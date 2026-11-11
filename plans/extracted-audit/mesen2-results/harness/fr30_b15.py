#!/usr/bin/env python3
"""FR30 batch 15: FL13-RADAR. Scenes $0C (tier 1), $0D (tier 2), $0E (tier 3): Start opens the radar at settle frame 15; control flag $0300+scene clear, forced set.
Exec marks: RadarScreenSetup 229567, the radar's TestFlag_0300 site 229828. Screenshot of each radar."""
import json
import hashlib
import os
from fr30_lib import *  # noqa: F401,F403

EX = [229567, 229828]


def radar(m, info, name, scene, setf):
    every = "function(R,n) if n==15 or n==16 then fr21.press(R,{'start'}) end if n>=100 then R.stop=true end end"
    hooks = drive(every=every, adv=False) + ",final=function(R) R.sceneEnd2=kit.r16(0x0644); R.fl=fr30.bytes(0x0A60,6) end"
    return visit(m, info, name, S01R, shot=name, scene=scene, set=setf, settle=110, watch=False, hooks=hooks, execs=EX)


m, info = open_o()
try:
    for scene in (12, 13, 14):
        flag = 0x300 + scene
        out = {}
        for k, setf in (("ctl", []), ("frc", [flag]), ("ctl2", []), ("frc2", [flag])):
            r = radar(m, info, f"radar_s{scene:02X}_{k}", scene, setf)
            p = os.path.join(BASEROM, r["screenshot"])
            out[k] = (hashlib.sha1(open(p, "rb").read()).hexdigest()[:10], r["screenshot"], r.get("execs"), r.get("fl"), r.get("error"), r.get("sceneEnd2"))
        print("scene", hex(scene), "flag", flag)
        for k, v in out.items():
            print("  ", k, v[0], v[5], "err", v[4], "execs", json.dumps(v[2]), "fl", v[3], v[1][-34:])
        print("   repeat equal: ctl", out["ctl"][0] == out["ctl2"][0], "forced", out["frc"][0] == out["frc2"][0], "ctl != forced", out["ctl"][0] != out["frc"][0])
finally:
    m.close()
