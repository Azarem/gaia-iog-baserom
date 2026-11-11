-- description: C1/C2 instrumentation: adhoc VRAM DMA store order against the NMI, NMITIMEN ($4200) writers by PC.
-- requires: mesen_kit, iog_kit, gaia_kit
--
-- run_script {includes={"gaia_kit","c1_adhoc"}, code='c1.run{frames=N, nmi=33528, input=function(n) ... end, execs={Name=prgOffset}}'}
--
-- What it records (all callbacks run BEFORE the store; the PC of a callback is the address AFTER the instruction):
--   control   : NMI exec count (snesPrgRom `nmi`), $36 write count (the NMI's INC $36), $4200 write count
--   pairs     : every CPU store of the trigger word ($7F0C07, low byte) and the next store of the size word ($7F0C09,
--               low byte): NMI execs and $36 writes between them, last NMITIMEN value written before each store
--   clears    : stores to $7F0C07 made by DmaAdhocVramBlock (PRG 258512..258543): arm-to-clear latency in NMI execs
--   w4200     : every distinct (K:PC after the store, value) written to $4200 at any of the 128 bank aliases
--   execs     : exec counters of the requested PRG offsets (coverage)
c1 = c1 or {}

local WR  = emu.memType.snesWorkRam
local SM  = emu.memType.snesMemory
local PRG = emu.memType.snesPrgRom
local CPU = emu.cpuType.snes

local DMA_LO, DMA_HI = 258512, 258543          -- DmaAdhocVramBlock (names/bank03.json key 258512)

local function hex(v, w) return string.format("%0" .. (w or 2) .. "X", v) end

function c1.run(o)
  local S = {
    nmi = 0, w36 = 0, n4200 = 0, nt = nil, ntPc = nil, ntFrame = nil,
    pend = nil, armed = nil, pairs = {}, pairAgg = {}, orphanSize = {}, destWhilePending = {},
    clears = {}, clearLatency = {}, w4200 = {}, execCount = {}, storeSrc = 0,
    probes = {}, rawAddr = {},
  }
  local scene = function() return kit.r16(0x0644) end

  -- exec counters ---------------------------------------------------------------------------
  emu.addMemoryCallback(function() S.nmi = S.nmi + 1 end, emu.callbackType.exec, o.nmi, o.nmi, CPU, PRG)
  -- UpdateFrameFull (33212..33285, runs actors inside the NMI during a music upload): inUF while it executes
  S.inUF, S.ufEntries = 0, 0
  emu.addMemoryCallback(function() S.inUF = 1; S.ufEntries = S.ufEntries + 1 end, emu.callbackType.exec, 33212, 33212, CPU, PRG)
  emu.addMemoryCallback(function() S.inUF = 0 end, emu.callbackType.exec, 33285, 33285, CPU, PRG)
  for name, off in pairs(o.execs or {}) do
    S.execCount[name] = 0
    emu.addMemoryCallback(function() S.execCount[name] = S.execCount[name] + 1 end,
      emu.callbackType.exec, off, off, CPU, PRG)
  end
  emu.addMemoryCallback(function(a) if (a & 0xFFFF) == 0x36 then S.w36 = S.w36 + 1 end end,
    emu.callbackType.write, 0x36, 0x36, CPU, WR)

  -- NMITIMEN ($4200), every bank alias --------------------------------------------------------
  local function on4200(a, v)
    if (a & 0xFFFF) ~= 0x4200 then return end
    local k, pc, f = gaia.pc()
    local pc24 = (k << 16) | pc
    S.nt, S.ntPc, S.ntFrame = v, pc24, f
    S.n4200 = S.n4200 + 1
    local key = hex(pc24, 6) .. "=" .. hex(v)
    local e = S.w4200[key]
    if not e then
      e = { n = 0, first = f, scene = scene() }
      S.w4200[key] = e
    end
    e.n = e.n + 1
  end
  for bank = 0, 0xFF do
    if bank <= 0x3F or (bank >= 0x80 and bank <= 0xBF) then
      emu.addMemoryCallback(on4200, emu.callbackType.write, (bank << 16) | 0x4200, (bank << 16) | 0x4200, CPU, SM)
    end
  end

  -- adhoc block ($7F0C03-$7F0C0A = WRAM 0x10C03-0x10C0A) -----------------------------------------
  local function ntSnap() return S.nt and hex(S.nt) or "??" end
  local function onAdhoc(a, v)
    local lo = a & 0xFFFF
    if lo >= 0x0C03 and lo <= 0x0C06 then S.storeSrc = S.storeSrc + 1; return end
    if lo ~= 0x0C07 and lo ~= 0x0C09 then return end
    local st = emu.getState()
    local k, pc, f = st["cpu.k"], st["cpu.pc"], st["frameCount"]
    local en = st["internalRegisters.enableNmi"] and 1 or 0     -- hardware NMITIMEN bit 7 at this instant
    local scan = st["ppu.scanline"]
    local pc24 = (k << 16) | pc
    local rk = string.format("%X", a)
    S.rawAddr[rk] = (S.rawAddr[rk] or 0) + 1
    if lo == 0x0C07 then
      if (k & 0x3F) == 3 and pc >= (DMA_LO & 0xFFFF) and pc <= (DMA_HI & 0xFFFF) then
        -- DmaAdhocVramBlock zeroing the trigger inside the NMI
        local lat = S.armed and (S.nmi - S.armed.nmi) or -1
        S.clearLatency[tostring(lat)] = (S.clearLatency[tostring(lat)] or 0) + 1
        S.clearPc = hex(pc24, 6)
        S.armed = nil
        return
      end
      if S.pend and #S.destWhilePending < 20 then
        S.destWhilePending[#S.destWhilePending + 1] = { pc = hex(pc24, 6), f = f, prevPc = hex(S.pend.pc, 6) }
      end
      S.pend = { nmi = S.nmi, w36 = S.w36, f = f, pc = pc24, nt = ntSnap(), ntAge = S.ntFrame and (f - S.ntFrame) or -1,
                 scene = scene(), val = v, en = en, scan = scan, uf = S.inUF }
      S.armed = { nmi = S.nmi, f = f }
      if o.onDest then o.onDest(S, pc24) end   -- sensitivity control hook (disposable runs only)
    else
      if S.pend then
        local p = S.pend
        S.pend = nil
        local rec = { destPc = hex(p.pc, 6), sizePc = hex(pc24, 6), nmiBetween = S.nmi - p.nmi,
                      w36Between = S.w36 - p.w36, ntAtDest = p.nt, ntAtSize = ntSnap(),
                      enAtDest = p.en, enAtSize = en, scanDest = p.scan, scanSize = scan,
                      f = p.f, scene = p.scene, val = v }
        if #S.pairs < 3 then S.pairs[#S.pairs + 1] = rec end
        local key = rec.destPc .. ">" .. rec.sizePc .. " nmiBetween=" .. rec.nmiBetween .. " w36Between=" .. rec.w36Between
                    .. " nt=" .. rec.ntAtDest .. "/" .. rec.ntAtSize .. " hwEnableNmi=" .. p.en .. "/" .. en
                    .. " inUpdateFrameFull=" .. p.uf
        local e = S.pairAgg[key]
        if not e then e = { n = 0, first = p.f, scene = p.scene }; S.pairAgg[key] = e end
        e.n = e.n + 1
      elseif #S.orphanSize < 20 then
        S.orphanSize[#S.orphanSize + 1] = { sizePc = hex(pc24, 6), f = f, nt = ntSnap(), val = v }
      end
    end
  end
  emu.addMemoryCallback(onAdhoc, emu.callbackType.write, 0x10C03, 0x10C0A, CPU, WR)

  -- frame loop: input timeline, probes, finish --------------------------------------------------
  local n = 0
  kit.onFrame(function()
    n = n + 1
    if o.input then
      local b = o.input(n)
      if b ~= nil then gaia.hold(b) end
    end
    if o.probe and #S.probes < 14 then
      -- change-only probe: one row per change of (scene, displayModeFlags, playerFlags, input mask, sceneNext)
      local sig = string.format("%04X %04X %04X %04X %04X", scene(), kit.r16(0x09EC), kit.r16(0x09AE),
                                kit.r16(0x065A), kit.r16(0x0642))
      if sig ~= S.lastSig then
        S.lastSig = sig
        S.probes[#S.probes + 1] = string.format("n=%d scene,dmf,pflags,mask,sceneNext=%s nt=%s xy=%d,%d", n, sig, ntSnap(),
                                               kit.r16(0x1014), kit.r16(0x1016))
      end
    end
    if o.tick then o.tick(n, S) end
    if n >= o.frames then
      gaia.release()
      local res = {
        frames = n, control = { nmiExec = S.nmi, w36Writes = S.w36, w4200Writes = S.n4200, updateFrameFullEntries = S.ufEntries },
        pairCount = #S.pairs, pairAgg = S.pairAgg, pairs = S.pairs, pendingAtEnd = S.pend and { destPc = hex(S.pend.pc, 6), f = S.pend.f } or nil,
        orphanSize = S.orphanSize, destWhilePending = S.destWhilePending,
        clearLatencyNmiExecs = S.clearLatency, clearPc = S.clearPc, rawAddr = S.rawAddr, srcStores = S.storeSrc,
        w4200 = S.w4200, execs = S.execCount, probes = S.probes, lastNt = ntSnap(),
      }
      if o.final then res.final = o.final(S) end
      kit.finish(res)
    end
  end)
end
