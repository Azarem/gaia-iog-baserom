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

?INCLUDE 'game_over_sequence'
?INCLUDE 'GetPlayerFacingDirection'
?INCLUDE 'hit_stagger_controller'
?INCLUDE 'inventory_mgmt'
?INCLUDE 'itemget_table_01FD24'
?INCLUDE 'NullActorScriptStub'
?INCLUDE 'player_transition_handlers'
?INCLUDE 'ShowDialogueFrame'
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
    PHP 
    REP #$20
    LDA $joypadCurrent
    BIT #$8000            ; $8000 = B button (attack/dodge input)
    BEQ loc_03BBB2
    LDY #$0000

  loc_03BB93:
    LDX $0C00, Y
    BEQ loc_03BBB2
    INY 
    INY 
    LDA $0010, X
    BIT #$D460            ; $D460 = death|orb|COP|overlay|pause — skip if any set
    BNE loc_03BB93
    LDA $onDodgeCallback, X
    BEQ loc_03BB93
    STA $0000, X          ; Overwrite actor entry point with dodge callback; clear to prevent re-trigger
    LDA #$0000
    STA $onDodgeCallback, X

  loc_03BBB2:
    PLP 
    RTL 
}

---------------------------------------------
; Check if the player has died and trigger game over sequence.
; 
; Guards: returns immediately if playerFlags bit 5 ($0020) is set (death already processing) or bit 9 ($0200) is set (game over sequence active). If playerHp ($0ACE) is zero and neither guard is set, sets $0200 in playerFlags, overwrites the player actor's entry point to GameOverSequence, and calls StopPlayerOnDeathAssign to halt all movement.

CheckPlayerDeath {
    PHP 
    REP #$20
    LDA $playerFlags
    BIT #$0020            ; $0020 = death sequence already processing
    BNE loc_03BBE2
    BIT #$0200            ; $0200 = game over already active
    BNE loc_03BBE2
    LDA $playerHp
    BNE loc_03BBE2
    LDA #$0200            ; HP zero — set $0200 and assign GameOverSequence to player entry point
    TSB $playerFlags
    LDY $playerActor
    LDA #$&game_over_sequence.GameOverSequence
    STA $0000, Y
    LDA #$*game_over_sequence.GameOverSequence
    STA $0002, Y
    JSL $@StopPlayerOnDeathAssign

  loc_03BBE2:
    PLP 
    RTL 
}

---------------------------------------------
; Entry point for the per-frame combat collision system.
; 
; Saves processor state and data bank. Zeroes enemyHpPending ($09EA) to clear any stale HP display request. Loads the player actor slot from $09AA and checks bit 6 ($0040) of the player's flags — if set (orb/special state), jumps directly to CombatCollision_Exit (no combat during orb). Otherwise falls through to CombatCollision_EnemyLoop.

