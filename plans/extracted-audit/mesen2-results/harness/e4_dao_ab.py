#!/usr/bin/env python3
"""E4 Dao rectangle A/B: two runs from orig_E4_dao.mss, window as the game sets it vs W12SEL forced to 0; screenshots at the same frame; diff inside and outside the rectangle."""
import sys
sys.path.insert(0, ".")
import e4_run as r
import e4_png as P

paths = {}
for tag, ov in (("on", "nil"), ("off", "0")):
    m, info = r.open_session()
    m.call("load_state_file", path=r.sp("orig_E4_dao.mss"))
    code = open("e4_dao_ab.lua").read().replace("DAO_OVERRIDE", ov)
    m.call("load_script", code=code, name="dbg", includes=r.INC)
    m.call("advance_frame", frames=130, turbo=True)
    paths[tag] = m.shot("E4_dao_ab_" + tag).get("path")
    print(tag, paths[tag])
    m.close()
a, b = P.read_png(paths["on"]), P.read_png(paths["off"])
inside = outside = 0
for y in range(239):
    for x in range(256):
        if P.pix(a, x, y) != P.pix(b, x, y):
            if 96 <= x <= 159 and 107 <= y <= 154:
                inside += 1
            else:
                outside += 1
print("pixels different inside the rectangle (x96-159, y107-154):", inside, " outside:", outside)
