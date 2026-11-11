#!/usr/bin/env python3
"""BA-02: is the layer-1 overlay exactly 'nonzero layer-1 flag wins'? For each dual-layer scene ($06EF bit 0): expected[i] = f1 if f1 != 0 else f0 with
f0 = flagTableL0[mapDataL0[i]] and f1 = flagTableL1[mapDataL1[i]]; compare the low nibble of the live collision layer ($7F:C000+i) with it.
Also a control (scene with $06EF bit 0 clear): expected = f0 only."""
import json
import sys
sys.path.insert(0, ".")
from b5_common import *

LUA = r"""
local n = 0
kit.onFrame(function()
  n = n + 1
  if n < 4 then return end
  local s0, r0 = kit.r8(0x0693), kit.r8(0x0697)
  local s1, r1 = kit.r8(0x0695), kit.r8(0x0699)
  local base0, base1 = kit.r16(0x069E), kit.r16(0x06A0)
  local ft0, ft1 = kit.r16(0x06AA), kit.r16(0x06AC)
  local dual = kit.r16(0x06EF) & 1
  local n0, n1 = s0 * r0 * 256, s1 * r1 * 256
  local exp, mism, mismHi = {}, 0, 0
  local classes = {}   -- "f0>f1>live" -> count of mismatches
  local first = {}
  local both, only1, only0 = 0, 0, 0
  for i = 0, n0 - 1 do
    local f0 = kit.r8(0x10000 + ft0 + kit.r8(base0 + i)) & 15
    local f1 = 0
    if dual == 1 and i < n1 then f1 = kit.r8(0x10000 + ft1 + kit.r8(base1 + i)) & 15 end
    local e = (f1 ~= 0) and f1 or f0
    local live = kit.r8(0x1C000 + i)
    if (live & 15) ~= e then
      mism = mism + 1
      local key = string.format("f0=%X f1=%X live=%X", f0, f1, live & 15)
      classes[key] = (classes[key] or 0) + 1
      if #first < 6 then first[#first + 1] = { i, f0, f1, live } end
    end
    if f1 ~= 0 and f0 ~= 0 then both = both + 1 elseif f1 ~= 0 then only1 = only1 + 1 elseif f0 ~= 0 then only0 = only0 + 1 end
  end
  kit.finish({ scene = kit.r16(0x0644), dual = dual, cells0 = n0, cells1 = n1, base0 = base0, base1 = base1, ft0 = ft0, ft1 = ft1, mismatches = mism,
               classes = classes, first = first, both = both, only1 = only1, only0 = only0 })
end)
"""

SCENES = [0x0B, 0x30, 0x5F, 0x60, 0x61, 0x62, 0x64, 0x65, 0x67, 0x01, 0x15]
FLAGS = {}   # default flag state (Mu rooms: flooded variant)

def main():
    m = open_session()
    out = []
    for sc in SCENES:
        w = warp_scene(m, sc, FLAGS.get(sc, ()))
        r, _ = lua(m, LUA, frames=8, name="b5_ba02")
        r["warp"] = w
        out.append(r)
        print(f"${sc:02X} scene={r['scene']:02X} dual={r['dual']} cells0={r['cells0']} cells1={r['cells1']} mismatches={r['mismatches']} f1-only={r['only1']} f1&f0={r['both']} f0-only={r['only0']} classes={r['classes']}")
    save("ba02_overlay", out)
    m.close()

main()
