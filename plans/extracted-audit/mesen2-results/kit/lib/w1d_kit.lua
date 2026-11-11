-- description: W1 address census (batch d: $7F scratch) with per-scene tally, read values, last-writer pairing, exec marks, value probes, snapshots and actor attribution for the per-slot fields.
-- requires: mesen_kit, iog_kit, gaia_kit
--
-- Use:  includes = {"gaia_kit", "a_census", "a_actors", "w1d_kit"}   then   local h = w1d.startD{logCap=60}   and   acen.run{..., final=function() return h.rows() end}
--
-- Every hit is keyed "<watch name> <read|write> <K:PC>" (PC = the address AFTER the accessing instruction; the harness maps it to the instruction that ENDS there).
-- Per key: count, first/last frame, first scene, per-scene counts, per-address counts (first 32 distinct, plus the min and max address), the distinct values (max 8;
-- the byte written, or for a read the byte read) and the context list `ctx`.
-- (`slotShift`: 0x10000 by default = the extended `$7F` fields; 0 for the fields of the low-WRAM slot itself, `base` = 0x1000.)
-- Slot-field watches (`fields`): a range of per-slot extended fields ($7F:1000 + slot, stride $30; `$7F0010,X` with X = the slot address is WRAM offset
-- 0x11010 + $30 k): only the listed field offsets are kept; the hit is named by the field and the ctx entry says who is running (D) relative to the slot
-- touched: "self" (D = the slot), "other" (D = another actor slot), "thinker" (D in $0F00-$0FFF), "d=XXXX" otherwise, with the entry word and bank byte of
-- the slot touched (`ent=`) and of the actor running (`de=`).
-- Reads are paired with the K:PC of the last write seen on the same byte ("init" = no write seen yet).
-- Exec marks (snesPrgRom offsets; alias-proof) count executions and the scenes. Probes read a WRAM value at each execution of an instruction (the callback runs before
-- the instruction) and tally the distinct values with the scene.
w1d = w1d or {}

local WR = emu.memType.snesWorkRam
local CTX_CAP = 60
local ADDR_CAP = 32

