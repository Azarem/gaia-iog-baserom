-- description: R2 scene sweep: one scene per run (warp by sceneNext, watch, one result row) with the coverage hooks of the R2 questions.
-- requires: mesen_kit, iog_kit, gaia_kit
--
--   r2.run{ scene=, post=180, maxWait=700, pcs={...ROM offsets...}, flagPoke=nil, noBanner=false, coll=true }
--
-- Run it from a loaded state (S01r) with `run_script includes={"gaia_kit"}`. At the first frame end it (optionally) writes the word
-- `flagPoke` into $0A00 (event flags $00-$0F) and then `scene` into sceneNext $0642; it watches until `post` NMIs after the arrival
-- (sceneCurrent == scene and sceneNext == 0), or until `maxWait` NMIs without an arrival, then ends with one result row (kit.finish).
-- A sample is also taken 180 NMIs after the write (the literal "advance 180 frames" of the R2 prompt).
--
-- pcs (ROM file offsets of the loaded ROM; `false` or nil disables a hook):
--   nmi (NmiHandler)  cfg (the ASL after the operand read of SceneCmd_ConfigDisplay: A = preset index, Y = stream offset + 1)
--   m3 (SceneCmd_LoadBgTiles, mode 3 entry)  l4 (Load4bppPage)  fgj (JMP DmaLowVramTileset in SceneCmd_LoadLayerMaps)  lowv (DmaLowVramTileset)
--   fcs (FindCurrentScene)  ldpg (LoadPlayerGraphics)  par (ParallaxThinkerEntry)  parw (the word of ParallaxThinkerEntry, 16 bit)
--   copspawn (STA $0000,X in SpawnThinkerParam: A = entry word)  tefidx (instruction after the STA of TestEventFlag: $0000 = flag index)
r2 = r2 or {}

local PRG = emu.memType.snesPrgRom
local WR = emu.memType.snesWorkRam
local CPU = emu.cpuType.snes

local function r16(a) return emu.read16(a, WR, false) end
local function r8(a) return emu.read(a, WR, false) end
local function hx(v, w) return string.format("%0" .. (w or 2) .. "X", v) end

local function cap(t, v, n) if #t < (n or 8) then t[#t + 1] = v end end

