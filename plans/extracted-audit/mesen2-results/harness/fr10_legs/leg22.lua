-- FR10 leg 22: Will's house, morning: leave to South Cape (scene $01), the letter/melody scenes done
local PASS = { [0] = true, [3] = true, [5] = true, [6] = true, [9] = true, [1] = true }
local h = fr10.start{}
local function r16(a) return kit.r16(a) end
fr10.bot{ steps = fr10s.cat(
  { { walk = { 48, 112 }, pass = PASS, max = 10, soft = true } },
  fr10s.leaveRoom(80, 464, 6, 1, PASS)
) }
