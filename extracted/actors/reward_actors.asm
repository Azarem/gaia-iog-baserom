; Stat-reward pickup actors of a cleared Dark Space room (Bank 00, 57389-57683): e_hp_increase, e_str_increase and e_def_increase.
; 
; SPAWN: EnemyStatBonusReward (in StandardEnemyDefeatHandler) runs when the LAST enemy of a scene is defeated (the remaining-enemy counter in orbitAngle is 0). enemy_clear_reward_table[scene] selects the actor: 1 = HP, 2 = STR, 3 or more = DEF, 0 = nothing. The reward is given once per scene: scene flag $0300 + scene (TestFlag_0300) must be clear and RewardActorVFX sets it. Before spawning, EnemyStatBonusReward sets displayModeFlags $0080 (display filter) and spawns the actor with flags $1000; in the display-filtered pass only actors with bit 12 run, so the rest of the world is frozen while the pickup plays.
; 
; EACH ACTOR: sprite frame $0C / $0D / $0E of spriteset_enemies (palette 0), CallNear RewardActorVFX, the stat change, a message and Die.
; RewardActorVFX: clears bits $4000 / $2000 of its $12; animation $FF for 4 passes while rising (Y movement chain #12: -1 px every second tick), 3 more passes standing still, then StageMove (speed 2) / TickMove flies it to the player (target = player X, player Y - 8). Then it sets the hidden bit, clears the display filter (the world runs again), plays sound $25 on channel 2, sets scene flag $0300 + scene (reward taken) and returns to the CallNear caller with RestoreSavedPtr.
; 
; STAT CHANGE: +1 with a signed-overflow check: BVC skips the clamp unless the sum overflows ($7FFF + 1), which cannot happen with these stats, so the clamp value $0255 is never loaded and nothing caps the stats here (the number of cleared rooms does). HP: max HP + 1 and hpToHeal = new max HP - current HP, so the whole missing HP is refilled by UpdateHUD (one HP per 8-frame step with sound $0D). STR and DEF only add 1.
---------------------------------------------

?INCLUDE 'flag_helpers'
?INCLUDE 'spriteset_enemies'

!sceneCurrent                   0644
!playerActor                    09AA
!displayModeFlags               09EC
!playerMaxHp                    0ACA
!playerHp                       0ACE
!playerDef                      0ADC
!playerStr                      0ADE
!hpToHeal                       0B22
!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

e_hp_increase {
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [SetSpritePalette] ( #00 )
    COP [StageSprAndHitbox] ( #0C ) ; Frame $0C (HP icon) with its hitbox
    COP [CallNear] ( &RewardActorVFX ) ; RewardActorVFX: rise, hold, fly to the player, set the scene flag
    LDA $playerMaxHp      ; playerMaxHp + 1, plain binary add; BVC skips the clamp unless $7FFF + 1 overflows, so the $0255 clamp is never reached
    CLC 
    ADC #$0001
    BVC HpIncreaseStore
    LDA #$0255

; Store point of e_hp_increase: max HP := the new value (the BVC skips the $0255 clamp unless the sum overflowed), hpToHeal := new max HP - current HP, print the message and Die.

  HpIncreaseStore:
    STA $playerMaxHp
    SEC                   ; hpToHeal = new max HP - current HP: UpdateHUD refills the whole missing HP, one HP per 8-frame step
    SBC $playerHp
    STA $hpToHeal
    COP [PrintDialogString] ( &dialogstring_00E058 ) ; Message: 'Your HP (Power) has increased!'
    COP [Die]
}

dialogstring_00E058 `[DEF][DLY:1][SFX:0]Your HP (Power) [N]has increased! [END]`

e_str_increase {
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [SetSpritePalette] ( #00 )
    COP [StageSprAndHitbox] ( #0D ) ; Frame $0D (STR icon) with its hitbox
    COP [CallNear] ( &RewardActorVFX )
    LDA $playerStr        ; playerStr + 1, with the same never-reached overflow clamp as HP
    CLC 
    ADC #$0001
    BVC StrIncreaseStore
    LDA #$0255

; Store point of e_str_increase: STR := the new value (the BVC skips the $0255 clamp unless the sum overflowed), print 'Your STR (Strength) has increased!' and Die.

  StrIncreaseStore:
    STA $playerStr
    COP [PrintDialogString] ( &dialogstring_00E09F ) ; Message: 'Your STR (Strength) has increased!'
    COP [Die]
}

dialogstring_00E09F `[DEF][DLY:1][SFX:0]Your STR (Strength) [N]has increased! [END]`

e_def_increase {
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [SetSpritePalette] ( #00 )
    COP [StageSprAndHitbox] ( #0E ) ; Frame $0E (DEF icon) with its hitbox
    COP [CallNear] ( &RewardActorVFX )
    LDA $playerDef        ; playerDef + 1, with the same never-reached overflow clamp as HP
    CLC 
    ADC #$0001
    BVC DefIncreaseStore
    LDA #$0255

; Store point of e_def_increase: DEF := the new value (the BVC skips the $0255 clamp unless the sum overflowed), print 'Your DEF (Defense) has increased!' and Die.

  DefIncreaseStore:
    STA $playerDef
    COP [PrintDialogString] ( &dialogstring_00E0EA ) ; Message: 'Your DEF (Defense) has increased!'
    COP [Die]
}

dialogstring_00E0EA `[DEF][DLY:1][SFX:0]Your DEF (Defense) [N]has increased! [END]`

RewardActorVFX {
    LDA #$6000            ; Clear bits $4000 and $2000 of Flags12 (animation / display state)
    TRB $12
    COP [StageSpriteLoopMoveY] ( #FF, #04, #12 ) ; Animation $FF, 4 passes, Y movement chain #12 (-1 px every second tick): the pickup rises
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #FF, #03 ) ; Animation $FF, 3 passes, no movement: it hovers
    COP [AnimLoop]
    LDY $playerActor
    LDA $0014, Y          ; Target = player X and player Y - 8, written to moveXAlt / moveYAlt
    STA $moveXAlt, X
    LDA $0016, Y
    SEC 
    SBC #$0008
    STA $moveYAlt, X
    COP [StageMove] ( #FF, #02, #FF ) ; StageMove: fly to the target at speed 2 (duration cap $FF = none)
    COP [TickMove]
    LDA #$2000            ; Arrived: set the hidden bit
    TSB $10
    LDA #$0080            ; Clear the display filter: the other actors run again
    TRB $displayModeFlags
    COP [PlaySoundCh2] ( #25 ) ; Sound $25 on channel 2
    LDA $sceneCurrent     ; Scene flag $0300 + scene = this scene's clear reward is taken
    JSL $@flag_helpers.SetFlag_0300
    COP [RestoreSavedPtr]
}