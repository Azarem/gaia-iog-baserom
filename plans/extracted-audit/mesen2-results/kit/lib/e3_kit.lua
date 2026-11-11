-- description: E3 (Mode 7 and the world map): per-frame Mode 7 parameter log, HDMA-table write census, divisor-overflow counters, M7SEL watch.
-- requires: mesen_kit, iog_kit, gaia_kit
--
-- ROM offsets (decimal, `; {n}` tags of extract:lt, ROM O):
--   ArrivalAndTravelSetup: COP TickGravity 238462, ADC $00B8 238469, loop-end yield 238477, first line after the 44 passes 238479,
--                          WaitByte #0F 238484, SpawnThinker WorldMapSplitEffect 238487, poll LDA $0D5A 238494, TiltPhaseStart 238500
--   Mode7PerspectiveInit: STA $M7SEL 239942, last STA $00B8 240002; Mode7PerspectiveUpdate 240005 (fill), 240061 (per frame)
--   quadrant routines 240173 / 240254 / 240335 / 240418 (JSR NormalizeDivisor); overflow INC $03 at 240239 / 240320 / 240403 / 240486
--   WorldMapSplitEffect 239678, BuildSplitTables 239782, QueueSplitTables 239750
-- WRAM offsets: $00B6 increment, $00B8 divisor, $00BC rotation, $00C2-$00CD six words, $0D58 choice, $0D5A route, $0036 frame counter.
e3 = e3 or {}

local WR  = emu.memType.snesWorkRam
local PRG = emu.memType.snesPrgRom
local CPU = emu.cpuType.snes
local SM  = emu.memType.snesMemory

e3.OFF = {
  tickGravity = 238462, adcB8 = 238469, passEnd = 238479, waitF = 238484, spawnSplit = 238487, poll = 238494, tilt = 238500,
  initM7SEL = 239942, initLastB8 = 240002, updFill = 240005, updFrame = 240061,
  q1 = 240173, q2 = 240254, q3 = 240335, q4 = 240418,
  ov1 = 240239, ov2 = 240320, ov3 = 240403, ov4 = 240486,
  splitEntry = 239678, splitBuild = 239782, splitQueue = 239750, nmi = 33528,
}

-- ROM offset of the code address K:PC (HiROM, banks $80-$BF/$C0-$FF with PC >= $8000)
function e3.rom(k, pc)
  if pc >= 0x8000 then return ((k & 0x3F) << 16) | pc end
  return ((k & 0x3F) << 16) | pc
end

-- chunked writeFile (hazard 20: at most 3000 bytes per call)
function e3.writeChunks(name, lines)
  local buf, first = {}, true
  local function flush()
    if #buf > 0 then
      emu.mcp.writeFile(name, table.concat(buf, "\n") .. "\n", not first)
      first = false
      buf = {}
    end
  end
  local size = 0
  for _, l in ipairs(lines) do
    buf[#buf + 1] = l
    size = size + #l + 1
    if size > 2500 then flush(); size = 0 end
  end
  flush()
end

-- exec counters on ROM offsets: returns table name -> count, and names -> first frame
function e3.execCounters(map)
  local c, first = {}, {}
  for name, off in pairs(map) do
    c[name] = 0
    emu.addMemoryCallback(function()
      c[name] = c[name] + 1
      if not first[name] then first[name] = emu.getState().frameCount end
    end, emu.callbackType.exec, off, off, CPU, PRG)
  end
  return c, first
end

-- Mode 7 table writers (ROM offsets of the instruction start) and the bytes each store writes
e3.TABLE_STORES = {}
for _, off in ipairs({ 240022, 240026, 240030, 240043, 240047, 240051 }) do e3.TABLE_STORES[off] = 1 end      -- fill loop and terminators (SEP #$20: 1 byte)
for _, off in ipairs({ 240197, 240220, 240228, 240278, 240301, 240309, 240361, 240384, 240392, 240444, 240467, 240475 }) do e3.TABLE_STORES[off] = 2 end -- quadrant stores (16 bit)
-- the three table extents (WRAM offsets): a store inside them is only COUNTED here; the census subtracts the executions of the known
-- stores (exec counters) and anything left over is an unknown writer. emu.getState() per byte made the run 40x slower.
e3.EXTENTS = { A = { 0x7000, 0x72A1 }, B = { 0x7800, 0x7AA1 }, C = { 0x8000, 0x82A1 } }

-- write census of WRAM ranges: unique "range K:PC (rom offset of the NEXT instruction)" with count, first frame and address span
-- ranges = { name = {lo, hi} } as WRAM offsets
function e3.writeCensus(ranges)
  local rows, order = {}, {}
  e3.extentHits = { A = 0, B = 0, C = 0 }
  e3.attributeExtents = true   -- until the first Mode7PerspectiveUpdate fill: every store inside an extent is attributed (K:PC) too
  for name, r in pairs(ranges) do
    emu.addMemoryCallback(function(addr, value)
      local a0 = addr & 0xFFFF
      local nm = name
      for en, ex in pairs(e3.EXTENTS) do
        if a0 >= ex[1] and a0 <= ex[2] then
          e3.extentHits[en] = e3.extentHits[en] + 1
          if not e3.attributeExtents then return end
          nm = name .. "_inExtent" .. en
        end
      end
      local st = emu.getState()
      local key = string.format("%s %02X:%04X", nm, st["cpu.k"], st["cpu.pc"])
      local row = rows[key]
      local a = addr & 0xFFFF
      if not row then
        row = { n = 0, f = st.frameCount, lo = a, hi = a, rom = e3.rom(st["cpu.k"], st["cpu.pc"]) }
        rows[key] = row
        order[#order + 1] = key
      end
      row.n = row.n + 1
      if a < row.lo then row.lo = a end
      if a > row.hi then row.hi = a end
    end, emu.callbackType.write, r[1], r[2], CPU, WR)
  end
  return rows, order
end

function e3.censusLines(rows, order)
  table.sort(order)
  local out = {}
  for _, key in ipairs(order) do
    local r = rows[key]
    out[#out + 1] = string.format("%s next=%d n=%d first_frame=%d span=%04X-%04X", key, r.rom, r.n, r.f, r.lo, r.hi)
  end
  return out
end

-- PPU Mode 7 view of the emulator state
function e3.ppu7()
  local s = emu.getState()
  return {
    mode = s["ppu.bgMode"], large = s["ppu.mode7.largeMap"], fill0 = s["ppu.mode7.fillWithTile0"],
    hflip = s["ppu.mode7.horizontalMirroring"], vflip = s["ppu.mode7.verticalMirroring"],
    cx = s["ppu.mode7.centerX"], cy = s["ppu.mode7.centerY"], hs = s["ppu.mode7.hscroll"], vs = s["ppu.mode7.vscroll"],
    m0 = s["ppu.mode7.matrix[0]"], m1 = s["ppu.mode7.matrix[1]"], m2 = s["ppu.mode7.matrix[2]"], m3 = s["ppu.mode7.matrix[3]"],
    fixed = s["ppu.fixedColor"],
  }
end

-- buttons from the inputPolled event: fn(n) returns a table such as {down=true} or nil
function e3.input(fn, f0)
  emu.addEventCallback(function()
    local n = emu.getState().frameCount - f0
    local b = fn(n)
    if b then emu.setInput(b, 0) end
  end, emu.eventType.inputPolled)
end
