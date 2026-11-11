local WR = emu.memType.snesWorkRam
local n = 0
local last = nil
kit.onFrame(function()
  n = n + 1
  local fe = emu.read16(0xFE, WR, false)
  local k = string.format("%04X|%04X|%04X", emu.read16(0xF6, WR, false), emu.read16(0xFA, WR, false), fe)
  if k ~= last and (last == nil or fe ~= 0xFFFF or n % 200 == 0) and n < 20000 then
    emu.log(string.format("n=%d n36=%d %s W12=?", n, emu.read16(0x36, WR, false), k)); last = k
  end
  if fe ~= 0xFFFF and fe < 0x8000 and not found then found = n; emu.log("FIRST circle n=" .. n .. " fe=" .. fe) end
  if found and n >= found + 3 then kit.finish({ n = n, found = found, n36 = emu.read16(0x36, WR, false), fe = fe }) end
end)
