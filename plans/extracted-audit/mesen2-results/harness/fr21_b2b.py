#!/usr/bin/env python3
"""FR21 batch 2b: FL22-04 collision cells around the ceiling tiles (x 8..12, y 25..31) before and after the placement, versus control."""
from fr21_lib import *  # noqa: F401,F403

m, info = open_o()
CELLS = [[x, y] for y in range(25, 32) for x in range(8, 13)] + [[15, 27], [15, 28], [14, 25], [14, 26]]
REC = "{ {name='f2F',addr=0x0A05,bit=0x80},{name='mask',addr=0x065A,size=2} }"
try:
    res = {}
    for nm, use in (("ctl", False), ("forced", True)):
        at = "{ [4]=function(R,n) fr21.item(7,0) end }" if use else "{}"
        r = visit(m, info, f"FL22-04_cells_{nm}", S01R, scene=0x25, settle=560, teleport=[232, 424], watch=True, cells=CELLS,
                  hold=({6: ["y"], 7: ["y"], 8: ["y"]} if use else {}), mash={"button": "b", "from": 60, "to": 120, "down": 2, "gap": 20},
                  hooks=f"onSample=fr21.drive{{ rec={REC}, at={at} }}", shot=f"FL22-04_cells_{nm}")
        res[nm] = r
        print(brief(r, keys=("f2F", "mask"), limit=6))
    for nm in res:
        r = res[nm]
        print(nm, "changed cells:", [(CELLS[i], r["cells0"][i], r["cells1"][i]) for i in range(len(CELLS)) if r["cells0"][i] != r["cells1"][i]])
finally:
    m.close()
