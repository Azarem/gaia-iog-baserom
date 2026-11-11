#!/usr/bin/env python3
"""Scenario B2-WALK: synthetic collision patterns walked by the player, with the movement routines traced (step B2, 2026-10-30).

Copy-and-extend of scenario_b2_special_tiles.py (that file is not changed). The trial Lua is kit/lib/b2_kit.lua (b2.trial):
one row per frame (position, speeds, flags, the sub-pixel position in and out of PlayerMovementTick, the traced routines
entered, optional register snapshots at routine entries).

usage: scenario_b2_walk.py --suite NAME [--rom PATH] [--tag O|R-plain|R-tagged] [--out DIR] [--repeat 2] [--show CASE]
suites are defined in SUITES below (functions returning a list of cases). Every case runs --repeat times and the rows must be
identical. Raw rows go to raw/B2w_<suite>_<tag>_<date>.json.

A case: name, x, y (actor pixel position: X = centre, Y = bottom edge + 1), hold [buttons], frames, paint [[cx, cy, v], ...]
(absolute collision cells), clear [cx0, cy0, cx1, cy1] (cells set to 0 first; default the open room 19..27 x 7..13), snap [names],
extra [WRAM offsets sampled per frame].
"""
import argparse
import json
import os
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from mcp_client import Mesen  # noqa: E402
from scenario_b2_special_tiles import ensure_state, lua_literal  # noqa: E402

RESULTS = os.path.abspath(os.path.join(HERE, ".."))
BASEROM = os.path.abspath(os.path.join(HERE, "..", "..", "..", ".."))
DEFAULT_ROM = os.path.join(BASEROM, "rebuilt", "Illusion of Gaia.smc")
STATE_DIR = os.path.join(BASEROM, "rebuilt", "states")

TRIAL = r"""
local case = CASE
local A = gaia.addr
if case.notrace then b2.routines = {} end
b2.trial{
  frames = case.frames, hold = case.hold, snap = case.snap, extra = case.extra,
  setup = function()
    local c = case.clear
    for ty = c[2], c[4] do for tx = c[1], c[3] do gaia.coll.set(tx, ty, 0) end end
    for _, p in ipairs(case.paint) do gaia.coll.set(p[1], p[2], p[3]) end
    kit.w16(A.playerX, case.x); kit.w16(A.playerY, case.y)
    kit.w16(A.speedEw, 0); kit.w16(A.speedNs, 0)
    kit.w16(0x09C6, 0)
    kit.w16(0x09AE, kit.r16(0x09AE) & ~0x1000)
  end,
  final = function()
    local cells = {}
    for _, p in ipairs(case.watch or {}) do cells[#cells + 1] = { p[1], p[2], gaia.coll.get(p[1], p[2]) } end
    return { cells = cells, scene = kit.r16(A.sceneCur), stride = kit.r8(A.collStride) }
  end,
}
"""

OPEN = [19, 7, 27, 13]


def X(cx):
    return cx * 16 + 8


def Y(cy):
    return cy * 16 + 16


def case(name, x, y, hold, frames, paint, **kw):
    c = {"name": name, "x": x, "y": y, "hold": hold, "frames": frames, "paint": paint, "clear": OPEN, "snap": [], "extra": []}
    c.update(kw)
    return c


# ----------------------------------------------------------------------------------------------------------------------
def suite_controls():
    """Reproduction of the single-tile sweep and the direction controls (OQ-I029-1, OQ-I029-4)."""
    cs = []
    base = dict(x=344, y=176, hold=["right"], frames=40)
    cs.append(case("E control open", paint=[], **base))
    cs.append(case("E $0F row0 (stalls)", paint=[[24, 10, 0x0F]], **base))
    cs.append(case("E $06 row0", paint=[[24, 10, 0x06]], **base))
    cs.append(case("E $09 row0", paint=[[24, 10, 0x09]], **base))
    # west direction control: start at cell (26,10), slope tile at column 22
    wb = dict(x=X(26), y=Y(10), hold=["left"], frames=40)
    cs.append(case("W control open", paint=[], **wb))
    cs.append(case("W $05 at (22,10)", paint=[[22, 10, 0x05]], **wb))
    cs.append(case("W $0A at (22,10)", paint=[[22, 10, 0x0A]], **wb))
    cs.append(case("W $0F at (22,10) (stalls)", paint=[[22, 10, 0x0F]], **wb))
    return cs


