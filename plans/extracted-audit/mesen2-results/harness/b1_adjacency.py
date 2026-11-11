#!/usr/bin/env python3
"""B1 adjacency census (OQ-I032-4, OQ-I030-3): for every valid scene with `$05` or `$0A`, read the whole collision layer and count which
low-nibble types sit north / south / east / west of every `$05`, `$0A`, `$06` and `$09` cell.

Per scene: load S01r, quick warp (scenario_b1_census.warp), read WRAM 0x1C000 (stride x rows x 256 bytes) with read_memory.
Writes raw/B1_adjacency_O.json: {"scenes": {id: {"05": {"N": {type: n}, ...}, ...}}, "total": {...}}.

usage: b1_adjacency.py [--scenes 21,133]   (default: every valid scene of raw/B1_census_merged.json with `$05` or `$0A`)
"""
import argparse
import collections
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from mcp_client import Mesen  # noqa: E402
from scenario_b1_census import ROM_O, STATE, warp, RESULTS  # noqa: E402
from scenario_b1_shots import make_reader  # noqa: E402

DIRS = {"N": (0, -1), "S": (0, 1), "E": (1, 0), "W": (-1, 0)}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--scenes", default="")
    args = ap.parse_args()
    raw = os.path.join(RESULTS, "raw")
    merged = json.load(open(os.path.join(raw, "B1_census_merged.json"), encoding="utf-8"))
    if args.scenes:
        ids = [int(x) for x in args.scenes.split(",")]
    else:
        ids = sorted(int(k) for k, r in merged.items() if r["census"] == "ok" and (r["low"][5] or r["low"][10]))
    per = {}
    total = {t: {d: collections.Counter() for d in DIRS} for t in ("05", "0A", "06", "09")}
    lib = os.path.join(RESULTS, "kit", "lib")
    with Mesen(args=[f"--mcp-lib-dir={lib}", f"--mcp-results-dir={raw}"]) as m:
        assert m.call("load_rom", path=ROM_O)["rom"]["fileSha1"] == "38de0c84dd2bc3bdfc0a3d7ab0220c79b70887c3"
        m.call("pause")
        for sid in ids:
            m.call("load_state_file", path=STATE)
            warp(m, sid)
            stride, rows, cell = make_reader(m)
            acc = {t: {d: collections.Counter() for d in DIRS} for t in total}
            for ty in range(rows * 16):
                for tx in range(stride * 16):
                    v = cell(tx, ty)
                    t = None if v is None else f"{v & 15:02X}"
                    if t not in acc:
                        continue
                    for d, (dx, dy) in DIRS.items():
                        n = cell(tx + dx, ty + dy)
                        acc[t][d]["edge" if n is None else f"{n & 15:02X}"] += 1
            per[f"{sid:02X}"] = {t: {d: dict(c) for d, c in acc[t].items()} for t in acc}
            for t in acc:
                for d in DIRS:
                    total[t][d].update(acc[t][d])
            print(f"{sid:3d} 05={sum(acc['05']['N'].values())} 0A={sum(acc['0A']['N'].values())} 06={sum(acc['06']['N'].values())} 09={sum(acc['09']['N'].values())}")
    out = {"scenes": per, "total": {t: {d: dict(c) for d, c in total[t].items()} for t in total}}
    p = os.path.join(raw, "B1_adjacency_O.json")
    with open(p, "w", encoding="utf-8") as f:
        json.dump(out, f, indent=1)
    print("wrote", p)
    for t in total:
        n = sum(total[t]["N"].values())
        print(f"${t} cells {n}")
        for d in DIRS:
            print("   ", d, dict(total[t][d].most_common(6)))


if __name__ == "__main__":
    main()
