#!/usr/bin/env python3
"""FR30 batch 11: FL10-08 / FL14-TOMB. Scene $88 (Great Wall tomb): gw88_tomb_dark_space tests byte $0A9F == $3F every frame; then StageBgChange #74 + ApplyBgChange and SetFlagWord $0174 (372).
Control $0A9F = $00 and $3E, forced $3F, and $7F (a superset: must not fire if the test is equality). Recorded after 150 settle frames: flag 372, the event-block $74 destination rectangle, actor list."""
import json
import sys
from fr30_lib import *  # noqa: F401,F403
from fr30_b8 import E, cmp_rect

e = E[0x74]
print("entry $74", e)
m, info = open_o()
try:
    res = {}
    for k, val in (("v00", 0x00), ("v3E", 0x3E), ("v3F", 0x3F), ("v7F", 0x7F), ("v3F_repeat", 0x3F), ("v00_repeat", 0x00)):
        rects = "R.dst=fr30.rect(%d,%d,%d,%d,%d); R.src=fr30.rect(%d,%d,%d,%d,%d)" % (e["dx"], e["dy"], e["w"], e["h"], e["layer"], e["sx"], e["sy"], e["w"], e["h"], e["layer"])
        hooks = drive(at="[3]=function(R,k) %s end" % rects, adv=False,
                      rec=[("f372", 0x0A2E, 0x10, 1), ("a9f", 0x0A9F, None, 1)]) + ",final=function(R) R.dstEnd=fr30.rect(%d,%d,%d,%d,%d); R.f372=gaia.flags.get(372); R.a9f=kit.r8(0x0A9F) end" % (e["dx"], e["dy"], e["w"], e["h"], e["layer"])
        r = visit(m, info, f"tomb_{k}", S01R, shot=f"tomb_{k}", scene=e["scene"], pre=[[0x0A9F, val]], settle=150, watch=False, hooks=hooks)
        res[k] = r
        names = [a["file"] for a in (r.get("actors1_named") or []) if "tomb" in a["file"] or "dark_space" in a["file"]]
        rec = [x for x in (r.get("rec") or []) if "f372" in x]
        print(k, "scene", r.get("scene"), "err", r.get("error"), "flag372@end", r.get("f372"), "a9f", hex(r.get("a9f") or 0), "d36", r.get("d36"), "tomb/darkspace actors", names, "rec", json.dumps(rec[:4]))
        print("   dst@arrival", r["dst"]["map"][:40], "dst@end", r["dstEnd"]["map"][:40], "src", r["src"]["map"][:40])
    print("dst end 3F vs 00:", cmp_rect(res["v3F"]["dstEnd"], res["v00"]["dstEnd"]), "3F dst vs src(00):", cmp_rect(res["v3F"]["dstEnd"], res["v00"]["src"]))
finally:
    m.close()
