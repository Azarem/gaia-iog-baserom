?INCLUDE 'binary_01C384'
?INCLUDE 'hardware_math'

!orbitAngle                     7F0010
!orbitDiameter                  7F0012

---------------------------------------------

ApplyOrbitalOffsetXY {
    LDA $orbitAngle, X
    AND #$00FF
    TAY 
    SEP #$20
    CLC 
    LDA $&binary_01C384.binary_01C455, Y
    BPL loc_00F446
    EOR #$FF
    INC 
    SEC 

  loc_00F446:
    XBA 
    LDA $orbitDiameter, X
    JSL $@hardware_math.SignedMultiply
    REP #$20
    XBA 
    AND #$00FF
    BCC loc_00F45B
    EOR #$FFFF
    INC 

  loc_00F45B:
    CLC 
    ADC $14
    STA $14
    LDA #$0000
    SEP #$20
    CLC 
    LDA $7F0011, X
    TAY 
    LDA $&binary_01C384.binary_01C495, Y
    BPL loc_00F474
    EOR #$FF
    INC 
    SEC 

  loc_00F474:
    XBA 
    LDA $7F0013, X
    JSL $@hardware_math.SignedMultiply
    REP #$20
    XBA 
    AND #$00FF
    BCC loc_00F489
    EOR #$FFFF
    INC 

  loc_00F489:
    CLC 
    ADC $16
    STA $16
    RTL 
}