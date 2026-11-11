-- description: E2 palette bundle study: static decode of palette_bundles (ROM bank $16 = CPU bank $96), runtime capture of every bundle start / end (exec callbacks), scene sweep driver.
-- requires: mesen_kit, iog_kit, gaia_kit
--
-- ROM O offsets (decimal PRG offsets). palette_bundles table = 1474560 ($168000), 128 word pointers (offset inside bank $16).
-- A bundle = list of 6-byte sub-entries < N, &frames, dest, size-1, wait > ended by N = 0. Frame data lives at $160000 + &frames.
--
--   e2.decode()                 table of the 128 bundles (strips, CGRAM ranges, colour and frame counts, tick estimate, data extents)
--   e2.writeStatic(file)        one line per bundle into <results>/<file>  (parsed by harness/e2_merge.py)
--   e2.watch(o)                 exec callbacks on PaletteRestart (37729), PaletteStart (37732), PaletteStartLoop (37761), the end-of-bundle
--                               exits of PaletteStep (37816) and PaletteStepLoop (37865), plus the controls (write $36, NMI exec 33528);
--                               returns the state table S. Events are appended to S.ev as compact "|"-separated rows.
--   e2.sweep(o)                 warp driver over a scene list from a base savestate (o.scenes, o.post frames after arrival)
--   e2.dump(S, file)            write S.ev / S.cap rows to <results>/<file> in chunks of at most 2800 bytes
e2 = e2 or {}

local PRG = emu.memType.snesPrgRom
local WR  = emu.memType.snesWorkRam
local CG  = emu.memType.snesCgRam
local CPU = emu.cpuType.snes

local TABLE, BANK = 1474560, 0x160000
local PC_RESTART, PC_START, PC_STARTLOOP = 37729, 37732, 37761
local PC_STEP_END, PC_STEPLOOP_END = 37816, 37865
local PC_STEP_FIRST = 37754      -- LDA $0C after both JSLs of the shared Start tail (frame 0 is in the staging buffer)
local PC_STARTLOOP_FIRST = 37795 -- LDA $0A after both JSLs of PaletteStartLoop
local PC_NMI = 33528
local STAGE = 0x10A00            -- $7F:0A00 palette staging buffer (WRAM offset)
local BACKDROP = 0x10C00         -- $7F:0C00 backdrop colours (3 bytes, fixed colour)

local function rb(off) return emu.read(off, PRG, false) end
local function rw(off) return rb(off) | (rb(off + 1) << 8) end
local function hex(v, w) return string.format("%0" .. (w or 2) .. "X", v) end

