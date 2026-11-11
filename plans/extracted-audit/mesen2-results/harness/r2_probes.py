#!/usr/bin/env python3
"""R2 one-off probes of ROM O (each Lua text is also copied verbatim into R2_<date>_lua.md).

usage (from this folder):  timeout 900 python r2_probes.py [f9apu|hookctl|rd1f|callstack1a ...]
Results: raw/R2_probe_<name>.json
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from mcp_client import Mesen  # noqa: E402
from r2_sweep import ARGS, RAW, ROMS  # noqa: E402

CFG = ROMS["O"]

LUA_F9APU = r"""
-- O ROM, scene $F9 written into sceneNext at the first frame end; samples at frames 300 / 900 / 1500 of the run.
local WR, PRG, MEM = emu.memType.snesWorkRam, emu.memType.snesPrgRom, emu.memType.snesMemory
local nf, out = 0, { samples = {}, code = {} }
for i = 0, 15 do out.code[#out.code + 1] = emu.read(166828 + i, PRG, false) end   -- bytes at ROM 166828 (82:8BAC)
kit.onFrame(function()
  nf = nf + 1
  if nf == 1 then emu.write16(0x0642, 0xF9, WR) end
  if nf == 300 or nf == 900 or nf == 1500 then
    local st = emu.getState()
    out.samples[#out.samples + 1] = { nf = nf, k = st["cpu.k"], pc = st["cpu.pc"], a = st["cpu.a"], x = st["cpu.x"], y = st["cpu.y"], ps = st["cpu.ps"],
      sceneCurrent = emu.read16(0x0644, WR, false), nmi36 = emu.read16(0x36, WR, false), d0D72 = emu.read(0x0D72, WR, false),
      ports = { emu.read(0x2140, MEM, false), emu.read(0x2141, MEM, false), emu.read(0x2142, MEM, false), emu.read(0x2143, MEM, false) } }
  end
  if nf >= 1500 then kit.finish(out) end
end)
"""

LUA_HOOKCTL = r"""
-- Positive control of the coverage hooks: exec counts at the entry of SceneCmd_LoadBgTiles (lbt) and at its mode-3 instruction (m3),
-- Load4bppPage (l4), SceneCmd_LoadLayerMaps entry (llm) and its JMP DmaLowVramTileset (fgj), DmaLowVramTileset (lowv); scene SID, 200 frames.
local WR, PRG, CPU = emu.memType.snesWorkRam, emu.memType.snesPrgRom, emu.cpuType.snes
local pcs = { lbt = 164957, m3 = 165107, l4 = 165266, llm = 165820, fgj = 165943, lowv = 166182, nmi = 33528 }
local c = {}
for k, off in pairs(pcs) do
  c[k] = 0
  emu.addMemoryCallback(function() c[k] = c[k] + 1 end, emu.callbackType.exec, off, off, CPU, PRG)
end
local nf = 0
kit.onFrame(function()
  nf = nf + 1
  if nf == 1 then emu.write16(0x0642, SID, WR) end
  if nf >= 200 then c.sceneCurrent = emu.read16(0x0644, WR, false); kit.finish(c) end
end)
"""

LUA_RD1F = r"""
-- Who reads $0A1F (flags $F8-$FF) in scene SID: read callback with the pc of the reader, plus TestEventFlag calls (index word at $0000
-- after the STA, ROM 45311) whose flag index is in $F8-$FF, with the direct page of the caller. 300 frames.
local WR, PRG, CPU = emu.memType.snesWorkRam, emu.memType.snesPrgRom, emu.cpuType.snes
local rd, tef = {}, {}
emu.addMemoryCallback(function(a)
  if (a & 0xFFFF) == 0x0A1F then
    local st = emu.getState()
    local k = string.format("%02X:%04X d=%04X", st["cpu.k"], st["cpu.pc"], st["cpu.d"])
    rd[k] = (rd[k] or 0) + 1
  end
end, emu.callbackType.read, 0x0A1F, 0x0A1F, CPU, WR)
emu.addMemoryCallback(function()
  local idx = emu.read16(0x0000, WR, false)
  if (idx >> 3) == 0x1F then
    local k = string.format("idx=%02X d=%04X", idx & 0xFF, emu.getState()["cpu.d"])
    tef[k] = (tef[k] or 0) + 1
  end
end, emu.callbackType.exec, 45311, 45311, CPU, PRG)
local nf = 0
kit.onFrame(function()
  nf = nf + 1
  if nf == 1 then emu.write16(0x0642, SID, WR) end
  if nf >= 300 then kit.finish({ reads = rd, tef = tef, sceneCurrent = emu.read16(0x0644, WR, false) }) end
end)
"""

LUA_WARP_ONLY = r"""
-- scene SID into sceneNext at the first frame end, then run to frame 600 and report sceneCurrent / pc (for the get_callstack probe).
local WR = emu.memType.snesWorkRam
local nf = 0
kit.onFrame(function()
  nf = nf + 1
  if nf == 1 then emu.write16(0x0642, SID, WR) end
  if nf >= 600 then local st = emu.getState(); kit.finish({ sceneCurrent = emu.read16(0x0644, WR, false), k = st["cpu.k"], pc = st["cpu.pc"], sp = st["cpu.sp"] }) end
end)
"""


LUA_KILL = r"""
-- Game-over probe: set gemCount (GEMS) and playerHp = 0 (CheckPlayerDeath then starts GameOverSequence), pulse A while a banner blocks
-- the main loop, run to frame 1300 and report the scene reached, the transition words and the two warp records.
local WR = emu.memType.snesWorkRam
local function r16(a) return emu.read16(a, WR, false) end
local nf, S = 0, { seen = {}, gems = GEMS }
local last
kit.onFrame(function()
  nf = nf + 1
  if nf == 1 then
    S.before = { r16(0x0644), r16(0x0AF0), r16(0x0AF2), r16(0x0AF4), r16(0x0AF6), r16(0x0AD6), r16(0x0ACE) }
    emu.write16(0x0AD6, GEMS, WR)
    emu.write16(0x0ACE, 0, WR)
  end
  local sc = r16(0x0644)
  if sc ~= last then S.seen[#S.seen + 1] = { nf, sc }; last = sc end
  if emu.read(0x00B4, WR, false) ~= 0 then gaia.hold((nf % 6 < 3) and { "a" } or {}) else gaia.release() end
  if r16(0x0642) ~= 0 and not S.staged then S.staged = { nf, r16(0x0642), r16(0x064C), r16(0x064E), r16(0x0650), r16(0x0652) } end
  if nf >= 1300 then
    gaia.release()
    S.endScene, S.gemsEnd, S.hpEnd, S.wake = sc, r16(0x0AD6), r16(0x0ACE), r16(0x0AF8)
    kit.finish(S)
  end
end)
"""


def gameover(m, gems):
    """Save warp 1A -> 1B, non-save warp 24 -> 22, quick warp to 30, then kill the player with `gems` gems."""
    inc = ["gaia_kit", "r2w_kit"]
    m.call("load_state_file", path=CFG["state"])
    cw = 174459
    out = {}
    out["save"] = m.run_script_checked("r2w.run{scene=26, x=200, y=384, dest=27, cwr=%d}" % cw, frames=1500, includes=inc, turbo=True, timeoutMs=180000, maxLog=3, name="r2go1").get("result", {})
    out["plain"] = m.run_script_checked("r2w.run{scene=36, x=248, y=32, dest=34, cwr=%d}" % cw, frames=1500, includes=inc, turbo=True, timeoutMs=180000, maxLog=3, name="r2go2").get("result", {})
    out["neutral"] = m.run_script_checked("local WR=emu.memType.snesWorkRam; local n=0; kit.onFrame(function() n=n+1; if n==1 then emu.write16(0x0642,48,WR) end; if n>=200 then kit.finish({scene=emu.read16(0x0644,WR,false)}) end end)", frames=400, includes=inc, turbo=True, timeoutMs=60000, maxLog=3, name="r2go3").get("result", {})
    out["kill"] = m.run_script_checked(LUA_KILL.replace("GEMS", str(gems)), frames=1500, includes=["gaia_kit"], turbo=True, timeoutMs=180000, maxLog=3, name="r2go4").get("result", {})
    return out


def run(m, lua, sid=None, name="r2probe", frames=1700):
    code = lua.replace("SID", str(sid)) if sid is not None else lua
    m.call("load_state_file", path=CFG["state"])
    return m.run_script_checked(code, frames=frames, includes=["gaia_kit"], turbo=True, timeoutMs=180000, maxLog=3, name=name).get("result", {})


def main():
    which = sys.argv[1:] or ["f9apu", "hookctl", "rd1f", "callstack1a"]
    m = Mesen(args=ARGS)
    try:
        m.call("load_rom", path=CFG["rom"])
        m.call("pause")
        m.call("load_labels", path=CFG["labels"], replace=True)
        m.call("load_state_file", path=CFG["state"])
        m.call("advance_frame", frames=120)
        res = {}
        if "f9apu" in which:
            res["f9apu"] = run(m, LUA_F9APU, name="r2f9")
        if "hookctl" in which:
            res["hookctl"] = {"%02X" % s: run(m, LUA_HOOKCTL, s, "r2hk", 400) for s in (0x02, 0x15, 0x21, 0x5A, 0x8C, 0xE6, 0xF7, 0xFD)}
        if "rd1f" in which:
            res["rd1f"] = {"%02X" % s: run(m, LUA_RD1F, s, "r2rd", 400) for s in (0x09, 0x1D, 0x2A, 0x5C, 0x5D, 0x60, 0x8A, 0xCC, 0xDE, 0xFB, 0xFD, 0xFF)}
        if "callstack1a" in which:
            r = run(m, LUA_WARP_ONLY, 0x1A, "r2cs", 700)
            cs = m.call("get_callstack")
            res["callstack1a"] = {"run": r, "callstack": cs}
        if "gameover" in which:
            res["gameover"] = {"gems0": gameover(m, 0), "gems100": gameover(m, 100)}
        json.dump(res, open(os.path.join(RAW, "R2_probe_%s.json" % "_".join(which)), "w"), indent=1)
        print(json.dumps(res)[:4000])
    finally:
        m.close()


if __name__ == "__main__":
    main()
