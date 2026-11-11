#!/usr/bin/env python3
"""Scenario B5 (B addendum, 2026-10-30): extra suites on top of scenario_b4's case runner. Usage: scenario_b5.py --suite NAME --sub B5 [same flags as scenario_b4].

Suites are registered into scenario_b4.SUITES so that the B4 trial, summaries and main() are reused unchanged (raw files go to raw/B5/).
"""
import sys

import scenario_b4 as b4
from scenario_b4 import case, scan_slots, glide_hooks, GCOLS, PCOLS, FCOLS, OFF, ramp_hooks
from b5_common import S14H, S14G, S14I, S13  # noqa: F401


def suite_gew(m):
    """BA-20: East and West glide triggers of Mu West ($62, drained state S14h): East (32, 28) type $11, West (40, 28) type $11. Slide east into the East
    trigger (stopped by the wall band at tx 33-34) and west into the West trigger (wall band tx 38-39); X offsets and start phases, plus controls."""
    sl = scan_slots(m, S14H)
    print("S14h glide triggers", {k: v for k, v in sl.items() if k[0] == "G"})
    cs = []
    pk = [[0x0AA2, 2, 2, "or"]]
    for side, key, inp, sgn in (("E", "GE", "right", 1), ("W", "GW", "left", -1)):
        for (slot, x, y, t) in sl.get(key, []):
            hk = glide_hooks(side, slot)
            slide = [[2, [inp]], [3, []], [8, [inp]], [2, [inp, "b"]], [90, [inp]]]
            for dy in (-8, 0, 8, 16, 24):
                for ph in range(2):
                    sx = x - sgn * (60 + ph)
                    cs.append(b4.case(f"G{side}{x} dy{dy:+d} p{ph}", 110, slide, state=S14H, hooks=hk, cols=GCOLS, place=[sx, y + dy], pokes=pk, maxEvents=400))
            walk = [[110, [inp]]]
            cs.append(b4.case(f"G{side}{x} control walk", 110, walk, state=S14H, hooks=hk, cols=GCOLS, place=[x - sgn * 60, y], pokes=pk, maxEvents=400))
            cs.append(b4.case(f"G{side}{x} control noability", 110, slide, state=S14H, hooks=hk, cols=GCOLS, place=[x - sgn * 60, y], maxEvents=400))
    return cs


def suite_gedge(m):
    """BA-23: lateral window edges. Window rule (slider_glide.asm): trigger - 8 < player <= trigger - 8 + $20 on the lateral axis, i.e. offsets -7..+24.
    South trigger (6, 14) of $B5 (X 104): dx -9..-6 with the row-13 cells tx 3..5 cleared (so the player can stand left of the gap) and +22..+26;
    North trigger (6, 21): dx -9..-6 and +22..+26 (open floor); East / West triggers of $62 (S14h): dy -8..-6 and +23..+26."""
    pk = [[0x0AA2, 2, 2, "or"]]
    cs = []
    slideS = [[2, ["down"]], [3, []], [8, ["down"]], [2, ["down", "b"]], [90, ["down"]]]
    slideN = [[2, ["up"]], [3, []], [8, ["up"]], [2, ["up", "b"]], [90, ["up"]]]
    sl = scan_slots(m, S14G)
    slot = sl["GS"][0][0]
    for dx in (-9, -8, -7, -6, 22, 23, 24, 25, 26):
        cs.append(b4.case(f"ES104 dx{dx:+d}", 110, slideS, state=S14G, hooks=glide_hooks("S", slot), cols=GCOLS, place=[104 + dx, 150], pokes=pk,
                          clear=[3, 13, 5, 13], maxEvents=400))
    for dx in (-9, -8, -7, -6, 22, 23, 24, 25, 26):
        cs.append(b4.case(f"EN104 dx{dx:+d}", 110, slideN, state=S14G, hooks=[{"name": "GUnlock", "off": 53422, "slot": 0x1000, "cols": PCOLS + [0x1028]}],
                          cols=GCOLS, place=[104 + dx, 420], pokes=pk, maxEvents=400))
    sl = scan_slots(m, S14H)
    for side, key, inp, sgn in (("E", "GE", "right", 1), ("W", "GW", "left", -1)):
        (slot, x, y, t) = sl[key][0]
        slide = [[2, [inp]], [3, []], [8, [inp]], [2, [inp, "b"]], [90, [inp]]]
        for dy in (-8, -7, -6, 23, 24, 25, 26):
            cs.append(b4.case(f"E{side}{x} dy{dy:+d}", 110, slide, state=S14H, hooks=glide_hooks(side, slot), cols=GCOLS,
                              place=[x - sgn * 60, y + dy], pokes=pk, maxEvents=400))
    return cs


