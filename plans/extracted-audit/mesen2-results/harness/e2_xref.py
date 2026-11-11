#!/usr/bin/env python3
"""E2 static cross-reference: every place in extracted/ that names a palette bundle id (PaletteStart / PaletteStartLoop operand,
SpawnThinkerParam operand for the palette reset thinker, ambient_palette_cycler / palette thinker spawn records).
Writes raw/E2_xref.json ({id: [{file, line, text}]}) and prints the ids with no reference. Read-only on extracted/."""
import collections
import json
import os
import re

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, "..", "..", "..", ".."))
RAW = os.path.join(HERE, "..", "raw")

PAT = [
    re.compile(r"COP \[(PaletteStart|PaletteStartLoop)\]\s*\(\s*#([0-9A-Fa-f]{1,2})\b"),
    re.compile(r"COP \[SpawnThinkerParam\]\s*\(\s*#([0-9A-Fa-f]{1,2}),\s*@?([\w\.]+)"),
    re.compile(r"thinker-spawn\s*<\s*#([0-9A-Fa-f]{1,2}),\s*@(\w+)"),
]
refs = collections.defaultdict(list)
for root, _, files in os.walk(os.path.join(REPO, "extracted")):
    for fn in files:
        if not fn.endswith(".asm"):
            continue
        p = os.path.join(root, fn)
        for i, line in enumerate(open(p, encoding="utf-8", errors="replace"), 1):
            if line.lstrip().startswith(";"):
                continue
            m = PAT[0].search(line)
            if m:
                refs[int(m.group(2), 16)].append(dict(file=os.path.relpath(p, REPO), line=i, kind=m.group(1), text=line.strip()[:120]))
                continue
            m = PAT[1].search(line)
            if m and "Palette" in m.group(2):
                refs[int(m.group(1), 16)].append(dict(file=os.path.relpath(p, REPO), line=i, kind="SpawnThinkerParam", text=line.strip()[:120]))
                continue
            m = PAT[2].search(line)
            if m and ("palette" in m.group(2).lower() or "gold_ship_wreck" in m.group(2)):
                refs[int(m.group(1), 16)].append(dict(file=os.path.relpath(p, REPO), line=i, kind="spawn-record:" + m.group(2), text=line.strip()[:120]))
json.dump({f"{k:02X}": v for k, v in sorted(refs.items())}, open(os.path.join(RAW, "E2_xref.json"), "w"), indent=0)
none = [i for i in range(128) if i not in refs]
print("ids with a reference:", len(refs), " without:", len(none))
print(" ".join(f"{i:02X}" for i in none))
