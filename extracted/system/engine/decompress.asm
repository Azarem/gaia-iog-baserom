?BANK 02

---------------------------------------------

QuintetLzDecompress {
    PHP 
    PHB 
    PHX 
    PHY 
    SEP #$20
    LDA #$7E
    PHA 
    PLB 
    LDX #$0200
    STX $74
    STX $76
    LDA #$20

  loc_028283:
    STA ($74)
    INC $74
    BNE loc_028283
    LDA #$EF
    STA $74
    LDA #$80
    STA $72
    LDX $7A
    LDY $78

  loc_028295:
    LDA [$3E]
    AND $72
    PHA 
    LSR $72
    BCC loc_0282A6
    ROR $72
    INC $3E
    BNE loc_0282A6
    INC $3F

  loc_0282A6:
    PLA 
    BEQ loc_0282B9
    JSR $&LzReadBitField
    STA $0000, X
    INX 
    STA ($74)
    INC $74
    DEY 
    BNE loc_028295
    BRA loc_0282D9

  loc_0282B9:
    JSR $&LzReadBitField
    STA $76
    JSR $&LzReadBackRef
    INC 
    INC 

  loc_0282C3:
    XBA 
    LDA ($76)
    INC $76
    STA ($74)
    INC $74
    STA $0000, X
    INX 
    DEY 
    BEQ loc_0282D9
    XBA 
    DEC 
    BNE loc_0282C3
    BRA loc_028295

  loc_0282D9:
    PLY 
    PLX 
    PLB 
    PLP 
    RTL 
}

LzReadBitField {
    LDA $72
    BMI loc_028325
    ASL 
    BMI loc_02831E
    ASL 
    BMI loc_028317
    ASL 
    BMI loc_028310
    ASL 
    BMI loc_028309
    ASL 
    BMI loc_028302
    ASL 
    BMI loc_0282FB
    REP #$20
    LDA [$3E]
    XBA 
    BRA loc_02832E

  loc_0282FB:
    REP #$20
    LDA [$3E]
    XBA 
    BRA loc_02832F

  loc_028302:
    REP #$20
    LDA [$3E]
    XBA 
    BRA loc_028330

  loc_028309:
    REP #$20
    LDA [$3E]
    XBA 
    BRA loc_028331

  loc_028310:
    REP #$20
    LDA [$3E]
    XBA 
    BRA loc_028332

  loc_028317:
    REP #$20
    LDA [$3E]
    XBA 
    BRA loc_028333

  loc_02831E:
    REP #$20
    LDA [$3E]
    XBA 
    BRA loc_028334

  loc_028325:
    LDA [$3E]
    REP #$20
    INC $3E
    SEP #$20
    RTS 

  loc_02832E:
    ASL 

  loc_02832F:
    ASL 

  loc_028330:
    ASL 

  loc_028331:
    ASL 

  loc_028332:
    ASL 

  loc_028333:
    ASL 

  loc_028334:
    ASL 
    INC $3E
    XBA 
    SEP #$20
    RTS 
}

LzReadBackRef {
    LDA $72
    CMP #$10
    BCC loc_02835D
    LSR 
    LSR 
    LSR 
    LSR 
    STA $72
    XBA 
    LDA [$3E]
    XBA 
    REP #$20
    LSR 
    BCS loc_028357
    LSR 
    BCS loc_028357
    LSR 
    BCS loc_028357
    LSR 

  loc_028357:
    SEP #$20
    XBA 
    AND #$0F
    RTS 

  loc_02835D:
    LSR 
    BCS loc_02838E
    LSR 
    BCS loc_028381
    LSR 
    BCS loc_028375
    LDA #$80
    STA $72
    LDA [$3E]
    REP #$20
    INC $3E
    SEP #$20
    AND #$0F
    RTS 

  loc_028375:
    LDA #$40
    STA $72
    REP #$20
    LDA [$3E]
    XBA 
    ASL 
    BRA loc_02839A

  loc_028381:
    LDA #$20
    STA $72
    REP #$20
    LDA [$3E]
    XBA 
    ASL 
    ASL 
    BRA loc_02839A

  loc_02838E:
    LDA #$10
    STA $72
    REP #$20
    LDA [$3E]
    XBA 
    ASL 
    ASL 
    ASL 

  loc_02839A:
    INC $3E
    SEP #$20
    XBA 
    AND #$0F
    RTS 
}