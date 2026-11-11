-- description: E4 HDMA / window / parallax / credits capture: PPU window and colour-math register census on every bank alias (HDMA writes included), HDMA channel bind census (SetupHdmaChannel_Direct / _Indirect: channel, carry), 30-frame samples with the first bytes of every active HDMA table, scene warp driver that saves the arrival census.
-- requires: mesen_kit, iog_kit, gaia_kit, e1_display
--
-- Note: e4.bindSweep also needs the e2_palette module (e2.sweep).
-- ROM O offsets (decimal PRG offsets, `; {n}` tags of extract:lt):
--   NmiHandler 33528; ResetHdmaState 254278; SetupHdmaChannel_Indirect 254295; SetupHdmaChannel_Direct 254323;
--   the shared tail: `ADC #$10` 254370 (no CLC before it), `STA $006A` 254372; ParallaxThinkerEntry 47245; ParallaxClearBandAccumulators 47299.
-- Callbacks run BEFORE the access; the PC a memory callback reports is the address AFTER the accessing instruction.
-- A write callback fires for HDMA transfers too (alias $00:21xx, the PC is whatever the CPU was executing): a register that gets more
-- than 2 writes in one frame is an HDMA register for that frame.
--
--   e4.install(o)          S = state table; callbacks: $36 write + NMI exec (controls), writes $2123-$2133 on 128 aliases (S.last, S.cnt, S.maxPF,
--                          census rows when o.census), exec on the HDMA bind routines (S.b: binds per reset interval, channel, carry, register)
--   e4.snap(S, tag)        one sample row (table) and e4.fmt(row) its one-line text
--   e4.sampler(S, o)       frame callback: o.every (30), o.total (300), o.tag; samples at (frame - f0) % every == 0, per-scanline record of the
--                          frame before; ends with kit.finish({rows = ...}) when o.finish ~= false
--   e4.warp(o)             warp driver from the loaded state: o.scene, o.flags, o.pre, o.post (frames after the banner), o.noBanner, o.tag
e4 = e4 or {}

local WR  = emu.memType.snesWorkRam
local SM  = emu.memType.snesMemory
local CPU = emu.cpuType.snes

e4.OFF = { nmi = 33528, resetHdma = 254278, setupInd = 254295, setupDir = 254323, adc = 254370, parEntry = 47245, parClear = 47299 }

local REGS = {
  [0x2123] = "W12SEL", [0x2124] = "W34SEL", [0x2125] = "WOBJSEL", [0x2126] = "WH0", [0x2127] = "WH1", [0x2128] = "WH2", [0x2129] = "WH3",
  [0x212A] = "WBGLOG", [0x212B] = "WOBJLOG", [0x212C] = "TM", [0x212D] = "TS", [0x212E] = "TMW", [0x212F] = "TSW", [0x2130] = "CGWSEL",
  [0x2131] = "CGADSUB", [0x2132] = "COLDATA", [0x2133] = "SETINI",
}
e4.REGS = REGS
-- registers whose per-scanline values are recorded during the frame before a sample
local LINEREGS = { [0x2126] = true, [0x2127] = true, [0x2130] = true, [0x2131] = true, [0x2132] = true, [0x212C] = true, [0x212D] = true }

-- a Lua error inside an event callback is not reported by the host (silent): log it
local function safe(name, f)
  return function(...)
    local ok, err = pcall(f, ...)
    if not ok then emu.log("E4 LUA ERROR in " .. name .. ": " .. tostring(err)) end
  end
end

local function hx(v, w) if v == nil then return "--" end return string.format("%0" .. (w or 2) .. "X", v) end
local function off24(k, pc) return ((k & 0x3F) << 16) | (pc & 0xFFFF) end
local function frameNow() return emu.getState()["frameCount"] end