def suite_dump():
    """One trace of every wall type with full traces, to read the routine order."""
    cs = []
    base = dict(x=344, y=176, hold=["right"], frames=24, snap=["EWPushDown", "EWPushUp", "PushUp", "PushDown", "CompEastSnap", "SnapYN", "SnapYS", "SnapXE"])
    cs.append(case("E $09 row0 traced", paint=[[24, 10, 0x09]], **base))
    cs.append(case("E $06 row0 traced", paint=[[24, 10, 0x06]], **base))
    return cs


def suite_i033s():
    """South walking into $06 / $09 columns (OQ-I033-1, OQ-I033-2, OQ-SAN2-2, OQ-I033-4 push direction)."""
    cs = []
    snap = ["FineE", "FineW", "CompSouthSnap", "SnapYN", "SnapYS", "AAlignEWS", "SouthBlocked"]
    # $06 column in col 23 rows 11-12 (right foot): sweep X (left-edge phase n = (X-8)&15) and Y
    for y in (190, 191, 192, 193):
        for x in (361, 364, 368, 372, 375):
            cs.append(case(f"S $06 col23 r11-12 X{x} Y{y}", x, y, ["down"], 6, [[23, 11, 6], [23, 12, 6]], snap=snap))
    # $09 mirror in col 22 rows 11-12 (left foot)
    for y in (190, 191, 192, 193):
        for x in (361, 364, 368, 372, 375):
            cs.append(case(f"S $09 col22 r11-12 X{x} Y{y}", x, y, ["down"], 6, [[22, 11, 9], [22, 12, 9]], snap=snap))
    return cs


def suite_i033s2():
    """Single-row $06 / $09 (the step leaves the wall row): lands on the next row line? (OQ-I033-2)"""
    cs = []
    snap = ["FineE", "FineW", "CompSouthSnap", "SnapYN", "SnapYS", "AAlignEWS", "SouthBlocked"]
    for y in (177, 181, 185, 189, 190, 191):
        for x in (364, 372):
            cs.append(case(f"S $06 col23 r11 X{x} Y{y}", x, y, ["down"], 6, [[23, 11, 6]], snap=snap))
            cs.append(case(f"S $09 col22 r11 X{x} Y{y}", x, y, ["down"], 6, [[22, 11, 9]], snap=snap))
            cs.append(case(f"S $0F col23 r12 X{x} Y{y}", x, y, ["down"], 6, [[23, 12, 15], [22, 12, 15]], snap=snap))
    return cs


def suite_i033n():
    """North walking into a $06 column (top-left foot) and a $09 column (top-right foot): SouthWallHandler / NorthWallHandler,
    SouthWallNudge, FineAdjustX*, SnapYNorthCollision (OQ-SAN2-2, OQ-I039-2, OQ-I039-3, OQ-I033-4)."""
    cs = []
    snap = ["FineE", "FineW", "CompYSnap", "SnapYN", "SnapYS", "SWHandler", "NWHandler", "SWNudge", "NProbeRedir", "AAlignEWN", "SnapXE", "SnapXW"]
    for y in (176, 177, 179, 181, 191):
        for x in (361, 364, 368, 375):
            cs.append(case(f"N $06 col22 r8-9 X{x} Y{y}", x, y, ["up"], 8, [[22, 8, 6], [22, 9, 6]], snap=snap))
            cs.append(case(f"N $09 col23 r8-9 X{x} Y{y}", x, y, ["up"], 8, [[23, 8, 9], [23, 9, 9]], snap=snap))
    for x in (364, 372):
        cs.append(case(f"N $0F control X{x} Y176", x, 176, ["up"], 8, [[22, 9, 15], [23, 9, 15]], snap=snap))
        cs.append(case(f"N open control X{x} Y176", x, 176, ["up"], 8, [], snap=snap))
    return cs


def suite_i040e():
    """East walking into a $09 (top-right) / $06 (bottom-right) cell at several Y phases: push magnitude (OQ-I040-4, OQ-I039-3)."""
    cs = []
    snap = ["EWPushDown", "EWPushUp", "PushUp", "PushDown", "CompEastSnap", "SnapYN", "SnapYS", "SnapXE", "AAlignNSE", "AAlignY", "FineE", "FineW"]
    for y in (176, 178, 181, 184, 187, 190, 191):
        cs.append(case(f"E $09 (24,10) Y{y}", 344, y, ["right"], 36, [[24, 10, 9]], snap=snap))
    for y in (161, 164, 168, 171, 174, 176):
        cs.append(case(f"E $06 (24,10) Y{y}", 344, y, ["right"], 36, [[24, 10, 6]], snap=snap))
    return cs


