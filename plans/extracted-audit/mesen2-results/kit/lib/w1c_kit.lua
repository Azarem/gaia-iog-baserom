-- description: W1 address census (batch c: event/flag bytes) with per-scene tally, read values, last-writer pairing, exec marks, value probes, snapshots and caller attribution for the flag helpers.
-- requires: mesen_kit, iog_kit, gaia_kit
--
-- Use:  includes = {"gaia_kit", "a_census", "w1c_kit"}   then   local h = w1c.startC{logCap=60}   and   acen.run{..., final=function() return h.rows() end}
--
-- Every hit is keyed "<watch name> <read|write> <K:PC>" (PC = the address AFTER the accessing instruction; the harness maps it to the
-- instruction that ENDS there). Per key: count, first/last frame, first scene, per-scene counts, per-address counts, the distinct values
-- (max 8; the byte written, or for a read the byte read). `bits` (write only) records a write only when it changes a bit of the mask
-- (old ~ new): the bit-change variant of plan 6.1.
--
-- Caller attribution (the flag helpers are shared by every COP flag handler and every JSL wrapper, so the K:PC alone cannot tell the
-- caller): a hit whose instruction lies in a helper range (`helpers`, ROM offsets) records in the row's `ctx` list one descriptor
--   i=<WRAM $0000 word: the flag index the helper stored>  s=<stack words at SP+3, SP+5, byte SP+7>  [cop=<bank>:<$0A word of the actor in D>]
-- The helper cores start with PHX (2 bytes), so SP+3 holds the return address of the JSR from the COP handler or the JSL wrapper, SP+5..7 the
-- JSL return (wrapper) address. `cop=` is present when D lies in the actor/thinker slot range: [D+$0A] is the operand pointer of the running COP
-- (the COP opcode is $0A - 3 for the byte forms, $0A - 4 for the word forms, $0A - 2 without operand), [D+$0C] its bank. The harness decodes it.
-- Other `ctx` entries: "x:<offset hex> <old>><new>" = the byte transitions of a `chg` watch (a write that changes the byte).
-- Exec marks (snesPrgRom offsets; alias-proof) count executions and the scenes. Probes read a WRAM value at each execution of an instruction
-- (the callback runs before the instruction) and tally the distinct values with the scene.
w1c = w1c or {}

local WR = emu.memType.snesWorkRam
local CTX_CAP = 300

local function romOff(k, pc)
  if k == 0x7E or k == 0x7F then return nil end
  if k <= 0x3F or (k >= 0x80 and k <= 0xBF) then
    if pc < 0x8000 then return nil end
    return ((k & 0x3F) << 16) | pc
  end
  if k >= 0xC0 then return ((k & 0x3F) << 16) | pc end
  return nil
end

