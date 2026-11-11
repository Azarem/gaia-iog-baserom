-- FR10 leg 13: coastal cave: face the card below Will (actor (104,192)) and pick it (sc02_card sets $08), mash through the reactions (Erik $09, Seth $0A, Lance $0B, $04 cleared) until free
local h = fr10.start{}
fr10.bot{ steps = {
  { hold = { "down" }, n = 8 },
  { mash = "a", down = 2, gap = 14, untilFn = fr10s.busy(), max = 300 },
  { mash = "a", down = 2, gap = 20, untilFn = fr10s.free(120), max = 4000, onlyDialog = true },
} }