def suite_i039n():
    """SouthWallNudge ($AB bit 1) with north-only and north+west holds (OQ-I039-2)."""
    cs = []
    snap = ["SWNudge", "SWHandler", "CompYSnap", "FineW", "SnapXW", "SnapYS", "SnapYN", "NProbeRedir"]
    for hold, hn in ((["up"], "U"), (["up", "left"], "UL")):
        for x in (378, 377, 380, 372):
            cs.append(case(f"NN $06 col23 r8-9 {hn} X{x} Y176", x, 176, hold, 6, [[23, 8, 6], [23, 9, 6]], snap=snap))
        cs.append(case(f"NN $06 col23 r9 only {hn} X378 Y176", 378, 176, hold, 6, [[23, 9, 6]], snap=snap))
    return cs


def suite_slopes():
    """Slope trajectories for OQ-I038-1/2/5, OQ-I033-3, OQ-I039-1/5. Observation first: single tile and a diagonal run per type."""
    cs = []
    snap = ["ERampDown", "ERampUp", "WRampUp", "WRampDown", "WRampDesc", "WRampAsc", "WEdgeDesc", "WEdgeAsc", "SnapXE", "SnapXW", "CancelV", "ClrEW5", "ClrEW6", "EWPushDown", "EWPushUp"]
    eb = dict(x=344, y=176, hold=["right"], frames=40)
    wb = dict(x=X(26), y=Y(10), hold=["left"], frames=40)
    cs.append(case("E $0A single (24,10)", paint=[[24, 10, 0x0A]], snap=snap, **eb))
    cs.append(case("E $05 single (24,10)", paint=[[24, 10, 0x05]], snap=snap, **eb))
    cs.append(case("E $0A diag down (24,10)(25,11)(26,12)", paint=[[24, 10, 0x0A], [25, 11, 0x0A], [26, 12, 0x0A]], snap=snap, **eb))
    cs.append(case("E $0A diag up (24,12)(25,11)(26,10)", paint=[[24, 12, 0x0A], [25, 11, 0x0A], [26, 10, 0x0A]], snap=snap, **eb))
    cs.append(case("E $05 diag down (24,10)(25,11)(26,12)", paint=[[24, 10, 0x05], [25, 11, 0x05], [26, 12, 0x05]], snap=snap, **eb))
    cs.append(case("E $05 diag up (24,12)(25,11)(26,10)", paint=[[24, 12, 0x05], [25, 11, 0x05], [26, 10, 0x05]], snap=snap, **eb))
    cs.append(case("W $05 diag down (24,10)(23,11)(22,12)", paint=[[24, 10, 0x05], [23, 11, 0x05], [22, 12, 0x05]], snap=snap, **wb))
    cs.append(case("W $0A diag up (24,12)(23,11)(22,10)", paint=[[24, 12, 0x0A], [23, 11, 0x0A], [22, 10, 0x0A]], snap=snap, **wb))
    return cs


def suite_rampphase():
    """Column-crossing Y step on $0A / $05 for the four X phases and three Y phases (OQ-I038-1: 4n and the +4 bias)."""
    cs = []
    snap = ["ERampDown", "WRampUp", "CancelV"]
    for typ, tn in ((0x0A, "$0A"), (0x05, "$05")):
        for x0 in (344, 345, 346, 347):
            for y0 in (176, 177, 178, 179):
                cs.append(case(f"R {tn} X{x0} Y{y0}", x0, y0, ["right"], 30, [[24, 10, typ]], snap=snap))
    return cs


def suite_rampwall():
    """East into a wall at the foot of a $0A / $05 tile: corner snap Y compensation (OQ-I038-2)."""
    cs = []
    snap = ["ERampDown", "WRampUp", "ERampUp", "WRampDown", "ECorner", "SnapXE", "SnapYN", "SnapYS"]
    wall = [[25, r, 0x0F] for r in range(8, 13)]
    for typ, tn in ((0x0A, "$0A"), (0x05, "$05")):
        for x0, y0 in ((344, 176), (345, 177), (344, 180), (344, 184)):
            cs.append(case(f"RW {tn} (24,10) wall col25 X{x0} Y{y0}", x0, y0, ["right"], 36, [[24, 10, typ]] + wall, snap=snap))
    cs.append(case("RW $0A (24,10)+(24,11) wall col25", 344, 176, ["right"], 36, [[24, 10, 0x0A], [24, 11, 0x0A]] + wall, snap=snap))
    cs.append(case("RW $0F only col25 (control)", 344, 176, ["right"], 36, wall, snap=snap))
    wall27 = [[27, r, 0x0F] for r in range(6, 14)]
    cs.append(case("RW $05 row (24..26,10) wall col27", 344, 176, ["right"], 60, [[24, 10, 5], [25, 10, 5], [26, 10, 5]] + wall27, snap=snap))
    cs.append(case("RW $05 up (24,12)(25,11)(26,10) wall col27", 344, 192, ["right"], 60, [[24, 12, 5], [25, 11, 5], [26, 10, 5]] + wall27, snap=snap))
    cs.append(case("RW $0A down (24,10)(25,11)(26,12) wall col27", 344, 176, ["right"], 60, [[24, 10, 10], [25, 11, 10], [26, 12, 10]] + wall27, snap=snap))
    return cs


