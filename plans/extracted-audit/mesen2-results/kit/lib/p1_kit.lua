-- description: P1 input and facing: run-window trials ($040C), in-game button sweep with effect marks, GetPlayerFacingDirection forced-table probe, escort facing probe.
-- requires: mesen_kit, iog_kit, gaia_kit, m1_kit, m2_kit
--
-- Callbacks run BEFORE the access / instruction; a memory callback reports the PC AFTER the accessing instruction.
-- Exec marks use ROM FILE OFFSETS (O: the decimal `; {n}` tag of extract:lt; R: label offset from artifacts/master-lookup.json + the delta of the block).
-- Frames: m1.t counts end-of-frame callbacks of the run (one per emulator frame). A press at the end of frame k is seen by the game in frame k+1.
--
--   p1.mark(name, off, extra)             exec mark: appends {t, n, w=$040C, n36, a, ps} to p1.ev (when non-nil) and counts p1.cnt[name]
--   p1.windowTrial(m, dir, h1, r, h2, tail)  one trial: hold dir h1 frames, release r frames, hold h2 frames, release tail frames; returns a row table
--   p1.windowSweep(m, o)                  o = {dirs={"right","left"}, rs={1..20}, h1=3, h2=6}; logs one row per trial
--   p1.btnFx()                            effect string for the button sweep (entry word, bank, mark counters, scene, mask)
--   p1.facingProbe(o)                     forced-table probe of GetPlayerFacingDirection (see below)
p1 = p1 or {}

local WR  = emu.memType.snesWorkRam
local P   = emu.memType.snesPrgRom
local CPU = emu.cpuType.snes

p1.ev  = nil
p1.cnt = {}

local function s16(a) local v = kit.r16(a); if v >= 0x8000 then v = v - 0x10000 end; return v end
local function hx(v, w) return string.format("%0" .. (w or 4) .. "X", v & 0xFFFFFFFF) end

