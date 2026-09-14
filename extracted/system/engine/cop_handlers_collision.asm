?BANK 00

?INCLUDE 'ApplyOrbitalOffsetFromRef'
?INCLUDE 'cop_handlers_actors'
?INCLUDE 'cop_handlers_script'
?INCLUDE 'func_0AA3A7'
?INCLUDE 'GetPlayerFacingDirection'
?INCLUDE 'hardware_math'
?INCLUDE 'hdma_dma_spc'
?INCLUDE 'hdma_ramp_tables'
?INCLUDE 'map_coords'
?INCLUDE 'math_lookup_tables'
?INCLUDE 'QuintetLzDecompress'
?INCLUDE 'sprite_composition'
?INCLUDE 'tile_collision_physics'

!rngState                       040F
!rngModuloResult                0420
!sceneNext                      0642
!bg1ScrollH                     068A
!bg2ScrollH                     068E
!mapBoundsX                     0692
!mapRowStrideL0                 0693
!cameraTargetX                  06BE
!cameraTargetY                  06C2
!cameraOffsetX                  06D6
!cameraOffsetY                  06D8
!cameraBoundsX                  06DA
!cameraBoundsY                  06DC
!cameraLowerYBound              06DE
!scrollStepTableBase            06E0
!scrollStepIndex                06E2
!sfxQueueCh2                    06F9
!tileQueryResult                0902
!playerActor                    09AA
!displayModeFlags               09EC
!sceneSaveData                  0AF0
!WRMPYA                         4202
!WRMPYB                         4203
!WRDIVL                         4204
!WRDIVB                         4206
!RDDIVL                         4214
!RDMPYL                         4216
!RDMPYH                         4217
!DMAP0                          4300
!BBAD0                          4301
!A1T0L                          4302
!A1B0                           4304
!DASB0                          4307
!metatileMapLayer               7E2000
!sineTableA                     7E8900
!sineTableB                     7E8B00
!mapLayerTilemap                7EA000
!animScratch                    7F0000
!retPtr1                        7F0004
!spritesetPtr                   7F0006
!chatPtr                        7F000A
!metaspritePtr                  7F000C
!animScratch2                   7F000E
!orbitAngle                     7F0010
!orbitDiameter                  7F0012
!moveXAlt                       7F0018
!moveYAlt                       7F001A
!extendedFlags                  7F002A
!moveScratch1                   7F002C
!moveScratch2                   7F002E
!adhocVramDma                   7F0C03
!scratch1010                    7F1010
!snapResumePtr                  7F1018
!collisionLayer                 7FC000
!L_WRMPYB                       804203
!L_WRDIVL                       804204
!L_WRDIVB                       804206
!L_RDDIVL                       804214
!L_RDMPYL                       804216
!L_RDMPYH                       804217

---------------------------------------------

GenHdmaSine {
    TYX 
    PHP 
    JSR $&BuildSineLookupTable
    LDA $spritesetPtr, X
    INC 
    STA $spritesetPtr, X
    AND #$01FE
    CLC 
    ADC #$8900
    STA $7E8801
    CLC 
    ADC #$00FE
    STA $7E8804
    SEP #$20
    LDA #$FF
    STA $7E8800
    LDA #$E0
    STA $7E8803
    LDA #$00
    STA $7E8806
    PLP 
    LDA $0A
    STA $02, S
    RTI 
}

QueueHdma {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    TAY 
    LDA [$0A]
    INC $0A
    INC $0A
    JSL $@hdma_dma_spc.SetupHdmaChannel_Indirect
    LDA $0A
    STA $02, S
    RTI 
}

QueueDma {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    TAY 
    LDA [$0A]
    INC $0A
    INC $0A
    JSL $@hdma_dma_spc.SetupHdmaChannel_Direct
    LDA $0A
    STA $02, S
    RTI 
}

QueueHdmaChannel {
    PHY 
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0002
    ASL 
    ASL 
    ASL 
    ASL 
    STA $0000
    LDX $0002
    SEP #$20
    LDA $@cop_handlers_script.bitmasks_bit_position, X
    TSB $0066
    REP #$20
    LDA [$0A]
    INC $0A
    INC $0A
    TAY 
    LDA [$0A]
    INC $0A
    INC $0A
    PHP 
    SEP #$20
    PHA 
    LDA #$00
    XBA 
    PHA 
    TAX 
    LDA $&hdma_ramp_tables.hdma_channel_config, X
    LDX $0000
    ORA #$40
    STA $DMAP0, X
    LDA $02, S
    STA $DASB0, X
    PLA 
    STA $BBAD0, X
    REP #$20
    TYA 
    STA $A1T0L, X
    SEP #$20
    PLA 
    STA $A1B0, X
    PLP 
    PLX 
    LDA $0A
    STA $02, S
    RTI 
}
---------------------------------------------

MarkSolidHere {
    TYX 
    LDA $14
    STA $0018
    LDA $16
    STA $001C
    STZ $0000
    JSR $&MarkCollisionRect
    LDA $0A
    STA $02, S
    RTI 
}

ClearSolidHere {
    TYX 
    LDA $14
    STA $0018
    LDA $16
    STA $001C
    STZ $0000
    JSR $&ClearCollisionRect
    LDA $0A
    STA $02, S
    RTI 
}

MarkSolidOffset {
    TYX 
    JSR $&ParseSignedTileOffset
    PHX 
    PHD 
    LDA #$0000
    TCD 
    LDX #$0000
    JSL $@map_coords.TileCoordsToMapIndex
    SEP #$20
    LDA $collisionLayer, X
    ORA #$F0
    STA $collisionLayer, X
    REP #$20
    PLD 
    PLX 
    LDA $0A
    STA $02, S
    RTI 
}

ClearSolidOffset {
    TYX 
    JSR $&ParseSignedTileOffset
    PHX 
    PHD 
    LDA #$0000
    TCD 
    LDX #$0000
    JSL $@map_coords.TileCoordsToMapIndex
    SEP #$20
    LDA $collisionLayer, X
    AND #$0F
    STA $collisionLayer, X
    REP #$20
    PLD 
    PLX 
    LDA $0A
    STA $02, S
    RTI 
}

MarkSolidAbs {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0018
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $001C
    PHX 
    PHD 
    LDA #$0000
    TCD 
    LDX #$0000
    JSL $@map_coords.TileCoordsToMapIndex
    SEP #$20
    LDA $collisionLayer, X
    ORA #$F0
    STA $collisionLayer, X
    REP #$20
    PLD 
    PLX 
    LDA $0A
    STA $02, S
    RTI 
}

ClearSolidAbs {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0018
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $001C
    PHX 
    PHD 
    LDA #$0000
    TCD 
    LDX #$0000
    JSL $@map_coords.TileCoordsToMapIndex
    SEP #$20
    LDA $collisionLayer, X
    AND #$0F
    STA $collisionLayer, X
    REP #$20
    PLD 
    PLX 
    LDA $0A
    STA $02, S
    RTI 
}

ClearCollisionHere {
    TYX 
    LDA $14
    STA $0018
    LDA $16
    STA $001C
    LDA #$0001
    STA $0000
    JSR $&ClearCollisionRect
    LDA $0A
    STA $02, S
    RTI 
}

ClearTypeAbs {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0018
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $001C
    PHX 
    PHD 
    LDA #$0000
    TCD 
    LDX #$0000
    JSL $@map_coords.TileCoordsToMapIndex
    SEP #$20
    LDA $collisionLayer, X
    AND #$F0
    STA $collisionLayer, X
    REP #$20
    PLD 
    PLX 
    LDA $0A
    STA $02, S
    RTI 
}

