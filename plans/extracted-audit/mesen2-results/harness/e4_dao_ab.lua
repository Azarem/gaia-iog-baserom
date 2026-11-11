-- E4 OQ-I035-4: Dao window rectangle, same-frame A/B. Two runs from the same state: DAO_OVERRIDE = nil (window as the game sets it) or 0 (W12SEL write forced to 0 for every write).
-- The player is moved next to the rectangle in a disposable state. The screenshot at the same frame of both runs is compared by e4_png.py.
local WR = emu.memType.snesWorkRam
local SM = emu.memType.snesMemory
local CPU = emu.cpuType.snes
local ov = DAO_OVERRIDE
for bank = 0, 0xBF do
  if bank <= 0x3F or bank >= 0x80 then
    emu.addMemoryCallback(function() return ov end, emu.callbackType.write, (bank << 16) | 0x2123, (bank << 16) | 0x2123, CPU, SM)
  end
end
local n = 0
kit.onFrame(function()
  n = n + 1
  if n == 1 then
    emu.write16(0x1014, 352, WR); emu.write16(0x1016, 395, WR); emu.write16(0x09A2, 360, WR); emu.write16(0x09A4, 411, WR)
  end
  if n == 120 then kit.finish({ n = n, ov = tostring(ov) }) end
end)