function e4.writeChunks(name, lines)
  local buf, first, size = {}, true, 0
  local function flush()
    if #buf > 0 then emu.mcp.writeFile(name, table.concat(buf, "\n") .. "\n", not first); first = false; buf = {} end
  end
  for _, l in ipairs(lines) do
    buf[#buf + 1] = l; size = size + #l + 1
    if size > 2500 then flush(); size = 0 end
  end
  flush()
end

function e4.install(o)
  o = o or {}
  local S = { last = {}, cnt = {}, pf = {}, maxPF = {}, seen = {}, census = {}, ncensus = 0, w36 = 0, nmi = 0, rec = false, lines = {},
              census_on = o.census == true, f0 = frameNow(),
              b = { total = 0, direct = 0, indirect = 0, carry = { [0] = 0, [1] = 0 }, ch = {}, cur = 0, max = 0, rows = {}, seen = {}, chCarry = {},
                    resets = 0, tail6A = {}, maxRegs = nil } }
  -- positive controls
  emu.addMemoryCallback(function(a) if (a & 0xFFFF) == 0x36 then S.w36 = S.w36 + 1 end end, emu.callbackType.write, 0x36, 0x36, CPU, WR)
  emu.addMemoryCallback(function() S.nmi = S.nmi + 1 end, emu.callbackType.exec, e4.OFF.nmi, e4.OFF.nmi, CPU, emu.memType.snesPrgRom)

  local function onPpu(a, v)
    local reg = a & 0xFFFF
    S.last[reg] = v
    S.cnt[reg] = (S.cnt[reg] or 0) + 1
    S.pf[reg] = (S.pf[reg] or 0) + 1
    if S.rec and LINEREGS[reg] then
      local sc = emu.getState()["ppu.scanline"]
      local t = S.lines[reg]
      if not t then t = {}; S.lines[reg] = t end
      if #t < 1200 then t[#t + 1] = (sc << 8) | v end
    end
    if S.census_on then
      local key = (reg << 8) | v
      if not S.seen[key] and S.ncensus < (o.maxCensus or 300) then
        S.seen[key] = true
        local st = emu.getState()
        S.ncensus = S.ncensus + 1
        S.census[#S.census + 1] = string.format("f=%d n36=%d %s=%02X alias=%02X pc=%d (%02X:%04X)", st.frameCount - S.f0, emu.read16(0x36, WR, false), REGS[reg], v,
          (a >> 16) & 0xFF, off24(st["cpu.k"], st["cpu.pc"]), st["cpu.k"], st["cpu.pc"])
      end
    end
  end
  for bank = 0, 0xBF do
    if bank <= 0x3F or bank >= 0x80 then
      emu.addMemoryCallback(onPpu, emu.callbackType.write, (bank << 16) | 0x2123, (bank << 16) | 0x2133, CPU, SM)
    end
  end

  -- BG scroll registers $210D-$2114 (two writes per value: low then high): per-scanline words while recording
  S.scrPend, S.scr = {}, {}
  local function onScroll(a, v)
    local reg = a & 0xFFFF
    local pend = S.scrPend[reg]
    if pend == nil then S.scrPend[reg] = v
    else
      S.scrPend[reg] = nil
      if S.rec then
        local t = S.scr[reg]
        if not t then t = {}; S.scr[reg] = t end
        if #t < 600 then t[#t + 1] = (emu.getState()["ppu.scanline"] << 16) | (pend | (v << 8)) end
      end
    end
  end
  for bank = 0, 0xBF do
    if bank <= 0x3F or bank >= 0x80 then
      emu.addMemoryCallback(onScroll, emu.callbackType.write, (bank << 16) | 0x210D, (bank << 16) | 0x2114, CPU, SM)
    end
  end

  -- HDMA channel allocation: ResetHdmaState entry (interval boundary), the two entries (A = bank | register << 8, Y = table), the shared tail ADC
  local B = S.b
  emu.addMemoryCallback(function()
    B.resets = B.resets + 1
    if B.cur > B.max then B.max = B.cur end
    B.cur = 0
  end, emu.callbackType.exec, e4.OFF.resetHdma, e4.OFF.resetHdma, CPU, emu.memType.snesPrgRom)
  local pend
  local function onEntry(kind)
    return function()
      local st = emu.getState()
      pend = { kind = kind, reg = (st["cpu.a"] >> 8) & 0xFF, bank = st["cpu.a"] & 0xFF, tbl = st["cpu.y"], m = (st["cpu.ps"] & 0x20) ~= 0 }
      if kind == "D" then B.direct = B.direct + 1 else B.indirect = B.indirect + 1 end
    end
  end
  emu.addMemoryCallback(onEntry("I"), emu.callbackType.exec, e4.OFF.setupInd, e4.OFF.setupInd, CPU, emu.memType.snesPrgRom)
  emu.addMemoryCallback(onEntry("D"), emu.callbackType.exec, e4.OFF.setupDir, e4.OFF.setupDir, CPU, emu.memType.snesPrgRom)
  emu.addMemoryCallback(function()
    local st = emu.getState()
    local carry = st["cpu.ps"] & 1
    local r6A = emu.read(0x6A, WR, false)
    local r68 = emu.read(0x68, WR, false)
    local ch = r6A >> 4
    B.total = B.total + 1; B.cur = B.cur + 1
    B.carry[carry] = B.carry[carry] + 1
    B.ch[ch] = (B.ch[ch] or 0) + 1
    B.chCarry[ch] = B.chCarry[ch] or { [0] = 0, [1] = 0 }
    B.chCarry[ch][carry] = B.chCarry[ch][carry] + 1
    B.tail6A[r6A] = (B.tail6A[r6A] or 0) + 1
    if pend then
      local key = string.format("%s ch%d reg=21%02X bank=%02X tbl=%04X", pend.kind, ch, pend.reg, pend.bank, pend.tbl)
      if not B.seen[key] and #B.rows < 60 then B.seen[key] = true; B.rows[#B.rows + 1] = key .. string.format(" carry=%d $68after=%02X", carry, r68) end
    end
  end, emu.callbackType.exec, e4.OFF.adc, e4.OFF.adc, CPU, emu.memType.snesPrgRom)

  -- parallax band accumulators $0720-$0760 around the spawn-time clear: pre = at ParallaxClearBandAccumulators entry, post = right after its RTS
  S.par = {}
  local function accStr()
    local t = {}
    for a = 0x0720, 0x0760, 2 do t[#t + 1] = hx(emu.read16(a, WR, false), 4) end
    return table.concat(t, " ")
  end
  emu.addMemoryCallback(function()
    if #S.par < 12 then S.par[#S.par + 1] = string.format("PRE  f=%d n36=%d scene=%02X thinkerSlot=%04X acc: %s", frameNow() - S.f0, emu.read16(0x36, WR, false),
      emu.read16(0x644, WR, false), emu.getState()["cpu.x"], accStr()) end
  end, emu.callbackType.exec, e4.OFF.parClear, e4.OFF.parClear, CPU, emu.memType.snesPrgRom)
  emu.addMemoryCallback(function()
    if #S.par < 12 then S.par[#S.par + 1] = string.format("POST f=%d acc: %s", frameNow() - S.f0, accStr()) end
  end, emu.callbackType.exec, 47248, 47248, CPU, emu.memType.snesPrgRom)

  kit.onFrame(safe('install.frame', function()
    for reg, n in pairs(S.pf) do if n > (S.maxPF[reg] or 0) then S.maxPF[reg] = n end end
    S.pf = {}
  end))
  return S
end

function e4.resetBinds(S)
  local B = S.b
  B.total, B.direct, B.indirect, B.cur, B.max, B.resets = 0, 0, 0, 0, 0, 0
  B.carry = { [0] = 0, [1] = 0 }; B.ch = {}; B.chCarry = {}; B.rows = {}; B.seen = {}; B.tail6A = {}
end

local function runs(list, maxRuns)
  -- list of (scanline << 8 | value): run-length of consecutive scanlines with the same value
  local out, cur = {}, nil
  for _, e in ipairs(list or {}) do
    local sc, v = e >> 8, e & 0xFF
    if cur and cur.v == v and sc == cur.b + 1 then cur.b = sc
    elseif cur and cur.v == v and sc == cur.b then -- same scanline written twice
    else
      cur = { a = sc, b = sc, v = v }
      out[#out + 1] = cur
    end
  end
  local s = {}
  for i, r in ipairs(out) do
    if i > (maxRuns or 14) then s[#s + 1] = string.format("...(+%d runs)", #out - i + 1); break end
    s[#s + 1] = string.format("%d-%d=%02X", r.a, r.b, r.v)
  end
  return table.concat(s, " "), #out
end

-- register values rebuilt from the PPU state (what the PPU holds now, independent of whether the write happened after the callbacks were installed)
local function winSel(st, l1, l2)
  local v = 0
  for i, l in ipairs({ l1, l2 }) do
    for w = 0, 1 do
      local inv = st["ppu.window[" .. w .. "].invertedLayers[" .. l .. "]"] and 1 or 0
      local en = st["ppu.window[" .. w .. "].activeLayers[" .. l .. "]"] and 1 or 0
      local sh = (i - 1) * 4 + w * 2
      v = v | (inv << sh) | (en << (sh + 1))
    end
  end
  return v
end
local function maskByte(st, name)
  local v = 0
  for j = 0, 4 do if st["ppu." .. name .. "[" .. j .. "]"] then v = v | (1 << j) end end
  return v
end

function e4.snap(S, tag, o)
  o = o or {}
  local st = emu.getState()
  local p = e1.snap()
  local row = {
    tag = tag, frame = st.frameCount, n36 = emu.read16(0x36, WR, false), scene = emu.read16(0x0644, WR, false),
    W12SEL = S.last[0x2123], W34SEL = S.last[0x2124], WOBJSEL = S.last[0x2125], TMWw = S.last[0x212E], TSWw = S.last[0x212F], CGWSEL = S.last[0x2130],
    CGADSUB = S.last[0x2131], TMw = S.last[0x212C], TSw = S.last[0x212D], COLDATA = S.last[0x2132], WH0 = S.last[0x2126], WH1 = S.last[0x2127],
    WBGLOG = S.last[0x212A], WOBJLOG = S.last[0x212B],
    TM = p.TM, TS = p.TS, tmw = p.tmw, tsw = p.tsw, win1 = p.win[1], win2 = p.win[2], cmMask = p.cmMask, cmSub = p.cmSub, cmHalve = p.cmHalve, cmUseSub = p.cmAddSub,
    fixed = p.fixedRGB, bgMode = p.bgMode, bright = p.brightness, blank = p.forcedBlank,
    hdma66 = emu.read(0x66, WR, false), mask = st["dmaController.hdmaChannels"], w36 = S.w36, nmi = S.nmi,
    next68 = emu.read(0x68, WR, false), next6A = emu.read(0x6A, WR, false),
    chans = {}, lines = {},
    dW12 = winSel(st, 0, 1), dW34 = winSel(st, 2, 3), dWOBJ = winSel(st, 4, 5), dTMW = maskByte(st, "windowMaskMain"), dTSW = maskByte(st, "windowMaskSub"),
    dCGADSUB = (st["ppu.colorMathEnabled"] or 0) | ((st["ppu.colorMathSubtractMode"] and 1 or 0) << 7) | ((st["ppu.colorMathHalveResult"] and 1 or 0) << 6),
    dCGWSEL1 = st["ppu.colorMathAddSubscreen"] and 1 or 0,
    dWH = string.format("%d,%d,%d,%d", st["ppu.window[0].left"] or -1, st["ppu.window[0].right"] or -1, st["ppu.window[1].left"] or -1, st["ppu.window[1].right"] or -1),
  }
  for c = 0, 7 do
    if (row.mask >> c) & 1 == 1 then
      local pfx = "dmaController.channel[" .. c .. "]."
      local sb, sa, dest = st[pfx .. "srcBank"] or 0, st[pfx .. "srcAddress"] or 0, st[pfx .. "destAddress"] or 0
      local ind = st[pfx .. "hdmaIndirectAddressing"] == true
      local bytes = {}
      for i = 0, 15 do bytes[#bytes + 1] = hx(emu.read((sb << 16) | ((sa + i) & 0xFFFF), SM, false)) end
      local s = string.format("ch%d dest=21%02X mode=%d %s src=%02X:%04X tbl16=%s", c, dest, st[pfx .. "transferMode"] or -1, ind and "IND" or "DIR", sb, sa, table.concat(bytes, " "))
      if ind then
        local ib = st[pfx .. "hdmaBank"] or 0
        local cnt, pl, ph = emu.read((sb << 16) | sa, SM, false), emu.read((sb << 16) | ((sa + 1) & 0xFFFF), SM, false), emu.read((sb << 16) | ((sa + 2) & 0xFFFF), SM, false)
        local ptr = pl | (ph << 8)
        local d = {}
        for i = 0, 5 do d[#d + 1] = hx(emu.read((ib << 16) | ((ptr + i) & 0xFFFF), SM, false)) end
        s = s .. string.format(" | data@%02X:%04X(first entry cnt=%02X): %s", ib, ptr, cnt, table.concat(d, " "))
      end
      row.chans[#row.chans + 1] = s
    end
  end
  for reg, name in pairs({ [0x2126] = "WH0", [0x2127] = "WH1", [0x2130] = "CGWSEL", [0x2131] = "CGADSUB", [0x2132] = "COLDATA", [0x212C] = "TM", [0x212D] = "TS" }) do
    if S.lines[reg] and #S.lines[reg] > 0 then
      local r, n = runs(S.lines[reg], o.maxRuns or 14)
      row.lines[#row.lines + 1] = string.format("%s[%d writes, %d runs, scan-range=value]: %s", name, #S.lines[reg], n, r)
    end
  end
  table.sort(row.lines)
  row.scrRaw = {}
  for reg, list in pairs(S.scr) do
    if #list > 0 then
      local mn, mx, w = 0x10000, -1, {}
      for _, e in ipairs(list) do local v = e & 0xFFFF; if v < mn then mn = v end; if v > mx then mx = v end end
      for i = 1, math.min(12, #list) do w[#w + 1] = string.format("%d:%04X", list[i] >> 16, list[i] & 0xFFFF) end
      row.lines[#row.lines + 1] = string.format("scroll $%04X [%d words/frame, min %04X max %04X] first: %s", reg, #list, mn, mx, table.concat(w, " "))
      local full = {}
      for _, e in ipairs(list) do full[#full + 1] = string.format("%d:%04X", e >> 16, e & 0xFFFF) end
      row.scrRaw[#row.scrRaw + 1] = string.format("%s $%04X %d: %s", tag, reg, #list, table.concat(full, " "))
    end
  end
  table.sort(row.lines); table.sort(row.scrRaw)
  if o.cam then
    row.cam = string.format("cameraTargetX($06BE)=%04X +2($06C0)=%04X cameraTargetY($06C2)=%04X +2($06C4)=%04X bg1H($068A)=%04X mapV($068E)=%04X", emu.read16(0x6BE, WR, false), emu.read16(0x6C0, WR, false),
      emu.read16(0x6C2, WR, false), emu.read16(0x6C4, WR, false), emu.read16(0x68A, WR, false), emu.read16(0x68E, WR, false))
  end
  if o.acc then
    local t = {}
    for a = 0x0720, 0x0760, 2 do t[#t + 1] = hx(emu.read16(a, WR, false), 4) end
    row.acc = table.concat(t, " ")
  end
  if o.circ then
    row.circ = string.format("cx=%04X cy=%04X r=%04X prev: %04X %04X %04X", emu.read16(0xF6, WR, false), emu.read16(0xFA, WR, false), emu.read16(0xFE, WR, false),
      emu.read16(0xF4, WR, false), emu.read16(0xF8, WR, false), emu.read16(0xFC, WR, false))
  end
  return row
end

function e4.fmt(r)
  local t = {}
  t[#t + 1] = string.format("%s f=%d n36=%d sc=%02X | PPU now: W12SEL=%02X W34SEL=%02X WOBJSEL=%02X TMW=%02X TSW=%02X CGADSUB=%02X CGWSEL.b1(sub screen)=%d WH0-3=%s TM=%02X TS=%02X fixed=%s | last write seen: W12SEL=%s W34SEL=%s WOBJSEL=%s TMW=%s TSW=%s CGWSEL=%s CGADSUB=%s COLDATA=%s TM=%s TS=%s WH0=%s WH1=%s | $66=%02X mask=%02X next68=%02X next6A=%02X | bgmode=%s | w36=%d nmi=%d",
    r.tag, r.frame, r.n36, r.scene, r.dW12, r.dW34, r.dWOBJ, r.dTMW, r.dTSW, r.dCGADSUB, r.dCGWSEL1, r.dWH, r.TM, r.TS, r.fixed,
    hx(r.W12SEL), hx(r.W34SEL), hx(r.WOBJSEL), hx(r.TMWw), hx(r.TSWw), hx(r.CGWSEL), hx(r.CGADSUB), hx(r.COLDATA), hx(r.TMw), hx(r.TSw), hx(r.WH0), hx(r.WH1),
    r.hdma66, r.mask, r.next68, r.next6A, tostring(r.bgMode), r.w36, r.nmi)
  for _, c in ipairs(r.chans) do t[#t + 1] = "   " .. c end
  for _, l in ipairs(r.lines) do t[#t + 1] = "   " .. l end
  if r.cam then t[#t + 1] = "   " .. r.cam end
  if r.acc then t[#t + 1] = "   acc $0720-$0760: " .. r.acc end
  if r.circ then t[#t + 1] = "   circle: " .. r.circ end
  return table.concat(t, "\n")
end

-- sampler -------------------------------------------------------------------------------------------------------------------
function e4.sampler(S, o)
  o = o or {}
  local every, total = o.every or 30, o.total or 300
  local f0 = frameNow()
  local rows, lines, scrLines = {}, {}, {}
  local done = false
  local function take(k)
    local r = e4.snap(S, string.format("t+%03d", k), o)
    rows[#rows + 1] = r
    lines[#lines + 1] = e4.fmt(r)
    for _, l in ipairs(r.scrRaw or {}) do scrLines[#scrLines + 1] = l end
    S.lines = {}; S.scr = {}; S.scrPend = {}; S.rec = false
    if o.onSample then o.onSample(k, r, S) end
  end
  take(0)
  local k = 0
  kit.onFrame(safe('sampler', function()
    if done then return end
    k = k + 1      -- own end-of-frame count: frameCount read inside the callback is not incremented yet
    if o.at and o.at[k] then o.at[k](k, S) end
    if k > 0 and k % every == 0 then
      take(k)
      if k >= total then
        done = true
        S.rec = false
        e4.writeChunks("E4_" .. (o.tag or "run") .. "_rows.txt", lines)
        if #scrLines > 0 then e4.writeChunks("E4_" .. (o.tag or "run") .. "_scroll.txt", scrLines) end
        if o.finish ~= false then
          local b = S.b
          local chs = {}
          for ch = 0, 8 do if b.ch[ch] then chs[#chs + 1] = string.format("ch%d x%d (carry0 %d carry1 %d)", ch, b.ch[ch], b.chCarry[ch][0], b.chCarry[ch][1]) end end
          kit.finish({ tag = o.tag, par = S.par, frames = k, rows = #rows, w36 = S.w36, nmi = S.nmi, lines = lines, binds = { total = b.total, direct = b.direct, indirect = b.indirect,
            carry0 = b.carry[0], carry1 = b.carry[1], maxPerInterval = b.max, resets = b.resets, channels = chs, rows = b.rows }, maxPF = (function()
              local t = {}
              for reg, n in pairs(S.maxPF) do t[#t + 1] = string.format("%s:%d", REGS[reg], n) end
              table.sort(t)
              return table.concat(t, " ")
            end)() })
        end
      end
    end
    if (k + 1) % every == 0 then
      S.rec = true       -- the next frame is a sample frame: record the per-scanline writes of the frame that ends at the sample
      S.lines = {}; S.scr = {}; S.scrPend = {}
    end
  end))
  return rows, lines
end

-- warp driver ---------------------------------------------------------------------------------------------------------------
function e4.warp(o)
  local S = e4.install{ census = true, maxCensus = o.maxCensus or 300 }
  local nf, stage, t0 = 0, "wait", 0
  local arrive, bannerSeen, n36arr, n36set
  local rows = {}
  kit.onFrame(safe('warp', function()
    nf = nf + 1
    if stage == "wait" then
      if nf >= (o.delay or 3) and emu.read16(0x642, WR, false) == 0 then
        for _, id in ipairs(o.flags or {}) do iog.setEventFlag(id) end
        if o.pre then o.pre(S) end
        emu.write16(0x642, o.scene, WR)
        S.warpFrame = frameNow() - S.f0
        stage = "warp"; t0 = nf
      end
    elseif stage == "warp" then
      if emu.read16(0x644, WR, false) == o.scene and emu.read16(0x642, WR, false) == 0 then
        stage = "banner"; t0 = nf; arrive = nf; S.arriveFrame = frameNow() - S.f0; n36arr = emu.read16(0x36, WR, false)
      elseif nf - t0 > 900 then
        gaia.release()
        kit.finish({ error = "warp_timeout", scene = emu.read16(0x644, WR, false), next = emu.read16(0x642, WR, false), census = S.census })
      end
    elseif stage == "banner" then
      -- $644 is set when the loader starts, the loader runs many frames without NMI: count NMIs ($36) from the arrival
      local dn = (emu.read16(0x36, WR, false) - n36arr) & 0xFFFF
      local b = emu.read(0xB4, WR, false)
      if b ~= 0 and not o.noBanner then
        bannerSeen = true
        gaia.hold((nf % 6 < 3) and { "a" } or {})
      else
        gaia.release()
        if (bannerSeen and dn >= 3) or dn >= (o.waitBanner or 60) then stage = "settle"; t0 = nf; n36set = emu.read16(0x36, WR, false) end
      end
      if nf - t0 > 3000 and stage == "banner" then gaia.release(); kit.finish({ error = "banner_timeout", census = S.census }) end
    elseif stage == "settle" then
      if o.tick then o.tick(nf - t0, S) end
      if ((emu.read16(0x36, WR, false) - n36set) & 0xFFFF) >= (o.post or 20) or nf - t0 > 3000 then
        local snap = e4.snap(S, "arrive", { acc = o.acc, circ = o.circ })
        local b = S.b
        local chs = {}
        for ch = 0, 8 do if b.ch[ch] then chs[#chs + 1] = string.format("ch%d x%d (carry0 %d carry1 %d)", ch, b.ch[ch], b.chCarry[ch][0], b.chCarry[ch][1]) end end
        e4.writeChunks("E4_" .. (o.tag or "warp") .. "_census.txt", S.census)
        kit.finish({ tag = o.tag, par = S.par, scene = emu.read16(0x644, WR, false), warpFrame = S.warpFrame, arriveFrame = S.arriveFrame, framesToFinish = nf, n36 = emu.read16(0x36, WR, false), banner = bannerSeen == true,
          mask65A = emu.read16(0x65A, WR, false), w36 = S.w36, nmi = S.nmi, census = S.census, ncensus = S.ncensus, snap = e4.fmt(snap),
          binds = { total = b.total, direct = b.direct, indirect = b.indirect, carry0 = b.carry[0], carry1 = b.carry[1], max = b.max, channels = chs, rows = b.rows } })
      end
    end
  end))
  return S
end

-- chain: warp through several scenes in one run (o.scenes = { {scene, frames}, ... }), logging the parallax accumulators at every spawn ---------------
function e4.chain(o)
  local S = e4.install{ census = false }
  local nf, idx, stage, t0 = 0, 1, "wait", 0
  local bannerSeen, n36arr, n36set
  local log = {}
  kit.onFrame(safe('chain', function()
    nf = nf + 1
    local cur = o.scenes[idx]
    if stage == "wait" then
      if nf >= 3 and emu.read16(0x642, WR, false) == 0 then
        emu.write16(0x642, cur[1], WR); stage = "warp"; t0 = nf; bannerSeen = false
        log[#log + 1] = string.format("warp -> %02X at f=%d", cur[1], frameNow() - S.f0)
      end
    elseif stage == "warp" then
      if emu.read16(0x644, WR, false) == cur[1] and emu.read16(0x642, WR, false) == 0 then stage = "banner"; t0 = nf; n36arr = emu.read16(0x36, WR, false)
      elseif nf - t0 > 900 then gaia.release(); kit.finish({ error = "warp_timeout", at = idx, log = log, par = S.par, scene = emu.read16(0x644, WR, false), next = emu.read16(0x642, WR, false), n36 = emu.read16(0x36, WR, false), b4 = emu.read(0xB4, WR, false) }) end
    elseif stage == "banner" then
      local dn = (emu.read16(0x36, WR, false) - n36arr) & 0xFFFF
      local b = emu.read(0xB4, WR, false)
      if b ~= 0 then bannerSeen = true; gaia.hold((nf % 6 < 3) and { "a" } or {})
      else gaia.release(); if (bannerSeen and dn >= 3) or dn >= 60 then stage = "settle"; t0 = nf; n36set = emu.read16(0x36, WR, false) end end
      if nf - t0 > 3000 and stage == "banner" then gaia.release(); kit.finish({ error = "banner_timeout", at = idx, log = log }) end
    elseif stage == "settle" then
      if ((emu.read16(0x36, WR, false) - n36set) & 0xFFFF) >= cur[2] or nf - t0 > 3000 then
        log[#log + 1] = e4.fmt(e4.snap(S, string.format("end-%02X", cur[1]), { acc = true }))
        idx = idx + 1; stage = "wait"
        if idx > #o.scenes then kit.finish({ tag = o.tag, par = S.par, log = log, w36 = S.w36, nmi = S.nmi }) end
      end
    end
  end))
  return S
end

-- bind sweep over scenes via e2.sweep: per scene, binds counted only while the scene is watched ----------------------------------------------------
function e4.bindSweep(o)
  local E = e4.install{ census = false }
  local S = { nev = 0 }
  local out, cur = {}, nil
  local function flush()
    if cur ~= nil then
      local b = E.b
      if b.cur > b.max then b.max = b.cur end
      local chs = {}
      for ch = 0, 8 do if b.ch[ch] then chs[#chs + 1] = string.format("ch%d:%d(c0=%d,c1=%d)", ch, b.ch[ch], b.chCarry[ch][0], b.chCarry[ch][1]) end end
      local t6 = {}
      for v, n in pairs(b.tail6A) do t6[#t6 + 1] = string.format("%02X:%d", v, n) end
      table.sort(t6)
      out[#out + 1] = string.format("%02X total=%d D=%d I=%d maxPerFrame=%d carry0=%d carry1=%d | %s | $6A@ADC %s | %s", cur, b.total, b.direct, b.indirect, b.max, b.carry[0], b.carry[1],
        table.concat(chs, " "), table.concat(t6, " "), table.concat(b.rows, "; "):sub(1, 400))
    end
  end
  S.reset = function() flush(); cur = nil end   -- called by e2.sweep before each scene load, i.e. right after the previous scene's watch ended
  e2.sweep({ scenes = o.scenes, post = o.post or 90, noBanner = o.noBanner, flagsFor = o.flagsFor,
    tick = function(scene, t, nf)
      if scene ~= cur then cur = scene; e4.resetBinds(E) end
    end,
    done = function(S2, per)
      flush(); cur = nil
      e4.writeChunks("E4_" .. (o.tag or "bindsweep") .. ".txt", out)
      local to = {}
      for _, r in ipairs(per) do if r.timeout then to[#to + 1] = string.format("%02X", r.scene) end end
      kit.finish({ tag = o.tag, scenes = #per, timeouts = table.concat(to, " "), w36 = E.w36, nmi = E.nmi, rows = #out })
    end }, S)
  return S, E
end
