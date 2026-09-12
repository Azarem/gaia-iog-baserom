?BANK 00

?INCLUDE 'array_01D3F7'
?INCLUDE 'binary_01C36C'
?INCLUDE 'binary_01D8E7'
?INCLUDE 'body_table'
?INCLUDE 'chunk_028000'
?INCLUDE 'chunk_038000'
?INCLUDE 'chunk_3B7DD'
?INCLUDE 'dir_sprite_table'
?INCLUDE 'parallax_table'
?INCLUDE 'reward_table'
?INCLUDE 'table_01A946'
?INCLUDE 'table_01B06E'
?INCLUDE 'table_0EE000'

!L_wramFlags                    000A80
!deathFlag                      0200
!invincibilityTimer             040C
!globalFrameTimer               040E
!rngState                       040F
!rngModuloResult                0420
!sceneNext                      0642
!sceneCurrent                   0644
!gfxCacheIdxA                   0648
!gfxCacheIdxB                   064A
!worldReadyFlag                 0654
!joypadCurrent                  0656
!joypadHeld                     0658
!joypadMaskStd                  065A
!joypadMaskInv                  065C
!joypadRaw                      0660
!bg1ScrollH                     068A
!bg1ScrollV                     068C
!bg2ScrollH                     068E
!savedCameraDelta               0690
!mapBoundsX                     0692
!mapRowStrideL0                 0693
!effectBoundsX                  0694
!effectBoundsY                  0698
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
!scrollStepTableBase            06E0
!scrollStepIndex                06E2
!effectDeltaX                   06E4
!effectDeltaY                   06E6
!layerPriorityFlag              06EE
!scrollModeFlags                06EF
!sfxQueueCh1                    06F8
!sfxQueueCh2                    06F9
!musicTransitionState           06FA
!dmaSkipFlag                    0800
!tileQueryResult                0902
!playerWallType                 09B0
!playerSpeedEw                  09B2
!playerSpeedNs                  09B4
!slopeStepCounter               09B6
!decelStepCounter               09B8
!slopeCurvePtrB                 09BC
!decelCurvePtr                  09C2
!slopeFracAccum                 09C6
!maxSpeedEw                     09C8
!maxSpeedNs                     09CA
!playerActorDp                  09F4
!eventFlags                     0A00
!wramFlags                      0A80
!abilityBitmask                 0AA2
!inventorySlots                 0AB4
!inventoryEquippedIndex         0AC4
!playerMaxHp                    0ACA
!cachedPrevMaxHp                0ACC
!playerHp                       0ACE
!cachedPrevHp                   0AD0
!characterForm                  0AD4
!gemCount                       0AD6
!gemHundredsDigit               0AD8
!cachedPrevGems                 0ADA
!playerDef                      0ADC
!playerStr                      0ADE
!enemyHealthTimer               0AE4
!sceneSaveData                  0AF0
!inventoryTabIndex              0AFA
!damageFlashTimer               0B22
!INIDISP                        2100
!BG1SC                          2107
!BG2SC                          2108
!BG1HOFS                        210D
!BG1VOFS                        210E
!VMAIN                          2115
!VMADDL                         2116
!W12SEL                         2123
!WH0                            2126
!TM                             212C
!TS                             212D
!CGWSEL                         2130
!CGADSUB                        2131
!COLDATA                        2132
!APUIO0                         2140
!APUIO1                         2141
!APUIO2                         2142
!WRMPYA                         4202
!WRMPYB                         4203
!WRDIVL                         4204
!WRDIVB                         4206
!MDMAEN                         420B
!HDMAEN                         420C
!MEMSEL                         420D
!HVBJOY                         4212
!RDDIVL                         4214
!RDMPYL                         4216
!RDMPYH                         4217
!JOY1L                          4218
!DMAP0                          4300
!BBAD0                          4301
!A1T0L                          4302
!A1B0                           4304
!DAS0L                          4305
!DASB0                          4307
!metatileMapLayer               7E2000
!tileStagingBuffer              7E7000
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
!loopCounter                    7F0014
!sprTimer                       7F0016
!moveXAlt                       7F0018
!moveYAlt                       7F001A
!parentId                       7F001C
!retPtr2                        7F001E
!statsPtr                       7F0020
!enemyNum                       7F0022
!deathActionIdx                 7F0024
!currentHp                      7F0026
!iframeCounter                  7F0028
!extendedFlags                  7F002A
!moveScratch1                   7F002C
!moveScratch2                   7F002E
!cgramPalette                   7F0A00
!adhocVramDma                   7F0C03
!onHitCallback                  7F1000
!onDodgeCallback                7F1002
!onDeathCallback                7F1004
!onCollideCallback              7F1008
!scratch1010                    7F1010
!snapResumePtr                  7F1018
!free101C                       7F101C
!chainDamage                    7F101E
!loopStartPcActor               7F2100
!loopCounterActor               7F2102
!oamComposeBuffer               7F3100
!collisionLayer                 7FC000
!L_WRMPYA                       804202
!L_WRMPYB                       804203
!L_WRDIVL                       804204
!L_WRDIVB                       804206
!L_RDDIVL                       804214
!L_RDMPYL                       804216
!L_RDMPYH                       804217

---------------------------------------------

emulation_mode_reset_008000 {
    SEI 
    CLC 
    XCE 
    JML $@code_008014
}
---------------------------------------------

native_mode_cop_008007 {
    JML $@code_00857D
}
---------------------------------------------

native_mode_nmi_00800B {
    JML $@code_008309
}
---------------------------------------------

native_mode_irq_00800F {
    JML $@code_008013
}

code_008013 {
    RTI 
}

code_008014 {
    CLD 
    REP #$30
    LDA #$0000
    TCD 
    LDA #$01FF
    TCS 
    SEP #$20
    LDA #$81
    PHA 
    PLB 
    LDA #$01
    STA $MEMSEL
    JSL $@chunk_028000.code_029F9F
    JSL $@chunk_028000.code_029ED2
    JSL $@chunk_028000.code_02914F
    JSL $@chunk_028000.code_0282E1
    JSL $@chunk_028000.code_02FCBC
    SEC 
    ROR $worldReadyFlag
    LDA $000100
    LDY #$0000
    CMP #$83
    BEQ loc_008050
    LDY #$0000

  loc_008050:
    TYA 
    STA $sceneNext
    JSL $@chunk_3B7DD.code_03D6FF
    STZ $worldReadyFlag
    LDA #$20
    STA $09AD
    REP #$20
    LDA #$0009
    STA $09D6
    STA $09D8
    LDA #$0008
    STA $playerMaxHp
    STA $playerHp
    LDA #$0001
    STA $playerStr
    LDA #$0000
    STA $playerDef
    LDA #$C36C
    STA $maxSpeedEw
    STA $maxSpeedNs
    LDA #$C38C
    STA $09CE
    STA $09CC
    STA $09D2
    STA $09D0
    LDA #$FFFF
    STA $0B28
    STA $0B2A
    STA $0B2C
    STA $0B2E
    STA $0B30
    STA $0B32
    SEP #$20
    LDA #$FB
    STA $sceneNext
    LDA #$00
    STA $abilityBitmask

  loc_0080B9:
    JSL $@chunk_028000.code_028168
    JSL $@chunk_028000.code_0282C7
    JSL $@chunk_3B7DD.code_03CE36
    JSL $@chunk_3B7DD.code_03D6F1
    JSL $@chunk_028000.code_02A60D
    JSL $@chunk_038000.code_038000
    JSR $&code_0082EF
    JSL $@chunk_3B7DD.code_03C801
    LDX $00D8
    LDA #$FF
    STA $oamComposeBuffer, X
    STA $7F3101, X
    JSL $@chunk_3B7DD.code_03C308
    JSL $@chunk_3B7DD.code_03B8E0
    JSL $@chunk_3B7DD.code_03BF6C
    JSL $@chunk_3B7DD.code_03B8B0
    JSL $@chunk_3B7DD.code_03B881
    LDX #$0000
    JSL $@chunk_028000.code_02AC55
    LDX #$0002
    JSL $@chunk_028000.code_02AC55
    JSL $@chunk_3B7DD.code_03DE2F
    JSL $@chunk_3B7DD.code_03CE66
    JSL $@chunk_3B7DD.code_03C41D
    JSL $@code_008217
    JSL $@chunk_3B7DD.code_03DF07
    JSL $@chunk_028000.code_0282B6
    BRL loc_0080B9

  code_008122:
    PHB 
    PHA 
    XBA 
    PHA 
    PHX 
    PHY 
    PHD 
    REP #$20
    LDA #$0000
    TCD 
    SEP #$20
    LDA #$81
    PHA 
    PLB 
    JSL $@chunk_3B7DD.code_03CA0B
    LDX $00D8
    LDA #$FF
    STA $oamComposeBuffer, X
    STA $7F3101, X
    JSL $@chunk_3B7DD.code_03C308
    LDX #$0000
    JSL $@chunk_028000.code_02AC55
    LDX #$0002
    JSL $@chunk_028000.code_02AC55
    JSL $@chunk_3B7DD.code_03DE2F
    JSL $@chunk_3B7DD.code_03CECB
    JSL $@chunk_3B7DD.code_03C41D
    LDA #$08
    TRB $09FA
    JSL $@chunk_028000.code_0282B6
    JSL $@chunk_028000.code_028168
    JSL $@chunk_028000.code_0282C7
    JSL $@chunk_3B7DD.code_03CE96
    PLD 
    PLY 
    PLX 
    PLA 
    XBA 
    PLA 
    PLB 
    RTL 
}

code_008181 {
    PHB 
    PHA 
    XBA 
    PHA 
    PHX 
    PHY 
    PHD 
    REP #$20
    LDA #$0000
    TCD 
    SEP #$20
    LDA #$81
    PHA 
    PLB 
    JSL $@chunk_3B7DD.code_03C308
    LDX $00D8
    LDA #$FF
    STA $oamComposeBuffer, X
    STA $7F3101, X
    JSL $@chunk_3B7DD.code_03C41D
    JSL $@chunk_3B7DD.code_03DE2F
    JSL $@chunk_3B7DD.code_03CECB
    JSL $@code_008217
    JSL $@chunk_028000.code_0282B6
    JSL $@chunk_028000.code_028168
    JSL $@chunk_028000.code_0282C7
    JSL $@chunk_3B7DD.code_03CE96
    PLD 
    PLY 
    PLX 
    PLA 
    XBA 
    PLA 
    PLB 
    RTL 
}

code_0081CD {
    PHP 
    SEP #$20
    JSL $@chunk_028000.code_0282C7
    PHB 
    LDA #$81
    PHA 
    PLB 
    JSL $@chunk_028000.code_028160
    JSL $@chunk_3B7DD.code_03CE96
    JSL $@chunk_3B7DD.code_03CA7A
    LDX $00D8
    LDA #$FF
    STA $oamComposeBuffer, X
    STA $7F3101, X
    JSL $@chunk_3B7DD.code_03C308
    LDX #$0000
    JSL $@chunk_028000.code_02AC55
    LDX #$0002
    JSL $@chunk_028000.code_02AC55
    JSL $@chunk_3B7DD.code_03DE2F
    JSL $@chunk_3B7DD.code_03CECB
    JSL $@chunk_3B7DD.code_03C41D
    PLB 
    JSL $@chunk_028000.code_0282B6
    PLP 
    RTL 
}

