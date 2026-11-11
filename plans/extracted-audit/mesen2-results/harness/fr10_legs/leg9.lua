-- FR10 leg 9: coastal cave (scene $02): talk to Lance (cell (6,10); scratch $01) and Seth (cell (9,10); scratch $02) from the cell below them, then mash A through Erik's news scene (sc02_erik: $16, $04, $03)
local PASS = { [0] = true, [3] = true, [5] = true, [6] = true, [9] = true, [1] = true }
local h = fr10.start{}
local function talk(px, py, flagN)
  return {
    { walk = { px, py }, pass = PASS, max = 900 },
    { hold = { "up" }, n = 14 },
    { mash = "a", down = 2, gap = 14, untilFn = fr10s.flag(flagN), max = 300 },
    { mash = "a", down = 2, gap = 20, untilFn = fr10s.free(30), max = 900, onlyDialog = true },
  }
end
fr10.bot{ steps = fr10s.cat(
  talk(96, 176, 1),
  talk(144, 176, 2),
  { { mash = "a", down = 2, gap = 20, untilFn = fr10s.free(90), max = 3000, onlyDialog = true } }
) }
