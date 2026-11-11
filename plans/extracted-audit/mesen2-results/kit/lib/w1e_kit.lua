-- description: W1 address census, batch e (unknown readers): $0B14, $0648, $090E/$0910, $09BA-$09C5, $0200-$02FF (decompressor dictionary vs depth-sort buckets), with exec marks and an ordering probe.
-- requires: mesen_kit, iog_kit, gaia_kit, w1d_kit
--
-- Use:  includes = {"gaia_kit", "a_census", "a_actors", "w1d_kit", "w1e_kit"}
--         local h = w1e.startE{logCap=60}
--         acen.run{..., final=function() return h.rowsE() end}
--
-- The census itself is w1d.start (kit/lib/w1d_kit.lua): every hit is keyed "<watch> <read|write> <K:PC>" (PC = the address AFTER the accessing
-- instruction), with count, scenes, addresses, values, and for reads the K:PC of the last write seen on the same byte ("init" = none seen in this run).
-- This module adds the watch list and exec marks of batch e and the ORDERING probe for the decompressor / depth-sort question:
--   at the entry of each `JSL QuintetLzDecompress` call site the caller is "pending"; ClearActorRenderList clears the pending callers (outcome "cleared first");
--   SortActorsByDepth marks the pending callers "sort first" (a sort ran before any clear; the sample keeps the frame, the scene and the frames since the
--   call) and the caller stays pending until the clear arrives (frames to the late clear are recorded).
--   At the entry of SortActors_BuildFinalList (the bucket array must be all zero there) the 256 words $0200-$03FE are scanned: a nonzero word is garbage that
--   phase 1 would chain.
w1e = w1e or {}

local function exec(off, fn)
  emu.addMemoryCallback(fn, emu.callbackType.exec, off, off, emu.cpuType.snes, emu.memType.snesPrgRom)
end

-- ROM offsets (decimal; ROM O; the `; {n}` tags of extract:lt output)
w1e.OFF = {
  QuintetLzDecompress = 164464,
  ClearActorRenderList = 252010,
  SortActorsByDepth = 247295,
  BuildFinalList = 247451,
  ReadMenuSelection = 256554,
}
-- the JSL QuintetLzDecompress call sites: the Decompress COP (cop_handlers_vram) and the 8 scene_script sites
w1e.CALLERS = {
  ["COP#51 Decompress"] = 39344,
  ["scene_script 165180"] = 165180, ["scene_script 165284"] = 165284, ["scene_script 165359"] = 165359, ["scene_script 165756"] = 165756,
  ["scene_script 166062"] = 166062, ["scene_script 166218"] = 166218, ["scene_script 166933"] = 166933, ["scene_script 167026"] = 167026,
}

w1e.batchE = {
  watch = {
    { name = "0B14-0B15", lo = 0x0B14, hi = 0x0B15, ctx = true },
    { name = "0648-0649", lo = 0x0648, hi = 0x0649, ctx = true },
    { name = "090E-0911", lo = 0x090E, hi = 0x0911, ctx = true },
    { name = "09BA-09BD", lo = 0x09BA, hi = 0x09BD, ctx = true },
    { name = "09BE-09C5", lo = 0x09BE, hi = 0x09C5, ctx = true },
    { name = "0200-02FF", lo = 0x0200, hi = 0x02FF },
  },
  exec = {
    QuintetLzDecompress = 164464, ClearActorRenderList = 252010, SortActorsByDepth = 247295, BuildFinalList = 247451,
    ReadMenuSelection = 256554, ReadMenuSelection_STA_090E = 256574,
    ExecuteSceneTransition_clear_gfxCacheIdxA = 252551, ScreenExitTransition = 252603, ScreenEnterTransition = 253074,
    InitSystemVariables_wramInit_store = 171642,
    DecomposeActorMetasprites = 247881, DecomposePlayerSprites = 248104,
    ReadDecelerationStep = 177921, ReadDecelerationStepNS = 178080,
    ApplySlopeCurveNegEW_ADC = 177572, ApplySlopeCurvePosEW_ADC = 177604, ApplySlopeCurvePosNS_ADC = 177642, ApplySlopeCurveNegNS_ADC = 177670,
  },
  nmi = 33528,
}

