#!/usr/bin/env python3
"""R2 warp probe driver (OQ-30): put the player on warp rectangles of ROM O and read the revive / save records.

For every scene warp (12-byte entry) of the chosen source scenes: load the S01r state, run `r2w.run` (kit/lib/r2w_kit.lua) and record
the row in raw/R2_<tag>.jsonl / .md. ROM O only. Entries are read from the ROM (scene_warps, 98868).

usage (from this folder):
    timeout 1500 python r2_warp.py --tag O_savewarp --save           # the 23 save warps
    timeout 600 python r2_warp.py --tag O_warpctl --scenes 1A,CC,E3 --nosave   # the non-save entries of those scenes (controls)
"""
import argparse
import json
import os
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from mcp_client import Mesen  # noqa: E402
from r2_sweep import ARGS, RAW, ROMS  # noqa: E402

ROM = open(ROMS["O"]["rom"], "rb").read()
SW = 98868


def u16(o):
    return ROM[o] | (ROM[o + 1] << 8)


def scene_entries(sid):
    off = 0x10000 + u16(SW + 2 * sid)
    out = []
    while ROM[off] != 0xFF:
        out.append((off, list(ROM[off:off + 12])))
        off += 12
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--tag", default="O_savewarp")
    ap.add_argument("--scenes", default="")
    ap.add_argument("--save", action="store_true")
    ap.add_argument("--nosave", action="store_true")
    ap.add_argument("--settle", type=int, default=60)
    ap.add_argument("--hold", type=int, default=90)
    ap.add_argument("--cwr", type=int, default=174459)
    ap.add_argument("--yoff", type=int, default=16)
    ap.add_argument("--xoff", type=int, default=8)
    a = ap.parse_args()
    if a.scenes:
        srcs = [int(x, 16) for x in a.scenes.split(",")]
    elif a.save:
        srcs = [0x1A, 0x1C, 0x24, 0x4C, 0x5E, 0x6B, 0x88, 0xB1, 0xB7, 0xCC, 0xDF, 0xE1, 0xE2, 0xE3]
    else:
        ap.error("--scenes or --save")
    todo = []
    for sid in srcs:
        for off, e in scene_entries(sid):
            save = bool(e[9] & 0x80)
            if a.save and not save:
                continue
            if a.nosave and save:
                continue
            todo.append((sid, off, e))
    cfg = ROMS["O"]
    jl = os.path.join(RAW, f"R2_{a.tag}.jsonl")
    md = os.path.join(RAW, f"R2_{a.tag}.md")
    m = Mesen(args=ARGS)
    try:
        m.call("load_rom", path=cfg["rom"])
        m.call("pause")
        m.call("load_labels", path=cfg["labels"], replace=True)
        with open(jl, "w") as fj, open(md, "w") as fm:
            fm.write("| src | entry off | rect x,y,w,h | dest | save | staged | arrived | $0AF0 before>after | $0AF4 before>after | $0AF2/$0AF6 after | warp ptr (entry+4) | why |\n|---|---|---|---|---|---|---|---|---|---|---|---|\n")
            for sid, off, e in todo:
                t0 = time.time()
                m.call("load_state_file", path=cfg["state"])
                rx, ry, rw, rh = e[0], e[1], e[2], e[3]
                x = rx * 16 + a.xoff
                y = ry * 16 + a.yoff
                code = "r2w.run{scene=%d, x=%d, y=%d, dest=%d, settle=%d, hold=%d, cwr=%d}" % (sid, x, y, e[4], a.settle, a.hold, a.cwr)
                try:
                    res = m.run_script_checked(code, frames=1600, includes=["gaia_kit", "r2w_kit"], turbo=True, timeoutMs=120000, maxLog=3, name="r2w")
                    row = res.get("result", {})
                except Exception as ex:  # noqa: BLE001
                    row = {"why": "error %s" % str(ex)[:160]}
                row.update({"src": sid, "off": off, "entry": e, "elapsed": round(time.time() - t0, 1)})
                fj.write(json.dumps(row) + "\n")
                fj.flush()
                b = row.get("before") or [None] * 4
                af = row.get("after") or [None] * 4
                ptr = (off + 4) & 0xFFFF
                fm.write("| %02X | %d | %d,%d,%d,%d | %02X | %s | %s | %s | %s>%s | %s>%s | %s/%s | %04X | %s |\n" % (
                    sid, off, rx, ry, rw, rh, e[4], "yes" if e[9] & 0x80 else "no",
                    ("%02X" % row["staged"]) if row.get("staged") is not None else "-", row.get("arrived", False),
                    b[0] if b[0] is None else "%04X" % b[0], af[0] if af[0] is None else "%04X" % af[0],
                    b[2] if b[2] is None else "%04X" % b[2], af[2] if af[2] is None else "%04X" % af[2],
                    af[1], af[3], ptr, row.get("why")))
                fm.flush()
                print("%02X off=%d rect=%s dest=%02X staged=%s why=%s before=%s after=%s ptr=%04X %.1fs" % (
                    sid, off, e[:4], e[4], row.get("staged"), row.get("why"),
                    [("%04X" % v) for v in b if v is not None], [("%04X" % v) for v in af if v is not None], ptr, row["elapsed"]), flush=True)
    finally:
        m.close()


if __name__ == "__main__":
    main()
