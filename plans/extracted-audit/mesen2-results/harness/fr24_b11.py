#!/usr/bin/env python3
"""FR24 batch 11: FL29-01 (scratch $00, scene 225 = $E1: light elevator cue and the player idle branches)."""
import sys
from fr24_lib import *  # noqa: F401,F403

which = [w for w in sys.argv[1:] if not w.startswith("-")]
m, info = open_o()
EXP = [181375, 181381, 181386, 181391, 181397, 181402, 181407, 181413, 181418, 181423, 181429, 181434]
WALK = {}
for base, d in ((30, "right"), (70, "left"), (110, "up"), (150, "down")):
    for k in range(base, base + 8):
        WALK[k] = [d]
SET0 = "[20]=function(R,n) kit.w8(0x0A00, kit.r8(0x0A00) | 0x01) end"
try:
    if "S0" in which:   # control: step into the elevator tiles
        at = "[20]=function(R,n) fr21.pos(136,1996) end"
        show(trial(m, info, "FL29-01_S0_s225_elevator", 225, settle=520, execs=[628105, 628115, 628124, 628132, 628139, 628146, 181375, 181423], at=at,
                   rec=[flagrec(0, "s00"), flagrec(1, "s01"), ("mask", 0x065A, None, 2)], shot="FL29-01_S0", snaps=(30,)), rec_limit=14)
    if "S1" in which:   # idle east, $00 clear
        show(trial(m, info, "FL29-01_S1_idle_ctl", 225, settle=220, execs=EXP, hold=WALK, at="[20]=function(R,n) end",
                   rec=[flagrec(0, "s00")], shot=None))
    if "S2" in which:   # idle east, $00 set at n=20
        show(trial(m, info, "FL29-01_S2_idle_s00", 225, settle=220, execs=EXP, hold=WALK, at=SET0,
                   rec=[flagrec(0, "s00")], shot=None))
finally:
    m.close()
