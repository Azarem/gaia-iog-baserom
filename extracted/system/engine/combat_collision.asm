; Combat and interaction collision system (244613–247295, Bank 03).
; 
; Implements all actor-vs-actor collision detection and damage processing. Called from the main game loop after actor AI execution and sprite composition. Contains two independent collision pipelines (combat and interaction), plus shared helpers for knockback, damage formatting, and death handling.
; 
; === COLLISION PIPELINE OVERVIEW ===
; 
; The system uses the actor render list ($0C00, word-sized entries) as its iteration source — only actors in the render list are candidates for collision. This means off-screen actors are never tested.
; 
; 1. RunCombatCollision (244708): Outer entry point. Checks player's orb flag ($0040 in $10) — if set, no combat occurs. Otherwise iterates the render list in CombatCollision_EnemyLoop.
; 
; 2. RunInteractionCollision (246366): Separate entry for NPC/object interactions. Tests player bounding box (±4px X, −4/−14px Y from position) against interaction hitboxes. Checks $2040 (COP mode + orb) to skip, and $0280 to route to FriendlyMode.
; 
; === COMBAT COLLISION (244729–245081) ===
; 
; Two-phase collision detection:
; 
; Phase 1 (outer loop): For each enemy in the render list, checks if the player is attacking ($0080 in enemy $10 = hittable AND $0040 = not orb-protected AND $0010 in $12 = not damage-immune). If eligible, calls PlayerAttackHitTest.
; 
; Phase 2 (inner loop at code_03BCBC): After player attack processing, checks all actors against the current enemy's hitbox for enemy-hits-player collision. Uses AABB overlap testing on hitbox fields ($20–$23). Two paths based on $20 flag: normal ($76E0 exclusion mask) or friendly ($74E0 mask + extendedFlags $0010 check).
; 
; === HITBOX FORMAT ===
; 
; Hitboxes are stored in the metasprite header at $0004–$0007 as signed 8-bit offsets:
; - $0004: X offset from actor position (sign-extended via $0080 check)
; - $0005: X width (added to offset for right edge)
; - $0006: Y offset (sign-extended)
; - $0007: Y height (added to offset for bottom edge)
; 
; The ASL ASL on $000E,X extracts the H-mirror flag from the actor's sprite field, which flips the hitbox X coordinates (BCS path negates offsets).
; 
; === DAMAGE FORMULAS ===
; 
; Player attacks enemy (PlayerAttackHitTest):
;   damage = chainDamage/2 + 1
;   enemyHP = max(0, enemyHP − damage)
;   chainDamage stored at $7F101E,X accumulates across consecutive hits
; 
; Enemy attacks player (EnemyHitPlayerHandler):
;   totalStr = playerStr + previousDamage($09E2) + climbStateData
;   rawDamage = max(1, enemyAtk − totalStr)
;   damage = rawDamage + chainDamage($08)
;   enemyHP = max(0, enemyHP − damage)
; 
; === DEATH HANDLING ===
; 
; When HP reaches 0: sets $0040 (death flag) in $10. If onDeathCallback ($7F1004,X) exists, uses it. Otherwise dispatches to StandardEnemyDefeatHandler and sets $0400 (standard defeat flag).
; 
; === IFRAME ASSIGNMENT ===
; 
; After damage: checks $12 bit 0 ($0001). If set, assigns negative iframe counter $FFEF (recovery/stagger phase). If clear, assigns positive counter $0011 (17 frames of invincibility). Plays hit sound #05.
; 
; === KNOCKBACK ===
; 
; CalcKnockbackDirection (246082): Computes the midpoint of the attacker's hitbox, compares against the target's center position, and returns a cardinal direction (0=S, 1=N, 2=W, 3=E) based on which axis has the greater delta. Falls back to GetPlayerFacing if the attacker is the player.
; 
; CalcKnockbackFromActorCenters (247076): Similar but uses raw actor centers (position ± 4px) instead of hitbox midpoints. Used by ApplyInteractionDamage.
; 
; === INTERACTION COLLISION (246366–246996) ===
; 
; Two modes:
; - Normal mode: Tests actors without $35C0 flags against player bbox. On hit, checks extendedFlags $0010 (collision callback). If callback exists, overwrites actor entry point. Otherwise defaults to smooth_follow_child.loc_00E4FA.
; - Friendly mode ($0280): Only tests actors with $0020 flag (friendly/NPC). Simplified hitbox test (no H-mirror).
; 
; ApplyInteractionDamage (246752): For combat actors ($0020 clear), calculates damage = max(1, enemyAtk − playerDef), subtracts from playerHp, spawns HitStaggerMain with knockback. For NPCs ($0020 set), routes to InteractionDamage_NPCChat.
; 
; === NPC CHAT (246997) ===
; 
; InteractionDamage_NPCChat: Attempts GiveItemToPlayer with chatPtr. On inventory full, shows overflow message. Otherwise shows dialogue and converts the actor to NullActorScriptStub (sets $0700 in flags to prevent re-interaction).
; 
; === DAMAGE DISPLAY ===
; 
; FormatDamageDigits (247183): Converts a 16-bit damage number to packed BCD format for sprite-based display. Handles values up to 999 (returns carry set for ≥1000). Digits packed as: high byte = hundreds, bits 7-4 of low byte = tens, bits 3-0 = ones. SpawnAttackTrailEffect actors display the formatted digits as floating damage numbers.
---------------------------------------------

?BANK 03

?INCLUDE 'dialogue_display'
?INCLUDE 'game_over_sequence'
?INCLUDE 'GetPlayerFacingDirection'
?INCLUDE 'hit_stagger_controller'
?INCLUDE 'hud_inventory'
?INCLUDE 'itemget_table_01FD24'
?INCLUDE 'NullActorScriptStub'
?INCLUDE 'player_transition_handlers'
?INCLUDE 'smooth_follow_child'
?INCLUDE 'SpawnAttackTrailEffect'
?INCLUDE 'StandardEnemyDefeatHandler'
?INCLUDE 'StopPlayerOnDeathAssign'

!extVelocityX                   0408
!extVelocityY                   040A
!joypadCurrent                  0656
!joypadMaskStd                  065A
!playerActor                    09AA
!playerFlags                    09AE
!climbStateData                 09E0
!enemyHpDisplay                 09E4
!enemyHpPending                 09EA
!playerHp                       0ACE
!characterForm                  0AD4
!playerDef                      0ADC
!playerStr                      0ADE
!chatPtr                        7F000A
!metaspritePtr                  7F000C
!statsPtr                       7F0020
!currentHp                      7F0026
!iframeCounter                  7F0028
!extendedFlags                  7F002A
!onHitCallback                  7F1000
!onDodgeCallback                7F1002
!onDeathCallback                7F1004
!onCollideCallback              7F1008
!scratch1010                    7F1010
!chainDamage                    7F101E

---------------------------------------------

; Trigger dodge callbacks when the B button is pressed.
; 
; Iterates the actor render list ($0C00). For each actor without exclusion flags ($D460 = death|orb|COP|overlay|pause bits), checks if onDodgeCallback ($7F1002,X) is set. If so, overwrites the actor's entry point ($0000,X) with the callback address and clears the callback to prevent re-trigger.
; 
; This allows actors to react to the player's dodge/attack button press — used by interactive objects and enemy dodge behaviors.

ProcessDodgeCallbacks {
    PHP                   ; Save processor status — restored at PLP before RTL exit
    REP #$20              ; 16-bit accumulator for joypad and actor data access
    LDA $joypadCurrent    ; Load current joypad button state from $0656
    BIT #$8000            ; Bit 15 ($8000) = B button (attack/dodge input)
    BEQ loc_03BBB2        ; B button not pressed → skip dodge callback processing entirely
    LDY #$0000            ; Start at render list index 0 for actor iteration

  loc_03BB93:
    LDX $0C00, Y          ; Load actor slot pointer from render list entry $0C00,Y
    BEQ loc_03BBB2        ; Null pointer = end of render list → exit
    INY                   ; Advance render list index by 2 (word-sized entries)
    INY 
    LDA $0010, X          ; Load actor primary flags ($10) for eligibility check
    BIT #$D460            ; Mask $D460 = death|orb|COP|overlay|pause — any set means skip
    BNE loc_03BB93        ; Actor has exclusion flags → try next actor in list
    LDA $onDodgeCallback, X ; Load onDodgeCallback ($7F1002,X) — custom dodge response handler
    BEQ loc_03BB93        ; No callback registered → skip to next actor
    STA $0000, X          ; Overwrite actor entry point ($0000,X) with dodge callback address
    LDA #$0000            ; Clear the dodge callback to prevent re-triggering next frame
    STA $onDodgeCallback, X ; Write zero to onDodgeCallback ($7F1002,X)

  loc_03BBB2:
    PLP                   ; Restore processor flags and return from dodge processing
    RTL 
}

---------------------------------------------
; Check if the player has died and trigger game over sequence.
; 
; Guards: returns immediately if playerFlags bit 5 ($0020) is set (death already processing) or bit 9 ($0200) is set (game over sequence active). If playerHp ($0ACE) is zero and neither guard is set, sets $0200 in playerFlags, overwrites the player actor's entry point to GameOverSequence, and calls StopPlayerOnDeathAssign to halt all movement.

CheckPlayerDeath {
    PHP                   ; Save processor flags for clean return
    REP #$20              ; 16-bit accumulator for flag word and HP access
    LDA $playerFlags      ; Load playerFlags from $09AE for death state checks
    BIT #$0020            ; Bit 5 ($0020) = death sequence already in progress
    BNE loc_03BBE2        ; Already dying → skip (prevents double game-over trigger)
    BIT #$0200            ; Bit 9 ($0200) = game over sequence already active
    BNE loc_03BBE2        ; Game over active → skip
    LDA $playerHp         ; Load player HP from $0ACE
    BNE loc_03BBE2        ; HP nonzero → player is alive, skip death processing
    LDA #$0200            ; HP is zero — set game over flag $0200 in playerFlags
    TSB $playerFlags      ; TSB sets bit 9 ($0200) in playerFlags to mark game over
    LDY $playerActor      ; Load player actor slot address from $09AA
    LDA #$&game_over_sequence.GameOverSequence ; Load GameOverSequence entry point address (same-bank)
    STA $0000, Y          ; Overwrite player actor script address ($0000,Y)
    LDA #$*game_over_sequence.GameOverSequence ; Load GameOverSequence bank byte as 16-bit immediate
    STA $0002, Y          ; Overwrite player actor bank byte ($0002,Y)
    JSL $@StopPlayerOnDeathAssign ; JSL StopPlayerOnDeathAssign — halt player movement and animations

  loc_03BBE2:
    PLP                   ; Restore processor flags and return
    RTL 
}

---------------------------------------------
; Entry point for the per-frame combat collision system.
; 
; Saves processor state and data bank. Zeroes enemyHpPending ($09EA) to clear any stale HP display request. Loads the player actor slot from $09AA and checks bit 6 ($0040) of the player's flags — if set (orb/special state), jumps directly to CombatCollision_Exit (no combat during orb). Otherwise falls through to CombatCollision_EnemyLoop.

