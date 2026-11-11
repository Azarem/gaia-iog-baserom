#!/usr/bin/env python3
"""FR24 batch 2: FL28-02 ($B1: map kid, exit menu), FL28-05 ($B6: scenes 196, 172, 174, exit menu), FL28-11 ($D2: scenes 195, 196, 200)."""
import json
import sys
from fr24_lib import *  # noqa: F401,F403

EXIT = [52404, 52410, 52422, 52438, 52454]
NV = [172, 173, 174, 175, 176, 178]          # $AC $AD $AE $AF $B0 $B2
which = [w for w in sys.argv[1:] if not w.startswith("-")]
TP = (504, 496)
m, info = open_o()
try:
    if "B0" in which:   # FL28-02 control: talk to the map kid, default answer
        every = ("function(R, n) R.n = n if not R.sq then R.sq = fr23.seq({{wait=function() return R.n>=60 end, find={0x8F8B,0x8FE1}, dy=16, max=300, "
                 "done=function() return (kit.r8(0x0A16) & 0x02)~=0 end}}) end R.sq(R, n) end")
        show(trial(m, info, "FL28-02_B0_kid_talk", 172, set_=NV, settle=600, execs=[561092, 561108, 561113, 561117] + EXIT,
                   rec=[flagrec(0xB1, "fB1"), flagrec(0xB6, "fB6")], shot="FL28-02_B0", snaps=(30, 590), every=every))
    if "B0u" in which:   # same, 'up' held with B (Yes row?)
        every = ("function(R, n) R.n = n if not R.sq then R.sq = fr23.seq({{wait=function() return R.n>=60 end, find={0x8F8B,0x8FE1}, dy=16, max=300, "
                 "done=function() return (kit.r8(0x0A16) & 0x02)~=0 end}}) end R.sq(R, n) "
                 "if fr22.dlg() and n % 12 == 6 then fr21.press(R, {'down'}) end end")
        show(trial(m, info, "FL28-02_B0d_kid_talk_down", 172, set_=NV, settle=600, execs=[561092, 561108, 561113, 561117] + EXIT,
                   rec=[flagrec(0xB1, "fB1"), flagrec(0xB6, "fB6")], shot="FL28-02_B0d", snaps=(30,), every=every))
    if "B1" in which:   # exit menu control, $B1 clear
        at = "[100]=function(R,n) fr21.pos(%d,%d) end" % TP
        show(trial(m, info, "FL28-02_B1_exit_ctl", 172, set_=NV, settle=260, execs=EXIT, rec=[flagrec(0xB1, "fB1")], at=at, shot="FL28-02_B1"))
    if "B2" in which:   # exit menu forced, $B1 set
        at = "[100]=function(R,n) fr21.pos(%d,%d) end" % TP
        show(trial(m, info, "FL28-02_B2_exit_B1", 172, set_=NV + [177], settle=260, execs=EXIT, rec=[flagrec(0xB1, "fB1")], at=at, shot="FL28-02_B2"))
    if "C0" in which:   # FL28-05 control: scene 196 first load, $CF set, $B6 clear
        show(trial(m, info, "FL28-05_C0_s196_ctl", 196, set_=[207], settle=500, execs=[566452, 566458, 566486, 566489, 566492],
                   rec=[flagrec(0xB6, "fB6"), flagrec(0xCF, "fCF")], shot="FL28-05_C0", snaps=(30, 490)))
    if "C1" in which:   # forced: $B6 set, scene 172 (+ exit menu)
        at = "[150]=function(R,n) fr21.pos(%d,%d) end" % TP
        show(trial(m, info, "FL28-05_C1_s172_B6", 172, set_=[207 - 207 + 182], settle=330, execs=EXIT + [557146], rec=[flagrec(0xB6, "fB6")], at=at,
                   shot="FL28-05_C1", snaps=(30,)))
    if "C2" in which:   # scene 174 control ($B6 clear, no statues)
        show(trial(m, info, "FL28-05_C2_s174_ctl", 174, set_=NV, settle=200, rec=[flagrec(0xB6, "fB6")], shot="FL28-05_C2", snaps=(30,)))
    if "C3" in which:   # scene 174 forced
        show(trial(m, info, "FL28-05_C3_s174_B6", 174, set_=NV + [182], settle=200, rec=[flagrec(0xB6, "fB6")], shot="FL28-05_C3", snaps=(30,)))
    if "D0" in which:   # FL28-11 control: scene 195, $D2 clear
        show(trial(m, info, "FL28-11_D0_s195_ctl", 195, set_=[180, 182], settle=200, execs=[622795, 622824, 622845, 622867], rec=[flagrec(0xD2, "fD2")],
                   shot="FL28-11_D0", snaps=(30,)))
    if "D1" in which:   # forced: $D2 set, scene 195, talk to the spirit
        every = ("function(R, n) R.n = n if not R.sq then R.sq = fr23.seq({{wait=function() return R.n>=60 end, find={0x80C6,0x811E}, dy=16, max=200, "
                 "done=function() return kit.r16(0x0644)~=195 end}}) end R.sq(R, n) "
                 "if fr22.dlg() and n % 12 == 6 then fr21.press(R, {'down'}) end end")
        show(trial(m, info, "FL28-11_D1_s195_D2", 195, set_=[180, 182, 210], settle=500, execs=[622795, 622824, 622840, 622845, 622867],
                   rec=[flagrec(0xD2, "fD2")], shot="FL28-11_D1", snaps=(30, 490), every=every))
    if "D2" in which:
        show(trial(m, info, "FL28-11_D2_s196_D2", 196, set_=[207, 182, 210], settle=300, execs=[566452, 566458, 566486, 566489, 566492],
                   rec=[flagrec(0xD2, "fD2")], shot="FL28-11_D2", snaps=(30,)))
    if "D3" in which:
        show(trial(m, info, "FL28-11_D3_s200_D2", 200, set_=[180, 182, 210], settle=300, execs=[566723, 566726, 566729, 566767],
                   rec=[flagrec(0xD2, "fD2")], shot="FL28-11_D3", snaps=(30,)))
finally:
    m.close()