def suite_g3(m):
    """BA-22: the third glide triggers of $B5: South (7, 30) type $13 ($0E = 9, 144 px expected) and North (7, 39) type $15 ($0E = 10, 160 px).
    South: slide down column X 120 / 128 / 136 (gap cells tx 7-8 of row 29) from Y 380 (a start at Y 440 reached the wall before the slide began: no fire, a harness artefact); North: slide up from Y 700 in the same columns."""
    pk = [[0x0AA2, 2, 2, "or"]]
    cs = []
    sl = scan_slots(m, S14G)
    (slot, x, y, t) = sl["GS"][2]
    for dx in (0, 8, 16):
        for ph in range(2):
            slideS = [[2, ["down"]], [3, []], [8, ["down"]], [2, ["down", "b"]], [120, ["down"]]]
            cs.append(b4.case(f"G3S dx{dx:+d} p{ph}", 150, slideS, state=S14G, hooks=glide_hooks("S", slot), cols=GCOLS, place=[x + dx, 380 + ph], pokes=pk, maxEvents=400))
    for dx in (0, 8, 16):
        for ph in range(2):
            slideN = [[2, ["up"]], [3, []], [8, ["up"]], [2, ["up", "b"]], [120, ["up"]]]
            cs.append(b4.case(f"G3N dx{dx:+d} p{ph}", 150, slideN, state=S14G, hooks=[{"name": "GUnlock", "off": 53422, "slot": 0x1000, "cols": PCOLS + [0x1028]}],
                              cols=GCOLS, place=[120 + dx, 700 + ph], pokes=pk, maxEvents=400))
    return cs


def suite_gne(m):
    """BA-21: SliderGlideTriggerNorthEntry of the statue tunnel ($72, state S14i): the actor sits at (1392, 128) after its one (-8, 0) nudge (spawn record
    (87, 8) = pixel 1400), type 9 ($0E = 4, 64 px). Slide north from below at X 1360..1424 (hook: UnlockPlayerAfterClimb; slot 0x13C0 exec on the glide-north
    main entry word 0xD16F is not hooked, the fire is read from the lock + entry bank)."""
    pk = [[0x0AA2, 2, 2, "or"]]
    cs = []
    slideN = [[2, ["up"]], [3, []], [8, ["up"]], [2, ["up", "b"]], [90, ["up"]]]
    for x in (1392, 1384, 1400, 1360, 1424):
        for ph in range(2):
            cs.append(b4.case(f"NE x{x} p{ph}", 110, slideN, state=S14I, hooks=[{"name": "GUnlock", "off": 53422, "slot": 0x1000, "cols": PCOLS + [0x1028]}],
                              cols=GCOLS, place=[x, 200 + ph], pokes=pk, maxEvents=400, ctlOptional=True))
    return cs


