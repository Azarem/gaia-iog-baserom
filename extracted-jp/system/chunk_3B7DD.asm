?BANK 03

?INCLUDE 'binary_01C36C'
?INCLUDE 'binary_01D8E7'
?INCLUDE 'body_table'
?INCLUDE 'chunk_008000'
?INCLUDE 'chunk_028000'
?INCLUDE 'dir_sprite_table'
?INCLUDE 'overworld_routes'
?INCLUDE 'palette_bundles'
?INCLUDE 'parallax_table'
?INCLUDE 'scene_actors'
?INCLUDE 'scene_thinkers'
?INCLUDE 'string_templates'

!deathFlag                      0200
!extVelocityX                   0408
!extVelocityY                   040A
!invincibilityTimer             040C
!sceneNext                      0642
!sceneCurrent                   0644
!gfxCacheIdxA                   0648
!gfxCacheIdxB                   064A
!worldReadyFlag                 0654
!joypadCurrent                  0656
!joypadMaskStd                  065A
!joypadMaskInv                  065C
!joypadRaw                      0660
!bg1ScrollH                     068A
!bg1ScrollV                     068C
!bg2ScrollH                     068E
!savedCameraDelta               0690
!mapBoundsX                     0692
!mapRowStrideL0                 0693
!mapBoundsY                     0696
!cameraTargetX                  06BE
!cameraDeltaX                   06C0
!cameraTargetY                  06C2
!cameraDeltaY                   06C4
!scrollOverrideH                06C6
!forcedScrollOverride           06C8
!scrollOverrideV                06CA
!cameraOffsetX                  06D6
!cameraOffsetY                  06D8
!cameraBoundsX                  06DA
!cameraBoundsY                  06DC
!cameraLowerYBound              06DE
!effectDeltaX                   06E4
!effectDeltaY                   06E6
!layerPriorityFlag              06EE
!scrollModeFlags                06EF
!musicRoomGroup                 06F6
!sfxQueueCh1                    06F8
!musicTransitionState           06FA
!dmaSkipFlag                    0800
!joypadInject                   09AC
!playerFlags                    09AE
!playerWallType                 09B0
!playerSpeedEw                  09B2
!playerSpeedNs                  09B4
!slopeStepCounter               09B6
!decelStepCounter               09B8
!slopeCurvePtrA                 09BA
!slopeCurvePtrB                 09BC
!decelCurvePtr                  09C2
!playerActorDp                  09F4
!eventFlags                     0A00
!wramFlags                      0A80
!inventorySlots                 0AB4
!inventoryEquippedIndex         0AC4
!inventoryEquippedType          0AC6
!playerMaxHp                    0ACA
!cachedPrevMaxHp                0ACC
!playerHp                       0ACE
!cachedPrevHp                   0AD0
!characterForm                  0AD4
!gemCount                       0AD6
!playerDef                      0ADC
!playerStr                      0ADE
!enemyHealthTimer               0AE4
!damageFlashTimer               0B22
!INIDISP                        2100
!MOSAIC                         2106
!BG3SC                          2109
!BG12NBA                        210B
!BG3HOFS                        2111
!BG3VOFS                        2112
!VMAIN                          2115
!VMADDL                         2116
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
!MDMAEN                         420B
!HDMAEN                         420C
!RDMPYL                         4216
!RDMPYH                         4217
!DMAP0                          4300
!BBAD0                          4301
!A1T0L                          4302
!A1B0                           4304
!DAS0L                          4305
!DASB0                          4307
!thinkerPoolAddrs               7E3000
!sineTableA                     7E8900
!sineTableB                     7E8B00
!animScratch                    7F0000
!spritesetPtr                   7F0006
!chatPtr                        7F000A
!metaspritePtr                  7F000C
!animScratch2                   7F000E
!statsPtr                       7F0020
!enemyNum                       7F0022
!deathActionIdx                 7F0024
!currentHp                      7F0026
!iframeCounter                  7F0028
!extendedFlags                  7F002A
!moveScratch1                   7F002C
!moveScratch2                   7F002E
!backdropColors                 7F0C00
!adhocVramDma                   7F0C03
!onHitCallback                  7F1000
!onDodgeCallback                7F1002
!onDeathCallback                7F1004
!onCollideCallback              7F1008
!scratch1010                    7F1010
!chainDamage                    7F101E
!oamComposeBuffer               7F3100
!L_WRMPYA                       804202
!L_WRMPYB                       804203

---------------------------------------------

code_3B7DD {
    PHX 
    LDA $0018
    STA $001A
    SEC 
    SBC #$0006
    STA $0018
    BRA loc_03B80C
}

code_03B7ED {
    PHX 
    LDA $0000
    BIT #$F000
    BNE loc_03B858
    LDA $14
    STA $001A
    SEC 
    SBC #$0006
    STA $0018
    LDA $16
    STA $001C
    LDA $0E
    STA $0002

  loc_03B80C:
    LDA $0001
    AND #$000F
    BEQ loc_03B823
    JSR $&code_03B85A
    LDA $0018
    CLC 
    ADC #$0004
    STA $0018
    BRA loc_03B82D

  loc_03B823:
    LDA $0018
    CLC 
    ADC #$0002
    STA $0018

  loc_03B82D:
    LDA $0000
    LSR 
    LSR 
    LSR 
    LSR 
    BEQ loc_03B845
    JSR $&code_03B85A
    LDA $001A
    CLC 
    ADC #$0004
    STA $0018
    BRA loc_03B84F

  loc_03B845:
    LDA $0018
    CLC 
    ADC #$0002
    STA $0018

  loc_03B84F:
    LDA $0000
    AND #$000F
    JSR $&code_03B85A

  loc_03B858:
    PLX 
    RTL 
}

