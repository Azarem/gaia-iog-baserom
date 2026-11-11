#!/usr/bin/env python3
"""Print a window of the collision layer of a scene (hex bytes, low nibble | high nibble kept: the whole byte) after the B1 quick warp.

usage: b1_window.py SCENE TX0 TY0 W H      e.g.  b1_window.py 21 60 10 20 16
Cells are printed one hex byte each ('.' for $00); the row header is ty.
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from mcp_client import Mesen  # noqa: E402
from scenario_b1_census import ROM_O, STATE, warp, RESULTS  # noqa: E402
from scenario_b1_shots import make_reader  # noqa: E402


def main():
    sid, tx0, ty0, w, h = (int(x) for x in sys.argv[1:6])
    lib = os.path.join(RESULTS, "kit", "lib")
    with Mesen(args=[f"--mcp-lib-dir={lib}", f"--mcp-results-dir={os.path.join(RESULTS, 'raw')}"]) as m:
        m.call("load_rom", path=ROM_O)
        m.call("pause")
        m.call("load_state_file", path=STATE)
        print("warp", warp(m, sid))
        stride, rows, cell = make_reader(m)
        print(f"scene {sid} stride {stride} rows {rows}; columns {tx0}..{tx0 + w - 1}")
        print("      " + "".join(f"{(tx0 + i) % 100:3d}" for i in range(w)))
        for ty in range(ty0, ty0 + h):
            line = []
            for tx in range(tx0, tx0 + w):
                v = cell(tx, ty)
                line.append("  ." if v == 0 else (" --" if v is None else f" {v:02X}"))
            print(f"{ty:4d}: " + "".join(line))


if __name__ == "__main__":
    main()
