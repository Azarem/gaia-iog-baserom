; Standard field-enemy defeat script (Bank 00, 56202-56816). The defeated actor itself runs it (X = D = the victim). Entered in three ways: (1) as the default death script: hit_stagger_controller (HitStaggerResolveHit) and two inline paths in combat_collision set the victim's entry point to StandardEnemyDefeatHandler when its HP reaches zero and it has no onDeathCallback ($7F1004); (2) by COP JumpFar from the own scripts of 13 enemies (pyCC_mystic_ball, pyD2_haunt, awB1_wall_walker, pyDD_mummy_queen, gw83_asp, mu67_vampires, av6E_draco, sg55_viper, sg4D_dynapede, sg4E_nitropede, sg4D_cyber, ir29_castoth, sg51_statue) and from EnemyDefeatDispatch (the last enemy of a scene); (3) ir20_statue and ir26_statue JumpFar straight into EnemyDefeatFlashAndDrop.
; 
; === FLOW ===
; 
; 1. Kill counters (StandardEnemyDefeatHandler). Skipped when statsPtr points at the first enemy_stats_table entry (an EnemyInitBasic actor: HP 1, no stats) or extendedFlags bit $0080 (the boss bit). Otherwise enemiesRemainingBcd ($0AEE) -= 1 in decimal mode, enemiesRemaining ($0AEC) -= 1 in hex, and the new count is also kept in orbitAngle ($7F0010,X): 0 means this was the last enemy on the map.
; 2. Flash (EnemyDefeatFlashAndDrop). Movement is halted ($2C / $2E and moveScratch1 / 2 := 0), SFX #06 plays on channel 1 and EnemyDeathFlash is spawned at the enemy (flags $0302; bit $0002 draws it in front of every actor). The flash gets $12 bit $1000 (CopyActorState clears it) so that it keeps running in display-filter actor mode, then WaitByte #02 (3 ticks).
; 3. No-stats and boss actors go to EnemyDefeatBossCleanup: WaitByte #02 (3 ticks), hide ($10 |= $2000), ClearSolidHere if extendedFlags $0008, WaitByte #05 (6 ticks), Die. They get no kill flag, gem drop or reward.
; 4. Other enemies: SetDungeonKillFlag (the enemyNum bit in wramFlags, so the enemy stays dead on re-entry), then the gem decision, hide ($10 |= $2000), ClearSolidHere if extendedFlags $0008, the field reveal, and finally Die when enemies remain or EnemyStatBonusReward when this was the last one.
;    Gem decision: TestFlag_0300 (event flag $0300 + scene = this scene's clear reward was already claimed) set, or orbitAngle nonzero (enemies remain): drop a gem when the stats byte +3 (gemDropType) is nonzero, through EnemyGemDropRouter. Last enemy with the reward still unclaimed: no gem, the stat reward replaces it.
;    Field reveal: deathActionIdx ($7F0024,X) nonzero and event flag $0100 + idx still clear: set it and spawn SpawnFieldRevealEffect (flags $0342, with $12 $1000), handing it the index.
; 5. EnemyStatBonusReward (last enemy only): enemy_clear_reward_table[scene] selects the pickup (0 none, 1 HP, 2 STR, 3 or more DEF) unless the scene flag $0300 is already set. It sets displayModeFlags $0080 (display-filter actor mode: only actors with $12 $1000 run, so the world freezes while the pickup plays), spawns reward_actors.e_hp_increase / e_str_increase / e_def_increase (flags $1000, $12 $1000) and Dies. RewardActorVFX sets the scene flag later (see reward_actors).
; 
; === CORRECTIONS ===
; 
; The old header said ComposeDigitSprites_AtCursor assigns this as the OnDeath callback during enemy setup (no code there references it; the engine falls back to it when $7F1004 is empty), that it is about 360 bytes (it spans about 614), that it calls ClearLowHere (the COP is ClearSolidHere) and that the $12 $1000 write is a 'priority boost'. The comment on the first block said the gem drop is skipped when scene flag $0300 is set; it is the opposite: gems drop when the flag is set or enemies remain. EnemyDropSystem.asm repeated the inverted condition (corrected there). The 'about 20 enemy actor scripts' were 13 JumpFar sites, EnemyDefeatDispatch, 2 statues and 3 engine sites.
---------------------------------------------

?INCLUDE 'enemy_clear_reward_table'
?INCLUDE 'enemy_stats_table'
?INCLUDE 'EnemyDeathFlash'
?INCLUDE 'EnemyDropSystem'
?INCLUDE 'flag_helpers'
?INCLUDE 'reward_actors'
?INCLUDE 'SpawnFieldRevealEffect'

!sceneCurrent                   0644
!displayModeFlags               09EC
!enemiesRemaining               0AEC
!enemiesRemainingBcd            0AEE
!orbitAngle                     7F0010
!statsPtr                       7F0020
!deathActionIdx                 7F0024
!extendedFlags                  7F002A
!moveScratch1                   7F002C
!moveScratch2                   7F002E

---------------------------------------------

; Entry (X = the defeated actor). A statsPtr equal to the first enemy_stats_table entry (EnemyInitBasic enemies) jumps to EnemyDefeatFlashAndDrop without counting; so does a boss bit ($0080) in extendedFlags. Otherwise it counts the kill in decimal ($0AEE) and in hex ($0AEC, also stored in orbitAngle: remaining enemies, 0 = last) and falls into EnemyDefeatFlashAndDrop.

StandardEnemyDefeatHandler {
    LDA $statsPtr, X      ; statsPtr = first enemy_stats_table entry: an EnemyInitBasic actor (HP 1, no stats), not counted
    CMP #$&enemy_stats_table
    BNE DefeatCountKill
    JMP $&EnemyDefeatFlashAndDrop

; Not a no-stats actor: the boss bit ($0080 of extendedFlags) skips the counters, otherwise decrement the BCD and hex counters.

  DefeatCountKill:
    LDA $extendedFlags, X
    BIT #$0080            ; extendedFlags $0080 = boss bit: not counted
    BNE EnemyDefeatFlashAndDrop
    SED                   ; Decimal mode: enemiesRemainingBcd -= 1
    LDA $enemiesRemainingBcd
    SEC 
    SBC #$0001
    STA $enemiesRemainingBcd
    CLD 
    LDA $enemiesRemaining ; Hex count -= 1
    DEC 
    STA $enemiesRemaining
    STA $orbitAngle, X    ; Remaining enemies after this kill (0 = the last one)
}

---------------------------------------------
; Common start of the defeat (also entered directly by ir20_statue and ir26_statue and by the fall-through above): stop the actor, SFX #06, spawn EnemyDeathFlash, WaitByte #02 (3 ticks), then boss / no-stats actors go to EnemyDefeatBossCleanup and the rest continue with the kill flag and the gem decision. orbitAngle is meaningful only on the counted path.

EnemyDefeatFlashAndDrop {
    LDA #$0000            ; Halt movement: $2C / $2E and moveScratch1 / 2 := 0
    STA $2C
    STA $2E
    STA $moveScratch1, X
    STA $moveScratch2, X
    COP [PlaySoundCh1] ( #06 ) ; Death SFX #06 on channel 1
    COP [SpawnListAppend] ( @EnemyDeathFlash, #00, #00, #$0302 ) ; Flash at the enemy; flags $0302 (bit $0002 = in front of every actor); Y = child
    LDA $0012, Y          ; Child $12 |= $1000 (CopyActorState cleared it): the flash keeps running in display-filter mode
    ORA #$1000
    STA $0012, Y
    COP [WaitByte] ( #02 ) ; WaitByte #02 = 3 ticks
    LDA $statsPtr, X
    CMP #$&enemy_stats_table
    BNE DefeatKillFlagAndGem
    JMP $&EnemyDefeatBossCleanup ; No-stats actor: no kill flag, drop or reward

; Boss-bit test again after the wait; then SetDungeonKillFlag and the gem decision (TestFlag_0300 and orbitAngle).

  DefeatKillFlagAndGem:
    LDA $extendedFlags, X
    BIT #$0080
    BNE EnemyDefeatBossCleanup
    COP [SetDungeonKillFlag] ; Set this enemy's bit in wramFlags (it stays dead on re-entry)
    LDA $sceneCurrent
    JSL $@flag_helpers.TestFlag_0300 ; Carry set = this scene's clear reward was already claimed
    BCS DefeatGemPath     ; Claimed: gems may drop
    LDA $orbitAngle, X    ; Unclaimed: no gem for the last enemy (the stat reward replaces it)
    BEQ DefeatHideAndRelease

; Gem path: the stats byte +3 (gemDropType) of the actor's enemy_stats_table entry; zero skips the gem, otherwise EnemyGemDropRouter spawns it and returns to DefeatHideAndRelease.

  DefeatGemPath:
    LDA $statsPtr, X
    TAY 
    LDA $0003, Y          ; Stats byte +3 = gemDropType (0 = no gem)
    AND #$00FF
    BEQ DefeatHideAndRelease
    JMP $&EnemyGemDropRouter

; Common tail of the counted path (also the return point of EnemyGemDropRouter): hide the enemy ($10 |= $2000; the flash shows the effect) and free its solid tile when extendedFlags $0008 is set.

  DefeatHideAndRelease:
    LDA #$2000            ; Hide the enemy ($2000); the flash child shows the effect
    TSB $10
    LDA $extendedFlags, X
    BIT #$0008            ; extendedFlags $0008: the actor made its tile solid
    BEQ DefeatFieldReveal
    COP [ClearSolidHere]

; Field reveal: when deathActionIdx is nonzero and event flag $0100 + idx is clear, set the flag and spawn SpawnFieldRevealEffect (flags $0342, $12 $1000), passing the index to the child.

  DefeatFieldReveal:
    LDA $deathActionIdx, X ; deathActionIdx: field-reveal index (0 = none)
    BEQ DefeatDieOrReward
    JSL $@flag_helpers.TestFlag_0100 ; Carry set = reveal flag $0100 + idx already set
    BCS DefeatDieOrReward
    LDA $deathActionIdx, X
    JSL $@flag_helpers.SetFlag_0100 ; Mark it revealed
    COP [SpawnListAppend] ( @SpawnFieldRevealEffect, #00, #00, #$0342 ) ; Reveal effect, flags $0342; Y = child
    LDA $0012, Y          ; Child $12 |= $1000
    ORA #$1000
    STA $0012, Y
    PHX 
    LDA $deathActionIdx, X ; Copy the index into the child's deathActionIdx (X = child for the store)
    TYX 
    STA $deathActionIdx, X
    PLX 

; orbitAngle nonzero (enemies remain): Die. Zero (the last enemy): EnemyStatBonusReward.

  DefeatDieOrReward:
    LDA $orbitAngle, X    ; Enemies remain: Die; last enemy: stat reward
    BNE DefeatDieNotLast
    JMP $&EnemyStatBonusReward

; Die for an enemy that was not the last.

  DefeatDieNotLast:
    COP [Die]
}

---------------------------------------------
; Defeat of a boss or no-stats actor: after a 3-tick wait (WaitByte #02, the same length as the flash wait) hide it ($10 |= $2000), free its solid tile when extendedFlags $0008 is set, wait 6 ticks and Die. No counters, kill flag, drop or reward.

EnemyDefeatBossCleanup {
    COP [WaitByte] ( #02 )
    LDA #$2000
    TSB $10
    LDA $extendedFlags, X
    BIT #$0008
    BEQ DefeatBossFinalWait
    COP [ClearSolidHere]

; Final wait (WaitByte #05 = 6 ticks) before Die.

  DefeatBossFinalWait:
    COP [WaitByte] ( #05 ) ; WaitByte #05 = 6 ticks
    COP [Die]
}
---------------------------------------------

; Gem-type dispatcher, reached with A = the stats byte +3 (gemDropType, nonzero) when this scene's reward flag $0300 is set or enemies remain (not, as the old note said, when the flag is clear). Two DEC operations select the spawn: 1 = SpawnDropGem1 (fixed $83), 2 = SpawnDropGem2 (fixed $84), otherwise SpawnDropByHpTier (the weighted picker). Each spawn uses SpawnListAppend with flags $0420 and jumps back to DefeatHideAndRelease.

EnemyGemDropRouter {
    DEC                   ; A = enemy stat byte +3 (gemDropType): 1 = fixed $83 gem, 2 = fixed $84 gem, otherwise the weighted picker
    BEQ GemDropType1
    DEC 
    BEQ GemDropType2
    BRA GemDropTypeOther

; gemDropType 1: SpawnDropGem1, then back to DefeatHideAndRelease.

  GemDropType1:
    COP [SpawnListAppend] ( @EnemyDropSystem.SpawnDropGem1, #00, #00, #$0420 )
    JMP $&DefeatHideAndRelease

; gemDropType 2: SpawnDropGem2, then back to DefeatHideAndRelease.

  GemDropType2:
    COP [SpawnListAppend] ( @EnemyDropSystem.SpawnDropGem2, #00, #00, #$0420 )
    JMP $&DefeatHideAndRelease

; Any other gemDropType: SpawnDropByHpTier, then back to DefeatHideAndRelease.

  GemDropTypeOther:
    COP [SpawnListAppend] ( @EnemyDropSystem.SpawnDropByHpTier, #00, #00, #$0420 )
    JMP $&DefeatHideAndRelease
}

---------------------------------------------
; Clear reward of the last enemy of a scene. Pushes enemy_clear_reward_table[sceneCurrent] (0 none, 1 HP, 2 STR, 3 or more DEF). A set scene flag $0300 (reward already claimed) or a tier of 0 just Dies; otherwise displayModeFlags $0080 is set (display-filter actor mode) and the matching reward_actors pickup is spawned with flags $1000 (and $12 $1000, so it runs in that mode). The actor then Dies.

EnemyStatBonusReward {
    COP [SetSpritePalette] ( #00 ) ; Palette 0 for this actor (repeated below; effect not traced)
    LDY $sceneCurrent     ; Y = scene; the table gives the reward tier
    LDA $&enemy_clear_reward_table, Y
    AND #$00FF
    PHA 
    LDA $sceneCurrent
    JSL $@flag_helpers.TestFlag_0300 ; Carry set = reward already claimed (RewardActorVFX sets the flag)
    BCS RewardNone        ; Claimed: no reward
    COP [SetSpritePalette] ( #00 )
    LDA $01, S            ; Tier 0: no reward
    BEQ RewardNone
    LDA #$0080            ; Display-filter actor mode: only $12 $1000 actors run while the pickup plays
    TSB $displayModeFlags
    PLA 
    DEC                   ; Tier 1 = HP, 2 = STR, otherwise DEF
    BEQ RewardHpPickup
    DEC 
    BEQ RewardStrPickup
    BRA RewardDefPickup

; No reward: drop the pushed tier and Die.

  RewardNone:
    PLA 
    COP [Die]

; Tier 1: spawn e_hp_increase (flags $1000, $12 $1000) and Die.

  RewardHpPickup:
    COP [SpawnListAppend] ( @reward_actors.e_hp_increase, #00, #00, #$1000 ) ; HP pickup; flags $1000
    LDA $0012, Y
    ORA #$1000
    STA $0012, Y
    COP [Die]

; Tier 2: spawn e_str_increase (flags $1000, $12 $1000) and Die.

  RewardStrPickup:
    COP [SpawnListAppend] ( @reward_actors.e_str_increase, #00, #00, #$1000 ) ; STR pickup; flags $1000
    LDA $0012, Y
    ORA #$1000
    STA $0012, Y
    COP [Die]

; Tier 3 or more: spawn e_def_increase (flags $1000, $12 $1000) and Die.

  RewardDefPickup:
    COP [SpawnListAppend] ( @reward_actors.e_def_increase, #00, #00, #$1000 ) ; DEF pickup; flags $1000
    LDA $0012, Y
    ORA #$1000
    STA $0012, Y
    COP [Die]
}