def suite_latch(m):
    """BA-19: the stopped-latch probe of SlopePhysicsEntry (both speed words 0 and playerFlags $1000 set), S13 (Itory, stride 5). Probe point =
    (playerXPos, playerYPos) = (actor X - 8, actor Y - 16). Hooks: TileProbeMain, MapCellRight, MapCellDown entries (X register in column 3 of each row,
    DP $00 in the first column) and the type handlers. Case A: probe cell (71, 17) = 0, right 0, below (71, 18) = $05. Case B: probe cell (71, 15) in row
    15 of a page (MapCellDown must carry into the next page row), below (71, 16) = $05. Case C: nothing painted, probe cell in the stair band."""
    hk = [{"name": n, "off": o, "slot": None, "cols": [0x0000, 0x001A, 0x001E, 0x09A2, 0x09A4]} for n, o in
          (("Probe", 189103), ("CellRight", 189251), ("CellDown", 189203), ("CellUp", 189227), ("ReadNib", 189180), ("H05", 177469), ("H0A", 177474), ("Flat", 177488),
           ("Entry", 177195))]
    lat = [[0x09AE, 0x1000, 2, "or"], [0x09A2, 1140, 2], [0x09A4, 280, 2]]
    lat15 = [[0x09AE, 0x1000, 2, "or"], [0x09A2, 1140, 2], [0x09A4, 250, 2]]
    cs = []
    cs.append(b4.case("A row17 below05", 6, [[6, []]], state=S13, hooks=hk, cols=FCOLS, place=[1152, 292], pokes=lat, maxEvents=200,
                      paint=[(71, 17, 0), (72, 17, 0), (71, 18, 5), (72, 18, 0)]))
    cs.append(b4.case("B row15 carry", 6, [[6, []]], state=S13, hooks=hk, cols=FCOLS, place=[1152, 266], pokes=lat15, maxEvents=200,
                      paint=[(71, 15, 0), (72, 15, 0), (71, 16, 5), (72, 16, 0)]))
    cs.append(b4.case("C below-right only", 6, [[6, []]], state=S13, hooks=hk, cols=FCOLS, place=[1152, 292], pokes=lat, maxEvents=200,
                      paint=[(71, 17, 0), (72, 17, 0), (71, 18, 0), (72, 18, 0x0A)]))
    cs.append(b4.case("D right only", 6, [[6, []]], state=S13, hooks=hk, cols=FCOLS, place=[1152, 292], pokes=lat, maxEvents=200,
                      paint=[(71, 17, 0), (72, 17, 5), (71, 18, 0), (72, 18, 0)]))
    cs.append(b4.case("E none", 6, [[6, []]], state=S13, hooks=hk, cols=FCOLS, place=[1152, 292], pokes=lat, maxEvents=200,
                      paint=[(71, 17, 0), (72, 17, 0), (71, 18, 0), (72, 18, 0)]))
    return cs


def suite_ns12(m):
    """BA-30: who writes $09B4 when EW/NS are poked (EW +5 / NS +12, EW +12 / NS +12, EW +5 / NS -12, EW 0 / NS +12): write watch with PC and the
    speed words; BA-31: read watch on $1014-$1017 with PC (one idle case, one walk case)."""
    wr = [{"name": "wNs", "lo": 0x09B4, "hi": 0x09B5, "kind": "write", "cols": [[0x09B2, True], [0x09B4, True], 0x09B6, 0x09B8, 0x09AE]}]
    rd = [{"name": "rXY", "lo": 0x1014, "hi": 0x1017, "kind": "read", "cols": []}]
    f = [57 * 16 + 8, 26 * 16 + 16]
    cs = []
    for nm, ew, ns in (("EW5 NS12", 5, 12), ("EW12 NS12", 12, 12), ("EW5 NS-12", 5, -12 & 0xFFFF), ("EW0 NS12", 0, 12), ("EW0 NS-12", 0, -12 & 0xFFFF)):
        cs.append(case("w " + nm, 14, [[14, []]], state=S13, hooks=[], cols=FCOLS, watches=wr, place=f, pokes=[[0x09B2, ew, 2], [0x09B4, ns, 2]], maxEvents=200))
    cs.append(case("r idle", 6, [[6, []]], state=S13, hooks=[], cols=FCOLS, watches=rd, place=f, maxEvents=400))
    cs.append(case("r walk E", 6, [[6, ["right"]]], state=S13, hooks=[], cols=FCOLS, watches=rd, place=f, maxEvents=400))
    return cs


def suite_iframe(m):
    """BA-34: program bank and PC of the accesses to the player's iframe counter ($1028-$1029) with $10 bit $0080 set and the counter poked to +3."""
    w = [{"name": "rC", "lo": 0x11028, "hi": 0x11029, "kind": "read", "cols": [0x11028]}, {"name": "wC", "lo": 0x11028, "hi": 0x11029, "kind": "write", "cols": [0x11028]}]
    f = [57 * 16 + 8, 26 * 16 + 16]
    return [case("iframe +3", 6, [[6, []]], state=S13, hooks=[], cols=FCOLS, watches=w, place=f, pokes=[[0x1010, 0x0080, 2, "or"], [0x11028, 3, 2]], maxEvents=100)]


HB_TYPES = (0x00, 0x0F, 0x05, 0x0A, 0x0E, 0x04, 0x01, 0x08, 0x03, 0x0C)
HB_T = (57, 26)   # target cell in S13's open floor; the area (48..66, 20..32) is cleared in RAM first


