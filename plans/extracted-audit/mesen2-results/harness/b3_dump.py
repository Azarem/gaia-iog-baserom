#!/usr/bin/env python3
"""Print events of a B3 raw file (raw/B3/<suite>_<tag>_<date>.json), read-only.

usage: b3_dump.py FILE CASE_SUBSTR [--names A,B] [--first N] [--frames A-B] [--hex]
Columns (compact): n name A X Y SP w1 w3 w5 d1A d1E d24 sEw sNs; full adds P w6 d20 d22 d26 c9B6 c9B8 c9C6 f9AE ax ay aa ab d00 d02.
"""
import argparse
import json

COMPACT = ["n", "name", "A", "X", "Y", "SP", "w1", "w3", "w5", "d1A", "d1E", "d24", "sEw", "sNs"]
FULL = COMPACT + ["P", "w6", "d20", "d22", "d26", "c9B6", "c9B8", "c9C6", "f9AE", "ax", "ay", "aa", "ab", "d00", "d02", "pX", "pY"]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("file")
    ap.add_argument("case")
    ap.add_argument("--names", default=None)
    ap.add_argument("--first", type=int, default=40)
    ap.add_argument("--frames", default=None)
    ap.add_argument("--hex", action="store_true")
    a = ap.parse_args()
    d = json.load(open(a.file, encoding="utf-8"))
    want = set(a.names.split(",")) if a.names else None
    lo, hi = (0, 10 ** 9)
    if a.frames:
        lo, hi = (int(x) for x in a.frames.split("-"))
    for c in d["cases"]:
        if a.case not in c["case"]["name"]:
            continue
        print("==", c["case"]["name"])
        shown = 0
        for e in c["result"]["events"]:
            if want and e[1] not in want:
                continue
            if not (lo <= e[0] <= hi):
                continue
            cols = FULL if len(e) > len(COMPACT) else COMPACT
            if len(e) == 6 and e[1] not in ("x",):  # watch rows: n name addr val k pc
                pass
            if len(e) == 6:
                print(f"  n={e[0]:3d} {e[1]:14s} addr={e[2]:04X} val={e[3]:04X} k={e[4]:02X} pc={e[5]:04X}")
            else:
                parts = []
                for k, v in zip(cols, e):
                    if k in ("n", "name"):
                        continue
                    parts.append(f"{k}={v:04X}" if (a.hex and isinstance(v, int)) else f"{k}={v}")
                print(f"  n={e[0]:3d} {e[1]:22s} " + " ".join(parts))
            shown += 1
            if shown >= a.first:
                break


if __name__ == "__main__":
    main()
