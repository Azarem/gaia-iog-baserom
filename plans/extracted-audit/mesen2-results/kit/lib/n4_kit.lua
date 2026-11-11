-- description: N4 COP semantic probes: exec hooks that record the NMI frame of each hit, run-length formatting, ROM byte patch with a log, snapshot of an actor slot.
-- requires: mesen_kit, iog_kit, gaia_kit, m1_kit, n1_kit
--
--   n4.hook(off, name, fn)    exec callback on ROM offset `off` (decimal, file offset); records c.n, c.frames (NMI frames = $36 low word at each hit, max 4000) and calls fn(c, st) with emu.getState()
--   n4.runs(list)             "a-b,c,d-e" run-length text of a sorted list of integers
--   n4.patch(off, v)          write one ROM byte (snesPrgRom) and log old -> new; returns old (restore with n4.patch(off, old) or revert_rom_changes)
--   n4.slot(s, from, to)      "off=val" hex words of an actor slot
--   n4.nmi()                  $36 (frame counter word)
-- Callbacks run BEFORE the access; an exec callback fires before the instruction at `off` executes, a memory callback reports the PC after the access.
n4 = n4 or {}

local P   = emu.memType.snesPrgRom
local CPU = emu.cpuType.snes

function n4.nmi() return kit.r16(0x36) end

-- wait (inside the m1 coroutine) until the scene finished loading: $36 advances on 12 consecutive end-of-frame samples. Returns frames waited.
function n4.settle(m, maxn)
  local n, run, last = 0, 0, n4.nmi()
  while n < (maxn or 900) do
    m.wait(1); n = n + 1
    local v = n4.nmi()
    if v ~= last then run = run + 1 else run = 0 end
    last = v
    if run >= 12 then return n end
  end
  return nil
end

function n4.hook(off, name, fn)
  local c = { n = 0, name = name, off = off, frames = {}, first = nil, last = nil }
  emu.addMemoryCallback(function()
    c.n = c.n + 1
    local f = n4.nmi()
    if #c.frames < 4000 then c.frames[#c.frames + 1] = f end
    c.first = c.first or f
    c.last = f
    if fn then fn(c, emu.getState()) end
  end, emu.callbackType.exec, off, off, CPU, P)
  return c
end

function n4.runs(list)
  if #list == 0 then return "-" end
  local out, a, b = {}, list[1], list[1]
  for i = 2, #list do
    local v = list[i]
    if v == b + 1 then b = v
    else
      out[#out + 1] = (a == b) and tostring(a) or (a .. "-" .. b)
      a, b = v, v
    end
  end
  out[#out + 1] = (a == b) and tostring(a) or (a .. "-" .. b)
  return table.concat(out, ",")
end

function n4.patch(off, v)
  local old = emu.read(off, P)
  emu.write(off, v, P)
  local now = emu.read(off, P)
  m1.log("patch ROM %d: %02X -> %02X (read back %02X)", off, old, v, now)
  return old
end

function n4.slot(s, from, to)
  local t = {}
  for o = from or 0, to or 0x2E, 2 do t[#t + 1] = string.format("%02X=%04X", o, kit.r16(s + o)) end
  return table.concat(t, " ")
end
