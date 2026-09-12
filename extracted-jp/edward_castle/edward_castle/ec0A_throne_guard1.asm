---------------------------------------------

h_ec0A_throne_guard1 [
  actor-def < #1D, #00, #18, {

  code_04C196:
    COP [SetOnInteract] ( &code_04C1E3 )
    COP [SetSpritePriority] ( #30 )
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #0A, #01 )
    COP [ClearLowHere]
    COP [SetOnInteract] ( #$0000 )
    COP [StageSpriteLoopMoveX] ( #21, #04, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #1F, #03, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #20, #03, #12 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #1F, #12 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1D )
    COP [AnimOnce]
    LDA #$0800
    TRB $10
    COP [ExitIfFlagByte] ( #0C, #01 )
    COP [StageSpriteLoopMoveX] ( #21, #03, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #1E, #05, #11 )
    COP [AnimLoop]
    COP [SetEntryContinue]
    RTL 
} >
]

code_04C1E3 {
    COP [PrintDialogString] ( &dialogstring_04C1E8 )
    RTL 
}

dialogstring_04C1E8 `[DEF]兵士:[N]会見ならば うろうろせずに[N]国王に 話しかけよ.[END]`