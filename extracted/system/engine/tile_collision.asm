?BANK 02

?INCLUDE 'tile_collision_physics'

!mapRowStrideL0                 0693
!cameraOffsetX                  06D6
!cameraOffsetY                  06D8
!cameraBoundsX                  06DA
!cameraLowerYBound              06DE
!collisionLayer                 7FC000

---------------------------------------------

CombinedProbe_Unused {
    CLC 
    ADC $26
    LSR 
    LSR 
    DEC 
    STA $1E
    AND #$000F
    PHP 
    LDA $22
    CLC 
    ADC $20
    LSR 
    LSR 
    CLC 
    ADC $1A
    STA $1A
    JSR $&TileProbeMain
    AND #$00FF
    CMP #$000E
    BCC loc_02E128
    PLP 

  loc_02E126:
    SEC 
    RTS 

  loc_02E128:
    PLP 
    BEQ loc_02E13D
    SEP #$20
    JSR $&MapCellLeft
    JSR $&ReadCollisionNibble
    REP #$20
    AND #$00FF
    CMP #$000E
    BCS loc_02E126

  loc_02E13D:
    CLC 
    RTS 
}

CheckTileBoundaryXor {
    LDA $22
    LSR 
    LSR 
    PHA 
    LDA $20
    LSR 
    LSR 
    CLC 
    ADC $01, S
    EOR $01, S
    STA $01, S
    PLA 
    BIT #$0010
    RTS 
}

ClearMovementDeltas {
    REP #$20
    STZ $24
    STZ $20
    RTS 
}

SetActorCollisionFlag {
    PHP 
    REP #$20
    PHY 
    LDY $000A
    LDA $0010, Y
    ORA #$0004
    STA $0010, Y
    PLY 
    PLP 
    RTS 
}

ApplyMovementDeltas {
    REP #$20
    LDA $22
    CLC 
    ADC $20
    STA $22
    LDA $26
    CLC 
    ADC $24
    STA $26
    STZ $20
    STZ $24
    RTS 
}

ProbeCurrentBR {
    PHP 
    REP #$20
    LDA $22
    LSR 
    LSR 
    CLC 
    ADC #$0007
    STA $1A
    LDA $26
    LSR 
    LSR 
    CLC 
    ADC #$FFFF
    STA $1E
    JSR $&TileProbeMain
    INC $1A
    INC $1E
    BCC loc_02E1A6
    PLP 
    SEC 
    RTS 

  loc_02E1A6:
    PLP 
    CLC 
    RTS 
}

ProbeCurrentTR {
    PHP 
    REP #$20
    LDA $22
    LSR 
    LSR 
    CLC 
    ADC #$0007
    STA $1A
    LDA $26
    LSR 
    LSR 
    CLC 
    ADC #$FFF0
    STA $1E
    JSR $&TileProbeMain
    INC $1A
    BCC loc_02E1CA
    PLP 
    SEC 
    RTS 

  loc_02E1CA:
    PLP 
    CLC 
    RTS 
}

ProbeCurrentBL {
    PHP 
    REP #$20
    LDA $22
    LSR 
    LSR 
    CLC 
    ADC #$FFF8
    STA $1A
    LDA $26
    LSR 
    LSR 
    CLC 
    ADC #$FFFF
    STA $1E
    JSR $&TileProbeMain
    INC $1E
    BCC loc_02E1EE
    PLP 
    SEC 
    RTS 

  loc_02E1EE:
    PLP 
    CLC 
    RTS 
}

ProbeCurrentTL {
    PHP 
    REP #$20
    LDA $22
    LSR 
    LSR 
    CLC 
    ADC #$FFF8
    STA $1A
    LDA $26
    LSR 
    LSR 
    CLC 
    ADC #$FFF0
    STA $1E
    PLP 
    JSR $&TileProbeMain
    RTS 
}

ProbeFutureTR {
    PHP 
    REP #$20
    LDA $20
    CLC 
    ADC $22
    LSR 
    LSR 
    CLC 
    ADC #$0007
    STA $1A
    LDA $26
    CLC 
    ADC $24
    LSR 
    LSR 
    CLC 
    ADC #$FFF0
    STA $1E
    JSR $&TileProbeMain
    INC $1A
    BCC loc_02E234
    PLP 
    SEC 
    RTS 

  loc_02E234:
    PLP 
    CLC 
    RTS 
}

ProbeFutureBR {
    PHP 
    REP #$20
    LDA $20
    CLC 
    ADC $22
    LSR 
    LSR 
    CLC 
    ADC #$0007
    STA $1A
    LDA $26
    CLC 
    ADC $24
    LSR 
    LSR 
    CLC 
    ADC #$FFFF
    STA $1E
    JSR $&TileProbeMain
    INC $1A
    INC $1E
    BCC loc_02E260
    PLP 
    SEC 
    RTS 

  loc_02E260:
    PLP 
    CLC 
    RTS 
}

