?INCLUDE 'smooth_follow'
?INCLUDE 'spriteset_enemies'

!playerActor                    09AA
!chatPtr                        7F000A
!orbitAngle                     7F0010
!orbitDiameter                  7F0012
!loopCounter                    7F0014
!moveScratch1                   7F002C
!moveScratch2                   7F002E

---------------------------------------------

dm_func_0ADB6B {
    COP [OrActorFlags] ( #$0010 )
    COP [CallScript] ( &code_0ADC25 )
    LDA #$8008
    STA $chatPtr, X
    LDA #$0001
    STA $loopCounter, X
    COP [SpawnMarkedAfter] ( @smooth_follow.InitFollowAndChase, #$2000 )
    LDA $playerActor
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
    JSR $&dm_sub_0ADD27
    BCC loc_0ADBB1
    COP [BranchIfBehindWall] ( &code_0ADC4C )

  loc_0ADBB1:
    COP [LoopNext]
    COP [CollPriorityClearMax]
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    DEC $24
    BMI loc_0ADBC8
    JSR $&dm_sub_0ADD27
    BCS loc_0ADBC3
    RTL 

  loc_0ADBC3:
    COP [BranchIfBehindWall] ( &code_0ADC4C )
    RTL 

  loc_0ADBC8:
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
    BNE loc_0ADBEF
    LDA #$0001
    STA $orbitAngle, X

  loc_0ADBEF:
    COP [KillNext]

  loc_0ADBF1:
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
    BMI loc_0ADBF1
    JSR $&dm_sub_0ADD27
    BCC loc_0ADC1B
    COP [BranchIfBehindWall] ( &code_0ADC4E )

  loc_0ADC1B:
    LDA $10
    BIT #$4000
    BNE loc_0ADC23
    RTL 

  loc_0ADC23:
    COP [Die]
}

code_0ADC25 {
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [SpawnLastRel] ( @code_0ADC45, #00, #00, #$0202 )
    COP [PlaySoundCh1] ( #1E )
    LDA #$0080
    TSB $12
    COP [StageSpriteFrame] ( #08 )
    COP [AnimOnce]
    COP [WaitByte] ( #03 )
    COP [RestoreSavedPtr]
}

code_0ADC45 {
    COP [StageSpriteFrame] ( #07 )
    COP [AnimOnce]
    COP [Die]
}

code_0ADC4C {
    COP [KillNext]
}

code_0ADC4E {
    COP [StageSpriteFrame] ( #2A )
    COP [AnimOnce]
    COP [Die]
}
---------------------------------------------

dm_sub_0ADD27 {
    LDA $14
    EOR $7F100C, X
    BIT #$0010
    BNE loc_0ADD4B
    LDA $16
    EOR $7F100E, X
    BIT #$0010
    BNE loc_0ADD4B
    LDA $14
    STA $7F100C, X
    LDA $16
    STA $7F100E, X
    CLC 
    RTS 

  loc_0ADD4B:
    LDA $14
    STA $7F100C, X
    LDA $16
    STA $7F100E, X
    SEC 
    RTS 
}