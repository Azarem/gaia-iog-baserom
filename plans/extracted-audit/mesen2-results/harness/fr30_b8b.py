#!/usr/bin/env python3
"""FR30 batch 8b: FL11-04 reload sequence for flag $0120 (event block $20, scene $2F, layer 1). Forced load from S01r (flag set) -> state saved to a disposable tmp state
(H1 validity test) -> reload scene $2F with the flag still set (picture unchanged) -> reload with the flag cleared (picture equals the control). Compared on the effect layer
(effectLayerTilemap, 32x16 at (0,0))."""
import json
from fr30_lib import *  # noqa: F401,F403
from fr30_b8 import E, load, cmp_rect
import fr20_lib as L

n = 0x20
m, info = open_o()
try:
    ctl = load(m, info, "eb20_rl_control", n, [])
    frc = load(m, info, "eb20_rl_forced", n, [288], shot="eb20_rl_forced")
    path = tmp_state("eb20_forced_loaded")
    m.call("save_state_file", path=path, note="FR30 disposable: scene $2F loaded with flag $0120 set", meta={})
    ok, h = L.h1(m, path)
    print("H1 tmp state", ok, h["k"], h["sp"], h["w36"], h["scene"])
    keep = load(m, info, "eb20_rl_reload_flag_kept", n, [], shot="eb20_rl_reload_kept") if False else None
    e = E[n]
    def reload(name, clearf, shot):
        rects = "R.dst=fr30.rect(%d,%d,%d,%d,1); R.src=fr30.rect(%d,%d,%d,%d,1)" % (e["dx"], e["dy"], e["w"], e["h"], e["sx"], e["sy"], e["w"], e["h"])
        hooks = drive(at="[3]=function(R,k) %s end" % rects, adv=False) + ",final=function(R) R.fl=fr30.bytes(0x0A20,8) end"
        return visit(m, info, name, path, shot=shot, scene=e["scene"], clear=clearf, settle=40, watch=False, hooks=hooks)
    r_keep = reload("eb20_rl_reload_flag_kept", [], "eb20_rl_reload_kept")
    r_clr = reload("eb20_rl_reload_flag_cleared", [288], "eb20_rl_reload_cleared")
    print("control vs forced dst", cmp_rect(ctl["dst"], frc["dst"]), "forced dst vs src", cmp_rect(frc["dst"], ctl["src"]))
    print("reload (flag kept) dst vs forced dst", cmp_rect(r_keep["dst"], frc["dst"]), "fl", r_keep.get("fl"), "err", r_keep.get("error"))
    print("reload (flag cleared) dst vs control dst", cmp_rect(r_clr["dst"], ctl["dst"]), "vs src", cmp_rect(r_clr["dst"], ctl["src"]), "fl", r_clr.get("fl"), "err", r_clr.get("error"))
    print("d36", r_keep.get("d36"), r_clr.get("d36"), "shots", r_keep.get("screenshot"), r_clr.get("screenshot"))
finally:
    m.close()
