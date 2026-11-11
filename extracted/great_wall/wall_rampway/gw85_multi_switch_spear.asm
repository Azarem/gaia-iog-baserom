; Switch spear on the Great Wall rampway driven by scratch flag $04; two placements share it.
; 
; Solid frame #1D, WaitOnFlagByte ( #04, #01 ) for the hit_switch at tile (64,1D), ClearFlagByte of the same flag, retract frame #1E, WaitByte ( #77 ), then back to solid. The two placements at tiles (64,19) and (65,19) wait on the same flag and each clears it after leaving the wait, so the spear that is polled first consumes the trigger; whether the second one also retracts depends on the actor update order (not traced).
---------------------------------------------

---------------------------------------------

gw85_multi_switch_spear [
  actor-def < #1C, #00, #02, {

  loc_07BD78:
    COP [StageSpriteFrame] ( #1D )
    COP [AnimOnce]
    COP [MarkSolidHere]
    COP [MarkSolidOffset] ( #00, #03 )
    COP [WaitOnFlagByte] ( #04, #01 )
    COP [ClearFlagByte] ( #04 )
    COP [ClearSolidHere]
    COP [ClearSolidOffset] ( #00, #03 )
    LDA #$0100
    TSB $10
    COP [StageSpriteFrame] ( #1E )
    COP [AnimOnce]
    LDA #$0100
    TRB $10
    COP [WaitByte] ( #77 )
    BRA loc_07BD78
} >
]