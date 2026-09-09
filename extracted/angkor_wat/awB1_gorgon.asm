?INCLUDE 'camera_drift'
?INCLUDE 'table_0EE000'

!bg1ScrollH                     068A
!bg2ScrollH                     068E
!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

awB1_gorgon [
  actor-def < #00, #00, #00, {

  code_0BB81A:
    COP [WaitWhileOffscreen] ( #0F )
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #04, &code_0BB939 )
    RTL 
} >
]

awB1_gorgon2 [
  actor-def < #00, #00, #20, {

  code_0BB828:
    COP [BranchIfPlayerNear] ( #05, &code_0BB82E )
    RTL 
} >
]

code_0BB82E {
    COP [SpawnAfterFlags] ( @code_0BBA62, #$0300 )
    COP [SpawnAfterFlags] ( @code_0BBA69, #$0300 )
    COP [WaitByte] ( #0F )
    COP [SpawnAfterFlags] ( @code_0BBA80, #$0300 )
    COP [WaitByte] ( #0F )
    COP [SpawnAfterFlags] ( @code_0BBA97, #$0300 )
    COP [WaitByte] ( #0F )
    COP [SpawnAfterFlags] ( @code_0BBAAE, #$0300 )
    COP [WaitByte] ( #0F )
    COP [SpawnAfterFlags] ( @code_0BBAC5, #$0300 )
    COP [WaitByte] ( #0F )
    COP [SpawnAfterFlags] ( @code_0BBADC, #$0300 )
    COP [WaitByte] ( #0F )
    COP [SpawnAfterFlags] ( @code_0BBAF3, #$0300 )
    COP [WaitByte] ( #0F )
    COP [SpawnAfterFlags] ( @code_0BBB0A, #$0300 )
    LDA #$FFFF
    STA $26
    COP [SetEntryContinue]
    LDA $26
    BPL loc_0BB88E
    RTL 

  loc_0BB88E:
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    LDA #$2000
    TRB $10
    BRA loc_0BB8AA

  loc_0BB8A7:
    COP [WaitWhileOffscreen] ( #08 )

  loc_0BB8AA:
    LDA $10
    BIT #$4000
    BNE loc_0BB8A7
    COP [BranchIfPlayerNear] ( #04, &code_0BB994 )
    COP [BranchNearerAxis] ( &code_0BB8BC, &code_0BB8F2 )
}

code_0BB8BC {
    COP [BranchOnPlayerX] ( #$0000, &code_0BB8C6, &code_0BB8C6, &code_0BB8DC )
}

code_0BB8C6 {
    COP [BranchIfSolidWest] ( &code_0BB97C )
    COP [StageSpriteMoveX] ( #05, #12 )
    COP [AnimOnce]
    COP [BranchIfSolidWest] ( &code_0BB97C )
    COP [StageSpriteMoveX] ( #2A, #12 )
    COP [AnimOnce]
    BRA loc_0BB8AA
}

code_0BB8DC {
    COP [BranchIfSolidEast] ( &code_0BB97C )
    COP [StageSpriteMoveX] ( #85, #11 )
    COP [AnimOnce]
    COP [BranchIfSolidEast] ( &code_0BB97C )
    COP [StageSpriteMoveX] ( #AA, #11 )
    COP [AnimOnce]
    BRA loc_0BB8AA
}

code_0BB8F2 {
    COP [BranchOnPlayerY] ( #$0000, &code_0BB8FC, &code_0BB8FC, &code_0BB912 )
}

code_0BB8FC {
    COP [BranchIfSolidNorth] ( &code_0BB97C )
    COP [StageSpriteMoveY] ( #04, #12 )
    COP [AnimOnce]
    COP [BranchIfSolidNorth] ( &code_0BB97C )
    COP [StageSpriteMoveY] ( #29, #12 )
    COP [AnimOnce]
    BRA loc_0BB8AA
}

code_0BB912 {
    COP [BranchIfSolidSouth] ( &code_0BB928 )
    COP [StageSpriteMoveY] ( #03, #11 )
    COP [AnimOnce]
    COP [BranchIfSolidSouth] ( &code_0BB928 )
    COP [StageSpriteMoveY] ( #28, #11 )
    COP [AnimOnce]
    BRA loc_0BB8AA
}

code_0BB928 {
    COP [BranchOnPlayerY] ( #$0010, &code_0BB97C, &code_0BB97C, &code_0BB932 )
}

code_0BB932 {
    COP [BranchIfSolidTypeSouth] ( #08, &code_0BB939 )
    BRA code_0BB97C
}

code_0BB939 {
    LDA #$0011
    TSB $12
    COP [StageSpriteFrame] ( #2C )
    COP [AnimOnce]

  loc_0BB943:
    COP [StageSpriteMoveY] ( #2D, #07 )
    COP [AnimOnce]
    COP [BranchIfSolidType] ( #00, &code_0BB950 )
    BRA loc_0BB943
}

code_0BB950 {
    LDA #$0011
    TRB $12
    COP [PlaySoundCh1] ( #15 )
    COP [SpawnMarkedAfter] ( @code_0BB9BE, #$2000 )
    LDA #$0010
    TSB $10
    COP [SpawnLastRel] ( @code_0BB9DF, #00, #00, #$2000 )
    COP [StageSpriteFrame] ( #2E )
    COP [AnimOnce]
    LDA #$0010
    TRB $10
    COP [KillNext]
    COP [SetSpritePalette] ( #00 )
}

code_0BB97C {
    COP [SetEntryExit]
    COP [RngByte]
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0BB98C )
}

code_list_0BB98C [
  &code_0BB8C6   ;00
  &code_0BB8DC   ;01
  &code_0BB912   ;02
  &code_0BB8FC   ;03
]

code_0BB994 {
    COP [SetEntryExit]
    LDA #$0010
    TSB $10
    COP [SpawnMarkedAfter] ( @code_0BB9BE, #$2000 )
    COP [StageSpriteFrame] ( #07 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #08, #04 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #21 )
    COP [AnimOnce]
    COP [KillNext]
    LDA #$0010
    TRB $10
    COP [SetSpritePalette] ( #00 )
    BRA code_0BB97C
}

code_0BB9BE {
    LDY $24
    LDA $000E, Y
    AND #$F1FF
    STA $000E, Y
    COP [WaitByte] ( #01 )
    LDY $24
    LDA $000E, Y
    AND #$F1FF
    ORA #$0200
    STA $000E, Y
    COP [WaitByte] ( #01 )
    BRA code_0BB9BE
}

code_0BB9DF {
    COP [LoopInit] ( #0F )
    COP [SpawnAfterFlags] ( @code_0BB9FC, #$2300 )
    COP [SpawnLastRel] ( @camera_drift.CameraDriftPatterned, #00, #00, #$2000 )
    CLC 
    ADC #$0020
    STA $08
    COP [LoopNext]
    COP [Die]
}

code_0BB9FC {
    COP [RngByte]
    CLC 
    ADC $bg1ScrollH
    STA $14
    STA $moveXAlt, X
    COP [RngByte]
    CLC 
    ADC $bg2ScrollH
    STA $16
    STA $moveYAlt, X
    COP [BranchIfSolid] ( &code_0BBA54 )
    COP [SpawnAfterFlags] ( @code_0BBA56, #$0300 )
    COP [WaitByte] ( #3B )
    LDA #$2000
    TRB $10
    LDA $bg2ScrollH
    SEC 
    SBC #$0020
    STA $16
    COP [StageMove] ( #18, #04, #FF )
    COP [TickMove]
    COP [PlaySoundCh1] ( #14 )
    COP [StageSpriteLoopMoveY] ( #18, #0B, #45 )
    COP [AnimLoop]
    COP [KillNext]
    LDA #$0100
    TRB $10
    COP [StageSpriteFrame] ( #19 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #30 )
    COP [AnimOnce]
    COP [SetEntryExit]
}

code_0BBA54 {
    COP [Die]
}

code_0BBA56 {
    COP [SetMetasprite] ( @table_0EE000 )

  loc_0BBA5B:
    COP [StageSpriteFrame] ( #31 )
    COP [AnimOnce]
    BRA loc_0BBA5B
}

code_0BBA62 {
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    BRA code_0BBA62
}

code_0BBA69 {
    JSR $&code_0BBB46
    COP [StageMove] ( #09, #06, #FF )
    COP [TickMove]
    COP [PlaySoundCh1] ( #15 )
    COP [StageSpriteLoopMoveY] ( #09, #10, #4A )
    COP [AnimLoop]
    COP [SetEntryContinue]
    RTL 
}

code_0BBA80 {
    JSR $&code_0BBB46
    COP [StageMove] ( #0A, #06, #FF )
    COP [TickMove]
    COP [PlaySoundCh1] ( #15 )
    COP [StageSpriteLoopMoveY] ( #0A, #10, #4A )
    COP [AnimLoop]
    COP [SetEntryContinue]
    RTL 
}

code_0BBA97 {
    JSR $&code_0BBB46
    COP [StageMove] ( #0B, #06, #FF )
    COP [TickMove]
    COP [PlaySoundCh1] ( #15 )
    COP [StageSpriteLoopMoveY] ( #0B, #10, #4A )
    COP [AnimLoop]
    COP [SetEntryContinue]
    RTL 
}

code_0BBAAE {
    JSR $&code_0BBB46
    COP [StageMove] ( #0C, #06, #FF )
    COP [TickMove]
    COP [PlaySoundCh1] ( #15 )
    COP [StageSpriteLoopMoveY] ( #0C, #10, #4A )
    COP [AnimLoop]
    COP [SetEntryContinue]
    RTL 
}

code_0BBAC5 {
    JSR $&code_0BBB46
    COP [StageMove] ( #0D, #06, #FF )
    COP [TickMove]
    COP [PlaySoundCh1] ( #15 )
    COP [StageSpriteLoopMoveY] ( #0D, #10, #4A )
    COP [AnimLoop]
    COP [SetEntryContinue]
    RTL 
}

code_0BBADC {
    JSR $&code_0BBB46
    COP [StageMove] ( #0E, #06, #FF )
    COP [TickMove]
    COP [PlaySoundCh1] ( #15 )
    COP [StageSpriteLoopMoveY] ( #0E, #10, #4A )
    COP [AnimLoop]
    COP [SetEntryContinue]
    RTL 
}

code_0BBAF3 {
    JSR $&code_0BBB46
    COP [StageMove] ( #0F, #06, #FF )
    COP [TickMove]
    COP [PlaySoundCh1] ( #15 )
    COP [StageSpriteLoopMoveY] ( #0F, #11, #4A )
    COP [AnimLoop]
    COP [SetEntryContinue]
    RTL 
}

code_0BBB0A {
    JSR $&code_0BBB46
    LDA $24
    STA $26
    LDA $moveYAlt, X
    CLC 
    ADC #$0010
    STA $moveYAlt, X
    COP [StageMove] ( #10, #08, #FF )
    COP [TickMove]
    LDA $14
    STA $moveXAlt, X
    LDA $16
    SEC 
    SBC #$0010
    STA $moveYAlt, X
    COP [StageMove] ( #10, #04, #FF )
    COP [TickMove]
    LDY $26
    LDA #$0000
    STA $0026, Y
    COP [SetEntryContinue]
    RTL 
}

code_0BBB46 {
    LDA $14
    STA $moveXAlt, X
    LDA $16
    STA $moveYAlt, X
    LDA $bg2ScrollH
    SEC 
    SBC #$0010
    STA $16
    RTS 
}