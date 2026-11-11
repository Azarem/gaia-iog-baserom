#!/usr/bin/env python3
"""FR21 batch 12: FL22-09 ($4A = flag 74): Lily in scene $1A (talk with item $04, answer), Itory exit menu in scene $15 with $4A clear/set, Lily on re-entry."""
from fr21_lib import *  # noqa: F401,F403

m, info = open_o()
REC = "{ {name='f4A',addr=0x0A09,bit=0x04},{name='mask',addr=0x065A,size=2},{name='sc',addr=0x0644,size=2},{name='m58',addr=0x0D58,size=2} }"
EX = [324858, 324877, 324881, 324911, 324848]
try:
    # Lily talk: Lily at tile (0D,1A); stand south of her at tile (0D,1B): px=0x0D*16+8, py=0x1B*16+24, hold up, B opens the talk, then A at the question (default / down)
    for nm, down in (("talk_no", 1),):
        every = ("function(R,n) local e=R.execs['324865']; "
                 "if e and e[1]>0 then R.o=R.o or n; local k=n-R.o; "
                 "if %d==1 and k>=20 and k<=22 then fr21.press(R,{'down'}) end; "
                 "if k>=40 and k<=42 then fr21.press(R,{'a'}) elseif k>42 and n%%24<2 then fr21.press(R,{'a'}) end "
                 "elseif n>=60 and n%%24<2 then fr21.press(R,{'a'}) end end") % down
        r = visit(m, info, f"FL22-09_{nm}", S01R, scene=0x1A, set=[73], settle=1300, teleport=[0xD8, 0x1B8], watch=True, execs=EX + [324865],
                  walk=[[5, 100, ["up"]]], hold={20: ["b"], 21: ["b"], 22: ["b"]},
                  hooks="onSample=fr21.drive{ rec=" + REC + ", at={ [3]=function(R,n) fr21.item(4,0) end }, every=" + every.replace("%%", "%") + " }", shot=f"FL22-09_{nm}")
        print(brief(r, keys=("f4A", "mask", "sc", "m58"), limit=10))
finally:
    m.close()
