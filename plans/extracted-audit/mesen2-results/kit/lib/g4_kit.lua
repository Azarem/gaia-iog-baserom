-- description: G4 enemy stats rows: static census of the stats rows (spawn records of every scene, rows of the table) and a scene-sweep coverage session that watches every store to statsPtr ($7F0020,X) and to the knockback tier ($7F101C,X) of the 84 actor slots.
-- requires: mesen_kit, iog_kit, gaia_kit, a_census, a_actors, g1_kit, g2_kit
--
--   g4.static{ file = "G4_static_rows.txt" }          -- ROM-only decode (run with frames = 1): rows, per-row spawn-record use; writes the full table to raw/<file>
--   g4.sweep{ scenes = {..}, cap = 120, file = ... }  -- from a loaded state: warp to each scene in turn (g2.warper: write sceneNext, banner pulses, 30 NMI frames settle), count the stores
--   g4.tier{ frames = N, ... }                         -- see g4_runs.lua
--
-- All addresses are decimal ROM file offsets (the "; {n}" tags of extracted/) or WRAM offsets ($7F:xxxx = 0x10000 + xxxx).
-- statsPtr of slot s ($1000 + 0x30 k) is WRAM 0x10020 + s; the knockback tier ("free101C") is WRAM 0x1101C + s.
g4 = g4 or {}

local P   = emu.memType.snesPrgRom
local WR  = emu.memType.snesWorkRam
local CPU = emu.cpuType.snes
local TBL = 109552          -- enemy_stats_table ($01:ABF0), 110 rows x 4
local NROW = 110
local SCENE_PTRS = 819200   -- scene_actors pointer table (256 words); record = 0xC0000 + word

local function rb(o) return emu.read(o, P) end
local function rw(o) return rb(o) | (rb(o + 1) << 8) end
local function pc24()
  local st = emu.getState()
  return ((st["cpu.k"] or 0) << 16) | (st["cpu.pc"] or 0)
end
-- ROM file offset of a CPU address (HiROM banks 00-3F / 80-BF upper half, C0-FF whole bank)
local function romOff(a)
  local k, pc = (a >> 16) & 0xFF, a & 0xFFFF
  if k >= 0xC0 then return ((k - 0xC0) << 16) | pc end
  if (k & 0x7F) <= 0x3F and pc >= 0x8000 then return ((k & 0x3F) << 16) | pc end
  return nil
end
g4.romOff = romOff

local function rowOf(full)
  if full >= 0xABF0 and full <= 0xABF0 + (NROW - 1) * 4 and (full - 0xABF0) % 4 == 0 then return (full - 0xABF0) // 4 end
  return nil
end

local function hex(v, w) return string.format("%0" .. (w or 2) .. "X", v) end

