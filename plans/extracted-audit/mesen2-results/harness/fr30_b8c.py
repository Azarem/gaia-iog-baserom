#!/usr/bin/env python3
"""FR30 batch 8c: FL11-04 follow-up. Same-scene reload (47 -> 47) with the flag cleared kept the copied effect layer. Test a reload through another scene:
tmp state (scene $2F loaded with flag $0120 set) -> clear the flag, load scene $2E -> state saved (H1) -> load scene $2F: effect layer rectangle compared with the control."""
import json
from fr30_lib import *  # noqa: F401,F403
from fr30_b8 import E, load, cmp_rect
import fr20_lib as L

n = 0x20
e = E[n]
m, info = open_o()
try:
    ctl = load(m, info, "eb20_via_control", n, [])
    frc = load(m, info, "eb20_via_forced", n, [288])
    p1 = tmp_state("eb20_forced_loaded")
    m.call("load_state_file", path=p1)  # saved by fr30_b8b (valid, H1 passed there)
    ok, h = L.h1(m, p1)
    print("H1 p1", ok)
    rects = "R.dst=fr30.rect(%d,%d,%d,%d,1); R.src=fr30.rect(%d,%d,%d,%d,1)" % (e["dx"], e["dy"], e["w"], e["h"], e["sx"], e["sy"], e["w"], e["h"])
    hooks = drive(at="[3]=function(R,k) %s end" % rects, adv=False) + ",final=function(R) R.fl=fr30.bytes(0x0A20,8) end"
    mid = visit(m, info, "eb20_via_other_scene_2E", p1, shot="eb20_via_other", scene=46, clear=[288], settle=40, watch=False, hooks=hooks)
    p2 = tmp_state("eb20_via_other")
    m.call("save_state_file", path=p2, note="FR30 disposable: scene $2E loaded, flag $0120 cleared", meta={})
    ok2, h2 = L.h1(m, p2)
    print("H1 p2", ok2, "scene", h2["scene"], "mid fl", mid.get("fl"), "err", mid.get("error"))
    back = visit(m, info, "eb20_via_back_2F", p2, shot="eb20_via_back", scene=47, settle=40, watch=False, hooks=hooks)
    print("back dst vs control dst", cmp_rect(back["dst"], ctl["dst"]), "vs src", cmp_rect(back["dst"], ctl["src"]), "fl", back.get("fl"), "err", back.get("error"), "d36", back.get("d36"))
    print("forced vs control", cmp_rect(frc["dst"], ctl["dst"]))
finally:
    m.close()
