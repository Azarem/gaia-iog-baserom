-- FR10 leg 3: school: walk to the west door trigger (warp_def_08 entry 00: tiles ($04,$04) 1 x 2 -> scene $01 at ($00C0,$00B0)); cell (4,5) is the passable one of the pair
local h = fr10.start{}
fr10.bot{ steps = {
  {walk = {64, 80}, max = 900},
  {waitUntil = fr10s.scene(0x01), max = 400},
  {wait = 30},
} }
