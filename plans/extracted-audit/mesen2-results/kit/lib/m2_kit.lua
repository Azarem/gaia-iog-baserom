-- description: M2 title / boot / diary experiments: boot recorder (persistent), raw joypad read callback, per-button sweep, exec marks with frame and $36.
-- requires: mesen_kit, iog_kit, gaia_kit, m1_kit
--
-- Callbacks run BEFORE the access / instruction; a memory callback reports the PC AFTER the accessing instruction (ROM offset = the decimal `; {n}` tag of extract:lt, O ROM).
-- Frames: m2.f() is the emulator frame count; n36 is WRAM $36 (the NMI frame counter, INC $36 once per NMI).
--
--   m2.boot{ frames=N, marks={Name=off,...}, nmi=33528, out="M2_boot_O.txt", palettes={0,1,2,3,4}, tag="O" }
--       persistent recorder: change rows (frame relative to load, $36, scene, next, brightness, forced blank, main layers, OBJ-palette hashes, OAM on-screen count),
--       exec marks (first 8 hits: frame, $36), positive controls (NMI exec, $36 write count). At frame N it writes `out` (all rows) and publishes the summary with emu.mcp.result.
--   m2.rawpad()                                  installs read callbacks on $4218/$4219 (all 128 bank aliases): m2.raw = {lo, hi, n}
--   m2.sweepRun{ btns={"b","a",...}, hold=8, rel=5, tag="", fx=function() -> string, out="M2_x.txt", pre=0 }
--       m1.run driver: for each button, hold `hold` frames, release `rel` frames; per frame it samples raw ($4218/9), $065E, $0656, $0660, $0658, $065A and the fx() string;
--       it logs one row per button with the values of the LAST hold frame, plus the set of distinct fx strings seen (hold + release).
m2 = m2 or {}

local WR  = emu.memType.snesWorkRam
local P   = emu.memType.snesPrgRom
local SM  = emu.memType.snesMemory
local CG  = emu.memType.snesCgRam
local OAM = emu.memType.snesSpriteRam
local CPU = emu.cpuType.snes

function m2.f() return emu.getState()["frameCount"] end
local function hx(v, w) return string.format("%0" .. (w or 4) .. "X", v & 0xFFFFFFFF) end

-- decimal ROM offset marks ----------------------------------------------------------------------
function m2.marks(map, cap, S)
  S = S or {}
  S.marks = S.marks or {}
  for name, off in pairs(map or {}) do
    local e = { n = 0, rows = {} }
    S.marks[name] = e
    emu.addMemoryCallback(function()
      e.n = e.n + 1
      if #e.rows < (cap or 8) then e.rows[#e.rows + 1] = { m2.f(), kit.r16(0x36), S.nmi or 0 } end
    end, emu.callbackType.exec, off, off, CPU, P)
  end
  return S
end

