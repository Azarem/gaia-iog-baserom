-- FR10 leg 17: Will's house evening: talk to Bill (actor (136,144); scratch $03) and Lola (actor (120,144); scratch $04) from the cell below them, then mash A until free
local PASS = { [0] = true, [3] = true, [5] = true, [6] = true, [9] = true, [1] = true }
local h = fr10.start{}
local function r16(a) return kit.r16(a) end
local function talk(px, py, flagN)
  return {
    { walk = { px, py }, pass = PASS, max = 1500 },
    { hold = { "up" }, n = 14 },
    { mash = "a", down = 2, gap = 14, untilFn = fr10s.flag(flagN), max = 400 },
    { mash = "a", down = 2, gap = 20, untilFn = fr10s.free(30), max = 1500, onlyDialog = true },
  }
end
fr10.bot{ steps = fr10s.cat(
  { { walk = { 48, 368 }, pass = PASS, max = 900, tol = 0, soft = true },
    { dir = "up", untilFn = function() return r16(0x09A4) < 300 end, max = 200 },
    { wait = 60 } },
  talk(128, 144, 3),
  talk(112, 144, 4),
  { { mash = "a", down = 2, gap = 20, untilFn = fr10s.free(90), max = 3000, onlyDialog = true } }
) }