RunCombatCollision {
    PHP 
    PHB 
    REP #$20
    STZ $enemyHpPending   ; Clear stale HUD HP display request
    LDX $playerActor
    LDA $0010, X
    BIT #$0040            ; $0040 = orb/special state — disables all combat
    BEQ loc_03BC1B
    JMP $&CombatCollision_Exit
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
    BIT #$0080            ; $0080 = hittable flag
    BEQ loc_03BC26
    BIT #$0040            ; $0040 = orb protection on this actor
    BNE loc_03BC26
    LDA $0012, Y
    BIT #$0010            ; $0010 in $12 = damage immunity
    BNE loc_03BC26
    STX $0E
    STY $08
    TYX 
    LDA $iframeCounter, X
    BMI CombatCollision_NextTarget ; Negative iframe = recovery phase → skip
    JSR $&PlayerAttackHitTest
    BRA CombatCollision_NextTarget

  loc_03BC1B:
    LDX #$0000
    STX $0E

  CombatCollision_NextTarget:
    LDX $0E
    STZ $20               ; $20 = 0 for normal combat; nonzero = friendly/interaction mode
    STZ $24

  loc_03BC26:
    LDY $0C00, X
    BNE loc_03BC2E
    JMP $&CombatCollision_Exit

  loc_03BC2E:
    INX 
    INX 
    LDA $0010, Y
    BIT #$0400            ; $0400 = combat-eligible (enemies have this)
    BEQ CombatCollision_EnemyLoop
    BIT #$0140            ; $0140 = dead or orb-protected
    BNE loc_03BC26
    BIT #$0020            ; $0020 = friendly/NPC flag
    BEQ loc_03BC44
    INC $20               ; Set $20 for friendly/interaction hit mode

  loc_03BC44:
    STX $0E
    STY $08
    SEP #$20
    TYX 
    LDA $7F0008, X
    PHA 
    PLB 
    REP #$20
    LDA $metaspritePtr, X
    TAY 
    STA $42
    LDA $000E, X
    ASL                   ; ASL ×2 shifts H-mirror into carry for hitbox flip
    ASL 
    LDA $0004, Y          ; Hitbox X offset from metasprite+4; sign-extend signed byte via AND/BIT/ORA
    AND #$00FF
    BIT #$0080
    BEQ loc_03BC6D
    ORA #$FF00

  loc_03BC6D:
    BCS loc_03BC81
    ADC $0014, X          ; Non-mirrored: left = actorX + offset; right = left + width
    STA $04
    LDA $0005, Y
    AND #$00FF
    CLC 
    ADC $04
    STA $06
    BRA loc_03BC9A

  loc_03BC81:
    EOR #$FFFF            ; Mirrored: negate offset; right = actorX − offset; left = right − width
    INC 
    CLC 
    ADC $0014, X
    STA $06
    LDA $0005, Y
    AND #$00FF
    EOR #$FFFF
    INC 
    CLC 
    ADC $06
    STA $04

  loc_03BC9A:
    LDA $0006, Y          ; Y axis: same sign-extend pattern for metasprite+6 offset and +7 height
    AND #$00FF
    BIT #$0080
    BEQ loc_03BCA8
    ORA #$FF00

  loc_03BCA8:
    CLC 
    ADC $0016, X
    STA $00
    LDA $0007, Y
    AND #$00FF
    CLC 
    ADC $00
    STA $02
    LDX #$0000            ; Reset inner loop — test all actors against this enemy's box

  CombatCollision_InnerLoop:
    LDY $0C00, X
    BNE loc_03BCC4
    JMP $&CombatCollision_NextTarget

  loc_03BCC4:
    INX 
    INX 
    LDA $20
    BNE loc_03BCD4
    LDA $0010, Y
    BIT #$76E0            ; $76E0: skip dead/orb/COP/display/overlay/pause
    BEQ loc_03BCEF
    BRA CombatCollision_InnerLoop

  loc_03BCD4:
    STZ $24
    LDA $0010, Y
    BIT #$74E0            ; $74E0: like $76E0 but allows $0200
    BNE CombatCollision_InnerLoop
    PHX 
    TYX 
    LDA $extendedFlags, X
    BIT #$0010            ; $0010 in extendedFlags = interaction collision enabled
    BNE loc_03BCEC
    PLX 
    BRA CombatCollision_InnerLoop

  loc_03BCEC:
    PLX 
    INC $24               ; Set $24 — marks as interaction/push collision

  loc_03BCEF:
    LDA $0020, Y          ; AABB overlap: signed offsets from $0020–$0023 vs enemy box at $00–$06
    AND #$00FF
    BIT #$0080
    BEQ loc_03BCFD
    ORA #$FF00

  loc_03BCFD:
    SEC 
    SBC $0014, Y
    EOR #$FFFF
    INC 
    CMP $06
    BCS CombatCollision_InnerLoop
    LDA $0021, Y
    AND #$00FF
    BIT #$0080
    BEQ loc_03BD17
    ORA #$FF00

  loc_03BD17:
    CLC 
    ADC $0014, Y
    CMP $04
    BCC CombatCollision_InnerLoop
    LDA $0022, Y
    AND #$00FF
    BIT #$0080
    BEQ loc_03BD2D
    ORA #$FF00

  loc_03BD2D:
    SEC 
    SBC $0016, Y
    EOR #$FFFF
    INC 
    CMP $02
    BCS CombatCollision_InnerLoop
    LDA $0023, Y
    AND #$00FF
    BIT #$0080
    BEQ loc_03BD47
    ORA #$FF00

  loc_03BD47:
    CLC 
    ADC $0016, Y
    CMP $00
    BCS loc_03BD52
    JMP $&CombatCollision_InnerLoop

  loc_03BD52:
    PHX 
    JSR $&EnemyHitPlayerHandler
    PLX 
    JMP $&CombatCollision_InnerLoop
}

