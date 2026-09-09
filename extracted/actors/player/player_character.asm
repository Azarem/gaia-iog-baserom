?BANK 02

?INCLUDE 'attack_ability_system'
?INCLUDE 'dark_space_palette'
?INCLUDE 'game_over_sequence'
?INCLUDE 'hardware_math'
?INCLUDE 'player_move_controller'
?INCLUDE 'slope_ramp_physics'
?INCLUDE 'table_17D000'

!invincibilityTimer             040C
!sceneCurrent                   0644
!joypadCurrent                  0656
!joypadHeld                     0658
!joypadMaskStd                  065A
!cameraTargetX                  06BE
!cameraTargetY                  06C2
!layerPriorityFlag              06EE
!playerXPos                     09A2
!playerActor                    09AA
!playerFlags                    09AE
!playerSpeedEw                  09B2
!playerSpeedNs                  09B4
!slopeStepCounter               09B6
!decelStepCounter               09B8
!climbStateData                 09E0
!abilityBitmask                 0AA2
!characterForm                  0AD4
!free101C                       7F101C

---------------------------------------------

PlayerCharacterDef [
  actor-def < #00, #08, #85, {

  code_02C38F:
    LDA #$0100
    TSB $10
    LDA #$0001
    TSB $12
    TXA 
    STA $playerActor
    LDA #$0001
    STA $free101C, X
    LDA $0AF8
    BEQ loc_02C3B0
    COP [SpawnAfterFlags] ( @game_over_sequence.DeathWakeupMessage, #$2000 )

  loc_02C3B0:
    COP [SpawnBefore] ( @attack_ability_system.AttackSystemEntry )
    COP [SpawnAfter] ( @player_move_controller.PlayerMoveController )
    COP [SpawnAfter] ( @slope_ramp_physics.SlopePhysicsEntry )
    COP [SpawnLastRel] ( @dark_space_palette.DarkSpacePaletteInit, #00, #00, #$2800 )
} >
]

PlayerIdleEntry {
    COP [SetEntryContinue]
    LDA $joypadHeld
    AND #$F0FF
    STA $joypadHeld
    LDA #$2800
    TRB $playerFlags
    LDA #$0100
    TSB $10
    LDA #$0020
    TRB $10
    STZ $climbStateData
    LDA $10
    BIT #$2000
    BEQ loc_02C3EE
    RTL 

  loc_02C3EE:
    COP [SetSavedPtr] ( &PlayerIdleEntry )
    COP [SetForceBoth] ( #00 )
    LDA $playerSpeedEw
    BEQ loc_02C3FD
    JMP $&MovingEastWest

  loc_02C3FD:
    LDA $playerSpeedNs
    BEQ loc_02C405
    JMP $&MovingNorthSouth

  loc_02C405:
    PHX 
    COP [GetPlayerFacing]
    AND #$0003
    STA $24
    SEP #$20
    XBA 
    LDA #$0E
    JSL $@hardware_math.SignedMultiply
    REP #$20
    TAX 
    LDA $joypadCurrent
    BIT #$8000
    BNE loc_02C43F
    INX 
    INX 
    XBA 
    LSR 
    BCS loc_02C43F
    INX 
    INX 
    LSR 
    BCS loc_02C43F
    INX 
    INX 
    LSR 
    BCS loc_02C43F
    INX 
    INX 
    LSR 
    BCS loc_02C43F
    INX 
    INX 
    BIT #$0300
    BNE loc_02C43F
    INX 
    INX 

  loc_02C43F:
    LDA $@PlayerIdleDispatchTable, X
    PLX 
    DEC 
    PHA 
    RTS 
}

PlayerIdleDispatchTable [
  &AttackSouth   ;00
  &WalkEast   ;01
  &WalkWest   ;02
  &WalkSouth   ;03
  &WalkNorth   ;04
  &RunSouth   ;05
  &IdleStandSouth   ;06
  &AttackNorth   ;07
  &WalkEast   ;08
  &WalkWest   ;09
  &WalkSouth   ;0A
  &WalkNorth   ;0B
  &RunNorth   ;0C
  &IdleStandNorth   ;0D
  &AttackWest   ;0E
  &WalkEast   ;0F
  &WalkWest   ;10
  &WalkSouth   ;11
  &WalkNorth   ;12
  &RunWest   ;13
  &IdleStandWest   ;14
  &AttackEast   ;15
  &WalkEast   ;16
  &WalkWest   ;17
  &WalkSouth   ;18
  &WalkNorth   ;19
  &RunEast   ;1A
  &IdleStandEast   ;1B
]

IdleStandSouth {
    COP [BranchIfFlagByte] ( #00, #01, &IdleStandSouthShadow )
    COP [StagePlayerSprite] ( #00 )
    BRA loc_02C4BD
}

IdleStandSouthShadow {
    COP [StagePlayerSprite] ( #10 )
    BRA loc_02C4BD
}

IdleStandNorth {
    COP [BranchIfFlagByte] ( #00, #01, &IdleStandNorthShadow )
    COP [StagePlayerSprite] ( #01 )
    BRA loc_02C4BD
}

IdleStandNorthShadow {
    COP [StagePlayerSprite] ( #11 )
    BRA loc_02C4BD
}

IdleStandWest {
    COP [BranchIfFlagByte] ( #00, #01, &IdleStandWestShadow )
    COP [StagePlayerSprite] ( #02 )
    BRA loc_02C4BD
}

IdleStandWestShadow {
    COP [StagePlayerSprite] ( #12 )
    BRA loc_02C4BD
}

IdleStandEast {
    COP [BranchIfFlagByte] ( #00, #01, &IdleStandEastShadow )
    COP [StagePlayerSprite] ( #03 )
    BRA loc_02C4BD
}

IdleStandEastShadow {
    COP [StagePlayerSprite] ( #13 )

  loc_02C4BD:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $playerSpeedEw
    ORA $playerSpeedNs
    BNE code_02C4DB
    COP [BranchIfButton] ( #$8F30, &code_02C4DB )
    DEC $24
    BMI loc_02C4BD
    RTL 
}

code_02C4DB {
    COP [RestoreSavedPtr]
}

WalkSouth {
    LDA $24
    BNE loc_02C4F9
    LDA $invincibilityTimer
    BMI loc_02C4F9
    STZ $invincibilityTimer
    LDA #$0003
    STA $playerSpeedNs
    STZ $slopeStepCounter
    STZ $decelStepCounter
    COP [SetEntryExit]
    COP [RestoreSavedPtr]

  loc_02C4F9:
    COP [StagePlayerSprite] ( #08 )
    JSR $&SetAutoWalkTimer

  loc_02C4FF:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $2A
    BEQ loc_02C4FF
    COP [BranchIfNoButton] ( #$0400, &WalkRestoreSaved )
    JSR $&CheckAttackWhileWalking
    BNE loc_02C51F
    COP [BranchIfButton] ( #$0030, &RunSouth )

  loc_02C51F:
    DEC $24
    BMI loc_02C4FF
    RTL 
}

WalkNorth {
    LDA $24
    DEC 
    BNE loc_02C541
    LDA $invincibilityTimer
    BMI loc_02C541
    STZ $invincibilityTimer
    LDA #$FFFD
    STA $playerSpeedNs
    STZ $slopeStepCounter
    STZ $decelStepCounter
    COP [SetEntryExit]
    COP [RestoreSavedPtr]

  loc_02C541:
    COP [StagePlayerSprite] ( #09 )
    JSR $&SetAutoWalkTimer

  loc_02C547:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $2A
    BEQ loc_02C547
    COP [BranchIfNoButton] ( #$0800, &WalkRestoreSaved )
    JSR $&CheckAttackWhileWalking
    BNE loc_02C567
    COP [BranchIfButton] ( #$0030, &RunNorth )

  loc_02C567:
    DEC $24
    BMI loc_02C547
    RTL 
}

WalkWest {
    LDA $24
    DEC 
    DEC 
    BNE loc_02C58A
    LDA $invincibilityTimer
    BMI loc_02C58A
    STZ $invincibilityTimer
    LDA #$FFFD
    STA $playerSpeedEw
    STZ $slopeStepCounter
    STZ $decelStepCounter
    COP [SetEntryExit]
    COP [RestoreSavedPtr]

  loc_02C58A:
    COP [StagePlayerSprite] ( #0A )
    JSR $&SetAutoWalkTimer

  loc_02C590:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $2A
    BEQ loc_02C590
    COP [BranchIfNoButton] ( #$0200, &WalkRestoreSaved )
    JSR $&CheckAttackWhileWalking
    BNE loc_02C5B0
    COP [BranchIfButton] ( #$0030, &RunWest )

  loc_02C5B0:
    DEC $24
    BMI loc_02C590
    RTL 
}

WalkEast {
    LDA $24
    DEC 
    DEC 
    DEC 
    BNE loc_02C5D4
    LDA $invincibilityTimer
    BMI loc_02C5D4
    STZ $invincibilityTimer
    LDA #$0003
    STA $playerSpeedEw
    STZ $slopeStepCounter
    STZ $decelStepCounter
    COP [SetEntryExit]
    COP [RestoreSavedPtr]

  loc_02C5D4:
    COP [StagePlayerSprite] ( #0B )
    JSR $&SetAutoWalkTimer

  loc_02C5DA:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $2A
    BEQ loc_02C5DA
    COP [BranchIfNoButton] ( #$0100, &WalkRestoreSaved )
    JSR $&CheckAttackWhileWalking
    BNE loc_02C5FA
    COP [BranchIfButton] ( #$0030, &RunEast )

  loc_02C5FA:
    DEC $24
    BMI loc_02C5DA
    RTL 
}

CheckAttackWhileWalking {
    COP [BranchIfButton] ( #$8000, &WalkAbortToIdle )
    LDA $playerSpeedEw
    ORA $playerSpeedNs
    BNE WalkAbortToIdle
    LDA $playerFlags
    BIT #$1000
    RTS 
}

WalkAbortToIdle {
    PLA 
}

WalkRestoreSaved {
    COP [RestoreSavedPtr]
}

SetAutoWalkTimer {
    LDA #$000D
    STA $invincibilityTimer
    RTS 
}

ClimbVineEntry {
    LDA #$0008
    TRB $10
    LDA #$0200
    TSB $10
    LDA #$4000
    TSB $joypadMaskStd
    COP [StagePlayerMoveXY] ( #18, #00, #18 )
    COP [AnimOnce]
    COP [StagePlayerMoveY] ( #19, #07 )
    COP [AnimOnce]

  loc_02C63B:
    COP [BranchIfSolidType] ( #00, &ClimbVineLand )
    COP [StagePlayerSprite] ( #1A )
    COP [StageForceMoveY] ( #07 )

  loc_02C646:
    COP [AnimOneFrame]
    JSR $&CheckClimbFrame
    BCS loc_02C658

  loc_02C64D:
    JSR $&CheckClimbAttack
    COP [SetEntryExit]
    DEC $24
    BPL loc_02C64D
    BRA loc_02C646

  loc_02C658:
    COP [BranchIfSolidType] ( #00, &ClimbVineLand )
    COP [StagePlayerSprite] ( #1B )
    COP [StageForceMoveY] ( #07 )

  loc_02C663:
    COP [AnimOneFrame]
    JSR $&CheckClimbFrame
    BCS loc_02C675

  loc_02C66A:
    JSR $&CheckClimbAttack
    COP [SetEntryExit]
    DEC $24
    BPL loc_02C66A
    BRA loc_02C663

  loc_02C675:
    COP [BranchIfSolidType] ( #00, &ClimbVineLand )
    COP [StagePlayerSprite] ( #19 )
    COP [StageForceMoveY] ( #07 )

  loc_02C680:
    COP [AnimOneFrame]
    JSR $&CheckClimbFrame
    BCS loc_02C63B

  loc_02C687:
    JSR $&CheckClimbAttack
    COP [SetEntryExit]
    DEC $24
    BPL loc_02C687
    BRA loc_02C680
}

ClimbVineLand {
    COP [PlaySoundCh2] ( #2C )
    COP [StagePlayerMoveY] ( #1C, #00 )
    COP [AnimOnce]
    LDA #$0200
    TRB $10
    LDA #$0008
    TSB $10
    LDA #$4000
    TRB $joypadMaskStd
    JMP $&PlayerIdleEntry
}

CheckClimbFrame {
    LDA $2A
    BEQ loc_02C6BA
    LDA $08
    STZ $08
    STA $24
    CLC 
    RTS 

  loc_02C6BA:
    SEC 
    RTS 
}

CheckClimbAttack {
    LDA $characterForm
    CMP #$0001
    BEQ loc_02C6C5
    RTS 

  loc_02C6C5:
    LDA $abilityBitmask
    BIT #$0040
    BNE loc_02C6CE
    RTS 

  loc_02C6CE:
    COP [BranchIfButton] ( #$8000, &ClimbDropAttack )
    RTS 
}

ClimbDropAttack {
    PLA 
    COP [SetPlayerBodySprite] ( #06 )
    COP [StageSprAndHitbox] ( #00 )

  loc_02C6DC:
    COP [StageForceMoveY] ( #07 )

  loc_02C6DF:
    COP [AnimOneFrame]
    JSR $&CheckClimbFrame
    BCS loc_02C6DC

  loc_02C6E6:
    LDA $16
    BIT #$000F
    BNE loc_02C6F2
    COP [BranchIfSolidType] ( #00, &ClimbDropLand )

  loc_02C6F2:
    COP [SetEntryExit]
    DEC $24
    BPL loc_02C6E6
    BRA loc_02C6DF
}

ClimbDropLand {
    LDA #$0002
    JSR $&attack_ability_system.LoadAbilityAnimTableB
    LDA $sceneCurrent
    AND #$00FF
    CMP #$00DD
    BEQ loc_02C714
    COP [SpawnLastRel] ( @ImpactTerrainShake, #00, #00, #$2400 )

  loc_02C714:
    COP [SpawnLastRel] ( @CameraShakeActor, #00, #00, #$2400 )
    LDA #$003C
    STA $0026, Y
    COP [StageSpriteMoveY] ( #01, #00 )
    COP [AnimOnce]
    COP [WaitByte] ( #27 )
    LDA #$0200
    TRB $10
    LDA #$0008
    TSB $10
    LDA #$4000
    TRB $joypadMaskStd
    JMP $&PlayerIdleEntry
}

ImpactTerrainShake {
    LDA #$0010
    TSB $playerFlags
    COP [WaitWord] ( #$01DF )
    LDA #$0010
    TRB $playerFlags
    COP [Die]
}

CameraShakeActor {
    COP [PlaySoundCh2] ( #15 )
    JSR $&CameraShakeFrame
    DEC $26
    BMI loc_02C75C
    RTL 

  loc_02C75C:
    COP [Die]
}

CameraShakeFrame {
    LDA $layerPriorityFlag
    BIT #$0200
    BNE loc_02C794
    LDA #$0000
    STA $7F100C, X
    STA $7F100E, X

  loc_02C771:
    COP [RngByte]
    PHA 
    AND #$0003
    SEC 
    SBC #$0001
    CLC 
    ADC $cameraTargetX
    STA $cameraTargetX
    PLA 
    LSR 
    LSR 
    AND #$0003
    SEC 
    SBC #$0001
    CLC 
    ADC $cameraTargetY
    STA $cameraTargetY
    RTS 

  loc_02C794:
    LDA $7F100C, X
    BNE loc_02C7AA
    LDA $cameraTargetX
    STA $7F100C, X
    LDA $cameraTargetY
    STA $7F100E, X
    BRA loc_02C771

  loc_02C7AA:
    STA $cameraTargetX
    LDA $7F100E, X
    STA $cameraTargetY
    BRA loc_02C771

  LadderClimbSouth:
    LDA #$0028
    TRB $10
    LDA #$0100
    TSB $10
    LDA #$0800
    TSB $playerFlags
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [StagePlayerMoveXY] ( #26, #00, #1B )
    COP [AnimOnce]
    COP [BranchIfButton] ( #$0801, &LadderMoveUp )
    COP [BranchIfButton] ( #$0401, &LadderMoveDown )
    JMP $&LadderIdleNorth
}

LadderClimbNorth {
    LDA #$0028
    TRB $10
    LDA #$0100
    TSB $10
    LDA #$0800
    TSB $playerFlags
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [StagePlayerMoveXY] ( #28, #00, #19 )
    COP [AnimOnce]
    COP [BranchIfButton] ( #$0401, &LadderMoveDown )
    COP [BranchIfButton] ( #$0801, &LadderMoveUp )
    BRA LadderIdleSouth
}

LadderMoveDown {
    COP [StagePlayerSprite] ( #2D )

  loc_02C810:
    COP [StageForceMoveY] ( #1D )

  loc_02C813:
    LDA $16
    AND #$000F
    BNE loc_02C81F
    COP [BranchIfSolidTypeSouth] ( #00, &LadderLandBottom )

  loc_02C81F:
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_02C810
    COP [BranchIfNoButton] ( #$0401, &LadderIdleSouth )
    COP [SetEntryExit]
    BRA loc_02C813
}

LadderMoveUp {
    COP [StagePlayerSprite] ( #2C )

  loc_02C834:
    COP [StageForceMoveY] ( #1E )

  loc_02C837:
    LDA $16
    AND #$000F
    BNE loc_02C843
    COP [BranchIfSolidTypeNorth] ( #00, &LadderReachTop )

  loc_02C843:
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_02C834
    COP [BranchIfNoButton] ( #$0801, &LadderIdleNorth )
    COP [SetEntryExit]
    BRA loc_02C837
}

LadderIdleSouth {
    COP [BranchIfFlagByte] ( #00, #01, &LadderIdleSouthShadow )
    COP [StagePlayerSprite] ( #2B )
    BRA loc_02C873
}

LadderIdleSouthShadow {
    COP [StagePlayerSprite] ( #2F )
    BRA loc_02C873
}

LadderIdleNorth {
    COP [BranchIfFlagByte] ( #00, #01, &LadderIdleNorthShadow )
    COP [StagePlayerSprite] ( #2A )
    BRA loc_02C873
}

LadderIdleNorthShadow {
    COP [StagePlayerSprite] ( #2E )

  loc_02C873:
    STZ $2E
    STZ $08

  loc_02C877:
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_02C877
    LDA $08
    STZ $08
    STA $24

  loc_02C883:
    COP [SetEntryExit]
    COP [BranchIfButton] ( #$0401, &LadderMoveDown )
    COP [BranchIfButton] ( #$0801, &LadderMoveUp )
    DEC $24
    BPL loc_02C883
    BRA loc_02C877
}

LadderLandBottom {
    COP [StagePlayerMoveY] ( #29, #1A )
    COP [AnimOnce]
    LDA #$CFF0
    TRB $joypadMaskStd
    LDA #$0008
    TSB $10
    COP [RestoreSavedPtr]
}

LadderReachTop {
    COP [StagePlayerMoveY] ( #27, #1C )
    COP [AnimOnce]
    LDA #$CFF0
    TRB $joypadMaskStd
    LDA #$0008
    TSB $10
    COP [RestoreSavedPtr]

  ShimmyRightEntry:
    LDA #$0028
    TRB $10
    LDA #$0100
    TSB $10
    LDA #$0800
    TSB $playerFlags
    COP [StagePlayerMoveXY] ( #33, #51, #00 )
    COP [AnimOnce]

  ShimmyRightCheckWall:
    LDA $14
    CLC 
    ADC #$0008
    AND #$000F
    BNE ShimmyRightLoop
    COP [BranchIfSolidTypeEast] ( #07, &ShimmyRightLoop )
    COP [BranchIfSolidTypeEast] ( #00, &ShimmyRightLoop )
    JMP $&ShimmyDetachRight
}

ShimmyRightLoop {
    COP [StagePlayerSprite] ( #33 )

  loc_02C8EF:
    COP [StageForceMoveX] ( #51 )

  loc_02C8F2:
    LDA $14
    SEC 
    SBC #$0008
    AND #$000F
    BNE code_02C91B
    COP [BranchIfSolidType] ( #00, &ShimmyTopCorner )
    COP [BranchIfButton] ( #$0801, &ShimmyRightUpCheck )
    COP [BranchIfButton] ( #$0401, &ShimmyRightDownCheck )

  loc_02C90E:
    COP [BranchIfSolidTypeEast] ( #07, &code_02C91B )
    COP [BranchIfSolidTypeEast] ( #00, &code_02C91B )
    JMP $&ShimmyDetachRight
}

code_02C91B {
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_02C8EF
    COP [BranchIfNoButton] ( #$0101, &ShimmyDetachRight )
    COP [SetEntryExit]
    BRA loc_02C8F2
}

ShimmyRightUpCheck {
    COP [BranchIfSolidTypeNorth] ( #00, &ShimmyTopCorner )
    BRA loc_02C90E
}

ShimmyRightDownCheck {
    COP [BranchIfSolidTypeSouth] ( #00, &ShimmyTopCorner )
    BRA loc_02C90E

  ShimmyLeftEntry:
    LDA #$0028
    TRB $10
    LDA #$0100
    TSB $10
    LDA #$0800
    TSB $playerFlags
    COP [StagePlayerMoveXY] ( #32, #52, #00 )
    COP [AnimOnce]

  ShimmyLeftCheckWall:
    LDA $14
    CLC 
    ADC #$0008
    AND #$000F
    BNE ShimmyLeftLoop
    COP [BranchIfSolidTypeWest] ( #07, &ShimmyLeftLoop )
    COP [BranchIfSolidTypeWest] ( #00, &ShimmyLeftLoop )
    BRA ShimmyDetachLeft
}

ShimmyLeftLoop {
    COP [StagePlayerSprite] ( #32 )

  loc_02C96C:
    COP [StageForceMoveX] ( #52 )

  loc_02C96F:
    LDA $14
    SEC 
    SBC #$0008
    AND #$000F
    BNE code_02C997
    COP [BranchIfSolidType] ( #00, &ShimmyTopCorner )
    COP [BranchIfButton] ( #$0801, &ShimmyLeftUpCheck )
    COP [BranchIfButton] ( #$0401, &ShimmyLeftDownCheck )

  loc_02C98B:
    COP [BranchIfSolidTypeWest] ( #07, &code_02C997 )
    COP [BranchIfSolidTypeWest] ( #00, &code_02C997 )
    BRA ShimmyDetachLeft
}

code_02C997 {
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_02C96C
    COP [BranchIfNoButton] ( #$0201, &ShimmyDetachLeft )
    COP [SetEntryExit]
    BRA loc_02C96F
}

ShimmyLeftUpCheck {
    COP [BranchIfSolidTypeNorth] ( #00, &ShimmyTopCorner )
    BRA loc_02C98B
}

ShimmyLeftDownCheck {
    COP [BranchIfSolidTypeSouth] ( #00, &ShimmyTopCorner )
    BRA loc_02C98B
}

ShimmyDetachRight {
    COP [StageForceMoveX] ( #00 )
    COP [BranchIfFlagByte] ( #00, #01, &ShimmyDetachRightShadow )
    COP [StagePlayerSprite] ( #31 )
    BRA loc_02C9DB
}

ShimmyDetachRightShadow {
    COP [StagePlayerSprite] ( #35 )
    BRA loc_02C9DB
}

ShimmyDetachLeft {
    COP [StageForceMoveX] ( #00 )
    COP [BranchIfFlagByte] ( #00, #01, &ShimmyDetachLeftShadow )
    COP [StagePlayerSprite] ( #30 )
    BRA loc_02C9DB
}

ShimmyDetachLeftShadow {
    COP [StagePlayerSprite] ( #34 )

  loc_02C9DB:
    STZ $2C
    STZ $08

  loc_02C9DF:
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_02C9DF
    LDA $08
    STZ $08
    STA $24

  loc_02C9EB:
    COP [SetEntryExit]
    COP [BranchIfButton] ( #$0801, &code_02CA0B )
    COP [BranchIfButton] ( #$0401, &code_02CA12 )
    COP [BranchIfButton] ( #$0201, &ShimmyLeftCheckWall )
    COP [BranchIfButton] ( #$0101, &ShimmyRightCheckWall )

  loc_02CA05:
    DEC $24
    BPL loc_02C9EB
    BRA loc_02C9DF
}

code_02CA0B {
    COP [BranchIfSolidTypeNorth] ( #00, &ShimmyTopCorner )
    BRA loc_02CA05
}

code_02CA12 {
    COP [BranchIfSolidTypeSouth] ( #00, &ShimmyTopCorner )
    BRA loc_02CA05
}

ShimmyTopCorner {
    STZ $2C
    LDA #$0008
    TSB $10
    COP [RestoreSavedPtr]

  AttackFromWalkSouth:
    LDA #$0400
    TSB $joypadHeld
}

RunSouth {
    STZ $invincibilityTimer
    COP [StagePlayerSprite] ( #3A )
    BRA loc_02CA58

  AttackFromWalkNorth:
    LDA #$0800
    TSB $joypadHeld
}

RunNorth {
    STZ $invincibilityTimer
    COP [StagePlayerSprite] ( #3B )
    BRA loc_02CA58

  AttackFromWalkWest:
    LDA #$0200
    TSB $joypadHeld
}

RunWest {
    STZ $invincibilityTimer
    COP [StagePlayerSprite] ( #3C )
    BRA loc_02CA58

  AttackFromWalkEast:
    LDA #$0100
    TSB $joypadHeld
}

RunEast {
    STZ $invincibilityTimer
    COP [StagePlayerSprite] ( #3D )

  loc_02CA58:
    LDA #$2000
    TSB $playerFlags
    LDA #$0020
    TSB $10
    LDA #$0100
    TRB $10

  loc_02CA68:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $2A
    BEQ loc_02CA68
    COP [BranchIfNoButton] ( #$0030, &RunStopToIdle )
    DEC $24
    BMI loc_02CA68
    RTL 
}

RunStopToIdle {
    COP [RestoreSavedPtr]
}

MovingEastWest {
    LDA $joypadCurrent
    BIT #$0300
    BEQ loc_02CA93
    BIT #$0200
    BNE loc_02CAD4
    BRA loc_02CA9C

  loc_02CA93:
    LDA $playerSpeedEw
    BMI loc_02CAD4
    BRA loc_02CA9C

  code_02CA9A:
    COP [SetEntryExit]

  loc_02CA9C:
    COP [StagePlayerSprite] ( #0F )

  loc_02CA9F:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $2A
    BEQ loc_02CA9F
    LDA $playerSpeedEw
    BEQ loc_02CB0A
    COP [BranchIfButton] ( #$0200, &code_02CAD2 )
    JSR $&CheckRunAttack
    JSR $&SpeedThresholdEW
    BCS loc_02CACD
    COP [BranchIfButton] ( #$8000, &AttackEast )
    COP [BranchIfButton] ( #$0030, &AttackFromWalkEast )

  loc_02CACD:
    DEC $24
    BMI loc_02CA9F
    RTL 
}

code_02CAD2 {
    COP [SetEntryExit]

  loc_02CAD4:
    COP [StagePlayerSprite] ( #0E )

  loc_02CAD7:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $2A
    BEQ loc_02CAD7
    LDA $playerSpeedEw
    BEQ loc_02CB0A
    COP [BranchIfButton] ( #$0100, &code_02CA9A )
    JSR $&CheckRunAttack
    JSR $&SpeedThresholdEW
    BCS loc_02CB05
    COP [BranchIfButton] ( #$8000, &AttackWest )
    COP [BranchIfButton] ( #$0030, &AttackFromWalkWest )

  loc_02CB05:
    DEC $24
    BMI loc_02CAD7
    RTL 

  loc_02CB0A:
    COP [RestoreSavedPtr]
}

MovingNorthSouth {
    LDA $joypadCurrent
    BIT #$0C00
    BEQ loc_02CB1B
    BIT #$0800
    BNE loc_02CB24
    BRA loc_02CB5C

  loc_02CB1B:
    LDA $playerSpeedNs
    BMI loc_02CB24
    BRA loc_02CB5C

  code_02CB22:
    COP [SetEntryExit]

  loc_02CB24:
    COP [StagePlayerSprite] ( #0D )

  loc_02CB27:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $2A
    BEQ loc_02CB27
    LDA $playerSpeedNs
    BEQ loc_02CB0A
    COP [BranchIfButton] ( #$0400, &code_02CB5A )
    JSR $&CheckRunAttack
    JSR $&SpeedThresholdNS
    BCS loc_02CB55
    COP [BranchIfButton] ( #$8000, &AttackNorth )
    COP [BranchIfButton] ( #$0030, &AttackFromWalkNorth )

  loc_02CB55:
    DEC $24
    BMI loc_02CB27
    RTL 
}

code_02CB5A {
    COP [SetEntryExit]

  loc_02CB5C:
    COP [StagePlayerSprite] ( #0C )

  loc_02CB5F:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $2A
    BEQ loc_02CB5F
    LDA $playerSpeedNs
    BEQ loc_02CB0A
    COP [BranchIfButton] ( #$0800, &code_02CB22 )
    JSR $&CheckRunAttack
    JSR $&SpeedThresholdNS
    BCS loc_02CB8D
    COP [BranchIfButton] ( #$8000, &AttackSouth )
    COP [BranchIfButton] ( #$0030, &AttackFromWalkSouth )

  loc_02CB8D:
    DEC $24
    BMI loc_02CB5F
    RTL 
}

CheckRunAttack {
    LDA $10
    BIT #$0080
    BNE loc_02CBB4
    LDA $characterForm
    BNE loc_02CBB4
    LDA $abilityBitmask
    BIT #$0002
    BEQ loc_02CBB4
    LDA $playerFlags
    BIT #$1000
    BNE loc_02CBB4
    COP [BranchIfButton] ( #$8000, &RunAttackSpeedCheck )

  loc_02CBB4:
    RTS 
}

RunAttackSpeedCheck {
    LDA $playerSpeedEw
    BPL loc_02CBBE
    EOR #$FFFF
    INC 

  loc_02CBBE:
    CMP #$0003
    BCC loc_02CBC7
    PLA 
    JMP $&RunAttackEW

  loc_02CBC7:
    LDA $playerSpeedNs
    BPL loc_02CBD0
    EOR #$FFFF
    INC 

  loc_02CBD0:
    CMP #$0003
    BCC loc_02CBB4
    PLA 
    JMP $&RunAttackNS
}

SpeedThresholdEW {
    LDA $playerSpeedEw
    BPL loc_02CBE2
    EOR #$FFFF
    INC 

  loc_02CBE2:
    BRA loc_02CBED
}

SpeedThresholdNS {
    LDA $playerSpeedNs
    BPL loc_02CBED
    EOR #$FFFF
    INC 

  loc_02CBED:
    CMP #$0004
    BCC loc_02CBF3
    RTS 

  loc_02CBF3:
    LDA $playerFlags
    BIT #$1000
    BNE loc_02CBFD
    CLC 
    RTS 

  loc_02CBFD:
    SEC 
    RTS 
}

RunAttackNS {
    LDA #$0001
    JSR $&attack_ability_system.LoadAbilityAnimTableA
    COP [SetPlayerBodySprite] ( #04 )
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
    COP [StageSpriteFrame] ( #0E )
    COP [AnimOnce]
    JSR $&RunAttackCleanup
    COP [RestoreSavedPtr]

  loc_02CC2E:
    JSR $&RunAttackFlagSetup
    COP [SetForceNE] ( #01 )
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    STZ $playerSpeedNs
    LDA #$0100
    TRB $10
    COP [StageSpriteLoopMoveY] ( #10, #02, #44 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #11 )
    COP [AnimOnce]
    JSR $&RunAttackCleanup
    COP [RestoreSavedPtr]
}

RunAttackEW {
    LDA #$0001
    JSR $&attack_ability_system.LoadAbilityAnimTableA
    COP [SetPlayerBodySprite] ( #04 )
    LDA $playerSpeedEw
    BPL loc_02CC84
    JSR $&RunAttackFlagSetup
    COP [SetForceSW] ( #01 )
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    STZ $playerSpeedEw
    LDA #$0100
    TRB $10
    COP [StageSpriteLoopMoveX] ( #13, #02, #44 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #14 )
    COP [AnimOnce]
    JSR $&RunAttackCleanup
    COP [RestoreSavedPtr]

  loc_02CC84:
    JSR $&RunAttackFlagSetup
    COP [StageSpriteFrame] ( #15 )
    COP [AnimOnce]
    STZ $playerSpeedEw
    LDA #$0100
    TRB $10
    COP [StageSpriteLoopMoveX] ( #16, #02, #44 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #17 )
    COP [AnimOnce]
    JSR $&RunAttackCleanup
    COP [RestoreSavedPtr]
}

DisableStatusForAttack {
    LDA #$0100
    TRB $10
    LDA #$0200
    TSB $layerPriorityFlag
}

RunAttackFlagSetup {
    LDA #$0200
    TSB $10
    LDA #$8000
    TSB $joypadHeld
    LDA #$0802
    TSB $playerFlags
    RTS 
}

RestoreStatusDisplay {
    LDA #$0200
    TRB $layerPriorityFlag
}

RunAttackCleanup {
    LDA #$0200
    TRB $10
    LDA #$8000
    TSB $joypadHeld
    LDA #$0002
    TRB $playerFlags
    RTS 
}

AttackSouth {
    JSR $&AttackInit
    LDA #$0400
    TSB $joypadHeld
    LDA $characterForm
    CMP #$0001
    BNE loc_02CD04
    COP [BranchIfSolidSouth] ( &code_02CCFF )
    LDA $playerXPos
    AND #$000F
    BEQ loc_02CD04
    COP [BranchIfSolidOffset] ( #01, #01, &code_02CCFF )
    BRA loc_02CD04
}

code_02CCFF {
    COP [StagePlayerSprite] ( #48 )
    BRA loc_02CD07

  loc_02CD04:
    COP [StagePlayerSprite] ( #36 )

  loc_02CD07:
    LDA $sceneCurrent
    CMP #$00E8
    BNE loc_02CD18
    COP [SpawnLastRel] ( @ProjectileSouth, #00, #00, #$0602 )

  loc_02CD18:
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    COP [SetEntryExit]

  loc_02CD1E:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $2A
    BEQ loc_02CD52
    LDA $characterForm
    BNE loc_02CD45
    COP [SetEntryContinue]
    COP [BranchIfButton] ( #$0B00, &AttackRedirect )
    COP [BranchIfButton] ( #$0400, &RangedAttackSouth )
    DEC $24
    BMI loc_02CD1E
    RTL 

  loc_02CD45:
    COP [SetEntryContinue]
    COP [BranchIfButton] ( #$0B00, &AttackRedirect )
    DEC $24
    BMI loc_02CD1E
    RTL 

  loc_02CD52:
    COP [BranchIfButton] ( #$8000, &AttackSouth )
    JMP $&AttackFinish
}

AttackNorth {
    JSR $&AttackInit
    LDA #$0800
    TSB $joypadHeld
    LDA $characterForm
    CMP #$0001
    BNE loc_02CD85
    COP [BranchIfSolidSouth] ( &code_02CD80 )
    LDA $playerXPos
    AND #$000F
    BEQ loc_02CD85
    COP [BranchIfSolidOffset] ( #01, #FF, &code_02CD80 )
    BRA loc_02CD85
}

code_02CD80 {
    COP [StagePlayerSprite] ( #49 )
    BRA loc_02CD88

  loc_02CD85:
    COP [StagePlayerSprite] ( #37 )

  loc_02CD88:
    LDA $sceneCurrent
    CMP #$00E8
    BNE loc_02CD99
    COP [SpawnLastRel] ( @ProjectileNorth, #00, #D0, #$0602 )

  loc_02CD99:
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    COP [SetEntryExit]

  loc_02CD9F:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $2A
    BEQ loc_02CDD3
    LDA $characterForm
    BNE loc_02CDC6
    COP [SetEntryContinue]
    COP [BranchIfButton] ( #$0700, &AttackRedirect )
    COP [BranchIfButton] ( #$0800, &RangedAttackNorth )
    DEC $24
    BMI loc_02CD9F
    RTL 

  loc_02CDC6:
    COP [SetEntryContinue]
    COP [BranchIfButton] ( #$0700, &AttackRedirect )
    DEC $24
    BMI loc_02CD9F
    RTL 

  loc_02CDD3:
    COP [BranchIfButton] ( #$8000, &AttackNorth )
    JMP $&AttackFinish
}

AttackWest {
    JSR $&AttackInit
    LDA #$0200
    TSB $joypadHeld
    LDA $characterForm
    CMP #$0002
    BEQ loc_02CDFE
    COP [BranchIfSolidWest] ( &code_02CE03 )
    LDA $16
    AND #$000F
    BEQ loc_02CDFE
    COP [BranchIfSolidOffset] ( #FF, #01, &code_02CE03 )

  loc_02CDFE:
    COP [StagePlayerSprite] ( #38 )
    BRA loc_02CE06
}

code_02CE03 {
    COP [StagePlayerSprite] ( #42 )

  loc_02CE06:
    LDA $sceneCurrent
    CMP #$00E8
    BNE loc_02CE17
    COP [SpawnLastRel] ( @ProjectileWest, #00, #00, #$0602 )

  loc_02CE17:
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    COP [SetEntryExit]

  loc_02CE1D:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $2A
    BEQ loc_02CE51
    LDA $characterForm
    BNE loc_02CE44
    COP [SetEntryContinue]
    COP [BranchIfButton] ( #$0D00, &AttackRedirect )
    COP [BranchIfButton] ( #$0200, &RangedAttackWest )
    DEC $24
    BMI loc_02CE1D
    RTL 

  loc_02CE44:
    COP [SetEntryContinue]
    COP [BranchIfButton] ( #$0D00, &AttackRedirect )
    DEC $24
    BMI loc_02CE1D
    RTL 

  loc_02CE51:
    COP [BranchIfButton] ( #$8000, &AttackWest )
    JMP $&AttackFinish
}

AttackEast {
    JSR $&AttackInit
    LDA #$0100
    TSB $joypadHeld
    LDA $characterForm
    CMP #$0002
    BEQ loc_02CE7C
    COP [BranchIfSolidEast] ( &code_02CE81 )
    LDA $16
    AND #$000F
    BEQ loc_02CE7C
    COP [BranchIfSolidOffset] ( #01, #01, &code_02CE81 )

  loc_02CE7C:
    COP [StagePlayerSprite] ( #39 )
    BRA loc_02CE84
}

code_02CE81 {
    COP [StagePlayerSprite] ( #43 )

  loc_02CE84:
    LDA $sceneCurrent
    CMP #$00E8
    BNE loc_02CE95
    COP [SpawnLastRel] ( @ProjectileEast, #00, #00, #$0602 )

  loc_02CE95:
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    COP [SetEntryExit]

  loc_02CE9B:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $2A
    BEQ loc_02CECF
    LDA $characterForm
    BNE loc_02CEC2
    COP [SetEntryContinue]
    COP [BranchIfButton] ( #$0E00, &AttackRedirect )
    COP [BranchIfButton] ( #$0100, &RangedAttackEast )
    DEC $24
    BMI loc_02CE9B
    RTL 

  loc_02CEC2:
    COP [SetEntryContinue]
    COP [BranchIfButton] ( #$0E00, &AttackRedirect )
    DEC $24
    BMI loc_02CE9B
    RTL 

  loc_02CECF:
    COP [BranchIfButton] ( #$8000, &AttackEast )
    JMP $&AttackFinish
}

AttackRedirect {
    LDA $joypadCurrent
    BIT #$0F00
    BEQ AttackFinish
    LDA #$8000
    TRB $joypadHeld
}

AttackFinish {
    LDA #$0F00
    TRB $joypadHeld
    COP [RestoreSavedPtr]
}

AttackInit {
    LDA $joypadCurrent
    AND #$0F00
    STA $joypadCurrent
    ORA #$8000
    STA $joypadHeld
    LDA #$0100
    TRB $10
    LDA $characterForm
    BEQ loc_02CF0B
    COP [PlaySoundCh2] ( #02 )
    RTS 

  loc_02CF0B:
    COP [PlaySoundCh2] ( #01 )
    RTS 
}

RangedAttackSouth {
    JSR $&RangedSetForceY
    COP [StagePlayerSprite] ( #44 )
    COP [AnimOnce]
    BRA loc_02CF3F
}

RangedAttackNorth {
    JSR $&RangedSetForceY
    LDA #$2000
    TSB $12
    COP [StagePlayerSprite] ( #45 )
    COP [AnimOnce]
    BRA loc_02CF3F
}

RangedAttackWest {
    JSR $&RangedSetForceX
    LDA #$4000
    TSB $12
    COP [StagePlayerSprite] ( #46 )
    COP [AnimOnce]
    BRA loc_02CF3F
}

RangedAttackEast {
    JSR $&RangedSetForceX
    COP [StagePlayerSprite] ( #47 )
    COP [AnimOnce]

  loc_02CF3F:
    LDA #$0200
    TRB $10
    COP [AndActorFlags] ( #$FFBF )
    COP [RestoreSavedPtr]
}

RangedSetForceX {
    COP [StageForceMoveX] ( #46 )
    BRA loc_02CF52
}

RangedSetForceY {
    COP [StageForceMoveY] ( #46 )

  loc_02CF52:
    LDA #$0800
    TSB $playerFlags
    LDA #$0001
    STA $climbStateData
    LDA #$0200
    TSB $10
    COP [OrActorFlags] ( #$0040 )
    RTS 
}

ProjectileSouth {
    COP [SetMetasprite] ( @table_17D000 )
    COP [StageSpriteMoveY] ( #00, #09 )
    COP [AnimOnce]

  loc_02CF73:
    COP [StageSpriteMoveY] ( #04, #0F )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_02CF73
    COP [Die]
}

ProjectileNorth {
    COP [SetMetasprite] ( @table_17D000 )
    COP [StageSpriteMoveY] ( #01, #0A )
    COP [AnimOnce]

  loc_02CF8D:
    COP [StageSpriteMoveY] ( #05, #10 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_02CF8D
    COP [Die]
}

ProjectileWest {
    COP [SetMetasprite] ( @table_17D000 )
    COP [StageSpriteMoveX] ( #02, #0A )
    COP [AnimOnce]

  loc_02CFA7:
    COP [StageSpriteMoveX] ( #06, #10 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_02CFA7
    COP [Die]
}

ProjectileEast {
    COP [SetMetasprite] ( @table_17D000 )
    COP [StageSpriteMoveX] ( #03, #09 )
    COP [AnimOnce]

  loc_02CFC1:
    COP [StageSpriteMoveX] ( #07, #0F )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_02CFC1
    COP [Die]
}