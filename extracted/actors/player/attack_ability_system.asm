?BANK 02

?INCLUDE 'ApplyOrbitalOffsetFromRef'
?INCLUDE 'attack_trail_followers'
?INCLUDE 'cop_handlers_actors'
?INCLUDE 'player_character'
?INCLUDE 'table_01D9A7'
?INCLUDE 'table_01D9BF'
?INCLUDE 'table_0EE000'
?INCLUDE 'table_178000'
?INCLUDE 'table_179000'

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
!retPtr1                        7F0004
!orbitAngle                     7F0010
!orbitDiameter                  7F0012
!loopCounter                    7F0014
!moveXAlt                       7F0018
!moveYAlt                       7F001A
!retPtr2                        7F001E
!moveScratch1                   7F002C
!moveScratch2                   7F002E

---------------------------------------------

AttackSystemEntry {
    LDA $playerFlags
    BIT #$0008
    BEQ code_02B7BD
    COP [Die]

  code_02B7BD:
    LDA #$0001
    TRB $playerFlags
    COP [SetEntryContinue]
    LDA $playerFlags
    BIT #$2A00
    BEQ loc_02B7CE
    RTL 

  loc_02B7CE:
    LDA $characterForm
    CMP #$0002
    BCC loc_02B7D7
    RTL 

  loc_02B7D7:
    COP [BranchIfButton] ( #$8001, &WillAttackDispatch )
    RTL 
}

WillAttackDispatch {
    LDA #$0001
    TSB $playerFlags
    LDA #$8000
    TSB $joypadHeld
    LDA $characterForm
    BEQ loc_02B7F2
    JMP $&FreedanAttackDispatch

  loc_02B7F2:
    LDA $abilityBitmask
    BIT #$0005
    BNE loc_02B7FB
    RTL 

  loc_02B7FB:
    COP [LoopInit] ( #28 )
    COP [BranchIfNoButton] ( #$8001, &code_02B7BD )
    COP [LoopNext]
    JSR $&SavePlayerPosition
    COP [SpawnLastRel] ( @WillAttackPaletteFX, #00, #00, #$2C00 )
    STY $22
    LDA #$0078
    STA $24
    COP [SetEntryContinue]
    JSR $&ValidateAttackContinue
    COP [BranchIfNoButton] ( #$8001, &AttackCleanup )
    DEC $24
    BMI loc_02B829
    RTL 

  loc_02B829:
    LDA $abilityBitmask
    BIT #$0004
    BNE loc_02B83D
    COP [SetEntryContinue]
    JSR $&ValidateAttackContinue
    COP [BranchIfNoButton] ( #$8001, &LaunchPsychoDash )
    RTL 

  loc_02B83D:
    COP [SetEntryContinue]
    JSR $&ValidateAttackContinue
    COP [BranchIfNoButton] ( #$8001, &LaunchPsychoDash )
    JSR $&CheckAttackChargeable
    BCC loc_02B84E
    RTL 

  loc_02B84E:
    COP [BranchIfButton] ( #$0030, &LaunchPsychoSlider )
    RTL 
}

LaunchPsychoDash {
    JSR $&ValidateAttackReady
    LDA #$&PsychoDashMain
    JSR $&SetPlayerActorFunc
    JMP $&AttackCleanup
}

LaunchPsychoSlider {
    JSR $&ValidateAttackReady
    LDA #$&PsychoSliderMain
    JSR $&SetPlayerActorFunc
    JMP $&AttackCleanup
}

FreedanAttackDispatch {
    LDA $abilityBitmask
    BIT #$0050
    BNE loc_02B876
    RTL 

  loc_02B876:
    COP [LoopInit] ( #28 )
    COP [BranchIfNoButton] ( #$8001, &code_02B7BD )
    COP [LoopNext]
    JSR $&SavePlayerPosition
    COP [SpawnLastRel] ( @FreedanAttackPaletteFX, #00, #00, #$2C00 )
    STY $22
    LDA #$0064
    STA $24
    COP [SetEntryContinue]
    JSR $&ValidateAttackContinue
    COP [BranchIfNoButton] ( #$8001, &AttackCleanup )
    COP [BranchIfButton] ( #$40B0, &AttackCleanup )
    DEC $24
    BMI loc_02B8AA
    RTL 

  loc_02B8AA:
    LDA $abilityBitmask
    BIT #$0020
    BNE loc_02B8BE
    COP [SetEntryContinue]
    JSR $&ValidateAttackContinue
    COP [BranchIfNoButton] ( #$8001, &LaunchDarkFriar )
    RTL 

  loc_02B8BE:
    COP [SetEntryContinue]
    JSR $&ValidateAttackContinue
    COP [BranchIfNoButton] ( #$8001, &LaunchDarkFriar )
    COP [BranchIfButton] ( #$0F00, &code_02B8D5 )
    COP [BranchIfButton] ( #$0030, &LaunchAuraBarrier )
}

code_02B8D5 {
    RTL 
}

LaunchDarkFriar {
    LDA #$0001
    STA $00EA
    JSR $&ValidateAttackReady
    LDA #$&DarkFriarMain
    JSR $&SetPlayerActorFunc
    BRA AttackCleanup
}

LaunchAuraBarrier {
    LDA $playerSpeedEw
    ORA $playerSpeedNs
    BEQ loc_02B8F0
    RTL 

  loc_02B8F0:
    LDA #$0002
    STA $00EA
    JSR $&ValidateAttackReady
    LDA #$&AuraBarrierMain
    JSR $&SetPlayerActorFunc
    BRA AttackCleanup
}

AttackCleanup {
    PHX 
    PHD 
    LDA $22
    BEQ loc_02B90B
    TCD 
    TAX 
    COP [MarkDeath]

  loc_02B90B:
    PLD 
    PLX 
    LDA $characterForm
    BNE loc_02B91C
    COP [PaletteStart] ( #0B )
    COP [PaletteStep]
    COP [SetEntryExitNow] ( @code_02B7BD )

  loc_02B91C:
    COP [PaletteStart] ( #0C )
    COP [PaletteStep]
    COP [SetEntryExitNow] ( @code_02B7BD )
}

SetPlayerActorFunc {
    LDY $playerActor
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    RTS 
}

ValidateAttackReady {
    LDA $playerFlags
    BIT #$3A00
    BNE loc_02B943
    COP [GetPlayerFacing]
    CMP #$0004
    BCS loc_02B943
    RTS 

  loc_02B943:
    PLA 
    BRA AttackCleanup
}

ValidateAttackContinue {
    LDA $playerFlags
    BIT #$2B00
    BNE loc_02B943
    RTS 
}

SavePlayerPosition {
    LDY $playerActor
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    STA $16
    RTS 
}

CheckAttackChargeable {
    LDA $playerFlags
    BIT #$8000
    BEQ loc_02B967

  loc_02B965:
    SEC 
    RTS 

  loc_02B967:
    LDY $playerActor
    LDA $0028, Y
    BMI loc_02B965
    CMP #$0004
    BCC loc_02B97D
    SEC 
    SBC #$0010
    CMP #$0004
    BCS loc_02B965

  loc_02B97D:
    CLC 
    RTS 
}

AuraBarrierMain {
    LDA #$0200
    TSB $10
    LDA #$0800
    TSB $playerFlags
    COP [SpawnLastRel] ( @AuraVramDmaLoader, #00, #00, #$2600 )
    CPY #$1FC0
    BNE loc_02B99B
    JMP $&AuraBarrierEnd

  loc_02B99B:
    LDA $16
    CMP #$0020
    BNE loc_02B9B4
    COP [SetEntryExit]
    COP [LoopInit] ( #08 )
    LDA $7F0C07
    CMP #$4400
    BNE loc_02B9C0
    COP [LoopNext]
    BRA loc_02B9C0

  loc_02B9B4:
    COP [SetEntryContinue]
    LDA $7F0C07
    CMP #$4400
    BNE loc_02B9C0
    RTL 

  loc_02B9C0:
    COP [CopyPalette] ( @fx_palette_198090, #00, #A9, #07 )
    COP [SetPlayerBodySprite] ( #06 )
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @AuraBarrierPaletteFX, #00, #00, #$2400 )
    TYA 
    STA $orbitDiameter, X
    COP [StageSpriteLoop] ( #03, #02 )
    COP [AnimLoop]
    LDA #$0001
    TRB $playerFlags
    COP [SpawnLastRel] ( @AuraOrbitalSpawner, #00, #F0, #$2600 )
    COP [StageSpriteLoop] ( #03, #0A )
    COP [AnimLoop]
    JSR $&KillSpawnedProjectile
}

AuraBarrierEnd {
    LDA #$0200
    TRB $10
    LDA $retPtr1, X
    BEQ loc_02BA09
    COP [RestoreSavedPtr]

  loc_02BA09:
    JMP $&player_character.PlayerIdleEntry
}

AuraVramDmaLoader {
    COP [AdhocVramDma] ( @misc_fx_1CC480, #$4400, #$0600 )
    COP [Die]
}

AuraOrbitalSpawner {
    STZ $24
    STZ $26
    LDA #$0000
    STA $orbitDiameter, X
    LDA $0B1E
    BEQ loc_02BA39
    COP [SpawnMarkedAfter] ( @AuraProjectileChild, #$0600 )
    INC $24
    COP [SpawnMarkedAfter] ( @AuraProjectileChild, #$0600 )
    INC $24

  loc_02BA39:
    COP [SpawnMarkedAfter] ( @AuraProjectileChild, #$0600 )
    INC $24
    COP [SpawnMarkedAfter] ( @AuraProjectileChild, #$0600 )
    LDA #$00F0
    STA $20
    COP [SetEntryContinue]
    LDA $playerFlags
    BIT #$0001
    BNE loc_02BA7D
    LDA $26
    CLC 
    ADC #$0002
    AND #$00FF
    STA $26
    STA $orbitAngle, X
    LDA $orbitDiameter, X
    CMP #$0040
    BCS loc_02BA75
    INC 
    STA $orbitDiameter, X

  loc_02BA75:
    JSR $&UpdateOrbitalPositions
    DEC $20
    BMI loc_02BA7D
    RTL 

  loc_02BA7D:
    LDA $24
    STA $0000
    LDY $06

  loc_02BA84:
    LDA #$&AuraProjectileShrink
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA $0006, Y
    TAY 
    DEC $0000
    BPL loc_02BA84
    COP [LoopInit] ( #1E )
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

  loc_02BAB6:
    JSR $&UpdateOrbitalPositions
    COP [LoopNext]
    COP [Die]
}

UpdateOrbitalPositions {
    PHD 
    LDA #$0080
    STA $0002
    LDA $24
    STA $0000
    LDA $06

  loc_02BACB:
    TCD 
    LDY $playerActor
    JSL $@ApplyOrbitalOffsetFromRef
    LDA $orbitAngle, X
    CLC 
    ADC $0002
    AND #$00FF
    STA $orbitAngle, X
    LDA $0002
    CMP #$0040
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
    LDA $sceneCurrent
    AND #$00FF
    CMP #$00DD
    BNE loc_02BB13
    LDA $0E
    AND #$CFFF
    ORA #$2000
    STA $0E

  loc_02BB13:
    COP [SetMetasprite] ( @table_179000 )
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]

  loc_02BB22:
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    BRA loc_02BB22

  AuraProjectileShrink:
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    LDA #$2000
    TSB $10
    COP [SetEntryContinue]
    RTL 
}

DarkFriarMain {
    LDA #$2000
    TSB $playerFlags
    COP [SpawnLastRel] ( @DarkFriarVramDma, #00, #00, #$2600 )
    CPY #$1FC0
    BNE loc_02BB52
    JMP $&DarkFriarFinish

  loc_02BB52:
    LDA $16
    CMP #$0020
    BNE loc_02BB6B
    COP [SetEntryExit]
    COP [LoopInit] ( #08 )
    LDA $7F0C07
    CMP #$4400
    BNE loc_02BB77
    COP [LoopNext]
    BRA loc_02BB77

  loc_02BB6B:
    COP [SetEntryContinue]
    LDA $7F0C07
    CMP #$4400
    BNE loc_02BB77
    RTL 

  loc_02BB77:
    COP [CopyPalette] ( @fx_palette_198070, #00, #A0, #10 )
    COP [SpawnThinkerParam] ( #4A, @cop_handlers_actors.PaletteResetAndKillThinker )
    COP [GetPlayerFacing]
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &DarkFriarDirTable )
}

DarkFriarDirTable [
  &DarkFriarSouth   ;00
  &DarkFriarNorth   ;01
  &DarkFriarWest   ;02
  &DarkFriarEast   ;03
]

DarkFriarSouth {
    COP [SpawnLastRel] ( @DarkFriarProjectile, #FE, #1A, #$2600 )
    COP [SpawnLastRel] ( @DarkFriarTrailSouth, #FE, #1A, #$2600 )
    COP [StagePlayerSprite] ( #36 )
    COP [AnimOnce]
    BRA DarkFriarFinish
}

DarkFriarNorth {
    COP [SpawnLastRel] ( @DarkFriarProjectile, #00, #C0, #$2600 )
    COP [SpawnLastRel] ( @DarkFriarTrailSouthInit, #00, #C0, #$2600 )
    COP [StagePlayerSprite] ( #37 )
    COP [AnimOnce]
    BRA DarkFriarFinish
}

DarkFriarWest {
    COP [SpawnLastRel] ( @DarkFriarProjectile, #CC, #EA, #$2600 )
    COP [SpawnLastRel] ( @DarkFriarTrailWestInit, #CC, #EA, #$2600 )
    COP [StagePlayerSprite] ( #38 )
    COP [AnimOnce]
    BRA DarkFriarFinish
}

DarkFriarEast {
    COP [SpawnLastRel] ( @DarkFriarProjectile, #34, #EA, #$2600 )
    COP [SpawnLastRel] ( @DarkFriarTrailEastWest, #34, #EA, #$2600 )
    COP [StagePlayerSprite] ( #39 )
    COP [AnimOnce]
}

DarkFriarFinish {
    COP [WaitByte] ( #07 )
    COP [RestoreSavedPtr]
}

DarkFriarVramDma {
    COP [AdhocVramDma] ( @misc_fx_1CC000, #$4400, #$0480 )
    COP [Die]
}

DarkFriarProjectile {
    COP [SetMetasprite] ( @table_178000 )
    JSR $&ComputeParentOffset
    COP [WaitByte] ( #07 )
    JSR $&ApplyParentOffset
    LDA #$2000
    TRB $10
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    COP [Die]
}

DarkFriarTrailSouthInit {
    LDA #$2000
    TSB $12
}

DarkFriarTrailSouth {
    LDA #$0000
    JSR $&LoadAbilityAnimTableB
    COP [SetMetasprite] ( @table_178000 )
    LDA $playerFlags
    BIT #$0080
    BEQ loc_02BC42
    COP [SetSpritePriority] ( #30 )

  loc_02BC42:
    JSR $&ComputeParentOffset
    COP [WaitByte] ( #07 )
    JSR $&ApplyParentOffset
    LDA #$2000
    TRB $10
    LDA $0B1C
    BEQ loc_02BC5D
    COP [OrActorFlags] ( #$0010 )
    COP [SetCollideCallback] ( &DarkFriarOnHit )

  loc_02BC5D:
    COP [StageSpriteLoopMoveY] ( #01, #02, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #02, #03, #03 )
    COP [AnimLoop]
    COP [StageSprAndHitbox] ( #03 )
    COP [StageForceMoveXY] ( #00, #05 )
    BRA loc_02BCCA
}

DarkFriarTrailWestInit {
    LDA #$4000
    TSB $12
}

DarkFriarTrailEastWest {
    LDA #$0000
    JSR $&LoadAbilityAnimTableB
    COP [SetMetasprite] ( @table_178000 )
    LDA $playerFlags
    BIT #$0080
    BEQ loc_02BC8F
    COP [SetSpritePriority] ( #30 )

  loc_02BC8F:
    JSR $&ComputeParentOffset
    COP [WaitByte] ( #07 )
    JSR $&ApplyParentOffset
    LDA #$2000
    TRB $10
    LDA $0B1C
    BEQ loc_02BCAA
    COP [OrActorFlags] ( #$0010 )
    COP [SetCollideCallback] ( &DarkFriarOnHit )

  loc_02BCAA:
    COP [StageSpriteLoopMoveX] ( #01, #02, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #02, #03, #03 )
    COP [AnimLoop]
    COP [StageSprAndHitbox] ( #03 )
    COP [StageForceMoveXY] ( #05, #00 )
    BRA loc_02BCCA

  DarkFriarBounceLoop:
    LDA $10
    BIT #$4000
    BNE loc_02BCEC
    COP [ReloadForceMove]

  loc_02BCCA:
    COP [AnimOneFrame]
    LDA $2A
    BEQ DarkFriarBounceLoop
    LDA $08
    STZ $08
    STA $26

  loc_02BCD6:
    LDA $0B1C
    CMP #$0002
    BNE loc_02BCE4
    COP [BranchIfButton] ( #$8001, &DarkFriarDisableCollide )

  loc_02BCE4:
    COP [SetEntryExit]
    DEC $26
    BPL loc_02BCD6
    BRA loc_02BCCA

  loc_02BCEC:
    COP [Die]
}

DarkFriarDisableCollide {
    COP [SetCollideCallback] ( #$0000 )
}

DarkFriarOnHit {
    COP [SpawnAfterFlags] ( @DarkFriarFragment1, #$0600 )
    COP [SpawnAfterFlags] ( @DarkFriarFragment2, #$0600 )
    COP [SpawnAfterFlags] ( @DarkFriarFragment3, #$0600 )
    LDA #$0000
    BRA DarkFriarFragmentInit
}

DarkFriarFragment1 {
    LDA #$0040
    BRA DarkFriarFragmentInit
}

DarkFriarFragment2 {
    LDA #$0080
    BRA DarkFriarFragmentInit
}

DarkFriarFragment3 {
    LDA #$00C0

  DarkFriarFragmentInit:
    STA $orbitAngle, X
    LDA #$0000
    JSR $&LoadAbilityAnimTableB
    LDA #$0000
    STA $orbitDiameter, X
    LDA $14
    STA $moveXAlt, X
    LDA $16
    STA $moveYAlt, X
    COP [SpawnMarkedAfter] ( @attack_trail_followers.TrailFollowerSprB, #$0600 )
    COP [SpawnMarkedAfter] ( @attack_trail_followers.TrailFollowerSprA, #$0600 )
    LDA #$0001
    STA $7F100E, X
    STA $7F100C, X
    COP [StageSprAndHitbox] ( #04 )

  loc_02BD52:
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_02BD52
    LDA $08
    STZ $08
    STA $26

  loc_02BD5E:
    COP [SetEntryExit]
    SEP #$20
    LDA $orbitAngle, X
    CLC 
    ADC #$02
    STA $orbitAngle, X
    LDA $orbitDiameter, X
    CLC 
    ADC #$04
    STA $orbitDiameter, X
    BCS loc_02BDA8
    REP #$20
    LDA $14
    PHA 
    LDA $16
    PHA 
    LDA $moveXAlt, X
    STA $14
    LDA $moveYAlt, X
    STA $16
    JSL $@ApplyOrbitalOffsetFromRef.code_00F3D3
    PLA 
    SEC 
    SBC $16
    STA $7F100E, X
    PLA 
    SEC 
    SBC $14
    STA $7F100C, X
    DEC $26
    BPL loc_02BD5E
    BRA loc_02BD52

  loc_02BDA8:
    REP #$20
    LDA #$6000
    TRB $12
    LDA $7F100C, X
    EOR #$FFFF
    INC 
    STA $7F100C, X
    LDA $7F100E, X
    EOR #$FFFF
    INC 
    STA $7F100E, X
    BRA loc_02BDD7

  DarkFriarFragmentLoop:
    COP [AnimOneFrame]
    LDA $2A
    BEQ DarkFriarFragmentLoop
    LDA $08
    STZ $08
    STA $26

  loc_02BDD5:
    COP [SetEntryExit]

  loc_02BDD7:
    LDA $7F100C, X
    STA $moveScratch1, X
    LDA $7F100E, X
    STA $moveScratch2, X
    LDA $10
    BIT #$4000
    BNE loc_02BDF4
    DEC $26
    BPL loc_02BDD5
    BRA DarkFriarFragmentLoop

  loc_02BDF4:
    COP [Die]
}
---------------------------------------------

ComputeParentOffset {
    LDY $24
    LDA $14
    SEC 
    SBC $0014, Y
    STA $7F100C, X
    LDA $16
    SEC 
    SBC $0016, Y
    STA $7F100E, X
    RTS 
}

ApplyParentOffset {
    LDY $24
    LDA $0014, Y
    CLC 
    ADC $7F100C, X
    STA $14
    LDA $0016, Y
    CLC 
    ADC $7F100E, X
    STA $16
    RTS 
}

PsychoDashMain {
    LDA #$0000
    JSR $&LoadAbilityAnimTableA
    JSR $&player_character.DisableStatusForAttack
    COP [GetPlayerFacing]
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &PsychoDashDirTable )
}

PsychoDashDirTable [
  &PsychoDashSouth   ;00
  &PsychoDashNorth   ;01
  &PsychoDashWest   ;02
  &PsychoDashEast   ;03
]

PsychoDashSouth {
    COP [SpawnAfter] ( @PsychoDashTrailSouth )
    COP [SetPlayerBodySprite] ( #04 )
    COP [StageSpriteMoveY] ( #04, #36 )
    COP [AnimOnce]
    BRA loc_02BF03
}

PsychoDashNorth {
    COP [SpawnAfter] ( @PsychoDashTrailNorth )
    COP [SetForceNE] ( #01 )
    COP [SetPlayerBodySprite] ( #04 )
    COP [StageSpriteMoveY] ( #05, #36 )
    COP [AnimOnce]
    BRA loc_02BF03
}

PsychoDashWest {
    COP [SpawnAfter] ( @PsychoDashTrailWest )
    COP [SetForceBoth] ( #01 )
    COP [SetPlayerBodySprite] ( #04 )
    COP [StageSpriteMoveX] ( #06, #36 )
    COP [AnimOnce]
    BRA loc_02BF03
}

PsychoDashEast {
    COP [SpawnAfter] ( @PsychoDashTrailEast )
    COP [SetPlayerBodySprite] ( #04 )
    COP [StageSpriteMoveX] ( #07, #36 )
    COP [AnimOnce]

  loc_02BF03:
    JSR $&player_character.RestoreStatusDisplay
    JMP $&player_character.PlayerIdleEntry
}

PsychoDashTrailSouth {
    LDA #$0006
    STA $08
    LDY $04
    LDA $0016, Y
    STA $14
    LDA #$09D0
    STA $16
    COP [SetEntryExit]
    COP [LoopInit] ( #08 )
    LDY $04
    LDA $14
    SEC 
    SBC $0016, Y
    LDY $16
    INC $16
    INC $16
    STA $0000, Y
    LDY $04
    LDA $0016, Y
    STA $14
    COP [LoopNext]
    LDA #$0003
    STA $08
    LDY $04
    LDA #$0000
    STA $002E, Y
    COP [SetEntryExit]
    DEC $16
    DEC $16
    COP [LoopInit] ( #08 )
    LDY $16
    DEC $16
    DEC $16
    PHX 
    LDX $04
    LDA $0000, Y
    STA $moveScratch2, X
    PLX 
    COP [LoopNext]
    COP [SetEntryExit]
    PHX 
    LDX $04
    LDA #$0000
    STA $moveScratch2, X
    PLX 
    COP [Die]
}

PsychoDashTrailNorth {
    LDA #$0006
    STA $08
    LDY $04
    LDA $0016, Y
    STA $14
    LDA #$09D0
    STA $16
    COP [SetEntryExit]
    COP [LoopInit] ( #08 )
    LDY $04
    LDA $0016, Y
    SEC 
    SBC $14
    LDY $16
    INC $16
    INC $16
    STA $0000, Y
    LDY $04
    LDA $0016, Y
    STA $14
    COP [LoopNext]
    LDA #$0003
    STA $08
    LDY $04
    LDA #$0000
    STA $002E, Y
    COP [SetEntryExit]
    DEC $16
    DEC $16
    COP [LoopInit] ( #08 )
    LDY $16
    DEC $16
    DEC $16
    PHX 
    LDX $04
    LDA $0000, Y
    STA $moveScratch2, X
    PLX 
    COP [LoopNext]
    COP [SetEntryExit]
    PHX 
    LDX $04
    LDA #$0000
    STA $moveScratch2, X
    PLX 
    COP [Die]
}

PsychoDashTrailWest {
    LDA #$0006
    STA $08
    LDY $04
    LDA $0014, Y
    STA $14
    LDA #$09D0
    STA $16
    COP [SetEntryExit]
    COP [LoopInit] ( #08 )
    LDY $04
    LDA $0014, Y
    SEC 
    SBC $14
    LDY $16
    INC $16
    INC $16
    STA $0000, Y
    LDY $04
    LDA $0014, Y
    STA $14
    COP [LoopNext]
    LDA #$0003
    STA $08
    LDY $04
    LDA #$0000
    STA $002C, Y
    COP [SetEntryExit]
    DEC $16
    DEC $16
    COP [LoopInit] ( #08 )
    LDY $16
    DEC $16
    DEC $16
    PHX 
    LDX $04
    LDA $0000, Y
    STA $moveScratch1, X
    PLX 
    COP [LoopNext]
    COP [SetEntryExit]
    PHX 
    LDX $04
    LDA #$0000
    STA $moveScratch1, X
    PLX 
    COP [Die]
}

PsychoDashTrailEast {
    LDA #$0006
    STA $08
    LDY $04
    LDA $0014, Y
    STA $14
    LDA #$09D0
    STA $16
    COP [SetEntryExit]
    COP [LoopInit] ( #08 )
    LDY $04
    LDA $14
    SEC 
    SBC $0014, Y
    LDY $16
    INC $16
    INC $16
    STA $0000, Y
    LDY $04
    LDA $0014, Y
    STA $14
    COP [LoopNext]
    LDA #$0003
    STA $08
    LDY $04
    LDA #$0000
    STA $002C, Y
    COP [SetEntryExit]
    DEC $16
    DEC $16
    COP [LoopInit] ( #08 )
    LDY $16
    DEC $16
    DEC $16
    PHX 
    LDX $04
    LDA $0000, Y
    STA $moveScratch1, X
    PLX 
    COP [LoopNext]
    COP [SetEntryExit]
    PHX 
    LDX $04
    LDA #$0000
    STA $moveScratch1, X
    PLX 
    COP [Die]

  PsychoSliderMain:
    LDA #$8000
    TSB $joypadHeld
    LDA #$2002
    TSB $playerFlags
    LDA #$000F
    STA $26
    STA $orbitAngle, X
    COP [SetPlayerBodySprite] ( #04 )
    COP [StageSprAndHitbox] ( #22 )
    LDA #$0000
    STA $7F102E, X

  loc_02C0CB:
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_02C0CB
    STZ $08
    LDA $10
    BIT #$0080
    BEQ loc_02C0DF
    JMP $&PsychoSliderAbort

  loc_02C0DF:
    LDA $26
    BMI loc_02C0FB
    CMP #$000C
    BCC loc_02C0FB
    LSR 
    STA $24
    COP [SetEntryContinue]
    COP [BranchIfNoButton] ( #$8001, &PsychoSliderAbort )
    JSR $&PsychoSliderChargeTick
    DEC $24
    BMI loc_02C0CB
    RTL 

  loc_02C0FB:
    LDA #$0002
    JSR $&LoadAbilityAnimTableA
    LDA #$0100
    TRB $10
    LDA #$0200
    TSB $10
    COP [SpawnLastRel] ( @GuidedProjectileActor, #00, #00, #$0302 )
    TYA 
    STA $orbitDiameter, X
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #1D, #04 )
    COP [AnimLoop]
    JSR $&KillSpawnedProjectile
    PEA $&PsychoSliderRelease-1
    STZ $playerSpeedEw
    STZ $playerSpeedNs
    LDA $joypadCurrent
    BIT #$0100
    BEQ loc_02C145
    LDA #$0007
    STA $playerSpeedEw
    STZ $slopeStepCounter
    STZ $decelStepCounter
    RTS 

  loc_02C145:
    BIT #$0200
    BEQ loc_02C157
    LDA #$FFF9
    STA $playerSpeedEw
    STZ $slopeStepCounter
    STZ $decelStepCounter
    RTS 

  loc_02C157:
    BIT #$0800
    BEQ loc_02C169
    LDA #$FFF9
    STA $playerSpeedNs
    STZ $slopeStepCounter
    STZ $decelStepCounter
    RTS 

  loc_02C169:
    BIT #$0400
    BEQ loc_02C17B
    LDA #$0007
    STA $playerSpeedNs
    STZ $slopeStepCounter
    STZ $decelStepCounter
    RTS 

  loc_02C17B:
    RTS 
}

PsychoSliderRelease {
    LDA #$2800
    TRB $playerFlags
    PEA $&PsychoSliderLaunch-1
    LDA #$&loc_02C1A3
    STA $retPtr2, X
    LDA $0B1A
    BNE loc_02C195
    LDA #$000C
    RTS 

  loc_02C195:
    LDA #$0018
    RTS 
}

PsychoSliderLaunch {
    STA $loopCounter, X
    LDA #$0001
    JSR $&LoadAbilityAnimTableA

  loc_02C1A3:
    COP [StageSpriteFrame] ( #1D )
    COP [AnimOnce]
    COP [LoopNext]
    LDA #$0002
    TRB $playerFlags
    COP [BranchIfButton] ( #$0300, &PsychoSliderDirEW )
    COP [BranchIfButton] ( #$0C00, &PsychoSliderDirNS )
    BRA PsychoSliderAbort
}

PsychoSliderDirEW {
    LDA $joypadCurrent
    BIT #$0200
    BNE loc_02C1CB
    COP [StagePlayerSprite] ( #03 )
    BRA loc_02C1E0

  loc_02C1CB:
    COP [StagePlayerSprite] ( #02 )
    BRA loc_02C1E0
}

PsychoSliderDirNS {
    LDA $joypadCurrent
    BIT #$0800
    BNE loc_02C1DD
    COP [StagePlayerSprite] ( #00 )
    BRA loc_02C1E0

  loc_02C1DD:
    COP [StagePlayerSprite] ( #01 )

  loc_02C1E0:
    COP [AnimOneFrame]
    STZ $08
}

PsychoSliderAbort {
    LDA #$0200
    TRB $10
    COP [RestoreSavedPtr]
}

PsychoSliderChargeTick {
    LDA $26
    LSR 
    BCC loc_02C202
    LDA $joypadCurrent
    BIT #$0020
    BEQ loc_02C212
    LDA $26
    SEC 
    SBC #$0001
    STA $26
    BRA loc_02C212

  loc_02C202:
    LDA $joypadCurrent
    BIT #$0010
    BEQ loc_02C212
    LDA $26
    SEC 
    SBC #$0001
    STA $26

  loc_02C212:
    LDA $joypadCurrent
    AND #$0030
    TSB $joypadHeld
    RTS 
}

KillSpawnedProjectile {
    PHX 
    PHD 
    LDA $orbitDiameter, X
    BEQ loc_02C22F
    TCD 
    TAX 
    LDA #$0000
    STA $orbitDiameter, X
    COP [MarkDeath]

  loc_02C22F:
    PLD 
    PLX 
    RTS 
}

GuidedProjectileActor {
    COP [SetSpritePriority] ( #30 )
    LDA $14
    SEC 
    SBC $playerXPos
    STA $7F100C, X
    LDA $16
    SEC 
    SBC $playerYPos
    STA $7F100E, X
    COP [SetMetasprite] ( @table_0EE000 )

  code_02C24E:
    COP [BranchIfButton] ( #$0100, &ProjectileMoveRight )
    COP [BranchIfButton] ( #$0200, &ProjectileMoveLeft )
    COP [BranchIfButton] ( #$0800, &ProjectileMoveUp )
    COP [BranchIfButton] ( #$0400, &ProjectileMoveDown )
    COP [SetEntryContinue]
    COP [StageSprAndHitbox] ( #39 )

  loc_02C26B:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $2A
    BEQ loc_02C26B
    COP [BranchIfButton] ( #$0F00, &code_02C24E )
    JSR $&RecomputeProjectilePos
    DEC $24
    BMI loc_02C26B
    RTL 
}

ProjectileMoveRight {
    COP [StageSprAndHitbox] ( #3D )

  loc_02C28B:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $2A
    BEQ loc_02C28B
    COP [BranchIfNoButton] ( #$0100, &code_02C24E )
    JSR $&RecomputeProjectilePos
    DEC $24
    BMI loc_02C28B
    RTL 
}

ProjectileMoveLeft {
    COP [StageSprAndHitbox] ( #3C )

  loc_02C2AB:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $2A
    BEQ loc_02C2AB
    COP [BranchIfNoButton] ( #$0200, &code_02C24E )
    JSR $&RecomputeProjectilePos
    DEC $24
    BMI loc_02C2AB
    RTL 
}

ProjectileMoveUp {
    COP [StageSprAndHitbox] ( #3B )

  loc_02C2CB:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $2A
    BEQ loc_02C2CB
    COP [BranchIfNoButton] ( #$0800, &code_02C24E )
    JSR $&RecomputeProjectilePos
    DEC $24
    BMI loc_02C2CB
    RTL 
}

ProjectileMoveDown {
    COP [StageSprAndHitbox] ( #3A )

  loc_02C2EB:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $2A
    BEQ loc_02C2EB
    COP [BranchIfNoButton] ( #$0400, &code_02C24E )
    JSR $&RecomputeProjectilePos
    DEC $24
    BMI loc_02C2EB
    RTL 
}

WillAttackPaletteFX {
    COP [PaletteStartLoop] ( #2A, #02 )
    COP [PaletteStepLoop]

  loc_02C30E:
    COP [PaletteStart] ( #2B )
    COP [PaletteStep]
    BRA loc_02C30E
}

FreedanAttackPaletteFX {
    COP [PaletteStartLoop] ( #4B, #02 )
    COP [PaletteStepLoop]

  loc_02C31B:
    COP [PaletteStart] ( #2C )
    COP [PaletteStep]
    BRA loc_02C31B
}

AuraBarrierPaletteFX {
    COP [PaletteStart] ( #5B )
    COP [PaletteStep]
    BRA AuraBarrierPaletteFX
}

RecomputeProjectilePos {
    LDA $7F100C, X
    CLC 
    ADC $playerXPos
    STA $14
    LDA $7F100E, X
    CLC 
    ADC $playerYPos
    STA $16
    RTS 
}

LoadAbilityAnimTableA {
    PHX 
    ASL 
    TAX 
    LDA $@table_01D9A7, X
    SEC 
    SBC #$&table_01D9A7
    TAX 
    LDA $@table_01D9A7+2, X
    TAY 
    LDA $0000, Y
    PHA 
    TXA 
    CLC 
    ADC $01, S
    TAX 
    PLA 
    LDA $@table_01D9A7+4, X
    AND #$00FF
    STA $climbStateData
    PLX 
    RTS 
}

LoadAbilityAnimTableB {
    PHX 
    ASL 
    TAX 
    LDA $@table_01D9BF, X
    SEC 
    SBC #$&table_01D9BF
    TAX 
    LDA $@table_01D9BF+2, X
    TAY 
    LDA $0000, Y
    PHA 
    TXA 
    CLC 
    ADC $01, S
    TAX 
    PLA 
    LDA $@table_01D9BF+4, X
    AND #$00FF
    STA $09E2
    PLX 
    RTS 
}