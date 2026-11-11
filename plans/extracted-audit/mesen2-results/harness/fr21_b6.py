#!/usr/bin/env python3
"""FR21 batch 6: FL23-05 ($68 = flag 104): Memory Melody (item $0D) in scene $39 on tile (13,18): control ($68 clear) and forced ($68 set)."""
from fr21_lib import *  # noqa: F401,F403

m, info = open_o()
REC = "{ {name='f0F',addr=0x0A01,bit=0x80},{name='f68',addr=0x0A0D,bit=0x01},{name='mask',addr=0x065A,size=2},{name='slot0',addr=0x0AB4},{name='dmf',addr=0x09EC,size=2},{name='tx',addr=0x09A6,size=2},{name='ty',addr=0x09A8,size=2} }"
EX = [233327, 233336, 233341, 378789, 378843]
try:
    for nm, setf in (("ctl", [101]),):
        r = visit(m, info, f"FL23-05_mel3_{nm}", S01R, scene=0x39, set=setf, settle=6600, teleport=[312, 408], watch=True, execs=EX,
                  hold={12: ["y"], 13: ["y"], 14: ["y"]}, mash={"button": "b", "from": 60, "to": 6500, "down": 2, "gap": 8},
                  hooks=f"onSample=fr21.drive{{ rec={REC}, at={{ [5]=function(R,n) fr21.item(0x0D,0) end }}, every=function(R,n) if n%40==0 then R.s=R.s or {{}}; end end }}",
                  shot=f"FL23-05_mel3_{nm}")
        print(brief(r, keys=("f0F", "f68", "mask", "slot0", "tx", "ty"), limit=24))
finally:
    m.close()
