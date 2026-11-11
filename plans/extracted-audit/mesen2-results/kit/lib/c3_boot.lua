-- description: C3 instrumentation: boot sequence from reset (power or soft): MEMSEL ($420D) and APUIO ($2140-$2143) writes, SystemInit milestones, the warmboot byte $0100, event flag byte $0A02, sceneNext / sceneCurrent.
-- requires: mesen_kit, iog_kit, gaia_kit
--
-- run_script {includes={"gaia_kit","c3_boot"}, code='c3.run{frames=N, nmi=33528, marks={Name=prgOffset,...}}'}
--
-- All callbacks run BEFORE the access / instruction; the PC a memory callback reports is the address AFTER the instruction.
-- Every frame number in the result is relative to the frame counter at script load (f0: 0 after a power reset, the running count after a soft reset).
-- Offsets are decimal PRG (ROM file) offsets of the O ROM (db-us/names keys).
--
--   start    : f0, the first instruction address, WRAM $0100 / $0A02 / $0642 / $0644 at load (shows what a soft reset kept)
--   control  : NMI exec count (PRG `nmi`) and $36 write count (the INC $36 in the NMI)
--   marks    : exec counters of the requested PRG offsets: n, first / last frame, enableFastRom (MEMSEL bit 0 as the hardware holds it)
--              and cpuSpeed (master clocks per access of the last bus cycle) at the first hit; `seq` lists the first hits in order
--   memsel   : every write to $420D at any of the 128 bank aliases: frame, PC after the store, value, enableFastRom before the store
--   apuio    : writes to $2140-$2143 (all aliases): total, first / last frame (counter bucket), frames with writes, per-frame sample
--              (frame, PC, enableFastRom, cpuSpeed at the first write of each frame), perFrame = writes per frame (frames 0-130)
--   marks[x].mc : masterClock (master clocks since power) at the first hit
--   inidisp  : writes to $2100: change-only rows (frame, value, PC) and the first value with bit 7 clear
--   wram     : rows for writes to sceneNext ($0642-3), sceneCurrent ($0644-5), event flag byte $0A02 (old and new value), $0100 (write and read)
--   fast     : change-only rows of enableFastRom sampled at every frame end
c3 = c3 or {}

local WR  = emu.memType.snesWorkRam
local SM  = emu.memType.snesMemory
local PRG = emu.memType.snesPrgRom
local CPU = emu.cpuType.snes

local function hex(v, w) return string.format("%0" .. (w or 2) .. "X", v) end