function w1d.start(opts)
  local self = { keys = {}, pairsT = {}, lw = {}, ctl36 = 0, nmi = 0, frames = 0, scenes = {}, sceneSeq = {}, execs = {}, probes = {}, logN = 0, hits = 0, snaps = {}, streaks = {} }
  local LOGCAP = opts.logCap or 120
  local lastScene = nil

  -- tally of one hit into its key entry
  local function record(e, off, v, f, sc, ck, pck, kind, key)
    self.hits = self.hits + 1
    e.n, e.last = e.n + 1, f
    e.scenes[sc] = (e.scenes[sc] or 0) + 1
    if off < e.amin then e.amin = off end
    if off > e.amax then e.amax = off end
    if e.addrs[off] or e.naddr < ADDR_CAP then
      if not e.addrs[off] then e.naddr = e.naddr + 1 end
      e.addrs[off] = (e.addrs[off] or 0) + 1
    end
    if e.vals[v] or e.nv < 8 then
      if not e.vals[v] then e.nv = e.nv + 1 end
      e.vals[v] = (e.vals[v] or 0) + 1
    end
    if ck then
      if e.ctx[ck] or e.nctx < CTX_CAP then
        if not e.ctx[ck] then e.nctx = e.nctx + 1 end
        e.ctx[ck] = (e.ctx[ck] or 0) + 1
      end
    end
    if kind == "write" then
      self.lw[off] = pck
    else
      local pk = key .. " <- " .. (self.lw[off] or "init")
      local p = self.pairsT[pk]
      if not p then p = { key = pk, n = 0, first = f, scene0 = sc }; self.pairsT[pk] = p end
      p.n, p.last = p.n + 1, f
    end
  end

  -- DMA compression: the DMA of the BG3 buffer to VRAM reads 2048 consecutive WRAM bytes with the CPU parked, one callback per byte, and an emu.getState() per byte
  -- makes the session ~7 times slower. A READ hit whose address is the next byte (step 1) of a run that was attributed by emu.getState() to a PC that directly follows a
  -- store to $420B / $420C (opcode 8D / 8E / 8C, operand 0B 42 or 0C 42: the DMA / HDMA trigger) reuses that attribution for 15 hits and re-validates on every 16th
  -- (counts, scenes, addresses and values of every hit are still recorded). Nothing else is compressed: a store loop, a block move or a read by another
  -- instruction always goes through emu.getState().
  -- PCs reported after a store to $420B / $420C: the tagged instruction after each such store of extracted/ (output of the static scan: `w1d_static.py` / tags `; {n}`),
  -- as the K:PC the callback reports (the next instruction's address, and that address + 1: the callback of a DMA reports the PC one byte further)
  local dmaPc = { ["80:8309"]=true,["80:830A"]=true,["80:8353"]=true,["80:8354"]=true,["80:8431"]=true,["80:8432"]=true,["80:846A"]=true,["80:846B"]=true,["82:83BA"]=true,["82:83BB"]=true,["82:8590"]=true,["82:8591"]=true,["82:85D9"]=true,["82:85DA"]=true,["82:8689"]=true,["82:868A"]=true,["82:8977"]=true,["82:8978"]=true,["82:8A66"]=true,["82:8A67"]=true,["82:8CE5"]=true,["82:8CE6"]=true,["82:8E40"]=true,["82:8E41"]=true,["82:8F3C"]=true,["82:8F3D"]=true,["82:8FCA"]=true,["82:8FCB"]=true,["82:9E06"]=true,["82:9E07"]=true,["82:9E42"]=true,["82:9E43"]=true,["82:9F2F"]=true,["82:9F30"]=true,["82:AFDD"]=true,["82:AFDE"]=true,["82:AFFE"]=true,["82:AFFF"]=true,["82:B016"]=true,["82:B017"]=true,["82:B036"]=true,["82:B037"]=true,["82:B0A2"]=true,["82:B0A3"]=true,["82:ED10"]=true,["82:ED11"]=true,["82:EE38"]=true,["82:EE39"]=true,["83:D8EA"]=true,["83:D8EB"]=true,["83:D90C"]=true,["83:D90D"]=true,["83:DD59"]=true,["83:DD5A"]=true,["83:DE7C"]=true,["83:DE7D"]=true,["83:F1FF"]=true,["83:F200"]=true }
  local function isDmaNext(k, pc)
    return dmaPc[string.format("%02X:%04X", k, pc)] == true
  end

  local function hit(w, kind, a, v)
    local off = kit.wramOffset(a) or (a & 0xFFFF)
    local name, slot = w.name, nil
    if w.fields then
      local rel = off - w.base
      local fld = rel % w.stride
      if not w.fields[fld] then return end
      name = w.fields[fld]
      slot = (off - (w.slotShift or 0x10000)) - fld   -- the slot address ($1000 + $30 k): the direct page of that actor (slotShift 0 for fields in the low-WRAM slot itself)
    end
    if w.chg and kind == "write" and kit.r8(off) == v then return end
    local sk = self.streaks[w.name .. kind]
    if not sk then sk = { cnt = 0, last = -1 }; self.streaks[w.name .. kind] = sk end
    if kind == "read" and sk.dma and off == sk.last + 1 and sk.cnt % 16 ~= 0 then
      sk.cnt, sk.last = sk.cnt + 1, off
      record(sk.e, off, v, sk.f, sk.sc, sk.ck, sk.pck, kind, sk.key)
      return
    end
    local st = emu.getState()
    local k, pc, f = st["cpu.k"], st["cpu.pc"], st["frameCount"]
    local sc = kit.r16(0x0644)
    local pck = string.format("%02X:%04X", k, pc)
    local key = name .. " " .. kind .. " " .. pck
    local e = self.keys[key]
    if not e then
      e = { name = name, kind = kind, pc = pck, n = 0, first = f, scene0 = sc, scenes = {}, addrs = {}, naddr = 0, amin = off, amax = off, vals = {}, nv = 0, ctx = {}, nctx = 0 }
      self.keys[key] = e
      if self.logN < LOGCAP then
        self.logN = self.logN + 1
        gaia.log("%s f=%d sc=%02X a=%05X v=%02X D=%04X", key, f, sc, off, v, st["cpu.d"] or 0)
      end
    end
    local d = st["cpu.d"] or 0
    local ck
    if slot then
      local rel = "d=" .. string.format("%04X", d)
      if d == slot then rel = "self"
      elseif d >= 0x1000 and d <= 0x1FBF then rel = "other"
      elseif d >= 0x0F00 and d <= 0x0FFF then rel = "thinker" end
      local de = ""
      if d >= 0x1000 and d <= 0x1FBF and d ~= slot then de = string.format(" de=%02X:%04X", kit.r8(d + 2), kit.r16(d)) end
      ck = string.format("%s ent=%02X:%04X%s", rel, kit.r8(slot + 2), kit.r16(slot), de)
    elseif w.ctx then
      local role = "d=" .. string.format("%04X", d)
      if d >= 0x1000 and d <= 0x1FBF then role = string.format("actor de=%02X:%04X", kit.r8(d + 2), kit.r16(d))
      elseif d >= 0x0F00 and d <= 0x0FFF then role = string.format("thinker D=%04X", d) end
      ck = role
    end
    record(e, off, v, f, sc, ck, pck, kind, key)
    if sk.e == e and off == sk.last + 1 then sk.cnt = sk.cnt + 1 else sk.cnt = 1 end
    sk.e, sk.last, sk.f, sk.sc, sk.ck, sk.pck, sk.key = e, off, f, sc, ck, pck, key
    sk.dma = (kind == "read") and (not slot) and isDmaNext(k, pc)
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
      local a = e.addr
      if p.rel then a = a + emu.getState()["cpu.x"] end    -- rel: the address is a field of the actor in X (a direct-page offset when D = X)
      local v = (e.size == 2) and kit.r16(a) or kit.r8(a)
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

  -- snapshot of the watched state at a named moment: CGRAM colours $91 / $92 (byte $122-$125) against the staging words $7F0B22 / $7F0B24, the backdrop triplet,
  -- the player's per-slot fields +$10 / +$20, the BG3 staging head, the cache slots and the words of the inventory open path
  function self.snap(label)
    if #self.snaps >= 80 then return end
    local WRAMW = function(a) return kit.r16(a) end
    local s = { label = label, frame = emu.getState()["frameCount"], scene = kit.r16(0x0644), next = kit.r16(0x0642), form = kit.r16(0x0AD4),
                stg91 = WRAMW(0x10B22), stg92 = WRAMW(0x10B24), cg91 = emu.read16(0x122, emu.memType.snesCgRam), cg92 = emu.read16(0x124, emu.memType.snesCgRam),
                back = string.format("%02X%02X%02X", kit.r8(0x10C00), kit.r8(0x10C01), kit.r8(0x10C02)),
                pl10 = WRAMW(0x11010), pl20 = WRAMW(0x11020), pf = kit.r16(0x09AE), c0672 = string.format("%02X%02X%02X", kit.r8(0x0672), kit.r8(0x0673), kit.r8(0x0674)),
                c0675 = string.format("%02X%02X%02X", kit.r8(0x0675), kit.r8(0x0676), kit.r8(0x0677)), b2 = kit.r16(0x00B2), f4 = kit.r16(0x00F4), f8 = kit.r16(0x00F8),
                s06c6 = kit.r16(0x06C6), s06c8 = kit.r16(0x06C8), s06ca = kit.r16(0x06CA), s06cc = kit.r16(0x06CC), ac = kit.r16(0x0DBC) }
    self.snaps[#self.snaps + 1] = s
  end

  function self.rows()
    local rows, prs, ex, pr = {}, {}, {}, {}
    for key, e in pairs(self.keys) do
      rows[#rows + 1] = { key = key, name = e.name, kind = e.kind, pc = e.pc, n = e.n, first = e.first, last = e.last or e.first, sc0 = e.scene0,
                          scenes = plnum(e.scenes), addrs = plnum(e.addrs), naddr = e.naddr, amin = e.amin, amax = e.amax, vals = plnum(e.vals), ctx = pl(e.ctx) }
    end
    table.sort(rows, function(x, y) return x.key < y.key end)
    for _, p in pairs(self.pairsT) do
      prs[#prs + 1] = { key = p.key, n = p.n, first = p.first, last = p.last or p.first, sc0 = p.scene0 }
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

-- Batch W1-d ($7F scratch), ROM O. WRAM offsets: $7F:xxxx = 0x10000 + xxxx. ROM offsets are decimal, from the `; {n}` tags of extract:lt output.
--   7F0000-00FF / 7F0100-01FF   collision flag tables of layer 0 / 1 (`[$3E]` pointer set from $06AA / $06AC, bank $7F) and anything else that reaches $7F:0000-$01FF
--   slot fields +$10 / +$20     `$7F0010,X` orbitAngle / `$7F0020,X` statsPtr with X = the slot address: WRAM 0x11000 + $30 k + field (actors); the thinker pages
--                               are 0x10F00-0x10FFF and are not watched
--   player +$20 / +$10          the same fields of the player slot ($1000, `$09AA`): the readers that can see the glide countdown
--   7F0200-09FF                 BG3 tilemap staging (bg3TilemapBuffer $7F0200, 32 x 32 words)
--   7F0B22-0B25                 palette staging buffer words = CGRAM colours $91 / $92 (cgramPalette $7F0A00 + 2 x index)
--   7F0C00-0C02                 backdropColors, the COLDATA triplet written verbatim by UploadCgramPalette
--   7F0E00-0EFF / 7F3000-30FF   the two pages InitActorPool zeroes
--   00B2 / 00F4 / 00F8 / 0672-0677  the unsaved or cleared words of OQ-I034-4 (the $06CA / $06CC half was measured in W1-b)
w1d.batchD = {
  watch = {
    { name = "7F0000-00FF", lo = 0x10000, hi = 0x100FF, ctx = true },
    { name = "7F0100-01FF", lo = 0x10100, hi = 0x101FF, ctx = true },
    { name = "7F0200-09FF", lo = 0x10200, hi = 0x109FF },
    { name = "7F0B22-0B25", lo = 0x10B22, hi = 0x10B25, ctx = true },
    { name = "7F0C00-0C02", lo = 0x10C00, hi = 0x10C02, ctx = true },
    { name = "7F0E00-0EFF", lo = 0x10E00, hi = 0x10EFF, ctx = true },
    { name = "7F3000-30FF", lo = 0x13000, hi = 0x130FF, ctx = true },
    { name = "slot fields", lo = 0x11000, hi = 0x11FBF, base = 0x11000, stride = 0x30,
      fields = { [0x10] = "7F0010,X orbitAngle", [0x11] = "7F0010,X orbitAngle", [0x20] = "7F0020,X statsPtr", [0x21] = "7F0020,X statsPtr" } },
    { name = "player 7F0020", lo = 0x11020, hi = 0x11021, ctx = true },
    { name = "player 7F0010", lo = 0x11010, hi = 0x11011, ctx = true },
    { name = "00B2-00B3", lo = 0x00B2, hi = 0x00B3, ctx = true },
    { name = "00F4-00F5", lo = 0x00F4, hi = 0x00F5, ctx = true },
    { name = "00F8-00F9", lo = 0x00F8, hi = 0x00F9, ctx = true },
    { name = "0672-0677", lo = 0x0672, hi = 0x0677, ctx = true },
  },
  exec = {
    -- InitActorPool: the actor clear, the thinker clear loop (7F0E00 / 7F3000) and the inventory (scene FF) variant
    InitActorPool_actorClear = 249359, InitActorPool_thinkerClear = 249447, InitActorPool_thinkerClear_FF = 249471,
    -- Mode7PerspectiveInit: the two $FFFF stores
    Mode7Init_STA_0B22 = 239950, Mode7Init_STA_0B24 = 239957,
    -- palette upload and the backdrop writers
    UploadCgramPalette_COLDATA_read0 = 171526, ClearSceneState_backdrop_clear = 253384, gs2C_crow_crew_STA_0C01 = 361564, gs2C_crow_crew_STA_0C00 = 361570,
    sF0_class_dismissed_STA_0C00 = 646014, sE8_comet_display_STA_0C02 = 846876, sE8_dark_gaia_STA_0C02 = 848106,
    -- field_reveal_object: entry, the tier stores, the gem paths and the pickup child
    field_reveal_object = 55928, FieldRevealStatItemHp_STA = 55986, FieldRevealStatItemStr_STA = 56001, FieldRevealStatItemDef_STA = 56016, FieldRevealFromActorStats = 56025,
    collect_handler_gem = 57685, EnemyDefeatDispatch = 697407, gw82_fire_bug_JumpFar = 757177, StandardEnemyDefeatHandler = 56202, pyCC_mystic_ball_spawn = 771837, awB1_wall_walker_spawn = 769369,
    -- the player lock that stores a countdown in the player's statsPtr: glide, ramp climb
    LockPlayerForGlide_STA = 53392, RampBeginPlayerControl_STA = 54432, SliderGlideWest_STA = 53811, RampArcDriver_read = 54723,
    -- the inventory open path
    OpenInventoryScreen_06CA = 191947,
  },
  probes = {
    player_statsPtr_at_glide_lock = { off = 53392, addr = 0x11020, size = 2 },
    player_statsPtr_at_ramp_lock = { off = 54432, addr = 0x11020, size = 2 },
    -- field_reveal_object entry (LDA $26): the child's $26 (X = the child), and the parent's orbitAngle word at the spawners' LDA $orbitAngle,X (X = the parent)
    frev_child_26 = { off = 55941, addr = 0x26, size = 2, rel = true },
    frev_orbit_at_pyCC_spawn = { off = 771844, addr = 0x10010, size = 2, rel = true },
    frev_orbit_at_awB1_spawn = { off = 769376, addr = 0x10010, size = 2, rel = true },
    frev_orbit_at_EnemyDefeatDispatch = { off = 697451, addr = 0x10010, size = 2, rel = true },
  },
  nmi = 33528,
}

-- w1d.startD{ publishEvery = 600, logCap = 60, extraWatch = {...}, extraExec = {...}, extraProbes = {...}, kinds = { ["name"] = {"read"} } }
function w1d.startD(o)
  o = o or {}
  local cfg = { watch = {}, exec = {}, probes = {}, nmi = w1d.batchD.nmi, control = true, logCap = o.logCap, publishEvery = o.publishEvery }
  for _, w in ipairs(w1d.batchD.watch) do
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
  for k, v in pairs(w1d.batchD.exec) do cfg.exec[k] = v end
  for k, v in pairs(o.extraExec or {}) do cfg.exec[k] = v end
  for k, v in pairs(w1d.batchD.probes) do cfg.probes[k] = v end
  for k, v in pairs(o.extraProbes or {}) do cfg.probes[k] = v end
  return w1d.start(cfg)
end

-- Death transition of the engine (hit_stagger_controller, HP = 0): `$10 |= $0040`, the entry := the onDeathCallback ($7F1004 word, $7F1006 bank) or
-- StandardEnemyDefeatHandler ($DB8A, bank $80), `$08` := 0, `$2C` := `$2E` := 0. `pick(slot, cb)` chooses the victims (cb = the callback word, 0 = none).
function w1d.kill(n, pick)
  local done, pl, got = 0, kit.r16(0x09AA), {}
  for _, s in ipairs(aact.live()) do
    if done >= n then break end
    local sp, ext = kit.r16(0x10020 + s), kit.r16(0x1002A + s)
    local cb = kit.r16(0x11004 + s)             -- onDeathCallback = $7F1004,X
    if s ~= pl and sp ~= 0 and sp ~= 0xAB70 and (ext & 0x80) == 0 and pick(s, cb) then
      local f10 = kit.r16(s + 0x10)
      kit.w16(s + 0x10, f10 | 0x0040)
      if cb ~= 0 then
        kit.w16(s, cb); kit.w8(s + 2, kit.r8(0x11006 + s))   -- onDeathCallbackBank = $7F1006,X
      else
        kit.w16(s, 0xDB8A); kit.w8(s + 2, 0x80)
      end
      kit.w16(s + 0x08, 0); kit.w16(s + 0x2C, 0); kit.w16(s + 0x2E, 0)
      done = done + 1
      got[#got + 1] = string.format("%04X:cb=%04X", s, cb)
    end
  end
  return done, got
end
