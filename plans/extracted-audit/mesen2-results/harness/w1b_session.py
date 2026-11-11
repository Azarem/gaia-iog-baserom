#!/usr/bin/env python3
"""W1-b address census sessions (ROM O): batch "Scene and flags" ($06A0, $06C8, $06CC, $06EF, $06F0, $06F2, $0402-$0405, $0D6E, $09CC, ...).

usage: w1b_session.py [--only name,name] [--list] [--natural] [--boot] [--mask]

Same drivers as w1a_session.py (the session table is imported from it: states, seeded bots, direction patterns, timelines, quick warps,
the recorded natural replay), but the census is kit/lib/w1b_kit.lua (`w1b.startB`). Every session: load a state, run the H1 validity test
(load, advance_frame 120, check cpu.k / cpu.sp / scene), load the state again and run the census. Result of each session:
raw/W1b_<name>_<date>.json (census rows, controls, H1 record, the Lua text). w1b_merge.py merges them.
"""
import argparse
import json
import os
import sys
import time

import w1a_session as A
from a_common import RAW, S01R, open_session, stamp

# extra W1-b sessions: the scenes whose display preset sets scrollModeFlags bit 4 (the bit-12 setters found statically: presets $19 / $2A / $2B / $2D
# are used by scenes $59, $8C, $8D, $8E, $8F, $C0, $FE) and the scrolling scenes of OQ-I051-2 / OQ-57 ($4E)
A.add("warp_b", S01R, 2 + 700 * 8, "quick warps through the bit-12 preset scenes and $4E: $59 $8C $8D $8E $8F $C0 $4E $FE", scene=0x59,
      chain=[(2 + 700 * i, c) for i, c in enumerate([0x59, 0x8C, 0x8D, 0x8E, 0x8F, 0xC0, 0x4E, 0xFE]) if i > 0], drive="bot", bot=A.TALK)
A.add("warp_b2", S01R, 2 + 700 * 4, "quick warps: $F7 credits, $FE world map, $FD, $8C again (LoadPlayerGraphics skip scenes $F7/$FE/$8C)", scene=0xF7,
      chain=[(2 + 700 * i, c) for i, c in enumerate([0xF7, 0xFE, 0xFD, 0x8C]) if i > 0], drive="bot", bot=A.TALK)

A.add("warp_l1", S01R, 2 + 700 * 6, "quick warps through dual-layer scenes (layer-1 collision overlay): $60 $61 $62 $67 $0B $30", scene=0x60,
      chain=[(2 + 700 * i, c) for i, c in enumerate([0x60, 0x61, 0x62, 0x67, 0x0B, 0x30]) if i > 0], drive="bot", bot=A.TALK)

S = A.S


MASK_PROBES = "{collL1_0080={off=168056, addr=0x80, size=2, dp=true}}"
MASK_WATCH = "{{name=\"0A1F mask\", lo=0x0A1F, hi=0x0A1F, kinds={\"read\"}, ctxMask=true}}"


def lua_for(s, mask=False):
    ats = []
    if s.get("scene") is not None:
        ats.append(f"[2]=function() kit.w16(0x0642, {s['scene']}) end")
    for fr, sc in s.get("chain", []):
        ats.append(f"[{fr}]=function() kit.w16(0x0642, {sc}) end")
    head, extra = "", ""
    drive = s["drive"]
    if drive == "pattern":
        head += A.DIR_PATTERN % ()
        extra = "input=pattern, "
    elif drive == "bot":
        extra = f"bot={A.bot_lua(s['bot'])}, "
    elif drive == "timeline":
        steps = ",".join("{n=%d,b={%s}}" % (n, ",".join(json.dumps(b) for b in bl)) for n, bl in s["steps"])
        extra = "timeline={start=1,loop=false,steps={%s}}, " % steps
    at = "at={" + ",".join(ats) + "}, " if ats else ""
    opts = "logCap=60" + (", extraWatch=" + MASK_WATCH + ", extraProbes=" + MASK_PROBES if mask else "")
    return (head + "local h = w1b.startB{" + opts + "}\n" +
            f"acen.run{{frames={s['frames']}, writes=false, reads=false, refill=10, {extra}{at}"
            "final=function() local r = h.rows(); r.endScene = kit.r16(0x0644); r.endHp = kit.r16(0x0ACE); "
            "r.endFlags = kit.r16(0x09AE); r.endAbil = kit.r16(0x0AA2); return r end}")


def run_session(m, info, s, mask=False):
    t = time.time()
    rec = A.h1(m, s["state"])
    if not rec["ok"]:
        raise RuntimeError(f"H1 failed {rec}")
    m.call("load_state_file", path=s["state"])
    for addr, val, size in s.get("pokes", []):
        m.poke(addr, val)
    code = lua_for(s, mask)
    r = m.run_script_checked(code, ok_stop=("script_done",), name="w1b_run", includes=["gaia_kit", "a_census", "w1b_kit"], frames=s["frames"] + 20,
                             turbo=True, timeoutMs=1800000)
    res = r["result"]
    res["session"] = {k: v for k, v in s.items() if k not in ("bot", "steps")}
    res["h1"] = rec
    res["rom"] = info
    res["lua"] = code
    res["warnings"] = r.get("__warnings__", [])
    res["log"] = r.get("log")
    res["seconds"] = round(time.time() - t, 1)
    out = os.path.join(RAW, f"{'W1bm' if mask else 'W1b'}_{s['name']}_{stamp()}.json")
    with open(out, "w", encoding="utf-8") as f:
        json.dump(res, f, indent=1)
    return res


