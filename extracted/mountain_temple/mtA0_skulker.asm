?INCLUDE 'binary_01C384'
?INCLUDE 'hardware_math'

!orbitAngle                     7F0010
!orbitDiameter                  7F0012

---------------------------------------------

mtA0_skulker1 [
  actor-def < #03, #00, #00, {

  code_0B9BA5:
    LDA #$2000
    TSB $12
    BRA loc_0B9BAF
} >
]
---------------------------------------------

mtA0_skulker_ns [
  actor-def < #02, #00, #00, {

  loc_0B9BAF:
    LDA #$0010
    TSB $12
    COP [WaitWhileOffscreen] ( #08 )
    LDA #$0000
    STA $orbitAngle, X
    LDA #$0040
    STA $orbitDiameter, X
    LDA #$0150
    STA $7F100E, X
    LDA $14
    STA $7F100C, X

  loc_0B9BD2:
    LDA $16
    STA $26

  loc_0B9BD6:
    COP [StageForceMoveY] ( #01 )

  loc_0B9BD9:
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0B9BD6
    LDA $08
    INC 
    STA $24
    STZ $08
    JSR $&sub2_0B9CE8
    CLC 
    ADC $7F100C, X
    STA $14
    LDA $orbitAngle, X
    SEC 
    SBC #$0002
    AND #$00FF
    STA $orbitAngle, X
    LDA $26
    SEC 
    SBC $16
    BPL loc_0B9C0C
    EOR #$FFFF
    INC 

  loc_0B9C0C:
    CMP $7F100E, X
    BEQ loc_0B9C19
    DEC $24
    BMI loc_0B9C17
    RTL 

  loc_0B9C17:
    BRA loc_0B9BD9

  loc_0B9C19:
    STZ $2E
    LDA $12
    BIT #$2000
    BNE loc_0B9C33
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    LDA #$2000
    TSB $12
    BRA loc_0B9BD2

  loc_0B9C33:
    COP [StageSpriteFrame] ( #84 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    LDA #$2000
    TRB $12
    BRA loc_0B9BD2
} >
]
---------------------------------------------

mtA0_skulker2 [
  actor-def < #04, #00, #00, {

  code_0B9C47:
    LDA #$4000
    TSB $12
    BRA loc_0B9C53
} >
]
---------------------------------------------

mtA0_skulker_ew [
  actor-def < #04, #00, #00, {

  code_0B9C51:
    COP [SetHFlip]

  loc_0B9C53:
    LDA #$0010
    TSB $12
    COP [WaitWhileOffscreen] ( #08 )
    LDA #$0000
    STA $orbitAngle, X
    LDA #$0040
    STA $orbitDiameter, X
    LDA #$0150
    STA $7F100E, X
    LDA $16
    STA $7F100C, X

  loc_0B9C76:
    LDA $14
    STA $26

  loc_0B9C7A:
    COP [StageForceMoveX] ( #01 )

  loc_0B9C7D:
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0B9C7A
    LDA $08
    INC 
    STA $24
    STZ $08
    JSR $&sub2_0B9CE8
    CLC 
    ADC $7F100C, X
    STA $16
    LDA $orbitAngle, X
    SEC 
    SBC #$0002
    AND #$00FF
    STA $orbitAngle, X
    LDA $26
    SEC 
    SBC $14
    BPL loc_0B9CB0
    EOR #$FFFF
    INC 

  loc_0B9CB0:
    CMP $7F100E, X
    BEQ loc_0B9CBD
    DEC $24
    BMI loc_0B9CBB
    RTL 

  loc_0B9CBB:
    BRA loc_0B9C7D

  loc_0B9CBD:
    STZ $2C
    LDA $12
    BIT #$4000
    BNE loc_0B9CD7
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    LDA #$4000
    TSB $12
    BRA loc_0B9C76

  loc_0B9CD7:
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #84 )
    COP [AnimOnce]
    LDA #$4000
    TRB $12
    BRA loc_0B9C76
} >
]

sub2_0B9CE8 {
    LDA $orbitAngle, X
    TAY 
    SEP #$20
    CLC 
    LDA $&binary_01C384.binary_01C455, Y
    BPL loc2_0B9CF9
    EOR #$FF
    INC 
    SEC 

  loc2_0B9CF9:
    XBA 
    LDA $orbitDiameter, X
    JSL $@hardware_math.SignedMultiply
    REP #$20
    XBA 
    AND #$00FF
    BCC loc2_0B9D0E
    EOR #$FFFF
    INC 

  loc2_0B9D0E:
    RTS 
}