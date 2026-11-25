; Shira's Gift shortens Will's shared Psycho Dash / Spin Dash charge by 24 frames.
; Psycho Slider keeps its final speed (one pixel per frame) while the mapped
; Attack button is held. Normal tile collision still applies. If a step is
; blocked without setting solid contact, the unchanged position ends the slide.

?BANK 02

?INCLUDE 'attack_ability_system'
?INCLUDE 'player_character'

!shirasGiftEquippedItem 7E0AC6
!shirasGiftJoypadRaw    7E0660

attack_ability_system.WillAttackDispatch! {
    LDA #$0001
    TSB $playerFlags
    LDA #$0080
    TSB $joypadHeld
    LDA $characterForm
    BEQ loc_02B7F2
    JMP $&FreedanAttackDispatch

  attack_ability_system.loc_02B7F2!:
    LDA $abilityBitmask
    BIT #$0005
    BNE loc_02B7FB
    RTL

  attack_ability_system.loc_02B7FB!:
    COP [LoopStart] ( #28 )
    COP [BranchIfNotPressed] ( #$0081, &code_02B7BD )
    COP [LoopEnd]
    JSR $&SavePlayerPosition
    COP [SpawnListAppend] ( @WillAttackPaletteFX, #00, #00, #$2C00 )
    STY $22
    LDA $shirasGiftEquippedItem
    CMP #$002B
    BEQ ShirasGiftChargeTimer
    LDA #$0078
    BRA StoreWillChargeTimer

  ShirasGiftChargeTimer:
    LDA #$0060

  StoreWillChargeTimer:
    STA $24
    COP [SetEntryHere]
    JSR $&ValidateAttackContinue
    COP [BranchIfNotPressed] ( #$0081, &AttackCleanup )
    DEC $24
    BMI loc_02B829
    RTL

  attack_ability_system.loc_02B829!:
    LDA $abilityBitmask
    BIT #$0004
    BNE loc_02B83D
    COP [SetEntryHere]
    JSR $&ValidateAttackContinue
    COP [BranchIfNotPressed] ( #$0081, &LaunchPsychoDash )
    RTL

  attack_ability_system.loc_02B83D!:
    COP [SetEntryHere]
    JSR $&ValidateAttackContinue
    COP [BranchIfNotPressed] ( #$0081, &LaunchPsychoDash )
    JSR $&CheckAttackChargeable
    BCC loc_02B84E
    RTL

  attack_ability_system.loc_02B84E!:
    COP [BranchIfPressed] ( #$0030, &LaunchSpinDash )
    RTL
}

player_character.RunAttackNS! {
    LDA #$0001
    JSR $&attack_ability_system.LoadAbilityDamageA
    COP [SetPlayerSpriteDirect] ( #04 )
    LDA $playerSpeedNs
    BMI loc_02CC2E
    JSR $&RunAttackFlagSetup
    LDA #$0100
    TRB $10
    COP [StageSpriteFrame] ( #0C )
    COP [AnimOnce]
    STZ $playerSpeedNs
    COP [StageSpriteLoopMoveY] ( #0D, #02, #44 )
    COP [AnimLoop]
    JSR $&ShirasGiftSliderCanExtend
    BCC ShirasGiftSliderFinishSouth

  ShirasGiftSliderMoveSouth:
    LDA $16
    STA $26
    LDA #$0001
    STA $7F002E, X
    COP [WaitByte] ( #00 )
    JSR $&ShirasGiftSliderCanExtend
    BCC ShirasGiftSliderFinishSouth
    LDA $16
    CMP $26
    BNE ShirasGiftSliderMoveSouth

  ShirasGiftSliderFinishSouth:
    COP [StageSpriteFrame] ( #0E )
    COP [AnimOnce]
    JSR $&RunAttackCleanup
    COP [RestoreSavedPtr]

  player_character.loc_02CC2E!:
    JSR $&RunAttackFlagSetup
    COP [SetMoveNegateY] ( #01 )
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    STZ $playerSpeedNs
    LDA #$0100
    TRB $10
    COP [StageSpriteLoopMoveY] ( #10, #02, #44 )
    COP [AnimLoop]
    JSR $&ShirasGiftSliderCanExtend
    BCC ShirasGiftSliderFinishNorth

  ShirasGiftSliderMoveNorth:
    LDA $16
    STA $26
    LDA #$0001
    STA $7F002E, X
    COP [WaitByte] ( #00 )
    JSR $&ShirasGiftSliderCanExtend
    BCC ShirasGiftSliderFinishNorth
    LDA $16
    CMP $26
    BNE ShirasGiftSliderMoveNorth

  ShirasGiftSliderFinishNorth:
    COP [StageSpriteFrame] ( #11 )
    COP [AnimOnce]
    JSR $&RunAttackCleanup
    COP [RestoreSavedPtr]
}

player_character.RunAttackEW! {
    LDA #$0001
    JSR $&attack_ability_system.LoadAbilityDamageA
    COP [SetPlayerSpriteDirect] ( #04 )
    LDA $playerSpeedEw
    BPL loc_02CC84
    JSR $&RunAttackFlagSetup
    COP [SetMoveNegateX] ( #01 )
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    STZ $playerSpeedEw
    LDA #$0100
    TRB $10
    COP [StageSpriteLoopMoveX] ( #13, #02, #44 )
    COP [AnimLoop]
    JSR $&ShirasGiftSliderCanExtend
    BCC ShirasGiftSliderFinishWest

  ShirasGiftSliderMoveWest:
    LDA $14
    STA $26
    LDA #$0001
    STA $7F002C, X
    COP [WaitByte] ( #00 )
    JSR $&ShirasGiftSliderCanExtend
    BCC ShirasGiftSliderFinishWest
    LDA $14
    CMP $26
    BNE ShirasGiftSliderMoveWest

  ShirasGiftSliderFinishWest:
    COP [StageSpriteFrame] ( #14 )
    COP [AnimOnce]
    JSR $&RunAttackCleanup
    COP [RestoreSavedPtr]

  player_character.loc_02CC84!:
    JSR $&RunAttackFlagSetup
    COP [StageSpriteFrame] ( #15 )
    COP [AnimOnce]
    STZ $playerSpeedEw
    LDA #$0100
    TRB $10
    COP [StageSpriteLoopMoveX] ( #16, #02, #44 )
    COP [AnimLoop]
    JSR $&ShirasGiftSliderCanExtend
    BCC ShirasGiftSliderFinishEast

  ShirasGiftSliderMoveEast:
    LDA $14
    STA $26
    LDA #$0001
    STA $7F002C, X
    COP [WaitByte] ( #00 )
    JSR $&ShirasGiftSliderCanExtend
    BCC ShirasGiftSliderFinishEast
    LDA $14
    CMP $26
    BNE ShirasGiftSliderMoveEast

  ShirasGiftSliderFinishEast:
    COP [StageSpriteFrame] ( #17 )
    COP [AnimOnce]
    JSR $&RunAttackCleanup
    COP [RestoreSavedPtr]
}

; Carry set while the gift is equipped, Attack is held, and no wall was hit.
ShirasGiftSliderCanExtend {
    LDA $10
    BIT #$0004
    BNE ShirasGiftSliderStop
    LDA $shirasGiftEquippedItem
    CMP #$002B
    BNE ShirasGiftSliderStop
    LDA $shirasGiftJoypadRaw
    BIT #$0080
    BEQ ShirasGiftSliderStop
    SEC
    RTS

  ShirasGiftSliderStop:
    CLC
    RTS
}
