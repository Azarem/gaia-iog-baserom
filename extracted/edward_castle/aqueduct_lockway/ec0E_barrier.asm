---------------------------------------------

ec0E_barrier [
  actor-def < #3C, #10, #00, {

  loc_0A89E1:
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveY] ( #3E, #04, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #3E, #04, #11 )
    COP [AnimLoop]
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #01, #00 )
    COP [ClearLowHere]
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
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveY] ( #3E, #02, #12 )
    COP [AnimLoop]
    COP [WaitByte] ( #1F )
    COP [StageSpriteLoopMoveX] ( #3E, #02, #11 )
    COP [AnimLoop]
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #01, #00 )
    COP [ClearLowHere]
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
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveX] ( #3E, #02, #12 )
    COP [AnimLoop]
    COP [WaitByte] ( #1F )
    COP [StageSpriteLoopMoveY] ( #3E, #02, #12 )
    COP [AnimLoop]
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #01, #00 )
    COP [ClearLowHere]
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
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveX] ( #3E, #04, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #3E, #04, #12 )
    COP [AnimLoop]
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #01, #00 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveY] ( #3E, #04, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #3E, #04, #11 )
    COP [AnimLoop]
    BRA loc_0A8A80
} >
]