-- description: M3 (world map, routes, exits): in-script savestate batch of world-map trips (menu and scripted), route-step tick census, choice-id writer log, LookupMapName log, WaitByte timing.
-- requires: mesen_kit, iog_kit, gaia_kit
--
-- ROM O offsets (decimal `; {n}` tags of extract:lt):
--   ArrivalAndTravelSetup: WaitByte #0F 238484 (resumes at 238487), LookupMapName call for the start name 238516
--   RouteAnimationEngine: RouteStepLoop 238913, apply of one tick (LDA $18 after SetEntryHere) 238982, DEC $24 239059
--   RouteEndHandler 239102 (return-pointer check), RouteTrulyEnded 239115, WaitByte #3B 239146 (resumes at 239149), RouteEndLanding 239172
--   SkipToSceneTransition 239067, ClearWorldMapState 239233, LookupMapName 239250 (found 239277, miss 239286)
--   world_map_options 242689-244449; the 27 RestoreSavedPtr that follow a DialogueOptions (the "dead" ones, OQ-I060-4) are listed in m3.DEAD
-- WRAM: $0D52 staged X, $0D54 start X, $0D56 start Y, $0D58 choice id, $0D5A route id, $0D5C route return ptr, $0D5E, $0D60-$0D6B party array,
--       $0D6C aux ($0652 later), $0D6E dest scene, $0D6F origin scene; $00CA/$00CC world X/Y, $00BC rotation, $24 tick counter of the step, $2C route read pointer.
--
-- m3.run{ cases={...}, maxN=2600, out="M3_x.txt" }   runs the cases one after the other from the loaded state (createSavestate/loadSavestate in the NMI stub exec, tag 32779).
--   case = { name=, kind="menu"|"route"|"idle", choice=, pos=, rows=, btn="a"|"b", route=, origin=, dest=, scroll=, party={..}, x=, y=, stop="landing"|"A+N" }
m3 = m3 or {}

local WR  = emu.memType.snesWorkRam
local PRG = emu.memType.snesPrgRom
local CPU = emu.cpuType.snes
local r8, r16, w8, w16 = kit.r8, kit.r16, kit.w8, kit.w16

local function hx(v, w) return string.format("%0" .. (w or 4) .. "X", v & 0xFFFFFFFF) end
local function pc24()
  local st = emu.getState()
  return ((st["cpu.k"] or 0) << 16) | (st["cpu.pc"] or 0)
end
local function rom(k, pc) return ((k & 0x3F) << 16) | pc end

m3.OFF = {
  stub = 32779, nmi = 33528,
  waitF = 238484, waitFres = 238487, lookStart = 238516,
  stepLoop = 238913, apply = 238982, skip = 239067, endH = 239102, trulyEnd = 239115, wait3B = 239146, wait3Bres = 239149, landing = 239172,
  clear = 239233, look = 239250, lookFound = 239277, lookMiss = 239286,
  optLo = 242689, optHi = 244449,
}
m3.DEAD = { 242779, 242823, 242866, 242902, 242938, 242980, 243017, 243053, 243089, 243115, 243153, 243196, 243252, 243290, 243361, 243399, 243453, 243491, 243529, 243586, 243631, 243647, 243692, 243748, 243789, 243862, 243936 }

