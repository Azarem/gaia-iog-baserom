local n = 0
local override = nil
local CPU = emu.cpuType.snes
local SM = emu.memType.snesMemory
local hits = 0
for bank = 0, 0xBF do
  if bank <= 0x3F or bank >= 0x80 then
    emu.addMemoryCallback(function(a, v) hits = hits + 1; if override ~= nil then return override end end, emu.callbackType.write, (bank << 16) | 0x2123, (bank << 16) | 0x2123, CPU, SM)
  end
end
local function col(x) local t = {} for y = 0, 223 do t[#t + 1] = emu.getPixel(x, y) end return t end
local A, B = {}, {}
local function d(x, y) return string.format("%06X", (x[y + 1] or 0) & 0xFFFFFF) end
kit.onFrame(function()
  n = n + 1
  if n == 3 then
    for x = 0, 3 do A[x] = col(x) end
  end
  if n == 4 then override = 0x00 end
  if n == 6 then
    for x = 0, 3 do B[x] = col(x) end
    local res = {}
    for x = 0, 3 do
      local dd = 0
      for y = 0, 223 do if A[x][y + 1] ~= B[x][y + 1] then dd = dd + 1 end end
      res[#res + 1] = string.format("x=%d diffRows=%d", x, dd)
    end
    local ex = {}
    for y = 0, 223, 16 do ex[#ex + 1] = string.format("y=%d A0=%s B0=%s A1=%s B1=%s", y, d(A[0], y), d(B[0], y), d(A[1], y), d(B[1], y)) end
    kit.finish({ res = res, ex = ex, hits = hits, act0 = emu.getState()["ppu.window[0].activeLayers[0]"] })
  end
end)
