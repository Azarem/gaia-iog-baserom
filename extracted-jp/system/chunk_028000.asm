?BANK 02

?INCLUDE 'array_01D3F7'
?INCLUDE 'binary_01C36C'
?INCLUDE 'chunk_008000'
?INCLUDE 'chunk_038000'
?INCLUDE 'chunk_058000'
?INCLUDE 'chunk_078000'
?INCLUDE 'chunk_088000'
?INCLUDE 'chunk_098000'
?INCLUDE 'chunk_0A8000'
?INCLUDE 'chunk_3B7DD'
?INCLUDE 'ec0A_caring_maid'
?INCLUDE 'music_array'
?INCLUDE 'palette_bundles'
?INCLUDE 'sc03_lances_mother'
?INCLUDE 'scene_warps'
?INCLUDE 'stats_table'
?INCLUDE 'string_templates'
?INCLUDE 'table_018000'
?INCLUDE 'table_01A946'
?INCLUDE 'table_01AD90'
?INCLUDE 'table_01B06E'
?INCLUDE 'table_01D9D0'
?INCLUDE 'table_01D9E8'
?INCLUDE 'table_0EE000'

!L_WRMPYA                       004202
!deathFlag                      0200
!extVelocityX                   0408
!extVelocityY                   040A
!invincibilityTimer             040C
!rngState                       040F
!sceneNext                      0642
!sceneCurrent                   0644
!worldReadyFlag                 0654
!joypadCurrent                  0656
!joypadHeld                     0658
!joypadMaskStd                  065A
!joypadMaskInv                  065C
!joypadRemapped                 065E
!joypadRaw                      0660
!joypadRepeatCounter            0662
!bg1ScrollH                     068A
!bg1ScrollV                     068C
!bg2ScrollH                     068E
!savedCameraDelta               0690
!mapBoundsX                     0692
!mapRowStrideL0                 0693
!mapRowStrideL1                 0695
!mapBoundsY                     0696
!mapTilemapBaseA                069E
!cameraTargetX                  06BE
!cameraDeltaX                   06C0
!cameraTargetY                  06C2
!cameraDeltaY                   06C4
!scrollOverrideH                06C6
!forcedScrollOverride           06C8
!scrollOverrideV                06CA
!scrollDeltaXClamped            06CE
!scrollDeltaYClamped            06D2
!cameraOffsetX                  06D6
!cameraOffsetY                  06D8
!cameraBoundsX                  06DA
!cameraBoundsY                  06DC
!cameraLowerYBound              06DE
!scrollStepTableBase            06E0
!scrollStepIndex                06E2
!effectDeltaX                   06E4
!layerPriorityFlag              06EE
!scrollModeFlags                06EF
!musicParentActor               06F2
!sfxQueueCh1                    06F8
!sfxQueueCh2                    06F9
!musicTransitionState           06FA
!dmaSkipFlag                    0800
!tileQueryResult                0902
!playerXPos                     09A2
!playerYPos                     09A4
!playerXTile                    09A6
!playerYTile                    09A8
!playerActor                    09AA
!playerWallType                 09B0
!playerSpeedEw                  09B2
!playerSpeedNs                  09B4
!slopeStepCounter               09B6
!decelStepCounter               09B8
!slopeCurvePtrA                 09BA
!slopeCurvePtrB                 09BC
!decelCurvePtr                  09C2
!slopeFracAccum                 09C6
!maxSpeedEw                     09C8
!maxSpeedNs                     09CA
!eventFlags                     0A00
!abilityBitmask                 0AA2
!inventorySlots                 0AB4
!inventoryEquippedIndex         0AC4
!inventoryEquippedType          0AC6
!cachedPrevMaxHp                0ACC
!cachedPrevHp                   0AD0
!characterForm                  0AD4
!bg1ConfigMode                  0AE6
!itemAbilityIndex               0AE8
!sceneSaveData                  0AF0
!inventoryTabIndex              0AFA
!remapSelect                    0DA6
!remapX                         0DA8
!remapB                         0DAA
!remapA                         0DAC
!remapY                         0DAE
!remapStart                     0DB0
!remapL                         0DB2
!remapR                         0DB4
!S_metatileMapLayer             2000
!INIDISP                        2100
!OAMADDL                        2102
!BG1SC                          2107
!BG2SC                          2108
!BG3SC                          2109
!BG34NBA                        210C
!BG3HOFS                        2111
!BG3VOFS                        2112
!VMAIN                          2115
!VMADDL                         2116
!VMDATAL                        2118
!M7A                            211B
!M7B                            211C
!M7C                            211D
!M7D                            211E
!M7X                            211F
!M7Y                            2120
!CGADD                          2121
!W12SEL                         2123
!W34SEL                         2124
!WOBJSEL                        2125
!WH0                            2126
!WH1                            2127
!WH2                            2128
!WH3                            2129
!WBGLOG                         212A
!WOBJLOG                        212B
!COLDATA                        2132
!APUIO0                         2140
!APUIO1                         2141
!APUIO2                         2142
!S_metatileEffectLayer          2800
!WRMPYA                         4202
!WRMPYB                         4203
!WRDIVL                         4204
!WRDIVH                         4205
!WRDIVB                         4206
!MDMAEN                         420B
!HDMAEN                         420C
!RDDIVL                         4214
!RDMPYL                         4216
!DMAP0                          4300
!BBAD0                          4301
!A1T0L                          4302
!A1B0                           4304
!DAS0L                          4305
!S_tileStagingBuffer            7000
!metatileMapLayer               7E2000
!metatileEffectLayer            7E2800
!tilemapStaging                 7E3100
!mapLayerTilemap                7EA000
!effectLayerTilemap             7EC000
!animScratch                    7F0000
!retPtr1                        7F0004
!chatPtr                        7F000A
!animScratch2                   7F000E
!orbitAngle                     7F0010
!orbitDiameter                  7F0012
!loopCounter                    7F0014
!moveXAlt                       7F0018
!moveYAlt                       7F001A
!iframeCounter                  7F0028
!moveScratch1                   7F002C
!moveScratch2                   7F002E
!cgramPalette                   7F0A00
!backdropColors                 7F0C00
!oamComposeBuffer               7F3100
!collisionLayer                 7FC000
!L_INIDISP                      802100
!L_NMITIMEN                     804200
!L_WRMPYB                       804203
!L_RDNMI                        804210
!L_RDMPYL                       804216
!L_RDMPYH                       804217
!S_mapLayerTilemap              A000

---------------------------------------------

code_028000 {
    PHP 
    REP #$20
    PHD 
    LDA #$0000
    TCD 
    STZ $0D70
    LDX #$0000

  loc_02800E:
    LDA #$0000
    STA $mapLayerTilemap, X
    STA $7EA002, X
    STA $7EA004, X
    STA $7EA006, X
    STA $7EA008, X
    STA $7EA00A, X
    STA $7EA00C, X
    STA $7EA00E, X
    TXA 
    CLC 
    ADC #$0010
    TAX 
    CPX #$0800
    BCC loc_02800E
    STZ $08
    SEP #$20
    LDX #$A000
    STX $3E
    LDA #$7E
    STA $40
    STA $44
    LDX #$804A
    PHX 
    LDA $0000, Y
    BMI loc_028059
    INY 
    JSR $&code_0280A5
    RTS 

  loc_028059:
    INY 
    BIT #$40
    BNE loc_028062
    JSR $&code_02807E
    RTS 

  loc_028062:
    AND #$1F
    CMP #$14
    BEQ loc_028071
    CMP #$15
    BNE loc_028076
    LDA #$00
    STA $09
    RTS 

  loc_028071:
    LDA #$20
    STA $09
    RTS 

  loc_028076:
    REP #$20
    PLA 
    PLA 
    TCD 
    TAX 
    PLP 
    RTL 
}

code_02807E {
    AND #$3F
    XBA 
    LDA $0000, Y
    INY 
    REP #$20
    PHA 
    AND #$01FF
    ASL 
    ASL 
    ASL 
    ASL 
    ASL 
    ASL 
    STA $62
    PLA 
    XBA 
    AND #$00FF
    LSR 
    CLC 
    ADC #$00C2
    STA $64
    JSR $&code_0280C1
    SEP #$20
    RTS 
}

code_0280A5 {
    PHA 
    LDA #$C1
    STA $64
    PLA 
    REP #$20
    AND #$00FF
    ASL 
    ASL 
    ASL 
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $08
    STA $62
    JSR $&code_0280C1
    SEP #$20
    RTS 
}

code_0280C1 {
    PHY 
    INC $0D70
    LDY #$0000
    LDA $3E
    STA $42
    LDA #$0001
    STA $10

  loc_0280D1:
    LDA #$0001
    STA $0E

  loc_0280D6:
    LDX #$0007

  loc_0280D9:
    LDA [$62], Y
    STA $00
    SEP #$20
    EOR $01
    EOR #$FF
    TRB $00
    TRB $01
    REP #$20
    LDA $00
    STA [$42], Y
    INY 
    INY 
    DEX 
    BPL loc_0280D9
    LDA $42
    CLC 
    ADC #$0010
    STA $42
    DEC $0E
    BPL loc_0280D6
    LDA $42
    CLC 
    ADC #$01C0
    STA $42
    DEC $10
    BPL loc_0280D1
    LDA $3E
    PHA 
    CLC 
    ADC #$0040
    STA $3E
    EOR $01, S
    BIT #$0200
    BEQ loc_028122
    LDA #$0200
    CLC 
    ADC $3E
    STA $3E

  loc_028122:
    PLA 
    PLY 
    RTS 
}

code_028125 {
    SEP #$20
    STA $WRMPYA
    XBA 
    PHA 
    REP #$20
    TYA 
    SEP #$20
    STA $WRMPYB
    XBA 
    NOP 
    NOP 
    NOP 
    LDY $RDMPYL
    STA $WRMPYB
    REP #$20
    TYA 
    SEP #$20
    STA $WRDIVL
    XBA 
    CLC 
    ADC $RDMPYL
    STA $WRDIVH
    PLA 
    STA $WRDIVB
    NOP 
    NOP 
    NOP 
    NOP 
    NOP 
    NOP 
    NOP 
    NOP 
    REP #$20
    LDA $RDDIVL
    RTL 
}

code_028160 {
    PHP 
    REP #$20
    PHA 
    SEP #$20
    BRA loc_02817C
}

code_028168 {
    PHP 
    REP #$20
    PHA 
    SEP #$20
    LDA $L_RDNMI

  loc_028172:
    LDA $L_RDNMI
    BPL loc_028172
    LDA $L_RDNMI

  loc_02817C:
    LDA $scrollModeFlags
    BIT #$08
    BEQ loc_0281CB
    LDA $C2
    STA $M7A
    LDA $C3
    STA $M7A
    LDA $C4
    STA $M7B
    LDA $C5
    STA $M7B
    LDA $C6
    STA $M7C
    LDA $C7
    STA $M7C
    LDA $C8
    STA $M7D
    LDA $C9
    STA $M7D
    LDA $CA
    STA $M7X
    LDA $CB
    AND #$1F
    STA $M7X
    LDA $CC
    STA $M7Y
    LDA $CD
    AND #$1F
    STA $M7Y
    LDX $BE
    STX $CE
    LDX $C0
    STX $D0

  loc_0281CB:
    REP #$20
    LDA $slopeCurvePtrA
    BEQ loc_0281DB
    STA $joypadCurrent
    STZ $slopeCurvePtrA
    PLA 
    PLP 
    RTL 

  loc_0281DB:
    LDA $joypadRaw
    AND #$0F00
    STA $joypadRemapped
    LDA $remapL
    BEQ loc_0281F7
    LDA $joypadRaw
    BIT #$1000
    BEQ loc_0281F7
    LDA $remapL
    TSB $joypadRemapped

  loc_0281F7:
    LDA $remapR
    BEQ loc_02820A
    LDA $joypadRaw
    BIT #$2000
    BEQ loc_02820A
    LDA $remapR
    TSB $joypadRemapped

  loc_02820A:
    LDA $remapB
    BEQ loc_02821D
    LDA $joypadRaw
    BIT #$8000
    BEQ loc_02821D
    LDA $remapB
    TSB $joypadRemapped

  loc_02821D:
    LDA $remapY
    BEQ loc_028230
    LDA $joypadRaw
    BIT #$4000
    BEQ loc_028230
    LDA $remapY
    TSB $joypadRemapped

  loc_028230:
    LDA $remapA
    BEQ loc_028243
    LDA $joypadRaw
    BIT #$0080
    BEQ loc_028243
    LDA $remapA
    TSB $joypadRemapped

  loc_028243:
    LDA $remapStart
    BEQ loc_028256
    LDA $joypadRaw
    BIT #$0040
    BEQ loc_028256
    LDA $remapStart
    TSB $joypadRemapped

  loc_028256:
    LDA $remapX
    BEQ loc_028269
    LDA $joypadRaw
    BIT #$0020
    BEQ loc_028269
    LDA $remapX
    TSB $joypadRemapped

  loc_028269:
    LDA $remapSelect
    BEQ loc_02827C
    LDA $joypadRaw
    BIT #$0010
    BEQ loc_02827C
    LDA $remapSelect
    TSB $joypadRemapped

  loc_02827C:
    LDA $joypadRemapped
    STA $joypadCurrent
    STA $joypadRaw
    AND $joypadHeld
    STA $joypadHeld
    BEQ loc_0282A4
    AND $joypadMaskInv
    BEQ loc_0282A4
    LDA $joypadRepeatCounter
    INC 
    STA $joypadRepeatCounter
    CMP #$000C
    BNE loc_0282A7
    LDA $joypadMaskInv
    TRB $joypadHeld

  loc_0282A4:
    STZ $joypadRepeatCounter

  loc_0282A7:
    LDA $joypadHeld
    TRB $joypadCurrent
    LDA $joypadMaskStd
    TRB $joypadCurrent
    PLA 
    PLP 
    RTL 
}

code_0282B6 {
    PHP 
    SEP #$20
    PHA 
    LDA $L_RDNMI
    LDA #$81
    STA $L_NMITIMEN
    PLA 
    PLP 
    RTL 
}

code_0282C7 {
    PHP 
    SEP #$20
    PHA 
    LDA #$01
    STA $L_NMITIMEN
    PLA 
    PLP 
    RTL 
}

code_0282D4 {
    PHP 
    SEP #$20
    PHA 
    LDA #$00
    STA $L_INIDISP
    PLA 
    PLP 
    RTL 
}

code_0282E1 {
    PHP 
    SEP #$20
    PHA 
    LDA #$80
    STA $L_INIDISP
    PLA 
    PLP 
    RTL 
}

code_0282EE {
    JSL $@code_028168
    DEC 
    BNE code_0282EE
    RTL 
}

code_0282F6 {
    STA $L_WRMPYA
    XBA 
    STA $L_WRMPYB
    NOP 
    NOP 
    NOP 
    NOP 
    LDA $L_RDMPYH
    XBA 
    LDA $L_RDMPYL
    RTL 
}

code_02830D {
    STY $WRDIVL
    STA $WRDIVB
    NOP 
    NOP 
    NOP 
    NOP 
    NOP 
    NOP 
    NOP 
    NOP 
    LDA $RDMPYL
    XBA 
    LDA $RDDIVL
    RTL 
}

code_028323 {
    PHD 
    PHA 
    LDA #$00
    BRK #$5B
    PLA 
    STZ $00
    STZ $02
    STZ $04
    STZ $06
    CMP #$00
    BRK #$30
    ORA $E6
    BRK #$0A
    BPL loc_028337
    STA $02
    TYA 
    LDY #$0010
    CLC 

  loc_028343:
    BCS loc_028349
    CMP $02
    BCC loc_02834C

  loc_028349:
    SBC $02
    SEC 

  loc_02834C:
    ROL $06
    DEC $00
    BMI loc_028356
    ASL 
    DEY 
    BNE loc_028343

  loc_028356:
    ASL 
    LDY #$0010
    CLC 

  loc_02835B:
    BCS loc_028361
    CMP $02
    BCC loc_028364

  loc_028361:
    SBC $02
    SEC 

  loc_028364:
    ROL $04
    ASL 
    DEY 
    BNE loc_02835B
    PLD 
    RTL 
}

code_02836C {
    PHP 
    SEP #$20
    PHA 
    PHX 
    PHY 
    LDX #$000F
    LDA #$00
    XBA 
    CLC 

  loc_028379:
    LDA $0410, X
    ADC $rngState, X
    STA $rngState, X
    DEX 
    BNE loc_028379
    LDX #$0010

  loc_028388:
    INC $rngState, X
    BNE loc_028390
    DEX 
    BNE loc_028388

  loc_028390:
    PLA 
    PLY 
    PLX 
    PLP 
    RTL 
}

code_028395 {
    PHP 
    PHB 
    PHX 
    PHY 
    SEP #$20
    LDA #$7E
    PHA 
    PLB 
    LDX #$0200
    STX $74
    STX $76
    LDA #$20

  loc_0283A8:
    STA ($74)
    INC $74
    BNE loc_0283A8
    LDA #$EF
    STA $74
    LDA #$80
    STA $72
    LDX $7A
    LDY $78

  loc_0283BA:
    LDA [$3E]
    AND $72
    PHA 
    LSR $72
    BCC loc_0283CB
    ROR $72
    INC $3E
    BNE loc_0283CB
    INC $3F

  loc_0283CB:
    PLA 
    BEQ loc_0283DE
    JSR $&code_028403
    STA $0000, X
    INX 
    STA ($74)
    INC $74
    DEY 
    BNE loc_0283BA
    BRA loc_0283FE

  loc_0283DE:
    JSR $&code_028403
    STA $76
    JSR $&code_028460
    INC 
    INC 

  loc_0283E8:
    XBA 
    LDA ($76)
    INC $76
    STA ($74)
    INC $74
    STA $0000, X
    INX 
    DEY 
    BEQ loc_0283FE
    XBA 
    DEC 
    BNE loc_0283E8
    BRA loc_0283BA

  loc_0283FE:
    PLY 
    PLX 
    PLB 
    PLP 
    RTL 
}

code_028403 {
    LDA $72
    BMI loc_02844A
    ASL 
    BMI loc_028443
    ASL 
    BMI loc_02843C
    ASL 
    BMI loc_028435
    ASL 
    BMI loc_02842E
    ASL 
    BMI loc_028427
    ASL 
    BMI loc_028420
    REP #$20
    LDA [$3E]
    XBA 
    BRA loc_028453

  loc_028420:
    REP #$20
    LDA [$3E]
    XBA 
    BRA loc_028454

  loc_028427:
    REP #$20
    LDA [$3E]
    XBA 
    BRA loc_028455

  loc_02842E:
    REP #$20
    LDA [$3E]
    XBA 
    BRA loc_028456

  loc_028435:
    REP #$20
    LDA [$3E]
    XBA 
    BRA loc_028457

  loc_02843C:
    REP #$20
    LDA [$3E]
    XBA 
    BRA loc_028458

  loc_028443:
    REP #$20
    LDA [$3E]
    XBA 
    BRA loc_028459

  loc_02844A:
    LDA [$3E]
    REP #$20
    INC $3E
    SEP #$20
    RTS 

  loc_028453:
    ASL 

  loc_028454:
    ASL 

  loc_028455:
    ASL 

  loc_028456:
    ASL 

  loc_028457:
    ASL 

  loc_028458:
    ASL 

  loc_028459:
    ASL 
    INC $3E
    XBA 
    SEP #$20
    RTS 
}

code_028460 {
    LDA $72
    CMP #$10
    BCC loc_028482
    LSR 
    LSR 
    LSR 
    LSR 
    STA $72
    XBA 
    LDA [$3E]
    XBA 
    REP #$20
    LSR 
    BCS loc_02847C
    LSR 
    BCS loc_02847C
    LSR 
    BCS loc_02847C
    LSR 

  loc_02847C:
    SEP #$20
    XBA 
    AND #$0F
    RTS 

  loc_028482:
    LSR 
    BCS loc_0284B3
    LSR 
    BCS loc_0284A6
    LSR 
    BCS loc_02849A
    LDA #$80
    STA $72
    LDA [$3E]
    REP #$20
    INC $3E
    SEP #$20
    AND #$0F
    RTS 

  loc_02849A:
    LDA #$40
    STA $72
    REP #$20
    LDA [$3E]
    XBA 
    ASL 
    BRA loc_0284BF

  loc_0284A6:
    LDA #$20
    STA $72
    REP #$20
    LDA [$3E]
    XBA 
    ASL 
    ASL 
    BRA loc_0284BF

  loc_0284B3:
    LDA #$10
    STA $72
    REP #$20
    LDA [$3E]
    XBA 
    ASL 
    ASL 
    ASL 

  loc_0284BF:
    INC $3E
    SEP #$20
    XBA 
    AND #$0F
    RTS 
}

code_0284C7 {
    STX $4302
    STA $4304
    STY $4305
    LDA #$01
    STA $4300
    LDA #$18
    STA $4301
    LDA #$01
    STA $420B
    RTL 
}

code_0284E0 {
    PHP 
    SEP #$20
    JSR $&code_028E0A

  code_0284E6:
    JSR $&code_028DFF
    CMP #$00
    BEQ loc_028500
    PEA $&code_0284E6-1
    REP #$20
    AND #$00FF
    ASL 
    TAX 
    LDA $@code_028534, X
    DEC 
    PHA 
    SEP #$20
    RTS 

  loc_028500:
    JSR $&code_0290E1
    PLP 
    RTL 
}

code_028505 {
    PHP 
    SEP #$20
    JSR $&code_028E0A

  code_02850B:
    JSR $&code_028DFF
    CMP #$00
    BEQ loc_028532
    PEA $&code_02850B-1
    REP #$20
    AND #$00FF
    ASL 
    TAX 
    LDA $@code_028534, X
    CMP #$8C8B
    BEQ loc_02852A
    DEC 
    PHA 
    SEP #$20
    RTS 

  loc_02852A:
    INY 
    INY 
    INY 
    INY 
    INY 
    SEP #$20
    RTS 

  loc_028532:
    PLP 
    RTL 
}

code_028534 {
    PLY 
    STA $7A
    STA $8B
    PHB 
    TDC 
    STA $E1
    STA [$30]
    DEY 
    PHX 
    DEY 
    PLY 
    STA $7A
    STA $7A
    STA $7A
    STA $7A
    STA $7A
    STA $7A
    STA $87
    STY $857A
    JSR ($&code_list_028B8C, X)
    STY $857A
    STZ $85
    ADC $5585, Y
    STX $857A
    PHA 
    STA $C208
    JSR $&code_02FF20
    STA $225A
    ADC $B5
    BRA loc_0285EA

  loc_028570:
    BCC loc_028576
    PLP 
    JMP $&code_028E55

  loc_028576:
    INY 
    PLP 
    RTS 
}

code_028579 {
    INY 
    RTS 
}

code_02857B {
    PHP 
    REP #$20
    JSR $&code_028DFF
    XBA 
    ASL 
    STA $0664
    JSR $&code_028DFF
    XBA 
    ASL 
    STA $0666
    JSR $&code_028DFF
    STA $0668
    LDX #$003E
    JSR $&code_028EA7
    JSR $&code_028DFF
    CMP #$0000
    BEQ loc_0285AB
    DEC 
    BEQ loc_0285DA
    DEC 
    BEQ loc_028605
    DEC 
    BEQ loc_028611

  loc_0285AB:
    LDA $0668
    BIT #$0010
    BNE loc_0285CE
    CLC 
    ADC #$0020
    STA $0668
    LDX #$066C
    LDA $0666
    SEC 
    SBC $0664
    CMP #$2001
    BMI loc_02861A
    STZ $0670
    BRA loc_02861A

  loc_0285CE:
    CLC 
    ADC #$0020
    STA $0668
    LDX #$066F
    BRA loc_02861A

  loc_0285DA:
    LDA $0668
    BIT #$0010
    BNE loc_0285F9
    CLC 
    ADC #$0040
    STA $0668
    BIT #$0028
    BEQ loc_0285F1
    STZ $0676

  loc_0285F1:
    STZ $0673
    LDX #$0672
    BRA loc_02861A

  loc_0285F9:
    CLC 
    ADC #$0040
    STA $0668
    LDX #$0675
    BRA loc_02861A

  loc_028605:
    LDA $0668
    CLC 
    ADC #$0060
    STA $0668
    BRA loc_028621

  loc_028611:
    LDA $0668
    STA $0668
    JMP $&code_0286B0

  loc_02861A:
    JSR $&code_028ED9
    BCS loc_028621
    PLP 
    RTS 

  loc_028621:
    LDA [$3E]
    INC $3E
    INC $3E
    STA $78
    CMP #$0000
    BEQ loc_028673
    CPX #$066C
    BNE loc_02863E
    LDA $06EE
    BIT #$0800
    BEQ loc_02863E
    JMP $&code_0286F9

  loc_02863E:
    JSR $&code_028F30
    BCC loc_028648
    JSR $&code_029014
    PLP 
    RTS 

  loc_028648:
    JSR $&code_028F55
    LDA $78
    CMP #$2001
    BCC loc_028655
    STZ $067F

  loc_028655:
    LDX #$7000
    STX $7A
    JSL $@code_028395
    LDX #$7000
    STX $3E
    LDA #$007E
    STA $40
    JSR $&code_028670
    JSR $&code_028F79
    PLP 
    RTS 
}

code_028670 {
    PHP 
    BRA loc_02867E

  loc_028673:
    LDA $06EE
    BIT #$0800
    BEQ loc_02867E
    JMP $&code_028711

  loc_02867E:
    LDA $0668
    XBA 
    STA $2116
    LDA $3E
    CLC 
    ADC $0664
    STA $4302
    LDA $0666
    SEC 
    SBC $0664
    STA $4305
    SEP #$20
    LDA #$01
    STA $4300
    LDA #$18
    STA $4301
    LDA $40
    STA $4304
    LDA #$01
    STA $420B
    PLP 
    RTS 
}

code_0286B0 {
    LDA [$3E]
    STA $78
    INC $3E
    INC $3E
    CMP #$0000
    BEQ loc_0286D0
    LDX #$7000
    STX $7A
    JSL $@code_028395
    LDX #$7000
    STX $3E
    LDA #$007E
    STA $40

  loc_0286D0:
    SEP #$20
    LDX #$2000
    STX $2116
    LDA #$00
    STA $4300
    LDA #$19
    STA $4301
    LDX $3E
    STX $4302
    LDA $40
    STA $4304
    LDX #$4000
    STX $4305
    LDA #$01
    STA $420B
    PLP 
    RTS 
}

code_0286F9 {
    STZ $0670
    STZ $067F
    STZ $0682
    STZ $0679
    STZ $067C
    LDX #$7000
    STX $7A
    JSL $@code_028395
}

code_028711 {
    PHY 
    PHB 
    SEP #$20
    LDA #$7E
    PHA 
    PLB 
    LDX #$0000
    STZ $0E
    LDY #$A000
    STY $5E
    JSR $&code_0287AA

  loc_028726:
    LDA #$07
    STA $12
    LDA ($3E)
    STA $10
    INC $3E
    BNE loc_028734
    INC $3F

  loc_028734:
    LDA $S_tileStagingBuffer, X
    STA $00
    LDA $7001, X
    STA $02
    LDA $7010, X
    STA $04
    LDA $7011, X
    STA $06
    LDY #$0007

  loc_02874B:
    LDA #$00
    ROL $06
    ROL 
    ROL $04
    ROL 
    ROL $02
    ROL 
    ROL $00
    ROL 
    ORA $10
    STA ($5E)
    INC $5E
    BNE loc_028763
    INC $5F

  loc_028763:
    DEY 
    BPL loc_02874B
    INX 
    INX 
    DEC $12
    BPL loc_028734
    REP #$20
    TXA 
    CLC 
    ADC #$0010
    TAX 
    SEP #$20
    CPX #$2000
    BCC loc_028726
    PLB 
    LDX #$0000
    STX $2116
    LDA #$80
    STA $2115
    LDA #$00
    STA $4300
    LDA #$19
    STA $4301
    LDX #$A000
    STX $4302
    LDA #$7E
    STA $4304
    LDX #$4000
    STX $4305
    LDA #$01
    STA $420B
    PLY 
    PLP 
    RTS 
}

code_0287AA {
    PHP 
    REP #$20
    LDA #$0000
    TAY 

  loc_0287B1:
    STA $S_metatileEffectLayer, Y
    INY 
    INY 
    CPY #$0100
    BCC loc_0287B1
    LDY #$2800
    STY $3E
    LDY #$0000
    SEP #$20

  loc_0287C5:
    LDA $S_metatileMapLayer, Y
    STA $3E
    LDA $2001, Y
    ASL 
    ASL 
    AND #$70
    STA ($3E)
    INY 
    INY 
    CPY #$0800
    BCC loc_0287C5
    LDY #$2800
    STY $3E
    PLP 
    RTS 
}

code_0287E1 {
    PHP 
    REP #$20
    JSR $&code_028DFF
    ASL 
    STA $0664
    JSR $&code_028DFF
    ASL 
    STA $0666
    JSR $&code_028DFF
    ASL 
    STA $0668
    CMP #$0020
    BEQ loc_028813
    LDX #$003E
    JSR $&code_028EA7
    LDX #$0A00
    STX $42
    LDA #$007F
    STA $44
    JSR $&code_028F02
    PLP 
    RTS 

  loc_028813:
    LDX #$003E
    JSR $&code_028EA7
    LDX #$0A00
    STX $42
    LDA #$007F
    STA $44
    JSR $&code_028F02
    LDA $7F0A20
    STA $cgramPalette
    PLP 
    RTS 
}

code_028830 {
    PHP 
    REP #$20
    JSR $&code_028DFF
    XBA 
    LSR 
    LSR 
    STA $0664
    JSR $&code_028DFF
    XBA 
    LSR 
    LSR 
    STA $0666
    JSR $&code_028DFF
    XBA 
    LSR 
    LSR 
    STA $0668
    JSR $&code_028DFF
    STA $066A
    LDX #$003E
    JSR $&code_028EA7
    LDA #$0001
    AND $066A
    BEQ loc_028870
    LDX #$0678
    JSR $&code_028ED9
    BCS loc_028870
    LDA #$0001
    TRB $066A

  loc_028870:
    LDA #$0002
    AND $066A
    BEQ loc_028886
    LDX #$067B
    JSR $&code_028ED9
    BCS loc_028886
    LDA #$0002
    TRB $066A

  loc_028886:
    LDA $066A
    BEQ loc_0288D8
    LDA [$3E]
    STA $78
    INC $3E
    INC $3E
    BEQ loc_0288A8
    LDX #$7000
    STX $7A
    JSL $@code_028395
    LDX #$7000
    STX $3E
    LDA #$007E
    STA $40

  loc_0288A8:
    LSR $066A
    BCC loc_0288C0
    LDX #$2000
    STX $42
    LDA #$007E
    STA $44
    JSR $&code_028F02
    LDX #$0000
    JSR $&code_02908E

  loc_0288C0:
    LSR $066A
    BCC loc_0288D8
    LDX #$2800
    STX $42
    LDA #$007E
    STA $44
    JSR $&code_028F02
    LDX #$0002
    JSR $&code_02908E

  loc_0288D8:
    PLP 
    RTS 
}

code_0288DA {
    STZ $0664
    STZ $0665
    JSR $&code_028DFF
    STA $066A
    LDX #$003E
    JSR $&code_028EA7
    LDA $066A
    AND #$7F
    BEQ loc_02892B
    LDA #$01
    AND $066A
    BEQ loc_02890E
    LDA $06EF
    BIT #$08
    BNE loc_028936
    LDX #$067E
    JSR $&code_028ED9
    BCS loc_02890E
    LDA #$01
    TRB $066A

  loc_02890E:
    LDA #$02
    AND $066A
    BEQ loc_028922
    LDX #$0681
    JSR $&code_028ED9
    BCS loc_028922
    LDA #$02
    TRB $066A

  loc_028922:
    LDA $066A
    AND #$7F
    BEQ loc_02895A
    BRA loc_028936

  loc_02892B:
    LDA $066A
    BMI loc_028936
    STZ $067F
    STZ $0680

  loc_028936:
    REP #$20
    LDA [$3E]
    INC $3E
    AND #$00FF
    XBA 
    STA $00
    LDA [$3E]
    INC $3E
    AND #$00FF
    XBA 
    STA $02
    SEP #$20
    LDA $066A
    AND #$7F
    BNE loc_028958
    JMP $&code_028A44

  loc_028958:
    BRA loc_02895B

  loc_02895A:
    RTS 

  loc_02895B:
    REP #$20
    LDA [$3E]
    STA $78
    STA $0666
    INC $3E
    INC $3E
    CMP #$0000
    BEQ loc_0289D3
    SEP #$20
    LDA $066A
    BIT #$01
    BEQ loc_0289AC
    LDX #$0000
    JSR $&code_0289B3
    LDA $066A
    BIT #$02
    BEQ loc_0289B2
    LDX #$A000
    STX $3E
    LDA #$7E
    STA $40
    LDX #$C000
    STX $42
    LDA #$7E
    STA $44
    JSR $&code_028F02
    LDA $01
    STA $0695
    XBA 
    LDA $03
    STA $0699
    JSL $@code_0282F6
    STA $069D
    BRA loc_0289B2

  loc_0289AC:
    LDX #$0002
    JSR $&code_0289B3

  loc_0289B2:
    RTS 
}

code_0289B3 {
    LDA $01
    STA $0693, X
    XBA 
    LDA $03
    STA $0697, X
    JSL $@code_0282F6
    STA $069B, X
    REP #$20
    LDA $069E, X
    STA $7A
    JSL $@code_028395
    SEP #$20
    RTS 

  loc_0289D3:
    SEP #$20
    LDA $01
    XBA 
    LDA $03
    JSL $@code_0282F6
    STZ $0666
    STA $0667
    LDA $066A
    BIT #$01
    BEQ loc_028A22
    LDX #$A000
    STX $42
    LDA #$7E
    STA $44
    LDX #$0000
    JSR $&code_028A32
    LDA $066A
    BIT #$02
    BEQ loc_028A31
    LDX #$A000
    STX $3E
    LDA #$7E
    STA $40
    LDX #$C000
    STX $42
    LDA #$7E
    STA $44
    JSR $&code_028F02
    LDX $00
    STX $0694
    LDX $02
    STX $0698
    BRA loc_028A31

  loc_028A22:
    LDX #$C000
    STX $42
    LDA #$7E
    STA $44
    LDX #$0002
    JSR $&code_028A32

  loc_028A31:
    RTS 
}

code_028A32 {
    REP #$20
    LDA $00
    STA $0692, X
    LDA $02
    STA $0696, X
    JSR $&code_028F02
    SEP #$20
    RTS 
}

code_028A44 {
    REP #$20
    LDA [$3E]
    INC $3E
    INC $3E
    STA $78
    CMP #$0000
    BNE loc_028A61
    SEP #$20
    LDX $3E
    STX $4302
    LDA $40
    STA $4304
    BRA loc_028A77

  loc_028A61:
    SEP #$20
    LDX #$A000
    STX $7A
    JSL $@code_028395
    LDX #$A000
    STX $4302
    LDA #$7E
    STA $4304

  loc_028A77:
    STZ $2115
    LDX #$2000
    STX $2116
    LDA #$00
    STA $4300
    LDA #$18
    STA $4301
    LDX #$4000
    STX $4305
    LDA #$01
    STA $420B
    LDA #$80
    STA $2115
    RTS 
}

code_028A9B {
    PHY 
    PHB 
    LDA #$7E
    PHA 
    PLB 
    LDX #$0000
    REP #$20

  loc_028AA6:
    LDA #$0000
    STA $B000, X
    STA $B002, X
    STA $B004, X
    STA $B006, X
    TXA 
    CLC 
    ADC #$0008
    TAX 
    CPX #$4000
    BCC loc_028AA6
    SEP #$20
    LDA $0693
    STA $18
    LDA $0697
    CMP #$05
    BCC loc_028AD0
    LDA #$04

  loc_028AD0:
    STA $1C
    LDA #$00
    STA $0E
    STA $10
    LDY #$0000
    TYX 
    STX $00

  loc_028ADE:
    REP #$20
    TYA 
    CLC 
    ADC #$0100
    STA $14
    SEP #$20

  loc_028AE9:
    LDA #$0F
    STA $12

  loc_028AED:
    REP #$20
    LDA $S_mapLayerTilemap, Y
    PHY 
    AND #$00FF
    ASL 
    ASL 
    ASL 
    TAY 
    SEP #$20
    LDA $S_metatileMapLayer, Y
    STA $B000, X
    LDA $2002, Y
    STA $B001, X
    LDA $2004, Y
    STA $B080, X
    LDA $2006, Y
    STA $B081, X
    PLY 
    INY 
    INX 
    INX 
    DEC $12
    BPL loc_028AED
    REP #$20
    TXA 
    CLC 
    ADC #$00E0
    TAX 
    SEP #$20
    CPY $14
    BCC loc_028AE9
    REP #$20
    LDA $00
    CLC 
    ADC #$0020
    STA $00
    TAX 
    SEP #$20
    LDA $0E
    INC 
    STA $0E
    CMP $18
    BCC loc_028ADE
    STZ $0E
    LDA $10
    INC 
    STA $10
    CMP $1C
    BCS loc_028B5A
    REP #$20
    AND #$00FF
    XBA 
    ASL 
    ASL 
    ASL 
    ASL 
    STA $00
    TAX 
    BRA loc_028ADE

  loc_028B5A:
    PLB 
    STZ $2115
    LDX #$0000
    STX $2116
    LDX #$B000
    STX $4302
    LDA #$7E
    STA $4304
    LDA #$00
    STA $4300
    LDA #$18
    STA $4301
    LDX #$4000
    STX $4305
    LDA #$01
    STA $420B
    LDA #$80
    STA $2115
    PLY 
    RTL 
}

code_028B8B {
    JSR $&code_028DFF
    PHY 
    REP #$20
    AND #$00FF
    ASL 
    TAX 
    LDA $@table_018000, X
    SEC 
    SBC #$8000
    TAX 
    SEP #$20
    LDA $@table_018000, X
    STA $212C
    STA $212E
    LDA $@table_018000+1, X
    STA $212D
    STA $212F
    LDA $@table_018000+2, X
    STA $2130
    LDA $@table_018000+3, X
    STA $2131
    LDA $@table_018000+4, X
    AND #$30
    STA $06F1
    LDA $@table_018000+4, X
    STZ $06A3
    STZ $06A5
    LDY #$2000
    ROR 
    BCC loc_028BDF
    STY $06A2

  loc_028BDF:
    ROR 
    BCC loc_028BE5
    STY $06A4

  loc_028BE5:
    ROR 
    ROR 
    ROR 
    ROR 
    ROR 
    LDY #$00E0
    BCC loc_028BF2
    LDY #$0100

  loc_028BF2:
    STY $06EC
    ROR 
    BCS loc_028BFD
    LDA #$01
    TSB $06A5

  loc_028BFD:
    REP #$20
    LDA $06A2
    CMP $06A6
    BEQ code_028C0A
    STZ $0679

  code_028C0A:
    STA $06A6
    LDA $06A4
    CMP $06A8
    BEQ loc_028C18
    STZ $067C

  loc_028C18:
    STA $06A8
    SEP #$20
    LDA $@table_018000+5, X
    STA $06EE
    BMI loc_028C40
    LDA $06EE
    AND #$03
    CLC 
    ADC #$10
    STA $2107
    LDA $06EE
    LSR 
    LSR 
    AND #$03
    CLC 
    ADC #$18
    STA $2108
    BRA loc_028C58

  loc_028C40:
    LDA $06EE
    AND #$03
    CLC 
    ADC #$18
    STA $2107
    LDA $06EE
    LSR 
    LSR 
    AND #$03
    CLC 
    ADC #$10
    STA $2108

  loc_028C58:
    LDA $@table_018000+6, X
    STA $2105
    LDA $@table_018000+7, X
    PHA 
    AND #$1F
    STA $06EF
    BIT #$08
    BEQ loc_028C70
    STZ $066E

  loc_028C70:
    LDA #$40
    TRB $09FB
    PLA 
    BPL loc_028C7D
    LDA #$40
    TSB $09FB

  loc_028C7D:
    LDA $@table_018000+8, X
    LDA $@table_018000+9, X
    PLY 
    RTS 
}

code_028C87 {
    INY 
    INY 
    INY 
    RTS 
}

code_028C8B {
    JSR $&code_028DFF
    STA $06F2
    JSR $&code_028DFF
    STA $06F4
    LDX #$003E
    JSR $&code_028EA7
    LDA $06F6
    CMP $06F4
    BEQ loc_028CA6
    RTS 

  loc_028CA6:
    LDX #$0687
    JSR $&code_028ED9
    BCS loc_028CAF
    RTS 

  loc_028CAF:
    LDA $0D72
    BEQ loc_028CBF
    LDA #$F2
    STA $2140
    LDA #$20
    JSL $@code_0282EE

  loc_028CBF:
    LDA #$F0
    STA $2140

  loc_028CC4:
    LDA $2140
    BNE loc_028CC4
    LDA #$02
    JSL $@code_0282EE
    LDA #$FF
    STA $2140
    LDA #$02
    JSL $@code_0282EE
    LDX $3E
    STX $46
    LDX $40
    STX $48
    JSL $@code_02915C
    LDA #$01
    STA $0D72
    LDA #$03
    JSL $@code_0282EE
    LDA $06F2
    BEQ loc_028CF8
    LDA #$01

  loc_028CF8:
    STA $2140
    RTS 
}

code_028CFC {
    PHP 
    REP #$20
    LDA [$3A], Y
    STA $0666
    SEP #$20
    INY 
    INY 
    INY 
    LDX #$003E
    JSR $&code_028EA7
    LDX #$0684
    JSR $&code_028ED9
    BCC loc_028D31
    REP #$20
    LDA [$3E]
    INC $3E
    INC $3E
    CMP #$0000
    BEQ loc_028D33
    STA $78
    SEP #$20
    LDX #$4000
    STX $7A
    JSL $@code_028395

  loc_028D31:
    PLP 
    RTS 

  loc_028D33:
    STZ $0664
    STZ $0668
    LDX #$4000
    STX $42
    LDA #$007E
    STA $44
    JSR $&code_028F02
    PLP 
    RTS 
}

code_028D48 {
    PHP 
    JSR $&code_028DFF
    STA $066A
    LDX #$003E
    JSR $&code_028EA7
    REP #$20
    LDA [$3E]
    STA $00
    INC $3E
    INC $3E
    LDA [$3E]
    XBA 
    ORA $00
    INC $3E
    INC $3E
    SEP #$20
    JSL $@code_0282F6
    REP #$20
    STA $00
    XBA 
    ASL 
    ASL 
    ASL 
    STA $0666
    LDA [$3E]
    INC $3E
    INC $3E
    BEQ loc_028D99
    STA $78
    SEP #$20
    LDX #$7000
    STX $7A
    JSL $@code_028395
    LDX #$7000
    STX $3E
    LDA #$7E
    STA $40
    BRA loc_028D9F

  loc_028D99:
    INC $3E
    INC $3E
    SEP #$20

  loc_028D9F:
    LDA $066A
    BPL loc_028DB2
    AND #$7F
    XBA 
    LDA #$00
    REP #$20
    ASL 
    ASL 
    STA $2116
    BRA loc_028DDC

  loc_028DB2:
    REP #$20
    AND #$00FF
    BIT #$0001
    BEQ code_028DC8
    LDA #$1000
    STA $2116
    PEA $&code_028DC8-1
    PHP 
    BRA loc_028DDC
}

code_028DC8 {
    REP #$20
    LDA $066A
    BIT #$0002
    BEQ loc_028DDA
    LDA #$1800
    STA $2116
    BRA loc_028DDC

  loc_028DDA:
    PLP 
    RTS 

  loc_028DDC:
    SEP #$20
    LDA #$01
    STA $4300
    LDA #$18
    STA $4301
    LDX $3E
    STX $4302
    LDA $40
    STA $4304
    LDX $0666
    STX $4305
    LDA #$01
    STA $420B
    PLP 
    RTS 
}

code_028DFF {
    PHP 
    SEP #$20
    LDA #$00
    XBA 
    LDA [$3A], Y
    INY 
    PLP 
    RTS 
}

code_028E0A {
    LDY #$0000

  loc_028E0D:
    LDA [$3A], Y
    INY 
    INY 
    CMP $0644
    BNE loc_028E17
    RTS 

  loc_028E17:
    SEP #$20
    LDA [$3A], Y
    INY 
    CMP #$00
    BEQ loc_028E0D
    CMP #$13
    BEQ loc_028E51
    CMP #$02
    BEQ loc_028E52
    CMP #$03
    BEQ loc_028E4C
    CMP #$04
    BEQ loc_028E4D
    CMP #$05
    BEQ loc_028E4C
    CMP #$06
    BEQ loc_028E4F
    CMP #$0E
    BEQ loc_028E50
    CMP #$10
    BEQ loc_028E4D
    CMP #$11
    BEQ loc_028E4E
    CMP #$14
    BEQ loc_028E52
    CMP #$15
    BEQ loc_028E52

  loc_028E4C:
    INY 

  loc_028E4D:
    INY 

  loc_028E4E:
    INY 

  loc_028E4F:
    INY 

  loc_028E50:
    INY 

  loc_028E51:
    INY 

  loc_028E52:
    INY 
    BRA loc_028E17
}

code_028E55 {
    JSR $&code_028DFF
    PHA 
    LDY #$0000
    INY 
    INY 

  loc_028E5E:
    LDA [$3A], Y
    INY 
    CMP #$F000
    SBC [$C9], Y
    COP #$F0
    AND ($C9)
    ORA $F0, S
    PLP 
    CMP #$F004
    AND $C9
    ORA $F0
    JSR $06C9
    BEQ loc_028E98
    CMP #$F00E
    TRB $10C9
    BEQ loc_028E96
    CMP #$F011
    ORA ($C9)
    ORA ($F0)
    TRB $13C9
    BEQ loc_028E9A
    CMP #$F014
    ORA $15C9
    BEQ loc_028E9B
    INY 

  loc_028E96:
    INY 
    INY 

  loc_028E98:
    INY 
    INY 

  loc_028E9A:
    INY 

  loc_028E9B:
    INY 
    BRA loc_028E5E

  loc_028E9E:
    LDA [$3A], Y
    INY 
    CMP $01, S
    BNE loc_028E5E
    PLA 
    RTS 
}

code_028EA7 {
    PHP 
    REP #$20
    LDA [$3A], Y
    INY 
    INY 
    STA $0000, X
    SEP #$20
    LDA [$3A], Y
    INY 
    STA $0002, X
    CMP #$70
    BCS loc_028ED7
    CLC 
    ADC #$80
    CMP #$A0
    BCC loc_028ED4
    CLC 
    ADC #$20
    STA $0002, X
    LDA $0001, X
    AND #$7F
    STA $0001, X
    BRA loc_028ED7

  loc_028ED4:
    STA $0002, X

  loc_028ED7:
    PLP 
    RTS 
}

code_028ED9 {
    PHP 
    REP #$20
    LDA $3E
    CMP $0000, X
    BNE loc_028EF1
    SEP #$20
    LDA $40
    CMP $0002, X
    BNE loc_028EF1
    REP #$20
    PLP 
    CLC 
    RTS 

  loc_028EF1:
    SEP #$20
    LDA $40
    STA $0002, X
    REP #$20
    LDA $3E
    STA $0000, X
    PLP 
    SEC 
    RTS 
}

code_028F02 {
    PHP 
    PHX 
    PHY 
    SEP #$20
    LDA $40
    STA $0405
    LDA $44
    STA $0404
    REP #$20
    LDA $3E
    CLC 
    ADC $0664
    TAX 
    LDA $42
    CLC 
    ADC $0668

  code_028F20:
    TAY 
    LDA $0666
    SEC 
    SBC $0664
    DEC 
    JSR $0402
    PLY 
    PLX 
    PLP 
    RTS 
}

code_028F30 {
    LDX #$0000

  loc_028F33:
    LDA $3E
    CMP $0084, X
    BEQ loc_028F44

  loc_028F3A:
    INX 
    INX 
    INX 
    CPX #$000C
    BNE loc_028F33
    CLC 
    RTS 

  loc_028F44:
    SEP #$20
    LDA $40
    CMP $0086, X
    BEQ loc_028F51
    REP #$20
    BRA loc_028F3A

  loc_028F51:
    REP #$20
    SEC 
    RTS 
}

code_028F55 {
    LDX $0094
    TXA 
    INC 
    AND #$0003
    STA $0094
    TXA 
    PHA 
    ASL 
    CLC 
    ADC $01, S
    TAX 
    PLA 
    LDA $003E
    STA $0084, X
    SEP #$20
    LDA $0040
    STA $0086, X
    REP #$20
    RTS 
}

code_028F79 {
    PHY 
    LDA $0668
    XBA 
    STA $2116
    LDA $0666
    CMP #$2001
    BMI loc_028F95
    SEC 
    SBC #$2000
    STA $0666
    LDA #$2000
    BRA loc_028F98

  loc_028F95:
    STZ $0666

  loc_028F98:
    JSR $&code_028FD9
    LDA $0666
    BEQ loc_028FD7
    PHA 
    LDY $0094
    TYA 
    INC 
    CMP #$0004
    BCC loc_028FAE
    LDA #$0000

  loc_028FAE:
    STA $0094
    TYA 
    PHA 
    ASL 
    CLC 
    ADC $01, S
    TAY 
    PLA 
    LDA #$FFFF
    STA $0084, Y
    SEP #$20
    LDA #$FF
    STA $0086, Y
    REP #$20
    LDA $0668
    XBA 
    CLC 
    ADC #$1000
    STA $2116
    PLA 
    JSR $&code_028FD9

  loc_028FD7:
    PLY 
    RTS 
}

code_028FD9 {
    PHP 
    STA $4305
    JSR $&code_029004
    TAY 
    LDA $2139
    SEP #$20
    STY $4302
    LDA #$7F
    STA $4304
    LDA #$81
    STA $4300
    LDA #$39
    STA $4301
    LDA #$01
    STA $420B
    LDA #$01
    STA $4300
    PLP 
    RTS 
}

code_029004 {
    LDA $0094
    DEC 
    ROR 
    ROR 
    ROR 
    ROR 
    AND #$6000
    CLC 
    ADC #$4000
    RTS 
}

code_029014 {
    PHY 
    LDA $@code_029FBC, X
    AND #$00FF
    PHA 
    ROR 
    ROR 
    ROR 
    ROR 
    AND #$6000
    CLC 
    ADC #$4000
    TAX 
    LDA $0666
    SEC 
    SBC $0664
    CMP #$2001
    BCS loc_02903C
    TAY 
    JSR $&code_029068
    PLA 
    PLY 
    RTS 

  loc_02903C:
    SEC 
    SBC #$2000
    PHA 
    LDA #$2000
    TAY 
    JSR $&code_029068
    LDA $0668
    CLC 
    ADC #$0010
    STA $0668
    LDA $03, S
    INC 
    ROR 
    ROR 
    ROR 
    ROR 
    AND #$6000
    CLC 
    ADC #$4000
    TAX 
    PLA 
    JSR $&code_029068
    PLA 
    PLY 
    RTS 
}

code_029068 {
    LDA $0668
    XBA 
    STA $2116
    STX $4302
    STY $4305
    SEP #$20
    LDA #$01
    STA $4300
    LDA #$18
    STA $4301
    LDA #$7F
    STA $4304
    LDA #$01
    STA $420B
    REP #$20
    RTS 
}

code_02908E {
    PHP 
    SEP #$20
    PHB 
    PHY 
    LDA #$7E
    PHA 
    PLB 
    LDY $06AA, X
    STY $42
    LDA #$7F
    STA $44
    LDY $06AE, X
    LDA #$00
    STA $0E

  loc_0290A7:
    LDA #$04
    STA $10

  loc_0290AB:
    LDA $0001, Y
    AND #$02
    PHA 
    REP #$20
    LDA $0000, Y
    AND #$FDFF
    ORA $06A2, X
    STA $0000, Y
    SEP #$20
    INY 
    INY 
    DEC $10
    BNE loc_0290AB
    PLA 
    ASL 
    ORA $01, S
    ASL 
    ORA $02, S
    ASL 
    ORA $03, S
    LSR 
    STA [$42]
    INC $42
    PLA 
    PLA 
    PLA 
    DEC $0E
    BNE loc_0290A7
    PLY 
    PLB 
    PLP 
    RTS 
}

code_0290E1 {
    LDX #$0000
    JSR $&code_0290F5
    LDA $06EF
    BIT #$01
    BEQ loc_0290F4
    LDX #$0002
    JSR $&code_029121

  loc_0290F4:
    RTS 
}

code_0290F5 {
    LDY $06AA
    STY $3E
    LDA #$7F
    STA $40
    LDA $0693
    XBA 
    LDA $0697
    JSL $@code_0282F6
    XBA 
    TAY 
    BEQ loc_029120
    LDX $069E

  loc_029110:
    LDA $7E0000, X
    STA $3E
    LDA [$3E]
    STA $7F2000, X
    INX 
    DEY 
    BNE loc_029110

  loc_029120:
    RTS 
}

code_029121 {
    LDY $06AC
    STY $3E
    LDA #$7F
    STA $40
    LDA $0695
    XBA 
    LDA $0699
    JSL $@code_0282F6
    XBA 
    TAY 
    BEQ loc_02914E
    LDX $0080

  loc_02913C:
    LDA $7E0000, X
    STA $3E
    LDA [$3E]
    BEQ loc_02914A
    STA $animScratch, X

  loc_02914A:
    INX 
    DEY 
    BNE loc_02913C

  loc_02914E:
    RTS 
}

code_02914F {
    LDX #$92D1
    STX $46
    LDA #$82
    STA $48
    JSR $&code_02925C
    RTL 
}

code_02915C {
    PHP 
    PHY 
    JSR $&code_02925C
    DEY 
    DEY 
    SEP #$20
    LDA #$FF
    STA $2140
    LDA #$CC
    STA $30
    REP #$20
    LDA #$BBAA

  loc_029173:
    CMP $2140
    BNE loc_029173
    LDA [$46], Y
    INY 
    INY 
    STA $2E
    LDA [$46], Y
    INY 
    STY $32
    AND #$00FF
    STA $28
    STZ $2C

  code_02918A:
    REP #$20
    LDX #$0000
    STX $4A
    SEP #$20
    LDA #$C5
    STA $4C
    LDY $32
    LDA [$46], Y
    INY 
    STY $32
    STA $2A
    STZ $2B
    BIT #$80
    BEQ loc_0291A9
    JMP $&code_029214

  loc_0291A9:
    REP #$20
    LDA $2E
    CLC 
    ADC $2C
    STA $2E

  loc_0291B2:
    LDA [$4A]
    STA $2C
    STA $34
    INC $4A
    INC $4A
    LDA $2A
    BEQ loc_0291D4
    DEC $2A
    LDA $4A
    CLC 
    ADC $2C
    STA $4A
    BPL loc_0291B2
    AND #$7FFF
    STA $4A
    INC $4C
    BRA loc_0291B2

  loc_0291D4:
    LDY $4A
    STZ $4A
    SEP #$20
    LDA $30
    BRA loc_029221

  loc_0291DE:
    LDA [$4A], Y
    INY 
    BPL loc_0291E8
    LDY #$0000
    INC $4C

  loc_0291E8:
    XBA 
    LDA #$00
    BRA loc_0291FF

  loc_0291ED:
    XBA 
    LDA [$4A], Y
    INY 
    BPL loc_0291F8
    LDY #$0000
    INC $4C

  loc_0291F8:
    XBA 

  loc_0291F9:
    CMP $2140
    BNE loc_0291F9
    INC 

  loc_0291FF:
    REP #$20
    STA $2140
    SEP #$20
    DEX 
    BNE loc_0291ED

  loc_029209:
    CMP $2140
    BNE loc_029209

  loc_02920E:
    ADC #$03
    BEQ loc_02920E
    STA $30
}

code_029214 {
    DEC $28
    BEQ loc_02921B
    JMP $&code_02918A

  loc_02921B:
    STZ $2C
    STZ $2D
    LDA $30

  loc_029221:
    PHA 
    REP #$20
    LDA $2C
    TAX 
    LDA $2E
    STA $2142
    SEP #$20
    CPX #$0001
    LDA #$00
    ROL 
    STA $2141
    ADC #$7F
    JSL $@code_0282C7
    PLA 
    STA $2140

  loc_029241:
    CMP $2140
    BNE loc_029241
    LDA $0654
    CMP #$0F
    BNE loc_029251
    JSL $@code_0282B6

  loc_029251:
    BVS loc_0291DE
    STZ $2141
    STZ $2142
    PLY 
    PLP 
    RTL 
}

code_02925C {
    PHP 
    REP #$20
    LDY #$0000
    LDA #$BBAA

  loc_029265:
    CMP $APUIO0
    BNE loc_029265
    SEP #$20
    LDA #$CC
    BRA loc_029296

  loc_029270:
    LDA [$46], Y
    INY 
    XBA 
    LDA #$00
    BRA loc_029283

  loc_029278:
    XBA 
    LDA [$46], Y
    INY 
    XBA 

  loc_02927D:
    CMP $APUIO0
    BNE loc_02927D
    INC 

  loc_029283:
    REP #$20
    STA $APUIO0
    SEP #$20
    DEX 
    BNE loc_029278

  loc_02928D:
    CMP $APUIO0
    BNE loc_02928D

  loc_029292:
    ADC #$03
    BEQ loc_029292

  loc_029296:
    PHA 
    REP #$20
    LDA [$46], Y
    INY 
    INY 
    TAX 
    LDA [$46], Y
    INY 
    INY 
    STA $APUIO2
    SEP #$20
    JSL $@code_0282C7
    CPX #$0001
    LDA #$00

  loc_0292B0:
    ROL 
    STA $APUIO1
    ADC #$7F
    PLA 
    STA $APUIO0

  loc_0292BA:
    CMP $APUIO0
    BNE loc_0292BA
    LDA $worldReadyFlag
    CMP #$0F
    BNE loc_0292CA
    JSL $@code_0282B6

  loc_0292CA:
    BVS loc_029270
    STZ $APUIO2
    PLP 
    RTS 
}

code_0292D1 {
    STA [$0B], Y
    BRK #$04
    JSR $&code_02CFCD
    LDA $00E8, X
    EOR $&binary_01C36C.binary_01C77D+132, X
    BEQ loc_0292B0
    XCE 
    LDY $&01E93F, X
    ORA #$A2
    PHA 
    INX 
    RTS 
}

code_0292E9 {
    STA $3F0C
    LDA $@palette_1B4166+14B9F, X
    AND $@2805BF, X
    BPL loc_029283
    EOR $&table_01B06E.delta_node_01BF3C+3, X
    ORA $E8
    BMI loc_0292C1
    SBC ($E8), Y
    BPL loc_0292C5
    PLX 
    CPY $53
    INX 
    ORA ($C4, X)
    SBC ($E4), Y
    ROL $48, X
    SBC $@gfx_ruins+17EF, X
    SEC 
    STA $&stats_table+132
    ORA $F0
    ORA [$B0]
    PHP 
    ADC #$4D
    JMP $0FD0
    SBC $4C, S
    TSB $&table_01AD90+66
    ORA $&01F2C4
    INC $B7, X
    ORA $&01E65D
    CPY $F3
    INC $&music_array+4D, X
    EOR $CB
    LSR $EB
    SBC $&01FCF0, X
    ADC $40E8
    CMP $@chunk_038000.code_list_038431+2F
    CPY $43
    BCC loc_029352
    SBC $FD
    ORA $@301468
    ORA $3F, S
    BEQ loc_029358
    ADC #$4D
    JMP $02F0
    PLB 
    JMP $53E4
    RTS 
}

code_029355 {
    STY $F5
    INC $60CF
    STY $51
    CPY $51
    BCC loc_029379
    AND $@2406B2, X
    BMI loc_029356
    ASL 
    PHB 
    AND ($D0), Y
    ASL $8F
    BRK #$04
    AND $@gfx_credits_actors2+5EF, X
    BRK #$3F
    LDA $5F04, X
    AND ($04, S), Y

  loc_029379:
    CPX $04
    BEQ loc_02938F
    CMP $&208F00
    ORA ($47, X)
    PEA $&code_02F0D6-1
    ORA $3F, S
    STA ($0C, X)
    AND $0B3D, X
    EOR [$D0]
    SBC ($5F, S), Y
    AND ($04, S), Y
    PEA $&code_02D405-1
    PEA $&code_02F4F5-1
    STZ $F4, X
    BNE loc_029396
    PEI ($00)

  loc_02939E:
    ADC $@gfx_pyramid+54C
    ORA $3F
    ORA $&208D08, X
    LDY $AD
    INY 
    BCS loc_02939E

  loc_0293AC:
    CPX $1A
    BIT $47
    BNE loc_02939E
    CMP $7F28, X
    RTS 
}

code_0293B6 {
    STY $50
    RTS 
}

code_0293B9 {
    STA $F0, X
    COP [RemoveItem] ( #7D )
    ORA $F5, S
    LDA $03
    CMP $7C, X
    ORA $F5, S
    LDA ($02, X)
    JML $@code_3C00E8
}

code_0293CC {
    CMP $8C, X
    COP #$E8
    BRK #$D4
    LDY $00D5
    ORA ($D5, X)
    INY 
    COP [GiveItem] ( #C0, $4709 )
    LSR $4709, X
    EOR $F5
    STZ $02
    PEI ($98)
    BEQ loc_029406
    SBC $65, X
    COP [GiveItem] ( #99, $78F5 )
    COP [BranchIfFlagByte] ( #0A, #F5, $037D )
    BRA loc_0293AC

  loc_0293F7:
    ADC $&20D502, Y
    ADC $&20F503, X
    ADC $6002, Y
    STA $7D, X
    ORA $3F, S
    EOR $0A, X

  loc_029406:
    AND $8D0A6D, X
    BRK #$E4
    ORA ($80), Y
    TAY 

  loc_02940F:
    BIT $B0, X
    ORA #$E4
    ORA ($80), Y
    TAY 
    ORA ($B0, S), Y
    ASL $DC
    TRB $107A
    PHX 
    BPL loc_02946D
    CPX $11
    TRB $008D
    CMP $&209E18
    EOR $&20C3F6, X
    ORA $15C4
    INC $C2, X
    ORA $14C4
    INC $C5, X
    ORA $&20F62D
    CPY $0D
    INC $149A
    XBA 
    BPL loc_02940F
    CMP $008D, X
    PLY 
    TRB $CB
    ORA $1C, X
    PLD 
    ORA $C4, X
    TRB $2F
    TSB $4B
    ORA $7C, X
    AND $forcedScrollOverride, X
    BNE loc_02944E
    CPY $14
    DEC $28F5
    COP #$EB
    ORA $CF, X
    PHX 
    ASL $F5, X
    PLP 
    COP #$EB
    TRB $CF
    ADC $29F5
    COP #$EB
    TRB $CF
    PLY 
    ASL $DA, X
    ASL $F5, X
    AND #$EB02
    ORA $CF, X
    SBC $7AAE, X
    ASL $DA, X
    ASL $F5, X
    JML [$080D]
    COP #$FD
    CPX $16
    AND $@3C05B7, X
    CPX $17
    AND $47E4
    BIT $1A
    LDX $04D0
    WAI 
    SBC ($C4)
    SBC ($6F, S), Y
    STA $&20F700
    RTI 
    DEC 
    RTI 
    AND $40F7
    DEC 
    RTI 
    SBC $6FAE, X
    STA $8F30FF
    ADC $@ec0A_caring_maid.h_ec0A_caring_maid+7, X
    ADC $@3EE52D
    ORA $@map_gs2F+34
    PHX 
    TSC 
    INX 
    BRK #$5D

  loc_0294BC:
    CMP [$3B]
    DEC 
    TSC 
    BNE loc_0294BC
    LDX $&208F6F
    SBC $@chunk_008000.loc_008F41+5, X
    TSB $A2
    PHA 
    REP #$48
    INX 
    BRK #$C4
    SBC $C4
    SBC [$E8]
    ORA ($3F, X)
    SBC #$6F09
    REP #$48
    ADC $0F563F
    CPY $08
    CPY $04
    ADC $@30F068
    STP 
    PLA 
    SBC ($F0), Y
    TSX 
    PLA 
    SBC ($F0)
    SBC #$FF68
    BEQ loc_0294DD
    ADC $@28F4E4
    BCC loc_0294EB
    ORA ($68)
    STA ($F0), Y
    ORA ($80)
    TAY 
    BPL loc_02956C
    BVS loc_0294B6
    ASL $1C
    CPY $3E
    STA $@2F5EFF
    STA $@2F3201
    STA $@2F3200
    CPY $04
    TRB $2EF0
    PLA 
    COP [BranchIfFlagByte] ( #D7, #3F, $05DB )
    SBC $FC
    ORA $@gfx_ending_credits+1067
    PHX 
    RTI 
    DEC 
    RTI 
    DEC 
    RTI 
    STA $@280C02
    BRK #$C4
    BMI loc_0294FA
    EOR $@gfx_ruins+78F, X
    AND $C4, X
    ROL $C4, X
    SBC $C4
    SBC [$C4]
    AND $3EC4, X
    CPY $F5
    CMP ($48)
    CPX $1A
    PHA 
    SBC $00460E, X
    ADC $8F0ECD
    BRA loc_02959D

  loc_029556:
    INX 
    SBC $0305D5, X
    INX 
    ASL 
    AND $@bgm_golden_road+889, X
    ORA $02, X
    CMP $A5, X
    ORA $D5, S
    BEQ loc_02956B
    CMP $64, X

  loc_02956B:
    COP [GiveItem] ( #AD, &code_02C1D4 )
    ORA $4B1D, X
    EOR [$D0]
    CPX #$5AC4
    CPY $68
    CPY $54
    CPY $50
    CPY $42
    STA $8F59C0
    JSR $6F53
    XBA 
    PHP 
    CPX $00
    PLA 
    BEQ loc_02951E
    ORA $5F, S
    BPL loc_029598
    CPY $08
    ROR $&20F000, X
    ORA $5F, S
    EOR ($06, X)
    CPX $04

  loc_02959D:
    BEQ loc_029586
    CMP ($48)
    CPX $0C
    BEQ loc_029603
    ROR $&20A90C

  loc_0295A8:
    PLX 
    AND $3FF5, X
    CPY $05
    BNE loc_0295D0
    SBC $09D0, X
    STA $8F3DFF
    SBC $@gfx_dao+58D, X
    ASL $8B
    WDM 
    BPL loc_0295C5
    CPY $42
    STA $3F3D00
    CPY $05
    SED 
    WDM 
    BEQ loc_0295A8
    PHX 
    RTI 
    AND $@3DABD8
    PHX 
    ASL $8D, X
    ORA $@map_pyramid_vader_a+6B3
    PEI ($00)
    JML [$&code_02F810]
    CMP $&208F00
    ORA ($47, X)

  loc_0295E3:
    PEA $&code_02F0D6-1
    ASL 
    SBC $15, X
    COP [BranchIfFlagByte] ( #05, #E8, $3F00 )
    ORA $&20E808, X
    BRK #$D5
    CLV 
    ORA $D4, S
    STY $D4
    STA $BC
    PEI ($70)
    AND $0B3D, X
    EOR [$D0]
    CPX #$00CD
    CLD 
    LSR $018F, X
    EOR [$D8]
    MVP #$F4, #$D5
    BEQ loc_02967C
    TXY 
    BVS loc_0295E3
    PER loc_02A955
    PHP 
    BNE loc_029636
    SBC $B8, X
    ORA $F0, S
    TXA 
    AND $@350981, X
    CLV 
    ORA $9C, S
    CMP $B8, X
    ORA $D0, S
    NOP 
    SBC $3C, X
    COP [GiveItem] ( #D4, $3DF5 )
    COP [GiveItem] ( #D5, &code_02DE2F )

  loc_029636:
    BMI loc_029658
    CMP $00, X
    COP [WaitUntilNoButton] ( #$0813 )
    BMI loc_029658
    AND $289F
    ORA [$FD]
    INC $00, X
    ORA ($D5, S), Y
    ORA ($02, X)
    LDX $0F28
    SBC $08F6, X
    ORA ($D5, S), Y
    TRB $02
    AND $@280813, X
    CPX #$0590
    AND $2F0801, X
    LDA ($3F, S), Y
    DEX 
    TSB $F5
    BRK #$02
    PEI ($70)
    SBC $01F5, X
    COP [ClearFlagWord] ( #$D0DD )
    ORA ($BC, X)
    PEI ($71)
    AND $A93F03
    PHD 
    AND $3D0A35, X
    AND $470B, X
    BNE loc_02960A
    CPX $30
    BEQ loc_029689
    STA $@245EFF
    MVN #$F0, #$0B
    TSX 
    LSR $7A, X
    EOR ($6E)
    MVN #$02, #$BA
    MVN #$DA, #$52
    CPX $68
    BEQ loc_0296B1
    TSX 
    STZ $7A
    RTS 
}

code_0296A0 {
    PHX 
    RTS 
}

code_0296A2 {
    TSX 
    ROR $7A
    PER loc_02FF16
    ASL $BA
    PLA 
    PHX 
    RTS 
}

code_0296AD {
    XBA 
    ROR 
    PHX 
    PER code_02F197
    BEQ loc_0296C3
    TSX 
    JML $@code_2E587A
}

code_0296BA {
    PHY 
    COP [ClearHFlip]
    PHY 
    PHX 
    CLI 
    STA $@gfx_southcape_effect+33D
    BRK #$8F
    ORA ($47, X)
    PEA $&code_02F0D6-1
    ORA $3F, S
    SBC $0A
    AND $0B3D, X
    EOR [$D0]
    SBC ($6F, S), Y
    TRB $&20F6FD
    CMP $09, X
    AND $&20D4F6
    ORA #$DD2D
    JML $@code_2AF6FD
}

code_0296E5 {
    ASL 
    BEQ loc_0296F0
    SBC [$D4]
    TYX 
    PEI ($D0)
    COP [SetHFlip]
    CMP $FD, X
    ADC $0215D5
    XBA 
    BIT $D0, X
    ORA ($FD), Y
    BPL loc_029702
    BRA loc_0296A6

  loc_0296FE:
    DEX 
    RTS 
}

code_029700 {
    STY $5F

  loc_029702:
    EOR $&20F55D
    CPX #$CE0F
    AND $@map_ir1E+17E
    ASL $80
    TAY 
    DEX 
    RTS 
}

code_029711 {
    STY $39
    STA $&20CF06
    PHX 
    TRB $60
    TYA 
    BRK #$14
    TYA 
    ORA ($15)
    CPX $1A
    BIT $47
    BNE loc_02975D
    EOR $&20DCF5
    ORA $extVelocityX
    EOR $008D, X
    SBC [$14], Y
    BPL loc_029740
    PLP 
    ORA $@sfx2C+361, X
    ASL $0048
    ORA #$4947
    CMP $072F, X

  loc_029740:
    CPX $47
    LSR $0049

  loc_029745:
    SBC [$14], Y
    CLD 
    SBC ($C4)
    SBC ($3D, S), Y
    JSR ($04AD, X)
    BNE loc_029745
    DEC $14F7
    CMP $29, X
    COP #$FC
    SBC [$14], Y
    CMP $28, X
    COP #$6F
    CMP $69, X
    ORA $28, S
    ORA $0341D5, X
    INX 
    BRK #$D5
    RTI 
    ORA $6F, S
    PEI ($85)
    AND $133F
    PHP 
    CMP $68, X
    ORA $80, S
    LDA $41, X
    ORA $CE, S
    AND $@spm_angkor_interior_sprites+130, X
    MVN #$03, #$DD
    CMP $55, X
    ORA $6F, S
    CMP $A0, X
    COP [WaitUntilNoButton] ( #$0813 )
    CMP $8D, X
    COP [WaitUntilNoButton] ( #$0813 )
    PEI ($AD)
    CMP $B5, X
    COP #$E8
    BRK #$D5
    LDA ($02, X)
    ADC $@code_02A1D5
    AND $008D
    PEA $&code_02CEAE-1
    STZ $44F8, X
    CMP $B4, X
    COP #$6F
    CMP $&20A880, X
    BRK #$FD
    INX 
    BRK #$DA
    CLI 
    ADC $3F5AC4
    ORA ($08, S), Y
    CPY $5B
    BRA loc_029763

  loc_0297BF:
    EOR $5AF8, Y
    AND $@set_babel_upper+464, X
    JML $@code_34E46F
}

code_0297CA {
    BNE loc_0297D0
    INX 
    BRK #$DA
    EOR ($6F)
    CPY $54
    AND $@gfx_darkspace+813, X
    EOR $80, X
    LDY $53
    SED 
    MVN #$3F, #$78
    ASL 
    PHX 
    LSR $6F, X
    CPY $50
    ADC $@code_02F0C1+14
    ADC $@loc_02DCCA+B
    AND $@bgm_golden_road+813, X
    CMP #$3F02
    ORA ($08, S), Y
    PEI ($C1)
    ADC $2F01E8
    COP #$E8
    BRK #$D5
    SEI 
    COP [PanCameraUp]
    CMP $65, X
    COP [WaitUntilNoButton] ( #$0813 )
    CMP $64, X
    COP [WaitUntilNoButton] ( #$0813 )
    CMP $79, X
    COP #$6F
    CMP $64, X
    COP #$6F
    CMP $05, X
    ORA $E8, S
    BRK #$D5
    TSB $03
    ADC $@2D84D4
    AND $@bgm_golden_road+813, X
    BIT $&208003
    LDA $05, X
    ORA $CE, S
    AND $@spm_angkor_interior_sprites+130, X
    CLC 
    ORA $DD, S
    CMP $19, X
    ORA $6F, S
    CMP $A5, X
    ORA $6F, S
    CMP $50, X
    COP [WaitUntilNoButton] ( #$0813 )
    CMP $51, X
    COP [WaitUntilNoButton] ( #$0813 )
    CMP $B8, X
    ORA $F4, S
    PEI ($D5)
    BIT $&20F402, X
    CMP $D5, X
    AND $&20F502, X
    BVC loc_02985B
    PEI ($D4)

  loc_02985B:
    SBC $51, X
    COP [GiveItem] ( #D5, &code_02C46F )
    LSR 
    AND $@280813, X
    BRK #$DA
    RTS 
}

code_02986A {
    AND $@280813, X
    BRK #$DA
    PER loc_02E125
    ADC $3F68C4
    ORA ($08, S), Y
    CPY $69
    BRA loc_029821

  loc_02987D:
    ADC ($F8, X)
    PLA 
    AND $@set_babel_upper+464, X
    STZ $3F
    ORA ($08, S), Y
    CPY $6A
    BRA loc_029830

  loc_02988C:
    ADC $F8, S
    PLA 
    AND $@set_babel_upper+464, X
    ROR $6F
    PHX 
    RTS 
}

code_029897 {
    PHX 
    PER loc_02E13D
    ADC $@09E93F
    AND $@gfx_darkspace+813, X
    LSR $133F
    PHP 
    STA $&20CF08
    EOR $0F8D, X

  loc_0298AD:
    SBC $8E, X
    ORA $&20BF3F
    ORA $3D
    CMP $&208860, X
    BPL loc_0298B6
    BPL loc_0298AD
    SED 
    MVP #$6F, #$C4
    EOR $7D8D
    WAI 
    SBC ($E4)
    SBC ($64, S), Y
    EOR $29F0
    PLP 
    ORA $@33FF48
    JMP $6003
    STY $4C
    CPY $4C
    STA $&20F604
    LDA $&20C40D
    SBC ($E8)
    BRK #$C4
    SBC ($FE, S), Y
    SBC $E4, X
    PHA 
    PHP 
    JSR $6C8D
    AND $@2405BF, X
    EOR $7D8D
    AND $1C05BF, X
    TRB $481C
    SBC $@3F8880, X
    STA $5F6D
    LDA $@34EB05, X
    BNE loc_029907
    CPY $5F
    ADC $@2F39C4
    PEA $&code_02D099-1
    AND ($E7, S), Y
    PEI ($68)
    SBC $2DD0, Y
    AND $3F0815, X
    ORA ($08, S), Y
    PEI ($99)
    AND $@map_babel_middle+813, X
    TYA 
    AND $@200813, X
    STY $50
    STA $F0, X
    COP [BranchIfPlayerAt] ( #$D57F, #$03A4, &code_02B580 )
    ADC $&20FB03, X
    TYA 
    ADC $3FCE
    SEI 
    ASL 
    CMP $90, X
    ORA $DD, S
    CMP $91, X
    ORA $6F, S
    SBC $7D, X
    ORA $C4, S
    ORA ($F5), Y
    JMP ($&code_list_02C403, X)
}

code_02994B {
    BPL loc_0299BC
    SBC $126B
    BPL loc_029955
    PHA 
    SBC $@chunk_008000.loc_008DB2+A, X
    STZ $&20E82D, X
    BRK #$9E
    INC $44F8
    SBC ($12, S), Y
    ASL $DA
    TRB $BA
    ASL $149A
    ADC $89081D
    PHP 
    STA [$08], Y
    BCS loc_029979
    LDY $&20D708, X
    PHP 
    SBC ($08, X)
    SBC ($08, S), Y

  loc_029979:
    JSR ($0E08, X)
    ORA #$0911
    ORA $09, X
    AND ($09, X)
    WDM 
    ORA #$094B
    PLA 
    ORA #$08C7
    BIT $09
    PLP 
    ORA #$093E
    STZ $09
    STY $&20C009
    ORA #$09C7
    STA $0A4509, X
    PLD 
    ASL 
    ORA ($01, X)
    COP [QueueHdmaChannel] ( #00, #$0201, #$0201 )
    ORA ($01, X)
    ORA $00, S
    ORA ($02, X)
    ORA $01, S
    ORA $03, S
    BRK #$01
    ORA $00, S
    ORA $03, S
    ORA $01, S
    PEA $&code_02F085-1
    ORA #$04E8
    STA $&209B03
    STY $3F
    STA $0B
    XCE 
    CMP ($F0, X)
    AND $F5, S
    JML [$&code_02DE02]
    CPY #$091B
    EOR [$5E]
    SBC $C8, X
    COP [ClearLowAbs] ( #07, #FC )
    BNE loc_0299E0
    INX 
    BRA loc_029A0E

  loc_0299DF:
    TSB $60
    STA $C9, X
    COP [RemoveItem] ( #C8 )
    COP [WaitUntilNoButton] ( #$0D0D )
    AND $@chunk_008000.code_00BB01+6
    INX 
    SBC $0D183F, X
    PEA $&code_02F086-1
    ORA #$40E8
    STA $&209B03

  loc_0299FC:
    STA $3F
    STA $0B

  loc_029A00:
    CPX $47
    BIT $5E
    BEQ loc_029A59
    SBC $41, X
    ORA $FD, S
    SBC $40, X
    ORA $DA, S

  loc_029A0E:
    BPL loc_029A05
    JML [$&code_02C40D]
    ORA ($E4)
    AND ($F0)
    ORA #$0A8F
    ORA ($8F), Y
    BRK #$10
    STA $@2B110A
    ORA ($F6), Y
    DEC 
    ORA $&20B680
    AND $&20EB0D, Y
    BPL loc_0299FC

  loc_029A2D:
    CMP $11EB, X
    RTS 
}

code_029A31 {
    STX $39, Y
    ORA $&20F5FD
    AND $&20CF03
    SBC $69, X
    ORA $1C, S
    ORA ($12, S), Y
    ORA ($1C, X)
    CMP $0390, X
    PHA 
    SBC $@gfx_sc02_main_characters+A09, X
    AND $8D05B7, X
    TRB $E8
    BRK #$9A
    BPL loc_029A2D
    BPL loc_029A00
    ORA ($33)
    ORA ($C8)

  loc_029A59:
    ADC $@map_ir29+64
    PHX 
    TRB $DA
    ASL $4D, X
    INC $&20D060
    ASL 
    TYA 
    AND [$16]
    INX 
    BRK #$D7
    TRB $FC
    AND $@149809
    ASL $3F, X
    LDX #$FC0B
    SBC [$14], Y
    STA [$16], Y
    CMP [$14], Y
    ADC $@3071F4
    STZ $9B
    ADC ($F0), Y
    ORA $E8
    COP [PanCameraRight]
    BVS code_029AE6
    SBC $B8, X
    ORA $C4, S
    ORA [$F4], Y
    PEI ($FB)
    CMP $DA, X
    TRB $8D
    BRK #$F7
    TRB $F0
    TRB $0530

  loc_029A9E:
    JSR ($14F7, X)
    BPL loc_029A9E
    PLA 
    INY 
    BEQ code_029AE6
    PLA 
    SBC $@2829F0
    CPX #$3090
    ADC $&20AEFD
    STX $EA, Y
    ORA #$2FFD
    CPX #$17E4
    BEQ loc_029ADF
    PHB 
    ORA [$D0], Y
    ASL 
    SBC $3D, X
    COP [DirToPlayer]
    SBC $3C, X
    COP #$EE
    AND $@gfx_euro_geezers_sprites+E8B
    COP [DirToPlayer]
    SBC $50, X
    COP #$EE
    AND $@37FCC0
    TRB $2D
    JSR ($14F7, X)
    SBC $2FAE, X
    LDA $E4, X
    EOR [$8D]
    JML $@chunk_058000.code_05B73F
}

code_029AE6 {
    SBC ($13)
    PEA $&code_02F099-1
    ORA ($F4, S), Y
    STA $04F0, Y
    TXY 
    STA $0B2F, Y
    SEP #$13
    INX 
    JMP ($038D, X)
    TXY 
    TYA 
    AND $3F0B88, X
    ADC $&20F40A
    LDA $4CF0
    SBC $A0, X
    COP [PanCameraRight]
    LDY $&20F544
    BRK #$01
    ADC $A1, X
    COP [BranchIfFlagByte] ( #05, #F5, $02B5 )
    AND $BB400D
    BRK #$20
    SBC $02F0, X
    PEA $60AE
    STA $B4, X
    COP [GiveItem] ( #AD, &code_028CF5 )
    COP [TickSineHdma] ( #95, #8D )
    COP [RemoveItem] ( #8C )
    COP [SetEntryExitNow] ( $1C1C12 )

  loc_029B36:
    BCC loc_029B3A
    PHA 
    SBC $@2DF4FD, X
    PLA 
    SBC ($90), Y
    ORA $28
    ORA $042FCF
    CMP $@chunk_008000.loc_008DBF+1E
    AND $@pal_kress+B8, X
    BIT $05, X
    TYX 
    LDY $13E3
    SED 
    ADC $@3413F2
    CMP ($F0, X)
    ORA #$DCF5
    COP [PanCameraRight]
    CPY #$03
    AND $@350D00, X
    EOR ($03, X)
    SBC $40F5, X
    ORA $DA, S
    BPL loc_029B63
    STA $F0
    ASL 
    SBC $55, X
    ORA $FD, S
    SBC $54, X
    ORA $3F, S
    SEP #$0C
    SBC ($13, S), Y
    ORA $3F, S
    DEC 
    PHD 

  loc_029B82:
    SBC ($13)
    SBC $7D, X
    ORA $FD, S
    SBC $7C, X
    ORA $DA, S
    BPL loc_029B82
    TYA 
    BEQ loc_029B9F
    PEA $&code_02D09A-1
    ASL 
    SBC $91, X
    ORA $FD, S
    SBC $90, X
    ORA $3F, S
    SEP #$0C

  loc_029B9F:
    PEA $&code_02F0AE-1
    LDA $@loc_02A0EB+A
    DEC $&20A9AC, X
    XBA 
    EOR ($F5), Y
    STA $&20CF02
    CMP $&209560, X
    STY $5F02
    EOR $&20E20C, X
    ORA ($CB, S), Y
    ORA ($3F)
    TXA 
    ASL 
    ADC $51EB
    CMP $8F14CB
    BRK #$15
    XBA 
    EOR ($AE), Y
    CMP $3F147A
    TXA 
    ASL 
    PLY 
    BPL loc_029BAD
    BPL loc_029C44
    SEP #$13
    XBA 
    EOR ($F5), Y
    CMP #$CF02
    CMP $&209560, X
    INY 
    COP [BranchIfSolidTypeSouth] ( #90, $4802 )
    SBC $@map_tunnel_waterfall+4D5, X
    CMP $&20FF48, X
    XBA 
    BIT $D0, X
    ASL $80
    LDY $3E
    XBA 
    EOR $&20F5CF, Y
    TRB $02
    CMP $0305F5
    CMP $@3030E4
    TSB $E4
    AND ($1C), Y
    CMP $@gfx_mine+16BF
    CMP $2D, X
    ORA $6F, S
    BRK #$01
    ORA $07, S
    ORA $1E15
    AND #$4234
    EOR ($5E), Y
    ADC [$6E]
    ADC ($77, S), Y
    PLY 
    JMP ($7E7D, X)
    ADC $0C0B0A, X
    ORA $0F0E
    BPL loc_029C3C
    ORA ($12), Y
    ORA ($13)
    ORA ($13, S), Y
    TRB $14
    TRB $14
    TRB $13
    ORA ($13, S), Y
    ORA ($12)
    ORA ($11), Y
    BPL loc_029C4E
    ASL $0C0D
    PHD 
    ASL 

  loc_029C44:
    ORA #$0708
    ASL $05
    TSB $03
    ORA $02, S
    COP [QueueHdma] ( $000101, #00 )
    BRK #$00
    BRK #$01
    ORA ($01, X)
    COP [QueueDma] ( $040303, #05 )
    ASL $07
    PHP 
    ORA #$007F
    BRK #$00
    BRK #$00
    BRK #$00
    CLI 
    LDA $@3EF0DB, X
    ORA [$0C]
    TSB $BG34NBA
    PLD 
    PLD 
    ORA ($FE, S), Y
    SBC ($F9, S), Y
    BIT $33, X
    BRK #$D9
    SBC $01
    JSR ($2CEB, X)
    BIT $4D0D, X
    JMP ($5C4C)
    AND $5C2D, X
    ADC ($63, X)
    LSR $4838
    EOR $0E
    EOR #$464B
    EOR $@chunk_088000.widestring_08DDD2+M, X
    ADC $09
    PEA $&code_028C0A-1
    ASL 
    BIT $&20D60B
    PHD 
    PHB 
    TSB $0D4A
    TRB $0E
    NOP 
    ASL $0FCD
    LDX $0010, Y
    BRK #$10
    BRK #$20
    BRK #$30
    BRK #$40
    BRK #$50
    BRK #$60
    BRK #$70
    BRK #$60
    BRK #$70
    BRK #$FA
    INC 
    AND [$38], Y
    AND $@3F8F1A, X
    BIT $8F, X
    BRK #$5E
    STA $@binary_0D44DB+265
    BPL loc_029CBB
    INC $F0, X
    AND $0430, Y
    XBA 
    AND $D0, X
    AND ($2D, S), Y
    ORA $4709
    LSR $09
    EOR [$37]
    ORA #$3647
    AND $8E0E64, X
    BPL loc_029D12
    AND $8F0EC9, X
    SBC $@chunk_008000.code_008F32+3, X
    AND $@chunk_078000.code_07808E+1, X
    CMP $&20AE12
    ORA #$4647
    ORA #$3747
    ORA #$3647
    AND $@280E64, X
    ORA $D4, S
    BVS loc_029D40
    ORA $3FAE, X
    CMP #$8F0E
    BRA loc_029D60

  loc_029D19:
    CMP $&20E412
    AND $D0, X
    BPL loc_029D04
    SBC [$F0], Y
    TSB $4709
    LSR $09
    EOR [$37]
    ORA #$3647
    AND $3F0E64, X
    CMP #$8F0E
    BRK #$34
    PLX 
    AND [$1A], Y
    ADC $@map_sc04+75
    SBC $01, X
    TRB $FD

  loc_029D40:
    SBC $00, X
    TRB $CE
    PEI ($D4)
    STP 
    CMP $E8, X
    JML [$05D5]
    ORA $E8, S
    ASL 
    AND $@280889, X
    BRK #$D5
    ORA $02, X
    CMP $A5, X
    ORA $D5, S
    BEQ loc_029D5F
    CMP $64, X

  loc_029D5F:
    COP [GiveItem] ( #AD, &code_02C1D4 )
    CMP $B8, X
    ORA $D4, S
    STY $D4
    STA $E8
    COP [GiveItem] ( #70, &code_02E46F )
    EOR [$48]
    SBC $3724FD, X
    CPY $37
    CMP $3624, X
    CPY $36
    ORA #$5E47
    PLX 
    EOR [$5C]
    STA $@gfx_mine_sprites+617
    ADC $&20A880, X
    TSB $5D
    SBC $15, X
    COP [WaitUntilNoButton] ( #$081D )
    DEC $&20FF8F
    BIT $E8, X
    BRK #$D4
    CMP $C4, X
    AND $6F, X
    PEA $&code_02D0D6-1
    ORA ($6F, X)
    CPX $35
    BEQ loc_029DCF
    ORA #$5E47
    INY 
    ORA ($D0)
    ORA ($E4)
    AND $@map_angkor_shrine_main+50, X
    PLP 
    AND $@table_0EE000.sprite_group_0EF6F5+8, X
    ORA $&20C008
    AND $2F0889, X
    ORA $@083FE4
    SBC $285CBC, X
    AND $@table_0EE000.sprite_group_0EF6F5+8, X
    ORA $&20893F
    PHP 

  loc_029DCF:
    CLD 
    MVP #$9B, #$70
    BNE loc_029E1A
    AND $@300813, X
    STX $30, Y
    JSR $00D5
    COP [WaitUntilNoButton] ( #$0813 )
    BMI loc_029DFC
    AND $289F
    ORA [$FD]
    INC $00, X
    ORA ($D5, S), Y
    ORA ($02, X)
    LDX $0F28
    SBC $08F6, X
    ORA ($D5, S), Y
    TRB $02
    AND $@280813, X
    CPX #$90
    ORA $3F
    ORA ($08, X)
    AND $@gfx_prologue_prophecy+E32
    TSB $F5
    BRK #$02
    PEI ($70)

  loc_029E0D:
    SBC $01F5, X
    COP [ClearFlagWord] ( #$D0DD )
    ORA ($BC, X)
    PEI ($71)
    AND $A93F03
    PHD 
    AND $@240A35, X
    BMI loc_029E13
    ORA $09, S
    EOR [$5E]
    AND $@2F0AE5, X
    STA $&20E8BB
    TAX 
    PHX 
    PEA $&code_02F4E5-1
    PLA 
    CPY $&20FAD0
    AND $@34EB1E
    BNE loc_029E39

  loc_029E3D:
    ROR $&20D0F4, X
    BPL loc_029E0D
    PEA $&code_02F5E5-1
    DEC $00, X
    BRK #$FC
    BNE loc_029E3D
    LDY $0F72
    EOR $100F68, X
    NOP 
    ROR $10F4, X
    INC $BA
    INC $C5, X
    ADC ($0F), Y
    CPY $0F72
    XBA 
    PEA $&code_02F5E5-1
    WAI 
    PEA $&code_02D2D1-1
    CMP $&20D831
    SBC ($6F), Y
    BRK #$00
    BRK #$04
}

code_029E70 {
    PHP 
    SEP #$20
    STZ $CGADD
    STZ $DMAP0
    LDA #$22
    STA $BBAD0
    LDX #$0A00
    STX $A1T0L
    LDA #$7F
    STA $A1B0
    LDX #$0200
    STX $DAS0L
    LDA #$01
    STA $MDMAEN
    LDA $backdropColors
    STA $COLDATA
    LDA $7F0C01
    STA $COLDATA
    LDA $7F0C02
    STA $COLDATA
    PLP 
    RTL 
}

code_029EAB {
    PHP 
    LDX #$0000
    STX $OAMADDL
    STZ $DMAP0
    LDA #$04
    STA $BBAD0
    LDX #$0422
    STX $A1T0L
    LDA #$00
    STA $A1B0
    LDX #$0220
    STX $DAS0L
    LDA #$01
    STA $MDMAEN
    PLP 
    RTL 
}

code_029ED2 {
    PHP 
    REP #$20
    LDA #$0000
    LDX #$0000

  loc_029EDB:
    STA $7E0000, X
    INX 
    INX 
    CPX #$0100
    BNE loc_029EDB

  loc_029EE6:
    LDX #$0200

  loc_029EE9:
    STA $7E0000, X
    INX 
    INX 
    BNE loc_029EE9
    LDX #$0000

  loc_029EF4:
    STA $animScratch, X
    INX 
    INX 
    BNE loc_029EF4
    LDX #$0000

  loc_029EFF:
    LDA $@code_029F15, X
    BMI loc_029F13
    TAY 
    LDA $@code_029F15+2, X
    STA $0000, Y
    INX 
    INX 
    INX 
    INX 
    BRA loc_029EFF

  loc_029F13:
    PLP 
    RTL 
}

code_029F15 {
    STZ $0006, X
    LDY #$06A0
    BRK #$C0
    BRA loc_029F1F

  loc_029F1F:
    BRK #$C0
    BRL loc_031E24

  loc_029F24:
    BRK #$BA
    ASL $00
    BPL loc_029EE6
    ASL $00
    CLC 
    LDX $0006
    JSR $06B0
    BRK #$28
    LDA ($06)
    BRK #$31
    LDY $06, X
    DEY 
    AND ($B6)
    ASL $84
    AND ($B8), Y
    ASL $0C
    AND ($AA, S), Y
    ASL $00
    BRK #$AC
    ASL $00
    ORA ($3A, X)
    BRK #$00
    BRA loc_029F8E

  loc_029F52:
    BRK #$8D
    BRK #$02
    TSB $8B
    MVN #$06, #$04
    PLB 
    RTS 
}

code_029F5D {
    LSR $0000, X
    BRK #$60
    BRK #$81
    BRK #$62
    BRK #$00
    BRK #$4A
    ASL $01
    BRK #$48
    ASL $04
    TSB $A8
    ORA $0020
    LDX $0D
    BPL loc_029F79

  loc_029F79:
    TAX 
    ORA $&table_018000
    LDY $&table_018000+D
    BRK #$AE
    ORA $4000
    BCS loc_029F94
    RTI 
    BRK #$B4
    ORA $2000
    LDA ($0D)
    BRK #$10
    TRB $0B
    BIT $&binary_01C36C+94, X
    ASL 
    SBC $0B04FF, X
    ORA ($00, X)
    SBC $A208FF, X
    BRK #$00

  loc_029FA3:
    REP #$20
    LDA $@code_029FBC+C, X
    BMI loc_029FBA
    TAY 
    SEP #$20
    LDA $@code_029FBC+E, X
    STA $0000, Y
    INX 
    INX 
    INX 
    BRA loc_029FA3

  loc_029FBA:
    PLP 
    RTL 
}

code_029FBC {
    BRK #$00
    BRK #$01
    BRK #$00
    COP [GenHdmaSine]
    BRK #$03
    BRK #$00
    PHD 
    WDM 
    BRK #$0C
    WDM 
    BRK #$00
    AND ($80, X)
    ORA ($21, X)
    COP [QueueDma] ( $030021, #21 )
    BRK #$05
    AND ($09, X)
    ASL $21
    BRK #$07
    AND ($11, X)
    PHP 
    AND ($19, X)
    ORA #$7821
    ASL 
    AND ($00, X)
    PHD 
    AND ($22, X)
    TSB $0621
    ORA $0021
    ORA $0021
    ASL $0021
    ASL $0021
    ORA $0F0021
    AND ($00, X)
    BPL loc_02A027
    BRK #$10
    AND ($00, X)
    ORA ($21), Y
    BRK #$11
    AND ($00, X)
    ORA ($21)
    BRK #$12
    AND ($00, X)
    ORA ($21, S), Y
    BRK #$13
    AND ($00, X)
    TRB $21
    BRK #$14
    AND ($00, X)
    ORA $21, X
    BRA loc_02A03C

  loc_02A026:
    AND ($00, X)
    ORA [$21], Y
    BRK #$1A
    AND ($80, X)
    TCS 
    AND ($01, X)
    TCS 
    AND ($00, X)
    TRB $0021
    TRB $0021
    ORA $0021, X
    ORA $0021, X
    ASL $0021, X
    ASL $0021, X
    ORA $1F0021, X
    AND ($00, X)
    JSR $0021
    JSR $0021
    AND ($21, X)
    BRK #$23
    AND ($33, X)
    BIT $21
    AND ($25, S), Y
    AND ($33, X)
    ROL $21
    BRK #$27
    AND ($FF, X)
    PLP 
    AND ($00, X)
    AND #$0021
    ROL 
    AND ($00, X)
    PLD 
    AND ($00, X)
    BIT $0421
    AND $0021
    ROL $0021
    AND $300021
    AND ($82, X)
    AND ($21), Y
    BRK #$32
    AND ($E0, X)
    AND ($21, S), Y
    BRK #$00
    WDM 
    BRK #$01
    WDM 
    SBC $L_WRMPYA, X
    ORA $42, S
    BRK #$04
    WDM 
    BRK #$05
    WDM 
    BRK #$06
    WDM 
    BRK #$07
    WDM 
    BRK #$08
    WDM 
    BRK #$09
    WDM 
    BRK #$0A
    WDM 
    BRK #$0D
    WDM 
    BRK #$FF
    SBC $@06F2AD, X
    STA $orbitAngle, X
    COP [SpawnAfterFlags] ( @chunk_3B7DD.code_03DEBF, #$2000 )
    CPY #$1FC0
    BNE loc_02A0C4
    JMP $&code_02A14B

  loc_02A0C4:
    TXA 
    TYX 
    TAY 
    LDA $26
    INC 
    STA $chatPtr, X
    LDA $0012, X
    ORA #$1000
    STA $0012, X
    TXA 
    TYX 
    TAY 
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [SetEntryContinue]
    LDA $musicTransitionState
    CMP #$FFFF
    BEQ loc_02A0EB
    RTL 

  loc_02A0EB:
    COP [SpawnAfterFlags] ( @code_02A153, #$2000 )
    LDA $20
    STA $0020, Y
    LDA $22
    STA $0022, Y
    LDA $0012, Y
    ORA #$1000
    STA $0012, Y
    COP [SetEntryContinue]
    SEP #$20
    LDA $APUIO1
    REP #$20
    AND #$00FF
    CMP #$00FF
    BEQ loc_02A117
    RTL 

  loc_02A117:
    LDA #$FFF0
    TRB $joypadMaskStd
    COP [SpawnAfterFlags] ( @chunk_3B7DD.code_03DEBF, #$2000 )
    CPY #$1FC0
    BEQ code_02A14B
    PHX 
    LDA $orbitAngle, X
    TYX 
    STA $chatPtr, X
    LDA $0012, X
    ORA #$1000
    STA $0012, X
    PLX 
    COP [SetEntryContinue]
    LDA $musicTransitionState
    CMP #$FFFF
    BEQ loc_02A148
    RTL 

  loc_02A148:
    COP [WaitByte] ( #01 )
}

code_02A14B {
    LDA #$0080
    TRB $09FA
    COP [Die]
}

code_02A153 {
    COP [WaitByte] ( #48 )
    LDA #$1000
    TRB $12
    PHP 
    PHB 
    REP #$20
    STZ $joypadMaskStd
    SEP #$20
    LDA $22
    PHA 
    PLB 
    LDY $20
    JSL $@chunk_008000.code_008181
    REP #$20
    JSL $@code_02B05F
    PLB 
    PLP 
    COP [Die]
}

code_02A178 {
    LDA $musicTransitionState
    BNE loc_02A187
    LDA $09FA
    BIT #$0080
    BNE loc_02A187
    CLC 
    RTL 

  loc_02A187:
    SEC 
    RTL 
}

code_02A189 {
    LDA $0D6E
    CMP $sceneCurrent
    BNE loc_02A192
    RTL 

  loc_02A192:
    JSR $&code_02A1E0
    LDA $00
    BNE loc_02A19A
    RTL 

  loc_02A19A:
    PHP 
    PHB 
    SEC 
    SBC #$4920
    SBC $294A1A, X
    INC $&table_01A946+2, X
    CPX #$B48D
    BRK #$9C
    LDA $00, X
    LDA $0040
    PHA 
    LDY $3E
    PHY 
    PHK 
    PLB 
    LDY #$A1D5
    REP #$20
    JSL $@code_02B05F
    PLY 
    PLB 
    SEP #$20
    PLA 
    CLC 
    ADC $097A
    STA $097A
    REP #$20
    JSL $@code_02B05F
    PLB 
    PLP 
    RTL 
}

code_02A1D5 {
    DEX 
    CMP ($08, X)
    ORA [$C7]
    PHP 
    ORA ($00, X)
    DEC $00, X
    CPY $&table_01B06E.delta_node_01C208
    JSR $3EE6
    STZ $00
    SEP #$20
    LDY #$0000

  loc_02A1EC:
    LDA [$3E], Y
    CMP #$CC
    BEQ loc_02A217
    BIT #$80
    BEQ loc_02A20D
    BIT #$40
    BEQ loc_02A20C
    CMP #$CE
    BNE loc_02A209
    INY 
    LDA [$3E], Y
    INY 
    CLC 
    ADC $00
    STA $00
    BRA loc_02A1EC

  loc_02A209:
    INY 
    BRA loc_02A1EC

  loc_02A20C:
    INY 

  loc_02A20D:
    INY 
    LDA $00
    CLC 
    ADC #$03
    STA $00
    BRA loc_02A1EC

  loc_02A217:
    PLP 
    RTS 
}

code_02A219 {
    PHP 
    SEP #$20
    LDY #$0000
    STY $04

  loc_02A221:
    LDA $0A20, Y
    INY 
    STA $06
    LDA #$08
    STA $0E

  loc_02A22B:
    LSR $06
    BCC loc_02A244
    LDA $04
    REP #$20
    PHY 
    AND #$00FF
    JSL $@code_02A393
    PLY 
    SEP #$20
    BCS loc_02A244
    JSL $@code_02A250

  loc_02A244:
    INC $04
    DEC $0E
    BNE loc_02A22B
    LDA $04
    BNE loc_02A221
    PLP 
    RTL 
}

code_02A250 {
    PHP 
    PHY 
    REP #$20
    LDA $06AC
    STA $3E
    LDA #$007F
    STA $40
    STZ $A6
    LDA $A4
    AND #$00FF
    BEQ loc_02A26C
    LDA #$0002
    STA $A6

  loc_02A26C:
    LDA $9A
    STA $18
    LDA $9C
    STA $1C
    LDX $A6
    JSL $@code_02BDAF
    STX $00
    STX $1A
    LDA $96
    STA $18
    LDA $98
    STA $1C
    LDX $A6
    JSL $@code_02BDAF
    STX $02
    STX $1E
    LDA $A6
    BNE loc_02A2E9

  loc_02A294:
    LDX $02
    SEP #$20
    LDA $mapLayerTilemap, X
    PHA 
    LDA $collisionLayer, X
    LDX $00
    STA $collisionLayer, X
    PLA 
    STA $mapLayerTilemap, X
    REP #$20
    DEC $9E
    BEQ loc_02A2C6
    JSL $@code_02BE02
    PHX 
    LDA $00
    STA $02
    JSL $@code_02BE02
    STX $00
    PLX 
    STX $02
    BRA loc_02A294

  loc_02A2C6:
    DEC $A0
    BEQ loc_02A2E6
    LDA $A2
    STA $9E
    LDA $1A
    STA $02
    JSL $@code_02BE3E
    STX $00
    STX $1A
    LDA $1E
    STA $02
    JSL $@code_02BE3E
    STX $1E
    BRA loc_02A294

  loc_02A2E6:
    PLY 
    PLP 
    RTL 

  loc_02A2E9:
    LDX $02
    SEP #$20
    LDA $effectLayerTilemap, X
    PHA 
    LDX $00
    STA $3E
    LDA [$3E]
    BEQ loc_02A2FE
    STA $collisionLayer, X

  loc_02A2FE:
    PLA 
    STA $effectLayerTilemap, X
    REP #$20
    DEC $9E
    BEQ loc_02A31D
    JSL $@code_02BE02
    PHX 
    LDA $00
    STA $02
    JSL $@code_02BE02
    STX $00
    PLX 
    STX $02
    BRA loc_02A2E9

  loc_02A31D:
    DEC $A0
    BEQ loc_02A33D
    LDA $A2
    STA $9E
    LDA $1A
    STA $02
    JSL $@code_02BE5A
    STX $00
    STX $1A
    LDA $1E
    STA $02
    JSL $@code_02BE5A
    STX $1E
    BRA loc_02A2E9

  loc_02A33D:
    PLY 
    PLP 
    RTL 
}

code_02A340 {
    TSX 
    LDY $dmaSkipFlag
    BEQ loc_02A35F
    REP #$20
    LDA #$07FF
    TCS 

  loc_02A34C:
    PLA 
    BEQ loc_02A358
    STA $VMADDL
    PLA 
    STA $VMDATAL
    BRA loc_02A34C

  loc_02A358:
    TXS 
    STZ $dmaSkipFlag
    SEP #$20
    RTL 

  loc_02A35F:
    TXS 
    LDA #$80
    STA $VMAIN
    REP #$20
    LDA $tileQueryResult
    BEQ loc_02A38D
    STA $VMADDL
    LDA $0904
    STA $VMDATAL
    LDA $0906
    STA $VMDATAL
    LDA $0908
    STA $VMADDL
    LDA $090A
    STA $VMDATAL
    LDA $090C
    STA $VMDATAL

  loc_02A38D:
    STZ $tileQueryResult
    SEP #$20
    RTL 
}

code_02A393 {
    ASL 
    ASL 
    ASL 
    TAY 
    STA $00A8
    LDA $&array_01D3F7, Y
    AND #$00FF
    CMP $sceneCurrent
    BNE loc_02A3D6
    PHD 
    LDA #$0000
    TCD 
    SEP #$20
    LDA $&array_01D3F7+7, Y
    STA $A4
    LDA $&array_01D3F7+5, Y
    STA $9A
    LDA $&array_01D3F7+6, Y
    STA $9C
    LDA $&array_01D3F7+1, Y
    STA $96
    LDA $&array_01D3F7+2, Y
    STA $98
    LDA $&array_01D3F7+3, Y
    STA $A2
    STA $9E
    LDA $&array_01D3F7+4, Y
    STA $A0
    PLD 
    REP #$20
    CLC 
    RTL 

  loc_02A3D6:
    SEC 
    RTL 
}

code_02A3D8 {
    PHX 
    PHD 
    LDA #$0000
    TCD 

  code_02A3DE:
    STA $A6
    LDA $A4
    AND #$00FF
    BEQ loc_02A3EC
    LDA #$0002
    STA $A6

  loc_02A3EC:
    LDY #$0000

  code_02A3EF:
    LDA $9A
    STA $18
    ASL 
    ASL 
    ASL 
    ASL 
    STA $1A
    LDA $9C
    STA $1C
    ASL 
    ASL 
    ASL 
    ASL 
    STA $1E
    LDX $A6
    JSL $@code_02BDAF
    STX $00
    LDA $96
    STA $18
    LDA $98
    STA $1C
    LDX $A6
    JSL $@code_02BDAF
    STX $02
    LDA $A6
    BNE code_02A473

  loc_02A41F:
    LDX $02
    SEP #$20
    LDA $mapLayerTilemap, X
    PHA 
    LDA $collisionLayer, X
    LDX $00
    STA $collisionLayer, X
    PLA 
    STA $mapLayerTilemap, X
    JSR $&code_02A53D
    BCS loc_02A43E
    BEQ loc_02A44C

  loc_02A43E:
    REP #$20
    JSR $&code_02A5BB
    BCC loc_02A41F
    JSR $&code_02A5E1
    BCS loc_02A469
    BRA code_02A3EF

  loc_02A44C:
    REP #$20
    JSR $&code_02A5BB
    BCC loc_02A458
    JSR $&code_02A5E1
    BCS loc_02A469

  loc_02A458:
    LDA #$0000
    STA $dmaSkipFlag, Y
    SEP #$20
    JSL $@chunk_008000.code_008122
    REP #$20
    JMP $&code_02A3DE

  loc_02A469:
    LDA #$0000
    STA $dmaSkipFlag, Y
    PLD 
    PLX 
    SEC 
    RTL 

  code_02A473:
    LDA $06AC
    STA $3E
    LDA #$007F
    STA $40
    LDX $02
    SEP #$20
    LDA $effectLayerTilemap, X
    PHA 
    LDX $00
    STA $3E
    LDA [$3E]
    BEQ loc_02A492
    STA $collisionLayer, X

  loc_02A492:
    PLA 
    STA $effectLayerTilemap, X
    REP #$20
    LDA $1A
    CLC 
    ADC #$0010
    SEC 
    SBC $bg1ScrollV
    CMP #$0111
    BCS loc_02A50F
    LDA $savedCameraDelta
    SEC 
    SBC #$0010
    AND #$FFF0
    PHA 
    LDA $1E
    SEC 
    SBC $01, S
    BMI loc_02A50E
    CMP #$00F1
    BCS loc_02A50E
    PLA 
    LDA $effectLayerTilemap, X
    AND #$00FF
    ASL 
    ASL 
    ASL 
    TAX 
    LDA $metatileEffectLayer, X
    STA $0802, Y
    LDA $7E2802, X
    STA $0806, Y
    LDA $7E2804, X
    STA $080A, Y
    LDA $7E2806, X
    STA $080E, Y
    JSL $@code_02BDDB
    CLC 
    ADC #$0800
    STA $dmaSkipFlag, Y
    INC 
    STA $0804, Y
    CLC 
    ADC #$001F
    STA $0808, Y
    INC 
    STA $080C, Y
    TYA 
    CLC 
    ADC #$0010
    TAY 
    CMP #$0100
    BEQ loc_02A51F
    BRA loc_02A50F

  loc_02A50E:
    PLA 

  loc_02A50F:
    JSR $&code_02A5BB
    BCS loc_02A517
    JMP $&code_02A473

  loc_02A517:
    JSR $&code_02A5E1
    BCS loc_02A533
    JMP $&code_02A3EF

  loc_02A51F:
    JSR $&code_02A5BB
    BCC loc_02A529
    JSR $&code_02A5E1
    BCS loc_02A533

  loc_02A529:
    LDA #$0000
    STA $dmaSkipFlag, Y
    PLD 
    PLX 
    CLC 
    RTL 

  loc_02A533:
    LDA #$0000
    STA $dmaSkipFlag, Y
    PLD 
    PLX 
    SEC 
    RTL 
}

code_02A53D {
    PHP 
    REP #$20
    LDA $1A
    CLC 
    ADC #$0010
    SEC 
    SBC $bg1ScrollH
    CMP #$0111
    BCS loc_02A5B8
    LDA $bg2ScrollH
    SEC 
    SBC #$0010
    AND #$FFF0
    PHA 
    LDA $1E
    SEC 
    SBC $01, S
    BMI loc_02A5B7
    CMP #$00F1
    BCS loc_02A5B7
    PLA 
    LDA $mapLayerTilemap, X
    AND #$00FF
    ASL 
    ASL 
    ASL 
    TAX 
    LDA $metatileMapLayer, X
    STA $0802, Y
    LDA $7E2002, X
    STA $0806, Y
    LDA $7E2004, X
    STA $080A, Y
    LDA $7E2006, X
    STA $080E, Y
    JSL $@code_02BDDB
    STA $dmaSkipFlag, Y
    INC 
    STA $0804, Y
    CLC 
    ADC #$001F
    STA $0808, Y
    INC 
    STA $080C, Y
    TYA 
    CLC 
    ADC #$0010
    TAY 
    CMP #$0100
    BEQ loc_02A5B2
    PLP 
    CLC 
    RTS 

  loc_02A5B2:
    PLP 
    LDX #$0000
    RTS 

  loc_02A5B7:
    PLA 

  loc_02A5B8:
    PLP 
    SEC 
    RTS 
}

code_02A5BB {
    SEC 
    DEC $9E
    BNE loc_02A5C1
    RTS 

  loc_02A5C1:
    LDA $1A
    CLC 
    ADC #$0010
    STA $1A
    INC $96
    INC $9A
    JSL $@code_02BE02
    PHX 
    LDA $00
    STA $02
    JSL $@code_02BE02
    STX $00
    PLX 
    STX $02
    CLC 
    RTS 
}

code_02A5E1 {
    SEC 
    DEC $A0
    BNE loc_02A5E7
    RTS 

  loc_02A5E7:
    LDA $1E
    CLC 
    ADC #$0010
    STA $1E
    INC $98
    INC $9C
    LDX $A8
    LDA $@array_01D3F7+1, X
    AND #$00FF
    STA $96
    LDA $@array_01D3F7+5, X
    AND #$00FF
    STA $9A
    LDA $A2
    STA $9E
    CLC 
    RTS 
}

code_02A60D {
    PHP 
    REP #$20
    JSR $&code_02A9A2
    BCS loc_02A61A
    JSR $&code_02A68D
    BCS loc_02A61A

  loc_02A61A:
    NOP 
    NOP 
    NOP 
    NOP 
    PLP 
    RTL 
}

code_02A620 {
    PHP 
    REP #$20
    LDY $0646
    LDX $&table_01AD90, Y

  loc_02A629:
    LDA $0000, X
    BIT #$0080
    BNE loc_02A68B
    LDA $0003, X
    AND #$007F
    JSL $@chunk_008000.code_00B537
    BCC loc_02A685
    PHX 
    SEP #$20
    LDA $0000, X
    STA $18
    LDA $0001, X
    DEC 
    STA $1C
    STZ $19
    STZ $1D
    LDX #$0000
    JSL $@code_02BDAF
    STX $02
    STX $00
    LDA #$FE
    STA $mapLayerTilemap, X
    JSL $@code_02BE02
    LDA #$FF
    STA $mapLayerTilemap, X
    LDX $00
    STX $02
    JSL $@code_02BE3E
    LDA #$FC
    STA $mapLayerTilemap, X
    JSL $@code_02BE02
    LDA #$FD
    STA $mapLayerTilemap, X
    REP #$20
    PLX 

  loc_02A685:
    INX 
    INX 
    INX 
    INX 
    BRA loc_02A629

  loc_02A68B:
    PLP 
    RTL 
}

code_02A68D {
    LDY $decelStepCounter
    LDA $0010, Y
    BIT #$0004
    BNE loc_02A699
    RTS 

  loc_02A699:
    LDA $joypadCurrent
    BIT #$0800
    BNE loc_02A6A2
    RTS 

  loc_02A6A2:
    JSL $@chunk_3B7DD.code_03E58B
    AND #$00FF
    CMP #$0001
    BEQ loc_02A6AF
    RTS 

  loc_02A6AF:
    LDY $decelStepCounter
    LDA $0014, Y
    SEC 
    SBC #$0008
    STA $18
    AND #$0008
    ASL 
    CLC 
    ADC $18
    LSR 
    LSR 
    LSR 
    LSR 
    STA $18
    LDA $0016, Y
    SEC 
    SBC #$0020
    LSR 
    LSR 
    LSR 
    LSR 
    STA $1C
    LDX #$0000
    SEP #$20
    JSL $@code_02BDAF
    LDA $mapLayerTilemap, X
    STX $02
    CMP #$F8
    BEQ loc_02A6FF
    CMP #$F9
    BEQ loc_02A6EF

  loc_02A6EC:
    REP #$20
    RTS 

  loc_02A6EF:
    JSL $@code_02BE1F
    LDA $mapLayerTilemap, X
    CMP #$F8
    BNE loc_02A6EC
    DEC $18
    BRA loc_02A70B

  loc_02A6FF:
    JSL $@code_02BE02
    LDA $mapLayerTilemap, X
    CMP #$F9
    BNE loc_02A6EC

  loc_02A70B:
    LDY $0646
    LDX $&table_01AD90, Y

  loc_02A711:
    LDA $0000, X
    BMI loc_02A727
    CMP $18
    BNE loc_02A721
    LDA $0001, X
    CMP $1C
    BEQ loc_02A731

  loc_02A721:
    INX 
    INX 
    INX 
    INX 
    BRA loc_02A711

  loc_02A727:
    REP #$20
    LDY #$E9BA
    JSL $@code_02FC78
    RTS 

  loc_02A731:
    REP #$20
    PHX 
    LDA #$0080
    TSB $09FA
    LDA #$00FC
    STA $06
    JSR $&code_02A8D9
    LDA $01, S
    TAX 
    LDA $0002, X
    AND #$00FF
    BEQ loc_02A764
    JSL $@chunk_3B7DD.code_03E458
    BCC loc_02A77A
    JSL $@code_02FC78
    LDA $01, S
    TAX 
    LDA #$00F8
    STA $06
    JSR $&code_02A8D9
    BRA loc_02A7D7

  loc_02A764:
    LDY #$E9A8
    JSL $@code_02FC78
    LDA $01, S
    TAX 
    LDA $0003, X
    AND #$007F
    JSL $@chunk_008000.code_00B52F
    BRA loc_02A7D7

  loc_02A77A:
    LDA $01, S
    PHX 
    TAX 
    LDA $0003, X
    BIT #$0080
    BNE loc_02A79F
    LDA #$0080
    TRB $09FA
    SEP #$20
    LDA #$2A
    STA $sfxQueueCh2
    REP #$20
    PLX 
    LDY #$E99F
    JSL $@code_02FC78
    BRA loc_02A7C8

  loc_02A79F:
    PLX 
    PHY 
    PHX 
    LDX #$0000
    COP [SpawnLastRel] ( @code_02A7DF, #00, #00, #$2000 )
    LDA $0012, Y
    ORA #$1000
    STA $0012, Y
    LDA #$0017
    STA $0026, Y
    PLX 
    PLA 
    STA $0024, Y
    LDA $0DB8
    STA $0020, Y

  loc_02A7C8:
    LDA $01, S
    TAX 
    LDA $0003, X
    AND #$007F
    JSL $@chunk_008000.code_00B52F
    PLX 
    RTS 

  loc_02A7D7:
    LDA #$0080
    TRB $09FA
    PLX 
    RTS 
}

code_02A7DF {
    LDA $musicParentActor
    STA $orbitAngle, X
    COP [SpawnAfterFlags] ( @chunk_3B7DD.code_03DEBF, #$2000 )
    CPY #$1FC0
    BNE loc_02A7F5
    JMP $&code_02A8B2

  loc_02A7F5:
    TXA 
    TYX 
    TAY 
    LDA $26
    INC 
    STA $chatPtr, X
    LDA $0012, X
    ORA #$1000
    STA $0012, X
    TXA 

  code_02A809:
    TYX 
    TAY 
    LDA #$CFF0
    TSB $joypadMaskStd
    LDY $decelStepCounter
    LDA $0012, Y
    ORA #$1000
    STA $0012, Y
    LDA #$0080
    STA $0002, Y
    LDA #$C57A
    JSR $&code_02A8CF
    LDA #$0800
    TSB $slopeCurvePtrB
    COP [SetEntryContinue]
    LDA $musicTransitionState
    CMP #$FFFF
    BEQ loc_02A83A
    RTL 

  loc_02A83A:
    COP [SpawnAfterFlags] ( @code_02A8BA, #$2000 )
    LDA $24
    STA $0024, Y
    LDA $0012, Y
    ORA #$1000
    STA $0012, Y
    LDA $20
    STA $0020, Y
    COP [SetEntryContinue]
    SEP #$20
    LDA $APUIO1
    REP #$20
    AND #$00FF
    CMP #$00FF
    BEQ loc_02A866
    RTL 

  loc_02A866:
    LDY $decelStepCounter
    LDA $0012, Y
    AND #$EFFF
    STA $0012, Y
    LDA #$0080
    STA $0002, Y
    LDA #$C5A2
    JSR $&code_02A8CF
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SpawnAfterFlags] ( @chunk_3B7DD.code_03DEBF, #$2000 )
    CPY #$1FC0
    BEQ code_02A8B2
    PHX 
    LDA $orbitAngle, X
    TYX 
    STA $chatPtr, X
    LDA $0012, X
    ORA #$1000
    STA $0012, X
    PLX 
    COP [SetEntryContinue]
    LDA $musicTransitionState
    CMP #$FFFF
    BEQ loc_02A8AF
    RTL 

  loc_02A8AF:
    COP [WaitByte] ( #01 )
}

code_02A8B2 {
    LDA #$0080
    TRB $09FA
    COP [Die]
}

code_02A8BA {
    COP [WaitByte] ( #48 )
    LDA #$1000
    TRB $12
    LDA $20
    STA $0DB8
    LDY $24
    JSL $@code_02FC78
    COP [Die]
}

code_02A8CF {
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    RTS 
}

code_02A8D9 {
    PHP 
    LDA $0000, X
    AND #$00FF
    STA $18
    ASL 
    ASL 
    ASL 
    ASL 
    STA $1A
    LDA $0001, X
    AND #$00FF
    DEC 
    STA $1C
    ASL 
    ASL 
    ASL 
    ASL 
    STA $1E
    SEP #$20
    LDX #$0000
    JSL $@code_02BDAF
    STX $02
    STX $00
    LDY #$0000
    LDA $06

  code_02A909:
    CLC 
    ADC #$02
    STA $mapLayerTilemap, X
    JSR $&code_02A53D
    JSL $@code_02BE02
    LDA $06
    CLC 
    ADC #$03
    STA $mapLayerTilemap, X
    REP #$20
    LDA $1A
    CLC 
    ADC #$0010
    STA $1A
    SEP #$20
    JSR $&code_02A53D
    LDX $00
    STX $02
    JSL $@code_02BE3E
    LDA $06
    STA $mapLayerTilemap, X
    REP #$20
    LDA $1A
    SEC 
    SBC #$0010
    STA $1A
    LDA $1E
    CLC 
    ADC #$0010
    STA $1E
    SEP #$20
    JSR $&code_02A53D
    JSL $@code_02BE02
    LDA $06
    INC 
    STA $mapLayerTilemap, X
    REP #$20
    LDA $1A
    CLC 
    ADC #$0010
    STA $1A
    SEP #$20
    JSR $&code_02A53D
    REP #$20
    LDA #$0000
    STA $dmaSkipFlag, Y
    SEP #$20
    JSL $@chunk_008000.code_008181
    PLP 
    RTS 
}

code_02A97E {
    REP #$20
    LDA $0646
    TAX 
    LDA $&scene_warps, X
    STA $00D4

  loc_02A98A:
    SEP #$20
    TAX 
    LDA $0000, X
    BMI loc_02A99B
    REP #$20
    TXA 
    CLC 
    ADC #$000C
    BRA loc_02A98A

  loc_02A99B:
    INX 
    STX $00D6
    SEP #$20
    RTL 
}

code_02A9A2 {
    SEP #$20
    LDX $00D4
    BEQ loc_02A9F0

  loc_02A9A9:
    LDA $0000, X
    CMP #$FF
    BEQ loc_02A9F0
    LDA $playerSpeedNs
    SEC 
    SBC $0000, X
    CMP $0002, X
    BCS loc_02A9C8
    LDA $slopeStepCounter
    SEC 
    SBC $0001, X
    CMP $0003, X
    BCC loc_02A9D4

  loc_02A9C8:
    REP #$20
    TXA 
    CLC 
    ADC #$000C
    TAX 
    SEP #$20
    BRA loc_02A9A9

  loc_02A9D4:
    REP #$20
    JSR $&code_02AA48
    LDA $playerWallType
    SEC 
    SBC $00

  loc_02A9DF:
    CMP $04
    BCS loc_02A9F0
    LDA $playerSpeedEw
    SEC 
    SBC $02
    CMP $06
    BCS loc_02A9F0
    JMP $&code_02AA81

  loc_02A9F0:
    SEP #$20
    LDX $00D6
    BEQ loc_02AA3E

  loc_02A9F7:
    LDA $0000, X
    CMP #$FF
    BEQ loc_02AA3E
    LDA $playerSpeedNs
    SEC 
    SBC $0000, X
    CMP $0002, X
    BCS loc_02AA16
    LDA $slopeStepCounter
    SEC 
    SBC $0001, X
    CMP $0003, X
    BCC loc_02AA22

  loc_02AA16:
    REP #$20
    TXA 
    CLC 
    ADC #$000D
    TAX 
    SEP #$20
    BRA loc_02A9F7

  loc_02AA22:
    REP #$20
    JSR $&code_02AA48
    LDA $playerWallType
    SEC 
    SBC $00
    CMP $04
    BCS loc_02AA3E
    LDA $playerSpeedEw
    SEC 
    SBC $02
    CMP $06
    BCS loc_02AA3E
    JMP $&code_02AB19

  loc_02AA3E:
    REP #$20
    LDA #$0100
    TRB $slopeCurvePtrB
    CLC 
    RTS 
}

code_02AA48 {
    LDA $0000, X
    AND #$00FF
    ASL 
    ASL 
    ASL 
    ASL 
    STA $00
    LDA $0001, X
    AND #$00FF
    ASL 
    ASL 
    ASL 
    ASL 
    STA $02
    LDA $0002, X
    AND #$00FF
    ASL 
    ASL 
    ASL 
    ASL 
    SEC 
    SBC #$000F
    STA $04
    LDA $0003, X
    AND #$00FF
    ASL 
    ASL 
    ASL 
    ASL 
    SEC 
    SBC #$000F
    STA $06
    RTS 
}

code_02AA81 {
    PHP 
    TXA 
    CLC 
    ADC #$0004
    STA $0AF4
    SEP #$20
    LDA #$81
    STA $0AF6
    LDA $0004, X
    STA $sceneNext
    LDY $0005, X
    STY $064C
    LDY $0007, X
    STY $064E
    LDA $0009, X
    STA $0650
    LDY $000A, X
    STY $0652
    LDY $sceneCurrent
    STY $0B12
    LDA $0000, X
    STA $0B08
    LDA $0001, X
    STA $0B0C
    LDA $0002, X
    STA $0B0A
    LDA $0003, X
    STA $0B0E
    LDA $cameraOffsetX+1
    AND #$0F
    STA $0B10
    LDA $cameraOffsetY+1
    ASL 
    ASL 
    ASL 
    ASL 
    ORA $0B10
    STA $0B10
    LDA $cameraBoundsX+1
    AND #$0F
    STA $0B11
    LDA $cameraBoundsY+1
    ASL 
    ASL 
    ASL 
    ASL 
    ORA $0B11
    STA $0B11
    LDA $0650
    BIT #$80
    BNE loc_02AB01
    PLP 
    SEC 
    RTS 

  loc_02AB01:
    AND #$7F
    STA $0650
    REP #$20
    TXA 
    CLC 
    ADC #$0004
    STA $sceneSaveData
    LDA #$0081
    STA $0AF2
    PLP 
    SEC 
    RTS 
}

code_02AB19 {
    LDA $slopeCurvePtrB
    BIT #$0100
    BEQ loc_02AB22
    RTS 

  loc_02AB22:
    TXA 
    CLC 
    ADC #$0007
    STA $0650
    LDA #$0000
    STA $09C0
    STA $decelCurvePtr
    SEP #$20
    LDY $0004, X
    STY $0652
    LDA $0006, X
    STA $scrollStepTableBase
    JSL $@chunk_3B7DD.code_03DD39
    JSR $&code_02AB4C
    REP #$20
    SEC 
    RTS 
}

code_02AB4C {
    REP #$20
    LDA #$0100
    TSB $slopeCurvePtrB
    LDY $decelStepCounter
    LDA $0010, Y
    ORA #$2000
    STA $0010, Y
    STZ $scrollStepIndex
    LDA $scrollStepTableBase
    PHA 
    AND #$000F
    STA $scrollStepTableBase
    PLA 
    BIT #$0020
    BNE loc_02AB8A
    BIT #$0010
    BNE loc_02AB97
    BIT #$0080
    BNE loc_02ABA4
    PHD 
    LDA $decelStepCounter
    TAX 
    TCD 
    COP [SpawnBefore] ( @chunk_008000.code_00EC92 )
    PLD 
    RTS 

  loc_02AB8A:
    PHD 
    LDA $decelStepCounter
    TAX 
    TCD 
    COP [SpawnBefore] ( @chunk_008000.code_00ED3A )
    PLD 
    RTS 

  loc_02AB97:
    PHD 
    LDA $decelStepCounter
    TAX 
    TCD 
    COP [SpawnBefore] ( @chunk_008000.code_00ED8E )
    PLD 
    RTS 

  loc_02ABA4:
    PHD 
    LDA $decelStepCounter
    TAX 
    TCD 
    COP [SpawnBefore] ( @chunk_008000.code_00ECE6 )
    PLD 
    RTS 
}

code_02ABB1 {
    PHP 
    REP #$20
    LDA $cameraTargetX, X
    CMP $mapBoundsX, X
    BCC loc_02ABCA
    LDA $mapBoundsX, X
    DEC 
    STA $00
    LDA $cameraTargetX, X
    AND $00
    STA $cameraTargetX, X

  loc_02ABCA:
    STA $bg1ScrollH, X
    AND #$FFF0
    STA $18
    LDA $cameraTargetY, X
    BMI loc_02ABEA
    CMP $mapBoundsY, X
    BCC loc_02ABEA
    LDA $mapBoundsY, X
    DEC 
    STA $00
    LDA $cameraTargetY, X
    AND $00
    STA $cameraTargetY, X

  loc_02ABEA:
    STA $bg2ScrollH, X
    AND #$FFF0
    STA $1C
    SEP #$20
    LDA #$81
    STA $VMAIN
    LDA #$01
    STA $DMAP0
    LDA #$18
    STA $BBAD0
    LDA #$7E
    STA $A1B0
    REP #$20
    LDA #$0020

  loc_02AC0D:
    PHA 
    JSR $&code_02ADC9
    PHX 
    LDA $06B2, X
    TAX 
    LDA $7E0000, X
    TAY 
    JSR $&code_02AFEE
    PLX 
    LDA $18
    CLC 
    ADC #$0010
    CMP $mapBoundsX, X
    BCC loc_02AC36
    AND #$0100
    CMP $mapBoundsX, X
    BCC loc_02AC36
    SEC 
    SBC $mapBoundsX, X

  loc_02AC36:
    STA $18
    PLA 
    DEC 
    BNE loc_02AC0D
    LDA #$0000
    STA $tilemapStaging
    STA $7E3288
    STA $7E3184
    STA $7E330C
    JSL $@code_029E70
    PLP 
    RTL 
}

code_02AC55 {
    PHP 
    REP #$20
    LDA $scrollModeFlags
    BIT #$0008
    BEQ loc_02AC6E
    LDA $cameraTargetX, X
    STA $bg1ScrollH, X
    LDA $cameraTargetY, X
    STA $bg2ScrollH, X
    PLP 
    RTL 

  loc_02AC6E:
    CPX #$0000
    BEQ loc_02AC89
    LDA $layerPriorityFlag
    BIT #$0400
    BEQ loc_02AC89
    LDA $cameraDeltaX
    STA $bg1ScrollV
    LDA $cameraDeltaY
    STA $savedCameraDelta
    PLP 
    RTL 

  loc_02AC89:
    LDA $bg1ScrollH, X
    PHA 
    LDA $cameraTargetX, X
    SEC 
    SBC $bg1ScrollH, X
    BPL loc_02ACA0
    CMP #$FFF0
    BCS loc_02ACA8
    LDA #$FFF0
    BRA loc_02ACA8

  loc_02ACA0:
    CMP #$0010
    BCC loc_02ACA8
    LDA #$0010

  loc_02ACA8:
    STA $scrollDeltaXClamped, X
    CLC 
    ADC $bg1ScrollH, X
    STA $bg1ScrollH, X
    EOR $01, S
    BIT #$0010
    BEQ loc_02ACBC
    JSR $&code_02AD18

  loc_02ACBC:
    PLA 
    LDA $bg2ScrollH, X
    PHA 
    LDA $cameraTargetY, X
    SEC 
    SBC $bg2ScrollH, X
    BPL loc_02ACD4
    CMP #$FFF0
    BCS loc_02ACDC
    LDA #$FFF0
    BRA loc_02ACDC

  loc_02ACD4:
    CMP #$0010
    BCC loc_02ACDC
    LDA #$0010

  loc_02ACDC:
    STA $scrollDeltaYClamped, X
    CLC 
    ADC $bg2ScrollH, X
    STA $bg2ScrollH, X
    EOR $01, S
    BIT #$0010
    BEQ loc_02ACF0
    JSR $&code_02ACF3

  loc_02ACF0:
    PLA 
    PLP 
    RTL 
}

code_02ACF3 {
    LDA $bg1ScrollH, X
    STA $18
    LDA #$FFF0
    LDY $scrollDeltaYClamped, X
    BMI loc_02AD03
    LDA #$00E0

  loc_02AD03:
    CLC 
    ADC $bg2ScrollH, X

  loc_02AD07:
    STA $1C
    CMP $mapBoundsY, X
    BCC loc_02AD14
    SEC 
    SBC $mapBoundsY, X
    BRA loc_02AD07

  loc_02AD14:
    JSR $&code_02AD32
    RTS 
}

code_02AD18 {
    LDA #$0000
    LDY $scrollDeltaXClamped, X
    BMI loc_02AD23
    LDA #$0100

  loc_02AD23:
    CLC 
    ADC $bg1ScrollH, X
    STA $18
    LDA $bg2ScrollH, X
    STA $1C
    JSR $&code_02ADC9
    RTS 
}

code_02AD32 {
    PHP 
    PHB 
    PHX 
    LDA $06AE, X
    STA $02
    SEP #$20
    LDA #$7E
    PHA 
    PLB 
    LDA $1D
    XBA 
    LDA $0693, X
    JSL $@code_0282F6
    CLC 
    ADC $19
    CLC 
    ADC $069F, X
    XBA 
    LDA $1C
    AND #$F0
    TAY 
    STY $04
    REP #$20
    JSR $&code_02ADB4
    LDA $1C
    AND #$00F0
    ASL 
    ASL 
    CLC 
    ADC $06BA, X
    PHA 
    LDA $06B6, X
    TAX 
    LDA $18
    BIT #$0100
    BNE loc_02AD82
    PLA 
    STA $0000, X
    CLC 
    ADC #$0400
    STA $0082, X
    BRA loc_02AD8D

  loc_02AD82:
    PLA 
    STA $0082, X
    CLC 
    ADC #$0400
    STA $0000, X

  loc_02AD8D:
    PHX 
    LDA #$0010
    JSR $&code_02AF18
    LDA $04
    CLC 
    ADC #$0100
    STA $04
    LDA $03, S
    TAX 
    LDA $04
    JSR $&code_02ADB4
    PLA 
    CLC 
    ADC #$0082
    TAX 
    LDA #$0010
    JSR $&code_02AF18
    PLX 
    PLB 
    PLP 
    RTS 
}

code_02ADB4 {
    SEC 
    SBC $069E, X
    SEC 
    SBC $069A, X
    BCS loc_02ADBF
    RTS 

  loc_02ADBF:
    CLC 
    ADC $069E, X
    STA $0004
    TAY 
    BRA code_02ADB4
}

code_02ADC9 {
    PHP 
    PHB 
    PHX 
    LDA $mapBoundsX, X
    STA $1A
    LDA $069A, X
    STA $08
    CLC 
    ADC $mapTilemapBaseA, X
    STA $1E
    LDA $06AE, X
    STA $02
    SEP #$20
    LDA #$7E
    PHA 
    PLB 
    LDA $1D
    XBA 
    LDA $1B
    JSL $@code_0282F6
    CLC 
    ADC $19
    CLC 
    ADC $069F, X
    STA $05
    LDA $1C
    LSR 
    LSR 
    LSR 
    LSR 
    XBA 
    LDA #$10
    JSL $@code_0282F6
    STA $04
    LDA $18
    LSR 
    LSR 
    LSR 
    LSR 
    CLC 
    ADC $04
    STA $04
    REP #$20
    LDA $04
    JSR $&code_02ADB4
    LDA $04
    STA $06
    LDA $06B2, X
    PHA 
    LDA $18
    LSR 
    LSR 
    LSR 
    AND #$003E
    BIT #$0020
    BNE loc_02AE7F
    CLC 
    ADC $06BA, X
    PLX 
    STA $0000, X
    INC 
    STA $0042, X
    PHX 
    LDA $1C
    LSR 
    LSR 
    LSR 
    LSR 
    AND #$000F
    STA $10
    ASL 
    ASL 
    CLC 
    ADC $01, S
    TAX 
    LDA #$0010
    SEC 
    SBC $10
    JSR $&code_02AF4D
    PLY 
    LDA $10
    BEQ loc_02AE7D
    TYX 
    LDA $04
    AND #$FF0F
    CLC 
    ADC $1A
    CMP $1E
    BCC loc_02AE6B
    SEC 
    SBC $08

  loc_02AE6B:
    STA $04
    TAY 
    PHX 
    LDA $03, S
    TAX 
    LDA $04
    JSR $&code_02ADB4
    PLX 
    LDA $10
    JSR $&code_02AF4D

  loc_02AE7D:
    BRA loc_02AED7

  loc_02AE7F:
    AND #$001E
    CLC 
    ADC $06BA, X
    CLC 
    ADC #$0400
    PLX 
    STA $0000, X
    CLC 
    ADC #$0001
    STA $0042, X
    PHX 
    LDA $1C
    LSR 
    LSR 
    LSR 
    LSR 
    AND #$000F
    STA $10
    ASL 
    ASL 
    CLC 
    ADC $01, S
    TAX 
    LDA #$0010
    SEC 
    SBC $10
    JSR $&code_02AF4D
    PLY 
    LDA $10
    BEQ loc_02AED7
    TYX 
    LDA $04
    AND #$FF0F
    CLC 
    ADC $1A
    CMP $1E
    BCC loc_02AEC5
    SEC 
    SBC $08

  loc_02AEC5:
    STA $04
    TAY 
    PHX 
    LDA $03, S
    TAX 
    LDA $04
    JSR $&code_02ADB4
    PLX 
    LDA $10
    JSR $&code_02AF4D

  loc_02AED7:
    TXA 
    SEC 
    SBC #$0004
    TAX 
    LDA $06
    BIT #$00F0
    BNE loc_02AEFE
    SEC 
    SBC $1A
    CLC 
    ADC #$00F0
    STA $04
    PHX 
    LDA $03, S
    TAX 
    LDA $04
    CMP $069E, X
    BMI loc_02AEFB
    PLX 
    BRA loc_02AF04

  loc_02AEFB:
    PLX 
    BRA loc_02AF14

  loc_02AEFE:
    SEC 
    SBC #$0010
    STA $04

  loc_02AF04:
    PHX 
    LDA $03, S
    TAX 
    LDA $04
    JSR $&code_02ADB4
    PLX 
    LDA #$0001
    JSR $&code_02AF4D

  loc_02AF14:
    PLX 
    PLB 
    PLP 
    RTS 
}

code_02AF18 {
    LDY $04
    STA $0E

  loc_02AF1C:
    LDA $0000, Y
    PHY 
    AND #$00FF
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $02
    TAY 
    LDA $0000, Y
    STA $0002, X
    LDA $0002, Y
    STA $0004, X
    LDA $0004, Y
    STA $0042, X
    LDA $0006, Y
    STA $0044, X
    INX 
    INX 
    INX 
    INX 
    PLY 
    INY 
    DEC $0E
    BNE loc_02AF1C
    RTS 
}

code_02AF4D {
    LDY $04
    STA $0E

  loc_02AF51:
    LDA $0000, Y
    PHY 
    AND #$00FF
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $02
    TAY 
    LDA $0000, Y
    STA $0002, X
    LDA $0002, Y
    STA $0044, X
    LDA $0004, Y
    STA $0004, X
    LDA $0006, Y
    STA $0046, X
    INX 
    INX 
    INX 
    INX 
    PLA 
    CLC 
    ADC #$0010
    TAY 
    DEC $0E
    BNE loc_02AF51
    RTS 
}

code_02AF86 {
    PHP 
    SEP #$20
    LDA #$81
    STA $VMAIN
    LDA #$01
    STA $DMAP0
    LDA #$18
    STA $BBAD0
    LDA #$7E
    STA $A1B0
    REP #$20
    LDX $06B2
    LDA $7E0000, X
    TAY 
    BEQ loc_02AFAC
    JSR $&code_02AFEE

  loc_02AFAC:
    LDX $06B4
    LDA $7E0000, X
    TAY 
    BEQ loc_02AFB9
    JSR $&code_02AFEE

  loc_02AFB9:
    LDA #$0080
    STA $VMAIN
    LDX $06B6
    LDA $7E0000, X
    TAY 
    BEQ loc_02AFCC
    JSR $&code_02B027

  loc_02AFCC:
    LDX $06B8
    LDA $7E0000, X
    TAY 
    BEQ loc_02AFD9
    JSR $&code_02B027

  loc_02AFD9:
    LDA #$0000
    STA $tilemapStaging
    STA $7E3288
    STA $7E3184
    STA $7E330C
    PLP 
    RTL 
}

code_02AFEE {
    PHP 
    SEP #$20
    INX 
    INX 
    PHX 
    STY $VMADDL
    STX $A1T0L
    LDA #$40
    STA $DAS0L
    LDA #$01
    STA $MDMAEN
    REP #$20
    PLA 
    CLC 
    ADC #$0040
    TAX 
    LDA $7E0000, X
    TAY 
    INX 
    INX 
    SEP #$20
    STY $VMADDL
    STX $A1T0L
    LDA #$40
    STA $DAS0L
    LDA #$01
    STA $MDMAEN
    PLP 
    RTS 
}

code_02B027 {
    PHP 
    SEP #$20
    INX 
    INX 
    PHX 
    STY $VMADDL
    STX $A1T0L
    LDA #$80
    STA $DAS0L
    LDA #$01
    STA $MDMAEN
    REP #$20
    PLA 
    CLC 
    ADC #$0080
    TAX 
    LDA $7E0000, X
    STA $VMADDL
    INX 
    INX 
    SEP #$20
    STX $A1T0L
    LDA #$80
    STA $DAS0L
    LDA #$01
    STA $MDMAEN
    PLP 
    RTS 
}

code_02B05F {
    PHP 
    PHD 
    PHX 
    LDA #$0000
    TCD 

  code_02B066:
    SEP #$20
    LDA $0000, Y
    BMI loc_02B076
    INY 
    JSR $&code_02B810
    JSR $&code_02BD26
    BRA code_02B066

  loc_02B076:
    INY 
    BIT #$40
    BNE loc_02B083
    JSR $&code_02B857
    JSR $&code_02BD26
    BRA code_02B066

  loc_02B083:
    REP #$20
    PEA $&code_02B066-1
    AND #$001F
    ASL 
    TAX 
    LDA $@code_list_02B094, X
    DEC 
    PHA 
    RTS 
}
---------------------------------------------

code_list_02B094 [
  &code_02B0C8   ;00
  &code_02B188   ;01
  &code_02B0D9   ;02
  &code_02B1C2   ;03
  &code_02B27B   ;04
  &code_02B2A6   ;05
  &code_02B2C8   ;06
  &code_02B35F   ;07
  &code_02B3B4   ;08
  &code_02B426   ;09
  &code_02B433   ;0A
  &code_02B43A   ;0B
  &code_02B0D4   ;0C
  &code_02B0FB   ;0D
  &code_02B144   ;0E
  &code_02B1A8   ;0F
  &code_02B441   ;10
  &code_02B4B8   ;11
  &code_02B4E6   ;12
  &code_02B4FB   ;13
  &code_02B500   ;14
  &code_02B50A   ;15
  &code_02B514   ;16
  &code_02B51F   ;17
  &code_02B54A   ;18
  &code_02B55F   ;19
]

code_02B0C8 {
    JSR $&code_02B4E6
    JSR $&code_02B3B4
    LDA #$0F00
    TRB $joypadHeld
}

code_02B0D4 {
    PLX 
    PLX 
    PLD 
    PLP 
    RTL 
}

code_02B0D9 {
    LDA $0000, Y
    INY 
    AND #$00FF
    PHP 
    PHB 
    PHY 
    ASL 
    TAY 
    SEP #$20
    LDA #$81
    PHA 
    PLB 
    REP #$20
    LDA $&string_templates, Y
    TAY 
    JSL $@code_02B05F
    REP #$20
    PLY 
    PLB 
    PLP 
    RTS 
}

code_02B0FB {
    LDX $099E
    LDA $097E, X
    CLC 
    ADC #$0004
    STA $097E, X
    LDA $0982, X
    ASL 
    STA $097A, X
    LDA #$0000
    STA $099A, X
    LDA $098E, X
    ASL 
    CLC 
    ADC $0986, X
    ASL 
    SEC 
    SBC #$0004
    CMP $097E, X
    BCS loc_02B143
    LDA $097E, X
    SEC 
    SBC #$0004
    STA $097E, X
    LDX $099E
    JSR $&code_02B763
    JSR $&code_02BD1E
    LDX $099E
    JSR $&code_02B763
    JSR $&code_02BD1E

  loc_02B143:
    RTS 
}

code_02B144 {
    LDA $0000, Y
    INY 
    AND #$00FF
    BEQ loc_02B187
    PHA 

  loc_02B14E:
    LDX $099E
    LDA $097A, X
    STA $18
    LDA $098A, X
    ASL 
    CLC 
    ADC $0982, X
    ASL 
    SEC 
    SBC $18
    CMP $01, S
    BCS loc_02B174
    PHA 
    LDA $03, S
    SEC 
    SBC $01, S
    STA $03, S
    PLA 
    JSR $&code_02B0FB
    BRA loc_02B14E

  loc_02B174:
    LDA $097A, X
    CLC 
    ADC $01, S
    STA $097A, X
    LDA $099A, X
    CLC 
    ADC $01, S
    STA $099A, X
    PLA 

  loc_02B187:
    RTS 
}

code_02B188 {
    LDX $099E
    LDA $0000, Y
    INY 
    INY 
    PHA 
    AND #$00FF
    ASL 
    STA $097A, X
    PLA 
    XBA 
    AND #$00FF
    ASL 
    STA $097E, X
    LDA #$0000
    STA $099A, X
    RTS 
}

code_02B1A8 {
    PHY 
    PHB 
    LDA $0000, Y
    PHA 
    SEP #$20
    LDA $0002, Y
    PHA 
    PLB 
    REP #$20
    PLY 
    JSL $@code_02B05F
    PLB 
    PLY 
    INY 
    INY 
    INY 
    RTS 
}

code_02B1C2 {
    LDX $099E
    LDA $0000, Y
    AND #$00FF
    INY 
    PHY 
    XBA 
    ASL 
    ASL 
    STA $0992, X
    SEC 
    JSR $&code_02B73C
    LDX $099E
    LDA $099A, X
    BIT #$0001
    BEQ loc_02B1F2
    LDA #$0000
    STA $099A, X
    LDA $097A, X
    CLC 
    ADC #$0001
    STA $097A, X

  loc_02B1F2:
    LDA $097A, X
    LSR 
    STA $18
    LDA $098A, X
    ASL 
    CLC 
    ADC $0982, X
    SEC 
    SBC $18
    STA $18
    LDA $097E, X
    LSR 
    STA $1C
    LDA $098E, X
    ASL 
    CLC 
    ADC $0986, X
    SEC 
    SBC $1C
    LSR 
    STA $1C
    LDA $097E, X
    ASL 
    ASL 
    ASL 
    ASL 
    ASL 
    PHA 
    CLC 
    ADC $0982, X
    CLC 
    ADC $0982, X
    STA $00
    PLA 
    CLC 
    ADC $097A, X
    PHA 
    LDA $0992, X
    PLX 
    PHA 

  loc_02B237:
    SEP #$20

  loc_02B239:
    LDA $7F0201, X
    AND #$E3
    ORA $02, S
    STA $7F0201, X
    LDA $7F0241, X
    AND #$E3
    ORA $02, S
    STA $7F0241, X
    INX 
    INX 
    DEC $18
    BNE loc_02B239
    REP #$20
    LDX $099E
    LDA $098A, X
    ASL 
    STA $18
    LDA $00
    CLC 
    ADC #$0080
    STA $00
    TAX 
    DEC $1C
    BNE loc_02B237
    PLA 
    LDA #$0001
    TSB $09FA
    JSR $&code_02BD1E
    PLY 
    RTS 
}

code_02B27B {
    LDX $099E
    LDA $098E, X
    CMP $09A0
    BEQ loc_02B28E
    JSR $&code_02B0FB
    INC $09A0
    BRA code_02B27B

  loc_02B28E:
    LDA $0982, X
    ASL 
    STA $097A, X
    LDA $0986, X
    ASL 
    STA $097E, X
    LDA #$0000
    STA $099A, X
    STA $09A0
    RTS 
}

code_02B2A6 {
    LDA $0000, Y
    INY 
    INY 
    STA $00
    LDA $0000, Y
    INY 
    INY 
    TAX 
    LDA $0000, X
    PHY 
    ASL 
    CLC 
    ADC $00
    TAX 
    LDA $0000, X
    TAY 
    JSL $@code_02B05F
    REP #$20
    PLY 
    RTS 
}

code_02B2C8 {
    PHY 
    LDA #$0000
    PHA 
    PHA 
    PHA 
    PHA 
    LDA $0000, Y
    INY 
    INY 
    PHA 
    LDA $0000, Y
    INY 
    INY 
    PHA 

  loc_02B2DC:
    LDA $03, S
    SEC 
    SBC $07, S
    LDY #$0000

  loc_02B2E4:
    SEC 
    SBC #$0004
    BMI loc_02B2EF
    BEQ loc_02B2EF
    INY 
    BRA loc_02B2E4

  loc_02B2EF:
    CLC 
    ADC #$0004
    STA $05, S
    TYA 
    STA $09, S
    ASL 
    CLC 
    ADC $01, S
    TAY 
    LDA $0000, Y
    TAX 
    LDA $05, S
    TAY 
    TXA 

  loc_02B305:
    DEY 
    BEQ loc_02B30E
    LSR 
    LSR 
    LSR 
    LSR 
    BRA loc_02B305

  loc_02B30E:
    AND #$000F
    TAX 
    BNE loc_02B31D
    LDA $05, S
    DEC 
    BEQ loc_02B31D
    LDA $0B, S
    BEQ loc_02B32C

  loc_02B31D:
    LDA $@code_02B34F, X
    AND #$00FF
    JSR $&code_02B810
    LDA $0B, S
    INC 
    STA $0B, S

  loc_02B32C:
    LDA $09, S
    BNE loc_02B335
    LDA $05, S
    DEC 
    BEQ loc_02B33F

  loc_02B335:
    LDA $07, S
    INC 
    STA $07, S
    JSR $&code_02BD26
    BRA loc_02B2DC

  loc_02B33F:
    JSR $&code_02BD1E
    PLA 
    PLA 
    PLA 
    PLA 
    PLA 
    PLA 
    PLA 
    CLC 
    ADC #$0004
    TAY 
    RTS 
}

code_02B34F {
    ADC ($74, S), Y
    ADC $76, X
    ADC [$78], Y
    ADC $7B7A, Y
    JMP ($2221, X)
    AND $24, S
    AND $26
}

code_02B35F {
    LDX $099E
    LDA $0000, Y
    AND #$00FF
    INY 
    STA $098A, X
    LDA $0000, Y
    INY 
    AND #$00FF
    STA $098E, X
    LDA $0000, Y
    INY 
    AND #$00FF
    STA $00

  code_02B37F:
    LDA $0B04
    STA $007E
    LDA #$0010
    STA $playerActor
    LDA #$0000
    STA $00DC
    PHY 
    LDA $097A, X
    LSR 
    STA $0982, X
    LDA $097E, X
    LSR 
    STA $0986, X
    LDA #$0000
    STA $0992, X
    STA $099A, X
    JSR $&code_02B89E
    JSR $&code_02BC3E
    JSR $&code_02BD1E
    PLY 
    RTS 
}

code_02B3B4 {
    PHY 
    LDX $099E
    PHB 
    LDA $0982, X
    DEC 
    STA $00
    LDA $0986, X
    DEC 
    STA $02
    JSR $&code_02BCD1
    PHA 
    LDA $098A, X
    INC 
    ASL 
    PHA 
    LDA $098E, X
    INC 
    ASL 
    TAY 
    SEP #$20
    LDA #$7F
    PHA 
    PLB 
    REP #$20
    LDA $03, S
    TAX 
    LDA $01, S

  loc_02B3E2:
    STZ $0200, X
    STZ $0240, X
    INX 
    INX 
    DEC 
    BNE loc_02B3E2
    LDA $03, S
    CLC 
    ADC #$0040
    STA $03, S
    TAX 
    LDA $01, S
    DEY 
    BNE loc_02B3E2
    PLA 
    PLA 
    PLB 
    LDA #$0001
    TSB $09FA
    JSR $&code_02BD1E
    JSR $&code_02BCDD
    PHX 
    LDX #$0022
    LDA #$675D
    STA $cgramPalette, X
    LDA #$10F2
    STA $7F0A02, X
    LDA #$0000
    STA $7F0A04, X
    PLX 
    PLY 
    RTS 
}

code_02B426 {
    PHY 
    LDA $0000, Y
    AND #$00FF
    JSR $&code_02BD21
    PLY 
    INY 
    RTS 
}

code_02B433 {
    LDA #$0000
    STA $099E
    RTS 
}

code_02B43A {
    LDA #$0002
    STA $099E
    RTS 
}

code_02B441 {
    PHY 
    LDX $099E
    LDA $0982, X
    ASL 
    STA $097A, X
    LDA $0986, X
    ASL 
    STA $097E, X
    LDA $098A, X
    ASL 
    STA $18
    LDA $098E, X
    STA $1C
    LDA $0986, X
    ASL 
    ASL 
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $0982, X
    ASL 
    STA $00
    TAX 

  loc_02B46E:
    LDA #$2020
    STA $7F0200, X
    LDA #$2020
    STA $7F0240, X
    INX 
    INX 
    DEC $18
    BNE loc_02B46E
    LDX $099E
    LDA $098A, X
    ASL 
    STA $18
    LDA $00
    CLC 
    ADC #$0080
    STA $00
    TAX 
    DEC $1C
    BNE loc_02B46E
    LDA #$0001
    TSB $09FA
    JSR $&code_02BD1E
    LDX $099E
    JSR $&code_02BCDD
    JSR $&code_02BC3E
    LDX $099E
    LDA #$0000
    STA $099A, X
    JSR $&code_02BD1E
    PLY 
    RTS 
}

code_02B4B8 {
    LDA #$C080
    TSB $joypadHeld

  loc_02B4BE:
    JSR $&code_02BD1E
    LDA $joypadCurrent
    AND #$C080
    BNE loc_02B4D5
    SEC 
    JSR $&code_02B994
    LDA #$0001
    TSB $09FA
    BRA loc_02B4BE

  loc_02B4D5:
    STA $joypadHeld
    CLC 
    JSR $&code_02B994
    LDA #$0001
    TSB $09FA
    JSR $&code_02B441
    RTS 
}

code_02B4E6 {
    LDA #$CFF0
    TSB $joypadHeld

  loc_02B4EC:
    JSR $&code_02BD1E
    LDA $joypadCurrent
    AND #$CFFF
    BEQ loc_02B4EC
    STA $joypadHeld
    RTS 
}

code_02B4FB {
    LDA $0000, Y
    TAY 
    RTS 
}

code_02B500 {
    LDX $099E
    LDA #$0001
    STA $0996, X
    RTS 
}

code_02B50A {
    LDX $099E
    LDA #$0000
    STA $0996, X
    RTS 
}

code_02B514 {
    LDA $0000, Y
    INY 
    AND #$00FF
    STA $playerActor
    RTS 
}

code_02B51F {
    LDX $099E
    LDA #$000D
    STA $098A, X
    LDA #$0004
    STA $098E, X
    LDA #$0003
    ASL 
    STA $097A, X
    LDA #$0011
    ASL 
    STA $097E, X
    LDA #$0000
    STA $099A, X
    LDA #$0000
    STA $00
    JMP $&code_02B37F
}

code_02B54A {
    PHX 
    LDA $0000, Y
    AND #$00FF
    ASL 
    TAX 
    LDA $0001, Y
    STA $cgramPalette, X
    INY 
    INY 
    INY 
    PLX 
    RTS 
}

code_02B55F {
    LDA $0000, Y
    AND #$00FF
    STA $007E
    INY 
    RTS 
}

code_02B56A {
    LDX $099E
    LDA $099A, X
    BIT #$0001
    BEQ loc_02B5D8
    BIT #$0002
    BEQ loc_02B5A9
    LDX #$0000
    LDY #$FFFF
}

code_02B580 {
    LDA $092A, X
    AND #$F0F0
    STA $091A, X
    TYA 
    STA $092A, X
    LDA $095A, X
    AND #$F0F0
    STA $094A, X
    TYA 
    STA $095A, X
    STA $093A, X
    STA $096A, X
    INX 
    INX 
    CPX #$0010
    BNE code_02B580
    BRA loc_02B5F4

  loc_02B5A9:
    LDX #$0000
    LDY #$FFFF

  loc_02B5AF:
    LDA $093A, X
    AND #$F0F0
    STA $091A, X
    TYA 
    STA $093A, X
    LDA $096A, X
    AND #$F0F0
    STA $094A, X
    TYA 
    STA $096A, X
    STA $092A, X
    STA $095A, X
    INX 
    INX 
    CPX #$0010
    BNE loc_02B5AF
    BRA loc_02B5F4

  loc_02B5D8:
    LDX #$0000
    LDA #$FFFF

  loc_02B5DE:
    STA $091A, X
    INX 
    INX 
    CPX #$0060
    BNE loc_02B5DE
    LDX $099E
    LDA #$0000
    STA $099A, X
    CLC 
    BRA loc_02B5FE

  loc_02B5F4:
    LDX $099E
    LDA #$0001
    STA $099A, X
    SEC 

  loc_02B5FE:
    RTS 
}

code_02B5FF {
    LDA $42
    CLC 
    ADC #$0010
    STA $3E
    LDA $44
    STA $40
    SEP #$20
    LDX #$0000
    TXY 

  loc_02B611:
    LDA [$42], Y
    ROR 
    ROR 
    ROR 
    ROR 
    STA $04
    ROR 
    STA $00
    LDA $04
    AND #$0F
    ORA $091A, X
    STA $091A, X
    LDA $00
    AND #$F0
    STA $00
    LDA [$3E], Y
    ROR 
    ROR 
    ROR 
    ROR 
    STA $04
    ROR 
    STA $02
    LDA $04
    AND #$0F
    ORA $00
    STA $092A, X
    LDA $02
    ORA #$0F
    STA $093A, X
    INY 
    INX 
    CPX #$0010
    BNE loc_02B611
    LDX #$0000
    LDY #$0020

  loc_02B654:
    LDA [$42], Y
    ROR 
    ROR 
    ROR 
    ROR 
    STA $04
    ROR 
    STA $00
    LDA $04
    AND #$0F
    ORA $094A, X
    STA $094A, X
    LDA $00
    AND #$F0
    STA $00
    LDA [$3E], Y
    ROR 
    ROR 
    ROR 
    ROR 
    STA $04
    ROR 
    STA $02
    LDA $04
    AND #$0F
    ORA $00
    STA $095A, X
    LDA $02
    ORA #$0F
    STA $096A, X
    INY 
    INX 
    CPX #$0010
    BNE loc_02B654
    REP #$20
    RTS 
}

code_02B694 {
    LDX #$0000
    TXY 

  loc_02B698:
    LDA [$42], Y
    STA $091A, X
    INY 
    INY 
    INX 
    INX 
    CPX #$0020
    BNE loc_02B698
    LDX #$0000

  loc_02B6A9:
    LDA [$42], Y
    STA $094A, X
    INY 
    INY 
    INX 
    INX 
    CPX #$0020
    BNE loc_02B6A9
    RTS 
}

code_02B6B8 {
    LDX $099E
    LDA #$0002
    TSB $09FA
    LDA $097E, X
    ASL 
    ASL 
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $097A, X
    AND #$FFFE
    TAX 
    LDA $7F0200, X
    AND #$03FF
    ASL 
    ASL 
    ASL 
    STA $090E
    CLC 
    ADC #$0008
    BIT #$0080
    BNE loc_02B6EC
    STA $0910
    BRA loc_02B6F3

  loc_02B6EC:
    CLC 
    ADC #$0080
    STA $0910

  loc_02B6F3:
    CLC 
    ADC #$0008
    BIT #$0080
    BNE loc_02B701
    STA $0912
    BRA loc_02B708

  loc_02B701:
    CLC 
    ADC #$0080
    STA $0912

  loc_02B708:
    LDA $090E
    CLC 
    ADC #$6000
    STA $090E
    CLC 
    ADC #$0080
    STA $0914
    LDA $0910
    CLC 
    ADC #$6000
    STA $0910
    CLC 
    ADC #$0080
    STA $0916
    LDA $0912
    CLC 
    ADC #$6000
    STA $0912
    CLC 
    ADC #$0080
    STA $0918
    RTS 
}

code_02B73C {
    BCC loc_02B745
    LDA #$0003
    STA $00
    BRA loc_02B74A

  loc_02B745:
    LDA #$0004
    STA $00

  loc_02B74A:
    LDA $097A, X
    STA $18
    LDA $098A, X
    ASL 
    CLC 
    ADC $0982, X
    ASL 
    SEC 
    SBC $18
    CMP $00
    BCS loc_02B762
    JSR $&code_02B0FB

  loc_02B762:
    RTS 
}

code_02B763 {
    LDA $098A, X
    ASL 
    STA $18
    STA $1A
    LDA $098E, X
    ASL 
    STA $1C
    LDA $0986, X
    ASL 
    ASL 
    ASL 
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $0982, X
    CLC 
    ADC $0982, X
    STA $00
    TAX 
    PHY 
    LDY #$0000

  loc_02B789:
    LDA $7F0200, X
    STA $091A, Y
    INX 
    INX 
    INY 
    INY 
    DEC $18
    BNE loc_02B789
    PLY 
    LDA $1A
    STA $18
    LDX $00

  loc_02B79F:
    LDA $7F0240, X
    STA $7F0200, X
    INX 
    INX 
    DEC $18
    BNE loc_02B79F
    DEC $1C
    BEQ loc_02B7C0
    LDA $1A
    STA $18
    LDA $00
    CLC 
    ADC #$0040
    STA $00
    TAX 
    BRA loc_02B79F

  loc_02B7C0:
    LDX $099E
    LDA $0992, X
    STA $02
    LDX $00
    LDA $1A
    STA $18
    PHY 
    LDY #$0000

  loc_02B7D2:
    LDA $091A, Y
    AND #$E3FF
    ORA $02
    STA $7F0200, X
    INX 
    INX 
    INY 
    INY 
    DEC $18
    BNE loc_02B7D2
    PLY 
    LDX #$0000
    LDA $1A
    LSR 
    STA $1A
    STA $090E

  loc_02B7F2:
    LDA $091A, X
    AND #$03FF
    ASL 
    ASL 
    ASL 
    ORA #$6000
    STA $091A, X
    INX 
    INX 
    INX 
    INX 
    DEC $1A
    BNE loc_02B7F2
    LDA #$0005
    TSB $09FA
    RTS 
}

code_02B810 {
    LDX $099E
    PHY 
    REP #$20
    AND #$00FF
    STA $06
    ASL 
    ASL 
    ASL 
    ASL 
    ASL 
    ASL 
    STA $42
    LDA $0996, X
    BIT #$0001
    BEQ loc_02B832
    LDA #$2000
    TSB $42
    STZ $06

  loc_02B832:
    LDA #$00C1
    STA $44
    SEC 
    JSR $&code_02B73C
    JSR $&code_02B9D4
    LDX $099E
    LDA $099A, X
    CLC 
    ADC #$0003
    STA $099A, X
    LDA $097A, X
    CLC 
    ADC #$0003
    STA $097A, X
    PLY 
    RTS 
}

code_02B857 {
    LDX $099E
    AND #$3F
    XBA 
    LDA $0000, Y
    INY 
    REP #$20
    STZ $06
    PHY 
    PHA 
    AND #$01FF
    ASL 
    ASL 
    ASL 
    ASL 
    ASL 
    ASL 
    STA $42
    PLA 
    XBA 
    AND #$00FF
    LSR 
    CLC 
    ADC #$00C2
    STA $44
    SEC 
    JSR $&code_02B73C
    JSR $&code_02B9D4
    LDX $099E
    LDA $099A, X
    CLC 
    ADC #$0003
    STA $099A, X
    LDA $097A, X
    CLC 
    ADC #$0003
    STA $097A, X
    PLY 
    RTS 
}

code_02B89E {
    LDA $00
    ASL 
    TAX 
    LDA #$0082
    STA $40
    LDA $@code_02B8E3, X
    STA $3E
    LDX $099E
    LDA $098A, X
    ASL 
    STA $18
    PHA 
    LDA $098E, X
    ASL 
    STA $1C
    LDA $097E, X
    DEC 
    DEC 
    ASL 
    ASL 
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $097A, X
    SEC 
    SBC #$0002
    TAX 
    STX $00
    JSR $&code_02B907
    PLX 
    PHX 

  loc_02B8D7:
    STX $18
    JSR $&code_02B92E
    PLY 
    STY $18
    JSR $&code_02B907
    RTS 
}

code_02B8E3 {
    SBC [$B8]
    SBC [$B8], Y
    BPL loc_02B909
    ORA ($20), Y
    BPL loc_02B94D
    ORA ($20)
    ORA ($60)
    BPL loc_02B893
    ORA ($A0), Y
    BPL loc_02B8D7
    ORA ($20, S), Y
    TRB $20
    ORA ($60, S), Y
    ORA $20, X
    ORA $60, X
    ORA ($A0, S), Y
    TRB $A0
    ORA ($E0, S), Y
}

code_02B907 {
    LDA [$3E]

  loc_02B909:
    STA $7F0200, X
    INX 
    INX 
    INC $3E
    INC $3E
    LDA [$3E]

  loc_02B915:
    STA $7F0200, X
    INX 
    INX 
    DEC $18
    BNE loc_02B915
    INC $3E
    INC $3E
    LDA [$3E]
    STA $7F0200, X
    INC $3E
    INC $3E
    RTS 
}

code_02B92E {
    PHY 
    LDY #$0002

  loc_02B932:
    LDA $00
    CLC 
    ADC #$0040
    STA $00
    TAX 
    LDA [$3E]
    STA $7F0200, X
    INX 
    INX 
    TXA 
    CLC 
    ADC $18
    CLC 
    ADC $18
    TAX 
    LDA [$3E], Y

  loc_02B94D:
    STA $7F0200, X
    DEC $1C
    BNE loc_02B932
    LDA $00
    CLC 
    ADC #$0040
    STA $00
    TAX 
    LDA $worldReadyFlag
    AND #$00FF
    BEQ loc_02B98A
    LDA [$3E]
    STA $7F0200, X
    INX 
    INX 
    LDA #$2020

  loc_02B971:
    STA $7F0200, X
    INX 
    INX 
    DEC $18
    BNE loc_02B971
    LDA [$3E], Y
    STA $7F0200, X
    LDA $00
    CLC 
    ADC #$0040
    STA $00
    TAX 

  loc_02B98A:
    LDA $3E
    CLC 
    ADC #$0004
    STA $3E
    PLY 
    RTS 
}

code_02B994 {
    PHP 
    LDX $099E
    LDA $098E, X
    ASL 
    CLC 
    ADC $0986, X
    ASL 
    ASL 
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $098A, X
    CLC 
    ADC $0982, X
    ASL 
    TAX 
    PLP 
    BCC loc_02B9CA
    LDA $36
    BIT #$000F
    BNE loc_02B9BC
    INC $playerYTile

  loc_02B9BC:
    LDA $playerYTile
    BIT #$0001
    BEQ loc_02B9CA
    LDA #$203D
    PHA 
    BRA loc_02B9CE

  loc_02B9CA:
    LDA #$2020
    PHA 

  loc_02B9CE:
    PLA 
    STA $7F0200, X
    RTS 
}

code_02B9D4 {
    JSR $&code_02B56A
    BCC loc_02B9DE
    JSR $&code_02B5FF
    BRA loc_02B9E1

  loc_02B9DE:
    JSR $&code_02B694

  loc_02B9E1:
    JSR $&code_02B6B8
    LDA $worldReadyFlag
    BNE loc_02B9EA
    RTS 

  loc_02B9EA:
    LDA $06
    CMP #$0020
    BNE loc_02B9F2
    RTS 

  loc_02B9F2:
    LDA $sfxQueueCh1
    AND #$FF00
    ORA $playerActor
    STA $sfxQueueCh1
    RTS 
}

code_02B9FF {
    PHD 
    PHX 
    PHA 
    LDA #$0000
    TCD 
    PHA 
    STA $playerYTile

  code_02BA0A:
    JSR $&code_02BB2D
    JSR $&code_02BD1E
    LDA $joypadCurrent
    BIT #$CF80
    BEQ code_02BA0A
    PHA 
    LDA #$CFF0
    TSB $joypadHeld
    PLA 
    BIT #$0800
    BNE loc_02BA70
    BIT #$0400
    BNE loc_02BAA6
    BIT #$0300
    BEQ loc_02BA32
    JMP $&code_02BAE6

  loc_02BA32:
    BIT #$8080
    BNE loc_02BA45
    BIT #$4000
    BEQ code_02BA0A
    JSR $&code_02BBD7
    PLA 
    LDA #$0000
    BRA loc_02BA63

  loc_02BA45:
    LDA $000A
    PHA 
    LDA $000C
    PHA 
    SEP #$20
    LDA #$11
    STA $sfxQueueCh2
    REP #$20
    PLA 
    STA $000C
    PLA 
    STA $000A
    JSR $&code_02BBD7
    PLA 
    INC 

  loc_02BA63:
    PHA 
    JSR $&code_02BD1E
    PLA 
    STZ $playerYTile
    PLY 
    PLX 
    PLD 
    SEC 
    RTL 

  loc_02BA70:
    SEP #$20
    LDA #$10
    STA $sfxQueueCh2
    REP #$20
    STZ $playerYTile
    SEP #$20
    LDA $03, S
    AND #$0F
    STA $1C
    LDA $03, S
    LSR 
    LSR 
    LSR 
    LSR 
    STA $18
    LDA $01, S
    DEC 
    BMI loc_02BA98
    STA $01, S
    REP #$20
    JMP $&code_02BA0A

  loc_02BA98:
    LDA $18
    BNE loc_02BA9E
    LDA $1C

  loc_02BA9E:
    DEC 
    STA $01, S
    REP #$20
    JMP $&code_02BA0A

  loc_02BAA6:
    SEP #$20
    LDA #$10
    STA $sfxQueueCh2
    REP #$20
    STZ $playerYTile
    SEP #$20
    LDA $03, S
    AND #$0F
    STA $1C
    LDA $03, S
    LSR 
    LSR 
    LSR 
    LSR 
    STA $18
    LDA $01, S
    CMP $1C
    BCS loc_02BAD8
    INC 
    CMP $1C
    BCS loc_02BACF
    BRA loc_02BAD1

  loc_02BACF:
    LDA #$00

  loc_02BAD1:
    STA $01, S
    REP #$20
    JMP $&code_02BA0A

  loc_02BAD8:
    INC 
    CMP $18
    BCC loc_02BADF
    LDA $1C

  loc_02BADF:
    STA $01, S
    REP #$20
    JMP $&code_02BA0A
}

code_02BAE6 {
    STZ $playerYTile
    SEP #$20
    LDA $03, S
    AND #$0F
    STA $1C
    LDA $03, S
    LSR 
    LSR 
    LSR 
    LSR 
    STA $18
    LDA $01, S
    CMP $1C
    BCS loc_02BB13
    CLC 
    ADC $1C
    CMP $18
    BCC loc_02BB08
    LDA $01, S

  loc_02BB08:
    STA $01, S
    CMP $1C
    REP #$20
    BCS loc_02BB21
    JMP $&code_02BA0A

  loc_02BB13:
    SEC 
    SBC $1C
    STA $01, S
    CMP $1C
    REP #$20
    BCC loc_02BB21
    JMP $&code_02BA0A

  loc_02BB21:
    SEP #$20
    LDA #$10
    STA $sfxQueueCh2
    REP #$20
    JMP $&code_02BA0A
}

code_02BB2D {
    LDA $playerYTile
    INC 
    STA $playerYTile
    BIT #$0010
    BNE loc_02BB45
    LDA #$20CC
    STA $00
    LDA #$20CD
    STA $02
    BRA loc_02BB4C

  loc_02BB45:
    LDA #$2020
    STA $00
    STA $02

  loc_02BB4C:
    LDA $playerYPos
    BEQ loc_02BB62
    LDX $playerXPos
    LDA $playerYPos
    STA $7F0200, X
    LDA $playerXTile
    STA $7F0240, X

  loc_02BB62:
    SEP #$20
    LDA $05, S
    AND #$0F
    STA $1C
    LDA $05, S
    LSR 
    LSR 
    LSR 
    LSR 
    STA $18
    LDA $03, S
    CMP $1C
    BCC loc_02BB86
    SEC 
    SBC $1C
    STA $1C
    STZ $1D
    LDX #$0018
    STX $18
    BRA loc_02BB8F

  loc_02BB86:
    STA $1C
    STZ $1D
    LDX #$0000
    STX $18

  loc_02BB8F:
    REP #$20
    LDX $099E
    LDA $06, S
    AND #$00FF
    CLC 
    ADC $1C
    ASL 
    CLC 
    ADC $0986, X
    ASL 
    ASL 
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $0982, X
    ASL 
    CLC 
    ADC $18
    TAX 
    LDA $7F0200, X
    PHA 
    LDA $00
    STA $7F0200, X
    LDA $7F0240, X
    PHA 
    LDA $02
    STA $7F0240, X
    STX $playerXPos
    PLA 
    STA $playerXTile
    PLA 
    STA $playerYPos
    LDA #$0001
    TSB $09FA
    RTS 
}

code_02BBD7 {
    PHY 
    LDX $playerXPos
    LDA $playerYPos
    STA $7F0200, X
    AND #$03FF
    ASL 
    ASL 
    ASL 
    ORA #$6000
    STA $090E
    LDA $playerXTile
    STA $7F0240, X
    AND #$03FF
    ASL 
    ASL 
    ASL 
    ORA #$6000
    STA $0910
    LDX $099E
    LDA #$0000
    STA $099A, X
    LDY #$0000
    LDX #$000F

  loc_02BC10:
    LDA $@code_02BC2E, X
    XBA 
    ORA #$00FF
    STA $091A, Y
    INY 
    INY 
    DEX 
    BPL loc_02BC10
    STZ $playerYPos
    STZ $playerXTile
    LDA #$0003
    TSB $09FA
    PLY 
    RTS 
}

code_02BC2E {
    SBC $@gfx_garden_enemies+141E, X
    STA $@scene_warps+16B
    STA ($83, X)
    STA [$8F]
    STA $@3FFFFF, X
}

code_02BC3E {
    LDX $099E
    LDA $098A, X
    TAY 
    PHA 
    LDA $098E, X
    PHA 
    LDA $0982, X
    STA $00
    LDA $0986, X
    STA $02
    JSR $&code_02BCD1
    PHA 
    STA $00
    LDX $099E
    BEQ loc_02BC68
    LDA #$2200
    ORA $0992, X
    PHA 
    BRA loc_02BC82

  loc_02BC68:
    LDA #$2100
    ORA $0992, X
    CLC 
    ADC $00B4
    PHA 
    BRA loc_02BC82

  loc_02BC75:
    LDA $01, S
    BIT #$000F
    BNE loc_02BC82
    CLC 
    ADC #$0010
    STA $01, S

  loc_02BC82:
    LDA $03, S
    TAX 
    LDA $01, S
    STA $7F0200, X
    CLC 
    ADC #$0010
    STA $7F0240, X
    LDA $01, S
    INC 
    INX 
    INX 
    STA $7F0200, X
    CLC 
    ADC #$0010
    STA $7F0240, X
    LDA $01, S
    INC 
    INC 
    STA $01, S
    INX 
    INX 
    TXA 
    STA $03, S
    DEY 
    BNE loc_02BC75
    LDA $07, S
    TAY 
    LDA $00
    CLC 
    ADC #$0080
    STA $00
    STA $03, S
    LDA $05, S
    DEC 
    STA $05, S
    BNE loc_02BC75
    LDA #$0001
    TSB $09FA
    PLA 
    PLA 
    PLA 
    PLA 
    RTS 
}

code_02BCD1 {
    LDA $02
    ASL 
    ASL 
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $00
    ASL 
    RTS 
}

code_02BCDD {
    LDA #$0007
    PHA 
    LDX $099E
    BNE loc_02BCEC
    LDA #$6800
    PHA 
    BRA loc_02BCF0

  loc_02BCEC:
    LDA #$7000
    PHA 

  loc_02BCF0:
    LDA $01, S
    LDX #$0010
    STX $090E
    LDY #$0000

  loc_02BCFB:
    STA $091A, Y
    INY 
    INY 
    INY 
    INY 
    CLC 
    ADC #$0010
    DEX 
    BNE loc_02BCFB
    STA $01, S
    LDA #$0004
    TSB $09FA
    JSR $&code_02BD1E
    LDA $03, S
    DEC 
    STA $03, S
    BNE loc_02BCF0
    PLA 
    PLA 
    RTS 
}

code_02BD1E {
    LDA #$0001
}

code_02BD21 {
    PHP 
    SEP #$20
    BRA loc_02BD2D
}

code_02BD26 {
    PHP 
    SEP #$20
    LDA $007E
    INC 

  loc_02BD2D:
    PHA 
    LDA $worldReadyFlag
    BEQ loc_02BD3D
    PLA 
    JSL $@chunk_008000.code_008122
    DEC 
    BNE loc_02BD2D
    PLP 
    RTS 

  loc_02BD3D:
    PLA 
    JSL $@chunk_008000.code_008546
    PLP 
    RTS 
}

code_02BD44 {
    LDA $09FB
    BPL loc_02BD4A
    RTL 

  loc_02BD4A:
    LDA $09FA
    BIT #$31
    BNE loc_02BD52
    RTL 

  loc_02BD52:
    BIT #$01
    BEQ loc_02BD6A
    LDX #$0800
    STX $DAS0L
    LDX #$7800
    STX $VMADDL
    LDX #$0200
    STX $A1T0L
    BRA loc_02BD90

  loc_02BD6A:
    LDA $09FA
    BIT #$20
    BNE loc_02BD79
    LDX #$0140
    STX $DAS0L
    BRA loc_02BD84

  loc_02BD79:
    AND #$DF
    STA $09FA
    LDX #$0140
    STX $DAS0L

  loc_02BD84:
    LDX #$7840
    STX $VMADDL
    LDX #$0280
    STX $A1T0L

  loc_02BD90:
    LDA #$31
    TRB $09FA
    LDA #$80
    STA $VMAIN
    LDA #$01
    STA $DMAP0
    LDA #$18
    STA $BBAD0
    LDA #$7F
    STA $A1B0
    LDA #$01
    STA $MDMAEN
    RTL 
}

code_02BDAF {
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
    JSL $@code_0282F6
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

code_02BDDB {
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

code_02BE02 {
    PHP 
    SEP #$20
    LDA $02
    INC 
    BIT #$0F
    BEQ loc_02BE12
    STA $02
    LDX $02
    PLP 
    RTL 

  loc_02BE12:
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

code_02BE1F {
    PHP 
    REP #$20
    LDA $02
    SEP #$20
    DEC 
    PHA 
    AND #$0F
    CMP #$0F
    BEQ loc_02BE32
    PLA 
    TAX 
    PLP 
    RTL 

  loc_02BE32:
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

code_02BE3E {
    PHP 
    REP #$20
    LDA $02
    SEP #$20
    CLC 
    ADC #$10
    BCS loc_02BE4F
    TAX 
    STX $02
    PLP 
    RTL 

  loc_02BE4F:
    XBA 
    CLC 
    ADC $mapRowStrideL0
    XBA 
    TAX 
    STX $02
    PLP 
    RTL 
}

code_02BE5A {
    PHP 
    LDA $02
    SEP #$20
    CLC 
    ADC #$10
    BCS loc_02BE69
    TAX 
    STX $02
    PLP 
    RTL 

  loc_02BE69:
    XBA 
    CLC 
    ADC $mapRowStrideL1
    XBA 
    TAX 
    STX $02
    PLP 
    RTL 
}

code_02BE74 {
    JSR $&code_02EE33
    REP #$20
    LDA $1A
    CLC 
    ADC #$0008
    STA $1A
    SEP #$20
    JSR $&code_02EEF1
    CMP #$0A
    BEQ loc_02BEC1
    CMP #$05
    BEQ loc_02BEC3
    CMP #$09
    BNE loc_02BE9C
    JSR $&code_02EF6D
    JSR $&code_02EF3E
    CMP #$0A
    BEQ loc_02BEC1

  loc_02BE9C:
    JSR $&code_02EF55
    JSR $&code_02EF3E
    CMP #$0A
    BEQ loc_02BEC1
    CMP #$05
    BEQ loc_02BEC3
    JSR $&code_02EEA5
    CMP #$0A
    BEQ loc_02BEC4
    CMP #$05
    BEQ loc_02BEC6
    JSR $&code_02EEC7
    CMP #$0A
    BEQ loc_02BEC4
    CMP #$05
    BEQ loc_02BEC6
    RTS 

  loc_02BEC1:
    CLC 
    RTS 

  loc_02BEC3:
    RTS 

  loc_02BEC4:
    CLC 
    RTS 

  loc_02BEC6:
    RTS 
}

code_02BEC7 {
    JSR $&code_02EDEB
    REP #$20
    LDA $1A
    SEC 
    SBC #$0008
    STA $1A
    SEP #$20
    JSR $&code_02EEF1
    CMP #$0A
    BEQ loc_02BF15
    CMP #$05
    BEQ loc_02BF14
    CMP #$06
    BNE loc_02BEEF
    JSR $&code_02EF6D
    JSR $&code_02EF3E
    CMP #$05
    BEQ loc_02BF14

  loc_02BEEF:
    JSR $&code_02EF55
    JSR $&code_02EF3E
    CMP #$0A
    BEQ loc_02BF15
    CMP #$05
    BEQ loc_02BF14

  loc_02BEFD:
    JSR $&code_02EE4F
    CMP #$0A
    BEQ loc_02BF18
    CMP #$05
    BEQ loc_02BF17
    JSR $&code_02EE79
    CMP #$0A
    BEQ loc_02BF18
    CMP #$05
    BEQ loc_02BF17
    RTS 

  loc_02BF14:
    RTS 

  loc_02BF15:
    CLC 
    RTS 

  loc_02BF17:
    RTS 

  loc_02BF18:
    CLC 
    RTS 
}

code_02BF1A {
    LDA $characterForm
    CMP #$02

  loc_02BF1F:
    BRK #$F0
    COP [QueueDma] ( $A202E0, #99 )
    LDA $280082, X

  code_02BF2B:
    LDY $06
    LDA #$99
    LDA $000099, X
    LDA #$00
    BRK #$99
    PHP 
    BRK #$02
    CMP ($20, X)
    BVS loc_02BEFD
    LDA $09C0
    ORA $decelCurvePtr
    BNE code_02BF4D
    COP [BranchIfFlagByte] ( #00, #01, &code_02BF4D )
    RTL 
}

code_02BF4D {
    LDY $06
    LDA #$A0
    LDA $000099, X
    LDA #$00
    BRK #$99
    PHP 
    BRK #$02

  code_02BF5C:
    CMP ($20, X)
    BVS loc_02BF1F
    LDA $09C0
    ORA $decelCurvePtr
    BEQ loc_02BF69
    RTL 

  loc_02BF69:
    COP [BranchIfFlagByte] ( #00, #00, &code_02BF2B )
    RTL 
}

code_02BF70 {
    LDA $characterForm
    CMP #$02
    BRK #$D0
    ASL $&table_01B06E.delta_node_01B8AC, X
    ORA #$B9
    BPL loc_02BF7E

  loc_02BF7E:
    BIT #$40
    BRK #$D0
    ORA ($60, X)
    PLA 
    LDY $06
    LDA #$A7
    LDA $000099, X
    LDA #$00
    BRK #$99
    PHP 
    BRK #$02
    CMP ($6B, X)
    PLA 
    COP [Die]

  loc_02BF99:
    COP [PaletteStart] ( #23 )
    COP [PaletteStep]
    BRA loc_02BF99

  loc_02BFA0:
    COP [PaletteStart] ( #24 )
    COP [PaletteStep]
    BRA loc_02BFA0

  loc_02BFA7:
    COP [SetEntryContinue]
    RTL 
}

code_02BFAA {
    LDA $14
    ASL 
    ASL 
    STA $14
    LDA $16
    ASL 
    ASL 
    STA $16
    COP [SetEntryContinue]
    LDA $slopeCurvePtrB
    BIT #$00
    ASL 
    BEQ loc_02BFC7
    STZ $extVelocityX
    STZ $extVelocityY
    RTL 

  loc_02BFC7:
    LDY $decelStepCounter
    LDA $14
    LSR 
    LSR 
    CMP $0014, Y
    BEQ loc_02BFDA
    LDA $0014, Y
    ASL 
    ASL 
    STA $14

  loc_02BFDA:
    LDA $16
    LSR 
    LSR 
    CMP $0016, Y

  loc_02BFE1:
    BEQ loc_02BFEA
    LDA $0016, Y
    ASL 
    ASL 
    STA $16

  loc_02BFEA:
    LDA $slopeCurvePtrB
    BIT #$00
    BMI loc_02BFE1
    ORA $A9
    BRK #$00
    BRA loc_02BFFA

  loc_02BFF7:
    JSR $&code_02C0BD

  loc_02BFFA:
    PHA 
    LDA $14
    STA $0022
    STZ $0020
    LDA $09C0
    BNE loc_02C01E
    LDA $01, S
    AND #$FF
    BRK #$89
    BRA loc_02C010

  loc_02C010:
    BEQ loc_02C015
    ORA #$00
    SBC $086D18, X
    TSB $8D
    JSR $&code_028000
    ORA $180A0A
    ADC $extVelocityX
    STA $0020
    LDA #$00
    BPL loc_02C047
    LDY $&scene_warps.warp_def_019C02+7, X
    PHP 
    TSB $9C
    BIT $00
    LDA $16
    STA $0026
    LDA $decelCurvePtr
    BNE loc_02C057
    STZ $09D4
    LDA $01, S
    XBA 
    AND #$FF
    BRK #$89

  loc_02C047:
    BRA loc_02C049

  loc_02C049:
    BEQ loc_02C04E
    ORA #$00
    SBC $0A6D18, X
    TSB $8D
    BIT $00
    BRA loc_02C066

  loc_02C057:
    ASL 
    ASL 
    CLC 
    ADC $extVelocityY
    STA $0024
    LDA #$00
    BPL loc_02C080
    LDY $&scene_warps.warp_def_019C02+7, X
    ASL 
    TSB $68
    LDY $decelStepCounter
    LDA $0010, Y
    BIT #$08
    BRK #$D0
    ASL $AD, X
    JSR $1800
    ADC $0022
    STA $0022
    LDA $0024
    CLC 
    ADC $0026
    STA $0026
    BRA loc_02C093

  loc_02C08B:
    STX $000A
    TXY 
    JSL $@code_02DC18

  loc_02C093:
    LDY $decelStepCounter
    LDA $0022
    STA $14
    LSR 
    LSR 
    STA $0014, Y
    LDA $0026
    STA $16
    LSR 
    LSR 
    STA $0016, Y
    LDA $0010, Y
    AND #$FB
    SBC $@gfx_angel+1641, X
    AND #$04
    BRK #$03
    ORA ($99, X)
    BPL loc_02C0BB

  loc_02C0BB:
    PLA 
    RTL 
}

code_02C0BD {
    PHP 
    SEP #$20
    LDA $0657
    BIT #$02
    BNE loc_02C0DA
    BIT #$01
    BNE loc_02C0F7
    BIT #$08
    BNE loc_02C114
    BIT #$04
    BNE loc_02C11B
    LDA #$00
    XBA 
    LDA #$00
    BRA loc_02C0F5

  loc_02C0DA:
    BIT #$0C
    BEQ loc_02C0F0
    BIT #$08
    BNE loc_02C0E9
    LDA #$06
    XBA 
    LDA #$FA
    BRA loc_02C0F5

  loc_02C0E9:
    LDA #$FA
    XBA 
    LDA #$FA
    BRA loc_02C0F5

  loc_02C0F0:
    LDA #$00
    XBA 
    LDA #$F8

  loc_02C0F5:
    PLP 
    RTS 

  loc_02C0F7:
    BIT #$0C
    BEQ loc_02C10D
    BIT #$08
    BNE loc_02C106
    LDA #$06
    XBA 

  code_02C102:
    LDA #$06
    BRA loc_02C112

  loc_02C106:
    LDA #$FA
    XBA 
    LDA #$06
    BRA loc_02C112

  loc_02C10D:
    LDA #$00
    XBA 
    LDA #$08

  loc_02C112:
    PLP 
    RTS 

  loc_02C114:
    LDA #$F8
    XBA 
    LDA #$00
    PLP 
    RTS 

  loc_02C11B:
    LDA #$08
    XBA 
    LDA #$00
    PLP 
    RTS 
}

code_02C122 {
    COP [SetEntryContinue]
    PHX 
    LDX $decelStepCounter
    LDA $0010, X
    BIT #$C0
    BRK #$F0
    ASL 
    LDA $iframeCounter, X
    BMI loc_02C13A
    PLX 
    JMP $&code_02C252

  loc_02C13A:
    PLX 
    LDA $09C0
    ORA $decelCurvePtr
    BEQ loc_02C1B7
    PHX 
    PHD 
    LDA #$00
    BRK #$5B
    LDY $decelStepCounter
    LDA $0014, Y
    STA $1A
    LDA $0016, Y
    SEC 
    SBC #$08
    BRK #$85
    ASL $&01F120, X
    INC $&01FF29
    BRK #$0A
    TAX 
    LDA $@code_02C273, X
    BEQ loc_02C16B
    DEC 
    PHA 
    RTS 

  loc_02C16B:
    TXA 
    LSR 
    CMP #$06
    BRK #$F0
    PHP 
    CMP #$09
    BRK #$F0
    ORA $4C, S
    EOR [$C2]
    JSR $&code_02EF55
    SEP #$20
    JSR $&code_02EF3E
    REP #$20
    AND #$00FF
    CMP #$0005
    BNE loc_02C18F
    JMP $&code_02C234

  loc_02C18F:
    CMP #$000A
    BNE loc_02C197
    JMP $&code_02C239

  loc_02C197:
    JSR $&code_02EF6D
    SEP #$20
    JSR $&code_02EF3E
    REP #$20
    AND #$00FF
    CMP #$0005
    BNE loc_02C1AC
    JMP $&code_02C234

  loc_02C1AC:
    CMP #$000A
    BNE loc_02C1B4
    JMP $&code_02C239

  loc_02C1B4:
    JMP $&code_02C247

  loc_02C1B7:
    LDA $slopeCurvePtrB
    BIT #$00
    BPL loc_02C18E
    ORA $4C, S
    EOR ($C2)
    STZ $09C4
    STZ $slopeFracAccum
    PHX 
    PHD 
    LDY $decelStepCounter
    LDA $playerWallType
    STA $001A
    LDA $playerSpeedEw
    STA $001E
    LDA #$00
    BRK #$5B
    JSR $&code_02EEF1
    AND #$FF
    BRK #$0A
    TAX 
    LDA $@code_02C273, X
    BNE loc_02C22C
    JSR $&code_02EF85
    SEP #$20
    JSR $&code_02EF3E
    REP #$20
    AND #$00FF
    ASL 
    TAX 
    LDA $@code_02C273, X
    BNE loc_02C22C
    JSR $&code_02EF55
    STX $00
    SEP #$20
    JSR $&code_02EF3E
    REP #$20
    AND #$00FF
    ASL 
    TAX 
    LDA $@code_02C273, X
    BNE loc_02C22C
    JSR $&code_02EF85
    SEP #$20
    JSR $&code_02EF3E
    REP #$20
    AND #$00FF
    ASL 
    TAX 
    LDA $@code_02C273, X
    BEQ code_02C247

  loc_02C22C:
    DEC 
    PHA 
    RTS 
}

code_02C22F {
    JSR $&code_02C2D9
    BRA loc_02C241
}

code_02C234 {
    JSR $&code_02C293
    BRA loc_02C241
}

code_02C239 {
    JSR $&code_02C2B3
    BRA loc_02C241

  loc_02C23E:
    JSR $&code_02C2F5

  loc_02C241:
    JSR $&code_02C315
    PLD 
    PLX 
    RTL 
}

code_02C247 {
    JSR $&code_02C315
    STZ $09D4
    STZ $09C4
    PLD 
    PLX 
}

code_02C252 {
    LDA $09C0
    BEQ loc_02C25B
    JSR $&code_02C36C
    RTL 

  loc_02C25B:
    LDA $slopeCurvePtrB
    BIT #$00
    BPL code_02C252
    ASL $29
    SBC $@3C8DEF, X
    ORA #$AD
    REP #$09
    BNE loc_02C26F
    RTL 

  loc_02C26F:
    JSR $&code_02C40B
    RTL 
}

code_02C273 {
    BRK #$00
    BRK #$00
    BRK #$00
    AND $0000C2
    BIT $C2, X
    BRK #$00
    BRK #$00
    BRK #$00
    BRK #$00
    AND $00C2, Y
    BRK #$3E
    REP #$00
    BRK #$00
    BRK #$00
    BRK #$AD
    CPY $09
    AND #$0F
    BRK #$0A
    CLC 
    ADC $maxSpeedEw
    TAY 
    LDA $0000, Y
    EOR #$FF
    SBC $@2D181A, X
    CPY #$8D09
    CPY #$F009
    JSR $&code_02C4EE
    ORA #$60
}

code_02C2B3 {
    LDA $09C4
    AND #$000F
    ASL 
    CLC 
    ADC $maxSpeedEw
    TAY 
    LDA $0000, Y
    CLC 
    ADC $09C0
    STA $09C0
    BEQ loc_02C2CF
    INC $09C4
    RTS 

  loc_02C2CF:
    STZ $09C4
    LDA #$1000
    TSB $slopeCurvePtrB
    RTS 
}

code_02C2D9 {
    LDA $09C4
    AND #$0F
    BRK #$0A
    CLC 
    ADC $maxSpeedNs
    TAY 
    LDA $0000, Y
    CLC 
    ADC $decelCurvePtr
    STA $decelCurvePtr
    BEQ loc_02C2CF
    INC $09C4
    RTS 
}

code_02C2F5 {
    LDA $09C4
    AND #$000F
    ASL 
    CLC 
    ADC $maxSpeedNs
    TAY 
    LDA $0000, Y
    EOR #$FFFF
    INC 
    CLC 
    ADC $decelCurvePtr
    STA $decelCurvePtr
    BEQ loc_02C2CF
    INC $09C4
    RTS 
}

code_02C315 {
    LDA $09C0
    BEQ loc_02C340
    BPL loc_02C332
    EOR #$FF
    SBC $@palette_bundles.palette_bundle_16CD01+19, X
    ORA #$10
    ORA ($60, X)
    LDA $09D6
    DEC 
    EOR #$FF
    SBC $@chunk_008000.code_008D15+5, X
    ORA #$60

  loc_02C332:
    CMP $09D6
    BPL loc_02C338
    RTS 

  loc_02C338:
    LDA $09D6
    DEC 
    STA $09C0
    RTS 

  loc_02C340:
    LDA $decelCurvePtr
    BNE loc_02C346
    RTS 

  loc_02C346:
    BPL loc_02C35E
    EOR #$FF
    SBC $@gfx_cliff+2400, X
    ORA #$10
    ORA ($60, X)
    LDA $09D8
    DEC 
    EOR #$FF
    SBC $@code_028CFC+1E, X
    ORA #$60

  loc_02C35E:
    CMP $09D8
    BPL loc_02C364

  loc_02C363:
    RTS 

  loc_02C364:
    LDA $09D8
    DEC 
    STA $decelCurvePtr
    RTS 
}

code_02C36C {
    LDA $slopeCurvePtrB
    BIT #$00
    BPL loc_02C363
    ORA ($60, X)
    LDA $09C0
    BPL loc_02C37E
    EOR #$FF
    SBC $@chunk_3B7DD.loc_03C908+12, X
    BRK #$10
    TSB $9C
    CPY #$6009
    LDA $09C0
    BMI loc_02C3C8
    LDA $joypadCurrent
    BIT #$00
    ORA ($F0, X)
    ORA ($60, X)
    JSR $&code_02C3F8
    BEQ loc_02C3A7
    EOR #$FF
    SBC $@2D181A, X
    CPY #$8D09
    CPY #$F009
    ORA $56AD, X
    ASL $89
    BRK #$02
    BNE loc_02C3B0
    RTS 

  loc_02C3B0:
    JSR $&code_02C3F8
    BNE loc_02C3B6
    RTS 

  loc_02C3B6:
    EOR #$FF
    SBC $@2D181A, X
    CPY #$8D09
    CPY #$F009
    ORA ($60, X)

  loc_02C3C4:
    STZ $slopeFracAccum
    RTS 

  loc_02C3C8:
    LDA $joypadCurrent
    BIT #$00
    COP #$F0
    ORA ($60, X)
    JSR $&code_02C3F8
    BEQ loc_02C3DF
    CLC 
    ADC $09C0
    STA $09C0
    BEQ loc_02C3C4

  loc_02C3DF:
    LDA $joypadCurrent
    BIT #$00
    ORA ($D0, X)
    ORA ($60, X)
    JSR $&code_02C3F8
    BNE loc_02C3EE
    RTS 

  loc_02C3EE:
    CLC 
    ADC $09C0
    STA $09C0
    BEQ loc_02C3C4
    RTS 
}

code_02C3F8 {
    LDA $slopeFracAccum
    INC $slopeFracAccum
    AND #$0F
    BRK #$0A

  loc_02C402:
    CLC 
}

code_list_02C403 [
  &code_02D06D   ;00
  &code_02A809   ;01
  $#00B9   ;02
  $#6000   ;03
]

code_02C40B {
    LDA $slopeCurvePtrB
    BIT #$00
    BPL loc_02C402
    ORA ($60, X)
    LDA $decelCurvePtr
    BPL loc_02C41D
    EOR #$FF
    SBC $@chunk_3B7DD.loc_03C908+12, X
    BRK #$10
    TSB $9C
    REP #$09
    RTS 
}

code_02C426 {
    LDA $decelCurvePtr
    BMI loc_02C467
    LDA $joypadCurrent
    BIT #$00
    TSB $F0
    ORA ($60, X)
    JSR $&code_02C497
    BEQ loc_02C446
    EOR #$FF
    SBC $@2D181A, X
    REP #$09
    STA $decelCurvePtr
    BEQ loc_02C463

  loc_02C446:
    LDA $joypadCurrent
    BIT #$00
    PHP 
    BNE loc_02C44F
    RTS 

  loc_02C44F:
    JSR $&code_02C497
    BNE loc_02C455
    RTS 

  loc_02C455:
    EOR #$FF
    SBC $@2D181A, X
    REP #$09
    STA $decelCurvePtr
    BEQ loc_02C463
    RTS 

  loc_02C463:
    STZ $09C4
    RTS 

  loc_02C467:
    LDA $joypadCurrent
    BIT #$00
    PHP 
    BEQ loc_02C470
}

code_02C46F {
    RTS 

  loc_02C470:
    JSR $&code_02C497
    BEQ loc_02C47E
    CLC 
    ADC $decelCurvePtr
    STA $decelCurvePtr
    BEQ loc_02C463

  loc_02C47E:
    LDA $joypadCurrent
    BIT #$00
    TSB $D0
    ORA ($60, X)
    JSR $&code_02C497
    BNE loc_02C48D
    RTS 

  loc_02C48D:
    CLC 
    ADC $decelCurvePtr
    STA $decelCurvePtr
    BEQ loc_02C463
    RTS 
}

code_02C497 {
    LDA $slopeFracAccum
    INC $slopeFracAccum
    AND #$0F
    BRK #$0A
    CLC 
    ADC $09D0
    TAY 
    LDA $0000, Y
    RTS 
}

code_02C4AA {
    LDA $slopeCurvePtrB
    BIT #$08
    BRK #$F0
    COP [QueueDma] ( @table_01A946.dma_channel_01A9E0, #00 )
    TRB $slopeCurvePtrB
    COP [SetEntryContinue]
    LDA $slopeCurvePtrB
    BIT #$00
    ROL 
    BEQ loc_02C4C5
    RTL 

  loc_02C4C5:
    LDA $characterForm
    CMP #$02
    BRK #$90
    ORA ($6B, X)
    COP [BranchIfButton] ( #$8001, &code_02C4D5 )
    RTL 
}

code_02C4D5 {
    LDA #$01
    BRK #$0C
    LDY $&scene_warps.warp_def_01A8B4+55, X
    BRK #$80
    TSB $joypadHeld
    LDA $characterForm
    BEQ loc_02C4E9
    JMP $&code_02C564

  loc_02C4E9:
    LDA $abilityBitmask
    BIT #$05
}

code_02C4EE {
    BRK #$D0
    ORA ($6B, X)
    COP [LoopInit] ( #28 )
    COP [BranchIfNoButton] ( #$8001, &code_02C4B4 )
    COP [LoopNext]
    JSR $&code_02C63D
    COP [SpawnLastRel] ( @code_02CF5B, #00, #00, #$2C00 )
    STY $22
    LDA #$78
    BRK #$85
    BIT $02
    CMP ($20, X)
    BIT $C6, X
    COP [BranchIfNoButton] ( #$8001, &code_02C5EF )
    DEC $24
    BMI loc_02C520
    RTL 

  loc_02C520:
    LDA $abilityBitmask
    BIT #$04
    BRK #$D0
    TSB $&table_01B06E.delta_node_01C100+2
    JSR $&code_02C634
    COP [BranchIfNoButton] ( #$8001, &code_02C54C )
    RTL 
}

code_02C534 {
    COP [SetEntryContinue]
    JSR $&code_02C634
    COP [BranchIfNoButton] ( #$8001, &code_02C54C )
    JSR $&code_02C64B
    BCC loc_02C545
    RTL 

  loc_02C545:
    COP [BranchIfButton] ( #$0030, &code_02C558 )
    RTL 
}

code_02C54C {
    JSR $&code_02C621
    LDA #$00
    WAI 
    JSR $&code_02C614
    JMP $&code_02C5EF
}

code_02C558 {
    JSR $&code_02C621
    LDA #$09
    CMP $1420
    DEC $4C
    SBC $@22ADC5
    ASL 
    BIT #$50
    BRK #$D0
    ORA ($6B, X)
    COP [LoopInit] ( #28 )
    COP [BranchIfNoButton] ( #$8001, &code_02C4B4 )
    COP [LoopNext]
    JSR $&code_02C63D
    COP [SpawnLastRel] ( @code_02CF68, #00, #00, #$2C00 )
    STY $22
    LDA #$64
    BRK #$85
    BIT $02
    CMP ($20, X)
    BIT $C6, X
    COP [BranchIfNoButton] ( #$8001, &code_02C5EF )
    COP [BranchIfButton] ( #$40B0, &code_02C5EF )
    DEC $24
    BMI loc_02C5A1
    RTL 

  loc_02C5A1:
    LDA $abilityBitmask
    BIT #$20
    BRK #$D0
    TSB $&table_01B06E.delta_node_01C100+2
    JSR $&code_02C634
    COP [BranchIfNoButton] ( #$8001, &code_02C5CD )
    RTL 
}

code_02C5B5 {
    COP [SetEntryContinue]
    JSR $&code_02C634
    COP [BranchIfNoButton] ( #$8001, &code_02C5CD )
    COP [BranchIfButton] ( #$0F00, &code_02C5CC )
    COP [BranchIfButton] ( #$0030, &code_02C5DE )
}

code_02C5CC {
    RTL 
}

code_02C5CD {
    LDA #$01
    BRK #$8D
    NOP 
    BRK #$20
    AND ($C6, X)
    LDA #$D3
    CMP [$20]
    TRB $C6
    BRA code_02C5EF
}

code_02C5DE {
    LDA #$02
    BRK #$8D
    NOP 
    BRK #$20
    AND ($C6, X)
    LDA #$6D
    DEC $20
    TRB $C6
    BRA code_02C5EF
}

code_02C5EF {
    PHX 
    PHD 
    LDA $22
    BEQ loc_02C5F9
    TCD 
    TAX 
    COP [MarkDeath]

  loc_02C5F9:
    PLD 
    PLX 
    LDA $characterForm
    BNE loc_02C60A
    COP [PaletteStart] ( #0B )
    COP [PaletteStep]
    COP [SetEntryExitNow] ( @code_02C4B4 )

  loc_02C60A:
    COP [PaletteStart] ( #0C )
    COP [PaletteStep]
    COP [SetEntryExitNow] ( @code_02C4B4 )
}

code_02C614 {
    LDY $decelStepCounter
    STA $0000, Y
    LDA #$00
    BRK #$99
    PHP 
    BRK #$60
}

code_02C621 {
    LDA $slopeCurvePtrB
    BIT #$00
    DEC 
    BNE loc_02C631
    COP [GetPlayerFacing]
    CMP #$04
    BRK #$B0
    ORA ($60, X)

  loc_02C631:
    PLA 
    BRA code_02C5EF
}

code_02C634 {
    LDA $slopeCurvePtrB
    BIT #$00
    PLD 
    BNE loc_02C631
    RTS 
}

code_02C63D {
    LDY $decelStepCounter
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    STA $16
    RTS 
}

code_02C64B {
    LDA $slopeCurvePtrB
    BIT #$00
    BRA loc_02C642

  loc_02C652:
    COP [PaletteStartLoop] ( #60, #AC )
    CLV 
    ORA #$B9
    PLP 
    BRK #$30
    INC $C9, X
    TSB $00
    BCC loc_02C66B
    SEC 
    SBC #$10
    BRK #$C9
    TSB $00
    BCS loc_02C653

  loc_02C66B:
    CLC 
    RTS 
}

code_02C66D {
    LDA #$00
    COP [StartMusic] ( #10 )
    LDA #$00
    PHP 
    TSB $slopeCurvePtrB
    COP [SetPlayerBodySprite] ( #06 )
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @code_02CF75, #00, #00, #$2000 )
    TYA 
    STA $orbitDiameter, X
    COP [StageSpriteLoop] ( #03, #02 )
    COP [AnimLoop]
    COP [AdhocVramDma] ( @misc_fx_1CC480, #$4400, #$0600 )
    COP [CopyPalette] ( @fx_palette_198090, #00, #A9, #07 )
    LDA #$01
    BRK #$1C
    LDY $0209, X
    LDA $C4
    DEC $82
    BRK #$F0
    BRK #$26
    COP [StageSpriteLoop] ( #03, #0A )
    COP [AnimLoop]
    JSR $&code_02CE6F
    LDA #$00
    COP [BranchIfSolidOffset] ( #10, #02, $64C5 )
    BIT $64
    ROL $A9
    BRK #$00
    STA $orbitDiameter, X
    LDA $0B1E
    BEQ loc_02C6E6
    COP [SpawnMarkedAfter] ( @code_02C7AB, #$0600 )
    INC $24
    COP [SpawnMarkedAfter] ( @code_02C7AB, #$0600 )
    INC $24

  loc_02C6E6:
    COP [SpawnMarkedAfter] ( @code_02C7AB, #$0600 )
    INC $24
    COP [SpawnMarkedAfter] ( @code_02C7AB, #$0600 )
    LDA #$F0
    BRK #$85
    JSR $&code_02C102
    LDA $slopeCurvePtrB
    BIT #$01
    BRK #$D0
    AND $A5
    ROL $18
    ADC #$02
    BRK #$29
    SBC $@268500, X
    STA $orbitAngle, X
    LDA $orbitDiameter, X
    CMP #$40
    BRK #$B0
    ORA $1A
    STA $orbitDiameter, X

  code_02C722:
    JSR $&code_02C76A
    DEC $20
    BMI loc_02C72A
    RTL 

  loc_02C72A:
    LDA $24
    STA $0000
    LDY $06

  loc_02C731:
    LDA #$C1
    CMP [$99]
    BRK #$00
    LDA #$00
    BRK #$99
    PHP 
    BRK #$B9
    ASL $00
    TAY 
    DEC $0000
    BPL loc_02C731
    COP [LoopInit] ( #1E )
    LDA $26
    CLC 
    ADC #$02
    BRK #$29
    SBC $@268500, X
    STA $orbitAngle, X
    LDA $orbitDiameter, X
    BEQ loc_02C763
    DEC 
    STA $orbitDiameter, X

  loc_02C763:
    JSR $&code_02C76A
    COP [LoopNext]
    COP [Die]
}

code_02C76A {
    PHD 
    LDA #$80
    BRK #$8D
    COP [GenHdmaSine]
    LDA $24
    STA $0000
    LDA $06

  loc_02C778:
    TCD 
    LDY $decelStepCounter
    JSL $@chunk_008000.code_00F4BD
    LDA $orbitAngle, X
    CLC 
    ADC $0002
    AND #$FF
    BRK #$9F
    BPL loc_02C78E

  loc_02C78E:
    ADC $0002AD, X
    CMP #$40
    BRK #$D0
    ORA $A9
    BRA loc_02C79A

  loc_02C79A:
    BRA loc_02C79F

  loc_02C79C:
    LDA #$40
    BRK #$8D
    COP [GenHdmaSine]
    LDA $06
    DEC $0000
    BPL loc_02C778
    PLD 
    RTS 
}

code_02C7AB {
    COP [SetMetasprite] ( @sprite_set_list_179000 )
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]

  loc_02C7BA:
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    BRA loc_02C7BA

  loc_02C7C1:
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    LDA #$00
    JSR $1004
    COP [SetEntryContinue]
    RTL 
}

code_02C7D3 {
    LDA #$00
    JSR $&code_02BC0C
    ORA #$02
    EOR $@misc_fx_1CC000
    BRK #$44
    BRA loc_02C7E6

  loc_02C7E2:
    COP [CopyPalette] ( @fx_palette_198070, #00, #A0, #10 )
    COP [SpawnThinkerParam] ( #4A, @chunk_008000.code_00B5C4 )
    COP [GetPlayerFacing]
    AND #$03
    BRK #$8D
    BRK #$00
    COP [SwitchCase] ( #$0000, &code_list_02C7FE )
}

code_list_02C7FE [
  &code_02C806   ;00
  &code_02C81F   ;01
  &code_02C838   ;02
  &code_02C851   ;03
]

code_02C806 {
    COP [SpawnLastRel] ( @code_02C86D, #FE, #1A, #$2600 )
    COP [SpawnLastRel] ( @code_02C88C, #FE, #1A, #$2600 )
    COP [StagePlayerSprite] ( #36 )
    COP [AnimOnce]
    BRA loc_02C868
}

code_02C81F {
    COP [SpawnLastRel] ( @code_02C86D, #00, #C0, #$2600 )
    COP [SpawnLastRel] ( @code_02C887, #00, #C0, #$2600 )
    COP [StagePlayerSprite] ( #37 )
    COP [AnimOnce]
    BRA loc_02C868
}

code_02C838 {
    COP [SpawnLastRel] ( @code_02C86D, #CC, #EA, #$2600 )
    COP [SpawnLastRel] ( @code_02C8D4, #CC, #EA, #$2600 )
    COP [StagePlayerSprite] ( #38 )
    COP [AnimOnce]
    BRA loc_02C868
}

code_02C851 {
    COP [SpawnLastRel] ( @code_02C86D, #34, #EA, #$2600 )
    COP [SpawnLastRel] ( @code_02C8D9, #34, #EA, #$2600 )
    COP [StagePlayerSprite] ( #39 )
    COP [AnimOnce]

  loc_02C868:
    COP [WaitByte] ( #07 )
    COP [RestoreSavedPtr]
}

code_02C86D {
    COP [SetMetasprite] ( @sprite_set_list_178000 )
    JSR $&code_02CAD2
    COP [WaitByte] ( #07 )
    JSR $&code_02CAE9

  loc_02C87B:
    LDA #$00
    JSR $1014
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    COP [Die]
}

code_02C887 {
    LDA #$00
    JSR $1204
}

code_02C88C {
    LDA #$00
    BRK #$20
    CLV 
    CMP $@chunk_008000.code_0087C5+3D
    BRA loc_02C82E

  loc_02C897:
    LDA $slopeCurvePtrB
    BIT #$80
    BRK #$F0
    ORA $02, S
    LDX $30, Y
    JSR $&code_02CAD2
    COP [WaitByte] ( #07 )
    JSR $&code_02CAE9
    LDA #$00
    JSR $1014
    LDA $0B1C
    BEQ loc_02C8BD
    COP [OrActorFlags] ( #$0010 )
    COP [SetCollideCallback] ( &code_02C952 )

  loc_02C8BD:
    COP [StageSpriteLoopMoveY] ( #01, #02, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #02, #03, #03 )
    COP [AnimLoop]
    COP [StageSprAndHitbox] ( #03 )
    COP [StageForceMoveXY] ( #00, #05 )
    BRA loc_02C92A
}

code_02C8D4 {
    LDA #$00
    RTI 
    TSB $12
}

code_02C8D9 {
    LDA #$00
    BRK #$20
    CLV 
    CMP $@chunk_008000.code_0087C5+3D
    BRA loc_02C87B

  loc_02C8E4:
    LDA $slopeCurvePtrB
    BIT #$80
    BRK #$F0
    ORA $02, S
    LDX $30, Y
    JSR $&code_02CAD2
    COP [WaitByte] ( #07 )
    JSR $&code_02CAE9
    LDA #$00
    JSR $1014
    LDA $0B1C
    BEQ loc_02C90A
    COP [OrActorFlags] ( #$0010 )
    COP [SetCollideCallback] ( &code_02C952 )

  loc_02C90A:
    COP [StageSpriteLoopMoveX] ( #01, #02, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #02, #03, #03 )
    COP [AnimLoop]
    COP [StageSprAndHitbox] ( #03 )
    COP [StageForceMoveXY] ( #05, #00 )
    BRA loc_02C92A

  loc_02C921:
    LDA $10
    BIT #$00
    RTI 
    BNE loc_02C94C
    COP [ReloadForceMove]

  loc_02C92A:
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_02C921
    LDA $08
    STZ $08
    STA $26
    LDA $0B1C
    CMP #$02
    BRK #$D0
    ASL $02
    RTI 
    ORA ($80, X)
    LSR $02C9
    REP #$C6
    ROL $10
    CPX $&01DE80

  loc_02C94C:
    COP [Die]

  loc_02C94E:
    COP [SetCollideCallback] ( #$0000 )
}

code_02C952 {
    COP [SpawnAfterFlags] ( @code_02C96C, #$0600 )
    COP [SpawnAfterFlags] ( @code_02C971, #$0600 )
    COP [SpawnAfterFlags] ( @code_02C976, #$0600 )
    LDA #$00
    BRK #$80
    ORA $40A9
    BRK #$80
    PHP 
}

code_02C971 {
    LDA #$80
    BRK #$80
    ORA $A9, S
    CPY #$9F00
    BPL loc_02C97C

  loc_02C97C:
    ADC $0000A9, X
    JSR $&code_02CFB8
    LDA #$00
    BRK #$9F
    ORA ($00)
    ADC $9F14A5, X
    CLC 
    BRK #$7F
    LDA $16
    STA $moveYAlt, X
    COP [SpawnMarkedAfter] ( @code_02CA5B, #$0600 )
    COP [SpawnMarkedAfter] ( @code_02CA56, #$0600 )
    LDA #$01
    BRK #$9F
    ASL $7F10
    STA $7F100C, X
    COP [StageSprAndHitbox] ( #04 )

  loc_02C9B2:
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_02C9B2
    LDA $08
    STZ $08
    STA $26

  loc_02C9BE:
    COP [SetEntryExit]
    SEP #$20
    LDA $orbitAngle, X
    CLC 
    ADC #$02
    STA $orbitAngle, X
    LDA $orbitDiameter, X
    CLC 
    ADC #$04
    STA $orbitDiameter, X
    BCS loc_02CA08
    REP #$20
    LDA $14
    PHA 
    LDA $16
    PHA 
    LDA $moveXAlt, X
    STA $14
    LDA $moveYAlt, X
    STA $16
    JSL $@chunk_008000.code_00F4C7
    PLA 
    SEC 
    SBC $16
    STA $7F100E, X
    PLA 
    SEC 
    SBC $14
    STA $7F100C, X
    DEC $26
    BPL loc_02C9BE
    BRA loc_02C9B2

  loc_02CA08:
    REP #$20
    LDA #$6000
    TRB $12
    LDA $7F100C, X
    EOR #$FFFF
    INC 
    STA $7F100C, X
    LDA $7F100E, X
    EOR #$FFFF
    INC 
    STA $7F100E, X
    BRA loc_02CA37

  loc_02CA29:
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_02CA29
    LDA $08
    STZ $08
    STA $26

  loc_02CA35:
    COP [SetEntryExit]

  loc_02CA37:
    LDA $7F100C, X
    STA $moveScratch1, X
    LDA $7F100E, X
    STA $moveScratch2, X
    LDA $10
    BIT #$4000
    BNE loc_02CA54
    DEC $26
    BPL loc_02CA35
    BRA loc_02CA29

  loc_02CA54:
    COP [Die]
}

code_02CA56 {
    COP [StageSprAndHitbox] ( #05 )
    BRA loc_02CA5E
}

code_02CA5B {
    COP [StageSprAndHitbox] ( #06 )

  loc_02CA5E:
    JSR $&code_02CAB5

  loc_02CA61:
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_02CA61
    LDA $08
    STZ $08
    STA $26

  loc_02CA6D:
    COP [SetEntryExit]
    LDY $04
    JSR $&code_02CA7A
    DEC $26
    BPL loc_02CA6D
    BRA loc_02CA61
}

code_02CA7A {
    LDA $animScratch, X
    STA $14
    LDA $animScratch+2, X
    STA $animScratch, X
    LDA $animScratch2, X
    STA $animScratch+2, X
    LDA $0014, Y
    STA $animScratch2, X
    LDA $moveXAlt, X
    STA $16
    LDA $moveYAlt, X
    STA $moveXAlt, X
    LDA $retPtr1, X
    STA $moveYAlt, X
    LDA $0016, Y
    STA $retPtr1, X
    RTS 
}

code_02CAB5 {
    LDA $14
    STA $animScratch, X
    STA $animScratch+2, X
    STA $animScratch2, X
    LDA $16
    STA $moveXAlt, X
    STA $moveYAlt, X
    STA $retPtr1, X
    RTS 
}

code_02CAD2 {
    LDY $24
    LDA $14
    SEC 
    SBC $0014, Y
    STA $7F100C, X
    LDA $16
    SEC 
    SBC $0016, Y
    STA $7F100E, X
    RTS 
}

code_02CAE9 {
    LDY $24
    LDA $0014, Y
    CLC 
    ADC $7F100C, X
    STA $14
    LDA $0016, Y
    CLC 
    ADC $7F100E, X
    STA $16
    RTS 
}

code_02CB00 {
    LDA #$00
    BRK #$20
    STA ($CF), Y
    JSR $&code_02D8ED
    COP [GetPlayerFacing]
    AND #$03
    BRK #$8D
    BRK #$00
    COP [SwitchCase] ( #$0000, &code_list_02CB17 )
}

code_list_02CB17 [
  &code_02CB1F   ;00
  &code_02CB2F   ;01
  &code_02CB42   ;02
  &code_02CB55   ;03
]

code_02CB1F {
    COP [SpawnAfter] ( @code_02CB69 )
    COP [SetPlayerBodySprite] ( #04 )
    COP [StageSpriteMoveY] ( #04, #36 )
    COP [AnimOnce]
    BRA loc_02CB63
}

code_02CB2F {
    COP [SpawnAfter] ( @code_02CBD1 )
    COP [SetForceNE] ( #01 )
    COP [SetPlayerBodySprite] ( #04 )
    COP [StageSpriteMoveY] ( #05, #36 )
    COP [AnimOnce]
    BRA loc_02CB63
}

code_02CB42 {
    COP [SpawnAfter] ( @code_02CC39 )
    COP [SetForceBoth] ( #01 )
    COP [SetPlayerBodySprite] ( #04 )
    COP [StageSpriteMoveX] ( #06, #36 )
    COP [AnimOnce]
    BRA loc_02CB63
}

code_02CB55 {
    COP [SpawnAfter] ( @code_02CCA1 )
    COP [SetPlayerBodySprite] ( #04 )
    COP [StageSpriteMoveX] ( #07, #36 )
    COP [AnimOnce]

  loc_02CB63:
    JSR $&code_02D90A
    JMP $&code_02D01B
}

code_02CB69 {
    LDA #$06
    BRK #$85
    PHP 
    LDY $04
    LDA $0016, Y
    STA $14
    LDA #$DE
    ORA #$85
    ASL $02, X
    REP #$02
    DEX 
    PHP 
    LDY $04
    LDA $14
    SEC 
    SBC $0016, Y
    LDY $16
    INC $16
    INC $16
    STA $0000, Y
    LDY $04
    LDA $0016, Y
    STA $14
    COP [LoopNext]
    LDA #$03
    BRK #$85
    PHP 
    LDY $04
    LDA #$00
    BRK #$99
    ROL $deathFlag
    REP #$C6
    ASL $C6, X
    ASL $02, X
    DEX 
    PHP 
    LDY $16
    DEC $16
    DEC $16
    PHX 
    LDX $04
    LDA $0000, Y
    STA $moveScratch2, X
    PLX 
    COP [LoopNext]
    COP [SetEntryExit]
    PHX 
    LDX $04
    LDA #$00
    BRK #$9F
    ROL $7F00
    PLX 
    COP [Die]
}

code_02CBD1 {
    LDA #$06
    BRK #$85
    PHP 
    LDY $04
    LDA $0016, Y
    STA $14
    LDA #$DE
    ORA #$85
    ASL $02, X
    REP #$02
    DEX 
    PHP 
    LDY $04
    LDA $0016, Y
    SEC 
    SBC $14
    LDY $16
    INC $16
    INC $16
    STA $0000, Y
    LDY $04
    LDA $0016, Y
    STA $14
    COP [LoopNext]
    LDA #$03
    BRK #$85
    PHP 
    LDY $04
    LDA #$00
    BRK #$99
    ROL $deathFlag
    REP #$C6
    ASL $C6, X
    ASL $02, X
    DEX 
    PHP 
    LDY $16
    DEC $16
    DEC $16
    PHX 
    LDX $04
    LDA $0000, Y
    STA $moveScratch2, X
    PLX 
    COP [LoopNext]
    COP [SetEntryExit]
    PHX 
    LDX $04
    LDA #$00
    BRK #$9F
    ROL $7F00
    PLX 
    COP [Die]
}

code_02CC39 {
    LDA #$06
    BRK #$85
    PHP 
    LDY $04
    LDA $0014, Y
    STA $14
    LDA #$DE
    ORA #$85
    ASL $02, X
    REP #$02
    DEX 
    PHP 
    LDY $04
    LDA $0014, Y
    SEC 
    SBC $14
    LDY $16
    INC $16
    INC $16
    STA $0000, Y
    LDY $04
    LDA $0014, Y
    STA $14
    COP [LoopNext]
    LDA #$03
    BRK #$85
    PHP 
    LDY $04
    LDA #$00
    BRK #$99
    BIT $deathFlag
    REP #$C6
    ASL $C6, X
    ASL $02, X
    DEX 
    PHP 
    LDY $16
    DEC $16
    DEC $16
    PHX 
    LDX $04
    LDA $0000, Y
    STA $moveScratch1, X
    PLX 
    COP [LoopNext]
    COP [SetEntryExit]
    PHX 
    LDX $04
    LDA #$00
    BRK #$9F
    BIT $7F00
    PLX 
    COP [Die]
}

code_02CCA1 {
    LDA #$06
    BRK #$85
    PHP 
    LDY $04
    LDA $0014, Y
    STA $14
    LDA #$DE
    ORA #$85
    ASL $02, X
    REP #$02
    DEX 
    PHP 
    LDY $04
    LDA $14
    SEC 
    SBC $0014, Y
    LDY $16
    INC $16
    INC $16
    STA $0000, Y
    LDY $04
    LDA $0014, Y
    STA $14
    COP [LoopNext]
    LDA #$03
    BRK #$85
    PHP 
    LDY $04
    LDA #$00
    BRK #$99
    BIT $deathFlag
    REP #$C6
    ASL $C6, X
    ASL $02, X
    DEX 
    PHP 
    LDY $16
    DEC $16
    DEC $16
    PHX 
    LDX $04
    LDA $0000, Y
    STA $moveScratch1, X
    PLX 
    COP [LoopNext]
    COP [SetEntryExit]
    PHX 
    LDX $04
    LDA #$00
    BRK #$9F
    BIT $7F00
    PLX 
    COP [Die]

  loc_02CD09:
    LDA #$00
    BRA loc_02CD19

  loc_02CD0D:
    CLI 
    ASL $A9
    COP [BranchIfActorNear] ( #0C, #BC, &code_02A909 )
    ASL $&scene_warps.warp_def_018500, X

  loc_02CD19:
    ROL $9F
    BPL loc_02CD1D

  loc_02CD1D:
    ADC $@sc03_lances_mother.code_048D84+7E, X
    COP [StageSprAndHitbox] ( #22 )

  loc_02CD24:
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_02CD24
    STZ $08
    LDA $10
    BIT #$80
    BRK #$F0
    ORA $4C, S
    AND [$CE], Y
    LDA $26
    BMI loc_02CD54
    CMP #$0C
    BRK #$90
    ORA ($4A, S), Y
    STA $24
    COP [SetEntryContinue]
    COP [BranchIfNoButton] ( #$8001, &code_02CE37 )
    JSR $&code_02CE3E
    DEC $24
    BMI loc_02CD24
    RTL 

  loc_02CD54:
    LDA #$02
    BRK #$20
    STA ($CF), Y
    LDA #$00
    ORA ($14, X)
    BPL loc_02CD09
    BRK #$02
    TSB $10
    COP [SpawnLastRel] ( @code_02CE85, #00, #00, #$0302 )
    TYA 
    STA $orbitDiameter, X
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #1D, #04 )
    COP [AnimLoop]
    JSR $&code_02CE6F
    PEA $&code_02CDD5-1
    STZ $09C0
    STZ $decelCurvePtr
    LDA $joypadCurrent
    BIT #$00
    ORA ($F0, X)
    ORA $07A9
    BRK #$8D
    CPY #$9C09
    CPY $09
    STZ $slopeFracAccum
    RTS 
}

code_02CD9E {
    BIT #$00
    COP #$F0
    ORA $&01F9A9
    SBC $@chunk_098000.actor_def_09BF4D+140, X
    STZ $09C4
    STZ $slopeFracAccum
    RTS 
}

code_02CDB0 {
    BIT #$00
    PHP 
    BEQ loc_02CDC2
    LDA #$F9
    SBC $@chunk_098000.loc_09C285+8, X
    STZ $09C4
    STZ $slopeFracAccum
    RTS 

  loc_02CDC2:
    BIT #$00
    TSB $F0
    ORA $07A9
    BRK #$8D
    REP #$09
    STZ $09C4
    STZ $slopeFracAccum
    RTS 
}

code_02CDD4 {
    RTS 
}

code_02CDD5 {
    LDA #$00
    PLP 
    TRB $slopeCurvePtrB
    PEA $&code_02CDF2-1
    LDA #$FC
    CMP $1E9F
    BRK #$7F
    LDA $0B1A
    BNE loc_02CDEE
    LDA #$0C
    BRK #$60

  loc_02CDEE:
    LDA #$18
    BRK #$60
}

code_02CDF2 {
    STA $loopCounter, X
    LDA #$01
    BRK #$20
    STA ($CF), Y
    COP [StageSpriteFrame] ( #1D )
    COP [AnimOnce]
    COP [LoopNext]

  loc_02CE03:
    COP [BranchIfButton] ( #$0300, &code_02CE11 )
    COP [BranchIfButton] ( #$0C00, &code_02CE23 )
    BRA code_02CE37
}

code_02CE11 {
    LDA $joypadCurrent
    BIT #$00
    COP [BranchIfFlagByte] ( #05, #02, $038F )
    BRA loc_02CE33

  loc_02CE1E:
    COP [StagePlayerSprite] ( #02 )
    BRA loc_02CE33
}

code_02CE23 {
    LDA $joypadCurrent
    BIT #$00
    PHP 
    BNE loc_02CE30
    COP [StagePlayerSprite] ( #00 )
    BRA loc_02CE33

  loc_02CE30:
    COP [StagePlayerSprite] ( #01 )

  loc_02CE33:
    COP [AnimOneFrame]
    STZ $08
}

code_02CE37 {
    LDA #$00
    COP [BranchIfSolidOffset] ( #10, #02, &code_02A5C5 )
    ROL $4A
    BCC loc_02CE55
    LDA $joypadCurrent
    BIT #$20
    BRK #$F0
    INC 
    LDA $26
    SEC 
    SBC #$02
    BRK #$85
    ROL $80
    BPL loc_02CE03
    LSR $06, X
    BIT #$10
    BRK #$F0
    PHP 
    LDA $26
    SEC 
    SBC #$02
    BRK #$85
    ROL $AD
    LSR $06, X
    AND #$30
    BRK #$0C
    CLI 
    ASL $60
}

code_02CE6F {
    PHX 
    PHD 
    LDA $orbitDiameter, X
    BEQ loc_02CE82
    TCD 
    TAX 
    LDA #$00
    BRK #$9F
    ORA ($00)
    ADC $@2BA702, X
    PLX 
    RTS 
}

code_02CE85 {
    COP [SetSpritePriority] ( #30 )
    LDA $14
    SEC 
    SBC $playerWallType
    STA $7F100C, X
    LDA $16
    SEC 
    SBC $playerSpeedEw
    STA $7F100E, X
    COP [SetMetasprite] ( @table_0EE000 )

  code_02CEA1:
    COP [BranchIfButton] ( #$0100, &code_02CEDB )
    COP [BranchIfButton] ( #$0200, &code_02CEFB )
    COP [BranchIfButton] ( #$0800, &code_02CF1B )
    COP [BranchIfButton] ( #$0400, &code_02CF3B )
    COP [SetEntryContinue]
    COP [StageSprAndHitbox] ( #39 )

  loc_02CEBE:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $2A
    BEQ loc_02CEBE
    COP [BranchIfButton] ( #$0F00, &code_02CEA1 )
    JSR $&code_02CF7C
    DEC $24
    BMI loc_02CEBE
    RTL 
}

code_02CEDB {
    COP [StageSprAndHitbox] ( #3D )

  loc_02CEDE:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $2A
    BEQ loc_02CEDE
    COP [BranchIfNoButton] ( #$0100, &code_02CEA1 )
    JSR $&code_02CF7C
    DEC $24
    BMI loc_02CEDE
    RTL 
}

code_02CEFB {
    COP [StageSprAndHitbox] ( #3C )

  loc_02CEFE:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $2A
    BEQ loc_02CEFE
    COP [BranchIfNoButton] ( #$0200, &code_02CEA1 )
    JSR $&code_02CF7C
    DEC $24
    BMI loc_02CEFE
    RTL 
}

code_02CF1B {
    COP [StageSprAndHitbox] ( #3B )

  loc_02CF1E:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $2A
    BEQ loc_02CF1E
    COP [BranchIfNoButton] ( #$0800, &code_02CEA1 )
    JSR $&code_02CF7C
    DEC $24
    BMI loc_02CF1E
    RTL 
}

code_02CF3B {
    COP [StageSprAndHitbox] ( #3A )

  loc_02CF3E:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $2A
    BEQ loc_02CF3E
    COP [BranchIfNoButton] ( #$0400, &code_02CEA1 )
    JSR $&code_02CF7C
    DEC $24
    BMI loc_02CF3E
    RTL 
}

code_02CF5B {
    COP [PaletteStartLoop] ( #2A, #02 )
    COP [PaletteStepLoop]

  loc_02CF61:
    COP [PaletteStart] ( #2B )
    COP [PaletteStep]
    BRA loc_02CF61
}

code_02CF68 {
    COP [PaletteStartLoop] ( #4B, #02 )
    COP [PaletteStepLoop]

  loc_02CF6E:
    COP [PaletteStart] ( #2C )
    COP [PaletteStep]
    BRA loc_02CF6E
}

code_02CF75 {
    COP [PaletteStart] ( #5B )
    COP [PaletteStep]
    BRA code_02CF75
}

code_02CF7C {
    LDA $7F100C, X
    CLC 
    ADC $playerWallType
    STA $14
    LDA $7F100E, X
    CLC 
    ADC $playerSpeedEw
    STA $16
    RTS 
}

code_02CF91 {
    PHX 
    ASL 
    TAX 
    LDA $@table_01D9D0, X
    SEC 
    SBC #$D0
    CMP $&table_01B06E.delta_node_01BFA8+2, Y
    CMP ($D9)
    STA ($A8, X)
    LDA $0000, Y
    PHA 
    TXA 
    CLC 
    ADC $01, S
    TAX 
    PLA 
    LDA $@table_01D9D0+4, X
    AND #$FF
    BRK #$8D
    INC $&01FA09
    RTS 
}

code_02CFB8 {
    PHX 
    ASL 
    TAX 
    LDA $@table_01D9E8, X
    SEC 
    SBC #$E8
    CMP $&table_01B06E.delta_node_01BFA8+2, Y
    NOP 
    CMP $&scene_warps.warp_def_01A868+19, Y
    LDA $0000, Y
    PHA 
}

code_02CFCD {
    TXA 
    CLC 
    ADC $01, S
    TAX 
    PLA 
    LDA $@table_01D9E8+4, X
    AND #$FF
    BRK #$8D
    BEQ loc_02CFE6
    PLX 
    RTS 
}

actor_def_02CFDF [
  actor-def < #00, #08, #85, {

  code_02CFE2:
    LDA #$00
    ORA ($04, X)

  loc_02CFE6:
    BPL code_02CF91
    ORA ($00, X)
    TSB $12
    TXA 
    STA $decelStepCounter
    LDA #$01
    BRK #$9F
    TRB $7F10
    LDA $0AF8
    BEQ loc_02D003
    COP [SpawnAfterFlags] ( @chunk_008000.code_00D8DC, #$2000 )

  loc_02D003:
    COP [SpawnBefore] ( @code_02C4AA )
    COP [SpawnAfter] ( @code_02BFAA )
    COP [SpawnAfter] ( @code_02C122 )
    COP [SpawnLastRel] ( @code_02BF1A, #00, #00, #$2800 )
} >
]

code_02D01B {
    COP [SetEntryContinue]
    LDA $joypadHeld
    AND #$F0FF
    STA $joypadHeld
    LDA #$2800
    TRB $slopeCurvePtrB
    LDA #$0100
    TSB $10
    LDA #$0020
    TRB $10
    STZ $09EE
    LDA $10
    BIT #$2000
    BEQ loc_02D041
    RTL 

  loc_02D041:
    COP [SetSavedPtr] ( &code_02D01B )
    COP [SetForceBoth] ( #00 )
    LDA $09C0
    BEQ loc_02D050
    JMP $&code_02D6CC

  loc_02D050:
    LDA $decelCurvePtr
    BEQ loc_02D058
    JMP $&code_02D754

  loc_02D058:
    PHX 
    COP [GetPlayerFacing]
    AND #$0003
    STA $24
    SEP #$20
    XBA 
    LDA #$0E
    JSL $@code_0282F6
    REP #$20
    TAX 
    LDA $joypadCurrent
    BIT #$8000
    BNE loc_02D092
    INX 
    INX 
    XBA 
    LSR 
    BCS loc_02D092
    INX 
    INX 

  loc_02D07C:
    LSR 
    BCS loc_02D092
    INX 
    INX 
    LSR 
    BCS loc_02D092
    INX 
    INX 
    LSR 
    BCS loc_02D092
    INX 
    INX 
    BIT #$0300
    BNE loc_02D092
    INX 
    INX 

  loc_02D092:
    LDA $@code_02D09A, X
    PLX 
    DEC 
    PHA 
}

code_02D099 {
    RTS 
}

code_02D09A {
    JSL $@code_1208D9
    LDA $@spm_prison_enemies+A46, X
    ADC [$D1], Y
    BVS loc_02D07C
    CMP ($D0)
    LDA $D9, S
    PHP 
    CMP ($BF)
    CMP ($30), Y
    CMP ($77), Y
    CMP ($7E), Y
    DEC $E2, X
    BNE loc_02D0DB
    PHX 
    PHP 
    CMP ($BF)
    CMP ($30), Y
    CMP ($77), Y
    CMP ($8C), Y
    DEC $F2, X
    BNE loc_02D067
    PHX 
    PHP 
    CMP ($BF)
    CMP ($30), Y
    CMP ($77), Y
    CMP ($9A), Y
    DEC $02, X
    CMP ($02), Y
    BNE loc_02D0D5

  loc_02D0D5:
    ORA ($DD, X)
    BNE loc_02D0DB
    STA $@338000
    COP [StagePlayerSprite] ( #10 )
    BRA loc_02D110

  loc_02D0E2:
    COP [BranchIfFlagByte] ( #00, #01, &code_02D0ED )
    COP [StagePlayerSprite] ( #01 )
    BRA loc_02D110
}

code_02D0ED {
    COP [StagePlayerSprite] ( #11 )
    BRA loc_02D110

  loc_02D0F2:
    COP [BranchIfFlagByte] ( #00, #01, &code_02D0FD )
    COP [StagePlayerSprite] ( #02 )
    BRA loc_02D110
}

code_02D0FD {
    COP [StagePlayerSprite] ( #12 )
    BRA loc_02D110

  loc_02D102:
    COP [BranchIfFlagByte] ( #00, #01, &code_02D10D )
    COP [StagePlayerSprite] ( #03 )
    BRA loc_02D110
}

code_02D10D {
    COP [StagePlayerSprite] ( #13 )

  loc_02D110:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $09C0
    ORA $decelCurvePtr
    BNE code_02D12E
    COP [BranchIfButton] ( #$8F30, &code_02D12E )
    DEC $24
    BMI loc_02D110
    RTL 
}

code_02D12E {
    COP [RestoreSavedPtr]

  loc_02D130:
    LDA $24
    BNE loc_02D14C
    LDA $invincibilityTimer
    BMI loc_02D14C
    STZ $invincibilityTimer
    LDA #$0003
    STA $decelCurvePtr
    STZ $09C4
    STZ $slopeFracAccum
    COP [SetEntryExit]
    COP [RestoreSavedPtr]

  loc_02D14C:
    COP [StagePlayerSprite] ( #08 )
    JSR $&code_02D26A

  loc_02D152:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $2A
    BEQ loc_02D152
    COP [BranchIfNoButton] ( #$0400, &code_02D268 )
    JSR $&code_02D252
    BNE loc_02D172
    COP [BranchIfButton] ( #$0030, &code_02D670 )

  loc_02D172:
    DEC $24
    BMI loc_02D152
    RTL 
}

code_02D177 {
    LDA $24
    DEC 
    BNE loc_02D194
    LDA $invincibilityTimer
    BMI loc_02D194
    STZ $invincibilityTimer
    LDA #$FFFD
    STA $decelCurvePtr
    STZ $09C4
    STZ $slopeFracAccum
    COP [SetEntryExit]
    COP [RestoreSavedPtr]

  loc_02D194:
    COP [StagePlayerSprite] ( #09 )
    JSR $&code_02D26A

  loc_02D19A:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $2A
    BEQ loc_02D19A
    COP [BranchIfNoButton] ( #$0800, &code_02D268 )
    JSR $&code_02D252
    BNE loc_02D1BA
    COP [BranchIfButton] ( #$0030, &code_02D67E )

  loc_02D1BA:
    DEC $24
    BMI loc_02D19A
    RTL 
}

code_02D1BF {
    LDA $24
    DEC 
    DEC 
    BNE loc_02D1DD
    LDA $invincibilityTimer
    BMI loc_02D1DD
    STZ $invincibilityTimer
    LDA #$FFFD
    STA $09C0
    STZ $09C4
    STZ $slopeFracAccum
    COP [SetEntryExit]
    COP [RestoreSavedPtr]

  loc_02D1DD:
    COP [StagePlayerSprite] ( #0A )
    JSR $&code_02D26A

  loc_02D1E3:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $2A
    BEQ loc_02D1E3
    COP [BranchIfNoButton] ( #$0200, &code_02D268 )
    JSR $&code_02D252
    BNE loc_02D203
    COP [BranchIfButton] ( #$0030, &code_02D68C )

  loc_02D203:
    DEC $24
    BMI loc_02D1E3
    RTL 
}

code_02D208 {
    LDA $24
    DEC 
    DEC 
    DEC 
    BNE loc_02D227
    LDA $invincibilityTimer
    BMI loc_02D227
    STZ $invincibilityTimer
    LDA #$0003
    STA $09C0
    STZ $09C4
    STZ $slopeFracAccum
    COP [SetEntryExit]
    COP [RestoreSavedPtr]

  loc_02D227:
    COP [StagePlayerSprite] ( #0B )
    JSR $&code_02D26A

  loc_02D22D:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $2A
    BEQ loc_02D22D
    COP [BranchIfNoButton] ( #$0100, &code_02D268 )
    JSR $&code_02D252
    BNE loc_02D24D
    COP [BranchIfButton] ( #$0030, &code_02D69A )

  loc_02D24D:
    DEC $24
    BMI loc_02D22D
    RTL 
}

code_02D252 {
    COP [BranchIfButton] ( #$8000, &code_02D267 )
    LDA $09C0
    ORA $decelCurvePtr
    BNE code_02D267
    LDA $slopeCurvePtrB
    BIT #$1000
    RTS 
}

code_02D267 {
    PLA 
}

code_02D268 {
    COP [RestoreSavedPtr]
}

code_02D26A {
    LDA #$000D
    STA $invincibilityTimer
    RTS 
}

code_02D271 {
    LDA #$0008
    TRB $10
    LDA #$0200
    TSB $10
    LDA #$4000
    TSB $joypadMaskStd
    COP [StagePlayerMoveXY] ( #18, #00, #18 )
    COP [AnimOnce]
    COP [StagePlayerMoveY] ( #19, #07 )
    COP [AnimOnce]

  loc_02D28E:
    COP [BranchIfSolidType] ( #00, &code_02D2E5 )
    COP [StagePlayerSprite] ( #1A )
    COP [StageForceMoveY] ( #07 )

  loc_02D299:
    COP [AnimOneFrame]
    JSR $&code_02D301
    BCS loc_02D2AB

  loc_02D2A0:
    JSR $&code_02D30F
    COP [SetEntryExit]
    DEC $24
    BPL loc_02D2A0
    BRA loc_02D299

  loc_02D2AB:
    COP [BranchIfSolidType] ( #00, &code_02D2E5 )
    COP [StagePlayerSprite] ( #1B )
    COP [StageForceMoveY] ( #07 )

  loc_02D2B6:
    COP [AnimOneFrame]
    JSR $&code_02D301
    BCS loc_02D2C8

  loc_02D2BD:
    JSR $&code_02D30F
    COP [SetEntryExit]
    DEC $24
    BPL loc_02D2BD
    BRA loc_02D2B6

  loc_02D2C8:
    COP [BranchIfSolidType] ( #00, &code_02D2E5 )
    COP [StagePlayerSprite] ( #19 )
    COP [StageForceMoveY] ( #07 )

  loc_02D2D3:
    COP [AnimOneFrame]
    JSR $&code_02D301
    BCS loc_02D28E

  loc_02D2DA:
    JSR $&code_02D30F
    COP [SetEntryExit]
    DEC $24
    BPL loc_02D2DA
    BRA loc_02D2D3
}

code_02D2E5 {
    COP [PlaySoundCh2] ( #2C )
    COP [StagePlayerMoveY] ( #1C, #00 )
    COP [AnimOnce]
    LDA #$0200
    TRB $10
    LDA #$0008
    TSB $10
    LDA #$4000
    TRB $joypadMaskStd
    JMP $&code_02D01B
}

code_02D301 {
    LDA $2A
    BEQ loc_02D30D
    LDA $08
    STZ $08
    STA $24
    CLC 
    RTS 

  loc_02D30D:
    SEC 
    RTS 
}

code_02D30F {
    LDA $characterForm
    CMP #$0001
    BEQ loc_02D318
    RTS 

  loc_02D318:
    LDA $abilityBitmask
    BIT #$0040
    BNE loc_02D321
    RTS 

  loc_02D321:
    COP [BranchIfButton] ( #$8000, &code_02D328 )
    RTS 
}

code_02D328 {
    PLA 
    COP [SetPlayerBodySprite] ( #06 )
    COP [StageSprAndHitbox] ( #00 )

  loc_02D32F:
    COP [StageForceMoveY] ( #07 )

  loc_02D332:
    COP [AnimOneFrame]
    JSR $&code_02D301
    BCS loc_02D32F

  loc_02D339:
    LDA $16
    BIT #$000F
    BNE loc_02D345
    COP [BranchIfSolidType] ( #00, &code_02D34D )

  loc_02D345:
    COP [SetEntryExit]
    DEC $24
    BPL loc_02D339
    BRA loc_02D332
}

code_02D34D {
    LDA #$0002
    JSR $&code_02CFB8
    COP [SpawnLastRel] ( @code_02D387, #00, #00, #$2400 )
    COP [SpawnLastRel] ( @code_02D399, #00, #00, #$2400 )
    LDA #$003C
    STA $0026, Y
    COP [StageSpriteMoveY] ( #01, #00 )
    COP [AnimOnce]
    COP [WaitByte] ( #27 )
    LDA #$0200
    TRB $10
    LDA #$0008
    TSB $10
    LDA #$4000
    TRB $joypadMaskStd
    JMP $&code_02D01B
}

code_02D387 {
    LDA #$0010
    TSB $slopeCurvePtrB
    COP [WaitWord] ( #$01DF )
    LDA #$0010
    TRB $slopeCurvePtrB
    COP [Die]
}

code_02D399 {
    COP [PlaySoundCh2] ( #15 )
    JSR $&code_02D3A6
    DEC $26
    BMI loc_02D3A4
    RTL 

  loc_02D3A4:
    COP [Die]
}

code_02D3A6 {
    LDA $layerPriorityFlag
    BIT #$0200
    BNE loc_02D3DC
    LDA #$0000
    STA $7F100C, X
    STA $7F100E, X

  loc_02D3B9:
    COP [RngByte]
    PHA 
    AND #$0003
    SEC 
    SBC #$0001
    CLC 
    ADC $cameraTargetX
    STA $cameraTargetX
    PLA 
    LSR 
    LSR 
    AND #$0003
    SEC 
    SBC #$0001
    CLC 
    ADC $cameraTargetY
    STA $cameraTargetY
    RTS 

  loc_02D3DC:
    LDA $7F100C, X
    BNE loc_02D3F2
    LDA $cameraTargetX
    STA $7F100C, X
    LDA $cameraTargetY
    STA $7F100E, X
    BRA loc_02D3B9

  loc_02D3F2:
    STA $cameraTargetX
    LDA $7F100E, X
    STA $cameraTargetY
    BRA loc_02D3B9

  loc_02D3FE:
    LDA #$0028
    TRB $10
    LDA #$0100
    TSB $10
    LDA #$0800
    TSB $slopeCurvePtrB
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [StagePlayerMoveXY] ( #26, #00, #1B )
    COP [AnimOnce]
    COP [BranchIfButton] ( #$0801, &code_02D479 )
    COP [BranchIfButton] ( #$0401, &code_02D455 )
    JMP $&code_02D4AD
}

code_02D42A {
    LDA #$0028
    TRB $10
    LDA #$0100
    TSB $10
    LDA #$0800
    TSB $slopeCurvePtrB
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [StagePlayerMoveXY] ( #28, #00, #19 )
    COP [AnimOnce]
    COP [BranchIfButton] ( #$0401, &code_02D455 )
    COP [BranchIfButton] ( #$0801, &code_02D479 )
    BRA code_02D49D
}

code_02D455 {
    COP [StagePlayerSprite] ( #2D )

  loc_02D458:
    COP [StageForceMoveY] ( #1D )

  loc_02D45B:
    LDA $16
    AND #$000F
    BNE loc_02D467
    COP [BranchIfSolidTypeSouth] ( #00, &code_02D4DF )

  loc_02D467:
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_02D458
    COP [BranchIfNoButton] ( #$0401, &code_02D49D )
    COP [SetEntryExit]
    BRA loc_02D45B
}

code_02D479 {
    COP [StagePlayerSprite] ( #2C )

  loc_02D47C:
    COP [StageForceMoveY] ( #1E )

  loc_02D47F:
    LDA $16
    AND #$000F
    BNE loc_02D48B
    COP [BranchIfSolidTypeNorth] ( #00, &code_02D4F2 )

  loc_02D48B:
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_02D47C
    COP [BranchIfNoButton] ( #$0801, &code_02D4AD )
    COP [SetEntryExit]
    BRA loc_02D47F
}

code_02D49D {
    COP [BranchIfFlagByte] ( #00, #01, &code_02D4A8 )
    COP [StagePlayerSprite] ( #2B )
    BRA loc_02D4BB
}

code_02D4A8 {
    COP [StagePlayerSprite] ( #2F )
    BRA loc_02D4BB
}

code_02D4AD {
    COP [BranchIfFlagByte] ( #00, #01, &code_02D4B8 )
    COP [StagePlayerSprite] ( #2A )
    BRA loc_02D4BB
}

code_02D4B8 {
    COP [StagePlayerSprite] ( #2E )

  loc_02D4BB:
    STZ $2E
    STZ $08

  loc_02D4BF:
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_02D4BF
    LDA $08
    STZ $08
    STA $24

  loc_02D4CB:
    COP [SetEntryExit]
    COP [BranchIfButton] ( #$0401, &code_02D455 )
    COP [BranchIfButton] ( #$0801, &code_02D479 )
    DEC $24
    BPL loc_02D4CB
    BRA loc_02D4BF
}

code_02D4DF {
    COP [StagePlayerMoveY] ( #29, #1A )
    COP [AnimOnce]
    LDA #$CFF0
    TRB $joypadMaskStd
    LDA #$0008
    TSB $10
    COP [RestoreSavedPtr]
}

code_02D4F2 {
    COP [StagePlayerMoveY] ( #27, #1C )
    COP [AnimOnce]
    LDA #$CFF0
    TRB $joypadMaskStd
    LDA #$0008
    TSB $10
    COP [RestoreSavedPtr]

  loc_02D505:
    LDA #$0028
    TRB $10
    LDA #$0100
    TSB $10
    LDA #$0800
    TSB $slopeCurvePtrB
    COP [StagePlayerMoveXY] ( #33, #51, #00 )
    COP [AnimOnce]

  code_02D51C:
    LDA $14
    CLC 
    ADC #$0008
    AND #$000F
    BNE code_02D534
    COP [BranchIfSolidTypeEast] ( #07, &code_02D534 )
    COP [BranchIfSolidTypeEast] ( #00, &code_02D534 )
    JMP $&code_02D5FF
}

code_02D534 {
    COP [StagePlayerSprite] ( #33 )

  loc_02D537:
    COP [StageForceMoveX] ( #51 )

  loc_02D53A:
    LDA $14
    SEC 
    SBC #$0008
    AND #$000F
    BNE code_02D563
    COP [BranchIfSolidType] ( #00, &code_02D661 )
    COP [BranchIfButton] ( #$0801, &code_02D575 )
    COP [BranchIfButton] ( #$0401, &code_02D57C )

  loc_02D556:
    COP [BranchIfSolidTypeEast] ( #07, &code_02D563 )
    COP [BranchIfSolidTypeEast] ( #00, &code_02D563 )
    JMP $&code_02D5FF
}

code_02D563 {
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_02D537
    COP [BranchIfNoButton] ( #$0101, &code_02D5FF )
    COP [SetEntryExit]
    BRA loc_02D53A
}

code_02D575 {
    COP [BranchIfSolidTypeNorth] ( #00, &code_02D661 )
    BRA loc_02D556
}

code_02D57C {
    COP [BranchIfSolidTypeSouth] ( #00, &code_02D661 )
    BRA loc_02D556

  loc_02D583:
    LDA #$0028
    TRB $10
    LDA #$0100
    TSB $10
    LDA #$0800
    TSB $slopeCurvePtrB
    COP [StagePlayerMoveXY] ( #32, #52, #00 )
    COP [AnimOnce]

  code_02D59A:
    LDA $14
    CLC 
    ADC #$0008
    AND #$000F
    BNE code_02D5B1
    COP [BranchIfSolidTypeWest] ( #07, &code_02D5B1 )
    COP [BranchIfSolidTypeWest] ( #00, &code_02D5B1 )
    BRA code_02D612
}

code_02D5B1 {
    COP [StagePlayerSprite] ( #32 )

  loc_02D5B4:
    COP [StageForceMoveX] ( #52 )

  loc_02D5B7:
    LDA $14
    SEC 
    SBC #$0008
    AND #$000F
    BNE code_02D5DF
    COP [BranchIfSolidType] ( #00, &code_02D661 )
    COP [BranchIfButton] ( #$0801, &code_02D5F1 )
    COP [BranchIfButton] ( #$0401, &code_02D5F8 )

  loc_02D5D3:
    COP [BranchIfSolidTypeWest] ( #07, &code_02D5DF )
    COP [BranchIfSolidTypeWest] ( #00, &code_02D5DF )
    BRA code_02D612
}

code_02D5DF {
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_02D5B4
    COP [BranchIfNoButton] ( #$0201, &code_02D612 )
    COP [SetEntryExit]
    BRA loc_02D5B7
}

code_02D5F1 {
    COP [BranchIfSolidTypeNorth] ( #00, &code_02D661 )
    BRA loc_02D5D3
}

code_02D5F8 {
    COP [BranchIfSolidTypeSouth] ( #00, &code_02D661 )
    BRA loc_02D5D3
}

code_02D5FF {
    COP [StageForceMoveX] ( #00 )
    COP [BranchIfFlagByte] ( #00, #01, &code_02D60D )
    COP [StagePlayerSprite] ( #31 )
    BRA loc_02D623
}

code_02D60D {
    COP [StagePlayerSprite] ( #35 )
    BRA loc_02D623
}

code_02D612 {
    COP [StageForceMoveX] ( #00 )
    COP [BranchIfFlagByte] ( #00, #01, &code_02D620 )
    COP [StagePlayerSprite] ( #30 )
    BRA loc_02D623
}

code_02D620 {
    COP [StagePlayerSprite] ( #34 )

  loc_02D623:
    STZ $2C
    STZ $08

  loc_02D627:
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_02D627
    LDA $08
    STZ $08
    STA $24

  loc_02D633:
    COP [SetEntryExit]
    COP [BranchIfButton] ( #$0801, &code_02D653 )
    COP [BranchIfButton] ( #$0401, &code_02D65A )
    COP [BranchIfButton] ( #$0201, &code_02D59A )
    COP [BranchIfButton] ( #$0101, &code_02D51C )

  loc_02D64D:
    DEC $24
    BPL loc_02D633
    BRA loc_02D627
}

code_02D653 {
    COP [BranchIfSolidTypeNorth] ( #00, &code_02D661 )
    BRA loc_02D64D
}

code_02D65A {
    COP [BranchIfSolidTypeSouth] ( #00, &code_02D661 )
    BRA loc_02D64D
}

code_02D661 {
    STZ $2C
    LDA #$0008
    TSB $10
    COP [RestoreSavedPtr]

  code_02D66A:
    LDA #$0400
    TSB $joypadHeld
}

code_02D670 {
    STZ $invincibilityTimer
    COP [StagePlayerSprite] ( #3A )
    BRA loc_02D6A0

  code_02D678:
    LDA #$0800
    TSB $joypadHeld
}

code_02D67E {
    STZ $invincibilityTimer
    COP [StagePlayerSprite] ( #3B )
    BRA loc_02D6A0

  code_02D686:
    LDA #$0200
    TSB $joypadHeld
}

code_02D68C {
    STZ $invincibilityTimer
    COP [StagePlayerSprite] ( #3C )
    BRA loc_02D6A0

  code_02D694:
    LDA #$0100
    TSB $joypadHeld
}

code_02D69A {
    STZ $invincibilityTimer
    COP [StagePlayerSprite] ( #3D )

  loc_02D6A0:
    LDA #$2000
    TSB $slopeCurvePtrB
    LDA #$0020
    TSB $10
    LDA #$0100
    TRB $10

  loc_02D6B0:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $2A
    BEQ loc_02D6B0
    COP [BranchIfNoButton] ( #$0030, &code_02D6CA )
    DEC $24
    BMI loc_02D6B0
    RTL 
}

code_02D6CA {
    COP [RestoreSavedPtr]
}

code_02D6CC {
    LDA $joypadCurrent
    BIT #$0300
    BEQ loc_02D6DB
    BIT #$0200
    BNE loc_02D71C
    BRA loc_02D6E4

  loc_02D6DB:
    LDA $09C0
    BMI loc_02D71C
    BRA loc_02D6E4

  code_02D6E2:
    COP [SetEntryExit]

  loc_02D6E4:
    COP [StagePlayerSprite] ( #0F )

  loc_02D6E7:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $2A
    BEQ loc_02D6E7
    LDA $09C0
    BEQ loc_02D752
    COP [BranchIfButton] ( #$0200, &code_02D71A )
    JSR $&code_02D7DA
    JSR $&code_02D821
    BCS loc_02D715
    COP [BranchIfButton] ( #$8000, &code_02DAA2 )
    COP [BranchIfButton] ( #$0030, &code_02D694 )

  loc_02D715:
    DEC $24
    BMI loc_02D6E7
    RTL 
}

code_02D71A {
    COP [SetEntryExit]

  loc_02D71C:
    COP [StagePlayerSprite] ( #0E )

  loc_02D71F:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $2A
    BEQ loc_02D71F
    LDA $09C0
    BEQ loc_02D752
    COP [BranchIfButton] ( #$0100, &code_02D6E2 )
    JSR $&code_02D7DA
    JSR $&code_02D821
    BCS loc_02D74D
    COP [BranchIfButton] ( #$8000, &code_02DA24 )
    COP [BranchIfButton] ( #$0030, &code_02D686 )

  loc_02D74D:
    DEC $24
    BMI loc_02D71F
    RTL 

  loc_02D752:
    COP [RestoreSavedPtr]
}

code_02D754 {
    LDA $joypadCurrent
    BIT #$0C00
    BEQ loc_02D763
    BIT #$0800
    BNE loc_02D76C
    BRA loc_02D7A4

  loc_02D763:
    LDA $decelCurvePtr
    BMI loc_02D76C
    BRA loc_02D7A4

  code_02D76A:
    COP [SetEntryExit]

  loc_02D76C:
    COP [StagePlayerSprite] ( #0D )

  loc_02D76F:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $2A
    BEQ loc_02D76F
    LDA $decelCurvePtr
    BEQ loc_02D752
    COP [BranchIfButton] ( #$0400, &code_02D7A2 )
    JSR $&code_02D7DA
    JSR $&code_02D82C
    BCS loc_02D79D
    COP [BranchIfButton] ( #$8000, &code_02D9A3 )
    COP [BranchIfButton] ( #$0030, &code_02D678 )

  loc_02D79D:
    DEC $24
    BMI loc_02D76F
    RTL 
}

code_02D7A2 {
    COP [SetEntryExit]

  loc_02D7A4:
    COP [StagePlayerSprite] ( #0C )

  loc_02D7A7:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $2A
    BEQ loc_02D7A7
    LDA $decelCurvePtr
    BEQ loc_02D752
    COP [BranchIfButton] ( #$0800, &code_02D76A )
    JSR $&code_02D7DA
    JSR $&code_02D82C
    BCS loc_02D7D5
    COP [BranchIfButton] ( #$8000, &code_02D922 )
    COP [BranchIfButton] ( #$0030, &code_02D66A )

  loc_02D7D5:
    DEC $24
    BMI loc_02D7A7
    RTL 
}

code_02D7DA {
    LDA $10
    BIT #$0080
    BNE loc_02D7FC
    LDA $characterForm
    BNE loc_02D7FC
    LDA $abilityBitmask
    BIT #$0002
    BEQ loc_02D7FC
    LDA $slopeCurvePtrB
    BIT #$1000
    BNE loc_02D7FC
    COP [BranchIfButton] ( #$8000, &code_02D7FD )

  loc_02D7FC:
    RTS 
}

code_02D7FD {
    LDA $09C0
    BPL loc_02D806
    EOR #$FFFF
    INC 

  loc_02D806:
    CMP #$0003
    BCC loc_02D80F
    PLA 
    JMP $&code_02D89A

  loc_02D80F:
    LDA $decelCurvePtr
    BPL loc_02D818
    EOR #$FFFF
    INC 

  loc_02D818:
    CMP #$0003
    BCC loc_02D7FC
    PLA 
    JMP $&code_02D847
}

code_02D821 {
    LDA $09C0
    BPL loc_02D82A
    EOR #$FFFF
    INC 

  loc_02D82A:
    BRA loc_02D835
}

code_02D82C {
    LDA $decelCurvePtr
    BPL loc_02D835
    EOR #$FFFF
    INC 

  loc_02D835:
    CMP #$0004
    BCC loc_02D83B
    RTS 

  loc_02D83B:
    LDA $slopeCurvePtrB
    BIT #$1000
    BNE loc_02D845
    CLC 
    RTS 

  loc_02D845:
    SEC 
    RTS 
}

code_02D847 {
    LDA #$0001
    JSR $&code_02CF91
    COP [SetPlayerBodySprite] ( #04 )
    LDA $decelCurvePtr
    BMI loc_02D876
    JSR $&code_02D8F8
    LDA #$0100
    TRB $10
    COP [StageSpriteFrame] ( #0C )
    COP [AnimOnce]
    STZ $decelCurvePtr
    COP [StageSpriteLoopMoveY] ( #0D, #02, #44 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #0E )
    COP [AnimOnce]
    JSR $&code_02D910
    COP [RestoreSavedPtr]

  loc_02D876:
    JSR $&code_02D8F8
    COP [SetForceNE] ( #01 )
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    STZ $decelCurvePtr
    LDA #$0100
    TRB $10
    COP [StageSpriteLoopMoveY] ( #10, #02, #44 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #11 )
    COP [AnimOnce]
    JSR $&code_02D910
    COP [RestoreSavedPtr]
}

code_02D89A {
    LDA #$0001
    JSR $&code_02CF91
    COP [SetPlayerBodySprite] ( #04 )
    LDA $09C0
    BPL loc_02D8CC
    JSR $&code_02D8F8
    COP [SetForceSW] ( #01 )
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    STZ $09C0
    LDA #$0100
    TRB $10
    COP [StageSpriteLoopMoveX] ( #13, #02, #44 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #14 )
    COP [AnimOnce]
    JSR $&code_02D910
    COP [RestoreSavedPtr]

  loc_02D8CC:
    JSR $&code_02D8F8
    COP [StageSpriteFrame] ( #15 )
    COP [AnimOnce]
    STZ $09C0
    LDA #$0100
    TRB $10
    COP [StageSpriteLoopMoveX] ( #16, #02, #44 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #17 )
    COP [AnimOnce]
    JSR $&code_02D910
    COP [RestoreSavedPtr]
}

code_02D8ED {
    LDA #$00
    ORA ($14, X)
    BPL loc_02D89C
    BRK #$02
    TSB $layerPriorityFlag
}

code_02D8F8 {
    LDA #$0200
    TSB $10
    LDA #$8000
    TSB $joypadHeld
    LDA #$0802
    TSB $slopeCurvePtrB
    RTS 
}

code_02D90A {
    LDA #$00
    COP [BranchIfSolidTypeSouth] ( #EE, &code_02A906 )
    BRK #$02
    TRB $10
    LDA #$00
    BRA loc_02D925

  loc_02D919:
    CLI 
    ASL $A9
    COP [GenHdmaSine]
    TRB $slopeCurvePtrB
    RTS 
}

code_02D922 {
    JSR $&code_02DB36

  loc_02D925:
    LDA #$00
    TSB $0C
    CLI 
    ASL $AD
    PEI ($0A)
    CMP #$01
    BRK #$D0
    ORA $1602, Y
    EOR [$D9]
    LDA $playerWallType
    AND #$0F
    BRK #$F0
    ORA $1402
    ORA ($01, X)
    EOR [$D9]
    BRA loc_02D94C

  loc_02D947:
    COP [StagePlayerSprite] ( #48 )
    BRA loc_02D94F

  loc_02D94C:
    COP [StagePlayerSprite] ( #36 )

  loc_02D94F:
    LDA $sceneCurrent
    CMP #$E8
    BRK #$D0
    ORA #$02
    LDA $B0
    STP 
    BRL loc_02D95E

  loc_02D95E:
    COP [PlaySoundCh2] ( #02 )
    CMP ($02, X)
    PHB 
    COP [SetEntryExit]

  loc_02D966:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $2A
    BEQ loc_02D99A
    LDA $characterForm
    BNE loc_02D98D
    COP [SetEntryContinue]
    COP [BranchIfButton] ( #$0B00, &code_02DB20 )
    COP [BranchIfButton] ( #$0400, &code_02DB57 )
    DEC $24
    BMI loc_02D966
    RTL 

  loc_02D98D:
    COP [SetEntryContinue]
    COP [BranchIfButton] ( #$0B00, &code_02DB20 )
    DEC $24
    BMI loc_02D966
    RTL 

  loc_02D99A:
    COP [BranchIfButton] ( #$8000, &code_02D922 )
    JMP $&code_02DB2E
}

code_02D9A3 {
    JSR $&code_02DB36
    LDA #$00
    PHP 
    TSB $joypadHeld
    LDA $characterForm
    CMP #$01
    BRK #$D0
    ORA $1602, Y
    INY 
    CMP $&table_01B06E+3F, Y
    ORA #$29
    ORA $@spm_viper+2D
    COP [BranchIfSolidOffset] ( #01, #FF, &code_02D9C8 )
    BRA loc_02D9CD
}

code_02D9C8 {
    COP [StagePlayerSprite] ( #49 )
    BRA loc_02D9D0

  loc_02D9CD:
    COP [StagePlayerSprite] ( #37 )

  loc_02D9D0:
    LDA $sceneCurrent
    CMP #$E8
    BRK #$D0
    ORA #$02
    LDA $CA
    STP 
    BRL loc_02A9DF

  loc_02D9DF:
    COP [PlaySoundCh2] ( #02 )
    CMP ($02, X)
    PHB 
    COP [SetEntryExit]

  loc_02D9E7:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $2A
    BEQ loc_02DA1B
    LDA $characterForm
    BNE loc_02DA0E
    COP [SetEntryContinue]
    COP [BranchIfButton] ( #$0700, &code_02DB20 )
    COP [BranchIfButton] ( #$0800, &code_02DB61 )
    DEC $24
    BMI loc_02D9E7
    RTL 

  loc_02DA0E:
    COP [SetEntryContinue]
    COP [BranchIfButton] ( #$0700, &code_02DB20 )
    DEC $24
    BMI loc_02D9E7
    RTL 

  loc_02DA1B:
    COP [BranchIfButton] ( #$8000, &code_02D9A3 )
    JMP $&code_02DB2E
}

code_02DA24 {
    JSR $&code_02DB36
    LDA #$00
    COP [ClearLowHere]
    CLI 
    ASL $AD
    PEI ($0A)
    CMP #$02
    BRK #$F0
    ORA ($02), Y
    ORA [$4B], Y
    PHX 
    LDA $16
    AND #$0F
    BRK #$F0
    ASL $02
    TRB $FF
    ORA ($4B, X)
    PHX 
    COP [StagePlayerSprite] ( #38 )
    BRA loc_02DA4E

  loc_02DA4B:
    COP [StagePlayerSprite] ( #42 )

  loc_02DA4E:
    LDA $sceneCurrent
    CMP #$E8
    BRK #$D0
    ORA #$02
    LDA $E4
    STP 
    BRL loc_02DA5D

  loc_02DA5D:
    COP [PlaySoundCh2] ( #02 )
    CMP ($02, X)
    PHB 
    COP [SetEntryExit]

  loc_02DA65:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $2A
    BEQ loc_02DA99
    LDA $characterForm
    BNE loc_02DA8C
    COP [SetEntryContinue]
    COP [BranchIfButton] ( #$0D00, &code_02DB20 )
    COP [BranchIfButton] ( #$0200, &code_02DB70 )
    DEC $24
    BMI loc_02DA65
    RTL 

  loc_02DA8C:
    COP [SetEntryContinue]
    COP [BranchIfButton] ( #$0D00, &code_02DB20 )
    DEC $24
    BMI loc_02DA65
    RTL 

  loc_02DA99:
    COP [BranchIfButton] ( #$8000, &code_02DA24 )
    JMP $&code_02DB2E
}

code_02DAA2 {
    JSR $&code_02DB36
    LDA #$00
    ORA ($0C, X)
    CLI 
    ASL $AD
    PEI ($0A)
    CMP #$02
    BRK #$F0
    ORA ($02), Y
    CLC 
    CMP #$DA
    LDA $16
    AND #$0F
    BRK #$F0
    ASL $02
    TRB $01
    ORA ($C9, X)
    PHX 
    COP [StagePlayerSprite] ( #39 )
    BRA loc_02DACC

  loc_02DAC9:
    COP [StagePlayerSprite] ( #43 )

  loc_02DACC:
    LDA $sceneCurrent
    CMP #$E8
    BRK #$D0
    ORA #$02
    LDA $FE
    STP 
    BRL loc_02DADB

  loc_02DADB:
    COP [PlaySoundCh2] ( #02 )
    CMP ($02, X)
    PHB 
    COP [SetEntryExit]

  loc_02DAE3:
    COP [AnimOneFrame]
    LDA $08
    STZ $08
    INC 
    STA $24
    COP [SetEntryContinue]
    LDA $2A
    BEQ loc_02DB17
    LDA $characterForm
    BNE loc_02DB0A
    COP [SetEntryContinue]
    COP [BranchIfButton] ( #$0E00, &code_02DB20 )
    COP [BranchIfButton] ( #$0100, &code_02DB7F )
    DEC $24
    BMI loc_02DAE3
    RTL 

  loc_02DB0A:
    COP [SetEntryContinue]
    COP [BranchIfButton] ( #$0E00, &code_02DB20 )
    DEC $24
    BMI loc_02DAE3
    RTL 

  loc_02DB17:
    COP [BranchIfButton] ( #$8000, &code_02DAA2 )
    JMP $&code_02DB2E
}

code_02DB20 {
    LDA $joypadCurrent
    BIT #$00
    ORA $A906F0
    BRK #$80
    TRB $joypadHeld
}

code_02DB2E {
    LDA #$00
    ORA $06581C
    COP [RestoreSavedPtr]
}

code_02DB36 {
    LDA $joypadCurrent
    AND #$00
    ORA $06568D
    ORA #$00
    BRA loc_02DAD0

  loc_02DB43:
    CLI 
    ASL $A9
    BRK #$01
    TRB $10
    LDA $characterForm
    BEQ loc_02DB53
    COP [PlaySoundCh2] ( #02 )
    RTS 

  loc_02DB53:
    COP [PlaySoundCh2] ( #01 )
    RTS 
}

code_02DB57 {
    JSR $&code_02DB97
    COP [StagePlayerSprite] ( #44 )
    COP [AnimOnce]
    BRA loc_02DB87
}

code_02DB61 {
    JSR $&code_02DB97
    LDA #$00
    JSR $1204
    COP [StagePlayerSprite] ( #45 )
    COP [AnimOnce]
    BRA loc_02DB87
}

code_02DB70 {
    JSR $&code_02DB92
    LDA #$00
    RTI 
    TSB $12
    COP [StagePlayerSprite] ( #46 )
    COP [AnimOnce]
    BRA loc_02DB87
}

code_02DB7F {
    JSR $&code_02DB92
    COP [StagePlayerSprite] ( #47 )
    COP [AnimOnce]

  loc_02DB87:
    LDA #$00
    COP [BranchIfSolidOffset] ( #10, #02, &code_02BF5C )
    SBC $@code_02C4EE+14, X
    TAX 
    LSR $80
    ORA $02, S
    PLB 
    LSR $A9
    BRK #$08
    TSB $slopeCurvePtrB
    LDA #$01
    BRK #$8D
    INC $&scene_warps.warp_def_01A8B4+55
    BRK #$02
    TSB $10
    COP [OrActorFlags] ( #$0040 )
    RTS 
}

code_02DBB0 {
    COP [SetMetasprite] ( @sprite_set_list_17D000 )
    COP [StageSpriteMoveY] ( #00, #09 )
    COP [AnimOnce]

  loc_02DBBB:
    COP [StageSpriteMoveY] ( #04, #0F )
    COP [AnimOnce]
    LDA $10
    BIT #$00
    RTI 
    BEQ loc_02DBBB
    COP [Die]

  loc_02DBCA:
    COP [SetMetasprite] ( @sprite_set_list_17D000 )
    COP [StageSpriteMoveY] ( #01, #0A )
    COP [AnimOnce]

  loc_02DBD5:
    COP [StageSpriteMoveY] ( #05, #10 )
    COP [AnimOnce]
    LDA $10
    BIT #$00
    RTI 
    BEQ loc_02DBD5
    COP [Die]

  loc_02DBE4:
    COP [SetMetasprite] ( @sprite_set_list_17D000 )
    COP [StageSpriteMoveX] ( #02, #0A )
    COP [AnimOnce]

  loc_02DBEF:
    COP [StageSpriteMoveX] ( #06, #10 )
    COP [AnimOnce]
    LDA $10
    BIT #$00
    RTI 
    BEQ loc_02DBEF
    COP [Die]

  loc_02DBFE:
    COP [SetMetasprite] ( @sprite_set_list_17D000 )
    COP [StageSpriteMoveX] ( #03, #09 )
    COP [AnimOnce]

  loc_02DC09:
    COP [StageSpriteMoveX] ( #07, #0F )
    COP [AnimOnce]
    LDA $10
    BIT #$00
    RTI 
    BEQ loc_02DC09
    COP [Die]
}

code_02DC18 {
    PHP 
    PHD 
    PHX 
    STX $000A
    LDA #$00
    BRK #$5B
    LDA $24
    STZ $24
    STZ $AA
    PHA 
    LDA $0010, X
    AND #$FB
    SBC $00109D, X
    LDA $20
    BEQ loc_02DC4A
    BPL loc_02DC42
    LDA #$40
    BRK #$04
    TAX 
    JSR $&code_02E7C5
    BRA loc_02DC4A

  loc_02DC42:
    LDA #$40
    BRK #$04
    TAX 
    JSR $&code_02E324

  loc_02DC4A:
    REP #$20
    LDX $decelStepCounter
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
    BEQ loc_02DC7C
    BPL loc_02DC72
    LDA $AA
    BIT #$0800
    BNE loc_02DC7C
    JSR $&code_02DC80
    BRA loc_02DC7C

  loc_02DC72:
    LDA $AA
    BIT #$0400
    BNE loc_02DC7C
    JSR $&code_02DFBE

  loc_02DC7C:
    PLX 
    PLD 
    PLP 
    RTL 
}

code_02DC80 {
    SEP #$20
    JSR $&code_02EE33
    BCC loc_02DC9C
    CMP #$06
    BNE loc_02DC8E
    JMP $&code_02DDD0

  loc_02DC8E:
    CMP #$03
    BNE loc_02DC95
    JMP $&code_02DD36

  loc_02DC95:
    CMP #$0C
    BNE loc_02DC9C
    JMP $&code_02DD6A

  loc_02DC9C:
    JSR $&code_02EDEB
    CMP #$09
    BNE loc_02DCA6
    JMP $&code_02DE3A

  loc_02DCA6:
    JSR $&code_02EEA5
    CMP #$0E
    BCS loc_02DCF7
    CMP #$08
    BEQ loc_02DCF7
    CMP #$02
    BEQ loc_02DD1C
    CMP #$06
    BNE loc_02DCBC
    JMP $&code_02DE16

  loc_02DCBC:
    JSR $&code_02EFBE
    BCS loc_02DCCA
    CMP #$09
    BNE loc_02DCC8
    JMP $&code_02DE80

  loc_02DCC8:
    BRA loc_02DCED

  loc_02DCCA:
    CMP #$09
    BEQ loc_02DCF7
    JSR $&code_02EF85
    STX $00
    JSR $&code_02EF3E
    CMP #$0E
    BCS loc_02DCF7
    CMP #$08
    BEQ loc_02DCF7
    CMP #$02
    BEQ loc_02DCF7
    CMP #$09
    BNE loc_02DCE9
    JMP $&code_02DE80

  loc_02DCE9:
    CMP #$06
    BEQ loc_02DCF7

  loc_02DCED:
    REP #$20
    LDA $26
    CLC 
    ADC $24
    STA $26
    RTS 

  loc_02DCF7:
    JSR $&code_02ED9D
    JSR $&code_02DF07
    BCS code_02DD04
    PHP 
    REP #$20
    BRA loc_02DD0A

  code_02DD04:
    PHP 
    REP #$20
    STZ $decelCurvePtr

  loc_02DD0A:
    LDA $24
    CLC 
    ADC $26
    AND #$FFC0
    CLC 
    ADC #$0040
    STA $26
    STZ $24
    PLP 
    RTS 

  loc_02DD1C:
    JSR $&code_02EFBE
    BCS loc_02DCF7
    PHY 
    LDY $decelStepCounter
    REP #$20
    LDA #$D3FE
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    PLY 
    BRA loc_02DCF7
}

code_02DD36 {
    JSR $&code_02EDEB
    CMP #$03
    BNE loc_02DCF7
    JSR $&code_02EFCB
    BCC loc_02DD62
    JSR $&code_02EF55
    JSR $&code_02EF3E
    CMP #$03
    BEQ loc_02DD62
    LDA $26
    CLC 
    ADC $24
    LSR 
    LSR 
    AND #$0F
    SEC 
    SBC #$10
    EOR #$FF
    INC 
    CMP #$08
    BPL loc_02DD62
    JMP $&code_02EDB0

  loc_02DD62:
    LDA #$10
    TSB $09BD
    JMP $&code_02EDB0
}

code_02DD6A {
    JSR $&code_02EDEB
    CMP #$0C
    BNE loc_02DCF7
    JSR $&code_02EFCB
    BCC loc_02DD96
    JSR $&code_02EF55
    JSR $&code_02EF3E
    CMP #$0C
    BEQ loc_02DD96
    LDA $24
    CLC 
    ADC $26
    LSR 
    LSR 
    AND #$0F
    SEC 
    SBC #$10
    EOR #$FF
    INC 
    CMP #$08
    BPL loc_02DD96
    JMP $&code_02EDB0

  loc_02DD96:
    LDA #$10
    TSB $09BD
    REP #$20
    LDA $09D4
    BMI loc_02DDA5
    STZ $09D4

  loc_02DDA5:
    LDA $24
    CLC 
    ADC $09D4
    STA $09D4
    EOR #$FFFF
    INC 
    LSR 
    LSR 
    LSR 
    LSR 
    BEQ loc_02DDCD
    STA $24
    ASL 
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $09D4
    STA $09D4
    LDA $24
    EOR #$FFFF
    INC 
    STA $24

  loc_02DDCD:
    JMP $&code_02EDB0
}

code_02DDD0 {
    JSR $&code_02EDC5
    CMP #$06
    BNE loc_02DDDA
    JMP $&code_02ED96

  loc_02DDDA:
    JSR $&code_02EEA5
    JSR $&code_02EFCB
    BCC loc_02DDFA
    CMP #$06
    BNE loc_02DDFA

  loc_02DDE6:
    JSR $&code_02EF85
    STX $00
    JSR $&code_02EF3E
    BNE loc_02DE34
    JSR $&code_02EF55
    JSR $&code_02EF3E
    BNE loc_02DE34
    BRA loc_02DE0E

  loc_02DDFA:
    JSR $&code_02E855
    JSR $&code_02EEA5
    CMP #$06
}

code_02DE02 {
    BEQ loc_02DE0E

  loc_02DE04:
    REP #$20
    STZ $24
    JSR $&code_02E03F
    JMP $&code_02EDB0

  loc_02DE0E:
    REP #$20
    JSR $&code_02DE8E
    JMP $&code_02E2E2
}

code_02DE16 {
    LDA $AB
    BIT #$02
    BEQ loc_02DE28
    JSR $&code_02EFBE
    BCS loc_02DE28
    REP #$20
    STZ $24
    JMP $&code_02EDB0

  loc_02DE28:
    JSR $&code_02EF85
    JSR $&code_02EF3E
    CMP #$0E
    BCS loc_02DE04
    BRA loc_02DDE6

  loc_02DE34:
    REP #$20
    STZ $decelCurvePtr
    RTS 
}

code_02DE3A {
    JSR $&code_02EE0F
    CMP #$09
    BNE loc_02DE44
    JMP $&code_02ED96

  loc_02DE44:
    JSR $&code_02EE4F
    JSR $&code_02EFCB
    BCC loc_02DE64
    CMP #$09
    BNE loc_02DE64

  loc_02DE50:
    JSR $&code_02EF9F
    STX $00
    JSR $&code_02EF3E
    BNE loc_02DE88
    JSR $&code_02EF55
    JSR $&code_02EF3E
    BNE loc_02DE88
    BRA loc_02DE78

  loc_02DE64:
    JSR $&code_02E3A8
    JSR $&code_02EE4F
    CMP #$09
    BEQ loc_02DE78
    REP #$20
    STZ $24
    JSR $&code_02E03F
    JMP $&code_02EDB0

  loc_02DE78:
    REP #$20
    JSR $&code_02DE8E
    JMP $&code_02E29D
}

code_02DE80 {
    JSR $&code_02EF55
    JSR $&code_02EF3E
    BRA loc_02DE50

  loc_02DE88:
    REP #$20
    STZ $decelCurvePtr
    RTS 
}

code_02DE8E {
    REP #$20
    LDA $1E
    AND #$000F
    ORA #$FFF0
    EOR #$FFFF
    INC 
    STA $02
    RTS 
}

code_02DE9F {
    REP #$20
    LDA $1A
    PHA 
    LDA $1E
    PHA 
    SEP #$20
    JSR $&code_02EE33
    CMP #$06
    BEQ loc_02DEBF
    JSR $&code_02EFBE
    BCC loc_02DEEB
    JSR $&code_02EF85
    JSR $&code_02EF3E
    CMP #$09
    BNE loc_02DEEB

  loc_02DEBF:
    REP #$20
    PLA 
    STA $1E
    PLA 
    STA $1A
    STZ $02
    LDA $1E
    PHA 
    LDA $24
    BEQ loc_02DED5
    LSR 
    LSR 
    ORA #$C000

  loc_02DED5:
    EOR #$FFFF
    INC 
    CLC 
    ADC $01, S
    EOR $01, S
    BIT #$0010
    BEQ loc_02DEE8
    LDA #$0010
    STA $02

  loc_02DEE8:
    PLA 
    BRA loc_02DEF5

  loc_02DEEB:
    REP #$20
    PLA 
    STA $1E
    PLA 
    STA $1A
    STZ $02

  loc_02DEF5:
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

code_02DF07 {
    REP #$20
    LDA $AA
    BIT #$0040
    BNE loc_02DF81
    LDA $collisionLayer, X
    AND #$00FF
    BIT #$00F0
    BNE loc_02DF81
    LDA $22
    LSR 
    LSR 
    SEC 
    SBC #$0008
    AND #$000F
    STA $04
    BEQ loc_02DF81
    CMP #$0006
    BCC loc_02DF55
    JSR $&code_02EE4F
    CMP #$000E
    BCS loc_02DF55
    CMP #$0006
    BEQ loc_02DF55
    LDX #$0022
    LDA $00, X
    SEC 
    SBC #$0020
    STA $00, X
    JSR $&code_02DF83
    LDA $00, X
    CLC 
    ADC #$0020
    STA $00, X
    CLC 
    RTS 

  loc_02DF55:
    LDA $04
    CMP #$0009
    BCS loc_02DF81
    JSR $&code_02EEA5
    CMP #$000E
    BCS loc_02DF81
    CMP #$0009
    BEQ loc_02DF81
    LDX #$0022
    LDA $00, X
    SEC 
    SBC #$0020
    STA $00, X
    JSR $&code_02DF9C
    LDA $00, X
    CLC 
    ADC #$0020
    STA $00, X
    CLC 
    RTS 

  loc_02DF81:
    SEC 
    RTS 
}

code_02DF83 {
    LDA $00, X
    PHA 
    CLC 
    ADC #$0008
    STA $00, X
    EOR $01, S
    BIT #$0040
    BEQ loc_02DF9A
    LDA $00, X
    AND #$FFC0
    STA $00, X

  loc_02DF9A:
    PLA 
    RTS 
}

code_02DF9C {
    LDA $00, X
    PHA 
    SEC 
    SBC #$0008
    STA $00, X
    EOR $01, S
    BIT #$0040
    BEQ loc_02DFBC
    LDA $00, X
    BIT #$003F
    BEQ loc_02DFBC
    AND #$FFC0
    CLC 
    ADC #$0040
    STA $00, X

  loc_02DFBC:
    PLA 
    RTS 
}

code_02DFBE {
    SEP #$20
    JSR $&code_02EE0F
    CMP #$09
    BNE loc_02DFCA
    JMP $&code_02E122

  loc_02DFCA:
    CMP #$03
    BNE loc_02DFD1
    JMP $&code_02E096

  loc_02DFD1:
    CMP #$0C
    BNE loc_02DFD8
    JMP $&code_02E0C7

  loc_02DFD8:
    JSR $&code_02EDC5
    CMP #$06
    BNE loc_02DFE2
    JMP $&code_02E17E

  loc_02DFE2:
    JSR $&code_02EEC7
    CMP #$0E
    BCC loc_02DFEC
    JMP $&code_02E032

  loc_02DFEC:
    CMP #$02
    BEQ loc_02E053
    CMP #$08
    BEQ loc_02E06D
    CMP #$09
    BNE loc_02DFFB
    JMP $&code_02E16C

  loc_02DFFB:
    JSR $&code_02EFBE
    BCS loc_02E009
    CMP #$06
    BNE loc_02E007
    JMP $&code_02E1C4

  loc_02E007:
    BRA loc_02E028

  loc_02E009:
    CMP #$06
    BEQ code_02E032
    JSR $&code_02EF85
    STX $00
    JSR $&code_02EF3E
    CMP #$0E
    BCS code_02E032
    CMP #$02
    BEQ code_02E032
    CMP #$06
    BNE loc_02E024
    JMP $&code_02E1C4

  loc_02E024:
    CMP #$09
    BEQ code_02E032

  loc_02E028:
    REP #$20
    LDA $26
    CLC 
    ADC $24
    STA $26
    RTS 
}

code_02E032 {
    JSR $&code_02ED9D
    JSR $&code_02E1CC
    BCS code_02E03F
    PHP 
    REP #$20
    BRA loc_02E045
}

code_02E03F {
    PHP 
    REP #$20
    STZ $decelCurvePtr

  loc_02E045:
    LDA $24
    CLC 
    ADC $26
    AND #$FFC0
    STA $26
    STZ $24
    PLP 
    RTS 

  loc_02E053:
    JSR $&code_02EFBE
    BCS code_02E032
    PHY 
    REP #$20
    LDY $decelStepCounter
    LDA #$D42A
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    PLY 
    BRA code_02E032

  loc_02E06D:
    JSR $&code_02EFBE
    BCC loc_02E07C
    JSR $&code_02EF85
    JSR $&code_02EF3E
    CMP #$08
    BNE code_02E032

  loc_02E07C:
    LDA #$08
    TSB $09BD
    PHY 
    LDY $decelStepCounter
    REP #$20
    LDA #$D271
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    PLY 
    BRA code_02E03F
}

code_02E096 {
    JSR $&code_02EDC5
    CMP #$03
    BEQ loc_02E0A0
    JMP $&code_02E032

  loc_02E0A0:
    JSR $&code_02EFCB
    BCC loc_02E0BF
    JSR $&code_02EF6D
    JSR $&code_02EF3E
    CMP #$03
    BEQ loc_02E0BF
    LDA $24
    CLC 
    ADC $26
    LSR 
    LSR 
    AND #$0F
    CMP #$08
    BPL loc_02E0BF
    JMP $&code_02EDB0

  loc_02E0BF:
    LDA #$10
    TSB $09BD
    JMP $&code_02EDB0
}

code_02E0C7 {
    JSR $&code_02EDC5
    CMP #$0C
    BEQ loc_02E0D1
    JMP $&code_02E032

  loc_02E0D1:
    JSR $&code_02EFCB
    BCC loc_02E0F0
    JSR $&code_02EF6D
    JSR $&code_02EF3E
    CMP #$0C
    BEQ loc_02E0F0
    LDA $24
    CLC 
    ADC $26
    LSR 
    LSR 
    AND #$0F
    CMP #$08
    BPL loc_02E0F0
    JMP $&code_02EDB0

  loc_02E0F0:
    LDA #$10
    TSB $09BD
    REP #$20
    LDA $09D4
    BPL loc_02E0FF
    STZ $09D4

  loc_02E0FF:
    LDA $24
    CLC 
    ADC $09D4
    STA $09D4
    LSR 
    LSR 
    LSR 
    LSR 
    BEQ loc_02E11F
    STA $24
    ASL 
    ASL 
    ASL 
    ASL 
    EOR #$FFFF
    INC 
    CLC 
    ADC $09D4
    STA $09D4

  loc_02E11F:
    JMP $&code_02EDB0
}

code_02E122 {
    JSR $&code_02EDEB

  loc_02E125:
    CMP #$D009
    ORA $4C, S
    STX $ED, Y
    JSR $&code_02EEC7
    JSR $&code_02EFCB
    BCC loc_02E14C
    CMP #$D009
    TRB $20
    STA $EF
    STX $00

  loc_02E13D:
    JSR $&code_02EF3E
    BNE loc_02E178
    JSR $&code_02EF6D
    JSR $&code_02EF3E
    BNE loc_02E178
    BRA loc_02E164

  loc_02E14C:
    JSR $&code_02E855
    JSR $&code_02EEC7
    BCC loc_02E164
    CMP #$F001
    TSB $09C9
    BEQ loc_02E164
    REP #$20

  loc_02E15E:
    JSR $&code_02E03F
    JMP $&code_02EDB0

  loc_02E164:
    REP #$20
    JSR $&code_02E241
    JMP $&code_02E2E2
}

code_02E16C {
    JSR $&code_02EF85
    JSR $&code_02EF3E
    CMP #$0E
    BCS loc_02E15E
    BRA loc_02E138

  loc_02E178:
    REP #$20
    STZ $decelCurvePtr
    RTS 
}

code_02E17E {
    JSR $&code_02EE33
    CMP #$06
    BNE loc_02E188
    JMP $&code_02ED96

  loc_02E188:
    JSR $&code_02EE79
    JSR $&code_02EFCB
    BCC loc_02E1A8
    CMP #$06
    BNE loc_02E1A8

  loc_02E194:
    JSR $&code_02EF9F
    STX $00
    JSR $&code_02EF3E
    BNE loc_02E1C6
    JSR $&code_02EF6D
    JSR $&code_02EF3E
    BNE loc_02E1C6
    BRA loc_02E1BC

  loc_02E1A8:
    JSR $&code_02E3A8
    JSR $&code_02EE79
    CMP #$06
    BEQ loc_02E1BC
    REP #$20
    STZ $24
    JSR $&code_02DD04
    JMP $&code_02EDB0

  loc_02E1BC:
    REP #$20
    JSR $&code_02E241
    JMP $&code_02E29D
}

code_02E1C4 {
    BRA loc_02E194

  loc_02E1C6:
    REP #$20
    STZ $decelCurvePtr
    RTS 
}

code_02E1CC {
    REP #$20
    LDA $AA
    BIT #$0040
    BNE loc_02E23F
    LDA $collisionLayer, X
    AND #$00FF
    BIT #$00F0
    BNE loc_02E23F
    LDA $22
    LSR 
    LSR 
    AND #$000F
    SEC 
    SBC #$0008
    AND #$000F
    STA $04
    BEQ loc_02E23F
    CMP #$0006
    BCC loc_02E218
    JSR $&code_02EE79
    CMP #$000E
    BCS loc_02E218
    LDX #$0022
    LDA $00, X
    SEC 
    SBC #$0020
    STA $00, X
    JSR $&code_02DF83
    LDA $00, X
    CLC 
    ADC #$0020
    STA $00, X
    CLC 
    RTS 

  loc_02E218:
    LDA $04
    CMP #$0009
    BCS loc_02E23F
    JSR $&code_02EEC7
    CMP #$000E
    BCS loc_02E23F
    LDX #$0022
    LDA $00, X
    SEC 
    SBC #$0020
    STA $00, X
    JSR $&code_02DF9C
    LDA $00, X
    CLC 
    ADC #$0020
    STA $00, X
    CLC 
    RTS 

  loc_02E23F:
    SEC 
    RTS 
}

code_02E241 {
    REP #$20
    LDA $1A
    PHA 
    LDA $1E
    PHA 
    SEP #$20
    JSR $&code_02EE0F
    CMP #$09
    BEQ loc_02E261
    JSR $&code_02EFBE
    BCC loc_02E288
    JSR $&code_02EF85
    JSR $&code_02EF3E
    CMP #$06
    BNE loc_02E288

  loc_02E261:
    REP #$20
    PLA 
    STA $1E
    PLA 
    STA $1A
    STZ $02
    LDA $1E
    PHA 
    LDA $24
    LSR 
    LSR 
    SEC 
    SBC $01, S
    EOR #$FFFF
    INC 
    EOR $01, S
    BIT #$0010
    BEQ loc_02E285
    LDA #$0010
    STA $02

  loc_02E285:
    PLA 
    BRA loc_02E292

  loc_02E288:
    REP #$20
    PLA 
    STA $1E
    PLA 
    STA $1A
    STZ $02

  loc_02E292:
    LDA $1E
    AND #$000F
    CLC 
    ADC $02
    STA $02
    RTS 
}

code_02E29D {
    LDX $decelStepCounter
    LDA $0014, X
    SEC 
    SBC #$0008
    AND #$000F
    BNE loc_02E2AF
    LDA #$0010

  loc_02E2AF:
    CLC 
    ADC $02
    CMP #$0011
    BCS loc_02E2BA
    JMP $&code_02EDB0

  loc_02E2BA:
    LDA #$0010
    SEC 
    SBC $02
    STA $02
    LDA $0014, X
    SEC 
    SBC #$0008
    BIT #$000F
    BNE loc_02E2D2
    SEC 
    SBC #$0010

  loc_02E2D2:
    AND #$FFF0
    ORA $02
    CLC 
    ADC #$0008
    ASL 
    ASL 
    STA $22
    JMP $&code_02EDB0
}

code_02E2E2 {
    LDX $decelStepCounter
    LDA $0014, X
    SEC 
    SBC #$0008
    ORA #$FFF0
    EOR #$FFFF
    INC 
    CLC 
    ADC $02
    CMP #$0011
    BCS loc_02E2FE
    JMP $&code_02EDB0

  loc_02E2FE:
    LDA #$0010
    SEC 
    SBC $02
    ORA #$FFF0
    EOR #$FFFF
    INC 
    STA $02
    LDA $0014, X
    SEC 
    SBC #$0008
    AND #$FFF0
    ORA $02
    CLC 
    ADC #$0008
    ASL 
    ASL 
    STA $22
    JMP $&code_02EDB0
}

code_02E324 {
    SEP #$20
    JSR $&code_02BEC7
    BNE loc_02E333
    BCS loc_02E330
    JMP $&code_02E488

  loc_02E330:
    JMP $&code_02E5CB

  loc_02E333:
    JSR $&code_02EDEB
    CMP #$09
    BNE loc_02E33D
    JMP $&code_02E3E0

  loc_02E33D:
    JSR $&code_02EDC5
    CMP #$06
    BNE loc_02E347
    JMP $&code_02E434

  loc_02E347:
    JSR $&code_02EE4F
    CMP #$0E
    BCS loc_02E39B
    CMP #$09
    BNE loc_02E355
    JMP $&code_02E426

  loc_02E355:
    JSR $&code_02EFCB
    BCS loc_02E363
    CMP #$06
    BNE loc_02E361
    JMP $&code_02E460

  loc_02E361:
    BRA loc_02E37C

  loc_02E363:
    CMP #$06
    BEQ loc_02E39B
    JSR $&code_02EF55
    JSR $&code_02EF3E
    CMP #$0E
    BCS loc_02E39B
    CMP #$06
    BNE loc_02E378
    JMP $&code_02E460

  loc_02E378:
    CMP #$09
    BEQ loc_02E39B

  loc_02E37C:
    CMP #$07
    BEQ loc_02E3C4
    JSR $&code_02EE0F
    CMP #$05
    BNE loc_02E38A
    JMP $&code_02E6CF

  loc_02E38A:
    CMP #$0A
    BNE loc_02E391
    JMP $&code_02E584

  loc_02E391:
    REP #$20
    LDA $22
    CLC 
    ADC $20
    STA $22
    RTS 

  loc_02E39B:
    JSR $&code_02ED9D
    JSR $&code_02E712
    BCS code_02E3A8
    PHP 
    REP #$20
    BRA loc_02E3AE
}

code_02E3A8 {
    PHP 
    REP #$20
    STZ $09C0

  loc_02E3AE:
    LDA $20
    CLC 
    ADC $22
    SEC 
    SBC #$0020
    AND #$FFC0
    CLC 
    ADC #$0020
    STA $22
    STZ $20
    PLP 
    RTS 

  loc_02E3C4:
    JSR $&code_02EFCB
    BCS loc_02E39B
    PHY 
    REP #$20
    LDY $decelStepCounter
    LDA #$D505
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    PLY 
    BRA loc_02E39B

  code_02E3DE:
    SEP #$20
}

code_02E3E0 {
    LDA #$80
    TSB $AB
    JSR $&code_02EE4F
    JSR $&code_02EFBE
    BCC loc_02E40C
    CMP #$09
    BNE loc_02E40C

  loc_02E3F0:
    JSR $&code_02EF55
    STX $00
    JSR $&code_02EF3E
    BEQ loc_02E3FE
    CMP #$0A
    BNE loc_02E42C

  loc_02E3FE:
    JSR $&code_02EF9F
    JSR $&code_02EF3E
    BEQ loc_02E41E
    CMP #$09
    BNE loc_02E42C
    BRA loc_02E41E

  loc_02E40C:
    JSR $&code_02DD04
    JSR $&code_02EE4F
    BCC loc_02E41E
    CMP #$09
    BEQ loc_02E41E
    JSR $&code_02E3A8
    JMP $&code_02EDB0

  loc_02E41E:
    REP #$20
    JSR $&code_02E767
    JMP $&code_02ECED
}

code_02E426 {
    LDA #$04
    TSB $AB
    BRA loc_02E3F0

  loc_02E42C:
    REP #$20
    STZ $09C0
    RTS 
}

code_02E432 {
    SEP #$20
}

code_02E434 {
    LDA #$80
    TSB $AB
    JSR $&code_02EE79
    JSR $&code_02EFBE
    BCC loc_02E468
    CMP #$06
    BNE loc_02E468

  loc_02E444:
    JSR $&code_02EF6D
    STX $00
    JSR $&code_02EF3E
    BEQ loc_02E452
    CMP #$05
    BNE loc_02E482

  loc_02E452:
    JSR $&code_02EF9F
    JSR $&code_02EF3E
    BEQ loc_02E47A
    CMP #$06
    BNE loc_02E482
    BRA loc_02E47A
}

code_02E460 {
    STX $00
    LDA #$08
    TSB $AB
    BRA loc_02E444

  loc_02E468:
    JSR $&code_02E03F
    JSR $&code_02EE79
    BCC loc_02E47A
    CMP #$06
    BEQ loc_02E47A
    JSR $&code_02E3A8
    JMP $&code_02EDB0

  loc_02E47A:
    REP #$20
    JSR $&code_02E767
    JMP $&code_02ECA2

  loc_02E482:
    REP #$20
    STZ $09C0
    RTS 
}

code_02E488 {
    JSR $&code_02ED3C
    JSR $&code_02EDEB
    LDA $1A
    SEC 
    SBC #$08
    BRK #$85
    INC 
    JSR $&code_02EEF1
    AND #$FF
    BRK #$C9
    ASL 
    BRK #$F0
    RTL 
}

code_02E4A1 {
    JSR $&code_02EF55
    SEP #$20
    JSR $&code_02EF3E
    REP #$20
    AND #$00FF
    CMP #$000A
    BEQ code_02E50C
    JSR $&code_02EE4F
    LDA $1A
    SEC 
    SBC #$0009
    STA $1A
    JSR $&code_02EEF1
    AND #$00FF
    CMP #$000A
    BEQ loc_02E4DE
    JSR $&code_02EF55
    SEP #$20
    JSR $&code_02EF3E
    REP #$20
    AND #$00FF
    CMP #$000A
    BEQ loc_02E4DE
    JMP $&code_02E5BD

  loc_02E4DE:
    JSR $&code_02ED81
    BNE loc_02E4E6
    JMP $&code_02EDB0

  loc_02E4E6:
    LDA $20
    CLC 
    ADC $22
    LSR 
    LSR 
    AND #$000F
    ASL 
    ASL 
    CLC 
    ADC $26
    STA $26
    CLC 
    ADC $20
    CLC 
    ADC $22
    LSR 
    LSR 
    LSR 
    BCC code_02E513
    LDA $26
    CLC 
    ADC #$0004
    STA $26
    BRA code_02E513

  code_02E50C:
    LDA $20
    CLC 
    ADC $26
    STA $26

  code_02E513:
    LDA #$1000
    TSB $slopeCurvePtrB
    SEP #$20
    JSR $&code_02EE4F
    CMP #$0E
    BCS loc_02E52F
    JSR $&code_02EE79
    CMP #$0E
    BCS loc_02E52C
    JMP $&code_02EDB0

  loc_02E52C:
    JMP $&code_02E574

  loc_02E52F:
    JSR $&code_02EE79
    CMP #$0E
    BCS loc_02E539
    JMP $&code_02E57C

  loc_02E539:
    REP #$20
    LDA $22
    PHA 
    CLC 
    ADC $20
    LSR 
    LSR 
    SEC 
    SBC #$0008
    BIT #$000F
    BEQ loc_02E54F
    AND #$FFF0

  loc_02E54F:
    CLC 
    ADC #$0008
    ASL 
    ASL 
    STA $22
    SEC 
    SBC $01, S
    SEC 
    SBC $20
    EOR #$FFFF
    INC 
    CLC 
    ADC $26
    STA $26
    PLA 
    STZ $20
    STZ $24
    STZ $09C0
    JSR $&code_02ED9D
    JMP $&code_02EDB0
}

code_02E574 {
    REP #$20
    JSR $&code_02E03F
    JMP $&code_02EDB0
}

code_02E57C {
    REP #$20
    JSR $&code_02DD04
    JMP $&code_02EDB0
}

code_02E584 {
    JSR $&code_02ED3C
    LDA $1A
    CLC 

  loc_02E58A:
    ADC #$08
    BRK #$85
    INC 
    JSR $&code_02EEF1
    AND #$FF
    BRK #$C9
    ASL 
    BRK #$F0
    ORA $4C, S
    BCS loc_02E58A
    JSR $&code_02ED81
    BNE loc_02E5A5
    JMP $&code_02E50C

  loc_02E5A5:
    LDA $20
    LSR 
    LSR 
    CLC 
    ADC $1A
    AND #$0F
    BRK #$0A
    ASL 
    SEC 
    SBC $20
    EOR #$FF
    SBC $@24851A, X
    JMP $&code_02E513
}

code_02E5BD {
    JSR $&code_02EE4F
    CMP #$0009
    BNE loc_02E5C8
    JMP $&code_02E3DE

  loc_02E5C8:
    JMP $&code_02EDB0
}

code_02E5CB {
    JSR $&code_02ED3C
    JSR $&code_02EDC5
    LDA $1A
    SEC 
    SBC #$08
    BRK #$85
    INC 
    JSR $&code_02EEF1
    AND #$FF
    BRK #$C9
    ORA $00
    BEQ code_02E653
    JSR $&code_02EF6D
    SEP #$20
    JSR $&code_02EF3E
    REP #$20
    AND #$00FF
    CMP #$0005
    BEQ code_02E653
    JSR $&code_02EE4F
    LDA $1A
    SEC 
    SBC #$0009
    STA $1A
    JSR $&code_02EEF1
    AND #$00FF
    CMP #$0005
    BEQ loc_02E621
    JSR $&code_02EF55
    SEP #$20
    JSR $&code_02EF3E
    REP #$20
    AND #$00FF
    CMP #$0005
    BEQ loc_02E621
    JMP $&code_02E704

  loc_02E621:
    JSR $&code_02ED81
    BNE loc_02E629
    JMP $&code_02EDB0

  loc_02E629:
    LDA $20
    CLC 
    ADC $22
    LSR 
    LSR 
    AND #$000F
    ASL 
    ASL 
    EOR #$FFFF
    INC 
    CLC 
    ADC $26
    STA $26
    CLC 
    ADC $20
    CLC 
    ADC $22
    LSR 
    LSR 
    LSR 
    BCC code_02E65E
    LDA $26
    SEC 
    SBC #$0004
    STA $26
    BRA code_02E65E

  code_02E653:
    LDA $20
    EOR #$FF
    SBC $@25181A, X
    ROL $85
    ROL $A9
    BRK #$10
    TSB $slopeCurvePtrB
    SEP #$20
    JSR $&code_02EE4F
    CMP #$0E
    BCS loc_02E67A
    JSR $&code_02EE79
    CMP #$0E
    BCS loc_02E677
    JMP $&code_02EDB0

  loc_02E677:
    JMP $&code_02E6BF

  loc_02E67A:
    JSR $&code_02EE79
    CMP #$0E
    BCS loc_02E684
    JMP $&code_02E6C7

  loc_02E684:
    REP #$20
    LDA $22
    PHA 
    CLC 
    ADC $20
    LSR 
    LSR 
    SEC 
    SBC #$0008
    BIT #$000F
    BEQ loc_02E69A
    AND #$FFF0

  loc_02E69A:
    CLC 
    ADC #$0008
    ASL 
    ASL 
    STA $22
    SEC 
    SBC $01, S
    SEC 
    SBC $20
    EOR #$FFFF
    INC 
    CLC 
    ADC $26
    STA $26
    PLA 
    STZ $20
    STZ $24
    STZ $09C0
    JSR $&code_02ED9D
    JMP $&code_02EDB0
}

code_02E6BF {
    REP #$20
    JSR $&code_02E03F
    JMP $&code_02EDB0
}

code_02E6C7 {
    REP #$20
    JSR $&code_02DD04
    JMP $&code_02EDB0
}

code_02E6CF {
    JSR $&code_02ED3C
    LDA $1A
    CLC 
    ADC #$08
    BRK #$85
    INC 
    JSR $&code_02EEF1
    AND #$FF
    BRK #$C9
    ORA $00
    BEQ loc_02E6E8
    JMP $&code_02EDB0

  loc_02E6E8:
    JSR $&code_02ED81
    BNE loc_02E6F0
    JMP $&code_02E653

  loc_02E6F0:
    LDA $20
    LSR 
    LSR 
    CLC 
    ADC $1A
    AND #$0F
    BRK #$0A
    ASL 
    SEC 
    SBC $20
    STA $24
    JMP $&code_02E65E
}

code_02E704 {
    JSR $&code_02EE79
    CMP #$0006
    BNE loc_02E70F
    JMP $&code_02E432

  loc_02E70F:
    JMP $&code_02EDB0
}

code_02E712 {
    PHP 
    REP #$20
    LDA $06, S
    BNE loc_02E764
    LDA $collisionLayer, X
    AND #$00FF
    BIT #$00F0
    BNE loc_02E764
    LDA $26
    LSR 
    LSR 
    AND #$000F
    BEQ loc_02E764
    STA $04
    CMP #$0004
    BCC loc_02E749
    JSR $&code_02EE79
    AND #$00FF
    CMP #$000E
    BCS loc_02E749
    LDX #$0026
    JSR $&code_02DF83
    PLP 
    CLC 
    RTS 

  loc_02E749:
    LDA $04
    CMP #$000B
    BCS loc_02E764
    JSR $&code_02EE4F
    AND #$00FF
    CMP #$000E
    BCS loc_02E764
    LDX #$0026
    JSR $&code_02DF9C
    PLP 
    CLC 
    RTS 

  loc_02E764:
    PLP 
    SEC 
    RTS 
}

code_02E767 {
    REP #$20
    STZ $02
    LDA $1A
    PHA 
    LDA $1E
    PHA 
    SEP #$20
    JSR $&code_02EDEB
    CMP #$09
    BEQ loc_02E789
    JSR $&code_02EFCB
    BCC loc_02E7B0
    JSR $&code_02EF55
    JSR $&code_02EF3E
    CMP #$06
    BNE loc_02E7B0

  loc_02E789:
    REP #$20
    PLA 
    STA $1E
    PLA 
    STA $1A
    STZ $02
    LDA $1A
    PHA 
    LDA $20
    LSR 
    LSR 
    SEC 
    SBC $01, S
    EOR #$FFFF
    INC 
    EOR $01, S
    BIT #$0010
    BEQ loc_02E7AD
    LDA #$0010
    STA $02

  loc_02E7AD:
    PLA 
    BRA loc_02E7BA

  loc_02E7B0:
    REP #$20
    PLA 
    STA $1E
    PLA 
    STA $1A
    STZ $02

  loc_02E7BA:
    LDA $1A
    AND #$000F
    CLC 
    ADC $02
    STA $02
    RTS 
}

code_02E7C5 {
    SEP #$20
    LDA #$02
    TSB $AB
    JSR $&code_02BE74
    BNE loc_02E7D8
    BCS loc_02E7D5
    JMP $&code_02EA93

  loc_02E7D5:
    JMP $&code_02E935

  loc_02E7D8:
    JSR $&code_02EE33
    BCC loc_02E7E4
    CMP #$06
    BNE loc_02E7E4
    JMP $&code_02E88D

  loc_02E7E4:
    JSR $&code_02EE0F
    BCC loc_02E7F0
    CMP #$09
    BNE loc_02E7F0
    JMP $&code_02E8E1

  loc_02E7F0:
    JSR $&code_02EEA5
    BCC loc_02E800
    CMP #$0E
    BCS loc_02E848
    CMP #$06
    BNE loc_02E800
    JMP $&code_02E8B9

  loc_02E800:
    JSR $&code_02EFCB
    BCS loc_02E80E
    CMP #$09
    BNE loc_02E80C
    JMP $&code_02E90D

  loc_02E80C:
    BRA loc_02E827

  loc_02E80E:
    CMP #$09
    BEQ loc_02E848
    JSR $&code_02EF55
    JSR $&code_02EF3E
    CMP #$0E
    BCS loc_02E848
    CMP #$09
    BNE loc_02E823
    JMP $&code_02E90D

  loc_02E823:
    CMP #$06
    BEQ loc_02E848

  loc_02E827:
    CMP #$07
    BEQ loc_02E871
    JSR $&code_02EDEB
    BCC loc_02E83E
    CMP #$05
    BNE loc_02E837
    JMP $&code_02EA44

  loc_02E837:
    CMP #$0A
    BNE loc_02E83E
    JMP $&code_02EB9E

  loc_02E83E:
    REP #$20
    LDA $22
    CLC 
    ADC $20
    STA $22
    RTS 

  loc_02E848:
    JSR $&code_02ED9D
    JSR $&code_02EBE9
    BCS code_02E855
    PHP 
    REP #$20
    BRA loc_02E85B
}

code_02E855 {
    PHP 
    REP #$20
    STZ $09C0

  loc_02E85B:
    LDA $20
    CLC 
    ADC $22
    SEC 
    SBC #$0020
    AND #$FFC0
    CLC 
    ADC #$0060
    STA $22
    STZ $20
    PLP 
    RTS 

  loc_02E871:
    JSR $&code_02EFCB
    BCS loc_02E848
    PHY 
    REP #$20
    LDY $decelStepCounter
    LDA #$D583
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    PLY 
    BRA loc_02E848

  code_02E88B:
    SEP #$20
}

code_02E88D {
    LDA #$80
    TSB $AB
    JSR $&code_02EEA5
    JSR $&code_02EFBE
    BCC loc_02E8BF
    CMP #$06
    BNE loc_02E8BF

  loc_02E89D:
    JSR $&code_02EF55
    STX $00
    JSR $&code_02EF3E
    BEQ loc_02E8AB
    CMP #$05
    BNE loc_02E8D9

  loc_02E8AB:
    JSR $&code_02EF85
    JSR $&code_02EF3E
    BEQ loc_02E8D1
    CMP #$06
    BNE loc_02E8D9
    BRA loc_02E8D1
}

code_02E8B9 {
    LDA #$04
    TSB $AB
    BRA loc_02E89D

  loc_02E8BF:
    JSR $&code_02DD04
    JSR $&code_02EEA5
    BCC loc_02E8D1
    CMP #$06
    BEQ loc_02E8D1
    JSR $&code_02E855
    JMP $&code_02EDB0

  loc_02E8D1:
    REP #$20
    JSR $&code_02EC38
    JMP $&code_02ECED

  loc_02E8D9:
    REP #$20
    STZ $09C0
    RTS 
}

code_02E8DF {
    SEP #$20
}

code_02E8E1 {
    LDA #$80
    TSB $AB
    JSR $&code_02EEC7
    JSR $&code_02EFBE
    BCC loc_02E915
    CMP #$09
    BNE loc_02E915

  loc_02E8F1:
    JSR $&code_02EF6D
    STX $00
    JSR $&code_02EF3E
    BEQ loc_02E8FF
    CMP #$0A
    BNE loc_02E92F

  loc_02E8FF:
    JSR $&code_02EF85
    JSR $&code_02EF3E
    BEQ loc_02E927
    CMP #$09
    BNE loc_02E92F
    BRA loc_02E927
}

code_02E90D {
    STX $00
    LDA #$08
    TSB $AB
    BRA loc_02E8F1

  loc_02E915:
    JSR $&code_02E03F
    JSR $&code_02EEC7
    BCC loc_02E927
    CMP #$09
    BEQ loc_02E927
    JSR $&code_02E855
    JMP $&code_02EDB0

  loc_02E927:
    REP #$20
    JSR $&code_02EC38
    JMP $&code_02ECA2

  loc_02E92F:
    REP #$20
    STZ $09C0
    RTS 
}

code_02E935 {
    JSR $&code_02ED3C
    JSR $&code_02EE33
    LDA $1A
    CLC 
    ADC #$08
    BRK #$85
    INC 
    JSR $&code_02EEF1
    AND #$FF
    BRK #$C9
    ORA $00
    BNE loc_02E951
    JMP $&code_02E9C4

  loc_02E951:
    JSR $&code_02EF55
    SEP #$20
    JSR $&code_02EF3E
    REP #$20
    AND #$00FF
    CMP #$0005
    BEQ code_02E9C4
    JSR $&code_02EEA5
    LDA $1A
    CLC 
    ADC #$0008
    STA $1A
    JSR $&code_02EEF1
    AND #$00FF
    CMP #$0005
    BEQ loc_02E98E
    JSR $&code_02EF55
    SEP #$20
    JSR $&code_02EF3E
    REP #$20
    AND #$00FF
    CMP #$0005
    BEQ loc_02E98E
    JMP $&code_02EA85

  loc_02E98E:
    JSR $&code_02ED81
    BNE loc_02E996
    JMP $&code_02EDB0

  loc_02E996:
    LDA $20
    CLC 
    ADC $22
    LSR 
    LSR 
    AND #$000F
    EOR #$FFFF
    INC 
    CLC 
    ADC #$0010
    ASL 
    ASL 
    CLC 
    ADC $26
    STA $26
    CLC 
    ADC $20
    CLC 
    ADC $22
    LSR 
    LSR 
    LSR 
    BCC code_02E9CF
    LDA $26
    CLC 
    ADC #$0004
    STA $26
    BRA code_02E9CF
}

code_02E9C4 {
    LDA $20
    EOR #$FF
    SBC $@25181A, X
    ROL $85
    ROL $A9
    BRK #$10
    TSB $slopeCurvePtrB
    SEP #$20
    JSR $&code_02EEA5
    CMP #$0E
    BCS loc_02E9EB
    JSR $&code_02EEC7
    CMP #$0E
    BCS loc_02E9E8
    JMP $&code_02EDB0

  loc_02E9E8:
    JMP $&code_02EA34

  loc_02E9EB:
    JSR $&code_02EEC7
    CMP #$0E
    BCS loc_02E9F5
    JMP $&code_02EA3C

  loc_02E9F5:
    REP #$20
    LDA $22
    PHA 
    CLC 
    ADC $20
    LSR 
    LSR 
    SEC 
    SBC #$0008
    BIT #$000F
    BEQ loc_02EA0F
    AND #$FFF0
    CLC 
    ADC #$0010

  loc_02EA0F:
    CLC 
    ADC #$0008
    ASL 
    ASL 
    STA $22
    SEC 
    SBC $01, S
    SEC 
    SBC $20
    EOR #$FFFF
    INC 
    CLC 
    ADC $26
    STA $26
    PLA 
    STZ $20
    STZ $24
    STZ $09C0
    JSR $&code_02ED9D
    JMP $&code_02EDB0
}

code_02EA34 {
    REP #$20
    JSR $&code_02E03F
    JMP $&code_02EDB0
}

code_02EA3C {
    REP #$20
    JSR $&code_02DD04
    JMP $&code_02EDB0
}

code_02EA44 {
    JSR $&code_02ED3C
    LDA $1A
    SEC 
    SBC #$09
    BRK #$85
    INC 
    JSR $&code_02EEF1
    AND #$FF
    BRK #$C9
    ORA $00
    BEQ loc_02EA5D
    JMP $&code_02EDB0

  loc_02EA5D:
    JSR $&code_02ED81
    BNE loc_02EA65
    JMP $&code_02E9C4

  loc_02EA65:
    LDA $20
    LSR 
    LSR 
    ORA #$00
    BEQ code_02EA85
    ADC $1A
    INC 
    ORA #$F0
    SBC $@090A0A, X
    SBC $181AFF, X
    ADC $20
    EOR #$FF
    SBC $@24851A, X
    JMP $&code_02E9CF
}

code_02EA85 {
    JSR $&code_02EEA5
    CMP #$0006
    BNE loc_02EA90
    JMP $&code_02E88B

  loc_02EA90:
    JMP $&code_02EDB0
}

code_02EA93 {
    JSR $&code_02ED3C
    JSR $&code_02EE0F
    LDA $1A
    CLC 
    ADC #$08
    BRK #$85
    INC 
    JSR $&code_02EEF1
    AND #$FF
    BRK #$C9
    ASL 
    BRK #$D0
    ORA $4C, S
    ROL $EB
    JSR $&code_02EF6D
    SEP #$20
    JSR $&code_02EF3E
    REP #$20
    AND #$00FF
    CMP #$000A
    BEQ code_02EB26
    JSR $&code_02EEA5
    LDA $1A
    CLC 
    ADC #$0008
    STA $1A
    JSR $&code_02EEF1
    AND #$00FF
    CMP #$000A
    BEQ loc_02EAEC
    JSR $&code_02EF55
    SEP #$20
    JSR $&code_02EF3E
    REP #$20
    AND #$00FF
    CMP #$000A
    BEQ loc_02EAEC
    JMP $&code_02EBDB

  loc_02EAEC:
    JSR $&code_02ED81
    BNE loc_02EAF4
    JMP $&code_02EDB0

  loc_02EAF4:
    LDA $20
    CLC 
    ADC $22
    LSR 
    LSR 
    AND #$000F
    EOR #$FFFF
    INC 
    CLC 
    ADC #$0010
    ASL 
    ASL 
    EOR #$FFFF
    INC 
    CLC 
    ADC $26
    STA $26
    CLC 
    ADC $20
    CLC 
    ADC $22
    LSR 
    LSR 
    LSR 
    BCC code_02EB2D
    LDA $26
    SEC 
    SBC #$0004
    STA $26
    BRA code_02EB2D

  code_02EB26:
    LDA $20
    CLC 
    ADC $26
    STA $26

  code_02EB2D:
    LDA #$1000
    TSB $slopeCurvePtrB
    SEP #$20
    JSR $&code_02EEA5
    CMP #$0E
    BCS loc_02EB49
    JSR $&code_02EEC7
    CMP #$0E
    BCS loc_02EB46
    JMP $&code_02EDB0

  loc_02EB46:
    JMP $&code_02EB8E

  loc_02EB49:
    JSR $&code_02EEC7
    CMP #$0E
    BCS loc_02EB53
    JMP $&code_02EB96

  loc_02EB53:
    REP #$20
    LDA $22
    PHA 
    CLC 
    ADC $20
    LSR 
    LSR 
    SEC 
    SBC #$0008
    BIT #$000F
    BEQ loc_02EB6D
    AND #$FFF0
    CLC 
    ADC #$0010

  loc_02EB6D:
    CLC 
    ADC #$0008
    ASL 
    ASL 
    STA $22
    SEC 
    SBC $01, S
    SEC 
    SBC $20
    CLC 
    ADC $26
    STA $26
    PLA 
    STZ $20
    STZ $24
    STZ $09C0
    JSR $&code_02ED9D
    JMP $&code_02EDB0
}

code_02EB8E {
    REP #$20
    JSR $&code_02E03F
    JMP $&code_02EDB0
}

code_02EB96 {
    REP #$20
    JSR $&code_02DD04
    JMP $&code_02EDB0
}

code_02EB9E {
    JSR $&code_02ED3C
    LDA $1A
    SEC 

  loc_02EBA4:
    SBC #$09
    BRK #$85
    INC 
    JSR $&code_02EEF1
    AND #$FF
    BRK #$C9
    ASL 
    BRK #$F0
    ORA $4C, S
    BCS loc_02EBA4
    JSR $&code_02ED81
    BNE loc_02EBBF
    JMP $&code_02EB26

  loc_02EBBF:
    LDA $20
    LSR 
    LSR 
    ORA #$00
    BEQ loc_02EBDF
    ADC $1A
    INC 
    ORA #$F0
    SBC $@090A0A, X
    SBC $181AFF, X
    ADC $20
    STA $24
    JMP $&code_02EB2D
}

code_02EBDB {
    JSR $&code_02EEC7
    CMP #$0009
    BNE loc_02EBE6
    JMP $&code_02E8DF

  loc_02EBE6:
    JMP $&code_02EDB0
}

code_02EBE9 {
    PHP 
    REP #$20
    LDA $06, S
    BNE loc_02EC35
    LDA $collisionLayer, X
    AND #$00FF
    BIT #$00F0
    BNE loc_02EC35
    LDA $26
    LSR 
    LSR 
    AND #$000F
    BEQ loc_02EC35
    STA $04
    CMP #$0004
    BCC loc_02EC1D
    JSR $&code_02EEC7
    CMP #$000E
    BCS loc_02EC1D
    LDX #$0026
    JSR $&code_02DF83
    PLP 
    CLC 
    RTS 

  loc_02EC1D:
    LDA $04
    CMP #$000B
    BCS loc_02EC35
    JSR $&code_02EEA5
    CMP #$000E
    BCS loc_02EC35
    LDX #$0026
    JSR $&code_02DF9C
    PLP 
    CLC 
    RTS 

  loc_02EC35:
    PLP 
    SEC 
    RTS 
}

code_02EC38 {
    REP #$20
    STZ $02
    LDA $1A
    PHA 
    LDA $1E
    PHA 
    SEP #$20
    JSR $&code_02EE33
    CMP #$09
    BEQ loc_02EC5A
    JSR $&code_02EFCB
    BCC loc_02EC86
    JSR $&code_02EF55
    JSR $&code_02EF3E
    CMP #$06
    BNE loc_02EC86

  loc_02EC5A:
    REP #$20
    PLA 
    STA $1E
    PLA 
    STA $1A
    STZ $02
    LDA $1A
    PHA 
    LDA $20
    BEQ loc_02EC70
    LSR 
    LSR 
    ORA #$0C00

  loc_02EC70:
    SEC 
    SBC $01, S
    EOR #$FFFF
    INC 
    EOR $01, S
    BIT #$0010
    BEQ loc_02EC83
    LDA #$0010
    STA $02

  loc_02EC83:
    PLA 
    BRA loc_02EC90

  loc_02EC86:
    REP #$20
    PLA 
    STA $1E
    PLA 
    STA $1A
    STZ $02

  loc_02EC90:
    LDA $1A
    AND #$000F
    ORA #$FFF0
    EOR #$FFFF
    INC 
    CLC 
    ADC $02
    STA $02
    RTS 
}

code_02ECA2 {
    LDA $26
    LSR 
    LSR 
    AND #$000F
    BNE loc_02ECAE
    LDA #$0010

  loc_02ECAE:
    CLC 
    ADC $02
    CMP #$0011
    BCS loc_02ECB9
    JMP $&code_02EDB0

  loc_02ECB9:
    AND #$000F
    STA $02
    LDA $03, S
    BEQ loc_02ECD8
    LDA $20
    BPL loc_02ECCA
    EOR #$FFFF
    INC 

  loc_02ECCA:
    CMP $03, S
    BEQ loc_02ECE5
    BPL loc_02ECD8
    STZ $20
    LDA #$0840
    TRB $AA
    RTS 

  loc_02ECD8:
    LDA $02
    ASL 
    ASL 
    EOR #$FFFF
    INC 
    STA $24
    JMP $&code_02EDB0

  loc_02ECE5:
    LDA #$0000
    STA $03, S
    STA $20
    RTS 
}

code_02ECED {
    LDA $26
    LSR 
    LSR 
    ORA #$FFF0
    EOR #$FFFF
    INC 
    BNE loc_02ECFD
    LDA #$0010

  loc_02ECFD:
    CLC 
    ADC $02
    CMP #$0011
    BCS loc_02ED08
    JMP $&code_02EDB0

  loc_02ED08:
    AND #$000F
    STA $02
    LDA $03, S
    BEQ loc_02ED2B
    LDA $20
    BPL loc_02ED19
    EOR #$FFFF
    INC 

  loc_02ED19:
    EOR #$FFFF
    INC 
    CMP $03, S
    BEQ loc_02ED34
    BMI loc_02ED2B
    STZ $20
    LDA #$0440
    TRB $AA
    RTS 

  loc_02ED2B:
    LDA $02
    ASL 
    ASL 
    STA $24
    JMP $&code_02EDB0

  loc_02ED34:
    LDA #$0000
    STA $03, S
    STA $20
    RTS 
}

code_02ED3C {
    REP #$20
    LDA #$0000
    STA $05, S
    RTS 
}

code_02ED44 {
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
    JSR $&code_02EEF1
    AND #$00FF
    CMP #$000E
    BCC loc_02ED6A
    PLP 

  loc_02ED68:
    SEC 
    RTS 

  loc_02ED6A:
    PLP 
    BEQ loc_02ED7F
    SEP #$20
    JSR $&code_02EF6D
    JSR $&code_02EF3E
    REP #$20
    AND #$00FF
    CMP #$000E
    BCS loc_02ED68

  loc_02ED7F:
    CLC 
    RTS 
}

code_02ED81 {
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

code_02ED96 {
    REP #$20
    STZ $24
    STZ $20
    RTS 
}

code_02ED9D {
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

code_02EDB0 {
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

code_02EDC5 {
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
    JSR $&code_02EEF1
    INC $1A
    INC $1E
    BCC loc_02EDE8
    PLP 
    SEC 
    RTS 

  loc_02EDE8:
    PLP 
    CLC 
    RTS 
}

code_02EDEB {
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
    JSR $&code_02EEF1
    INC $1A
    BCC loc_02EE0C
    PLP 
    SEC 
    RTS 

  loc_02EE0C:
    PLP 
    CLC 
    RTS 
}

code_02EE0F {
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
    JSR $&code_02EEF1
    INC $1E
    BCC loc_02EE30
    PLP 
    SEC 
    RTS 

  loc_02EE30:
    PLP 
    CLC 
    RTS 
}

code_02EE33 {
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
    JSR $&code_02EEF1
    RTS 
}

code_02EE4F {
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
    JSR $&code_02EEF1
    INC $1A
    BCC loc_02EE76
    PLP 
    SEC 
    RTS 

  loc_02EE76:
    PLP 
    CLC 
    RTS 
}

code_02EE79 {
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
    JSR $&code_02EEF1
    INC $1A
    INC $1E
    BCC loc_02EEA2
    PLP 
    SEC 
    RTS 

  loc_02EEA2:
    PLP 
    CLC 
    RTS 
}

code_02EEA5 {
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
    JSR $&code_02EEF1
    RTS 
}

code_02EEC7 {
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
    JSR $&code_02EEF1
    INC $1E
    BCC loc_02EEEE
    PLP 
    SEC 
    RTS 

  loc_02EEEE:
    PLP 
    CLC 
    RTS 
}

code_02EEF1 {
    PHP 
    REP #$20
    LDA $1A
    BMI loc_02EF32
    CMP $cameraOffsetX
    BCC loc_02EF32
    CMP $cameraBoundsX
    BCS loc_02EF32
    LSR 
    LSR 
    LSR 
    LSR 
    STA $18
    LDA $1E
    BMI loc_02EF32
    CMP $cameraOffsetY
    BCC loc_02EF32
    CMP $cameraLowerYBound
    BCS loc_02EF32
    LSR 
    LSR 
    LSR 
    LSR 
    STA $1C
    PHY 
    JSL $@chunk_3B7DD.code_03D493
    STY $00
    TYX 
    PLY 
    SEP #$20
    JSR $&code_02EF3E
    BNE loc_02EF2F
    PLP 
    CLC 
    RTS 

  loc_02EF2F:
    PLP 
    SEC 
    RTS 

  loc_02EF32:
    SEP #$20
    LDX #$4001
    STX $00
    LDA #$0F
    PLP 
    SEC 
    RTS 
}

code_02EF3E {
    CPX #$4000
    BCS loc_02EF52
    LDA $collisionLayer, X
    BIT #$F0
    BEQ loc_02EF4F
    LSR 
    LSR 
    LSR 
    LSR 

  loc_02EF4F:
    BIT #$FF
    RTS 

  loc_02EF52:
    LDA #$0F
    RTS 
}

code_02EF55 {
    PHP 
    REP #$20
    LDA $00
    SEP #$20
    CLC 
    ADC #$10
    BCS loc_02EF64
    TAX 
    PLP 
    RTS 

  loc_02EF64:
    XBA 
    CLC 
    ADC $mapRowStrideL0
    XBA 
    TAX 
    PLP 
    RTS 
}

code_02EF6D {
    PHP 
    REP #$20
    LDA $00
    SEP #$20
    SEC 
    SBC #$10
    BCC loc_02EF7C
    TAX 
    PLP 
    RTS 

  loc_02EF7C:
    XBA 
    SEC 
    SBC $mapRowStrideL0
    XBA 
    TAX 
    PLP 
    RTS 
}

code_02EF85 {
    PHP 
    REP #$20
    LDA $00
    SEP #$20
    INC 
    BIT #$0F
    BEQ loc_02EF94
    TAX 
    PLP 
    RTS 

  loc_02EF94:
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

code_02EF9F {
    PHP 
    REP #$20
    LDA $00
    SEP #$20
    DEC 
    PHA 
    AND #$0F
    CMP #$0F
    BEQ loc_02EFB2
    PLA 
    TAX 
    PLP 
    RTS 

  loc_02EFB2:
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

code_02EFBE {
    PHA 
    LDA $1A
    BIT #$0F
    BNE loc_02EFC8
    PLA 
    CLC 
    RTS 

  loc_02EFC8:
    PLA 
    SEC 
    RTS 
}

code_02EFCB {
    PHA 
    LDA $1E
    BIT #$0F
    BNE loc_02EFD5
    PLA 
    CLC 
    RTS 

  loc_02EFD5:
    PLA 
    SEC 
    RTS 
}

actor_def_02EFD8 [
  actor-def < #00, #00, #28, {

  code_02EFDB:
    COP [SetMetasprite] ( @sprite_set_list_108000 )
    COP [RunBg3Script] ( @01E4F5 )
    STZ $inventoryTabIndex
    LDA #$0F
    BRK #$85
    BIT $02
    STZ $&01F509
    BRL loc_0307F4

  loc_02EFF4:
    PHY 
    LDY $24
    LDA $inventorySlots, Y
    AND #$FF
    BRK #$7A
    STA $0028, Y
    DEC $24
    BPL loc_02EFED
    TYA 
    STA $orbitAngle, X
    COP [SpawnAfterFlags] ( @code_02F529, #$0802 )
    TYA 
    STA $orbitDiameter, X
    LDA $inventoryEquippedIndex
    STA $1A
    JSR $&code_02F6B5
    COP [SpawnAfterFlags] ( @code_02F541, #$0800 )
    TYA 
    STA $moveXAlt, X
    COP [SpawnAfterFlags] ( @code_02F595, #$0800 )
    COP [SpawnAfterFlags] ( @code_02F576, #$0800 )
    COP [SpawnAfterFlags] ( @code_02F557, #$0800 )
    TYA 
    STA $moveYAlt, X
    COP [SetEntryExit]
    STZ $inventoryTabIndex
    LDA #$00
    BPL loc_02F051
    BPL loc_02F051
    LDA $&01E594, X
    STA ($02, X)
    LDA $&01E574, X
    STA ($64, X)
    TRB $&01FFA9
    SBC $A91885, X
    BRK #$80
    TSB $joypadHeld
    COP [SetEntryExit]
    JSR $&code_02F89A
    BCS loc_02F087
    LDA $inventoryTabIndex
    CMP $18
    BNE loc_02F074
    RTL 

  loc_02F074:
    STA $18
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_02F07F )
} >
]

code_list_02F07F [
  &code_02F409   ;00
  &code_02F428   ;01
  &code_02F439   ;02
]

code_02F085 {
    CLI 
}

code_02F086 {
    PEA $0603
    ORA $&01FAAD
    ASL 
    STA $18
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_02F098 )
}

code_list_02F098 [
  &code_02F0A0   ;00
  &code_02F178   ;01
  &code_02F299   ;02
  &code_02F35B   ;03
]

code_02F0A0 {
    LDA #$04
    BRK #$8D
    INC $0A
    COP [RunBg3Script] ( @01E594 )
    COP [RunBg3Script] ( @01E6B5 )
    COP [RunBg3Script] ( @01E60D )
    STZ $inventoryEquippedIndex
    JSR $&code_02F739
    LDA $1A
    BPL code_02F0C1
    STZ $1A

  code_02F0C1:
    JSR $&code_02F6B5
    COP [RunBg3Script] ( @01E59B )
    LDY $1A
    LDA $inventorySlots, Y
    AND #$FF
    BRK #$8D
    INX 
    ASL 
    COP [RunBg3Script] ( @01E682 )
    COP [SetEntryExit]
    COP [BranchIfButton] ( #$C040, &code_02F14D )
    COP [BranchIfButton] ( #$0800, &code_02F0FA )
    COP [BranchIfButton] ( #$0400, &code_02F110 )
    COP [BranchIfButton] ( #$0200, &code_02F126 )
    COP [BranchIfButton] ( #$0100, &code_02F139 )
    RTL 
}

code_02F0FA {
    LDA #$00
    PHD 
    TSB $joypadHeld
    COP [PlaySoundCh2] ( #10 )
    LDA $1A
    SEC 
    SBC #$04
    BRK #$29
    ORA $@will_sprites_1A8000+500
    BRA code_02F0C1
}

code_02F110 {
    LDA #$00
    ORA [$0C]
    CLI 
    ASL $02
    ASL $10
    LDA $1A
    CLC 
    ADC #$04
    BRK #$29
    ORA $@will_sprites_1A8000+500
    BRA code_02F0C1
}

code_02F126 {
    LDA #$00
    COP [ClearLowHere]
    CLI 
    ASL $02
    ASL $10
    LDA $1A
    DEC 
    AND #$0F
    BRK #$85
    INC 
    BRA code_02F0C1
}

code_02F139 {
    LDA #$00
    ORA ($0C, X)
    CLI 
    ASL $02
    ASL $10
    LDA $1A
    INC 
    AND #$0F
    BRK #$85
    INC 
    JMP $&code_02F0C1
}

code_02F14D {
    LDA #$40
    CPY #$580C
    ASL $02
    ASL $11
    LDA $1A
    STA $inventoryEquippedIndex
    TAY 
    LDA $inventorySlots, Y
    AND #$FF
    BRK #$D0
    ASL $&01FFA9
    SBC $@chunk_0A8000.code_0AC487+6, X
    STA $1A
    STZ $inventoryEquippedType
    JMP $&code_02F04E
}

code_02F172 {
    STA $inventoryEquippedType
    JMP $&code_02F04E
}

code_02F178 {
    JSR $&code_02F74D
    COP [SpawnAfterFlags] ( @code_02F533, #$0802 )
    STY $20
    STZ $22

  code_02F186:
    STZ $1C
    COP [RunBg3Script] ( @01E594 )
    COP [RunBg3Script] ( @01E6C7 )
    COP [RunBg3Script] ( @01E62C )

  code_02F197:
    JSR $&code_02F67F
    COP [SetEntryExit]
    COP [BranchIfButton] ( #$4040, &code_02F28E )
    COP [BranchIfButton] ( #$8000, &code_02F1C5 )
    PEA $&code_02F197-1
    COP [BranchIfButton] ( #$0800, &code_02F5C3 )
    COP [BranchIfButton] ( #$0400, &code_02F5D8 )
    COP [BranchIfButton] ( #$0200, &code_02F5ED )
    COP [BranchIfButton] ( #$0100, &code_02F5FF )
    PLA 
    RTL 
}

code_02F1C5 {
    COP [PlaySoundCh2] ( #11 )
    LDA #$8000
    TSB $joypadHeld
    LDA $20
    STA $2C
    LDA $22
    STA $2E
    COP [SpawnAfterFlags] ( @code_02F533, #$0802 )
    STY $20
    COP [RunBg3Script] ( @01E594 )
    COP [RunBg3Script] ( @01E6C7 )
    COP [RunBg3Script] ( @01E656 )

  code_02F1EE:
    JSR $&code_02F67F
    COP [SetEntryExit]
    COP [BranchIfButton] ( #$4040, &code_02F28C )
    COP [BranchIfButton] ( #$8000, &code_02F21C )
    PEA $&code_02F1EE-1
    COP [BranchIfButton] ( #$0800, &code_02F5C3 )
    COP [BranchIfButton] ( #$0400, &code_02F5D8 )
    COP [BranchIfButton] ( #$0200, &code_02F5ED )
    COP [BranchIfButton] ( #$0100, &code_02F5FF )
    PLA 
    RTL 
}

code_02F21C {
    LDA #$8000
    TSB $joypadHeld
    LDA $22
    CMP $2E
    BEQ code_02F1EE
    COP [PlaySoundCh2] ( #11 )
    LDY $22
    SEP #$20
    LDA $inventorySlots, Y
    XBA 
    LDY $2E
    LDA $inventorySlots, Y
    XBA 
    STA $inventorySlots, Y
    XBA 
    LDY $22
    STA $inventorySlots, Y
    REP #$20
    LDY $2E
    LDA $inventorySlots, Y
    AND #$00FF
    PHA 
    TYA 
    JSR $&code_02F62F
    PLA 
    STA $0028, Y
    LDY $22
    LDA $inventorySlots, Y
    AND #$00FF
    PHA 
    TYA 
    JSR $&code_02F62F
    PLA 
    STA $0028, Y
    TYA 
    CMP $inventoryEquippedIndex
    BNE loc_02F273
    LDA $2E
    STA $inventoryEquippedIndex
    BRA loc_02F27F

  loc_02F273:
    LDA $2E
    CMP $inventoryEquippedIndex
    BNE loc_02F27F
    LDA $22
    STA $inventoryEquippedIndex

  loc_02F27F:
    PHX 
    PHD 
    LDA $2C
    TAX 
    TCD 
    COP [MarkDeath]
    PLD 
    PLX 
    JMP $&code_02F186
}

code_02F28C {
    COP [KillNext]
}

code_02F28E {
    COP [KillNext]
    LDA #$4040
    TSB $joypadHeld
    JMP $&code_02F04E
}

code_02F299 {
    LDA #$0004
    STA $bg1ConfigMode
    JSR $&code_02F74D
    COP [SpawnAfterFlags] ( @code_02F533, #$0802 )
    STY $20
    STZ $22

  code_02F2AD:
    STZ $1C
    COP [RunBg3Script] ( @01E594 )
    COP [RunBg3Script] ( @01E6D8 )
    COP [RunBg3Script] ( @01E66C )

  code_02F2BE:
    JSR $&code_02F67F
    COP [SetEntryExit]
    COP [BranchIfButton] ( #$4040, &code_02F34D )
    COP [BranchIfButton] ( #$8000, &code_02F2EC )
    PEA $&code_02F2BE-1
    COP [BranchIfButton] ( #$0800, &code_02F5C3 )
    COP [BranchIfButton] ( #$0400, &code_02F5D8 )
    COP [BranchIfButton] ( #$0200, &code_02F5ED )
    COP [BranchIfButton] ( #$0100, &code_02F5FF )
    PLA 
    RTL 
}

code_02F2EC {
    LDA #$8000
    TSB $joypadHeld
    LDY $22
    LDA $inventorySlots, Y
    AND #$00FF
    BEQ loc_02F347
    STA $itemAbilityIndex
    JSR $&code_02F655
    BCS loc_02F347
    COP [RunBg3Script] ( @01E59B )
    COP [RunBg3Script] ( @01E694 )
    STZ $28
    COP [SetEntryExit]
    JSR $&code_02F808
    BCS loc_02F318
    RTL 

  loc_02F318:
    LDA $28
    BEQ loc_02F344
    LDY $22
    LDA $inventorySlots, Y
    AND #$FF00
    STA $inventorySlots, Y
    LDA $22
    JSR $&code_02F62F
    LDA $22
    CMP $inventoryEquippedIndex
    BNE loc_02F33E
    STZ $inventoryEquippedType
    LDA #$FFFF
    STA $inventoryEquippedIndex
    STA $1A

  loc_02F33E:
    COP [PlaySoundCh2] ( #13 )
    JMP $&code_02F2AD

  loc_02F344:
    JMP $&code_02F2AD

  loc_02F347:
    COP [PlaySoundCh2] ( #12 )
    JMP $&code_02F2AD
}

code_02F34D {
    LDA #$4040
    TSB $joypadHeld
    COP [KillNext]
    JSR $&code_02F739
    JMP $&code_02F04E
}

code_02F35B {
    LDA #$0000
    STA $bg1ConfigMode
    COP [RunBg3Script] ( @01E594 )
    COP [RunBg3Script] ( @01E6E7 )
    COP [SpawnAfterFlags] ( @code_02F533, #$0802 )
    STY $20
    STZ $22

  loc_02F376:
    JSR $&code_02F3E5
    COP [RunBg3Script] ( @01E59B )
    LDA $characterForm
    STA $0004
    LDA $22
    JSR $&code_02F61E
    BCC loc_02F395
    LDA $22
    JSR $&code_02F5B4
    COP [RunBg3Script] ( @01E758 )

  loc_02F395:
    COP [SetEntryExit]
    COP [BranchIfButton] ( #$0800, &code_02F3AA )
    COP [BranchIfButton] ( #$0400, &code_02F3BF )
    COP [BranchIfButton] ( #$C040, &code_02F3D7 )
    RTL 
}

code_02F3AA {
    LDA #$0800
    TSB $joypadHeld
    COP [PlaySoundCh2] ( #10 )
    LDA $22
    DEC 
    BPL loc_02F3BB
    LDA #$0002

  loc_02F3BB:
    STA $22
    BRA loc_02F376
}

code_02F3BF {
    LDA #$0400
    TSB $joypadHeld
    COP [PlaySoundCh2] ( #10 )
    LDA $22
    INC 
    CMP #$0003
    BCC loc_02F3D3
    LDA #$0000

  loc_02F3D3:
    STA $22
    BRA loc_02F376
}

code_02F3D7 {
    COP [PlaySoundCh2] ( #11 )
    LDA #$C040
    TSB $joypadHeld
    COP [KillNext]
    JMP $&code_02F04E
}

code_02F3E5 {
    PHX 
    LDY $20
    LDA $22
    ASL 
    ASL 
    TAX 
    LDA $@code_02F3FD, X
    STA $0014, Y
    LDA $@code_02F3FD+2, X
    STA $0016, Y
    PLX 
    RTS 
}

code_02F3FD {
    TYA 
    BRK #$48
    BRK #$98
    BRK #$60
    BRK #$98
    BRK #$78
    BRK #$20
    JML $3920F7
    SBC [$20], Y
    COP #$F7
    COP [RunBg3Script] ( @01E56D )
    COP [RunBg3Script] ( @01E59B )
    COP [RunBg3Script] ( @01E5A2 )
    LDA #$0004
    STA $bg1ConfigMode
    RTL 
}

code_02F428 {
    JSR $&code_02F75C
    JSR $&code_02F739
    COP [RunBg3Script] ( @01E59B )
    COP [RunBg3Script] ( @01E5E7 )
    RTL 
}

code_02F439 {
    JSR $&code_02F75C
    JSR $&code_02F739
    JSR $&code_02F702
    COP [RunBg3Script] ( @01E59B )
    COP [RunBg3Script] ( @01E56D )
    COP [RunBg3Script] ( @01E5FC )
    LDA #$0004
    STA $bg1ConfigMode
    RTL 
}

code_02F458 {
    JSR $&code_02F787
    JSR $&code_02F74D
    COP [RunBg3Script] ( @01E59B )
    COP [RunBg3Script] ( @01E4FC )
    COP [RunBg3Script] ( @01E71F )
    LDA #$0000
    STA $bg1ConfigMode
    LDA $moveXAlt, X
    TAY 
    LDA $inventoryEquippedIndex
    BMI loc_02F48C
    LDA $inventoryEquippedType
    JSR $&code_02F611
    LDA $0010, Y
    AND #$DFFF
    STA $0010, Y

  loc_02F48C:
    LDA $moveYAlt, X
    STA $0002
    LDA $characterForm
    STA $0004
    LDA #$0000
    JSR $&code_02F61E
    BCC loc_02F4B8
    LDY $0002
    LDA $0010, Y
    AND #$DFFF
    STA $0010, Y
    LDA #$0000
    JSR $&code_02F5B4
    COP [RunBg3Script] ( @01E6F8 )

  loc_02F4B8:
    LDY $0002
    LDA $0006, Y
    STA $0002
    LDA #$0001
    JSR $&code_02F61E
    BCC loc_02F4E0
    LDY $0002
    LDA $0010, Y
    AND #$DFFF
    STA $0010, Y
    LDA #$0001
    JSR $&code_02F5B4
    COP [RunBg3Script] ( @01E705 )

  loc_02F4E0:
    LDY $0002
    LDA $0006, Y
    STA $0002
    LDA #$0002
    JSR $&code_02F61E
    BCC loc_02F508
    LDY $0002
    LDA $0010, Y
    AND #$DFFF
    STA $0010, Y
    LDA #$0002
    JSR $&code_02F5B4
    COP [RunBg3Script] ( @01E712 )

  loc_02F508:
    RTL 
}

code_02F509 {
    INC $inventoryTabIndex
    JSR $&code_02F7B2
    COP [SetEntryContinue]
    LDA $28
    BNE loc_02F51B
    LDA #$2000
    TSB $10
    RTL 

  loc_02F51B:
    LDA #$2000
    TRB $10

  loc_02F520:
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_02F520
    RTL 
}

code_02F529 {
    LDA $inventoryEquippedIndex
    BPL code_02F533
    LDA #$2000
    TSB $10
}

code_02F533 {
    COP [StageSprAndHitbox] ( #40 )
    COP [SetEntryExit]

  loc_02F538:
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_02F538
    RTL 
}

code_02F541 {
    LDA #$0028
    STA $14
    LDA #$0078
    STA $16
    LDA $inventoryEquippedType
    STA $28
    STZ $2A
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    RTL 
}

code_02F557 {
    LDA #$0098
    STA $14
    LDA #$0048
    STA $16
    LDA $characterForm
    ASL 
    CLC 
    ADC $characterForm
    CLC 
    ADC #$0044
    STA $28
    STZ $2A
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    RTL 
}

code_02F576 {
    LDA #$0098
    STA $14
    LDA #$0060
    STA $16
    LDA $characterForm
    ASL 
    CLC 
    ADC $characterForm
    CLC 
    ADC #$0045
    STA $28
    STZ $2A
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    RTL 
}

code_02F595 {
    LDA #$0098
    STA $14
    LDA #$0078
    STA $16
    LDA $characterForm
    ASL 
    CLC 
    ADC $characterForm
    CLC 
    ADC #$0046
    STA $28
    STZ $2A
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    RTL 
}

code_02F5B4 {
    PHA 
    LDA $characterForm
    ASL 
    ASL 
    CLC 
    ADC $01, S
    INC 
    STA $itemAbilityIndex
    PLA 
    RTS 
}

code_02F5C3 {
    LDA #$0B00
    TSB $joypadHeld
    COP [PlaySoundCh2] ( #10 )
    LDA $22
    SEC 
    SBC #$0004
    AND #$000F
    STA $22
    RTS 
}

code_02F5D8 {
    LDA #$0700
    TSB $joypadHeld
    COP [PlaySoundCh2] ( #10 )
    LDA $22
    CLC 
    ADC #$0004
    AND #$000F
    STA $22
    RTS 
}

code_02F5ED {
    LDA #$0200
    TSB $joypadHeld
    COP [PlaySoundCh2] ( #10 )
    LDA $22
    DEC 
    AND #$000F
    STA $22
    RTS 
}

code_02F5FF {
    LDA #$0100
    TSB $joypadHeld
    COP [PlaySoundCh2] ( #10 )
    LDA $22
    INC 
    AND #$000F
    STA $22
    RTS 
}

code_02F611 {
    STA $0028, Y
    LDA #$0000
    STA $002A, Y
    STA $0008, Y
    RTS 
}

code_02F61E {
    PHA 
    LDA $0004
    ASL 
    ASL 
    CLC 

  loc_02F625:
    ADC $01, S
    STA $01, S
    PLA 
    JSL $@chunk_008000.code_00B55A
    RTS 
}

code_02F62F {
    STA $000E
    LDA $orbitAngle, X
    TAY 

  loc_02F637:
    DEC $000E
    BMI loc_02F642
    LDA $0006, Y
    TAY 
    BRA loc_02F637

  loc_02F642:
    LDA #$F50F
    STA $0000, Y
    LDA #$0000
    STA $0028, Y
    STA $0008, Y
    STA $002A, Y
    RTS 
}

code_02F655 {
    PHX 
    STA $0000
    LSR 
    LSR 
    LSR 
    TAY 
    LDA #$0000
    SEP #$20
    LDA $0000
    AND #$07
    TAX 
    LDA $@code_02F677, X
    AND $&20DD49, Y
    SEC 
    BNE loc_02F673
    CLC 

  loc_02F673:
    REP #$20
    PLX 
    RTS 
}

code_02F677 {
    ORA ($02, X)
    TSB $08
    BPL loc_02F69D
    RTI 
    BRA loc_02F625

  loc_02F680:
    JSL $00008D
    LDY $20
    BRA loc_02F68F

  loc_02F688:
    LDA $2E
    STA $0000
    LDY $2C

  loc_02F68F:
    PHX 
    LDA $0000
    ASL 
    ASL 
    PHA 
    AND #$000C
    TAX 
    LDA #$0030

  loc_02F69D:
    AND $01, S
    STA $01, S
    LDA $@loc_02F6E3+F, X
    STA $0014, Y
    LDA $@loc_02F6E3+11, X
    CLC 
    ADC $01, S
    STA $0016, Y
    PLA 
    PLX 
    RTS 
}

code_02F6B5 {
    LDA $1A
    BMI loc_02F6E3
    PHX 
    LDA $orbitDiameter, X
    TAY 
    LDA $1A
    ASL 
    ASL 
    PHA 
    AND #$0C
    BRK #$AA
    LDA #$30
    BRK #$23
    ORA ($83, X)
    ORA ($BF, X)
    SBC ($F6)
    BRL loc_030B6E

  loc_02F6D5:
    BRK #$BF
    PEA $&code_0282F7-1
    CLC 
    ADC $01, S
    STA $0016, Y
    PLA 
    PLX 
    RTS 

  loc_02F6E3:
    LDA $orbitDiameter, X
    TAY 
    LDA $0010, Y
    ORA #$00
    JSR $1099
    BRK #$60
    JML $003000
    STZ $00, X
    BMI loc_02F6FA

  loc_02F6FA:
    STY $3000
    BRK #$A4
    BRK #$30
    BRK #$BF
    CLC 
    BRK #$7F
    TAY 
    LDA $0010, Y
    ORA #$00
    JSR $1099
    BRK #$BF
    INC 
    BRK #$7F
    TAY 
    LDA $0010, Y
    ORA #$00
    JSR $1099
    BRK #$B9
    ASL $00
    TAY 
    LDA $0010, Y
    ORA #$00
    JSR $1099
    BRK #$B9
    ASL $00
    TAY 
    LDA $0010, Y
    ORA #$00
    JSR $1099
    BRK #$60
}

code_02F739 {
    LDA $inventoryEquippedIndex
    BMI code_02F74D
    LDA $orbitDiameter, X
    TAY 
    LDA $0010, Y
    AND #$FF
    CMP $001099, X
    RTS 
}

code_02F74D {
    LDA $orbitDiameter, X
    TAY 
    LDA $0010, Y
    ORA #$00
    JSR $1099
    BRK #$60
}

code_02F75C {
    LDA $10
    BIT #$1000
    BEQ loc_02F764
    RTS 

  loc_02F764:
    LDA #$1000
    TSB $10
    LDA #$000F
    STA $0000
    LDA $orbitAngle, X
    TAY 

  loc_02F774:
    LDA $0010, Y
    AND #$DFFF
    STA $0010, Y
    LDA $0006, Y
    TAY 
    DEC $0000
    BPL loc_02F774
    RTS 
}

code_02F787 {
    LDA $10
    BIT #$1000
    BNE loc_02F78F
    RTS 

  loc_02F78F:
    LDA #$1000
    TRB $10
    LDA #$000F
    STA $0000
    LDA $orbitAngle, X
    TAY 

  loc_02F79F:
    LDA $0010, Y
    ORA #$2000
    STA $0010, Y
    LDA $0006, Y
    TAY 
    DEC $0000
    BPL loc_02F79F
    RTS 
}

code_02F7B2 {
    PHX 
    LDA $inventoryTabIndex
    DEC 
    ASL 
    ASL 
    TAX 
    LDA $@code_02F7C8, X
    STA $14
    LDA $@code_02F7C8+2, X
    STA $16
    PLX 
    RTS 
}

code_02F7C8 {
    JML $003100
    STZ $00, X
    AND ($00), Y
    STY $3100
    BRK #$A4
    BRK #$31
    BRK #$5C
    BRK #$41
    BRK #$74
    BRK #$41
    BRK #$8C
    BRK #$41
    BRK #$A4
    BRK #$41
    BRK #$5C
    BRK #$51
    BRK #$74
    BRK #$51
    BRK #$8C
    BRK #$51
    BRK #$A4
    BRK #$51
    BRK #$5C
    BRK #$61
    BRK #$74
    BRK #$61
    BRK #$8C
    BRK #$61
    BRK #$A4
    BRK #$61
    BRK #$02
    RTI 
    BRK #$80
    STZ $F8
    COP [BranchIfButton] ( #$0800, &code_02F834 )
    COP [BranchIfButton] ( #$0400, &code_02F84C )
    LDA $1C
    INC $1C
    BIT #$000F
    BEQ loc_02F825
    CLC 
    RTS 

  loc_02F825:
    BIT #$0010
    BNE loc_02F82F
    JSR $&code_02F86F
    CLC 
    RTS 

  loc_02F82F:
    JSR $&code_02F888
    CLC 
    RTS 
}

code_02F834 {
    COP [PlaySoundCh2] ( #10 )
    LDA #$0800
    TSB $joypadHeld
    LDA $28
    DEC 
    AND #$0001
    STA $28
    STZ $1C
    JSR $&code_02F86F
    CLC 
    RTS 
}

code_02F84C {
    COP [PlaySoundCh2] ( #10 )
    LDA #$0400
    TSB $joypadHeld
    LDA $28
    INC 
    AND #$0001
    STA $28
    STZ $1C
    JSR $&code_02F86F
    CLC 
    RTS 
}

code_02F864 {
    LDA #$8000
    TSB $joypadHeld
    JSR $&code_02F86F
    SEC 
    RTS 
}

code_02F86F {
    JSR $&code_02F888
    PHX 
    LDA $28
    AND #$00FF
    XBA 
    LSR 
    CLC 
    ADC #$0616
    TAX 
    LDA #$202B
    STA $7F0200, X
    PLX 
    RTS 
}

code_02F888 {
    LDA #$0001
    TSB $09FA
    LDA #$2020
    STA $7F0816
    STA $7F0896
    RTS 
}

code_02F89A {
    COP [BranchIfButton] ( #$8000, &code_02F905 )
    COP [BranchIfButton] ( #$0800, &code_02F8CC )
    COP [BranchIfButton] ( #$0400, &code_02F8E6 )
    COP [BranchIfButton] ( #$6040, &code_02F900 )
    LDA $1C
    INC $1C
    BIT #$0F
    BRK #$F0
    COP [BranchIfSolidEast] ( &code_028960 )
    BPL loc_02F8C0

  loc_02F8C0:
    BNE loc_02F8C7
    JSR $&code_02F910
    CLC 
    RTS 

  loc_02F8C7:
    JSR $&code_02F92A
    CLC 
    RTS 
}

code_02F8CC {
    COP [PlaySoundCh2] ( #10 )
    LDA #$00
    PHP 
    TSB $joypadHeld
    STZ $1C
    LDA $inventoryTabIndex
    DEC 
    AND #$03
    BRK #$8D
    PLX 
    ASL 
    JSR $&code_02F910
    CLC 
    RTS 
}

code_02F8E6 {
    COP [PlaySoundCh2] ( #10 )
    LDA #$00
    TSB $0C
    CLI 
    ASL $64
    TRB $&01FAAD
    ASL 
    INC 
    AND #$03
    BRK #$8D
    PLX 
    ASL 
    JSR $&code_02F910
    CLC 
    RTS 
}

code_02F900 {
    COP [SetFlagByte] ( #00 )
    CLC 
    RTS 
}

code_02F905 {
    LDA #$00

  loc_02F907:
    BRA loc_02F915

  loc_02F909:
    CLI 
    ASL $20
    BPL loc_02F907
    SEC 
    RTS 
}

code_02F910 {
    JSR $&code_02F92A
    PHX 
    LDA $inventoryTabIndex
    AND #$FF
    BRK #$EB
    LSR 
    CLC 
    ADC #$86
    ORA $AA
    LDA #$2B
    JSR $009F
    COP #$7F
    PLX 
    RTS 
}

code_02F92A {
    LDA #$01
    BRK #$0C
    PLX 
    ORA #$A9
    JSR $&code_028F20
    STX $07
    ADC $08068F, X
    ADC $@chunk_088000.code_088663+2C, X
    ADC $09068F, X
    ADC $@220860, X
    JSR $&code_02C722
    BRL loc_031BCE

  loc_02F94C:
    SBC ($82, X)
    BRL loc_0305ED

  loc_02F951:
    WDM 
    JSR $&code_02FB59
    REP #$20
    LDA #$0F00
    STA $joypadMaskInv
    LDA $effectDeltaX
    PHA 
    STZ $effectDeltaX
    LDA $09FA
    PHA 
    LDA #$4000
    STA $09FA
    LDA $eventFlags
    PHA 
    STZ $eventFlags
    LDA $sceneCurrent
    AND #$00FF
    PHA 
    LDA #$00FF
    STA $sceneCurrent
    ASL 
    STA $0646
    SEP #$20
    LDA $0A1F
    AND #$7F
    STA $0A1F
    STZ $W12SEL
    STZ $W34SEL
    STZ $WOBJSEL
    STZ $WBGLOG
    STZ $WOBJLOG
    STZ $WH0
    STZ $WH2
    STZ $WH3
    LDA #$FF
    STA $WH1
    LDA #$78
    STA $BG3SC
    STZ $BG3HOFS
    STZ $BG3HOFS
    STZ $BG3VOFS
    STZ $BG3VOFS
    JSL $@code_028505
    LDA #$0C
    STA $BG2SC
    LDA #$04
    STA $BG1SC
    STA $bg1ConfigMode
    JSL $@chunk_3B7DD.code_03DCA7
    LDA #$1B
    STA $7F0A04
    LDA #$5B
    STA $7F0A05
    JSL $@code_029E70
    LDX #$0000
    STX $0673
    STX $0676
    LDX #$0000
    STX $cameraTargetX
    STX $cameraTargetY
    STX $cameraDeltaX
    STX $cameraDeltaY
    STX $bg1ScrollH
    STX $bg2ScrollH
    STX $bg1ScrollV
    STX $savedCameraDelta
    STX $scrollOverrideH
    STX $forcedScrollOverride
    STX $scrollOverrideV
    STX $06CC
    STX $00B2
    JSL $@code_02FCA6
    JSL $@chunk_3B7DD.code_03CAE8
    JSL $@chunk_3B7DD.code_03CBAD
    JSL $@chunk_3B7DD.code_03D4F0
    JSL $@chunk_3B7DD.code_03D573
    JSL $@chunk_3B7DD.code_03C801
    JSL $@chunk_3B7DD.code_03C801
    JSL $@chunk_3B7DD.code_03C308
    LDA #$FF
    STA $oamComposeBuffer
    STA $7F3101
    JSL $@chunk_3B7DD.code_03C41D
    JSL $@chunk_008000.code_008122
    JSL $@code_0282B6
    JSL $@code_028168
    LDA #$0F
    STA $INIDISP
    JSL $@code_0282C7

  code_02FA59:
    JSL $@chunk_008000.code_008122
    LDA $bg1ConfigMode
    STA $BG1SC
    COP [BranchIfFlagByte] ( #00, #00, &code_02FA59 )
    STZ $BG3VOFS
    STZ $BG3VOFS
    JSL $@code_0282C7
    JSL $@code_0282E1
    STZ $HDMAEN
    JSR $&code_02FBE8
    LDX $cameraTargetX
    STX $bg1ScrollH
    LDX $cameraTargetY
    STX $bg2ScrollH
    LDX $cameraDeltaX
    STX $bg1ScrollV
    LDX $cameraDeltaY
    STX $savedCameraDelta
    REP #$20
    PLA 
    STA $sceneCurrent
    ASL 
    STA $0646
    PLA 
    STA $eventFlags
    PLA 
    STA $09FA
    PLA 
    STA $effectDeltaX
    SEP #$20
    JSL $@code_028505
    JSL $@code_02A219
    JSL $@code_02A620
    JSR $&code_02FC65
    JSL $@chunk_3B7DD.code_03DCA7
    JSL $@chunk_3B7DD.code_03DCE9
    JSR $&code_02FB08
    JSL $@chunk_3B7DD.code_03D573
    JSL $@code_02FCA6
    LDA #$41
    TSB $09FA
    JSL $@chunk_3B7DD.code_03DBD4
    LDX #$0000
    STX $09DA
    STX $09DC
    STX $cachedPrevHp
    STX $cachedPrevMaxHp
    STX $joypadMaskInv
    COP [RunBg3Script] ( @01E4A4 )
    JSR $&code_02FB47
    JSL $@chunk_3B7DD.code_03DE2F
    JSL $@chunk_008000.code_008181
    COP [SetFlagByte] ( #FF )
    JSL $@chunk_008000.code_008181
    LDA #$0F
    STA $INIDISP
    PLP 
    RTL 
}

code_02FB08 {
    LDA $00EA
    BNE loc_02FB0E
    RTS 

  loc_02FB0E:
    DEC 
    BNE loc_02FB2C
    LDX #$4400
    STX $VMADDL
    LDX #$C000
    LDA #$9C
    LDY #$0480
    JSL $@code_0284C7
    COP [CopyPalette] ( @fx_palette_198070, #00, #A0, #10 )
    RTS 

  loc_02FB2C:
    LDX #$4400
    STX $VMADDL
    LDX #$C480
    LDA #$9C
    LDY #$0600
    JSL $@code_0284C7
    COP [CopyPalette] ( @fx_palette_198090, #00, #A9, #07 )
    RTS 
}

code_02FB47 {
    PHP 
    PHD 
    REP #$20
    LDA $5A
    BEQ loc_02FB56

  loc_02FB4F:
    TCD 
    STZ $08
    LDA $06
    BNE loc_02FB4F

  loc_02FB56:
    PLD 
    PLP 
    RTS 
}

code_02FB59 {
    PHP 
    PHB 
    REP #$20
    LDA $joypadCurrent
    STZ $joypadCurrent
    STA $7E38AC
    LDA $joypadHeld
    STA $7E38AE
    LDA $joypadMaskStd
    STZ $joypadMaskStd
    STA $7E38B0
    LDX #$0000

  loc_02FB7B:
    LDA $004E, X
    STA $7E389C, X
    INX 
    INX 
    CPX #$0010
    BNE loc_02FB7B
    LDX #$0000

  loc_02FB8C:
    LDA $cameraTargetX, X
    STA $7E3890, X
    INX 
    INX 
    CPX #$000C
    BNE loc_02FB8C
    LDX #$0E00
    LDY #$3490
    LDA #$00FF
    MVN #$7E, #$00
    LDX #$3000
    LDA #$00FF
    MVN #$7E, #$7E
    LDX #$1000
    LDY #$E000
    LDA #$0FFF
    MVN #$7F, #$00
    LDX #$1000
    LDA #$0FFF
    MVN #$7F, #$7F
    LDX #$0F00
    LDY #$3690
    LDA #$00FF
    MVN #$7E, #$00
    LDX #$0F00
    LDA #$00FF
    MVN #$7E, #$7F
    LDX #$0A00
    LDY #$38B4
    LDA #$0202
    MVN #$7E, #$7F
    PLB 
    PLP 
    RTS 
}

code_02FBE8 {
    PHP 
    PHB 
    REP #$20
    LDA $7E38AC
    STA $joypadCurrent
    LDA $7E38AE
    STA $joypadHeld
    LDA $7E38B0
    STA $joypadMaskStd
    LDX #$0000

  loc_02FC04:
    LDA $7E389C, X
    STA $004E, X
    INX 
    INX 
    CPX #$0010
    BNE loc_02FC04
    LDX #$0000

  loc_02FC15:
    LDA $7E3890, X
    STA $cameraTargetX, X
    INX 
    INX 
    CPX #$000C
    BNE loc_02FC15
    LDX #$3490
    LDY #$0E00
    LDA #$00FF
    MVN #$00, #$7E
    LDY #$3000
    LDA #$00FF
    MVN #$7E, #$7E
    LDX #$E000
    LDY #$1000
    LDA #$0FFF
    MVN #$00, #$7F
    LDY #$1000
    LDA #$0FFF
    MVN #$7F, #$7F
    LDX #$3690
    LDY #$0F00
    LDA #$00FF
    MVN #$00, #$7E
    LDY #$0F00
    LDA #$00FF
    MVN #$7F, #$7E
    PLB 
    PLP 
    RTS 
}

code_02FC65 {
    PHP 
    PHB 
    REP #$20
    LDX #$38B4
    LDY #$0A00
    LDA #$0202
    MVN #$7F, #$7E
    PLB 
    PLP 
    RTS 
}

code_02FC78 {
    PHP 
    PHB 
    REP #$20
    LDA $joypadMaskStd
    STZ $joypadMaskStd
    PHA 
    SEP #$20
    LDA #$81
    PHA 
    PLB 
    JSL $@chunk_008000.code_008181
    REP #$20
    JSL $@code_02B05F
    PLA 
    STA $joypadMaskStd
    PLB 
    PLP 
    RTL 
}

code_02FC9A {
    PHX 
    PHP 
    REP #$20
    LDA #$0000
    LDX #$0140
    BRA loc_02FCAE
}

code_02FCA6 {
    PHX 
    PHP 
    REP #$20
    LDA #$0000
    TAX 

  loc_02FCAE:
    STA $7F0200, X
    INX 
    INX 
    CPX #$0800
    BNE loc_02FCAE
    PLP 
    PLX 
    RTL 
}

code_02FCBC {
    LDX #$FFFF
    STX $00
    LDA #$80
    STA $VMAIN
    LDX #$6800
    STX $VMADDL
    LDA #$09
    STA $DMAP0
    LDA #$18
    STA $BBAD0
    LDX #$0000
    STX $A1T0L
    LDA #$00
    STA $A1B0
    LDX #$1E00
    STX $DAS0L
    LDA #$01
    STA $MDMAEN
    RTL 
}