-- exit staging (choice id -> start X, Y, origin scene) from overworld_exit.asm (27 sites) and the origin scene of the exit actor
m3.EXIT = {
  [0x01] = { 0x00D4, 0x03A4, 0x01 }, [0x02] = { 0x00D4, 0x03A4, 0x01 }, [0x1B] = { 0x00D4, 0x03A4, 0x01 },
  [0x03] = { 0x0104, 0x0334, 0x0A },
  [0x04] = { 0x00C4, 0x02B4, 0x15 }, [0x06] = { 0x00C4, 0x02B4, 0x15 },
  [0x05] = { 0x0134, 0x0284, 0x1C },
  [0x09] = { 0x0254, 0x02D4, 0x32 }, [0x07] = { 0x0254, 0x02D4, 0x32 },
  [0x08] = { 0x0334, 0x0334, 0x3E },
  [0x15] = { 0x0384, 0x0164, 0x69 }, [0x0A] = { 0x0384, 0x0164, 0x69 },
  [0x0B] = { 0x02D4, 0x01A4, 0x78 }, [0x0C] = { 0x02D4, 0x01A4, 0x78 }, [0x0E] = { 0x02D4, 0x01A4, 0x78 },
  [0x0D] = { 0x02A4, 0x0124, 0x82 },
  [0x0F] = { 0x01D4, 0x0134, 0x91 }, [0x10] = { 0x01D4, 0x0134, 0x91 }, [0x1A] = { 0x01D4, 0x0134, 0x91 },
  [0x11] = { 0x0214, 0x00B4, 0xA0 },
  [0x12] = { 0x0124, 0x01A4, 0xAC }, [0x13] = { 0x0124, 0x01A4, 0xAC }, [0x19] = { 0x0124, 0x01A4, 0xAC },
  [0x14] = { 0x0134, 0x0154, 0xB0 },
  [0x16] = { 0x0094, 0x0114, 0xC3 }, [0x17] = { 0x0094, 0x0114, 0xC3 },
  [0x18] = { 0x0074, 0x00B4, 0xCC },
}

-- the 13 scripted trips (StageWorldMapMove operands, party array, QueueMapChange destination scene and scroll word, origin scene)
m3.SCRIPT = {
  [0x03] = { x = 0x00D4, y = 0x03A4, dest = 0x15, scroll = 0x4500, origin = 0x06, party = { 0, 1, 2 } },
  [0x02] = { x = 0x0104, y = 0x0334, dest = 0x06, scroll = 0x2110, origin = 0x0A, party = { 0, 1 } },
  [0x05] = { x = 0x00C4, y = 0x02B4, dest = 0x1A, scroll = 0x2200, origin = 0x17, party = { 0, 2 } },
  [0x06] = { x = 0x0094, y = 0x0254, dest = 0x1C, scroll = 0x2200, origin = 0x1A, party = { 0, 2 } },
  [0x09] = { x = 0x0254, y = 0x0354, dest = 0x32, scroll = 0x4500, origin = 0x30, party = { 0, 1 } },
  [0x0C] = { x = 0x0254, y = 0x02D4, dest = 0x49, scroll = 0x1100, origin = 0x39, party = { 0, 1, 2, 3, 4 } },
  [0x0D] = { x = 0x0274, y = 0x0264, dest = 0x4B, scroll = 0x4400, origin = 0x49, party = { 0, 1, 2, 3, 4, 5 } },
  [0x11] = { x = 0x0384, y = 0x0164, dest = 0x78, scroll = 0x4500, origin = 0x6A, party = { 0, 1, 2, 3, 4, 5 } },
  [0x15] = { x = 0x02D4, y = 0x01A4, dest = 0x91, scroll = 0x5400, origin = 0x79, party = { 7, 8, 9, 10 } },
  [0x19] = { x = 0x01D4, y = 0x0134, dest = 0xAC, scroll = 0x2200, origin = 0x96, party = { 0, 1, 4, 6 } },
  [0x1D] = { x = 0x0124, y = 0x01A4, dest = 0xC4, scroll = 0x1100, origin = 0xAE, party = { 0, 1, 4 } },
  [0x21] = { x = 0x0094, y = 0x0114, dest = 0xDC, scroll = 0x1100, origin = 0xC8, party = { 11 } },
  [0x22] = { x = 0x02D4, y = 0x01A4, dest = 0x01, scroll = 0x4300, origin = 0x78, party = { 13 } },
}
-- NOTE: the dest numbers above are the first QueueMapChange operand as printed by extract (hex); the scene ids of the originating NPC scenes are the file prefixes (sc06, it17, ...).

