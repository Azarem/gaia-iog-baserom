; Auto-advance trigger for Sky Garden level transitions.
; 
; Invisible actor that checks position/flag conditions and
; automatically advances the player to the next garden section
; without interaction. Used for seamless area transitions.
---------------------------------------------

!joypadRaw                      0660
!joypadInject                   09AC

---------------------------------------------

sg4C_auto_advance [
  actor-def < #00, #00, #28, {

  code_0AB499:
    LDA $00B4
    BEQ loc_0AB4AE
    COP [LoopStart] ( #3C )
    LDA $joypadRaw
    BNE loc_0AB4AE
    COP [LoopEnd]
    LDA #$FFFF
    STA $joypadInject

  loc_0AB4AE:
    COP [Die]
} >
]