-- FR10 leg 15: South Cape: back to Will's house (evening: $16 set, $1B and $3D clear); sc06_hamlet locks the joypad at spawn; mash through the opening dialogs
local PASS = { [0] = true, [3] = true, [5] = true, [6] = true, [9] = true, [1] = true }
local h = fr10.start{}
fr10.bot{ steps = fr10s.cat(
  fr10s.enterDoor(32, 14, 1, 6, PASS, -1),
  { { mash = "a", down = 2, gap = 20, untilFn = fr10s.free(90), max = 1500, onlyDialog = true } }
) }
