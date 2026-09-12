---------------------------------------------

h_sc01_astronomer [
  actor-def < #02, #00, #10, {

  code_0487E2:
    COP [SetOnInteract] ( &code_048886 )
    COP [SolidHighHere]
    COP [WaitByte] ( #EF )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveY] ( #07, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #09, #03, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveXY] ( #09, #04, #11, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #09, #05, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #06, #02, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #09, #02, #11 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [WaitByte] ( #EF )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveX] ( #08, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #07, #12 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #08, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #07, #0C, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #08, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveXY] ( #08, #03, #12, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #08, #06, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #07, #05, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #09, #06, #11 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [WaitByte] ( #EF )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveY] ( #07, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #09, #11 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_048886 {
    COP [PrintDialogString] ( &dialogstring_04888B )
    RTL 
}

dialogstring_04888B `[DEF]知り合いの 天文学者が[N]変なことを いうんだよ.[N]この地球に向かって[N]近づいている星が あるとかってね.[END]`