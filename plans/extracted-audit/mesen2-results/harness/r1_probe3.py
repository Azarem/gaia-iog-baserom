#!/usr/bin/env python3
"""R1 probe 3 (ROM O): who reads the three unreferenced thinker lists of scene_thinkers (OQ-I072-3), over every scene id.
Read callbacks on 0CE8E6 (846054..846062), 0CE9EA (846314..846330) and 0CEA45 (846405..846417) with a margin; the result is a table
address -> {count, pc of the first read, first scene} plus the count of reads per scene, so a one-byte terminator overrun (one address, the first byte of the list)
is told apart from a parse of the list (all addresses read by the record loop of SpawnSceneThinkers).
usage: python r1_probe3.py     -> raw/R1_probe_thinker_full.json
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from a_common import open_session, S01R  # noqa: E402
import r1_probe2 as P  # noqa: E402
import r1_run as RR  # noqa: E402

LUA = P.HDR + r"""
local T = {}
local cur = 0
local function mk(tag) return function(addr, v)
  local k = tag .. ":" .. addr
  local e = T[k]
  if not e then
    local st = emu.getState()
    e = { n = 0, pc = string.format("%02X:%04X", st["cpu.k"], st["cpu.pc"]), sc = kit.r16(0x0644) & 0xFF, v = v }
    T[k] = e
  end
  e.n = e.n + 1
end end
emu.addMemoryCallback(mk("E8"), emu.callbackType.read, 846048, 846070, CPU, PRG)
emu.addMemoryCallback(mk("E9"), emu.callbackType.read, 846306, 846335, CPU, PRG)
emu.addMemoryCallback(mk("EA"), emu.callbackType.read, 846398, 846425, CPU, PRG)
local S = { nev = 0 }
e2.sweep({ scenes = {@IDS@}, post = 40, noBanner = {[254] = true, [255] = true},
  done = function(S2, per) kit.finish({ T = T, scenes = #per }) end }, S)
"""


def main():
    ids = RR.scene_ids()
    lua = LUA.replace("@IDS@", ",".join(str(i) for i in ids))
    m, info = open_session()
    print("ROM", info["fileSha1"], flush=True)
    try:
        o = P.run(m, "thinker_full", S01R, lua, 60000, includes=("e2_palette",))
        res = o["result"]
        T = res.get("T", {})
        print("scenes", res.get("scenes"), "addresses", len(T))
        for k in sorted(T, key=lambda s: (s.split(":")[0], int(s.split(":")[1]))):
            e = T[k]
            print(k, "off", int(k.split(":")[1]), "n", e["n"], "pc", e["pc"], "firstScene", "%02X" % e["sc"], "v", e.get("v"))
    finally:
        m.close()


if __name__ == "__main__":
    main()
