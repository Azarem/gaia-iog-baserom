#!/usr/bin/env python3
"""R1 probe: does the CDL and do the native counters survive load_state_file? What does get_access_summary(rangesPath) return?
Reads only; writes raw/R1_probe.json."""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from a_common import open_session, STATE_DIR, RAW  # noqa: E402

m, info = open_session()
out = {"rom": info}
try:
    st = os.path.join(STATE_DIR, "orig_S06_title.mss")
    r = m.call("load_state_file", path=st)
    out["load"] = {k: r.get(k) for k in ("romCheck", "stateRomSha1")}
    m.call("reset_cdl")
    m.call("reset_access_counters")
    out["cdl0"] = m.call("get_cdl_statistics")
    m.call("advance_frame", frames=300)
    out["cdl1"] = m.call("get_cdl_statistics")
    req = os.path.join(RAW, "R1_ranges_req.json")
    a = m.call("get_access_summary", type="prgRom", rangesPath=req, cdl=True)
    out["acc_keys"] = list(a.keys()) if isinstance(a, dict) else str(type(a))
    rows = a.get("ranges", a.get("rows", []))
    out["acc_nrows"] = len(rows)
    out["acc_row0"] = rows[0] if rows else None
    out["acc_ctrl"] = rows[-1] if rows else None
    out["acc_hdr"] = {k: v for k, v in a.items() if k not in ("ranges", "rows")}
    # reload and see what happens to counters and CDL
    m.call("load_state_file", path=st)
    out["cdl_after_load"] = m.call("get_cdl_statistics")
    b = m.call("get_access_summary", type="prgRom", rangesPath=req, cdl=True)
    rows2 = b.get("ranges", b.get("rows", []))
    out["acc_ctrl_after_load"] = rows2[-1] if rows2 else None
    out["cdl_summary"] = m.call("get_cdl_data", format="summary")
finally:
    json.dump(out, open(os.path.join(RAW, "R1_probe.json"), "w"), indent=1, default=str)
    m.close()
print(json.dumps(out, indent=1, default=str)[:6000])
