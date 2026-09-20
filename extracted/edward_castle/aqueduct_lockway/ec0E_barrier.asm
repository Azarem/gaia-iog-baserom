; Aqueduct barrier/gate actor in the lockway.
; 
; Physics-driven barrier that opens when switches are pressed.
; Controls passage through the lockway puzzle area.
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