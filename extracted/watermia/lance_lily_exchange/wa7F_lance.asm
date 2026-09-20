; Lance in the lance/lily exchange scene — emotional dialog.
; 
; Extended NPC (~104 lines). Says: "Yes, the words are harder
; to say than a tongue twister." Part of the emotional scene
; where Lance tries to express his feelings for Lilly.
; Major character development moment.
---------------------------------------------

!gfxCacheIdxA                   0648
!gfxCacheIdxB                   064A
!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

wa7F_lance [
  actor-def < #05, #00, #10, {

  code_07AFCD:
    COP [AddPosition] ( #08, #00 )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [SpawnAfterRelFlags] ( @code_07B1C2, #$000A, #$FFF4, #$1002 )
    COP [StageSpriteFrame] ( #38 )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    COP [WaitByte] ( #1D )
    COP [ExitIfFlagByte] ( #03, #01 )
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_07B0A2 )
    COP [WaitByte] ( #1D )
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    COP [StartMusic] ( #1B )
    COP [WaitByte] ( #3B )
    COP [PrintDialogString] ( &dialogstring_07B0E1 )
    COP [WaitByte] ( #EF )
    COP [PrintDialogString] ( &dialogstring_07B108 )
    COP [WaitByte] ( #77 )
    COP [SetFlagByte] ( #04 )
    COP [ExitIfFlagByte] ( #05, #01 )
    COP [SpawnAfterFlags] ( @code_07B077, #$2000 )
    LDA #$0800
    TSB $10
    LDA #$02F8
    STA $moveXAlt, X
    LDA #$0120
    STA $moveYAlt, X
    COP [MoveToward] ( #06, #02 )
    LDA #$0800
    TRB $10
    COP [SetEntryExit]
    COP [SpawnAfterFlags] ( @code_07B07D, #$2000 )
    LDA #$0800
    TSB $10
    COP [StageSpriteLoop] ( #02, #78 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #09, #02, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #02, #78 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #07, #06, #14 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
} >
]

code_07B077 {
    COP [PrintDialogString] ( &dialogstring_07B158 )
    COP [Die]
}

code_07B07D {
    COP [WaitByte] ( #77 )
    COP [PrintDialogString] ( &dialogstring_07B174 )
    COP [WaitByte] ( #3B )
    COP [SetFlagByte] ( #91 )
    LDA #$0404
    STA $gfxCacheIdxB
    LDA #$0200
    STA $gfxCacheIdxA
    COP [QueueMapChange] ( #79, #$0070, #$00B0, #00, #$1100 )
    COP [Die]
}

dialogstring_07B0A2 `[DEF][TPL:4]Lance: Yes, the words are [N]harder to say than [N]a tongue twister. [END]`

dialogstring_07B0E1 `[DEF][TPL:4][DLY:2]Lance: [N]Lilly... [N][PAU:1E]I love you...[END]`

dialogstring_07B108 `[DEF][TPL:4][DLY:2]Lance: [N]You don't have to [N]answer right away... [FIN]But, [PAU:1E]I wanted to [N]tell you how I feel...[PAL:0][END]`

dialogstring_07B158 `[TPL:A][TPL:4]Lance: [N]Lilly! Wait![PAU:3C][CLD]`

dialogstring_07B174 `[TPL:A][TPL:0]Will: [N]We had no idea [N]what had happened. [FIN]That day, Lilly didn't [N]come back to her room.[PAL:0][END]`

code_07B1C2 {
    COP [StageSpriteFrame] ( #3A )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [Die]
}