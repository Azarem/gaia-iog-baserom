-- description: E3 scenes that run Mode7PerspectiveUpdate without the world-map Init ($8C prologue, $59 Sky Garden crash, $C0 Angkor vision): warp from S01r, census of every writer of $7000-$8FFF after the first table fill, DMAs sourced from there, M7SEL writes, formula check of the tables.
-- requires: mesen_kit, iog_kit, gaia_kit, e3_kit
--
-- e3scene.go{ tag=, scene=id, stop=N (frames after the load), warpAt=3, shotAt={n,...} (rows only), from=1 }
-- Frame n counts from the load of the base state. The warp writes sceneNext ($0642) once $0642 is 0 at n >= warpAt.
e3scene = e3scene or {}

local function s16(lo, hi) local v = lo | (hi << 8); if v >= 0x8000 then v = v - 0x10000 end; return v end

function e3scene.go(o)
  local OFF = e3.OFF
  local f0 = emu.getState().frameCount
  local done = false
  local w36, nmi = 0, 0
  emu.addMemoryCallback(function(a) if (a & 0xFFFF) == 0x36 then w36 = w36 + 1 end end, emu.callbackType.write, 0x36, 0x36, emu.cpuType.snes, emu.memType.snesWorkRam)
  emu.addMemoryCallback(function() nmi = nmi + 1 end, emu.callbackType.exec, OFF.nmi, OFF.nmi, emu.cpuType.snes, emu.memType.snesPrgRom)

  -- exec counters
  local ex, exFirst = e3.execCounters({ updFill = OFF.updFill, updFrame = OFF.updFrame, initM7SEL = OFF.initM7SEL,
    q1 = OFF.q1, q2 = OFF.q2, q3 = OFF.q3, q4 = OFF.q4, ov1 = OFF.ov1, ov2 = OFF.ov2, ov3 = OFF.ov3, ov4 = OFF.ov4 })
  local firstN = {}
  for k, v in pairs(exFirst) do firstN[k] = v end
  emu.addMemoryCallback(function()
    e3.attributeExtents = false
    if not o.fillN then
      o.fillN = emu.getState().frameCount - f0
      local h = e3.extentHits
      o.preFill = h.A + h.B + h.C
    end
  end,
    emu.callbackType.exec, OFF.updFill, OFF.updFill, emu.cpuType.snes, emu.memType.snesPrgRom)

  emu.addMemoryCallback(function() o.lastUpdN = emu.getState().frameCount - f0 end, emu.callbackType.exec, OFF.updFrame, OFF.updFrame, emu.cpuType.snes, emu.memType.snesPrgRom)
  local expectedBytes = 0
  for off, w in pairs(e3.TABLE_STORES) do
    emu.addMemoryCallback(function() expectedBytes = expectedBytes + w end, emu.callbackType.exec, off, off, emu.cpuType.snes, emu.memType.snesPrgRom)
  end

  -- M7SEL writes on every bank alias
  local m7sel = {}
  local function onM7(addr, v)
    local st = emu.getState()
    if #m7sel < 12 then
      m7sel[#m7sel + 1] = string.format("n=%d write %06X value=%02X pc=%02X:%04X rom=%d", st.frameCount - f0, addr, v, st["cpu.k"], st["cpu.pc"], e3.rom(st["cpu.k"], st["cpu.pc"]))
    end
  end
  for bank = 0, 0xBF do
    if bank <= 0x3F or bank >= 0x80 then
      emu.addMemoryCallback(onM7, emu.callbackType.write, (bank << 16) | 0x211A, (bank << 16) | 0x211A, emu.cpuType.snes, emu.memType.snesMemory)
    end
  end

  -- general DMA starts ($420B): channels whose source is bank $7E, $7000-$8FFF (the table area) are recorded with the PC; all others only counted
  local dmaTotal, dmaFromArea, dmaRows, dmaOrder = 0, 0, {}, {}
  local function onMdma(addr, v)
    local st = emu.getState()
    for c = 0, 7 do
      if (v >> c) & 1 == 1 then
        dmaTotal = dmaTotal + 1
        local p = "dmaController.channel[" .. c .. "]."
        local sb, sa = st[p .. "srcBank"] or 0, st[p .. "srcAddress"] or 0
        if sb == 0x7E and sa >= 0x7000 and sa <= 0x8FFF then
          dmaFromArea = dmaFromArea + 1
          local key = string.format("ch%d src=%02X:%04X dest=21%02X size=%d pc=%02X:%04X phase=%s", c, sb, sa, st[p .. "destAddress"] or 0, st[p .. "transferSize"] or 0,
            st["cpu.k"], st["cpu.pc"], e3.attributeExtents and "pre" or "post")
          local r = dmaRows[key]
          if not r then r = { n = 0, f = st.frameCount - f0 }; dmaRows[key] = r; dmaOrder[#dmaOrder + 1] = key end
          r.n = r.n + 1
        end
      end
    end
  end
  for bank = 0, 0xBF do
    if bank <= 0x3F or bank >= 0x80 then
      emu.addMemoryCallback(onMdma, emu.callbackType.write, (bank << 16) | 0x420B, (bank << 16) | 0x420B, emu.cpuType.snes, emu.memType.snesMemory)
    end
  end

  -- write census (the three extents are counted; attributed with K:PC only before the first fill)
  local crows, corder = e3.writeCensus({
    A_7000_77FF = { 0x7000, 0x77FF }, B_7800_7FFF = { 0x7800, 0x7FFF }, C_8000_87FF = { 0x8000, 0x87FF }, S_8800_8FFF = { 0x8800, 0x8FFF },
  })

  local rows = { "n\tf36\tscene\tB6\tB8\tBC\tbg\tM7SEL?\tA0\tA223\tB0\tB223\tC0\tC223\texpA0\texpA223\texpB0\texpB223" }
  local warped, arrivedN = false, nil
  local worst = { relA = 0, relB = 0, nA = nil, nB = nil, samples = 0 }

  local function exp16(c, i)  -- |c| / divisor_i, 8.8 value as the hardware divider would give it (float estimate)
    local b6, b8 = kit.r16(0xB6), kit.r16(0xB8)
    local d = (b8 * 256 + i * b6) / 256.0
    return c / d
  end

  kit.onFrame(function()
    if done then return end
    local st = emu.getState()
    local n = st.frameCount - f0
    if not warped and n >= (o.warpAt or 3) and kit.r16(0x642) == 0 then
      emu.write(0x642, o.scene & 0xFF, emu.memType.snesWorkRam); emu.write(0x643, (o.scene >> 8) & 0xFF, emu.memType.snesWorkRam)
      warped = true; o.warpN = n
    end
    local sc = kit.r16(0x644)
    if warped and not arrivedN and sc == o.scene and kit.r16(0x642) == 0 then arrivedN = n end
    if o.poke then o.poke(n) end
    -- once the scene variable leaves the target scene, attribute every extent write again and snapshot the counters
    if arrivedN and sc ~= o.scene then
      if not o.leftN then
        o.leftN = n
        local h = e3.extentHits
        o.hitsAtLeft = h.A + h.B + h.C
        o.expAtLeft = expectedBytes
      end
      e3.attributeExtents = true
    end
    local upd = ex.updFrame
    if upd > 0 and o.lastUpdN == n and (n % (o.every or 8) == 0 or n <= (o.denseUntil or 0)) then
      local p = e3.ppu7()
      local function w(base, i) local a = base + 3 * i; return s16(kit.r8(a + 1), kit.r8(a + 2)) end
      local bc = kit.r16(0xBC) & 0x1FF
      local th = 2 * math.pi * bc / 512
      local cs, sn = math.cos(th) * 32767, math.sin(th) * 32767
      local eA0, eA223 = exp16(math.abs(cs), 0), exp16(math.abs(cs), 223)
      local sB0, sB223 = (sn >= 0) and 1 or -1, (sn >= 0) and 1 or -1
      local eB0, eB223 = sB0 * exp16(math.abs(sn), 0), sB223 * exp16(math.abs(sn), 223)
      if cs < 0 then eA0, eA223 = -eA0, -eA223 end
      local a0, a223, b0, b223, c0, c223 = w(0x7000, 0), w(0x7000, 223), w(0x7800, 0), w(0x7800, 223), w(0x8000, 0), w(0x8000, 223)
      rows[#rows + 1] = string.format("%d\t%d\t%02X\t%04X\t%04X\t%04X\t%s\t%s\t%d\t%d\t%d\t%d\t%d\t%d\t%.1f\t%.1f\t%.1f\t%.1f",
        n, kit.r16(0x36), sc, kit.r16(0xB6), kit.r16(0xB8), kit.r16(0xBC), tostring(p.mode), p.large and "L" or "-", a0, a223, b0, b223, c0, c223, eA0, eA223, eB0, eB223)
      -- relative deviation with a floor of 3 units (quantisation)
      local function rel(a, e) return math.abs(a - e) / math.max(3, math.abs(e)) end
      local rA = math.max(rel(a0, eA0), rel(a223, eA223))
      local rB = math.max(rel(b0, eB0), rel(b223, eB223))
      worst.samples = worst.samples + 1
      if rA > worst.relA then worst.relA = rA; worst.nA = n end
      if rB > worst.relB then worst.relB = rB; worst.nB = n end
    end
    if n >= o.stop then
      done = true
      e3.writeChunks(string.format("E3_SC_%s_rows.tsv", o.tag), rows)
      local cl = e3.censusLines(crows, corder)
      local dl = {}
      for _, k in ipairs(dmaOrder) do dl[#dl + 1] = string.format("%s n=%d first_frame=%d", k, dmaRows[k].n, dmaRows[k].f) end
      local all = {}
      for _, l in ipairs(cl) do all[#all + 1] = "census " .. l end
      for _, l in ipairs(dl) do all[#all + 1] = "dma " .. l end
      for _, l in ipairs(m7sel) do all[#all + 1] = "M7SEL " .. l end
      e3.writeChunks(string.format("E3_SC_%s_census.txt", o.tag), all)
      local ehh = e3.extentHits
      kit.finish({ n = n, start = f0, warpN = o.warpN, arrivedN = arrivedN, scene = sc, w36 = w36, nmi = nmi, ex = ex, exFirst = exFirst, fillN = o.fillN,
        extentHits = ehh, extentTotal = ehh.A + ehh.B + ehh.C, expectedBytes = expectedBytes, preFill = o.preFill,
        postFillUnknownBytes = o.preFill and (ehh.A + ehh.B + ehh.C - o.preFill - expectedBytes) or nil,
        leftN = o.leftN, unknownWhileInScene = (o.preFill and o.hitsAtLeft) and (o.hitsAtLeft - o.preFill - o.expAtLeft) or nil,
        lastUpdN = o.lastUpdN,
        census = #corder, dmaTotal = dmaTotal, dmaFromArea = dmaFromArea, m7sel = #m7sel, m7selFirst = m7sel[1], rows = #rows, worst = worst,
        B6 = kit.r16(0xB6), B8 = kit.r16(0xB8), BC = kit.r16(0xBC) })
    end
  end)
end
