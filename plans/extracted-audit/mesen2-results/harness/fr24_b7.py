#!/usr/bin/env python3
"""FR24 batch 7: FL28-12 ($FF latch, native_village_sine_hdma in 172 and dao_sine_hdma_slow in 195)."""
import sys
from fr24_lib import *  # noqa: F401,F403

which = [w for w in sys.argv[1:] if not w.startswith("-")]
m, info = open_o()
REC = [flagrec(255, "fFF"), ("tab", 0x8C00, None, 2)]
CLR = "[60]=function(R,n) kit.w8(0x0A1F, kit.r8(0x0A1F) & 0x7F) end"
try:
    for key, scene, ex, forced in (("L0", 172, [48884, 48898, 48904], False), ("L1", 172, [48884, 48898, 48904], True),
                                   ("L2", 195, [48851, 48865, 48871], False), ("L3", 195, [48851, 48865, 48871], True)):
        if key in which:
            show(trial(m, info, "FL28-12_%s_s%d_%s" % (key, scene, "clearFF" if forced else "ctl"), scene, set_=([172, 173, 174, 175, 176, 178] if scene == 172 else [182]),
                       settle=140, execs=ex, rec=REC, at=(CLR if forced else "[60]=function(R,n) end"), shot=None), rec_limit=14)
finally:
    m.close()
