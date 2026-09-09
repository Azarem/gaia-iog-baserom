---------------------------------------------

sc08_seth [
  actor-def < #13, #00, #18, {

  code_048D71:
    COP [BranchIfFlagByte] ( #10, #01, &code_048D93 )
    COP [ExitIfFlagByte] ( #10, #01 )
    COP [StageSpriteLoop] ( #14, #22 )
    COP [AnimLoop]
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [StageSpriteLoopMoveY] ( #17, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #19, #04, #11 )
    COP [AnimLoop]
} >
]

code_048D93 {
    COP [Die]
}