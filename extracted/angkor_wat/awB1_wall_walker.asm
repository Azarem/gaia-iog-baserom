?INCLUDE 'cop_handlers_script'
?INCLUDE 'EnemyDeathFlash'
?INCLUDE 'field_reveal_object'
?INCLUDE 'smooth_follow_child'
?INCLUDE 'SpawnFieldRevealEffect'
?INCLUDE 'StandardEnemyDefeatHandler'
?INCLUDE 'table_0EE000'

!playerActor                    09AA
!orbitAngle                     7F0010
!loopCounter                    7F0014
!moveXAlt                       7F0018
!moveYAlt                       7F001A
!deathActionIdx                 7F0024
!extendedFlags                  7F002A
!moveScratch1                   7F002C
!moveScratch2                   7F002E

---------------------------------------------

awB1_wall_walker1 [
  actor-def < #13, #00, #00, {

  code_0BBB5F:
    LDA #$0001
    STA $26
    BRA loc_0BBB6B
} >
]

awB1_wall_walker2 [
  actor-def < #13, #00, #00, {

  code_0BBB69:
    STZ $26

  loc_0BBB6B:
    LDA #$0011
    TSB $12
    COP [SetDeathCallback] ( @code_0BBD48 )

  code_0BBB75:
    COP [SetHitCallback] ( &code_0BBB96 )

  loc_0BBB79:
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #06, &code_0BBB88 )
    COP [RngByte]
    AND #$000F
    STA $08
    RTL 
} >
]

