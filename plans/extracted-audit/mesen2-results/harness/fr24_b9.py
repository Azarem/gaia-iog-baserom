#!/usr/bin/env python3
"""FR24 batch 9: FL29-12/13/14/15 (Babel crystal gates a-d and the Kara-missing reader, scene 224 = $E0), FL29-10 ($D2 monologue, scene 222 = $DE)."""
import sys
from fr24_lib import *  # noqa: F401,F403

which = [w for w in sys.argv[1:] if not w.startswith("-")]
m, info = open_o()
CELLS = [[0x71, 0x38], [0x72, 0x38], [0x0D, 0x28], [0x0E, 0x28], [0x49, 0x18], [0x4A, 0x18], [0x15, 0x08], [0x16, 0x08]]
NAMES = ["a71,38", "a72,38", "b0D,28", "b0E,28", "c49,18", "c4A,18", "d15,08", "d16,08"]
REC = [flagrec(373, "f0175"), flagrec(374, "f0176"), flagrec(375, "f0177"), flagrec(376, "f0178"), flagrec(212, "fD4"), ("mask", 0x065A, None, 2)]
EX = [624184, 624206, 624218, 624441, 624446, 624454, 624585, 624590, 624598]

def setb(addr, bit):
    return "[60]=function(R,n) kit.w8(0x%04X, kit.r8(0x%04X) | 0x%02X) end" % (addr, addr, bit)

def cells(r):
    c0, c1 = r.get("cells0"), r.get("cells1")
    if c0 is None:
        print("   cells: none"); return
    print("   cells0:", " ".join("%s=%s" % (NAMES[i], c0[i]) for i in range(len(CELLS))))
    print("   cells1:", " ".join("%s=%s" % (NAMES[i], c1[i]) for i in range(len(CELLS))))

try:
    runs = [("P0", "ctl", [212], "[60]=function(R,n) end"), ("P1", "a_0175", [212], setb(0x0A2E, 0x20)), ("P2", "b_0176", [212], setb(0x0A2E, 0x40)),
            ("P3", "c_0177", [212], setb(0x0A2E, 0x80)), ("P4", "d_0178_runtime", [212], setb(0x0A2F, 0x01)), ("P5", "d_0178_load", [212, 376], "[60]=function(R,n) end")]
    for key, nm, st, at in runs:
        if key in which:
            r = trial(m, info, "FL29-12_%s_s224_%s" % (key, nm), 224, set_=st, settle=200, execs=EX, rec=REC, at=at, cells=CELLS, shot="FL29-12_%s" % key, snaps=(30,))
            show(r, rec_limit=12); cells(r)
    if "Q0" in which:   # FL29-10 control: first arrival at scene 222
        show(trial(m, info, "FL29-10_Q0_s222_ctl", 222, settle=500, execs=[628918, 628934, 628940, 628946, 628952, 628962], rec=[flagrec(210, "fD2"), ("mask", 0x065A, None, 2)], shot="FL29-10_Q0", snaps=(30,)))
    if "Q1" in which:
        show(trial(m, info, "FL29-10_Q1_s222_D2", 222, set_=[210], settle=500, execs=[628918, 628934, 628940, 628946, 628952, 628962], rec=[flagrec(210, "fD2"), ("mask", 0x065A, None, 2)], shot="FL29-10_Q1", snaps=(30,)))
finally:
    m.close()
