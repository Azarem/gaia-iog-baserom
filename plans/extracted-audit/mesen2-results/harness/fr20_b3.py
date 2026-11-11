#!/usr/bin/env python3
"""FR20 batch 3: scene 6 phases (FL20-02 half, 03, 04, 05, 06, 09). Base N02 (scene 6 morning)."""
import sys
from fr20_lib import *  # noqa: F401,F403

m, info = open_o()
ALL = [22, 27, 28, 29, 33, 37, 38, 61, 62, 281]
def cfg(*on):
    return dict(set=list(on), clear=[n for n in ALL if n not in on])
PH = {
  "ARR": cfg(), "EVE": cfg(22), "AFTER1B": cfg(22, 27, 61), "DINNER": cfg(22, 27, 61, 62),
  "NIGHT": cfg(22, 27, 61, 62, 28), "MORNING": cfg(22, 27, 61, 62, 28, 29), "CASTLE": cfg(22, 27, 61, 62, 28, 29, 33),
  "DEPART": cfg(22, 27, 61, 62, 28, 29, 33, 37), "TRIP": cfg(22, 27, 61, 62, 28, 29, 33, 37, 38),
  "MORNING_RANSACKED": cfg(22, 27, 61, 62, 28, 29, 281),
}
def W(name, ph, extra=None, **k):
    d = dict(scene=6, settle=120, watch=True, maskwatch=True, cells=[[5, 29], [6, 29]], vram=True)
    d.update(PH[ph]); d.update(k)
    print(summarize(visit(m, info, name, N02, shot=name, **d)))
try:
    only = sys.argv[1:] 
    for ph in ("ARR", "EVE", "AFTER1B", "DINNER", "NIGHT", "MORNING", "CASTLE", "DEPART", "TRIP", "MORNING_RANSACKED"):
        W(f"S6_{ph}", ph)
finally:
    m.close()
