-- description: W1 address census, batch g (actor scratch): $24-$27 of every actor slot (the spawner slot CopyActorState stores in $24), $0B02-$0B03 (difficulty), the escort ring $7EDF00-$7EDF7F, with exec marks, probes and the smooth-follow / escort-tracker tallies.
-- requires: mesen_kit, iog_kit, gaia_kit, w1d_kit
--
-- Use:  includes = {"gaia_kit", "a_census", "a_actors", "w1d_kit", "w1g_kit"}
--         local h = w1g.start{logCap=60}
--         acen.run{..., final=function() return h.rowsG() end}
--
-- The census itself is w1d.start (kit/lib/w1d_kit.lua): every hit of a watch is keyed "<watch> <read|write> <K:PC>" (PC = the address AFTER the accessing instruction,
-- mapped by the harness to the instruction that ENDS there), with count, scenes, addresses, values, the context (who runs: "self" = D is the slot touched, "other", "thinker")
-- and, for reads, the K:PC of the last write seen on the same byte ("init" = none seen in this run).
-- Watches: the slot fields $24-$25 and $26-$27 of the 84 slots (WRAM $1000 + $30 k; w1d `fields` with slotShift 0; a 16-bit access is two byte hits), $0B02-$0B03,
-- the ring $DF00-$DF3F and the bytes $DF40-$DF7F (the ninth entry and what follows it).
-- Added here (ROM O offsets, decimal, from the `; {n}` tags of extract:lt output):
--   spd     A at the six `STA $loopCounter, X` that set the projectile speed before the smooth_follow_child tail call (and the two callers that spawn the tick by COP)
--   tickspd exec at the tick's speed load (58624): the body's speed ($7F0014,X) and animation ($28)
--   step    exec at SmoothFollowWriteParentPos (58948): the tick's speed and the |dx| / |dy| it moved this frame (tick position minus body position)
--   trk     the escort tracker: seed probe, setup facing, ring offsets written, head index read (masked / wrapped), idle index, facing written with the carry, plus a trace of
--           the first frames of every tracker (the ring after setup, the NPC / player positions, the NPC animation)
w1g = w1g or {}

local function exec(off, fn)
  emu.addMemoryCallback(fn, emu.callbackType.exec, off, off, emu.cpuType.snes, emu.memType.snesPrgRom)
end

-- the 13 direct `$0B02` readers of extracted/ (tags of the load / ADC)
w1g.B02 = { 769504, 769519, 693289, 693375, 636919, 760353, 760606, 764696, 764741, 764811, 763802, 764129, 712476 }

-- speed stores: { offset of the STA, name }
w1g.SPD = {
  { 772087, "pyCC_blaster #1 (anim 08)" }, { 772230, "pyCC_blaster #2 (anim 03)" }, { 769336, "awB1_wall_walker" }, { 689254, "ec0C_ribber" },
  { 756099, "gw8A_sand_fanger" }, { 763805, "pyDD_mummy_queen" },
}

w1g.batch = {
  watch = {
    { name = "$24-$25 slot", lo = 0x1000, hi = 0x1FBF, base = 0x1000, stride = 0x30, slotShift = 0,
      fields = { [0x24] = "$24-$25 slot", [0x25] = "$24-$25 slot", [0x26] = "$26-$27 slot", [0x27] = "$26-$27 slot" } },
    { name = "0B02-0B03", lo = 0x0B02, hi = 0x0B03, ctx = true },
    { name = "DF00-DF3F ring", lo = 0xDF00, hi = 0xDF3F, ctx = true },
    { name = "DF40-DF7F", lo = 0xDF40, hi = 0xDF7F, ctx = true },
  },
  exec = {
    CopyActorState_STA_24 = 45576, CopyActorState_sceneFF_load = 45646, CopyActorState_clearExtended = 45654,
    FlickerParentActor_LDY_24 = 51194, SpawnDamageNumberEffect_LDY_24 = 56513, hit_stagger_controller_LDY_24 = 55442, statue_inventory_reward_LDY_24 = 52956,
    SmoothFollowChild_spawn = 58590, SmoothFollowChild_LDA_24 = 58602, SmoothFollowChildDie = 58618, SmoothFollowTick_entry = 58620, SmoothFollowTick_LDY_24 = 58633,
    EscortTracker_entry = 51206, EscortTracker_fetchFacing = 51216, EscortTracker_playerMoved = 51359, EscortTracker_idle = 51447, EscortTracker_advance = 51492,
    attack_ComputeParentOffset_LDY_24 = 179826, attack_ApplyParentOffset_LDY_24 = 179849,
    pyDD_child_STA_24 = 763819, gw8A_child_STA_24 = 756118, smooth_follow_child_STA_24 = 58604,
    pyCC1_STA_24 = 772076, pyCC2_STA_24 = 772219, awB1_STA_24 = 769325, ec0C_STA_24 = 689243,
    InitActorPool_actorClear = 249359,
  },
  probes = {
    tracker_seed_orbitAngle = { off = 51207, addr = 0x10010, size = 2, rel = true },
  },
  nmi = 33528,
}

