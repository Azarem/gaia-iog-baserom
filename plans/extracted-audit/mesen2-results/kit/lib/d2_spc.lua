-- description: D2 SPC-side trace: SPC700 exec marks on the engine command handlers, SPC port 0 as the SPC sees it, DSP register writes, per-frame DSP/RAM sampling, CPU writes to $2140-$2143.
-- requires: mesen_kit, iog_kit, gaia_kit
--
-- run_script {includes={"gaia_kit","d2_spc"}, code='d2.run{frames=N, nmi=33528, out="D2_x.txt", input=function(n) ... end, tick=function(n,S) ... end, at={Name=prgOffset}}'}
--
-- Time base: every event carries emu.getState().masterClock (shared by the 65816 and the SPC700, 21,477,270 Hz;
-- one NTSC frame = 357,368 clocks) so events of both CPUs sort into one timeline. t = (masterClock - first recorded clock) / 357368 frames.
-- Callbacks run BEFORE the access; for a CPU memory callback the PC is the address AFTER the accessing instruction.
-- For an SPC exec callback emu.getState()["spc.pc"] is the address of the instruction about to run, spc.a/x/y are its input registers.
--
-- SPC addresses (ARAM, docs/audio/spc-disassembly.md, US engine at $0400):
--   exec marks (o.spcMarks overrides): MusicTick 0738, Dispatch 068B ($F0-$FF command split, A = command), CmdFadeOut 0619, CmdStop 0636,
--   CmdF2 067F, Loader 0F89 (sub_0f89, the IPL clone), ProcPort 06C2 (ProcessPortCommand, A = command), Path01 06CB (call ClearAramTail:
--   the command $01 path), Reset3031 06DF ($30 = 0), SongInit 0702 (loc_0702, new-song voice init), SongHdr 0782 (header copy), FadeStep 04D9
--   (DEC $31, counted), FadeEnd 04DD (fade counter reached 0 -> CmdStop), SyncPort 0504 (counted).
--   ports   : read of $F4 (SPC input, port 0 = what the 65816 wrote) and write of $F4 (SPC output): logged on a change of value
--   dsp     : write of $F3 with DSPADDR ($F2) in {0C 1C 2C 3C 4C 5C 6C 0D 4D 6D 7D}: logged on a change of the register's value (KON $4C: every nonzero write)
--   cpu     : writes to $2140-$2143 at all 128 bank aliases: port 0 logged (bulk transfer PCs counted only), ports 1-3 counted; reads of $2140 logged on change
--   sample  : one row per frame (end of frame): spc RAM $00 $04 $08 $0E $30 $31, DSP MVOLL MVOLR EVOLL EVOLR FLG KOFF, sum of the 8 ENVX, voices with ENVX > 0
--   controls: $36 write count, NMI exec count, SPC SyncPort count (S.counts), SPC P0 read count
d2 = d2 or {}

local WR  = emu.memType.snesWorkRam
local SM  = emu.memType.snesMemory
local PRG = emu.memType.snesPrgRom
local CPU = emu.cpuType.snes
local SPC = emu.cpuType.spc
local SR  = emu.memType.spcRam
local DSP = emu.memType.spcDspRegisters

local XFER_LO, XFER_HI = 168078, 168463
local NMI_LO,  NMI_HI  = 33528, 33670
local FRAME_CLOCKS = 357368

local MARKS = { MusicTick = 0x0738, Dispatch = 0x068B, CmdFadeOut = 0x0619, CmdStop = 0x0636, CmdF2 = 0x067F, Loader = 0x0F89,
                ProcPort = 0x06C2, Path01 = 0x06CB, Reset3031 = 0x06DF, SongInit = 0x0702, SongHdr = 0x0782, FadeEnd = 0x04DD }
local COUNT_MARKS = { FadeStep = 0x04D9, SyncPort = 0x0504 }
local DSPREGS = { [0x0C] = "MVOLL", [0x1C] = "MVOLR", [0x2C] = "EVOLL", [0x3C] = "EVOLR", [0x4C] = "KON", [0x5C] = "KOFF",
                  [0x6C] = "FLG", [0x0D] = "EFB", [0x4D] = "EON", [0x6D] = "ESA", [0x7D] = "EDL" }

local function hex(v, w) return string.format("%0" .. (w or 2) .. "X", v) end
local function off24(k, pc) return ((k & 0x3F) << 16) | (pc & 0xFFFF) end

