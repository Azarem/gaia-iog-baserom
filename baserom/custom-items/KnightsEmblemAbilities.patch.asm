; The equipped Knight's Emblem reduces Freedan's shared Dark Flare / Aura Barrier
; charge timer from 100 to 75 frames after the usual initial Attack hold.
; Aura Barrier expands to a 96-unit diameter instead of 64 (roughly 48 vs 32 px
; from Freedan). Holding the mapped Block action at normal expiry sustains the
; orbit for up to 240 more frames. Releasing Block during that extension, taking
; the native early-exit path, or reaching the limit starts the usual shrink.
;
; Like v0.051's Dark Crest, this changes the orbital actor's timer and leaves
; the casting pose, palette cleanup, and return to movement on their own timer.

?BANK 02

?INCLUDE 'attack_ability_system'

!knightsEmblemActiveItem 7E0AC6
!knightsEmblemHeldInput  7E0660

attack_ability_system.FreedanAttackDispatch! {
    LDA $abilityBitmask
    BIT #$0050
    BNE loc_02B876
    RTL

  attack_ability_system.loc_02B876!:
    COP [LoopStart] ( #28 )
    COP [BranchIfNotPressed] ( #$0081, &code_02B7BD )
    COP [LoopEnd]
    JSR $&SavePlayerPosition
    COP [SpawnListAppend] ( @FreedanAttackPaletteFX, #00, #00, #$2C00 )
    STY $22
    LDA $knightsEmblemActiveItem
    CMP #$002C
    BEQ KnightsEmblemChargeTimer
    LDA #$0064
    BRA StoreFreedanChargeTimer

  KnightsEmblemChargeTimer:
    LDA #$004B

  StoreFreedanChargeTimer:
    STA $24
    COP [SetEntryHere]
    JSR $&ValidateAttackContinue
    COP [BranchIfNotPressed] ( #$0081, &AttackCleanup )
    COP [BranchIfPressed] ( #$0030, &AttackCleanup )
    DEC $24
    BMI loc_02B8AA
    RTL

  attack_ability_system.loc_02B8AA!:
    LDA $abilityBitmask
    BIT #$0020
    BNE loc_02B8BE
    COP [SetEntryHere]
    JSR $&ValidateAttackContinue
    COP [BranchIfNotPressed] ( #$0081, &LaunchDarkFriar )
    RTL

  attack_ability_system.loc_02B8BE!:
    COP [SetEntryHere]
    JSR $&ValidateAttackContinue
    COP [BranchIfNotPressed] ( #$0081, &LaunchDarkFriar )
    COP [BranchIfPressed] ( #$0F00, &AttackChargeReturn )
    COP [BranchIfPressed] ( #$0030, &LaunchAuraBarrier )
}

attack_ability_system.AuraOrbitalSpawner! {
    STZ $24
    STZ $26
    LDA #$0000
    STA $orbitDiameter, X
    LDA $0B1E
    BEQ loc_02BA39
    COP [SpawnAfterMarked] ( @AuraProjectileChild, #$0600 )
    INC $24
    COP [SpawnAfterMarked] ( @AuraProjectileChild, #$0600 )
    INC $24

  attack_ability_system.loc_02BA39!:
    COP [SpawnAfterMarked] ( @AuraProjectileChild, #$0600 )
    INC $24
    COP [SpawnAfterMarked] ( @AuraProjectileChild, #$0600 )
    LDA #$00F0
    STA $20
    COP [SetEntryHere]
    LDA $playerFlags
    BIT #$0001
    BNE loc_02BA7D
    LDA $26
    CLC
    ADC #$0002
    AND #$00FF
    STA $26
    STA $orbitAngle, X
    LDA $knightsEmblemActiveItem
    CMP #$002C
    BEQ KnightsEmblemAuraDiameter
    LDA #$0040
    BRA CheckAuraDiameter

  KnightsEmblemAuraDiameter:
    LDA #$0060

  CheckAuraDiameter:
    CMP $orbitDiameter, X
    BCC loc_02BA75
    BEQ loc_02BA75
    LDA $orbitDiameter, X
    INC
    STA $orbitDiameter, X

  attack_ability_system.loc_02BA75!:
    JSR $&UpdateOrbitalPositions
    DEC $20
    BPL AuraOrbitContinue
    ; The timer is negative after normal expiry. Values -1 through -240
    ; permit the bonus, so the last update starts shrink at -241.
    LDA $20
    CMP #$FF10
    BCC loc_02BA7D
    LDA $knightsEmblemActiveItem
    CMP #$002C
    BNE loc_02BA7D
    LDA $knightsEmblemHeldInput
    BIT #$0020
    BEQ loc_02BA7D

  AuraOrbitContinue:
    RTL

  attack_ability_system.loc_02BA7D!:
    LDA $24
    STA $0000
    LDY $06

  attack_ability_system.loc_02BA84!:
    LDA #$&AuraProjectileShrink
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA $0006, Y
    TAY
    DEC $0000
    BPL loc_02BA84
    COP [LoopStart] ( #1E )
    LDA $26
    CLC
    ADC #$0002
    AND #$00FF
    STA $26
    STA $orbitAngle, X
    LDA $orbitDiameter, X
    BEQ loc_02BAB6
    DEC
    STA $orbitDiameter, X

  attack_ability_system.loc_02BAB6!:
    JSR $&UpdateOrbitalPositions
    COP [LoopEnd]
    COP [Die]
}
