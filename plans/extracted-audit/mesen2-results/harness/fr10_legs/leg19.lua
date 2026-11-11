-- FR10 leg 19: Will's house evening ($1B set): talk to Lola (tile (12,27), from (12,25) facing down; scratch $0A -> Bill's talk $0B -> $3E), mash A until free
local PASS = { [0] = true, [3] = true, [5] = true, [6] = true, [9] = true, [1] = true }
local h = fr10.start{}
fr10.bot{ steps = {
  { walk = { 192, 400 }, pass = PASS, max = 900 },
  { hold = { "down" }, n = 14 },
  { mash = "a", down = 2, gap = 14, untilFn = fr10s.flag(10), max = 400 },
  { mash = "a", down = 2, gap = 20, untilFn = fr10s.free(60), max = 3000, onlyDialog = true },
} }
