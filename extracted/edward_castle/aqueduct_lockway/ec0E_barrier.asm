; Barrier actors of the aqueduct lockway (scene $0E): ec0E_barrier and ec0E_barrier2-4 (scene_actors rows 15-18).
; 
; Each marks its tile solid and waits on scratch flag $01, which the single ec0E_switch toggles on every hit (8 wait sites). $01 set: the barrier clears its solid mark, slides (StageSpriteLoopMoveY then StageSpriteLoopMoveX; the first actor #04 steps each, barrier2 #02 steps with a #1F-tick pause), marks its new position solid and waits for $01 to clear, then slides back. The movement is scripted sprite stepping, not physics.
---------------------------------------------

---------------------------------------------

ec0E_barrier [
  actor-def < #3C, #10, #00, {

  loc_0A89E1:
    COP [MarkSolidHere]
    COP [WaitOnFlagByte] ( #01, #01 )
    COP [ClearSolidHere]
    COP [StageSpriteLoopMoveY] ( #3E, #04, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #3E, #04, #11 )
    COP [AnimLoop]
    COP [MarkSolidHere]
    COP [WaitOnFlagByte] ( #01, #00 )
    COP [ClearSolidHere]
    COP [StageSpriteLoopMoveX] ( #3E, #04, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #3E, #04, #11 )
    COP [AnimLoop]
    BRA loc_0A89E1
} >
]

ec0E_barrier2 [
  actor-def < #3C, #10, #00, {

  loc_0A8A12:
    COP [MarkSolidHere]
    COP [WaitOnFlagByte] ( #01, #01 )
    COP [ClearSolidHere]
    COP [StageSpriteLoopMoveY] ( #3E, #02, #12 )
    COP [AnimLoop]
    COP [WaitByte] ( #1F )
    COP [StageSpriteLoopMoveX] ( #3E, #02, #11 )
    COP [AnimLoop]
    COP [MarkSolidHere]
    COP [WaitOnFlagByte] ( #01, #00 )
    COP [ClearSolidHere]
    COP [StageSpriteLoopMoveX] ( #3E, #02, #12 )
    COP [AnimLoop]
    COP [WaitByte] ( #1F )
    COP [StageSpriteLoopMoveY] ( #3E, #02, #11 )
    COP [AnimLoop]
    BRA loc_0A8A12
} >
]

ec0E_barrier3 [
  actor-def < #3C, #10, #00, {

  loc_0A8A49:
    COP [MarkSolidHere]
    COP [WaitOnFlagByte] ( #01, #01 )
    COP [ClearSolidHere]
    COP [StageSpriteLoopMoveX] ( #3E, #02, #12 )
    COP [AnimLoop]
    COP [WaitByte] ( #1F )
    COP [StageSpriteLoopMoveY] ( #3E, #02, #12 )
    COP [AnimLoop]
    COP [MarkSolidHere]
    COP [WaitOnFlagByte] ( #01, #00 )
    COP [ClearSolidHere]
    COP [StageSpriteLoopMoveY] ( #3E, #02, #11 )
    COP [AnimLoop]
    COP [WaitByte] ( #1F )
    COP [StageSpriteLoopMoveX] ( #3E, #02, #11 )
    COP [AnimLoop]
    BRA loc_0A8A49
} >
]

ec0E_barrier4 [
  actor-def < #3C, #10, #00, {

  loc_0A8A80:
    COP [MarkSolidHere]
    COP [WaitOnFlagByte] ( #01, #01 )
    COP [ClearSolidHere]
    COP [StageSpriteLoopMoveX] ( #3E, #04, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #3E, #04, #12 )
    COP [AnimLoop]
    COP [MarkSolidHere]
    COP [WaitOnFlagByte] ( #01, #00 )
    COP [ClearSolidHere]
    COP [StageSpriteLoopMoveY] ( #3E, #04, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #3E, #04, #11 )
    COP [AnimLoop]
    BRA loc_0A8A80
} >
]