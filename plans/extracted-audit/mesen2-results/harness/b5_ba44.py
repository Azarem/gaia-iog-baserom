#!/usr/bin/env python3
"""BA-44: who calls CheckActorOnSpecialTile (PRG 251656) in South Cape ($01, S01r) and a few other scenes: exec hook, slot X, return address on the stack
(3 bytes at SP+1), the actor's $00/$02 (entry word), $10 flags and sprite pointer. 300 frames after the state load; plus the scene's `scene_actors` owner is read offline."""
import json
import sys
sys.path.insert(0, ".")
from b5_common import *

LUA = r"""
local f = 0
local PRG = emu.memType.snesPrgRom
local seen, order, total, ctl = {}, {}, 0, 0
emu.addMemoryCallback(function(a, v) if (a & 0xFFFF) == 0x36 then ctl = ctl + 1 end end, emu.callbackType.write, 0x36, 0x36, emu.cpuType.snes, emu.memType.snesWorkRam)
emu.addMemoryCallback(function()
  local st = emu.getState()
  local x, sp = st["cpu.x"], st["cpu.sp"]
  local ret = emu.read(sp + 1, emu.memType.snesMemory) | (emu.read(sp + 2, emu.memType.snesMemory) << 8) | (emu.read(sp + 3, emu.memType.snesMemory) << 16)
  local key = string.format("slot %%04X ret %%06X entry %%04X", x, ret, kit.r16(x + 0))
  local e = seen[key]
  if not e then e = { n = 0, f = f, f10 = kit.r16(x + 0x10), spr = kit.r16(0x10006 + x), k = st["cpu.k"] }; seen[key] = e; order[#order + 1] = key end
  e.n = e.n + 1; total = total + 1
end, emu.callbackType.exec, 251656, 251656, emu.cpuType.snes, PRG)
kit.onFrame(function()
  f = f + 1
  if f == %(frames)d then
    local rows = {}
    for _, k in ipairs(order) do local e = seen[k]; rows[#rows + 1] = { k, e.n, e.f, e.f10, e.spr } end
    kit.finish({ scene = kit.r16(0x0644), total = total, ctl36 = ctl, rows = rows })
  end
end)
"""
m = open_session()
out = []
for state in (S01R, S13):
    r, _ = lua(m, LUA % dict(frames=1500), state=state, frames=1505, name="b5_ba44")
    print(os.path.basename(state), "scene", r["scene"], "calls", r["total"], "ctl", r["ctl36"])
    for x in r["rows"]:
        print("   ", x)
    out.append({"state": os.path.basename(state), **r})
save("ba44_special_callers", out)
m.close()
