#!/usr/bin/env python3
"""FR23 batch 0: identity, H1 validity on the states used, standing flag-63 control (start / end of the step)."""
import json
import sys
from fr23_lib import *  # noqa: F401,F403
import fr20_lib as L

tag = sys.argv[1] if len(sys.argv) > 1 else "start"
m, info = open_o()
try:
    out = {"rom": {k: info[k] for k in ("path", "fileSizeBytes", "fileSha1", "fileCrc32")}}
    print("ROM", json.dumps(out["rom"]))
    for nm, st in (("S01r", S01R), ("N02", N02), ("N03", N03)):
        ok, r = L.h1(m, st)
        out["h1_" + nm] = {"ok": ok, **{k: r[k] for k in ("w36", "k", "sp", "scene", "mask")}}
        print("H1", nm, ok, out["h1_" + nm])
    ok, sc = L.standing_control(m, info, tag="_FR23" + tag)
    out["standing"] = {"ok": ok, **sc}
    print("STANDING", ok, json.dumps(sc))
    store("b0_identity_h1_standing_" + tag, out)
finally:
    m.close()
