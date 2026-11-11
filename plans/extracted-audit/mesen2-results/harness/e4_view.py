#!/usr/bin/env python3
"""E4 viewer: compact text of raw/E4_sample_<name>.json (harness only; reads the capture, writes nothing)."""
import json
import re
import sys

RAW = "../raw/"


def rows(name):
    d = json.load(open(RAW + f"E4_sample_{name}.json"))
    return d["result"]["lines"], d


def compact(l, keep_lines=True, w=400):
    out = []
    for x in l.split("\n"):
        x = re.sub(r"\| last write seen:.*?\| \$66", "| $66", x)
        x = re.sub(r"tbl16=([0-9A-F ]{14})[0-9A-F ]*", r"tbl16=\1", x)
        out.append(x[:w])
    return "\n".join(out)


if __name__ == "__main__":
    name = sys.argv[1]
    sel = sys.argv[2:] or None
    lines, d = rows(name)
    for l in lines:
        if sel and not any(l.startswith(s) for s in sel):
            continue
        print(compact(l))
