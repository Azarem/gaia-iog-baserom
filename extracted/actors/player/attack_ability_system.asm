; Player attack and ability companion actor system (Bank 02).
; 
; Runs as a companion actor spawned before the movement controller via SpawnBefore. Each frame, checks player state (alive, not in hurt/knockback/dialogue) and listens for the attack button. The COP mask is $0081: bit 0 only tells BranchIfPressed/BranchIfNotPressed to test joypadRaw (the physical level, which still reports a button that was consumed through joypadHeld) instead of joypadCurrent, and $0080 is the logical attack bit, physical A in this ROM (db-us/transforms.json rewrites the vanilla ROM masks of this block; the vanilla attack mask differs). Dispatches to character-specific attack flows based on characterForm ($0AD4): Will (form 0) uses WillAttackDispatch, Freedan (form 1) uses FreedanAttackDispatch. Forms 2+ return immediately and cannot attack through this code path.
; 
; Both characters share a 40-frame ($28 hex) initial button-hold detection period via COP LoopInit. If the player releases during this window, the attack cancels back to idle.
; 
; Will's attack system (WillAttackDispatch):
; - Extended charge timer: 120 frames ($0078)
; - Ability gate: abilityBitmask bit 2 ($0004) unlocks Spin Dash
; - Without bit 2: release after charge → Psycho Dash
; - With bit 2: CheckAttackChargeable gates continued charge; L/R ($0030) → Spin Dash; release → Psycho Dash
; - Psycho Dash: directional fast dash with trail afterimage actors (4 directions)
; - Spin Dash: spawns a GuidedProjectileActor the player steers with D-pad; the charge level $26 starts at $0F and four alternating L, R, L, R presses (SpinDashChargeTick) bring it below $0C, which ends the charge phase
; 
; Freedan's attack system (FreedanAttackDispatch):
; - Extended charge timer: 100 frames ($0064)
; - Additional cancel: L/R ($0030, tested in joypadCurrent) during the charge aborts to AttackCleanup; the vanilla ROM mask also listed the Y and A face bits, which the transform drops because the attack button is logical $0080 here
; - Ability gate: abilityBitmask bit 5 ($0020) unlocks Aura Barrier
; - Without bit 5: release → Dark Friar
; - With bit 5: D-pad during charge → cancel (AttackChargeReturn); L/R ($0030) → Aura Barrier; release → Dark Friar
; - Dark Friar: 4-directional energy projectile with trail, wall-bounce, redirect (upgrade level 2), and fragment burst on hit
; - Aura Barrier: requires standing still; rotating orbital projectiles with VRAM DMA, custom palette, expand/shrink lifecycle
; 
; Ability bitmask ($0AA2) gates (the bits are event flags $0510 + characterForm×4 + slot, the flags the inventory Status tab tests with TestAbilityFlag):
; - Bit 0 ($0001): Psycho Dash (Will attack gate + charge release)
; - Bit 1 ($0002): Psycho Slider (Will run attack)
; - Bit 2 ($0004): Spin Dash (Will L/R alternate ability)
; - Bit 4 ($0010): Dark Friar (Freedan attack gate + charge release)
; - Bit 5 ($0020): Aura Barrier (Freedan L/R alternate ability)
; - Bit 6 ($0040): Earthquaker (Freedan attack gate)
; 
; The system hijacks the player actor function pointer via SetPlayerActorFunc during ability execution, then restores it through AttackCleanup which kills spawned FX actors and plays form-specific palette restoration (Will=#0B, Freedan=#0C).
; 
; Helper routines: ValidateAttackReady ($3A00 flags + facing < 4), ValidateAttackContinue ($2B00 per-frame check), CheckAttackChargeable (carry clear only while playerFlags $8000 is clear and the player body animation index at +$28 is 0–3 or $10–$13), SavePlayerPosition (snapshots for offset calculations), ComputeParentOffset/ApplyParentOffset (relative position tracking for child actors), KillSpawnedProjectile (cleanup via MarkDeath).
; 
; Palette FX (bundle contents decoded from palette_bundles): WillAttackPaletteFX = #2A twice then #2B forever; FreedanAttackPaletteFX = #4B twice then #2C forever (both tint the 15 colors at CGRAM $81–$8F, which AttackCleanup restores with the single-frame bundles #0B/#0C); AuraBarrierPaletteFX = #5B forever (8 colors at CGRAM $A1–$A8, a blue-to-white ramp, 16 ticks per cycle). Dark Friar also starts bundle #4A through a thinker: a white flash on $81–$8F fading back to Freedan's normal colors over 36 ticks.
; 
; Ability tables: LoadAbilityDamageA (will_ability_damage_table, Will) and LoadAbilityDamageB (freedan_ability_damage_table, Freedan) do not hold sprite or hitbox data. Each 6-byte record is { word 0, word pointer to the ability's upgrade-level word, then one damage byte per level }; the loader reads the level from that WRAM word ($0B16 Psycho Dash, $0B18 Psycho Slider, $0B1A Spin Dash; $0B1C Dark Friar, $0B1E Aura Barrier, $0B20 Earthquaker) and stores record[4 + level] to climbStateData ($09E0, Will) or $09E2 (Freedan), the damage bonus that combat_collision adds to the hit strength. Values by level: Psycho Dash 5/10, Psycho Slider 5/8, Spin Dash 4/7; Dark Friar 5/8/12, Aura Barrier 5/9, Earthquaker 0/7.
; 
; === TRAIL FOLLOWERS (TrailFollowerSprA, 179702–179872) ===
; 
; Dark Friar fragment trail follower actors and position offset helpers. Provides two trail segment actor variants (TrailFollowerSprA sprite #05, TrailFollowerSprB sprite #06) that follow behind Dark Friar fragment projectiles to create a cascading afterimage effect. Both variants share the same loop logic — only their initial sprite/hitbox configuration differs.
; 
; The trail system works via a 3-stage position FIFO buffer stored in per-actor long-address scratch fields ($7F0000–$7F001A,X). Each frame, TrailPositionCascade shifts the parent actor's current position into stage 3 of the queue, while each older position advances one stage forward. The trail actor displays the position from stage 1 (the oldest buffered value), creating a 3-frame position delay. The position source is the actor in $04 (the previous entry of the actor list, i.e. the actor the follower was inserted after, not a stored parent id): TrailFollowerSprA is spawned last, so it sits directly behind the fragment and lags it by 3 frames, while TrailFollowerSprB (spawned first) follows A and therefore lags the fragment by about 6. TrailPositionInit seeds all 3 stages with the current position so the trail starts co-located with its parent.
; 
; ComputeParentOffset and ApplyParentOffset are also in this part — they store/apply the XY delta between current position and a parent actor, used by Dark Friar projectile and trail actors for relative positioning.
; 
; === SECTIONS (the block has no parts in blocks.json; the notes use these address ranges) ===
; 
; 178099–179701: AttackSystemEntry, both dispatch paths, all Freedan abilities (Dark Friar, Aura Barrier) and the shared helpers.
; 179702–179825: TrailFollowerSprA/B, TrailPositionCascade, TrailPositionInit.
; 179826–179871: ComputeParentOffset, ApplyParentOffset (they use the spawner slot stored in $24 by CopyActorState).
; 179872–180391: Psycho Dash and its four trail actors. 180393–180763: Spin Dash, SpinDashChargeTick. 180764–181131: KillSpawnedProjectile, GuidedProjectileActor, the palette FX actors, RecomputeProjectilePos and the two ability-table loaders.
; 
; === CONVENTIONS ===
; 
; - Actor flags $10: bit 13 ($2000) = hidden for SortActorsByDepth and the script-only path of RunActors_Normal (no collision-aware movement, no iframe handling); bit 14 ($4000) = off-screen flag maintained by the depth sort; bit 7 ($0080) = hit/iframe marker.
; - $12 bits $2000 / $4000 negate the Y / X movement of staged movement chains (so one chain runs south or north, east or west).
; - COP movement operands (StageMoveXY, StageSpriteMoveX/Y, StageSpriteLoopMoveX/Y) are indices into move_chain_table, not distances: index 1/3/5/7 = constant +1/+2/+3/+4 per frame, 2/4/6 = the negatives, index $36 = 8 frames of 0, then 4,4,7,7,9,9,12,12, then 0,0, then eight frames of −8.
; - LoopStart/LoopEnd yield once per iteration, so LoopStart(#n) is an n-frame loop.
---------------------------------------------

?BANK 02

?INCLUDE 'ability_damage_tables'
?INCLUDE 'actor_pool'
?INCLUDE 'ApplyOrbitalOffsetFromRef'
?INCLUDE 'player_character'
?INCLUDE 'spriteset_aura'
?INCLUDE 'spriteset_dark_friar'
?INCLUDE 'spriteset_pickups_effects'

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
!adhocVramDmaDest               7F0C07

---------------------------------------------

; Attack dispatcher and Freedan ability implementations (178099–179702).
; 
; This part contains the attack companion actor's main dispatch logic plus all of Freedan's abilities. Despite being named after its first piece (AttackSystemEntry), the part spans the full attack dispatcher, both character-specific dispatch paths, all helper routines, and the complete Dark Friar and Aura Barrier ability implementations.
; 
; Major sections within this part:
; 
; 1. Attack Dispatcher (178099–178432): AttackSystemEntry checks player state each frame and listens for the attack button (mask $0081, held level in joypadRaw). WillAttackDispatch handles Will's 40-frame hold + 120-frame charge with ability bitmask gating for Psycho Dash/Spin Dash. FreedanAttackDispatch handles Freedan's 40-frame hold + 100-frame charge with Dark Friar/Aura Barrier selection. LaunchPsychoDash, LaunchSpinDash, LaunchDarkFriar, and LaunchAuraBarrier validate and hijack the player actor function pointer.
; 
; 2. Attack Helpers (178433–178558): AttackCleanup kills spawned FX and restores palette. SetPlayerActorFunc overwrites the player actor's entry point. ValidateAttackReady checks $3A00 flags and facing direction. ValidateAttackContinue does per-frame $2B00 checks. SavePlayerPosition snapshots position. CheckAttackChargeable returns carry clear only while playerFlags $8000 is clear and the player body animation index is 0-3 or $10-$13.
; 
; 3. Aura Barrier (178559–178710): AuraBarrierMain sets flags, spawns VRAM DMA loader, waits for tile upload, loads FX palette, spawns orbital children, and runs the expand→orbit→shrink lifecycle. AuraBarrierEnd clears flags and returns to idle. AuraVramDmaLoader does a one-shot DMA of Aura tile graphics.
; 
; 4. Aura Orbital System (178711–179002): AuraOrbitalSpawner spawns 2-4 orbital children (count depends on upgrade flag $0B1E), manages 240-frame orbit rotation expanding from diameter 0 to 64, then runs a 30-frame shrink. UpdateOrbitalPositions iterates children with angle spacing via ApplyOrbitalOffsetFromRef. AuraProjectileChild is the individual orbiting sprite with 3-frame animation. AuraProjectileShrink reverses the animation and flags for removal.
; 
; 5. Dark Friar (179003–179701): DarkFriarMain sets flags, spawns VRAM DMA, loads palette, spawns a palette reset thinker (#4A), and dispatches by facing direction. Each directional handler (South/North/West/East) spawns a projectile and trail at character-appropriate offsets. DarkFriarProjectile is the initial flash sprite. DarkFriarTrailSouth and DarkFriarTrailEastWest are the growing trail actors with optional collision (enabled by upgrade level $0B1C). DarkFriarBounceLoop keeps the trail travelling until it leaves the screen, and at upgrade level 2 holding attack runs DarkFriarDisableCollide, which detonates it into fragments on demand. DarkFriarOnHit spawns 4 fragment actors at 90° intervals. DarkFriarFragmentInit sets up spiraling outward motion, DarkFriarFragmentLoop applies the reversed velocity every frame until the fragment leaves the screen (actor flag $4000), then it dies.

AttackSystemEntry {
    LDA $playerFlags      ; Combat lock check (one-time, at spawn): $0008 is set in non-combat scenes, where no attack companion is wanted
    BIT #$0008            ; Bit 3 ($0008) = combat lock (set at spawn by non-combat scenes, toggled by cutscenes) — not a death flag
    BEQ code_02B7BD
    COP [Die]             ; Combat lock (playerFlags $0008, set at spawn by non-combat scenes): this companion removes itself; it is not a player-death check

  code_02B7BD:
    LDA #$0001            ; Clear the attack-request bit ($0001) once on entry to this idle label; the re-entry point below is after this write, so it is not repeated every frame
    TRB $playerFlags
    COP [SetEntryHere]    ; COP re-entry point — companion actor resumes here each frame to poll for attacks
    LDA $playerFlags
    BIT #$2A00            ; Bits 9+11+13 ($2A00) = game over, script/ability lock, or guard/channel stance — blocks attacking
    BEQ loc_02B7CE
    RTL 

  loc_02B7CE:
    LDA $characterForm    ; Check character form: 0=Will, 1=Freedan; forms 2+ cannot attack through this actor
    CMP #$0002
    BCC loc_02B7D7
    RTL 

  loc_02B7D7:
    COP [BranchIfPressed] ( #$0081, &WillAttackDispatch ) ; Mask $0081 tests joypadRaw (bit 0 = raw selector): $0080 is the logical attack bit (physical A here), so a held attack button branches to WillAttackDispatch
    RTL 
}

WillAttackDispatch {
    LDA #$0001            ; Set attack-request flag ($0001) — attack button accepted, ability flow starting
    TSB $playerFlags
    LDA #$0080            ; Mark attack button as consumed in joypad held tracker to prevent re-trigger
    TSB $joypadHeld
    LDA $characterForm    ; Check character form — Will (0) continues here, Freedan (1) jumps to FreedanAttackDispatch
    BEQ loc_02B7F2
    JMP $&FreedanAttackDispatch

  loc_02B7F2:
    LDA $abilityBitmask   ; Check Will's ability bitmask for available attacks
    BIT #$0005            ; Bits 0+2 ($0005) = Psycho Dash OR Spin Dash unlocked; need at least one
    BNE loc_02B7FB
    RTL 

  loc_02B7FB:
    COP [LoopStart] ( #28 ) ; Begin 40-frame ($28 hex) button-hold detection loop — must hold to commit
    COP [BranchIfNotPressed] ( #$0081, &code_02B7BD ) ; Attack no longer held in joypadRaw during the 40-frame hold: cancel back to the idle label
    COP [LoopEnd]         ; Hold period complete — player committed to charged attack
    JSR $&SavePlayerPosition ; Snapshot player position for palette FX actor reference point
    COP [SpawnListAppend] ( @WillAttackPaletteFX, #00, #00, #$2C00 ) ; Spawn Will's charge-up palette FX actor (cycles palettes #2A → #2B)
    STY $22               ; Store spawned FX actor ID in DP $22 — AttackCleanup will kill it later
    LDA #$0078            ; Set extended charge timer to 120 frames ($0078)
    STA $24
    COP [SetEntryHere]    ; COP re-entry for per-frame charge loop
    JSR $&ValidateAttackContinue ; Per-frame abort check: game over, script lock, stance or forced walk interrupts the charge
    COP [BranchIfNotPressed] ( #$0081, &AttackCleanup ) ; Attack released (joypadRaw) during the charge: AttackCleanup, no ability fires
    DEC $24               ; Decrement charge timer each frame
    BMI loc_02B829        ; Timer expired (negative) → proceed to ability selection phase
    RTL 

  loc_02B829:
    LDA $abilityBitmask   ; Check if Spin Dash ability (bit 2, $0004) is unlocked
    BIT #$0004
    BNE loc_02B83D        ; Spin Dash unlocked → enter extended charge with L/R selection
    COP [SetEntryHere]    ; Without Spin Dash: simple hold loop — release fires Psycho Dash
    JSR $&ValidateAttackContinue
    COP [BranchIfNotPressed] ( #$0081, &LaunchPsychoDash ) ; Attack released → launch Psycho Dash (default Will charged ability)
    RTL 

  loc_02B83D:
    COP [SetEntryHere]    ; With Spin Dash: extended charge with chargeable gate check
    JSR $&ValidateAttackContinue
    COP [BranchIfNotPressed] ( #$0081, &LaunchPsychoDash ) ; Attack released → launch Psycho Dash (still the default on release)
    JSR $&CheckAttackChargeable ; Carry clear = body animation index 0–3 or $10–$13 and the sprite override (playerFlags bit 15) clear; only then may L/R launch Spin Dash
    BCC loc_02B84E        ; Carry clear: go on to the L/R test; carry set: yield and keep charging
    RTL 

  loc_02B84E:
    COP [BranchIfPressed] ( #$0030, &LaunchSpinDash ) ; L or R ($0030, joypadCurrent: level minus buttons consumed in joypadHeld) launches Spin Dash
    RTL 
}

LaunchPsychoDash {
    JSR $&ValidateAttackReady ; Validate facing direction and player state before launching Psycho Dash
    LDA #$&PsychoDashMain ; Load PsychoDashMain entry point to overwrite player actor function
    JSR $&SetPlayerActorFunc ; Hijack player actor — player now executes PsychoDashMain instead of normal movement
    JMP $&AttackCleanup
}

LaunchSpinDash {
    JSR $&ValidateAttackReady ; Validate and set up Spin Dash — same pattern as Psycho Dash launch
    LDA #$&SpinDashMain   ; Load SpinDashMain entry point for player actor hijack
    JSR $&SetPlayerActorFunc
    JMP $&AttackCleanup
}

FreedanAttackDispatch {
    LDA $abilityBitmask   ; Check Freedan's ability bitmask for available attacks
    BIT #$0050            ; Bits 4+6 ($0050) = Dark Friar OR Earthquaker unlocked
    BNE loc_02B876
    RTL 

  loc_02B876:
    COP [LoopStart] ( #28 ) ; Begin 40-frame ($28 hex) button-hold period — same duration as Will
    COP [BranchIfNotPressed] ( #$0081, &code_02B7BD ) ; Released during hold → cancel back to idle
    COP [LoopEnd]
    JSR $&SavePlayerPosition ; Snapshot player position for Freedan palette FX reference
    COP [SpawnListAppend] ( @FreedanAttackPaletteFX, #00, #00, #$2C00 ) ; Spawn Freedan's charge-up palette FX actor (cycles palettes #4B → #2C)
    STY $22               ; Store spawned FX actor ID in DP $22 for cleanup
    LDA #$0064            ; Set extended charge timer to 100 frames ($0064) — shorter than Will's 120
    STA $24
    COP [SetEntryHere]    ; COP re-entry for Freedan per-frame charge loop
    JSR $&ValidateAttackContinue
    COP [BranchIfNotPressed] ( #$0081, &AttackCleanup ) ; Attack released during charge → abort to cleanup
    COP [BranchIfPressed] ( #$0030, &AttackCleanup ) ; L or R ($0030 in this ROM, joypadCurrent) during the charge aborts to AttackCleanup; the vanilla ROM mask also listed the Y and A face bits
    DEC $24               ; Decrement Freedan charge timer each frame
    BMI loc_02B8AA
    RTL 

  loc_02B8AA:
    LDA $abilityBitmask   ; Timer expired — check if Aura Barrier (bit 5, $0020) is unlocked
    BIT #$0020
    BNE loc_02B8BE
    COP [SetEntryHere]    ; Without Aura Barrier: simple wait-for-release loop
    JSR $&ValidateAttackContinue
    COP [BranchIfNotPressed] ( #$0081, &LaunchDarkFriar ) ; Release → launch Dark Friar (only available Freedan ability)
    RTL 

  loc_02B8BE:
    COP [SetEntryHere]    ; With Aura Barrier: extended selection with D-pad guard and L/R trigger
    JSR $&ValidateAttackContinue
    COP [BranchIfNotPressed] ( #$0081, &LaunchDarkFriar ) ; Release → launch Dark Friar (still the default ability on release)
    COP [BranchIfPressed] ( #$0F00, &AttackChargeReturn ) ; D-pad ($0F00) during charge → return without action (prevents Aura trigger while moving)
    COP [BranchIfPressed] ( #$0030, &LaunchAuraBarrier ) ; L or R ($0030, joypadCurrent) launches Aura Barrier (needs the stationary check in LaunchAuraBarrier)
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
    COP [PaletteStart] ( #0B ) ; Will (form 0): bundle #0B, one frame of Will's 15 colors at CGRAM $81–$8F, undoes the tint of the charge FX actor
    COP [PaletteStep]
    COP [JumpNextFrame] ( @code_02B7BD ) ; Set entry point to idle loop and exit immediately — attack complete

  loc_02B91C:
    COP [PaletteStart] ( #0C ) ; Freedan (form 1): bundle #0C, one frame of Freedan's 15 colors at CGRAM $81–$8F, undoes the tint of the charge FX actor
    COP [PaletteStep]
    COP [JumpNextFrame] ( @code_02B7BD )
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
    BIT #$3A00            ; Bits 9+11+12+13 ($3A00) = game over, script/ability lock, on a slope, or guard/channel stance
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
    BIT #$2B00            ; Bits 8+9+11+13 ($2B00) = forced walk + game over + script/ability lock + guard/channel stance
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

---------------------------------------------
; Carry clear = the charge may continue and an L/R press may launch the alternate ability; carry set = not now.
; 
; Carry is set when playerFlags $8000 (body sprite override) is set, when the player actor animation index at +$28 is negative, or when it is neither 0–3 nor $10–$13. The Will dispatch only reads the L/R buttons while this routine returns carry clear.

CheckAttackChargeable {
    LDA $playerFlags      ; Check whether the in-progress attack can continue charging
    BIT #$8000            ; Bit 15 ($8000) = body sprite overridden via SetPlayerSpriteDirect → not chargeable
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
    LDA #$0800            ; Set bit 11 ($0800) in player flags — script/ability lock (Aura Barrier active)
    TSB $playerFlags
    COP [SpawnListAppend] ( @AuraVramDmaLoader, #00, #00, #$2600 ) ; Spawn VRAM DMA loader to upload Aura Barrier tile graphics to VRAM
    CPY #$1FC0            ; Check spawn result — $1FC0 = actor pool exhausted, spawn failed
    BNE loc_02B99B
    JMP $&AuraBarrierEnd  ; Pool exhausted → skip directly to AuraBarrierEnd

  loc_02B99B:
    LDA $16               ; $16 is the actor Y position word, not a DMA status: Y = $0020 takes the bounded wait below, any other Y waits until the adhoc DMA clears
    CMP #$0020
    BNE loc_02B9B4
    COP [SetEntryHereAndYield]
    COP [LoopStart] ( #08 )
    LDA $adhocVramDmaDest ; $7F0C07 = adhoc VRAM destination cache; $4400 means DMA still pending
    CMP #$4400
    BNE loc_02B9C0
    COP [LoopEnd]
    BRA loc_02B9C0

  loc_02B9B4:
    COP [SetEntryHere]    ; DMA still pending — yield each frame until transfer completes
    LDA $adhocVramDmaDest
    CMP #$4400
    BNE loc_02B9C0
    RTL 

  loc_02B9C0:
    COP [CopyPalette] ( @fx_palette_198090, #00, #A9, #07 ) ; Copy Aura Barrier FX palette: 7 words from offset $00 into CGRAM position $A9
    COP [SetPlayerSpriteDirect] ( #06 ) ; Set player body to Aura casting pose (sprite #06)
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [SpawnListAppend] ( @AuraBarrierPaletteFX, #00, #00, #$2400 ) ; Spawn Aura Barrier palette cycling FX actor (palette #5B infinite loop)
    TYA 
    STA $orbitDiameter, X ; Store palette FX actor ID in orbitDiameter for KillSpawnedProjectile cleanup
    COP [StageSpriteLoop] ( #03, #02 ) ; Stage Aura casting animation loop: sprite #03, 2 iterations
    COP [AnimLoop]
    LDA #$0001            ; Clear the attack-request bit $0001 so a new attack press during the orbit (tested later) can start the early shrink
    TRB $playerFlags
    COP [SpawnListAppend] ( @AuraOrbitalSpawner, #00, #F0, #$2600 ) ; Spawn the orbital child spawner at Y offset -16 (above player head)
    COP [StageSpriteLoop] ( #03, #0A ) ; Stage orbital sustain animation: sprite #03, 10 iterations
    COP [AnimLoop]
    JSR $&KillSpawnedProjectile ; Kill the palette FX actor saved in orbitDiameter now that the barrier has ended
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
    COP [SpawnAfterMarked] ( @AuraProjectileChild, #$0600 ) ; Upgraded: spawn first additional orbital child (only if upgrade flag set)
    INC $24
    COP [SpawnAfterMarked] ( @AuraProjectileChild, #$0600 )
    INC $24

  loc_02BA39:
    COP [SpawnAfterMarked] ( @AuraProjectileChild, #$0600 ) ; Spawn standard orbital child (always present regardless of upgrade)
    INC $24
    COP [SpawnAfterMarked] ( @AuraProjectileChild, #$0600 )
    LDA #$00F0            ; Set orbital lifetime to 240 frames ($00F0)
    STA $20
    COP [SetEntryHere]    ; COP re-entry for per-frame orbital management loop
    LDA $playerFlags      ; Check attack-request flag ($0001) — set means the attack button was pressed again → begin shrink
    BIT #$0001
    BNE loc_02BA7D
    LDA $26               ; Advance orbit angle by 2 units per frame (smooth rotation speed)
    CLC 
    ADC #$0002
    AND #$00FF
    STA $26
    STA $orbitAngle, X
    LDA $orbitDiameter, X ; Read current orbit diameter for expansion check
    CMP #$0040            ; Maximum orbit diameter $40: ApplyOrbitalOffsetFromRef scales sine/cosine (max $7F) by the diameter and keeps the high byte, so the radius is about 32 px, not 64
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
    COP [LoopStart] ( #1E ) ; Run 30-frame ($1E hex) shrink loop — contracts orbit back to center
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
    COP [LoopEnd]
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
    COP [SetMetasprite] ( @spriteset_aura ) ; Set metasprite table to table_179000 (Aura orbital projectile graphics)
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
    TSB $10               ; Bit 13 ($2000): hides the orbital (depth sort) and makes it script-only; the spawner's COP Die removes the children (SpawnAfterMarked)
    COP [SetEntryHere]
    RTL 
}

DarkFriarMain {
    LDA #$2000            ; Set bit 13 ($2000) in player flags — guard/channel stance (Dark Friar casting)
    TSB $playerFlags
    COP [SpawnListAppend] ( @DarkFriarVramDma, #00, #00, #$2600 ) ; Spawn VRAM DMA loader for Dark Friar tile graphics
    CPY #$1FC0            ; Check spawn result — $1FC0 = pool exhausted
    BNE loc_02BB52
    JMP $&DarkFriarFinish ; Pool exhausted → skip to DarkFriarFinish (clean exit)

  loc_02BB52:
    LDA $16               ; $16 is the actor Y position word: same bounded-wait versus indefinite-wait split as in AuraBarrierMain
    CMP #$0020
    BNE loc_02BB6B
    COP [SetEntryHereAndYield]
    COP [LoopStart] ( #08 )
    LDA $adhocVramDmaDest
    CMP #$4400
    BNE loc_02BB77
    COP [LoopEnd]
    BRA loc_02BB77

  loc_02BB6B:
    COP [SetEntryHere]
    LDA $adhocVramDmaDest
    CMP #$4400
    BNE loc_02BB77
    RTL 

  loc_02BB77:
    COP [CopyPalette] ( @fx_palette_198070, #00, #A0, #10 ) ; Copy Dark Friar FX palette: 16 words from offset $00 into CGRAM position $A0
    COP [SpawnThinkerParam] ( #4A, @actor_pool.PaletteResetAndKillThinker ) ; Thinker with bundle #4A: white flash on CGRAM $81–$8F fading to Freedan's colors in 36 ticks; runs at the cast, not at ability end
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
    COP [SpawnListAppend] ( @DarkFriarProjectile, #FE, #1A, #$2600 ) ; South: spawn projectile at (-2, +26) relative to player
    COP [SpawnListAppend] ( @DarkFriarTrailSouth, #FE, #1A, #$2600 ) ; South: spawn trail actor at same offset — follows behind projectile
    COP [StagePlayerSprite] ( #36 ) ; Play Freedan south casting animation (sprite #36)
    COP [AnimOnce]
    BRA DarkFriarFinish
}

DarkFriarNorth {
    COP [SpawnListAppend] ( @DarkFriarProjectile, #00, #C0, #$2600 ) ; North: spawn projectile at (0, -64) — above player
    COP [SpawnListAppend] ( @DarkFriarTrailNorthInit, #00, #C0, #$2600 ) ; North: spawn trail via DarkFriarTrailNorthInit (reuses south path with direction flag)
    COP [StagePlayerSprite] ( #37 )
    COP [AnimOnce]
    BRA DarkFriarFinish
}

DarkFriarWest {
    COP [SpawnListAppend] ( @DarkFriarProjectile, #CC, #EA, #$2600 ) ; West: spawn projectile at (-52, -22) — to the left
    COP [SpawnListAppend] ( @DarkFriarTrailWestInit, #CC, #EA, #$2600 ) ; West: spawn trail via DarkFriarTrailWestInit (sets horizontal movement flag)
    COP [StagePlayerSprite] ( #38 )
    COP [AnimOnce]
    BRA DarkFriarFinish
}

DarkFriarEast {
    COP [SpawnListAppend] ( @DarkFriarProjectile, #34, #EA, #$2600 ) ; East: spawn projectile at (+52, -22) — to the right
    COP [SpawnListAppend] ( @DarkFriarTrailEastWest, #34, #EA, #$2600 ) ; East: spawn trail actor directly (DarkFriarTrailEastWest — no init flag needed)
    COP [StagePlayerSprite] ( #39 ) ; Play Freedan east casting animation (sprite #39)
    COP [AnimOnce]
}

DarkFriarFinish {
    COP [WaitByte] ( #07 ) ; WaitByte #07 = 8 actor ticks for the casting animation to complete
    COP [RestoreSavedPtr] ; Restore saved return pointer — returns player actor to pre-ability state
}

DarkFriarVramDma {
    COP [AdhocVramDma] ( @misc_fx_1CC000, #$4400, #$0480 ) ; One-shot DMA: upload Dark Friar tiles ($0480 bytes from misc_fx_1CC000) to VRAM $4400
    COP [Die]
}

DarkFriarProjectile {
    COP [SetMetasprite] ( @spriteset_dark_friar ) ; Set metasprite to table_178000 (Dark Friar projectile graphics)
    JSR $&ComputeParentOffset ; Compute offset from parent — tracks relative position for trail following
    COP [WaitByte] ( #07 ) ; WaitByte #07 = 8 ticks before revealing the projectile (syncs with the casting animation)
    JSR $&ApplyParentOffset ; Apply stored offset to follow parent's movement during delay
    LDA #$2000            ; Clear bit 13 ($2000) — make projectile visible after sync delay
    TRB $10
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    COP [Die]             ; Self-destruct — visual flash actor has served its purpose
}

---------------------------------------------
; Spawn entry stub for the north Dark Friar trail: sets bit $2000 in actor $12 to negate Y movement so the shared south trail code runs upward, then falls into DarkFriarTrailSouth.

DarkFriarTrailNorthInit {
    LDA #$2000            ; Set $2000 in $12 = negate-Y: the trail then runs north (this entry is only used for the north cast)
    TSB $12
}

DarkFriarTrailSouth {
    LDA #$0000            ; Load animation table B entry 0 — Dark Friar trail sprite configuration
    JSR $&LoadAbilityDamageB
    COP [SetMetasprite] ( @spriteset_dark_friar )
    LDA $playerFlags      ; Check player flags bit 7 ($0080) for behind-wall rendering mode (never set by shipped scenes)
    BIT #$0080
    BEQ loc_02BC42
    COP [SetSpritePriority] ( #30 ) ; Behind wall: lower sprite priority (#30) to render behind foreground tiles

  loc_02BC42:
    JSR $&ComputeParentOffset ; Compute offset from parent — trail tracks the projectile position
    COP [WaitByte] ( #07 ) ; WaitByte #07 = 8 ticks (sync with the projectile reveal delay)
    JSR $&ApplyParentOffset
    LDA #$2000            ; Clear bit 13 ($2000) — make trail visible after sync delay
    TRB $10
    LDA $0B1C             ; $0B1C = Dark Friar upgrade level; nonzero enables damage-on-contact
    BEQ loc_02BC5D
    COP [OrExtraFlags] ( #$0010 ) ; Upgraded: enable damage flag ($0010) in actor flags — trail can hurt enemies
    COP [SetCollideCallback] ( &DarkFriarOnHit ) ; Set collision callback → DarkFriarOnHit (triggers fragment burst on contact)

  loc_02BC5D:
    COP [StageSpriteLoopMoveY] ( #01, #02, #01 ) ; Sprite #01, 2 passes, Y movement index 1 (+1 px per frame constant)
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #02, #03, #03 ) ; Sprite #02, 3 passes, Y movement index 3 (+2 px per frame constant)
    COP [AnimLoop]
    COP [StageSprAndHitbox] ( #03 ) ; Final trail sprite #03 with active hitbox for continued collision detection
    COP [StageMoveXY] ( #00, #05 ) ; X movement index 0 (none), Y movement index 5 (+3 px per frame constant): the trail keeps travelling
    BRA loc_02BCCA
}

DarkFriarTrailWestInit {
    LDA #$4000            ; Set $4000 in $12 = negate-X: the shared east/west trail then runs west
    TSB $12
}

DarkFriarTrailEastWest {
    LDA #$0000            ; Shared trail code for east and west directions — uses X-axis movement instead of Y
    JSR $&LoadAbilityDamageB
    COP [SetMetasprite] ( @spriteset_dark_friar )
    LDA $playerFlags      ; Check player flags bit 7 ($0080) for behind-wall rendering mode (never set by shipped scenes)
    BIT #$0080
    BEQ loc_02BC8F
    COP [SetSpritePriority] ( #30 ) ; Behind wall: lower sprite priority (#30) to render behind foreground tiles

  loc_02BC8F:
    JSR $&ComputeParentOffset ; Compute offset from parent — trail tracks projectile position
    COP [WaitByte] ( #07 ) ; WaitByte #07 = 8 ticks (sync with the projectile reveal delay)
    JSR $&ApplyParentOffset
    LDA #$2000            ; Clear bit 13 ($2000) — make trail visible after sync delay
    TRB $10
    LDA $0B1C             ; $0B1C = Dark Friar upgrade level; nonzero enables damage-on-contact
    BEQ loc_02BCAA
    COP [OrExtraFlags] ( #$0010 ) ; Upgraded: enable damage flag ($0010) in actor flags
    COP [SetCollideCallback] ( &DarkFriarOnHit ) ; Set collision callback → DarkFriarOnHit (triggers fragment burst on contact)

  loc_02BCAA:
    COP [StageSpriteLoopMoveX] ( #01, #02, #01 ) ; Sprite #01, 2 passes, X movement index 1 (+1 px per frame constant)
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #02, #03, #03 ) ; Sprite #02, 3 passes, X movement index 3 (+2 px per frame constant)
    COP [AnimLoop]
    COP [StageSprAndHitbox] ( #03 )
    COP [StageMoveXY] ( #05, #00 ) ; X movement index 5 (+3 px per frame constant), Y movement index 0 (none)
    BRA loc_02BCCA

  DarkFriarBounceLoop:
    LDA $10               ; Actor flag bit 14 ($4000) is the off-screen flag kept by the depth sort, not a wall-contact flag
    BIT #$4000
    BNE loc_02BCEC        ; Off-screen: the trail dies
    COP [ReloadMoveChains] ; No wall hit: reload force movement parameters for continued travel

  loc_02BCCA:
    COP [AnimOneFrame]    ; Animate one frame and check for collision events
    LDA $2A
    BEQ DarkFriarBounceLoop
    LDA $08               ; Hold time of the frame just staged by AnimOneFrame (copied to $26 so the loop below can run once per frame while it is held)
    STZ $08
    STA $26

  loc_02BCD6:
    LDA $0B1C             ; $0B1C = Dark Friar upgrade level: 2 = fully upgraded with player redirect
    CMP #$0002
    BNE loc_02BCE4
    COP [BranchIfPressed] ( #$0081, &DarkFriarDisableCollide ) ; Level 2 and attack held (joypadRaw): DarkFriarDisableCollide, which clears the callback and falls through into DarkFriarOnHit (detonate on demand)

  loc_02BCE4:
    COP [SetEntryHereAndYield] ; Set re-entry and yield — continue bounce/travel loop next frame
    DEC $26
    BPL loc_02BCD6
    BRA loc_02BCCA

  loc_02BCEC:
    COP [Die]
}

---------------------------------------------
; Reached from the bounce loop when the Dark Friar upgrade level is 2 and the attack button is held (joypadRaw). It clears the collide callback and then FALLS THROUGH into DarkFriarOnHit (there is no branch or return between the two blocks), so at level 2 holding attack detonates the trail into the four fragments on demand, with the callback removed so it cannot fire twice.

DarkFriarDisableCollide {
    COP [SetCollideCallback] ( #$0000 ) ; Clear the collide callback; there is no return here, execution continues into DarkFriarOnHit below
}

DarkFriarOnHit {
    COP [SpawnAfterFlags] ( @DarkFriarFragment1, #$0600 ) ; On collision: spawn 3 fragment actors plus self (4 total at 90° intervals)
    COP [SpawnAfterFlags] ( @DarkFriarFragment2, #$0600 )
    COP [SpawnAfterFlags] ( @DarkFriarFragment3, #$0600 )
    LDA #$0000            ; Self becomes fragment at 0° angle — falls through to DarkFriarFragmentInit
    BRA DarkFriarFragmentInit
}

DarkFriarFragment1 {
    LDA #$0040            ; Fragment 1 starts at angle $40 (90°; the angle byte has 256 units per turn)
    BRA DarkFriarFragmentInit
}

DarkFriarFragment2 {
    LDA #$0080            ; Fragment 2 starts at angle $80 (180°)
    BRA DarkFriarFragmentInit
}

DarkFriarFragment3 {
    LDA #$00C0            ; Fragment 3 starts at angle $C0 (270°)

  DarkFriarFragmentInit:
    STA $orbitAngle, X    ; Store initial orbit angle for this fragment's spiral expansion path
    LDA #$0000            ; Load animation table B entry 0 for fragment sprite set
    JSR $&LoadAbilityDamageB
    LDA #$0000            ; Initialize orbit diameter to 0 — fragments spiral outward from impact point
    STA $orbitDiameter, X
    LDA $14               ; Save current X position as spiral center reference (moveXAlt)
    STA $moveXAlt, X
    LDA $16
    STA $moveYAlt, X      ; Save current Y position as spiral center (moveYAlt)
    COP [SpawnAfterMarked] ( @TrailFollowerSprB, #$0600 ) ; Spawn trail follower sprite B — visual trail segment behind fragment
    COP [SpawnAfterMarked] ( @TrailFollowerSprA, #$0600 ) ; Spawn trail follower sprite A — second trail segment for longer trail
    LDA #$0001            ; Initialize X and Y movement deltas to 1 — minimal initial velocity
    STA $7F100E, X
    STA $7F100C, X
    COP [StageSprAndHitbox] ( #04 ) ; Set sprite #04 with active hitbox — fragment damages enemies on contact

  loc_02BD52:
    COP [AnimOneFrame]    ; AnimOneFrame stages the next frame without yielding; with $2A (frame counter) nonzero the frame's hold time ($08) becomes the loop count in $26
    LDA $2A
    BEQ loc_02BD52
    LDA $08
    STZ $08
    STA $26

  loc_02BD5E:
    COP [SetEntryHereAndYield] ; Per-frame spiral update: advance angle by 2, expand diameter by 4
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
    JSL $@ApplyOrbitalOffsetFromRef.ApplyOrbitalOffsetFromRef_AddToCurrent ; Compute orbital offset at current angle and diameter via ApplyOrbitalOffsetFromRef
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
    COP [SetEntryHereAndYield]

  loc_02BDD7:
    LDA $7F100C, X        ; Copy stored X velocity to moveScratch1 for engine movement application
    STA $moveScratch1, X
    LDA $7F100E, X        ; Copy stored Y velocity to moveScratch2 for engine movement
    STA $moveScratch2, X
    LDA $10               ; Actor flag bit 14 ($4000) = off-screen, not a wall hit
    BIT #$4000            ; Test the off-screen flag $4000 (actor left the screen), not a wall hit
    BNE loc_02BDF4        ; Off-screen during the return phase: the fragment dies
    DEC $26
    BPL loc_02BDD5
    BRA DarkFriarFragmentLoop

  loc_02BDF4:
    COP [Die]
}

TrailFollowerSprA {
    COP [StageSprAndHitbox] ( #05 ) ; Sprite #05 with hitbox. Spawned last, so it is inserted directly after the fragment and follows it with a 3-frame lag
    BRA loc_02BDFE        ; Jump to shared trail follower main loop
}

TrailFollowerSprB {
    COP [StageSprAndHitbox] ( #06 ) ; Sprite #06 with hitbox. Spawned first, so it ends up behind TrailFollowerSprA in the list and follows A (about 6 frames behind the fragment)

  loc_02BDFE:
    JSR $&TrailPositionInit ; Initialize 3-stage position FIFO buffer with current position

  loc_02BE01:
    COP [AnimOneFrame]    ; AnimOneFrame stages a frame without yielding; $2A nonzero then takes the hold time from $08 into $26
    LDA $2A
    BEQ loc_02BE01
    LDA $08               ; Capture frame count from $08 — determines how many cascade updates to run this cycle
    STZ $08
    STA $26

  loc_02BE0D:
    COP [SetEntryHereAndYield] ; Per-frame cascade: yield execution, then shift one position through the FIFO
    LDY $04               ; $04 = previous actor-list entry: the actor this follower was inserted after (the fragment for A, A for B)
    JSR $&TrailPositionCascade ; Cascade parent position through the 3-stage FIFO buffer
    DEC $26               ; Decrement remaining cascade updates
    BPL loc_02BE0D
    BRA loc_02BE01        ; Loop back to animation wait for next event cycle
}

---------------------------------------------
; 3-stage position FIFO cascade for the Dark Friar fragment trail followers.
; 
; Each call reads the oldest stage as the follower's displayed $14/$16, shifts the other two stages forward and samples the position of the actor in Y (the caller loads $04, the previous actor-list entry) into the newest stage. The follower therefore trails that actor by 3 calls. The X queue is animScratch, animScratch+2, animScratch2; the Y queue is moveXAlt, moveYAlt, retPtr1.

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
; Sets all three FIFO stages to the follower's own current position ($14 / $16, its spawn position), so the delayed trail starts co-located instead of at (0,0). Called once by the shared trail follower entry (loc_02BDFE) of TrailFollowerSprA and TrailFollowerSprB.

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
; This part contains all of Will's ability code plus shared helper routines. Despite being named after its first piece (ComputeParentOffset), the part spans offset helpers, the complete Psycho Dash and Spin Dash implementations, the guided projectile actor, all palette FX actors, and animation table loaders.
; 
; Major sections within this part:
; 
; 1. Offset Helpers (179826–179871): ComputeParentOffset stores the XY delta between current position and a parent actor. ApplyParentOffset adds the stored delta back to the parent's current position. Used by Dark Friar projectile/trail actors to maintain relative positioning.
; 
; 2. Psycho Dash (179872–180392): PsychoDashMain loads animation table A entry 0, disables status display, dispatches by facing. Each directional handler (South/North/West/East) spawns a trail afterimage actor, sets the movement direction via force flags, stages movement index $36 (a delta chain, not a distance), then returns to idle. The four PsychoDashTrail actors (South/North/West/East) record 8 position deltas during the dash and replay them in reverse as afterimage segments.
; 
; 3. Spin Dash (180393–180763): SpinDashMain sets $2002 flags, enters a charge loop that aborts when the actor is hit (flag bit 7, $0080), then transitions to either the charge tick phase (L/R shoulder decrement charge level) or projectile launch. On launch, spawns GuidedProjectileActor, kills it on completion, and uses an RTS-trick (PEA label-1) to chain through directional speed setup → SpinDashRelease → SpinDashLaunch. SpinDashChargeTick alternates the L/R test by the parity of the charge level. SpinDashAbort clears flags and restores state.
; 
; 4. Guided Projectile (180764–180999): KillSpawnedProjectile cleans up a stored actor reference via MarkDeath. GuidedProjectileActor stores its offset from the player, responds to D-pad input for 4-directional steering (Right=#3D, Left=#3C, Up=#3B, Down=#3A sprites), and runs a per-frame animation/collision loop.
; 
; 5. Palette FX & Utilities (181000–181131): WillAttackPaletteFX cycles palettes #2A→#2B. FreedanAttackPaletteFX cycles #4B→#2C. AuraBarrierPaletteFX loops #5B infinitely. RecomputeProjectilePos adds stored offsets to current player position. LoadAbilityDamageA reads will_ability_damage_table (Will), LoadAbilityDamageB freedan_ability_damage_table (Freedan). Both store the damage byte for the current upgrade level to climbStateData ($09E0 Will, $09E2 Freedan); see the block note.

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
    JSR $&LoadAbilityDamageA
    JSR $&player_character.FreezeCameraForAttack ; Disable status display during Psycho Dash execution (cross-file call)
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
    COP [SetPlayerSpriteDirect] ( #04 ) ; Set player body to Psycho Dash pose (sprite #04)
    COP [StageSpriteMoveY] ( #04, #36 ) ; Sprite #04, Y movement index $36 (delta chain 8×0, 4,4,7,7,9,9,12,12, 0,0, 8×−8), not ~54 px; AnimOnce ends the movement with the animation
    COP [AnimOnce]
    BRA loc_02BF03
}

PsychoDashNorth {
    COP [SpawnAfter] ( @PsychoDashTrailNorth ) ; North: spawn trail afterimage actor for northward dash path
    COP [SetMoveNegateY] ( #01 ) ; Set NE force direction — reverses Y movement for northward dash
    COP [SetPlayerSpriteDirect] ( #04 ) ; Set player body to Psycho Dash pose (sprite #04)
    COP [StageSpriteMoveY] ( #05, #36 ) ; Sprite #05, same index $36 (the SetMoveNegateY above flips it for north)
    COP [AnimOnce]
    BRA loc_02BF03
}

PsychoDashWest {
    COP [SpawnAfter] ( @PsychoDashTrailWest ) ; West: spawn trail afterimage actor for westward dash path
    COP [SetMoveNegateXY] ( #01 ) ; Set both force directions — reverses X movement for westward dash
    COP [SetPlayerSpriteDirect] ( #04 ) ; Set player body to Psycho Dash pose (sprite #04)
    COP [StageSpriteMoveX] ( #06, #36 ) ; Sprite #06, same index $36 on X (SetMoveNegateXY above flips it for west)
    COP [AnimOnce]
    BRA loc_02BF03
}

PsychoDashEast {
    COP [SpawnAfter] ( @PsychoDashTrailEast ) ; East: spawn trail afterimage actor for eastward dash path
    COP [SetPlayerSpriteDirect] ( #04 ) ; Set player body to Psycho Dash pose (sprite #04)
    COP [StageSpriteMoveX] ( #07, #36 ) ; Sprite #07, same index $36 on X
    COP [AnimOnce]

  loc_02BF03:
    JSR $&player_character.UnfreezeCameraAfterAttack ; Restore status display after Psycho Dash completes
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
    COP [SetEntryHereAndYield] ; Yield — recording begins on the next frame
    COP [LoopStart] ( #08 ) ; Recording loop: 8 iterations, capture one Y-position delta per frame
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
    COP [LoopEnd]         ; Recording complete — switch to playback mode
    LDA #$0003            ; Playback speed = 3 frames per segment (slower than recording for afterimage effect)
    STA $08
    LDY $04
    LDA #$0000
    STA $002E, Y          ; Zero parent Y movement scratch — trail actor takes over movement control
    COP [SetEntryHereAndYield] ; Yield — playback begins on the next frame
    DEC $16               ; Rewind buffer pointer — deltas played back in reverse order
    DEC $16
    COP [LoopStart] ( #08 ) ; Playback loop: 8 iterations, replay one stored delta per frame
    LDY $16
    DEC $16
    DEC $16
    PHX 
    LDX $04
    LDA $0000, Y
    STA $moveScratch2, X  ; Apply delta to parent moveScratch2 — afterimage reproduces dash movement in reverse
    PLX 
    COP [LoopEnd]
    COP [SetEntryHereAndYield] ; Final cleanup: set re-entry for zero-movement frame
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
    COP [SetEntryHereAndYield] ; Yield — recording begins on the next frame
    COP [LoopStart] ( #08 ) ; Recording loop: 8 iterations, capture one Y-position delta per frame
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
    COP [LoopEnd]         ; Recording complete — switch to playback mode
    LDA #$0003            ; Playback speed = 3 frames per segment
    STA $08
    LDY $04
    LDA #$0000
    STA $002E, Y          ; Zero parent Y movement scratch for afterimage takeover
    COP [SetEntryHereAndYield] ; Yield — playback begins on next frame
    DEC $16
    DEC $16
    COP [LoopStart] ( #08 )
    LDY $16
    DEC $16
    DEC $16
    PHX 
    LDX $04
    LDA $0000, Y
    STA $moveScratch2, X  ; Apply stored delta to parent moveScratch2 — north afterimage movement
    PLX 
    COP [LoopEnd]
    COP [SetEntryHereAndYield] ; Final cleanup: zero residual movement
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
    COP [SetEntryHereAndYield] ; Yield — recording begins on the next frame
    COP [LoopStart] ( #08 ) ; Recording loop: 8 iterations, capture one X-position delta per frame
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
    COP [LoopEnd]         ; Recording complete — switch to playback mode
    LDA #$0003
    STA $08
    LDY $04
    LDA #$0000
    STA $002C, Y          ; Zero parent X movement scratch for afterimage takeover
    COP [SetEntryHereAndYield] ; Yield — playback begins on the next frame
    DEC $16
    DEC $16
    COP [LoopStart] ( #08 )
    LDY $16
    DEC $16
    DEC $16
    PHX 
    LDX $04
    LDA $0000, Y
    STA $moveScratch1, X  ; Apply stored delta to parent moveScratch1 — horizontal afterimage movement
    PLX 
    COP [LoopEnd]
    COP [SetEntryHereAndYield] ; Final cleanup: zero residual X movement
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
    COP [SetEntryHereAndYield] ; Yield — recording begins on the next frame
    COP [LoopStart] ( #08 ) ; Recording loop: 8 iterations, capture one X-position delta per frame
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
    COP [LoopEnd]         ; Recording complete — switch to playback mode
    LDA #$0003
    STA $08
    LDY $04
    LDA #$0000
    STA $002C, Y          ; Zero parent X movement scratch for afterimage takeover
    COP [SetEntryHereAndYield] ; Yield — playback begins on the next frame
    DEC $16
    DEC $16
    COP [LoopStart] ( #08 )
    LDY $16
    DEC $16
    DEC $16
    PHX 
    LDX $04
    LDA $0000, Y
    STA $moveScratch1, X  ; Apply stored delta to parent moveScratch1 — east afterimage movement
    PLX 
    COP [LoopEnd]
    COP [SetEntryHereAndYield] ; Final cleanup: zero residual X movement
    PHX 
    LDX $04
    LDA #$0000
    STA $moveScratch1, X
    PLX 
    COP [Die]             ; Self-destruct — east trail lifecycle complete

  SpinDashMain:
    LDA #$0080            ; Mark attack button as consumed in joypad held tracker
    TSB $joypadHeld
    LDA #$2002            ; Set bits 1+13 ($2002) in player flags — body slam/charge attack active ($0002) + guard/channel stance ($2000)
    TSB $playerFlags
    LDA #$000F            ; Initialize charge parameter $26 to $000F — controls Spin Dash charge intensity
    STA $26
    STA $orbitAngle, X    ; Store charge parameter in orbitAngle,X for per-frame access
    COP [SetPlayerSpriteDirect] ( #04 ) ; Set player body to attack pose (sprite #04)
    COP [StageSprAndHitbox] ( #22 ) ; Set sprite #22 with active hitbox — Spin Dash contact damage during charge
    LDA #$0000
    STA $7F102E, X

  loc_02C0CB:
    COP [SetEntryHere]    ; Charge animation loop: AnimOneFrame never yields; $2A nonzero means a frame was staged; this loop is exited by a hit (bit 7) or by the charge reaching its end
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_02C0CB
    STZ $08
    LDA $10               ; Actor flag bit 7 ($0080) is the hit/iframe marker (actor_execution manages the iframe counter from it), not a wall flag
    BIT #$0080
    BEQ loc_02C0DF
    JMP $&SpinDashAbort   ; Wall hit → abort Spin Dash entirely

  loc_02C0DF:
    LDA $26               ; $26 is the charge level: $0F at the start, never negative in this code; below $0C ends the charge phase
    BMI loc_02C0FB
    CMP #$000C
    BCC loc_02C0FB
    LSR 
    STA $24
    COP [SetEntryHere]    ; Re-entry for button-hold monitoring during charge tick phase
    COP [BranchIfNotPressed] ( #$0081, &SpinDashAbort ) ; Attack released (joypadRaw) during the charge ticks: abort
    JSR $&SpinDashChargeTick ; One tick: a fresh L or R press (alternating by the parity of $26) lowers the charge level
    DEC $24
    BMI loc_02C0CB
    RTL 

  loc_02C0FB:
    LDA #$0002            ; Charge complete or minimum reached — transition to projectile launch phase
    JSR $&LoadAbilityDamageA
    LDA #$0100            ; Clear bit 8 ($0100) from actor flags — end charge visual state
    TRB $10
    LDA #$0200            ; Set bit 9 ($0200) — guided projectile active state marker
    TSB $10
    COP [SpawnListAppend] ( @GuidedProjectileActor, #00, #00, #$0302 ) ; Spawn GuidedProjectileActor at player position with special flags $0302
    TYA                   ; Store projectile actor ID in orbitDiameter for later cleanup
    STA $orbitDiameter, X
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #1D, #04 )
    COP [AnimLoop]
    JSR $&KillSpawnedProjectile ; Kill spawned projectile when charge phase completes
    PEA $&SpinDashRelease-1 ; RTS trick: push SpinDashRelease-1 onto stack — RTS will jump there
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

SpinDashRelease {
    LDA #$2800            ; Clear $2800 from playerFlags: bit 13 was set by SpinDashMain, bit 11 was not (harmless)
    TRB $playerFlags
    PEA $&SpinDashLaunch-1
    LDA #$&SpinDashLaunchLoop
    STA $retPtr2, X
    LDA $0B1A             ; $0B1A = Spin Dash upgrade level: level 0 gives 12 passes of frame #1D, an upgraded Spin Dash 24
    BNE loc_02C195
    LDA #$000C
    RTS 

  loc_02C195:
    LDA #$0018
    RTS 
}

SpinDashLaunch {
    STA $loopCounter, X   ; A (12 or 24) is the pass count for the LoopEnd below; retPtr2 was set to SpinDashLaunchLoop
    LDA #$0001            ; Load animation table A entry 1 for Spin Dash launch sprite set
    JSR $&LoadAbilityDamageA

  SpinDashLaunchLoop:
    COP [StageSpriteFrame] ( #1D ) ; Launch animation re-entry point — stored in retPtr2 for COP loop
    COP [AnimOnce]
    COP [LoopEnd]
    LDA #$0002            ; Clear bit 1 ($0002) from player flags — end Spin Dash charge state
    TRB $playerFlags
    COP [BranchIfPressed] ( #$0300, &SpinDashDirEW ) ; Check D-pad left/right ($0300) for horizontal launch direction
    COP [BranchIfPressed] ( #$0C00, &SpinDashDirNS ) ; Check D-pad up/down ($0C00) for vertical launch direction
    BRA SpinDashAbort     ; No direction held → abort Spin Dash (no launch without directional input)
}

SpinDashDirEW {
    LDA $joypadCurrent    ; Check left button ($0200) to determine east vs west sprite
    BIT #$0200
    BNE loc_02C1CB
    COP [StagePlayerSprite] ( #03 )
    BRA loc_02C1E0

  loc_02C1CB:
    COP [StagePlayerSprite] ( #02 )
    BRA loc_02C1E0
}

SpinDashDirNS {
    LDA $joypadCurrent    ; Check up button ($0800) to determine north vs south launch sprite
    BIT #$0800
    BNE loc_02C1DD
    COP [StagePlayerSprite] ( #00 ) ; South: set player sprite #00 for downward Spin Dash launch
    BRA loc_02C1E0

  loc_02C1DD:
    COP [StagePlayerSprite] ( #01 ) ; North: set player sprite #01 for upward Spin Dash launch

  loc_02C1E0:
    COP [AnimOneFrame]    ; Animate one frame of directional launch, then clear frame counter
    STZ $08
}

SpinDashAbort {
    LDA #$0200            ; Clear bit 9 ($0200) — end guided projectile state
    TRB $10
    COP [RestoreSavedPtr]
}

---------------------------------------------
; One tick of the Spin Dash charge. $26 is the charge level (it starts at $0F). When $26 is odd the L button ($0020) must be newly pressed to decrement it, when even the R button ($0010). The routine then adds the L/R bits that are pressed to joypadHeld, which consumes them: joypadCurrent no longer reports a held shoulder button, so every decrement needs a fresh press. Starting at $0F the sequence L, R, L, R reaches $0B; once $26 is below $0C SpinDashMain leaves the charge phase and spawns the guided projectile.

SpinDashChargeTick {
    LDA $26               ; Charge level $26: odd needs L, even needs R; each correct fresh press lowers it by one
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
    LDA $joypadCurrent    ; Consume the L/R bits just seen in joypadHeld, so the next decrement needs a new press
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
    COP [SetMetasprite] ( @spriteset_pickups_effects ) ; Set metasprite to table_0EE000 — Spin Dash projectile graphics

  code_02C24E:
    COP [BranchIfPressed] ( #$0100, &ProjectileMoveRight ) ; D-pad direction dispatch: right=$0100, left=$0200, up=$0800, down=$0400
    COP [BranchIfPressed] ( #$0200, &ProjectileMoveLeft )
    COP [BranchIfPressed] ( #$0800, &ProjectileMoveUp )
    COP [BranchIfPressed] ( #$0400, &ProjectileMoveDown )
    COP [SetEntryHere]    ; No direction → neutral float with sprite #39 (idle projectile pose)
    COP [StageSprAndHitbox] ( #39 )

  loc_02C26B:
    COP [AnimOneFrame]    ; Per-frame: animate one frame, check collisions, track D-pad for steering
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryHere]
    LDA $2A
    BEQ loc_02C26B
    COP [BranchIfPressed] ( #$0F00, &code_02C24E )
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
    COP [SetEntryHere]    ; COP re-entry for per-frame steering — checks button state each frame
    LDA $2A
    BEQ loc_02C28B
    COP [BranchIfNotPressed] ( #$0100, &code_02C24E ) ; Right button released → return to neutral direction dispatch (code_02C24E)
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
    COP [SetEntryHere]
    LDA $2A
    BEQ loc_02C2AB
    COP [BranchIfNotPressed] ( #$0200, &code_02C24E ) ; Left button released → return to neutral direction dispatch
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
    COP [SetEntryHere]
    LDA $2A
    BEQ loc_02C2CB
    COP [BranchIfNotPressed] ( #$0800, &code_02C24E ) ; Up button released → return to neutral direction dispatch
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
    COP [SetEntryHere]
    LDA $2A
    BEQ loc_02C2EB
    COP [BranchIfNotPressed] ( #$0400, &code_02C24E ) ; Down button released → return to neutral direction dispatch
    JSR $&RecomputeProjectilePos
    DEC $24
    BMI loc_02C2EB
    RTL 
}

---------------------------------------------
; Will charge-up tint. Bundle #2A is 14 one-frame strips of 15 colors at CGRAM $81–$8F (sprite palette 0, colors 1–15) with holds 0,2,3,4,5,6,7,6,5,4,3,2,1,0, i.e. 62 ticks per pass; PaletteStartLoop/PaletteStepLoop play it twice. Bundle #2B holds the same 14 color sets with no holds (14 ticks per pass) and is repeated until AttackCleanup kills the actor.

WillAttackPaletteFX {
    COP [PaletteStartLoop] ( #2A, #02 ) ; Bundle #2A twice (62 ticks per pass), then #2B forever (14 ticks per pass); see the part note
    COP [PaletteStepLoop]

  loc_02C30E:
    COP [PaletteStart] ( #2B )
    COP [PaletteStep]
    BRA loc_02C30E
}

---------------------------------------------
; Freedan charge-up tint. Bundle #4B is 14 one-frame strips on the same 15 colors with holds 0,1,2,3,4,5,6,5,4,3,2,1,0,0 (50 ticks per pass), played twice; bundle #2C (holds mostly 0, 16 ticks per pass) repeats until the actor is killed.

FreedanAttackPaletteFX {
    COP [PaletteStartLoop] ( #4B, #02 ) ; Bundle #4B twice (50 ticks per pass), then #2C forever (16 ticks per pass); see the part note
    COP [PaletteStepLoop]

  loc_02C31B:
    COP [PaletteStart] ( #2C )
    COP [PaletteStep]
    BRA loc_02C31B
}

AuraBarrierPaletteFX {
    COP [PaletteStart] ( #5B ) ; Bundle #5B: 8 strips of 8 colors at CGRAM $A1–$A8 (a blue-to-white ramp), hold 1 (16 ticks per cycle), repeated until the actor is killed
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

LoadAbilityDamageA {
    PHX                   ; A = ability index; the record points to the ability level word ($0B16/$0B18/$0B1A) and carries one damage byte per level
    ASL 
    TAX 
    LDA $@ability_damage_tables.will_ability_damage_table, X
    SEC 
    SBC #$&ability_damage_tables.will_ability_damage_table
    TAX 
    LDA $@ability_damage_tables.will_ability_damage_table+2, X
    TAY 
    LDA $0000, Y
    PHA 
    TXA 
    CLC 
    ADC $01, S
    TAX 
    PLA 
    LDA $@ability_damage_tables.will_ability_damage_table+4, X
    AND #$00FF
    STA $climbStateData   ; climbStateData ($09E0) = Will ability damage bonus for the current level (Psycho Dash 5/10, Slider 5/8, Spin Dash 4/7)
    PLX 
    RTS 
}

LoadAbilityDamageB {
    PHX                   ; A = ability index; the record points to the level word ($0B1C/$0B1E/$0B20) and carries one damage byte per level
    ASL 
    TAX 
    LDA $@ability_damage_tables.freedan_ability_damage_table, X
    SEC 
    SBC #$&ability_damage_tables.freedan_ability_damage_table
    TAX 
    LDA $@ability_damage_tables.freedan_ability_damage_table+2, X
    TAY 
    LDA $0000, Y
    PHA 
    TXA 
    CLC 
    ADC $01, S
    TAX 
    PLA 
    LDA $@ability_damage_tables.freedan_ability_damage_table+4, X
    AND #$00FF
    STA $climbStateData+2 ; $09E2 = Freedan ability damage bonus for the current level (Dark Friar 5/8/12, Aura Barrier 5/9, Earthquaker 0/7)
    PLX 
    RTS 
}