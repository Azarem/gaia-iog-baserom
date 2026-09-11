?BANK 03

?INCLUDE 'actor_execution'
?INCLUDE 'hardware_math'
?INCLUDE 'scene_thinkers'

!deathFlag                      0200
!mapRowStrideL0                 0693
!cameraOffsetX                  06D6
!cameraOffsetY                  06D8
!cameraBoundsX                  06DA
!cameraLowerYBound              06DE
!animScratch                    7F0000
!metaspritePtr                  7F000C
!animScratch2                   7F000E
!extendedFlags                  7F002A
!moveScratch1                   7F002C
!moveScratch2                   7F002E

---------------------------------------------

ApplyMovement {
    LDA $2C
    BEQ loc_03D214
    TAY 
    LDA $0002, Y
    STA $2C
    LDA $12
    BIT #$4000
    BEQ loc_03D20F
    LDA $0000, Y
    EOR #$FFFF
    INC 
    BRA loc_03D229

  loc_03D20F:
    LDA $0000, Y
    BRA loc_03D229

  loc_03D214:
    LDA $12
    BIT #$4000
    BEQ loc_03D225
    LDA $moveScratch1, X
    EOR #$FFFF
    INC 
    BRA loc_03D229

  loc_03D225:
    LDA $moveScratch1, X

  loc_03D229:
    CLC 
    ADC $14
    STA $14
    LDA #$0000
    STA $moveScratch1, X
    LDA $2E
    BEQ loc_03D254
    TAY 
    LDA $0002, Y
    STA $2E
    LDA $12
    BIT #$2000
    BEQ loc_03D24F
    LDA $0000, Y
    EOR #$FFFF
    INC 
    BRA loc_03D269

  loc_03D24F:
    LDA $0000, Y
    BRA loc_03D269

  loc_03D254:
    LDA $12
    BIT #$2000
    BEQ loc_03D265
    LDA $moveScratch2, X
    EOR #$FFFF
    INC 
    BRA loc_03D269

  loc_03D265:
    LDA $moveScratch2, X

  loc_03D269:
    CLC 
    ADC $16
    STA $16
    LDA #$0000
    STA $moveScratch2, X
    RTS 
}

ApplyMovementWithCollision {
    LDA $cameraLowerYBound
    SEC 
    SBC #$0010
    STA $0004
    LDA $2C
    BEQ loc_03D291
    TAY 
    LDA $0000, Y
    BNE loc_03D297
    LDA $0002, Y
    STA $2C
    BRA loc_03D2FD

  loc_03D291:
    LDA $moveScratch1, X
    BEQ loc_03D2FD

  loc_03D297:
    STA $001A
    LDA $12
    BIT #$4000
    BEQ loc_03D2AB
    LDA $001A
    EOR #$FFFF
    INC 
    STA $001A

  loc_03D2AB:
    LDA $001A
    PEA $&CollisionX_PostMove-1
    BPL loc_03D2B6
    JMP $&TileCollision_MoveLeft

  loc_03D2B6:
    JMP $&TileCollision_MoveRight
}

CollisionX_PostMove {
    LDA $2C
    BEQ loc_03D2DA
    TAY 
    LDA $0002, Y
    STA $2C
    BCS loc_03D2FD
    LDA $12
    BIT #$4000
    BEQ loc_03D2D5
    LDA $0000, Y
    EOR #$FFFF
    INC 
    BRA loc_03D2F1

  loc_03D2D5:
    LDA $0000, Y
    BRA loc_03D2F1

  loc_03D2DA:
    BCS loc_03D2F6
    LDA $12
    BIT #$4000
    BEQ loc_03D2ED
    LDA $moveScratch1, X
    EOR #$FFFF
    INC 
    BRA loc_03D2F1

  loc_03D2ED:
    LDA $moveScratch1, X

  loc_03D2F1:
    CLC 
    ADC $14
    STA $14

  loc_03D2F6:
    LDA #$0000
    STA $moveScratch1, X

  loc_03D2FD:
    CLC 
    LDA $2E
    BEQ loc_03D30F
    TAY 
    LDA $0000, Y
    BNE loc_03D315
    LDA $0002, Y
    STA $2E
    BRA loc_03D37B

  loc_03D30F:
    LDA $moveScratch2, X
    BEQ loc_03D37B

  loc_03D315:
    STA $001E
    LDA $12
    BIT #$2000
    BEQ loc_03D329
    LDA $001E
    EOR #$FFFF
    INC 
    STA $001E

  loc_03D329:
    LDA $001E
    PEA $&CollisionY_Setup-1
    BPL loc_03D334
    JMP $&TileCollision_MoveUp

  loc_03D334:
    JMP $&TileCollision_MoveDown
}