CombatCollision_Exit {
    PLB 
    PLP 
    RTL 
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
    SEP #$20
    LDA $7F0008, X
    PHA 
    PLB 
    REP #$20
    LDA $metaspritePtr, X
    TAY 
    STA $42
    LDA $0014, X
    STA $04
    LDA $0016, X
    STA $00
    LDA $0000, Y          ; Attack hitbox: offsets always negative; width/height ×16 via ASL ×4
    ORA #$FF00
    CLC 
    ADC $04
    STA $04
    LDA $0002, Y
    AND #$00FF
    ASL 
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $04
    STA $06
    LDA $0001, Y
    ORA #$FF00
    CLC 
    ADC $00
    STA $00
    LDA $0003, Y
    AND #$00FF
    ASL 
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $00
    STA $02
    LDX #$0000

  code_03BDAF:
    LDY $0C00, X
    BNE loc_03BDB7
    JMP $&PlayerAttackHitTest_End

  loc_03BDB7:
    INX 
    INX 
    LDA $0010, Y
    BIT #$36F0            ; $36F0: skip friendly/dead/orb/COP/display
    BNE code_03BDAF
    LDA $0020, Y          ; AABB overlap: same edge-comparison pattern as CombatCollision_InnerLoop
    AND #$00FF
    BIT #$0080
    BEQ loc_03BDCF
    ORA #$FF00

  loc_03BDCF:
    SEC 
    SBC $0014, Y
    EOR #$FFFF
    INC 
    CMP $06
    BCS code_03BDAF
    LDA $0021, Y
    AND #$00FF
    BIT #$0080
    BEQ loc_03BDE9
    ORA #$FF00

  loc_03BDE9:
    CLC 
    ADC $0014, Y
    CMP $04
    BCC code_03BDAF
    LDA $0022, Y
    AND #$00FF
    BIT #$0080
    BEQ loc_03BDFF
    ORA #$FF00

  loc_03BDFF:
    SEC 
    SBC $0016, Y
    EOR #$FFFF
    INC 
    CMP $02
    BCS code_03BDAF
    LDA $0023, Y
    AND #$00FF
    BIT #$0080
    BEQ loc_03BE19
    ORA #$FF00

  loc_03BE19:
    CLC 
    ADC $0016, Y
    CMP $00
    BCS loc_03BE24
    JMP $&code_03BDAF

  loc_03BE24:
    TYX 
    LDA $08
    TAX 
    LDA $chainDamage, X   ; chainDamage ($7F101E) accumulates across consecutive hits in one attack
    LSR                   ; damage = chainDamage/2 + 1; halved each hit for diminishing returns
    TYX 
    STA $chainDamage, X
    INC 
    PHA 
    EOR #$FFFF
    INC 
    CLC 
    ADC $currentHp, X
    BPL loc_03BE42
    LDA #$0000            ; Clamp HP to 0

  loc_03BE42:
    STA $currentHp, X
    STA $0AE2
    PHX 
    LDA $statsPtr, X
    TAX 
    LDA $810000, X        ; Max HP from stats table byte 0 (long $81xxxx)
    STA $0AE0
    PLX 
    TXA                   ; TCD — set DP to target actor for field-relative access
    TCD 
    LDA $12
    BIT #$0020            ; $0020 in $12 = boss — skip damage display
    BNE loc_03BE76
    PLA 
    JSR $&FormatDamageDigits
    BCS loc_03BE77
    PHA 
    COP [SpawnLastRel] ( @SpawnAttackTrailEffect, #00, #00, #$2F00 )
    PLA 
    STA $0028, Y
    BRA loc_03BE77

  loc_03BE76:
    PLA 

  loc_03BE77:
    LDA #$0080            ; $0080 = iframe state
    TSB $10
    LDA $playerFlags
    BIT #$0010
    BNE loc_03BE8B
    LDA $12               ; $0010 in $12 = stagger-immune
    BIT #$0010
    BEQ loc_03BEBE

  loc_03BE8B:
    LDA $0AE2
    BNE loc_03BEEE
    LDA #$0040            ; $0040 = dead; check onDeathCallback ($7F1004) else StandardEnemyDefeatHandler
    TSB $10
    LDA $onDeathCallback, X
    BEQ loc_03BEAB
    STA $00
    LDA $7F1006, X
    STA $02
    STZ $08
    STZ $2C
    STZ $2E
    BRA loc_03BF08

  loc_03BEAB:
    LDA #$*StandardEnemyDefeatHandler
    STA $02
    LDA #$&StandardEnemyDefeatHandler
    STA $00
    STZ $08
    LDA #$0400            ; $0400 = standard defeat flag
    TSB $10
    BRA loc_03BF08

  loc_03BEBE:
    COP [SpawnLastRel] ( @hit_stagger_controller.HitStaggerMain, #00, #00, #$2000 ) ; Spawn HitStaggerMain; copy direction flag; CalcKnockbackDirection
    LDA #$0000
    STA $002C, Y
    STA $002E, Y
    LDA $extendedFlags, X
    AND #$0020
    PHX 
    TYX 
    STA $extendedFlags, X
    PLX 
    PHY 
    PHD 
    JSR $&CalcKnockbackDirection
    BCC loc_03BEE7
    COP [GetPlayerFacing]

  loc_03BEE7:
    PLD 
    PLY 
    STA $0028, Y
    TDC 
    TAX 

  loc_03BEEE:
    LDA $12
    BIT #$0001            ; $0001 in $12: set = recovery iframe ($FFEF), clear = invincibility ($0011)
    BEQ loc_03BEFE
    LDA #$FFEF
    STA $iframeCounter, X
    BRA loc_03BF05

  loc_03BEFE:
    LDA #$0011
    STA $iframeCounter, X

  loc_03BF05:
    COP [PlaySoundCh1] ( #05 ) ; Hit sound #05

  loc_03BF08:
    LDA $12
    BIT #$0020
    BNE PlayerAttackHitTest_End
    SEP #$20
    LDA $0AE0             ; Max HP → $09E4/$09EA; current HP → $09E6 for HUD
    STA $enemyHpDisplay
    STA $enemyHpPending
    LDA $0AE2
    STA $09E6
    REP #$20
}

PlayerAttackHitTest_End {
    LDA #$0000            ; Reset DP to 0
    TCD 
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
    SEP #$20
    LDA #$81
    PHA 
    PLB 
    REP #$20
    LDA $24               ; $24 nonzero = interaction/push path; zero = combat damage
    BEQ loc_03BF86
    STZ $24
    TYX 
    LDA $scratch1010+6, X ; Custom interaction handler from scratch1010+6 ($7F1016)
    BEQ loc_03BF40
    STA $0000, X          ; Overwrite entry point with custom handler
    RTS 

  loc_03BF40:
    TXA 
    PHD 
    TCD 
    LDA #$&player_transition_handlers ; Default: player_transition_handlers with $0040 death/transition flag
    STA $00
    LDA #$*player_transition_handlers
    STA $02
    LDA #$0040
    TSB $10
    PLD 
    JSL $@GetPlayerFacingDirection
    PEA $&EnemyHitPlayer_Epilogue-1 ; PEA epilogue−1 for RTS-trick directional knockback dispatch
    BCC loc_03BF5D
    RTS 

  loc_03BF5D:
    AND #$000F
    BNE loc_03BF69
    LDA #$FFFC            ; Knockback velocity ±4 by cardinal direction (0=N, 1=S, 2=E, 3=W)
    STA $extVelocityY
    RTS 

  loc_03BF69:
    DEC 
    BNE loc_03BF73
    LDA #$0004
    STA $extVelocityY
    RTS 

  loc_03BF73:
    DEC 
    BNE loc_03BF7D
    LDA #$0004
    STA $extVelocityX
    RTS 

  loc_03BF7D:
    LDA #$FFFC
    STA $extVelocityX
    RTS 
}

EnemyHitPlayer_Epilogue {
    TXY 
    RTS 

  loc_03BF86:
    TYX 
    STX $3E
    LDA $0010, X
    BIT #$0010            ; $0010 = invincible → route to InvinciblePlayerHit
    BEQ loc_03BF94
    JMP $&InvinciblePlayerHit

  loc_03BF94:
    STZ $20               ; totalStr = playerStr + bonus($09E2) + climbStateData
    LDA $08
    CMP #$1000
    BEQ loc_03BFA2
    LDA $09E2
    STA $20

  loc_03BFA2:
    LDA $characterForm
    STA $08
    LDA $playerStr
    CLC 
    ADC $20
    CLC 
    ADC $climbStateData
    STA $20
    TXA 
    TCD 
    LDA $statsPtr, X
    TAY 
    LDA $0000, Y
    AND #$00FF
    STA $0AE0
    LDA $0002, Y
    AND #$00FF
    SEC 
    SBC $0020             ; rawDamage = enemyAtk(stats[2]) − totalStr; min 1
    EOR #$FFFF
    INC 
    CMP #$0001
    BPL loc_03BFD9
    LDA #$0001

  loc_03BFD9:
    CLC 
    ADC $0008             ; netDamage = rawDamage + chainDamage($08)
    STA $chainDamage, X
    PHA 
    EOR #$FFFF
    INC 
    CLC 
    ADC $currentHp, X
    BPL loc_03BFF0
    LDA #$0000            ; Clamp HP to 0

  loc_03BFF0:
    STA $currentHp, X
    STA $0AE2
    LDA $12
    BIT #$0020
    BNE loc_03C01D
    PLA 
    JSR $&FormatDamageDigits
    BCS loc_03C01E
    PHA 
    COP [SpawnLastRel] ( @SpawnAttackTrailEffect, #00, #00, #$2B00 ) ; Spawn damage number at $2B00 priority; set $1000 display flag
    LDA $0012, Y
    ORA #$1000
    STA $0012, Y
    PLA 
    STA $0028, Y
    BRA loc_03C01E

  loc_03C01D:
    PLA 

  loc_03C01E:
    LDA #$0080            ; $0080 = iframe state
    TSB $10
    LDA $playerFlags
    BIT #$0010
    BNE loc_03C032
    LDA $12
    BIT #$0010
    BEQ loc_03C065

  loc_03C032:
    LDA $0AE2
    BNE loc_03C097
    LDA #$0040            ; $0040 = dead; onDeathCallback or StandardEnemyDefeatHandler
    TSB $10
    LDA $onDeathCallback, X
    BEQ loc_03C052
    STA $00
    LDA $7F1006, X
    STA $02
    STZ $08
    STZ $2C
    STZ $2E
    BRA loc_03C0C8

  loc_03C052:
    LDA #$*StandardEnemyDefeatHandler
    STA $02
    LDA #$&StandardEnemyDefeatHandler
    STA $00
    STZ $08
    LDA #$0400
    TSB $10
    BRA loc_03C0C8

  loc_03C065:
    TXA 
    TCD 
    COP [SpawnLastRel] ( @hit_stagger_controller.HitStaggerMain, #00, #00, #$2000 ) ; Spawn HitStaggerMain; CalcKnockbackDirection for knockback
    LDA #$0000
    STA $002C, Y
    STA $002E, Y
    LDA $extendedFlags, X
    AND #$0020
    PHX 
    TYX 
    STA $extendedFlags, X
    PLX 
    PHY 
    PHD 
    JSR $&CalcKnockbackDirection
    BCC loc_03C090
    COP [GetPlayerFacing]

  loc_03C090:
    PLD 
    PLY 
    STA $0028, Y
    TDC 
    TAX 

  loc_03C097:
    LDA $onHitCallback, X ; Dispatch and clear onHitCallback ($7F1000)
    BEQ loc_03C0AE
    STA $00
    LDA #$0000
    STA $onHitCallback, X
    LDA $02
    AND #$00FF
    BNE loc_03C0AE
    NOP 

  loc_03C0AE:
    LDA $12
    BIT #$0001
    BEQ loc_03C0BE
    LDA #$FFEF
    STA $iframeCounter, X
    BRA loc_03C0C5

  loc_03C0BE:
    LDA #$0011
    STA $iframeCounter, X

  loc_03C0C5:
    COP [PlaySoundCh1] ( #05 ) ; Hit sound #05

  loc_03C0C8:
    LDA $12
    BIT #$0020
    BNE loc_03C0E2
    SEP #$20
    LDA $0AE0             ; Max/current HP → HUD display registers
    STA $enemyHpDisplay
    STA $enemyHpPending
    LDA $0AE2
    STA $09E6
    REP #$20

  loc_03C0E2:
    LDA #$0000
    TCD 
    LDX $0E
    LDA $0BFE, X          ; $0BFE,X = previous actor in render list (the attacker)
    TAX 
    LDA $extendedFlags, X
    BIT #$0050            ; $0050 in extendedFlags = collision callback trigger
    BEQ loc_03C115
    AND #$FFAF            ; Clear $0050, dispatch onCollideCallback, toggle $6000 in $12
    STA $extendedFlags, X
    LDA $onCollideCallback, X
    BEQ loc_03C10C
    STA $0000, X
    LDA #$0000
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
    TXA 
    TCD 
    LDA $10
    ORA #$0080            ; $0080 = iframe state
    STA $10
    LDA #$FFEF            ; $FFEF = recovery iframe (counts up toward zero)
    STA $iframeCounter, X
    LDA $onHitCallback, X ; Dispatch and clear onHitCallback if present
    BEQ loc_03C13D
    STA $00
    LDA #$0000
    STA $onHitCallback, X
    LDA $02
    AND #$00FF
    BNE loc_03C13D
    NOP 

  loc_03C13D:
    COP [PlaySoundCh1] ( #09 )
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
    LDY $000E
    LDX $0BFE, Y
    CPX $playerActor
    SEC 
    BNE loc_03C14F
    RTS 

  loc_03C14F:
    SEP #$20
    LDA $7F0008, X
    PHA 
    PLB 
    REP #$20
    LDA $000E, X
    ASL                   ; ASL ×2 shifts H-mirror into carry
    ASL 
    LDY $0042
    LDA $0004, Y
    AND #$00FF
    BIT #$0080
    BEQ loc_03C16F
    ORA #$FF00

  loc_03C16F:
    BCS loc_03C188
    CLC 
    ADC $0014, X
    STA $0018
    LDA $0005, Y
    AND #$00FF
    LSR 
    CLC 
    ADC $0018
    STA $0018
    BRA loc_03C1A5

  loc_03C188:
    EOR #$FFFF
    INC 
    CLC 
    ADC $0014, X
    STA $0018
    LDA $0005, Y
    AND #$00FF
    LSR 
    EOR #$FFFF
    INC 
    CLC 
    ADC $0018
    STA $0018

  loc_03C1A5:
    LDA $0006, Y
    AND #$00FF
    BIT #$0080
    BEQ loc_03C1B3
    ORA #$FF00

  loc_03C1B3:
    CLC 
    ADC $0016, X          ; Attacker hitbox center Y
    STA $001C
    LDA $0007, Y
    AND #$00FF
    LSR 
    CLC 
    ADC $001C
    STA $001C
    SEP #$20
    LDA $21
    SEC 
    SBC $20
    REP #$20
    AND #$00FF
    LSR 
    BIT #$0040
    BEQ loc_03C1DD
    ORA #$FF80

  loc_03C1DD:
    CLC 
    ADC $14               ; Defender center X from hitbox fields ($20–$23)
    STA $001A
    SEP #$20
    LDA $23
    SEC 
    SBC $22
    REP #$20
    AND #$00FF
    LSR 
    BIT #$0040
    BEQ loc_03C1F8
    ORA #$FF80

  loc_03C1F8:
    CLC 
    ADC $16               ; Defender center Y
    STA $001E
    LDA #$0000
    TCD 
    LDA $18
    SEC 
    SBC $1A               ; deltaX = attacker − defender center; deltaY likewise
    BCS loc_03C22A
    EOR #$FFFF
    INC 
    STA $08
    LDA $1C
    SEC 
    SBC $1E
    BCS loc_03C222
    EOR #$FFFF
    INC                   ; |deltaY| vs |deltaX| → axis-dominant cardinal direction
    CMP $08
    BCS loc_03C256
    NOP 
    NOP 
    BRA loc_03C24C

  loc_03C222:
    CMP $08
    BCS loc_03C251
    NOP 
    NOP 
    BRA loc_03C24C

  loc_03C22A:
    STA $08
    LDA $1C
    SEC 
    SBC $1E
    BCS loc_03C23F
    EOR #$FFFF
    INC 
    CMP $08
    BCS loc_03C256
    NOP 
    NOP 
    BRA loc_03C247

  loc_03C23F:
    CMP $08
    BCS loc_03C251
    NOP 
    NOP 
    BRA loc_03C247

  loc_03C247:
    CLC 
    LDA #$0002            ; Direction 2 = west
    RTS 

  loc_03C24C:
    CLC 
    LDA #$0003            ; Direction 3 = east
    RTS 

  loc_03C251:
    CLC 
    LDA #$0001            ; Direction 1 = north
    RTS 

  loc_03C256:
    CLC 
    LDA #$0000            ; Direction 0 = south
    RTS 
}

InteractionCollision_Exit {
    PLB 
    PLP 
    RTL 
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
    PHP 
    PHB 
    REP #$20
    LDY $playerActor
    LDA $0014, Y
    SEC                   ; Interaction box: X ± 4px, Y from (Y−14) to (Y−4)
    SBC #$0004
    STA $18
    CLC 
    ADC #$0008
    STA $1A
    LDA $0016, Y
    SEC 
    SBC #$0004
    STA $1E
    SEC 
    SBC #$000A
    STA $1C
    LDA $0010, Y
    BIT #$2040
    BNE InteractionCollision_Exit
    BIT #$0280
    BEQ loc_03C293
    JMP $&InteractionCollision_FriendlyMode

  loc_03C293:
    LDY #$0000
    STY $0E

  InteractionCollision_LoopBody:
    LDY $0E

  loc_03C29A:
    LDX $0C00, Y
    BEQ InteractionCollision_Exit
    INY 
    INY 
    LDA $0010, X
    BIT #$35C0            ; $35C0: skip dead/orb/COP/pause/display
    BNE loc_03C29A
    STY $0E
    SEP #$20
    LDA $7F0008, X
    PHA 
    PLB 
    REP #$20
    TXY 
    LDA $metaspritePtr, X
    TAX 
    LDA $000E, Y
    ASL 
    ASL 
    LDA $0004, X          ; AABB overlap with H-mirror (same pattern as CombatCollision)
    AND #$00FF
    BIT #$0080
    BEQ loc_03C2CE
    ORA #$FF00

  loc_03C2CE:
    BCS loc_03C2E8
    ADC $0014, Y
    CMP $1A
    BCS InteractionCollision_LoopBody
    STA $06
    LDA $0005, X
    AND #$00FF
    CLC 
    ADC $06
    CMP $18
    BCC InteractionCollision_LoopBody
    BRA loc_03C307

  loc_03C2E8:
    EOR #$FFFF
    INC 
    CLC 
    ADC $0014, Y
    CMP $18
    BCC InteractionCollision_LoopBody
    STA $06
    LDA $0005, X
    AND #$00FF
    EOR #$FFFF
    INC 
    CLC 
    ADC $06
    CMP $1A
    BCS InteractionCollision_LoopBody

  loc_03C307:
    LDA $0006, X
    AND #$00FF
    BIT #$0080
    BEQ loc_03C315
    ORA #$FF00

  loc_03C315:
    CLC 
    ADC $0016, Y
    CMP $1E
    BCC loc_03C320
    JMP $&InteractionCollision_LoopBody

  loc_03C320:
    STA $02
    LDA $0007, X
    AND #$00FF
    CLC 
    ADC $02
    CMP $1C
    BCS loc_03C332
    JMP $&InteractionCollision_LoopBody

  loc_03C332:
    PHX 
    TYX 
    LDA $extendedFlags, X
    BIT #$0010            ; $0010 in extendedFlags = interaction callback
    BEQ loc_03C35B
    LDA $onCollideCallback, X
    BEQ loc_03C348
    STA $0000, X          ; Overwrite entry point with onCollideCallback or default smooth_follow_child
    BRA loc_03C354

  loc_03C348:
    LDA #$*smooth_follow_child.loc_00E4FA
    STA $0002, X
    LDA #$&smooth_follow_child.loc_00E4FA
    STA $0000, X

  loc_03C354:
    LDA #$0000
    STA $0008, X
    TXY 

  loc_03C35B:
    PLX 
    JSR $&ApplyInteractionDamage

  loc_03C35F:
    PLB 
    PLP 
    RTL 
}

InteractionCollision_FriendlyMode {
    LDY #$0000
    STY $0E

  loc_03C367:
    LDY $0E

  loc_03C369:
    LDX $0C00, Y
    BEQ loc_03C35F
    INY 
    INY 
    LDA $0010, X
    BIT #$3540            ; $3540: like $35C0 but allows $0020 (friendly NPC)
    BNE loc_03C369
    BIT #$0020            ; $0020 = friendly — REQUIRED in FriendlyMode
    BEQ loc_03C369
    STY $0E
    SEP #$20
    LDA $7F0008, X
    PHA 
    PLB 
    REP #$20
    TXY 
    LDA $metaspritePtr, X
    TAX 
    LDA $0004, X          ; Simplified AABB: no H-mirror for friendly actors
    AND #$00FF
    BIT #$0080
    BEQ loc_03C39D
    ORA #$FF00

  loc_03C39D:
    CLC 
    ADC $0014, Y
    CMP $1A
    BCS loc_03C367
    STA $06
    LDA $0005, X
    AND #$00FF
    CLC 
    ADC $0014, Y
    CMP $18
    BCC loc_03C367
    LDA $0006, X
    AND #$00FF
    BIT #$0080
    BEQ loc_03C3C3
    ORA #$FF00

  loc_03C3C3:
    CLC 
    ADC $0016, Y
    CMP $1E
    BCS loc_03C367
    STA $02
    LDA $0007, X
    AND #$00FF
    CLC 
    ADC $02
    CMP $1C
    BCC loc_03C367
    JSR $&ApplyInteractionDamage ; Single-hit exit — first overlap triggers and returns
    PLB 
    PLP 
    RTL 
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
    LDA $0010, Y
    BIT #$0020            ; $0020 = NPC → InteractionDamage_NPCChat
    BEQ loc_03C3EB
    JMP $&InteractionDamage_NPCChat

  loc_03C3EB:
    LDA $000E, Y
    ASL                   ; Compute interaction hitbox center (with H-mirror)
    ASL 
    LDA $0004, X
    AND #$00FF
    BIT #$0080
    BEQ loc_03C3FE
    ORA #$FF00

  loc_03C3FE:
    BCS loc_03C413
    ADC $0014, Y
    STA $00
    LDA $0005, X
    AND #$00FF
    LSR 
    CLC 
    ADC $00
    STA $00
    BRA loc_03C42D

  loc_03C413:
    EOR #$FFFF
    INC 
    CLC 
    ADC $0014, Y
    STA $00
    LDA $0005, X
    AND #$00FF
    LSR 
    EOR #$FFFF
    INC 
    CLC 
    ADC $00
    STA $00

  loc_03C42D:
    LDA $0006, X
    AND #$00FF
    BIT #$0080
    BEQ loc_03C43B
    ORA #$FF00

  loc_03C43B:
    CLC 
    ADC $0016, Y
    STA $02
    LDA $0007, X
    AND #$00FF
    LSR 
    CLC 
    ADC $02
    STA $02
    SEP #$20
    LDA #$81
    PHA 
    PLB 
    REP #$20
    STY $08
    TYX 
    LDA $statsPtr, X
    TAY 
    LDA $0001, Y
    AND #$00FF
    SEC 
    SBC $playerDef        ; damage = max(1, enemyAtk(stats[1]) − playerDef)
    BEQ loc_03C46B
    BCS loc_03C46E

  loc_03C46B:
    LDA #$0001

  loc_03C46E:
    EOR #$FFFF
    INC 
    CLC 
    ADC $playerHp
    BPL loc_03C47B
    LDA #$0000

  loc_03C47B:
    STA $playerHp
    LDA $playerActor
    TCD 
    TAX 
    LDA #$0080
    TSB $10
    LDA #$003C            ; 60-frame iframe ($003C) — longer than combat's 17
    STA $iframeCounter, X
    LDA $playerFlags
    BIT #$1800
    BNE loc_03C4C2
    COP [SpawnLastRel] ( @hit_stagger_controller.HitStaggerMain, #00, #00, #$2400 ) ; Spawn HitStaggerMain; CalcKnockbackFromActorCenters for knockback
    CPY #$1FC0
    BEQ loc_03C4C2
    LDA $extendedFlags, X
    AND #$0020
    PHX 
    TYX 
    STA $extendedFlags, X
    PLX 
    LDA #$0F00
    TSB $joypadMaskStd
    JSR $&CalcKnockbackFromActorCenters
    STA $28
    STZ $2C
    STZ $2E

  loc_03C4C2:
    LDA $characterForm
    BEQ loc_03C4CC
    COP [PlaySoundCh2] ( #08 ) ; Freedan/Shadow hit #08; Will hit #07
    BRA loc_03C4CF

  loc_03C4CC:
    COP [PlaySoundCh2] ( #07 )

  loc_03C4CF:
    LDA #$0000
    TCD 
    CLC 
    RTS 
}

---------------------------------------------
; Handle NPC chat interaction — item giving and dialogue display.
; 
; Sets data bank to $81. Attempts to give the item referenced by chatPtr ($7F000A,X) to the player via GiveItemToPlayer. If inventory is full (carry set), shows the overflow message (dialogstring_01FF02) and returns carry set.
; 
; If the item was given or chatPtr indicates dialogue: loads the chatPtr value. Values ≥ $81 are treated as dialogue script indices; values < $81 are item IDs shown in a dialogue frame. After interaction, converts the NPC actor to NullActorScriptStub (dead stub) by overwriting its entry point and zeroing the frame counter. Sets $0700 in flags to prevent re-interaction.

InteractionDamage_NPCChat {
    TYX 
    SEP #$20
    LDA #$81
    PHA 
    PLB 
    REP #$20
    LDA $chatPtr, X
    JSL $@inventory_mgmt.GiveItemToPlayer
    BCC loc_03C4F7
    AND #$00FF
    STA $0DB8
    LDY #$&itemget_table_01FD24.dialogstring_01FF02
    JSL $@ShowDialogueFrame
    SEC 
    RTS 

  loc_03C4F7:
    LDA $chatPtr, X
    CMP #$0081            ; ≥ $81 = dialogue script; < $81 = item ID for display
    BCS loc_03C50A
    AND #$00FF
    STA $0DB8
    JSL $@ShowDialogueFrame

  loc_03C50A:
    LDA #$*NullActorScriptStub ; Deactivate: NullActorScriptStub + $0700 prevents re-interaction
    STA $0002, X
    LDA #$&NullActorScriptStub
    STA $0000, X
    STZ $0008, X
    LDA $0010, X
    ORA #$0700
    STA $0010, X
    SEC 
    RTS 
}

---------------------------------------------
; Compute knockback direction from raw actor center positions (not hitbox centers).
; 
; Simpler version of CalcKnockbackDirection: uses actor positions with ±4px adjustment instead of metasprite hitbox center calculation. Compares axis deltas to determine cardinal direction (0=S, 1=N, 2=W, 3=E).
; 
; Returns direction in A. Used by ApplyInteractionDamage for interaction knockback where precise hitbox geometry is not needed.

CalcKnockbackFromActorCenters {
    PHY 
    LDA #$0000
    TCD 
    LDY $08
    LDA $1A
    SEC 
    SBC #$0004            ; ±4px adjustment from interaction box edges for center estimate
    STA $1A
    SEC 
    SBC $00               ; Compare axis deltas → cardinal direction
    BCS loc_03C55B
    EOR #$FFFF
    INC 
    STA $04
    LDA $1E
    SEC 
    SBC #$0004
    STA $1E
    SEC 
    SBC $02
    BCS loc_03C555
    EOR #$FFFF
    INC 
    CMP $04
    BCC loc_03C578
    BRA loc_03C582

  loc_03C555:
    CMP $04
    BCS loc_03C587
    BRA loc_03C578

  loc_03C55B:
    STA $04
    LDA $1E
    SEC 
    SBC #$0004
    SEC 
    SBC $02
    BCS loc_03C572
    EOR #$FFFF
    INC 
    CMP $04
    BCS loc_03C582
    BRA loc_03C57D

  loc_03C572:
    CMP $04
    BCC loc_03C57D
    BRA loc_03C587

  loc_03C578:
    LDY #$0002            ; Direction 2 = west
    BRA loc_03C58A

  loc_03C57D:
    LDY #$0003            ; Direction 3 = east
    BRA loc_03C58A

  loc_03C582:
    LDY #$0001            ; Direction 1 = north
    BRA loc_03C58A

  loc_03C587:
    LDY #$0000            ; Direction 0 = south

  loc_03C58A:
    PLA 
    TAX 
    TCD 
    TYA 
    RTS 
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
    PHA 
    LDY $0000
    STZ $0000
    CMP #$03E8            ; ≥ 1000 ($03E8) → overflow (carry set)
    BCS loc_03C5F9
    CMP #$01F4
    BCC loc_03C5AC
    SEC                   ; Hundreds: subtract 500, then loop-subtract 100
    SBC #$01F4
    PHA 
    LDA #$0005
    STA $0000
    PLA 

  loc_03C5AC:
    CMP #$0064
    BCC loc_03C5BA
    SEC 
    SBC #$0064
    INC $0000
    BRA loc_03C5AC

  loc_03C5BA:
    PHA 
    LDA $0000             ; XBA packs hundreds into high byte
    XBA 
    AND #$FF00
    STA $0000
    PLA 
    SEP #$20              ; Tens: subtract 50 then loop-subtract 10 (8-bit)
    CMP #$32
    BCC loc_03C5D6
    SEC 
    SBC #$32
    PHA 
    LDA #$05
    STA $0000
    PLA 

  loc_03C5D6:
    CMP #$0A
    BCC loc_03C5E2
    SEC 
    SBC #$0A
    INC $0000
    BRA loc_03C5D6

  loc_03C5E2:
    PHA 
    LDA $0000
    ASL 
    ASL 
    ASL 
    ASL 
    ORA $01, S
    STA $01, S
    PLA 
    REP #$20
    STA $01, S
    STY $0000
    PLA                   ; Carry clear = success (packed BCD in A)
    CLC 
    RTS 

  loc_03C5F9:
    STY $0000
    PLA 
    SEC 
    RTS 
}