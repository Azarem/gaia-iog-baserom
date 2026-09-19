; Scroll-linked brightness thinker for the Seaside Palace coffin maze.
; 
; Reads cameraTargetY ($06C2), adds #$0080, shifts right 8 bits, masks to #$F8, then adds base #$E0 and writes the result to COLDATA ($2132). Screen brightness dims or brightens smoothly as the player scrolls vertically through the coffin room. Runs every frame via SetEntryContinue with no palette or HDMA involvement.
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