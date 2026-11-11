-- description: M1 inventory and item experiments: coroutine scenario driver (m1.run / m1.wait / m1.press), compact output file, tilemap text decode.
-- requires: mesen_kit, iog_kit, gaia_kit
--
--   m1.run(body, o)     body(m1) is a coroutine; it yields through m1.wait(n). o = {out="M1_x.txt", maxFrames=N}. Ends with kit.finish.
--   m1.wait(n)          yield n emulator frames (end-of-frame callbacks)
--   m1.press(btns, n)   hold the buttons (list of names a b x y l r up down left right select start) for n frames, then release one frame
--   m1.log(fmt, ...)    line into the output (kept in a table, written chunked at the end; max 4000 lines)
--   m1.r8 / m1.r16 / m1.w8 / m1.w16   WRAM offset access (kit.*)
--   m1.frame()          emulator frame count
-- Callbacks run BEFORE the access; a memory callback reports the PC AFTER the accessing instruction (ROM offset = decimal ; {n} tag of extract:lt).
m1 = m1 or {}

local WR  = emu.memType.snesWorkRam
local P   = emu.memType.snesPrgRom
local CPU = emu.cpuType.snes

m1.r8, m1.r16, m1.w8, m1.w16 = kit.r8, kit.r16, kit.w8, kit.w16
m1.lines = {}
m1.ctl = 0
m1.t = 0
m1.OFF = { nmi = 33528 }

function m1.frame() return emu.getState()["frameCount"] end

