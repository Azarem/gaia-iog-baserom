-- FR10 leg 6: South Cape: Lance's house (door cell (18,36), doorstep (18,37); narration $13 at actor ($0128,$0258)), then back out (warp_def_03 -> scene $01)
local PASS = { [0] = true, [3] = true, [5] = true, [6] = true, [9] = true }
local h = fr10.start{}
fr10.bot{ steps = fr10s.cat(
  fr10s.enterDoor(18, 37, 1, 3, PASS),
  fr10s.leaveRoom(80, 208, 3, 1, PASS)
) }
