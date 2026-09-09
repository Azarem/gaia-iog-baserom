?INCLUDE 'smooth_follow_child'

!playerActor                    09AA
!orbitAngle                     7F0010
!orbitDiameter                  7F0012
!loopCounter                    7F0014

---------------------------------------------

ec0C_ribber [
  actor-def < #00, #00, #00, {

  code_0A826F:
    COP [WaitWhileOffscreen] ( #08 )
    COP [SetSpritePriority] ( #30 )
    COP [SetEntryExit]

  code_0A8277:
    COP [RngByte]
    STA $orbitAngle, X
    LDA $orbitDiameter, X
    BMI loc_0A82C5
    INC 
    AND #$0003
    STA $orbitDiameter, X
    COP [SetHitCallback] ( &code_0A82B6 )
    COP [BranchIfPlayerNear] ( #04, &code_0A82B6 )

  loc_0A8294:
    LDA $orbitAngle, X
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0A82A4 )
} >
]

code_list_0A82A4 [
  &code_0A82E0   ;00
  &code_0A8313   ;01
  &code_0A8346   ;02
  &code_0A8379   ;03
]

code_0A82AC {
    COP [SetEntryExit]
    COP [RngByte]
    STA $orbitAngle, X
    BRA loc_0A8294
}

code_0A82B6 {
    COP [SetHitCallback] ( #$0000 )
    COP [SnapToGrid]
    LDA #$FFFF
    STA $orbitDiameter, X
    COP [SetEntryContinue]

  loc_0A82C5:
    COP [BranchNearerAxis] ( &code_0A82CB, &code_0A82D5 )
}

code_0A82CB {
    COP [BranchOnPlayerX] ( #$0008, &code_0A82E0, &code_0A82D5, &code_0A8313 )
}

code_0A82D5 {
    COP [BranchOnPlayerY] ( #$0008, &code_0A8346, &code_0A82DF, &code_0A8379 )
}

code_0A82DF {
    RTL 
}

code_0A82E0 {
    LDA $orbitAngle, X
    AND #$0001
    BEQ code_0A82EE
    COP [BranchIfPlayerNear] ( #02, &code_0A83AC )

  code_0A82EE:
    COP [BranchIfSolidWest] ( &code_0A82AC )
    COP [StageSpriteMoveX] ( #07, #12 )
    COP [AnimOnce]
    LDA $orbitDiameter, X
    BEQ loc_0A8301
    JMP $&code_0A8277

  loc_0A8301:
    COP [LoopInit] ( #02 )
    COP [StageSpriteFrame] ( #0B )
    COP [AnimOnce]
    COP [BranchIfPlayerNear] ( #04, &code_0A82B6 )
    COP [LoopNext]
    JMP $&code_0A8277
}

code_0A8313 {
    LDA $orbitAngle, X
    AND #$0001
    BEQ code_0A8321
    COP [BranchIfPlayerNear] ( #02, &code_0A83D0 )

  code_0A8321:
    COP [BranchIfSolidEast] ( &code_0A82AC )
    COP [StageSpriteMoveX] ( #87, #11 )
    COP [AnimOnce]
    LDA $orbitDiameter, X
    BEQ loc_0A8334
    JMP $&code_0A8277

  loc_0A8334:
    COP [LoopInit] ( #02 )
    COP [StageSpriteFrame] ( #8B )
    COP [AnimOnce]
    COP [BranchIfPlayerNear] ( #04, &code_0A82B6 )
    COP [LoopNext]
    JMP $&code_0A8277
}

code_0A8346 {
    LDA $orbitAngle, X
    AND #$0001
    BEQ code_0A8354
    COP [BranchIfPlayerNear] ( #02, &code_0A83F4 )

  code_0A8354:
    COP [BranchIfSolidNorth] ( &code_0A82AC )
    COP [StageSpriteMoveY] ( #05, #12 )
    COP [AnimOnce]
    LDA $orbitDiameter, X
    BEQ loc_0A8367
    JMP $&code_0A8277

  loc_0A8367:
    COP [LoopInit] ( #02 )
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    COP [BranchIfPlayerNear] ( #04, &code_0A82B6 )
    COP [LoopNext]
    JMP $&code_0A8277
}

code_0A8379 {
    LDA $orbitAngle, X
    AND #$0001
    BEQ code_0A8387
    COP [BranchIfPlayerNear] ( #02, &code_0A8418 )

  code_0A8387:
    COP [BranchIfSolidSouth] ( &code_0A82AC )
    COP [StageSpriteMoveY] ( #03, #11 )
    COP [AnimOnce]
    LDA $orbitDiameter, X
    BEQ loc_0A839A
    JMP $&code_0A8277

  loc_0A839A:
    COP [LoopInit] ( #02 )
    COP [StageSpriteFrame] ( #09 )
    COP [AnimOnce]
    COP [BranchIfPlayerNear] ( #04, &code_0A82B6 )
    COP [LoopNext]
    JMP $&code_0A8277
}

code_0A83AC {
    COP [SetHitCallback] ( #$0000 )
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @code_0A843E, #F8, #E0, #$0200 )
    COP [ForceMoveLastChild] ( #04, #00 )
    COP [StageSpriteFrame] ( #1B )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #02, #20 )
    COP [AnimLoop]
    JMP $&code_0A82EE
}

code_0A83D0 {
    COP [SetHitCallback] ( #$0000 )
    COP [StageSpriteFrame] ( #9A )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @code_0A843E, #08, #E0, #$0200 )
    COP [ForceMoveLastChild] ( #03, #00 )
    COP [StageSpriteFrame] ( #9B )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #82, #20 )
    COP [AnimLoop]
    JMP $&code_0A8321
}

code_0A83F4 {
    COP [SetHitCallback] ( #$0000 )
    COP [StageSpriteFrame] ( #18 )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @code_0A843E, #00, #D0, #$0200 )
    COP [ForceMoveLastChild] ( #00, #04 )
    COP [StageSpriteFrame] ( #19 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #01, #20 )
    COP [AnimLoop]
    JMP $&code_0A8354
}

code_0A8418 {
    COP [SetHitCallback] ( #$0000 )
    COP [StageSpriteFrame] ( #16 )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @code_0A843C, #00, #E0, #$0200 )
    COP [ForceMoveLastChild] ( #00, #03 )
    COP [StageSpriteFrame] ( #17 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #00, #20 )
    COP [AnimLoop]
    JMP $&code_0A8387
}

code_0A843C {
    COP [CollPrioritySetMax]
}

code_0A843E {
    COP [OrActorFlags] ( #$0010 )
    LDA #$0080
    TSB $12
    COP [PlaySoundCh1] ( #1E )
    COP [StageSpriteLoop] ( #1C, #02 )
    COP [AnimLoop]
    COP [CollPriorityClearMax]
    COP [StageSpriteLoop] ( #1C, #02 )
    COP [AnimLoop]
    LDA $playerActor
    STA $24
    LDA #$001C
    STA $0028, X
    LDA #$0001
    STA $loopCounter, X
    SEP #$20
    LDA #$^smooth_follow_child
    PHA 
    REP #$20
    LDA #$&smooth_follow_child-1
    PHA 
    RTL 
}