-- FR10 leg 11: coastal cave: sit next to Erik (BranchIfPlayerAt actor ($0078,$0090) = player point (112,128); sc02_seth sets $05), pull the statue (actor (232,192), cell (14,11)):
-- push_handler_solid pulls the object toward a player who faces it from 32 px or more away while L / R is held; Seth sets $06 when the statue has moved
local PASS = { [0] = true, [3] = true, [5] = true, [6] = true, [9] = true, [1] = true }
local h = fr10.start{}
fr10.bot{ steps = {
  { walk = { 112, 128 }, pass = PASS, max = 900, tol = 0 },
  { mash = "a", down = 2, gap = 20, untilFn = fr10s.free(60), max = 900, onlyDialog = true },
  { walk = { 160, 176 }, pass = PASS, max = 900 },
  { hold = { "right" }, n = 2 },
  { hold = { "l" }, n = 40 },
  { waitUntil = fr10s.flag(6), max = 240 },
  { mash = "a", down = 2, gap = 20, untilFn = fr10s.free(60), max = 900, onlyDialog = true },
} }
