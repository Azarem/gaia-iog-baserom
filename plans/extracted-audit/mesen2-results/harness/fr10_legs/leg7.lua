-- FR10 leg 7: South Cape: Erik's house (door cell (34,32), doorstep (34,33); narration $14 at actor ($0228,$0218)), back out (warp_def_04 entry 00 -> scene $01),
-- then Will's house (door cell (32,13), doorstep (32,14); narration $12 at actor ($0208,$00E0)), back out (warp_def_06 -> scene $01)
local PASS = { [0] = true, [1] = true, [3] = true, [5] = true, [6] = true, [9] = true }
local h = fr10.start{}
fr10.bot{ steps = fr10s.cat(
  fr10s.enterDoor(34, 33, 1, 4, PASS),
  fr10s.leaveRoom(192, 464, 4, 1, PASS),
  fr10s.enterDoor(32, 14, 1, 6, PASS, -1),
  fr10s.leaveRoom(80, 464, 6, 1, PASS)
) }
