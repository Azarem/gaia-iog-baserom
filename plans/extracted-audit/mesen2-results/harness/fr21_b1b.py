#!/usr/bin/env python3
"""FR21 batch 1b: FL22-01 NPC talk in scene $18 with $2E clear (control) and set (forced); calibration of the talk bot."""
from fr21_lib import *  # noqa: F401,F403

m, info = open_o()
REC = "{ {name='mask',addr=0x065A,size=2},{name='dmf',addr=0x09EC,size=2},{name='tx',addr=0x09A6,size=2},{name='ty',addr=0x09A8,size=2},{name='px',addr=0x1014,size=2},{name='py',addr=0x1016,size=2} }"
try:
    for nm, setf in (("ctl_clear", []), ("forced_set", [46])):
        r = visit(m, info, f"FL22-01_talkMan_{nm}", S01R, scene=0x18, set=setf, settle=90, watch=True,
                  walk=[[1, 60, ["right"]]], mash={"button": "a", "from": 25, "to": 45, "down": 2, "gap": 6},
                  hooks=f"onSample=fr21.drive{{ rec={REC} }}", shot=f"FL22-01_talkMan_{nm}")
        print(summarize(r))
        print(show_rec(r, 30))
finally:
    m.close()
