#!/usr/bin/env python3
"""FR21 batch 10: FL22-08 ($44 = flag 68) the Elder in scene $15: talk with item $04 (control) and item $03 (forced), $41 and $47 set."""
from fr21_lib import *  # noqa: F401,F403

m, info = open_o()
REC = "{ {name='f44',addr=0x0A08,bit=0x10},{name='f41',addr=0x0A08,bit=0x02},{name='f47',addr=0x0A05,bit=0x80},{name='mask',addr=0x065A,size=2},{name='slot0',addr=0x0AB4} }"
# Elder at (168,384), handler code_04E97A = 321914; item $04 branch 322012; item $03 branch 322017; set $44 = 322043
EX = [321914, 322012, 322017, 322021, 322033, 322039, 322043]
try:
    for nm, item, x, y, hold, DOWNS in (("item03_yes0b", 3, 168, 408, "up", 0),):
        at = "{ [3]=function(R,n) fr21.item(%d,0) end }" % item
        every = ("function(R,n) local e=R.execs['322021']; "
                 "if e and e[1]>0 then R.o=R.o or n; local k=n-R.o; "
                 "if k==20 and %d==1 then fr21.press(R,{'down'}) elseif k>=21 and k<=22 and %d==1 then fr21.press(R,{'down'}) "
                 "elseif k>=40 and k<=41 then fr21.press(R,{'a'}) elseif k>41 and n%%24<2 then fr21.press(R,{'a'}) end "
                 "elseif n>=120 and n%%24<2 then fr21.press(R,{'a'}) end end") % (DOWNS, DOWNS)
        r = visit(m, info, f"FL22-08_{nm}", S01R, scene=0x15, set=[65, 71], settle=1300, teleport=[x, y], watch=True, execs=EX,
                  walk=[[5, 110, [hold]]], hold={20: ["b"], 21: ["b"]},
                  hooks="onSample=fr21.drive{ rec=" + REC + ", at=" + at + ", every=" + every.replace("%%", "%") + " }", shot=f"FL22-08_{nm}")
        print(brief(r, keys=("f44", "mask", "slot0"), limit=8))
finally:
    m.close()
