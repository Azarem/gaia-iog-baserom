-- FR10 leg 18: Will's house evening: take the stairs down (cell (3,7)), enter the soldier trigger area (abs tiles (4,25)-(14,29); scratch $07), mash A until free
local PASS = { [0] = true, [3] = true, [5] = true, [6] = true, [9] = true, [1] = true }
local h = fr10.start{}
local function r16(a) return kit.r16(a) end
fr10.bot{ steps = {
  { walk = { 48, 112 }, pass = PASS, max = 900, tol = 0, soft = true },
  { waitUntil = function() return r16(0x09A4) > 300 end, max = 200 },
  { walk = { 112, 400 }, pass = PASS, max = 900, soft = true },
  { mash = "a", down = 2, gap = 20, untilFn = fr10s.free(90), max = 3000, onlyDialog = true },
} }
