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
    LDA #$6000            ; Clear direction flags $6000 from secondary status $12
    TRB $12
    COP [SetEntryContinue]
    LDA #$FFFF            ; Mask ALL joypad input — player cannot control during forced walk
    TSB $joypadMaskStd
    STZ $joypadCurrent    ; Zero current input — suppress all player control
    JSR $&ReadDirSprite_YVelocity ; Look up south walk sprite and Y-axis frame duration
    LDA #$2008            ; Clear flags $2008 (climb + grounded) for forced-walk mode
    TRB $10
    COP [StagePlayerSpriteFromBank] ; Index forced_walk_sequence_table from scrollStepTableBase low byte ×2
    COP [AnimPlayerOnce]
    LDA #$2000
    TSB $10
    STZ $scrollStepIndex  ; Reset scroll step index to start of walk sequence
    LDA $scrollStepTableBase ; scrollStepTableBase low byte = walk sequence ID
    AND #$00FF
    ASL                   ; ×2 for word-sized table index
    TAX 
    LDA $&forced_walk_sequence_table, X ; Look up walk sequence data pointer from forced_walk_sequence_table
    STA $scrollStepTableBase
    STZ $2A
    TDC                   ; TDC/TAX: restore actor slot address to X register
    TAX 
    COP [SetEntryContinue]
    COP [PanCameraDown]   ; Pan camera southward — yields until camera finishes scrolling
    JSR $&ApplyScrollOffset ; Apply position offset from walk sequence data to actor
    LDA #$2008
    TRB $10
    JSR $&ReadDirSprite_YVelocity ; Re-read next sprite frame for post-pan walk animation
    COP [StagePlayerSpriteFromBank]
    COP [AnimPlayerOnce]
    JSR $&SyncPlayerToCamera ; Sync player position/flags to match camera after forced walk
    LDA #$FFFF
    TRB $joypadMaskStd    ; Unmask all joypad — forced walk finished, return control
    COP [Die]

  ForcedWalkNorth:
    LDA #$6000            ; ForcedWalkNorth: identical structure to South but PanCameraUp
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
    LDA #$6000            ; ForcedWalkWest: uses ReadDirSprite_XVelocity and PanCameraLeft
    TRB $12
    COP [SetEntryContinue]
    LDA #$FFFF
    TSB $joypadMaskStd
    STZ $joypadCurrent
    JSR $&ReadDirSprite_XVelocity ; X velocity for horizontal walk direction
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
    LDA #$6000            ; ForcedWalkEast: ReadDirSprite_XVelocity + PanCameraRight
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
    INC $0650             ; Advance data stream pointer to next walk-step entry
    LDA $0000, Y          ; Advance walk data stream pointer to next step entry
    AND #$00FF            ; Read direction byte from walk data at $0650
    ASL 
    TAY 
    LDA $&direction_velocity_table, Y ; direction_velocity_table: sprite frame + velocity per direction
    STA $0000             ; Store sprite frame in $0000 for StagePlayerSpriteFromBank
    XBA                   ; XBA: swap to high byte = movement delta index
    AND #$00FF
    ASL 
    TAY 
    LDA $&movement_delta_table, Y ; Look up frame duration from movement_delta_table
    STA $2E               ; Store Y-axis frame duration to $2E
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
    STA $2C               ; X-axis duration → $2C (sibling of ReadDirSprite_YVelocity)
    RTS 
}

ApplyScrollOffset {
    LDA $0650             ; Load current data stream position
    TAY 
    CLC 
    ADC #$0004            ; Advance past 4-byte (X word + Y word) scroll offset record
    STA $0650
    LDA $0000, Y          ; Read and add X scroll offset to actor X
    CLC 
    ADC $14               ; Add X scroll offset to actor X position
    STA $14
    LDA $0002, Y          ; Read Y scroll offset from walk data
    CLC 
    ADC $16               ; Add Y scroll offset to actor Y position
    STA $16
    RTS 
}

SyncPlayerToCamera {
    LDY $playerActor      ; SyncPlayerToCamera: copy $14/$16 to player actor, set $0008 clear $0400
    LDA $14               ; Copy local X to player actor X position
    STA $0014, Y
    LDA $16               ; Copy local Y to player actor Y position
    STA $0016, Y
    LDA $10
    ORA #$0008            ; Set grounded flag $0008 on player
    AND #$FDFF            ; Clear $0200 flag on player
    STA $0010, Y
    LDA $28               ; Sync animation index to player actor
    STA $0028, Y
    LDA #$0000            ; Zero player frame counter
    STA $0008, Y
    RTS 
}