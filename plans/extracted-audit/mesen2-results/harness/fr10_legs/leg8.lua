-- FR10 leg 8: South Cape: walk to the cave warp (warp_def_01 entry 07: tiles ($29,$28) 1 x 3 -> scene $02); the lowest tile is (41,42); mash A through the arrival narration ($15)
local PASS = { [0] = true, [3] = true, [5] = true, [6] = true, [9] = true, [1] = true }
local h = fr10.start{}
fr10.bot{ steps = {
  { walk = { 656, 672 }, pass = PASS, max = 3000 },
  { waitUntil = fr10s.scene(2), max = 600 },
  { mash = "a", down = 2, gap = 20, untilFn = fr10s.free(40), max = 900 },
} }