BranchIfSolidHere {
    TYX 
    LDA $14
    STA $0018
    LDA $16
    STA $001C
    JSR $&TileCollisionQuery
    BIT #$000F
    BNE loc_0089CA
    LDA [$0A]
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 

  loc_0089CA:
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

BranchIfSolidOffset {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_0089E3
    ORA #$FF00

  loc_0089E3:
    ASL 
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $14
    STA $0018
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_0089FC
    ORA #$FF00

  loc_0089FC:
    ASL 
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $16
    STA $001C
    JSR $&TileCollisionQuery
    BIT #$000F
    BNE loc_008A19
    LDA [$0A]
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 

  loc_008A19:
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

BranchIfSolidNorth {
    TYX 
    LDA $14
    STA $0018
    LDA $16
    SEC 
    SBC #$0010
    STA $001C
    JSR $&TileCollisionQuery
    BIT #$000F
    BNE loc_008A44
    LDA [$0A]
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 

  loc_008A44:
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

BranchIfSolidSouth {
    TYX 
    LDA $14
    STA $0018
    LDA $16
    CLC 
    ADC #$0010
    STA $001C
    JSR $&TileCollisionQuery
    BIT #$000F
    BNE loc_008A6F
    LDA [$0A]
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 

  loc_008A6F:
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

BranchIfSolidWest {
    TYX 
    LDA $14
    SEC 
    SBC #$0010
    STA $0018
    LDA $16
    STA $001C
    JSR $&TileCollisionQuery
    BIT #$000F
    BNE loc_008A9A
    LDA [$0A]
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 

  loc_008A9A:
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

BranchIfSolidEast {
    TYX 
    LDA $14
    CLC 
    ADC #$0010
    STA $0018
    LDA $16
    STA $001C
    JSR $&TileCollisionQuery
    BIT #$000F
    BNE loc_008AC5
    LDA [$0A]
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 

  loc_008AC5:
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

BranchIfTypeHere {
    TYX 
    LDA $14
    STA $0018
    LDA $16
    STA $001C
    JSR $&TileCollisionQuery
    AND #$00FF
    PHA 
    LDA [$0A]
    INC $0A
    AND #$00FF
    CMP $01, S
    BEQ loc_008AF7
    LDA [$0A]
    INC $0A
    INC $0A
    PLY 
    LDA $0A
    STA $02, S
    RTI 

  loc_008AF7:
    PLA 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

BranchIfTypeNorth {
    TYX 
    LDA $14
    STA $0018
    LDA $16
    SEC 
    SBC #$0010
    STA $001C
    JSR $&TileCollisionQuery
    AND #$00FF
    PHA 
    LDA [$0A]
    INC $0A
    AND #$00FF
    CMP $01, S
    BEQ loc_008B2E
    LDA [$0A]
    INC $0A
    INC $0A
    PLY 
    LDA $0A
    STA $02, S
    RTI 

  loc_008B2E:
    PLA 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

BranchIfTypeSouth {
    TYX 
    LDA $14
    STA $0018
    LDA $16
    CLC 
    ADC #$0010
    STA $001C
    JSR $&TileCollisionQuery
    AND #$00FF
    PHA 
    LDA [$0A]
    INC $0A
    AND #$00FF
    CMP $01, S
    BEQ loc_008B65
    LDA [$0A]
    INC $0A
    INC $0A
    PLY 
    LDA $0A
    STA $02, S
    RTI 

  loc_008B65:
    PLA 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

BranchIfTypeWest {
    TYX 
    LDA $14
    SEC 
    SBC #$0010
    STA $0018
    LDA $16
    STA $001C
    JSR $&TileCollisionQuery
    AND #$00FF
    PHA 
    LDA [$0A]
    INC $0A
    AND #$00FF
    CMP $01, S
    BEQ loc_008B9C
    LDA [$0A]
    INC $0A
    INC $0A
    PLY 
    LDA $0A
    STA $02, S
    RTI 

  loc_008B9C:
    PLA 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

BranchIfTypeEast {
    TYX 
    LDA $14
    CLC 
    ADC #$0010
    STA $0018
    LDA $16
    STA $001C
    JSR $&TileCollisionQuery
    AND #$00FF
    PHA 
    LDA [$0A]
    INC $0A
    AND #$00FF
    CMP $01, S
    BEQ loc_008BD3
    LDA [$0A]
    INC $0A
    INC $0A
    PLY 
    LDA $0A
    STA $02, S
    RTI 

  loc_008BD3:
    PLA 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

BranchIfNotOnGridline {
    TYX 
    PHB 
    LDA $16
    BIT #$000F
    BEQ loc_008BF0

  loc_008BE6:
    PLB 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 

  loc_008BF0:
    LDA $metaspritePtr, X
    TAY 
    SEP #$20
    LDA $7F0008, X
    PHA 
    PLB 
    REP #$20
    LDA $0000, Y
    ORA #$FF00
    CLC 
    ADC $14
    BIT #$000F
    BNE loc_008BE6
    PLB 
    LDA [$0A]
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 
}

BranchIfActorNear {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSR $&ResolveActorIndex
    BRA loc_008C2A
}

BranchIfPlayerNear {
    TYX 
    LDY $playerActor

  loc_008C2A:
    LDA [$0A]
    INC $0A
    AND #$00FF
    ASL 
    ASL 
    ASL 
    ASL 
    INC 
    STA $0000
    LDA $14
    SEC 
    SBC $0014, Y
    BPL loc_008C45
    EOR #$FFFF
    INC 

  loc_008C45:
    CMP $0000
    BCS loc_008C64
    LDA $16
    SEC 
    SBC $0016, Y
    BPL loc_008C56
    EOR #$FFFF
    INC 

  loc_008C56:
    CMP $0000
    BCS loc_008C64
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 

  loc_008C64:
    LDA [$0A]
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 
}

MoveToward {
    TYX 
    LDA $extendedFlags, X
    BIT #$0002
    BNE loc_008C7C
    JSR $&InitSmoothMovement

  loc_008C7C:
    LDA $animScratch2, X
    AND #$00FF
    CMP $24
    BNE loc_008C8A
    JMP $&code_008D11

  loc_008C8A:
    SEP #$20
    LDA $24
    STA $WRMPYA
    LDA $moveXAlt, X
    AND #$FF
    JSR $&MultiplyThenDivide
    SEC 
    SBC $animScratch, X
    BEQ loc_008CC3
    REP #$20
    AND #$00FF
    PHA 
    LDA $animScratch2, X
    ASL 
    BMI loc_008CB1
    PLA 
    BRA loc_008CB6

  loc_008CB1:
    PLA 
    EOR #$FFFF
    INC 

  loc_008CB6:
    STA $moveScratch1, X
    SEP #$20
    LDA $0000
    STA $animScratch, X

  loc_008CC3:
    LDA $moveYAlt, X
    AND #$FF
    JSR $&MultiplyThenDivide
    SEC 
    SBC $animScratch+1, X
    REP #$20
    BEQ loc_008CF7
    AND #$00FF
    PHA 
    LDA $animScratch2, X
    ASL 
    BCS loc_008CE3
    PLA 
    BRA loc_008CE8

  loc_008CE3:
    PLA 
    EOR #$FFFF
    INC 

  loc_008CE8:
    STA $moveScratch2, X
    SEP #$20
    LDA $0000
    STA $animScratch+1, X
    REP #$20

  loc_008CF7:
    INC $24
    LDA $animScratch+2, X
    DEC 
    BPL loc_008D08

  loc_008D00:
    JSL $@sprite_composition.UpdateActorAnimation
    BCS loc_008D00
    LDA $08

  loc_008D08:
    STZ $08
    STA $animScratch+2, X
    PLA 
    PLA 
    RTL 
}

code_008D11 {
    LDA $extendedFlags, X
    AND #$FFFD
    STA $extendedFlags, X
    LDA $0A
    INC 
    INC 
    STA $00
    PLA 
    PLA 
    RTL 
}

ReadMultiplyResult {
    NOP 
    LDY $RDMPYL
    RTS 
}

ReadDivideResult {
    NOP 
    NOP 
    NOP 
    NOP 
    NOP 
    LDA $RDDIVL
    RTS 
}

MultiplyThenDivide {
    STA $WRMPYB
    JSR $&ReadMultiplyResult
    STY $WRDIVL
    LDA $animScratch2, X
    DEC 
    STA $WRDIVB
    BEQ loc_008D49
    JSR $&ReadDivideResult

  loc_008D49:
    STA $0000
    RTS 
}

InitSmoothMovement {
    STZ $0004
    LDA $0A
    DEC 
    DEC 
    STA $00
    LDY #$0001
    LDA [$0A]
    AND #$00FF
    CMP #$00FF
    BNE loc_008D65
    LDA $28

  loc_008D65:
    JSR $&cop_handlers_actors.ProcessAnimFlag
    LDA $moveXAlt, X
    SEC 
    SBC $14
    CLC 
    BPL loc_008D77
    EOR #$FFFF
    INC 
    SEC 

  loc_008D77:
    ROR $0004
    BIT #$FF00
    BEQ loc_008D82
    LDA #$00FE

  loc_008D82:
    STA $moveXAlt, X
    LDA $moveYAlt, X
    SEC 
    SBC $16
    CLC 
    BPL loc_008D95
    EOR #$FFFF
    INC 
    SEC 

  loc_008D95:
    ROR $0004
    BIT #$FF00
    BEQ loc_008DA0
    LDA #$00FE

  loc_008DA0:
    STA $moveYAlt, X
    CMP $moveXAlt, X
    BCS loc_008DAE
    LDA $moveXAlt, X

  loc_008DAE:
    PHA 
    LDA [$0A], Y
    AND #$00FF
    PLY 
    SEP #$20
    JSL $@hardware_math.UnsignedDivide
    INC 
    STA $animScratch2, X
    LDA $0005
    STA $7F000F, X
    REP #$20
    LDA #$0000
    STA $animScratch, X
    STA $animScratch+2, X
    STA $24
    STZ $2C
    STZ $2E
    LDA $extendedFlags, X
    ORA #$0002
    STA $extendedFlags, X
    RTS 
}

SnapToGrid {
    TYX 
    STZ $2C
    STZ $2E
    LDA $14
    SEC 
    SBC #$0008
    ORA $16
    AND #$000F
    BEQ loc_008E14
    LDA $0A
    STA $snapResumePtr, X
    LDA $02
    STA $7F101A, X
    LDA #$&func_0AA3A7
    STA $02, S
    SEP #$20
    LDA #$^func_0AA3A7
    STA $02
    STA $04, S
    REP #$20
    RTI 

  loc_008E14:
    LDA $0A
    STA $02, S
    RTI 
}

ResumeAfterSnap {
    TYX 
    LDA $snapResumePtr, X
    STA $02, S
    SEP #$20
    LDA $7F101A, X
    STA $04, S
    REP #$20
    LDA #$0000
    STA $snapResumePtr, X
    STA $7F101A, X
    RTI 
}

StageMove {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    CMP #$00FF
    BNE loc_008E45
    LDA $28

  loc_008E45:
    JSR $&cop_handlers_actors.ProcessAnimFlag
    LDY #$0000
    LDA $moveXAlt, X
    SEC 
    SBC $14
    BPL loc_008E5B
    LDY #$4000
    EOR #$FFFF
    INC 

  loc_008E5B:
    STA $moveXAlt, X
    TYA 
    STA $animScratch2, X
    LDY #$0000
    LDA $moveYAlt, X
    SEC 
    SBC $16
    BPL loc_008E77
    LDY #$8000
    EOR #$FFFF
    INC 

  loc_008E77:
    STA $moveYAlt, X
    CMP $moveXAlt, X
    BCS loc_008E85
    LDA $moveXAlt, X

  loc_008E85:
    PHA 
    TYA 
    ORA $animScratch2, X
    STA $animScratch2, X
    LDA #$0000
    STA $chatPtr, X
    PLA 

  loc_008E97:
    BIT #$FF00
    BEQ loc_008EA4
    LSR 
    PHA 
    JSR $&HalveMovementDistance
    PLA 
    BRA loc_008E97

  loc_008EA4:
    STA $WRDIVL
    LDA [$0A]
    INC $0A
    AND #$00FF
    SEP #$20
    CMP #$80
    BCC loc_008EB7
    EOR #$FF
    INC 

  loc_008EB7:
    STA $WRDIVB
    REP #$20
    LDA [$0A]
    INC $0A
    AND #$00FF
    XBA 
    STA $animScratch+2, X
    LDA $RDDIVL
    INC 
    ORA $animScratch2, X
    STA $animScratch2, X
    BCC loc_008ED9
    JSR $&HalveMovementDistance

  loc_008ED9:
    LDA #$0000
    STA $animScratch, X
    STA $24
    STA $00002C, X
    STA $00002E, X
    LDA $0C
    STA $02
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

HalveMovementDistance {
    LDA $moveXAlt, X
    LSR 
    STA $moveXAlt, X
    LDA $moveYAlt, X
    LSR 
    STA $moveYAlt, X
    LDA $chatPtr, X
    INC 
    STA $chatPtr, X
    RTS 
}

TickMove {
    TYX 

  code_008F0E:
    LDA $animScratch2, X
    AND #$3FFF
    CMP $24
    BNE loc_008F1C
    JMP $&code_008FBC

  loc_008F1C:
    SEP #$20
    LDA $24
    STA $WRMPYA
    LDA $moveYAlt, X
    JSR $&MovementVelocityCompute
    SBC $animScratch+1, X
    BEQ loc_008F55
    PHA 
    LDA $animScratch2, X
    ASL 
    PLA 
    BCC loc_008F3D
    EOR #$FFFF
    INC 

  loc_008F3D:
    AND #$00FF
    BIT #$0080
    BEQ loc_008F48
    ORA #$FF00

  loc_008F48:
    STA $moveScratch2, X
    SEP #$20
    LDA $0000
    STA $animScratch+1, X

  loc_008F55:
    SEP #$20
    LDA $moveXAlt, X
    JSR $&MovementVelocityCompute
    SBC $animScratch, X
    BEQ loc_008F8A
    PHA 
    LDA $animScratch2, X
    ASL 
    ASL 
    PLA 
    BCC loc_008F72
    EOR #$FFFF
    INC 

  loc_008F72:
    AND #$00FF
    BIT #$0080
    BEQ loc_008F7D
    ORA #$FF00

  loc_008F7D:
    STA $moveScratch1, X
    SEP #$20
    LDA $0000
    STA $animScratch, X

  loc_008F8A:
    SEP #$20
    LDA $animScratch+3, X
    BMI loc_008F9C
    DEC 
    BNE loc_008F98
    JMP $&code_008FBC

  loc_008F98:
    STA $animScratch+3, X

  loc_008F9C:
    LDA $animScratch+2, X
    DEC 
    BPL loc_008FAF
    REP #$20

  loc_008FA5:
    JSL $@sprite_composition.UpdateActorAnimation
    BCS loc_008FA5
    SEP #$20
    LDA $08

  loc_008FAF:
    STA $animScratch+2, X
    REP #$20
    STZ $08
    INC $24
    PLA 
    PLA 
    RTL 
}

code_008FBC {
    REP #$20
    LDA $chatPtr, X
    BEQ loc_008FD5
    DEC 
    STA $chatPtr, X
    LDA #$0000
    STA $animScratch, X
    STA $24
    JMP $&code_008F0E

  loc_008FD5:
    LDA $0A
    STA $00
    PLA 
    PLA 
    RTL 
}

MovementVelocityCompute {
    STA $WRMPYB
    LDA $animScratch2, X
    DEC 
    LDY $RDMPYL
    STY $WRDIVL
    STA $WRDIVB
    NOP 
    NOP 
    NOP 
    NOP 
    NOP 
    REP #$20
    SEC 
    LDA $RDDIVL
    STA $0000
    RTS 
}

RngByte {
    PHY 
    SEP #$20
    LDX #$000F
    LDA #$00
    XBA 
    CLC 

  loc_009006:
    LDA $0410, X
    ADC $rngState, X
    STA $rngState, X
    DEX 
    BNE loc_009006
    LDX #$0010

  loc_009015:
    INC $rngState, X
    BNE loc_00901D
    DEX 
    BNE loc_009015

  loc_00901D:
    REP #$20
    PLX 
    LDA $0A
    STA $02, S
    LDA $0410
    AND #$00FF
    RTI 
}

RngMod {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0000
    LDA $0410
    AND #$00FF

  loc_00903C:
    SEC 
    SBC $0000
    BPL loc_00903C
    CLC 
    ADC $0000
    STA $rngModuloResult
    LDA $0A
    STA $02, S
    RTI 
}

SetTilePos {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    ASL 
    ASL 
    ASL 
    ASL 
    CLC 
    ADC #$0008
    STA $14
    LDA [$0A]
    INC $0A
    AND #$00FF
    ASL 
    ASL 
    ASL 
    ASL 
    STA $16
    LDA $0A
    STA $02, S
    RTI 
}

QueueMapChange {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $sceneNext
    LDA [$0A]
    INC $0A
    INC $0A
    STA $064C
    LDA [$0A]
    INC $0A
    INC $0A
    STA $064E
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0650
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0652
    LDA $0650
    BIT #$0080
    BNE loc_0090AF
    LDA $0A
    STA $02, S
    RTI 

  loc_0090AF:
    AND #$FF7F
    STA $0650
    LDA $0A
    SEC 
    SBC #$0008
    STA $sceneSaveData
    STA $0AF4
    LDA $0C
    STA $0AF2
    STA $0AF6
    LDA $0A
    STA $02, S
    RTI 
}

WaitWhileOffscreen {
    TYX 
    LDA $10
    BIT #$4000
    BEQ loc_0090E8
    LDA $0A
    DEC 
    DEC 
    STA $00
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $08
    PLA 
    PLA 
    RTL 

  loc_0090E8:
    LDA [$0A]
    INC $0A
    AND #$00FF
    LDA $0A
    STA $02, S
    RTI 
}

BranchIfPlayerAt {
    TYX 
    LDY $playerActor
    BRA loc_009105
}

BranchIfActorAt {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSR $&ResolveActorIndex

  loc_009105:
    LDA [$0A]
    INC $0A
    INC $0A
    CMP $0014, Y
    BNE loc_009124
    LDA [$0A]
    INC $0A
    INC $0A
    CMP $0016, Y
    BNE loc_00912A
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 

  loc_009124:
    LDA [$0A]
    INC $0A
    INC $0A

  loc_00912A:
    LDA [$0A]
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 
}

BranchOnPlayerX {
    TYX 
    LDY $playerActor
    LDA $0014, Y
    LDY #$0004
    SEC 
    SBC $14
    BEQ loc_00915A
    BPL loc_009153
    EOR #$FFFF
    INC 
    CMP [$0A]
    BCC loc_00915A
    LDY #$0002
    BRA loc_00915A

  loc_009153:
    CMP [$0A]
    BCC loc_00915A
    LDY #$0006

  loc_00915A:
    LDA [$0A], Y
    STA $02, S
    RTI 
}

BranchOnPlayerY {
    TYX 
    LDY $playerActor
    LDA $0016, Y
    LDY #$0004
    SEC 
    SBC $16
    BEQ loc_009184
    BPL loc_00917D
    EOR #$FFFF
    INC 
    CMP [$0A]
    BCC loc_009184
    LDY #$0002
    BRA loc_009184

  loc_00917D:
    CMP [$0A]
    BCC loc_009184
    LDY #$0006

  loc_009184:
    LDA [$0A], Y
    STA $02, S
    RTI 
}

BranchNearerAxis {
    TYX 
    LDY $playerActor
    LDA $0014, Y
    SEC 
    SBC $14
    BPL loc_009199
    EOR #$FFFF
    INC 

  loc_009199:
    PHA 
    LDA $0016, Y
    SEC 
    SBC $16
    BPL loc_0091A6
    EOR #$FFFF
    INC 

  loc_0091A6:
    CMP $01, S
    BCC loc_0091AF
    LDY #$0002
    BRA loc_0091B2

  loc_0091AF:
    LDY #$0000

  loc_0091B2:
    PLA 
    LDA [$0A], Y
    STA $02, S
    RTI 
}

DirToPlayer {
    TYX 
    LDA $14
    STA $0018
    LDA $16
    STA $001C
    JSR $&ComputeDirectionToPlayer
    LDA $0A
    STA $02, S
    TYA 
    RTI 
}

CardinalToPlayer {
    TYX 
    LDY #$&code_009230-1
    PHY 
    LDY $playerActor
    LDA $0014, Y
    SEC 
    SBC $14
    BMI loc_009203
    STA $0018
    LDA $0016, Y
    SEC 
    SBC $16
    BMI loc_0091F0
    CMP $0018
    BCC loc_0091FB
    LDY #$0002
    RTS 

  loc_0091F0:
    BPL loc_0091F6
    EOR #$FFFF
    INC 

  loc_0091F6:
    CMP $0018
    BCS loc_0091FF

  loc_0091FB:
    LDY #$0001
    RTS 

  loc_0091FF:
    LDY #$0000
    RTS 

  loc_009203:
    BPL loc_009209
    EOR #$FFFF
    INC 

  loc_009209:
    STA $0018
    LDA $0016, Y
    SEC 
    SBC $16
    BMI loc_00921D
    CMP $0018
    BCC loc_009228
    LDY #$0002
    RTS 

  loc_00921D:
    BPL loc_009223
    EOR #$FFFF
    INC 

  loc_009223:
    CMP $0018
    BCS loc_00922C

  loc_009228:
    LDY #$0003
    RTS 

  loc_00922C:
    LDY #$0000
    RTS 
}

code_009230 {
    LDA $0A
    STA $02, S
    TYA 
    RTI 
}

DirToPlayerFrom {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_009246
    ORA #$FF00

  loc_009246:
    CLC 
    ADC $14
    STA $0018
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_00925B
    ORA #$FF00

  loc_00925B:
    CLC 
    ADC $16
    STA $001C
    JSR $&ComputeDirectionToPlayer
    LDA $0A
    STA $02, S
    TYA 
    RTI 
}

BranchIfDirToPlayer {
    TYX 
    LDA $14
    STA $0018
    LDA $16
    STA $001C
    JSR $&ComputeDirectionToPlayer
    SEP #$20
    CMP [$0A]
    REP #$20
    BEQ loc_009289
    LDA $0A
    CLC 
    ADC #$0003
    STA $02, S
    RTI 

  loc_009289:
    LDA [$0A]
    INC $0A
    AND #$00FF
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

BranchIfDirToPlayerFrom {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_0092A9
    ORA #$FF00

  loc_0092A9:
    CLC 
    ADC $14
    STA $0018
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_0092BE
    ORA #$FF00

  loc_0092BE:
    CLC 
    ADC $16
    STA $001C
    JSR $&ComputeDirectionToPlayer
    SEP #$20
    CMP [$0A]
    REP #$20
    BEQ loc_0092D8
    LDA $0A
    CLC 
    ADC #$0003
    STA $02, S
    RTI 

  loc_0092D8:
    LDA [$0A]
    INC $0A
    AND #$00FF
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

BranchOnPlayerFacing {
    TYX 
    JSL $@GetPlayerFacingDirection
    BEQ loc_009300
    DEC 
    BEQ loc_009305
    DEC 
    BEQ loc_00930A
    DEC 
    BEQ loc_00930F
    LDA #$0008
    CLC 
    ADC $0A
    BRA loc_009314

  loc_009300:
    LDY #$0000
    BRA loc_009312

  loc_009305:
    LDY #$0002
    BRA loc_009312

  loc_00930A:
    LDY #$0004
    BRA loc_009312

  loc_00930F:
    LDY #$0006

  loc_009312:
    LDA [$0A], Y

  loc_009314:
    STA $02, S
    RTI 
}
---------------------------------------------

SetCollisionAbs {
    PHY 
    PHD 
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0018
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $001C
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0000
    LDA #$0000
    TCD 
    LDX #$0000
    JSL $@map_coords.TileCoordsToMapIndex
    SEP #$20
    LDA $00
    STA $collisionLayer, X
    REP #$20
    PLD 
    PLX 
    LDA $0A
    STA $02, S
    RTI 
}
---------------------------------------------

DrawMetatileAbs {
    TYX 
    JSR $&TileQueryGate
    BCC loc_00968E
    PLA 
    PLA 
    RTL 

  loc_00968E:
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0018
    ASL 
    ASL 
    ASL 
    ASL 
    STA $001A
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $001C
    ASL 
    ASL 
    ASL 
    ASL 
    STA $001E
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0000
    PHY 
    PHD 
    LDA #$0000
    TCD 
    JSR $&ResolveTileData
    PLD 
    PLX 
    LDA $0A
    STA $02, S
    RTI 
}

DrawMetatileHere {
    TYX 
    JSR $&TileQueryGate
    BCC loc_0096D3
    PLA 
    PLA 
    RTL 

  loc_0096D3:
    PHY 
    PHD 
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0000
    LDA #$0000
    TCD 
    LDA $0014, X
    STA $18
    ASL 
    ASL 
    ASL 
    ASL 
    STA $1A
    LDA $0016, X
    STA $1C
    ASL 
    ASL 
    ASL 
    ASL 
    STA $1E
    JSR $&ResolveTileData
    PLD 
    PLX 
    LDA $0A
    STA $02, S
    RTI 
}

WorldMapStream3 {
    TYX 
    JSR $&TileQueryGate
    BCC loc_00970C
    PLA 
    PLA 
    RTL 

  loc_00970C:
    LDA $extendedFlags, X
    BIT #$0002
    BNE loc_009720
    ORA #$0002
    STA $extendedFlags, X
    LDA [$0A]
    STA $24

  loc_009720:
    PHX 
    PHD 
    PHB 
    SEP #$20
    LDA $02
    PHA 
    PLB 
    REP #$20
    LDA $24
    TAX 
    INC 
    INC 
    INC 
    STA $24
    JSR $&ParseMapEntry
    BCS loc_00975B
    PLB 
    JSR $&ResolveTileData
    PLD 
    PLX 
    LDA $extendedFlags, X
    BIT #$0004
    BEQ loc_009752
    SEP #$20
    LDA $orbitAngle, X
    STA $sfxQueueCh2
    REP #$20

  loc_009752:
    LDA $0A
    DEC 
    DEC 
    STA $00
    PLA 
    PLA 
    RTL 

  loc_00975B:
    REP #$20
    PLB 
    PLD 
    PLX 
    LDA $extendedFlags, X
    AND #$FFFD
    STA $extendedFlags, X
    LDA $0A
    CLC 
    ADC #$0002
    STA $02, S
    RTI 
}

WorldMapStream4 {
    TYX 
    JSR $&TileQueryGate
    BCC loc_00977D
    PLA 
    PLA 
    RTL 

  loc_00977D:
    LDA $extendedFlags, X
    BIT #$0002
    BNE loc_009791
    ORA #$0002
    STA $extendedFlags, X
    LDA [$0A]
    STA $24

  loc_009791:
    PHX 
    PHD 
    PHB 
    SEP #$20
    LDA $02
    PHA 
    PLB 
    REP #$20
    LDA $24
    TAX 
    CLC 
    ADC #$0004
    STA $24
    JSR $&ParseMapEntry
    BCS loc_0097D6
    LDA $0003, X
    AND #$00FF
    STA $0008, Y
    PLB 
    JSR $&ResolveTileData
    PLD 
    PLX 
    LDA $extendedFlags, X
    BIT #$0004
    BEQ loc_0097CD
    SEP #$20
    LDA $orbitAngle, X
    STA $sfxQueueCh2
    REP #$20

  loc_0097CD:
    LDA $0A
    DEC 
    DEC 
    STA $00
    PLA 
    PLA 
    RTL 

  loc_0097D6:
    REP #$20
    PLB 
    PLD 
    PLX 
    LDA $extendedFlags, X
    AND #$FFFD
    STA $extendedFlags, X
    LDA $0A
    CLC 
    ADC #$0002
    STA $02, S
    RTI 
}

ParseMapEntry {
    LDA #$0000
    TCD 
    SEP #$20
    LDA $0000, X
    BMI loc_009827
    STA $18
    LDA $0001, X
    STA $1C
    LDA $0002, X
    REP #$20
    AND #$00FF
    STA $00
    LDA $18
    AND #$00FF
    STA $18
    ASL 
    ASL 
    ASL 
    ASL 
    STA $1A
    LDA $1C
    AND #$00FF
    STA $1C
    ASL 
    ASL 
    ASL 
    ASL 
    STA $1E
    CLC 
    RTS 

  loc_009827:
    SEC 
    RTS 
}

ResolveTileData {
    LDX #$0000
    JSL $@map_coords.TileCoordsToMapIndex
    LDA $00
    PHX 
    TAX 
    SEP #$20
    LDA $animScratch, X
    STA $02
    TXA 
    PLX 
    STA $mapLayerTilemap, X
    LDA $02
    STA $collisionLayer, X
    REP #$20
    LDA $1A
    CLC 
    ADC #$0010
    SEC 
    SBC $bg1ScrollH
    CMP #$0111
    BCS loc_0098A8
    LDA $bg2ScrollH
    SEC 
    SBC #$0010
    AND #$FFF0
    PHA 
    LDA $1E
    SEC 
    SBC $01, S
    BMI loc_0098A7
    CMP #$00F1
    BCS loc_0098A7
    PLA 
    LDA $mapLayerTilemap, X
    AND #$00FF
    ASL 
    ASL 
    ASL 
    TAX 
    LDA $metatileMapLayer, X
    STA $0904
    LDA $7E2002, X
    STA $0906
    LDA $7E2004, X
    STA $090A
    LDA $7E2006, X
    STA $090C
    JSL $@map_coords.PixelToVramAddress
    STA $tileQueryResult
    CLC 
    ADC #$0020
    STA $0908
    RTS 

  loc_0098A7:
    PLA 

  loc_0098A8:
    RTS 
}

TileQueryGate {
    CLC 
    LDA $tileQueryResult
    BNE loc_0098B0
    RTS 

  loc_0098B0:
    LDA $0A
    DEC 
    DEC 
    STA $00
    SEC 
    RTS 
}

AdhocVramDma {
    TYX 
    LDA $extendedFlags, X
    BIT #$0001
    BNE loc_00990E
    LDA $7F0C07
    BEQ loc_0098D1
    LDA $0A
    DEC 
    DEC 
    STA $00
    PLA 
    PLA 
    RTL 

  loc_0098D1:
    LDA $0A
    DEC 
    DEC 
    STA $00
    LDA [$0A]
    INC $0A
    INC $0A
    STA $adhocVramDma
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $7F0C05
    LDA [$0A]
    INC $0A
    INC $0A
    STA $7F0C07
    LDA [$0A]
    INC $0A
    INC $0A
    STA $7F0C09
    LDA $extendedFlags, X
    ORA #$0001
    STA $extendedFlags, X
    PLA 
    PLA 
    RTL 

  loc_00990E:
    LDY #$0003
    LDA [$0A], Y
    CMP $7F0C07
    BNE loc_00991C
    PLA 
    PLA 
    RTL 

  loc_00991C:
    LDA $extendedFlags, X
    AND #$FFFE
    STA $extendedFlags, X
    LDA $0A
    CLC 
    ADC #$0007
    STA $02, S
    RTI 
}

CopyPalette {
    PHY 
    LDA [$0A]
    INC $0A
    INC $0A
    PHA 
    LDA [$0A]
    INC $0A
    AND #$00FF
    SEP #$20
    STA $0405
    REP #$20
    LDA [$0A]
    INC $0A
    AND #$00FF
    ASL 
    CLC 
    ADC $01, S
    TAX 
    PLA 
    LDA [$0A]
    INC $0A
    AND #$00FF
    ASL 
    CLC 
    ADC #$0A00
    TAY 
    SEP #$20
    LDA #$7F
    STA $0404
    REP #$20
    LDA [$0A]
    INC $0A
    AND #$00FF
    ASL 
    DEC 
    JSR $0402
    PLX 
    LDA $0A
    STA $02, S
    RTI 
}

Decompress {
    PHY 
    PHD 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $003E
    LDA [$0A]
    INC $0A
    AND #$00FF
    SEP #$20
    STA $0040
    REP #$20
    LDA [$0A]
    INC $0A
    INC $0A
    STA $007A
    LDA [$0A]
    INC $0A
    AND #$00FF
    LDA #$0000
    TCD 
    LDA [$3E]
    STA $78
    INC $3E
    INC $3E
    JSL $@QuintetLzDecompress
    JSL $@sprite_composition.ClearActorRenderList
    PLD 
    PLX 
    LDA $0A
    STA $02, S
    RTI 
}

SetScratchPointer {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $animScratch, X
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $animScratch+2, X
    LDA $0A
    STA $02, S
    RTI 
}
---------------------------------------------

BranchIfBehindWall {
    TYX 
    LDA $14
    LSR 
    LSR 
    LSR 
    LSR 
    STA $0018
    LDA $16
    LSR 
    LSR 
    LSR 
    LSR 
    STA $001C
    PHD 
    LDA #$0000
    TCD 
    JSL $@tile_collision_physics.CalcTileMapOffset
    CPY #$4000
    BCS loc_009B37
    LDA $000F, X
    AND #$0010
    BEQ loc_009B1C
    LDA [$80], Y
    AND #$000F
    BEQ loc_009B2D
    BRA loc_009B2D

  loc_009B1C:
    LDA [$80], Y
    BIT #$00F0
    BNE loc_009B37
    AND #$000F
    BEQ loc_009B2D
    CMP #$000E
    BNE loc_009B37

  loc_009B2D:
    PLD 
    LDA $0A
    CLC 
    ADC #$0002
    STA $02, S
    RTI 

  loc_009B37:
    PLD 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

BranchIfCollisionTypeNe {
    TYX 
    LDA $14
    LSR 
    LSR 
    LSR 
    LSR 
    STA $0018
    LDA $16
    LSR 
    LSR 
    LSR 
    LSR 
    STA $001C
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0000
    PHD 
    LDA #$0000
    TCD 
    JSL $@tile_collision_physics.CalcTileMapOffset
    CPY #$4000
    BCS loc_009B7F
    LDA [$80], Y
    AND #$000F
    CMP $00
    BEQ loc_009B7F
    PLD 
    LDA $0A
    CLC 
    ADC #$0002
    STA $02, S
    RTI 

  loc_009B7F:
    PLD 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

InitSineHdma {
    PHY 
    PHB 
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0062
    STA $spritesetPtr, X
    CLC 
    ADC #$0200
    STA $005E
    CLC 
    ADC #$0200
    STA $0006
    CLC 
    ADC #$0200
    STA $0008
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0E
    ORA #$0080
    STA $0004
    LDA $0E
    ASL 
    STA $0E
    LSR 
    DEC 
    STA $animScratch, X
    LDA $0E
    LSR 
    LDY #$0100
    JSL $@hardware_math.UnsignedDivide
    AND #$00FF
    STA $000E
    ASL 
    CLC 
    ADC $000E
    STA $000E
    SEP #$20
    LDA #$7E
    PHA 
    PLB 
    REP #$20
    LDA #$0000
    TCD 
    LDA $62
    CLC 
    ADC #$0100
    STA $00
    CLC 
    ADC #$0200
    STA $02
    LDY #$0000

  loc_009BFD:
    LDA $04
    STA ($62), Y
    STA ($5E), Y
    STA ($06), Y
    STA ($08), Y
    INY 
    LDA $00
    STA ($62), Y
    LDA $02
    STA ($5E), Y
    CLC 
    ADC #$0200
    STA ($06), Y
    CLC 
    ADC #$0200
    STA ($08), Y
    INY 
    INY 
    CPY $0E
    BNE loc_009BFD
    LDA #$0000
    STA $5E
    STA $animScratch+2, X
    STA $retPtr1, X
    PLB 
    PLA 
    TAX 
    TCD 
    LDA $0C
    STA $02
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

TickSineHdma {
    TYX 
    LDA $animScratch+2, X
    DEC 
    BPL loc_009C58
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $animScratch+2, X
    LDA $retPtr1, X
    INC 
    STA $retPtr1, X
    BRA loc_009C5E

  loc_009C58:
    STA $animScratch+2, X
    INC $0A

  loc_009C5E:
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_009C7C
    AND #$000F
    TAY 
    LDA $cameraTargetX, Y
    STA $0018
    LDA $cameraTargetY, Y
    STA $001C
    BRA loc_009C89

  loc_009C7C:
    TAY 
    LDA $cameraTargetX, Y
    STA $0018
    LDA $cameraTargetY, Y
    STA $001C

  loc_009C89:
    JSR $&BuildSineHdmaTable
    LDA $0A
    STA $02, S
    RTI 
}

BindSineHdma {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    TAY 
    LDA $0036
    LSR 
    BCC loc_009CA5
    TYA 
    CLC 
    ADC #$0200
    TAY 

  loc_009CA5:
    LDA [$0A]
    INC $0A
    INC $0A
    JSL $@hdma_dma_spc.SetupHdmaChannel_Indirect
    LDA $0A
    STA $02, S
    RTI 
}

InitGravity {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_009CC4
    ORA #$FF00

  loc_009CC4:
    STA $scratch1010+2, X
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $scratch1010, X
    LDA [$0A]
    INC $0A
    AND #$00FF
    ASL 
    ASL 
    ASL 
    ASL 
    BIT #$0800
    BEQ loc_009CE7
    EOR #$FFFF
    INC 

  loc_009CE7:
    CLC 
    ADC $16
    STA $moveYAlt, X
    LDA #$0000
    STA $scratch1010+4, X
    LDA $0A
    STA $02, S
    RTI 
}

TickGravity {
    TYX 
    LDA $scratch1010, X
    TAY 
    LDA $scratch1010+4, X
    INC 
    STA $scratch1010+4, X
    SEP #$20
    STA $WRMPYA
    LSR 
    STA $WRMPYB
    LDA #$00
    XBA 
    REP #$20
    LDA $RDMPYL

  loc_009D1A:
    DEY 
    BMI loc_009D20
    LSR 
    BRA loc_009D1A

  loc_009D20:
    PHA 
    LDA $scratch1010+2, X
    SEC 
    SBC $01, S
    STA $01, S
    PLA 
    EOR #$FFFF
    INC 
    STA $moveScratch2, X
    BMI loc_009D4A
    LDA $16
    BMI loc_009D4A
    LDA $moveYAlt, X
    SEC 
    SBC $16
    BCS loc_009D4A
    LDA $0A
    STA $02, S
    LDA #$FFFF
    RTI 

  loc_009D4A:
    LDA $0A
    STA $02, S
    LDA #$0000
    RTI 
}
---------------------------------------------

BranchIfOffCamera {
    TYX 
    LDA $14
    BMI loc_009DE1
    CMP $cameraOffsetX
    BCC loc_009DE1
    CMP $cameraBoundsX
    BCS loc_009DE1
    LDA $16
    BMI loc_009DE1
    CMP $cameraOffsetY
    BCC loc_009DE1
    CMP $cameraBoundsY
    BCS loc_009DE1
    LDA $0A
    INC 
    INC 
    STA $02, S
    RTI 

  loc_009DE1:
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

HaltIfMaxFrames {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    CMP $00E4
    BCC loc_009E01
    LDA $0A
    SEC 
    SBC #$0004
    STA $00
    PLA 
    PLA 
    RTL 

  loc_009E01:
    LDA $0A
    STA $02, S
    RTI 
}
---------------------------------------------

InitSpiral {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $orbitDiameter, X
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $orbitAngle, X
    LDA $0A
    STA $02, S
    RTI 
}

SpiralStep {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_00A9BE
    ORA #$FF00

  loc_00A9BE:
    CLC 
    ADC $orbitDiameter, X
    STA $orbitDiameter, X
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_00A9D6
    ORA #$FF00

  loc_00A9D6:
    CLC 
    ADC $orbitAngle, X
    STA $orbitAngle, X
    LDY $0000
    JSL $@ApplyOrbitalOffsetFromRef
    LDA $0A
    STA $02, S
    RTI 
}
---------------------------------------------

CameraPanDown {
    TYX 
    LDA $2A
    AND #$00FF
    DEC 
    BMI loc_00ACF0
    SEP #$20
    STA $2A
    REP #$20
    BRA loc_00ACFE

  loc_00ACF0:
    REP #$20
    JSR $&CameraScrollStepLookup
    BCC loc_00ACFC
    LDA $0A
    STA $02, S
    RTI 

  loc_00ACFC:
    STA $2A

  loc_00ACFE:
    LDA $2B
    AND #$000F
    CLC 
    ADC $cameraTargetY
    STA $cameraTargetY
    CMP $cameraBoundsY
    BPL loc_00AD12
    PLA 
    PLA 
    RTL 

  loc_00AD12:
    LDA $0A
    STA $02, S
    RTI 
}

CameraPanUp {
    TYX 
    LDA $2A
    AND #$00FF
    DEC 
    BMI loc_00AD28
    SEP #$20
    STA $2A
    REP #$20
    BRA loc_00AD36

  loc_00AD28:
    REP #$20
    JSR $&CameraScrollStepLookup
    BCC loc_00AD34
    LDA $0A
    STA $02, S
    RTI 

  loc_00AD34:
    STA $2A

  loc_00AD36:
    LDA $2B
    AND #$000F
    SEC 
    SBC $cameraTargetY
    BEQ loc_00AD47
    BPL loc_00AD52
    EOR #$FFFF
    INC 

  loc_00AD47:
    STA $cameraTargetY
    CMP $cameraOffsetY
    BMI loc_00AD52
    PLA 
    PLA 
    RTL 

  loc_00AD52:
    LDA $0A
    STA $02, S
    RTI 
}

CameraPanRight {
    TYX 
    LDA $2A
    AND #$00FF
    DEC 
    BMI loc_00AD68
    SEP #$20
    STA $2A
    REP #$20
    BRA loc_00AD76

  loc_00AD68:
    REP #$20
    JSR $&CameraScrollStepLookup
    BCC loc_00AD74
    LDA $0A
    STA $02, S
    RTI 

  loc_00AD74:
    STA $2A

  loc_00AD76:
    LDA $2B
    AND #$000F
    CLC 
    ADC $cameraTargetX
    STA $cameraTargetX
    CMP $cameraBoundsX
    BPL loc_00AD8A
    PLA 
    PLA 
    RTL 

  loc_00AD8A:
    LDA $0A
    STA $02, S
    RTI 
}

CameraPanLeft {
    TYX 
    LDA $2A
    AND #$00FF
    DEC 
    BMI loc_00ADA0
    SEP #$20
    STA $2A
    REP #$20
    BRA loc_00ADAE

  loc_00ADA0:
    REP #$20
    JSR $&CameraScrollStepLookup
    BCC loc_00ADAC
    LDA $0A
    STA $02, S
    RTI 

  loc_00ADAC:
    STA $2A

  loc_00ADAE:
    LDA $2B
    AND #$000F
    SEC 
    SBC $cameraTargetX
    BEQ loc_00ADBF
    BPL loc_00ADCA
    EOR #$FFFF
    INC 

  loc_00ADBF:
    STA $cameraTargetX
    CMP $cameraOffsetX
    BMI loc_00ADCA
    PLA 
    PLA 
    RTL 

  loc_00ADCA:
    LDA $0A
    STA $02, S
    RTI 
}

BuildSineHdmaTable {
    PHX 
    PHB 
    LDA $spritesetPtr, X
    CLC 
    ADC #$0100
    STA $0062
    CLC 
    ADC #$0400
    STA $005E
    LDA $0036
    LSR 
    BCC loc_00ADFA
    LDA $0062
    CLC 
    ADC #$0200
    STA $0062
    CLC 
    ADC #$0400
    STA $005E

  loc_00ADFA:
    SEP #$20
    LDA $7F0008, X
    STA $WRMPYA
    LDA #$7E
    PHA 
    PLB 
    REP #$20
    LDA #$0000
    TCD 
    LDA $000E, X
    STA $0E
    LSR 
    PHA 
    LDA #$0100
    STA $L_WRDIVL
    PLA 
    SEP #$20
    STA $L_WRDIVB
    LDA #$00
    XBA 
    NOP 
    NOP 
    NOP 
    NOP 
    NOP 
    NOP 
    LDA $L_RDDIVL
    REP #$20
    STA $00
    LDY #$0000

  loc_00AE36:
    INY 
    LSR 
    BCC loc_00AE36
    DEY 
    LDA $retPtr1, X
    CLC 
    ADC $1C

  loc_00AE42:
    ASL 
    DEY 
    BNE loc_00AE42
    AND #$00FF
    TAX 
    LDY #$0000

  loc_00AE4D:
    SEP #$20
    LDA $@math_lookup_tables.sine_table_8bit, X
    STA $L_WRMPYB
    BPL loc_00AE8F
    NOP 
    NOP 
    NOP 
    LDA $L_RDMPYH
    PHA 
    LDA #$FF
    STA $L_WRMPYB
    XBA 
    PLA 
    CLC 
    ADC $L_RDMPYL
    REP #$20
    PHA 
    CLC 
    ADC $18
    STA ($62), Y
    PLA 
    CLC 
    ADC $1C
    STA ($5E), Y
    TXA 
    CLC 
    ADC $00
    AND #$00FF
    TAX 
    INY 
    INY 
    CPY $0E
    BNE loc_00AE4D
    PLB 
    PLA 
    TAX 
    TCD 
    RTS 

  loc_00AE8F:
    REP #$20
    NOP 
    LDA $L_RDMPYH
    AND #$00FF
    PHA 
    CLC 
    ADC $18
    STA ($62), Y
    PLA 
    CLC 
    ADC $1C
    STA ($5E), Y
    TXA 
    CLC 
    ADC $00
    AND #$00FF
    TAX 
    INY 
    INY 
    CPY $0E
    BNE loc_00AE4D
    PLB 
    PLA 
    TCD 
    TAX 
    RTS 
}

BuildSineLookupTable {
    PHP 
    PHX 
    LDA $displayModeFlags
    BIT #$0040
    BNE loc_00AED4
    LDA $animScratch2, X
    BIT #$0001
    BEQ loc_00AF19
    AND #$FFFE
    STA $animScratch2, X
    BRA loc_00AEDA

  loc_00AED4:
    AND #$FFBF
    STA $displayModeFlags

  loc_00AEDA:
    SEP #$20
    LDA $7F0008, X
    STA $WRMPYA
    LDX #$0000
    TXY 

  loc_00AEE7:
    LDA $&math_lookup_tables.sine_table_8bit, Y
    STA $WRMPYB
    BPL loc_00AF1C
    NOP 
    NOP 
    NOP 
    LDA $RDMPYH
    PHA 
    LDA #$FF
    STA $WRMPYB
    XBA 
    PLA 
    CLC 
    ADC $RDMPYL
    REP #$20
    STA $sineTableA, X
    STA $sineTableB, X
    TYA 
    SEP #$20
    CLC 
    ADC $0E
    TAY 
    INX 
    INX 
    CPX #$0200
    BNE loc_00AEE7

  loc_00AF19:
    PLX 
    PLP 
    RTS 

  loc_00AF1C:
    REP #$20
    NOP 
    LDA $RDMPYH
    REP #$20
    AND #$00FF
    STA $sineTableA, X
    STA $sineTableB, X
    TYA 
    SEP #$20
    CLC 
    ADC $0E
    TAY 
    INX 
    INX 
    CPX #$0200
    BNE loc_00AEE7
    PLX 
    PLP 
    RTS 
}
---------------------------------------------

ParseSignedTileOffset {
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_00AF9E
    ORA #$FF00

  loc_00AF9E:
    ASL 
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $14
    LSR 
    LSR 
    LSR 
    LSR 
    STA $0018
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_00AFBB
    ORA #$FF00

  loc_00AFBB:
    ASL 
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $16
    SEC 
    SBC #$0010
    LSR 
    LSR 
    LSR 
    LSR 
    STA $001C
    RTS 
}

ComputeDirectionToPlayer {
    LDY $playerActor
    LDA $0014, Y
    SEC 
    SBC $0018
    BMI loc_00B01A
    STA $0000
    LDA $0016, Y
    SEC 
    SBC $001C
    BMI loc_00AFFE
    LDY #$0002
    CMP #$0010
    BCC loc_00B05C
    LDY #$0004
    LDA $0000
    CMP #$0010
    BCC loc_00B05C
    LDY #$0003
    BRA loc_00B05C

  loc_00AFFE:
    EOR #$FFFF
    INC 
    LDY #$0002
    CMP #$0010
    BCC loc_00B05C
    LDY #$0000
    LDA $0000
    CMP #$0010
    BCC loc_00B05C
    LDY #$0001
    BRA loc_00B05C

  loc_00B01A:
    EOR #$FFFF
    INC 
    STA $0000
    LDA $0016, Y
    SEC 
    SBC $001C
    BMI loc_00B042
    LDY #$0006
    CMP #$0010
    BCC loc_00B05C
    LDY #$0004
    LDA $0000
    CMP #$0010
    BCC loc_00B05C
    LDY #$0005
    BRA loc_00B05C

  loc_00B042:
    EOR #$FFFF
    INC 
    LDY #$0006
    CMP #$0010
    BCC loc_00B05C
    LDY #$0000
    LDA $0000
    CMP #$0010
    BCC loc_00B05C
    LDY #$0007

  loc_00B05C:
    TYA 
    RTS 
}
---------------------------------------------

ResolveActorIndex {
    SEP #$20
    XBA 
    LDA #$30
    JSL $@hardware_math.SignedMultiply
    REP #$20
    CLC 
    ADC #$1000
    TAY 
    RTS 
}

CameraScrollStepLookup {
    PHP 
    PHX 
    LDA $scrollStepIndex
    INC $scrollStepIndex
    ASL 
    CLC 
    ADC $scrollStepTableBase
    TAX 
    LDA $0000, X
    BIT #$FF00
    BEQ loc_00B150
    PLX 
    PLP 
    CLC 
    RTS 

  loc_00B150:
    STZ $scrollStepIndex
    PLX 
    PLP 
    SEC 
    RTS 
}
---------------------------------------------

MarkCollisionRect {
    PHB 
    PHD 
    PHX 
    LDA #$0000
    TCD 
    LDA $metaspritePtr, X
    TAY 
    SEP #$20
    LDA $7F0008, X
    PHA 
    PLB 
    REP #$20
    LDA $0000, Y
    ORA #$FF00
    CLC 
    ADC $18
    LSR 
    LSR 
    LSR 
    LSR 
    STA $18
    LDA $0002, Y
    AND #$00FF
    STA $1A
    LDA $0001, Y
    ORA #$FF00
    CLC 
    ADC $1C
    LSR 
    LSR 
    LSR 
    LSR 
    STA $1C
    LDA $0003, Y
    AND #$00FF
    STA $1E
    LDX #$0000
    JSL $@map_coords.TileCoordsToMapIndex
    CPX #$4000
    BCS loc_00B325
    LDA $1A
    STA $18
    TXA 
    STA $1C

  loc_00B2F6:
    SEP #$20
    TAX 
    LDA $collisionLayer, X
    ORA #$F0
    STA $collisionLayer, X
    DEC $18
    BEQ loc_00B316
    REP #$20
    TXA 
    INC 
    BIT #$000F
    BNE loc_00B2F6
    CLC 
    ADC #$00F0
    BRA loc_00B2F6

  loc_00B316:
    DEC $1E
    BEQ loc_00B325
    LDA $1A
    STA $18
    JSR $&AdvanceMapY
    LDA $1C
    BRA loc_00B2F6

  loc_00B325:
    REP #$20
    PLX 
    PLD 
    PLB 
    RTS 
}

AdvanceMapY {
    PHP 
    SEP #$20
    LDA $1C
    CLC 
    ADC #$10
    BCS loc_00B339
    STA $1C
    PLP 
    RTS 

  loc_00B339:
    XBA 
    CLC 
    ADC $mapRowStrideL0
    XBA 
    REP #$20
    STA $1C
    PLP 
    RTS 
}

ClearCollisionRect {
    PHB 
    PHD 
    PHX 
    LDA #$0000
    TCD 
    LDA $metaspritePtr, X
    TAY 
    SEP #$20
    LDA $7F0008, X
    PHA 
    PLB 
    REP #$20
    LDA $0000, Y
    ORA #$FF00
    CLC 
    ADC $18
    LSR 
    LSR 
    LSR 
    LSR 
    STA $18
    LDA $0002, Y
    AND #$00FF
    STA $1A
    LDA $0001, Y
    ORA #$FF00
    CLC 
    ADC $1C
    LSR 
    LSR 
    LSR 
    LSR 
    STA $1C
    LDA $0003, Y
    AND #$00FF
    STA $1E
    LDX #$0000
    JSL $@map_coords.TileCoordsToMapIndex
    CPX #$4000
    BCS loc_00B3E9
    LDA $1A
    STA $18
    TXA 
    STA $1C
    LDA $00
    BEQ loc_00B3A3
    JMP $&ClearCollisionRectFull

  loc_00B3A3:
    TXA 

  loc_00B3A4:
    SEP #$20
    TAX 
    LDA $collisionLayer, X
    AND #$0F
    STA $collisionLayer, X
    DEC $18
    BEQ loc_00B3C4
    REP #$20
    TXA 
    INC 
    BIT #$000F
    BNE loc_00B3A4
    CLC 
    ADC #$00F0
    BRA loc_00B3A4

  loc_00B3C4:
    DEC $1E
    BEQ loc_00B3E9
    LDA $1A
    STA $18
    LDA $1C
    CLC 
    ADC #$10
    BCS loc_00B3DB
    STA $1C
    REP #$20
    LDA $1C
    BRA loc_00B3A4

  loc_00B3DB:
    STA $1C
    REP #$20
    LDA $1C
    CLC 
    ADC $mapBoundsX
    STA $1C
    BRA loc_00B3A4

  loc_00B3E9:
    REP #$20
    PLX 
    PLD 
    PLB 
    RTS 
}

ClearCollisionRectFull {
    TXA 

  loc_00B3F0:
    SEP #$20
    TAX 
    LDA $collisionLayer, X
    AND #$00
    STA $collisionLayer, X
    DEC $18
    BEQ loc_00B410
    REP #$20
    TXA 
    INC 
    BIT #$000F
    BNE loc_00B3F0
    CLC 
    ADC #$00F0
    BRA loc_00B3F0

  loc_00B410:
    DEC $1E
    BEQ loc_00B435
    LDA $1A
    STA $18
    LDA $1C
    CLC 
    ADC #$10
    BCS loc_00B427
    STA $1C
    REP #$20
    LDA $1C
    BRA loc_00B3F0

  loc_00B427:
    STA $1C
    REP #$20
    LDA $1C
    CLC 
    ADC $mapBoundsX
    STA $1C
    BRA loc_00B3F0

  loc_00B435:
    REP #$20
    PLX 
    PLD 
    PLB 
    RTS 
}

TileCollisionQuery {
    PHD 
    LDA #$0000
    TCD 
    LDA $18
    AND #$FFF0
    BMI loc_00B47C
    CMP $cameraOffsetX
    BCC loc_00B47C
    CMP $cameraBoundsX
    BCS loc_00B47C
    LSR 
    LSR 
    LSR 
    LSR 
    STA $18
    LDA $1C
    BMI loc_00B47C
    CMP $cameraOffsetY
    BCC loc_00B47C
    CMP $cameraLowerYBound
    BCS loc_00B47C
    LSR 
    LSR 
    LSR 
    LSR 
    DEC 
    STA $1C
    JSL $@tile_collision_physics.CalcTileMapOffset
    CPY #$4000
    BCS loc_00B47C
    LDA [$80], Y
    BIT #$00F0
    BEQ loc_00B47F

  loc_00B47C:
    LDA #$000F

  loc_00B47F:
    PLD 
    RTS 
}