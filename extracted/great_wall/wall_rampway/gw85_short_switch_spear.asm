; Switch spear on the Great Wall rampway driven by scratch flag $02.
; 
; Same script as the retractable gate: solid frame #1D, WaitOnFlagByte ( #02, #01 ) for the hit_switch placements at tiles (3B,29) and (29,2B), ClearFlagByte of the same flag, retract frame #1E, WaitByte ( #77 ), then back to solid. The retract time is the same #77 ticks as in the other three rampway actors; the names "short" and "long" only distinguish the switch flag.
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