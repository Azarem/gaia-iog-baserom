#!/usr/bin/env python3
"""BA-05: why scene $FE never writes $36: per scene (FE, FA, FC, 01 control) after the load (frames 340..440): NMI events, exec hits of NmiHandler (PRG 33528),
writes of $36 (with PC histogram), the value of $36 at start / end, and the PC (K:PC) at the first NMI event."""
import json
import sys
sys.path.insert(0, ".")
from b5_common import *

LUA = r"""
local SCENE = %(scene)d
local PRG = emu.memType.snesPrgRom
local f = 0
local nmi, nmiExec, w36, first = 0, 0, 0, nil
local pcs = {}
local v0, v1
emu.addEventCallback(function()
  if f >= 340 then
    nmi = nmi + 1
    if not first then local st = emu.getState(); first = string.format("%%02X:%%04X", st["cpu.k"], st["cpu.pc"]) end
  end
end, emu.eventType.nmi)
emu.addMemoryCallback(function() if f >= 340 then nmiExec = nmiExec + 1 end end, emu.callbackType.exec, 33528, 33528, emu.cpuType.snes, PRG)
emu.addMemoryCallback(function(a, v)
  if f >= 340 and (a & 0xFFFF) == 0x36 then
    w36 = w36 + 1
    local st = emu.getState(); local k = string.format("%%02X:%%04X", st["cpu.k"], st["cpu.pc"]); pcs[k] = (pcs[k] or 0) + 1
  end
end, emu.callbackType.write, 0x36, 0x36, emu.cpuType.snes, emu.memType.snesWorkRam)
kit.onFrame(function()
  f = f + 1
  if f == 1 then kit.w16(0x0642, SCENE) end
  if f == 340 then v0 = kit.r16(0x36) end
  if f == 440 then
    kit.finish({ scene = kit.r16(0x0644), nmi = nmi, nmiExec = nmiExec, w36 = w36, pcs = pcs, v0 = v0, v1 = kit.r16(0x36), firstNmiPc = first,
                 disp = kit.r16(0x09EC), inidisp = kit.r8(0x0B), nmitimen = kit.r8(0x0C) })
  end
end)
"""
m = open_session()
out = []
for sc in (0xFE, 0xFA, 0xFC, 0x01):
    m.call("load_state_file", path=S01R)
    r, _ = lua(m, LUA % dict(scene=sc), frames=445, name="b5_ba05")
    print("scene %02X cur %02X: NMI events %d, NmiHandler exec %d, $36 writes %d, $36 %d -> %d, first NMI pc %s, pcs %s" % (sc, r["scene"], r["nmi"], r["nmiExec"], r["w36"], r["v0"], r["v1"], r.get("firstNmiPc"), r["pcs"]))
    out.append({"scene": sc, **r})
save("ba05_nmi", out)
m.close()
