#!/usr/bin/env python3
"""FR24 batch 12: FL29-03 (scratch $0F, Vader barriers, scene 214 = $D6)."""
import sys
from fr24_lib import *  # noqa: F401,F403

which = [w for w in sys.argv[1:] if not w.startswith("-")]
m, info = open_o()
try:
    if "T0" in which:
        show(trial(m, info, "FL29-03_T0_s214_list", 214, settle=30, execs=[574316, 574327, 574550, 574561, 574692], rec=[flagrec(15, "s0F")], shot=None))
    EXB = [574316, 574322, 574327, 574385, 574398, 574455, 574536, 574550, 574561, 574619, 574692]
    CEL = [[0x34, 0x2B], [0x39, 0x2C], [0x34, 0x4B], [0x39, 0x4C]]
    def swings(frames):
        h = {}
        for f in range(14, 30): h[f] = ["up"]
        for base in frames:
            for k in range(base, base + 3): h[k] = ["b", "up"]
        return h
    def at(extra=""):
        return "[10]=function(R,n) fr21.pos(936,744) end" + extra
    if "T1" in which:   # control: one hit on the upper barrier, then another a few frames later
        show(trial(m, info, "FL29-03_T1_hit_ctl", 214, settle=800, execs=EXB, rec=[flagrec(15, "s0F"), ("cnt", 0x1086, None, 2), ("form", 0x0AD4, None, 2)], at=at(), hold=swings([40, 80, 120, 300, 560]),
                   cells=CEL, shot="FL29-03_T1", snaps=(30,)), rec_limit=24)
    if "T2" in which:   # forced: $0F set before the first hit
        show(trial(m, info, "FL29-03_T2_hit_s0F", 214, post={"set": [15]}, settle=800, execs=EXB, rec=[flagrec(15, "s0F"), ("cnt", 0x1086, None, 2), ("form", 0x0AD4, None, 2)], at=at(), hold=swings([40, 80, 120, 300, 560]),
                   cells=CEL, shot="FL29-03_T2", snaps=(30,)), rec_limit=24)
    if "T3" in which:   # find the attack button / position
        h = {}
        for f in range(14, 30): h[f] = ["up"]
        for base, bt in ((40, "b"), (90, "a"), (140, "y"), (190, "x")):
            for k in range(base, base + 3): h[k] = [bt, "up"]
        for ypos in (736, 744):
            show(trial(m, info, "FL29-03_T3_find_%d" % ypos, 214, settle=240, execs=EXB, rec=[flagrec(15, "s0F")], at="[10]=function(R,n) fr21.pos(880,%d) end" % ypos, hold=h, shot="FL29-03_T3_%d" % ypos), rec_limit=8)
    if "T4" in which:
        h = {}
        for f in range(14, 30): h[f] = ["up"]
        for base in (40, 80, 120, 160):
            for k in range(base, base + 3): h[k] = ["b", "up"]
        for (px, py) in ((936, 728), (936, 744), (920, 736), (952, 736)):
            show(trial(m, info, "FL29-03_T4_find_%d_%d" % (px, py), 214, settle=200, execs=EXB, rec=[flagrec(15, "s0F")], at="[10]=function(R,n) fr21.pos(%d,%d) end" % (px, py), hold=h, shot="FL29-03_T4_%d_%d" % (px, py)), rec_limit=8)
    def sw(bases):
        h = {}
        for f in range(14, 30): h[f] = ["up"]
        for base in bases:
            for f in range(base - 12, base): h[f] = ["up"]
            for k in range(base, base + 3): h[k] = ["b", "up"]
        return h
    REC3 = [flagrec(15, "s0F"), ("cnt", 0x1086, None, 2)]
    if "T5" in which:   # upper hit, then a lower barrier hit while $0F is set
        show(trial(m, info, "FL29-03_T5_upper_then_lower", 214, settle=300, execs=EXB, rec=REC3[:1], at="[10]=function(R,n) fr21.pos(936,744) end,[100]=function(R,n) fr21.pos(936,1256) end",
                   hold=sw([40, 112, 150]), cells=CEL, shot="FL29-03_T5"), rec_limit=8)
    if "T6" in which:   # lower barrier alone
        show(trial(m, info, "FL29-03_T6_lower_alone", 214, settle=300, execs=EXB, rec=REC3[:1], at="[10]=function(R,n) fr21.pos(936,1256) end",
                   hold=sw([40, 80]), cells=CEL, shot="FL29-03_T6"), rec_limit=8)
finally:
    m.close()
