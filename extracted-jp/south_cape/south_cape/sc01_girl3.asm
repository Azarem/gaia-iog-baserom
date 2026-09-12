---------------------------------------------

h_sc01_girl3 [
  actor-def < #1C, #00, #10, {

  code_048190:
    COP [SetOnInteract] ( &code_0481B6 )

  loc_048194:
    COP [SolidHighHere]

  code_048196:
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveX] ( #20, #02, #14 )
    COP [AnimLoop]
    COP [SolidHighHere]
    COP [BranchIfFlagByte] ( #03, #00, &code_048196 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveX] ( #21, #06, #11 )
    COP [AnimLoop]
    BRA loc_048194
} >
]

code_0481B6 {
    COP [PrintDialogString] ( &dialogstring_0481BB )
    RTL 
}

dialogstring_0481BB `[DEF]あたしたちって いつから[N]この遊び やってるんだろう··[END]`