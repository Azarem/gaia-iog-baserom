#!/usr/bin/env python3
"""FR20 batch 4: FL20-05, FL20-06 natural cutscene control vs forced; scene 1 narration with $26."""
import sys
from fr20_lib import *  # noqa: F401,F403
m, info = open_o()
ALL = [22, 27, 28, 29, 33, 37, 38, 61, 62, 281]
def cfg(*on): return dict(set=list(on), clear=[n for n in ALL if n not in on])
MORN = (22, 27, 61, 62, 28, 29)
def W(name, st, **k):
    print(summarize(visit(m, info, name, st, shot=name, **k)))
try:
    W("FL20-05_ctl_castle_mashA", N02, scene=6, settle=1500, watch=True, maskwatch=True, **cfg(*MORN, 33, 281),
      mash={"button": "a", "from": 1, "to": 1500, "down": 2, "gap": 10})
    W("FL20-05_forced_25_ransacked", N02, scene=6, settle=120, watch=True, maskwatch=True, vram=True, **cfg(*MORN, 33, 37, 281))
    W("FL20-06_ctl_depart_mashA", N02, scene=6, settle=2400, watch=True, maskwatch=True, **cfg(*MORN, 33, 37),
      mash={"button": "a", "from": 1, "to": 2400, "down": 2, "gap": 10})
    s1 = dict(scene=1, settle=200, watch=True, maskwatch=True, teleport=[0x208, 0xE0])
    W("FL20-06_s1_ctl26clear", N01, set=[33], clear=[38, 18], **s1)
    W("FL20-06_s1_forced26", N01, set=[33, 38], clear=[18], **s1)
finally:
    m.close()
