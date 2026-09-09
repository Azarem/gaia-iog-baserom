?INCLUDE 'binary_01C384'
?INCLUDE 'hardware_math'

!orbitAngle                     7F0010
!orbitDiameter                  7F0012

---------------------------------------------

ApplyOrbitalOffsetFromRef {
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    STA $16

  code_00F3D3:
    LDA $orbitAngle, X
    AND #$00FF
    TAY 
    SEP #$20
    CLC 
    LDA $&binary_01C384.binary_01C455, Y
    BPL loc_00F3E7
    EOR #$FF
    INC 
    SEC 

  loc_00F3E7:
    XBA 
    LDA $orbitDiameter, X
    JSL $@hardware_math.SignedMultiply
    REP #$20
    XBA 
    AND #$00FF
    BCC loc_00F3FC
    EOR #$FFFF
    INC 

  loc_00F3FC:
    CLC 
    ADC $14
    STA $14
    SEP #$20
    CLC 
    LDA $&binary_01C384.binary_01C495, Y
    BPL loc_00F40D
    EOR #$FF
    INC 
    SEC 

  loc_00F40D:
    XBA 
    LDA $orbitDiameter, X
    JSL $@hardware_math.SignedMultiply
    REP #$20
    XBA 
    AND #$00FF
    BCC loc_00F422
    EOR #$FFFF
    INC 

  loc_00F422:
    CLC 
    ADC $16
    STA $16
    RTL 
}