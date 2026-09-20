; Scroll-linked brightness thinker for the Seaside Palace.
; 
; Adjusts screen brightness based on scroll position to
; create the dim, underwater atmosphere of the palace.
---------------------------------------------

!cameraTargetY                  06C2
!COLDATA                        2132

---------------------------------------------

palace_scroll_brightness [
  thinker-def < #04, #08, {

  code_00B79F:
    COP [SetEntryContinue]
    LDA $cameraTargetY
    CLC 
    ADC #$0080
    LSR 
    LSR 
    LSR 
    LSR 
    AND #$00F8
    LSR 
    LSR 
    LSR 
    CLC 
    ADC #$00E0
    SEP #$20
    STA $COLDATA
    REP #$20
    RTL 
} >
]