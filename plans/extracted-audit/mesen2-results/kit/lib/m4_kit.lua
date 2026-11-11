-- description: M4 text and console renderers: BG3 font tile decode (2bpp), CGRAM and tilemap helpers, shared-word census.
-- requires: mesen_kit, iog_kit, gaia_kit, m1_kit
--
--   m4.tile(t, base)        8 strings of 8 chars: pixel value 0 '.', 1 '1', 2 '2', 3 '3' of 2bpp tile t at VRAM byte base (default 0xC000 = BG3 character base $6000 words)
--   m4.tileBytes(t, base)   16 bytes as hex
--   m4.tileBlank(t, base)   true when every pixel of the tile is 0
--   m4.tileSum(t, base)     count of pixels per value {n0, n1, n2, n3}
--   m4.vramHash(lo, n)      cheap checksum of VRAM bytes
--   m4.cg(i)                CGRAM colour word of entry i
--   m4.rgb(w)               "R,G,B" 5-bit fields of a BGR555 word
--   m4.bg3(col,row)         entry of the BG3 staging buffer ($7F:0200)
--   m4.vramMap(col,row)     entry of the live BG3 tilemap in VRAM (word $7800)
m4 = m4 or {}

local V = emu.memType.snesVideoRam
local CG = emu.memType.snesCgRam
local CPU = emu.cpuType.snes
local P = emu.memType.snesPrgRom
local WR = emu.memType.snesWorkRam

m4.FONT = 0xC000

function m4.vb(a) return emu.read(a, V) end

function m4.tile(t, base)
  base = base or m4.FONT
  local a = base + t * 16
  local rows = {}
  for r = 0, 7 do
    local lo, hi = emu.read(a + r * 2, V), emu.read(a + r * 2 + 1, V)
    local s = {}
    for c = 7, 0, -1 do
      local v = ((lo >> c) & 1) | (((hi >> c) & 1) << 1)
      s[#s + 1] = (v == 0) and "." or tostring(v)
    end
    rows[#rows + 1] = table.concat(s)
  end
  return rows
end

function m4.tileBytes(t, base)
  base = base or m4.FONT
  local s = {}
  for i = 0, 15 do s[#s + 1] = string.format("%02X", emu.read(base + t * 16 + i, V)) end
  return table.concat(s, " ")
end

function m4.tileSum(t, base)
  base = base or m4.FONT
  local a = base + t * 16
  local n = { 0, 0, 0, 0 }
  for r = 0, 7 do
    local lo, hi = emu.read(a + r * 2, V), emu.read(a + r * 2 + 1, V)
    for c = 0, 7 do
      local v = ((lo >> c) & 1) | (((hi >> c) & 1) << 1)
      n[v + 1] = n[v + 1] + 1
    end
  end
  return n
end

function m4.tileBlank(t, base)
  local n = m4.tileSum(t, base)
  return n[2] + n[3] + n[4] == 0
end

function m4.vramHash(lo, n)
  local s = 0
  for i = 0, n - 1 do s = (s * 31 + emu.read(lo + i, V)) & 0xFFFFFFFF end
  return s
end

function m4.cg(i)
  return emu.read(i * 2, CG) | (emu.read(i * 2 + 1, CG) << 8)
end

function m4.rgb(w)
  return string.format("%d,%d,%d", w & 31, (w >> 5) & 31, (w >> 10) & 31)
end

function m4.bg3(col, row) return kit.r16(0x10200 + (row * 32 + col) * 2) end

function m4.vramMap(col, row)
  local a = 0xF000 + (row * 32 + col) * 2
  return emu.read(a, V) | (emu.read(a + 1, V) << 8)
end

-- ASCII text of a BG3 row (buffer or VRAM): low byte; tile $40 is shown as '@' like the M1 decode
function m4.rowText(getter, row, c0, c1)
  local t = {}
  for c = c0 or 0, c1 or 31 do
    local v = getter(c, row) & 0xFF
    t[#t + 1] = (v >= 0x20 and v < 0x7F) and string.char(v) or (v == 0 and " " or "?")
  end
  return table.concat(t)
end

-- hex row of whole entries
function m4.rowHex(getter, row, c0, c1)
  local t = {}
  for c = c0 or 0, c1 or 31 do t[#t + 1] = string.format("%04X", getter(c, row)) end
  return table.concat(t, " ")
end

-- CGRAM colours first..first+n-1 as "idx:BBBB(r,g,b)"
function m4.cgRange(first, n)
  local t = {}
  for i = first, first + n - 1 do t[#t + 1] = string.format("%02X:%04X(%s)", i, m4.cg(i), m4.rgb(m4.cg(i))) end
  return table.concat(t, " ")
end

-- CGRAM buffer colour ii of the dialog palette writes ($7F:0A00 + 2 ii)
function m4.cgBuf(i) return kit.r16(0x10A00 + i * 2) end

-- snapshot lines: CGRAM $10-$13 (live), the CGRAM staging buffer $10-$13, and the non-empty rows of the BG3 staging buffer as entries
-- (only columns c0..c1), each entry as tile (hex 3 digits) and palette bits (bits 10-12)
function m4.snap(log, label, c0, c1)
  log('SNAP %s f=%d n36=%d scene=%04X dmf=%04X mask=%04X', label, m1.frame(), kit.r16(0x36), kit.r16(0x644), kit.r16(0x9EC), kit.r16(0x65A))
  log('  CGRAM live  %s', m4.cgRange(0x10, 4))
  local b = {}
  for i = 0x10, 0x13 do b[#b + 1] = string.format('%02X:%04X', i, m4.cgBuf(i)) end
  log('  CGRAM buf   %s', table.concat(b, ' '))
  for r = 0, 31 do
    local any = false
    for c = c0 or 0, c1 or 31 do if m4.bg3(c, r) ~= 0 then any = true; break end end
    if any then
      local t = {}
      for c = c0 or 0, c1 or 31 do
        local v = m4.bg3(c, r)
        t[#t + 1] = (v == 0) and '....' or string.format('%04X', v)
      end
      log('  buf r%02d %s', r, table.concat(t, ' '))
    end
  end
end

-- shared-word census: exec hook on ConsoleCmd_InsertSharedWord (ROM offset 256701; the operand byte is read at DBR:Y at entry)
m4.LU = { n = 0, counts = {}, first = {}, bad = 0 }
function m4.luHook()
  emu.addMemoryCallback(function()
    local st = emu.getState()
    local a = ((st["cpu.dbr"] & 0xFF) << 16) | (st["cpu.y"] & 0xFFFF)
    local v = emu.read(a, emu.memType.snesMemory)
    m4.LU.n = m4.LU.n + 1
    m4.LU.counts[v] = (m4.LU.counts[v] or 0) + 1
    if not m4.LU.first[v] then m4.LU.first[v] = emu.getState()["frameCount"] end
  end, emu.callbackType.exec, 256701, 256701, CPU, P)
end

function m4.luSummary()
  local t = {}
  for i = 0, 0x1F do
    if m4.LU.counts[i] then t[#t + 1] = string.format("%02X:%d@f%d", i, m4.LU.counts[i], m4.LU.first[i]) end
  end
  return table.concat(t, " ")
end
