!joypadMaskStd                  065A
!playerMaxHp                    0ACA

---------------------------------------------

ec0C_force_hint [
  actor-def < #00, #00, #20, {

  code_04DC95:
    LDA $playerMaxHp
    CMP #$0008
    BNE loc_04DCBB
    COP [SetEntryContinue]
    LDA $playerMaxHp
    CMP #$0008
    BNE loc_04DCA8
    RTL 

  loc_04DCA8:
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #27 )
    COP [PrintWideString] ( &widestring_04DCBD )
    LDA #$CFF0
    TRB $joypadMaskStd

  loc_04DCBB:
    COP [Die]
} >
]

widestring_04DCBD `[DEF][TPL:0][DLY:0]Will:[N]When you defeat all of[N]the enemies around you,[N]a Jewel will appear.[PAL:0][END]`