#!/usr/bin/env python3
"""FR21 batch 2: FL22-04 (flag $2F, Blue Block item $07 in scene $25 on tile (0E,19)); dialog is dismissed with physical B."""
from fr21_lib import *  # noqa: F401,F403

m, info = open_o()
REC = "{ {name='f2F',addr=0x0A05,bit=0x80},{name='mask',addr=0x065A,size=2},{name='dmf',addr=0x09EC,size=2},{name='tx',addr=0x09A6,size=2},{name='ty',addr=0x09A8,size=2},{name='inv',addr=0x0AB4},{name='snd',addr=0x0DB8,size=2} }"
CELLS = [[14, 25], [15, 25], [14, 26], [15, 26], [14, 24], [14, 27]]
SNAP = "function(R,n) R.snap=R.snap or {}; R.snap[tostring(n)]=fr20.actors() end"
try:
    for nm, tp, use, setf in (("forced_use_x0E", [232, 424], True, []), ("forced_use_x0F", [248, 424], True, []), ("forced_use_y1A", [232, 440], True, [])):
        at = f"{{ [4]=function(R,n) fr21.item(7,0) end, [100]={SNAP}, [300]={SNAP}, [690]={SNAP} }}"
        r = visit(m, info, f"FL22-04_{nm}", S01R, scene=0x25, set=setf, settle=700, teleport=tp, watch=True, cells=CELLS, execs=[231800],
                  hold={6: ["y"], 7: ["y"], 8: ["y"]}, mash={"button": "b", "from": 60, "to": 120, "down": 2, "gap": 20},
                  hooks=f"onSample=fr21.drive{{ rec={REC}, at={at} }}", shot=f"FL22-04_{nm}")
        print(summarize(r))
        print("   cells0", r["cells0"], "cells1", r["cells1"], "execs", r["execs"])
        print(show_rec(r, 25))
        for k, v in sorted(r.get("snap", {}).items(), key=lambda kv: int(kv[0])):
            print("   snap", k, [(a["x"], a["y"], a["wait"], a["f10"]) for a in v if "25" in actor_names([a])[0] or True][:0], [x for x in actor_names(v) if "ir25" in x])
finally:
    m.close()
