?BANK 02

!rngState                       040F
!WRMPYA                         4202
!WRMPYB                         4203
!WRDIVL                         4204
!WRDIVH                         4205
!WRDIVB                         4206
!RDDIVL                         4214
!RDMPYL                         4216
!L_WRMPYA                       804202
!L_WRMPYB                       804203
!L_RDMPYL                       804216
!L_RDMPYH                       804217

---------------------------------------------

MulDivide {
    SEP #$20
    STA $WRMPYA
    XBA 
    PHA 
    REP #$20
    TYA 
    SEP #$20
    STA $WRMPYB
    XBA 
    NOP 
    NOP 
    NOP 
    LDY $RDMPYL
    STA $WRMPYB
    REP #$20
    TYA 
    SEP #$20
    STA $WRDIVL
    XBA 
    CLC 
    ADC $RDMPYL
    STA $WRDIVH
    PLA 
    STA $WRDIVB
    NOP 
    NOP 
    NOP 
    NOP 
    NOP 
    NOP 
    NOP 
    NOP 
    REP #$20
    LDA $RDDIVL
    RTL 
}
---------------------------------------------

SignedMultiply {
    STA $L_WRMPYA
    XBA 
    STA $L_WRMPYB
    NOP 
    NOP 
    NOP 
    NOP 
    LDA $L_RDMPYH
    XBA 
    LDA $L_RDMPYL
    RTL 
}

UnsignedDivide {
    STY $WRDIVL
    STA $WRDIVB
    NOP 
    NOP 
    NOP 
    NOP 
    NOP 
    NOP 
    NOP 
    NOP 
    LDA $RDMPYL
    XBA 
    LDA $RDDIVL
    RTL 
}

SoftDivide_Unused {
    PHD 
    PHA 
    LDA #$0000
    TCD 
    PLA 
    STZ $00
    STZ $02
    STZ $04
    STZ $06
    CMP #$0000
    BMI loc_028217

  loc_028212:
    INC $00
    ASL 
    BPL loc_028212

  loc_028217:
    STA $02
    TYA 
    LDY #$0010
    CLC 

  loc_02821E:
    BCS loc_028224
    CMP $02
    BCC loc_028227

  loc_028224:
    SBC $02
    SEC 

  loc_028227:
    ROL $06
    DEC $00
    BMI loc_028231
    ASL 
    DEY 
    BNE loc_02821E

  loc_028231:
    ASL 
    LDY #$0010
    CLC 

  loc_028236:
    BCS loc_02823C
    CMP $02
    BCC loc_02823F

  loc_02823C:
    SBC $02
    SEC 

  loc_02823F:
    ROL $04
    ASL 
    DEY 
    BNE loc_028236
    PLD 
    RTL 
}

IncrementCounter_Unused {
    PHP 
    SEP #$20
    PHA 
    PHX 
    PHY 
    LDX #$000F
    LDA #$00
    XBA 
    CLC 

  loc_028254:
    LDA $0410, X
    ADC $rngState, X
    STA $rngState, X
    DEX 
    BNE loc_028254
    LDX #$0010

  loc_028263:
    INC $rngState, X
    BNE loc_02826B
    DEX 
    BNE loc_028263

  loc_02826B:
    PLA 
    PLY 
    PLX 
    PLP 
    RTL 
}