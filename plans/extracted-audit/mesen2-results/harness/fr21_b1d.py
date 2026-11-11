#!/usr/bin/env python3
"""FR21 batch 1d: FL22-01 NPC talk (physical B at an adjacent NPC) in scene $18 with $2E clear and set; screenshots of the dialog."""
from fr21_lib import *  # noqa: F401,F403

m, info = open_o()
try:
    for who, tp, ex in (("man", [136, 160], 318914), ("woman", [168, 176], 319100)):
        for nm, setf in (("ctl", []), ("set", [46])):
            r = visit(m, info, f"FL22-01_talk_{who}_{nm}", S01R, scene=0x18, set=setf, settle=100, teleport=tp, watch=True, execs=[ex],
                      walk=[[3, 100, ["right"]]], hold={10: ["b"], 11: ["b"]}, shot=f"FL22-01_talk_{who}_{nm}")
            print(who, nm, "flag46", 46 in flag_bits(r["flags1"]), "execs", r["execs"], "actors", len(r["actors1"]), "dmf1", hex(r["dmf1"]), "shot", r.get("shot"))
finally:
    m.close()
