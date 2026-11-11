-- description: W1 address census with per-scene tally, last-writer pairing and exec marks (step W1-a, Engine DP scratch).
-- requires: mesen_kit, iog_kit, gaia_kit
--
-- Use:  includes = {"gaia_kit", "w1a_kit"}
--   local h = w1a.start{
--     watch = { {name="AA", lo=0xAA, hi=0xAA}, {name="AB b2b3", lo=0xAB, hi=0xAB, kinds={"write"}, bits=0x0C}, ... },
--     exec  = { NAME = <ROM file offset of an instruction> , ... },     -- exec marks (snesPrgRom: alias-proof offsets)
--     control = true, nmi = 33528,                                       -- positive controls ($36 writes, NMI exec offset of THIS ROM)
--     logCap = 120, publishEvery = 600 }                                 -- logged first-seen keys; emu.mcp.result refresh
--   h.rows()  -> table for kit.finish (rows, pairs, execs, control, scenes)
--
-- Every hit is keyed "<watch name> <read|write> <K:PC>" (PC = the address AFTER the accessing instruction; the harness maps it to the
-- instruction that ENDS there). Per key: count, first/last frame, first scene, per-scene counts, per-address counts, and for writes the
-- distinct values (max 8). Reads are also paired with the K:PC of the last write seen on the same byte ("init" = no write seen yet):
-- the key "<name> read <K:PC> <- <K:PC of last writer>" answers "who consumes a leftover value".
-- A `bits` entry (write only) records a write only when it changes a bit of the mask (old ~ new), the bit-change variant of plan 6.1.
w1a = w1a or {}

local WR = emu.memType.snesWorkRam

