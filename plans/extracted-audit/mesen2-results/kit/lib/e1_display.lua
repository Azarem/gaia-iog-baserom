-- description: E1 display state capture: PPU register writes ($2100-$2133) on every bank alias with the last writer per register, a run-length per-frame log of $2130/$2131/$2132, decoded PPU snapshots, scene warp driver.
-- requires: mesen_kit, iog_kit, gaia_kit
--
-- run_script {includes={"gaia_kit","e1_display"}, code='e1.run{scene=0x23, post=120, snapAt={0,60,120}, out="E1_x.txt"}'}
--
-- Callbacks run BEFORE the access; the PC a memory callback reports is the address AFTER the accessing instruction.
-- Offsets are decimal PRG (ROM file) offsets of the O ROM: off = ((bank & 0x3F) << 16) | pc16.
--
--   warp     : o.scene (id), o.flags = {event flag ids set before the scene is staged}, o.pokes = {{addr=wramOffset, v=byte|word, w=16}},
--              o.delay = frames before staging (default 5), quick warp (sceneNext only: default spawn). The banner ($00B4 <> 0) is
--              dismissed with A pulses unless o.noBanner. Without o.scene the run starts from the loaded scene (t counts from the start).
--   arrival  : the first frame with $0644 == scene and $0642 == 0 (S.arriveFrame). t = NMI frames ($36 deltas) since the first NMI that
--              ran after that frame (S.t0Frame); snapAt = list of t values at which a snapshot is taken; the run ends at o.post (default 120)
--              or at o.frames (emulator frames after the start of the script) when o.post is nil.
--   writes   : every write to $2100-$2101, $2105-$210C and $2123-$2133 at the 128 aliases ($00-$3F, $80-$BF): last value, count, PC and frame per register (S.last),
--              change events (S.chg) for the registers in WATCH, effective COLDATA colour (S.rgb). Per-frame run-length rows (S.runs) for
--              $2130 / $2131 / $2132: "f1-f2 xN reg=value@pc ..." means every frame from f1 to f2 had that exact write sequence.
--   snapshot : decoded ppu.* fields of emu.getState() (TM TS colour math fixed colour BG mode scrolls windows) plus $66, $7F0C00-02, $09EC,
--              $0644, $065A, $00B4 (e1.snap()).
--   leaving  : the run ends at the first frame after arrival whose $0644 differs from o.scene (S.leftAt, a "LEFT_t" snapshot) unless o.allowLeave.
--   output   : o.out = file under <results>/raw (events, runs, last-write table); the result carries the first o.show events (default 40).
e1 = e1 or {}

local WR  = emu.memType.snesWorkRam
local SM  = emu.memType.snesMemory
local CPU = emu.cpuType.snes

local function off24(k, pc) return ((k & 0x3F) << 16) | (pc & 0xFFFF) end
local function hex(v, w) return string.format("%0" .. (w or 2) .. "X", v) end

local WATCH = {
  [0x2100] = "INIDISP", [0x2101] = "OBSEL", [0x2105] = "BGMODE", [0x2106] = "MOSAIC", [0x2107] = "BG1SC", [0x2108] = "BG2SC",
  [0x2109] = "BG3SC", [0x210A] = "BG4SC", [0x210B] = "BG12NBA", [0x210C] = "BG34NBA", [0x2123] = "W12SEL", [0x2124] = "W34SEL",
  [0x2125] = "WOBJSEL", [0x2126] = "WH0", [0x2127] = "WH1", [0x2128] = "WH2", [0x2129] = "WH3", [0x212A] = "WBGLOG",
  [0x212B] = "WOBJLOG", [0x212C] = "TM", [0x212D] = "TS", [0x212E] = "TMW", [0x212F] = "TSW", [0x2130] = "CGWSEL", [0x2131] = "CGADSUB",
  [0x2132] = "COLDATA", [0x2133] = "SETINI",
}
local RUNREGS = { [0x2130] = true, [0x2131] = true, [0x2132] = true }

