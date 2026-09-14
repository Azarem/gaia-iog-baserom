?BANK 00

?INCLUDE 'direction_velocity_table'
?INCLUDE 'forced_walk_sequence_table'
?INCLUDE 'movement_delta_table'

!joypadCurrent                  0656
!joypadMaskStd                  065A
!scrollStepTableBase            06E0
!scrollStepIndex                06E2
!playerActor                    09AA

---------------------------------------------

ForcedWalkSouth {
    LDA #$6000
    TRB $12
    COP [SetEntryContinue]
    LDA #$FFFF
    TSB $joypadMaskStd
    STZ $joypadCurrent
    JSR $&ReadDirSprite_YVelocity
    LDA #$2008
    TRB $10
    COP [StagePlayerSpriteFromBank]
    COP [AnimPlayerOnce]
    LDA #$2000
    TSB $10
    STZ $scrollStepIndex
    LDA $scrollStepTableBase
    AND #$00FF
    ASL 
    TAX 
    LDA $&forced_walk_sequence_table, X
    STA $scrollStepTableBase
    STZ $2A
    TDC 
    TAX 
    COP [SetEntryContinue]
    COP [PanCameraDown]
    JSR $&ApplyScrollOffset
    LDA #$2008
    TRB $10
    JSR $&ReadDirSprite_YVelocity
    COP [StagePlayerSpriteFromBank]
    COP [AnimPlayerOnce]
    JSR $&SyncPlayerToCamera
    LDA #$FFFF
    TRB $joypadMaskStd
    COP [Die]

  ForcedWalkNorth:
    LDA #$6000
    TRB $12
    COP [SetEntryContinue]
    LDA #$FFFF
    TSB $joypadMaskStd
    STZ $joypadCurrent
    JSR $&ReadDirSprite_YVelocity
    LDA #$2008
    TRB $10
    COP [StagePlayerSpriteFromBank]
    COP [AnimPlayerOnce]
    LDA #$2000
    TSB $10
    STZ $scrollStepIndex
    LDA $scrollStepTableBase
    AND #$00FF
    ASL 
    TAX 
    LDA $&forced_walk_sequence_table, X
    STA $scrollStepTableBase
    STZ $2A
    TDC 
    TAX 
    COP [SetEntryContinue]
    COP [PanCameraUp]
    JSR $&ApplyScrollOffset
    LDA #$2008
    TRB $10
    JSR $&ReadDirSprite_YVelocity
    COP [StagePlayerSpriteFromBank]
    COP [AnimPlayerOnce]
    JSR $&SyncPlayerToCamera
    LDA #$FFFF
    TRB $joypadMaskStd
    COP [Die]

  ForcedWalkWest:
    LDA #$6000
    TRB $12
    COP [SetEntryContinue]
    LDA #$FFFF
    TSB $joypadMaskStd
    STZ $joypadCurrent
    JSR $&ReadDirSprite_XVelocity
    LDA #$2008
    TRB $10
    COP [StagePlayerSpriteFromBank]
    COP [AnimPlayerOnce]
    LDA #$2000
    TSB $10
    STZ $scrollStepIndex
    LDA $scrollStepTableBase
    AND #$00FF
    ASL 
    TAX 
    LDA $&forced_walk_sequence_table, X
    STA $scrollStepTableBase
    STZ $2A
    TDC 
    TAX 
    COP [SetEntryContinue]
    COP [PanCameraLeft]
    JSR $&ApplyScrollOffset
    LDA #$2008
    TRB $10
    JSR $&ReadDirSprite_XVelocity
    COP [StagePlayerSpriteFromBank]
    COP [AnimPlayerOnce]
    JSR $&SyncPlayerToCamera
    LDA #$FFFF
    TRB $joypadMaskStd
    COP [Die]

  ForcedWalkEast:
    LDA #$6000
    TRB $12
    COP [SetEntryContinue]
    LDA #$FFFF
    TSB $joypadMaskStd
    STZ $joypadCurrent
    JSR $&ReadDirSprite_XVelocity
    LDA #$2008
    TRB $10
    COP [StagePlayerSpriteFromBank]
    COP [AnimPlayerOnce]
    LDA #$2000
    TSB $10
    STZ $scrollStepIndex
    LDA $scrollStepTableBase
    AND #$00FF
    ASL 
    TAX 
    LDA $&forced_walk_sequence_table, X
    STA $scrollStepTableBase
    STZ $2A
    TDC 
    TAX 
    COP [SetEntryContinue]
    COP [PanCameraRight]
    JSR $&ApplyScrollOffset
    LDA #$2008
    TRB $10
    JSR $&ReadDirSprite_XVelocity
    COP [StagePlayerSpriteFromBank]
    COP [AnimPlayerOnce]
    JSR $&SyncPlayerToCamera
    LDA #$FFFF
    TRB $joypadMaskStd
    COP [Die]
}
---------------------------------------------

ReadDirSprite_YVelocity {
    LDY $0650
    INC $0650
    LDA $0000, Y
    AND #$00FF
    ASL 
    TAY 
    LDA $&direction_velocity_table, Y
    STA $0000
    XBA 
    AND #$00FF
    ASL 
    TAY 
    LDA $&movement_delta_table, Y
    STA $2E
    RTS 
}

ReadDirSprite_XVelocity {
    LDY $0650
    INC $0650
    LDA $0000, Y
    AND #$00FF
    ASL 
    TAY 
    LDA $&direction_velocity_table, Y
    STA $0000
    XBA 
    AND #$00FF
    ASL 
    TAY 
    LDA $&movement_delta_table, Y
    STA $2C
    RTS 
}

ApplyScrollOffset {
    LDA $0650
    TAY 
    CLC 
    ADC #$0004
    STA $0650
    LDA $0000, Y
    CLC 
    ADC $14
    STA $14
    LDA $0002, Y
    CLC 
    ADC $16
    STA $16
    RTS 
}

SyncPlayerToCamera {
    LDY $playerActor
    LDA $14
    STA $0014, Y
    LDA $16
    STA $0016, Y
    LDA $10
    ORA #$0008
    AND #$FDFF
    STA $0010, Y
    LDA $28
    STA $0028, Y
    LDA #$0000
    STA $0008, Y
    RTS 
}