?INCLUDE 'stats_01ABF0'

!statsPtr                       7F0020

---------------------------------------------

mu64_switch_spikes [
  actor-def < #2A, #01, #03, {

  code_069D22:
    LDA #$&stats_01ABF0
    STA $statsPtr, X

  loc_069D29:
    COP [StageSpriteFrame] ( #2A )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #0F, #01 )
    COP [ClearLowHere]
    COP [StageSpriteFrame] ( #2B )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #28 )
    COP [AnimOnce]
    COP [WaitByte] ( #C7 )
    COP [StageSpriteFrame] ( #29 )
    COP [AnimOnce]
    COP [ClearFlagByte] ( #0F )
    BRA loc_069D29
} >
]