-- Register-value exec marks: w1a.gate(name, off, mask) counts executions of the ROM instruction at `off` and how often (A & mask) ~= 0 there
-- (the callback runs before the instruction, so A is the value the instruction sees). Used for the BIT #$0800 / BIT #$0400 gates.
w1a.gates = {}
function w1a.gate(name, off, mask)
  local g = { name = name, off = off, mask = mask, n = 0, set = 0 }
  w1a.gates[#w1a.gates + 1] = g
  emu.addMemoryCallback(function()
    g.n = g.n + 1
    if (emu.getState()["cpu.a"] & mask) ~= 0 then g.set = g.set + 1 end
  end, emu.callbackType.exec, off, off, emu.cpuType.snes, emu.memType.snesPrgRom)
end
function w1a.gateRows()
  local o = {}
  for _, g in ipairs(w1a.gates) do o[#o + 1] = { name = g.name, off = g.off, mask = g.mask, n = g.n, set = g.set } end
  return o
end


-- Tick probe (OQ-I029-3 / OQ-I045-1): do the ticks in which a TSB $AB bit-2/bit-3 setter ran also reach the $0800 / $0400 gates with the bit set?
-- Per PlayerMovementTick: `pend` is armed by the four bit-2/bit-3 setters (ROM offsets 186339, 186399, 187513, 187599). At 184346 (after $24 is
-- un-parked: A = $24) the probe records the sign of $24 (0 = both gates skipped, negative = north gate, positive = south gate) and the $AA word
-- bits $0C00; at the gate BITs (184352 / 184364) it records whether A & mask is set; the next tick start clears `pend`.
w1a.probe = { ticks = 0, armed = 0, v0 = 0, north = 0, south = 0, northSet = 0, southSet = 0, aaBits = {} }
function w1a.tickProbe()
  local P = w1a.probe
  local pend = false
  local function exec(off, fn) emu.addMemoryCallback(fn, emu.callbackType.exec, off, off, emu.cpuType.snes, emu.memType.snesPrgRom) end
  exec(184272, function() P.ticks = P.ticks + 1; pend = false end)
  for _, off in ipairs({ 186339, 186399, 187513, 187599 }) do
    exec(off, function() if not pend then P.armed = P.armed + 1 end; pend = true end)
  end
  exec(184346, function()
    if not pend then return end
    local a = emu.getState()["cpu.a"]
    if a == 0 then P.v0 = P.v0 + 1 elseif a >= 0x8000 then P.north = P.north + 1 else P.south = P.south + 1 end
    local bits = kit.r16(0x00AA) & 0x0C00
    P.aaBits[bits] = (P.aaBits[bits] or 0) + 1
  end)
  exec(184352, function() if pend and (emu.getState()["cpu.a"] & 0x0800) ~= 0 then P.northSet = P.northSet + 1 end end)
  exec(184364, function() if pend and (emu.getState()["cpu.a"] & 0x0400) ~= 0 then P.southSet = P.southSet + 1 end end)
end
function w1a.probeRows()
  local P = w1a.probe
  local ab = {}
  for k, v in pairs(P.aaBits) do ab[#ab + 1] = { k, v } end
  table.sort(ab, function(x, y) return x[1] < y[1] end)
  return { ticks = P.ticks, armed = P.armed, v0 = P.v0, north = P.north, south = P.south, northSet = P.northSet, southSet = P.southSet, aaBits = ab }
end

function w1a.start(opts)
  local self = { keys = {}, pairsT = {}, lw = {}, ctl36 = 0, nmi = 0, frames = 0, scenes = {}, sceneSeq = {}, execs = {}, logN = 0, hits = 0 }
  local LOGCAP = opts.logCap or 120
  local lastScene = nil

  local function hit(w, kind, a, v)
    local off = kit.wramOffset(a) or (a & 0xFFFF)
    if w.bits and kind == "write" then
      local old = kit.r8(off)
      if ((old ~ v) & w.bits) == 0 then return end
    end
    local st = emu.getState()
    local k, pc, f = st["cpu.k"], st["cpu.pc"], st["frameCount"]
    local sc = kit.r16(0x0644)
    local pck = string.format("%02X:%04X", k, pc)
    local key = w.name .. " " .. kind .. " " .. pck
    local e = self.keys[key]
    if not e then
      e = { name = w.name, kind = kind, pc = pck, n = 0, first = f, scene0 = sc, scenes = {}, addrs = {}, vals = {}, nv = 0 }
      self.keys[key] = e
      if self.logN < LOGCAP then
        self.logN = self.logN + 1
        gaia.log("%s f=%d sc=%02X a=%04X v=%02X D=%04X", key, f, sc, off, v, st["cpu.d"] or 0)
      end
    end
    self.hits = self.hits + 1
    e.n, e.last = e.n + 1, f
    e.scenes[sc] = (e.scenes[sc] or 0) + 1
    e.addrs[off] = (e.addrs[off] or 0) + 1
    if kind == "write" then
      if e.vals[v] or e.nv < 8 then
        if not e.vals[v] then e.nv = e.nv + 1 end
        e.vals[v] = (e.vals[v] or 0) + 1
      end
      self.lw[off] = pck
    else
      local pk = key .. " <- " .. (self.lw[off] or "init")
      local p = self.pairsT[pk]
      if not p then p = { key = pk, n = 0, first = f, scene0 = sc, addrs = {} }; self.pairsT[pk] = p end
      p.n, p.last = p.n + 1, f
      p.addrs[off] = (p.addrs[off] or 0) + 1
    end
  end

  for _, w in ipairs(opts.watch or {}) do
    for _, kind in ipairs(w.kinds or { "read", "write" }) do
      emu.addMemoryCallback(function(a, v) hit(w, kind, a, v) end, emu.callbackType[kind], w.lo, w.hi, emu.cpuType.snes, WR)
    end
  end

  for name, off in pairs(opts.exec or {}) do
    local e = { n = 0, off = off }
    self.execs[name] = e
    emu.addMemoryCallback(function()
      e.n = e.n + 1
      if e.n == 1 then e.first, e.scene0 = emu.getState()["frameCount"], kit.r16(0x0644) end
      local sc = kit.r16(0x0644)
      e.scenes = e.scenes or {}
      e.scenes[sc] = (e.scenes[sc] or 0) + 1
    end, emu.callbackType.exec, off, off, emu.cpuType.snes, emu.memType.snesPrgRom)
  end

  if opts.control ~= false then
    emu.addMemoryCallback(function(a) if (a & 0xFFFF) == 0x36 then self.ctl36 = self.ctl36 + 1 end end,
      emu.callbackType.write, 0x36, 0x36, emu.cpuType.snes, WR)
  end
  if opts.nmi then
    emu.addMemoryCallback(function() self.nmi = self.nmi + 1 end, emu.callbackType.exec, opts.nmi, opts.nmi, emu.cpuType.snes, emu.memType.snesPrgRom)
  end

  local function pl(map)   -- {{key, count}, ...} sorted by key (a JSON array: integer-keyed maps do not serialise)
    local list = {}
    for k, c in pairs(map or {}) do list[#list + 1] = { k, c } end
    table.sort(list, function(x, y) return x[1] < y[1] end)
    return list
  end

  -- structured result for the harness (merged across segments): rows, pairs, execs, controls
  function self.rows()
    local rows, prs, ex = {}, {}, {}
    for key, e in pairs(self.keys) do
      rows[#rows + 1] = { key = key, name = e.name, kind = e.kind, pc = e.pc, n = e.n, first = e.first, last = e.last or e.first, sc0 = e.scene0,
                          scenes = pl(e.scenes), addrs = pl(e.addrs), vals = pl(e.vals) }
    end
    table.sort(rows, function(x, y) return x.key < y.key end)
    for _, p in pairs(self.pairsT) do
      prs[#prs + 1] = { key = p.key, n = p.n, first = p.first, last = p.last or p.first, sc0 = p.scene0, addrs = pl(p.addrs) }
    end
    table.sort(prs, function(x, y) return x.key < y.key end)
    for name, e in pairs(self.execs) do
      ex[#ex + 1] = { name = name, off = e.off, n = e.n, first = e.first, sc0 = e.scene0, scenes = pl(e.scenes) }
    end
    table.sort(ex, function(x, y) return x.name < y.name end)
    return { rows = rows, pairs = prs, execs = ex, control36Writes = self.ctl36, nmiExecs = self.nmi, frames = self.frames, hits = self.hits,
             sceneFrames = pl(self.scenes), sceneSeq = self.sceneSeq, gates = w1a.gateRows(), probe = w1a.probeRows() }
  end

  -- per-frame: scene tracking + periodic publication (emu.mcp.result keeps the last value; get_script_result reads it)
  kit.onFrame(function()
    self.frames = self.frames + 1
    local sc = kit.r16(0x0644)
    self.scenes[sc] = (self.scenes[sc] or 0) + 1
    if sc ~= lastScene then
      lastScene = sc
      if #self.sceneSeq < 80 then self.sceneSeq[#self.sceneSeq + 1] = string.format("f%d:%02X", emu.getState()["frameCount"], sc) end
    end
    if opts.publishEvery and self.frames % opts.publishEvery == 0 then emu.mcp.result(self.rows()) end
  end)

  return self
end

-- Batch W1-a (Engine DP scratch), ROM O. Watch list of the plan (section 7, W1-a) plus the bit-change variants of $AA/$AB.
--   $00AA/$00AB    the player-movement per-tick flag word (D = 0 inside PlayerMovementTick)
--   $005E-$0062    global scratch; the long pointer at $62 spans $62-$64, so $63-$64 are watched too
--   $00DC          dialog scratch word (STZ $00DC is a 16-bit store: $DC-$DD)
--   $0720-$0760    parallax band accumulators (word at $0760 -> $0761)
-- Exec marks are ROM O file offsets (the `; {n}` tags of extract:lt): the instructions that the static prelude lists as writers.
w1a.batchA = {
  watch = {
    { name = "AA", lo = 0xAA, hi = 0xAA },
    { name = "AB", lo = 0xAB, hi = 0xAB },
    { name = "AA bit6(0x40)", lo = 0xAA, hi = 0xAA, kinds = { "write" }, bits = 0x40 },
    { name = "AB bit1(0x02)", lo = 0xAB, hi = 0xAB, kinds = { "write" }, bits = 0x02 },
    { name = "AB bit2,3(0x0C)", lo = 0xAB, hi = 0xAB, kinds = { "write" }, bits = 0x0C },
    { name = "AB bit7(0x80)", lo = 0xAB, hi = 0xAB, kinds = { "write" }, bits = 0x80 },
    { name = "5E-5F", lo = 0x5E, hi = 0x5F },
    { name = "60-61", lo = 0x60, hi = 0x61 },
    { name = "62-64", lo = 0x62, hi = 0x64 },
    { name = "DC-DD", lo = 0xDC, hi = 0xDD },
    { name = "0720-0761", lo = 0x0720, hi = 0x0761 },
  },
  exec = {
    PlayerMovementTick = 184272,
    TSB_AB_bit1_West_187268 = 187268, TSB_AB_bit7_West_187469 = 187469, TSB_AB_bit2_West_187513 = 187513,
    TSB_AB_bit7_West_187553 = 187553, TSB_AB_bit3_West_187599 = 187599,
    TSB_AB_bit7_East_186269 = 186269, TSB_AB_bit2_East_186339 = 186339, TSB_AB_bit7_East_186353 = 186353, TSB_AB_bit3_East_186399 = 186399,
    TRB_AA_0840_West_188563 = 188563, TRB_AA_0440_West_188646 = 188646,
    GateNorth_BIT0800_184352 = 184352, GateSouth_BIT0400_184364 = 184364,
    DispatchNorthMoveCall_184357 = 184357, DispatchSouthMoveCall_184369 = 184369, PlayerMovementTickExit_184372 = 184372,
    SouthWallNudge_LDA_AB_184782 = 184782,
    STZ_00DC_DialogStringRenderer_255073 = 255073,
    ParallaxThinkerEntry_47245 = 47245, ParallaxBuildHdmaTable_47316 = 47316, ParallaxComputeBandValue_47971 = 47971,
    InitSineHdma_39817 = 39817, BuildSineHdmaTable_44495 = 44495, InterleaveTilesPriority_165363 = 165363,
    SpaceBgScroll_846687 = 846687, CreditsF7_650096 = 650096, CreditsHdmaFlicker_652094 = 652094, LaraiCliffWave_48555 = 48555,
  },
  nmi = 33528,
}

-- batch + per-run overrides: w1a.startA{ publishEvery = 600, logCap = 120, extraWatch = {...}, extraExec = {...} }
function w1a.startA(o)
  o = o or {}
  local cfg = { watch = {}, exec = {}, nmi = w1a.batchA.nmi, control = true, logCap = o.logCap, publishEvery = o.publishEvery }
  for _, w in ipairs(w1a.batchA.watch) do
    local kinds = o.kinds and o.kinds[w.name]   -- optional per-watch kind override, e.g. kinds = { ["62-64"] = { "write" } } (a hot read watch costs frames per second)
    if kinds then
      local c = {}
      for k, v in pairs(w) do c[k] = v end
      c.kinds = kinds
      w = c
    end
    cfg.watch[#cfg.watch + 1] = w
  end
  for _, w in ipairs(o.extraWatch or {}) do cfg.watch[#cfg.watch + 1] = w end
  for k, v in pairs(w1a.batchA.exec) do cfg.exec[k] = v end
  for k, v in pairs(o.extraExec or {}) do cfg.exec[k] = v end
  w1a.gates = {}
  w1a.gate("GateNorth A&0800", 184352, 0x0800)
  w1a.gate("GateSouth A&0400", 184364, 0x0400)
  w1a.probe = { ticks = 0, armed = 0, v0 = 0, north = 0, south = 0, northSet = 0, southSet = 0, aaBits = {} }
  w1a.tickProbe()
  return w1a.start(cfg)
end

-- Accumulator snapshots (OQ-I035-3): words $0750-$0760 (the part of the band accumulators that ParallaxClearBandAccumulators does not clear).
-- w1a.snap(tag) appends "<tag> f=<frame> sc=<scene> 0750=.... 0752=...." (non-zero words only, or "all zero") to w1a.snaps (max 60 rows).
-- w1a.snapOnExec(tag, offset) takes one at every execution of the ROM instruction at `offset` (snesPrgRom file offset).
w1a.snaps = {}
function w1a.snap(tag)
  if #w1a.snaps >= 60 then return end
  local t = {}
  for a = 0x0750, 0x0760, 2 do
    local v = kit.r16(a)
    if v ~= 0 then t[#t + 1] = string.format("%04X=%04X", a, v) end
  end
  w1a.snaps[#w1a.snaps + 1] = string.format("%s f=%d sc=%02X %s", tag, emu.getState()["frameCount"], kit.r16(0x0644), #t > 0 and table.concat(t, " ") or "all zero")
end

function w1a.snapOnExec(tag, off)
  emu.addMemoryCallback(function() w1a.snap(tag) end, emu.callbackType.exec, off, off, emu.cpuType.snes, emu.memType.snesPrgRom)
end
