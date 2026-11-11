#!/usr/bin/env python3
"""FR21 batch 3: FL23-01 ($4C = flag 76) and FL23-09 ($0185 = flag 389): scene $2C control vs forced, then scenes $02 and $06."""
import json
from fr21_lib import *  # noqa: F401,F403
from collections import Counter

m, info = open_o()
REC = "{ {name='f4C',addr=0x0A09,bit=0x10},{name='f185',addr=0x0A30,bit=0x20},{name='mask',addr=0x065A,size=2},{name='sc',addr=0x0644,size=2} }"
SKIP = ("camera_scroll", "camera_scroll_controller", "player_character", "player_move_controller", "slope_ramp_physics", "attack_ability_system")
try:
    for scn, frames in ((0x2C, 900), (0x02, 200), (0x06, 200)):
        for nm, setf in (("ctl", []), ("f4C", [76])):
            r = visit(m, info, f"FL23-01_s{scn:02X}_{nm}", S01R, scene=scn, set=setf, settle=frames, watch=True, cgram=True, vram=True, execs=[360840, 360944],
                      hooks=f"onSample=fr21.drive{{ rec={REC} }}", shot=f"FL23-01_s{scn:02X}_{nm}")
            a = Counter(x["file"] for x in r["actors1_named"] if x["file"] not in SKIP)
            print(brief(r, limit=10))
            print("   actors1:", dict(a))
            r["_a"] = a
finally:
    m.close()
