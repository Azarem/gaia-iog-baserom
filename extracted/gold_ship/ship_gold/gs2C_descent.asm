?INCLUDE 'oneshot_palette_flash_1C'
?INCLUDE 'player_character'

!joypadMaskStd                  065A
!playerActor                    09AA
!TM                             212C
!CGADSUB                        2131
!COLDATA                        2132

---------------------------------------------

gs2C_descent [
  actor-def < #00, #00, #20, {

  code_05817C:
    COP [BranchIfFlagByte] ( #4C, #01, &code_0581FD )
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [SetFlagWord] ( #$0185 )
    SEP #$20
    LDA #$15
    STA $TM
    LDA #$B1
    STA $CGADSUB
    LDA #$FF
    STA $COLDATA
    REP #$20
    LDY $playerActor
    LDA #$00D0
    STA $0014, Y
    LDA #$0020
    STA $0016, Y
    LDA $0010, Y
    AND #$FFF7
    ORA #$0200
    STA $0010, Y
    SEP #$20
    LDA #$^player_character.loc_02C63B
    STA $0002, Y
    REP #$20
    LDA #$&player_character.loc_02C63B
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    STA $002A, Y
    COP [SetEntryContinue]
    COP [BranchIfPlayerAt] ( #$00D0, #$0240, &code_0581DD )
    RTL 
} >
]

code_0581DD {
    COP [LoopInit] ( #3C )
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [LoopNext]
    COP [SpawnThinker] ( @oneshot_palette_flash_1C.code_00B7EC )
    COP [WaitByte] ( #BF )
    COP [SetFlagByte] ( #4C )
    COP [PrintDialogString] ( &dialogstring_0581FF )
    LDA #$EFF0
    TRB $joypadMaskStd
}

code_0581FD {
    COP [Die]
}

dialogstring_0581FF `[DLG:3,12][SIZ:D,2][TPL:0]Will: This is the [N]Incan Gold Ship?! [FIN]What?! I feel like[N]someone's there...[PAL:0][END]`