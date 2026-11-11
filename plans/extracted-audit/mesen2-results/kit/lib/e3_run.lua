-- description: E3 main run from S08: log Mode 7 words per frame, pass/tick counts, write censuses, overflow counters, M7SEL writes.
-- requires: mesen_kit, iog_kit, gaia_kit, e3_kit
--
-- e3run.go{ tag=, frames=, input=function(n) -> buttons|nil, stopWhen=function(n) -> bool, dumpAfterRoute={0,2,20,42} }
-- Output files (results dir): E3_<tag>_frames.tsv (one row per frame for n < 520, then every 4th), E3_<tag>_misc.txt, E3_<tag>_census.txt
-- Result: controls (w36, nmi), exec counts and first frames, extent hit counts against the expected store bytes.
e3run = e3run or {}

local function hx(v) return string.format("%04X", v & 0xFFFF) end

function e3run.go(o)
  local OFF = e3.OFF
  local f0 = emu.getState().frameCount
  local S = { w36 = 0, nmi = 0, m7sel = {}, b8w = {}, b6w = {}, bcw = {}, passes = {}, rows = {}, ev = {}, dumps = {} }
  local done = false

  -- positive controls
  emu.addMemoryCallback(function(a) if (a & 0xFFFF) == 0x36 then S.w36 = S.w36 + 1 end end, emu.callbackType.write, 0x36, 0x36, emu.cpuType.snes, emu.memType.snesWorkRam)
  emu.addMemoryCallback(function() S.nmi = S.nmi + 1 end, emu.callbackType.exec, OFF.nmi, OFF.nmi, emu.cpuType.snes, emu.memType.snesPrgRom)

  -- exec counters
  local ex, exFirst = e3.execCounters({
    tickGravity = OFF.tickGravity, adcB8 = OFF.adcB8, passEnd = OFF.passEnd, waitF = OFF.waitF, spawnSplit = OFF.spawnSplit,
    poll = OFF.poll, tilt = OFF.tilt, initM7SEL = OFF.initM7SEL, initLastB8 = OFF.initLastB8, updFill = OFF.updFill, updFrame = OFF.updFrame,
    q1 = OFF.q1, q2 = OFF.q2, q3 = OFF.q3, q4 = OFF.q4, ov1 = OFF.ov1, ov2 = OFF.ov2, ov3 = OFF.ov3, ov4 = OFF.ov4,
    splitEntry = OFF.splitEntry, splitBuild = OFF.splitBuild, splitQueue = OFF.splitQueue,
  })

  -- ordered event list of the first executions (n, $36, name): proves the order controller-pass / Init within one frame
  local evNames = { [OFF.adcB8] = "ADC_B8", [OFF.initM7SEL] = "Init_M7SEL", [OFF.initLastB8] = "Init_STA_B8", [OFF.updFill] = "Update_fill", [OFF.passEnd] = "passEnd", [OFF.spawnSplit] = "spawnSplit", [OFF.tilt] = "tilt" }
  for off, name in pairs(evNames) do
    emu.addMemoryCallback(function()
      if #S.ev < 24 then S.ev[#S.ev + 1] = string.format("n=%d f36=%d %s B8=%s", emu.getState().frameCount - f0, kit.r16(0x36), name, hx(kit.r16(0xB8))) end
    end, emu.callbackType.exec, off, off, emu.cpuType.snes, emu.memType.snesPrgRom)
  end

  emu.addMemoryCallback(function() e3.attributeExtents = false end, emu.callbackType.exec, OFF.updFill, OFF.updFill, emu.cpuType.snes, emu.memType.snesPrgRom)

  -- executions of the known Mode 7 table stores (expected bytes written into the three table extents)
  local expectedBytes = 0
  for off, w in pairs(e3.TABLE_STORES) do
    emu.addMemoryCallback(function() expectedBytes = expectedBytes + w end, emu.callbackType.exec, off, off, emu.cpuType.snes, emu.memType.snesPrgRom)
  end

  -- one row per pass of the zoom-out loop: frame (since load), $36, delta in A, $B8 before the add
  emu.addMemoryCallback(function()
    local st = emu.getState()
    S.passes[#S.passes + 1] = string.format("n=%d f36=%d A=%s B8=%s", st.frameCount - f0, kit.r16(0x36), hx(st["cpu.a"]), hx(kit.r16(0xB8)))
  end, emu.callbackType.exec, OFF.adcB8, OFF.adcB8, emu.cpuType.snes, emu.memType.snesPrgRom)

  -- writers of $B6 / $B8 / $BC (first 14 each) with the low byte written and the PC (next instruction)
  local function wrw(tag, tbl)
    return function(addr, value)
      if (addr & 0xFFFF) % 2 == 0 and #tbl < 14 then
        local st = emu.getState()
        tbl[#tbl + 1] = string.format("n=%d %s lo=%02X pc=%02X:%04X rom=%d", st.frameCount - f0, tag, value, st["cpu.k"], st["cpu.pc"], e3.rom(st["cpu.k"], st["cpu.pc"]))
      end
    end
  end
  emu.addMemoryCallback(wrw("B6", S.b6w), emu.callbackType.write, 0xB6, 0xB6, emu.cpuType.snes, emu.memType.snesWorkRam)
  emu.addMemoryCallback(wrw("B8", S.b8w), emu.callbackType.write, 0xB8, 0xB8, emu.cpuType.snes, emu.memType.snesWorkRam)
  emu.addMemoryCallback(wrw("BC", S.bcw), emu.callbackType.write, 0xBC, 0xBC, emu.cpuType.snes, emu.memType.snesWorkRam)

  -- M7SEL ($211A): every write with value, PC, frame (register callbacks on all banks that mirror the PPU)
  local function onM7(addr, v)
    local st = emu.getState()
    S.m7sel[#S.m7sel + 1] = string.format("n=%d write %06X value=%02X pc=%02X:%04X rom=%d", st.frameCount - f0, addr, v, st["cpu.k"], st["cpu.pc"], e3.rom(st["cpu.k"], st["cpu.pc"]))
  end
  for bank = 0, 0xFF do
    if bank <= 0x3F or (bank >= 0x80 and bank <= 0xBF) then
      emu.addMemoryCallback(onM7, emu.callbackType.write, (bank << 16) | 0x211A, (bank << 16) | 0x211A, emu.cpuType.snes, emu.memType.snesMemory)
    end
  end

  -- write census on the HDMA table regions and the split buffers (hits inside the three table extents are only counted)
  local crows, corder = e3.writeCensus({
    A_7000_77FF = { 0x7000, 0x77FF }, B_7800_7FFF = { 0x7800, 0x7FFF }, C_8000_87FF = { 0x8000, 0x87FF }, S_8800_8FFF = { 0x8800, 0x8FFF },
  })

  if o.input then e3.input(o.input, f0) end

  local lastExt = { A = 0, B = 0, C = 0 }
  local routeN, lastRoute = nil, 0
  local function dumpBuffers(n, tag)
    local function rd(a, len)
      local t = {}
      for i = 0, len - 1 do t[#t + 1] = string.format("%02X", kit.r8(a + i)) end
      return table.concat(t, " ")
    end
    S.dumps[#S.dumps + 1] = string.format("%s n=%d f36=%d bgmodeEven[8800]=%s | bgmodeOdd[8900]=%s | coldataEven[8A00]=%s | coldataOdd[8B00]=%s",
      tag, n, kit.r16(0x36), rd(0x8800, 8), rd(0x8900, 8), rd(0x8A00, 20), rd(0x8B00, 20))
  end

  kit.onFrame(function(f)
    if done then return end
    local st = emu.getState()
    local n = st.frameCount - f0
    local p = e3.ppu7()
    local eh = e3.extentHits
    local dA, dB, dC = eh.A - lastExt.A, eh.B - lastExt.B, eh.C - lastExt.C
    lastExt.A, lastExt.B, lastExt.C = eh.A, eh.B, eh.C
    local route = kit.r16(0xD5A)
    if route ~= 0 and lastRoute == 0 then routeN = n end
    lastRoute = route
    if o.dumpAfterRoute and routeN then
      for _, k in ipairs(o.dumpAfterRoute) do if n == routeN + k then dumpBuffers(n, "route+" .. k) end end
    end
    if n < 520 or n % 4 == 0 then
      S.rows[#S.rows + 1] = string.format("%d\t%d\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%d\t%d\t%d\t%d\t%d\t%02X%02X\t%d,%d,%d",
        n, kit.r16(0x36), hx(kit.r16(0xB6)), hx(kit.r16(0xB8)), hx(kit.r16(0xBC)), hx(kit.r16(0xC2)), hx(kit.r16(0xC4)), hx(kit.r16(0xC6)), hx(kit.r16(0xC8)),
        hx(kit.r16(0xCA)), hx(kit.r16(0xCC)), hx(kit.r16(0x644)), hx(kit.r16(0xD58)), hx(route), p.mode or -1,
        p.m0 or 0, p.m1 or 0, p.m2 or 0, p.m3 or 0, kit.r8(0x8802), kit.r8(0x8902), dA, dB, dC)
    end
    if (o.stopWhen and o.stopWhen(n)) or n >= o.frames then
      done = true
      local rows = { "n\tf36\tB6\tB8\tBC\tC2\tC4\tC6\tC8\tCA\tCC\tscene\tchoice\troute\tbgmode\tM7A\tM7B\tM7C\tM7D\tbm2(8802,8902)\textentHitsABC" }
      for _, r in ipairs(S.rows) do rows[#rows + 1] = r end
      e3.writeChunks(string.format("E3_%s_frames.tsv", o.tag), rows)
      e3.writeChunks(string.format("E3_%s_census.txt", o.tag), e3.censusLines(crows, corder))
      local misc = { string.format("routeSetN=%s", tostring(routeN)) }
      for _, l in ipairs(S.ev) do misc[#misc + 1] = "event " .. l end
      for _, l in ipairs(S.passes) do misc[#misc + 1] = "pass " .. l end
      for _, l in ipairs(S.m7sel) do misc[#misc + 1] = "M7SEL " .. l end
      for _, l in ipairs(S.b8w) do misc[#misc + 1] = "W " .. l end
      for _, l in ipairs(S.b6w) do misc[#misc + 1] = "W " .. l end
      for _, l in ipairs(S.bcw) do misc[#misc + 1] = "W " .. l end
      for _, l in ipairs(S.dumps) do misc[#misc + 1] = "dump " .. l end
      e3.writeChunks(string.format("E3_%s_misc.txt", o.tag), misc)
      local ehh = e3.extentHits
      kit.finish({ n = n, w36 = S.w36, nmi = S.nmi, ex = ex, exFirst = exFirst, passes = #S.passes, m7sel = #S.m7sel, rows = #S.rows, census = #corder, routeSetN = routeN,
                   extentHits = ehh, extentTotal = ehh.A + ehh.B + ehh.C, expectedBytes = expectedBytes, unknownBytes = ehh.A + ehh.B + ehh.C - expectedBytes,
                   B6 = kit.r16(0xB6), B8 = kit.r16(0xB8), BC = kit.r16(0xBC), scene = kit.r16(0x644), choice = kit.r16(0xD58), route = kit.r16(0xD5A) })
    end
  end)
end
