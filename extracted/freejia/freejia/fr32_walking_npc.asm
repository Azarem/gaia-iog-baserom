---------------------------------------------

fr32_walking_npc [
  actor-def < #0A, #00, #10, {

  code_05B340:
    COP [SetSpritePriority] ( #10 )

  loc_05B343:
    COP [StageSpriteLoopMoveX] ( #11, #06, #11 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #10, #06, #12 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    BRA loc_05B343
} >
]