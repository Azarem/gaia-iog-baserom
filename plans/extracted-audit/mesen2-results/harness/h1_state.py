#!/usr/bin/env python3
"""H1 validity test of a save state (read-only): load_rom, pause, load_state_file, then 120 frames: cpu.k, scene, $36 writes.

usage: python h1_state.py [STATE]   (default: rebuilt/states/orig_S13_slope-field.mss)"""
import os
import sys

from mcp_client import Mesen
from scenario_b3 import DEFAULT_ROM, RESULTS, S13

LUA = """
local WR = emu.memType.snesWorkRam
local n36 = 0
emu.addMemoryCallback(function(a, v) n36 = n36 + 1 end, emu.callbackType.write, 0x36, 0x36, emu.cpuType.snes, WR)
local first = { k = emu.getState()["cpu.k"], scene = kit.r16(0x0644), ax = kit.r16(0x1014), ay = kit.r16(0x1016) }
local frames = 0
emu.addEventCallback(function()
  frames = frames + 1
  if frames == 120 then
    local st = emu.getState()
    kit.finish({ first = first, k = st["cpu.k"], pc = st["cpu.pc"], scene = kit.r16(0x0644), ax = kit.r16(0x1014),
                 ay = kit.r16(0x1016), n36 = n36 })
  end
end, emu.eventType.endFrame)
"""


def main():
    state = sys.argv[1] if len(sys.argv) > 1 else S13
    lib = os.path.join(RESULTS, "kit", "lib")
    with Mesen(args=[f"--mcp-lib-dir={lib}", f"--mcp-results-dir={os.path.join(RESULTS, 'raw')}"]) as m:
        info = m.call("load_rom", path=DEFAULT_ROM)["rom"]
        m.call("pause")
        print("ROM sha1", info["fileSha1"], "crc32", info["fileCrc32"])
        m.call("load_state_file", path=state)
        r = m.call("run_script", code=LUA, name="h1_state", includes=["gaia_kit"], frames=125, turbo=True, maxLog=40)
        print(state)
        print(r.get("stopReason"), r.get("result"))


if __name__ == "__main__":
    main()
