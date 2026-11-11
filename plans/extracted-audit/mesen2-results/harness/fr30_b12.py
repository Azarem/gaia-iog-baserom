#!/usr/bin/env python3
"""FR30 batch 12: FL14-EXPOSE-PYRAMID-BABEL forced half. Babel dark-lair scenes $F2-$F6 loaded with $0A80 = $00 (control) and $0A80 = $3E (kill bits of enemy numbers $01-$05 set).
Recorded: enemiesRemaining $0AEC and the enemy-like actors (HP word nonzero) at the end of 120 settle frames."""
import json
from fr30_lib import *  # noqa: F401,F403

FINAL = "final=function(R) R.en=fr30.enemies(); R.rem=kit.r16(0x0AEC); R.k=fr30.bytes(0x0A80,2) end"
m, info = open_o()
try:
    for scene in (0xF2, 0xF3, 0xF4, 0xF5, 0xF6):
        out = {}
        for k, val in (("ctl", 0x00), ("k3E", 0x3E), ("ctl_repeat", 0x00), ("k3E_repeat", 0x3E)):
            r = visit(m, info, f"babel_s{scene:02X}_{k}", S01R, shot=(f"babel_s{scene:02X}_{k}" if "repeat" not in k else None), scene=scene, pre=[[0x0A80, val]], settle=120, watch=False, hooks=FINAL)
            files = sorted(a["file"] for a in (r.get("actors1_named") or []) if a["file"] not in ("attack_ability_system",))
            out[k] = (r.get("rem"), len(r.get("en") or []), files, r.get("error"), r.get("d36"), r.get("k"))
        print(f"scene {scene:#x}")
        for k, v in out.items():
            print("   ", k, "rem", v[0], "enemies", v[1], "err", v[3], "d36", v[4], "kill bytes", v[5])
        print("    ctl actors", out["ctl"][2])
        print("    k3E actors", out["k3E"][2])
        print("    repeat equal", out["ctl"][:3] == out["ctl_repeat"][:3], out["k3E"][:3] == out["k3E_repeat"][:3])
finally:
    m.close()
