#!/usr/bin/env python3
"""W1-b census (ROM O): static census and merged report for the batch "Scene and flags".

usage: w1b_report.py --static [--out raw/W1b_static.md]
       w1b_report.py [--date yyyymmdd] [--out raw/W1b_report.md]

Reads (read-only): extracted/**/*.asm (the `; {n}` line tags and the `!name hex` RAM definitions), db-us/names/bank*.json (labels),
raw/W1b_*_<date>.json (session results). Writes raw/W1b_static.md / raw/W1b_report.md and raw/W1b_merged.json only.
Reuses the loaders of w1a_report.py (same tag / name / PC-mapping rules: a callback reports the PC AFTER the accessing instruction, the
instruction ENDS there).
"""
import argparse
import glob
import json
import os
import re
import sys
import time
from collections import defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import w1a_report as R  # noqa: E402

RAW = R.RAW

WATCH_RANGES = {
    "06A0": (0x06A0, 0x06A1),
    "06C6-06C7": (0x06C6, 0x06C7),
    "06C8": (0x06C8, 0x06C9),
    "06CA-06CB": (0x06CA, 0x06CB),
    "06EE-06EF": (0x06EE, 0x06EF),
    "06EF bit4(0x10)": (0x06EF, 0x06EF),
    "06F0": (0x06F0, 0x06F1),
    "06F2": (0x06F2, 0x06F3),
    "0402-0405": (0x0402, 0x0405),
    "0D6E-0D6F": (0x0D6E, 0x0D6F),
    "09CC-09CF": (0x09CC, 0x09CF),
    "06CC-06CD": (0x06CC, 0x06CD),
    "0A1F flag FF bit7": (0x0A1F, 0x0A1F),
    "7F0600-06FF": (0x10600, 0x106FF),
    "00DA": (0x00DA, 0x00DB),
}
STATIC_NAMES = ["06A0", "06C6-06C7", "06C8", "06CA-06CB", "06CC-06CD", "06EE-06EF", "06F0", "06F2", "0402-0405", "0D6E-0D6F", "09CC-09CF", "0A1F flag FF bit7", "00DA"]
R.WATCH_RANGES = WATCH_RANGES

STORES = {"STA", "STX", "STY", "STZ"}
RMW = {"TSB", "TRB", "INC", "DEC", "ASL", "LSR", "ROL", "ROR"}


def wram_static(tag, wname):
    """7F0600 is a long address: operand $7F06xx names it."""
    return False


def static_table(tags, tag_keys, names, nkeys, rt=None):
    L, rows = [], []
    for wname in STATIC_NAMES:
        L.append(f"### {wname}\n")
        L.append("| offset | file:line | instruction | routine | access | runtime hits (all sessions) |")
        L.append("|---|---|---|---|---|---|")
        for off in tag_keys:
            t = tags[off]
            if not R.static_hit(t, wname):
                continue
            mn = t["text"].split(None, 1)[0].upper() if t["text"] else ""
            acc = "write" if mn in STORES else ("read+write" if mn in RMW and len(t["text"].split()) > 1 else "read")
            n = (rt or {}).get((wname, off), "")
            L.append(f"| {off} | {t['file']}:{t['line']} | {t['text']} | {R.routine(names, nkeys, off)} | {acc} | {n} |")
            rows.append(dict(watch=wname, off=off, where=f"{t['file']}:{t['line']}", text=t["text"], routine=R.routine(names, nkeys, off), access=acc, runtime=n))
        L.append("")
    return L, rows


def static_main(out):
    tags = R.load_tags()
    tag_keys = sorted(tags)
    names, nkeys = R.load_names()
    L = ["# W1-b static census (operand names a watched address; from extracted/ tags)\n"]
    t, rows = static_table(tags, tag_keys, names, nkeys)
    L += t
    # JSR $0402 (the stub is executed, not read)
    L.append("### JSR $0402 / JSL callers of the RAM stub (exec, not a data read)\n")
    L.append("| offset | file:line | instruction | routine |")
    L.append("|---|---|---|---|")
    for off in tag_keys:
        tg = tags[off]
        if re.match(r"JSR\s+\$0402\b", tg["text"]):
            L.append(f"| {off} | {tg['file']}:{tg['line']} | {tg['text']} | {R.routine(names, nkeys, off)} |")
    L.append("")
    with open(out, "w", encoding="utf-8") as f:
        f.write("\n".join(L) + "\n")
    with open(os.path.join(RAW, "W1b_static.json"), "w", encoding="utf-8") as f:
        json.dump(rows, f, indent=1)
    print("wrote", out, len(rows), "static rows")


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--static", action="store_true")
    ap.add_argument("--out", default=None)
    ap.add_argument("--date", default=None)
    a = ap.parse_args()
    if a.static:
        static_main(a.out or os.path.join(RAW, "W1b_static.md"))
    else:
        import w1b_merge
        w1b_merge.main(a)
