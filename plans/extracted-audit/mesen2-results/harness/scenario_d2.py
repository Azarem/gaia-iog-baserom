#!/usr/bin/env python3
"""D2 SPC-side trace driver: opens its own server session (a Cursor tool call times out after about a minute, the SPC census
takes longer), loads O, the S01r state, runs one Lua scenario from a file with the d2_spc kit module and stores the reply.

usage: [ROM=<path> LABELS=<mlb or empty>] timeout 900 python scenario_d2.py <scenario.lua> <result-name> [frames] [state]
ROM defaults to O; for R pass ROM=rebuilt/variants/plain.smc LABELS= and the state R-b2_S01r_south-cape-ready.mss
The Lua file is passed verbatim as `code`; includes are gaia_kit and d2_spc. Nothing here edits the baserom.
"""
import json
import os
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from a_common import open_session, RAW, STATE_DIR, S01R, ROM_O, LABELS_O  # noqa: E402


def main():
    lua_path, name = sys.argv[1], sys.argv[2]
    frames = int(sys.argv[3]) if len(sys.argv) > 3 else 700
    state = sys.argv[4] if len(sys.argv) > 4 else S01R
    code = open(lua_path, encoding="utf-8").read()
    rom = os.environ.get('ROM', ROM_O)
    labels = os.environ.get('LABELS', LABELS_O) or None
    m, info = open_session(rom, labels)
    try:
        caps = m.call("get_capabilities")
        rinfo = m.call("get_rom_info")
        st = m.call("load_state_file", path=state)
        t0 = time.time()
        r = m.run_script_checked(code, includes=["gaia_kit", "d2_spc"], frames=frames, turbo=True, name="d2_run",
                                 maxLog=int(os.environ.get("MAXLOG","3")), timeoutMs=800000)
        out = {"server": caps.get("serverVersion"), "rom": info, "romInfo": rinfo, "state": {k: st.get(k) for k in ("path", "romCheck", "frame")},
               "elapsedS": round(time.time() - t0, 1), "reply": r}
        os.makedirs(RAW, exist_ok=True)
        path = os.path.join(RAW, f"{name}.json")
        with open(path, "w", encoding="utf-8") as fh:
            json.dump(out, fh, indent=1)
        res = r.get("result") or {}
        print("saved", path, "elapsed", out["elapsedS"], "s; stop", r.get("stopReason"), "frames", r.get("framesAdvanced"))
        print("control", json.dumps(res.get("control")))
        print("final", json.dumps(res.get("final")), json.dumps(res.get("atFrames")), json.dumps(res.get("atVals")))
        print("counts", json.dumps(res.get("counts")))
        for line in (res.get("events") or [])[:12]:
            print(line)
    finally:
        m.close()


if __name__ == "__main__":
    main()
