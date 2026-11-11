#!/usr/bin/env python3
"""FR24 batch 14: FL29-06 ($D4: btDF_kara joins in 223, btE3_kara joins in 227, btDE_kara_missing clears it in 224)."""
import sys
from fr24_lib import *  # noqa: F401,F403

which = [w for w in sys.argv[1:] if not w.startswith("-")]
m, info = open_o()
REC = [flagrec(212, "fD4"), flagrec(376, "f0178"), ("mask", 0x065A, None, 2)]
PRE_E3 = [[0x064C, 0x78], [0x064D, 0x00], [0x064E, 0x90], [0x064F, 0x01]]
EX = [623896, 623902, 623913, 623934, 623981, 624351]
try:
    if "V0" in which:   # btE3_kara: D4 clear, 0178 clear
        show(trial(m, info, "FL29-06_V0_s227_D4clear_0178clear", 227, pre=PRE_E3, settle=500, execs=EX, rec=REC, shot="FL29-06_V0", snaps=(30,)), rec_limit=10)
    if "V1" in which:   # D4 clear, 0178 set
        show(trial(m, info, "FL29-06_V1_s227_D4clear_0178set", 227, pre=PRE_E3, set_=[376], settle=500, execs=EX, rec=REC, shot="FL29-06_V1", snaps=(30,)), rec_limit=10)
    if "V2" in which:   # D4 set
        show(trial(m, info, "FL29-06_V2_s227_D4set", 227, pre=PRE_E3, set_=[212], settle=300, execs=EX, rec=REC, shot="FL29-06_V2", snaps=(30,)), rec_limit=10)
    if "V3" in which:   # btDF_kara in scene 223 with the player in the trigger tiles
        show(trial(m, info, "FL29-06_V3_s223_join", 223, settle=2400, execs=[630415, 630423, 630434, 630446, 630545, 630432], rec=REC,
                   at="[20]=function(R,n) fr21.pos(1808,190) end", shot="FL29-06_V3", snaps=(30, 850)), rec_limit=14)
finally:
    m.close()
