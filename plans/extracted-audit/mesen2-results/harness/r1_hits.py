#!/usr/bin/env python3
"""R1 static helper: classify ROM offsets (hits of r1_static.py) by the blocks.json part that contains them. Read-only."""
import json, os, sys
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "..", ".."))
B = json.load(open(os.path.join(REPO, "db-us", "blocks.json"), encoding="utf-8"))
F = json.load(open(os.path.join(REPO, "db-us", "files.json"), encoding="utf-8")) if os.path.exists(os.path.join(REPO, "db-us", "files.json")) else {}
items = []
def walk(o, path):
    if isinstance(o, dict):
        if "start" in o and "end" in o and isinstance(o["start"], int):
            items.append((o["start"], o["end"], "/".join(path), o.get("type")))
        else:
            for k, v in o.items():
                walk(v, path + [str(k)])
walk(B, ["blocks"])
walk(F, ["files"])
def cls(off):
    # smallest containing item first (a part inside its block); end of blocks.json is exclusive, of files.json inclusive in practice
    c = [(e - st, f"{n} [{t}] {st}..{e}") for st, e, n, t in items if st <= off < e]
    return [x[1] for x in sorted(c)][:3] or ["(no block/part/file)"]
for a in sys.argv[1:]:
    print(a, cls(int(a)))
