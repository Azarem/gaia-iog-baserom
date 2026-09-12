---------------------------------------------

h_sc01_salesman [
  actor-def < #0C, #00, #10, {

  code_0481DD:
    COP [SetOnInteract] ( &code_0482BA )
    COP [SetEntryContinue]
    COP [SolidHighHere]
    COP [WaitByte] ( #EF )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveY] ( #0E, #01, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #10, #0D, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #0F, #01, #12 )
    COP [AnimLoop]
    COP [SolidHighHere]
    COP [StageSpriteLoop] ( #0B, #78 )
    COP [AnimLoop]
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveY] ( #0E, #01, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #10, #07, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #0E, #04, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #11, #01, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveXY] ( #11, #03, #11, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #11, #01, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #0E, #0B, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #11, #04, #11 )
    COP [AnimLoop]
    COP [SolidHighHere]
    COP [StageSpriteLoop] ( #0B, #78 )
    COP [AnimLoop]
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveX] ( #10, #06, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveXY] ( #10, #04, #12, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #10, #06, #12 )
    COP [AnimLoop]
    COP [SolidHighHere]
    COP [StageSpriteLoop] ( #0B, #78 )
    COP [AnimLoop]
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveX] ( #10, #06, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #0E, #01, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #10, #05, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #0F, #01, #12 )
    COP [AnimLoop]
    COP [SolidHighHere]
    COP [StageSpriteLoop] ( #0B, #78 )
    COP [AnimLoop]
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveY] ( #0E, #01, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #11, #0C, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #0E, #01, #11 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    COP [SetOnInteract] ( &code_0482BF )
    COP [SolidHighHere]
    LDA #$0200
    TSB $12
    COP [SetEntryContinue]
    RTL 
} >
]

code_0482BA {
    COP [PrintDialogString] ( &dialogstring_0482C4 )
    RTL 
}

code_0482BF {
    COP [PrintDialogString] ( &dialogstring_048338 )
    RTL 
}

dialogstring_0482C4 `[DEF]セ-ルスマン:[N]おじさんは みんなの家をまわって[N]まものと 戦うための 武器を[N]売っているんだよ.[FIN]最近は ぶっそうな世の中だからね.[N]でも 子供の君に 武器を[N]売るわけには いかないもんなぁ.[END]`

dialogstring_048338 `[DEF]セ-ルスマン:[N]ふっ···[END]`