def suite_rampdetect():
    """Which probe row first engages a $0A / $05 ramp walking east (OQ-I038-5): tile row relative to the feet."""
    cs = []
    snap = ["ERampDown", "WRampUp", "ERampUp", "WRampDown"]
    for typ, tn in ((0x0A, "$0A"), (0x05, "$05")):
        for row in (9, 10, 11):
            for y0 in (176, 184):
                cs.append(case(f"RD {tn} cell(24,{row}) Y{y0}", 344, y0, ["right"], 30, [[24, row, typ]], snap=snap))
    return cs


def suite_nslope():
    """North / south walking on $03 and $0C columns: slopeFracAccum filter, $09AF bit $10 flag, direction (OQ-I039-1, OQ-I039-5, OQ-I033-3)."""
    cs = []
    snap = ["NSlopeR", "NSlopeL", "SSlopeR", "SSlopeL"]
    col = lambda t, rows: [[23, r, t] for r in rows]
    for typ, tn in ((0x0C, "$0C"), (0x03, "$03")):
        cs.append(case(f"NS {tn} north X376 from Y208", 376, 208, ["up"], 40, col(typ, range(8, 13)), snap=snap, extra=[0x09C6, 0x09AE]))
        cs.append(case(f"NS {tn} north X376 from Y205", 376, 205, ["up"], 40, col(typ, range(8, 13)), snap=snap, extra=[0x09C6, 0x09AE]))
        cs.append(case(f"NS {tn} south X376 from Y144", 376, 144, ["down"], 40, col(typ, range(8, 13)), snap=snap, extra=[0x09C6, 0x09AE]))
        cs.append(case(f"NS {tn} south X376 from Y147", 376, 147, ["down"], 40, col(typ, range(8, 13)), snap=snap, extra=[0x09C6, 0x09AE]))
    for typ, tn in ((0x0C, "$0C"), (0x03, "$03")):
        cs.append(case(f"NS {tn} short north (rows 11-12) X376 from Y208", 376, 208, ["up"], 40, col(typ, [11, 12]), snap=snap, extra=[0x09C6, 0x09AE]))
        cs.append(case(f"NS {tn} short south (rows 8-9) X376 from Y144", 376, 144, ["down"], 40, col(typ, [8, 9]), snap=snap, extra=[0x09C6, 0x09AE]))
        for y0 in (223, 221, 219, 217, 216, 215, 213):
            cs.append(case(f"NS {tn} bottom-row north X376 from Y{y0}", 376, y0, ["up"], 12, col(typ, [12]), snap=snap, extra=[0x09C6, 0x09AE]))
    return cs


def suite_flushpush():
    """East into a wall piece with X flush and Y flush / off by n: SnapYNorthCollision with $24 = 0 (OQ-I039-3)."""
    cs = []
    snap = ["EWPushDown", "EWPushUp", "PushUp", "PushDown", "CompEastSnap", "SnapYN", "SnapYS", "SnapXE", "AAlignNSE", "AAlignY", "EWNorthFlag", "EWSouthFlag"]
    for x in (366, 370, 372, 374, 376):
        for y in (176, 177, 184, 191):
            cs.append(case(f"FP $09 (23,10) X{x} Y{y}", x, y, ["right"], 8, [[23, 10, 9]], snap=snap))
        for y in (161, 168, 176):
            cs.append(case(f"FP $06 (23,10) X{x} Y{y}", x, y, ["right"], 8, [[23, 10, 6]], snap=snap))
    return cs


SUITES = {k[6:]: v for k, v in list(globals().items()) if k.startswith("suite_")}