function d2.run(o)
  local S = { w36 = 0, nmi = 0, counts = {}, ev = {}, nev = 0, dropped = 0, rows = {}, last = {}, mc0 = nil, rec = (o.recFrom == nil) }
  if o.xfer then XFER_LO, XFER_HI = o.xfer[1], o.xfer[2] end  -- ROM offsets of SpcBlockTransfer (bulk port writes suppressed); defaults are O
  if o.nmiRange then NMI_LO, NMI_HI = o.nmiRange[1], o.nmiRange[2] end  -- NmiHandler body (zero writes of P0 suppressed)
  local maxEv = o.maxEv or 1200
  local marks = o.spcMarks or MARKS

  local function stamp()
    local st = emu.getState()
    if S.mc0 == nil then S.mc0 = st["masterClock"] end
    return st, st["frameCount"], st["masterClock"]
  end
  local function ev(st, f, mc, text)
    if not S.rec then return end
    S.nev = S.nev + 1
    if #S.ev >= maxEv then S.dropped = S.dropped + 1; return end
    S.ev[#S.ev + 1] = { mc = mc, f = f, n36 = kit.r16(0x36), text = text, seq = S.nev }
  end
  local function cnt(k) S.counts[k] = (S.counts[k] or 0) + 1 end

  -- controls ---------------------------------------------------------------------------------------
  emu.addMemoryCallback(function() S.nmi = S.nmi + 1 end, emu.callbackType.exec, o.nmi, o.nmi, CPU, PRG)
  emu.addMemoryCallback(function(a) if (a & 0xFFFF) == 0x36 then S.w36 = S.w36 + 1 end end, emu.callbackType.write, 0x36, 0x36, CPU, WR)

  -- SPC exec marks --------------------------------------------------------------------------------
  local function spcRam(a) return emu.read(a, SR) end
  for name, addr in pairs(marks) do
    emu.addMemoryCallback(function()
      cnt("spc " .. name)
      if name == "MusicTick" then return end
      local st, f, mc = stamp()
      ev(st, f, mc, string.format("SPC %s a=%02X x=%02X y=%02X in0=%02X $04=%02X $08=%02X $0E=%02X $30=%02X $31=%02X", name,
        st["spc.a"] & 0xFF, st["spc.x"] & 0xFF, st["spc.y"] & 0xFF, spcRam(0x00), spcRam(0x04), spcRam(0x08), spcRam(0x0E), spcRam(0x30), spcRam(0x31)))
    end, emu.callbackType.exec, addr, addr, SPC, SR)
  end
  for name, addr in pairs(COUNT_MARKS) do
    emu.addMemoryCallback(function() cnt("spc " .. name) end, emu.callbackType.exec, addr, addr, SPC, SR)
  end

  -- SPC ports: P0 as the SPC sees it ---------------------------------------------------------------
  emu.addMemoryCallback(function(a, v)
    S.nRdP0 = (S.nRdP0 or 0) + 1
    if v ~= S.last.spcIn0 then
      S.last.spcIn0 = v
      local st, f, mc = stamp()
      local pc = st["spc.pc"] & 0xFFFF
      if pc >= 0x0F89 and pc <= 0x0FD0 then S.nLoaderP0 = (S.nLoaderP0 or 0) + 1; return end   -- the IPL clone's byte stream
      ev(st, f, mc, string.format("SPC rd $F4 (P0 in) = %02X at spc.pc=%04X", v, pc))
    end
  end, emu.callbackType.read, 0xF4, 0xF4, SPC, SR)
  emu.addMemoryCallback(function(a, v)
    S.nWrP0 = (S.nWrP0 or 0) + 1
    if v ~= S.last.spcOut0 then
      S.last.spcOut0 = v
      local st, f, mc = stamp()
      local pc = st["spc.pc"] & 0xFFFF
      if pc >= 0x0F89 and pc <= 0x0FD0 then S.nLoaderP0 = (S.nLoaderP0 or 0) + 1; return end
      ev(st, f, mc, string.format("SPC wr $F4 (P0 out) = %02X at spc.pc=%04X", v, pc))
    end
  end, emu.callbackType.write, 0xF4, 0xF4, SPC, SR)

  -- DSP register writes -----------------------------------------------------------------------------
  emu.addMemoryCallback(function(a, v)
    local r = emu.read(0xF2, SR)
    local name = DSPREGS[r]
    do -- any DSP register written by the resident loader ($0F89-$0FD0 = the IPL clone and its transfer loop)
      local pcw = emu.getState()["spc.pc"] & 0xFFFF
      if pcw >= 0x0F89 and pcw <= 0x0FD0 then cnt(string.format("DSP WRITE BY LOADER reg %02X", r)) end
    end
    if not name then return end
    cnt("dsp w " .. name)
    local old = S.last["dsp" .. r]
    if r == 0x4C then
      if v ~= 0 and o.logKon then
        local st, f, mc = stamp()
        ev(st, f, mc, string.format("DSP KON = %02X at spc.pc=%04X", v, st["spc.pc"] & 0xFFFF))
      end
      return
    end
    if r == 0x5C then
      -- the sequencer keys single voices off all the time (KOFF alternates between $0E and $46 in every main-loop pass); log only "all voices" ($FF)
      if v == 0xFF then
        S.koffFF = (S.koffFF or 0) + 1
        local st, f, mc = stamp()
        if S.koffLogged == nil or f - S.koffLogged >= 60 then
          S.koffLogged = f
          ev(st, f, mc, string.format("DSP KOFF = FF (all voices; repeated every main-loop pass while $0E = FF: next logged after 60 frames) at spc.pc=%04X", st["spc.pc"] & 0xFFFF))
        end
      end
      S.last["dsp" .. r] = v
      return
    end
    if v ~= old then
      S.last["dsp" .. r] = v
      local st, f, mc = stamp()
      ev(st, f, mc, string.format("DSP %s = %02X (was %s) at spc.pc=%04X", name, v, old and hex(old) or "--", st["spc.pc"] & 0xFFFF))
    end
  end, emu.callbackType.write, 0xF3, 0xF3, SPC, SR)

  -- CPU side: $2140-$2143 ---------------------------------------------------------------------------
  local function onApuW(a, v)
    local port = a & 3
    if port ~= 0 then cnt("cpu wP" .. port); return end
    local st, f, mc = stamp()
    local po = off24(st["cpu.k"], st["cpu.pc"])
    if po > XFER_LO and po <= XFER_HI + 4 then cnt("cpu wP0 xfer"); return end
    if po >= NMI_LO and po <= NMI_HI and v == 0 then cnt("cpu wP0 nmi zero"); return end
    ev(st, f, mc, string.format("CPU wr $2140 = %02X pc=%d", v, po))
  end
  local function onApuR(a, v)
    if v == S.last.cpuRd0 then return end
    if (a & 0xFFFF) ~= 0x2140 then return end
    do
      S.last.cpuRd0 = v
      local st, f, mc = stamp()
      local po = off24(st["cpu.k"], st["cpu.pc"])
      if po > XFER_LO and po <= XFER_HI + 4 then cnt("cpu rP0 xfer"); return end
      ev(st, f, mc, string.format("CPU rd $2140 = %02X pc=%d", v, po))
    end
  end
  for bank = 0, 0xFF do
    if bank <= 0x3F or (bank >= 0x80 and bank <= 0xBF) then
      emu.addMemoryCallback(onApuW, emu.callbackType.write, (bank << 16) | 0x2140, (bank << 16) | 0x2143, CPU, SM)
      emu.addMemoryCallback(onApuR, emu.callbackType.read, (bank << 16) | 0x2140, (bank << 16) | 0x2140, CPU, SM)
    end
  end

  -- CPU exec marks (prg offsets) -----------------------------------------------------------------------
  for name, off in pairs(o.atCount or {}) do
    emu.addMemoryCallback(function()
      cnt("cpu cnt " .. name)
      local stA = emu.getState()
      local f = stA["frameCount"]
      if o.atValue and o.atValue[name] then
        -- o.atValue = {Name = true}: tally the low byte of A at the mark (use a mark just after an LDA of a port)
        S.atVals = S.atVals or {}
        local key = name .. " A=" .. hex(stA["cpu.a"] & 0xFF)
        local ev0 = S.atVals[key]
        if ev0 == nil then S.atVals[key] = { n = 1, first = f, last = f } else ev0.n = ev0.n + 1; ev0.last = f end
      end
      S.atFrames = S.atFrames or {}
      local e = S.atFrames[name]
      if e == nil then S.atFrames[name] = { first = f, last = f, frames = 1 } else if f ~= e.last then e.frames = e.frames + 1 end; e.last = f end
    end, emu.callbackType.exec, off, off, CPU, PRG)
  end
  for name, off in pairs(o.at or {}) do
    emu.addMemoryCallback(function()
      cnt("cpu at " .. name)
      local st, f, mc = stamp()
      ev(st, f, mc, string.format("CPU AT %s sc=%02X", name, kit.r16(0x0644) & 0xFF))
    end, emu.callbackType.exec, off, off, CPU, PRG)
  end

  -- frame loop: sampling and driving ----------------------------------------------------------------------
  local n = 0
  local envx = {}
  kit.onFrame(function()
    n = n + 1
    local st, f, mc = stamp()
    if o.input then local b = o.input(n); if b ~= nil then gaia.hold(b) end end
    if o.tick then o.tick(n, S) end
    local sum, act = 0, 0
    for v = 0, 7 do local e = emu.read(v * 0x10 + 8, DSP); sum = sum + e; if e > 0 then act = act + 1 end end
    if S.rec then
      S.rows[#S.rows + 1] = { f = f, n = n, mc = mc, n36 = kit.r16(0x36), in0 = spcRam(0x00), r04 = spcRam(0x04), r08 = spcRam(0x08), r0E = spcRam(0x0E),
        r30 = spcRam(0x30), r31 = spcRam(0x31), mvl = emu.read(0x0C, DSP), mvr = emu.read(0x1C, DSP), evl = emu.read(0x2C, DSP),
        evr = emu.read(0x3C, DSP), flg = emu.read(0x6C, DSP), koff = emu.read(0x5C, DSP), envx = sum, act = act, sc = kit.r16(0x0644) & 0xFF,
        bgm = kit.r8(0x06F2), out0 = st["spc.outputReg[0]"], cpu0 = emu.read(0x2140, SM), cpc = ((st["cpu.k"] or 0) << 16) | (st["cpu.pc"] or 0), ml = S.counts["cpu cnt " .. (o.rowCountName or "LoadMusicFromTransitionState")] or 0, p2 = S.counts["cpu cnt HandshakePoll2"] or 0, pc = st["spc.pc"] & 0xFFFF }
    end
    if n >= o.frames and not S.finished then
      S.finished = true
      local ok, err = pcall(function()
        gaia.release()
        table.sort(S.ev, function(a, b) if a.mc ~= b.mc then return a.mc < b.mc end return a.seq < b.seq end)
        local mc0 = S.ev[1] and S.ev[1].mc or S.mc0 or mc
        local evLines, rowLines = {}, {}
        for _, e in ipairs(S.ev) do
          evLines[#evLines + 1] = string.format("EV f=%d t=%.3f n36=%d %s", e.f, (e.mc - mc0) / FRAME_CLOCKS, e.n36, e.text)
        end
        rowLines[1] = "f n n36 sc bgm | spc in0 04 08 0E 30 31 out0 pc cpuP0 | mainLoopPasses poll2 MVOLL MVOLR EVOLL EVOLR FLG KOFF | sumENVX voices   (one row per " .. (o.rowEvery or 4) .. " frames)"
        for i, r in ipairs(S.rows) do
          if (i - 1) % (o.rowEvery or 4) == 0 then
            rowLines[#rowLines + 1] = string.format("ROW %d %d %d %02X %02X | %02X %02X %02X %02X %02X %02X %02X %04X %02X | %02X %02X %02X %02X %02X %02X | %d %d | %d %d | %06X",
              r.f, r.n, r.n36, r.sc, r.bgm, r.in0, r.r04, r.r08, r.r0E, r.r30, r.r31, r.out0 or 0, r.pc, r.cpu0 or 0, r.mvl, r.mvr, r.evl, r.evr, r.flg, r.koff, r.envx, r.act, r.ml, r.p2, r.cpc)
          end
        end
        local bytes = 0
        local function put(file, lines)
          local chunk, size, first = {}, 0, true
          for _, line in ipairs(lines) do
            if bytes > 95000 then break end
            chunk[#chunk + 1] = line; size = size + #line + 1
            if size > 2800 then emu.mcp.writeFile(file, table.concat(chunk, "\n") .. "\n", not first); bytes, first, chunk, size = bytes + size, false, {}, 0 end
          end
          if #chunk > 0 then emu.mcp.writeFile(file, table.concat(chunk, "\n") .. "\n", not first); bytes = bytes + size end
        end
        if o.out then put(o.out, evLines); put(o.out:gsub("%.txt$", "") .. "_rows.txt", rowLines) end
        local show, shown = o.show or 40, {}
        for i = 1, math.min(show, #evLines) do shown[i] = evLines[i] end
        local res = { frames = n,
          control = { w36 = S.w36, nmi = S.nmi, spcSyncPort = S.counts["spc SyncPort"] or 0, spcRdP0 = S.nRdP0 or 0, spcWrP0 = S.nWrP0 or 0, loaderP0Changes = S.nLoaderP0 or 0, evTotal = S.nev,
                      evKept = #S.ev, evDropped = S.dropped, rows = #S.rows, file = o.out, fileBytes = bytes },
          counts = S.counts, events = shown }
        res.atFrames = S.atFrames; res.atVals = S.atVals
        if o.final then res.final = o.final(S) end
        kit.finish(res)
      end)
      if not ok then emu.log("d2 finish error: " .. tostring(err)); kit.finish({ error = tostring(err) }) end
    end
  end)
end