-- static decode ----------------------------------------------------------------------------------------------------------
function e2.decode()
  local B = {}
  for id = 0, 127 do
    local ptr = rw(TABLE + 2 * id)
    local b = { id = id, ptr = ptr, off = BANK + ptr, strips = {}, frames = 0, ticks = 0 }
    local o = b.off
    while true do
      local n = rb(o)
      if n == 0 then break end
      local st = { n = n, src = rw(o + 1), dest = rb(o + 3), sz = rb(o + 4), wait = rb(o + 5), sub = o }
      st.bytes = st.sz + 1
      st.backdrop = (st.sz == 2)
      st.colours = st.backdrop and 0 or (st.bytes // 2)
      b.strips[#b.strips + 1] = st
      b.frames = b.frames + n
      b.ticks = b.ticks + n * (st.wait + 1)
      o = o + 6
      if #b.strips > 400 then b.runaway = true; break end
    end
    b.term = o
    local lo, hi, dlo, dhi = nil, nil, nil, nil
    local bd = false
    for _, st in ipairs(b.strips) do
      local a, e = BANK + st.src, BANK + st.src + st.n * st.bytes - 1
      st.lo, st.hi = a, e
      if not lo or a < lo then lo = a end
      if not hi or e > hi then hi = e end
      if st.backdrop then bd = true
      else
        local d0, d1 = st.dest, st.dest + st.colours - 1
        if not dlo or d0 < dlo then dlo = d0 end
        if not dhi or d1 > dhi then dhi = d1 end
      end
    end
    b.dataLo, b.dataHi, b.dlo, b.dhi, b.hasBackdrop = lo, hi, dlo, dhi, bd
    B[id] = b
  end
  return B
end

-- one line per bundle: id|ptr|listOff|termOff|nstrips|frames|ticks|dataLo|dataHi|dlo|dhi|backdrop|runaway|strip;strip;...  strip = n,src,dest,sz,wait
function e2.writeStatic(file)
  local B = e2.decode()
  local lines = {}
  for id = 0, 127 do
    local b = B[id]
    local s = {}
    for _, st in ipairs(b.strips) do s[#s + 1] = string.format("%d,%d,%d,%d,%d", st.n, st.src, st.dest, st.sz, st.wait) end
    lines[#lines + 1] = string.format("%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%s", id, b.ptr, b.off, b.term, #b.strips, b.frames, b.ticks,
      b.dataLo or -1, b.dataHi or -1, b.dlo or -1, b.dhi or -1, b.hasBackdrop and 1 or 0, b.runaway and 1 or 0, table.concat(s, ";"))
  end
  local chunk, size, first, total = {}, 0, true, 0
  for _, line in ipairs(lines) do
    chunk[#chunk + 1] = line; size = size + #line + 1
    if size > 2800 then emu.mcp.writeFile(file, table.concat(chunk, "\n") .. "\n", not first); total, first, chunk, size = total + size, false, {}, 0 end
  end
  if #chunk > 0 then emu.mcp.writeFile(file, table.concat(chunk, "\n") .. "\n", not first); total = total + size end
  return total, B
end

-- runtime ------------------------------------------------------------------------------------------------------------------
local function cgWords(lo, hi)
  local t = {}
  for i = lo, hi do t[#t + 1] = emu.read16(i * 2, CG, false) end
  return t
end
local function stageWords(lo, hi)
  local t = {}
  for i = lo, hi do t[#t + 1] = emu.read16(STAGE + i * 2, WR, false) end
  return t
end
local function bdBytes() return { emu.read(BACKDROP, WR, false), emu.read(BACKDROP + 1, WR, false), emu.read(BACKDROP + 2, WR, false) } end

-- scene id: $0644 (WRAM) ; frame = emulator frame counter
local function sceneNow() return emu.read16(0x0644, WR, false) end
local function frameNow() return emu.getState()["frameCount"] end
local function n36() return emu.read16(0x0036, WR, false) end

-- o.B = decoded bundles; o.capLimit = number of starts per bundle with a full before/first/end/after capture (default 2)
function e2.watch(o)
  local B = o.B or e2.decode()
  local S = { B = B, ev = {}, nev = 0, w36 = 0, nmi = 0, cur = {}, counts = {}, starts = {}, ends = {}, caps = {}, pend = {}, ncap = {}, rowCap = o.rowCap or 400 }
  local capLimit = o.capLimit or 2

  emu.addMemoryCallback(function(a) if (a & 0xFFFF) == 0x36 then S.w36 = S.w36 + 1 end end, emu.callbackType.write, 0x36, 0x36, CPU, WR)
  emu.addMemoryCallback(function() S.nmi = S.nmi + 1 end, emu.callbackType.exec, PC_NMI, PC_NMI, CPU, PRG)

  local function emit(s)
    S.nev = S.nev + 1
    if #S.ev < S.rowCap then S.ev[#S.ev + 1] = s end
  end

  -- operand byte of the COP at the current script pointer ([$0A] long pointer, D = actor slot)
  local function operand(d)
    local ptr, bank = emu.read16(d + 0x0A, WR, false), emu.read(d + 0x0C, WR, false)
    local off = ((bank & 0x3F) << 16) | ptr
    return rb(off), off, bank, ptr
  end

  local function onStart(op)
    return function()
      local st = emu.getState()
      local d = st["cpu.d"]
      local id, off
      if op == 36 then
        id = emu.read16(0x10002 + d, WR, false) & 0xFF
        local ptr, bank = emu.read16(d + 0x0A, WR, false), emu.read(d + 0x0C, WR, false)
        off = ((bank & 0x3F) << 16) | ptr
      else
        id, off = operand(d)
        id = id & 0xFF
      end
      local f, sc, nn = st["frameCount"], sceneNow(), n36()
      local c = S.counts[id]
      if not c then c = { n = 0, scenes = {}, sites = {}, ops = {} }; S.counts[id] = c end
      c.n = c.n + 1
      c.scenes[sc] = (c.scenes[sc] or 0) + 1
      c.sites[off] = (c.sites[off] or 0) + 1
      c.ops[op] = (c.ops[op] or 0) + 1
      -- the first start of each (bundle, scene, site) is a row; later ones are only counted
      local key = id .. ":" .. sc .. ":" .. off
      if not S.starts[key] then
        S.starts[key] = true
        emit(string.format("S|%02X|%02X|%d|%d|%d|op%d|site%d|slot%X|pc%d|k%X|%s", id, sc, f, nn, c.n, op, off, d, st["cpu.pc"], st["cpu.k"], o.tag or ""))
      end
      if o.ppuIds and o.ppuIds[id] then
        emit(string.format("F|%02X|%02X|%d|en%02X|sub%s|half%s|addsub%s|fc%04X|slot%X", id, sc, f, st["ppu.colorMathEnabled"] or 0, tostring(st["ppu.colorMathSubtractMode"]),
          tostring(st["ppu.colorMathHalveResult"]), tostring(st["ppu.colorMathAddSubscreen"]), st["ppu.fixedColor"] or 0, d))
      end
      -- capture set: before (CGRAM), first and end (staging), after (CGRAM)
      S.ncap[id] = S.ncap[id] or 0
      local b = B[id]
      local slotst = { id = id, f0 = f, n0 = nn, scene = sc, op = op }
      if S.ncap[id] < capLimit and b and (b.dlo or b.hasBackdrop) then
        slotst.cap = true
        if b.dlo then slotst.before = cgWords(b.dlo, b.dhi) end
        if b.hasBackdrop then slotst.bdBefore = bdBytes(); slotst.fcBefore = st["ppu.fixedColor"] end
      end
      S.cur[d] = slotst
    end
  end

  local function onFirst(op)
    return function()
      local d = emu.getState()["cpu.d"]
      local sl = S.cur[d]
      if sl and sl.cap and not sl.first then
        local b = B[sl.id]
        if b.dlo then sl.first = stageWords(b.dlo, b.dhi) end
        if b.hasBackdrop then sl.bdFirst = bdBytes() end
      end
    end
  end

  local function onEnd(op)
    return function()
      local st = emu.getState()
      local d = st["cpu.d"]
      local id = emu.read16(0x10002 + d, WR, false) & 0xFF
      local sl = S.cur[d]
      local nn, f = n36(), st["frameCount"]
      local e = S.ends[id]
      if not e then e = { n = 0 }; S.ends[id] = e end
      e.n = e.n + 1
      local ticks = sl and sl.id == id and ((nn - sl.n0) & 0xFFFF) or -1
      if e.n <= 3 then e["t" .. e.n] = ticks end
      if sl and sl.id == id and sl.cap and not sl.done then
        sl.done = true
        local b = B[id]
        if b.dlo then sl.last = stageWords(b.dlo, b.dhi) end
        if b.hasBackdrop then sl.bdLast = bdBytes() end
        sl.ticks = ticks
        sl.endN = nn
        S.pend[#S.pend + 1] = { sl = sl, due = nn + 3 }
      end
      if e.n <= 2 then emit(string.format("E|%02X|%02X|%d|%d|ticks%d|op%d|slot%X", id, sceneNow(), f, nn, ticks, op, d)) end
    end
  end

  -- every use of a bundle goes through LoadPaletteBundle (254128): X = actor slot, bundle id = $7F0002 + X (counts per bundle, independent of the start ops)
  S.load = {}
  emu.addMemoryCallback(function()
    local x = emu.getState()["cpu.x"]
    local id = emu.read16(0x10002 + x, WR, false) & 0xFF
    S.load[id] = (S.load[id] or 0) + 1
  end, emu.callbackType.exec, 254128, 254128, CPU, PRG)
  emu.addMemoryCallback(onStart(36), emu.callbackType.exec, PC_RESTART, PC_RESTART, CPU, PRG)
  emu.addMemoryCallback(onStart(37), emu.callbackType.exec, PC_START, PC_START, CPU, PRG)
  emu.addMemoryCallback(onStart(38), emu.callbackType.exec, PC_STARTLOOP, PC_STARTLOOP, CPU, PRG)
  emu.addMemoryCallback(onFirst(37), emu.callbackType.exec, PC_STEP_FIRST, PC_STEP_FIRST, CPU, PRG)
  emu.addMemoryCallback(onFirst(38), emu.callbackType.exec, PC_STARTLOOP_FIRST, PC_STARTLOOP_FIRST, CPU, PRG)
  emu.addMemoryCallback(onEnd(39), emu.callbackType.exec, PC_STEP_END, PC_STEP_END, CPU, PRG)
  emu.addMemoryCallback(onEnd(58), emu.callbackType.exec, PC_STEPLOOP_END, PC_STEPLOOP_END, CPU, PRG)

  -- executed-PC set of the step handlers and the two bundle routines (OQ-31: no call leaves these ranges)
  S.pcs = {}
  local function pcHit() local st = emu.getState(); local k = ((st["cpu.k"] & 0x3F) << 16) | st["cpu.pc"]; S.pcs[k] = (S.pcs[k] or 0) + 1 end
  if o.pcSet then
    emu.addMemoryCallback(pcHit, emu.callbackType.exec, 37729, 37887, CPU, PRG)
    emu.addMemoryCallback(pcHit, emu.callbackType.exec, 254128, 254277, CPU, PRG)
  end

  -- finish pending captures: CGRAM two NMI frames after the end of the bundle
  function S.tick()
    local nn = n36()
    local keep = {}
    for _, p in ipairs(S.pend) do
      if ((nn - p.due) & 0xFFFF) < 0x8000 then
        local sl = p.sl
        local b = B[sl.id]
        if b.dlo then sl.after = cgWords(b.dlo, b.dhi) end
        if b.hasBackdrop then sl.fcAfter = emu.getState()["ppu.fixedColor"] end
        S.ncap[sl.id] = (S.ncap[sl.id] or 0) + 1
        S.caps[#S.caps + 1] = sl
      else keep[#keep + 1] = p end
    end
    S.pend = keep
  end
  function S.reset() S.cur = {}; S.pend = {} end
  S.o = o
  return S
end

-- compact change rows of one capture: "C|id|scene|f0|ticks|colour:before>first>last>after ..." (colours that differ anywhere), backdrop rows
function e2.capRows(S)
  local rows = {}
  for _, sl in ipairs(S.caps) do
    local b = S.B[sl.id]
    local parts, diffs = {}, 0
    if b.dlo and sl.before and sl.first and sl.last and sl.after then
      for i = 0, b.dhi - b.dlo do
        local a, f, l, z = sl.before[i + 1], sl.first[i + 1], sl.last[i + 1], sl.after[i + 1]
        if a ~= f or a ~= l or a ~= z or f ~= l then
          diffs = diffs + 1
          if #parts < 12 then parts[#parts + 1] = string.format("%02X:%04X>%04X>%04X>%04X", b.dlo + i, a, f, l, z) end
        end
      end
    end
    local bd = ""
    if b.hasBackdrop and sl.bdBefore then
      bd = string.format("|bd %s>%s>%s fc %04X>%04X", table.concat((function() local t = {} for _, v in ipairs(sl.bdBefore) do t[#t + 1] = hex(v) end return t end)()),
        sl.bdFirst and table.concat((function() local t = {} for _, v in ipairs(sl.bdFirst) do t[#t + 1] = hex(v) end return t end)()) or "--",
        sl.bdLast and table.concat((function() local t = {} for _, v in ipairs(sl.bdLast) do t[#t + 1] = hex(v) end return t end)()) or "--",
        sl.fcBefore or 0, sl.fcAfter or 0)
    end
    rows[#rows + 1] = string.format("C|%02X|%02X|%d|ticks%d|n%d|%s%s", sl.id, sl.scene, sl.f0, sl.ticks or -1, diffs, table.concat(parts, " "), bd)
  end
  return rows
end

-- per = list of per-scene rows of e2.sweep; written as "P|scene|arrive|t|sceneEnd|timeout|startsDelta|mask"; N rows = per bundle totals of this run
function e2.dump(S, file, per, append)
  local lines = {}
  for _, r in ipairs(per or {}) do
    lines[#lines + 1] = string.format("P|%02X|%s|%s|%02X|%s|%d|%04X", r.scene, tostring(r.arrive), tostring(r.t), r.sceneEnd or 0, r.timeout and "TIMEOUT" or "ok",
      (r.startsAfter or 0) - (r.startsBefore or 0), r.mask or 0)
  end
  for _, r in ipairs(S.ev) do lines[#lines + 1] = r end
  for _, r in ipairs(e2.capRows(S)) do lines[#lines + 1] = r end
  local ids = {}
  for id in pairs(S.counts) do ids[#ids + 1] = id end
  table.sort(ids)
  for _, id in ipairs(ids) do
    local c = S.counts[id]
    local sc, sites, ops = {}, {}, {}
    for k, v in pairs(c.scenes) do sc[#sc + 1] = string.format("%02X:%d", k, v) end
    for k, v in pairs(c.sites) do sites[#sites + 1] = string.format("%d:%d", k, v) end
    for k, v in pairs(c.ops) do ops[#ops + 1] = string.format("%d:%d", k, v) end
    table.sort(sc); table.sort(sites); table.sort(ops)
    local e = S.ends[id] or {}
    lines[#lines + 1] = string.format("N|%02X|%d|%s|%s|%s|ends%d t1=%s|load%d", id, c.n, table.concat(sc, ","), table.concat(sites, ","), table.concat(ops, ","), e.n or 0, tostring(e.t1), S.load and S.load[id] or 0)
  end
  if S.load then
    local lids = {}
    for id in pairs(S.load) do lids[#lids + 1] = id end
    table.sort(lids)
    for _, id in ipairs(lids) do
      lines[#lines + 1] = string.format("L|%02X|%d|startsLogged%d", id, S.load[id], S.counts[id] and S.counts[id].n or 0)
    end
  end
  local chunk, size, first, total = {}, 0, not append, 0
  for _, line in ipairs(lines) do
    chunk[#chunk + 1] = line; size = size + #line + 1
    if size > 2800 then emu.mcp.writeFile(file, table.concat(chunk, "\n") .. "\n", not first); total, first, chunk, size = total + size, false, {}, 0 end
  end
  if #chunk > 0 then emu.mcp.writeFile(file, table.concat(chunk, "\n") .. "\n", not first); total = total + size end
  return total
end

-- scene sweep driver -------------------------------------------------------------------------------------------------------
-- o.scenes = list of scene ids; o.post = NMI frames watched after arrival (default 150); o.base = savestate string (created at the first NMI if nil)
-- emu.createSavestate / emu.loadSavestate only work inside an exec callback of the main CPU: the driver arms a request and an NMI exec callback performs it.
-- Each scene: loadSavestate(base), 3 frames, flags (o.flagsFor(scene) -> list), sceneNext = id, wait for $0644 == id and $0642 == 0, banner pulses of A, watch.
-- When the run finishes it calls o.done(S, per) with the per-scene summary rows.
function e2.sweep(o, S)
  local per = {}
  local idx, stage, t0, base = 0, "init", 0, o.base
  local arriveN36 = 0
  local post = o.post or 150
  local nf = 0
  local req = base and nil or "create"
  local row, pendingRef
  local function nextScene()
    idx = idx + 1
    if idx > #o.scenes then
      stage = "end"
      if o.done then o.done(S, per) end
      return
    end
    row = { scene = o.scenes[idx], startsBefore = S.nev }
    stage = "loading"; t0 = nf
    if S.reset then S.reset() end
    req = "load"
    -- a state can be loaded only inside an exec callback: a temporary callback over the whole ROM performs the load at the next instruction
    -- (an NMI-only callback never fires when the previous scene left the game with NMI disabled, e.g. a blocking SPC transfer)
    local ref
    ref = emu.addMemoryCallback(function()
      if req == "load" then
        req = nil
        emu.loadSavestate(base); stage = "load"; t0 = nf
      end
    end, emu.callbackType.exec, 0, 0x1FFFFF, CPU, PRG)
    S.tmpRefs = S.tmpRefs or {}
    S.tmpRefs[#S.tmpRefs + 1] = ref
    pendingRef = ref
  end
  emu.addMemoryCallback(function()
    if req == "create" then
      base = emu.createSavestate(); req = nil
      nextScene()
    end
  end, emu.callbackType.exec, PC_NMI, PC_NMI, CPU, PRG)
  if base then nextScene() end
  kit.onFrame(function()
    nf = nf + 1
    if S.tick then S.tick() end
    if pendingRef and stage ~= "loading" then
      pcall(emu.removeMemoryCallback, pendingRef, emu.callbackType.exec, 0, 0x1FFFFF, CPU, PRG)
      pendingRef = nil
    end
    if stage == "load" then
      if nf - t0 >= 3 and emu.read16(0x0642, WR, false) == 0 then
        for _, id in ipairs((o.flagsFor and o.flagsFor(row.scene)) or {}) do iog.setEventFlag(id) end
        if o.beforeWarp then o.beforeWarp(row.scene) end
        emu.write16(0x0642, row.scene, WR)
        stage = "warp"; t0 = nf
      end
    elseif stage == "warp" then
      if sceneNow() == row.scene and emu.read16(0x0642, WR, false) == 0 then
        stage = "watch"; t0 = nf; arriveN36 = n36(); row.arrive = nf
      elseif nf - t0 > (o.warpTimeout or 900) then
        row.timeout = true; row.sceneEnd = sceneNow(); row.next = emu.read16(0x0642, WR, false); per[#per + 1] = row
        nextScene()
      end
    elseif stage == "watch" then
      local a = emu.read(0x00B4, WR, false)
      if a ~= 0 and not (o.noBanner and o.noBanner[row.scene]) then gaia.hold((nf % 6 < 3) and { "a" } or {}) else gaia.release() end
      if o.tick then o.tick(row.scene, ((n36() - arriveN36) & 0xFFFF), nf) end
      if ((n36() - arriveN36) & 0xFFFF) >= post or nf - t0 > post * 4 + 300 then
        gaia.release()
        row.t = ((n36() - arriveN36) & 0xFFFF); row.sceneEnd = sceneNow(); row.startsAfter = S.nev; row.mask = emu.read16(0x065A, WR, false)
        per[#per + 1] = row
        if o.progress then emu.mcp.writeFile(o.progress, string.format("scene %02X done t=%s end=%02X\n", row.scene, tostring(row.t), row.sceneEnd or 0), true) end
        nextScene()
      end
    end
  end)
end

-- one sweep run: e2.run(scenes, file, {post=, tag=, capLimit=, flagsFor=, tick=})
function e2.run(scenes, file, o)
  o = o or {}
  local S = e2.watch{ tag = o.tag, capLimit = o.capLimit or 1, rowCap = o.rowCap or 500, pcSet = o.pcSet, ppuIds = o.ppuIds }
  e2.sweep({ scenes = scenes, post = o.post or 150, progress = o.progress, noBanner = o.noBanner, flagsFor = o.flagsFor, tick = o.tick, beforeWarp = o.beforeWarp, done = function(S2, per)
    local n = e2.dump(S2, file, per)
    if o.extra then
      local rows, chunk, size = o.extra(S2, per) or {}, {}, 0
      for _, line in ipairs(rows) do
        chunk[#chunk + 1] = line; size = size + #line + 1
        if size > 2600 then emu.mcp.writeFile(file, table.concat(chunk, "\n") .. "\n", true); n, chunk, size = n + size, {}, 0 end
      end
      if #chunk > 0 then emu.mcp.writeFile(file, table.concat(chunk, "\n") .. "\n", true); n = n + size end
    end
    local to = {}
    for _, r in ipairs(per) do if r.timeout then to[#to + 1] = string.format("%02X", r.scene) end end
    kit.finish({ scenes = #per, w36 = S2.w36, nmi = S2.nmi, nev = S2.nev, bytes = n, caps = #S2.caps, timeouts = table.concat(to, ","), pcs = S2.pcs })
  end }, S)
end
