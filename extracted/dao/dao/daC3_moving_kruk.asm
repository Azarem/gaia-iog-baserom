---------------------------------------------

daC3_moving_kruk [
  actor-def < #1A, #00, #10, {

  code_08AAE2:
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_08AB0C )
    COP [SolidHighHere]
    COP [WaitByte] ( #EF )
    COP [ClearLowHere]
    COP [SpawnAfterFlags] ( @code_08AB03, #$1001 )
    COP [StageSpriteLoopMoveXY] ( #1B, #40, #53, #54 )
    COP [AnimLoop]
    COP [Die]
} >
]

code_08AB03 {
    COP [StageSpriteLoopMoveX] ( #1C, #40, #53 )
    COP [AnimLoop]
    COP [Die]
}

code_08AB0C {
    COP [PrintDialogString] ( &dialogstring_08AB11 )
    RTL 
}

dialogstring_08AB11 `[DEF]Kiaaa...kiaaa...[END]`