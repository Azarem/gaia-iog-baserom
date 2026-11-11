-- FR10 probe: player point and actor position around the Hamlet trigger (scene $06 evening)
local PASS = { [0]=true,[3]=true,[5]=true,[6]=true,[9]=true,[1]=true }
local h = fr10.start{}
local n = 0
kit.onFrame(function()
  n = n + 1
  if n % 6 == 0 and n < 700 and kit.r16(0x0644) == 6 then
    emu.log(string.format("n=%d p=%d,%d actor=%d,%d mask=%04X", n, kit.r16(0x09A2), kit.r16(0x09A4), kit.r16(0x1014), kit.r16(0x1016), kit.r16(0x065A)))
  end
end)
fr10.bot{ steps = {
  { walk = { 48, 400 }, pass = PASS, max = 400, tol = 0, soft = true },
  { waitUntil = fr10s.busy(), max = 120, soft = true },
  { wait = 60 },
} }
