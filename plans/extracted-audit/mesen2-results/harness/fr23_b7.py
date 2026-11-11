#!/usr/bin/env python3
"""FR23 batch 7: FL27-04 ($9D = byte $0A13 bit 5, scene $78): which wa78_men instance dies. Control vs forced ($9D set before the load, $8D $91 set so the intro is skipped);
lists every wa78_men actor with position and field $24 (spawn parameter)."""
import json
import sys
from fr23_lib import *  # noqa: F401,F403

which = sys.argv[1:] or ["M"]


def men(r, key):
    out = []
    for a in L.actor_names(r.get(key)):
        if a["file"] == "wa78_men":
            raw = a.get("raw") or ""
            out.append((a["x"], a["y"], int(raw[0x24 * 2:0x24 * 2 + 2], 16) if raw else None, a["line"]))
    return sorted(out)


m, info = open_o()
try:
    if "M" in which:
        for nm, st in (("ctl", [141, 145]), ("f9D", [141, 145, 157])):
            hooks = "onSample=fr22.drive{ rec={ {name='f9D',addr=0x0A13,bit=0x20},{name='mask',addr=0x065A,size=2} }, snaps={30,200}, adv=false }"
            r = visit(m, info, f"FL27-04_M_{nm}", S01R, scene=0x78, set=st, settle=240, watch=False, hooks=hooks, shot=f"FL27-04_{nm}", frames=700)
            print(nm, summarize(r).split(chr(10))[0][:160])
            print("   actors0 files:", dict(count_files(r, "actors0")).get("wa78_men"), "men actors0 (x,y,$24,line):", men(r, "actors0"))
            print("   men actors1:", men(r, "actors1"))
            print("   rec", json.dumps(r.get("rec"), separators=(",", ":"))[:300])
finally:
    m.close()
