#!/usr/bin/env python3
"""FR21 batch 7b: FL23-07 bed trigger with $F8 set: answer the prompt with physical B presses, watch for scene $2A."""
from fr21_lib import *  # noqa: F401,F403

m, info = open_o()
REC = "{ {name='fF8',addr=0x0A1F,bit=0x01},{name='mask',addr=0x065A,size=2},{name='sc',addr=0x0644,size=2},{name='dmf',addr=0x09EC,size=2} }"
try:
    for nm, setf in (("bed_f248_b", [78, 79, 248]), ("bed_ctl_b", [78, 79])):
        r = visit(m, info, f"FL23-07_{nm}", S01R, scene=0x2E, set=setf, settle=1500, watch=True, execs=[362085],
                  mash={"button": "b", "from": 60, "to": 1400, "down": 2, "gap": 14},
                  hooks=f"onSample=fr21.drive{{ rec={REC}, at={{ [3]=function(R,n) fr21.pos(184,88) end }} }}", shot=f"FL23-07_{nm}")
        print(brief(r, keys=("fF8", "mask", "sc"), limit=14))
        print("   scenes:", [(s["n"], hex(s["from"]), hex(s["to"]), hex(s["mask"])) for s in r["scenes"]][:10])
finally:
    m.close()
