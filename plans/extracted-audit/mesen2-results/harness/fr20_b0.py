#!/usr/bin/env python3
"""FR20 batch 0: ROM identity, H1 validity of the states used, the standing control (scene 0A with and without flag 63).
usage: timeout 600 python fr20_b0.py
"""
import json
import sys

from fr20_lib import *  # noqa: F401,F403

m, info = open_o()
try:
    print("ROM", info["path"], info["fileSizeBytes"], info["fileSha1"], info["fileCrc32"])
    out = {"rom": {k: info[k] for k in ("path", "fileSizeBytes", "fileSha1", "fileCrc32")}, "h1": {}}
    for name, st in (("N01", N01), ("N02", N02), ("N03", N03), ("S01r", S01R)):
        ok, r = h1(m, st)
        out["h1"][name] = {"ok": ok, **r}
        print("H1", name, ok, r)
    ok, sc = standing_control(m, info, "_b0")
    out["standing"] = {"ok": ok, **sc}
    print("STANDING", ok, json.dumps(sc))
    store("b0_identity_h1_standing", out)
finally:
    m.close()
