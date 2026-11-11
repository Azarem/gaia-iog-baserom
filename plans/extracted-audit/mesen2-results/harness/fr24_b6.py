#!/usr/bin/env python3
"""FR24 batch 6: FL28-13 ($B5 effect gate, scene 180), FL28-14 ($BE edge, scene 191)."""
import sys
from fr24_lib import *  # noqa: F401,F403

which = [w for w in sys.argv[1:] if not w.startswith("-")]
m, info = open_o()
try:
    EX = [563501, 563511, 563538, 563556, 563562, 563567, 563584, 563587, 563592]
    at = "[400]=function(R,n) end"
    PRE = [[0x064C, 0x70], [0x064D, 0x05], [0x064E, 0x00], [0x064F, 0x00]]
    if "J0" in which:
        show(trial(m, info, "FL28-13_J0_s180_ctl", 180, pre=PRE, settle=400, execs=EX, rec=[flagrec(181, "fB5"), ("pf", 0x09AE, None, 2)], at=at, shot="FL28-13_J0", snaps=(30,)))
    if "J1" in which:
        show(trial(m, info, "FL28-13_J1_s180_B5", 180, pre=PRE, set_=[181], settle=400, execs=EX, rec=[flagrec(181, "fB5"), ("pf", 0x09AE, None, 2)], at=at, shot="FL28-13_J1", snaps=(30,)))
    INV = [("jw", 0x0AB0, None, 2)] + [("i%d" % k, 0x0AB4 + 2 * k, None, 2) for k in range(8)] + [flagrec(190, "fBE"), ("mask", 0x065A, None, 2)]
    EXK = [563979, 563996, 564007, 564012, 564017, 564030, 564034, 564045, 564052, 564005]
    def full(first):
        return [[0x0AB4 + i, (first if i == 0 else 0x1E)] for i in range(16)]
    if "K0" in which:
        show(trial(m, info, "FL28-14_K0_full_none", 191, set_=[189], pre=full(0x1E), settle=900, execs=EXK, rec=INV, shot="FL28-14_K0", snaps=(30,)))
    if "K1" in which:
        show(trial(m, info, "FL28-14_K1_full_jewel", 191, set_=[189], pre=full(0x01), settle=900, execs=EXK, rec=INV, shot="FL28-14_K1", snaps=(30,)))
    if "K2" in which:
        show(trial(m, info, "FL28-14_K2_full_herb", 191, set_=[189], pre=full(0x06), settle=900, execs=EXK, rec=INV, shot="FL28-14_K2", snaps=(30,)))
finally:
    m.close()
