-- D2 run A: S01r (South Cape, scene $01), quick warp to scene $58 (write $0642 at n=5) with $0AA6 = 2, so that the actor
-- sp58_red_eye takes its FadeThenStartMusic #02 branch (extracted/sky_garden/garden_descent/sp58_red_eye.asm: LDA $0AA6, CMP #$0002).
-- A button pulses (2 frames in 30) dismiss the scene banner. 700 frames. Offsets are decimal ROM offsets of the O ROM.
d2.run{frames=700, nmi=33528, out='D2_A_scene58_20261031.txt', show=12, maxEv=1500, rowEvery=4,
  at={FadeThenStartMusic=34633, SpcMusicLoadCmd=166765, SpcFadeOutHandshake=254378, SpcTransferMusicData=254422, SpcBlockTransfer=168091},
  atCount={LoadMusicFromTransitionState=254494, HandshakePoll1=254389, HandshakePoll2=254414, AfterPoll1=254392, AfterPoll2=254417},
  atValue={AfterPoll1=true, AfterPoll2=true},
  tick=function(n,S) if n==430 or n==500 or n==300 then local st=emu.getState(); local sp=st['cpu.sp']; local M=emu.memType.snesMemory; local t={}; for i=1,60 do local lo=emu.read(sp+i,M); local hi=emu.read(sp+i+1,M); local bk=emu.read(sp+i+2,M); local jsl=((bk<<16)|(hi<<8)|lo)-3; if bk>=0x80 and emu.read(jsl,M)==0x22 then local tgt=emu.read(jsl+1,M)|(emu.read(jsl+2,M)<<8)|(emu.read(jsl+3,M)<<16); t[#t+1]=string.format('sp+%d JSL@%06X -> %06X',i,jsl,tgt) end end; S.stk=S.stk or {}; S.stk[#S.stk+1]=string.format('n%d sp=%04X ',n,sp)..table.concat(t,' | ') end; if n==5 then kit.w16(0x0AA6,2); kit.w16(0x0642,0x58) end end,
  input=function(n) if n%30==10 or n%30==11 then return {'a'} else return {} end end,
  final=function(S) local st=emu.getState(); return {stk=S.stk, scene=kit.r16(0x0644), bgm=kit.r8(0x06F2), f=st['frameCount'], k=st['cpu.k'], sp=st['cpu.sp'], aa6=kit.r16(0x0AA6)} end}
