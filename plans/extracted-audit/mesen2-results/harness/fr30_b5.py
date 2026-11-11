#!/usr/bin/env python3
"""FR30 batch 5: kill-flag block lifetime (FL10-03): ordinary scene change, world-map entry (scene $FE), game over with 100 gems or more (revive), game over with fewer.
Before the warp every byte of $0A02-$0AA1 is written $FF (flags $0010-$050F: kill block $0A80-$0A9F, event/reward blocks $0A02-$0A7F, boss flags $0AA0-$0AA1);
the end dump ($0A00-$0AB3, 180 bytes) shows which bytes were cleared. Exec marks: ClearAllWramFlags entry 46284, its WorldMapController call 238336,
the game-over clear loop start 54988, the revive payment 54932."""
import json
import sys
from fr30_lib import *  # noqa: F401,F403

EX = [46284, 238336, 54988, 54932, 54957]
FF_ALL = [[a, 255] for a in range(0x0A02, 0x0AA2)]


def dump_runs(hexs):
    """Runs of equal bytes of the 180-byte dump as 'start-end=XX'."""
    out, i = [], 0
    b = [int(hexs[k:k + 2], 16) for k in range(0, len(hexs), 2)]
    while i < len(b):
        j = i
        while j + 1 < len(b) and b[j + 1] == b[i]:
            j += 1
        out.append("%04X-%04X=%02X" % (0x0A00 + i, 0x0A00 + j, b[i]))
        i = j + 1
    return out


def warp(m, info, name, scene, settle=200, shot=None):
    final = "final=function(R) R.dump=gaia.flags.dump(); R.sceneEnd2=kit.r16(0x0644); R.form=kit.r16(0x0AD4) end"
    hooks = drive(adv=False) + "," + final
    return visit(m, info, name, S01R, shot=shot, scene=scene, pre=FF_ALL, settle=settle, watch=False, hooks=hooks, execs=EX)


def gameover(m, info, name, gems, settle=420, shot=None):
    """From scene $71 after the load: pre-set the blocks, at settle frame 20 write gemCount, at 30 write playerHp = 0 and watch for game over."""
    at = ("[5]=function(R,n) for a=0x0A02,0x0AA1 do kit.w8(a,255) end R.pre=fr30.bytes(0x0A80,32); R.gems0=kit.r16(0x0AD6) end,"
          "[20]=function(R,n) kit.w16(0x0AD6,%d) end,"
          "[30]=function(R,n) R.hpBefore=kit.r16(0x0ACE); kit.w16(0x0ACE,0); R.maxhp=kit.r16(0x0ACA) end") % gems
    rec = [("hp", 0x0ACE, None, 2), ("gems", 0x0AD6, None, 2), ("pf0200", 0x09AE, 0x0200, 2), ("form", 0x0AD4, None, 2), ("k80", 0x0A80, None, 2),
           ("k86", 0x0A86, None, 1), ("a00", 0x0A00, None, 2), ("a02", 0x0A02, None, 1), ("a60", 0x0A60, None, 1), ("aa0", 0x0AA0, None, 1)]
    final = "final=function(R) R.dump=gaia.flags.dump(); R.sceneEnd2=kit.r16(0x0644); R.gemsEnd=kit.r16(0x0AD6); R.hpEnd=kit.r16(0x0ACE) end"
    hooks = drive(rec=rec, at=at, adv=False) + "," + final
    return visit(m, info, name, S01R, shot=shot, scene=113, settle=settle, watch=False, hooks=hooks, execs=EX, frames=settle + 1400)


def show(r):
    print("==", r["experiment"], "scene", r.get("scene"), "end", r.get("sceneEnd2"), "err", r.get("error"), "d36", r.get("d36"), "ctl36", r.get("ctl36"))
    if r.get("dump"):
        print("  dump runs", dump_runs(r["dump"]))
    print("  execs", json.dumps(r.get("execs")))
    print("  pre", r.get("pre"), "gems0", r.get("gems0"), "hpBefore", r.get("hpBefore"), "maxhp", r.get("maxhp"), "gemsEnd", r.get("gemsEnd"), "hpEnd", r.get("hpEnd"), "form", r.get("form"))
    print("  rec", json.dumps((r.get("rec") or [])[:40], separators=(",", ":")))
    print("  scenes", json.dumps(r.get("scenes")))


if __name__ == "__main__":
    which = sys.argv[1:] or ["ctl", "wm"]
    m, info = open_o()
    try:
        for k in which:
            if k == "ctl":
                show(warp(m, info, "kill_block_ctl_scene15", 0x15, shot="kill_block_ctl_scene15"))
            elif k == "wm":
                show(warp(m, info, "kill_block_wm_scene_FE", 0xFE, shot="kill_block_wm_scene_FE"))
            elif k == "rev":
                show(gameover(m, info, "kill_block_gameover_rev", 150, shot="kill_block_gameover_rev"))
            elif k == "real":
                show(gameover(m, info, "kill_block_gameover_real", 50, shot="kill_block_gameover_real"))
    finally:
        m.close()