-- menu cases: choice id, position in the visible list (0 = Quit), rows per column, expected route id
m3.MENU = {
  { 0x01, 1, 2, 0x01 }, { 0x02, 1, 2, 0x03 }, { 0x03, 1, 2, 0x02 }, { 0x04, 1, 2, 0x04 }, { 0x05, 1, 2, 0x08 }, { 0x06, 1, 2, 0x07 },
  { 0x07, 1, 2, 0x0A }, { 0x08, 1, 2, 0x0B }, { 0x0A, 1, 2, 0x11 }, { 0x0B, 1, 2, 0x12 }, { 0x0C, 1, 2, 0x13 }, { 0x0C, 2, 2, 0x12 },
  { 0x0D, 1, 2, 0x14 }, { 0x0E, 3, 2, 0x15 }, { 0x0F, 1, 2, 0x16 }, { 0x10, 2, 2, 0x17 }, { 0x11, 1, 2, 0x18 }, { 0x12, 1, 2, 0x1A },
  { 0x13, 2, 2, 0x1B }, { 0x14, 1, 2, 0x1C }, { 0x16, 1, 2, 0x20 }, { 0x17, 2, 2, 0x1E }, { 0x18, 1, 2, 0x1F }, { 0x19, 3, 2, 0x1D },
  { 0x1A, 3, 2, 0x19 },
}

