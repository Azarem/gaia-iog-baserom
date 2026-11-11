#!/usr/bin/env python3
"""Scenario B2-SPECIAL: synthetic collision patterns against CheckActorOnSpecialTile (test harness for the plan).

Question context (inventory rows OQ-16, OQ-I029-5, OQ-I033-4, OQ-I030-3): collision types $06 and $09 are "not traced
to a purpose". Static reading (tile_collision_physics.asm, CheckActorOnSpecialTile): the probe tile
((x - 8) >> 4, (y - 16) >> 4) of the actor is read; the pattern {T = $06 and T+(1,1) = $06} or
{T = $00, T+(1,0) = $09 and T+(0,1) = $09} makes the axis routine return carry set without snapping; the probe is skipped
when (x - 8) or (y - 16) is 16-aligned.

This script paints each pattern in an open corridor of South Cape, holds a direction and records the player trajectory.

usage: scenario_b2_special_tiles.py [--rom PATH] [--tag O|R-plain|R-tagged] [--out DIR] [--repeat N]
Needs: the kit folder (mesen2-results/kit/lib) as --mcp-lib-dir; the state is created on first run.
"""
import argparse
import json
import os
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from mcp_client import Mesen  # noqa: E402

RESULTS = os.path.abspath(os.path.join(HERE, ".."))
BASEROM = os.path.abspath(os.path.join(HERE, "..", "..", "..", ".."))
DEFAULT_ROM = os.path.join(BASEROM, "rebuilt", "Illusion of Gaia.smc")
STATE_DIR = os.path.join(BASEROM, "rebuilt", "states")

# trial code; CASE is injected as a Lua table literal
TRIAL = r"""
local case = CASE
local A = gaia.addr
local tx0, ty0 = case.tx, case.ty            -- probe tile T
gaia.trial{
  frames = case.frames,
  hold = case.hold,
  setup = function()
    -- clear a 6x4 area around T to $00, paint the pattern, then place the player
    for dy = -1, 2 do for dx = -2, 3 do gaia.coll.set(tx0 + dx, ty0 + dy, 0) end end
    for _, p in ipairs(case.paint) do gaia.coll.set(tx0 + p[1], ty0 + p[2], p[3]) end
    kit.w16(A.playerX, case.x); kit.w16(A.playerY, case.y)
    kit.w16(A.speedEw, 0); kit.w16(A.speedNs, 0)
  end,
  sample = function()
    local p = gaia.player()
    return { p.x, p.y, p.sEw, p.sNs, p.flags10 }
  end,
  final = function()
    local tx, ty, active = gaia.coll.probeTile(kit.r16(A.playerX), kit.r16(A.playerY))
    return { probeTx = tx, probeTy = ty, probeActive = active, frame36 = kit.r16(A.frame36) }
  end,
}
"""


def lua_literal(v):
    if isinstance(v, dict):
        return "{" + ",".join(f"[{json.dumps(k)}]={lua_literal(x)}" for k, x in v.items()) + "}"
    if isinstance(v, (list, tuple)):
        return "{" + ",".join(lua_literal(x) for x in v) + "}"
    if isinstance(v, bool):
        return "true" if v else "false"
    if isinstance(v, str):
        return json.dumps(v)
    return str(v)


def ensure_state(m, rom, state):
    """Create the S01-ready state: quick warp from the boot logo, dismiss the scene banner, save with a sidecar."""
    if os.path.isfile(state):
        try:
            m.call("load_state_file", path=state)
            return "loaded"
        except Exception as e:  # rom_mismatch etc.: rebuild it
            print("state not usable, rebuilding:", e)
    m.call("load_rom", path=rom)
    m.call("pause")
    m.call("advance_frame", frames=100)                     # boot logo scene $FB
    assert m.u16(0x644) == 0xFB, "not on the boot logo"
    m.poke(0x642, 1)                                        # sceneNext = 1 (quick warp: only valid from $FB)
    m.call("advance_frame", frames=240)
    assert m.u16(0x644) == 1, f"scene {m.u16(0x644):04X}"
    for _ in range(40):                                     # dismiss the scene-title banner ($00B4 != 0)
        if m.u8(0xB4) == 0:
            break
        m.call("set_input", buttons=["a"], frames=2)
        m.call("advance_frame", frames=4)
    m.call("advance_frame", frames=30)
    assert m.u8(0xB4) == 0 and m.u16(0x65A) == 0, "banner or input lock still set"
    os.makedirs(os.path.dirname(state), exist_ok=True)
    m.call("save_state_file", path=state, note="S01 ready: quick warp, banner dismissed, 30 frames",
           meta={"scene": 1, "flags": [], "form": "Will"})
    return "created"


