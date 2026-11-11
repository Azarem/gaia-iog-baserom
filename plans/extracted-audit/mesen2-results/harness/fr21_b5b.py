#!/usr/bin/env python3
"""FR21 batch 5b: FL23-10 reload with $67 set (cells at (04,0D), (08,0E)-(08,11), kidnapper actors) and FL23-04 fr32_kara with $65 clear/set in scene $32."""
from fr21_lib import *  # noqa: F401,F403
from collections import Counter

m, info = open_o()
CELLS = [[4, 13], [4, 12], [8, 14], [8, 15], [8, 16], [8, 17], [5, 13]]
KEEP = ("fr32_kidnapper", "fr32_kara", "fr32_locked_door")
try:
    for nm, setf in (("c10_ctl", [100, 87, 102]), ("c10_f67", [100, 87, 102, 103]), ("c04_ctl", [100, 87]), ("c04_f65", [100, 87, 101])):
        r = visit(m, info, f"FL23-10_reload_{nm}", S01R, scene=0x32, set=setf, settle=150, watch=True, cells=CELLS, shot=f"FL23-10_reload_{nm}")
        a = [(x["file"], x["x"], x["y"], hex(x["f10"])) for x in r["actors1_named"] if x["file"] in KEEP]
        print(brief(r, limit=3)); print("   cells0", r["cells0"], "cells1", r["cells1"], "actors:", a)
finally:
    m.close()
