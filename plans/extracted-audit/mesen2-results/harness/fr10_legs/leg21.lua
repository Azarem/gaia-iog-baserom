-- FR10 leg 21: Will's house, morning ($1D set): stairs down, talk to Lola (tile (12,26) from (12,25) facing down): she gives item $09 and the letter/melody scene sets $35; mash A until free
local PASS = { [0] = true, [3] = true, [5] = true, [6] = true, [9] = true, [1] = true }
local h = fr10.start{}
local function r16(a) return kit.r16(a) end
fr10.bot{ steps = {
  { walk = { 48, 112 }, pass = PASS, max = 900, tol = 0, soft = true },
  { waitUntil = function() return r16(0x09A4) > 300 end, max = 200 },
  { walk = { 192, 400 }, pass = PASS, max = 900 },
  { hold = { "down" }, n = 14 },
  { mash = "a", down = 2, gap = 14, untilFn = fr10s.flag(0x35), max = 600 },
  { mash = "a", down = 2, gap = 20, untilFn = fr10s.free(90), max = 4000, onlyDialog = true },
} }
