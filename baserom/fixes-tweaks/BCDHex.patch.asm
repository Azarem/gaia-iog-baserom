
----------------------------------------------------------

;Fix for string code 05 BCD processing to include hex chars
loc_03ED90! {
    LDA $0000, Y
    AND #$0F
    CMP #$0A
    BMI bcd_numeric1

    CLC
    ADC #$37
    BRA bcd_store1

  bcd_numeric1:
    ORA #$30

  bcd_store1:
    REP #$20
    DEX 
    DEX 
    STA $7F0200, X
    SEP #$20
    DEC $000E
    BEQ loc_03EDC1
    LDA $0000, Y
    INY 
    ;AND #$F0
    LSR 
    LSR 
    LSR 
    LSR
    CMP #$0A
    BMI bcd_numeric2

    CLC
    ADC #$37
    BRA bcd_store2

  bcd_numeric2:
    ORA #$30

  bcd_store2:
    REP #$20
    DEX 
    DEX 
    STA $7F0200, X
    SEP #$20
    DEC $000E
    BNE loc_03ED90
}
