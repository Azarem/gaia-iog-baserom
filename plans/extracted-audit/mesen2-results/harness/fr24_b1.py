#!/usr/bin/env python3
"""FR24 batch 1: FL28-01 (flag $AC, byte $0A15 bit 4): scene 172 arrival (control) and with $AC set (forced) + talk to Kara."""
import json
import sys
from fr24_lib import *  # noqa: F401,F403

REC = [flagrec(0xAC, "fAC"), flagrec(0xAD, "fAD"), flagrec(0x01, "s01")]
EXECS = [557194, 557213, 557216, 557240, 557502, 557520, 557270, 557405]
KARA = "{0x805A,0x81E1}"

which = [w for w in sys.argv[1:] if not w.startswith("-")] or ["A0", "A1", "A2"]
m, info = open_o()
try:
    if "A0" in which:   # control: every Native Village flag clear
        show(trial(m, info, "FL28-01_A0_ctl", 172, settle=800, execs=EXECS, rec=REC, shot="FL28-01_A0", snaps=(30, 300, 790)))
    if "A1" in which:   # forced: $AC set before the load, no talk
        show(trial(m, info, "FL28-01_A1_AC", 172, set_=[172], settle=300, execs=EXECS, rec=REC, shot="FL28-01_A1", snaps=(30, 290)))
    if "A2" in which:   # forced + talk to Kara (interact handler), watch $AD
        every = ("function(R, n) R.n = n if not R.sq then R.sq = fr23.seq({{wait=function() return R.n>=60 end, find=%s, dx=-16, dy=0, dir='right', max=200, "
                 "done=function() return (kit.r8(0x0A15) & 0x20)~=0 end}}) end R.sq(R, n) end" % KARA)
        show(trial(m, info, "FL28-01_A2_AC_talk", 172, set_=[172], settle=500, execs=EXECS, rec=REC, shot="FL28-01_A2", snaps=(30, 480), every=every))
finally:
    m.close()
