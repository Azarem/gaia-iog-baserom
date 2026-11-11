#!/usr/bin/env python3
"""FR21 batch 12b: FL22-09 Lily No answer: cursor starts on No; A alone = No path (324877); flag $4A stays set."""
from fr21_lib import *  # noqa: F401,F403

m, info = open_o()
REC = "{ {name='f4A',addr=0x0A09,bit=0x04},{name='mask',addr=0x065A,size=2},{name='sc',addr=0x0644,size=2} }"
try:
    every = ("function(R,n) local e=R.execs['324865']; if e and e[1]>0 then R.o=R.o or n; local k=n-R.o; "
             "if k>=40 and k<=41 then fr21.press(R,{'a'}) elseif k>60 and n%24<2 then fr21.press(R,{'a'}) end "
             "elseif n>=60 and n%24<2 then fr21.press(R,{'a'}) end end")
    r = visit(m, info, "FL22-09_talk_no2", S01R, scene=0x1A, set=[73], settle=500, teleport=[0xD8, 0x1B8], watch=True, execs=[324858, 324865, 324877, 324881, 324911],
              walk=[[5, 100, ["up"]]], hold={20: ["b"], 21: ["b"], 22: ["b"]},
              hooks="onSample=fr21.drive{ rec=" + REC + ", at={ [3]=function(R,n) fr21.item(4,0) end }, every=" + every + " }", shot="FL22-09_talk_no2")
    print(brief(r, limit=8))
finally:
    m.close()