ProbeFutureTL {
    PHP 
    REP #$20
    LDA $20
    CLC 
    ADC $22
    LSR 
    LSR 
    CLC 
    ADC #$FFF8
    STA $1A
    LDA $26
    CLC 
    ADC $24
    LSR 
    LSR 
    CLC 
    ADC #$FFF0
    STA $1E
    PLP 
    JSR $&TileProbeMain
    RTS 
}

ProbeFutureBL {
    PHP 
    REP #$20
    LDA $20
    CLC 
    ADC $22
    LSR 
    LSR 
    CLC 
    ADC #$FFF8
    STA $1A
    LDA $26
    CLC 
    ADC $24
    LSR 
    LSR 
    CLC 
    ADC #$FFFF
    STA $1E
    JSR $&TileProbeMain
    INC $1E
    BCC loc_02E2AC
    PLP 
    SEC 
    RTS 

  loc_02E2AC:
    PLP 
    CLC 
    RTS 
}

TileProbeMain {
    PHP 
    REP #$20
    LDA $1A
    BMI loc_02E2F0
    CMP $cameraOffsetX
    BCC loc_02E2F0
    CMP $cameraBoundsX
    BCS loc_02E2F0
    LSR 
    LSR 
    LSR 
    LSR 
    STA $18
    LDA $1E
    BMI loc_02E2F0
    CMP $cameraOffsetY
    BCC loc_02E2F0
    CMP $cameraLowerYBound
    BCS loc_02E2F0
    LSR 
    LSR 
    LSR 
    LSR 
    STA $1C
    PHY 
    JSL $@tile_collision_physics.CalcTileMapOffset
    STY $00
    TYX 
    PLY 
    SEP #$20
    JSR $&ReadCollisionNibble
    BNE loc_02E2ED
    PLP 
    CLC 
    RTS 

  loc_02E2ED:
    PLP 
    SEC 
    RTS 

  loc_02E2F0:
    SEP #$20
    LDX #$4001
    STX $00
    LDA #$0F
    PLP 
    SEC 
    RTS 
}

ReadCollisionNibble {
    CPX #$4000
    BCS loc_02E310
    LDA $collisionLayer, X
    BIT #$F0
    BEQ loc_02E30D
    LSR 
    LSR 
    LSR 
    LSR 

  loc_02E30D:
    BIT #$FF
    RTS 

  loc_02E310:
    LDA #$0F
    RTS 
}

MapCellRight {
    PHP 
    REP #$20
    LDA $00
    SEP #$20
    CLC 
    ADC #$10
    BCS loc_02E322
    TAX 
    PLP 
    RTS 

  loc_02E322:
    XBA 
    CLC 
    ADC $mapRowStrideL0
    XBA 
    TAX 
    PLP 
    RTS 
}

MapCellLeft {
    PHP 
    REP #$20
    LDA $00
    SEP #$20
    SEC 
    SBC #$10
    BCC loc_02E33A
    TAX 
    PLP 
    RTS 

  loc_02E33A:
    XBA 
    SEC 
    SBC $mapRowStrideL0
    XBA 
    TAX 
    PLP 
    RTS 
}

MapCellDown {
    PHP 
    REP #$20
    LDA $00
    SEP #$20
    INC 
    BIT #$0F
    BEQ loc_02E352
    TAX 
    PLP 
    RTS 

  loc_02E352:
    XBA 
    LDA $01
    INC 
    XBA 
    CLC 
    ADC #$F0
    TAX 
    PLP 
    RTS 
}

MapCellUp {
    PHP 
    REP #$20
    LDA $00
    SEP #$20
    DEC 
    PHA 
    AND #$0F
    CMP #$0F
    BEQ loc_02E370
    PLA 
    TAX 
    PLP 
    RTS 

  loc_02E370:
    PLA 
    XBA 
    LDA $01
    DEC 
    XBA 
    SEC 
    SBC #$F0
    TAX 
    PLP 
    RTS 
}

CheckSubTileAlignX {
    PHA 
    LDA $1A
    BIT #$0F
    BNE loc_02E386
    PLA 
    CLC 
    RTS 

  loc_02E386:
    PLA 
    SEC 
    RTS 
}

CheckSubTileAlignY {
    PHA 
    LDA $1E
    BIT #$0F
    BNE loc_02E393
    PLA 
    CLC 
    RTS 

  loc_02E393:
    PLA 
    SEC 
    RTS 
}