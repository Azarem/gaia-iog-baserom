---------------------------------------------

sc01_girl3 [
  actor-def < #1C, #00, #10, {

  code_0481AB:
    COP [SetOnInteract] ( &code_0481D1 )

  loc_0481AF:
    COP [SolidHighHere]

  code_0481B1:
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveX] ( #20, #02, #14 )
    COP [AnimLoop]
    COP [SolidHighHere]
    COP [BranchIfFlagByte] ( #03, #00, &code_0481B1 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveX] ( #21, #06, #11 )
    COP [AnimLoop]
    BRA loc_0481AF
} >
]

code_0481D1 {
    COP [PrintWideString] ( &widestring_0481D6 )
    RTL 
}

widestring_0481D6 `[DEF]How long have we been [N]playing this?[END]`