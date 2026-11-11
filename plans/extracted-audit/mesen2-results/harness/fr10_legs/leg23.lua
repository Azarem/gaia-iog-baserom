-- FR10 leg 23: South Cape, morning after the letter ($35 set): talk to the gate guard (actor (408,128), cell (25,7)) from (24,7) facing right; scratch-free flag $27 opens the gate cells (23,6),(24,6)
local PASS = { [0] = true, [3] = true, [5] = true, [6] = true, [9] = true, [1] = true }
local h = fr10.start{}
fr10.bot{ steps = {
  { walk = { 384, 112 }, pass = PASS, max = 2500 },
  { hold = { "right" }, n = 4 },
  { hold = { "left" }, n = 10 },
  { hold = { "up" }, n = 14 },
  { mash = "a", down = 2, gap = 14, untilFn = fr10s.flag(0x27), max = 400 },
  { mash = "a", down = 2, gap = 20, untilFn = fr10s.free(60), max = 900, onlyDialog = true },
} }