RunCombatCollision {
    PHP                   ; Save processor flags — restored at CombatCollision_Exit
    PHB                   ; Save data bank — will be switched per-actor during collision tests
    REP #$20              ; 16-bit accumulator for all collision math
    STZ $enemyHpPending   ; Zero enemyHpPending ($09EA) — clear stale HUD HP display request
    LDX $playerActor      ; Load player actor slot from $09AA into X for indexed access
    LDA $0010, X          ; Load player primary flags ($0010,X)
    BIT #$0040            ; Bit 6 ($0040) = orb/special state — disables all combat collision
    BEQ loc_03BC1B        ; Orb flag clear → proceed to normal combat processing
    JMP $&CombatCollision_Exit ; Player has orb — skip all combat, jump to exit
}

---------------------------------------------
; Main combat collision iteration loop — tests player attacks and enemy contact.
; 
; Two-phase collision detection per enemy:
; 
; Phase 1 (player attack test): For each actor Y in the render list, checks eligibility: bit 7 ($0080) of $10 set (hittable), bit 6 ($0040) clear (not orb), and $12 bit 4 ($0010) clear (not damage-immune). If eligible and the enemy's iframe counter is non-negative, calls PlayerAttackHitTest.
; 
; Phase 2 (enemy-hits-player test): After phase 1, constructs the current enemy's AABB from metasprite hitbox fields ($0004–$0007), accounting for H-mirror via the carry flag from ASL on $000E. Then iterates the render list again (inner loop at code_03BCBC), testing each actor's hitbox ($0020–$0023) for AABB overlap against the enemy's box.
; 
; The $20 DP flag distinguishes normal mode (exclusion mask $76E0) from friendly/interaction mode ($74E0 + extendedFlags $0010 check). On overlap, calls EnemyHitPlayerHandler.