-- ordering probe state
w1e.O = nil
function w1e.order()
  local O = { callers = {}, pending = {}, sorts = 0, clears = 0, builds = 0, dirtyBuilds = 0, dirtySamples = {}, nzHist = {}, decCalls = 0, overlap = 0 }
  w1e.O = O
  local function frame() return emu.getState()["frameCount"] end
  for name, off in pairs(w1e.CALLERS) do
    local c = { name = name, off = off, n = 0, clearedFirst = 0, sortFirst = 0, samples = {}, lateClear = {}, scenes = {} }
    O.callers[name] = c
    exec(off, function()
      c.n = c.n + 1
      O.decCalls = O.decCalls + 1
      local sc = kit.r16(0x0644)
      c.scenes[sc] = (c.scenes[sc] or 0) + 1
      if O.pending[name] then O.overlap = O.overlap + 1; c.superseded = (c.superseded or 0) + 1 end   -- the same site called again before any clear or sort
      O.pending[name] = { f0 = frame(), sc = sc, sortSeen = false }
    end)
  end
  exec(w1e.OFF.ClearActorRenderList, function()
    O.clears = O.clears + 1
    local f = frame()
    for name, p in pairs(O.pending) do
      local c = O.callers[name]
      if p.sortSeen then
        if #c.lateClear < 12 then c.lateClear[#c.lateClear + 1] = string.format("f%d sc=%02X +%d frames", p.f0, p.sc, f - p.f0) end
      else
        c.clearedFirst = c.clearedFirst + 1
      end
      O.pending[name] = nil
    end
  end)
  exec(w1e.OFF.SortActorsByDepth, function()
    O.sorts = O.sorts + 1
    local f = frame()
    for name, p in pairs(O.pending) do
      if not p.sortSeen then
        p.sortSeen = true
        local c = O.callers[name]
        c.sortFirst = c.sortFirst + 1
        if #c.samples < 12 then c.samples[#c.samples + 1] = string.format("call f%d sc=%02X, first sort at f%d (+%d)", p.f0, p.sc, f, f - p.f0) end
      end
    end
  end)
  exec(w1e.OFF.BuildFinalList, function()
    O.builds = O.builds + 1
    local nz, nz0 = 0, 0
    for a = 0x0200, 0x03FE, 2 do
      if kit.r16(a) ~= 0 then
        nz = nz + 1
        if a < 0x0300 then nz0 = nz0 + 1 end
      end
    end
    local b = (nz == 0) and "0" or ((nz <= 8) and "1-8" or ((nz <= 64) and "9-64" or "65-256"))
    O.nzHist[b] = (O.nzHist[b] or 0) + 1
    if nz > 0 then
      O.dirtyBuilds = O.dirtyBuilds + 1
      if #O.dirtySamples < 12 then
        local pend = {}
        for name, _ in pairs(O.pending) do pend[#pend + 1] = name end
        table.sort(pend)
        O.dirtySamples[#O.dirtySamples + 1] = string.format("f%d sc=%02X nzWords=%d (in $0200-$02FF %d) pending=[%s]", frame(), kit.r16(0x0644), nz, nz0, table.concat(pend, ","))
      end
    end
  end)
end

function w1e.orderRows()
  local O = w1e.O
  if not O then return nil end
  local cs = {}
  for name, c in pairs(O.callers) do
    local sc = {}
    for k, v in pairs(c.scenes) do sc[#sc + 1] = { k, v } end
    table.sort(sc, function(x, y) return x[1] < y[1] end)
    cs[#cs + 1] = { name = name, off = c.off, n = c.n, clearedFirst = c.clearedFirst, sortFirst = c.sortFirst, superseded = c.superseded or 0, samples = c.samples, lateClear = c.lateClear, scenes = sc }
  end
  table.sort(cs, function(x, y) return x.off < y.off end)
  local hist = {}
  for k, v in pairs(O.nzHist) do hist[#hist + 1] = { k, v } end
  table.sort(hist, function(x, y) return x[1] < y[1] end)
  local pend = {}
  for name, p in pairs(O.pending) do pend[#pend + 1] = string.format("%s call f%d sc=%02X sortSeen=%s", name, p.f0, p.sc, tostring(p.sortSeen)) end
  table.sort(pend)
  return { callers = cs, sorts = O.sorts, clears = O.clears, builds = O.builds, dirtyBuilds = O.dirtyBuilds, dirtySamples = O.dirtySamples, nzHist = hist,
           decCalls = O.decCalls, overlap = O.overlap, pendingAtEnd = pend }
end

-- w1e.startE{ publishEvery = 600, logCap = 60, win0200 = true (watch only $0200-$021F instead of the whole page), extra = { {name=,lo=,hi=,ctx=} ... } (additional watches), kinds = { ["name"] = {"read"} } }
function w1e.startE(o)
  o = o or {}
  local cfg = { watch = {}, exec = {}, probes = {}, nmi = w1e.batchE.nmi, control = true, logCap = o.logCap, publishEvery = o.publishEvery }
  for _, w in ipairs(w1e.batchE.watch) do
    local kinds = o.kinds and o.kinds[w.name]
    if o.win0200 and w.name == "0200-02FF" then   -- narrow window ($0200-$021F): the full page costs ~250 callbacks per depth sort
      local c = {}
      for k, v in pairs(w) do c[k] = v end
      c.name = "0200-021F"; c.hi = 0x021F
      w = c
    end
    if kinds then
      local c = {}
      for k, v in pairs(w) do c[k] = v end
      c.kinds = kinds
      w = c
    end
    cfg.watch[#cfg.watch + 1] = w
  end
  for _, w in ipairs(o.extra or {}) do cfg.watch[#cfg.watch + 1] = w end   -- extra watches (the displayModeFlags run)
  for k, v in pairs(w1e.batchE.exec) do cfg.exec[k] = v end
  for k, v in pairs(o.extraExec or {}) do cfg.exec[k] = v end
  local h = w1d.start(cfg)
  w1e.order()
  function h.rowsE()
    local r = h.rows()
    r.order = w1e.orderRows()
    return r
  end
  return h
end
