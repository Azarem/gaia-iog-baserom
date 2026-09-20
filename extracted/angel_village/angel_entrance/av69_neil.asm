; Neil at the Angel Village entrance — ambient party member.
; 
; NPC at the entrance. Positioned as part of the arriving
; party formation.
---------------------------------------------

---------------------------------------------

av69_neil [
  actor-def < #13, #00, #18, {

  code_06BFFD:
    COP [BranchOnFlagByte] ( #8D, #01, &av69_neil_destroy )
    COP [BranchOnFlagByte] ( #75, #01, &av69_neil_destroy )
    COP [WaitOnFlagByte] ( #01, #01 )
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