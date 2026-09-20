; Central enemy death resolution pipeline invoked when any standard field enemy's HP reaches zero (Bank $00, ~360 bytes).
; 
; Assigned as the default OnDeath callback ($7F1004) by ComposeDigits_Continuation during enemy setup; also reached from hit_stagger_controller when an enemy has no saved AI script. Referenced by ~20 enemy actor scripts across Pyramid, Angkor Wat, Sky Garden, Incan Ruins, Great Wall, Mu, and other regions.
; 
; Entry path decrements BCD kill counters ($0AEE/$0AEC) for non-boss enemies, then runs a shared defeat sequence: play death SFX, spawn EnemyDeathFlash, wait, and optionally SetDungeonKillFlag.
; 
; Branches on enemy stats (enemy_stats_table), extended flag $0080 (boss/miniboss), and scene flag $0300 to route gem drops via EnemyGemDropRouter (DarkGemDropSystem) or stat bonuses via EnemyStatBonusReward. Handles field-tile reveal (SpawnFieldRevealEffect when deathActionIdx is set), ClearLowHere for actors with flag $0008, and final Die COP.
---------------------------------------------

?INCLUDE 'cop_handlers_flags'
?INCLUDE 'DarkGemDropSystem'
?INCLUDE 'enemy_clear_reward_table'
?INCLUDE 'enemy_stats_table'
?INCLUDE 'EnemyDeathFlash'
?INCLUDE 'reward_actors'
?INCLUDE 'SpawnFieldRevealEffect'

!sceneCurrent                   0644
!displayModeFlags               09EC
!orbitAngle                     7F0010
!statsPtr                       7F0020
!deathActionIdx                 7F0024
!extendedFlags                  7F002A
!moveScratch1                   7F002C
!moveScratch2                   7F002E

---------------------------------------------

; Main entry for the standard field-enemy death pipeline; reached when an enemy's HP hits zero.
; 
; Expects X = defeated actor index; reads statsPtr and extendedFlags to distinguish normal enemies, stat-table entries, and boss-flag ($0080) actors. Non-boss kills decrement BCD counters $0AEE/$0AEC and stash the remaining count in orbitAngle before falling into the shared defeat sequence. The sequence plays death SFX, spawns EnemyDeathFlash, routes gem drops or stat rewards, and ends with COP Die.

StandardEnemyDefeatHandler {
    LDA $statsPtr, X      ; StandardEnemyDefeatHandler: SED subtract 1 from BCD kill counter at $0AEE
    CMP #$&enemy_stats_table
    BNE loc_00DB96
    JMP $&EnemyDefeatFlashAndDrop

  loc_00DB96:
    LDA $extendedFlags, X
    BIT #$0080
    BNE EnemyDefeatFlashAndDrop
    SED 
    LDA $0AEE
    SEC 
    SBC #$0001
    STA $0AEE
    CLD 
    LDA $0AEC
    DEC 
    STA $0AEC
    STA $orbitAngle, X
}