function c3.run(o)
  local st0 = emu.getState()
  local f0 = st0["frameCount"]
  local S = {
    f0 = f0, cur = 0, nmi = 0, w36 = 0,
    marks = {}, seq = {}, memsel = {}, apu = { n = 0, first = nil, last = nil, frames = 0, samples = {}, fastHist = {}, spdHist = {}, perFrame = {} },
    inidisp = {}, firstOn = nil, wram = {}, fast = {}, scene = {}, curDelta = {},
  }
  local function rel(st) return st["frameCount"] - f0 end
  local function fastOf(st) return st["internalRegisters.enableFastRom"] and 1 or 0 end
  local function add(list, row, cap) if #list < (cap or 40) then list[#list + 1] = row end end

  S.start = {
    pc = hex((st0["cpu.k"] << 16) | st0["cpu.pc"], 6), f0 = f0,
    w0100 = emu.read(0x0100, WR), w0A02 = emu.read(0x0A02, WR),
    sceneNext = kit.r16(0x0642), sceneCurrent = kit.r16(0x0644), w36 = kit.r16(0x0036),
    fast = fastOf(st0), spd = st0["memoryManager.cpuSpeed"],
  }

  -- controls ----------------------------------------------------------------------------------
  emu.addMemoryCallback(function() S.nmi = S.nmi + 1 end, emu.callbackType.exec, o.nmi, o.nmi, CPU, PRG)
  emu.addMemoryCallback(function(a) if (a & 0xFFFF) == 0x36 then S.w36 = S.w36 + 1 end end,
    emu.callbackType.write, 0x36, 0x36, CPU, WR)

  -- exec marks --------------------------------------------------------------------------------
  for name, off in pairs(o.marks or {}) do
    S.marks[name] = { n = 0 }
    emu.addMemoryCallback(function()
      local st = emu.getState()
      local e = S.marks[name]
      e.n = e.n + 1
      e.last = rel(st)
      if e.n == 1 then
        e.first = rel(st)
        e.fast = fastOf(st)
        e.spd = st["memoryManager.cpuSpeed"]
        e.mc = st["masterClock"]
        e.nmiAt = S.nmi
        add(S.seq, name .. "@" .. e.first, 60)
      end
    end, emu.callbackType.exec, off, off, CPU, PRG)
  end

  -- MEMSEL ($420D), every bank alias ---------------------------------------------------------
  local function onMemsel(a, v)
    if (a & 0xFFFF) ~= 0x420D then return end
    local st = emu.getState()
    add(S.memsel, { f = rel(st), pc = hex((st["cpu.k"] << 16) | st["cpu.pc"], 6), v = v, fastBefore = fastOf(st),
                    spdBefore = st["memoryManager.cpuSpeed"] }, 20)
  end
  -- APUIO ($2140-$2143), every bank alias ----------------------------------------------------
  local lastApuCur = -1
  local function onApu(a, v)
    local lo = a & 0xFFFF
    if lo < 0x2140 or lo > 0x2143 then return end
    local A = S.apu
    A.n = A.n + 1
    A.last = S.cur
    if S.cur <= (o.perFrameMax or 130) then local key = tostring(S.cur); A.perFrame[key] = (A.perFrame[key] or 0) + 1 end
    if S.cur ~= lastApuCur then
      lastApuCur = S.cur
      A.frames = A.frames + 1
      local st = emu.getState()
      if not A.first then A.first = rel(st); A.firstPc = hex((st["cpu.k"] << 16) | st["cpu.pc"], 6); A.firstVal = v; A.firstAddr = lo end
      local fv = fastOf(st)
      A.fastHist[fv] = (A.fastHist[fv] or 0) + 1
      local sp = st["memoryManager.cpuSpeed"]
      A.spdHist[sp] = (A.spdHist[sp] or 0) + 1
      if A.frames <= 4 or A.frames % 8 == 0 then
        add(A.samples, { f = rel(st), pc = hex((st["cpu.k"] << 16) | st["cpu.pc"], 6), fast = fv, spd = sp, n = A.n }, 40)
      end
      if S.cur ~= rel(st) then add(S.curDelta, { cur = S.cur, rel = rel(st) }, 4) end
    end
  end
  -- INIDISP ($2100) ----------------------------------------------------------------------------
  local lastIni = nil
  local function onIni(a, v)
    if (a & 0xFFFF) ~= 0x2100 then return end
    if v == lastIni then return end
    lastIni = v
    local st = emu.getState()
    local row = { f = rel(st), v = v, pc = hex((st["cpu.k"] << 16) | st["cpu.pc"], 6) }
    add(S.inidisp, row, 24)
    if (v & 0x80) == 0 and not S.firstOn then S.firstOn = row end
  end
  for bank = 0, 0xFF do
    if bank <= 0x3F or (bank >= 0x80 and bank <= 0xBF) then
      local b = bank << 16
      emu.addMemoryCallback(onMemsel, emu.callbackType.write, b | 0x420D, b | 0x420D, CPU, SM)
      emu.addMemoryCallback(onApu, emu.callbackType.write, b | 0x2140, b | 0x2143, CPU, SM)
      emu.addMemoryCallback(onIni, emu.callbackType.write, b | 0x2100, b | 0x2100, CPU, SM)
    end
  end

  -- WRAM watches -------------------------------------------------------------------------------
  local function wramRow(tag, lo0, lo1, withOld, cap, kind)
    emu.addMemoryCallback(function(a, v)
      local lo = a & 0xFFFF
      if lo < lo0 or lo > lo1 then return end
      local st = emu.getState()
      local row = { t = tag, k = kind, f = rel(st), a = hex(lo, 4), v = v, pc = hex((st["cpu.k"] << 16) | st["cpu.pc"], 6) }
      if withOld then row.old = emu.read(lo, WR) end
      if kind == "r" then row.v = emu.read(lo, WR) end
      add(S.wram, row, cap)
    end, kind == "r" and emu.callbackType.read or emu.callbackType.write, lo0, lo1, CPU, WR)
  end
  wramRow("sceneNext", 0x0642, 0x0643, true, 30, "w")
  wramRow("sceneCurrent", 0x0644, 0x0645, true, 20, "w")
  wramRow("flagByte0A02", 0x0A02, 0x0A02, true, 20, "w")
  wramRow("warm0100", 0x0100, 0x0100, true, 12, "w")
  wramRow("warm0100", 0x0100, 0x0100, false, 12, "r")

  -- frame loop ---------------------------------------------------------------------------------
  local n = 0
  local lastFast, lastScene = nil, nil
  kit.onFrame(function()
    n = n + 1
    S.cur = n                       -- frames completed since load (the next frame is bucket n)
    local st = emu.getState()
    local fv = fastOf(st)
    if fv ~= lastFast then lastFast = fv; add(S.fast, { f = rel(st), fast = fv }, 24) end
    local sc = kit.r16(0x0644)
    if sc ~= lastScene then lastScene = sc; add(S.scene, { f = rel(st), scene = hex(sc, 4), next = hex(kit.r16(0x0642), 4), a02 = emu.read(0x0A02, WR) }, 16) end
    if o.tick then o.tick(n, S) end
    if n >= o.frames then
      local st1 = emu.getState()
      local res = {
        start = S.start, frames = n, endFrame = rel(st1), control = { nmiExec = S.nmi, w36Writes = S.w36 },
        marks = S.marks, seq = S.seq, memsel = S.memsel, apuio = S.apu, inidisp = S.inidisp, firstDisplayOn = S.firstOn,
        wram = S.wram, fast = S.fast, scene = S.scene, curDelta = S.curDelta,
        endState = { w0100 = emu.read(0x0100, WR), w0A02 = emu.read(0x0A02, WR), sceneCurrent = kit.r16(0x0644),
                     sceneNext = kit.r16(0x0642), w36 = kit.r16(0x0036) },
      }
      if o.final then res.final = o.final(S) end
      kit.finish(res)
    end
  end)
end
