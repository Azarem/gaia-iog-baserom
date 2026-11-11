#!/usr/bin/env python3
"""FR21 batch 2c: FL22-04 Blue Block on tile X $0F (the CMP #$000F fall-through): dialog text screenshot and flag."""
from fr21_lib import *  # noqa: F401,F403

m, info = open_o()
try:
    for nm, tp in (("x0F_y19", [248, 424]), ("x10_y19", [264, 424]), ("x0D_y19", [216, 424])):
        r = visit(m, info, f"FL22-04_dlg_{nm}", S01R, scene=0x25, settle=45, teleport=tp, watch=True, execs=[231800, 231737],
                  hold={6: ["y"], 7: ["y"], 8: ["y"]}, hooks="onSample=fr21.drive{ at={ [4]=function(R,n) fr21.item(7,0); R.t=fr21.tile() end } }", shot=f"FL22-04_dlg_{nm}")
        print(brief(r, limit=4), r.get("t"))
finally:
    m.close()
