#!/usr/bin/env python3
"""FR21 batch 4: FL23-04 ($65 = flag 101): scene $32 exit zone (tiles (12,3C)-(16,3E)) menu id with $65 clear and set; scene $39 actors."""
from fr21_lib import *  # noqa: F401,F403
from collections import Counter

m, info = open_o()
W = ",".join(f"{{name='w{a:04X}',addr=0x{a:04X},size=2}}" for a in range(0x0D58, 0x0D70, 2))
REC = "{ {name='f65',addr=0x0A0C,bit=0x20},{name='mask',addr=0x065A,size=2},{name='sc',addr=0x0644,size=2},{name='scn',addr=0x0642,size=2}," + W + " }"
SKIP = ("camera_scroll", "camera_scroll_controller", "player_character", "player_move_controller", "slope_ramp_physics", "attack_ability_system")
try:
    for nm, setf in (("ctl", [100, 87]), ("f65", [100, 87, 101])):
        r = visit(m, info, f"FL23-04_s32exit_{nm}", S01R, scene=0x32, set=setf, settle=240, teleport=[296, 984], watch=True, execs=[52109, 52125],
                  hooks=f"onSample=fr21.drive{{ rec={REC} }}", shot=f"FL23-04_s32exit_{nm}")
        print(brief(r, limit=12))
    for nm, setf in (("ctl", [100, 87]), ("f65", [100, 87, 101])):
        r = visit(m, info, f"FL23-04_s39_{nm}", S01R, scene=0x39, set=setf, settle=200, watch=True,
                  hooks=f"onSample=fr21.drive{{ rec={REC} }}", shot=f"FL23-04_s39_{nm}")
        a = Counter(x["file"] for x in r["actors1_named"] if x["file"] not in SKIP)
        print(brief(r, limit=6)); print("   actors1:", dict(a))
finally:
    m.close()