def hb_case(t, d, q, p=0, frames=70):
    tx, ty = HB_T
    x0, y0 = tx * 16, ty * 16            # cell origin in pixels; the player's probe is (X - 8, Y - 16)
    if d == "right":
        pl, key = [x0 - 48 + p + 8, y0 + 16 + q], "right"
    elif d == "left":
        pl, key = [x0 + 16 + 48 - p + 8, y0 + 16 + q], "left"
    elif d == "down":
        pl, key = [x0 + 8 + q, y0 + 16 - 48 + p], "down"
    else:
        pl, key = [x0 + 8 + q, y0 + 16 + 16 + 48 - p], "up"
    return case(f"T{t:02X} {d} q{q} p{p}", frames, [[frames, [key]]], state=S13, hooks=[], cols=FCOLS, place=pl, clear=[48, 20, 66, 32],
                paint=[(tx, ty, t)], maxEvents=0)


def suite_hb(m):
    """BA-10 / BA-06: one painted cell of type T at (57, 26), the player walks into it from W / E / N / S for 70 frames from 48 px away; q = 0, 4, 8, 12 px
    offset along the other axis (Y = cell row + 16 + q for E / W, X = cell column + 8 + q for N / S). The final position says which part of the cell blocks."""
    cs = []
    for t in HB_TYPES:
        for d in ("right", "left", "down", "up"):
            for q in (0, 4, 8, 12):
                cs.append(hb_case(t, d, q))
    return cs


def suite_hby(m):
    """BA-11: `$05` and `$0A` painted on row 26 and the player walking east at Y offsets q = -8 .. +23 step 2 (rows 25..27 of the probe)."""
    cs = []
    for t in (0x05, 0x0A):
        for q in range(-8, 24, 2):
            cs.append(hb_case(t, "right", q))
    return cs


def suite_wcorner(m):
    """BA-12: the WestRampUp corner label (186943) on the natural Itory stair (S13, scene $15): walk east up the $05 stair from the foot (cells (63, 24) ..
    (70, 19); $06 caps and a $0F wall column two cells east of each $05), 200 frames, holding right; also from three Y phases of the foot and with a run."""
    hk = [{"name": n, "off": o, "slot": None, "cols": [0x1014, 0x1016, [0x09B2, True], [0x09B4, True], 0x0026, 0x0022, 0x09AE]} for n, o in
          (("WCorner", 186943), ("WestRampUp", 186758), ("EastRampDown", 186435), ("SnapS", 185335), ("SnapN", 184508))]
    cs = []
    for nm, pl, inp in (("walk foot", [63 * 16 + 8, 24 * 16 + 16], [[200, ["right"]]]), ("walk foot y+6", [63 * 16 + 8, 24 * 16 + 22], [[200, ["right"]]]),
                        ("walk foot y-6", [63 * 16 + 8, 24 * 16 + 10], [[200, ["right"]]]), ("run foot", [60 * 16 + 8, 24 * 16 + 16], [[2, ["right"]], [3, []], [195, ["right"]]]),
                        ("walk mid", [67 * 16 + 8, 21 * 16 + 16], [[120, ["right"]]])):
        cs.append(case(nm, sum(f for f, _ in inp), inp, state=S13, hooks=hk, cols=FCOLS, place=pl, maxEvents=800))
    return cs


def suite_short(m):
    """BA-24: the player starts k px short of the ramp coordinate (k = 0..6, 13..16) at the ramp row and holds toward the ramp for 300 frames, arrival speed 8 poked
    (E ramps: from the east moving left, W ramps: from the west moving right); S14. Counts of the hooks Watch / Armed / S2 / Disarm / Launch per case."""
    sl = scan_slots(m, b4.S14)
    print("S14 ramp actors", {k: v for k, v in sl.items() if k in "EW"})
    cs = []
    for side in "EW":
        for (slot, x, y, t) in sl.get(side, [])[:3]:
            hk = ramp_hooks(side, slot)
            for k in (0, 1, 2, 3, 4, 5, 6, 13, 14, 15, 16):
                sx = x - k if side == "W" else x + k
                sv = 8 if side == "W" else (-8) & 0xFFFF
                cs.append(case(f"{side}{slot:04X} short{k}", 300, [[300, ["right" if side == "W" else "left"]]], state=b4.S14, hooks=hk, cols=FCOLS,
                               place=[sx, y + 16], pokes=[[0x09B2, sv, 2]], maxEvents=400, ctlOptional=True))
    return cs


b4.SUITES.update({k[6:]: v for k, v in list(globals().items()) if k.startswith("suite_")})

if __name__ == "__main__":
    sys.argv += ["--sub", "B5"] if "--sub" not in sys.argv else []
    b4.main()
