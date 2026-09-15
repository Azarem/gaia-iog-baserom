?BANK 05

?INCLUDE 'enemy_stats_table'
?INCLUDE 'player_transition_handlers'

!gfxCacheIdxA                   0648
!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!playerActor                    09AA
!playerFlags                    09AE
!displayModeFlags               09EC
!playerMaxHp                    0ACA
!playerHp                       0ACE
!damageFlashTimer               0B22
!animScratch2                   7F000E
!orbitAngle                     7F0010
!statsPtr                       7F0020
!currentHp                      7F0026

---------------------------------------------

dc2F_adrift [
  actor-def < #15, #00, #10, {

  code_059712:
    COP [SwitchCase] ( #$0AA6, &code_list_059718 )
} >
]

code_list_059718 [
  &code_059726   ;00
  &code_059775   ;01
  &code_059941   ;02
  &code_059ABA   ;03
  &code_059B3B   ;04
  &code_059BB7   ;05
  &code_059C7A   ;06
]

code_059726 {
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_059749 )
    COP [ExitIfFlagByte] ( #03, #01 )
    COP [WaitByte] ( #3B )
    INC $0AA6
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #2F, #$0070, #$0090, #00, #$1100 )
    COP [SetEntryContinue]
    RTL 
}

code_059749 {
    COP [BranchIfFlagByte] ( #01, #01, &code_05976D )
    COP [PrintDialogString] ( &dialogstring_059D42 )
    COP [DialogueOptions] ( #02, #01, &code_list_059759 )
}

code_list_059759 [
  &code_059765   ;00
  &code_05975F   ;01
  &code_059765   ;02
]

code_05975F {
    COP [PrintDialogString] ( &dialogstring_059D91 )
    BRA loc_059769
}

code_059765 {
    COP [PrintDialogString] ( &dialogstring_059DCD )

  loc_059769:
    COP [SetFlagByte] ( #01 )
    RTL 
}

code_05976D {
    COP [PrintDialogString] ( &dialogstring_059E6F )
    COP [SetFlagByte] ( #02 )
    RTL 
}

code_059775 {
    LDA #$0008
    STA $playerHp
    LDA #$0200
    TSB $12
    COP [SetTilePos] ( #09, #0A )
    COP [StageSpriteFrame] ( #13 )
    COP [AnimOnce]
    COP [SpawnAfterFlags] ( @code_0597EB, #$2800 )
    COP [WaitByte] ( #01 )
    COP [PrintDialogString] ( &dialogstring_059CEB )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05993C )
    COP [ExitIfFlagByte] ( #01, #01 )
    LDA #$0000
    STA $orbitAngle, X

  code_0597A8:
    COP [StageSpriteFrame] ( #14 )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_059F2E )
    COP [StageSpriteFrame] ( #13 )
    COP [AnimOnce]
    COP [ClearFlagByte] ( #01 )
    COP [SetEntryContinue]
    COP [BranchIfFlagByte] ( #01, #01, &code_0597A8 )
    LDA $orbitAngle, X
    CMP #$0708
    BEQ loc_0597D0
    INC 
    STA $orbitAngle, X
    RTL 

  loc_0597D0:
    COP [PrintDialogString] ( &dialogstring_059F5A )
    COP [SetFlagByte] ( #4D )
    INC $0AA6
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #2F, #$0070, #$0090, #00, #$1100 )
    RTL 
}

code_0597EB {
    COP [RngByte]
    AND #$0007
    ASL 
    ASL 
    ASL 
    ASL 
    ASL 
    STA $08
    COP [SetEntryExit]
    COP [SpawnAfterFlags] ( @code_059805, #$0900 )
    COP [SetEntryExitNow] ( @code_0597EB )
}

code_059805 {
    LDA #$1039
    TSB $12
    COP [SetSpritePriority] ( #20 )
    LDA #$&enemy_stats_table+4
    STA $statsPtr, X
    LDA #$00FF
    STA $currentHp, X
    LDA #$0100
    STA $14
    COP [RngByte]
    AND #$000F
    CLC 
    ADC #$0080
    STA $16
    COP [LoopInit] ( #06 )
    COP [SpawnAfterFlags] ( @code_059935, #$1800 )
    LDA $0012, Y
    ORA #$1000
    STA $0012, Y
    COP [StageSpriteLoopMoveXY] ( #42, #08, #04, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveXY] ( #42, #04, #04, #02 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #42, #06, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveXY] ( #43, #04, #04, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveXY] ( #43, #08, #04, #03 )
    COP [AnimLoop]
    LDA $currentHp, X
    CMP #$00FF
    BNE loc_059893

  code_05986E:
    COP [SpawnAfterFlags] ( @code_059935, #$1800 )
    LDA $0012, Y
    ORA #$1000
    STA $0012, Y
    LDA #$2000
    TSB $10
    COP [AddPosition] ( #E0, #00 )
    COP [WaitByte] ( #27 )
    LDA #$2000
    TRB $10
    COP [LoopNext]
    COP [Die]

  loc_059893:
    LDA #$00FF
    STA $currentHp, X
    COP [SetFlagByte] ( #01 )
    LDA $0AA6
    CMP #$0001
    BEQ code_05986E
    COP [SetSpritePriority] ( #30 )
    COP [CollPrioritySetMax]
    COP [StageSpriteLoopMoveXY] ( #42, #04, #11, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveXY] ( #43, #04, #11, #02 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #42, #07, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveXY] ( #43, #04, #11, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveXY] ( #42, #04, #11, #03 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveXY] ( #43, #04, #11, #05 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveXY] ( #42, #05, #11, #07 )
    COP [AnimLoop]
    COP [CollPriorityClearMax]
    COP [BranchIfSolid] ( &code_05986E )
    LDA #$1000
    TSB $10
    COP [SetOnInteract] ( &code_05992A )
    COP [LoopInit] ( #08 )
    COP [StageSpriteLoopMoveY] ( #42, #03, #06 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #43, #03, #02 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #42, #03, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #43, #03, #05 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #44, #08 )
    COP [AnimLoop]
    COP [LoopNext]
    COP [LoopInit] ( #14 )
    LDA #$2000
    TSB $10
    COP [SetEntryExit]
    LDA #$2000
    TRB $10
    COP [LoopNext]
    COP [Die]
}

code_05992A {
    COP [PlaySoundCh1] ( #22 )
    LDA #$0001
    STA $damageFlashTimer
    COP [Die]
}

code_059935 {
    COP [StageSpriteFrame] ( #47 )
    COP [AnimOnce]
    COP [Die]
}

code_05993C {
    COP [PrintDialogString] ( &dialogstring_059EE3 )
    RTL 
}

code_059941 {
    LDA #$0004
    STA $playerHp
    COP [WaitByte] ( #01 )
    COP [PrintDialogString] ( &dialogstring_059CF9 )
    COP [SetOnInteract] ( &code_05999A )
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveX] ( #18, #02, #02 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #14, #1E )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #18, #12 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #14 )
    COP [AnimOnce]
    COP [WaitByte] ( #EF )
    COP [SpawnAfterAbsFlags] ( @code_0599DC, #$FFF8, #$00B0, #$1800 )
    COP [ExitIfFlagByte] ( #03, #01 )
    LDA #$0200
    TSB $12
    COP [StageSpriteLoopMoveX] ( #19, #02, #01 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #15 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
}

code_05999A {
    COP [BranchIfFlagByte] ( #03, #01, &code_0599C1 )
    COP [BranchIfFlagByte] ( #02, #01, &code_0599B9 )
    COP [BranchIfFlagByte] ( #01, #01, &code_0599B4 )
    COP [PrintDialogString] ( &dialogstring_05A03C )
    COP [SetFlagByte] ( #01 )
    RTL 
}

code_0599B4 {
    COP [PrintDialogString] ( &dialogstring_05A074 )
    RTL 
}

code_0599B9 {
    COP [PrintDialogString] ( &dialogstring_05A091 )
    COP [SetFlagByte] ( #03 )
    RTL 
}

code_0599C1 {
    COP [PrintDialogString] ( &dialogstring_05A232 )
    COP [ClearFlagByte] ( #4D )
    INC $0AA6
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #2F, #$0070, #$0090, #00, #$1100 )
    RTL 
}

code_0599DC {
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_0599F4 )
    COP [StageSpriteLoopMoveX] ( #46, #0C, #13 )
    COP [AnimLoop]
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #46 )
    COP [AnimOnce]
    RTL 
}

code_0599F4 {
    COP [PrintDialogString] ( &dialogstring_0599FC )
    COP [SetFlagByte] ( #02 )
    RTL 
}

dialogstring_0599FC `[TPL:A][PAL:0]There was a letter[N]in the jar...[N]The contents read ... [FIN][TPL:5]We are on a ship on our [N]way to be sold as forced [N]labor in an unknown land.[FIN]If anyone reads this, [N]please save us... [N]                   Sam [PAL:0][END]`

code_059ABA {
    LDA #$0200
    TSB $12
    COP [SpawnAfterFlags] ( @code_0597EB, #$2800 )
    LDA #$0001
    STA $playerHp
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #01 )
    COP [PrintDialogString] ( &dialogstring_059D07 )
    COP [PrintDialogString] ( &dialogstring_05A291 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SetOnInteract] ( &code_059B26 )
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveX] ( #18, #03, #12 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #13 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [ClearFlagByte] ( #01 )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [WaitByte] ( #B3 )
    COP [PrintDialogString] ( &dialogstring_05A405 )
    COP [SetFlagWord] ( #$0120 )
    COP [SetFlagByte] ( #52 )
    INC $0AA6
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #2F, #$0070, #$0090, #00, #$1100 )
    RTL 
}

code_059B26 {
    LDA $playerHp
    CMP $playerMaxHp
    BEQ loc_059B33
    COP [PrintDialogString] ( &dialogstring_05A319 )
    RTL 

  loc_059B33:
    COP [PrintDialogString] ( &dialogstring_05A332 )
    COP [SetFlagByte] ( #02 )
    RTL 
}

code_059B3B {
    LDA #$4001
    TSB $displayModeFlags
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [SpawnThinker] ( @code_059BAF )
    TXA 
    TYX 
    TAY 
    LDA $animScratch2, X
    ORA #$0800
    STA $animScratch2, X
    TXA 
    TYX 
    TAY 
    COP [SetTilePos] ( #06, #0A )
    COP [StageSpriteFrame] ( #13 )
    COP [AnimOnce]
    COP [WaitByte] ( #01 )
    COP [PrintDialogString] ( &dialogstring_059D15 )
    COP [PrintDialogString] ( &dialogstring_05A467 )
    COP [WaitByte] ( #EF )
    COP [PrintDialogString] ( &dialogstring_05A5AB )
    LDA #$0800
    TSB $10
    COP [StageSprAndHitbox] ( #17 )
    COP [StageForceMoveX] ( #13 )
    COP [ClearFlagWord] ( #$0120 )
    LDA #$0000
    STA $0682
    COP [ClearFlagByte] ( #52 )
    INC $0AA6
    LDA #$0408
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #2F, #$0070, #$00A0, #03, #$1100 )
    COP [SetEntryContinue]
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #13 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
}

code_059BAF {
    COP [SetEntryContinue]
    COP [PaletteStart] ( #73 )
    COP [PaletteStep]
    RTL 
}

code_059BB7 {
    COP [SetTilePos] ( #08, #0B )
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    COP [WaitByte] ( #01 )
    COP [PrintDialogString] ( &dialogstring_059D24 )
    COP [SetOnInteract] ( &code_059C2E )
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [SpawnAfterAbsFlags] ( @code_059C44, #$0118, #$0088, #$1800 )
    COP [LoopInit] ( #02 )
    COP [WaitByte] ( #59 )
    COP [SpawnAfterAbsFlags] ( @code_059C5D, #$FFE8, #$00D8, #$1800 )
    COP [LoopNext]
    COP [WaitByte] ( #3B )
    COP [StartMusic] ( #06 )
    COP [PrintDialogString] ( &dialogstring_05A6EA )
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [SetEntryDelayExit] ( @code_059C04, #$04B0 )
}

code_059C04 {
    COP [FadeThenStartMusic] ( #15 )
    COP [PrintDialogString] ( &dialogstring_05A770 )
    COP [SetFlagByte] ( #03 )
    COP [SetOnInteract] ( #$0000 )
    COP [WaitByte] ( #EF )
    COP [SetFlagByte] ( #4D )
    INC $0AA6
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #2F, #$0070, #$00A0, #03, #$1100 )
    COP [SetEntryContinue]
    RTL 
}

code_059C2E {
    COP [BranchIfFlagByte] ( #01, #01, &code_059C3C )
    COP [PrintDialogString] ( &dialogstring_05A5E3 )
    COP [SetFlagByte] ( #01 )
    RTL 
}

code_059C3C {
    COP [PrintDialogString] ( &dialogstring_05A723 )
    COP [SetFlagByte] ( #02 )
    RTL 
}

code_059C44 {
    LDA #$1000
    TSB $12
    COP [SetSpritePriority] ( #20 )
    COP [StageSpriteLoopMoveX] ( #45, #10, #02 )
    COP [AnimLoop]
    COP [AddPosition] ( #00, #50 )
    COP [BranchIfFlagByte] ( #03, #01, &code_059C78 )
}

code_059C5D {
    LDA #$1000
    TSB $12
    COP [SetSpritePriority] ( #20 )
    COP [StageSpriteLoopMoveX] ( #C5, #10, #01 )
    COP [AnimLoop]
    COP [AddPosition] ( #00, #B0 )
    COP [BranchIfFlagByte] ( #03, #01, &code_059C78 )
    BRA code_059C44
}

code_059C78 {
    COP [Die]
}

code_059C7A {
    LDA #$0008
    TSB $playerFlags
    COP [SetTilePos] ( #09, #0A )
    COP [StageSpriteFrame] ( #13 )
    COP [AnimOnce]
    COP [WaitByte] ( #01 )
    COP [PrintDialogString] ( &dialogstring_059D33 )
    COP [SetOnInteract] ( &code_059CE3 )
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #01, #01 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    COP [WaitByte] ( #3B )
    LDY $playerActor
    LDA #$*player_transition_handlers.code_00C45E
    STA $0002, Y
    LDA #$&player_transition_handlers.code_00C45E
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    STA $002A, Y
    COP [StartMusic] ( #06 )
    COP [WaitByte] ( #3B )
    COP [PrintDialogString] ( &dialogstring_05A9F9 )
    LDA #$0404
    STA $gfxCacheIdxB
    LDA #$0202
    STA $gfxCacheIdxA
    COP [QueueMapChange] ( #31, #$00A0, #$0060, #03, #$1100 )
    COP [SetEntryContinue]
    RTL 
}

code_059CE3 {
    COP [PrintDialogString] ( &dialogstring_05A853 )
    COP [SetFlagByte] ( #01 )
    RTL 
}

dialogstring_059CEB `[DLG:8,7][SIZ:8,1]Drifting, Day 2[END]`

dialogstring_059CF9 `[DLG:8,7][SIZ:8,1]Drifting, Day 4[END]`

dialogstring_059D07 `[DLG:8,7][SIZ:8,1]Drifting, Day 7[END]`

dialogstring_059D15 `[DLG:8,7][SIZ:8,1]Drifting, Day 12[END]`

dialogstring_059D24 `[DLG:8,7][SIZ:8,1]Drifting, Day 18[END]`

dialogstring_059D33 `[DLG:8,7][SIZ:8,1]Drifting, Day 21[END]`

dialogstring_059D42 `[TPL:A][TPL:1]Kara: [N]You've just come to??? [N]I've lost everyone... [FIN]Are you OK?[N][PAL:0] Yes, I'm OK.[N] I'm still unsteady.`

dialogstring_059D91 `[CLR][TPL:1]Kara: Hmmm. [N]You recover quickly. [N]Like a lizard's tail. [FIN][JMP:&dialogstring_059DCD+M]`

dialogstring_059DCD `[CLR][TPL:1]Kara: Of course, you [N]were unconscious for [N]more than half a day. [FIN][::][TPL:B][TPL:1]I've read about being[N]adrift, but I never[N]thought it would[N]happen to me...[FIN]Disasters sometimes[N]happen suddenly.[PAL:0][END]`

dialogstring_059E6F `[TPL:A][TPL:1]Kara: [N]Don't be upset. [FIN]Don't think about the [N]future. Let's just enjoy [N]drifting. [FIN]I'm starved. I'll have[N]the meat I brought[N]from the castle.[PAL:0][END]`

dialogstring_059EE3 `[TPL:B][TPL:1]Kara: Beautiful.... [N]Even after seeing it [N]all day, I still never [N]get tired of it.[PAL:0][END]`

dialogstring_059F2E `[TPL:A][TPL:1]Kara: What are you [N]doing!! The poor fish!!![PAL:0][END]`

dialogstring_059F5A `[TPL:A][TPL:0][DLY:0]Will: Time passed [N]slowly, with nothing [N]to break the monotony. [FIN]Kara just stared at [N]the fish all day. [N]Will couldn't stand it. [FIN]He walked around on [N]the raft and talked to [N]Kara many times. [FIN]A minute seemed like [N]forever. But he could [N]hear the march of time.[PAL:0][END]`

dialogstring_05A03C `[TPL:A][TPL:1]Kara: [N]I have a premonition... [N]Help is coming... [FIN]What?[PAL:0][END]`

dialogstring_05A074 `[TPL:A][TPL:1]Kara: Something [N]is drifting here![PAL:0][END]`

dialogstring_05A091 `[TPL:A][TPL:1]Kara: [N]My premonition! [FIN]You said you wanted to[N]be saved... but it's me[N]who needs to be saved.[FIN]Oh! I am so[N]starved.[FIN][TPL:0]Will: You should have [N]caught that fish. [N]If you had........ [FIN][TPL:1]Kara: I can't hurt [N]such a pretty fish! [FIN][TPL:0]Will: [N]Are you saying it's [N]better to starve?! [FIN][TPL:1]Kara: [N]Raw fish gives me the [N]creeps! I can't eat it! [FIN]Besides, the fish is[N]fighting to stay alive![FIN]Fish feel pain! Have[N]you ever thought of[N]how the fish feels?![FIN]If you want to eat it,[N]go ahead!! I'm not[N]going to eat it!!![PAL:0][END]`

dialogstring_05A232 `[TPL:A][TPL:1]Kara: [N]................ [FIN][TPL:0][DLY:0]Will: Kara didn't [N]say anything all day.[FIN]A typical princess...[N]She's such a bother...[PAL:0][END]`

dialogstring_05A291 `[PAU:1E][TPL:A][TPL:0]Will: Drifting. [N]First week. [N]A school of fish.... [FIN]He reached the end [N]of his rope.[FIN]If he didn't[N]eat more, he thought[N]he would starve...[END]`

dialogstring_05A319 `[TPL:A][TPL:1]Kara: [N]...............[PAL:0][END]`

dialogstring_05A332 `[TPL:A][TPL:1][DLY:0]Kara: [N]............... [FIN]Will... [N]Sorry I talked to you [N]that way yesterday.... [FIN]I'll try to eat the fish.[N]I can't do anything[N]if I starve.[FIN]Only in peace time can[N]you refuse food you[N]don't like...[FIN][TPL:0]Will: [N]Let's catch a fish. [N]A good one.[PAL:0][END]`

dialogstring_05A405 `[TPL:A][TPL:0][DLY:0]Will: [N]Happily Kara ate some [N]fish. [FIN]Will found that he was [N]starting to develop [N]feelings for Kara...[PAL:0][END]`

dialogstring_05A467 `[DLG:3,13][SIZ:D,3][TPL:1]Kara: The stars [N]are beautiful... [FIN]If I were taller[N]I could reach them.[FIN]Surely Lilly and Lance are[N]looking at the same [N]star-studded sky... [FIN]If I could talk to the[N]stars I could find out [N]where everyone is...[FIN][TPL:1]Kara: There seems to be [N]one extra star near the [N]constellation of Cygnus[FIN]Yes, that red star.[FIN]Shall we make a wish[N]upon that star? I have a[N]feeling it'll come true.[FIN]Will, you close your [N]eyes, too. [END]`

dialogstring_05A5AB `[TPL:A][TPL:0][DLY:0]Will: I hope for  [N]everyone's safety, and [N]for my father...[PAL:0][END]`

dialogstring_05A5E3 `[TPL:B][TPL:1]Kara: [N]We've been adrift for [N]almost three weeks now. [FIN]Hasn't your hair gotten[N]a little long?[N]Just a little (Laughs).[FIN][TPL:0]Will: Kara doesn't [N]act like a spoiled [N]princess now. [FIN]If you told someone she[N]was one of the island[N]girls, no one would[N]doubt it.[FIN][TPL:1]Kara: [N]It's terrible!! [FIN]What is that...?[N]There in the water...?[PAL:0][END]`

dialogstring_05A6EA `[TPL:A][TPL:1]Kara: [N]Maybe a shark...? [FIN]We could be eaten.... [N]What should we do?...[PAL:0][END]`

dialogstring_05A723 `[TPL:A][TPL:1]Kara: They're circling [N]our raft, but they're [N]not attacking... [FIN][TPL:0]Will: [N]Let's think about this... [END]`

dialogstring_05A770 `[TPL:B][TPL:1]Kara: [N]I've got it! [N]They're not hungry!! [FIN]My grandpa told me that[N]only humans attack[N]living things when[N]they're not hungry.[FIN][TPL:0]Will: Then what we're [N]doing is not usual [N]human behavior. [FIN]We didn't eat fish [N]until we were starving.[FIN][TPL:1]Kara: That's right. [N]They're going. [N]Good-bye, sharks...[PAL:0][END]`

dialogstring_05A853 `[TPL:B][TPL:1]Kara: When I was in the [N]castle I loved watching [N]the sun set... [FIN]The sunset was so [N]beautiful from the [N]corridor of the[N]castle...[FIN]But now I've come[N]to hate it.[FIN]After the sun has set, [N]the darkness comes... [FIN]I thought I'd never see[N]the sunrise again....[FIN]But since you're with [N]me, I see a beautiful [N]sunrise every morning. [FIN]With you by my side,[N]I can even enjoy[N]times like these.[FIN][TPL:0]Will: I've wanted to say [N]the same things to you, [N]but somehow the words [N]just wouldn't come out. [FIN]I just nodded,[N]saying nothing...[PAL:0][END]`

dialogstring_05A9F9 `[TPL:A][TPL:0]Will: Suddenly Will[N]fell over,[N]unconscious... [FIN][TPL:1][DLY:0]Kara: [N]Will! Will!! [N]What's wrong!! [FIN]Wake up!! Don't[N]leave me here alone![PAL:0][END]`