function r2.run(o)
  local P = o.pcs or {}
  local post, maxWait = o.post or 180, o.maxWait or 700
  local S = {
    scene = o.scene, base = r16(0x0644), pre0642 = r16(0x0642), flagPoke = o.flagPoke,
    presets = {}, presetOperandOk = {}, par = {}, parCop = 0, ffTests = { T = 0, A = 0, O = 0 }, ffActorD = {},
    byte1FTests = 0, byte1FReads = 0, d58 = {}, d58n = 0, seen = { r16(0x0644) }, cov = {},
  }
  local nmiN, w36, nf = 0, 0, 0
  local started, start36 = false, 0
  local arrived, arriveN, arriveF = false, nil, nil
  local nmiAtArrive = 0
  local sample180 = nil

  -- positive controls
  if P.nmi then
    emu.addMemoryCallback(function()
      nmiN = nmiN + 1
      if arrived and not S.loadFrames then S.loadFrames = nf - arriveF end
    end, emu.callbackType.exec, P.nmi, P.nmi, CPU, PRG)
  end
  emu.addMemoryCallback(function(a) if (a & 0xFFFF) == 0x36 then w36 = w36 + 1 end end, emu.callbackType.write, 0x36, 0x36, CPU, WR)

  -- coverage counters (exec)
  for name, off in pairs({ m3 = P.m3, l4 = P.l4, fgj = P.fgj, lowv = P.lowv, fcs = P.fcs, ldpg = P.ldpg }) do
    if off then
      S.cov[name] = 0
      emu.addMemoryCallback(function() S.cov[name] = S.cov[name] + 1 end, emu.callbackType.exec, off, off, CPU, PRG)
    end
  end

  -- ConfigDisplay: preset index = A at the ASL; the operand byte read from the script stream must equal it
  if P.cfg then
    emu.addMemoryCallback(function()
      local st = emu.getState()
      local a, y = st["cpu.a"] & 0xFF, st["cpu.y"]
      local ptr = r16(0x3A) | (r8(0x3C) << 16)
      local bank = ptr >> 16
      local lo = (ptr & 0xFFFF) + y - 1
      local opv
      if bank == 0x7E or bank == 0x7F then
        opv = emu.read(((bank - 0x7E) << 16) + lo, WR, false)
      else
        opv = emu.read(((bank & 0x3F) << 16) + lo, PRG, false)
      end
      cap(S.presets, hx(a)); cap(S.presetOperandOk, opv == a and 1 or 0)
    end, emu.callbackType.exec, P.cfg, P.cfg, CPU, PRG)
  end

  -- parallax thinker: entry (spawn parameter = animScratch+2,X) and COP spawns that name the entry
  if P.par then
    emu.addMemoryCallback(function()
      local x = emu.getState()["cpu.x"]
      cap(S.par, hx(r8(0x10002 + x)), 16)
    end, emu.callbackType.exec, P.par, P.par, CPU, PRG)
  end
  if P.copspawn and P.parw then
    emu.addMemoryCallback(function()
      if (emu.getState()["cpu.a"] & 0xFFFF) == P.parw then S.parCop = S.parCop + 1 end
    end, emu.callbackType.exec, P.copspawn, P.copspawn, CPU, PRG)
  end

  -- TestEventFlag: flag index in $0000 (word) after the STA; byte $0A1F is flags $F8-$FF (idx >> 3 == $1F)
  if P.tefidx then
    emu.addMemoryCallback(function()
      local idx = r16(0x0000)
      S.tefAll = (S.tefAll or 0) + 1
      if (idx >> 3) == 0x1F then
        S.byte1FTests = S.byte1FTests + 1
        if idx == 0xFF then
          local d = emu.getState()["cpu.d"]
          if d >= 0x1000 then
            S.ffTests.A = S.ffTests.A + 1
            local k = hx(d, 4)
            S.ffActorD[k] = (S.ffActorD[k] or 0) + 1
          elseif d >= 0x0F00 and d < 0x1000 then S.ffTests.T = S.ffTests.T + 1
          else S.ffTests.O = S.ffTests.O + 1 end
        end
      end
    end, emu.callbackType.exec, P.tefidx, P.tefidx, CPU, PRG)
  end
  emu.addMemoryCallback(function(a) if (a & 0xFFFF) == 0x0A1F then S.byte1FReads = S.byte1FReads + 1 end end, emu.callbackType.read, 0x0A1F, 0x0A1F, CPU, WR)

  -- writes of the menu-choice words $0D58 / $0D5A: record the nonzero values with the writing pc
  emu.addMemoryCallback(function(a, v)
    if v ~= 0 then
      S.d58n = S.d58n + 1
      local st = emu.getState()
      cap(S.d58, string.format("%04X=%02X@%02X:%04X", a & 0xFFFF, v, st["cpu.k"], st["cpu.pc"]), 6)
    end
  end, emu.callbackType.write, 0x0D58, 0x0D5B, CPU, WR)

  local function sampleCpu()
    local st = emu.getState()
    return { k = st["cpu.k"], pc = st["cpu.pc"], sp = st["cpu.sp"], d = st["cpu.d"], dbr = st["cpu.dbr"], ps = st["cpu.ps"],
      bgMode = st["ppu.bgMode"], frame = st["frameCount"] }
  end

  local function finish(why)
    gaia.release()
    S.why = why
    S.arrived, S.arriveN, S.nmi, S.w36, S.frames = arrived, arriveN, nmiN, w36, nf
    S.sample180 = sample180
    S.endScene, S.endNext = r16(0x0644), r16(0x0642)
    S.bgm, S.actors, S.mask, S.banner = r8(0x06F2), r8(0x0DBC) | (r8(0x0DBD) << 8), r16(0x065A), r8(0x00B4)
    S.flagsEnd = r16(0x0A00)
    S.cpu = sampleCpu()
    S.layer = { l06EE = r16(0x06EE), l06EF = r16(0x06EF), tm = nil }
    S.visibleH = r16(0x06EC)
    S.tableIdx = r16(0x0646)
    if arrived and o.coll ~= false then
      local c = gaia.coll.census({}, 0)
      local h = {}
      for _, t in ipairs({ 3, 4, 5, 6, 9, 10, 12, 14 }) do h[hx(t)] = c.low[t + 1] end
      local dyn = 0
      for i = 2, 16 do dyn = dyn + c.hi[i] end
      S.coll = { w = c.cellsW, h = c.cellsH, stride = c.stride, bx = c.boundsX, by = c.boundsY, hist = h, dyn = dyn, clamped = c.clamped }
    end
    S.ps = nil
    kit.finish(S)
  end

  kit.onFrame(function()
    nf = nf + 1
    if not started then
      started = true
      start36 = r16(0x0036)
      if o.flagPoke then emu.write16(0x0A00, o.flagPoke, WR) end
      emu.write16(0x0642, o.scene, WR)
      return
    end
    local sc = r16(0x0644)
    if S.seen[#S.seen] ~= sc then cap(S.seen, sc, 10) end
    if not arrived and sc == o.scene and r16(0x0642) == 0 then
      arrived, arriveN, arriveF = true, nmiN, nf
      S.flagsArrive = r16(0x0A00)
      S.actorsArrive = r8(0x0DBC)
    end
    if r8(0x00B4) ~= 0 and not o.noBanner then gaia.hold((nf % 6 < 3) and { "a" } or {}) else gaia.release() end
    if not sample180 and nmiN >= 180 then
      sample180 = { scene = sc, next = r16(0x0642), arrived = arrived, bgm = r8(0x06F2), actors = r8(0x0DBC), flags = r16(0x0A00) }
    end
    if arrived and nmiN - arriveN >= post then
      if o.flagPoke then
        -- the flags are read once more 60 NMIs later by the caller's `post`; nothing extra here
      end
      finish("post")
    elseif nmiN >= maxWait or nf >= maxWait + 300 then
      finish("timeout")
    end
  end)
end
