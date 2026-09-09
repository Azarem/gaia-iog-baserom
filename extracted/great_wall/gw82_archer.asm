?INCLUDE 'ApplyPlayerHitstun'
?INCLUDE 'chunk_03BAE1'
?INCLUDE 'interaction_handlers'
?INCLUDE 'player_transition_handlers'
?INCLUDE 'stats_01ABF0'

!extVelocityX                   0408
!joypadMaskStd                  065A
!playerXPos                     09A2
!playerYPos                     09A4
!playerActor                    09AA
!orbitAngle                     7F0010
!orbitDiameter                  7F0012
!statsPtr                       7F0020
!currentHp                      7F0026

---------------------------------------------

gw83_stone_archer1 [
  actor-def < #07, #00, #03, {

  code_0B8EF5:
    BRA loc_0B8F01

  gw83_stone_archer2:
    ORA [$00]
    ORA $02, S
    TYX 
    BRA loc_0B8F01
} >
]

gw83_stone_archer3 [
  actor-def < #05, #00, #03, {

  loc_0B8F01:
    COP [SetSpritePalette] ( #06 )
    COP [SpawnMarkedAfter] ( @interaction_handlers.push_handler_solid, #$2300 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #03, &code_0B8F15 )
    RTL 
} >
]

code_0B8F15 {
    COP [BranchIfNotOnGridline] ( &code_0B8F1B )
    BRA loc_0B8F20
}

code_0B8F1B {
    COP [SetEntryExitNow] ( @code_0B8F15 )

  loc_0B8F20:
    COP [KillNext]
    COP [LoopInit] ( #1E )
    COP [SetSpritePalette] ( #06 )
    COP [SetEntryExit]
    COP [SetSpritePalette] ( #00 )
    COP [LoopNext]
    COP [LoopInit] ( #0F )
    COP [SetSpritePalette] ( #06 )
    COP [SetEntryExit]
    COP [SetEntryExit]
    COP [SetSpritePalette] ( #00 )
    COP [SetEntryExit]
    COP [LoopNext]
    LDA #$0010
    TRB $12
    LDA #$0300
    TRB $10
    COP [ClearLowHere]
    JMP $&code_0B917A
}

gw83_stone_archer4 [
  actor-def < #05, #00, #01, {

  code_0B8F52:
    LDA #$0010
    TSB $12
    COP [SetSpritePalette] ( #06 )
    COP [SpawnMarkedAfter] ( @interaction_handlers.push_handler_solid, #$2300 )
    COP [SolidHighHere]
    COP [SetHitCallback] ( &code_0B8F6A )
    COP [SetEntryContinue]
    RTL 
} >
]

code_0B8F6A {
    LDA #$0200
    TSB $10
    JMP $&code_0B8F15
}

gw87_statue_archer [
  actor-def < #05, #00, #01, {

  code_0B8F75:
    LDA #$0020
    TSB $12
    COP [SetSpritePalette] ( #06 )
    COP [SpawnMarkedAfter] ( @code_0B8FFB, #$2700 )
    COP [SolidHighHere]
    LDA $currentHp, X
    STA $26

  loc_0B8F8C:
    LDA $14
    STA $orbitAngle, X
    LDA $16
    STA $orbitDiameter, X
    LDA $26
    STA $currentHp, X
    COP [SetEntryContinue]
    LDA $14
    CMP $orbitAngle, X
    BNE loc_0B8FBF
    LDA $16
    CMP $orbitDiameter, X
    BNE loc_0B8FBF
    LDA $currentHp, X
    CMP $26
    BNE loc_0B8F8C
    COP [BranchIfFlagByte] ( #0F, #01, &code_0B8FDD )
    RTL 

  loc_0B8FBF:
    LDA $14
    PHA 
    LDA $16
    PHA 
    LDA $orbitAngle, X
    STA $14
    LDA $orbitDiameter, X
    STA $16
    COP [ClearLowHere]
    PLA 
    STA $16
    PLA 
    STA $14
    COP [SolidHighHere]
    BRA loc_0B8F8C
} >
]

code_0B8FDD {
    LDA #$0200
    TSB $10
    LDA #$0020
    TRB $12
    LDA #$&stats_01ABF0+CC
    STA $statsPtr, X
    LDA $&stats_01ABF0+CC
    AND #$00FF
    STA $currentHp, X
    JMP $&code_0B8F15
}

code_0B8FFB {
    COP [SetSavedPtr] ( &code_0B8FFB )
    COP [SetEntryExit]
    LDY $24
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    STA $16
    LDA $0010, Y
    BIT #$0080
    BEQ loc_0B9016
    RTL 

  loc_0B9016:
    COP [BranchIfButton] ( #$0031, &code_0B901D )

  code_0B901C:
    RTL 
}

code_0B901D {
    COP [BranchIfPlayerNear] ( #0F, &code_0B9023 )
    RTL 
}

code_0B9023 {
    COP [BranchOnPlayerX] ( #$000F, &code_0B90B0, &code_0B902D, &code_0B90B0 )
}

code_0B902D {
    LDY $playerActor
    LDA $0016, Y
    SEC 
    SBC $16
    BPL loc_0B9077
    BPL loc_0B903E
    EOR #$FFFF
    INC 

  loc_0B903E:
    CMP #$0020
    BCC code_0B9075
    LDA $0028, Y
    CMP #$003A
    BNE code_0B9075
    JSL $@chunk_03BAE1.func_03F0CA
    CMP #$0000
    BNE code_0B9075
    COP [BranchIfSolidOffset] ( #00, #FF, &code_0B9075 )
    JSR $&code_0B913D
    COP [AddPosition] ( #00, #F0 )
    COP [PlaySoundCh1] ( #2C )
    COP [LoopInit] ( #10 )
    LDY $04
    LDA $0016, Y
    DEC 
    STA $0016, Y
    COP [LoopNext]
    JSR $&code_0B9149
}

code_0B9075 {
    COP [RestoreSavedPtr]

  loc_0B9077:
    CMP #$0020
    BCC code_0B90AE
    LDA $0028, Y
    CMP #$003B
    BNE code_0B90AE
    JSL $@chunk_03BAE1.func_03F0CA
    CMP #$0001
    BNE code_0B90AE
    COP [BranchIfSolidOffset] ( #00, #01, &code_0B90AE )
    JSR $&code_0B913D
    COP [AddPosition] ( #00, #10 )
    COP [PlaySoundCh1] ( #2C )
    COP [LoopInit] ( #10 )
    LDY $04
    LDA $0016, Y
    INC 
    STA $0016, Y
    COP [LoopNext]
    JSR $&code_0B9149
}

code_0B90AE {
    COP [RestoreSavedPtr]
}

code_0B90B0 {
    COP [BranchOnPlayerY] ( #$000F, &code_0B901C, &code_0B90BA, &code_0B901C )
}

code_0B90BA {
    LDY $playerActor
    LDA $0014, Y
    SEC 
    SBC $14
    BPL loc_0B9104
    BPL loc_0B90CB
    EOR #$FFFF
    INC 

  loc_0B90CB:
    CMP #$0020
    BCC code_0B9102
    LDA $0028, Y
    CMP #$003D
    BNE code_0B9102
    JSL $@chunk_03BAE1.func_03F0CA
    CMP #$0003
    BNE code_0B9102
    COP [BranchIfSolidOffset] ( #FF, #00, &code_0B9102 )
    JSR $&code_0B913D
    COP [AddPosition] ( #F0, #00 )
    COP [PlaySoundCh1] ( #2C )
    COP [LoopInit] ( #10 )
    LDY $04
    LDA $0014, Y
    DEC 
    STA $0014, Y
    COP [LoopNext]
    JSR $&code_0B9149
}

code_0B9102 {
    COP [RestoreSavedPtr]

  loc_0B9104:
    CMP #$0020
    BCC code_0B913B
    LDA $0028, Y
    CMP #$003C
    BNE code_0B913B
    JSL $@chunk_03BAE1.func_03F0CA
    CMP #$0002
    BNE code_0B913B
    COP [BranchIfSolidOffset] ( #01, #00, &code_0B913B )
    JSR $&code_0B913D
    COP [AddPosition] ( #10, #00 )
    COP [PlaySoundCh1] ( #2C )
    COP [LoopInit] ( #10 )
    LDY $04
    LDA $0014, Y
    INC 
    STA $0014, Y
    COP [LoopNext]
    JSR $&code_0B9149
}

code_0B913B {
    COP [RestoreSavedPtr]
}

code_0B913D {
    LDY $24
    LDA $0012, Y
    ORA #$0010
    STA $0012, Y
    RTS 
}

code_0B9149 {
    LDY $24
    LDA $0012, Y
    AND #$FFEF
    STA $0012, Y
    RTS 
}

gw82_archer1 [
  actor-def < #07, #00, #00, {

  code_0B9158:
    COP [SetHitCallback] ( &code_0B917A )

  loc_0B915C:
    COP [WaitWhileOffscreen] ( #09 )
    COP [CallScript] ( &code_0B91AF )
    BRA loc_0B915C
} >
]

gw82_archer2 [
  actor-def < #07, #00, #00, {

  code_0B9168:
    COP [SetHFlip]
    COP [SetHitCallback] ( &code_0B917A )

  loc_0B916E:
    COP [WaitWhileOffscreen] ( #09 )
    COP [CallScript] ( &code_0B91C6 )
    BRA loc_0B916E
} >
]

gw82_archer3 [
  actor-def < #05, #00, #00, {

  code_0B917A:
    COP [WaitWhileOffscreen] ( #09 )
    COP [SetSavedPtr] ( &code_0B918B )
    COP [BranchOnPlayerX] ( #$0000, &code_0B91AF, &code_0B91AF, &code_0B91C6 )
} >
]

code_0B918B {
    LDA $10
    BIT #$4000
    BNE code_0B917A
    COP [SetSavedPtr] ( &code_0B918B )
    COP [BranchIfPlayerNear] ( #04, &code_0B91FF )
    COP [BranchOnPlayerY] ( #$000E, &code_0B91DD, &code_0B91A5, &code_0B91E9 )
}

code_0B91A5 {
    COP [BranchOnPlayerX] ( #$0000, &code_0B91AF, &code_0B91AF, &code_0B91C6 )
}

code_0B91AF {
    COP [StageSpriteFrame] ( #0B )
    COP [AnimOnce]
    COP [SpawnAfterRelFlags] ( @code_0B926C, #$0000, #$FFF5, #$0300 )
    COP [StageSpriteFrame] ( #0E )
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0B91C6 {
    COP [StageSpriteFrame] ( #8B )
    COP [AnimOnce]
    COP [SpawnAfterRelFlags] ( @code_0B9253, #$0000, #$FFF5, #$0300 )
    COP [StageSpriteFrame] ( #8E )
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0B91DD {
    COP [BranchIfSolidNorth] ( &code_0B91F5 )
    COP [StageSpriteMoveY] ( #09, #12 )
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0B91E9 {
    COP [BranchIfSolidSouth] ( &code_0B91F5 )
    COP [StageSpriteMoveY] ( #08, #11 )
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0B91F5 {
    COP [BranchOnPlayerX] ( #$0000, &code_0B91AF, &code_0B91AF, &code_0B91C6 )
}

code_0B91FF {
    COP [BranchOnPlayerX] ( #$0000, &code_0B922E, &code_0B922E, &code_0B9209 )
}

code_0B9209 {
    COP [LoopInit] ( #02 )
    COP [BranchIfSolidWest] ( &code_0B91F5 )
    COP [StageSprAndHitbox] ( #8A )
    COP [StageForceMoveX] ( #04 )
    COP [SetEntryContinue]
    COP [ContinueIfFrame] ( #02 )
    COP [SetEntryExit]
    STZ $2C
    COP [BranchIfSolidWest] ( &code_0B91F5 )
    COP [StageForceMoveX] ( #04 )
    COP [SetEntryContinue]
    COP [AnimOnce]
    COP [LoopNext]
    BRA code_0B91F5
}

code_0B922E {
    COP [LoopInit] ( #02 )
    COP [BranchIfSolidEast] ( &code_0B91F5 )
    COP [StageSprAndHitbox] ( #0A )
    COP [StageForceMoveX] ( #03 )
    COP [SetEntryContinue]
    COP [ContinueIfFrame] ( #02 )
    COP [SetEntryExit]
    STZ $2C
    COP [BranchIfSolidEast] ( &code_0B91F5 )
    COP [StageForceMoveX] ( #03 )
    COP [SetEntryContinue]
    COP [AnimOnce]
    COP [LoopNext]
    BRA code_0B91F5
}

code_0B9253 {
    COP [SetExtraCallback] ( &code_0B92E9 )
    COP [OrActorFlags] ( #$0010 )
    COP [SpawnMarkedAfter] ( @code_0B931A, #$2000 )
    COP [StageSpriteFrame] ( #8C )
    COP [AnimOnce]
    COP [StageForceMoveX] ( #05 )
    BRA loc_0B9283
}

code_0B926C {
    COP [SetExtraCallback] ( &code_0B92F9 )
    COP [OrActorFlags] ( #$0010 )
    COP [SpawnMarkedAfter] ( @code_0B9375, #$2000 )
    COP [StageSpriteFrame] ( #0C )
    COP [AnimOnce]
    COP [StageForceMoveX] ( #06 )

  loc_0B9283:
    COP [PlaySoundCh1] ( #1E )
    LDA #$0064
    STA $24
    COP [SetEntryContinue]
    COP [BranchIfSolidNibbleNe] ( #0F, &code_0B92A8 )
    DEC $24
    BMI loc_0B9297
    RTL 

  loc_0B9297:
    COP [SetEntryContinue]
    COP [BranchIfSolidNibbleNe] ( #0F, &code_0B92A8 )
    LDA $10
    BIT #$4000
    BNE loc_0B92A6
    RTL 

  loc_0B92A6:
    COP [Die]
}

code_0B92A8 {
    STZ $2C
    LDA $0E
    BIT #$4000
    BNE loc_0B92C0
    COP [KillNext]
    COP [StageSpriteLoop] ( #0D, #0A )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    COP [Die]

  loc_0B92C0:
    COP [KillNext]
    COP [StageSpriteLoop] ( #8D, #0A )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #92 )
    COP [AnimOnce]
    COP [Die]

  loc_0B92CF:
    COP [StageSpriteLoop] ( #0D, #06 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    COP [Die]

  loc_0B92DC:
    COP [StageSpriteLoop] ( #8D, #06 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #92 )
    COP [AnimOnce]
    COP [Die]
}

code_0B92E9 {
    LDA #$0004
    STA $extVelocityX
    LDA $14
    CLC 
    ADC #$000E
    STA $14
    BRA loc_0B9307
}

code_0B92F9 {
    LDA #$FFFC
    STA $extVelocityX
    LDA $14
    SEC 
    SBC #$000E
    STA $14

  loc_0B9307:
    LDA $16
    SEC 
    SBC #$000E
    STA $16
    COP [SpawnLastRel] ( @player_transition_handlers.code_00C423, #00, #00, #$0302 )
    COP [Die]
}

code_0B931A {
    LDY $playerActor
    LDA $0010, Y
    BIT #$0040
    BEQ loc_0B9328
    COP [SetEntryContinue]
    RTL 

  loc_0B9328:
    BIT #$2280
    BEQ loc_0B932E
    RTL 

  loc_0B932E:
    LDA #$0000
    JSR $&code_0B9408
    CLC 
    ADC #$0008
    BPL loc_0B933E
    EOR #$FFFF
    INC 

  loc_0B933E:
    CMP #$0005
    BCC loc_0B9344
    RTL 

  loc_0B9344:
    LDA $0016, Y
    SEC 
    SBC #$0014
    SEC 
    SBC $001C
    BPL loc_0B9355
    EOR #$FFFF
    INC 

  loc_0B9355:
    CMP #$000F
    BCC loc_0B935B
    RTL 

  loc_0B935B:
    LDA #$0F00
    TSB $joypadMaskStd
    PHY 
    LDA #$0002
    LDY #$0003
    JSL $@ApplyPlayerHitstun
    PLY 
    LDA #$&loc_0B92DC
    JSR $&code_0B93FB
    BRA loc_0B93C8
}

code_0B9375 {
    LDY $playerActor
    LDA $0010, Y
    BIT #$0040
    BEQ loc_0B9383
    COP [SetEntryContinue]
    RTL 

  loc_0B9383:
    BIT #$2280
    BEQ loc_0B9389
    RTL 

  loc_0B9389:
    LDA #$0010
    JSR $&code_0B9408
    SEC 
    SBC #$0008
    BPL loc_0B9399
    EOR #$FFFF
    INC 

  loc_0B9399:
    CMP #$0005
    BCC loc_0B939F
    RTL 

  loc_0B939F:
    LDA $0016, Y
    SEC 
    SBC #$0014
    SEC 
    SBC $001C
    BPL loc_0B93B0
    EOR #$FFFF
    INC 

  loc_0B93B0:
    CMP #$000F
    BCC loc_0B93B6
    RTL 

  loc_0B93B6:
    PHY 
    LDA #$0002
    LDY #$0002
    JSL $@ApplyPlayerHitstun
    PLY 
    LDA #$&loc_0B92CF
    JSR $&code_0B93FB

  loc_0B93C8:
    PHX 
    LDX $playerActor
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
    LDX $playerActor
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

code_0B93FB {
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    STA $002C, Y
    RTS 
}

code_0B9408 {
    CLC 
    ADC $playerXPos
    STA $0018
    LDA $playerYPos
    SEC 
    SBC #$0001
    STA $001C
    LDY $24
    LDA $0014, Y
    SEC 
    SBC $0018
    RTS 
}