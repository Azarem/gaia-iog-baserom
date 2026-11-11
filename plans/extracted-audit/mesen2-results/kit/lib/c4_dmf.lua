-- description: C4 instrumentation: displayModeFlags ($09EC word, $09ED = hudDisableFlag) setters / clearers per bit and PC, readers per PC, Bg3TilemapVramDma / UpdateHUD exec counts, scene log, word timeline.
-- requires: mesen_kit, iog_kit, gaia_kit
--
-- run_script {includes={"gaia_kit","c4_dmf"}, code='c4.run{frames=N, nmi=33528, marks={Bg3Dma=176184,...}, input=fn(n), at={[n]=fn}, tick=fn, final=fn}'}
--
-- All memory callbacks run BEFORE the access; the PC a callback reports is the address AFTER the instruction that made the access.
-- A 16-bit access fires two byte callbacks (low, high) with the same PC. Frame numbers are the emulator's absolute frame counter.
-- Offsets are decimal PRG (ROM file) offsets of the O ROM (db-us/names keys).
--
-- Result keys:
--   control   : nmiExec (exec count of PRG `nmi`), w36 ($36 write count: the INC $36 in the NMI), frames run
--   setters   : rows "set|clr bitNN K:PC n=.. f=.. sc=.. v=.." one per (bit, direction, PC): bit 0-15 of the word ($09ED bit b = word bit 8+b)
--   readers   : rows "R byteB K:PC n=.. f=.. sc=.. or=.." one per (byte, PC): or = OR of every value read by that PC
--   writes    : total byte writes to $09EC-$09ED, and how many changed no bit
--   marks     : exec counters of o.marks (n, first frame); Bg3 flag histogram under marks.Bg3Dma.hist (word & $8031 at entry)
--   scenes    : change-only rows {f, scene}; word : change-only rows {f, scene, word} sampled at every frame end
c4 = c4 or {}

local WR  = emu.memType.snesWorkRam
local PRG = emu.memType.snesPrgRom
local CPU = emu.cpuType.snes

local function hex(v, w) return string.format("%0" .. (w or 2) .. "X", v) end

