#!/usr/bin/env python3
"""FR24 batch 4: FL28-07/08/09 (Gorgon Flower petals, scene 174 = $AE)."""
import sys
from fr24_lib import *  # noqa: F401,F403

which = [w for w in sys.argv[1:] if not w.startswith("-")]
NV = [172, 173, 174, 175, 176, 178]          # $AC $AD $AE $AF $B0 $B2
REC = [flagrec(191, "fBF"), flagrec(192, "fC0"), flagrec(193, "fC1"), flagrec(207, "fCF"), flagrec(230, "fE6"),
       ("jw", 0x0AB0, None, 2), ("inv0", 0x0AB4, None, 2), ("mask", 0x065A, None, 2)]
EX = [236024, 236039, 236054, 236081, 236013, 561865, 561870, 562066, 562333, 562083, 562089, 562098, 562106, 562489, 562520, 562524]
GIRL2 = "{0x9369,0x946F}"
m, info = open_o()
try:
    if "H0" in which:   # control: three petals in order from the inventory
        at = ("[4]=function(R,n) fr21.pos(104,120) fr21.item(0x1D,0) end,"
              "[304]=function(R,n) fr21.pos(136,120) fr21.item(0x1D,0) end,"
              "[604]=function(R,n) fr21.pos(168,120) fr21.item(0x1D,0) end")
        hold = {6: ["y"], 7: ["y"], 8: ["y"], 306: ["y"], 307: ["y"], 308: ["y"], 606: ["y"], 607: ["y"], 608: ["y"]}
        show(trial(m, info, "FL28-07_H0_petals_ctl", 174, set_=NV, settle=1300, execs=EX, rec=REC, at=at, hold=hold, shot="FL28-07_H0", snaps=(30, 1200)))
    if "H1" in which:   # forced: $BF $C0 $C1 set before the load, then talk to girl 2 twice
        talk = ("fr23.talker{ {n=900, find=%s, dy=16, len=60}, {n=1100, find=%s, dy=16, len=60} }" % (GIRL2, GIRL2))
        show(trial(m, info, "FL28-08_H1_forced_BF_C0_C1", 174, set_=NV + [191, 192, 193], settle=1300, execs=EX, rec=REC,
                   every="function(R,n) (%s)(R,n) end" % talk, shot="FL28-08_H1", snaps=(30, 800)))
    if "H2" in which:   # forced: $C0 and $E6 set (CF set so no cutscene lock), talk to girl 2
        talk = ("fr23.talker{ {n=100, find=%s, dy=16, len=100} }" % GIRL2)
        show(trial(m, info, "FL28-08_H2_forced_C0_E6", 174, set_=NV + [192, 230, 207], settle=400, execs=EX, rec=REC,
                   every="function(R,n) (%s)(R,n) end" % talk, shot="FL28-08_H2", snaps=(30,)))
    if "H3" in which:   # forced: $C0 set, $E6 clear: reward given once
        talk = ("fr23.talker{ {n=100, find=%s, dy=16, len=100}, {n=300, find=%s, dy=16, len=100} }" % (GIRL2, GIRL2))
        show(trial(m, info, "FL28-08_H3_forced_C0_noE6", 174, set_=NV + [192, 207], settle=500, execs=EX, rec=REC,
                   every="function(R,n) (%s)(R,n) end" % talk, shot="FL28-08_H3", snaps=(30,)))
finally:
    m.close()
