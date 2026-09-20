; Zombie enemy — undead with resurrection in Angkor Wat (~684 lines).
; 
; Complex undead enemy that rises from the ground when the
; player approaches. Can resurrect after being defeated
; unless destroyed quickly enough. Multi-phase AI with
; shambling patrol, lunge attack, and death/resurrection
; mechanics. One of the largest regular enemy scripts.
---------------------------------------------

?INCLUDE 'ActorMidpointCalc'
?INCLUDE 'enemy_stats_table'
?INCLUDE 'EnemyDeathFlash'

!playerXPos                     09A2
!playerYPos                     09A4
!orbitAngle                     7F0010
!moveXAlt                       7F0018
!moveYAlt                       7F001A
!statsPtr                       7F0020
!currentHp                      7F0026

---------------------------------------------

awB0_zombie [
  actor-def < #1F, #00, #00, {

  code_0BB278:
    LDA #$0020
    TSB $12
    LDA $&enemy_stats_table+120
    AND #$00FF
    STA $orbitAngle, X
    BRA loc_0BB2A8

  code_0BB289:
    LDA #$00FF
    STA $currentHp, X
    COP [SetEntryExit]
    COP [RngByte]
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0BB2A0 )
} >
]

code_list_0BB2A0 [
  &code_0BB2C8   ;00
  &code_0BB315   ;01
  &code_0BB3B6   ;02
  &code_0BB36C   ;03
]