code_0BBB88 {
    COP [SpawnMarkedAfterRel] ( @code_0BBD02, #00, #E6, #$0202 )
    COP [WaitByte] ( #77 )
    BRA loc_0BBB79
}

code_0BBB96 {
    COP [StageSpriteFrame] ( #14 )
    COP [AnimOnce]
    LDA $26
    BNE loc_0BBBD1
    COP [SpawnAfterRelFlags] ( @code_0BBC04, #$0000, #$0000, #$0302 )
    JSR $&code_0BBD81
    COP [SetEntryExit]
    COP [SpawnAfterRelFlags] ( @code_0BBC04, #$0000, #$0000, #$0302 )
    JSR $&code_0BBD81
    COP [SetEntryExit]
    COP [SpawnAfterRelFlags] ( @code_0BBC04, #$0000, #$0000, #$0302 )
    COP [StageSpriteFrame] ( #2B )
    COP [AnimOnce]
    BRA code_0BBB75

  loc_0BBBD1:
    COP [SpawnAfterRelFlags] ( @code_0BBC86, #$0000, #$0000, #$0302 )
    JSR $&code_0BBD81
    COP [SetEntryExit]
    COP [SpawnAfterRelFlags] ( @code_0BBC86, #$0000, #$0000, #$0302 )
    JSR $&code_0BBD81
    COP [SetEntryExit]
    COP [SpawnAfterRelFlags] ( @code_0BBC86, #$0000, #$0000, #$0302 )
    COP [StageSpriteFrame] ( #2B )
    COP [AnimOnce]
    JMP $&code_0BBB75
}

code_0BBC04 {
    COP [PlaySoundCh1] ( #28 )
    LDA #$00A0
    TSB $12
    COP [RngByte]
    LSR 
    BCS code_0BBC1F
    COP [BranchIfSolidOffset] ( #00, #03, &code_0BBC1F )
    LDA $16
    CLC 
    ADC #$0030
    BRA loc_0BBC31
}

code_0BBC1F {
    COP [BranchIfSolidOffset] ( #00, #02, &code_0BBD00 )
    LDA $14
    STA $moveXAlt, X
    LDA $16
    CLC 
    ADC #$0020

  loc_0BBC31:
    STA $moveYAlt, X
    LDA $14
    STA $moveXAlt, X
    COP [MoveToward] ( #2F, #02 )
    COP [OrActorFlags] ( #$0080 )
    LDA #$0302
    TRB $10
    COP [BranchOnPlayerX] ( #$0000, &code_0BBC52, &code_0BBC52, &code_0BBC6C )
}

code_0BBC52 {
    COP [SetEntryExit]
    COP [BranchIfSolidWest] ( &code_0BBC6C )
    COP [StageSpriteFrame] ( #A0 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #A7, #04 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ code_0BBC52
    COP [Die]
}

code_0BBC6C {
    COP [SetEntryExit]
    COP [BranchIfSolidEast] ( &code_0BBC52 )
    COP [StageSpriteFrame] ( #20 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #27, #03 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ code_0BBC6C
    COP [Die]
}

code_0BBC86 {
    COP [PlaySoundCh1] ( #28 )
    LDA #$00A0
    TSB $12
    COP [RngByte]
    LSR 
    BCS code_0BBCA1
    COP [BranchIfSolidOffset] ( #01, #02, &code_0BBCA1 )
    LDA $14
    CLC 
    ADC #$0010
    BRA loc_0BBCA9
}

code_0BBCA1 {
    COP [BranchIfSolidOffset] ( #00, #02, &code_0BBD00 )
    LDA $14

  loc_0BBCA9:
    STA $moveXAlt, X
    LDA $16
    CLC 
    ADC #$0020
    STA $moveYAlt, X
    COP [MoveToward] ( #2F, #02 )
    COP [OrActorFlags] ( #$0080 )
    LDA #$0302
    TRB $10
    COP [BranchOnPlayerY] ( #$0000, &code_0BBCCE, &code_0BBCCE, &code_0BBCE8 )
}

code_0BBCCE {
    COP [SetEntryExit]
    COP [BranchIfSolidNorth] ( &code_0BBCE8 )
    COP [StageSpriteFrame] ( #1F )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #26, #04 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ code_0BBCCE
    COP [Die]
}

code_0BBCE8 {
    COP [SetEntryExit]
    COP [BranchIfSolidSouth] ( &code_0BBCCE )
    COP [StageSpriteFrame] ( #1F )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #26, #03 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ code_0BBCE8
}

code_0BBD00 {
    COP [Die]
}

code_0BBD02 {
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]
    COP [SpawnAfterRelFlags] ( @code_0BBD19, #$0000, #$0002, #$0202 )
    COP [StageSpriteFrame] ( #24 )
    COP [AnimOnce]
    COP [Die]
}

code_0BBD19 {
    COP [PlaySoundCh1] ( #1E )
    COP [OrActorFlags] ( #$0010 )
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    LDA $playerActor
    STA $24
    LDA #$0003
    STA $0028, X
    LDA #$0002
    STA $loopCounter, X
    SEP #$20
    LDA #$^smooth_follow_child
    PHA 
    REP #$20
    LDA #$&smooth_follow_child-1
    PHA 
    RTL 
}

code_0BBD48 {
    LDA $0AEC
    CMP #$0001
    BNE loc_0BBD55
    COP [JumpScript] ( @StandardEnemyDefeatHandler )

  loc_0BBD55:
    COP [CallScript] ( &code_0BC11B )
    COP [SpawnAfterFlags] ( @field_reveal_object, #$0020 )
    LDA $orbitAngle, X
    STA $0026, Y
    COP [LoopInit] ( #28 )
    COP [StageSpriteFrame] ( #15 )
    COP [AnimOnce]
    LDA #$2000
    TSB $10
    COP [SetEntryExit]
    LDA #$2000
    TRB $10
    COP [SetEntryExit]
    COP [LoopNext]
    COP [Die]
}

code_0BBD81 {
    COP [RngByte]
    AND #$001F
    CLC 
    ADC #$0008
    STA $08
    RTS 
}
---------------------------------------------

awB1_wall_walker3 [
  actor-def < #16, #00, #00, {

  code_0BBFBE:
    JSR $&code_0BC001
    COP [SetSpritePalette] ( #0A )
    COP [WaitWhileOffscreen] ( #15 )
    LDA #$0000
    STA $26
    STA $24
    BRA loc_0BBFE0
} >
]

awB1_wall_walker4 [
  actor-def < #16, #00, #00, {

  code_0BBFD3:
    JSR $&code_0BC001
    COP [SetSpritePalette] ( #0A )
    LDA #$0001
    STA $26
    STA $24

  loc_0BBFE0:
    LDA #$0011
    TSB $12
    COP [SpawnMarkedAfter] ( @code_0BC0EA, #$2000 )
    LDA $orbitAngle, X
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0BBFF9 )
} >
]

code_list_0BBFF9 [
  &code_0BC07C   ;00
  &code_0BC00D   ;01
  &code_0BC0AD   ;02
  &code_0BC047   ;03
]

code_0BC001 {
    LDA $0E
    XBA 
    AND #$0006
    LSR 
    STA $orbitAngle, X
    RTS 
}

code_0BC00D {
    COP [SetEntryExit]

  loc_0BC00F:
    COP [BranchIfSolidWest] ( &code_0BC018 )
    JMP $&code_0BC0B5
}

code_0BC016 {
    COP [SetEntryExit]
}

code_0BC018 {
    COP [BranchIfSolidNorth] ( &code_0BC04F )
    LDA $24
    STA $26
    LDA $26
    EOR #$FFFF
    INC 
    STA $moveScratch2, X
    COP [SetEntryExit]
    LDA $26
    EOR #$FFFF
    INC 
    STA $moveScratch2, X
    LDA $16
    AND #$000F
    BEQ loc_0BC03E
    RTL 

  loc_0BC03E:
    LDA #$0000
    STA $moveScratch2, X
    BRA loc_0BC00F
}

code_0BC047 {
    COP [SetEntryExit]

  loc_0BC049:
    COP [BranchIfSolidNorth] ( &code_0BC051 )
    BRA code_0BC016
}

code_0BC04F {
    COP [SetEntryExit]
}

code_0BC051 {
    COP [BranchIfSolidEast] ( &code_0BC084 )
    LDA $24
    STA $26
    LDA $26
    STA $moveScratch1, X
    COP [SetEntryExit]
    LDA $26
    STA $moveScratch1, X
    LDA $14
    SEC 
    SBC #$0008
    AND #$000F
    BEQ loc_0BC073
    RTL 

  loc_0BC073:
    LDA #$0000
    STA $moveScratch1, X
    BRA loc_0BC049
}

code_0BC07C {
    COP [SetEntryExit]

  loc_0BC07E:
    COP [BranchIfSolidEast] ( &code_0BC086 )
    BRA code_0BC04F
}

code_0BC084 {
    COP [SetEntryExit]
}

code_0BC086 {
    COP [BranchIfSolidSouth] ( &code_0BC0B5 )
    LDA $24
    STA $26
    LDA $26
    STA $moveScratch2, X
    COP [SetEntryExit]
    LDA $26
    STA $moveScratch2, X
    LDA $16
    AND #$000F
    BEQ loc_0BC0A4
    RTL 

  loc_0BC0A4:
    LDA #$0000
    STA $moveScratch2, X
    BRA loc_0BC07E
}

code_0BC0AD {
    COP [SetEntryExit]

  loc_0BC0AF:
    COP [BranchIfSolidSouth] ( &code_0BC0B7 )
    BRA code_0BC084
}

code_0BC0B5 {
    COP [SetEntryExit]
}

code_0BC0B7 {
    COP [BranchIfSolidWest] ( &code_0BC016 )
    LDA $24
    STA $26
    LDA $26
    EOR #$FFFF
    INC 
    STA $moveScratch1, X
    COP [SetEntryExit]
    LDA $26
    EOR #$FFFF
    INC 
    STA $moveScratch1, X
    LDA $14
    SEC 
    SBC #$0008
    AND #$000F
    BEQ loc_0BC0E1
    RTL 

  loc_0BC0E1:
    LDA #$0000
    STA $moveScratch1, X
    BRA loc_0BC0AF
}

code_0BC0EA {
    COP [SetEntryContinue]
    LDY $04
    LDA $0010, Y
    BIT #$0080
    BNE loc_0BC0F7
    RTL 

  loc_0BC0F7:
    LDA $0024, Y
    BNE loc_0BC101
    LDA #$0001
    BRA loc_0BC102

  loc_0BC101:
    ASL 

  loc_0BC102:
    STA $0024, Y
    CMP #$0008
    BCS loc_0BC119
    COP [SetEntryContinue]
    LDY $04
    LDA $0010, Y
    BIT #$0080
    BEQ loc_0BC117
    RTL 

  loc_0BC117:
    BRA code_0BC0EA

  loc_0BC119:
    COP [Die]
}

code_0BC11B {
    COP [PlaySoundCh1] ( #06 )
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
    COP [SpawnLastRel] ( @EnemyDeathFlash, #00, #00, #$0302 )
    COP [SetDungeonKillFlag]
    LDA $extendedFlags, X
    BIT #$0008
    BEQ loc_0BC15A
    COP [ClearLowHere]

  loc_0BC15A:
    LDA $deathActionIdx, X
    BEQ loc_0BC182
    JSL $@cop_handlers_script.TestFlag_0100
    BCS loc_0BC182
    LDA $deathActionIdx, X
    JSL $@cop_handlers_script.SetFlag_0100
    COP [SpawnLastRel] ( @SpawnFieldRevealEffect, #00, #00, #$0342 )
    PHX 
    LDA $deathActionIdx, X
    TYX 
    STA $deathActionIdx, X
    PLX 

  loc_0BC182:
    COP [RestoreSavedPtr]
}