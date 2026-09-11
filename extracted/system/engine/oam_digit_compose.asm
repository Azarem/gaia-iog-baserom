?BANK 03

!oamComposeBuffer               7F3100

---------------------------------------------

ComposeDigits_Continuation {
    PHX 
    LDA $0018
    STA $001A
    SEC 
    SBC #$0006
    STA $0018
    BRA loc_03BB0D
}

ComposeDigitSprites {
    PHX 
    LDA $0000
    BIT #$F000
    BNE loc_03BB5C
    LDA $14
    SEC 
    SBC #$000C
    STA $0018
    LDA $16
    STA $001C
    LDA $0E
    STA $0002

  loc_03BB0D:
    LDA $0001
    AND #$000F
    BEQ loc_03BB24
    JSR $&EmitDigitOamEntry
    LDA $0018
    CLC 
    ADC #$0008
    STA $0018
    BRA loc_03BB2E

  loc_03BB24:
    LDA $0018
    CLC 
    ADC #$0004
    STA $0018

  loc_03BB2E:
    LDA $0000
    LSR 
    LSR 
    LSR 
    LSR 
    BEQ loc_03BB49
    AND #$000F
    JSR $&EmitDigitOamEntry
    LDA $0018
    CLC 
    ADC #$0008
    STA $0018
    BRA loc_03BB53

  loc_03BB49:
    LDA $0018
    CLC 
    ADC #$0004
    STA $0018

  loc_03BB53:
    LDA $0000
    AND #$000F
    JSR $&EmitDigitOamEntry

  loc_03BB5C:
    PLX 
    RTL 
}

EmitDigitOamEntry {
    LDX $00D8
    CLC 
    ADC #$0070
    ORA $0002
    STA $7F3104, X
    LDA $0018
    STA $oamComposeBuffer, X
    LDA $001C
    STA $7F3102, X
    LDA $00D8
    CLC 
    ADC #$0006
    STA $00D8
    RTS 
}