function m1.log(fmt, ...)
  if #m1.lines < 4000 then
    m1.lines[#m1.lines + 1] = select("#", ...) > 0 and string.format(fmt, ...) or fmt
  end
end

local function writeChunks(name, lines)
  local buf, first, size = {}, true, 0
  local function flush()
    if #buf > 0 then emu.mcp.writeFile(name, table.concat(buf, "\n") .. "\n", not first); first = false; buf = {} end
  end
  for _, l in ipairs(lines) do
    buf[#buf + 1] = l; size = size + #l + 1
    if size > 2500 then flush(); size = 0 end
  end
  flush()
end

local co, waitN = nil, 0

function m1.wait(n) waitN = n or 1; coroutine.yield() end

function m1.press(btns, n)
  gaia.hold(btns)
  m1.wait(n or 2)
  gaia.release()
  m1.wait(1)
end

function m1.finish(result)
  if m1.done then return end
  m1.done = true
  gaia.release()
  if m1.o and m1.o.out then writeChunks(m1.o.out, m1.lines) end
  result = result or {}
  result.control36 = m1.ctl
  result.nlines = #m1.lines
  result.frames = m1.t
  result.frame = m1.frame()
  kit.finish(result)
end

function m1.run(body, o)
  m1.o = o or {}
  emu.addMemoryCallback(function(a) if (a & 0xFFFF) == 0x36 then m1.ctl = m1.ctl + 1 end end, emu.callbackType.write, 0x36, 0x36, CPU, WR)
  co = coroutine.create(function() return body(m1) end)
  kit.onFrame(function()
    if m1.done then return end
    m1.t = m1.t + 1
    if waitN > 0 then
      waitN = waitN - 1
      if waitN > 0 then return end
    end
    local ok, res = coroutine.resume(co)
    if not ok then
      emu.log("M1 LUA ERROR: " .. tostring(res))
      m1.log("LUA ERROR: " .. tostring(res))
      m1.finish({ error = tostring(res) })
    elseif coroutine.status(co) == "dead" then
      m1.finish(type(res) == "table" and res or nil)
    elseif m1.o.maxFrames and m1.t >= m1.o.maxFrames then
      m1.log("maxFrames reached")
      m1.finish({ truncated = true })
    end
  end)
end

-- helpers ----------------------------------------------------------------------------------------

function m1.hex(v, w) return string.format("%0" .. (w or 2) .. "X", v) end

-- bytes $0AB4..$0AC3 as a hex string, plus equipped index / type
function m1.inv()
  local t = {}
  for i = 0, 15 do t[#t + 1] = string.format("%02X", kit.r8(0x0AB4 + i)) end
  return table.concat(t, " ") .. string.format(" | idx=%04X type=%04X", kit.r16(0x0AC4), kit.r16(0x0AC6))
end

-- reload (or enter) scene `scene` through sceneNext ($0642): waits for arrival, dismisses the banner with A pulses, settles `settle` frames.
-- Must be called inside the coroutine. Returns the number of frames used.
function m1.warp(scene, settle)
  local n0 = m1.t
  local n = 0
  while kit.r16(0x0642) ~= 0 and n < 300 do m1.wait(1); n = n + 1 end
  kit.w16(0x0642, scene)
  m1.wait(2)
  n = 0
  local seen = false
  while n < 900 do
    m1.wait(1); n = n + 1
    if kit.r16(0x0644) == scene and kit.r16(0x0642) == 0 then seen = true; break end
  end
  if not seen then return nil end
  local pulse = 0
  n = 0
  while kit.r8(0x00B4) ~= 0 and n < 400 do
    pulse = pulse + 1
    gaia.hold((pulse % 6 < 3) and { "a" } or {})
    m1.wait(1); n = n + 1
  end
  gaia.release()
  m1.wait(settle or 30)
  return m1.t - n0
end

-- dialogue text candidates in the BG3 buffer: rows whose non-blank entries all have an ASCII low byte (>= $20, < $7F), as "rNN|text"
function m1.dialogText()
  local out = {}
  for r = 0, 31 do
    local ok, any, t = true, false, {}
    for c = 0, 31 do
      local v = m1.bg3(c, r)
      local lo = v & 0xFF
      if v ~= 0 then
        any = true
        if lo < 0x20 or lo >= 0x7F then ok = false; break end
      end
      t[#t + 1] = (v == 0) and " " or string.char(lo)
    end
    if ok and any then
      local s = table.concat(t):gsub("%s+$", "")
      if s:match("%a%a%a") then out[#out + 1] = string.format("r%02d|%s", r, s) end
    end
  end
  return out
end

-- generic memory range as hex
function m1.hexrange(lo, n)
  local t = {}
  for i = 0, n - 1 do t[#t + 1] = string.format("%02X", kit.r8(lo + i)) end
  return table.concat(t, " ")
end

-- a cheap checksum of a WRAM range (sum of bytes * position mix), to compare large ranges
function m1.sum(lo, n)
  local s = 0
  for i = 0, n - 1 do s = (s * 31 + kit.r8(lo + i)) & 0xFFFFFFFF end
  return s
end

-- BG3 tilemap staging buffer ($7F:0200, 32x32 words): returns the 16-bit entry at (col, row)
function m1.bg3(col, row) return kit.r16(0x10200 + (row * 32 + col) * 2) end

function m1.bg3row(row, c0, c1)
  local t = {}
  for c = c0 or 0, c1 or 31 do t[#t + 1] = string.format("%04X", m1.bg3(c, row)) end
  return table.concat(t, " ")
end

-- ASCII text of a BG3 buffer row: the low byte of an entry is the ASCII code (tile $20xx, xx = character), 0 = blank
function m1.text(row, c0, c1)
  local t = {}
  for c = c0 or 0, c1 or 31 do
    local v = m1.bg3(c, row) & 0xFF
    t[#t + 1] = (v >= 0x20 and v < 0x7F) and string.char(v) or (v == 0 and " " or "?")
  end
  return table.concat(t)
end

-- every non-blank BG3 buffer row as "rNN|text" (rows r0..r1)
function m1.screenText(r0, r1)
  local out = {}
  for r = r0 or 0, r1 or 31 do
    local s = m1.text(r)
    if s:match("%S") then out[#out + 1] = string.format("r%02d|%s", r, s) end
  end
  return out
end

-- the inventory is open when sceneCurrent = $FF and the actor main loop runs
function m1.inInventory() return kit.r16(0x0644) & 0xFF == 0xFF end

-- exec hook on a ROM offset (decimal), returns a counter table c with c.n and optional fn(c, st)
function m1.exec(off, name, fn)
  local c = { n = 0, name = name, off = off, first = nil, last = nil }
  emu.addMemoryCallback(function()
    c.n = c.n + 1
    local f = m1.frame()
    c.first = c.first or f
    c.last = f
    if fn then fn(c, emu.getState()) end
  end, emu.callbackType.exec, off, off, CPU, P)
  return c
end

-- slot actor walk: list of actor slots from $56 (head) following +6 links (hazard 23: freed slots keep contents)
function m1.actors(maxn)
  local out, s, n = {}, kit.r16(0x56), 0
  while s ~= 0 and n < (maxn or 90) do
    out[#out + 1] = s
    s = kit.r16(s + 6)
    n = n + 1
  end
  return out
end
