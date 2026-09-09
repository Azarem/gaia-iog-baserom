---------------------------------------------

gw85_short_switch_spear [
  actor-def < #1C, #00, #02, {

  loc_07BD1A:
    COP [StageSpriteFrame] ( #1D )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SolidHighOffset] ( #00, #03 )
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [ClearFlagByte] ( #02 )
    COP [ClearLowHere]
    COP [ClearLowOffset] ( #00, #03 )
    LDA #$0100
    TSB $10
    COP [StageSpriteFrame] ( #1E )
    COP [AnimOnce]
    LDA #$0100
    TRB $10
    COP [WaitByte] ( #77 )
    BRA loc_07BD1A
} >
]