-- chunked file writer (the server caps a script at 100,000 bytes; 3,000 bytes per call is the documented chunk)
local function writeLines(name, lines)
  local buf, first = {}, true
  local function flush()
    if #buf == 0 then return end
    emu.mcp.writeFile(name, table.concat(buf, "\n") .. "\n", not first)
    first = false; buf = {}
  end
  local sz = 0
  for _, l in ipairs(lines) do
    buf[#buf + 1] = l; sz = sz + #l + 1
    if sz >= 2800 then flush(); sz = 0 end
  end
  flush()
end

-- enemy-spawn records of one scene id: { [row] = count }
function g4.sceneRows(s)
  local out = {}
  local p = 0xC0000 + rw(SCENE_PTRS + s * 2)
  local n = 0
  while n < 300 do
    if rb(p) == 0xFF then break end
    local st = rb(p + 6)
    if st ~= 0 then out[st] = (out[st] or 0) + 1; p = p + 9 else p = p + 7 end
    n = n + 1
  end
  return out
end

-- static -------------------------------------------------------------------------------------------
function g4.static(o)
  o = o or {}
  local rows = {}
  for r = 0, NROW - 1 do
    local b = TBL + r * 4
    rows[r] = { hp = rb(b), atk = rb(b + 1), def = rb(b + 2), gem = rb(b + 3), n = 0, scenes = {}, defs = {} }
    rows[r].zero = (rows[r].hp | rows[r].atk | rows[r].def | rows[r].gem) == 0
  end
  local seenPtr, scenesOfPtr = {}, {}
  local badIdx, enemyRecs, actorRecs = {}, 0, 0
  for s = 0, 255 do
    local w = rw(SCENE_PTRS + s * 2)
    if seenPtr[w] then
      scenesOfPtr[w][#scenesOfPtr[w] + 1] = s
    else
      seenPtr[w] = true; scenesOfPtr[w] = { s }
      local p = 0xC0000 + w
      local n = 0
      while n < 300 do
        local x = rb(p)
        if x == 0xFF then break end
        local st = rb(p + 6)
        if st ~= 0 then
          enemyRecs = enemyRecs + 1
          local ptr, bank = rw(p + 3), rb(p + 5)
          local def = ((bank >= 0xC0) and ((bank - 0xC0) << 16) or ((bank & 0x3F) << 16)) | ptr
          if st >= NROW then badIdx[#badIdx + 1] = string.format("scene %02X idx %02X", s, st)
          else
            local R = rows[st]
            R.n = R.n + 1
            R.scenes[s] = (R.scenes[s] or 0) + 1
            R.defs[def] = (R.defs[def] or 0) + 1
          end
          p = p + 9
        else
          actorRecs = actorRecs + 1
          p = p + 7
        end
        n = n + 1
      end
    end
  end
  -- summary
  local used, unused, zeroRows, unusedZero = {}, {}, {}, {}
  local gemUsed, gemAll = { [0] = 0, 0, 0, 0 }, { [0] = 0, 0, 0, 0 }
  local distinctUsed = 0
  for r = 0, NROW - 1 do
    local R = rows[r]
    if R.zero then zeroRows[#zeroRows + 1] = hex(r) end
    if R.n > 0 then used[#used + 1] = hex(r); distinctUsed = distinctUsed + 1 end
    if not R.zero then
      local g = math.min(R.gem, 3)
      gemAll[g] = gemAll[g] + 1
      if R.n > 0 then gemUsed[g] = gemUsed[g] + 1 end
    end
    if R.n == 0 and r >= 1 then (R.zero and unusedZero or unused)[#(R.zero and unusedZero or unused) + 1] = hex(r) end
  end
  local lines = {}
  lines[#lines + 1] = "row hp atk def gem | records scenes(first 8) | actor-def ROM offsets (decimal) x count"
  for r = 0, NROW - 1 do
    local R = rows[r]
    local sc = {}
    for s in pairs(R.scenes) do sc[#sc + 1] = s end
    table.sort(sc)
    local scs = {}
    for i = 1, math.min(#sc, 8) do scs[#scs + 1] = hex(sc[i]) end
    local ds = {}
    for d, c in pairs(R.defs) do ds[#ds + 1] = { d, c } end
    table.sort(ds, function(a, b) return a[1] < b[1] end)
    local dss = {}
    for _, e in ipairs(ds) do dss[#dss + 1] = string.format("%d x%d", e[1], e[2]) end
    lines[#lines + 1] = string.format("%02X %02X %02X %02X %d | %d %d sc [%s] | %s", r, R.hp, R.atk, R.def, R.gem, R.n, #sc, table.concat(scs, " "), table.concat(dss, "; "))
  end
  if o.file then writeLines(o.file, lines) end
  kit.finish({
    enemyRecords = enemyRecs, actorRecords = actorRecs, badIdx = badIdx,
    usedRows = table.concat(used, " "), distinctUsedRows = distinctUsed,
    unusedRowsWithStats = table.concat(unused, " "), nUnusedWithStats = #unused,
    zeroRows = table.concat(zeroRows, " "), unusedZeroRowsFrom1 = table.concat(unusedZero, " "),
    gemTypeAllRowsWithStats = gemAll, gemTypeUsedRows = gemUsed,
    sharedDefaultScenes = (function() local out = {} for w, l in pairs(scenesOfPtr) do if #l > 1 then local t = {} for _, s in ipairs(l) do t[#t + 1] = hex(s) end out[#out + 1] = table.concat(t, ",") end end return out end)(),
  })
end

-- sweep: store watch across scenes -------------------------------------------------------------------
-- o.scenes = list of target scene ids; o.pre(S) optional; the result lists, per stats row, the number of stores, the scenes and the store sites
function g4.sweep(o)
  local S = g2.new{ cap = o.cap or 120 }
  local W = g2.warper()
  local list, idx = o.scenes, 0
  local tgt = nil
  local R = { rows = {}, other = {}, tier = {}, pend = {}, loOnly = 0, tpend = 0, arrivals = {}, fails = {}, resolveExec = 0, writesRow = 0, perScene = {} }

  local function note(key, v)
    local e = R.other[key]
    if not e then e = { n = 0, v1 = v, v2 = v, scene = tgt, hist = {} }; R.other[key] = e end
    e.n = e.n + 1; e.v2 = v
    e.hist[v] = (e.hist[v] or 0) + 1
  end

  local function onFull(slot, full, pc)
    local site = romOff(pc)
    local row = rowOf(full)
    if row then
      R.writesRow = R.writesRow + 1
      local e = R.rows[row]
      if not e then e = { n = 0, scenes = {}, pcs = {}, ns = 0 }; R.rows[row] = e end
      e.n = e.n + 1
      if not e.scenes[tgt] then e.scenes[tgt] = 0; e.ns = e.ns + 1 end
      e.scenes[tgt] = e.scenes[tgt] + 1
      local k = site and tostring(site) or hex(pc, 6)
      e.pcs[k] = (e.pcs[k] or 0) + 1
      if site == 249858 then
        local ps = R.perScene[tgt]; if not ps then ps = {}; R.perScene[tgt] = ps end
        ps[row] = (ps[row] or 0) + 1
      end
    else
      note(string.format("%s:%s", site and tostring(site) or hex(pc, 6), full < 0x100 and "small" or "big"), full)
    end
  end

  for k = 0, 83 do
    local slot = 0x1000 + 0x30 * k
    local a = 0x10020 + slot
    emu.addMemoryCallback(function(addr, v)
      if R.pend[slot] then R.loOnly = R.loOnly + 1 end
      R.pend[slot] = v & 0xFF
    end, emu.callbackType.write, a, a, CPU, WR)
    emu.addMemoryCallback(function(addr, v)
      local lo = R.pend[slot]
      R.pend[slot] = nil
      if lo == nil then R.hiOnly = (R.hiOnly or 0) + 1; return end
      onFull(slot, lo | ((v & 0xFF) << 8), pc24())
    end, emu.callbackType.write, a + 1, a + 1, CPU, WR)
    local t = 0x1101C + slot
    emu.addMemoryCallback(function(addr, v)
      local pc = pc24()
      local site = romOff(pc)
      local key = string.format("%s=%02X", site and tostring(site) or hex(pc, 6), v & 0xFF)
      local e = R.tier[key]
      if not e then e = { n = 0, scene = tgt, slot = slot }; R.tier[key] = e end
      e.n = e.n + 1
    end, emu.callbackType.write, t, t, CPU, WR)
  end
  -- the final resolve in InitActorFromSceneData (STA $statsPtr,X at 249854): exec control for the spawn path
  S:ex(249854, function() R.resolveExec = R.resolveExec + 1 end)

  if o.pre then o.pre(S, R) end
  local base, sceneFrames, needLoad = nil, 0, false
  local function summarize(extra)
        local rowsOut, never = {}, {}
        for r = 0, NROW - 1 do
          local e = R.rows[r]
          if e then
            local sc = {}
            for s in pairs(e.scenes) do sc[#sc + 1] = s end
            table.sort(sc)
            local scs = {}
            for i = 1, math.min(#sc, 6) do scs[#scs + 1] = hex(sc[i]) end
            local ps = {}
            for pcs, c in pairs(e.pcs) do ps[#ps + 1] = pcs .. "x" .. c end
            table.sort(ps)
            rowsOut[#rowsOut + 1] = string.format("%02X n=%d scenes=%d [%s] sites %s", r, e.n, e.ns, table.concat(scs, " "), table.concat(ps, ","))
          else
            never[#never + 1] = hex(r)
          end
        end
        local oth = {}
        for key, e in pairs(R.other) do
          local hs = {}
          for v, c in pairs(e.hist) do hs[#hs + 1] = { v, c } end
          table.sort(hs, function(a, b) return a[1] < b[1] end)
          local hstr = {}
          for i = 1, math.min(#hs, 70) do hstr[#hstr + 1] = string.format("%X:%d", hs[i][1], hs[i][2]) end
          oth[#oth + 1] = string.format("%s n=%d first scene %s values %s%s", key, e.n, e.scene and hex(e.scene) or "?", table.concat(hstr, " "), #hs > 70 and " ..." or "")
        end
        table.sort(oth)
        -- static vs runtime, per scene: records of the scene list against stores of table rows with the spawn-path site (249858 end)
        local mism = {}
        for _, s in ipairs(list) do
         if R.arrSet and R.arrSet[s] then
          local st, rt = g4.sceneRows(s), R.perScene[s] or {}
          local diffs = {}
          for r = 0, NROW - 1 do
            local a, b = st[r] or 0, rt[r] or 0
            if a ~= b then diffs[#diffs + 1] = string.format("%02X:static %d runtime %d", r, a, b) end
          end
          if #diffs > 0 then mism[#mism + 1] = string.format("%02X %s", s, table.concat(diffs, ", ")) end
         end
        end
        local tr = {}
        for key, e in pairs(R.tier) do tr[#tr + 1] = string.format("%s n=%d first scene %s slot %X", key, e.n, e.scene and hex(e.scene) or "?", e.slot) end
        table.sort(tr)
        if o.file then
          local lines = {}
          for _, l in ipairs(rowsOut) do lines[#lines + 1] = "ROW " .. l end
          for _, l in ipairs(oth) do lines[#lines + 1] = "OTHER " .. l end
          for _, l in ipairs(tr) do lines[#lines + 1] = "TIER " .. l end
          for s, ps in pairs(R.perScene) do
            local t2 = {}
            for r, c in pairs(ps) do t2[#t2 + 1] = hex(r) .. "x" .. c end
            table.sort(t2)
            lines[#lines + 1] = string.format("SCENE %02X %s", s, table.concat(t2, " "))
          end
          writeLines(o.file, lines)
        end
        S:finish({ arrived = table.concat(R.arrivals, " "), nArrived = #R.arrivals, fails = table.concat(R.fails, " "), rowTable = rowsOut, never = table.concat(never, " "),
                   other = oth, tier = tr, sceneMismatch = mism, writesRow = R.writesRow, resolveExec = R.resolveExec, loOnly = R.loOnly, hiOnly = R.hiOnly or 0,
                   crashedAt = extra and extra.crashedAt or nil, doneThrough = extra and extra.doneThrough or nil })
  end

  -- every scene starts from the same saved state: the state is saved at the first main-loop pass and reloaded at the top of the main loop
  -- (savestate calls work only inside an exec callback of the main CPU, T-62)
  local ticks, lastHook, lastCtl = 0, 0, -1
  S:ex(32779, function()
    if base == nil then
      base = emu.createSavestate(); idx = 1; tgt = list[idx]; W.go(tgt); sceneFrames = 0
      return
    end
    if needLoad then
      needLoad = false
      emu.loadSavestate(base)
      R.pend = {}
      tgt = list[idx]; W.go(tgt); sceneFrames = 0
    end
  end)
  S:frame(function(t)
    ticks = ticks + 1
    -- a scene that derails the CPU (no NMI stub pass for 60 frame callbacks) cannot be recovered from inside the script: finish with what was seen
    if S.ctl ~= lastCtl then lastCtl = S.ctl; lastHook = ticks end
    if base ~= nil and ticks - lastHook > 1200 then
      R.fails[#R.fails + 1] = string.format("%02X(CRASH)", tgt)
      summarize({ crashedAt = tgt, doneThrough = list[idx - 1] })
      return
    end
    if base == nil or needLoad then return end
    W.step()
    sceneFrames = sceneFrames + 1
    if W.state == "done" or W.state == "fail" or sceneFrames > 800 then
      if W.state == "done" then R.arrivals[#R.arrivals + 1] = string.format("%02X", tgt); R.arrSet = R.arrSet or {}; R.arrSet[tgt] = true
      else R.fails[#R.fails + 1] = string.format("%02X(cur %02X,next %02X)", tgt, kit.r16(0x0644) & 0xFF, kit.r16(0x0642) & 0xFF) end
      idx = idx + 1
      if idx > #list then summarize() else needLoad = true end
    end
  end)
end
