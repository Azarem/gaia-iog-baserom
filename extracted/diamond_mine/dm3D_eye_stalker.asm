!sceneCurrent                   0644
!playerXPos                     09A2
!playerYPos                     09A4
!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

dm3D_eye_stalker1 [
  actor-def < #16, #00, #03, {

  code_0AB0B6:
    COP [OrActorFlags] ( #$0008 )
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #03, &code_0AB0C9 )
    RTL 
} >
]

code_0AB0C9 {
    COP [StageSpriteFrame] ( #1B )
    COP [AnimOnce]
    COP [ClearLowHere]
    LDA #$0300
    TRB $10
    JMP $&code_0AB125
}

sE9_eye_stalker2 [
  actor-def < #16, #00, #03, {

  code_0AB0DB:
    COP [OrActorFlags] ( #$0008 )
    COP [SetSpritePalette] ( #04 )
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #03, &code_0AB0F1 )
    RTL 
} >
]

code_0AB0F1 {
    COP [SetSpritePalette] ( #00 )
    COP [StageSpriteFrame] ( #1B )
    COP [AnimOnce]
    COP [ClearLowHere]
    LDA #$0300
    TRB $10
    JMP $&code_0AB125
}

dm3D_eye_stalker3 [
  actor-def < #16, #00, #00, {

  code_0AB106:
    COP [OrActorFlags] ( #$0008 )

  loc_0AB10A:
    COP [WaitWhileOffscreen] ( #0F )
    LDA $10
    BIT #$4000
    BNE loc_0AB10A

  code_0AB114:
    COP [BranchIfPlayerNear] ( #03, &code_0AB12B )

  code_0AB119:
    COP [BranchIfPlayerNear] ( #05, &code_0AB148 )
    LDA $10
    BIT #$4000
    BNE loc_0AB10A
} >
]

code_0AB125 {
    COP [CallScript] ( &code_0AB14E )
    BRA code_0AB114
}

code_0AB12B {
    LDA $sceneCurrent
    CMP #$00E9
    BNE loc_0AB138
    COP [SetEntryExitNow] ( @code_0AB119 )

  loc_0AB138:
    LDA #$0300
    TSB $10
    COP [CallScript] ( &code_0AB3CA )
    LDA #$0300
    TRB $10
    BRA code_0AB114
}

code_0AB148 {
    COP [CallScript] ( &code_0AB220 )
    BRA code_0AB125
}

code_0AB14E {
    LDA $28
    SEC 
    SBC #$0016
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0AB160 )
}

code_list_0AB160 [
  &code_0AB16E   ;00
  &code_0AB19C   ;01
  &code_0AB1CA   ;02
  &code_0AB1F8   ;03
]

code_0AB168 {
    COP [SetEntryExit]
    COP [BranchIfSolidWest] ( &code_0AB19C )
}

code_0AB16E {
    COP [StageSpriteFrame] ( #18 )
    COP [AnimOnce]

  loc_0AB173:
    COP [BranchIfSolidWest] ( &code_0AB196 )
    COP [StageSpriteMoveX] ( #18, #02 )
    COP [AnimOnce]
    COP [BranchNearerAxis] ( &code_0AB183, &code_0AB1CA )
}

code_0AB183 {
    COP [BranchOnPlayerX] ( #$0080, &code_0AB18D, &code_0AB18D, &code_0AB19C )
}

code_0AB18D {
    COP [SetEntryExit]
    COP [BranchIfPlayerNear] ( #05, &code_0AB114 )
    BRA loc_0AB173
}

code_0AB196 {
    COP [SetEntryExit]
    COP [BranchIfSolidEast] ( &code_0AB1CA )
}

code_0AB19C {
    COP [StageSpriteFrame] ( #98 )
    COP [AnimOnce]

  loc_0AB1A1:
    COP [BranchIfSolidEast] ( &code_0AB1C4 )
    COP [StageSpriteMoveX] ( #98, #01 )
    COP [AnimOnce]
    COP [BranchNearerAxis] ( &code_0AB1B1, &code_0AB1CA )
}

code_0AB1B1 {
    COP [BranchOnPlayerX] ( #$0080, &code_0AB18D, &code_0AB1BB, &code_0AB1BB )
}

code_0AB1BB {
    COP [SetEntryExit]
    COP [BranchIfPlayerNear] ( #05, &code_0AB114 )
    BRA loc_0AB1A1
}

code_0AB1C4 {
    COP [SetEntryExit]
    COP [BranchIfSolidSouth] ( &code_0AB1F8 )
}

code_0AB1CA {
    COP [StageSpriteFrame] ( #16 )
    COP [AnimOnce]

  loc_0AB1CF:
    COP [BranchIfSolidSouth] ( &code_0AB1F2 )
    COP [StageSpriteMoveY] ( #16, #01 )
    COP [AnimOnce]
    COP [BranchNearerAxis] ( &code_0AB16E, &code_0AB1DF )
}

code_0AB1DF {
    COP [BranchOnPlayerY] ( #$0080, &code_0AB217, &code_0AB1E9, &code_0AB1E9 )
}

code_0AB1E9 {
    COP [SetEntryExit]
    COP [BranchIfPlayerNear] ( #05, &code_0AB114 )
    BRA loc_0AB1CF
}

code_0AB1F2 {
    COP [SetEntryExit]
    COP [BranchIfSolidNorth] ( &code_0AB16E )
}

code_0AB1F8 {
    COP [StageSpriteFrame] ( #17 )
    COP [AnimOnce]

  loc_0AB1FD:
    COP [BranchIfSolidNorth] ( &code_0AB168 )
    COP [StageSpriteMoveY] ( #17, #02 )
    COP [AnimOnce]
    COP [BranchNearerAxis] ( &code_0AB16E, &code_0AB20D )
}

code_0AB20D {
    COP [BranchOnPlayerY] ( #$0080, &code_0AB217, &code_0AB217, &code_0AB1E9 )
}

code_0AB217 {
    COP [SetEntryExit]
    COP [BranchIfPlayerNear] ( #05, &code_0AB114 )
    BRA loc_0AB1FD
}

code_0AB220 {
    COP [BranchOnPlayerX] ( #$0030, &code_0AB22A, &code_0AB2B2, &code_0AB26E )
}

code_0AB22A {
    COP [StageSpriteFrame] ( #18 )
    COP [AnimOnce]
    JSR $&code_0ADD66
    LDA $moveXAlt, X
    CLC 
    ADC #$0060
    STA $moveXAlt, X
    LDA #$0008
    TSB $10
    BRA loc_0AB24E

  code_0AB245:
    JSR $&code_0ADD83
    COP [MoveToward] ( #18, #02 )
    BRA loc_0AB256

  loc_0AB24E:
    COP [MoveToward] ( #18, #02 )
    COP [BranchIfNotOnGridline] ( &code_0AB245 )

  loc_0AB256:
    LDA #$0008
    TRB $10
    COP [StageSpriteFrame] ( #24 )
    COP [AnimOnce]
    COP [SpawnMarkedAfterRel] ( @code_0AB39E, #E8, #EB, #$2200 )
    COP [WaitByte] ( #05 )
    COP [RestoreSavedPtr]
}

code_0AB26E {
    COP [StageSpriteFrame] ( #98 )
    COP [AnimOnce]
    JSR $&code_0ADD66
    LDA $moveXAlt, X
    SEC 
    SBC #$0050
    STA $moveXAlt, X
    LDA #$0008
    TSB $10
    BRA loc_0AB292

  code_0AB289:
    JSR $&code_0ADD83
    COP [MoveToward] ( #98, #02 )
    BRA loc_0AB29A

  loc_0AB292:
    COP [MoveToward] ( #98, #02 )
    COP [BranchIfNotOnGridline] ( &code_0AB289 )

  loc_0AB29A:
    LDA #$0008
    TRB $10
    COP [StageSpriteFrame] ( #A4 )
    COP [AnimOnce]
    COP [SpawnMarkedAfterRel] ( @code_0AB399, #18, #EB, #$2200 )
    COP [WaitByte] ( #05 )
    COP [RestoreSavedPtr]
}

code_0AB2B2 {
    COP [BranchOnPlayerY] ( #$0030, &code_0AB2BC, &code_0AB2BC, &code_0AB300 )
}

code_0AB2BC {
    COP [StageSpriteFrame] ( #17 )
    COP [AnimOnce]
    JSR $&code_0ADD66
    LDA $moveYAlt, X
    CLC 
    ADC #$0060
    STA $moveYAlt, X
    LDA #$0008
    TSB $10
    BRA loc_0AB2E0

  code_0AB2D7:
    JSR $&code_0ADD83
    COP [MoveToward] ( #17, #02 )
    BRA loc_0AB2E8

  loc_0AB2E0:
    COP [MoveToward] ( #17, #02 )
    COP [BranchIfNotOnGridline] ( &code_0AB2D7 )

  loc_0AB2E8:
    LDA #$0008
    TRB $10
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]
    COP [SpawnMarkedAfterRel] ( @code_0AB344, #00, #F8, #$2200 )
    COP [WaitByte] ( #05 )
    COP [RestoreSavedPtr]
}

code_0AB300 {
    COP [StageSpriteFrame] ( #16 )
    COP [AnimOnce]
    JSR $&code_0ADD66
    LDA $moveYAlt, X
    SEC 
    SBC #$0060
    STA $moveYAlt, X
    LDA #$0008
    TSB $10
    BRA loc_0AB324

  code_0AB31B:
    JSR $&code_0ADD83
    COP [MoveToward] ( #16, #02 )
    BRA loc_0AB32C

  loc_0AB324:
    COP [MoveToward] ( #16, #02 )
    COP [BranchIfNotOnGridline] ( &code_0AB31B )

  loc_0AB32C:
    LDA #$0008
    TRB $10
    COP [StageSpriteFrame] ( #22 )
    COP [AnimOnce]
    COP [SpawnMarkedAfterRel] ( @code_0AB36D, #00, #07, #$2202 )
    COP [WaitByte] ( #05 )
    COP [RestoreSavedPtr]
}

code_0AB344 {
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
    BRA loc_0AB384
}

code_0AB36D {
    COP [SetSpritePriority] ( #30 )
    LDA #$2000
    TRB $10
    COP [PlaySoundCh1] ( #20 )
    COP [StageSpriteMoveY] ( #25, #03 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #26, #03 )
    COP [AnimOnce]

  loc_0AB384:
    COP [StageSpriteMoveY] ( #27, #05 )
    COP [AnimOnce]

  loc_0AB38A:
    COP [StageSpriteMoveY] ( #28, #07 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_0AB38A
    COP [Die]
}

code_0AB399 {
    LDA #$4000
    TSB $12
}

code_0AB39E {
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

  loc_0AB3BB:
    COP [StageSpriteMoveX] ( #2C, #08 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_0AB3BB
    COP [Die]
}

code_0AB3CA {
    LDA $28
    SEC 
    SBC #$0016
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0AB3DC )
}

code_list_0AB3DC [
  &code_0AB3E4   ;00
  &code_0AB408   ;01
  &code_0AB42C   ;02
  &code_0AB42C   ;03
]

code_0AB3E4 {
    COP [SolidHighHere]
    COP [StageSpriteFrame] ( #19 )
    COP [AnimOnce]
    COP [LoopInit] ( #0C )
    COP [StageSpriteLoop] ( #1A, #08 )
    COP [AnimLoop]
    COP [BranchIfPlayerNear] ( #03, &code_0AB3FB )
    BRA loc_0AB3FF
}

code_0AB3FB {
    COP [LoopNext]
    BRA loc_0AB479

  loc_0AB3FF:
    COP [StageSpriteFrame] ( #1B )
    COP [AnimOnce]
    COP [ClearLowHere]
    COP [RestoreSavedPtr]
}

code_0AB408 {
    COP [SolidHighHere]
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [LoopInit] ( #0C )
    COP [StageSpriteLoop] ( #1D, #08 )
    COP [AnimLoop]
    COP [BranchIfPlayerNear] ( #03, &code_0AB41F )
    BRA loc_0AB423
}

code_0AB41F {
    COP [LoopNext]
    BRA loc_0AB479

  loc_0AB423:
    COP [StageSpriteFrame] ( #1E )
    COP [AnimOnce]
    COP [ClearLowHere]
    COP [RestoreSavedPtr]
}

code_0AB42C {
    COP [SolidHighHere]
    LDA $0E
    BIT #$4000
    BNE loc_0AB457
    COP [StageSpriteFrame] ( #1F )
    COP [AnimOnce]
    COP [LoopInit] ( #0C )
    COP [StageSpriteLoop] ( #20, #08 )
    COP [AnimLoop]
    COP [BranchIfPlayerNear] ( #03, &code_0AB44A )
    BRA loc_0AB44E
}

code_0AB44A {
    COP [LoopNext]
    BRA loc_0AB479

  loc_0AB44E:
    COP [StageSpriteFrame] ( #21 )
    COP [AnimOnce]
    COP [ClearLowHere]
    COP [RestoreSavedPtr]

  loc_0AB457:
    COP [StageSpriteFrame] ( #9F )
    COP [AnimOnce]
    COP [LoopInit] ( #0C )
    COP [StageSpriteLoop] ( #A0, #08 )
    COP [AnimLoop]
    COP [BranchIfPlayerNear] ( #03, &code_0AB46C )
    BRA loc_0AB470
}

code_0AB46C {
    COP [LoopNext]
    BRA loc_0AB479

  loc_0AB470:
    COP [StageSpriteFrame] ( #A1 )
    COP [AnimOnce]
    COP [ClearLowHere]
    COP [RestoreSavedPtr]

  loc_0AB479:
    LDA #$0300
    TRB $10
    COP [ClearLowHere]
    COP [RngByte]
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0AB48E )
}

code_list_0AB48E [
  &code_0AB22A   ;00
  &code_0AB26E   ;01
  &code_0AB2BC   ;02
  &code_0AB300   ;03
]
---------------------------------------------

code_0ADD66 {
    LDA $playerXPos
    AND #$FFF0
    CLC 
    ADC #$0008
    STA $moveXAlt, X
    LDA $playerYPos
    AND #$FFF0
    CLC 
    ADC #$0020
    STA $moveYAlt, X
    RTS 
}

code_0ADD83 {
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