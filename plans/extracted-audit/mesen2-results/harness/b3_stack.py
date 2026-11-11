#!/usr/bin/env python3
"""OQ-I029-2 analysis (read-only): for every hooked routine event with full columns, which stack word (S+1, S+3, S+5, S+6) equals
the $24 value PlayerMovementTick parked in the same tick? Only ticks with a nonzero incoming $24 count.

usage: b3_stack.py raw/B3/diag_O_<date>.json [--case SUBSTR]
Event layout (full): n name A X Y SP w1 w3 w5 d1A d1E d24 sEw sNs P w6 ...
"""
import argparse
import json
from collections import defaultdict


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("file")
    ap.add_argument("--case", default="")
    a = ap.parse_args()
    d = json.load(open(a.file, encoding="utf-8"))
    tally = defaultdict(lambda: defaultdict(int))
    for c in d["cases"]:
        if a.case not in c["case"]["name"]:
            continue
        cur = None
        for e in c["result"]["events"]:
            if len(e) == 6:
                continue
            name = e[1]
            if name == "PlayerMovementTick":
                cur = e[11]  # d24 at tick entry = the word that is parked with PHA
                continue
            if len(e) <= 14 or cur is None:
                continue
            sp, w1, w3, w5, w6 = e[5], e[6], e[7], e[8], e[15]
            key = name
            tally[key]["events"] += 1
            if cur != 0:
                tally[key]["events_with_nonzero_parked"] += 1
                for lab, w in (("S+1", w1), ("S+3", w3), ("S+5", w5), ("S+6", w6)):
                    if (w & 0xFFFF) == (cur & 0xFFFF):
                        tally[key][lab] += 1
            else:
                tally[key]["parked_zero"] += 1
    for k, v in sorted(tally.items()):
        print(k, dict(v))


if __name__ == "__main__":
    main()
