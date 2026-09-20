; Long-delay switch spear on the Great Wall rampway.
; 
; Wall spear trap with a longer timer cycle. Extends and
; retracts more slowly than the standard wall_spear. Used
; to create timing puzzles on the rampway section.
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