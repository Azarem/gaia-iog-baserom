#!/usr/bin/env python3
"""Dump the live collision layer of every scene (BA-12 / BA-14 / BA-17 census search): S01r, flags, $0642 = id poked in the script, 330 frames (the load is
done by frame ~215, see ba01), then the layer bytes (paged index order) as hex plus stride/rows. raw/B5/layers_<date>.json (one entry per scene)."""
import json
import sys
import time
sys.path.insert(0, ".")
from b5_common import *
from scenario_b1_census import FLAGS, set_flag

LUA = r"""
local SCENE = %(scene)d
local f = 0
local ctl = 0
emu.addMemoryCallback(function(a, v) if (a & 0xFFFF) == 0x36 then ctl = ctl + 1 end end, emu.callbackType.write, 0x36, 0x36, emu.cpuType.snes, emu.memType.snesWorkRam)
kit.onFrame(function()
  f = f + 1
  if f == 1 then kit.w16(0x0642, SCENE) end
  if f == %(frames)d then
    local stride, rows = kit.r8(0x0693), kit.r8(0x0697)
    local n = stride * rows * 256
    local t = {}
    for i = 0, n - 1 do t[#t + 1] = string.format("%%02X", kit.r8(0x1C000 + i)) end
    kit.finish({ scene = kit.r16(0x0644), ctl36 = ctl, stride = stride, rows = rows, f06EF = kit.r16(0x06EF), hex = table.concat(t) })
  end
end)
"""

def main():
    ids = json.load(open(os.path.join(BASEROM, "artifacts", "scenes.json"), encoding="utf-8"))["ids"]
    m = open_session()
    out = []
    t0 = time.time()
    for sc in ids:
        try:
            m.call("load_state_file", path=S01R)
            for n in FLAGS.get(sc, []):
                set_flag(m, n)
            r, _ = lua(m, LUA % dict(scene=sc, frames=330), frames=340, name="b5_layers")
            r["requested"] = sc
        except Exception as e:
            r = {"requested": sc, "error": str(e)[:200]}
        out.append(r)
        print(sc, r.get("scene"), "ctl", r.get("ctl36"), r.get("stride"), r.get("rows"), r.get("error", ""), round(time.time() - t0), flush=True)
    save("layers", out)
    m.close()

main()
