!joypadRaw                      0660
!joypadInject                   09AC

---------------------------------------------

sg4C_auto_advance [
  actor-def < #00, #00, #28, {

  code_0AB499:
    LDA $00B4
    BEQ loc_0AB4AE
    COP [LoopInit] ( #3C )
    LDA $joypadRaw
    BNE loc_0AB4AE
    COP [LoopNext]
    LDA #$FFFF
    STA $joypadInject

  loc_0AB4AE:
    COP [Die]
} >
]