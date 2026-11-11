-- description: C2 instrumentation: NMITIMEN ($4200) writers by PC and value, callers of the NMI routines, NMI state at the entry of VBlankWaitAndJoypad.
-- requires: mesen_kit, iog_kit, gaia_kit
--
-- run_script {includes={"gaia_kit","c2_nmitimen"}, code='c2.run{frames=N, nmi=33528, input=function(n) ... end, tick=function(n) ... end}'}
--
-- All callbacks run BEFORE the access / instruction; the PC a memory callback reports is the address AFTER the instruction.
-- Offsets are decimal PRG (ROM file) offsets of the O ROM: off = ((bank & 0x3F) << 16) | pc16 for the HiROM mirrors $00-$3F / $80-$BF.
--
--   control  : NMI exec count (snesPrgRom `nmi`), $36 write count (INC $36 in the NMI), $4200 write count, frames
--   writes   : every distinct (writer PC after the store, value) written to $4200 at any of the 128 bank aliases:
--              n, first/last frame, scene at the first hit, previous NMITIMEN value counts (prev), hardware NMI enable
--              bit at the instant of the write (hw0 / hw1 counts), the alias bank the code used
--   entries  : exec of the three routines of vblank_joypad (EnableNmiAndJoypad, DisableNmiKeepJoypad, VBlankWaitAndJoypad,
--              plus WaitFrames and VBlankPartial) keyed by the JSL that called them. The return address is read from the stack
--              at entry (SP+1..SP+3; JSL pushes the address of its last byte, so the JSL starts at ret-3). Each row has the
--              last NMITIMEN value written before the call (nt), the hardware NMI enable bit (hw), the count and the first frame
c2 = c2 or {}

local WR  = emu.memType.snesWorkRam
local SM  = emu.memType.snesMemory
local PRG = emu.memType.snesPrgRom
local CPU = emu.cpuType.snes

local ENTRY = {   -- db-us/names/bank02.json keys (decimal PRG offsets)
  VBlankPartial = 163899, VBlankWaitAndJoypad = 163907, EnableNmiAndJoypad = 164241,
  DisableNmiKeepJoypad = 164258, WaitFrames = 164297,
}

local function hex(v, w) return string.format("%0" .. (w or 2) .. "X", v) end
local function off24(k, pc) return ((k & 0x3F) << 16) | (pc & 0xFFFF) end

