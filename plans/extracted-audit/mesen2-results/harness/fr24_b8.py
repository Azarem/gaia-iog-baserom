#!/usr/bin/env python3
"""FR24 batch 8: FL29-02 ($0E, Lola's Melody in scene 205), FL29-08/09 ($BB / $D0 in scene 205)."""
import sys
from fr24_lib import *  # noqa: F401,F403

which = [w for w in sys.argv[1:] if not w.startswith("-")]
m, info = open_o()
SCR = [flagrec(14, "s0E"), flagrec(1, "s01"), flagrec(13, "s0D"), flagrec(15, "s0F"), flagrec(2, "s02"), flagrec(3, "s03")]
EX = [571425, 571452, 571458, 571461, 232420, 232426, 232437, 232491, 232501, 571233, 571287]
at = "[60]=function(R,n) fr21.item(0x09,0) end"
hold = {62: ["y"], 63: ["y"], 64: ["y"]}
try:
    if "M0" in which:   # control: first visit, melody before any stone
        show(trial(m, info, "FL29-02_M0_s205_melody", 205, settle=1500, execs=EX, rec=SCR + [("mask", 0x065A, None, 2)], at=at, hold=hold,
                   shot="FL29-02_M0", snaps=(30, 1400)), rec_limit=24)
    if "M1" in which:   # contrast: $0E cleared after the load, then the melody
        show(trial(m, info, "FL29-02_M1_s205_melody_no0E", 205, post={"clear": [14]}, settle=300, execs=EX, rec=SCR, at=at, hold=hold,
                   shot="FL29-02_M1", snaps=(30,)), rec_limit=24)
    STONES = [194, 195, 196, 197, 198, 199]
    R8 = [flagrec(187, "fBB"), flagrec(208, "fD0"), flagrec(252, "fFC"), flagrec(14, "s0E"), flagrec(15, "s0F"), ("mask", 0x065A, None, 2)]
    EX8 = [571458, 571884, 572941, 572943, 572967, 232414, 232420, 232426, 232491]
    if "N0" in which:
        show(trial(m, info, "FL29-08_N0_stones_ctl", 205, set_=STONES, settle=500, execs=EX8, rec=R8, at=at, hold=hold, shot="FL29-08_N0", snaps=(30,)), rec_limit=24)
    if "N1" in which:
        show(trial(m, info, "FL29-08_N1_stones_BB", 205, set_=STONES + [187], settle=500, execs=EX8, rec=R8, at=at, hold=hold, shot="FL29-08_N1", snaps=(30,)), rec_limit=24)
    if "N2" in which:
        show(trial(m, info, "FL29-09_N2_stones_BB_FC", 205, set_=STONES + [187, 252], settle=1800, execs=EX8 + [572881, 572884], rec=R8, shot="FL29-09_N2", snaps=(30, 1700)), rec_limit=24)
    if "N3" in which:
        show(trial(m, info, "FL29-09_N3_stones_BB_FC_D0", 205, set_=STONES + [187, 252, 208], settle=500, execs=EX8, rec=R8, shot="FL29-09_N3", snaps=(30,)), rec_limit=24)
finally:
    m.close()
