-- FR10 leg 4: South Cape (scene $01) arrival: the scene banner ($00B4 = $E0) waits for a button; press A until the player is free
local h = fr10.start{}
fr10.bot{ steps = {
  {wait = 20},
  {mash = "a", down = 2, gap = 20, untilFn = fr10s.free(30), max = 900},
} }
