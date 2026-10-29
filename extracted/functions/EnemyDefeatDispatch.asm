; Enemy defeat dispatcher with a kill counter (Bank 0A, 697407-697568). A trimmed variant of StandardEnemyDefeatHandler used as a death callback by three enemies: gw82_fire_bug (SetDeathCallback code_0B8DB9), av6D_dive_bat (code_0AEF2E) and gw8A_sand_fanger (JumpFar), each reaching it with COP JumpFar. $0AEC is the number of enemies left on the map (hex) and $0AEE the same count in BCD (ram_map.txt).
; 
; === FLOW ===
; 
; - $0AEC = 1 (this is the last enemy): clear the ForceDir bits ($6000 of $12), halt movement (StageMoveXY #0, #0 selects the zero chain; moveScratch1 / 2 = $7F002C / $7F002E cleared) and JumpFar into StandardEnemyDefeatHandler, which decrements the counters itself, plays the full defeat and gives the clear reward (EnemyStatBonusReward when the remaining count reaches 0).
; - Otherwise: CallNear EnemyDefeatDispatch_CountKill (below), then SpawnAfterFlags ( @field_reveal_object, #$0020 ), store the remaining count (orbitAngle, saved by the subroutine) in the child's $26 and Die. field_reveal_object treats a nonzero $26 as 'use this enemy's own stats': FieldRevealFromActorStats reads the low two bits of the stat-table byte at +3 of the defeated enemy: 0 = nothing, 1 / 2 / 3 = a gem pickup worth 1 / 2 / 5 gems (item $83 / $84 / $85). So every kill but the last can drop its own gem. The HP / STR / DEF items of field_reveal_object come only from its room-reward tier path, which this caller does not use (the old note said 'Spawn stat gem reveal', and an earlier version of this note called the byte a HP / STR / DEF gem).
; 
; EnemyDefeatDispatch_CountKill (a CallNear subroutine, returns with RestoreSavedPtr): death sound #03 (the standard handler uses #06), BCD decrement of $0AEE, hex decrement of $0AEC stored also in orbitAngle ($7F0010,X) for the spawned actors, halt movement, spawn EnemyDeathFlash (flags $0302), SetDungeonKillFlag (the actor's enemyNum bit in the wramFlags bitfield), $10 |= $2000 (script-driven run path), ClearSolidHere when extendedFlags bit $0008 is set, and the field-reveal bookkeeping: when deathActionIdx ($7F0024) is nonzero and event flag $0100 + idx is not yet set (TestFlag_0100 carry clear), set it and spawn SpawnFieldRevealEffect (flags $0342) with the index copied into the child's deathActionIdx.
; 
; Differences from StandardEnemyDefeatHandler: no boss / stat-table checks (the three callers are ordinary enemies), no WaitByte, no EnemyGemDropRouter call (a field_reveal_object child is spawned instead; it reads the same stat-table byte at +3), and the flash does not get the $12 bit $1000 (the display-filter qualifier that lets an actor run in RunActors_DisplayFiltered; StandardEnemyDefeatHandler sets it on its flash). The old header said it 'decrements ... plays death SFX, spawns death flash, sets dungeon kill flag, optionally clears collision tile' which is right; it did not explain the field_reveal_object spawn or the callers.
; 
; Edge case: the test is for exactly 1. If $0AEC were 0 the counters would wrap to $FFFF / $99 (BCD) and $26 would be nonzero (OQ-I046-4). UNVERIFIED-RUNTIME.
---------------------------------------------

?INCLUDE 'EnemyDeathFlash'
?INCLUDE 'field_reveal_object'
?INCLUDE 'flag_helpers'
?INCLUDE 'SpawnFieldRevealEffect'
?INCLUDE 'StandardEnemyDefeatHandler'

!enemiesRemaining               0AEC
!enemiesRemainingBcd            0AEE
!orbitAngle                     7F0010
!deathActionIdx                 7F0024
!extendedFlags                  7F002A
!moveScratch1                   7F002C
!moveScratch2                   7F002E

---------------------------------------------

; Entry (X = defeated actor). Last enemy ($0AEC = 1): halt and JumpFar to StandardEnemyDefeatHandler. Otherwise run EnemyDefeatDispatch_CountKill, spawn field_reveal_object with the remaining count in $26, and Die.

EnemyDefeatDispatch {
    LDA $enemiesRemaining ; Exactly 1 means the last enemy (a count of 0 would wrap the counters, OQ-I046-4)
    CMP #$0001
    BNE EnemyDefeatDispatch_NotLast
    LDA #$6000            ; Last enemy: clear the ForceDir bits and halt movement (zero chains, delta words cleared)
    TRB $12
    COP [StageMoveXY] ( #00, #00 )
    LDA #$0000
    STA $moveScratch1, X
    STA $moveScratch2, X
    COP [JumpFar] ( @StandardEnemyDefeatHandler ) ; Last enemy: the full standard defeat (it decrements the counters itself)

; Not the last enemy: per-enemy death processing, then the gem pickup child (field_reveal_object), then Die.

  EnemyDefeatDispatch_NotLast:
    COP [CallNear] ( &EnemyDefeatDispatch_CountKill ) ; Not the last: per-enemy death processing as a near subroutine
    COP [SpawnAfterFlags] ( @field_reveal_object, #$0020 ) ; Spawn the gem pickup child (field_reveal_object, flags $0020)
    LDA $orbitAngle, X    ; Remaining count (stored by EnemyDefeatDispatch_CountKill) goes to the child's $26: nonzero selects FieldRevealFromActorStats
    STA $0026, Y
    COP [Die]
}

---------------------------------------------
; Per-enemy death processing (CallNear): sound #03, BCD and hex counter decrements, halt, death flash, kill flag, collision clear, optional field-reveal effect; returns with RestoreSavedPtr.

EnemyDefeatDispatch_CountKill {
    COP [PlaySoundCh1] ( #03 ) ; Death sound #03
    SED                   ; BCD decrement of $0AEE, then hex decrement of $0AEC, also saved in orbitAngle for the caller
    LDA $enemiesRemainingBcd
    SEC 
    SBC #$0001
    STA $enemiesRemainingBcd
    CLD 
    LDA $enemiesRemaining
    DEC 
    STA $enemiesRemaining
    STA $orbitAngle, X
    COP [StageMoveXY] ( #00, #00 ) ; Halt the corpse: zero chains and delta words
    LDA #$0000
    STA $moveScratch1, X
    STA $moveScratch2, X
    COP [SpawnListAppend] ( @EnemyDeathFlash, #00, #00, #$0302 ) ; Spawn the death flash effect (flags $0302)
    COP [SetDungeonKillFlag] ; Set this enemy's kill bit (its enemyNum)
    LDA #$2000            ; Script-driven run path
    TSB $10
    LDA $extendedFlags, X ; extendedFlags bit $0008: the enemy marked solid collision cells, so clear the mark
    BIT #$0008
    BEQ loc_0AA4B8
    COP [ClearSolidHere]

; Field-reveal bookkeeping: skip when deathActionIdx is 0 or its $0100-base event flag is already set; otherwise set it and spawn SpawnFieldRevealEffect with the index.

  loc_0AA4B8:
    LDA $deathActionIdx, X ; Field-reveal index (0 = none): skip when its $0100-base event flag is already set (TestFlag_0100 carry set)
    BEQ loc_0AA4E0
    JSL $@flag_helpers.TestFlag_0100
    BCS loc_0AA4E0
    LDA $deathActionIdx, X ; Mark it triggered and spawn the room-reveal effect (flags $0342) with the index copied into its deathActionIdx
    JSL $@flag_helpers.SetFlag_0100
    COP [SpawnListAppend] ( @SpawnFieldRevealEffect, #00, #00, #$0342 )
    PHX 
    LDA $deathActionIdx, X
    TYX 
    STA $deathActionIdx, X
    PLX 

; Return to the caller of the CallNear subroutine.

  loc_0AA4E0:
    COP [RestoreSavedPtr]
}