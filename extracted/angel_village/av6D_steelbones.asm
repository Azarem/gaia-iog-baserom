; Steelbones enemy — armored skeleton in the Angel tunnels (~611 lines).
; 
; Heavy melee enemy with high defense. Patrols tunnel corridors
; with 4-directional movement and charges at the player when
; in range. Uses hit callbacks for damage tracking. Complex
; AI with patrol, alert, and attack states. One of the
; tougher regular enemies in the Angel Village dungeon.
---------------------------------------------

!playerXPos                     09A2
!playerYPos                     09A4
!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

av6D_steelbones [
  actor-def < #00, #00, #00, {

  code_0AEA54:
    COP [WaitWhileOffscreen] ( #10 )
    COP [SetHitCallback] ( &code_0AECF0 )
    COP [SetSavedPtr] ( &code_0AEA54 )
    COP [BranchIfPlayerNear] ( #06, &code_0AEA7F )
    LDA #$0004
    STA $24
    COP [RngByte]
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0AEA77 )
} >
]

code_list_0AEA77 [
  &code_0AEB3F   ;00
  &code_0AEB65   ;01
  &code_0AEB83   ;02
  &code_0AEBA9   ;03
]

code_0AEA7F {
    COP [BranchIfPlayerNear] ( #02, &code_0AEAE1 )
    LDA #$0002
    STA $24
    COP [BranchOnPlayerX] ( #$0030, &code_0AEACD, &code_0AEA93, &code_0AEAD7 )
}

code_0AEA93 {
    COP [CardinalToPlayer]
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0AEAA1 )
}

code_list_0AEAA1 [
  &code_0AEAA9   ;00
  &code_0AEAB5   ;01
  &code_0AEAAF   ;02
  &code_0AEAC1   ;03
]

code_0AEAA9 {
    COP [CallNear] ( &code_0AEBC7 )
    BRA code_0AEA54
}

code_0AEAAF {
    COP [CallNear] ( &code_0AEBD3 )
    BRA code_0AEA54
}

code_0AEAB5 {
    COP [StageSpriteLoop] ( #82, #1E )
    COP [AnimLoop]
    COP [CallNear] ( &code_0AEC0A )
    BRA code_0AEA54
}

code_0AEAC1 {
    COP [StageSpriteLoop] ( #02, #1E )
    COP [AnimLoop]
    COP [CallNear] ( &code_0AEBFE )
    BRA code_0AEA54
}

code_0AEACD {
    COP [CallNear] ( &code_0AEC0A )
    COP [CallNear] ( &code_0AED06 )
    BRA code_0AEA93
}

code_0AEAD7 {
    COP [CallNear] ( &code_0AEBFE )
    COP [CallNear] ( &code_0AED2C )
    BRA code_0AEA93
}

code_0AEAE1 {
    COP [CardinalToPlayer]
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0AEAEF )
}

code_list_0AEAEF [
  &code_0AEAF7   ;00
  &code_0AEB1B   ;01
  &code_0AEB09   ;02
  &code_0AEB2D   ;03
]

code_0AEAF7 {
    COP [StageSpriteLoop] ( #01, #1E )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #06 )
    COP [AnimOnce]
    COP [CallNear] ( &code_0AEC38 )
    JMP $&code_0AEA54
}

code_0AEB09 {
    COP [StageSpriteLoop] ( #00, #1E )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    COP [CallNear] ( &code_0AEC66 )
    JMP $&code_0AEA54
}

code_0AEB1B {
    COP [StageSpriteLoop] ( #82, #1E )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #88 )
    COP [AnimOnce]
    COP [CallNear] ( &code_0AECC2 )
    JMP $&code_0AEA54
}

code_0AEB2D {
    COP [StageSpriteLoop] ( #02, #1E )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #08 )
    COP [AnimOnce]
    COP [CallNear] ( &code_0AEC94 )
    JMP $&code_0AEA54
}

code_0AEB3F {
    COP [SetHitCallback] ( &code_0AEB53 )
    COP [StageSpriteLoop] ( #00, #3C )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #09, #02 )
    COP [AnimLoop]
    COP [SetHitCallback] ( #$0000 )
}

code_0AEB53 {
    COP [BranchIfPlayerInRelTiles] ( #FE, #00, #02, #08, &code_0AEC66 )

  loc_0AEB5B:
    COP [BranchOnPlayerX] ( #$0000, &code_0AEC94, &code_0AEC94, &code_0AECC2 )
}

code_0AEB65 {
    COP [SetHitCallback] ( &code_0AEB79 )
    COP [StageSpriteLoop] ( #01, #3C )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #0A, #02 )
    COP [AnimLoop]
    COP [SetHitCallback] ( #$0000 )
}

code_0AEB79 {
    COP [BranchIfPlayerInRelTiles] ( #FE, #F8, #02, #00, &code_0AEC38 )
    BRA loc_0AEB5B
}

code_0AEB83 {
    COP [SetHitCallback] ( &code_0AEB97 )
    COP [StageSpriteLoop] ( #02, #3C )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #0B, #02 )
    COP [AnimLoop]
    COP [SetHitCallback] ( #$0000 )
}

code_0AEB97 {
    COP [BranchIfPlayerInRelTiles] ( #F8, #FE, #00, #02, &code_0AEC94 )

  loc_0AEB9F:
    COP [BranchOnPlayerY] ( #$0000, &code_0AEC38, &code_0AEC38, &code_0AEC66 )
}

code_0AEBA9 {
    COP [SetHitCallback] ( &code_0AEBBD )
    COP [StageSpriteLoop] ( #82, #3C )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #8B, #02 )
    COP [AnimLoop]
    COP [SetHitCallback] ( #$0000 )
}

code_0AEBBD {
    COP [BranchIfPlayerInRelTiles] ( #00, #FE, #08, #02, &code_0AECC2 )
    BRA loc_0AEB9F
}

code_0AEBC7 {
    COP [BranchIfSolidNorth] ( &code_0AEBDF )
    COP [StageSpriteMoveY] ( #05, #12 )
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0AEBD3 {
    COP [BranchIfSolidSouth] ( &code_0AEBDF )
    COP [StageSpriteMoveY] ( #03, #11 )
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0AEBDF {
    COP [SetEntryHereAndYield]
    COP [RngByte]
    AND #$0003
    BNE loc_0AEBF4
    LDA $0410
    LSR 
    LSR 
    AND #$0001
    BEQ code_0AEC0A
    BRA code_0AEBFE

  loc_0AEBF4:
    COP [BranchOnPlayerX] ( #$0000, &code_0AEBFE, &code_0AEBFE, &code_0AEC0A )
}

code_0AEBFE {
    COP [BranchIfSolidWest] ( &code_0AEC16 )
    COP [StageSpriteMoveX] ( #07, #12 )
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0AEC0A {
    COP [BranchIfSolidEast] ( &code_0AEC16 )
    COP [StageSpriteMoveX] ( #87, #11 )
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0AEC16 {
    COP [BranchOnPlayerY] ( #$0000, &code_0AEC20, &code_0AEC20, &code_0AEC2C )
}

code_0AEC20 {
    COP [BranchIfSolidNorth] ( &code_0AEBDF )
    COP [StageSpriteMoveY] ( #05, #12 )
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0AEC2C {
    COP [BranchIfSolidSouth] ( &code_0AEBDF )
    COP [StageSpriteMoveY] ( #03, #11 )
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0AEC38 {
    COP [StageSprAndHitbox] ( #05 )
    COP [LoopStart] ( #02 )
    COP [BranchIfSolidNorth] ( &code_0AEC62 )
    COP [StageMoveY] ( #04 )
    LDA #$0001
    STA $26
    COP [SetEntryHere]
    COP [AnimOneFrame]
    LDA #$0003
    STA $08
    DEC $26
    BMI loc_0AEC58
    RTL 

  loc_0AEC58:
    COP [LoopEnd]
    COP [SetEntryHereAndYield]
    DEC $24
    BPL code_0AEC38
    STZ $24
}

code_0AEC62 {
    STZ $2E
    COP [RestoreSavedPtr]
}

code_0AEC66 {
    COP [StageSprAndHitbox] ( #03 )
    COP [LoopStart] ( #02 )
    COP [BranchIfSolidSouth] ( &code_0AEC90 )
    COP [StageMoveY] ( #03 )
    LDA #$0001
    STA $26
    COP [SetEntryHere]
    COP [AnimOneFrame]
    LDA #$0003
    STA $08
    DEC $26
    BMI loc_0AEC86
    RTL 

  loc_0AEC86:
    COP [LoopEnd]
    COP [SetEntryHereAndYield]
    DEC $24
    BPL code_0AEC66
    STZ $24
}

code_0AEC90 {
    STZ $2E
    COP [RestoreSavedPtr]
}

code_0AEC94 {
    COP [StageSprAndHitbox] ( #07 )
    COP [LoopStart] ( #02 )
    COP [BranchIfSolidWest] ( &code_0AECBE )
    COP [StageMoveX] ( #04 )
    LDA #$0001
    STA $26
    COP [SetEntryHere]
    COP [AnimOneFrame]
    LDA #$0003
    STA $08
    DEC $26
    BMI loc_0AECB4
    RTL 

  loc_0AECB4:
    COP [LoopEnd]
    COP [SetEntryHereAndYield]
    DEC $24
    BPL code_0AEC94
    STZ $24
}

code_0AECBE {
    STZ $2C
    COP [RestoreSavedPtr]
}

code_0AECC2 {
    COP [StageSprAndHitbox] ( #87 )
    COP [LoopStart] ( #02 )
    COP [BranchIfSolidEast] ( &code_0AECEC )
    COP [StageMoveX] ( #03 )
    LDA #$0001
    STA $26
    COP [SetEntryHere]
    COP [AnimOneFrame]
    LDA #$0003
    STA $08
    DEC $26
    BMI loc_0AECE2
    RTL 

  loc_0AECE2:
    COP [LoopEnd]
    COP [SetEntryHereAndYield]
    DEC $24
    BPL code_0AECC2
    STZ $24
}

code_0AECEC {
    STZ $2C
    COP [RestoreSavedPtr]
}

code_0AECF0 {
    COP [SnapToGrid]
    COP [StageMoveXY] ( #00, #00 )
    COP [SetHitCallback] ( #$0000 )
    COP [SetEntryHereAndYield]
    COP [BranchOnPlayerX] ( #$0000, &code_0AED06, &code_0AED06, &code_0AED2C )
}

code_0AED06 {
    COP [SetHitCallback] ( #$0000 )
    LDA #$0001
    TSB $12
    COP [StageSpriteFrame] ( #0C )
    COP [AnimOnce]
    COP [WaitByte] ( #1D )
    COP [SpawnAfterOffsetMarked] ( @code_0AED52, #F8, #F0, #$0202 )
    COP [StageSpriteFrame] ( #0D )
    COP [AnimOnce]
    LDA #$0001
    TRB $12
    COP [RestoreSavedPtr]
}

code_0AED2C {
    COP [SetHitCallback] ( #$0000 )
    LDA #$0001
    TSB $12
    COP [StageSpriteFrame] ( #8C )
    COP [AnimOnce]
    COP [WaitByte] ( #1D )
    COP [SpawnAfterOffsetMarked] ( @code_0AEDA9, #08, #F0, #$0202 )
    COP [StageSpriteFrame] ( #8D )
    COP [AnimOnce]
    LDA #$0001
    TRB $12
    COP [RestoreSavedPtr]
}

code_0AED52 {
    COP [PlaySoundCh1] ( #1E )
    LDA $24
    STA $7F100C, X
    COP [OrExtraFlags] ( #$0010 )
    LDA $14
    SEC 
    SBC $playerXPos
    BPL loc_0AED6B
    EOR #$FFFF
    INC 

  loc_0AED6B:
    PHA 
    COP [RngByte]
    AND #$003F
    CLC 
    ADC $01, S
    EOR #$FFFF
    INC 
    CLC 
    ADC $14
    STA $moveXAlt, X
    PLA 
    LDA $playerYPos
    SEC 
    SBC $16
    PHP 
    BPL loc_0AED8D
    EOR #$FFFF
    INC 

  loc_0AED8D:
    CMP #$0030
    BCC loc_0AED95
    AND #$001F

  loc_0AED95:
    PLP 
    BCS loc_0AED9C
    EOR #$FFFF
    INC 

  loc_0AED9C:
    CLC 
    ADC $16
    STA $moveYAlt, X
    COP [MoveToward] ( #0E, #02 )
    BRA loc_0AEDFA
}

code_0AEDA9 {
    COP [PlaySoundCh1] ( #1E )
    LDA $24
    STA $7F100C, X
    COP [OrExtraFlags] ( #$0010 )
    LDA $playerXPos
    SEC 
    SBC $14
    BPL loc_0AEDC2
    EOR #$FFFF
    INC 

  loc_0AEDC2:
    PHA 
    COP [RngByte]
    AND #$003F
    CLC 
    ADC $01, S
    CLC 
    ADC $14
    STA $moveXAlt, X
    PLA 
    LDA $playerYPos
    SEC 
    SBC $16
    PHP 
    BPL loc_0AEDE0
    EOR #$FFFF
    INC 

  loc_0AEDE0:
    CMP #$0030
    BCC loc_0AEDE8
    AND #$001F

  loc_0AEDE8:
    PLP 
    BCS loc_0AEDEF
    EOR #$FFFF
    INC 

  loc_0AEDEF:
    CLC 
    ADC $16
    STA $moveYAlt, X
    COP [MoveToward] ( #0E, #02 )

  loc_0AEDFA:
    LDA $7F100C, X
    STA $26

  code_0AEE00:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryHere]
    LDA $2A
    BEQ code_0AEE00
    LDY $26
    LDA $0014, Y
    SEC 
    SBC $14
    STA $0000
    BPL loc_0AEE20
    EOR #$FFFF
    INC 

  loc_0AEE20:
    CMP #$0003
    BCC loc_0AEE3C
    LDA $0000
    BPL loc_0AEE34
    LDA #$FFFE
    CLC 
    ADC $14
    STA $14
    BRA loc_0AEE3C

  loc_0AEE34:
    LDA #$0002
    CLC 
    ADC $14
    STA $14

  loc_0AEE3C:
    LDA $0016, Y
    SEC 
    SBC #$0010
    SEC 
    SBC $16
    STA $0000
    BPL loc_0AEE4F
    EOR #$FFFF
    INC 

  loc_0AEE4F:
    CMP #$0003
    BCC loc_0AEE6B
    LDA $0000
    BPL loc_0AEE63
    LDA #$FFFE
    CLC 
    ADC $16
    STA $16
    BRA loc_0AEE6B

  loc_0AEE63:
    LDA #$0002
    CLC 
    ADC $16
    STA $16

  loc_0AEE6B:
    LDA $0000
    BPL loc_0AEE74
    EOR #$FFFF
    INC 

  loc_0AEE74:
    STA $0000
    LDA $14
    SEC 
    SBC $0014, Y
    BPL loc_0AEE83
    EOR #$FFFF
    INC 

  loc_0AEE83:
    CLC 
    ADC $0000
    CMP #$0006
    BCC loc_0AEE94
    DEC $24
    BPL loc_0AEE93
    JMP $&code_0AEE00

  loc_0AEE93:
    RTL 

  loc_0AEE94:
    COP [Die]
}