function e1.snap()
  local st = emu.getState()
  local function g(k) return st["ppu." .. k] end
  local win = {}
  for i = 0, 1 do
    win[#win + 1] = string.format("w%d L%d R%d act=%s inv=%s", i + 1, g("window[" .. i .. "].left") or -1, g("window[" .. i .. "].right") or -1,
      (function() local t = {} for j = 0, 5 do t[#t + 1] = g("window[" .. i .. "].activeLayers[" .. j .. "]") and "1" or "0" end return table.concat(t) end)(),
      (function() local t = {} for j = 0, 5 do t[#t + 1] = g("window[" .. i .. "].invertedLayers[" .. j .. "]") and "1" or "0" end return table.concat(t) end)())
  end
  local mm, ms = {}, {}
  for j = 0, 4 do mm[#mm + 1] = g("windowMaskMain[" .. j .. "]") and "1" or "0"; ms[#ms + 1] = g("windowMaskSub[" .. j .. "]") and "1" or "0" end
  local fc = g("fixedColor") or 0
  local cg = {}
  for i = 0, 15 do cg[#cg + 1] = string.format("%04X", emu.read16(i * 2, emu.memType.snesCgRam, false)) end
  local cg21, cgE2, sum = {}, {}, 0
  for i = 0x21, 0x2C do cg21[#cg21 + 1] = string.format("%04X", emu.read16(i * 2, emu.memType.snesCgRam, false)) end
  for i = 0xE2, 0xE4 do cgE2[#cgE2 + 1] = string.format("%04X", emu.read16(i * 2, emu.memType.snesCgRam, false)) end
  for i = 0, 255 do sum = (sum * 31 + emu.read16(i * 2, emu.memType.snesCgRam, false)) & 0xFFFFFF end
  return {
    cg0_15 = table.concat(cg, " "), cg21 = table.concat(cg21, " "), cgE2 = table.concat(cgE2, " "), cgsum = sum,
    frame = st["frameCount"], n36 = kit.r16(0x36), scene = kit.r16(0x0644), sceneNext = kit.r16(0x0642),
    bgMode = g("bgMode"), bg3prio = g("mode1Bg3Priority"), brightness = g("screenBrightness"), forcedBlank = g("forcedBlank"),
    TM = g("mainScreenLayers"), TS = g("subScreenLayers"),
    cmMask = g("colorMathEnabled"), cmSub = g("colorMathSubtractMode"), cmHalve = g("colorMathHalveResult"), cmAddSub = g("colorMathAddSubscreen"),
    fixed555 = fc, fixedRGB = string.format("%d,%d,%d", fc & 31, (fc >> 5) & 31, (fc >> 10) & 31),
    layers = (function() local t = {} for j = 0, 3 do t[#t + 1] = string.format("bg%d map=%04X chr=%04X h=%d v=%d", j + 1,
      g("layers[" .. j .. "].tilemapAddress") or 0, g("layers[" .. j .. "].chrAddress") or 0, g("layers[" .. j .. "].hscroll") or 0, g("layers[" .. j .. "].vscroll") or 0) end return t end)(),
    oamBase = g("oamBaseAddress"), oamOffs = g("oamAddressOffset"), oamMode = g("oamMode"),
    win = win, tmw = table.concat(mm), tsw = table.concat(ms),
    hdmaMask66 = kit.r8(0x66), backdrop = string.format("%02X %02X %02X", kit.r8(0x10000 + 0x0C00), kit.r8(0x10000 + 0x0C01), kit.r8(0x10000 + 0x0C02)),
    dmf = kit.r16(0x09EC), mask65A = kit.r16(0x065A), banner = kit.r8(0x00B4), pflags = kit.r16(0x09AE),
  }
end

function e1.fmt(s)
  return string.format("%s f=%d n36=%d sc=%02X TM=%02X TS=%02X CM(mask=%02X sub=%s half=%s useSub=%s) fixed=%s(%04X) bgmode=%d bright=%d blank=%s " ..
    "$66=%02X $7F0C00=%s dmf=%04X mask65A=%04X $B4=%02X pflags=%04X TMW=%s TSW=%s | %s | %s | %s | %s | win: %s ; %s | obj base=%04X off=%04X mode=%d | cg0-15: %s | cg21-2C: %s | cgE2-E4: %s | cgsum=%06X",
    s.tag, s.frame, s.n36, s.scene, s.TM, s.TS, s.cmMask, tostring(s.cmSub), tostring(s.cmHalve), tostring(s.cmAddSub), s.fixedRGB, s.fixed555,
    s.bgMode, s.brightness, tostring(s.forcedBlank), s.hdmaMask66, s.backdrop, s.dmf, s.mask65A, s.banner, s.pflags, s.tmw, s.tsw,
    s.layers[1], s.layers[2], s.layers[3], s.layers[4], s.win[1], s.win[2], s.oamBase, s.oamOffs, s.oamMode, s.cg0_15, s.cg21, s.cgE2, s.cgsum)
end

function e1.run(o)
  local S = { w36 = 0, nev = 0, chg = {}, last = {}, nwrites = 0, rgb = { 0, 0, 0 }, runs = {}, snaps = {}, counts = {},
              arrived = false, t = 0, t0Frame = nil, arriveFrame = nil, firstNmiFrame = nil, startFrame = emu.getState()["frameCount"], log = {} }
  local post = o.post
  S.snapsRaw = S.snaps
  local snapAt = {}
  for _, v in ipairs(o.snapAt or {}) do snapAt[v] = true end
  local curFrame = {}      -- ordered "REG=VV@pc" strings of the current frame, regs 2130-2132
  local runSig, runFirst, runLast, runN = nil, nil, nil, 0
  local lastFrameSeen = nil

  local function frame() return emu.getState()["frameCount"] end
  local function tstr() if S.arrived and S.t0Frame then return "t=" .. S.t else return "t=-" end end

  local function chg(s) S.nev = S.nev + 1; if #S.chg < (o.maxEv or 400) then S.chg[#S.chg + 1] = s end end

  emu.addMemoryCallback(function(a) if (a & 0xFFFF) == 0x36 then S.w36 = S.w36 + 1 end end, emu.callbackType.write, 0x36, 0x36, CPU, WR)
  if o.nmi then emu.addMemoryCallback(function() S.nmi = (S.nmi or 0) + 1 end, emu.callbackType.exec, o.nmi, o.nmi, CPU, emu.memType.snesPrgRom) end

  -- backdropColors ($7F:0C00-02): nonzero writes are logged (they are what UploadCgramPalette copies to COLDATA), zero writes are counted
  S.bdZero, S.bdNonzero = 0, 0
  emu.addMemoryCallback(function(a, v)
    local w = a & 0x1FFFF
    if v == 0 then S.bdZero = S.bdZero + 1; return end
    S.bdNonzero = S.bdNonzero + 1
    local st = emu.getState()
    chg(string.format("f=%d %s BACKDROP[7F:0C%02X]=%02X pc=%d", st["frameCount"], tstr(), w & 0xFF, v, off24(st["cpu.k"], st["cpu.pc"])))
  end, emu.callbackType.write, 0x10C00, 0x10C02, CPU, WR)

  local function onPpu(a, v)
    local reg = a & 0xFFFF
    local st = emu.getState()
    local po = off24(st["cpu.k"], st["cpu.pc"])
    local f = st["frameCount"]
    S.nwrites = S.nwrites + 1
    local e = S.last[reg]
    if not e then e = { n = 0, pcs = {} }; S.last[reg] = e end
    local old = e.v
    e.n = e.n + 1; e.v = v; e.pc = po; e.f = f; e.t = S.arrived and S.t or -1
    if e.n <= 1 then e.firstF = f end
    e.pcs[po] = (e.pcs[po] or 0) + 1
    if RUNREGS[reg] then curFrame[#curFrame + 1] = string.format("%s=%02X@%d", WATCH[reg], v, po) end
    if reg == 0x2132 then
      if v & 0x20 ~= 0 then S.rgb[1] = v & 31 end
      if v & 0x40 ~= 0 then S.rgb[2] = v & 31 end
      if v & 0x80 ~= 0 then S.rgb[3] = v & 31 end
      local key = string.format("%d,%d,%d", S.rgb[1], S.rgb[2], S.rgb[3])
      if key ~= S.lastRgbKey then
        S.lastRgbKey = key
        chg(string.format("f=%d %s COLDATA rgb=%s (write %02X pc=%d)", f, tstr(), key, v, po))
      end
    elseif WATCH[reg] and old ~= v then
      chg(string.format("f=%d %s %s %s->%02X pc=%d", f, tstr(), WATCH[reg], old and hex(old) or "--", v, po))
    end
  end
  for bank = 0, 0xFF do
    if bank <= 0x3F or (bank >= 0x80 and bank <= 0xBF) then
      -- state registers only: the OAM / VRAM / CGRAM data ports ($2102-$2104, $2115-$2119, $2121-$2122) and the scroll registers
      -- ($210D-$2114) are not hooked (they carry 195,000 writes per 330 frames and slow the run to 7 frames per second)
      emu.addMemoryCallback(onPpu, emu.callbackType.write, (bank << 16) | 0x2100, (bank << 16) | 0x2101, CPU, SM)
      emu.addMemoryCallback(onPpu, emu.callbackType.write, (bank << 16) | 0x2105, (bank << 16) | 0x210C, CPU, SM)
      emu.addMemoryCallback(onPpu, emu.callbackType.write, (bank << 16) | 0x2123, (bank << 16) | 0x2133, CPU, SM)
    end
  end

  local function flushRun()
    if runSig then
      local rows = S.runs
      rows[#rows + 1] = string.format("f%d-%d x%d %s", runFirst, runLast, runLast - runFirst + 1, runSig == "" and "(no write)" or runSig)
    end
  end

  -- warp driver state
  local n = 0
  local stage = o.scene and "wait" or "run"
  local delay = o.delay or 5
  local bannerPulse = 0
  local nmiLast = nil

  kit.onFrame(function()
    n = n + 1
    local f = frame()
    -- per-frame run-length log of the colour math registers
    local sig = table.concat(curFrame, " ")
    curFrame = {}
    if S.arrived or o.logFromStart then
      if sig == runSig then runLast = f else flushRun(); runSig, runFirst, runLast = sig, f, f end
    end
    local sc, sn = kit.r16(0x0644), kit.r16(0x0642)
    if S.lastScene ~= sc then
      chg(string.format("f=%d SCENE %s->%02X next=%02X n36=%d", f, S.lastScene and hex(S.lastScene) or "--", sc, sn, kit.r16(0x36)))
      S.lastScene = sc
      if o.scene and sc == o.scene then S.sceneSetFrame = f end
    end
    if stage == "wait" then
      if n >= delay and sn == 0 then
        for _, id in ipairs(o.flags or {}) do iog.setEventFlag(id) end
        for _, p in ipairs(o.pokes or {}) do if p.w == 16 then kit.w16(p.addr, p.v) else kit.w8(p.addr, p.v) end end
        kit.w16(0x0642, o.scene)
        chg(string.format("f=%d STAGE scene %02X (quick warp), flags=%d pokes=%d", f, o.scene, #(o.flags or {}), #(o.pokes or {})))
        stage = "warping"
      end
    elseif stage == "warping" then
      if sc == o.scene and sn == 0 then
        S.arrived = true; S.arriveFrame = f; stage = "run"; S.n36Arrive = kit.r16(0x36)
        chg(string.format("f=%d ARRIVE scene %02X n36=%d", f, sc, S.n36Arrive))
        if post then flushRun(); runSig = nil end
      elseif n - delay > (o.warpTimeout or 1500) then
        S.timeout = true
        kit.finish({ error = "warp_timeout", scene = sc, next = sn, chg = S.chg })
        return
      end
    end
    if not o.scene and not S.arrived then S.arrived = true; S.arriveFrame = f; S.n36Arrive = kit.r16(0x36) end
    -- t: NMI frames since arrival
    if S.arrived then
      local n36 = kit.r16(0x36)
      local t = (n36 - S.n36Arrive) & 0xFFFF
      if t ~= S.t then
        if t > 0 and not S.t0Frame then S.t0Frame = f; S.firstNmiFrame = f end
        S.t = t
      end
      if kit.r8(0x00B4) ~= 0 and not o.noBanner then gaia.hold((n % 6 < 3) and { "a" } or {}) else gaia.release() end
      if o.input then local b = o.input(S.t, S) if b ~= nil then gaia.hold(b) end end
      if o.tick then o.tick(S.t, S, n) end
      if snapAt[S.t] and not S.snapDone then
        S.snapDone = S.snapDone or {}
      end
      if snapAt[S.t] and (S.lastSnapT ~= S.t) then
        S.lastSnapT = S.t
        local sn2 = e1.snap(); sn2.t = S.t; sn2.tag = "t" .. S.t
        S.snaps[#S.snaps + 1] = e1.fmt(sn2)
      end
      local left = o.scene and sc ~= o.scene and not o.allowLeave
      if left then
        S.leftAt = { t = S.t, frame = f, scene = sc, next = sn }
        local sn3 = e1.snap(); sn3.t = S.t; sn3.tag = "LEFT_t" .. S.t
        S.snaps[#S.snaps + 1] = e1.fmt(sn3)
      end
      if left or (post and S.t >= post) or (not post and n >= (o.frames or 300)) then
        flushRun()
        S.runs[#S.runs + 1] = "(end)"
        gaia.release()
        -- file output
        local lines = {}
        lines[#lines + 1] = "--- snapshots"
        for _, s in ipairs(S.snaps) do lines[#lines + 1] = s end
        lines[#lines + 1] = "--- events"
        for _, s in ipairs(S.chg) do lines[#lines + 1] = s end
        lines[#lines + 1] = "--- per-frame runs of $2130/$2131/$2132 (after arrival)"
        for _, s in ipairs(S.runs) do lines[#lines + 1] = s end
        lines[#lines + 1] = "--- last write per register (reg value pc frame t count; pcs=count)"
        local regs = {}
        for r in pairs(S.last) do regs[#regs + 1] = r end
        table.sort(regs)
        for _, r in ipairs(regs) do
          local e = S.last[r]
          local pcs = {}
          for p, c in pairs(e.pcs) do pcs[#pcs + 1] = p .. "x" .. c end
          table.sort(pcs)
          lines[#lines + 1] = string.format("%04X %s %02X pc=%d f=%d t=%d n=%d pcs=%s", r, WATCH[r] or "", e.v, e.pc, e.f, e.t, e.n, table.concat(pcs, ","))
        end
        local fileBytes = 0
        if o.cgramOut then
          -- full CGRAM (256 colours, RGB555 words, 16 colours per row) as text
          local rows = {}
          for r = 0, 15 do
            local row = {}
            for c = 0, 15 do row[#row + 1] = string.format("%04X", emu.read16((r * 16 + c) * 2, emu.memType.snesCgRam, false)) end
            rows[#rows + 1] = string.format("%02X: %s", r * 16, table.concat(row, " "))
          end
          emu.mcp.writeFile(o.cgramOut, table.concat(rows, "\n") .. "\n", false)
        end
        if o.out then
          local chunk, size, first = {}, 0, true
          for _, line in ipairs(lines) do
            chunk[#chunk + 1] = line; size = size + #line + 1
            if size > 2800 then emu.mcp.writeFile(o.out, table.concat(chunk, "\n") .. "\n", not first); fileBytes, first, chunk, size = fileBytes + size, false, {}, 0 end
          end
          if #chunk > 0 then emu.mcp.writeFile(o.out, table.concat(chunk, "\n") .. "\n", not first); fileBytes = fileBytes + size end
        end
        local lastTbl = {}
        for _, r in ipairs(regs) do
          local e = S.last[r]
          lastTbl[#lastTbl + 1] = string.format("%04X %s=%02X pc=%d f=%d n=%d", r, WATCH[r] or "", e.v, e.pc, e.f, e.n)
        end
        local show, shown = o.show or 40, {}
        for i = 1, math.min(show, #S.chg) do shown[i] = S.chg[i] end
        local runShow, rs = o.runShow or 40, {}
        for i = 1, math.min(runShow, #S.runs) do rs[i] = S.runs[i] end
        local res = {
          leftAt = S.leftAt,
          control = { w36Writes = S.w36, nmiExec = S.nmi, ppuWrites = S.nwrites, backdropWritesNonzero = S.bdNonzero, backdropWritesZero = S.bdZero, frames = n, file = o.out, fileBytes = fileBytes, evTotal = S.nev, evKept = #S.chg, nRuns = #S.runs },
          arrive = { frame = S.arriveFrame, sceneSetFrame = S.sceneSetFrame, firstNmiFrame = S.firstNmiFrame, n36Arrive = S.n36Arrive, t = S.t, startFrame = S.startFrame },
          snaps = S.snaps, last = o.brief and (function() local t = {} for _, r in ipairs(lastTbl) do if r:find("^212[CD]") or r:find("^213[0-2]") or r:find("^2105") or r:find("^2101") then t[#t + 1] = r end end return t end)() or lastTbl,
          events = shown, runs = rs,
        }
        if o.final then res.final = o.final(S) end
        kit.finish(res)
        return
      end
    end
  end)
end
