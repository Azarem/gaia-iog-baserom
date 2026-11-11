#!/usr/bin/env python3
"""FR21 batch 7: FL23-07 ($F8 = flag 248) in scene $2E: bed trigger without/with $F8, then the item $38 ceremony (scene $FD)."""
from fr21_lib import *  # noqa: F401,F403

m, info = open_o()
REC = "{ {name='fF8',addr=0x0A1F,bit=0x01},{name='mask',addr=0x065A,size=2},{name='sc',addr=0x0644,size=2},{name='gsi',addr=0x0AAC,size=2},{name='slot0',addr=0x0AB4},{name='slot1',addr=0x0AB5} }"
try:
    for nm, setf, bed, item, settle in (("bed_ctl", [78, 79], True, False, 400), ("bed_f248", [78, 79, 248], True, False, 400), ("ceremony", [78, 79], False, True, 4500)):
        at = "{ " + ("[3]=function(R,n) fr21.pos(184,88) end, " if bed else "") + ("[3]=function(R,n) fr21.item(0x38,0) end" if item else "") + " }"
        r = visit(m, info, f"FL23-07_{nm}", S01R, scene=0x2E, set=setf, settle=settle, watch=True,
                  mash=({"button": "b", "from": 100, "to": settle - 50, "down": 2, "gap": 8} if item else None) or {"button": "b", "from": 399, "to": 399, "down": 1, "gap": 1},
                  hooks=f"onSample=fr21.drive{{ rec={REC}, at={at} }}", shot=f"FL23-07_{nm}")
        print(brief(r, limit=14))
        print("   scenes:", [(s["n"], hex(s["from"]), hex(s["to"]), hex(s["mask"])) for s in r["scenes"]][:10], "mask0", hex(r["mask0"]))
finally:
    m.close()