function w1c.start(opts)
  local self = { keys = {}, pairsT = {}, lw = {}, ctl36 = 0, nmi = 0, frames = 0, scenes = {}, sceneSeq = {}, execs = {}, probes = {}, logN = 0, hits = 0, snaps = {} }
  local LOGCAP = opts.logCap or 120
  local HELP = opts.helpers or {}
  local lastScene = nil

  local function inHelper(k, pc)
    local ro = romOff(k, pc)
    if not ro then return false end
    for _, r in ipairs(HELP) do
      if ro >= r[1] and ro <= r[2] + 4 then return true end
    end
    return false
  end

  local function hit(w, kind, a, v)
    local off = kit.wramOffset(a) or (a & 0xFFFF)
    local old = nil
    if kind == "write" then
      old = kit.r8(off)
      if w.bits and ((old ~ v) & w.bits) == 0 then return end
      if w.chg and old == v then return end
    end
    local st = emu.getState()
    local k, pc, f = st["cpu.k"], st["cpu.pc"], st["frameCount"]
    local sc = kit.r16(0x0644)
    local pck = string.format("%02X:%04X", k, pc)
    local key = w.name .. " " .. kind .. " " .. pck
    local e = self.keys[key]
    if not e then
      e = { name = w.name, kind = kind, pc = pck, n = 0, first = f, scene0 = sc, scenes = {}, addrs = {}, vals = {}, nv = 0, ctx = {}, nctx = 0 }
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
    if e.vals[v] or e.nv < 8 then
      if not e.vals[v] then e.nv = e.nv + 1 end
      e.vals[v] = (e.vals[v] or 0) + 1
    end
    local function ctx(ck)
      if e.ctx[ck] or e.nctx < CTX_CAP then
        if not e.ctx[ck] then e.nctx = e.nctx + 1 end
        e.ctx[ck] = (e.ctx[ck] or 0) + 1
      end
    end
    if w.chg and kind == "write" then
      ctx(string.format("x:%04X %02X>%02X", off, old, v))
    end
    if inHelper(k, pc) then
      local sp, d = st["cpu.sp"], st["cpu.d"] or 0
      local ck = string.format("i=%04X s=%04X,%04X,%02X", kit.r16(0x0000), kit.r16(sp + 3), kit.r16(sp + 5), kit.r8(sp + 7))
      if d >= 0x0F00 and d <= 0x1FBF then
        ck = ck .. string.format(" cop=%02X:%04X", kit.r8(d + 0x0C), kit.r16(d + 0x0A))
      end
      ctx(ck)
    end
    if kind == "write" then
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
    local e = { n = 0, off = off, scenes = {} }
    self.execs[name] = e
    emu.addMemoryCallback(function()
      e.n = e.n + 1
      if e.n == 1 then e.first, e.scene0 = emu.getState()["frameCount"], kit.r16(0x0644) end
      local sc = kit.r16(0x0644)
      e.scenes[sc] = (e.scenes[sc] or 0) + 1
    end, emu.callbackType.exec, off, off, emu.cpuType.snes, emu.memType.snesPrgRom)
  end

  -- probes: { name = {off = <ROM offset of the instruction>, addr = <WRAM offset>, size = 1|2} }
  for name, p in pairs(opts.probes or {}) do
    local e = { n = 0, off = p.off, addr = p.addr, size = p.size or 1, vals = {}, nv = 0, scenes = {} }
    self.probes[name] = e
    emu.addMemoryCallback(function()
      e.n = e.n + 1
      local v = (e.size == 2) and kit.r16(e.addr) or kit.r8(e.addr)
      local sc = kit.r16(0x0644)
      local vk = string.format("%d@%02X", v, sc)
      if e.vals[vk] or e.nv < 40 then
        if not e.vals[vk] then e.nv = e.nv + 1 end
        e.vals[vk] = (e.vals[vk] or 0) + 1
      end
      e.scenes[sc] = (e.scenes[sc] or 0) + 1
    end, emu.callbackType.exec, p.off, p.off, emu.cpuType.snes, emu.memType.snesPrgRom)
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
    table.sort(list, function(x, y) return tostring(x[1]) < tostring(y[1]) end)
    return list
  end
  local function plnum(map)
    local list = {}
    for k, c in pairs(map or {}) do list[#list + 1] = { k, c } end
    table.sort(list, function(x, y) return x[1] < y[1] end)
    return list
  end

  -- snapshot of the watched state at a named moment (the kill / leave / return trials)
  function self.snap(label)
    if #self.snaps >= 80 then return end
    local b = {}
    for a = 0x0A80, 0x0AA7 do b[#b + 1] = string.format("%02X", kit.r8(a)) end
    self.snaps[#self.snaps + 1] = { label = label, frame = emu.getState()["frameCount"], scene = kit.r16(0x0644), next = kit.r16(0x0642),
                                    wramFlags = table.concat(b), a00 = kit.r16(0x0A00), a1F = kit.r8(0x0A1F), enemies = kit.r16(0x0AEC),
                                    enemiesBcd = kit.r16(0x0AEE), actors = kit.r16(0x0DBC), form = kit.r16(0x0AD4) }
  end

  function self.rows()
    local rows, prs, ex, pr = {}, {}, {}, {}
    for key, e in pairs(self.keys) do
      rows[#rows + 1] = { key = key, name = e.name, kind = e.kind, pc = e.pc, n = e.n, first = e.first, last = e.last or e.first, sc0 = e.scene0,
                          scenes = plnum(e.scenes), addrs = plnum(e.addrs), vals = plnum(e.vals), ctx = pl(e.ctx) }
    end
    table.sort(rows, function(x, y) return x.key < y.key end)
    for _, p in pairs(self.pairsT) do
      prs[#prs + 1] = { key = p.key, n = p.n, first = p.first, last = p.last or p.first, sc0 = p.scene0, addrs = plnum(p.addrs) }
    end
    table.sort(prs, function(x, y) return x.key < y.key end)
    for name, e in pairs(self.execs) do
      ex[#ex + 1] = { name = name, off = e.off, n = e.n, first = e.first, sc0 = e.scene0, scenes = plnum(e.scenes) }
    end
    table.sort(ex, function(x, y) return x.name < y.name end)
    for name, e in pairs(self.probes) do
      pr[#pr + 1] = { name = name, off = e.off, addr = e.addr, size = e.size, n = e.n, vals = pl(e.vals), scenes = plnum(e.scenes) }
    end
    table.sort(pr, function(x, y) return x.name < y.name end)
    return { rows = rows, pairs = prs, execs = ex, probes = pr, control36Writes = self.ctl36, nmiExecs = self.nmi, frames = self.frames, hits = self.hits,
             sceneFrames = plnum(self.scenes), sceneSeq = self.sceneSeq, snaps = self.snaps }
  end

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

-- Batch W1-c (Event/flag bytes), ROM O (ROM offsets are decimal, from the `; {n}` tags of extract:lt output).
--   $0A00            eventFlags byte 0 (flags #00-#07; flag #00 = bit 0). Read watch (mask recorded through the helper's index `i=`), write watch,
--                    and a bit-change watch on bit 0 (old ~ new)
--   $0A80-$0AA7      wramFlags $0A80-$0A9F (flags $0400-$04FF: enemy-defeat bits) plus $0AA0-$0AA7 (flags $0500-$053F: boss rewards $0500-$0507,
--                    ability unlocks $0510+). Read / write watch and a byte-change watch (`chg`: old>new per byte)
--   $0AEC-$0AEF      enemiesRemaining ($0AEC word, binary) and enemiesRemainingBcd ($0AEE word, BCD); the word accesses touch $0AED / $0AEF
--   helper cores     SetWramFlag .. TestEventFlag (45172-45340, flag_helpers.asm) and CheckEnemyDefeatedFlag (250075-250110, actor_execution.asm):
--                    the flag index is in WRAM $0000 and the return addresses are on the stack (descriptor `i=` / `s=` / `cop=`)
w1c.batchC = {
  watch = {
    { name = "0A00", lo = 0x0A00, hi = 0x0A00 },
    { name = "0A00 bit0 change", lo = 0x0A00, hi = 0x0A00, kinds = { "write" }, bits = 0x01 },
    { name = "0A80-0AA7", lo = 0x0A80, hi = 0x0AA7 },
    { name = "0A80-0AA7 change", lo = 0x0A80, hi = 0x0AA7, kinds = { "write" }, chg = true },
    { name = "0AEC-0AEF", lo = 0x0AEC, hi = 0x0AEF },
    { name = "0AEC-0AEF change", lo = 0x0AEC, hi = 0x0AEF, kinds = { "write" }, chg = true },
  },
  helpers = { { 45172, 45340 }, { 250075, 250110 } },
  exec = {
    -- InitActorFromSceneData: defeat check, the skip of an already defeated record, the counter increment
    Init_CheckDefeated_call = 249721, Init_DefeatedSkip_JMP = 249726, Init_INC_enemiesRemaining = 249750,
    CheckEnemyDefeatedFlag_defeated = 250110,
    -- player_character idle dispatch (flag #00 selects the sprite family: #00-#03 normal, #10-#13 the "Shadow" sprites) and PlayerIdleAnimLoop
    IdleSouth_test = 181375, IdleSouth_normal = 181381, IdleSouth_flagSet = 181386,
    IdleNorth_test = 181391, IdleNorth_normal = 181397, IdleNorth_flagSet = 181402,
    IdleWest_test = 181407, IdleWest_normal = 181413, IdleWest_flagSet = 181418,
    IdleEast_test = 181423, IdleEast_normal = 181429, IdleEast_flagSet = 181434,
    PlayerIdleAnimLoop_normal = 50232, PlayerIdleAnimLoop_flagSet = 50237,
    -- ClearSceneState: flags $00-$0F zeroed, both counters zeroed, flag $FF set / cleared
    ClearSceneState_STX_eventFlags = 253291, ClearSceneState_STX_enemiesRemaining = 253345, ClearSceneState_STX_enemiesRemainingBcd = 253348,
    -- the kill counters and the kill flag
    StdDefeat_entry = 56202, StdDefeat_DecBcd = 56223, StdDefeat_SetDungeonKillFlag = 56306,
    EnemyDefeatDispatch_entry = 697407, EnemyDefeatDispatch_CountKill_DecBcd = 697463, EnemyDefeatDispatch_SetDungeonKillFlag = 697510,
    SetDungeonKillFlag_handler_JSR = 44172,
    -- clears of the wramFlags block
    ClearAllWramFlags_loop = 46291, GameOver_clear_loop = 54994,
    -- ShadowShimmer flag #00 tests (Idle / Active) and the inventory exit flag
    ShadowShimmerIdle_flag0 = 176698, ShadowShimmerActive_flag0 = 176733, scene_flag_init_set = 50794,
    PlayerIdleAnimLoop_flag0 = 50226, inventory_exit_set = 191678, inventory_loop_test = 192033,
  },
  probes = {
    -- the counter at every spawn increment and at every kill (value@scene)
    enemies_at_spawn_INC = { off = 249750, addr = 0x0AEC, size = 2 },
    enemies_at_StdDefeat = { off = 56223, addr = 0x0AEC, size = 2 },
    enemies_at_Dispatch = { off = 697463, addr = 0x0AEC, size = 2 },
    flags00_at_ShadowIdle = { off = 176698, addr = 0x0A00, size = 1 },
    flags00_at_ShadowActive = { off = 176733, addr = 0x0A00, size = 1 },
    flags00_at_PlayerIdleAnimLoop = { off = 50226, addr = 0x0A00, size = 1 },
    flags00_at_scene_flag_init = { off = 50794, addr = 0x0A00, size = 1 },
    flags00_at_inventory_exit_set = { off = 191678, addr = 0x0A00, size = 1 },
    flags00_at_ClearSceneState = { off = 253291, addr = 0x0A00, size = 2 },
  },
  nmi = 33528,
}

-- w1c.startC{ publishEvery = 600, logCap = 60, extraWatch = {...}, extraExec = {...}, extraProbes = {...}, kinds = { ["name"] = {"read"} } }
function w1c.startC(o)
  o = o or {}
  local cfg = { watch = {}, exec = {}, probes = {}, helpers = w1c.batchC.helpers, nmi = w1c.batchC.nmi, control = true, logCap = o.logCap, publishEvery = o.publishEvery }
  for _, w in ipairs(w1c.batchC.watch) do
    local kinds = o.kinds and o.kinds[w.name]
    if kinds then
      local c = {}
      for k, v in pairs(w) do c[k] = v end
      c.kinds = kinds
      w = c
    end
    cfg.watch[#cfg.watch + 1] = w
  end
  for _, w in ipairs(o.extraWatch or {}) do cfg.watch[#cfg.watch + 1] = w end
  for k, v in pairs(w1c.batchC.exec) do cfg.exec[k] = v end
  for k, v in pairs(o.extraExec or {}) do cfg.exec[k] = v end
  for k, v in pairs(w1c.batchC.probes) do cfg.probes[k] = v end
  for k, v in pairs(o.extraProbes or {}) do cfg.probes[k] = v end
  return w1c.start(cfg)
end
