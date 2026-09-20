; South Cape girl commenting on the hide-and-seek game.
; 
; Single dialog about Red Light, Green Light. Part of the children
; playing scene.
---------------------------------------------

---------------------------------------------

sc01_girl2 [
  actor-def < #1C, #00, #10, {

  code_048137:
    COP [SetInteractHandler] ( &code_048166 )

  loc_04813B:
    COP [MarkSolidHere]

  loc_04813D:
    COP [WaitOnFlagByte] ( #02, #01 )
    COP [ClearSolidHere]
    COP [StageSpriteLoopMoveX] ( #20, #02, #14 )
    COP [AnimLoop]
    COP [MarkSolidHere]
    COP [BranchIfSolidWest] ( &code_048152 )
    BRA loc_04813D
} >
]

code_048152 {
    COP [SetFlagByte] ( #03 )
    COP [ClearSolidHere]
    COP [StageSpriteLoopMoveX] ( #21, #06, #11 )
    COP [AnimLoop]
    COP [ClearFlagByte] ( #02 )
    COP [ClearFlagByte] ( #03 )
    BRA loc_04813B
}

code_048166 {
    COP [PrintDialogString] ( &dialogstring_04816B )
    RTL 
}

dialogstring_04816B `[DEF]It's strange. This [N]game is like[N]"Red Light, [N]Green Lightˮ....[END]`