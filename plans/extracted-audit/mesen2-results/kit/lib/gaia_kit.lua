-- description: Illusion of Gaia investigation helpers: capped log, collision layer access, held input, per-frame trials.
-- requires: mesen_kit, iog_kit
--
-- Load with run_script / load_script  includes=["gaia_kit"]  (the server resolves "requires" for you).
-- The server must be started with --mcp-lib-dir=<this folder> (see harness/README.md). mesen_kit, iog_kit and the
-- recipes come from the server's own lua/lib (server 0.5.0 searches --mcp-lib-dir folders after its own); this
-- folder holds only the project module.
--
-- All addresses are WRAM offsets (snesWorkRam): $7E:xxxx = 0xxxxx, $7F:xxxx = 0x10000 + xxxx.
--
--   gaia.log(fmt, ...)                    capped log (200 lines, then one "LOG CAP" row)
--   gaia.coll.get(tx, ty) / set(tx, ty, v) / index(tx, ty)   collision layer cell by TILE coordinate
--   gaia.coll.probeTile(x, y)             tile used by CheckActorOnSpecialTile for an actor at pixel (x, y)
--   gaia.player()                         {x, y, flags10, flags12, sEw, sNs, scene, hp, mask, banner, frame36}
--   gaia.hold({"right"}) / gaia.release() hold buttons from an inputPolled callback (port 0)
--   gaia.trial{setup=fn, hold={..}, frames=N, sample=fn, final=fn}   run a per-frame trial, then finish with a result
--   gaia.flags.get/set/clear(n), gaia.flags.dump(), gaia.flags.diff(a, b), gaia.flagwatch{...}   script flags $0A00-$0AB3 (FR00)
--   gaia.execMarks{ name = rom_offset, ... }   frames of the executions of chosen instructions (FR00)
gaia = gaia or {}

local WR = emu.memType.snesWorkRam
gaia.WR = WR

gaia.addr = {
  frame36 = 0x0036, sceneNext = 0x0642, sceneCur = 0x0644, collStride = 0x0693,
  boundsX = 0x0692, boundsY = 0x0696, bannerFlag = 0x00B4, inputMask = 0x065A,
  playerFlags10 = 0x1010, playerFlags12 = 0x1012, playerX = 0x1014, playerY = 0x1016,
  speedEw = 0x09B2, speedNs = 0x09B4, hp = 0x0ACE, maxHp = 0x0ACA,
}

-- capped log -----------------------------------------------------------------------------------
local CAP, nlog = 200, 0
function gaia.log(fmt, ...)
  if nlog < CAP then
    nlog = nlog + 1
    emu.log(select("#", ...) > 0 and string.format(fmt, ...) or fmt)
  elseif nlog == CAP then
    nlog = nlog + 1
    emu.log("-- LOG CAP REACHED --")
  end
end

-- collision layer: 256-byte pages of 16x16 tiles; page = (ty>>4) * stride + (tx>>4); see tile_collision_physics.asm
gaia.coll = { base = 0x1C000 }

function gaia.coll.index(tx, ty)
  local stride = kit.r8(gaia.addr.collStride)
  return (((ty >> 4) * stride + (tx >> 4)) << 8) | ((ty & 15) << 4) | (tx & 15)
end

function gaia.coll.get(tx, ty) return kit.r8(gaia.coll.base + gaia.coll.index(tx, ty)) end
function gaia.coll.set(tx, ty, v) kit.w8(gaia.coll.base + gaia.coll.index(tx, ty), v) end

-- CheckActorOnSpecialTile probes (actorX - 8, actorY - 16); the probe is skipped when either value is 16-aligned.
function gaia.coll.probeTile(x, y)
  local px, py = x - 8, y - 16
  return px >> 4, py >> 4, (px & 15) ~= 0 and (py & 15) ~= 0
end

