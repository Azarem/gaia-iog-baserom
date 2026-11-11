#!/usr/bin/env python3
"""G4 tier watch: load a state, H1 validity test, then g4.tier (kit/lib/g4_runs.lua) for N NMI frames.

usage: python g4_tier.py <state file name in rebuilt/states> <frames> <out name>
output: raw/G4_tier_<out>.json
"""
import json
import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
from a_common import open_session, RAW, STATE_DIR  # noqa: E402

H1 = ("local c=0 emu.addMemoryCallback(function(a) c=c+1 end, emu.callbackType.write,0x36,0x36,emu.cpuType.snes,emu.memType.snesWorkRam)"
      " local n=0 kit.onFrame(function() n=n+1 if n==120 then local s=emu.getState() kit.finish({k=s['cpu.k'],sp=s['cpu.sp'],scene=kit.r16(0x644),c36=c}) end end)")


def main():
    state, frames, out = sys.argv[1], int(sys.argv[2]), sys.argv[3]
    pulses = sys.argv[4] if len(sys.argv) > 4 else "nil"      # Lua table text, e.g. {{t=60,btn={'a'},len=3}}
    m, info = open_session()
    print("rom", info["fileSha1"], info["fileSizeBytes"], info["fileCrc32"])
    st = m.call("load_state_file", path=os.path.join(STATE_DIR, state))
    print("state romCheck", st.get("romCheck"))
    h1 = m.run_script_checked(H1, frames=130, turbo=True, includes=["gaia_kit"], name="g4_h1", maxLog=2)
    print("H1", h1["result"])
    m.call("load_state_file", path=os.path.join(STATE_DIR, state))
    r = m.run_script_checked(f"g4.tier{{ frames = {frames}, cap = 60, pulses = {pulses} }}", frames=frames * 3 + 600, turbo=True,
                             includes=["gaia_kit", "a_census", "a_actors", "g1_kit", "g2_kit", "g4_kit", "g4_runs"], name="g4_tier", maxLog=1)
    res = r["result"]
    with open(os.path.join(RAW, f"G4_tier_{out}.json"), "w") as f:
        json.dump(res, f, indent=1)
    print(json.dumps({k: res[k] for k in ("tier", "finalTiers", "readExec", "control36", "t")}, indent=1))
    m.close()


if __name__ == "__main__":
    main()
