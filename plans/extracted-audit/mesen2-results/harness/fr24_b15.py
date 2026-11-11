#!/usr/bin/env python3
"""FR24 batch 15: FL29-07 ($DB, epilogue scene 229 = $E5)."""
import sys
from fr24_lib import *  # noqa: F401,F403

which = [w for w in sys.argv[1:] if not w.startswith("-")]
m, info = open_o()
EX = [774946, 774955, 775006, 775015, 775028, 775053]
REC = [flagrec(219, "fDB"), ("mask", 0x065A, None, 2)]
try:
    if "W0" in which:
        show(trial(m, info, "FL29-07_W0_s229_DBclear", 229, settle=3200, execs=EX + [774973, 774980, 774984, 774998, 775002], rec=REC + [flagrec(2, "s02")], mash={"button": "b", "from": 1150, "to": 4900, "down": 2, "gap": 3}, shot="FL29-07_W0", snaps=(30,)), rec_limit=14)
    if "W1" in which:
        show(trial(m, info, "FL29-07_W1_s229_DBset", 229, set_=[219], settle=700, execs=EX, rec=REC, shot="FL29-07_W1", snaps=(30,)), rec_limit=14)
finally:
    m.close()