def run_case(m, case, state):
    m.call("load_state_file", path=state)
    # the state restores the position; the scenario writes it again at its first frame
    code = TRIAL.replace("CASE", lua_literal(case))
    r = m.call("run_script", code=code, name="b2_special", includes=["gaia_kit"], frames=case["frames"] + 8, turbo=True)
    if r.get("stopReason") != "script_done":
        raise RuntimeError(f"trial did not finish: {r.get('stopReason')} {r.get('log')}")
    return r["result"]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--rom", default=DEFAULT_ROM)
    ap.add_argument("--tag", default="O", help="ROM tag used in the state file name and the output (O, R-plain, R-tagged)")
    ap.add_argument("--out", default=os.path.join(RESULTS, "raw"))
    ap.add_argument("--repeat", type=int, default=2, help="run the whole sweep this many times and require identical samples")
    args = ap.parse_args()
    os.makedirs(args.out, exist_ok=True)

    lib = os.path.join(RESULTS, "kit", "lib")
    with Mesen(args=[f"--mcp-lib-dir={lib}", f"--mcp-results-dir={args.out}"]) as m:
        info = m.call("load_rom", path=args.rom)["rom"]
        m.call("pause")
        print("ROM", info["path"], "sha1", info["fileSha1"], "size", info["fileSizeBytes"])
        prefix = "orig" if args.tag == "O" else args.tag
        state = os.path.join(STATE_DIR, f"{prefix}_S01r_south-cape-ready.mss")
        print("state:", ensure_state(m, args.rom, state))
        m.call("load_state_file", path=state)
        print("S01 ready: scene", hex(m.u16(0x644)), "pos", m.u16(0x1014), m.u16(0x1016), "mask", hex(m.u16(0x65A)),
              "stride", m.u8(0x693))

        # Open room of South Cape: tile columns 19..27, rows 7..13 are type $00 (see the map dump in the result file).
        # The player starts at tile (21,10) and walks east; one test tile is painted at column 24 in a chosen row.
        px0, py0 = 21 * 16 + 8, 10 * 16 + 16
        base = {"tx": 24, "ty": 10, "x": px0, "y": py0, "frames": 40, "hold": ["right"]}
        cases = [dict(base, name="control-open", paint=[])]
        for ttype in (0x0F, 0x06, 0x09, 0x05, 0x0A):
            for row in (-1, 0, 1):
                cases.append(dict(base, name=f"type {ttype:02X} at row {row:+d}", paint=[[0, row, ttype]]))
        results = []
        reference = {}
        for case in cases * args.repeat:
            res = run_case(m, case, state)
            if case["name"] in reference:
                assert reference[case["name"]] == res["samples"], f"not deterministic: {case['name']}"
                continue
            reference[case["name"]] = res["samples"]
            s = res["samples"]
            x0, y0 = case["x"], case["y"]
            xs = [row[0] for row in s]
            ys = [row[1] for row in s]
            dev = next((i for i, y in enumerate(ys) if y != y0), None)      # first frame where y left its start value
            stall = next((i for i in range(1, len(xs)) if xs[i] == xs[i - 1]), None)  # first frame x did not advance
            summary = {
                "case": case["name"], "x0": x0, "y0": y0, "xEnd": xs[-1], "yEnd": ys[-1],
                "dx": xs[-1] - x0, "dy": ys[-1] - y0, "yDevFrame": dev, "xStallFrame": stall,
                "yTrace": ys[:20],
            }
            results.append({"summary": summary, "samples": s})
            print(f"{case['name']:22s} dx={summary['dx']:+4d} dy={summary['dy']:+4d} yDev@{dev} xStall@{stall} y[:12]={ys[:12]}")
        stamp = time.strftime("%Y%m%d")
        out = os.path.join(args.out, f"B2_special_tiles_{args.tag}_{stamp}.json")
        with open(out, "w", encoding="utf-8") as f:
            json.dump({"tag": args.tag, "rom": info, "state": state, "repeat": args.repeat, "cases": results}, f, indent=1)
        print("wrote", out)
        errs = [l for l in m.stderr_lines if "rror" in l]
        if errs:
            print("stderr errors:", errs[:3])


if __name__ == "__main__":
    main()