local function sceneNow() return kit.r16(0x0644) end
local function frameNow() return emu.getState()["frameCount"] end

local function newT() return { keys = {}, n = 0 } end
local function tally(T, key, extra)
  local sc, f = sceneNow(), frameNow()
  local e = T.keys[key]
  if not e then
    if T.n >= 400 then return end
    e = { n = 0, first = f, sc0 = sc, scenes = {} }
    if extra then for k, v in pairs(extra) do e[k] = v end end
    T.keys[key] = e
    T.n = T.n + 1
  end
  e.n = e.n + 1
  e.last = f
  e.scenes[sc] = (e.scenes[sc] or 0) + 1
end
local function dump(T)
  local out = {}
  for k, e in pairs(T.keys) do
    local sc = {}
    for s, c in pairs(e.scenes) do sc[#sc + 1] = { s, c } end
    table.sort(sc, function(a, b) return a[1] < b[1] end)
    out[#out + 1] = { key = k, n = e.n, first = e.first, last = e.last, sc0 = e.sc0, scenes = sc, info = e.info }
  end
  table.sort(out, function(a, b) return a.key < b.key end)
  return out
end

local function absdiff(a, b)
  local d = (a - b) & 0xFFFF
  if d > 0x8000 then d = 0x10000 - d end
  return d
end

function w1g.start(o)
  o = o or {}
  local cfg = { watch = {}, exec = {}, probes = {}, nmi = w1g.batch.nmi, control = true, logCap = o.logCap, publishEvery = o.publishEvery }
  for _, w in ipairs(w1g.batch.watch) do cfg.watch[#cfg.watch + 1] = w end
  for _, w in ipairs(o.extra or {}) do cfg.watch[#cfg.watch + 1] = w end
  for k, v in pairs(w1g.batch.exec) do cfg.exec[k] = v end
  for k, v in pairs(w1g.batch.probes) do cfg.probes[k] = v end
  for _, off in ipairs(w1g.B02) do cfg.probes["B02 reader @" .. off] = { off = off, addr = 0x0B02, size = 2 } end
  local h = w1d.start(cfg)

  local SPD, TSPD, STEP, SETF, RINGW, HEAD, IDLE, FACW, SEED = newT(), newT(), newT(), newT(), newT(), newT(), newT(), newT(), newT()
  local maxRaw = 0

  for _, s in ipairs(w1g.SPD) do
    exec(s[1], function()
      tally(SPD, string.format("%s @%d A=%04X", s[2], s[1], emu.getState()["cpu.a"]))
    end)
  end

  exec(58624, function()   -- LDA $loopCounter, X  (X = the body that spawned the tick)
    local x = emu.getState()["cpu.x"]
    tally(TSPD, string.format("speed=%d anim=%02X", kit.r16(0x10014 + x), kit.r8(x + 0x28)))
  end)
  exec(58948, function()   -- SmoothFollowWriteParentPos: X = the tick, $04 = the body
    local x = emu.getState()["cpu.x"]
    local body = kit.r16(x + 4)
    local spd = kit.r16(0x10014 + x)
    local dx, dy = absdiff(kit.r16(x + 0x14), kit.r16(body + 0x14)), absdiff(kit.r16(x + 0x16), kit.r16(body + 0x16))
    tally(STEP, string.format("speed=%d dx=%d dy=%d", spd, dx, dy))
  end)

  -- CopyActorState at the scene test (LDA $sceneCurrent, 45646): X = the NEW actor here (TYX at 45598), D = the spawner. The new slot's extendedFlags ($7F002A) and callbacks ($7F1000 / 1002 / 1004)
  -- as they stand BEFORE the clearing that the scene-$FF test skips, and the spawner's extendedFlags
  local CAS = newT()
  exec(45646, function()
    local st = emu.getState()
    local x, d = st["cpu.x"], st["cpu.d"] or 0
    tally(CAS, string.format("new ext=%04X hit=%04X dodge=%04X death=%04X | spawner ext=%04X hit=%04X death=%04X", kit.r16(0x1002A + x), kit.r16(0x11000 + x), kit.r16(0x11002 + x), kit.r16(0x11004 + x),
      kit.r16(0x1002A + d), kit.r16(0x11000 + d), kit.r16(0x11004 + d)))
  end)

  -- the escort tracker
  local TRK, ser, serial = {}, {}, 0
  local function trace(line) if #TRK < 200 then TRK[#TRK + 1] = line end end
  exec(51206, function()   -- setup entry: X = the tracker slot
    local st = emu.getState()
    local x = st["cpu.x"]
    serial = serial + 1
    ser[x] = { id = serial, step = 0, f0 = st["frameCount"] }
    local npc = kit.r16(x + 4)
    if serial <= 12 then
      trace(string.format("sp#%d f=%d sc=%02X trk=%04X npc=%04X ent=%02X:%04X npcXY=(%d,%d) seed=%d seed2=%d orbitDiameter=%02X player=(%d,%d)", serial, st["frameCount"], sceneNow(), x, npc,
        kit.r8(npc + 2), kit.r16(npc), kit.r16(npc + 0x14), kit.r16(npc + 0x16), kit.r16(0x10010 + x), kit.r16(0x10010 + x) - 1, kit.r16(0x10012 + x),
        kit.r16(kit.r16(0x09AA) + 0x14), kit.r16(kit.r16(0x09AA) + 0x16)))
    end
  end)
  exec(51220, function()   -- after the seed branch / GetPlayerFacingDirection: A = the facing index
    local st = emu.getState()
    tally(SETF, string.format("setup facing A=%04X carry=%d", st["cpu.a"], st["cpu.ps"] & 1))
  end)
  exec(51282, function()   -- STA $7EDF00,X: X = the ring offset
    tally(RINGW, string.format("setup write offset=%02X", emu.getState()["cpu.x"]))
  end)
  exec(51340, function()   -- COP SetEntryHereAndYield: the ring after setup
    local x = emu.getState()["cpu.x"]
    local s = ser[x]
    if s and s.id <= 12 then
      local r = {}
      for i = 0, 8 do r[#r + 1] = string.format("%d:(%d,%d,f%d)", i, kit.r16(0xDF00 + 8 * i), kit.r16(0xDF02 + 8 * i), kit.r16(0xDF04 + 8 * i)) end
      trace(string.format("sp#%d ring after setup: %s", s.id, table.concat(r, " ")))
    end
  end)
  exec(51342, function()   -- the per-frame body
    local st = emu.getState()
    local x = st["cpu.x"]
    local s = ser[x]
    if not s then return end
    s.step = s.step + 1
    if s.id <= 6 and s.step <= 14 then
      local npc, pl = kit.r16(x + 4), kit.r16(0x09AA)
      trace(string.format("sp#%d step %d f=%d head=%04X npcXY=(%d,%d) anim=%02X e=%02X pl=(%d,%d) ($14,$16)=(%d,%d) $0E=%04X", s.id, s.step, st["frameCount"], kit.r16(0x10010 + x),
        kit.r16(npc + 0x14), kit.r16(npc + 0x16), kit.r16(npc + 0x28), kit.r8(npc + 0x08), kit.r16(pl + 0x14), kit.r16(pl + 0x16), kit.r16(x + 0x14), kit.r16(x + 0x16), kit.r16(x + 0x0E)))
    end
  end)
  exec(51366, function()   -- AND #$003F in the moving case: A = the raw head (byte offset, +8 per recorded frame)
    local a = emu.getState()["cpu.a"]
    if a > maxRaw then maxRaw = a end
    tally(HEAD, string.format("moved head index=%d wrapped=%d", (a & 0x3F) // 8, (a > 0x3F) and 1 or 0))
  end)
  exec(51456, function()   -- idle: LDA $7EDF04,X with X = the masked head
    tally(IDLE, string.format("idle head index=%d", emu.getState()["cpu.x"] // 8))
  end)
  exec(51505, function()   -- STA $7EDF04,X after GetPlayerFacingDirection: A = the facing, carry set = unknown
    local st = emu.getState()
    tally(FACW, string.format("facing written A=%04X carry=%d index=%d", st["cpu.a"], st["cpu.ps"] & 1, st["cpu.x"] // 8))
  end)

  function h.rowsG()
    local r = h.rows()
    r.spd, r.tickspd, r.step, r.setupFacing, r.ringWrites, r.headRead, r.idleRead, r.facingWritten = dump(SPD), dump(TSPD), dump(STEP), dump(SETF), dump(RINGW), dump(HEAD), dump(IDLE), dump(FACW)
    r.trk, r.maxRaw, r.trackers = TRK, maxRaw, serial
    r.copyState = dump(CAS)
    return r
  end
  return h
end
