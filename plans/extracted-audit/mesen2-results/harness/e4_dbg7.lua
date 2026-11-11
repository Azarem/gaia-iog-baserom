local WR = emu.memType.snesWorkRam
local n = 0
emu.log(string.format("S07 cursors: D92=%04X D96=%04X D98=%04X", emu.read16(0xD92, WR, false), emu.read16(0xD96, WR, false), emu.read16(0xD98, WR, false)))
kit.onFrame(function()
  n = n + 1
  if n == 1 then emu.write16(0xD92, DIARY_D92, WR); emu.write16(0xD96, DIARY_D96, WR) end
  if n == 8 then emu.log(string.format("cursors: D92=%04X D96=%04X D98=%04X", emu.read16(0xD92, WR, false), emu.read16(0xD96, WR, false), emu.read16(0xD98, WR, false))); kit.finish({}) end
end)
