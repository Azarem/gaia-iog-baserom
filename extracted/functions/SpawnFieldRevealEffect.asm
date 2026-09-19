; Dark Space room-clear reveal cutscene effect.
; 
; Animates a rising sprite sequence, moves toward target coordinates from event_block_table via deathActionIdx, spawns flash and scatter particle children, waits, then calls StageBgChangeFromDeathIdx to swap the room background. Used after defeating enemies that unlock a field reveal (Pyramid mystic ball, Angkor wall walker). The visual centerpiece of the "room cleared" transformation.
---------------------------------------------

?INCLUDE 'event_block_table'
?INCLUDE 'spriteset_enemies'

!orbitAngle                     7F0010
!orbitDiameter                  7F0012
!moveXAlt                       7F0018
!moveYAlt                       7F001A
!deathActionIdx                 7F0024

---------------------------------------------

SpawnFieldRevealEffect {
    COP [SetSpritePalette] ( #00 )
    LDA #$0342
    STA $10
    LDA #$6000
    TRB $12
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [StageSpriteMoveY] ( #29, #02 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #29, #12 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #29, #14 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #29, #02 )
    COP [AnimLoop]
    COP [SetSpritePriority] ( #30 )
    LDA $deathActionIdx, X
    ASL 
    ASL 
    ASL 
    TAY 
    LDA $&event_block_table+3, Y
    AND #$00FF
    STA $0000
    LSR 
    STA $orbitAngle, X
    LDA $&event_block_table+5, Y
    AND #$00FF
    ASL 
    CLC 
    ADC $0000
    ASL 
    ASL 
    ASL 
    STA $moveXAlt, X
    LDA $&event_block_table+4, Y
    AND #$00FF
    STA $0000
    LSR 
    STA $orbitDiameter, X
    LDA $&event_block_table+6, Y
    AND #$00FF
    ASL 
    CLC 
    ADC $0000
    ASL 
    ASL 
    ASL 
    STA $moveYAlt, X
    COP [StageMove] ( #29, #04, #FF )
    COP [TickMove]
    COP [SpawnAfterFlags] ( @field_reveal_flash, #$0302 )
    LDA $0012, Y
    ORA #$1000
    STA $0012, Y
    COP [WaitByte] ( #01 )
    LDA #$2000
    TSB $10
    COP [LoopInit] ( #0A )
    COP [SpawnAfterFlags] ( @field_reveal_scatter, #$0302 )
    LDA $0012, Y
    ORA #$1000
    STA $0012, Y
    LDA $orbitAngle, X
    AND #$00FF
    STA $0020, Y
    LDA $orbitDiameter, X
    AND #$00FF
    STA $0022, Y
    COP [WaitByte] ( #03 )
    COP [LoopNext]
    COP [StageBgChangeFromDeathIdx]
    COP [ApplyBgChange]
    COP [Die]
}

field_reveal_scatter {
    COP [RngByte]
    LDY $20
    CPY #$0004
    BCS loc_00DECC
    CPY #$0002
    BCS loc_00DED2
    LSR 
    AND #$000F
    BRA loc_00DED6

  loc_00DECC:
    LSR 
    AND #$003F
    BRA loc_00DED6

  loc_00DED2:
    LSR 
    AND #$001F

  loc_00DED6:
    BCC loc_00DEDC
    EOR #$FFFF
    INC 

  loc_00DEDC:
    CLC 
    ADC $14
    STA $14
    COP [RngByte]
    LDY $22
    CPY #$0003
    BCS loc_00DEF5
    CPY #$0002
    BEQ loc_00DEFB
    LSR 
    AND #$000F
    BRA loc_00DEFF

  loc_00DEF5:
    LSR 
    AND #$003F
    BRA loc_00DEFF

  loc_00DEFB:
    LSR 
    AND #$001F

  loc_00DEFF:
    BCC loc_00DF05
    EOR #$FFFF
    INC 

  loc_00DF05:
    CLC 
    ADC $16
    STA $16
}

field_reveal_flash {
    COP [PlaySoundBoth] ( #$0606 )
    COP [StageSpriteFrame] ( #25 )
    COP [AnimOnce]
    COP [Die]
}