def run_natural(m, info):
    t = time.time()
    N = A.NATURAL
    rec = A.h1(m, N["state"])
    if not rec["ok"]:
        raise RuntimeError(f"H1 failed {rec}")
    m.call("load_state_file", path=N["state"])
    with open(N["input"], encoding="utf-8") as f:
        doc = json.load(f)
    lua = ("local h = w1b.startB{logCap=60}\nlocal pub = false\n"
           "kit.onFrame(function() if h.frames >= 20050 and not pub then pub = true; emu.mcp.result(h.rows()) end end)\n")
    m.call("load_script", name="w1b_nat", code=lua, includes=["gaia_kit", "a_census", "w1b_kit"])
    total = 0
    for part in A.chunk_sequence(doc["segments"]):
        m.call("play_input", sequence=part, turbo=True, thenPause=True)
        total += sum(p["frames"] for p in part)
        print(f"  natural: {total} frames", flush=True)
    m.call("advance_frame", frames=70, turbo=True)
    res = m.call("get_script_result", name="w1b_nat")
    res = res.get("result", res) if isinstance(res, dict) else res
    out_png = m.shot("W1b_natural_end")
    m.call("unload_script", name="w1b_nat")
    final = dict(census=res, h1=rec, rom=info, lua=lua, inputFile=os.path.basename(N["input"]), inputFrames=total, seconds=round(time.time() - t, 1),
                 screenshot=out_png, endScene=m.u16(0x0644))
    out = os.path.join(RAW, f"W1b_{N['name']}_{stamp()}.json")
    with open(out, "w", encoding="utf-8") as f:
        json.dump(final, f, indent=1)
    return final


def run_boot(m, info):
    """Cold boot census (fromReset power, 720 frames): the boot-time writers of the watched bytes (wram-init, the boot DMA fill)."""
    t = time.time()
    code = ("local h = w1b.startB{logCap=60}\n"
            "kit.onFrame(function() if h.frames >= 700 then local r = h.rows(); r.endScene = kit.r16(0x0644); kit.finish(r) end end)")
    r = m.run_script_checked(code, ok_stop=("script_done",), name="w1b_run", includes=["gaia_kit", "w1b_kit"], frames=720, turbo=True,
                             timeoutMs=1800000, fromReset="power")
    res = dict(session=dict(name="boot_power", frames=700, note="cold boot (fromReset power), 700 frames"), final=r["result"], rom=info, lua=code,
               h1=dict(state="(cold boot, no state)", ok=True, k=0x80, sp=0x1FF, scene=r["result"].get("endScene"), expectScene=None),
               frames=r["result"].get("frames"), scene=r["result"].get("endScene"), seconds=round(time.time() - t, 1), log=r.get("log"))
    out = os.path.join(RAW, f"W1b_boot_power_{stamp()}.json")
    with open(out, "w", encoding="utf-8") as f:
        json.dump(res, f, indent=1)
    return res


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--only", default="")
    ap.add_argument("--list", action="store_true")
    ap.add_argument("--natural", action="store_true")
    ap.add_argument("--boot", action="store_true")
    ap.add_argument("--mask", action="store_true", help="add the $0A1F read watch keyed on the accumulator mask; files W1bm_*")
    args = ap.parse_args()
    if args.list:
        for s in S:
            print(s["name"], s["frames"], s["note"])
        return
    only = set(x for x in args.only.split(",") if x)
    m, info = open_session()
    print("ROM", info["fileSha1"], info["fileSizeBytes"], flush=True)
    try:
        if args.boot:
            r = run_boot(m, info)
            print("boot", r["frames"], "frames, ctl36", r["final"].get("control36Writes"), "nmi", r["final"].get("nmiExecs"), "hits", r["final"].get("hits"), flush=True)
            return
        if args.natural:
            f = run_natural(m, info)
            print("natural", f["inputFrames"], "frames", f["seconds"], "s end scene", hex(f["endScene"]), flush=True)
            return
        for s in S:
            if only and s["name"] not in only:
                continue
            try:
                res = run_session(m, info, s, args.mask)
                fin = res.get("final") or {}
                print(f"{s['name']:22s} {res['seconds']:6.1f}s frames={res.get('frames')} ctl36={fin.get('control36Writes')} nmi={fin.get('nmiExecs')} "
                      f"hits={fin.get('hits')} endScene={fin.get('endScene', 0):02X}", flush=True)
            except Exception as e:  # keep going: a failed session is reported, not hidden
                print("FAILED", s["name"], repr(e)[:400], flush=True)
    finally:
        m.close()


if __name__ == "__main__":
    main()
