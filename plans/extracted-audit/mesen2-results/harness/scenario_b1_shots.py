#!/usr/bin/env python3
"""Scenario B1 shots: put the player next to the first `$06` cell and the first `$09` cell of a scene and take a screenshot.

Per scene: load the ready state S01r, quick warp (same procedure as scenario_b1_census.py), read the whole collision layer
with read_memory (WRAM 0x1C000, stride x rows x 256 bytes; index = (((ty>>4)*stride + (tx>>4)) << 8) | ((ty&15)<<4) | (tx&15)),
take the first cell of the type in row-major order (the same cell as the first entry of the census row), choose a free
neighbour cell (low nibble 0, high nibble 0; order west, east, south, north, then any free cell within 2), write the actor position
`$1014/$1016` = (cx*16+8, cy*16+16) (the cell centre convention of the B2 trial: the probe tile of CheckActorOnSpecialTile is
((x-8)>>4, (y-16)>>4)), zero the speeds `$09B2/$09B4`, advance 30 frames and call take_screenshot.

usage: scenario_b1_shots.py [--scenes 1,21 | --all] [--types 06,09] [--tag O]
Writes raw/B1_shots_<tag>_<first>-<last>.json (scene, type, cell, player cell, screenshot path) and the PNGs under raw/screenshots.
"""
import argparse
import json
import os
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from mcp_client import Mesen  # noqa: E402
from scenario_b1_census import ROM_O, STATE, warp, RESULTS  # noqa: E402


def make_reader(m):
    stride, rows = m.u8(0x693), m.u8(0x697)
    data = m.mem(0x1C000, stride * rows * 256)

    def cell(tx, ty):
        if tx < 0 or ty < 0 or tx >= stride * 16 or ty >= rows * 16:
            return None
        return data[(((ty >> 4) * stride + (tx >> 4)) << 8) | ((ty & 15) << 4) | (tx & 15)]

    return stride, rows, cell


def first_cell(stride, rows, cell, t):
    for ty in range(rows * 16):
        for tx in range(stride * 16):
            v = cell(tx, ty)
            if v is not None and (v & 15) == t:
                return tx, ty
    return None


def free_neighbour(cell, tx, ty):
    for dx, dy in ((-1, 0), (1, 0), (0, 1), (0, -1)):
        v = cell(tx + dx, ty + dy)
        if v == 0:
            return tx + dx, ty + dy
    for r in (2,):
        for dy in range(-r, r + 1):
            for dx in range(-r, r + 1):
                if cell(tx + dx, ty + dy) == 0:
                    return tx + dx, ty + dy
    return None


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--scenes", default="")
    ap.add_argument("--all", action="store_true", help="every valid scene of raw/B1_census_merged.json that has $06 or $09")
    ap.add_argument("--types", default="06,09")
    ap.add_argument("--tag", default="O")
    ap.add_argument("--out", default=os.path.join(RESULTS, "raw"))
    args = ap.parse_args()
    types = [int(x, 16) for x in args.types.split(",")]
    if args.all:
        merged = json.load(open(os.path.join(args.out, "B1_census_merged.json"), encoding="utf-8"))
        ids = sorted(int(k) for k, r in merged.items() if r["census"] == "ok" and (r["low"][6] or r["low"][9]))
    else:
        ids = [int(x) for x in args.scenes.split(",")]
    lib = os.path.join(RESULTS, "kit", "lib")
    out_rows = []
    t0 = time.time()
    with Mesen(args=[f"--mcp-lib-dir={lib}", f"--mcp-results-dir={args.out}"]) as m:
        info = m.call("load_rom", path=ROM_O)["rom"]
        m.call("pause")
        assert info["fileSha1"] == "38de0c84dd2bc3bdfc0a3d7ab0220c79b70887c3"
        for sid in ids:
            try:
                m.call("load_state_file", path=STATE)
                w = warp(m, sid)
                stride, rows, cell = make_reader(m)
                for t in types:
                    fc = first_cell(stride, rows, cell, t)
                    if fc is None:
                        out_rows.append({"scene": sid, "type": t, "cell": None})
                        continue
                    nb = free_neighbour(cell, *fc)
                    if nb is None:
                        out_rows.append({"scene": sid, "type": t, "cell": fc, "player": None})
                        continue
                    x, y = nb[0] * 16 + 8, nb[1] * 16 + 16
                    m.poke(0x1014, x)
                    m.poke(0x1016, y)
                    m.poke(0x09B2, 0)
                    m.poke(0x09B4, 0)
                    m.call("advance_frame", frames=30)
                    label = f"B1_s{sid:02X}_t{t:02X}_{fc[0]}_{fc[1]}"
                    shot = m.shot(label)
                    out_rows.append({"scene": sid, "type": t, "cell": fc, "playerCell": nb, "actorXY": [x, y],
                                     "actorAfter": [m.u16(0x1014), m.u16(0x1016)], "shot": shot.get("path"), "frame": shot.get("frame"),
                                     "sceneNow": m.u16(0x644), "warpOk": w["ok"]})
                print(f"{sid:3d} " + " ".join(f"t{r['type']:02X}@{r['cell']}->{r.get('playerCell')}" for r in out_rows if r['scene'] == sid))
            except Exception as e:
                out_rows.append({"scene": sid, "error": str(e)[:300]})
                print(f"{sid:3d} ERROR {str(e)[:200]}")
    out = os.path.join(args.out, f"B1_shots_{args.tag}_{ids[0]:03d}-{ids[-1]:03d}.json")
    with open(out, "w", encoding="utf-8") as f:
        json.dump({"rom": info, "state": STATE, "seconds": round(time.time() - t0, 1), "rows": out_rows}, f, indent=1)
    print("wrote", out, round(time.time() - t0, 1), "s")


if __name__ == "__main__":
    main()
