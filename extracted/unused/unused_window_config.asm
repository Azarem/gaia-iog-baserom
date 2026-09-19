; Unused window object select configuration actor.
; 
; Writes #$A0 to WOBJSEL ($2125) via 8-bit mode, then returns.
; Sets window 1 inversion for BG3/BG4. No references.
---------------------------------------------

!WOBJSEL                        2125

---------------------------------------------

unused_window_config [
  actor-def < #00, #00, #20, {

  code_0ADB3B:
    SEP #$20
    LDA #$A0
    STA $WOBJSEL
    REP #$20
    RTL 
} >
]