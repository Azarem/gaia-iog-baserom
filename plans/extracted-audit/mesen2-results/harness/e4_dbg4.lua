local WR = emu.memType.snesWorkRam
local n = 0
local S = e4.install{census=true}
kit.onFrame(function()
  n = n + 1
  if n == 5 then iog.setEventFlag(0x0E); emu.log("poke flag 0E; $0A01=" .. string.format("%02X", emu.read(0x0A01, WR, false))) end
  if n % 10 == 0 and n <= 120 then
    emu.log(string.format("n=%d $0A01=%02X F6=%04X FA=%04X FE=%04X n36=%d WH0=%s WH1=%s", n, emu.read(0x0A01, WR, false), emu.read16(0xF6, WR, false), emu.read16(0xFA, WR, false), emu.read16(0xFE, WR, false), emu.read16(0x36, WR, false), tostring(S.last[0x2126]), tostring(S.last[0x2127])))
  end
end)
