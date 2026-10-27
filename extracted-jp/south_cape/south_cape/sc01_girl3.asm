---------------------------------------------

h_sc01_girl3 [
  actor-def < #1C, #00, #10, {

  code_048190:
    COP [SetInteractHandler] ( &code_0481B6 )

  loc_048194:
    COP [MarkSolidHere]

  code_048196:
    COP [WaitOnFlagByte] ( #02, #01 )
    COP [ClearSolidHere]
    COP [StageSpriteLoopMoveX] ( #20, #02, #14 )
    COP [AnimLoop]
    COP [MarkSolidHere]
    COP [BranchOnFlagByte] ( #03, #00, &code_048196 )
    COP [ClearSolidHere]
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