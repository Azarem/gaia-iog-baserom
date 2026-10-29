; Player-actor transition scripts plus one impact effect (Bank 00, 50200-50671). Most routines are not run by an actor of their own: a caller (scene script, item code, warp code) writes a routine's address into the player actor's entry pointer ($0000,Y low word and $0002,Y bank byte), clears the player's wait counter ($0008,Y), and the player actor runs the routine on its next turn (X = D = the player slot, so every COP inside acts on the player). The routines hold a pose, play a short sequence or give control back; most finish with JML player_character.PlayerIdleEntry, which also clears playerFlags $2800, so the $0800 script lock set by the caller or the routine is released there.
; 
; === ENTRY POINTS AND CALLERS (from the pointer writes) ===
; 
; - SpawnImpactSparkAndDie (50200, the first entry of this file): SpawnListAppend ImpactSparkEffect, then Die. It is the default script written into an actor hit by the player's interaction / push strike (combat_collision.ApplyHitDamageToVictim path 1, together with $10 |= $0040) and is reached by JumpFar from gw8A_sand_fanger (756178).
; - ImpactSparkEffect (50211): effect actor: SFX $09, frame $2A of spriteset_pickups_effects, then Die. Spawned by SpawnImpactSparkAndDie and by gw82_archer (SpawnListAppend at X +- 14, Y - 14, flags $0302), so it is an impact spark; it reveals no item.
; - PlayerIdleAnimLoop (50226): idle animation loop. Callers: warps_interaction (while the music upload finishes) and ir29_castoth func_0AA37B.
; - PlayerStaticBodyPose / PlayerWalkingIdlePose (50246 / 50261): the flute playback in item_use_system holds body 4 frame $1F, then restores control.
; - RestorePlayerControlDirect (50266): JML PlayerIdleEntry. Callers: warps_interaction and ir29_castoth func_0AA391.
; - PlayerPoseHold / PlayerPoseHoldExit (50270 / 50285): hold body 4 frame $20 (every frame / once, then PlayerIdleEntry). Idle: gs2D_lily, gs2E_sleep, dc2F_adrift, dc31_rescuer. Exit: dc31_kara. The callers do not identify the character as Freedan, so the pose names are neutral.
; - PlayerIdleEntryJump (50281): a bare JML PlayerIdleEntry; no reference found.
; - PlayerFallFromHeight (50297): awBD_fall_trigger. PlayerSkyGardenJumpLanding (50385): sg4D_jump_handler. PlayerAuraTransformEntry (50519): item_use_system.UseItem_Aura (Shadow only, standing still).
; 
; === FLAG BITS USED ===
; 
; Player actor flags $10: $0008 = normal collision-aware movement (cleared while a script moves the player, set again at the end), $0200 = scripted motion marker (the Psycho Slider and the lunge set it too), $2000 = SortActorsByDepth skips the actor and PlayerIdleEntry yields without acting (meaning not traced), $0040 = death flag. playerFlags $0800 = script / ability lock. layerPriorityFlag ($06EE) bit $0200 = camera frozen. joypadMaskStd |= $CFFC hides every button except Select / Start.
---------------------------------------------

?INCLUDE 'player_character'
?INCLUDE 'spriteset_pickups_effects'

!joypadMaskStd                  065A
!layerPriorityFlag              06EE
!playerFlags                    09AE

---------------------------------------------

; Default victim script and spark spawner: spawn ImpactSparkEffect at this actor (offsets 0, 0, flags $0302) and Die. See the block note for how an actor ends up here.

