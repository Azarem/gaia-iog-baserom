#!/usr/bin/env python3
"""FR24 batch 5: FL28-03 ($B3: Angkor Wat entrance latch, Hamlet gate, scene 172 music)."""
import sys
from fr24_lib import *  # noqa: F401,F403

which = [w for w in sys.argv[1:] if not w.startswith("-")]
m, info = open_o()
BG = ("bgm", 0x06F2, None, 2)
try:
    if "I0" in which:   # control: first entry of scene 176
        show(trial(m, info, "FL28-03_I0_s176_first_entry", 176, settle=400, execs=[563171, 563177, 563183, 563189, 563195, 563199, 563205],
                   rec=[flagrec(179, "fB3"), flagrec(190, "fBE"), BG], shot="FL28-03_I0", snaps=(30,)))
    if "I1" in which:   # control: scene 172 with $AC $AF set, $B3 clear
        show(trial(m, info, "FL28-03_I1_s172_ctl", 172, set_=[172, 175], settle=300, execs=[558689, 558783, 558781],
                   rec=[flagrec(179, "fB3"), BG], shot="FL28-03_I1", snaps=(30,)))
    if "I2" in which:   # forced: $B3 set
        show(trial(m, info, "FL28-03_I2_s172_B3", 172, set_=[172, 175, 179], settle=300, execs=[558689, 558783, 558781],
                   rec=[flagrec(179, "fB3"), BG], shot="FL28-03_I2", snaps=(30,)))
finally:
    m.close()
