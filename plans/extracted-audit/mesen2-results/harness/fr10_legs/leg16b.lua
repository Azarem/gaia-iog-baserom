-- FR10 leg 16b: Will's house (scene $06, evening): carry on through the dinner and dream dialogs until the joypad is free
local h = fr10.start{}
fr10.bot{ steps = {
  { mash = "a", down = 2, gap = 20, untilFn = fr10s.free(90), max = 3000, onlyDialog = true },
} }
