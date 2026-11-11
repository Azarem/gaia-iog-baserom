; Will's hint about enemy-clear jewels (scene $0C, aqueduct entrance).
; 
; Dies at spawn when playerMaxHp is not 8. With max HP 8 it yields every frame and, the moment playerMaxHp changes, locks the joypad ($CFFC), waits #$27 ticks, prints 'When you defeat all of the enemies around you, a Jewel will appear.' and unlocks. It reads and writes no event flag.
---------------------------------------------

!joypadMaskStd                  065A
!playerMaxHp                    0ACA

---------------------------------------------

ec0C_force_hint [
  actor-def < #00, #00, #20, {

  code_04DC95:
    LDA $playerMaxHp
    CMP #$0008
    BNE loc_04DCBB
    COP [SetEntryHere]
    LDA $playerMaxHp
    CMP #$0008
    BNE loc_04DCA8
    RTL 

  loc_04DCA8:
    LDA #$CFFC
    TSB $joypadMaskStd
    COP [WaitByte] ( #27 )
    COP [PrintDialogString] ( &dialogstring_04DCBD )
    LDA #$CFFC
    TRB $joypadMaskStd

  loc_04DCBB:
    COP [Die]
} >
]

dialogstring_04DCBD `[DEF][TPL:0][DLY:0]Will:[N]When you defeat all of[N]the enemies around you,[N]a Jewel will appear.[PAL:0][END]`