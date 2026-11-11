#!/usr/bin/env python3
"""FR30 batch 6: boss reward flags $0500-$0507 (FL15-BOSS-CLAIM) and the kill-bit exposure forced half (FL14-EXPOSE-AQUEDUCT).
B0: scene $29 (Castoth lair) with flag $0500 (byte $0AA0 bit 0) clear: boss present. B1: flag set: boss must be absent / dying at spawn, enemiesRemaining 0.
V0 / V1: scene $55 (Viper lair) with and without flag $0501 (bit 1). E0 / E1: scene $1D with $0A80 = 0 and $0A80 = $01 (kill bit of enemy number $01)."""
import json
import sys
from fr30_lib import *  # noqa: F401,F403

BOSS_EXECS = [49883, 49891]


def lair(m, info, name, scene, setf, settle=120, shot=None, pre=None):
    rec = [("f500", 0x0AA0, 0x01, 1), ("f501", 0x0AA0, 0x02, 1), ("rem", 0x0AEC, None, 2), ("pf20", 0x09AE, 0x20, 2), ("maxhp", 0x0ACA, None, 2)]
    final = ("final=function(R) R.en=fr30.enemies(); R.rem=kit.r16(0x0AEC); R.bcd=kit.r16(0x0AEE); R.aa0=fr30.bytes(0x0AA0,3); R.stats={maxhp=kit.r16(0x0ACA),"
             "hp=kit.r16(0x0ACE),str=kit.r16(0x0ADE),def=kit.r16(0x0ADC)}; R.kill=fr30.bytes(0x0A80,4) end")
    hooks = drive(rec=rec, adv=False, snaps=[1, settle // 2, settle - 1]) + "," + final
    return visit(m, info, name, S01R, shot=shot, scene=scene, set=setf, pre=pre, settle=settle, watch=False, hooks=hooks, execs=BOSS_EXECS, frames=settle + 1400)


def show(r):
    print("==", r["experiment"], "scene", r.get("scene"), "err", r.get("error"), "d36", r.get("d36"), "ctl36", r.get("ctl36"))
    print("  rem@end", r.get("rem"), "bcd", r.get("bcd"), "aa0", r.get("aa0"), "stats", r.get("stats"), "kill", r.get("kill"))
    print("  execs", json.dumps(r.get("execs")))
    print("  rec", json.dumps((r.get("rec") or [])[:25], separators=(",", ":")))
    print("  enemies@end", [(e["pc"], e["x"], e["y"], e["hp"]) for e in (r.get("en") or [])])
    print("  actors0", [(a["file"], a["x"], a["y"]) for a in (r.get("actors0_named") or []) if a["file"] not in SKIP])
    print("  actors1", [(a["file"], a["x"], a["y"]) for a in (r.get("actors1_named") or []) if a["file"] not in SKIP])
    for k in sorted((r.get("snap") or {}), key=int):
        print("  snap", k, len(r["snap"][k]))


if __name__ == "__main__":
    which = sys.argv[1:] or ["B0", "B1", "V0", "V1", "E0", "E1"]
    m, info = open_o()
    try:
        for k in which:
            if k == "B0":
                show(lair(m, info, "castoth_B0_control", 41, [], shot="castoth_B0_control"))
            elif k == "B1":
                show(lair(m, info, "castoth_B1_forced_0500", 41, [1280], shot="castoth_B1_forced"))
            elif k == "V0":
                show(lair(m, info, "viper_V0_control", 85, [], shot="viper_V0_control"))
            elif k == "V1":
                show(lair(m, info, "viper_V1_forced_0501", 85, [1281], shot="viper_V1_forced"))
            elif k == "E0":
                show(lair(m, info, "scene1D_E0_control", 29, [], shot="scene1D_E0_control"))
            elif k == "E2":
                show(lair(m, info, "scene1D_E2_kill0A80_02", 29, [], pre=[[0x0A80, 2]], shot="scene1D_E2_forced"))
            elif k == "E3":
                show(lair(m, info, "scene1D_E3_kill0A80_3E", 29, [], pre=[[0x0A80, 0x3E]], shot="scene1D_E3_forced"))
            elif k == "E1":
                show(lair(m, info, "scene1D_E1_kill0A80_01", 29, [], pre=[[0x0A80, 1]], shot="scene1D_E1_forced"))
    finally:
        m.close()
