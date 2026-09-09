?INCLUDE 'EnemyDeathFlash'
?INCLUDE 'interaction_handlers'
?INCLUDE 'smooth_follow'

!playerActor                    09AA
!chatPtr                        7F000A
!orbitAngle                     7F0010
!orbitDiameter                  7F0012
!loopCounter                    7F0014
!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

sg4D_knight_armor1 [
  actor-def < #17, #10, #03, {

  code_0AC101:
    JSR $&code_0AC506
    COP [SolidHighHere]

  loc_0AC106:
    COP [StageSpriteFrame] ( #17 )
    COP [AnimOnce]

  code_0AC10B:
    COP [WaitWhileOffscreen] ( #1E )
    COP [BranchIfPlayerNear] ( #04, &code_0AC118 )
    COP [SetEntryExitNow] ( @code_0AC10B )
} >
]

code_0AC118 {
    COP [SpawnBeforeFlags] ( @code_0AC1B4, #$2212 )
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
    COP [CallScript] ( &code_0AD9D2 )
    COP [StageSprAndHitbox] ( #19 )
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $orbitAngle, X
    BMI loc_0AC1A1
    BEQ loc_0AC14A
    RTL 

  loc_0AC14A:
    COP [CallScript] ( &code_0ADA12 )
    BRA loc_0AC106
}

sg4F_knight_armor2 [
  actor-def < #17, #10, #01, {

  code_0AC153:
    JSR $&code_0AC506
    COP [SolidHighHere]

  loc_0AC158:
    COP [StageSpriteFrame] ( #17 )
    COP [AnimOnce]
    COP [SetHitCallback] ( &code_0AC169 )

  code_0AC161:
    COP [WaitWhileOffscreen] ( #1E )
    COP [SetEntryExitNow] ( @code_0AC161 )
} >
]

code_0AC169 {
    COP [SpawnBeforeFlags] ( @code_0AC1B4, #$2212 )
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
    COP [CallScript] ( &code_0AD9D2 )
    COP [StageSprAndHitbox] ( #19 )
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $orbitAngle, X
    BMI loc_0AC1A1
    BEQ loc_0AC19B
    RTL 

  loc_0AC19B:
    COP [CallScript] ( &code_0ADA12 )
    BRA loc_0AC158

  loc_0AC1A1:
    COP [StageSpriteFrame] ( #18 )
    COP [AnimOnce]
    COP [CallScript] ( &code_0ADA12 )
    COP [SpawnMarkedAfter] ( @interaction_handlers.push_handler_solid, #$2300 )
    COP [SetEntryContinue]
    RTL 
}

code_0AC1B4 {
    COP [AddPosition] ( #FF, #DC )
    LDA #$2000
    TRB $10
    JSR $&sub_0ADD59
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
    COP [SetHitCallback] ( &code_0AC23D )
    BRA loc_0AC1EE

  code_0AC1E4:
    COP [SetHitCallback] ( &code_0AC23D )

  code_0AC1E8:
    COP [StageSpriteLoop] ( #22, #02 )
    COP [AnimLoop]

  loc_0AC1EE:
    COP [SetSavedPtr] ( &code_0AC1E8 )
    COP [BranchIfPlayerNear] ( #07, &code_0AC294 )
    COP [CollPrioritySetMax]

  loc_0AC1F9:
    LDA $7F100C, X
    STA $moveXAlt, X
    LDA $7F100E, X
    STA $moveYAlt, X
    COP [StageMove] ( #22, #04, #FF )
    COP [TickMove]
    LDA $14
    CMP $7F100C, X
    BNE loc_0AC1F9
    LDA $16
    CMP $7F100E, X
    BNE loc_0AC1F9
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

code_0AC23D {
    LDA $orbitDiameter, X
    INC 
    CMP #$0003
    BEQ loc_0AC275
    STA $orbitDiameter, X
    STZ $2C
    STZ $2E
    COP [SpawnAfter] ( @code_0AC35A )
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
    JMP $&code_0AC1E4

  loc_0AC275:
    PHX 
    LDA $orbitAngle, X
    TAX 
    LDA #$FFFF
    STA $orbitAngle, X
    PLX 
    COP [PlaySoundCh1] ( #06 )
    COP [SpawnLastRel] ( @EnemyDeathFlash, #00, #00, #$0302 )
    COP [WaitByte] ( #03 )
    COP [Die]
}

code_0AC294 {
    COP [StageSprAndHitbox] ( #22 )
    COP [DirToPlayer]
    AND #$0007
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0AC2A5 )
}

code_list_0AC2A5 [
  &code_0AC2B5   ;00
  &code_0AC2CA   ;01
  &code_0AC2DF   ;02
  &code_0AC2F3   ;03
  &code_0AC308   ;04
  &code_0AC31C   ;05
  &code_0AC331   ;06
  &code_0AC345   ;07
]

code_0AC2B5 {
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    COP [SetEntryExit]
    COP [StageSpriteLoop] ( #1A, #1E )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #1A, #18, #08 )
    COP [AnimLoop]
    COP [RestoreSavedPtr]
}

code_0AC2CA {
    COP [SetEntryContinue]
    COP [ContinueIfFrame] ( #02 )
    COP [StageSpriteLoop] ( #1B, #1E )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveXY] ( #1B, #18, #05, #06 )
    COP [AnimLoop]
    COP [RestoreSavedPtr]
}

code_0AC2DF {
    COP [SetEntryContinue]
    COP [ContinueIfFrame] ( #03 )
    COP [StageSpriteLoop] ( #1C, #1E )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #1C, #18, #07 )
    COP [AnimLoop]
    COP [RestoreSavedPtr]
}

code_0AC2F3 {
    COP [SetEntryContinue]
    COP [ContinueIfFrame] ( #04 )
    COP [StageSpriteLoop] ( #1D, #1E )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveXY] ( #1D, #18, #05, #05 )
    COP [AnimLoop]
    COP [RestoreSavedPtr]
}

code_0AC308 {
    COP [SetEntryContinue]
    COP [ContinueIfFrame] ( #05 )
    COP [StageSpriteLoop] ( #1E, #1E )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #1E, #18, #07 )
    COP [AnimLoop]
    COP [RestoreSavedPtr]
}

code_0AC31C {
    COP [SetEntryContinue]
    COP [ContinueIfFrame] ( #06 )
    COP [StageSpriteLoop] ( #1F, #1E )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveXY] ( #1F, #18, #06, #05 )
    COP [AnimLoop]
    COP [RestoreSavedPtr]
}

code_0AC331 {
    COP [SetEntryContinue]
    COP [ContinueIfFrame] ( #07 )
    COP [StageSpriteLoop] ( #20, #1E )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #20, #18, #08 )
    COP [AnimLoop]
    COP [RestoreSavedPtr]
}

code_0AC345 {
    COP [SetEntryContinue]
    COP [ContinueIfFrame] ( #08 )
    COP [StageSpriteLoop] ( #21, #1E )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveXY] ( #21, #18, #06, #06 )
    COP [AnimLoop]
    COP [RestoreSavedPtr]
}

code_0AC35A {
    LDA #$0008
    TSB $12
    PEA $&code_0AC39C-1
    COP [CardinalToPlayer]
    AND #$0003
    BEQ loc_0AC372
    DEC 
    BEQ loc_0AC37B
    DEC 
    BEQ loc_0AC387
    DEC 
    BEQ loc_0AC393

  loc_0AC372:
    LDA #$6000
    TRB $12
    COP [StageForceMoveY] ( #22 )
    RTS 

  loc_0AC37B:
    LDA #$6000
    TRB $12
    COP [SetForceBoth] ( #01 )
    COP [StageForceMoveX] ( #22 )
    RTS 

  loc_0AC387:
    LDA #$6000
    TRB $12
    COP [SetForceBoth] ( #01 )
    COP [StageForceMoveY] ( #22 )
    RTS 

  loc_0AC393:
    LDA #$6000
    TRB $12
    COP [StageForceMoveX] ( #22 )
    RTS 
}

code_0AC39C {
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

sg4F_knight_armor3 [
  actor-def < #17, #10, #03, {

  code_0AC3B6:
    JSR $&code_0AC506
    COP [SolidHighHere]

  loc_0AC3BB:
    COP [StageSpriteFrame] ( #17 )
    COP [AnimOnce]

  code_0AC3C0:
    COP [WaitWhileOffscreen] ( #1E )
    COP [BranchIfPlayerNear] ( #04, &code_0AC3CD )
    COP [SetEntryExitNow] ( @code_0AC3C0 )
} >
]

code_0AC3CD {
    COP [SpawnAfterRelFlags] ( @code_0AC471, #$FFFF, #$FFDC, #$0212 )
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
    COP [CallScript] ( &code_0AD9F2 )
    COP [StageSprAndHitbox] ( #19 )
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $orbitAngle, X
    BMI loc_0AC45E
    BEQ loc_0AC403
    RTL 

  loc_0AC403:
    COP [CallScript] ( &code_0ADA12 )
    BRA loc_0AC3BB
}

sg4F_knight_armor4 [
  actor-def < #17, #10, #01, {

  code_0AC40C:
    JSR $&code_0AC506
    COP [SolidHighHere]

  loc_0AC411:
    COP [SetHitCallback] ( &code_0AC422 )
    COP [StageSpriteFrame] ( #17 )
    COP [AnimOnce]

  code_0AC41A:
    COP [WaitWhileOffscreen] ( #1E )
    COP [SetEntryExitNow] ( @code_0AC41A )
} >
]

code_0AC422 {
    COP [SpawnAfterRelFlags] ( @code_0AC471, #$FFFF, #$FFDC, #$0212 )
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
    COP [CallScript] ( &code_0AD9F2 )
    COP [StageSprAndHitbox] ( #19 )
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $orbitAngle, X
    BMI loc_0AC45E
    BEQ loc_0AC458
    RTL 

  loc_0AC458:
    COP [CallScript] ( &code_0ADA12 )
    BRA loc_0AC411

  loc_0AC45E:
    COP [StageSpriteFrame] ( #18 )
    COP [AnimOnce]
    COP [CallScript] ( &code_0ADA32 )
    COP [SpawnMarkedAfter] ( @interaction_handlers.push_handler_solid, #$2300 )
    COP [SetEntryContinue]
    RTL 
}

code_0AC471 {
    JSR $&sub_0ADD59
    LDA #$0000
    STA $orbitDiameter, X
    COP [StageSpriteLoop] ( #1A, #50 )
    COP [AnimLoop]
    LDA #$0200
    TRB $10
    COP [StageSprAndHitbox] ( #22 )
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    BRA loc_0AC499

  loc_0AC48F:
    COP [SetHitCallback] ( &code_0AC4CE )
    COP [StageSpriteLoop] ( #22, #04 )
    COP [AnimLoop]

  loc_0AC499:
    COP [SetHitCallback] ( &code_0AC4CC )
    LDA #$8022
    STA $chatPtr, X
    LDA #$0002
    STA $loopCounter, X
    COP [SpawnMarkedAfter] ( @smooth_follow.InitFollowAndChase, #$2000 )
    LDA $playerActor
    STA $0024, Y
    COP [SetEntryExit]
    LDA #$0030
    STA $24
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    DEC $24
    BMI loc_0AC4C8
    RTL 

  loc_0AC4C8:
    COP [KillNext]
    BRA loc_0AC48F
}

code_0AC4CC {
    COP [KillNext]
}

code_0AC4CE {
    LDA $orbitDiameter, X
    INC 
    STA $orbitDiameter, X
    CMP #$0003
    BEQ loc_0AC4E7
    STZ $2C
    STZ $2E
    COP [SpawnAfter] ( @code_0AC35A )
    BRA loc_0AC48F

  loc_0AC4E7:
    PHX 
    LDA $orbitAngle, X
    TAX 
    LDA #$FFFF
    STA $orbitAngle, X
    PLX 
    COP [PlaySoundCh1] ( #06 )
    COP [SpawnLastRel] ( @EnemyDeathFlash, #00, #00, #$0302 )
    COP [WaitByte] ( #03 )
    COP [Die]
}

code_0AC506 {
    LDY $playerActor
    LDA $0014, Y
    CMP $14
    BNE loc_0AC51F
    LDA $0016, Y
    CMP $16
    BNE loc_0AC51F
    LDA $14
    SEC 
    SBC #$0020
    STA $14

  loc_0AC51F:
    RTS 
}
---------------------------------------------

sub_0ADD59 {
    LDA $14
    STA $7F100C, X
    LDA $16
    STA $7F100E, X
    RTS 
}
---------------------------------------------

code_0AD9D2 {
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

code_0AD9F2 {
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

code_0ADA12 {
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

code_0ADA32 {
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