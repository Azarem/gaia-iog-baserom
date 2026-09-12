---------------------------------------------

daC3_merchant [
  actor-def < #05, #00, #10, {

  code_08A89E:
    COP [SetOnInteract] ( &code_08A8B2 )
    COP [SolidHighHere]
    COP [WaitByte] ( #EF )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveX] ( #08, #40, #12 )
    COP [AnimLoop]
    COP [Die]
} >
]

code_08A8B2 {
    COP [PrintDialogString] ( &dialogstring_08A8B7 )
    RTL 
}

dialogstring_08A8B7 `[DEF]Merchant:[N]I have fine goods for[N]sale today. You've never[N]seen carpets this nice.[END]`