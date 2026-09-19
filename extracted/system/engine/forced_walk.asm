; Cutscene auto-walk and camera-pan actors (Bank 00) spawned by warps_interaction.StartForcedWalk during extended warp transitions.
; 
; ForcedWalkSouth/North/West/East each mask all joypad input, index forced_walk_sequence_table from scrollStepTableBase, pan the camera in the walk direction (PanCameraDown/Up/Left/Right), apply scroll offsets via ApplyScrollOffset, stage direction-specific player sprites from direction_velocity_table and movement_delta_table, and SyncPlayerToCamera before dying.
; 
; StartForcedWalk decodes scrollStepTableBase bit flags (bit 5=west, 4=east, 7=north, default south) and SpawnBefore the matching handler on the player actor while setting playerFlags $0100/$2000. ReadDirSprite_X/YVelocity helpers pull per-step deltas from the shared movement tables also used by hit stagger and world map travel.
---------------------------------------------

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

; Cutscene auto-walk actor spawned on the player by StartForcedWalk during extended warp transitions.
; 
; Masks all joypad input, indexes forced_walk_sequence_table from scrollStepTableBase, stages south-facing player sprites via ReadDirSprite_YVelocity, pans the camera down (PanCameraDown), applies scroll offsets, re-syncs the player sprite, and calls SyncPlayerToCamera before dying. Default direction when no east/west/north bit is set.

ForcedWalkSouth {
    LDA #$6000            ; ForcedWalkSouth: TSB joypadMaskStd $FFFF, zero joypadCurrent, mask $12 $6000
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

; Advances the forced-walk data stream and resolves south/north sprite frame plus Y-axis animation duration.
; 
; Increments the stream pointer at $0650, reads the next direction byte, looks up a base sprite frame in direction_velocity_table (stored to $0000), and fetches a movement-delta index into movement_delta_table (stored to $2E as frame duration). Has a sibling ReadDirSprite_XVelocity for east/west walks.

ReadDirSprite_YVelocity {
    LDY $0650             ; ReadDirSprite_YVelocity: pull step delta from direction_velocity_table to $2E
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
    LDY $playerActor      ; SyncPlayerToCamera: copy $14/$16 to player actor, set $0008 clear $0400
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