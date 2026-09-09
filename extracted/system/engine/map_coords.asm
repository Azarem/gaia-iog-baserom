?BANK 02

?INCLUDE 'hardware_math'
?INCLUDE 'tile_collision'

!mapRowStrideL0                 0693
!mapRowStrideL1                 0695

---------------------------------------------

TileCoordsToMapIndex {
    PHP 
    REP #$20
    LDA $1C
    ASL 
    ASL 
    ASL 
    ASL 
    PHA 
    SEP #$20
    LDA $mapRowStrideL0, X
    JSL $@hardware_math.SignedMultiply
    STA $02, S
    LDA $18
    AND #$0F
    CLC 
    ADC $01, S
    STA $01, S
    LDA $18
    LSR 
    LSR 
    LSR 
    LSR 
    CLC 
    ADC $02, S
    STA $02, S
    PLX 
    PLP 
    RTL 
}

PixelToVramAddress {
    LDA $1E
    AND #$00F8
    ASL 
    ASL 
    PHA 
    LDA $1A
    AND #$00F8
    LSR 
    LSR 
    LSR 
    CLC 
    ADC $01, S
    STA $01, S
    LDA $1A
    AND #$0100
    ASL 
    ASL 
    CLC 
    ADC $01, S
    STA $01, S
    PLA 
    CLC 
    ADC #$1000
    RTL 
}

MapIndexMoveRight {
    PHP 
    SEP #$20
    LDA $02
    INC 
    BIT #$0F
    BEQ loc_02B106
    STA $02
    LDX $02
    PLP 
    RTL 

  loc_02B106:
    XBA 
    LDA $03
    INC 
    XBA 
    CLC 
    ADC #$F0
    TAX 
    STX $02
    PLP 
    RTL 
}

MapIndexMoveLeft {
    PHP 
    REP #$20
    LDA $02
    SEP #$20
    DEC 
    PHA 
    AND #$0F
    CMP #$0F
    BEQ loc_02B126
    PLA 
    TAX 
    PLP 
    RTL 

  loc_02B126:
    PLA 
    XBA 
    LDA $03
    DEC 
    XBA 
    SEC 
    SBC #$F0
    TAX 
    PLP 
    RTL 
}

MapIndexMoveDown {
    PHP 
    REP #$20
    LDA $02
    SEP #$20
    CLC 
    ADC #$10
    BCS loc_02B143
    TAX 
    STX $02
    PLP 
    RTL 

  loc_02B143:
    XBA 
    CLC 
    ADC $mapRowStrideL0
    XBA 
    TAX 
    STX $02
    PLP 
    RTL 
}

MapIndexMoveDown_L1 {
    PHP 
    LDA $02
    SEP #$20
    CLC 
    ADC #$10
    BCS loc_02B15D
    TAX 
    STX $02
    PLP 
    RTL 

  loc_02B15D:
    XBA 
    CLC 
    ADC $mapRowStrideL1
    XBA 
    TAX 
    STX $02
    PLP 
    RTL 
}

ProbeRightTiles {
    JSR $&tile_collision.ProbeCurrentTL
    REP #$20
    LDA $1A
    CLC 
    ADC #$0008
    STA $1A
    SEP #$20
    JSR $&tile_collision.TileProbeMain
    CMP #$0A
    BEQ loc_02B1B5
    CMP #$05
    BEQ loc_02B1B7
    CMP #$09
    BNE loc_02B190
    JSR $&tile_collision.MapCellLeft
    JSR $&tile_collision.ReadCollisionNibble
    CMP #$0A
    BEQ loc_02B1B5

  loc_02B190:
    JSR $&tile_collision.MapCellRight
    JSR $&tile_collision.ReadCollisionNibble
    CMP #$0A
    BEQ loc_02B1B5
    CMP #$05
    BEQ loc_02B1B7
    JSR $&tile_collision.ProbeFutureTL
    CMP #$0A
    BEQ loc_02B1B8
    CMP #$05
    BEQ loc_02B1BA
    JSR $&tile_collision.ProbeFutureBL
    CMP #$0A
    BEQ loc_02B1B8
    CMP #$05
    BEQ loc_02B1BA
    RTS 

  loc_02B1B5:
    CLC 
    RTS 

  loc_02B1B7:
    RTS 

  loc_02B1B8:
    CLC 
    RTS 

  loc_02B1BA:
    RTS 
}

ProbeLeftTiles {
    JSR $&tile_collision.ProbeCurrentTR
    REP #$20
    LDA $1A
    SEC 
    SBC #$0008
    STA $1A
    SEP #$20
    JSR $&tile_collision.TileProbeMain
    CMP #$0A
    BEQ loc_02B209
    CMP #$05
    BEQ loc_02B208
    CMP #$06
    BNE loc_02B1E3
    JSR $&tile_collision.MapCellLeft
    JSR $&tile_collision.ReadCollisionNibble
    CMP #$05
    BEQ loc_02B208

  loc_02B1E3:
    JSR $&tile_collision.MapCellRight
    JSR $&tile_collision.ReadCollisionNibble
    CMP #$0A
    BEQ loc_02B209
    CMP #$05
    BEQ loc_02B208
    JSR $&tile_collision.ProbeFutureTR
    CMP #$0A
    BEQ loc_02B20C
    CMP #$05
    BEQ loc_02B20B
    JSR $&tile_collision.ProbeFutureBR
    CMP #$0A
    BEQ loc_02B20C
    CMP #$05
    BEQ loc_02B20B
    RTS 

  loc_02B208:
    RTS 

  loc_02B209:
    CLC 
    RTS 

  loc_02B20B:
    RTS 

  loc_02B20C:
    CLC 
    RTS 
}