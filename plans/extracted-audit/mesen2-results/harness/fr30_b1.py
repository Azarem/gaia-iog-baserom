#!/usr/bin/env python3
"""FR30 batch 1: chest flag (FL12-01). Scene $0E (Herb chest at tile (04,1A), record flag $01 of the $0200 group = global 513 = byte $0A40 bit 1).
Control: flag clear. Forced: flag 513 set before the scene load. Each run: rect of the chest cells (map layer + collision), then the player is placed under the
chest (80, 456) and pushes up for 60 frames; inventory slots, flag byte, GiveItemToPlayer / PlaceOpenedChestTiles exec marks, screenshot."""
import json
import sys
from fr30_lib import *  # noqa: F401,F403
import fr20_lib as L

CHEST = (4, 0x19, 2, 2)   # top-left cell (X, Y-1) and 2x2 size
EX = [173552, 173602, 173704, 257943]   # PlaceOpenedChestTiles entry, TileCoordsToMapIndex call inside its flag-set path, HandleChestInteraction tile lookup (guards passed), GiveItemToPlayer


def trial(m, info, name, setf, shot):
    at = ("[1]=function(R,n) R.rect1=fr30.rect(%d,%d,%d,%d,0); R.inv1=fr21.inv(); R.b40_1=kit.r8(0x0A40) end,"
          "[2]=function(R,n) R.ctl2=1 end") % CHEST
    walk = "walk={{12,72,{'up'}}}"
    final = ("final=function(R) R.rect2=fr30.rect(%d,%d,%d,%d,0); R.inv2=fr21.inv(); R.b40_2=kit.r8(0x0A40); R.dmf=kit.r16(0x09EC); "
             "R.playerFlags=kit.r16(0x09AE) end") % CHEST
    every = "function(R,n) if n>=90 and (n%12)<2 then fr21.press(R,{(((n//12)%2)==0) and 'a' or 'b'}) end end"
    hooks = drive(rec=[("f513", 0x0A40, 0x02, 1), ("inv0", 0x0AB4, None, 1), ("dmf80", 0x09EC, 0x80, 2)], at=at, every=every) + "," + final + "," + walk
    return visit(m, info, name, S01R, shot=shot, scene=14, set=setf, teleport=[80, 456], settle=260, watch=False, hooks=hooks, execs=EX)


def show(r):
    print("==", r["experiment"], "scene", r.get("scene"), "err", r.get("error"), "d36", r.get("d36"), "ctl36", r.get("ctl36"))
    print("  rect1", r.get("rect1"), "inv1", r.get("inv1"), "$0A40 @arrival", r.get("b40_1"))
    print("  rect2", r.get("rect2"), "inv2", r.get("inv2"), "$0A40 @end", r.get("b40_2"), "dmf", hex(r.get("dmf") or 0), "pf", hex(r.get("playerFlags") or 0))
    print("  execs", json.dumps(r.get("execs")))
    print("  rec", json.dumps((r.get("rec") or [])[:20], separators=(",", ":")))
    print("  shot", r.get("screenshot"))


m, info = open_o()
try:
    for name, setf, shot in (("chest0E_control", [], "chest0E_control"), ("chest0E_forced", [513], "chest0E_forced"),
                             ("chest0E_control_repeat", [], "chest0E_control_repeat"), ("chest0E_forced_repeat", [513], "chest0E_forced_repeat")):
        r = trial(m, info, name, setf, shot)
        show(r)
finally:
    m.close()