def run_case(m, c, state):
    m.call("load_state_file", path=state)
    code = TRIAL.replace("CASE", lua_literal(c))
    r = m.call("run_script", code=code, name="b2_walk", includes=["gaia_kit", "b2_kit"], frames=c["frames"] + 8, turbo=True)
    if r.get("stopReason") != "script_done":
        raise RuntimeError(f"trial did not finish: {r.get('stopReason')} {r.get('log')}")
    res = r["result"]
    ctl = res.get("ctl36", 0)
    if ctl < c["frames"] - 2:
        raise RuntimeError(f"positive control failed: $36 writes {ctl} < {c['frames']}")
    return res


def summarize(c, res):
    rows = res["rows"]
    x0, y0 = c["x"], c["y"]
    xs = [r[1] for r in rows]
    ys = [r[2] for r in rows]
    return {"case": c["name"], "x0": x0, "y0": y0, "xEnd": xs[-1], "yEnd": ys[-1], "dx": xs[-1] - x0, "dy": ys[-1] - y0,
            "ctl36": res["ctl36"], "ticks": sum(r[18] for r in rows)}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--suite", required=True)
    ap.add_argument("--rom", default=DEFAULT_ROM)
    ap.add_argument("--tag", default="O")
    ap.add_argument("--state", default=None)
    ap.add_argument("--out", default=os.path.join(RESULTS, "raw"))
    ap.add_argument("--repeat", type=int, default=2)
    ap.add_argument("--show", default=None, help="print the rows of the cases whose name contains this text")
    ap.add_argument("--notrace", action="store_true")
    ap.add_argument("--brief", type=int, default=0, help="print the first N rows of every case as x,y,vis[+snaps]")
    ap.add_argument("--only", default=None, help="run only the cases whose name contains this text")
    args = ap.parse_args()
    os.makedirs(args.out, exist_ok=True)
    lib = os.path.join(RESULTS, "kit", "lib")
    cases = SUITES[args.suite]()
    if args.only:
        cases = [c for c in cases if args.only in c["name"]]
    if args.notrace:
        for c in cases:
            c["notrace"] = True
    with Mesen(args=[f"--mcp-lib-dir={lib}", f"--mcp-results-dir={args.out}"]) as m:
        info = m.call("load_rom", path=args.rom)["rom"]
        m.call("pause")
        print("ROM", info["path"], "sha1", info["fileSha1"], "crc32", info["fileCrc32"], "size", info["fileSizeBytes"])
        prefix = "orig" if args.tag == "O" else args.tag
        state = args.state or os.path.join(STATE_DIR, f"{prefix}_S01r_south-cape-ready.mss")
        print("state:", ensure_state(m, args.rom, state))
        m.call("load_state_file", path=state)
        print("S01 ready: scene", hex(m.u16(0x644)), "pos", m.u16(0x1014), m.u16(0x1016), "mask", hex(m.u16(0x65A)), "stride", m.u8(0x693))
        out_cases, reference = [], {}
        for c in cases * args.repeat:
            res = run_case(m, c, state)
            if c["name"] in reference:
                if reference[c["name"]] != res["rows"]:
                    raise AssertionError(f"not deterministic: {c['name']}")
                continue
            reference[c["name"]] = res["rows"]
            s = summarize(c, res)
            out_cases.append({"case": c, "summary": s, "result": res})
            print(f"{c['name']:34s} dx={s['dx']:+4d} dy={s['dy']:+4d} end=({s['xEnd']},{s['yEnd']}) ctl36={s['ctl36']}")
            if args.brief:
                for r in res["rows"][:args.brief]:
                    sn = ";".join(",".join(str(v) for v in q) for q in r[17])
                    print(f"    f{r[0]:02d} x={r[1]} y={r[2]} s=({r[3]},{r[4]}) f10={r[5]:04X} tin=({r[7]},{r[8]}) tout=({r[11]},{r[12]}) AA={r[13]:04X} {r[16]} {sn}")
            if args.show and args.show in c["name"]:
                for r in res["rows"]:
                    print("   ", json.dumps(r, separators=(",", ":")))
        stamp = time.strftime("%Y%m%d")
        out = os.path.join(args.out, f"B2w_{args.suite}_{args.tag}_{stamp}.json")
        with open(out, "w", encoding="utf-8") as f:
            json.dump({"tag": args.tag, "rom": info, "state": state, "repeat": args.repeat, "suite": args.suite, "cases": out_cases}, f, separators=(",", ":"))
        print("wrote", out)
        errs = [l for l in m.stderr_lines if "rror" in l]
        if errs:
            print("stderr errors:", errs[:3])


if __name__ == "__main__":
    main()
