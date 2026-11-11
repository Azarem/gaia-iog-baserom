-- description: E1 Aura casts: warp with form / item / ability pokes, scripted buttons, exec counters on named routines, OBSEL ($2101) writes on every bank alias, adhoc DMA register writes ($7F0C03-09), decoded snapshots with a VRAM $4400-$46FF occupancy count.
-- requires: mesen_kit, iog_kit, gaia_kit, e1_display
--
-- run_script {includes={"gaia_kit","e1_display","e1_aura"}, code='e1a.run{scene=0x3F, pokes={...}, sched=function(t) ... end, post=300, snapAt={1,150,299}, execs={{"AuraBarrierMain",178559}}, out="E1_aura.txt"}'}
--
-- Callbacks run BEFORE the access; the PC a memory callback reports is the address after the accessing instruction.
-- Offsets are decimal PRG offsets: off = ((bank & 0x3F) << 16) | pc16.
--   warp     : o.pokes = {{addr=wramOffset, v=, w=16 for a word}} are written when $0642 = 0 (frame >= 5), then o.scene is written to $0642 (quick warp).
--   clock    : t = NMI frames ($36 deltas) since the first frame with $0644 = o.scene, $0642 = 0 and the banner flag $00B4 = 0 (the banner is dismissed with A pulses
--              before that); the scene load itself runs about 160 emulator frames without NMIs, which do not count.
--   input    : o.sched(t) returns a button list (names as for gaia.hold) or nil for none; called every frame from t = 1.
--   execs    : list of {name, prgOffset}; counts and first frame of each (exec callback on snesPrgRom).
--   snapshot : e1.snap() line (PPU state, OBSEL decoded as obj base / off / mode) plus form $0AD4, the player actor's function word, the number of
--              nonzero VRAM words in $4400-$46FF (the Aura orbital tiles), and the adhoc DMA registers $7F0C03-09.
--   tick     : o.tick(t, S) is called every frame of the run clock; anything it stores in S.custom is returned in the result.
--   writes   : every write to $2101 (OBSEL) at the aliases $00-$3F / $80-$BF, and to $7F0C07 / $7F0C09 (adhoc DMA trigger / size), listed with frame, t and PC.
e1a = e1a or {}

local WR  = emu.memType.snesWorkRam
local SM  = emu.memType.snesMemory
local CPU = emu.cpuType.snes
local VRAM = emu.memType.snesVideoRam
local function off24(k, pc) return ((k & 0x3F) << 16) | (pc & 0xFFFF) end

