-- FR10 leg 12: coastal cave: talk to Lance again (his handler after $06 prints 'Next. Pick a card' and sets $07), watch the card deal until the player is free
local PASS = { [0] = true, [3] = true, [5] = true, [6] = true, [9] = true, [1] = true }
local h = fr10.start{}
fr10.bot{ steps = {
  { walk = { 96, 176 }, pass = PASS, max = 900 },
  { hold = { "up" }, n = 14 },
  { mash = "a", down = 2, gap = 14, untilFn = fr10s.busy(), max = 300 },
  { mash = "a", down = 2, gap = 20, untilFn = fr10s.free(90), max = 2400, onlyDialog = true },
} }
