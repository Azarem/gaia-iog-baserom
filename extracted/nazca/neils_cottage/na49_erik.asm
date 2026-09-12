---------------------------------------------

na49_erik [
  actor-def < #0B, #00, #10, {

  code_05E298:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05E2C9 )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [StageSpriteLoopMoveY] ( #0F, #05, #12 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #0B )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #05, #01 )
    COP [StageSpriteMoveY] ( #0F, #12 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #10, #03, #12 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #0C )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_05E2C9 {
    COP [PrintDialogString] ( &dialogstring_05E2CE )
    RTL 
}

dialogstring_05E2CE `[TPL:A][TPL:3]Erik: Seth will be [N]pleased when he [N]sees this invention...[END]`