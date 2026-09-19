; Collection of stat-reward pickup actor scripts: e_hp_increase, e_str_increase, and e_def_increase.
; 
; Each displays a floating metasprite, runs RewardActorVFX (bob animation, sound #$25, sets scene flag $0300), prints a stat-increase dialog, and dies. Spawned by StandardEnemyDefeatHandler when an enemy_clear_reward_table entry awards a stat boost.
---------------------------------------------

?INCLUDE 'cop_handlers_flags'
?INCLUDE 'table_0EE000'

!sceneCurrent                   0644
!playerActor                    09AA
!displayModeFlags               09EC
!playerMaxHp                    0ACA
!playerHp                       0ACE
!playerDef                      0ADC
!playerStr                      0ADE
!damageFlashTimer               0B22
!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

e_hp_increase {
    COP [SetMetasprite] ( @table_0EE000 )
    COP [SetSpritePalette] ( #00 )
    COP [StageSprAndHitbox] ( #0C )
    COP [CallScript] ( &RewardActorVFX )
    LDA $playerMaxHp
    CLC 
    ADC #$0001
    BVC loc_00E048
    LDA #$0255

  loc_00E048:
    STA $playerMaxHp
    SEC 
    SBC $playerHp
    STA $damageFlashTimer
    COP [PrintDialogString] ( &dialogstring_00E058 )
    COP [Die]
}

dialogstring_00E058 `[DEF][DLY:1][SFX:0]Your HP (Power) [N]has increased! [END]`

e_str_increase {
    COP [SetMetasprite] ( @table_0EE000 )
    COP [SetSpritePalette] ( #00 )
    COP [StageSprAndHitbox] ( #0D )
    COP [CallScript] ( &RewardActorVFX )
    LDA $playerStr
    CLC 
    ADC #$0001
    BVC loc_00E096
    LDA #$0255

  loc_00E096:
    STA $playerStr
    COP [PrintDialogString] ( &dialogstring_00E09F )
    COP [Die]
}

dialogstring_00E09F `[DEF][DLY:1][SFX:0]Your STR (Strength) [N]has increased! [END]`

e_def_increase {
    COP [SetMetasprite] ( @table_0EE000 )
    COP [SetSpritePalette] ( #00 )
    COP [StageSprAndHitbox] ( #0E )
    COP [CallScript] ( &RewardActorVFX )
    LDA $playerDef
    CLC 
    ADC #$0001
    BVC loc_00E0E1
    LDA #$0255

  loc_00E0E1:
    STA $playerDef
    COP [PrintDialogString] ( &dialogstring_00E0EA )
    COP [Die]
}

dialogstring_00E0EA `[DEF][DLY:1][SFX:0]Your DEF (Defense) [N]has increased! [END]`

RewardActorVFX {
    LDA #$6000
    TRB $12
    COP [StageSpriteLoopMoveY] ( #FF, #04, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #FF, #03 )
    COP [AnimLoop]
    LDY $playerActor
    LDA $0014, Y
    STA $moveXAlt, X
    LDA $0016, Y
    SEC 
    SBC #$0008
    STA $moveYAlt, X
    COP [StageMove] ( #FF, #02, #FF )
    COP [TickMove]
    LDA #$2000
    TSB $10
    LDA #$0080
    TRB $displayModeFlags
    COP [PlaySoundCh2] ( #25 )
    LDA $sceneCurrent
    JSL $@cop_handlers_flags.SetFlag_0300
    COP [RestoreSavedPtr]
}