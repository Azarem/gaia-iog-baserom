-- FR10 leg 2: school (scene $08): dismiss the scene banner and the lesson dialogs with A until the player is free
local h = fr10.start{}
fr10.bot{ steps = {
  {mash = "a", down = 2, gap = 10, untilFn = fr10s.free(60), max = 4000},
} }
