---------------------------------------------

ClearVramBufferPartial {
    PHX 
    PHP 
    REP #$20
    LDA #$0000
    LDX #$0140
    BRA loc_02F07E
}

ClearVramBufferFull {
    PHX 
    PHP 
    REP #$20
    LDA #$0000
    TAX 

  loc_02F07E:
    STA $7F0200, X
    INX 
    INX 
    CPX #$0800
    BNE loc_02F07E
    PLP 
    PLX 
    RTL 
}