code_03B85A {
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

code_03B881 {
    PHP 
    REP #$20
    LDA $joypadCurrent
    BIT #$8000
    BEQ loc_03B8AE
    LDY #$0000

  loc_03B88F:
    LDX $0C00, Y
    BEQ loc_03B8AE
    INY 
    INY 
    LDA $0010, X
    BIT #$D460
    BNE loc_03B88F
    LDA $onDodgeCallback, X
    BEQ loc_03B88F
    STA $0000, X
    LDA #$0000
    STA $onDodgeCallback, X

  loc_03B8AE:
    PLP 
    RTL 
}

code_03B8B0 {
    PHP 
    REP #$20
    LDA $slopeCurvePtrB
    BIT #$0020
    BNE loc_03B8DE
    BIT #$0200
    BNE loc_03B8DE
    LDA $playerHp
    BNE loc_03B8DE
    LDA #$0200
    TSB $slopeCurvePtrB
    LDY $decelStepCounter
    LDA #$D775
    STA $0000, Y
    LDA #$0080
    STA $0002, Y
    JSL $@chunk_008000.code_00F4A7

  loc_03B8DE:
    PLP 
    RTL 
}

code_03B8E0 {
    PHP 
    PHB 
    REP #$20
    STZ $09F8
    LDX $decelStepCounter
    LDA $0010, X
    BIT #$0040
    BEQ loc_03B917
    JMP $&code_03BA56
}

code_03B8F5 {
    BIT #$0080
    BEQ loc_03B922
    BIT #$0040
    BNE loc_03B922
    LDA $0012, Y
    BIT #$0010
    BNE loc_03B922
    STX $0E
    STY $08
    TYX 
    LDA $iframeCounter, X
    BMI code_03B91C
    JSR $&code_03BA59
    BRA code_03B91C

  loc_03B917:
    LDX #$0000
    STX $0E

  code_03B91C:
    LDX $0E
    STZ $20
    STZ $24

  loc_03B922:
    LDY $0C00, X
    BNE loc_03B92A
    JMP $&code_03BA56

  loc_03B92A:
    INX 
    INX 
    LDA $0010, Y
    BIT #$0400
    BEQ code_03B8F5
    BIT #$0140
    BNE loc_03B922
    BIT #$0020
    BEQ loc_03B940
    INC $20

  loc_03B940:
    STX $0E
    STY $08
    SEP #$20
    TYX 
    LDA $7F0008, X
    PHA 
    PLB 
    REP #$20
    LDA $metaspritePtr, X
    TAY 
    STA $42
    LDA $000E, X
    ASL 
    ASL 
    LDA $0004, Y
    AND #$00FF
    BIT #$0080
    BEQ loc_03B969
    ORA #$FF00

  loc_03B969:
    BCS loc_03B97D
    ADC $0014, X
    STA $04
    LDA $0005, Y
    AND #$00FF
    CLC 
    ADC $04
    STA $06
    BRA loc_03B996

  loc_03B97D:
    EOR #$FFFF
    INC 
    CLC 
    ADC $0014, X
    STA $06
    LDA $0005, Y
    AND #$00FF
    EOR #$FFFF
    INC 
    CLC 
    ADC $06
    STA $04

  loc_03B996:
    LDA $0006, Y
    AND #$00FF
    BIT #$0080
    BEQ loc_03B9A4
    ORA #$FF00

  loc_03B9A4:
    CLC 
    ADC $0016, X
    STA $00
    LDA $0007, Y
    AND #$00FF
    CLC 
    ADC $00
    STA $02
    LDX #$0000

  code_03B9B8:
    LDY $0C00, X
    BNE loc_03B9C0
    JMP $&code_03B91C

  loc_03B9C0:
    INX 
    INX 
    LDA $20
    BNE loc_03B9D0
    LDA $0010, Y
    BIT #$76E0
    BEQ loc_03B9EB
    BRA code_03B9B8

  loc_03B9D0:
    STZ $24
    LDA $0010, Y
    BIT #$74E0
    BNE code_03B9B8
    PHX 
    TYX 
    LDA $extendedFlags, X
    BIT #$0010
    BNE loc_03B9E8
    PLX 
    BRA code_03B9B8

  loc_03B9E8:
    PLX 
    INC $24

  loc_03B9EB:
    LDA $0020, Y
    AND #$00FF
    BIT #$0080
    BEQ loc_03B9F9
    ORA #$FF00

  loc_03B9F9:
    SEC 
    SBC $0014, Y
    EOR #$FFFF
    INC 
    CMP $06
    BCS code_03B9B8
    LDA $0021, Y
    AND #$00FF
    BIT #$0080
    BEQ loc_03BA13
    ORA #$FF00

  loc_03BA13:
    CLC 
    ADC $0014, Y
    CMP $04
    BCC code_03B9B8
    LDA $0022, Y
    AND #$00FF
    BIT #$0080
    BEQ loc_03BA29
    ORA #$FF00

  loc_03BA29:
    SEC 
    SBC $0016, Y
    EOR #$FFFF
    INC 
    CMP $02
    BCS code_03B9B8
    LDA $0023, Y
    AND #$00FF
    BIT #$0080
    BEQ loc_03BA43
    ORA #$FF00

  loc_03BA43:
    CLC 
    ADC $0016, Y
    CMP $00
    BCS loc_03BA4E
    JMP $&code_03B9B8

  loc_03BA4E:
    PHX 
    JSR $&code_03BC2C
    PLX 
    JMP $&code_03B9B8
}

code_03BA56 {
    PLB 
    PLP 
    RTL 
}

code_03BA59 {
    SEP #$20
    LDA $7F0008, X
    PHA 
    PLB 
    REP #$20
    LDA $metaspritePtr, X
    TAY 
    STA $42
    LDA $0014, X
    STA $04
    LDA $0016, X
    STA $00
    LDA $0000, Y
    ORA #$FF00
    CLC 
    ADC $04
    STA $04
    LDA $0002, Y
    AND #$00FF
    ASL 
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $04
    STA $06
    LDA $0001, Y
    ORA #$FF00
    CLC 
    ADC $00
    STA $00
    LDA $0003, Y
    AND #$00FF
    ASL 
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $00
    STA $02
    LDX #$0000

  code_03BAAB:
    LDY $0C00, X
    BNE loc_03BAB3
    JMP $&code_03BC27

  loc_03BAB3:
    INX 
    INX 
    LDA $0010, Y
    BIT #$36F0
    BNE code_03BAAB
    LDA $0020, Y
    AND #$00FF
    BIT #$0080
    BEQ loc_03BACB
    ORA #$FF00

  loc_03BACB:
    SEC 
    SBC $0014, Y
    EOR #$FFFF
    INC 
    CMP $06
    BCS code_03BAAB
    LDA $0021, Y
    AND #$00FF
    BIT #$0080
    BEQ loc_03BAE5
    ORA #$FF00

  loc_03BAE5:
    CLC 
    ADC $0014, Y
    CMP $04
    BCC code_03BAAB
    LDA $0022, Y
    AND #$00FF
    BIT #$0080
    BEQ loc_03BAFB
    ORA #$FF00

  loc_03BAFB:
    SEC 
    SBC $0016, Y
    EOR #$FFFF
    INC 
    CMP $02
    BCS code_03BAAB
    LDA $0023, Y
    AND #$00FF
    BIT #$0080
    BEQ loc_03BB15
    ORA #$FF00

  loc_03BB15:
    CLC 
    ADC $0016, Y
    CMP $00
    BCS loc_03BB20
    JMP $&code_03BAAB

  loc_03BB20:
    TYX 
    LDA $currentHp, X
    PHA 
    LDA $08
    TAX 
    LDA $chainDamage, X
    LSR 
    TYX 
    STA $chainDamage, X
    INC 
    EOR #$FFFF
    INC 
    CLC 
    ADC $currentHp, X
    BPL loc_03BB42
    LDA #$0000

  loc_03BB42:
    STA $currentHp, X
    STA $0AE2
    PHX 
    LDA $statsPtr, X
    TAX 
    LDA $810000, X
    STA $0AE0
    PLX 
    TXA 
    TCD 
    LDA $12
    BIT #$0020
    BNE loc_03BB7B
    PLA 
    SEC 
    SBC $currentHp, X
    JSR $&code_03C298
    BCS loc_03BB7C
    PHA 
    COP [SpawnLastRel] ( @chunk_008000.code_00DDD3, #00, #00, #$2F00 )
    PLA 
    STA $0028, Y
    BRA loc_03BB7C

  loc_03BB7B:
    PLA 

  loc_03BB7C:
    LDA #$0080
    TSB $10
    LDA $slopeCurvePtrB
    BIT #$0010
    BNE loc_03BB90
    LDA $12
    BIT #$0010
    BEQ loc_03BBC3

  loc_03BB90:
    LDA $0AE2
    BNE loc_03BBF3
    LDA #$0040
    TSB $10
    LDA $onDeathCallback, X
    BEQ loc_03BBB0
    STA $00
    LDA $7F1006, X
    STA $02
    STZ $08
    STZ $2C
    STZ $2E
    BRA loc_03BC0D

  loc_03BBB0:
    LDA #$0080
    STA $02
    LDA #$DCA9
    STA $00
    STZ $08
    LDA #$0400
    TSB $10
    BRA loc_03BC0D

  loc_03BBC3:
    COP [SpawnLastRel] ( @chunk_008000.code_00D996, #00, #00, #$2000 )
    LDA #$0000
    STA $002C, Y
    STA $002E, Y
    LDA $extendedFlags, X
    AND #$0020
    PHX 
    TYX 
    STA $extendedFlags, X
    PLX 
    PHY 
    PHD 
    JSR $&code_03BE50
    BCC loc_03BBEC
    COP [GetPlayerFacing]

  loc_03BBEC:
    PLD 
    PLY 
    STA $0028, Y
    TDC 
    TAX 

  loc_03BBF3:
    LDA $12
    BIT #$0001
    BEQ loc_03BC03
    LDA #$FFEF
    STA $iframeCounter, X
    BRA loc_03BC0A

  loc_03BC03:
    LDA #$0011
    STA $iframeCounter, X

  loc_03BC0A:
    COP [PlaySoundCh1] ( #05 )

  loc_03BC0D:
    LDA $12
    BIT #$0020
    BNE code_03BC27
    SEP #$20
    LDA $0AE0
    STA $09F2
    STA $09F8
    LDA $0AE2
    STA $playerActorDp
    REP #$20
}

code_03BC27 {
    LDA #$0000
    TCD 
    RTS 
}

code_03BC2C {
    SEP #$20
    LDA #$81
    PHA 
    PLB 
    REP #$20
    LDA $24
    BEQ loc_03BC8B
    STZ $24
    TYX 
    LDA $scratch1010+6, X
    BEQ loc_03BC45
    STA $0000, X
    RTS 

  loc_03BC45:
    TXA 
    PHD 
    TCD 
    LDA #$C560
    STA $00
    LDA #$0080
    STA $02
    LDA #$0040
    TSB $10
    PLD 
    JSL $@code_03E58B
    PEA $&code_03BC89-1
    BCC loc_03BC62
    RTS 

  loc_03BC62:
    AND #$000F
    BNE loc_03BC6E
    LDA #$FFFC
    STA $extVelocityY
    RTS 

  loc_03BC6E:
    DEC 
    BNE loc_03BC78
    LDA #$0004
    STA $extVelocityY
    RTS 

  loc_03BC78:
    DEC 
    BNE loc_03BC82
    LDA #$0004
    STA $extVelocityX
    RTS 

  loc_03BC82:
    LDA #$FFFC
    STA $extVelocityX
    RTS 
}

code_03BC89 {
    TXY 
    RTS 

  loc_03BC8B:
    TYX 
    STX $3E
    LDA $0010, X
    BIT #$0010
    BEQ loc_03BC99
    JMP $&code_03BE24

  loc_03BC99:
    STZ $20
    LDA $08
    CMP #$1000
    BEQ loc_03BCA7
    LDA $09F0
    STA $20

  loc_03BCA7:
    LDA $characterForm
    STA $08
    LDA $playerStr
    CLC 
    ADC $20
    CLC 
    ADC $09EE
    STA $20
    TXA 
    TCD 
    LDA $currentHp, X
    PHA 
    LDA $statsPtr, X
    TAY 
    LDA $0000, Y
    AND #$00FF
    STA $0AE0
    LDA $0002, Y
    AND #$00FF
    SEC 
    SBC $0020
    EOR #$FFFF
    INC 
    CMP #$0001
    BPL loc_03BCE3
    LDA #$0001

  loc_03BCE3:
    CLC 
    ADC $0008
    STA $chainDamage, X
    EOR #$FFFF
    INC 
    CLC 
    ADC $currentHp, X
    BPL loc_03BCF9
    LDA #$0000

  loc_03BCF9:
    STA $currentHp, X
    STA $0AE2
    LDA $12
    BIT #$0020
    BNE loc_03BD2B
    PLA 
    SEC 
    SBC $currentHp, X
    JSR $&code_03C298
    BCS loc_03BD2C
    PHA 
    COP [SpawnLastRel] ( @chunk_008000.code_00DDD3, #00, #00, #$2B00 )
    LDA $0012, Y
    ORA #$1000
    STA $0012, Y
    PLA 
    STA $0028, Y
    BRA loc_03BD2C

  loc_03BD2B:
    PLA 

  loc_03BD2C:
    LDA #$0080
    TSB $10
    LDA $slopeCurvePtrB
    BIT #$0010
    BNE loc_03BD40
    LDA $12
    BIT #$0010
    BEQ loc_03BD73

  loc_03BD40:
    LDA $0AE2
    BNE loc_03BDA5
    LDA #$0040
    TSB $10
    LDA $onDeathCallback, X
    BEQ loc_03BD60
    STA $00
    LDA $7F1006, X
    STA $02
    STZ $08
    STZ $2C
    STZ $2E
    BRA loc_03BDD6

  loc_03BD60:
    LDA #$0080
    STA $02
    LDA #$DCA9
    STA $00
    STZ $08
    LDA #$0400
    TSB $10
    BRA loc_03BDD6

  loc_03BD73:
    TXA 
    TCD 
    COP [SpawnLastRel] ( @chunk_008000.code_00D996, #00, #00, #$2000 )
    LDA #$0000
    STA $002C, Y
    STA $002E, Y
    LDA $extendedFlags, X
    AND #$0020
    PHX 
    TYX 
    STA $extendedFlags, X
    PLX 
    PHY 
    PHD 
    JSR $&code_03BE50
    BCC loc_03BD9E
    COP [GetPlayerFacing]

  loc_03BD9E:
    PLD 
    PLY 
    STA $0028, Y
    TDC 
    TAX 

  loc_03BDA5:
    LDA $onHitCallback, X
    BEQ loc_03BDBC
    STA $00
    LDA #$0000
    STA $onHitCallback, X
    LDA $02
    AND #$00FF
    BNE loc_03BDBC
    NOP 

  loc_03BDBC:
    LDA $12
    BIT #$0001
    BEQ loc_03BDCC
    LDA #$FFEF
    STA $iframeCounter, X
    BRA loc_03BDD3

  loc_03BDCC:
    LDA #$0011
    STA $iframeCounter, X

  loc_03BDD3:
    COP [PlaySoundCh1] ( #05 )

  loc_03BDD6:
    LDA $12
    BIT #$0020
    BNE loc_03BDF0
    SEP #$20
    LDA $0AE0
    STA $09F2
    STA $09F8
    LDA $0AE2
    STA $playerActorDp
    REP #$20

  loc_03BDF0:
    LDA #$0000
    TCD 
    LDX $0E
    LDA $0BFE, X
    TAX 
    LDA $extendedFlags, X
    BIT #$0050
    BEQ loc_03BE23
    AND #$FFAF
    STA $extendedFlags, X
    LDA $onCollideCallback, X
    BEQ loc_03BE1A
    STA $0000, X
    LDA #$0000
    STA $onCollideCallback, X

  loc_03BE1A:
    LDA $0012, X
    EOR #$6000
    STA $0012, X

  loc_03BE23:
    RTS 
}

code_03BE24 {
    TXA 
    TCD 
    LDA $10
    ORA #$0080
    STA $10
    LDA #$FFEF
    STA $iframeCounter, X
    LDA $onHitCallback, X
    BEQ loc_03BE4B
    STA $00
    LDA #$0000
    STA $onHitCallback, X
    LDA $02
    AND #$00FF
    BNE loc_03BE4B
    NOP 

  loc_03BE4B:
    COP [PlaySoundCh1] ( #09 )
    BRA loc_03BDF0
}

code_03BE50 {
    LDY $000E
    LDX $0BFE, Y
    CPX $decelStepCounter
    SEC 
    BNE loc_03BE5D
    RTS 

  loc_03BE5D:
    SEP #$20
    LDA $7F0008, X
    PHA 
    PLB 
    REP #$20
    LDA $000E, X
    ASL 
    ASL 
    LDY $0042
    LDA $0004, Y
    AND #$00FF
    BIT #$0080
    BEQ loc_03BE7D
    ORA #$FF00

  loc_03BE7D:
    BCS loc_03BE96
    CLC 
    ADC $0014, X
    STA $0018
    LDA $0005, Y
    AND #$00FF
    LSR 
    CLC 
    ADC $0018
    STA $0018
    BRA loc_03BEB3

  loc_03BE96:
    EOR #$FFFF
    INC 
    CLC 
    ADC $0014, X
    STA $0018
    LDA $0005, Y
    AND #$00FF
    LSR 
    EOR #$FFFF
    INC 
    CLC 
    ADC $0018
    STA $0018

  loc_03BEB3:
    LDA $0006, Y
    AND #$00FF
    BIT #$0080
    BEQ loc_03BEC1
    ORA #$FF00

  loc_03BEC1:
    CLC 
    ADC $0016, X
    STA $001C
    LDA $0007, Y
    AND #$00FF
    LSR 
    CLC 
    ADC $001C
    STA $001C
    SEP #$20
    LDA $21
    SEC 
    SBC $20
    REP #$20
    AND #$00FF
    LSR 
    BIT #$0040
    BEQ loc_03BEEB
    ORA #$FF80

  loc_03BEEB:
    CLC 
    ADC $14
    STA $001A
    SEP #$20
    LDA $23
    SEC 
    SBC $22
    REP #$20
    AND #$00FF
    LSR 
    BIT #$0040
    BEQ loc_03BF06
    ORA #$FF80

  loc_03BF06:
    CLC 
    ADC $16
    STA $001E
    LDA #$0000
    TCD 
    LDA $18
    SEC 
    SBC $1A
    BCS loc_03BF38
    EOR #$FFFF
    INC 
    STA $08
    LDA $1C
    SEC 
    SBC $1E
    BCS loc_03BF30
    EOR #$FFFF
    INC 
    CMP $08
    BCS loc_03BF64
    NOP 
    NOP 
    BRA loc_03BF5A

  loc_03BF30:
    CMP $08
    BCS loc_03BF5F
    NOP 
    NOP 
    BRA loc_03BF5A

  loc_03BF38:
    STA $08
    LDA $1C
    SEC 
    SBC $1E
    BCS loc_03BF4D
    EOR #$FFFF
    INC 
    CMP $08
    BCS loc_03BF64
    NOP 
    NOP 
    BRA loc_03BF55

  loc_03BF4D:
    CMP $08
    BCS loc_03BF5F
    NOP 
    NOP 
    BRA loc_03BF55

  loc_03BF55:
    CLC 
    LDA #$0002
    RTS 

  loc_03BF5A:
    CLC 
    LDA #$0003
    RTS 

  loc_03BF5F:
    CLC 
    LDA #$0001
    RTS 

  loc_03BF64:
    CLC 
    LDA #$0000
    RTS 
}

code_03BF69 {
    PLB 
    PLP 
    RTL 
}

code_03BF6C {
    PHP 
    PHB 
    REP #$20
    LDY $decelStepCounter
    LDA $0014, Y
    SEC 
    SBC #$0004
    STA $18
    CLC 
    ADC #$0008
    STA $1A
    LDA $0016, Y
    SEC 
    SBC #$0004
    STA $1E
    SEC 
    SBC #$000A
    STA $1C
    LDA $0010, Y
    BIT #$2040
    BNE code_03BF69
    BIT #$0280
    BEQ loc_03BFA1
    JMP $&code_03C070

  loc_03BFA1:
    LDY #$0000
    STY $0E

  code_03BFA6:
    LDY $0E

  loc_03BFA8:
    LDX $0C00, Y
    BEQ code_03BF69
    INY 
    INY 
    LDA $0010, X
    BIT #$35C0
    BNE loc_03BFA8
    STY $0E
    SEP #$20
    LDA $7F0008, X
    PHA 
    PLB 
    REP #$20
    TXY 
    LDA $metaspritePtr, X
    TAX 
    LDA $000E, Y
    ASL 
    ASL 
    LDA $0004, X
    AND #$00FF
    BIT #$0080
    BEQ loc_03BFDC
    ORA #$FF00

  loc_03BFDC:
    BCS loc_03BFF6
    ADC $0014, Y
    CMP $1A
    BCS code_03BFA6
    STA $06
    LDA $0005, X
    AND #$00FF
    CLC 
    ADC $06
    CMP $18
    BCC code_03BFA6
    BRA loc_03C015

  loc_03BFF6:
    EOR #$FFFF
    INC 
    CLC 
    ADC $0014, Y
    CMP $18
    BCC code_03BFA6
    STA $06
    LDA $0005, X
    AND #$00FF
    EOR #$FFFF
    INC 
    CLC 
    ADC $06
    CMP $1A
    BCS code_03BFA6

  loc_03C015:
    LDA $0006, X
    AND #$00FF
    BIT #$0080
    BEQ loc_03C023
    ORA #$FF00

  loc_03C023:
    CLC 
    ADC $0016, Y
    CMP $1E
    BCC loc_03C02E
    JMP $&code_03BFA6

  loc_03C02E:
    STA $02
    LDA $0007, X
    AND #$00FF
    CLC 
    ADC $02
    CMP $1C
    BCS loc_03C040
    JMP $&code_03BFA6

  loc_03C040:
    PHX 
    TYX 
    LDA $extendedFlags, X
    BIT #$0010
    BEQ loc_03C069
    LDA $onCollideCallback, X
    BEQ loc_03C056
    STA $0000, X
    BRA loc_03C062

  loc_03C056:
    LDA #$0080
    STA $0002, X
    LDA #$E5F1
    STA $0000, X

  loc_03C062:
    LDA #$0000
    STA $0008, X
    TXY 

  loc_03C069:
    PLX 
    JSR $&code_03C0EE

  loc_03C06D:
    PLB 
    PLP 
    RTL 
}

code_03C070 {
    LDY #$0000
    STY $0E

  loc_03C075:
    LDY $0E

  loc_03C077:
    LDX $0C00, Y
    BEQ loc_03C06D
    INY 
    INY 
    LDA $0010, X
    BIT #$3540
    BNE loc_03C077
    BIT #$0020
    BEQ loc_03C077
    STY $0E
    SEP #$20
    LDA $7F0008, X
    PHA 
    PLB 
    REP #$20
    TXY 
    LDA $metaspritePtr, X
    TAX 
    LDA $0004, X
    AND #$00FF
    BIT #$0080
    BEQ loc_03C0AB
    ORA #$FF00

  loc_03C0AB:
    CLC 
    ADC $0014, Y
    CMP $1A
    BCS loc_03C075
    STA $06
    LDA $0005, X
    AND #$00FF
    CLC 
    ADC $0014, Y
    CMP $18
    BCC loc_03C075
    LDA $0006, X
    AND #$00FF
    BIT #$0080
    BEQ loc_03C0D1
    ORA #$FF00

  loc_03C0D1:
    CLC 
    ADC $0016, Y
    CMP $1E
    BCS loc_03C075
    STA $02
    LDA $0007, X
    AND #$00FF
    CLC 
    ADC $02
    CMP $1C
    BCC loc_03C075
    JSR $&code_03C0EE
    PLB 
    PLP 
    RTL 
}

code_03C0EE {
    LDA $0010, Y
    BIT #$0020
    BEQ loc_03C0F9
    JMP $&code_03C1DE

  loc_03C0F9:
    LDA $000E, Y
    ASL 
    ASL 
    LDA $0004, X
    AND #$00FF
    BIT #$0080
    BEQ loc_03C10C
    ORA #$FF00

  loc_03C10C:
    BCS loc_03C121
    ADC $0014, Y
    STA $00
    LDA $0005, X
    AND #$00FF
    LSR 
    CLC 
    ADC $00
    STA $00
    BRA loc_03C13B

  loc_03C121:
    EOR #$FFFF
    INC 
    CLC 
    ADC $0014, Y
    STA $00
    LDA $0005, X
    AND #$00FF
    LSR 
    EOR #$FFFF
    INC 
    CLC 
    ADC $00
    STA $00

  loc_03C13B:
    LDA $0006, X
    AND #$00FF
    BIT #$0080
    BEQ loc_03C149
    ORA #$FF00

  loc_03C149:
    CLC 
    ADC $0016, Y
    STA $02
    LDA $0007, X
    AND #$00FF
    LSR 
    CLC 
    ADC $02
    STA $02
    SEP #$20
    LDA #$81
    PHA 
    PLB 
    REP #$20
    STY $08
    TYX 
    LDA $statsPtr, X
    TAY 
    LDA $0001, Y
    AND #$00FF
    SEC 
    SBC $playerDef
    BEQ loc_03C179
    BCS loc_03C17C

  loc_03C179:
    LDA #$0001

  loc_03C17C:
    EOR #$FFFF
    INC 
    CLC 
    ADC $playerHp
    BPL loc_03C189
    LDA #$0000

  loc_03C189:
    STA $playerHp
    LDA $decelStepCounter
    TCD 
    TAX 
    LDA #$0080
    TSB $10
    LDA #$003C
    STA $iframeCounter, X
    LDA $slopeCurvePtrB
    BIT #$1800
    BNE loc_03C1CB
    COP [SpawnLastRel] ( @chunk_008000.code_00D996, #00, #00, #$2400 )
    LDA $extendedFlags, X
    AND #$0020
    PHX 
    TYX 
    STA $extendedFlags, X
    PLX 
    LDA #$0F00
    TSB $joypadMaskStd
    JSR $&code_03C22D
    STA $28
    STZ $2C
    STZ $2E

  loc_03C1CB:
    LDA $characterForm
    BEQ loc_03C1D5
    COP [PlaySoundCh2] ( #08 )
    BRA loc_03C1D8

  loc_03C1D5:
    COP [PlaySoundCh2] ( #07 )

  loc_03C1D8:
    LDA #$0000
    TCD 
    CLC 
    RTS 
}

code_03C1DE {
    TYX 
    SEP #$20
    LDA #$81
    PHA 
    PLB 
    REP #$20
    LDA $chatPtr, X
    JSL $@code_03E458
    BCC loc_03C200
    AND #$00FF
    STA $0DB8
    LDY #$E974
    JSL $@chunk_028000.code_02FC78
    SEC 
    RTS 

  loc_03C200:
    LDA $chatPtr, X
    CMP #$0081
    BCS loc_03C213
    AND #$00FF
    STA $0DB8
    JSL $@chunk_028000.code_02FC78

  loc_03C213:
    LDA #$0080
    STA $0002, X
    LDA #$DD96
    STA $0000, X
    STZ $0008, X
    LDA $0010, X
    ORA #$0700
    STA $0010, X
    SEC 
    RTS 
}

code_03C22D {
    PHY 
    LDA #$0000
    TCD 
    LDY $08
    LDA $1A
    SEC 
    SBC #$0004
    STA $1A
    SEC 
    SBC $00
    BCS loc_03C264
    EOR #$FFFF
    INC 
    STA $04
    LDA $1E
    SEC 
    SBC #$0004
    STA $1E
    SEC 
    SBC $02
    BCS loc_03C25E
    EOR #$FFFF
    INC 
    CMP $04
    BCC loc_03C281
    BRA loc_03C28B

  loc_03C25E:
    CMP $04
    BCS loc_03C290
    BRA loc_03C281

  loc_03C264:
    STA $04
    LDA $1E
    SEC 
    SBC #$0004
    SEC 
    SBC $02
    BCS loc_03C27B
    EOR #$FFFF
    INC 
    CMP $04
    BCS loc_03C28B
    BRA loc_03C286

  loc_03C27B:
    CMP $04
    BCC loc_03C286
    BRA loc_03C290

  loc_03C281:
    LDY #$0002
    BRA loc_03C293

  loc_03C286:
    LDY #$0003
    BRA loc_03C293

  loc_03C28B:
    LDY #$0001
    BRA loc_03C293

  loc_03C290:
    LDY #$0000

  loc_03C293:
    PLA 
    TAX 
    TCD 
    TYA 
    RTS 
}

code_03C298 {
    PHA 
    LDY $0000
    STZ $0000
    CMP #$03E8
    BCS loc_03C302
    CMP #$01F4
    BCC loc_03C2B5
    SEC 
    SBC #$01F4
    PHA 
    LDA #$0005
    STA $0000
    PLA 

  loc_03C2B5:
    CMP #$0064
    BCC loc_03C2C3
    SEC 
    SBC #$0064
    INC $0000
    BRA loc_03C2B5

  loc_03C2C3:
    PHA 
    LDA $0000
    XBA 
    AND #$FF00
    STA $0000
    PLA 
    SEP #$20
    CMP #$32
    BCC loc_03C2DF
    SEC 
    SBC #$32
    PHA 
    LDA #$05
    STA $0000
    PLA 

  loc_03C2DF:
    CMP #$0A
    BCC loc_03C2EB
    SEC 
    SBC #$0A
    INC $0000
    BRA loc_03C2DF

  loc_03C2EB:
    PHA 
    LDA $0000
    ASL 
    ASL 
    ASL 
    ASL 
    ORA $01, S
    STA $01, S
    PLA 
    REP #$20
    STA $01, S
    STY $0000
    PLA 
    CLC 
    RTS 

  loc_03C302:
    STY $0000
    PLA 
    SEC 
    RTS 
}

code_03C308 {
    PHP 
    PHD 
    REP #$20
    LDY #$0000
    LDA $0058

  code_03C312:
    TAX 
    TCD 
    BNE loc_03C319
    JMP $&code_03C3A4

  loc_03C319:
    LDA $14
    SEC 
    SBC $18
    SEC 
    SBC $bg1ScrollH
    CMP #$0100
    BCC loc_03C33A
    BMI loc_03C32C
    JMP $&code_03C39A

  loc_03C32C:
    LDA $14
    CLC 
    ADC $1C
    SEC 
    SBC $bg1ScrollH
    CMP #$0100
    BCS code_03C39A

  loc_03C33A:
    LDA $16
    SEC 
    SBC $1A
    SEC 
    SBC $bg2ScrollH
    CMP #$00E0
    BCC loc_03C358
    BPL code_03C39A
    LDA $16
    CLC 
    ADC $1E
    SEC 
    SBC $bg2ScrollH
    CMP #$00E0
    BCS code_03C39A

  loc_03C358:
    LDA $10
    BIT #$2000
    BNE loc_03C390
    BIT #$0003
    BEQ loc_03C36E
    BIT #$0002
    BNE loc_03C379
    LDA #$01FE
    BRA loc_03C380

  loc_03C36E:
    LDA $16
    SEC 
    SBC $bg2ScrollH
    CMP #$0100
    BCC loc_03C37C

  loc_03C379:
    LDA #$00FF

  loc_03C37C:
    EOR #$00FF
    ASL 

  loc_03C380:
    CMP #$0200
    BCS loc_03C380
    STA $0C00, Y
    TXA 
    STA $0C02, Y
    INY 
    INY 
    INY 
    INY 

  loc_03C390:
    LDA #$4000
    TRB $10
    LDA $04
    JMP $&code_03C312
}

code_03C39A {
    LDA #$4000
    TSB $10
    LDA $04
    JMP $&code_03C312
}

code_03C3A4 {
    LDA #$FFFF
    STA $0C00, Y
    LDA #$0000
    TCD 
    LDA #$0422
    STA $02
    TSC 
    STA $00
    LDA #$0BFF
    TCS 

  loc_03C3BA:
    PLX 
    BMI loc_03C3F4
    LDY $deathFlag, X
    BNE loc_03C3DC
    LDA $02
    STA $deathFlag, X
    TAY 
    PLA 
    STA $0000, Y
    LDA #$0000
    STA $0002, Y
    LDA $02
    CLC 
    ADC #$0004
    STA $02
    BRA loc_03C3BA

  loc_03C3DC:
    LDA $02
    STA $deathFlag, X
    TAX 
    PLA 
    STA $0000, X
    TYA 
    STA $0002, X
    LDA $02
    CLC 
    ADC #$0004
    STA $02
    BRA loc_03C3BA

  loc_03C3F4:
    LDA #$01FF
    TCS 
    LDX #$0000
    BRA loc_03C3FF

  loc_03C3FD:
    PHA 
    PLA 

  loc_03C3FF:
    PLY 
    BEQ loc_03C3FF
    BMI loc_03C414

  loc_03C404:
    LDA $0000, Y
    STA $0C00, X
    INX 
    INX 
    LDA $0002, Y
    BEQ loc_03C3FD
    TAY 
    BRA loc_03C404

  loc_03C414:
    STZ $0C00, X
    LDA $00
    TCS 
    PLD 
    PLP 
    RTL 
}

code_03C41D {
    PHP 
    REP #$20
    LDA #$06FE
    STA $08
    STZ $06FF
    STZ $070F
    STZ $14
    LDA $bg1ScrollH
    SEC 
    SBC #$0010
    STA $1A
    LDA $bg2ScrollH
    SEC 
    SBC #$0010
    STA $1E
    LDA #$0622
    STA $06
    LDA #$0004
    STA $0E
    TSC 
    STA $00
    LDA #$0621
    TCS 
    LDX #$0010
    LDA #$E080

  loc_03C456:
    PHA 
    PHA 
    PHA 
    PHA 
    PHA 
    PHA 
    PHA 
    PHA 
    PHA 
    PHA 
    PHA 
    PHA 
    PHA 
    PHA 
    PHA 
    PHA 
    DEX 
    BNE loc_03C456
    LDA $00
    TCS 
    JSR $&code_03C494
    STZ $00D8
    LDX #$0000

  loc_03C475:
    LDA $0C00, X
    BEQ loc_03C486
    INX 
    INX 
    PHX 
    TAX 
    JSR $&code_03C555
    PLX 
    BCC loc_03C475
    BRA loc_03C492

  loc_03C486:
    SEP #$20
    LDA $00

  loc_03C48A:
    LSR 
    LSR 
    DEC $0E
    BNE loc_03C48A
    STA ($06)

  loc_03C492:
    PLP 
    RTL 
}

code_03C494 {
    LDX #$0000
    TXY 
    LDA $layerPriorityFlag
    BIT #$1000
    BNE loc_03C4F9

  loc_03C4A0:
    LDA $oamComposeBuffer, X
    BPL loc_03C4A7
    RTS 

  loc_03C4A7:
    LDA $7F3102, X
    SEC 
    SBC $bg2ScrollH
    CMP #$00F0
    BCS loc_03C4F1
    STA $0423, Y
    LDA $7F3104, X
    STA $0424, Y
    LDA $oamComposeBuffer, X
    SEC 
    SBC $bg1ScrollH
    CMP #$0110
    BCS loc_03C4F1
    SEP #$20
    STA $0422, Y
    XBA 
    LSR 
    ROR $00
    CLC 
    ROR $00
    DEC $0E
    BNE loc_03C4E5
    LDA $00
    STA ($06)
    INC $06
    LDA #$04
    STA $0E

  loc_03C4E5:
    REP #$20
    INY 
    INY 
    INY 
    INY 
    CPY #$0200
    BNE loc_03C4F1
    RTS 

  loc_03C4F1:
    INX 
    INX 
    INX 
    INX 
    INX 
    INX 
    BRA loc_03C4A0

  loc_03C4F9:
    LDA $00DA
    BNE loc_03C4FF
    RTS 

  loc_03C4FF:
    LDX #$3100
    LDY #$0422
    LDA $00DA
    BIT #$FE00
    BEQ loc_03C510
    LDA #$0200

  loc_03C510:
    DEC 
    PHB 
    MVN #$00, #$7F
    PLB 
    LDA $00DA
    LSR 
    LSR 
    LSR 
    LSR 
    STA $0E
    LDA $00DA
    LSR 
    AND #$0006
    STA $00
    SEP #$20

  loc_03C52A:
    DEC $0E
    BMI loc_03C536
    LDA #$AA
    STA ($06)
    INC $06
    BRA loc_03C52A

  loc_03C536:
    LDY $00DA
    LDX $00
    LDA $@code_03C54D, X
    STA $00
    LDA $@code_03C54D+1, X
    STA $0E
    REP #$20
    STZ $00DA
    RTS 
}

code_03C54D {
    BRK #$04
    BRA loc_03C554

  loc_03C551:
    LDY #$A802

  loc_03C554:
    ORA ($8B, X)
    SEP #$20
    LDA $7F0008, X
    PHA 
    PLB 
    REP #$20
    LDA $0014, X
    SEC 
    SBC $0018, X
    SEC 
    SBC $1A
    STA $18
    LDA $0016, X
    SEC 
    SBC $001A, X
    SEC 
    SBC $1E
    STA $1C
    LDA $000E, X
    STA $04
    STZ $02
    LDA $0010, X
    BIT #$0080
    BEQ loc_03C5A2
    BIT #$0010
    BNE loc_03C5A2
    BIT #$0400
    BNE loc_03C591

  loc_03C591:
    LDA $iframeCounter, X
    BEQ loc_03C59F
    LSR 
    BCC loc_03C59F
    LDA #$0E00
    STA $02

  loc_03C59F:
    LDA $0010, X

  loc_03C5A2:
    BIT #$8000
    BPL loc_03C5AA
    JMP $&code_03C634

  loc_03C5AA:
    LDA $metaspritePtr, X
    CLC 
    ADC #$0008
    TAX 
    LDA $0000, X
    AND #$00FF
    INX 
    STA $10

  loc_03C5BC:
    LDA $04
    ASL 
    LDA $0003, X
    BCC loc_03C5C5
    XBA 

  loc_03C5C5:
    AND #$00FF
    CLC 
    ADC $1C
    CMP #$00F0
    BCS loc_03C62C
    SBC #$0010
    STA $0423, Y
    LDA $0005, X
    EOR $04
    ORA $02
    STA $0424, Y
    LDA $04
    ASL 
    ASL 
    LDA $0001, X
    BCC loc_03C5EA
    XBA 

  loc_03C5EA:
    AND #$00FF
    CLC 
    ADC $18
    CMP #$0110
    BCS loc_03C62C
    SBC #$000F
    SEP #$20
    STA $0422, Y
    XBA 
    LSR 
    ROR $00
    LDA $0000, X
    LSR 
    ROR $00
    DEC $0E
    BNE loc_03C615
    LDA $00
    STA ($06)
    INC $06
    LDA #$04
    STA $0E

  loc_03C615:
    REP #$20
    INY 
    INY 
    INY 
    INY 
    CPY #$0200
    BEQ loc_03C62A

  loc_03C620:
    TXA 
    CLC 
    ADC #$0007
    TAX 
    DEC $10
    BNE loc_03C5BC

  loc_03C62A:
    PLB 
    RTS 

  loc_03C62C:
    LDA #$E080
    STA $0422, Y
    BRA loc_03C620
}

code_03C634 {
    JSR $&code_03C725
    LDA $slopeCurvePtrB
    BPL loc_03C642
    LDA $animScratch2, X
    BRA loc_03C64B

  loc_03C642:
    LDA $characterForm
    ASL 
    CLC 
    ADC $characterForm
    ASL 

  loc_03C64B:
    TAX 
    LDA $@body_table+3, X
    STA $06FC
    LDA $@body_table+5, X
    AND #$00FF
    STA ($08)
    INC $08
    LDA $09DA
    CLC 
    ADC #$0008
    TAX 
    LDA $0000, X
    AND #$00FF
    INX 
    STA $10

  code_03C66F:
    LDA $04
    ASL 
    LDA $0003, X
    BCC loc_03C678
    XBA 

  loc_03C678:
    AND #$00FF
    CLC 
    ADC $1C
    CMP #$00F0
    BCC loc_03C686
    JMP $&code_03C711

  loc_03C686:
    SBC #$0010
    STA $0423, Y
    LDA $0005, X
    EOR $04
    ORA $02
    PHA 
    AND #$01FF
    ASL 
    ASL 
    ASL 
    ASL 
    ASL 
    ADC $06FC
    STA ($08)
    INC $08
    INC $08
    PLA 
    AND #$FE00
    ORA $14
    STA $0424, Y
    LDA $14
    INC 
    INC 
    BIT #$0010
    BEQ loc_03C6BB
    CLC 
    ADC #$0010

  loc_03C6BB:
    STA $14
    LDA $04
    ASL 
    ASL 
    LDA $0001, X
    BCC loc_03C6C7
    XBA 

  loc_03C6C7:
    AND #$00FF
    CLC 
    ADC $18
    CMP #$0110
    BCS code_03C711
    SBC #$000F
    SEP #$20
    STA $0422, Y
    XBA 
    LSR 
    ROR $00
    LDA $0000, X
    LSR 
    ROR $00
    DEC $0E
    BNE loc_03C6F2
    LDA $00
    STA ($06)
    INC $06
    LDA #$04
    STA $0E

  loc_03C6F2:
    REP #$20
    INY 
    INY 
    INY 
    INY 
    CPY #$0200
    BEQ loc_03C70A

  loc_03C6FD:
    TXA 
    CLC 
    ADC #$0007
    TAX 
    DEC $10
    BEQ loc_03C70A
    JMP $&code_03C66F

  loc_03C70A:
    LDA #$0000
    STA ($08)
    PLB 
    RTS 
}

code_03C711 {
    LDA #$0004
    TSB $slopeCurvePtrB
    LDA #$0008
    TSB $09FA
    LDA #$E080
    STA $0422, Y
    BRA loc_03C6FD
}

code_03C725 {
    LDA $slopeCurvePtrB
    BIT #$0004
    BNE loc_03C743
    LDA $metaspritePtr, X
    CMP $09DA
    BNE loc_03C743
    LDA $7F0008, X
    CMP $09DC
    BNE loc_03C743
    LDA $09DA
    RTS 

  loc_03C743:
    LDA $slopeCurvePtrB
    AND #$FFFB
    STA $slopeCurvePtrB
    LDA $7F0008, X
    STA $09DC
    LDA $metaspritePtr, X
    STA $09DA
    LDA #$0008
    TSB $09FA
    RTS 
}

code_03C761 {
    PHB 
    SEP #$20
    LDA $7F0008, X
    PHA 
    PLB 
    REP #$20
    LDA $28
    ASL 
    CLC 
    ADC $spritesetPtr, X
    TAY 
    LDA $2A
    ASL 
    ASL 
    CLC 
    ADC $0000, Y
    TAY 
    LDA $0000, Y
    BMI loc_03C7FC
    STA $08
    LDA $0002, Y
    TAY 
    CLC 
    ADC #$0004
    STA $metaspritePtr, X
    LDA $0E
    ROL 
    PHP 
    LDA $0002, Y
    STA $0002
    BCC loc_03C79E
    XBA 

  loc_03C79E:
    SEP #$20
    STA $1A
    XBA 
    STA $1E
    REP #$20
    LDA $0000, Y
    STA $0000
    PLP 
    BPL loc_03C7B1
    XBA 

  loc_03C7B1:
    STA $0000
    AND #$00FF
    BIT #$0080
    BEQ loc_03C7BF
    ORA #$FF00

  loc_03C7BF:
    STA $18
    LDA $0001
    AND #$00FF
    BIT #$0080
    BEQ loc_03C7CF
    ORA #$FF00

  loc_03C7CF:
    STA $1C
    INC $2A
    LDA $12
    BIT #$0100
    BNE loc_03C7F9
    BIT #$0080
    BNE loc_03C7EF
    LDA $0000
    STA $20
    LDA $0002
    SEC 
    SBC #$0008
    STA $22
    BRA loc_03C7F9

  loc_03C7EF:
    LDA $0000
    STA $20
    LDA $0002
    STA $22

  loc_03C7F9:
    CLC 
    PLB 
    RTL 

  loc_03C7FC:
    STZ $2A
    SEC 
    PLB 
    RTL 
}

code_03C801 {
    PHP 
    PHD 
    REP #$20
    LDA $slopeCurvePtrB
    BIT #$0008
    BEQ loc_03C813
    LDA #$8000
    TRB $joypadCurrent

  loc_03C813:
    BIT #$0010
    BEQ loc_03C81B
    JMP $&code_03C949

  loc_03C81B:
    LDA $09FA
    BIT #$0080
    BEQ loc_03C826
    JMP $&code_03C8AF

  loc_03C826:
    LDA $56
    BEQ loc_03C89C

  loc_03C82A:
    TCD 
    TAX 
    LDA $10
    BIT #$2000
    BEQ loc_03C849
    DEC $08
    BPL code_03C89F
    STZ $08
    PHK 
    PEA $&code_03C89F-1
    SEP #$20
    LDA $02
    PHA 
    REP #$20
    LDA $00
    DEC 
    PHA 
    RTL 

  loc_03C849:
    BIT #$0080
    BEQ loc_03C86E
    LDA $iframeCounter, X
    BEQ loc_03C869
    BMI loc_03C862
    DEC 
    STA $iframeCounter, X
    CPX $decelStepCounter
    BEQ loc_03C86E
    BRA loc_03C898

  loc_03C862:
    INC 
    STA $iframeCounter, X
    BNE loc_03C86E

  loc_03C869:
    LDA #$0080
    TRB $10

  loc_03C86E:
    DEC $08
    BPL code_03C884
    STZ $08
    PHK 
    PEA $&code_03C884-1
    SEP #$20
    LDA $02
    PHA 
    REP #$20
    LDA $00
    DEC 
    PHA 
    RTL 
}

code_03C884 {
    LDA $10
    AND #$FFFB
    STA $10
    BIT #$0008
    BEQ loc_03C895
    JSR $&code_03CF7F
    BRA loc_03C898

  loc_03C895:
    JSR $&code_03CEFE

  loc_03C898:
    LDA $06
    BNE loc_03C82A

  loc_03C89C:
    PLD 
    PLP 
    RTL 
}

code_03C89F {
    LDA $10
    BIT #$2000
    BEQ code_03C884
    LDA $12
    BIT #$0008
    BEQ loc_03C898
    BRA code_03C884
}

code_03C8AF {
    LDA $56
    BNE loc_03C8B6
    JMP $&code_03C936

  loc_03C8B6:
    TCD 
    TAX 
    LDA $10
    BIT #$1000
    BNE loc_03C8C8
    LDA $12
    BIT #$1000
    BEQ loc_03C932
    LDA $10

  loc_03C8C8:
    BIT #$2000
    BEQ loc_03C8E3
    DEC $08
    BPL code_03C939
    STZ $08
    PHK 
    PEA $&code_03C939-1
    SEP #$20
    LDA $02
    PHA 
    REP #$20
    LDA $00
    DEC 
    PHA 
    RTL 

  loc_03C8E3:
    BIT #$0080
    BEQ loc_03C908
    LDA $iframeCounter, X
    BEQ loc_03C903
    BMI loc_03C8FC
    DEC 
    STA $iframeCounter, X
    CPX $decelStepCounter
    BEQ loc_03C908
    BRA loc_03C932

  loc_03C8FC:
    INC 
    STA $iframeCounter, X
    BNE loc_03C908

  loc_03C903:
    LDA #$0080
    TRB $10

  loc_03C908:
    DEC $08
    BPL code_03C91E
    STZ $08
    PHK 
    PEA $&code_03C91E-1
    SEP #$20
    LDA $02
    PHA 
    REP #$20
    LDA $00
    DEC 
    PHA 
    RTL 
}

code_03C91E {
    LDA $10
    AND #$FFFB
    STA $10
    BIT #$0008
    BEQ loc_03C92F
    JSR $&code_03CF7F
    BRA loc_03C932

  loc_03C92F:
    JSR $&code_03CEFE

  loc_03C932:
    LDA $06
    BNE loc_03C8B6
}

code_03C936 {
    PLD 
    PLP 
    RTL 
}

code_03C939 {
    LDA $10
    BIT #$2000
    BEQ code_03C91E
    LDA $12
    BIT #$0008
    BEQ loc_03C932
    BRA code_03C91E
}

code_03C949 {
    LDA $56
    BNE code_03C950
    JMP $&code_03C9D6

  code_03C950:
    TCD 
    TAX 
    LDA $12
    BIT #$1000
    BNE loc_03C960
    LDA $10
    BIT #$1400
    BEQ loc_03C9D9

  loc_03C960:
    BIT #$2000
    BEQ loc_03C97E
    DEC $08
    BMI loc_03C96C
    JMP $&code_03C9FB

  loc_03C96C:
    STZ $08
    PHK 
    PEA $&code_03C9FB-1
    SEP #$20
    LDA $02
    PHA 
    REP #$20
    LDA $00
    DEC 
    PHA 
    RTL 

  loc_03C97E:
    BIT #$0080
    BEQ loc_03C9A3
    LDA $iframeCounter, X
    BEQ loc_03C99E
    BMI loc_03C997
    DEC 
    STA $iframeCounter, X
    CPX $decelStepCounter
    BEQ loc_03C9A3
    BRA loc_03C9CF

  loc_03C997:
    INC 
    STA $iframeCounter, X
    BNE loc_03C9A3

  loc_03C99E:
    LDA #$0080
    TRB $10

  loc_03C9A3:
    DEC $08
    BPL code_03C9B9
    STZ $08
    PHK 
    PEA $&code_03C9B9-1
    SEP #$20
    LDA $02
    PHA 
    REP #$20
    LDA $00
    DEC 
    PHA 
    RTL 
}

code_03C9B9 {
    LDA $10
    AND #$FFFB
    STA $10
    BIT #$0008
    BEQ loc_03C9CA
    JSR $&code_03CF7F
    BRA loc_03C9CF

  loc_03C9CA:
    JSR $&code_03CEFE
    BRA loc_03C9CF

  loc_03C9CF:
    LDA $06
    BEQ code_03C9D6
    JMP $&code_03C950
}

code_03C9D6 {
    PLD 
    PLP 
    RTL 

  loc_03C9D9:
    BIT #$0080
    BEQ loc_03C9CF
    LDA $iframeCounter, X
    BEQ loc_03C9F4
    BMI loc_03C9ED
    DEC 
    STA $iframeCounter, X
    BRA loc_03C9CF

  loc_03C9ED:
    INC 
    STA $iframeCounter, X
    BRA loc_03C9CF

  loc_03C9F4:
    LDA #$0080
    TRB $10
    BRA loc_03C9CF
}

code_03C9FB {
    LDA $10
    BIT #$2000
    BEQ code_03C9B9
    LDA $12
    BIT #$0008
    BEQ loc_03C9CF
    BRA code_03C9B9
}

code_03CA0B {
    PHP 
    PHD 
    REP #$20
    LDA $56
    BEQ loc_03CA67

  loc_03CA13:
    TCD 
    TAX 
    LDA $10
    AND #$FFFB
    STA $10
    BIT #$0800
    BEQ loc_03CA63
    LDA $10
    BIT #$2000
    BEQ loc_03CA3E
    DEC $08
    BPL code_03CA6A
    STZ $08
    PHK 
    PEA $&code_03CA6A-1
    SEP #$20
    LDA $02
    PHA 
    REP #$20
    LDA $00
    DEC 
    PHA 
    RTL 

  loc_03CA3E:
    DEC $08
    BPL code_03CA54
    STZ $08
    PHK 
    PEA $&code_03CA54-1
    SEP #$20
    LDA $02
    PHA 
    REP #$20
    LDA $00
    DEC 
    PHA 
    RTL 
}

code_03CA54 {
    LDA $10
    BIT #$0008
    BEQ loc_03CA60
    JSR $&code_03CF7F
    BRA loc_03CA63

  loc_03CA60:
    JSR $&code_03CEFE

  loc_03CA63:
    LDA $06
    BNE loc_03CA13

  loc_03CA67:
    PLD 
    PLP 
    RTL 
}

code_03CA6A {
    LDA $10
    BIT #$2000
    BEQ code_03CA54
    LDA $12
    BIT #$0008
    BEQ loc_03CA63
    BRA code_03CA54
}

code_03CA7A {
    PHP 
    PHD 
    REP #$20
    LDA $09FA
    BIT #$0080
    BEQ loc_03CA89
    JMP $&code_03C8AF

  loc_03CA89:
    LDA $56
    BEQ loc_03CAD5

  loc_03CA8D:
    TCD 
    TAX 
    LDA $12
    BIT #$1000
    BEQ loc_03CAD1
    LDA $10
    AND #$FFFB
    STA $10
    BIT #$2000
    BEQ loc_03CAB8
    DEC $08
    BPL loc_03CAD1
    STZ $08
    PHK 
    PEA $&code_03CAD8-1
    SEP #$20
    LDA $02
    PHA 
    REP #$20
    LDA $00
    DEC 
    PHA 
    RTL 

  loc_03CAB8:
    DEC $08
    BPL code_03CACE
    STZ $08
    PHK 
    PEA $&code_03CACE-1
    SEP #$20
    LDA $02
    PHA 
    REP #$20
    LDA $00
    DEC 
    PHA 
    RTL 
}

code_03CACE {
    JSR $&code_03CEFE

  loc_03CAD1:
    LDA $06
    BNE loc_03CA8D

  loc_03CAD5:
    PLD 
    PLP 
    RTL 
}

code_03CAD8 {
    LDA $10
    BIT #$2000
    BEQ code_03CACE
    LDA $12
    BIT #$0008
    BEQ loc_03CAD1
    BRA code_03CACE
}

code_03CAE8 {
    PHP 
    REP #$20
    LDX #$0E00
    STX $4E
    LDA #$0000
    STA $50
    LDA #$1000
    LDX #$0000

  loc_03CAFB:
    STA $0E00, X
    INX 
    INX 
    CLC 
    ADC #$0030
    CPX #$00A8
    BMI loc_03CAFB
    LDA #$FFFF
    STA $0E00, X
    LDA $sceneCurrent
    CMP #$00FF
    BEQ loc_03CB2F
    LDX #$0000
    TXA 

  loc_03CB1B:
    STA $1000, X
    STA $onHitCallback, X
    STA $7F2000, X
    INX 
    INX 
    CPX #$0FC0
    BNE loc_03CB1B
    BRA loc_03CB41

  loc_03CB2F:
    LDX #$0000
    TXA 

  loc_03CB33:
    STA $1000, X
    STA $onHitCallback, X
    INX 
    INX 
    CPX #$0FC0
    BNE loc_03CB33

  loc_03CB41:
    LDX #$3000
    STX $52
    LDA #$007E
    STA $54
    LDA #$0F00
    LDX #$0000

  loc_03CB51:
    STA $thinkerPoolAddrs, X
    INX 
    INX 
    CLC 
    ADC #$0010
    CPX #$0020
    BMI loc_03CB51
    LDA #$FFFF
    STA $thinkerPoolAddrs, X
    LDA $sceneCurrent
    CMP #$00FF
    BEQ loc_03CB87
    LDX #$0000
    TXA 

  loc_03CB73:
    STA $0F00, X
    STA $7F0E00, X
    STA $7F3000, X
    INX 
    INX 
    CPX #$0100
    BNE loc_03CB73
    PLP 
    RTL 

  loc_03CB87:
    LDX #$0000
    TXA 

  loc_03CB8B:
    STA $0F00, X
    STA $7F0E00, X
    INX 
    INX 
    CPX #$0100
    BNE loc_03CB8B
    PLP 
    RTL 
}

code_03CB9B {
    LDA [$52]
    BMI loc_03CBAB
    TAY 
    LDA #$0000
    STA [$52]
    INC $52
    INC $52
    CLC 
    RTL 

  loc_03CBAB:
    SEC 
    RTL 
}

code_03CBAD {
    PHP 
    REP #$20
    STZ $0056
    STZ $0058
    LDA #$008C
    STA $40
    LDX $0646
    LDA $@scene_actors, X
    STA $3E
    BEQ loc_03CBF8
    LDA [$3E]
    AND #$00FF
    CMP #$00FF
    BEQ loc_03CBF8
    JSL $@chunk_008000.code_00B5AF
    STY $0056
    BRA loc_03CBEF

  loc_03CBD9:
    LDA [$3E]
    AND #$00FF
    CMP #$00FF
    BEQ loc_03CBF5
    JSL $@chunk_008000.code_00B5AF
    TYA 
    STA $0006, X
    TXA 
    STA $0004, Y

  loc_03CBEF:
    TYX 
    JSR $&code_03CC24
    BCC loc_03CBD9

  loc_03CBF5:
    STX $0058

  loc_03CBF8:
    LDA #$1000
    STA $09FE
    PLP 
    RTL 
}

code_03CC00 {
    TYA 
    INC 
    CLC 
    ADC $3E
    STA $3E
    LDA [$3E]
    AND #$FF
    BRK #$C9
    SBC $@gfx_babel+1FCF, X
    DEC $4E
    DEC $4E
    TXA 
    STA [$4E]
    LDY $0004, X
    LDA #$00
    BRK #$99
    ASL $00
    TYX 
    SEC 
    RTS 
}

code_03CC24 {
    LDY #$0000
    LDA [$3E], Y
    INY 
    AND #$00FF
    ASL 
    ASL 
    ASL 
    ASL 
    STA $0014, X
    LDA [$3E], Y
    INY 
    AND #$00FF
    ASL 
    ASL 
    ASL 
    ASL 
    STA $0016, X
    LDA [$3E], Y
    INY 
    BIT #$0001
    BNE loc_03CC55
    AND #$00F6
    XBA 
    ORA $06F0
    STA $000E, X
    BRA loc_03CC5C

  loc_03CC55:
    AND #$00FF
    LSR 
    STA $000E, X

  loc_03CC5C:
    LDA [$3E], Y
    INY 
    INY 
    STA $42
    LDA [$3E], Y
    INY 
    AND #$00FF
    STA $44
    LDA [$3E], Y
    INY 
    AND #$00FF
    STA $statsPtr, X
    BEQ loc_03CCAE
    LDA [$3E], Y
    INY 
    AND #$00FF
    STA $enemyNum, X
    BEQ loc_03CC8A
    JSR $&code_03CDE4
    BCC loc_03CC8A
    JMP $&code_03CC00

  loc_03CC8A:
    LDA $extendedFlags, X
    ORA #$0100
    STA $extendedFlags, X
    LDA [$3E], Y
    INY 
    AND #$00FF
    STA $deathActionIdx, X
    INC $0AEC
    SED 
    LDA $0AEE
    CLC 
    ADC #$0001
    STA $0AEE
    CLD 

  loc_03CCAE:
    TYA 
    CLC 
    ADC $3E
    STA $3E
    LDY #$0000
    LDA [$42], Y
    INY 
    AND #$00FF
    STA $0028, X
    LDA [$42], Y
    INY 
    INY 
    ORA #$4000
    STA $0010, X
    TYA 
    CLC 
    ADC $42
    STA $0000, X
    LDA $44
    STA $0002, X
    PHD 
    TXA 
    TCD 
    LDA $10
    BMI loc_03CD18
    LDA #$4000
    STA $spritesetPtr, X
    LDA #$007E
    STA $7F0008, X
    JSL $@code_03C761
    LDA $14
    CLC 
    ADC #$0008
    STA $14
    STZ $08
    PLD 
    LDA $statsPtr, X
    BNE loc_03CD01
    RTS 

  loc_03CD01:
    ASL 
    ASL 
    CLC 
    ADC #$ABD8
    STA $statsPtr, X
    TAY 
    LDA $0000, Y
    AND #$00FF
    STA $currentHp, X
    CLC 
    RTS 

  loc_03CD18:
    LDA #$0088
    TRB $slopeCurvePtrB
    LDA $0E
    BIT #$0600
    BEQ loc_03CD44
    PHA 
    AND #$F9FF
    STA $0E
    LDA $01, S
    BIT #$0200
    BEQ loc_03CD38
    LDA #$0008
    TSB $slopeCurvePtrB

  loc_03CD38:
    PLA 
    BIT #$0400
    BEQ loc_03CD44
    LDA #$0080
    TSB $slopeCurvePtrB

  loc_03CD44:
    LDA $0650
    AND #$00FF
    ASL 
    TAY 
    LDA $&dir_sprite_table, Y
    AND #$00FF
    STA $28
    LDA $characterForm
    ASL 
    ASL 
    CLC 
    ADC $characterForm
    CLC 
    ADC $characterForm
    TAY 
    LDA $&body_table, Y
    STA $spritesetPtr, X
    LDA $&body_table+2, Y
    AND #$00FF
    STA $7F0008, X
    LDA $064C
    ORA $064E
    BEQ loc_03CD9B
    LDA $064C
    CLC 
    ADC #$0008
    STA $14
    LDA $064E
    CLC 
    ADC #$0010
    STA $16
    STZ $064C
    STZ $064E
    JSL $@code_03C761
    STZ $08
    BRA loc_03CDA3

  loc_03CD9B:
    LDA $14
    CLC 
    ADC #$0008
    STA $14

  loc_03CDA3:
    LDA $14
    STA $playerWallType
    LSR 
    LSR 
    LSR 
    LSR 
    STA $playerSpeedNs
    LDA $14
    SEC 
    SBC #$0080
    BPL loc_03CDBA
    LDA #$0000

  loc_03CDBA:
    STA $cameraTargetX
    STA $bg1ScrollH
    LDA $16
    SEC 
    SBC #$0010
    STA $playerSpeedEw
    LSR 
    LSR 
    LSR 
    LSR 
    STA $slopeStepCounter
    LDA $16
    SEC 
    SBC #$0080
    BPL loc_03CDDB
    LDA #$0000

  loc_03CDDB:
    STA $cameraTargetY
    STA $bg2ScrollH
    PLD 
    CLC 
    RTS 
}

code_03CDE4 {
    PHY 
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
    LDA $@code_03CE2E, X
    AND $wramFlags, Y
    BNE loc_03CE07
    CLC 
    REP #$20
    PLX 
    PLY 
    RTS 

  loc_03CE07:
    REP #$20
    LDA $03, S
    TAY 
    LDA [$3E], Y
    AND #$00FF
    BEQ loc_03CE2A
    NOP 
    JSL $@chunk_028000.code_02A393
    BCS loc_03CE2A
    LDY $3E
    PHY 
    LDY $40
    PHY 
    JSL $@chunk_028000.code_02A250
    PLY 
    STY $40
    PLY 
    STY $3E

  loc_03CE2A:
    SEC 
    PLX 
    PLY 
    RTS 
}

code_03CE2E {
    ORA ($02, X)
    TSB $08
    BPL loc_03CE54
    RTI 
    BRA loc_03CE3F

  loc_03CE37:
    PHD 
    REP #$20
    LDA $5A
    BEQ loc_03CE63

  loc_03CE3E:
    TCD 

  loc_03CE3F:
    TAX 
    LDA $animScratch2, X
    BIT #$0004
    BNE code_03CE5F
    DEC $08
    BPL code_03CE5F
    STZ $08
    PHK 
    PEA $&code_03CE5F-1
    SEP #$20
    LDA $02
    PHA 
    REP #$20
    LDA $00
    DEC 
    PHA 
    RTL 
}

code_03CE5F {
    LDA $06
    BNE loc_03CE3E

  loc_03CE63:
    PLD 
    PLP 
    RTL 
}

code_03CE66 {
    PHP 
    PHD 
    REP #$20
    LDA $5A
    BEQ loc_03CE93

  loc_03CE6E:
    TCD 
    TAX 
    LDA $animScratch2, X
    BIT #$0004
    BEQ code_03CE8F
    DEC $08
    BPL code_03CE8F
    STZ $08
    PHK 
    PEA $&code_03CE8F-1
    SEP #$20
    LDA $02
    PHA 
    REP #$20
    LDA $00
    DEC 
    PHA 
    RTL 
}

code_03CE8F {
    LDA $06
    BNE loc_03CE6E

  loc_03CE93:
    PLD 
    PLP 
    RTL 
}

code_03CE96 {
    PHP 
    PHD 
    REP #$20
    LDA $5A
    BEQ loc_03CEC8

  loc_03CE9E:
    TCD 
    TAX 
    LDA $animScratch2, X
    BIT #$0800
    BEQ code_03CEC4
    BIT #$0004
    BNE code_03CEC4
    DEC $08
    BPL code_03CEC4
    STZ $08
    PHK 
    PEA $&code_03CEC4-1
    SEP #$20
    LDA $02
    PHA 
    REP #$20
    LDA $00
    DEC 
    PHA 
    RTL 
}

code_03CEC4 {
    LDA $06
    BNE loc_03CE9E

  loc_03CEC8:
    PLD 
    PLP 
    RTL 
}

code_03CECB {
    PHP 
    PHD 
    REP #$20
    LDA $5A
    BEQ loc_03CEFB

  loc_03CED3:
    TCD 
    TAX 
    LDA $animScratch2, X
    AND #$0804
    CMP #$0804
    BNE code_03CEF7
    DEC $08
    BPL code_03CEF7
    STZ $08
    PHK 
    PEA $&code_03CEF7-1
    SEP #$20
    LDA $02
    PHA 
    REP #$20
    LDA $00
    DEC 
    PHA 
    RTL 
}

code_03CEF7 {
    LDA $06
    BNE loc_03CED3

  loc_03CEFB:
    PLD 
    PLP 
    RTL 
}

code_03CEFE {
    LDA $2C
    BEQ loc_03CF1D
    TAY 
    LDA $0002, Y
    STA $2C
    LDA $12
    BIT #$4000
    BEQ loc_03CF18
    LDA $0000, Y
    EOR #$FFFF
    INC 
    BRA loc_03CF32

  loc_03CF18:
    LDA $0000, Y
    BRA loc_03CF32

  loc_03CF1D:
    LDA $12
    BIT #$4000
    BEQ loc_03CF2E
    LDA $moveScratch1, X
    EOR #$FFFF
    INC 
    BRA loc_03CF32

  loc_03CF2E:
    LDA $moveScratch1, X

  loc_03CF32:
    CLC 
    ADC $14
    STA $14
    LDA #$0000
    STA $moveScratch1, X
    LDA $2E
    BEQ loc_03CF5D
    TAY 
    LDA $0002, Y
    STA $2E
    LDA $12
    BIT #$2000
    BEQ loc_03CF58
    LDA $0000, Y
    EOR #$FFFF
    INC 
    BRA loc_03CF72

  loc_03CF58:
    LDA $0000, Y
    BRA loc_03CF72

  loc_03CF5D:
    LDA $12
    BIT #$2000
    BEQ loc_03CF6E
    LDA $moveScratch2, X
    EOR #$FFFF
    INC 
    BRA loc_03CF72

  loc_03CF6E:
    LDA $moveScratch2, X

  loc_03CF72:
    CLC 
    ADC $16
    STA $16
    LDA #$0000
    STA $moveScratch2, X
    RTS 
}

code_03CF7F {
    LDA $cameraLowerYBound
    SEC 
    SBC #$0010
    STA $0004
    LDA $2C
    BEQ loc_03CF9A
    TAY 
    LDA $0000, Y
    BNE loc_03CFA0
    LDA $0002, Y
    STA $2C
    BRA loc_03D006

  loc_03CF9A:
    LDA $moveScratch1, X
    BEQ loc_03D006

  loc_03CFA0:
    STA $001A
    LDA $12
    BIT #$4000
    BEQ loc_03CFB4
    LDA $001A
    EOR #$FFFF
    INC 
    STA $001A

  loc_03CFB4:
    LDA $001A
    PEA $&code_03CFC2-1
    BPL loc_03CFBF
    JMP $&code_03D0A5

  loc_03CFBF:
    JMP $&code_03D128
}

code_03CFC2 {
    LDA $2C
    BEQ loc_03CFE3
    TAY 
    LDA $0002, Y
    STA $2C
    BCS loc_03D006
    LDA $12
    BIT #$4000
    BEQ loc_03CFDE
    LDA $0000, Y
    EOR #$FFFF
    INC 
    BRA loc_03CFFA

  loc_03CFDE:
    LDA $0000, Y
    BRA loc_03CFFA

  loc_03CFE3:
    BCS loc_03CFFF
    LDA $12
    BIT #$4000
    BEQ loc_03CFF6
    LDA $moveScratch1, X
    EOR #$FFFF
    INC 
    BRA loc_03CFFA

  loc_03CFF6:
    LDA $moveScratch1, X

  loc_03CFFA:
    CLC 
    ADC $14
    STA $14

  loc_03CFFF:
    LDA #$0000
    STA $moveScratch1, X

  loc_03D006:
    CLC 
    LDA $2E
    BEQ loc_03D018
    TAY 
    LDA $0000, Y
    BNE loc_03D01E
    LDA $0002, Y
    STA $2E
    BRA loc_03D084

  loc_03D018:
    LDA $moveScratch2, X
    BEQ loc_03D084

  loc_03D01E:
    STA $001E
    LDA $12
    BIT #$2000
    BEQ loc_03D032
    LDA $001E
    EOR #$FFFF
    INC 
    STA $001E

  loc_03D032:
    LDA $001E
    PEA $&code_03D040-1
    BPL loc_03D03D
    JMP $&code_03D25F

  loc_03D03D:
    JMP $&code_03D2E0
}

code_03D040 {
    LDA $2E
    BEQ loc_03D061
    TAY 
    LDA $0002, Y
    STA $2E
    BCS loc_03D084
    LDA $12
    BIT #$2000
    BEQ loc_03D05C
    LDA $0000, Y
    EOR #$FFFF
    INC 
    BRA loc_03D078

  loc_03D05C:
    LDA $0000, Y
    BRA loc_03D078

  loc_03D061:
    BCS loc_03D07D
    LDA $12
    BIT #$2000
    BEQ loc_03D074
    LDA $moveScratch2, X
    EOR #$FFFF
    INC 
    BRA loc_03D078

  loc_03D074:
    LDA $moveScratch2, X

  loc_03D078:
    CLC 
    ADC $16
    STA $16

  loc_03D07D:
    LDA #$0000
    STA $moveScratch2, X

  loc_03D084:
    LDA $10
    BIT #$0004
    BNE loc_03D08C
    RTS 

  loc_03D08C:
    LDA $extendedFlags, X
    BIT #$0040
    BNE loc_03D096
    RTS 

  loc_03D096:
    AND #$FFBF
    STA $extendedFlags, X
    LDA $12
    EOR #$6000
    STA $12
    RTS 
}

code_03D0A5 {
    PHB 
    CLC 
    ADC $14
    STA $0018
    LDA #$0000
    TCD 
    JSR $&code_03D411
    BCC loc_03D0B9
    PLB 
    TXA 
    TCD 
    RTS 

  loc_03D0B9:
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
    BMI loc_03D122
    CMP $cameraOffsetX
    BCC loc_03D122
    CMP $cameraBoundsX
    BCS loc_03D122
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
    JSL $@code_03D493
    STY $00

  loc_03D102:
    LDA [$80], Y
    BIT #$00F0
    BEQ loc_03D10C
    JMP $&code_03D1D7

  loc_03D10C:
    AND #$000F
    BNE loc_03D11C
    DEC $0E
    BEQ loc_03D11C
    JSR $&code_03D4BD
    STY $00
    BRA loc_03D102

  loc_03D11C:
    ASL 
    TXY 
    TAX 
    JMP ($&code_list_03D1B6, X)

  loc_03D122:
    PHA 
    LDA #$000F
    BRA loc_03D11C
}

code_03D128 {
    PHB 
    CLC 
    ADC $14
    STA $0018
    LDA #$0000
    TCD 
    JSR $&code_03D411
    BCC loc_03D13C
    PLB 
    TXA 
    TCD 
    RTS 

  loc_03D13C:
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
    BMI loc_03D122
    CMP $cameraOffsetX
    BCC loc_03D122
    CLC 
    ADC #$0010
    CMP $cameraBoundsX
    BCS loc_03D122
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
    JSL $@code_03D493
    STY $00

  loc_03D199:
    LDA [$80], Y
    BIT #$00F0
    BNE code_03D1D7
    AND #$000F
    BNE loc_03D1B0
    DEC $0E
    BEQ loc_03D1B0
    JSR $&code_03D4BD
    STY $00
    BRA loc_03D199

  loc_03D1B0:
    ASL 
    TXY 
    TAX 
    JMP ($&code_list_03D1B6, X)
}

code_list_03D1B6 [
  &code_03D24A   ;00
  &code_03D1D6   ;01
  &code_03D1D6   ;02
  &code_03D1D6   ;03
  &code_03D1D6   ;04
  &code_03D1D6   ;05
  &code_03D1D6   ;06
  &code_03D1D6   ;07
  &code_03D1D6   ;08
  &code_03D1D6   ;09
  &code_03D1D6   ;0A
  &code_03D1D6   ;0B
  &code_03D1D6   ;0C
  &code_03D1D6   ;0D
  &code_03D1D6   ;0E
  &code_03D1D6   ;0F
]

code_03D1D6 {
    TYX 
}

code_03D1D7 {
    TXA 
    TCD 
    LDA #$0004
    TSB $10
    LDA $001A
    BMI loc_03D20F
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

  loc_03D20F:
    LDA $metaspritePtr, X
    TAY 
    LDA $0000, Y
    ORA #$FF00
    CLC 
    ADC $14
    CLC 
    ADC $001A
    BIT #$000F
    BEQ loc_03D22D
    AND #$FFF0
    CLC 
    ADC #$0010

  loc_03D22D:
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

code_03D244 {
    TXA 
    TCD 
    PLA 
    PLB 
    CLC 
    RTS 
}

code_03D24A {
    TYX 
    LDA $01, S
    BIT #$000F
    BEQ code_03D244
    JSR $&code_03D4BD
    LDA [$80], Y
    AND #$00FF
    BEQ code_03D244
    JMP $&code_03D1D7
}

code_03D25F {
    PHB 
    CLC 
    ADC $16
    STA $001C
    LDA #$0000
    TCD 
    JSR $&code_03D411
    BCC loc_03D273
    PLB 
    TXA 
    TCD 
    RTS 

  loc_03D273:
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
    BMI loc_03D2DB
    CMP $cameraOffsetY
    BCC loc_03D2DB
    CMP $04
    BCS loc_03D2DB
    LSR 
    LSR 
    LSR 
    LSR 
    STA $1C
    JSL $@code_03D493
    STY $00

  loc_03D2BB:
    LDA [$80], Y
    BIT #$00F0
    BEQ loc_03D2C5
    JMP $&code_03D385

  loc_03D2C5:
    AND #$000F
    BNE loc_03D2D5
    DEC $0E
    BEQ loc_03D2D5
    JSR $&code_03D4D3
    STY $00
    BRA loc_03D2BB

  loc_03D2D5:
    ASL 
    TXY 
    TAX 
    JMP ($&code_list_03D365, X)

  loc_03D2DB:
    LDA #$000F
    BRA loc_03D2D5
}

code_03D2E0 {
    PHB 
    CLC 
    ADC $16
    STA $001C
    LDA #$0000
    TCD 
    JSR $&code_03D411
    BCC loc_03D2F4
    PLB 
    TXA 
    TCD 
    RTS 

  loc_03D2F4:
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
    BMI loc_03D2DB
    CMP $cameraOffsetY
    BCC loc_03D2DB
    CMP $04
    BCS loc_03D2DB
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
    JSL $@code_03D493
    STY $00

  loc_03D348:
    LDA [$80], Y
    BIT #$00F0
    BNE code_03D385
    AND #$000F
    BNE loc_03D35F
    DEC $0E
    BEQ loc_03D35F
    JSR $&code_03D4D3
    STY $00
    BRA loc_03D348

  loc_03D35F:
    ASL 
    TXY 
    TAX 
    JMP ($&code_list_03D365, X)
}

code_list_03D365 [
  &code_03D3F8   ;00
  &code_03D40D   ;01
  &code_03D40D   ;02
  &code_03D40D   ;03
  &code_03D40D   ;04
  &code_03D40D   ;05
  &code_03D40D   ;06
  &code_03D40D   ;07
  &code_03D40D   ;08
  &code_03D40D   ;09
  &code_03D40D   ;0A
  &code_03D40D   ;0B
  &code_03D40D   ;0C
  &code_03D40D   ;0D
  &code_03D40D   ;0E
  &code_03D40D   ;0F
]

code_03D385 {
    TXA 
    TCD 
    LDA #$0004
    TSB $10
    LDA $001E
    BMI loc_03D3BD
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

  loc_03D3BD:
    LDA $metaspritePtr, X
    TAY 
    LDA $0001, Y
    ORA #$FF00
    CLC 
    ADC $16
    CLC 
    ADC $001E
    BIT #$000F
    BEQ loc_03D3DB
    AND #$FFF0
    CLC 
    ADC #$0010

  loc_03D3DB:
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

code_03D3F2 {
    TXA 
    TCD 
    PLA 
    PLB 
    CLC 
    RTS 
}

code_03D3F8 {
    TYX 
    LDA $01, S
    BIT #$000F
    BEQ code_03D3F2
    JSR $&code_03D4D3
    LDA [$80], Y
    AND #$00FF
    BEQ code_03D3F2
    JMP $&code_03D385
}

code_03D40D {
    TYX 
    JMP $&code_03D385
}

code_03D411 {
    LDA $18
    PHA 
    LDA $1C
    PHA 
    LDA $0014, X
    SEC 
    SBC #$0008
    BIT #$000F
    BEQ loc_03D48B
    LSR 
    LSR 
    LSR 
    LSR 
    STA $18
    LDA $0016, X
    SEC 
    SBC #$0010
    BIT #$000F
    BEQ loc_03D48B
    LSR 
    LSR 
    LSR 
    LSR 
    STA $1C
    JSL $@code_03D493
    STY $00
    LDA [$80], Y
    AND #$00FF
    BEQ loc_03D461
    CMP #$0006
    BNE loc_03D48B
    JSR $&code_03D4BD
    STY $00
    JSR $&code_03D4D3
    LDA [$80], Y
    AND #$00FF
    CMP #$0006
    BNE loc_03D48B
    BRA loc_03D483

  loc_03D461:
    LDA $00
    STA $02
    JSR $&code_03D4D3
    LDA [$80], Y
    AND #$00FF
    CMP #$0009
    BNE loc_03D48B
    LDA $02
    STA $00
    JSR $&code_03D4BD
    LDA [$80], Y
    AND #$00FF
    CMP #$0009
    BNE loc_03D48B

  loc_03D483:
    PLA 
    STA $1C
    PLA 
    STA $18
    SEC 
    RTS 

  loc_03D48B:
    PLA 
    STA $1C
    PLA 
    STA $18
    CLC 
    RTS 
}

code_03D493 {
    PHP 
    LDA $1C
    ASL 
    ASL 
    ASL 
    ASL 
    PHA 
    SEP #$20
    LDA $mapRowStrideL0
    JSL $@chunk_028000.code_0282F6
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

code_03D4BD {
    PHP 
    LDA $00
    SEP #$20
    CLC 
    ADC #$10
    BCS loc_03D4CA
    TAY 
    PLP 
    RTS 

  loc_03D4CA:
    XBA 
    CLC 
    ADC $mapRowStrideL0
    XBA 
    TAY 
    PLP 
    RTS 
}

code_03D4D3 {
    PHP 
    SEP #$20
    LDA $00
    INC 
    BIT #$0F
    BEQ loc_03D4E5
    STA $00
    REP #$20
    LDY $00
    PLP 
    RTS 

  loc_03D4E5:
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

code_03D4F0 {
    PHP 
    REP #$20
    STZ $005A
    STZ $005C
    LDX $0646
    LDA $@scene_thinkers.t_scene_thinkers, X
    BEQ loc_03D538
    STA $3E
    LDA #$008C
    STA $40
    LDA [$3E]
    BIT #$0080
    BNE loc_03D538
    JSL $@code_03CB9B
    STY $005A
    BRA loc_03D52F

  loc_03D519:
    LDA [$3E]
    AND #$00FF
    CMP #$00FF
    BEQ loc_03D535
    JSL $@code_03CB9B
    TYA 
    STA $0006, X
    TXA 
    STA $0004, Y

  loc_03D52F:
    TYX 
    JSR $&code_03D53A
    BRA loc_03D519

  loc_03D535:
    STX $005C

  loc_03D538:
    PLP 
    RTL 
}

code_03D53A {
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

code_03D573 {
    PHP 
    REP #$20
    LDX #$0000
    TXA 

  loc_03D57A:
    STA $deathFlag, X
    INX 
    INX 
    CPX #$0200
    BNE loc_03D57A
    DEC 
    STA $deathFlag, X
    PLP 
    RTL 
}

code_03D58A {
    LDA $09FA
    BIT #$08
    BNE loc_03D592
    RTL 

  loc_03D592:
    AND #$F7
    STA $09FA
    LDA #$80
    STA $VMAIN
    LDA #$01
    STA $DMAP0
    LDA #$18
    STA $BBAD0
    LDA $06FE
    STA $A1B0
    LDY #$0001
    LDX #$4000
    STX $VMADDL
    JSR $&code_03D5E1
    CPY #$0011
    BNE loc_03D5C6
    LDX #$4200
    STX $VMADDL
    JSR $&code_03D5E1

  loc_03D5C6:
    LDY #$0001
    LDX #$4100
    STX $VMADDL
    JSR $&code_03D5FB
    CPY #$0011
    BNE loc_03D5E0
    LDX #$4300
    STX $VMADDL
    JSR $&code_03D5FB

  loc_03D5E0:
    RTL 
}

code_03D5E1 {
    LDX $06FE, Y
    BEQ loc_03D5FA
    STX $A1T0L
    LDA #$40
    STA $DAS0L
    LDA #$01
    STA $MDMAEN
    INY 
    INY 
    CPY #$0011
    BNE code_03D5E1

  loc_03D5FA:
    RTS 
}

code_03D5FB {
    REP #$20
    LDA $06FE, Y
    BEQ loc_03D61C
    CLC 
    ADC #$0200
    STA $A1T0L
    SEP #$20
    LDA #$40
    STA $DAS0L
    LDA #$01
    STA $MDMAEN
    INY 
    INY 
    CPY #$0011
    BNE code_03D5FB

  loc_03D61C:
    SEP #$20
    RTS 
}

code_03D61F {
    PHP 
    PHX 
    PHY 
    PHB 
    REP #$20
    AND #$0003
    XBA 
    ASL 
    TAX 
    LDA $sceneCurrent
    STA $0B06
    LDY #$0000
    PHX 

  loc_03D635:
    LDA $eventFlags, Y
    STA $306200, X
    INX 
    INX 
    INY 
    INY 
    CPY #$01FC
    BNE loc_03D635
    PLX 
    JSL $@code_03D6C1
    LDA $0018
    STA $3063FC, X
    LDA $001C
    STA $3063FE, X
    PLB 
    PLY 
    PLX 
    PLP 
    RTL 
}

code_03D65D {
    PHP 
    PHX 
    PHB 
    REP #$20
    AND #$0003
    XBA 
    ASL 
    TAX 
    JSL $@code_03D6C1
    LDA $0018
    CMP $3063FC, X
    BNE loc_03D698
    LDA $001C
    CMP $3063FE, X
    BNE loc_03D698
    LDY #$0000
    PHX 

  loc_03D682:
    LDA $306200, X
    STA $eventFlags, Y
    INX 
    INX 
    INY 
    INY 
    CPY #$01FC
    BNE loc_03D682
    PLX 
    PLB 
    PLX 
    PLP 
    CLC 
    RTL 

  loc_03D698:
    PLB 
    PLX 
    PLP 
    SEC 
    RTL 
}

code_03D69D {
    PHP 
    PHX 
    PHB 
    REP #$20
    AND #$0003
    XBA 
    ASL 
    TAX 
    LDY #$0000
    PHX 
    LDA #$0000

  loc_03D6AF:
    STA $306200, X
    INX 
    INX 
    INY 
    CPY #$0100
    BNE loc_03D6AF
    PLX 
    PLB 
    PLX 
    PLP 
    SEC 
    RTL 
}

code_03D6C1 {
    PHP 
    PHX 
    REP #$20
    LDA #$3652
    STA $0018
    STA $001C
    LDA #$00FE
    STA $000E

  loc_03D6D4:
    LDA $306200, X
    PHA 
    CLC 
    ADC $0018
    STA $0018
    PLA 
    EOR $001C
    STA $001C
    INX 
    INX 
    DEC $000E
    BNE loc_03D6D4
    PLX 
    PLP 
    RTL 
}

code_03D6F1 {
    LDA $0D52
    ORA $0D53
    BNE code_03D6FF
    LDA $sceneNext
    BNE code_03D6FF
    RTL 
}

code_03D6FF {
    LDA $worldReadyFlag
    BMI loc_03D70C
    BEQ loc_03D709
    JSR $&code_03D7C4

  loc_03D709:
    STZ $worldReadyFlag

  loc_03D70C:
    STZ $66
    JSL $@chunk_028000.code_0282C7
    JSL $@chunk_028000.code_0282E1
    LDA #$00
    XBA 
    LDA $0D52
    ORA $0D53
    BEQ loc_03D74A
    REP #$20
    LDA $0D52
    STA $0D54
    STZ $0D52
    LDA $0652
    STA $0D6C
    STZ $0652
    LDA #$0000
    SEP #$20
    LDA $sceneNext
    STA $0D6E
    LDA $sceneCurrent
    STA $0D6F
    LDA #$FE
    BRA loc_03D756

  loc_03D74A:
    LDA $sceneCurrent
    STA $0D6E
    STZ $0D6F
    LDA $sceneNext

  loc_03D756:
    STZ $sceneNext
    STA $sceneCurrent
    REP #$20
    ASL 
    STA $0646
    SEP #$20
    JSL $@code_03DA5F
    JSL $@code_03DBD4
    JSL $@chunk_008000.code_008217
    JSL $@chunk_028000.code_028168
    JSL $@chunk_028000.code_0282B6
    JSL $@chunk_028000.code_0282D4
    LDA $worldReadyFlag
    BNE loc_03D78A
    JSR $&code_03D99B
    LDX #$000F
    STX $worldReadyFlag

  loc_03D78A:
    LDX #$0000
    STX $gfxCacheIdxB
    STX $gfxCacheIdxA
    LDA $00B4
    BEQ loc_03D7BD

  loc_03D798:
    JSL $@chunk_008000.code_008122
    LDA $joypadCurrent
    ORA $0657
    ORA $joypadRaw
    ORA $0661
    BEQ loc_03D798
    STZ $00B4
    STZ $00B5
    JSL $@chunk_028000.code_02FC9A
    LDA #$01
    TSB $09FA
    JSL $@chunk_008000.code_008122

  loc_03D7BD:
    STZ $slopeCurvePtrA
    STZ $09BB
    RTL 
}

code_03D7C4 {
    LDA $gfxCacheIdxA
    BEQ loc_03D7D9
    DEC 
    BEQ loc_03D7FB
    DEC 
    BEQ loc_03D803
    DEC 
    BEQ loc_03D829
    DEC 
    BNE loc_03D7D8
    JMP $&code_03D8AD

  loc_03D7D8:
    RTS 

  loc_03D7D9:
    LDA #$0F
    STA $0DB6

  loc_03D7DE:
    LDA #$00
    XBA 
    LDA $gfxCacheIdxB
    TAX 

  loc_03D7E5:
    JSL $@chunk_008000.code_008122
    LDA $0DB6
    BEQ loc_03D7FA
    DEX 
    BPL loc_03D7E5
    STA $INIDISP
    DEC 
    STA $0DB6
    BPL loc_03D7DE

  loc_03D7FA:
    RTS 

  loc_03D7FB:
    JSL $@chunk_008000.code_008122
    STZ $INIDISP
    RTS 

  loc_03D803:
    LDA #$0F

  loc_03D805:
    PHA 
    LDA #$00
    XBA 
    LDA $gfxCacheIdxB
    TAX 
    PLA 

  loc_03D80E:
    JSL $@chunk_008000.code_008122
    DEX 
    BPL loc_03D80E
    STA $INIDISP
    PHA 
    EOR #$0F
    ASL 
    ASL 
    ASL 
    ASL 
    ORA #$03
    STA $MOSAIC
    PLA 
    DEC 
    BPL loc_03D805
    RTS 

  loc_03D829:
    PHA 
    PHA 
    LDA $0070
    BNE loc_03D838
    LDA #$06
    STA $0070
    STZ $006E

  loc_03D838:
    LDA $gfxCacheIdxB
    CMP #$08
    BCC loc_03D844
    LDA #$08
    STA $gfxCacheIdxB

  loc_03D844:
    ASL 
    ASL 
    ASL 
    ASL 
    SEC 
    SBC #$80
    EOR #$FF
    INC 
    STA $01, S

  loc_03D850:
    LDA $006E
    INC 
    STA $006E
    STA $00
    LDA $01, S
    DEC 
    STA $01, S
    BMI loc_03D86F
    PHA 
    JSL $@code_03DE2F
    LDA #$FF
    STA $6C
    PLA 
    JSR $&code_03D8FF
    BRA loc_03D850

  loc_03D86F:
    LDA #$0F
    STA $01, S

  loc_03D873:
    LDA $gfxCacheIdxB
    STA $02, S

  loc_03D878:
    LDA $006E
    STA $00
    PHA 
    JSL $@code_03DE2F
    LDA #$FF
    STA $6C
    PLA 
    JSR $&code_03D8FF
    INC 
    STA $006E
    LDA $02, S
    DEC 
    STA $02, S
    BNE loc_03D878
    LDA $01, S
    DEC 
    STA $01, S
    STA $INIDISP
    BNE loc_03D873
    LDA #$00
    STA $INIDISP
    PLA 
    PLA 
    STZ $0070
    STZ $006E
    RTS 
}

code_03D8AD {
    PHA 
    PHA 
    LDA $0070
    BNE loc_03D8BC
    LDA #$06
    STA $0070
    STZ $006E

  loc_03D8BC:
    LDA $gfxCacheIdxB
    STA $01, S
    LDA #$0F
    STA $02, S

  loc_03D8C5:
    INC $006E
    STA $00
    PHA 
    JSL $@code_03DE2F
    LDA #$FF
    STA $6C
    PLA 
    JSR $&code_03D8FF
    JSL $@chunk_008000.code_008122
    LDA $01, S
    DEC 
    STA $01, S
    BNE loc_03D8C5
    LDA $gfxCacheIdxB
    STA $01, S
    LDA $02, S
    DEC 
    STA $02, S
    STA $INIDISP
    BNE loc_03D8C5
    LDA #$00
    STA $INIDISP
    PLA 
    PLA 
    STZ $0070
    STZ $006E
    RTS 
}

code_03D8FF {
    PHA 
    JSR $&code_03D942
    REP #$20
    LDA $36
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
    COP [QueueHdmaChannel] ( #06, #$8800, #$0D7E )
    COP [QueueHdmaChannel] ( #07, #$8800, #$0F7E )
    JSL $@chunk_008000.code_008122
    PLA 
    RTS 
}

code_03D942 {
    PHP 
    SEP #$20
    LDX #$0000
    TXY 
    LDA $00
    BEQ loc_03D999
    LDA $006E
    STA $L_WRMPYA
    CLC 

  loc_03D955:
    LDA $&binary_01C36C.binary_01C43D, Y
    BPL loc_03D95B
    SEC 

  loc_03D95B:
    STA $L_WRMPYB
    NOP 
    NOP 
    NOP 
    NOP 
    LDA $RDMPYH
    BCC loc_03D979
    PHA 
    LDA #$FF
    STA $L_WRMPYB
    XBA 
    PLA 
    CLC 
    ADC $RDMPYL
    REP #$20
    BRA loc_03D97E

  loc_03D979:
    REP #$20
    AND #$00FF

  loc_03D97E:
    CLC 
    ADC $bg1ScrollH
    STA $sineTableA, X
    STA $sineTableB, X
    TYA 
    SEP #$20
    CLC 
    ADC $0070
    TAY 
    INX 
    INX 
    CPX #$0200
    BNE loc_03D955

  loc_03D999:
    PLP 
    RTS 
}

code_03D99B {
    LDA $0649
    BEQ loc_03D9AA
    DEC 
    BEQ loc_03D9CE
    DEC 
    BEQ loc_03D9D8
    DEC 
    BEQ loc_03DA00
    RTS 

  loc_03D9AA:
    LDA #$01
    STA $0DB6

  loc_03D9AF:
    LDA #$00
    XBA 
    LDA $064B
    TAX 

  loc_03D9B6:
    JSL $@chunk_008000.code_008122
    LDA $0DB6
    BEQ loc_03D9CD
    DEX 
    BPL loc_03D9B6
    STA $INIDISP
    INC 
    STA $0DB6
    CMP #$10
    BCC loc_03D9AF

  loc_03D9CD:
    RTS 

  loc_03D9CE:
    JSL $@chunk_008000.code_008122
    LDA #$0F
    STA $INIDISP
    RTS 

  loc_03D9D8:
    LDA #$00

  loc_03D9DA:
    PHA 
    LDA #$00
    XBA 
    LDA $064B
    TAX 
    PLA 

  loc_03D9E3:
    JSL $@chunk_008000.code_008122
    DEX 
    BPL loc_03D9E3
    STA $INIDISP
    PHA 
    EOR #$0F
    ASL 
    ASL 
    ASL 
    ASL 
    ORA #$03
    STA $MOSAIC
    PLA 
    INC 
    CMP #$10
    BCC loc_03D9DA
    RTS 

  loc_03DA00:
    LDA $0070
    BNE loc_03DA0F
    LDA #$06
    STA $0070
    LDA #$80
    STA $006E

  loc_03DA0F:
    LDA #$00
    PHA 

  loc_03DA12:
    LDA $064B

  loc_03DA15:
    DEC $006E
    BEQ loc_03DA3F
    STA $00
    PHA 
    JSL $@code_03DE2F
    LDA #$FF
    STA $6C
    PLA 
    JSR $&code_03D8FF
    DEC 
    BNE loc_03DA15
    LDA $01, S
    INC 
    CMP #$0F
    BCC loc_03DA35
    LDA #$0F

  loc_03DA35:
    STA $INIDISP
    STA $01, S
    BRA loc_03DA12

  loc_03DA3C:
    LDA $064B

  loc_03DA3F:
    JSL $@chunk_008000.code_008122
    DEC 
    BNE loc_03DA3F
    LDA $01, S
    CMP #$0F
    BEQ loc_03DA54
    INC 
    STA $INIDISP
    STA $01, S
    BRA loc_03DA3C

  loc_03DA54:
    STA $INIDISP
    PLA 
    STZ $0070
    STZ $006E
    RTS 
}

code_03DA5F {
    STZ $HDMAEN
    LDX #$0000
    STX $joypadMaskInv
    STX $cachedPrevHp
    STX $cachedPrevMaxHp
    STX $09FA
    STX $slopeCurvePtrB
    STX $eventFlags
    STX $cameraDeltaX
    STX $cameraTargetX
    STX $cameraDeltaY
    STX $cameraTargetY
    STX $scrollOverrideH
    STX $forcedScrollOverride
    STX $scrollOverrideV
    STX $06CC
    STX $bg2ScrollH
    STX $savedCameraDelta
    STX $bg1ScrollH
    STX $bg1ScrollV
    STX $09C0
    STX $decelCurvePtr
    STX $extVelocityX
    STX $extVelocityY
    STX $enemyHealthTimer
    STX $0AEC
    STX $0AEE
    STX $09EE
    STX $09DA
    STX $09DC
    STX $00B2
    STX $0C07
    STX $dmaSkipFlag
    STX $00EA
    DEX 
    STX $invincibilityTimer
    LDA #$00
    STA $backdropColors
    STA $7F0C01
    STA $7F0C02
    LDA #$E0
    STA $COLDATA
    LDA #$78
    STA $BG3SC
    STZ $BG3HOFS
    STZ $BG3HOFS
    STZ $BG3VOFS
    STZ $BG3VOFS
    LDA $0A1F
    AND #$7F
    STA $0A1F
    LDA #$01
    STA $enemyHealthTimer
    LDA #$22
    STA $BG12NBA
    STZ $MOSAIC
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
    LDA #$E0
    STA $COLDATA
    JSL $@chunk_028000.code_02FCBC
    JSL $@chunk_028000.code_02FCA6
    JSL $@chunk_028000.code_0284E0
    JSL $@code_03DD39
    JSL $@chunk_028000.code_02A219
    JSL $@chunk_028000.code_02A620
    LDX #$0000
    STX $joypadMaskStd
    STX $joypadCurrent
    STX $joypadRaw
    JSL $@code_03CAE8
    JSL $@code_03CBAD
    JSL $@chunk_028000.code_02A189
    JSL $@code_03D4F0
    JSL $@code_03DCA7
    JSL $@code_03DCE9
    JSL $@code_03D573
    JSL $@chunk_028000.code_02A97E
    JSL $@code_03C801
    JSL $@code_03C801
    JSL $@code_03DE2F
    JSL $@code_03CE36
    JSL $@code_03CE66
    JSL $@code_03DE2F
    STZ $HDMAEN
    COP [SetFlagByte] ( #FF )
    LDA #$FF
    STA $oamComposeBuffer
    STA $7F3101
    JSL $@code_03C308
    JSL $@code_03C41D
    JSL $@code_03D58A
    LDA $scrollModeFlags
    BIT #$08
    BEQ loc_03DBA9
    JSL $@chunk_028000.code_028A9B
    BRA loc_03DBC1

  loc_03DBA9:
    LDA $069B
    BEQ loc_03DBB5
    LDX #$0000
    JSL $@chunk_028000.code_02ABB1

  loc_03DBB5:
    LDA $069D
    BEQ loc_03DBC1
    LDX #$0002
    JSL $@chunk_028000.code_02ABB1

  loc_03DBC1:
    STZ $musicRoomGroup
    LDX #$0000
    STX $effectDeltaX
    STX $effectDeltaY
    STX $06E8
    STX $06EA
    RTL 
}

code_03DBD4 {
    LDA $09FB
    BIT #$40
    BEQ loc_03DBDC
    RTL 

  loc_03DBDC:
    PHP 
    REP #$20
    PHB 
    PHK 
    PLB 
    LDY #$0000
    TYX 

  loc_03DBE6:
    LDA $&code_03DC11, Y
    BNE loc_03DBFE
    LDA $&code_03DC11+2, Y
    BEQ loc_03DC08
    INY 
    INY 
    INY 
    INY 
    ASL 
    STA $0E
    TXA 
    CLC 
    ADC $0E
    TAX 
    BRA loc_03DBE6

  loc_03DBFE:
    STA $7F0200, X
    INX 
    INX 
    INY 
    INY 
    BRA loc_03DBE6

  loc_03DC08:
    LDA #$0001
    TSB $09FA
    PLB 
    PLP 
    RTL 
}

code_03DC11 {
    BRK #$00
    ORA $340E00
    ORA $000034
    BPL loc_03DC1D

  loc_03DC1D:
    DEC $&parallax_table.binary_01CEE6+46
    BIT $0000
    PHP 
    BRK #$EF
    CPX $2CDA
    STP 
    BIT $2CDC
    ASL $1F34, X
    BIT $DC, X
    JMP ($6CDB)
    PHX 
    JMP ($&overworld_routes.code_03ACEF)
}

code_03DC39 {
    BRK #$00
    PHP 
    BRK #$CF
    JMP ($6CCE)
    BRK #$00
    COP [GenHdmaSine]
    DEC $002C, X
    BRK #$0A
    BRK #$EA
    BIT $2CD9
    BRK #$00
    ORA ($00, X)
    SBC $&01ED2C
    JMP ($0000)
    COP [GenHdmaSine]
    NOP 
    JMP ($0000)
    ASL 
    BRK #$DE
    JMP ($0000)
    COP [GenHdmaSine]
    INC $002C
    BRK #$0A
    BRK #$FA
    BIT $2CFB
    JSR ($&code_list_03FD2C, X)
    BIT $6CFD
    SBC #$2C
    XCE 
    JMP ($6CFA)
    BRK #$00
    ASL 
    BRK #$EE
    JMP ($0000)
    COP [GenHdmaSine]
    INC $&01EF2C, X
    BIT $0000
    PHP 
    BRK #$CF
    CPX $&01ECCE
    BRK #$00
    ASL $00
    DEC $&parallax_table.binary_01CEE6+C6
    LDY $0000
    PHP 
    BRK #$EF
    JMP ($6CFE)
    BRK #$00
    BRK #$00
}

code_03DCA7 {
    PHP 
    REP #$20
    COP [CopyPalette] ( @fx_palette_198040, #01, #01, #17 )
    LDA $sceneCurrent
    CMP #$00F0
    BEQ loc_03DCE7
    LDA $sceneCurrent
    CMP #$00FF
    BEQ loc_03DCE7
    COP [CopyPalette] ( @fx_palette_198020, #00, #90, #10 )
    LDY #$0B40
    LDA $slopeCurvePtrB
    BIT #$0008
    BEQ loc_03DCE7
    SEP #$20
    LDA #$99
    LDX #$8000
    STA $0405
    REP #$20
    LDA #$001F
    JSR $0402

  loc_03DCE7:
    PLP 
    RTL 
}

code_03DCE9 {
    PHP 
    LDA $sceneCurrent
    CMP #$F7
    BEQ loc_03DD37
    LDX #$4200
    STX $VMADDL
    LDX #$0000
    LDA #$C0
    LDY #$1C00
    JSL $@chunk_028000.code_0284C7
    LDA $slopeCurvePtrB
    BIT #$08
    BEQ loc_03DD1E
    LDX #$4400
    STX $VMADDL
    LDX #$D580
    LDA #$9C
    LDY #$0800
    JSL $@chunk_028000.code_0284C7
    PLP 
    RTL 

  loc_03DD1E:
    LDA $sceneCurrent
    CMP #$E8
    BNE loc_03DD37
    LDX #$4400
    STX $VMADDL
    LDX #$CA80
    LDA #$9C
    LDY #$0600
    JSL $@chunk_028000.code_0284C7

  loc_03DD37:
    PLP 
    RTL 
}

code_03DD39 {
    LDX $0652
    BNE loc_03DD58
    LDX $mapBoundsX
    STX $cameraBoundsX
    LDX $mapBoundsY
    STX $cameraBoundsY
    STX $cameraLowerYBound
    LDX #$0000
    STX $cameraOffsetX
    STX $cameraOffsetY
    BRA loc_03DD7D

  loc_03DD58:
    LDA $0652
    PHA 
    AND #$0F
    STA $cameraOffsetX+1
    PLA 
    LSR 
    LSR 
    LSR 
    LSR 
    STA $cameraOffsetY+1
    LDA $0653
    PHA 
    AND #$0F
    STA $cameraBoundsX+1
    PLA 
    LSR 
    LSR 
    LSR 
    LSR 
    STA $cameraBoundsY+1
    STA $06DF

  loc_03DD7D:
    STZ $cameraBoundsY
    STZ $cameraLowerYBound
    REP #$20
    STZ $0652
    LDA #$0100
    SEC 
    SBC $06EC
    CLC 
    ADC $cameraBoundsY
    STA $cameraBoundsY
    SEP #$20
    RTL 
}

code_03DD99 {
    PHP 
    PHB 
    SEP #$20
    LDA #$96
    PHA 
    PLB 
    REP #$20
    LDA $animScratch+2, X
    ASL 
    TAY 
    LDA $&palette_bundles, Y
    PHA 
    LDA $0E
    ASL 
    CLC 
    ADC $0E
    ASL 
    CLC 
    ADC $01, S
    PLY 
    TAY 
    LDA $0000, Y
    AND #$00FF
    BEQ loc_03DE08
    STA $spritesetPtr, X
    LDA $0001, Y
    STA $chatPtr, X
    LDA $0003, Y
    AND #$00FF
    ASL 
    CLC 
    ADC #$0A00
    STA $metaspritePtr, X
    LDA $0004, Y
    AND #$00FF
    STA $7F0008, X
    PHA 
    LDA $0005, Y
    AND #$00FF
    STA $08
    STA $animScratch, X
    INC $0E
    PLA 
    CMP #$0002
    BNE loc_03DE04
    LDA $7F000D, X
    INC 
    INC 
    STA $7F000D, X

  loc_03DE04:
    PLB 
    PLP 
    CLC 
    RTL 

  loc_03DE08:
    STZ $0E
    PLB 
    PLP 
    SEC 
    RTL 
}

code_03DE0E {
    PHX 
    LDA #$967F
    STA $0404
    LDA $7F0008, X
    PHA 
    LDA $metaspritePtr, X
    TAY 
    LDA $chatPtr, X
    TAX 
    PLA 
    JSR $0402
    TXA 
    PLX 
    STA $chatPtr, X
    RTL 
}

code_03DE2F {
    LDA $6C
    BMI loc_03DE3D
    STZ $66
    LDA #$02
    STA $68
    LDA #$10
    STA $6A

  loc_03DE3D:
    STZ $6C
    RTL 
}

code_03DE40 {
    PHP 
    PHX 
    SEP #$20
    PHA 
    LDA #$00
    XBA 
    PHA 
    TAX 
    LDA $&binary_01D8E7, X
    LDX $006A
    ORA #$40
    STA $DMAP0, X
    LDA $02, S
    STA $DASB0, X
    BRA loc_03DE6F
}

code_03DE5C {
    PHP 
    PHX 
    SEP #$20
    PHA 
    LDA #$00
    XBA 
    PHA 
    TAX 
    LDA $&binary_01D8E7, X
    LDX $006A
    STA $DMAP0, X

  loc_03DE6F:
    PLA 
    STA $BBAD0, X
    REP #$20
    TYA 
    STA $A1T0L, X
    SEP #$20
    PLA 
    STA $A1B0, X
    LDA $0068
    TSB $0066
    ASL $0068
    LDA $006A
    ADC #$10
    STA $006A
    PLX 
    PLP 
    RTL 
}

code_03DE93 {
    SEP #$20
    LDA #$F1
    STA $APUIO0
    REP #$20
    COP [SetEntryExit]
    LDA $APUIO0
    AND #$00FF
    CMP #$00F1
    BEQ loc_03DEAA
    RTL 

  loc_03DEAA:
    SEP #$20
    LDA #$01
    STA $APUIO0
    REP #$20
    COP [SetEntryExit]
    SEP #$20
    LDA $APUIO0
    REP #$20
    BEQ code_03DEBF
    RTL 
}

code_03DEBF {
    SEP #$20
    LDA #$F0
    STA $APUIO0
    REP #$20
    COP [SetEntryExit]
    SEP #$20
    LDA $APUIO0
    REP #$20
    BEQ loc_03DED4
    RTL 

  loc_03DED4:
    COP [SetEntryExit]
    SEP #$20
    LDA #$FF
    STA $APUIO0
    REP #$20
    LDA $chatPtr, X
    STA $musicTransitionState
    COP [SetEntryExit]
    LDA $musicTransitionState
    CMP #$FFFF
    BEQ loc_03DEF1
    RTL 

  loc_03DEF1:
    COP [WaitByte] ( #01 )
    SEP #$20
    LDA #$01
    STA $APUIO0
    REP #$20
    COP [SetEntryExit]
    STZ $sfxQueueCh1
    STZ $musicTransitionState
    COP [Die]
}

code_03DF07 {
    LDX $musicTransitionState
    BEQ loc_03DF3D
    BMI loc_03DF3D
    REP #$20
    TXA 
    ASL 
    CLC 
    ADC $musicTransitionState
    TAX 
    LDA $@string_templates.widestring_01CB8C+M, X
    STA $46
    STA $0687
    LDA $@string_templates.widestring_01CB8C+M, X
    STA $47
    STA $0688
    JSL $@chunk_028000.code_0282B6
    JSL $@chunk_028000.code_02915C
    JSL $@chunk_028000.code_0282C7
    LDA #$FFFF
    STA $musicTransitionState
    SEP #$20

  loc_03DF3D:
    RTL 
}

code_03DF3E {
    PHP 
    PHB 

  loc_03DF40:
    SEP #$20
    LDA $0000, Y
    INY 
    CMP #$10
    BCS loc_03DF58
    REP #$20
    PHX 
    AND #$00FF
    ASL 
    TAX 
    JSR ($&code_list_03DF83, X)
    PLX 
    BRA loc_03DF40

  loc_03DF58:
    STA $7F0200, X
    XBA 
    LDA $09AD
    STA $7F0201, X
    INX 
    INX 
    XBA 
    LDA $0000, Y
    CMP #$26
    BEQ loc_03DF74
    CMP #$27
    BEQ loc_03DF74
    BRA loc_03DF40

  loc_03DF74:
    STA $7F01BE, X
    XBA 
    LDA $09AD
    STA $7F01BF, X
    INY 
    BRA loc_03DF40
}

code_list_03DF83 [
  &code_03E113   ;00
  &code_03E1C1   ;01
  &code_03E1CC   ;02
  &code_03E1EC   ;03
  &code_03E1FD   ;04
  &code_03E230   ;05
  &code_03E2A4   ;06
  &code_03E366   ;07
  &code_03E3B6   ;08
  &code_03E3FF   ;09
  &code_03DFDC   ;0A
  &code_03E0BD   ;0B
  &code_03E3E0   ;0C
  &code_03E118   ;0D
  &code_03E125   ;0E
  &code_03DFA3   ;0F
]

code_03DFA3 {
    PHY 
    LDA $05, S
    STA $00
    TAX 
    LDA $0000, Y
    AND #$FF
    BRK #$85
    ASL $1085
    LDA $0001, Y
    STA $12

  loc_03DFB8:
    LDA #$00
    BRK #$9F
    BRK #$02
    ADC $@06E8E8, X
    BPL loc_03DFD4
    INC $C6, X
    ORA ($30)
    ORA $1800A5
    ADC #$40
    BRK #$85
    BRK #$AA
    LDA $0E

  loc_03DFD4:
    STA $10
    BRA loc_03DFB8

  loc_03DFD8:
    PLY 
    INY 
    INY 
    RTS 
}

code_03DFDC {
    PHY 
    STZ $08
    LDA $playerMaxHp
    CMP #$29
    BRK #$30
    TRB $A9
    PLP 
    BRK #$8D
    DEX 
    ASL 
    LDA $playerHp
    CMP #$0029
    BMI loc_03DFFB
    LDA #$0028
    STA $playerHp

  loc_03DFFB:
    LDA $playerHp
    LSR 
    STA $00
    BCC loc_03E005
    INC $08

  loc_03E005:
    ASL 
    CLC 
    ADC $08
    SEC 
    SBC $playerMaxHp
    EOR #$FFFF
    INC 
    LSR 
    STA $02
    LDA $08
    CLC 
    ADC $02
    CLC 
    ADC $00
    ASL 
    SEC 
    SBC $playerMaxHp
    BCS loc_03E025
    INC $02

  loc_03E025:
    LDA #$0800
    STA $0004
    LDA $05, S
    JSR $&code_03E032
    PLY 
    RTS 
}

code_03E032 {
    TAX 
    LDY #$000A
    STZ $06
    LDA $00
    BEQ loc_03E054
    LDA #$2006
    ORA $0004

  loc_03E042:
    STA $7F0200, X
    INX 
    INX 
    DEY 
    BNE loc_03E04E
    JSR $&code_03E0A7

  loc_03E04E:
    DEC $00
    BEQ loc_03E054
    BRA loc_03E042

  loc_03E054:
    LDA $08
    BEQ loc_03E069
    LDA #$2007
    ORA $04
    STA $7F0200, X
    INX 
    INX 
    DEY 
    BNE loc_03E069
    JSR $&code_03E0A7

  loc_03E069:
    LDA $02
    BEQ loc_03E084
    LDA #$20FF
    ORA $04

  loc_03E072:
    STA $7F0200, X
    INX 
    INX 
    DEY 
    BNE loc_03E07E
    JSR $&code_03E0A7

  loc_03E07E:
    DEC $02
    BEQ loc_03E084
    BRA loc_03E072

  loc_03E084:
    LDA $06
    BNE loc_03E09A
    LDA #$0000

  loc_03E08B:
    STA $7F0200, X
    INX 
    INX 
    DEY 
    BNE loc_03E08B
    JSR $&code_03E0A7
    LDY #$000A

  loc_03E09A:
    LDA #$0000

  loc_03E09D:
    STA $7F0200, X
    INX 
    INX 
    DEY 
    BNE loc_03E09D
    RTS 
}

code_03E0A7 {
    PHA 
    TXA 
    CLC 
    ADC #$002C
    TAX 
    STA $06
    CMP #$0100
    BCS loc_03E0BA
    PLA 
    LDY #$000A
    RTS 

  loc_03E0BA:
    PLA 
    PLA 
    RTS 
}

code_03E0BD {
    PHY 
    STZ $0008
    LDA $09F2
    CMP #$0029
    BMI loc_03E0DD
    LDA #$0028
    STA $09F2
    LDA $playerActorDp
    CMP #$0029
    BMI loc_03E0DD
    LDA #$0028
    STA $playerActorDp

  loc_03E0DD:
    LDA $playerActorDp
    LSR 
    STA $00
    BCC loc_03E0E7
    INC $08

  loc_03E0E7:
    ASL 
    CLC 
    ADC $08
    SEC 
    SBC $09F2
    EOR #$FFFF
    INC 
    LSR 
    STA $02
    LDA $08
    CLC 
    ADC $02
    CLC 
    ADC $00
    ASL 
    SEC 
    SBC $09F2
    BCS loc_03E107
    INC $02

  loc_03E107:
    LDA #$0400
    STA $04
    LDA $05, S
    JSR $&code_03E032
    PLY 
    RTS 
}

code_03E113 {
    PLA 
    PLX 
    PLB 
    PLP 
    RTL 
}

code_03E118 {
    LDA $playerFlags
    CLC 
    ADC #$0080
    STA $playerFlags
    STA $03, S
    RTS 
}

code_03E125 {
    PHY 
    LDA $05, S
    TAX 
    STZ $0006
    STZ $0000
    LDA $joypadInject
    ORA #$0030
    STA $0004
    LDA $0000, Y
    TAY 
    LDA $0000, Y
    SEC 

  loc_03E140:
    INC $0000
    SBC #$0064
    BCS loc_03E140
    ADC #$0064
    STA $0002
    LDA $0000
    DEC 
    CMP #$0009
    BCC loc_03E15A
    LDA #$0009

  loc_03E15A:
    BIT #$000F
    BEQ loc_03E167
    ORA $0004
    INC $0006
    BRA loc_03E16A

  loc_03E167:
    LDA #$2000

  loc_03E16A:
    STZ $0000
    LDA $0002
    SEC 

  loc_03E171:
    INC $0000
    SBC #$000A
    BCS loc_03E171
    ADC #$000A
    STA $0002
    LDA $0000
    DEC 
    BNE loc_03E192
    LDA $0006
    BNE loc_03E18F
    LDA #$2000
    BRA loc_03E195

  loc_03E18F:
    LDA #$0000

  loc_03E192:
    ORA $0004

  loc_03E195:
    STZ $0000
    STA $7F0200, X
    INX 
    INX 
    LDA $0002
    SEC 

  loc_03E1A2:
    INC $0000
    SBC #$0001
    BCS loc_03E1A2
    LDA $0000
    DEC 
    ORA $0004
    STZ $0000
    STA $7F0200, X
    INX 
    INX 
    TXA 
    STA $05, S
    PLY 
    INY 
    INY 
    RTS 
}

code_03E1C1 {
    LDA $0000, Y
    INY 
    INY 
    STA $playerFlags
    STA $03, S
    RTS 
}

code_03E1CC {
    LDA $03, S
    TAX 
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
    JSL $@code_03DF3E
    PLB 
    PLY 
    INY 
    INY 
    INY 
    TXA 
    STA $03, S
    RTS 
}

code_03E1EC {
    SEP #$20
    LDA $09AD
    AND #$E3
    ORA $0000, Y
    INY 
    STA $09AD
    REP #$20
    RTS 
}

code_03E1FD {
    PHY 
    PHB 
    LDX $0003, Y
    LDA $0000, X
    ASL 
    PHA 
    LDA $0000, Y
    PHA 
    SEP #$20
    LDA $0002, Y
    PHA 
    PLB 
    REP #$20
    PLA 
    CLC 
    ADC $01, S
    TAY 
    PLA 
    LDA $0000, Y
    TAY 
    LDA $06, S
    TAX 
    JSL $@code_03DF3E
    PLB 
    PLA 
    CLC 
    ADC #$0005
    TAY 
    TXA 
    STA $03, S
    RTS 
}

code_03E230 {
    LDA $03, S
    TAX 
    PHY 
    LDA $0000, Y
    AND #$00FF
    STA $000E
    STA $0010
    ASL 
    PHX 
    CLC 
    ADC $01, S
    STA $01, S
    TAX 
    LDA $0001, Y
    TAY 
    LDA $joypadInject
    SEP #$20

  loc_03E251:
    LDA $0000, Y
    AND #$0F
    ORA #$30
    REP #$20
    DEX 
    DEX 
    STA $7F0200, X
    SEP #$20
    DEC $000E
    BEQ loc_03E282
    LDA $0000, Y
    INY 
    AND #$F0
    LSR 
    LSR 
    LSR 
    LSR 
    ORA #$30
    REP #$20
    DEX 
    DEX 
    STA $7F0200, X
    SEP #$20
    DEC $000E
    BNE loc_03E251

  loc_03E282:
    DEC $0010
    BEQ loc_03E299
    LDA $7F0200, X
    CMP #$30
    BNE loc_03E299
    LDA #$20
    STA $7F0200, X
    INX 
    INX 
    BRA loc_03E282

  loc_03E299:
    REP #$20
    PLX 
    PLY 
    INY 
    INY 
    INY 
    TXA 
    STA $03, S
    RTS 
}

code_03E2A4 {
    PHY 
    LDA $0000, Y
    AND #$00FF
    STA $0000
    LDA $0001, Y
    AND #$00FF
    STA $0002
    LDA $0002, Y
    TAX 
    PHA 
    LDA $joypadInject
    ORA #$0010
    STA $7F0200, X
    LDA $0000
    STA $000E
    LDA $joypadInject
    ORA #$0011

  loc_03E2D2:
    STA $7F0202, X
    INX 
    INX 
    DEC $000E
    BNE loc_03E2D2
    LDA $joypadInject
    ORA #$4010
    STA $7F0202, X
    LDA $01, S
    CLC 
    ADC #$0040
    TAX 
    LDA $0002
    STA $000E

  loc_03E2F4:
    PHX 
    LDA $joypadInject
    ORA #$0012
    STA $7F0200, X
    LDA $0000
    STA $0010
    LDA $joypadInject
    ORA #$0020

  loc_03E30B:
    STA $7F0202, X
    INX 
    INX 
    DEC $0010
    BNE loc_03E30B
    LDA $joypadInject
    ORA #$4012
    STA $7F0202, X
    PLA 
    CLC 
    ADC #$0040
    TAX 
    DEC $000E
    BNE loc_03E2F4
    LDA $joypadInject
    ORA #$8010
    STA $7F0200, X
    LDA $0000
    STA $000E
    LDA $joypadInject
    ORA #$8011

  loc_03E341:
    STA $7F0202, X
    INX 
    INX 
    DEC $000E
    BNE loc_03E341
    LDA $joypadInject
    ORA #$C010
    STA $7F0202, X
    PLA 
    PLY 
    CLC 
    ADC #$0082
    STA $playerFlags
    STA $03, S
    INY 
    INY 
    INY 
    INY 
    RTS 
}

code_03E366 {
    PHY 
    LDA $0000, Y
    TAX 
    STZ $0000
    SEP #$20
    PHX 

  loc_03E371:
    LDA $7F0200, X
    BEQ loc_03E37E
    INX 
    INX 
    INC $0000
    BRA loc_03E371

  loc_03E37E:
    DEC $0000
    REP #$20
    PLX 

  loc_03E384:
    LDA $0000
    STA $000E
    PHX 
    LDA #$0000

  loc_03E38E:
    STA $7F0200, X
    INX 
    INX 
    DEC $000E
    BNE loc_03E38E
    LDA $7F0200, X
    TAY 
    LDA #$0000
    STA $7F0200, X
    PLX 
    TXA 
    CLC 
    ADC #$0040
    TAX 
    LDA $7F0200, X
    BNE loc_03E384
    PLY 
    INY 
    INY 
    RTS 
}

code_03E3B6 {
    PHY 
    LDA $0001, Y
    TAX 
    LDA $0000, X
    PHA 
    LDA $07, S
    TAX 
    LDA $joypadInject
    SEP #$20
    LDA $0000, Y
    REP #$20
    PLY 
    BEQ loc_03E3D8

  loc_03E3CF:
    STA $7F0200, X
    INX 
    INX 
    DEY 
    BNE loc_03E3CF

  loc_03E3D8:
    PLY 
    INY 
    INY 
    INY 
    TXA 
    STA $03, S
    RTS 
}

code_03E3E0 {
    LDA $03, S
    TAX 

  loc_03E3E3:
    LDA $0000, Y
    AND #$00FF
    CMP #$00FF
    BEQ loc_03E3FA
    ORA $joypadInject
    STA $7F0200, X
    INX 
    INX 
    INY 
    BRA loc_03E3E3

  loc_03E3FA:
    INY 
    TXA 
    STA $03, S
    RTS 
}

code_03E3FF {
    LDA $03, S
    TAX 
    LDA #$0000
    PHA 
    PHY 

  loc_03E407:
    SEP #$20
    LDA $0000, Y
    BMI loc_03E44B
    REP #$20
    AND #$00FF
    CMP #$0008
    BCS loc_03E41E
    ASL 
    ORA #$01E0
    BRA loc_03E426

  loc_03E41E:
    SEC 
    SBC #$0008
    ASL 
    ORA #$02E0

  loc_03E426:
    ORA $joypadInject
    INX 
    INX 
    STA $7F01BE, X
    INC 
    STA $7F01C0, X
    CLC 
    ADC #$000F
    STA $7F01FE, X
    INC 
    STA $7F0200, X
    INX 
    INX 
    INY 
    LDA $01, S
    INC 
    STA $01, S
    BRA loc_03E407

  loc_03E44B:
    REP #$20
    PLA 
    CLC 
    ADC $01, S
    INC 
    TAY 
    PLA 
    TXA 
    STA $03, S
    RTS 
}

code_03E458 {
    PHP 
    SEP #$20
    BIT #$80
    BNE loc_03E474
    PHA 
    LDY #$0000

  loc_03E463:
    LDA $inventorySlots, Y
    BNE loc_03E46B
    JMP $&code_03E531

  loc_03E46B:
    INY 
    CPY #$0010
    BNE loc_03E463
    JMP $&code_03E541

  loc_03E474:
    SEC 
    SBC #$80
    BEQ loc_03E4CD
    DEC 
    BEQ loc_03E4F3
    DEC 
    BNE loc_03E482
    JMP $&code_03E512

  loc_03E482:
    DEC 
    BEQ loc_03E4AA
    DEC 
    BEQ loc_03E4AE
    DEC 
    BEQ loc_03E4B2
    REP #$20
    LDA #$0005
    CLC 
    ADC $damageFlashTimer
    STA $damageFlashTimer
    PHD 
    TXA 
    TCD 
    COP [SpawnLastRel] ( @chunk_008000.code_00DE22, #00, #00, #$2F00 )
    PLD 
    COP [PlaySoundCh2] ( #22 )
    JMP $&code_03E53E

  loc_03E4AA:
    LDA #$01
    BRA loc_03E4B4

  loc_03E4AE:
    LDA #$02
    BRA loc_03E4B4

  loc_03E4B2:
    LDA #$05

  loc_03E4B4:
    REP #$20
    AND #$00FF
    CLC 
    ADC $gemCount
    CMP #$03E7
    BCC loc_03E4C5
    LDA #$03E7

  loc_03E4C5:
    STA $gemCount
    COP [PlaySoundCh2] ( #22 )
    BRA code_03E53E

  loc_03E4CD:
    REP #$20
    LDA #$0080
    TRB $09FA
    SEP #$20
    COP [PlaySoundCh2] ( #25 )
    LDA $playerMaxHp
    CLC 
    ADC #$01
    BVC loc_03E4E4
    LDA #$55

  loc_03E4E4:
    STA $playerMaxHp
    SEC 
    SBC $playerHp
    STA $damageFlashTimer
    LDY #$0000
    BRA code_03E53E

  loc_03E4F3:
    REP #$20
    LDA #$0080
    TRB $09FA
    SEP #$20
    COP [PlaySoundCh2] ( #25 )
    LDA $playerStr
    CLC 
    ADC #$01
    BVC loc_03E50A
    LDA #$55

  loc_03E50A:
    STA $playerStr
    LDY #$0000
    BRA code_03E53E
}

code_03E512 {
    REP #$20
    LDA #$0080
    TRB $09FA
    SEP #$20
    COP [PlaySoundCh2] ( #25 )
    LDA $playerDef
    CLC 
    ADC #$01
    BVC loc_03E529
    LDA #$55

  loc_03E529:
    STA $playerDef
    LDY #$0000
    BRA code_03E53E
}

code_03E531 {
    PLA 
    STA $inventorySlots, Y
    STA $0DB8
    STZ $0DB9
    LDY #$E991
}

code_03E53E {
    PLP 
    CLC 
    RTL 
}

code_03E541 {
    PLA 
    STA $0DB8
    STZ $0DB9
    LDY #$E974
    PLP 
    SEC 
    RTL 
}

code_03E54E {
    PHP 
    SEP #$20
    LDY #$0000

  loc_03E554:
    CMP $inventorySlots, Y
    BEQ loc_03E561
    INY 
    CPY #$0010
    BNE loc_03E554
    BRA loc_03E572

  loc_03E561:
    LDA #$00
    STA $inventorySlots, Y
    REP #$20
    LDA #$0000
    STA $inventoryEquippedType
    DEC 
    STA $inventoryEquippedIndex

  loc_03E572:
    PLP 
    RTL 
}

code_03E574 {
    PHP 
    SEP #$20
    LDY #$0000

  loc_03E57A:
    CMP $inventorySlots, Y
    BEQ loc_03E588
    INY 
    CPY #$0010
    BNE loc_03E57A
    PLP 
    SEC 
    RTL 

  loc_03E588:
    PLP 
    CLC 
    RTL 
}

code_03E58B {
    PHP 
    REP #$20
    TXY 
    LDX $decelStepCounter
    LDA $slopeCurvePtrB
    BMI loc_03E5B2

  loc_03E597:
    LDA $0028, X
    TAX 
    LDA $@code_03E5E0, X
    AND #$00FF
    CMP #$0004
    BPL loc_03E5AB
    TYX 
    PLP 
    CLC 
    RTL 

  loc_03E5AB:
    TYX 
    PLP 
    SEC 
    RTL 
}

code_03E5AF {
    PLY 
    BRA loc_03E597

  loc_03E5B2:
    PHY 
    TXY 
    LDA $0AC8
    AND #$00FF
    SEC 
    SBC #$0004
    BMI code_03E5AF
    ASL 
    TAX 
    LDA $@code_03E5E0+58, X
    SEC 
    SBC #$E638
    CLC 
    ADC $0028, Y
    TAX 
    PLY 
    LDA $@code_03E5E0+58, X
    AND #$00FF
    CMP #$0004
    BPL loc_03E5AB
    TYX 
    PLP 
    CLC 
    RTL 
}

code_03E5E0 {
    BRK #$01
    COP [QueueHdmaChannel] ( #00, #$0201, #$0003 )
    ORA ($02, X)
    ORA $00, S
    ORA ($02, X)
    ORA $00, S
    ORA ($02, X)
    ORA $00, S
    ORA ($02, X)
    ORA $00, S
    BRK #$00
    BRK #$00
    ORA ($01, X)
    ORA ($02, X)
    COP [QueueDma] ( $030303, #01 )
    ORA ($00, X)
    BRK #$01
    BRK #$01
    BRK #$01
    BRK #$02
    ORA $02, S
    ORA $02, S
    ORA $00, S
    ORA ($02, X)
    ORA $00, S
    ORA ($02, X)
    ORA $00, S
    ORA ($02, X)
    ORA $02, S
    ORA $00, S
    ORA ($02, X)
    ORA $00, S
    ORA ($04, X)
    TSB $04
    TSB $04
    TSB $00
    ORA ($02, X)
    ORA $04, S
    TSB $04
    TSB $40
    INC $5B
    INC $87
    INC $8B
    INC $00
    ORA ($02, X)
    ORA $00, S
    ORA ($02, X)
    ORA $00, S
    ORA ($02, X)
    ORA $00, S
    BRK #$00
    ORA ($01, X)
    ORA ($02, X)
    COP [QueueDma] ( $030303, #04 )
    TSB $04
    BRK #$00
    BRK #$00
    BRK #$00
    BRK #$00
    BRK #$00
    BRK #$00
    BRK #$00
    BRK #$00
    BRK #$00
    BRK #$00
    BRK #$00
    BRK #$00
    BRK #$00
    BRK #$00
    BRK #$00
    BRK #$00
    BRK #$00
    BRK #$00
    BRK #$00
    BRK #$00
    BRK #$00
    BRK #$00
    BRK #$00
    BRK #$00
    BRK #$00
    BRK #$00
    BRK #$00
}

code_03E691 {
    PHP 
    REP #$20
    LDA $7F0C07
    BEQ loc_03E6C0
    STA $VMADDL
    LDA #$0000
    STA $7F0C07
    LDA $7F0C09
    STA $DAS0L
    LDA $adhocVramDma
    STA $A1T0L
    SEP #$20
    LDA $7F0C05
    STA $A1B0
    LDA #$01
    STA $MDMAEN

  loc_03E6C0:
    PLP 
    RTL 
}