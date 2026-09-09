---------------------------------------------

sc01_girl2 [
  actor-def < #1C, #00, #10, {

  code_048137:
    COP [SetOnInteract] ( &code_048166 )

  loc_04813B:
    COP [SolidHighHere]

  loc_04813D:
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveX] ( #20, #02, #14 )
    COP [AnimLoop]
    COP [SolidHighHere]
    COP [BranchIfSolidWest] ( &code_048152 )
    BRA loc_04813D
} >
]

code_048152 {
    COP [SetFlagByte] ( #03 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveX] ( #21, #06, #11 )
    COP [AnimLoop]
    COP [ClearFlagByte] ( #02 )
    COP [ClearFlagByte] ( #03 )
    BRA loc_04813B
}

code_048166 {
    COP [PrintWideString] ( &widestring_04816B )
    RTL 
}

widestring_04816B `[DEF]It's strange. This [N]game is like[N]"Red Light, [N]Green Lightˮ....[END]`