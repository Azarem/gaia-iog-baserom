#!/usr/bin/env python3
"""FR40 natural-entry check: every scene entered with each distinct destination of the scene-warp table rows that lead into it
(full warp: warpDestX/Y, facing, scroll), no flags, from S01r. Variant names n0, n1, ... Companion of step (a), which uses the
quick-warp position (warpDestX/Y left over from the earlier warp).

usage: fr40_n.py [ids ...]      (default: every scene with at least one incoming scene-warp row)
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import fr40  # noqa: E402
from mcp_client import ScriptRunError  # noqa: E402


def main():
    with open(fr40.WARP_DEST, encoding="utf-8") as f:
        wd = json.load(f)
    ids = [int(a, 0) for a in sys.argv[1:]] or sorted(int(k) for k in wd)
    m, info = fr40.open_o()
    try:
        for sid in ids:
            cands = []
            for c in wd.get(str(sid), []):
                t = (c["x"], c["y"], c["face"], c["scroll"])
                if t not in cands:
                    cands.append(t)
            for i, t in enumerate(cands):
                try:
                    r = fr40.trial(m, info, sid, f"n{i}", [], dest=t, shot=False)
                except ScriptRunError as e:
                    print(f"s{sid:02X} n{i} SCRIPT ERROR {e}", flush=True)
                    raise
                print(fr40.brief(r), "dest", t, flush=True)
    finally:
        m.close()


if __name__ == "__main__":
    main()
