; Retractable gate on the Great Wall rampway (scene $85).
; 
; Solid gate at frame #1D (MarkSolidHere and MarkSolidOffset ( #00, #03 )). It waits on WaitOnFlagByte ( #01, #01 ), the scratch flag raised by the hit_switch at tile (18,1A), and clears the flag (one-shot trigger). It then clears its solid tiles, shows the retract frame #1E with $10 bit $0100 set during the animation, waits 120 ticks (WaitByte #77) and closes again, so every later hit re-opens it.
---------------------------------------------

---------------------------------------------

gw85_retractable_gate [
  actor-def < #1C, #00, #02, {

  loc_07BCEB:
    COP [StageSpriteFrame] ( #1D )
    COP [AnimOnce]
    COP [MarkSolidHere]
    COP [MarkSolidOffset] ( #00, #03 )
    COP [WaitOnFlagByte] ( #01, #01 )
    COP [ClearFlagByte] ( #01 )
    COP [ClearSolidHere]
    COP [ClearSolidOffset] ( #00, #03 )
    LDA #$0100
    TSB $10
    COP [StageSpriteFrame] ( #1E )
    COP [AnimOnce]
    LDA #$0100
    TRB $10
    COP [WaitByte] ( #77 )
    BRA loc_07BCEB
} >
]