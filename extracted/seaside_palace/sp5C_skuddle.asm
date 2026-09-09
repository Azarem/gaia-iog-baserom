?INCLUDE 'table_0EE000'

!sceneCurrent                   0644
!cameraTargetY                  06C2

---------------------------------------------

sp5C_skuddle [
  actor-def < #1D, #00, #00, {

  code_0AE6CF:
    LDA #$0010
    TSB $12
    COP [BranchIfSolid] ( &code_0AE6DA )
    BRA loc_0AE6E2
} >
]

code_0AE6DA {
    LDA #$2000
    TSB $10
    COP [SetEntryContinue]
    RTL 

  loc_0AE6E2:
    COP [BranchIfPlayerNear] ( #02, &code_0AE74C )
    COP [SpawnAfter] ( @code_0AE90D )
    COP [StageSpriteMoveY] ( #1D, #43 )
    COP [AnimOnce]
    BRA loc_0AE6E2
}

sp5C_ceiling_skuddle [
  actor-def < #1D, #02, #23, {

  code_0AE6F7:
    LDA #$0010
    TSB $12
    LDA $sceneCurrent
    CMP #$005C
    BEQ loc_0AE709
    CMP #$005D
    BNE code_0AE711

  loc_0AE709:
    COP [BranchIfFlagByte] ( #70, #00, &code_0AE711 )
    COP [Die]
} >
]

code_0AE711 {
    COP [BranchIfPlayerNear] ( #05, &code_0AE717 )
    RTL 
}

code_0AE717 {
    COP [SpawnMarkedAfter] ( @code_0AE8B6, #$0301 )
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
    BEQ loc_0AE743
    RTL 

  loc_0AE743:
    LDA #$0302
    TRB $10
    COP [KillNext]
    COP [SetEntryExit]
}

code_0AE74C {
    LDA #$6000
    TRB $12
    STZ $24
    COP [BranchNearerAxis] ( &code_0AE759, &code_0AE76F )
}

code_0AE759 {
    COP [BranchOnPlayerX] ( #$0000, &code_0AE763, &code_0AE763, &code_0AE769 )
}

code_0AE763 {
    COP [CallScript] ( &code_0AE787 )
    BRA code_0AE74C
}

code_0AE769 {
    COP [CallScript] ( &code_0AE7AA )
    BRA code_0AE74C
}

code_0AE76F {
    COP [BranchOnPlayerY] ( #$0000, &code_0AE779, &code_0AE779, &code_0AE77F )
}

code_0AE779 {
    COP [CallScript] ( &code_0AE7CD )
    BRA code_0AE74C
}

code_0AE77F {
    COP [CallScript] ( &code_0AE7F0 )
    BRA code_0AE74C

  code_0AE785:
    COP [SetEntryExit]
}

code_0AE787 {
    COP [BranchOnPlayerY] ( #$0000, &code_0AE791, &code_0AE791, &code_0AE79D )
}

code_0AE791 {
    JSR $&code_0AE89E
    COP [BranchIfSolidOffset] ( #FF, #FF, &code_0AE79D )
    JMP $&code_0AE857
}

code_0AE79D {
    JSR $&code_0AE89E
    COP [BranchIfSolidOffset] ( #FF, #01, &code_0AE7A8 )
    BRA loc_0AE810
}

code_0AE7A8 {
    COP [SetEntryExit]
}

code_0AE7AA {
    COP [BranchOnPlayerY] ( #$0000, &code_0AE7B4, &code_0AE7B4, &code_0AE7C0 )
}

code_0AE7B4 {
    JSR $&code_0AE89E
    COP [BranchIfSolidOffset] ( #01, #FF, &code_0AE7C0 )
    JMP $&code_0AE87D
}

code_0AE7C0 {
    JSR $&code_0AE89E
    COP [BranchIfSolidOffset] ( #01, #01, &code_0AE785 )
    BRA loc_0AE836

  code_0AE7CB:
    COP [SetEntryExit]
}

code_0AE7CD {
    COP [BranchOnPlayerX] ( #$0000, &code_0AE7D7, &code_0AE7D7, &code_0AE7E2 )
}

code_0AE7D7 {
    JSR $&code_0AE89E
    COP [BranchIfSolidOffset] ( #FF, #FF, &code_0AE7E2 )
    BRA code_0AE857
}

code_0AE7E2 {
    JSR $&code_0AE89E
    COP [BranchIfSolidOffset] ( #01, #FF, &code_0AE7EE )
    JMP $&code_0AE87D
}

code_0AE7EE {
    COP [SetEntryExit]
}

code_0AE7F0 {
    COP [BranchOnPlayerX] ( #$0000, &code_0AE7FA, &code_0AE7FA, &code_0AE805 )
}

code_0AE7FA {
    JSR $&code_0AE89E
    COP [BranchIfSolidOffset] ( #FF, #01, &code_0AE805 )
    BRA loc_0AE810
}

code_0AE805 {
    JSR $&code_0AE89E
    COP [BranchIfSolidOffset] ( #01, #01, &code_0AE7CB )
    BRA loc_0AE836

  loc_0AE810:
    COP [SpawnAfter] ( @code_0AE8EA )
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

  loc_0AE836:
    COP [SpawnAfter] ( @code_0AE8FE )
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

code_0AE857 {
    COP [SpawnAfter] ( @code_0AE8C2 )
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

code_0AE87D {
    COP [SpawnAfter] ( @code_0AE8D6 )
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

code_0AE89E {
    INC $24
    LDA $24
    CMP #$0004
    BCS loc_0AE8A8
    RTS 

  loc_0AE8A8:
    PLA 
    COP [SpawnAfter] ( @code_0AE90D )
    COP [StageSpriteMoveY] ( #1D, #43 )
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0AE8B6 {
    COP [SetMetasprite] ( @table_0EE000 )

  loc_0AE8BB:
    COP [StageSpriteFrame] ( #31 )
    COP [AnimOnce]
    BRA loc_0AE8BB
}

code_0AE8C2 {
    LDA #$2000
    TRB $10
    LDA #$0301
    TSB $10
    LDA #$6000
    TSB $12
    COP [StageSprAndHitbox] ( #1E )
    BRA loc_0AE91C
}

code_0AE8D6 {
    LDA #$2000
    TRB $10
    LDA #$0301
    TSB $10
    LDA #$2000
    TSB $12
    COP [StageSprAndHitbox] ( #1E )
    BRA loc_0AE91C
}

code_0AE8EA {
    LDA #$2000
    TRB $10
    LDA #$0301
    TSB $10
    LDA #$4000
    TSB $12
    COP [StageSprAndHitbox] ( #1E )
    BRA loc_0AE91C
}

code_0AE8FE {
    LDA #$2000
    TRB $10
    LDA #$0301
    TSB $10
    COP [StageSprAndHitbox] ( #1E )
    BRA loc_0AE91C
}

code_0AE90D {
    LDA #$2000
    TRB $10
    LDA #$0301
    TSB $10
    COP [StageSprAndHitbox] ( #1E )
    BRA loc_0AE920

  loc_0AE91C:
    COP [StageForceMoveXY] ( #42, #42 )

  loc_0AE920:
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    STA $26
    COP [SetEntryContinue]
    LDY $24
    LDA $0010, Y
    BIT #$0080
    BNE loc_0AE941
    DEC $26
    BMI loc_0AE93B
    RTL 

  loc_0AE93B:
    LDA $2A
    BEQ loc_0AE941
    BRA loc_0AE920

  loc_0AE941:
    COP [Die]
}