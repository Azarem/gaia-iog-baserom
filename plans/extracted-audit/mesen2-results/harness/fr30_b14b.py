#!/usr/bin/env python3
"""FR30 batch 14b: collision map around the scene $60 flag-only chest (1E,18) to find a reachable tile below it."""
import json
from fr30_lib import *  # noqa: F401,F403
m, info = open_o()
try:
    hooks = ("final=function(R) R.r=fr30.rect(26,20,10,10,0) end")
    r = visit(m, info, "c60_collmap", S01R, scene=96, settle=20, watch=False, hooks=hooks)
    print("map rows y=20..29, x=26..35")
    for a, b in zip(r["r"]["map"].split("/"), r["r"]["col"].split("/")):
        print(a, "|", b)
finally:
    m.close()