loc_0BB2A8 {
    LDA #$00FF
    STA $currentHp, X
    COP [SetSavedPtr] ( &loc_0BB2A8 )
    COP [SetEntryExit]
    COP [WaitWhileOffscreen] ( #11 )
    COP [BranchNearerAxis] ( &code_0BB2BE, &code_0BB362 )
}

code_0BB2BE {
    COP [BranchOnPlayerX] ( #$0000, &code_0BB2C8, &code_0BB2C8, &code_0BB315 )
}

code_0BB2C8 {
    COP [LoopInit] ( #02 )
    COP [BranchIfSolidWest] ( &code_0BB289 )
    COP [BranchIfPlayerNear] ( #03, &code_0BB2EB )
    COP [StageSpriteMoveX] ( #24, #02 )
    COP [AnimOnce]
    COP [BranchIfSolidWest] ( &code_0BB289 )
    COP [BranchIfPlayerNear] ( #03, &code_0BB2F7 )
    COP [StageSpriteMoveX] ( #2A, #02 )
    COP [AnimOnce]
    COP [LoopNext]
}

code_0BB2EB {
    COP [BranchIfSolidWest] ( &code_0BB289 )
    COP [StageSpriteMoveX] ( #24, #02 )
    COP [AnimOnce]
    BRA loc_0BB301
}

code_0BB2F7 {
    COP [BranchIfSolidWest] ( &code_0BB289 )
    COP [StageSpriteMoveX] ( #2A, #02 )
    COP [AnimOnce]

  loc_0BB301:
    COP [StageSpriteFrame] ( #21 )
    COP [AnimOnce]
    COP [CardinalToPlayer]
    CMP #$0001
    BEQ loc_0BB310
    JMP $&code_0BB400

  loc_0BB310:
    COP [WaitByte] ( #0F )
    COP [RestoreSavedPtr]
}

code_0BB315 {
    COP [LoopInit] ( #02 )
    COP [BranchIfPlayerNear] ( #03, &code_0BB338 )
    COP [BranchIfSolidEast] ( &code_0BB289 )
    COP [StageSpriteMoveX] ( #A4, #01 )
    COP [AnimOnce]
    COP [BranchIfPlayerNear] ( #03, &code_0BB344 )
    COP [BranchIfSolidEast] ( &code_0BB289 )
    COP [StageSpriteMoveX] ( #AA, #01 )
    COP [AnimOnce]
    COP [LoopNext]
}

code_0BB338 {
    COP [BranchIfSolidEast] ( &code_0BB289 )
    COP [StageSpriteMoveX] ( #A4, #01 )
    COP [AnimOnce]
    BRA loc_0BB34E
}

code_0BB344 {
    COP [BranchIfSolidEast] ( &code_0BB289 )
    COP [StageSpriteMoveX] ( #AA, #01 )
    COP [AnimOnce]

  loc_0BB34E:
    COP [StageSpriteFrame] ( #A1 )
    COP [AnimOnce]
    COP [CardinalToPlayer]
    CMP #$0003
    BEQ loc_0BB35D
    JMP $&code_0BB400

  loc_0BB35D:
    COP [WaitByte] ( #0F )
    COP [RestoreSavedPtr]
}

code_0BB362 {
    COP [BranchOnPlayerY] ( #$0000, &code_0BB36C, &code_0BB36C, &code_0BB3B6 )
}

code_0BB36C {
    COP [LoopInit] ( #02 )
    COP [BranchIfPlayerNear] ( #03, &code_0BB38F )
    COP [BranchIfSolidNorth] ( &code_0BB289 )
    COP [StageSpriteMoveY] ( #23, #02 )
    COP [AnimOnce]
    COP [BranchIfPlayerNear] ( #03, &code_0BB39B )
    COP [BranchIfSolidNorth] ( &code_0BB289 )
    COP [StageSpriteMoveY] ( #29, #02 )
    COP [AnimOnce]
    COP [LoopNext]
}

code_0BB38F {
    COP [BranchIfSolidNorth] ( &code_0BB289 )
    COP [StageSpriteMoveY] ( #23, #02 )
    COP [AnimOnce]
    BRA loc_0BB3A5
}

code_0BB39B {
    COP [BranchIfSolidNorth] ( &code_0BB289 )
    COP [StageSpriteMoveY] ( #29, #02 )
    COP [AnimOnce]

  loc_0BB3A5:
    COP [StageSpriteFrame] ( #20 )
    COP [AnimOnce]
    COP [CardinalToPlayer]
    CMP #$0002
    BNE code_0BB400
    COP [WaitByte] ( #0F )
    COP [RestoreSavedPtr]
}

code_0BB3B6 {
    COP [LoopInit] ( #02 )
    COP [BranchIfPlayerNear] ( #03, &code_0BB3D9 )
    COP [BranchIfSolidSouth] ( &code_0BB289 )
    COP [StageSpriteMoveY] ( #22, #01 )
    COP [AnimOnce]
    COP [BranchIfPlayerNear] ( #03, &code_0BB3E5 )
    COP [BranchIfSolidSouth] ( &code_0BB289 )
    COP [StageSpriteMoveY] ( #28, #01 )
    COP [AnimOnce]
    COP [LoopNext]
}

code_0BB3D9 {
    COP [BranchIfSolidSouth] ( &code_0BB289 )
    COP [StageSpriteMoveY] ( #22, #01 )
    COP [AnimOnce]
    BRA loc_0BB3EF
}

code_0BB3E5 {
    COP [BranchIfSolidSouth] ( &code_0BB289 )
    COP [StageSpriteMoveY] ( #28, #01 )
    COP [AnimOnce]

  loc_0BB3EF:
    COP [StageSpriteFrame] ( #1F )
    COP [AnimOnce]
    COP [CardinalToPlayer]
    CMP #$0000
    BNE code_0BB400
    COP [WaitByte] ( #0F )
    COP [RestoreSavedPtr]
}

code_0BB400 {
    AND #$0003
    STA $26
    COP [BranchIfPlayerNear] ( #05, &code_0BB40C )
    COP [RestoreSavedPtr]
}

code_0BB40C {
    LDA $26
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0BB417 )
}

code_list_0BB417 [
  &code_0BB41F   ;00
  &code_0BB4E9   ;01
  &code_0BB47A   ;02
  &code_0BB558   ;03
]

code_0BB41F {
    COP [StageSpriteFrame] ( #26 )
    COP [AnimOnce]
    COP [SpawnMarkedAfterRel] ( @code_0BB74F, #00, #D0, #$2002 )
    COP [SpawnMarkedAfterRel] ( @code_0BB6BD, #00, #D2, #$2202 )
    COP [SpawnMarkedAfterRel] ( @code_0BB6BD, #00, #DA, #$2202 )
    COP [SpawnMarkedAfterRel] ( @code_0BB6BD, #00, #E0, #$2202 )
    COP [SpawnMarkedAfterRel] ( @code_0BB68E, #00, #E6, #$2202 )
    LDA #$FFFF
    STA $26
    COP [SetEntryExit]
    COP [StageSpriteFrame] ( #10 )
    COP [AnimOnce]
    LDA $26
    BPL loc_0BB462
    RTL 

  loc_0BB462:
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    LDA $26
    BEQ loc_0BB473
    JMP $&code_0BB5C4

  loc_0BB473:
    COP [StageSpriteFrame] ( #20 )
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0BB47A {
    COP [StageSpriteFrame] ( #25 )
    COP [AnimOnce]
    COP [SpawnMarkedBefore] ( @code_0BB73D, #$2002 )
    LDA #$FFD0
    JSR $&code_0BB686
    COP [SpawnMarkedBefore] ( @code_0BB6BD, #$2202 )
    LDA #$FFD2
    JSR $&code_0BB686
    COP [SpawnMarkedBefore] ( @code_0BB6BD, #$2202 )
    LDA #$FFDA
    JSR $&code_0BB686
    COP [SpawnMarkedBefore] ( @code_0BB6BD, #$2202 )
    LDA #$FFE0
    JSR $&code_0BB686
    COP [SpawnMarkedBefore] ( @code_0BB68E, #$2202 )
    LDA #$FFE6
    JSR $&code_0BB686
    LDA #$FFFF
    STA $26
    COP [SetEntryExit]
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    LDA $26
    BPL loc_0BB4D1
    RTL 

  loc_0BB4D1:
    COP [KillPrev]
    COP [KillPrev]
    COP [KillPrev]
    COP [KillPrev]
    COP [KillPrev]
    LDA $26
    BEQ loc_0BB4E2
    JMP $&code_0BB5C4

  loc_0BB4E2:
    COP [StageSpriteFrame] ( #1F )
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0BB4E9 {
    COP [StageSpriteFrame] ( #A7 )
    COP [AnimOnce]
    COP [SpawnMarkedBefore] ( @code_0BB6CC, #$2002 )
    LDA #$FFD8
    JSR $&code_0BB686
    COP [SpawnMarkedBefore] ( @code_0BB6BD, #$2202 )
    LDA #$FFD2
    JSR $&code_0BB686
    COP [SpawnMarkedBefore] ( @code_0BB6BD, #$2202 )
    LDA #$FFDA
    JSR $&code_0BB686
    COP [SpawnMarkedBefore] ( @code_0BB6BD, #$2202 )
    LDA #$FFE0
    JSR $&code_0BB686
    COP [SpawnMarkedBefore] ( @code_0BB68E, #$2202 )
    LDA #$FFE6
    JSR $&code_0BB686
    LDA #$FFFF
    STA $26
    COP [SetEntryExit]
    COP [StageSpriteFrame] ( #91 )
    COP [AnimOnce]
    LDA $26
    BPL loc_0BB540
    RTL 

  loc_0BB540:
    COP [KillPrev]
    COP [KillPrev]
    COP [KillPrev]
    COP [KillPrev]
    COP [KillPrev]
    LDA $26
    BEQ loc_0BB551
    JMP $&code_0BB5C4

  loc_0BB551:
    COP [StageSpriteFrame] ( #A1 )
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0BB558 {
    COP [StageSpriteFrame] ( #27 )
    COP [AnimOnce]
    COP [SpawnMarkedBefore] ( @code_0BB6DC, #$2002 )
    LDA #$FFD8
    JSR $&code_0BB686
    COP [SpawnMarkedBefore] ( @code_0BB6BD, #$2202 )
    LDA #$FFD2
    JSR $&code_0BB686
    COP [SpawnMarkedBefore] ( @code_0BB6BD, #$2202 )
    LDA #$FFDA
    JSR $&code_0BB686
    COP [SpawnMarkedBefore] ( @code_0BB6BD, #$2202 )
    LDA #$FFE0
    JSR $&code_0BB686
    COP [SpawnMarkedBefore] ( @code_0BB68E, #$2202 )
    LDA #$FFE6
    JSR $&code_0BB686
    LDA #$FFFF
    STA $26
    COP [SetEntryExit]
    COP [StageSpriteFrame] ( #11 )
    COP [AnimOnce]
    LDA $26
    BPL loc_0BB5AF
    RTL 

  loc_0BB5AF:
    COP [KillPrev]
    COP [KillPrev]
    COP [KillPrev]
    COP [KillPrev]
    COP [KillPrev]
    LDA $26
    BNE code_0BB5C4
    COP [StageSpriteFrame] ( #21 )
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0BB5C4 {
    LDA #$&enemy_stats_table+11C
    STA $statsPtr, X
    LDA $&enemy_stats_table+11C
    AND #$00FF
    STA $currentHp, X
    LDA #$0020
    TRB $12
    COP [StageSpriteFrame] ( #2B )
    COP [AnimOnce]

  code_0BB5DF:
    COP [SetSavedPtr] ( &code_0BB5DF )
    COP [SetEntryExit]
    COP [BranchIfPlayerNear] ( #07, &code_0BB600 )
    COP [RngByte]
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0BB5F8 )
}

code_list_0BB5F8 [
  &code_0BB610   ;00
  &code_0BB62B   ;01
  &code_0BB650   ;02
  &code_0BB66B   ;03
]

code_0BB600 {
    COP [BranchNearerAxis] ( &code_0BB606, &code_0BB646 )
}

code_0BB606 {
    COP [BranchOnPlayerX] ( #$0000, &code_0BB610, &code_0BB610, &code_0BB62B )
}

code_0BB610 {
    COP [LoopInit] ( #03 )
    COP [BranchIfSolidWest] ( &code_0BB5DF )
    COP [StageSpriteMoveX] ( #14, #04 )
    COP [AnimOnce]
    COP [BranchIfSolidWest] ( &code_0BB5DF )
    COP [StageSpriteMoveX] ( #17, #04 )
    COP [AnimOnce]
    COP [LoopNext]
    COP [RestoreSavedPtr]
}

code_0BB62B {
    COP [LoopInit] ( #03 )
    COP [BranchIfSolidEast] ( &code_0BB5DF )
    COP [StageSpriteMoveX] ( #94, #03 )
    COP [AnimOnce]
    COP [BranchIfSolidEast] ( &code_0BB5DF )
    COP [StageSpriteMoveX] ( #97, #03 )
    COP [AnimOnce]
    COP [LoopNext]
    COP [RestoreSavedPtr]
}

code_0BB646 {
    COP [BranchOnPlayerY] ( #$0000, &code_0BB650, &code_0BB650, &code_0BB66B )
}

code_0BB650 {
    COP [LoopInit] ( #07 )
    COP [BranchIfSolidNorth] ( &code_0BB5DF )
    COP [StageSpriteMoveY] ( #13, #04 )
    COP [AnimOnce]
    COP [BranchIfSolidNorth] ( &code_0BB5DF )
    COP [StageSpriteMoveY] ( #16, #04 )
    COP [AnimOnce]
    COP [LoopNext]
    COP [RestoreSavedPtr]
}

code_0BB66B {
    COP [LoopInit] ( #07 )
    COP [BranchIfSolidSouth] ( &code_0BB5DF )
    COP [StageSpriteMoveY] ( #12, #03 )
    COP [AnimOnce]
    COP [BranchIfSolidSouth] ( &code_0BB5DF )
    COP [StageSpriteMoveY] ( #15, #03 )
    COP [AnimOnce]
    COP [LoopNext]
    COP [RestoreSavedPtr]
}

code_0BB686 {
    CLC 
    ADC $0016, Y
    STA $0016, Y
    RTS 
}

code_0BB68E {
    LDY $24
    LDA $14
    SEC 
    SBC $0014, Y
    STA $7F100C, X
    LDA $16
    SEC 
    SBC $0016, Y
    STA $7F100E, X
    COP [SetEntryContinue]
    LDY $24
    LDA $0014, Y
    CLC 
    ADC $7F100C, X
    STA $14
    LDA $0016, Y
    CLC 
    ADC $7F100E, X
    STA $16
    RTL 
}

code_0BB6BD {
    LDA #$2000
    TRB $10
    COP [StageSprAndHitbox] ( #1E )
    COP [SetEntryContinue]
    JSL $@ActorMidpointCalc
    RTL 
}

code_0BB6CC {
    COP [StageSprAndHitbox] ( #9D )
    LDA #$0002
    TSB $12
    LDA $14
    CLC 
    ADC #$0040
    BRA loc_0BB6E5
}

code_0BB6DC {
    COP [StageSprAndHitbox] ( #1D )
    LDA $14
    CLC 
    ADC #$FFC0

  loc_0BB6E5:
    STA $moveXAlt, X
    LDA $24
    STA $26
    PHX 
    TAX 
    LDA $orbitAngle, X
    PLX 
    STA $currentHp, X
    LDA #$&enemy_stats_table+120
    STA $statsPtr, X
    LDA #$FFD8
    STA $7F100E, X
    LDA #$0000
    STA $7F100C, X
    LDA $16
    CLC 
    ADC #$0018
    STA $16
    LDA #$2000
    TRB $10
    COP [BranchOnPlayerY] ( #$0020, &code_0BB72D, &code_0BB724, &code_0BB72D )
}

code_0BB724 {
    LDA $playerYPos
    CLC 
    ADC #$0008
    BRA loc_0BB72F
}

code_0BB72D {
    LDA $16

  loc_0BB72F:
    STA $moveYAlt, X
    LDA $16
    CLC 
    ADC #$FFE8
    STA $16
    BRA loc_0BB79E
}

code_0BB73D {
    COP [StageSprAndHitbox] ( #19 )
    LDA #$FFD8
    STA $7F100E, X
    LDA $16
    CLC 
    ADC #$0050
    BRA loc_0BB75F
}

code_0BB74F {
    COP [StageSprAndHitbox] ( #1B )
    LDA #$FFD0
    STA $7F100E, X
    LDA $16
    CLC 
    ADC #$FFD0

  loc_0BB75F:
    STA $moveYAlt, X
    LDA $24
    STA $26
    PHX 
    TAX 
    LDA $orbitAngle, X
    PLX 
    STA $currentHp, X
    LDA #$&enemy_stats_table+120
    STA $statsPtr, X
    LDA #$0000
    STA $7F100C, X
    LDA #$2000
    TRB $10
    COP [BranchOnPlayerX] ( #$0020, &code_0BB798, &code_0BB78F, &code_0BB798 )
}

code_0BB78F {
    LDA $playerXPos
    CLC 
    ADC #$0008
    BRA loc_0BB79A
}

code_0BB798 {
    LDA $14

  loc_0BB79A:
    STA $moveXAlt, X

  loc_0BB79E:
    COP [SetDeathCallback] ( @code_0BB800 )
    COP [MoveToward] ( #FF, #02 )
    DEC $28
    LDY $26

  loc_0BB7AB:
    LDA $0014, Y
    CLC 
    ADC $7F100C, X
    STA $moveXAlt, X
    LDA $0016, Y
    CLC 
    ADC $7F100E, X
    STA $moveYAlt, X
    COP [MoveToward] ( #FF, #02 )
    LDY $26
    LDA $0014, Y
    CLC 
    ADC $7F100C, X
    SEC 
    SBC $14
    BPL loc_0BB7DA
    EOR #$FFFF
    INC 

  loc_0BB7DA:
    CMP #$0002
    BCS loc_0BB7AB
    LDA $0016, Y
    CLC 
    ADC $7F100E, X
    SEC 
    SBC $16
    BPL loc_0BB7F0
    EOR #$FFFF
    INC 

  loc_0BB7F0:
    CMP #$0002
    BCS loc_0BB7AB
    LDY $26
    LDA #$0000
    STA $0026, Y
    COP [SetEntryContinue]
    RTL 
}

code_0BB800 {
    LDY $26
    LDA #$0001
    STA $0026, Y
    COP [PlaySoundCh1] ( #06 )
    COP [SpawnLastRel] ( @EnemyDeathFlash, #00, #00, #$0302 )
    COP [SetEntryContinue]
    RTL 
}