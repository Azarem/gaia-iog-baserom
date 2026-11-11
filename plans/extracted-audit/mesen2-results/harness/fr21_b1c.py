#!/usr/bin/env python3
"""FR21 batch 1c: talk-bot calibration in scene $18 (it18_warning_man at 152,160, talk handler code_04DDC2 = 318914): which button, which offset."""
from fr21_lib import *  # noqa: F401,F403

m, info = open_o()
REC = "{ {name='mask',addr=0x065A,size=2},{name='dmf',addr=0x09EC,size=2},{name='pf',addr=0x09AE,size=2},{name='px',addr=0x1014,size=2},{name='py',addr=0x1016,size=2} }"
try:
    for nm, tp, held, btn in (("a_w16", [136, 160], "right", "a"), ("b_w16", [136, 160], "right", "b"), ("y_w16", [136, 160], "right", "y"), ("x_w16", [136, 160], "right", "x"),
                              ("a_walkin", [100, 160], "right", "a")):
        r = visit(m, info, f"FL22-01_talkcal_{nm}", S01R, scene=0x18, settle=90, teleport=tp, watch=True, execs=[318914],
                  walk=[[3, 90, [held]]], mash={"button": btn, "from": 10, "to": 80, "down": 2, "gap": 8},
                  hooks=f"onSample=fr21.drive{{ rec={REC} }}")
        rows = [x for x in r["rec"] if "mask" in x or ("dmf" in x and x["dmf"] not in (0, 8))]
        print(nm, "pos", r["pos"], "dmf1", hex(r["dmf1"]), "execs", r["execs"], "rows", rows[:6])
finally:
    m.close()
