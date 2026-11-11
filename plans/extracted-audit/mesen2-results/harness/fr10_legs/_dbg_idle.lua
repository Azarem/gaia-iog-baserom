-- FR10 control: the title idles (no input) past WaitWord #$09D3 = 2516 ticks: $F4 is set and scene $8C is queued
local h = fr10.start{}
fr10.bot{ steps = { { wait = 3200 } } }
