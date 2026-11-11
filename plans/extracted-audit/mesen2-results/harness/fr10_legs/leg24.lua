-- FR10 leg 24: South Cape: walk north through the opened gate corridor to the map edge: scene $FE is the world-map menu ("Where do you go?  Quit / Edward's Castle"); choose Edward's Castle (Down, A), wait for scene $0A, mash A until free
local PASS = { [0] = true, [3] = true, [5] = true, [6] = true, [9] = true, [1] = true }
local h = fr10.start{}
local function r16(a) return kit.r16(a) end
fr10.bot{ steps = {
  { walk = { 368, 0 }, pass = PASS, max = 900, soft = true },
  { waitUntil = function() return r16(0x0644) == 0xFE and r16(0x0642) == 0 end, max = 300 },
  { wait = 330 },
  { hold = { "down" }, n = 3 },
  { wait = 15 },
  { hold = { "a" }, n = 3 },
  { waitUntil = function() return r16(0x0644) == 0x0A and r16(0x0642) == 0 end, max = 900 },
  { mash = "a", down = 2, gap = 20, untilFn = fr10s.free(60), max = 3000, onlyDialog = true },
} }
