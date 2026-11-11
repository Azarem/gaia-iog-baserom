-- FR10 leg 10: coastal cave: continue Erik's news scene until the player is free again
local h = fr10.start{}
fr10.bot{ steps = {
  { mash = "a", down = 2, gap = 20, untilFn = fr10s.free(90), max = 3000, onlyDialog = true },
} }