EnemyDefeatFlashAndDrop {
    LDA #$0000            ; Defeat flash: OR actor $12 bit $1000 for priority boost during death anim
    STA $2C
    STA $2E
    STA $moveScratch1, X
    STA $moveScratch2, X
    COP [PlaySoundCh1] ( #06 )
    COP [SpawnListAppend] ( @EnemyDeathFlash, #00, #00, #$0302 )
    LDA $0012, Y
    ORA #$1000
    STA $0012, Y
    COP [WaitByte] ( #02 )
    LDA $statsPtr, X
    CMP #$&enemy_stats_table
    BNE loc_00DBE9
    JMP $&EnemyDefeatBossCleanup

  loc_00DBE9:
    LDA $extendedFlags, X
    BIT #$0080
    BNE EnemyDefeatBossCleanup
    COP [SetDungeonKillFlag]
    LDA $sceneCurrent
    JSL $@cop_handlers_flags.TestFlag_0300
    BCS loc_00DC03
    LDA $orbitAngle, X
    BEQ code_00DC13

  loc_00DC03:
    LDA $statsPtr, X      ; Dungeon kill flag set; TestFlag_0300 skips gem drop when scene flag set
    TAY 
    LDA $0003, Y
    AND #$00FF
    BEQ code_00DC13
    JMP $&EnemyGemDropRouter

  code_00DC13:
    LDA #$2000
    TSB $10
    LDA $extendedFlags, X
    BIT #$0008
    BEQ loc_00DC23
    COP [ClearSolidHere]

  loc_00DC23:
    LDA $deathActionIdx, X
    BEQ loc_00DC54
    JSL $@cop_handlers_flags.TestFlag_0100
    BCS loc_00DC54
    LDA $deathActionIdx, X
    JSL $@cop_handlers_flags.SetFlag_0100
    COP [SpawnListAppend] ( @SpawnFieldRevealEffect, #00, #00, #$0342 )
    LDA $0012, Y
    ORA #$1000
    STA $0012, Y
    PHX 
    LDA $deathActionIdx, X
    TYX 
    STA $deathActionIdx, X
    PLX 

  loc_00DC54:
    LDA $orbitAngle, X
    BNE loc_00DC5D
    JMP $&EnemyStatBonusReward

  loc_00DC5D:
    COP [Die]
}

EnemyDefeatBossCleanup {
    COP [WaitByte] ( #02 )
    LDA #$2000
    TSB $10
    LDA $extendedFlags, X
    BIT #$0008
    BEQ loc_00DC72
    COP [ClearSolidHere]

  loc_00DC72:
    COP [WaitByte] ( #05 )
    COP [Die]
}
---------------------------------------------

; Gem-type dispatcher called from StandardEnemyDefeatHandler when the enemy's stats byte at offset $03 is nonzero and scene flag $0300 is clear.
; 
; Uses the kill-count value in orbitAngle: two DEC operations select among three DarkGemDropSystem spawn targets (type 1, type 2, or weighted random). Each path spawns a gem actor via SpawnLastRel then jumps back for the remainder of the defeat sequence.

EnemyGemDropRouter {
    DEC                   ; EnemyGemDropRouter: deathActionIdx 3/2/1 selects dark gem spawn variant
    BEQ loc_00DD63
    DEC 
    BEQ loc_00DD6F
    BRA loc_00DD7B

  loc_00DD63:
    COP [SpawnListAppend] ( @DarkGemDropSystem.SpawnDarkGemType1, #00, #00, #$0420 )
    JMP $&code_00DC13

  loc_00DD6F:
    COP [SpawnListAppend] ( @DarkGemDropSystem.DarkGemDropAnimVariantB, #00, #00, #$0420 )
    JMP $&code_00DC13

  loc_00DD7B:
    COP [SpawnListAppend] ( @DarkGemDropSystem.DarkGemDropTierPicker, #00, #00, #$0420 )
    JMP $&code_00DC13
}

EnemyStatBonusReward {
    COP [SetSpritePalette] ( #00 )
    LDY $sceneCurrent
    LDA $&enemy_clear_reward_table, Y
    AND #$00FF
    PHA 
    LDA $sceneCurrent
    JSL $@cop_handlers_flags.TestFlag_0300
    BCS loc_00DDB3
    COP [SetSpritePalette] ( #00 )
    LDA $01, S
    BEQ loc_00DDB3
    LDA #$0080
    TSB $displayModeFlags
    PLA 
    DEC 
    BEQ loc_00DDB6
    DEC 
    BEQ loc_00DDCA
    BRA loc_00DDDE

  loc_00DDB3:
    PLA 
    COP [Die]

  loc_00DDB6:
    COP [SpawnListAppend] ( @reward_actors.e_hp_increase, #00, #00, #$1000 )
    LDA $0012, Y
    ORA #$1000
    STA $0012, Y
    COP [Die]

  loc_00DDCA:
    COP [SpawnListAppend] ( @reward_actors.e_str_increase, #00, #00, #$1000 )
    LDA $0012, Y
    ORA #$1000
    STA $0012, Y
    COP [Die]

  loc_00DDDE:
    COP [SpawnListAppend] ( @reward_actors.e_def_increase, #00, #00, #$1000 )
    LDA $0012, Y
    ORA #$1000
    STA $0012, Y
    COP [Die]
}