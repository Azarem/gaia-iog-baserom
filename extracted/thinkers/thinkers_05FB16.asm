!tileStagingBuffer              7E7000
!chatPtr                        7F000A

---------------------------------------------

crF7_thinker_05FB16 [
  thinker-def < #04, #08, {

  code_05FB18:
    COP [SetEntryContinue]
    JSR $&code_05FB59
    LDA $chatPtr, X
    LSR 
    BCC loc_05FB2B
    COP [QueueHdma] ( $7E7000, #26 )
    RTL 

  loc_05FB2B:
    COP [QueueHdma] ( $7E7100, #26 )
    RTL 
} >
]

thinker_def_05FB32 [
  thinker-def < #04, #08, {

  code_05FB34:
    JSR $&code_05FE9A
    COP [SetEntryContinue]
    JSR $&code_05FEA4
    BCS loc_05FB44
    JSR $&code_05FC92
    JSR $&code_05FEBF

  loc_05FB44:
    LDA $chatPtr, X
    LSR 
    BCC loc_05FB52
    COP [QueueHdma] ( $7E7000, #26 )
    RTL 

  loc_05FB52:
    COP [QueueHdma] ( $7E7100, #26 )
    RTL 
} >
]

code_05FB59 {
    PHX 
    PHD 
    PHB 
    LDA #$0000
    TCD 
    SEP #$20
    LDA #$7E
    PHA 
    PLB 
    REP #$20
    JSR $&code_05FE2C
    BCC loc_05FB70
    JMP $&code_05FC71

  loc_05FB70:
    LDY $02
    LDA #$0001
    STA $0000, Y
    LDA $04
    STA $0001, Y
    LDA #$0000
    STA $0003, Y
    LDA $FE
    BPL loc_05FB8A
    JMP $&code_05FC71

  loc_05FB8A:
    AND #$FFFE
    STA $FC
    STA $18
    STA $1A
    BIT #$FF00
    BEQ loc_05FB9D
    LDA #$00FE
    STA $1A

  loc_05FB9D:
    LDA $F8
    ASL 
    SEC 
    SBC $18
    BCC loc_05FBB8
    LSR 
    JSR $&code_05FDD7
    LDA $18
    EOR #$FFFF
    INC 
    CLC 
    ADC $00
    STA $02
    LDA $18
    BRA loc_05FBCA

  loc_05FBB8:
    LDA $F8
    ASL 
    PHA 
    EOR #$FFFF
    INC 
    CLC 
    ADC $00
    STA $02
    PLA 
    CLC 
    ADC $18
    LSR 

  loc_05FBCA:
    INC 
    JSR $&code_05FDFA
    LDA #$0001
    STA $0000, Y
    LDA $04
    STA $0001, Y
    LDA #$0000
    STA $0003, Y
    LDA #$0000
    CLC 
    BRA loc_05FBE9

  code_05FBE5:
    LDA $1C
    INC 
    INC 

  loc_05FBE9:
    STA $1C
    STA $1E
    BIT #$FF00
    BEQ loc_05FBF7
    LDA #$00FE
    STA $1E

  loc_05FBF7:
    LDA $1C
    BIT #$FE00
    BNE loc_05FC27
    LDA $1C
    CLC 
    ADC $00
    TAX 
    LDA $00
    SEC 
    SBC $1C
    TAY 
    SEP #$20
    LDA $1A
    CLC 
    ADC $F4
    BCC loc_05FC15
    LDA #$FF

  loc_05FC15:
    XBA 
    LDA $F4
    SEC 
    SBC $1A
    BCS loc_05FC1F
    LDA #$00

  loc_05FC1F:
    REP #$20
    STA $0000, X
    STA $0000, Y

  loc_05FC27:
    LDA $18
    BIT #$FE00
    BNE loc_05FC57
    LDA $00
    CLC 
    ADC $18
    TAX 
    LDA $00
    SEC 
    SBC $18
    TAY 
    SEP #$20
    LDA $1E
    CLC 
    ADC $F4
    BCC loc_05FC45
    LDA #$FF

  loc_05FC45:
    XBA 
    LDA $F4
    SEC 
    SBC $1E
    BCS loc_05FC4F
    LDA #$00

  loc_05FC4F:
    REP #$20
    STA $0000, X
    STA $0000, Y

  loc_05FC57:
    LDA $1C
    ASL 
    DEC 
    EOR #$FFFF
    INC 
    CLC 
    ADC $FC
    STA $FC
    BMI loc_05FC75

  loc_05FC66:
    LDA $18
    BMI code_05FC71
    CMP $1C
    BCC code_05FC71
    JMP $&code_05FBE5
}

code_05FC71 {
    PLB 
    PLD 
    PLX 
    RTS 

  loc_05FC75:
    LDA $18
    DEC 
    ASL 
    CLC 
    ADC $FC
    STA $FC
    LDA $18
    DEC 
    DEC 
    STA $18
    STA $1A
    BIT #$FF00
    BEQ loc_05FC66
    LDA #$00FF
    STA $1A
    BRA loc_05FC66
}

code_05FC92 {
    PHX 
    PHD 
    PHB 
    LDA #$0000
    TCD 
    SEP #$20
    LDA #$7E
    PHA 
    PLB 
    REP #$20
    JSR $&code_05FE2C
    BCC loc_05FCA9
    JMP $&code_05FDB7

  loc_05FCA9:
    LDY $02
    LDA #$0001
    STA $0000, Y
    LDA $04
    STA $0001, Y
    LDA #$0000
    STA $0003, Y
    LDA $FE
    BPL loc_05FCC3
    JMP $&code_05FDB7

  loc_05FCC3:
    AND #$FFFE
    STA $FC
    STA $18
    STA $1A
    BIT #$FF00
    BEQ loc_05FCD6
    LDA #$00FE
    STA $1A

  loc_05FCD6:
    LDA $F8
    BMI loc_05FCF3
    SEC 
    SBC $18
    BCC loc_05FCF3
    JSR $&code_05FDD7
    LDA $18
    ASL 
    EOR #$FFFF
    INC 
    CLC 
    ADC $00
    STA $02
    LDA $18
    ASL 
    BRA loc_05FD0B

  loc_05FCF3:
    LDA $F8
    CLC 
    ADC $FC
    BMI loc_05FD0F
    LDA $F8
    PHA 
    ASL 
    EOR #$FFFF
    INC 
    CLC 
    ADC $00
    STA $02
    PLA 
    CLC 
    ADC $18

  loc_05FD0B:
    INC 
    JSR $&code_05FDFA

  loc_05FD0F:
    LDA #$0001
    STA $0000, Y
    LDA $04
    STA $0001, Y
    LDA #$0000
    STA $0003, Y
    LDA #$0000
    CLC 
    BRA loc_05FD29

  code_05FD26:
    LDA $1C
    INC 

  loc_05FD29:
    STA $1C
    STA $1E
    BIT #$FF00
    BEQ loc_05FD37
    LDA #$00FE
    STA $1E

  loc_05FD37:
    LDA $1C
    BIT #$FF00
    BNE loc_05FD6A
    LDA $1E
    ASL 
    PHA 
    CLC 
    ADC $00
    TAX 
    LDA $00
    SEC 
    SBC $01, S
    TAY 
    PLA 
    SEP #$20
    LDA $1A
    CLC 
    ADC $F4
    BCC loc_05FD58
    LDA #$FF

  loc_05FD58:
    XBA 
    LDA $F4
    SEC 
    SBC $1A
    BCS loc_05FD62
    LDA #$00

  loc_05FD62:
    REP #$20
    STA $0000, X
    STA $0000, Y

  loc_05FD6A:
    LDA $18
    BIT #$FF00
    BNE loc_05FD9D
    LDA $1A
    ASL 
    PHA 
    CLC 
    ADC $00
    TAX 
    LDA $00
    SEC 
    SBC $01, S
    TAY 
    PLA 
    SEP #$20
    LDA $1E
    CLC 
    ADC $F4
    BCC loc_05FD8B
    LDA #$FF

  loc_05FD8B:
    XBA 
    LDA $F4
    SEC 
    SBC $1E
    BCS loc_05FD95
    LDA #$00

  loc_05FD95:
    REP #$20
    STA $0000, X
    STA $0000, Y

  loc_05FD9D:
    LDA $1C
    ASL 
    DEC 
    EOR #$FFFF
    INC 
    CLC 
    ADC $FC
    STA $FC
    BMI loc_05FDBB

  loc_05FDAC:
    LDA $18
    BMI code_05FDB7
    CMP $1C
    BCC code_05FDB7
    JMP $&code_05FD26
}

code_05FDB7 {
    PLB 
    PLD 
    PLX 
    RTS 

  loc_05FDBB:
    LDA $18
    DEC 
    ASL 
    CLC 
    ADC $FC
    STA $FC
    LDA $18
    DEC 
    STA $18
    STA $1A
    BIT #$FF00
    BEQ loc_05FDAC
    LDA #$00FF
    STA $1A
    BRA loc_05FDAC
}

code_05FDD7 {
    BNE loc_05FDDA
    RTS 

  loc_05FDDA:
    PHA 
    CMP #$0080
    BCC loc_05FDE3
    LDA #$007F

  loc_05FDE3:
    PHA 
    LDA $03, S
    SEC 
    SBC $01, S
    STA $03, S
    PLA 
    STA $0000, Y
    LDA $04
    STA $0001, Y
    INY 
    INY 
    INY 
    PLA 
    BRA code_05FDD7
}

code_05FDFA {
    BNE loc_05FDFD
    RTS 

  loc_05FDFD:
    PHA 
    CMP #$0080
    BCC loc_05FE06
    LDA #$007F

  loc_05FE06:
    PHA 
    LDA $03, S
    SEC 
    SBC $01, S
    STA $03, S
    PLA 
    ORA #$0080
    STA $0000, Y
    LDA $02
    STA $0001, Y
    LDA $0000, Y
    AND #$007F
    ASL 
    CLC 
    ADC $02
    STA $02
    INY 
    INY 
    INY 
    PLA 
    BRA code_05FDFA
}

code_05FE2C {
    LDA $00FE
    CMP $00FC
    BNE loc_05FE49
    LDA $00F6
    CMP $00F4
    BNE loc_05FE4F
    LDA $00FA
    CMP $00F8
    BNE loc_05FE47
    JMP $&code_05FE98

  loc_05FE47:
    BRA loc_05FE55

  loc_05FE49:
    STA $00FC
    LDA $00F6

  loc_05FE4F:
    STA $00F4
    LDA $00FA

  loc_05FE55:
    STA $00F8
    LDA $chatPtr, X
    INC 
    STA $chatPtr, X
    LSR 
    BCC loc_05FE7E
    LDA #$7600
    STA $0000
    LDA #$7000
    STA $0002
    LDA #$00FF
    STA $7E7200
    LDA #$7200
    STA $04
    CLC 
    RTS 

  loc_05FE7E:
    LDA #$7A00
    STA $0000
    LDA #$7100
    STA $0002
    LDA #$00FF
    STA $7E7200
    LDA #$7200
    STA $04
    CLC 
    RTS 
}

code_05FE98 {
    SEC 
    RTS 
}

code_05FE9A {
    STZ $00F4
    STZ $00F8
    STZ $00FC
    RTS 
}

code_05FEA4 {
    LDA $00F4
    CMP $00F6
    BNE loc_05FEBD
    LDA $00F8
    CMP $00FA
    BNE loc_05FEBD
    LDA $00FC
    CMP $00FE
    BNE loc_05FEBD
    RTS 

  loc_05FEBD:
    CLC 
    RTS 
}

code_05FEBF {
    LDA $00F6
    STA $00F4
    LDA $00FA
    STA $00F8
    LDA $00FE
    STA $00FC
    RTS 
}