; South Cape woman who sympathizes with Seth.
; 
; Single dialog about feeling sorry for Seth because of his parents
; fighting.
---------------------------------------------

---------------------------------------------

sc01_sympathetic_woman [
  actor-def < #14, #00, #10, {

  code_04893D:
    COP [SetOnInteract] ( &code_048999 )
    COP [SolidHighHere]
    COP [WaitByte] ( #EF )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveX] ( #19, #0C, #11 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #17, #12 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #18 )
    COP [AnimOnce]
    COP [DrawMetatileAbs] ( #15, #24, #F9 )
    LDA #$0200
    TSB $12
    COP [StageSpriteFrame] ( #3A )
    COP [AnimOnce]
    LDA #$0200
    TRB $12
    COP [StageSpriteMoveY] ( #2E, #11 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #30, #0C, #12 )
    COP [AnimLoop]
    LDA #$0200
    TSB $12
    COP [StageSpriteFrame] ( #3B )
    COP [AnimOnce]
    LDA #$0200
    TRB $12
    COP [DrawMetatileAbs] ( #09, #25, #F8 )
    COP [StageSpriteFrame] ( #14 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_048999 {
    COP [PrintDialogString] ( &dialogstring_04899E )
    RTL 
}

dialogstring_04899E `[DEF]I feel sorry[N]for Seth.[FIN]I understand why.  [N]He hates to see[N]his parents fighting[N]every day.[END]`