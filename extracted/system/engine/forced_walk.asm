; Cutscene auto-walk actors (Bank 00) spawned by warps_interaction.StartForcedWalk during extended warp transitions.
; 
; StartForcedWalk decodes the direction from scrollStepTableBase (bit 5 = west, bit 4 = east, bit 7 = north, default south), sets playerFlags $0100 and spawns the matching ForcedWalkSouth/North/West/East on the player actor (SpawnBefore).
; 
; The warp entry gives two things: the walk-step stream pointed to by warpFacing ($0650, a pointer to warp entry +7) and the walk sequence index in scrollStepTableBase. Stream layout, 6 bytes: [direction byte][X offset word][Y offset word][direction byte]. A direction byte indexes direction_velocity_table, whose entry is (animation index, index into movement_delta_table); movement_delta_table entries are delta-node lists, so ReadDirSprite_*Velocity leaves a velocity-curve pointer in $2E (Y) or $2C (X).
; 
; Each ForcedWalk* actor: masks all joypad input, reads the first direction byte, stages the player sprite (StagePlayerSprFromDP, animation index from DP $0000), replaces scrollStepTableBase with the pointer to the word scroll-step list from forced_walk_sequence_table (read by CameraScrollStepLookup, ends at a zero word), pans the camera in the walk direction (CameraPan*), adds the stream's X/Y offset words to its own position (ApplyScrollOffset), reads the second direction byte, stages the final sprite, copies position and state to the player (SyncPlayerToCamera), unmasks the joypad and dies.
; 
; The direction variants differ only in the ReadDirSprite helper (Y velocity for south/north, X for west/east) and the CameraPan* COP.
---------------------------------------------

?BANK 00

?INCLUDE 'direction_velocity_table'
?INCLUDE 'forced_walk_sequence_table'
?INCLUDE 'movement_delta_table'

!warpFacing                     0650
!joypadCurrent                  0656
!joypadMaskStd                  065A
!scrollStepTableBase            06E0
!scrollStepIndex                06E2
!playerActor                    09AA

---------------------------------------------

; Cutscene auto-walk actor spawned on the player by StartForcedWalk during extended warp transitions (default direction when no west/east/north bit is set).
; 
; Masks all joypad input, reads the first stream direction byte with ReadDirSprite_YVelocity, stages the player sprite, loads the walk sequence pointer from forced_walk_sequence_table into scrollStepTableBase, pans the camera down (CameraPanDown), applies the stream's position offset, reads the next direction byte, re-stages the sprite, syncs the player and dies. The North/West/East labels below follow the same sequence.

ForcedWalkSouth {
    LDA #$6000            ; Clear direction flags $6000 from secondary status $12
    TRB $12
    COP [SetEntryHere]
    LDA #$FFFF            ; Mask ALL joypad input — player cannot control during forced walk
    TSB $joypadMaskStd
    STZ $joypadCurrent    ; Zero current input — suppress all player control
    JSR $&ReadDirSprite_YVelocity ; First stream byte → animation index ($0000) and Y velocity curve ($2E)
    LDA #$2008            ; Clear $2008 in own $10 (bit meanings unverified, OQ-60)
    TRB $10
    COP [StagePlayerSprFromDP] ; Stage the player sprite: animation index = DP $0000 (set by ReadDirSprite_*)
    COP [RunPlayerAnim]
    LDA #$2000
    TSB $10
    STZ $scrollStepIndex  ; Reset scroll step index to start of walk sequence
    LDA $scrollStepTableBase ; scrollStepTableBase low byte = walk sequence ID
    AND #$00FF
    ASL                   ; ×2 for word-sized table index
    TAX 
    LDA $&forced_walk_sequence_table, X ; Look up walk sequence data pointer from forced_walk_sequence_table
    STA $scrollStepTableBase ; scrollStepTableBase now = pointer to the word scroll-step list used by CameraScrollStepLookup
    STZ $2A
    TDC                   ; TDC/TAX: restore actor slot address to X register
    TAX 
    COP [SetEntryHere]
    COP [CameraPanDown]   ; Pan camera southward — yields until camera finishes scrolling
    JSR $&ApplyScrollOffset ; Add the stream's X/Y offset words to this actor's position (stream pointer += 4)
    LDA #$2008
    TRB $10
    JSR $&ReadDirSprite_YVelocity ; Re-read next sprite frame for post-pan walk animation
    COP [StagePlayerSprFromDP]
    COP [RunPlayerAnim]
    JSR $&SyncPlayerToCamera ; Sync player position/flags to match camera after forced walk
    LDA #$FFFF
    TRB $joypadMaskStd    ; Unmask all joypad — forced walk finished, return control
    COP [Die]

; Same sequence as ForcedWalkSouth with ReadDirSprite_YVelocity and CameraPanUp.

  ForcedWalkNorth:
    LDA #$6000            ; ForcedWalkNorth: identical structure to South but PanCameraUp
    TRB $12
    COP [SetEntryHere]
    LDA #$FFFF
    TSB $joypadMaskStd
    STZ $joypadCurrent
    JSR $&ReadDirSprite_YVelocity
    LDA #$2008
    TRB $10
    COP [StagePlayerSprFromDP]
    COP [RunPlayerAnim]
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
    COP [SetEntryHere]
    COP [CameraPanUp]
    JSR $&ApplyScrollOffset
    LDA #$2008
    TRB $10
    JSR $&ReadDirSprite_YVelocity
    COP [StagePlayerSprFromDP]
    COP [RunPlayerAnim]
    JSR $&SyncPlayerToCamera
    LDA #$FFFF
    TRB $joypadMaskStd
    COP [Die]

; Same sequence as ForcedWalkSouth with ReadDirSprite_XVelocity and CameraPanLeft.

  ForcedWalkWest:
    LDA #$6000            ; ForcedWalkWest: uses ReadDirSprite_XVelocity and PanCameraLeft
    TRB $12
    COP [SetEntryHere]
    LDA #$FFFF
    TSB $joypadMaskStd
    STZ $joypadCurrent
    JSR $&ReadDirSprite_XVelocity ; X velocity for horizontal walk direction
    LDA #$2008
    TRB $10
    COP [StagePlayerSprFromDP]
    COP [RunPlayerAnim]
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
    COP [SetEntryHere]
    COP [CameraPanLeft]
    JSR $&ApplyScrollOffset
    LDA #$2008
    TRB $10
    JSR $&ReadDirSprite_XVelocity
    COP [StagePlayerSprFromDP]
    COP [RunPlayerAnim]
    JSR $&SyncPlayerToCamera
    LDA #$FFFF
    TRB $joypadMaskStd
    COP [Die]

; Same sequence as ForcedWalkSouth with ReadDirSprite_XVelocity and CameraPanRight.

  ForcedWalkEast:
    LDA #$6000            ; ForcedWalkEast: ReadDirSprite_XVelocity + PanCameraRight
    TRB $12
    COP [SetEntryHere]
    LDA #$FFFF
    TSB $joypadMaskStd
    STZ $joypadCurrent
    JSR $&ReadDirSprite_XVelocity
    LDA #$2008
    TRB $10
    COP [StagePlayerSprFromDP]
    COP [RunPlayerAnim]
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
    COP [SetEntryHere]
    COP [CameraPanRight]
    JSR $&ApplyScrollOffset
    LDA #$2008
    TRB $10
    JSR $&ReadDirSprite_XVelocity
    COP [StagePlayerSprFromDP]
    COP [RunPlayerAnim]
    JSR $&SyncPlayerToCamera
    LDA #$FFFF
    TRB $joypadMaskStd
    COP [Die]
}
---------------------------------------------

