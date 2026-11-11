#!/usr/bin/env python3
"""W1-b: does the BG2 horizontal scroll follow forcedScrollOverride ($06C8)?  (override half of the scroll-override question)

Loads a state of a scene that writes $06C8 (Sky Garden $58 Layer1DriftUnbounded, Mt. Kress $A0 ScrollCameraInit), runs N frames and, at each
WriteBgScroll pass that takes the override branch for X = 2 (exec at 33753), pairs the two stores to BG2HOFS (STA $BG1HOFS,Y with Y = 2 at 33756 and 33775) with
$06C8 & $03FF read at the same time. Output: raw/W1b_bg2check_<date>.json and a printed summary.
"""
import json
import os
import sys

import w1a_session as A
from a_common import RAW, open_session, stamp

LUA = r"""
local n, same, diff, pending, lo, hi, nz, ry = 0, 0, 0, false, 0, 0, 0, 0
local byY = {}
local samples = {}
local function on(off, fn) emu.addMemoryCallback(fn, emu.callbackType.exec, off, off, emu.cpuType.snes, emu.memType.snesPrgRom) end
on(33753, function() local s = emu.getState(); pending = ((s["cpu.x"] or 0) == 2) end)
on(33756, function()
  if not pending then return end
  local s = emu.getState()
  lo = (s["cpu.a"] or 0) & 0xFF
  ry = s["cpu.y"] or 0
end)
on(33775, function()
  if not pending then return end
  local s = emu.getState()
  hi = (s["cpu.a"] or 0) & 0xFF
  local v = kit.r16(0x06C8)
  local want = v & 0x03FF
  local got = lo | (hi << 8)
  n = n + 1
  if want ~= 0 then nz = nz + 1 end
  if got == want then same = same + 1 else diff = diff + 1 end
  if #samples < 8 and want ~= 0 and n % 25 == 1 then samples[#samples + 1] = string.format("f=%d sc=%02X $06C8=%04X BG2HOFS stores=%04X Y=%d", s["frameCount"], kit.r16(0x0644), v, got, ry) end
  byY[ry] = (byY[ry] or 0) + 1
  pending = false
end)
local function result() return { passes = n, same = same, diff = diff, nonzero = nz, samples = samples, passesByY = byY, endScene = kit.r16(0x0644) } end
acen.run{frames = __N__, writes = false, reads = false, refill = 10, bot = __BOT__, final = result}
"""


def main():
    m, info = open_session()
    out = {}
    try:
        for name, frames in (("p05_58", 1200), ("p12_A0", 1200)):
            s = [x for x in A.S if x["name"] == name][0]
            m.call("load_state_file", path=s["state"])
            code = LUA.replace("__N__", str(frames)).replace("__BOT__", A.bot_lua(s["bot"]))
            r = m.run_script_checked(code, ok_stop=("script_done",), name="w1b_bg2", includes=["gaia_kit", "a_census"], frames=frames + 20, turbo=True, timeoutMs=900000)
            out[name] = r["result"]
            print(name, json.dumps(r["result"]), flush=True)
    finally:
        m.close()
    out["lua"] = LUA
    out["rom"] = info
    with open(os.path.join(RAW, f"W1b_bg2check_{stamp()}.json"), "w", encoding="utf-8") as f:
        json.dump(out, f, indent=1)


if __name__ == "__main__":
    main()