CollisionY_Setup {
    LDA $2E
    BEQ loc_03D358
    TAY 
    LDA $0002, Y
    STA $2E
    BCS loc_03D37B
    LDA $12
    BIT #$2000
    BEQ loc_03D353
    LDA $0000, Y
    EOR #$FFFF
    INC 
    BRA loc_03D36F

  loc_03D353:
    LDA $0000, Y
    BRA loc_03D36F

  loc_03D358:
    BCS loc_03D374
    LDA $12
    BIT #$2000
    BEQ loc_03D36B
    LDA $moveScratch2, X
    EOR #$FFFF
    INC 
    BRA loc_03D36F

  loc_03D36B:
    LDA $moveScratch2, X

  loc_03D36F:
    CLC 
    ADC $16
    STA $16

  loc_03D374:
    LDA #$0000
    STA $moveScratch2, X

  loc_03D37B:
    LDA $10
    BIT #$0004
    BNE loc_03D383
    RTS 

  loc_03D383:
    LDA $extendedFlags, X
    BIT #$0040
    BNE loc_03D38D
    RTS 

  loc_03D38D:
    AND #$FFBF
    STA $extendedFlags, X
    LDA $12
    EOR #$6000
    STA $12
    RTS 
}

TileCollision_MoveLeft {
    PHB 
    CLC 
    ADC $14
    STA $0018
    LDA #$0000
    TCD 
    JSR $&CheckActorOnSpecialTile
    BCC loc_03D3B0
    PLB 
    TXA 
    TCD 
    RTS 

  loc_03D3B0:
    LDA $metaspritePtr, X
    TAY 
    SEP #$20
    LDA $7F0008, X
    PHA 
    PLB 
    REP #$20
    LDA $0003, Y
    AND #$00FF
    STA $0E
    LDA $0000, Y
    ORA #$FF00
    CLC 
    ADC $18
    BMI loc_03D419
    CMP $cameraOffsetX
    BCC loc_03D419
    CMP $cameraBoundsX
    BCS loc_03D419
    LSR 
    LSR 
    LSR 
    LSR 
    STA $18
    LDA $0001, Y
    ORA #$FF00
    CLC 
    ADC $0016, X
    PHA 
    LSR 
    LSR 
    LSR 
    LSR 
    STA $1C
    JSL $@CalcTileMapOffset
    STY $00

  loc_03D3F9:
    LDA [$80], Y
    BIT #$00F0
    BEQ loc_03D403
    JMP $&TileCollision_BlockH

  loc_03D403:
    AND #$000F
    BNE loc_03D413
    DEC $0E
    BEQ loc_03D413
    JSR $&AdvanceTileOffsetRight
    STY $00
    BRA loc_03D3F9

  loc_03D413:
    ASL 
    TXY 
    TAX 
    JMP ($&TileTypeJumpTable_Horizontal, X)

  loc_03D419:
    PHA 
    LDA #$000F
    BRA loc_03D413
}

TileCollision_MoveRight {
    PHB 
    CLC 
    ADC $14
    STA $0018
    LDA #$0000
    TCD 
    JSR $&CheckActorOnSpecialTile
    BCC loc_03D433
    PLB 
    TXA 
    TCD 
    RTS 

  loc_03D433:
    LDA $metaspritePtr, X
    TAY 
    SEP #$20
    LDA $7F0008, X
    PHA 
    PLB 
    REP #$20
    LDA $0003, Y
    AND #$00FF
    STA $0E
    LDA $0000, Y
    ORA #$FF00
    CLC 
    ADC $18
    DEC 
    BMI loc_03D419
    CMP $cameraOffsetX
    BCC loc_03D419
    CLC 
    ADC #$0010
    CMP $cameraBoundsX
    BCS loc_03D419
    SEC 
    SBC #$0010
    LSR 
    LSR 
    LSR 
    LSR 
    STA $18
    LDA $0002, Y
    AND #$00FF
    CLC 
    ADC $18
    STA $18
    LDA $0001, Y
    ORA #$FF00
    CLC 
    ADC $0016, X
    PHA 
    LSR 
    LSR 
    LSR 
    LSR 
    STA $1C
    JSL $@CalcTileMapOffset
    STY $00

  loc_03D490:
    LDA [$80], Y
    BIT #$00F0
    BNE TileCollision_BlockH
    AND #$000F
    BNE loc_03D4A7
    DEC $0E
    BEQ loc_03D4A7
    JSR $&AdvanceTileOffsetRight
    STY $00
    BRA loc_03D490

  loc_03D4A7:
    ASL 
    TXY 
    TAX 
    JMP ($&TileTypeJumpTable_Horizontal, X)
}

