---------------------------------------------

sg55_falling_tile [
  actor-def < #0A, #01, #03, {

  code_0ACFE8:
    COP [ClearAllHere]
    COP [SetEntryContinue]
    COP [BranchOnPlayerY] ( #$0020, &code_0ACFF7, &code_0ACFF6, &code_0ACFF6 )
} >
]

code_0ACFF6 {
    RTL 
}

code_0ACFF7 {
    COP [SolidHighHere]
    COP [StageSpriteFrame] ( #0B )
    COP [AnimOnce]
    COP [Die]
}