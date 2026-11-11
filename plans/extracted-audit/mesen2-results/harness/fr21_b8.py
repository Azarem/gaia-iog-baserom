#!/usr/bin/env python3
"""FR21 batch 8: FL22-03 ($26 = flag 38) in scene $15: actors, mask at scene start, scratch $01 during the camera pan, dialog screenshot."""
from fr21_lib import *  # noqa: F401,F403
from collections import Counter

m, info = open_o()
REC = "{ {name='s01',addr=0x0A00,bit=0x02},{name='mask',addr=0x065A,size=2},{name='f26',addr=0x0A04,bit=0x40},{name='f2B',addr=0x0A05,bit=0x08},{name='cx',addr=0x0E26,size=2} }"
KEEP = ("it15_lily", "it15_kara", "it15_elder", "it15_lola", "it15_bill")
try:
    for nm, setf, frames, shot in (("ctl", [], 700, "FL22-03_ctl"), ("f26", [38], 700, "FL22-03_f26"), ("f26_early", [38], 120, "FL22-03_f26_early")):
        r = visit(m, info, f"FL22-03_{nm}", S01R, scene=0x15, set=setf, settle=frames, watch=True,
                  mash={"button": "b", "from": 200, "to": frames - 20, "down": 2, "gap": 14} if frames > 200 else None or {"button": "b", "from": 999, "to": 999},
                  hooks=f"onSample=fr21.drive{{ rec={REC} }}", shot=shot)
        print(brief(r, keys=("s01", "mask", "f26", "f2B"), limit=14))
        print("   actors0:", [(x["file"], x["x"], x["y"], hex(x["f10"])) for x in r["actors0_named"] if x["file"] in KEEP], "mask0", hex(r["mask0"]))
        print("   actors1:", [(x["file"], x["x"], x["y"], hex(x["f10"])) for x in r["actors1_named"] if x["file"] in KEEP])
finally:
    m.close()
