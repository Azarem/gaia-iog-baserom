#!/usr/bin/env python3
"""B5 additions to the B2 walk harness (scenario_b2_walk.py is not changed): suites registered into its SUITES.
usage: python scenario_b5w.py --suite n8|y16|fp15 [--repeat 2] [--out ../raw/B5]"""
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import scenario_b2_walk as w
from scenario_b2_walk import case

SNAPP = ["EWPushDown", "EWPushUp", "PushUp", "PushDown", "CompEastSnap", "SnapYN", "SnapYS", "SnapXE", "AAlignNSE", "AAlignY", "EWNorthFlag", "EWSouthFlag"]


def suite_n8():
    """BA-18: the n = 8 (d = 8) boundary of the slope flag $1000 on the $0C / $03 stack (23, 8)-(23, 12), walking north in 2-px ticks from Y = 223 + k: the top
    probe is Y - 2t - 16, so n = (probe & 15). The $09AE word is sampled per frame ($09AE, $09C6 as extra)."""
    cs = []
    col = lambda t, rows: [[23, r, t] for r in rows]
    snap = ["NSlopeR", "NSlopeL"]
    for typ, tn in ((0x0C, "$0C"), (0x03, "$03")):
        for y0 in (226, 225, 224, 223, 222, 221, 220, 219):
            cs.append(case(f"N8 {tn} north X376 from Y{y0}", 376, y0, ["up"], 14, col(typ, range(8, 13)), snap=snap, extra=[0x09AE, 0x09C6]))
    return cs


def suite_y16():
    """BA-16: the $06 / $09 mirror pair (columns 23 / 22, rows 11-12) walked south from Y 184..199, X in 364 / 368 / 372; row 6 frames."""
    cs = []
    snap = ["FineE", "FineW", "CompSouthSnap", "SnapYN", "SnapYS", "AAlignEWS", "SouthBlocked"]
    for y in range(184, 200):
        for x in (364, 368, 372):
            cs.append(case(f"S $06 col23 r11-12 X{x} Y{y}", x, y, ["down"], 6, [[23, 11, 6], [23, 12, 6]], snap=snap))
            cs.append(case(f"S $09 col22 r11-12 X{x} Y{y}", x, y, ["down"], 6, [[22, 11, 9], [22, 12, 9]], snap=snap))
    return cs


def suite_fp15():
    """BA-15: the wall-slide push of WallSlidePushDown (PushDown) with $02 / $00 / $26 per tick: East into a $09 at (23, 10), X 366-376, Y 176 / 177 / 184 / 191
    (the flushpush suite of B2 with the snap list kept; registers per snap row: $20 $22 $24 $26 $02 $1A $1E $AA $AB $09C6 actorX)."""
    cs = []
    for x in (366, 370, 372, 374, 376):
        for y in (176, 177, 184, 191):
            cs.append(case(f"FP $09 (23,10) X{x} Y{y}", x, y, ["right"], 8, [[23, 10, 9]], snap=SNAPP, extra=[0x0000, 0x0002]))
    return cs


def suite_y16s():
    """BA-14: the single-row $06 / $09 (the shape real maps have) walked south from Y 184..199, X 364 / 368 / 372 (suite y16 with rows 11 only)."""
    cs = []
    snap = ["FineE", "FineW", "CompSouthSnap", "SnapYN", "SnapYS", "AAlignEWS", "SouthBlocked"]
    for y in range(176, 200):
        for x in (364, 368, 372):
            cs.append(case(f"S $06 col23 r11 X{x} Y{y}", x, y, ["down"], 6, [[23, 11, 6]], snap=snap))
            cs.append(case(f"S $09 col22 r11 X{x} Y{y}", x, y, ["down"], 6, [[22, 11, 9]], snap=snap))
    return cs


w.SUITES.update({"n8": suite_n8, "y16": suite_y16, "fp15": suite_fp15, "y16s": suite_y16s})

if __name__ == "__main__":
    w.main()
