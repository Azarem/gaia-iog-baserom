-- description: B4 trial runner: exec hooks by ROM offset with an actor-slot filter and per-hook word columns, write watches with PC, per-frame word columns, scripted input.
-- requires: gaia_kit, b3_kit
--
-- All hook offsets are ROM FILE offsets of the ORIGINAL ROM (decimal keys of db-us/names/bankNN.json; a local label is bank << 16 + address).
--
--   b4.run{ frames=N, input=b3.schedule(segs), setup=fn, final=fn,
--           hooks = { {name=, off=, slot=<X register value or nil>, cols={ addr | {addr, true(signed)} , ... }} , ... },
--           cols  = { addr | {addr, true} , ... }                 -- per-frame columns (read after the frame's NMI)
--           watches = { {name=, lo=, hi=, kind="write"|"read", cols=...}, ... },
--           maxEvents = 1500 }
--   Hook event row : { n, name, xReg, <cols...> }          n = completed frames when the hook ran (the event belongs to the frame whose end state is row n + 1)
--   Watch event row: { n, name, addr, value, pc, <cols...> } pc = address AFTER the accessing instruction
--   Frame row      : { n, <cols...> }
--   Result         : { frames = {...}, events = {...}, ctl36 = <writes of $36 seen>, truncated = bool, final = ... }
-- addr is a WRAM offset (16-bit read; $7F:xxxx = 0x10000 + xxxx). Word reads: kit.r16.
b4 = b4 or {}
local PRG = emu.memType.snesPrgRom
local WR = emu.memType.snesWorkRam

local function readcols(cols, row)
  for _, c in ipairs(cols or {}) do
    if type(c) == "table" then row[#row + 1] = kit.r16(c[1], nil, c[2]) else row[#row + 1] = kit.r16(c) end
  end
end

function b4.run(o)
  local events, frames = {}, {}
  local n, started, handle, ctl36 = 0, false, nil, 0
  local cap = o.maxEvents or 1500
  emu.addMemoryCallback(function(a, v) if (a & 0xFFFF) == 0x36 then ctl36 = ctl36 + 1 end end,
    emu.callbackType.write, 0x36, 0x36, emu.cpuType.snes, WR)
  for _, h in ipairs(o.hooks or {}) do
    emu.addMemoryCallback(function()
      if not started or #events >= cap then return end
      local x = emu.getState()["cpu.x"]
      if h.slot and x ~= h.slot then return end
      local row = { n, h.name, x }
      readcols(h.cols, row)
      events[#events + 1] = row
    end, emu.callbackType.exec, h.off, h.off, emu.cpuType.snes, PRG)
  end
  for _, w in ipairs(o.watches or {}) do
    emu.addMemoryCallback(function(a, v)
      if not started or #events >= cap then return end
      local st = emu.getState()
      local row = { n, w.name, a & 0xFFFF, v, st["cpu.pc"] }
      readcols(w.cols, row)
      row[#row + 1] = st["cpu.k"]   -- program bank of the accessing instruction (last field of a watch row)
      events[#events + 1] = row
    end, emu.callbackType[w.kind or "write"], w.lo, w.hi, emu.cpuType.snes, WR)
  end
  emu.addEventCallback(function()
    if not started then return end
    local b = o.input and o.input(n + 1) or nil
    local t = {}
    for _, name in ipairs(b or {}) do t[name] = true end
    emu.setInput(t, 0)
  end, emu.eventType.inputPolled)
  handle = kit.onFrame(function()
    if not started then
      started = true
      if o.setup then o.setup() end
      return
    end
    n = n + 1
    local row = { n }
    readcols(o.cols, row)
    frames[#frames + 1] = row
    if o.each then o.each(n, row) end
    if n >= o.frames then
      kit.off(handle)
      local res = { frames = frames, events = events, ctl36 = ctl36, truncated = (#events >= cap) }
      if o.final then res.final = o.final() end
      kit.finish(res)
    end
  end)
end
