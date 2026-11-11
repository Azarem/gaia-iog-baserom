#!/usr/bin/env python3
"""FR30 batch 4: scene reward flag ($0300 + scene) and dungeon kill flag ($0400 + enemy number) in scene $71 (angel_tunnel_wind, tier 1 = Max HP +1,
two av70_ramskull rows with enemy numbers $37 and $38; flag $0371 = global 881 = byte $0A6E bit 1; kill bits global 1079 = $0A86 bit 7 and 1080 = $0A87 bit 0).
Kill driver: every frame from settle frame 10 each live enemy row with HP > 0 gets HP 1 and is put 20 px above the player (position words $1014/$1016
only); physical B is pressed 3 frames of every 10 (the player faces up after one up press at frame 10).
Runs: K0 control (flags clear): both enemies are killed, the reward pickup spawns, Max HP +1, flag 881 set, kill bits set. K1 forced reward: flag 881 set before the load.
K2 forced kill: flag 1079 set before the load (enemy $37 must be absent). K3 both flags."""
import json
import sys
from fr30_lib import *  # noqa: F401,F403

EX = [56727, 56311, 57679, 56758, 249750, 249721]


def kill(m, info, name, setf, settle=360, shot=None, extra_final=""):
    every = ("function(R,n) "
             "if n==10 then fr21.press(R,{'up'}) end "
             "if n>=11 and (n%10)<3 and n<=LIM then fr21.press(R,{'b'}) end "
             "if n>=10 and n<=LIM then local px,py=kit.r16(0x1014),kit.r16(0x1016); "
             "for _,e in ipairs(fr30.enemies()) do if e.hp>0 then kit.w16(e.slot+0x14,px); kit.w16(e.slot+0x16,py-20); emu.write16(0x10026+e.slot,1,emu.memType.snesWorkRam) end end end "
             "end").replace("LIM", str(settle - 20))
    rec = [("rem", 0x0AEC, None, 2), ("maxhp", 0x0ACA, None, 2), ("hp", 0x0ACE, None, 2), ("str", 0x0ADE, None, 2), ("def", 0x0ADC, None, 2),
           ("f371", 0x0A6E, 0x02, 1), ("k37", 0x0A86, 0x80, 1), ("k38", 0x0A87, 0x01, 1), ("heal", 0x0B22, None, 2), ("pf20", 0x09AE, 0x20, 2)]
    final = ("final=function(R) R.en=fr30.enemies(); R.rem=kit.r16(0x0AEC); R.bcd=kit.r16(0x0AEE); R.kill=fr30.bytes(0x0A80,32); R.rew=fr30.bytes(0x0A60,32); "
             "R.stats={maxhp=kit.r16(0x0ACA),hp=kit.r16(0x0ACE),str=kit.r16(0x0ADE),def=kit.r16(0x0ADC)}; R.gems=kit.r16(0x0AD6) " + extra_final + " end")
    hooks = drive(rec=rec, every=every, adv=False, snaps=[1, 120, 240, settle - 1]) + "," + final
    return visit(m, info, name, S01R, shot=shot, scene=113, set=setf, settle=settle, watch=False, hooks=hooks, execs=EX, frames=settle + 1400)


def show(r):
    print("==", r["experiment"], "scene", r.get("scene"), "err", r.get("error"), "d36", r.get("d36"), "ctl36", r.get("ctl36"))
    print("  rem@end", r.get("rem"), "bcd", r.get("bcd"), "stats", r.get("stats"), "gems", r.get("gems"))
    print("  kill", r.get("kill"))
    print("  rew ", r.get("rew"))
    print("  execs", json.dumps(r.get("execs")))
    print("  rec", json.dumps((r.get("rec") or [])[:40], separators=(",", ":")))
    for k in sorted((r.get("snap") or {}), key=int):
        v = r["snap"][k]
        print("  snap", k, [(a["pc"], a["x"], a["y"]) for a in v if a["pc"] not in ()][:14])
    print("  actors0", [(a["file"], a["x"], a["y"]) for a in (r.get("actors0_named") or []) if a["file"] not in SKIP])
    print("  actors1", [(a["file"], a["x"], a["y"]) for a in (r.get("actors1_named") or []) if a["file"] not in SKIP])


if __name__ == "__main__":
    which = sys.argv[1:] or ["K0", "K1", "K2"]
    runs = {"K0": ("scene71_K0_control", []), "K1": ("scene71_K1_forced_reward", [881]), "K2": ("scene71_K2_forced_kill", [1079]),
            "K3": ("scene71_K3_both", [881, 1079])}
    m, info = open_o()
    try:
        for k in which:
            name, setf = runs[k]
            r = kill(m, info, name, setf, shot=name)
            show(r)
    finally:
        m.close()