function c4.vram(byteAddr, nWords)
  local t = {}
  for i = 0, nWords - 1 do
    t[#t + 1] = hex(emu.read(byteAddr + 2 * i, emu.memType.snesVideoRam) | (emu.read(byteAddr + 2 * i + 1, emu.memType.snesVideoRam) << 8), 4)
  end
  return t
end

function c4.run(o)
  local S = { cur = 0, nmi = 0, w36 = 0, wTotal = 0, wSame = 0, setters = {}, readers = {}, marks = {}, scenes = {}, word = {} }
  local setList, readList = {}, {}
  local function add(list, row, cap) if #list < (cap or 60) then list[#list + 1] = row end end

  -- controls ----------------------------------------------------------------------------------
  if o.nmi then
    emu.addMemoryCallback(function() S.nmi = S.nmi + 1 end, emu.callbackType.exec, o.nmi, o.nmi, CPU, PRG)
  end
  emu.addMemoryCallback(function(a, v) if (a & 0xFFFF) == 0x36 then S.w36 = S.w36 + 1 end end,
    emu.callbackType.write, 0x36, 0x36, CPU, WR)

  -- setters and clearers ----------------------------------------------------------------------
  emu.addMemoryCallback(function(a, v)
    local lo = a & 0xFFFF
    if lo < 0x09EC or lo > 0x09ED then return end
    S.wTotal = S.wTotal + 1
    local old = emu.read(lo, WR)
    local d = old ~ v
    if d == 0 then S.wSame = S.wSame + 1; return end
    local st = emu.getState()
    local pc = hex(st["cpu.k"], 2) .. ":" .. hex(st["cpu.pc"], 4)
    for b = 0, 7 do
      if ((d >> b) & 1) == 1 then
        local bit = b + (lo - 0x09EC) * 8
        local dir = (((v >> b) & 1) == 1) and "set" or "clr"
        local key = dir .. " bit" .. string.format("%02d", bit) .. " " .. pc
        local e = S.setters[key]
        if not e then
          e = { n = 0, f = st["frameCount"], sc = kit.r16(0x0644), v = v, old = old }
          S.setters[key] = e
          setList[#setList + 1] = key
        end
        e.n = e.n + 1
      end
    end
  end, emu.callbackType.write, 0x09EC, 0x09ED, CPU, WR)

  -- readers -----------------------------------------------------------------------------------
  emu.addMemoryCallback(function(a, v)
    local lo = a & 0xFFFF
    if lo < 0x09EC or lo > 0x09ED then return end
    local st = emu.getState()
    local key = "R byte" .. (lo - 0x09EC) .. " " .. hex(st["cpu.k"], 2) .. ":" .. hex(st["cpu.pc"], 4)
    local e = S.readers[key]
    if not e then
      e = { n = 0, f = st["frameCount"], sc = kit.r16(0x0644), orv = 0 }
      S.readers[key] = e
      readList[#readList + 1] = key
    end
    e.n = e.n + 1
    e.orv = e.orv | (v or 0)
  end, emu.callbackType.read, 0x09EC, 0x09ED, CPU, WR)

  -- exec marks --------------------------------------------------------------------------------
  for name, off in pairs(o.marks or {}) do
    local m = { n = 0, hist = {} }
    S.marks[name] = m
    emu.addMemoryCallback(function()
      m.n = m.n + 1
      if m.n == 1 then m.first = emu.getState()["frameCount"] end
      if name == "Bg3Dma" then
        local w = kit.r16(0x09EC) & 0x8031
        local k = hex(w, 4)
        m.hist[k] = (m.hist[k] or 0) + 1
      end
    end, emu.callbackType.exec, off, off, CPU, PRG)
  end

  -- input -------------------------------------------------------------------------------------
  if o.input then
    emu.addEventCallback(function()
      local b = o.input(S.cur + 1)
      if b then
        local t = {}
        for _, x in ipairs(b) do t[x] = true end
        emu.setInput(t, 0)
      end
    end, emu.eventType.inputPolled)
  end

  -- frame loop --------------------------------------------------------------------------------
  local lastScene, lastWord = nil, nil
  local n = 0
  kit.onFrame(function()
    n = n + 1
    S.cur = n
    local f = emu.getState()["frameCount"]
    local sc = kit.r16(0x0644)
    if sc ~= lastScene then lastScene = sc; add(S.scenes, { f = f, scene = hex(sc, 4) }, 60) end
    local w = kit.r16(0x09EC)
    if w ~= lastWord then lastWord = w; add(S.word, { f = f, sc = hex(sc, 4), w = hex(w, 4) }, o.wordCap or 80) end
    if o.at and o.at[n] then o.at[n](n, S) end
    if o.tick then o.tick(n, S) end
    if n >= o.frames then
      table.sort(setList)
      table.sort(readList)
      local setters, readers = {}, {}
      for _, k in ipairs(setList) do
        local e = S.setters[k]
        setters[#setters + 1] = string.format("%s n=%d f=%d sc=%s v=%02X old=%02X", k, e.n, e.f, hex(e.sc, 4), e.v, e.old)
      end
      for _, k in ipairs(readList) do
        local e = S.readers[k]
        readers[#readers + 1] = string.format("%s n=%d f=%d sc=%s or=%02X", k, e.n, e.f, hex(e.sc, 4), e.orv)
      end
      local res = {
        tag = o.tag, control = { nmiExec = S.nmi, w36 = S.w36, frames = n },
        setters = setters, readers = readers, writes = { total = S.wTotal, noChange = S.wSame },
        marks = S.marks, scenes = S.scenes, word = S.word,
        endWord = hex(kit.r16(0x09EC), 4), endScene = hex(sc, 4),
      }
      if o.final then res.final = o.final(S) end
      kit.finish(res)
    end
  end)
end
