#!/usr/bin/env python3
"""FR24 batch 3: FL28-04 ($B4: scene 200 reunion, Dao exit menu, Dark Space Shadow statue), FL28-10 ($D0: Neil), FL28-06 ($BB / $D0: Kara in 196)."""
import json
import sys
from fr24_lib import *  # noqa: F401,F403

which = [w for w in sys.argv[1:] if not w.startswith("-")]
NEIL = "{0xA5B1,0xA62F}"
m, info = open_o()
try:
    if "E0" in which:   # FL28-04 control: scene 200 first visit ($B6 set, $B4 clear)
        show(trial(m, info, "FL28-04_E0_s200_ctl", 200, set_=[182], settle=500, execs=[566717, 566723, 566726, 566752, 566759],
                   rec=[flagrec(0xB4, "fB4")], shot="FL28-04_E0", snaps=(30, 490)))
    if "E1" in which:   # Dao exit menu, $B4 clear (menu $16 = 52510)
        at = "[100]=function(R,n) fr21.pos(12,256) end"
        show(trial(m, info, "FL28-04_E1_exit_ctl", 195, set_=[182], settle=260, execs=[52489, 52497, 52498, 52510, 52526], rec=[flagrec(0xB4, "fB4")], at=at, shot="FL28-04_E1"))
    if "E2" in which:   # Dao exit menu, $B4 set (menu $17 = 52526)
        at = "[100]=function(R,n) fr21.pos(12,256) end"
        show(trial(m, info, "FL28-04_E2_exit_B4", 195, set_=[182, 180], settle=260, execs=[52489, 52497, 52498, 52510, 52526], rec=[flagrec(0xB4, "fB4")], at=at, shot="FL28-04_E2"))
    DS_REC = [flagrec(0xB4, "fB4"), ("form", 0x0AD4, None, 2), ("dsx", 0x0AAC, None, 2)]
    DS_EX = [579736, 579742, 579828, 586730, 586744]
    at_ds = "[60]=function(R,n) fr21.pos(200,176) end"
    if "E3" in which:   # Dark Space (layout 1) with $B4 clear: Shadow statue locked
        show(trial(m, info, "FL28-04_E3_dark_space_ctl", 230, pre=[[0x0AAC, 1], [0x0AAD, 0]], settle=600, execs=DS_EX, rec=DS_REC, at=at_ds,
                   shot="FL28-04_E3", snaps=(30,)))
    if "E4" in which:   # Dark Space with $B4 set
        show(trial(m, info, "FL28-04_E4_dark_space_B4", 230, pre=[[0x0AAC, 1], [0x0AAD, 0]], set_=[180], settle=900, execs=DS_EX, rec=DS_REC, at=at_ds,
                   shot="FL28-04_E4", snaps=(30,)))
    NEILEV = ("function(R, n) R.n = n if not R.sq then R.sq = fr23.seq({{wait=function() return R.n>=60 end, find=%s, dy=16, max=300, "
              "done=function() return kit.r16(0x0644)~=200 or R.n>=420 end}}) end R.sq(R, n) end" % NEIL)
    if "F0" in which:   # FL28-10 control: $D0 clear, talk to Neil
        show(trial(m, info, "FL28-10_F0_neil_ctl", 200, set_=[180, 182], settle=450, execs=[566767, 566773, 566778, 566782, 566794, 566802],
                   rec=[flagrec(0xD0, "fD0"), ("d60", 0x0D60, None, 2)], shot="FL28-10_F0", snaps=(30,), every=NEILEV))
    if "F1" in which:   # forced: $D0 set
        show(trial(m, info, "FL28-10_F1_neil_D0", 200, set_=[180, 182, 208], settle=600, execs=[566767, 566773, 566778, 566782, 566794, 566802],
                   rec=[flagrec(0xD0, "fD0"), ("d60", 0x0D60, None, 2)], shot="FL28-10_F1", snaps=(30,), every=NEILEV))
    if "G0" in which:   # FL28-06 control: $BB clear
        show(trial(m, info, "FL28-06_G0_s196_ctl", 196, set_=[182], settle=200, execs=[566452, 566458], rec=[flagrec(0xBB, "fBB"), flagrec(0xD0, "fD0")],
                   shot="FL28-06_G0", snaps=(30,)))
    if "G1" in which:   # forced: $BB set, $D0 clear
        show(trial(m, info, "FL28-06_G1_s196_BB", 196, set_=[182, 187], settle=200, execs=[566452, 566458], rec=[flagrec(0xBB, "fBB"), flagrec(0xD0, "fD0")],
                   shot="FL28-06_G1", snaps=(30,)))
    if "G2" in which:   # forced: $BB and $D0 set
        show(trial(m, info, "FL28-06_G2_s196_BB_D0", 196, set_=[182, 187, 208], settle=200, execs=[566452, 566458], rec=[flagrec(0xBB, "fBB"), flagrec(0xD0, "fD0")],
                   shot="FL28-06_G2", snaps=(30,)))
finally:
    m.close()
