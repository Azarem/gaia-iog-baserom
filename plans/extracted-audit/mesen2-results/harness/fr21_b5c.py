#!/usr/bin/env python3
"""FR21 batch 5c: FL23-04 fr32_kara presence in scene $32 with $65 clear (control), $65 set, $57 set."""
from fr21_lib import *  # noqa: F401,F403

m, info = open_o()
try:
    for nm, setf in (("ctl64", [100]), ("f65", [100, 101]), ("f57", [100, 87]), ("none", [])):
        r = visit(m, info, f"FL23-04_kara_{nm}", S01R, scene=0x32, set=setf, settle=150, watch=True)
        a = [(x["file"], x["x"], x["y"], hex(x["f10"])) for x in r["actors1_named"] if x["file"] in ("fr32_kara",)]
        print(nm, setf, "d36", r["d36"], "kara actors:", a, "mask0", hex(r["mask0"]))
finally:
    m.close()