-- B1 census of the whole collision layer of the loaded scene ------------------------------------
-- Walks every cell of the page grid (stride = $0693 pages across, $0697 pages down; one page = 16 x 16 cells) with
-- gaia.coll.get. Returns one row (a table for kit.finish): bounds words, strides, per-nibble histograms (index = value + 1),
-- the first `maxFirst` cells (tx, ty in row-major order) of every type in `firsts` (low nibble), map-data-size words.
-- A page grid above 64 pages would run past $7F:FFFF (the layer starts at $7F:C000): it is clamped and flagged.
function gaia.coll.census(firsts, maxFirst)
  firsts, maxFirst = firsts or { 6, 9 }, maxFirst or 10
  local A = gaia.addr
  local stride, rows = kit.r8(A.collStride), kit.r8(0x0697)
  local clamped = false
  if stride * rows > 64 then rows = math.max(1, 64 // math.max(stride, 1)); clamped = true end
  local w, h = stride * 16, rows * 16
  local low, hi = {}, {}
  for i = 1, 16 do low[i], hi[i] = 0, 0 end
  local want, first = {}, {}
  for _, t in ipairs(firsts) do want[t] = true; first[string.format("%02X", t)] = {} end
  for ty = 0, h - 1 do
    for tx = 0, w - 1 do
      local v = gaia.coll.get(tx, ty)
      local lo, hn = v & 15, v >> 4
      low[lo + 1] = low[lo + 1] + 1
      hi[hn + 1] = hi[hn + 1] + 1
      if want[lo] then
        local f = first[string.format("%02X", lo)]
        if #f < maxFirst then f[#f + 1] = { tx, ty, v } end
      end
    end
  end
  return {
    scene = kit.r16(A.sceneCur), boundsX = kit.r16(A.boundsX), boundsY = kit.r16(A.boundsY),
    stride = stride, rows = rows, cellsW = w, cellsH = h, clamped = clamped,
    stride1 = kit.r8(0x0695), rows1 = kit.r8(0x0699), boundsX1 = kit.r16(0x0694), boundsY1 = kit.r16(0x0698),
    size069A = kit.r16(0x069A), size069C = kit.r16(0x069C), scrollMode06EF = kit.r16(0x06EF),
    low = low, hi = hi, first = first,
    playerX = kit.r16(A.playerX), playerY = kit.r16(A.playerY), mask = kit.r16(A.inputMask), banner = kit.r8(A.bannerFlag),
  }
end

-- OQ-3 data-flow check (scene_script BuildMetatileFlagTable + FillCollisionFromLayer0): the collision byte of cell i is
-- flagTable[mapData[i]] with the flag table in bank $7F (pointer $06AA) and the map data (one metatile index byte per cell,
-- bank $7E, start = word $069E). Counts the cells whose low nibble differs from the flag table byte (a high nibble is a
-- dynamic mark and is ignored), the words of the 256 metatile definitions (bank $7E, pointer $06AE, 4 words each) that still
-- have bit 9 set (the routine clears it), and returns the 4 words of the first metatile whose flag is each of `want`.
function gaia.coll.verifyFlow(want)
  want = want or { 6, 9 }
  local baseA, ftab, defp = kit.r16(0x069E), kit.r16(0x06AA), kit.r16(0x06AE)
  local n = kit.r8(0x0693) * kit.r8(0x0697) * 256
  local mism, firstm, used = 0, {}, {}
  for m = 0, 255 do used[m] = 0 end
  for i = 0, n - 1 do
    local m = kit.r8(baseA + i)
    used[m] = used[m] + 1
    local f = kit.r8(0x10000 + ftab + m) & 15
    local c = kit.r8(0x1C000 + i) & 15
    if c ~= f then
      mism = mism + 1
      if #firstm < 5 then firstm[#firstm + 1] = { i, m, c, f } end
    end
  end
  local bit9, merge, hist = 0, {}, {}
  for i = 1, 16 do hist[i] = 0 end
  local meta = {}
  for m = 0, 255 do
    local f = kit.r8(0x10000 + ftab + m) & 15
    if used[m] > 0 then hist[f + 1] = hist[f + 1] + used[m] end
    local words = {}
    for w = 0, 3 do
      local v = kit.r16(defp + m * 8 + w * 2)
      words[#words + 1] = v
      if used[m] > 0 and (v & 0x0200) ~= 0 then bit9 = bit9 + 1 end
    end
    for _, t in ipairs(want) do
      if f == t and used[m] > 0 and not meta[string.format("%02X", t)] then
        meta[string.format("%02X", t)] = { metatile = m, cellsUsingIt = used[m], words = words }
      end
    end
  end
  return { baseA = baseA, flagTable = ftab, defTable = defp, cells = n, mismatches = mism, firstMismatches = firstm,
           usedMetatileWordsWithBit9 = bit9, cellsPerFlagValue = hist, firstMetatileOfType = meta,
           scrollMode06EF = kit.r16(0x06EF), mergeWord06A2 = kit.r16(0x06A2) }
end

-- Runs gaia.coll.census at the `after`-th frame end (default 3) with a positive control: the number of writes of the
-- frame counter $36 seen up to then (the NMI writes it once per frame). Ends the run with the row (kit.finish).
function gaia.coll.censusRun(firsts, maxFirst, after)
  local ctl, f = 0, 0
  emu.addMemoryCallback(function(a, v)
    if (a & 0xFFFF) == 0x36 then ctl = ctl + 1 end
  end, emu.callbackType.write, 0x36, 0x36, emu.cpuType.snes, WR)
  kit.onFrame(function()
    f = f + 1
    if f < (after or 3) then return end
    local row = gaia.coll.census(firsts, maxFirst)
    row.control36Writes, row.frames = ctl, f
    kit.finish(row)
  end)
end

-- Same as censusRun for gaia.coll.verifyFlow (OQ-3).
function gaia.coll.flowRun(want, after)
  local ctl, f = 0, 0
  emu.addMemoryCallback(function(a, v)
    if (a & 0xFFFF) == 0x36 then ctl = ctl + 1 end
  end, emu.callbackType.write, 0x36, 0x36, emu.cpuType.snes, WR)
  kit.onFrame(function()
    f = f + 1
    if f < (after or 3) then return end
    local row = gaia.coll.verifyFlow(want)
    row.scene, row.control36Writes, row.frames = kit.r16(gaia.addr.sceneCur), ctl, f
    kit.finish(row)
  end)
end

-- player snapshot ------------------------------------------------------------------------------
function gaia.player()
  local a = gaia.addr
  return {
    x = kit.r16(a.playerX), y = kit.r16(a.playerY),
    flags10 = kit.r16(a.playerFlags10), flags12 = kit.r16(a.playerFlags12),
    sEw = kit.r16(a.speedEw, nil, true), sNs = kit.r16(a.speedNs, nil, true),
    scene = kit.r16(a.sceneCur), hp = kit.r16(a.hp), mask = kit.r16(a.inputMask),
    banner = kit.r8(a.bannerFlag), frame36 = kit.r16(a.frame36),
  }
end

-- held input -----------------------------------------------------------------------------------
local holdRef, holdButtons = nil, nil

function gaia.hold(buttons, port)
  holdButtons = buttons
  if not holdRef then
    holdRef = emu.addEventCallback(function()
      local t = {}
      for _, b in ipairs(holdButtons or {}) do t[b] = true end
      emu.setInput(t, port or 0)
    end, emu.eventType.inputPolled)
  end
end

function gaia.release()
  holdButtons = nil
end

-- W1 census: who reads / writes an address ------------------------------------------------------
-- The PC reported inside a memory callback is the address AFTER the instruction that made the access.
-- gaia.watch{ {name=, lo=, hi=, kinds={"read","write"}, bits=mask?}, ... } logs each unique (name, kind, K:PC) once
-- (first `perKey` hits are counted, later ones only counted), and returns a table of counts for kit.finish.
local census, censusN = {}, 0
function gaia.pc()
  local st = emu.getState()
  return st["cpu.k"], st["cpu.pc"], st["frameCount"]
end

function gaia.once(tag, extra)
  local k, pc, f = gaia.pc()
  local key = string.format("%s %02X:%04X", tag, k, pc)
  local e = census[key]
  if not e then
    e = { n = 0, first = f, k = k, pc = pc }
    census[key] = e
    censusN = censusN + 1
    gaia.log("%s f=%d scene=%04X %s", key, f, kit.r16(gaia.addr.sceneCur), extra or "")
  end
  e.n = e.n + 1
  return e
end

function gaia.watch(list)
  for _, w in ipairs(list) do
    for _, kind in ipairs(w.kinds or { "read", "write" }) do
      emu.addMemoryCallback(function(a, v)
        if w.bits and kind == "write" then
          local old = kit.r8(a)
          if ((old ~ v) & w.bits) == 0 then return end
        end
        gaia.once(w.name .. " " .. kind, string.format("addr=%04X val=%02X", a, v))
      end, emu.callbackType[kind], w.lo, w.hi, emu.cpuType.snes, WR)
    end
  end
end

-- rows {key, n, first} sorted by key, for kit.finish
function gaia.censusRows()
  local rows = {}
  for key, e in pairs(census) do rows[#rows + 1] = { key = key, n = e.n, first = e.first } end
  table.sort(rows, function(a, b) return a.key < b.key end)
  return rows
end

-- script flags $0A00-$0AB3 (FR00) --------------------------------------------------------------------
-- Global flag index n = WRAM byte $0A00 + (n >> 3), bit (n & 7), n in 0..1439 ($0000-$059F); the dump covers the
-- 180 bytes $0A00-$0AB3 (flag-analysis-plan 2.1). Writes go through emu.write (they do not run memory callbacks:
-- measured in FR00, so a forced write never shows up in gaia.flagwatch).
--   gaia.flags.loc(n)          -> byte offset, bit
--   gaia.flags.get(n)          -> 0 or 1
--   gaia.flags.set(n) / clear(n)  -> the bit read back after the write (1 / 0)
--   gaia.flags.dump()          -> 360 hex digits (180 bytes of $0A00-$0AB3)
--   gaia.flags.diff(a, b)      -> list of changed flag indices (ascending) and a parallel list of "<index hex>:<old>><new>"; a, b are dumps
--   gaia.flagwatch(opts)       -> handle with :summary() and :stop(); write callback over the flag array
gaia.flags = { base = 0x0A00, bytes = 180 }

function gaia.flags.loc(n)
  assert(n >= 0 and n < gaia.flags.bytes * 8, "flag index out of range: " .. tostring(n))
  return gaia.flags.base + (n >> 3), n & 7
end

function gaia.flags.get(n)
  local a, b = gaia.flags.loc(n)
  return (kit.r8(a) >> b) & 1
end

function gaia.flags.set(n)
  local a, b = gaia.flags.loc(n)
  kit.w8(a, kit.r8(a) | (1 << b))
  return gaia.flags.get(n)
end

function gaia.flags.clear(n)
  local a, b = gaia.flags.loc(n)
  kit.w8(a, kit.r8(a) & (~(1 << b) & 0xFF))
  return gaia.flags.get(n)
end

function gaia.flags.dump()
  local t = {}
  for i = 0, gaia.flags.bytes - 1 do t[#t + 1] = string.format("%02X", kit.r8(gaia.flags.base + i)) end
  return table.concat(t)
end

function gaia.flags.diff(a, b)
  local out, detail = {}, {}
  for i = 0, gaia.flags.bytes - 1 do
    local x, y = tonumber(a:sub(i * 2 + 1, i * 2 + 2), 16), tonumber(b:sub(i * 2 + 1, i * 2 + 2), 16)
    local d = x ~ y
    if d ~= 0 then
      for bit = 0, 7 do
        if (d >> bit) & 1 == 1 then
          local n = i * 8 + bit
          out[#out + 1] = n
          detail[#detail + 1] = string.format("%X:%d>%d", n, (x >> bit) & 1, (y >> bit) & 1)
        end
      end
    end
  end
  return out, detail
end

-- Length of the memory-writing 65816 instructions (fixed length whatever M and X are): the instruction that ENDS at the
-- PC a callback reports is found by trying the starts pc-2, pc-3, pc-4 (and pc-1 never writes memory).
local WLEN = {}
for _, op in ipairs { 0x85, 0x95, 0x81, 0x91, 0x92, 0x87, 0x97, 0x83, 0x93, 0x86, 0x96, 0x84, 0x94, 0x64, 0x74, 0x04, 0x14,
                      0x06, 0x16, 0x46, 0x56, 0x26, 0x36, 0x66, 0x76, 0xE6, 0xF6, 0xC6, 0xD6 } do WLEN[op] = 2 end
for _, op in ipairs { 0x8D, 0x9D, 0x99, 0x8E, 0x8C, 0x9C, 0x9E, 0x0C, 0x1C, 0x0E, 0x1E, 0x4E, 0x5E, 0x2E, 0x3E, 0x6E, 0x7E,
                      0xEE, 0xFE, 0xCE, 0xDE, 0x54, 0x44 } do WLEN[op] = 3 end
for _, op in ipairs { 0x8F, 0x9F } do WLEN[op] = 4 end

-- ROM file offset of a CPU address of the HiROM map (banks $00-$3F and $80-$BF from $8000, banks $C0-$FF), or nil (RAM code).
function gaia.romOffset(k, pc)
  if k >= 0xC0 or ((k & 0x7F) <= 0x3F and pc >= 0x8000) then return ((k & 0x3F) << 16) | pc end
  return nil
end

-- Offset(s) of the instruction that ends at CPU K:PC, as a list (several when the bytes before the PC read as more than one
-- writer of different length; the harness settles it with the `; {n}` tags of extract:lt).
function gaia.insEndingAt(k, pc)
  local endOff = gaia.romOffset(k, pc)
  if not endOff then return nil, {} end
  local c = {}
  for _, len in ipairs { 3, 2, 4 } do
    local s = endOff - len
    if s >= 0 and WLEN[emu.read(s, emu.memType.snesPrgRom)] == len then c[#c + 1] = s end
  end
  return endOff, c
end

-- gaia.flagwatch{ lo=0x0A00, hi=0x0AB3, cap=200, keep=300, filterClear=true, clearEnd=253294, control=true }
-- Write callback over the flag array. A write that changes a bit logs one row (cap rows, then only counted):
--   f=<frame> sc=<sceneCurrent> <K>:<PC> end=<offset after the instruction> ins=<offset(s) of the instruction> $<addr> <old>><new> +<set flags> -<cleared flags>
-- (a 16-bit store gives two rows, one per byte). A write that stores the byte it already holds is counted as `noop`.
-- The zeroing of $0A00/$0A01 by ClearSceneState (the store that ends at `clearEnd`, 253294 on the original ROM:
-- STX $eventFlags at 253291, 3 bytes) is not logged per write: summary().clear has its count, frames and nonzero old values.
-- `control` also counts the NMI's INC $36 writes (summary().control36Writes, the standing positive control).
-- `actor` (FR10): append " D=<cpu D> entry=<bank>:<word at D, D+2> P=<$09A2>,<$09A4>" to every row (D = the actor slot id inside a COP handler, X is the bit index there; the word is the slot's current entry address).
-- `log` (FR10): a function(fmt, ...) that replaces gaia.log for the rows and the summary lines (a long play session uses its own
-- cap per segment).
function gaia.flagwatch(opts)
  opts = opts or {}
  local LOG = opts.log or gaia.log
  local lo, hi = opts.lo or gaia.flags.base, opts.hi or (gaia.flags.base + gaia.flags.bytes - 1)
  local cap, keep = opts.cap or 200, opts.keep or 300
  local filterClear = opts.filterClear ~= false
  local clearEnd = opts.clearEnd or 253294
  local fw = { logged = 0, noop = 0, hits = 0, overflow = 0, ctl = 0, rows = {}, byIns = {},
               clear = { n = 0, frames = {}, nonzeroOld = {} }, refs = {} }

  local ref = emu.addMemoryCallback(function(a, v)
    local off = kit.wramOffset(a) or (a & 0xFFFF)
    if off < lo or off > hi then return end
    fw.hits = fw.hits + 1
    local old = kit.r8(off)
    if old == v then fw.noop = fw.noop + 1; return end
    local k, pc, frame = gaia.pc()
    local endOff, cands = gaia.insEndingAt(k, pc)
    local scene = kit.r16(gaia.addr.sceneCur)
    if filterClear and endOff == clearEnd and (off == 0x0A00 or off == 0x0A01) then
      fw.clear.n = fw.clear.n + 1
      if fw.clear.frames[#fw.clear.frames] ~= frame and #fw.clear.frames < 20 then fw.clear.frames[#fw.clear.frames + 1] = frame end
      if old ~= 0 and #fw.clear.nonzeroOld < 20 then
        fw.clear.nonzeroOld[#fw.clear.nonzeroOld + 1] = string.format("f=%d $%04X %02X", frame, off, old)
      end
      return
    end
    local up, dn = {}, {}
    local base = (off - gaia.flags.base) * 8
    for bit = 0, 7 do
      if ((old ~ v) >> bit) & 1 == 1 then
        if (v >> bit) & 1 == 1 then up[#up + 1] = base + bit else dn[#dn + 1] = base + bit end
      end
    end
    local ins = {}
    for _, s in ipairs(cands) do ins[#ins + 1] = tostring(s) end
    local insText = #ins > 0 and table.concat(ins, "|") or "?"
    local key = string.format("%s end=%s", insText, tostring(endOff))
    local e = fw.byIns[key]
    if not e then e = { n = 0, first = frame }; fw.byIns[key] = e end
    e.n = e.n + 1
    local function fmt(list, sign)
      local t = {}
      for i = 1, math.min(#list, 8) do t[#t + 1] = string.format("%s%X", sign, list[i]) end
      if #list > 8 then t[#t + 1] = sign .. "..(" .. #list .. ")" end
      return table.concat(t, " ")
    end
    if fw.logged < cap then
      fw.logged = fw.logged + 1
      local who = ""
      if opts.actor then
        local d = emu.getState()["cpu.d"] or 0
        who = string.format(" D=%04X entry=%02X:%04X P=%d,%d", d, kit.r8(d + 2), kit.r16(d), kit.r16(0x09A2), kit.r16(0x09A4))
      end
      LOG("f=%d sc=%02X %02X:%04X end=%s ins=%s $%04X %02X>%02X %s %s%s", frame, scene, k, pc, tostring(endOff), insText, off, old, v,
               fmt(up, "+"), fmt(dn, "-"), who)
    else
      fw.overflow = fw.overflow + 1
    end
    if #fw.rows < keep then
      fw.rows[#fw.rows + 1] = { f = frame, sc = scene, k = k, pc = pc, ["end"] = endOff, ins = insText, a = off, old = old, new = v, set = up, clr = dn }
    end
  end, emu.callbackType.write, lo, hi, emu.cpuType.snes, WR)
  fw.refs[#fw.refs + 1] = { ref, emu.callbackType.write, lo, hi }

  if opts.control ~= false then
    local cref = emu.addMemoryCallback(function(a, v)
      if (a & 0xFFFF) == 0x36 then fw.ctl = fw.ctl + 1 end
    end, emu.callbackType.write, 0x36, 0x36, emu.cpuType.snes, WR)
    fw.refs[#fw.refs + 1] = { cref, emu.callbackType.write, 0x36, 0x36 }
  end

  -- Also logs the one summary line of the filtered ClearSceneState zeroing (when there was any) and of the rows past the cap.
  function fw:summary()
    local by = {}
    for key, e in pairs(self.byIns) do by[#by + 1] = { key = key, n = e.n, first = e.first } end
    table.sort(by, function(x, y) return x.key < y.key end)
    if self.clear.n > 0 then
      LOG("ClearSceneState zeroing of $0A00-$0A01 (store ending at %d): %d byte writes at frames %s; nonzero old values: %s",
               clearEnd, self.clear.n, table.concat(self.clear.frames, ","), #self.clear.nonzeroOld > 0 and table.concat(self.clear.nonzeroOld, "; ") or "none")
    end
    if self.overflow > 0 then LOG("flagwatch: %d further changing writes not logged (cap %d)", self.overflow, cap) end
    return { control36Writes = self.ctl, hits = self.hits, noop = self.noop, logged = self.logged, overflow = self.overflow,
             clear = self.clear, byIns = by, rows = self.rows }
  end

  function fw:stop()
    for _, r in ipairs(self.refs) do emu.removeMemoryCallback(r[1], r[2], r[3], r[4], emu.cpuType.snes, WR) end
    self.refs = {}
  end
  return fw
end

-- gaia.execMarks{ name = <ROM file offset of an instruction>, ... [, cap] } counts the executions of each instruction and keeps the
-- emulator frame of the first `cap` (10) of them: h.n[name], h.frames[name] (the frame count of emu.getState()). ROM-specific offsets.
function gaia.execMarks(map, cap)
  local h = { frames = {}, n = {} }
  for name, off in pairs(map) do
    h.frames[name], h.n[name] = {}, 0
    emu.addMemoryCallback(function()
      h.n[name] = h.n[name] + 1
      if #h.frames[name] < (cap or 10) then h.frames[name][#h.frames[name] + 1] = emu.getState().frameCount end
    end, emu.callbackType.exec, off, off, emu.cpuType.snes, emu.memType.snesPrgRom)
  end
  return h
end

-- per-frame trial ------------------------------------------------------------------------------
-- setup runs at the first end of frame (paint tiles, place the player); the buttons are then held for `frames`
-- frames and sample() is stored after each of them. The result {samples, final} is returned by run_script.
function gaia.trial(o)
  local n, samples, started = 0, {}, false
  local handle
  handle = kit.onFrame(function()
    if not started then
      started = true
      if o.setup then o.setup() end
      gaia.hold(o.hold)
      return
    end
    n = n + 1
    samples[#samples + 1] = o.sample and o.sample() or gaia.player()
    if n >= o.frames then
      kit.off(handle)
      gaia.release()
      local res = { samples = samples }
      if o.final then res.final = o.final() end
      kit.finish(res)
    end
  end)
end
