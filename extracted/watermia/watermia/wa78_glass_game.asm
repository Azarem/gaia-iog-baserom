?INCLUDE 'npc_wander_ai'

!gfxCacheIdxA                   0648
!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!playerHp                       0ACE
!currentHp                      7F0026

---------------------------------------------

wa78_glass_game [
  actor-def < #02, #00, #10, {

  code_078FCA:
    COP [BranchIfFlagByte] ( #96, #01, &code_078FEB )
    COP [SetOnInteract] ( &code_079237 )
    LDA #$0002
    STA $currentHp, X
    JSL $@npc_wander_ai.SyncActorPosFromDP

  loc_078FDF:
    JSL $@npc_wander_ai.NpcRandomWanderAI
    COP [SetEntryExit]
    COP [SetEntryContinue]
    COP [AnimOnce]
    BRA loc_078FDF
} >
]

code_078FEB {
    COP [SpawnAfterAbsFlags] ( @code_07958C, #$0478, #$0070, #$1000 )
    COP [SpawnAfterAbsFlags] ( @code_0795E4, #$04A8, #$0070, #$1000 )
    COP [SpawnAfterAbsFlags] ( @code_079637, #$04C8, #$00C0, #$1000 )
    COP [SpawnAfterAbsFlags] ( @code_07980E, #$0458, #$0090, #$1000 )
    COP [SpawnAfterAbsFlags] ( @code_079845, #$0458, #$00B0, #$1000 )
    COP [SpawnAfterAbsFlags] ( @code_0798AB, #$0478, #$0090, #$1000 )
    COP [SpawnAfterAbsFlags] ( @code_0799D6, #$0488, #$0080, #$1000 )
    COP [SpawnAfterAbsFlags] ( @code_079A13, #$0498, #$0090, #$1000 )
    COP [SpawnAfterAbsFlags] ( @code_079A50, #$04A8, #$0080, #$1000 )
    COP [SpawnAfterAbsFlags] ( @code_079A8D, #$04B8, #$0090, #$1000 )
    COP [SetOnInteract] ( &code_07923C )
    COP [SetTilePos] ( #48, #0B )
    COP [StageSpriteFrame] ( #2B )
    COP [AnimOnce]
    COP [SolidHighHere]
    LDA #$0000
    STA $0AA6
    LDA $0AA6
    BIT #$0004
    BNE loc_0790D0
    COP [ExitIfFlagByte] ( #02, #01 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [StartMusic] ( #06 )
    COP [WaitByte] ( #1D )
    COP [WriteApuIo1] ( #08 )
    COP [StageSpriteMoveX] ( #31, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #2F, #12 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #2B, #1E )
    COP [AnimLoop]
    COP [PrintDialogString] ( &dialogstring_0793B6 )
    COP [PlaySoundCh1] ( #2E )
    COP [WaitByte] ( #27 )
    LDA $0AA6
    ORA #$0004
    STA $0AA6
    COP [StageSpriteMoveY] ( #2E, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #30, #12 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #2B )
    COP [AnimOnce]
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SetOnInteract] ( &code_079244 )
    COP [SetFlagByte] ( #0F )
    COP [ExitIfFlagByte] ( #03, #01 )

  loc_0790D0:
    LDA $0AA6
    BIT #$0010
    BNE loc_079125
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [StageSpriteMoveX] ( #30, #12 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #2F, #12 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #2B, #1E )
    COP [AnimLoop]
    COP [PrintDialogString] ( &dialogstring_0793B6 )
    COP [PlaySoundCh1] ( #2E )
    COP [WaitByte] ( #27 )
    LDA $0AA6
    ORA #$0010
    STA $0AA6
    COP [StageSpriteMoveY] ( #2E, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #31, #11 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #2B )
    COP [AnimOnce]
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SetOnInteract] ( &code_079252 )
    COP [SetFlagByte] ( #0F )
    COP [ExitIfFlagByte] ( #04, #01 )

  loc_079125:
    LDA $0AA6
    BIT #$0002
    BNE loc_07917E
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [StageSpriteLoopMoveX] ( #31, #02, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #2F, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #2B, #1E )
    COP [AnimLoop]
    COP [PrintDialogString] ( &dialogstring_0793B6 )
    COP [PlaySoundCh1] ( #2E )
    COP [WaitByte] ( #27 )
    LDA $0AA6
    ORA #$0002
    STA $0AA6
    COP [StageSpriteLoopMoveY] ( #2E, #02, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #30, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #2B )
    COP [AnimOnce]
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SetOnInteract] ( &code_079260 )
    COP [SetFlagByte] ( #0F )
    COP [ExitIfFlagByte] ( #05, #01 )

  loc_07917E:
    LDA $0AA6
    BIT #$0008
    BNE loc_0791C9
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [StageSpriteLoopMoveY] ( #2F, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #2B, #1E )
    COP [AnimLoop]
    COP [PrintDialogString] ( &dialogstring_0793B6 )
    COP [PlaySoundCh1] ( #2E )
    COP [WaitByte] ( #27 )
    LDA $0AA6
    ORA #$0008
    STA $0AA6
    COP [StageSpriteLoopMoveY] ( #2E, #02, #11 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #2B )
    COP [AnimOnce]
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SetOnInteract] ( &code_07926E )
    COP [SetFlagByte] ( #0F )
    COP [ExitIfFlagByte] ( #06, #01 )

  loc_0791C9:
    LDA $0AA6
    BIT #$0001
    BNE loc_07922F
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [StageSpriteLoopMoveX] ( #31, #03, #11 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #2F, #12 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #2B, #1E )
    COP [AnimLoop]
    COP [StartMusic] ( #1B )
    COP [WaitByte] ( #3B )
    COP [PrintDialogString] ( &dialogstring_07944D )
    LDA $0AA6
    ORA #$0001
    STA $0AA6
    COP [SetFlagByte] ( #08 )
    COP [WaitByte] ( #7F )
    COP [PrintDialogString] ( &dialogstring_079520 )
    COP [PlaySoundCh1] ( #2E )
    COP [WaitByte] ( #77 )
    LDA #$0408
    STA $gfxCacheIdxB
    LDA #$0203
    STA $gfxCacheIdxA
    COP [QueueMapChange] ( #7D, #$0070, #$0080, #00, #$1100 )
    COP [ClearFlagByte] ( #96 )
    COP [SetFlagByte] ( #97 )
    LDA #$CFF0
    TRB $joypadMaskStd

  loc_07922F:
    COP [SetEntryContinue]
    RTL 
}

code_079232 {
    COP [PrintDialogString] ( &dialogstring_079422 )
    RTL 
}

code_079237 {
    COP [PrintDialogString] ( &dialogstring_07927C )
    RTL 
}

code_07923C {
    COP [PrintDialogString] ( &dialogstring_0792F7 )
    COP [SetFlagByte] ( #02 )
    RTL 
}

code_079244 {
    COP [BranchIfFlagByte] ( #0F, #01, &code_079232 )
    COP [PrintDialogString] ( &dialogstring_079401 )
    COP [SetFlagByte] ( #03 )
    RTL 
}

code_079252 {
    COP [BranchIfFlagByte] ( #0F, #01, &code_079232 )
    COP [PrintDialogString] ( &dialogstring_079401 )
    COP [SetFlagByte] ( #04 )
    RTL 
}

code_079260 {
    COP [BranchIfFlagByte] ( #0F, #01, &code_079232 )
    COP [PrintDialogString] ( &dialogstring_079401 )
    COP [SetFlagByte] ( #05 )
    RTL 
}

code_07926E {
    COP [BranchIfFlagByte] ( #0F, #01, &code_079232 )
    COP [PrintDialogString] ( &dialogstring_079401 )
    COP [SetFlagByte] ( #06 )
    RTL 
}

dialogstring_07927C `[DEF][SFX:10]On full moon nights they[N]play Russian Glass,[N]the most dangerous game[N]you can play.[FIN]But you're still young.[N]I wouldn't think you'd[N]throw away your life.[END]`

dialogstring_0792F7 `[DEF][SFX:10][TPL:4]Opponent: [N]Shoot! I forgot my [N]lucky Kruk's foot. [FIN]The rules are simple. [N]One of the five glasses [N]contains poison. [FIN]Drink each one in turn.[N]The one left alive[N]is the winner.[FIN]We'll start with me![END]`

dialogstring_0793B6 `[DEF][SFX:10][TPL:4]Opponent: [N]BAAANZAII!! [FIN][SFX:0]The Opponent drank the[N]glass in one gulp...[END]`

dialogstring_079401 `[DEF][SFX:10][TPL:4]Opponent:[N]Lucky![N]My turn next.[END]`

dialogstring_079422 `[DEF][SFX:10][TPL:4]Opponent:[N]Your turn! Don't run[N]away scared!![END]`

dialogstring_07944D `[DEF][SFX:10][TPL:4]Opponent:[N]One glass left...[WAI][CLD][PAU:3C][DEF][TPL:6][DLY:2]Spectator:[N]That's enough...[N]This young man won...[FIN][DLY:0]Spectator:[N]Right![N]Quit now![FIN][TPL:4][DLY:3]Opponent: No...[N][PAU:1E]I'm the champion. I [N]will not be disgraced. [FIN][SFX:0][DLY:2][TPL:6]He picks up the glass.[END]`

dialogstring_079520 `[DEF][SFX:10][TPL:6]Spectator: Stop![N]You've already lost![N]Stop it!![FIN][SFX:0][DLY:4]Ignoring the spectator,[N]he downs the drink[N]in a shot.[PAL:0][END]`

code_07958C {
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [SetOnInteract] ( &code_0795B4 )
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #08, #01 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveX] ( #09, #02, #01 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #06, #11 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
}

code_0795B4 {
    COP [PrintDialogString] ( &dialogstring_0795B9 )
    RTL 
}

dialogstring_0795B9 `[DEF]You're still young, why[N]would you risk your[N]life this way...[END]`

code_0795E4 {
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    COP [SetOnInteract] ( &code_07960B )
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #08, #01 )
    COP [ClearLowHere]
    COP [StageSpriteMoveX] ( #11, #01 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #0E, #11 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
}

code_07960B {
    COP [PrintDialogString] ( &dialogstring_079610 )
    RTL 
}

dialogstring_079610 `[DEF]There's no game as[N]exciting as this one.[END]`

code_079637 {
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SolidHighOffset] ( #01, #00 )
    COP [SetOnInteract] ( &code_079677 )
    COP [ExitIfFlagByte] ( #01, #01 )
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [ClearLowHere]
    COP [ClearLowOffset] ( #01, #00 )
    COP [SetOnInteract] ( &code_0796A4 )
    COP [StageSpriteMoveX] ( #09, #11 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveY] ( #07, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    COP [SolidHighHere]
    LDA #$EFF0
    TRB $joypadMaskStd
    COP [SetEntryContinue]
    RTL 
}

code_079677 {
    COP [PrintDialogString] ( &dialogstring_0796A9 )
    COP [DialogueOptions] ( #02, #02, &code_list_079681 )
}

code_list_079681 [
  &code_079687   ;00
  &code_07968C   ;01
  &code_079687   ;02
]

code_079687 {
    COP [PrintDialogString] ( &dialogstring_0796DE )
    RTL 
}

code_07968C {
    COP [PrintDialogString] ( &dialogstring_079704 )
    COP [DialogueOptions] ( #02, #02, &code_list_079696 )
}

code_list_079696 [
  &code_079687   ;00
  &code_07969C   ;01
  &code_079687   ;02
]

code_07969C {
    COP [PrintDialogString] ( &dialogstring_07977A )
    COP [SetFlagByte] ( #01 )
    RTL 
}

code_0796A4 {
    COP [PrintDialogString] ( &dialogstring_0797E6 )
    RTL 
}

dialogstring_0796A9 `[DEF]The Russian Glass Club. [N]Do you wish to join? [N] Yes [N] No `

dialogstring_0796DE `[CLR]Then go home, and[N]forget what you've[N]seen here.[END]`

dialogstring_079704 `[CLR]Do you want to risk[N]your young life[N]playing Russian Glass?![FIN]This isn't just a game. [N]You could lose [N]your life.[FIN]I'll ask again. Are[N]you sure?[N] Yes[N] No`

dialogstring_07977A `[CLR]All right. The Opponent[N]is over there.[FIN]He's a seasoned[N]veteran. I've never[N]seen a man so lucky.[FIN]Well.[N]Ask him the rules.[END]`

dialogstring_0797E6 `[DEF]Tonight, some young man [N]will lose his life... [END]`

code_07980E {
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    COP [SetOnInteract] ( &code_079830 )
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #08, #01 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveX] ( #09, #02, #01 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
}

code_079830 {
    COP [PrintDialogString] ( &dialogstring_079835 )
    RTL 
}

dialogstring_079835 `[DEF]You have courage.[END]`

code_079845 {
    COP [StageSpriteFrame] ( #0D )
    COP [AnimOnce]
    COP [SetOnInteract] ( &code_079867 )
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #08, #01 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveX] ( #11, #02, #01 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #0D )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
}

code_079867 {
    COP [PrintDialogString] ( &dialogstring_07986C )
    RTL 
}

dialogstring_07986C `[DEF]Your opponent has won[N]a lot of money. I wonder[N]what he does with it...[END]`

code_0798AB {
    LDA #$0200
    TSB $12
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_0798CA )
    COP [SetEntryContinue]
    LDA $0AA6
    BIT #$0010
    BNE loc_0798C6
    RTL 

  loc_0798C6:
    COP [ClearLowHere]
    COP [Die]
}

code_0798CA {
    COP [BranchIfFlagByte] ( #0F, #00, &code_0798E7 )
    COP [ClearFlagByte] ( #0F )
    LDA $0AA6
    ORA #$0010
    STA $0AA6
    COP [PrintDialogString] ( &dialogstring_0798E8 )
    COP [PlaySoundCh1] ( #2E )
    COP [ClearLowHere]
    COP [Die]
}

code_0798E7 {
    RTL 
}

dialogstring_0798E8 `[DEF][CLR][TPL:0]Will: [N]Will closed his eyes and [N]drank it in one gulp![PAL:0][END]`

dialogstring_079922 `[DEF][TPL:0]Will: What? [N]The glass looks [N]very suspicious! [FIN]Do I have the courage to[N]put this in my body?[FIN][PAL:0]Drink the glass?[N] Yes[N] No`

dialogstring_079992 `[DEF][CLR][TPL:0]Will: [N]I'm quitting...[PAL:0][END]`

dialogstring_0799AF `[DEF][TPL:0]Will: My body[N]is getting numb....[PAL:0][END]`

code_0799D6 {
    LDA #$0200
    TSB $12
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_0799F5 )
    COP [SetEntryContinue]
    LDA $0AA6
    BIT #$0008
    BNE loc_0799F1
    RTL 

  loc_0799F1:
    COP [ClearLowHere]
    COP [Die]
}

code_0799F5 {
    COP [BranchIfFlagByte] ( #0F, #00, &code_079A12 )
    COP [ClearFlagByte] ( #0F )
    LDA $0AA6
    ORA #$0008
    STA $0AA6
    COP [PrintDialogString] ( &dialogstring_0798E8 )
    COP [PlaySoundCh1] ( #2E )
    COP [ClearLowHere]
    COP [Die]
}

code_079A12 {
    RTL 
}

code_079A13 {
    LDA #$0200
    TSB $12
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_079A32 )
    COP [SetEntryContinue]
    LDA $0AA6
    BIT #$0004
    BNE loc_079A2E
    RTL 

  loc_079A2E:
    COP [ClearLowHere]
    COP [Die]
}

code_079A32 {
    COP [BranchIfFlagByte] ( #0F, #00, &code_079A4F )
    COP [ClearFlagByte] ( #0F )
    LDA $0AA6
    ORA #$0004
    STA $0AA6
    COP [PrintDialogString] ( &dialogstring_0798E8 )
    COP [PlaySoundCh1] ( #2E )
    COP [ClearLowHere]
    COP [Die]
}

code_079A4F {
    RTL 
}

code_079A50 {
    LDA #$0200
    TSB $12
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_079A6F )
    COP [SetEntryContinue]
    LDA $0AA6
    BIT #$0002
    BNE loc_079A6B
    RTL 

  loc_079A6B:
    COP [ClearLowHere]
    COP [Die]
}

code_079A6F {
    COP [BranchIfFlagByte] ( #0F, #00, &code_079A8C )
    COP [ClearFlagByte] ( #0F )
    LDA $0AA6
    ORA #$0002
    STA $0AA6
    COP [PrintDialogString] ( &dialogstring_0798E8 )
    COP [PlaySoundCh1] ( #2E )
    COP [ClearLowHere]
    COP [Die]
}

code_079A8C {
    RTL 
}

code_079A8D {
    LDA #$0200
    TSB $12
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_079AAC )
    COP [SetEntryContinue]
    LDA $0AA6
    BIT #$0001
    BNE loc_079AA8
    RTL 

  loc_079AA8:
    COP [ClearLowHere]
    COP [Die]
}

code_079AAC {
    COP [BranchIfFlagByte] ( #0F, #00, &code_079AD2 )
    COP [PrintDialogString] ( &dialogstring_079922 )
    COP [DialogueOptions] ( #02, #01, &code_list_079ABC )
}

code_list_079ABC [
  &code_079ACD   ;00
  &code_079AC2   ;01
  &code_079ACD   ;02
]

code_079AC2 {
    COP [PrintDialogString] ( &dialogstring_0798E8 )
    COP [PlaySoundCh1] ( #2E )
    STZ $playerHp
    RTL 
}

code_079ACD {
    COP [PrintDialogString] ( &dialogstring_079992 )
    RTL 
}

code_079AD2 {
    RTL 
}