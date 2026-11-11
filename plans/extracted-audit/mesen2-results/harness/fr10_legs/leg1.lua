-- FR10 leg 1: title (S06) -> Start (after the 540-tick delay) -> diary menu -> Start Journey -> Diary 1 -> Start Journey -> scene $08 (school)
-- Start is accepted from about 480 frames after the S06 state is loaded; the diary menu is ready about 200 frames after scene $FA loads.
local h = fr10.start{}
fr10.bot{ steps = {
  {wait = 500},
  {hold = {"start"}, n = 4},
  {wait = 330},
  {hold = {"a"}, n = 4}, {wait = 40},
  {hold = {"a"}, n = 4}, {wait = 40},
  {hold = {"a"}, n = 4},
  {waitUntil = fr10s.scene(0x08), max = 600},
  {wait = 200},
} }
