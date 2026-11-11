-- FR10 leg 14: coastal cave exit (sc02_entry code_04BE57: playerYPos == $00D0 and $04 clear -> scene $01 at ($0290,$02B0)); then the $17 narration in scene 1 (sc01_house_intro at actor ($0298,$02C0))
local PASS = { [0] = true, [3] = true, [5] = true, [6] = true, [9] = true, [1] = true }
local h = fr10.start{}
fr10.bot{ steps = {
  { walk = { 112, 208 }, pass = PASS, max = 900, tol = 0 },
  { waitUntil = fr10s.scene(1), max = 600 },
  { waitUntil = fr10s.busy(), max = 240, soft = true },
  { mash = "a", down = 2, gap = 20, untilFn = fr10s.free(60), max = 900, onlyDialog = true },
} }
