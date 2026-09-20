; Acid Spider — major enemy in the Mountain Temple (~735 lines).
; 
; Large spider enemy with acid spit ranged attacks. Patrols
; temple corridors and clings to walls. Complex multi-phase
; AI with web mechanics, ceiling traversal, and acid
; projectile patterns. One of the game's largest regular
; enemy scripts.
---------------------------------------------

?INCLUDE 'ActorMidpointCalc'

!moveXAlt                       7F0018
!moveYAlt                       7F001A
!parentId                       7F001C

---------------------------------------------

mtA0_acid_spider1 [
  actor-def < #06, #00, #00, {

  code_0BA020:
    COP [SetHitCallback] ( &code_0BA0D2 )

  code_0BA024:
    COP [StageSpriteFrame] ( #06 )
    COP [AnimOnce]
    COP [WaitByte] ( #4F )
    COP [BranchIfPlayerInRelTiles] ( #FF, #FA, #01, #00, &code_0BA035 )
    RTL 
} >
]

code_0BA035 {
    COP [BranchIfSolidOffset] ( #00, #FC, &code_0BA024 )
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [SpawnAfterFlags] ( @code_0BA54C, #$0201 )
    BRA code_0BA024
}
---------------------------------------------

mtA0_acid_spider2 [
  actor-def < #05, #00, #00, {

  code_0BA04C:
    COP [SetHitCallback] ( &code_0BA0D2 )

  code_0BA050:
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    COP [WaitByte] ( #4F )
    COP [BranchIfPlayerInRelTiles] ( #FF, #00, #01, #05, &code_0BA061 )
    RTL 
} >
]

code_0BA061 {
    COP [BranchIfSolidOffset] ( #00, #04, &code_0BA050 )
    COP [StageSpriteFrame] ( #0E )
    COP [AnimOnce]
    COP [SpawnAfterFlags] ( @code_0BA55A, #$0201 )
    BRA code_0BA050
}
---------------------------------------------

mtA0_acid_spider3 [
  actor-def < #07, #00, #00, {

  code_0BA078:
    COP [SetHitCallback] ( &code_0BA0D2 )

  code_0BA07C:
    COP [StageSpriteFrame] ( #07 )
    COP [AnimOnce]
    COP [WaitByte] ( #4F )
    COP [BranchIfPlayerInRelTiles] ( #FC, #FF, #00, #01, &code_0BA08D )
    RTL 
} >
]

code_0BA08D {
    COP [BranchIfSolidOffset] ( #FC, #00, &code_0BA07C )
    COP [StageSpriteFrame] ( #10 )
    COP [AnimOnce]
    COP [SpawnAfterFlags] ( @code_0BA502, #$0201 )
    BRA code_0BA07C
}
---------------------------------------------

mtA0_acid_spider4 [
  actor-def < #07, #00, #00, {

  code_0BA0A4:
    COP [SetHFlip]
    COP [SetHitCallback] ( &code_0BA0D2 )

  code_0BA0AA:
    COP [StageSpriteFrame] ( #87 )
    COP [AnimOnce]
    COP [WaitByte] ( #4F )
    COP [BranchIfPlayerInRelTiles] ( #00, #FF, #04, #01, &code_0BA0BB )
    RTL 
} >
]

code_0BA0BB {
    COP [BranchIfSolidOffset] ( #04, #00, &code_0BA0AA )
    COP [StageSpriteFrame] ( #90 )
    COP [AnimOnce]
    COP [SpawnAfterFlags] ( @code_0BA527, #$0201 )
    BRA code_0BA0AA
}
---------------------------------------------

mtA0_acid_spider5 [
  actor-def < #05, #00, #00, {

  code_0BA0D2:
    COP [WaitWhileOffscreen] ( #0B )
    COP [BranchNearerAxis] ( &code_0BA0DB, &code_0BA2EB )
} >
]

code_0BA0DB {
    COP [BranchOnPlayerX] ( #$0000, &code_0BA0E5, &code_0BA0E5, &code_0BA1CE )
}

code_0BA0E5 {
    COP [BranchIfSolidWest] ( &code_0BA12B )
    COP [StageSpriteMoveX] ( #0A, #12 )
    COP [AnimOnce]
    COP [BranchIfPlayerInRelTiles] ( #FB, #FE, #00, #01, &code_0BA0F9 )
    BRA code_0BA0D2
}

code_0BA0F9 {
    COP [RngByte]
    AND #$0001
    BEQ loc_0BA103
    JMP $&code_0BA5BA

  loc_0BA103:
    COP [StageSpriteFrame] ( #10 )
    COP [AnimOnce]
    COP [SpawnAfterFlags] ( @code_0BA502, #$0201 )
    COP [BranchNearerAxis] ( &code_0BA115, &code_0BA2EB )
}

code_0BA115 {
    COP [BranchOnPlayerX] ( #$0000, &code_0BA11F, &code_0BA11F, &code_0BA0DB )
}

code_0BA11F {
    COP [BranchIfSolidEast] ( &code_0BA0D2 )
    COP [StageSpriteMoveX] ( #0A, #11 )
    COP [AnimOnce]
    BRA code_0BA0D2
}

code_0BA12B {
    JSR $&code_0BA5A6
    COP [SetEntryExit]
    LDA #$0011
    TSB $12
    COP [BranchIfSolidOffset] ( #FE, #00, &code_0BA140 )
    LDA #$FFE0
    BRA loc_0BA17E
}

code_0BA140 {
    JSR $&code_0BA5A6
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #FD, #00, &code_0BA150 )
    LDA #$FFD0
    BRA loc_0BA17E
}

code_0BA150 {
    JSR $&code_0BA5A6
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #FC, #00, &code_0BA160 )
    LDA #$FFC0
    BRA loc_0BA17E
}

code_0BA160 {
    JSR $&code_0BA5A6
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #FB, #00, &code_0BA170 )
    LDA #$FFB0
    BRA loc_0BA17E
}

code_0BA170 {
    JSR $&code_0BA5A6
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #FA, #00, &code_0BA5BA )
    LDA #$FFA0

  loc_0BA17E:
    STA $24
    COP [StageSpriteFrame] ( #8D )
    COP [AnimOnce]
    COP [SpawnMarkedAfter] ( @code_0BA2CA, #$0301 )
    LDA $24
    STA $0026, Y
    LDA #$0004

  loc_0BA194:
    PHA 
    COP [SpawnMarkedAfter] ( @code_0BA2BE, #$0301 )
    PLA 
    DEC 
    BPL loc_0BA194
    LDA $14
    CLC 
    ADC $24
    STA $moveXAlt, X
    LDA $16
    STA $moveYAlt, X
    COP [SetEntryContinue]
    LDA $24
    BEQ loc_0BA1B6
    RTL 

  loc_0BA1B6:
    COP [MoveToward] ( #87, #02 )
    LDA #$0010
    TRB $12
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    JMP $&code_0BA0D2
}

code_0BA1CE {
    COP [BranchIfSolidEast] ( &code_0BA216 )
    COP [StageSpriteMoveX] ( #8A, #11 )
    COP [AnimOnce]
    COP [BranchIfPlayerInRelTiles] ( #00, #FE, #05, #01, &code_0BA1E3 )
    JMP $&code_0BA0D2
}

code_0BA1E3 {
    COP [RngByte]
    AND #$0001
    BEQ loc_0BA1ED
    JMP $&code_0BA5BA

  loc_0BA1ED:
    COP [StageSpriteFrame] ( #90 )
    COP [AnimOnce]
    COP [SpawnAfterFlags] ( @code_0BA527, #$0201 )
    COP [BranchNearerAxis] ( &code_0BA1FF, &code_0BA2EB )
}

code_0BA1FF {
    COP [BranchOnPlayerX] ( #$0000, &code_0BA0DB, &code_0BA0DB, &code_0BA209 )
}

code_0BA209 {
    COP [BranchIfSolidWest] ( &code_0BA0D2 )
    COP [StageSpriteMoveX] ( #8A, #12 )
    COP [AnimOnce]
    JMP $&code_0BA0D2
}

code_0BA216 {
    JSR $&code_0BA5A6
    COP [SetEntryExit]
    LDA #$0011
    TSB $12
    COP [BranchIfSolidOffset] ( #02, #00, &code_0BA22B )
    LDA #$0020
    BRA loc_0BA269
}

code_0BA22B {
    JSR $&code_0BA5A6
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #03, #00, &code_0BA23B )
    LDA #$0030
    BRA loc_0BA269
}

code_0BA23B {
    JSR $&code_0BA5A6
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #04, #00, &code_0BA24B )
    LDA #$0040
    BRA loc_0BA269
}

code_0BA24B {
    JSR $&code_0BA5A6
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #05, #00, &code_0BA25B )
    LDA #$0050
    BRA loc_0BA269
}

code_0BA25B {
    JSR $&code_0BA5A6
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #06, #00, &code_0BA5BA )
    LDA #$0060

  loc_0BA269:
    STA $24
    COP [StageSpriteFrame] ( #0D )
    COP [AnimOnce]
    COP [SpawnMarkedAfter] ( @code_0BA2CA, #$0301 )
    LDA $24
    STA $0026, Y
    LDA #$0004

  loc_0BA27F:
    PHA 
    COP [SpawnMarkedAfter] ( @code_0BA2BE, #$0301 )
    PLA 
    DEC 
    BPL loc_0BA27F
    LDA #$0010
    TSB $12
    LDA $14
    CLC 
    ADC $24
    STA $moveXAlt, X
    LDA $16
    STA $moveYAlt, X
    COP [SetEntryContinue]
    LDA $24
    BEQ loc_0BA2A6
    RTL 

  loc_0BA2A6:
    COP [MoveToward] ( #07, #02 )
    LDA #$0010
    TRB $12
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    JMP $&code_0BA0D2
}

code_0BA2BE {
    COP [StageSprAndHitbox] ( #19 )
    COP [AnimOneFrame]
    COP [SetEntryContinue]
    JSL $@ActorMidpointCalc
    RTL 
}

code_0BA2CA {
    LDA $26
    CLC 
    ADC $14
    STA $moveXAlt, X
    LDA $16
    STA $moveYAlt, X
    COP [MoveToward] ( #19, #02 )
    LDA $parentId, X
    TAY 
    LDA #$0000
    STA $0024, Y
    COP [SetEntryContinue]
    RTL 
}

code_0BA2EB {
    COP [BranchOnPlayerY] ( #$0000, &code_0BA2F5, &code_0BA2F5, &code_0BA3E5 )
}

code_0BA2F5 {
    COP [BranchIfSolidNorth] ( &code_0BA33D )
    COP [StageSpriteMoveY] ( #09, #12 )
    COP [AnimOnce]
    COP [BranchIfPlayerInRelTiles] ( #FF, #FA, #01, #FF, &code_0BA30A )
    JMP $&code_0BA0D2
}

code_0BA30A {
    COP [RngByte]
    AND #$0001
    BEQ loc_0BA314
    JMP $&code_0BA5BA

  loc_0BA314:
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [SpawnAfterFlags] ( @code_0BA54C, #$0201 )
    COP [BranchNearerAxis] ( &code_0BA0DB, &code_0BA326 )
}

code_0BA326 {
    COP [BranchOnPlayerY] ( #$0000, &code_0BA330, &code_0BA330, &code_0BA2EB )
}

code_0BA330 {
    COP [BranchIfSolidSouth] ( &code_0BA0D2 )
    COP [StageSpriteMoveY] ( #09, #11 )
    COP [AnimOnce]
    JMP $&code_0BA0D2
}

code_0BA33D {
    JSR $&code_0BA5A6
    COP [SetEntryExit]
    LDA #$0011
    TSB $12
    COP [BranchIfSolidOffset] ( #00, #FE, &code_0BA352 )
    LDA #$FFE0
    BRA loc_0BA390
}

code_0BA352 {
    JSR $&code_0BA5A6
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #00, #FD, &code_0BA362 )
    LDA #$FFD0
    BRA loc_0BA390
}

code_0BA362 {
    JSR $&code_0BA5A6
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #00, #FC, &code_0BA372 )
    LDA #$FFC0
    BRA loc_0BA390
}

code_0BA372 {
    JSR $&code_0BA5A6
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #00, #FB, &code_0BA382 )
    LDA #$FFB0
    BRA loc_0BA390
}

code_0BA382 {
    JSR $&code_0BA5A6
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #00, #FA, &code_0BA5BA )
    LDA #$FFB0

  loc_0BA390:
    STA $24
    COP [StageSpriteFrame] ( #0B )
    COP [AnimOnce]
    COP [SpawnMarkedAfter] ( @code_0BA4E1, #$0301 )
    LDA $24
    STA $0026, Y
    LDA #$0004

  loc_0BA3A6:
    PHA 
    COP [SpawnMarkedAfter] ( @code_0BA4D5, #$0301 )
    PLA 
    DEC 
    BPL loc_0BA3A6
    LDA #$0010
    TSB $12
    LDA $14
    STA $moveXAlt, X
    LDA $24
    CLC 
    ADC $16
    STA $moveYAlt, X
    COP [SetEntryContinue]
    LDA $24
    BEQ loc_0BA3CD
    RTL 

  loc_0BA3CD:
    COP [MoveToward] ( #05, #02 )
    LDA #$0010
    TRB $12
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    JMP $&code_0BA0D2
}

code_0BA3E5 {
    COP [BranchIfSolidSouth] ( &code_0BA42D )
    COP [StageSpriteMoveY] ( #08, #11 )
    COP [AnimOnce]
    COP [BranchIfPlayerInRelTiles] ( #FF, #00, #01, #05, &code_0BA3FA )
    JMP $&code_0BA0D2
}

code_0BA3FA {
    COP [RngByte]
    AND #$0001
    BEQ loc_0BA404
    JMP $&code_0BA5BA

  loc_0BA404:
    COP [StageSpriteFrame] ( #0E )
    COP [AnimOnce]
    COP [SpawnAfterFlags] ( @code_0BA55A, #$0201 )
    COP [BranchNearerAxis] ( &code_0BA0DB, &code_0BA416 )
}

code_0BA416 {
    COP [BranchOnPlayerY] ( #$0000, &code_0BA2EB, &code_0BA2EB, &code_0BA420 )
}

code_0BA420 {
    COP [BranchIfSolidNorth] ( &code_0BA0D2 )
    COP [StageSpriteMoveY] ( #08, #12 )
    COP [AnimOnce]
    JMP $&code_0BA0D2
}

code_0BA42D {
    JSR $&code_0BA5A6
    COP [SetEntryExit]
    LDA #$0011
    TSB $12
    COP [BranchIfSolidOffset] ( #00, #02, &code_0BA442 )
    LDA #$0020
    BRA loc_0BA480
}

code_0BA442 {
    JSR $&code_0BA5A6
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #00, #03, &code_0BA452 )
    LDA #$0030
    BRA loc_0BA480
}

code_0BA452 {
    JSR $&code_0BA5A6
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #00, #04, &code_0BA462 )
    LDA #$0040
    BRA loc_0BA480
}

code_0BA462 {
    JSR $&code_0BA5A6
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #00, #05, &code_0BA472 )
    LDA #$0050
    BRA loc_0BA480
}

code_0BA472 {
    JSR $&code_0BA5A6
    COP [SetEntryExit]
    COP [BranchIfSolidOffset] ( #00, #06, &code_0BA5BA )
    LDA #$0060

  loc_0BA480:
    STA $24
    COP [StageSpriteFrame] ( #0C )
    COP [AnimOnce]
    COP [SpawnMarkedAfter] ( @code_0BA4E1, #$0301 )
    LDA $24
    STA $0026, Y
    LDA #$0004

  loc_0BA496:
    PHA 
    COP [SpawnMarkedAfter] ( @code_0BA4D5, #$0301 )
    PLA 
    DEC 
    BPL loc_0BA496
    LDA #$0010
    TSB $12
    LDA $14
    STA $moveXAlt, X
    LDA $24
    CLC 
    ADC $16
    STA $moveYAlt, X
    COP [SetEntryContinue]
    LDA $24
    BEQ loc_0BA4BD
    RTL 

  loc_0BA4BD:
    COP [MoveToward] ( #06, #02 )
    LDA #$0010
    TRB $12
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    COP [KillNext]
    JMP $&code_0BA0D2
}

code_0BA4D5 {
    COP [StageSprAndHitbox] ( #18 )
    COP [AnimOneFrame]
    COP [SetEntryContinue]
    JSL $@ActorMidpointCalc
    RTL 
}

code_0BA4E1 {
    LDA $14
    STA $moveXAlt, X
    LDA $26
    CLC 
    ADC $16
    STA $moveYAlt, X
    COP [MoveToward] ( #18, #02 )
    LDA $parentId, X
    TAY 
    LDA #$0000
    STA $0024, Y
    COP [SetEntryContinue]
    RTL 
}

code_0BA502 {
    COP [PlaySoundCh1] ( #1E )
    COP [AddPosition] ( #00, #F8 )
    LDA $14
    SEC 
    SBC #$0040
    STA $moveXAlt, X
    LDA $16
    CLC 
    ADC #$0008
    STA $moveYAlt, X
    COP [OrActorFlags] ( #$0010 )
    COP [MoveToward] ( #15, #03 )
    BRA loc_0BA578
}

code_0BA527 {
    COP [PlaySoundCh1] ( #1E )
    COP [AddPosition] ( #00, #F8 )
    LDA $14
    CLC 
    ADC #$0040
    STA $moveXAlt, X
    LDA $16
    CLC 
    ADC #$0008
    STA $moveYAlt, X
    COP [OrActorFlags] ( #$0010 )
    COP [MoveToward] ( #95, #03 )
    BRA loc_0BA578
}

code_0BA54C {
    COP [PlaySoundCh1] ( #1E )
    COP [StageSprAndHitbox] ( #14 )
    LDA $16
    CLC 
    ADC #$FFC0
    BRA loc_0BA566
}

code_0BA55A {
    COP [PlaySoundCh1] ( #1E )
    COP [StageSprAndHitbox] ( #13 )
    LDA $16
    CLC 
    ADC #$0040

  loc_0BA566:
    STA $moveYAlt, X
    LDA $14
    STA $moveXAlt, X
    COP [OrActorFlags] ( #$0010 )
    COP [MoveToward] ( #FF, #03 )

  loc_0BA578:
    COP [AndActorFlags] ( #$FFEF )
    COP [BranchIfSolid] ( &code_0BA593 )
    COP [StageSpriteFrame] ( #11 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #12, #06 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #16, #0A )
    COP [AnimLoop]
    COP [Die]
}

code_0BA593 {
    COP [LoopInit] ( #10 )
    LDA #$2000
    TSB $10
    COP [SetEntryExit]
    LDA #$2000
    TRB $10
    COP [LoopNext]
    COP [Die]
}

code_0BA5A6 {
    PHD 
    LDA #$0000
    TCD 
    LDA [$80], Y
    AND #$000F
    PLD 
    CMP #$000F
    BCS loc_0BA5B7
    RTS 

  loc_0BA5B7:
    PLA 
    COP [SetEntryExit]
}

code_0BA5BA {
    LDA #$0010
    TRB $12
    COP [RngByte]
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0BA5CD )
}

code_list_0BA5CD [
  &code_0BA0E5   ;00
  &code_0BA1CE   ;01
  &code_0BA3E5   ;02
  &code_0BA2F5   ;03
]