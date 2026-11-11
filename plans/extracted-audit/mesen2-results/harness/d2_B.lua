-- D2 run B: patched build (R, MusicTransitions + APUWaitFixes). Same scene-58 trigger as d2_A; R addresses.
d2.run{frames=700, nmi=0x967C, xfer={163893-14, 163893+380}, nmiRange={0x967C,0x967C+142}, out='D2_B_R_scene58_20261031.txt', show=12, maxEv=1500, rowEvery=4,
  at={SpcFadeOutHandshake=252778, SpcTransferMusicData=252851, bgm_load_wait=252865, loc_028B91=169335, bgm_halt=169357, SpcBlockTransfer=163893, ExecuteSceneTransition=239535},
  atCount={count_check=691893, LoadMusicFromTransitionState=252898},
  rowCountName='LoadMusicFromTransitionState',
  tick=function(n,S) if n==5 then kit.w16(0x0AA6,2); kit.w16(0x0642,0x58) end end,
  input=function(n) if n%30==10 or n%30==11 then return {'a'} else return {} end end,
  final=function(S) local st=emu.getState(); return {scene=kit.r16(0x0644), bgm=kit.r8(0x06F2), d72=kit.r8(0x0D72), f=st['frameCount']} end}
