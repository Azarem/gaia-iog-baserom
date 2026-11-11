#!/usr/bin/env python3
"""FR30 batch 2: chest flag, radar half (FL12-01) plus an arrival screenshot. Scene $0E: control (flag 513 clear) and forced (flag 513 set); the Start button
(physical Start, logical $1000) opens the radar map at settle frame 15; exec marks: RadarScreenSetup 229567, the BCD count of an unopened chest 230137, the icon store 230127."""
import json
from fr30_lib import *  # noqa: F401,F403

EX = [229567, 230127, 230137]


def radar(m, info, name, setf):
    every = "function(R,n) if n==15 or n==16 then fr21.press(R,{'start'}) end if n>=100 then R.stop=true end end"
    hooks = drive(rec=[("f513", 0x0A40, 0x02, 1)], every=every, adv=False) + ",final=function(R) R.bcd=fr30.bytes(0x0002,1); R.sceneEnd2=kit.r16(0x0644) end"
    return visit(m, info, name, S01R, shot=name, scene=14, set=setf, settle=110, watch=False, hooks=hooks, execs=EX)


def arrival(m, info, name, setf):
    return visit(m, info, name, S01R, shot=name, scene=14, set=setf, settle=3, watch=False,
                 hooks=drive(adv=False) + ",final=function(R) R.rect=fr30.rect(4,0x19,2,2,0) end")


m, info = open_o()
try:
    for name, setf in (("chest0E_radar_control", []), ("chest0E_radar_forced", [513])):
        r = radar(m, info, name, setf)
        print("==", name, "scene", r.get("sceneEnd2"), "execs", json.dumps(r.get("execs")), "shot", r.get("screenshot"))
    for name, setf in (("chest0E_arrival_control", []), ("chest0E_arrival_forced", [513])):
        r = arrival(m, info, name, setf)
        print("==", name, "rect", r.get("rect"), "shot", r.get("screenshot"))
finally:
    m.close()
