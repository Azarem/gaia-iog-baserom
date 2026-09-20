; Plane jumping scene — Neil flies Will to the tower.
; 
; Cutscene (~92 lines). Neil: "We'll be there soon, Will.
; Say hello to your father for me." Will: "Thanks. I know you
; mean that." The airplane approach and Will's jump into
; the tower. Emotional farewell with Neil.
---------------------------------------------

!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!playerActor                    09AA
!TM                             212C

---------------------------------------------

btDC_plane_jumping [
  actor-def < #06, #00, #18, {

  code_098149:
    LDA #$EFF0
    TSB $joypadMaskStd
    SEP #$20
    LDA #$15
    STA $TM
    REP #$20
    LDY $playerActor
    LDA $0010, Y
    ORA #$2000
    STA $0010, Y
    LDY #$1000
    TYA 
    CLC 
    ADC #$0030
    TAY 
    LDA #$FFFE
    STA $002C, Y
    LDA #$0001
    STA $002E, Y
    LDA $14
    CLC 
    ADC #$009C
    STA $14
    COP [StageSpriteLoopMoveX] ( #06, #22, #14 )
    COP [AnimLoop]
    COP [SpawnAfterFlags] ( @code_0981E5, #$3000 )
    COP [StageSpriteLoopMoveX] ( #06, #46, #14 )
    COP [AnimLoop]

  loc_098196:
    COP [BranchIfFlagByte] ( #01, #01, &code_0981A3 )
    COP [StageSpriteFrame] ( #06 )
    COP [AnimOnce]
    BRA loc_098196
} >
]

code_0981A3 {
    COP [StageSpriteLoopMoveXY] ( #06, #1E, #02, #02 )
    COP [AnimLoop]
    COP [SpawnAfterAbsFlags] ( @code_098505, #$0020, #$0000, #$1800 )
    COP [WaitByte] ( #C7 )
    COP [SpawnAfterFlags] ( @code_0981EE, #$3000 )
    COP [WaitWord] ( #$0117 )
    COP [SpawnAfterAbsFlags] ( @code_098505, #$0020, #$0000, #$1800 )
    COP [WaitByte] ( #4F )
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #DE, #$0078, #$00C0, #00, #$1100 )
    COP [SetEntryContinue]
    RTL 
}

code_0981E5 {
    COP [PrintDialogString] ( &dialogstring_0981F4 )
    COP [SetFlagByte] ( #01 )
    COP [Die]
}

code_0981EE {
    COP [PrintDialogString] ( &dialogstring_0984B1 )
    COP [Die]
}

dialogstring_0981F4 `[TPL:A][TPL:6][DLY:0]Neil: We'll be there [N]soon, Will.[FIN]Say hello to [N]your father for me. [FIN][TPL:0]Will: Thanks. [N]I know you will make [N]a great president. [FIN][TPL:3]Erik: Aaah. [N]I guess I won't see you [N]for a long time. [FIN]When you've finished[N]your business, hurry[N]back to South Cape.[FIN][TPL:0]Will: Thank you. I'm [N]glad we all made the [N]trip together. [FIN][TPL:3]Erik: [N]On this trip, everyone [N]found something. [FIN]Lance met Lilly and [N]found his lost father. [FIN]Neil decided to [N]take over his [N]parents' company. [FIN]Kara started to really [N]live, and saw a world [N]outside the castle. [FIN]I'm going to excuse [N]myself.[FIN]Finally, I can go [N]to the bathroom by [N]myself at night! [FIN][TPL:6]Neil: [N]Ha ha ha. Just like Erik. [FIN]Kara hasn't said [N]anything for a while. [FIN]I won't see Will for a [N]long time. I'll say [N]goodbye to him. [FIN][TPL:1]Kara: [N][DLY:4]Hmmm. Right...[FIN][TPL:6][DLY:1]Neil: [N]We've reached the [N]Tower of Babel. [FIN]OK, Will. [N]Is your parachute ready? [N]Let's go.[PAL:0][END]`

dialogstring_0984B1 `[TPL:A][TPL:0][DLY:2]I jumped out over the[N]Tower of Babel.[FIN]I hadn't been there [N]in a year and a half...[PAU:B4][PAL:0][CLD]`

code_098505 {
    COP [StageSpriteMoveXY] ( #05, #13, #11 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ code_098505
    COP [Die]
}