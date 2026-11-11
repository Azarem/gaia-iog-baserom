-- description: D1 APU port log: writes to $2140-$2143 on every bank alias, the sfx queue ($06F8/$06F9), the BGM id ($06F2), the music staging word ($06FA), exec marks, scene changes.
-- requires: mesen_kit, iog_kit, gaia_kit
--
-- run_script {includes={"gaia_kit","d1_apu"}, code='d1.run{frames=N, nmi=33528, input=function(n) ... end, tick=function(n,S) ... end, at={Name=prgOffset}}'}
--
-- Callbacks run BEFORE the access; the PC a memory callback reports is the address AFTER the accessing instruction.
-- Offsets are decimal PRG (ROM file) offsets of the O ROM: off = ((bank & 0x3F) << 16) | pc16.
--
--   control : $36 write count (INC $36 in the NMI), NMI exec count (snesPrgRom, o.nmi), frames
--   ports   : writes to $2140-$2143 at all 128 bank aliases ($00-$3F, $80-$BF).
--             * PCs inside the spc_transfer routines (XFER range) are bulk upload traffic: counted by (port, PC), never logged
--             * the NMI write of the sfx word (APUIO2 low byte, APUIO3 high byte): value 0 is counted only; a nonzero value is logged
--             * everything else is logged in order (frame, $36, port, value, PC offset, scene, $06F2)
--   queue   : writes to $06F8 / $06F9 (sfxQueueCh1 / Ch2) with a nonzero value (the NMI's STZ is a zero write and is only counted)
--   bgm     : writes to $06F2 (musicParentActor: the BGM id stored by SpcMusicLoadCmd) and $06FA/$06FB (musicTransitionState)
--   at      : exec marks {Name = offset}: logged with frame and $36 (use for rare routines); atCount = {Name = offset}: counted only
--   xfer    : at every SpcBlockTransfer entry (168091) the 24-bit source pointer $46-$48 and the staged id $06FA are logged
--   scene   : a change of $0644 is logged with $06F2
--   reads   : o.reads2141 logs a change of the value read from $2141 (APUIO1); o.readsByPc also counts the reads per PC outside the transfer
--             range (counts["rd2141 pc=N"]) and keeps the first and last frame per PC in S.rdFrames (return it from o.final)
--   output  : o.out = file name under <results>/raw (full event list + aggregated rows), o.show / o.showRows = rows returned inline,
--             identical consecutive event lines are collapsed (control.collapsedRepeats)
d1 = d1 or {}

local WR  = emu.memType.snesWorkRam
local SM  = emu.memType.snesMemory
local PRG = emu.memType.snesPrgRom
local CPU = emu.cpuType.snes

local XFER_LO, XFER_HI = 168078, 168463     -- spc_transfer.asm: SpcLoadBuiltinEngine .. end of SpcSendRecord
local NMI_LO,  NMI_HI  = 33528, 33670       -- NmiHandler (INC $36 is the instruction at 33663)
local SPC_BLOCK_TRANSFER = 168091

local function hex(v, w) return string.format("%0" .. (w or 2) .. "X", v) end
local function off24(k, pc) return ((k & 0x3F) << 16) | (pc & 0xFFFF) end

function d1.run(o)
  local S = { w36 = 0, nmi = 0, ev = {}, nev = 0, agg = {}, nzero = { [0] = 0, 0, 0, 0 }, apu = 0, last2141 = nil, reads2141 = 0,
              counts = {}, lastScene = nil }
  local maxEv = o.maxEv or 500
  local xlo, xhi = o.xlo or XFER_LO, o.xhi or XFER_HI

  local function scene() return kit.r16(0x0644) end
  local lastEv = nil
  local function ev(s)
    -- consecutive identical rows (same text) are collapsed and counted in S.dups
    if s == lastEv then S.dups = (S.dups or 0) + 1; return end
    lastEv = s
    S.nev = S.nev + 1
    if #S.ev < maxEv then S.ev[#S.ev + 1] = s end
  end
  local function frame() return emu.getState()["frameCount"] end
  local function tag(f) return string.format("f=%d n36=%d sc=%02X bgm=%02X", f, kit.r16(0x36), scene(), kit.r8(0x06F2)) end

  -- controls ------------------------------------------------------------------------------------
  emu.addMemoryCallback(function() S.nmi = S.nmi + 1 end, emu.callbackType.exec, o.nmi, o.nmi, CPU, PRG)
  emu.addMemoryCallback(function(a) if (a & 0xFFFF) == 0x36 then S.w36 = S.w36 + 1 end end,
    emu.callbackType.write, 0x36, 0x36, CPU, WR)

  local function agg(key, f, extra)
    local e = S.agg[key]
    if not e then e = { n = 0, first = f, sc = scene() }; for k2, v2 in pairs(extra or {}) do e[k2] = v2 end; S.agg[key] = e end
    e.n = e.n + 1
    e.last = f
  end

  -- APU ports on every bank alias ---------------------------------------------------------------
  local function onApu(a, v)
    local port = a & 3
    local st = emu.getState()
    local po = off24(st["cpu.k"], st["cpu.pc"])
    local f = st["frameCount"]
    S.apu = S.apu + 1
    if po > xlo and po <= xhi + 4 then
      agg("XFER P" .. port .. " pc=" .. po, f, { pc = po, port = port })
      return
    end
    if po >= NMI_LO and po <= NMI_HI and v == 0 then
      S.nzero[port] = S.nzero[port] + 1
      return
    end
    local ctx = (po >= NMI_LO and po <= NMI_HI) and "NMI" or "ctl"
    ev(string.format("APU P%d=%02X pc=%d %s %s", port, v, po, ctx, tag(f)))
    agg(ctx .. " P" .. port .. " v=" .. hex(v) .. " pc=" .. po, f, { pc = po, port = port, v = v })
  end
  for bank = 0, 0xFF do
    if bank <= 0x3F or (bank >= 0x80 and bank <= 0xBF) then
      emu.addMemoryCallback(onApu, emu.callbackType.write, (bank << 16) | 0x2140, (bank << 16) | 0x2143, CPU, SM)
      if o.reads2141 then
        emu.addMemoryCallback(function(a, v)
          if (a & 0xFFFF) ~= 0x2141 then return end
          S.reads2141 = S.reads2141 + 1
          if o.readsByPc then
            local st0 = emu.getState()
            local po0 = off24(st0["cpu.k"], st0["cpu.pc"])
            if po0 < xlo or po0 > xhi + 4 then
              local key = "rd2141 pc=" .. po0
              S.counts[key] = (S.counts[key] or 0) + 1
              S.rdFrames = S.rdFrames or {}
              local fr = st0["frameCount"]
              if S.rdFrames[key] == nil then S.rdFrames[key] = { first = fr, last = fr } else S.rdFrames[key].last = fr end
            end
          end
          if v ~= S.last2141 then
            S.last2141 = v
            local st = emu.getState()
            ev(string.format("RD $2141=%02X pc=%d %s", v, off24(st["cpu.k"], st["cpu.pc"]), tag(st["frameCount"])))
          end
        end, emu.callbackType.read, (bank << 16) | 0x2141, (bank << 16) | 0x2141, CPU, SM)
      end
    end
  end

  -- WRAM watches ---------------------------------------------------------------------------------
  local function wr(name, lo, hi, logZero)
    emu.addMemoryCallback(function(a, v)
      local w = a & 0xFFFF
      if w < lo or w > hi then return end
      local st = emu.getState()
      local po = off24(st["cpu.k"], st["cpu.pc"])
      local f = st["frameCount"]
      S.counts[name .. " w"] = (S.counts[name .. " w"] or 0) + 1
      if v ~= 0 or logZero then
        ev(string.format("WR %s[%04X]=%02X pc=%d %s", name, w, v, po, tag(f)))
        agg("WR " .. name .. " v=" .. hex(v) .. " pc=" .. po, f, { pc = po, v = v })
      else
        S.counts[name .. " w0"] = (S.counts[name .. " w0"] or 0) + 1
      end
    end, emu.callbackType.write, lo, hi, CPU, WR)
  end
  wr("sfxQ", 0x06F8, 0x06F9, false)
  wr("bgm", 0x06F2, 0x06F2, true)
  wr("xit", 0x06FA, 0x06FB, true)
  for _, w in ipairs(o.watch or {}) do wr(w.name, w.lo, w.hi, w.logZero) end

  -- exec marks ------------------------------------------------------------------------------------
  for name, off in pairs(o.at or {}) do
    emu.addMemoryCallback(function()
      S.counts["at " .. name] = (S.counts["at " .. name] or 0) + 1
      ev("AT " .. name .. " " .. tag(frame()))
    end, emu.callbackType.exec, off, off, CPU, PRG)
  end
  for name, off in pairs(o.atCount or {}) do
    emu.addMemoryCallback(function() S.counts["cnt " .. name] = (S.counts["cnt " .. name] or 0) + 1 end,
      emu.callbackType.exec, off, off, CPU, PRG)
  end

  -- SpcBlockTransfer entry: source pointer $46-$48 (DP of the caller) and the staged id --------------
  emu.addMemoryCallback(function()
    local st = emu.getState()
    local d = st["cpu.d"]
    local lo, hi, bk = emu.read(d + 0x46, WR), emu.read(d + 0x47, WR), emu.read(d + 0x48, WR)
    local src = off24(bk, (hi << 8) | lo)
    S.counts["xfer"] = (S.counts["xfer"] or 0) + 1
    ev(string.format("XFER src=%02X:%02X%02X off=%d id06FA=%04X d=%04X %s", bk, hi, lo, src, kit.r16(0x06FA), d, tag(st["frameCount"])))
  end, emu.callbackType.exec, SPC_BLOCK_TRANSFER, SPC_BLOCK_TRANSFER, CPU, PRG)

  -- frame loop --------------------------------------------------------------------------------------
  local n = 0
  kit.onFrame(function()
    n = n + 1
    local sc = scene()
    if S.lastScene ~= sc then
      if S.lastScene ~= nil then ev(string.format("SCENE %02X->%02X bgm=%02X n=%d f36=%d", S.lastScene, sc, kit.r8(0x06F2), n, kit.r16(0x36))) end
      S.lastScene = sc
    end
    if o.input then
      local b = o.input(n)
      if b ~= nil then gaia.hold(b) end
    end
    if o.tick then o.tick(n, S) end
    if n >= o.frames then
      gaia.release()
      local rows = {}
      for key, e in pairs(S.agg) do rows[#rows + 1] = { key = key, n = e.n, first = e.first, last = e.last, scene = e.sc } end
      table.sort(rows, function(x, y) if x.first ~= y.first then return x.first < y.first end return x.key < y.key end)
      -- the full event list goes to <results>/<o.out> in chunks of at most 3,000 bytes (script output cap 100,000 bytes);
      -- the result carries only the first o.show events (default 40) and the first o.showRows rows (default 40)
      local fileBytes = 0
      if o.out then
        local chunk, size, first = {}, 0, true
        local lines = {}
        for _, line in ipairs(S.ev) do lines[#lines + 1] = line end
        lines[#lines + 1] = "--- aggregated rows (first, last, n, scene, key)"
        for _, r in ipairs(rows) do lines[#lines + 1] = string.format("ROW %d %d %d %02X %s", r.first, r.last or r.first, r.n, r.scene, r.key) end
        for _, line in ipairs(lines) do
          chunk[#chunk + 1] = line
          size = size + #line + 1
          if size > 2800 then
            emu.mcp.writeFile(o.out, table.concat(chunk, "\n") .. "\n", not first)
            fileBytes, first, chunk, size = fileBytes + size, false, {}, 0
          end
        end
        if #chunk > 0 then emu.mcp.writeFile(o.out, table.concat(chunk, "\n") .. "\n", not first); fileBytes = fileBytes + size end
      end
      local show, shown = o.show or 40, {}
      for i = 1, math.min(show, #S.ev) do shown[i] = S.ev[i] end
      local showRows, rr = o.showRows or 40, {}
      for i = 1, math.min(showRows, #rows) do rr[i] = rows[i] end
      S.counts["reads2141"] = S.reads2141
      local res = {
        frames = n,
        control = { w36Writes = S.w36, nmiExec = S.nmi, apuWrites = S.apu, nmiZeroWrites = S.nzero, evTotal = S.nev, evKept = #S.ev,
                    collapsedRepeats = S.dups or 0, file = o.out, fileBytes = fileBytes },
        counts = S.counts, rows = rr, nRows = #rows, events = shown,
      }
      if o.final then res.final = o.final(S) end
      kit.finish(res)
    end
  end)
end
