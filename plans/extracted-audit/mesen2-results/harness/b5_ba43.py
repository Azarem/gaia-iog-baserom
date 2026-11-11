#!/usr/bin/env python3
"""BA-43: displayModeFlags $09EC per frame during a B press, ROM O (S01r) versus R-plain (R-plain_S01r), 5 repeats each, B pressed from frame P for 30 frames,
P in {20, 40}. Records the full 90-frame sequence of $09EC and the first frame where it differs from its value at frame 0."""
import json
import sys
sys.path.insert(0, ".")
from b5_common import *
from mcp_client import Mesen

R_ROM = os.path.join(BASEROM, "rebuilt", "Illusion of Gaia - Rebuilt.smc")
R_ST = st("R-b2_S01r_south-cape-ready.mss")

LUA = r"""
local P = %(p)d
local n = 0
local seq, ctl = {}, 0
emu.addMemoryCallback(function(a, v) if (a & 0xFFFF) == 0x36 then ctl = ctl + 1 end end, emu.callbackType.write, 0x36, 0x36, emu.cpuType.snes, emu.memType.snesWorkRam)
emu.addEventCallback(function()
  local t = {}
  if n >= P and n < P + 30 then t["b"] = true end
  if %(dir)s and n >= 10 then t[%(dir)s] = true end
  emu.setInput(t, 0)
end, emu.eventType.inputPolled)
kit.onFrame(function()
  n = n + 1
  seq[#seq + 1] = kit.r16(0x09EC)
  if n == 90 then kit.finish({ seq = seq, ctl36 = ctl, p1010 = kit.r16(0x1010), px = kit.r16(0x1014), py = kit.r16(0x1016) }) end
end)
"""

DIR = "nil"

def run(rom, state, tag):
    lib = os.path.join(RESULTS, "kit", "lib")
    m = Mesen(args=[f"--mcp-lib-dir={lib}", f"--mcp-results-dir={os.path.join(RESULTS, 'raw')}"])
    info = m.call("load_rom", path=rom)["rom"]
    m.call("pause")
    print(tag, "sha1", info["fileSha1"])
    res = {}
    for p in (20, 40):
        runs = []
        for rep in range(5):
            r, _ = lua(m, LUA % dict(p=p, dir=DIR), state=state, frames=95, name="b5_ba43")
            runs.append(r)
        res[p] = runs
        seqs = [tuple(r["seq"]) for r in runs]
        first = [next((i for i, v in enumerate(s) if v != s[0]), None) for s in seqs]
        print(tag, "P", p, "identical x5:", len(set(seqs)) == 1, "first change frames", first, "ctl", [r["ctl36"] for r in runs], "end", runs[0]["px"], runs[0]["py"])
        print("   ", "".join("%X" % (v & 0xF) for v in seqs[0]))
    m.close()
    return {"sha1": info["fileSha1"], "res": res}

if len(sys.argv) > 1:
    DIR = '"%s"' % sys.argv[1]
out = {"O": run(ROM_O, S01R, "O"), "R": run(R_ROM, R_ST, "R-plain")}
save("ba43_displaymode" + ("_" + sys.argv[1] if len(sys.argv) > 1 else ""), out)
