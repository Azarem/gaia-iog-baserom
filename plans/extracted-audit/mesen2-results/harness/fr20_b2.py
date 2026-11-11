#!/usr/bin/env python3
"""FR20 batch 2: scene 2 and scene 6 load trials (FL20-02, 03, 04, 07, 09, 10). Base N01 for scene 2, N02 for scene 6."""
import sys
from fr20_lib import *  # noqa: F401,F403

m, info = open_o()
W = lambda *a, **k: print(summarize(visit(m, info, *a, **k)))
try:
    # --- scene 2 (base N01: $10 set; $15 set in every run so the arrival narration does not lock the joypad)
    base2 = dict(scene=2, settle=120, watch=True, maskwatch=True)
    W("FL20-02_s2_ctl", N01, shot="FL20-02_s2_ctl", set=[21], clear=[22, 76, 32], **base2)
    W("FL20-02_s2_forced16", N01, shot="FL20-02_s2_f16", set=[21, 22], clear=[76, 32], **base2)
    W("FL20-07_s2_forced4C", N01, shot="FL20-07_s2_f4C", set=[21, 76], clear=[22, 32], **base2)
    W("FL20-10_s2_forced20", N01, shot="FL20-10_s2_f20", set=[21, 32], clear=[22, 76], **base2)
finally:
    m.close()
