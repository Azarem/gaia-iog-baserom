; Shadow's palette shimmer (Bank 02, 176654-176798): a hidden companion that animates the player's OBJ palette 0 (colours $81-$8F) while the player is Shadow (characterForm 2).
; 
; SPAWN: PlayerCharacterDef (SpawnListAppend, so it is appended at the end of the actor list) and the two Dark Space transformations in sE6_gaia (Transform_WillToShadow, Transform_FreedanToShadow), which spawn it just before they set characterForm = 2; the new actor runs later in the same tick, after the form is set. All three use flags $2800: hidden ($2000) plus $0800, so it also runs in the cutscene-only passes. Init dies at once when characterForm is not 2.
; 
; STRUCTURE: Init spawns ShadowShimmerSlowStrips with SpawnAfterMarked (a marked child dies with its parent). This actor never touches the palette: it only points the child at one of three routines by writing the child's entry word ($0000,Y) and clearing its waitCounter ($0008,Y). The child is found through $06 (the actor-list successor), which is the child because SpawnAfter inserts it directly behind its spawner.
;   - ShadowShimmerSlowStrips: bundle #23 in a loop (eight strips, wait 2 each)
;   - ShadowShimmerFastStrips: bundle #24 in a loop (eight strips, waits 0 and 1 alternating: a faster cycle)
;   - ShadowShimmerNop: yields every frame, no palette change
; Both bundles write colours $81-$8F (15 colours, size byte $1D); bundle #23 is also the Shadow palette that global_ambient_dispatcher loads at spawn.
; 
; STATES: Idle (the slow strips, ShadowShimmerSlowStrips) and Active (the fast strips, ShadowShimmerFastStrips). Idle -> Active when playerSpeedEw or playerSpeedNs is nonzero, or when flag byte #00 is set. Active -> Idle when both speeds are zero and flag #00 is clear. The speed words are not set by ordinary walking (walking uses the joypad velocity of player_move_controller); they are nonzero during slope and ramp slides and in run / slide moves, so the fast strips play then. Flag #00 is a general per-scene flag (scene_lifecycle clears it at scene setup; scene_flag_init sets it in 26 scene lists; some scripts set and clear it) that player_character also reads to pick Shadow's idle, ladder and shimmy-detach sprites; where it is set, this actor stays in Active. What the flag means is open (OQ-I030-1; here OQ-I048-1).
; 
; GUARD (ShadowShimmerGuard, called every frame from both states): characterForm no longer 2 -> pop the return address and Die (the marked child dies too). Player Flags10 bit $0040 (dead: set when HP reaches 0 by combat_collision and by GameOverSequence; combat_collision also calls it the orb state) -> point the child at ShadowShimmerNop and run SetEntryHere + RTL. The saved entry is that RTL, so the states are never run again for the rest of the scene visit and the palette stays on whatever strip was showing.
---------------------------------------------

!playerActor                    09AA
!playerSpeedEw                  09B2
!playerSpeedNs                  09B4
!characterForm                  0AD4

---------------------------------------------

; Spawned by PlayerCharacterDef and by the two Dark Space transformations to Shadow. Dies at once unless characterForm is 2, otherwise spawns the palette child (slow strips) and falls into ShadowShimmerIdle.

ShadowShimmerInit {
    LDA $characterForm    ; characterForm: 0 Will, 1 Freedan, 2 Shadow
    CMP #$0002
    BEQ loc_02B218
    COP [Die]             ; Any other form: the shimmer is not needed, remove the actor

  loc_02B218:
    COP [SpawnAfterMarked] ( @ShadowShimmerSlowStrips, #$2800 ) ; Spawn the palette child (slow strips, flags $2800); marked, so it dies with this actor

; Idle state: point the child at the slow strips (ShadowShimmerSlowStrips) and restart it, then each frame: guard, then switch to Active when a speed word is nonzero or flag byte #00 is set. Plain walking leaves both speed words at zero.

  ShadowShimmerIdle:
    LDY $06               ; Y = $06 = actor-list successor = the child just spawned behind this actor
    LDA #$&ShadowShimmerSlowStrips ; Idle: point the child at ShadowShimmerSlowStrips by overwriting its entry word, and clear its waitCounter ($08) so it starts at once
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    COP [SetEntryHere]
    JSR $&ShadowShimmerGuard ; Guard: Shadow form and not dead (does not return when it ends the actor)
    LDA $playerSpeedEw    ; Speed words are nonzero only for slope / ramp slides and run / slide moves, not for plain walking
    ORA $playerSpeedNs
    BNE ShadowShimmerActive
    COP [BranchOnFlagByte] ( #00, #01, &ShadowShimmerActive ) ; Flag byte #00 == 1: Active state as well
    RTL 
}

---------------------------------------------
; Active state: point the child at the fast strips (ShadowShimmerFastStrips) and restart it, then each frame: guard, stay while a speed word is nonzero, go back to Idle when both are zero and flag byte #00 is clear.

ShadowShimmerActive {
    LDY $06
    LDA #$&ShadowShimmerFastStrips ; Active: the same with ShadowShimmerFastStrips (entry word overwritten, waitCounter cleared)
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    COP [SetEntryHere]
    JSR $&ShadowShimmerGuard
    LDA $playerSpeedEw
    ORA $playerSpeedNs
    BEQ loc_02B25D
    RTL 

  loc_02B25D:
    COP [BranchOnFlagByte] ( #00, #00, &ShadowShimmerIdle ) ; Flag byte #00 == 0: back to Idle
    RTL                   ; Flag set: stay Active
}

---------------------------------------------
; Called with JSR from both states every frame. Form no longer Shadow: pop the return address and Die. Player Flags10 bit $0040 (dead) set: pop the return address, point the child at ShadowShimmerNop and execute SetEntryHere + RTL (the saved entry is the RTL, so this actor never runs its states again). Otherwise RTS.

ShadowShimmerGuard {
    LDA $characterForm
    CMP #$0002
    BNE loc_02B28A        ; No longer Shadow: end the actor
    LDY $playerActor
    LDA $0010, Y
    BIT #$0040            ; Bit $0040 = dead (set when HP reaches 0 and by GameOverSequence)
    BNE loc_02B278
    RTS 

  loc_02B278:
    PLA                   ; Drop the JSR return address: the caller's state code is skipped
    LDY $06
    LDA #$&ShadowShimmerNop ; Point the child at ShadowShimmerNop (entry word, no palette change) and clear its waitCounter
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    COP [SetEntryHere]    ; Saves the entry as the RTL below, so this actor never runs its states again
    RTL 

  loc_02B28A:
    PLA 
    COP [Die]             ; Remove this actor; the marked child dies with it
}

---------------------------------------------
; Child routine: play palette bundle #23 (eight strips on colours $81-$8F, wait 2 each) in an endless loop.

ShadowShimmerSlowStrips {
    COP [PaletteStart] ( #23 )
    COP [PaletteStep]
    BRA ShadowShimmerSlowStrips

; Child routine: play palette bundle #24 (eight strips on colours $81-$8F, waits 0 and 1 alternating) in an endless loop.

  ShadowShimmerFastStrips:
    COP [PaletteStart] ( #24 )
    COP [PaletteStep]
    BRA ShadowShimmerFastStrips

; Child routine: yield every frame, no palette change. The colours stay as the last strip left them.

  ShadowShimmerNop:
    COP [SetEntryHere]
    RTL 
}