function c2.run(o)
  local S = { nmi = 0, w36 = 0, n4200 = 0, nt = nil, ntFrame = nil, writes = {}, entries = {}, probes = {}, lastSig = nil }
  local scene = function() return kit.r16(0x0644) end

  -- controls -----------------------------------------------------------------------------------
  emu.addMemoryCallback(function() S.nmi = S.nmi + 1 end, emu.callbackType.exec, o.nmi, o.nmi, CPU, PRG)
  emu.addMemoryCallback(function(a) if (a & 0xFFFF) == 0x36 then S.w36 = S.w36 + 1 end end,
    emu.callbackType.write, 0x36, 0x36, CPU, WR)

  -- NMITIMEN ($4200) on every bank alias ---------------------------------------------------------
  local function on4200(a, v)
    if (a & 0xFFFF) ~= 0x4200 then return end
    local st = emu.getState()
    local k, pc, f = st["cpu.k"], st["cpu.pc"], st["frameCount"]
    local hw = st["internalRegisters.enableNmi"] and 1 or 0
    local key = hex(off24(k, pc), 6) .. "=" .. hex(v)
    local e = S.writes[key]
    if not e then
      e = { n = 0, first = f, scene = scene(), pc24 = hex((k << 16) | pc, 6), alias = hex((a >> 16) & 0xFF), prev = {}, hw0 = 0, hw1 = 0 }
      S.writes[key] = e
    end
    e.n = e.n + 1
    e.last = f
    local pv = S.nt and hex(S.nt) or "??"
    e.prev[pv] = (e.prev[pv] or 0) + 1
    if hw == 1 then e.hw1 = e.hw1 + 1 else e.hw0 = e.hw0 + 1 end
    S.nt, S.ntFrame, S.n4200 = v, f, S.n4200 + 1
  end
  for bank = 0, 0xFF do
    if bank <= 0x3F or (bank >= 0x80 and bank <= 0xBF) then
      emu.addMemoryCallback(on4200, emu.callbackType.write, (bank << 16) | 0x4200, (bank << 16) | 0x4200, CPU, SM)
    end
  end

  -- callers of the routines (stack at entry: SP+1 = ret low, SP+2 = ret high, SP+3 = ret bank) ------
  for name, off in pairs(ENTRY) do
    emu.addMemoryCallback(function()
      local st = emu.getState()
      local sp, f = st["cpu.sp"], st["frameCount"]
      local lo, hi, bk = emu.read(sp + 1, WR), emu.read(sp + 2, WR), emu.read(sp + 3, WR)
      local ret = (hi << 8) | lo
      local caller = off24(bk, (ret - 3) & 0xFFFF)         -- offset of the JSL opcode
      local hw = st["internalRegisters.enableNmi"] and 1 or 0
      local key = name .. " <- " .. hex(caller, 6) .. " nt=" .. (S.nt and hex(S.nt) or "??") .. " hw=" .. hw
      local e = S.entries[key]
      if not e then e = { n = 0, first = f, scene = scene(), retBank = hex(bk) }; S.entries[key] = e end
      e.n = e.n + 1
      e.last = f
    end, emu.callbackType.exec, off, off, CPU, PRG)
  end

  -- NMI state at the entry of arbitrary routines (o.at = {Name = prgOffset}): last NMITIMEN value written and the hardware enable bit
  S.at = {}
  for name, off in pairs(o.at or {}) do
    emu.addMemoryCallback(function()
      local st = emu.getState()
      local hw = st["internalRegisters.enableNmi"] and 1 or 0
      local key = name .. " nt=" .. (S.nt and hex(S.nt) or "??") .. " hw=" .. hw
      S.at[key] = (S.at[key] or 0) + 1
    end, emu.callbackType.exec, off, off, CPU, PRG)
  end

  -- adhoc VRAM DMA staging: dest ($7F0C07, the pending flag) then size ($7F0C09). Per pair: hardware NMI enable bit and NMITIMEN at the
  -- destination store, and the number of NMI handler entries between the two stores.
  S.adhoc = {}
  if o.adhoc then
    local nmiAtDest, keyDest = nil, nil
    emu.addMemoryCallback(function(a, v)
      local st = emu.getState()
      nmiAtDest = S.nmi
      keyDest = "dest hw=" .. (st["internalRegisters.enableNmi"] and 1 or 0) .. " nt=" .. (S.nt and hex(S.nt) or "??")
    end, emu.callbackType.write, 0x10C07, 0x10C07, CPU, WR)
    emu.addMemoryCallback(function(a, v)
      if not nmiAtDest then return end
      local key = keyDest .. " nmiBetween=" .. (S.nmi - nmiAtDest) .. " scene=" .. hex(scene(), 4)
      S.adhoc[key] = (S.adhoc[key] or 0) + 1
      nmiAtDest = nil
    end, emu.callbackType.write, 0x10C09, 0x10C09, CPU, WR)
  end

  -- frame loop ---------------------------------------------------------------------------------------
  local n = 0
  kit.onFrame(function()
    n = n + 1
    if o.input then
      local b = o.input(n)
      if b ~= nil then gaia.hold(b) end
    end
    if o.probe and #S.probes < 24 then
      local sig = string.format("%04X %04X", scene(), kit.r16(0x0642))
      if sig ~= S.lastSig then
        S.lastSig = sig
        S.probes[#S.probes + 1] = string.format("n=%d f36=%d scene,sceneNext=%s nt=%s", n, kit.r16(0x36), sig, S.nt and hex(S.nt) or "??")
      end
    end
    if o.tick then o.tick(n, S) end
    if n >= o.frames then
      gaia.release()
      local res = {
        frames = n, control = { nmiExec = S.nmi, w36Writes = S.w36, w4200Writes = S.n4200 },
        writes = S.writes, entries = S.entries, at = S.at, adhoc = S.adhoc, probes = S.probes, lastNt = S.nt and hex(S.nt) or "??",
      }
      if o.final then res.final = o.final(S) end
      kit.finish(res)
    end
  end)
end
