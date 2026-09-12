---------------------------------------------

nvAE_erik [
  actor-def < #03, #00, #30, {

  code_089733:
    COP [BranchIfFlagByte] ( #B6, #01, &code_089771 )
    COP [BranchIfFlagByte] ( #CF, #01, &code_08975A )
    COP [ExitIfFlagByte] ( #BF, #01 )
    COP [ExitIfFlagByte] ( #C0, #01 )
    COP [ExitIfFlagByte] ( #C1, #01 )
    COP [WaitByte] ( #59 )
    LDA #$2000
    TRB $10
    COP [StageSpriteLoopMoveY] ( #07, #03, #02 )
    COP [AnimLoop]
} >
]

code_08975A {
    COP [SetTilePos] ( #08, #0A )
    LDA #$2000
    TRB $10
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_089773 )
    COP [SetEntryContinue]
    RTL 
}

code_089771 {
    COP [Die]
}

code_089773 {
    COP [PrintDialogString] ( &dialogstring_089778 )
    RTL 
}

dialogstring_089778 `[DEF][TPL:3]Erik: The traders [N]knew there was no food [N]here, and led [N]the children away. [FIN]A terrible story.[PAL:0][END]`