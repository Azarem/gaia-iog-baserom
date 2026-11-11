#!/usr/bin/env python3
"""FR20 batch 8: scene 0B prison (FL21-02, 03, 08, 10)."""
from fr20_lib import *
from collections import Counter
m, info = open_o()
CELLS = [[9, 23], [20, 23], [10, 23], [19, 23], [8, 23], [21, 23]]
try:
    for nm, on, off in (("ctl", [33, 35], [36, 66, 67]), ("f24", [33, 35, 36], [66, 67]), ("f42", [33, 35, 66], [36, 67]), ("f43", [33, 35, 67], [36, 66]), ("f42_43", [33, 35, 66, 67], [36])):
        r = visit(m, info, f"FL21-B8_s0B_{nm}", N03, scene=0x0B, set=on, clear=off, settle=300, watch=True, cells=CELLS, execs=[318208, 318219], shot=f"FL21-B8_s0B_{nm}")
        a = r["actors0_named"]
        c = Counter((x["file"]) for x in a if x["file"] not in ("camera_scroll", "camera_scroll_controller", "player_character", "player_move_controller", "slope_ramp_physics"))
        print(f"== {nm}: end={r['sceneEnd']:02X} mask0={r['mask0']:04X} cells0={r['cells0']} cells1={r['cells1']}")
        print("   actors:", dict(c))
        print("   execs 318208 (AdhocVramDma COP)/318219 (BranchOnFlag #00):", r["execs"]["318208"], r["execs"]["318219"])
        print("   FW:", [(x['f'], hex(x['a']), x['old'], x['new']) for x in r['fw']['rows']][:8])
        print("   $0106 byte $0A20:", r["flags1"][0x20 * 2:0x20 * 2 + 2], "$0A04:", r["flags1"][8:10], "$0A08:", r["flags1"][16:18])
finally:
    m.close()
