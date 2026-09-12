---------------------------------------------

nvAD_erik [
  actor-def < #03, #00, #10, {

  code_088BA2:
    COP [BranchIfFlagByte] ( #B2, #01, &code_088BD1 )
    COP [BranchIfFlagByte] ( #AE, #01, &code_088BC3 )
    COP [BranchIfFlagByte] ( #AD, #00, &code_088BD1 )
    COP [SetOnInteract] ( &code_088BD3 )
    COP [ExitIfFlagByte] ( #AE, #01 )
    COP [StageSpriteLoopMoveY] ( #07, #04, #12 )
    COP [AnimLoop]
} >
]

code_088BC3 {
    COP [SetTilePos] ( #07, #0A )
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
}

code_088BD1 {
    COP [Die]
}

code_088BD3 {
    COP [PrintDialogString] ( &dialogstring_088BD8 )
    RTL 
}

dialogstring_088BD8 `[TPL:A][TPL:3]Erik: I'm exhausted. [N]I feel like sleeping [N]for days.[PAL:0][END]`