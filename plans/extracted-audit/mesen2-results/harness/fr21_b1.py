#!/usr/bin/env python3
"""FR21 batch 1: FL22-01 (flag $2E, UseItem_IncanMelody in scene $18 versus scene $15)."""
import json
from fr21_lib import *  # noqa: F401,F403

m, info = open_o()
REC = "{ {name='f2E',addr=0x0A05,bit=0x40},{name='mask',addr=0x065A,size=2},{name='sc',addr=0x0644,size=2},{name='dmf',addr=0x09EC,size=2},{name='eq',addr=0x0AC4,size=2},{name='slot0',addr=0x0AB4} }"
try:
    for nm, sc in (("ctl_s15", 0x15), ("forced_s18", 0x18)):
        hooks = f"onSample=fr21.drive{{ rec={REC}, at={{ [5]=function(R,n) fr21.item(5,0); R.inv0=fr21.inv() end }} }}"
        r = visit(m, info, f"FL22-01_{nm}", S01R, scene=sc, settle=420, watch=True, execs=[231453, 231465, 231473],
                  hold={10: ["y"], 11: ["y"], 12: ["y"]}, mash={"button": "a", "from": 40, "to": 400, "down": 2, "gap": 12},
                  hooks=hooks, shot=f"FL22-01_{nm}")
        print(summarize(r))
        print("   inv0", r.get("inv0"), "execs", r.get("execs"))
        print(show_rec(r))
finally:
    m.close()
