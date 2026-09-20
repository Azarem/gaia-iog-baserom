; Short-delay switch spear on the Great Wall rampway.
; 
; Wall spear trap with a shorter timer cycle. Faster
; extend/retract rhythm than the long variant. Creates
; tighter timing windows on the rampway.
---------------------------------------------

---------------------------------------------

gw85_short_switch_spear [
  actor-def < #1C, #00, #02, {

  loc_07BD1A:
    COP [StageSpriteFrame] ( #1D )
    COP [AnimOnce]
    COP [MarkSolidHere]
    COP [MarkSolidOffset] ( #00, #03 )
    COP [WaitOnFlagByte] ( #02, #01 )
    COP [ClearFlagByte] ( #02 )
    COP [ClearSolidHere]
    COP [ClearSolidOffset] ( #00, #03 )
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