CombatCollision_EnemyLoop {
    BIT #$0080            ; Check enemy hittable flag: bit 7 ($0080) of current actor flags
    BEQ loc_03BC26        ; Not hittable → skip to inner loop at loc_03BC26
    BIT #$0040            ; Bit 6 ($0040) = orb protection on this actor
    BNE loc_03BC26        ; Actor has orb → skip (can't hit orb-protected enemies)
    LDA $0012, Y          ; Load secondary flags ($0012,Y) for damage immunity check
    BIT #$0010            ; Bit 4 ($0010) in $12 = damage immunity flag
    BNE loc_03BC26        ; Damage-immune → skip player attack test
    STX $0E               ; Save current render list index X to DP $0E
    STY $08               ; Save enemy actor pointer Y to DP $08
    TYX                   ; Transfer enemy pointer Y→X for long indexed access
    LDA $iframeCounter, X ; Load iframe counter from $7F0028,X (enemy's invincibility timer)
    BMI CombatCollision_NextTarget ; Negative iframe = recovery phase → skip attack test, go to NextTarget
    JSR $&PlayerAttackHitTest ; JSR PlayerAttackHitTest — test player's attack box vs this enemy
    BRA CombatCollision_NextTarget ; Always branch to NextTarget after attack test

  loc_03BC1B:
    LDX #$0000            ; Initial entry: reset render list index to 0
    STX $0E               ; Store initial list index 0 to DP $0E

  CombatCollision_NextTarget:
    LDX $0E               ; Reload render list index from DP $0E
    STZ $20               ; Zero DP $20 — friendly/interaction hit flag (0 = normal combat mode)
    STZ $24               ; Zero DP $24 — extended interaction flag

  loc_03BC26:
    LDY $0C00, X          ; Load next actor pointer from render list ($0C00,X)
    BNE loc_03BC2E        ; Nonzero = valid actor → continue at loc_03BC2E
    JMP $&CombatCollision_Exit ; End of render list → exit combat collision

  loc_03BC2E:
    INX                   ; Advance render list index by 2
    INX 
    LDA $0010, Y          ; Load target actor's primary flags ($0010,Y)
    BIT #$0400            ; Bit 10 ($0400) = combat-eligible flag (enemies have this set)
    BEQ CombatCollision_EnemyLoop ; Not combat-eligible → loop back to CombatCollision_EnemyLoop for Phase 1
    BIT #$0140            ; Check bits 8|6 ($0140) = dead or orb-protected
    BNE loc_03BC26        ; Dead/orb → skip AABB test, advance to next actor
    BIT #$0020            ; Bit 5 ($0020) = friendly/NPC flag
    BEQ loc_03BC44        ; Not friendly → proceed to AABB setup at loc_03BC44
    INC $20               ; Friendly actor present — set $20 flag for interaction hit mode

  loc_03BC44:
    STX $0E               ; Save render list index X to DP $0E for inner loop
    STY $08               ; Save target actor Y to DP $08
    SEP #$20              ; 8-bit A for data bank switch
    TYX                   ; Transfer target actor Y→X for long indexed access
    LDA $7F0008, X        ; Load target actor's sprite bank byte from $7F0008,X
    PHA                   ; Push bank byte onto stack
    PLB                   ; Pull into data bank register — now abs addressing reads actor's bank
    REP #$20              ; Back to 16-bit A for hitbox math
    LDA $metaspritePtr, X ; Load metasprite pointer from $7F000C,X
    TAY                   ; TAY — metasprite base pointer in Y for offset reads
    STA $42               ; Save metasprite pointer to DP $42 for CalcKnockback later
    LDA $000E, X          ; Load sprite field $000E,X (contains H-mirror flag in high bits)
    ASL                   ; ASL ×2 — shift H-mirror flag into carry
    ASL 
    LDA $0004, Y          ; Load hitbox X offset from metasprite+4 (signed 8-bit)
    AND #$00FF            ; Mask to low byte
    BIT #$0080            ; Test sign bit ($0080) for sign extension
    BEQ loc_03BC6D        ; Positive → no sign extension needed
    ORA #$FF00            ; Sign-extend: set high byte to $FF for negative offsets

  loc_03BC6D:
    BCS loc_03BC81        ; Carry set = H-mirrored → use negated hitbox path
    ADC $0014, X          ; Non-mirrored: X_left = actorX + hitbox_X_offset
    STA $04               ; Store left edge X to DP $04
    LDA $0005, Y          ; Load hitbox X width from metasprite+5 (unsigned byte)
    AND #$00FF            ; Mask to byte (clear high byte)
    CLC                   ; Clear carry for addition
    ADC $04               ; X_right = X_left + width
    STA $06               ; Store right edge X to DP $06
    BRA loc_03BC9A        ; Skip mirrored path → continue to Y hitbox

  loc_03BC81:
    EOR #$FFFF            ; Mirrored: negate X offset (two's complement)
    INC                   ; INC completes two's complement negation
    CLC                   ; Clear carry for addition
    ADC $0014, X          ; Mirrored X_right = actorX + (−offset) = actorX − offset
    STA $06               ; Store right edge to DP $06
    LDA $0005, Y          ; Load width byte
    AND #$00FF            ; Mask to byte
    EOR #$FFFF            ; Negate width for mirrored subtraction
    INC                   ; INC completes negation
    CLC                   ; Clear carry
    ADC $06               ; Mirrored X_left = X_right − width
    STA $04               ; Store left edge to DP $04

  loc_03BC9A:
    LDA $0006, Y          ; Load hitbox Y offset from metasprite+6 (signed byte)
    AND #$00FF            ; Mask to byte
    BIT #$0080            ; Test sign bit for extension
    BEQ loc_03BCA8        ; Positive → no sign extension
    ORA #$FF00            ; Sign-extend negative Y offset

  loc_03BCA8:
    CLC                   ; Clear carry for addition
    ADC $0016, X          ; Y_top = actorY ($0016,X) + hitbox_Y_offset
    STA $00               ; Store top edge Y to DP $00
    LDA $0007, Y          ; Load hitbox Y height from metasprite+7 (unsigned byte)
    AND #$00FF            ; Mask to byte
    CLC                   ; Clear carry
    ADC $00               ; Y_bottom = Y_top + height
    STA $02               ; Store bottom edge Y to DP $02
    LDX #$0000            ; Reset render list index to 0 for inner loop (test all actors)

  CombatCollision_InnerLoop:
    LDY $0C00, X          ; Inner loop: load next actor from render list ($0C00,X)
    BNE loc_03BCC4        ; Nonzero = valid actor → continue at loc_03BCC4
    JMP $&CombatCollision_NextTarget ; End of render list → jump back to NextTarget (advance outer loop)

  loc_03BCC4:
    INX                   ; Advance inner loop index by 2
    INX 
    LDA $20               ; Check $20 flag: nonzero = friendly/interaction mode
    BNE loc_03BCD4        ; Friendly mode → use alternate exclusion mask at loc_03BCD4
    LDA $0010, Y          ; Normal mode: load target actor flags ($0010,Y)
    BIT #$76E0            ; Exclusion mask $76E0: skip dead/orb/COP/display/overlay/pause actors
    BEQ loc_03BCEF        ; All exclusion bits clear → test AABB overlap at loc_03BCEF
    BRA CombatCollision_InnerLoop ; Has exclusion flags → skip this actor, try next

  loc_03BCD4:
    STZ $24               ; Friendly mode: clear $24 for fresh interaction flag
    LDA $0010, Y          ; Load target flags for friendly exclusion check
    BIT #$74E0            ; Mask $74E0: similar to $76E0 but allows bit 9 ($0200) through
    BNE CombatCollision_InnerLoop ; Has exclusion flags → skip
    PHX                   ; Save render list index for restore after inner check
    TYX                   ; Transfer target actor Y→X for extended flag access
    LDA $extendedFlags, X ; Load extendedFlags ($7F002A,X) for interaction eligibility
    BIT #$0010            ; Bit 4 ($0010) = has interaction collision enabled
    BNE loc_03BCEC        ; Interaction enabled → proceed to overlap test (via loc_03BCEC)
    PLX                   ; Not interaction-eligible → restore X and skip
    BRA CombatCollision_InnerLoop ; Skip to next actor in inner loop

  loc_03BCEC:
    PLX                   ; Restore render list index X from stack
    INC $24               ; Set $24 flag — marks this as an interaction/push collision

  loc_03BCEF:
    LDA $0020, Y          ; Begin AABB overlap test: load target hitbox X1 from $0020,Y (signed byte)
    AND #$00FF            ; Mask to byte
    BIT #$0080            ; Test sign bit
    BEQ loc_03BCFD        ; Positive → no sign extension
    ORA #$FF00            ; Sign-extend negative X1 offset

  loc_03BCFD:
    SEC                   ; SEC for subtraction
    SBC $0014, Y          ; hitbox_right = actorX ($0014,Y) − (−X1) = actorX + X1 (after negate)
    EOR #$FFFF            ; Negate: EOR + INC = two's complement
    INC                   ; INC completes negation → result is actorX − X1_offset (right edge)
    CMP $06               ; Compare right edge vs enemy left ($06): if right < enemy_left, no overlap
    BCS CombatCollision_InnerLoop ; No X overlap → skip to next actor
    LDA $0021, Y          ; Load target hitbox X2 from $0021,Y (signed byte → right extent)
    AND #$00FF            ; Mask to byte
    BIT #$0080            ; Test sign bit
    BEQ loc_03BD17        ; Positive → skip sign extension
    ORA #$FF00            ; Sign-extend negative

  loc_03BD17:
    CLC                   ; Clear carry for addition
    ADC $0014, Y          ; target_right = actorX + X2_offset
    CMP $04               ; Compare target_right vs enemy right ($04): target must reach past $04
    BCC CombatCollision_InnerLoop ; target_right < enemy_left_edge ($04) → no X overlap
    LDA $0022, Y          ; Load target hitbox Y1 from $0022,Y (signed byte)
    AND #$00FF            ; Mask to byte
    BIT #$0080            ; Test sign bit
    BEQ loc_03BD2D        ; Positive → skip extension
    ORA #$FF00            ; Sign-extend negative Y1

  loc_03BD2D:
    SEC                   ; SEC for subtraction
    SBC $0016, Y          ; Y1_edge = actorY − Y1_offset (negated subtraction)
    EOR #$FFFF            ; Negate result
    INC                   ; INC completes negation → top edge of target
    CMP $02               ; Compare top vs enemy bottom ($02): must overlap
    BCS CombatCollision_InnerLoop ; No Y overlap → skip
    LDA $0023, Y          ; Load target hitbox Y2 from $0023,Y (bottom extent, signed byte)
    AND #$00FF            ; Mask to byte
    BIT #$0080            ; Test sign bit
    BEQ loc_03BD47        ; Positive → skip extension
    ORA #$FF00            ; Sign-extend negative Y2

  loc_03BD47:
    CLC                   ; Clear carry for addition
    ADC $0016, Y          ; target_bottom = actorY + Y2_offset
    CMP $00               ; Compare target_bottom vs enemy top ($00)
    BCS loc_03BD52        ; Overlap on both axes! → proceed to hit handler at loc_03BD52
    JMP $&CombatCollision_InnerLoop ; target_bottom < enemy_top → no Y overlap, try next

  loc_03BD52:
    PHX                   ; Save render list index before calling hit handler
    JSR $&EnemyHitPlayerHandler ; JSR EnemyHitPlayerHandler — process enemy-on-player collision
    PLX                   ; Restore render list index
    JMP $&CombatCollision_InnerLoop ; Continue inner loop with next actor
}

CombatCollision_Exit {
    PLB                   ; Restore data bank saved at RunCombatCollision entry
    PLP                   ; Restore processor flags
    RTL                   ; Return from combat collision to caller (RTL)
}

---------------------------------------------
; Test the player's attack hitbox against all enemies and apply damage on hit.
; 
; Constructs the player's attack AABB from the metasprite header: $0000/$0001 are signed X/Y offsets (sign-extended from 8 bits via ORA #$FF00), $0002/$0003 are unsigned widths (×16 via ASL ×4). The result is stored in DP $00–$06 as the bounding box.
; 
; Then iterates all actors in the render list, skipping those with exclusion flags ($36F0). For each candidate, reads the actor's hitbox fields ($0020–$0023) as signed offsets from position, computes the AABB, and tests overlap against the player's box.
; 
; On hit: applies damage = chainDamage/2 + 1. chainDamage ($7F101E,X) accumulates across consecutive hits within the same attack sequence. Enemy HP = max(0, HP − damage). If HP reaches 0: checks for onDeathCallback or defaults to StandardEnemyDefeatHandler. If alive: spawns HitStaggerMain for knockback, computes knockback direction, assigns iframe counter ($0011 normal or $FFEF for $0001 flag).
; 
; Damage digits are formatted via FormatDamageDigits and spawned as SpawnAttackTrailEffect floating numbers (priority $2F00). Enemy HP is written to the HUD display registers.

PlayerAttackHitTest {
    SEP #$20              ; 8-bit A to set up data bank for player's sprite bank
    LDA $7F0008, X        ; Load player's sprite bank byte from $7F0008,X
    PHA                   ; Push bank byte
    PLB                   ; Pull into DBR — absolute addressing now reads player's bank
    REP #$20              ; 16-bit A for hitbox computation
    LDA $metaspritePtr, X ; Load player metasprite pointer from $7F000C,X
    TAY                   ; Copy to Y for offset-based reads of metasprite header
    STA $42               ; Save metasprite pointer to DP $42
    LDA $0014, X          ; Load player X position ($0014,X)
    STA $04               ; Store to DP $04 (will become attack box left edge)
    LDA $0016, X          ; Load player Y position ($0016,X)
    STA $00               ; Store to DP $00 (will become attack box top edge)
    LDA $0000, Y          ; Load attack hitbox X offset from metasprite byte 0 (always negative/leftward)
    ORA #$FF00            ; ORA #$FF00 — sign-extend byte 0 as always-negative offset
    CLC                   ; CLC for addition
    ADC $04               ; attack_left = playerX + negative_offset (shifts box left of player)
    STA $04               ; Store attack box left edge to DP $04
    LDA $0002, Y          ; Load attack hitbox width from metasprite byte 2 (unsigned)
    AND #$00FF            ; Mask to byte
    ASL                   ; ASL ×4 = multiply width by 16 (hitbox units to pixels)
    ASL 
    ASL 
    ASL 
    CLC                   ; CLC for addition
    ADC $04               ; attack_right = attack_left + (width × 16)
    STA $06               ; Store right edge to DP $06
    LDA $0001, Y          ; Load attack hitbox Y offset from metasprite byte 1 (always negative/upward)
    ORA #$FF00            ; ORA #$FF00 — sign-extend as negative offset
    CLC                   ; CLC for addition
    ADC $00               ; attack_top = playerY + negative_offset
    STA $00               ; Store attack box top edge to DP $00
    LDA $0003, Y          ; Load attack hitbox height from metasprite byte 3 (unsigned)
    AND #$00FF            ; Mask to byte
    ASL                   ; ASL ×4 = multiply height by 16
    ASL 
    ASL 
    ASL 
    CLC                   ; CLC for addition
    ADC $00               ; attack_bottom = attack_top + (height × 16)
    STA $02               ; Store bottom edge to DP $02
    LDX #$0000            ; Reset render list index to 0 for iteration

  code_03BDAF:
    LDY $0C00, X          ; Load next actor from render list ($0C00,X)
    BNE loc_03BDB7        ; Nonzero = valid → continue at loc_03BDB7
    JMP $&PlayerAttackHitTest_End ; End of list → jump to PlayerAttackHitTest_End

  loc_03BDB7:
    INX                   ; Advance render list index by 2
    INX 
    LDA $0010, Y          ; Load target actor flags ($0010,Y)
    BIT #$36F0            ; Exclusion mask $36F0: skip friendly/dead/orb/COP/display actors
    BNE code_03BDAF       ; Any exclusion bit set → skip this target
    LDA $0020, Y          ; Load target hitbox X1 from $0020,Y (signed byte offset from position)
    AND #$00FF            ; Mask to byte
    BIT #$0080            ; Test sign bit
    BEQ loc_03BDCF
    ORA #$FF00

  loc_03BDCF:
    SEC                   ; Compute target right edge: SEC then subtract from position (negated)
    SBC $0014, Y
    EOR #$FFFF
    INC                   ; Compare right_edge vs player attack_right ($06)
    CMP $06
    BCS code_03BDAF
    LDA $0021, Y
    AND #$00FF
    BIT #$0080
    BEQ loc_03BDE9        ; Sign-extend negative
    ORA #$FF00

  loc_03BDE9:
    CLC                   ; CLC for addition
    ADC $0014, Y          ; target_left = actorX + X2_offset
    CMP $04               ; Compare target_left vs player attack_left ($04)
    BCC code_03BDAF       ; target_left < attack_left → no X overlap
    LDA $0022, Y          ; Load target hitbox Y1 from $0022,Y (signed byte)
    AND #$00FF            ; Mask to byte
    BIT #$0080            ; Test sign bit
    BEQ loc_03BDFF
    ORA #$FF00

  loc_03BDFF:
    SEC                   ; SEC for subtraction
    SBC $0016, Y          ; Compute top_edge via negated subtraction
    EOR #$FFFF            ; Negate result
    INC                   ; INC → target top_edge
    CMP $02               ; Compare vs player attack_bottom ($02)
    BCS code_03BDAF       ; No Y overlap → skip
    LDA $0023, Y          ; Load target hitbox Y2 from $0023,Y (bottom extent)
    AND #$00FF            ; Mask to byte
    BIT #$0080            ; Test sign bit
    BEQ loc_03BE19
    ORA #$FF00

  loc_03BE19:
    CLC                   ; CLC for addition
    ADC $0016, Y          ; target_bottom = actorY + Y2_offset
    CMP $00               ; Compare target_bottom vs player attack_top ($00)
    BCS loc_03BE24        ; Overlap confirmed → process hit at loc_03BE24
    JMP $&code_03BDAF     ; No overlap → continue checking next actor

  loc_03BE24:
    TYX                   ; Transfer hit target Y→X for damage processing
    LDA $08               ; Load saved enemy pointer from DP $08 (the attacking player's context)
    TAX                   ; TAX — X now points to the player's actor slot for chainDamage access
    LDA $chainDamage, X   ; Load player's chainDamage ($7F101E,X) — cumulative hit counter
    LSR                   ; LSR — halve chainDamage for diminishing returns
    TYX                   ; Transfer hit target back to X for HP update
    STA $chainDamage, X   ; Store halved chainDamage to enemy's chainDamage field ($7F101E,X)
    INC                   ; INC — damage = chainDamage/2 + 1 (minimum 1 damage)
    PHA                   ; Save damage to stack for later use
    EOR #$FFFF            ; Negate damage for HP subtraction
    INC                   ; INC completes negation
    CLC                   ; CLC for addition (adding negative = subtraction)
    ADC $currentHp, X     ; enemyHP = currentHp ($7F0026,X) − damage
    BPL loc_03BE42        ; HP still positive → store normally
    LDA #$0000            ; HP went negative → clamp to 0 (enemy is dead)

  loc_03BE42:
    STA $currentHp, X     ; Store updated HP to currentHp ($7F0026,X)
    STA $0AE2             ; Store HP to work area $0AE2 for HUD display
    PHX                   ; Save target X for stats lookup
    LDA $statsPtr, X      ; Load statsPtr ($7F0020,X) — pointer to enemy's stats table
    TAX                   ; Transfer to X for long indexed read
    LDA $810000, X        ; Read max HP from stats table byte 0 (long address $81xxxx)
    STA $0AE0             ; Store max HP to $0AE0 for HUD bar calculation
    PLX                   ; Restore target actor slot to X
    TXA                   ; TXA → TCD: set direct page to target actor's slot base
    TCD 
    LDA $12               ; Load secondary flags ($12 via DP)
    BIT #$0020            ; Bit 5 ($0020) = boss/no-damage-display flag
    BNE loc_03BE76        ; Boss flag set → skip damage number display
    PLA                   ; JSR FormatDamageDigits — convert to packed BCD for sprite display
    JSR $&FormatDamageDigits
    BCS loc_03BE77
    PHA                   ; COP SpawnLastRel: spawn damage number actor at target position
    COP [SpawnLastRel] ( @SpawnAttackTrailEffect, #00, #00, #$2F00 )
    PLA 
    STA $0028, Y
    BRA loc_03BE77

  loc_03BE76:
    PLA                   ; Boss path: discard damage value from stack

  loc_03BE77:
    LDA #$0080            ; Set bit 7 ($0080) in target actor's primary flags — iframe state
    TSB $10               ; Load playerFlags to check for auto-kill mode
    LDA $playerFlags
    BIT #$0010
    BNE loc_03BE8B        ; Normal mode: check target's secondary flags
    LDA $12               ; Bit 4 ($0010) in $12 = stagger-immune flag
    BIT #$0010
    BEQ loc_03BEBE

  loc_03BE8B:
    LDA $0AE2             ; Check if HP reached zero
    BNE loc_03BEEE        ; HP nonzero → enemy survived, skip to iframe assignment at loc_03BEEE
    LDA #$0040            ; Set bit 6 ($0040) in flags — mark actor as dead
    TSB $10               ; Check onDeathCallback ($7F1004,X) for custom death handler
    LDA $onDeathCallback, X
    BEQ loc_03BEAB        ; Custom death: copy callback address to entry point $00
    STA $00               ; Load custom death bank byte from $7F1006,X
    LDA $7F1006, X
    STA $02               ; Clear DP $08 (frame delay counter)
    STZ $08               ; Clear velocity X ($2C)
    STZ $2C               ; Clear velocity Y ($2E)
    STZ $2E               ; Jump to HUD update at loc_03BF08
    BRA loc_03BF08

  loc_03BEAB:
    LDA #$*StandardEnemyDefeatHandler ; Default death: load StandardEnemyDefeatHandler bank byte
    STA $02               ; Store bank to $02
    LDA #$&StandardEnemyDefeatHandler ; Load StandardEnemyDefeatHandler address
    STA $00               ; Store to entry point $00
    STZ $08               ; Clear frame delay
    LDA #$0400            ; Set $0400 flag (standard defeat marker) in primary flags
    TSB $10               ; TSB $10 sets the standard defeat flag
    BRA loc_03BF08        ; Jump to HUD update at loc_03BF08

  loc_03BEBE:
    COP [SpawnLastRel] ( @hit_stagger_controller.HitStaggerMain, #00, #00, #$2000 ) ; Spawn HitStaggerMain effect for knockback animation
    LDA #$0000
    STA $002C, Y          ; Zero velocity Y on spawned stagger actor ($002E,Y)
    STA $002E, Y
    LDA $extendedFlags, X
    AND #$0020
    PHX                   ; Copy directional flag to stagger actor's extendedFlags
    TYX 
    STA $extendedFlags, X
    PLX                   ; Save direct page
    PHY                   ; JSR CalcKnockbackDirection — compute knockback cardinal direction
    PHD 
    JSR $&CalcKnockbackDirection
    BCC loc_03BEE7
    COP [GetPlayerFacing]

  loc_03BEE7:
    PLD                   ; Restore direct page
    PLY 
    STA $0028, Y          ; Restore stagger actor Y
    TDC 
    TAX                   ; TDC → TAX: restore target actor pointer from direct page

  loc_03BEEE:
    LDA $12               ; Load secondary flags ($12 via DP) for iframe type check
    BIT #$0001            ; Bit 0 ($0001) = use recovery iframe (negative counter) instead of invincibility
    BEQ loc_03BEFE        ; Recovery flag set → assign negative iframes at loc_03BEFE
    LDA #$FFEF            ; Normal: assign 17-frame ($0011) invincibility counter
    STA $iframeCounter, X ; Store positive iframe counter to $7F0028,X
    BRA loc_03BF05        ; Skip recovery path

  loc_03BEFE:
    LDA #$0011            ; Recovery iframe: assign $FFEF (−17) — counts up toward zero
    STA $iframeCounter, X ; Store negative iframe counter to $7F0028,X

  loc_03BF05:
    COP [PlaySoundCh1] ( #05 ) ; COP PlaySoundCh1: play hit sound #05 on audio channel 1

  loc_03BF08:
    LDA $12               ; Load secondary flags ($12) for boss/no-display check
    BIT #$0020            ; Bit 5 ($0020) = boss flag — skip HP bar update
    BNE PlayerAttackHitTest_End ; Boss → skip HUD update, jump to PlayerAttackHitTest_End
    SEP #$20              ; 8-bit A for byte-sized HUD register writes
    LDA $0AE0             ; Load max HP from $0AE0 work area
    STA $enemyHpDisplay   ; Write to enemyHpDisplay ($09E4) for HUD bar rendering
    STA $enemyHpPending   ; Also write to enemyHpPending ($09EA) to trigger HUD update
    LDA $0AE2             ; Load current HP from $0AE2
    STA $09E6             ; Write to HP display counter at $09E6
    REP #$20              ; 16-bit A restored for clean return
}

PlayerAttackHitTest_End {
    LDA #$0000            ; Reset direct page to 0 (clean up from TCD targeting actor slot)
    TCD                   ; RTS — return to CombatCollision_EnemyLoop caller
    RTS 
}

---------------------------------------------
; Handle an enemy actor making contact with the player.
; 
; Two main paths based on $24 flag (set by the friendly/interaction detection in the outer loop):
; 
; Path 1 ($24 nonzero — interaction/push hit): Checks the enemy's scratch1010+6 ($7F1016,X) for a custom interaction handler. If present, overwrites the enemy's entry point. Otherwise, sets the enemy to player_transition_handlers, marks $0040 (death flag), and dispatches knockback velocity by player facing direction (±4 to extVelocityX/Y).
; 
; Path 2 ($24 zero — combat damage): Checks if the enemy has $0010 in flags (invincible) → routes to InvinciblePlayerHit. Otherwise computes damage:
;   totalStr = playerStr + previousDamage($09E2) + climbStateData
;   rawDamage = max(1, enemyAtk(stats[2]) − totalStr)
;   netDamage = rawDamage + chainDamage($08)
; Subtracts from enemy HP, spawns damage digits (priority $2B00 with $1000 in spawned actor's $12), handles death (onDeathCallback or StandardEnemyDefeatHandler), and spawns HitStaggerMain for knockback.
; 
; After damage: checks and dispatches onHitCallback ($7F1000,X). Assigns iframes ($0011 or $FFEF). Updates HUD HP display. Finally checks extendedFlags $0050 for collision callback processing — clears $FFAF bits, toggles $6000 in $12, and dispatches onCollideCallback.

EnemyHitPlayerHandler {
    SEP #$20              ; 8-bit A for data bank switch
    LDA #$81              ; Load bank $81 for RAM access to extended actor fields
    PHA                   ; Push $81
    PLB                   ; Pull into DBR — now absolute addresses read bank $81
    REP #$20              ; 16-bit A for flag checks and damage computation
    LDA $24               ; Load $24 flag — nonzero = interaction/push collision from friendly actor
    BEQ loc_03BF86        ; Zero → combat damage path at loc_03BF86
    STZ $24               ; Clear $24 flag after reading
    TYX                   ; Transfer hit actor Y→X for indexed access
    LDA $scratch1010+6, X ; Load scratch1010+6 ($7F1016,X) — custom interaction handler address
    BEQ loc_03BF40        ; No custom handler → use default at loc_03BF40
    STA $0000, X          ; Overwrite actor entry point with custom handler
    RTS                   ; Return — actor will execute custom handler next frame

  loc_03BF40:
    TXA                   ; No custom handler: set up player transition sequence
    PHD                   ; Save current direct page
    TCD                   ; Set DP to actor slot base for DP-relative access
    LDA #$&player_transition_handlers ; Load player_transition_handlers address (same-bank reference)
    STA $00               ; Store to entry point $00
    LDA #$*player_transition_handlers ; Load player_transition_handlers bank byte
    STA $02               ; Store to $02 (bank byte of entry point)
    LDA #$0040            ; Load $0040 = death/transition flag
    TSB $10               ; TSB $10 — set transition flag in actor's primary flags
    PLD                   ; Restore original direct page
    JSL $@GetPlayerFacingDirection ; JSL GetPlayerFacingDirection — returns facing in low nibble
    PEA $&EnemyHitPlayer_Epilogue-1 ; Push EnemyHitPlayer_Epilogue−1 as return address for RTS trick
    BCC loc_03BF5D        ; Carry clear = facing is valid → apply directional velocity
    RTS                   ; Carry set → RTS returns through PEA'd address to Epilogue

  loc_03BF5D:
    AND #$000F            ; Mask to low nibble (direction 0–3)
    BNE loc_03BF69        ; Direction 0 (up/north)? → push player up
    LDA #$FFFC            ; Knockback velocity = −4 (upward)
    STA $extVelocityY     ; Store to extVelocityY ($040A)
    RTS                   ; RTS → returns to EnemyHitPlayer_Epilogue via PEA trick

  loc_03BF69:
    DEC                   ; DEC — direction 1 (down/south)?
    BNE loc_03BF73        ; Not 1 → check next direction
    LDA #$0004            ; Knockback velocity = +4 (downward)
    STA $extVelocityY     ; Store to extVelocityY ($040A)
    RTS                   ; RTS → Epilogue

  loc_03BF73:
    DEC                   ; DEC — direction 2 (right/east)?
    BNE loc_03BF7D        ; Not 2 → must be direction 3 (left/west)
    LDA #$0004            ; Knockback velocity = +4 (rightward)
    STA $extVelocityX     ; Store to extVelocityX ($0408)
    RTS                   ; RTS → Epilogue

  loc_03BF7D:
    LDA #$FFFC            ; Direction 3: knockback velocity = −4 (leftward)
    STA $extVelocityX     ; Store to extVelocityX ($0408)
    RTS                   ; RTS → Epilogue
}

EnemyHitPlayer_Epilogue {
    TXY                   ; Transfer enemy actor pointer X→Y for return to caller
    RTS                   ; RTS — return from EnemyHitPlayer_Epilogue to combat loop

  loc_03BF86:
    TYX                   ; Transfer target actor Y→X for damage processing
    STX $3E               ; Save target pointer to DP $3E for later use in post-collision
    LDA $0010, X          ; Load target actor flags ($0010,X)
    BIT #$0010            ; Bit 4 ($0010) = invincible/immune flag
    BEQ loc_03BF94        ; Not invincible → proceed to normal damage at loc_03BF94
    JMP $&InvinciblePlayerHit ; Invincible → route to InvinciblePlayerHit handler

  loc_03BF94:
    STZ $20               ; Zero DP $20 — damage modifier accumulator
    LDA $08               ; Load saved attacking actor from DP $08
    CMP #$1000            ; Compare attacker pointer to $1000 (first actor slot / player)
    BEQ loc_03BFA2        ; Player is attacker → skip weapon bonus at loc_03BFA2
    LDA $09E2             ; Non-player attacker: load weapon/bonus damage from $09E2
    STA $20               ; Store bonus to DP $20

  loc_03BFA2:
    LDA $characterForm    ; Load characterForm ($0AD4): 0=Will, 1=Freedan, 2=Shadow
    STA $08               ; Save form to DP $08 for later reference
    LDA $playerStr        ; Load playerStr ($0ADE) — base attack power
    CLC                   ; Add bonus damage from $20 (weapon modifier)
    ADC $20
    CLC                   ; Add climbStateData ($09E0) — elevation bonus
    ADC $climbStateData
    STA $20               ; Store total strength to DP $20
    TXA                   ; Transfer target slot address to A
    TCD                   ; TCD — set direct page to target actor for DP-relative field access
    LDA $statsPtr, X      ; Load statsPtr ($7F0020,X) — pointer to enemy's stats table
    TAY                   ; Transfer to Y for indirect stat reads
    LDA $0000, Y          ; Load max HP from stats[0] (byte, zero-extended)
    AND #$00FF            ; Mask to byte — stats are packed bytes in 16-bit words
    STA $0AE0             ; Store max HP to $0AE0 for HUD display
    LDA $0002, Y          ; Load enemy attack power from stats[2] (byte, zero-extended)
    AND #$00FF            ; Mask to byte
    SEC                   ; SEC for subtraction
    SBC $0020             ; rawDamage = enemyAtk − totalStr (using DP $20 which is $0020 abs)
    EOR #$FFFF            ; Negate: damage = totalStr − enemyAtk (attacker perspective)
    INC                   ; INC completes two's complement
    CMP #$0001            ; Compare vs 1 — minimum damage is always 1
    BPL loc_03BFD9        ; Damage ≥ 1 → use calculated value
    LDA #$0001            ; Damage < 1 → floor to minimum of 1

  loc_03BFD9:
    CLC                   ; CLC for addition
    ADC $0008             ; Add chainDamage from $08 (accumulated consecutive hit bonus)
    STA $chainDamage, X   ; Store total damage to enemy's chainDamage ($7F101E,X)
    PHA                   ; Save damage for HP subtraction
    EOR #$FFFF            ; Negate damage for subtraction from HP
    INC                   ; INC completes negation
    CLC                   ; CLC for addition (negative = subtraction)
    ADC $currentHp, X     ; enemyHP = currentHp − damage
    BPL loc_03BFF0        ; HP still positive → store normally
    LDA #$0000            ; HP negative → clamp to 0

  loc_03BFF0:
    STA $currentHp, X     ; Store updated HP to currentHp ($7F0026,X)
    STA $0AE2             ; Also store to $0AE2 for HUD display
    LDA $12               ; Check secondary flags ($12) for boss/no-display
    BIT #$0020            ; Bit 5 ($0020) = boss flag
    BNE loc_03C01D        ; Boss → skip damage digits
    PLA                   ; Pull damage from stack
    JSR $&FormatDamageDigits ; JSR FormatDamageDigits — convert to packed BCD
    BCS loc_03C01E        ; Carry set = overflow (≥1000) → skip spawn
    PHA                   ; Save formatted digits
    COP [SpawnLastRel] ( @SpawnAttackTrailEffect, #00, #00, #$2B00 ) ; COP SpawnLastRel: spawn floating damage number ($2B00 priority)
    LDA $0012, Y
    ORA #$1000
    STA $0012, Y
    PLA                   ; Store digit data to damage sprite's animation field ($0028,Y)
    STA $0028, Y
    BRA loc_03C01E

  loc_03C01D:
    PLA                   ; Boss path: discard damage from stack

  loc_03C01E:
    LDA #$0080            ; Set $0080 (iframe flag) in target actor flags $10
    TSB $10               ; Load playerFlags for auto-kill check
    LDA $playerFlags
    BIT #$0010
    BNE loc_03C032        ; Check target secondary flags for stagger immunity
    LDA $12               ; Bit 4 ($0010) in $12 = stagger-immune
    BIT #$0010
    BEQ loc_03C065

  loc_03C032:
    LDA $0AE2             ; Check if enemy HP reached zero ($0AE2)
    BNE loc_03C097        ; HP nonzero → survived, skip to onHitCallback at loc_03C097
    LDA #$0040            ; Set $0040 (death flag) in target actor flags
    TSB $10               ; Check onDeathCallback ($7F1004,X)
    LDA $onDeathCallback, X
    BEQ loc_03C052        ; Copy custom death callback to entry point $00
    STA $00               ; Load custom death bank from $7F1006,X
    LDA $7F1006, X
    STA $02               ; Clear frame delay ($08)
    STZ $08               ; Clear velocity X ($2C)
    STZ $2C               ; Clear velocity Y ($2E)
    STZ $2E               ; Jump to HUD update
    BRA loc_03C0C8

  loc_03C052:
    LDA #$*StandardEnemyDefeatHandler ; Default death: load StandardEnemyDefeatHandler bank
    STA $02               ; Store bank to $02
    LDA #$&StandardEnemyDefeatHandler ; Load StandardEnemyDefeatHandler address
    STA $00               ; Store to entry point $00
    STZ $08               ; Clear frame delay
    LDA #$0400            ; Set $0400 (standard defeat flag)
    TSB $10               ; TSB $10
    BRA loc_03C0C8        ; Jump to HUD update

  loc_03C065:
    TXA                   ; Set DP to target actor for field-relative access
    TCD 
    COP [SpawnLastRel] ( @hit_stagger_controller.HitStaggerMain, #00, #00, #$2000 ) ; COP SpawnLastRel: spawn HitStaggerMain for visual knockback ($2000 priority)
    LDA #$0000
    STA $002C, Y          ; Zero stagger velocity Y ($002E,Y)
    STA $002E, Y
    LDA $extendedFlags, X
    AND #$0020
    PHX                   ; Copy direction flag to stagger actor's extendedFlags
    TYX 
    STA $extendedFlags, X
    PLX                   ; Save direct page
    PHY                   ; JSR CalcKnockbackDirection
    PHD 
    JSR $&CalcKnockbackDirection
    BCC loc_03C090
    COP [GetPlayerFacing]

  loc_03C090:
    PLD                   ; Restore direct page
    PLY 
    STA $0028, Y          ; Restore stagger actor Y
    TDC 
    TAX                   ; TDC → TAX: restore target pointer from DP

  loc_03C097:
    LDA $onHitCallback, X ; Load onHitCallback ($7F1000,X) — custom reaction to being hit
    BEQ loc_03C0AE        ; No callback → skip to iframe assignment at loc_03C0AE
    STA $00               ; Copy callback to entry point $00
    LDA #$0000            ; Clear the callback to prevent re-triggering
    STA $onHitCallback, X
    LDA $02
    AND #$00FF
    BNE loc_03C0AE
    NOP 

  loc_03C0AE:
    LDA $12               ; NOP padding (unused branch target)
    BIT #$0001
    BEQ loc_03C0BE
    LDA #$FFEF
    STA $iframeCounter, X
    BRA loc_03C0C5

  loc_03C0BE:
    LDA #$0011            ; Normal iframe: assign $0011 (17 frames) invincibility
    STA $iframeCounter, X ; Store positive counter to $7F0028,X

  loc_03C0C5:
    COP [PlaySoundCh1] ( #05 ) ; COP PlaySoundCh1: hit sound #05

  loc_03C0C8:
    LDA $12               ; Load secondary flags for boss check
    BIT #$0020            ; Bit 5 ($0020) = boss/no-display flag
    BNE loc_03C0E2        ; Boss → skip HUD update, jump to post-collision cleanup
    SEP #$20              ; 8-bit for HUD register writes
    LDA $0AE0             ; Load max HP from $0AE0
    STA $enemyHpDisplay   ; Write to enemyHpDisplay ($09E4)
    STA $enemyHpPending   ; Write to enemyHpPending ($09EA)
    LDA $0AE2             ; Load current HP from $0AE2
    STA $09E6             ; Write to display counter $09E6
    REP #$20              ; 16-bit A for cleanup

  loc_03C0E2:
    LDA #$0000            ; Reset direct page to 0
    TCD                   ; TCD restores zero-page
    LDX $0E               ; Reload render list index from DP $0E
    LDA $0BFE, X          ; Load previous actor from render list ($0BFE,X = two entries back)
    TAX                   ; Transfer to X for extended flag access
    LDA $extendedFlags, X ; Load attacker's extendedFlags ($7F002A,X)
    BIT #$0050            ; Check bits 6|4 ($0050) — collision callback trigger flags
    BEQ loc_03C115        ; Neither set → skip callback processing at loc_03C115
    AND #$FFAF            ; Clear bits 6|4 ($FFAF = ~$0050) from extendedFlags
    STA $extendedFlags, X ; Store cleared flags
    LDA $onCollideCallback, X ; Load onCollideCallback ($7F1008,X)
    BEQ loc_03C10C        ; No callback → skip to flag toggle at loc_03C10C
    STA $0000, X          ; Overwrite attacker entry point with collide callback
    LDA #$0000            ; Clear the collide callback to prevent re-trigger
    STA $onCollideCallback, X

  loc_03C10C:
    LDA $0012, X
    EOR #$6000
    STA $0012, X

  loc_03C115:
    RTS 
}

---------------------------------------------
; Handle enemy hitting a player that has the invincible flag ($0010).
; 
; Sets $0080 (iframe) in actor flags, assigns iframe counter $FFEF (recovery), checks onHitCallback for custom response. Plays invincible-hit sound #09 instead of normal damage sound. Then falls through to the enemy post-collision cleanup (loc_03C0E2) which handles extendedFlags $0050 and onCollideCallback processing.

InvinciblePlayerHit {
    TXA                   ; Set DP to invincible target actor for field access
    TCD 
    LDA $10               ; Load primary flags $10 via DP
    ORA #$0080            ; Set bit 7 ($0080) — iframe state marker
    STA $10               ; Store updated flags
    LDA #$FFEF            ; Assign recovery iframe counter $FFEF (−17) — negative = counting up
    STA $iframeCounter, X ; Store to $7F0028,X
    LDA $onHitCallback, X ; Load onHitCallback for invincible-hit response
    BEQ loc_03C13D        ; No callback → skip at loc_03C13D
    STA $00               ; Copy callback to entry point
    LDA #$0000            ; Clear callback to prevent re-trigger
    STA $onHitCallback, X
    LDA $02
    AND #$00FF
    BNE loc_03C13D
    NOP 

  loc_03C13D:
    COP [PlaySoundCh1] ( #09 ) ; NOP padding
    BRA loc_03C0E2
}

---------------------------------------------
; Compute knockback direction from attacking and defending actor hitbox centers.
; 
; Loads the attacking actor from $0BFE,Y (render list back-reference). If the attacker IS the player, returns with carry set (caller should use GetPlayerFacing instead).
; 
; Otherwise computes the attacker's hitbox center: reads metasprite hitbox offsets ($0004–$0007), sign-extends, halves the width/height (LSR), and adds to position. Accounts for H-mirror via carry flag.
; 
; Computes the defender's center: reads hitbox fields ($20–$23), halves, and adds to position.
; 
; Then determines direction by comparing axis deltas: |centerX_attacker − centerX_defender| vs |centerY_attacker − centerY_defender|. Returns: 0=south (defender below), 1=north (defender above), 2=west (defender left), 3=east (defender right). Returns carry clear to signal a valid direction.

CalcKnockbackDirection {
    LDY $000E             ; Load render list index from DP $0E for attacker lookup
    LDX $0BFE, Y
    CPX $playerActor
    SEC                   ; Attacker is not player → compute hitbox direction
    BNE loc_03C14F        ; RTS — return with carry set (attacker is player)
    RTS 

  loc_03C14F:
    SEP #$20              ; 8-bit A for bank switch
    LDA $7F0008, X        ; Load attacker's sprite bank from $7F0008,X
    PHA                   ; Push bank byte
    PLB                   ; Pull into DBR
    REP #$20              ; 16-bit A for hitbox math
    LDA $000E, X          ; Load attacker's sprite field ($000E,X)
    ASL                   ; ASL ×2 — shift H-mirror into carry
    ASL 
    LDY $0042             ; Load hitbox X offset from metasprite $42 (saved earlier)
    LDA $0004, Y          ; Mask to byte
    AND #$00FF            ; Test sign bit
    BIT #$0080
    BEQ loc_03C16F
    ORA #$FF00

  loc_03C16F:
    BCS loc_03C188        ; Non-mirrored path: add X offset to position
    CLC 
    ADC $0014, X          ; CLC
    STA $0018
    LDA $0005, Y          ; Load width byte
    AND #$00FF            ; Mask to byte
    LSR                   ; LSR — half-width for center calculation
    CLC                   ; Add half-width to left edge → center X
    ADC $0018
    STA $0018
    BRA loc_03C1A5

  loc_03C188:
    EOR #$FFFF            ; Mirrored: negate X offset
    INC                   ; INC completes negation
    CLC                   ; CLC
    ADC $0014, X          ; Mirrored: actorX + negated_offset
    STA $0018             ; Store right edge to DP $18
    LDA $0005, Y
    AND #$00FF
    LSR                   ; Negate half-width
    EOR #$FFFF
    INC                   ; CLC
    CLC                   ; Mirrored center = right_edge − half_width
    ADC $0018
    STA $0018

  loc_03C1A5:
    LDA $0006, Y          ; Load hitbox Y offset from metasprite+6
    AND #$00FF            ; Mask to byte
    BIT #$0080            ; Test sign bit
    BEQ loc_03C1B3
    ORA #$FF00

  loc_03C1B3:
    CLC                   ; CLC
    ADC $0016, X          ; centerY_base = actorY + Y_offset
    STA $001C             ; Store to DP $1C
    LDA $0007, Y
    AND #$00FF
    LSR                   ; Add half-height → center Y
    CLC 
    ADC $001C
    STA $001C             ; 8-bit A for defender center calc
    SEP #$20
    LDA $21               ; X2 − X1 = width
    SEC                   ; 16-bit A
    SBC $20
    REP #$20
    AND #$00FF            ; LSR — half-width
    LSR 
    BIT #$0040            ; Not set → skip sign extension
    BEQ loc_03C1DD
    ORA #$FF80

  loc_03C1DD:
    CLC                   ; CLC
    ADC $14               ; defender_centerX = defenderX ($14) + half_width
    STA $001A
    SEP #$20              ; 8-bit for Y axis
    LDA $23               ; Load defender hitbox Y2 ($23 via DP)
    SEC                   ; SEC
    SBC $22               ; Y2 − Y1 = height
    REP #$20              ; 16-bit A
    AND #$00FF            ; Mask to byte
    LSR                   ; Half-height
    BIT #$0040            ; Test sign bit of half-height
    BEQ loc_03C1F8        ; Not set → skip extension
    ORA #$FF80            ; Sign-extend

  loc_03C1F8:
    CLC                   ; CLC
    ADC $16               ; defender_centerY = defenderY ($16) + half_height
    STA $001E
    LDA #$0000            ; Reset direct page to 0 for absolute addressing
    TCD                   ; TCD restores zero-page
    LDA $18               ; Load attacker center X from DP $18
    SEC                   ; SEC for comparison subtraction
    SBC $1A               ; deltaX = attackerCenterX − defenderCenterX ($1A)
    BCS loc_03C22A
    EOR #$FFFF
    INC 
    STA $08               ; INC completes abs(deltaX)
    LDA $1C
    SEC 
    SBC $1E
    BCS loc_03C222
    EOR #$FFFF
    INC                   ; Compare |deltaY| vs |deltaX|
    CMP $08
    BCS loc_03C256
    NOP 
    NOP                   ; Y dominant, attacker above → direction is east/west
    BRA loc_03C24C

  loc_03C222:
    CMP $08               ; Compare |deltaY| vs |deltaX| (attacker above, defender left)
    BCS loc_03C251
    NOP 
    NOP                   ; NOP padding
    BRA loc_03C24C

  loc_03C22A:
    STA $08               ; Store |deltaX| to DP $08
    LDA $1C               ; deltaY = $1C − $1E
    SEC 
    SBC $1E               ; Carry clear = attacker above
    BCS loc_03C23F        ; Negate deltaY
    EOR #$FFFF
    INC 
    CMP $08
    BCS loc_03C256
    NOP 
    NOP                   ; X dominant → west direction
    BRA loc_03C247

  loc_03C23F:
    CMP $08               ; |deltaY| vs |deltaX|
    BCS loc_03C251
    NOP 
    NOP                   ; NOP padding
    BRA loc_03C247

  loc_03C247:
    CLC                   ; CLC — carry clear = valid direction computed
    LDA #$0002            ; Return direction 2 (west) in A
    RTS                   ; RTS

  loc_03C24C:
    CLC                   ; CLC — valid direction
    LDA #$0003            ; Return direction 3 (east) in A
    RTS                   ; RTS

  loc_03C251:
    CLC                   ; CLC — valid direction
    LDA #$0001            ; Return direction 1 (north) in A
    RTS                   ; RTS

  loc_03C256:
    CLC                   ; CLC — valid direction
    LDA #$0000            ; Return direction 0 (south) in A
    RTS                   ; RTS
}

InteractionCollision_Exit {
    PLB                   ; Restore data bank
    PLP                   ; Restore processor flags
    RTL                   ; RTL — exit from interaction collision
}

---------------------------------------------
; Player-vs-NPC/object interaction collision system.
; 
; Constructs a player interaction bounding box: X ± 4px from position, Y range from (Y−14) to (Y−4). This smaller box is centered higher than the combat hitbox, matching the player's interaction hotspot.
; 
; Checks player flags: $2040 (COP mode or orb) → exit immediately. $0280 (climb or special) → InteractionCollision_FriendlyMode (restricted to friendly NPCs).
; 
; Normal mode: iterates render list, skipping $35C0 flagged actors. For each candidate: sets data bank to actor's sprite bank, reads metasprite hitbox, accounts for H-mirror, and tests AABB overlap. On overlap: checks extendedFlags $0010 for collision callback. If callback exists, dispatches it; otherwise sets actor to smooth_follow_child default handler. Then calls ApplyInteractionDamage.
; 
; FriendlyMode: only tests actors with $0020 flag (friendly). Simplified hitbox test without H-mirror path. Single-hit return (first overlap triggers interaction and exits).

RunInteractionCollision {
    PHP                   ; Save processor status
    PHB                   ; Save data bank register
    REP #$20              ; 16-bit A for position math
    LDY $playerActor      ; Load player Y index from $09AA for position access
    LDA $0014, Y          ; Load player X position ($0014,Y)
    SEC                   ; Subtract 4: interaction box left = playerX − 4
    SBC #$0004
    STA $18
    CLC 
    ADC #$0008
    STA $1A               ; Load player Y position ($0016,Y)
    LDA $0016, Y
    SEC 
    SBC #$0004            ; Store bottom edge to DP $1E
    STA $1E
    SEC                   ; Store top edge to DP $1C
    SBC #$000A
    STA $1C
    LDA $0010, Y
    BIT #$2040
    BNE InteractionCollision_Exit
    BIT #$0280
    BEQ loc_03C293
    JMP $&InteractionCollision_FriendlyMode

  loc_03C293:
    LDY #$0000            ; Normal mode: initialize render list index Y = 0
    STY $0E               ; Store index to DP $0E

  InteractionCollision_LoopBody:
    LDY $0E               ; Reload render list index from DP $0E

  loc_03C29A:
    LDX $0C00, Y          ; Load next actor from render list ($0C00,Y)
    BEQ InteractionCollision_Exit ; Null = end of list → exit interaction collision
    INY                   ; Advance index by 2
    INY 
    LDA $0010, X          ; Load actor flags ($0010,X)
    BIT #$35C0            ; Exclusion mask $35C0: skip dead/orb/COP/pause/display actors
    BNE loc_03C29A        ; Any exclusion bit set → try next actor
    STY $0E               ; Save updated index to DP $0E
    SEP #$20              ; 8-bit A for bank switch
    LDA $7F0008, X        ; Load actor's sprite bank from $7F0008,X
    PHA                   ; Push bank byte
    PLB                   ; Pull into DBR
    REP #$20              ; 16-bit A for hitbox math
    TXY                   ; Transfer actor X→Y for position reads; X will hold metasprite
    LDA $metaspritePtr, X ; Load metasprite pointer ($7F000C,X → now via bank register)
    TAX                   ; Transfer to X for offset reads
    LDA $000E, Y          ; Load sprite field ($000E,Y) for H-mirror flag
    ASL                   ; ASL ×2 — H-mirror flag into carry
    ASL 
    LDA $0004, X          ; Load hitbox X offset from metasprite+4 (signed byte)
    AND #$00FF            ; Mask to byte
    BIT #$0080            ; Test sign bit
    BEQ loc_03C2CE
    ORA #$FF00

  loc_03C2CE:
    BCS loc_03C2E8        ; Carry set = mirrored → negated hitbox path at loc_03C2E8
    ADC $0014, Y          ; Non-mirrored: actorX ($0014,Y) + X_offset (carry clear from BCS fail)
    CMP $1A               ; Compare right edge vs player interaction right ($1A)
    BCS InteractionCollision_LoopBody ; Actor right ≥ player right → no overlap, next actor
    STA $06               ; Store left edge to DP $06
    LDA $0005, X          ; Load width from metasprite+5 (unsigned byte)
    AND #$00FF            ; Mask to byte
    CLC                   ; CLC
    ADC $06               ; actor_right = left + width
    CMP $18               ; Compare actor_right vs player interaction left ($18)
    BCC InteractionCollision_LoopBody ; actor_right < player_left → no overlap
    BRA loc_03C307        ; Both X edges overlap → check Y axis

  loc_03C2E8:
    EOR #$FFFF            ; Mirrored: negate X offset
    INC                   ; INC completes negation
    CLC                   ; CLC
    ADC $0014, Y          ; Mirrored: actorX + (−offset) = actorX − offset
    CMP $18               ; Compare left vs player left ($18)
    BCC InteractionCollision_LoopBody ; actor_left < player_left → no overlap
    STA $06               ; Store right edge to DP $06
    LDA $0005, X          ; Load width
    AND #$00FF            ; Mask to byte
    EOR #$FFFF            ; Negate width
    INC                   ; INC
    CLC                   ; CLC
    ADC $06               ; Mirrored left = right − width
    CMP $1A               ; Compare mirrored_left vs player right ($1A)
    BCS InteractionCollision_LoopBody ; mirrored_left ≥ player_right → no overlap

  loc_03C307:
    LDA $0006, X          ; Y axis check: load hitbox Y offset from metasprite+6 (signed byte)
    AND #$00FF            ; Mask to byte
    BIT #$0080            ; Test sign bit
    BEQ loc_03C315
    ORA #$FF00

  loc_03C315:
    CLC                   ; CLC
    ADC $0016, Y          ; actorY_top = actorY ($0016,Y) + Y_offset
    CMP $1E               ; Compare top vs player bottom ($1E)
    BCC loc_03C320        ; actor_top < player_bottom → overlap possible (note: screen Y is inverted)
    JMP $&InteractionCollision_LoopBody ; actor_top ≥ player_bottom → no overlap, jump to loop

  loc_03C320:
    STA $02               ; Store Y top to DP $02
    LDA $0007, X          ; Load height from metasprite+7
    AND #$00FF            ; Mask to byte
    CLC                   ; CLC
    ADC $02               ; actor_bottom = top + height
    CMP $1C               ; Compare bottom vs player top ($1C)
    BCS loc_03C332        ; Overlap! → process interaction hit at loc_03C332
    JMP $&InteractionCollision_LoopBody ; actor_bottom < player_top → no overlap

  loc_03C332:
    PHX                   ; Save metasprite X for later hitbox center calc
    TYX                   ; Transfer actor Y→X for extended flag check
    LDA $extendedFlags, X ; Load extendedFlags ($7F002A,X) for interaction trigger check
    BIT #$0010            ; Bit 4 ($0010) = has interaction/collision callback
    BEQ loc_03C35B        ; No interaction flag → skip callback at loc_03C35B
    LDA $onCollideCallback, X ; Load onCollideCallback ($7F1008,X)
    BEQ loc_03C348        ; No callback → use default handler at loc_03C348
    STA $0000, X          ; Overwrite actor entry point with callback address
    BRA loc_03C354        ; Branch to clear frame counter

  loc_03C348:
    LDA #$*smooth_follow_child.loc_00E4FA ; Default: load smooth_follow_child.loc_00E4FA bank byte
    STA $0002, X          ; Store to actor bank ($0002,X)
    LDA #$&smooth_follow_child.loc_00E4FA ; Load smooth_follow_child.loc_00E4FA address
    STA $0000, X          ; Store to actor entry point ($0000,X)

  loc_03C354:
    LDA #$0000            ; Clear actor frame counter ($0008,X) for immediate execution
    STA $0008, X          ; Transfer back to Y for ApplyInteractionDamage
    TXY 

  loc_03C35B:
    PLX                   ; Restore metasprite X from stack
    JSR $&ApplyInteractionDamage ; JSR ApplyInteractionDamage — apply damage or chat interaction

  loc_03C35F:
    PLB                   ; Restore data bank and processor flags — shared exit point
    PLP 
    RTL 
}

InteractionCollision_FriendlyMode {
    LDY #$0000            ; FriendlyMode: initialize render list index Y = 0
    STY $0E               ; Store to DP $0E

  loc_03C367:
    LDY $0E               ; Reload index from DP $0E

  loc_03C369:
    LDX $0C00, Y          ; Load next actor from render list ($0C00,Y)
    BEQ loc_03C35F        ; Null = end → exit at loc_03C35F (shared exit)
    INY                   ; Advance index by 2
    INY 
    LDA $0010, X          ; Load actor flags ($0010,X)
    BIT #$3540            ; Exclusion mask $3540: skip dead/COP/pause/display (but allow $0020 friendly)
    BNE loc_03C369        ; Any exclusion bit → skip
    BIT #$0020            ; Bit 5 ($0020) = friendly/NPC flag — REQUIRED for friendly mode
    BEQ loc_03C369        ; Not friendly → skip this actor
    STY $0E               ; Save updated index to DP $0E
    SEP #$20              ; 8-bit for bank switch
    LDA $7F0008, X        ; Load sprite bank byte
    PHA                   ; Push and pull into DBR
    PLB 
    REP #$20              ; 16-bit A
    TXY                   ; Transfer actor X→Y for position reads
    LDA $metaspritePtr, X ; Load metasprite pointer
    TAX                   ; Transfer to X for offset reads
    LDA $0004, X          ; Load hitbox X offset (simplified — no H-mirror for friendly mode)
    AND #$00FF            ; Mask to byte
    BIT #$0080            ; Test sign bit
    BEQ loc_03C39D
    ORA #$FF00

  loc_03C39D:
    CLC                   ; CLC
    ADC $0014, Y          ; left_edge = actorX ($0014,Y) + offset
    CMP $1A               ; Compare vs player right ($1A)
    BCS loc_03C367        ; actor_left ≥ player_right → no overlap
    STA $06               ; Store left to DP $06
    LDA $0005, X          ; Load width from metasprite+5
    AND #$00FF            ; Mask to byte
    CLC                   ; CLC
    ADC $0014, Y          ; right = actorX + width (note: uses actorX not left; simplified calc)
    CMP $18               ; Compare right vs player left ($18)
    BCC loc_03C367        ; right < player_left → no overlap
    LDA $0006, X          ; Load hitbox Y offset from metasprite+6
    AND #$00FF            ; Mask to byte
    BIT #$0080            ; Test sign bit
    BEQ loc_03C3C3
    ORA #$FF00

  loc_03C3C3:
    CLC                   ; CLC
    ADC $0016, Y          ; top = actorY ($0016,Y) + Y_offset
    CMP $1E               ; Compare top vs player bottom ($1E)
    BCS loc_03C367        ; top ≥ player_bottom → no overlap
    STA $02               ; Store top to DP $02
    LDA $0007, X          ; Load height from metasprite+7
    AND #$00FF            ; Mask to byte
    CLC                   ; CLC
    ADC $02               ; bottom = top + height
    CMP $1C               ; Compare bottom vs player top ($1C)
    BCC loc_03C367        ; bottom < player_top → no overlap
    JSR $&ApplyInteractionDamage ; Overlap! JSR ApplyInteractionDamage — handle NPC interaction
    PLB                   ; Restore data bank (friendly mode single-hit exit)
    PLP                   ; Restore processor flags
    RTL                   ; RTL — exit after first friendly interaction hit
}

---------------------------------------------
; Apply damage or interaction effect when player contacts an actor.
; 
; If the target has $0020 flag (NPC/friendly), routes to InteractionDamage_NPCChat for dialogue handling.
; 
; For combat actors: computes the interaction hitbox center (with H-mirror), loads enemy attack power from stats table offset 1. Damage = max(1, enemyAtk − playerDef). Subtracts from playerHp (clamped to 0). Sets $0080 (iframe) flag, assigns 60-frame ($003C) iframe counter.
; 
; If playerFlags bits 11|12 ($1800) are clear (not in special state): spawns HitStaggerMain ($2400 priority), copies extendedFlags $0020 to the stagger actor, masks joypad ($0F00), computes knockback direction via CalcKnockbackFromActorCenters.
; 
; Plays character-form-specific hit sound: Freedan/Shadow = #08, Will = #07.

ApplyInteractionDamage {
    LDA $0010, Y          ; Load target actor flags ($0010,Y) for NPC check
    BIT #$0020            ; Bit 5 ($0020) = friendly/NPC actor
    BEQ loc_03C3EB        ; NPC → route to InteractionDamage_NPCChat
    JMP $&InteractionDamage_NPCChat ; Combat actor: JMP to hitbox center calc path

  loc_03C3EB:
    LDA $000E, Y          ; Load actor sprite field ($000E,Y) for H-mirror
    ASL                   ; ASL ×2 to get carry = H-mirror flag
    ASL 
    LDA $0004, X          ; Load hitbox X offset from metasprite+4 (signed byte)
    AND #$00FF            ; Mask to byte
    BIT #$0080            ; Test sign bit
    BEQ loc_03C3FE
    ORA #$FF00

  loc_03C3FE:
    BCS loc_03C413        ; Carry set = mirrored → negated path at loc_03C413
    ADC $0014, Y          ; Non-mirrored: actorX + offset
    STA $00               ; Store to DP $00 (left edge for center calc)
    LDA $0005, X          ; Load width from metasprite+5
    AND #$00FF            ; Mask to byte
    LSR                   ; LSR — half-width for center
    CLC                   ; CLC
    ADC $00               ; center_X = left + half_width
    STA $00               ; Store center X to DP $00
    BRA loc_03C42D        ; Branch to Y center calc

  loc_03C413:
    EOR #$FFFF            ; Mirrored: negate X offset
    INC                   ; INC
    CLC                   ; CLC
    ADC $0014, Y          ; Mirrored: actorX + negated_offset
    STA $00               ; Store to DP $00
    LDA $0005, X          ; Load width
    AND #$00FF            ; Mask to byte
    LSR                   ; Half-width
    EOR #$FFFF            ; Negate half-width
    INC                   ; INC
    CLC                   ; CLC
    ADC $00               ; Mirrored center = right − half_width
    STA $00               ; Store mirrored center X to DP $00

  loc_03C42D:
    LDA $0006, X          ; Load hitbox Y offset from metasprite+6 (signed byte)
    AND #$00FF            ; Mask to byte
    BIT #$0080            ; Test sign bit
    BEQ loc_03C43B
    ORA #$FF00

  loc_03C43B:
    CLC                   ; CLC
    ADC $0016, Y          ; actorY ($0016,Y) + Y_offset = top edge
    STA $02               ; Store to DP $02
    LDA $0007, X          ; Load height from metasprite+7
    AND #$00FF            ; Mask to byte
    LSR                   ; Half-height
    CLC                   ; CLC
    ADC $02               ; center_Y = top + half_height
    STA $02               ; Store center Y to DP $02
    SEP #$20              ; 8-bit for bank switch to $81
    LDA #$81              ; Push $81
    PHA                   ; Pull into DBR for RAM access
    PLB 
    REP #$20              ; 16-bit A for damage math
    STY $08               ; Save target actor Y to DP $08
    TYX                   ; Transfer actor Y→X for stats access
    LDA $statsPtr, X      ; Load statsPtr ($7F0020,X)
    TAY                   ; Transfer to Y for indirect read
    LDA $0001, Y          ; Load enemy attack power from stats[1] (byte, zero-extended)
    AND #$00FF            ; Mask to byte
    SEC                   ; SEC for subtraction
    SBC $playerDef        ; rawDamage = enemyAtk − playerDef ($0ADC)
    BEQ loc_03C46B        ; Zero damage → floor to 1
    BCS loc_03C46E        ; Positive → use calculated damage

  loc_03C46B:
    LDA #$0001            ; Minimum damage = 1

  loc_03C46E:
    EOR #$FFFF            ; Negate damage for HP subtraction
    INC                   ; INC completes negation
    CLC                   ; CLC
    ADC $playerHp         ; playerHp = playerHp ($0ACE) − damage
    BPL loc_03C47B        ; HP positive → store normally
    LDA #$0000            ; Clamp to 0

  loc_03C47B:
    STA $playerHp         ; Store updated HP to playerHp ($0ACE)
    LDA $playerActor      ; Load player actor from $09AA
    TCD                   ; Set DP to player actor for field access
    TAX                   ; TAX — also in X for indexed ops
    LDA #$0080            ; Set bit 7 ($0080) = iframe state in player flags
    TSB $10               ; TSB $10
    LDA #$003C            ; Assign 60-frame ($003C) iframe counter — longer than combat (17)
    STA $iframeCounter, X ; Store to $7F0028,X (player iframe counter)
    LDA $playerFlags      ; Load playerFlags for special state check
    BIT #$1800            ; Bits 11|12 ($1800) = cutscene or overlay state
    BNE loc_03C4C2        ; Either set → skip stagger spawn at loc_03C4C2
    COP [SpawnLastRel] ( @hit_stagger_controller.HitStaggerMain, #00, #00, #$2400 ) ; COP SpawnLastRel: spawn HitStaggerMain ($2400 priority)
    CPY #$1FC0
    BEQ loc_03C4C2
    LDA $extendedFlags, X
    AND #$0020
    PHX                   ; Switch to stagger actor for flag write
    TYX                   ; Copy direction flag to stagger
    STA $extendedFlags, X
    PLX 
    LDA #$0F00
    TSB $joypadMaskStd
    JSR $&CalcKnockbackFromActorCenters
    STA $28               ; Zero stagger velocity X
    STZ $2C               ; Zero stagger velocity Y
    STZ $2E

  loc_03C4C2:
    LDA $characterForm    ; Load characterForm for sound selection
    BEQ loc_03C4CC        ; Form 0 (Will) → play sound #07
    COP [PlaySoundCh2] ( #08 ) ; Non-Will form: COP PlaySoundCh2 sound #08 (Freedan/Shadow hit)
    BRA loc_03C4CF

  loc_03C4CC:
    COP [PlaySoundCh2] ( #07 ) ; Will: COP PlaySoundCh2 sound #07

  loc_03C4CF:
    LDA #$0000            ; Reset direct page to 0
    TCD                   ; CLC — success return
    CLC                   ; RTS to caller
    RTS 
}

---------------------------------------------
; Handle NPC chat interaction — item giving and dialogue display.
; 
; Sets data bank to $81. Attempts to give the item referenced by chatPtr ($7F000A,X) to the player via GiveItemToPlayer. If inventory is full (carry set), shows the overflow message (widestring_01FF02) and returns carry set.
; 
; If the item was given or chatPtr indicates dialogue: loads the chatPtr value. Values ≥ $81 are treated as dialogue script indices; values < $81 are item IDs shown in a dialogue frame. After interaction, converts the NPC actor to NullActorScriptStub (dead stub) by overwriting its entry point and zeroing the frame counter. Sets $0700 in flags to prevent re-interaction.

InteractionDamage_NPCChat {
    TYX                   ; Transfer target actor Y→X for bank switch
    SEP #$20              ; 8-bit for DBR setup
    LDA #$81              ; Push $81 for bank register
    PHA                   ; Pull into DBR
    PLB                   ; 16-bit A for item/dialogue data
    REP #$20
    LDA $chatPtr, X
    JSL $@hud_inventory.GiveItemToPlayer
    BCC loc_03C4F7
    AND #$00FF
    STA $0DB8
    LDY #$&itemget_table_01FD24.widestring_01FF02
    JSL $@dialogue_display.ShowDialogueFrame
    SEC                   ; RTS to caller
    RTS 

  loc_03C4F7:
    LDA $chatPtr, X       ; Load chatPtr again for dialogue path
    CMP #$0081            ; Compare to $0081 — values ≥ $81 are dialogue script indices
    BCS loc_03C50A        ; ≥ $81 → skip item display, go to NPC deactivation at loc_03C50A
    AND #$00FF            ; Mask to byte for item display
    STA $0DB8             ; Store to $0DB8 as dialogue parameter
    JSL $@dialogue_display.ShowDialogueFrame ; JSL ShowDialogueFrame — display item/chat dialogue

  loc_03C50A:
    LDA #$*NullActorScriptStub ; Deactivate NPC: load NullActorScriptStub bank byte
    STA $0002, X          ; Store to actor bank ($0002,X)
    LDA #$&NullActorScriptStub ; Load NullActorScriptStub address
    STA $0000, X          ; Store to actor entry point ($0000,X)
    STZ $0008, X          ; Clear frame counter ($0008,X)
    LDA $0010, X          ; Load actor flags ($0010,X)
    ORA #$0700            ; Set $0700 — disable all interaction and display flags
    STA $0010, X          ; Store updated flags
    SEC                   ; SEC = interaction handled, NPC deactivated
    RTS                   ; RTS
}

---------------------------------------------
; Compute knockback direction from raw actor center positions (not hitbox centers).
; 
; Simpler version of CalcKnockbackDirection: uses actor positions with ±4px adjustment instead of metasprite hitbox center calculation. Compares axis deltas to determine cardinal direction (0=S, 1=N, 2=W, 3=E).
; 
; Returns direction in A. Used by ApplyInteractionDamage for interaction knockback where precise hitbox geometry is not needed.

CalcKnockbackFromActorCenters {
    PHY                   ; Save current Y (stagger actor pointer) to stack
    LDA #$0000            ; Reset DP to 0 for absolute addressing
    TCD                   ; TCD
    LDY $08               ; Load target actor from DP $08 into Y
    LDA $1A               ; Load player interaction box right ($1A)
    SEC                   ; SEC
    SBC #$0004            ; Adjust right edge: subtract 4px for tighter center estimate
    STA $1A               ; Store adjusted right to DP $1A
    SEC                   ; SEC
    SBC $00               ; deltaX = adjusted_player_right − target_center_X ($00)
    BCS loc_03C55B
    EOR #$FFFF
    INC 
    STA $04               ; INC
    LDA $1E
    SEC 
    SBC #$0004            ; SEC
    STA $1E
    SEC 
    SBC $02               ; SEC
    BCS loc_03C555
    EOR #$FFFF            ; Carry clear = player is above target
    INC 
    CMP $04
    BCC loc_03C578        ; Compare |deltaY| vs |deltaX|
    BRA loc_03C582        ; |deltaY| < |deltaX| → X-dominant (E/W) at loc_03C578

  loc_03C555:
    CMP $04               ; Y dominant: compare axis deltas (player below)
    BCS loc_03C587
    BRA loc_03C578

  loc_03C55B:
    STA $04               ; player left: store |deltaX|
    LDA $1E               ; Load bottom
    SEC                   ; SEC
    SBC #$0004            ; Subtract 4px adjustment
    SEC                   ; SEC
    SBC $02               ; deltaY (player left branch)
    BCS loc_03C572
    EOR #$FFFF
    INC 
    CMP $04               ; INC
    BCS loc_03C582
    BRA loc_03C57D

  loc_03C572:
    CMP $04               ; |deltaY| vs |deltaX| (player below, left)
    BCC loc_03C57D
    BRA loc_03C587

  loc_03C578:
    LDY #$0002            ; Return direction 2 (west): load Y=2
    BRA loc_03C58A        ; Branch to return epilogue

  loc_03C57D:
    LDY #$0003            ; Return direction 3 (east): load Y=3
    BRA loc_03C58A        ; Branch to return epilogue

  loc_03C582:
    LDY #$0001            ; Return direction 1 (north): load Y=1
    BRA loc_03C58A        ; Branch to return epilogue

  loc_03C587:
    LDY #$0000            ; Return direction 0 (south): load Y=0

  loc_03C58A:
    PLA                   ; Return epilogue: restore stagger actor from stack → X
    TAX 
    TCD                   ; Restore DP from X (TCD sets DP to actor base)
    TYA                   ; Transfer direction Y→A for return value
    RTS                   ; RTS — return direction in A
}

---------------------------------------------
; Convert a 16-bit damage number to packed BCD digit format for sprite display.
; 
; Input: damage value on stack. Output: packed BCD in A (carry clear = success).
; 
; Values ≥ 1000 ($03E8): returns carry set (overflow — too many digits).
; 
; For values < 1000: extracts hundreds digit via repeated subtraction by 100/500. Switches to 8-bit for tens and ones: repeated subtraction by 50/10. Packs result as: high byte = hundreds digit, bits 7-4 of low byte = tens, bits 3-0 = ones.
; 
; The packed format matches what SpawnAttackTrailEffect expects for rendering individual digit sprites as floating damage numbers.

FormatDamageDigits {
    PHA                   ; Save damage value to stack for processing
    LDY $0000             ; Load current actor entry point to Y (will restore at end)
    STZ $0000             ; Zero the digit accumulator at $0000
    CMP #$03E8            ; Compare damage to 1000 ($03E8)
    BCS loc_03C5F9        ; ≥1000 → overflow, return carry set at loc_03C5F9
    CMP #$01F4            ; Compare to 500 ($01F4)
    BCC loc_03C5AC        ; < 500 → skip 500 subtraction
    SEC                   ; Subtract 500: remainder in A
    SBC #$01F4
    PHA                   ; Set hundreds digit = 5
    LDA #$0005
    STA $0000
    PLA 

  loc_03C5AC:
    CMP #$0064            ; Compare remainder to 100 ($0064)
    BCC loc_03C5BA        ; < 100 → done with hundreds digit
    SEC                   ; Subtract 100
    SBC #$0064
    INC $0000
    BRA loc_03C5AC

  loc_03C5BA:
    PHA                   ; Save tens+ones remainder to stack
    LDA $0000             ; Load hundreds digit, swap bytes (XBA) for high-byte packing
    XBA                   ; Mask to keep only high byte (hundreds in bits 15-8)
    AND #$FF00
    STA $0000
    PLA 
    SEP #$20              ; Compare to 50 ($32)
    CMP #$32              ; < 50 → skip
    BCC loc_03C5D6        ; Subtract 50
    SEC                   ; Save remainder
    SBC #$32              ; Set tens digit = 5
    PHA                   ; Store 5 to low byte of accumulator
    LDA #$05
    STA $0000
    PLA 

  loc_03C5D6:
    CMP #$0A              ; Compare to 10 ($0A)
    BCC loc_03C5E2        ; < 10 → done with tens
    SEC                   ; Subtract 10
    SBC #$0A
    INC $0000
    BRA loc_03C5D6

  loc_03C5E2:
    PHA                   ; Save ones digit to stack (remainder = ones)
    LDA $0000             ; Load tens digit from accumulator
    ASL 
    ASL 
    ASL 
    ASL                   ; ORA with ones (still on stack as $01,S) — pack tens|ones into one byte
    ORA $01, S
    STA $01, S            ; Write packed byte back to stack
    PLA                   ; 16-bit A for final result assembly
    REP #$20
    STA $01, S
    STY $0000             ; Restore actor entry point Y
    PLA                   ; CLC — carry clear = success (damage < 1000)
    CLC                   ; RTS
    RTS 

  loc_03C5F9:
    STY $0000             ; Overflow path: restore actor entry point Y
    PLA                   ; Discard damage value from stack
    SEC                   ; SEC — carry set = overflow (≥1000)
    RTS                   ; RTS
}