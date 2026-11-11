#!/usr/bin/env python3
"""FR21 batch 9: FL22-07 ($40 = flag 64): Lola's Melody (item $09) in scene $15 with $26 set: first use ($40 clear) and second use ($40 set)."""
from fr21_lib import *  # noqa: F401,F403

m, info = open_o()
REC = "{ {name='f40',addr=0x0A08,bit=0x01},{name='s01',addr=0x0A00,bit=0x02},{name='s0E',addr=0x0A01,bit=0x40},{name='mask',addr=0x065A,size=2},{name='slot0',addr=0x0AB4},{name='dmf',addr=0x09EC,size=2,bit=0x0080} }"
try:
    for nm, setf, st, rep in (("first2", [38], 4200, ""), ("second2", [38, 64], 1500, ", repeatEvery=45")):
        r = visit(m, info, f"FL22-07_{nm}", S01R, scene=0x15, set=setf, settle=st, watch=True, cgram=True, execs=[232527, 232491, 232552, 232560, 232445],
                  hooks="onSample=fr21.drive{ rec=" + REC + ", every=fr21.auto{ item=9, anymask=true, minN=250, free=30" + rep + " } }", shot=f"FL22-07_{nm}")
        print(brief(r, keys=("f40", "s01", "s0E", "mask", "slot0", "dmf"), limit=24), "used", r.get("used"))
        c1, c2 = r.get("cgram1"), r.get(f"cgram{750}")
        print("   cgram n=1 vs mid differing palettes:", [i for i in range(16) if c1 and c2 and c1[i] != c2[i]])
finally:
    m.close()