TileTypeJumpTable_Horizontal [
  &TileCollision_CheckAdjacentH   ;00
  &TileCollision_SolidH   ;01
  &TileCollision_SolidH   ;02
  &TileCollision_SolidH   ;03
  &TileCollision_SolidH   ;04
  &TileCollision_SolidH   ;05
  &TileCollision_SolidH   ;06
  &TileCollision_SolidH   ;07
  &TileCollision_SolidH   ;08
  &TileCollision_SolidH   ;09
  &TileCollision_SolidH   ;0A
  &TileCollision_SolidH   ;0B
  &TileCollision_SolidH   ;0C
  &TileCollision_SolidH   ;0D
  &TileCollision_SolidH   ;0E
  &TileCollision_SolidH   ;0F
]

TileCollision_SolidH {
    TYX 
}

TileCollision_BlockH {
    TXA 
    TCD 
    LDA #$0004
    TSB $10
    LDA $001A
    BMI loc_03D506
    LDA $metaspritePtr, X
    TAY 
    LDA $0000, Y
    ORA #$FF00
    CLC 
    ADC $14
    CLC 
    ADC $001A
    AND #$FFF0
    STA $001A
    LDA $0000, Y
    ORA #$FF00
    EOR #$FFFF
    INC 
    CLC 
    ADC $001A
    STA $14
    PLA 
    PLB 
    SEC 
    RTS 

  loc_03D506:
    LDA $metaspritePtr, X
    TAY 
    LDA $0000, Y
    ORA #$FF00
    CLC 
    ADC $14
    CLC 
    ADC $001A
    BIT #$000F
    BEQ loc_03D524
    AND #$FFF0
    CLC 
    ADC #$0010

  loc_03D524:
    STA $001A
    LDA $0000, Y
    ORA #$FF00
    EOR #$FFFF
    INC 
    CLC 
    ADC $001A
    STA $14
    PLA 
    PLB 
    SEC 
    RTS 
}

TileCollision_PassH {
    TXA 
    TCD 
    PLA 
    PLB 
    CLC 
    RTS 
}

TileCollision_CheckAdjacentH {
    TYX 
    LDA $01, S
    BIT #$000F
    BEQ TileCollision_PassH
    JSR $&AdvanceTileOffsetRight
    LDA [$80], Y
    AND #$00FF
    BEQ TileCollision_PassH
    JMP $&TileCollision_BlockH
}

TileCollision_MoveUp {
    PHB 
    CLC 
    ADC $16
    STA $001C
    LDA #$0000
    TCD 
    JSR $&CheckActorOnSpecialTile
    BCC loc_03D56A
    PLB 
    TXA 
    TCD 
    RTS 

  loc_03D56A:
    LDA $metaspritePtr, X
    TAY 
    SEP #$20
    LDA $7F0008, X
    PHA 
    PLB 
    REP #$20
    LDA $0002, Y
    AND #$00FF
    STA $0E
    LDA $0000, Y
    ORA #$FF00
    CLC 
    ADC $0014, X
    PHA 
    LSR 
    LSR 
    LSR 
    LSR 
    STA $18
    LDA $0001, Y
    ORA #$FF00
    CLC 
    ADC $1C
    BMI loc_03D5D2
    CMP $cameraOffsetY
    BCC loc_03D5D2
    CMP $04
    BCS loc_03D5D2
    LSR 
    LSR 
    LSR 
    LSR 
    STA $1C
    JSL $@CalcTileMapOffset
    STY $00

  loc_03D5B2:
    LDA [$80], Y
    BIT #$00F0
    BEQ loc_03D5BC
    JMP $&TileCollision_BlockV

  loc_03D5BC:
    AND #$000F
    BNE loc_03D5CC
    DEC $0E
    BEQ loc_03D5CC
    JSR $&AdvanceTileOffsetDown
    STY $00
    BRA loc_03D5B2

  loc_03D5CC:
    ASL 
    TXY 
    TAX 
    JMP ($&TileTypeJumpTable_Vertical, X)

  loc_03D5D2:
    LDA #$000F
    BRA loc_03D5CC
}

