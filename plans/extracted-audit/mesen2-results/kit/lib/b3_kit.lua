-- description: B3 movement trace: exec hooks by ROM offset with register and stack snapshots, memory watches with PC, scripted input, per-frame rows.
-- requires: gaia_kit
--
-- All hook offsets are ROM FILE offsets of the ORIGINAL ROM (decimal keys of db-us/names/bank02.json; a local label
-- loc_02xxxx is 0x20000 + xxxx). Never use them on the rebuilt ROM.
--
--   b3.run{ frames=N, input=function(n) -> {buttons} | nil, setup=fn, hooks={ {name=, off=, full=bool, cond=fn}, ... },
--           watches={ {name=, lo=, hi=, kind="write"|"read", cond=fn(addr, val)}, ... }, final=fn, perFrame=fn(n) -> table }
--
--   Event row (hook):  { n, name, a, x, y, sp, w1, w3, w5, d1A, d1E, d24, sEw, sNs }                         (compact)
--                      full adds:  p, w6, d20, d22, d26, c9B6, c9B8, c9C6, f9AE, ax, ay, aa, ab, d00, d02, pX($09A2), pY($09A4)   (after the compact fields)
--   Event row (watch): { n, name, addr, val, k, pc }   (pc = address AFTER the accessing instruction; mask addr with 0xFFFF)
--   Frame row:         { n, ax, ay, sEw, sNs, f10, f9AE, c9B6, c9B8, c9C6, mask }   (after the frame's NMI; n = 1 for the first frame after setup)
--   Result:            { frames = {...}, events = {...}, ctl36 = <writes of $36 seen>, final = ... }
--   wN = the 16-bit stack word at S+N when the hook runs (S = the S register BEFORE the hooked instruction; the stack page is WRAM $0100-$01FF).
b3 = b3 or {}
local PRG = emu.memType.snesPrgRom
local WR = emu.memType.snesWorkRam

local function r16(a) return kit.r16(a) end
local function s16(a) return kit.r16(a, nil, true) end

function b3.run(o)
  local events, frames = {}, {}
  local n, started, handle = 0, false, nil
  local ctl36 = 0
  local cap = o.maxEvents or 1200
  emu.addMemoryCallback(function(a, v) if (a & 0xFFFF) == 0x36 then ctl36 = ctl36 + 1 end end,
    emu.callbackType.write, 0x36, 0x36, emu.cpuType.snes, WR)
  for _, h in ipairs(o.hooks or {}) do
    emu.addMemoryCallback(function()
      if not started or #events >= cap then return end
      if h.cond and not h.cond() then return end
      local st = emu.getState()
      local sp = st["cpu.sp"]
      local row = { n, h.name, st["cpu.a"], st["cpu.x"], st["cpu.y"], sp, r16(sp + 1), r16(sp + 3), r16(sp + 5),
        r16(0x1A), r16(0x1E), s16(0x24), s16(0x09B2), s16(0x09B4) }
      if h.full then
        row[#row + 1] = st["cpu.ps"]; row[#row + 1] = r16(sp + 6)
        row[#row + 1] = s16(0x20); row[#row + 1] = r16(0x22); row[#row + 1] = s16(0x26)
        row[#row + 1] = r16(0x09B6); row[#row + 1] = r16(0x09B8); row[#row + 1] = r16(0x09C6); row[#row + 1] = r16(0x09AE)
        row[#row + 1] = r16(0x1014); row[#row + 1] = r16(0x1016)
        row[#row + 1] = r16(0xAA); row[#row + 1] = r16(0xAB); row[#row + 1] = r16(0x00); row[#row + 1] = r16(0x02)
        row[#row + 1] = r16(0x09A2); row[#row + 1] = r16(0x09A4)
      end
      events[#events + 1] = row
    end, emu.callbackType.exec, h.off, h.off, emu.cpuType.snes, PRG)
  end
  for _, w in ipairs(o.watches or {}) do
    emu.addMemoryCallback(function(a, v)
      if not started or #events >= cap then return end
      if w.cond and not w.cond(a, v) then return end
      local st = emu.getState()
      events[#events + 1] = { n, w.name, a & 0xFFFF, v, st["cpu.k"], st["cpu.pc"] }
    end, emu.callbackType[w.kind or "write"], w.lo, w.hi, emu.cpuType.snes, WR)
  end
  -- scripted input: the schedule is read at every inputPolled event; n counts completed frames
  emu.addEventCallback(function()
    if not started then return end
    local b = o.input and o.input(n + 1) or nil
    local t = {}
    for _, name in ipairs(b or {}) do t[name] = true end
    emu.setInput(t, 0)
  end, emu.eventType.inputPolled)
  handle = kit.onFrame(function()
    if not started then
      started = true
      if o.setup then o.setup() end
      return
    end
    n = n + 1
    frames[#frames + 1] = { n, r16(0x1014), r16(0x1016), s16(0x09B2), s16(0x09B4), r16(0x1010), r16(0x09AE), r16(0x09B6), r16(0x09B8), r16(0x09C6), r16(0x065A) }
    if o.perFrame then
      local pf = o.perFrame(n)
      if pf then frames[#frames][#frames[#frames] + 1] = pf end
    end
    if n >= o.frames then
      kit.off(handle)
      local res = { frames = frames, events = events, ctl36 = ctl36, truncated = (#events >= cap) }
      if o.final then res.final = o.final() end
      kit.finish(res)
    end
  end)
end

-- ROM offsets in [lo, hi) whose bytes equal `bytes` (a list of byte values); used to find the JSR sites of a routine
function b3.scan(lo, hi, bytes)
  local out = {}
  for a = lo, hi - #bytes do
    local ok = true
    for i, b in ipairs(bytes) do
      if emu.read(a + i - 1, PRG) ~= b then ok = false; break end
    end
    if ok then out[#out + 1] = a end
  end
  return out
end

-- input schedule from a list of {frames, {buttons}} segments (frame numbers start at 1)
function b3.schedule(segs)
  local table_ = {}
  local f = 0
  for _, s in ipairs(segs) do
    for _ = 1, s[1] do f = f + 1; table_[f] = s[2] end
  end
  return function(n) return table_[n] end
end

-- decimal ROM offsets used by the B3 suites (names/bank02.json keys unless marked local)
b3.off = {
  DecelerateNS = 177940, ClampSpeeds = 177694, DispatchEastMove = 186076, CancelVerticalPhase = 188666,
  FindSlopeForEastMove = 176571, FindSlopeForWestMove = 176488, DispatchWestMove = 187264,
  PlayerMovementTick = 184272, DispatchNorthMove = 184376, DispatchSouthMove = 185206,
  EastRampDown = 186435, EastRampUp = 186687, WestRampUp = 186758, WestRampDown = 187018,
  WestRampDescend = 187635, WestRampAscend = 187985,
  SlopePhysicsEntry = 177195, SlopeType03Handler = 177464, SlopeType05Handler = 177469, SlopeType0AHandler = 177474,
  SlopeType0CHandler = 177479, SlopeFlatExit = 177488, SlopeFlatDecelerate = 177499,
  DecelerateEW = 177781, DecelResetCounterEW = 177869, ReadDecelerationStep = 177921, ReadDecelerationStepNS = 178080,
  PlayerMoveCollisionTick = 177044,
  -- local labels (0x20000 + bank-02 address)
  DecelEW_SnapZero = 0x20000 + 0xB68C,   -- STZ playerSpeedEw (|speed| < 3)          loc_02B687 + 5
  DecelNS_SnapZero = 0x20000 + 0xB72B,   -- STZ playerSpeedNs (|speed| < 3)          loc_02B726 + 5
  DecelNS_Reset = 0x20000 + 0xB76C,      -- loc_02B76C: STZ slopeStepCounter (NS speed reached zero by a step)
  SlopeMoving_MapCellDown = 0x20000 + 0xB483, SlopeMoving_MapCellUp = 0x20000 + 0xB4A0,
}
