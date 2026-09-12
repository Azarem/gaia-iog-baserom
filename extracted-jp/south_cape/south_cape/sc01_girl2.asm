---------------------------------------------

e_sc01_girl2 [
  actor-def < #1C, #00, #10, {

  code_048125:
    COP [SetOnInteract] ( &code_048154 )

  loc_048129:
    COP [SolidHighHere]

  loc_04812B:
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveX] ( #20, #02, #14 )
    COP [AnimLoop]
    COP [SolidHighHere]
    COP [BranchIfSolidWest] ( &code_048140 )
    BRA loc_04812B
} >
]

code_048140 {
    COP [SetFlagByte] ( #03 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveX] ( #21, #06, #11 )
    COP [AnimLoop]
    COP [ClearFlagByte] ( #02 )
    COP [ClearFlagByte] ( #03 )
    BRA loc_048129
}

code_048154 {
    COP [PrintDialogString] ( &dialogstring_048159 )
    RTL 
}

dialogstring_048159 `[DEF]しかし 不思議よね.[N]この遊びって なんで だるまさんが[N]ころんだって 言うのかしら···[END]`