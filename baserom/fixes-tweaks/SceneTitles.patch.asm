
-----------------------------------------------
?INCLUDE 'text_measure'

;Auto-size and center scene titles

loc_02A12C! {
    PHP 
    PHB 
    
    PEA #$CA01
    INC
    LSR
    PHA
    PEA #$C707

    CLC
    SBC #$10
    EOR #$FF
    PHA

    LDA #$C1
    PHA

    TSC
    LDY $3E
    PHY 
    TAY
    INY

    LDA $40
    PHA
    
    LDA #$E0
    STA $00B4
    STZ $00B5
    
    REP #$20
    JSL $@DialogStringRenderer
    PLB
    PLY

    PLA
    PLA
    PLA
    JSL $@DialogStringRenderer

    PLB
    PLB
    PLP
    RTL
}

-----------------------------------------------
;Take extended accent characters into account during char counts

loc_02A17E! {
    LDA [$3E], Y
    CMP #$CA
    BEQ loc_02A1A7
    CMP #$E0
    BCS loc_02A1A2
    CMP #$C0
    BCC loc_02A1A2
    CMP #$CC
    BNE loc_02A197
    INY 
    LDA [$3E], Y
    INY 
    CLC 
    ADC $00
    STA $00
    BRA loc_02A17E
}
