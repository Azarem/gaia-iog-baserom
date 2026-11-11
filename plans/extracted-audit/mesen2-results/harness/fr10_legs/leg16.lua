-- FR10 leg 16: Will's house (scene $06, evening): walk to the player point (48,400) (sc06_hamlet BranchIfPlayerAt actor ($0038,$01A0); pins Will, sets scratch $01), then mash through until free
local PASS = { [0] = true, [3] = true, [5] = true, [6] = true, [9] = true, [1] = true }
local h = fr10.start{}
fr10.bot{ steps = {
  { walk = { 48, 400 }, pass = PASS, max = 900, tol = 0, dismiss = true },
  { waitUntil = fr10s.busy(), max = 120, soft = true },
  { mash = "a", down = 2, gap = 20, untilFn = fr10s.free(90), max = 2500, onlyDialog = true },
} }
