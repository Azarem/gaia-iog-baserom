-- FR10 leg 5: South Cape: walk to Seth's door (cell (7,37), doorstep of the door at (7,36)) and hold Up: the jar scene (sc01_jar_door, $11) locks the joypad at (actor $0078,$025E)
local PASS = { [0] = true, [3] = true, [5] = true, [6] = true, [9] = true }
local h = fr10.start{}
fr10.bot{ steps = {
  {walk = {112, 592}, pass = PASS, max = 2500},
  {dir = "up", untilFn = fr10s.any(fr10s.busy(), fr10s.leaves(1)), max = 200},
  {mash = "a", down = 2, gap = 20, untilFn = fr10s.any(fr10s.free(40), fr10s.leaves(1)), max = 1500},
} }
