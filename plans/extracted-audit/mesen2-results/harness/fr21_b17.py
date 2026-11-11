#!/usr/bin/env python3
"""FR21 batch 17: FL23-06 ($6A = flag 106, byte $0A0D bit 2) in the Freejia slave market (scene $3C): actors fr3C_imas / fr3C_sam / fr3C_remus, Remus chatPtr and sprite frame, mask."""
from fr21_lib import *  # noqa: F401,F403

m, info = open_o()
try:
    for nm, setf in (("ctl", [102]), ("forced", [102, 106])):
        r = visit(m, info, f"FL23-06_{nm}", S01R, scene=0x3C, set=setf, settle=120, watch=False, shot=f"FL23-06_{nm}",
                  execs=[376553, 376749, 376769, 376950, 376581 if False else 376788, 376793])
        print(brief(r, limit=4))
        print("   actors1:", [(x["file"], hex(x["off"]) if "off" in x else None, x["x"], x["y"], hex(x.get("chat", 0)), hex(x["f10"])) for x in r["actors1_named"] if "fr3C" in x["file"]])
finally:
    m.close()
