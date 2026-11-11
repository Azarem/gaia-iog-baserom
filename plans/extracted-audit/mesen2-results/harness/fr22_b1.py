#!/usr/bin/env python3
"""FR22 batch 1: FL25-01 probe: scene $63 default spawn, tile and prayer-room actor entry."""
import json
from fr22_lib import *  # noqa: F401,F403
from collections import Counter

m, info = open_o()
try:
    r = visit(m, info, "probe_s63", S01R, scene=0x63, settle=60, watch=False, tag="probe_s63",
              hooks="onSample=function(R,n) if n==30 then R.tile={fr21.tile()} end end", shot="probe_s63")
    print(summarize(r))
    print("tile", r.get("tile"), "p09A2", r.get("p09A2"), "pos", r.get("pos"))
    for a in r["actors1_named"]:
        print("  actor", a["slot"], a["file"], a["line"], a["x"], a["y"], "pc %04X" % (a["off"] & 0xFFFF), "raw pc", hex(a["off"]))
finally:
    m.close()
