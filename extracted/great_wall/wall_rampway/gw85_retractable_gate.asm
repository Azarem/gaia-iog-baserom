; Retractable gate on the Great Wall rampway.
; 
; Gate that opens/closes based on switch states. When
; the corresponding switch is hit, retracts to allow passage.
; Returns to blocking state when switch resets.
---------------------------------------------

---------------------------------------------

gw85_retractable_gate [
  actor-def < #1C, #00, #02, {

  loc_07BCEB:
    COP [StageSpriteFrame] ( #1D )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SolidHighOffset] ( #00, #03 )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [ClearFlagByte] ( #01 )
    COP [ClearLowHere]
    COP [ClearLowOffset] ( #00, #03 )
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