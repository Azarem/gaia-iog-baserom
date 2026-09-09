?INCLUDE 'binary_01C384'

!WRDIVL                         4204
!WRDIVB                         4206
!RDDIVL                         4214
!tileStagingBuffer              7E7000

---------------------------------------------

func_03AB88 {
    PHX 
    SEP #$20
    LDX #$0000
    LDA #$F0
    STA $tileStagingBuffer, X
    STA $7E7003, X
    STA $7E7006, X
    STA $7E7800, X
    STA $7E7803, X
    STA $7E7806, X
    STA $7E8000, X
    STA $7E8003, X
    STA $7E8006, X
    REP #$20
    LDA #$7100
    STA $7E7001, X
    LDA #$71E0
    STA $7E7004, X
    LDA #$7900
    STA $7E7801, X
    LDA #$79E0
    STA $7E7804, X
    LDA #$8100
    STA $7E8001, X
    LDA #$81E0
    STA $7E8004, X
    PLX 
    COP [SetEntryContinue]
    PHX 
    PHD 
    LDA #$0000
    TCD 
    LDA $B8
    STZ $00
    STA $02
    LDA $B6
    STA $04
    LDA #$00E0
    STA $0E
    LDA $BC
    AND #$01FF
    ASL 
    TAY 
    LDX #$01C0
    PEA $&code_03AC38-1
    LDA $&binary_01C384.binary_01C695, Y
    BMI loc_03AC1F
    STA $18
    LDA $&binary_01C384.binary_01C595, Y
    BMI loc_03AC16
    STA $1C
    JMP $&code_03AC53

  loc_03AC16:
    EOR #$FFFF
    INC 
    STA $1C
    JMP $&code_03AC9B

  loc_03AC1F:
    EOR #$FFFF
    INC 
    STA $18
    LDA $&binary_01C384.binary_01C595, Y
    BMI loc_03AC2F
    STA $1C
    JMP $&code_03ACE3

  loc_03AC2F:
    EOR #$FFFF
    INC 
    STA $1C
    JMP $&code_03AD2D
}

code_03AC38 {
    PLD 
    PLX 
    COP [QueueHdma] ( $7E7000, #1B )
    COP [QueueHdma] ( $7E7800, #1C )
    COP [QueueHdma] ( $7E8000, #1D )
    COP [QueueHdma] ( $7E7000, #1E )
    RTL 
}

code_03AC53 {
    LDY $02
    LDA $18
    STA $WRDIVL
    STY $WRDIVB
    NOP 
    NOP 
    NOP 
    NOP 
    NOP 
    NOP 
    DEX 
    DEX 
    LDA $RDDIVL
    STA $7E7100, X
    LDA $1C
    STA $WRDIVL
    STY $WRDIVB
    NOP 
    LDA $01
    SEC 
    SBC $04
    STA $01
    LDA $RDDIVL
    STA $7E7900, X
    EOR #$FFFF
    INC 
    STA $7E8100, X
    BCC loc_03AC93
    CPX #$0000
    BPL code_03AC53
    RTS 

  loc_03AC93:
    DEC $03
    CPX #$0000
    BPL code_03AC53
    RTS 
}

code_03AC9B {
    LDY $02
    LDA $18
    STA $WRDIVL
    STY $WRDIVB
    NOP 
    NOP 
    NOP 
    NOP 
    NOP 
    NOP 
    DEX 
    DEX 
    LDA $RDDIVL
    STA $7E7100, X
    LDA $1C
    STA $WRDIVL
    STY $WRDIVB
    NOP 
    LDA $01
    SEC 
    SBC $04
    STA $01
    LDA $RDDIVL
    STA $7E8100, X
    EOR #$FFFF
    INC 
    STA $7E7900, X
    BCC loc_03ACDB
    CPX #$0000
    BPL code_03AC9B
    RTS 

  loc_03ACDB:
    DEC $03
    CPX #$0000
    BPL code_03AC9B
    RTS 
}

code_03ACE3 {
    LDY $02
    LDA $18
    STA $WRDIVL
    STY $WRDIVB
    NOP 
    NOP 
    NOP 
    NOP 
    DEX 
    DEX 
    LDA #$0000
    SEC 
    SBC $RDDIVL
    STA $7E7100, X
    LDA $1C
    STA $WRDIVL
    STY $WRDIVB
    NOP 
    LDA $01
    SEC 
    SBC $04
    STA $01
    LDA $RDDIVL
    STA $7E7900, X
    EOR #$FFFF
    INC 
    STA $7E8100, X
    BCC loc_03AD25
    CPX #$0000
    BPL code_03ACE3
    RTS 

  loc_03AD25:
    DEC $03
    CPX #$0000
    BPL code_03ACE3
    RTS 
}

code_03AD2D {
    LDY $02
    LDA $18
    STA $WRDIVL
    STY $WRDIVB
    NOP 
    NOP 
    NOP 
    NOP 
    DEX 
    DEX 
    LDA #$0000
    SEC 
    SBC $RDDIVL
    STA $7E7100, X
    LDA $1C
    STA $WRDIVL
    STY $WRDIVB
    NOP 
    LDA $01
    SEC 
    SBC $04
    STA $01
    LDA $RDDIVL
    STA $7E8100, X
    EOR #$FFFF
    INC 
    STA $7E7900, X
    BCC loc_03AD6F
    CPX #$0000
    BPL code_03AD2D
    RTS 

  loc_03AD6F:
    DEC $03
    CPX #$0000
    BPL code_03AD2D
    RTS 
}