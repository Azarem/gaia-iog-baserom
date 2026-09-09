?BANK 02

?INCLUDE 'player_move_diag'
?INCLUDE 'player_move_ew'
?INCLUDE 'player_move_ns'
?INCLUDE 'tile_collision'

!playerActor                    09AA
!collisionLayer                 7FC000

---------------------------------------------

PlayerMovementTick {
    PHP 
    PHD 
    PHX 
    STX $000A
    LDA #$0000
    TCD 
    LDA $24
    STZ $24
    STZ $AA
    PHA 
    LDA $0010, X
    AND #$FFFB
    STA $0010, X
    LDA $20
    BEQ loc_02D002
    BPL loc_02CFFA
    LDA #$0040
    TSB $AA
    JSR $&player_move_diag.DispatchDiagDownLeft
    BRA loc_02D002

  loc_02CFFA:
    LDA #$0040
    TSB $AA
    JSR $&player_move_ew.DispatchWestMove

  loc_02D002:
    REP #$20
    LDX $playerActor
    LDA $22
    LSR 
    LSR 
    STA $0014, X
    LDA $26
    LSR 
    LSR 
    STA $0016, X
    STZ $20
    PLA 
    STA $24
    BEQ loc_02D034
    BPL loc_02D02A
    LDA $AA
    BIT #$0800
    BNE loc_02D034
    JSR $&player_move_ns.DispatchSouthMove
    BRA loc_02D034

  loc_02D02A:
    LDA $AA
    BIT #$0400
    BNE loc_02D034
    JSR $&player_move_ew.DispatchEastMove

  loc_02D034:
    PLX 
    PLD 
    PLP 
    RTL 
}
---------------------------------------------

ComputeYSnapOffset {
    REP #$20
    LDA $1E
    AND #$000F
    ORA #$FFF0
    EOR #$FFFF
    INC 
    STA $02
    RTS 
}

DiagSnapCompute_Unused {
    REP #$20
    LDA $1A
    PHA 
    LDA $1E
    PHA 
    SEP #$20
    JSR $&tile_collision.ProbeCurrentTL
    CMP #$06
    BEQ loc_02D277
    JSR $&tile_collision.CheckSubTileAlignX
    BCC loc_02D2A3
    JSR $&tile_collision.MapCellDown
    JSR $&tile_collision.ReadCollisionNibble
    CMP #$09
    BNE loc_02D2A3

  loc_02D277:
    REP #$20
    PLA 
    STA $1E
    PLA 
    STA $1A
    STZ $02
    LDA $1E
    PHA 
    LDA $24
    BEQ loc_02D28D
    LSR 
    LSR 
    ORA #$C000

  loc_02D28D:
    EOR #$FFFF
    INC 
    CLC 
    ADC $01, S
    EOR $01, S
    BIT #$0010
    BEQ loc_02D2A0
    LDA #$0010
    STA $02

  loc_02D2A0:
    PLA 
    BRA loc_02D2AD

  loc_02D2A3:
    REP #$20
    PLA 
    STA $1E
    PLA 
    STA $1A
    STZ $02

  loc_02D2AD:
    LDA $1E
    AND #$000F
    ORA #$FFF0
    EOR #$FFFF
    INC 
    CLC 
    ADC $02
    STA $02
    RTS 
}

AutoAlignEW {
    REP #$20
    LDA $AA
    BIT #$0040
    BNE loc_02D339
    LDA $collisionLayer, X
    AND #$00FF
    BIT #$00F0
    BNE loc_02D339
    LDA $22
    LSR 
    LSR 
    SEC 
    SBC #$0008
    AND #$000F
    STA $04
    BEQ loc_02D339
    CMP #$0006
    BCC loc_02D30D
    JSR $&tile_collision.ProbeFutureTR
    CMP #$000E
    BCS loc_02D30D
    CMP #$0006
    BEQ loc_02D30D
    LDX #$0022
    LDA $00, X
    SEC 
    SBC #$0020
    STA $00, X
    JSR $&NudgeToLowerGrid
    LDA $00, X
    CLC 
    ADC #$0020
    STA $00, X
    CLC 
    RTS 

  loc_02D30D:
    LDA $04
    CMP #$0009
    BCS loc_02D339
    JSR $&tile_collision.ProbeFutureTL
    CMP #$000E
    BCS loc_02D339
    CMP #$0009
    BEQ loc_02D339
    LDX #$0022
    LDA $00, X
    SEC 
    SBC #$0020
    STA $00, X
    JSR $&NudgeToUpperGrid
    LDA $00, X
    CLC 
    ADC #$0020
    STA $00, X
    CLC 
    RTS 

  loc_02D339:
    SEC 
    RTS 
}

NudgeToLowerGrid {
    LDA $00, X
    PHA 
    CLC 
    ADC #$0008
    STA $00, X
    EOR $01, S
    BIT #$0040
    BEQ loc_02D352
    LDA $00, X
    AND #$FFC0
    STA $00, X

  loc_02D352:
    PLA 
    RTS 
}

NudgeToUpperGrid {
    LDA $00, X
    PHA 
    SEC 
    SBC #$0008
    STA $00, X
    EOR $01, S
    BIT #$0040
    BEQ loc_02D374
    LDA $00, X
    BIT #$003F
    BEQ loc_02D374
    AND #$FFC0
    CLC 
    ADC #$0040
    STA $00, X

  loc_02D374:
    PLA 
    RTS 
}