-- ROM tables parsed at load time (never read the ROM inside a callback)
function m3.loadTables()
  local R = {}
  local tbl = 241015
  for id = 0, 0x25 do
    local ptr = emu.read(tbl + id * 2, PRG, false) | (emu.read(tbl + id * 2 + 1, PRG, false) << 8)
    local steps, calls = {}, {}
    local function walk(o0, depth)
      local off = o0
      while #steps < 200 do
        local b0 = emu.read(off, PRG, false)
        if b0 == 0xFF then return end
        if b0 == 0xFE then
          local tgt = emu.read(off + 1, PRG, false) | (emu.read(off + 2, PRG, false) << 8)
          calls[#calls + 1] = tgt
          if depth < 4 then walk(0x030000 + tgt, depth + 1) end
          off = off + 3
        else
          steps[#steps + 1] = { b0, emu.read(off + 1, PRG, false), emu.read(off + 2, PRG, false), emu.read(off + 3, PRG, false), off }
          off = off + 4
        end
      end
    end
    walk(0x030000 + ptr, 0)
    R[id] = { ptr = ptr, off = 0x030000 + ptr, steps = steps, calls = calls }
  end
  m3.routes = R
  -- scene-name table ids (3-byte entries from world_map_scene_names, 242132): read until a zero id
  local names, o = {}, 242132
  while true do
    local id = emu.read(o, PRG, false)
    if id == 0 or #names > 60 then break end
    names[#names + 1] = id
    o = o + 3
  end
  m3.names = names
  m3.nameSet = {}
  for _, id in ipairs(names) do m3.nameSet[id] = true end
end

-- predicted deltas of a route from the move chains (chain tables are word lists in ROM): applies = n+1 per step
-- (the chain contents are resolved offline; here only the per-step n and the chain indices are kept)

local function chunkWrite(name, lines, append)
  local buf, size, first = {}, 0, not append
  local function flush()
    if #buf > 0 then
      emu.mcp.writeFile(name, table.concat(buf, "\n") .. "\n", not first)
      first = false
      buf, size = {}, 0
    end
  end
  for _, l in ipairs(lines) do
    buf[#buf + 1] = l
    size = size + #l + 1
    if size > 2400 then flush() end
  end
  flush()
end
m3.chunkWrite = chunkWrite

local function menuPresses(pos, rows)
  local P = {}
  local col, row = pos // rows, pos % rows
  for _ = 1, col do P[#P + 1] = "right" end
  for _ = 1, row do P[#P + 1] = "down" end
  return P
end

function m3.run(o)
  m3.loadTables()
  local OFF = m3.OFF
  local S = { i = 0, phase = "init", done = false, errs = 0, res = {}, lines = {}, ctl = { nmi = 0, w36 = 0 } }
  local C = nil           -- current case state (nil outside a run phase)
  local saved
  local maxN = o.maxN or 2600
  local out = o.out or "M3_run.txt"
  local deadSet = {}
  for _, d in ipairs(m3.DEAD) do deadSet[d] = true end

  local function L(fmt, ...) S.lines[#S.lines + 1] = select("#", ...) > 0 and string.format(fmt, ...) or fmt end

  -- positive controls over the whole script
  emu.addMemoryCallback(function(a) if (a & 0xFFFF) == 0x36 then S.ctl.w36 = S.ctl.w36 + 1 end end, emu.callbackType.write, 0x36, 0x36, CPU, WR)
  emu.addMemoryCallback(function() S.ctl.nmi = S.ctl.nmi + 1 end, emu.callbackType.exec, OFF.nmi, OFF.nmi, CPU, PRG)

  local function ex(off, fn)
    emu.addMemoryCallback(function()
      if not C then return end
      local ok, err = pcall(fn)
      if not ok then C.errs = C.errs or {}; if #C.errs < 3 then C.errs[#C.errs + 1] = off .. ": " .. tostring(err) end end
    end, emu.callbackType.exec, off, off, CPU, PRG)
  end

  -- route engine
  -- the engine's $24 / $2C are direct-page offsets of the actor (D = actor slot): WRAM address = D + offset
  local function dp(off) return r16(emu.getState()["cpu.d"] + off) end
  ex(OFF.stepLoop, function() C.sm[#C.sm + 1] = { #C.ap + 1, dp(0x2C), C.n } end)
  ex(OFF.apply, function()
    local i = #C.ap + 1
    C.ap[i] = { C.n, dp(0x24), r16(0xCA), r16(0xCC), r16(0xBC), r16(0x36) }
  end)
  ex(OFF.endH, function()
    C.endN = C.endN or C.n
    C.endCA, C.endCC, C.endBC = r16(0xCA), r16(0xCC), r16(0xBC)
    C.endCount = (C.endCount or 0) + 1
  end)
  ex(OFF.trulyEnd, function() C.trulyN = C.n; C.trulyCA, C.trulyCC = r16(0xCA), r16(0xCC) end)
  ex(OFF.skip, function() C.skipN = C.n end)
  ex(OFF.landing, function() C.landN = C.landN or C.n; C.landCA, C.landCC = r16(0xCA), r16(0xCC) end)

  -- progress marks (first n and count)
  local markTable = { tilt = 238500, spawnEngine = 238690, dotEnded = 238790, formation = 238594, entry = 238324, selForm = 238563, engine = 238895, dotLoop = 238743, afterSpawn = 238695, ec = 238678, sbEntry = 41547, sbRet = 41551 }
  for name, off in pairs(m3.extraMarks or {}) do markTable[name] = off end
  for name, off in pairs(markTable) do
    ex(off, function() local m = C.marks[name]; if not m then local st = emu.getState(); m = { C.n, 0, st['cpu.y'], st['cpu.ps'], st['cpu.x'], st['cpu.d'] }; C.marks[name] = m end; m[2] = m[2] + 1 end)
  end

  -- WaitByte timing (CL-01)
  ex(OFF.waitF, function() C.wf0 = { C.n, r16(0x36) } end)
  ex(OFF.waitFres, function() if C.wf0 and not C.wf1 then C.wf1 = { C.n, r16(0x36) } end end)
  ex(OFF.wait3B, function() C.w30 = { C.n, r16(0x36) } end)
  ex(OFF.wait3Bres, function() if C.w30 and not C.w31 then C.w31 = { C.n, r16(0x36) } end end)

  -- LookupMapName: key ($0000) at entry, found/miss
  ex(OFF.look, function()
    local st = emu.getState()
    C.look[#C.look + 1] = { C.n, r8(0), (st["cpu.k"] or 0) }
    C.lookPending = #C.look
  end)
  ex(OFF.lookFound, function()
    local st = emu.getState()
    local e = C.look[C.lookPending or 0]
    if e then e.res = "found"; e.idx = (st["cpu.x"] or 0) // 3 end
  end)
  ex(OFF.lookMiss, function()
    local st = emu.getState()
    local e = C.look[C.lookPending or 0]
    if e then e.res = "MISS"; e.idx = (st["cpu.x"] or 0) // 3 end
  end)

  -- every write to $0D58 (choice id) and the other world-map state words: n, address, value, PC after the store, ROM offset
  emu.addMemoryCallback(function(addr, value)
    if not C then return end
    local a = addr & 0xFFFF
    local st = emu.getState()
    if #C.wr < 70 then
      C.wr[#C.wr + 1] = string.format("n=%d %04X<-%02X pc=%02X:%04X rom=%d", C.n, a, value & 0xFF, st["cpu.k"], st["cpu.pc"], rom(st["cpu.k"], st["cpu.pc"]))
    end
    if a == 0x0D58 or a == 0x0D59 then C.w58[#C.w58 + 1] = string.format("n=%d %04X<-%02X pc=%02X:%04X rom=%d", C.n, a, value & 0xFF, st["cpu.k"], st["cpu.pc"], rom(st["cpu.k"], st["cpu.pc"])) end
    if a == 0x0D5A or a == 0x0D5B then C.w5A[#C.w5A + 1] = string.format("n=%d %04X<-%02X pc=%02X:%04X rom=%d", C.n, a, value & 0xFF, st["cpu.k"], st["cpu.pc"], rom(st["cpu.k"], st["cpu.pc"])) end
    if a >= 0x0D5C and a <= 0x0D5F then C.w5C = C.w5C or {}; C.w5C[#C.w5C + 1] = string.format("n=%d %04X<-%02X pc=%02X:%04X rom=%d", C.n, a, value & 0xFF, st["cpu.k"], st["cpu.pc"], rom(st["cpu.k"], st["cpu.pc"])) end
  end, emu.callbackType.write, 0x0D52, 0x0D6F, CPU, WR)

  -- sceneNext / warp words writes (QueueMapChange, DeferSceneTransition, landing)
  emu.addMemoryCallback(function(addr, value)
    if not C or #C.sw > 30 then return end
    local st = emu.getState()
    C.sw[#C.sw + 1] = string.format("n=%d %04X<-%02X pc=%02X:%04X", C.n, addr & 0xFFFF, value & 0xFF, st["cpu.k"], st["cpu.pc"])
  end, emu.callbackType.write, 0x0642, 0x0643, CPU, WR)

  -- world_map_options code reached (unique ROM offsets of instruction starts)
  emu.addMemoryCallback(function(addr)
    if not C then return end
    C.opt[addr] = (C.opt[addr] or 0) + 1
  end, emu.callbackType.exec, OFF.optLo, OFF.optHi, CPU, PRG)

  -- inputs
  emu.addEventCallback(function()
    if not C or not C.input then return end
    local b = C.input(C.n)
    if b then emu.setInput(b, 0) end
  end, emu.eventType.inputPolled)

  local function newCase(c)
    local st = {
      c = c, n = 0, ap = {}, sm = {}, marks = {}, wr = {}, w58 = {}, w5A = {}, sw = {}, look = {}, opt = {},
      aN = nil,
    }
    -- input generator
    if c.kind == "menu" then
      local P = menuPresses(c.pos or 1, c.rows or 2)
      local t0 = c.t0 or 300
      local gap = c.gap or 10
      local aAt = t0 + gap * #P + gap
      st.aAt = aAt
      st.input = function(n0)
        if not st.arriveN then return nil end
        local n = n0 - st.arriveN
        for i, name in ipairs(P) do
          local t = t0 + gap * (i - 1)
          if n == t or n == t + 1 then return { [name] = true } end
        end
        if n == aAt or n == aAt + 1 then return { [c.btn or "a"] = true } end
      end
    elseif c.input then
      st.input = c.input
    end
    return st
  end

  local function setup(c)
    if c.kind == "menu" then
      -- base state S01r: the stores overworld_exit makes through StageWorldMapChoice (COP #66); the arrival at $FE and the controller run unmodified
      local ex_ = m3.EXIT[c.choice] or { 0x00D4, 0x03A4, 0x01 }
      w16(0x0D52, c.x or ex_[1]); w16(0x0D56, c.y or ex_[2])
      w16(0x0D58, c.choice); w16(0x0D5A, 0); w16(0x0D5E, 0)
      w16(0x0D60, 0)
    elseif c.kind == "route" then
      -- base state S01r (South Cape, no trip yet): the same stores StageWorldMapMove (COP #65) and QueueMapChange make in a NPC script
      local sc = m3.SCRIPT[c.route]
      local sx, sy = (sc and sc.x) or c.x or 0x00D4, (sc and sc.y) or c.y or 0x03A4
      w16(0x0D52, sx); w16(0x0D56, sy); w16(0x0D58, 0); w16(0x0D5E, 0); w16(0x0D5A, c.route)
      w16(0x0642, (sc and sc.dest) or c.dest or 0x15)
      w16(0x0652, (sc and sc.scroll) or c.scroll or 0x4500)
      for i = 0, 5 do w16(0x0D60 + i * 2, (sc and sc.party[i + 1]) or (c.party and c.party[i + 1]) or 0) end
    end
    if c.pokes then for _, p in ipairs(c.pokes) do if p[3] == 8 then w8(p[1], p[2]) else w16(p[1], p[2]) end end end
  end

  local function summarise()
    local c = C.c
    local s = {}
    local ap, sm = C.ap, C.sm
    local steps = {}
    local trace = {}
    for k = 1, #sm do
      local first = sm[k][1]
      local nextFirst = sm[k + 1] and sm[k + 1][1] or (#ap + 1)
      local cnt = nextFirst - first
      if cnt > 0 then
        local a0 = ap[first]
        local a1 = ap[nextFirst]
        local nextN = a1 and a1[1] or C.endN
        local nCA = a1 and a1[3] or C.endCA
        local nCC = a1 and a1[4] or C.endCC
        local nBC = a1 and a1[5] or C.endBC
        steps[#steps + 1] = {
          ptr = sm[k][2], n = a0[2], applies = cnt, f0 = a0[1], frames = nextN and (nextN - a0[1]) or -1,
          dCA = nCA and ((nCA - a0[3]) + 0x10000) % 0x10000 or nil, dCC = nCC and ((nCC - a0[4]) + 0x10000) % 0x10000 or nil, dBC = nBC and ((nBC - a0[5]) + 0x10000) % 0x10000 or nil,
          lastF = ap[nextFirst - 1][1],
        }
      else
        steps[#steps + 1] = { ptr = sm[k][2], call = true }
      end
    end
    return steps
  end

  local function sg(v) if v and v >= 0x8000 then return v - 0x10000 end return v end

  local function record()
    local c = C.c
    local steps = summarise()
    local head = string.format("CASE %s kind=%s", c.name, c.kind)
    if c.kind == "menu" then head = head .. string.format(" choice=%02X pos=%d btn=%s expectRoute=%s", c.choice, c.pos or 0, c.btn or "a", tostring(c.expect and string.format("%02X", c.expect) or "-")) end
    if c.kind == "route" then head = head .. string.format(" route=%02X", c.route) end
    L(head)
    if C.errs then for _, e in ipairs(C.errs) do L("  CALLBACK ERROR %s", e) end end
    if C.arriveN then L("  arrived at scene $FE at n=%d ($0D54/$0D56 start=%04X/%04X $0D6E=%02X)", C.arriveN, r16(0x0D54), r16(0x0D56), r8(0x0D6E)) end
    L("  end n=%d reason=%s route$0D5A_at_end=%02X choice_at_end=%02X scene=%02X sceneNext=%02X $0D6E=%02X $0D6F=%02X $0D6C=%04X", C.n, C.reason or "?", r16(0x0D5A) & 0xFF, r16(0x0D58) & 0xFF, r16(0x0644) & 0xFF, r16(0x0642) & 0xFF, r8(0x0D6E), r8(0x0D6F), r16(0x0D6C))
    do
      local mk = {}
      for k, v in pairs(C.marks) do mk[#mk + 1] = string.format("%s(first n=%d x%d y=%04X ps=%02X x=%04X d=%04X)", k, v[1], v[2], v[3] or 0, v[4] or 0, v[5] or 0, v[6] or 0) end
      table.sort(mk)
      L("  marks: %s; stepLoop execs=%d applies=%d", table.concat(mk, " "), #C.sm, #C.ap)
    end
    if C.routeSeen then L("  route id observed ($0D5A first nonzero) = %02X at n=%d (A pressed at arrival+%s, arrival n=%s)", C.routeSeen, C.routeSeenN, tostring(C.aAt), tostring(C.arriveN)) end
    L("  endHandler n=%s trulyEnd n=%s landing n=%s skip=%s endHandlerExecs=%s", tostring(C.endN), tostring(C.trulyN), tostring(C.landN), tostring(C.skipN), tostring(C.endCount))
    if C.wf0 then L("  WaitByte#0F: call n=%d $36=%d, resume n=%s $36=%s => frames %s (n+1 = 16)", C.wf0[1], C.wf0[2], C.wf1 and tostring(C.wf1[1]) or "-", C.wf1 and tostring(C.wf1[2]) or "-", C.wf1 and tostring(C.wf1[1] - C.wf0[1]) or "-") end
    if C.w30 then L("  WaitByte#3B: call n=%d $36=%d, resume n=%s $36=%s => frames %s (n+1 = 60)", C.w30[1], C.w30[2], C.w31 and tostring(C.w31[1]) or "-", C.w31 and tostring(C.w31[2]) or "-", C.w31 and tostring(C.w31[1] - C.w30[1]) or "-") end
    for _, e in ipairs(C.look) do L("  Lookup n=%d key=%02X -> %s idx=%s (K=%02X)", e[1], e[2], e.res or "?", tostring(e.idx), e[3]) end
    for _, w in ipairs(C.w58) do L("  W58 %s", w) end
    for _, w in ipairs(C.w5A) do L("  W5A %s", w) end
    L("  writes to $0D5C-$0D5F (staging pokes excluded): %d", C.w5C and #C.w5C or 0)
    for _, w in ipairs(C.w5C or {}) do L("  W5C %s", w) end
    for _, w in ipairs(C.sw) do L("  Wscene %s", w) end
    -- dead RestoreSavedPtr executions
    local dead = {}
    for off, cnt in pairs(C.opt) do if deadSet[off] then dead[#dead + 1] = string.format("%d x%d", off, cnt) end end
    table.sort(dead)
    local reached = {}
    for off, cnt in pairs(C.opt) do reached[#reached + 1] = off end
    table.sort(reached)
    L("  options-code PCs reached: %d distinct; dead RestoreSavedPtr executed: %s", #reached, #dead == 0 and "none" or table.concat(dead, ","))
    if #steps > 0 then
      local sumN1, sumN, sumAp, sumFr = 0, 0, 0, 0
      local viol = 0
      local rows = {}
      local R = C.routeSeen and m3.routes[C.routeSeen]
      local k = 0
      for i, s in ipairs(steps) do
        if s.call then
          rows[#rows + 1] = string.format("  step %d CALL ptr=%04X", i, s.ptr)
        else
          k = k + 1
          local rs = R and R.steps[k]
          local rn = rs and rs[4] or -1
          sumN = sumN + rn; sumN1 = sumN1 + rn + 1; sumAp = sumAp + s.applies; sumFr = sumFr + s.frames
          local ok = (s.applies == rn + 1)
          if not ok then viol = viol + 1 end
          rows[#rows + 1] = string.format("  step %d ptr=%04X romN=%d ($24 at first apply=%d) applies=%d frames_to_next=%d firstN=%d lastApplyN=%d dX=%d dY=%d dRot=%d chains=%s %s", i, s.ptr, rn, s.n, s.applies, s.frames, s.f0, s.lastF, sg(s.dCA) or 0, sg(s.dCC) or 0, sg(s.dBC) or 0, rs and string.format("%02X,%02X,%02X", rs[1], rs[2], rs[3]) or "?", ok and "applies=n+1" or "APPLIES!=n+1")
        end
      end
      L("  route steps: %d, sum romN=%d, sum (romN+1)=%d, observed applies=%d, observed frames(first-apply to next first-apply)=%d, steps with applies != romN+1: %d (ROM route has %d flat steps)", #steps, sumN, sumN1, sumAp, sumFr, viol, R and #R.steps or -1)
      for _, r in ipairs(rows) do L(r) end
      if C.ap[1] then L("  first apply n=%d, last apply n=%d, CA/CC at first=%s/%s", C.ap[1][1], C.ap[#C.ap][1], hx(C.ap[1][3]), hx(C.ap[1][4])) end
      if C.endCA then L("  CA/CC at end handler=%s/%s, BC=%s; at landing=%s/%s", hx(C.endCA), hx(C.endCC), hx(C.endBC), C.landCA and hx(C.landCA) or "-", C.landCC and hx(C.landCC) or "-") end
    end
    local summary = {
      name = c.name, n = C.n, reason = C.reason, route = C.routeSeen, steps = #steps, land = C.landN, end_ = C.endN,
      w58 = #C.w58, look = #C.look,
    }
    S.res[#S.res + 1] = summary
    -- flush the per-case lines straight away so a timeout still leaves the data
    chunkWrite(out, S.lines, S.wroteOnce)
    S.wroteOnce = true
    S.lines = {}
  end

  local function over()
    local c = C.c
    -- route id observed
    local rid = r16(0x0D5A)
    if rid ~= 0 and not C.routeSeen then C.routeSeen = rid; C.routeSeenN = C.n end
    if C.n >= (c.maxN or maxN) then C.reason = "maxN"; return true end
    if C.landN and C.n >= C.landN + (c.after or 4) then C.reason = "landing+" .. (c.after or 4); return true end
    if c.stop == "route" and C.routeSeen and C.n >= C.routeSeenN + (c.after or 3) then C.reason = "route staged+" .. (c.after or 3); return true end
    if c.kind == "menu" and C.aAt and C.arriveN and C.n >= C.arriveN + C.aAt + (c.afterA or 80) and not C.routeSeen then C.reason = "no route after A+" .. (c.afterA or 80); return true end
    if c.kind == "idle" and C.n >= (c.frames or 400) then C.reason = "idle frames"; return true end
    return false
  end

  local function machine()
    if S.done then return end
    if S.phase == "init" then
      saved = emu.createSavestate()
      S.phase = "start"
      return
    end
    if S.phase == "start" then
      if S.i >= #o.cases then
        S.done = true
        C = nil
        chunkWrite(out, { string.format("CTL nmi=%d w36=%d errs=%d cases=%d", S.ctl.nmi, S.ctl.w36, S.errs, #o.cases) }, true)
        local sum = {}
        for _, r in ipairs(S.res) do
          sum[#sum + 1] = string.format("%s: n=%d %s route=%s steps=%d land=%s w58=%d look=%d", r.name, r.n, tostring(r.reason), r.route and hx(r.route, 2) or "-", r.steps, tostring(r.land), r.w58, r.look)
        end
        kit.finish({ cases = #o.cases, nmi = S.ctl.nmi, w36 = S.ctl.w36, errs = S.errs, summary = sum })
        return
      end
      S.i = S.i + 1
      C = nil
      emu.loadSavestate(saved)
      local c = o.cases[S.i]
      setup(c)
      C = newCase(c)
      S.phase = "run"
      return
    end
    C.n = C.n + 1
    C.arriveN = C.arriveN
    if not C.arriveN and (r16(0x644) & 0xFF) == 0xFE then
      C.arriveN = C.n
      local sc = C.c.kind == "route" and m3.SCRIPT[C.c.route]
      local ex_ = C.c.kind == "menu" and m3.EXIT[C.c.choice]
      w8(0x0D6F, (sc and sc.origin) or C.c.origin or (ex_ and ex_[3]) or 0x01)
    end
    if C.c.probe and C.c.probeAt and C.n == C.c.probeAt then
      local ok, txt = pcall(C.c.probe, C)
      L("  PROBE n=%d %s", C.n, ok and tostring(txt) or ("error " .. tostring(txt)))
    end
    if over() then
      local snap = C
      record()
      S.phase = "start"
    end
  end

  -- watchdog: after a scene change the loader can spin on the APUIO0 handshake with NMIs off (see tool-issues); end the run with what was recorded
  local lastN, same = -1, 0
  emu.addEventCallback(function()
    if S.done or S.phase ~= "run" or not C or not C.arriveN then lastN, same = -1, 0; return end
    if C.n == lastN then same = same + 1 else same = 0; lastN = C.n end
    if same >= 240 then
      C.reason = "STALL: no NMI for 240 frames after n=" .. C.n
      local ok, err = pcall(record)
      S.done = true
      chunkWrite(out, { string.format("CTL nmi=%d w36=%d errs=%d stalled_case=%d of %d", S.ctl.nmi, S.ctl.w36, S.errs, S.i, #o.cases) }, true)
      kit.finish({ stalled = S.i, cases = #o.cases, nmi = S.ctl.nmi, errs = S.errs })
    end
  end, emu.eventType.endFrame)

  emu.addMemoryCallback(function()
    local ok, err = pcall(machine)
    if not ok then
      S.errs = S.errs + 1
      if S.errs <= 3 then chunkWrite(out, { "LUA ERROR " .. tostring(err) }, true) end
      S.phase = "start"
    end
  end, emu.callbackType.exec, OFF.stub, OFF.stub, CPU, PRG)
  return S
end