code_008217 {
    LDA $09FB
    BIT #$40
    BEQ loc_00821F
    RTL 

  loc_00821F:
    PHP 
    LDX #$0000
    SEP #$20
    LDA $09FA
    AND #$01
    PHA 
    LDA $09BD
    BIT #$02
    BNE loc_008255
    LDA $0036
    BIT #$07
    BNE loc_008255
    LDA $damageFlashTimer
    BEQ loc_008255
    DEC 
    STA $damageFlashTimer
    LDA $playerHp
    CMP $playerMaxHp
    BNE loc_00824F
    STZ $damageFlashTimer
    BRA loc_008255

  loc_00824F:
    INC $playerHp
    COP [PlaySoundCh2] ( #0D )

  loc_008255:
    LDA $playerHp
    CMP $cachedPrevHp
    BNE loc_00826D
    LDA $playerMaxHp
    CMP $cachedPrevMaxHp
    BNE loc_00826D
    LDA $gemCount
    CMP $cachedPrevGems
    BEQ loc_00828A

  loc_00826D:
    LDA #$10
    TSB $09FA
    REP #$20
    STZ $gemHundredsDigit
    LDA $gemCount

  loc_00827A:
    SEC 
    SBC #$0064
    BMI loc_008285
    INC $gemHundredsDigit
    BRA loc_00827A

  loc_008285:
    COP [RunBg3Script] ( @01E482 )

  loc_00828A:
    REP #$20
    LDA $09F8
    BEQ loc_0082AA
    LDA #$0019
    STA $enemyHealthTimer
    COP [RunBg3Script] ( @01E4A4 )
    LDA #$0010
    TSB $09FA
    LDA #$003C
    STA $enemyHealthTimer
    BRA loc_0082CE

  loc_0082AA:
    LDA $enemyHealthTimer
    BEQ loc_0082CE
    DEC $enemyHealthTimer
    BNE loc_0082CE
    LDA #$001E
    STA $enemyHealthTimer
    STZ $playerActorDp
    STZ $09F2
    COP [RunBg3Script] ( @01E4A4 )
    LDA #$0010
    TSB $09FA
    STZ $enemyHealthTimer

  loc_0082CE:
    LDA $playerHp
    STA $cachedPrevHp
    LDA $playerMaxHp
    STA $cachedPrevMaxHp
    LDA $gemCount
    STA $cachedPrevGems
    SEP #$20
    LDA $09FA
    AND #$FE
    ORA $01, S
    STA $09FA
    PLA 
    PLP 
    RTL 
}

code_0082EF {
    PHP 
    REP #$20
    LDA $invincibilityTimer
    BMI loc_0082FB
    DEC 
    STA $invincibilityTimer

  loc_0082FB:
    LDA $globalFrameTimer
    CMP #$0100
    BCS loc_008304
    INC 

  loc_008304:
    STA $globalFrameTimer
    PLP 
    RTS 
}

code_008309 {
    PHP 
    PHB 
    REP #$20
    PHA 
    PHX 
    PHY 
    CLD 
    SEP #$20
    LDA #$81
    PHA 
    PLB 
    STZ $HDMAEN
    JSR $&code_0083A5
    JSL $@chunk_028000.code_02AF86
    JSL $@chunk_028000.code_029E70
    JSL $@chunk_028000.code_029EAB
    JSL $@chunk_028000.code_02BD44
    LDA #$80
    STA $VMAIN
    LDA #$18
    STA $BBAD0
    LDA #$01
    STA $DMAP0
    LDA $09FA
    BIT #$08
    BNE loc_008368
    LDA $dmaSkipFlag
    BNE loc_00835C
    LDA $09FA
    BIT #$06
    BNE loc_00835C
    JSL $@chunk_3B7DD.code_03E691
    JSL $@chunk_028000.code_02A340
    JSR $&code_00842F
    BRA loc_00836C

  loc_00835C:
    JSL $@chunk_028000.code_02A340
    JSR $&code_0084A5
    JSR $&code_008456
    BRA loc_00836C

  loc_008368:
    JSL $@chunk_3B7DD.code_03D58A

  loc_00836C:
    LDA $66
    STA $HDMAEN
    REP #$20

  loc_008373:
    LDA $HVBJOY
    ROR 
    BCS loc_008373
    LDA $JOY1L
    STA $joypadRaw
    LDA $musicTransitionState
    BEQ loc_00838C
    BMI loc_00839D
    JSL $@code_0081CD
    BRA loc_00839D

  loc_00838C:
    LDA $36
    LSR 
    LDA #$0000
    BCS loc_00839A
    LDA $sfxQueueCh1
    STZ $sfxQueueCh1

  loc_00839A:
    STA $APUIO2

  loc_00839D:
    INC $36
    PLY 
    PLX 
    PLA 
    PLB 
    PLP 
    RTI 
}

code_0083A5 {
    LDA $scrollModeFlags
    BIT #$08
    BNE loc_0083D5
    LDA $layerPriorityFlag
    BMI loc_0083C2
    LDX #$0000
    LDY #$0000
    JSR $&code_0083F2
    LDX #$0002
    LDY #$0002
    BRA loc_0083D1

  loc_0083C2:
    LDX #$0002
    LDY #$0000
    JSR $&code_0083F2
    LDX #$0000
    LDY #$0002

  loc_0083D1:
    JSR $&code_0083F2
    RTS 

  loc_0083D5:
    LDA $bg1ScrollH
    STA $BG1HOFS
    LDA $068B
    AND #$7F
    STA $BG1HOFS
    LDA $bg2ScrollH
    STA $BG1VOFS
    LDA $068F
    AND #$7F
    STA $BG1VOFS
    RTS 
}

code_0083F2 {
    LDA $06C7, X
    BPL loc_008402
    LDA $scrollOverrideH, X
    STA $BG1HOFS, Y
    LDA $06C7, X
    BRA loc_00840B

  loc_008402:
    LDA $bg1ScrollH, X
    STA $BG1HOFS, Y
    LDA $068B, X

  loc_00840B:
    AND #$03
    STA $BG1HOFS, Y
    LDA $06CB, X
    BPL loc_008420
    LDA $scrollOverrideV, X
    STA $BG1VOFS, Y
    LDA $06CB, X
    BRA loc_008429

  loc_008420:
    LDA $bg2ScrollH, X
    STA $BG1VOFS, Y
    LDA $068F, X

  loc_008429:
    AND #$03
    STA $BG1VOFS, Y
    RTS 
}

code_00842F {
    LDX $00B2
    BNE loc_008435
    RTS 

  loc_008435:
    STX $DAS0L
    LDX $00B0
    STX $VMADDL
    LDX $00AC
    STX $A1T0L
    LDA $00AE
    STA $A1B0
    LDA #$01
    STA $MDMAEN
    LDX #$0000
    STX $00B2
    RTS 
}

code_008456 {
    LDA $09FA
    BIT #$04
    BNE loc_00845E
    RTS 

  loc_00845E:
    AND #$FB
    STA $09FA
    LDA #$09
    STA $DMAP0
    LDX #$0000
    STX $A1T0L
    LDA #$00
    STA $A1B0
    LDX $0E
    PHX 
    LDX $00
    PHX 
    LDX #$FFFF
    STX $00
    LDA $090E
    STA $0E
    LDY #$0000

  loc_008486:
    LDX $091A, Y
    STX $VMADDL
    LDA #$20
    STA $DAS0L
    LDA #$01
    STA $MDMAEN
    INY 
    INY 
    INY 
    INY 
    DEC $0E
    BNE loc_008486
    PLX 
    STX $00
    PLX 
    STX $0E
    RTS 
}

code_0084A5 {
    LDA $09FA
    BIT #$02
    BNE loc_0084AD
    RTS 

  loc_0084AD:
    AND #$FD
    STA $09FA
    LDX #$091A
    STX $A1T0L
    LDA #$00
    STA $A1B0
    LDY #$0000
    LDX $099E
    LDA $099A, X
    BEQ loc_008523
    CMP #$05
    BCC loc_0084E4

  loc_0084CC:
    LDX $090E, Y
    STX $VMADDL
    LDA #$10
    STA $DAS0L
    LDA #$01
    STA $MDMAEN
    INY 
    INY 
    CPY #$000C
    BNE loc_0084CC
    RTS 

  loc_0084E4:
    LDX $090E, Y
    STX $VMADDL
    LDA #$10
    STA $DAS0L
    LDA #$01
    STA $MDMAEN
    INY 
    INY 
    CPY #$0004
    BNE loc_0084E4
    INY 
    INY 
    REP #$20
    LDA $A1T0L
    CLC 
    ADC #$0010
    STA $A1T0L
    SEP #$20

  loc_00850B:
    LDX $090E, Y
    STX $VMADDL
    LDA #$10
    STA $DAS0L
    LDA #$01
    STA $MDMAEN
    INY 
    INY 
    CPY #$000A
    BNE loc_00850B
    RTS 

  loc_008523:
    LDX $090E, Y
    STX $VMADDL
    LDA #$10
    STA $DAS0L
    LDA #$01
    STA $MDMAEN
    INY 
    INY 
    LDX $090E, Y
    STX $VMADDL
    LDA #$10
    STA $DAS0L
    LDA #$01
    STA $MDMAEN
    RTS 
}

code_008546 {
    PHP 
    PHB 
    REP #$20
    PHA 
    PHX 
    PHY 
    CLD 
    SEP #$20
    LDA #$81
    PHA 
    PLB 
    STZ $HDMAEN
    LDA #$80
    STA $VMAIN
    LDA #$18
    STA $BBAD0
    LDA #$01
    STA $DMAP0
    JSL $@chunk_028000.code_02BD44
    JSR $&code_008456
    JSR $&code_0084A5
    LDA $66
    STA $HDMAEN
    REP #$20
    PLY 
    PLX 
    PLA 
    PLB 
    PLP 
    RTL 
}

code_00857D {
    REP #$20
    TXY 
    LDA $04, S
    STA $0C
    LDA $02, S
    DEC 
    STA $0A
    LDA [$0A]
    INC $0A
    AND #$00FF
    ASL 
    TAX 
    JMP ($&code_list_008595, X)
}

code_list_008595 [
  &code_00875C   ;00
  &code_008797   ;01
  &code_0087AE   ;02
  &code_0087C5   ;03
  &code_008822   ;04
  &code_00884E   ;05
  &code_00887A   ;06
  &code_00888E   ;07
  &code_0088A2   ;08
  &code_0088B1   ;09
  &code_0088C5   ;0A
  &code_008972   ;0B
  &code_008988   ;0C
  &code_00899E   ;0D
  &code_0089C4   ;0E
  &code_0089EA   ;0F
  &code_008A21   ;10
  &code_008A58   ;11
  &code_008A71   ;12
  &code_008AA8   ;13
  &code_008ACF   ;14
  &code_008B1E   ;15
  &code_008B49   ;16
  &code_008B74   ;17
  &code_008B9F   ;18
  &code_0088D9   ;19
  &code_008BCA   ;1A
  &code_008BFD   ;1B
  &code_008C34   ;1C
  &code_008C6B   ;1D
  &code_008CA2   ;1E
  &code_008CD9   ;1F
  &code_008D15   ;20
  &code_008D22   ;21
  &code_008D6B   ;22
  &code_0090F8   ;23
  &code_009127   ;24
  &code_00914A   ;25
  &code_00916E   ;26
  &code_0091CA   ;27
  &code_0091F0   ;28
  &code_0091F6   ;29
  &code_009231   ;2A
  &code_00925B   ;2B
  &code_009285   ;2C
  &code_0092B4   ;2D
  &code_009332   ;2E
  &code_009366   ;2F
  &code_009395   ;30
  &code_0093E4   ;31
  &code_009413   ;32
  &code_009424   ;33
  &code_00944E   ;34
  &code_0092C8   ;35
  &code_00945D   ;36
  &code_009460   ;37
  &code_00947D   ;38
  &code_0094A6   ;39
  &code_0094CA   ;3A
  &code_0094FC   ;3B
  &code_009538   ;3C
  &code_00953F   ;3D
  &code_009581   ;3E
  &code_0095A9   ;3F
  &code_0095D1   ;40
  &code_0095FD   ;41
  &code_00962B   ;42
  &code_008EE2   ;43
  &code_009667   ;44
  &code_0096E6   ;45
  &code_009743   ;46
  &code_009748   ;47
  &code_00975A   ;48
  &code_009764   ;49
  &code_008F15   ;4A
  &code_009781   ;4B
  &code_0097C6   ;4C
  &code_0097FF   ;4D
  &code_009870   ;4E
  &code_0099B4   ;4F
  &code_009A2C   ;50
  &code_009A77   ;51
  &code_008F32   ;52
  &code_009009   ;53
  &code_009ABB   ;54
  &code_009AD6   ;55
  &code_009AF1   ;56
  &code_009B63   ;57
  &code_009B7E   ;58
  &code_009B8E   ;59
  &code_009B9E   ;5A
  &code_009BBE   ;5B
  &code_009BD2   ;5C
  &code_009BE6   ;5D
  &code_009BAE   ;5E
  &code_009C85   ;5F
  &code_009D36   ;60
  &code_009D8D   ;61
  &code_009C3D   ;62
  &code_009DB0   ;63
  &code_009DF6   ;64
  &code_009E4E   ;65
  &code_009E7D   ;66
  &code_009E9F   ;67
  &code_009EB9   ;68
  &code_009EE6   ;69
  &code_009F02   ;6A
  &code_00AA39   ;6B
  #$FFFF   ;6C
  #$FFFF   ;6D
  #$FFFF   ;6E
  #$FFFF   ;6F
  #$FFFF   ;70
  #$FFFF   ;71
  #$FFFF   ;72
  #$FFFF   ;73
  #$FFFF   ;74
  #$FFFF   ;75
  #$FFFF   ;76
  #$FFFF   ;77
  #$FFFF   ;78
  #$FFFF   ;79
  #$FFFF   ;7A
  #$FFFF   ;7B
  #$FFFF   ;7C
  #$FFFF   ;7D
  #$FFFF   ;7E
  #$FFFF   ;7F
  &code_009F1F   ;80
  &code_009F31   ;81
  &code_009F53   ;82
  &code_009F75   ;83
  &code_009FA7   ;84
  &code_009FC4   ;85
  &code_009FF1   ;86
  &code_00A01E   ;87
  &code_00A08B   ;88
  &code_00A0A6   ;89
  &code_00A0BC   ;8A
  &code_00A0DA   ;8B
  &code_00A0ED   ;8C
  &code_00A11A   ;8D
  &code_00A132   ;8E
  &code_00A167   ;8F
  &code_00A17D   ;90
  &code_00A1A3   ;91
  &code_00A1C9   ;92
  &code_00A1FF   ;93
  &code_00A215   ;94
  &code_00A255   ;95
  &code_00A26A   ;96
  &code_00A2B1   ;97
  &code_00A2FC   ;98
  &code_00A347   ;99
  &code_00A363   ;9A
  &code_00A388   ;9B
  &code_00A3A4   ;9C
  &code_00A3C9   ;9D
  &code_00A3FF   ;9E
  &code_00A43E   ;9F
  &code_00A46C   ;A0
  &code_00A4A3   ;A1
  &code_00A4D0   ;A2
  &code_00A4FD   ;A3
  &code_00A53C   ;A4
  &code_00A595   ;A5
  &code_00A62F   ;A6
  &code_00A6DA   ;A7
  &code_00A79D   ;A8
  &code_00A7AD   ;A9
  &code_00A7BD   ;AA
  &code_00A7D3   ;AB
  &code_00A7E9   ;AC
  &code_00A80F   ;AD
  &code_00A82D   ;AE
  &code_00A84B   ;AF
  &code_00A869   ;B0
  &code_00A895   ;B1
  &code_00A8AF   ;B2
  &code_00A8BA   ;B3
  &code_00A8C5   ;B4
  &code_00A8D0   ;B5
  &code_00A8DB   ;B6
  &code_00A8F0   ;B7
  &code_00A905   ;B8
  &code_00A912   ;B9
  &code_00A91F   ;BA
  &code_00A92A   ;BB
  &code_00A935   ;BC
  &code_00A963   ;BD
  &code_00A990   ;BE
  &code_00A9EB   ;BF
  &code_00AAB5   ;C0
  &code_00AAC5   ;C1
  &code_00AAD1   ;C2
  &code_00AADD   ;C3
  &code_00AAFA   ;C4
  &code_00AB11   ;C5
  &code_00AB3C   ;C6
  &code_00AB4C   ;C7
  &code_00AB67   ;C8
  &code_00AB77   ;C9
  &code_00AB89   ;CA
  &code_00ABBF   ;CB
  &code_00ABF2   ;CC
  &code_00AC02   ;CD
  &code_00AC11   ;CE
  &code_00AC21   ;CF
  &code_00AC30   ;D0
  &code_00AC3F   ;D1
  &code_00AC73   ;D2
  &code_00AC88   ;D3
  &code_00ACB6   ;D4
  &code_00ACD8   ;D5
  &code_00ACE9   ;D6
  &code_00AD0B   ;D7
  &code_00AD33   ;D8
  &code_00AD45   ;D9
  &code_00AD72   ;DA
  &code_00AD87   ;DB
  &code_00AD90   ;DC
  &code_00ADC8   ;DD
  &code_00AE08   ;DE
  &code_00AE40   ;DF
  &code_00A6F3   ;E0
  &code_00AB25   ;E1
  &code_0080EA   ;E2
  &code_00BBFD   ;E3
]
---------------------------------------------

code_00875C {
    TYX 
    PHP 
    JSR $&code_00AF69
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

code_008797 {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    TAY 
    LDA [$0A]
    INC $0A
    INC $0A
    JSL $@chunk_3B7DD.code_03DE40
    LDA $0A
    STA $02, S
    RTI 
}

code_0087AE {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    TAY 
    LDA [$0A]
    INC $0A
    INC $0A
    JSL $@chunk_3B7DD.code_03DE5C
    LDA $0A
    STA $02, S
    RTI 
}

code_0087C5 {
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
    LDA $@code_00B1CE, X
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
    LDA $&binary_01D8E7, X
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

code_008822 {
    TYX 
    PHX 
    JSR $&code_00B23A
    TYX 
    LDA #$DEBF
    STA $0000, X
    LDA #$0083
    STA $0002, X
    LDA $0012, X
    ORA #$1000
    STA $0012, X
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $chatPtr, X
    PLX 
    LDA $0A
    STA $02, S
    RTI 
}

code_00884E {
    TYX 
    PHX 
    JSR $&code_00B23A
    TYX 
    LDA #$DE93
    STA $0000, X
    LDA #$0083
    STA $0002, X
    LDA $0012, X
    ORA #$1000
    STA $0012, X
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $chatPtr, X
    PLX 
    LDA $0A
    STA $02, S
    RTI 
}

code_00887A {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    SEP #$20
    STA $sfxQueueCh2
    REP #$20
    LDA $0A
    STA $02, S
    RTI 
}

code_00888E {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    SEP #$20
    STA $sfxQueueCh1
    REP #$20
    LDA $0A
    STA $02, S
    RTI 
}

code_0088A2 {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $sfxQueueCh1
    LDA $0A
    STA $02, S
    RTI 
}

code_0088B1 {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    SEP #$20
    STA $APUIO1
    REP #$20
    LDA $0A
    STA $02, S
    RTI 
}

code_0088C5 {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    SEP #$20
    STA $APUIO0
    REP #$20
    LDA $0A
    STA $02, S
    RTI 
}

code_0088D9 {
    TYX 
    PHD 
    LDA #$0000
    TCD 
    JSL $@code_00B5AF
    BCS loc_008932
    TYX 
    LDY $0058
    TXA 
    STA $0006, Y
    STA $0058
    TYA 
    STA $0004, X
    STZ $0006, X
    TXY 
    PLA 
    TCD 
    TAX 
    JSR $&code_00B288
    LDA #$A0AE
    STA $0000, Y
    LDA #$0082
    STA $0002, Y
    LDA #$1000
    STA $0012, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0026, Y
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0020, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0022, Y
    LDA $0A
    STA $02, S
    RTI 

  loc_008932:
    PLA 
    TCD 
    TAX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    PHP 
    PHB 
    LDA [$0A]
    INC $0A
    INC $0A
    TAY 
    LDA $joypadMaskStd
    STZ $joypadMaskStd
    PHA 
    LDA [$0A]
    INC $0A
    AND #$00FF
    SEP #$20
    PHA 
    PLB 
    JSL $@code_008181
    REP #$20
    JSL $@chunk_028000.code_02B05F
    PLA 
    STA $joypadMaskStd
    PLB 
    PLP 
    LDA #$0080
    TRB $09FA
    LDA $0A
    STA $02, S
    RTI 
}

code_008972 {
    TYX 
    LDA $14
    STA $0018
    LDA $16
    STA $001C
    STZ $0000
    JSR $&code_00B34D
    LDA $0A
    STA $02, S
    RTI 
}

code_008988 {
    TYX 
    LDA $14
    STA $0018
    LDA $16
    STA $001C
    STZ $0000
    JSR $&code_00B3F3
    LDA $0A
    STA $02, S
    RTI 
}

code_00899E {
    TYX 
    JSR $&code_00B040
    PHX 
    PHD 
    LDA #$0000
    TCD 
    LDX #$0000
    JSL $@chunk_028000.code_02BDAF
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

code_0089C4 {
    TYX 
    JSR $&code_00B040
    PHX 
    PHD 
    LDA #$0000
    TCD 
    LDX #$0000
    JSL $@chunk_028000.code_02BDAF
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

code_0089EA {
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
    JSL $@chunk_028000.code_02BDAF
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

code_008A21 {
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
    JSL $@chunk_028000.code_02BDAF
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

code_008A58 {
    TYX 
    LDA $14
    STA $0018
    LDA $16
    STA $001C
    LDA #$0001
    STA $0000
    JSR $&code_00B3F3
    LDA $0A
    STA $02, S
    RTI 
}

code_008A71 {
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
    JSL $@chunk_028000.code_02BDAF
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

code_008AA8 {
    TYX 
    LDA $14
    STA $0018
    LDA $16
    STA $001C
    JSR $&code_00B4E9
    BIT #$000F
    BNE loc_008AC6
    LDA [$0A]
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 

  loc_008AC6:
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

code_008ACF {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_008ADF
    ORA #$FF00

  loc_008ADF:
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
    BEQ loc_008AF8
    ORA #$FF00

  loc_008AF8:
    ASL 
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $16
    STA $001C
    JSR $&code_00B4E9
    BIT #$000F
    BNE loc_008B15
    LDA [$0A]
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 

  loc_008B15:
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

code_008B1E {
    TYX 
    LDA $14
    STA $0018
    LDA $16
    SEC 
    SBC #$0010
    STA $001C
    JSR $&code_00B4E9
    BIT #$000F
    BNE loc_008B40
    LDA [$0A]
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 

  loc_008B40:
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

code_008B49 {
    TYX 
    LDA $14
    STA $0018
    LDA $16
    CLC 
    ADC #$0010
    STA $001C
    JSR $&code_00B4E9
    BIT #$000F
    BNE loc_008B6B
    LDA [$0A]
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 

  loc_008B6B:
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

code_008B74 {
    TYX 
    LDA $14
    SEC 
    SBC #$0010
    STA $0018
    LDA $16
    STA $001C
    JSR $&code_00B4E9
    BIT #$000F
    BNE loc_008B96
    LDA [$0A]
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 

  loc_008B96:
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

code_008B9F {
    TYX 
    LDA $14
    CLC 
    ADC #$0010
    STA $0018
    LDA $16
    STA $001C
    JSR $&code_00B4E9
    BIT #$000F
    BNE loc_008BC1
    LDA [$0A]
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 

  loc_008BC1:
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

code_008BCA {
    TYX 
    LDA $14
    STA $0018
    LDA $16
    STA $001C
    JSR $&code_00B4E9
    AND #$00FF
    PHA 
    LDA [$0A]
    INC $0A
    AND #$00FF
    CMP $01, S
    BEQ loc_008BF3
    LDA [$0A]
    INC $0A
    INC $0A
    PLY 
    LDA $0A
    STA $02, S
    RTI 

  loc_008BF3:
    PLA 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

code_008BFD {
    TYX 
    LDA $14
    STA $0018
    LDA $16
    SEC 
    SBC #$0010
    STA $001C
    JSR $&code_00B4E9
    AND #$00FF
    PHA 
    LDA [$0A]
    INC $0A
    AND #$00FF
    CMP $01, S
    BEQ loc_008C2A
    LDA [$0A]
    INC $0A
    INC $0A
    PLY 
    LDA $0A
    STA $02, S
    RTI 

  loc_008C2A:
    PLA 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

code_008C34 {
    TYX 
    LDA $14
    STA $0018
    LDA $16
    CLC 
    ADC #$0010
    STA $001C
    JSR $&code_00B4E9
    AND #$00FF
    PHA 
    LDA [$0A]
    INC $0A
    AND #$00FF
    CMP $01, S
    BEQ loc_008C61
    LDA [$0A]
    INC $0A
    INC $0A
    PLY 
    LDA $0A
    STA $02, S
    RTI 

  loc_008C61:
    PLA 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

code_008C6B {
    TYX 
    LDA $14
    SEC 
    SBC #$0010
    STA $0018
    LDA $16
    STA $001C
    JSR $&code_00B4E9
    AND #$00FF
    PHA 
    LDA [$0A]
    INC $0A
    AND #$00FF
    CMP $01, S
    BEQ loc_008C98
    LDA [$0A]
    INC $0A
    INC $0A
    PLY 
    LDA $0A
    STA $02, S
    RTI 

  loc_008C98:
    PLA 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

code_008CA2 {
    TYX 
    LDA $14
    CLC 
    ADC #$0010
    STA $0018
    LDA $16
    STA $001C
    JSR $&code_00B4E9
    AND #$00FF
    PHA 
    LDA [$0A]
    INC $0A
    AND #$00FF
    CMP $01, S
    BEQ loc_008CCF
    LDA [$0A]
    INC $0A
    INC $0A
    PLY 
    LDA $0A
    STA $02, S
    RTI 

  loc_008CCF:
    PLA 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

code_008CD9 {
    TYX 
    PHB 
    LDA $16
    BIT #$000F
    BEQ loc_008CEC

  loc_008CE2:
    PLB 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 

  loc_008CEC:
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
    BNE loc_008CE2
    PLB 
    LDA [$0A]
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 
}

code_008D15 {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSR $&code_00B1D6
    BRA loc_008D26
}

code_008D22 {
    TYX 
    LDY $decelStepCounter

  loc_008D26:
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
    BPL loc_008D41
    EOR #$FFFF
    INC 

  loc_008D41:
    CMP $0000
    BCS loc_008D60
    LDA $16
    SEC 
    SBC $0016, Y
    BPL loc_008D52
    EOR #$FFFF
    INC 

  loc_008D52:
    CMP $0000
    BCS loc_008D60
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 

  loc_008D60:
    LDA [$0A]
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 
}

code_008D6B {
    TYX 
    LDA $extendedFlags, X
    BIT #$0002
    BNE loc_008D78
    JSR $&code_008E49

  loc_008D78:
    LDA $animScratch2, X
    AND #$00FF
    CMP $24
    BNE loc_008D86
    JMP $&code_008E0D

  loc_008D86:
    SEP #$20
    LDA $24
    STA $WRMPYA
    LDA $moveXAlt, X
    AND #$FF
    JSR $&code_008E2F
    SEC 
    SBC $animScratch, X
    BEQ loc_008DBF
    REP #$20
    AND #$00FF
    PHA 
    LDA $animScratch2, X
    ASL 
    BMI loc_008DAD
    PLA 
    BRA loc_008DB2

  loc_008DAD:
    PLA 
    EOR #$FFFF
    INC 

  loc_008DB2:
    STA $moveScratch1, X
    SEP #$20
    LDA $0000
    STA $animScratch, X

  loc_008DBF:
    LDA $moveYAlt, X
    AND #$FF
    JSR $&code_008E2F
    SEC 
    SBC $animScratch+1, X
    REP #$20
    BEQ loc_008DF3
    AND #$00FF
    PHA 
    LDA $animScratch2, X
    ASL 
    BCS loc_008DDF
    PLA 
    BRA loc_008DE4

  loc_008DDF:
    PLA 
    EOR #$FFFF
    INC 

  loc_008DE4:
    STA $moveScratch2, X
    SEP #$20
    LDA $0000
    STA $animScratch+1, X
    REP #$20

  loc_008DF3:
    INC $24
    LDA $animScratch+2, X
    DEC 
    BPL loc_008E04

  loc_008DFC:
    JSL $@chunk_3B7DD.code_03C761
    BCS loc_008DFC
    LDA $08

  loc_008E04:
    STZ $08
    STA $animScratch+2, X
    PLA 
    PLA 
    RTL 
}

code_008E0D {
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

code_008E21 {
    NOP 
    LDY $RDMPYL
    RTS 
}

code_008E26 {
    NOP 
    NOP 
    NOP 
    NOP 
    NOP 
    LDA $RDDIVL
    RTS 
}

code_008E2F {
    STA $WRMPYB
    JSR $&code_008E21
    STY $WRDIVL
    LDA $animScratch2, X
    DEC 
    STA $WRDIVB
    BEQ loc_008E45
    JSR $&code_008E26

  loc_008E45:
    STA $0000
    RTS 
}

code_008E49 {
    STZ $0004
    LDA $0A
    DEC 
    DEC 
    STA $00
    LDY #$0001
    LDA [$0A]
    AND #$00FF
    CMP #$00FF
    BNE loc_008E61
    LDA $28

  loc_008E61:
    JSR $&code_00A05B
    LDA $moveXAlt, X
    SEC 
    SBC $14
    CLC 
    BPL loc_008E73
    EOR #$FFFF
    INC 
    SEC 

  loc_008E73:
    ROR $0004
    BIT #$FF00
    BEQ loc_008E7E
    LDA #$00FE

  loc_008E7E:
    STA $moveXAlt, X
    LDA $moveYAlt, X
    SEC 
    SBC $16
    CLC 
    BPL loc_008E91
    EOR #$FFFF
    INC 
    SEC 

  loc_008E91:
    ROR $0004
    BIT #$FF00
    BEQ loc_008E9C
    LDA #$00FE

  loc_008E9C:
    STA $moveYAlt, X
    CMP $moveXAlt, X
    BCS loc_008EAA
    LDA $moveXAlt, X

  loc_008EAA:
    PHA 
    LDA [$0A], Y
    AND #$00FF
    PLY 
    SEP #$20
    JSL $@chunk_028000.code_02830D
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

code_008EE2 {
    TYX 
    STZ $2C
    STZ $2E
    LDA $14
    SEC 
    SBC #$0008
    ORA $16
    AND #$000F
    BEQ loc_008F10
    LDA $0A
    STA $snapResumePtr, X
    LDA $02
    STA $7F101A, X
    LDA #$A2EA
    STA $02, S
    SEP #$20
    LDA #$8A
    STA $02
    STA $04, S
    REP #$20
    RTI 

  loc_008F10:
    LDA $0A
    STA $02, S
    RTI 
}

code_008F15 {
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

code_008F32 {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    CMP #$00FF
    BNE loc_008F41
    LDA $28

  loc_008F41:
    JSR $&code_00A05B
    LDY #$0000
    LDA $moveXAlt, X
    SEC 
    SBC $14
    BPL loc_008F57
    LDY #$4000
    EOR #$FFFF
    INC 

  loc_008F57:
    STA $moveXAlt, X
    TYA 
    STA $animScratch2, X
    LDY #$0000
    LDA $moveYAlt, X
    SEC 
    SBC $16
    BPL loc_008F73
    LDY #$8000
    EOR #$FFFF
    INC 

  loc_008F73:
    STA $moveYAlt, X
    CMP $moveXAlt, X
    BCS loc_008F81
    LDA $moveXAlt, X

  loc_008F81:
    PHA 
    TYA 
    ORA $animScratch2, X
    STA $animScratch2, X
    LDA #$0000
    STA $chatPtr, X
    PLA 

  loc_008F93:
    BIT #$FF00
    BEQ loc_008FA0
    LSR 
    PHA 
    JSR $&code_008FED
    PLA 
    BRA loc_008F93

  loc_008FA0:
    STA $WRDIVL
    LDA [$0A]
    INC $0A
    AND #$00FF
    SEP #$20
    CMP #$80
    BCC loc_008FB3
    EOR #$FF
    INC 

  loc_008FB3:
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
    BCC loc_008FD5
    JSR $&code_008FED

  loc_008FD5:
    LDA #$0000
    STA $animScratch, X
    STA $24
    STA $00002C, X
    STA $00002E, X
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

code_008FED {
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

code_009009 {
    TYX 

  code_00900A:
    LDA $animScratch2, X
    AND #$3FFF
    CMP $24
    BNE loc_009018
    JMP $&code_0090B8

  loc_009018:
    SEP #$20
    LDA $24
    STA $WRMPYA
    LDA $moveYAlt, X
    JSR $&code_0090D8
    SBC $animScratch+1, X
    BEQ loc_009051
    PHA 
    LDA $animScratch2, X
    ASL 
    PLA 
    BCC loc_009039
    EOR #$FFFF
    INC 

  loc_009039:
    AND #$00FF
    BIT #$0080
    BEQ loc_009044
    ORA #$FF00

  loc_009044:
    STA $moveScratch2, X
    SEP #$20
    LDA $0000
    STA $animScratch+1, X

  loc_009051:
    SEP #$20
    LDA $moveXAlt, X
    JSR $&code_0090D8
    SBC $animScratch, X
    BEQ loc_009086
    PHA 
    LDA $animScratch2, X
    ASL 
    ASL 
    PLA 
    BCC loc_00906E
    EOR #$FFFF
    INC 

  loc_00906E:
    AND #$00FF
    BIT #$0080
    BEQ loc_009079
    ORA #$FF00

  loc_009079:
    STA $moveScratch1, X
    SEP #$20
    LDA $0000
    STA $animScratch, X

  loc_009086:
    SEP #$20
    LDA $animScratch+3, X
    BMI loc_009098
    DEC 
    BNE loc_009094
    JMP $&code_0090B8

  loc_009094:
    STA $animScratch+3, X

  loc_009098:
    LDA $animScratch+2, X
    DEC 
    BPL loc_0090AB
    REP #$20

  loc_0090A1:
    JSL $@chunk_3B7DD.code_03C761
    BCS loc_0090A1
    SEP #$20
    LDA $08

  loc_0090AB:
    STA $animScratch+2, X
    REP #$20
    STZ $08
    INC $24
    PLA 
    PLA 
    RTL 
}

code_0090B8 {
    REP #$20
    LDA $chatPtr, X
    BEQ loc_0090D1
    DEC 
    STA $chatPtr, X
    LDA #$0000
    STA $animScratch, X
    STA $24
    JMP $&code_00900A

  loc_0090D1:
    LDA $0A
    STA $00
    PLA 
    PLA 
    RTL 
}

code_0090D8 {
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

code_0090F8 {
    PHY 
    SEP #$20
    LDX #$000F
    LDA #$00
    XBA 
    CLC 

  loc_009102:
    LDA $0410, X
    ADC $rngState, X
    STA $rngState, X
    DEX 
    BNE loc_009102
    LDX #$0010

  loc_009111:
    INC $rngState, X
    BNE loc_009119
    DEX 
    BNE loc_009111

  loc_009119:
    REP #$20
    PLX 
    LDA $0A
    STA $02, S
    LDA $0410
    AND #$00FF
    RTI 
}

code_009127 {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0000
    LDA $0410
    AND #$00FF

  loc_009138:
    SEC 
    SBC $0000
    BPL loc_009138
    CLC 
    ADC $0000
    STA $rngModuloResult
    LDA $0A
    STA $02, S
    RTI 
}

code_00914A {
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

code_00916E {
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
    BNE loc_0091AB
    LDA $0A
    STA $02, S
    RTI 

  loc_0091AB:
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

code_0091CA {
    TYX 
    LDA $10
    BIT #$4000
    BEQ loc_0091E4
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

  loc_0091E4:
    LDA [$0A]
    INC $0A
    AND #$00FF
    LDA $0A
    STA $02, S
    RTI 
}

code_0091F0 {
    TYX 
    LDY $decelStepCounter
    BRA loc_009201
}

code_0091F6 {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSR $&code_00B1D6

  loc_009201:
    LDA [$0A]
    INC $0A
    INC $0A
    CMP $0014, Y
    BNE loc_009220
    LDA [$0A]
    INC $0A
    INC $0A
    CMP $0016, Y
    BNE loc_009226
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 

  loc_009220:
    LDA [$0A]
    INC $0A
    INC $0A

  loc_009226:
    LDA [$0A]
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 
}

code_009231 {
    TYX 
    LDY $decelStepCounter
    LDA $0014, Y
    LDY #$0004
    SEC 
    SBC $14
    BEQ loc_009256
    BPL loc_00924F
    EOR #$FFFF
    INC 
    CMP [$0A]
    BCC loc_009256
    LDY #$0002
    BRA loc_009256

  loc_00924F:
    CMP [$0A]
    BCC loc_009256
    LDY #$0006

  loc_009256:
    LDA [$0A], Y
    STA $02, S
    RTI 
}

code_00925B {
    TYX 
    LDY $decelStepCounter
    LDA $0016, Y
    LDY #$0004
    SEC 
    SBC $16
    BEQ loc_009280
    BPL loc_009279
    EOR #$FFFF
    INC 
    CMP [$0A]
    BCC loc_009280
    LDY #$0002
    BRA loc_009280

  loc_009279:
    CMP [$0A]
    BCC loc_009280
    LDY #$0006

  loc_009280:
    LDA [$0A], Y
    STA $02, S
    RTI 
}

code_009285 {
    TYX 
    LDY $decelStepCounter
    LDA $0014, Y
    SEC 
    SBC $14
    BPL loc_009295
    EOR #$FFFF
    INC 

  loc_009295:
    PHA 
    LDA $0016, Y
    SEC 
    SBC $16
    BPL loc_0092A2
    EOR #$FFFF
    INC 

  loc_0092A2:
    CMP $01, S
    BCC loc_0092AB
    LDY #$0002
    BRA loc_0092AE

  loc_0092AB:
    LDY #$0000

  loc_0092AE:
    PLA 
    LDA [$0A], Y
    STA $02, S
    RTI 
}

code_0092B4 {
    TYX 
    LDA $14
    STA $0018
    LDA $16
    STA $001C
    JSR $&code_00B07F
    LDA $0A
    STA $02, S
    TYA 
    RTI 
}

code_0092C8 {
    TYX 
    LDY #$932B
    PHY 
    LDY $decelStepCounter
    LDA $0014, Y
    SEC 
    SBC $14
    BMI loc_0092FF
    STA $0018
    LDA $0016, Y
    SEC 
    SBC $16
    BMI loc_0092EC
    CMP $0018
    BCC loc_0092F7
    LDY #$0002
    RTS 

  loc_0092EC:
    BPL loc_0092F2
    EOR #$FFFF
    INC 

  loc_0092F2:
    CMP $0018
    BCS loc_0092FB

  loc_0092F7:
    LDY #$0001
    RTS 

  loc_0092FB:
    LDY #$0000
    RTS 

  loc_0092FF:
    BPL loc_009305
    EOR #$FFFF
    INC 

  loc_009305:
    STA $0018
    LDA $0016, Y
    SEC 
    SBC $16
    BMI loc_009319
    CMP $0018
    BCC loc_009324
    LDY #$0002
    RTS 

  loc_009319:
    BPL loc_00931F
    EOR #$FFFF
    INC 

  loc_00931F:
    CMP $0018
    BCS loc_009328

  loc_009324:
    LDY #$0003
    RTS 

  loc_009328:
    LDY #$0000
    RTS 
}

code_00932C {
    LDA $0A
    STA $02, S
    TYA 
    RTI 
}

code_009332 {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_009342
    ORA #$FF00

  loc_009342:
    CLC 
    ADC $14
    STA $0018
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_009357
    ORA #$FF00

  loc_009357:
    CLC 
    ADC $16
    STA $001C
    JSR $&code_00B07F
    LDA $0A
    STA $02, S
    TYA 
    RTI 
}

code_009366 {
    TYX 
    LDA $14
    STA $0018
    LDA $16
    STA $001C
    JSR $&code_00B07F
    SEP #$20
    CMP [$0A]
    REP #$20
    BEQ loc_009385
    LDA $0A
    CLC 
    ADC #$0003
    STA $02, S
    RTI 

  loc_009385:
    LDA [$0A]
    INC $0A
    AND #$00FF
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

code_009395 {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_0093A5
    ORA #$FF00

  loc_0093A5:
    CLC 
    ADC $14
    STA $0018
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_0093BA
    ORA #$FF00

  loc_0093BA:
    CLC 
    ADC $16
    STA $001C
    JSR $&code_00B07F
    SEP #$20
    CMP [$0A]
    REP #$20
    BEQ loc_0093D4
    LDA $0A
    CLC 
    ADC #$0003
    STA $02, S
    RTI 

  loc_0093D4:
    LDA [$0A]
    INC $0A
    AND #$00FF
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

code_0093E4 {
    TYX 
    JSL $@chunk_3B7DD.code_03E58B
    BEQ loc_0093FC
    DEC 
    BEQ loc_009401
    DEC 
    BEQ loc_009406
    DEC 
    BEQ loc_00940B
    LDA #$0008
    CLC 
    ADC $0A
    BRA loc_009410

  loc_0093FC:
    LDY #$0000
    BRA loc_00940E

  loc_009401:
    LDY #$0002
    BRA loc_00940E

  loc_009406:
    LDY #$0004
    BRA loc_00940E

  loc_00940B:
    LDY #$0006

  loc_00940E:
    LDA [$0A], Y

  loc_009410:
    STA $02, S
    RTI 
}

code_009413 {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF

  loc_00941B:
    JSL $@chunk_028000.code_02A393
    LDA $0A
    STA $02, S
    RTI 
}

code_009424 {
    TYX 
    SEP #$20
    JSL $@code_008181
    JSL $@code_008122
    REP #$20

  loc_009431:
    JSL $@chunk_028000.code_02A3D8
    BCS loc_009441
    SEP #$20
    JSL $@code_008122
    REP #$20
    BRA loc_009431

  loc_009441:
    SEP #$20
    JSL $@code_008122
    REP #$20
    LDA $0A
    STA $02, S
    RTI 
}

code_00944E {
    TYX 
    LDA $deathActionIdx, X
    PHA 
    LDA #$0F0F
    STA $sfxQueueCh1
    PLA 
    BRA loc_00941B
}

code_00945D {
    TYX 
    BRA loc_00946C
}

code_009460 {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $animScratch+2, X

  loc_00946C:
    STZ $0E
    JSL $@chunk_3B7DD.code_03DD99
    JSL $@chunk_3B7DD.code_03DE0E
    LDA $0A
    STA $00
    PLA 
    PLA 
    RTL 
}

code_00947D {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $animScratch+2, X
    STZ $000E, X
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $retPtr1, X
    JSL $@chunk_3B7DD.code_03DD99
    JSL $@chunk_3B7DD.code_03DE0E
    LDA $0A
    STA $00
    PLA 
    PLA 
    RTL 
}

code_0094A6 {
    TYX 
    LDA $spritesetPtr, X
    DEC 
    BNE loc_0094B9
    JSL $@chunk_3B7DD.code_03DD99
    BCC loc_0094C3
    LDA $0A
    STA $02, S
    RTI 

  loc_0094B9:
    STA $spritesetPtr, X
    LDA $animScratch, X
    STA $08

  loc_0094C3:
    JSL $@chunk_3B7DD.code_03DE0E
    PLA 
    PLA 
    RTL 
}

code_0094CA {
    TYX 
    LDA $spritesetPtr, X
    DEC 
    BNE loc_0094EA

  loc_0094D2:
    JSL $@chunk_3B7DD.code_03DD99
    BCC loc_0094F5
    LDA $retPtr1, X
    DEC 
    BEQ loc_0094E5
    STA $retPtr1, X
    BRA loc_0094D2

  loc_0094E5:
    LDA $0A
    STA $02, S
    RTI 

  loc_0094EA:
    STA $spritesetPtr, X
    LDA $animScratch, X
    STA $0008, X

  loc_0094F5:
    JSL $@chunk_3B7DD.code_03DE0E
    PLA 
    PLA 
    RTL 
}

code_0094FC {
    PHY 
    JSR $&code_00B329
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $animScratch+2, X

  loc_00950C:
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0000, X
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0002, X
    TXY 
    LDA $01, S
    TAX 
    LDA $animScratch2, X
    TYX 
    STA $animScratch2, X
    LDA #$0000
    STA $000E, X
    PLX 
    LDA $0A
    STA $02, S
    RTI 
}

code_009538 {
    PHY 
    JSR $&code_00B329
    TYX 
    BRA loc_00950C
}

code_00953F {
    TYX 
    LDY $0004, X
    BNE loc_009555
    LDY $0006, X
    STY $005A
    BEQ loc_009569
    LDA #$0000
    STA $0004, Y
    BRA loc_009569

  loc_009555:
    LDA $0006, X
    STA $0006, Y
    BNE loc_009562
    STY $005C
    BRA loc_009569

  loc_009562:
    TAY 
    LDA $0004, X
    STA $0004, Y

  loc_009569:
    PHD 
    LDA #$0000
    TCD 
    SEP #$20
    DEC $0052
    DEC $0052
    REP #$20
    TXA 
    STA [$52]
    PLD 
    LDA $0A
    STA $02, S
    RTI 
}

code_009581 {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    BIT #$0001
    BNE loc_009594
    BIT $joypadCurrent
    BNE loc_009599
    BRA loc_00959E

  loc_009594:
    BIT $joypadRaw
    BEQ loc_00959E

  loc_009599:
    LDA $0A
    STA $02, S
    RTI 

  loc_00959E:
    LDA $0A
    SEC 
    SBC #$0004
    STA $00
    PLA 
    PLA 
    RTL 
}

code_0095A9 {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    BIT #$0001
    BNE loc_0095BC
    BIT $joypadCurrent
    BEQ loc_0095C1
    BRA loc_0095C6

  loc_0095BC:
    BIT $joypadRaw
    BNE loc_0095C6

  loc_0095C1:
    LDA $0A
    STA $02, S
    RTI 

  loc_0095C6:
    LDA $0A
    SEC 
    SBC #$0004
    STA $00
    PLA 
    PLA 
    RTL 
}

code_0095D1 {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    BIT #$0001
    BNE loc_0095E4
    BIT $joypadCurrent
    BNE loc_0095F4
    BRA loc_0095E9

  loc_0095E4:
    BIT $joypadRaw
    BNE loc_0095F4

  loc_0095E9:
    LDA [$0A]
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 

  loc_0095F4:
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

code_0095FD {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    BIT #$0001
    BNE loc_009610
    BIT $joypadCurrent
    BEQ loc_009617
    BRA loc_009620

  loc_009610:
    BIT $joypadRaw
    BEQ loc_009617
    BRA loc_009620

  loc_009617:
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 

  loc_009620:
    LDA [$0A]
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 
}

code_00962B {
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
    JSL $@chunk_028000.code_02BDAF
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

code_009667 {
    PHY 
    LDX $decelStepCounter
    LDY #$0000
    LDA [$0A]
    INY 
    AND #$00FF
    BIT #$0080
    BEQ loc_00967C
    ORA #$FF00

  loc_00967C:
    ASL 
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $14
    CMP $0014, X
    BCS loc_0096DC
    LDA [$0A], Y
    INY 
    AND #$00FF
    BIT #$0080
    BEQ loc_009696
    ORA #$FF00

  loc_009696:
    ASL 
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $16
    CMP $0016, X
    BCS loc_0096DC
    LDA [$0A], Y
    INY 
    AND #$00FF
    BIT #$0080
    BEQ loc_0096B0
    ORA #$FF00

  loc_0096B0:
    ASL 
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $14
    CMP $0014, X
    BCC loc_0096DC
    LDA [$0A], Y
    INY 
    AND #$00FF
    BIT #$0080
    BEQ loc_0096CA
    ORA #$FF00

  loc_0096CA:
    ASL 
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $16
    CMP $0016, X
    BCC loc_0096DC
    PLX 
    LDA [$0A], Y
    STA $02, S
    RTI 

  loc_0096DC:
    PLX 
    LDA $0A
    CLC 
    ADC #$0006
    STA $02, S
    RTI 
}

code_0096E6 {
    PHY 
    LDX $decelStepCounter
    LDY #$0000
    LDA $0016, X
    SEC 
    SBC #$0008
    STA $0000
    LDA [$0A]
    INY 
    AND #$00FF
    ASL 
    ASL 
    ASL 
    ASL 
    CMP $0014, X
    BCS loc_009739
    LDA [$0A], Y
    INY 
    AND #$00FF
    ASL 
    ASL 
    ASL 
    ASL 
    CMP $0000
    BCS loc_009739
    LDA [$0A], Y
    INY 
    AND #$00FF
    ASL 
    ASL 
    ASL 
    ASL 
    CMP $0014, X
    BCC loc_009739
    LDA [$0A], Y
    INY 
    AND #$00FF
    ASL 
    ASL 
    ASL 
    ASL 
    CMP $0000
    BCC loc_009739
    PLX 
    LDA [$0A], Y
    STA $02, S
    RTI 

  loc_009739:
    PLX 
    LDA $0A
    CLC 
    ADC #$0006
    STA $02, S
    RTI 
}

code_009743 {
    TYX 
    LDY $04
    BRA loc_00974B
}

code_009748 {
    TYX 
    LDY $06

  loc_00974B:
    LDA $14
    STA $0014, Y
    LDA $16
    STA $0016, Y
    LDA $0A
    STA $02, S
    RTI 
}

code_00975A {
    TYX 
    LDA $0A
    STA $02, S
    JSL $@chunk_3B7DD.code_03E58B
    RTI 
}

code_009764 {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    CMP $characterForm
    BNE loc_009778
    LDA $0A
    INC 
    INC 
    STA $02, S
    RTI 

  loc_009778:
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

code_009781 {
    TYX 
    JSR $&code_0099A5
    BCC loc_00978A
    PLA 
    PLA 
    RTL 

  loc_00978A:
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
    JSR $&code_009925
    PLD 
    PLX 
    LDA $0A
    STA $02, S
    RTI 
}

code_0097C6 {
    TYX 
    JSR $&code_0099A5
    BCC loc_0097CF
    PLA 
    PLA 
    RTL 

  loc_0097CF:
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
    JSR $&code_009925
    PLD 
    PLX 
    LDA $0A
    STA $02, S
    RTI 
}

code_0097FF {
    TYX 
    JSR $&code_0099A5
    BCC loc_009808
    PLA 
    PLA 
    RTL 

  loc_009808:
    LDA $extendedFlags, X
    BIT #$0002
    BNE loc_00981C
    ORA #$0002
    STA $extendedFlags, X
    LDA [$0A]
    STA $24

  loc_00981C:
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
    JSR $&code_0098EB
    BCS loc_009857
    PLB 
    JSR $&code_009925
    PLD 
    PLX 
    LDA $extendedFlags, X
    BIT #$0004
    BEQ loc_00984E
    SEP #$20
    LDA $orbitAngle, X
    STA $sfxQueueCh2
    REP #$20

  loc_00984E:
    LDA $0A
    DEC 
    DEC 
    STA $00
    PLA 
    PLA 
    RTL 

  loc_009857:
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

code_009870 {
    TYX 
    JSR $&code_0099A5
    BCC loc_009879
    PLA 
    PLA 
    RTL 

  loc_009879:
    LDA $extendedFlags, X
    BIT #$0002
    BNE loc_00988D
    ORA #$0002
    STA $extendedFlags, X
    LDA [$0A]
    STA $24

  loc_00988D:
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
    JSR $&code_0098EB
    BCS loc_0098D2
    LDA $0003, X
    AND #$00FF
    STA $0008, Y
    PLB 
    JSR $&code_009925
    PLD 
    PLX 
    LDA $extendedFlags, X
    BIT #$0004
    BEQ loc_0098C9
    SEP #$20
    LDA $orbitAngle, X
    STA $sfxQueueCh2
    REP #$20

  loc_0098C9:
    LDA $0A
    DEC 
    DEC 
    STA $00
    PLA 
    PLA 
    RTL 

  loc_0098D2:
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

code_0098EB {
    LDA #$0000
    TCD 
    SEP #$20
    LDA $0000, X
    BMI loc_009923
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

  loc_009923:
    SEC 
    RTS 
}

code_009925 {
    LDX #$0000
    JSL $@chunk_028000.code_02BDAF
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
    BCS loc_0099A4
    LDA $bg2ScrollH
    SEC 
    SBC #$0010
    AND #$FFF0
    PHA 
    LDA $1E
    SEC 
    SBC $01, S
    BMI loc_0099A3
    CMP #$00F1
    BCS loc_0099A3
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
    JSL $@chunk_028000.code_02BDDB
    STA $tileQueryResult
    CLC 
    ADC #$0020
    STA $0908
    RTS 

  loc_0099A3:
    PLA 

  loc_0099A4:
    RTS 
}

code_0099A5 {
    CLC 
    LDA $tileQueryResult
    BNE loc_0099AC
    RTS 

  loc_0099AC:
    LDA $0A
    DEC 
    DEC 
    STA $00
    SEC 
    RTS 
}

code_0099B4 {
    TYX 
    LDA $extendedFlags, X
    BIT #$0001
    BNE loc_009A0A
    LDA $7F0C07
    BEQ loc_0099CD
    LDA $0A
    DEC 
    DEC 
    STA $00
    PLA 
    PLA 
    RTL 

  loc_0099CD:
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

  loc_009A0A:
    LDY #$0003
    LDA [$0A], Y
    CMP $adhocVramDma
    BNE loc_009A18
    PLA 
    PLA 
    RTL 

  loc_009A18:
    LDA $extendedFlags, X
    AND #$FFFE
    STA $extendedFlags, X
    LDA $0A
    CLC 
    ADC #$0007
    STA $02, S
    RTI 
}

code_009A2C {
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

code_009A77 {
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
    JSL $@chunk_028000.code_028395
    JSL $@chunk_3B7DD.code_03D573
    PLD 
    PLX 
    LDA $0A
    STA $02, S
    RTI 
}

code_009ABB {
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

code_009AD6 {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $28
    STZ $2A
    LDA [$0A]
    INC $0A
    INC $0A
    STA $24
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

code_009AF1 {
    TYX 
    LDA $00B2
    BEQ loc_009AFA
    PLA 
    PLA 
    RTL 

  loc_009AFA:
    PHB 
    LDA $24
    STA $00B0
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
    INC $2A
    ASL 
    ASL 
    CLC 
    ADC $0000, Y
    TAY 
    LDA $0000, Y
    BMI loc_009B5B
    STA $08
    LDA $0002, Y
    TAY 
    LDA $0012, Y
    AND #$00FF
    ASL 
    ASL 
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $animScratch, X
    STA $00AC
    LDA $animScratch+2, X
    STA $00AE
    LDA #$0020
    STA $00B2
    LDA $000D, Y
    AND #$00FF
    BEQ loc_009B57
    LDA #$0080
    STA $00B2

  loc_009B57:
    PLB 
    PLA 
    PLA 
    RTL 

  loc_009B5B:
    STZ $2A
    PLB 
    LDA $0A
    STA $02, S
    RTI 
}

code_009B63 {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $onDeathCallback, X
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $7F1006, X
    LDA $0A
    STA $02, S
    RTI 
}

code_009B7E {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $onHitCallback, X
    LDA $0A
    STA $02, S
    RTI 
}

code_009B8E {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $onDodgeCallback, X
    LDA $0A
    STA $02, S
    RTI 
}

code_009B9E {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $onCollideCallback, X
    LDA $0A
    STA $02, S
    RTI 
}

code_009BAE {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $scratch1010+6, X
    LDA $0A
    STA $02, S
    RTI 
}

code_009BBE {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    ORA $extendedFlags, X
    STA $extendedFlags, X
    LDA $0A
    STA $02, S
    RTI 
}

code_009BD2 {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    AND $extendedFlags, X
    STA $extendedFlags, X
    LDA $0A
    STA $02, S
    RTI 
}

code_009BE6 {
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
    JSL $@chunk_3B7DD.code_03D493
    CPY #$4000
    BCS loc_009C33
    LDA $000F, X
    AND #$0010
    BEQ loc_009C18
    LDA [$80], Y
    AND #$000F
    BEQ loc_009C29
    BRA loc_009C29

  loc_009C18:
    LDA [$80], Y
    BIT #$00F0
    BNE loc_009C33
    AND #$000F
    BEQ loc_009C29
    CMP #$000E
    BNE loc_009C33

  loc_009C29:
    PLD 
    LDA $0A
    CLC 
    ADC #$0002
    STA $02, S
    RTI 

  loc_009C33:
    PLD 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

code_009C3D {
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
    JSL $@chunk_3B7DD.code_03D493
    CPY #$4000
    BCS loc_009C7B
    LDA [$80], Y
    AND #$000F
    CMP $00
    BEQ loc_009C7B
    PLD 
    LDA $0A
    CLC 
    ADC #$0002
    STA $02, S
    RTI 

  loc_009C7B:
    PLD 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

code_009C85 {
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
    JSL $@chunk_028000.code_02830D
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

  loc_009CF9:
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
    BNE loc_009CF9
    LDA #$0000
    STA $5E
    STA $animScratch+2, X
    STA $retPtr1, X
    PLB 
    PLA 
    TAX 
    TCD 
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

code_009D36 {
    TYX 
    LDA $animScratch+2, X
    DEC 
    BPL loc_009D54
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $animScratch+2, X
    LDA $retPtr1, X
    INC 
    STA $retPtr1, X
    BRA loc_009D5A

  loc_009D54:
    STA $animScratch+2, X
    INC $0A

  loc_009D5A:
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_009D78
    AND #$000F
    TAY 
    LDA $cameraTargetX, Y
    STA $0018
    LDA $cameraTargetY, Y
    STA $001C
    BRA loc_009D85

  loc_009D78:
    TAY 
    LDA $cameraTargetX, Y
    STA $0018
    LDA $cameraTargetY, Y
    STA $001C

  loc_009D85:
    JSR $&code_00AE80
    LDA $0A
    STA $02, S
    RTI 
}

code_009D8D {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    TAY 
    LDA $0036
    LSR 
    BCC loc_009DA1
    TYA 
    CLC 
    ADC #$0200
    TAY 

  loc_009DA1:
    LDA [$0A]
    INC $0A
    INC $0A
    JSL $@chunk_3B7DD.code_03DE40
    LDA $0A
    STA $02, S
    RTI 
}

code_009DB0 {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_009DC0
    ORA #$FF00

  loc_009DC0:
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
    BEQ loc_009DE3
    EOR #$FFFF
    INC 

  loc_009DE3:
    CLC 
    ADC $16
    STA $moveYAlt, X
    LDA #$0000
    STA $scratch1010+4, X
    LDA $0A
    STA $02, S
    RTI 
}

code_009DF6 {
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

  loc_009E16:
    DEY 
    BMI loc_009E1C
    LSR 
    BRA loc_009E16

  loc_009E1C:
    PHA 
    LDA $scratch1010+2, X
    SEC 
    SBC $01, S
    STA $01, S
    PLA 
    EOR #$FFFF
    INC 
    STA $moveScratch2, X
    BMI loc_009E46
    LDA $16
    BMI loc_009E46
    LDA $moveYAlt, X
    SEC 
    SBC $16
    BCS loc_009E46
    LDA $0A
    STA $02, S
    LDA #$FFFF
    RTI 

  loc_009E46:
    LDA $0A
    STA $02, S
    LDA #$0000
    RTI 
}

code_009E4E {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0D52
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0D56
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0D5E
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0D5A
    STZ $0D58
    LDA $0A
    STA $02, S
    RTI 
}

code_009E7D {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0D52
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0D56
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0D58
    LDA $0A
    STA $02, S
    RTI 
}

code_009E9F {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0D5E
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0D5A
    LDA $0A
    STA $02, S
    RTI 
}

code_009EB9 {
    TYX 
    LDA $14
    BMI loc_009EDD
    CMP $cameraOffsetX
    BCC loc_009EDD
    CMP $cameraBoundsX
    BCS loc_009EDD
    LDA $16
    BMI loc_009EDD
    CMP $cameraOffsetY
    BCC loc_009EDD
    CMP $cameraBoundsY
    BCS loc_009EDD
    LDA $0A
    INC 
    INC 
    STA $02, S
    RTI 

  loc_009EDD:
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

code_009EE6 {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    CMP $00E4
    BCC loc_009EFD
    LDA $0A
    SEC 
    SBC #$0004
    STA $00
    PLA 
    PLA 
    RTL 

  loc_009EFD:
    LDA $0A
    STA $02, S
    RTI 
}

code_009F02 {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    LDY $06
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    STA $002C, Y
    STA $002E, Y
    LDA $0A
    STA $02, S
    RTI 
}

code_009F1F {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSR $&code_00A05B
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

code_009F31 {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSR $&code_00A05B
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveXAlt, X
    JSR $&code_00B208
    STA $2C
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

code_009F53 {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSR $&code_00A05B
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveYAlt, X
    JSR $&code_00B208
    STA $2E
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

code_009F75 {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSR $&code_00A05B
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveXAlt, X
    JSR $&code_00B208
    STA $2C
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveYAlt, X
    JSR $&code_00B208
    STA $2E
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

code_009FA7 {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSR $&code_00A05B
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $sprTimer, X
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

code_009FC4 {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSR $&code_00A05B
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $sprTimer, X
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveXAlt, X
    JSR $&code_00B208
    STA $2C
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

code_009FF1 {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSR $&code_00A05B
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $sprTimer, X
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveYAlt, X
    JSR $&code_00B208
    STA $2E
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

code_00A01E {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSR $&code_00A05B
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $sprTimer, X
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveXAlt, X
    JSR $&code_00B208
    STA $2C
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveYAlt, X
    JSR $&code_00B208
    STA $2E
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

code_00A05B {
    STZ $2A
    CMP #$00FF
    BNE loc_00A063
    RTS 

  loc_00A063:
    BIT #$0080
    BEQ loc_00A07B
    AND #$FF7F
    STA $28
    LDA $12
    BIT #$0002
    BEQ loc_00A075
    RTS 

  loc_00A075:
    LDA #$4000
    TSB $0E
    RTS 

  loc_00A07B:
    STA $28
    LDA $12
    BIT #$0002
    BEQ loc_00A085
    RTS 

  loc_00A085:
    LDA #$4000
    TRB $0E
    RTS 
}

code_00A08B {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $spritesetPtr, X
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $7F0008, X
    LDA $0A
    STA $02, S
    RTI 
}

code_00A0A6 {
    TYX 
    JSL $@chunk_3B7DD.code_03C761
    BCC loc_00A0B9
    LDA #$0000
    STA $2C
    STA $2E
    LDA $0A
    STA $02, S
    RTI 

  loc_00A0B9:
    PLA 
    PLA 
    RTL 
}

code_00A0BC {
    TYX 

  loc_00A0BD:
    JSL $@chunk_3B7DD.code_03C761
    BCC loc_00A0D7
    LDA $sprTimer, X
    DEC 
    STA $sprTimer, X
    BNE loc_00A0BD
    STZ $2C
    STZ $2E
    LDA $0A
    STA $02, S
    RTI 

  loc_00A0D7:
    PLA 
    PLA 
    RTL 
}

code_00A0DA {
    TYX 
    JSL $@chunk_3B7DD.code_03C761
    BCC loc_00A0E8
    LDA #$0000
    STA $2C
    STA $2E

  loc_00A0E8:
    LDA $0A
    STA $02, S
    RTI 
}

code_00A0ED {
    TYX 
    JSL $@chunk_3B7DD.code_03C761
    BCC loc_00A107
    LDA #$0000
    STA $2C
    STA $2E
    LDA [$0A]
    INC $0A
    AND #$00FF
    LDA $0A
    STA $02, S
    RTI 

  loc_00A107:
    LDA [$0A]
    INC $0A
    AND #$00FF
    CMP $2A
    BEQ loc_00A115
    PLA 
    PLA 
    RTL 

  loc_00A115:
    LDA $0A
    STA $02, S
    RTI 
}

code_00A11A {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSR $&code_00A05B
    JSL $@chunk_3B7DD.code_03C761
    STZ $2A
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

code_00A132 {
    TYX 
    SEP #$20
    LDA [$0A]
    STA $0AC8
    ASL 
    CLC 
    ADC [$0A]
    ASL 
    REP #$20
    AND #$00FF
    STA $animScratch2, X
    TAY 
    LDA $&body_table, Y
    STA $spritesetPtr, X
    LDA $&body_table+2, Y
    AND #$00FF
    STA $7F0008, X
    LDA #$8000
    TSB $slopeCurvePtrB
    INC $0A
    LDA $0A
    STA $02, S
    RTI 
}

code_00A167 {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $28
    STZ $2A
    JSR $&code_00B01E
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

code_00A17D {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $28
    STZ $2A
    JSR $&code_00B01E
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveXAlt, X
    JSR $&code_00B208
    STA $2C
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

code_00A1A3 {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $28
    STZ $2A
    JSR $&code_00B01E
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveYAlt, X
    JSR $&code_00B208
    STA $2E
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

code_00A1C9 {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $28
    STZ $2A
    JSR $&code_00B01E
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveXAlt, X
    JSR $&code_00B208
    STA $2C
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveYAlt, X
    JSR $&code_00B208
    STA $2E
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

code_00A1FF {
    TYX 
    JSL $@chunk_3B7DD.code_03C761
    BCC loc_00A212
    LDA #$0000
    STA $2C
    STA $2E
    LDA $0A
    STA $02, S
    RTI 

  loc_00A212:
    PLA 
    PLA 
    RTL 
}

code_00A215 {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $28
    STZ $2A
    JSR $&code_00B01E
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveXAlt, X
    JSR $&code_00B208
    STA $2C
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveYAlt, X
    JSR $&code_00B208
    STA $2E
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $09BE
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

code_00A255 {
    TYX 
    LDA $0000
    AND #$00FF
    STA $28
    STZ $2A
    JSR $&code_00B01E
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

code_00A26A {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    CMP $joypadCurrent
    BNE loc_00A2A0
    LDA $16
    BIT #$000F
    BNE loc_00A29A
    STA $001C
    LDA $14
    STA $0018
    JSR $&code_00B4E9
    AND #$00FF
    BIT #$00F0
    BNE loc_00A2A5
    CMP #$000F
    BEQ loc_00A2A5
    CMP $09BE
    BNE loc_00A2A0

  loc_00A29A:
    JSL $@chunk_3B7DD.code_03C761
    BCC loc_00A2AE

  loc_00A2A0:
    LDA $0A
    STA $02, S
    RTI 

  loc_00A2A5:
    LDA $10
    ORA #$0004
    STA $10
    BRA loc_00A2A0

  loc_00A2AE:
    PLA 
    PLA 
    RTL 
}

code_00A2B1 {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    CMP $joypadCurrent
    BNE loc_00A2EB
    LDA $16
    BIT #$000F
    BNE loc_00A2E5
    SEC 
    SBC #$0010
    STA $001C
    LDA $14
    STA $0018
    JSR $&code_00B4E9
    AND #$00FF
    BIT #$00F0
    BNE loc_00A2F0
    CMP #$000F
    BEQ loc_00A2F0
    CMP $09BE
    BNE loc_00A2EB

  loc_00A2E5:
    JSL $@chunk_3B7DD.code_03C761
    BCC loc_00A2F9

  loc_00A2EB:
    LDA $0A
    STA $02, S
    RTI 

  loc_00A2F0:
    LDA $10
    ORA #$0004
    STA $10
    BRA loc_00A2EB

  loc_00A2F9:
    PLA 
    PLA 
    RTL 
}

code_00A2FC {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    CMP $joypadCurrent
    BNE loc_00A336
    LDA $16
    BIT #$000F
    BNE loc_00A330
    CLC 
    ADC #$0010
    STA $001C
    LDA $14
    STA $0018
    JSR $&code_00B4E9
    AND #$00FF
    BIT #$00F0
    BNE loc_00A33B
    CMP #$000F
    BEQ loc_00A33B
    CMP $09BE
    BNE loc_00A336

  loc_00A330:
    JSL $@chunk_3B7DD.code_03C761
    BCC loc_00A344

  loc_00A336:
    LDA $0A
    STA $02, S
    RTI 

  loc_00A33B:
    LDA $10
    ORA #$0004
    STA $10
    BRA loc_00A336

  loc_00A344:
    PLA 
    PLA 
    RTL 
}

code_00A347 {
    TYX 
    JSR $&code_00B20E
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0000, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0002, Y
    LDA $0A
    STA $02, S
    RTI 
}

code_00A363 {
    TYX 
    JSR $&code_00B20E
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0000, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0002, Y
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0010, Y
    LDA $0A
    STA $02, S
    RTI 
}

code_00A388 {
    TYX 
    JSR $&code_00B23A
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0000, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0002, Y
    LDA $0A
    STA $02, S
    RTI 
}

code_00A3A4 {
    TYX 
    JSR $&code_00B23A
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0000, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0002, Y
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0010, Y
    LDA $0A
    STA $02, S
    RTI 
}

code_00A3C9 {
    TYX 
    JSR $&code_00B23A
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0000, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0002, Y
    LDA [$0A]
    INC $0A
    INC $0A
    CLC 
    ADC $0014, Y
    STA $0014, Y
    LDA [$0A]
    INC $0A
    INC $0A
    CLC 
    ADC $0016, Y
    STA $0016, Y
    LDA $0A
    STA $02, S
    RTI 
}

code_00A3FF {
    TYX 
    JSR $&code_00B23A
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0000, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0002, Y
    LDA [$0A]
    INC $0A
    INC $0A
    CLC 
    ADC $0014, Y
    STA $0014, Y
    LDA [$0A]
    INC $0A
    INC $0A
    CLC 
    ADC $0016, Y
    STA $0016, Y
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0010, Y
    LDA $0A
    STA $02, S
    RTI 
}

code_00A43E {
    TYX 
    JSR $&code_00B23A
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0000, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0002, Y
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0014, Y
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0016, Y
    LDA $0A
    STA $02, S
    RTI 
}

code_00A46C {
    TYX 
    JSR $&code_00B23A
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0000, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0002, Y
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0014, Y
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0016, Y
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0010, Y
    LDA $0A
    STA $02, S
    RTI 
}

code_00A4A3 {
    TYX 
    JSR $&code_00B20E
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0000, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0002, Y
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0010, Y
    LDA #$0040
    TSB $12
    JSR $&code_00B279
    LDA $0A
    STA $02, S
    RTI 
}

code_00A4D0 {
    TYX 
    JSR $&code_00B23A
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0000, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0002, Y
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0010, Y
    LDA #$0040
    TSB $12
    JSR $&code_00B279
    LDA $0A
    STA $02, S
    RTI 
}

code_00A4FD {
    TYX 
    JSR $&code_00B23A
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0000, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0002, Y
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0014, Y
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0016, Y
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0010, Y
    LDA #$0040
    TSB $12
    JSR $&code_00B279
    LDA $0A
    STA $02, S
    RTI 
}

code_00A53C {
    TYX 
    JSR $&code_00B23A
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0000, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0002, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_00A562
    ORA #$FF00

  loc_00A562:
    CLC 
    ADC $0014, Y
    STA $0014, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_00A578
    ORA #$FF00

  loc_00A578:
    CLC 
    ADC $0016, Y
    STA $0016, Y
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0010, Y
    LDA #$0040
    TSB $12
    JSR $&code_00B279
    LDA $0A
    STA $02, S
    RTI 
}

code_00A595 {
    PHY 
    LDA #$0000
    TCD 
    JSL $@code_00B5AF
    BCS loc_00A606
    TYX 
    LDY $0058
    TXA 
    STA $0006, Y
    STA $0058
    TYA 
    STA $0004, X
    STZ $0006, X
    TXY 
    PLA 
    TCD 
    TAX 
    JSR $&code_00B288
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0000, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0002, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_00A5DB
    ORA #$FF00

  loc_00A5DB:
    CLC 
    ADC $0014, Y
    STA $0014, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_00A5F1
    ORA #$FF00

  loc_00A5F1:
    CLC 
    ADC $0016, Y
    STA $0016, Y
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0010, Y
    LDA $0A
    STA $02, S
    RTI 

  loc_00A606:
    PLA 
    TCD 
    TAX 
    LDA [$0A]
    INC $0A
    INC $0A
    LDA [$0A]
    INC $0A
    AND #$00FF
    LDA [$0A]
    INC $0A
    AND #$00FF
    LDA [$0A]
    INC $0A
    AND #$00FF
    LDA [$0A]
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 
}

code_00A62F {
    PHY 
    LDA #$0000
    TCD 
    JSL $@code_00B5AF
    BCS loc_00A6AA
    TYX 
    LDY $0058
    TXA 
    STA $0006, Y
    STA $0058
    TYA 
    STA $0004, X
    STZ $0006, X
    TXY 
    PLA 
    TCD 
    TAX 
    JSR $&code_00B288
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0000, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0002, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0028, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_00A67F
    ORA #$FF00

  loc_00A67F:
    CLC 
    ADC $0014, Y
    STA $0014, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_00A695
    ORA #$FF00

  loc_00A695:
    CLC 
    ADC $0016, Y
    STA $0016, Y
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0010, Y
    LDA $0A
    STA $02, S
    RTI 

  loc_00A6AA:
    PLA 
    TCD 
    TAX 
    LDA [$0A]
    INC $0A
    INC $0A
    LDA [$0A]
    INC $0A
    AND #$00FF
    LDA [$0A]
    INC $0A
    AND #$00FF
    LDA [$0A]
    INC $0A
    AND #$00FF
    LDA [$0A]
    INC $0A
    AND #$00FF
    LDA [$0A]
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 
}

code_00A6DA {
    TYX 
    PHD 
    LDA $12
    BIT #$0040
    BEQ loc_00A6E8
    PEA $&code_00A6EB-1
    BRA loc_00A70A

  loc_00A6E8:
    JSR $&code_00AFF1
}

code_00A6EB {
    PLA 
    TAX 
    TCD 
    LDA $0A
    STA $02, S
    RTI 
}

code_00A6F3 {
    TYX 
    PHD 
    LDA $12
    BIT #$0040
    BEQ loc_00A701
    PEA $&code_00A704-1
    BRA loc_00A70A

  loc_00A701:
    JSR $&code_00AFF1
}

code_00A704 {
    PLA 
    TAX 
    TCD 
    PLA 
    PLA 
    RTL 

  loc_00A70A:
    STX $0000
    LDA $0004, X
    TAX 
    BEQ loc_00A722

  loc_00A713:
    LDA $parentId, X
    CMP $0000
    BNE loc_00A722
    LDA $0004, X
    TAX 
    BNE loc_00A713

  loc_00A722:
    STX $0002
    LDX $0000
    LDA $0006, X
    TAX 
    BEQ loc_00A73D

  loc_00A72E:
    LDA $parentId, X
    CMP $0000
    BNE loc_00A73D
    LDA $0006, X
    TAX 
    BNE loc_00A72E

  loc_00A73D:
    STX $0004
    LDX $0002
    BNE loc_00A74B
    LDX $0056
    JSR $&code_00B266

  loc_00A74B:
    LDA $0006, X
    CMP $0004
    BEQ loc_00A759
    TAX 
    JSR $&code_00B266
    BRA loc_00A74B

  loc_00A759:
    LDA $0002
    BNE loc_00A771
    LDX $0004
    STX $0056
    STZ $0004, X
    LDA $03, S
    TAX 
    TCD 
    LDA $0004
    STA $06
    RTS 

  loc_00A771:
    LDA $0004
    BNE loc_00A786
    LDX $0002
    STX $0058
    STZ $0006, X
    LDA $03, S
    TAX 
    TCD 
    STZ $06
    RTS 

  loc_00A786:
    LDY $0004
    LDA $0002
    STA $0004, Y
    TAX 
    TYA 
    STA $0006, X
    TAY 
    LDA $03, S
    TAX 
    TCD 
    TYA 
    STA $06
    RTS 
}

code_00A79D {
    PHY 
    LDA $04
    TCD 
    TAX 
    JSR $&code_00AFF1
    PLA 
    TCD 
    TAX 
    LDA $0A
    STA $02, S
    RTI 
}

code_00A7AD {
    PHY 
    LDA $06
    TCD 
    TAX 
    JSR $&code_00AFF1
    PLA 
    TCD 
    TAX 
    LDA $0A
    STA $02, S
    RTI 
}

code_00A7BD {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveXAlt, X
    JSR $&code_00B208
    STA $2C
    LDA $0A
    STA $02, S
    RTI 
}

code_00A7D3 {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveYAlt, X
    JSR $&code_00B208
    STA $2E
    LDA $0A
    STA $02, S
    RTI 
}

code_00A7E9 {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveXAlt, X
    JSR $&code_00B208
    STA $2C
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveYAlt, X
    JSR $&code_00B208
    STA $2E
    LDA $0A
    STA $02, S
    RTI 
}

code_00A80F {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    BEQ loc_00A823
    LDA #$4000
    TSB $12
    LDA $0A
    STA $02, S
    RTI 

  loc_00A823:
    LDA #$4000
    TRB $12
    LDA $0A
    STA $02, S
    RTI 
}

code_00A82D {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    BEQ loc_00A841
    LDA #$2000
    TSB $12
    LDA $0A
    STA $02, S
    RTI 

  loc_00A841:
    LDA #$2000
    TRB $12
    LDA $0A
    STA $02, S
    RTI 
}

code_00A84B {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    BEQ loc_00A85F
    LDA #$6000
    TSB $12
    LDA $0A
    STA $02, S
    RTI 

  loc_00A85F:
    LDA #$6000
    TRB $12
    LDA $0A
    STA $02, S
    RTI 
}

code_00A869 {
    PHY 
    LDX $0058
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveXAlt, X
    JSR $&code_00B208
    STA $002C, X
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveYAlt, X
    JSR $&code_00B208
    STA $002E, X
    PLX 
    LDA $0A
    STA $02, S
    RTI 
}

code_00A895 {
    TYX 
    LDA $moveXAlt, X
    JSR $&code_00B208
    STA $002C, X
    LDA $moveYAlt, X
    JSR $&code_00B208
    STA $002E, X
    LDA $0A
    STA $02, S
    RTI 
}

code_00A8AF {
    TYX 
    LDA #$0002
    TSB $10
    LDA $0A
    STA $02, S
    RTI 
}

code_00A8BA {
    TYX 
    LDA #$0001
    TSB $10
    LDA $0A
    STA $02, S
    RTI 
}

code_00A8C5 {
    TYX 
    LDA #$0002
    TRB $10
    LDA $0A
    STA $02, S
    RTI 
}

code_00A8D0 {
    TYX 
    LDA #$0001
    TRB $10
    LDA $0A
    STA $02, S
    RTI 
}

code_00A8DB {
    TYX 
    LDA #$3000
    TRB $0E
    LDA [$0A]
    INC $0A
    AND #$00FF
    XBA 
    TSB $0E
    LDA $0A
    STA $02, S
    RTI 
}

code_00A8F0 {
    TYX 
    LDA #$0E00
    TRB $0E
    LDA [$0A]
    INC $0A
    AND #$00FF
    XBA 
    TSB $0E
    LDA $0A
    STA $02, S
    RTI 
}

code_00A905 {
    TYX 
    LDA $0E
    EOR #$4000
    STA $0E
    LDA $0A
    STA $02, S
    RTI 
}

code_00A912 {
    TYX 
    LDA $0E
    EOR #$8000
    STA $0E
    LDA $0A
    STA $02, S
    RTI 
}

code_00A91F {
    TYX 
    LDA #$4000
    TRB $0E
    LDA $0A
    STA $02, S
    RTI 
}

code_00A92A {
    TYX 
    LDA #$4000
    TSB $0E
    LDA $0A
    STA $02, S
    RTI 
}

code_00A935 {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_00A945
    ORA #$FF00

  loc_00A945:
    CLC 
    ADC $14
    STA $14
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_00A959
    ORA #$FF00

  loc_00A959:
    CLC 
    ADC $16
    STA $16
    LDA $0A
    STA $02, S
    RTI 
}

code_00A963 {
    PHY 
    PHB 
    LDA [$0A]
    INC $0A
    INC $0A
    TAY 
    LDA [$0A]
    INC $0A
    AND #$00FF
    SEP #$20
    PHA 
    PLB 
    REP #$20
    LDA #$0000
    TCD 
    JSL $@chunk_3B7DD.code_03DF3E
    PLB 
    PLA 
    TAX 
    TCD 
    LDA #$0001
    TSB $09FA
    LDA $0A
    STA $02, S
    RTI 
}

code_00A990 {
    TYX 
    LDA $worldReadyFlag
    CMP #$000F
    BEQ loc_00A9A2
    LDA $0A
    DEC 
    DEC 
    STA $00
    PLA 
    PLA 
    RTL 

  loc_00A9A2:
    LDA #$0F00
    STA $joypadMaskInv
    PHB 
    SEP #$20
    LDA $0C
    PHA 
    PLB 
    REP #$20
    LDA $joypadMaskStd
    STZ $joypadMaskStd
    PHA 
    LDA $10
    AND #$0800
    PHA 
    LDA #$0800
    TRB $10
    LDA [$0A]
    INC $0A
    INC $0A
    JSL $@chunk_028000.code_02B9FF
    ASL 
    PHA 
    LDA [$0A]
    INC $0A
    INC $0A
    CLC 
    ADC $01, S
    TAY 
    PLA 
    PLA 
    TSB $10
    PLA 
    STA $joypadMaskStd
    STZ $joypadMaskInv
    LDA $0000, Y
    PLB 
    STA $02, S
    RTI 
}

code_00A9EB {
    TYX 
    LDA $0A
    PHA 
    SEP #$20
    LDA $0C
    PHA 
    JSL $@code_008181
    PLA 
    STA $0C
    REP #$20
    PLA 
    STA $0A
    LDA $10
    AND #$0800
    PHA 
    LDA #$0800
    TRB $10
    LDA $joypadMaskStd
    STZ $joypadMaskStd
    PHA 
    PHB 
    SEP #$20
    LDA $0C
    PHA 
    PLB 
    REP #$20
    LDA [$0A]
    INC $0A
    INC $0A
    TAY 
    JSL $@chunk_028000.code_02B05F
    PLB 
    PLA 
    STA $joypadMaskStd
    LDA #$0F00
    TRB $joypadHeld
    PLA 
    TSB $10
    LDA $0A
    STA $02, S
    RTI 
}

code_00AA39 {
    TYX 
    LDA #$0000
    SEP #$20
    PHX 
    PHD 
    TCD 
    JSL $@chunk_028000.code_028168
    PLD 
    PLX 
    JSL $@chunk_028000.code_0282E1
    STZ $HDMAEN
    REP #$20
    LDA #$0000
    STA $worldReadyFlag
    LDA $10
    AND #$0800
    PHA 
    LDA #$0800
    TRB $10
    LDA $joypadMaskStd
    STZ $joypadMaskStd
    PHA 
    PHB 
    SEP #$20
    LDA $0C
    PHA 
    PLB 
    REP #$20
    LDA [$0A]
    INC $0A
    INC $0A
    TAY 
    JSL $@chunk_028000.code_02B05F
    PLB 
    PLA 
    STA $joypadMaskStd
    LDA #$0F00
    TRB $joypadHeld
    PLA 
    TSB $10
    LDA #$0000
    SEP #$20
    PHX 
    PHD 
    TCD 
    JSL $@chunk_028000.code_028168
    PLD 
    PLX 
    JSL $@chunk_028000.code_0282D4
    LDA #$0F
    STA $INIDISP
    LDA $0066
    STA $HDMAEN
    REP #$20
    LDA #$000F
    STA $worldReadyFlag
    LDA $0A
    STA $02, S
    RTI 
}

code_00AAB5 {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $chatPtr, X
    LDA $0A
    STA $02, S
    RTI 
}

code_00AAC5 {
    TYX 
    LDA $0C
    STA $02
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

code_00AAD1 {
    TYX 
    LDA $0C
    STA $02
    LDA $0A
    STA $00
    PLA 
    PLA 
    RTL 
}

code_00AADD {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $00
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $02
    LDA [$0A]
    INC $0A
    INC $0A
    STA $08
    PLA 
    PLA 
    RTL 
}

code_00AAFA {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $00
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $02
    STZ $08
    PLA 
    PLA 
    RTL 
}

code_00AB11 {
    TYX 
    LDA $retPtr1, X
    BEQ loc_00AB22
    STA $02, S
    LDA #$0000
    STA $retPtr1, X
    RTI 

  loc_00AB22:
    PLA 
    PLA 
    RTL 
}

code_00AB25 {
    TYX 
    LDA $retPtr1, X
    BEQ loc_00AB39
    STA $02, S
    LDA #$0000
    STA $retPtr1, X
    LDA #$FFFF
    RTI 

  loc_00AB39:
    PLA 
    PLA 
    RTL 
}

code_00AB3C {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $retPtr1, X
    LDA $0A
    STA $02, S
    RTI 
}

code_00AB4C {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $00
    STA $02, S
    LDA [$0A]
    INC $0A
    AND #$00FF
    SEP #$20
    STA $02
    STA $04, S
    REP #$20
    RTI 
}

code_00AB67 {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    LDA $0A
    STA $retPtr1, X
    RTI 
}

code_00AB77 {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $00
    LDA $0A
    STA $retPtr1, X
    PLA 
    PLA 
    RTL 
}

code_00AB89 {
    TYX 
    CPX #$1000
    BCC loc_00ABA7
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $loopCounter, X
    LDA $0A
    STA $retPtr2, X
    STA $00
    LDA $0A
    STA $02, S
    RTI 

  loc_00ABA7:
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $loopCounterActor, X
    LDA $0A
    STA $loopStartPcActor, X
    STA $00
    LDA $0A
    STA $02, S
    RTI 
}

code_00ABBF {
    TYX 
    CPX #$1000
    BCC loc_00ABDE
    LDA $loopCounter, X
    DEC 
    BEQ loc_00ABD9
    STA $loopCounter, X
    LDA $retPtr2, X
    STA $00
    PLA 
    PLA 
    RTL 

  loc_00ABD9:
    LDA $0A
    STA $02, S
    RTI 

  loc_00ABDE:
    LDA $loopCounterActor, X
    DEC 
    BEQ loc_00ABD9
    STA $loopCounterActor, X
    LDA $loopStartPcActor, X
    STA $00
    PLA 
    PLA 
    RTL 
}

code_00ABF2 {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSR $&code_00B168
    LDA $0A
    STA $02, S
    RTI 
}

code_00AC02 {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    JSR $&code_00B168
    LDA $0A
    STA $02, S
    RTI 
}

code_00AC11 {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSR $&code_00B189
    LDA $0A
    STA $02, S
    RTI 
}

code_00AC21 {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    JSR $&code_00B189
    LDA $0A
    STA $02, S
    RTI 
}

code_00AC30 {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSR $&code_00B1AC
    BCS loc_00AC56
    BCC loc_00AC4B
}

code_00AC3F {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    JSR $&code_00B1AC
    BCS loc_00AC56

  loc_00AC4B:
    LDA [$0A]
    INC $0A
    AND #$00FF
    BNE loc_00AC68
    BRA loc_00AC5F

  loc_00AC56:
    LDA [$0A]
    INC $0A
    AND #$00FF
    BEQ loc_00AC68

  loc_00AC5F:
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 

  loc_00AC68:
    LDA [$0A]
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 
}

code_00AC73 {
    TYX 
    LDA $0A
    DEC 
    DEC 
    STA $00
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSR $&code_00B1AC
    BCS loc_00ACA5
    BCC loc_00AC9A
}

code_00AC88 {
    TYX 
    LDA $0A
    DEC 
    DEC 
    STA $00
    LDA [$0A]
    INC $0A
    INC $0A
    JSR $&code_00B1AC
    BCS loc_00ACA5

  loc_00AC9A:
    LDA [$0A]
    INC $0A
    AND #$00FF
    BEQ loc_00ACB1
    BRA loc_00ACAE

  loc_00ACA5:
    LDA [$0A]
    INC $0A
    AND #$00FF
    BNE loc_00ACB1

  loc_00ACAE:
    PLA 
    PLA 
    RTL 

  loc_00ACB1:
    LDA $0A
    STA $02, S
    RTI 
}

code_00ACB6 {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSL $@chunk_3B7DD.code_03E458
    BCS loc_00ACCF
    LDA [$0A]
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 

  loc_00ACCF:
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

code_00ACD8 {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSL $@chunk_3B7DD.code_03E54E
    LDA $0A
    STA $02, S
    RTI 
}

code_00ACE9 {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSL $@chunk_3B7DD.code_03E574
    BCC loc_00AD02
    LDA [$0A]
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 

  loc_00AD02:
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

code_00AD0B {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    SEP #$20
    LDY $inventoryEquippedIndex
    CMP $inventorySlots, Y
    REP #$20
    BEQ loc_00AD2A
    LDA [$0A]
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 

  loc_00AD2A:
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

code_00AD33 {
    TYX 
    LDA $enemyNum, X
    AND #$00FF
    BEQ loc_00AD40
    JSR $&code_00B125

  loc_00AD40:
    LDA $0A
    STA $02, S
    RTI 
}

code_00AD45 {
    LDA [$0A]
    INC $0A
    INC $0A
    TAX 
    LDA $0000, X
    AND #$00FF
    ASL 
    STA $0000
    PHB 
    SEP #$20
    LDA $0C
    PHA 
    PLB 
    REP #$20
    LDA [$0A]
    INC $0A
    INC $0A
    CLC 
    ADC $0000
    TAX 
    LDA $0000, X
    PLB 
    TYX 
    STA $02, S
    RTI 
}

code_00AD72 {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF

  loc_00AD7A:
    STA $08
    LDA $0C
    STA $02
    LDA $0A
    STA $00
    PLA 
    PLA 
    RTL 
}

code_00AD87 {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    BRA loc_00AD7A
}

code_00AD90 {
    TYX 
    LDA $2A
    AND #$00FF
    DEC 
    BMI loc_00ADA1
    SEP #$20
    STA $2A
    REP #$20
    BRA loc_00ADAF

  loc_00ADA1:
    REP #$20
    JSR $&code_00B1E7
    BCC loc_00ADAD
    LDA $0A
    STA $02, S
    RTI 

  loc_00ADAD:
    STA $2A

  loc_00ADAF:
    LDA $2B
    AND #$000F
    CLC 
    ADC $cameraTargetY
    STA $cameraTargetY
    CMP $cameraBoundsY
    BPL loc_00ADC3
    PLA 
    PLA 
    RTL 

  loc_00ADC3:
    LDA $0A
    STA $02, S
    RTI 
}

code_00ADC8 {
    TYX 
    LDA $2A
    AND #$00FF
    DEC 
    BMI loc_00ADD9
    SEP #$20
    STA $2A
    REP #$20
    BRA loc_00ADE7

  loc_00ADD9:
    REP #$20
    JSR $&code_00B1E7
    BCC loc_00ADE5
    LDA $0A
    STA $02, S
    RTI 

  loc_00ADE5:
    STA $2A

  loc_00ADE7:
    LDA $2B
    AND #$000F
    SEC 
    SBC $cameraTargetY
    BEQ loc_00ADF8
    BPL loc_00AE03
    EOR #$FFFF
    INC 

  loc_00ADF8:
    STA $cameraTargetY
    CMP $cameraOffsetY
    BMI loc_00AE03
    PLA 
    PLA 
    RTL 

  loc_00AE03:
    LDA $0A
    STA $02, S
    RTI 
}

code_00AE08 {
    TYX 
    LDA $2A
    AND #$00FF
    DEC 
    BMI loc_00AE19
    SEP #$20
    STA $2A
    REP #$20
    BRA loc_00AE27

  loc_00AE19:
    REP #$20
    JSR $&code_00B1E7
    BCC loc_00AE25
    LDA $0A
    STA $02, S
    RTI 

  loc_00AE25:
    STA $2A

  loc_00AE27:
    LDA $2B
    AND #$000F
    CLC 
    ADC $cameraTargetX
    STA $cameraTargetX
    CMP $cameraBoundsX
    BPL loc_00AE3B
    PLA 
    PLA 
    RTL 

  loc_00AE3B:
    LDA $0A
    STA $02, S
    RTI 
}

code_00AE40 {
    TYX 
    LDA $2A
    AND #$00FF
    DEC 
    BMI loc_00AE51
    SEP #$20
    STA $2A
    REP #$20
    BRA loc_00AE5F

  loc_00AE51:
    REP #$20
    JSR $&code_00B1E7
    BCC loc_00AE5D
    LDA $0A
    STA $02, S
    RTI 

  loc_00AE5D:
    STA $2A

  loc_00AE5F:
    LDA $2B
    AND #$000F
    SEC 
    SBC $cameraTargetX
    BEQ loc_00AE70
    BPL loc_00AE7B
    EOR #$FFFF
    INC 

  loc_00AE70:
    STA $cameraTargetX
    CMP $cameraOffsetX
    BMI loc_00AE7B
    PLA 
    PLA 
    RTL 

  loc_00AE7B:
    LDA $0A
    STA $02, S
    RTI 
}

code_00AE80 {
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
    BCC loc_00AEAB
    LDA $0062
    CLC 
    ADC #$0200
    STA $0062
    CLC 
    ADC #$0400
    STA $005E

  loc_00AEAB:
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

  loc_00AEE7:
    INY 
    LSR 
    BCC loc_00AEE7
    DEY 
    LDA $retPtr1, X
    CLC 
    ADC $1C

  loc_00AEF3:
    ASL 
    DEY 
    BNE loc_00AEF3
    AND #$00FF
    TAX 
    LDY #$0000

  loc_00AEFE:
    SEP #$20
    LDA $@binary_01C36C.binary_01C43D, X
    STA $L_WRMPYB
    BPL loc_00AF40
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
    BNE loc_00AEFE
    PLB 
    PLA 
    TAX 
    TCD 
    RTS 

  loc_00AF40:
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
    BNE loc_00AEFE
    PLB 
    PLA 
    TCD 
    TAX 
    RTS 
}

code_00AF69 {
    PHP 
    PHX 
    LDA $09FA
    BIT #$0040
    BNE loc_00AF85
    LDA $animScratch2, X
    BIT #$0001
    BEQ loc_00AFCA
    AND #$FFFE
    STA $animScratch2, X
    BRA loc_00AF8B

  loc_00AF85:
    AND #$FFBF
    STA $09FA

  loc_00AF8B:
    SEP #$20
    LDA $7F0008, X
    STA $WRMPYA
    LDX #$0000
    TXY 

  loc_00AF98:
    LDA $&binary_01C36C.binary_01C43D, Y
    STA $WRMPYB
    BPL loc_00AFCD
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
    BNE loc_00AF98

  loc_00AFCA:
    PLX 
    PLP 
    RTS 

  loc_00AFCD:
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
    BNE loc_00AF98
    PLX 
    PLP 
    RTS 
}

code_00AFF1 {
    LDY $0004, X
    BNE loc_00B006
    LDY $0006, X
    STY $0056
    BEQ loc_00B01A
    LDA #$0000
    STA $0004, Y
    BRA loc_00B01A

  loc_00B006:
    LDA $0006, X
    STA $0006, Y
    BNE loc_00B013
    STY $0058
    BRA loc_00B01A

  loc_00B013:
    TAY 
    LDA $0004, X
    STA $0004, Y

  loc_00B01A:
    JSR $&code_00B266
    RTS 
}

code_00B01E {
    LDA $characterForm
    ASL 
    CLC 
    ADC $characterForm
    ASL 
    TAY 
    LDA $&body_table, Y
    STA $spritesetPtr, X
    LDA $&body_table+2, Y
    AND #$00FF
    STA $7F0008, X
    LDA #$8000
    TRB $slopeCurvePtrB
    RTS 
}

code_00B040 {
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_00B04F
    ORA #$FF00

  loc_00B04F:
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
    BEQ loc_00B06C
    ORA #$FF00

  loc_00B06C:
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

code_00B07F {
    LDY $decelStepCounter
    LDA $0014, Y
    SEC 
    SBC $0018
    BMI loc_00B0CB
    STA $0000
    LDA $0016, Y
    SEC 
    SBC $001C
    BMI loc_00B0AF
    LDY #$0002
    CMP #$0010
    BCC loc_00B10D
    LDY #$0004
    LDA $0000
    CMP #$0010
    BCC loc_00B10D
    LDY #$0003
    BRA loc_00B10D

  loc_00B0AF:
    EOR #$FFFF
    INC 
    LDY #$0002
    CMP #$0010
    BCC loc_00B10D
    LDY #$0000
    LDA $0000
    CMP #$0010
    BCC loc_00B10D
    LDY #$0001
    BRA loc_00B10D

  loc_00B0CB:
    EOR #$FFFF
    INC 
    STA $0000
    LDA $0016, Y
    SEC 
    SBC $001C
    BMI loc_00B0F3
    LDY #$0006
    CMP #$0010
    BCC loc_00B10D
    LDY #$0004
    LDA $0000
    CMP #$0010
    BCC loc_00B10D
    LDY #$0005
    BRA loc_00B10D

  loc_00B0F3:
    EOR #$FFFF
    INC 
    LDY #$0006
    CMP #$0010
    BCC loc_00B10D
    LDY #$0000
    LDA $0000
    CMP #$0010
    BCC loc_00B10D
    LDY #$0007

  loc_00B10D:
    TYA 
    RTS 
}

code_00B10F {
    AND #$0007
    CLC 
    ADC #$0100
    JSR $&code_00B146
    RTL 
}

code_00B11A {
    AND #$0007
    CLC 
    ADC #$0100
    JSR $&code_00B125
    RTL 
}

code_00B125 {
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
    LDA $wramFlags, Y
    ORA $@code_00B1CE, X
    STA $wramFlags, Y
    REP #$20
    PLX 
    RTS 
}

code_00B146 {
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
    LDA $@code_00B1CE, X
    AND $wramFlags, Y
    SEC 
    BNE loc_00B164
    CLC 

  loc_00B164:
    REP #$20
    PLX 
    RTS 
}

code_00B168 {
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
    LDA $eventFlags, Y
    ORA $@code_00B1CE, X
    STA $eventFlags, Y
    REP #$20
    PLX 
    RTS 
}

code_00B189 {
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
    LDA $@code_00B1CE, X
    EOR #$FF
    AND $eventFlags, Y
    STA $eventFlags, Y
    REP #$20
    PLX 
    RTS 
}

code_00B1AC {
    PHX 
    STA $0000
    LSR 
    LSR 
    LSR 
    TAY 
    LDA #$0000
    SEP #$20

  loc_00B1B9:
    LDA $0000
    AND #$07
    TAX 
    LDA $@code_00B1CE, X
    AND $eventFlags, Y
    SEC 
    BNE loc_00B1CA
    CLC 

  loc_00B1CA:
    REP #$20
    PLX 
    RTS 
}

code_00B1CE {
    ORA ($02, X)
    TSB $08
    BPL loc_00B1F4
    RTI 
    BRA loc_00B1B9

  loc_00B1D7:
    JSR $&code_00A9EB
    BMI loc_00B1FE
    INC $82, X
    BRL loc_00D2A3

  loc_00B1E1:
    CLC 
    ADC #$1000
    TAY 
    RTS 
}

code_00B1E7 {
    PHP 
    PHX 
    LDA $scrollStepIndex
    INC $scrollStepIndex
    ASL 
    CLC 
    ADC $scrollStepTableBase

  loc_00B1F4:
    TAX 
    LDA $0000, X
    BIT #$FF00
    BEQ loc_00B201
    PLX 

  loc_00B1FE:
    PLP 
    CLC 
    RTS 

  loc_00B201:
    STZ $scrollStepIndex
    PLX 
    PLP 
    SEC 
    RTS 
}

code_00B208 {
    ASL 
    TAY 
    LDA $&table_01B06E, Y
    RTS 
}

code_00B20E {
    PHD 
    LDA #$0000
    TCD 
    JSL $@code_00B5AF
    PLD 
    BCS loc_00B239
    TXA 
    STA $0006, Y
    LDA $04
    STA $0004, Y
    TYA 
    STA $04
    PHX 
    LDX $0004, Y
    BNE loc_00B231
    STY $0056
    BRA loc_00B235

  loc_00B231:
    TYA 
    STA $0006, X

  loc_00B235:
    PLX 
    JSR $&code_00B288

  loc_00B239:
    RTS 
}

code_00B23A {
    PHD 
    LDA #$0000
    TCD 
    JSL $@code_00B5AF
    PLD 
    BCS loc_00B265
    TXA 
    STA $0004, Y
    LDA $06
    STA $0006, Y
    TYA 
    STA $06
    PHX 
    LDX $0006, Y
    BEQ loc_00B25E
    TYA 
    STA $0004, X
    BRA loc_00B261

  loc_00B25E:
    STY $0058

  loc_00B261:
    PLX 
    JSR $&code_00B288

  loc_00B265:
    RTS 
}

code_00B266 {
    LDA #$0000
    TCD 
    SEP #$20
    DEC $004E
    DEC $004E
    REP #$20
    TXA 
    STA [$4E]
    TCD 
    RTS 
}

code_00B279 {
    LDA $parentId, X
    BNE loc_00B280
    TDC 

  loc_00B280:
    TYX 
    STA $parentId, X
    TDC 
    TAX 
    RTS 
}

code_00B288 {
    PHX 
    LDA $0E
    STA $000E, Y
    LDA $10
    ORA #$2000
    AND #$F7FC
    STA $0010, Y
    LDA $12
    AND #$EFFF
    STA $0012, Y
    LDA $14
    STA $0014, Y
    LDA $16
    STA $0016, Y
    LDA $28
    STA $0028, Y
    LDA $2A
    STA $002A, Y
    TXA 
    STA $0024, Y
    LDA $statsPtr, X
    PHA 
    LDA $metaspritePtr, X
    PHA 
    LDA $spritesetPtr, X
    PHA 
    LDA $7F0008, X
    TYX 
    STA $7F0008, X
    PLA 
    STA $spritesetPtr, X
    PLA 
    STA $metaspritePtr, X
    PLA 
    STA $statsPtr, X
    LDA #$0000
    STA $parentId, X
    STA $002C, X
    STA $002E, X
    STA $moveScratch1, X
    STA $moveScratch2, X
    STA $0008, X
    STA $chatPtr, X
    LDA $sceneCurrent
    CMP #$00FF
    BEQ loc_00B327
    LDA #$0000
    STA $extendedFlags, X
    STA $onHitCallback, X
    STA $onDodgeCallback, X
    STA $onDeathCallback, X
    STA $onCollideCallback, X
    STA $scratch1010+6, X
    STA $free101C, X
    STA $chainDamage, X

  loc_00B327:
    PLX 
    RTS 
}

code_00B329 {
    PHD 
    LDA #$0000
    TCD 
    JSL $@chunk_3B7DD.code_03CB9B
    BCS loc_00B34B
    LDX $005C
    TXA 
    STA $0004, Y
    LDA #$0000
    STA $0008, Y
    STA $0006, Y
    TYA 
    STA $0006, X
    STY $005C

  loc_00B34B:
    PLD 
    RTS 
}

code_00B34D {
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
    JSL $@chunk_028000.code_02BDAF
    CPX #$4000
    BCS loc_00B3D3
    LDA $1A
    STA $18
    TXA 
    STA $1C

  loc_00B3A4:
    SEP #$20
    TAX 
    LDA $collisionLayer, X
    ORA #$F0
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
    BEQ loc_00B3D3
    LDA $1A
    STA $18
    JSR $&code_00B3D9
    LDA $1C
    BRA loc_00B3A4

  loc_00B3D3:
    REP #$20
    PLX 
    PLD 
    PLB 
    RTS 
}

code_00B3D9 {
    PHP 
    SEP #$20
    LDA $1C
    CLC 
    ADC #$10
    BCS loc_00B3E7
    STA $1C
    PLP 
    RTS 

  loc_00B3E7:
    XBA 
    CLC 
    ADC $mapRowStrideL0
    XBA 
    REP #$20
    STA $1C
    PLP 
    RTS 
}

code_00B3F3 {
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
    JSL $@chunk_028000.code_02BDAF
    CPX #$4000
    BCS loc_00B497
    LDA $1A
    STA $18
    TXA 
    STA $1C
    LDA $00
    BEQ loc_00B451
    JMP $&code_00B49D

  loc_00B451:
    TXA 

  loc_00B452:
    SEP #$20
    TAX 
    LDA $collisionLayer, X
    AND #$0F
    STA $collisionLayer, X
    DEC $18
    BEQ loc_00B472
    REP #$20
    TXA 
    INC 
    BIT #$000F
    BNE loc_00B452
    CLC 
    ADC #$00F0
    BRA loc_00B452

  loc_00B472:
    DEC $1E
    BEQ loc_00B497
    LDA $1A
    STA $18
    LDA $1C
    CLC 
    ADC #$10
    BCS loc_00B489
    STA $1C
    REP #$20
    LDA $1C
    BRA loc_00B452

  loc_00B489:
    STA $1C
    REP #$20
    LDA $1C
    CLC 
    ADC $mapBoundsX
    STA $1C
    BRA loc_00B452

  loc_00B497:
    REP #$20
    PLX 
    PLD 
    PLB 
    RTS 
}

code_00B49D {
    TXA 

  loc_00B49E:
    SEP #$20
    TAX 
    LDA $collisionLayer, X
    AND #$00
    STA $collisionLayer, X
    DEC $18
    BEQ loc_00B4BE
    REP #$20
    TXA 
    INC 
    BIT #$000F
    BNE loc_00B49E
    CLC 
    ADC #$00F0
    BRA loc_00B49E

  loc_00B4BE:
    DEC $1E
    BEQ loc_00B4E3
    LDA $1A
    STA $18
    LDA $1C
    CLC 
    ADC #$10
    BCS loc_00B4D5
    STA $1C
    REP #$20
    LDA $1C
    BRA loc_00B49E

  loc_00B4D5:
    STA $1C
    REP #$20
    LDA $1C
    CLC 
    ADC $mapBoundsX
    STA $1C
    BRA loc_00B49E

  loc_00B4E3:
    REP #$20
    PLX 
    PLD 
    PLB 
    RTS 
}

code_00B4E9 {
    PHD 
    LDA #$0000
    TCD 
    LDA $18
    AND #$FFF0
    BMI loc_00B52A
    CMP $cameraOffsetX
    BCC loc_00B52A
    CMP $cameraBoundsX
    BCS loc_00B52A
    LSR 
    LSR 
    LSR 
    LSR 
    STA $18
    LDA $1C
    BMI loc_00B52A
    CMP $cameraOffsetY
    BCC loc_00B52A
    CMP $cameraLowerYBound
    BCS loc_00B52A
    LSR 
    LSR 
    LSR 
    LSR 
    DEC 
    STA $1C
    JSL $@chunk_3B7DD.code_03D493
    CPY #$4000
    BCS loc_00B52A
    LDA [$80], Y
    BIT #$00F0
    BEQ loc_00B52D

  loc_00B52A:
    LDA #$000F

  loc_00B52D:
    PLD 
    RTS 
}

code_00B52F {
    CLC 
    ADC #$0200
    JSR $&code_00B168
    RTL 
}

code_00B537 {
    REP #$20
    AND #$00FF
    CLC 
    ADC #$0200
    JSR $&code_00B1AC
    RTL 
}

code_00B544 {
    AND #$00FF
    CLC 
    ADC #$0300
    JSR $&code_00B1AC
    RTL 
}

code_00B54F {
    AND #$00FF
    CLC 
    ADC #$0300
    JSR $&code_00B168
    RTL 
}

code_00B55A {
    AND #$00FF
    CLC 
    ADC #$0510
    JSR $&code_00B1AC
    RTL 
}

code_00B565 {
    AND #$00FF
    JSR $&code_00B1AC
    RTL 
}

code_00B56C {
    AND #$00FF
    JSR $&code_00B168
    RTL 
}

code_00B573 {
    AND #$00FF
    JSR $&code_00B189
    RTL 
}

code_00B57A {
    PHX 
    LDX #$0000
    LDA #$0000

  loc_00B581:
    STA $L_wramFlags, X
    INX 
    INX 
    CPX #$0020
    BNE loc_00B581
    PLX 
    RTL 
}

code_00B58E {
    AND #$00FF
    CLC 
    ADC #$0100
    JSR $&code_00B168
    RTL 
}

code_00B599 {
    AND #$00FF
    CLC 
    ADC #$0100
    JSR $&code_00B189
    RTL 
}

code_00B5A4 {
    AND #$00FF
    CLC 
    ADC #$0100
    JSR $&code_00B1AC
    RTL 
}

code_00B5AF {
    LDA ($4E)
    BMI loc_00B5BF
    TAY 
    LDA #$0000
    STA ($4E)
    INC $4E
    INC $4E
    CLC 
    RTL 

  loc_00B5BF:
    LDY #$1FC0
    SEC 
    RTL 
}

code_00B5C4 {
    COP [PaletteRestart]
    COP [PaletteStep]
    COP [KillThinker]
    RTL 
}

thinker_def_00B5CB [
  thinker-def < #00, #08, {

  code_00B5CD:
    COP [PaletteRestart]
    COP [PaletteStep]
    BRA code_00B5CD

  loc_00B5D3:
    LDY $decelStepCounter
    LDA $0028, Y
    STA $metaspritePtr, X
    COP [SpawnThinker] ( @code_00B63D )
    TYA 
    STA $chatPtr, X
    COP [SetEntryContinue]
    LDA $slopeCurvePtrB
    BIT #$0002
    BNE loc_00B61A
    PHX 
    LDY $decelStepCounter
    TYX 
    SEP #$20
    LDA $7F0008, X
    PLX 
    CMP #$8F
    BNE loc_00B60D
    REP #$20
    LDA $0028, Y
    CMP $metaspritePtr, X
    BNE loc_00B60D
    RTL 

  loc_00B60D:
    REP #$20
    JSR $&code_00B651
    COP [PaletteStart] ( #0B )
    COP [PaletteStep]
    COP [KillThinker]
    RTL 

  loc_00B61A:
    JSR $&code_00B651
    COP [SpawnThinker] ( @code_00B649 )
    TYA 
    STA $chatPtr, X
    COP [SetEntryContinue]
    LDA $slopeCurvePtrB
    BIT #$0002
    BEQ loc_00B632
    RTL 

  loc_00B632:
    JSR $&code_00B651
    COP [PaletteStart] ( #0B )
    COP [PaletteStep]
    COP [KillThinker]
    RTL 
} >
]

code_00B63D {
    COP [PaletteStart] ( #20 )
    COP [PaletteStep]

  loc_00B642:
    COP [PaletteStart] ( #21 )
    COP [PaletteStep]
    BRA loc_00B642
}

code_00B649 {
    COP [PaletteStart] ( #22 )
    COP [PaletteStep]
    COP [SetEntryContinue]
    RTL 
}

code_00B651 {
    PHX 
    PHD 
    LDA $chatPtr, X
    TCD 
    TAX 
    COP [KillThinker]
    PLD 
    PLX 
    RTS 
}

code_00B65E {
    COP [PaletteStart] ( #10 )
    COP [PaletteStep]
    COP [PaletteStart] ( #0E )
    COP [PaletteStep]
    COP [KillThinker]
    RTL 
}

thinker_def_00B66B [
  thinker-def < #00, #08, {

  code_00B66D:
    COP [BranchIfFlagByte] ( #1C, #01, &code_00B687 )
    COP [BranchIfFlagByte] ( #16, #00, &code_00B687 )

  loc_00B679:
    COP [PaletteStart] ( #02 )
    COP [PaletteStep]
    COP [SetFlagByte] ( #FF )
    COP [ExitIfFlagByte] ( #FF, #00 )
    BRA loc_00B679
} >
]

code_00B687 {
    COP [KillThinker]
    RTL 
}

thinker_def_00B68A [
  thinker-def < #00, #08, {

  code_00B68C:
    COP [BranchIfFlagByte] ( #1C, #01, &code_00B6A6 )
    COP [BranchIfFlagByte] ( #16, #00, &code_00B6A6 )

  loc_00B698:
    COP [PaletteStart] ( #4C )
    COP [PaletteStep]
    COP [SetFlagByte] ( #FF )
    COP [ExitIfFlagByte] ( #FF, #00 )
    BRA loc_00B698
} >
]

code_00B6A6 {
    COP [KillThinker]
    RTL 
}

thinker_def_00B6A9 [
  thinker-def < #00, #08, {

  loc_00B6AB:
    COP [PaletteStart] ( #03 )
    COP [SetEntryContinue]
    COP [BranchIfFlagByte] ( #01, #01, &code_00B6B7 )
    RTL 
} >
]

code_00B6B7 {
    COP [SpawnThinker] ( @code_00B6D5 )
    TYA 
    STA $chatPtr, X
    COP [SetEntryContinue]
    COP [ExitIfFlagByte] ( #01, #00 )
    PHX 
    PHD 
    LDA $chatPtr, X
    TAX 
    TCD 
    COP [KillThinker]
    PLD 
    PLX 
    BRA loc_00B6AB
}

code_00B6D5 {
    COP [PaletteStart] ( #03 )
    COP [PaletteStep]
    BRA code_00B6D5
}

thinker_def_00B6DC [
  thinker-def < #00, #08, {

  code_00B6DE:
    COP [BranchIfFlagByte] ( #22, #01, &code_00B706 )
    COP [BranchIfFlagByte] ( #21, #00, &code_00B706 )

  loc_00B6EA:
    COP [PaletteStart] ( #05 )
    COP [PaletteStep]
    SEP #$20
    LDA #$24
    STA $COLDATA
    LDA #$42
    STA $COLDATA
    REP #$20
    COP [SetFlagByte] ( #FF )
    COP [ExitIfFlagByte] ( #FF, #00 )
    BRA loc_00B6EA
} >
]

code_00B706 {
    COP [KillThinker]
    RTL 
}

thinker_def_00B709 [
  thinker-def < #00, #08, {

  code_00B70B:
    SEP #$20
    LDA #$66
    STA $COLDATA
    LDA #$82
    STA $COLDATA
    REP #$20
    COP [KillThinker]
    RTL 
} >
]

thinker_def_00B71C [
  thinker-def < #00, #08, {

  code_00B71E:
    COP [BranchIfFlagByte] ( #52, #01, &code_00B746 )
    COP [BranchIfFlagByte] ( #4D, #01, &code_00B731 )

  loc_00B72A:
    COP [PaletteStart] ( #1A )
    COP [PaletteStep]
    BRA loc_00B72A
} >
]

code_00B731 {
    COP [PaletteStart] ( #34 )
    COP [PaletteStep]
    COP [SetFlagByte] ( #FF )

  code_00B739:
    COP [PaletteStart] ( #33 )
    COP [PaletteStep]
    COP [BranchIfFlagByte] ( #FF, #01, &code_00B739 )
    BRA code_00B731
}

code_00B746 {
    PHX 
    LDX $005A
    COP [KillThinker]
    TXA 
    CLC 
    ADC #$0010
    TAX 
    COP [KillThinker]
    PLX 

  loc_00B755:
    PHX 
    LDA #$1421
    LDX #$0000

  loc_00B75C:
    STA $7F0A40, X
    INX 
    INX 
    CPX #$0020
    BNE loc_00B75C
    PLX 
    LDA #$1442
    STA $cgramPalette
    COP [PaletteStart] ( #36 )
    COP [PaletteStep]
    COP [SetFlagByte] ( #FF )
    COP [ExitIfFlagByte] ( #FF, #00 )
    BRA loc_00B755
}

thinker_def_00B77D [
  thinker-def < #00, #08, {

  loc_00B77F:
    COP [PaletteStart] ( #35 )
    COP [PaletteStep]
    COP [SetFlagByte] ( #FF )
    COP [ExitIfFlagByte] ( #FF, #00 )
    BRA loc_00B77F

  loc_00B78D:
    COP [KillThinker]
    RTL 
} >
]

thinker_def_00B790 [
  thinker-def < #00, #08, {

  code_00B792:
    SEP #$20
    LDA #$2B
    STA $COLDATA
    LDA #$44
    STA $COLDATA
    LDA #$82
    STA $COLDATA
    REP #$20
    COP [KillThinker]
    RTL 
} >
]

code_00B7A8 {
    BRK #$08

  loc_00B7AA:
    PHX 
    LDA #$0000
    LDX #$0000

  loc_00B7B1:
    STA $7F0A94, X
    INX 
    INX 
    CPX #$000E
    BNE loc_00B7B1
    PLX 
    COP [SetFlagByte] ( #FF )
    COP [ExitIfFlagByte] ( #FF, #00 )
    BRA loc_00B7AA

  loc_00B7C6:
    COP [KillThinker]
    RTL 
}

thinker_def_00B7C9 [
  thinker-def < #00, #08, {

  loc_00B7CB:
    COP [SetFlagByte] ( #FF )
    SEP #$20
    LDA #$03
    STA $CGADSUB
    REP #$20

  code_00B7D7:
    COP [BranchIfFlagByte] ( #0F, #01, &code_00B7F9 )
    COP [BranchIfFlagByte] ( #70, #00, &code_00B7EA )
    COP [PaletteStart] ( #1A )
    COP [PaletteStep]
    BRA loc_00B7F1
} >
]

code_00B7EA {
    COP [PaletteStart] ( #33 )
    COP [PaletteStep]
    BRA loc_00B7F1

  loc_00B7F1:
    COP [BranchIfFlagByte] ( #FF, #01, &code_00B7D7 )
    BRA loc_00B7CB
}

code_00B7F9 {
    COP [ExitIfFlagByte] ( #0F, #00 )
    BRA code_00B7D7
}

thinker_def_00B7FF [
  thinker-def < #00, #08, {

  code_00B801:
    COP [BranchIfFlagByte] ( #96, #01, &code_00B80E )

  loc_00B807:
    COP [PaletteStart] ( #42 )
    COP [PaletteStep]
    BRA loc_00B807
} >
]

code_00B80E {
    COP [SpawnThinker] ( @code_00B81A )

  loc_00B813:
    COP [PaletteStart] ( #48 )
    COP [PaletteStep]
    BRA loc_00B813
}

code_00B81A {
    LDA $animScratch2, X
    ORA #$0800
    STA $animScratch2, X

  loc_00B825:
    COP [PaletteStart] ( #72 )
    COP [PaletteStep]
    BRA loc_00B825
}

thinker_def_00B82C [
  thinker-def < #00, #08, {

  code_00B82E:
    COP [ExitIfFlagByte] ( #F5, #01 )
    COP [SetEntryContinue]
    COP [PaletteStart] ( #65 )
    COP [PaletteStep]
    RTL 
} >
]

thinker_def_00B83A [
  thinker-def < #00, #08, {

  code_00B83C:
    COP [SetEntryContinue]
    SEP #$20
    LDA #$02
    STA $CGADSUB
    REP #$20
    RTL 
} >
]

thinker_def_00B848 [
  thinker-def < #04, #08, {

  code_00B84A:
    COP [SetEntryContinue]
    LDA $cameraTargetY
    CLC 
    ADC #$0080
    LSR 
    LSR 
    LSR 
    LSR 
    AND #$00F8
    LSR 
    LSR 
    LSR 
    CLC 
    ADC #$00E0
    SEP #$20
    STA $COLDATA
    REP #$20
    RTL 
} >
]

thinker_def_00B869 [
  thinker-def < #00, #08, {

  code_00B86B:
    COP [SetEntryContinue]
    SEP #$20
    LDA #$02
    STA $W12SEL
    REP #$20
    RTL 
} >
]

code_00B877 {
    BRK #$08

  code_00B879:
    COP [PaletteStart] ( #18 )
    COP [PaletteStep]
    COP [KillThinker]
    RTL 
}

code_00B881 {
    BRK #$08

  code_00B883:
    COP [PaletteStart] ( #19 )
    COP [PaletteStep]
    COP [KillThinker]
    RTL 
}

code_00B88B {
    BRK #$08

  code_00B88D:
    COP [PaletteStart] ( #1B )
    COP [PaletteStep]
    COP [KillThinker]
    RTL 
}

code_00B895 {
    BRK #$08

  code_00B897:
    COP [PaletteStart] ( #1C )
    COP [PaletteStep]
    COP [KillThinker]
    RTL 
}

code_00B89F {
    BRK #$08

  code_00B8A1:
    COP [PaletteStart] ( #40 )
    COP [PaletteStep]
    COP [KillThinker]
    RTL 
}

code_00B8A9 {
    BRK #$08

  code_00B8AB:
    COP [PaletteStart] ( #1F )
    COP [PaletteStep]
    COP [KillThinker]
    RTL 
}

code_00B8B3 {
    BRK #$08
    COP [PaletteStartLoop] ( #14, #07 )
    COP [PaletteStepLoop]
    COP [PaletteStart] ( #0B )
    COP [PaletteStep]
    COP [KillThinker]
    RTL 
}

thinker_def_00B8C3 [
  thinker-def < #00, #08, {

  code_00B8C5:
    COP [ExitIfFlagByte] ( #2B, #01 )
    COP [SetEntryContinue]
    LDY $decelStepCounter
    LDA $0014, Y
    CMP #$01B0
    BCC loc_00B8E0
    SEP #$20
    LDA #$00
    STA $CGADSUB
    REP #$20
    RTL 

  loc_00B8E0:
    SEP #$20
    LDA #$50
    STA $CGADSUB
    REP #$20
    RTL 
} >
]

thinker_def_00B8EA [
  thinker-def < #00, #08, {

  code_00B8EC:
    COP [PaletteStart] ( #50 )
    COP [PaletteStep]
    COP [PaletteStart] ( #52 )
    COP [PaletteStep]
    COP [PaletteStart] ( #54 )
    COP [PaletteStep]
    COP [KillThinker]
    RTL 
} >
]

thinker_def_00B8FE [
  thinker-def < #00, #08, {

  code_00B900:
    COP [PaletteStart] ( #51 )
    COP [PaletteStep]
    COP [PaletteStart] ( #53 )
    COP [PaletteStep]
    COP [PaletteStart] ( #55 )
    COP [PaletteStep]
    COP [KillThinker]
    RTL 
} >
]

thinker_def_00B912 [
  thinker-def < #00, #08, {

  code_00B914:
    COP [PaletteStart] ( #56 )
    COP [PaletteStep]
    COP [PaletteStart] ( #57 )
    COP [PaletteStep]
    COP [PaletteStart] ( #58 )
    COP [PaletteStep]
    COP [KillThinker]
    RTL 
} >
]

thinker_def_00B926 [
  thinker-def < #04, #08, {

  code_00B928:
    COP [QueueDma] ( @dma_channel_00B92F, #2C )
    RTL 
} >
]

dma_channel_00B92F [
  dma-channel < #6F, #15, #70 >   ;00
  dma-channel < #15, #01, #00 >   ;01
]

thinker_def_00B936 [
  thinker-def < #04, #08, {

  code_00B938:
    COP [QueueDma] ( @dma_channel_00B945, #09 )
    COP [QueueDma] ( @dma_channel_00B94A, #31 )
    RTL 
} >
]

dma_channel_00B945 [
  dma-channel < #27, #78, #01 >   ;00
  dma-channel < #7C, #00, #27 >   ;01
]

dma_channel_00B94A [
  dma-channel < #27, #00, #01 >   ;00
  dma-channel < #44, #00, #04 >   ;01
]

thinker_def_00B94F [
  thinker-def < #04, #08, {

  code_00B951:
    JSR $&code_00BB33
    PHX 
    LDX #$0000
    LDA #$7100
    STA $0000

  loc_00B95E:
    LDA $@code_00B9EC, X
    STA $tileStagingBuffer, X
    STA $7E7200, X
    LDA $0000
    STA $7E7001, X
    CLC 
    ADC #$0200
    STA $7E7201, X
    LDA $0000
    INC 
    INC 
    STA $0000
    INX 
    INX 
    INX 
    CPX #$0021
    BCC loc_00B95E
    LDA #$0000
    STA $tileStagingBuffer, X
    PLX 
    COP [SetEntryExit]
    COP [BranchIfFlagByte] ( #FF, #00, &code_00B951 )
    PHX 
    PHB 
    SEP #$20
    LDA #$7E
    PHA 
    PLB 
    REP #$20
    LDA $0036
    LSR 
    BCS loc_00B9C7
    LDX #$0000
    TXY 

  loc_00B9AD:
    INX 
    LDA $@code_00B9EC, X
    CLC 
    ADC $0720, Y
    STA $0720, Y
    STA $7100, Y
    INY 
    INY 
    INX 
    INX 
    CPX #$0021
    BCC loc_00B9AD
    BRA loc_00B9E3

  loc_00B9C7:
    LDX #$0000
    TXY 

  loc_00B9CB:
    INX 
    LDA $@code_00B9EC, X
    CLC 
    ADC $0720, Y
    STA $0720, Y
    STA $7300, Y
    INY 
    INY 
    INX 
    INX 
    CPX #$0021
    BCC loc_00B9CB

  loc_00B9E3:
    PLB 
    PLX 
    COP [BindSineHdma] ( $7E7000, #0F )
    RTL 
} >
]

code_00B9EC {
    AND [$FB]
    SBC $@3FFC18, X
    BPL loc_00B9F1
    SBC $@3FFE08, X
    PHP 
    SBC $0020FF, X
    BRK #$08
    ORA ($00, X)
    PHP 
    COP [GenHdmaSine]
    BPL loc_00BA09
    BRK #$18
    TSB $00
    PLP 
    ORA $00
    BRK #$04
    PHP 

  code_00BA10:
    PHB 
    SEP #$20
    LDA #$7E
    PHA 
    PLB 
    REP #$20
    LDA #$7500
    STA $0000
    LDY #$0000

  loc_00BA22:
    LDA #$0008
    STA $7400, Y
    STA $7600, Y
    LDA $0000
    STA $7401, Y
    CLC 
    ADC #$0200
    STA $7601, Y
    LDA $0000
    CLC 
    ADC #$0002
    AND #$FFEF
    STA $0000
    INY 
    INY 
    INY 
    CPY #$0054
    BCC loc_00BA22
    LDA #$0000
    STA $7400, Y
    LDA #$0027
    STA $7400
    STA $7600
    LDA #$074E
    STA $7401
    LDA #$074E
    STA $7601
    PLB 
    LDA #$0040
    STA $animScratch+2, X
    LDA #$0080
    STA $7F0008, X
    LDA #$0004
    STA $0E
    COP [SetEntryExit]
    COP [BranchIfFlagByte] ( #FF, #00, &code_00BA10 )
    PHX 
    PHB 
    SEP #$20
    LDA #$7E
    PHA 
    PLB 
    REP #$20
    LDA $animScratch+2, X
    STA $0000
    LDA $7F0008, X
    SEP #$20
    STA $L_WRMPYA
    REP #$20
    LDA $0E
    TAX 
    LDA #$0007
    STA $000E
    LDY #$0100
    LDA $0036
    LSR 
    BCC loc_00BAB6
    LDY #$0300

  loc_00BAB6:
    SEP #$20
    CLC 
    LDA $@binary_01C36C.binary_01C43D, X
    BPL loc_00BAC3
    EOR #$FF
    INC 
    SEC 

  loc_00BAC3:
    STA $L_WRMPYB
    REP #$20
    INY 
    INY 
    NOP 
    LDA $L_RDDIVL
    BCC loc_00BAD6
    EOR #$FFFF
    INC 

  loc_00BAD6:
    STA $73FE, Y
    TXA 
    CLC 
    ADC $0000
    AND #$00FF
    TAX 
    DEC $000E
    BPL loc_00BAB6
    PLB 
    PLX 
    LDA $0E
    CLC 
    ADC #$0001
    AND #$00FF
    STA $0E
    COP [BindSineHdma] ( $7E7400, #11 )
    RTL 
}

parallax_thinker [
  actor-def < #04, #08, #20, {

  code_00BAFE:
    AND ($BB, S), Y
    LDA #$0000
    STA $chatPtr, X
    COP [SetEntryContinue]
    LDA $chatPtr, X
    STA $0012
    INC 
    STA $chatPtr, X
    JSR $&code_00BB44
    SEP #$20
    LDA $0002
    XBA 
    LDA $0060
    LDY $005E
    JSL $@chunk_3B7DD.code_03DE5C
    LDA #$01
    STA $0060
    REP #$20
    STZ $005E
    RTL 
} >
]

code_00BB33 {
    LDY #$0000
    LDA #$0000

  loc_00BB39:
    STA $0720, Y
    INY 
    INY 
    CPY #$0030
    BNE loc_00BB39
    RTS 
}

code_00BB44 {
    PHX 
    LDA #$0000
    TCD 
    LDA $effectDeltaX
    STA $1A
    LDA #$00E0
    STA $10
    LDA $animScratch+2, X
    ASL 
    TAX 
    LDA $&parallax_table, X
    TAX 
    LDA $0003, X
    BIT #$0040
    BEQ loc_00BB6D
    LDA $1A
    ASL 
    ASL 
    ASL 
    ASL 
    STA $1A

  loc_00BB6D:
    LDA $savedCameraDelta
    STA $1C
    LDA $bg1ScrollH
    STA $18
    LDA $0003, X
    BIT #$0080
    BEQ loc_00BB89
    LDA $bg2ScrollH
    STA $1C
    LDA $bg1ScrollV
    STA $18

  loc_00BB89:
    LDA $0012
    LSR 
    BCS loc_00BB9F
    LDA $0002, X
    STA $64
    STA $60
    LDA $0000, X
    STA $62
    STA $5E
    BRA loc_00BBB1

  loc_00BB9F:
    LDA $0002, X
    STA $64
    STA $60
    LDA $0000, X
    CLC 
    ADC #$0200
    STA $62
    STA $5E

  loc_00BBB1:
    LDA $0003, X
    AND #$003F
    STA $02
    JSR $&code_00BD2A
    LDA $0004, X
    AND #$00FF
    STA $00
    TXA 
    CLC 
    ADC #$0005
    TAX 
    LDA $00
    CMP #$0004
    BEQ loc_00BBFE
    CMP #$0009
    BEQ loc_00BC23

  loc_00BBD6:
    LDA $0000, X
    BEQ loc_00BBF1
    CLC 
    ADC $1C
    STA $1C
    BMI loc_00BBEE
    PHA 
    JSR $&code_00BDD3
    TXA 
    CLC 
    ADC $00
    TAX 
    PLA 
    BRA loc_00BBD6

  loc_00BBEE:
    JSR $&code_00BD3D

  loc_00BBF1:
    LDA #$0000
    STA [$62]
    STZ $62
    STZ $64
    PLA 
    TCD 
    TAX 
}

code_00BBFD {
    RTS 

  loc_00BBFE:
    LDA $0000, X
    BEQ loc_00BC16
    CLC 
    ADC $1C
    STA $1C
    BMI loc_00BC13
    TAY 
    TXA 
    CLC 
    ADC $00
    TAX 
    TYA 
    BRA loc_00BBFE

  loc_00BC13:
    JSR $&code_00BD8F

  loc_00BC16:
    LDA #$0000
    STA [$62]
    STZ $62
    STZ $64
    PLA 
    TCD 
    TAX 
    RTS 

  loc_00BC23:
    DEC $00
    STZ $08

  loc_00BC27:
    LDA $0000, X
    BMI loc_00BC70
    SEC 
    SBC $bg1ScrollH
    BMI loc_00BC39
    CMP #$00FF
    BCS loc_00BC69
    BRA loc_00BC46

  loc_00BC39:
    CLC 
    ADC $0002, X
    BMI loc_00BC69
    CMP #$00FF
    BCS loc_00BC69
    BRA loc_00BC46

  loc_00BC46:
    LDA $0004, X
    SEC 
    SBC $bg2ScrollH
    BMI loc_00BC59
    CMP #$00FF
    BCS loc_00BC69
    JSR $&code_00BC8B
    BRA loc_00BC69

  loc_00BC59:
    CLC 
    ADC $0006, X
    BEQ loc_00BC69
    BMI loc_00BC69
    CMP #$00FF
    BCS loc_00BC69
    JSR $&code_00BC8B

  loc_00BC69:
    TXA 
    CLC 
    ADC $00
    TAX 
    BRA loc_00BC27

  loc_00BC70:
    LDY #$0001
    LDA #$0001
    STA [$62]
    LDA #$0000
    STA [$62], Y
    LDY #$0003
    STA [$62], Y
    LDY #$0004
    STA [$62], Y
    PLA 
    TCD 
    TAX 
    RTS 
}

code_00BC8B {
    LDA $0004, X
    SEC 
    SBC $bg2ScrollH
    BCS loc_00BC9E
    CLC 
    ADC $0006, X
    STA $26
    STZ $24
    BRA loc_00BCA5

  loc_00BC9E:
    STA $24
    LDA $0006, X
    STA $26

  loc_00BCA5:
    LDA $0000, X
    SEC 
    SBC $bg1ScrollH
    BCS loc_00BCBA
    CLC 
    ADC $0002, X
    AND #$00FF
    XBA 
    STA $20
    BRA loc_00BCCA

  loc_00BCBA:
    STA $20
    CLC 
    ADC $0002, X
    CMP #$0100
    BCC loc_00BCC8
    LDA #$FFFF

  loc_00BCC8:
    STA $21

  loc_00BCCA:
    LDY $20
    JSR $&code_00BCD0
    RTS 
}

code_00BCD0 {
    LDA $24
    SEC 
    SBC $08
    BEQ loc_00BD01
    STA $0E
    CLC 
    ADC $08
    STA $08
    LDA $0E

  loc_00BCE0:
    STZ $0E
    CMP #$0080
    BMI loc_00BCF0
    SEC 
    SBC #$007F
    STA $0E
    LDA #$007F

  loc_00BCF0:
    STA [$62]
    INC $62
    LDA #$0000
    STA [$62]
    INC $62
    INC $62
    LDA $0E
    BNE loc_00BCE0

  loc_00BD01:
    LDA $26
    CLC 
    ADC $08
    STA $08
    LDA $26

  loc_00BD0A:
    STZ $26
    CMP #$0080
    BMI loc_00BD1A
    SEC 
    SBC #$007F
    STA $26
    LDA #$007F

  loc_00BD1A:
    STA [$62]
    INC $62
    TYA 
    STA [$62]
    INC $62
    INC $62
    LDA $26
    BNE loc_00BD0A
    RTS 
}

code_00BD2A {
    LDA $02
    TAY 
    LDA $&binary_01D8E7, Y
    AND #$0007
    TAY 
    LDA $&binary_01D8E7.binary_01D927, Y
    AND #$00FF
    STA $04
    RTS 
}

code_00BD3D {
    EOR #$FFFF
    INC 
    PHA 
    JSR $&code_00BDD3
    LDA $10
    SEC 
    SBC $01, S
    STA $10
    PLA 

  loc_00BD4D:
    STZ $0E
    CMP #$0080
    BMI loc_00BD5D
    SEC 
    SBC #$007F
    STA $0E
    LDA #$007F

  loc_00BD5D:
    STA [$62]
    LDY #$0001
    LDA $06
    LSR 
    LSR 
    LSR 
    LSR 
    BIT #$0800
    BEQ loc_00BD70
    ORA #$F000

  loc_00BD70:
    STA [$62], Y
    LDA $62
    CLC 
    ADC $04
    STA $62
    LDA $0E
    BNE loc_00BD4D
    LDA $10
    BPL loc_00BD82
    RTS 

  loc_00BD82:
    TXA 
    CLC 
    ADC $00
    TAX 
    LDA $0000, X
    BNE loc_00BD8D
    RTS 

  loc_00BD8D:
    BRA code_00BD3D
}

code_00BD8F {
    EOR #$FFFF
    INC 
    PHA 
    LDA $10
    SEC 
    SBC $01, S
    STA $10
    PLA 

  loc_00BD9C:
    STZ $0E
    CMP #$0080
    BMI loc_00BDAC
    SEC 
    SBC #$007F
    STA $0E
    LDA #$007F

  loc_00BDAC:
    STA [$62]
    LDA $0002, X
    LDY #$0001
    STA [$62], Y
    LDA $62
    CLC 
    ADC $04
    STA $62
    LDA $0E
    BNE loc_00BD9C
    LDA $10
    BPL loc_00BDC6
    RTS 

  loc_00BDC6:
    TXA 
    CLC 
    ADC $00
    TAX 
    LDA $0000, X
    BNE loc_00BDD1
    RTS 

  loc_00BDD1:
    BRA code_00BD8F
}

code_00BDD3 {
    LDA $0004, X
    BEQ loc_00BDEB
    LDY $18
    JSL $@chunk_028000.code_028125
    CLC 
    ADC $0006, X
    LDY $0002, X
    STA $0000, Y
    STA $06
    RTS 

  loc_00BDEB:
    LDY $0002, X
    LDA $0006, X
    CLC 
    ADC $0000, Y
    CLC 
    ADC $1A
    STA $0000, Y
    STA $06
    RTS 
}

thinker_def_00BDFE [
  thinker-def < #04, #08, {

  code_00BE00:
    COP [QueueDma] ( @dma_channel_00BE07, #12 )
    RTL 
} >
]

dma_channel_00BE07 [
  dma-channel < #70, #00, #00 >   ;00
  dma-channel < #30, #00, #00 >   ;01
  dma-channel < #0C, #0B, #00 >   ;02
  dma-channel < #0C, #0F, #00 >   ;03
  dma-channel < #0C, #13, #00 >   ;04
  dma-channel < #0C, #17, #00 >   ;05
  dma-channel < #40, #20, #00 >   ;06
]

dma_channel_00BE1D [
]

dma_channel_00BE1E [
]

thinker_def_00BE1F [
  thinker-def < #04, #08, {

  code_00BE21:
    LDA $0D96
    BMI loc_00BE2C
    LDA $0036
    LSR 
    BCC loc_00BE37

  loc_00BE2C:
    LDA $0D92
    BPL loc_00BE3F
    LDA #$00FF
    STA $WH0

  loc_00BE37:
    COP [QueueDma] ( @dma_channel_00BEBC, #26 )
    BRA loc_00BE5C

  loc_00BE3F:
    BNE loc_00BE49
    COP [QueueDma] ( @dma_channel_00BEBD, #26 )
    BRA loc_00BE5C

  loc_00BE49:
    DEC 
    BNE loc_00BE54
    COP [QueueDma] ( @dma_channel_00BEC7, #26 )
    BRA loc_00BE5C

  loc_00BE54:
    COP [QueueDma] ( @dma_channel_00BED1, #26 )
    BRA loc_00BE5C

  loc_00BE5C:
    LDA $0D96
    BPL loc_00BE6F
    LDA #$00FF
    STA $WH0
    COP [QueueDma] ( @dma_channel_00BEBC, #26 )
    BRA loc_00BE8C

  loc_00BE6F:
    BNE loc_00BE79
    COP [QueueDma] ( @dma_channel_00BEBD, #26 )
    BRA loc_00BE8C

  loc_00BE79:
    DEC 
    BNE loc_00BE84
    COP [QueueDma] ( @dma_channel_00BEC7, #26 )
    BRA loc_00BE8C

  loc_00BE84:
    COP [QueueDma] ( @dma_channel_00BED1, #26 )
    BRA loc_00BE8C

  loc_00BE8C:
    LDA $0D98
    BPL loc_00BE98
    COP [QueueDma] ( @dma_channel_00BEDE, #26 )
    RTL 

  loc_00BE98:
    BNE loc_00BEA1
    COP [QueueDma] ( @dma_channel_00BEDF, #26 )
    RTL 

  loc_00BEA1:
    DEC 
    BNE loc_00BEAB
    COP [QueueDma] ( @dma_channel_00BEE9, #26 )
    RTL 

  loc_00BEAB:
    DEC 
    BNE loc_00BEB5
    COP [QueueDma] ( @dma_channel_00BEF3, #26 )
    RTL 

  loc_00BEB5:
    COP [QueueDma] ( @dma_channel_00BEFD, #26 )
    RTL 
} >
]

dma_channel_00BEBC [
]

dma_channel_00BEBD [
  dma-channel < #4F, #FF, #00 >   ;00
  dma-channel < #1F, #10, #F0 >   ;01
  dma-channel < #60, #FF, #00 >   ;02
]

dma_channel_00BEC7 [
  dma-channel < #6F, #FF, #00 >   ;00
  dma-channel < #1F, #10, #F0 >   ;01
  dma-channel < #60, #FF, #00 >   ;02
]

dma_channel_00BED1 [
  dma-channel < #10, #FF, #00 >   ;00
  dma-channel < #7F, #FF, #00 >   ;01
  dma-channel < #1F, #10, #F0 >   ;02
  dma-channel < #60, #FF, #00 >   ;03
]

dma_channel_00BEDE [
]

dma_channel_00BEDF [
  dma-channel < #4F, #FF, #00 >   ;00
  dma-channel < #0F, #30, #D0 >   ;01
  dma-channel < #60, #FF, #00 >   ;02
]

dma_channel_00BEE9 [
  dma-channel < #5F, #FF, #00 >   ;00
  dma-channel < #0F, #30, #D0 >   ;01
  dma-channel < #60, #FF, #00 >   ;02
]

dma_channel_00BEF3 [
  dma-channel < #6F, #FF, #00 >   ;00
  dma-channel < #0F, #30, #D0 >   ;01
  dma-channel < #60, #FF, #00 >   ;02
]

dma_channel_00BEFD [
  dma-channel < #7F, #FF, #00 >   ;00
  dma-channel < #0F, #30, #D0 >   ;01
  dma-channel < #60, #FF, #00 >   ;02
]

thinker_def_00BF07 [
  thinker-def < #04, #08, {

  code_00BF09:
    COP [QueueDma] ( @dma_channel_00BF10, #12 )
    RTL 
} >
]

dma_channel_00BF10 [
  dma-channel < #70, #00, #00 >   ;00
  dma-channel < #40, #00, #00 >   ;01
  dma-channel < #0C, #04, #00 >   ;02
  dma-channel < #0C, #08, #00 >   ;03
  dma-channel < #20, #0C, #00 >   ;04
  dma-channel < #20, #00, #00 >   ;05
]

thinker_def_00BF23 [
  thinker-def < #04, #08, {

  code_00BF25:
    LDA #$0001
    STA $7F0008, X
    COP [InitSineHdma] ( #$8800, #08 )
    LDA #$0000
    STA $7E8C30
    STA $7E8E30
    COP [SetEntryExit]
    COP [TickSineHdma] ( #05, #02 )
    COP [BindSineHdma] ( $7E8800, #0F )
    COP [BindSineHdma] ( $7E8C00, #10 )
    RTL 
} >
]

thinker_def_00BF4F [
  thinker-def < #04, #08, {

  code_00BF51:
    COP [QueueDma] ( @dma_channel_00BF58, #10 )
    RTL 
} >
]

dma_channel_00BF58 [
  dma-channel < #70, #00, #00 >   ;00
  dma-channel < #10, #00, #00 >   ;01
  dma-channel < #01, #00, #00 >   ;02
  dma-channel < #01, #00, #00 >   ;03
]

thinker_def_00BF65 [
  thinker-def < #04, #08, {

  code_00BF67:
    LDA #$0001
    STA $7F0008, X
    COP [InitSineHdma] ( #$8800, #08 )
    LDA #$0000
    STA $7E8C30
    STA $7E8E30
    COP [SetEntryExit]
    COP [BranchIfFlagByte] ( #FF, #00, &code_00BF67 )
    COP [TickSineHdma] ( #05, #02 )
    COP [BindSineHdma] ( $7E8C00, #10 )
    RTL 
} >
]

thinker_def_00BF91 [
  thinker-def < #04, #08, {

  code_00BF93:
    LDA #$0008
    STA $7F0008, X
    COP [InitSineHdma] ( #$8400, #08 )
    COP [SetEntryExit]
    COP [BranchIfFlagByte] ( #FF, #00, &thinker_def_00BF91 )
    COP [TickSineHdma] ( #05, #02 )
    COP [BindSineHdma] ( $7E8400, #0F )
    RTL 
} >
]

thinker_def_00BFB2 [
  thinker-def < #04, #08, {

  code_00BFB4:
    LDA #$0002
    STA $7F0008, X
    COP [InitSineHdma] ( #$8000, #08 )
    COP [SetEntryExit]
    COP [BranchIfFlagByte] ( #FF, #00, &thinker_def_00BFB2 )
    COP [BranchIfFlagByte] ( #01, #01, &code_00BFD9 )
    COP [TickSineHdma] ( #05, #02 )
    COP [BindSineHdma] ( $7E8400, #0D )
    RTL 
} >
]

code_00BFD9 {
    LDA #$0070
    STA $7F0008, X
    COP [InitSineHdma] ( #$8000, #04 )
    COP [SetEntryExit]
    COP [BranchIfFlagByte] ( #FF, #00, &code_00BFD9 )
    LDA $7F0008, X
    DEC 
    STA $7F0008, X
    BEQ loc_00C003
    COP [TickSineHdma] ( #05, #02 )
    COP [BindSineHdma] ( $7E8400, #0D )
    RTL 

  loc_00C003:
    COP [SetEntryContinue]
    RTL 
}

thinker_def_00C006 [
  thinker-def < #04, #08, {

  code_00C008:
    LDA #$0004
    STA $7F0008, X
    COP [SetFlagByte] ( #FF )
    COP [InitSineHdma] ( #$8800, #10 )
    LDA $cameraDeltaX
    PHA 
    LDA $0722
    LSR 
    LSR 
    LSR 
    LSR 
    STA $cameraDeltaX
    COP [TickSineHdma] ( #04, #02 )
    PLA 
    STA $cameraDeltaX
    COP [BindSineHdma] ( $7E8800, #0D )
    COP [BranchIfFlagByte] ( #FF, #00, &code_00C008 )
    RTL 
} >
]

code_00C03A {
    TSB $08
    RTL 
}

thinker_def_00C03D [
  thinker-def < #04, #08, {

  code_00C03F:
    COP [BranchIfFlagByte] ( #7B, #01, &code_00C055 )
    SEP #$20
    LDA #$2A
    STA $COLDATA
    LDA #$44
    STA $COLDATA
    REP #$20
    BRA loc_00C063
} >
]

code_00C055 {
    SEP #$20
    LDA #$28
    STA $COLDATA
    LDA #$41
    STA $COLDATA
    REP #$20

  loc_00C063:
    LDA #$0001
    STA $7F0008, X
    COP [InitSineHdma] ( #$8800, #08 )
    COP [SetEntryExit]
    COP [BranchIfFlagByte] ( #FF, #00, &code_00C03F )
    COP [TickSineHdma] ( #03, #02 )
    COP [BindSineHdma] ( $7E8800, #0D )
    COP [BindSineHdma] ( $7E8C00, #0E )
    RTL 
}

thinker_def_00C088 [
  thinker-def < #04, #08, {

  code_00C08A:
    LDA #$0008
    STA $7F0008, X
    COP [InitSineHdma] ( #$8800, #40 )
    COP [SetEntryExit]
    COP [BranchIfFlagByte] ( #FF, #00, &code_00C08A )
    COP [TickSineHdma] ( #01, #02 )
    COP [BindSineHdma] ( $7E8800, #0D )
    RTL 
} >
]

thinker_def_00C0A9 [
  thinker-def < #04, #08, {

  code_00C0AB:
    PHX 
    LDX #$0000
    LDY #$0010

  loc_00C0B2:
    LDA #$0090
    STA $tileStagingBuffer, X
    LDA #$7100
    STA $7E7001, X
    INX 
    INX 
    INX 
    DEY 
    BPL loc_00C0B2
    LDX #$0000
    LDY #$0010

  loc_00C0CC:
    LDA #$0000
    STA $7E7100, X
    INX 
    INX 
    DEY 
    BPL loc_00C0CC
    PLX 
    COP [QueueHdma] ( $7E7000, #21 )
    COP [SetEntryExit]
    COP [SetFlagByte] ( #FF )
    COP [SetEntryContinue]
    COP [QueueHdma] ( $7E7000, #21 )
    COP [BranchIfFlagByte] ( #FF, #00, &code_00C0AB )
    RTL 
} >
]

thinker_def_00C0F3 [
  thinker-def < #04, #08, {

  code_00C0F5:
    LDA #$0002
    STA $7F0008, X
    COP [InitSineHdma] ( #$8800, #08 )
    COP [SetEntryExit]
    COP [BranchIfFlagByte] ( #FF, #00, &code_00C0F5 )
    COP [TickSineHdma] ( #02, #02 )
    COP [BindSineHdma] ( $7E8800, #0F )
    COP [BindSineHdma] ( $7E8C00, #10 )
    RTL 
} >
]

code_00C11A {
    TSB $08

  code_00C11C:
    LDA #$0004
    STA $7F0008, X
    COP [InitSineHdma] ( #$8800, #20 )
    COP [SetEntryExit]
    COP [BranchIfFlagByte] ( #FF, #00, &code_00C11C )
    COP [TickSineHdma] ( #04, #02 )
    COP [BindSineHdma] ( $7E8C00, #0E )
    COP [BindSineHdma] ( $7E8C00, #10 )
    RTL 
}

thinker_def_00C141 [
  thinker-def < #04, #08, {

  code_00C143:
    LDA #$0010
    STA $7F0008, X
    COP [InitSineHdma] ( #$8800, #40 )
    COP [SetEntryExit]
    COP [BranchIfFlagByte] ( #FF, #00, &code_00C143 )
    COP [TickSineHdma] ( #00, #02 )
    COP [BindSineHdma] ( $7E8800, #0D )
    RTL 
} >
]

thinker_def_00C162 [
  thinker-def < #04, #08, {

  code_00C164:
    LDA #$0004
    STA $7F0008, X
    COP [InitSineHdma] ( #$8800, #20 )
    COP [SetEntryExit]
    COP [BranchIfFlagByte] ( #FF, #00, &code_00C164 )
    COP [TickSineHdma] ( #04, #02 )
    COP [BindSineHdma] ( $7E8C00, #0E )
    COP [BindSineHdma] ( $7E8C00, #10 )
    RTL 
} >
]

thinker_def_00C189 [
  thinker-def < #04, #08, {

  code_00C18B:
    LDA #$0008
    STA $7F0008, X
    COP [InitSineHdma] ( #$8800, #40 )
    COP [SetEntryExit]
    COP [BranchIfFlagByte] ( #FF, #00, &code_00C18B )
    COP [TickSineHdma] ( #01, #02 )
    COP [BindSineHdma] ( $7E8800, #0F )
    RTL 
} >
]

code_00C1AA {
    LDA $animScratch2, X
    ORA #$0001
    STA $animScratch2, X
    COP [SetEntryContinue]
    COP [GenHdmaSine]
    COP [QueueHdma] ( $7E8800, #0F )
    REP #$20
    RTL 
}

code_00C1C2 {
    TSB $08
    LDA #$0006
    STA $0E
    LDA #$0005
    STA $7F0008, X
    LDA $animScratch2, X
    ORA #$0001
    STA $animScratch2, X
    COP [SetEntryContinue]
    COP [GenHdmaSine]
    COP [QueueHdma] ( $7E8800, #10 )
    REP #$20
    RTL 
}

thinker_def_00C1E8 [
  thinker-def < #00, #08, {

  code_00C1EA:
    COP [SwitchCase] ( #$0AD4, &code_list_00C1F0 )
} >
]

code_list_00C1F0 [
  &code_00C1F8   ;00
  &code_00C1FF   ;01
  &code_00C206   ;02
  &code_00C20D   ;03
]

code_00C1F8 {
    COP [PaletteStart] ( #0B )
    COP [PaletteStep]
    BRA loc_00C214
}

code_00C1FF {
    COP [PaletteStart] ( #0C )
    COP [PaletteStep]
    BRA loc_00C214
}

code_00C206 {
    COP [PaletteStart] ( #23 )
    COP [PaletteStep]
    BRA loc_00C214
}

code_00C20D {
    COP [PaletteStart] ( #0C )
    COP [PaletteStep]
    BRA loc_00C214

  loc_00C214:
    LDA $animScratch2, X
    AND #$F7FF
    STA $animScratch2, X
    COP [SetEntryExit]
    PHD 
    LDA #$0000
    TCD 
    LDA $joypadCurrent
    BIT #$8000
    BEQ loc_00C231
    JMP $&code_00C233

  loc_00C231:
    PLD 
    RTL 
}

code_00C233 {
    JSL $@chunk_3B7DD.code_03E58B
    BCC loc_00C23B
    PLD 
    RTL 

  loc_00C23B:
    STA $09FC
    LDY $decelStepCounter
    PHP 
    REP #$20
    AND #$00FF
    BEQ loc_00C251
    DEC 
    BEQ loc_00C26B
    DEC 
    BEQ loc_00C285
    BRA loc_00C29F

  loc_00C251:
    LDA $0014, Y
    STA $18
    LDA $0016, Y
    INC 
    STA $1C
    JSR $&code_00C38C
    BEQ loc_00C2B9
    LDA $0016, X
    SEC 
    SBC $1C
    BMI loc_00C2BC
    BRA loc_00C2C9

  loc_00C26B:
    LDA $0014, Y
    STA $18
    LDA $0016, Y
    DEC 
    STA $1C
    JSR $&code_00C38C
    BEQ loc_00C2B9
    LDA $1C
    SEC 
    SBC $0016, X
    BMI loc_00C2BC
    BRA loc_00C2C9

  loc_00C285:
    LDA $0014, Y
    DEC 
    STA $18
    LDA $0016, Y
    STA $1C
    JSR $&code_00C38C
    BEQ loc_00C2B9
    LDA $18
    SEC 
    SBC $0014, X
    BMI loc_00C2BC
    BRA loc_00C2C9

  loc_00C29F:
    LDA $0014, Y
    INC 
    STA $18
    LDA $0016, Y
    STA $1C
    JSR $&code_00C38C
    BEQ loc_00C2B9
    LDA $0014, X
    SEC 
    SBC $18
    BMI loc_00C2BC
    BRA loc_00C2C9

  loc_00C2B9:
    PLP 
    PLD 
    RTL 

  loc_00C2BC:
    LDA $chatPtr, X
    BNE loc_00C2C5
    JMP $&code_00C337

  loc_00C2C5:
    TXA 
    TCD 
    BRA loc_00C2DE

  loc_00C2C9:
    LDA #$8000
    TSB $joypadHeld
    LDA $chatPtr, X
    BEQ loc_00C343
    TXA 
    TCD 
    LDA $12
    BIT #$0200
    BEQ loc_00C2F0

  loc_00C2DE:
    SEP #$20
    PHK 
    PEA $&code_00C337-1
    LDA $02
    PHA 
    REP #$20
    LDA $chatPtr, X
    DEC 
    PHA 
    RTL 

  loc_00C2F0:
    SEP #$20
    LDA #$7E
    STA $0404
    LDY #$3410
    LDA #$00
    STA $0405
    REP #$20
    LDA #$002F
    JSR $0402
    TDC 
    TAX 
    SEP #$20
    LDA #$7F
    STA $0405
    REP #$20
    LDA #$002F
    JSR $0402
    TDC 
    TAX 
    JSR $&code_00C3DB
    STA $28
    STZ $2A
    JSL $@chunk_3B7DD.code_03C761
    SEP #$20
    PHK 
    PEA $&code_00C346-1
    LDA $02
    PHA 
    REP #$20
    LDA $chatPtr, X
    DEC 
    PHA 
    RTL 
}

code_00C337 {
    LDA #$8000
    TRB $joypadCurrent
    LDA #$8000
    TSB $joypadHeld

  loc_00C343:
    PLP 
    PLD 
    RTL 
}

code_00C346 {
    TXY 
    LDA $06
    PHA 
    SEP #$20
    LDA #$7E
    STA $0405
    LDX #$3410
    LDA #$00
    STA $0404
    REP #$20
    LDA #$002F
    JSR $0402
    TDC 
    TAY 
    SEP #$20
    LDA #$7F
    STA $0404
    REP #$20
    LDA #$002F
    JSR $0402
    TDC 
    TAX 
    LDA $06
    BNE loc_00C37C
    LDA $01, S
    STA $06

  loc_00C37C:
    PLA 
    LDA #$8000
    TRB $joypadCurrent
    LDA #$8000
    TSB $joypadHeld
    PLP 
    PLD 
    RTL 
}

code_00C38C {
    LDA #$0020
    STA $02
    STZ $00
    STZ $04
    LDA $0056
    BRA loc_00C39D

  loc_00C39A:
    LDA $0006, X

  loc_00C39D:
    TAX 
    BEQ loc_00C3D8
    LDA $0010, X
    BIT #$1000
    BEQ loc_00C39A
    LDA $0014, X
    SEC 
    SBC $18
    BPL loc_00C3B4
    EOR #$FFFF
    INC 

  loc_00C3B4:
    CMP #$0010
    BCS loc_00C39A
    STA $00
    LDA $0016, X
    SEC 
    SBC $1C
    BPL loc_00C3C7
    EOR #$FFFF
    INC 

  loc_00C3C7:
    CMP #$0010
    BCS loc_00C39A
    ADC $00
    CMP $02
    BCS loc_00C39A
    STA $02
    STX $04
    BRA loc_00C39A

  loc_00C3D8:
    LDX $04
    RTS 
}

code_00C3DB {
    LDA $09FC
    AND #$00FF
    BIT #$0002
    BNE loc_00C3EC
    INC 
    AND #$0001
    BRA loc_00C3F2

  loc_00C3EC:
    INC 
    AND #$0001
    INC 
    INC 

  loc_00C3F2:
    STA $09FC
    LDA $28
    DEC 
    DEC 
    AND #$FFF8
    INC 
    INC 
    CLC 
    ADC $09FC
    RTS 
}

actor_def_00C403 [
  actor-def < #00, #00, #20, {

  code_00C406:
    PHX 
    SEP #$20
    LDX #$0000
    LDA $sceneCurrent

  loc_00C40F:
    CMP $@code_00C45A, X
    BEQ loc_00C41B
    INX 
    INX 
    INX 
    INX 
    BRA loc_00C40F

  loc_00C41B:
    REP #$20
    TXA 
    STX $20
    PLX 
    LSR 
    LSR 
    JSL $@code_00B10F
    BCS loc_00C454
    COP [SetEntryContinue]
    LDA $slopeCurvePtrB
    BIT #$0020
    BNE loc_00C434
    RTL 

  loc_00C434:
    PHX 
    LDX $20
    LDA $@code_00C45A+1, X
    STA $0004
    JSR $&code_00C486
    PLX 
    LDA $playerMaxHp
    SEC 
    SBC $playerHp
    STA $damageFlashTimer
    LDA $20
    LSR 
    LSR 
    JSL $@code_00B11A

  loc_00C454:
    COP [SetEntryContinue]
    NOP 
    NOP 
    NOP 
    RTL 
} >
]

code_00C45A {
    AND #$290C
    BRK #$55
    AND $0055, X
    ADC [$5A]
    ADC [$00]
    TXA 
    ADC $008A
    CMP $&01DDA0, X
    BRK #$F8
    BRK #$00
    BRK #$29
    BRK #$00
    BRK #$29
    BRK #$00
    BRK #$29
    BRK #$00
    BRK #$29
    BRK #$00
    BRK #$29
    BRK #$00
    BRK #$EB
    AND #$00FF
    STA $000E
    LDA $0004
    AND #$00FF
    TAY 
    SEP #$20
    BRA loc_00C49B

  code_00C498:
    SEP #$20
    INY 

  loc_00C49B:
    LDA $&reward_table, Y
    BNE loc_00C4A8
    INY 
    CPY $000E
    BCC loc_00C49B
    BRA loc_00C4DC

  loc_00C4A8:
    REP #$20
    AND #$00FF
    STA $0004
    TYA 
    PHY 
    JSL $@code_00B544
    PLY 
    BCS code_00C498
    PHY 
    TYA 
    JSL $@code_00B54F
    PLY 
    LDA $0004
    PEA $&code_00C498-1
    DEC 
    BNE loc_00C4CD
    INC $playerMaxHp
    RTS 

  loc_00C4CD:
    DEC 
    BNE loc_00C4D4
    INC $playerStr
    RTS 

  loc_00C4D4:
    DEC 
    BEQ loc_00C4D8
    RTS 

  loc_00C4D8:
    INC $playerDef
    RTS 

  loc_00C4DC:
    REP #$20
    RTS 
}

code_00C4DF {
    PHX 
    PHD 
    STZ $0002
    STY $0000
    ASL 
    BCC loc_00C4F2
    PHA 
    LDA #$FFC4
    STA $0002
    PLA 

  loc_00C4F2:
    LSR 
    EOR #$FFFF
    INC 
    CLC 
    ADC $playerHp
    BPL loc_00C500
    LDA #$0000

  loc_00C500:
    STA $playerHp
    LDA $decelStepCounter
    TCD 
    TAX 
    LDA #$0080
    TSB $10
    LDA $0002
    BNE loc_00C515
    LDA #$003C

  loc_00C515:
    STA $iframeCounter, X
    LDA $slopeCurvePtrB
    BIT #$0800
    BNE loc_00C558
    COP [SpawnLastRel] ( @code_00D996, #00, #00, #$2400 )
    CPY #$1FC0
    BNE loc_00C535
    LDA #$0F00
    TRB $joypadMaskStd

  loc_00C535:
    LDA $extendedFlags, X
    AND #$0020
    PHX 
    TYX 
    STA $extendedFlags, X
    PLX 
    LDA $0000
    STA $0028, Y
    LDA #$0000
    STA $002C, Y
    STA $002E, Y

  loc_00C552:
    COP [PlaySoundCh2] ( #07 )
    PLD 
    PLX 
    RTL 

  loc_00C558:
    LDA #$0F00
    TRB $joypadMaskStd
    BRA loc_00C552

  code_00C560:
    COP [SpawnLastRel] ( @code_00C56B, #00, #00, #$0302 )
    COP [Die]
}

code_00C56B {
    COP [PlaySoundCh2] ( #09 )
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #2A )
    COP [AnimOnce]
    COP [Die]

  loc_00C57A:
    COP [BranchIfFlagByte] ( #00, #01, &code_00C585 )
    COP [StagePlayerSprite] ( #01 )
    BRA loc_00C588
}

code_00C585 {
    COP [StagePlayerSprite] ( #11 )

  loc_00C588:
    COP [SetEntryContinue]
    COP [AnimOnce]
    BRA loc_00C588

  loc_00C58E:
    LDA #$0200
    TSB $10
    COP [SetPlayerBodySprite] ( #04 )

  loc_00C596:
    COP [StageSpriteFrame] ( #1F )
    COP [AnimOnce]
    BRA loc_00C596

  loc_00C59D:
    LDA #$0200
    TRB $10
    JML $@chunk_028000.code_02D01B
}

code_00C5A6 {
    COP [SetPlayerBodySprite] ( #04 )
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #20 )
    COP [AnimOnce]
    RTL 
}

code_00C5B1 {
    JML $@chunk_028000.code_02D01B
}

code_00C5B5 {
    COP [SetPlayerBodySprite] ( #04 )
    COP [StageSpriteFrame] ( #20 )
    COP [AnimOnce]
    JML $@chunk_028000.code_02D01B
}

code_00C5C1 {
    LDA #$CFF0
    TSB $joypadMaskStd
    LDA #$0008
    TRB $10
    LDA #$2200
    TSB $10
    LDA #$0200
    TSB $layerPriorityFlag
    COP [WaitByte] ( #03 )
    COP [AddPosition] ( #00, #80 )
    LDA #$2000
    TRB $10
    COP [LoopInit] ( #08 )
    COP [StagePlayerMoveY] ( #19, #07 )
    COP [AnimOnce]
    COP [LoopNext]
    COP [PlaySoundCh2] ( #2C )
    COP [StagePlayerMoveY] ( #1C, #00 )
    COP [AnimOnce]
    LDA #$0008
    TSB $10
    LDA #$0200
    TRB $10
    LDA #$0200
    TRB $layerPriorityFlag
    LDA #$CFF0
    TRB $joypadMaskStd
    STZ $08
    JML $@chunk_028000.code_02D01B
}

code_00C613 {
    LDA #$0008
    TRB $10
    LDA #$2200
    TSB $10
    COP [AddPosition] ( #00, #C0 )
    COP [SetEntryExit]
    LDA #$0200
    TSB $layerPriorityFlag
    COP [WaitByte] ( #03 )
    COP [AddPosition] ( #00, #40 )
    LDA #$2000
    TRB $10
    COP [ToggleVFlip]
    COP [AddPosition] ( #00, #E0 )
    COP [StagePlayerMoveY] ( #1A, #08 )
    COP [AnimOnce]
    COP [LoopInit] ( #03 )
    COP [StagePlayerMoveY] ( #1B, #08 )
    COP [AnimOnce]
    COP [LoopNext]
    COP [StagePlayerMoveY] ( #1B, #04 )
    COP [AnimOnce]
    COP [StagePlayerMoveY] ( #1B, #04 )
    COP [AnimOnce]
    COP [StagePlayerMoveY] ( #1B, #02 )
    COP [AnimOnce]
    COP [StagePlayerMoveY] ( #1B, #02 )
    COP [AnimOnce]
    COP [ToggleVFlip]
    COP [AddPosition] ( #00, #20 )
    COP [StagePlayerSprite] ( #1E )
    COP [AnimOnce]
    COP [StagePlayerMoveY] ( #1E, #01 )
    COP [AnimOnce]
    COP [StagePlayerMoveY] ( #1E, #03 )
    COP [AnimOnce]
    COP [PlaySoundCh2] ( #2C )
    COP [StagePlayerSprite] ( #1F )
    COP [AnimOnce]
    LDA #$0008
    TSB $10
    LDA #$0200
    TRB $10
    LDA #$0200
    TRB $layerPriorityFlag
    STZ $08
    JML $@chunk_028000.code_02D01B
}

code_00C699 {
    LDA #$0800
    TSB $slopeCurvePtrB
    LDA #$0008
    TRB $10
    LDA #$0200
    TSB $10
    COP [SetPlayerBodySprite] ( #08 )
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    LDA $14
    STA $24
    LDA $16
    STA $26
    LDA $16
    AND #$FFF0
    STA $16

  loc_00C6C0:
    COP [BranchIfSolid] ( &code_00C6CE )
    LDA $16
    CLC 
    ADC #$0010
    STA $16
    BRA loc_00C6C0
}

code_00C6CE {
    COP [BranchIfSolidTypeSouth] ( #04, &code_00C6E3 )
    LDA $24
    STA $14
    LDA $26
    STA $16
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    JMP $&code_00C725
}

code_00C6E3 {
    LDA $24
    STA $14
    LDA $26
    STA $16
    LDA #$2000
    TSB $10

  code_00C6F0:
    LDA $16
    AND #$000F
    BNE loc_00C6FC
    COP [BranchIfSolidType] ( #04, &code_00C703 )

  loc_00C6FC:
    INC $16
    COP [SetEntryExitNow] ( @code_00C6F0 )
}

code_00C703 {
    LDA #$2000
    TRB $10
    LDA #$0002
    TSB $10

  loc_00C70D:
    COP [StageSpriteMoveY] ( #02, #01 )
    COP [AnimOnce]
    COP [BranchIfSolidType] ( #00, &code_00C71A )
    BRA loc_00C70D
}

code_00C71A {
    LDA #$0002
    TRB $10
    COP [StagePlayerMoveY] ( #1C, #00 )
    COP [AnimOnce]
}

code_00C725 {
    LDA #$0008
    TSB $10
    LDA #$0200
    TRB $10
    STZ $08
    JML $@chunk_028000.code_02D01B
}

actor_def_00C735 [
  actor-def < #01, #00, #10, {

  code_00C738:
    COP [SetMetasprite] ( @sprite_set_list_0EDA00 )
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [BranchIfPlayerNear] ( #01, &code_00C765 )
    COP [WaitWhileOffscreen] ( #0A )

  code_00C74C:
    COP [BranchIfPlayerNear] ( #01, &code_00C752 )
    RTL 
} >
]

code_00C752 {
    COP [LoopInit] ( #08 )
    COP [BranchIfButton] ( #$0800, &code_00C760 )
    COP [SetEntryExitNow] ( @code_00C74C )
}

code_00C760 {
    COP [LoopNext]
    COP [PlaySoundCh2] ( #0E )
}

code_00C765 {
    COP [ClearLowHere]
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
}

actor_def_00C76F [
  actor-def < #07, #00, #10, {

  code_00C772:
    COP [SetMetasprite] ( @sprite_set_list_0EDA00 )
    COP [StageSpriteFrame] ( #07 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [BranchIfPlayerNear] ( #01, &code_00C79F )
    COP [WaitWhileOffscreen] ( #0A )

  code_00C786:
    COP [BranchIfPlayerNear] ( #01, &code_00C78C )
    RTL 
} >
]

code_00C78C {
    COP [LoopInit] ( #08 )
    COP [BranchIfButton] ( #$0800, &code_00C79A )
    COP [SetEntryExitNow] ( @code_00C786 )
}

code_00C79A {
    COP [LoopNext]
    COP [PlaySoundCh2] ( #01 )
}

code_00C79F {
    COP [ClearLowHere]
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
}

actor_def_00C7A9 [
  actor-def < #00, #00, #10, {

  code_00C7AC:
    COP [SetFlagByte] ( #00 )
    COP [Die]
} >
]

actor_def_00C7B1 [
  actor-def < #00, #00, #30, {

  code_00C7B4:
    COP [SetOnInteract] ( &code_00C7C3 )
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSprAndHitbox] ( #00 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_00C7C3 {
    LDA $0E
    CLC 
    ADC #$0080
    JSL $@code_00B537
    BCS loc_00C7E7
    COP [GiveItem] ( #01, &code_00C7E3 )
    COP [PrintDialogString] ( &dialogstring_00C7E8 )
    LDA $0E
    CLC 
    ADC #$0080
    JSL $@code_00B52F
    RTL 
}

code_00C7E3 {
    COP [PrintDialogString] ( &dialogstring_00C7FF )

  loc_00C7E7:
    RTL 
}

dialogstring_00C7E8 `[DLG:3,11][SIZ:D,3,0]赤い宝石を 見つけた![END]`

dialogstring_00C7FF `[DLG:3,11][SIZ:D,3,0]赤い宝石を 見つけたが[N]持ち物が いっぱいのようだ···[END]`

dialogstring_00C829 `[NAM:A][AA][BF]ひ[CLD]断[B8]ぞ[9D]がが[E2] [A9]卵ぐが[TPL:20][9E]ぜが[9E]Lが[9E]Nが[A9]がが[9F]Lが:[9F]Nが:[FA]ぅ[WAI][CLR][E2][CLR][F2][CLR]ぐ[FIN][A5]ば[9F]┌が:[A5]ぶ[9F](が:ぅぐCIずが[8D]ががぐ[DLY:0]が5[CLD][92][CLD][88][CLD][9C][CLD][A6][CLD][DD][CLD][END]`

dialogstring_00C883 `[CLD][FA][CLD]べ[PAU:BF]Fが:ぼぁがが声[BF]Fが:ぼぁぎが話[BF]Fが:ぼぁぐが必[BF]Fが:ぼぁげが私[85]HれJBら[SIZ:83,A9,78]が[85]ぜぐぢぅ[BF](が:ぼぁPが[ADR:&chunk_008000.code_00900A+C,2BC]ぶ[88][CLD]ぐ[AB]┘[BF]Fが:ぼぁごが陸[BF](が:X[E9]Pが[ADR:&chunk_008000.loc_00B013+3,2A9]び[92][CLD]ぐ[AB]([BF]Fが:ぼぁざが上[BF]┌が:X[E9]Pが[ADR:&chunk_008000.loc_00B013+1,296]べ[9C][CLD]ぐ[AA]([BF]Fが:ぼぁじが中[BF]┌が:ぼぁPが[ADR:&chunk_008000.code_00900A+A,283]ぼ[A6][CLD]ぐ[AA]┘[BF]Fが:ぼぁずが私[85]HれJBら[SIZ:83,2,C]ぅ[A4]D[B9]┌がそが [99]┌がぅ[NAM:BF]┌が:[F0]げZ空B[8B][E5][83]だだだ[AA][A4]ご[B9]ばが[8D]がが[B9]ぶが[8D]ぐが[BF][8C][RET]`

dialogstring_00C96E `対ぺが[A0]がが[BF][88][RET]`

dialogstring_00C978 `戦ぉがが[8D]がが[8D]ぼが[BF][8A][RET]`

dialogstring_00C986 `戦ぉぐが[8D]ぐが[8D]ぴが[8A][BB][A8][AD]ぼが[9F]が[DF]·[AD]ぴが[9F]ぐ[DF]·[AD]ぺが[9F]ご[DF]·[8A][BB][A8][98]ぼぁぜが[A8][END]`

dialogstring_00C9B3 `せが[CLR][BE][FA][AC][B8]ぞ[B9]ばが[85]ば[B9]ぶが[85]ぶ[AD]ぺが[85]ど[A9]がが[9F]┌が:ぐ[TPL:AC][B8]ぞ[B9]ばが[ADR:&chunk_008000.code_00D009+B,B907]ぶが[ADR:&chunk_008000.loc_00F010+6,DA58][A4]ご[BF]┌が:Iおが[AA][BF]が[DF]·[99]ばが[BF]ぐ[DF]·[99]ぶが[AC][B8]ぞ[B9]ばが[85]ば[9F]が[DF]·[B9]ぶが[85]ぶ[9F]ぐ[DF]·[BF]ご[DF]·[FA][ADR:&chunk_008000.loc_00EFFF+F,854E]どぼぁごがせ[BF](が:ぼるぎ[83]ぎん[A4]ご[99]Hが[A9]がが[99]Jが[99]ぜが心[BF]┌が:Iおが[NAM:AA][BF]ご[DF]·[FA]せ[BF](が:ぼるぎ[83]ぎん[A4]ご[99]Hが[A9]がが[99]Jが[99]ぜが[A9][FF][FF][85]どぅ[BF]┌が:Iおが[NAM:AA]B[8B][E5][83][9F]ご[DF]·[FA][BF]┌が:ぼぁぜが[9F]┌が:ぅがが[FE][FF]ぎがががががぐがががががぐがががげががが[FE][FF]ががぐががが`

actor_def_00CAA8 [
  actor-def < #00, #00, #20, {

  loc_00CAAB:
    LDA $09C0
    ORA $decelCurvePtr
    BNE loc_00CAB4
    RTL 

  loc_00CAB4:
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #02, &code_00CABC )
    RTL 
} >
]

code_00CABC {
    LDA $09C0
    BMI loc_00CAC6
    INC $09C0
    BRA loc_00CAC9

  loc_00CAC6:
    DEC $09C0

  loc_00CAC9:
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #03, &code_00CAD2 )
    BRA loc_00CAAB
}

code_00CAD2 {
    RTL 
}

code_00CAD3 {
    COP [PrintDialogString] ( &dialogstring_00CAD8 )
    RTL 
}

dialogstring_00CAD8 `[DEF][CLR][TPL:0]だが もちものが いっぱいで[N]これ以上 持つことができない![PAL:0][END]`

dialogstring_00CB00 `ぐ[RET]`

dialogstring_00CB02 `ぜぐ[NAM:3]ぐ[9C]┘[ZZZ]手げぐ[ZZZ]ぐ[E0]ぐ[88]が[E0][8E]ぐ[B7]がぐ[B6]PぐCI.がX[E9]┌がぼろば[85]ばぐCI.がX[E9]┌がぼろぶ[85]ぶぐぜ??ぐ旅ぐ[89]ぐ[E0]`

actor_def_00CB43 [
  actor-def < #00, #00, #01, {

  code_00CB46:
    LDA $0E
    STA $24
    LDA #$2000
    STA $0E
    LDA #$ACF0
    STA $statsPtr, X
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [SolidHighHere]
    LDA #$0031
    TSB $12

  loc_00CB67:
    LDA #$00FF
    STA $currentHp, X
    COP [SetHitCallback] ( &code_00CB75 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_00CB75 {
    LDA $24
    JSL $@code_00B56C
    COP [StageSpriteFrame] ( #10 )
    COP [AnimOnce]
    COP [WaitByte] ( #0F )
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    BRA loc_00CB67
}

actor_def_00CB8A [
  actor-def < #00, #00, #30, {

  code_00CB8D:
    LDA $sceneCurrent
    CMP #$0001
    BNE loc_00CB98
    JMP $&code_00CC24

  loc_00CB98:
    CMP #$000A
    BNE loc_00CBA0
    JMP $&code_00CC6B

  loc_00CBA0:
    CMP #$0015
    BNE loc_00CBA8
    JMP $&code_00CC84

  loc_00CBA8:
    CMP #$001C
    BNE loc_00CBB0
    JMP $&code_00CCB9

  loc_00CBB0:
    CMP #$0032
    BNE loc_00CBB8
    JMP $&code_00CCD2

  loc_00CBB8:
    CMP #$003E
    BNE loc_00CBC0
    JMP $&code_00CD01

  loc_00CBC0:
    CMP #$0069
    BNE loc_00CBC8
    JMP $&code_00CD1A

  loc_00CBC8:
    CMP #$0078
    BNE loc_00CBD0
    JMP $&code_00CD49

  loc_00CBD0:
    CMP #$0082
    BNE loc_00CBD8
    JMP $&code_00CD8E

  loc_00CBD8:
    CMP #$0091
    BNE loc_00CBE0
    JMP $&code_00CDA7

  loc_00CBE0:
    CMP #$00A0
    BNE loc_00CBE8
    JMP $&code_00CDEC

  loc_00CBE8:
    CMP #$00AC
    BNE loc_00CBF0
    JMP $&code_00CE05

  loc_00CBF0:
    CMP #$00B0
    BNE loc_00CBF8
    JMP $&code_00CE4A

  loc_00CBF8:
    CMP #$00C3
    BNE loc_00CC00
    JMP $&code_00CE63

  loc_00CC00:
    CMP #$00CC
    BNE loc_00CC08
    JMP $&code_00CE92

  loc_00CC08:
    RTL 
} >
]

code_00CC09 {
    LDA #$0400
    STA $gfxCacheIdxB
    COP [SetEntryContinue]
    RTL 
}

code_00CC12 {
    BNE loc_00CB94
    TSC 
    BRA loc_00CC53

  loc_00CC17:
    LSR $59
    EOR [$1F]
    CPY #$5ED0
    JML $@code_0A4659
}

code_00CC22 {
    ORA $@hiragana_font+2C0, X
    LDA $playerSpeedEw
    CMP #$0010
    BCC loc_00CC2F
    RTL 

  loc_00CC2F:
    COP [BranchIfFlagByte] ( #26, #01, &code_00CC4B )
    COP [BranchIfFlagByte] ( #25, #01, &code_00CC5B )
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$00D4, #$03A4, #01 )
    JMP $&code_00CC09
}

code_00CC4B {
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$00D4, #$03A4, #02 )
    JMP $&code_00CC09
}

code_00CC5B {
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$00D4, #$03A4, #1B )
    JMP $&code_00CC09
}

code_00CC6B {
    LDA $playerSpeedEw
    CMP #$02D0
    BEQ loc_00CC74
    RTL 

  loc_00CC74:
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$0104, #$0334, #03 )
    JMP $&code_00CC09
}

code_00CC84 {
    COP [BranchIfFlagByte] ( #01, #01, &code_00CC92 )
    COP [BranchIfPlayerInAbsTiles] ( #2D, #2E, #2F, #30, &code_00CC93 )
}

code_00CC92 {
    RTL 
}

code_00CC93 {
    COP [BranchIfFlagByte] ( #4A, #01, &code_00CCA9 )
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$00C4, #$02B4, #04 )
    JMP $&code_00CC09
}

code_00CCA9 {
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$00C4, #$02B4, #06 )
    JMP $&code_00CC09
}

code_00CCB9 {
    COP [BranchIfPlayerInAbsTiles] ( #06, #1C, #08, #1E, &code_00CCC2 )
    RTL 
}

code_00CCC2 {
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$0134, #$0284, #05 )
    JMP $&code_00CC09
}

code_00CCD2 {
    COP [BranchIfPlayerInAbsTiles] ( #12, #3C, #16, #3E, &code_00CCDB )
    RTL 
}

code_00CCDB {
    COP [BranchIfFlagByte] ( #65, #01, &code_00CCF1 )
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$0254, #$02D4, #09 )
    JMP $&code_00CC09
}

code_00CCF1 {
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$0254, #$02D4, #07 )
    JMP $&code_00CC09
}

code_00CD01 {
    COP [BranchIfPlayerInAbsTiles] ( #0A, #3F, #0C, #40, &code_00CD0A )
    RTL 
}

code_00CD0A {
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$0334, #$0334, #08 )
    JMP $&code_00CC09
}

code_00CD1A {
    COP [BranchIfPlayerInAbsTiles] ( #29, #0D, #2C, #0F, &code_00CD23 )
    RTL 
}

code_00CD23 {
    COP [BranchIfFlagByte] ( #8D, #01, &code_00CD39 )
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$0384, #$0164, #15 )
    JMP $&code_00CC09
}

code_00CD39 {
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$0384, #$0164, #0A )
    JMP $&code_00CC09
}

code_00CD49 {
    COP [BranchIfPlayerInAbsTiles] ( #27, #3D, #29, #40, &code_00CD52 )
    RTL 
}

code_00CD52 {
    COP [BranchIfFlagByte] ( #94, #01, &code_00CD7E )
    COP [BranchIfFlagByte] ( #8E, #01, &code_00CD6E )
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$02D4, #$01A4, #0B )
    JMP $&code_00CC09
}

code_00CD6E {
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$02D4, #$01A4, #0C )
    JMP $&code_00CC09
}

code_00CD7E {
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$02D4, #$01A4, #0E )
    JMP $&code_00CC09
}

code_00CD8E {
    COP [BranchIfPlayerInAbsTiles] ( #00, #08, #01, #0B, &code_00CD97 )
    RTL 
}

code_00CD97 {
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$02A4, #$0124, #0D )
    JMP $&code_00CC09
}

code_00CDA7 {
    COP [BranchIfPlayerInAbsTiles] ( #3F, #42, #40, #48, &code_00CDB0 )
    RTL 
}

code_00CDB0 {
    COP [BranchIfFlagByte] ( #AC, #01, &code_00CDDC )
    COP [BranchIfFlagByte] ( #9F, #01, &code_00CDCC )
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$01D4, #$0134, #0F )
    JMP $&code_00CC09
}

code_00CDCC {
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$01D4, #$0134, #10 )
    JMP $&code_00CC09
}

code_00CDDC {
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$01D4, #$0134, #1A )
    JMP $&code_00CC09
}

code_00CDEC {
    COP [BranchIfPlayerInAbsTiles] ( #2F, #1B, #30, #1C, &code_00CDF5 )
    RTL 
}

code_00CDF5 {
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$0214, #$00B4, #11 )
    JMP $&code_00CC09
}

code_00CE05 {
    COP [BranchIfPlayerInAbsTiles] ( #1F, #1B, #20, #20, &code_00CE0E )
    RTL 
}

code_00CE0E {
    COP [BranchIfFlagByte] ( #B6, #01, &code_00CE3A )
    COP [BranchIfFlagByte] ( #B1, #01, &code_00CE2A )
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$0124, #$01A4, #12 )
    JMP $&code_00CC09
}

code_00CE2A {
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$0124, #$01A4, #13 )
    JMP $&code_00CC09
}

code_00CE3A {
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$0124, #$01A4, #19 )
    JMP $&code_00CC09
}

code_00CE4A {
    COP [BranchIfPlayerInAbsTiles] ( #1D, #4F, #24, #50, &code_00CE53 )
    RTL 
}

code_00CE53 {
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$0134, #$0154, #14 )
    JMP $&code_00CC09
}

code_00CE63 {
    COP [BranchIfPlayerInAbsTiles] ( #00, #0D, #01, #11, &code_00CE6C )
    RTL 
}

code_00CE6C {
    COP [BranchIfFlagByte] ( #B4, #01, &code_00CE82 )
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$0094, #$0114, #16 )
    JMP $&code_00CC09
}

code_00CE82 {
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$0094, #$0114, #17 )
    JMP $&code_00CC09
}

code_00CE92 {
    COP [BranchIfPlayerInAbsTiles] ( #00, #0D, #01, #0F, &code_00CEA3 )
    COP [BranchIfPlayerInAbsTiles] ( #3F, #0D, #40, #0F, &code_00CEA3 )
    RTL 
}

code_00CEA3 {
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$0074, #$00B4, #18 )
    JMP $&code_00CC09
}

actor_def_00CEB3 [
  actor-def < #00, #00, #30, {

  code_00CEB6:
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [AddPosition] ( #08, #08 )
    COP [SetMetasprite] ( @sprite_set_list_108000 )
    SEP #$20
    LDA #$08
    STA $BG1SC
    LDA #$0C
    STA $BG2SC
    LDA #$13
    STA $TM
    LDA #$11
    STA $TS
    LDA #$82
    STA $CGWSEL
    LDA #$02
    STA $CGADSUB
    REP #$20
    STZ $0676
    LDA $0E
    STA $24
    BIT #$0010
    BEQ loc_00CEF7
    COP [AddPosition] ( #00, #F8 )

  loc_00CEF7:
    LDA #$2000
    STA $0E
    PHX 
    LDA $24
    AND #$000F
    ASL 
    ASL 
    TAX 
    LDA $@code_00CFF1, X
    AND #$00FF
    JSL $@code_00B565
    BCC loc_00CF15
    JMP $&code_00CFD5

  loc_00CF15:
    LDA $@code_00CFF1+2, X
    AND #$00FF
    CMP $0AAC
    BEQ loc_00CF24
    JMP $&code_00CFED

  loc_00CF24:
    LDA $@code_00CFF1, X
    AND #$00FF
    JSL $@code_00B56C
    LDA $@code_00CFF1+1, X
    AND #$00FF
    STA $28
    STZ $2A
    PLX 
    JSL $@chunk_3B7DD.code_03C761
    LDA #$0001
    STA $26

  loc_00CF44:
    COP [SpawnAfterFlags] ( @code_00D009, #$1802 )
    LDA $26
    CLC 
    ADC #$0020
    STA $26
    STA $0026, Y
    CMP #$0101
    BNE loc_00CF44
    TYA 
    STA $26
    LDA #$00B4
    STA $0AAC
    COP [SetEntryContinue]
    DEC $0AAC
    BEQ loc_00CFA0
    JSL $@chunk_028000.code_02A178
    BCC loc_00CF72
    RTL 

  loc_00CF72:
    LDA #$0000
    STA $0AAC
    COP [WaitByte] ( #0F )
    COP [PlaySoundBoth] ( #$2525 )
    COP [SetEntryExit]
    PHX 
    LDX $26
    LDA $orbitDiameter, X
    PLX 
    CMP #$0000
    BEQ loc_00CF8F
    RTL 

  loc_00CF8F:
    LDA #$2000
    TRB $10
    COP [LoopInit] ( #3C )
    COP [SpawnAfterFlags] ( @code_00D059, #$1802 )
    COP [LoopNext]

  loc_00CFA0:
    LDA $0B12
    STA $sceneNext
    LDA $0B08
    ASL 
    ASL 
    ASL 
    ASL 
    STA $064C
    LDA $0B0C
    ASL 
    ASL 
    ASL 
    ASL 
    STA $064E
    LDA #$0003
    STA $0650
    LDA $0B10
    STA $0652
    LDA #$0303
    STA $gfxCacheIdxB
    LDA #$0002
    STA $gfxCacheIdxA
    COP [SetEntryContinue]
    RTL 
} >
]

code_00CFD5 {
    LDA $@code_00CFF1+1, X
    AND #$00FF
    STA $28
    STZ $2A
    PLX 
    JSL $@chunk_3B7DD.code_03C761
    LDA #$2000
    TRB $10
    COP [SetEntryContinue]
    RTL 
}

code_00CFED {
    PLX 
    COP [SetEntryContinue]
    RTL 
}

code_00CFF1 {
    SED 
    DEC 
    BRK #$00
    SBC $013B, Y
    BRK #$FA
    BIT $0002, X
    XCE 
    AND $0003, X
    JSR ($043E, X)
    BRK #$FD
    AND $020005, X
    LDX $30, Y
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSprAndHitbox] ( #02 )
    LDA #$00FC
    STA $orbitDiameter, X
    LDA $26
    STA $orbitAngle, X

  loc_00D021:
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_00D021
    LDA $08
    INC 
    STA $26
    STZ $08
    COP [SetEntryContinue]
    DEC $26
    BMI loc_00D021
    LDY $24
    JSL $@code_00F4BD
    LDA $orbitAngle, X
    CLC 
    ADC #$0004
    STA $orbitAngle, X
    LDA $orbitDiameter, X
    BEQ loc_00D057
    SEC 
    SBC #$0002
    STA $orbitDiameter, X
    RTL 

  loc_00D057:
    COP [Die]
}

code_00D059 {
    LDA $0036
    AND #$0003
    BNE loc_00D081
    COP [RngByte]
    AND #$000F
    SEC 
    SBC #$0008
    CLC 
    ADC $14
    STA $14
    LDA $16
    SEC 
    SBC #$0008
    STA $16
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]

  loc_00D081:
    COP [Die]
}

actor_def_00D083 [
  actor-def < #00, #00, #38, {

  code_00D086:
    COP [AddPosition] ( #08, #08 )
    COP [SetMetasprite] ( @sprite_set_list_108000 )
    LDA $0E
    STA $24
    BIT #$0010
    BEQ loc_00D09C
    COP [AddPosition] ( #00, #F8 )

  loc_00D09C:
    LDA #$2000
    STA $0E
    PHX 
    LDA $24
    AND #$000F
    ASL 
    ASL 
    TAX 
    LDA $@code_00CFF1, X
    AND #$00FF
    JSL $@code_00B565
    BCC loc_00D0BA
    JMP $&code_00D0BD

  loc_00D0BA:
    PLX 
    COP [Die]
} >
]

code_00D0BD {
    LDA $@code_00CFF1+1, X
    AND #$00FF
    STA $28
    STZ $2A
    PLX 
    JSL $@chunk_3B7DD.code_03C761
    LDA #$2000
    TRB $10
    COP [SetEntryContinue]
    LDA $inventoryTabIndex
    CMP #$0003
    BEQ loc_00D0E2
    LDA #$2000
    TRB $10
    RTL 

  loc_00D0E2:
    LDA #$2000
    TSB $10
    RTL 
}

code_00D0E8 {
    COP [LoopInit] ( #78 )
    COP [RngByte]
    AND #$0003
    SEC 
    SBC #$0001
    PHA 
    CLC 
    ADC $cameraTargetY
    STA $cameraTargetY
    PLA 
    CLC 
    ADC $cameraDeltaY
    STA $cameraDeltaY
    COP [LoopNext]
    COP [Die]

  code_00D108:
    LDA #$1000
    TSB $12
    STZ $26
    COP [LoopInit] ( #78 )
    LDA $slopeCurvePtrB
    BIT #$0100
    BNE loc_00D13A
    LDA $cameraDeltaY
    SEC 
    SBC $26
    STA $cameraDeltaY
    COP [RngByte]
    AND #$0003
    STA $26
    PHA 
    CLC 
    ADC $cameraTargetY
    STA $cameraTargetY
    PLA 
    CLC 
    ADC $cameraDeltaY
    STA $cameraDeltaY

  loc_00D13A:
    COP [LoopNext]
    COP [SetEntryExit]
    LDA $cameraDeltaY
    SEC 
    SBC $26
    STA $cameraDeltaY
    COP [Die]

  code_00D149:
    COP [RngByte]
    STA $28
    LDA #$0002
    STA $2A
    COP [SetEntryContinue]
    PHB 
    PHK 
    PLB 
    LDA $28
    INC $28
    AND #$0007
    ASL 
    TAY 
    LDA $&loc_00D1AE, Y
    PHA 
    CLC 
    ADC $cameraTargetY
    STA $cameraTargetY
    LDA $24
    CMP #$FFFF
    BEQ loc_00D17C
    PLA 
    CLC 
    ADC $cameraDeltaY
    STA $cameraDeltaY
    BRA loc_00D17D

  loc_00D17C:
    PLA 

  loc_00D17D:
    LDA $28
    AND #$0007
    ASL 
    TAY 
    LDA $&loc_00D1AE, Y
    PHA 
    CLC 
    ADC $cameraTargetX
    STA $cameraTargetX
    LDA $24
    CMP #$FFFF
    BEQ loc_00D1A0
    PLA 
    CLC 
    ADC $cameraDeltaX
    STA $cameraDeltaX
    BRA loc_00D1A1

  loc_00D1A0:
    PLA 

  loc_00D1A1:
    PLB 
    LDA #$0003
    STA $08
    DEC $2A
    BMI loc_00D1AC
    RTL 

  loc_00D1AC:
    COP [Die]

  loc_00D1AE:
    ORA ($00, X)
    SBC $@3FFEFF, X
    ORA ($00, X)
    COP [GenHdmaSine]
    BRK #$00
    INC $01FF, X
    BRK #$05
    BRK #$FC
    SBC $@code_04FDDE+220, X
    BRK #$01
    BRK #$FB
    SBC $@3D0004, X
    SBC $0A0EA5, X
    ASL 
    PHX 
    LDX $decelStepCounter
    STA $statsPtr, X
    LDA #$0000
    STA $002C, X
    STA $002E, X
    STA $0008, X
    PLX 
    LDA #$0F00
    TSB $joypadMaskStd
    LDA #$0800
    TSB $slopeCurvePtrB
    RTS 
}

code_00D1F4 {
    STZ $09EE
    LDA #$CFF0
    TRB $joypadMaskStd
    LDA #$0008
    TSB $10
    LDA #$0200
    TRB $10
    LDA #$8000
    TSB $joypadHeld
    LDA #$0002
    TRB $slopeCurvePtrB
    JSR $&code_00D6D0
    RTS 
}

actor_def_00D217 [
  actor-def < #00, #00, #20, {

  code_00D21A:
    LDY $decelStepCounter
    LDA $16
    SEC 
    SBC #$0008
    CMP $0016, Y
    BCC loc_00D229
    RTL 

  loc_00D229:
    CLC 
    ADC #$0020
    CMP $0016, Y
    BCS loc_00D233
    RTL 

  loc_00D233:
    LDA $0014, Y
    CMP $14
    BEQ loc_00D23B
    RTL 

  loc_00D23B:
    JSR $&code_00D34A
    BCC loc_00D241
    RTL 

  loc_00D241:
    LDA $0028, Y
    CMP #$0012
    BEQ loc_00D24F
    CMP #$0013
    BEQ loc_00D24F
    RTL 

  loc_00D24F:
    LDA #$D35E
    STA $0000, Y
    LDA #$0080
    STA $0002, Y
    JSR $&code_00D1CE
    RTL 
} >
]

actor_def_00D25F [
  actor-def < #00, #00, #20, {

  code_00D262:
    LDY $decelStepCounter
    LDA $16
    SEC 
    SBC #$0008
    CMP $0016, Y
    BCC loc_00D271
    RTL 

  loc_00D271:
    CLC 
    ADC #$0020
    CMP $0016, Y
    BCS loc_00D27B
    RTL 

  loc_00D27B:
    LDA $0014, Y
    CMP $14
    BEQ loc_00D283
    RTL 

  loc_00D283:
    JSR $&code_00D34A
    BCC loc_00D289
    RTL 

  loc_00D289:
    LDA $0028, Y
    CMP #$0015
    BEQ loc_00D297
    CMP #$0016
    BEQ loc_00D297
    RTL 

  loc_00D297:
    LDA #$D38C
    STA $0000, Y
    LDA #$0080
    STA $0002, Y

  loc_00D2A3:
    JSR $&code_00D1CE
    RTL 
} >
]

actor_def_00D2A7 [
  actor-def < #00, #00, #20, {

  code_00D2AA:
    COP [AddPosition] ( #F8, #00 )
    BRA code_00D2B3
} >
]

actor_def_00D2B0 [
  actor-def < #00, #00, #20, {

  code_00D2B3:
    COP [SetEntryContinue]
    LDY $decelStepCounter
    LDA $14
    SEC 
    SBC #$0008
    CMP $0014, Y
    BCC loc_00D2C4
    RTL 

  loc_00D2C4:
    CLC 
    ADC #$0020
    CMP $0014, Y
    BCS loc_00D2CE
    RTL 

  loc_00D2CE:
    LDA $0016, Y
    SEC 
    SBC $16
    BEQ loc_00D2D7
    RTL 

  loc_00D2D7:
    JSR $&code_00D34A
    BCC loc_00D2DD
    RTL 

  loc_00D2DD:
    LDA $0028, Y
    CMP #$000F
    BEQ loc_00D2EB
    CMP #$0010
    BEQ loc_00D2EB
    RTL 

  loc_00D2EB:
    LDA #$D3BA
    STA $0000, Y
    LDA #$0080
    STA $0002, Y
    JSR $&code_00D1CE
    RTL 
} >
]

actor_def_00D2FB [
  actor-def < #00, #00, #20, {

  code_00D2FE:
    LDY $decelStepCounter
    LDA $14
    SEC 
    SBC #$0008
    CMP $0014, Y
    BCC loc_00D30D
    RTL 

  loc_00D30D:
    CLC 
    ADC #$0020
    CMP $0014, Y
    BCS loc_00D317
    RTL 

  loc_00D317:
    LDA $0016, Y
    SEC 
    SBC $16
    BEQ loc_00D320
    RTL 

  loc_00D320:
    LDY $decelStepCounter
    JSR $&code_00D34A
    BCC loc_00D329
    RTL 

  loc_00D329:
    LDY $decelStepCounter
    LDA $0028, Y
    CMP #$000C
    BEQ loc_00D33A
    CMP #$000D
    BEQ loc_00D33A
    RTL 

  loc_00D33A:
    LDA #$D3E8
    STA $0000, Y
    LDA #$0080
    STA $0002, Y
    JSR $&code_00D1CE
    RTL 
} >
]

code_00D34A {
    PHX 
    TYX 
    SEP #$20
    LDA $7F0008, X
    CMP #$8F
    REP #$20
    BEQ loc_00D35B
    PLX 
    SEC 
    RTS 

  loc_00D35B:
    PLX 
    CLC 
    RTS 
}

code_00D35E {
    LDA #$2200
    TSB $10
    LDA #$0008
    TRB $10
    COP [SetEntryContinue]
    LDA $14
    SEC 
    SBC #$0004
    STA $14
    LDA $statsPtr, X
    DEC 
    BEQ loc_00D37E
    STA $statsPtr, X
    RTL 

  loc_00D37E:
    LDA #$2000
    TRB $10
    COP [StageSpriteFrame] ( #14 )
    COP [AnimOnce]
    JSR $&code_00D1F4
    RTL 
}

code_00D38C {
    LDA #$2200
    TSB $10
    LDA #$0008
    TRB $10
    COP [SetEntryContinue]
    LDA $14
    CLC 
    ADC #$0004
    STA $14
    LDA $statsPtr, X
    DEC 
    BEQ loc_00D3AC
    STA $statsPtr, X
    RTL 

  loc_00D3AC:
    LDA #$2000
    TRB $10
    COP [StageSpriteFrame] ( #17 )
    COP [AnimOnce]
    JSR $&code_00D1F4
    RTL 
}

code_00D3BA {
    LDA #$2200
    TSB $10
    LDA #$0008
    TRB $10
    COP [SetEntryContinue]
    LDA $16
    SEC 
    SBC #$0004
    STA $16
    LDA $statsPtr, X
    DEC 
    BEQ loc_00D3DA
    STA $statsPtr, X
    RTL 

  loc_00D3DA:
    LDA #$2000
    TRB $10
    COP [StageSpriteFrame] ( #11 )
    COP [AnimOnce]
    JSR $&code_00D1F4
    RTL 
}

code_00D3E8 {
    LDA #$2200
    TSB $10
    LDA #$0008
    TRB $10
    COP [SetEntryContinue]
    LDA $16
    CLC 
    ADC #$0004
    STA $16
    LDA $statsPtr, X
    DEC 
    BEQ loc_00D408
    STA $statsPtr, X
    RTL 

  loc_00D408:
    LDA #$2000
    TRB $10
    COP [StageSpriteFrame] ( #0E )
    COP [AnimOnce]
    JSR $&code_00D1F4
    RTL 
}

actor_def_00D416 [
  actor-def < #00, #00, #20, {

  code_00D419:
    COP [SetEntryContinue]

  code_00D41B:
    LDA $14
    CLC 
    ADC #$0008
    STA $0018
    LDA $09C0
    JSR $&code_00D601
    BCC loc_00D42D
    RTL 

  loc_00D42D:
    LDY $decelStepCounter
    LDA $0016, Y
    SEC 
    SBC $16
    BPL loc_00D43C
    EOR #$FFFF
    INC 

  loc_00D43C:
    CMP #$0019
    BMI loc_00D442
    RTL 

  loc_00D442:
    LDA $0014, Y
    SEC 
    SBC #$0008
    SEC 
    SBC $0018
    BMI loc_00D450
    RTL 

  loc_00D450:
    BPL loc_00D456
    EOR #$FFFF
    INC 

  loc_00D456:
    CMP #$000F
    BCC loc_00D45C
    RTL 

  loc_00D45C:
    COP [SetEntryContinue]
    LDY $decelStepCounter
    LDA $0014, Y
    SEC 
    SBC $14
    BEQ loc_00D47A
    BPL loc_00D46F
    EOR #$FFFF
    INC 

  loc_00D46F:
    CMP #$0010
    BCS loc_00D475
    RTL 

  loc_00D475:
    COP [SetEntryExitNow] ( @code_00D41B )

  loc_00D47A:
    LDA #$D618
    STA $0000, Y
    LDA #$0080
    STA $0002, Y
    JSR $&code_00D5DC
    COP [SetEntryExitNow] ( @code_00D41B )
} >
]

actor_def_00D48E [
  actor-def < #00, #00, #20, {

  code_00D491:
    COP [SetEntryContinue]

  code_00D493:
    LDA $14
    SEC 
    SBC #$0008
    STA $0018
    LDA $09C0
    JSR $&code_00D601
    BCC loc_00D4A5
    RTL 

  loc_00D4A5:
    LDY $decelStepCounter
    LDA $0016, Y
    SEC 
    SBC $16
    BPL loc_00D4B4
    EOR #$FFFF
    INC 

  loc_00D4B4:
    CMP #$0019
    BMI loc_00D4BA
    RTL 

  loc_00D4BA:
    LDA $0014, Y
    CLC 
    ADC #$0008
    SEC 
    SBC $0018
    BPL loc_00D4C8
    RTL 

  loc_00D4C8:
    CMP #$000F
    BCC loc_00D4CE
    RTL 

  loc_00D4CE:
    COP [SetEntryContinue]
    LDY $decelStepCounter
    LDA $0014, Y
    SEC 
    SBC $14
    BEQ loc_00D4EC
    BPL loc_00D4E1
    EOR #$FFFF
    INC 

  loc_00D4E1:
    CMP #$0010
    BCS loc_00D4E7
    RTL 

  loc_00D4E7:
    COP [SetEntryExitNow] ( @code_00D493 )

  loc_00D4EC:
    LDA #$D63B
    STA $0000, Y
    LDA #$0080
    STA $0002, Y
    JSR $&code_00D5DC
    COP [SetEntryExitNow] ( @code_00D493 )
} >
]

actor_def_00D500 [
  actor-def < #00, #00, #20, {

  code_00D503:
    COP [SetEntryContinue]

  code_00D505:
    LDA $decelCurvePtr
    JSR $&code_00D601
    BCC loc_00D50E
    RTL 

  loc_00D50E:
    LDY $decelStepCounter
    LDA $0014, Y
    SEC 
    SBC $14
    BPL loc_00D51D
    EOR #$FFFF
    INC 

  loc_00D51D:
    CMP #$0011
    BMI loc_00D523
    RTL 

  loc_00D523:
    LDA $0016, Y
    SEC 
    SBC #$0010
    SEC 
    SBC $16
    BMI loc_00D530
    RTL 

  loc_00D530:
    BPL loc_00D536
    EOR #$FFFF
    INC 

  loc_00D536:
    CMP #$000F
    BCC loc_00D53C
    RTL 

  loc_00D53C:
    COP [SetEntryContinue]
    LDY $decelStepCounter
    LDA $0016, Y
    SEC 
    SBC $16
    BEQ loc_00D55A
    BPL loc_00D54F
    EOR #$FFFF
    INC 

  loc_00D54F:
    CMP #$0010
    BCS loc_00D555
    RTL 

  loc_00D555:
    COP [SetEntryExitNow] ( @code_00D505 )

  loc_00D55A:
    LDA #$D65E
    STA $0000, Y
    LDA #$0080
    STA $0002, Y
    JSR $&code_00D5DC
    COP [SetEntryExitNow] ( @code_00D505 )
} >
]

actor_def_00D56E [
  actor-def < #00, #00, #20, {

  code_00D571:
    COP [SetEntryContinue]

  code_00D573:
    LDA $16
    SEC 
    SBC #$0010
    STA $001C
    LDA $decelCurvePtr
    JSR $&code_00D601
    BCC loc_00D585
    RTL 

  loc_00D585:
    LDY $decelStepCounter
    LDA $0014, Y
    SEC 
    SBC $14
    BPL loc_00D594
    EOR #$FFFF
    INC 

  loc_00D594:
    CMP #$0011
    BMI loc_00D59A
    RTL 

  loc_00D59A:
    LDA $0016, Y
    SEC 
    SBC $001C
    BPL loc_00D5A4
    RTL 

  loc_00D5A4:
    CMP #$000F
    BCC loc_00D5AA
    RTL 

  loc_00D5AA:
    COP [SetEntryContinue]
    LDY $decelStepCounter
    LDA $0016, Y
    SEC 
    SBC $16
    BEQ loc_00D5C8
    BPL loc_00D5BD
    EOR #$FFFF
    INC 

  loc_00D5BD:
    CMP #$0010
    BCS loc_00D5C3
    RTL 

  loc_00D5C3:
    COP [SetEntryExitNow] ( @code_00D573 )

  loc_00D5C8:
    LDA #$D696
    STA $0000, Y
    LDA #$0080
    STA $0002, Y
    JSR $&code_00D5DC
    COP [SetEntryExitNow] ( @code_00D573 )
} >
]

code_00D5DC {
    STZ $09C0
    STZ $decelCurvePtr
    LDA $0E
    PHX 
    TYX 
    STA $statsPtr, X
    LDA #$0000
    STA $002C, X
    STA $002E, X
    PLX 
    LDA #$0F00
    TSB $joypadMaskStd
    LDA #$0800
    TSB $slopeCurvePtrB
    RTS 
}

code_00D601 {
    BPL loc_00D607
    EOR #$FFFF
    INC 

  loc_00D607:
    CMP #$0006
    BCC loc_00D616
    LDA $slopeCurvePtrB
    BIT #$0800
    BNE loc_00D616
    CLC 
    RTS 

  loc_00D616:
    SEC 
    RTS 
}

code_00D618 {
    COP [SpawnAfter] ( @code_00D706 )
    PHX 
    LDX $06
    LDA #$FFF8
    STA $orbitDiameter, X
    PLX 
    LDA #$0008
    TRB $10
    LDA #$0200
    TSB $10

  loc_00D632:
    COP [StagePlayerMoveXY] ( #21, #10, #00 )
    COP [AnimOnce]
    BRA loc_00D632

  loc_00D63B:
    COP [SpawnAfter] ( @code_00D706 )
    PHX 
    LDX $06
    LDA #$0008
    STA $orbitDiameter, X
    PLX 
    LDA #$0008
    TRB $10
    LDA #$0200
    TSB $10

  loc_00D655:
    COP [StagePlayerMoveXY] ( #24, #0F, #00 )
    COP [AnimOnce]
    BRA loc_00D655

  loc_00D65E:
    LDA $statsPtr, X
    STA $loopCounter, X
    LDA #$D677
    STA $retPtr2, X
    LDA #$0008
    TRB $10
    LDA #$0200
    TSB $10
    COP [StagePlayerMoveXY] ( #1E, #00, #10 )
    COP [AnimOnce]
    COP [LoopNext]
    LDA #$FFF8
    STA $decelCurvePtr
    JSR $&code_00D6D0
    LDA #$0000
    STA $09C4
    LDA #$0007
    STA $slopeFracAccum
    RTL 
}

code_00D696 {
    LDA $statsPtr, X
    STA $loopCounter, X
    LDA #$D6B1
    STA $retPtr2, X
    COP [SetEntryContinue]
    LDA #$0008
    TRB $10
    LDA #$0200
    TSB $10
    COP [StagePlayerMoveXY] ( #19, #00, #0F )
    COP [AnimOnce]
    COP [LoopNext]
    LDA #$0008
    STA $decelCurvePtr
    JSR $&code_00D6D0
    LDA #$0000
    STA $09C4
    LDA #$0007
    STA $slopeFracAccum
    RTL 
}

code_00D6D0 {
    PHX 
    LDX $decelStepCounter
    LDA #$0082
    STA $0002, X
    LDA #$D01B
    STA $0000, X
    LDA #$0000
    STA $002C, X
    STA $002E, X
    STA $0008, X
    LDA $0010, X
    AND #$FDFF
    ORA #$0008
    STA $0010, X
    LDA #$0F00
    TRB $joypadMaskStd
    LDA #$0800
    TRB $slopeCurvePtrB
    PLX 
    RTS 
}

code_00D706 {
    PHX 
    LDX $04
    LDA $statsPtr, X
    ASL 
    CLC 
    ADC $statsPtr, X
    TAX 
    LDA $@binary_01D8E7.array_01D934+2, X
    AND #$00FF
    TAY 
    LDA $@binary_01D8E7.array_01D934, X
    SEC 
    SBC #$D934
    PLX 
    STA $orbitAngle, X
    TYA 
    STA $loopCounter, X
    STZ $2A
    LDA #$D737
    STA $retPtr2, X
    PHX 
    LDA $orbitAngle, X
    CLC 
    ADC $2A
    INC $2A
    TAX 
    LDA $@binary_01D8E7.array_01D934, X
    AND #$00FF
    BIT #$0080
    BEQ loc_00D751
    ORA #$FF00

  loc_00D751:
    LDX $04
    CLC 
    ADC $0016, X
    STA $0016, X
    PLX 
    COP [LoopNext]
    LDA $orbitDiameter, X
    STA $09C0
    JSR $&code_00D6D0
    LDA #$0000
    STA $09C4
    LDA #$0007
    STA $slopeFracAccum
    COP [Die]

  loc_00D775:
    LDA #$0040
    TSB $10
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #20 )
    COP [SpawnThinker] ( @code_00B65E )
    COP [SpawnAfter] ( @code_00D85E )
    COP [WaitByte] ( #77 )
    LDA #$8000
    TRB $10
    COP [PlaySoundBoth] ( #$0C0C )
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    LDA #$000F
    STA $orbitAngle, X

  loc_00D7AA:
    SEP #$20
    LDA $orbitAngle, X
    DEC 
    BMI loc_00D7C1
    STA $orbitAngle, X
    STA $INIDISP
    REP #$20
    COP [WaitByte] ( #03 )
    BRA loc_00D7AA

  loc_00D7C1:
    REP #$20
    COP [SpawnThinkerParam] ( #0B, @code_00B5C4 )
    COP [SpawnThinkerParam] ( #0D, @code_00B5C4 )
    COP [SetEntryExit]
    PHB 
    LDA $gemCount
    CMP #$0064
    BCC loc_00D7F3
    SBC #$0064
    STA $gemCount
    LDA $playerMaxHp
    LSR 
    STA $playerHp
    SEP #$20
    LDA $0AF6
    PHA 
    PLB 
    LDY $0AF4
    BRA loc_00D82C

  loc_00D7F3:
    STZ $gemCount
    LDA $sceneCurrent
    AND #$00FF
    CMP #$00E8
    BNE loc_00D809
    LDA #$0002
    STA $characterForm
    BRA loc_00D80C

  loc_00D809:
    STZ $characterForm

  loc_00D80C:
    LDA $playerMaxHp
    STA $playerHp
    LDY #$0000
    LDA #$0000

  loc_00D818:
    STA $wramFlags, Y
    INY 
    INY 
    CPY #$0020
    BNE loc_00D818
    SEP #$20
    LDA $0AF2
    PHA 
    PLB 
    LDY $sceneSaveData

  loc_00D82C:
    LDA $0000, Y
    STA $sceneNext
    LDA $0005, Y
    AND #$7F
    STA $0650
    REP #$20
    LDA $0001, Y
    STA $064C
    LDA $0003, Y
    STA $064E
    LDA $0006, Y
    STA $0652
    PLB 
    LDA #$0404
    STA $gfxCacheIdxB
    INC $0AF8
    STZ $worldReadyFlag
    COP [SetEntryContinue]
    RTL 
}

code_00D85E {
    LDA #$2000
    TSB $10
    COP [SetMetasprite] ( @table_0EE000 )
    COP [SetSpritePalette] ( #00 )
    COP [WaitByte] ( #0B )
    COP [SpawnMarkedAfterRel] ( @code_00D894, #E7, #D8, #$0700 )
    COP [WaitByte] ( #02 )
    COP [SpawnMarkedAfterRel] ( @code_00D8B8, #19, #E8, #$0700 )
    COP [WaitByte] ( #04 )
    COP [SpawnMarkedAfterRel] ( @code_00D894, #E7, #F8, #$0700 )
    COP [WaitByte] ( #62 )
    COP [Die]
}

code_00D894 {
    LDA #$0001
    TSB $10
    COP [StageSpriteMoveXY] ( #15, #2D, #2F )
    COP [AnimOnce]
    LDA #$0001
    TRB $10
    LDA #$0002
    TSB $10
    COP [StageSpriteMoveXY] ( #15, #2E, #30 )
    COP [AnimOnce]
    LDA #$0002
    TRB $10
    BRA code_00D894
}

code_00D8B8 {
    LDA #$0001
    TSB $10
    COP [StageSpriteMoveXY] ( #15, #2E, #2F )
    COP [AnimOnce]
    LDA #$0001
    TRB $10
    LDA #$0002
    TSB $10
    COP [StageSpriteMoveXY] ( #15, #2D, #30 )
    COP [AnimOnce]
    LDA #$0002
    TRB $10
    BRA code_00D8B8

  code_00D8DC:
    LDA #$CFF0
    TSB $joypadMaskStd
    STZ $0AF8
    COP [WaitByte] ( #02 )
    LDA $characterForm
    BNE loc_00D8F3
    COP [PrintDialogString] ( &dialogstring_00D908 )
    BRA loc_00D900

  loc_00D8F3:
    DEC 
    BNE loc_00D8FC
    COP [PrintDialogString] ( &dialogstring_00D945 )
    BRA loc_00D900

  loc_00D8FC:
    COP [PrintDialogString] ( &dialogstring_00D96E )

  loc_00D900:
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [Die]
}

dialogstring_00D908 `[DEF]テム:[N]気がつくと ぼくは 見覚えのある[N]場所に たおれていた.[N]悪い夢を 見ていたのだろうか··[END]`

dialogstring_00D945 `[DEF]フリーダン:[N]気がつくと そこは 見覚えのある[N]場所だった···[END]`

dialogstring_00D96E `[DEF]シャドウ:[N]気がつくと そこは 見覚えのある[N]場所だった···[END]`

code_00D996 {
    LDA $extendedFlags, X
    BIT #$0020
    BNE loc_00D9A4
    LDA #$0008
    TSB $10

  loc_00D9A4:
    LDA #$0008
    TSB $12
    LDA $12
    BIT #$0010
    BNE loc_00D9E5
    PHX 
    LDY $24
    LDA $0014, Y
    STA $orbitAngle, X
    STA $14
    LDA $0016, Y
    STA $orbitDiameter, X
    STA $16
    TYX 
    LDA $free101C, X
    PLX 
    STA $free101C, X
    LDA $0028, X
    CMP #$0004
    BCS loc_00D9E5
    PEA $&code_00DA23-1
    DEC 
    BMI loc_00D9F5
    DEC 
    BMI loc_00D9FF
    DEC 
    BMI loc_00DA0C
    BRA loc_00DA19

  loc_00D9E5:
    COP [WaitByte] ( #0F )
    LDA $10
    BIT #$0400
    BEQ loc_00D9F2
    JMP $&code_00DB0A

  loc_00D9F2:
    JMP $&code_00DAA7

  loc_00D9F5:
    LDA #$6000
    TRB $12
    SEC 
    JSR $&code_00DB66
    RTS 

  loc_00D9FF:
    LDA #$6000
    TRB $12
    COP [SetForceBoth] ( #01 )
    SEC 
    JSR $&code_00DB66
    RTS 

  loc_00DA0C:
    LDA #$6000
    TRB $12
    COP [SetForceBoth] ( #01 )
    CLC 
    JSR $&code_00DB66
    RTS 

  loc_00DA19:
    LDA #$6000
    TRB $12
    CLC 
    JSR $&code_00DB66
    RTS 
}

code_00DA23 {
    COP [SetEntryExit]
    COP [LoopInit] ( #10 )
    LDY $24
    LDA $14
    STA $0014, Y
    LDA $16
    STA $0016, Y
    COP [LoopNext]
    LDA $10
    BIT #$0400
    BEQ loc_00DA40
    JMP $&code_00DB0A

  loc_00DA40:
    LDA $10
    BIT #$0008
    BEQ code_00DAA7
    LDA $26
    BNE loc_00DA7A
    LDA $orbitDiameter, X
    SEC 
    SBC $16
    BEQ code_00DAA7
    BPL loc_00DA5A
    EOR #$FFFF
    INC 

  loc_00DA5A:
    BIT #$000F
    BNE loc_00DA64
    JSR $&code_00DB32
    BCC code_00DAA7

  loc_00DA64:
    LDX $24
    LDA $002C, X
    BNE loc_00DA6E
    STZ $0008, X

  loc_00DA6E:
    LDA #$0000
    STA $002E, X
    STA $moveScratch2, X
    BRA loc_00DAA9

  loc_00DA7A:
    LDA $orbitAngle, X
    SEC 
    SBC $14
    BEQ code_00DAA7
    BPL loc_00DA89
    EOR #$FFFF
    INC 

  loc_00DA89:
    BIT #$000F
    BNE loc_00DA93
    JSR $&code_00DB32
    BCC code_00DAA7

  loc_00DA93:
    LDX $24
    LDA $002E, X
    BNE loc_00DA9D
    STZ $0008, X

  loc_00DA9D:
    LDA #$0000
    STA $002C, X
    STA $moveScratch1, X
}

code_00DAA7 {
    LDX $24

  loc_00DAA9:
    LDA $currentHp, X
    BNE loc_00DAEF
    LDA $0010, X
    BIT #$0040
    BNE loc_00DB06
    ORA #$0040
    STA $0010, X
    LDA $onDeathCallback, X
    BEQ loc_00DADB
    STA $0000, X
    LDA $7F1006, X
    STA $0002, X
    LDA #$0000
    STA $0008, X
    STA $002C, X
    STA $002E, X
    BRA loc_00DB06

  loc_00DADB:
    LDA #$0080
    STA $0002, X
    LDA #$DCA9
    STA $0000, X
    LDA #$0000
    STA $0008, X
    BRA loc_00DB06

  loc_00DAEF:
    LDA $onHitCallback, X
    BEQ loc_00DAFF
    STA $0000, X
    LDA #$0000
    STA $onHitCallback, X

  loc_00DAFF:
    LDA #$FFF4
    STA $iframeCounter, X

  loc_00DB06:
    TDC 
    TAX 
    COP [Die]
}

code_00DB0A {
    PHX 
    LDX $decelStepCounter
    LDA $slopeCurvePtrB
    BIT #$0A00
    BNE loc_00DB22
    LDA #$0082
    STA $0002, X
    LDA #$D01B
    STA $0000, X

  loc_00DB22:
    LDA #$FFE2
    STA $iframeCounter, X
    PLX 
    LDA #$0F00
    TRB $joypadMaskStd
    COP [Die]
}

code_00DB32 {
    STA $0000
    PEA $&code_00DB60-1
    LDA $free101C, X
    BNE loc_00DB45
    LDA $0000
    CMP #$0030
    RTS 

  loc_00DB45:
    DEC 
    BNE loc_00DB4F
    LDA $0000
    CMP #$0020
    RTS 

  loc_00DB4F:
    DEC 
    BNE loc_00DB59
    LDA $0000
    CMP #$0040
    RTS 

  loc_00DB59:
    LDA $0000
    CMP #$0040
    RTS 
}

code_00DB60 {
    CLC 
    BNE loc_00DB64
    RTS 

  loc_00DB64:
    SEC 
    RTS 
}

code_00DB66 {
    PEA $&code_00DB85-1
    LDA $free101C, X
    BNE loc_00DB73
    LDY #$0044
    RTS 

  loc_00DB73:
    DEC 
    BNE loc_00DB7A
    LDY #$0046
    RTS 

  loc_00DB7A:
    DEC 
    BNE loc_00DB81
    LDY #$0046
    RTS 

  loc_00DB81:
    LDY #$0046
    RTS 
}

code_00DB85 {
    LDA $&table_01B06E, Y
    BCS loc_00DB92
    STA $2C
    LDA #$0001
    STA $26
    RTS 

  loc_00DB92:
    STA $2E
    STZ $26
    RTS 
}

code_00DB97 {
    COP [SetMetasprite] ( @table_0EE000 )
    COP [SetSpritePalette] ( #00 )
    LDA #$6000
    TRB $12
    LDA $26
    BNE code_00DBF8
    LDA $sceneCurrent
    JSL $@code_00B544
    BCS code_00DBF8
    LDY $sceneCurrent
    LDA $&reward_table, Y
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_00DBC3 )
}

code_list_00DBC3 [
  &code_00DBF8   ;00
  &code_00DBCB   ;01
  &code_00DBDA   ;02
  &code_00DBE9   ;03
]

code_00DBCB {
    COP [StageSprAndHitbox] ( #0C )
    LDA #$FFFF
    STA $orbitAngle, X
    LDA #$0080
    BRA loc_00DC2A
}

code_00DBDA {
    COP [StageSprAndHitbox] ( #0D )
    LDA #$FFFF
    STA $orbitAngle, X
    LDA #$0081
    BRA loc_00DC2A
}

code_00DBE9 {
    COP [StageSprAndHitbox] ( #0E )
    LDA #$FFFF
    STA $orbitAngle, X
    LDA #$0082
    BRA loc_00DC2A
}

code_00DBF8 {
    LDA $statsPtr, X
    TAY 
    LDA $0003, Y
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_00DC0C )
}

code_list_00DC0C [
  &code_00DCA7   ;00
  &code_00DC14   ;01
  &code_00DC1C   ;02
  &code_00DC24   ;03
]

code_00DC14 {
    COP [StageSprAndHitbox] ( #04 )
    LDA #$0083
    BRA loc_00DC2A
}

code_00DC1C {
    COP [StageSprAndHitbox] ( #05 )
    LDA #$0084
    BRA loc_00DC2A
}

code_00DC24 {
    COP [StageSprAndHitbox] ( #06 )
    LDA #$0085

  loc_00DC2A:
    STA $chatPtr, X
    LDA $16
    STA $24
    LDA #$0007
    STA $26
    LDA $16
    AND #$FFF0
    STA $16
    BRA loc_00DC62

  code_00DC40:
    DEC $26
    BPL loc_00DC4B
    LDA $24
    INC 
    STA $16
    BRA loc_00DC66

  loc_00DC4B:
    PHX 
    TYX 
    LDA $collisionLayer, X
    PLX 
    AND #$00FF
    CMP #$000E
    BEQ loc_00DC66
    LDA $16
    CLC 
    ADC #$0010
    STA $16

  loc_00DC62:
    COP [BranchIfSolid] ( &code_00DC40 )

  loc_00DC66:
    LDA $16
    STA $moveYAlt, X
    LDA $14
    STA $moveXAlt, X
    LDA $24
    STA $16
    COP [MoveToward] ( #FF, #04 )
    COP [StageForceMoveXY] ( #00, #45 )
    COP [WaitByte] ( #0B )
    COP [SpawnMarkedAfter] ( @code_00E24C, #$2300 )

  loc_00DC88:
    COP [LoopInit] ( #64 )
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    COP [LoopNext]
    LDA $28
    CMP #$0008
    BCS loc_00DC88
    CLC 
    ADC #$0005
    STA $28
    COP [LoopInit] ( #0A )
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    COP [LoopNext]
}

code_00DCA7 {
    COP [Die]

  code_00DCA9:
    LDA $statsPtr, X
    CMP #$ABD8
    BNE loc_00DCB5
    JMP $&code_00DCD5

  loc_00DCB5:
    LDA $extendedFlags, X
    BIT #$0080
    BNE code_00DCD5
    SED 
    LDA $0AEE
    SEC 
    SBC #$0001
    STA $0AEE
    CLD 
    LDA $0AEC
    DEC 
    STA $0AEC
    STA $orbitAngle, X
}

code_00DCD5 {
    LDA #$0000
    STA $2C
    STA $2E
    STA $moveScratch1, X
    STA $moveScratch2, X
    COP [PlaySoundCh1] ( #06 )
    COP [SpawnLastRel] ( @code_00E034, #00, #00, #$0302 )
    LDA $0012, Y
    ORA #$1000
    STA $0012, Y
    COP [WaitByte] ( #02 )
    LDA $statsPtr, X
    CMP #$ABD8
    BNE loc_00DD08
    JMP $&code_00DD7E

  loc_00DD08:
    LDA $extendedFlags, X
    BIT #$0080
    BNE code_00DD7E
    COP [SetDungeonKillFlag]
    LDA $sceneCurrent
    JSL $@code_00B544
    BCS loc_00DD22
    LDA $orbitAngle, X
    BEQ code_00DD32

  loc_00DD22:
    LDA $statsPtr, X
    TAY 
    LDA $0003, Y
    AND #$00FF
    BEQ code_00DD32
    JMP $&code_00DE7A

  code_00DD32:
    LDA #$2000
    TSB $10
    LDA $extendedFlags, X
    BIT #$0008
    BEQ loc_00DD42
    COP [ClearLowHere]

  loc_00DD42:
    LDA $deathActionIdx, X
    BEQ loc_00DD73
    JSL $@code_00B5A4
    BCS loc_00DD73
    LDA $deathActionIdx, X
    JSL $@code_00B58E
    COP [SpawnLastRel] ( @code_00DF11, #00, #00, #$0342 )
    LDA $0012, Y
    ORA #$1000
    STA $0012, Y
    PHX 
    LDA $deathActionIdx, X
    TYX 
    STA $deathActionIdx, X
    PLX 

  loc_00DD73:
    LDA $orbitAngle, X
    BNE loc_00DD7C
    JMP $&code_00DEA6

  loc_00DD7C:
    COP [Die]
}

code_00DD7E {
    COP [WaitByte] ( #02 )
    LDA #$2000
    TSB $10
    LDA $extendedFlags, X
    BIT #$0008
    BEQ loc_00DD91
    COP [ClearLowHere]

  loc_00DD91:
    COP [WaitByte] ( #05 )
    COP [Die]

  loc_00DD96:
    COP [Die]

  loc_00DD98:
    LDA #$3200
    STA $0E
    LDA $16
    CLC 
    ADC #$FFF8
    STA $16
    COP [LoopInit] ( #04 )
    LDA $16
    CLC 
    ADC #$0002
    STA $16
    LDA $28
    STA $0000
    JSL $@chunk_3B7DD.code_03B7ED
    COP [LoopNext]
    COP [LoopInit] ( #20 )
    LDA $16
    CLC 
    ADC #$FFFF
    STA $16
    LDA $28
    STA $0000
    JSL $@chunk_3B7DD.code_03B7ED
    COP [LoopNext]
    COP [Die]

  code_00DDD3:
    LDA #$3200
    STA $0E
    LDA $16
    CLC 
    ADC #$FFF0
    STA $16
    LDY $24
    LDA $0014, Y
    STA $20
    LDA $0016, Y
    STA $22
    COP [LoopInit] ( #10 )
    LDY $24
    LDA $0014, Y
    SEC 
    SBC $20
    CLC 
    ADC $14
    STA $14
    LDA $0016, Y
    SEC 
    SBC $22
    CLC 
    ADC $16
    CLC 
    ADC #$FFFF
    STA $16
    LDA $0014, Y
    STA $20
    LDA $0016, Y
    STA $22
    LDA $28
    STA $0000
    JSL $@chunk_3B7DD.code_03B7ED
    COP [LoopNext]
    COP [Die]

  code_00DE22:
    COP [LoopInit] ( #08 )
    JSR $&code_00DE3C
    COP [LoopNext]
    COP [LoopInit] ( #10 )
    LDA $16
    CLC 
    ADC #$FFFF
    STA $16
    JSR $&code_00DE3C
    COP [LoopNext]
    COP [Die]
}

code_00DE3C {
    PHX 
    LDX $00D8
    LDA #$327A
    STA $7F3104, X
    LDA $14
    SEC 
    SBC #$0004
    STA $oamComposeBuffer, X
    LDA $16
    STA $7F3102, X
    LDA #$327B
    STA $7F310A, X
    LDA $14
    CLC 
    ADC #$0004
    STA $7F3106, X
    LDA $16
    STA $7F3108, X
    LDA $00D8
    CLC 
    ADC #$000C
    STA $00D8
    PLX 
    RTS 
}

code_00DE7A {
    DEC 
    BEQ loc_00DE82
    DEC 
    BEQ loc_00DE8E
    BRA loc_00DE9A

  loc_00DE82:
    COP [SpawnLastRel] ( @code_00E048, #00, #00, #$0420 )
    JMP $&code_00DD32

  loc_00DE8E:
    COP [SpawnLastRel] ( @code_00E071, #00, #00, #$0420 )
    JMP $&code_00DD32

  loc_00DE9A:
    COP [SpawnLastRel] ( @code_00E09A, #00, #00, #$0420 )
    JMP $&code_00DD32
}

code_00DEA6 {
    COP [SetSpritePalette] ( #00 )
    LDY $sceneCurrent
    LDA $&reward_table, Y
    AND #$00FF
    PHA 
    LDA $sceneCurrent
    JSL $@code_00B544
    BCS loc_00DED2
    COP [SetSpritePalette] ( #00 )
    LDA $01, S
    BEQ loc_00DED2
    LDA #$0080
    TSB $09FA
    PLA 
    DEC 
    BEQ loc_00DED5
    DEC 
    BEQ loc_00DEE9
    BRA loc_00DEFD

  loc_00DED2:
    PLA 
    COP [Die]

  loc_00DED5:
    COP [SpawnLastRel] ( @code_00E14C, #00, #00, #$1000 )
    LDA $0012, Y
    ORA #$1000
    STA $0012, Y
    COP [Die]

  loc_00DEE9:
    COP [SpawnLastRel] ( @code_00E18D, #00, #00, #$1000 )
    LDA $0012, Y
    ORA #$1000
    STA $0012, Y
    COP [Die]

  loc_00DEFD:
    COP [SpawnLastRel] ( @code_00E1CA, #00, #00, #$1000 )
    LDA $0012, Y
    ORA #$1000
    STA $0012, Y
    COP [Die]
}

code_00DF11 {
    COP [SetSpritePalette] ( #00 )
    LDA #$0342
    STA $10
    LDA #$6000
    TRB $12
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteMoveY] ( #29, #02 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #29, #12 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #29, #14 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #29, #02 )
    COP [AnimLoop]
    COP [SetSpritePriority] ( #30 )
    LDA $deathActionIdx, X
    ASL 
    ASL 
    ASL 
    TAY 
    LDA $&array_01D3F7+3, Y
    AND #$00FF
    STA $0000
    LSR 
    STA $orbitAngle, X
    LDA $&array_01D3F7+5, Y
    AND #$00FF
    ASL 
    CLC 
    ADC $0000
    ASL 
    ASL 
    ASL 
    STA $moveXAlt, X
    LDA $&array_01D3F7+4, Y
    AND #$00FF
    STA $0000
    LSR 
    STA $orbitDiameter, X
    LDA $&array_01D3F7+6, Y
    AND #$00FF
    ASL 
    CLC 
    ADC $0000
    ASL 
    ASL 
    ASL 
    STA $moveYAlt, X
    COP [StageMove] ( #29, #04, #FF )
    COP [TickMove]
    COP [SpawnAfterFlags] ( @code_00E029, #$0302 )
    LDA $0012, Y
    ORA #$1000
    STA $0012, Y
    COP [WaitByte] ( #01 )
    LDA #$2000
    TSB $10
    COP [LoopInit] ( #0A )
    COP [SpawnAfterFlags] ( @code_00DFD7, #$0302 )
    LDA $0012, Y
    ORA #$1000
    STA $0012, Y
    LDA $orbitAngle, X
    AND #$00FF
    STA $0020, Y
    LDA $orbitDiameter, X
    AND #$00FF
    STA $0022, Y
    COP [WaitByte] ( #03 )
    COP [LoopNext]
    COP [StageBgChangeFromDeathIdx]
    COP [ApplyBgChange]
    COP [Die]
}

code_00DFD7 {
    COP [RngByte]
    LDY $20
    CPY #$0004
    BCS loc_00DFEB
    CPY #$0002
    BCS loc_00DFF1
    LSR 
    AND #$000F
    BRA loc_00DFF5

  loc_00DFEB:
    LSR 
    AND #$003F
    BRA loc_00DFF5

  loc_00DFF1:
    LSR 
    AND #$001F

  loc_00DFF5:
    BCC loc_00DFFB
    EOR #$FFFF
    INC 

  loc_00DFFB:
    CLC 
    ADC $14
    STA $14
    COP [RngByte]
    LDY $22
    CPY #$0003
    BCS loc_00E014
    CPY #$0002
    BEQ loc_00E01A
    LSR 
    AND #$000F
    BRA loc_00E01E

  loc_00E014:
    LSR 
    AND #$003F
    BRA loc_00E01E

  loc_00E01A:
    LSR 
    AND #$001F

  loc_00E01E:
    BCC loc_00E024
    EOR #$FFFF
    INC 

  loc_00E024:
    CLC 
    ADC $16
    STA $16
}

code_00E029 {
    COP [PlaySoundBoth] ( #$0606 )
    COP [StageSpriteFrame] ( #25 )
    COP [AnimOnce]
    COP [Die]
}

code_00E034 {
    COP [SetMetasprite] ( @table_0EE000 )
    COP [SetSpritePalette] ( #00 )
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    LDA #$2000
    TSB $10
    COP [Die]
}

code_00E048 {
    COP [SetMetasprite] ( @table_0EE000 )
    COP [SetSpritePalette] ( #00 )
    COP [SpawnMarkedAfter] ( @code_00E24C, #$2700 )
    LDA #$0083
    STA $chatPtr, X
    LDA #$0400
    TRB $10
    COP [StageSpriteLoop] ( #04, #0A )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #09, #96 )
    COP [AnimLoop]
    COP [Die]
}

code_00E071 {
    COP [SetMetasprite] ( @table_0EE000 )
    COP [SetSpritePalette] ( #00 )
    COP [SpawnMarkedAfter] ( @code_00E24C, #$2700 )
    LDA #$0084
    STA $chatPtr, X
    LDA #$0400
    TRB $10
    COP [StageSpriteLoop] ( #05, #0A )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #0A, #96 )
    COP [AnimLoop]
    COP [Die]
}

code_00E09A {
    COP [SetMetasprite] ( @table_0EE000 )
    COP [SetSpritePalette] ( #00 )
    COP [SpawnMarkedAfter] ( @code_00E24C, #$2700 )
    LDA $playerMaxHp
    LSR 
    LSR 
    CMP $playerHp
    BCC loc_00E0B8
    LDA #$0020
    BRA loc_00E0C9

  loc_00E0B8:
    LDA $playerMaxHp
    LSR 
    CMP $playerHp
    BCC loc_00E0C6
    LDA #$0010
    BRA loc_00E0C9

  loc_00E0C6:
    LDA #$0000

  loc_00E0C9:
    STA $26
    COP [RngByte]
    PHX 
    LDX $26
    LDY #$0002

  loc_00E0D3:
    CMP $@loc_00E11C, X
    BCC loc_00E0E0
    INX 
    INX 
    INX 
    INX 
    DEY 
    BPL loc_00E0D3

  loc_00E0E0:
    LDA $@loc_00E11C+2, X
    DEC 
    PLX 
    PHA 
    RTS 
}

code_00E0E8 {
    LDA #$0085
    STA $chatPtr, X
    LDA #$0400
    TRB $10
    COP [StageSpriteLoop] ( #06, #0A )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #0B, #96 )
    COP [AnimLoop]
    COP [Die]

  loc_00E102:
    LDA #$0086
    STA $chatPtr, X
    LDA #$0400
    TRB $10
    COP [StageSpriteLoop] ( #22, #B4 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #35, #3C )
    COP [AnimLoop]
    COP [Die]

  loc_00E11C:
    ORA $@210200

  loc_00E120:
    BIT $&01E800, X
    CPX #$0099
    BRA loc_00E108

  loc_00E128:
    BRK #$01
    EOR [$E0], Y
    ORA $&01E800, Y
    CPX #$004C
    EOR [$E0], Y
    STA $deathFlag, Y
    SBC ($00, X)
    ORA ($80, X)
    CPX #$000C
    BRA loc_00E120

  loc_00E140:
    AND ($00, S), Y
    EOR [$E0], Y
    ADC $@20E800, X
    BRK #$01
    COP [RestoreSavedPtrFFFF]
}

code_00E14C {
    COP [SetMetasprite] ( @table_0EE000 )
    COP [SetSpritePalette] ( #00 )
    COP [StageSprAndHitbox] ( #0C )
    COP [CallScript] ( &code_00E207 )
    LDA $playerMaxHp
    CLC 
    ADC #$0001
    BVC loc_00E167
    LDA #$0255

  loc_00E167:
    STA $playerMaxHp
    SEC 
    SBC $playerHp
    STA $damageFlashTimer
    COP [PrintDialogString] ( &dialogstring_00E177 )
    COP [Die]
}

dialogstring_00E177 `[DEF][DLY:1][SFX:0]HP(体力)が 上がった![END]`

code_00E18D {
    COP [SetMetasprite] ( @table_0EE000 )
    COP [SetSpritePalette] ( #00 )
    COP [StageSprAndHitbox] ( #0D )
    COP [CallScript] ( &code_00E207 )
    LDA $playerStr
    CLC 
    ADC #$0001
    BVC loc_00E1A8
    LDA #$0255

  loc_00E1A8:
    STA $playerStr
    COP [PrintDialogString] ( &dialogstring_00E1B1 )
    COP [Die]
}

dialogstring_00E1B1 `[DEF][DLY:1][SFX:0]STR(力の強さ)が 上がった![END]`

code_00E1CA {
    COP [SetMetasprite] ( @table_0EE000 )
    COP [SetSpritePalette] ( #00 )
    COP [StageSprAndHitbox] ( #0E )
    COP [CallScript] ( &code_00E207 )
    LDA $playerDef
    CLC 
    ADC #$0001
    BVC loc_00E1E5
    LDA #$0255

  loc_00E1E5:
    STA $playerDef
    COP [PrintDialogString] ( &dialogstring_00E1EE )
    COP [Die]
}

dialogstring_00E1EE `[DEF][DLY:1][SFX:0]DEF(守りの強さ)が上がった![END]`

code_00E207 {
    LDA #$6000
    TRB $12
    COP [StageSpriteLoopMoveY] ( #FF, #04, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #FF, #03 )
    COP [AnimLoop]
    LDY $decelStepCounter
    LDA $0014, Y
    STA $moveXAlt, X
    LDA $0016, Y
    SEC 
    SBC #$0008
    STA $moveYAlt, X
    COP [StageMove] ( #FF, #02, #FF )
    COP [TickMove]
    LDA #$2000
    TSB $10
    LDA #$0080
    TRB $09FA
    COP [PlaySoundCh2] ( #25 )
    LDA $sceneCurrent
    JSL $@code_00B54F
    COP [RestoreSavedPtr]
}

code_00E24C {
    COP [SetSavedPtr] ( &code_00E24C )
    COP [SetEntryExit]
    COP [BranchIfButton] ( #$0031, &code_00E259 )

  code_00E258:
    RTL 
}

code_00E259 {
    COP [BranchIfPlayerNear] ( #0F, &code_00E25F )
    RTL 
}

code_00E25F {
    COP [BranchOnPlayerX] ( #$000F, &code_00E2D6, &code_00E269, &code_00E2D6 )
}

code_00E269 {
    LDY $decelStepCounter
    LDA $0016, Y
    SEC 
    SBC $16
    BPL loc_00E2A8
    BPL loc_00E27A
    EOR #$FFFF
    INC 

  loc_00E27A:
    LSR 
    STA $orbitAngle, X
    JSL $@chunk_3B7DD.code_03E58B
    CMP #$0000
    BNE loc_00E2A6
    COP [SetEntryContinue]
    LDY $04
    LDA $0016, Y
    SEC 
    SBC #$0002
    STA $0016, Y
    STA $16
    LDA $orbitAngle, X
    BEQ loc_00E2A6
    DEC 
    STA $orbitAngle, X
    BEQ loc_00E2A6
    RTL 

  loc_00E2A6:
    COP [RestoreSavedPtr]

  loc_00E2A8:
    LSR 
    STA $orbitAngle, X
    JSL $@chunk_3B7DD.code_03E58B
    CMP #$0001
    BNE loc_00E2D4
    COP [SetEntryContinue]
    LDY $04
    LDA $0016, Y
    CLC 
    ADC #$0002
    STA $0016, Y
    STA $16
    LDA $orbitAngle, X
    BEQ loc_00E2D4
    DEC 
    STA $orbitAngle, X
    BEQ loc_00E2D4
    RTL 

  loc_00E2D4:
    COP [RestoreSavedPtr]
}

code_00E2D6 {
    COP [BranchOnPlayerY] ( #$000F, &code_00E258, &code_00E2E0, &code_00E258 )
}

code_00E2E0 {
    LDY $decelStepCounter
    LDA $0014, Y
    SEC 
    SBC $14
    BPL loc_00E31F
    BPL loc_00E2F1
    EOR #$FFFF
    INC 

  loc_00E2F1:
    LSR 
    STA $orbitAngle, X
    JSL $@chunk_3B7DD.code_03E58B
    CMP #$0003
    BNE loc_00E31D
    COP [SetEntryContinue]
    LDY $04
    LDA $0014, Y
    SEC 
    SBC #$0002
    STA $0014, Y
    STA $14
    LDA $orbitAngle, X
    BEQ loc_00E31D
    DEC 
    STA $orbitAngle, X
    BEQ loc_00E31D
    RTL 

  loc_00E31D:
    COP [RestoreSavedPtr]

  loc_00E31F:
    LSR 
    STA $orbitAngle, X
    JSL $@chunk_3B7DD.code_03E58B
    CMP #$0002
    BNE loc_00E34B
    COP [SetEntryContinue]
    LDY $04
    LDA $0014, Y
    CLC 
    ADC #$0002
    STA $0014, Y
    STA $14
    LDA $orbitAngle, X
    BEQ loc_00E34B
    DEC 
    STA $orbitAngle, X
    BEQ loc_00E34B
    RTL 

  loc_00E34B:
    COP [RestoreSavedPtr]

  code_00E34D:
    COP [SetSavedPtr] ( &code_00E34D )
    COP [SetEntryExit]
    COP [BranchIfButton] ( #$0031, &code_00E35A )

  code_00E359:
    RTL 
}

code_00E35A {
    COP [BranchIfPlayerNear] ( #0F, &code_00E360 )
    RTL 
}

code_00E360 {
    LDY $04
    LDA $0010, Y
    BIT #$0080
    BEQ loc_00E376
    LDA $0012, Y
    BIT #$0010
    BNE loc_00E376
    NOP 
    NOP 
    NOP 
    RTL 

  loc_00E376:
    COP [BranchOnPlayerX] ( #$000F, &code_00E403, &code_00E380, &code_00E403 )
}

code_00E380 {
    LDY $decelStepCounter
    LDA $0016, Y
    SEC 
    SBC $16
    BPL loc_00E3CA
    BPL loc_00E391
    EOR #$FFFF
    INC 

  loc_00E391:
    CMP #$0020
    BCC code_00E3C8
    JSL $@chunk_3B7DD.code_03E58B
    CMP #$0000
    BNE code_00E3C8
    COP [BranchIfSolidOffset] ( #00, #FF, &code_00E3C8 )
    COP [ClearLowHere]
    LDA $16
    SEC 
    SBC #$0010
    STA $16
    COP [SolidHighHere]
    COP [PlaySoundCh1] ( #2C )
    JSR $&code_00E490
    COP [LoopInit] ( #10 )
    LDY $04
    LDA $0016, Y
    DEC 
    STA $0016, Y
    COP [LoopNext]
    JSR $&code_00E4A3
}

code_00E3C8 {
    COP [RestoreSavedPtr]

  loc_00E3CA:
    CMP #$0020
    BCC code_00E401
    JSL $@chunk_3B7DD.code_03E58B
    CMP #$0001
    BNE code_00E401
    COP [BranchIfSolidOffset] ( #00, #01, &code_00E401 )
    COP [ClearLowHere]
    LDA $16
    CLC 
    ADC #$0010
    STA $16
    COP [SolidHighHere]
    COP [PlaySoundCh1] ( #2C )
    JSR $&code_00E490
    COP [LoopInit] ( #10 )
    LDY $04
    LDA $0016, Y
    INC 
    STA $0016, Y
    COP [LoopNext]
    JSR $&code_00E4A3
}

code_00E401 {
    COP [RestoreSavedPtr]
}

code_00E403 {
    COP [BranchOnPlayerY] ( #$000F, &code_00E359, &code_00E40D, &code_00E359 )
}

code_00E40D {
    LDY $decelStepCounter
    LDA $0014, Y
    SEC 
    SBC $14
    BPL loc_00E457
    BPL loc_00E41E
    EOR #$FFFF
    INC 

  loc_00E41E:
    CMP #$0020
    BCC code_00E455
    JSL $@chunk_3B7DD.code_03E58B
    CMP #$0003
    BNE code_00E455
    COP [BranchIfSolidOffset] ( #FF, #00, &code_00E455 )
    COP [ClearLowHere]
    LDA $14
    SEC 
    SBC #$0010
    STA $14
    COP [SolidHighHere]
    COP [PlaySoundCh1] ( #2C )
    JSR $&code_00E490
    COP [LoopInit] ( #10 )
    LDY $04
    LDA $0014, Y
    DEC 
    STA $0014, Y
    COP [LoopNext]
    JSR $&code_00E4A3
}

code_00E455 {
    COP [RestoreSavedPtr]

  loc_00E457:
    CMP #$0020
    BCC code_00E48E
    JSL $@chunk_3B7DD.code_03E58B
    CMP #$0002
    BNE code_00E48E
    COP [BranchIfSolidOffset] ( #01, #00, &code_00E48E )
    COP [ClearLowHere]
    LDA $14
    CLC 
    ADC #$0010
    STA $14
    COP [SolidHighHere]
    COP [PlaySoundCh1] ( #2C )
    JSR $&code_00E490
    COP [LoopInit] ( #10 )
    LDY $04
    LDA $0014, Y
    INC 
    STA $0014, Y
    COP [LoopNext]
    JSR $&code_00E4A3
}

code_00E48E {
    COP [RestoreSavedPtr]
}

code_00E490 {
    LDY $04
    LDA $0012, Y
    PHA 
    ORA #$0010
    STA $0012, Y
    PLA 
    AND #$0010
    STA $24
    RTS 
}

code_00E4A3 {
    LDY $04
    LDA $0012, Y
    AND #$FFEF
    ORA $24
    STA $0012, Y
    RTS 
}

code_00E4B1 {
    COP [SetSavedPtr] ( &code_00E4B1 )
    COP [SetEntryExit]
    COP [BranchIfButton] ( #$0031, &code_00E4CA )
    LDY $04
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    STA $16

  code_00E4C9:
    RTL 
}

code_00E4CA {
    COP [BranchIfPlayerNear] ( #0F, &code_00E4D0 )
    RTL 
}

code_00E4D0 {
    COP [BranchOnPlayerX] ( #$000F, &code_00E551, &code_00E4DA, &code_00E551 )
}

code_00E4DA {
    LDY $decelStepCounter
    LDA $0016, Y
    SEC 
    SBC $16
    BPL loc_00E51E
    BPL loc_00E4EB
    EOR #$FFFF
    INC 

  loc_00E4EB:
    CMP #$0020
    BCC code_00E51C
    LDA $0028, Y
    CMP #$003A
    BNE code_00E51C
    JSL $@chunk_3B7DD.code_03E58B
    CMP #$0000
    BNE code_00E51C
    COP [BranchIfSolidOffset] ( #00, #FF, &code_00E51C )
    COP [AddPosition] ( #00, #F0 )
    COP [PlaySoundCh1] ( #2C )
    COP [LoopInit] ( #10 )
    LDY $04
    LDA $0016, Y
    DEC 
    STA $0016, Y
    COP [LoopNext]
}

code_00E51C {
    COP [RestoreSavedPtr]

  loc_00E51E:
    CMP #$0020
    BCC code_00E54F
    LDA $0028, Y
    CMP #$003B
    BNE code_00E54F
    JSL $@chunk_3B7DD.code_03E58B
    CMP #$0001
    BNE code_00E54F
    COP [BranchIfSolidOffset] ( #00, #01, &code_00E54F )
    COP [AddPosition] ( #00, #10 )
    COP [PlaySoundCh1] ( #2C )
    COP [LoopInit] ( #10 )
    LDY $04
    LDA $0016, Y
    INC 
    STA $0016, Y
    COP [LoopNext]
}

code_00E54F {
    COP [RestoreSavedPtr]
}

code_00E551 {
    COP [BranchOnPlayerY] ( #$000F, &code_00E4C9, &code_00E55B, &code_00E4C9 )
}

code_00E55B {
    LDY $decelStepCounter
    LDA $0014, Y
    SEC 
    SBC $14
    BPL loc_00E59F
    BPL loc_00E56C
    EOR #$FFFF
    INC 

  loc_00E56C:
    CMP #$0020
    BCC code_00E59D
    LDA $0028, Y
    CMP #$003D
    BNE code_00E59D
    JSL $@chunk_3B7DD.code_03E58B
    CMP #$0003
    BNE code_00E59D
    COP [BranchIfSolidOffset] ( #FF, #00, &code_00E59D )
    COP [AddPosition] ( #F0, #00 )
    COP [PlaySoundCh1] ( #2C )
    COP [LoopInit] ( #10 )
    LDY $04
    LDA $0014, Y
    DEC 
    STA $0014, Y
    COP [LoopNext]
}

code_00E59D {
    COP [RestoreSavedPtr]

  loc_00E59F:
    CMP #$0020
    BCC code_00E5D0
    LDA $0028, Y
    CMP #$003C
    BNE code_00E5D0
    JSL $@chunk_3B7DD.code_03E58B
    CMP #$0002
    BNE code_00E5D0
    COP [BranchIfSolidOffset] ( #01, #00, &code_00E5D0 )
    COP [AddPosition] ( #10, #00 )
    COP [PlaySoundCh1] ( #2C )
    COP [LoopInit] ( #10 )
    LDY $04
    LDA $0014, Y
    INC 
    STA $0014, Y
    COP [LoopNext]
}

code_00E5D0 {
    COP [RestoreSavedPtr]

  loc_00E5D2:
    STZ $002A, X
    COP [SpawnMarkedAfter] ( @code_00E5F3, #$2000 )
    CPY #$1FC0
    BEQ loc_00E5F1
    LDA $24
    STA $0024, Y

  loc_00E5E6:
    COP [SetEntryContinue]
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_00E5E6

  loc_00E5F1:
    COP [Die]
}

code_00E5F3 {
    TXY 
    LDX $0004, Y
    LDA $loopCounter, X
    TYX 
    STA $loopCounter, X
    LDY $24
    LDA $0014, Y
    SEC 
    SBC $14
    BMI loc_00E634
    STA $0018
    LDA $0016, Y
    SEC 
    SBC #$0008
    SEC 
    SBC $16
    BMI loc_00E626
    STA $001C
    CMP $0018
    BCC loc_00E624
    JMP $&code_00E6B8

  loc_00E624:
    BRA loc_00E69D

  loc_00E626:
    EOR #$FFFF
    INC 
    STA $001C
    CMP $0018
    BCS loc_00E667
    BRA loc_00E682

  loc_00E634:
    EOR #$FFFF
    INC 
    STA $0018
    LDA $0016, Y
    SEC 
    SBC #$0008
    SEC 
    SBC $16
    BMI loc_00E655
    STA $001C
    CMP $0018
    BCC loc_00E652
    JMP $&code_00E6D3

  loc_00E652:
    JMP $&code_00E6ED

  loc_00E655:
    EOR #$FFFF
    INC 
    STA $001C
    CMP $0018
    BCC loc_00E664
    JMP $&code_00E721

  loc_00E664:
    JMP $&code_00E707

  loc_00E667:
    JSR $&code_00EE9C
    COP [SetEntryContinue]
    JSR $&code_00EF10
    LDA $16
    SEC 
    SBC $0000
    STA $16
    LDA $14
    CLC 
    ADC $0002
    STA $14
    JMP $&code_00E73B

  loc_00E682:
    JSR $&code_00EEB7
    COP [SetEntryContinue]
    JSR $&code_00EF10
    LDA $14
    CLC 
    ADC $0000
    STA $14
    LDA $16
    SEC 
    SBC $0002
    STA $16
    JMP $&code_00E73B

  loc_00E69D:
    JSR $&code_00EEB7
    COP [SetEntryContinue]
    JSR $&code_00EF10
    LDA $14
    CLC 
    ADC $0000
    STA $14
    LDA $16
    CLC 
    ADC $0002
    STA $16
    JMP $&code_00E73B
}

code_00E6B8 {
    JSR $&code_00EE9C
    COP [SetEntryContinue]
    JSR $&code_00EF10
    LDA $16
    CLC 
    ADC $0000
    STA $16
    LDA $14
    CLC 
    ADC $0002
    STA $14
    JMP $&code_00E73B
}

code_00E6D3 {
    JSR $&code_00EE9C
    COP [SetEntryContinue]
    JSR $&code_00EF10
    LDA $16
    CLC 
    ADC $0000
    STA $16
    LDA $14
    SEC 
    SBC $0002
    STA $14
    BRA code_00E73B
}

code_00E6ED {
    JSR $&code_00EEB7
    COP [SetEntryContinue]
    JSR $&code_00EF10
    LDA $14
    SEC 
    SBC $0000
    STA $14
    LDA $16
    CLC 
    ADC $0002
    STA $16
    BRA code_00E73B
}

code_00E707 {
    JSR $&code_00EEB7
    COP [SetEntryContinue]
    JSR $&code_00EF10
    LDA $14
    SEC 
    SBC $0000
    STA $14
    LDA $16
    SEC 
    SBC $0002
    STA $16
    BRA code_00E73B
}

code_00E721 {
    JSR $&code_00EE9C
    COP [SetEntryContinue]
    JSR $&code_00EF10
    LDA $16
    SEC 
    SBC $0000
    STA $16
    LDA $14
    SEC 
    SBC $0002
    STA $14
    BRA code_00E73B
}

code_00E73B {
    LDA $0004, X
    TAY 
    LDA $0014, X
    STA $0014, Y
    LDA $0016, X
    STA $0016, Y
    RTL 
}

code_00E74C {
    COP [SpawnMarkedAfter] ( @code_00E79D, #$2000 )
    CPY #$1FC0
    BEQ loc_00E778
    LDA $24
    STA $0024, Y
    COP [SetEntryContinue]
    COP [AnimOnce]
    LDA $animScratch2, X
    DEC 
    STA $animScratch2, X
    BEQ loc_00E76D
    RTL 

  loc_00E76D:
    COP [SetEntryContinue]
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_00E76D

  loc_00E778:
    COP [Die]

  code_00E77A:
    TXY 
    LDX $0004, Y
    LDA $loopCounter, X
    STA $0000
    LDA $chatPtr, X
    STA $0002
    TYX 
    LDA $0000
    STA $loopCounter, X
    LDA $0002
    STA $chatPtr, X
    BRA code_00E7C5
}

code_00E79D {
    TXY 
    LDX $0004, Y
    LDA $loopCounter, X
    STA $0000
    LDA $chatPtr, X
    STA $0002
    TYX 
    LDA $0000
    STA $loopCounter, X
    LDA $0002
    STA $chatPtr, X
    LDA #$FFFF
    STA $animScratch2, X

  code_00E7C5:
    LDY $24
    LDA $0014, Y
    SEC 
    SBC $14
    BMI loc_00E7FA
    STA $0018
    LDA $0016, Y
    SEC 
    SBC #$0008
    SEC 
    SBC $16
    BMI loc_00E7EC
    STA $001C
    CMP $0018
    BCC loc_00E7E9
    JMP $&code_00E89C

  loc_00E7E9:
    JMP $&code_00E880

  loc_00E7EC:
    EOR #$FFFF
    INC 
    STA $001C
    CMP $0018
    BCS loc_00E82D
    BRA loc_00E85A

  loc_00E7FA:
    EOR #$FFFF
    INC 
    STA $0018
    LDA $0016, Y
    SEC 
    SBC #$0008
    SEC 
    SBC $16
    BMI loc_00E81B
    STA $001C
    CMP $0018
    BCC loc_00E818
    JMP $&code_00E8C5

  loc_00E818:
    JMP $&code_00E8F2

  loc_00E81B:
    EOR #$FFFF
    INC 
    STA $001C
    CMP $0018
    BCC loc_00E82A
    JMP $&code_00E947

  loc_00E82A:
    JMP $&code_00E918

  loc_00E82D:
    JSR $&code_00EE9C
    LDA #$0000
    STA $0000
    JSR $&code_00EF70
    LDA $0000
    BMI code_00E841
    JMP $&code_00E9B1

  code_00E841:
    COP [SetEntryContinue]
    JSR $&code_00EF10
    LDA $0000
    EOR #$FFFF
    INC 
    TAY 
    LDA $0002
    STA $0000
    STY $0002
    JMP $&code_00E975

  loc_00E85A:
    JSR $&code_00EEB7
    LDA #$0002
    STA $0000
    JSR $&code_00EF80
    LDA $0000
    BMI code_00E86E
    JMP $&code_00E9B1

  code_00E86E:
    COP [SetEntryContinue]
    JSR $&code_00EF10
    LDA $0002
    EOR #$FFFF
    INC 
    STA $0002
    JMP $&code_00E975
}

code_00E880 {
    JSR $&code_00EEB7
    LDA #$0004
    STA $0000
    JSR $&code_00EF70
    LDA $0000
    BMI code_00E894
    JMP $&code_00E9B1

  code_00E894:
    COP [SetEntryContinue]
    JSR $&code_00EF10
    JMP $&code_00E975
}

code_00E89C {
    JSR $&code_00EE9C
    LDA #$0006
    STA $0000
    JSR $&code_00EF80
    LDA $0000
    BMI code_00E8B0
    JMP $&code_00E9B1

  code_00E8B0:
    COP [SetEntryContinue]
    JSR $&code_00EF10
    LDA $0000
    TAY 
    LDA $0002
    STA $0000
    STY $0002
    JMP $&code_00E975
}

code_00E8C5 {
    JSR $&code_00EE9C
    LDA #$0008
    STA $0000
    JSR $&code_00EF70
    LDA $0000
    BMI code_00E8D9
    JMP $&code_00E9B1

  code_00E8D9:
    COP [SetEntryContinue]
    JSR $&code_00EF10
    LDA $0002
    EOR #$FFFF
    INC 
    TAY 
    LDA $0000
    STA $0002
    STY $0000
    JMP $&code_00E975
}

code_00E8F2 {
    JSR $&code_00EEB7
    LDA #$000A
    STA $0000
    JSR $&code_00EF80
    LDA $0000
    BMI code_00E906
    JMP $&code_00E9B1

  code_00E906:
    COP [SetEntryContinue]
    JSR $&code_00EF10
    LDA $0000
    EOR #$FFFF
    INC 
    STA $0000
    JMP $&code_00E975
}

code_00E918 {
    JSR $&code_00EEB7
    LDA #$000C
    STA $0000
    JSR $&code_00EF70
    LDA $0000
    BMI code_00E92C
    JMP $&code_00E9B1

  code_00E92C:
    COP [SetEntryContinue]
    JSR $&code_00EF10
    LDA $0000
    EOR #$FFFF
    INC 
    STA $0000
    LDA $0002
    EOR #$FFFF
    INC 
    STA $0002
    BRA code_00E975
}

code_00E947 {
    JSR $&code_00EE9C
    LDA #$000E
    STA $0000
    JSR $&code_00EF80
    LDA $0000
    BMI code_00E95B
    JMP $&code_00E9B1

  code_00E95B:
    COP [SetEntryContinue]
    JSR $&code_00EF10
    LDA $0000
    EOR #$FFFF
    INC 
    TAY 
    LDA $0002
    EOR #$FFFF
    INC 
    STA $0000
    STY $0002
}

code_00E975 {
    LDY $04
    LDA $14
    CLC 
    ADC $0000
    STA $14
    STA $0014, Y
    LDA $0000
    STA $moveScratch1, X
    LDA $16
    CLC 
    ADC $0002
    STA $16
    STA $0016, Y
    LDA $0002
    STA $moveScratch2, X
    LDA $orbitDiameter, X
    CMP #$0008
    BPL loc_00E9A5
    RTL 

  loc_00E9A5:
    LDA #$0000
    STA $orbitDiameter, X
    COP [SetEntryExitNow] ( @code_00E7C5 )
}

code_00E9B1 {
    DEC 
    AND #$0007
    STA $0004
    COP [SwitchCase] ( #$0004, &code_list_00E9BE )
}

code_list_00E9BE [
  &code_00E841   ;00
  &code_00E86E   ;01
  &code_00E894   ;02
  &code_00E8B0   ;03
  &code_00E8D9   ;04
  &code_00E906   ;05
  &code_00E92C   ;06
  &code_00E95B   ;07
]

actor_def_00E9CE [
  actor-def < #00, #00, #2C, {

  code_00E9D1:
    LDA #$1000
    TSB $12
    LDA $14
    LSR 
    LSR 
    LSR 
    LSR 
    BIT #$0080
    BEQ loc_00E9E8
    AND #$FF7F
    EOR #$FFFF
    INC 

  loc_00E9E8:
    STA $2C
    LDA $16
    LSR 
    LSR 
    LSR 
    LSR 
    DEC 
    BIT #$0080
    BEQ loc_00E9FD
    AND #$FF7F
    EOR #$FFFF
    INC 

  loc_00E9FD:
    STA $2E
    LDA #$0000
    STA $14
    STA $bg1ScrollV
    STA $cameraDeltaX
    STA $16
    STA $savedCameraDelta
    STA $cameraDeltaY
    COP [WaitByte] ( #01 )
    LDA $14
    CLC 
    ADC $2C
    CLC 
    ADC $effectDeltaX
    STA $14
    ORA #$8000
    STA $forcedScrollOverride
    LDA $16
    CLC 
    ADC $2E
    CLC 
    ADC $effectDeltaY
    STA $16
    STA $cameraDeltaY
    LDA $2C
    STA $06E8
    LDA $cameraDeltaY
    SEC 
    SBC $savedCameraDelta
    STA $06EA
    RTL 
} >
]

actor_def_00EA44 [
  actor-def < #00, #00, #2C, {

  code_00EA47:
    LDA #$1000
    TSB $12
    LDA $14
    SEC 
    SBC #$0008
    JSR $&code_00EDE2
    STA $14
    LDA $16
    SEC 
    SBC #$0010
    JSR $&code_00EDE2
    STA $16
    COP [LoopInit] ( #03 )
    JSR $&code_00EE02
    LDA $cameraDeltaY
    STA $savedCameraDelta
    COP [LoopNext]
    COP [SetEntryContinue]
    JSR $&code_00EE02
    LDA $cameraDeltaX
    ORA #$8000
    STA $forcedScrollOverride
    STZ $cameraDeltaX
    RTL 
} >
]

code_00EA82 {
    COP [SetEntryContinue]
    PEA $&code_00EAC1-1
    LDA $14
    BIT #$8000
    BNE loc_00EA9E
    BIT #$FF00
    BEQ loc_00EAB1
    LDY $cameraTargetX
    JSL $@chunk_028000.code_028125
    STA $forcedScrollOverride
    RTS 

  loc_00EA9E:
    AND #$00FF
    BIT #$0080
    BEQ loc_00EAA9
    ORA #$FF00

  loc_00EAA9:
    CLC 
    ADC $forcedScrollOverride
    STA $forcedScrollOverride
    RTS 

  loc_00EAB1:
    BIT #$0080
    BEQ loc_00EAB9
    ORA #$FF00

  loc_00EAB9:
    CLC 
    ADC $forcedScrollOverride
    STA $forcedScrollOverride
    RTS 
}

code_00EAC1 {
    LDA $16
    BIT #$FF00
    BEQ loc_00EAD3
    LDY $cameraTargetY
    JSL $@chunk_028000.code_028125
    STA $cameraDeltaY
    RTL 

  loc_00EAD3:
    BIT #$0080
    BEQ loc_00EADB
    ORA #$FF00

  loc_00EADB:
    CLC 
    ADC $cameraDeltaY
    STA $cameraDeltaY
    RTL 
}

actor_def_00EAE3 [
  actor-def < #00, #00, #2C, {

  code_00EAE6:
    LDA #$1000
    TSB $12
    LDA $14
    LSR 
    LSR 
    LSR 
    LSR 
    BIT #$0080
    BEQ loc_00EAFD
    AND #$FF7F
    EOR #$FFFF
    INC 

  loc_00EAFD:
    STA $2C
    LDA $16
    LSR 
    LSR 
    LSR 
    LSR 
    DEC 
    BIT #$0080
    BEQ loc_00EB12
    AND #$FF7F
    EOR #$FFFF
    INC 

  loc_00EB12:
    STA $2E
    LDA #$0000
    STA $14
    STA $16
    COP [SetEntryContinue]
    LDA $14
    CLC 
    ADC $2C
    CLC 
    ADC $effectDeltaX
    STA $14
    STA $cameraDeltaX
    BPL loc_00EB3A
    LDA $effectBoundsX
    STA $cameraDeltaX
    STA $bg1ScrollV
    STA $14
    BRA loc_00EB4A

  loc_00EB3A:
    CMP $effectBoundsX
    BCC loc_00EB4A
    LDA #$0000
    STA $cameraDeltaX
    STA $14
    STA $bg1ScrollV

  loc_00EB4A:
    LDA $16
    CLC 
    ADC $2E
    CLC 
    ADC $effectDeltaY
    STA $16
    STA $cameraDeltaY
    BPL loc_00EB68
    LDA $effectBoundsY
    DEC 
    STA $cameraDeltaY
    STA $savedCameraDelta
    STA $16
    BRA loc_00EB78

  loc_00EB68:
    CMP $effectBoundsY
    BCC loc_00EB78
    LDA #$0000
    STA $cameraDeltaY
    STA $16
    STA $savedCameraDelta

  loc_00EB78:
    LDA $cameraDeltaX
    SEC 
    SBC $bg1ScrollV
    STA $06E8
    LDA $cameraDeltaY
    SEC 
    SBC $savedCameraDelta
    STA $06EA
    RTL 
} >
]

actor_def_00EB8D [
  actor-def < #00, #00, #2C, {

  code_00EB90:
    LDA #$1000
    TSB $12
    JSR $&code_00EDEF
    COP [SetEntryContinue]
    JSR $&code_00EE02
    RTL 
} >
]

actor_def_00EB9E [
  actor-def < #00, #00, #2C, {

  code_00EBA1:
    LDA #$1000
    TSB $12
    JSR $&code_00EDEF
    COP [SetEntryContinue]
    LDA $16
    BEQ loc_00EBB9
    LDY $cameraTargetY
    JSL $@chunk_028000.code_028125
    STA $cameraDeltaY

  loc_00EBB9:
    RTL 
} >
]

actor_def_00EBBA [
  actor-def < #00, #00, #24, {

  code_00EBBD:
    LDA #$1000
    TSB $12
    LDA #$0000
    STA $24
    STA $26
    JSR $&code_00EDEF
    COP [SetEntryContinue]
    JSR $&code_00EE02
    LDA $cameraDeltaX
    CLC 
    ADC $24
    STA $cameraDeltaX
    LDA $cameraDeltaY
    CLC 
    ADC $26
    STA $cameraDeltaY
    RTL 
} >
]

actor_def_00EBE4 [
  actor-def < #00, #00, #2C, {

  code_00EBE7:
    LDA #$1000
    TSB $12
    COP [SetEntryContinue]
    LDA $layerPriorityFlag
    BIT #$0200
    BEQ loc_00EBF7
    RTL 

  loc_00EBF7:
    PHD 
    LDA $09FE
    TCD 
    LDA $14
    SEC 
    SBC #$0008
    STA $playerWallType
    LSR 
    LSR 
    LSR 
    LSR 
    STA $playerSpeedNs
    LDA $16
    SEC 
    SBC #$0010
    STA $playerSpeedEw
    LSR 
    LSR 
    LSR 
    LSR 
    STA $slopeStepCounter
    LDA $slopeCurvePtrB
    BIT #$0100
    BNE loc_00EC7C
    LDA $14
    SEC 
    SBC #$0080
    BMI loc_00EC44
    CMP $cameraOffsetX
    BMI loc_00EC44
    CLC 
    ADC #$0100
    CMP $cameraBoundsX
    BMI loc_00EC49
    LDA $cameraBoundsX
    BRA loc_00EC49

  loc_00EC3F:
    LDA $cameraBoundsX
    BRA loc_00EC49

  loc_00EC44:
    LDA $cameraOffsetX
    BRA loc_00EC4D

  loc_00EC49:
    SEC 
    SBC #$0100

  loc_00EC4D:
    STA $cameraTargetX
    LDA $16
    SEC 
    SBC #$0080
    BMI loc_00EC70
    CMP $cameraOffsetY
    BMI loc_00EC70
    CLC 
    ADC #$0100
    CMP $cameraBoundsY
    BMI loc_00EC75
    LDA $cameraBoundsY
    BRA loc_00EC75

  loc_00EC6B:
    LDA $cameraBoundsY
    BRA loc_00EC75

  loc_00EC70:
    LDA $cameraOffsetY
    BRA loc_00EC79

  loc_00EC75:
    SEC 
    SBC #$0100

  loc_00EC79:
    STA $cameraTargetY

  loc_00EC7C:
    LDA $cameraTargetX
    SEC 
    SBC $bg1ScrollH
    STA $effectDeltaX
    LDA $cameraTargetY
    SEC 
    SBC $bg2ScrollH
    STA $effectDeltaY
    PLD 
    RTL 
} >
]

code_00EC92 {
    LDA #$6000
    TRB $12
    COP [SetEntryContinue]
    LDA #$FFFF
    TSB $joypadMaskStd
    STZ $joypadCurrent
    JSR $&code_00EE1F
    LDA #$2008
    TRB $10
    COP [StagePlayerSpriteFromBank]
    COP [AnimPlayerOnce]
    LDA #$2000
    TSB $10
    STZ $scrollStepIndex
    LDA $scrollStepTableBase
    AND #$00FF
    ASL 
    TAX 
    LDA $&table_01A946, X
    STA $scrollStepTableBase
    STZ $2A
    TDC 
    TAX 
    COP [SetEntryContinue]
    COP [PanCameraDown]
    JSR $&code_00EE5F
    LDA #$2008
    TRB $10
    JSR $&code_00EE1F
    COP [StagePlayerSpriteFromBank]
    COP [AnimPlayerOnce]
    JSR $&code_00EE7B
    LDA #$FFFF
    TRB $joypadMaskStd
    COP [Die]

  code_00ECE6:
    LDA #$6000
    TRB $12
    COP [SetEntryContinue]
    LDA #$FFFF
    TSB $joypadMaskStd
    STZ $joypadCurrent
    JSR $&code_00EE1F
    LDA #$2008
    TRB $10
    COP [StagePlayerSpriteFromBank]
    COP [AnimPlayerOnce]
    LDA #$2000
    TSB $10
    STZ $scrollStepIndex
    LDA $scrollStepTableBase
    AND #$00FF
    ASL 
    TAX 
    LDA $&table_01A946, X
    STA $scrollStepTableBase
    STZ $2A
    TDC 
    TAX 
    COP [SetEntryContinue]
    COP [PanCameraUp]
    JSR $&code_00EE5F
    LDA #$2008
    TRB $10
    JSR $&code_00EE1F
    COP [StagePlayerSpriteFromBank]
    COP [AnimPlayerOnce]
    JSR $&code_00EE7B
    LDA #$FFFF
    TRB $joypadMaskStd
    COP [Die]

  code_00ED3A:
    LDA #$6000
    TRB $12
    COP [SetEntryContinue]
    LDA #$FFFF
    TSB $joypadMaskStd
    STZ $joypadCurrent
    JSR $&code_00EE3F
    LDA #$2008
    TRB $10
    COP [StagePlayerSpriteFromBank]
    COP [AnimPlayerOnce]
    LDA #$2000
    TSB $10
    STZ $scrollStepIndex
    LDA $scrollStepTableBase
    AND #$00FF
    ASL 
    TAX 
    LDA $&table_01A946, X
    STA $scrollStepTableBase
    STZ $2A
    TDC 
    TAX 
    COP [SetEntryContinue]
    COP [PanCameraLeft]
    JSR $&code_00EE5F
    LDA #$2008
    TRB $10
    JSR $&code_00EE3F
    COP [StagePlayerSpriteFromBank]
    COP [AnimPlayerOnce]
    JSR $&code_00EE7B
    LDA #$FFFF
    TRB $joypadMaskStd
    COP [Die]

  code_00ED8E:
    LDA #$6000
    TRB $12
    COP [SetEntryContinue]
    LDA #$FFFF
    TSB $joypadMaskStd
    STZ $joypadCurrent
    JSR $&code_00EE3F
    LDA #$2008
    TRB $10
    COP [StagePlayerSpriteFromBank]
    COP [AnimPlayerOnce]
    LDA #$2000
    TSB $10
    STZ $scrollStepIndex
    LDA $scrollStepTableBase
    AND #$00FF
    ASL 
    TAX 
    LDA $&table_01A946, X
    STA $scrollStepTableBase
    STZ $2A
    TDC 
    TAX 
    COP [SetEntryContinue]
    COP [PanCameraRight]
    JSR $&code_00EE5F
    LDA #$2008
    TRB $10
    JSR $&code_00EE3F
    COP [StagePlayerSpriteFromBank]
    COP [AnimPlayerOnce]
    JSR $&code_00EE7B
    LDA #$FFFF
    TRB $joypadMaskStd
    COP [Die]
}

code_00EDE2 {
    SEP #$20
    LSR 
    LSR 
    LSR 
    LSR 
    REP #$20
    AND #$0F0F
    TAY 
    RTS 
}

code_00EDEF {
    LDA $14
    SEC 
    SBC #$0008
    JSR $&code_00EDE2
    STY $14
    LDA $16
    JSR $&code_00EDE2
    STY $16
    RTS 
}

code_00EE02 {
    LDA $14
    BEQ loc_00EE10
    LDY $cameraTargetX
    JSL $@chunk_028000.code_028125
    STA $cameraDeltaX

  loc_00EE10:
    LDA $16
    BEQ loc_00EE1E
    LDY $cameraTargetY
    JSL $@chunk_028000.code_028125
    STA $cameraDeltaY

  loc_00EE1E:
    RTS 
}

code_00EE1F {
    LDY $0650
    INC $0650
    LDA $0000, Y
    AND #$00FF
    ASL 
    TAY 
    LDA $&dir_sprite_table, Y
    STA $0000
    XBA 
    AND #$00FF
    ASL 
    TAY 
    LDA $&table_01B06E, Y
    STA $2E
    RTS 
}

code_00EE3F {
    LDY $0650
    INC $0650
    LDA $0000, Y
    AND #$00FF
    ASL 
    TAY 
    LDA $&dir_sprite_table, Y
    STA $0000
    XBA 
    AND #$00FF
    ASL 
    TAY 
    LDA $&table_01B06E, Y
    STA $2C
    RTS 
}

code_00EE5F {
    LDA $0650
    TAY 
    CLC 
    ADC #$0004
    STA $0650
    LDA $0000, Y
    CLC 
    ADC $14
    STA $14
    LDA $0002, Y
    CLC 
    ADC $16
    STA $16
    RTS 
}

code_00EE7B {
    LDY $decelStepCounter
    LDA $14
    STA $0014, Y
    LDA $16
    STA $0016, Y
    LDA $10
    ORA #$0008
    STA $0010, Y
    LDA $28
    STA $0028, Y
    LDA #$0000
    STA $0008, Y
    RTS 
}

code_00EE9C {
    LDA $0018
    CMP $001C
    BNE loc_00EEA9
    LDA #$0000
    BRA loc_00EF04

  loc_00EEA9:
    LDY $0018
    LDA $001C
    LSR 
    LSR 
    LSR 
    LSR 
    BNE loc_00EED1
    BRA loc_00EED0
}

code_00EEB7 {
    LDA $001C
    CMP $0018
    BNE loc_00EEC4
    LDA #$0000
    BRA loc_00EF04

  loc_00EEC4:
    LDY $001C
    LDA $0018
    LSR 
    LSR 
    LSR 
    LSR 
    BNE loc_00EED1

  loc_00EED0:
    INC 

  loc_00EED1:
    SEP #$20
    JSL $@chunk_028000.code_02830D
    REP #$20
    AND #$00FF
    CMP #$0018
    BPL loc_00EEE8
    CMP #$0011
    BPL loc_00EEF6
    BRA loc_00EEFC

  loc_00EEE8:
    SEC 
    SBC #$0010
    EOR #$FFFF
    INC 
    CLC 
    ADC #$0010
    BRA loc_00EF04

  loc_00EEF6:
    SEC 
    SBC #$0010
    BRA loc_00EF04

  loc_00EEFC:
    EOR #$FFFF
    INC 
    CLC 
    ADC #$0010

  loc_00EF04:
    STA $orbitAngle, X
    LDA #$0000
    STA $orbitDiameter, X
    RTS 
}

code_00EF10 {
    LDA $orbitAngle, X
    ASL 
    ASL 
    ASL 
    ASL 
    ASL 
    TAY 
    LDA $orbitDiameter, X
    STA $0004
    ASL 
    STA $0006
    TYA 
    CLC 
    ADC $0006
    TAY 
    LDA $loopCounter, X
    STA $0000
    CLC 
    ADC $0004
    AND #$000F
    STA $0008
    STA $orbitDiameter, X
    PHX 
    TYX 
    STZ $0002

  loc_00EF45:
    LDA $@code_00F287, X
    CLC 
    ADC $0002
    STA $0002
    INX 
    INX 
    INC $0004
    LDA $0004
    BIT #$FFF0
    BEQ loc_00EF69
    TXA 
    SEC 
    SBC #$0020
    TAX 
    LDA #$0000
    STA $0004

  loc_00EF69:
    CMP $0008
    BNE loc_00EF45
    PLX 
    RTS 
}

code_00EF70 {
    LDA $orbitAngle, X
    CMP #$000D
    BPL loc_00EF8E
    CMP #$0005
    BPL loc_00EF96
    BRA loc_00EF9E
}

code_00EF80 {
    LDA $orbitAngle, X
    CMP #$000D
    BPL loc_00EF9E
    CMP #$0005
    BPL loc_00EF96

  loc_00EF8E:
    LDA #$0000
    STA $0002
    BRA loc_00EFA4

  loc_00EF96:
    LDA #$0001
    STA $0002
    BRA loc_00EFA4

  loc_00EF9E:
    LDA #$0002
    STA $0002

  loc_00EFA4:
    LDA $0000
    CLC 
    ADC $0002
    AND #$000F
    STA $0004
    LDA $chatPtr, X
    LDA $animScratch2, X
    BMI loc_00F010
    SEC 
    SBC $0004
    BMI loc_00EFD4
    BEQ loc_00F010
    CMP #$0001
    BEQ loc_00F010
    CMP #$000F
    BEQ loc_00F010
    CMP #$0009
    BPL loc_00EFFF
    BRA loc_00EFE5

  loc_00EFD4:
    CMP #$FFFF
    BEQ loc_00F010
    CMP #$FFF1
    BEQ loc_00F010
    CMP #$FFF9
    BPL loc_00EFFF
    BRA loc_00EFE5

  loc_00EFE5:
    LDA $animScratch2, X
    DEC 
    STA $animScratch2, X
    STA $0004
    BPL loc_00F01D
    LDA #$000F
    STA $animScratch2, X
    STA $0004
    BRA loc_00F01D

  loc_00EFFF:
    LDA $animScratch2, X
    INC 
    AND #$000F
    STA $animScratch2, X
    STA $0004
    BRA loc_00F01D

  loc_00F010:
    LDA $0004
    STA $animScratch2, X
    LDA #$FFFF
    STA $0000

  loc_00F01D:
    LDA $0004, X
    TAY 
    LDA $chatPtr, X
    BMI loc_00F034
    CLC 
    ADC $0004
    STA $0028, Y
    LDA #$0000
    STA $002A, Y

  loc_00F034:
    LDA $chatPtr, X
    BMI loc_00F046
    PHX 
    TYX 
    TYA 
    TCD 
    JSL $@chunk_3B7DD.code_03C761
    PLA 
    TXY 
    TAX 
    TCD 

  loc_00F046:
    LDA $chatPtr, X
    STA $0006
    LDA $animScratch2, X
    AND #$000F
    PHX 
    ASL 
    TAX 
    CLC 
    LDA $0006
    BPL loc_00F05E
    SEC 

  loc_00F05E:
    LDA $@code_00F066, X
    DEC 
    PLX 
    PHA 
    RTS 
}

code_00F066 {
    STX $F0
    LDY $F0
    REP #$F0
    CPX #$FEF0
    BEQ loc_00F08D
    SBC ($3D), Y
    SBC ($5E), Y
    SBC ($7F), Y
    SBC ($A0), Y
    SBC ($C1), Y
    SBC ($E2), Y
    SBC ($03), Y
    SBC ($24)
    SBC ($45)
    SBC ($66)
    SBC ($B0)
    ORA #$0EB9
    BRK #$29
    SBC $@0E993F, X
    BRK #$AD
    BRK #$00
    BMI loc_00F0A3
    LDA #$0001
    STA $0000
    LDA #$0010
    STA $orbitAngle, X

  loc_00F0A3:
    RTS 
}

code_00F0A4 {
    BCS loc_00F0AF
    LDA $000E, Y
    AND #$3FFF
    STA $000E, Y

  loc_00F0AF:
    LDA $0000
    BMI loc_00F0C1
    LDA #$0001
    STA $0000
    LDA #$0008
    STA $orbitAngle, X

  loc_00F0C1:
    RTS 
}

code_00F0C2 {
    BCS loc_00F0CD
    LDA $000E, Y
    AND #$3FFF
    STA $000E, Y

  loc_00F0CD:
    LDA $0000
    BMI loc_00F0DF
    LDA #$0002
    STA $0000
    LDA #$0000
    STA $orbitAngle, X

  loc_00F0DF:
    RTS 
}

code_00F0E0 {
    BCS loc_00F0EB
    LDA $000E, Y
    AND #$3FFF
    STA $000E, Y

  loc_00F0EB:
    LDA $0000
    BMI loc_00F0FD
    LDA #$0002
    STA $0000
    LDA #$0008
    STA $orbitAngle, X

  loc_00F0FD:
    RTS 
}

code_00F0FE {
    BCS loc_00F109
    LDA $000E, Y
    AND #$3FFF
    STA $000E, Y

  loc_00F109:
    LDA $0000
    BMI loc_00F11B
    LDA #$0003
    STA $0000
    LDA #$0010
    STA $orbitAngle, X

  loc_00F11B:
    RTS 
}

code_00F11C {
    BCS loc_00F12A
    LDA $000E, Y
    AND #$3FFF
    ORA #$8000
    STA $000E, Y

  loc_00F12A:
    LDA $0000
    BMI loc_00F13C
    LDA #$0003
    STA $0000
    LDA #$0008
    STA $orbitAngle, X

  loc_00F13C:
    RTS 
}

code_00F13D {
    BCS loc_00F14B
    LDA $000E, Y
    AND #$3FFF
    ORA #$8000
    STA $000E, Y

  loc_00F14B:
    LDA $0000
    BMI loc_00F15D
    LDA #$0004
    STA $0000
    LDA #$0000
    STA $orbitAngle, X

  loc_00F15D:
    RTS 
}

code_00F15E {
    BCS loc_00F16C
    LDA $000E, Y
    AND #$3FFF
    ORA #$8000
    STA $000E, Y

  loc_00F16C:
    LDA $0000
    BMI loc_00F17E
    LDA #$0004
    STA $0000
    LDA #$0008
    STA $orbitAngle, X

  loc_00F17E:
    RTS 
}

code_00F17F {
    BCS loc_00F18D
    LDA $000E, Y
    AND #$3FFF
    ORA #$8000
    STA $000E, Y

  loc_00F18D:
    LDA $0000
    BMI loc_00F19F
    LDA #$0005
    STA $0000
    LDA #$0010
    STA $orbitAngle, X

  loc_00F19F:
    RTS 
}

code_00F1A0 {
    BCS loc_00F1AE
    LDA $000E, Y
    AND #$3FFF
    ORA #$C000
    STA $000E, Y

  loc_00F1AE:
    LDA $0000
    BMI loc_00F1C0
    LDA #$0005
    STA $0000
    LDA #$0008
    STA $orbitAngle, X

  loc_00F1C0:
    RTS 
}

code_00F1C1 {
    BCS loc_00F1CF
    LDA $000E, Y
    AND #$3FFF
    ORA #$C000
    STA $000E, Y

  loc_00F1CF:
    LDA $0000
    BMI loc_00F1E1
    LDA #$0006
    STA $0000
    LDA #$0000
    STA $orbitAngle, X

  loc_00F1E1:
    RTS 
}

code_00F1E2 {
    BCS loc_00F1F0
    LDA $000E, Y
    AND #$3FFF
    ORA #$C000
    STA $000E, Y

  loc_00F1F0:
    LDA $0000
    BMI loc_00F202
    LDA #$0006
    STA $0000
    LDA #$0008
    STA $orbitAngle, X

  loc_00F202:
    RTS 
}

code_00F203 {
    BCS loc_00F211
    LDA $000E, Y
    AND #$3FFF
    ORA #$4000
    STA $000E, Y

  loc_00F211:
    LDA $0000
    BMI loc_00F223
    LDA #$0007
    STA $0000
    LDA #$0010
    STA $orbitAngle, X

  loc_00F223:
    RTS 
}

code_00F224 {
    BCS loc_00F232
    LDA $000E, Y
    AND #$3FFF
    ORA #$4000
    STA $000E, Y

  loc_00F232:
    LDA $0000
    BMI loc_00F244
    LDA #$0007
    STA $0000
    LDA #$0008
    STA $orbitAngle, X

  loc_00F244:
    RTS 
}

code_00F245 {
    BCS loc_00F253
    LDA $000E, Y
    AND #$3FFF
    ORA #$4000
    STA $000E, Y

  loc_00F253:
    LDA $0000
    BMI loc_00F265
    LDA #$0008
    STA $0000
    LDA #$0000
    STA $orbitAngle, X

  loc_00F265:
    RTS 
}

code_00F266 {
    BCS loc_00F274
    LDA $000E, Y
    AND #$3FFF
    ORA #$4000
    STA $000E, Y

  loc_00F274:
    LDA $0000
    BMI loc_00F286
    LDA #$0008
    STA $0000
    LDA #$0008
    STA $orbitAngle, X

  loc_00F286:
    RTS 
}

code_00F287 {
    ORA ($00, X)
    ORA ($00, X)
    ORA ($00, X)
    ORA ($00, X)
    ORA ($00, X)
    ORA ($00, X)
    ORA ($00, X)
    ORA ($00, X)
    ORA ($00, X)
    ORA ($00, X)
    ORA ($00, X)
    ORA ($00, X)
    ORA ($00, X)
    ORA ($00, X)
    ORA ($00, X)
    ORA ($00, X)
    ORA ($00, X)
    ORA ($00, X)
    ORA ($00, X)
    ORA ($00, X)
    ORA ($00, X)
    ORA ($00, X)
    ORA ($00, X)
    BRK #$00
    ORA ($00, X)
    ORA ($00, X)
    ORA ($00, X)
    ORA ($00, X)
    ORA ($00, X)
    ORA ($00, X)
    ORA ($00, X)
    ORA ($00, X)
    ORA ($00, X)
    ORA ($00, X)
    ORA ($00, X)
    ORA ($00, X)
    BRK #$00
    ORA ($00, X)
    ORA ($00, X)
    ORA ($00, X)
    ORA ($00, X)
    ORA ($00, X)
    ORA ($00, X)
    ORA ($00, X)
    BRK #$00
    ORA ($00, X)
    ORA ($00, X)
    ORA ($00, X)
    ORA ($00, X)
    ORA ($00, X)
    BRK #$00
    ORA ($00, X)
    ORA ($00, X)
    ORA ($00, X)
    ORA ($00, X)
    BRK #$00
    ORA ($00, X)
    ORA ($00, X)
    ORA ($00, X)
    ORA ($00, X)
    ORA ($00, X)
    BRK #$00
    ORA ($00, X)
    ORA ($00, X)
    ORA ($00, X)
    ORA ($00, X)
    BRK #$00
    ORA ($00, X)
    ORA ($00, X)
    ORA ($00, X)
    BRK #$00
    ORA ($00, X)
    ORA ($00, X)
    ORA ($00, X)
    BRK #$00
    ORA ($00, X)
    ORA ($00, X)
    ORA ($00, X)
    BRK #$00
    ORA ($00, X)
    ORA ($00, X)
    BRK #$00
    ORA ($00, X)
    ORA ($00, X)
    ORA ($00, X)
    BRK #$00
    ORA ($00, X)
    BRK #$00
    ORA ($00, X)
    ORA ($00, X)
    ORA ($00, X)
    BRK #$00
    ORA ($00, X)
    ORA ($00, X)
    BRK #$00
    ORA ($00, X)
    ORA ($00, X)
    BRK #$00
    ORA ($00, X)
    ORA ($00, X)
    BRK #$00
    ORA ($00, X)
    BRK #$00
    ORA ($00, X)
    ORA ($00, X)
    BRK #$00
    ORA ($00, X)
    ORA ($00, X)
    BRK #$00
    ORA ($00, X)
    BRK #$00
    ORA ($00, X)
    ORA ($00, X)
    BRK #$00
    ORA ($00, X)
    BRK #$00
    ORA ($00, X)
    BRK #$00
    ORA ($00, X)
    BRK #$00
    ORA ($00, X)
    ORA ($00, X)
    BRK #$00
    ORA ($00, X)
    BRK #$00
    ORA ($00, X)
    BRK #$00
    ORA ($00, X)
    BRK #$00
    ORA ($00, X)
    BRK #$00
    ORA ($00, X)
    BRK #$00
    ORA ($00, X)
    BRK #$00
    ORA ($00, X)
    BRK #$00
    ORA ($00, X)
    BRK #$00
    ORA ($00, X)
    BRK #$00
    ORA ($00, X)
    BRK #$00
    ORA ($00, X)
    BRK #$00
    ORA ($00, X)
    BRK #$00
    ORA ($00, X)
    BRK #$00
    ORA ($00, X)
    BRK #$00
    ORA ($00, X)
    BRK #$00
    BRK #$00
    ORA ($00, X)
    BRK #$00
    ORA ($00, X)
    BRK #$00
    ORA ($00, X)
    BRK #$00
    BRK #$00
    ORA ($00, X)
    BRK #$00
    BRK #$00
    ORA ($00, X)
    BRK #$00
    ORA ($00, X)
    BRK #$00
    BRK #$00
    ORA ($00, X)
    BRK #$00
    BRK #$00
    ORA ($00, X)
    BRK #$00
    ORA ($00, X)
    BRK #$00
    BRK #$00
    ORA ($00, X)
    BRK #$00
    BRK #$00
    BRK #$00
    ORA ($00, X)
    BRK #$00
    ORA ($00, X)
    BRK #$00
    BRK #$00
    BRK #$00
    ORA ($00, X)
    BRK #$00
    BRK #$00
    ORA ($00, X)
    BRK #$00
    BRK #$00
    BRK #$00
    ORA ($00, X)
    BRK #$00
    BRK #$00
    BRK #$00
    ORA ($00, X)
    BRK #$00
    BRK #$00
    BRK #$00
    ORA ($00, X)
    BRK #$00
    BRK #$00
    BRK #$00
    ORA ($00, X)
    BRK #$00
    BRK #$00
    BRK #$00
    ORA ($00, X)
    BRK #$00
    BRK #$00
    BRK #$00
    BRK #$00
    ORA ($00, X)
    BRK #$00
    BRK #$00
    BRK #$00
    BRK #$00
    BRK #$00
    ORA ($00, X)
    BRK #$00
    BRK #$00
    BRK #$00
    BRK #$00
    BRK #$00
    BRK #$00
    ORA ($00, X)
    BRK #$00
    BRK #$00
    BRK #$00
    BRK #$00
    BRK #$00
    BRK #$00
    BRK #$00
    ORA ($00, X)
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
    ORA ($00, X)
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

  code_00F4A7:
    LDA #$0000
    STA $09C0
    STA $decelCurvePtr
    STA $0008, Y
    LDA $0010, Y
    ORA #$0200
    STA $0010, Y
    RTL 
}

code_00F4BD {
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    STA $16

  code_00F4C7:
    LDA $orbitAngle, X
    AND #$00FF
    TAY 
    SEP #$20
    CLC 
    LDA $&binary_01C36C.binary_01C43D, Y
    BPL loc_00F4DB
    EOR #$FF
    INC 
    SEC 

  loc_00F4DB:
    XBA 
    LDA $orbitDiameter, X
    JSL $@chunk_028000.code_0282F6
    REP #$20
    XBA 
    AND #$00FF
    BCC loc_00F4F0
    EOR #$FFFF
    INC 

  loc_00F4F0:
    CLC 
    ADC $14
    STA $14
    SEP #$20
    CLC 
    LDA $&binary_01C36C.binary_01C47D, Y
    BPL loc_00F501
    EOR #$FF
    INC 
    SEC 

  loc_00F501:
    XBA 
    LDA $orbitDiameter, X
    JSL $@chunk_028000.code_0282F6
    REP #$20
    XBA 
    AND #$00FF
    BCC loc_00F516
    EOR #$FFFF
    INC 

  loc_00F516:
    CLC 
    ADC $16
    STA $16
    RTL 
}

code_00F51C {
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    STA $16

  code_00F526:
    LDA $orbitAngle, X
    AND #$00FF
    TAY 
    SEP #$20
    CLC 
    LDA $&binary_01C36C.binary_01C43D, Y
    BPL loc_00F53A
    EOR #$FF
    INC 
    SEC 

  loc_00F53A:
    XBA 
    LDA $orbitDiameter, X
    JSL $@chunk_028000.code_0282F6
    REP #$20
    XBA 
    AND #$00FF
    BCC loc_00F54F
    EOR #$FFFF
    INC 

  loc_00F54F:
    CLC 
    ADC $14
    STA $14
    LDA #$0000
    SEP #$20
    CLC 
    LDA $7F0011, X
    TAY 
    LDA $&binary_01C36C.binary_01C47D, Y
    BPL loc_00F568
    EOR #$FF
    INC 
    SEC 

  loc_00F568:
    XBA 
    LDA $7F0013, X
    JSL $@chunk_028000.code_0282F6
    REP #$20
    XBA 
    AND #$00FF
    BCC loc_00F57D
    EOR #$FFFF
    INC 

  loc_00F57D:
    CLC 
    ADC $16
    STA $16
    RTL 
}