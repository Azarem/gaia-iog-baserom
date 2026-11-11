#!/usr/bin/env python3
"""FR24 batch 10: FL29-11 ($FF latch in scene 232 = $E8)."""
import sys
from fr24_lib import *  # noqa: F401,F403

which = [w for w in sys.argv[1:] if not w.startswith("-")]
m, info = open_o()
EX = [846710, 846746, 846753, 846789, 846796, 846832, 846894, 846942, 48452, 48466, 48478, 48489, 48503]
CLR = "[60]=function(R,n) kit.w8(0x0A1F, kit.r8(0x0A1F) & 0x7F) end"
try:
    if "R0" in which:
        show(trial(m, info, "FL29-11_R0_s232_ctl", 232, settle=140, execs=EX, rec=[flagrec(255, "fFF")], at="[60]=function(R,n) end", shot="FL29-11_R0", snaps=(30,)))
    if "R1" in which:
        show(trial(m, info, "FL29-11_R1_s232_clearFF", 232, settle=140, execs=EX, rec=[flagrec(255, "fFF")], at=CLR, shot="FL29-11_R1", snaps=(30,)))
finally:
    m.close()
