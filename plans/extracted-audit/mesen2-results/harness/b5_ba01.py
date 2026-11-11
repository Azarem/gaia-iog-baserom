#!/usr/bin/env python3
"""BA-01: who writes the collision layer ($7F:C000-$FFFF) after a scene load? Write callback on the whole layer from the scene-change poke on, histogram by
K:PC with first/last frame, plus a snapshot comparison of the layer 40 frames and at the end. Scenes: $55 $6B $78 $D6 $D7 and controls $01 $62 $15."""
import sys
sys.path.insert(0, ".")
from b5_common import *

LUA = r"""
local SCENE = %(scene)d
local WR = emu.memType.snesWorkRam
local f, started = 0, false
local hist, order = {}, {}
local total = 0
local loadedFrame
local ctl = 0
local snapAt = {}
local function snap()
  local s = {}
  local n = kit.r8(0x0693) * kit.r8(0x0697) * 256
  for i = 0, n - 1 do s[i] = kit.r8(0x1C000 + i) end
  return s, n
end
emu.addMemoryCallback(function(a, v) if (a & 0xFFFF) == 0x36 then ctl = ctl + 1 end end, emu.callbackType.write, 0x36, 0x36, emu.cpuType.snes, WR)
emu.addMemoryCallback(function(a, v)
  local st = emu.getState()
  local key = string.format("%%02X:%%04X", st["cpu.k"], st["cpu.pc"])
  local h = hist[key]
  if not h then h = { n = 0, first = f, last = f, lo = a, hi = a }; hist[key] = h; order[#order + 1] = key end
  h.n = h.n + 1; h.last = f
  if a < h.lo then h.lo = a end
  if a > h.hi then h.hi = a end
  total = total + 1
end, emu.callbackType.write, 0x1C000, 0x1FFFF, emu.cpuType.snes, WR)
local s1, s2, n1
kit.onFrame(function()
  f = f + 1
  if f == 1 then kit.w16(0x0642, SCENE) end
  if not loadedFrame and kit.r16(0x0644) == SCENE and kit.r16(0x0642) == 0 then loadedFrame = f end
  if loadedFrame and f == loadedFrame + 60 then s1, n1 = snap() end
  if f == %(frames)d then
    local s2, n2 = snap()
    local diff = 0
    if s1 and n1 == n2 then for i = 0, n2 - 1 do if s1[i] ~= s2[i] then diff = diff + 1 end end end
    local rows = {}
    for _, k in ipairs(order) do local h = hist[k]; rows[#rows + 1] = { k, h.n, h.first, h.last, h.lo, h.hi } end
    kit.finish({ scene = kit.r16(0x0644), loadedFrame = loadedFrame, total = total, ctl36 = ctl, snapDiff = diff, cells = n2, hist = rows })
  end
end)
"""

def main():
    m = open_session()
    out = []
    for sc in [0x55, 0x6B, 0x78, 0xD6, 0xD7, 0x01, 0x62, 0x15]:
        res = []
        for rep in range(2):
            m.call("load_state_file", path=S01R)
            r, _ = lua(m, LUA % dict(scene=sc, frames=520), frames=540, name="b5_ba01")
            res.append(r)
        a, b = res
        same = a["hist"] == b["hist"] and a["total"] == b["total"]
        print(f"${sc:02X} scene={a['scene']:02X} loadedFrame={a['loadedFrame']} writes={a['total']} ctl36={a['ctl36']} snapDiff(+60..end)={a['snapDiff']} cells={a['cells']} repeat-identical={same}")
        for h in a["hist"]:
            print("    ", h)
        out.append({"scene": sc, "runs": res, "identical": same})
    save("ba01_layer_writers", out)
    m.close()

main()
