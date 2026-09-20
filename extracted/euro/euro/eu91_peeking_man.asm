; Peeking man in Euro — hides between buildings.
; 
; Animated NPC that peeks out from behind a building.
; No direct dialog. Suspicious character adding to Euro's
; atmosphere of hidden activity.
---------------------------------------------

---------------------------------------------

eu91_peeking_man [
  actor-def < #02, #00, #10, {

  code_07D054:
    COP [AddPosition] ( #08, #00 )
    COP [SetSpritePriority] ( #10 )

  loc_07D05B:
    COP [StageSpriteMoveY] ( #06, #11 )
    COP [AnimOnce]
    COP [WaitByte] ( #3B )
    COP [StageSpriteMoveY] ( #06, #12 )
    COP [AnimOnce]
    COP [WaitByte] ( #27 )
    COP [LoopInit] ( #02 )
    COP [StageSpriteLoopMoveX] ( #02, #02, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #02, #04, #03 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #02, #02, #04 )
    COP [AnimLoop]
    COP [LoopNext]
    COP [WaitByte] ( #3B )
    BRA loc_07D05B
} >
]