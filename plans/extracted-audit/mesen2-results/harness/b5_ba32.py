#!/usr/bin/env python3
"""BA-32: hit box headers seen by MarkCollisionRect / ClearCollisionRect / ClearCollisionRectFull in every scene.
Per scene: S01r loaded, flags set, $0642 = id poked in the script's first frame, 330 frames; exec hooks on the three helpers (X = actor slot, header at
bank $7F0008,X : pointer $7F000C,X) log the 4 header bytes. Output: raw/B5/ba32_hitbox_headers_<date>.json (one row per scene, unique keys with counts)."""
import json
import sys
import time
sys.path.insert(0, ".")
from b5_common import *
from scenario_b1_census import FLAGS, set_flag

LUA = r"""
local SCENE = %(scene)d
local PRG = emu.memType.snesPrgRom
local SM = emu.memType.snesMemory
local f = 0
local seen, order = {}, {}
local ctl = 0
emu.addMemoryCallback(function(a, v) if (a & 0xFFFF) == 0x36 then ctl = ctl + 1 end end, emu.callbackType.write, 0x36, 0x36, emu.cpuType.snes, emu.memType.snesWorkRam)
local function hook(name, off)
  emu.addMemoryCallback(function()
    local st = emu.getState()
    local x = st["cpu.x"]
    local ptr = kit.r16(0x1000C + x)
    local bank = kit.r8(0x10008 + x)
    local b = {}
    for i = 0, 3 do b[#b + 1] = emu.read(((bank << 16) | ((ptr + i) & 0xFFFF)), SM) end
    local key = string.format("%%s %%02X:%%04X %%02X %%02X %%02X %%02X", name, bank, ptr, b[1], b[2], b[3], b[4])
    local e = seen[key]
    if not e then e = { n = 0, slot = x, frame = f, flags10 = kit.r16(0x1000 + 0 + x + 0x10 - 0x1000) }; seen[key] = e; order[#order + 1] = key end
    e.n = e.n + 1
  end, emu.callbackType.exec, off, off, emu.cpuType.snes, PRG)
end
hook("Mark", 45727)
hook("Clear", 45893)
hook("ClearFull", 46063 - 0)
kit.onFrame(function()
  f = f + 1
  if f == 1 then kit.w16(0x0642, SCENE) end
  if f == %(frames)d then
    local rows = {}
    for _, k in ipairs(order) do local e = seen[k]; rows[#rows + 1] = { k, e.n, e.slot, e.frame } end
    kit.finish({ scene = kit.r16(0x0644), ctl36 = ctl, rows = rows })
  end
end)
"""

def main():
    ids = json.load(open(os.path.join(BASEROM, "artifacts", "scenes.json"), encoding="utf-8"))["ids"]
    if len(sys.argv) > 1 and sys.argv[1] != "all":
        ids = [int(x) for x in sys.argv[1].split(",")]
    m = open_session()
    out = []
    t0 = time.time()
    for sc in ids:
        try:
            m.call("load_state_file", path=S01R)
            for n in FLAGS.get(sc, []):
                set_flag(m, n)
            r, _ = lua(m, LUA % dict(scene=sc, frames=330), frames=340, name="b5_ba32")
            r["requested"] = sc
        except Exception as e:
            r = {"requested": sc, "error": str(e)[:200]}
        out.append(r)
        print(sc, r.get("scene"), "ctl", r.get("ctl36"), "n", len(r.get("rows", [])), r.get("error", ""), round(time.time() - t0), flush=True)
    save("ba32_hitbox_headers", out)
    m.close()

main()
