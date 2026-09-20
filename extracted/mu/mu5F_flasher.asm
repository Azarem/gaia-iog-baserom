; Flasher enemy — electrical enemy in Mu that blinks in and out.
; 
; Phase-shifting enemy that alternates between visible/tangible
; and invisible/intangible states. Can only be damaged while
; visible. Fires electrical projectile attacks during the
; visible phase. Uses orbitAngle for timing the phase shifts.
---------------------------------------------

?INCLUDE 'smooth_follow'

!playerXPos                     09A2
!playerYPos                     09A4
!playerActor                    09AA
!chatPtr                        7F000A
!animScratch2                   7F000E
!loopCounter                    7F0014
!moveScratch1                   7F002C
!moveScratch2                   7F002E

---------------------------------------------

mu5F_flasher [
  actor-def < #0D, #00, #20, {

  code_0AE271:
    COP [BranchIfSolidHere] ( &code_0AE28E )
    LDA #$0011
    TSB $12
    LDA $14
    STA $7F100C, X
    LDA $16
    STA $7F100E, X

  loc_0AE286:
    COP [SetEntryHereAndYield]
    COP [BranchIfPlayerNear] ( #0A, &code_0AE296 )
    RTL 
} >
]

code_0AE28E {
    LDA #$2000
    TSB $10
    COP [SetEntryHere]
    RTL 
}

code_0AE296 {
    COP [WaitByte] ( #3B )
    COP [RngByte]
    PHA 
    AND #$00F0
    SEC 
    SBC #$0080
    CLC 
    ADC $playerXPos
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
    ADC $playerYPos
    AND #$FFF0
    CLC 
    ADC #$0010
    STA $16
    LDA $7F100C, X
    SEC 
    SBC $14
    BPL loc_0AE2D6
    EOR #$FFFF
    INC 

  loc_0AE2D6:
    CMP #$0100
    BCS loc_0AE286
    LDA $7F100E, X
    SEC 
    SBC $16
    BPL loc_0AE2E8
    EOR #$FFFF
    INC 

  loc_0AE2E8:
    CMP #$0100
    BCS loc_0AE286
    COP [BranchIfSolidHere] ( &code_0AE301 )
    COP [BranchIfPlayerNear] ( #01, &code_0AE301 )
    COP [CallNear] ( &code_0AE302 )
    LDA #$2100
    TSB $10
    BRA code_0AE296
}

code_0AE301 {
    RTL 
}

code_0AE302 {
    COP [SetEntryHereAndYield]
    LDA #$2000
    TRB $10
    COP [BranchNearerAxis] ( &code_0AE30F, &code_0AE373 )
}

code_0AE30F {
    COP [BranchOnPlayerX] ( #$0000, &code_0AE319, &code_0AE319, &code_0AE346 )
}

code_0AE319 {
    COP [SetHitCallback] ( &code_0AE33F )
    COP [StageSpriteFrame] ( #15 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    COP [SpawnListAppend] ( @code_0AE3D7, #F0, #F0, #$0202 )
    LDA #$000C
    STA $0026, Y
    COP [ApplyMoveToChild] ( #06, #00 )
}

code_0AE33F {
    COP [StageSpriteFrame] ( #18 )
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0AE346 {
    COP [SetHitCallback] ( &code_0AE36C )
    COP [StageSpriteFrame] ( #95 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #8F )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #92 )
    COP [AnimOnce]
    COP [SpawnListAppend] ( @code_0AE3D7, #10, #F0, #$0202 )
    LDA #$0004
    STA $0026, Y
    COP [ApplyMoveToChild] ( #05, #00 )
}

code_0AE36C {
    COP [StageSpriteFrame] ( #98 )
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0AE373 {
    COP [BranchOnPlayerY] ( #$0000, &code_0AE37D, &code_0AE37D, &code_0AE3AA )
}

code_0AE37D {
    COP [SetHitCallback] ( &code_0AE3A3 )
    COP [StageSpriteFrame] ( #14 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0E )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #11 )
    COP [AnimOnce]
    COP [SpawnListAppend] ( @code_0AE3D7, #00, #F0, #$0200 )
    LDA #$0000
    STA $0026, Y
    COP [ApplyMoveToChild] ( #00, #06 )
}

code_0AE3A3 {
    COP [StageSpriteFrame] ( #17 )
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0AE3AA {
    COP [SetHitCallback] ( &code_0AE3D0 )
    COP [StageSpriteFrame] ( #13 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0D )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #10 )
    COP [AnimOnce]
    COP [SpawnListAppend] ( @code_0AE3D7, #00, #F0, #$0202 )
    LDA #$0008
    STA $0026, Y
    COP [ApplyMoveToChild] ( #00, #05 )
}

code_0AE3D0 {
    COP [StageSpriteFrame] ( #16 )
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0AE3D7 {
    COP [PlaySoundCh1] ( #20 )
    COP [OrExtraFlags] ( #$0010 )
    LDA #$0080
    TSB $12
    COP [StageSpriteFrame] ( #21 )
    COP [AnimOnce]
    COP [SpawnAfterMarked] ( @smooth_follow.CopySiblingFollowState, #$2000 )
    LDA #$8021
    STA $chatPtr, X
    LDA #$0003
    STA $loopCounter, X
    LDA $playerActor
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

  loc_0AE432:
    COP [SetEntryHere]
    COP [AnimOneFrame]
    LDA $08
    STA $24
    STZ $08
    COP [SetEntryHere]
    LDA $7F100C, X
    STA $moveScratch1, X
    LDA $7F100E, X
    STA $moveScratch2, X
    DEC $24
    BMI loc_0AE453
    RTL 

  loc_0AE453:
    LDA $10
    BIT #$4000
    BEQ loc_0AE432
    COP [Die]
}