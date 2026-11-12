; Color addition effect for the Babel light elevator.
; 
; Technical thinker that applies additive color blending
; during the light elevator ride. Creates the ethereal
; glow effect as the elevator ascends.
---------------------------------------------

!CGADSUB                        2131

---------------------------------------------

babel_elevator_color_add [
  thinker-def < #00, #08, {

  code_00B791:
    COP [SetEntryHere]
    SEP #$20
    LDA #$02
    STA $CGADSUB          ; CGADSUB $02: colour math (add, not halved) on BG2 only; rewritten every frame by the SetEntryHere loop
    REP #$20
    RTL 
} >
]