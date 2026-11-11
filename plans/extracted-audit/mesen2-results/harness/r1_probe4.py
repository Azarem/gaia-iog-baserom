#!/usr/bin/env python3
"""R1 probe 4 (ROM O): which code reads bytes 2..N of the unreferenced thinker lists 0CE9EA (846315..846330) and 0CEA45 (846406..846417) in the Will sweep (post 600 frames, with the sweep input)?
The R1 counters showed all 17 / 13 bytes touched in sweep chunk 06 (scenes $4D-$59), while the post-40 probe (r1_probe3.py) read the first byte only.
usage: python r1_probe4.py     -> raw/R1_probe_thinker_sweep.json   (runs the sweep chunk of R1 with read callbacks; the sweep Lua of r1_run.py plus the callbacks)
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from a_common import open_session, S01R  # noqa: E402
import r1_probe2 as P  # noqa: E402
import r1_run as RR  # noqa: E402

CB = P.HDR + r"""
local T = {}
local function mk(tag) return function(addr, v)
  local st = emu.getState()
  local k = tag .. ":" .. addr .. ":" .. string.format("%02X:%04X", st["cpu.k"], st["cpu.pc"])
  local e = T[k]
  if not e then
    e = { n = 0, sc = kit.r16(0x0644) & 0xFF, ix = kit.r16(0x0646), n36 = kit.r16(0x36), v = v, a = st["cpu.a"], x = st["cpu.x"], y = st["cpu.y"] }
    T[k] = e
  end
  e.n = e.n + 1
end end
emu.addMemoryCallback(mk("E9"), emu.callbackType.read, 846315, 846330, CPU, PRG)
emu.addMemoryCallback(mk("EA"), emu.callbackType.read, 846406, 846417, CPU, PRG)
"""


def main():
    ids = [0x4D, 0x4E, 0x4F, 0x50, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x58, 0x59]
    body = RR.SWEEP_LUA % dict(form=0, post=600, ids=",".join(str(i) for i in ids))
    body = body.replace("kit.finish({ scenes = #per, timeouts = table.concat(to, ','), form = FORM })", "kit.finish({ scenes = #per, T = T })")
    lua = CB + body
    m, info = open_session()
    print("ROM", info["fileSha1"], flush=True)
    try:
        o = P.run(m, "thinker_sweep", S01R, lua, 60000, includes=("e2_palette", "gaia_kit"))
        T = o["result"].get("T", {})
        print("scenes", o["result"].get("scenes"), "keys", len(T))
        for k in sorted(T):
            e = T[k]
            print(k, "n", e["n"], "scene", "%02X" % e["sc"], "$0646", e["ix"], "n36", e["n36"], "v", e.get("v"), "A/X/Y", e["a"], e["x"], e["y"])
    finally:
        m.close()


if __name__ == "__main__":
    main()