-- boot recorder ----------------------------------------------------------------------------------
function m2.boot(o)
  local f0 = m2.f()
  local S = { f0 = f0, nmi = 0, w36 = 0, rows = {}, done = false }
  m2.marks(o.marks, 8, S)
  emu.addMemoryCallback(function() S.nmi = S.nmi + 1 end, emu.callbackType.exec, o.nmi, o.nmi, CPU, P)
  emu.addMemoryCallback(function(a) if (a & 0xFFFF) == 0x36 then S.w36 = S.w36 + 1 end end, emu.callbackType.write, 0x36, 0x36, CPU, WR)
  local pals = o.palettes or { 0, 1, 2, 3, 4 }
  local last = ""
  local function palHash(p)
    local s = 0
    for i = 0, 31 do s = (s * 31 + emu.read(256 + p * 32 + i, CG)) & 0xFFFFFFF end
    return s
  end
  local function oamOn()
    local n = 0
    for i = 0, 127 do
      local y = emu.read(i * 4 + 1, OAM)
      if y < 224 then n = n + 1 end
    end
    return n
  end
  local function writeRows()
    local buf, first, size = {}, true, 0
    local function flush()
      if #buf > 0 then emu.mcp.writeFile(o.out, table.concat(buf, "\n") .. "\n", not first); first = false; buf = {}; size = 0 end
    end
    for _, l in ipairs(S.rows) do
      buf[#buf + 1] = l; size = size + #l + 1
      if size > 2500 then flush() end
    end
    flush()
  end
  kit.onFrame(function()
    if S.done then return end
    local st = emu.getState()
    local rel = st["frameCount"] - f0
    local ph = {}
    for _, p in ipairs(pals) do ph[#ph + 1] = hx(palHash(p), 7) end
    local key = string.format("scene=%04X next=%04X bright=%d forced=%d main=%02X nOam=%d f10=%d pal[%s]=%s", kit.r16(0x0644), kit.r16(0x0642),
      st["ppu.screenBrightness"], st["ppu.forcedBlank"] and 1 or 0, st["ppu.mainScreenLayers"] & 0xFF, oamOn(), kit.r8(0x0A02) & 1,
      table.concat(pals, ","), table.concat(ph, " "))
    if key ~= last then
      last = key
      S.rows[#S.rows + 1] = string.format("f=%d n36=%d %s", rel, kit.r16(0x36), key)
    end
    if rel >= o.frames then
      S.done = true
      writeRows()
      local res = { f0 = f0, frames = rel, nmi = S.nmi, w36 = S.w36, nrows = #S.rows, marks = {} }
      for name, e in pairs(S.marks) do
        local rr = {}
        for _, r in ipairs(e.rows) do rr[#rr + 1] = r[1] .. ":" .. r[2] .. ":" .. r[3] end
        res.marks[name] = { n = e.n, hits = table.concat(rr, ",") }
      end
      emu.mcp.result(res)
    end
  end)
  return S
end

-- raw joypad ---------------------------------------------------------------------------------------
function m2.rawpad()
  m2.raw = { lo = 0, hi = 0, n = 0 }
  local function cb(a, v)
    local x = a & 0xFFFF
    if x == 0x4218 then m2.raw.lo = v elseif x == 0x4219 then m2.raw.hi = v end
    m2.raw.n = m2.raw.n + 1
  end
  for bank = 0, 0xFF do
    if bank < 0x40 or (bank >= 0x80 and bank < 0xC0) then
      local b = bank << 16
      emu.addMemoryCallback(cb, emu.callbackType.read, b | 0x4218, b | 0x4219, CPU, SM)
    end
  end
end

-- per-button sweep ---------------------------------------------------------------------------------
function m2.sweepRun(o)
  m2.rawpad()
  local out = {}
  local btns = o.btns
  local fx = o.fx or function() return "" end
  local samples = {}
  kit.onFrame(function()
    samples[#samples + 1] = {
      raw = (m2.raw.hi << 8) | m2.raw.lo, j5E = kit.r16(0x065E), j56 = kit.r16(0x0656), j60 = kit.r16(0x0660), j58 = kit.r16(0x0658),
      j5A = kit.r16(0x065A), fx = fx(),
    }
  end)
  m1.run(function(m)
    m.wait(o.pre or 2)
    for _, b in ipairs(btns) do
      samples = {}
      gaia.hold({ b })
      m.wait(o.hold or 8)
      local nh = #samples
      gaia.release()
      m.wait(o.rel or 5)
      local s = samples[nh] or samples[#samples]
      local seen, order = {}, {}
      for _, x in ipairs(samples) do
        if not seen[x.fx] then seen[x.fx] = true; order[#order + 1] = x.fx end
      end
      local maxj56, anyj56 = 0, {}
      for i = 1, nh do anyj56[#anyj56 + 1] = hx(samples[i].j56) end
      local row = string.format("%s btn=%s raw=%s | $065E=%s $0656=%s $0660=%s $0658=%s $065A=%s | fxLast=%s | fxSeq=%s | j56seq=%s", o.tag or "", b, hx(s.raw), hx(s.j5E), hx(s.j56),
        hx(s.j60), hx(s.j58), hx(s.j5A), s.fx, table.concat(order, " > "), table.concat(anyj56, ","))
      m.log(row)
      out[#out + 1] = { b = b, raw = hx(s.raw), j5E = hx(s.j5E), j56 = hx(s.j56), j60 = hx(s.j60), j58 = hx(s.j58), j5A = hx(s.j5A), fxLast = s.fx, fxSeq = table.concat(order, " > "), j56seq = table.concat(anyj56, ",") }
    end
    return { rows = out, rawReads = m2.raw.n }
  end, { out = o.out or "M2_sweep.txt", maxFrames = (o.pre or 2) + #btns * ((o.hold or 8) + (o.rel or 5) + 3) + 50 })
end

-- diary watch (OQ-I057-6) --------------------------------------------------------------------------------
--   m2.diaryWatch{ marks={Name=off,...}, slot=0x1000 }
--   Persistent: logs (frame, $36, PC after the access, value) for accesses of $0D94 (read / write), writes of $0DAA / $0DAE (remapB / remapY), writes of the diary actor's $1A / $1C
--   (slot + $1A .. $1D) and exec marks (with $1A / $1C / $0D94 at the hit). Publishes the row list with emu.mcp.result whenever it changed (<= 400 rows).
function m2.diaryWatch(o)
  local S = { rows = {}, dirty = false }
  local slot = o.slot or 0x1000
  local function add(fmt, ...)
    if #S.rows < 400 then
      local st = emu.getState()
      S.rows[#S.rows + 1] = string.format("f%d n%d pc=%02X%04X ", st["frameCount"], kit.r16(0x36), st["cpu.k"], st["cpu.pc"]) .. string.format(fmt, ...)
      S.dirty = true
    end
  end
  local function range(kind, lo, hi, label)
    emu.addMemoryCallback(function(a, v) add("%s %s %04X val=%02X", kind, label, a & 0xFFFF, v & 0xFF) end,
      kind == "R" and emu.callbackType.read or emu.callbackType.write, lo, hi, CPU, WR)
  end
  range("R", 0x0D94, 0x0D95, "$0D94")
  range("W", 0x0D94, 0x0D95, "$0D94")
  range("W", 0x0D96, 0x0D97, "$0D96")
  range("W", 0x0D92, 0x0D93, "$0D92")
  range("W", 0x0DAA, 0x0DAB, "remapB")
  range("W", 0x0DAE, 0x0DAF, "remapY")
  range("W", slot + 0x1A, slot + 0x1B, "actor$1A")
  range("W", slot + 0x1C, slot + 0x1D, "actor$1C")
  -- readers of the diary actor's $18 / $1A / $1C / $1E: counted per (field, PC after the read), first / last frame
  S.rd = {}
  for _, f in ipairs({ 0x18, 0x1A, 0x1C, 0x1E }) do
    emu.addMemoryCallback(function(a, v)
      local st = emu.getState()
      local key = string.format("$%02X pc=%02X%04X", f, st["cpu.k"], st["cpu.pc"])
      local e = S.rd[key]
      if not e then e = { n = 0, first = st["frameCount"], vals = {} }; S.rd[key] = e; S.dirty = true end
      e.n = e.n + 1; e.last = st["frameCount"]
      local vk = string.format("%02X", v & 0xFF)
      if not e.vals[vk] and #vk > 0 then e.vals[vk] = true end
    end, emu.callbackType.read, slot + f, slot + f, CPU, WR)
  end
  for name, off in pairs(o.marks or {}) do
    emu.addMemoryCallback(function()
      add("EXEC %s | $1A=%04X $1C=%04X $0D94=%04X $0D92=%04X remapB=%04X remapY=%04X", name, kit.r16(slot + 0x1A), kit.r16(slot + 0x1C), kit.r16(0x0D94), kit.r16(0x0D92),
        kit.r16(0x0DAA), kit.r16(0x0DAE))
    end, emu.callbackType.exec, off, off, CPU, P)
  end
  emu.addMemoryCallback(function(a) if (a & 0xFFFF) == 0x36 then S.w36 = (S.w36 or 0) + 1 end end, emu.callbackType.write, 0x36, 0x36, CPU, WR)
  kit.onFrame(function()
    if S.dirty then
      S.dirty = false
      local rd = {}
      for k, e in pairs(S.rd) do
        local vs = {}
        for v in pairs(e.vals) do vs[#vs + 1] = v end
        table.sort(vs)
        rd[#rd + 1] = string.format("%s n=%d first=%d last=%d lowbyte-values=%s", k, e.n, e.first, e.last or e.first, table.concat(vs, ","))
      end
      table.sort(rd)
      emu.mcp.result({ rows = S.rows, w36 = S.w36, readers = rd })
    end
  end)
  return S
end

-- exec counts (flicker trace) -----------------------------------------------------------------------------
--   m2.execCount{ marks={Name=romOffset,...}, parityMark=Name, frames=n }
--   Counts the exec hits of every mark; for parityMark it also records the low bit of $36 at each hit. Publishes { counts, parity } after `frames` frames.
function m2.execCount(o)
  local c, par, n = {}, {}, 0
  for name, off in pairs(o.marks) do
    emu.addMemoryCallback(function()
      c[name] = (c[name] or 0) + 1
      if name == o.parityMark then par[#par + 1] = kit.r16(0x36) & 1 end
    end, emu.callbackType.exec, off, off, CPU, P)
  end
  kit.onFrame(function()
    n = n + 1
    if n == o.frames then emu.mcp.result({ counts = c, parity = table.concat(par, "") }) end
  end)
end
