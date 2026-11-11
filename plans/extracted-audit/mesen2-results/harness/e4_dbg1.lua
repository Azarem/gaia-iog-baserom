local S = e4.install{census=true}
local rows, lines = e4.sampler(S, {every=30, total=300, tag='dbg'})
emu.log("rows after load: "..#rows)