function p1.mark(name, off, fn)
  p1.cnt[name] = 0
  emu.addMemoryCallback(function()
    p1.cnt[name] = p1.cnt[name] + 1
    local st = emu.getState()
    if p1.ev then
      p1.ev[#p1.ev + 1] = { t = m1.t, n = name, w = kit.r16(0x040C), n36 = kit.r16(0x36), a = st["cpu.a"], ps = st["cpu.ps"] }
    end
    if fn then fn(st) end
  end, emu.callbackType.exec, off, off, CPU, P)
end

-- run-window trial -------------------------------------------------------------------------------------------
-- Rows: dir h1 r h2 | events (t:name:$040C-before-the-instruction) | E = number of walk entries, d = frames between the first two entries,
-- w2 = $040C at the second entry, run = 1 when the run-start STZ executed, sp = signed speed words after the second hold.
function p1.windowTrial(m, dir, h1, r, h2, tail, dir2)
  p1.ev = {}
  local t0 = m1.t
  gaia.hold({ dir }); m.wait(h1); gaia.release(); m.wait(r)
  gaia.hold({ dir2 or dir }); m.wait(h2)
  local sp = string.format("%d,%d", s16(0x09B2), s16(0x09B4))
  gaia.release(); m.wait(tail)
  local ev = p1.ev; p1.ev = nil
  local entries, runs, parts = {}, 0, {}
  local runT
  for _, e in ipairs(ev) do
    parts[#parts + 1] = string.format("%d:%s:%04X", e.t - t0, e.n, e.w)
    if e.n:sub(1, 4) == "Walk" then entries[#entries + 1] = e end
    if e.n:sub(1, 3) == "Run" then runs = runs + 1; runT = runT or (e.t - t0) end
  end
  local row = { dir = dir, h1 = h1, r = r, h2 = h2, E = #entries, run = runs > 0 and 1 or 0, sp = sp }
  if #entries >= 2 then row.d = entries[2].t - entries[1].t; row.w2 = entries[2].w end
  m.log("%s%s h1=%d r=%d h2=%d | E=%d d=%s w2=%s run=%d runT=%s sp=%s | %s", dir, dir2 and ("->" .. dir2) or "", h1, r, h2, row.E,
    tostring(row.d), row.w2 and hx(row.w2) or "-", row.run, tostring(runT), sp, table.concat(parts, " "))
  return row
end

local function settle(m)
  local k = 0
  while (kit.r16(0x040C) < 0x8000 or kit.r16(0x09B2) ~= 0 or kit.r16(0x09B4) ~= 0) and k < 100 do m.wait(1); k = k + 1 end
  m.wait(6)
  return k
end

p1.settle = settle

function p1.windowSweep(m, o)
  local rows = {}
  for _, r in ipairs(o.rs) do
    for _, d in ipairs(o.dirs) do
      settle(m)
      rows[#rows + 1] = p1.windowTrial(m, d, o.h1 or 3, r, o.h2 or 6, o.tail or 20)
    end
  end
  return rows
end

-- first press from standing: the window must be closed; hold dir `h` frames; no second press
function p1.firstPress(m, dir, h)
  settle(m)
  p1.ev = {}
  local t0 = m1.t
  local w0 = kit.r16(0x040C)
  gaia.hold({ dir }); m.wait(h); gaia.release(); m.wait(25)
  local ev = p1.ev; p1.ev = nil
  local parts, run = {}, 0
  for _, e in ipairs(ev) do
    parts[#parts + 1] = string.format("%d:%s:%04X", e.t - t0, e.n, e.w)
    if e.n:sub(1, 3) == "Run" then run = run + 1 end
  end
  m.log("FIRST %s h=%d $040C-before=%04X run=%d | %s", dir, h, w0, run, table.concat(parts, " "))
  return { dir = dir, h = h, w0 = w0, run = run }
end

-- button sweep effect string ---------------------------------------------------------------------------------
function p1.btnFx()
  local c = p1.cnt
  return string.format("ent=%04X:%02X sc=%02X mask=%04X eq=%04X att=%d use=%d talk=%d snap=%d defer=%d", kit.r16(0x1000), kit.r8(0x1002), kit.r8(0x0644),
    kit.r16(0x065A), kit.r16(0x0AC4), c.attack or 0, c.itemUse or 0, c.talkIn or 0, c.talkSnap or 0, c.talkDefer or 0)
end

-- classification of a ROM offset in the facing data block (O offsets; pass o.layout for another ROM) ----------------------
local function classify(L, off)
  if off >= L.lookup and off < L.lookup + 88 then return "Lookup+" .. (off - L.lookup) end
  if off >= L.fot and off < L.fot + 8 then return "FormOffsetTable+" .. (off - L.fot) end
  local names = { "WillAbilities", "TransformPoses", "FreedanFx", "ShadowFx" }
  for i = 1, 4 do
    if off >= L.data[i] and off < L.data[i] + L.len[i] then return names[i] .. "+" .. (off - L.data[i]) end
  end
  if off >= L.endBlock then return "past-block+" .. (off - L.endBlock) end
  return "other+" .. off
end
p1.classify = classify

-- forced-table probe -----------------------------------------------------------------------------------------
-- p1.facingProbe{ L = layout, plan = { {n=, f=, bit15=true|false}, ... } }
-- The entry mark of GetPlayerFacingDirection (L.entry) writes, for the next call of the plan, playerFlags bit 15 ($09AE), $0AC8 = n and the player
-- actor's frame word $1028 = f; the RTL marks (L.ret) restore the three words and record the result: the table pointer loaded (L.tbl mark),
-- the data offset read (L.data mark), the returned A (low byte) and carry. Every call is also recorded with its caller (return address on the stack).
-- Result rows: S.rows[i] = {n, f, bit15, ptrOff, dataOff, byte, A, C, caller, path}. S.calls counts all entries, S.forced the planned ones.
function p1.facingProbe(o)
  local L = o.L
  local S = { calls = 0, forced = 0, idx = 1, plan = o.plan, rows = {}, cur = nil, marks = {}, natural = {} }
  local function rd(off) return emu.read(off, P) end
  emu.addMemoryCallback(function()
    S.calls = S.calls + 1
    local st = emu.getState()
    local sp = st["cpu.sp"]
    local caller = string.format("%02X:%04X", emu.read(sp + 3, emu.memType.snesWorkRam) & 0xFF, (emu.read16(sp + 1, emu.memType.snesWorkRam) + 1) & 0xFFFF)
    S.cur = { caller = caller, path = "", ptrOff = nil, dataOff = nil, byte = nil }
    if S.idx <= #S.plan and (o.onlyCaller == nil or o.onlyCaller == caller) then
      local pl = S.plan[S.idx]
      S.cur.saved = { pf = kit.r16(0x09AE), r8 = kit.r16(0x0AC8), fr = kit.r16(0x1028) }
      local pf = S.cur.saved.pf
      if pl.bit15 then pf = pf | 0x8000 else pf = pf & 0x7FFF end
      kit.w16(0x09AE, pf); kit.w16(0x0AC8, pl.n); kit.w16(0x1028, pl.f)
      S.cur.n, S.cur.f, S.cur.bit15 = pl.n, pl.f, pl.bit15
      S.forced = S.forced + 1
    end
  end, emu.callbackType.exec, L.entry, L.entry, CPU, P)

  local function mk(off, label, fn) emu.addMemoryCallback(function() if S.cur then fn(emu.getState()) end; S.marks[label] = (S.marks[label] or 0) + 1 end, emu.callbackType.exec, off, off, CPU, P) end
  mk(L.fallback, "fallback", function() S.cur.path = S.cur.path .. "F" end)
  mk(L.override, "override", function() S.cur.path = S.cur.path .. "O" end)
  mk(L.tbl, "tblLoad", function(st)
    local x = st["cpu.x"] & 0xFFFF
    local off = L.fot + x
    S.cur.xTbl = x
    S.cur.ptr = rd(off) | (rd(off + 1) << 8)
  end)
  mk(L.dataLoad, "dataLoad", function(st)
    local x = st["cpu.x"] & 0xFFFF
    S.cur.dataOff = L.fot + x
    S.cur.byte = rd(S.cur.dataOff)
  end)
  local function ret(label)
    mk(L.ret[label], label, function(st)
      local c = S.cur
      if c.saved then
        kit.w16(0x09AE, c.saved.pf); kit.w16(0x0AC8, c.saved.r8); kit.w16(0x1028, c.saved.fr)
        local row = { n = c.n, f = c.f, bit15 = c.bit15, ptr = c.ptr, xTbl = c.xTbl, dataOff = c.dataOff, byte = c.byte, A = st["cpu.a"] & 0xFF,
                      C = st["cpu.ps"] & 1, caller = c.caller, path = c.path, ret = label }
        S.rows[#S.rows + 1] = row
        S.idx = S.idx + 1
      else
        S.natural[c.caller] = (S.natural[c.caller] or 0) + 1
      end
      S.cur = nil
    end)
  end
  for lab in pairs(L.ret) do ret(lab) end
  return S
end