SpawnImpactSparkAndDie {
    COP [SpawnListAppend] ( @ImpactSparkEffect, #00, #00, #$0302 ) ; Spawn the impact spark at this actor (offsets 0, 0, flags $0302)
    COP [Die]
}

---------------------------------------------
; Impact spark actor: SFX $09 on channel 2, frame $2A of spriteset_pickups_effects, AnimOnce, Die. The code after the Die belongs to the same block but is only entered through the entry pointer written into the player actor.

ImpactSparkEffect {
    COP [PlaySoundCh2] ( #09 ) ; SFX $09 on channel 2
    COP [SetMetasprite] ( @spriteset_pickups_effects )
    COP [StageSpriteFrame] ( #2A ) ; Frame $2A of spriteset_pickups_effects, one-shot
    COP [AnimOnce]
    COP [Die]

; Entered as the player's script. When per-scene flag #00 is set it stages anim $11 (PlayerIdleUseShadowSprite), otherwise anim $01, then loops AnimOnce until the caller redirects the player. What flag #00 means is not traced.

  PlayerIdleAnimLoop:
    COP [BranchOnFlagByte] ( #00, #01, &PlayerIdleUseShadowSprite ) ; Per-scene flag #00 set: anim $11, otherwise anim $01
    COP [StagePlayerSprite] ( #01 )
    BRA PlayerIdleAnimContinue
}

---------------------------------------------
; Per-scene flag #00 set: stage anim $11 instead of $01.

PlayerIdleUseShadowSprite {
    COP [StagePlayerSprite] ( #11 )

; Loop: SetEntryHere, AnimOnce, repeat. Each pass saves the loop as the re-entry point and plays the animation once.

  PlayerIdleAnimContinue:
    COP [SetEntryHere]
    COP [AnimOnce]
    BRA PlayerIdleAnimContinue

; Flute pose: $10 |= $0200, body table index 4 (SetPlayerSpriteDirect), then frame $1F is staged again on every pass. item_use_system writes this as the player's script while the melody plays.

  PlayerStaticBodyPose:
    LDA #$0200
    TSB $10               ; $10 bit $0200: scripted-motion marker (cleared again by PlayerWalkingIdlePose)
    COP [SetPlayerSpriteDirect] ( #04 ) ; Body table index 4 (the Psycho Slider uses it too)

; Stage frame $1F and play it once, forever.

  PlayerStaticBodyAnimLoop:
    COP [StageSpriteFrame] ( #1F ) ; Pose frame $1F, staged again on every pass
    COP [AnimOnce]
    BRA PlayerStaticBodyAnimLoop

; End of the flute: clear $10 bit $0200 and fall into RestorePlayerControlDirect.

  PlayerWalkingIdlePose:
    LDA #$0200
    TRB $10               ; Clear $10 bit $0200

; Give control back: JML PlayerIdleEntry.

  RestorePlayerControlDirect:
    JML $@player_character.PlayerIdleEntry
}

---------------------------------------------
; Hold pose: body table index 4, then every frame stage frame $20 and play it once (SetEntryHere + RTL). The callers place the player first (gs2E_sleep also moves it up 8 px).

PlayerPoseHold {
    COP [SetPlayerSpriteDirect] ( #04 ) ; Body table index 4 (see PlayerStaticBodyPose)
    COP [SetEntryHere]    ; Re-entry point: the lines below run every frame
    COP [StageSpriteFrame] ( #20 ) ; Pose frame $20
    COP [AnimOnce]
    RTL 
}

---------------------------------------------
; Unreferenced trampoline: JML PlayerIdleEntry.

PlayerIdleEntryJump {
    JML $@player_character.PlayerIdleEntry
}

---------------------------------------------
; Leave the held pose: body 4 frame $20 once, then PlayerIdleEntry.

PlayerPoseHoldExit {
    COP [SetPlayerSpriteDirect] ( #04 )
    COP [StageSpriteFrame] ( #20 )
    COP [AnimOnce]
    JML $@player_character.PlayerIdleEntry
}

---------------------------------------------
; Fall into the scene (awBD_fall_trigger): hide the buttons, lock the player, leave collision-aware movement, freeze the camera; 4 ticks (WaitByte #03) out of the depth sort, Y -= 128, then 8 passes of fall anim $19 with Y chain 7 (+4 px per frame), landing SFX $2C and frame $1C. Then restore $10 / camera / buttons and return to PlayerIdleEntry (which clears the $0800 lock). Whether the fall ends exactly on the original Y is not checked.

PlayerFallFromHeight {
    LDA #$CFFC            ; Mask $CFFC in joypadMaskStd: every button except Select / Start is hidden
    TSB $joypadMaskStd
    LDA #$0800
    TSB $playerFlags      ; playerFlags $0800: script / ability lock (released by PlayerIdleEntry)
    LDA #$0008
    TRB $10               ; Leave collision-aware movement ($10 bit $0008) for the scripted fall
    LDA #$2200
    TSB $10               ; $10 |= $2200: $2000 (skipped by SortActorsByDepth) and $0200 (scripted motion)
    LDA #$0200
    TSB $layerPriorityFlag ; Freeze the camera (layerPriorityFlag bit $0200)
    COP [WaitByte] ( #03 ) ; WaitByte #03 = 4 ticks out of the depth sort
    COP [NudgePosition] ( #00, #80 ) ; Y -= 128 (signed $80): start the fall 128 px higher
    LDA #$2000
    TRB $10               ; Clear $2000: the player is drawn again
    COP [LoopStart] ( #08 )
    COP [StagePlayerMoveY] ( #19, #07 ) ; Fall: anim $19 with Y chain 7 (+4 px per frame), 8 passes
    COP [AnimOnce]
    COP [LoopEnd]
    COP [PlaySoundCh2] ( #2C ) ; Landing SFX $2C
    COP [StagePlayerMoveY] ( #1C, #00 ) ; Landing frame: anim $1C, chain 0 = no movement
    COP [AnimOnce]
    LDA #$0008
    TSB $10               ; Restore $10 bit $0008 (collision-aware movement)
    LDA #$0200
    TRB $10               ; Clear $10 bit $0200
    LDA #$0200
    TRB $layerPriorityFlag ; Unfreeze the camera
    LDA #$CFFC
    TRB $joypadMaskStd    ; Unmask the buttons
    STZ $08               ; No pending wait
    JML $@player_character.PlayerIdleEntry ; Control returns; PlayerIdleEntry clears playerFlags $2800
}

---------------------------------------------
; Jump sequence of sg4D_jump_handler (the caller sets playerFlags $0800): leave collision-aware movement, $10 |= $2200, Y -= 64, freeze the camera, 4 ticks (WaitByte #03), Y += 64, show the player, flip the sprite vertically, Y -= 32 and rise with decelerating Y chains (8 x4 passes, 4 x2, 2 x2); flip back, Y += 32, descend (chains 1, 3), landing SFX $2C and frame $1F; restore $10 and the camera and return to PlayerIdleEntry. The buttons are not masked or unmasked here.

PlayerSkyGardenJumpLanding {
    LDA #$0008
    TRB $10               ; Leave collision-aware movement
    LDA #$2200
    TSB $10               ; $10 |= $2200: not depth-sorted, scripted motion
    COP [NudgePosition] ( #00, #C0 ) ; Y -= 64 (signed $C0)
    COP [SetEntryHereAndYield] ; Yield; the next frame continues here
    LDA #$0200
    TSB $layerPriorityFlag ; Freeze the camera
    COP [WaitByte] ( #03 ) ; WaitByte #03 = 4 ticks
    COP [NudgePosition] ( #00, #40 ) ; Y += 64: back to the original row
    LDA #$2000
    TRB $10               ; Clear $2000: the player is drawn again
    COP [ToggleVMirror]   ; Flip the sprite vertically
    COP [NudgePosition] ( #00, #E0 ) ; Y -= 32 (signed $E0)
    COP [StagePlayerMoveY] ( #1A, #08 ) ; Rise, decelerating: chain 8 (-4 px per frame) for 4 passes, chain 4 (-2) for 2, chain 2 (-1) for 2
    COP [AnimOnce]
    COP [LoopStart] ( #03 )
    COP [StagePlayerMoveY] ( #1B, #08 )
    COP [AnimOnce]
    COP [LoopEnd]
    COP [StagePlayerMoveY] ( #1B, #04 )
    COP [AnimOnce]
    COP [StagePlayerMoveY] ( #1B, #04 )
    COP [AnimOnce]
    COP [StagePlayerMoveY] ( #1B, #02 )
    COP [AnimOnce]
    COP [StagePlayerMoveY] ( #1B, #02 )
    COP [AnimOnce]
    COP [ToggleVMirror]   ; Flip back
    COP [NudgePosition] ( #00, #20 ) ; Y += 32
    COP [StagePlayerSprite] ( #1E )
    COP [AnimOnce]
    COP [StagePlayerMoveY] ( #1E, #01 ) ; Descent: chain 1 (+1 px per frame), then chain 3 (+2)
    COP [AnimOnce]
    COP [StagePlayerMoveY] ( #1E, #03 )
    COP [AnimOnce]
    COP [PlaySoundCh2] ( #2C ) ; Landing SFX $2C
    COP [StagePlayerSprite] ( #1F )
    COP [AnimOnce]
    LDA #$0008
    TSB $10               ; Restore $10 bit $0008 (collision-aware movement)
    LDA #$0200
    TRB $10
    LDA #$0200
    TRB $layerPriorityFlag ; Unfreeze the camera
    STZ $08
    JML $@player_character.PlayerIdleEntry ; Control returns; PlayerIdleEntry clears playerFlags $2800
}

---------------------------------------------
; Aura (item_use_system.UseItem_Aura, Shadow standing still): lock the player, leave collision-aware movement, $10 |= $0200, body table index 8, frame 0; save X / Y in $24 / $26, align Y to a 16 px row, then search for floor (PlayerAuraAlignToSolidSouth). The terrain type $04 test below decides between the sink and an abort.

PlayerAuraTransformEntry {
    LDA #$0800            ; Aura: lock the player (playerFlags $0800, released by PlayerIdleEntry)
    TSB $playerFlags
    LDA #$0008
    TRB $10
    LDA #$0200
    TSB $10
    COP [SetPlayerSpriteDirect] ( #08 ) ; Body table index 8
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    LDA $14
    STA $24               ; Save the start X / Y in $24 / $26
    LDA $16
    STA $26
    LDA $16
    AND #$FFF0
    STA $16               ; Y aligned down to a 16 px row

; Scan down one 16 px row at a time until BranchIfSolidHere reports a blocked tile; the whole scan runs inside one frame.

  PlayerAuraAlignToSolidSouth:
    COP [BranchIfSolidHere] ( &PlayerAuraBlockedBySolid ) ; Blocked tile: PlayerAuraBlockedBySolid; free tile: step one row down and probe again (no yield)
    LDA $16
    CLC 
    ADC #$0010
    STA $16
    BRA PlayerAuraAlignToSolidSouth
}

---------------------------------------------
; Blocked tile found: when the tile below (Y + 16) has terrain type $04 go to PlayerAuraDescendToFloor; otherwise restore the saved position, show frame 1 once and leave through PlayerAuraTransformExit.

PlayerAuraBlockedBySolid {
    COP [BranchIfSolidTypeSouth] ( #04, &PlayerAuraDescendToFloor ) ; Tile below (Y + 16) has terrain type $04: sink; otherwise abort
    LDA $24
    STA $14
    LDA $26
    STA $16
    COP [StageSpriteFrame] ( #01 ) ; Abort: frame 1 at the original spot, then exit
    COP [AnimOnce]
    JMP $&PlayerAuraTransformExit
}

---------------------------------------------
; Restore the saved X / Y, set $10 bit $2000 and sink: PlayerAuraScanSolidRow.

PlayerAuraDescendToFloor {
    LDA $24
    STA $14
    LDA $26
    STA $16
    LDA #$2000
    TSB $10               ; $10 |= $2000 while sinking

; Every 16th pixel row test for terrain type $04 at the actor position; on a match land.

  PlayerAuraScanSolidRow:
    LDA $16               ; Per-row solid scan: BranchIfSolidType $04 only when Y mod 16 equals zero
    AND #$000F
    BNE PlayerAuraScanSolidNext
    COP [BranchIfSolidType] ( #04, &PlayerAuraLandOnSolid )

; Sink 1 px and continue next frame (JumpNextFrame).

  PlayerAuraScanSolidNext:
    INC $16               ; Sink 1 px per frame
    COP [JumpNextFrame] ( @PlayerAuraScanSolidRow ) ; Next frame: continue the scan (JumpNextFrame yields)
}

---------------------------------------------
; Type $04 reached: clear $2000, set $10 bit $0002 (meaning not traced) and slide down with sprite anim 2 / Y chain 1 (+1 px per frame) until the tile type at the actor is 0.

PlayerAuraLandOnSolid {
    LDA #$2000
    TRB $10               ; Clear $2000
    LDA #$0002
    TSB $10               ; $10 |= $0002 for the landing slide (meaning not traced)

; One pass of the landing slide: anim 2, +1 px per frame, then test the tile type.

  PlayerAuraLandAnimLoop:
    COP [StageSpriteMoveY] ( #02, #01 ) ; Sprite anim 2 with Y chain 1 (+1 px per frame)
    COP [AnimOnce]
    COP [BranchIfSolidType] ( #00, &PlayerAuraLandComplete ) ; Stop when the tile type at the actor is 0 (open)
    BRA PlayerAuraLandAnimLoop
}

---------------------------------------------
; Open tile reached: clear $10 bit $0002, show frame $1C (anim $1C, no movement) and fall into PlayerAuraTransformExit.

PlayerAuraLandComplete {
    LDA #$0002
    TRB $10               ; Clear $10 bit $0002
    COP [StagePlayerMoveY] ( #1C, #00 ) ; Landing pose: anim $1C, no movement
    COP [AnimOnce]
}

---------------------------------------------
; End: normal movement again ($10 |= $0008, clear $0200), no pending wait, PlayerIdleEntry (clears the $0800 lock).

PlayerAuraTransformExit {
    LDA #$0008
    TSB $10               ; Normal movement again ($10 bit $0008)
    LDA #$0200
    TRB $10
    STZ $08
    JML $@player_character.PlayerIdleEntry
}