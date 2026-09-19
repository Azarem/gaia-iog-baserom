; One-shot hardware config thinker for the Babel Light Elevator shaft.
; 
; Uses SetEntryContinue to run every frame, writing #$02 to CGADSUB ($2131) to force subscreen-to-main color addition mode. Creates the bright ethereal additive glow as elevator subscreen graphics blend onto the main layer. No palette bundles or HDMA — a fixed PPU color-math register write only.
---------------------------------------------

!CGADSUB                        2131

---------------------------------------------

babel_elevator_color_add [
  thinker-def < #00, #08, {

  code_00B791:
    COP [SetEntryContinue]
    SEP #$20
    LDA #$02
    STA $CGADSUB
    REP #$20
    RTL 
} >
]