TileCollision_MoveDown {
    PHB 
    CLC 
    ADC $16
    STA $001C
    LDA #$0000
    TCD 
    JSR $&CheckActorOnSpecialTile
    BCC loc_03D5EB
    PLB 
    TXA 
    TCD 
    RTS 

  loc_03D5EB:
    LDA $metaspritePtr, X
    TAY 
    SEP #$20
    LDA $7F0008, X
    PHA 
    PLB 
    REP #$20
    LDA $0002, Y
    AND #$00FF
    STA $0E
    LDA $0000, Y
    ORA #$FF00
    CLC 
    ADC $0014, X
    PHA 
    LSR 
    LSR 
    LSR 
    LSR 
    STA $18
    LDA $0001, Y
    ORA #$FF00
    CLC 
    ADC $1C
    BMI loc_03D5D2
    CMP $cameraOffsetY
    BCC loc_03D5D2
    CMP $04
    BCS loc_03D5D2
    DEC 
    LSR 
    LSR 
    LSR 
    LSR 
    STA $1C
    LDA $0003, Y
    AND #$00FF
    CLC 
    ADC $1C
    STA $1C
    JSL $@CalcTileMapOffset
    STY $00

  loc_03D63F:
    LDA [$80], Y
    BIT #$00F0
    BNE TileCollision_BlockV
    AND #$000F
    BNE loc_03D656
    DEC $0E
    BEQ loc_03D656
    JSR $&AdvanceTileOffsetDown
    STY $00
    BRA loc_03D63F

  loc_03D656:
    ASL 
    TXY 
    TAX 
    JMP ($&TileTypeJumpTable_Vertical, X)
}

TileTypeJumpTable_Vertical [
  &TileCollision_CheckAdjacentV   ;00
  &TileCollision_SolidV   ;01
  &TileCollision_SolidV   ;02
  &TileCollision_SolidV   ;03
  &TileCollision_SolidV   ;04
  &TileCollision_SolidV   ;05
  &TileCollision_SolidV   ;06
  &TileCollision_SolidV   ;07
  &TileCollision_SolidV   ;08
  &TileCollision_SolidV   ;09
  &TileCollision_SolidV   ;0A
  &TileCollision_SolidV   ;0B
  &TileCollision_SolidV   ;0C
  &TileCollision_SolidV   ;0D
  &TileCollision_SolidV   ;0E
  &TileCollision_SolidV   ;0F
]

TileCollision_BlockV {
    TXA 
    TCD 
    LDA #$0004
    TSB $10
    LDA $001E
    BMI loc_03D6B4
    LDA $metaspritePtr, X
    TAY 
    LDA $0001, Y
    ORA #$FF00
    CLC 
    ADC $16
    CLC 
    ADC $001E
    AND #$FFF0
    STA $001E
    LDA $0001, Y
    ORA #$FF00
    EOR #$FFFF
    INC 
    CLC 
    ADC $001E
    STA $16
    PLA 
    PLB 
    SEC 
    RTS 

  loc_03D6B4:
    LDA $metaspritePtr, X
    TAY 
    LDA $0001, Y
    ORA #$FF00
    CLC 
    ADC $16
    CLC 
    ADC $001E
    BIT #$000F
    BEQ loc_03D6D2
    AND #$FFF0
    CLC 
    ADC #$0010

  loc_03D6D2:
    STA $001E
    LDA $0001, Y
    ORA #$FF00
    EOR #$FFFF
    INC 
    CLC 
    ADC $001E
    STA $16
    PLA 
    PLB 
    SEC 
    RTS 
}

TileCollision_PassV {
    TXA 
    TCD 
    PLA 
    PLB 
    CLC 
    RTS 
}

TileCollision_CheckAdjacentV {
    TYX 
    LDA $01, S
    BIT #$000F
    BEQ TileCollision_PassV
    JSR $&AdvanceTileOffsetDown
    LDA [$80], Y
    AND #$00FF
    BEQ TileCollision_PassV
    JMP $&TileCollision_BlockV
}

TileCollision_SolidV {
    TYX 
    JMP $&TileCollision_BlockV
}

