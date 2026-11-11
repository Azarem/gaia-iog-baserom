; Switch spear on the Great Wall rampway driven by scratch flag $03.
; 
; Solid frame #1F, WaitOnFlagByte ( #03, #01 ) for the hit_switch at tile (37,2C), ClearFlagByte of the same flag, retract frame #20, WaitByte ( #77 ), then back to solid. The retract time equals the other rampway actors; the script differs only in flag and frames.
---------------------------------------------

---------------------------------------------

gw85_long_switch_spear [
  actor-def < #1C, #00, #02, {

  loc_07BD49:
    COP [StageSpriteFrame] ( #1F )
    COP [AnimOnce]
    COP [MarkSolidHere]
    COP [MarkSolidOffset] ( #00, #03 )
    COP [WaitOnFlagByte] ( #03, #01 )
    COP [ClearFlagByte] ( #03 )
    COP [ClearSolidHere]
    COP [ClearSolidOffset] ( #00, #03 )
    LDA #$0100
    TSB $10
    COP [StageSpriteFrame] ( #20 )
    COP [AnimOnce]
    LDA #$0100
    TRB $10
    COP [WaitByte] ( #77 )
    BRA loc_07BD49
} >
]