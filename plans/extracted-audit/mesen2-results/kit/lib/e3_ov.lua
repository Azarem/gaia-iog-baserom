-- description: E3 divisor-overflow census: exec counters on the four INC $03 labels, the scanline of each overflow, and the step each one leaves in the M7A table.
-- requires: mesen_kit, iog_kit, gaia_kit, e3_kit, e3_shot
--
-- e3ov.go{ tag=, from=n0, stop=N, input=fn(n), poke=fn(n), scene=nil }
-- Table layout (Mode7PerspectiveUpdate): 224 entries of {count $01, word}, 3 bytes per line, plus a $00 terminator: entry i word at base + 3*i + 1.
-- Per frame (n >= from): B6, B8, BC, overflow counts per quadrant label, the 0-based scanline of every overflow ($0E counts 224 down at the check),
-- the second difference d2[i] = A[i+1] - 2 A[i] + A[i-1] of table A (M7A / M7D) and of table B (M7B), taken only at the two lines each overflow touches
-- (i = L, L+1) versus every other line, plus selected table dumps. Output: E3_<tag>_ov.tsv and E3_<tag>_ovdump.txt
e3ov = e3ov or {}

local function s16(lo, hi) local v = lo | (hi << 8); if v >= 0x8000 then v = v - 0x10000 end; return v end

function e3ov.go(o)
  local OFF = e3.OFF
  local f0 = emu.getState().frameCount
  local done = false
  local w36, nmi = 0, 0
  emu.addMemoryCallback(function(a) if (a & 0xFFFF) == 0x36 then w36 = w36 + 1 end end, emu.callbackType.write, 0x36, 0x36, emu.cpuType.snes, emu.memType.snesWorkRam)
  emu.addMemoryCallback(function() nmi = nmi + 1 end, emu.callbackType.exec, OFF.nmi, OFF.nmi, emu.cpuType.snes, emu.memType.snesPrgRom)

  local tot = { q1 = 0, q2 = 0, q3 = 0, q4 = 0, ov1 = 0, ov2 = 0, ov3 = 0, ov4 = 0, upd = 0 }
  local cur = { q1 = 0, q2 = 0, q3 = 0, q4 = 0, ov1 = 0, ov2 = 0, ov3 = 0, ov4 = 0 }
  local lines = {}
  local first = {}
  for _, k in ipairs({ "q1", "q2", "q3", "q4" }) do
    emu.addMemoryCallback(function()
      tot[k] = tot[k] + 1; cur[k] = cur[k] + 1
      if not first[k] then first[k] = emu.getState().frameCount - f0 end
    end, emu.callbackType.exec, OFF[k], OFF[k], emu.cpuType.snes, emu.memType.snesPrgRom)
  end
  emu.addMemoryCallback(function() tot.upd = tot.upd + 1 end, emu.callbackType.exec, OFF.updFrame, OFF.updFrame, emu.cpuType.snes, emu.memType.snesPrgRom)
  for _, k in ipairs({ "ov1", "ov2", "ov3", "ov4" }) do
    emu.addMemoryCallback(function()
      tot[k] = tot[k] + 1; cur[k] = cur[k] + 1
      lines[#lines + 1] = 224 - kit.r8(0x0E)
      if not first[k] then first[k] = emu.getState().frameCount - f0 end
    end, emu.callbackType.exec, OFF[k], OFF[k], emu.cpuType.snes, emu.memType.snesPrgRom)
  end

  if o.input then e3.input(o.input, f0) end

  local rows = { "n\tf36\tB6\tB8\tBC\tq1\tq2\tq3\tq4\tov1\tov2\tov3\tov4\tov_lines\tA0\tA223\tB0\tB223\tmaxOvA\tmaxOtherA\tmaxOvB\tmaxOtherB" }
  local dumps = {}
  local nDump = 0

  local function readTable(base)
    local t = {}
    for i = 0, 223 do
      local a = base + 3 * i
      t[i] = s16(kit.r8(a + 1), kit.r8(a + 2))
    end
    return t
  end

  kit.onFrame(function()
    if done then return end
    local n = emu.getState().frameCount - f0
    if o.poke then o.poke(n) end
    if n >= (o.from or 0) then
      local A, B = readTable(0x7000), readTable(0x7800)
      local isOv = {}
      for _, L in ipairs(lines) do isOv[L] = true; isOv[L + 1] = true end
      local mOvA, mOthA, mOvB, mOthB = 0, 0, 0, 0
      for i = 1, 222 do
        local dA = math.abs(A[i + 1] - 2 * A[i] + A[i - 1])
        local dB = math.abs(B[i + 1] - 2 * B[i] + B[i - 1])
        if isOv[i] then
          if dA > mOvA then mOvA = dA end
          if dB > mOvB then mOvB = dB end
        else
          if dA > mOthA then mOthA = dA end
          if dB > mOthB then mOthB = dB end
        end
      end
      local ovl = {}
      for _, L in ipairs(lines) do ovl[#ovl + 1] = tostring(L) end
      rows[#rows + 1] = string.format("%d\t%d\t%04X\t%04X\t%04X\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%s\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d",
        n, kit.r16(0x36), kit.r16(0xB6), kit.r16(0xB8), kit.r16(0xBC), cur.q1, cur.q2, cur.q3, cur.q4, cur.ov1, cur.ov2, cur.ov3, cur.ov4,
        table.concat(ovl, ","), A[0], A[223], B[0], B[223], mOvA, mOthA, mOvB, mOthB)
      -- dumps of the A values around each overflow line for the frames listed in o.dumpAt
      if o.dumpAt and o.dumpAt[n] and #lines > 0 then
        for _, L in ipairs(lines) do
          if nDump < 40 then
            nDump = nDump + 1
            local seg = {}
            for i = math.max(0, L - 3), math.min(223, L + 4) do seg[#seg + 1] = string.format("%d:%d", i, A[i]) end
            dumps[#dumps + 1] = string.format("n=%d B6=%04X B8=%04X overflow after line %d A[%s]", n, kit.r16(0xB6), kit.r16(0xB8), L, table.concat(seg, " "))
          end
        end
      end
    end
    for k in pairs(cur) do cur[k] = 0 end
    lines = {}
    if n >= o.stop then
      done = true
      e3.writeChunks(string.format("E3_%s_ov.tsv", o.tag), rows)
      e3.writeChunks(string.format("E3_%s_ovdump.txt", o.tag), dumps)
      kit.finish({ n = n, start = f0, w36 = w36, nmi = nmi, tot = tot, first = first, rows = #rows, dumps = #dumps, scene = kit.r16(0x644), route = kit.r16(0xD5A) })
    end
  end)
end