function e1a.run(o)
  local S = { ev = {}, snaps = {}, exec = {}, t = nil, arrived = false }
  local snapAt = {}
  for _, v in ipairs(o.snapAt or {}) do snapAt[v] = true end
  local function ev(s) if #S.ev < 120 then S.ev[#S.ev + 1] = s end end
  local function tstr() return S.t and ("t=" .. S.t) or "t=-" end

  for _, e in ipairs(o.execs or {}) do
    S.exec[e[1]] = { n = 0 }
    emu.addMemoryCallback(function()
      local x = S.exec[e[1]]
      x.n = x.n + 1
      if x.n == 1 then x.first = emu.getState()["frameCount"]; x.t = S.t; ev(string.format("EXEC %s first f=%d %s", e[1], x.first, tstr())) end
    end, emu.callbackType.exec, e[2], e[2], CPU, emu.memType.snesPrgRom)
  end

  local obsel = { n = 0 }
  for bank = 0, 0xFF do
    if bank <= 0x3F or (bank >= 0x80 and bank <= 0xBF) then
      emu.addMemoryCallback(function(a, v)
        local st = emu.getState()
        obsel.n = obsel.n + 1
        ev(string.format("OBSEL=%02X f=%d %s pc=%d", v, st["frameCount"], tstr(), off24(st["cpu.k"], st["cpu.pc"])))
      end, emu.callbackType.write, (bank << 16) | 0x2101, (bank << 16) | 0x2101, CPU, SM)
    end
  end
  local adhoc = { n = 0 }
  emu.addMemoryCallback(function(a, v)
    local st = emu.getState()
    adhoc.n = adhoc.n + 1
    ev(string.format("ADHOC[7F:%04X]=%02X f=%d %s pc=%d", a & 0xFFFF, v, st["frameCount"], tstr(), off24(st["cpu.k"], st["cpu.pc"])))
  end, emu.callbackType.write, 0x10C07, 0x10C0A, CPU, WR)

  local function vramOcc()
    local nz = 0
    for w = 0x4400, 0x46FF do if emu.read16(w * 2, VRAM, false) ~= 0 then nz = nz + 1 end end
    return nz
  end

  local n, stage, bannerPulse = 0, "wait", 0
  kit.onFrame(function()
    n = n + 1
    local f = emu.getState()["frameCount"]
    local sc, sn = kit.r16(0x0644), kit.r16(0x0642)
    if stage == "wait" then
      if n >= 5 and sn == 0 then
        for _, p in ipairs(o.pokes or {}) do if p.w == 16 then kit.w16(p.addr, p.v) else kit.w8(p.addr, p.v) end end
        kit.w16(0x0642, o.scene)
        ev(string.format("f=%d STAGE scene %02X pokes=%d", f, o.scene, #(o.pokes or {})))
        stage = "warping"
      end
    elseif stage == "warping" then
      if sc == o.scene and sn == 0 then stage = "banner" end
      if n > (o.warpTimeout or 1500) then kit.finish({ error = "warp_timeout", scene = sc, next = sn, ev = S.ev }); return end
    end
    if stage == "banner" then
      if kit.r8(0x00B4) ~= 0 then
        bannerPulse = bannerPulse + 1
        gaia.hold((bannerPulse % 6 < 3) and { "a" } or {})
      else
        gaia.release(); stage = "run"; S.t = 0; S.arrivedFrame = f; S.n36Start = kit.r16(0x36)
        ev(string.format("f=%d RUN start (banner clear) scene=%02X n36=%d", f, sc, S.n36Start))
      end
    elseif stage == "run" then
      S.t = (kit.r16(0x36) - S.n36Start) & 0xFFFF
      local b = (S.t >= 1 and o.sched) and o.sched(S.t) or nil
      if b then gaia.hold(b) else gaia.release() end
      if o.tick then o.tick(S.t, S) end
      if snapAt[S.t] and S.snapT ~= S.t then
        S.snapT = S.t
        local s = e1.snap(); s.tag = "t" .. S.t
        local slot = kit.r16(0x09AA)
        S.snaps[#S.snaps + 1] = e1.fmt(s) .. string.format(" | form=%d func=%04X vram4400nz=%d adhoc=%02X%02X%02X/%02X%02X/%02X%02X $0AA2=%04X inv0=%02X eqIdx=%04X eqType=%04X plX=%d plY=%d sEw=%d sNs=%d pflags=%04X",
          kit.r16(0x0AD4), kit.r16(slot), vramOcc(),
          kit.r8(0x10C05), kit.r8(0x10C04), kit.r8(0x10C03), kit.r8(0x10C08), kit.r8(0x10C07), kit.r8(0x10C0A), kit.r8(0x10C09),
          kit.r16(0x0AA2), kit.r8(0x0AB4), kit.r16(0x0AC4), kit.r16(0x0AC6), kit.r16(0x1014), kit.r16(0x1016), kit.r16(0x09B2, nil, true), kit.r16(0x09B4, nil, true), kit.r16(0x09AE))
      end
      if S.t >= o.post then
        local lines = {}
        for _, l in ipairs(S.ev) do lines[#lines + 1] = l end
        for _, l in ipairs(S.snaps) do lines[#lines + 1] = l end
        if o.out then emu.mcp.writeFile(o.out, table.concat(lines, "\n") .. "\n", false) end
        local ex = {}
        for k, v in pairs(S.exec) do ex[k] = { n = v.n, first = v.first, t = v.t } end
        local shown = {}
        for i = 1, math.min(o.show or 14, #S.ev) do shown[i] = S.ev[i] end
        kit.finish({ exec = ex, obselWrites = obsel.n, adhocWrites = adhoc.n, events = shown, nEvents = #S.ev, snaps = S.snaps, scene = sc, frame = f, custom = S.custom })
      end
    end
  end)
end
