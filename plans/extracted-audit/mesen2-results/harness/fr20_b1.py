#!/usr/bin/env python3
"""FR20 batch 1: FL20-01 (flag $10, scene 8 school lesson)."""
import json
from fr20_lib import *  # noqa: F401,F403

m, info = open_o()
try:
    # control: $10 clear at load (base N01 has it set; clear it before the warp), no input after the banner
    r = visit(m, info, "FL20-01_ctl_noinput", N01, shot="FL20-01_ctl", scene=8, clear=[16], settle=150, watch=True)
    print(summarize(r))
    # control, natural run of the lesson: mash A (physical A = logical interact $0080) until the lesson ends
    r = visit(m, info, "FL20-01_ctl_mashA", N01, shot="FL20-01_ctl_end", scene=8, clear=[16], settle=2400, watch=True,
              mash={"button": "a", "from": 1, "to": 2400, "down": 2, "gap": 10})
    print(summarize(r))
    # forced: $10 set at load
    r = visit(m, info, "FL20-01_forced", N01, shot="FL20-01_forced", scene=8, set=[16], settle=150, watch=True)
    print(summarize(r))
finally:
    m.close()
