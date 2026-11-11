-- D2 run D: vanilla ROM O. Scene change South Cape (scene $01, BGM $1C) -> scene $0A (BGM $05) by writing sceneNext ($0642) at n=5.
-- SpcMusicLoadCmd (WaitFrames 26, $F2 + 32 frames when $0D72 is set, $F0, poll 0, $FF, transfer, $01) runs on the SPC side as logged.
-- Offsets are decimal ROM offsets of O: SpcMusicLoadCmd 166765, loc_028B91 166801, SpcBlockTransfer 168091, LoadMusicFromTransitionState 254494.
d2.run{frames=700, nmi=33528, out='D2_D_O_sceneChange0A_20261031.txt', show=12, maxEv=1500, rowEvery=4,
  at={SpcMusicLoadCmd=166765, loc_028B91=166801, SpcBlockTransfer=168091, ExecuteSceneTransition=0x3A7AF},
  atCount={LoadMusicFromTransitionState=254494},
  tick=function(n,S) if n==5 then kit.w16(0x0642,0x0A) end end,
  input=function(n) if n%30==10 or n%30==11 then return {'a'} else return {} end end,
  final=function(S) local st=emu.getState(); return {scene=kit.r16(0x0644), bgm=kit.r8(0x06F2), d72=kit.r8(0x0D72), f=st['frameCount']} end}
