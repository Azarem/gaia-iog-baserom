-- description: W1 address census (batch b: scene and flags) with per-scene tally, read values, last-writer pairing, exec marks and value probes.
-- requires: mesen_kit, iog_kit, gaia_kit
--
-- Use:  includes = {"gaia_kit", "a_census", "w1b_kit"}   then   local h = w1b.startB{logCap=60}   and   acen.run{..., final=function() return h.rows() end}
--
-- Every hit is keyed "<watch name> <read|write> <K:PC>" (PC = the address AFTER the accessing instruction; the harness maps it to the
-- instruction that ENDS there). Per key: count, first/last frame, first scene, per-scene counts, per-address counts, the distinct values
-- (max 8; the byte written, or for a read the byte read), and for watches with ctx=true the actor context of the access (direct page D = the slot
-- address inside a COP handler, and the slot's entry word and bank byte). Reads are paired with the K:PC of the last write seen on the same
-- byte ("init" = no write seen yet). A `bits` entry (write only) records a write only when it changes a bit of the mask (old ~ new): the
-- bit-change variant of plan 6.1.
-- Exec marks (snesPrgRom offsets; alias-proof) count executions and the scenes. Probes read a WRAM value at each execution of an instruction
-- (the callback runs before the instruction) and tally the distinct values with the scene.
w1b = w1b or {}

local WR = emu.memType.snesWorkRam

function w1b.start(opts)
  local self = { keys = {}, pairsT = {}, lw = {}, ctl36 = 0, nmi = 0, frames = 0, scenes = {}, sceneSeq = {}, execs = {}, probes = {}, logN = 0, hits = 0 }
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
    if w.ctxMask then
      -- read callbacks run before the instruction executes: for `AND $eventFlags, Y` in TestEventFlag A still holds the bit mask ($80 = flag $FF)
      local d = st["cpu.d"] or 0
      local ck = string.format("a%02X:D%04X:ent%04X", (st["cpu.a"] or 0) & 0xFF, d, (d >= 0x1000 and d <= 0x1FBF) and kit.r16(d) or 0)
      if e.ctx[ck] or e.nctx < 40 then
        if not e.ctx[ck] then e.nctx = e.nctx + 1 end
        e.ctx[ck] = (e.ctx[ck] or 0) + 1
      end
    elseif w.ctx then
      local d = st["cpu.d"] or 0
      if d >= 0x1000 and d <= 0x1FBF then
        local ck = string.format("D%04X:ent%04X:b%02X", d, kit.r16(d), kit.r8(d + 2))
        if e.ctx[ck] or e.nctx < 12 then
          if not e.ctx[ck] then e.nctx = e.nctx + 1 end
          e.ctx[ck] = (e.ctx[ck] or 0) + 1
        end
      end
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

  -- probes: { name = {off = <ROM offset of the instruction>, addr = <WRAM offset>, size = 1|2, dp = true: addr is a direct-page offset (D + addr)} }
  for name, p in pairs(opts.probes or {}) do
    local e = { n = 0, off = p.off, addr = p.addr, size = p.size or 1, dp = p.dp, vals = {}, nv = 0, scenes = {} }
    self.probes[name] = e
    emu.addMemoryCallback(function()
      e.n = e.n + 1
      local ea = e.addr
      if e.dp then ea = ea + (emu.getState()["cpu.d"] or 0) end
      local v = (e.size == 2) and kit.r16(ea) or kit.r8(ea)
      local sc = kit.r16(0x0644)
      local vk = string.format("%d@%02X", v, sc)
      if e.vals[vk] or e.nv < 24 then
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
             sceneFrames = plnum(self.scenes), sceneSeq = self.sceneSeq }
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

-- Batch W1-b (Scene and flags), ROM O. The plan's watch list plus the aliases the static prelude showed the code uses:
--   $06A0         mapTilemapBaseB (word); RenderRowStrip / RenderColumnStrip read `$069F,X`, X = 0 / 2 -> $069F / $06A1 (high bytes)
--   $06C8         forcedScrollOverride = BG2 horizontal override value ($06C8) + flag ($06C9 bit 7): WriteBgScroll reads `$06C7,X` / `$scrollOverrideH,X` with X = 2
--   $06C6 $06CA   scrollOverrideH / V of BG1 (X = 0), watched so the X = 0 half of WriteBgScroll is separated from the X = 2 half
--   $06CC         scrollOverrideV of BG2 (value $06CC, flag $06CD bit 7): `$06CB,X` / `$scrollOverrideV,X` with X = 2
--   $06EE/$06EF   layerPriorityFlag (word) = $06EE low byte + scrollModeFlags ($06EF); bit 12 of the word is $06EF bit 4 (bit-change watch)
--   $06F0         default actor properties word (InitActorFromSceneData ORA $06F0); $06F1 is written by ConfigDisplay as a byte
--   $06F2         musicParentActor
--   $0402-$0405   RAM block-move stub (PHB, MVN dest,src, PLB, RTS): $0404 destination bank, $0405 source bank
--   $0D6E/$0D6F   deferred / left scene ids
--   $09CC-$09CF   playerSpriteCachePtr / playerSpriteCacheBank
--   $0A1F         event flag bits $F8-$FF (flag $FF = bit 7)
--   $7F0600-$7F06FF  sprite-text buffer of pr_text_placement_calc / BG3 tilemap staging rows (write only; the MVN of the block copy is an exec mark)
--   $00DA         sprite-text byte count
w1b.batchB = {
  watch = {
    { name = "06A0", lo = 0x06A0, hi = 0x06A1 },
    { name = "06C6-06C7", lo = 0x06C6, hi = 0x06C7 },
    { name = "06C8", lo = 0x06C8, hi = 0x06C9 },
    { name = "06CA-06CB", lo = 0x06CA, hi = 0x06CB },
    { name = "06CC-06CD", lo = 0x06CC, hi = 0x06CD },
    { name = "06EE-06EF", lo = 0x06EE, hi = 0x06EF },
    { name = "06EF bit4(0x10)", lo = 0x06EF, hi = 0x06EF, kinds = { "write" }, bits = 0x10 },
    { name = "06F0", lo = 0x06F0, hi = 0x06F1 },
    { name = "06F2", lo = 0x06F2, hi = 0x06F3 },
    { name = "0402-0405", lo = 0x0402, hi = 0x0405 },
    { name = "0D6E-0D6F", lo = 0x0D6E, hi = 0x0D6F },
    { name = "09CC-09CF", lo = 0x09CC, hi = 0x09CF },
    { name = "0A1F flag FF bit7", lo = 0x0A1F, hi = 0x0A1F, ctx = true },
    { name = "0A1F bit7 change", lo = 0x0A1F, hi = 0x0A1F, kinds = { "write" }, bits = 0x80, ctx = true },
    { name = "7F0600-06FF", lo = 0x10600, hi = 0x106FF, kinds = { "write" } },
    { name = "00DA", lo = 0x00DA, hi = 0x00DB },
  },
  exec = {
    RenderComposeBuffer_entry = 247691, RenderComposeBuffer_normal = 247703, RenderComposeBuffer_priority = 247792,
    RenderComposeBuffer_copy = 247798, RenderComposeBuffer_MVN = 247817,
    LoadScenePalettes_entry = 253856, LoadScenePalettes_stubcall = 253939,
    LoadPlayerGraphics_entry = 253944, LoadPlayerGraphics_main = 253960,
    ConfigDisplay_entry = 166509, ConfigDisplay_scrollModeFlags = 166728,
    TiltPhaseStart = 238500, RouteEndLanding_STZ_00DA = 239180, FormationDone_STZ_00DA = 238687,
    InitActorFromSceneData_mode0 = 249664,
    MusicJingleActor = 172096, ChestOpeningActor = 174008, FluteMusicActorController = 237520, SpcMusicLoadCmd = 166765,
    ExecuteSceneTransition_normal = 252481, DeferSceneTransition = 238408, DisplaySceneTitle = 172315,
    ClearSceneState_STX_06CC = 253315, OpenInventoryScreen_STX_06CC = 191950,
    WriteBgScroll_overrideH = 33753, WriteBgScroll_overrideV = 33783,
  },
  probes = {
    stubcall_LoadScenePalettes = { off = 253939, addr = 0x0404, size = 2 },
    stubcall_CopyPalette = { off = 39282, addr = 0x0404, size = 2 },
    stubcall_GlobalAmbientTalkWithSnapshot_a = { off = 49323, addr = 0x0404, size = 2 },
    stubcall_GlobalAmbientTalkWithSnapshot_b = { off = 49340, addr = 0x0404, size = 2 },
    stubcall_GlobalAmbientTalkRestoreActor_a = { off = 49413, addr = 0x0404, size = 2 },
    stubcall_GlobalAmbientTalkRestoreActor_b = { off = 49430, addr = 0x0404, size = 2 },
    stubcall_DmaRomToWram = { off = 167528, addr = 0x0404, size = 2 },
    stubcall_CopyPaletteBundleFrame = { off = 254268, addr = 0x0404, size = 2 },
    stubcall_DiaryCopyExecute = { off = 780860, addr = 0x0404, size = 2 },
    actorProps_06F0 = { off = 249664, addr = 0x06F0, size = 2 },
    renderCompose_00DA = { off = 247792, addr = 0x00DA, size = 2 },
    renderCompose_flags = { off = 247695, addr = 0x06EE, size = 2 },
    jingle_06F2 = { off = 172096, addr = 0x06F2, size = 2 },
    chest_06F2 = { off = 174008, addr = 0x06F2, size = 2 },
    flute_06F2 = { off = 237520, addr = 0x06F2, size = 2 },
    scene_0D6E_at_title = { off = 172315, addr = 0x0D6E, size = 2 },
  },
  nmi = 33528,
}

-- w1b.startB{ publishEvery = 600, logCap = 60, kinds = { ["06EE-06EF"] = {"write"} }, extraWatch = {...}, extraExec = {...} }
function w1b.startB(o)
  o = o or {}
  local cfg = { watch = {}, exec = {}, probes = {}, nmi = w1b.batchB.nmi, control = true, logCap = o.logCap, publishEvery = o.publishEvery }
  for _, w in ipairs(w1b.batchB.watch) do
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
  for k, v in pairs(w1b.batchB.exec) do cfg.exec[k] = v end
  for k, v in pairs(o.extraExec or {}) do cfg.exec[k] = v end
  for k, v in pairs(w1b.batchB.probes) do cfg.probes[k] = v end
  for k, v in pairs(o.extraProbes or {}) do cfg.probes[k] = v end
  return w1b.start(cfg)
end
