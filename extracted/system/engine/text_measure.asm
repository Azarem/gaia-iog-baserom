?BANK 02

?INCLUDE 'dialogue_engine'
?INCLUDE 'dictionary_01EBA8'
?INCLUDE 'dictionary_01F54D'

!sceneCurrent                   0644

---------------------------------------------

MeasureDialogueWidth {
    LDA $0D6E
    CMP $sceneCurrent
    BNE loc_02A124
    RTL 

  loc_02A124:
    JSR $&CountTextGlyphs
    LDA $00
    BNE loc_02A12C
    RTL 

  loc_02A12C:
    PHP 
    PHB 
    SEC 
    SBC #$12
    EOR #$FF
    INC 
    AND #$FE
    PHA 
    LDA #$E0
    STA $00B4
    STZ $00B5
    LDA $0040
    PHA 
    LDY $3E
    PHY 
    PHK 
    PLB 
    LDY #$&dialogue_measure_format
    REP #$20
    JSL $@dialogue_engine.WideStringRenderer
    PLY 
    PLB 
    SEP #$20
    PLA 
    REP #$20
    AND #$00FF
    CLC 
    ADC $0998
    STA $0998
    JSL $@dialogue_engine.WideStringRenderer
    PLB 
    PLP 
    RTL 
}

dialogue_measure_format `[DLG:7,7][SIZ:A,1][SFX:0]`

CountTextGlyphs {
    PHP 
    REP #$20
    INC $3E
    STZ $00
    SEP #$20
    LDY #$0000

  loc_02A17E:
    LDA [$3E], Y
    CMP #$CA
    BEQ loc_02A1A7
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

  loc_02A197:
    CMP #$D6
    BEQ loc_02A1A9
    CMP #$D7
    BEQ loc_02A1BE
    INY 
    BRA loc_02A17E

  loc_02A1A2:
    INY 
    INC $00
    BRA loc_02A17E

  loc_02A1A7:
    PLP 
    RTS 

  loc_02A1A9:
    INY 
    PHB 
    PHY 
    LDA #$^dictionary_01EBA8
    PHA 
    PLB 
    REP #$20
    LDA [$3E], Y
    AND #$00FF
    ASL 
    CLC 
    ADC #$&dictionary_01EBA8
    BRA loc_02A1D1

  loc_02A1BE:
    INY 
    PHB 
    PHY 
    LDA #$^dictionary_01F54D
    PHA 
    PLB 
    REP #$20
    LDA [$3E], Y
    AND #$00FF
    ASL 
    CLC 
    ADC #$&dictionary_01F54D

  loc_02A1D1:
    TAY 
    LDA $0000, Y
    TAY 
    SEP #$20

  loc_02A1D8:
    LDA $0000, Y
    CMP #$CA
    BEQ loc_02A1E4
    INC $00
    INY 
    BRA loc_02A1D8

  loc_02A1E4:
    PLY 
    PLB 
    INY 
    BRA loc_02A17E
}