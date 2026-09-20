; South Cape woman worried about strange merchants.
; 
; Multi-state dialog gated by game progress flags. Initially worried
; about merchants, dialog changes as story progresses.
---------------------------------------------

---------------------------------------------

sc01_worried_woman [
  actor-def < #15, #00, #10, {

  code_048657:
    COP [SetInteractHandler] ( &code_048719 )
    COP [MarkSolidHere]
    COP [WaitByte] ( #B3 )
    COP [StageSpriteFrame] ( #14 )
    COP [AnimOnce]
    COP [WaitByte] ( #77 )
    COP [StageSpriteFrame] ( #15 )
    COP [AnimOnce]
    COP [JumpAfterDelay] ( @code_048674, #$053C )
} >
]

code_048674 {
    COP [DrawMetatileAbs] ( #2C, #0E, #F9 )
    LDA #$0200
    TSB $12
    COP [StageSpriteFrame] ( #3C )
    COP [AnimOnce]
    LDA #$0200
    TRB $12
    COP [ClearSolidHere]
    COP [StageSpriteMoveY] ( #2E, #11 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #30, #10, #12 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #2F, #12 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #2C )
    COP [AnimOnce]
    COP [WaitByte] ( #1D )
    COP [StageSpriteFrame] ( #2D )
    COP [AnimOnce]
    LDA #$0200
    TSB $12
    COP [StageSpriteFrame] ( #3D )
    COP [AnimOnce]
    LDA #$0200
    TRB $12
    COP [DrawMetatileAbs] ( #1C, #0E, #F8 )
    COP [StageSpriteFrame] ( #14 )
    COP [AnimOnce]
    COP [MarkSolidHere]
    COP [WaitByte] ( #EF )
    COP [ClearSolidHere]
    COP [StageSpriteFrame] ( #15 )
    COP [AnimOnce]
    COP [DrawMetatileAbs] ( #1C, #0E, #F9 )
    LDA #$0200
    TSB $12
    COP [StageSpriteFrame] ( #3C )
    COP [AnimOnce]
    LDA #$0200
    TRB $12
    COP [StageSpriteMoveY] ( #2E, #11 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #31, #10, #11 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #2F, #12 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #2D )
    COP [AnimOnce]
    LDA #$0200
    TSB $12
    COP [StageSpriteFrame] ( #3D )
    COP [AnimOnce]
    LDA #$0200
    TRB $12
    COP [DrawMetatileAbs] ( #2C, #0E, #F8 )
    COP [StageSpriteFrame] ( #15 )
    COP [AnimOnce]
    COP [MarkSolidHere]
    COP [SetEntryHere]
    RTL 
}

code_048719 {
    COP [PrintDialogString] ( &dialogstring_04871E )
    RTL 
}

dialogstring_04871E `[DEF]I'm worried. There's[N]been a lot of strange[N]merchants lately[N]doing business...[END]`