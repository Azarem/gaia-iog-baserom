; Erik at the Angel Village entrance — ambient party member.
; 
; NPC at the tunnel entrance. No direct dialog in initial
; state — positioned as part of the party formation entering
; the village.
---------------------------------------------

---------------------------------------------

av69_erik [
  actor-def < #0B, #00, #18, {

  code_06C46D:
    COP [BranchIfFlagByte] ( #8D, #01, &av69_erik_destroy )
    COP [BranchIfFlagByte] ( #75, #01, &av69_erik_destroy )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [WaitByte] ( #1D )
    COP [StageSpriteLoopMoveY] ( #0F, #05, #12 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #11, #11 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveY] ( #0F, #04, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #0C, #1E )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #04, #01 )
    COP [StageSpriteLoopMoveX] ( #10, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #0E, #11 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveY] ( #0F, #02, #13 )
    COP [AnimLoop]
} >
]

av69_erik_destroy {
    COP [Die]
}