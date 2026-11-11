#!/usr/bin/env python3
"""FR30 batch 10b: scene $65 (FL10-13) had no VRAM difference with flag $7E set. Compare WRAM map layers (0xA000-0xFFFF: map layer, effect layer) instead of VRAM, with flag $7E, flags $7B+$7E and none."""
import json
from fr30_lib import *  # noqa: F401,F403

SUM = ("final=function(R) local s={0,0,0}; for i=0,0x1FFF do local a=kit.r8(0xA000+i); local b=kit.r8(0xC000+i); s[1]=(s[1]*31+a)&0xFFFFFFF; s[2]=(s[2]*31+b)&0xFFFFFFF end "
       "R.sumMap=s[1]; R.sumFx=s[2] end")
m, info = open_o()
try:
    for scene in (0x65, 0x64):
        out = {}
        for k, setf in (("ctl", []), ("f126", [126]), ("f123_126", [123, 126]), ("f123", [123])):
            r = visit(m, info, f"s{scene:02X}_{k}", S01R, shot=f"s{scene:02X}_{k}", scene=scene, set=setf, settle=60, watch=False, hooks=SUM)
            out[k] = (r.get("sumMap"), r.get("sumFx"), r.get("error"), r.get("screenshot"))
            print("scene", hex(scene), k, out[k])
finally:
    m.close()
