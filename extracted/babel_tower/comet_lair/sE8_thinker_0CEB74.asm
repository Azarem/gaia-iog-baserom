?BANK 0C

!BG1SC                          2107
!BG2SC                          2108
!WOBJSEL                        2125
!WH0                            2126
!WH1                            2127
!TM                             212C
!TS                             212D
!CGWSEL                         2130
!CGADSUB                        2131

---------------------------------------------

sE8_thinker_0CEB74 [
  thinker-def < #04, #08, {

  code_0CEB76:
    SEP #$20
    LDA #$16
    STA $TM
    LDA #$00
    STA $TS
    LDA #$82
    STA $CGWSEL
    LDA #$02
    STA $CGADSUB
    LDA #$10
    STA $BG1SC
    LDA #$18
    STA $BG2SC
    REP #$20
    COP [SetEntryExit]
    COP [BranchIfFlagByte] ( #FF, #00, &code_0CEB76 )
    RTL 
} >
]

code_0CEBA1 {
    SEP #$20
    LDA #$17
    STA $TM
    LDA #$02
    STA $TS
    LDA #$82
    STA $CGWSEL
    LDA #$11
    STA $CGADSUB
    LDA #$10
    STA $BG1SC
    LDA #$18
    STA $BG2SC
    REP #$20
    COP [SetEntryExit]
    COP [BranchIfFlagByte] ( #FF, #00, &code_0CEBA1 )
    RTL 
}

code_0CEBCC {
    SEP #$20
    LDA #$17
    STA $TM
    LDA #$00
    STA $TS
    LDA #$80
    STA $CGWSEL
    LDA #$80
    STA $CGADSUB
    LDA #$10
    STA $BG1SC
    LDA #$18
    STA $BG2SC
    REP #$20
    COP [SetEntryExit]
    COP [BranchIfFlagByte] ( #FF, #00, &code_0CEBCC )
    RTL 
}

code_0CEBF7 {
    SEP #$20
    LDA #$00
    STA $WH0
    STA $WH1
    LDA #$17
    STA $TM
    LDA #$00
    STA $TS
    LDA #$30
    STA $WOBJSEL
    LDA #$22
    STA $CGWSEL
    LDA #$03
    STA $CGADSUB
    LDA #$57
    STA $7F0C02
    LDA #$10
    STA $BG1SC
    LDA #$18
    STA $BG2SC
    REP #$20
    COP [SetEntryExit]
    COP [BranchIfFlagByte] ( #FF, #00, &code_0CEBF7 )
    RTL 
}

code_0CEC35 {
    SEP #$20
    LDA #$00
    STA $WOBJSEL
    LDA #$17
    STA $TM
    LDA #$00
    STA $TS
    LDA #$80
    STA $CGWSEL
    LDA #$3F
    STA $CGADSUB
    LDA #$10
    STA $BG1SC
    LDA #$18
    STA $BG2SC
    REP #$20
    COP [SetEntryExit]
    COP [BranchIfFlagByte] ( #FF, #00, &code_0CEC35 )
    RTL 
}