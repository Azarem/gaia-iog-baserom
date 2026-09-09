---------------------------------------------

av69_neil [
  actor-def < #13, #00, #18, {

  code_06BFFD:
    COP [BranchIfFlagByte] ( #8D, #01, &av69_neil_destroy )
    COP [BranchIfFlagByte] ( #75, #01, &av69_neil_destroy )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [StageSpriteLoopMoveY] ( #17, #04, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #19, #02, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #17, #04, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #18, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #16, #11 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveY] ( #17, #02, #13 )
    COP [AnimLoop]
} >
]

av69_neil_destroy {
    COP [Die]
}