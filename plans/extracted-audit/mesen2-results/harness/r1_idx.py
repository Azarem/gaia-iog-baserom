#!/usr/bin/env python3
"""R1 helper: per anim index of the spriteset rows: pointer reads, frame-list reads, top legs. usage: r1_idx.py <id> [idx ...]  (read-only analysis of raw/R1_acc.json + probes)"""
import os, sys, io, contextlib, importlib.util, re
HERE = os.path.dirname(os.path.abspath(__file__))
spec = importlib.util.spec_from_file_location("r1r", os.path.join(HERE, "r1_report.py"))
m = importlib.util.module_from_spec(spec)
_argv = sys.argv; sys.argv = ["x"]
with contextlib.redirect_stdout(io.StringIO()):
    spec.loader.exec_module(m)
sys.argv = _argv
want = sys.argv[1]
idx = set(x.upper() for x in sys.argv[2:])
d = {}
for r in m.R:
    if r["id"] != want:
        continue
    mm = re.match(r"(\w+)\[(\w+)\] (ptr|list@\d+)", r["name"])
    if not mm:
        continue
    a = m.A[r["req"]]
    e = d.setdefault((mm.group(1), mm.group(2)), {})
    e[mm.group(3)[:4]] = (a["read"], r["start"], sorted(a["legs"], key=lambda k: -a["legs"][k])[:2], a["cdlFlags"])
for (s, i), e in sorted(d.items()):
    if idx and i not in idx:
        continue
    p = e.get("ptr", (0, 0, [], 0)); l = e.get("list", (0, 0, [], 0))
    print(f"{s}[{i}] ptr@{p[1]} reads {p[0]} | list@{l[1]} reads {l[0]} | {','.join(p[2]) if p[0] else '-'}")
