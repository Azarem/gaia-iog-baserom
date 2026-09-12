?INCLUDE 'cop_handlers_actors'
?INCLUDE 'oneshot_palette_flash_40'
?INCLUDE 'table_0EE000'

!joypadMaskStd                  065A
!playerActor                    09AA
!CGADSUB                        2131
!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

sp5D_fountain [
  actor-def < #26, #02, #03, {

  code_0693FB:
    STZ $066D
    COP [BranchIfFlagByte] ( #70, #01, &code_0694A8 )
    COP [BranchIfFlagByte] ( #6F, #00, &code_0694A8 )
    COP [BranchIfNoItem] ( #11, &code_069412 )
    JMP $&code_0694A8
} >
]

code_069412 {
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_0694AA )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [ExitIfFlagByte] ( #0E, #01 )
    LDA #$EFF0
    TSB $joypadMaskStd
    LDY $playerActor
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    SEC 
    SBC #$0010
    STA $16
    COP [SpawnMarkedAfter] ( @code_069502, #$2000 )
    COP [PlaySoundBoth] ( #$2525 )
    COP [SetSpritePriority] ( #30 )
    COP [LoopInit] ( #40 )
    COP [SetEntryExit]
    COP [StageSpriteMoveY] ( #26, #02 )
    COP [AnimOnce]
    COP [LoopNext]
    COP [WaitByte] ( #3B )
    LDA #$0100
    STA $moveXAlt, X
    LDA #$0160
    STA $moveYAlt, X
    COP [MoveToward] ( #26, #01 )
    LDA #$2000
    TSB $10
    SEP #$20
    LDA #$03
    STA $CGADSUB
    REP #$20
    COP [SpawnThinker] ( @oneshot_palette_flash_40.code_00B7F6 )
    COP [SetFlagByte] ( #0F )
    COP [WaitByte] ( #3B )
    COP [SpawnThinker] ( @oneshot_palette_flash_40.code_00B7F6 )
    COP [SpawnThinkerParam] ( #26, @cop_handlers_actors.PaletteResetAndKillThinker )
    COP [WaitWord] ( #$02B1 )
    COP [ClearFlagByte] ( #0F )
    COP [SetFlagByte] ( #70 )
    COP [ClearLowAbs] ( #0D, #0F )
    LDA #$EFF0
    TRB $joypadMaskStd
}

code_0694A8 {
    COP [Die]
}

dialogstring_0694AA `[DEF][TPL:2]Lilly: What!! It's a [N]strange fountain... [FIN]Could there be a[N]connection between this[N]and the rock...?[PAL:0][END]`

code_069502 {
    LDA $0036
    AND #$0003
    BNE loc_06951D
    LDY $04
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    STA $16
    COP [SpawnAfterFlags] ( @code_06951E, #$0B02 )

  loc_06951D:
    RTL 
}

code_06951E {
    COP [RngByte]
    AND #$0003
    DEC 
    CLC 
    ADC $14
    STA $14
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [Die]
}