; Read the next walk-step stream byte and set up the sprite and the Y velocity curve for it.
; 
; Y = stream pointer (warpFacing, $0650), incremented by one. The byte indexes direction_velocity_table (word entries): the whole word goes to $0000 (low byte = animation index used by StagePlayerSprFromDP); its high byte indexes movement_delta_table, and that pointer (head of a delta-node velocity list) is stored in $2E. ReadDirSprite_XVelocity is identical but stores it in $2C.

ReadDirSprite_YVelocity {
    LDY $warpFacing       ; Y = walk-step stream pointer (warpFacing)
    INC $warpFacing       ; Advance data stream pointer to next walk-step entry
    LDA $0000, Y          ; Read direction byte from current walk data position
    AND #$00FF            ; Mask to 8-bit direction index
    ASL 
    TAY 
    LDA $&direction_velocity_table, Y ; Entry = (animation index, movement_delta_table index)
    STA $0000             ; $0000 = entry word; low byte = animation index for StagePlayerSprFromDP
    XBA                   ; XBA: swap to high byte = movement delta index
    AND #$00FF
    ASL 
    TAY 
    LDA $&movement_delta_table, Y ; Velocity-curve pointer from movement_delta_table (head of a delta-node list)
    STA $2E               ; $2E = Y velocity curve pointer (not a duration)
    RTS 
}

---------------------------------------------
; Same as ReadDirSprite_YVelocity, but the velocity-curve pointer goes to $2C (X axis) instead of $2E.

ReadDirSprite_XVelocity {
    LDY $warpFacing
    INC $warpFacing
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
    STA $2C               ; $2C = X velocity curve pointer
    RTS 
}

---------------------------------------------
; Add the next stream record, an X word and a Y word, to this actor's position ($14/$16); the stream pointer ($0650) advances by 4.

ApplyScrollOffset {
    LDA $warpFacing       ; Load current data stream position
    TAY 
    CLC 
    ADC #$0004            ; Advance past 4-byte (X word + Y word) scroll offset record
    STA $warpFacing
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

---------------------------------------------
; Copy this actor's final state to the player actor: position ($14/$16), animation index ($28), $10 with $0008 set and $0200 cleared (OQ-60), and zero the player's $08.

SyncPlayerToCamera {
    LDY $playerActor      ; SyncPlayerToCamera: copy position and state to the player actor
    LDA $14               ; Copy local X to player actor X position
    STA $0014, Y
    LDA $16               ; Copy local Y to player actor Y position
    STA $0016, Y
    LDA $10
    ORA #$0008            ; Set $0008 in the player's $10 (bit meaning: OQ-60)
    AND #$FDFF            ; Clear $0200 flag on player
    STA $0010, Y
    LDA $28               ; Sync animation index to player actor
    STA $0028, Y
    LDA #$0000            ; Zero player frame counter
    STA $0008, Y
    RTS 
}