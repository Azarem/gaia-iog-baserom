#!/usr/bin/env python3
"""FR21 batch 5: FL23-10 ($67 = flag 103, door voice at the Freejia cell, scene $32): talk with $66 clear and set; attack; collision cells; reload."""
from fr21_lib import *  # noqa: F401,F403

m, info = open_o()
REC = "{ {name='f66',addr=0x0A0C,bit=0x40},{name='f67',addr=0x0A0C,bit=0x80},{name='mask',addr=0x065A,size=2},{name='pf',addr=0x09AE,size=2},{name='dmf',addr=0x09EC,size=2} }"
CELLS = [[4, 13], [4, 12], [8, 14], [8, 15], [8, 16], [8, 17], [5, 13]]
EVERY = ("function(R,n) local d=fr21.find(0xB3A1,0xB420); if d then R.door=R.door or {}; local h=fr21.hp(d.slot); "
         "if n>=700 and n%12<2 then fr21.press(R,{'a','left'}) end; if R.doorLast~=h then R.doorLast=h; R.door[#R.door+1]={n=n,slot=d.slot,hp=h,f10=d.f10,x=d.x,y=d.y} end end end")
try:
    for nm, setf in (("ctl", [100, 87]), ("f66", [100, 87, 102])):
        r = visit(m, info, f"FL23-10_door_{nm}", S01R, scene=0x32, set=setf, settle=1100, watch=True, cells=CELLS, execs=[373764, 373777, 373782, 373786],
                  walk=[[91, 160, ["left"]], [650, 1100, ["left"]]], hold={100: ["b"], 101: ["b"]},
                  mash={"button": "b", "from": 170, "to": 640, "down": 2, "gap": 16},
                  hooks=("onSample=fr21.drive{ rec=" + REC + ", at={ [3]=function(R,n) fr21.pos(104,264) end, [90]=function(R,n) fr21.pos(88,232) end }, every=" + EVERY + " }"),
                  shot=f"FL23-10_door_{nm}")
        print(brief(r, limit=16))
        print("   door rows:", r.get("door"), "cells0", r["cells0"], "cells1", r["cells1"])
finally:
    m.close()
