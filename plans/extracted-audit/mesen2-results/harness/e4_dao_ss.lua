-- E4 OQ-I035-4: Dao window rectangle, same-frame A/B inside one run with emu.createSavestate / emu.loadSavestate.
-- createSavestate / loadSavestate only work inside an exec callback of the main CPU: the NMI entry (ROM offset 33528) is used. After frame 120 a savestate S is taken at an NMI entry; the next completed frame is grabbed (A, game window); at the following NMI entry S is loaded back and the same frame is rendered again with the W12SEL write forced to 0 (B). Same state, same frame: the pixel difference is the window.
local WR = emu.memType.snesWorkRam
local SM = emu.memType.snesMemory
local CPU = emu.cpuType.snes
local ov = nil
for bank = 0, 0xBF do
  if bank <= 0x3F or bank >= 0x80 then
    emu.addMemoryCallback(function() return ov end, emu.callbackType.write, (bank << 16) | 0x2123, (bank << 16) | 0x2123, CPU, SM)
  end
end
local function grab()
  local buf = emu.getScreenBuffer()
  local t = {}
  for y = 0, 223 do for x = 0, 255 do t[y * 256 + x + 1] = buf[y * 256 + x + 1] end end
  return t
end
local n, ss, A, stage, after = 0, nil, nil, 0, 0
local function safe(f) return function(...) local ok, e = pcall(f, ...); if not ok then emu.log("E4 LUA ERROR " .. tostring(e)) end end end
emu.addMemoryCallback(safe(function()
  if stage == 0 and n >= 120 then
    local s = emu.createSavestate()
    ss = s; stage = 1; emu.log("savestate bytes " .. #ss .. " at frame " .. n)
  elseif stage == 2 then
    ov = 0
    emu.loadSavestate(ss)
    stage = 3; after = 0
    emu.log("loadSavestate at frame " .. n)
  end
end), emu.callbackType.exec, 33528, 33528, CPU, emu.memType.snesPrgRom)
kit.onFrame(safe(function()
  n = n + 1
  if n == 1 then
    emu.write16(0x1014, 352, WR); emu.write16(0x1016, 395, WR); emu.write16(0x09A2, 360, WR); emu.write16(0x09A4, 411, WR)
  end
  if stage == 1 then stage = 1.5
  elseif stage == 1.5 then A = grab(); stage = 2
  elseif stage == 3 then
    after = after + 1
    if after == 2 then
      local B = grab(); stage = 4
      local inside, outside, bbox = 0, 0, { 999, -1, 999, -1 }
      local ib, ob, samp, outl = { 999, -1, 999, -1 }, { 999, -1, 999, -1 }, {}, {}
      for y = 0, 223 do for x = 0, 255 do
        if A[y * 256 + x + 1] ~= B[y * 256 + x + 1] then
          if x >= 96 and x <= 159 and y >= 100 and y <= 147 then
            inside = inside + 1; if x < ib[1] then ib[1] = x end; if x > ib[2] then ib[2] = x end; if y < ib[3] then ib[3] = y end; if y > ib[4] then ib[4] = y end
            if #samp < 3 then samp[#samp + 1] = string.format('(%d,%d) A=%06X B=%06X', x, y, A[y * 256 + x + 1] & 0xFFFFFF, B[y * 256 + x + 1] & 0xFFFFFF) end
          else
            outside = outside + 1; if #outl < 18 then outl[#outl + 1] = string.format('%d,%d A=%06X B=%06X', x, y, A[y * 256 + x + 1] & 0xFFFFFF, B[y * 256 + x + 1] & 0xFFFFFF) end; if x < ob[1] then ob[1] = x end; if x > ob[2] then ob[2] = x end; if y < ob[3] then ob[3] = y end; if y > ob[4] then ob[4] = y end
          end
          if x < bbox[1] then bbox[1] = x end; if x > bbox[2] then bbox[2] = x end
          if y < bbox[3] then bbox[3] = y end; if y > bbox[4] then bbox[4] = y end
        end
      end end
      kit.finish({ inside_rect = inside, outside_rect = outside, inside_bbox = ib, outside_bbox = ob, samples = samp, outside_list = outl, n = n })
    end
  end
end))
