-- FR10 leg 20: Will's house: walk into Bill's stair trigger (abs tiles (3,23)-(4,25); fade + QueueMapChange reload of scene $06 = dinner), mash A until free
local PASS = { [0] = true, [3] = true, [5] = true, [6] = true, [9] = true, [1] = true }
local h = fr10.start{}
fr10.bot{ steps = {
  { walk = { 48, 384 }, pass = PASS, max = 900, soft = true },
  { wait = 200 },
  { mash = "a", down = 2, gap = 20, untilFn = fr10s.free(90), max = 4000, onlyDialog = true },
} }
