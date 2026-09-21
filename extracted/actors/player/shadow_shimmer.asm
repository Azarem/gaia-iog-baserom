; Shadow's palette shimmer companion actor (176654–176798).
; 
; Runs as a companion actor for Shadow (characterForm == 2 only). Manages two alternating palette animation loops that give Shadow's sprite a shimmering visual effect — one palette for standing idle, another for moving.
; 
; Architecture: ShadowShimmerInit spawns a child palette actor via SpawnMarkedAfter. The parent actor (this code) switches the child between two palette cycling routines by overwriting the child's function pointer ($0000,Y) and resetting its frame counter ($0008,Y):
;   - ShadowShimmerCycleA: infinite loop on palette #23 (idle shimmer)
;   - ShadowShimmerCycleB: infinite loop on palette #24 (movement shimmer)
; 
; State machine:
;   ShadowShimmerIdle ←→ ShadowShimmerActive
; 
; Idle→Active transitions when playerSpeedEw | playerSpeedNs is nonzero (player started moving) or when flag byte #00 equals $01 (secondary movement trigger).
; 
; Active→Idle transitions when both speed axes are zero (player stopped) and flag byte #00 equals $00.
; 
; ShadowShimmerGuard runs every frame as a guard subroutine:
;   - If characterForm != 2 (no longer Shadow, e.g. transformed back): pop return address and COP [Die] — kills the shimmer actor entirely.
;   - If player actor flag bit 6 ($0040) is set (e.g. cutscene lock, menu active): pop return address, switch child to ShadowShimmerNop (idle no-op), and yield — palette cycling pauses without dying.
;   - Otherwise returns normally and the caller continues its idle/active logic.
; 
; ShadowShimmerNop is a minimal COP [SetEntryHere] + RTL loop — the child actor stays alive but produces no visual effect until the parent overwrites its function pointer again.
---------------------------------------------

!playerActor                    09AA
!playerSpeedEw                  09B2
!playerSpeedNs                  09B4
!characterForm                  0AD4

---------------------------------------------

; Shadow's palette shimmer companion actor — initialization.
; 
; SpawnLastRel companion spawned by PlayerCharacterDef. First checks characterForm — if not 2 (Shadow), immediately dies. Otherwise initializes the palette shimmer system and enters the Idle state.
; 
; Active only when the player is Shadow form, providing the distinctive shimmering palette visual effect.

ShadowShimmerInit {
    LDA $characterForm
    CMP #$0002
    BEQ loc_02B218
    COP [Die]             ; Not Shadow → self-destruct immediately (no shimmer for Will/Freedan)

  loc_02B218:
    COP [SpawnAfterMarked] ( @ShadowShimmerCycleA, #$2800 ) ; Spawn ShadowShimmerCycleA as child palette actor with priority flags $2800

; Palette shimmer idle state — waiting for player movement.
; 
; Monitors player speed for changes. When movement is detected, transitions to the Active state. When stationary, holds the current palette frame.

  ShadowShimmerIdle:
    LDY $06               ; Idle state: load child actor slot from $06 (linked spawned actor)
    LDA #$&ShadowShimmerCycleA ; Set child's function pointer to ShadowShimmerCycleA (idle palette #23)
    STA $0000, Y
    LDA #$0000            ; Zero child's frame counter — restart palette cycle from beginning
    STA $0008, Y
    COP [SetEntryHere]    ; COP re-entry — idle state polls every frame
    JSR $&ShadowShimmerGuard ; Guard check: verify still Shadow and not in cutscene/menu lock
    LDA $playerSpeedEw    ; Check if player is moving: OR both speed axes
    ORA $playerSpeedNs
    BNE ShadowShimmerActive ; Nonzero speed → transition to ShadowShimmerActive (movement palette)
    COP [BranchOnFlagByte] ( #00, #01, &ShadowShimmerActive ) ; Speed is zero but flag byte #00 == $01 → also transition to Active (secondary trigger)
    RTL 
}

---------------------------------------------
; Palette shimmer active state — animating palette transitions.
; 
; Runs the movement palette cycling animation while the player is moving. Returns to Idle when movement stops.

ShadowShimmerActive {
    LDY $06               ; Active state: load child actor slot from $06
    LDA #$&ShadowShimmerCycleB ; Set child's function pointer to ShadowShimmerCycleB (movement palette #24)
    STA $0000, Y
    LDA #$0000            ; Zero child's frame counter — restart palette cycle
    STA $0008, Y
    COP [SetEntryHere]    ; COP re-entry — active state polls every frame
    JSR $&ShadowShimmerGuard ; Guard check: verify still Shadow and not locked
    LDA $playerSpeedEw    ; Check if player has stopped: OR both speed axes
    ORA $playerSpeedNs
    BEQ loc_02B25D        ; Still moving → stay in Active state
    RTL 

  loc_02B25D:
    COP [BranchOnFlagByte] ( #00, #00, &ShadowShimmerIdle ) ; Speed is zero and flag byte #00 == $00 → transition back to Idle
    RTL 
}

ShadowShimmerGuard {
    LDA $characterForm    ; Validate character form is still Shadow (form 2)
    CMP #$0002
    BNE loc_02B28A        ; Not Shadow → branch to death cleanup (form changed during play)
    LDY $playerActor      ; Load player actor slot for flag inspection
    LDA $0010, Y          ; Read actor flags from player slot offset $10
    BIT #$0040            ; Bit 6 ($0040) = palette lock flag (cutscene, menu, etc.)
    BNE loc_02B278        ; Flag set → branch to NOP transition (pause palette cycling)
    RTS 

  loc_02B278:
    PLA                   ; Pop caller's return address — abort caller's idle/active logic
    LDY $06
    LDA #$&ShadowShimmerNop ; Set child's function pointer to ShadowShimmerNop (no-op loop)
    STA $0000, Y
    LDA #$0000            ; Zero child's frame counter
    STA $0008, Y
    COP [SetEntryHere]    ; Yield — palette cycling paused until parent resumes control
    RTL 

  loc_02B28A:
    PLA                   ; Pop caller's return address — abort caller's logic before dying
    COP [Die]             ; Kill this shimmer actor — Shadow form is no longer active
}

ShadowShimmerCycleA {
    COP [PaletteStart] ( #23 ) ; Idle shimmer: infinite loop cycling palette bundle #23
    COP [PaletteStep]
    BRA ShadowShimmerCycleA

  ShadowShimmerCycleB:
    COP [PaletteStart] ( #24 ) ; Movement shimmer: infinite loop cycling palette bundle #24
    COP [PaletteStep]
    BRA ShadowShimmerCycleB

  ShadowShimmerNop:
    COP [SetEntryHere]    ; No-op loop: yield each frame with no palette effect — paused state
    RTL 
}