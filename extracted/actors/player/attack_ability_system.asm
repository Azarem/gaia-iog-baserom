; Player attack and ability companion actor system (Bank 02).
; 
; Runs as a companion actor spawned before the movement controller via SpawnBefore. Each frame, checks player state (alive, not in hurt/knockback/dialogue) and listens for the attack button ($8001). Dispatches to character-specific attack flows based on characterForm ($0AD4): Will (form 0) uses WillAttackDispatch, Freedan (form 1) uses FreedanAttackDispatch. Forms 2+ return immediately and cannot attack through this code path.
; 
; Both characters share a 40-frame ($28 hex) initial button-hold detection period via COP LoopInit. If the player releases during this window, the attack cancels back to idle.
; 
; Will's attack system (WillAttackDispatch):
; - Extended charge timer: 120 frames ($0078)
; - Ability gate: abilityBitmask bit 2 ($0004) unlocks Psycho Slider
; - Without bit 2: release after charge → Psycho Dash
; - With bit 2: CheckAttackChargeable gates continued charge; L/R ($0030) → Psycho Slider; release → Psycho Dash
; - Psycho Dash: directional fast dash with trail afterimage actors (4 directions)
; - Psycho Slider: spawns a GuidedProjectileActor the player steers with D-pad; charge tick via L/R
; 
; Freedan's attack system (FreedanAttackDispatch):
; - Extended charge timer: 100 frames ($0064)
; - Additional cancel: Y/A/L/R ($40B0) during charge aborts (prevents accidental input)
; - Ability gate: abilityBitmask bit 5 ($0020) unlocks Aura Barrier
; - Without bit 5: release → Dark Friar
; - With bit 5: D-pad during charge → cancel (AttackChargeReturn); L/R ($0030) → Aura Barrier; release → Dark Friar
; - Dark Friar: 4-directional energy projectile with trail, wall-bounce, redirect (upgrade level 2), and fragment burst on hit
; - Aura Barrier: requires standing still; rotating orbital projectiles with VRAM DMA, custom palette, expand/shrink lifecycle
; 
; Ability bitmask ($0AA2) gates:
; - Bit 0 ($0001): Basic attack enabled (Will)
; - Bit 2 ($0004): Psycho Slider (Will extended charge)
; - Bit 4 ($0010): Dark Friar (Freedan)
; - Bit 5 ($0020): Aura Barrier (Freedan extended selection)
; - Bit 6 ($0040): Basic attack enabled (Freedan)
; 
; The system hijacks the player actor function pointer via SetPlayerActorFunc during ability execution, then restores it through AttackCleanup which kills spawned FX actors and plays form-specific palette restoration (Will=#0B, Freedan=#0C).
; 
; Helper routines: ValidateAttackReady ($3A00 flags + facing < 4), ValidateAttackContinue ($2B00 per-frame check), CheckAttackChargeable (hitstun/death/combo gate), SavePlayerPosition (snapshots for offset calculations), ComputeParentOffset/ApplyParentOffset (relative position tracking for child actors), KillSpawnedProjectile (cleanup via MarkDeath).
; 
; Palette FX: WillAttackPaletteFX (#2A→#2B loop), FreedanAttackPaletteFX (#4B→#2C loop), AuraBarrierPaletteFX (#5B infinite).
; 
; Animation tables: LoadAbilityAnimTableA (table_01D9A7, Will) and LoadAbilityAnimTableB (table_01D9BF, Freedan) provide indexed sprite/hitbox configurations stored to climbStateData ($09E0/$09E2).
; 
; === TRAIL FOLLOWERS (TrailFollowerSprA, 179702–179872) ===
; 
; Dark Friar fragment trail follower actors and position offset helpers. Provides two trail segment actor variants (TrailFollowerSprA sprite #05, TrailFollowerSprB sprite #06) that follow behind Dark Friar fragment projectiles to create a cascading afterimage effect. Both variants share the same loop logic — only their initial sprite/hitbox configuration differs.
; 
; The trail system works via a 3-stage position FIFO buffer stored in per-actor long-address scratch fields ($7F0000–$7F001A,X). Each frame, TrailPositionCascade shifts the parent actor's current position into stage 3 of the queue, while each older position advances one stage forward. The trail actor displays the position from stage 1 (the oldest buffered value), creating a 3-frame position delay. TrailPositionInit seeds all 3 stages with the current position so the trail starts co-located with its parent.
; 
; ComputeParentOffset and ApplyParentOffset are also in this part — they store/apply the XY delta between current position and a parent actor, used by Dark Friar projectile and trail actors for relative positioning.
; 
; === PART STRUCTURE ===
; 
; Part 1 (AttackSystemEntry, 178099–179702): Attack dispatch, both character dispatch paths, all Freedan abilities (Dark Friar + Aura Barrier), and shared helper routines.
; Part 2 (TrailFollowerSprA, 179702–179872): Trail follower actors, position FIFO system, and parent offset helpers.
; Part 3 (PsychoDashMain, 179872–181132): All Will abilities (Psycho Dash, Psycho Slider, Guided Projectile), palette FX actors, and animation table loaders.
---------------------------------------------

?BANK 02

?INCLUDE 'ability_anim_tables'
?INCLUDE 'ApplyOrbitalOffsetFromRef'
?INCLUDE 'cop_handlers_actors'
?INCLUDE 'player_character'
?INCLUDE 'table_0EE000'
?INCLUDE 'table_178000'
?INCLUDE 'table_179000'

!sceneCurrent                   0644
!joypadCurrent                  0656
!joypadHeld                     0658
!playerXPos                     09A2
!playerYPos                     09A4
!playerActor                    09AA
!playerFlags                    09AE
!playerSpeedEw                  09B2
!playerSpeedNs                  09B4
!slopeStepCounter               09B6
!decelStepCounter               09B8
!climbStateData                 09E0
!abilityBitmask                 0AA2
!characterForm                  0AD4
!animScratch                    7F0000
!retPtr1                        7F0004
!animScratch2                   7F000E
!orbitAngle                     7F0010
!orbitDiameter                  7F0012
!loopCounter                    7F0014
!moveXAlt                       7F0018
!moveYAlt                       7F001A
!retPtr2                        7F001E
!moveScratch1                   7F002C
!moveScratch2                   7F002E

---------------------------------------------

; Attack dispatcher and Freedan ability implementations (178099–179702).
; 
; This part contains the attack companion actor's main dispatch logic plus all of Freedan's abilities. Despite being named after its first piece (AttackSystemEntry), the part spans the full attack dispatcher, both character-specific dispatch paths, all helper routines, and the complete Dark Friar and Aura Barrier ability implementations.
; 
; Major sections within this part:
; 
; 1. Attack Dispatcher (178099–178432): AttackSystemEntry checks player state each frame and listens for the attack button. WillAttackDispatch handles Will's 40-frame hold + 120-frame charge with ability bitmask gating for Psycho Dash/Slider. FreedanAttackDispatch handles Freedan's 40-frame hold + 100-frame charge with Dark Friar/Aura Barrier selection. LaunchPsychoDash, LaunchPsychoSlider, LaunchDarkFriar, and LaunchAuraBarrier validate and hijack the player actor function pointer.
; 
; 2. Attack Helpers (178433–178558): AttackCleanup kills spawned FX and restores palette. SetPlayerActorFunc overwrites the player actor's entry point. ValidateAttackReady checks $3A00 flags and facing direction. ValidateAttackContinue does per-frame $2B00 checks. SavePlayerPosition snapshots position. CheckAttackChargeable gates charge progression via hitstun/death/combo state.
; 
; 3. Aura Barrier (178559–178710): AuraBarrierMain sets flags, spawns VRAM DMA loader, waits for tile upload, loads FX palette, spawns orbital children, and runs the expand→orbit→shrink lifecycle. AuraBarrierEnd clears flags and returns to idle. AuraVramDmaLoader does a one-shot DMA of Aura tile graphics.
; 
; 4. Aura Orbital System (178711–179002): AuraOrbitalSpawner spawns 2-4 orbital children (count depends on upgrade flag $0B1E), manages 240-frame orbit rotation expanding from diameter 0 to 64, then runs a 30-frame shrink. UpdateOrbitalPositions iterates children with angle spacing via ApplyOrbitalOffsetFromRef. AuraProjectileChild is the individual orbiting sprite with 3-frame animation. AuraProjectileShrink reverses the animation and flags for removal.
; 
; 5. Dark Friar (179003–179701): DarkFriarMain sets flags, spawns VRAM DMA, loads palette, spawns a palette reset thinker (#4A), and dispatches by facing direction. Each directional handler (South/North/West/East) spawns a projectile and trail at character-appropriate offsets. DarkFriarProjectile is the initial flash sprite. DarkFriarTrailSouth and DarkFriarTrailEastWest are the growing trail actors with optional collision (enabled by upgrade level $0B1C). DarkFriarBounceLoop handles wall-bounce animation and level-2 redirect. DarkFriarOnHit spawns 4 fragment actors at 90° intervals. DarkFriarFragmentInit sets up spiraling outward motion, DarkFriarFragmentLoop applies velocity until wall contact.

AttackSystemEntry {
    LDA $playerFlags      ; Check player flags for death state — companion actor must die with the player
    BIT #$0008            ; Bit 3 ($0008) = player dead flag
    BEQ code_02B7BD
    COP [Die]             ; Player is dead — kill this attack companion actor

  code_02B7BD:
    LDA #$0001            ; Clear attack-in-progress bit ($0001) each frame before re-evaluation
    TRB $playerFlags
    COP [SetEntryContinue] ; COP re-entry point — companion actor resumes here each frame to poll for attacks
    LDA $playerFlags
    BIT #$2A00            ; Bits 9+11+13 ($2A00) = hurt, knockback, or dialogue transition active — blocks attacking
    BEQ loc_02B7CE
    RTL 

  loc_02B7CE:
    LDA $characterForm    ; Check character form: 0=Will, 1=Freedan; forms 2+ cannot attack through this actor
    CMP #$0002
    BCC loc_02B7D7
    RTL 

  loc_02B7D7:
    COP [BranchIfButton] ( #$8001, &WillAttackDispatch ) ; Listen for attack button ($8001 = B + secondary bit); branch to dispatch on press
    RTL 
}

WillAttackDispatch {
    LDA #$0001            ; Set attack-in-progress flag ($0001) to lock player into the attack flow
    TSB $playerFlags
    LDA #$8000            ; Mark attack button as consumed in joypad held tracker to prevent re-trigger
    TSB $joypadHeld
    LDA $characterForm    ; Check character form — Will (0) continues here, Freedan (1) jumps to FreedanAttackDispatch
    BEQ loc_02B7F2
    JMP $&FreedanAttackDispatch

  loc_02B7F2:
    LDA $abilityBitmask   ; Check Will's ability bitmask for available attacks
    BIT #$0005            ; Bits 0+2 ($0005) = basic attack OR Psycho Slider unlocked; need at least one
    BNE loc_02B7FB
    RTL 

  loc_02B7FB:
    COP [LoopInit] ( #28 ) ; Begin 40-frame ($28 hex) button-hold detection loop — must hold to commit
    COP [BranchIfNoButton] ( #$8001, &code_02B7BD ) ; Attack released during hold period → cancel back to idle (code_02B7BD)
    COP [LoopNext]        ; Hold period complete — player committed to charged attack
    JSR $&SavePlayerPosition ; Snapshot player position for palette FX actor reference point
    COP [SpawnLastRel] ( @WillAttackPaletteFX, #00, #00, #$2C00 ) ; Spawn Will's charge-up palette FX actor (cycles palettes #2A → #2B)
    STY $22               ; Store spawned FX actor ID in DP $22 — AttackCleanup will kill it later
    LDA #$0078            ; Set extended charge timer to 120 frames ($0078)
    STA $24
    COP [SetEntryContinue] ; COP re-entry for per-frame charge loop
    JSR $&ValidateAttackContinue ; Per-frame abort check: hurt, knockback, transition interrupts the charge
    COP [BranchIfNoButton] ( #$8001, &AttackCleanup ) ; Attack released during charge → clean up and return to idle
    DEC $24               ; Decrement charge timer each frame
    BMI loc_02B829        ; Timer expired (negative) → proceed to ability selection phase
    RTL 

  loc_02B829:
    LDA $abilityBitmask   ; Check if Psycho Slider ability (bit 2, $0004) is unlocked
    BIT #$0004
    BNE loc_02B83D        ; Psycho Slider unlocked → enter extended charge with L/R selection
    COP [SetEntryContinue] ; Without Psycho Slider: simple hold loop — release fires Psycho Dash
    JSR $&ValidateAttackContinue
    COP [BranchIfNoButton] ( #$8001, &LaunchPsychoDash ) ; Attack released → launch Psycho Dash (default Will charged ability)
    RTL 

  loc_02B83D:
    COP [SetEntryContinue] ; With Psycho Slider: extended charge with chargeable gate check
    JSR $&ValidateAttackContinue
    COP [BranchIfNoButton] ( #$8001, &LaunchPsychoDash ) ; Attack released → launch Psycho Dash (still the default on release)
    JSR $&CheckAttackChargeable ; Gate check: can the player continue charging? (not in hitstun/death/mid-combo)
    BCC loc_02B84E        ; Not chargeable (carry clear) → fall through to L/R shoulder check
    RTL 

  loc_02B84E:
    COP [BranchIfButton] ( #$0030, &LaunchPsychoSlider ) ; L/R shoulder ($0030) pressed → launch Psycho Slider (alternate ability)
    RTL 
}

LaunchPsychoDash {
    JSR $&ValidateAttackReady ; Validate facing direction and player state before launching Psycho Dash
    LDA #$&PsychoDashMain ; Load PsychoDashMain entry point to overwrite player actor function
    JSR $&SetPlayerActorFunc ; Hijack player actor — player now executes PsychoDashMain instead of normal movement
    JMP $&AttackCleanup
}

LaunchPsychoSlider {
    JSR $&ValidateAttackReady ; Validate and set up Psycho Slider — same pattern as Psycho Dash launch
    LDA #$&PsychoSliderMain ; Load PsychoSliderMain entry point for player actor hijack
    JSR $&SetPlayerActorFunc
    JMP $&AttackCleanup
}

FreedanAttackDispatch {
    LDA $abilityBitmask   ; Check Freedan's ability bitmask for available attacks
    BIT #$0050            ; Bits 4+6 ($0050) = Dark Friar OR basic Freedan attack unlocked
    BNE loc_02B876
    RTL 

  loc_02B876:
    COP [LoopInit] ( #28 ) ; Begin 40-frame ($28 hex) button-hold period — same duration as Will
    COP [BranchIfNoButton] ( #$8001, &code_02B7BD ) ; Released during hold → cancel back to idle
    COP [LoopNext]
    JSR $&SavePlayerPosition ; Snapshot player position for Freedan palette FX reference
    COP [SpawnLastRel] ( @FreedanAttackPaletteFX, #00, #00, #$2C00 ) ; Spawn Freedan's charge-up palette FX actor (cycles palettes #4B → #2C)
    STY $22               ; Store spawned FX actor ID in DP $22 for cleanup
    LDA #$0064            ; Set extended charge timer to 100 frames ($0064) — shorter than Will's 120
    STA $24
    COP [SetEntryContinue] ; COP re-entry for Freedan per-frame charge loop
    JSR $&ValidateAttackContinue
    COP [BranchIfNoButton] ( #$8001, &AttackCleanup ) ; Attack released during charge → abort to cleanup
    COP [BranchIfButton] ( #$40B0, &AttackCleanup ) ; Y/A/L/R ($40B0) pressed during charge → abort (prevents accidental input)
    DEC $24               ; Decrement Freedan charge timer each frame
    BMI loc_02B8AA
    RTL 

  loc_02B8AA:
    LDA $abilityBitmask   ; Timer expired — check if Aura Barrier (bit 5, $0020) is unlocked
    BIT #$0020
    BNE loc_02B8BE
    COP [SetEntryContinue] ; Without Aura Barrier: simple wait-for-release loop
    JSR $&ValidateAttackContinue
    COP [BranchIfNoButton] ( #$8001, &LaunchDarkFriar ) ; Release → launch Dark Friar (only available Freedan ability)
    RTL 

  loc_02B8BE:
    COP [SetEntryContinue] ; With Aura Barrier: extended selection with D-pad guard and L/R trigger
    JSR $&ValidateAttackContinue
    COP [BranchIfNoButton] ( #$8001, &LaunchDarkFriar ) ; Release → launch Dark Friar (still the default ability on release)
    COP [BranchIfButton] ( #$0F00, &AttackChargeReturn ) ; D-pad ($0F00) during charge → return without action (prevents Aura trigger while moving)
    COP [BranchIfButton] ( #$0030, &LaunchAuraBarrier ) ; L/R shoulder ($0030) → launch Aura Barrier (alternate Freedan ability)
}

AttackChargeReturn {
    RTL                   ; Return stub — fall-through target for D-pad guard and end-of-dispatch
}

LaunchDarkFriar {
    LDA #$0001            ; Set ability type flag $00EA = 1 to identify Dark Friar for effects system
    STA $00EA
    JSR $&ValidateAttackReady ; Validate player state and facing before committing to Dark Friar
    LDA #$&DarkFriarMain  ; Load DarkFriarMain entry point for player actor hijack
    JSR $&SetPlayerActorFunc
    BRA AttackCleanup
}

LaunchAuraBarrier {
    LDA $playerSpeedEw    ; Aura Barrier requires the player to be completely stationary
    ORA $playerSpeedNs    ; OR both speed axes — any nonzero movement aborts the ability launch
    BEQ loc_02B8F0
    RTL 

  loc_02B8F0:
    LDA #$0002            ; Set ability type flag $00EA = 2 to identify Aura Barrier
    STA $00EA
    JSR $&ValidateAttackReady
    LDA #$&AuraBarrierMain
    JSR $&SetPlayerActorFunc
    BRA AttackCleanup
}

AttackCleanup {
    PHX                   ; Save X and D registers — will use them to access the FX actor slot
    PHD 
    LDA $22               ; Load spawned FX actor ID from DP $22 (stored during charge-up)
    BEQ loc_02B90B        ; Skip kill if no FX actor was spawned (ID = 0)
    TCD                   ; Set direct page to FX actor's slot to access it via COP MarkDeath
    TAX 
    COP [MarkDeath]       ; Kill the spawned palette FX actor

  loc_02B90B:
    PLD                   ; Restore registers after FX cleanup
    PLX 
    LDA $characterForm    ; Branch on character form for form-specific palette restoration
    BNE loc_02B91C
    COP [PaletteStart] ( #0B ) ; Will (form 0): restore palette bundle #0B after attack ends
    COP [PaletteStep]
    COP [SetEntryExitNow] ( @code_02B7BD ) ; Set entry point to idle loop and exit immediately — attack complete

  loc_02B91C:
    COP [PaletteStart] ( #0C ) ; Freedan (form 1): restore palette bundle #0C after attack ends
    COP [PaletteStep]
    COP [SetEntryExitNow] ( @code_02B7BD )
}

SetPlayerActorFunc {
    LDY $playerActor      ; Load player actor slot base address from $09AA
    STA $0000, Y          ; Write new function pointer A to player actor entry point at offset $0000
    LDA #$0000            ; Zero the frame wait counter at offset $0008 for immediate execution next frame
    STA $0008, Y
    RTS 
}

ValidateAttackReady {
    LDA $playerFlags      ; Pre-attack validation — checks blocking states before ability launch
    BIT #$3A00            ; Bits 9+11+12+13 ($3A00) = hurt, knockback, transform, or transition active
    BNE loc_02B943
    COP [GetPlayerFacing] ; Get player facing direction via COP (returns 0–3 in A)
    CMP #$0004            ; Facing must be cardinal (< 4); diagonal or invalid facings abort the attack
    BCS loc_02B943
    RTS 

  loc_02B943:
    PLA                   ; Abort pattern: pop return address (bypasses caller's RTS) and jump to AttackCleanup
    BRA AttackCleanup
}

ValidateAttackContinue {
    LDA $playerFlags      ; Per-frame validation — lighter check than ValidateAttackReady
    BIT #$2B00            ; Bits 0+8+9+11 ($2B00) = attack lock + hurt + knockback + transition
    BNE loc_02B943
    RTS 
}

SavePlayerPosition {
    LDY $playerActor      ; Snapshot current player actor position for child actor offset calculations
    LDA $0014, Y          ; Copy actor X position from player slot offset $14 to DP $14
    STA $14
    LDA $0016, Y          ; Copy actor Y position from player slot offset $16 to DP $16
    STA $16
    RTS 
}

CheckAttackChargeable {
    LDA $playerFlags      ; Check whether the in-progress attack can continue charging
    BIT #$8000            ; Bit 15 ($8000) = player in invincibility recovery from hit → not chargeable
    BEQ loc_02B967

  loc_02B965:
    SEC                   ; SEC = not chargeable — caller should fire or abort the charge
    RTS 

  loc_02B967:
    LDY $playerActor      ; Load animation state from player slot offset $28
    LDA $0028, Y
    BMI loc_02B965        ; Negative animation state = special/locked animation → not chargeable
    CMP #$0004            ; Frames 0–3 = idle or basic stance → still chargeable
    BCC loc_02B97D
    SEC 
    SBC #$0010            ; Subtract $10 to check extended range ($10–$13 also chargeable)
    CMP #$0004
    BCS loc_02B965

  loc_02B97D:
    CLC                   ; CLC = chargeable — charge may continue
    RTS 
}

AuraBarrierMain {
    LDA #$0200            ; Set bit 9 ($0200) in actor flags — marks ability FX active on this actor
    TSB $10
    LDA #$0800            ; Set bit 11 ($0800) in player flags — Aura Barrier active state
    TSB $playerFlags
    COP [SpawnLastRel] ( @AuraVramDmaLoader, #00, #00, #$2600 ) ; Spawn VRAM DMA loader to upload Aura Barrier tile graphics to VRAM
    CPY #$1FC0            ; Check spawn result — $1FC0 = actor pool exhausted, spawn failed
    BNE loc_02B99B
    JMP $&AuraBarrierEnd  ; Pool exhausted → skip directly to AuraBarrierEnd

  loc_02B99B:
    LDA $16               ; Check if VRAM DMA has completed (DP $16 reaching $0020 signals ready)
    CMP #$0020
    BNE loc_02B9B4
    COP [SetEntryExit]
    COP [LoopInit] ( #08 )
    LDA $7F0C07           ; $7F0C07 = adhoc VRAM destination cache; $4400 means DMA still pending
    CMP #$4400
    BNE loc_02B9C0
    COP [LoopNext]
    BRA loc_02B9C0

  loc_02B9B4:
    COP [SetEntryContinue] ; DMA still pending — yield each frame until transfer completes
    LDA $7F0C07
    CMP #$4400
    BNE loc_02B9C0
    RTL 

  loc_02B9C0:
    COP [CopyPalette] ( @fx_palette_198090, #00, #A9, #07 ) ; Copy Aura Barrier FX palette: 7 words from offset $00 into CGRAM position $A9
    COP [SetPlayerBodySprite] ( #06 ) ; Set player body to Aura casting pose (sprite #06)
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @AuraBarrierPaletteFX, #00, #00, #$2400 ) ; Spawn Aura Barrier palette cycling FX actor (palette #5B infinite loop)
    TYA 
    STA $orbitDiameter, X ; Store palette FX actor ID in orbitDiameter for KillSpawnedProjectile cleanup
    COP [StageSpriteLoop] ( #03, #02 ) ; Stage Aura casting animation loop: sprite #03, 2 iterations
    COP [AnimLoop]
    LDA #$0001            ; Clear attack-in-progress bit — player can now move during Aura Barrier
    TRB $playerFlags
    COP [SpawnLastRel] ( @AuraOrbitalSpawner, #00, #F0, #$2600 ) ; Spawn the orbital child spawner at Y offset -16 (above player head)
    COP [StageSpriteLoop] ( #03, #0A ) ; Stage orbital sustain animation: sprite #03, 10 iterations
    COP [AnimLoop]
    JSR $&KillSpawnedProjectile ; Kill spawned projectile/FX actor after Aura Barrier animation ends
}

AuraBarrierEnd {
    LDA #$0200            ; Clear ability FX flag ($0200) from actor flags
    TRB $10
    LDA $retPtr1, X       ; Check for saved return pointer — restore if one exists
    BEQ loc_02BA09
    COP [RestoreSavedPtr] ; Restore saved return pointer before returning to idle

  loc_02BA09:
    JMP $&player_character.PlayerIdleEntry ; Return to player idle via player_character.PlayerIdleEntry
}

AuraVramDmaLoader {
    COP [AdhocVramDma] ( @misc_fx_1CC480, #$4400, #$0600 ) ; One-shot DMA: upload Aura tiles ($0600 bytes from misc_fx_1CC480) to VRAM $4400
    COP [Die]
}

AuraOrbitalSpawner {
    STZ $24               ; Zero child count ($24) and orbit angle accumulator ($26)
    STZ $26
    LDA #$0000            ; Initialize orbit diameter to 0 — orbitals will expand outward from center
    STA $orbitDiameter, X
    LDA $0B1E             ; Check $0B1E (Aura upgrade flag) — upgraded version spawns 4 orbitals instead of 2
    BEQ loc_02BA39
    COP [SpawnMarkedAfter] ( @AuraProjectileChild, #$0600 ) ; Upgraded: spawn first additional orbital child (only if upgrade flag set)
    INC $24
    COP [SpawnMarkedAfter] ( @AuraProjectileChild, #$0600 )
    INC $24

  loc_02BA39:
    COP [SpawnMarkedAfter] ( @AuraProjectileChild, #$0600 ) ; Spawn standard orbital child (always present regardless of upgrade)
    INC $24
    COP [SpawnMarkedAfter] ( @AuraProjectileChild, #$0600 )
    LDA #$00F0            ; Set orbital lifetime to 240 frames ($00F0)
    STA $20
    COP [SetEntryContinue] ; COP re-entry for per-frame orbital management loop
    LDA $playerFlags      ; Check attack-in-progress flag — set means player released button → begin shrink
    BIT #$0001
    BNE loc_02BA7D
    LDA $26               ; Advance orbit angle by 2 units per frame (smooth rotation speed)
    CLC 
    ADC #$0002
    AND #$00FF
    STA $26
    STA $orbitAngle, X
    LDA $orbitDiameter, X ; Read current orbit diameter for expansion check
    CMP #$0040            ; Maximum orbit radius = $40 (64 pixels from player center)
    BCS loc_02BA75
    INC                   ; Expand orbit diameter by 1 pixel per frame until maximum reached
    STA $orbitDiameter, X

  loc_02BA75:
    JSR $&UpdateOrbitalPositions ; Recompute all orbital child positions at updated angle and diameter
    DEC $20               ; Decrement orbital lifetime timer
    BMI loc_02BA7D
    RTL 

  loc_02BA7D:
    LDA $24               ; Lifetime expired or button released — switch all children to shrink animation
    STA $0000
    LDY $06

  loc_02BA84:
    LDA #$&AuraProjectileShrink ; Overwrite each child's function pointer to AuraProjectileShrink via linked list walk
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA $0006, Y
    TAY 
    DEC $0000
    BPL loc_02BA84
    COP [LoopInit] ( #1E ) ; Run 30-frame ($1E hex) shrink loop — contracts orbit back to center
    LDA $26
    CLC 
    ADC #$0002
    AND #$00FF
    STA $26
    STA $orbitAngle, X
    LDA $orbitDiameter, X ; Check if diameter has reached zero
    BEQ loc_02BAB6
    DEC                   ; Shrink diameter by 1 per frame
    STA $orbitDiameter, X

  loc_02BAB6:
    JSR $&UpdateOrbitalPositions ; Recompute child positions during shrink phase
    COP [LoopNext]
    COP [Die]
}

UpdateOrbitalPositions {
    PHD                   ; Save direct page — will iterate through child actors by setting DP to each slot
    LDA #$0080            ; Initial angle spacing = $0080 (128 units = 180° for 2 orbitals)
    STA $0002
    LDA $24
    STA $0000
    LDA $06

  loc_02BACB:
    TCD                   ; Set DP to current child actor slot — position fields at DP offsets become accessible
    LDY $playerActor
    JSL $@ApplyOrbitalOffsetFromRef ; Compute orbital offset from player position via sine/cosine lookup (JSL ApplyOrbitalOffsetFromRef)
    LDA $orbitAngle, X
    CLC                   ; Advance this child's orbit angle by the spacing amount
    ADC $0002
    AND #$00FF
    STA $orbitAngle, X
    LDA $0002
    CMP #$0040            ; Toggle spacing between $40 (90° for 4 orbitals) and $80 (180° for 2 orbitals)
    BNE loc_02BAEF
    LDA #$0080
    BRA loc_02BAF2

  loc_02BAEF:
    LDA #$0040

  loc_02BAF2:
    STA $0002
    LDA $06
    DEC $0000
    BPL loc_02BACB
    PLD 
    RTS 
}

AuraProjectileChild {
    LDA $sceneCurrent     ; Check current scene ID for special rendering adjustment
    AND #$00FF
    CMP #$00DD            ; Scene $DD uses modified sprite priority flags for Dark Space visibility
    BNE loc_02BB13
    LDA $0E
    AND #$CFFF
    ORA #$2000
    STA $0E

  loc_02BB13:
    COP [SetMetasprite] ( @table_179000 ) ; Set metasprite table to table_179000 (Aura orbital projectile graphics)
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]

  loc_02BB22:
    COP [StageSpriteFrame] ( #02 ) ; Infinite animation loop on frame #02 — orbits until parent commands shrink
    COP [AnimOnce]
    BRA loc_02BB22

  AuraProjectileShrink:
    COP [StageSpriteFrame] ( #01 ) ; Shrink reverse animation: frames #01 → #00 (reverse of spawn-in sequence)
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    LDA #$2000            ; Set bit 13 ($2000) in actor flags — marks for deferred removal by parent
    TSB $10
    COP [SetEntryContinue]
    RTL 
}

DarkFriarMain {
    LDA #$2000            ; Set bit 13 ($2000) in player flags — Dark Friar active state marker
    TSB $playerFlags
    COP [SpawnLastRel] ( @DarkFriarVramDma, #00, #00, #$2600 ) ; Spawn VRAM DMA loader for Dark Friar tile graphics
    CPY #$1FC0            ; Check spawn result — $1FC0 = pool exhausted
    BNE loc_02BB52
    JMP $&DarkFriarFinish ; Pool exhausted → skip to DarkFriarFinish (clean exit)

  loc_02BB52:
    LDA $16               ; Wait for VRAM DMA completion — same DMA-wait pattern as AuraBarrierMain
    CMP #$0020
    BNE loc_02BB6B
    COP [SetEntryExit]
    COP [LoopInit] ( #08 )
    LDA $7F0C07
    CMP #$4400
    BNE loc_02BB77
    COP [LoopNext]
    BRA loc_02BB77

  loc_02BB6B:
    COP [SetEntryContinue]
    LDA $7F0C07
    CMP #$4400
    BNE loc_02BB77
    RTL 

  loc_02BB77:
    COP [CopyPalette] ( @fx_palette_198070, #00, #A0, #10 ) ; Copy Dark Friar FX palette: 16 words from offset $00 into CGRAM position $A0
    COP [SpawnThinkerParam] ( #4A, @cop_handlers_actors.PaletteResetAndKillThinker ) ; Spawn palette reset thinker (ID #4A) — auto-restores palette on ability end
    COP [GetPlayerFacing] ; Get player facing for directional projectile dispatch (0=S, 1=N, 2=W, 3=E)
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &DarkFriarDirTable ) ; Switch on facing direction → dispatch to directional Dark Friar spawner
}

DarkFriarDirTable [
  &DarkFriarSouth   ;00
  &DarkFriarNorth   ;01
  &DarkFriarWest   ;02
  &DarkFriarEast   ;03
]

DarkFriarSouth {
    COP [SpawnLastRel] ( @DarkFriarProjectile, #FE, #1A, #$2600 ) ; South: spawn projectile at (-2, +26) relative to player
    COP [SpawnLastRel] ( @DarkFriarTrailSouth, #FE, #1A, #$2600 ) ; South: spawn trail actor at same offset — follows behind projectile
    COP [StagePlayerSprite] ( #36 ) ; Play Freedan south casting animation (sprite #36)
    COP [AnimOnce]
    BRA DarkFriarFinish
}

DarkFriarNorth {
    COP [SpawnLastRel] ( @DarkFriarProjectile, #00, #C0, #$2600 ) ; North: spawn projectile at (0, -64) — above player
    COP [SpawnLastRel] ( @DarkFriarTrailSouthInit, #00, #C0, #$2600 ) ; North: spawn trail via DarkFriarTrailSouthInit (reuses south path with direction flag)
    COP [StagePlayerSprite] ( #37 )
    COP [AnimOnce]
    BRA DarkFriarFinish
}

DarkFriarWest {
    COP [SpawnLastRel] ( @DarkFriarProjectile, #CC, #EA, #$2600 ) ; West: spawn projectile at (-52, -22) — to the left
    COP [SpawnLastRel] ( @DarkFriarTrailWestInit, #CC, #EA, #$2600 ) ; West: spawn trail via DarkFriarTrailWestInit (sets horizontal movement flag)
    COP [StagePlayerSprite] ( #38 )
    COP [AnimOnce]
    BRA DarkFriarFinish
}

DarkFriarEast {
    COP [SpawnLastRel] ( @DarkFriarProjectile, #34, #EA, #$2600 ) ; East: spawn projectile at (+52, -22) — to the right
    COP [SpawnLastRel] ( @DarkFriarTrailEastWest, #34, #EA, #$2600 ) ; East: spawn trail actor directly (DarkFriarTrailEastWest — no init flag needed)
    COP [StagePlayerSprite] ( #39 ) ; Play Freedan east casting animation (sprite #39)
    COP [AnimOnce]
}

DarkFriarFinish {
    COP [WaitByte] ( #07 ) ; Wait 7 frames for casting animation to complete
    COP [RestoreSavedPtr] ; Restore saved return pointer — returns player actor to pre-ability state
}

DarkFriarVramDma {
    COP [AdhocVramDma] ( @misc_fx_1CC000, #$4400, #$0480 ) ; One-shot DMA: upload Dark Friar tiles ($0480 bytes from misc_fx_1CC000) to VRAM $4400
    COP [Die]
}

DarkFriarProjectile {
    COP [SetMetasprite] ( @table_178000 ) ; Set metasprite to table_178000 (Dark Friar projectile graphics)
    JSR $&ComputeParentOffset ; Compute offset from parent — tracks relative position for trail following
    COP [WaitByte] ( #07 ) ; Wait 7 frames before revealing projectile (syncs with casting animation)
    JSR $&ApplyParentOffset ; Apply stored offset to follow parent's movement during delay
    LDA #$2000            ; Clear bit 13 ($2000) — make projectile visible after sync delay
    TRB $10
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    COP [Die]             ; Self-destruct — visual flash actor has served its purpose
}

DarkFriarTrailSouthInit {
    LDA #$2000            ; Set bit 13 ($2000) in mirror flags ($12) — south direction marker for trail
    TSB $12
}

DarkFriarTrailSouth {
    LDA #$0000            ; Load animation table B entry 0 — Dark Friar trail sprite configuration
    JSR $&LoadAbilityAnimTableB
    COP [SetMetasprite] ( @table_178000 )
    LDA $playerFlags      ; Check player flags bit 7 ($0080) for behind-wall rendering mode
    BIT #$0080
    BEQ loc_02BC42
    COP [SetSpritePriority] ( #30 ) ; Behind wall: lower sprite priority (#30) to render behind foreground tiles

  loc_02BC42:
    JSR $&ComputeParentOffset ; Compute offset from parent — trail tracks the projectile position
    COP [WaitByte] ( #07 ) ; Wait 7 frames (sync with projectile reveal delay)
    JSR $&ApplyParentOffset
    LDA #$2000            ; Clear bit 13 ($2000) — make trail visible after sync delay
    TRB $10
    LDA $0B1C             ; $0B1C = Dark Friar upgrade level; nonzero enables damage-on-contact
    BEQ loc_02BC5D
    COP [OrActorFlags] ( #$0010 ) ; Upgraded: enable damage flag ($0010) in actor flags — trail can hurt enemies
    COP [SetCollideCallback] ( &DarkFriarOnHit ) ; Set collision callback → DarkFriarOnHit (triggers fragment burst on contact)

  loc_02BC5D:
    COP [StageSpriteLoopMoveY] ( #01, #02, #01 ) ; Trail growing animation: small south movement (sprite #01, speed 1, 2 iterations)
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #02, #03, #03 )
    COP [AnimLoop]
    COP [StageSprAndHitbox] ( #03 ) ; Final trail sprite #03 with active hitbox for continued collision detection
    COP [StageForceMoveXY] ( #00, #05 ) ; Apply constant force movement: 0 X, 5 Y → trail continues south
    BRA loc_02BCCA
}

DarkFriarTrailWestInit {
    LDA #$4000            ; Set bit 14 ($4000) in mirror flags — west/horizontal direction marker for trail
    TSB $12
}

DarkFriarTrailEastWest {
    LDA #$0000            ; Shared trail code for east and west directions — uses X-axis movement instead of Y
    JSR $&LoadAbilityAnimTableB
    COP [SetMetasprite] ( @table_178000 )
    LDA $playerFlags      ; Check player flags bit 7 ($0080) for behind-wall rendering mode
    BIT #$0080
    BEQ loc_02BC8F
    COP [SetSpritePriority] ( #30 ) ; Behind wall: lower sprite priority (#30) to render behind foreground tiles

  loc_02BC8F:
    JSR $&ComputeParentOffset ; Compute offset from parent — trail tracks projectile position
    COP [WaitByte] ( #07 ) ; Wait 7 frames (sync with projectile reveal delay)
    JSR $&ApplyParentOffset
    LDA #$2000            ; Clear bit 13 ($2000) — make trail visible after sync delay
    TRB $10
    LDA $0B1C             ; $0B1C = Dark Friar upgrade level; nonzero enables damage-on-contact
    BEQ loc_02BCAA
    COP [OrActorFlags] ( #$0010 ) ; Upgraded: enable damage flag ($0010) in actor flags
    COP [SetCollideCallback] ( &DarkFriarOnHit ) ; Set collision callback → DarkFriarOnHit (triggers fragment burst on contact)

  loc_02BCAA:
    COP [StageSpriteLoopMoveX] ( #01, #02, #01 ) ; Trail growing animation with X movement (sprite #01, speed 1, 2 iterations)
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #02, #03, #03 )
    COP [AnimLoop]
    COP [StageSprAndHitbox] ( #03 )
    COP [StageForceMoveXY] ( #05, #00 ) ; Apply constant force movement: 5 X, 0 Y → trail moves horizontally
    BRA loc_02BCCA

  DarkFriarBounceLoop:
    LDA $10               ; Check bit 14 ($4000) of actor flags — set on wall contact
    BIT #$4000
    BNE loc_02BCEC        ; Wall hit → die (trail dissipates on wall contact)
    COP [ReloadForceMove] ; No wall hit: reload force movement parameters for continued travel

  loc_02BCCA:
    COP [AnimOneFrame]    ; Animate one frame and check for collision events
    LDA $2A
    BEQ DarkFriarBounceLoop
    LDA $08               ; Read frame counter from $08 — captures wall-hit timing data
    STZ $08
    STA $26

  loc_02BCD6:
    LDA $0B1C             ; $0B1C = Dark Friar upgrade level: 2 = fully upgraded with player redirect
    CMP #$0002
    BNE loc_02BCE4
    COP [BranchIfButton] ( #$8001, &DarkFriarDisableCollide ) ; Level 2 + attack button held → DarkFriarDisableCollide (player can redirect trail)

  loc_02BCE4:
    COP [SetEntryExit]    ; Set re-entry and yield — continue bounce/travel loop next frame
    DEC $26
    BPL loc_02BCD6
    BRA loc_02BCCA

  loc_02BCEC:
    COP [Die]
}

DarkFriarDisableCollide {
    COP [SetCollideCallback] ( #$0000 ) ; Clear collision callback ($0000) — disables trail damage for redirect
}

DarkFriarOnHit {
    COP [SpawnAfterFlags] ( @DarkFriarFragment1, #$0600 ) ; On collision: spawn 3 fragment actors plus self (4 total at 90° intervals)
    COP [SpawnAfterFlags] ( @DarkFriarFragment2, #$0600 )
    COP [SpawnAfterFlags] ( @DarkFriarFragment3, #$0600 )
    LDA #$0000            ; Self becomes fragment at 0° angle — falls through to DarkFriarFragmentInit
    BRA DarkFriarFragmentInit
}

DarkFriarFragment1 {
    LDA #$0040            ; Fragment 1 starts at 64° ($40) orbit angle
    BRA DarkFriarFragmentInit
}

DarkFriarFragment2 {
    LDA #$0080            ; Fragment 2 starts at 128° ($80) orbit angle
    BRA DarkFriarFragmentInit
}

DarkFriarFragment3 {
    LDA #$00C0            ; Fragment 3 starts at 192° ($C0) orbit angle

  DarkFriarFragmentInit:
    STA $orbitAngle, X    ; Store initial orbit angle for this fragment's spiral expansion path
    LDA #$0000            ; Load animation table B entry 0 for fragment sprite set
    JSR $&LoadAbilityAnimTableB
    LDA #$0000            ; Initialize orbit diameter to 0 — fragments spiral outward from impact point
    STA $orbitDiameter, X
    LDA $14               ; Save current X position as spiral center reference (moveXAlt)
    STA $moveXAlt, X
    LDA $16
    STA $moveYAlt, X      ; Save current Y position as spiral center (moveYAlt)
    COP [SpawnMarkedAfter] ( @TrailFollowerSprB, #$0600 ) ; Spawn trail follower sprite B — visual trail segment behind fragment
    COP [SpawnMarkedAfter] ( @TrailFollowerSprA, #$0600 ) ; Spawn trail follower sprite A — second trail segment for longer trail
    LDA #$0001            ; Initialize X and Y movement deltas to 1 — minimal initial velocity
    STA $7F100E, X
    STA $7F100C, X
    COP [StageSprAndHitbox] ( #04 ) ; Set sprite #04 with active hitbox — fragment damages enemies on contact

  loc_02BD52:
    COP [AnimOneFrame]    ; Fragment animation loop — animate and wait for wall collision event ($2A)
    LDA $2A
    BEQ loc_02BD52
    LDA $08
    STZ $08
    STA $26

  loc_02BD5E:
    COP [SetEntryExit]    ; Per-frame spiral update: advance angle by 2, expand diameter by 4
    SEP #$20              ; Switch to 8-bit accumulator for byte-level angle and diameter math
    LDA $orbitAngle, X
    CLC 
    ADC #$02
    STA $orbitAngle, X
    LDA $orbitDiameter, X
    CLC 
    ADC #$04
    STA $orbitDiameter, X
    BCS loc_02BDA8        ; Diameter overflow (carry set) → max range reached, begin velocity reversal
    REP #$20
    LDA $14
    PHA 
    LDA $16
    PHA 
    LDA $moveXAlt, X      ; Load spiral center X to compute new orbital position
    STA $14
    LDA $moveYAlt, X
    STA $16
    JSL $@ApplyOrbitalOffsetFromRef.code_00F3D3 ; Compute orbital offset at current angle and diameter via ApplyOrbitalOffsetFromRef
    PLA 
    SEC 
    SBC $16
    STA $7F100E, X        ; Calculate Y velocity = old position − new spiral position
    PLA 
    SEC 
    SBC $14
    STA $7F100C, X        ; Calculate X velocity = old position − new spiral position
    DEC $26
    BPL loc_02BD5E
    BRA loc_02BD52

  loc_02BDA8:
    REP #$20              ; Max range reversal: restore 16-bit mode for velocity negation
    LDA #$6000
    TRB $12               ; Clear direction flags ($6000) in mirror register for velocity reversal
    LDA $7F100C, X        ; Negate X velocity (EOR #$FFFF + INC = two's complement) — reverse horizontal
    EOR #$FFFF
    INC 
    STA $7F100C, X
    LDA $7F100E, X        ; Negate Y velocity — reverse vertical direction
    EOR #$FFFF
    INC 
    STA $7F100E, X
    BRA loc_02BDD7

  DarkFriarFragmentLoop:
    COP [AnimOneFrame]    ; Fragment return phase: animate and apply reversed velocity each frame
    LDA $2A
    BEQ DarkFriarFragmentLoop
    LDA $08
    STZ $08
    STA $26

  loc_02BDD5:
    COP [SetEntryExit]

  loc_02BDD7:
    LDA $7F100C, X        ; Copy stored X velocity to moveScratch1 for engine movement application
    STA $moveScratch1, X
    LDA $7F100E, X        ; Copy stored Y velocity to moveScratch2 for engine movement
    STA $moveScratch2, X
    LDA $10
    BIT #$4000            ; Check bit 14 ($4000) — wall collision during return phase
    BNE loc_02BDF4        ; Wall hit during return → die (fragment fully dissipated)
    DEC $26
    BPL loc_02BDD5
    BRA DarkFriarFragmentLoop

  loc_02BDF4:
    COP [Die]
}

TrailFollowerSprA {
    COP [StageSprAndHitbox] ( #05 ) ; Stage sprite #05 with hitbox — smaller trail segment (spawned second, furthest behind parent)
    BRA loc_02BDFE        ; Jump to shared trail follower main loop
}

TrailFollowerSprB {
    COP [StageSprAndHitbox] ( #06 ) ; Stage sprite #06 with hitbox — larger trail segment (spawned first, directly behind parent)

  loc_02BDFE:
    JSR $&TrailPositionInit ; Initialize 3-stage position FIFO buffer with current position

  loc_02BE01:
    COP [AnimOneFrame]    ; Main loop: animate one frame and wait for collision/movement event ($2A)
    LDA $2A
    BEQ loc_02BE01
    LDA $08               ; Capture frame count from $08 — determines how many cascade updates to run this cycle
    STZ $08
    STA $26

  loc_02BE0D:
    COP [SetEntryExit]    ; Per-frame cascade: yield execution, then shift one position through the FIFO
    LDY $04               ; Load parent actor ID from $04 for position sampling
    JSR $&TrailPositionCascade ; Cascade parent position through the 3-stage FIFO buffer
    DEC $26               ; Decrement remaining cascade updates
    BPL loc_02BE0D
    BRA loc_02BE01        ; Loop back to animation wait for next event cycle
}

---------------------------------------------
; 3-stage position FIFO cascade for Dark Friar afterimage effect.
; 
; Each frame, shifts position data through three FIFO stages: stage 2 receives stage 1's position, stage 1 receives stage 0's position, stage 0 receives the current player position. This creates a trailing afterimage effect where follower sprites lag behind the player by 1, 2, and 3 frames respectively.

TrailPositionCascade {
    LDA $animScratch, X   ; Read stage 1 X (oldest buffered position) into display position $14
    STA $14
    LDA $animScratch+2, X ; Shift stage 2 X → stage 1 (advance X queue by one frame)
    STA $animScratch, X
    LDA $animScratch2, X  ; Shift stage 3 X → stage 2
    STA $animScratch+2, X
    LDA $0014, Y          ; Sample parent's current X position ($0014,Y) into stage 3 (newest X entry)
    STA $animScratch2, X
    LDA $moveXAlt, X      ; Read stage 1 Y (oldest buffered position) into display position $16
    STA $16
    LDA $moveYAlt, X      ; Shift stage 2 Y → stage 1 (advance Y queue by one frame)
    STA $moveXAlt, X
    LDA $retPtr1, X       ; Shift stage 3 Y → stage 2
    STA $moveYAlt, X
    LDA $0016, Y          ; Sample parent's current Y position ($0016,Y) into stage 3 (newest Y entry)
    STA $retPtr1, X
    RTS 
}

---------------------------------------------
; Initialize trail follower position FIFO.
; 
; Sets all three FIFO stages to the current player position, so trail followers start at the player's location rather than at (0,0). Called once when the Dark Friar attack begins.

TrailPositionInit {
    LDA $14               ; Seed all 3 X-position FIFO stages with current X ($14) — trail starts co-located
    STA $animScratch, X
    STA $animScratch+2, X
    STA $animScratch2, X
    LDA $16               ; Seed all 3 Y-position FIFO stages with current Y ($16)
    STA $moveXAlt, X
    STA $moveYAlt, X
    STA $retPtr1, X
    RTS 
}

---------------------------------------------
; Will ability implementations, projectile actors, palette FX, and utility routines (179826–181132).
; 
; This part contains all of Will's ability code plus shared helper routines. Despite being named after its first piece (ComputeParentOffset), the part spans offset helpers, the complete Psycho Dash and Psycho Slider implementations, the guided projectile actor, all palette FX actors, and animation table loaders.
; 
; Major sections within this part:
; 
; 1. Offset Helpers (179826–179871): ComputeParentOffset stores the XY delta between current position and a parent actor. ApplyParentOffset adds the stored delta back to the parent's current position. Used by Dark Friar projectile/trail actors to maintain relative positioning.
; 
; 2. Psycho Dash (179872–180392): PsychoDashMain loads animation table A entry 0, disables status display, dispatches by facing. Each directional handler (South/North/West/East) spawns a trail afterimage actor, sets the movement direction via force flags, stages a ~54-pixel dash movement, then returns to idle. The four PsychoDashTrail actors (South/North/West/East) record 8 position deltas during the dash and replay them in reverse as afterimage segments.
; 
; 3. Psycho Slider (180393–180763): PsychoSliderMain sets $2002 flags, enters a charge loop checking for wall collision ($0080), then transitions to either the charge tick phase (L/R shoulder decrement charge level) or projectile launch. On launch, spawns GuidedProjectileActor, kills it on completion, and uses an RTS-trick (PEA label-1) to chain through directional speed setup → PsychoSliderRelease → PsychoSliderLaunch. PsychoSliderChargeTick alternates L/R shoulder checks on odd/even frames. PsychoSliderAbort clears flags and restores state.
; 
; 4. Guided Projectile (180764–180999): KillSpawnedProjectile cleans up a stored actor reference via MarkDeath. GuidedProjectileActor stores its offset from the player, responds to D-pad input for 4-directional steering (Right=#3D, Left=#3C, Up=#3B, Down=#3A sprites), and runs a per-frame animation/collision loop.
; 
; 5. Palette FX & Utilities (181000–181131): WillAttackPaletteFX cycles palettes #2A→#2B. FreedanAttackPaletteFX cycles #4B→#2C. AuraBarrierPaletteFX loops #5B infinitely. RecomputeProjectilePos adds stored offsets to current player position. LoadAbilityAnimTableA reads indexed entries from table_01D9A7 (Will). LoadAbilityAnimTableB reads from table_01D9BF (Freedan). Both store a configuration byte to climbStateData ($09E0/$09E2).

ComputeParentOffset {
    LDY $24               ; Load parent actor ID from DP $24 for position reference
    LDA $14
    SEC 
    SBC $0014, Y          ; X offset = current X − parent X; store in $7F100C,X
    STA $7F100C, X
    LDA $16
    SEC 
    SBC $0016, Y          ; Y offset = current Y − parent Y; store in $7F100E,X
    STA $7F100E, X
    RTS 
}

ApplyParentOffset {
    LDY $24               ; Add stored offset to parent's current position — child follows parent movement
    LDA $0014, Y
    CLC 
    ADC $7F100C, X        ; New X = parent X + stored X offset
    STA $14
    LDA $0016, Y
    CLC 
    ADC $7F100E, X
    STA $16
    RTS 
}

PsychoDashMain {
    LDA #$0000            ; Load animation table A entry 0 — Psycho Dash sprite configuration
    JSR $&LoadAbilityAnimTableA
    JSR $&player_character.DisableStatusForAttack ; Disable status display during Psycho Dash execution (cross-file call)
    COP [GetPlayerFacing] ; Get player facing for directional dash dispatch (0=S, 1=N, 2=W, 3=E)
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &PsychoDashDirTable ) ; Switch on facing → dispatch to directional Psycho Dash handler
}

PsychoDashDirTable [
  &PsychoDashSouth   ;00
  &PsychoDashNorth   ;01
  &PsychoDashWest   ;02
  &PsychoDashEast   ;03
]

PsychoDashSouth {
    COP [SpawnAfter] ( @PsychoDashTrailSouth ) ; South: spawn trail afterimage actor for dash path
    COP [SetPlayerBodySprite] ( #04 ) ; Set player body to Psycho Dash pose (sprite #04)
    COP [StageSpriteMoveY] ( #04, #36 ) ; Stage south movement: sprite #04, move speed/distance #36 (~54 pixels southward)
    COP [AnimOnce]
    BRA loc_02BF03
}

PsychoDashNorth {
    COP [SpawnAfter] ( @PsychoDashTrailNorth ) ; North: spawn trail afterimage actor for northward dash path
    COP [SetForceNE] ( #01 ) ; Set NE force direction — reverses Y movement for northward dash
    COP [SetPlayerBodySprite] ( #04 ) ; Set player body to Psycho Dash pose (sprite #04)
    COP [StageSpriteMoveY] ( #05, #36 ) ; Stage north movement: sprite #05, move speed/distance #36 (~54 pixels northward)
    COP [AnimOnce]
    BRA loc_02BF03
}

PsychoDashWest {
    COP [SpawnAfter] ( @PsychoDashTrailWest ) ; West: spawn trail afterimage actor for westward dash path
    COP [SetForceBoth] ( #01 ) ; Set both force directions — reverses X movement for westward dash
    COP [SetPlayerBodySprite] ( #04 ) ; Set player body to Psycho Dash pose (sprite #04)
    COP [StageSpriteMoveX] ( #06, #36 ) ; Stage west movement: sprite #06, move speed/distance #36 (~54 pixels westward)
    COP [AnimOnce]
    BRA loc_02BF03
}

PsychoDashEast {
    COP [SpawnAfter] ( @PsychoDashTrailEast ) ; East: spawn trail afterimage actor for eastward dash path
    COP [SetPlayerBodySprite] ( #04 ) ; Set player body to Psycho Dash pose (sprite #04)
    COP [StageSpriteMoveX] ( #07, #36 ) ; Stage east movement: sprite #07, move speed/distance #36 (~54 pixels eastward)
    COP [AnimOnce]

  loc_02BF03:
    JSR $&player_character.RestoreStatusDisplay ; Restore status display after Psycho Dash completes
    JMP $&player_character.PlayerIdleEntry ; Return player to idle state — Psycho Dash is complete
}

PsychoDashTrailSouth {
    LDA #$0006            ; Trail recording phase: set step counter to 6, begin capturing 8 position deltas
    STA $08               ; Write trail playback speed (6 frames per segment) to frame counter
    LDY $04
    LDA $0016, Y          ; Read parent actor Y position as recording baseline
    STA $14
    LDA #$09D0            ; Delta buffer starts at $09D0 (scratch area for 8 word-sized entries)
    STA $16
    COP [SetEntryExit]    ; Yield — recording begins on the next frame
    COP [LoopInit] ( #08 ) ; Recording loop: 8 iterations, capture one Y-position delta per frame
    LDY $04
    LDA $14
    SEC 
    SBC $0016, Y          ; Delta = baseline Y − current parent Y (per-frame south movement)
    LDY $16
    INC $16
    INC $16
    STA $0000, Y          ; Store delta into buffer; advance pointer by 2 bytes per entry
    LDY $04
    LDA $0016, Y
    STA $14
    COP [LoopNext]        ; Recording complete — switch to playback mode
    LDA #$0003            ; Playback speed = 3 frames per segment (slower than recording for afterimage effect)
    STA $08
    LDY $04
    LDA #$0000
    STA $002E, Y          ; Zero parent Y movement scratch — trail actor takes over movement control
    COP [SetEntryExit]    ; Yield — playback begins on the next frame
    DEC $16               ; Rewind buffer pointer — deltas played back in reverse order
    DEC $16
    COP [LoopInit] ( #08 ) ; Playback loop: 8 iterations, replay one stored delta per frame
    LDY $16
    DEC $16
    DEC $16
    PHX 
    LDX $04
    LDA $0000, Y
    STA $moveScratch2, X  ; Apply delta to parent moveScratch2 — afterimage reproduces dash movement in reverse
    PLX 
    COP [LoopNext]
    COP [SetEntryExit]    ; Final cleanup: set re-entry for zero-movement frame
    PHX 
    LDX $04
    LDA #$0000            ; Zero residual movement delta — clean stop
    STA $moveScratch2, X
    PLX 
    COP [Die]             ; Self-destruct — trail afterimage lifecycle complete
}

PsychoDashTrailNorth {
    LDA #$0006            ; North trail: same delta recording/playback as south but with inverted Y subtraction
    STA $08               ; Write trail playback speed (6 frames per segment) to frame counter
    LDY $04
    LDA $0016, Y
    STA $14
    LDA #$09D0
    STA $16
    COP [SetEntryExit]    ; Yield — recording begins on the next frame
    COP [LoopInit] ( #08 ) ; Recording loop: 8 iterations, capture one Y-position delta per frame
    LDY $04
    LDA $0016, Y
    SEC                   ; Delta = current parent Y − baseline (inverted from south for northward direction)
    SBC $14
    LDY $16
    INC $16
    INC $16
    STA $0000, Y
    LDY $04
    LDA $0016, Y
    STA $14
    COP [LoopNext]        ; Recording complete — switch to playback mode
    LDA #$0003            ; Playback speed = 3 frames per segment
    STA $08
    LDY $04
    LDA #$0000
    STA $002E, Y          ; Zero parent Y movement scratch for afterimage takeover
    COP [SetEntryExit]    ; Yield — playback begins on next frame
    DEC $16
    DEC $16
    COP [LoopInit] ( #08 )
    LDY $16
    DEC $16
    DEC $16
    PHX 
    LDX $04
    LDA $0000, Y
    STA $moveScratch2, X  ; Apply stored delta to parent moveScratch2 — north afterimage movement
    PLX 
    COP [LoopNext]
    COP [SetEntryExit]    ; Final cleanup: zero residual movement
    PHX 
    LDX $04
    LDA #$0000
    STA $moveScratch2, X
    PLX 
    COP [Die]             ; Self-destruct — north trail lifecycle complete
}

PsychoDashTrailWest {
    LDA #$0006            ; West trail: record 8 X-position deltas during west dash, replay as horizontal afterimage
    STA $08               ; Write trail playback speed (6 frames per segment) to frame counter
    LDY $04
    LDA $0014, Y
    STA $14
    LDA #$09D0            ; Delta buffer at $09D0 for X-axis recording
    STA $16
    COP [SetEntryExit]    ; Yield — recording begins on the next frame
    COP [LoopInit] ( #08 ) ; Recording loop: 8 iterations, capture one X-position delta per frame
    LDY $04
    LDA $0014, Y
    SEC                   ; Delta = current parent X − baseline (horizontal movement)
    SBC $14
    LDY $16
    INC $16
    INC $16
    STA $0000, Y
    LDY $04
    LDA $0014, Y
    STA $14
    COP [LoopNext]        ; Recording complete — switch to playback mode
    LDA #$0003
    STA $08
    LDY $04
    LDA #$0000
    STA $002C, Y          ; Zero parent X movement scratch for afterimage takeover
    COP [SetEntryExit]    ; Yield — playback begins on the next frame
    DEC $16
    DEC $16
    COP [LoopInit] ( #08 )
    LDY $16
    DEC $16
    DEC $16
    PHX 
    LDX $04
    LDA $0000, Y
    STA $moveScratch1, X  ; Apply stored delta to parent moveScratch1 — horizontal afterimage movement
    PLX 
    COP [LoopNext]
    COP [SetEntryExit]    ; Final cleanup: zero residual X movement
    PHX 
    LDX $04
    LDA #$0000
    STA $moveScratch1, X
    PLX 
    COP [Die]             ; Self-destruct — west trail lifecycle complete
}

PsychoDashTrailEast {
    LDA #$0006            ; East trail: record 8 X-position deltas with inverted subtraction, replay in reverse
    STA $08               ; Write trail playback speed (6 frames per segment) to frame counter
    LDY $04
    LDA $0014, Y
    STA $14
    LDA #$09D0
    STA $16
    COP [SetEntryExit]    ; Yield — recording begins on the next frame
    COP [LoopInit] ( #08 ) ; Recording loop: 8 iterations, capture one X-position delta per frame
    LDY $04
    LDA $14
    SEC                   ; Delta = baseline X − current parent X (inverted for eastward direction)
    SBC $0014, Y
    LDY $16
    INC $16
    INC $16
    STA $0000, Y
    LDY $04
    LDA $0014, Y
    STA $14
    COP [LoopNext]        ; Recording complete — switch to playback mode
    LDA #$0003
    STA $08
    LDY $04
    LDA #$0000
    STA $002C, Y          ; Zero parent X movement scratch for afterimage takeover
    COP [SetEntryExit]    ; Yield — playback begins on the next frame
    DEC $16
    DEC $16
    COP [LoopInit] ( #08 )
    LDY $16
    DEC $16
    DEC $16
    PHX 
    LDX $04
    LDA $0000, Y
    STA $moveScratch1, X  ; Apply stored delta to parent moveScratch1 — east afterimage movement
    PLX 
    COP [LoopNext]
    COP [SetEntryExit]    ; Final cleanup: zero residual X movement
    PHX 
    LDX $04
    LDA #$0000
    STA $moveScratch1, X
    PLX 
    COP [Die]             ; Self-destruct — east trail lifecycle complete

  PsychoSliderMain:
    LDA #$8000            ; Mark attack button as consumed in joypad held tracker
    TSB $joypadHeld
    LDA #$2002            ; Set bits 1+13 ($2002) in player flags — Psycho Slider active + attack state
    TSB $playerFlags
    LDA #$000F            ; Initialize charge parameter $26 to $000F — controls slider charge intensity
    STA $26
    STA $orbitAngle, X    ; Store charge parameter in orbitAngle,X for per-frame access
    COP [SetPlayerBodySprite] ( #04 ) ; Set player body to attack pose (sprite #04)
    COP [StageSprAndHitbox] ( #22 ) ; Set sprite #22 with active hitbox — Psycho Slider contact damage during charge
    LDA #$0000
    STA $7F102E, X

  loc_02C0CB:
    COP [SetEntryContinue] ; Main charge animation loop — animate and wait for wall collision or charge input
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_02C0CB
    STZ $08
    LDA $10               ; Check bit 7 ($0080) of actor flags — wall collision during charge
    BIT #$0080
    BEQ loc_02C0DF
    JMP $&PsychoSliderAbort ; Wall hit → abort Psycho Slider entirely

  loc_02C0DF:
    LDA $26               ; Check charge level — negative means already fired; >= $000C enters L/R tick phase
    BMI loc_02C0FB
    CMP #$000C
    BCC loc_02C0FB
    LSR 
    STA $24
    COP [SetEntryContinue] ; Re-entry for button-hold monitoring during charge tick phase
    COP [BranchIfNoButton] ( #$8001, &PsychoSliderAbort ) ; Release during tick → abort Psycho Slider
    JSR $&PsychoSliderChargeTick ; Process charge tick: L/R shoulder buttons decrement charge level alternately
    DEC $24
    BMI loc_02C0CB
    RTL 

  loc_02C0FB:
    LDA #$0002            ; Charge complete or minimum reached — transition to projectile launch phase
    JSR $&LoadAbilityAnimTableA
    LDA #$0100            ; Clear bit 8 ($0100) from actor flags — end charge visual state
    TRB $10
    LDA #$0200            ; Set bit 9 ($0200) — guided projectile active state marker
    TSB $10
    COP [SpawnLastRel] ( @GuidedProjectileActor, #00, #00, #$0302 ) ; Spawn GuidedProjectileActor at player position with special flags $0302
    TYA                   ; Store projectile actor ID in orbitDiameter for later cleanup
    STA $orbitDiameter, X
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #1D, #04 )
    COP [AnimLoop]
    JSR $&KillSpawnedProjectile ; Kill spawned projectile when charge phase completes
    PEA $&PsychoSliderRelease-1 ; RTS trick: push PsychoSliderRelease-1 onto stack — RTS will jump there
    STZ $playerSpeedEw    ; Zero both movement speed axes before applying directional input
    STZ $playerSpeedNs
    LDA $joypadCurrent
    BIT #$0100            ; Right ($0100) pressed → set positive X speed (+7 per frame)
    BEQ loc_02C145
    LDA #$0007
    STA $playerSpeedEw
    STZ $slopeStepCounter
    STZ $decelStepCounter
    RTS 

  loc_02C145:
    BIT #$0200            ; Left ($0200) pressed → set negative X speed (-7 per frame, $FFF9)
    BEQ loc_02C157
    LDA #$FFF9
    STA $playerSpeedEw
    STZ $slopeStepCounter
    STZ $decelStepCounter
    RTS 

  loc_02C157:
    BIT #$0800            ; Up ($0800) pressed → set negative Y speed (-7 per frame, $FFF9)
    BEQ loc_02C169
    LDA #$FFF9
    STA $playerSpeedNs
    STZ $slopeStepCounter
    STZ $decelStepCounter
    RTS 

  loc_02C169:
    BIT #$0400            ; Down ($0400) pressed → set positive Y speed (+7 per frame)
    BEQ loc_02C17B
    LDA #$0007
    STA $playerSpeedNs
    STZ $slopeStepCounter
    STZ $decelStepCounter
    RTS 

  loc_02C17B:
    RTS 
}

PsychoSliderRelease {
    LDA #$2800            ; Clear bits 11+13 ($2800) from player flags — end Psycho Slider state
    TRB $playerFlags
    PEA $&PsychoSliderLaunch-1
    LDA #$&PsychoSliderLaunchLoop
    STA $retPtr2, X
    LDA $0B1A             ; Check $0B1A (Slider upgrade flag): standard=12 frames, upgraded=24 frames launch delay
    BNE loc_02C195
    LDA #$000C
    RTS 

  loc_02C195:
    LDA #$0018
    RTS 
}

PsychoSliderLaunch {
    STA $loopCounter, X   ; Store frame count as loop counter for launch animation sequence
    LDA #$0001            ; Load animation table A entry 1 for slider launch sprite set
    JSR $&LoadAbilityAnimTableA

  PsychoSliderLaunchLoop:
    COP [StageSpriteFrame] ( #1D ) ; Launch animation re-entry point — stored in retPtr2 for COP loop
    COP [AnimOnce]
    COP [LoopNext]
    LDA #$0002            ; Clear bit 1 ($0002) from player flags — end Slider charge state
    TRB $playerFlags
    COP [BranchIfButton] ( #$0300, &PsychoSliderDirEW ) ; Check D-pad left/right ($0300) for horizontal launch direction
    COP [BranchIfButton] ( #$0C00, &PsychoSliderDirNS ) ; Check D-pad up/down ($0C00) for vertical launch direction
    BRA PsychoSliderAbort ; No direction held → abort Psycho Slider (no launch without directional input)
}

PsychoSliderDirEW {
    LDA $joypadCurrent    ; Check left button ($0200) to determine east vs west sprite
    BIT #$0200
    BNE loc_02C1CB
    COP [StagePlayerSprite] ( #03 )
    BRA loc_02C1E0

  loc_02C1CB:
    COP [StagePlayerSprite] ( #02 )
    BRA loc_02C1E0
}

PsychoSliderDirNS {
    LDA $joypadCurrent    ; Check up button ($0800) to determine north vs south launch sprite
    BIT #$0800
    BNE loc_02C1DD
    COP [StagePlayerSprite] ( #00 ) ; South: set player sprite #00 for downward slider launch
    BRA loc_02C1E0

  loc_02C1DD:
    COP [StagePlayerSprite] ( #01 ) ; North: set player sprite #01 for upward slider launch

  loc_02C1E0:
    COP [AnimOneFrame]    ; Animate one frame of directional launch, then clear frame counter
    STZ $08
}

PsychoSliderAbort {
    LDA #$0200            ; Clear bit 9 ($0200) — end guided projectile state
    TRB $10
    COP [RestoreSavedPtr]
}

PsychoSliderChargeTick {
    LDA $26               ; Read charge level from $26; LSR checks odd/even for alternating L/R check
    LSR 
    BCC loc_02C202
    LDA $joypadCurrent    ; Odd frame: check L shoulder ($0020) for charge decrement
    BIT #$0020
    BEQ loc_02C212
    LDA $26
    SEC 
    SBC #$0001
    STA $26
    BRA loc_02C212

  loc_02C202:
    LDA $joypadCurrent    ; Even frame: check R shoulder ($0010) for charge decrement
    BIT #$0010
    BEQ loc_02C212
    LDA $26
    SEC 
    SBC #$0001
    STA $26

  loc_02C212:
    LDA $joypadCurrent    ; Merge L/R button state into held tracker — consumed for next frame
    AND #$0030
    TSB $joypadHeld
    RTS 
}

KillSpawnedProjectile {
    PHX                   ; Save registers for spawned projectile cleanup
    PHD 
    LDA $orbitDiameter, X ; Load spawned actor ID from orbitDiameter,X
    BEQ loc_02C22F        ; Skip if no projectile exists (ID = 0)
    TCD                   ; Set DP to projectile actor slot for COP access
    TAX 
    LDA #$0000
    STA $orbitDiameter, X ; Zero the orbitDiameter reference — prevent double-kill on re-entry
    COP [MarkDeath]       ; Kill the projectile actor via COP MarkDeath

  loc_02C22F:
    PLD 
    PLX 
    RTS 
}

GuidedProjectileActor {
    COP [SetSpritePriority] ( #30 ) ; Set sprite priority #30 — render above background, below player
    LDA $14               ; Compute initial X offset = projectile X − player X → $7F100C,X
    SEC 
    SBC $playerXPos
    STA $7F100C, X
    LDA $16
    SEC 
    SBC $playerYPos       ; Compute initial Y offset = projectile Y − player Y → $7F100E,X
    STA $7F100E, X
    COP [SetMetasprite] ( @table_0EE000 ) ; Set metasprite to table_0EE000 — Psycho Slider projectile graphics

  code_02C24E:
    COP [BranchIfButton] ( #$0100, &ProjectileMoveRight ) ; D-pad direction dispatch: right=$0100, left=$0200, up=$0800, down=$0400
    COP [BranchIfButton] ( #$0200, &ProjectileMoveLeft )
    COP [BranchIfButton] ( #$0800, &ProjectileMoveUp )
    COP [BranchIfButton] ( #$0400, &ProjectileMoveDown )
    COP [SetEntryContinue] ; No direction → neutral float with sprite #39 (idle projectile pose)
    COP [StageSprAndHitbox] ( #39 )

  loc_02C26B:
    COP [AnimOneFrame]    ; Per-frame: animate one frame, check collisions, track D-pad for steering
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $2A
    BEQ loc_02C26B
    COP [BranchIfButton] ( #$0F00, &code_02C24E )
    JSR $&RecomputeProjectilePos
    DEC $24
    BMI loc_02C26B
    RTL 
}

ProjectileMoveRight {
    COP [StageSprAndHitbox] ( #3D ) ; Right: stage directional sprite #3D with hitbox for rightward projectile steering

  loc_02C28B:
    COP [AnimOneFrame]    ; Per-frame animation, collision detection, and D-pad steering loop
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue] ; COP re-entry for per-frame steering — checks button state each frame
    LDA $2A
    BEQ loc_02C28B
    COP [BranchIfNoButton] ( #$0100, &code_02C24E ) ; Right button released → return to neutral direction dispatch (code_02C24E)
    JSR $&RecomputeProjectilePos ; Recompute projectile world position from player + stored offset
    DEC $24
    BMI loc_02C28B
    RTL 
}

ProjectileMoveLeft {
    COP [StageSprAndHitbox] ( #3C ) ; Left: stage directional sprite #3C with hitbox for leftward steering

  loc_02C2AB:
    COP [AnimOneFrame]    ; Per-frame animation, collision, and D-pad steering loop
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $2A
    BEQ loc_02C2AB
    COP [BranchIfNoButton] ( #$0200, &code_02C24E ) ; Left button released → return to neutral direction dispatch
    JSR $&RecomputeProjectilePos
    DEC $24
    BMI loc_02C2AB
    RTL 
}

ProjectileMoveUp {
    COP [StageSprAndHitbox] ( #3B ) ; Up: stage directional sprite #3B with hitbox for upward steering

  loc_02C2CB:
    COP [AnimOneFrame]    ; Per-frame animation, collision, and D-pad steering loop
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $2A
    BEQ loc_02C2CB
    COP [BranchIfNoButton] ( #$0800, &code_02C24E ) ; Up button released → return to neutral direction dispatch
    JSR $&RecomputeProjectilePos
    DEC $24
    BMI loc_02C2CB
    RTL 
}

ProjectileMoveDown {
    COP [StageSprAndHitbox] ( #3A ) ; Down: stage directional sprite #3A with hitbox for downward steering

  loc_02C2EB:
    COP [AnimOneFrame]    ; Per-frame animation, collision, and D-pad steering loop
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $2A
    BEQ loc_02C2EB
    COP [BranchIfNoButton] ( #$0400, &code_02C24E ) ; Down button released → return to neutral direction dispatch
    JSR $&RecomputeProjectilePos
    DEC $24
    BMI loc_02C2EB
    RTL 
}

WillAttackPaletteFX {
    COP [PaletteStartLoop] ( #2A, #02 ) ; Will palette FX: cycle palette #2A (2 iterations), then loop on #2B until killed
    COP [PaletteStepLoop]

  loc_02C30E:
    COP [PaletteStart] ( #2B )
    COP [PaletteStep]
    BRA loc_02C30E
}

FreedanAttackPaletteFX {
    COP [PaletteStartLoop] ( #4B, #02 ) ; Freedan palette FX: cycle palette #4B (2 iterations), then loop on #2C until killed
    COP [PaletteStepLoop]

  loc_02C31B:
    COP [PaletteStart] ( #2C )
    COP [PaletteStep]
    BRA loc_02C31B
}

AuraBarrierPaletteFX {
    COP [PaletteStart] ( #5B ) ; Aura Barrier palette FX: infinite loop on palette #5B until actor killed
    COP [PaletteStep]
    BRA AuraBarrierPaletteFX
}

RecomputeProjectilePos {
    LDA $7F100C, X        ; Recompute projectile world position = player position + stored XY offsets
    CLC 
    ADC $playerXPos
    STA $14
    LDA $7F100E, X
    CLC 
    ADC $playerYPos
    STA $16
    RTS 
}

LoadAbilityAnimTableA {
    PHX                   ; Index into table_01D9A7 by A (doubled for word entries) — Will ability animation config
    ASL 
    TAX 
    LDA $@ability_anim_tables.will_ability_anim_table, X
    SEC 
    SBC #$&ability_anim_tables.will_ability_anim_table
    TAX 
    LDA $@ability_anim_tables.will_ability_anim_table+2, X
    TAY 
    LDA $0000, Y
    PHA 
    TXA 
    CLC 
    ADC $01, S
    TAX 
    PLA 
    LDA $@ability_anim_tables.will_ability_anim_table+4, X
    AND #$00FF
    STA $climbStateData   ; Store configuration byte in climbStateData ($09E0) for engine sprite system
    PLX 
    RTS 
}

LoadAbilityAnimTableB {
    PHX                   ; Index into table_01D9BF by A — Freedan ability animation config
    ASL 
    TAX 
    LDA $@ability_anim_tables.freedan_ability_anim_table, X
    SEC 
    SBC #$&ability_anim_tables.freedan_ability_anim_table
    TAX 
    LDA $@ability_anim_tables.freedan_ability_anim_table+2, X
    TAY 
    LDA $0000, Y
    PHA 
    TXA 
    CLC 
    ADC $01, S
    TAX 
    PLA 
    LDA $@ability_anim_tables.freedan_ability_anim_table+4, X
    AND #$00FF
    STA $09E2
    PLX 
    RTS 
}