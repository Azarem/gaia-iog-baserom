?BANK 0A

?INCLUDE 'binary_01C36C'
?INCLUDE 'chunk_008000'
?INCLUDE 'chunk_028000'
?INCLUDE 'chunk_058000'
?INCLUDE 'chunk_098000'
?INCLUDE 'chunk_3B7DD'
?INCLUDE 'scene_warps'
?INCLUDE 'stats_table'
?INCLUDE 'table_0EE000'

!extVelocityX                   0408
!extVelocityY                   040A
!rngModuloResult                0420
!sceneCurrent                   0644
!gfxCacheIdxA                   0648
!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!joypadRaw                      0660
!bg1ScrollH                     068A
!bg2ScrollH                     068E
!mapBoundsX                     0692
!effectBoundsX                  0694
!mapBoundsY                     0696
!effectBoundsY                  0698
!cameraTargetX                  06BE
!cameraDeltaX                   06C0
!cameraTargetY                  06C2
!cameraDeltaY                   06C4
!cameraBoundsX                  06DA
!cameraBoundsY                  06DC
!playerWallType                 09B0
!playerSpeedEw                  09B2
!playerSpeedNs                  09B4
!slopeStepCounter               09B6
!decelStepCounter               09B8
!slopeCurvePtrA                 09BA
!slopeCurvePtrB                 09BC
!characterForm                  0AD4
!COLDATA                        2132
!animScratch                    7F0000
!chatPtr                        7F000A
!metaspritePtr                  7F000C
!animScratch2                   7F000E
!orbitAngle                     7F0010
!orbitDiameter                  7F0012
!loopCounter                    7F0014
!sprTimer                       7F0016
!moveXAlt                       7F0018
!moveYAlt                       7F001A
!parentId                       7F001C
!statsPtr                       7F0020
!deathActionIdx                 7F0024
!currentHp                      7F0026
!iframeCounter                  7F0028
!extendedFlags                  7F002A
!moveScratch1                   7F002C
!moveScratch2                   7F002E
!onHitCallback                  7F1000
!onDodgeCallback                7F1002
!scratch1010                    7F1010
!free101C                       7F101C

---------------------------------------------

actor_def_0A8000 [
  actor-def < #22, #08, #20, {

  code_0A8003:
    LDA #$0011
    TSB $12

  code_0A8008:
    COP [WaitWhileOffscreen] ( #18 )
    LDA #$2000
    TSB $10
    COP [WaitByte] ( #77 )
    LDA #$2000
    TRB $10
    COP [SpawnMarkedAfter] ( @code_0A8264, #$0301 )
    LDA #$2000
    TSB $10
    COP [WaitByte] ( #3F )
    LDA #$2000
    TRB $10
    COP [StageSpriteFrame] ( #22 )
    COP [AnimOnce]
    COP [SpawnMarkedAfter] ( @code_0A825C, #$0301 )
    COP [BranchIfDirToPlayerFrom] ( #00, #F0, #04, &code_0A80D1 )
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]
    COP [BranchIfDirToPlayerFrom] ( #00, #F0, #05, &code_0A80EC )
    COP [StageSpriteFrame] ( #24 )
    COP [AnimOnce]
    COP [BranchIfDirToPlayerFrom] ( #00, #F0, #06, &code_0A8107 )
    COP [StageSpriteFrame] ( #25 )
    COP [AnimOnce]
    COP [BranchIfDirToPlayerFrom] ( #00, #F0, #07, &code_0A8122 )
    COP [StageSpriteFrame] ( #26 )
    COP [AnimOnce]
    COP [BranchIfDirToPlayerFrom] ( #00, #F0, #00, &code_0A813D )
    COP [StageSpriteFrame] ( #27 )
    COP [AnimOnce]
    COP [BranchIfDirToPlayerFrom] ( #00, #F0, #01, &code_0A8158 )
    COP [StageSpriteFrame] ( #28 )
    COP [AnimOnce]
    COP [BranchIfDirToPlayerFrom] ( #00, #F0, #02, &code_0A8173 )
    COP [StageSpriteFrame] ( #29 )
    COP [AnimOnce]
    COP [BranchIfDirToPlayerFrom] ( #00, #F0, #03, &code_0A818E )
    COP [StageSpriteFrame] ( #2A )
    COP [AnimOnce]
    JMP $&code_0A80C3
} >
]

code_0A809B {
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]

  code_0A80A0:
    COP [StageSpriteFrame] ( #24 )
    COP [AnimOnce]

  code_0A80A5:
    COP [StageSpriteFrame] ( #25 )
    COP [AnimOnce]

  code_0A80AA:
    COP [StageSpriteFrame] ( #26 )
    COP [AnimOnce]

  code_0A80AF:
    COP [StageSpriteFrame] ( #27 )
    COP [AnimOnce]

  code_0A80B4:
    COP [StageSpriteFrame] ( #A8 )
    COP [AnimOnce]

  code_0A80B9:
    COP [StageSpriteFrame] ( #A9 )
    COP [AnimOnce]

  code_0A80BE:
    COP [StageSpriteFrame] ( #AA )
    COP [AnimOnce]
}

code_0A80C3 {
    COP [StageSpriteLoop] ( #2B, #04 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #35 )
    COP [AnimOnce]
    JMP $&code_0A8008
}

code_0A80D1 {
    COP [StageSpriteFrame] ( #2B )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @code_0A81A9, #00, #D8, #$0202 )
    COP [ForceMoveLastChild] ( #00, #03 )
    COP [StageSpriteLoop] ( #2B, #02 )
    COP [AnimLoop]
    JMP $&code_0A80A0
}

code_0A80EC {
    COP [StageSpriteFrame] ( #2C )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @code_0A81A9, #FC, #D8, #$0202 )
    COP [ForceMoveLastChild] ( #04, #03 )
    COP [StageSpriteLoop] ( #2C, #02 )
    COP [AnimLoop]
    JMP $&code_0A80A5
}

code_0A8107 {
    COP [StageSpriteFrame] ( #2D )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @code_0A81A9, #F8, #D8, #$0202 )
    COP [ForceMoveLastChild] ( #04, #00 )
    COP [StageSpriteLoop] ( #2D, #02 )
    COP [AnimLoop]
    JMP $&code_0A80AA
}

code_0A8122 {
    COP [StageSpriteFrame] ( #2E )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @code_0A81A9, #FC, #D8, #$0200 )
    COP [ForceMoveLastChild] ( #04, #04 )
    COP [StageSpriteLoop] ( #2E, #02 )
    COP [AnimLoop]
    JMP $&code_0A80AF
}

code_0A813D {
    COP [StageSpriteFrame] ( #2F )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @code_0A81A9, #00, #D8, #$0200 )
    COP [ForceMoveLastChild] ( #00, #04 )
    COP [StageSpriteLoop] ( #2F, #02 )
    COP [AnimLoop]
    JMP $&code_0A80B4
}

code_0A8158 {
    COP [StageSpriteFrame] ( #B0 )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @code_0A81A9, #04, #D8, #$0200 )
    COP [ForceMoveLastChild] ( #03, #04 )
    COP [StageSpriteLoop] ( #B0, #02 )
    COP [AnimLoop]
    JMP $&code_0A80B9
}

code_0A8173 {
    COP [StageSpriteFrame] ( #B1 )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @code_0A81A9, #08, #D8, #$0202 )
    COP [ForceMoveLastChild] ( #03, #00 )
    COP [StageSpriteLoop] ( #B1, #02 )
    COP [AnimLoop]
    JMP $&code_0A80BE
}

code_0A818E {
    COP [StageSpriteFrame] ( #B2 )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @code_0A81A9, #04, #D8, #$0202 )
    COP [ForceMoveLastChild] ( #03, #03 )
    COP [StageSpriteLoop] ( #B2, #02 )
    COP [AnimLoop]
    JMP $&code_0A80C3
}

code_0A81A9 {
    LDA #$0080
    TSB $12
    COP [SpawnLastRel] ( @code_0A8250, #00, #00, #$0300 )
    LDA $0010, Y
    ORA $10
    STA $0010, Y
    COP [OrActorFlags] ( #$0010 )
    COP [SpawnMarkedAfter] ( @code_0A822B, #$2200 )
    LDA #$0002
    JSR $&code_0A8200
    COP [SpawnMarkedAfter] ( @code_0A822B, #$2200 )
    LDA #$0003
    JSR $&code_0A8200
    COP [SetMetasprite] ( @table_0EE000 )
    COP [SetSpritePriority] ( #30 )
    COP [PlaySoundCh1] ( #1E )
    COP [StageSpriteLoop] ( #08, #02 )
    COP [AnimLoop]
    COP [CollPriorityClearMax]

  loc_0A81F0:
    COP [ReloadForceMove]
    COP [StageSpriteFrame] ( #08 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_0A81F0
    COP [Die]
}

code_0A8200 {
    STA $0008, Y
    LDA $0010, Y
    ORA $10
    STA $0010, Y
    LDA $2C
    STA $002C, Y
    LDA $2E
    STA $002E, Y
    PHX 
    LDA $moveXAlt, X
    PHA 
    LDA $moveYAlt, X
    TYX 
    STA $moveYAlt, X
    PLA 
    STA $moveXAlt, X
    PLX 
    RTS 
}

code_0A822B {
    LDA #$2000
    TRB $10
    COP [SetSpritePriority] ( #30 )
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteLoop] ( #26, #02 )
    COP [AnimLoop]
    COP [CollPriorityClearMax]

  loc_0A8240:
    COP [ReloadForceMove]
    COP [StageSpriteFrame] ( #26 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_0A8240
    COP [Die]
}

code_0A8250 {
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #07 )
    COP [AnimOnce]
    COP [Die]
}

code_0A825C {
    COP [StageSpriteLoop] ( #34, #09 )
    COP [AnimLoop]
    COP [Die]
}

code_0A8264 {
    COP [StageSpriteLoop] ( #33, #06 )
    COP [AnimLoop]
    COP [Die]
}

actor_def_0A826C [
  actor-def < #00, #00, #00, {

  code_0A826F:
    COP [WaitWhileOffscreen] ( #08 )
    COP [SetSpritePriority] ( #30 )
    COP [SetEntryExit]

  code_0A8277:
    COP [RngByte]
    STA $orbitAngle, X
    LDA $orbitDiameter, X
    BMI loc_0A82C3
    INC 
    AND #$0003
    STA $orbitDiameter, X
    COP [SetHitCallback] ( &code_0A82B6 )
    COP [BranchIfPlayerNear] ( #04, &code_0A82B6 )
    LDA $orbitAngle, X
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0A82A4 )
} >
]

code_list_0A82A4 [
  &code_0A82DE   ;00
  &code_0A8311   ;01
  &code_0A8344   ;02
  &code_0A8377   ;03
  &code_0AC202   ;04
  $#2302   ;05
  $#109F   ;06
  $#7F00   ;07
  &code_0ADE80   ;08
]

code_0A82B6 {
    COP [SetHitCallback] ( #$0000 )
    COP [SnapToGrid]
    LDA #$FFFF
    STA $orbitDiameter, X

  loc_0A82C3:
    COP [BranchNearerAxis] ( &code_0A82C9, &code_0A82D3 )
}

code_0A82C9 {
    COP [BranchOnPlayerX] ( #$0008, &code_0A82DE, &code_0A82D3, &code_0A8311 )
}

code_0A82D3 {
    COP [BranchOnPlayerY] ( #$0008, &code_0A8344, &code_0A82DD, &code_0A8377 )
}

code_0A82DD {
    RTL 
}

code_0A82DE {
    LDA $orbitAngle, X
    AND #$0001
    BEQ code_0A82EC
    COP [BranchIfPlayerNear] ( #02, &code_0A83AA )

  code_0A82EC:
    COP [BranchIfSolidWest] ( &code_0A82AC )
    COP [StageSpriteMoveX] ( #07, #12 )
    COP [AnimOnce]
    LDA $orbitDiameter, X
    BEQ loc_0A82FF
    JMP $&code_0A8277

  loc_0A82FF:
    COP [LoopInit] ( #02 )
    COP [StageSpriteFrame] ( #0B )
    COP [AnimOnce]
    COP [BranchIfPlayerNear] ( #04, &code_0A82B6 )
    COP [LoopNext]
    JMP $&code_0A8277
}

code_0A8311 {
    LDA $orbitAngle, X
    AND #$0001
    BEQ code_0A831F
    COP [BranchIfPlayerNear] ( #02, &code_0A83CE )

  code_0A831F:
    COP [BranchIfSolidEast] ( &code_0A82AC )
    COP [StageSpriteMoveX] ( #87, #11 )
    COP [AnimOnce]
    LDA $orbitDiameter, X
    BEQ loc_0A8332
    JMP $&code_0A8277

  loc_0A8332:
    COP [LoopInit] ( #02 )
    COP [StageSpriteFrame] ( #8B )
    COP [AnimOnce]
    COP [BranchIfPlayerNear] ( #04, &code_0A82B6 )
    COP [LoopNext]
    JMP $&code_0A8277
}

code_0A8344 {
    LDA $orbitAngle, X
    AND #$0001
    BEQ code_0A8352
    COP [BranchIfPlayerNear] ( #02, &code_0A83F2 )

  code_0A8352:
    COP [BranchIfSolidNorth] ( &code_0A82AC )
    COP [StageSpriteMoveY] ( #05, #12 )
    COP [AnimOnce]
    LDA $orbitDiameter, X
    BEQ loc_0A8365
    JMP $&code_0A8277

  loc_0A8365:
    COP [LoopInit] ( #02 )
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    COP [BranchIfPlayerNear] ( #04, &code_0A82B6 )
    COP [LoopNext]
    JMP $&code_0A8277
}

code_0A8377 {
    LDA $orbitAngle, X
    AND #$0001
    BEQ code_0A8385
    COP [BranchIfPlayerNear] ( #02, &code_0A8416 )

  code_0A8385:
    COP [BranchIfSolidSouth] ( &code_0A82AC )
    COP [StageSpriteMoveY] ( #03, #11 )
    COP [AnimOnce]
    LDA $orbitDiameter, X
    BEQ loc_0A8398
    JMP $&code_0A8277

  loc_0A8398:
    COP [LoopInit] ( #02 )
    COP [StageSpriteFrame] ( #09 )
    COP [AnimOnce]
    COP [BranchIfPlayerNear] ( #04, &code_0A82B6 )
    COP [LoopNext]
    JMP $&code_0A8277
}

code_0A83AA {
    COP [SetHitCallback] ( #$0000 )
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @code_0A843C, #F8, #E0, #$0200 )
    COP [ForceMoveLastChild] ( #04, #00 )
    COP [StageSpriteFrame] ( #1B )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #02, #20 )
    COP [AnimLoop]
    JMP $&code_0A82EC
}

code_0A83CE {
    COP [SetHitCallback] ( #$0000 )
    COP [StageSpriteFrame] ( #9A )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @code_0A843C, #08, #E0, #$0200 )
    COP [ForceMoveLastChild] ( #03, #00 )
    COP [StageSpriteFrame] ( #9B )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #82, #20 )
    COP [AnimLoop]
    JMP $&code_0A831F
}

code_0A83F2 {
    COP [SetHitCallback] ( #$0000 )
    COP [StageSpriteFrame] ( #18 )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @code_0A843C, #00, #D0, #$0200 )
    COP [ForceMoveLastChild] ( #00, #04 )
    COP [StageSpriteFrame] ( #19 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #01, #20 )
    COP [AnimLoop]
    JMP $&code_0A8352
}

code_0A8416 {
    COP [SetHitCallback] ( #$0000 )
    COP [StageSpriteFrame] ( #16 )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @code_0A843A, #00, #E0, #$0200 )
    COP [ForceMoveLastChild] ( #00, #03 )
    COP [StageSpriteFrame] ( #17 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #00, #20 )
    COP [AnimLoop]
    JMP $&code_0A8385
}

code_0A843A {
    COP [CollPrioritySetMax]
}

code_0A843C {
    COP [OrActorFlags] ( #$0010 )
    LDA #$0080
    TSB $12
    COP [PlaySoundCh1] ( #1E )
    COP [StageSpriteLoop] ( #1C, #02 )
    COP [AnimLoop]
    COP [CollPriorityClearMax]
    COP [StageSpriteLoop] ( #1C, #02 )
    COP [AnimLoop]
    LDA $decelStepCounter
    STA $24
    LDA #$001C
    STA $0028, X
    LDA #$0001
    STA $loopCounter, X
    SEP #$20
    LDA #$80
    PHA 
    REP #$20
    LDA #$E5D1
    PHA 
    RTL 
}

actor_def_0A8474 [
  actor-def < #00, #00, #00, {

  code_0A8477:
    COP [SetSpritePalette] ( #0C )
    COP [SetSpritePriority] ( #30 )
    COP [WaitWhileOffscreen] ( #08 )
    COP [SetDeathCallback] ( @code_0A853C )
    COP [SetEntryExit]

  code_0A8487:
    COP [BranchNearerAxis] ( &code_0A848D, &code_0A8497 )
} >
]

code_0A848D {
    COP [BranchOnPlayerX] ( #$0008, &code_0A84BA, &code_0A8497, &code_0A84DA )
}

code_0A8497 {
    COP [BranchOnPlayerY] ( #$0008, &code_0A84FA, &code_0A84A1, &code_0A851B )
}

code_0A84A1 {
    RTL 
}

code_0A84A2 {
    COP [SetEntryExit]
    COP [RngByte]
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0A84B2 )
}

code_list_0A84B2 [
  &code_0A84BA   ;00
  &code_0A84DA   ;01
  &code_0A84FA   ;02
  &code_0A851B   ;03
]

code_0A84BA {
    COP [BranchIfSolidWest] ( &code_0A84A2 )
    COP [StageSprAndHitbox] ( #07 )
    COP [StageForceMoveX] ( #02 )
    COP [SetEntryContinue]
    COP [ContinueIfFrame] ( #02 )
    COP [SetEntryExit]
    STZ $2C
    COP [BranchIfSolidWest] ( &code_0A84A2 )
    COP [StageForceMoveX] ( #02 )
    COP [SetEntryContinue]
    COP [AnimOnce]
    BRA code_0A8487
}

code_0A84DA {
    COP [BranchIfSolidEast] ( &code_0A84A2 )
    COP [StageSprAndHitbox] ( #87 )
    COP [StageForceMoveX] ( #01 )
    COP [SetEntryContinue]
    COP [ContinueIfFrame] ( #02 )
    COP [SetEntryExit]
    STZ $2C
    COP [BranchIfSolidEast] ( &code_0A84A2 )
    COP [StageForceMoveX] ( #01 )
    COP [SetEntryContinue]
    COP [AnimOnce]
    BRA code_0A8487
}

code_0A84FA {
    COP [BranchIfSolidNorth] ( &code_0A84A2 )
    COP [StageSprAndHitbox] ( #05 )
    COP [StageForceMoveY] ( #02 )
    COP [SetEntryContinue]
    COP [ContinueIfFrame] ( #02 )
    COP [SetEntryExit]
    STZ $2E
    COP [BranchIfSolidNorth] ( &code_0A84A2 )
    COP [StageForceMoveY] ( #02 )
    COP [SetEntryContinue]
    COP [AnimOnce]
    JMP $&code_0A8487
}

code_0A851B {
    COP [BranchIfSolidSouth] ( &code_0A84A2 )
    COP [StageSprAndHitbox] ( #03 )
    COP [StageForceMoveY] ( #01 )
    COP [SetEntryContinue]
    COP [ContinueIfFrame] ( #02 )
    COP [SetEntryExit]
    STZ $2E
    COP [BranchIfSolidSouth] ( &code_0A84A2 )
    COP [StageForceMoveY] ( #01 )
    COP [SetEntryContinue]
    COP [AnimOnce]
    JMP $&code_0A8487
}

code_0A853C {
    COP [SpawnAfterFlags] ( @code_0A854A, #$0300 )
    COP [SetEntryDelayExit] ( @code_0A8561, #$0002 )
}

code_0A854A {
    COP [PlaySoundCh1] ( #06 )
    COP [SetMetasprite] ( @table_0EE000 )
    COP [SetSpritePalette] ( #00 )
    LDA #$0002
    TSB $10
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    COP [Die]
}

code_0A8561 {
    COP [SetSpritePalette] ( #00 )
    COP [SetSpritePriority] ( #30 )
    COP [SetDeathCallback] ( $000000 )
    LDA #$AC1C
    STA $statsPtr, X
    LDA $@stats_table+44
    AND #$00FF
    STA $currentHp, X
    LDA #$0340
    TRB $10
    COP [AddPosition] ( #00, #E0 )

  loc_0A8587:
    LDA $orbitAngle, X
    AND #$0003
    BNE loc_0A8596
    COP [StageSpriteLoop] ( #0D, #0C )
    COP [AnimLoop]

  loc_0A8596:
    LDA $orbitAngle, X
    INC 
    STA $orbitAngle, X
    COP [BranchOnPlayerX] ( #$0000, &code_0A85A9, &code_0A85A9, &code_0A85CF )
}

code_0A85A9 {
    COP [BranchOnPlayerY] ( #$0000, &code_0A85B3, &code_0A85B3, &code_0A85C1 )
}

code_0A85B3 {
    COP [StageSpriteMoveXY] ( #0C, #29, #02 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0C )
    COP [AnimOnce]
    BRA loc_0A8587
}

code_0A85C1 {
    COP [StageSpriteMoveXY] ( #0C, #29, #01 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0C )
    COP [AnimOnce]
    BRA loc_0A8587
}

code_0A85CF {
    COP [BranchOnPlayerY] ( #$0000, &code_0A85D9, &code_0A85D9, &code_0A85E7 )
}

code_0A85D9 {
    COP [StageSpriteMoveXY] ( #0C, #2B, #02 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0C )
    COP [AnimOnce]
    BRA loc_0A8587
}

code_0A85E7 {
    COP [StageSpriteMoveXY] ( #0C, #2B, #01 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0C )
    COP [AnimOnce]
    BRA loc_0A8587
}

actor_def_0A85F5 [
  actor-def < #1F, #00, #00, {

  code_0A85F8:
    COP [BranchIfFlagWord] ( #$0105, #01, &code_0A8774 )
    LDA #$0010
    TSB $12
    COP [SetSpritePriority] ( #30 )
    COP [SetSpritePalette] ( #02 )
    COP [AddPosition] ( #08, #00 )
    COP [WaitWhileOffscreen] ( #10 )
    COP [SetEntryContinue]
    JSR $&code_0A8754
    BCC loc_0A8619
    RTL 

  loc_0A8619:
    COP [StageSpriteLoopMoveY] ( #1F, #02, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1F, #02 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #20, #02, #02 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1F, #02 )
    COP [AnimLoop]

  loc_0A8633:
    COP [StageSpriteMoveX] ( #21, #04 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #1F, #03 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #A1, #02, #03 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #9F, #03 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #21, #02, #04 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #20, #04 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #A1, #02, #03 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #A0, #04 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #21, #04 )
    COP [AnimOnce]
    BRA loc_0A8633
} >
]

actor_def_0A866E [
  actor-def < #1F, #00, #00, {

  code_0A8671:
    COP [BranchIfFlagWord] ( #$0105, #01, &code_0A8774 )
    JSR $&code_0A8764
    COP [WaitWhileOffscreen] ( #10 )
    COP [SetEntryContinue]
    JSR $&code_0A8754
    BCC loc_0A8686
    RTL 

  loc_0A8686:
    COP [StageSpriteMoveX] ( #21, #02 )
    COP [AnimOnce]

  loc_0A868C:
    COP [StageSpriteMoveY] ( #1F, #03 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #A1, #03 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #A0, #04 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #21, #04 )
    COP [AnimOnce]
    BRA loc_0A868C
} >
]

actor_def_0A86A6 [
  actor-def < #1F, #00, #00, {

  code_0A86A9:
    COP [BranchIfFlagWord] ( #$0105, #01, &code_0A8774 )
    JSR $&code_0A8764
    COP [WaitWhileOffscreen] ( #10 )
    COP [SetEntryContinue]
    JSR $&code_0A8754
    BCC loc_0A86BE
    RTL 

  loc_0A86BE:
    COP [StageSpriteMoveX] ( #A1, #01 )
    COP [AnimOnce]

  loc_0A86C4:
    COP [StageSpriteMoveY] ( #1F, #03 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #21, #04 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #20, #04 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #A1, #03 )
    COP [AnimOnce]
    BRA loc_0A86C4
} >
]

actor_def_0A86DE [
  actor-def < #1F, #00, #00, {

  code_0A86E1:
    COP [BranchIfFlagWord] ( #$0105, #01, &code_0A8774 )
    JSR $&code_0A8764
    COP [WaitWhileOffscreen] ( #10 )
    COP [SetEntryContinue]
    JSR $&code_0A8754
    BCC loc_0A86F6
    RTL 

  loc_0A86F6:
    COP [StageSpriteLoopMoveX] ( #21, #02, #02 )
    COP [AnimLoop]

  loc_0A86FD:
    COP [StageSpriteLoopMoveY] ( #1F, #02, #03 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #A1, #03 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveY] ( #20, #02, #04 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #21, #04 )
    COP [AnimOnce]
    BRA loc_0A86FD
} >
]

actor_def_0A8719 [
  actor-def < #1F, #00, #00, {

  code_0A871C:
    COP [BranchIfFlagWord] ( #$0105, #01, &code_0A8774 )
    JSR $&code_0A8764
    COP [WaitWhileOffscreen] ( #10 )
    COP [SetEntryContinue]
    JSR $&code_0A8754
    BCC loc_0A8731
    RTL 

  loc_0A8731:
    COP [StageSpriteLoopMoveX] ( #A1, #02, #01 )
    COP [AnimLoop]

  loc_0A8738:
    COP [StageSpriteLoopMoveY] ( #1F, #02, #03 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #21, #04 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveY] ( #20, #02, #04 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #A1, #03 )
    COP [AnimOnce]
    BRA loc_0A8738
} >
]

code_0A8754 {
    LDA $16
    SEC 
    SBC $playerSpeedEw
    BPL loc_0A8760
    EOR #$FFFF
    INC 

  loc_0A8760:
    CMP #$003C
    RTS 
}

code_0A8764 {
    LDA #$0010
    TSB $12
    COP [SetSpritePriority] ( #30 )
    COP [SetSpritePalette] ( #00 )
    COP [AddPosition] ( #08, #00 )
    RTS 
}

code_0A8774 {
    COP [Die]
}

actor_def_0A8776 [
  actor-def < #1F, #00, #00, {

  code_0A8779:
    COP [WaitWhileOffscreen] ( #0C )
    COP [SetSpritePriority] ( #30 )

  code_0A877F:
    COP [WaitWhileOffscreen] ( #01 )
    COP [SetEntryExit]

  code_0A8784:
    COP [RngByte]
    AND #$0003
    DEC 
    BMI loc_0A8793
    BEQ loc_0A87A7
    DEC 
    BEQ loc_0A87BB
    BRA loc_0A87CF

  loc_0A8793:
    COP [BranchIfSolidSouth] ( &code_0A877F )
    LDA $16
    CMP $mapBoundsY
    BCS code_0A877F
    COP [StageSpriteMoveXY] ( #1F, #00, #11 )
    COP [AnimOnce]
    BRA code_0A8784

  loc_0A87A7:
    COP [BranchIfSolidNorth] ( &code_0A877F )
    LDA $16
    CMP #$0010
    BCC code_0A877F
    COP [StageSpriteMoveXY] ( #20, #00, #12 )
    COP [AnimOnce]
    BRA code_0A8784

  loc_0A87BB:
    COP [BranchIfSolidWest] ( &code_0A877F )
    LDA $14
    CMP #$0010
    BCC code_0A877F
    COP [StageSpriteMoveXY] ( #21, #12, #00 )
    COP [AnimOnce]
    BRA code_0A8784

  loc_0A87CF:
    COP [BranchIfSolidEast] ( &code_0A877F )
    LDA $14
    CMP $mapBoundsX
    BCS code_0A877F
    COP [StageSpriteMoveXY] ( #A1, #11, #00 )
    COP [AnimOnce]
    JMP $&code_0A8784
} >
]

actor_def_0A87E4 [
  actor-def < #38, #02, #23, {

  code_0A87E7:
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #03, &code_0A87FA )
    RTL 
} >
]

actor_def_0A87EF [
  actor-def < #38, #02, #23, {

  code_0A87F2:
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #01, &code_0A87FA )
    RTL 
} >
]

code_0A87FA {
    COP [RngByte]
    AND #$003F
    STA $08
    COP [SetEntryExit]
    COP [SpawnMarkedAfter] ( @code_0A884E, #$0301 )
    LDA $16
    SEC 
    SBC #$0100
    STA $16
    LDA #$2000
    TRB $10
    COP [PlaySoundCh1] ( #13 )
    COP [StageSpriteMoveY] ( #39, #0F )
    COP [AnimOnce]
    LDA #$0100
    TRB $10
    COP [PlaySoundCh1] ( #1E )
    COP [CollPriorityClearMax]
    COP [StageSpriteFrame] ( #3A )
    COP [AnimOnce]
    COP [SolidHighHere]
    LDA #$0100
    TSB $10
    COP [WaitByte] ( #EF )
    COP [LoopInit] ( #20 )
    LDA #$2000
    TSB $10
    COP [SetEntryExit]
    LDA #$2000
    TRB $10
    COP [LoopNext]
    COP [ClearLowHere]
    COP [Die]
}

code_0A884E {
    COP [StageSpriteFrame] ( #3B )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
}

actor_def_0A8856 [
  actor-def < #36, #00, #10, {

  code_0A8859:
    LDA #$0200
    TSB $12
    COP [BranchIfFlagByte] ( #21, #00, &code_0A8868 )
    COP [SetOnInteract] ( &code_0A8874 )
} >
]

code_0A8868 {
    COP [SolidHighHere]
    COP [SpawnMarkedAfter] ( @chunk_008000.code_00E34D, #$2300 )
    COP [SetEntryContinue]
    RTL 
}

code_0A8874 {
    COP [PrintWideString] ( &widestring_0A8879 )
    RTL 
}

widestring_0A8879 `[DLG:3,11][SIZ:D,4,1][TPL:0]これは 海岸のどうくつにあった[N]石像と 同じ形だ···[PAL:0][END]`

actor_def_0A88A6 [
  actor-def < #1E, #00, #01, {

  code_0A88A9:
    LDA #$ABD8
    STA $statsPtr, X
    LDA #$1111
    STA $20
    STA $22
    LDA #$0031
    TSB $12
    COP [OrActorFlags] ( #$0008 )
    COP [SolidHighHere]
    COP [SpawnMarkedAfter] ( @chunk_008000.code_00E34D, #$2300 )

  loc_0A88C9:
    LDA #$00FF
    STA $currentHp, X
    COP [SetEntryContinue]
    LDA $currentHp, X
    CMP #$00FF
    BNE loc_0A88DC
    RTL 

  loc_0A88DC:
    LDA $slopeCurvePtrB
    BIT #$0002
    BNE loc_0A88E9
    DEC $24
    BMI loc_0A88C9
    RTL 

  loc_0A88E9:
    COP [JumpScript] ( @chunk_008000.code_00DCD5 )
} >
]

actor_def_0A88EE [
  actor-def < #1E, #00, #01, {

  code_0A88F1:
    COP [BranchIfFlagByte] ( #B9, #01, &code_0A893F )
    LDA #$ABD8
    STA $statsPtr, X
    LDA #$1111
    STA $20
    STA $22
    LDA #$0031
    TSB $12
    COP [OrActorFlags] ( #$0008 )
    COP [SolidHighHere]
    COP [SpawnMarkedAfter] ( @chunk_008000.code_00E34D, #$2300 )

  loc_0A8917:
    LDA #$00FF
    STA $currentHp, X
    COP [SetEntryContinue]
    LDA $currentHp, X
    CMP #$00FF
    BNE loc_0A892A
    RTL 

  loc_0A892A:
    LDA $slopeCurvePtrB
    BIT #$0002
    BNE loc_0A8937
    DEC $24
    BMI loc_0A8917
    RTL 

  loc_0A8937:
    COP [SetFlagByte] ( #B9 )
    COP [JumpScript] ( @chunk_008000.code_00DCD5 )
} >
]

code_0A893F {
    COP [Die]
}

actor_def_0A8941 [
  actor-def < #0F, #01, #01, {

  code_0A8944:
    LDA #$ACF0
    STA $statsPtr, X
    LDA #$0031
    TSB $12
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [SolidHighHere]
    LDA #$00FF
    STA $currentHp, X

  code_0A8963:
    COP [ClearFlagByte] ( #01 )
    COP [SetHitCallback] ( &code_0A8972 )
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
} >
]

code_0A8972 {
    COP [SetFlagByte] ( #01 )
    COP [SetHitCallback] ( &code_0A8963 )
    COP [StageSpriteFrame] ( #10 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
}

actor_def_0A8981 [
  actor-def < #0F, #01, #03, {

  code_0A8984:
    COP [SetMetasprite] ( @table_0EE000 )

  loc_0A8989:
    COP [SetEntryContinue]
    COP [BranchIfPlayerAt] ( #$00D8, #$0298, &code_0A89AD )
    COP [BranchIfPlayerNear] ( #01, &code_0A899F )
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    BRA loc_0A8989
} >
]

code_0A899F {
    COP [PrintWideString] ( &widestring_0A89CF )
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #01, &code_0A89AC )
    BRA loc_0A8989
}

code_0A89AC {
    RTL 
}

code_0A89AD {
    COP [WaitByte] ( #0F )
    COP [StageSpriteFrame] ( #10 )
    COP [AnimOnce]
    COP [WaitByte] ( #0F )
    COP [BranchIfFlagWord] ( #$0104, #01, &code_0A89CC )
    COP [PlaySoundBoth] ( #$0E0E )
    COP [StageBgChange] ( #04 )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0104 )
}

code_0A89CC {
    COP [SetEntryContinue]
    RTL 
}

widestring_0A89CF `[TPL:E][TPL:0]かたくて おしこめないっ![N]さびついているようだな···[PAL:0][END]`

actor_def_0A89F2 [
  actor-def < #3C, #10, #00, {

  loc_0A89F5:
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveY] ( #3E, #04, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #3E, #04, #11 )
    COP [AnimLoop]
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #01, #00 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveX] ( #3E, #04, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #3E, #04, #11 )
    COP [AnimLoop]
    BRA loc_0A89F5
} >
]

actor_def_0A8A23 [
  actor-def < #3C, #10, #00, {

  loc_0A8A26:
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveY] ( #3E, #02, #12 )
    COP [AnimLoop]
    COP [WaitByte] ( #1F )
    COP [StageSpriteLoopMoveX] ( #3E, #02, #11 )
    COP [AnimLoop]
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #01, #00 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveX] ( #3E, #02, #12 )
    COP [AnimLoop]
    COP [WaitByte] ( #1F )
    COP [StageSpriteLoopMoveY] ( #3E, #02, #11 )
    COP [AnimLoop]
    BRA loc_0A8A26
} >
]

actor_def_0A8A5A [
  actor-def < #3C, #10, #00, {

  loc_0A8A5D:
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveX] ( #3E, #02, #12 )
    COP [AnimLoop]
    COP [WaitByte] ( #1F )
    COP [StageSpriteLoopMoveY] ( #3E, #02, #12 )
    COP [AnimLoop]
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #01, #00 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveY] ( #3E, #02, #11 )
    COP [AnimLoop]
    COP [WaitByte] ( #1F )
    COP [StageSpriteLoopMoveX] ( #3E, #02, #11 )
    COP [AnimLoop]
    BRA loc_0A8A5D
} >
]

actor_def_0A8A91 [
  actor-def < #3C, #10, #00, {

  loc_0A8A94:
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveX] ( #3E, #04, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #3E, #04, #12 )
    COP [AnimLoop]
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #01, #00 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveY] ( #3E, #04, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #3E, #04, #11 )
    COP [AnimLoop]
    BRA loc_0A8A94
} >
]

actor_def_0A8AC2 [
  actor-def < #3C, #10, #00, {

  code_0A8AC5:
    LDA #$ABF8
    STA $statsPtr, X
    LDA $0E
    PHA 
    AND #$3FFF
    STA $0E
    PLA 
    AND #$C000
    CMP #$4000
    BEQ loc_0A8B1D
    CMP #$8000
    BEQ loc_0A8B0B
    CMP #$C000
    BEQ loc_0A8AF9

  loc_0A8AE7:
    COP [BranchIfSolidWest] ( &code_0A8AED )
    BRA loc_0A8B03
} >
]

code_0A8AED {
    COP [BranchIfSolidNorth] ( &code_0A8B23 )

  loc_0A8AF1:
    COP [StageSpriteMoveY] ( #3E, #02 )
    COP [AnimOnce]
    BRA loc_0A8AE7

  loc_0A8AF9:
    COP [BranchIfSolidSouth] ( &code_0A8AFF )
    BRA loc_0A8B15
}

code_0A8AFF {
    COP [BranchIfSolidWest] ( &code_0A8AED )

  loc_0A8B03:
    COP [StageSpriteMoveX] ( #3E, #02 )
    COP [AnimOnce]
    BRA loc_0A8AF9

  loc_0A8B0B:
    COP [BranchIfSolidEast] ( &code_0A8B11 )
    BRA loc_0A8B27
}

code_0A8B11 {
    COP [BranchIfSolidSouth] ( &code_0A8AFF )

  loc_0A8B15:
    COP [StageSpriteMoveY] ( #3E, #01 )
    COP [AnimOnce]
    BRA loc_0A8B0B

  loc_0A8B1D:
    COP [BranchIfSolidNorth] ( &code_0A8B23 )
    BRA loc_0A8AF1
}

code_0A8B23 {
    COP [BranchIfSolidEast] ( &code_0A8B11 )

  loc_0A8B27:
    COP [StageSpriteMoveX] ( #3E, #01 )
    COP [AnimOnce]
    BRA loc_0A8B1D
}

actor_def_0A8B2F [
  actor-def < #00, #00, #00, {

  code_0A8B32:
    COP [WaitWhileOffscreen] ( #10 )

  code_0A8B35:
    COP [SetEntryExit]

  code_0A8B37:
    COP [BranchNearerAxis] ( &code_0A8B3D, &code_0A8B47 )
} >
]

code_0A8B3D {
    COP [BranchOnPlayerX] ( #$0008, &code_0A8B6A, &code_0A8B47, &code_0A8B85 )
}

code_0A8B47 {
    COP [BranchOnPlayerY] ( #$0008, &code_0A8BA0, &code_0A8B51, &code_0A8BBC )
}

code_0A8B51 {
    RTL 
}

code_0A8B52 {
    COP [SetEntryExit]
    COP [RngByte]
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0A8B62 )
}

code_list_0A8B62 [
  &code_0A8B6A   ;00
  &code_0A8B85   ;01
  &code_0A8BA0   ;02
  &code_0A8BBC   ;03
]

code_0A8B6A {
    COP [BranchIfPlayerNear] ( #03, &code_0A8BD8 )
    COP [BranchIfSolidWest] ( &code_0A8B52 )
    COP [StageSpriteMoveX] ( #07, #12 )
    COP [AnimOnce]
    COP [BranchIfSolidWest] ( &code_0A8B52 )
    COP [StageSpriteMoveX] ( #08, #12 )
    COP [AnimOnce]
    BRA code_0A8B37
}

code_0A8B85 {
    COP [BranchIfPlayerNear] ( #03, &code_0A8C03 )
    COP [BranchIfSolidEast] ( &code_0A8B52 )
    COP [StageSpriteMoveX] ( #87, #11 )
    COP [AnimOnce]
    COP [BranchIfSolidEast] ( &code_0A8B52 )
    COP [StageSpriteMoveX] ( #88, #11 )
    COP [AnimOnce]
    BRA code_0A8B37
}

code_0A8BA0 {
    COP [BranchIfPlayerNear] ( #03, &code_0A8C2E )
    COP [BranchIfSolidNorth] ( &code_0A8B52 )
    COP [StageSpriteMoveY] ( #05, #12 )
    COP [AnimOnce]
    COP [BranchIfSolidNorth] ( &code_0A8B52 )
    COP [StageSpriteMoveY] ( #06, #12 )
    COP [AnimOnce]
    JMP $&code_0A8B37
}

code_0A8BBC {
    COP [BranchIfPlayerNear] ( #03, &code_0A8C59 )
    COP [BranchIfSolidSouth] ( &code_0A8B52 )
    COP [StageSpriteMoveY] ( #03, #11 )
    COP [AnimOnce]
    COP [BranchIfSolidSouth] ( &code_0A8B52 )
    COP [StageSpriteMoveY] ( #04, #11 )
    COP [AnimOnce]
    JMP $&code_0A8B37
}

code_0A8BD8 {
    LDA #$0008
    TSB $10
    COP [StageSpriteMoveX] ( #07, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #08, #11 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #02, #10 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #25, #04 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #02, #10 )
    COP [AnimLoop]
    LDA #$0008
    TRB $10
    JMP $&code_0A8B35
}

code_0A8C03 {
    LDA #$0008
    TSB $10
    COP [StageSpriteMoveX] ( #87, #12 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #88, #12 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #82, #10 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #A5, #03 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #82, #10 )
    COP [AnimLoop]
    LDA #$0008
    TRB $10
    JMP $&code_0A8B35
}

code_0A8C2E {
    LDA #$0008
    TSB $10
    COP [StageSpriteMoveY] ( #05, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #06, #11 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #01, #10 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #24, #04 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #01, #10 )
    COP [AnimLoop]
    LDA #$0008
    TRB $10
    JMP $&code_0A8B35
}

code_0A8C59 {
    LDA #$0008
    TSB $10
    COP [StageSpriteMoveY] ( #03, #12 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #04, #12 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #00, #10 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #23, #03 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #00, #10 )
    COP [AnimLoop]
    LDA #$0008
    TRB $10
    JMP $&code_0A8B35
}

actor_def_0A8C84 [
  actor-def < #09, #00, #00, {

  code_0A8C87:
    COP [AddPosition] ( #08, #00 )
    LDA #$0011
    TSB $12
    COP [OrActorFlags] ( #$0008 )
    COP [SolidHighHere]

  loc_0A8C96:
    COP [WaitWhileOffscreen] ( #10 )

  code_0A8C99:
    LDA $10
    BIT #$4000
    BNE loc_0A8C96
    COP [StageSpriteLoop] ( #28, #08 )
    COP [AnimLoop]
    COP [DirToPlayer]
    AND #$0001
    BEQ loc_0A8CE6
    COP [StageSpriteFrame] ( #29 )
    COP [AnimOnce]
    COP [PlaySoundCh1] ( #1E )
    COP [SpawnLastRel] ( @code_0A8D75, #F2, #F0, #$0200 )
    COP [SpawnLastRel] ( @code_0A8D88, #0F, #F0, #$0200 )
    COP [SpawnLastRel] ( @code_0A8D9B, #F2, #04, #$0200 )
    COP [SpawnLastRel] ( @code_0A8DAE, #0F, #04, #$0200 )
    COP [StageSpriteFrame] ( #2A )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #27, #02 )
    COP [AnimLoop]
    BRA code_0A8C99

  loc_0A8CE6:
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    COP [PlaySoundCh1] ( #1E )
    COP [SpawnLastRel] ( @code_0A8D20, #00, #E0, #$0200 )
    COP [SpawnLastRel] ( @code_0A8D3F, #00, #00, #$0202 )
    COP [SpawnLastRel] ( @code_0A8D51, #E8, #F5, #$0200 )
    COP [SpawnLastRel] ( @code_0A8D63, #18, #F5, #$0200 )
    COP [StageSpriteFrame] ( #0B )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #09, #02 )
    COP [AnimLoop]
    JMP $&code_0A8C99
} >
]

code_0A8D20 {
    JSR $&code_0A8DC1
    COP [ToggleVFlip]
    COP [StageSpriteMoveY] ( #0D, #06 )
    COP [AnimOnce]
    LDA #$0002
    TSB $10

  loc_0A8D30:
    COP [StageSpriteMoveY] ( #0D, #06 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_0A8D30
    COP [Die]
}

code_0A8D3F {
    JSR $&code_0A8DC1

  loc_0A8D42:
    COP [StageSpriteMoveY] ( #0D, #05 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_0A8D42
    COP [Die]
}

code_0A8D51 {
    JSR $&code_0A8DC1

  loc_0A8D54:
    COP [StageSpriteMoveX] ( #0C, #06 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_0A8D54
    COP [Die]
}

code_0A8D63 {
    JSR $&code_0A8DC1

  loc_0A8D66:
    COP [StageSpriteMoveX] ( #8C, #05 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_0A8D66
    COP [Die]
}

code_0A8D75 {
    JSR $&code_0A8DC1
    COP [StageSpriteMoveXY] ( #2C, #04, #04 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ code_0A8D75
    COP [Die]
}

code_0A8D88 {
    JSR $&code_0A8DC1
    COP [StageSpriteMoveXY] ( #AC, #03, #04 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ code_0A8D88
    COP [Die]
}

code_0A8D9B {
    JSR $&code_0A8DC1
    COP [StageSpriteMoveXY] ( #2B, #04, #03 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ code_0A8D9B
    COP [Die]
}

code_0A8DAE {
    JSR $&code_0A8DC1
    COP [StageSpriteMoveXY] ( #AB, #03, #03 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ code_0A8DAE
    COP [Die]
}

code_0A8DC1 {
    COP [OrActorFlags] ( #$0010 )
    LDA #$0080
    TSB $12
    RTS 
}

actor_def_0A8DCB [
  actor-def < #11, #00, #00, {

  code_0A8DCE:
    COP [WaitWhileOffscreen] ( #10 )

  code_0A8DD1:
    COP [SetEntryExit]

  code_0A8DD3:
    COP [DirToPlayer]
    CMP #$0000
    BNE loc_0A8DDD
    JMP $&code_0A8E8C

  loc_0A8DDD:
    CMP #$0002
    BNE loc_0A8DE5
    JMP $&code_0A8E6D

  loc_0A8DE5:
    CMP #$0004
    BNE loc_0A8DED
    JMP $&code_0A8EAB

  loc_0A8DED:
    CMP #$0006
    BNE code_0A8DF5
    JMP $&code_0A8E4E

  code_0A8DF5:
    COP [RngByte]
    AND #$0003
    DEC 
    BMI loc_0A8E3B
    BEQ loc_0A8E28
    DEC 
    BEQ loc_0A8E04
    BRA loc_0A8E16

  loc_0A8E04:
    COP [LoopInit] ( #02 )
    COP [BranchIfSolidWest] ( &code_0A8DD1 )
    COP [StageSpriteLoopMoveX] ( #13, #02, #14 )
    COP [AnimLoop]
    COP [LoopNext]
    BRA code_0A8DD3

  loc_0A8E16:
    COP [LoopInit] ( #02 )
    COP [BranchIfSolidEast] ( &code_0A8DD1 )
    COP [StageSpriteLoopMoveX] ( #93, #02, #13 )
    COP [AnimLoop]
    COP [LoopNext]
    BRA code_0A8DD3

  loc_0A8E28:
    COP [LoopInit] ( #02 )
    COP [BranchIfSolidNorth] ( &code_0A8DD1 )
    COP [StageSpriteLoopMoveY] ( #12, #02, #14 )
    COP [AnimLoop]
    COP [LoopNext]
    JMP $&code_0A8DD3

  loc_0A8E3B:
    COP [LoopInit] ( #02 )
    COP [BranchIfSolidSouth] ( &code_0A8DD1 )
    COP [StageSpriteLoopMoveY] ( #11, #02, #13 )
    COP [AnimLoop]
    COP [LoopNext]
    JMP $&code_0A8DD3
} >
]

code_0A8E4E {
    COP [BranchIfSolidWest] ( &code_0A8DF5 )
    COP [StageSpriteLoop] ( #16, #04 )
    COP [AnimLoop]

  loc_0A8E58:
    COP [BranchIfSolidWest] ( &code_0A8E64 )
    COP [StageSpriteMoveX] ( #16, #04 )
    COP [AnimOnce]
    BRA loc_0A8E58
}

code_0A8E64 {
    COP [StageSpriteLoop] ( #10, #10 )
    COP [AnimLoop]
    JMP $&code_0A8DD1
}

code_0A8E6D {
    COP [BranchIfSolidEast] ( &code_0A8DF5 )
    COP [StageSpriteLoop] ( #96, #04 )
    COP [AnimLoop]

  loc_0A8E77:
    COP [BranchIfSolidEast] ( &code_0A8E83 )
    COP [StageSpriteMoveX] ( #96, #03 )
    COP [AnimOnce]
    BRA loc_0A8E77
}

code_0A8E83 {
    COP [StageSpriteLoop] ( #90, #10 )
    COP [AnimLoop]
    JMP $&code_0A8DD1
}

code_0A8E8C {
    COP [BranchIfSolidNorth] ( &code_0A8DF5 )
    COP [StageSpriteLoop] ( #15, #04 )
    COP [AnimLoop]

  loc_0A8E96:
    COP [BranchIfSolidNorth] ( &code_0A8EA2 )
    COP [StageSpriteMoveY] ( #15, #04 )
    COP [AnimOnce]
    BRA loc_0A8E96
}

code_0A8EA2 {
    COP [StageSpriteLoop] ( #0F, #10 )
    COP [AnimLoop]
    JMP $&code_0A8DD1
}

code_0A8EAB {
    COP [BranchIfSolidSouth] ( &code_0A8DF5 )
    COP [StageSpriteLoop] ( #14, #04 )
    COP [AnimLoop]

  loc_0A8EB5:
    COP [BranchIfSolidSouth] ( &code_0A8EC1 )
    COP [StageSpriteMoveY] ( #14, #03 )
    COP [AnimOnce]
    BRA loc_0A8EB5
}

code_0A8EC1 {
    COP [StageSpriteLoop] ( #0E, #10 )
    COP [AnimLoop]
    JMP $&code_0A8DD1
}

actor_def_0A8ECA [
  actor-def < #11, #00, #00, {

  code_0A8ECD:
    COP [SetSpritePalette] ( #0A )
    COP [WaitWhileOffscreen] ( #10 )

  code_0A8ED3:
    COP [SetEntryExit]

  code_0A8ED5:
    COP [DirToPlayer]
    CMP #$0000
    BNE loc_0A8EDF
    JMP $&code_0A8FC4

  loc_0A8EDF:
    CMP #$0002
    BNE loc_0A8EE7
    JMP $&code_0A8F88

  loc_0A8EE7:
    CMP #$0004
    BNE loc_0A8EEF
    JMP $&code_0A8FFF

  loc_0A8EEF:
    CMP #$0006
    BNE code_0A8EF7
    JMP $&code_0A8F4C

  code_0A8EF7:
    COP [RngByte]
    AND #$0003
    DEC 
    BMI loc_0A8F3A
    BEQ loc_0A8F28
    DEC 
    BEQ loc_0A8F06
    BRA loc_0A8F17

  loc_0A8F06:
    COP [LoopInit] ( #02 )
    COP [BranchIfSolidWest] ( &code_0A8ED3 )
    COP [StageSpriteMoveX] ( #13, #12 )
    COP [AnimOnce]
    COP [LoopNext]
    BRA code_0A8ED5

  loc_0A8F17:
    COP [LoopInit] ( #02 )
    COP [BranchIfSolidEast] ( &code_0A8ED3 )
    COP [StageSpriteMoveX] ( #93, #11 )
    COP [AnimOnce]
    COP [LoopNext]
    BRA code_0A8ED5

  loc_0A8F28:
    COP [LoopInit] ( #02 )
    COP [BranchIfSolidNorth] ( &code_0A8ED3 )
    COP [StageSpriteMoveY] ( #12, #12 )
    COP [AnimOnce]
    COP [LoopNext]
    JMP $&code_0A8ED5

  loc_0A8F3A:
    COP [LoopInit] ( #02 )
    COP [BranchIfSolidSouth] ( &code_0A8ED3 )
    COP [StageSpriteMoveY] ( #11, #11 )
    COP [AnimOnce]
    COP [LoopNext]
    JMP $&code_0A8ED5
} >
]

code_0A8F4C {
    COP [BranchIfSolidWest] ( &code_0A8EF7 )
    COP [StageSpriteLoop] ( #16, #04 )
    COP [AnimLoop]

  loc_0A8F56:
    COP [BranchIfSolidWest] ( &code_0A8F67 )
    COP [BranchIfPlayerNear] ( #02, &code_0A8F70 )
    COP [StageSpriteMoveX] ( #16, #04 )
    COP [AnimOnce]
    BRA loc_0A8F56
}

code_0A8F67 {
    COP [StageSpriteLoop] ( #10, #10 )
    COP [AnimLoop]
    JMP $&code_0A8ED3
}

code_0A8F70 {
    COP [BranchIfSolidOffset] ( #FE, #00, &code_0A8F67 )
    BRA loc_0A8F78

  loc_0A8F78:
    COP [StageSpriteMoveXY] ( #22, #04, #38 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #10, #20 )
    COP [AnimLoop]
    JMP $&code_0A8ED3
}

code_0A8F88 {
    COP [BranchIfSolidEast] ( &code_0A8EF7 )
    COP [StageSpriteLoop] ( #96, #04 )
    COP [AnimLoop]

  loc_0A8F92:
    COP [BranchIfSolidEast] ( &code_0A8FA3 )
    COP [BranchIfPlayerNear] ( #02, &code_0A8FAC )
    COP [StageSpriteMoveX] ( #96, #03 )
    COP [AnimOnce]
    BRA loc_0A8F92
}

code_0A8FA3 {
    COP [StageSpriteLoop] ( #90, #10 )
    COP [AnimLoop]
    JMP $&code_0A8ED3
}

code_0A8FAC {
    COP [BranchIfSolidOffset] ( #02, #00, &code_0A8FA3 )
    BRA loc_0A8FB4

  loc_0A8FB4:
    COP [StageSpriteMoveXY] ( #A2, #03, #38 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #90, #20 )
    COP [AnimLoop]
    JMP $&code_0A8ED3
}

code_0A8FC4 {
    COP [BranchIfSolidNorth] ( &code_0A8EF7 )
    COP [StageSpriteLoop] ( #15, #04 )
    COP [AnimLoop]

  loc_0A8FCE:
    COP [BranchIfSolidNorth] ( &code_0A8FDF )
    COP [BranchIfPlayerNear] ( #02, &code_0A8FE8 )
    COP [StageSpriteMoveY] ( #15, #04 )
    COP [AnimOnce]
    BRA loc_0A8FCE
}

code_0A8FDF {
    COP [StageSpriteLoop] ( #0F, #10 )
    COP [AnimLoop]
    JMP $&code_0A8ED3
}

code_0A8FE8 {
    COP [BranchIfSolidOffset] ( #00, #FE, &code_0A8FDF )
    BRA loc_0A8FF0

  loc_0A8FF0:
    COP [StageSpriteMoveY] ( #21, #39 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #0F, #20 )
    COP [AnimLoop]
    JMP $&code_0A8ED3
}

code_0A8FFF {
    COP [BranchIfSolidSouth] ( &code_0A8EF7 )
    COP [StageSpriteLoop] ( #14, #04 )
    COP [AnimLoop]

  loc_0A9009:
    COP [BranchIfSolidSouth] ( &code_0A901A )
    COP [BranchIfPlayerNear] ( #02, &code_0A9023 )
    COP [StageSpriteMoveY] ( #14, #03 )
    COP [AnimOnce]
    BRA loc_0A9009
}

code_0A901A {
    COP [StageSpriteLoop] ( #0E, #10 )
    COP [AnimLoop]
    JMP $&code_0A8ED3
}

code_0A9023 {
    COP [BranchIfSolidOffset] ( #00, #02, &code_0A901A )
    BRA loc_0A902B

  loc_0A902B:
    COP [StageSpriteMoveY] ( #20, #3A )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #0E, #20 )
    COP [AnimLoop]
    JMP $&code_0A8ED3
}

actor_def_0A903A [
  actor-def < #0F, #01, #01, {

  code_0A903D:
    LDA #$ACF0
    STA $statsPtr, X
    LDA #$0030
    TSB $12
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [SolidHighHere]

  loc_0A9055:
    LDA #$00FF
    STA $currentHp, X
    COP [SetHitCallback] ( &code_0A9068 )
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
} >
]

code_0A9068 {
    COP [StageSpriteFrame] ( #10 )
    COP [AnimOnce]
    COP [SetFlagByte] ( #0F )
    COP [WaitByte] ( #3B )
    BRA loc_0A9055
}

actor_def_0A9075 [
  actor-def < #00, #00, #03, {

  code_0A9078:
    BRA loc_0A908B

  loc_0A907A:
    ORA ($00, X)
    ORA $80, S
    TSB $0002
    ORA $80, S
    ORA [$02]
    BRK #$03
    COP [SetHFlip]
    BRA loc_0A908B

  loc_0A908B:
    LDA #$0010
    TSB $12
    LDA $0F
    AND #$0010
    LSR 
    LSR 
    LSR 
    LSR 
    STA $orbitAngle, X
    COP [SetSpritePalette] ( #0E )
    COP [SetSpritePriority] ( #20 )
    COP [SolidHighHere]
    COP [WaitWhileOffscreen] ( #08 )
    COP [SpawnMarkedAfter] ( @chunk_008000.code_00E34D, #$2300 )
    LDA $orbitAngle, X
    BEQ loc_0A90CF
    BRA loc_0A90D7

  loc_0A90B7:
    LDA #$0200
    TRB $10
    COP [SetEntryContinue]
    LDA $currentHp, X
    CMP #$000A
    BNE loc_0A90C8
    RTL 

  loc_0A90C8:
    LDA #$0200
    TSB $10
    BRA code_0A90DB

  loc_0A90CF:
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #02, &code_0A90DB )
    RTL 

  loc_0A90D7:
    COP [ExitIfFlagByte] ( #0F, #01 )
} >
]

actor_def_0A907F [
  actor-def < #02, #00, #03, {

  code_0A9082:
    BRA loc_0A908B
} >
]

actor_def_0A9084 [
  actor-def < #02, #00, #03, {

  code_0A9087:
    COP [SetHFlip]
    BRA loc_0A908B

  loc_0A908B:
    LDA #$0010
    TSB $12
    LDA $0F
    AND #$0010
    LSR 
    LSR 
    LSR 
    LSR 
    STA $orbitAngle, X
    COP [SetSpritePalette] ( #0E )
    COP [SetSpritePriority] ( #20 )
    COP [SolidHighHere]
    COP [WaitWhileOffscreen] ( #08 )
    COP [SpawnMarkedAfter] ( @chunk_008000.code_00E34D, #$2300 )
    LDA $orbitAngle, X
    BEQ loc_0A90CF
    BRA loc_0A90D7

  loc_0A90B7:
    LDA #$0200
    TRB $10
    COP [SetEntryContinue]
    LDA $currentHp, X
    CMP #$000A
    BNE loc_0A90C8
    RTL 

  loc_0A90C8:
    LDA #$0200
    TSB $10
    BRA code_0A90DB

  loc_0A90CF:
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #02, &code_0A90DB )
    RTL 

  loc_0A90D7:
    COP [ExitIfFlagByte] ( #0F, #01 )
} >
]

code_0A90DB {
    COP [BranchIfNotOnGridline] ( &code_0A90E1 )
    BRA loc_0A90E6
}

code_0A90E1 {
    COP [SetEntryExitNow] ( @code_0A90DB )

  loc_0A90E6:
    COP [KillNext]
    COP [LoopInit] ( #1E )
    COP [SetSpritePalette] ( #0E )
    COP [SetEntryExit]
    COP [SetSpritePalette] ( #00 )
    COP [LoopNext]
    COP [LoopInit] ( #0F )
    COP [SetSpritePalette] ( #0E )
    COP [SetEntryExit]
    COP [SetEntryExit]
    COP [SetSpritePalette] ( #00 )
    COP [SetEntryExit]
    COP [LoopNext]
    LDA #$0300
    TRB $10
    LDA #$0010
    TRB $12
    COP [ClearLowHere]
    JMP $&code_0A911E
}

code_0A9115 {
    BRK #$00
    BRK #$02
    LDX $20, Y

  loc_0A911B:
    COP [WaitWhileOffscreen] ( #0E )
}

code_0A911E {
    COP [SetEntryExit]

  code_0A9120:
    LDA $10
    BIT #$4000
    BNE loc_0A911B
    COP [BranchNearerAxis] ( &code_0A912D, &code_0A9137 )
}

code_0A912D {
    COP [BranchOnPlayerX] ( #$0008, &code_0A915A, &code_0A9137, &code_0A9175 )
}

code_0A9137 {
    COP [BranchOnPlayerY] ( #$0008, &code_0A9190, &code_0A9141, &code_0A91AC )
}

code_0A9141 {
    RTL 
}

code_0A9142 {
    COP [SetEntryExit]
    COP [RngByte]
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0A9152 )
}

code_list_0A9152 [
  &code_0A915A   ;00
  &code_0A9175   ;01
  &code_0A9190   ;02
  &code_0A91AC   ;03
]

code_0A915A {
    COP [BranchIfPlayerNear] ( #04, &code_0A91C8 )

  code_0A915F:
    COP [BranchIfSolidWest] ( &code_0A9142 )
    COP [StageSpriteMoveX] ( #07, #02 )
    COP [AnimOnce]
    COP [BranchIfSolidWest] ( &code_0A9142 )
    COP [StageSpriteMoveX] ( #08, #02 )
    COP [AnimOnce]
    BRA code_0A9120
}

code_0A9175 {
    COP [BranchIfPlayerNear] ( #04, &code_0A91DD )

  code_0A917A:
    COP [BranchIfSolidEast] ( &code_0A9142 )
    COP [StageSpriteMoveX] ( #87, #01 )
    COP [AnimOnce]
    COP [BranchIfSolidEast] ( &code_0A9142 )
    COP [StageSpriteMoveX] ( #88, #01 )
    COP [AnimOnce]
    BRA code_0A9120
}

code_0A9190 {
    COP [BranchIfPlayerNear] ( #04, &code_0A91F2 )

  code_0A9195:
    COP [BranchIfSolidNorth] ( &code_0A9142 )
    COP [StageSpriteMoveY] ( #05, #02 )
    COP [AnimOnce]
    COP [BranchIfSolidNorth] ( &code_0A9142 )
    COP [StageSpriteMoveY] ( #06, #02 )
    COP [AnimOnce]
    JMP $&code_0A9120
}

code_0A91AC {
    COP [BranchIfPlayerNear] ( #04, &code_0A9207 )

  code_0A91B1:
    COP [BranchIfSolidSouth] ( &code_0A9142 )
    COP [StageSpriteMoveY] ( #03, #01 )
    COP [AnimOnce]
    COP [BranchIfSolidSouth] ( &code_0A9142 )
    COP [StageSpriteMoveY] ( #04, #01 )
    COP [AnimOnce]
    JMP $&code_0A9120
}

code_0A91C8 {
    COP [BranchIfPlayerInRelTiles] ( #FA, #FF, #00, #01, &code_0A921C )
    COP [StageSpriteFrame] ( #0B )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    JMP $&code_0A915F
}

code_0A91DD {
    COP [BranchIfPlayerInRelTiles] ( #00, #FF, #06, #01, &code_0A9250 )
    COP [StageSpriteFrame] ( #8B )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #9A )
    COP [AnimOnce]
    JMP $&code_0A917A
}

code_0A91F2 {
    COP [BranchIfPlayerInRelTiles] ( #FF, #FA, #01, #00, &code_0A92B8 )
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #19 )
    COP [AnimOnce]
    JMP $&code_0A9195
}

code_0A9207 {
    COP [BranchIfPlayerInRelTiles] ( #FF, #00, #01, #06, &code_0A9284 )
    COP [StageSpriteFrame] ( #09 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #18 )
    COP [AnimOnce]
    JMP $&code_0A91B1
}

code_0A921C {
    COP [StageSpriteFrame] ( #2D )
    COP [AnimOnce]
    COP [SpawnMarkedAfterRel] ( @code_0A92EC, #FC, #E8, #$0202 )
    COP [StageSpriteLoop] ( #2E, #20 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #2F )
    COP [AnimOnce]
    COP [PlaySoundCh1] ( #1E )
    COP [SpawnAfterRelFlags] ( @code_0A9306, #$FFF0, #$FFE0, #$0300 )
    COP [StageSpriteFrame] ( #2F )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    JMP $&code_0A9120
}

code_0A9250 {
    COP [StageSpriteFrame] ( #AD )
    COP [AnimOnce]
    COP [SpawnMarkedAfterRel] ( @code_0A9324, #04, #E8, #$0202 )
    COP [StageSpriteLoop] ( #AE, #20 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #AF )
    COP [AnimOnce]
    COP [PlaySoundCh1] ( #1E )
    COP [SpawnAfterRelFlags] ( @code_0A933E, #$0010, #$FFE0, #$0300 )
    COP [StageSpriteFrame] ( #AF )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #82 )
    COP [AnimOnce]
    JMP $&code_0A9120
}

code_0A9284 {
    COP [StageSpriteFrame] ( #27 )
    COP [AnimOnce]
    COP [SpawnMarkedAfterRel] ( @code_0A935C, #F6, #EC, #$0202 )
    COP [StageSpriteLoop] ( #28, #20 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #29 )
    COP [AnimOnce]
    COP [PlaySoundCh1] ( #1E )
    COP [SpawnAfterRelFlags] ( @code_0A9376, #$FFFC, #$0010, #$0300 )
    COP [StageSpriteFrame] ( #2F )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    JMP $&code_0A9120
}

code_0A92B8 {
    COP [StageSpriteFrame] ( #2A )
    COP [AnimOnce]
    COP [SpawnMarkedAfterRel] ( @code_0A9394, #0B, #ED, #$0202 )
    COP [StageSpriteLoop] ( #2B, #20 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #2C )
    COP [AnimOnce]
    COP [PlaySoundCh1] ( #1E )
    COP [SpawnAfterRelFlags] ( @code_0A93AE, #$0004, #$FFF8, #$0300 )
    COP [StageSpriteFrame] ( #2F )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    JMP $&code_0A9120
}

code_0A92EC {
    JSR $&code_0A93CC
    COP [LoopInit] ( #20 )

  loc_0A92F2:
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0A92F2
    JSR $&code_0A93E6
    COP [SetEntryContinue]
    DEC $26
    BMI loc_0A9302
    RTL 

  loc_0A9302:
    COP [LoopNext]
    COP [Die]
}

code_0A9306 {
    COP [SpawnMarkedAfter] ( @code_0A9502, #$2000 )

  loc_0A930D:
    COP [StageSpriteMoveX] ( #11, #06 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_0A930D
    COP [Die]

  loc_0A931C:
    COP [StageSpriteLoop] ( #94, #06 )
    COP [AnimLoop]
    COP [Die]
}

code_0A9324 {
    JSR $&code_0A93CC
    COP [LoopInit] ( #20 )

  loc_0A932A:
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0A932A
    JSR $&code_0A93E6
    COP [SetEntryContinue]
    DEC $26
    BMI loc_0A933A
    RTL 

  loc_0A933A:
    COP [LoopNext]
    COP [Die]
}

code_0A933E {
    COP [SpawnMarkedAfter] ( @code_0A94AB, #$2000 )

  loc_0A9345:
    COP [StageSpriteMoveX] ( #91, #05 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_0A9345
    COP [Die]

  loc_0A9354:
    COP [StageSpriteLoop] ( #14, #06 )
    COP [AnimLoop]
    COP [Die]
}

code_0A935C {
    JSR $&code_0A93CC
    COP [LoopInit] ( #20 )

  loc_0A9362:
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0A9362
    JSR $&code_0A93E6
    COP [SetEntryContinue]
    DEC $26
    BMI loc_0A9372
    RTL 

  loc_0A9372:
    COP [LoopNext]
    COP [Die]
}

code_0A9376 {
    COP [SpawnMarkedAfter] ( @code_0A93FD, #$2000 )

  loc_0A937D:
    COP [StageSpriteMoveY] ( #0F, #05 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_0A937D
    COP [Die]

  loc_0A938C:
    COP [StageSpriteLoop] ( #12, #06 )
    COP [AnimLoop]
    COP [Die]
}

code_0A9394 {
    JSR $&code_0A93CC
    COP [LoopInit] ( #20 )

  loc_0A939A:
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0A939A
    JSR $&code_0A93E6
    COP [SetEntryContinue]
    DEC $26
    BMI loc_0A93AA
    RTL 

  loc_0A93AA:
    COP [LoopNext]
    COP [Die]
}

code_0A93AE {
    COP [SpawnMarkedAfter] ( @code_0A9455, #$2000 )

  loc_0A93B5:
    COP [StageSpriteMoveY] ( #10, #06 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_0A93B5
    COP [Die]

  loc_0A93C4:
    COP [StageSpriteLoop] ( #13, #06 )
    COP [AnimLoop]
    COP [Die]
}

code_0A93CC {
    LDY $24
    LDA $14
    SEC 
    SBC $0014, Y
    STA $7F100C, X
    LDA $16
    SEC 
    SBC $0016, Y
    STA $7F100E, X
    COP [StageSprAndHitbox] ( #0E )
    RTS 
}

code_0A93E6 {
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

code_0A93FD {
    LDY $decelStepCounter
    LDA $0010, Y
    BIT #$0040
    BEQ loc_0A940B
    COP [SetEntryContinue]
    RTL 

  loc_0A940B:
    BIT #$2280
    BEQ loc_0A9411
    RTL 

  loc_0A9411:
    LDA #$0008
    JSR $&code_0A95AC

  code_0A9417:
    BPL loc_0A941D
    EOR #$FFFF
    INC 

  loc_0A941D:
    CMP #$0005
    BCC loc_0A9423
    RTL 

  loc_0A9423:
    LDA $0014, Y
    SEC 
    SBC $0018
    BPL loc_0A9430
    EOR #$FFFF
    INC 

  loc_0A9430:
    CMP #$0007
    BCC loc_0A9436
    RTL 

  loc_0A9436:
    LDA #$0F00
    TSB $joypadMaskStd
    PHY 
    LDA $0B02
    CLC 
    ADC #$0002
    LDY #$0000
    JSL $@chunk_008000.code_00C4DF
    PLY 
    LDA #$938C
    JSR $&code_0A9584
    JMP $&code_0A9551
}

code_0A9455 {
    LDY $decelStepCounter
    LDA $0010, Y
    BIT #$0040
    BEQ loc_0A9463
    COP [SetEntryContinue]
    RTL 

  loc_0A9463:
    BIT #$2280
    BEQ loc_0A9469
    RTL 

  loc_0A9469:
    LDA #$0008
    JSR $&code_0A95AC
    SEC 
    SBC #$0020
    BPL loc_0A9479
    EOR #$FFFF
    INC 

  loc_0A9479:
    CMP #$0005
    BCC loc_0A947F
    RTL 

  loc_0A947F:
    LDA $0014, Y
    SEC 
    SBC $0018
    BPL loc_0A948C
    EOR #$FFFF
    INC 

  loc_0A948C:
    CMP #$0007
    BCC loc_0A9492
    RTL 

  loc_0A9492:
    PHY 
    LDA $0B02
    CLC 
    ADC #$0002
    LDY #$0001
    JSL $@chunk_008000.code_00C4DF
    PLY 
    LDA #$93C4
    JSR $&code_0A9584
    JMP $&code_0A9551
}

code_0A94AB {
    LDY $decelStepCounter
    LDA $0010, Y
    BIT #$0040
    BEQ loc_0A94B9
    COP [SetEntryContinue]
    RTL 

  loc_0A94B9:
    BIT #$2280
    BEQ loc_0A94BF
    RTL 

  loc_0A94BF:
    LDA #$0000
    JSR $&code_0A9591
    CLC 
    ADC #$0004
    BPL loc_0A94CF
    EOR #$FFFF
    INC 

  loc_0A94CF:
    CMP #$0005
    BCC loc_0A94D5
    RTL 

  loc_0A94D5:
    LDA $0016, Y
    SEC 
    SBC $001C
    BPL loc_0A94E2
    EOR #$FFFF
    INC 

  loc_0A94E2:
    CMP #$000D
    BCC loc_0A94E8
    RTL 

  loc_0A94E8:
    LDA #$0F00
    TSB $joypadMaskStd
    PHY 
    LDA #$0002
    LDY #$0003
    JSL $@chunk_008000.code_00C4DF
    PLY 
    LDA #$931C
    JSR $&code_0A9584
    BRA code_0A9551
}

code_0A9502 {
    LDY $decelStepCounter
    LDA $0010, Y
    BIT #$0040
    BEQ loc_0A9510
    COP [SetEntryContinue]
    RTL 

  loc_0A9510:
    BIT #$2280
    BEQ loc_0A9516
    RTL 

  loc_0A9516:
    LDA #$0010
    JSR $&code_0A9591
    SEC 
    SBC #$0004
    BPL loc_0A9526
    EOR #$FFFF
    INC 

  loc_0A9526:
    CMP #$0005
    BCC loc_0A952C
    RTL 

  loc_0A952C:
    LDA $0016, Y
    SEC 
    SBC $001C
    BPL loc_0A9539
    EOR #$FFFF
    INC 

  loc_0A9539:
    CMP #$000D
    BCC loc_0A953F
    RTL 

  loc_0A953F:
    PHY 
    LDA #$0002
    LDY #$0002
    JSL $@chunk_008000.code_00C4DF
    PLY 
    LDA #$9354
    JSR $&code_0A9584
}

code_0A9551 {
    PHX 
    LDX $decelStepCounter
    LDA $0014, Y
    SEC 
    SBC $0014, X
    STA $14
    LDA $0016, Y
    SEC 
    SBC $0016, X
    STA $16
    PLX 
    COP [SetEntryContinue]
    PHX 
    LDX $decelStepCounter
    LDY $24
    LDA $0014, X
    CLC 
    ADC $14
    STA $0014, Y
    LDA $0016, X
    CLC 
    ADC $16
    STA $0016, Y
    PLX 
    RTL 
}

code_0A9584 {
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    STA $002C, Y
    RTS 
}

code_0A9591 {
    CLC 
    ADC $playerWallType
    STA $0018
    LDA $playerSpeedEw
    CLC 
    ADC #$0004
    STA $001C
    LDY $24
    LDA $0014, Y
    SEC 
    SBC $0018
    RTS 
}

code_0A95AC {
    CLC 
    ADC $playerSpeedEw
    STA $001C
    LDA $playerWallType
    CLC 
    ADC #$0008
    STA $0018
    LDY $24
    LDA $0016, Y
    SEC 
    SBC $001C
    RTS 
}

actor_def_0A95C7 [
  actor-def < #00, #00, #03, {

  code_0A95CA:
    BRA loc_0A95DD
} >
]

actor_def_0A95CC [
  actor-def < #01, #00, #03, {

  code_0A95CF:
    BRA loc_0A95DD
} >
]

actor_def_0A95D1 [
  actor-def < #02, #00, #03, {

  code_0A95D4:
    BRA loc_0A95DD
} >
]

actor_def_0A95D6 [
  actor-def < #02, #00, #03, {

  code_0A95D9:
    COP [SetHFlip]
    BRA loc_0A95DD

  loc_0A95DD:
    LDA #$0010
    TSB $12
    LDA $0F
    AND #$0010
    LSR 
    LSR 
    LSR 
    LSR 
    STA $orbitAngle, X
    COP [SetSpritePalette] ( #0E )
    COP [SetSpritePriority] ( #20 )
    COP [SolidHighHere]
    COP [WaitWhileOffscreen] ( #08 )
    COP [SpawnMarkedAfter] ( @chunk_008000.code_00E34D, #$2300 )
    LDA $orbitAngle, X
    BEQ loc_0A9621
    BRA loc_0A9629

  loc_0A9609:
    LDA #$0200
    TRB $10
    COP [SetEntryContinue]
    LDA $currentHp, X
    CMP #$000A
    BNE loc_0A961A
    RTL 

  loc_0A961A:
    LDA #$0200
    TSB $10
    BRA code_0A962D

  loc_0A9621:
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #02, &code_0A962D )
    RTL 

  loc_0A9629:
    COP [ExitIfFlagByte] ( #0F, #01 )
} >
]

code_0A962D {
    COP [BranchIfNotOnGridline] ( &code_0A9633 )
    BRA loc_0A9638
}

code_0A9633 {
    COP [SetEntryExitNow] ( @code_0A962D )

  loc_0A9638:
    COP [KillNext]
    COP [LoopInit] ( #1E )
    COP [SetSpritePalette] ( #0E )
    COP [SetEntryExit]
    COP [SetSpritePalette] ( #02 )
    COP [LoopNext]
    COP [LoopInit] ( #0F )
    COP [SetSpritePalette] ( #0E )
    COP [SetEntryExit]
    COP [SetEntryExit]
    COP [SetSpritePalette] ( #02 )
    COP [SetEntryExit]
    COP [LoopNext]
    LDA #$0300
    TRB $10
    LDA #$0010
    TRB $12
    COP [ClearLowHere]
    JMP $&code_0A9673
}

code_0A9667 {
    BRK #$00
    BRK #$02
    LDX $20, Y
    COP [SetSpritePalette] ( #02 )
    COP [WaitWhileOffscreen] ( #0E )
}

code_0A9673 {
    COP [SetEntryExit]

  code_0A9675:
    COP [BranchNearerAxis] ( &code_0A967B, &code_0A9685 )
}

code_0A967B {
    COP [BranchOnPlayerX] ( #$0008, &code_0A96A8, &code_0A9685, &code_0A96C6 )
}

code_0A9685 {
    COP [BranchOnPlayerY] ( #$0008, &code_0A96E4, &code_0A968F, &code_0A9703 )
}

code_0A968F {
    RTL 
}

code_0A9690 {
    COP [SetEntryExit]
    COP [RngByte]
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0A96A0 )
}

code_list_0A96A0 [
  &code_0A96A8   ;00
  &code_0A96C6   ;01
  &code_0A96E4   ;02
  &code_0A9703   ;03
]

code_0A96A8 {
    COP [BranchIfPlayerInRelTiles] ( #FA, #FF, #00, #01, &code_0A9722 )

  code_0A96B0:
    COP [BranchIfSolidWest] ( &code_0A9690 )
    COP [StageSpriteMoveX] ( #07, #02 )
    COP [AnimOnce]
    COP [BranchIfSolidWest] ( &code_0A9690 )
    COP [StageSpriteMoveX] ( #08, #02 )
    COP [AnimOnce]
    BRA code_0A9675
}

code_0A96C6 {
    COP [BranchIfPlayerInRelTiles] ( #00, #FF, #06, #01, &code_0A973E )

  code_0A96CE:
    COP [BranchIfSolidEast] ( &code_0A9690 )
    COP [StageSpriteMoveX] ( #87, #01 )
    COP [AnimOnce]
    COP [BranchIfSolidEast] ( &code_0A9690 )
    COP [StageSpriteMoveX] ( #88, #01 )
    COP [AnimOnce]
    BRA code_0A9675
}

code_0A96E4 {
    COP [BranchIfPlayerInRelTiles] ( #FF, #FA, #01, #00, &code_0A975A )

  code_0A96EC:
    COP [BranchIfSolidNorth] ( &code_0A9690 )
    COP [StageSpriteMoveY] ( #05, #02 )
    COP [AnimOnce]
    COP [BranchIfSolidNorth] ( &code_0A9690 )
    COP [StageSpriteMoveY] ( #06, #02 )
    COP [AnimOnce]
    JMP $&code_0A9675
}

code_0A9703 {
    COP [BranchIfPlayerInRelTiles] ( #FF, #00, #01, #06, &code_0A9776 )

  code_0A970B:
    COP [BranchIfSolidSouth] ( &code_0A9690 )
    COP [StageSpriteMoveY] ( #03, #01 )
    COP [AnimOnce]
    COP [BranchIfSolidSouth] ( &code_0A9690 )
    COP [StageSpriteMoveY] ( #04, #01 )
    COP [AnimOnce]
    JMP $&code_0A9675
}

code_0A9722 {
    COP [PlaySoundCh1] ( #1F )
    COP [StageSpriteFrame] ( #0B )
    COP [AnimOnce]
    COP [PlaySoundCh1] ( #21 )
    COP [SpawnLastRel] ( @code_0A9792, #E0, #00, #$0200 )
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    JMP $&code_0A96B0
}

code_0A973E {
    COP [PlaySoundCh1] ( #1F )
    COP [StageSpriteFrame] ( #8B )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @code_0A97AE, #20, #00, #$0200 )
    COP [PlaySoundCh1] ( #21 )
    COP [StageSpriteFrame] ( #9A )
    COP [AnimOnce]
    JMP $&code_0A96CE
}

code_0A975A {
    COP [PlaySoundCh1] ( #1F )
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @code_0A97CA, #00, #E0, #$0200 )
    COP [PlaySoundCh1] ( #21 )
    COP [StageSpriteFrame] ( #19 )
    COP [AnimOnce]
    JMP $&code_0A96EC
}

code_0A9776 {
    COP [PlaySoundCh1] ( #1F )
    COP [StageSpriteFrame] ( #09 )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @code_0A97E6, #00, #08, #$0200 )
    COP [PlaySoundCh1] ( #21 )
    COP [StageSpriteFrame] ( #18 )
    COP [AnimOnce]
    JMP $&code_0A970B
}

code_0A9792 {
    COP [SetSpritePalette] ( #00 )

  code_0A9795:
    COP [BranchIfSolid] ( &code_0A9800 )
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @code_0A9795, #FA, #00, #$0200 )
    COP [StageSpriteFrame] ( #24 )
    COP [AnimOnce]
    COP [Die]
}

code_0A97AE {
    COP [SetSpritePalette] ( #00 )

  code_0A97B1:
    COP [BranchIfSolid] ( &code_0A9800 )
    COP [StageSpriteFrame] ( #A3 )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @code_0A97B1, #06, #00, #$0200 )
    COP [StageSpriteFrame] ( #A4 )
    COP [AnimOnce]
    COP [Die]
}

code_0A97CA {
    COP [SetSpritePalette] ( #00 )

  code_0A97CD:
    COP [BranchIfSolid] ( &code_0A9800 )
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @code_0A97CD, #00, #FA, #$0200 )
    COP [StageSpriteFrame] ( #24 )
    COP [AnimOnce]
    COP [Die]
}

code_0A97E6 {
    COP [SetSpritePalette] ( #00 )

  code_0A97E9:
    COP [BranchIfSolid] ( &code_0A9800 )
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @code_0A97E9, #00, #06, #$0200 )
    COP [StageSpriteFrame] ( #24 )
    COP [AnimOnce]
}

code_0A9800 {
    COP [Die]
}

actor_def_0A9802 [
  actor-def < #1D, #01, #23, {

  code_0A9805:
    COP [AddPosition] ( #08, #00 )
    LDA #$0080
    TSB $12
    COP [WaitWhileOffscreen] ( #30 )
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #08, &code_0A9819 )
    RTL 
} >
]

code_0A9819 {
    LDA #$2000
    TRB $10
    LDA #$0008
    TRB $12
    LDA $10
    BIT #$4000
    BNE loc_0A982D
    COP [PlaySoundCh1] ( #26 )

  loc_0A982D:
    COP [StageSpriteFrame] ( #1D )
    COP [AnimOnce]
    LDA #$0300
    TRB $10
    LDA #$000F
    STA $chatPtr, X

  code_0A983E:
    LDA $chatPtr, X
    DEC 
    STA $chatPtr, X
    BEQ code_0A9819
    CMP #$0006
    BEQ loc_0A987A
    COP [SetEntryExit]
    COP [RngByte]
    AND #$0007
    DEC 
    BMI code_0A9890
    BEQ code_0A98A2
    DEC 
    BEQ code_0A98B4
    DEC 
    BEQ code_0A98C3
    COP [BranchNearerAxis] ( &code_0A9866, &code_0A9870 )
}

code_0A9866 {
    COP [BranchOnPlayerX] ( #$0008, &code_0A98B4, &code_0A9870, &code_0A98C3 )
}

code_0A9870 {
    COP [BranchOnPlayerY] ( #$0008, &code_0A98A2, &code_0A983E, &code_0A9890 )

  loc_0A987A:
    LDA #$0300
    TSB $10
    COP [StageSpriteFrame] ( #1E )
    COP [AnimOnce]
    LDA #$2000
    TSB $10
    LDA #$0008
    TSB $12
    BRA code_0A983E
}

code_0A9890 {
    COP [BranchIfSolidSouth] ( &code_0A983E )
    COP [BranchIfSolidOffset] ( #FF, #01, &code_0A983E )
    COP [StageSpriteMoveY] ( #1F, #28 )
    COP [AnimOnce]
    BRA code_0A983E
}

code_0A98A2 {
    COP [BranchIfSolidNorth] ( &code_0A983E )
    COP [BranchIfSolidOffset] ( #FF, #FF, &code_0A983E )
    COP [StageSpriteMoveY] ( #20, #27 )
    COP [AnimOnce]
    BRA code_0A983E
}

code_0A98B4 {
    COP [BranchIfSolidOffset] ( #FE, #00, &code_0A983E )
    COP [StageSpriteMoveX] ( #21, #27 )
    COP [AnimOnce]
    JMP $&code_0A983E
}

code_0A98C3 {
    COP [BranchIfSolidEast] ( &code_0A983E )
    COP [StageSpriteMoveX] ( #A1, #28 )
    COP [AnimOnce]
    JMP $&code_0A983E
}

actor_def_0A98D0 [
  actor-def < #1B, #00, #00, {

  code_0A98D3:
    COP [OrActorFlags] ( #$0020 )
    COP [AddPosition] ( #08, #08 )
    COP [WaitWhileOffscreen] ( #10 )
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #06, &code_0A98E6 )
    RTL 
} >
]

code_0A98E6 {
    COP [StageSpriteLoopMoveY] ( #1B, #40, #14 )
    COP [AnimLoop]
    COP [CollPrioritySetMax]
    COP [SpawnMarkedAfter] ( @code_0A98FD, #$2300 )

  loc_0A98F6:
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    BRA loc_0A98F6
}

code_0A98FD {
    LDA #$0000
    STA $chatPtr, X
    LDA $16
    SEC 
    SBC #$0040
    STA $16
    LDY $04
    LDA $0014, Y
    STA $orbitAngle, X
    LDA $0016, Y
    STA $orbitDiameter, X
    COP [SetEntryExit]
    PHX 
    LDX $04
    TXY 
    LDA $iframeCounter, X
    BEQ loc_0A992E
    BMI loc_0A992E
    PLX 
    JMP $&code_0A99D6

  loc_0A992E:
    PLX 
    LDA $orbitAngle, X
    SEC 
    SBC $0014, Y
    EOR #$FFFF
    INC 
    CLC 
    ADC $14
    STA $14
    LDA $orbitDiameter, X
    SEC 
    SBC $0016, Y
    EOR #$FFFF
    INC 
    CLC 
    ADC $16
    STA $16
    COP [BranchOnPlayerX] ( #$0028, &code_0A995B, &code_0A9961, &code_0A995F )
}

code_0A995B {
    DEC $14
    BRA code_0A9961
}

code_0A995F {
    INC $14
}

code_0A9961 {
    COP [BranchOnPlayerY] ( #$0028, &code_0A996B, &code_0A9971, &code_0A996F )
}

code_0A996B {
    DEC $16
    BRA code_0A9971
}

code_0A996F {
    INC $16
}

code_0A9971 {
    LDA $14
    STA $0018
    LDA $16
    STA $001C
    PHX 
    LDY $0004, X
    LDA $chatPtr, X
    AND #$007F
    ASL 
    TAX 
    SEP #$20
    LDA #$00
    XBA 
    LDA $&binary_01C36C.binary_01C43D, X
    BPL loc_0A9999
    XBA 
    DEC 
    XBA 
    SEC 
    ROR 
    BRA loc_0A999A

  loc_0A9999:
    LSR 

  loc_0A999A:
    REP #$20
    CLC 
    ADC $0018
    STA $0014, Y
    SEP #$20
    LDA #$00
    XBA 
    LDA $&binary_01C36C.binary_01C47D, X
    BPL loc_0A99B4
    XBA 
    DEC 
    XBA 
    SEC 
    ROR 
    BRA loc_0A99B5

  loc_0A99B4:
    LSR 

  loc_0A99B5:
    REP #$20
    CLC 
    ADC $001C
    STA $0016, Y
    PLX 
    LDA $0014, Y
    STA $orbitAngle, X
    LDA $0016, Y
    STA $orbitDiameter, X
    LDA $chatPtr, X
    INC 
    STA $chatPtr, X
}

code_0A99D6 {
    RTL 
}

actor_def_0A99D7 [
  actor-def < #1B, #00, #00, {

  code_0A99DA:
    LDA #$0010
    TSB $12
    COP [AddPosition] ( #08, #08 )
    COP [StageSpriteFrame] ( #1B )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
} >
]

actor_def_0A99EB [
  actor-def < #01, #01, #01, {

  code_0A99EE:
    LDA #$8011
    TSB $12
    COP [AddPosition] ( #08, #00 )
    COP [SetSpritePriority] ( #20 )
    COP [SpawnMarkedAfterAbs] ( @code_0A9A76, #$0058, #$00A0, #$0200 )
    TYA 
    STA $animScratch, X
    COP [SpawnMarkedAfterAbs] ( @code_0A9A84, #$0098, #$00A0, #$0200 )
    TYA 
    STA $animScratch+2, X
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    LDA #$0100
    TSB $12
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    LDA $characterForm
    CMP #$0002
    BEQ loc_0A9A57
    LDY $decelStepCounter
    LDA #$0088
    STA $0002, Y
    LDA #$EE8C
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $slopeCurvePtrB
    COP [SetEntryContinue]
    LDA $slopeCurvePtrB
    BIT #$0800
    BEQ loc_0A9A57
    RTL 

  loc_0A9A57:
    COP [SpawnLastRel] ( @code_0A9EB0, #00, #00, #$2200 )
    TYA 
    STA $orbitAngle, X
    COP [SetDeathCallback] ( @code_0A9BEA )
    COP [SpawnLastRel] ( @code_0A9AC7, #00, #00, #$2000 )
    JMP $&code_0A9BCD
} >
]

code_0A9A76 {
    COP [AddPosition] ( #08, #00 )
    LDA #$8023
    TSB $12
    COP [SetSpritePriority] ( #20 )
    BRA loc_0A9A92
}

code_0A9A84 {
    COP [AddPosition] ( #08, #00 )
    COP [ToggleHFlip]
    LDA #$8023
    TSB $12
    COP [SetSpritePriority] ( #20 )

  loc_0A9A92:
    LDA #$AD68
    STA $statsPtr, X
    LDA $@stats_table+190
    AND #$00FF
    STA $currentHp, X
    STA $orbitAngle, X
    COP [StageSpriteFrame] ( #06 )
    COP [AnimOnce]
    LDA $14
    STA $7F100C, X
    LDA $16
    STA $7F100E, X
    COP [SetEntryContinue]
    LDA $slopeCurvePtrB
    BIT #$0800
    BNE loc_0A9AC6
    JMP $&code_0AA19D

  loc_0A9AC6:
    RTL 
}

code_0A9AC7 {
    COP [SetEntryContinue]
    LDA $0AEC
    BEQ loc_0A9ACF
    RTL 

  loc_0A9ACF:
    LDY $decelStepCounter
    LDA #$0088
    STA $0002, Y
    LDA #$EC9E
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $slopeCurvePtrB
    COP [SetEntryContinue]
    LDA $slopeCurvePtrB
    BIT #$0800
    BEQ loc_0A9AF5
    RTL 

  loc_0A9AF5:
    COP [SetFlagWord] ( #$0175 )
    LDA #$0003
    STA $gfxCacheIdxA
    LDA #$0303
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #E0, #$03F8, #$03A0, #03, #$4830 )
    COP [Die]
}

actor_def_0A9B11 [
  actor-def < #01, #01, #03, {

  code_0A9B14:
    LDA #$0000
    JSL $@chunk_008000.code_00B10F
    BCC loc_0A9B25
    STZ $0AEC
    STZ $0AEE
    COP [Die]

  loc_0A9B25:
    LDA #$8011
    TSB $12
    COP [AddPosition] ( #08, #F8 )
    COP [SetSpritePriority] ( #20 )
    LDA #$008A
    AND #$00FF
    STA $0AF6
    LDA #$9BE2
    STA $0AF4
    JSL $@code_0AA2BE
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PlaySoundBoth] ( #$0E0E )
    COP [StageBgChange] ( #1E )
    COP [ApplyBgChange]
    COP [WaitByte] ( #27 )
    COP [StartMusic] ( #0F )
    COP [WaitByte] ( #3B )
    LDA #$EFF0
    TRB $joypadMaskStd
    JSL $@code_0AA2D4
    COP [SpawnLastRel] ( @chunk_008000.code_00D0E8, #00, #00, #$2000 )
    COP [SpawnMarkedAfterAbs] ( @code_0AA133, #$0050, #$00E0, #$0301 )
    TYA 
    STA $animScratch, X
    COP [WaitByte] ( #3B )
    COP [SpawnMarkedAfterAbs] ( @code_0AA141, #$00A0, #$00E0, #$0301 )
    TYA 
    STA $animScratch+2, X
    COP [WaitByte] ( #3B )
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    LDA #$0100
    TSB $12
    LDA #$0090
    STA $moveYAlt, X
    LDA $14
    STA $moveXAlt, X
    COP [MoveToward] ( #01, #01 )
    LDA #$0200
    TRB $10
    COP [SpawnLastRel] ( @code_0A9EB0, #00, #00, #$2200 )
    TYA 
    STA $orbitAngle, X
    COP [SetDeathCallback] ( @code_0A9BEA )
    STZ $26
} >
]

code_0A9BCD {
    COP [SetHitCallback] ( &code_0A9CE9 )

  code_0A9BD1:
    COP [WaitWord] ( #$010D )
    COP [SpawnMarkedAfter] ( @code_0A9D29, #$0302 )
    COP [WaitWord] ( #$010D )
    BRA code_0A9BCD

  loc_0A9BE2:
    ASL $0068, X
    BRK #$01
    BRK #$00
    BIT $AD
    LDY $&scene_warps.warp_def_0188FC+D, X
    BRK #$02
    BEQ loc_0A9BF5
    COP [SetEntryContinue]
    RTL 

  loc_0A9BF5:
    LDA #$0020
    TSB $slopeCurvePtrB
    LDY $26
    BEQ loc_0A9C0D
    STZ $26
    LDA #$9D76
    STA $0000, Y
    LDA #$0000
    STA $0008, Y

  loc_0A9C0D:
    LDA $orbitAngle, X
    PHX 
    TCD 
    TAX 
    COP [MarkDeath]
    PLA 
    TCD 
    TAX 
    LDA $animScratch, X
    TAY 
    LDA #$9C79
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA $animScratch+2, X
    TAY 
    LDA #$9C79
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    COP [SpawnLastRel] ( @code_0AA2B1, #00, #00, #$2000 )
    COP [SpawnLastRel] ( @code_0A9C55, #00, #00, #$2000 )
    COP [WaitByte] ( #3B )
    COP [JumpScript] ( @chunk_008000.code_00DCA9 )
}

code_0A9C55 {
    COP [SetMetasprite] ( @table_0EE000 )
    COP [LoopInit] ( #12 )
    COP [SpawnLastRel] ( @code_0A9CAB, #00, #C8, #$0302 )
    COP [WaitByte] ( #01 )
    COP [SpawnLastRel] ( @code_0A9CB8, #00, #C8, #$0302 )
    COP [WaitByte] ( #02 )
    COP [LoopNext]
    COP [Die]

  loc_0A9C79:
    COP [SpawnLastRel] ( @code_0A9C87, #00, #00, #$2000 )
    COP [WaitByte] ( #1D )
    COP [Die]
}

code_0A9C87 {
    COP [SetMetasprite] ( @table_0EE000 )
    COP [LoopInit] ( #0A )
    COP [SpawnLastRel] ( @code_0A9CAB, #00, #00, #$0302 )
    COP [WaitByte] ( #01 )
    COP [SpawnLastRel] ( @code_0A9CB8, #00, #00, #$0302 )
    COP [WaitByte] ( #02 )
    COP [LoopNext]
    COP [Die]
}

code_0A9CAB {
    JSR $&code_0A9CC2
    COP [PlaySoundCh1] ( #06 )
    COP [StageSpriteFrame] ( #07 )
    COP [AnimOnce]
    COP [Die]
}

code_0A9CB8 {
    JSR $&code_0A9CC2
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    COP [Die]
}

code_0A9CC2 {
    COP [RngByte]
    COP [RngByte]
    COP [RngMod] ( #60 )
    LDA $rngModuloResult
    SEC 
    SBC #$0030
    CLC 
    ADC $14
    STA $14
    COP [RngByte]
    COP [RngByte]
    COP [RngMod] ( #60 )
    LDA $rngModuloResult
    SEC 
    SBC #$0030
    CLC 
    ADC $16
    STA $16
    RTS 
}

code_0A9CE9 {
    LDA #$0200
    TSB $10
    COP [LoopInit] ( #05 )
    COP [PlaySoundCh1] ( #1F )
    COP [StageSpriteFrame] ( #28 )
    COP [AnimOnce]
    COP [LoopNext]
    COP [SpawnAfterRelFlags] ( @code_0A9D58, #$0000, #$FFE0, #$2202 )
    STY $26
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    COP [WaitWord] ( #$012B )
    LDA #$0200
    TRB $10
    LDY $26
    STZ $26
    LDA #$9D76
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    JMP $&code_0A9BD1
}

code_0A9D29 {
    COP [StageSpriteFrame] ( #25 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #26 )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @code_0A9FA0, #00, #A0, #$2000 )
    LDA $sceneCurrent
    CMP #$002A
    BCC loc_0A9D50
    COP [WaitByte] ( #0E )
    COP [SpawnLastRel] ( @code_0A9FA0, #00, #A0, #$2000 )

  loc_0A9D50:
    COP [StageSpriteLoop] ( #26, #08 )
    COP [AnimLoop]
    COP [Die]
}

code_0A9D58 {
    COP [SetSpritePriority] ( #30 )
    COP [SpawnMarkedAfter] ( @code_0A9D7F, #$0202 )
    COP [SpawnMarkedAfter] ( @code_0A9D78, #$0202 )
    COP [SetEntryContinue]
    LDY $24
    LDA $0010, Y
    BIT #$0040
    BNE loc_0A9D76
    RTL 

  loc_0A9D76:
    COP [Die]
}

code_0A9D78 {
    COP [StageSpriteFrame] ( #19 )
    COP [AnimOnce]
    BRA code_0A9D78
}

code_0A9D7F {
    PHX 
    LDX #$0000
    LDA $playerWallType
    CLC 
    ADC #$0008
    STA $0000
    SEC 
    SBC #$0080
    BMI loc_0A9DB2

  loc_0A9D93:
    CMP $@loc_0A9E6E+2A, X
    BCC loc_0A9DA2
    INX 
    INX 
    INX 
    INX 
    CPX #$0014
    BCC loc_0A9D93

  loc_0A9DA2:
    LDA $@loc_0A9E6E+2C, X
    PLX 
    PHA 
    LDA $0E
    ORA #$4000
    STA $0E
    PLA 
    BRA loc_0A9DCC

  loc_0A9DB2:
    BPL loc_0A9DB8
    EOR #$FFFF
    INC 

  loc_0A9DB8:
    CMP $@loc_0A9E6E+2A, X
    BCC loc_0A9DC7
    INX 
    INX 
    INX 
    INX 
    CPX #$0014
    BCC loc_0A9DB8

  loc_0A9DC7:
    LDA $@loc_0A9E6E+2C, X
    PLX 

  loc_0A9DCC:
    STA $28
    STZ $2A
    LDA #$2000
    TSB $10
    COP [WaitByte] ( #0F )
    LDA #$2000
    TRB $10
    COP [SpawnLastRel] ( @code_0A9DFB, #00, #00, #$2200 )
    COP [PlaySoundCh1] ( #20 )
    LDA #$0004
    STA $24

  loc_0A9DEE:
    COP [SetEntryContinue]
    COP [AnimOnce]
    DEC $24
    BPL loc_0A9DEE
    COP [SetEntryExitNow] ( @code_0A9D7F )
}

code_0A9DFB {
    COP [WaitByte] ( #03 )
    LDA #$2000
    TRB $10
    PHX 
    LDA $0E
    BIT #$4000
    BNE loc_0A9E20
    LDA $28
    SEC 
    SBC #$001D
    ASL 
    ASL 
    TAX 
    LDA $@loc_0A9E68, X
    STA $14
    LDA $@loc_0A9E6A, X
    BRA loc_0A9E33

  loc_0A9E20:
    LDA $28
    SEC 
    SBC #$001D
    ASL 
    ASL 
    TAX 
    LDA $@loc_0A9E6E+12, X
    STA $14
    LDA $@loc_0A9E6E+14, X

  loc_0A9E33:
    STA $16
    PLX 
    COP [PlaySoundCh1] ( #06 )
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #16 )
    COP [AnimOnce]
    COP [RngByte]
    AND #$0007
    SEC 
    SBC #$0003
    STA $14
    LDA $0411
    AND #$0007
    SEC 
    SBC $16
    STA $16
    COP [PlaySoundCh1] ( #06 )
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #16 )
    COP [AnimOnce]
    COP [Die]

  loc_0A9E68:
    BRA loc_0A9E6A

  loc_0A9E6A:
    DEC $00, X
    BVS loc_0A9E6E

  loc_0A9E6E:
    DEC $00, X
    LSR $00, X
    DEC $00, X
    SEC 
    BRK #$C6
    BRK #$1A
    BRK #$B0
    BRK #$1A
    BRK #$98
    BRK #$80
    BRK #$D6
    BRK #$93
    BRK #$D6
    BRK #$AA
    BRK #$D6
    BRK #$CA
    BRK #$C6
    BRK #$E7
    BRK #$B8
    BRK #$E5
    BRK #$98
    BRK #$0A
    BRK #$1D
    BRK #$15
    BRK #$1E
    BRK #$32
    BRK #$1F
    BRK #$59
    BRK #$20
    BRK #$5F
    BRK #$21
    BRK #$5D
    BRK #$22
    BRK #$02
    LDX $30, Y

  code_0A9EB3:
    COP [SetSavedPtr] ( &code_0A9EB3 )
    LDA #$2000
    TSB $10
    COP [LoopInit] ( #1E )
    COP [BranchIfPlayerInAbsTiles] ( #05, #02, #0C, #05, &code_0A9EEF )
    COP [BranchIfPlayerInAbsTiles] ( #05, #0A, #0B, #0C, &code_0A9F6F )
    COP [WaitByte] ( #04 )
    COP [LoopNext]
    LDA #$2000
    TRB $10
    COP [RngByte]
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0A9EE7 )
}

code_list_0A9EE7 [
  &code_0A9EFC   ;00
  &code_0A9F20   ;01
  &code_0A9F44   ;02
  &code_0A9F4B   ;03
]

code_0A9EEF {
    LDA #$2000
    TRB $10
    LDA $0036
    LSR 
    BCC code_0A9EFC
    BRA code_0A9F20
}

code_0A9EFC {
    LDA #$0008
    STA $14
    LDA #$003A
    STA $16
    COP [StageSpriteLoop] ( #27, #04 )
    COP [AnimLoop]
    COP [LoopInit] ( #10 )
    COP [SpawnAfterFlags] ( @code_0A9F98, #$0200 )
    COP [StageSpriteMoveX] ( #27, #03 )
    COP [AnimOnce]
    COP [LoopNext]
    COP [RestoreSavedPtr]
}

code_0A9F20 {
    LDA #$00F0
    STA $14
    LDA #$003A
    STA $16
    COP [StageSpriteLoop] ( #27, #04 )
    COP [AnimLoop]
    COP [LoopInit] ( #10 )
    COP [SpawnAfterFlags] ( @code_0A9F98, #$0200 )
    COP [StageSpriteMoveX] ( #27, #04 )
    COP [AnimOnce]
    COP [LoopNext]
    COP [RestoreSavedPtr]
}

code_0A9F44 {
    LDA #$0020
    STA $14
    BRA loc_0A9F50
}

code_0A9F4B {
    LDA #$00E0
    STA $14

  loc_0A9F50:
    LDA #$001C
    STA $16
    COP [StageSpriteLoop] ( #27, #04 )
    COP [AnimLoop]
    COP [LoopInit] ( #10 )
    COP [SpawnAfterFlags] ( @code_0A9F98, #$0200 )
    COP [StageSpriteMoveY] ( #27, #03 )
    COP [AnimOnce]
    COP [LoopNext]
    COP [RestoreSavedPtr]
}

code_0A9F6F {
    LDA #$2000
    TRB $10
    LDA #$0008
    STA $14
    LDA #$00B6
    STA $16
    COP [StageSpriteLoop] ( #27, #04 )
    COP [AnimLoop]
    COP [LoopInit] ( #10 )
    COP [SpawnAfterFlags] ( @code_0A9F98, #$0200 )
    COP [StageSpriteMoveX] ( #27, #03 )
    COP [AnimOnce]
    COP [LoopNext]
    COP [RestoreSavedPtr]
}

code_0A9F98 {
    COP [StageSpriteLoop] ( #27, #02 )
    COP [AnimLoop]
    COP [Die]
}

code_0A9FA0 {
    COP [SetSpritePriority] ( #30 )
    LDA #$0014
    STA $20
    LDA #$0001
    STA $22
    COP [StageSpriteLoop] ( #19, #04 )
    COP [AnimLoop]
    COP [PlaySoundCh1] ( #1F )
    COP [SpawnMarkedAfter] ( @code_0AA012, #$0302 )
    COP [StageSpriteLoop] ( #1A, #02 )
    COP [AnimLoop]
    COP [SetEntryExit]
    LDA $20
    CMP #$0010
    BCS loc_0A9FD6
    LDA $22
    EOR #$FFFF
    INC 
    STA $22
    BRA loc_0A9FE3

  loc_0A9FD6:
    CMP #$0028
    BCC loc_0A9FE3
    LDA $22
    EOR #$FFFF
    INC 
    STA $22

  loc_0A9FE3:
    LDA $20
    CLC 
    ADC $22
    STA $20
    LDY $24
    LDA $0010, Y
    BIT #$0040
    BNE loc_0A9FF5
    RTL 

  loc_0A9FF5:
    LDA #$2000
    TRB $10
    LDY $06
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    STA $16
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    COP [Die]
}

code_0AA012 {
    LDA $24
    STA $orbitAngle, X
    COP [SpawnMarkedAfter] ( @code_0AA0F8, #$0202 )
    LDA #$0000
    STA $0026, Y
    COP [SpawnMarkedAfter] ( @code_0AA0F8, #$0202 )
    LDA #$0055
    STA $0026, Y
    COP [SpawnMarkedAfter] ( @code_0AA0F8, #$0202 )
    LDA #$00AA
    STA $0026, Y
    COP [StageSpriteLoop] ( #24, #04 )
    COP [AnimLoop]
    LDA $0036
    LSR 
    BCC loc_0AA050
    LDA #$0030
    BRA loc_0AA053

  loc_0AA050:
    LDA #$FFD0

  loc_0AA053:
    CLC 
    ADC $14
    STA $moveXAlt, X
    LDA $16
    CLC 
    ADC #$0020
    STA $moveYAlt, X
    COP [MoveToward] ( #24, #02 )
    COP [StageForceMoveXY] ( #03, #03 )
    LDA $0036
    LSR 
    BCS loc_0AA076
    COP [StageForceMoveXY] ( #04, #03 )

  loc_0AA076:
    COP [StageSprAndHitbox] ( #24 )
    LDA #$0186
    STA $26

  loc_0AA07E:
    COP [ReloadForceMove]
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0AA07E
    LDA $08
    STA $24
    STZ $08

  loc_0AA08C:
    COP [SetEntryExit]
    LDA $14
    BMI loc_0AA097
    CMP #$0020
    BCS loc_0AA0A0

  loc_0AA097:
    LDA $12
    EOR #$4000
    STA $12
    BRA loc_0AA0AC

  loc_0AA0A0:
    CMP #$00E0
    BCC loc_0AA0AC
    LDA $12
    EOR #$4000
    STA $12

  loc_0AA0AC:
    LDA $16
    BMI loc_0AA0B5
    CMP #$0020
    BCS loc_0AA0BE

  loc_0AA0B5:
    LDA $12
    EOR #$2000
    STA $12
    BRA loc_0AA0CA

  loc_0AA0BE:
    CMP #$00C0
    BCC loc_0AA0CA
    LDA $12
    EOR #$2000
    STA $12

  loc_0AA0CA:
    DEC $26
    BMI loc_0AA0D4
    DEC $24
    BPL loc_0AA08C
    BRA loc_0AA07E

  loc_0AA0D4:
    LDA $24
    DEC 
    BMI loc_0AA0DD
    STA $08
    COP [SetEntryExit]

  loc_0AA0DD:
    COP [ReloadForceMove]
    COP [SetEntryContinue]
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_0AA0DD
    LDA $orbitAngle, X
    TAY 
    LDA #$9FF5
    STA $0000, Y
    COP [SetEntryContinue]
    RTL 
}

code_0AA0F8 {
    LDA $26
    STA $orbitAngle, X
    COP [StageSprAndHitbox] ( #23 )

  loc_0AA101:
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0AA101
    LDA $08
    STA $26
    STZ $08

  loc_0AA10D:
    LDA $parentId, X
    TAY 
    LDA $0020, Y
    STA $orbitDiameter, X
    LDA $orbitAngle, X
    CLC 
    ADC #$0002
    STA $orbitAngle, X
    LDY $24
    JSL $@chunk_008000.code_00F4BD
    COP [SetEntryExit]
    DEC $26
    BPL loc_0AA10D
    BRA loc_0AA101
}

code_0AA133 {
    COP [AddPosition] ( #08, #00 )
    LDA #$8023
    TSB $12
    COP [SetSpritePriority] ( #20 )
    BRA loc_0AA14F
}

code_0AA141 {
    COP [AddPosition] ( #08, #00 )
    COP [ToggleHFlip]
    LDA #$8023
    TSB $12
    COP [SetSpritePriority] ( #20 )

  loc_0AA14F:
    LDA #$AD68
    STA $statsPtr, X
    LDA $@stats_table+190
    AND #$00FF
    STA $currentHp, X
    STA $orbitAngle, X
    COP [StageSpriteMoveY] ( #03, #02 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    COP [SetSpritePriority] ( #30 )
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    COP [PlaySoundBoth] ( #$1515 )
    COP [SpawnLastRel] ( @chunk_008000.code_00D149, #00, #00, #$2000 )
    COP [CollPriorityClearMin]
    COP [StageSpriteFrame] ( #06 )
    COP [AnimOnce]
    LDA #$0101
    TRB $10
    LDA $14
    STA $7F100C, X
    LDA $16
    STA $7F100E, X
}

code_0AA19D {
    COP [SetDeathCallback] ( @code_0AA1F0 )

  code_0AA1A2:
    LDA #$0200
    TSB $10
    COP [BranchOnPlayerX] ( #$0030, &code_0AA1B1, &code_0AA1B8, &code_0AA1B1 )
}

code_0AA1B1 {
    COP [StageSpriteFrame] ( #06 )
    COP [AnimOnce]
    BRA code_0AA1A2
}

code_0AA1B8 {
    COP [StageSpriteLoop] ( #06, #03 )
    COP [AnimLoop]
    COP [BranchOnPlayerX] ( #$0020, &code_0AA1B1, &code_0AA1C8, &code_0AA1B1 )
}

code_0AA1C8 {
    COP [StageSpriteFrame] ( #07 )
    COP [AnimOnce]
    COP [SetSpritePriority] ( #20 )
    COP [StageSpriteFrame] ( #08 )
    COP [AnimOnce]
    COP [SetSpritePriority] ( #30 )
    COP [StageSpriteFrame] ( #09 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    COP [SetSavedPtr] ( &code_0AA1A2 )
    COP [BranchOnPlayerX] ( #$0020, &code_0AA200, &code_0AA228, &code_0AA24C )
}

code_0AA1F0 {
    LDA #$0040
    TRB $10
    LDA $orbitAngle, X
    STA $currentHp, X
    JMP $&code_0AA19D
}

code_0AA200 {
    COP [StageSpriteFrame] ( #0B )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #0C, #04 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #0D, #12 )
    COP [AnimOnce]
    COP [StageSpriteMoveXY] ( #0E, #02, #01 )
    COP [AnimOnce]
    COP [StageSpriteMoveXY] ( #0F, #02, #03 )
    COP [AnimOnce]
    COP [StageSpriteMoveXY] ( #10, #02, #05 )
    COP [AnimOnce]
    BRA loc_0AA272
}

code_0AA228 {
    COP [StageSpriteFrame] ( #0B )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #0C, #04 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0D )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #0E, #01 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #0F, #03 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #10, #05 )
    COP [AnimOnce]
    BRA loc_0AA272
}

code_0AA24C {
    COP [StageSpriteFrame] ( #0B )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #0C, #04 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #0D, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveXY] ( #0E, #01, #01 )
    COP [AnimOnce]
    COP [StageSpriteMoveXY] ( #0F, #01, #03 )
    COP [AnimOnce]
    COP [StageSpriteMoveXY] ( #10, #01, #05 )
    COP [AnimOnce]

  loc_0AA272:
    COP [PlaySoundCh1] ( #15 )
    COP [SpawnLastRel] ( @chunk_008000.code_00D149, #00, #00, #$2000 )
    COP [StageSpriteFrame] ( #11 )
    COP [AnimOnce]
    LDA $7F100C, X
    STA $moveXAlt, X
    LDA $7F100E, X
    STA $moveYAlt, X
    COP [MoveToward] ( #11, #01 )
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #08 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #07 )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @chunk_008000.code_00D149, #00, #00, #$2000 )
    COP [RestoreSavedPtr]
}

code_0AA2B1 {
    LDY $decelStepCounter
    LDA $0010, Y
    ORA #$0200
    STA $0010, Y
    RTL 
}

code_0AA2BE {
    LDY $decelStepCounter
    LDA #$0080
    STA $0002, Y
    LDA #$C57A
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    RTL 
}

code_0AA2D4 {
    LDY $decelStepCounter
    LDA #$0080
    STA $0002, Y
    LDA #$C5A2
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    RTL 
}

code_0AA2EA {
    LDA #$0000
    STA $onDodgeCallback, X
    STA $onHitCallback, X

  loc_0AA2F5:
    LDA $14
    SEC 
    SBC #$0008
    BIT #$0008
    BEQ loc_0AA309
    AND #$FFF0
    CLC 
    ADC #$0018
    BRA loc_0AA310

  loc_0AA309:
    AND #$FFF0
    CLC 
    ADC #$0008

  loc_0AA310:
    STA $moveXAlt, X
    LDA $16
    BIT #$0008
    BEQ loc_0AA324
    AND #$FFF0
    CLC 
    ADC #$0010
    BRA loc_0AA327

  loc_0AA324:
    AND #$FFF0

  loc_0AA327:
    STA $moveYAlt, X
    COP [SetEntryContinue]
    COP [MoveToward] ( #FF, #01 )
    LDA $14
    SEC 
    SBC #$0008
    ORA $16
    BIT #$000F
    BNE loc_0AA2F5
    COP [ResumeAfterSnap]
}

code_0AA340 {
    LDA #$0030
    TSB $12
    LDA $extendedFlags, X
    ORA #$0080
    STA $extendedFlags, X
    LDA #$ABD8
    STA $statsPtr, X
    LDA #$0001
    STA $currentHp, X
    RTL 
}

code_0AA35F {
    PHX 
    LDY $04
    LDX $06
    LDA $0014, Y
    CLC 
    ADC $0014, X
    CLC 
    BPL loc_0AA36F
    SEC 

  loc_0AA36F:
    ROR 
    STA $14
    LDA $0016, Y
    CLC 
    ADC $0016, X
    CLC 
    BPL loc_0AA37D
    SEC 

  loc_0AA37D:
    ROR 
    STA $16
    PLX 
    RTL 
}

code_0AA382 {
    LDA $0AEC
    CMP #$0001
    BNE loc_0AA3A3
    LDA #$6000
    TRB $12
    COP [StageForceMoveXY] ( #00, #00 )
    LDA #$0000
    STA $moveScratch1, X
    STA $moveScratch2, X
    COP [JumpScript] ( @chunk_008000.code_00DCA9 )

  loc_0AA3A3:
    COP [CallScript] ( &code_0AA3B7 )
    COP [SpawnAfterFlags] ( @chunk_008000.code_00DB97, #$0020 )
    LDA $orbitAngle, X
    STA $0026, Y
    COP [Die]
}

code_0AA3B7 {
    COP [PlaySoundCh1] ( #03 )
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
    COP [StageForceMoveXY] ( #00, #00 )
    LDA #$0000
    STA $moveScratch1, X
    STA $moveScratch2, X
    COP [SpawnLastRel] ( @chunk_008000.code_00E034, #00, #00, #$0302 )
    COP [SetDungeonKillFlag]
    LDA #$2000
    TSB $10
    LDA $extendedFlags, X
    BIT #$0008
    BEQ loc_0AA3FB
    COP [ClearLowHere]

  loc_0AA3FB:
    LDA $deathActionIdx, X
    BEQ loc_0AA423
    JSL $@chunk_008000.code_00B5A4
    BCS loc_0AA423
    LDA $deathActionIdx, X
    JSL $@chunk_008000.code_00B58E
    COP [SpawnLastRel] ( @chunk_008000.code_00DF11, #00, #00, #$0342 )
    PHX 
    LDA $deathActionIdx, X
    TYX 
    STA $deathActionIdx, X
    PLX 

  loc_0AA423:
    COP [RestoreSavedPtr]
}

actor_def_0AA425 [
  actor-def < #34, #02, #10, {

  code_0AA428:
    LDA #$0002
    STA $moveXAlt, X
    LDA #$0001
    STA $moveYAlt, X
    BRA loc_0AA460
} >
]

actor_def_0AA438 [
  actor-def < #34, #02, #10, {

  code_0AA43B:
    COP [AddPosition] ( #05, #00 )
    LDA #$0000
    STA $moveXAlt, X
    LDA #$0001
    STA $moveYAlt, X
    BRA loc_0AA460
} >
]

actor_def_0AA44F [
  actor-def < #34, #02, #10, {

  code_0AA452:
    LDA #$0001
    STA $moveXAlt, X
    LDA #$0000
    STA $moveYAlt, X

  loc_0AA460:
    LDA $14
    STA $orbitAngle, X
    LDA $16
    STA $orbitDiameter, X
    COP [SetEntryContinue]
    LDA $orbitAngle, X
    CLC 
    ADC $moveXAlt, X
    STA $orbitAngle, X
    SEC 
    SBC $cameraDeltaX
    CLC 
    ADC $cameraTargetX
    STA $14
    LDA $orbitDiameter, X
    CLC 
    ADC $moveYAlt, X
    STA $orbitDiameter, X
    SEC 
    SBC $cameraDeltaY
    CLC 
    ADC $cameraTargetY
    STA $16
    LDA $14
    BMI loc_0AA4AF
    CMP $effectBoundsX
    BCS loc_0AA4CC
    LDA $16
    BMI loc_0AA4AF
    CMP $effectBoundsY
    BCS loc_0AA4CC
    RTL 

  loc_0AA4AF:
    LDA $moveXAlt, X
    BPL loc_0AA4BD
    EOR #$FFFF
    INC 
    STA $moveXAlt, X

  loc_0AA4BD:
    LDA $moveYAlt, X
    BPL loc_0AA4CB
    EOR #$FFFF
    INC 
    STA $moveYAlt, X

  loc_0AA4CB:
    RTL 

  loc_0AA4CC:
    LDA $moveXAlt, X
    BMI loc_0AA4DA
    EOR #$FFFF
    INC 
    STA $moveXAlt, X

  loc_0AA4DA:
    LDA $moveYAlt, X
    BMI loc_0AA4E8
    EOR #$FFFF
    INC 
    STA $moveYAlt, X

  loc_0AA4E8:
    RTL 
} >
]

actor_def_0AA4E9 [
  actor-def < #34, #01, #03, {

  code_0AA4EC:
    SEP #$20
    LDA #$23
    STA $COLDATA
    LDA #$42
    STA $COLDATA
    REP #$20
    LDA $playerWallType
    CMP #$0030
    BCS loc_0AA541
    COP [SetTilePos] ( #04, #08 )
    COP [SetEntryContinue]
    COP [BranchIfPlayerAt] ( #$0048, #$0080, &code_0AA511 )
    RTL 
} >
]

code_0AA511 {
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [SetEntryContinue]

  loc_0AA519:
    COP [StageSpriteMoveXY] ( #34, #03, #01 )
    COP [AnimOnce]
    JSR $&code_0AA580
    LDY $decelStepCounter
    LDA $14
    INC 
    STA $0014, Y
    LDA $16
    STA $0016, Y
    CMP #$0340
    BEQ loc_0AA538
    BRA loc_0AA519

  loc_0AA538:
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SetEntryContinue]
    RTL 

  loc_0AA541:
    COP [SetTilePos] ( #5C, #34 )
    COP [SetEntryContinue]
    COP [BranchIfPlayerAt] ( #$05C8, #$0340, &code_0AA550 )
    RTL 
}

code_0AA550 {
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [SetEntryContinue]

  loc_0AA558:
    COP [StageSpriteMoveXY] ( #34, #04, #02 )
    COP [AnimOnce]
    JSR $&code_0AA580
    LDY $decelStepCounter
    LDA $14
    DEC 
    STA $0014, Y
    LDA $16
    STA $0016, Y
    CMP #$0080
    BEQ loc_0AA577
    BRA loc_0AA558

  loc_0AA577:
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SetEntryContinue]
    RTL 
}

code_0AA580 {
    LDA $0036
    AND #$000F
    BNE loc_0AA58B
    COP [PlaySoundCh2] ( #0C )

  loc_0AA58B:
    COP [BranchIfButton] ( #$0801, &code_0AA5A4 )
    COP [BranchIfButton] ( #$0401, &code_0AA5A9 )
    COP [BranchIfButton] ( #$0201, &code_0AA5AE )
    COP [BranchIfButton] ( #$0101, &code_0AA5B3 )
    RTS 
}

code_0AA5A4 {
    LDA #$0001
    BRA loc_0AA5B6
}

code_0AA5A9 {
    LDA #$0000
    BRA loc_0AA5B6
}

code_0AA5AE {
    LDA #$0002
    BRA loc_0AA5B6
}

code_0AA5B3 {
    LDA #$0003

  loc_0AA5B6:
    JSL $@chunk_008000.widestring_00C829
    RTS 
}

actor_def_0AA5BB [
  actor-def < #34, #01, #13, {

  code_0AA5BE:
    COP [AddPosition] ( #05, #00 )

  loc_0AA5C2:
    COP [SetEntryContinue]
    COP [StageForceMoveY] ( #01 )
    LDA $16
    CMP $mapBoundsY
    BEQ loc_0AA5CF
    RTL 

  loc_0AA5CF:
    COP [SetEntryContinue]
    COP [StageForceMoveY] ( #02 )
    LDA $16
    CMP #$0000
    BEQ loc_0AA5C2
    RTL 
} >
]

actor_def_0AA5DC [
  actor-def < #34, #01, #13, {

  loc_0AA5DF:
    COP [SetEntryContinue]
    COP [StageForceMoveX] ( #01 )
    LDA $14
    CMP $mapBoundsX
    BEQ loc_0AA5EC
    RTL 

  loc_0AA5EC:
    COP [SetEntryContinue]
    COP [StageForceMoveX] ( #02 )
    LDA $14
    CMP #$0000
    BEQ loc_0AA5DF
    RTL 
} >
]

actor_def_0AA5F9 [
  actor-def < #0C, #00, #10, {

  code_0AA5FC:
    LDA #$1000
    TSB $12
    LDA $0E
    STA $24
    PHX 
    TAX 
    LDA $@loc_0AA672, X
    PLX 
    AND #$00FF
    JSL $@chunk_008000.code_00B565
    BCC loc_0AA618
    JMP $&code_0AA670

  loc_0AA618:
    LDA #$2000
    STA $0E
    LDA #$0200
    TSB $12
    COP [SpawnAfterFlags] ( @code_0AA8AF, #$0100 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_0AA676 )
    COP [SetEntryContinue]
    LDY $06
    LDA $0010, Y
    BIT #$0040
    BNE code_0AA63C
    RTL 

  code_0AA63C:
    COP [SetOnInteract] ( &code_0AA67B )
    COP [SetEntryContinue]
    RTL 
} >
]

code_0AA643 {
    COP [SetOnInteract] ( #$0000 )
    LDA #$0800
    TSB $10
    COP [ClearLowHere]
    LDA #$0080
    TSB $09FA
    COP [StageSpriteLoopMoveY] ( #0D, #08, #01 )
    COP [AnimLoop]
    LDA #$0080
    TRB $09FA
    PHX 
    LDX $24
    LDA $@loc_0AA672, X
    PLX 
    AND #$00FF
    JSL $@chunk_008000.code_00B56C
}

code_0AA670 {
    COP [Die]

  loc_0AA672:
    LDY #$A2A1
    LDA $02, S
    LDA $@2BA6D4, X
}

code_0AA67B {
    LDA #$A643
    STA $00
    LDA $24
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0AA68B )
}

code_list_0AA68B [
  &code_0AA6CF   ;00
  &code_0AA6CA   ;01
  &code_0AA694   ;02
  &code_0AA6B4   ;03
  $#026B   ;04
  &code_0AF7BF   ;05
  $#02A6   ;06
  $#0CD4   ;07
  &code_0AA6AA   ;08
  &code_0A80A9   ;09
  $#0C00   ;0A
  $#09FA   ;0B
  $#1902   ;0C
  $#3317   ;0D
  &code_0A8AA7   ;0E
  &code_0AA96B   ;0F
  &code_0AA63C   ;10
  $#0085   ;11
  &code_0ABF02   ;12
  &code_0AA89A   ;13
  $#026B   ;14
  $#4DBF   ;15
  $#02A7   ;16
  $#0FD4   ;17
  &code_0AA6AA   ;18
  &code_0A80A9   ;19
  $#0C00   ;1A
  $#09FA   ;1B
  $#1902   ;1C
  &code_0A9417   ;1D
  &code_0A8AA7   ;1E
  $#026B   ;1F
  &code_0AAFBF   ;20
  $#6BA7   ;21
]

code_0AA6CF {
    COP [PrintWideString] ( &widestring_0AA860 )
    RTL 
}

code_0AA6D4 {
    CMP [$D4], Y
    ASL $3C64
    CMP $7F, X
    CMP $&20803F

  loc_0AA6DE:
    SBC $@070D3C
    ADC $44CD, X
    EOR ($20, S), Y
    WDM 
    EOR $62
    ADC [$20]
    BRA loc_0AA6DE

  loc_0AA6EE:
    ROR $424D
    ASL 
    EOR $3C
    ADC $&20C07D, X
    CMP [$D4], Y
    ASL $3C64
    CMP $7F, X
    CMP $203B
    TSC 
    PER loc_0AF505
    AND $7D7D, X
    CMP $5344
    JSR $&code_0A8004
    SBC ($54), Y
    JSR $&code_0AF280
    LSR $4D
    BRA loc_0AA70A

  loc_0AA717:
    STZ $59
    PHA 
    PLA 
    RTS 
}

code_0AA71C {
    ORA $@spm_castle_sprites+E9, X
    PEI ($40)
    ORA ($D5, X)
    ADC [$20]
    EOR $4D6E, X
    BIT $4D6E, X
    BRA loc_0AA6EF

  loc_0AA72E:
    EOR $3C
    ORA $@gfx_pyramid+770, X
    DEC $00, X
    CMP $&208009, Y
    EOR ($80), Y
    EOR ($53)
    PEI ($40)
    ORA ($D5, X)
    ADC [$20]
    BRA loc_0AA747

  loc_0AA745:
    BVC loc_0AA783

  loc_0AA747:
    STZ $4A
    ADC $&20FFC9, X
    CPY #$D4D7
    ASL 

  loc_0AA750:
    BIT $5D5E, X
    PLA 
    ASL $5180
    BRA loc_0AA7AB

  loc_0AA759:
    CMP $53, X
    JSR $&code_0AF480
    BRA loc_0AA6E6

  loc_0AA760:
    BVC loc_0AA7BF
    CMP $4A54
    ADC ($40, X)

  loc_0AA767:
    EOR $64
    EOR $633C
    BRA loc_0AA79D

  loc_0AA76E:
    LSR 
    PHK 
    BRK #$3C
    EOR $1F47, Y
    CMP ($44), Y
    EOR ($D4, S), Y
    RTI 
    ORA ($D5, X)
    ADC [$80]
    TCD 
    ROR $&20CD4D
    ASL $403D
    JSR $0380
    EOR $4D, S
    TSC 
    ORA $4D, S
    BRA loc_0AA750

  loc_0AA78F:
    EOR $3C
    ORA $@gfx_pyramid+770, X
    DEC $00, X
    CMP $&20D409, Y
    PER loc_0AF5F3

  loc_0AA79D:
    CMP $53, X
    PEI ($40)
    ORA ($D5, X)
    ADC [$20]
    BRA loc_0AA7A9

  loc_0AA7A7:
    BVC loc_0AA7E5

  loc_0AA7A9:
    STZ $4A

  loc_0AA7AB:
    ADC $&20FFC9, X
    CPY #$80D7
    ORA $43, S
    EOR $6442
    EOR $3B20
    PER loc_0AF5BC
    AND $&20CD1F, X

  loc_0AA7BF:
    AND $@gfx_angkor_vision+1205, X
    JSR $3C3C
    MVP #$4E, #$67
    JSR $&code_0A8A80
    ROL $4759, X
    ORA $@spm_castle_sprites+E9, X
    BRA loc_0AA826

  loc_0AA7D5:
    BRA loc_0AA829

  loc_0AA7D7:
    BVC loc_0AA82D
    JSR $4240
    EOR $64
    LSR 
    BRA loc_0AA767

  loc_0AA7E1:
    BRA loc_0AA837

  loc_0AA7E3:
    BRK #$CD

  loc_0AA7E5:
    TSC 
    ROR $204D
    EOR #$8053
    ORA $@3B8062
    MVN #$20, #$D4
    RTI 
    ORA [$D5], Y
    LSR $&2080CD
    ROL $80, X
    LDX $0043, Y
    JMP $5941
    PHA 
    PLA 
    ORA $@070DD1, X
    BRK #$20
    PEI ($40)
    ORA [$D5], Y
    EOR ($47, S), Y
    EOR ($59, X)
    RTI 
    ADC ($20, X)
    LSR $41, X
    MVP #$5B, #$CD
    BRA loc_0AA85F

  loc_0AA81B:
    BVC loc_0AA79D
    AND $4267, X
    TRB $64
    TRB $20
    BRA loc_0AA85C

  loc_0AA826:
    JMP $6143

  loc_0AA829:
    STZ $63
    ROR $&20CD4D
    BRA loc_0AA844

  loc_0AA830:
    ORA $1F47
    CMP ($5D), Y
    ROR $5D4E
    JSR $4F3B
    LSR 
    EOR ($60, S), Y
    AND $&20CD4F, X
    EOR $61
    EOR $61
    EOR ($D4, S), Y
    RTI 
    PHY 
    CMP $4F, X
    ADC ($20, X)
    EOR $@gfx_southcape_interior+B65
    ADC ($CD, X)
    EOR [$02]
    JSR $4066
    ADC $0D, S
    LSR $71

  loc_0AA85C:
    AND $1F52, X

  loc_0AA85F:
    CPY #$44D7
    EOR ($80, S), Y
    EOR ($80), Y
    EOR ($50)
    MVN #$20, #$80
    BRK #$5D
    JSR $4256
    JML $@code_3BCD4D
}

code_0AA874 {
    BRA loc_0AA8A5

  loc_0AA876:
    EOR ($D4, S), Y
    ASL $3C64
    CMP $00, X
    JSR $&code_0AAF80
    RTI 
    EOR $64
    EOR $593C
    EOR [$1F]
    CMP $3D0E
    RTI 
    JSR $0380
    EOR $4D, S
    TSC 
    ORA $4D, S
    BRA loc_0AA857

  loc_0AA896:
    EOR $3C
    ORA $@gfx_pyramid+125F, X
    LSR $40
    LSR $20
    BRA loc_0AA8D9

  loc_0AA8A2:
    PHK 
    BRA loc_0AA8DD

  loc_0AA8A5:
    BRK #$3C
    ROR $3C19
    ASL 
    ROR $7D4A
    CPY #$4022
    LDA $8A, S
    COP [StageSpriteFrame] ( #33 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
}

actor_def_0AA8BB [
  actor-def < #00, #00, #01, {

  code_0AA8BE:
    COP [BranchIfFlagWord] ( #$0133, #01, &code_0AA91E )
    COP [AddPosition] ( #08, #08 )
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    LDA #$ABD8
    STA $statsPtr, X
    LDA #$0031

  loc_0AA8DD:
    TSB $12

  loc_0AA8DF:
    LDA #$00FF
    STA $currentHp, X
    COP [SetEntryContinue]
    LDA $currentHp, X
    CMP #$00FF
    BNE loc_0AA901
    COP [BranchIfPlayerInAbsTiles] ( #05, #03, #07, #07, &code_0AA8FD )
    COP [ClearFlagByte] ( #00 )
    RTL 
} >
]

code_0AA8FD {
    COP [SetFlagByte] ( #00 )
    RTL 

  loc_0AA901:
    LDA $slopeCurvePtrB
    BIT #$0002
    BNE loc_0AA90E
    DEC $24
    BMI loc_0AA8DF
    RTL 

  loc_0AA90E:
    COP [SpawnAfterFlags] ( @chunk_008000.widestring_00CB00, #$2000 )
    COP [StageBgChange] ( #33 )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0133 )
}

code_0AA91E {
    COP [Die]
}

actor_def_0AA920 [
  actor-def < #00, #00, #00, {

  code_0AA923:
    LDA #$0002
    TSB $12
    COP [SetHFlip]

  loc_0AA92A:
    COP [WaitWhileOffscreen] ( #10 )
    COP [LoopInit] ( #02 )
    COP [SetHitCallback] ( #$0000 )
    COP [CallScript] ( &code_0AAD0D )
    COP [SetHitCallback] ( &code_0AA98A )
    COP [BranchIfPlayerNear] ( #04, &code_0AA98A )
    COP [LoopNext]
    COP [LoopInit] ( #14 )
    COP [RngByte]
    AND #$0003
    STA $08
    COP [BranchIfPlayerNear] ( #04, &code_0AA98A )
    COP [LoopNext]
    BRA loc_0AA92A
} >
]

actor_def_0AA956 [
  actor-def < #00, #00, #00, {

  code_0AA959:
    LDA #$0002
    TSB $12

  loc_0AA95E:
    COP [WaitWhileOffscreen] ( #10 )
    COP [LoopInit] ( #02 )
    COP [SetHitCallback] ( #$0000 )
    COP [CallScript] ( &code_0AAC92 )
    COP [SetHitCallback] ( &code_0AA98A )
    COP [BranchIfPlayerNear] ( #04, &code_0AA98A )
    COP [LoopNext]
    COP [LoopInit] ( #14 )
    COP [RngByte]
    AND #$0003
    STA $08
    COP [BranchIfPlayerNear] ( #04, &code_0AA98A )
    COP [LoopNext]
    BRA loc_0AA95E
} >
]

code_0AA98A {
    COP [SetHitCallback] ( #$0000 )
    LDA #$0002
    TRB $12
    JMP $&code_0AAA25
}

actor_def_0AA996 [
  actor-def < #00, #00, #00, {

  code_0AA999:
    COP [RngByte]
    AND #$003F
    STA $08

  code_0AA9A0:
    COP [SetEntryExit]
    COP [LoopInit] ( #02 )
    COP [BranchIfPlayerNear] ( #04, &code_0AAA25 )
    COP [BranchIfSolidSouth] ( &code_0AA9BA )
    COP [StageSpriteMoveY] ( #03, #11 )
    COP [AnimOnce]
    COP [LoopNext]
    COP [CallScript] ( &code_0AAA02 )
} >
]

code_0AA9BA {
    COP [SetEntryExit]
    COP [LoopInit] ( #02 )
    COP [BranchIfPlayerNear] ( #04, &code_0AAA25 )
    COP [BranchIfSolidSouth] ( &code_0AA9D4 )
    COP [StageSpriteMoveY] ( #04, #12 )
    COP [AnimOnce]
    COP [LoopNext]
    COP [CallScript] ( &code_0AAA02 )
}

code_0AA9D4 {
    COP [SetEntryExit]
    COP [LoopInit] ( #02 )
    COP [BranchIfSolidWest] ( &code_0AA9EA )
    COP [StageSpriteMoveX] ( #05, #12 )
    COP [AnimOnce]
    COP [BranchIfPlayerNear] ( #04, &code_0AAA25 )
    COP [LoopNext]
}

code_0AA9EA {
    COP [SetEntryExit]
    COP [LoopInit] ( #02 )
    COP [BranchIfSolidEast] ( &code_0AA9A0 )
    COP [StageSpriteMoveX] ( #85, #11 )
    COP [AnimOnce]
    COP [BranchIfPlayerNear] ( #04, &code_0AAA25 )
    COP [LoopNext]
    BRA code_0AA9A0
}

code_0AAA02 {
    COP [StageSpriteLoop] ( #02, #40 )
    COP [AnimLoop]
    COP [BranchIfPlayerNear] ( #04, &code_0AAA25 )
    COP [StageSpriteLoop] ( #00, #10 )
    COP [AnimLoop]
    COP [BranchIfPlayerNear] ( #04, &code_0AAA25 )
    COP [StageSpriteLoop] ( #82, #40 )
    COP [AnimLoop]
    COP [BranchIfPlayerNear] ( #04, &code_0AAA25 )
    COP [RestoreSavedPtr]
}

code_0AAA25 {
    LDA #$0001
    TSB $12
    COP [BranchNearerAxis] ( &code_0AAA30, &code_0AAA67 )
}

code_0AAA30 {
    COP [SetEntryExit]
    COP [BranchOnPlayerX] ( #$0030, &code_0AAAAA, &code_0AAA3C, &code_0AAADE )
}

code_0AAA3C {
    COP [BranchOnPlayerX] ( #$0000, &code_0AAA57, &code_0AAA46, &code_0AAA46 )
}

code_0AAA46 {
    LDA #$0100
    TSB $12
    COP [CallScript] ( &code_0AACE1 )
    LDA #$0100
    TRB $10
    JMP $&code_0AAADE
}

code_0AAA57 {
    LDA #$0100
    TSB $12
    COP [CallScript] ( &code_0AAC66 )
    LDA #$0100
    TRB $10
    BRA code_0AAAAA
}

code_0AAA67 {
    COP [SetEntryExit]
    COP [BranchOnPlayerY] ( #$0030, &code_0AAB46, &code_0AAA73, &code_0AAB12 )
}

code_0AAA73 {
    COP [BranchOnPlayerY] ( #$0000, &code_0AAA7D, &code_0AAA8E, &code_0AAA8E )
}

code_0AAA7D {
    LDA #$0100
    TSB $12
    COP [CallScript] ( &code_0AABEA )
    LDA #$0100
    TRB $10
    JMP $&code_0AAB46
}

code_0AAA8E {
    LDA #$0100
    TSB $12
    COP [CallScript] ( &code_0AAB6E )
    LDA #$0100
    TRB $10
    BRA code_0AAB12

  code_0AAA9E:
    COP [SetEntryExit]
    COP [BranchIfSolidWest] ( &code_0AAADE )
    COP [StageSpriteMoveX] ( #05, #12 )
    COP [AnimOnce]
}

code_0AAAAA {
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]

  loc_0AAAAF:
    COP [BranchIfSolidWest] ( &code_0AAAD2 )
    COP [StageSpriteMoveX] ( #05, #12 )
    COP [AnimOnce]
    COP [BranchNearerAxis] ( &code_0AAABF, &code_0AAB12 )
}

code_0AAABF {
    COP [BranchOnPlayerX] ( #$0080, &code_0AAAC9, &code_0AAAC9, &code_0AAADE )
}

code_0AAAC9 {
    COP [SetEntryExit]
    COP [BranchIfPlayerNear] ( #04, &code_0AAA25 )
    BRA loc_0AAAAF
}

code_0AAAD2 {
    COP [SetEntryExit]
    COP [BranchIfSolidEast] ( &code_0AAB12 )
    COP [StageSpriteMoveX] ( #85, #11 )
    COP [AnimOnce]
}

code_0AAADE {
    COP [StageSpriteFrame] ( #82 )
    COP [AnimOnce]

  loc_0AAAE3:
    COP [BranchIfSolidEast] ( &code_0AAB06 )
    COP [StageSpriteMoveX] ( #85, #11 )
    COP [AnimOnce]
    COP [BranchNearerAxis] ( &code_0AAAF3, &code_0AAB12 )
}

code_0AAAF3 {
    COP [BranchOnPlayerX] ( #$0080, &code_0AAAC9, &code_0AAAFD, &code_0AAAFD )
}

code_0AAAFD {
    COP [SetEntryExit]
    COP [BranchIfPlayerNear] ( #04, &code_0AAA25 )
    BRA loc_0AAAE3
}

code_0AAB06 {
    COP [SetEntryExit]
    COP [BranchIfSolidSouth] ( &code_0AAB46 )
    COP [StageSpriteMoveY] ( #03, #11 )
    COP [AnimOnce]
}

code_0AAB12 {
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]

  loc_0AAB17:
    COP [BranchIfSolidSouth] ( &code_0AAB3A )
    COP [StageSpriteMoveY] ( #03, #11 )
    COP [AnimOnce]
    COP [BranchNearerAxis] ( &code_0AAAAA, &code_0AAB27 )
}

code_0AAB27 {
    COP [BranchOnPlayerY] ( #$0080, &code_0AAB65, &code_0AAB31, &code_0AAB31 )
}

code_0AAB31 {
    COP [SetEntryExit]
    COP [BranchIfPlayerNear] ( #04, &code_0AAA25 )
    BRA loc_0AAB17
}

code_0AAB3A {
    COP [SetEntryExit]
    COP [BranchIfSolidNorth] ( &code_0AAAAA )
    COP [StageSpriteMoveY] ( #04, #12 )
    COP [AnimOnce]
}

code_0AAB46 {
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]

  loc_0AAB4B:
    COP [BranchIfSolidNorth] ( &code_0AAA9E )
    COP [StageSpriteMoveY] ( #04, #12 )
    COP [AnimOnce]
    COP [BranchNearerAxis] ( &code_0AAAAA, &code_0AAB5B )
}

code_0AAB5B {
    COP [BranchOnPlayerY] ( #$0080, &code_0AAB65, &code_0AAB65, &code_0AAB31 )
}

code_0AAB65 {
    COP [SetEntryExit]
    COP [BranchIfPlayerNear] ( #04, &code_0AAA25 )
    BRA loc_0AAB4B
}

code_0AAB6E {
    LDA $14
    STA $moveXAlt, X
    LDA $playerSpeedEw
    AND #$FFF0
    SEC 
    SBC #$0010
    STA $moveYAlt, X
    LDA #$0008
    TSB $10
    LDA #$0010
    TSB $12
    COP [MoveToward] ( #09, #02 )
    LDA #$0010
    TRB $12
    LDA #$0008
    TRB $10
    COP [StageSpriteFrame] ( #09 )
    COP [AnimOnce]
    COP [PlaySoundCh1] ( #23 )
    LDA #$0010
    TSB $12
    COP [StageSpriteFrame] ( #06 )
    COP [AnimOnce]
    COP [SpawnMarkedAfterRel] ( @code_0AAD70, #F0, #D0, #$0202 )
    COP [SpawnMarkedAfterRel] ( @code_0AAE81, #F0, #D4, #$0302 )
    COP [SpawnMarkedAfterRel] ( @code_0AAE81, #F0, #D8, #$0302 )
    COP [SpawnMarkedAfterRel] ( @code_0AAE81, #F0, #DC, #$0302 )
    COP [SpawnMarkedAfterRel] ( @code_0AAE81, #F0, #E0, #$0302 )
    COP [SpawnMarkedAfterRel] ( @code_0AAE90, #F0, #E4, #$0302 )
    COP [StageSpriteFrame] ( #13 )
    COP [AnimOnce]
    JMP $&code_0AAD5A
}

code_0AABEA {
    LDA $14
    STA $moveXAlt, X
    LDA $playerSpeedEw
    AND #$FFF0
    CLC 
    ADC #$0050
    STA $moveYAlt, X
    LDA #$0008
    TSB $10
    LDA #$0010
    TSB $12
    COP [MoveToward] ( #0A, #02 )
    LDA #$0010
    TRB $12
    LDA #$0008
    TRB $10
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    COP [PlaySoundCh1] ( #23 )
    LDA #$0010
    TSB $12
    COP [StageSpriteFrame] ( #07 )
    COP [AnimOnce]
    COP [SpawnMarkedAfterRel] ( @code_0AAD95, #10, #E0, #$0200 )
    COP [SpawnMarkedAfterRel] ( @code_0AAE81, #11, #DC, #$0300 )
    COP [SpawnMarkedAfterRel] ( @code_0AAE81, #12, #D8, #$0300 )
    COP [SpawnMarkedAfterRel] ( @code_0AAE81, #14, #D4, #$0300 )
    COP [SpawnMarkedAfterRel] ( @code_0AAE81, #12, #D0, #$0300 )
    COP [SpawnMarkedAfterRel] ( @code_0AAE9C, #0C, #D0, #$0300 )
    COP [StageSpriteFrame] ( #14 )
    COP [AnimOnce]
    JMP $&code_0AAD5A
}

code_0AAC66 {
    LDA $playerWallType
    AND #$FFF0
    CLC 
    ADC #$0048
    STA $moveXAlt, X
    LDA $16
    STA $moveYAlt, X
    LDA #$0008
    TSB $10
    LDA #$0010
    TSB $12
    COP [MoveToward] ( #0B, #02 )
    LDA #$0010
    TRB $12
    LDA #$0008
    TRB $10
}

code_0AAC92 {
    COP [StageSpriteFrame] ( #0B )
    COP [AnimOnce]
    COP [PlaySoundCh1] ( #23 )
    LDA #$0010
    TSB $12
    COP [StageSpriteFrame] ( #08 )
    COP [AnimOnce]
    COP [SpawnMarkedAfterRel] ( @code_0AADBA, #DE, #C0, #$0200 )
    COP [SpawnMarkedAfterRel] ( @code_0AAE86, #E0, #C4, #$0300 )
    COP [SpawnMarkedAfterRel] ( @code_0AAE86, #E2, #C8, #$0300 )
    COP [SpawnMarkedAfterRel] ( @code_0AAE86, #E3, #CC, #$0300 )
    COP [SpawnMarkedAfterRel] ( @code_0AAE86, #E3, #D0, #$0300 )
    COP [SpawnMarkedAfterRel] ( @code_0AAEA9, #E3, #E8, #$0300 )
    COP [StageSpriteFrame] ( #15 )
    COP [AnimOnce]
    BRA code_0AAD5A
}

code_0AACE1 {
    LDA $playerWallType
    AND #$FFF0
    SEC 
    SBC #$0038
    STA $moveXAlt, X
    LDA $16
    STA $moveYAlt, X
    LDA #$0008
    TSB $10
    LDA #$0010
    TSB $12
    COP [MoveToward] ( #8B, #02 )
    LDA #$0010
    TRB $12
    LDA #$0008
    TRB $10
}

code_0AAD0D {
    COP [StageSpriteFrame] ( #8B )
    COP [AnimOnce]
    COP [PlaySoundCh1] ( #23 )
    LDA #$0010
    TSB $12
    COP [StageSpriteFrame] ( #88 )
    COP [AnimOnce]
    COP [SpawnMarkedAfterRel] ( @code_0AADD7, #14, #C4, #$0200 )
    COP [SpawnMarkedAfterRel] ( @code_0AAE86, #16, #C8, #$0300 )
    COP [SpawnMarkedAfterRel] ( @code_0AAE86, #18, #CC, #$0300 )
    COP [SpawnMarkedAfterRel] ( @code_0AAE86, #19, #D0, #$0300 )
    COP [SpawnMarkedAfterRel] ( @code_0AAE86, #1A, #D4, #$0300 )
    COP [SpawnMarkedAfterRel] ( @code_0AAEB5, #1B, #D8, #$0300 )
    COP [StageSpriteFrame] ( #95 )
    COP [AnimOnce]
}

code_0AAD5A {
    COP [WaitByte] ( #4F )
    LDA #$0010
    TRB $12
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    COP [RestoreSavedPtr]
}

code_0AAD70 {
    LDA #$FFF4
    STA $7F100C, X
    LDA #$FFFC
    STA $7F100E, X
    COP [StageSprAndHitbox] ( #10 )
    LDA $16
    CLC 
    ADC #$0060
    STA $moveYAlt, X
    COP [BranchOnPlayerX] ( #$0018, &code_0AAE35, &code_0AAE28, &code_0AAE35 )
}

code_0AAD95 {
    LDA #$000C
    STA $7F100C, X
    LDA #$FFFC
    STA $7F100E, X
    COP [StageSprAndHitbox] ( #11 )
    LDA $16
    SEC 
    SBC #$0040
    STA $moveYAlt, X
    COP [BranchOnPlayerX] ( #$0018, &code_0AAE41, &code_0AAE28, &code_0AAE41 )
}

code_0AADBA {
    LDA #$FFE8
    STA $7F100C, X
    LDA #$FFEA
    STA $7F100E, X
    COP [StageSprAndHitbox] ( #12 )
    LDA $14
    SEC 
    SBC #$0050
    STA $moveXAlt, X
    BRA loc_0AADF7
}

code_0AADD7 {
    LDA #$0012
    STA $7F100C, X
    LDA #$FFEB
    STA $7F100E, X
    COP [StageSprAndHitbox] ( #92 )
    LDA #$0002
    TSB $12
    LDA $14
    CLC 
    ADC #$0050
    STA $moveXAlt, X

  loc_0AADF7:
    LDA $16
    CLC 
    ADC #$0030
    STA $16
    COP [BranchOnPlayerY] ( #$0018, &code_0AAE1A, &code_0AAE09, &code_0AAE1A )
}

code_0AAE09 {
    LDA $16
    SEC 
    SBC #$0030
    STA $16
    LDA $playerSpeedEw
    STA $moveYAlt, X
    BRA loc_0AAE4B
}

code_0AAE1A {
    LDA $16
    STA $moveYAlt, X
    SEC 
    SBC #$0030
    STA $16
    BRA loc_0AAE4B
}

code_0AAE28 {
    LDA $playerWallType
    CLC 
    ADC #$0008
    STA $moveXAlt, X
    BRA loc_0AAE4B
}

code_0AAE35 {
    LDA $14
    CLC 
    ADC #$0010
    STA $moveXAlt, X
    BRA loc_0AAE4B
}

code_0AAE41 {
    LDA $14
    SEC 
    SBC #$0010
    STA $moveXAlt, X

  loc_0AAE4B:
    LDA $24
    STA $orbitAngle, X
    COP [MoveToward] ( #FF, #08 )
    LDA #$0100
    TRB $10
    COP [WaitByte] ( #1D )
    LDA $orbitAngle, X
    TAY 
    LDA $0014, Y
    CLC 
    ADC $7F100C, X
    STA $moveXAlt, X
    LDA $0016, Y
    CLC 
    ADC $7F100E, X
    STA $moveYAlt, X
    COP [MoveToward] ( #FF, #04 )
    COP [SetEntryContinue]
    RTL 
}

code_0AAE81 {
    COP [StageSprAndHitbox] ( #0E )
    BRA loc_0AAE89
}

code_0AAE86 {
    COP [StageSprAndHitbox] ( #0F )

  loc_0AAE89:
    COP [SetEntryContinue]
    JSL $@code_0AA35F
    RTL 
}

code_0AAE90 {
    COP [StageSprAndHitbox] ( #0E )
    COP [SetEntryExit]
    COP [AddPosition] ( #04, #18 )
    COP [SetEntryContinue]
    RTL 
}

code_0AAE9C {
    COP [StageSprAndHitbox] ( #0E )
    COP [WaitByte] ( #0F )
    COP [AddPosition] ( #00, #24 )
    COP [SetEntryContinue]
    RTL 
}

code_0AAEA9 {
    COP [StageSprAndHitbox] ( #0F )
    COP [SetEntryExit]
    COP [AddPosition] ( #06, #04 )
    COP [SetEntryContinue]
    RTL 
}

code_0AAEB5 {
    COP [StageSprAndHitbox] ( #0F )
    COP [SetEntryExit]
    COP [AddPosition] ( #FA, #13 )
    COP [SetEntryContinue]
    RTL 
}

actor_def_0AAEC1 [
  actor-def < #1A, #00, #22, {

  code_0AAEC4:
    LDA #$0011
    TSB $12
    LDA #$0000
    STA $orbitAngle, X

  code_0AAED0:
    COP [WaitWhileOffscreen] ( #08 )
    COP [BranchIfPlayerNear] ( #04, &code_0AAED9 )
    RTL 
} >
]

code_0AAED9 {
    LDA #$2000
    TRB $10
    COP [LoopInit] ( #05 )
    COP [PlaySoundCh1] ( #2C )
    COP [StageSpriteFrame] ( #2D )
    COP [AnimOnce]
    COP [LoopNext]
    LDA #$0200
    TRB $10
    COP [SpawnAfterFlags] ( @code_0AAF4D, #$0200 )
    COP [SpawnAfterFlags] ( @code_0AAF64, #$0200 )
    COP [SpawnAfterFlags] ( @code_0AAF5D, #$0200 )
    COP [SetEntryExit]
    COP [SpawnAfterFlags] ( @code_0AAF78, #$0200 )
    COP [SpawnMarkedAfter] ( @code_0AAF3D, #$0301 )
    COP [StageSpriteFrame] ( #2F )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #30 )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @code_0AD9FA, #00, #CE, #$0202 )
    COP [StageSpriteFrame] ( #30 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #31 )
    COP [AnimOnce]
    LDA #$2200
    TSB $10
    COP [WaitByte] ( #77 )
    JMP $&code_0AAED0
}

code_0AAF3D {
    COP [StageSpriteFrame] ( #2E )
    COP [AnimOnce]
    COP [WaitWord] ( #$00DB )
    COP [StageSpriteFrame] ( #2D )
    COP [AnimOnce]
    COP [Die]
}

code_0AAF4D {
    COP [StageSpriteMoveXY] ( #32, #02, #2A )
    COP [AnimOnce]
    COP [StageSpriteMoveXY] ( #32, #02, #2B )
    COP [AnimOnce]
    COP [Die]
}

code_0AAF5D {
    LDA #$4000
    TSB $12
    BRA code_0AAF4D
}

code_0AAF64 {
    COP [AddPosition] ( #00, #06 )
    COP [StageSpriteMoveXY] ( #32, #12, #2A )
    COP [AnimOnce]
    COP [StageSpriteMoveXY] ( #32, #12, #2B )
    COP [AnimOnce]
    COP [Die]
}

code_0AAF78 {
    LDA #$4000
    TSB $12
    BRA code_0AAF64
}

actor_def_0AAF7F [
  actor-def < #16, #00, #03, {

  code_0AAF82:
    COP [OrActorFlags] ( #$0008 )
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #03, &code_0AAF95 )
    RTL 
} >
]

code_0AAF95 {
    COP [StageSpriteFrame] ( #1B )
    COP [AnimOnce]
    COP [ClearLowHere]
    LDA #$0300
    TRB $10
    JMP $&code_0AAFF1
}

actor_def_0AAFA4 [
  actor-def < #16, #00, #03, {

  code_0AAFA7:
    COP [OrActorFlags] ( #$0008 )
    COP [SetSpritePalette] ( #04 )
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #03, &code_0AAFBD )
    RTL 
} >
]

code_0AAFBD {
    COP [SetSpritePalette] ( #00 )
    COP [StageSpriteFrame] ( #1B )
    COP [AnimOnce]
    COP [ClearLowHere]
    LDA #$0300
    TRB $10
    JMP $&code_0AAFF1
}

actor_def_0AAFCF [
  actor-def < #16, #00, #00, {

  code_0AAFD2:
    COP [OrActorFlags] ( #$0008 )

  loc_0AAFD6:
    COP [WaitWhileOffscreen] ( #0F )
    LDA $10
    BIT #$4000
    BNE loc_0AAFD6

  code_0AAFE0:
    COP [BranchIfPlayerNear] ( #03, &code_0AAFF7 )

  code_0AAFE5:
    COP [BranchIfPlayerNear] ( #05, &code_0AB014 )
    LDA $10
    BIT #$4000
    BNE loc_0AAFD6
} >
]

code_0AAFF1 {
    COP [CallScript] ( &code_0AB01A )
    BRA code_0AAFE0
}

code_0AAFF7 {
    LDA $sceneCurrent
    CMP #$00E9
    BNE loc_0AB004
    COP [SetEntryExitNow] ( @code_0AAFE5 )

  loc_0AB004:
    LDA #$0300
    TSB $10
    COP [CallScript] ( &code_0AB296 )
    LDA #$0300
    TRB $10
    BRA code_0AAFE0
}

code_0AB014 {
    COP [CallScript] ( &code_0AB0EC )
    BRA code_0AAFF1
}

code_0AB01A {
    LDA $28
    SEC 
    SBC #$0016
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0AB02C )
}

code_list_0AB02C [
  &code_0AB03A   ;00
  &code_0AB068   ;01
  &code_0AB096   ;02
  &code_0AB0C4   ;03
  &code_0AC202   ;04
  $#1702   ;05
  &code_0AB068   ;06
]

code_0AB03A {
    COP [StageSpriteFrame] ( #18 )
    COP [AnimOnce]

  loc_0AB03F:
    COP [BranchIfSolidWest] ( &code_0AB062 )
    COP [StageSpriteMoveX] ( #18, #02 )
    COP [AnimOnce]
    COP [BranchNearerAxis] ( &code_0AB04F, &code_0AB096 )
}

code_0AB04F {
    COP [BranchOnPlayerX] ( #$0080, &code_0AB059, &code_0AB059, &code_0AB068 )
}

code_0AB059 {
    COP [SetEntryExit]
    COP [BranchIfPlayerNear] ( #05, &code_0AAFE0 )
    BRA loc_0AB03F
}

code_0AB062 {
    COP [SetEntryExit]
    COP [BranchIfSolidEast] ( &code_0AB096 )
}

code_0AB068 {
    COP [StageSpriteFrame] ( #98 )
    COP [AnimOnce]

  loc_0AB06D:
    COP [BranchIfSolidEast] ( &code_0AB090 )
    COP [StageSpriteMoveX] ( #98, #01 )
    COP [AnimOnce]
    COP [BranchNearerAxis] ( &code_0AB07D, &code_0AB096 )
}

code_0AB07D {
    COP [BranchOnPlayerX] ( #$0080, &code_0AB059, &code_0AB087, &code_0AB087 )
}

code_0AB087 {
    COP [SetEntryExit]
    COP [BranchIfPlayerNear] ( #05, &code_0AAFE0 )
    BRA loc_0AB06D
}

code_0AB090 {
    COP [SetEntryExit]
    COP [BranchIfSolidSouth] ( &code_0AB0C4 )
}

code_0AB096 {
    COP [StageSpriteFrame] ( #16 )
    COP [AnimOnce]

  loc_0AB09B:
    COP [BranchIfSolidSouth] ( &code_0AB0BE )
    COP [StageSpriteMoveY] ( #16, #01 )
    COP [AnimOnce]
    COP [BranchNearerAxis] ( &code_0AB03A, &code_0AB0AB )
}

code_0AB0AB {
    COP [BranchOnPlayerY] ( #$0080, &code_0AB0E3, &code_0AB0B5, &code_0AB0B5 )
}

code_0AB0B5 {
    COP [SetEntryExit]
    COP [BranchIfPlayerNear] ( #05, &code_0AAFE0 )
    BRA loc_0AB09B
}

code_0AB0BE {
    COP [SetEntryExit]
    COP [BranchIfSolidNorth] ( &code_0AB03A )
}

code_0AB0C4 {
    COP [StageSpriteFrame] ( #17 )
    COP [AnimOnce]

  loc_0AB0C9:
    COP [BranchIfSolidNorth] ( &code_0AB034 )
    COP [StageSpriteMoveY] ( #17, #02 )
    COP [AnimOnce]
    COP [BranchNearerAxis] ( &code_0AB03A, &code_0AB0D9 )
}

code_0AB0D9 {
    COP [BranchOnPlayerY] ( #$0080, &code_0AB0E3, &code_0AB0E3, &code_0AB0B5 )
}

code_0AB0E3 {
    COP [SetEntryExit]
    COP [BranchIfPlayerNear] ( #05, &code_0AAFE0 )
    BRA loc_0AB0C9
}

code_0AB0EC {
    COP [BranchOnPlayerX] ( #$0030, &code_0AB0F6, &code_0AB17E, &code_0AB13A )
}

code_0AB0F6 {
    COP [StageSpriteFrame] ( #18 )
    COP [AnimOnce]
    JSR $&code_0ADBF5
    LDA $moveXAlt, X
    CLC 
    ADC #$0060
    STA $moveXAlt, X
    LDA #$0008
    TSB $10
    BRA loc_0AB11A

  code_0AB111:
    JSR $&code_0ADC12
    COP [MoveToward] ( #18, #02 )
    BRA loc_0AB122

  loc_0AB11A:
    COP [MoveToward] ( #18, #02 )
    COP [BranchIfNotOnGridline] ( &code_0AB111 )

  loc_0AB122:
    LDA #$0008
    TRB $10
    COP [StageSpriteFrame] ( #24 )
    COP [AnimOnce]
    COP [SpawnMarkedAfterRel] ( @code_0AB26A, #E8, #EB, #$2200 )
    COP [WaitByte] ( #05 )
    COP [RestoreSavedPtr]
}

code_0AB13A {
    COP [StageSpriteFrame] ( #98 )
    COP [AnimOnce]
    JSR $&code_0ADBF5
    LDA $moveXAlt, X
    SEC 
    SBC #$0050
    STA $moveXAlt, X
    LDA #$0008
    TSB $10
    BRA loc_0AB15E

  code_0AB155:
    JSR $&code_0ADC12
    COP [MoveToward] ( #98, #02 )
    BRA loc_0AB166

  loc_0AB15E:
    COP [MoveToward] ( #98, #02 )
    COP [BranchIfNotOnGridline] ( &code_0AB155 )

  loc_0AB166:
    LDA #$0008
    TRB $10
    COP [StageSpriteFrame] ( #A4 )
    COP [AnimOnce]
    COP [SpawnMarkedAfterRel] ( @code_0AB265, #18, #EB, #$2200 )
    COP [WaitByte] ( #05 )
    COP [RestoreSavedPtr]
}

code_0AB17E {
    COP [BranchOnPlayerY] ( #$0030, &code_0AB188, &code_0AB188, &code_0AB1CC )
}

code_0AB188 {
    COP [StageSpriteFrame] ( #17 )
    COP [AnimOnce]
    JSR $&code_0ADBF5
    LDA $moveYAlt, X
    CLC 
    ADC #$0060
    STA $moveYAlt, X
    LDA #$0008
    TSB $10
    BRA loc_0AB1AC

  code_0AB1A3:
    JSR $&code_0ADC12
    COP [MoveToward] ( #17, #02 )
    BRA loc_0AB1B4

  loc_0AB1AC:
    COP [MoveToward] ( #17, #02 )
    COP [BranchIfNotOnGridline] ( &code_0AB1A3 )

  loc_0AB1B4:
    LDA #$0008
    TRB $10
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]
    COP [SpawnMarkedAfterRel] ( @code_0AB210, #00, #F8, #$2200 )
    COP [WaitByte] ( #05 )
    COP [RestoreSavedPtr]
}

code_0AB1CC {
    COP [StageSpriteFrame] ( #16 )
    COP [AnimOnce]
    JSR $&code_0ADBF5
    LDA $moveYAlt, X
    SEC 
    SBC #$0060
    STA $moveYAlt, X
    LDA #$0008
    TSB $10
    BRA loc_0AB1F0

  code_0AB1E7:
    JSR $&code_0ADC12
    COP [MoveToward] ( #16, #02 )
    BRA loc_0AB1F8

  loc_0AB1F0:
    COP [MoveToward] ( #16, #02 )
    COP [BranchIfNotOnGridline] ( &code_0AB1E7 )

  loc_0AB1F8:
    LDA #$0008
    TRB $10
    COP [StageSpriteFrame] ( #22 )
    COP [AnimOnce]
    COP [SpawnMarkedAfterRel] ( @code_0AB239, #00, #07, #$2202 )
    COP [WaitByte] ( #05 )
    COP [RestoreSavedPtr]
}

code_0AB210 {
    COP [SetSpritePriority] ( #30 )
    LDA #$2000
    TSB $12
    LDA #$2000
    TRB $10
    COP [PlaySoundCh1] ( #20 )
    COP [StageSpriteMoveY] ( #25, #03 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #26, #05 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #27, #07 )
    COP [AnimOnce]
    LDA #$0002
    TSB $10
    BRA loc_0AB250
}

code_0AB239 {
    COP [SetSpritePriority] ( #30 )
    LDA #$2000
    TRB $10
    COP [PlaySoundCh1] ( #20 )
    COP [StageSpriteMoveY] ( #25, #03 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #26, #03 )
    COP [AnimOnce]

  loc_0AB250:
    COP [StageSpriteMoveY] ( #27, #05 )
    COP [AnimOnce]

  loc_0AB256:
    COP [StageSpriteMoveY] ( #28, #07 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_0AB256
    COP [Die]
}

code_0AB265 {
    LDA #$4000
    TSB $12
}

code_0AB26A {
    COP [SetSpritePriority] ( #30 )
    LDA #$2000
    TRB $10
    COP [PlaySoundCh1] ( #20 )
    COP [StageSpriteMoveX] ( #29, #04 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #2A, #04 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #2B, #06 )
    COP [AnimOnce]

  loc_0AB287:
    COP [StageSpriteMoveX] ( #2C, #08 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_0AB287
    COP [Die]
}

code_0AB296 {
    LDA $28
    SEC 
    SBC #$0016
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0AB2A8 )
}

code_list_0AB2A8 [
  &code_0AB2B0   ;00
  &code_0AB2D4   ;01
  &code_0AB2F8   ;02
  &code_0AB2F8   ;03
]

code_0AB2B0 {
    COP [SolidHighHere]
    COP [StageSpriteFrame] ( #19 )
    COP [AnimOnce]
    COP [LoopInit] ( #0C )
    COP [StageSpriteLoop] ( #1A, #08 )
    COP [AnimLoop]
    COP [BranchIfPlayerNear] ( #03, &code_0AB2C7 )
    BRA loc_0AB2CB
}

code_0AB2C7 {
    COP [LoopNext]
    BRA loc_0AB345

  loc_0AB2CB:
    COP [StageSpriteFrame] ( #1B )
    COP [AnimOnce]
    COP [ClearLowHere]
    COP [RestoreSavedPtr]
}

code_0AB2D4 {
    COP [SolidHighHere]
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [LoopInit] ( #0C )
    COP [StageSpriteLoop] ( #1D, #08 )
    COP [AnimLoop]
    COP [BranchIfPlayerNear] ( #03, &code_0AB2EB )
    BRA loc_0AB2EF
}

code_0AB2EB {
    COP [LoopNext]
    BRA loc_0AB345

  loc_0AB2EF:
    COP [StageSpriteFrame] ( #1E )
    COP [AnimOnce]
    COP [ClearLowHere]
    COP [RestoreSavedPtr]
}

code_0AB2F8 {
    COP [SolidHighHere]
    LDA $0E
    BIT #$4000
    BNE loc_0AB323
    COP [StageSpriteFrame] ( #1F )
    COP [AnimOnce]
    COP [LoopInit] ( #0C )
    COP [StageSpriteLoop] ( #20, #08 )
    COP [AnimLoop]
    COP [BranchIfPlayerNear] ( #03, &code_0AB316 )
    BRA loc_0AB31A
}

code_0AB316 {
    COP [LoopNext]
    BRA loc_0AB345

  loc_0AB31A:
    COP [StageSpriteFrame] ( #21 )
    COP [AnimOnce]
    COP [ClearLowHere]
    COP [RestoreSavedPtr]

  loc_0AB323:
    COP [StageSpriteFrame] ( #9F )
    COP [AnimOnce]
    COP [LoopInit] ( #0C )
    COP [StageSpriteLoop] ( #A0, #08 )
    COP [AnimLoop]
    COP [BranchIfPlayerNear] ( #03, &code_0AB338 )
    BRA loc_0AB33C
}

code_0AB338 {
    COP [LoopNext]
    BRA loc_0AB345

  loc_0AB33C:
    COP [StageSpriteFrame] ( #A1 )
    COP [AnimOnce]
    COP [ClearLowHere]
    COP [RestoreSavedPtr]

  loc_0AB345:
    LDA #$0300
    TRB $10
    COP [ClearLowHere]
    COP [RngByte]
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0AB35A )
}

code_list_0AB35A [
  &code_0AB0F6   ;00
  &code_0AB13A   ;01
  &code_0AB188   ;02
  &code_0AB1CC   ;03
]

actor_def_0AB362 [
  actor-def < #00, #00, #28, {

  code_0AB365:
    LDA $00B4
    BEQ loc_0AB37A
    COP [LoopInit] ( #3C )
    LDA $joypadRaw
    BNE loc_0AB37A
    COP [LoopNext]
    LDA #$FFFF
    STA $slopeCurvePtrA

  loc_0AB37A:
    COP [Die]
} >
]

actor_def_0AB37C [
  actor-def < #00, #00, #00, {

  code_0AB37F:
    LDA #$0011
    TSB $12
    COP [SetHitCallback] ( &code_0AB3D5 )
    COP [AddPosition] ( #01, #00 )

  loc_0AB38C:
    COP [WaitWhileOffscreen] ( #0F )

  loc_0AB38F:
    COP [RngByte]
    AND #$0007
    STA $orbitAngle, X
    COP [LoopInit] ( #03 )
    COP [AddPosition] ( #FF, #00 )
    COP [CallScript] ( &code_0ABE92 )
    COP [CallScript] ( &code_0ABEB9 )
    COP [CallScript] ( &code_0ABEE0 )
    COP [CallScript] ( &code_0ABF07 )
    COP [CallScript] ( &code_0ABF2E )
    COP [AddPosition] ( #01, #00 )
    COP [CallScript] ( &code_0ABF55 )
    COP [CallScript] ( &code_0ABF7C )
    COP [CallScript] ( &code_0ABFA3 )
    LDA $10
    BIT #$4000
    BNE loc_0AB38C
    LDA #$FFFF
    STA $orbitAngle, X
    COP [LoopNext]
    BRA loc_0AB38F
} >
]

code_0AB3D5 {
    LDA $14
    AND #$0007
    BEQ loc_0AB3E0
    COP [AddPosition] ( #FF, #00 )

  loc_0AB3E0:
    LDA #$0011
    TRB $12

  code_0AB3E5:
    COP [SetHitCallback] ( &code_0AB5F8 )
    COP [BranchNearerAxis] ( &code_0AB3EF, &code_0AB4F2 )
}

code_0AB3EF {
    COP [SetEntryExit]
    COP [BranchOnPlayerX] ( #$0000, &code_0AB3FB, &code_0AB3FB, &code_0AB476 )
}

code_0AB3FB {
    COP [StageSpriteLoop] ( #02, #0A )
    COP [AnimLoop]
    COP [SetEntryExit]
    COP [CallScript] ( &code_0AB68E )
    COP [SetEntryExit]
    COP [LoopInit] ( #03 )

  loc_0AB40C:
    COP [BranchIfSolidWest] ( &code_0AB41A )
    COP [StageSpriteMoveX] ( #05, #12 )
    COP [AnimOnce]
    COP [LoopNext]
    BRA code_0AB3E5
}

code_0AB41A {
    COP [RngByte]
    AND #$0001
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0AB428 )
}

code_list_0AB428 [
  &code_0AB42C   ;00
  &code_0AB451   ;01
]

code_0AB42C {
    COP [BranchIfSolidWest] ( &code_0AB432 )
    BRA loc_0AB40C
}

code_0AB432 {
    COP [SetEntryExit]
    COP [RngByte]
    AND #$0007
    BNE code_0AB445
    COP [BranchIfSolidEast] ( &code_0AB445 )
    COP [StageSpriteMoveX] ( #85, #11 )
    COP [AnimOnce]
}

code_0AB445 {
    COP [BranchIfSolidSouth] ( &code_0AB451 )
    COP [StageSpriteMoveY] ( #03, #11 )
    COP [AnimOnce]
    BRA code_0AB42C
}

code_0AB451 {
    COP [BranchIfSolidWest] ( &code_0AB457 )
    BRA loc_0AB40C
}

code_0AB457 {
    COP [SetEntryExit]
    COP [RngByte]
    BIT #$0007
    BNE code_0AB46A
    COP [BranchIfSolidEast] ( &code_0AB46A )
    COP [StageSpriteMoveX] ( #85, #11 )
    COP [AnimOnce]
}

code_0AB46A {
    COP [BranchIfSolidNorth] ( &code_0AB42C )
    COP [StageSpriteMoveY] ( #04, #12 )
    COP [AnimOnce]
    BRA code_0AB42C
}

code_0AB476 {
    COP [StageSpriteLoop] ( #82, #0A )
    COP [AnimLoop]
    COP [SetEntryExit]
    COP [CallScript] ( &code_0AB6C5 )
    COP [SetEntryExit]
    COP [LoopInit] ( #03 )

  loc_0AB487:
    COP [BranchIfSolidEast] ( &code_0AB496 )
    COP [StageSpriteMoveX] ( #85, #11 )
    COP [AnimOnce]
    COP [LoopNext]
    JMP $&code_0AB3E5
}

code_0AB496 {
    COP [RngByte]
    AND #$0001
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0AB4A4 )
}

code_list_0AB4A4 [
  &code_0AB4A8   ;00
  &code_0AB4CD   ;01
]

code_0AB4A8 {
    COP [BranchIfSolidEast] ( &code_0AB4AE )
    BRA loc_0AB487
}

code_0AB4AE {
    COP [SetEntryExit]
    COP [RngByte]
    AND #$0007
    BNE code_0AB4C1
    COP [BranchIfSolidWest] ( &code_0AB4C1 )
    COP [StageSpriteMoveX] ( #05, #12 )
    COP [AnimOnce]
}

code_0AB4C1 {
    COP [BranchIfSolidSouth] ( &code_0AB4CD )
    COP [StageSpriteMoveY] ( #03, #11 )
    COP [AnimOnce]
    BRA code_0AB4A8
}

code_0AB4CD {
    COP [BranchIfSolidEast] ( &code_0AB4D3 )
    BRA loc_0AB487
}

code_0AB4D3 {
    COP [SetEntryExit]
    COP [RngByte]
    BIT #$0007
    BNE code_0AB4E6
    COP [BranchIfSolidWest] ( &code_0AB4E6 )
    COP [StageSpriteMoveX] ( #05, #12 )
    COP [AnimOnce]
}

code_0AB4E6 {
    COP [BranchIfSolidNorth] ( &code_0AB4A8 )
    COP [StageSpriteMoveY] ( #04, #12 )
    COP [AnimOnce]
    BRA code_0AB4A8
}

code_0AB4F2 {
    COP [SetEntryExit]
    COP [BranchOnPlayerY] ( #$0000, &code_0AB4FE, &code_0AB4FE, &code_0AB57A )
}

code_0AB4FE {
    COP [StageSpriteLoop] ( #01, #0A )
    COP [AnimLoop]
    COP [SetEntryExit]
    COP [CallScript] ( &code_0AB657 )
    COP [SetEntryExit]
    COP [LoopInit] ( #03 )

  code_0AB50F:
    COP [BranchIfSolidNorth] ( &code_0AB51E )
    COP [StageSpriteMoveY] ( #04, #12 )
    COP [AnimOnce]
    COP [LoopNext]
    JMP $&code_0AB3E5
}

code_0AB51E {
    COP [RngByte]
    AND #$0001
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0AB52C )
}

code_list_0AB52C [
  &code_0AB530   ;00
  &code_0AB555   ;01
]

code_0AB530 {
    COP [BranchIfSolidNorth] ( &code_0AB536 )
    BRA code_0AB50F
}

code_0AB536 {
    COP [SetEntryExit]
    COP [RngByte]
    AND #$0007
    BNE loc_0AB549
    COP [BranchIfSolidSouth] ( &code_0AB4C1 )
    COP [StageSpriteMoveY] ( #03, #11 )
    COP [AnimOnce]

  loc_0AB549:
    COP [BranchIfSolidWest] ( &code_0AB555 )
    COP [StageSpriteMoveX] ( #05, #12 )
    COP [AnimOnce]
    BRA code_0AB530
}

code_0AB555 {
    COP [BranchIfSolidNorth] ( &code_0AB55B )
    BRA code_0AB50F
}

code_0AB55B {
    COP [SetEntryExit]
    COP [RngByte]
    BIT #$0007
    BNE code_0AB56E
    COP [BranchIfSolidSouth] ( &code_0AB56E )
    COP [StageSpriteMoveY] ( #03, #11 )
    COP [AnimOnce]
}

code_0AB56E {
    COP [BranchIfSolidEast] ( &code_0AB530 )
    COP [StageSpriteMoveX] ( #85, #11 )
    COP [AnimOnce]
    BRA code_0AB555
}

code_0AB57A {
    COP [StageSpriteLoop] ( #00, #0A )
    COP [AnimLoop]
    COP [SetEntryExit]
    COP [CallScript] ( &code_0AB620 )
    COP [SetEntryExit]
    COP [LoopInit] ( #03 )
    COP [BranchIfSolidSouth] ( &code_0AB59A )
    COP [StageSpriteMoveY] ( #03, #11 )
    COP [AnimOnce]
    COP [LoopNext]
    JMP $&code_0AB3E5
}

code_0AB59A {
    COP [RngByte]
    AND #$0001
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0AB5A8 )
}

code_list_0AB5A8 [
  &code_0AB5AC   ;00
  &code_0AB5D2   ;01
]

code_0AB5AC {
    COP [BranchIfSolidSouth] ( &code_0AB5B3 )
    JMP $&code_0AB50F
}

code_0AB5B3 {
    COP [SetEntryExit]
    COP [RngByte]
    AND #$0007
    BNE loc_0AB5C6
    COP [BranchIfSolidNorth] ( &code_0AB4C1 )
    COP [StageSpriteMoveY] ( #04, #12 )
    COP [AnimOnce]

  loc_0AB5C6:
    COP [BranchIfSolidWest] ( &code_0AB5D2 )
    COP [StageSpriteMoveX] ( #05, #12 )
    COP [AnimOnce]
    BRA code_0AB5AC
}

code_0AB5D2 {
    COP [BranchIfSolidSouth] ( &code_0AB5D9 )
    JMP $&code_0AB50F
}

code_0AB5D9 {
    COP [SetEntryExit]
    COP [RngByte]
    BIT #$0007
    BNE loc_0AB5EC
    COP [BranchIfSolidNorth] ( &code_0AB56E )
    COP [StageSpriteMoveY] ( #04, #12 )
    COP [AnimOnce]

  loc_0AB5EC:
    COP [BranchIfSolidEast] ( &code_0AB5AC )
    COP [StageSpriteMoveX] ( #85, #11 )
    COP [AnimOnce]
    BRA code_0AB5D2
}

code_0AB5F8 {
    COP [SnapToGrid]
    COP [SetSavedPtr] ( &code_0AB3E5 )
    COP [SetEntryContinue]
    COP [AnimOnce]
    COP [DirToPlayer]
    AND #$0007
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0AB610 )
}

code_list_0AB610 [
  &code_0AB661   ;00
  &code_0AB661   ;01
  &code_0AB6CF   ;02
  &code_0AB6CF   ;03
  &code_0AB62A   ;04
  &code_0AB62A   ;05
  &code_0AB698   ;06
  &code_0AB698   ;07
]

code_0AB620 {
    COP [BranchIfPlayerInRelTiles] ( #FE, #00, #02, #04, &code_0AB62A )
    COP [RestoreSavedPtr]
}

code_0AB62A {
    COP [SetHitCallback] ( #$0000 )
    COP [SetEntryExit]
    COP [StageSprAndHitbox] ( #06 )
    COP [SetEntryContinue]
    COP [ContinueIfFrame] ( #05 )
    COP [PlaySoundCh1] ( #1F )
    COP [SpawnAfterRelFlags] ( @code_0AB6FC, #$FFF4, #$FFF0, #$0202 )
    COP [SpawnAfterRelFlags] ( @code_0AB6FC, #$000C, #$FFF0, #$0202 )
    COP [SetEntryContinue]
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0AB657 {
    COP [BranchIfPlayerInRelTiles] ( #FE, #FA, #02, #00, &code_0AB661 )
    COP [RestoreSavedPtr]
}

code_0AB661 {
    COP [SetHitCallback] ( #$0000 )
    COP [SetEntryExit]
    COP [StageSprAndHitbox] ( #07 )
    COP [SetEntryContinue]
    COP [ContinueIfFrame] ( #05 )
    COP [PlaySoundCh1] ( #1F )
    COP [SpawnAfterRelFlags] ( @code_0AB71B, #$FFF4, #$FFD0, #$0202 )
    COP [SpawnAfterRelFlags] ( @code_0AB71B, #$000C, #$FFD0, #$0202 )
    COP [SetEntryContinue]
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0AB68E {
    COP [BranchIfPlayerInRelTiles] ( #FC, #FE, #00, #02, &code_0AB698 )
    COP [RestoreSavedPtr]
}

code_0AB698 {
    COP [SetHitCallback] ( #$0000 )
    COP [SetEntryExit]
    COP [StageSprAndHitbox] ( #08 )
    COP [SetEntryContinue]
    COP [ContinueIfFrame] ( #05 )
    COP [PlaySoundCh1] ( #1F )
    COP [SpawnAfterRelFlags] ( @code_0AB73A, #$FFF3, #$FFE0, #$0202 )
    COP [SpawnAfterRelFlags] ( @code_0AB73A, #$FFF3, #$FFE8, #$0202 )
    COP [SetEntryContinue]
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0AB6C5 {
    COP [BranchIfPlayerInRelTiles] ( #00, #FE, #04, #02, &code_0AB6CF )
    COP [RestoreSavedPtr]
}

code_0AB6CF {
    COP [SetHitCallback] ( #$0000 )
    COP [SetEntryExit]
    COP [StageSprAndHitbox] ( #88 )
    COP [SetEntryContinue]
    COP [ContinueIfFrame] ( #05 )
    COP [PlaySoundCh1] ( #1F )
    COP [SpawnAfterRelFlags] ( @code_0AB75B, #$000D, #$FFE0, #$0202 )
    COP [SpawnAfterRelFlags] ( @code_0AB75B, #$000D, #$FFE8, #$0202 )
    COP [SetEntryContinue]
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0AB6FC {
    COP [OrActorFlags] ( #$0010 )
    COP [StageSpriteMoveY] ( #09, #01 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #09, #03 )
    COP [AnimOnce]

  loc_0AB70C:
    COP [StageSpriteMoveY] ( #09, #05 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_0AB70C
    COP [Die]
}

code_0AB71B {
    COP [OrActorFlags] ( #$0010 )
    COP [StageSpriteMoveY] ( #0A, #02 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #0A, #04 )
    COP [AnimOnce]

  loc_0AB72B:
    COP [StageSpriteMoveY] ( #0A, #06 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_0AB72B
    COP [Die]
}

code_0AB73A {
    COP [OrActorFlags] ( #$0010 )
    COP [StageSpriteMoveXY] ( #0B, #02, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveXY] ( #0B, #04, #13 )
    COP [AnimOnce]

  loc_0AB74C:
    COP [StageSpriteMoveX] ( #0B, #06 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_0AB74C
    COP [Die]
}

code_0AB75B {
    COP [OrActorFlags] ( #$0010 )
    COP [StageSpriteMoveXY] ( #8B, #01, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveXY] ( #8B, #03, #13 )
    COP [AnimOnce]

  loc_0AB76D:
    COP [StageSpriteMoveX] ( #8B, #05 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_0AB76D
    COP [Die]
}

actor_def_0AB77C [
  actor-def < #00, #00, #00, {

  code_0AB77F:
    LDA #$0011
    TSB $12
    COP [SetHitCallback] ( &code_0AB878 )
    COP [SetDeathCallback] ( @code_0AB839 )

  code_0AB78D:
    COP [WaitWhileOffscreen] ( #0F )
    LDA #$FFFF
    STA $orbitAngle, X
    COP [CallScript] ( &code_0ABE92 )
    COP [CallScript] ( &code_0ABEB9 )
    COP [CallScript] ( &code_0ABEE0 )
    COP [CallScript] ( &code_0ABF07 )
    COP [CallScript] ( &code_0ABF2E )
    COP [AddPosition] ( #01, #00 )
    COP [CallScript] ( &code_0ABF55 )
    COP [CallScript] ( &code_0ABF7C )
    COP [CallScript] ( &code_0ABFA3 )
    COP [AddPosition] ( #FF, #00 )
    LDA $10
    BIT #$4000
    BNE code_0AB78D
    COP [StageSpriteLoop] ( #0C, #02 )
    COP [AnimLoop]
    JSR $&code_0ADBAD
    COP [CallScript] ( &code_0ABE92 )
    COP [StageSpriteLoop] ( #0D, #02 )
    COP [AnimLoop]
    JSR $&code_0ADBAD
    COP [CallScript] ( &code_0ABEB9 )
    COP [StageSpriteLoop] ( #0E, #02 )
    COP [AnimLoop]
    JSR $&code_0ADBAD
    COP [CallScript] ( &code_0ABEE0 )
    COP [StageSpriteLoop] ( #0F, #02 )
    COP [AnimLoop]
    JSR $&code_0ADBAD
    COP [CallScript] ( &code_0ABF07 )
    COP [StageSpriteLoop] ( #10, #02 )
    COP [AnimLoop]
    JSR $&code_0ADBAD
    COP [CallScript] ( &code_0ABF2E )
    COP [AddPosition] ( #01, #00 )
    COP [StageSpriteLoop] ( #8F, #02 )
    COP [AnimLoop]
    JSR $&code_0ADBAD
    COP [CallScript] ( &code_0ABF55 )
    COP [StageSpriteLoop] ( #8E, #02 )
    COP [AnimLoop]
    JSR $&code_0ADBAD
    COP [CallScript] ( &code_0ABF7C )
    COP [StageSpriteLoop] ( #8D, #02 )
    COP [AnimLoop]
    JSR $&code_0ADBAD
    COP [CallScript] ( &code_0ABFA3 )
    COP [AddPosition] ( #FF, #00 )
    JMP $&code_0AB78D
} >
]

code_0AB839 {
    LDA $orbitAngle, X
    BNE loc_0AB842
    JMP $&code_0AB871

  loc_0AB842:
    PHX 
    STX $0000
    TXA 
    TYX 
    TAY 
    LDX $0006, Y
    LDA $0000
    CMP $orbitDiameter, X
    BNE loc_0AB870
    LDA #$0000
    STA $orbitDiameter, X
    TXY 
    LDX $0006, Y
    LDA $0000
    CMP $orbitDiameter, X
    BNE loc_0AB870
    LDA #$0000
    STA $orbitDiameter, X

  loc_0AB870:
    PLX 
}

code_0AB871 {
    COP [SetEntryExit]
    COP [JumpScript] ( @chunk_008000.code_00DCA9 )
}

code_0AB878 {
    COP [SnapToGrid]
    LDA $14
    AND #$0007
    BEQ loc_0AB885
    COP [AddPosition] ( #FF, #00 )

  loc_0AB885:
    LDA #$0011
    TRB $12

  code_0AB88A:
    COP [SetHitCallback] ( &code_0AB97D )
    COP [BranchIfPlayerNear] ( #04, &code_0AB91B )
    COP [RngByte]
    AND #$0003
    BNE loc_0AB8B4
    COP [BranchNearerAxis] ( &code_0AB8A0, &code_0AB8AA )
}

code_0AB8A0 {
    COP [BranchOnPlayerX] ( #$0000, &code_0AB8CA, &code_0AB8CA, &code_0AB8DF )
}

code_0AB8AA {
    COP [BranchOnPlayerY] ( #$0000, &code_0AB907, &code_0AB907, &code_0AB8F3 )

  loc_0AB8B4:
    COP [RngByte]
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0AB8C2 )
}

code_list_0AB8C2 [
  &code_0AB8CD   ;00
  &code_0AB8E1   ;01
  &code_0AB8F5   ;02
  &code_0AB909   ;03
]

code_0AB8CA {
    COP [WaitByte] ( #00 )
}

code_0AB8CD {
    COP [LoopInit] ( #02 )
    COP [BranchIfSolidWest] ( &code_0AB8DF )
    COP [StageSpriteMoveX] ( #05, #12 )
    COP [AnimOnce]
    COP [LoopNext]
    JMP $&code_0AB88A
}

code_0AB8DF {
    COP [SetEntryExit]
}

code_0AB8E1 {
    COP [LoopInit] ( #02 )
    COP [BranchIfSolidEast] ( &code_0AB8F3 )
    COP [StageSpriteMoveX] ( #85, #11 )
    COP [AnimOnce]
    COP [LoopNext]
    JMP $&code_0AB88A
}

code_0AB8F3 {
    COP [SetEntryExit]
}

code_0AB8F5 {
    COP [LoopInit] ( #02 )
    COP [BranchIfSolidSouth] ( &code_0AB907 )
    COP [StageSpriteMoveY] ( #03, #11 )
    COP [AnimOnce]
    COP [LoopNext]
    JMP $&code_0AB88A
}

code_0AB907 {
    COP [SetEntryExit]
}

code_0AB909 {
    COP [LoopInit] ( #02 )
    COP [BranchIfSolidNorth] ( &code_0AB8CA )
    COP [StageSpriteMoveY] ( #04, #12 )
    COP [AnimOnce]
    COP [LoopNext]
    JMP $&code_0AB88A
}

code_0AB91B {
    COP [BranchNearerAxis] ( &code_0AB951, &code_0AB923 )

  code_0AB921:
    COP [SetEntryExit]
}

code_0AB923 {
    COP [BranchOnPlayerX] ( #$0000, &code_0AB93E, &code_0AB93E, &code_0AB92D )
}

code_0AB92D {
    COP [BranchIfSolidWest] ( &code_0AB94F )
    COP [StageSpriteMoveX] ( #85, #12 )
    COP [AnimOnce]
    COP [CallScript] ( &code_0ABB7A )
    JMP $&code_0AB88A
}

code_0AB93E {
    COP [BranchIfSolidEast] ( &code_0AB94F )
    COP [StageSpriteMoveX] ( #05, #11 )
    COP [AnimOnce]
    COP [CallScript] ( &code_0ABADF )
    JMP $&code_0AB88A
}

code_0AB94F {
    COP [SetEntryExit]
}

code_0AB951 {
    COP [BranchOnPlayerY] ( #$0000, &code_0AB96C, &code_0AB96C, &code_0AB95B )
}

code_0AB95B {
    COP [BranchIfSolidNorth] ( &code_0AB921 )
    COP [StageSpriteMoveY] ( #03, #12 )
    COP [AnimOnce]
    COP [CallScript] ( &code_0AB9A7 )
    JMP $&code_0AB88A
}

code_0AB96C {
    COP [BranchIfSolidSouth] ( &code_0AB921 )
    COP [StageSpriteMoveY] ( #04, #11 )
    COP [AnimOnce]
    COP [CallScript] ( &code_0ABA44 )
    JMP $&code_0AB88A
}

code_0AB97D {
    COP [SnapToGrid]
    COP [SetSavedPtr] ( &code_0AB88A )
    COP [SetEntryContinue]
    COP [AnimOnce]
    COP [DirToPlayer]
    AND #$0007
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0AB995 )
}

code_list_0AB995 [
  &code_0ABA78   ;00
  &code_0ABA78   ;01
  &code_0ABBAE   ;02
  &code_0ABBAE   ;03
  &code_0AB9DB   ;04
  &code_0AB9DB   ;05
  &code_0ABB13   ;06
  &code_0ABB13   ;07
  &code_0AC502   ;08
]

code_0AB9A7 {
    COP [BranchIfPlayerInRelTiles] ( #FD, #00, #03, #06, &code_0AB9DB )
    COP [BranchOnPlayerX] ( #$0000, &code_0AB9B9, &code_0AB9B9, &code_0AB9CB )
}

code_0AB9B9 {
    COP [BranchIfSolidWest] ( &code_0AB9A5 )
    COP [BranchIfSolidOffset] ( #FE, #00, &code_0AB9A5 )
    COP [StageSpriteMoveX] ( #03, #02 )
    COP [AnimOnce]
    BRA code_0AB9DB
}

code_0AB9CB {
    COP [BranchIfSolidEast] ( &code_0AB9A5 )
    COP [BranchIfSolidOffset] ( #02, #00, &code_0AB9A5 )
    COP [StageSpriteMoveX] ( #03, #01 )
    COP [AnimOnce]
}

code_0AB9DB {
    COP [SetHitCallback] ( #$0000 )
    COP [StageSprAndHitbox] ( #11 )
    COP [SetEntryContinue]
    COP [ContinueIfFrame] ( #05 )
    COP [SetEntryContinue]
    COP [PlaySoundCh1] ( #1F )
    COP [SpawnAfterRelFlags] ( @code_0ABC15, #$FFF4, #$FFF0, #$2200 )
    PHX 
    TYX 
    LDA #$FFF4
    STA $7F100C, X
    LDA #$FFEC
    STA $7F100E, X
    PLA 
    STA $orbitDiameter, X
    TAX 
    COP [SpawnAfterRelFlags] ( @code_0ABC15, #$000C, #$FFF0, #$2200 )
    PHX 
    TYX 
    LDA #$000C
    STA $7F100C, X
    LDA #$FFEC
    STA $7F100E, X
    PLA 
    STA $orbitDiameter, X
    TAX 
    LDA #$0003
    STA $orbitAngle, X
    COP [SetEntryContinue]
    LDA $orbitAngle, X
    BEQ loc_0ABA3E
    RTL 

  loc_0ABA3E:
    COP [SetEntryContinue]
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0ABA44 {
    COP [BranchIfPlayerInRelTiles] ( #FD, #FB, #03, #00, &code_0ABA78 )
    COP [BranchOnPlayerX] ( #$0000, &code_0ABA56, &code_0ABA56, &code_0ABA68 )
}

code_0ABA56 {
    COP [BranchIfSolidWest] ( &code_0AB9A5 )
    COP [BranchIfSolidOffset] ( #FE, #00, &code_0AB9A5 )
    COP [StageSpriteMoveX] ( #04, #02 )
    COP [AnimOnce]
    BRA code_0ABA78
}

code_0ABA68 {
    COP [BranchIfSolidEast] ( &code_0AB9A5 )
    COP [BranchIfSolidOffset] ( #02, #00, &code_0AB9A5 )
    COP [StageSpriteMoveX] ( #04, #01 )
    COP [AnimOnce]
}

code_0ABA78 {
    COP [SetHitCallback] ( #$0000 )
    COP [StageSprAndHitbox] ( #12 )
    COP [SetEntryContinue]
    COP [ContinueIfFrame] ( #05 )
    COP [PlaySoundCh1] ( #1F )
    COP [SpawnAfterRelFlags] ( @code_0ABC88, #$FFF4, #$FFD0, #$2200 )
    PHX 
    TYX 
    LDA #$FFF4
    STA $7F100C, X
    LDA #$FFDC
    STA $7F100E, X
    PLA 
    STA $orbitDiameter, X
    TAX 
    COP [SpawnAfterRelFlags] ( @code_0ABC88, #$000C, #$FFD0, #$2200 )
    PHX 
    TYX 
    LDA #$000C
    STA $7F100C, X
    LDA #$FFDC
    STA $7F100E, X
    PLA 
    STA $orbitDiameter, X
    TAX 
    LDA #$0003
    STA $orbitAngle, X
    COP [SetEntryContinue]
    LDA $orbitAngle, X
    BEQ loc_0ABAD9
    RTL 

  loc_0ABAD9:
    COP [SetEntryContinue]
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0ABADF {
    COP [BranchIfPlayerInRelTiles] ( #FB, #FE, #00, #02, &code_0ABB13 )
    COP [BranchOnPlayerY] ( #$0000, &code_0ABAF1, &code_0ABAF1, &code_0ABB03 )
}

code_0ABAF1 {
    COP [BranchIfSolidNorth] ( &code_0AB9A5 )
    COP [BranchIfSolidOffset] ( #00, #FE, &code_0AB9A5 )
    COP [StageSpriteMoveY] ( #05, #02 )
    COP [AnimOnce]
    BRA code_0ABB13
}

code_0ABB03 {
    COP [BranchIfSolidSouth] ( &code_0AB9A5 )
    COP [BranchIfSolidOffset] ( #00, #02, &code_0AB9A5 )
    COP [StageSpriteMoveY] ( #05, #01 )
    COP [AnimOnce]
}

code_0ABB13 {
    COP [SetHitCallback] ( #$0000 )
    COP [StageSprAndHitbox] ( #13 )
    COP [SetEntryContinue]
    COP [ContinueIfFrame] ( #05 )
    COP [PlaySoundCh1] ( #1F )
    COP [SpawnAfterRelFlags] ( @code_0ABCFB, #$FFF3, #$FFE0, #$2200 )
    PHX 
    TYX 
    LDA #$FFF3
    STA $7F100C, X
    LDA #$FFE0
    STA $7F100E, X
    PLA 
    STA $orbitDiameter, X
    TAX 
    COP [SpawnAfterRelFlags] ( @code_0ABCFB, #$FFF3, #$FFE8, #$2200 )
    PHX 
    TYX 
    LDA #$FFF3
    STA $7F100C, X
    LDA #$FFE8
    STA $7F100E, X
    PLA 
    STA $orbitDiameter, X
    TAX 
    LDA #$0003
    STA $orbitAngle, X
    COP [SetEntryContinue]
    LDA $orbitAngle, X
    BEQ loc_0ABB74
    RTL 

  loc_0ABB74:
    COP [SetEntryContinue]
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0ABB7A {
    COP [BranchIfPlayerInRelTiles] ( #00, #FE, #05, #02, &code_0ABBAE )
    COP [BranchOnPlayerY] ( #$0000, &code_0ABB8C, &code_0ABB8C, &code_0ABB9E )
}

code_0ABB8C {
    COP [BranchIfSolidNorth] ( &code_0AB9A5 )
    COP [BranchIfSolidOffset] ( #00, #FE, &code_0AB9A5 )
    COP [StageSpriteMoveY] ( #85, #02 )
    COP [AnimOnce]
    BRA code_0ABBAE
}

code_0ABB9E {
    COP [BranchIfSolidSouth] ( &code_0AB9A5 )
    COP [BranchIfSolidOffset] ( #00, #02, &code_0AB9A5 )
    COP [StageSpriteMoveY] ( #85, #01 )
    COP [AnimOnce]
}

code_0ABBAE {
    COP [SetHitCallback] ( #$0000 )
    COP [StageSprAndHitbox] ( #93 )
    COP [SetEntryContinue]
    COP [ContinueIfFrame] ( #05 )
    COP [PlaySoundCh1] ( #1F )
    COP [SpawnAfterRelFlags] ( @code_0ABD74, #$000D, #$FFE0, #$2200 )
    PHX 
    TYX 
    LDA #$000D
    STA $7F100C, X
    LDA #$FFE0
    STA $7F100E, X
    PLA 
    STA $orbitDiameter, X
    TAX 
    COP [SpawnAfterRelFlags] ( @code_0ABD74, #$000D, #$FFE8, #$2200 )
    PHX 
    TYX 
    LDA #$000D
    STA $7F100C, X
    LDA #$FFE8
    STA $7F100E, X
    PLA 
    STA $orbitDiameter, X
    TAX 
    LDA #$0003
    STA $orbitAngle, X
    COP [SetEntryContinue]
    LDA $orbitAngle, X
    BEQ loc_0ABC0F
    RTL 

  loc_0ABC0F:
    COP [SetEntryContinue]
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0ABC15 {
    COP [SetSpritePriority] ( #30 )
    COP [OrActorFlags] ( #$0010 )
    COP [SetCollideCallback] ( &code_0ABC5C )
    COP [SetExtraCallback] ( &code_0ABC5C )
    LDA #$2000
    TRB $10
    COP [StageSpriteMoveY] ( #09, #01 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #09, #03 )
    COP [AnimOnce]
    LDY $decelStepCounter
    LDA $14
    SEC 
    SBC $0014, Y
    JSR $&code_0ABE3F
    CLC 
    ADC $14
    STA $moveXAlt, X
    LDA $16
    CLC 
    ADC #$0050
    STA $moveYAlt, X
    COP [MoveToward] ( #09, #03 )
    COP [StageSpriteMoveY] ( #09, #01 )
    COP [AnimOnce]
}

code_0ABC5C {
    COP [AndActorFlags] ( #$FFED )
    COP [SetCollideCallback] ( #$0000 )

  loc_0ABC64:
    LDA $orbitDiameter, X
    BEQ loc_0ABC78
    JSR $&code_0ABE5B
    BCS loc_0ABC72
    JMP $&code_0ABDEA

  loc_0ABC72:
    COP [MoveToward] ( #14, #02 )
    BRA loc_0ABC64

  loc_0ABC78:
    COP [StageSpriteLoopMoveY] ( #09, #03, #03 )
    COP [AnimLoop]
    LDA $10
    BIT #$4000
    BEQ loc_0ABC78
    COP [Die]
}

code_0ABC88 {
    COP [SetSpritePriority] ( #30 )
    COP [OrActorFlags] ( #$0010 )
    COP [SetCollideCallback] ( &code_0ABCCF )
    COP [SetExtraCallback] ( &code_0ABCCF )
    LDA #$2000
    TRB $10
    COP [StageSpriteMoveY] ( #0A, #02 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #0A, #04 )
    COP [AnimOnce]
    LDY $decelStepCounter
    LDA $14
    SEC 
    SBC $0014, Y
    JSR $&code_0ABE3F
    CLC 
    ADC $14
    STA $moveXAlt, X
    LDA $16
    SEC 
    SBC #$0050
    STA $moveYAlt, X
    COP [MoveToward] ( #0A, #03 )
    COP [StageSpriteMoveY] ( #0A, #01 )
    COP [AnimOnce]
}

code_0ABCCF {
    COP [AndActorFlags] ( #$FFED )
    COP [SetCollideCallback] ( #$0000 )

  loc_0ABCD7:
    LDA $orbitDiameter, X
    BEQ loc_0ABCEB
    JSR $&code_0ABE5B
    BCS loc_0ABCE5
    JMP $&code_0ABDEA

  loc_0ABCE5:
    COP [MoveToward] ( #15, #02 )
    BRA loc_0ABCD7

  loc_0ABCEB:
    COP [StageSpriteLoopMoveY] ( #0A, #03, #04 )
    COP [AnimLoop]
    LDA $10
    BIT #$4000
    BEQ loc_0ABCEB
    COP [Die]
}

code_0ABCFB {
    COP [SetSpritePriority] ( #30 )
    COP [OrActorFlags] ( #$0010 )
    COP [SetCollideCallback] ( &code_0ABD48 )
    COP [SetExtraCallback] ( &code_0ABD48 )
    LDA #$2000
    TRB $10
    COP [StageSpriteMoveXY] ( #0B, #02, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveXY] ( #0B, #04, #13 )
    COP [AnimOnce]
    LDY $decelStepCounter
    LDA $16
    SEC 
    SBC $0030
    SEC 
    SBC $0016, Y
    JSR $&code_0ABE3F
    CLC 
    ADC $16
    STA $moveYAlt, X
    LDA $14
    SEC 
    SBC #$0050
    STA $moveXAlt, X
    COP [MoveToward] ( #0B, #03 )
    COP [StageSpriteMoveX] ( #0B, #01 )
    COP [AnimOnce]
}

code_0ABD48 {
    COP [AndActorFlags] ( #$FFED )
    COP [SetCollideCallback] ( #$0000 )

  loc_0ABD50:
    LDA $orbitDiameter, X
    BEQ loc_0ABD64
    JSR $&code_0ABE5B
    BCS loc_0ABD5E
    JMP $&code_0ABDEA

  loc_0ABD5E:
    COP [MoveToward] ( #16, #02 )
    BRA loc_0ABD50

  loc_0ABD64:
    COP [StageSpriteLoopMoveX] ( #0B, #03, #04 )
    COP [AnimLoop]
    LDA $10
    BIT #$4000
    BEQ loc_0ABD64
    COP [Die]
}

code_0ABD74 {
    COP [SetSpritePriority] ( #30 )
    COP [OrActorFlags] ( #$0010 )
    COP [SetCollideCallback] ( &code_0ABDC1 )
    COP [SetExtraCallback] ( &code_0ABDC1 )
    LDA #$2000
    TRB $10
    COP [StageSpriteMoveXY] ( #8B, #01, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveXY] ( #8B, #03, #13 )
    COP [AnimOnce]
    LDY $decelStepCounter
    LDA $16
    SEC 
    SBC $0030
    SEC 
    SBC $0016, Y
    JSR $&code_0ABE3F
    CLC 
    ADC $16
    STA $moveYAlt, X
    LDA $14
    CLC 
    ADC #$0050
    STA $moveXAlt, X
    COP [MoveToward] ( #8B, #03 )
    COP [StageSpriteMoveX] ( #8B, #01 )
    COP [AnimOnce]
}

code_0ABDC1 {
    COP [AndActorFlags] ( #$FFED )
    COP [SetCollideCallback] ( #$0000 )

  loc_0ABDC9:
    LDA $orbitDiameter, X
    BEQ loc_0ABDDA
    JSR $&code_0ABE5B
    BCC code_0ABDEA
    COP [MoveToward] ( #96, #02 )
    BRA loc_0ABDC9

  loc_0ABDDA:
    COP [StageSpriteLoopMoveX] ( #8B, #03, #03 )
    COP [AnimLoop]
    LDA $10
    BIT #$4000
    BEQ loc_0ABDDA
    COP [Die]
}

code_0ABDEA {
    LDA $orbitDiameter, X
    BEQ loc_0ABE3C
    PHX 
    TAX 
    LDA $orbitAngle, X
    LSR 
    STA $orbitAngle, X
    TXY 
    PLX 
    LDA $0014, Y
    SEC 
    SBC $14
    STA $7F100C, X
    LDA $0016, Y
    SEC 
    SBC $16
    STA $7F100E, X

  loc_0ABE11:
    LDA $0014, Y
    SEC 
    SBC $7F100C, X
    STA $14
    LDA $0016, Y
    SEC 
    SBC $7F100E, X
    STA $16
    COP [SetEntryExit]
    PHX 
    LDA $orbitDiameter, X
    BEQ loc_0ABE3C
    TAX 
    LDA $orbitAngle, X
    TXY 
    PLX 
    CMP #$0000
    BNE loc_0ABE11
    COP [Die]

  loc_0ABE3C:
    PLX 
    COP [Die]
}

code_0ABE3F {
    BMI loc_0ABE4E
    CMP #$0010
    BCC loc_0ABE49
    LDA #$0008

  loc_0ABE49:
    EOR #$FFFF
    INC 
    RTS 

  loc_0ABE4E:
    EOR #$FFFF
    INC 
    CMP #$0010
    BCC loc_0ABE5A
    LDA #$0008

  loc_0ABE5A:
    RTS 
}

code_0ABE5B {
    LDA $orbitDiameter, X
    TAY 
    LDA $0014, Y
    CLC 
    ADC $7F100C, X
    STA $moveXAlt, X
    CMP $14
    BNE loc_0ABE84
    LDA $0016, Y
    CLC 
    ADC $7F100E, X
    STA $moveYAlt, X
    CMP $16
    SEC 
    BEQ loc_0ABE82
    RTS 

  loc_0ABE82:
    CLC 
    RTS 

  loc_0ABE84:
    LDA $0016, Y
    CLC 
    ADC $7F100E, X
    STA $moveYAlt, X
    SEC 
    RTS 
}

code_0ABE92 {
    COP [StageSpriteFrame] ( #0C )
    COP [AnimOnce]
    LDA $orbitAngle, X
    CMP #$0004
    BNE loc_0ABEB7
    COP [StageSpriteLoop] ( #0C, #08 )
    COP [AnimLoop]
    COP [SpawnAfterRelFlags] ( @code_0AD8E1, #$0000, #$FFD9, #$2202 )
    COP [StageSpriteLoop] ( #0C, #02 )
    COP [AnimLoop]

  loc_0ABEB7:
    COP [RestoreSavedPtr]
}

code_0ABEB9 {
    COP [StageSpriteFrame] ( #0D )
    COP [AnimOnce]
    LDA $orbitAngle, X
    CMP #$0005
    BNE loc_0ABEDE
    COP [StageSpriteLoop] ( #0D, #08 )
    COP [AnimLoop]
    COP [SpawnAfterRelFlags] ( @code_0AD8F8, #$FFFA, #$FFD9, #$2202 )
    COP [StageSpriteLoop] ( #0D, #02 )
    COP [AnimLoop]

  loc_0ABEDE:
    COP [RestoreSavedPtr]
}

code_0ABEE0 {
    COP [StageSpriteFrame] ( #0E )
    COP [AnimOnce]
    LDA $orbitAngle, X
    CMP #$0006
    BNE loc_0ABF05
    COP [StageSpriteLoop] ( #0E, #08 )
    COP [AnimLoop]
    COP [SpawnAfterRelFlags] ( @code_0AD92F, #$FFF5, #$FFDA, #$2202 )
    COP [StageSpriteLoop] ( #0E, #02 )
    COP [AnimLoop]

  loc_0ABF05:
    COP [RestoreSavedPtr]
}

code_0ABF07 {
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    LDA $orbitAngle, X
    CMP #$0007
    BNE loc_0ABF2C
    COP [StageSpriteLoop] ( #0F, #08 )
    COP [AnimLoop]
    COP [SpawnAfterRelFlags] ( @code_0AD960, #$FFF9, #$FFD0, #$2200 )
    COP [StageSpriteLoop] ( #0F, #02 )
    COP [AnimLoop]

  loc_0ABF2C:
    COP [RestoreSavedPtr]
}

code_0ABF2E {
    COP [StageSpriteFrame] ( #10 )
    COP [AnimOnce]
    LDA $orbitAngle, X
    CMP #$0000
    BNE loc_0ABF53
    COP [StageSpriteLoop] ( #10, #08 )
    COP [AnimLoop]
    COP [SpawnAfterRelFlags] ( @code_0AD993, #$0000, #$FFD0, #$2200 )
    COP [StageSpriteLoop] ( #10, #02 )
    COP [AnimLoop]

  loc_0ABF53:
    COP [RestoreSavedPtr]
}

code_0ABF55 {
    COP [StageSpriteFrame] ( #8F )
    COP [AnimOnce]
    LDA $orbitAngle, X
    CMP #$0001
    BNE loc_0ABF7A
    COP [StageSpriteLoop] ( #8F, #08 )
    COP [AnimLoop]
    COP [SpawnAfterRelFlags] ( @code_0AD976, #$0007, #$FFD0, #$2200 )
    COP [StageSpriteLoop] ( #8F, #02 )
    COP [AnimLoop]

  loc_0ABF7A:
    COP [RestoreSavedPtr]
}

code_0ABF7C {
    COP [StageSpriteFrame] ( #8E )
    COP [AnimOnce]
    LDA $orbitAngle, X
    CMP #$0002
    BNE loc_0ABFA1
    COP [StageSpriteLoop] ( #8E, #08 )
    COP [AnimLoop]
    COP [SpawnAfterRelFlags] ( @code_0AD944, #$000B, #$FFDA, #$2202 )
    COP [StageSpriteLoop] ( #8E, #02 )
    COP [AnimLoop]

  loc_0ABFA1:
    COP [RestoreSavedPtr]
}

code_0ABFA3 {
    COP [StageSpriteFrame] ( #8D )
    COP [AnimOnce]
    LDA $orbitAngle, X
    CMP #$0003
    BNE loc_0ABFC8
    COP [StageSpriteLoop] ( #8D, #08 )
    COP [AnimLoop]
    COP [SpawnAfterRelFlags] ( @code_0AD910, #$0006, #$FFD9, #$2202 )
    COP [StageSpriteLoop] ( #8D, #02 )
    COP [AnimLoop]

  loc_0ABFC8:
    COP [RestoreSavedPtr]
}

actor_def_0ABFCA [
  actor-def < #17, #10, #03, {

  code_0ABFCD:
    JSR $&code_0AC3D2
    COP [SolidHighHere]

  loc_0ABFD2:
    COP [StageSpriteFrame] ( #17 )
    COP [AnimOnce]

  code_0ABFD7:
    COP [WaitWhileOffscreen] ( #1E )
    COP [BranchIfPlayerNear] ( #04, &code_0ABFE4 )
    COP [SetEntryExitNow] ( @code_0ABFD7 )
} >
]

code_0ABFE4 {
    COP [SpawnBeforeFlags] ( @code_0AC080, #$2212 )
    TXA 
    TYX 
    TAY 
    TYA 
    STA $orbitAngle, X
    TXA 
    TYX 
    TAY 
    LDA #$0001
    STA $orbitAngle, X
    COP [StageSpriteFrame] ( #18 )
    COP [AnimOnce]
    COP [CallScript] ( &code_0AD861 )
    COP [StageSprAndHitbox] ( #19 )
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $orbitAngle, X
    BMI loc_0AC06D
    BEQ loc_0AC016
    RTL 

  loc_0AC016:
    COP [CallScript] ( &code_0AD8A1 )
    BRA loc_0ABFD2
}

actor_def_0AC01C [
  actor-def < #17, #10, #01, {

  code_0AC01F:
    JSR $&code_0AC3D2
    COP [SolidHighHere]

  loc_0AC024:
    COP [StageSpriteFrame] ( #17 )
    COP [AnimOnce]
    COP [SetHitCallback] ( &code_0AC035 )

  code_0AC02D:
    COP [WaitWhileOffscreen] ( #1E )
    COP [SetEntryExitNow] ( @code_0AC02D )
} >
]

code_0AC035 {
    COP [SpawnBeforeFlags] ( @code_0AC080, #$2212 )
    TXA 
    TYX 
    TAY 
    TYA 
    STA $orbitAngle, X
    TXA 
    TYX 
    TAY 
    LDA #$0001
    STA $orbitAngle, X
    COP [StageSpriteFrame] ( #18 )
    COP [AnimOnce]
    COP [CallScript] ( &code_0AD861 )
    COP [StageSprAndHitbox] ( #19 )
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $orbitAngle, X
    BMI loc_0AC06D
    BEQ loc_0AC067
    RTL 

  loc_0AC067:
    COP [CallScript] ( &code_0AD8A1 )
    BRA loc_0AC024

  loc_0AC06D:
    COP [StageSpriteFrame] ( #18 )
    COP [AnimOnce]
    COP [CallScript] ( &code_0AD8A1 )
    COP [SpawnMarkedAfter] ( @chunk_008000.code_00E34D, #$2300 )
    COP [SetEntryContinue]
    RTL 
}

code_0AC080 {
    COP [AddPosition] ( #FF, #DC )
    LDA #$2000
    TRB $10
    JSR $&code_0ADBE8
    LDA #$0000
    STA $orbitDiameter, X
    LDA #$0100
    TSB $12
    LDA #$1010
    STA $20
    STA $22
    COP [StageSpriteLoop] ( #1A, #50 )
    COP [AnimLoop]
    LDA #$0200
    TRB $10
    COP [SetHitCallback] ( &code_0AC109 )
    BRA loc_0AC0BA

  code_0AC0B0:
    COP [SetHitCallback] ( &code_0AC109 )

  code_0AC0B4:
    COP [StageSpriteLoop] ( #22, #02 )
    COP [AnimLoop]

  loc_0AC0BA:
    COP [SetSavedPtr] ( &code_0AC0B4 )
    COP [BranchIfPlayerNear] ( #07, &code_0AC160 )
    COP [CollPrioritySetMax]

  loc_0AC0C5:
    LDA $7F100C, X
    STA $moveXAlt, X
    LDA $7F100E, X
    STA $moveYAlt, X
    COP [StageMove] ( #22, #04, #FF )
    COP [TickMove]
    LDA $14
    CMP $7F100C, X
    BNE loc_0AC0C5
    LDA $16
    CMP $7F100E, X
    BNE loc_0AC0C5
    PHX 
    LDA $orbitAngle, X
    TAX 
    LDA #$0000
    STA $orbitAngle, X
    PLX 
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    LDA #$0200
    TSB $10
    COP [WaitByte] ( #77 )
    COP [Die]
}

code_0AC109 {
    LDA $orbitDiameter, X
    INC 
    CMP #$0003
    BEQ loc_0AC141
    STA $orbitDiameter, X
    STZ $2C
    STZ $2E
    COP [SpawnAfter] ( @code_0AC226 )
    LDA #$0200
    TSB $10
    COP [LoopInit] ( #0A )
    LDA #$2000
    TSB $10
    COP [SetEntryExit]
    LDA #$2000
    TRB $10
    COP [WaitByte] ( #01 )
    COP [LoopNext]
    LDA #$0200
    TRB $10
    JMP $&code_0AC0B0

  loc_0AC141:
    PHX 
    LDA $orbitAngle, X
    TAX 
    LDA #$FFFF
    STA $orbitAngle, X
    PLX 
    COP [PlaySoundCh1] ( #06 )
    COP [SpawnLastRel] ( @chunk_008000.code_00E034, #00, #00, #$0302 )
    COP [WaitByte] ( #03 )
    COP [Die]
}

code_0AC160 {
    COP [StageSprAndHitbox] ( #22 )
    COP [DirToPlayer]
    AND #$0007
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0AC171 )
}

code_list_0AC171 [
  &code_0AC181   ;00
  &code_0AC196   ;01
  &code_0AC1AB   ;02
  &code_0AC1BF   ;03
  &code_0AC1D4   ;04
  &code_0AC1E8   ;05
  &code_0AC1FD   ;06
  &code_0AC211   ;07
]

code_0AC181 {
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    COP [SetEntryExit]
    COP [StageSpriteLoop] ( #1A, #1E )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #1A, #18, #08 )
    COP [AnimLoop]
    COP [RestoreSavedPtr]
}

code_0AC196 {
    COP [SetEntryContinue]
    COP [ContinueIfFrame] ( #02 )
    COP [StageSpriteLoop] ( #1B, #1E )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveXY] ( #1B, #18, #05, #06 )
    COP [AnimLoop]
    COP [RestoreSavedPtr]
}

code_0AC1AB {
    COP [SetEntryContinue]
    COP [ContinueIfFrame] ( #03 )
    COP [StageSpriteLoop] ( #1C, #1E )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #1C, #18, #07 )
    COP [AnimLoop]
    COP [RestoreSavedPtr]
}

code_0AC1BF {
    COP [SetEntryContinue]
    COP [ContinueIfFrame] ( #04 )
    COP [StageSpriteLoop] ( #1D, #1E )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveXY] ( #1D, #18, #05, #05 )
    COP [AnimLoop]
    COP [RestoreSavedPtr]
}

code_0AC1D4 {
    COP [SetEntryContinue]
    COP [ContinueIfFrame] ( #05 )
    COP [StageSpriteLoop] ( #1E, #1E )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #1E, #18, #07 )
    COP [AnimLoop]
    COP [RestoreSavedPtr]
}

code_0AC1E8 {
    COP [SetEntryContinue]
    COP [ContinueIfFrame] ( #06 )
    COP [StageSpriteLoop] ( #1F, #1E )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveXY] ( #1F, #18, #06, #05 )
    COP [AnimLoop]
    COP [RestoreSavedPtr]
}

code_0AC1FD {
    COP [SetEntryContinue]
    COP [ContinueIfFrame] ( #07 )
}

code_0AC202 {
    COP [StageSpriteLoop] ( #20, #1E )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #20, #18, #08 )
    COP [AnimLoop]
    COP [RestoreSavedPtr]
}

code_0AC211 {
    COP [SetEntryContinue]
    COP [ContinueIfFrame] ( #08 )
    COP [StageSpriteLoop] ( #21, #1E )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveXY] ( #21, #18, #06, #06 )
    COP [AnimLoop]
    COP [RestoreSavedPtr]
}

code_0AC226 {
    LDA #$0008
    TSB $12
    PEA $&code_0AC268-1
    COP [CardinalToPlayer]
    AND #$0003
    BEQ loc_0AC23E
    DEC 
    BEQ loc_0AC247
    DEC 
    BEQ loc_0AC253
    DEC 
    BEQ loc_0AC25F

  loc_0AC23E:
    LDA #$6000
    TRB $12
    COP [StageForceMoveY] ( #22 )
    RTS 

  loc_0AC247:
    LDA #$6000
    TRB $12
    COP [SetForceBoth] ( #01 )
    COP [StageForceMoveX] ( #22 )
    RTS 

  loc_0AC253:
    LDA #$6000
    TRB $12
    COP [SetForceBoth] ( #01 )
    COP [StageForceMoveY] ( #22 )
    RTS 

  loc_0AC25F:
    LDA #$6000
    TRB $12
    COP [StageForceMoveX] ( #22 )
    RTS 
}

code_0AC268 {
    COP [SetEntryExit]
    COP [LoopInit] ( #14 )
    LDY $04
    LDY $24
    LDA $14
    STA $0014, Y
    LDA $16
    STA $0016, Y
    COP [LoopNext]
    COP [Die]
}

actor_def_0AC27F [
  actor-def < #17, #10, #03, {

  code_0AC282:
    JSR $&code_0AC3D2
    COP [SolidHighHere]

  loc_0AC287:
    COP [StageSpriteFrame] ( #17 )
    COP [AnimOnce]

  code_0AC28C:
    COP [WaitWhileOffscreen] ( #1E )
    COP [BranchIfPlayerNear] ( #04, &code_0AC299 )
    COP [SetEntryExitNow] ( @code_0AC28C )
} >
]

code_0AC299 {
    COP [SpawnAfterRelFlags] ( @code_0AC33D, #$FFFF, #$FFDC, #$0212 )
    TXA 
    TYX 
    TAY 
    TYA 
    STA $orbitAngle, X
    TXA 
    TYX 
    TAY 
    LDA #$0001
    STA $orbitAngle, X
    COP [StageSpriteFrame] ( #18 )
    COP [AnimOnce]
    COP [CallScript] ( &code_0AD881 )
    COP [StageSprAndHitbox] ( #19 )
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $orbitAngle, X
    BMI loc_0AC32A
    BEQ loc_0AC2CF
    RTL 

  loc_0AC2CF:
    COP [CallScript] ( &code_0AD8A1 )
    BRA loc_0AC287
}

actor_def_0AC2D5 [
  actor-def < #17, #10, #01, {

  code_0AC2D8:
    JSR $&code_0AC3D2
    COP [SolidHighHere]

  loc_0AC2DD:
    COP [SetHitCallback] ( &code_0AC2EE )
    COP [StageSpriteFrame] ( #17 )
    COP [AnimOnce]

  code_0AC2E6:
    COP [WaitWhileOffscreen] ( #1E )
    COP [SetEntryExitNow] ( @code_0AC2E6 )
} >
]

code_0AC2EE {
    COP [SpawnAfterRelFlags] ( @code_0AC33D, #$FFFF, #$FFDC, #$0212 )
    TXA 
    TYX 
    TAY 
    TYA 
    STA $orbitAngle, X
    TXA 
    TYX 
    TAY 
    LDA #$0001
    STA $orbitAngle, X
    COP [StageSpriteFrame] ( #18 )
    COP [AnimOnce]
    COP [CallScript] ( &code_0AD881 )
    COP [StageSprAndHitbox] ( #19 )
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $orbitAngle, X
    BMI loc_0AC32A
    BEQ loc_0AC324
    RTL 

  loc_0AC324:
    COP [CallScript] ( &code_0AD8A1 )
    BRA loc_0AC2DD

  loc_0AC32A:
    COP [StageSpriteFrame] ( #18 )
    COP [AnimOnce]
    COP [CallScript] ( &code_0AD8C1 )
    COP [SpawnMarkedAfter] ( @chunk_008000.code_00E34D, #$2300 )
    COP [SetEntryContinue]
    RTL 
}

code_0AC33D {
    JSR $&code_0ADBE8
    LDA #$0000
    STA $orbitDiameter, X
    COP [StageSpriteLoop] ( #1A, #50 )
    COP [AnimLoop]
    LDA #$0200
    TRB $10
    COP [StageSprAndHitbox] ( #22 )
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    BRA loc_0AC365

  loc_0AC35B:
    COP [SetHitCallback] ( &code_0AC39A )
    COP [StageSpriteLoop] ( #22, #04 )
    COP [AnimLoop]

  loc_0AC365:
    COP [SetHitCallback] ( &code_0AC398 )
    LDA #$8022
    STA $chatPtr, X
    LDA #$0002
    STA $loopCounter, X
    COP [SpawnMarkedAfter] ( @chunk_008000.code_00E79D, #$2000 )
    LDA $decelStepCounter
    STA $0024, Y
    COP [SetEntryExit]
    LDA #$0030
    STA $24
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    DEC $24
    BMI loc_0AC394
    RTL 

  loc_0AC394:
    COP [KillNext]
    BRA loc_0AC35B
}

code_0AC398 {
    COP [KillNext]
}

code_0AC39A {
    LDA $orbitDiameter, X
    INC 
    STA $orbitDiameter, X
    CMP #$0003
    BEQ loc_0AC3B3
    STZ $2C
    STZ $2E
    COP [SpawnAfter] ( @code_0AC226 )
    BRA loc_0AC35B

  loc_0AC3B3:
    PHX 
    LDA $orbitAngle, X
    TAX 
    LDA #$FFFF
    STA $orbitAngle, X
    PLX 
    COP [PlaySoundCh1] ( #06 )
    COP [SpawnLastRel] ( @chunk_008000.code_00E034, #00, #00, #$0302 )
    COP [WaitByte] ( #03 )
    COP [Die]
}

code_0AC3D2 {
    LDY $decelStepCounter
    LDA $0014, Y
    CMP $14
    BNE loc_0AC3EB
    LDA $0016, Y
    CMP $16
    BNE loc_0AC3EB
    LDA $14
    SEC 
    SBC #$0020
    STA $14

  loc_0AC3EB:
    RTS 
}

actor_def_0AC3EC [
  actor-def < #25, #00, #00, {

  code_0AC3EF:
    LDA #$0080
    TSB $12
    COP [SetDeathCallback] ( @code_0AC5CC )

  loc_0AC3F9:
    COP [WaitWhileOffscreen] ( #0F )
    JMP $&code_0AC412
} >
]

actor_def_0AC3FF [
  actor-def < #23, #00, #00, {

  code_0AC402:
    LDA #$0080
    TSB $12
    COP [SetDeathCallback] ( @code_0AC5CC )

  code_0AC40C:
    COP [WaitWhileOffscreen] ( #0F )
    JMP $&code_0AC4AB
} >
]

code_0AC412 {
    LDA $10
    BIT #$4000
    BNE loc_0AC3F9
    COP [SetSavedPtr] ( &code_0AC412 )
    COP [StageSpriteFrame] ( #25 )
    COP [AnimOnce]
    BRA loc_0AC42D

  code_0AC424:
    COP [SetSavedPtr] ( &code_0AC424 )
    COP [StageSpriteFrame] ( #25 )
    COP [AnimOnce]

  loc_0AC42D:
    COP [BranchOnPlayerX] ( #$0020, &code_0AC596, &code_0AC437, &code_0AC5B1 )
}

code_0AC437 {
    COP [SetEntryExit]
    COP [RngByte]
    AND #$0001
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0AC447 )
}

code_list_0AC447 [
  &code_0AC44B   ;00
  &code_0AC463   ;01
]

code_0AC44B {
    COP [BranchIfSolidNorth] ( &code_0AC499 )
    COP [BranchIfSolidOffset] ( #00, #FE, &code_0AC499 )
    COP [SetEntryExit]
    COP [StageSpriteFrame] ( #2D )
    COP [AnimOnce]
    COP [SetSavedPtr] ( &code_0AC4C0 )
    JMP $&code_0AC54D
}

code_0AC463 {
    COP [BranchIfSolidNorth] ( &code_0AC487 )
    COP [BranchIfSolidOffset] ( #00, #FE, &code_0AC487 )
    COP [SetEntryExit]
    COP [BranchIfSolidSouth] ( &code_0AC487 )
    COP [BranchIfSolidOffset] ( #00, #02, &code_0AC487 )
    COP [SetEntryExit]
    COP [StageSpriteFrame] ( #2D )
    COP [AnimOnce]
    COP [SetSavedPtr] ( &code_0AC4AB )
    JMP $&code_0AC571
}

code_0AC487 {
    COP [SetEntryExit]
    COP [BranchIfSolidEast] ( &code_0AC499 )
    COP [BranchIfSolidOffset] ( #02, #00, &code_0AC499 )
    COP [CallScript] ( &code_0AC5B1 )
    BRA code_0AC44B
}

code_0AC499 {
    COP [SetEntryExit]
    COP [BranchIfSolidWest] ( &code_0AC487 )
    COP [BranchIfSolidOffset] ( #FE, #00, &code_0AC487 )
    COP [CallScript] ( &code_0AC596 )
    BRA code_0AC44B
}

code_0AC4AB {
    LDA $10
    BIT #$4000
    BEQ loc_0AC4B5
    JMP $&code_0AC40C

  loc_0AC4B5:
    COP [SetSavedPtr] ( &code_0AC4AB )
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]
    BRA loc_0AC4C9
}

code_0AC4C0 {
    COP [SetSavedPtr] ( &code_0AC4C0 )
    COP [StageSpriteFrame] ( #24 )
    COP [AnimOnce]

  loc_0AC4C9:
    COP [BranchOnPlayerY] ( #$0020, &code_0AC54D, &code_0AC4D3, &code_0AC571 )
}

code_0AC4D3 {
    COP [SetEntryExit]
    COP [RngByte]
    AND #$0001
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0AC4E3 )
}

code_list_0AC4E3 [
  &code_0AC503   ;00
  &code_0AC4E7   ;01
]

code_0AC4E7 {
    COP [SetSavedPtr] ( &code_0AC4E7 )
    COP [BranchIfSolidEast] ( &code_0AC529 )
    COP [BranchIfSolidOffset] ( #02, #00, &code_0AC529 )
    COP [SetEntryExit]
    COP [StageSpriteFrame] ( #38 )
    COP [AnimOnce]
    COP [SetSavedPtr] ( &code_0AC424 )
    JMP $&code_0AC5B1
}

code_0AC503 {
    COP [SetSavedPtr] ( &code_0AC503 )
    COP [BranchIfSolidEast] ( &code_0AC53B )
    COP [BranchIfSolidOffset] ( #02, #00, &code_0AC53B )
    COP [SetEntryExit]
    COP [BranchIfSolidWest] ( &code_0AC53B )
    COP [BranchIfSolidOffset] ( #FE, #00, &code_0AC53B )
    COP [StageSpriteFrame] ( #38 )
    COP [AnimOnce]
    COP [SetSavedPtr] ( &code_0AC412 )
    JMP $&code_0AC596
}

code_0AC529 {
    COP [SetEntryExit]
    COP [BranchIfSolidSouth] ( &code_0AC53B )
    COP [BranchIfSolidOffset] ( #00, #02, &code_0AC53B )
    COP [CallScript] ( &code_0AC571 )
    BRA code_0AC4E7
}

code_0AC53B {
    COP [SetEntryExit]
    COP [BranchIfSolidNorth] ( &code_0AC529 )
    COP [BranchIfSolidOffset] ( #00, #FE, &code_0AC529 )
    COP [CallScript] ( &code_0AC54D )
    BRA code_0AC503
}

code_0AC54D {
    COP [BranchIfSolidOffset] ( #00, #FE, &code_0AC4D3 )
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #00, #FD, &code_0AC4D3 )
    COP [StageSprAndHitbox] ( #26 )
    LDA #$2000
    TSB $12
    COP [SetEntryContinue]
    COP [ContinueIfFrame] ( #04 )
    COP [StageForceMoveY] ( #3C )
    COP [SetEntryContinue]
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0AC571 {
    COP [BranchIfSolidSouth] ( &code_0AC4D3 )
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #00, #02, &code_0AC4D3 )
    COP [StageSprAndHitbox] ( #27 )
    LDA #$2000
    TRB $12
    COP [StageForceMoveY] ( #3C )
    COP [SetEntryContinue]
    COP [ContinueIfFrame] ( #08 )
    COP [StageForceMoveY] ( #00 )
    COP [SetEntryContinue]
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0AC596 {
    COP [BranchIfSolidOffset] ( #FE, #00, &code_0AC437 )
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #FD, #00, &code_0AC437 )
    LDA #$4000
    TSB $12
    COP [StageSpriteMoveX] ( #28, #3D )
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0AC5B1 {
    COP [BranchIfSolidOffset] ( #02, #00, &code_0AC437 )
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #03, #00, &code_0AC437 )
    LDA #$4000
    TRB $12
    COP [StageSpriteMoveX] ( #28, #3D )
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0AC5CC {
    COP [SetEntryContinue]
    COP [AnimOnce]
    PHX 
    LDA $28
    AND #$00FF
    SEC 
    SBC #$0023
    TAX 
    LDA $@loc_0AC666, X
    AND #$00FF
    PLX 
    CMP #$0001
    BEQ loc_0AC5F0
    COP [StageSpriteLoop] ( #33, #04 )
    COP [AnimLoop]
    BRA loc_0AC5F6

  loc_0AC5F0:
    COP [StageSpriteLoop] ( #34, #04 )
    COP [AnimLoop]

  loc_0AC5F6:
    LDA #$6000
    TRB $12
    COP [StageSprAndHitbox] ( #2E )
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    COP [PlaySoundBoth] ( #$0E0E )
    COP [SpawnAfterRelFlags] ( @code_0AC67E, #$0000, #$0000, #$0302 )
    COP [SetEntryExit]
    COP [SpawnAfterRelFlags] ( @code_0AC692, #$0000, #$0000, #$0302 )
    COP [SetEntryExit]
    COP [SpawnAfterRelFlags] ( @code_0AC69C, #$0000, #$0000, #$0302 )
    COP [SetEntryExit]
    COP [SpawnAfterRelFlags] ( @code_0AC6A6, #$0000, #$0000, #$0302 )
    COP [SetEntryExit]
    COP [SpawnAfterRelFlags] ( @code_0AC6B0, #$0000, #$0000, #$0302 )
    COP [SetEntryExit]
    COP [SpawnAfterRelFlags] ( @code_0AC6BA, #$0000, #$0000, #$0302 )
    COP [SetEntryExit]
    COP [SpawnAfterRelFlags] ( @code_0AC6C4, #$0000, #$0000, #$0302 )
    COP [SetEntryExit]
    COP [JumpScript] ( @chunk_008000.code_00DCA9 )

  loc_0AC666:
    ORA ($01, X)
    BRK #$01
    ORA ($00, X)
    ORA ($01, X)
    BRK #$01
    ORA ($09, X)
    BRK #$00
    ORA ($01, X)
    BRK #$00
    BRK #$00
    BRK #$00
    BRK #$01
}

code_0AC67E {
    COP [SpawnLastRel] ( @chunk_008000.code_00E034, #00, #00, #$0302 )
    COP [InitGravity] ( #03, #07, #00 )
    COP [StageForceMoveX] ( #03 )
    JMP $&code_0AC6C9
}

code_0AC692 {
    COP [InitGravity] ( #03, #07, #00 )
    COP [StageForceMoveX] ( #04 )
    BRA code_0AC6C9
}

code_0AC69C {
    COP [InitGravity] ( #04, #07, #01 )
    COP [StageForceMoveX] ( #01 )
    BRA code_0AC6C9
}

code_0AC6A6 {
    COP [InitGravity] ( #04, #07, #01 )
    COP [StageForceMoveX] ( #02 )
    BRA code_0AC6C9
}

code_0AC6B0 {
    COP [InitGravity] ( #05, #07, #02 )
    COP [StageForceMoveX] ( #11 )
    BRA code_0AC6C9
}

code_0AC6BA {
    COP [InitGravity] ( #05, #07, #02 )
    COP [StageForceMoveX] ( #12 )
    BRA code_0AC6C9
}

code_0AC6C4 {
    COP [InitGravity] ( #06, #07, #03 )
}

code_0AC6C9 {
    COP [TickGravity]
    CMP #$0000
    BMI loc_0AC6D4
    COP [SetEntryExit]
    BRA code_0AC6C9

  loc_0AC6D4:
    COP [PlaySoundCh1] ( #06 )
    COP [SetEntryExit]
    COP [AddPosition] ( #04, #14 )
    COP [JumpScript] ( @chunk_008000.code_00E034 )
}

actor_def_0AC6E2 [
  actor-def < #25, #00, #00, {

  code_0AC6E5:
    COP [SetSpritePalette] ( #04 )
    LDA #$0180
    TSB $12
    COP [SetDeathCallback] ( @code_0ACA5E )
    JSR $&code_0ACA48

  loc_0AC6F5:
    COP [WaitWhileOffscreen] ( #0F )
    JMP $&code_0AC714
} >
]

code_0AC6FB {
    AND $00, S
    BRK #$02
    LDA [$04], Y
    LDA #$0180
    TSB $12
    COP [SetDeathCallback] ( @code_0ACA5E )
    JSR $&code_0ACA53

  code_0AC70E:
    COP [WaitWhileOffscreen] ( #0F )
    JMP $&code_0AC917
}

code_0AC714 {
    LDA $10
    BIT #$4000
    BNE loc_0AC6F5
    COP [SetSavedPtr] ( &code_0AC714 )
    COP [StageSpriteFrame] ( #25 )
    COP [AnimOnce]
    BRA loc_0AC72F

  code_0AC726:
    COP [SetSavedPtr] ( &code_0AC726 )
    COP [StageSpriteFrame] ( #25 )
    COP [AnimOnce]

  loc_0AC72F:
    COP [BranchOnPlayerX] ( #$0020, &code_0ACA0D, &code_0AC739, &code_0ACA2D )
}

code_0AC739 {
    COP [SetEntryExit]
    COP [RngByte]
    AND #$0001
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0AC749 )
}

code_list_0AC749 [
  &code_0AC74D   ;00
  &code_0AC81B   ;01
]

code_0AC74D {
    COP [RngByte]
    LSR 
    BCC loc_0AC7B5
    COP [BranchIfSolidOffset] ( #FE, #FC, &code_0AC79D )
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #FF, #FC, &code_0AC79D )
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #00, #FC, &code_0AC79D )
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #01, #FC, &code_0AC79D )
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #02, #FC, &code_0AC79D )
    COP [SetEntryExit]
    COP [StageSpriteFrame] ( #2F )
    COP [AnimOnce]
    LDA #$2000
    TRB $12
    LDA #$0300
    TSB $10
    COP [StageSpriteLoopMoveY] ( #30, #19, #50 )
    COP [AnimLoop]
    LDA #$0300
    TRB $10
    COP [StageSpriteFrame] ( #39 )
    COP [AnimOnce]
    JMP $&code_0AC714
}

code_0AC79D {
    COP [BranchIfSolidNorth] ( &code_0AC904 )
    COP [BranchIfSolidOffset] ( #00, #FE, &code_0AC904 )
    COP [SetEntryExit]
    COP [StageSpriteFrame] ( #2D )
    COP [AnimOnce]
    COP [SetSavedPtr] ( &code_0AC92C )
    JMP $&code_0AC9BF

  loc_0AC7B5:
    COP [BranchIfSolidNorth] ( &code_0AC7D0 )
    COP [BranchIfSolidOffset] ( #00, #FE, &code_0AC7D0 )
    COP [SetEntryExit]
    COP [StageSpriteFrame] ( #2D )
    COP [AnimOnce]
    COP [SetSavedPtr] ( &code_0AC92C )
    JSR $&code_0ACA53
    JMP $&code_0AC9BF
}

code_0AC7D0 {
    COP [BranchIfSolidOffset] ( #FE, #FC, &code_0AC904 )
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #FF, #FC, &code_0AC904 )
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #00, #FC, &code_0AC904 )
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #01, #FC, &code_0AC904 )
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #02, #FC, &code_0AC904 )
    COP [SetEntryExit]
    COP [StageSpriteFrame] ( #2F )
    COP [AnimOnce]
    LDA #$2000
    TRB $12
    LDA #$0300
    TSB $10
    COP [StageSpriteLoopMoveY] ( #30, #19, #50 )
    COP [AnimLoop]
    LDA #$0300
    TRB $10
    COP [StageSpriteFrame] ( #39 )
    COP [AnimOnce]
    JMP $&code_0AC714
}

code_0AC81B {
    COP [RngByte]
    LSR 
    BCC loc_0AC892
    COP [BranchIfSolidOffset] ( #FE, #04, &code_0AC86B )
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #FF, #04, &code_0AC86B )
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #00, #04, &code_0AC86B )
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #01, #04, &code_0AC86B )
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #02, #04, &code_0AC86B )
    COP [SetEntryExit]
    COP [StageSpriteFrame] ( #2F )
    COP [AnimOnce]
    LDA #$2000
    TRB $12
    LDA #$0300
    TSB $10
    COP [StageSpriteLoopMoveY] ( #30, #1A, #4F )
    COP [AnimLoop]
    LDA #$0300
    TRB $10
    COP [StageSpriteFrame] ( #39 )
    COP [AnimOnce]
    JMP $&code_0AC726
}

code_0AC86B {
    COP [BranchIfSolidNorth] ( &code_0AC904 )
    COP [BranchIfSolidOffset] ( #00, #FE, &code_0AC904 )
    COP [SetEntryExit]
    COP [BranchIfSolidSouth] ( &code_0AC904 )
    COP [BranchIfSolidOffset] ( #00, #02, &code_0AC904 )
    COP [SetEntryExit]
    COP [StageSpriteFrame] ( #2D )
    COP [AnimOnce]
    COP [SetSavedPtr] ( &code_0AC917 )
    JSR $&code_0ACA53
    JMP $&code_0AC9E8

  loc_0AC892:
    COP [BranchIfSolidNorth] ( &code_0AC8B9 )
    COP [BranchIfSolidOffset] ( #00, #FE, &code_0AC8B9 )
    COP [SetEntryExit]
    COP [BranchIfSolidSouth] ( &code_0AC8B9 )
    COP [BranchIfSolidOffset] ( #00, #02, &code_0AC8B9 )
    COP [SetEntryExit]
    COP [StageSpriteFrame] ( #2D )
    COP [AnimOnce]
    COP [SetSavedPtr] ( &code_0AC917 )
    JSR $&code_0ACA53
    JMP $&code_0AC9E8
}

code_0AC8B9 {
    COP [BranchIfSolidOffset] ( #FE, #04, &code_0AC904 )
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #FF, #04, &code_0AC904 )
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #00, #04, &code_0AC904 )
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #01, #04, &code_0AC904 )
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #02, #04, &code_0AC904 )
    COP [SetEntryExit]
    COP [StageSpriteFrame] ( #2F )
    COP [AnimOnce]
    LDA #$2000
    TRB $12
    LDA #$0300
    TSB $10
    COP [StageSpriteLoopMoveY] ( #30, #1A, #4F )
    COP [AnimLoop]
    LDA #$0300
    TRB $10
    COP [StageSpriteFrame] ( #39 )
    COP [AnimOnce]
    JMP $&code_0AC726
}

code_0AC904 {
    COP [RngByte]
    LSR 
    BCS loc_0AC910
    COP [SetSavedPtr] ( &code_0AC714 )
    JMP $&code_0ACA0D

  loc_0AC910:
    COP [SetSavedPtr] ( &code_0AC726 )
    JMP $&code_0ACA2D
}

code_0AC917 {
    LDA $10
    BIT #$4000
    BEQ loc_0AC921
    JMP $&code_0AC70E

  loc_0AC921:
    COP [SetSavedPtr] ( &code_0AC917 )
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]
    BRA loc_0AC935
}

code_0AC92C {
    COP [SetSavedPtr] ( &code_0AC92C )
    COP [StageSpriteFrame] ( #24 )
    COP [AnimOnce]

  loc_0AC935:
    COP [BranchOnPlayerY] ( #$0020, &code_0AC9BF, &code_0AC93F, &code_0AC9E8 )
}

code_0AC93F {
    COP [SetEntryExit]
    COP [RngByte]
    AND #$0001
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0AC94F )
}

code_list_0AC94F [
  &code_0AC972   ;00
  &code_0AC953   ;01
]

code_0AC953 {
    COP [SetSavedPtr] ( &code_0AC953 )
    COP [BranchIfSolidEast] ( &code_0AC99B )
    COP [BranchIfSolidOffset] ( #02, #00, &code_0AC99B )
    COP [SetEntryExit]
    COP [StageSpriteFrame] ( #38 )
    COP [AnimOnce]
    COP [SetSavedPtr] ( &code_0AC726 )
    JSR $&code_0ACA48
    JMP $&code_0ACA2D
}

code_0AC972 {
    COP [SetSavedPtr] ( &code_0AC972 )
    COP [BranchIfSolidEast] ( &code_0AC9AD )
    COP [BranchIfSolidOffset] ( #02, #00, &code_0AC9AD )
    COP [SetEntryExit]
    COP [BranchIfSolidWest] ( &code_0AC9AD )
    COP [BranchIfSolidOffset] ( #FE, #00, &code_0AC9AD )
    COP [StageSpriteFrame] ( #38 )
    COP [AnimOnce]
    COP [SetSavedPtr] ( &code_0AC714 )
    JSR $&code_0ACA48
    JMP $&code_0ACA0D
}

code_0AC99B {
    COP [SetEntryExit]
    COP [BranchIfSolidSouth] ( &code_0AC9AD )
    COP [BranchIfSolidOffset] ( #00, #02, &code_0AC9AD )
    COP [CallScript] ( &code_0AC9E8 )
    BRA code_0AC953
}

code_0AC9AD {
    COP [SetEntryExit]
    COP [BranchIfSolidNorth] ( &code_0AC99B )
    COP [BranchIfSolidOffset] ( #00, #FE, &code_0AC99B )
    COP [CallScript] ( &code_0AC9BF )
    BRA code_0AC972
}

code_0AC9BF {
    COP [BranchIfSolidOffset] ( #00, #FE, &code_0AC93F )
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #00, #FD, &code_0AC93F )
    COP [StageSprAndHitbox] ( #2A )
    LDA #$2000
    TSB $12
    COP [SetEntryContinue]
    COP [ContinueIfFrame] ( #04 )
    COP [StageForceMoveY] ( #3F )
    COP [SetEntryContinue]
    COP [AnimOnce]
    LDA #$2000
    TRB $12
    COP [RestoreSavedPtr]
}

code_0AC9E8 {
    COP [BranchIfSolidSouth] ( &code_0AC93F )
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #00, #02, &code_0AC93F )
    COP [StageSprAndHitbox] ( #29 )
    LDA #$2000
    TRB $12
    COP [StageForceMoveY] ( #3F )
    COP [SetEntryContinue]
    COP [ContinueIfFrame] ( #08 )
    COP [StageForceMoveY] ( #00 )
    COP [SetEntryContinue]
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0ACA0D {
    COP [BranchIfSolidOffset] ( #FE, #00, &code_0AC739 )
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #FD, #00, &code_0AC739 )
    LDA #$4000
    TSB $12
    COP [StageSpriteMoveX] ( #2B, #3E )
    COP [AnimOnce]
    LDA #$4000
    TRB $12
    COP [RestoreSavedPtr]
}

code_0ACA2D {
    COP [BranchIfSolidOffset] ( #02, #00, &code_0AC739 )
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #03, #00, &code_0AC739 )
    LDA #$4000
    TRB $12
    COP [StageSpriteMoveX] ( #2B, #3E )
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0ACA48 {
    LDA #$1818
    STA $20
    LDA #$0610
    STA $22
    RTS 
}

code_0ACA53 {
    LDA #$0908
    STA $20
    LDA #$131E
    STA $22
    RTS 
}

code_0ACA5E {
    COP [SetEntryContinue]
    COP [AnimOnce]
    PHX 
    LDA $28
    AND #$00FF
    SEC 
    SBC #$0023
    TAX 
    LDA $@loc_0AC666, X
    AND #$00FF
    PLX 
    CMP #$0001
    BEQ loc_0ACA82
    COP [StageSpriteLoop] ( #33, #04 )
    COP [AnimLoop]
    BRA loc_0ACA88

  loc_0ACA82:
    COP [StageSpriteLoop] ( #34, #04 )
    COP [AnimLoop]

  loc_0ACA88:
    LDA #$6000
    TRB $12
    COP [PlaySoundBoth] ( #$0505 )
    COP [LoopInit] ( #07 )
    COP [SpawnAfterFlags] ( @code_0ACAEC, #$2302 )
    COP [WaitByte] ( #01 )
    COP [LoopNext]
    COP [SpawnAfterFlags] ( @code_0ACAAC, #$2000 )
    COP [JumpScript] ( @chunk_008000.code_00DCA9 )
}

code_0ACAAC {
    COP [StageSpriteFrame] ( #2E )
    COP [AnimOnce]
    COP [LoopInit] ( #07 )
    COP [WaitByte] ( #01 )
    COP [SpawnAfterFlags] ( @code_0ACB40, #$2302 )
    LDY $06
    COP [RngByte]
    STA $0000
    AND #$00F0
    SEC 
    SBC #$0080
    ORA #$0008
    CLC 
    ADC $14
    STA $0014, Y
    LDA $0000
    AND #$0070
    SEC 
    SBC #$0030
    CLC 
    ADC $16
    STA $0016, Y
    COP [WaitByte] ( #13 )
    COP [LoopNext]
    COP [Die]
}

code_0ACAEC {
    COP [RngByte]
    AND #$001F
    SEC 
    SBC #$0010
    CLC 
    ADC $14
    STA $14
    COP [SetSpritePalette] ( #00 )
    COP [SpawnLastRel] ( @chunk_008000.code_00E034, #00, #00, #$0302 )
    COP [SetEntryExit]
    COP [SetSpritePalette] ( #04 )
    LDA #$2000
    TRB $10
    COP [StageSpriteFrame] ( #2E )
    COP [AnimOnce]
    PHX 
    LDX $04
    LDA #$0007
    SEC 
    SBC $loopCounter, X
    PLX 
    STA $moveXAlt, X
    LDA #$0000
    STA $moveYAlt, X
    COP [ReloadForceMove]
    COP [InitGravity] ( #0A, #09, #01 )

  loc_0ACB33:
    COP [SetEntryExit]
    COP [TickGravity]
    LDA $10
    BIT #$4000
    BEQ loc_0ACB33
    COP [Die]
}

code_0ACB40 {
    COP [SpawnMarkedAfter] ( @code_0ACB8E, #$0301 )
    COP [SetEntryExit]
    LDA #$2000
    TRB $10
    COP [PlaySoundCh1] ( #13 )
    LDA $16
    STA $orbitAngle, X
    LDA $cameraTargetY
    SEC 
    SBC #$0100
    STA $16
    COP [StageForceMoveY] ( #0F )
    COP [SetSpritePriority] ( #30 )
    COP [SetEntryContinue]
    LDA $16
    BPL loc_0ACB6D
    RTL 

  loc_0ACB6D:
    CMP $orbitAngle, X
    BCS loc_0ACB74
    RTL 

  loc_0ACB74:
    COP [StageForceMoveY] ( #00 )
    LDA #$0102
    TRB $10
    COP [PlaySoundCh1] ( #06 )
    COP [SetSpritePalette] ( #00 )
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    COP [Die]
}

code_0ACB8E {
    COP [BranchIfSolid] ( &code_0ACB9E )
    COP [SetMetasprite] ( @table_0EE000 )

  loc_0ACB97:
    COP [StageSpriteFrame] ( #31 )
    COP [AnimOnce]
    BRA loc_0ACB97
}

code_0ACB9E {
    COP [Die]
}

actor_def_0ACBA0 [
  actor-def < #3B, #00, #02, {

  code_0ACBA3:
    COP [SpawnAfterFlags] ( @code_0ACC9A, #$0200 )
    COP [SpawnAfterFlags] ( @code_0ACC9A, #$0200 )
    COP [WaitWhileOffscreen] ( #08 )
    LDA #$0000
    STA $chatPtr, X
    BRA loc_0ACBD8
} >
]

actor_def_0ACBBD [
  actor-def < #3B, #00, #02, {

  code_0ACBC0:
    COP [SpawnAfterFlags] ( @code_0ACC9A, #$0200 )
    COP [SpawnAfterFlags] ( @code_0ACC9A, #$0200 )
    COP [WaitWhileOffscreen] ( #08 )
    LDA #$0001
    STA $chatPtr, X

  loc_0ACBD8:
    LDY $06
    LDA #$0000
    STA $0024, Y
    LDA $0006, Y
    TAY 
    LDA #$0000
    STA $0024, Y

  code_0ACBEA:
    COP [BranchIfSolidOffset] ( #00, #01, &code_0ACC16 )
    COP [BranchIfSolidOffset] ( #FF, #00, &code_0ACC6E )
    COP [BranchIfSolidOffset] ( #FF, #01, &code_0ACC42 )
    LDA $chatPtr, X
    BNE loc_0ACC0C
    COP [StageSpriteLoopMoveXY] ( #3B, #08, #12, #11 )
    COP [AnimLoop]
    BRA code_0ACBEA

  loc_0ACC0C:
    COP [StageSpriteLoopMoveXY] ( #3B, #04, #02, #01 )
    COP [AnimLoop]
    BRA code_0ACBEA
} >
]

code_0ACC16 {
    COP [BranchIfSolidOffset] ( #FF, #00, &code_0ACC42 )
    COP [BranchIfSolidOffset] ( #00, #FF, &code_0ACBEA )
    COP [BranchIfSolidOffset] ( #FF, #FF, &code_0ACC6E )
    LDA $chatPtr, X
    BNE loc_0ACC38
    COP [StageSpriteLoopMoveXY] ( #3B, #08, #12, #12 )
    COP [AnimLoop]
    BRA code_0ACC16

  loc_0ACC38:
    COP [StageSpriteLoopMoveXY] ( #3B, #04, #02, #02 )
    COP [AnimLoop]
    BRA code_0ACC16
}

code_0ACC42 {
    COP [BranchIfSolidOffset] ( #00, #FF, &code_0ACC6E )
    COP [BranchIfSolidOffset] ( #01, #00, &code_0ACC16 )
    COP [BranchIfSolidOffset] ( #01, #FF, &code_0ACBEA )
    LDA $chatPtr, X
    BNE loc_0ACC64
    COP [StageSpriteLoopMoveXY] ( #3B, #08, #11, #12 )
    COP [AnimLoop]
    BRA code_0ACC42

  loc_0ACC64:
    COP [StageSpriteLoopMoveXY] ( #3B, #04, #01, #02 )
    COP [AnimLoop]
    BRA code_0ACC42
}

code_0ACC6E {
    COP [BranchIfSolidOffset] ( #01, #00, &code_0ACBEA )
    COP [BranchIfSolidOffset] ( #00, #01, &code_0ACC42 )
    COP [BranchIfSolidOffset] ( #01, #01, &code_0ACC16 )
    LDA $chatPtr, X
    BNE loc_0ACC90
    COP [StageSpriteLoopMoveXY] ( #3B, #08, #11, #11 )
    COP [AnimLoop]
    BRA code_0ACC6E

  loc_0ACC90:
    COP [StageSpriteLoopMoveXY] ( #3B, #04, #01, #01 )
    COP [AnimLoop]
    BRA code_0ACC6E
}

code_0ACC9A {
    COP [StageSprAndHitbox] ( #3B )
    LDA #$0000
    STA $moveXAlt, X
    STA $moveXAlt, X
    STA $2C
    STA $2E
    STA $2A
    COP [SetEntryContinue]
    LDA $24
    BEQ loc_0ACCB5
    RTL 

  loc_0ACCB5:
    LDY $04
    LDA $0028, Y
    STA $orbitAngle, X
    TXA 
    TYX 
    TAY 
    LDA $moveXAlt, X
    PHA 
    LDA $moveYAlt, X
    PHA 
    LDA $sprTimer, X
    PHA 
    TXA 
    TYX 
    TAY 
    PLA 
    STA $sprTimer, X
    PLA 
    STA $7F100E, X
    PLA 
    STA $7F100C, X
    COP [ReloadForceMove]
    COP [SetEntryContinue]
    COP [AnimLoop]
    LDA $7F100C, X
    STA $moveXAlt, X
    LDA $7F100E, X
    STA $moveYAlt, X
    LDA $orbitAngle, X
    STA $28
    BRA loc_0ACCB5
}

actor_def_0ACD00 [
  actor-def < #00, #00, #30, {

  code_0ACD03:
    COP [SetEntryContinue]
    LDA $0AEC
    BEQ loc_0ACD0B
    RTL 

  loc_0ACD0B:
    COP [BranchIfFlagByte] ( #F9, #01, &code_0ACD4D )
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #3B )
    COP [PrintWideString] ( &widestring_0ACDDA )
    LDA #$0001
    STA $0AAC
    LDA #$0055
    STA $0B12
    LDA #$0010
    STA $0B08
    STA $0B0A
    LDA #$0008
    STA $0B0C
    STA $0B0E
    LDA #$2200
    STA $0B10
    COP [QueueMapChange] ( #FD, #$0000, #$0000, #00, #$1100 )
    RTL 
} >
]

code_0ACD4D {
    COP [SpawnBeforeFlags] ( @chunk_008000.code_00EA82, #$2800 )
    LDA #$0201
    STA $0014, Y
    LDA #$000C
    STA $0016, Y
    COP [SpawnBeforeFlags] ( @code_0ACECF, #$2800 )
    COP [WaitByte] ( #3B )
    LDA $characterForm
    BEQ loc_0ACD95
    LDY $decelStepCounter
    LDA #$0088
    STA $0002, Y
    LDA #$EC6A
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $slopeCurvePtrB
    COP [SetEntryContinue]
    LDA $slopeCurvePtrB
    BIT #$0800
    BEQ loc_0ACD95
    RTL 

  loc_0ACD95:
    COP [WaitByte] ( #3B )
    COP [PrintWideString] ( &widestring_0ACE09 )
    COP [LoopInit] ( #30 )
    LDA $cameraBoundsY
    INC 
    STA $cameraBoundsY
    COP [LoopNext]
    LDA #$0170
    STA $cameraBoundsY
    COP [SetSolidAbs] ( #07, #0C, #08 )
    COP [SetEntryContinue]
    LDA $slopeStepCounter
    CMP #$0018
    BEQ loc_0ACDBE
    RTL 

  loc_0ACDBE:
    LDA #$0000
    STA $0AA6
    STA $0688
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #58, #$0000, #$0000, #03, #$1100 )
    COP [SetEntryContinue]
    RTL 
}

widestring_0ACDDA `[DEF][TPL:0]きょだいな鳥を たおすと[N]しかばねから ミステリードールが[N]見つかった!![PAL:0][END]`

widestring_0ACE09 `[DEF][TPL:0]プロペラ音と ともに 拡声器から[N]ニールのさけび声が ひびく![FIN][TPL:6]ニール:[N]テムーっ![N]地上が 近いぞーっ!!!!![FIN]エアプレインで 受けとめるから[N]そこから 飛びおりるんだっ!![PAL:0][END]`

actor_def_0ACE80 [
  actor-def < #0A, #01, #03, {

  code_0ACE83:
    COP [ClearAllHere]
    COP [SetEntryContinue]
    COP [BranchOnPlayerY] ( #$0020, &code_0ACE92, &code_0ACE91, &code_0ACE91 )
} >
]

code_0ACE91 {
    RTL 
}

code_0ACE92 {
    COP [SolidHighHere]
    COP [StageSpriteFrame] ( #0B )
    COP [AnimOnce]
    COP [Die]

  code_0ACE9B:
    COP [SpawnBeforeFlags] ( @chunk_008000.code_00EA82, #$2800 )
    LDA #$0201
    STA $0014, Y
    LDA #$0000
    STA $0016, Y
    LDA $24
    STA $orbitAngle, X
    COP [WaitByte] ( #02 )
    COP [InitGravity] ( #00, #09, #00 )
    COP [SetEntryExit]
    COP [TickGravity]
    LDA $moveScratch2, X
    LDY $04
    STA $0016, Y
    CMP #$000C
    BCS code_0ACECF
    RTL 
}

code_0ACECF {
    COP [SpawnAfterFlags] ( @chunk_058000.code_05FD38, #$2B00 )
    COP [LoopInit] ( #04 )
    COP [RngByte]
    COP [SpawnAfterFlags] ( @code_0ACF15, #$0B01 )
    LDA $0410
    AND #$0033
    STA $08
    COP [LoopNext]
    COP [SpawnAfterFlags] ( @code_0ACEFB, #$0B02 )
    COP [RngByte]
    AND #$0070
    STA $08
    RTL 
}

code_0ACEFB {
    JSR $&code_0ACF40
    INC 
    INC 
    ASL 
    STA $moveYAlt, X
    COP [SetSpritePriority] ( #30 )

  loc_0ACF08:
    COP [ReloadForceMove]
    COP [StageSpriteFrame] ( #06 )
    COP [AnimOnce]
    LDA $16
    BPL loc_0ACF08
    COP [Die]
}

code_0ACF15 {
    JSR $&code_0ACF40
    ASL 
    STA $moveYAlt, X
    COP [SetSpritePriority] ( #20 )
    LDA $0036
    LSR 
    BCS loc_0ACF33

  loc_0ACF26:
    COP [ReloadForceMove]
    COP [StageSpriteFrame] ( #07 )
    COP [AnimOnce]
    LDA $16
    BPL loc_0ACF26
    COP [Die]

  loc_0ACF33:
    COP [ReloadForceMove]
    COP [StageSpriteFrame] ( #08 )
    COP [AnimOnce]
    LDA $16
    BPL loc_0ACF33
    COP [Die]
}

code_0ACF40 {
    LDA #$0000
    STA $moveXAlt, X
    LDA $bg2ScrollH
    CLC 
    ADC #$00FF
    STA $16
    LDA $bg1ScrollH
    CLC 
    ADC #$0080
    STA $14
    COP [RngByte]
    SEC 
    SBC #$0080
    CLC 
    ADC $14
    STA $14
    LDA $0410
    AND #$0003
    BNE loc_0ACF6F
    LDA #$0003

  loc_0ACF6F:
    RTS 
}

actor_def_0ACF70 [
  actor-def < #00, #00, #00, {

  code_0ACF73:
    LDA #$0011
    TSB $12
    LDA #$0100
    STA $cameraBoundsY
    COP [SpawnLastRel] ( @code_0ACFC0, #00, #00, #$2000 )
    LDA $characterForm
    CMP #$0002
    BNE loc_0ACF92
    JMP $&code_0AD070

  loc_0ACF92:
    LDY $decelStepCounter
    LDA #$0088
    STA $0002, Y
    LDA #$EE8C
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $slopeCurvePtrB
    COP [SetEntryContinue]
    LDA $slopeCurvePtrB
    BIT #$0800
    BEQ loc_0ACFB8
    RTL 

  loc_0ACFB8:
    COP [SetDeathCallback] ( @code_0AD7D4 )
    JMP $&code_0AD070
} >
]

code_0ACFC0 {
    COP [SetEntryContinue]
    LDA $0AEC
    BEQ loc_0ACFC8
    RTL 

  loc_0ACFC8:
    LDY $decelStepCounter
    LDA #$0088
    STA $0002, Y
    LDA #$EC9E
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $slopeCurvePtrB
    COP [SetEntryContinue]
    LDA $slopeCurvePtrB
    BIT #$0800
    BEQ loc_0ACFEE
    RTL 

  loc_0ACFEE:
    COP [SetFlagWord] ( #$0176 )
    LDA #$0003
    STA $gfxCacheIdxA
    LDA #$0403
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #E0, #$03F8, #$02A0, #03, #$3820 )
    COP [Die]
}

actor_def_0AD00A [
  actor-def < #00, #00, #00, {

  code_0AD00D:
    LDA #$0001
    JSL $@chunk_008000.code_00B10F
    BCC loc_0AD01E
    STZ $0AEC
    STZ $0AEE
    COP [Die]

  loc_0AD01E:
    LDA #$0011
    TSB $12
    COP [SetDeathCallback] ( @code_0AD7D4 )
    LDA #$008A
    AND #$00FF
    STA $0AF6
    LDA #$D7CC
    STA $0AF4
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #01 )
    COP [StartMusic] ( #0F )
    COP [WaitByte] ( #27 )
    LDA #$EFF0
    TRB $joypadMaskStd
    COP [SetEntryContinue]
    LDA $playerSpeedEw
    CMP #$00A0
    BCC loc_0AD057
    RTL 

  loc_0AD057:
    LDA #$0130
    STA $cameraBoundsY
    COP [LoopInit] ( #30 )
    LDA $cameraBoundsY
    DEC 
    STA $cameraBoundsY
    COP [LoopNext]
    COP [SpawnBeforeFlags] ( @code_0ACE9B, #$2800 )
} >
]

code_0AD070 {
    COP [SpawnAfter] ( @code_0AD119 )
    LDA #$FFD0
    STA $0018, Y
    LDA #$0030
    STA $001C, Y
    LDA #$0000
    STA $001A, Y
    LDA #$0080
    STA $001E, Y
    LDA #$0001
    STA $0028, Y
    LDA #$0000
    STA $002C, Y
    LDA #$0006
    STA $002E, Y

  code_0AD09F:
    LDA #$0010
    STA $24
    COP [CallScript] ( &code_0AD195 )
    STZ $24
    COP [CallScript] ( &code_0AD169 )
    COP [CallScript] ( &code_0AD20F )
    STZ $24
    COP [CallScript] ( &code_0AD169 )
    STZ $24
    COP [CallScript] ( &code_0AD195 )
    LDA #$FFA0
    STA $24
    COP [CallScript] ( &code_0AD195 )
    LDA #$FFD0
    STA $24
    COP [CallScript] ( &code_0AD169 )
    COP [InitGravity] ( #00, #09, #00 )
    COP [StageSprAndHitbox] ( #00 )

  loc_0AD0D8:
    COP [TickGravity]
    COP [SetEntryExit]
    LDA $16
    BMI loc_0AD0D8
    CMP #$0030
    BCC loc_0AD0D8
    COP [StageSpriteMoveY] ( #00, #03 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveY] ( #01, #02, #13 )
    COP [AnimLoop]
    COP [SetSavedPtr] ( &code_0AD100 )
    COP [BranchOnPlayerX] ( #$0020, &code_0AD4EE, &code_0AD4CC, &code_0AD515 )
}

code_0AD100 {
    STZ $24
    COP [CallScript] ( &code_0AD195 )
    STZ $24
    COP [CallScript] ( &code_0AD169 )
    COP [CallScript] ( &code_0AD342 )
    COP [StageSpriteLoop] ( #00, #02 )
    COP [AnimLoop]
    JMP $&code_0AD09F
}

code_0AD119 {
    LDY $24
    LDA $0028, Y
    CMP $28
    BNE loc_0AD168
    LDA $0014, Y
    SEC 
    SBC #$0008
    CLC 
    ADC $18
    CMP $playerWallType
    BCS loc_0AD168
    SEC 
    SBC $18
    CLC 
    ADC $1C
    CMP $playerWallType
    BCC loc_0AD168
    LDA $0016, Y
    SEC 
    SBC #$0010
    CLC 
    ADC $1A
    CMP $playerSpeedEw
    BCS loc_0AD168
    SEC 
    SBC $1A
    CLC 
    ADC $1E
    CMP $playerSpeedEw
    BCC loc_0AD168
    LDA $2C
    CLC 
    ADC $extVelocityX
    STA $extVelocityX
    LDA $2E
    CLC 
    ADC $extVelocityY
    STA $extVelocityY

  loc_0AD168:
    RTL 
}

code_0AD169 {
    COP [RngByte]
    AND #$003F
    SEC 
    SBC #$001F
    CLC 
    ADC $playerWallType
    STA $moveXAlt, X
    LDA $0410
    AND #$001F
    SEC 
    SBC #$000F
    CLC 
    ADC #$0050
    CLC 
    ADC $24
    STA $moveYAlt, X
    COP [MoveToward] ( #00, #04 )
    COP [RestoreSavedPtr]
}

code_0AD195 {
    LDA $16
    CLC 
    ADC $24
    STA $7F100E, X
    LDA #$0000
    STA $orbitAngle, X
    COP [BranchOnPlayerX] ( #$0000, &code_0AD1AF, &code_0AD1AF, &code_0AD1B4 )
}

code_0AD1AF {
    LDA #$4000
    TSB $12
}

code_0AD1B4 {
    LDA #$2000
    TSB $12
    LDY $decelStepCounter
    LDA $0014, Y
    SEC 
    SBC $14
    BPL loc_0AD1C8
    EOR #$FFFF
    INC 

  loc_0AD1C8:
    LSR 
    LSR 
    LSR 
    LSR 
    LSR 
    AND #$0003
    INC 
    STA $26
    COP [StageSpriteLoop] ( #01, #02 )
    COP [AnimLoop]
    COP [InitGravity] ( #03, #09, #00 )
    COP [StageSprAndHitbox] ( #00 )

  loc_0AD1E1:
    COP [SetEntryExit]
    LDA $26
    STA $moveScratch1, X
    COP [TickGravity]
    LDA $orbitAngle, X
    DEC 
    BPL loc_0AD1FA
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $08
    STZ $08

  loc_0AD1FA:
    STA $orbitAngle, X
    LDA $16
    BMI loc_0AD208
    CMP $7F100E, X
    BCS loc_0AD1E1

  loc_0AD208:
    LDA #$6000
    TRB $12
    COP [RestoreSavedPtr]
}

code_0AD20F {
    COP [StageSpriteLoop] ( #01, #03 )
    COP [AnimLoop]
    COP [StageForceMoveY] ( #13 )
    COP [WaitByte] ( #27 )
    COP [StageForceMoveY] ( #00 )
    COP [SpawnAfterFlags] ( @code_0AD227, #$0200 )
    COP [RestoreSavedPtr]
}

code_0AD227 {
    COP [PlaySoundCh1] ( #1E )
    LDA $playerWallType
    STA $moveXAlt, X
    LDA $playerSpeedEw
    STA $moveYAlt, X
    COP [MoveToward] ( #05, #02 )
    COP [LoopInit] ( #0A )
    COP [SetSpritePalette] ( #08 )
    COP [SetEntryExit]
    COP [SetSpritePalette] ( #00 )
    COP [LoopNext]
    COP [PlaySoundCh1] ( #1D )
    COP [SpawnAfterFlags] ( @code_0AD275, #$0200 )
    COP [SpawnAfterFlags] ( @code_0AD2E0, #$0200 )
    COP [SpawnAfterFlags] ( @code_0AD26C, #$0200 )
    COP [SpawnAfterFlags] ( @code_0AD2D7, #$0200 )
    COP [SetEntryExit]
    COP [Die]
}

code_0AD26C {
    COP [SetHFlip]
    COP [ToggleVFlip]
    LDA #$6002
    TSB $12
}

code_0AD275 {
    COP [OrActorFlags] ( #$0010 )
    LDY $24
    LDA $002A, Y
    DEC 
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0AD28B )
}

code_list_0AD28B [
  &code_0AD293   ;00
  &code_0AD2A4   ;01
  &code_0AD2B5   ;02
  &code_0AD2C6   ;03
]

code_0AD293 {
    COP [StageSpriteLoopMoveXY] ( #1D, #20, #02, #00 )
    COP [AnimLoop]
    LDA $10
    BIT #$4000
    BEQ code_0AD293
    COP [Die]
}

code_0AD2A4 {
    COP [StageSpriteLoopMoveXY] ( #1E, #20, #17, #14 )
    COP [AnimLoop]
    LDA $10
    BIT #$4000
    BEQ code_0AD2A4
    COP [Die]
}

code_0AD2B5 {
    COP [StageSpriteLoopMoveXY] ( #1F, #20, #12, #12 )
    COP [AnimLoop]
    LDA $10
    BIT #$4000
    BEQ code_0AD2B5
    COP [Die]
}

code_0AD2C6 {
    COP [StageSpriteLoopMoveXY] ( #20, #20, #14, #17 )
    COP [AnimLoop]
    LDA $10
    BIT #$4000
    BEQ code_0AD2C6
    COP [Die]
}

code_0AD2D7 {
    COP [SetHFlip]
    COP [ToggleVFlip]
    LDA #$6002
    TSB $12
}

code_0AD2E0 {
    COP [OrActorFlags] ( #$0010 )
    LDY $24
    LDA $002A, Y
    DEC 
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0AD2F6 )
}

code_list_0AD2F6 [
  &code_0AD2FE   ;00
  &code_0AD30F   ;01
  &code_0AD320   ;02
  &code_0AD331   ;03
]

code_0AD2FE {
    COP [StageSpriteLoopMoveXY] ( #19, #20, #00, #01 )
    COP [AnimLoop]
    LDA $10
    BIT #$4000
    BEQ code_0AD2FE
    COP [Die]
}

code_0AD30F {
    COP [StageSpriteLoopMoveXY] ( #1A, #20, #14, #16 )
    COP [AnimLoop]
    LDA $10
    BIT #$4000
    BEQ code_0AD30F
    COP [Die]
}

code_0AD320 {
    COP [StageSpriteLoopMoveXY] ( #1B, #20, #12, #11 )
    COP [AnimLoop]
    LDA $10
    BIT #$4000
    BEQ code_0AD320
    COP [Die]
}

code_0AD331 {
    COP [StageSpriteLoopMoveXY] ( #1C, #20, #17, #13 )
    COP [AnimLoop]
    LDA $10
    BIT #$4000
    BEQ code_0AD331
    COP [Die]
}

code_0AD342 {
    LDY $decelStepCounter
    LDA $0014, Y
    SEC 
    SBC $14
    STA $orbitAngle, X
    COP [StageSpriteLoop] ( #01, #03 )
    COP [AnimLoop]
    LDA #$0000

  loc_0AD358:
    STA $24
    COP [SpawnAfterFlags] ( @code_0AD37D, #$2200 )
    TXA 
    TYX 
    TAY 
    LDA $24
    STA $orbitAngle, X
    TXA 
    TYX 
    TAY 
    LDA $24
    INC 
    CMP #$0006
    BCC loc_0AD358
    LDA $orbitAngle, X
    STA $24
    COP [RestoreSavedPtr]
}

code_0AD37D {
    COP [PlaySoundCh1] ( #1E )
    COP [OrActorFlags] ( #$0010 )
    LDA $orbitAngle, X
    CMP #$0006
    BCC loc_0AD390
    LDA #$0005

  loc_0AD390:
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0AD399 )
}

code_list_0AD399 [
  &code_0AD3A5   ;00
  &code_0AD3AE   ;01
  &code_0AD3B7   ;02
  &code_0AD3C0   ;03
  &code_0AD3C9   ;04
  &code_0AD3D2   ;05
]

code_0AD3A5 {
    COP [AddPosition] ( #10, #E0 )
    LDA #$0020
    BRA loc_0AD3D9
}

code_0AD3AE {
    COP [AddPosition] ( #F0, #E0 )
    LDA #$0040
    BRA loc_0AD3D9
}

code_0AD3B7 {
    COP [AddPosition] ( #20, #E0 )
    LDA #$0030
    BRA loc_0AD3D9
}

code_0AD3C0 {
    COP [AddPosition] ( #E0, #E0 )
    LDA #$0030
    BRA loc_0AD3D9
}

code_0AD3C9 {
    COP [AddPosition] ( #30, #E0 )
    LDA #$0040
    BRA loc_0AD3D9
}

code_0AD3D2 {
    COP [AddPosition] ( #D0, #E0 )
    LDA #$0020

  loc_0AD3D9:
    STA $7F100E, X
    COP [SetEntryExit]
    LDA #$2000
    TRB $10
    LDY $24
    LDA $0024, Y
    BPL loc_0AD3F4
    COP [ClearHFlip]
    LDA #$4000
    TSB $12
    BRA loc_0AD3FB

  loc_0AD3F4:
    COP [SetHFlip]
    LDA #$0002
    TSB $12

  loc_0AD3FB:
    LDA $7F100E, X
    TAY 
    LDA #$0005
    SEP #$20
    JSL $@chunk_028000.code_02830D
    REP #$20
    AND #$00FF
    STA $orbitAngle, X
    STA $orbitDiameter, X
    COP [StageSprAndHitbox] ( #19 )
    LDA #$0000
    STA $7F100C, X
    STA $scratch1010, X
    STA $scratch1010+2, X
    COP [SetEntryContinue]
    LDA $7F100E, X
    BEQ loc_0AD461
    DEC 
    STA $7F100E, X
    LDA $7F100C, X
    INC 
    STA $7F100C, X
    LDA $orbitDiameter, X
    DEC 
    STA $orbitDiameter, X
    BNE loc_0AD461
    LDA $orbitAngle, X
    STA $orbitDiameter, X
    LDA $28
    INC 
    CMP #$001E
    BCS loc_0AD461
    STA $28
    STZ $2A
    JSL $@chunk_3B7DD.code_03C761

  loc_0AD461:
    LDA $7F100C, X
    CLC 
    ADC $scratch1010, X
    STA $scratch1010, X
    LSR 
    LSR 
    LSR 
    LSR 
    STA $moveScratch1, X
    ASL 
    ASL 
    ASL 
    ASL 
    SEC 
    SBC $scratch1010, X
    EOR #$FFFF
    INC 
    STA $scratch1010, X
    LDA $7F100E, X
    CLC 
    ADC $scratch1010+2, X
    STA $scratch1010+2, X
    LSR 
    LSR 
    LSR 
    LSR 
    STA $moveScratch2, X
    ASL 
    ASL 
    ASL 
    ASL 
    SEC 
    SBC $scratch1010+2, X
    EOR #$FFFF
    INC 
    STA $scratch1010+2, X
    LDA $0036
    LSR 
    BCC loc_0AD4B8
    COP [SetSpritePalette] ( #08 )
    BRA loc_0AD4BB

  loc_0AD4B8:
    COP [SetSpritePalette] ( #00 )

  loc_0AD4BB:
    LDA $14
    BMI loc_0AD4CA
    SEC 
    SBC $cameraBoundsX
    CLC 
    ADC #$0010
    BPL loc_0AD4CA
    RTL 

  loc_0AD4CA:
    COP [Die]
}

code_0AD4CC {
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [SpawnMarkedAfterRel] ( @code_0AD608, #00, #D8, #$0202 )
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [SpawnMarkedAfterRel] ( @code_0AD6D7, #00, #F2, #$0202 )
    COP [SetHitCallback] ( &code_0AD585 )
    BRA loc_0AD53A
}

code_0AD4EE {
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    COP [SpawnMarkedAfterRel] ( @code_0AD669, #E8, #CD, #$0202 )
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    COP [SpawnMarkedAfterRel] ( @code_0AD70F, #E4, #EA, #$0202 )
    COP [SetHitCallback] ( &code_0AD54B )
    BRA loc_0AD53A
}

code_0AD515 {
    COP [StageSpriteFrame] ( #84 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #83 )
    COP [AnimOnce]
    COP [SpawnMarkedAfterRel] ( @code_0AD658, #18, #CD, #$0202 )
    COP [StageSpriteFrame] ( #83 )
    COP [AnimOnce]
    COP [SpawnMarkedAfterRel] ( @code_0AD747, #1C, #EA, #$0202 )
    COP [SetHitCallback] ( &code_0AD568 )

  loc_0AD53A:
    LDA #$0003
    STA $sprTimer, X
    COP [SetEntryContinue]
    COP [AnimLoop]
    COP [SetHitCallback] ( #$0000 )
    COP [RestoreSavedPtr]
}

code_0AD54B {
    COP [BranchOnPlayerX] ( #$0020, &code_0AD5E0, &code_0AD555, &code_0AD55C )
}

code_0AD555 {
    COP [StageSpriteFrame] ( #09 )
    COP [AnimOnce]
    BRA loc_0AD59D
}

code_0AD55C {
    COP [StageSpriteFrame] ( #09 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #84 )
    COP [AnimOnce]
    BRA loc_0AD5B4
}

code_0AD568 {
    COP [BranchOnPlayerX] ( #$0020, &code_0AD579, &code_0AD572, &code_0AD5E0 )
}

code_0AD572 {
    COP [StageSpriteFrame] ( #89 )
    COP [AnimOnce]
    BRA loc_0AD59D
}

code_0AD579 {
    COP [StageSpriteFrame] ( #89 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    BRA loc_0AD5CB
}

code_0AD585 {
    COP [BranchOnPlayerX] ( #$0020, &code_0AD58F, &code_0AD5E0, &code_0AD596 )
}

code_0AD58F {
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    BRA loc_0AD5CB
}

code_0AD596 {
    COP [StageSpriteFrame] ( #84 )
    COP [AnimOnce]
    BRA loc_0AD5B4

  loc_0AD59D:
    COP [StageSprAndHitbox] ( #02 )
    COP [SpawnMarkedAfterRel] ( @code_0AD600, #00, #D8, #$0202 )
    COP [SpawnMarkedAfterRel] ( @code_0AD6D7, #00, #F2, #$0202 )
    BRA code_0AD5E0

  loc_0AD5B4:
    COP [StageSprAndHitbox] ( #83 )
    COP [SpawnMarkedAfterRel] ( @code_0AD649, #18, #CD, #$0202 )
    COP [SpawnMarkedAfterRel] ( @code_0AD747, #1C, #EA, #$0202 )
    BRA code_0AD5E0

  loc_0AD5CB:
    COP [StageSprAndHitbox] ( #03 )
    COP [SpawnMarkedAfterRel] ( @code_0AD661, #E8, #CD, #$0202 )
    COP [SpawnMarkedAfterRel] ( @code_0AD70F, #E4, #EA, #$0202 )
}

code_0AD5E0 {
    COP [SetEntryContinue]
    COP [AnimOnce]
    LDA #$6000
    TRB $12
    LDA $14
    STA $moveXAlt, X
    LDA $cameraTargetY
    SEC 
    SBC #$0040
    STA $moveYAlt, X
    COP [MoveToward] ( #00, #04 )
    COP [RestoreSavedPtr]
}

code_0AD600 {
    LDA $24
    STA $orbitAngle, X
    BRA loc_0AD62B
}

code_0AD608 {
    LDA $24
    STA $orbitAngle, X
    COP [StageSprAndHitbox] ( #24 )
    COP [LoopInit] ( #30 )
    JSR $&code_0AD6C1
    BCC loc_0AD61C
    JMP $&code_0AD6A7

  loc_0AD61C:
    COP [LoopNext]
    LDA #$2000
    TSB $10
    COP [WaitByte] ( #17 )
    LDA #$2000
    TRB $10

  loc_0AD62B:
    COP [StageSprAndHitbox] ( #25 )
    STZ $24

  loc_0AD630:
    COP [SetEntryContinue]
    JSR $&code_0AD6C1
    BCS code_0AD6A7
    DEC $24
    BMI loc_0AD63C
    RTL 

  loc_0AD63C:
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $08
    INC 
    STA $24
    STZ $08
    BRA loc_0AD630
}

code_0AD649 {
    LDA #$0002
    TSB $12
    COP [SetHFlip]
    LDA $24
    STA $orbitAngle, X
    BRA loc_0AD689
}

code_0AD658 {
    LDA #$0002
    TSB $12
    COP [SetHFlip]
    BRA code_0AD669
}

code_0AD661 {
    LDA $24
    STA $orbitAngle, X
    BRA loc_0AD689
}

code_0AD669 {
    LDA $24
    STA $orbitAngle, X
    COP [StageSprAndHitbox] ( #26 )
    COP [LoopInit] ( #30 )
    JSR $&code_0AD6C1
    BCS code_0AD6A7
    COP [LoopNext]
    LDA #$2000
    TSB $10
    COP [WaitByte] ( #17 )
    LDA #$2000
    TRB $10

  loc_0AD689:
    COP [StageSprAndHitbox] ( #27 )
    STZ $24

  loc_0AD68E:
    COP [SetEntryContinue]
    JSR $&code_0AD6C1
    BCS code_0AD6A7
    DEC $24
    BMI loc_0AD69A
    RTL 

  loc_0AD69A:
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $08
    INC 
    STA $24
    STZ $08
    BRA loc_0AD68E
}

code_0AD6A7 {
    COP [Die]

  code_0AD6A9:
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $08
    STA $24
    STZ $08
    COP [SetEntryExit]
    JSR $&code_0AD6C1
    BCS code_0AD6A7
    DEC $24
    BMI loc_0AD6BF
    RTL 

  loc_0AD6BF:
    COP [RestoreSavedPtr]
}

code_0AD6C1 {
    LDA $orbitAngle, X
    TAY 
    LDA $0028, Y
    CMP #$0002
    BEQ loc_0AD6D3
    CMP #$0003
    BNE loc_0AD6D5

  loc_0AD6D3:
    CLC 
    RTS 

  loc_0AD6D5:
    SEC 
    RTS 
}

code_0AD6D7 {
    COP [StageSpriteFrame] ( #0C )
    COP [AnimOnce]
    LDA $24
    STA $orbitAngle, X
    LDA #$0000
    STA $orbitDiameter, X
    COP [PlaySoundCh1] ( #21 )
    COP [StageSprAndHitbox] ( #0D )

  loc_0AD6EF:
    COP [LoopInit] ( #04 )
    COP [CallScript] ( &code_0AD6A9 )
    COP [LoopNext]
    LDA $orbitDiameter, X
    INC 
    STA $orbitDiameter, X
    LSR 
    BCC loc_0AD6EF
    COP [SpawnLastRel] ( @code_0AD786, #00, #30, #$0200 )
    BRA loc_0AD6EF
}

code_0AD70F {
    COP [StageSpriteFrame] ( #0E )
    COP [AnimOnce]
    LDA #$0000
    STA $orbitDiameter, X
    LDA $24
    STA $orbitAngle, X
    COP [PlaySoundCh1] ( #21 )
    COP [StageSprAndHitbox] ( #0F )

  loc_0AD727:
    COP [LoopInit] ( #04 )
    COP [CallScript] ( &code_0AD6A9 )
    COP [LoopNext]
    LDA $orbitDiameter, X
    INC 
    STA $orbitDiameter, X
    LSR 
    BCC loc_0AD727
    COP [SpawnLastRel] ( @code_0AD786, #C0, #20, #$0200 )
    BRA loc_0AD727
}

code_0AD747 {
    LDA #$0002
    TSB $12
    COP [SetHFlip]
    COP [StageSpriteFrame] ( #0E )
    COP [AnimOnce]
    LDA #$0000
    STA $orbitDiameter, X
    LDA $24
    STA $orbitAngle, X
    COP [PlaySoundCh1] ( #21 )
    COP [StageSprAndHitbox] ( #0F )

  loc_0AD766:
    COP [LoopInit] ( #04 )
    COP [CallScript] ( &code_0AD6A9 )
    COP [LoopNext]
    LDA $orbitDiameter, X
    INC 
    STA $orbitDiameter, X
    LSR 
    BCC loc_0AD766
    COP [SpawnLastRel] ( @code_0AD786, #40, #20, #$0200 )
    BRA loc_0AD766
}

code_0AD786 {
    COP [OrActorFlags] ( #$0010 )
    LDA #$0000
    STA $moveYAlt, X
    COP [RngByte]
    AND #$0007
    CMP #$0007
    BNE loc_0AD79E
    LDA #$0003

  loc_0AD79E:
    STA $moveXAlt, X
    LSR 
    LDA #$0000
    ADC #$0021
    STA $28
    STZ $2A
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    COP [ReloadForceMove]
    COP [SetEntryExit]
    COP [InitGravity] ( #03, #04, #01 )
    COP [SetEntryContinue]
    COP [TickGravity]
    CMP #$0000
    BMI loc_0AD7C4
    RTL 

  loc_0AD7C4:
    COP [StageSpriteLoop] ( #23, #04 )
    COP [AnimLoop]
    COP [Die]

  loc_0AD7CC:
    JMP $00F8
    BMI loc_0AD7D1

  loc_0AD7D1:
    BRK #$00
    JSL $@chunk_098000.code_09BCAD
    BIT #$0200
    BEQ loc_0AD7DF
    COP [SetEntryContinue]
    RTL 

  loc_0AD7DF:
    LDA #$0020
    TSB $slopeCurvePtrB
    COP [SpawnLastRel] ( @code_0AA2B1, #00, #00, #$2000 )
    COP [SpawnLastRel] ( @code_0AD7FF, #00, #00, #$2300 )
    COP [WaitByte] ( #27 )
    COP [JumpScript] ( @chunk_008000.code_00DCA9 )
}

code_0AD7FF {
    COP [SetMetasprite] ( @table_0EE000 )
    COP [LoopInit] ( #0A )
    COP [SpawnLastRel] ( @code_0AD823, #00, #E0, #$0302 )
    COP [WaitByte] ( #01 )
    COP [SpawnLastRel] ( @code_0AD830, #00, #E0, #$0302 )
    COP [WaitByte] ( #02 )
    COP [LoopNext]
    COP [Die]
}

code_0AD823 {
    JSR $&code_0AD83A
    COP [PlaySoundCh1] ( #06 )
    COP [StageSpriteFrame] ( #07 )
    COP [AnimOnce]
    COP [Die]
}

code_0AD830 {
    JSR $&code_0AD83A
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    COP [Die]
}

code_0AD83A {
    COP [RngByte]
    COP [RngByte]
    COP [RngMod] ( #50 )
    LDA $rngModuloResult
    SEC 
    SBC #$0028
    CLC 
    ADC $14
    STA $14
    COP [RngByte]
    COP [RngByte]
    COP [RngMod] ( #60 )
    LDA $rngModuloResult
    SEC 
    SBC #$0030
    CLC 
    ADC $16
    STA $16
    RTS 
}

code_0AD861 {
    COP [LoopInit] ( #19 )
    COP [SetSpritePalette] ( #02 )
    COP [SetEntryExit]
    COP [SetSpritePalette] ( #00 )
    COP [LoopNext]
    COP [LoopInit] ( #0F )
    COP [SetSpritePalette] ( #02 )
    COP [WaitByte] ( #01 )
    COP [SetSpritePalette] ( #00 )
    COP [LoopNext]
    COP [SetSpritePalette] ( #02 )
    COP [RestoreSavedPtr]
}

code_0AD881 {
    COP [LoopInit] ( #19 )
    COP [SetSpritePalette] ( #04 )
    COP [SetEntryExit]
    COP [SetSpritePalette] ( #00 )
    COP [LoopNext]
    COP [LoopInit] ( #0F )
    COP [SetSpritePalette] ( #04 )
    COP [WaitByte] ( #01 )
    COP [SetSpritePalette] ( #00 )
    COP [LoopNext]
    COP [SetSpritePalette] ( #04 )
    COP [RestoreSavedPtr]
}

code_0AD8A1 {
    COP [LoopInit] ( #19 )
    COP [SetSpritePalette] ( #00 )
    COP [SetEntryExit]
    COP [SetSpritePalette] ( #02 )
    COP [LoopNext]
    COP [LoopInit] ( #0F )
    COP [SetSpritePalette] ( #00 )
    COP [WaitByte] ( #01 )
    COP [SetSpritePalette] ( #02 )
    COP [LoopNext]
    COP [SetSpritePalette] ( #00 )
    COP [RestoreSavedPtr]
}

code_0AD8C1 {
    COP [LoopInit] ( #19 )
    COP [SetSpritePalette] ( #00 )
    COP [SetEntryExit]
    COP [SetSpritePalette] ( #04 )
    COP [LoopNext]
    COP [LoopInit] ( #0F )
    COP [SetSpritePalette] ( #00 )
    COP [WaitByte] ( #01 )
    COP [SetSpritePalette] ( #04 )
    COP [LoopNext]
    COP [SetSpritePalette] ( #00 )
    COP [RestoreSavedPtr]
}

code_0AD8E1 {
    COP [CallScript] ( &code_0AD9A8 )
    COP [ToggleVFlip]
    COP [StageSpriteFrame] ( #2E )
    COP [AnimOnce]

  loc_0AD8EC:
    COP [StageSpriteMoveY] ( #2B, #0B )
    COP [AnimOnce]
    COP [CallScript] ( &code_0AD9BC )
    BRA loc_0AD8EC
}

code_0AD8F8 {
    COP [CallScript] ( &code_0AD9A8 )
    COP [ToggleVFlip]
    COP [StageSpriteFrame] ( #30 )
    COP [AnimOnce]

  loc_0AD903:
    COP [StageSpriteMoveXY] ( #2D, #0A, #09 )
    COP [AnimOnce]
    COP [CallScript] ( &code_0AD9BC )
    BRA loc_0AD903
}

code_0AD910 {
    COP [CallScript] ( &code_0AD9A8 )
    LDA #$0002
    TSB $12
    COP [SetHFlip]
    COP [ToggleVFlip]
    COP [StageSpriteFrame] ( #30 )
    COP [AnimOnce]

  loc_0AD922:
    COP [StageSpriteMoveXY] ( #2D, #09, #09 )
    COP [AnimOnce]
    COP [CallScript] ( &code_0AD9BC )
    BRA loc_0AD922
}

code_0AD92F {
    COP [CallScript] ( &code_0AD9A8 )
    COP [StageSpriteFrame] ( #2F )
    COP [AnimOnce]

  loc_0AD938:
    COP [StageSpriteMoveX] ( #2C, #0C )
    COP [AnimOnce]
    COP [CallScript] ( &code_0AD9BC )
    BRA loc_0AD938
}

code_0AD944 {
    COP [CallScript] ( &code_0AD9A8 )
    LDA #$0002
    TSB $12
    COP [SetHFlip]
    COP [StageSpriteFrame] ( #2F )
    COP [AnimOnce]

  loc_0AD954:
    COP [StageSpriteMoveX] ( #2C, #0B )
    COP [AnimOnce]
    COP [CallScript] ( &code_0AD9BC )
    BRA loc_0AD954
}

code_0AD960 {
    COP [CallScript] ( &code_0AD9A8 )
    COP [StageSpriteFrame] ( #30 )
    COP [AnimOnce]

  loc_0AD969:
    COP [StageSpriteMoveXY] ( #2D, #0A, #0A )
    COP [AnimOnce]
    COP [CallScript] ( &code_0AD9BC )
    BRA loc_0AD969
}

code_0AD976 {
    COP [CallScript] ( &code_0AD9A8 )
    LDA #$0002
    TSB $12
    COP [SetHFlip]
    COP [StageSpriteFrame] ( #30 )
    COP [AnimOnce]

  loc_0AD986:
    COP [StageSpriteMoveXY] ( #2D, #09, #0A )
    COP [AnimOnce]
    COP [CallScript] ( &code_0AD9BC )
    BRA loc_0AD986
}

code_0AD993 {
    COP [CallScript] ( &code_0AD9A8 )
    COP [StageSpriteFrame] ( #2E )
    COP [AnimOnce]

  loc_0AD99C:
    COP [StageSpriteMoveY] ( #2B, #0C )
    COP [AnimOnce]
    COP [CallScript] ( &code_0AD9BC )
    BRA loc_0AD99C
}

code_0AD9A8 {
    COP [SetSpritePriority] ( #30 )
    COP [SetMetasprite] ( @table_0EE000 )
    COP [SetEntryExit]
    LDA #$2000
    TRB $10
    COP [PlaySoundCh1] ( #20 )
    COP [RestoreSavedPtr]
}

code_0AD9BC {
    LDA $10
    BIT #$4000
    BNE loc_0AD9C5
    COP [RestoreSavedPtr]

  loc_0AD9C5:
    COP [Die]

  loc_0AD9C7:
    BRK #$00
    JSR $20E2
    LDA #$8DA0
    AND $21
    REP #$20
    RTL 
}

code_0AD9D4 {
    COP [OrActorFlags] ( #$0010 )
    COP [CallScript] ( &code_0ADAB4 )
    LDA $decelStepCounter
    STA $24
    LDA #$0008
    STA $0028, X
    LDA #$0002
    STA $loopCounter, X
    SEP #$20
    LDA #$80
    PHA 
    REP #$20
    LDA #$E5D1
    PHA 
    RTL 
}

code_0AD9FA {
    COP [OrActorFlags] ( #$0010 )
    COP [CallScript] ( &code_0ADAB4 )
    LDA #$8008
    STA $chatPtr, X
    LDA #$0001
    STA $loopCounter, X
    COP [SpawnMarkedAfter] ( @chunk_008000.code_00E79D, #$2000 )
    LDA $decelStepCounter
    STA $0024, Y
    COP [SetEntryExit]
    LDA #$003B
    STA $24
    LDA $14
    STA $7F100C, X
    LDA $16
    STA $7F100E, X
    COP [LoopInit] ( #1E )
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    JSR $&code_0ADBB6
    BCC loc_0ADA40
    COP [BranchIfBehindWall] ( &code_0ADADB )

  loc_0ADA40:
    COP [LoopNext]
    COP [CollPriorityClearMax]
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    DEC $24
    BMI loc_0ADA57
    JSR $&code_0ADBB6
    BCS loc_0ADA52
    RTL 

  loc_0ADA52:
    COP [BranchIfBehindWall] ( &code_0ADADB )
    RTL 

  loc_0ADA57:
    PHX 
    LDX $06
    LDA $moveScratch1, X
    STA $0000
    LDA $moveScratch2, X
    PLX 
    STA $orbitDiameter, X
    LDA $0000
    STA $orbitAngle, X
    ORA $orbitDiameter, X
    BNE loc_0ADA7E
    LDA #$0001
    STA $orbitAngle, X

  loc_0ADA7E:
    COP [KillNext]

  loc_0ADA80:
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $orbitAngle, X
    STA $moveScratch1, X
    LDA $orbitDiameter, X
    STA $moveScratch2, X
    DEC $24
    BMI loc_0ADA80
    JSR $&code_0ADBB6
    BCC loc_0ADAAA
    COP [BranchIfBehindWall] ( &code_0ADADD )

  loc_0ADAAA:
    LDA $10
    BIT #$4000
    BNE loc_0ADAB2
    RTL 

  loc_0ADAB2:
    COP [Die]
}

code_0ADAB4 {
    COP [SetMetasprite] ( @table_0EE000 )
    COP [SpawnLastRel] ( @code_0ADAD4, #00, #00, #$0202 )
    COP [PlaySoundCh1] ( #1E )
    LDA #$0080
    TSB $12
    COP [StageSpriteFrame] ( #08 )
    COP [AnimOnce]
    COP [WaitByte] ( #03 )
    COP [RestoreSavedPtr]
}

code_0ADAD4 {
    COP [StageSpriteFrame] ( #07 )
    COP [AnimOnce]
    COP [Die]
}

code_0ADADB {
    COP [KillNext]
}

code_0ADADD {
    COP [StageSpriteFrame] ( #2A )
    COP [AnimOnce]
    COP [Die]
}

actor_def_0ADAE4 [
  actor-def < #00, #00, #20, {

  code_0ADAE7:
    PHX 
    SEP #$20
    LDX #$0000

  loc_0ADAED:
    LDA $@code_0ADB8D, X
    BNE loc_0ADAF8

  loc_0ADAF3:
    REP #$20
    PLX 
    COP [Die]

  loc_0ADAF8:
    CMP $sceneCurrent
    BEQ loc_0ADB04
    BCS loc_0ADAF3
    INX 
    INX 
    INX 
    BRA loc_0ADAED

  loc_0ADB04:
    REP #$20
    LDA $@code_0ADB8D+1, X
    SEC 
    SBC #$DB8D
    STA $24
    PLX 
    COP [WaitByte] ( #01 )
    PHX 
    LDX $24
    PHD 
    LDA #$0000
    TCD 
    LDA $playerSpeedNs
    STA $18
    INC 
    STA $1A
    LDA $slopeStepCounter
    STA $1C
    INC 
    STA $1E
    SEP #$20

  loc_0ADB2E:
    LDA $@code_0ADB8D, X
    BMI loc_0ADB88
    CMP $1A
    BCS loc_0ADB80
    LDA $@code_0ADB8D+1, X
    CMP $1E
    BCS loc_0ADB80
    LDA $@code_0ADB8D+2, X
    CMP $18
    BCC loc_0ADB80
    LDA $@code_0ADB8D+3, X
    CMP $1C
    BCC loc_0ADB80
    LDA $@code_0ADB8D+4, X
    REP #$20
    AND #$00FF
    BIT #$0080
    BEQ loc_0ADB61
    ORA #$FF00

  loc_0ADB61:
    CLC 
    ADC $extVelocityX
    STA $extVelocityX
    LDA $@code_0ADB8D+5, X
    AND #$00FF
    BIT #$0080
    BEQ loc_0ADB77
    ORA #$FF00

  loc_0ADB77:
    CLC 
    ADC $extVelocityY
    STA $extVelocityY
    SEP #$20

  loc_0ADB80:
    INX 
    INX 
    INX 
    INX 
    INX 
    INX 
    BRA loc_0ADB2E

  loc_0ADB88:
    REP #$20
    PLD 
    PLX 
    RTL 
} >
]

code_0ADB8D {
    EOR $94, X
    STP 
    NOP 
    TXS 
    STP 
    BRK #$02
    TSB $16
    ASL 
    BRK #$04
    ORA $07, S
    TSB $09
    BRK #$04
    ORA [$06]
    PHP 
    PHP 
    BRK #$FC
    PHD 
    ORA [$0C]
    ORA #$0400
    SBC $002E02, X
    BNE loc_0ADB51
    BPL loc_0ADBB4

  loc_0ADBB4:
    ADC $@14A560, X
    EOR $7F100C, X
    BIT #$0010
    BNE loc_0ADBDA
    LDA $16
    EOR $7F100E, X
    BIT #$0010
    BNE loc_0ADBDA
    LDA $14
    STA $7F100C, X
    LDA $16
    STA $7F100E, X
    CLC 
    RTS 

  loc_0ADBDA:
    LDA $14
    STA $7F100C, X
    LDA $16
    STA $7F100E, X
    SEC 
    RTS 
}

code_0ADBE8 {
    LDA $14
    STA $7F100C, X
    LDA $16
    STA $7F100E, X
    RTS 
}

code_0ADBF5 {
    LDA $playerWallType
    AND #$FFF0
    CLC 
    ADC #$0008
    STA $moveXAlt, X
    LDA $playerSpeedEw
    AND #$FFF0
    CLC 
    ADC #$0020
    STA $moveYAlt, X
    RTS 
}

code_0ADC12 {
    LDA $14
    SEC 
    SBC #$0008
    AND #$FFF0
    CLC 
    ADC #$0008
    STA $moveXAlt, X
    LDA $16
    AND #$FFF0
    STA $moveYAlt, X
    RTS 
}

actor_def_0ADC2D [
  actor-def < #00, #10, #01, {

  code_0ADC30:
    LDA #$0001
    STA $free101C, X
    COP [OrActorFlags] ( #$0008 )
    COP [BranchIfSolid] ( &code_0ADC8E )
    COP [AddPosition] ( #F8, #00 )
    COP [SolidHighHere]

  code_0ADC45:
    COP [WaitWhileOffscreen] ( #08 )
    COP [SetHitCallback] ( &code_0ADF90 )
    COP [WaitByte] ( #07 )
    COP [LoopInit] ( #78 )
    COP [BranchIfPlayerNear] ( #03, &code_0ADC5C )
    COP [BranchIfPlayerNear] ( #06, &code_0ADCDF )
} >
]

code_0ADC5C {
    COP [LoopNext]
    COP [SetHitCallback] ( #$0000 )
    COP [StageSpriteLoop] ( #01, #02 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    LDA #$0110
    TRB $10
    COP [ClearLowHere]

  code_0ADC74:
    COP [SetSavedPtr] ( &code_0ADCFB )
    COP [RngByte]
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0ADC86 )
}

code_list_0ADC86 [
  &code_0ADDB8   ;00
  &code_0ADDF7   ;01
  &code_0ADE49   ;02
  &code_0ADE97   ;03
]

code_0ADC8E {
    LDA #$2000
    TSB $10
    COP [SetEntryContinue]
    RTL 
}

actor_def_0ADC96 [
  actor-def < #00, #00, #01, {

  code_0ADC99:
    LDA #$0001
    STA $free101C, X
    COP [BranchIfSolid] ( &code_0ADC8E )
    COP [OrActorFlags] ( #$0008 )
    LDA #$0010
    TSB $12
    COP [AddPosition] ( #F8, #00 )
    COP [SolidHighHere]
    COP [SetHitCallback] ( &code_0ADCBB )
    COP [WaitWhileOffscreen] ( #08 )
    RTL 
} >
]

code_0ADCBB {
    LDA #$0010
    TSB $10
    LDA #$0010
    TRB $12
    COP [ClearLowHere]
    BRA code_0ADCDF

  code_0ADCC9:
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    LDA #$0110
    TSB $10
    COP [SolidHighHere]
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    COP [SetEntryExitNow] ( @code_0ADC45 )
}

code_0ADCDF {
    COP [SetHitCallback] ( #$0000 )
    COP [StageSpriteLoop] ( #01, #02 )
    COP [AnimLoop]
    COP [WaitByte] ( #27 )
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    LDA #$0110
    TRB $10
    COP [ClearLowHere]

  loc_0ADCF8:
    COP [WaitWhileOffscreen] ( #08 )
}

code_0ADCFB {
    LDA $10
    BIT #$4000
    BNE loc_0ADCF8
    COP [BranchIfPlayerNear] ( #02, &code_0ADCC9 )
    COP [BranchNearerAxis] ( &code_0ADD0D, &code_0ADD17 )
}

code_0ADD0D {
    COP [BranchOnPlayerX] ( #$0000, &code_0ADD21, &code_0ADD34, &code_0ADD34 )
}

code_0ADD17 {
    COP [BranchOnPlayerY] ( #$0000, &code_0ADD5A, &code_0ADD5A, &code_0ADD47 )
}

code_0ADD21 {
    COP [StageSpriteFrame] ( #06 )
    COP [AnimOnce]

  loc_0ADD26:
    COP [BranchIfPlayerNear] ( #05, &code_0ADD6D )
    COP [CallScriptDeferred] ( &code_0ADDB8 )
    ASL 
    BCS code_0ADCFB
    BRA loc_0ADD26
}

code_0ADD34 {
    COP [StageSpriteFrame] ( #86 )
    COP [AnimOnce]

  loc_0ADD39:
    COP [BranchIfPlayerNear] ( #05, &code_0ADD7A )
    COP [CallScriptDeferred] ( &code_0ADDF7 )
    ASL 
    BCS code_0ADCFB
    BRA loc_0ADD39
}

code_0ADD47 {
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]

  loc_0ADD4C:
    COP [BranchIfPlayerNear] ( #05, &code_0ADD88 )
    COP [CallScriptDeferred] ( &code_0ADE49 )
    ASL 
    BCS code_0ADCFB
    BRA loc_0ADD4C
}

code_0ADD5A {
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    COP [BranchIfPlayerNear] ( #05, &code_0ADD96 )
    COP [CallScriptDeferred] ( &code_0ADE97 )
    ASL 
    BCS code_0ADCFB
    BRA code_0ADD5A
}

code_0ADD6D {
    JSR $&code_0ADDA4
    COP [CallScript] ( &code_0ADF36 )
    COP [CallScriptDeferred] ( &code_0ADDB8 )
    BRA code_0ADCFB
}

code_0ADD7A {
    JSR $&code_0ADDA4
    COP [CallScript] ( &code_0ADF63 )
    COP [CallScriptDeferred] ( &code_0ADDF7 )
    JMP $&code_0ADCFB
}

code_0ADD88 {
    JSR $&code_0ADDA4
    COP [CallScript] ( &code_0ADED6 )
    COP [CallScriptDeferred] ( &code_0ADE49 )
    JMP $&code_0ADCFB
}

code_0ADD96 {
    JSR $&code_0ADDA4
    COP [CallScript] ( &code_0ADF03 )
    COP [CallScriptDeferred] ( &code_0ADE97 )
    JMP $&code_0ADCFB
}

code_0ADDA4 {
    COP [RngByte]
    AND #$0003
    BNE loc_0ADDB5
    LDA $0B02
    CLC 
    ADC #$0004
    STA $24
    RTS 

  loc_0ADDB5:
    STZ $24
    RTS 
}

code_0ADDB8 {
    COP [BranchIfSolidOffset] ( #FE, #00, &code_0ADDF5 )
    COP [BranchIfSolidOffset] ( #FE, #FF, &code_0ADDF5 )
    COP [BranchIfPlayerNear] ( #03, &code_0ADDED )
    COP [StageSpriteMoveX] ( #09, #02 )
    COP [AnimOnce]
    COP [BranchIfSolidOffset] ( #FE, #00, &code_0ADDF5 )
    COP [BranchIfSolidOffset] ( #FE, #FF, &code_0ADDF5 )
    COP [StageSpriteMoveX] ( #24, #02 )
    COP [AnimOnce]
    COP [BranchOnPlayerX] ( #$0000, &code_0ADDEB, &code_0ADDEB, &code_0ADDF3 )
}

code_0ADDEB {
    COP [RestoreSavedPtr]
}

code_0ADDED {
    COP [StageSpriteMoveX] ( #09, #02 )
    COP [AnimOnce]
}

code_0ADDF3 {
    COP [RestoreSavedPtrFFFF]
}

code_0ADDF5 {
    BRA code_0ADE34
}

code_0ADDF7 {
    COP [BranchIfSolidOffset] ( #01, #00, &code_0ADE34 )
    COP [BranchIfSolidOffset] ( #01, #FF, &code_0ADE34 )
    COP [BranchIfPlayerNear] ( #03, &code_0ADE2C )
    COP [StageSpriteMoveX] ( #89, #01 )
    COP [AnimOnce]
    COP [BranchIfSolidOffset] ( #01, #00, &code_0ADE34 )
    COP [BranchIfSolidOffset] ( #01, #FF, &code_0ADE34 )
    COP [StageSpriteMoveX] ( #A4, #01 )
    COP [AnimOnce]
    COP [BranchOnPlayerX] ( #$0000, &code_0ADE32, &code_0ADE2A, &code_0ADE2A )
}

code_0ADE2A {
    COP [RestoreSavedPtr]
}

code_0ADE2C {
    COP [StageSpriteMoveX] ( #89, #01 )
    COP [AnimOnce]
}

code_0ADE32 {
    COP [RestoreSavedPtrFFFF]
}

code_0ADE34 {
    COP [SetEntryExit]
    COP [RngByte]
    AND #$0003
    BEQ loc_0ADE47
    COP [BranchOnPlayerY] ( #$0000, &code_0ADE97, &code_0ADE97, &code_0ADE49 )

  loc_0ADE47:
    COP [RestoreSavedPtr]
}

code_0ADE49 {
    COP [BranchIfSolidSouth] ( &code_0ADE82 )
    COP [BranchIfSolidOffset] ( #FF, #01, &code_0ADE82 )
    COP [BranchIfPlayerNear] ( #03, &code_0ADE7A )
    COP [StageSpriteMoveY] ( #07, #01 )
    COP [AnimOnce]
    COP [BranchIfSolidSouth] ( &code_0ADE82 )
    COP [BranchIfSolidOffset] ( #FF, #01, &code_0ADE82 )
    COP [StageSpriteMoveY] ( #22, #01 )
    COP [AnimOnce]
    COP [BranchOnPlayerY] ( #$0000, &code_0ADE80, &code_0ADE78, &code_0ADE78 )
}

code_0ADE78 {
    COP [RestoreSavedPtr]
}

code_0ADE7A {
    COP [StageSpriteMoveY] ( #07, #01 )
    COP [AnimOnce]
}

code_0ADE80 {
    COP [RestoreSavedPtrFFFF]
}

code_0ADE82 {
    COP [SetEntryExit]
    COP [RngByte]
    AND #$0003
    BEQ loc_0ADE95
    COP [BranchOnPlayerX] ( #$0000, &code_0ADDB8, &code_0ADDB8, &code_0ADDF7 )

  loc_0ADE95:
    COP [RestoreSavedPtr]
}

code_0ADE97 {
    COP [BranchIfSolidOffset] ( #00, #FE, &code_0ADED4 )
    COP [BranchIfSolidOffset] ( #FF, #FE, &code_0ADED4 )
    COP [BranchIfPlayerNear] ( #03, &code_0ADECC )
    COP [StageSpriteMoveY] ( #08, #02 )
    COP [AnimOnce]
    COP [BranchIfSolidOffset] ( #00, #FE, &code_0ADED4 )
    COP [BranchIfSolidOffset] ( #FF, #FE, &code_0ADED4 )
    COP [StageSpriteMoveY] ( #23, #02 )
    COP [AnimOnce]
    COP [BranchOnPlayerY] ( #$0000, &code_0ADECA, &code_0ADECA, &code_0ADED2 )
}

code_0ADECA {
    COP [RestoreSavedPtr]
}

code_0ADECC {
    COP [StageSpriteMoveY] ( #08, #02 )
    COP [AnimOnce]
}

code_0ADED2 {
    COP [RestoreSavedPtrFFFF]
}

code_0ADED4 {
    BRA code_0ADE82
}

code_0ADED6 {
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    COP [SpawnAfterRelFlags] ( @code_0AE06A, #$0000, #$FFF4, #$0202 )
    COP [SetHitCallback] ( &code_0ADCC9 )

  loc_0ADEEA:
    COP [WaitByte] ( #09 )
    DEC $24
    BMI loc_0ADF30
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    COP [SpawnAfterRelFlags] ( @code_0AE05E, #$0000, #$FFF4, #$0202 )
    BRA loc_0ADEEA
}

code_0ADF03 {
    COP [StageSpriteFrame] ( #0B )
    COP [AnimOnce]
    COP [SpawnAfterRelFlags] ( @code_0AE065, #$0000, #$FFCC, #$0200 )
    COP [SetHitCallback] ( &code_0ADCC9 )

  loc_0ADF17:
    COP [WaitByte] ( #09 )
    DEC $24
    BMI loc_0ADF30
    COP [StageSpriteFrame] ( #0B )
    COP [AnimOnce]
    COP [SpawnAfterRelFlags] ( @code_0AE059, #$0000, #$FFCC, #$0200 )
    BRA loc_0ADF17

  loc_0ADF30:
    COP [SetHitCallback] ( #$0000 )
    COP [RestoreSavedPtr]
}

code_0ADF36 {
    COP [StageSpriteFrame] ( #0C )
    COP [AnimOnce]
    COP [SpawnAfterRelFlags] ( @code_0AE015, #$FFD8, #$FFE8, #$0200 )
    COP [SetHitCallback] ( &code_0ADCC9 )

  loc_0ADF4A:
    COP [WaitByte] ( #09 )
    DEC $24
    BMI loc_0ADF30
    COP [StageSpriteFrame] ( #0C )
    COP [AnimOnce]
    COP [SpawnAfterRelFlags] ( @code_0AE009, #$FFD8, #$FFE8, #$0200 )
    BRA loc_0ADF4A
}

code_0ADF63 {
    COP [StageSpriteFrame] ( #8C )
    COP [AnimOnce]
    COP [SpawnAfterRelFlags] ( @code_0AE010, #$0028, #$FFE8, #$0200 )
    COP [SetHitCallback] ( &code_0ADCC9 )

  loc_0ADF77:
    COP [WaitByte] ( #09 )
    DEC $24
    BMI loc_0ADF30
    COP [StageSpriteFrame] ( #8C )
    COP [AnimOnce]
    COP [SpawnAfterRelFlags] ( @code_0AE004, #$0028, #$FFE8, #$0200 )
    BRA loc_0ADF77
}

code_0ADF90 {
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    COP [ClearLowHere]
    LDA #$0110
    TRB $10
    COP [StageSpriteFrame] ( #2E )
    COP [AnimOnce]
    COP [PlaySoundCh1] ( #1E )
    COP [SpawnAfterRelFlags] ( @code_0AE0B9, #$0000, #$0000, #$0202 )
    COP [SpawnAfterRelFlags] ( @code_0AE0BF, #$0000, #$0000, #$0202 )
    COP [SpawnAfterRelFlags] ( @code_0AE0C5, #$0000, #$0000, #$0202 )
    COP [SpawnAfterRelFlags] ( @code_0AE0CB, #$0000, #$0000, #$0200 )
    COP [SpawnAfterRelFlags] ( @code_0AE0D1, #$0000, #$0000, #$0202 )
    COP [SpawnAfterRelFlags] ( @code_0AE0D7, #$0000, #$0000, #$0200 )
    COP [SpawnAfterRelFlags] ( @code_0AE0DD, #$0000, #$0000, #$0202 )
    COP [SpawnAfterRelFlags] ( @code_0AE0E3, #$0000, #$0000, #$0200 )
    COP [StageSpriteFrame] ( #2F )
    COP [AnimOnce]
    JMP $&code_0ADC74
}

code_0AE004 {
    LDA #$4000
    TSB $12
}

code_0AE009 {
    COP [RngByte]
    AND #$0003
    BRA loc_0AE018
}

code_0AE010 {
    LDA #$4000
    TSB $12
}

code_0AE015 {
    LDA #$0000

  loc_0AE018:
    PHA 
    COP [StageForceMoveXY] ( #04, #01 )
    LDA #$0080
    TSB $12
    COP [OrActorFlags] ( #$0010 )
    COP [PlaySoundCh1] ( #1E )
    PLA 
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0AE033 )
}

code_list_0AE033 [
  &code_0AE03B   ;00
  &code_0AE044   ;01
  &code_0AE049   ;02
  &code_0AE03B   ;03
]

code_0AE03B {
    LDA #$0000
    STA $moveYAlt, X
    STZ $2E
}

code_0AE044 {
    LDA #$2000
    TSB $12
}

code_0AE049 {
    COP [StageSpriteFrame] ( #1F )
    COP [AnimOnce]
    COP [ReloadForceMove]
    LDA $10
    BIT #$4000
    BEQ code_0AE049
    COP [Die]
}

code_0AE059 {
    LDA #$2000
    TSB $12
}

code_0AE05E {
    COP [RngByte]
    AND #$0003
    BRA loc_0AE06D
}

code_0AE065 {
    LDA #$2000
    TSB $12
}

code_0AE06A {
    LDA #$0000

  loc_0AE06D:
    PHA 
    COP [StageForceMoveXY] ( #02, #03 )
    COP [OrActorFlags] ( #$0010 )
    LDA #$0080
    TSB $12
    COP [PlaySoundCh1] ( #1E )
    PLA 
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0AE088 )
}

code_list_0AE088 [
  &code_0AE090   ;00
  &code_0AE09E   ;01
  &code_0AE099   ;02
  &code_0AE090   ;03
]

code_0AE090 {
    LDA #$0000
    STA $moveXAlt, X
    STZ $2C
}

code_0AE099 {
    LDA #$4000
    TSB $12
}

code_0AE09E {
    COP [StageSpriteLoop] ( #1F, #03 )
    COP [AnimLoop]
    LDA #$0002
    TRB $10

  loc_0AE0A9:
    COP [ReloadForceMove]
    COP [StageSpriteFrame] ( #1F )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_0AE0A9
    COP [Die]
}

code_0AE0B9 {
    COP [StageForceMoveXY] ( #04, #00 )
    BRA loc_0AE0E7
}

code_0AE0BF {
    COP [StageForceMoveXY] ( #03, #00 )
    BRA loc_0AE0E7
}

code_0AE0C5 {
    COP [StageForceMoveXY] ( #00, #03 )
    BRA loc_0AE0E7
}

code_0AE0CB {
    COP [StageForceMoveXY] ( #00, #04 )
    BRA loc_0AE0E7
}

code_0AE0D1 {
    COP [StageForceMoveXY] ( #02, #01 )
    BRA loc_0AE0E7
}

code_0AE0D7 {
    COP [StageForceMoveXY] ( #02, #02 )
    BRA loc_0AE0E7
}

code_0AE0DD {
    COP [StageForceMoveXY] ( #01, #01 )
    BRA loc_0AE0E7
}

code_0AE0E3 {
    COP [StageForceMoveXY] ( #01, #02 )

  loc_0AE0E7:
    COP [OrActorFlags] ( #$0010 )
    LDA #$0080
    TSB $12
    COP [StageSpriteLoop] ( #1F, #02 )
    COP [AnimLoop]
    LDA #$0002
    TRB $10
    BRA loc_0AE0A9
}

actor_def_0AE0FD [
  actor-def < #0D, #00, #20, {

  code_0AE100:
    COP [BranchIfSolid] ( &code_0AE11D )
    LDA #$0011
    TSB $12
    LDA $14
    STA $7F100C, X
    LDA $16
    STA $7F100E, X

  loc_0AE115:
    COP [SetEntryExit]
    COP [BranchIfPlayerNear] ( #0A, &code_0AE125 )
    RTL 
} >
]

code_0AE11D {
    LDA #$2000
    TSB $10
    COP [SetEntryContinue]
    RTL 
}

code_0AE125 {
    COP [WaitByte] ( #3B )
    COP [RngByte]
    PHA 
    AND #$00F0
    SEC 
    SBC #$0080
    CLC 
    ADC $playerWallType
    AND #$FFF0
    CLC 
    ADC #$0008
    STA $14
    PLA 
    ASL 
    ASL 
    ASL 
    ASL 
    AND #$00F0
    SEC 
    SBC #$0070
    CLC 
    ADC $playerSpeedEw
    AND #$FFF0
    CLC 
    ADC #$0010
    STA $16
    LDA $7F100C, X
    SEC 
    SBC $14
    BPL loc_0AE165
    EOR #$FFFF
    INC 

  loc_0AE165:
    CMP #$0100
    BCS loc_0AE115
    LDA $7F100E, X
    SEC 
    SBC $16
    BPL loc_0AE177
    EOR #$FFFF
    INC 

  loc_0AE177:
    CMP #$0100
    BCS loc_0AE115
    COP [BranchIfSolid] ( &code_0AE190 )
    COP [BranchIfPlayerNear] ( #01, &code_0AE190 )
    COP [CallScript] ( &code_0AE191 )
    LDA #$2100
    TSB $10
    BRA code_0AE125
}

code_0AE190 {
    RTL 
}

code_0AE191 {
    COP [SetEntryExit]
    LDA #$2000
    TRB $10
    COP [BranchNearerAxis] ( &code_0AE19E, &code_0AE202 )
}

code_0AE19E {
    COP [BranchOnPlayerX] ( #$0000, &code_0AE1A8, &code_0AE1A8, &code_0AE1D5 )
}

code_0AE1A8 {
    COP [SetHitCallback] ( &code_0AE1CE )
    COP [StageSpriteFrame] ( #15 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @code_0AE266, #F0, #F0, #$0202 )
    LDA #$000C
    STA $0026, Y
    COP [ForceMoveLastChild] ( #06, #00 )
}

code_0AE1CE {
    COP [StageSpriteFrame] ( #18 )
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0AE1D5 {
    COP [SetHitCallback] ( &code_0AE1FB )
    COP [StageSpriteFrame] ( #95 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #8F )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #92 )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @code_0AE266, #10, #F0, #$0202 )
    LDA #$0004
    STA $0026, Y
    COP [ForceMoveLastChild] ( #05, #00 )
}

code_0AE1FB {
    COP [StageSpriteFrame] ( #98 )
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0AE202 {
    COP [BranchOnPlayerY] ( #$0000, &code_0AE20C, &code_0AE20C, &code_0AE239 )
}

code_0AE20C {
    COP [SetHitCallback] ( &code_0AE232 )
    COP [StageSpriteFrame] ( #14 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0E )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #11 )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @code_0AE266, #00, #F0, #$0200 )
    LDA #$0000
    STA $0026, Y
    COP [ForceMoveLastChild] ( #00, #06 )
}

code_0AE232 {
    COP [StageSpriteFrame] ( #17 )
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0AE239 {
    COP [SetHitCallback] ( &code_0AE25F )
    COP [StageSpriteFrame] ( #13 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0D )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #10 )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @code_0AE266, #00, #F0, #$0202 )
    LDA #$0008
    STA $0026, Y
    COP [ForceMoveLastChild] ( #00, #05 )
}

code_0AE25F {
    COP [StageSpriteFrame] ( #16 )
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0AE266 {
    COP [PlaySoundCh1] ( #20 )
    COP [OrActorFlags] ( #$0010 )
    LDA #$0080
    TSB $12
    COP [StageSpriteFrame] ( #21 )
    COP [AnimOnce]
    COP [SpawnMarkedAfter] ( @chunk_008000.code_00E77A, #$2000 )
    LDA #$8021
    STA $chatPtr, X
    LDA #$0003
    STA $loopCounter, X
    LDA $decelStepCounter
    STA $0024, Y
    PHX 
    TYX 
    LDA $26
    STA $animScratch2, X
    PLX 
    LDA #$0002
    TSB $10
    COP [StageSpriteFrame] ( #21 )
    COP [AnimOnce]
    PHX 
    LDX $06
    LDA $moveScratch1, X
    STA $0000
    LDA $moveScratch2, X
    PLX 
    STA $7F100E, X
    LDA $0000
    STA $7F100C, X
    COP [KillNext]

  loc_0AE2C1:
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $08
    STA $24
    STZ $08
    COP [SetEntryContinue]
    LDA $7F100C, X
    STA $moveScratch1, X
    LDA $7F100E, X
    STA $moveScratch2, X
    DEC $24
    BMI loc_0AE2E2
    RTL 

  loc_0AE2E2:
    LDA $10
    BIT #$4000
    BEQ loc_0AE2C1
    COP [Die]
}

actor_def_0AE2EB [
  actor-def < #19, #00, #03, {

  code_0AE2EE:
    COP [BranchIfSolid] ( &code_0AE302 )
    LDA $sceneCurrent
    CMP #$005C
    BNE code_0AE30A
    COP [BranchIfFlagByte] ( #70, #00, &code_0AE30A )
    COP [Die]
} >
]

code_0AE302 {
    LDA #$2000
    TSB $10
    COP [SetEntryContinue]
    RTL 
}

code_0AE30A {
    COP [AddPosition] ( #F8, #00 )
    LDA #$0080
    TSB $12
    COP [WaitWhileOffscreen] ( #08 )

  code_0AE316:
    COP [BranchIfPlayerNear] ( #05, &code_0AE334 )
    LDA #$0009
    STA $08
    RTL 
}

code_0AE321 {
    COP [SetDodgeCallback] ( #$0000 )
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    LDA #$0300
    TSB $10
    COP [SetEntryExitNow] ( @code_0AE316 )
}

code_0AE334 {
    LDA #$0300
    TRB $10
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]

  code_0AE33E:
    COP [StageSpriteFrame] ( #1B )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BNE code_0AE321
    COP [BranchIfPlayerNear] ( #03, &code_0AE37F )
    COP [BranchIfPlayerNear] ( #06, &code_0AE36E )
    COP [SetSavedPtr] ( &code_0AE33E )
    COP [RngByte]
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0AE366 )
}

code_list_0AE366 [
  &code_0AE457   ;00
  &code_0AE4A0   ;01
  &code_0AE4D0   ;02
  &code_0AE521   ;03
]

code_0AE36E {
    COP [SetDodgeCallback] ( #$0000 )
    COP [StageSpriteLoop] ( #20, #03 )
    COP [AnimLoop]
    COP [StageSprAndHitbox] ( #27 )
    INC $24
    BRA loc_0AE385
}

code_0AE37F {
    COP [SetDodgeCallback] ( &code_0AE3C8 )
    STZ $24

  loc_0AE385:
    COP [RngByte]
    AND #$0003
    BNE loc_0AE394
    LDA $0411
    LSR 
    BCS code_0AE3B0
    BRA code_0AE39A

  loc_0AE394:
    COP [BranchNearerAxis] ( &code_0AE39A, &code_0AE3B0 )
}

code_0AE39A {
    COP [BranchOnPlayerX] ( #$0000, &code_0AE3A4, &code_0AE3A4, &code_0AE3AA )
}

code_0AE3A4 {
    COP [CallScript] ( &code_0AE457 )
    BRA code_0AE33E
}

code_0AE3AA {
    COP [CallScript] ( &code_0AE4A0 )
    BRA code_0AE33E
}

code_0AE3B0 {
    COP [BranchOnPlayerY] ( #$0000, &code_0AE3BA, &code_0AE3BA, &code_0AE3C1 )
}

code_0AE3BA {
    COP [CallScript] ( &code_0AE4D0 )
    JMP $&code_0AE33E
}

code_0AE3C1 {
    COP [CallScript] ( &code_0AE521 )
    JMP $&code_0AE33E
}

code_0AE3C8 {
    COP [SetEntryContinue]
    COP [AnimOnce]
    COP [BranchIfPlayerNear] ( #04, &code_0AE3D4 )
    JMP $&code_0AE33E
}

code_0AE3D4 {
    COP [CardinalToPlayer]
    CMP #$0000
    BNE loc_0AE3FB
    COP [LoopInit] ( #02 )
    COP [BranchIfSolidSouth] ( &code_0AE3F1 )
    COP [BranchIfSolidOffset] ( #FF, #01, &code_0AE3F1 )
    COP [StageForceMoveY] ( #11 )
    COP [SetEntryContinue]
    COP [AnimOnce]
    COP [LoopNext]
}

code_0AE3F1 {
    COP [StageSprAndHitbox] ( #27 )
    COP [CallScript] ( &code_0AE503 )
    JMP $&code_0AE33E

  loc_0AE3FB:
    DEC 
    BNE loc_0AE41A
    COP [LoopInit] ( #02 )
    COP [BranchIfSolidOffset] ( #FE, #00, &code_0AE410 )
    COP [StageForceMoveX] ( #12 )
    COP [SetEntryContinue]
    COP [AnimOnce]
    COP [LoopNext]
}

code_0AE410 {
    COP [StageSprAndHitbox] ( #27 )
    COP [CallScript] ( &code_0AE4B8 )
    JMP $&code_0AE33E

  loc_0AE41A:
    DEC 
    BNE loc_0AE43D
    COP [LoopInit] ( #02 )
    COP [BranchIfSolidNorth] ( &code_0AE433 )
    COP [BranchIfSolidOffset] ( #FF, #FF, &code_0AE433 )
    COP [StageForceMoveY] ( #12 )
    COP [SetEntryContinue]
    COP [AnimOnce]
    COP [LoopNext]
}

code_0AE433 {
    COP [StageSprAndHitbox] ( #27 )
    COP [CallScript] ( &code_0AE53F )
    JMP $&code_0AE33E

  loc_0AE43D:
    COP [LoopInit] ( #02 )
    COP [BranchIfSolidEast] ( &code_0AE44D )
    COP [StageForceMoveX] ( #11 )
    COP [SetEntryContinue]
    COP [AnimOnce]
    COP [LoopNext]
}

code_0AE44D {
    COP [StageSprAndHitbox] ( #27 )
    COP [CallScript] ( &code_0AE486 )
    JMP $&code_0AE33E
}

code_0AE457 {
    LDA $24
    BNE code_0AE486
    COP [BranchIfSolidOffset] ( #FE, #00, &code_0AE46F )
    COP [StageForceMoveX] ( #12 )
    COP [SetEntryContinue]
    COP [AnimOnce]
    COP [BranchIfPlayerNear] ( #04, &code_0AE457 )
    COP [RestoreSavedPtr]
}

code_0AE46F {
    STZ $2C
    COP [SetEntryExit]
    COP [RngByte]
    AND #$0003
    BEQ loc_0AE484
    COP [BranchOnPlayerY] ( #$0000, &code_0AE4D0, &code_0AE4D0, &code_0AE521 )

  loc_0AE484:
    COP [RestoreSavedPtr]
}

code_0AE486 {
    STZ $24
    COP [SetEntryExit]
    COP [StageForceMoveX] ( #08 )
    COP [LoopInit] ( #04 )
    COP [BranchIfSolidOffset] ( #FE, #00, &code_0AE49C )
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    COP [LoopNext]
}

code_0AE49C {
    STZ $2C
    COP [RestoreSavedPtr]
}

code_0AE4A0 {
    LDA $24
    BNE code_0AE4B8
    COP [BranchIfSolidEast] ( &code_0AE4B6 )
    COP [StageForceMoveX] ( #11 )
    COP [SetEntryContinue]
    COP [AnimOnce]
    COP [BranchIfPlayerNear] ( #04, &code_0AE4A0 )
    COP [RestoreSavedPtr]
}

code_0AE4B6 {
    BRA code_0AE46F
}

code_0AE4B8 {
    STZ $24
    COP [SetEntryExit]
    COP [StageForceMoveX] ( #07 )
    COP [LoopInit] ( #04 )
    COP [BranchIfSolidEast] ( &code_0AE4CC )
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    COP [LoopNext]
}

code_0AE4CC {
    STZ $2C
    COP [RestoreSavedPtr]
}

code_0AE4D0 {
    LDA $24
    BNE code_0AE503
    COP [BranchIfSolidNorth] ( &code_0AE4EC )
    COP [BranchIfSolidOffset] ( #FF, #FF, &code_0AE4EC )
    COP [StageForceMoveY] ( #12 )
    COP [SetEntryContinue]
    COP [AnimOnce]
    COP [BranchIfPlayerNear] ( #04, &code_0AE4D0 )
    COP [RestoreSavedPtr]
}

code_0AE4EC {
    STZ $2E
    COP [SetEntryExit]
    COP [RngByte]
    AND #$0003
    BEQ loc_0AE501
    COP [BranchOnPlayerX] ( #$0000, &code_0AE457, &code_0AE457, &code_0AE4A0 )

  loc_0AE501:
    COP [RestoreSavedPtr]
}

code_0AE503 {
    STZ $24
    COP [SetEntryExit]
    COP [StageForceMoveY] ( #08 )
    COP [LoopInit] ( #04 )
    COP [BranchIfSolidNorth] ( &code_0AE51D )
    COP [BranchIfSolidOffset] ( #FF, #FF, &code_0AE51D )
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    COP [LoopNext]
}

code_0AE51D {
    STZ $2E
    COP [RestoreSavedPtr]
}

code_0AE521 {
    LDA $24
    BNE code_0AE53F
    COP [BranchIfSolidSouth] ( &code_0AE53D )
    COP [BranchIfSolidOffset] ( #FF, #01, &code_0AE53D )
    COP [StageForceMoveY] ( #11 )
    COP [SetEntryContinue]
    COP [AnimOnce]
    COP [BranchIfPlayerNear] ( #04, &code_0AE521 )
    COP [RestoreSavedPtr]
}

code_0AE53D {
    BRA code_0AE4EC
}

code_0AE53F {
    STZ $24
    COP [StageForceMoveY] ( #07 )
    COP [LoopInit] ( #04 )
    COP [BranchIfSolidSouth] ( &code_0AE557 )
    COP [BranchIfSolidOffset] ( #FF, #01, &code_0AE557 )
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    COP [LoopNext]
}

code_0AE557 {
    STZ $2E
    COP [RestoreSavedPtr]
}

actor_def_0AE55B [
  actor-def < #1D, #00, #00, {

  code_0AE55E:
    LDA #$0010
    TSB $12
    COP [BranchIfSolid] ( &code_0AE569 )
    BRA loc_0AE571
} >
]

code_0AE569 {
    LDA #$2000
    TSB $10
    COP [SetEntryContinue]
    RTL 

  loc_0AE571:
    COP [BranchIfPlayerNear] ( #02, &code_0AE5DB )
    COP [SpawnAfter] ( @code_0AE79C )
    COP [StageSpriteMoveY] ( #1D, #43 )
    COP [AnimOnce]
    BRA loc_0AE571
}

actor_def_0AE583 [
  actor-def < #1D, #02, #23, {

  code_0AE586:
    LDA #$0010
    TSB $12
    LDA $sceneCurrent
    CMP #$005C
    BEQ loc_0AE598
    CMP #$005D
    BNE code_0AE5A0

  loc_0AE598:
    COP [BranchIfFlagByte] ( #70, #00, &code_0AE5A0 )
    COP [Die]
} >
]

code_0AE5A0 {
    COP [BranchIfPlayerNear] ( #05, &code_0AE5A6 )
    RTL 
}

code_0AE5A6 {
    COP [SpawnMarkedAfter] ( @code_0AE745, #$0301 )
    LDA #$2000
    TRB $10
    LDA $16
    STA $7F100E, X
    LDA $cameraTargetY
    SEC 
    SBC #$0020
    LSR 
    ASL 
    STA $16
    COP [SetEntryContinue]
    LDA $16
    INC 
    INC 
    STA $16
    CMP $7F100E, X
    BEQ loc_0AE5D2
    RTL 

  loc_0AE5D2:
    LDA #$0302
    TRB $10
    COP [KillNext]
    COP [SetEntryExit]
}

code_0AE5DB {
    LDA #$6000
    TRB $12
    STZ $24
    COP [BranchNearerAxis] ( &code_0AE5E8, &code_0AE5FE )
}

code_0AE5E8 {
    COP [BranchOnPlayerX] ( #$0000, &code_0AE5F2, &code_0AE5F2, &code_0AE5F8 )
}

code_0AE5F2 {
    COP [CallScript] ( &code_0AE616 )
    BRA code_0AE5DB
}

code_0AE5F8 {
    COP [CallScript] ( &code_0AE639 )
    BRA code_0AE5DB
}

code_0AE5FE {
    COP [BranchOnPlayerY] ( #$0000, &code_0AE608, &code_0AE608, &code_0AE60E )
}

code_0AE608 {
    COP [CallScript] ( &code_0AE65C )
    BRA code_0AE5DB
}

code_0AE60E {
    COP [CallScript] ( &code_0AE67F )
    BRA code_0AE5DB

  code_0AE614:
    COP [SetEntryExit]
}

code_0AE616 {
    COP [BranchOnPlayerY] ( #$0000, &code_0AE620, &code_0AE620, &code_0AE62C )
}

code_0AE620 {
    JSR $&code_0AE72D
    COP [BranchIfSolidOffset] ( #FF, #FF, &code_0AE62C )
    JMP $&code_0AE6E6
}

code_0AE62C {
    JSR $&code_0AE72D
    COP [BranchIfSolidOffset] ( #FF, #01, &code_0AE637 )
    BRA loc_0AE69F
}

code_0AE637 {
    COP [SetEntryExit]
}

code_0AE639 {
    COP [BranchOnPlayerY] ( #$0000, &code_0AE643, &code_0AE643, &code_0AE64F )
}

code_0AE643 {
    JSR $&code_0AE72D
    COP [BranchIfSolidOffset] ( #01, #FF, &code_0AE64F )
    JMP $&code_0AE70C
}

code_0AE64F {
    JSR $&code_0AE72D
    COP [BranchIfSolidOffset] ( #01, #01, &code_0AE614 )
    BRA loc_0AE6C5

  code_0AE65A:
    COP [SetEntryExit]
}

code_0AE65C {
    COP [BranchOnPlayerX] ( #$0000, &code_0AE666, &code_0AE666, &code_0AE671 )
}

code_0AE666 {
    JSR $&code_0AE72D
    COP [BranchIfSolidOffset] ( #FF, #FF, &code_0AE671 )
    BRA code_0AE6E6
}

code_0AE671 {
    JSR $&code_0AE72D
    COP [BranchIfSolidOffset] ( #01, #FF, &code_0AE67D )
    JMP $&code_0AE70C
}

code_0AE67D {
    COP [SetEntryExit]
}

code_0AE67F {
    COP [BranchOnPlayerX] ( #$0000, &code_0AE689, &code_0AE689, &code_0AE694 )
}

code_0AE689 {
    JSR $&code_0AE72D
    COP [BranchIfSolidOffset] ( #FF, #01, &code_0AE694 )
    BRA loc_0AE69F
}

code_0AE694 {
    JSR $&code_0AE72D
    COP [BranchIfSolidOffset] ( #01, #01, &code_0AE65A )
    BRA loc_0AE6C5

  loc_0AE69F:
    COP [SpawnAfter] ( @code_0AE779 )
    LDA #$0100
    TSB $10
    LDA #$4000
    TSB $12
    COP [StageSprAndHitbox] ( #1D )
    COP [StageForceMoveXY] ( #42, #41 )
    COP [SetEntryContinue]
    COP [ContinueIfFrame] ( #02 )
    LDA #$0100
    TRB $10
    COP [SetEntryContinue]
    COP [AnimOnce]
    COP [RestoreSavedPtr]

  loc_0AE6C5:
    COP [SpawnAfter] ( @code_0AE78D )
    LDA #$0100
    TSB $10
    COP [StageSprAndHitbox] ( #1D )
    COP [StageForceMoveXY] ( #42, #41 )
    COP [SetEntryContinue]
    COP [ContinueIfFrame] ( #02 )
    LDA #$0100
    TRB $10
    COP [SetEntryContinue]
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0AE6E6 {
    COP [SpawnAfter] ( @code_0AE751 )
    LDA #$0100
    TSB $10
    LDA #$4000
    TSB $12
    COP [StageSprAndHitbox] ( #1D )
    COP [StageForceMoveXY] ( #42, #40 )
    COP [SetEntryContinue]
    COP [ContinueIfFrame] ( #02 )
    LDA #$0100
    TRB $10
    COP [SetEntryContinue]
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0AE70C {
    COP [SpawnAfter] ( @code_0AE765 )
    LDA #$0100
    TSB $10
    COP [StageSprAndHitbox] ( #1D )
    COP [StageForceMoveXY] ( #42, #40 )
    COP [SetEntryContinue]
    COP [ContinueIfFrame] ( #02 )
    LDA #$0100
    TRB $10
    COP [SetEntryContinue]
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0AE72D {
    INC $24
    LDA $24
    CMP #$0004
    BCS loc_0AE737
    RTS 

  loc_0AE737:
    PLA 
    COP [SpawnAfter] ( @code_0AE79C )
    COP [StageSpriteMoveY] ( #1D, #43 )
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0AE745 {
    COP [SetMetasprite] ( @table_0EE000 )

  loc_0AE74A:
    COP [StageSpriteFrame] ( #31 )
    COP [AnimOnce]
    BRA loc_0AE74A
}

code_0AE751 {
    LDA #$2000
    TRB $10
    LDA #$0301
    TSB $10
    LDA #$6000
    TSB $12
    COP [StageSprAndHitbox] ( #1E )
    BRA loc_0AE7AB
}

code_0AE765 {
    LDA #$2000
    TRB $10
    LDA #$0301
    TSB $10
    LDA #$2000
    TSB $12
    COP [StageSprAndHitbox] ( #1E )
    BRA loc_0AE7AB
}

code_0AE779 {
    LDA #$2000
    TRB $10
    LDA #$0301
    TSB $10
    LDA #$4000
    TSB $12
    COP [StageSprAndHitbox] ( #1E )
    BRA loc_0AE7AB
}

code_0AE78D {
    LDA #$2000
    TRB $10
    LDA #$0301
    TSB $10
    COP [StageSprAndHitbox] ( #1E )
    BRA loc_0AE7AB
}

code_0AE79C {
    LDA #$2000
    TRB $10
    LDA #$0301
    TSB $10
    COP [StageSprAndHitbox] ( #1E )
    BRA loc_0AE7AF

  loc_0AE7AB:
    COP [StageForceMoveXY] ( #42, #42 )

  loc_0AE7AF:
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    STA $26
    COP [SetEntryContinue]
    LDY $24
    LDA $0010, Y
    BIT #$0080
    BNE loc_0AE7D0
    DEC $26
    BMI loc_0AE7CA
    RTL 

  loc_0AE7CA:
    LDA $2A
    BEQ loc_0AE7D0
    BRA loc_0AE7AF

  loc_0AE7D0:
    COP [Die]
}

actor_def_0AE7D2 [
  actor-def < #2C, #00, #20, {

  code_0AE7D5:
    COP [BranchIfSolid] ( &code_0AE7FF )
    LDA #$ABD8
    STA $statsPtr, X
    COP [SpawnAfterFlags] ( @code_0AE801, #$0200 )
    COP [SpawnAfterFlags] ( @code_0AE89C, #$0200 )
    COP [SpawnAfterFlags] ( @code_0AE89C, #$0200 )
    COP [SpawnAfterFlags] ( @code_0AE89C, #$0200 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_0AE7FF {
    COP [Die]
}

code_0AE801 {
    LDA $14
    STA $orbitAngle, X
    LDA $16
    STA $orbitDiameter, X
    COP [StageSprAndHitbox] ( #2C )

  code_0AE810:
    COP [WaitWhileOffscreen] ( #08 )
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #05, &code_0AE864 )
    COP [RngByte]
    AND #$007F
    SEC 
    SBC #$0040
    CLC 
    ADC $orbitAngle, X
    STA $moveXAlt, X
    COP [RngByte]
    AND #$007F
    SEC 
    SBC #$0040
    CLC 
    ADC $orbitDiameter, X
    STA $moveYAlt, X
    COP [MoveToward] ( #2C, #02 )
    COP [StageSpriteLoop] ( #2C, #04 )
    COP [AnimLoop]
    LDA $orbitAngle, X
    STA $moveXAlt, X
    LDA $orbitDiameter, X
    STA $moveYAlt, X
    COP [MoveToward] ( #2C, #01 )
    COP [StageSpriteLoop] ( #2C, #04 )
    COP [AnimLoop]
    BRA code_0AE810
}

code_0AE864 {
    LDY $decelStepCounter
    LDA $0014, Y
    STA $moveXAlt, X
    LDA $0016, Y
    STA $moveYAlt, X
    COP [MoveToward] ( #2C, #02 )
    COP [StageSpriteLoop] ( #2C, #04 )
    COP [AnimLoop]
    LDA $orbitAngle, X
    STA $moveXAlt, X
    LDA $orbitDiameter, X
    STA $moveYAlt, X
    COP [MoveToward] ( #2C, #01 )
    COP [StageSpriteLoop] ( #2C, #04 )
    COP [AnimLoop]
    JMP $&code_0AE810
}

code_0AE89C {
    COP [StageSprAndHitbox] ( #2C )
    LDA #$0100
    TSB $12

  loc_0AE8A4:
    PHX 
    LDY $04
    LDX $06
    LDA $0014, Y
    CLC 
    ADC $0014, X
    LSR 
    STA $14
    LDA $0016, Y
    CLC 
    ADC $0016, X
    LSR 
    STA $16
    LDA $0018, X
    STA $18
    LDA $001A, X
    STA $1A
    LDA $001C, X
    STA $1C
    LDA $001E, X
    STA $1E
    LDX $06
    LDA $metaspritePtr, X
    PLX 
    STA $metaspritePtr, X
    COP [SetEntryExit]
    BRA loc_0AE8A4
}

actor_def_0AE8E0 [
  actor-def < #00, #00, #00, {

  code_0AE8E3:
    COP [WaitWhileOffscreen] ( #10 )
    COP [SetHitCallback] ( &code_0AEB7F )
    COP [SetSavedPtr] ( &code_0AE8E3 )
    COP [BranchIfPlayerNear] ( #06, &code_0AE90E )
    LDA #$0004
    STA $24
    COP [RngByte]
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0AE906 )
} >
]

code_list_0AE906 [
  &code_0AE9CE   ;00
  &code_0AE9F4   ;01
  &code_0AEA12   ;02
  &code_0AEA38   ;03
]

code_0AE90E {
    COP [BranchIfPlayerNear] ( #02, &code_0AE970 )
    LDA #$0002
    STA $24
    COP [BranchOnPlayerX] ( #$0030, &code_0AE95C, &code_0AE922, &code_0AE966 )
}

code_0AE922 {
    COP [CardinalToPlayer]
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0AE930 )
}

code_list_0AE930 [
  &code_0AE938   ;00
  &code_0AE944   ;01
  &code_0AE93E   ;02
  &code_0AE950   ;03
]

code_0AE938 {
    COP [CallScript] ( &code_0AEA56 )
    BRA code_0AE8E3
}

code_0AE93E {
    COP [CallScript] ( &code_0AEA62 )
    BRA code_0AE8E3
}

code_0AE944 {
    COP [StageSpriteLoop] ( #82, #1E )
    COP [AnimLoop]
    COP [CallScript] ( &code_0AEA99 )
    BRA code_0AE8E3
}

code_0AE950 {
    COP [StageSpriteLoop] ( #02, #1E )
    COP [AnimLoop]
    COP [CallScript] ( &code_0AEA8D )
    BRA code_0AE8E3
}

code_0AE95C {
    COP [CallScript] ( &code_0AEA99 )
    COP [CallScript] ( &code_0AEB95 )
    BRA code_0AE922
}

code_0AE966 {
    COP [CallScript] ( &code_0AEA8D )
    COP [CallScript] ( &code_0AEBBB )
    BRA code_0AE922
}

code_0AE970 {
    COP [CardinalToPlayer]
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0AE97E )
}

code_list_0AE97E [
  &code_0AE986   ;00
  &code_0AE9AA   ;01
  &code_0AE998   ;02
  &code_0AE9BC   ;03
]

code_0AE986 {
    COP [StageSpriteLoop] ( #01, #1E )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #06 )
    COP [AnimOnce]
    COP [CallScript] ( &code_0AEAC7 )
    JMP $&code_0AE8E3
}

code_0AE998 {
    COP [StageSpriteLoop] ( #00, #1E )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    COP [CallScript] ( &code_0AEAF5 )
    JMP $&code_0AE8E3
}

code_0AE9AA {
    COP [StageSpriteLoop] ( #82, #1E )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #88 )
    COP [AnimOnce]
    COP [CallScript] ( &code_0AEB51 )
    JMP $&code_0AE8E3
}

code_0AE9BC {
    COP [StageSpriteLoop] ( #02, #1E )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #08 )
    COP [AnimOnce]
    COP [CallScript] ( &code_0AEB23 )
    JMP $&code_0AE8E3
}

code_0AE9CE {
    COP [SetHitCallback] ( &code_0AE9E2 )
    COP [StageSpriteLoop] ( #00, #3C )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #09, #02 )
    COP [AnimLoop]
    COP [SetHitCallback] ( #$0000 )
}

code_0AE9E2 {
    COP [BranchIfPlayerInRelTiles] ( #FE, #00, #02, #08, &code_0AEAF5 )

  loc_0AE9EA:
    COP [BranchOnPlayerX] ( #$0000, &code_0AEB23, &code_0AEB23, &code_0AEB51 )
}

code_0AE9F4 {
    COP [SetHitCallback] ( &code_0AEA08 )
    COP [StageSpriteLoop] ( #01, #3C )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #0A, #02 )
    COP [AnimLoop]
    COP [SetHitCallback] ( #$0000 )
}

code_0AEA08 {
    COP [BranchIfPlayerInRelTiles] ( #FE, #F8, #02, #00, &code_0AEAC7 )
    BRA loc_0AE9EA
}

code_0AEA12 {
    COP [SetHitCallback] ( &code_0AEA26 )
    COP [StageSpriteLoop] ( #02, #3C )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #0B, #02 )
    COP [AnimLoop]
    COP [SetHitCallback] ( #$0000 )
}

code_0AEA26 {
    COP [BranchIfPlayerInRelTiles] ( #F8, #FE, #00, #02, &code_0AEB23 )

  loc_0AEA2E:
    COP [BranchOnPlayerY] ( #$0000, &code_0AEAC7, &code_0AEAC7, &code_0AEAF5 )
}

code_0AEA38 {
    COP [SetHitCallback] ( &code_0AEA4C )
    COP [StageSpriteLoop] ( #82, #3C )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #8B, #02 )
    COP [AnimLoop]
    COP [SetHitCallback] ( #$0000 )
}

code_0AEA4C {
    COP [BranchIfPlayerInRelTiles] ( #00, #FE, #08, #02, &code_0AEB51 )
    BRA loc_0AEA2E
}

code_0AEA56 {
    COP [BranchIfSolidNorth] ( &code_0AEA6E )
    COP [StageSpriteMoveY] ( #05, #12 )
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0AEA62 {
    COP [BranchIfSolidSouth] ( &code_0AEA6E )
    COP [StageSpriteMoveY] ( #03, #11 )
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0AEA6E {
    COP [SetEntryExit]
    COP [RngByte]
    AND #$0003
    BNE loc_0AEA83
    LDA $0410
    LSR 
    LSR 
    AND #$0001
    BEQ code_0AEA99
    BRA code_0AEA8D

  loc_0AEA83:
    COP [BranchOnPlayerX] ( #$0000, &code_0AEA8D, &code_0AEA8D, &code_0AEA99 )
}

code_0AEA8D {
    COP [BranchIfSolidWest] ( &code_0AEAA5 )
    COP [StageSpriteMoveX] ( #07, #12 )
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0AEA99 {
    COP [BranchIfSolidEast] ( &code_0AEAA5 )
    COP [StageSpriteMoveX] ( #87, #11 )
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0AEAA5 {
    COP [BranchOnPlayerY] ( #$0000, &code_0AEAAF, &code_0AEAAF, &code_0AEABB )
}

code_0AEAAF {
    COP [BranchIfSolidNorth] ( &code_0AEA6E )
    COP [StageSpriteMoveY] ( #05, #12 )
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0AEABB {
    COP [BranchIfSolidSouth] ( &code_0AEA6E )
    COP [StageSpriteMoveY] ( #03, #11 )
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0AEAC7 {
    COP [StageSprAndHitbox] ( #05 )
    COP [LoopInit] ( #02 )
    COP [BranchIfSolidNorth] ( &code_0AEAF1 )
    COP [StageForceMoveY] ( #04 )
    LDA #$0001
    STA $26
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA #$0003
    STA $08
    DEC $26
    BMI loc_0AEAE7
    RTL 

  loc_0AEAE7:
    COP [LoopNext]
    COP [SetEntryExit]
    DEC $24
    BPL code_0AEAC7
    STZ $24
}

code_0AEAF1 {
    STZ $2E
    COP [RestoreSavedPtr]
}

code_0AEAF5 {
    COP [StageSprAndHitbox] ( #03 )
    COP [LoopInit] ( #02 )
    COP [BranchIfSolidSouth] ( &code_0AEB1F )
    COP [StageForceMoveY] ( #03 )
    LDA #$0001
    STA $26
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA #$0003
    STA $08
    DEC $26
    BMI loc_0AEB15
    RTL 

  loc_0AEB15:
    COP [LoopNext]
    COP [SetEntryExit]
    DEC $24
    BPL code_0AEAF5
    STZ $24
}

code_0AEB1F {
    STZ $2E
    COP [RestoreSavedPtr]
}

code_0AEB23 {
    COP [StageSprAndHitbox] ( #07 )
    COP [LoopInit] ( #02 )
    COP [BranchIfSolidWest] ( &code_0AEB4D )
    COP [StageForceMoveX] ( #04 )
    LDA #$0001
    STA $26
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA #$0003
    STA $08
    DEC $26
    BMI loc_0AEB43
    RTL 

  loc_0AEB43:
    COP [LoopNext]
    COP [SetEntryExit]
    DEC $24
    BPL code_0AEB23
    STZ $24
}

code_0AEB4D {
    STZ $2C
    COP [RestoreSavedPtr]
}

code_0AEB51 {
    COP [StageSprAndHitbox] ( #87 )
    COP [LoopInit] ( #02 )
    COP [BranchIfSolidEast] ( &code_0AEB7B )
    COP [StageForceMoveX] ( #03 )
    LDA #$0001
    STA $26
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA #$0003
    STA $08
    DEC $26
    BMI loc_0AEB71
    RTL 

  loc_0AEB71:
    COP [LoopNext]
    COP [SetEntryExit]
    DEC $24
    BPL code_0AEB51
    STZ $24
}

code_0AEB7B {
    STZ $2C
    COP [RestoreSavedPtr]
}

code_0AEB7F {
    COP [SnapToGrid]
    COP [StageForceMoveXY] ( #00, #00 )
    COP [SetHitCallback] ( #$0000 )
    COP [SetEntryExit]
    COP [BranchOnPlayerX] ( #$0000, &code_0AEB95, &code_0AEB95, &code_0AEBBB )
}

code_0AEB95 {
    COP [SetHitCallback] ( #$0000 )
    LDA #$0001
    TSB $12
    COP [StageSpriteFrame] ( #0C )
    COP [AnimOnce]
    COP [WaitByte] ( #1D )
    COP [SpawnMarkedAfterRel] ( @code_0AEBE1, #F8, #F0, #$0202 )
    COP [StageSpriteFrame] ( #0D )
    COP [AnimOnce]
    LDA #$0001
    TRB $12
    COP [RestoreSavedPtr]
}

code_0AEBBB {
    COP [SetHitCallback] ( #$0000 )
    LDA #$0001
    TSB $12
    COP [StageSpriteFrame] ( #8C )
    COP [AnimOnce]
    COP [WaitByte] ( #1D )
    COP [SpawnMarkedAfterRel] ( @code_0AEC38, #08, #F0, #$0202 )
    COP [StageSpriteFrame] ( #8D )
    COP [AnimOnce]
    LDA #$0001
    TRB $12
    COP [RestoreSavedPtr]
}

code_0AEBE1 {
    COP [PlaySoundCh1] ( #1E )
    LDA $24
    STA $7F100C, X
    COP [OrActorFlags] ( #$0010 )
    LDA $14
    SEC 
    SBC $playerWallType
    BPL loc_0AEBFA
    EOR #$FFFF
    INC 

  loc_0AEBFA:
    PHA 
    COP [RngByte]
    AND #$003F
    CLC 
    ADC $01, S
    EOR #$FFFF
    INC 
    CLC 
    ADC $14
    STA $moveXAlt, X
    PLA 
    LDA $playerSpeedEw
    SEC 
    SBC $16
    PHP 
    BPL loc_0AEC1C
    EOR #$FFFF
    INC 

  loc_0AEC1C:
    CMP #$0030
    BCC loc_0AEC24
    AND #$001F

  loc_0AEC24:
    PLP 
    BCS loc_0AEC2B
    EOR #$FFFF
    INC 

  loc_0AEC2B:
    CLC 
    ADC $16
    STA $moveYAlt, X
    COP [MoveToward] ( #0E, #02 )
    BRA loc_0AEC89
}

code_0AEC38 {
    COP [PlaySoundCh1] ( #1E )
    LDA $24
    STA $7F100C, X
    COP [OrActorFlags] ( #$0010 )
    LDA $playerWallType
    SEC 
    SBC $14
    BPL loc_0AEC51
    EOR #$FFFF
    INC 

  loc_0AEC51:
    PHA 
    COP [RngByte]
    AND #$003F
    CLC 
    ADC $01, S
    CLC 
    ADC $14
    STA $moveXAlt, X
    PLA 
    LDA $playerSpeedEw
    SEC 
    SBC $16
    PHP 
    BPL loc_0AEC6F
    EOR #$FFFF
    INC 

  loc_0AEC6F:
    CMP #$0030
    BCC loc_0AEC77
    AND #$001F

  loc_0AEC77:
    PLP 
    BCS loc_0AEC7E
    EOR #$FFFF
    INC 

  loc_0AEC7E:
    CLC 
    ADC $16
    STA $moveYAlt, X
    COP [MoveToward] ( #0E, #02 )

  loc_0AEC89:
    LDA $7F100C, X
    STA $26

  code_0AEC8F:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $2A
    BEQ code_0AEC8F
    LDY $26
    LDA $0014, Y
    SEC 
    SBC $14
    STA $0000
    BPL loc_0AECAF
    EOR #$FFFF
    INC 

  loc_0AECAF:
    CMP #$0003
    BCC loc_0AECCB
    LDA $0000
    BPL loc_0AECC3
    LDA #$FFFE
    CLC 
    ADC $14
    STA $14
    BRA loc_0AECCB

  loc_0AECC3:
    LDA #$0002
    CLC 
    ADC $14
    STA $14

  loc_0AECCB:
    LDA $0016, Y
    SEC 
    SBC #$0010
    SEC 
    SBC $16
    STA $0000
    BPL loc_0AECDE
    EOR #$FFFF
    INC 

  loc_0AECDE:
    CMP #$0003
    BCC loc_0AECFA
    LDA $0000
    BPL loc_0AECF2
    LDA #$FFFE
    CLC 
    ADC $16
    STA $16
    BRA loc_0AECFA

  loc_0AECF2:
    LDA #$0002
    CLC 
    ADC $16
    STA $16

  loc_0AECFA:
    LDA $0000
    BPL loc_0AED03
    EOR #$FFFF
    INC 

  loc_0AED03:
    STA $0000
    LDA $14
    SEC 
    SBC $0014, Y
    BPL loc_0AED12
    EOR #$FFFF
    INC 

  loc_0AED12:
    CLC 
    ADC $0000
    CMP #$0006
    BCC loc_0AED23
    DEC $24
    BPL loc_0AED22
    JMP $&code_0AEC8F

  loc_0AED22:
    RTL 

  loc_0AED23:
    COP [Die]

  loc_0AED25:
    COP [BranchIfPlayerNear] ( #07, &code_0AED2C )
    SEC 
    RTS 
}

code_0AED2C {
    CLC 
    RTS 
}

actor_def_0AED2E [
  actor-def < #0F, #00, #00, {

  code_0AED31:
    COP [SetDeathCallback] ( @code_0AEDBD )
    LDA #$2000
    TSB $12
    COP [OrActorFlags] ( #$0020 )
    BRA loc_0AED45

  loc_0AED41:
    COP [BranchIfOffscreen] ( &code_0AED72 )

  loc_0AED45:
    COP [WaitWhileOffscreen] ( #0F )
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    LDA $16
    STA $26
    LDA $playerSpeedEw
    SEC 
    SBC $16
    BPL loc_0AED5A
    RTL 

  loc_0AED5A:
    CMP #$0100
    BCC loc_0AED60
    RTL 

  loc_0AED60:
    LDA $playerWallType
    SEC 
    SBC $14
    BPL loc_0AED6C
    EOR #$FFFF
    INC 

  loc_0AED6C:
    CMP #$0040
    BCC code_0AED72
    RTL 
} >
]

code_0AED72 {
    COP [BranchOnPlayerX] ( #$0000, &code_0AED7C, &code_0AED7C, &code_0AED81 )
}

code_0AED7C {
    COP [StageSprAndHitbox] ( #11 )
    BRA loc_0AED89
}

code_0AED81 {
    COP [StageSprAndHitbox] ( #91 )
    LDA #$4000
    TSB $12

  loc_0AED89:
    COP [InitGravity] ( #04, #09, #00 )

  loc_0AED8E:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    COP [TickGravity]
    COP [StageForceMoveX] ( #02 )
    LDA $16
    CMP $26
    BCC loc_0AEDA9
    DEC $24
    BMI loc_0AED8E
    RTL 

  loc_0AEDA9:
    LDA #$4000
    TRB $12
    STZ $2C
    LDA #$0000
    STA $moveScratch2, X
    LDA $26
    STA $16
    BRA loc_0AED41
}

code_0AEDBD {
    COP [JumpScript] ( @code_0AA382 )
}

actor_def_0AEDC2 [
  actor-def < #15, #02, #00, {

  code_0AEDC5:
    COP [SolidHighHere]
    LDA #$0001
    TSB $12
    COP [SetDeathCallback] ( @code_0AEEFA )
    LDA $14
    STA $7F100C, X
    LDA $16
    STA $7F100E, X
    COP [SpawnAfterFlags] ( @code_0AEEC1, #$0301 )
    LDA #$0003
    STA $24

  loc_0AEDE9:
    COP [SpawnAfterFlags] ( @code_0AEE7F, #$0202 )
    DEC $24
    BPL loc_0AEDE9
    COP [OrActorFlags] ( #$0020 )

  loc_0AEDF8:
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #04, &code_0AEE05 )
    RTL 
} >
]

code_0AEE05 {
    LDA #$0002
    TSB $12
    COP [BranchOnPlayerX] ( #$0000, &code_0AEE16, &code_0AEE16, &code_0AEE14 )
}

code_0AEE14 {
    COP [SetHFlip]
}

code_0AEE16 {
    COP [StageSpriteFrame] ( #16 )
    COP [AnimOnce]
    JSR $&code_0AFEFD
    COP [CallScript] ( &code_0AEE4F )
    JSR $&code_0AFEFD
    COP [CallScript] ( &code_0AEE4F )
    COP [BranchIfPlayerNear] ( #04, &code_0AEE30 )
    BRA loc_0AEDF8
}

code_0AEE30 {
    LDY $decelStepCounter
    LDA $0014, Y
    STA $moveXAlt, X
    LDA $0016, Y
    STA $moveYAlt, X
    COP [CallScript] ( &code_0AEE49 )
    COP [ClearHFlip]
    BRA loc_0AEDF8
}

code_0AEE49 {
    COP [MoveToward] ( #13, #04 )
    BRA loc_0AEE53
}

code_0AEE4F {
    COP [MoveToward] ( #13, #02 )

  loc_0AEE53:
    COP [StageSpriteLoop] ( #17, #02 )
    COP [AnimLoop]

  loc_0AEE59:
    LDA $7F100C, X
    STA $moveXAlt, X
    LDA $7F100E, X
    STA $moveYAlt, X
    COP [MoveToward] ( #12, #03 )
    LDA $7F100C, X
    CMP $14
    BNE loc_0AEE59
    LDA $7F100E, X
    CMP $16
    BNE loc_0AEE59
    COP [RestoreSavedPtr]
}

code_0AEE7F {
    COP [StageSpriteFrame] ( #14 )
    COP [AnimOnce]
    LDA $0E
    STA $26

  loc_0AEE88:
    COP [SetEntryContinue]
    JSL $@code_0AA35F
    LDY $24
    LDA $000E, Y
    STA $0E
    LDA $0010, Y
    BIT #$0080
    BNE loc_0AEE9E
    RTL 

  loc_0AEE9E:
    COP [SetEntryContinue]
    JSL $@code_0AA35F
    LDY $24
    LDA $0010, Y
    BIT #$0080
    BEQ loc_0AEE88
    LDA $0036
    LSR 
    BCC loc_0AEEBC
    LDA $26
    ORA #$0200
    STA $0E
    RTL 

  loc_0AEEBC:
    LDA $26
    STA $0E
    RTL 
}

code_0AEEC1 {
    COP [StageSpriteFrame] ( #15 )
    COP [AnimOnce]
    LDA $0E
    STA $26

  loc_0AEECA:
    LDA $26
    STA $0E
    COP [SetEntryContinue]
    LDY $24
    LDA $0010, Y
    BIT #$0080
    BNE loc_0AEEDB
    RTL 

  loc_0AEEDB:
    COP [SetEntryContinue]
    LDY $24
    LDA $0010, Y
    BIT #$0080
    BEQ loc_0AEECA
    LDA $0036
    LSR 
    BCC loc_0AEEF5
    LDA $26
    ORA #$0200
    STA $0E
    RTL 

  loc_0AEEF5:
    LDA $26
    STA $0E
    RTL 
}

code_0AEEFA {
    LDA #$0004
    STA $000E
    LDY $06
    LDA #$0004
    STA $0000

  loc_0AEF08:
    LDA #$EF43
    STA $0000, Y
    LDA $0000
    STA $0008, Y
    CLC 
    ADC #$0008
    STA $0000
    LDA $0006, Y
    TAY 
    DEC $000E
    BPL loc_0AEF08
    LDA $14
    PHA 
    LDA $16
    PHA 
    LDA $7F100C, X
    STA $14
    LDA $7F100E, X
    STA $16
    COP [ClearLowHere]
    PLA 
    STA $16
    PLA 
    STA $14
    COP [JumpScript] ( @chunk_008000.code_00DCA9 )

  loc_0AEF43:
    LDA $26
    STA $0E
    COP [PlaySoundCh1] ( #06 )
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    COP [Die]
}

actor_def_0AEF56 [
  actor-def < #1A, #00, #00, {

  code_0AEF59:
    COP [SolidHighHere]
    LDA #$0011
    TSB $12
    COP [OrActorFlags] ( #$0008 )

  loc_0AEF64:
    COP [WaitWhileOffscreen] ( #08 )
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #1B, #03 )
    COP [AnimLoop]
    COP [SpawnLastRel] ( @code_0AEF91, #FC, #F4, #$0200 )
    COP [SpawnLastRel] ( @code_0AEF8C, #04, #F4, #$0200 )
    COP [StageSpriteLoop] ( #1A, #02 )
    COP [AnimLoop]
    BRA loc_0AEF64
} >
]

code_0AEF8C {
    LDA #$4000
    TSB $12
}

code_0AEF91 {
    COP [OrActorFlags] ( #$0010 )
    COP [SpawnMarkedAfter] ( @code_0AEFC6, #$2200 )
    LDA #$0002
    STA $0008, Y
    COP [SpawnMarkedAfter] ( @code_0AEFC6, #$2200 )
    LDA #$0004
    STA $0008, Y
    COP [PlaySoundCh1] ( #1E )
    COP [SetMetasprite] ( @table_0EE000 )

  loc_0AEFB7:
    COP [StageSpriteMoveX] ( #08, #04 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_0AEFB7
    COP [Die]
}

code_0AEFC6 {
    COP [SetMetasprite] ( @table_0EE000 )
    COP [SetEntryExit]
    LDA #$2000
    TRB $10
    COP [StageForceMoveXY] ( #04, #00 )

  loc_0AEFD6:
    COP [ReloadForceMove]
    COP [StageSpriteFrame] ( #26 )
    COP [AnimOnce]
    BRA loc_0AEFD6
}

actor_def_0AEFDF [
  actor-def < #00, #00, #00, {

  code_0AEFE2:
    LDA #$8011
    TSB $12
    COP [SpawnLastRel] ( @code_0AF035, #00, #00, #$2000 )
    LDA $characterForm
    CMP #$0002
    BNE loc_0AEFFB
    JMP $&code_0AF0BB

  loc_0AEFFB:
    LDY $decelStepCounter
    LDA #$0088
    STA $0002, Y
    LDA #$EE8C
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $slopeCurvePtrB
    COP [SetEntryContinue]
    LDA $slopeCurvePtrB
    BIT #$0800
    BEQ loc_0AF021
    RTL 

  loc_0AF021:
    JMP $&code_0AF0BB
} >
]

actor_def_0AF024 [
  actor-def < #00, #00, #00, {

  code_0AF027:
    COP [SetEntryContinue]
    LDA $slopeCurvePtrB
    BIT #$0800
    BEQ loc_0AF032
    RTL 

  loc_0AF032:
    JMP $&code_0AF6B0
} >
]

code_0AF035 {
    COP [SetEntryContinue]
    LDA $0AEC
    BEQ loc_0AF03D
    RTL 

  loc_0AF03D:
    LDY $decelStepCounter
    LDA #$0088
    STA $0002, Y
    LDA #$EC9E
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $slopeCurvePtrB
    COP [SetEntryContinue]
    LDA $slopeCurvePtrB
    BIT #$0800
    BEQ loc_0AF063
    RTL 

  loc_0AF063:
    COP [SetFlagWord] ( #$0177 )
    LDA #$0003
    STA $gfxCacheIdxA
    LDA #$0403
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #E0, #$02F8, #$01A0, #03, #$2810 )
    COP [Die]
}

actor_def_0AF07F [
  actor-def < #00, #00, #00, {

  code_0AF082:
    COP [BranchIfPlayerAt] ( #$0180, #$0060, &code_0AF0A3 )
    COP [BranchIfPlayerAt] ( #$0180, #$01E0, &code_0AF0A3 )
    LDA #$0002
    JSL $@chunk_008000.code_00B10F
    BCC loc_0AF0AC
    STZ $0AEC
    STZ $0AEE
    COP [Die]
} >
]

code_0AF0A3 {
    LDA #$0008
    TSB $slopeCurvePtrB
    COP [SetEntryContinue]
    RTL 

  loc_0AF0AC:
    LDA #$008A
    AND #$00FF
    STA $0AF6
    LDA #$FC0B
    STA $0AF4
}

code_0AF0BB {
    COP [SetDeathCallback] ( @code_0AFA10 )
    LDA #$8011
    TSB $12
    LDA $06
    STA $26
    TAY 
    TXA 
    STA $0026, Y
    LDA #$0000
    STA $orbitAngle, X
    COP [BranchIfFlagByte] ( #87, #01, &code_0AF10B )
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #01, #13, #0F, #15, &code_0AF0E6 )
    RTL 
}

code_0AF0E6 {
    COP [ExitIfFlagByte] ( #86, #01 )
    LDA $14
    STA $moveXAlt, X
    LDA #$0100
    STA $moveYAlt, X
    COP [StageMove] ( #01, #02, #FF )
    COP [TickMove]
    COP [BranchIfFlagByte] ( #87, #01, &code_0AF10B )
    COP [SetFlagByte] ( #87 )
    COP [PrintWideString] ( &widestring_0AFA53 )
}

code_0AF10B {
    LDA $sceneCurrent
    CMP #$0067
    BNE loc_0AF12F
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [PlaySoundCh1] ( #0E )
    COP [WaitByte] ( #0E )
    COP [StageBgChange] ( #92 )
    COP [ApplyBgChange]
    COP [StageBgChange] ( #91 )
    COP [ApplyBgChange]
    COP [StartMusic] ( #0F )
    COP [WaitByte] ( #27 )

  loc_0AF12F:
    LDA #$EFF0
    TRB $joypadMaskStd
    COP [WaitByte] ( #77 )
    COP [SetFlagByte] ( #02 )

  code_0AF13B:
    COP [BranchIfFlagByte] ( #0F, #01, &code_0AFDB7 )
    LDA $orbitAngle, X
    CMP #$0003
    BCC loc_0AF166
    PHX 
    LDX $26
    LDA $orbitAngle, X
    CMP #$0003
    BCC loc_0AF165
    PLX 
    COP [RngByte]
    AND #$0001
    BNE loc_0AF166
    STA $orbitAngle, X
    JMP $&code_0AF521

  loc_0AF165:
    PLX 

  loc_0AF166:
    COP [CallScript] ( &code_0AF2EB )
    COP [BranchIfSolid] ( &code_0AF186 )
    COP [StageSpriteLoop] ( #00, #3C )
    COP [AnimLoop]
    COP [SpawnLastRel] ( @code_0AF450, #00, #00, #$0010 )
    LDA $orbitAngle, X
    INC 
    STA $orbitAngle, X
}

code_0AF186 {
    COP [CallScript] ( &code_0AF18C )
    BRA code_0AF13B
}

code_0AF18C {
    PEA $&code_0AF1C7-1
    LDA $playerWallType
    CLC 
    ADC #$0008
    CMP #$0080
    BCS loc_0AF1B1
    LDA $playerSpeedEw
    CMP #$0100
    BCS loc_0AF1AA
    JSR $&code_0AF1D8
    JSR $&code_0AF1F7
    RTS 

  loc_0AF1AA:
    JSR $&code_0AF1D8
    JSR $&code_0AF1F0
    RTS 

  loc_0AF1B1:
    LDA $playerSpeedEw
    CMP #$0100
    BCS loc_0AF1C0
    JSR $&code_0AF1E6
    JSR $&code_0AF1F7
    RTS 

  loc_0AF1C0:
    JSR $&code_0AF1E6
    JSR $&code_0AF1F0
    RTS 
}

code_0AF1C7 {
    COP [SetHitCallback] ( &code_0AF202 )
    COP [StageMove] ( #01, #01, #FF )
    COP [TickMove]
    COP [SetHitCallback] ( #$0000 )
    COP [RestoreSavedPtr]
}

code_0AF1D8 {
    COP [RngByte]
    AND #$007F
    CLC 
    ADC #$0080
    STA $moveXAlt, X
    RTS 
}

code_0AF1E6 {
    COP [RngByte]
    AND #$007F
    STA $moveXAlt, X
    RTS 
}

code_0AF1F0 {
    COP [RngByte]
    STA $moveYAlt, X
    RTS 
}

code_0AF1F7 {
    COP [RngByte]
    CLC 
    ADC #$0100
    STA $moveYAlt, X
    RTS 
}

code_0AF202 {
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    COP [SpawnMarkedAfter] ( @code_0AF24A, #$0200 )
    LDA #$0003

  loc_0AF211:
    PHA 
    COP [SpawnMarkedAfter] ( @code_0AF22F, #$0200 )
    PLA 
    DEC 
    BPL loc_0AF211
    COP [StageSpriteLoop] ( #01, #0F )
    COP [AnimLoop]
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    COP [RestoreSavedPtr]
}

code_0AF22F {
    COP [StageSprAndHitbox] ( #28 )

  loc_0AF232:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $2A
    BEQ loc_0AF232
    JSL $@code_0AA35F
    DEC $24
    BMI loc_0AF232
    RTL 
}

code_0AF24A {
    LDA $24
    STA $26
    COP [StageSprAndHitbox] ( #28 )
    LDA #$0000
    STA $orbitAngle, X
    LDA #$0000
    STA $orbitDiameter, X
    STA $7F100C, X

  loc_0AF263:
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0AF263
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryExit]
    LDY $26
    JSL $@chunk_008000.code_00F4BD
    LDA $orbitAngle, X
    CLC 
    ADC #$0010
    AND #$00FF
    STA $orbitAngle, X
    LDA $7F100C, X
    INC 
    STA $7F100C, X
    CMP #$0078
    BCS loc_0AF2D5
    LDA $0036
    AND #$0003
    BNE loc_0AF2B0
    LDA $orbitDiameter, X
    CMP #$007F
    BCS loc_0AF2B0
    CLC 
    ADC #$0003
    STA $orbitDiameter, X

  loc_0AF2B0:
    DEC $24
    BMI loc_0AF263
    RTL 
}

code_0AF2B5 {
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDY $26
    JSL $@chunk_008000.code_00F4BD
    LDA $orbitAngle, X
    CLC 
    ADC #$0010
    AND #$00FF
    STA $orbitAngle, X

  loc_0AF2D5:
    LDA $orbitDiameter, X
    SEC 
    SBC #$0003
    BPL loc_0AF2E2
    LDA #$0000

  loc_0AF2E2:
    STA $orbitDiameter, X
    DEC $24
    BMI code_0AF2B5
    RTL 
}

code_0AF2EB {
    COP [SpawnMarkedAfter] ( @code_0AF421, #$2200 )
    LDA $14
    STA $7F100C, X
    LDA $16
    STA $7F100E, X
    LDY $decelStepCounter
    LDA $0014, Y
    SEC 
    SBC #$0008
    AND #$FFF0
    CLC 
    ADC #$0008
    STA $14
    LDA $0016, Y
    AND #$FFF0
    STA $16
    STZ $24
    COP [BranchIfSolidNorth] ( &code_0AF324 )
    LDA #$0001
    TSB $24
}

code_0AF324 {
    COP [BranchIfSolidSouth] ( &code_0AF32D )
    LDA #$0002
    TSB $24
}

code_0AF32D {
    COP [BranchIfSolidWest] ( &code_0AF336 )
    LDA #$0004
    TSB $24
}

code_0AF336 {
    COP [BranchIfSolidEast] ( &code_0AF33F )
    LDA #$0008
    TSB $24
}

code_0AF33F {
    PEA $&code_0AF416-1
    LDA $7F100C, X
    STA $14
    LDA $7F100E, X
    STA $16
    LDA $24
    AND #$0003
    CMP #$0003
    BEQ loc_0AF362
    LDA $24
    AND #$000C
    CMP #$000C
    BEQ loc_0AF3BD

  loc_0AF362:
    LDA $24
    AND #$0003
    BEQ loc_0AF3BD
    CMP #$0003
    BEQ loc_0AF375
    CMP #$0001
    BEQ loc_0AF37C
    BRA loc_0AF39B

  loc_0AF375:
    COP [RngByte]
    AND #$0001
    BNE loc_0AF39B

  loc_0AF37C:
    LDA $playerWallType
    AND #$FFF0
    CLC 
    ADC #$0008
    STA $moveXAlt, X

  loc_0AF38A:
    LDA $playerSpeedEw
    AND #$FFF0
    SEC 
    SBC #$0040
    STA $moveYAlt, X
    BMI loc_0AF3A9
    RTS 

  loc_0AF39B:
    LDA $playerWallType
    AND #$FFF0
    CLC 
    ADC #$0008
    STA $moveXAlt, X

  loc_0AF3A9:
    LDA $playerSpeedEw
    AND #$FFF0
    CLC 
    ADC #$0040
    STA $moveYAlt, X
    CMP $cameraBoundsY
    BCS loc_0AF38A
    RTS 

  loc_0AF3BD:
    LDA $24
    AND #$000C
    CMP #$000C
    BEQ loc_0AF3CE
    CMP #$0004
    BEQ loc_0AF3D5
    BRA loc_0AF3F7

  loc_0AF3CE:
    COP [RngByte]
    AND #$0001
    BNE loc_0AF3F7

  loc_0AF3D5:
    LDA $playerSpeedEw
    AND #$FFF0
    CLC 
    ADC #$0010
    STA $moveYAlt, X

  loc_0AF3E3:
    LDA $playerWallType
    AND #$FFF0
    CLC 
    ADC #$0048
    STA $moveXAlt, X
    CMP $cameraBoundsX
    BCS loc_0AF405
    RTS 

  loc_0AF3F7:
    LDA $playerSpeedEw
    AND #$FFF0
    CLC 
    ADC #$0010
    STA $moveYAlt, X

  loc_0AF405:
    LDA $playerWallType
    AND #$FFF0
    CLC 
    ADC #$FFC8
    STA $moveXAlt, X
    BMI loc_0AF3E3
    RTS 
}

code_0AF416 {
    COP [StageMove] ( #01, #03, #FF )
    COP [TickMove]
    COP [KillNext]
    COP [RestoreSavedPtr]
}

code_0AF421 {
    COP [WaitByte] ( #04 )
    LDY $24
    LDA $0014, Y
    CMP $14
    BNE loc_0AF434
    LDA $0016, Y
    CMP $16
    BEQ code_0AF421

  loc_0AF434:
    COP [SpawnAfterFlags] ( @code_0AF449, #$0300 )
    LDY $24
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    STA $16
    BRA code_0AF421
}

code_0AF449 {
    COP [StageSpriteFrame] ( #10 )
    COP [AnimOnce]
    COP [Die]
}

code_0AF450 {
    COP [PlaySoundCh1] ( #2C )
    COP [SolidHighHere]
    COP [StageSpriteLoop] ( #07, #03 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #08 )
    COP [AnimOnce]
    COP [PlaySoundCh1] ( #06 )
    COP [SpawnAfterFlags] ( @code_0AF497, #$2200 )
    COP [SpawnAfterFlags] ( @code_0AF4B5, #$2200 )
    COP [SpawnAfterFlags] ( @code_0AF4D3, #$2200 )
    COP [SpawnAfterFlags] ( @code_0AF4F1, #$2200 )
    LDA #$0010
    TRB $10
    LDA #$0200
    TSB $10
    COP [StageSpriteFrame] ( #09 )
    COP [AnimOnce]
    COP [ClearLowHere]
    COP [Die]

  code_0AF492:
    JSR $&code_0AF50F
    BRA loc_0AF49E
}

code_0AF497 {
    COP [WaitByte] ( #03 )
    COP [BranchIfSolidWest] ( &code_0AF492 )

  loc_0AF49E:
    LDA #$2000
    TRB $10
    COP [AddPosition] ( #F0, #00 )
    COP [SpawnAfterFlags] ( @code_0AF497, #$2200 )
    BRA loc_0AF508

  code_0AF4B0:
    JSR $&code_0AF50F
    BRA loc_0AF4BC
}

code_0AF4B5 {
    COP [WaitByte] ( #03 )
    COP [BranchIfSolidEast] ( &code_0AF4B0 )

  loc_0AF4BC:
    LDA #$2000
    TRB $10
    COP [AddPosition] ( #10, #00 )
    COP [SpawnAfterFlags] ( @code_0AF4B5, #$2200 )
    BRA loc_0AF508

  code_0AF4CE:
    JSR $&code_0AF50F
    BRA loc_0AF4DA
}

code_0AF4D3 {
    COP [WaitByte] ( #03 )
    COP [BranchIfSolidNorth] ( &code_0AF4CE )

  loc_0AF4DA:
    LDA #$2000
    TRB $10
    COP [AddPosition] ( #00, #F0 )
    COP [SpawnAfterFlags] ( @code_0AF4D3, #$2200 )
    BRA loc_0AF508

  code_0AF4EC:
    JSR $&code_0AF50F
    BRA loc_0AF4F8
}

code_0AF4F1 {
    COP [WaitByte] ( #03 )
    COP [BranchIfSolidSouth] ( &code_0AF4EC )

  loc_0AF4F8:
    LDA #$2000
    TRB $10
    COP [AddPosition] ( #00, #10 )
    COP [SpawnAfterFlags] ( @code_0AF4F1, #$2200 )

  loc_0AF508:
    COP [StageSpriteFrame] ( #06 )
    COP [AnimOnce]

  loc_0AF50D:
    COP [Die]
}

code_0AF50F {
    PHD 
    LDA #$0000
    TCD 
    LDA [$80], Y
    AND #$000F
    BEQ loc_0AF51F
    PLD 
    PLA 
    BRA loc_0AF50D

  loc_0AF51F:
    PLD 
    RTS 
}

code_0AF521 {
    LDY $26
    LDA #$F5CA
    JSR $&code_0AFEDE
    LDA #$0050
    STA $moveYAlt, X
    LDA $playerWallType
    CMP #$0078
    BCC loc_0AF54E
    LDA #$00E8
    STA $moveXAlt, X
    PHX 
    LDX $26
    LDA #$0001
    STA $7F100C, X
    LDA #$0058
    BRA loc_0AF562

  loc_0AF54E:
    LDA #$00A8
    STA $moveXAlt, X
    PHX 
    LDX $26
    LDA #$0000
    STA $7F100C, X
    LDA #$0018

  loc_0AF562:
    STA $moveXAlt, X
    LDA #$0000
    STA $orbitDiameter, X
    INC 
    STA $7F100E, X
    PLX 
    LDA #$0000
    STA $orbitDiameter, X
    COP [StageMove] ( #01, #03, #FF )
    COP [TickMove]
    LDA $orbitDiameter, X
    INC 
    STA $orbitDiameter, X
    COP [SetEntryContinue]
    COP [BranchIfFlagByte] ( #0F, #01, &code_0AF5A8 )
    PHX 
    LDX $26
    LDA $orbitDiameter, X
    PLX 
    CMP #$0000
    BNE loc_0AF5A0
    RTL 

  loc_0AF5A0:
    LDA #$F60C
    LDY $26
    JSR $&code_0AFEDE
}

code_0AF5A8 {
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    COP [WaitByte] ( #17 )
    COP [BranchIfFlagByte] ( #0F, #01, &code_0AF5C2 )
    COP [SpawnLastRel] ( @code_0AF638, #00, #00, #$0202 )
    COP [WaitByte] ( #1F )
}

code_0AF5C2 {
    COP [StageSpriteFrame] ( #11 )
    COP [AnimOnce]
    JMP $&code_0AF13B
}

code_0AF5CA {
    COP [SetHitCallback] ( #$0000 )
    LDA #$0000
    STA $orbitAngle, X
    LDA #$0050
    STA $moveYAlt, X
    COP [StageMove] ( #14, #03, #FF )
    COP [TickMove]
    LDA $orbitDiameter, X
    INC 
    STA $orbitDiameter, X
    COP [SetEntryContinue]
    COP [BranchIfFlagByte] ( #0E, #01, &code_0AF60C )
    PHX 
    LDX $26
    LDA $orbitDiameter, X
    PLX 
    CMP #$0000
    BNE loc_0AF602
    RTL 

  loc_0AF602:
    LDA #$F5A8
    LDY $26
    JSR $&code_0AFEDE
    COP [SetEntryExit]
}

code_0AF60C {
    COP [StageSpriteFrame] ( #17 )
    COP [AnimOnce]
    COP [SpawnThinkerParam] ( #43, @chunk_008000.code_00B5C4 )
    COP [WaitByte] ( #17 )
    COP [BranchIfFlagByte] ( #0E, #01, &code_0AF62C )
    COP [SpawnLastRel] ( @code_0AF678, #00, #00, #$0202 )
    COP [WaitByte] ( #1F )
}

code_0AF62C {
    COP [StageSpriteFrame] ( #27 )
    COP [AnimOnce]
    COP [SetHitCallback] ( &code_0AF8BD )
    JMP $&code_0AF6F6
}

code_0AF638 {
    LDA #$AC9C
    STA $statsPtr, X
    COP [PlaySoundCh1] ( #1E )
    LDA $14
    CLC 
    ADC #$FFB8
    STA $moveXAlt, X
    LDA $16
    CLC 
    ADC #$0020
    STA $moveYAlt, X
    COP [MoveToward] ( #0A, #04 )
    COP [PlaySoundBoth] ( #$2323 )
    COP [StageSpriteLoop] ( #0B, #03 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #0D )
    COP [AnimOnce]

  loc_0AF669:
    COP [StageSpriteMoveY] ( #0E, #01 )
    COP [AnimOnce]
    LDA $16
    CMP $cameraBoundsY
    BCS loc_0AF690
    BRA loc_0AF669
}

code_0AF678 {
    LDA $14
    CLC 
    ADC #$0048
    STA $moveXAlt, X
    LDA $16
    CLC 
    ADC #$0020
    STA $moveYAlt, X
    COP [MoveToward] ( #0A, #04 )

  loc_0AF690:
    COP [Die]
}

actor_def_0AF692 [
  actor-def < #14, #00, #00, {

  code_0AF695:
    COP [BranchIfPlayerAt] ( #$0180, #$0060, &code_0AF0A3 )
    COP [BranchIfPlayerAt] ( #$0180, #$01E0, &code_0AF0A3 )
    LDA #$0002
    JSL $@chunk_008000.code_00B10F
    BCC code_0AF6B0
    COP [Die]
} >
]

code_0AF6B0 {
    COP [SetDeathCallback] ( @code_0AFC13 )
    COP [SetHitCallback] ( &code_0AF8BD )
    LDA #$0001
    STA $7F100C, X
    STA $7F100E, X
    LDA #$8011
    TSB $12
    COP [BranchIfFlagByte] ( #87, #01, &code_0AF6F6 )
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #01, #13, #0F, #15, &code_0AF6DA )
    RTL 
}

code_0AF6DA {
    COP [ExitIfFlagByte] ( #86, #01 )
    LDA $14
    STA $moveXAlt, X
    LDA #$0100
    STA $moveYAlt, X
    COP [StageMove] ( #14, #02, #FF )
    COP [TickMove]
    COP [ExitIfFlagByte] ( #02, #01 )
}

code_0AF6F6 {
    LDA #$0000
    STA $orbitAngle, X

  code_0AF6FD:
    COP [BranchIfFlagByte] ( #0E, #01, &code_0AFCB4 )
    JSR $&code_0AF7A8
    COP [MoveToward] ( #14, #01 )
    COP [BranchIfPlayerNear] ( #05, &code_0AF711 )
    BRA loc_0AF715
}

code_0AF711 {
    COP [CallScript] ( &code_0AF7D9 )

  loc_0AF715:
    JSR $&code_0AF75D
    JSR $&code_0AF7A8
    COP [MoveToward] ( #14, #01 )
    COP [BranchIfPlayerNear] ( #05, &code_0AF726 )
    BRA loc_0AF72A
}

code_0AF726 {
    COP [CallScript] ( &code_0AF7D9 )

  loc_0AF72A:
    JSR $&code_0AF77F
    BCC code_0AF6FD

  loc_0AF72F:
    JSR $&code_0AF7A8
    COP [MoveToward] ( #14, #01 )
    COP [BranchIfPlayerNear] ( #05, &code_0AF73D )
    BRA loc_0AF741
}

code_0AF73D {
    COP [CallScript] ( &code_0AF7D9 )

  loc_0AF741:
    JSR $&code_0AF75D
    JSR $&code_0AF7A8
    COP [MoveToward] ( #14, #01 )
    COP [BranchIfPlayerNear] ( #05, &code_0AF752 )
    BRA loc_0AF756
}

code_0AF752 {
    COP [CallScript] ( &code_0AF7D9 )

  loc_0AF756:
    JSR $&code_0AF794
    BCC loc_0AF72F
    BRA code_0AF6FD
}

code_0AF75D {
    COP [RngByte]
    AND #$0001
    BNE loc_0AF773
    LDA $7F100C, X
    CMP #$0003
    BCS loc_0AF779

  loc_0AF76D:
    INC 
    STA $7F100C, X
    RTS 

  loc_0AF773:
    LDA $7F100C, X
    BEQ loc_0AF76D

  loc_0AF779:
    DEC 
    STA $7F100C, X
    RTS 
}

code_0AF77F {
    LDA $7F100E, X
    CMP #$0003
    BCS loc_0AF78E
    INC 
    STA $7F100E, X
    RTS 

  loc_0AF78E:
    DEC 
    STA $7F100E, X
    RTS 
}

code_0AF794 {
    LDA $7F100E, X
    BEQ loc_0AF7A1
    DEC 
    STA $7F100E, X
    CLC 
    RTS 

  loc_0AF7A1:
    INC 
    STA $7F100E, X
    SEC 
    RTS 
}

code_0AF7A8 {
    PHX 
    LDA $7F100C, X
    ASL 
    TAX 
    LDA $@code_0AF7C9, X
    PLX 
    STA $moveXAlt, X
    PHX 
    LDA $7F100E, X
    ASL 
    TAX 
}

code_0AF7BF {
    LDA $@code_0AF7C9+8, X
    PLX 
    STA $moveYAlt, X
    RTS 
}

code_0AF7C9 {
    CLC 
    BRK #$58
    BRK #$A8
    BRK #$E8
    BRK #$58
    BRK #$D8
    BRK #$58
    ORA ($D8, X)
    ORA ($02, X)
    BRA loc_0AF7F1

  loc_0AF7DC:
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #18 )
    COP [AnimOnce]
    COP [PlaySoundCh1] ( #1D )
    COP [SpawnLastRel] ( @code_0AF81F, #00, #00, #$0300 )
    COP [SpawnLastRel] ( @code_0AF839, #00, #00, #$0300 )
    COP [SpawnLastRel] ( @code_0AF853, #00, #00, #$0300 )
    COP [SpawnLastRel] ( @code_0AF86D, #00, #00, #$0300 )
    COP [StageSpriteFrame] ( #19 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]
    LDA $orbitAngle, X
    INC 
    STA $orbitAngle, X
    COP [RestoreSavedPtr]
}

code_0AF81F {
    JSR $&code_0AF9A3
    COP [BranchIfSolidOffset] ( #FD, #00, &code_0AF8BB )
    JSR $&code_0AF9C8
    LDA $moveXAlt, X
    CLC 
    ADC #$FFD0
    STA $moveXAlt, X
    BRA loc_0AF885
}

code_0AF839 {
    JSR $&code_0AF9A3
    COP [BranchIfSolidOffset] ( #03, #00, &code_0AF8BB )
    JSR $&code_0AF9C8
    LDA $moveXAlt, X
    CLC 
    ADC #$0030
    STA $moveXAlt, X
    BRA loc_0AF885
}

code_0AF853 {
    JSR $&code_0AF9A3
    COP [BranchIfSolidOffset] ( #00, #03, &code_0AF8BB )
    JSR $&code_0AF9C8
    LDA $moveYAlt, X
    CLC 
    ADC #$0030
    STA $moveYAlt, X
    BRA loc_0AF885
}

code_0AF86D {
    JSR $&code_0AF9A3
    COP [BranchIfSolidOffset] ( #00, #FD, &code_0AF8BB )
    JSR $&code_0AF9C8
    LDA $moveYAlt, X
    CLC 
    ADC #$FFD0
    STA $moveYAlt, X

  loc_0AF885:
    COP [MoveToward] ( #1A, #03 )
    COP [OrActorFlags] ( #$0088 )
    LDA #$AC84
    STA $statsPtr, X
    LDA #$0006
    STA $currentHp, X
    COP [StageSpriteFrame] ( #20 )
    COP [AnimOnce]
    COP [PlaySoundCh1] ( #1F )
    LDA #$0011
    TSB $12
    COP [StageSpriteFrame] ( #1B )
    COP [AnimOnce]
    COP [SolidHighHere]
    LDA #$0200
    TRB $10
    COP [StageSpriteFrame] ( #26 )
    COP [AnimOnce]
    COP [ClearLowHere]
}

code_0AF8BB {
    COP [Die]
}

code_0AF8BD {
    COP [AndActorFlags] ( #$FFFD )
    COP [SpawnMarkedAfter] ( @code_0AF8E0, #$0200 )
    COP [SpawnMarkedAfter] ( @code_0AF8F3, #$0200 )
    COP [SpawnMarkedAfter] ( @code_0AF900, #$0200 )
    COP [SpawnMarkedAfter] ( @code_0AF90D, #$0200 )
    JMP $&code_0AF6FD
}

code_0AF8E0 {
    LDA $24
    STA $moveYAlt, X
    LDA #$0000
    STA $moveXAlt, X
    STA $orbitAngle, X
    BRA loc_0AF91A
}

code_0AF8F3 {
    LDA #$0080
    STA $moveXAlt, X
    STA $orbitAngle, X
    BRA loc_0AF91A
}

code_0AF900 {
    LDA #$0040
    STA $moveXAlt, X
    STA $orbitAngle, X
    BRA loc_0AF91A
}

code_0AF90D {
    LDA #$00C0
    STA $moveXAlt, X
    STA $orbitAngle, X
    BRA loc_0AF91A

  loc_0AF91A:
    LDA #$0002
    STA $7F100C, X
    LDA #$0000
    STA $orbitDiameter, X
    LDA #$0003
    STA $7F100E, X
    COP [StageSprAndHitbox] ( #29 )

  loc_0AF932:
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0AF932
    LDA $08
    STZ $08
    STA $26
    COP [SetEntryExit]
    LDY $24
    JSL $@chunk_008000.code_00F4BD
    LDA $orbitAngle, X
    CLC 
    ADC $7F100C, X
    STA $orbitAngle, X
    LDA $0036
    AND #$0003
    BNE loc_0AF980
    LDA $orbitDiameter, X
    CMP #$0080
    BCS loc_0AF973

  loc_0AF966:
    CLC 
    ADC $7F100E, X
    STA $orbitDiameter, X
    BPL loc_0AF980
    BMI loc_0AF985

  loc_0AF973:
    LDA #$FFFC
    STA $7F100E, X
    LDA $orbitDiameter, X
    BRA loc_0AF966

  loc_0AF980:
    DEC $26
    BMI loc_0AF932
    RTL 

  loc_0AF985:
    LDA $moveXAlt, X
    BEQ loc_0AF98D
    COP [Die]

  loc_0AF98D:
    COP [BranchIfFlagByte] ( #0E, #01, &code_0AF9A1 )
    PHX 
    PHD 
    LDA $moveYAlt, X
    TAX 
    TCD 
    COP [SetHitCallback] ( &code_0AF8BD )
    PLD 
    PLX 
}

code_0AF9A1 {
    COP [Die]
}

code_0AF9A3 {
    LDA $14
    STA $7F100C, X
    LDA $playerWallType
    AND #$FFF0
    CLC 
    ADC #$0008
    STA $14
    LDA $16
    STA $7F100E, X
    LDA $playerSpeedEw
    AND #$FFF0
    CLC 
    ADC #$0010
    STA $16
    RTS 
}

code_0AF9C8 {
    LDA $14
    STA $moveXAlt, X
    LDA $16
    STA $moveYAlt, X
    LDA $7F100C, X
    STA $14
    LDA $7F100E, X
    STA $16
    RTS 
}

code_0AF9E1 {
    COP [WaitByte] ( #04 )
    LDY $24
    LDA $0014, Y
    CMP $14
    BNE loc_0AF9F4
    LDA $0016, Y
    CMP $16
    BEQ code_0AF9E1

  loc_0AF9F4:
    COP [SpawnAfterFlags] ( @code_0AFA09, #$0300 )
    LDY $24
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    STA $16
    BRA code_0AF9E1
}

code_0AFA09 {
    COP [StageSpriteFrame] ( #24 )
    COP [AnimOnce]
    COP [Die]
}

code_0AFA10 {
    COP [SetFlagByte] ( #0E )
    LDY $26
    LDA $0010, Y
    BIT #$0040
    BNE code_0AFA2B
    LDA $sceneCurrent
    CMP #$0067
    BNE code_0AFA2B
    COP [PrintWideString] ( &widestring_0AFBC0 )
    BRA loc_0AFA45

  code_0AFA2B:
    LDA $slopeCurvePtrB
    BIT #$0200
    BEQ loc_0AFA36
    COP [SetEntryContinue]
    RTL 

  loc_0AFA36:
    LDA #$0020
    TSB $slopeCurvePtrB
    COP [SpawnLastRel] ( @code_0AA2B1, #00, #00, #$2000 )

  loc_0AFA45:
    COP [SpawnLastRel] ( @code_0AFC56, #00, #F0, #$2300 )
    COP [WaitByte] ( #1D )
    COP [Die]
}

widestring_0AFA53 `[DEF][TPL:2]キュウケツキ男:[N]よく ミステリードールを[N]見つけ出してくれた![FIN]変なヤツが きゅうでんにやってきた[N]と 思っていたが···[N]ふっ.[N]およがせておいて 正解だったよ.[FIN][TPL:1]キュウケツキ女:[N]なによ.[N]あんたは えものが やってきたとか[N]よだれを たらしてたくせにっ![FIN]ちょっと 若い子が くれば[N]これだものっ![N]あんたは 食べることしか 考えて[N]ないのっ?[FIN][TPL:2]キュウケツキ男:[N]そういう お前だって!![FIN]まあ まて.[N]今は ふうふげんかを してる場合[N]じゃない.[FIN]まずは その ミステリードールを[N]いただくとしよう.[N]そこの お前! かくごしろっ!!![PAL:0][END]`

widestring_0AFB8C `[DLG:3,11][SIZ:D,4,0][TPL:2]キュウケツキ男:[N]きさまっ! よくも わが妻をっ!![N]ゆるさんっ!!!![PAL:0][END]`

widestring_0AFBC0 `[DLG:3,11][SIZ:D,4,0][TPL:1]キュウケツキ女: ふんっ.[N]あんな男 死んで せいせいしたわっ[N]さあ 次は お前の番っ!![N]かくご おしっ!![PAL:0][END]`

widestring_0AFC0B `わ[F8]がPがががB`

code_0AFC13 {
    COP [SetFlagByte] ( #0F )
    LDY $26
    LDA $0010, Y
    BIT #$0040
    BNE loc_0AFC2E
    LDA $sceneCurrent
    CMP #$0067
    BNE loc_0AFC2E
    COP [PrintWideString] ( &widestring_0AFB8C )
    BRA loc_0AFC48

  loc_0AFC2E:
    LDA $slopeCurvePtrB
    BIT #$0200
    BEQ loc_0AFC39
    COP [SetEntryContinue]
    RTL 

  loc_0AFC39:
    LDA #$0020
    TSB $slopeCurvePtrB
    COP [SpawnLastRel] ( @code_0AA2B1, #00, #00, #$2000 )

  loc_0AFC48:
    COP [SpawnLastRel] ( @code_0AFC56, #00, #F0, #$2300 )
    COP [WaitByte] ( #1D )
    COP [Die]
}

code_0AFC56 {
    COP [SetMetasprite] ( @table_0EE000 )
    COP [LoopInit] ( #03 )
    COP [SpawnLastRel] ( @code_0AFC7D, #00, #00, #$0302 )
    COP [WaitByte] ( #01 )
    COP [SpawnLastRel] ( @code_0AFC8A, #00, #00, #$0302 )
    COP [WaitByte] ( #05 )
    COP [LoopNext]
    COP [JumpScript] ( @chunk_008000.code_00DCA9 )
}

code_0AFC7D {
    JSR $&code_0AFC97
    COP [PlaySoundCh1] ( #06 )
    COP [StageSpriteFrame] ( #07 )
    COP [AnimOnce]
    COP [Die]
}

code_0AFC8A {
    JSR $&code_0AFC97
    COP [PlaySoundCh1] ( #06 )
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    COP [Die]
}

code_0AFC97 {
    COP [RngByte]
    AND #$003F
    SEC 
    SBC #$001F
    CLC 
    ADC $16
    STA $16
    COP [RngByte]
    AND #$001F
    SEC 
    SBC #$000F
    CLC 
    ADC $14
    STA $14
    RTS 
}

code_0AFCB4 {
    COP [SpawnMarkedAfter] ( @code_0AF9E1, #$2200 )
    COP [SetHitCallback] ( #$0000 )
    COP [SetDeathCallback] ( @code_0AFA2B )
    COP [AndActorFlags] ( #$FFFD )

  loc_0AFCC8:
    COP [RngByte]
    STA $moveXAlt, X
    COP [RngByte]
    ASL 
    STA $moveYAlt, X
    COP [MoveToward] ( #14, #03 )
    COP [BranchIfPlayerNear] ( #06, &code_0AFCE6 )
    COP [StageSpriteLoop] ( #13, #3C )
    COP [AnimLoop]
    BRA loc_0AFCC8
}

code_0AFCE6 {
    COP [StageSpriteFrame] ( #15 )
    COP [AnimOnce]
    COP [PlaySoundCh1] ( #1E )
    COP [SpawnLastRel] ( @code_0AFD3D, #00, #00, #$0200 )
    COP [SpawnLastRel] ( @code_0AFD54, #00, #00, #$0200 )
    COP [SpawnLastRel] ( @code_0AFD49, #00, #00, #$0200 )
    COP [SpawnLastRel] ( @code_0AFD60, #00, #00, #$0200 )
    COP [SpawnLastRel] ( @code_0AFD6B, #00, #00, #$0200 )
    COP [SpawnLastRel] ( @code_0AFD76, #00, #00, #$0200 )
    COP [SpawnLastRel] ( @code_0AFD82, #00, #00, #$0200 )
    COP [SpawnLastRel] ( @code_0AFD8E, #00, #00, #$0200 )
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]
    BRA loc_0AFCC8
}

code_0AFD3D {
    COP [StageSpriteMoveXY] ( #1D, #02, #03 )
    COP [AnimOnce]
    JSR $&code_0AFD99
    BRA code_0AFD3D
}

code_0AFD49 {
    COP [StageSpriteMoveY] ( #1C, #03 )
    COP [AnimOnce]
    JSR $&code_0AFD99
    BRA code_0AFD49
}

code_0AFD54 {
    COP [StageSpriteMoveXY] ( #9D, #01, #03 )
    COP [AnimOnce]
    JSR $&code_0AFD99
    BRA code_0AFD54
}

code_0AFD60 {
    COP [StageSpriteMoveX] ( #25, #04 )
    COP [AnimOnce]
    JSR $&code_0AFD99
    BRA code_0AFD60
}

code_0AFD6B {
    COP [StageSpriteMoveX] ( #A5, #03 )
    COP [AnimOnce]
    JSR $&code_0AFD99
    BRA code_0AFD6B
}

code_0AFD76 {
    COP [StageSpriteMoveXY] ( #1F, #02, #04 )
    COP [AnimOnce]
    JSR $&code_0AFD99
    BRA code_0AFD76
}

code_0AFD82 {
    COP [StageSpriteMoveXY] ( #1F, #01, #04 )
}