local n=0
kit.onFrame(function() n=n+1
  if n<=60 and (n%3==0) then emu.log(string.format("n=%d fc=%d n36=%d scene=%04X next=%04X b4=%02X", n, emu.getState().frameCount, emu.read16(0x36, emu.memType.snesWorkRam,false), emu.read16(0x644,emu.memType.snesWorkRam,false), emu.read16(0x642,emu.memType.snesWorkRam,false), emu.read(0xB4,emu.memType.snesWorkRam,false))) end
end)
e4.warp{scene=0x2A, post=20, tag='dbg'}
