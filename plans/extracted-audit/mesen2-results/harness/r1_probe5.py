#!/usr/bin/env python3
"""R1 probe 5 (ROM O): which code reads the first byte of SpawnItemSparkleEffect (ROM offset 56579, never executed in R1) in the drop scenes?
Same session as the R1 extra session x_s11_freedan (combat room $0C, Freedan, rich bot) with a read callback on 56577..56581; the table is address -> pc / A / X / Y / count.
usage: python r1_probe5.py     -> raw/R1_probe_sparkle_reader.json
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from a_common import open_session  # noqa: E402
import r1_probe2 as P  # noqa: E402
import r1_run as RR  # noqa: E402

CB = P.HDR + r"""
local T = {}
local function mk(tag) return function(addr, v)
  local st = emu.getState()
  local k = tag .. ":" .. addr .. ":" .. string.format("%02X:%04X", st["cpu.k"], st["cpu.pc"])
  local e = T[k]
  if not e then e = { n = 0, sc = kit.r16(0x0644) & 0xFF, n36 = kit.r16(0x36), v = v, a = st["cpu.a"], x = st["cpu.x"], y = st["cpu.y"], p = st["cpu.ps"] } T[k] = e end
  e.n = e.n + 1
end end
emu.addMemoryCallback(mk("R"), emu.callbackType.read, 56575, 56583, CPU, PRG)
"""


def main():
    m, info = open_session()
    print("ROM", info["fileSha1"], flush=True)
    try:
        s = [x for x in RR.extra_sessions() if x["name"] == "x_s11_freedan"][0]
        body = RR.lean_lua(s).replace("acen.run{", "acen.run{final=function() return { T = T } end, ", 1)
        lua = CB + body
        o = P.run(m, "sparkle_reader", s["state"], lua, s["frames"], pokes=s.get("pokes", []), includes=("gaia_kit", "a_census"))
        T = (o["result"].get("final") or {}).get("T", {})
        print("keys", len(T))
        for k in sorted(T):
            e = T[k]
            print(k, "n", e["n"], "scene", "%02X" % e["sc"], "n36", e["n36"], "v", e.get("v"), "A/X/Y/P", e["a"], e["x"], e["y"], e["p"])
    finally:
        m.close()


if __name__ == "__main__":
    main()
