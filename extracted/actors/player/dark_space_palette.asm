; Shadow's Dark Space palette cycling actor (176654–176798).
; 
; Runs as a companion actor for Shadow (characterForm == 2 only). Manages two alternating palette animation loops that give Shadow's sprite a shimmering visual effect — one palette for standing idle, another for moving.
; 
; Architecture: DarkSpacePaletteInit spawns a child palette actor via SpawnMarkedAfter. The parent actor (this code) switches the child between two palette cycling routines by overwriting the child's function pointer ($0000,Y) and resetting its frame counter ($0008,Y):
;   - DarkSpacePaletteCycleA: infinite loop on palette #23 (idle shimmer)
;   - DarkSpacePaletteCycleB: infinite loop on palette #24 (movement shimmer)
; 
; State machine:
;   DarkSpacePaletteIdle ←→ DarkSpacePaletteActive
; 
; Idle→Active transitions when playerSpeedEw | playerSpeedNs is nonzero (player started moving) or when flag byte #00 equals $01 (secondary movement trigger).
; 
; Active→Idle transitions when both speed axes are zero (player stopped) and flag byte #00 equals $00.
; 
; DarkSpaceCheckValidity runs every frame as a guard subroutine:
;   - If characterForm != 2 (no longer Shadow, e.g. transformed back): pop return address and COP [Die] — kills the palette actor entirely.
;   - If player actor flag bit 6 ($0040) is set (e.g. Dark Space menu active, cutscene lock): pop return address, switch child to DarkSpacePaletteNop (idle no-op), and yield — palette cycling pauses without dying.
;   - Otherwise returns normally and the caller continues its idle/active logic.
; 
; DarkSpacePaletteNop is a minimal COP [SetEntryContinue] + RTL loop — the child actor stays alive but produces no visual effect until the parent overwrites its function pointer again.
---------------------------------------------

!playerActor                    09AA
!playerSpeedEw                  09B2
!playerSpeedNs                  09B4
!characterForm                  0AD4

---------------------------------------------

; Shadow's palette cycling companion actor — initialization.
; 
; SpawnLastRel companion spawned by PlayerCharacterDef. First checks characterForm — if not 2 (Shadow), immediately dies. Otherwise initializes the palette cycling system and enters the Idle state.
; 
; Active only when the player is Shadow form, providing the distinctive palette cycling visual effect.

DarkSpacePaletteInit {
    LDA $characterForm    ; Check character form — this palette actor is Shadow-only (form 2)
    CMP #$0002            ; Form 2 = Shadow → continue initialization
    BEQ loc_02B218
    COP [Die]             ; Not Shadow → self-destruct immediately (no palette cycling for Will/Freedan)

  loc_02B218:
    COP [SpawnMarkedAfter] ( @DarkSpacePaletteCycleA, #$2800 ) ; Spawn DarkSpacePaletteCycleA as child palette actor with priority flags $2800

; Palette cycling idle state — waiting for player movement.
; 
; Monitors player position for changes. When movement is detected, transitions to the Active state. When stationary, holds the current palette frame.

  DarkSpacePaletteIdle:
    LDY $06               ; Idle state: load child actor slot from $06 (linked spawned actor)
    LDA #$&DarkSpacePaletteCycleA ; Set child's function pointer to DarkSpacePaletteCycleA (idle palette #23)
    STA $0000, Y
    LDA #$0000            ; Zero child's frame counter — restart palette cycle from beginning
    STA $0008, Y
    COP [SetEntryContinue] ; COP re-entry — idle state polls every frame
    JSR $&DarkSpaceCheckValidity ; Guard check: verify still Shadow and not in cutscene/menu lock
    LDA $playerSpeedEw    ; Check if player is moving: OR both speed axes
    ORA $playerSpeedNs
    BNE DarkSpacePaletteActive ; Nonzero speed → transition to DarkSpacePaletteActive (movement palette)
    COP [BranchIfFlagByte] ( #00, #01, &DarkSpacePaletteActive ) ; Speed is zero but flag byte #00 == $01 → also transition to Active (secondary trigger)
    RTL 
}

---------------------------------------------
; Palette cycling active state — animating palette transitions.
; 
; Runs the palette cycling animation while the player is moving. Calls the A/B palette cycling sub-routines on alternating frames. Returns to Idle when movement stops.

DarkSpacePaletteActive {
    LDY $06               ; Active state: load child actor slot from $06
    LDA #$&DarkSpacePaletteCycleB ; Set child's function pointer to DarkSpacePaletteCycleB (movement palette #24)
    STA $0000, Y
    LDA #$0000            ; Zero child's frame counter — restart palette cycle
    STA $0008, Y
    COP [SetEntryContinue] ; COP re-entry — active state polls every frame
    JSR $&DarkSpaceCheckValidity ; Guard check: verify still Shadow and not locked
    LDA $playerSpeedEw    ; Check if player has stopped: OR both speed axes
    ORA $playerSpeedNs
    BEQ loc_02B25D        ; Still moving → stay in Active state
    RTL 

  loc_02B25D:
    COP [BranchIfFlagByte] ( #00, #00, &DarkSpacePaletteIdle ) ; Speed is zero and flag byte #00 == $00 → transition back to Idle
    RTL 
}

DarkSpaceCheckValidity {
    LDA $characterForm    ; Validate character form is still Shadow (form 2)
    CMP #$0002
    BNE loc_02B28A        ; Not Shadow → branch to death cleanup (form changed during play)
    LDY $playerActor      ; Load player actor slot for flag inspection
    LDA $0010, Y          ; Read actor flags from player slot offset $10
    BIT #$0040            ; Bit 6 ($0040) = palette lock flag (Dark Space menu, cutscene, etc.)
    BNE loc_02B278        ; Flag set → branch to NOP transition (pause palette cycling)
    RTS 

  loc_02B278:
    PLA                   ; Pop caller's return address — abort caller's idle/active logic
    LDY $06
    LDA #$&DarkSpacePaletteNop ; Set child's function pointer to DarkSpacePaletteNop (no-op loop)
    STA $0000, Y
    LDA #$0000            ; Zero child's frame counter
    STA $0008, Y
    COP [SetEntryContinue] ; Yield — palette cycling paused until parent resumes control
    RTL 

  loc_02B28A:
    PLA                   ; Pop caller's return address — abort caller's logic before dying
    COP [Die]             ; Kill this palette actor — Shadow form is no longer active
}

DarkSpacePaletteCycleA {
    COP [PaletteStart] ( #23 ) ; Idle shimmer: infinite loop cycling palette bundle #23
    COP [PaletteStep]
    BRA DarkSpacePaletteCycleA

  DarkSpacePaletteCycleB:
    COP [PaletteStart] ( #24 ) ; Movement shimmer: infinite loop cycling palette bundle #24
    COP [PaletteStep]
    BRA DarkSpacePaletteCycleB

  DarkSpacePaletteNop:
    COP [SetEntryContinue] ; No-op loop: yield each frame with no palette effect — paused state
    RTL 
}