CheckActorOnSpecialTile {
    LDA $18
    PHA 
    LDA $1C
    PHA 
    LDA $0014, X
    SEC 
    SBC #$0008
    BIT #$000F
    BEQ loc_03D782
    LSR 
    LSR 
    LSR 
    LSR 
    STA $18
    LDA $0016, X
    SEC 
    SBC #$0010
    BIT #$000F
    BEQ loc_03D782
    LSR 
    LSR 
    LSR 
    LSR 
    STA $1C
    JSL $@CalcTileMapOffset
    STY $00
    LDA [$80], Y
    AND #$00FF
    BEQ loc_03D758
    CMP #$0006
    BNE loc_03D782
    JSR $&AdvanceTileOffsetRight
    STY $00
    JSR $&AdvanceTileOffsetDown
    LDA [$80], Y
    AND #$00FF
    CMP #$0006
    BNE loc_03D782
    BRA loc_03D77A

  loc_03D758:
    LDA $00
    STA $02
    JSR $&AdvanceTileOffsetDown
    LDA [$80], Y
    AND #$00FF
    CMP #$0009
    BNE loc_03D782
    LDA $02
    STA $00
    JSR $&AdvanceTileOffsetRight
    LDA [$80], Y
    AND #$00FF
    CMP #$0009
    BNE loc_03D782

  loc_03D77A:
    PLA 
    STA $1C
    PLA 
    STA $18
    SEC 
    RTS 

  loc_03D782:
    PLA 
    STA $1C
    PLA 
    STA $18
    CLC 
    RTS 
}

CalcTileMapOffset {
    PHP 
    LDA $1C
    ASL 
    ASL 
    ASL 
    ASL 
    PHA 
    SEP #$20
    LDA $mapRowStrideL0
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
    PLY 
    PLP 
    RTL 
}

AdvanceTileOffsetRight {
    PHP 
    LDA $00
    SEP #$20
    CLC 
    ADC #$10
    BCS loc_03D7C1
    TAY 
    PLP 
    RTS 

  loc_03D7C1:
    XBA 
    CLC 
    ADC $mapRowStrideL0
    XBA 
    TAY 
    PLP 
    RTS 
}

AdvanceTileOffsetDown {
    PHP 
    SEP #$20
    LDA $00
    INC 
    BIT #$0F
    BEQ loc_03D7DC
    STA $00
    REP #$20
    LDY $00
    PLP 
    RTS 

  loc_03D7DC:
    XBA 
    LDA $01
    INC 
    XBA 
    CLC 
    ADC #$F0
    TAY 
    PLP 
    RTS 
}

SpawnSceneThinkers {
    PHP 
    REP #$20
    STZ $005A
    STZ $005C
    LDX $0646
    LDA $@scene_thinkers, X
    BEQ loc_03D82F
    STA $3E
    LDA #$008C
    STA $40
    LDA [$3E]
    BIT #$0080
    BNE loc_03D82F
    JSL $@actor_execution.ThinkerPoolAlloc
    STY $005A
    BRA loc_03D826

  loc_03D810:
    LDA [$3E]
    AND #$00FF
    CMP #$00FF
    BEQ loc_03D82C
    JSL $@actor_execution.ThinkerPoolAlloc
    TYA 
    STA $0006, X
    TXA 
    STA $0004, Y

  loc_03D826:
    TYX 
    JSR $&InitThinkerFromSceneData
    BRA loc_03D810

  loc_03D82C:
    STX $005C

  loc_03D82F:
    PLP 
    RTL 
}

InitThinkerFromSceneData {
    LDY #$0000
    LDA [$3E], Y
    INY 
    AND #$00FF
    STA $animScratch+2, X
    LDA [$3E], Y
    INY 
    INY 
    STA $42
    LDA [$3E], Y
    INY 
    AND #$00FF
    STA $44
    TYA 
    CLC 
    ADC $3E
    STA $3E
    LDY #$0000
    LDA [$42], Y
    INY 
    INY 
    STA $animScratch2, X
    TYA 
    CLC 
    ADC $42
    STA $0000, X
    LDA $44
    STA $0002, X
    RTS 
}

ClearActorRenderList {
    PHP 
    REP #$20
    LDX #$0000
    TXA 

  loc_03D871:
    STA $deathFlag, X
    INX 
    INX 
    CPX #$0200
    BNE loc_03D871
    DEC 
    STA $deathFlag, X
    PLP 
    RTL 
}