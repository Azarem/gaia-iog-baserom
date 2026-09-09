?BANK 03

?INCLUDE 'binary_01C384'
?INCLUDE 'binary_01D8BE'
?INCLUDE 'body_table'
?INCLUDE 'camera_tilemap'
?INCLUDE 'cop_handlers_actors'
?INCLUDE 'dialogue_display'
?INCLUDE 'dictionary_01EBA8'
?INCLUDE 'dictionary_01F54D'
?INCLUDE 'dir_sprite_01ABDE'
?INCLUDE 'event_blocks'
?INCLUDE 'game_over_sequence'
?INCLUDE 'hardware_math'
?INCLUDE 'hit_stagger_controller'
?INCLUDE 'itemcomp_table_01EB0F'
?INCLUDE 'itemget_table_01FD24'
?INCLUDE 'music_array_01CBA6'
?INCLUDE 'NullActorScriptStub'
?INCLUDE 'palette_bundles'
?INCLUDE 'player_transition_handlers'
?INCLUDE 'scene_actors'
?INCLUDE 'scene_script'
?INCLUDE 'scene_thinkers'
?INCLUDE 'smooth_follow_child'
?INCLUDE 'SpawnAttackTrailEffect'
?INCLUDE 'SpawnHitSparkSprites'
?INCLUDE 'spc_transfer'
?INCLUDE 'StandardEnemyDefeatHandler'
?INCLUDE 'stats_01ABF0'
?INCLUDE 'StopPlayerOnDeathAssign'
?INCLUDE 'system_core'
?INCLUDE 'templates_01CA95'
?INCLUDE 'text_measure'
?INCLUDE 'vblank_joypad'
?INCLUDE 'vram_buffer_clear'
?INCLUDE 'warps_interaction'

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
!sfxQueueCh2                    06F9
!musicTransitionState           06FA
!dmaSkipFlag                    0800
!sceneStateHelper               099F
!playerXPos                     09A2
!playerYPos                     09A4
!playerXTile                    09A6
!playerYTile                    09A8
!playerActor                    09AA
!joypadInject                   09AC
!playerFlags                    09AE
!playerSpeedEw                  09B2
!playerSpeedNs                  09B4
!climbStateData                 09E0
!enemyHpDisplay                 09E4
!enemyHpPending                 09EA
!displayModeFlags               09EC
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
!activeActorCount               0DBC
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
!cgramPalette                   7F0A00
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

func_03BAE1 {
    PHX 
    LDA $0018
    STA $001A
    SEC 
    SBC #$0006
    STA $0018
    BRA loc_03BB0D
}
---------------------------------------------

func_03BAF1 {
    PHX 
    LDA $0000
    BIT #$F000
    BNE loc_03BB5C
    LDA $14
    SEC 
    SBC #$000C
    STA $0018
    LDA $16
    STA $001C
    LDA $0E
    STA $0002

  loc_03BB0D:
    LDA $0001
    AND #$000F
    BEQ loc_03BB24
    JSR $&func_03BB5E
    LDA $0018
    CLC 
    ADC #$0008
    STA $0018
    BRA loc_03BB2E

  loc_03BB24:
    LDA $0018
    CLC 
    ADC #$0004
    STA $0018

  loc_03BB2E:
    LDA $0000
    LSR 
    LSR 
    LSR 
    LSR 
    BEQ loc_03BB49
    AND #$000F
    JSR $&func_03BB5E
    LDA $0018
    CLC 
    ADC #$0008
    STA $0018
    BRA loc_03BB53

  loc_03BB49:
    LDA $0018
    CLC 
    ADC #$0004
    STA $0018

  loc_03BB53:
    LDA $0000
    AND #$000F
    JSR $&func_03BB5E

  loc_03BB5C:
    PLX 
    RTL 
}
---------------------------------------------

func_03BB5E {
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
---------------------------------------------

func_03BB85 {
    PHP 
    REP #$20
    LDA $joypadCurrent
    BIT #$8000
    BEQ loc_03BBB2
    LDY #$0000

  loc_03BB93:
    LDX $0C00, Y
    BEQ loc_03BBB2
    INY 
    INY 
    LDA $0010, X
    BIT #$D460
    BNE loc_03BB93
    LDA $onDodgeCallback, X
    BEQ loc_03BB93
    STA $0000, X
    LDA #$0000
    STA $onDodgeCallback, X

  loc_03BBB2:
    PLP 
    RTL 
}
---------------------------------------------

func_03BBB4 {
    PHP 
    REP #$20
    LDA $playerFlags
    BIT #$0020
    BNE loc_03BBE2
    BIT #$0200
    BNE loc_03BBE2
    LDA $playerHp
    BNE loc_03BBE2
    LDA #$0200
    TSB $playerFlags
    LDY $playerActor
    LDA #$&game_over_sequence.GameOverSequence
    STA $0000, Y
    LDA #$*game_over_sequence.GameOverSequence
    STA $0002, Y
    JSL $@StopPlayerOnDeathAssign

  loc_03BBE2:
    PLP 
    RTL 
}
---------------------------------------------

func_03BBE4 {
    PHP 
    PHB 
    REP #$20
    STZ $enemyHpPending
    LDX $playerActor
    LDA $0010, X
    BIT #$0040
    BEQ loc_03BC1B
    JMP $&code_03BD5A
}

code_03BBF9 {
    BIT #$0080
    BEQ loc_03BC26
    BIT #$0040
    BNE loc_03BC26
    LDA $0012, Y
    BIT #$0010
    BNE loc_03BC26
    STX $0E
    STY $08
    TYX 
    LDA $iframeCounter, X
    BMI code_03BC20
    JSR $&func_03BD5D
    BRA code_03BC20

  loc_03BC1B:
    LDX #$0000
    STX $0E

  code_03BC20:
    LDX $0E
    STZ $20
    STZ $24

  loc_03BC26:
    LDY $0C00, X
    BNE loc_03BC2E
    JMP $&code_03BD5A

  loc_03BC2E:
    INX 
    INX 
    LDA $0010, Y
    BIT #$0400
    BEQ code_03BBF9
    BIT #$0140
    BNE loc_03BC26
    BIT #$0020
    BEQ loc_03BC44
    INC $20

  loc_03BC44:
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
    BEQ loc_03BC6D
    ORA #$FF00

  loc_03BC6D:
    BCS loc_03BC81
    ADC $0014, X
    STA $04
    LDA $0005, Y
    AND #$00FF
    CLC 
    ADC $04
    STA $06
    BRA loc_03BC9A

  loc_03BC81:
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

  loc_03BC9A:
    LDA $0006, Y
    AND #$00FF
    BIT #$0080
    BEQ loc_03BCA8
    ORA #$FF00

  loc_03BCA8:
    CLC 
    ADC $0016, X
    STA $00
    LDA $0007, Y
    AND #$00FF
    CLC 
    ADC $00
    STA $02
    LDX #$0000

  code_03BCBC:
    LDY $0C00, X
    BNE loc_03BCC4
    JMP $&code_03BC20

  loc_03BCC4:
    INX 
    INX 
    LDA $20
    BNE loc_03BCD4
    LDA $0010, Y
    BIT #$76E0
    BEQ loc_03BCEF
    BRA code_03BCBC

  loc_03BCD4:
    STZ $24
    LDA $0010, Y
    BIT #$74E0
    BNE code_03BCBC
    PHX 
    TYX 
    LDA $extendedFlags, X
    BIT #$0010
    BNE loc_03BCEC
    PLX 
    BRA code_03BCBC

  loc_03BCEC:
    PLX 
    INC $24

  loc_03BCEF:
    LDA $0020, Y
    AND #$00FF
    BIT #$0080
    BEQ loc_03BCFD
    ORA #$FF00

  loc_03BCFD:
    SEC 
    SBC $0014, Y
    EOR #$FFFF
    INC 
    CMP $06
    BCS code_03BCBC
    LDA $0021, Y
    AND #$00FF
    BIT #$0080
    BEQ loc_03BD17
    ORA #$FF00

  loc_03BD17:
    CLC 
    ADC $0014, Y
    CMP $04
    BCC code_03BCBC
    LDA $0022, Y
    AND #$00FF
    BIT #$0080
    BEQ loc_03BD2D
    ORA #$FF00

  loc_03BD2D:
    SEC 
    SBC $0016, Y
    EOR #$FFFF
    INC 
    CMP $02
    BCS code_03BCBC
    LDA $0023, Y
    AND #$00FF
    BIT #$0080
    BEQ loc_03BD47
    ORA #$FF00

  loc_03BD47:
    CLC 
    ADC $0016, Y
    CMP $00
    BCS loc_03BD52
    JMP $&code_03BCBC

  loc_03BD52:
    PHX 
    JSR $&func_03BF27
    PLX 
    JMP $&code_03BCBC
}

code_03BD5A {
    PLB 
    PLP 
    RTL 
}
---------------------------------------------

func_03BD5D {
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

  code_03BDAF:
    LDY $0C00, X
    BNE loc_03BDB7
    JMP $&code_03BF22

  loc_03BDB7:
    INX 
    INX 
    LDA $0010, Y
    BIT #$36F0
    BNE code_03BDAF
    LDA $0020, Y
    AND #$00FF
    BIT #$0080
    BEQ loc_03BDCF
    ORA #$FF00

  loc_03BDCF:
    SEC 
    SBC $0014, Y
    EOR #$FFFF
    INC 
    CMP $06
    BCS code_03BDAF
    LDA $0021, Y
    AND #$00FF
    BIT #$0080
    BEQ loc_03BDE9
    ORA #$FF00

  loc_03BDE9:
    CLC 
    ADC $0014, Y
    CMP $04
    BCC code_03BDAF
    LDA $0022, Y
    AND #$00FF
    BIT #$0080
    BEQ loc_03BDFF
    ORA #$FF00

  loc_03BDFF:
    SEC 
    SBC $0016, Y
    EOR #$FFFF
    INC 
    CMP $02
    BCS code_03BDAF
    LDA $0023, Y
    AND #$00FF
    BIT #$0080
    BEQ loc_03BE19
    ORA #$FF00

  loc_03BE19:
    CLC 
    ADC $0016, Y
    CMP $00
    BCS loc_03BE24
    JMP $&code_03BDAF

  loc_03BE24:
    TYX 
    LDA $08
    TAX 
    LDA $chainDamage, X
    LSR 
    TYX 
    STA $chainDamage, X
    INC 
    PHA 
    EOR #$FFFF
    INC 
    CLC 
    ADC $currentHp, X
    BPL loc_03BE42
    LDA #$0000

  loc_03BE42:
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
    BNE loc_03BE76
    PLA 
    JSR $&func_03C58F
    BCS loc_03BE77
    PHA 
    COP [SpawnLastRel] ( @SpawnAttackTrailEffect, #00, #00, #$2F00 )
    PLA 
    STA $0028, Y
    BRA loc_03BE77

  loc_03BE76:
    PLA 

  loc_03BE77:
    LDA #$0080
    TSB $10
    LDA $playerFlags
    BIT #$0010
    BNE loc_03BE8B
    LDA $12
    BIT #$0010
    BEQ loc_03BEBE

  loc_03BE8B:
    LDA $0AE2
    BNE loc_03BEEE
    LDA #$0040
    TSB $10
    LDA $onDeathCallback, X
    BEQ loc_03BEAB
    STA $00
    LDA $7F1006, X
    STA $02
    STZ $08
    STZ $2C
    STZ $2E
    BRA loc_03BF08

  loc_03BEAB:
    LDA #$*StandardEnemyDefeatHandler
    STA $02
    LDA #$&StandardEnemyDefeatHandler
    STA $00
    STZ $08
    LDA #$0400
    TSB $10
    BRA loc_03BF08

  loc_03BEBE:
    COP [SpawnLastRel] ( @hit_stagger_controller.HitStaggerMain, #00, #00, #$2000 )
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
    JSR $&func_03C142
    BCC loc_03BEE7
    COP [GetPlayerFacing]

  loc_03BEE7:
    PLD 
    PLY 
    STA $0028, Y
    TDC 
    TAX 

  loc_03BEEE:
    LDA $12
    BIT #$0001
    BEQ loc_03BEFE
    LDA #$FFEF
    STA $iframeCounter, X
    BRA loc_03BF05

  loc_03BEFE:
    LDA #$0011
    STA $iframeCounter, X

  loc_03BF05:
    COP [PlaySoundCh1] ( #05 )

  loc_03BF08:
    LDA $12
    BIT #$0020
    BNE code_03BF22
    SEP #$20
    LDA $0AE0
    STA $enemyHpDisplay
    STA $enemyHpPending
    LDA $0AE2
    STA $09E6
    REP #$20
}

code_03BF22 {
    LDA #$0000
    TCD 
    RTS 
}
---------------------------------------------

func_03BF27 {
    SEP #$20
    LDA #$81
    PHA 
    PLB 
    REP #$20
    LDA $24
    BEQ loc_03BF86
    STZ $24
    TYX 
    LDA $scratch1010+6, X
    BEQ loc_03BF40
    STA $0000, X
    RTS 

  loc_03BF40:
    TXA 
    PHD 
    TCD 
    LDA #$&player_transition_handlers
    STA $00
    LDA #$*player_transition_handlers
    STA $02
    LDA #$0040
    TSB $10
    PLD 
    JSL $@func_03F0CA
    PEA $&code_03BF84-1
    BCC loc_03BF5D
    RTS 

  loc_03BF5D:
    AND #$000F
    BNE loc_03BF69
    LDA #$FFFC
    STA $extVelocityY
    RTS 

  loc_03BF69:
    DEC 
    BNE loc_03BF73
    LDA #$0004
    STA $extVelocityY
    RTS 

  loc_03BF73:
    DEC 
    BNE loc_03BF7D
    LDA #$0004
    STA $extVelocityX
    RTS 

  loc_03BF7D:
    LDA #$FFFC
    STA $extVelocityX
    RTS 
}

code_03BF84 {
    TXY 
    RTS 

  loc_03BF86:
    TYX 
    STX $3E
    LDA $0010, X
    BIT #$0010
    BEQ loc_03BF94
    JMP $&code_03C116

  loc_03BF94:
    STZ $20
    LDA $08
    CMP #$1000
    BEQ loc_03BFA2
    LDA $09E2
    STA $20

  loc_03BFA2:
    LDA $characterForm
    STA $08
    LDA $playerStr
    CLC 
    ADC $20
    CLC 
    ADC $climbStateData
    STA $20
    TXA 
    TCD 
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
    BPL loc_03BFD9
    LDA #$0001

  loc_03BFD9:
    CLC 
    ADC $0008
    STA $chainDamage, X
    PHA 
    EOR #$FFFF
    INC 
    CLC 
    ADC $currentHp, X
    BPL loc_03BFF0
    LDA #$0000

  loc_03BFF0:
    STA $currentHp, X
    STA $0AE2
    LDA $12
    BIT #$0020
    BNE loc_03C01D
    PLA 
    JSR $&func_03C58F
    BCS loc_03C01E
    PHA 
    COP [SpawnLastRel] ( @SpawnAttackTrailEffect, #00, #00, #$2B00 )
    LDA $0012, Y
    ORA #$1000
    STA $0012, Y
    PLA 
    STA $0028, Y
    BRA loc_03C01E

  loc_03C01D:
    PLA 

  loc_03C01E:
    LDA #$0080
    TSB $10
    LDA $playerFlags
    BIT #$0010
    BNE loc_03C032
    LDA $12
    BIT #$0010
    BEQ loc_03C065

  loc_03C032:
    LDA $0AE2
    BNE loc_03C097
    LDA #$0040
    TSB $10
    LDA $onDeathCallback, X
    BEQ loc_03C052
    STA $00
    LDA $7F1006, X
    STA $02
    STZ $08
    STZ $2C
    STZ $2E
    BRA loc_03C0C8

  loc_03C052:
    LDA #$*StandardEnemyDefeatHandler
    STA $02
    LDA #$&StandardEnemyDefeatHandler
    STA $00
    STZ $08
    LDA #$0400
    TSB $10
    BRA loc_03C0C8

  loc_03C065:
    TXA 
    TCD 
    COP [SpawnLastRel] ( @hit_stagger_controller.HitStaggerMain, #00, #00, #$2000 )
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
    JSR $&func_03C142
    BCC loc_03C090
    COP [GetPlayerFacing]

  loc_03C090:
    PLD 
    PLY 
    STA $0028, Y
    TDC 
    TAX 

  loc_03C097:
    LDA $onHitCallback, X
    BEQ loc_03C0AE
    STA $00
    LDA #$0000
    STA $onHitCallback, X
    LDA $02
    AND #$00FF
    BNE loc_03C0AE
    NOP 

  loc_03C0AE:
    LDA $12
    BIT #$0001
    BEQ loc_03C0BE
    LDA #$FFEF
    STA $iframeCounter, X
    BRA loc_03C0C5

  loc_03C0BE:
    LDA #$0011
    STA $iframeCounter, X

  loc_03C0C5:
    COP [PlaySoundCh1] ( #05 )

  loc_03C0C8:
    LDA $12
    BIT #$0020
    BNE loc_03C0E2
    SEP #$20
    LDA $0AE0
    STA $enemyHpDisplay
    STA $enemyHpPending
    LDA $0AE2
    STA $09E6
    REP #$20

  loc_03C0E2:
    LDA #$0000
    TCD 
    LDX $0E
    LDA $0BFE, X
    TAX 
    LDA $extendedFlags, X
    BIT #$0050
    BEQ loc_03C115
    AND #$FFAF
    STA $extendedFlags, X
    LDA $onCollideCallback, X
    BEQ loc_03C10C
    STA $0000, X
    LDA #$0000
    STA $onCollideCallback, X

  loc_03C10C:
    LDA $0012, X
    EOR #$6000
    STA $0012, X

  loc_03C115:
    RTS 
}

code_03C116 {
    TXA 
    TCD 
    LDA $10
    ORA #$0080
    STA $10
    LDA #$FFEF
    STA $iframeCounter, X
    LDA $onHitCallback, X
    BEQ loc_03C13D
    STA $00
    LDA #$0000
    STA $onHitCallback, X
    LDA $02
    AND #$00FF
    BNE loc_03C13D
    NOP 

  loc_03C13D:
    COP [PlaySoundCh1] ( #09 )
    BRA loc_03C0E2
}
---------------------------------------------

func_03C142 {
    LDY $000E
    LDX $0BFE, Y
    CPX $playerActor
    SEC 
    BNE loc_03C14F
    RTS 

  loc_03C14F:
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
    BEQ loc_03C16F
    ORA #$FF00

  loc_03C16F:
    BCS loc_03C188
    CLC 
    ADC $0014, X
    STA $0018
    LDA $0005, Y
    AND #$00FF
    LSR 
    CLC 
    ADC $0018
    STA $0018
    BRA loc_03C1A5

  loc_03C188:
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

  loc_03C1A5:
    LDA $0006, Y
    AND #$00FF
    BIT #$0080
    BEQ loc_03C1B3
    ORA #$FF00

  loc_03C1B3:
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
    BEQ loc_03C1DD
    ORA #$FF80

  loc_03C1DD:
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
    BEQ loc_03C1F8
    ORA #$FF80

  loc_03C1F8:
    CLC 
    ADC $16
    STA $001E
    LDA #$0000
    TCD 
    LDA $18
    SEC 
    SBC $1A
    BCS loc_03C22A
    EOR #$FFFF
    INC 
    STA $08
    LDA $1C
    SEC 
    SBC $1E
    BCS loc_03C222
    EOR #$FFFF
    INC 
    CMP $08
    BCS loc_03C256
    NOP 
    NOP 
    BRA loc_03C24C

  loc_03C222:
    CMP $08
    BCS loc_03C251
    NOP 
    NOP 
    BRA loc_03C24C

  loc_03C22A:
    STA $08
    LDA $1C
    SEC 
    SBC $1E
    BCS loc_03C23F
    EOR #$FFFF
    INC 
    CMP $08
    BCS loc_03C256
    NOP 
    NOP 
    BRA loc_03C247

  loc_03C23F:
    CMP $08
    BCS loc_03C251
    NOP 
    NOP 
    BRA loc_03C247

  loc_03C247:
    CLC 
    LDA #$0002
    RTS 

  loc_03C24C:
    CLC 
    LDA #$0003
    RTS 

  loc_03C251:
    CLC 
    LDA #$0001
    RTS 

  loc_03C256:
    CLC 
    LDA #$0000
    RTS 
}
---------------------------------------------

func_03C25B {
    PLB 
    PLP 
    RTL 
}

code_03C25E {
    PHP 
    PHB 
    REP #$20
    LDY $playerActor
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
    BNE func_03C25B
    BIT #$0280
    BEQ loc_03C293
    JMP $&code_03C362

  loc_03C293:
    LDY #$0000
    STY $0E

  code_03C298:
    LDY $0E

  loc_03C29A:
    LDX $0C00, Y
    BEQ func_03C25B
    INY 
    INY 
    LDA $0010, X
    BIT #$35C0
    BNE loc_03C29A
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
    BEQ loc_03C2CE
    ORA #$FF00

  loc_03C2CE:
    BCS loc_03C2E8
    ADC $0014, Y
    CMP $1A
    BCS code_03C298
    STA $06
    LDA $0005, X
    AND #$00FF
    CLC 
    ADC $06
    CMP $18
    BCC code_03C298
    BRA loc_03C307

  loc_03C2E8:
    EOR #$FFFF
    INC 
    CLC 
    ADC $0014, Y
    CMP $18
    BCC code_03C298
    STA $06
    LDA $0005, X
    AND #$00FF
    EOR #$FFFF
    INC 
    CLC 
    ADC $06
    CMP $1A
    BCS code_03C298

  loc_03C307:
    LDA $0006, X
    AND #$00FF
    BIT #$0080
    BEQ loc_03C315
    ORA #$FF00

  loc_03C315:
    CLC 
    ADC $0016, Y
    CMP $1E
    BCC loc_03C320
    JMP $&code_03C298

  loc_03C320:
    STA $02
    LDA $0007, X
    AND #$00FF
    CLC 
    ADC $02
    CMP $1C
    BCS loc_03C332
    JMP $&code_03C298

  loc_03C332:
    PHX 
    TYX 
    LDA $extendedFlags, X
    BIT #$0010
    BEQ loc_03C35B
    LDA $onCollideCallback, X
    BEQ loc_03C348
    STA $0000, X
    BRA loc_03C354

  loc_03C348:
    LDA #$*smooth_follow_child.loc_00E4FA
    STA $0002, X
    LDA #$&smooth_follow_child.loc_00E4FA
    STA $0000, X

  loc_03C354:
    LDA #$0000
    STA $0008, X
    TXY 

  loc_03C35B:
    PLX 
    JSR $&func_03C3E0

  loc_03C35F:
    PLB 
    PLP 
    RTL 
}

code_03C362 {
    LDY #$0000
    STY $0E

  loc_03C367:
    LDY $0E

  loc_03C369:
    LDX $0C00, Y
    BEQ loc_03C35F
    INY 
    INY 
    LDA $0010, X
    BIT #$3540
    BNE loc_03C369
    BIT #$0020
    BEQ loc_03C369
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
    BEQ loc_03C39D
    ORA #$FF00

  loc_03C39D:
    CLC 
    ADC $0014, Y
    CMP $1A
    BCS loc_03C367
    STA $06
    LDA $0005, X
    AND #$00FF
    CLC 
    ADC $0014, Y
    CMP $18
    BCC loc_03C367
    LDA $0006, X
    AND #$00FF
    BIT #$0080
    BEQ loc_03C3C3
    ORA #$FF00

  loc_03C3C3:
    CLC 
    ADC $0016, Y
    CMP $1E
    BCS loc_03C367
    STA $02
    LDA $0007, X
    AND #$00FF
    CLC 
    ADC $02
    CMP $1C
    BCC loc_03C367
    JSR $&func_03C3E0
    PLB 
    PLP 
    RTL 
}
---------------------------------------------

func_03C3E0 {
    LDA $0010, Y
    BIT #$0020
    BEQ loc_03C3EB
    JMP $&code_03C4D5

  loc_03C3EB:
    LDA $000E, Y
    ASL 
    ASL 
    LDA $0004, X
    AND #$00FF
    BIT #$0080
    BEQ loc_03C3FE
    ORA #$FF00

  loc_03C3FE:
    BCS loc_03C413
    ADC $0014, Y
    STA $00
    LDA $0005, X
    AND #$00FF
    LSR 
    CLC 
    ADC $00
    STA $00
    BRA loc_03C42D

  loc_03C413:
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

  loc_03C42D:
    LDA $0006, X
    AND #$00FF
    BIT #$0080
    BEQ loc_03C43B
    ORA #$FF00

  loc_03C43B:
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
    BEQ loc_03C46B
    BCS loc_03C46E

  loc_03C46B:
    LDA #$0001

  loc_03C46E:
    EOR #$FFFF
    INC 
    CLC 
    ADC $playerHp
    BPL loc_03C47B
    LDA #$0000

  loc_03C47B:
    STA $playerHp
    LDA $playerActor
    TCD 
    TAX 
    LDA #$0080
    TSB $10
    LDA #$003C
    STA $iframeCounter, X
    LDA $playerFlags
    BIT #$1800
    BNE loc_03C4C2
    COP [SpawnLastRel] ( @hit_stagger_controller.HitStaggerMain, #00, #00, #$2400 )
    CPY #$1FC0
    BEQ loc_03C4C2
    LDA $extendedFlags, X
    AND #$0020
    PHX 
    TYX 
    STA $extendedFlags, X
    PLX 
    LDA #$0F00
    TSB $joypadMaskStd
    JSR $&func_03C524
    STA $28
    STZ $2C
    STZ $2E

  loc_03C4C2:
    LDA $characterForm
    BEQ loc_03C4CC
    COP [PlaySoundCh2] ( #08 )
    BRA loc_03C4CF

  loc_03C4CC:
    COP [PlaySoundCh2] ( #07 )

  loc_03C4CF:
    LDA #$0000
    TCD 
    CLC 
    RTS 
}

code_03C4D5 {
    TYX 
    SEP #$20
    LDA #$81
    PHA 
    PLB 
    REP #$20
    LDA $chatPtr, X
    JSL $@func_03EF97
    BCC loc_03C4F7
    AND #$00FF
    STA $0DB8
    LDY #$&itemget_table_01FD24.widestring_01FF02
    JSL $@dialogue_display.ShowDialogueFrame
    SEC 
    RTS 

  loc_03C4F7:
    LDA $chatPtr, X
    CMP #$0081
    BCS loc_03C50A
    AND #$00FF
    STA $0DB8
    JSL $@dialogue_display.ShowDialogueFrame

  loc_03C50A:
    LDA #$*NullActorScriptStub
    STA $0002, X
    LDA #$&NullActorScriptStub
    STA $0000, X
    STZ $0008, X
    LDA $0010, X
    ORA #$0700
    STA $0010, X
    SEC 
    RTS 
}
---------------------------------------------

func_03C524 {
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
    BCS loc_03C55B
    EOR #$FFFF
    INC 
    STA $04
    LDA $1E
    SEC 
    SBC #$0004
    STA $1E
    SEC 
    SBC $02
    BCS loc_03C555
    EOR #$FFFF
    INC 
    CMP $04
    BCC loc_03C578
    BRA loc_03C582

  loc_03C555:
    CMP $04
    BCS loc_03C587
    BRA loc_03C578

  loc_03C55B:
    STA $04
    LDA $1E
    SEC 
    SBC #$0004
    SEC 
    SBC $02
    BCS loc_03C572
    EOR #$FFFF
    INC 
    CMP $04
    BCS loc_03C582
    BRA loc_03C57D

  loc_03C572:
    CMP $04
    BCC loc_03C57D
    BRA loc_03C587

  loc_03C578:
    LDY #$0002
    BRA loc_03C58A

  loc_03C57D:
    LDY #$0003
    BRA loc_03C58A

  loc_03C582:
    LDY #$0001
    BRA loc_03C58A

  loc_03C587:
    LDY #$0000

  loc_03C58A:
    PLA 
    TAX 
    TCD 
    TYA 
    RTS 
}
---------------------------------------------

func_03C58F {
    PHA 
    LDY $0000
    STZ $0000
    CMP #$03E8
    BCS loc_03C5F9
    CMP #$01F4
    BCC loc_03C5AC
    SEC 
    SBC #$01F4
    PHA 
    LDA #$0005
    STA $0000
    PLA 

  loc_03C5AC:
    CMP #$0064
    BCC loc_03C5BA
    SEC 
    SBC #$0064
    INC $0000
    BRA loc_03C5AC

  loc_03C5BA:
    PHA 
    LDA $0000
    XBA 
    AND #$FF00
    STA $0000
    PLA 
    SEP #$20
    CMP #$32
    BCC loc_03C5D6
    SEC 
    SBC #$32
    PHA 
    LDA #$05
    STA $0000
    PLA 

  loc_03C5D6:
    CMP #$0A
    BCC loc_03C5E2
    SEC 
    SBC #$0A
    INC $0000
    BRA loc_03C5D6

  loc_03C5E2:
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

  loc_03C5F9:
    STY $0000
    PLA 
    SEC 
    RTS 
}
---------------------------------------------

func_03C5FF {
    PHP 
    PHD 
    REP #$20
    LDY #$0000
    LDA $0058

  code_03C609:
    TAX 
    TCD 
    BNE loc_03C610
    JMP $&code_03C69B

  loc_03C610:
    LDA $14
    SEC 
    SBC $18
    SEC 
    SBC $bg1ScrollH
    CMP #$0100
    BCC loc_03C631
    BMI loc_03C623
    JMP $&code_03C691

  loc_03C623:
    LDA $14
    CLC 
    ADC $1C
    SEC 
    SBC $bg1ScrollH
    CMP #$0100
    BCS code_03C691

  loc_03C631:
    LDA $16
    SEC 
    SBC $1A
    SEC 
    SBC $bg2ScrollH
    CMP #$00E0
    BCC loc_03C64F
    BPL code_03C691
    LDA $16
    CLC 
    ADC $1E
    SEC 
    SBC $bg2ScrollH
    CMP #$00E0
    BCS code_03C691

  loc_03C64F:
    LDA $10
    BIT #$2000
    BNE loc_03C687
    BIT #$0003
    BEQ loc_03C665
    BIT #$0002
    BNE loc_03C670
    LDA #$01FE
    BRA loc_03C677

  loc_03C665:
    LDA $16
    SEC 
    SBC $bg2ScrollH
    CMP #$0100
    BCC loc_03C673

  loc_03C670:
    LDA #$00FF

  loc_03C673:
    EOR #$00FF
    ASL 

  loc_03C677:
    CMP #$0200
    BCS loc_03C677
    STA $0C00, Y
    TXA 
    STA $0C02, Y
    INY 
    INY 
    INY 
    INY 

  loc_03C687:
    LDA #$4000
    TRB $10
    LDA $04
    JMP $&code_03C609
}

code_03C691 {
    LDA #$4000
    TSB $10
    LDA $04
    JMP $&code_03C609
}

code_03C69B {
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

  loc_03C6B1:
    PLX 
    BMI loc_03C6EB
    LDY $deathFlag, X
    BNE loc_03C6D3
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
    BRA loc_03C6B1

  loc_03C6D3:
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
    BRA loc_03C6B1

  loc_03C6EB:
    LDA #$01FF
    TCS 
    LDX #$0000
    BRA loc_03C6F6

  loc_03C6F4:
    PHA 
    PLA 

  loc_03C6F6:
    PLY 
    BEQ loc_03C6F6
    BMI loc_03C70B

  loc_03C6FB:
    LDA $0000, Y
    STA $0C00, X
    INX 
    INX 
    LDA $0002, Y
    BEQ loc_03C6F4
    TAY 
    BRA loc_03C6FB

  loc_03C70B:
    STZ $0C00, X
    LDA $00
    TCS 
    PLD 
    PLP 
    RTL 
}
---------------------------------------------

func_03C714 {
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

  loc_03C74D:
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
    BNE loc_03C74D
    LDA $00
    TCS 
    JSR $&func_03C78B
    STZ $00D8
    LDX #$0000

  loc_03C76C:
    LDA $0C00, X
    BEQ loc_03C77D
    INX 
    INX 
    PHX 
    TAX 
    JSR $&func_03C849
    PLX 
    BCC loc_03C76C
    BRA loc_03C789

  loc_03C77D:
    SEP #$20
    LDA $00

  loc_03C781:
    LSR 
    LSR 
    DEC $0E
    BNE loc_03C781
    STA ($06)

  loc_03C789:
    PLP 
    RTL 
}
---------------------------------------------

func_03C78B {
    LDX #$0000
    TXY 
    LDA $layerPriorityFlag
    BIT #$1000
    BNE loc_03C7F0

  loc_03C797:
    LDA $oamComposeBuffer, X
    BPL loc_03C79E
    RTS 

  loc_03C79E:
    LDA $7F3102, X
    SEC 
    SBC $bg2ScrollH
    CMP #$00F0
    BCS loc_03C7E8
    STA $0423, Y
    LDA $7F3104, X
    STA $0424, Y
    LDA $oamComposeBuffer, X
    SEC 
    SBC $bg1ScrollH
    CMP #$0110
    BCS loc_03C7E8
    SEP #$20
    STA $0422, Y
    XBA 
    LSR 
    ROR $00
    CLC 
    ROR $00
    DEC $0E
    BNE loc_03C7DC
    LDA $00
    STA ($06)
    INC $06
    LDA #$04
    STA $0E

  loc_03C7DC:
    REP #$20
    INY 
    INY 
    INY 
    INY 
    CPY #$0200
    BNE loc_03C7E8
    RTS 

  loc_03C7E8:
    INX 
    INX 
    INX 
    INX 
    INX 
    INX 
    BRA loc_03C797

  loc_03C7F0:
    LDA $00DA
    BNE loc_03C7F6
    RTS 

  loc_03C7F6:
    LDX #$0600
    LDY #$0422
    LDA $00DA
    BIT #$FE00
    BEQ loc_03C807
    LDA #$0200

  loc_03C807:
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

  loc_03C821:
    DEC $0E
    BMI loc_03C82D
    LDA #$AA
    STA ($06)
    INC $06
    BRA loc_03C821

  loc_03C82D:
    LDY $00DA
    LDX $00
    LDA $@binary_03C841, X
    STA $00
    LDA $@binary_03C841+1, X
    STA $0E
    REP #$20
    RTS 
}
---------------------------------------------

binary_03C841 #00048003A002A801
---------------------------------------------

func_03C849 {
    PHB 
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
    BEQ loc_03C896
    BIT #$0010
    BNE loc_03C896
    BIT #$0400
    BNE loc_03C885

  loc_03C885:
    LDA $iframeCounter, X
    BEQ loc_03C893
    LSR 
    BCC loc_03C893
    LDA #$0E00
    STA $02

  loc_03C893:
    LDA $0010, X

  loc_03C896:
    BIT #$8000
    BPL loc_03C89E
    JMP $&code_03C928

  loc_03C89E:
    LDA $metaspritePtr, X
    CLC 
    ADC #$0008
    TAX 
    LDA $0000, X
    AND #$00FF
    INX 
    STA $10

  loc_03C8B0:
    LDA $04
    ASL 
    LDA $0003, X
    BCC loc_03C8B9
    XBA 

  loc_03C8B9:
    AND #$00FF
    CLC 
    ADC $1C
    CMP #$00F0
    BCS loc_03C920
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
    BCC loc_03C8DE
    XBA 

  loc_03C8DE:
    AND #$00FF
    CLC 
    ADC $18
    CMP #$0110
    BCS loc_03C920
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
    BNE loc_03C909
    LDA $00
    STA ($06)
    INC $06
    LDA #$04
    STA $0E

  loc_03C909:
    REP #$20
    INY 
    INY 
    INY 
    INY 
    CPY #$0200
    BEQ loc_03C91E

  loc_03C914:
    TXA 
    CLC 
    ADC #$0007
    TAX 
    DEC $10
    BNE loc_03C8B0

  loc_03C91E:
    PLB 
    RTS 

  loc_03C920:
    LDA #$E080
    STA $0422, Y
    BRA loc_03C914
}

code_03C928 {
    JSR $&func_03CA19
    LDA $playerFlags
    BPL loc_03C936
    LDA $animScratch2, X
    BRA loc_03C93F

  loc_03C936:
    LDA $characterForm
    ASL 
    CLC 
    ADC $characterForm
    ASL 

  loc_03C93F:
    TAX 
    LDA $@body_table+3, X
    STA $06FC
    LDA $@body_table+5, X
    AND #$00FF
    STA ($08)
    INC $08
    LDA $09CC
    CLC 
    ADC #$0008
    TAX 
    LDA $0000, X
    AND #$00FF
    INX 
    STA $10

  code_03C963:
    LDA $04
    ASL 
    LDA $0003, X
    BCC loc_03C96C
    XBA 

  loc_03C96C:
    AND #$00FF
    CLC 
    ADC $1C
    CMP #$00F0
    BCC loc_03C97A
    JMP $&code_03CA05

  loc_03C97A:
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
    BEQ loc_03C9AF
    CLC 
    ADC #$0010

  loc_03C9AF:
    STA $14
    LDA $04
    ASL 
    ASL 
    LDA $0001, X
    BCC loc_03C9BB
    XBA 

  loc_03C9BB:
    AND #$00FF
    CLC 
    ADC $18
    CMP #$0110
    BCS code_03CA05
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
    BNE loc_03C9E6
    LDA $00
    STA ($06)
    INC $06
    LDA #$04
    STA $0E

  loc_03C9E6:
    REP #$20
    INY 
    INY 
    INY 
    INY 
    CPY #$0200
    BEQ loc_03C9FE

  loc_03C9F1:
    TXA 
    CLC 
    ADC #$0007
    TAX 
    DEC $10
    BEQ loc_03C9FE
    JMP $&code_03C963

  loc_03C9FE:
    LDA #$0000
    STA ($08)
    PLB 
    RTS 
}

code_03CA05 {
    LDA #$0004
    TSB $playerFlags
    LDA #$0008
    TSB $displayModeFlags
    LDA #$E080
    STA $0422, Y
    BRA loc_03C9F1
}
---------------------------------------------

func_03CA19 {
    LDA $playerFlags
    BIT #$0004
    BNE loc_03CA37
    LDA $metaspritePtr, X
    CMP $09CC
    BNE loc_03CA37
    LDA $7F0008, X
    CMP $09CE
    BNE loc_03CA37
    LDA $09CC
    RTS 

  loc_03CA37:
    LDA $playerFlags
    AND #$FFFB
    STA $playerFlags
    LDA $7F0008, X
    STA $09CE
    LDA $metaspritePtr, X
    STA $09CC
    LDA #$0008
    TSB $displayModeFlags
    RTS 
}
---------------------------------------------

func_03CA55 {
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
    BMI loc_03CAF0
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
    BCC loc_03CA92
    XBA 

  loc_03CA92:
    SEP #$20
    STA $1A
    XBA 
    STA $1E
    REP #$20
    LDA $0000, Y
    STA $0000
    PLP 
    BPL loc_03CAA5
    XBA 

  loc_03CAA5:
    STA $0000
    AND #$00FF
    BIT #$0080
    BEQ loc_03CAB3
    ORA #$FF00

  loc_03CAB3:
    STA $18
    LDA $0001
    AND #$00FF
    BIT #$0080
    BEQ loc_03CAC3
    ORA #$FF00

  loc_03CAC3:
    STA $1C
    INC $2A
    LDA $12
    BIT #$0100
    BNE loc_03CAED
    BIT #$0080
    BNE loc_03CAE3
    LDA $0000
    STA $20
    LDA $0002
    SEC 
    SBC #$0008
    STA $22
    BRA loc_03CAED

  loc_03CAE3:
    LDA $0000
    STA $20
    LDA $0002
    STA $22

  loc_03CAED:
    CLC 
    PLB 
    RTL 

  loc_03CAF0:
    STZ $2A
    SEC 
    PLB 
    RTL 
}
---------------------------------------------

run_actors_03CAF5 {
    PHP 
    PHD 
    REP #$20
    LDA $playerFlags
    BIT #$0008
    BEQ loc_03CB07
    LDA #$8000
    TRB $joypadCurrent

  loc_03CB07:
    BIT #$0010
    BEQ loc_03CB0F
    JMP $&code_03CC3D

  loc_03CB0F:
    LDA $displayModeFlags
    BIT #$0080
    BEQ loc_03CB1A
    JMP $&code_03CBA3

  loc_03CB1A:
    LDA $56
    BEQ loc_03CB90

  loc_03CB1E:
    TCD 
    TAX 
    LDA $10
    BIT #$2000
    BEQ loc_03CB3D
    DEC $08
    BPL code_03CB93
    STZ $08
    PHK 
    PEA $&code_03CB93-1
    SEP #$20
    LDA $02
    PHA 
    REP #$20
    LDA $00
    DEC 
    PHA 
    RTL 

  loc_03CB3D:
    BIT #$0080
    BEQ loc_03CB62
    LDA $iframeCounter, X
    BEQ loc_03CB5D
    BMI loc_03CB56
    DEC 
    STA $iframeCounter, X
    CPX $playerActor
    BEQ loc_03CB62
    BRA loc_03CB8C

  loc_03CB56:
    INC 
    STA $iframeCounter, X
    BNE loc_03CB62

  loc_03CB5D:
    LDA #$0080
    TRB $10

  loc_03CB62:
    DEC $08
    BPL code_03CB78
    STZ $08
    PHK 
    PEA $&code_03CB78-1
    SEP #$20
    LDA $02
    PHA 
    REP #$20
    LDA $00
    DEC 
    PHA 
    RTL 
}

code_03CB78 {
    LDA $10
    AND #$FFFB
    STA $10
    BIT #$0008
    BEQ loc_03CB89
    JSR $&func_03D276
    BRA loc_03CB8C

  loc_03CB89:
    JSR $&func_03D1F5

  loc_03CB8C:
    LDA $06
    BNE loc_03CB1E

  loc_03CB90:
    PLD 
    PLP 
    RTL 
}

code_03CB93 {
    LDA $10
    BIT #$2000
    BEQ code_03CB78
    LDA $12
    BIT #$0008
    BEQ loc_03CB8C
    BRA code_03CB78
}

code_03CBA3 {
    LDA $56
    BNE loc_03CBAA
    JMP $&code_03CC2A

  loc_03CBAA:
    TCD 
    TAX 
    LDA $10
    BIT #$1000
    BNE loc_03CBBC
    LDA $12
    BIT #$1000
    BEQ loc_03CC26
    LDA $10

  loc_03CBBC:
    BIT #$2000
    BEQ loc_03CBD7
    DEC $08
    BPL code_03CC2D
    STZ $08
    PHK 
    PEA $&code_03CC2D-1
    SEP #$20
    LDA $02
    PHA 
    REP #$20
    LDA $00
    DEC 
    PHA 
    RTL 

  loc_03CBD7:
    BIT #$0080
    BEQ loc_03CBFC
    LDA $iframeCounter, X
    BEQ loc_03CBF7
    BMI loc_03CBF0
    DEC 
    STA $iframeCounter, X
    CPX $playerActor
    BEQ loc_03CBFC
    BRA loc_03CC26

  loc_03CBF0:
    INC 
    STA $iframeCounter, X
    BNE loc_03CBFC

  loc_03CBF7:
    LDA #$0080
    TRB $10

  loc_03CBFC:
    DEC $08
    BPL code_03CC12
    STZ $08
    PHK 
    PEA $&code_03CC12-1
    SEP #$20
    LDA $02
    PHA 
    REP #$20
    LDA $00
    DEC 
    PHA 
    RTL 
}

code_03CC12 {
    LDA $10
    AND #$FFFB
    STA $10
    BIT #$0008
    BEQ loc_03CC23
    JSR $&func_03D276
    BRA loc_03CC26

  loc_03CC23:
    JSR $&func_03D1F5

  loc_03CC26:
    LDA $06
    BNE loc_03CBAA
}

code_03CC2A {
    PLD 
    PLP 
    RTL 
}

code_03CC2D {
    LDA $10
    BIT #$2000
    BEQ code_03CC12
    LDA $12
    BIT #$0008
    BEQ loc_03CC26
    BRA code_03CC12
}

code_03CC3D {
    LDA $56
    BNE code_03CC44
    JMP $&code_03CCCA

  code_03CC44:
    TCD 
    TAX 
    LDA $12
    BIT #$1004
    BNE loc_03CC54
    LDA $10
    BIT #$1400
    BEQ loc_03CCCD

  loc_03CC54:
    BIT #$2000
    BEQ loc_03CC72
    DEC $08
    BMI loc_03CC60
    JMP $&code_03CCEF

  loc_03CC60:
    STZ $08
    PHK 
    PEA $&code_03CCEF-1
    SEP #$20
    LDA $02
    PHA 
    REP #$20
    LDA $00
    DEC 
    PHA 
    RTL 

  loc_03CC72:
    BIT #$0080
    BEQ loc_03CC97
    LDA $iframeCounter, X
    BEQ loc_03CC92
    BMI loc_03CC8B
    DEC 
    STA $iframeCounter, X
    CPX $playerActor
    BEQ loc_03CC97
    BRA loc_03CCC3

  loc_03CC8B:
    INC 
    STA $iframeCounter, X
    BNE loc_03CC97

  loc_03CC92:
    LDA #$0080
    TRB $10

  loc_03CC97:
    DEC $08
    BPL code_03CCAD
    STZ $08
    PHK 
    PEA $&code_03CCAD-1
    SEP #$20
    LDA $02
    PHA 
    REP #$20
    LDA $00
    DEC 
    PHA 
    RTL 
}

code_03CCAD {
    LDA $10
    AND #$FFFB
    STA $10
    BIT #$0008
    BEQ loc_03CCBE
    JSR $&func_03D276
    BRA loc_03CCC3

  loc_03CCBE:
    JSR $&func_03D1F5
    BRA loc_03CCC3

  loc_03CCC3:
    LDA $06
    BEQ code_03CCCA
    JMP $&code_03CC44
}

code_03CCCA {
    PLD 
    PLP 
    RTL 

  loc_03CCCD:
    BIT #$0080
    BEQ loc_03CCC3
    LDA $iframeCounter, X
    BEQ loc_03CCE8
    BMI loc_03CCE1
    DEC 
    STA $iframeCounter, X
    BRA loc_03CCC3

  loc_03CCE1:
    INC 
    STA $iframeCounter, X
    BRA loc_03CCC3

  loc_03CCE8:
    LDA #$0080
    TRB $10
    BRA loc_03CCC3
}

code_03CCEF {
    LDA $10
    BIT #$2000
    BEQ code_03CCAD
    LDA $12
    BIT #$0008
    BEQ loc_03CCC3
    BRA code_03CCAD
}
---------------------------------------------

func_03CCFF {
    PHP 
    PHD 
    REP #$20
    LDA $56
    BEQ loc_03CD5B

  loc_03CD07:
    TCD 
    TAX 
    LDA $10
    AND #$FFFB
    STA $10
    BIT #$0800
    BEQ loc_03CD57
    LDA $10
    BIT #$2000
    BEQ loc_03CD32
    DEC $08
    BPL code_03CD5E
    STZ $08
    PHK 
    PEA $&code_03CD5E-1
    SEP #$20
    LDA $02
    PHA 
    REP #$20
    LDA $00
    DEC 
    PHA 
    RTL 

  loc_03CD32:
    DEC $08
    BPL code_03CD48
    STZ $08
    PHK 
    PEA $&code_03CD48-1
    SEP #$20
    LDA $02
    PHA 
    REP #$20
    LDA $00
    DEC 
    PHA 
    RTL 
}

code_03CD48 {
    LDA $10
    BIT #$0008
    BEQ loc_03CD54
    JSR $&func_03D276
    BRA loc_03CD57

  loc_03CD54:
    JSR $&func_03D1F5

  loc_03CD57:
    LDA $06
    BNE loc_03CD07

  loc_03CD5B:
    PLD 
    PLP 
    RTL 
}

code_03CD5E {
    LDA $10
    BIT #$2000
    BEQ code_03CD48
    LDA $12
    BIT #$0008
    BEQ loc_03CD57
    BRA code_03CD48
}
---------------------------------------------

func_03CD6E {
    PHP 
    PHD 
    REP #$20
    LDA $displayModeFlags
    BIT #$0080
    BEQ loc_03CD7D
    JMP $&code_03CBA3

  loc_03CD7D:
    LDA $56
    BEQ loc_03CDC9

  loc_03CD81:
    TCD 
    TAX 
    LDA $12
    BIT #$1000
    BEQ loc_03CDC5
    LDA $10
    AND #$FFFB
    STA $10
    BIT #$2000
    BEQ loc_03CDAC
    DEC $08
    BPL loc_03CDC5
    STZ $08
    PHK 
    PEA $&func_03CDCC-1
    SEP #$20
    LDA $02
    PHA 
    REP #$20
    LDA $00
    DEC 
    PHA 
    RTL 

  loc_03CDAC:
    DEC $08
    BPL code_03CDC2
    STZ $08
    PHK 
    PEA $&code_03CDC2-1
    SEP #$20
    LDA $02
    PHA 
    REP #$20
    LDA $00
    DEC 
    PHA 
    RTL 
}

code_03CDC2 {
    JSR $&func_03D1F5

  loc_03CDC5:
    LDA $06
    BNE loc_03CD81

  loc_03CDC9:
    PLD 
    PLP 
    RTL 
}
---------------------------------------------

func_03CDCC {
    LDA $10
    BIT #$2000
    BEQ code_03CDC2
    LDA $12
    BIT #$0008
    BEQ loc_03CDC5
    BRA code_03CDC2
}
---------------------------------------------

func_03CDDC {
    PHP 
    REP #$20
    LDX #$0E00
    STX $4E
    LDA #$0000
    STA $50
    LDA #$1000
    LDX #$0000

  loc_03CDEF:
    STA $0E00, X
    INX 
    INX 
    CLC 
    ADC #$0030
    CPX #$00A8
    BMI loc_03CDEF
    LDA #$FFFF
    STA $0E00, X
    LDA $sceneCurrent
    CMP #$00FF
    BEQ loc_03CE23
    LDX #$0000
    TXA 

  loc_03CE0F:
    STA $1000, X
    STA $onHitCallback, X
    STA $7F2000, X
    INX 
    INX 
    CPX #$0FC0
    BNE loc_03CE0F
    BRA loc_03CE35

  loc_03CE23:
    LDX #$0000
    TXA 

  loc_03CE27:
    STA $1000, X
    STA $onHitCallback, X
    INX 
    INX 
    CPX #$0FC0
    BNE loc_03CE27

  loc_03CE35:
    LDX #$3000
    STX $52
    LDA #$007E
    STA $54
    LDA #$0F00
    LDX #$0000

  loc_03CE45:
    STA $thinkerPoolAddrs, X
    INX 
    INX 
    CLC 
    ADC #$0010
    CPX #$0020
    BMI loc_03CE45
    LDA #$FFFF
    STA $thinkerPoolAddrs, X
    LDA $sceneCurrent
    CMP #$00FF
    BEQ loc_03CE7B
    LDX #$0000
    TXA 

  loc_03CE67:
    STA $0F00, X
    STA $7F0E00, X
    STA $7F3000, X
    INX 
    INX 
    CPX #$0100
    BNE loc_03CE67
    PLP 
    RTL 

  loc_03CE7B:
    LDX #$0000
    TXA 

  loc_03CE7F:
    STA $0F00, X
    STA $7F0E00, X
    INX 
    INX 
    CPX #$0100
    BNE loc_03CE7F
    PLP 
    RTL 
}
---------------------------------------------

func_03CE8F {
    LDA [$52]
    BMI loc_03CE9F
    TAY 
    LDA #$0000
    STA [$52]
    INC $52
    INC $52
    CLC 
    RTL 

  loc_03CE9F:
    SEC 
    RTL 
}
---------------------------------------------

func_03CEA1 {
    PHP 
    REP #$20
    STZ $0056
    STZ $0058
    LDA #$*scene_actors
    STA $40
    LDX $0646
    LDA $@scene_actors, X
    STA $3E
    BEQ loc_03CEEC
    LDA [$3E]
    AND #$00FF
    CMP #$00FF
    BEQ loc_03CEEC
    JSL $@cop_handlers_actors.ActorPoolAllocator
    STY $0056
    BRA loc_03CEE3

  loc_03CECD:
    LDA [$3E]
    AND #$00FF
    CMP #$00FF
    BEQ loc_03CEE9
    JSL $@cop_handlers_actors.ActorPoolAllocator
    TYA 
    STA $0006, X
    TXA 
    STA $0004, Y

  loc_03CEE3:
    TYX 
    JSR $&func_03CF1B
    BCC loc_03CECD

  loc_03CEE9:
    STX $0058

  loc_03CEEC:
    LDA #$1000
    STA $playerActorDp
    PLP 
    RTL 
}
---------------------------------------------

func_03CEF4 {
    TYA 
    INC 
    CLC 
    ADC $3E
    STA $3E
    LDA [$3E]
    AND #$00FF
    CMP #$00FF
    BNE func_03CF1B
    DEC $4E
    DEC $4E
    TXA 
    STA [$4E]
    DEC $activeActorCount
    LDY $0004, X
    LDA #$0000
    STA $0006, Y
    TYX 
    SEC 
    RTS 
}
---------------------------------------------

func_03CF1B {
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
    BNE loc_03CF4C
    AND #$00F6
    XBA 
    ORA $06F0
    STA $000E, X
    BRA loc_03CF53

  loc_03CF4C:
    AND #$00FF
    LSR 
    STA $000E, X

  loc_03CF53:
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
    BEQ loc_03CFA5
    LDA [$3E], Y
    INY 
    AND #$00FF
    STA $enemyNum, X
    BEQ loc_03CF81
    JSR $&func_03D0DB
    BCC loc_03CF81
    JMP $&func_03CEF4

  loc_03CF81:
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

  loc_03CFA5:
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
    BMI loc_03D00F
    LDA #$4000
    STA $spritesetPtr, X
    LDA #$007E
    STA $7F0008, X
    JSL $@func_03CA55
    LDA $14
    CLC 
    ADC #$0008
    STA $14
    STZ $08
    PLD 
    LDA $statsPtr, X
    BNE loc_03CFF8
    RTS 

  loc_03CFF8:
    ASL 
    ASL 
    CLC 
    ADC #$&stats_01ABF0
    STA $statsPtr, X
    TAY 
    LDA $0000, Y
    AND #$00FF
    STA $currentHp, X
    CLC 
    RTS 

  loc_03D00F:
    LDA #$0088
    TRB $playerFlags
    LDA $0E
    BIT #$0600
    BEQ loc_03D03B
    PHA 
    AND #$F9FF
    STA $0E
    LDA $01, S
    BIT #$0200
    BEQ loc_03D02F
    LDA #$0008
    TSB $playerFlags

  loc_03D02F:
    PLA 
    BIT #$0400
    BEQ loc_03D03B
    LDA #$0080
    TSB $playerFlags

  loc_03D03B:
    LDA $0650
    AND #$00FF
    ASL 
    TAY 
    LDA $&dir_sprite_01ABDE, Y
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
    BEQ loc_03D092
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
    JSL $@func_03CA55
    STZ $08
    BRA loc_03D09A

  loc_03D092:
    LDA $14
    CLC 
    ADC #$0008
    STA $14

  loc_03D09A:
    LDA $14
    STA $playerXPos
    LSR 
    LSR 
    LSR 
    LSR 
    STA $playerXTile
    LDA $14
    SEC 
    SBC #$0080
    BPL loc_03D0B1
    LDA #$0000

  loc_03D0B1:
    STA $cameraTargetX
    STA $bg1ScrollH
    LDA $16
    SEC 
    SBC #$0010
    STA $playerYPos
    LSR 
    LSR 
    LSR 
    LSR 
    STA $playerYTile
    LDA $16
    SEC 
    SBC #$0080
    BPL loc_03D0D2
    LDA #$0000

  loc_03D0D2:
    STA $cameraTargetY
    STA $bg2ScrollH
    PLD 
    CLC 
    RTS 
}
---------------------------------------------

func_03D0DB {
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
    LDA $@binary_03D125, X
    AND $wramFlags, Y
    BNE loc_03D0FE
    CLC 
    REP #$20
    PLX 
    PLY 
    RTS 

  loc_03D0FE:
    REP #$20
    LDA $03, S
    TAY 
    LDA [$3E], Y
    AND #$00FF
    BEQ loc_03D121
    NOP 
    JSL $@event_blocks.LookupEventBlock
    BCS loc_03D121
    LDY $3E
    PHY 
    LDY $40
    PHY 
    JSL $@event_blocks.SwapEventBlockTiles
    PLY 
    STY $40
    PLY 
    STY $3E

  loc_03D121:
    SEC 
    PLX 
    PLY 
    RTS 
}
---------------------------------------------

binary_03D125 #0102040810204080
---------------------------------------------

func_03D12D {
    PHP 
    PHD 
    REP #$20
    LDA $5A
    BEQ loc_03D15A

  loc_03D135:
    TCD 
    TAX 
    LDA $animScratch2, X
    BIT #$0004
    BNE code_03D156
    DEC $08
    BPL code_03D156
    STZ $08
    PHK 
    PEA $&code_03D156-1
    SEP #$20
    LDA $02
    PHA 
    REP #$20
    LDA $00
    DEC 
    PHA 
    RTL 
}

code_03D156 {
    LDA $06
    BNE loc_03D135

  loc_03D15A:
    PLD 
    PLP 
    RTL 
}
---------------------------------------------

func_03D15D {
    PHP 
    PHD 
    REP #$20
    LDA $5A
    BEQ loc_03D18A

  loc_03D165:
    TCD 
    TAX 
    LDA $animScratch2, X
    BIT #$0004
    BEQ code_03D186
    DEC $08
    BPL code_03D186
    STZ $08
    PHK 
    PEA $&code_03D186-1
    SEP #$20
    LDA $02
    PHA 
    REP #$20
    LDA $00
    DEC 
    PHA 
    RTL 
}

code_03D186 {
    LDA $06
    BNE loc_03D165

  loc_03D18A:
    PLD 
    PLP 
    RTL 
}
---------------------------------------------

func_03D18D {
    PHP 
    PHD 
    REP #$20
    LDA $5A
    BEQ loc_03D1BF

  loc_03D195:
    TCD 
    TAX 
    LDA $animScratch2, X
    BIT #$0800
    BEQ code_03D1BB
    BIT #$0004
    BNE code_03D1BB
    DEC $08
    BPL code_03D1BB
    STZ $08
    PHK 
    PEA $&code_03D1BB-1
    SEP #$20
    LDA $02
    PHA 
    REP #$20
    LDA $00
    DEC 
    PHA 
    RTL 
}

code_03D1BB {
    LDA $06
    BNE loc_03D195

  loc_03D1BF:
    PLD 
    PLP 
    RTL 
}
---------------------------------------------

func_03D1C2 {
    PHP 
    PHD 
    REP #$20
    LDA $5A
    BEQ loc_03D1F2

  loc_03D1CA:
    TCD 
    TAX 
    LDA $animScratch2, X
    AND #$0804
    CMP #$0804
    BNE code_03D1EE
    DEC $08
    BPL code_03D1EE
    STZ $08
    PHK 
    PEA $&code_03D1EE-1
    SEP #$20
    LDA $02
    PHA 
    REP #$20
    LDA $00
    DEC 
    PHA 
    RTL 
}

code_03D1EE {
    LDA $06
    BNE loc_03D1CA

  loc_03D1F2:
    PLD 
    PLP 
    RTL 
}
---------------------------------------------

func_03D1F5 {
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
---------------------------------------------

func_03D276 {
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
    PEA $&code_03D2B9-1
    BPL loc_03D2B6
    JMP $&code_03D39C

  loc_03D2B6:
    JMP $&code_03D41F
}

code_03D2B9 {
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
    PEA $&code_03D337-1
    BPL loc_03D334
    JMP $&code_03D556

  loc_03D334:
    JMP $&code_03D5D7
}

code_03D337 {
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

code_03D39C {
    PHB 
    CLC 
    ADC $14
    STA $0018
    LDA #$0000
    TCD 
    JSR $&func_03D708
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
    JSL $@func_03D78A
    STY $00

  loc_03D3F9:
    LDA [$80], Y
    BIT #$00F0
    BEQ loc_03D403
    JMP $&code_03D4CE

  loc_03D403:
    AND #$000F
    BNE loc_03D413
    DEC $0E
    BEQ loc_03D413
    JSR $&func_03D7B4
    STY $00
    BRA loc_03D3F9

  loc_03D413:
    ASL 
    TXY 
    TAX 
    JMP ($&func_03D4AD, X)

  loc_03D419:
    PHA 
    LDA #$000F
    BRA loc_03D413
}

code_03D41F {
    PHB 
    CLC 
    ADC $14
    STA $0018
    LDA #$0000
    TCD 
    JSR $&func_03D708
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
    JSL $@func_03D78A
    STY $00

  loc_03D490:
    LDA [$80], Y
    BIT #$00F0
    BNE code_03D4CE
    AND #$000F
    BNE loc_03D4A7
    DEC $0E
    BEQ loc_03D4A7
    JSR $&func_03D7B4
    STY $00
    BRA loc_03D490

  loc_03D4A7:
    ASL 
    TXY 
    TAX 
    JMP ($&func_03D4AD, X)
}
---------------------------------------------

func_03D4AD [
  &code_03D541   ;00
  &code_03D4CD   ;01
  &code_03D4CD   ;02
  &code_03D4CD   ;03
  &code_03D4CD   ;04
  &code_03D4CD   ;05
  &code_03D4CD   ;06
  &code_03D4CD   ;07
  &code_03D4CD   ;08
  &code_03D4CD   ;09
  &code_03D4CD   ;0A
  &code_03D4CD   ;0B
  &code_03D4CD   ;0C
  &code_03D4CD   ;0D
  &code_03D4CD   ;0E
  &code_03D4CD   ;0F
]

code_03D4CD {
    TYX 
}

code_03D4CE {
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

code_03D53B {
    TXA 
    TCD 
    PLA 
    PLB 
    CLC 
    RTS 
}

code_03D541 {
    TYX 
    LDA $01, S
    BIT #$000F
    BEQ code_03D53B
    JSR $&func_03D7B4
    LDA [$80], Y
    AND #$00FF
    BEQ code_03D53B
    JMP $&code_03D4CE
}

code_03D556 {
    PHB 
    CLC 
    ADC $16
    STA $001C
    LDA #$0000
    TCD 
    JSR $&func_03D708
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
    JSL $@func_03D78A
    STY $00

  loc_03D5B2:
    LDA [$80], Y
    BIT #$00F0
    BEQ loc_03D5BC
    JMP $&func_03D67C

  loc_03D5BC:
    AND #$000F
    BNE loc_03D5CC
    DEC $0E
    BEQ loc_03D5CC
    JSR $&sub_03D7CA
    STY $00
    BRA loc_03D5B2

  loc_03D5CC:
    ASL 
    TXY 
    TAX 
    JMP ($&func_03D65C, X)

  loc_03D5D2:
    LDA #$000F
    BRA loc_03D5CC
}

code_03D5D7 {
    PHB 
    CLC 
    ADC $16
    STA $001C
    LDA #$0000
    TCD 
    JSR $&func_03D708
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
    JSL $@func_03D78A
    STY $00

  loc_03D63F:
    LDA [$80], Y
    BIT #$00F0
    BNE func_03D67C
    AND #$000F
    BNE loc_03D656
    DEC $0E
    BEQ loc_03D656
    JSR $&sub_03D7CA
    STY $00
    BRA loc_03D63F

  loc_03D656:
    ASL 
    TXY 
    TAX 
    JMP ($&func_03D65C, X)
}
---------------------------------------------

func_03D65C [
  &func_03D6EF   ;00
  &func_03D704   ;01
  &func_03D704   ;02
  &func_03D704   ;03
  &func_03D704   ;04
  &func_03D704   ;05
  &func_03D704   ;06
  &func_03D704   ;07
  &func_03D704   ;08
  &func_03D704   ;09
  &func_03D704   ;0A
  &func_03D704   ;0B
  &func_03D704   ;0C
  &func_03D704   ;0D
  &func_03D704   ;0E
  &func_03D704   ;0F
]
---------------------------------------------

func_03D67C {
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

code_03D6E9 {
    TXA 
    TCD 
    PLA 
    PLB 
    CLC 
    RTS 
}
---------------------------------------------

func_03D6EF {
    TYX 
    LDA $01, S
    BIT #$000F
    BEQ code_03D6E9
    JSR $&sub_03D7CA
    LDA [$80], Y
    AND #$00FF
    BEQ code_03D6E9
    JMP $&func_03D67C
}
---------------------------------------------

func_03D704 {
    TYX 
    JMP $&func_03D67C
}
---------------------------------------------

func_03D708 {
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
    JSL $@func_03D78A
    STY $00
    LDA [$80], Y
    AND #$00FF
    BEQ loc_03D758
    CMP #$0006
    BNE loc_03D782
    JSR $&func_03D7B4
    STY $00
    JSR $&sub_03D7CA
    LDA [$80], Y
    AND #$00FF
    CMP #$0006
    BNE loc_03D782
    BRA loc_03D77A

  loc_03D758:
    LDA $00
    STA $02
    JSR $&sub_03D7CA
    LDA [$80], Y
    AND #$00FF
    CMP #$0009
    BNE loc_03D782
    LDA $02
    STA $00
    JSR $&func_03D7B4
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
---------------------------------------------

func_03D78A {
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
---------------------------------------------

func_03D7B4 {
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
---------------------------------------------

sub_03D7CA {
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
---------------------------------------------

func_03D7E7 {
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
    JSL $@func_03CE8F
    STY $005A
    BRA loc_03D826

  loc_03D810:
    LDA [$3E]
    AND #$00FF
    CMP #$00FF
    BEQ loc_03D82C
    JSL $@func_03CE8F
    TYA 
    STA $0006, X
    TXA 
    STA $0004, Y

  loc_03D826:
    TYX 
    JSR $&sub_03D831
    BRA loc_03D810

  loc_03D82C:
    STX $005C

  loc_03D82F:
    PLP 
    RTL 
}
---------------------------------------------

sub_03D831 {
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
---------------------------------------------

zero_bytes_03D86A {
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
---------------------------------------------

func_03D881 {
    LDA $displayModeFlags
    BIT #$08
    BNE loc_03D889
    RTL 

  loc_03D889:
    AND #$F7
    STA $displayModeFlags
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
    JSR $&sub_03D8D8
    CPY #$0011
    BNE loc_03D8BD
    LDX #$4200
    STX $VMADDL
    JSR $&sub_03D8D8

  loc_03D8BD:
    LDY #$0001
    LDX #$4100
    STX $VMADDL
    JSR $&sub_03D8F2
    CPY #$0011
    BNE loc_03D8D7
    LDX #$4300
    STX $VMADDL
    JSR $&sub_03D8F2

  loc_03D8D7:
    RTL 
}
---------------------------------------------

sub_03D8D8 {
    LDX $06FE, Y
    BEQ loc_03D8F1
    STX $A1T0L
    LDA #$40
    STA $DAS0L
    LDA #$01
    STA $MDMAEN
    INY 
    INY 
    CPY #$0011
    BNE sub_03D8D8

  loc_03D8F1:
    RTS 
}
---------------------------------------------

sub_03D8F2 {
    REP #$20
    LDA $06FE, Y
    BEQ loc_03D913
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
    BNE sub_03D8F2

  loc_03D913:
    SEP #$20
    RTS 
}
---------------------------------------------

func_03D916 {
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

  loc_03D92C:
    LDA $eventFlags, Y
    STA $306200, X
    INX 
    INX 
    INY 
    INY 
    CPY #$01FC
    BNE loc_03D92C
    PLX 
    JSL $@func_03D9B8
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
---------------------------------------------

func_03D954 {
    PHP 
    PHX 
    PHB 
    REP #$20
    AND #$0003
    XBA 
    ASL 
    TAX 
    JSL $@func_03D9B8
    LDA $0018
    CMP $3063FC, X
    BNE loc_03D98F
    LDA $001C
    CMP $3063FE, X
    BNE loc_03D98F
    LDY #$0000
    PHX 

  loc_03D979:
    LDA $306200, X
    STA $eventFlags, Y
    INX 
    INX 
    INY 
    INY 
    CPY #$01FC
    BNE loc_03D979
    PLX 
    PLB 
    PLX 
    PLP 
    CLC 
    RTL 

  loc_03D98F:
    PLB 
    PLX 
    PLP 
    SEC 
    RTL 
}
---------------------------------------------

func_03D994 {
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

  loc_03D9A6:
    STA $306200, X
    INX 
    INX 
    INY 
    CPY #$0100
    BNE loc_03D9A6
    PLX 
    PLB 
    PLX 
    PLP 
    SEC 
    RTL 
}
---------------------------------------------

func_03D9B8 {
    PHP 
    PHX 
    REP #$20
    LDA #$3652
    STA $0018
    STA $001C
    LDA #$00FE
    STA $000E

  loc_03D9CB:
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
    BNE loc_03D9CB
    PLX 
    PLP 
    RTL 
}
---------------------------------------------

func_03D9E8 {
    LDA $0D52
    ORA $0D53
    BNE func_03D9F6
    LDA $sceneNext
    BNE func_03D9F6
    RTL 
}
---------------------------------------------

func_03D9F6 {
    LDA $worldReadyFlag
    BMI loc_03DA03
    BEQ loc_03DA00
    JSR $&sub_03DABB

  loc_03DA00:
    STZ $worldReadyFlag

  loc_03DA03:
    STZ $66
    JSL $@vblank_joypad.EnableNmiOnly
    JSL $@vblank_joypad.EnableDisplay
    LDA #$00
    XBA 
    LDA $0D52
    ORA $0D53
    BEQ loc_03DA41
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
    BRA loc_03DA4D

  loc_03DA41:
    LDA $sceneCurrent
    STA $0D6E
    STZ $0D6F
    LDA $sceneNext

  loc_03DA4D:
    STZ $sceneNext
    STA $sceneCurrent
    REP #$20
    ASL 
    STA $0646
    SEP #$20
    JSL $@func_03DD56
    JSL $@func_03DECD
    JSL $@system_core.UpdateHUD
    JSL $@vblank_joypad.VBlankWaitAndJoypad
    JSL $@vblank_joypad.EnableNmiAndJoypad
    JSL $@vblank_joypad.ForceBlank
    LDA $worldReadyFlag
    BNE loc_03DA81
    JSR $&sub_03DC92
    LDX #$000F
    STX $worldReadyFlag

  loc_03DA81:
    LDX #$0000
    STX $gfxCacheIdxB
    STX $gfxCacheIdxA
    LDA $00B4
    BEQ loc_03DAB4

  loc_03DA8F:
    JSL $@system_core.UpdateFrameDialogue
    LDA $joypadCurrent
    ORA $0657
    ORA $joypadRaw
    ORA $0661
    BEQ loc_03DA8F
    STZ $00B4
    STZ $00B5
    JSL $@vram_buffer_clear.ClearVramBufferPartial
    LDA #$01
    TSB $displayModeFlags
    JSL $@system_core.UpdateFrameDialogue

  loc_03DAB4:
    STZ $joypadInject
    STZ $09AD
    RTL 
}
---------------------------------------------

sub_03DABB {
    LDA $gfxCacheIdxA
    BEQ loc_03DAD0
    DEC 
    BEQ loc_03DAF2
    DEC 
    BEQ loc_03DAFA
    DEC 
    BEQ loc_03DB20
    DEC 
    BNE loc_03DACF
    JMP $&code_03DBA4

  loc_03DACF:
    RTS 

  loc_03DAD0:
    LDA #$0F
    STA $0DB6

  loc_03DAD5:
    LDA #$00
    XBA 
    LDA $gfxCacheIdxB
    TAX 

  loc_03DADC:
    JSL $@system_core.UpdateFrameDialogue
    LDA $0DB6
    BEQ loc_03DAF1
    DEX 
    BPL loc_03DADC
    STA $INIDISP
    DEC 
    STA $0DB6
    BPL loc_03DAD5

  loc_03DAF1:
    RTS 

  loc_03DAF2:
    JSL $@system_core.UpdateFrameDialogue
    STZ $INIDISP
    RTS 

  loc_03DAFA:
    LDA #$0F

  loc_03DAFC:
    PHA 
    LDA #$00
    XBA 
    LDA $gfxCacheIdxB
    TAX 
    PLA 

  loc_03DB05:
    JSL $@system_core.UpdateFrameDialogue
    DEX 
    BPL loc_03DB05
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
    BPL loc_03DAFC
    RTS 

  loc_03DB20:
    PHA 
    PHA 
    LDA $0070
    BNE loc_03DB2F
    LDA #$06
    STA $0070
    STZ $006E

  loc_03DB2F:
    LDA $gfxCacheIdxB
    CMP #$08
    BCC loc_03DB3B
    LDA #$08
    STA $gfxCacheIdxB

  loc_03DB3B:
    ASL 
    ASL 
    ASL 
    ASL 
    SEC 
    SBC #$80
    EOR #$FF
    INC 
    STA $01, S

  loc_03DB47:
    LDA $006E
    INC 
    STA $006E
    STA $00
    LDA $01, S
    DEC 
    STA $01, S
    BMI loc_03DB66
    PHA 
    JSL $@func_03E146
    LDA #$FF
    STA $6C
    PLA 
    JSR $&sub_03DBF6
    BRA loc_03DB47

  loc_03DB66:
    LDA #$0F
    STA $01, S

  loc_03DB6A:
    LDA $gfxCacheIdxB
    STA $02, S

  loc_03DB6F:
    LDA $006E
    STA $00
    PHA 
    JSL $@func_03E146
    LDA #$FF
    STA $6C
    PLA 
    JSR $&sub_03DBF6
    INC 
    STA $006E
    LDA $02, S
    DEC 
    STA $02, S
    BNE loc_03DB6F
    LDA $01, S
    DEC 
    STA $01, S
    STA $INIDISP
    BNE loc_03DB6A
    LDA #$00
    STA $INIDISP
    PLA 
    PLA 
    STZ $0070
    STZ $006E
    RTS 
}

code_03DBA4 {
    PHA 
    PHA 
    LDA $0070
    BNE loc_03DBB3
    LDA #$06
    STA $0070
    STZ $006E

  loc_03DBB3:
    LDA $gfxCacheIdxB
    STA $01, S
    LDA #$0F
    STA $02, S

  loc_03DBBC:
    INC $006E
    STA $00
    PHA 
    JSL $@func_03E146
    LDA #$FF
    STA $6C
    PLA 
    JSR $&sub_03DBF6
    JSL $@system_core.UpdateFrameDialogue
    LDA $01, S
    DEC 
    STA $01, S
    BNE loc_03DBBC
    LDA $gfxCacheIdxB
    STA $01, S
    LDA $02, S
    DEC 
    STA $02, S
    STA $INIDISP
    BNE loc_03DBBC
    LDA #$00
    STA $INIDISP
    PLA 
    PLA 
    STZ $0070
    STZ $006E
    RTS 
}
---------------------------------------------

sub_03DBF6 {
    PHA 
    JSR $&sub_03DC39
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
    JSL $@system_core.UpdateFrameDialogue
    PLA 
    RTS 
}
---------------------------------------------

sub_03DC39 {
    PHP 
    SEP #$20
    LDX #$0000
    TXY 
    LDA $00
    BEQ loc_03DC90
    LDA $006E
    STA $L_WRMPYA
    CLC 

  loc_03DC4C:
    LDA $&binary_01C384.binary_01C455, Y
    BPL loc_03DC52
    SEC 

  loc_03DC52:
    STA $L_WRMPYB
    NOP 
    NOP 
    NOP 
    NOP 
    LDA $RDMPYH
    BCC loc_03DC70
    PHA 
    LDA #$FF
    STA $L_WRMPYB
    XBA 
    PLA 
    CLC 
    ADC $RDMPYL
    REP #$20
    BRA loc_03DC75

  loc_03DC70:
    REP #$20
    AND #$00FF

  loc_03DC75:
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
    BNE loc_03DC4C

  loc_03DC90:
    PLP 
    RTS 
}
---------------------------------------------

sub_03DC92 {
    LDA $0649
    BEQ loc_03DCA1
    DEC 
    BEQ loc_03DCC5
    DEC 
    BEQ loc_03DCCF
    DEC 
    BEQ loc_03DCF7
    RTS 

  loc_03DCA1:
    LDA #$01
    STA $0DB6

  loc_03DCA6:
    LDA #$00
    XBA 
    LDA $064B
    TAX 

  loc_03DCAD:
    JSL $@system_core.UpdateFrameDialogue
    LDA $0DB6
    BEQ loc_03DCC4
    DEX 
    BPL loc_03DCAD
    STA $INIDISP
    INC 
    STA $0DB6
    CMP #$10
    BCC loc_03DCA6

  loc_03DCC4:
    RTS 

  loc_03DCC5:
    JSL $@system_core.UpdateFrameDialogue
    LDA #$0F
    STA $INIDISP
    RTS 

  loc_03DCCF:
    LDA #$00

  loc_03DCD1:
    PHA 
    LDA #$00
    XBA 
    LDA $064B
    TAX 
    PLA 

  loc_03DCDA:
    JSL $@system_core.UpdateFrameDialogue
    DEX 
    BPL loc_03DCDA
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
    BCC loc_03DCD1
    RTS 

  loc_03DCF7:
    LDA $0070
    BNE loc_03DD06
    LDA #$06
    STA $0070
    LDA #$80
    STA $006E

  loc_03DD06:
    LDA #$00
    PHA 

  loc_03DD09:
    LDA $064B

  loc_03DD0C:
    DEC $006E
    BEQ loc_03DD36
    STA $00
    PHA 
    JSL $@func_03E146
    LDA #$FF
    STA $6C
    PLA 
    JSR $&sub_03DBF6
    DEC 
    BNE loc_03DD0C
    LDA $01, S
    INC 
    CMP #$0F
    BCC loc_03DD2C
    LDA #$0F

  loc_03DD2C:
    STA $INIDISP
    STA $01, S
    BRA loc_03DD09

  loc_03DD33:
    LDA $064B

  loc_03DD36:
    JSL $@system_core.UpdateFrameDialogue
    DEC 
    BNE loc_03DD36
    LDA $01, S
    CMP #$0F
    BEQ loc_03DD4B
    INC 
    STA $INIDISP
    STA $01, S
    BRA loc_03DD33

  loc_03DD4B:
    STA $INIDISP
    PLA 
    STZ $0070
    STZ $006E
    RTS 
}
---------------------------------------------

func_03DD56 {
    STZ $HDMAEN
    LDX #$0000
    STX $joypadMaskInv
    STX $cachedPrevHp
    STX $cachedPrevMaxHp
    STX $displayModeFlags
    STX $playerFlags
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
    STX $playerSpeedEw
    STX $playerSpeedNs
    STX $extVelocityX
    STX $extVelocityY
    STX $enemyHealthTimer
    STX $0AEC
    STX $0AEE
    STX $climbStateData
    STX $00DA
    STX $activeActorCount
    STX $09CC
    STX $09CE
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
    JSL $@vram_buffer_clear.ClearVramBufferFull
    JSL $@scene_script.SceneScriptMain
    JSL $@func_03E050
    JSL $@event_blocks.ApplyAllEventBlocks
    JSL $@warps_interaction.PlaceBarrierTiles
    LDX #$0000
    STX $joypadMaskStd
    STX $joypadCurrent
    STX $joypadRaw
    JSL $@func_03CDDC
    JSL $@func_03CEA1
    JSL $@text_measure.MeasureDialogueWidth
    JSL $@func_03D7E7
    JSL $@func_03DFA0
    JSL $@func_03DFF8
    JSL $@zero_bytes_03D86A
    JSL $@warps_interaction.InitWarpTable
    JSL $@run_actors_03CAF5
    JSL $@run_actors_03CAF5
    JSL $@func_03E146
    JSL $@func_03D12D
    JSL $@func_03D15D
    JSL $@func_03E146
    STZ $HDMAEN
    COP [SetFlagByte] ( #FF )
    LDA #$FF
    STA $oamComposeBuffer
    STA $7F3101
    JSL $@func_03C5FF
    JSL $@func_03C714
    JSL $@func_03D881
    LDA $scrollModeFlags
    BIT #$08
    BEQ loc_03DEA2
    JSL $@scene_script.RenderPaletteTiles
    BRA loc_03DEBA

  loc_03DEA2:
    LDA $069B
    BEQ loc_03DEAE
    LDX #$0000
    JSL $@camera_tilemap.CameraFullRefresh

  loc_03DEAE:
    LDA $069D
    BEQ loc_03DEBA
    LDX #$0002
    JSL $@camera_tilemap.CameraFullRefresh

  loc_03DEBA:
    STZ $musicRoomGroup
    LDX #$0000
    STX $effectDeltaX
    STX $effectDeltaY
    STX $06E8
    STX $06EA
    RTL 
}
---------------------------------------------

func_03DECD {
    LDA $09ED
    BIT #$40
    BEQ loc_03DED5
    RTL 

  loc_03DED5:
    PHP 
    REP #$20
    PHB 
    PHK 
    PLB 
    LDY #$0000
    TYX 

  loc_03DEDF:
    LDA $&word_03DF0A, Y
    BNE loc_03DEF7
    LDA $&word_03DF0A+2, Y
    BEQ loc_03DF01
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
    BRA loc_03DEDF

  loc_03DEF7:
    STA $7F0200, X
    INX 
    INX 
    INY 
    INY 
    BRA loc_03DEDF

  loc_03DF01:
    LDA #$0001
    TSB $displayModeFlags
    PLB 
    PLP 
    RTL 
}
---------------------------------------------

word_03DF0A [
  #$0000   ;00
  #$000F   ;01
  #$340E   ;02
  #$340F   ;03
  #$0000   ;04
  #$0010   ;05
  #$2CCE   ;06
  #$2CCF   ;07
  #$0000   ;08
  #$0008   ;09
  #$ECEF   ;0A
  #$2CDA   ;0B
  #$2CDB   ;0C
  #$2CDC   ;0D
  #$341E   ;0E
  #$341F   ;0F
  #$6CDC   ;10
  #$6CDB   ;11
  #$6CDA   ;12
  #$ACEF   ;13
  #$0000   ;14
  #$0008   ;15
  #$6CCF   ;16
  #$6CCE   ;17
  #$0000   ;18
  #$0002   ;19
  #$2CDE   ;1A
  #$0000   ;1B
  #$000A   ;1C
  #$2CEA   ;1D
  #$2CD9   ;1E
  #$0000   ;1F
  #$0001   ;20
  #$2CED   ;21
  #$6CED   ;22
  #$0000   ;23
  #$0002   ;24
  #$6CEA   ;25
  #$0000   ;26
  #$000A   ;27
  #$6CDE   ;28
  #$0000   ;29
  #$0002   ;2A
  #$2CEE   ;2B
  #$0000   ;2C
  #$000A   ;2D
  #$2CFA   ;2E
  #$2CFB   ;2F
  #$2CFC   ;30
  #$2CFD   ;31
  #$6CFD   ;32
  #$2CE9   ;33
  #$6CFB   ;34
  #$6CFA   ;35
  #$0000   ;36
  #$000A   ;37
  #$6CEE   ;38
  #$0000   ;39
  #$0002   ;3A
  #$2CFE   ;3B
  #$2CEF   ;3C
  #$0000   ;3D
  #$0008   ;3E
  #$ECCF   ;3F
  #$ECCE   ;40
  #$0000   ;41
  #$0006   ;42
  #$ACCE   ;43
  #$ACCF   ;44
  #$0000   ;45
  #$0008   ;46
  #$6CEF   ;47
  #$6CFE   ;48
  #$0000   ;49
  #$0000   ;4A
]
---------------------------------------------

func_03DFA0 {
    PHP 
    REP #$20
    LDA $sceneCurrent
    AND #$00FF
    CMP #$00F7
    BEQ loc_03DFF6
    COP [CopyPalette] ( @fx_palette_198040, #01, #01, #17 )
    LDA $sceneCurrent
    AND #$00FF
    CMP #$00F0
    BEQ loc_03DFF6
    CMP #$00FD
    BEQ loc_03DFF6
    LDA $sceneCurrent
    AND #$00FF
    CMP #$00FF
    BEQ loc_03DFF6
    COP [CopyPalette] ( @fx_palette_198020, #00, #90, #10 )
    LDY #$0B40
    LDA $playerFlags
    BIT #$0008
    BEQ loc_03DFF6
    SEP #$20
    LDA #$^fx_palette_198000
    LDX #$&fx_palette_198000
    STA $0405
    REP #$20
    LDA #$001F
    JSR $0402

  loc_03DFF6:
    PLP 
    RTL 
}
---------------------------------------------

func_03DFF8 {
    PHP 
    LDA $sceneCurrent
    CMP #$F7
    BEQ loc_03E04E
    CMP #$FE
    BEQ loc_03E04E
    CMP #$8C
    BEQ loc_03E04E
    LDX #$4200
    STX $VMADDL
    LDX #$&gfx_000000
    LDA #$^gfx_000000
    LDY #$1C00
    JSL $@scene_script.DmaWordToVram
    LDA $playerFlags
    BIT #$08
    BEQ loc_03E035
    LDX #$4400
    STX $VMADDL
    LDX #$&misc_fx_1CD580
    LDA #$^misc_fx_1CD580
    LDY #$0800
    JSL $@scene_script.DmaWordToVram
    PLP 
    RTL 

  loc_03E035:
    LDA $sceneCurrent
    CMP #$E8
    BNE loc_03E04E
    LDX #$4400
    STX $VMADDL
    LDX #$&misc_fx_1CCA80
    LDA #$^misc_fx_1CCA80
    LDY #$0600
    JSL $@scene_script.DmaWordToVram

  loc_03E04E:
    PLP 
    RTL 
}
---------------------------------------------

func_03E050 {
    LDX $0652
    BNE loc_03E06F
    LDX $mapBoundsX
    STX $cameraBoundsX
    LDX $mapBoundsY
    STX $cameraBoundsY
    STX $cameraLowerYBound
    LDX #$0000
    STX $cameraOffsetX
    STX $cameraOffsetY
    BRA loc_03E094

  loc_03E06F:
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

  loc_03E094:
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
---------------------------------------------

func_03E0B0 {
    PHP 
    PHB 
    SEP #$20
    LDA #$^palette_bundles
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
    BEQ loc_03E11F
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
    BNE loc_03E11B
    LDA $7F000D, X
    INC 
    INC 
    STA $7F000D, X

  loc_03E11B:
    PLB 
    PLP 
    CLC 
    RTL 

  loc_03E11F:
    STZ $0E
    PLB 
    PLP 
    SEC 
    RTL 
}
---------------------------------------------

func_03E125 {
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
---------------------------------------------

func_03E146 {
    LDA $6C
    BMI loc_03E154
    STZ $66
    LDA #$02
    STA $68
    LDA #$10
    STA $6A

  loc_03E154:
    STZ $6C
    RTL 
}
---------------------------------------------

func_03E157 {
    PHP 
    PHX 
    SEP #$20
    PHA 
    LDA #$00
    XBA 
    PHA 
    TAX 
    LDA $&binary_01D8BE, X
    LDX $006A
    ORA #$40
    STA $DMAP0, X
    LDA $02, S
    STA $DASB0, X
    BRA loc_03E186
}
---------------------------------------------

func_03E173 {
    PHP 
    PHX 
    SEP #$20
    PHA 
    LDA #$00
    XBA 
    PHA 
    TAX 
    LDA $&binary_01D8BE, X
    LDX $006A
    STA $DMAP0, X

  loc_03E186:
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
---------------------------------------------

func_03E1AA {
    SEP #$20
    LDA #$F1
    STA $APUIO0
    REP #$20
    COP [SetEntryExit]
    LDA $APUIO0
    AND #$00FF
    CMP #$00F1
    BEQ loc_03E1C1
    RTL 

  loc_03E1C1:
    SEP #$20
    LDA #$01
    STA $APUIO0
    REP #$20
    COP [SetEntryExit]
    SEP #$20
    LDA $APUIO0
    REP #$20
    BEQ func_03E1D6
    RTL 
}
---------------------------------------------

func_03E1D6 {
    SEP #$20
    LDA #$F0
    STA $APUIO0
    REP #$20
    COP [SetEntryExit]
    SEP #$20
    LDA $APUIO0
    REP #$20
    BEQ loc_03E1EB
    RTL 

  loc_03E1EB:
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
    BEQ loc_03E208
    RTL 

  loc_03E208:
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
---------------------------------------------

func_03E21E {
    LDX $musicTransitionState
    BEQ loc_03E254
    BMI loc_03E254
    REP #$20
    TXA 
    ASL 
    CLC 
    ADC $musicTransitionState
    TAX 
    LDA $@music_array_01CBA6-3, X
    STA $46
    STA $0687
    LDA $@music_array_01CBA6-2, X
    STA $47
    STA $0688
    JSL $@vblank_joypad.EnableNmiAndJoypad
    JSL $@spc_transfer.SpcBlockTransfer
    JSL $@vblank_joypad.EnableNmiOnly
    LDA #$FFFF
    STA $musicTransitionState
    SEP #$20

  loc_03E254:
    RTL 
}
---------------------------------------------

sub_03E255 {
    PHP 
    PHD 
    PHX 
    LDA #$0000
    TCD 
    LDX $0998

  code_03E25F:
    SEP #$20
    LDA $0000, Y
    CMP #$C0
    BCC loc_03E27C
    REP #$20
    INY 
    PEA $&code_03E25F-1
    AND #$001F
    ASL 
    PHX 
    TAX 
    LDA $@wide_cmd_table_03E2C3, X
    PLX 
    DEC 
    PHA 
    RTS 

  loc_03E27C:
    REP #$20
    AND #$00FF
    INY 
    STA $00
    ORA $0986
    ORA #$2100
    LDX $0998
    STA $7F0200, X
    CLC 
    ADC #$0010
    STA $7F0240, X
    INX 
    INX 
    STX $0998
    LDA $worldReadyFlag
    BEQ code_03E25F
    LDA $00
    PHA 
    LDA #$0001
    TSB $displayModeFlags
    JSR $&code_03E7BA
    PLA 
    CMP #$00AC
    BEQ code_03E25F
    LDA $sfxQueueCh1
    AND #$FF00
    ORA $0996
    STA $sfxQueueCh1
    BRA code_03E25F
}
---------------------------------------------

wide_cmd_table_03E2C3 [
  &cmd_c0_03E2F5   ;00
  &cmd_c1_03E30F   ;01
  &cmd_c2_03E335   ;02
  &cmd_c3_03E35B   ;03
  &cmd_c4_03E36B   ;04
  &cmd_c5_03E36F   ;05
  &cmd_c6_03E393   ;06
  &cmd_c7_03E43F   ;07
  &cmd_c8_03E579   ;08
  &cmd_c9_03E5EB   ;09
  &code_03E307   ;0A
  &cmd_cb_03E5F8   ;0B
  &cmd_cc_03E61E   ;0C
  &cmd_cd_03E636   ;0D
  &cmd_ce_03E656   ;0E
  &cmd_cf_03E6A4   ;0F
  &cmd_d0_03E6D2   ;10
  &cmd_d1_03E6E7   ;11
  &cmd_d2_03E6EC   ;12
  &cmd_d3_03E6F7   ;13
  &cmd_d4_03E721   ;14
  &cmd_d5_03E736   ;15
  &cmd_d6_03E743   ;16
  &cmd_d7_03E769   ;17
  &cmd_d8_03E78F   ;18
]
---------------------------------------------

cmd_c0_03E2F5 {
    JSR $&cmd_d0_03E6D2
    JSR $&cmd_c8_03E579
    LDA #$0F00
    TRB $joypadHeld
    LDA $0B04
    STA $007E
}

code_03E307 {
    STX $0998
    PLX 
    PLX 
    PLD 
    PLP 
    RTL 
}
---------------------------------------------

cmd_c1_03E30F {
    PHY 
    LDA $0000, Y
    PHA 
    AND #$00FF
    STA $097A
    PLA 
    XBA 
    AND #$00FF
    STA $097C
    XBA 
    LSR 
    LSR 
    CLC 
    ADC $097A
    CLC 
    ADC $097A
    TAX 
    STA $0998
    PLY 
    INY 
    INY 
    RTS 
}
---------------------------------------------

cmd_c2_03E335 {
    PHP 
    PHB 
    PHY 
    LDA $0000, Y
    AND #$00FF
    ASL 
    TAY 
    SEP #$20
    LDA #$^templates_01CA95
    PHA 
    PLB 
    REP #$20
    LDA $&templates_01CA95, Y
    TAY 
    STX $0998
    JSL $@sub_03E255
    LDX $0998
    PLY 
    INY 
    PLB 
    PLP 
    RTS 
}
---------------------------------------------

cmd_c3_03E35B {
    PHY 
    LDA $0000, Y
    AND #$00FF
    XBA 
    ASL 
    ASL 
    STA $0986
    PLY 
    INY 
    RTS 
}
---------------------------------------------

cmd_c4_03E36B {
    NOP 
    NOP 
    BRA cmd_c4_03E36B
}
---------------------------------------------

cmd_c5_03E36F {
    PHY 
    STX $0998
    LDX $0002, Y
    LDA $0000, X
    ASL 
    CLC 
    ADC $0000, Y
    TAX 
    LDA $0000, X
    TAY 
    LDX $0998
    JSL $@sub_03E255
    LDX $0998
    PLY 
    INY 
    INY 
    INY 
    INY 
    RTS 
}
---------------------------------------------

cmd_c6_03E393 {
    PHY 
    LDA #$0000
    PHA 
    PHA 
    PHA 
    PHA 
    STX $0998
    LDA $0000, Y
    PHA 
    LDA $0002, Y
    PHA 

  loc_03E3A6:
    LDA $03, S
    SEC 
    SBC $07, S
    LDY #$0000

  loc_03E3AE:
    SEC 
    SBC #$0004
    BMI loc_03E3B9
    BEQ loc_03E3B9
    INY 
    BRA loc_03E3AE

  loc_03E3B9:
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

  loc_03E3CF:
    DEY 
    BEQ loc_03E3D8
    LSR 
    LSR 
    LSR 
    LSR 
    BRA loc_03E3CF

  loc_03E3D8:
    AND #$000F
    TAX 
    BNE loc_03E3E7
    LDA $05, S
    DEC 
    BEQ loc_03E3E7
    LDA $0B, S
    BEQ loc_03E40D

  loc_03E3E7:
    LDA $@binary_03E42F, X
    AND #$00FF
    ORA $0986
    ORA #$2100
    LDX $0998
    STA $7F0200, X
    CLC 
    ADC #$0010
    STA $7F0240, X
    INX 
    INX 
    STX $0998
    LDA $0B, S
    INC 
    STA $0B, S

  loc_03E40D:
    LDA $09, S
    BNE loc_03E416
    LDA $05, S
    DEC 
    BEQ loc_03E420

  loc_03E416:
    LDA $07, S
    INC 
    STA $07, S
    JSR $&code_03E7BA
    BRA loc_03E3A6

  loc_03E420:
    LDX $0998
    PLA 
    PLA 
    PLA 
    PLA 
    PLA 
    PLA 
    PLY 
    INY 
    INY 
    INY 
    INY 
    RTS 
}
---------------------------------------------

binary_03E42F #20212223242526272829404142434445
---------------------------------------------

cmd_c7_03E43F {
    LDA $0000, Y
    AND #$00FF
    STA $0982
    LDA $0001, Y
    AND #$00FF
    STA $0984
    INY 
    INY 

  code_03E453:
    PHY 
    PHX 
    LDA $0B04
    STA $007E
    LDA #$0010
    STA $0996
    STZ $00DC
    STZ $099C
    LDA $097A
    STA $097E
    LDA $097C
    STA $0980
    XBA 
    LSR 
    LSR 
    CLC 
    ADC $097A
    CLC 
    ADC $097A
    STA $099A
    STZ $0986
    LDA #$*dlg_borders_03E4CE
    STA $40
    LDA #$&dlg_borders_03E4CE
    STA $3E
    LDA $0982
    ASL 
    STA $18
    PHA 
    LDA $0984
    ASL 
    STA $1C
    LDA $0998
    DEC 
    DEC 
    SEC 
    SBC #$0040
    STA $00
    TAX 
    JSR $&sub_03E4DE
    PLX 
    PHX 
    STX $18
    JSR $&sub_03E505
    PLY 
    STY $18
    JSR $&sub_03E4DE
    LDA #$0001
    TSB $displayModeFlags
    LDA $sceneCurrent
    AND #$00FF
    CMP #$00FA
    BEQ loc_03E4CB
    JSR $&sub_03E7B2

  loc_03E4CB:
    PLX 
    PLY 
    RTS 
}
---------------------------------------------

dlg_borders_03E4CE #1020112010601220126010A011A010E0
---------------------------------------------

sub_03E4DE {
    LDA [$3E]
    STA $7F0200, X
    INX 
    INX 
    INC $3E
    INC $3E
    LDA [$3E]

  loc_03E4EC:
    STA $7F0200, X
    INX 
    INX 
    DEC $18
    BNE loc_03E4EC
    INC $3E
    INC $3E
    LDA [$3E]
    STA $7F0200, X
    INC $3E
    INC $3E
    RTS 
}
---------------------------------------------

sub_03E505 {
    PHY 
    LDY #$0002

  loc_03E509:
    LDA $00
    CLC 
    ADC #$0040
    STA $00
    TAX 
    LDA [$3E]
    STA $7F0200, X
    INX 
    INX 
    LDA $18
    STA $EC
    LDA #$2040

  loc_03E521:
    STA $7F0200, X
    INX 
    INX 
    DEC $EC
    BNE loc_03E521
    LDA [$3E], Y
    STA $7F0200, X
    DEC $1C
    BNE loc_03E509
    LDA $00
    CLC 
    ADC #$0040
    STA $00
    TAX 
    LDA $00EE
    BNE loc_03E56F
    LDA $worldReadyFlag
    AND #$00FF
    BEQ loc_03E56F
    LDA [$3E]
    STA $7F0200, X
    INX 
    INX 
    LDA #$2040

  loc_03E556:
    STA $7F0200, X
    INX 
    INX 
    DEC $18
    BNE loc_03E556
    LDA [$3E], Y
    STA $7F0200, X
    LDA $00
    CLC 
    ADC #$0040
    STA $00
    TAX 

  loc_03E56F:
    LDA $3E
    CLC 
    ADC #$0004
    STA $3E
    PLY 
    RTS 
}
---------------------------------------------

cmd_c8_03E579 {
    PHY 
    PHB 
    LDA $099A
    STA $0998
    LDA $0982
    ASL 
    INC 
    STA $00
    STA $18
    LDA $0984
    INC 
    ASL 
    STA $1C
    LDA $099A
    SEC 
    SBC #$0042
    STA $099A
    TAX 

  loc_03E59C:
    LDA #$0000

  loc_03E59F:
    STA $7F0200, X
    INX 
    INX 
    DEC $18
    BPL loc_03E59F
    LDA $00
    STA $18
    LDA $099A
    CLC 
    ADC #$0040
    STA $099A
    TAX 
    DEC $1C
    BPL loc_03E59C
    PHX 
    LDX #$0022
    LDA #$675D
    STA $cgramPalette, X
    LDA #$10F2
    STA $7F0A02, X
    LDA #$0000
    STA $7F0A04, X
    PLX 
    LDA #$0001
    TSB $displayModeFlags
    JSR $&sub_03E7B2
    LDX $0998
    STX $099A
    STZ $099C
    PLB 
    PLY 
    RTS 
}
---------------------------------------------

cmd_c9_03E5EB {
    PHY 
    LDA $0000, Y
    AND #$00FF
    JSR $&code_03E7B5
    PLY 
    INY 
    RTS 
}
---------------------------------------------

cmd_cb_03E5F8 {
    LDA $099C
    INC 
    CMP $0984
    BNE loc_03E610
    JSR $&sub_03E7D6
    JSR $&sub_03E7B2
    JSR $&sub_03E7D6
    JSR $&sub_03E7B2
    LDA $099C

  loc_03E610:
    STA $099C
    XBA 
    LSR 
    CLC 
    ADC $099A
    STA $0998
    TAX 
    RTS 
}
---------------------------------------------

cmd_cc_03E61E {
    PHY 
    LDA $0000, Y
    AND #$00FF
    LSR 
    BEQ loc_03E633
    ASL 
    PHA 
    TXA 
    CLC 
    ADC $01, S
    TAX 
    STA $0998
    PLA 

  loc_03E633:
    PLY 
    INY 
    RTS 
}
---------------------------------------------

cmd_cd_03E636 {
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
    STX $0998
    JSL $@sub_03E255
    LDX $0998
    PLB 
    PLY 
    INY 
    INY 
    INY 
    RTS 
}
---------------------------------------------

cmd_ce_03E656 {
    LDA $0998
    LDA $0982
    ASL 
    DEC 
    STA $00
    STA $18
    LDA $0984
    DEC 
    STA $1C
    LDA $099A
    STA $02
    TAX 

  loc_03E66E:
    LDA #$2040

  loc_03E671:
    STA $7F0200, X
    STA $7F0240, X
    INX 
    INX 
    DEC $18
    BPL loc_03E671
    LDA $00
    STA $18
    LDA $02
    CLC 
    ADC #$0080
    STA $02
    TAX 
    DEC $1C
    BPL loc_03E66E
    LDA $099A
    STA $0998
    TAX 
    STZ $099C
    LDA #$0001
    TSB $displayModeFlags
    JSR $&sub_03E7B2
    RTS 
}
---------------------------------------------

cmd_cf_03E6A4 {
    LDA #$C080
    TSB $joypadHeld

  loc_03E6AA:
    JSR $&sub_03E7B2
    LDA $joypadCurrent
    AND #$C080
    BNE loc_03E6C1
    SEC 
    JSR $&sub_03E80C
    LDA #$0001
    TSB $displayModeFlags
    BRA loc_03E6AA

  loc_03E6C1:
    STA $joypadHeld
    CLC 
    JSR $&sub_03E80C
    LDA #$0001
    TSB $displayModeFlags
    JSR $&cmd_ce_03E656
    RTS 
}
---------------------------------------------

cmd_d0_03E6D2 {
    LDA #$CFF0
    TSB $joypadHeld

  loc_03E6D8:
    JSR $&sub_03E7B2
    LDA $joypadCurrent
    AND #$CFFF
    BEQ loc_03E6D8
    STA $joypadHeld
    RTS 
}
---------------------------------------------

cmd_d1_03E6E7 {
    LDA $0000, Y
    TAY 
    RTS 
}
---------------------------------------------

cmd_d2_03E6EC {
    LDA $0000, Y
    INY 
    AND #$00FF
    STA $0996
    RTS 
}
---------------------------------------------

cmd_d3_03E6F7 {
    LDA #$000D
    STA $0982
    LDA #$0004
    STA $0984
    LDA #$0003
    STA $097A
    LDA #$0011
    STA $097C
    XBA 
    LSR 
    LSR 
    CLC 
    ADC $097A
    CLC 
    ADC $097A
    TAX 
    STA $0998
    JMP $&code_03E453
}
---------------------------------------------

cmd_d4_03E721 {
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
---------------------------------------------

cmd_d5_03E736 {
    LDA $0000, Y
    INY 
    INC 
    INC 
    AND #$00FF
    STA $007E
    RTS 
}
---------------------------------------------

cmd_d6_03E743 {
    PHP 
    PHB 
    PHY 
    LDA $0000, Y
    AND #$00FF
    ASL 
    TAY 
    SEP #$20
    LDA #$^dictionary_01EBA8
    PHA 
    PLB 
    REP #$20
    LDA $&dictionary_01EBA8, Y
    TAY 
    STX $0998
    JSL $@sub_03E255
    LDX $0998
    PLY 
    INY 
    PLB 
    PLP 
    RTS 
}
---------------------------------------------

cmd_d7_03E769 {
    PHP 
    PHB 
    PHY 
    LDA $0000, Y
    AND #$00FF
    ASL 
    TAY 
    SEP #$20
    LDA #$^dictionary_01F54D
    PHA 
    PLB 
    REP #$20
    LDA $&dictionary_01F54D, Y
    TAY 
    STX $0998
    JSL $@sub_03E255
    LDX $0998
    PLY 
    INY 
    PLB 
    PLP 
    RTS 
}
---------------------------------------------

cmd_d8_03E78F {
    LDA $0000, Y
    INY 
    AND #$00FF
    BEQ loc_03E7AE
    ORA $0986
    ORA #$2100
    STA $7F0200, X
    CLC 
    ADC #$0010
    STA $7F0240, X
    INX 
    INX 
    BRA cmd_d8_03E78F

  loc_03E7AE:
    STX $0998
    RTS 
}
---------------------------------------------

sub_03E7B2 {
    LDA #$0001
}

code_03E7B5 {
    PHP 
    SEP #$20
    BRA loc_03E7C2
}

code_03E7BA {
    PHP 
    SEP #$20
    LDA $007E
    BEQ loc_03E7D4

  loc_03E7C2:
    PHA 
    LDA $worldReadyFlag
    BNE loc_03E7CC
    PLA 
    PLP 
    RTS 
}

code_03E7CB {
    PHA 

  loc_03E7CC:
    JSL $@system_core.UpdateFrameDialogue
    PLA 
    DEC 
    BNE code_03E7CB

  loc_03E7D4:
    PLP 
    RTS 
}
---------------------------------------------

sub_03E7D6 {
    LDA $099A
    STA $00
    TAX 
    LDA $0984
    ASL 
    DEC 
    STA $1C

  loc_03E7E3:
    LDA $0982
    ASL 
    DEC 
    STA $18

  loc_03E7EA:
    LDA $7F0240, X
    STA $7F0200, X
    INX 
    INX 
    DEC $18
    BPL loc_03E7EA
    LDA $00
    CLC 
    ADC #$0040
    STA $00
    TAX 
    DEC $1C
    BPL loc_03E7E3
    LDA #$0001
    TSB $displayModeFlags
    RTS 
}
---------------------------------------------

sub_03E80C {
    PHP 
    LDA $0984
    ASL 
    CLC 
    ADC $0980
    ASL 
    ASL 
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $0982
    CLC 
    ADC $097E
    ASL 
    TAX 
    PLP 
    BCC loc_03E83F
    LDA $36
    BIT #$000F
    BNE loc_03E831
    INC $0994

  loc_03E831:
    LDA $0994
    BIT #$0001
    BEQ loc_03E83F
    LDA #$2091
    PHA 
    BRA loc_03E843

  loc_03E83F:
    LDA #$2040
    PHA 

  loc_03E843:
    PLA 
    STA $7F0200, X
    RTS 
}
---------------------------------------------

func_03E849 {
    PHD 
    PHX 
    PHA 
    LDA #$0000
    TCD 
    PHA 
    STA $0994

  code_03E854:
    JSR $&sub_03E983
    JSR $&sub_03E7B2
    LDA $joypadCurrent
    BIT #$CF80
    BEQ code_03E854
    PHA 
    LDA #$CFF0
    TSB $joypadHeld
    PLA 
    BIT #$0800
    BNE loc_03E8C6
    BIT #$0400
    BEQ loc_03E877
    JMP $&code_03E8FC

  loc_03E877:
    BIT #$0300
    BEQ loc_03E87F
    JMP $&code_03E93C

  loc_03E87F:
    BIT #$8080
    BNE loc_03E892
    BIT #$4000
    BEQ code_03E854
    JSR $&sub_03EA2A
    PLA 
    LDA #$0000
    BRA loc_03E8B3

  loc_03E892:
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
    STZ $0994
    JSR $&sub_03E983
    PLA 
    INC 

  loc_03E8B3:
    PHA 
    JSR $&sub_03E7B2
    PLA 
    STZ $0994
    STZ $0990
    STZ $0992
    PLY 
    PLX 
    PLD 
    SEC 
    RTL 

  loc_03E8C6:
    SEP #$20
    LDA #$10
    STA $sfxQueueCh2
    REP #$20
    STZ $0994
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
    BMI loc_03E8EE
    STA $01, S
    REP #$20
    JMP $&code_03E854

  loc_03E8EE:
    LDA $18
    BNE loc_03E8F4
    LDA $1C

  loc_03E8F4:
    DEC 
    STA $01, S
    REP #$20
    JMP $&code_03E854
}

code_03E8FC {
    SEP #$20
    LDA #$10
    STA $sfxQueueCh2
    REP #$20
    STZ $0994
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
    BCS loc_03E92E
    INC 
    CMP $1C
    BCS loc_03E925
    BRA loc_03E927

  loc_03E925:
    LDA #$00

  loc_03E927:
    STA $01, S
    REP #$20
    JMP $&code_03E854

  loc_03E92E:
    INC 
    CMP $18
    BCC loc_03E935
    LDA $1C

  loc_03E935:
    STA $01, S
    REP #$20
    JMP $&code_03E854
}

code_03E93C {
    STZ $0994
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
    BCS loc_03E969
    CLC 
    ADC $1C
    CMP $18
    BCC loc_03E95E
    LDA $01, S

  loc_03E95E:
    STA $01, S
    CMP $1C
    REP #$20
    BCS loc_03E977
    JMP $&code_03E854

  loc_03E969:
    SEC 
    SBC $1C
    STA $01, S
    CMP $1C
    REP #$20
    BCC loc_03E977
    JMP $&code_03E854

  loc_03E977:
    SEP #$20
    LDA #$10
    STA $sfxQueueCh2
    REP #$20
    JMP $&code_03E854
}
---------------------------------------------

sub_03E983 {
    LDA $0994
    INC 
    STA $0994
    BIT #$0010
    BNE loc_03E99B
    LDA #$212C
    STA $00
    LDA #$213C
    STA $02
    BRA loc_03E9A2

  loc_03E99B:
    LDA #$21AC
    STA $00
    STA $02

  loc_03E9A2:
    LDA $0990
    BEQ loc_03E9B8
    LDX $098E
    LDA $0990
    STA $7F0200, X
    LDA $0992
    STA $7F0240, X

  loc_03E9B8:
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
    BCC loc_03E9DC
    SEC 
    SBC $1C
    STA $1C
    STZ $1D
    LDX #$0018
    STX $18
    BRA loc_03E9E5

  loc_03E9DC:
    STA $1C
    STZ $1D
    LDX #$0000
    STX $18

  loc_03E9E5:
    REP #$20
    LDA $06, S
    AND #$00FF
    CLC 
    ADC $1C
    ASL 
    CLC 
    ADC $0980
    ASL 
    ASL 
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $097E
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
    STX $098E
    PLA 
    STA $0992
    PLA 
    STA $0990
    LDA #$0001
    TSB $displayModeFlags
    RTS 
}
---------------------------------------------

sub_03EA2A {
    PHY 
    LDX $098E
    LDA $0990
    STA $7F0200, X
    AND #$03FF
    ASL 
    ASL 
    ASL 
    ORA #$6000
    STA $090E
    LDA $0992
    STA $7F0240, X
    AND #$03FF
    ASL 
    ASL 
    ASL 
    ORA #$6000
    STA $0910
    STZ $0990
    STZ $0992
    LDA #$0001
    TSB $displayModeFlags
    PLY 
    RTS 
}
---------------------------------------------

func_03EA62 {
    PHP 
    PHB 

  loc_03EA64:
    SEP #$20
    LDA $0000, Y
    INY 
    CMP #$12
    BCS loc_03EA7C
    REP #$20
    PHX 
    AND #$00FF
    ASL 
    TAX 
    JSR ($&asciistring_cmd_table_03EA8C, X)
    PLX 
    BRA loc_03EA64

  loc_03EA7C:
    STA $7F0200, X
    XBA 
    LDA $sceneStateHelper
    STA $7F0201, X
    INX 
    INX 
    BRA loc_03EA64
}
---------------------------------------------

asciistring_cmd_table_03EA8C [
  &cmd_00_03EC52   ;00
  &cmd_01_03ED00   ;01
  &cmd_02_03ED0B   ;02
  &cmd_03_03ED2B   ;03
  &cmd_04_03ED3C   ;04
  &cmd_05_03ED6F   ;05
  &cmd_06_03EDE3   ;06
  &cmd_07_03EEA5   ;07
  &cmd_08_03EEF5   ;08
  &cmd_09_03EF3E   ;09
  &cmd_0A_03EB1B   ;0A
  &cmd_0B_03EBFC   ;0B
  &cmd_0C_03EF1F   ;0C
  &cmd_0D_03EC57   ;0D
  &cmd_0E_03EC64   ;0E
  &cmd_0F_03EAE2   ;0F
  &cmd_10_03EABD   ;10
  &cmd_11_03EAB0   ;11
]
---------------------------------------------

cmd_11_03EAB0 {
    LDA $09A0
    CLC 
    ADC #$0040
    STA $09A0
    STA $03, S
    RTS 
}
---------------------------------------------

cmd_10_03EABD {
    PHY 
    PHB 
    LDA $06, S
    TAX 
    LDA $0000, Y
    AND #$00FF
    ASL 
    PHA 
    SEP #$20
    LDA #$^itemcomp_table_01EB0F
    PHA 
    PLB 
    REP #$20
    PLY 
    LDA $&itemcomp_table_01EB0F, Y
    TAY 
    JSL $@func_03EA62
    TXA 
    STA $06, S
    PLB 
    PLY 
    INY 
    RTS 
}
---------------------------------------------

cmd_0F_03EAE2 {
    PHY 
    LDA $05, S
    STA $00
    TAX 
    LDA $0000, Y
    AND #$00FF
    STA $0E
    STA $10
    LDA $0001, Y
    STA $12

  loc_03EAF7:
    LDA #$0000

  loc_03EAFA:
    STA $7F0200, X
    INX 
    INX 
    DEC $10
    BPL loc_03EAFA
    DEC $12
    BMI loc_03EB17
    LDA $00
    CLC 
    ADC #$0040
    STA $00
    TAX 
    LDA $0E
    STA $10
    BRA loc_03EAF7

  loc_03EB17:
    PLY 
    INY 
    INY 
    RTS 
}
---------------------------------------------

cmd_0A_03EB1B {
    PHY 
    STZ $08
    LDA $playerMaxHp
    CMP #$0029
    BMI loc_03EB3A
    LDA #$0028
    STA $playerMaxHp
    LDA $playerHp
    CMP #$0029
    BMI loc_03EB3A
    LDA #$0028
    STA $playerHp

  loc_03EB3A:
    LDA $playerHp
    LSR 
    STA $00
    BCC loc_03EB44
    INC $08

  loc_03EB44:
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
    BCS loc_03EB64
    INC $02

  loc_03EB64:
    LDA #$0800
    STA $0004
    LDA $05, S
    JSR $&sub_03EB71
    PLY 
    RTS 
}
---------------------------------------------

sub_03EB71 {
    TAX 
    LDY #$000A
    STZ $06
    LDA $00
    BEQ loc_03EB93
    LDA #$2006
    ORA $0004

  loc_03EB81:
    STA $7F0200, X
    INX 
    INX 
    DEY 
    BNE loc_03EB8D
    JSR $&sub_03EBE6

  loc_03EB8D:
    DEC $00
    BEQ loc_03EB93
    BRA loc_03EB81

  loc_03EB93:
    LDA $08
    BEQ loc_03EBA8
    LDA #$2007
    ORA $04
    STA $7F0200, X
    INX 
    INX 
    DEY 
    BNE loc_03EBA8
    JSR $&sub_03EBE6

  loc_03EBA8:
    LDA $02
    BEQ loc_03EBC3
    LDA #$20FF
    ORA $04

  loc_03EBB1:
    STA $7F0200, X
    INX 
    INX 
    DEY 
    BNE loc_03EBBD
    JSR $&sub_03EBE6

  loc_03EBBD:
    DEC $02
    BEQ loc_03EBC3
    BRA loc_03EBB1

  loc_03EBC3:
    LDA $06
    BNE loc_03EBD9
    LDA #$0000

  loc_03EBCA:
    STA $7F0200, X
    INX 
    INX 
    DEY 
    BNE loc_03EBCA
    JSR $&sub_03EBE6
    LDY #$000A

  loc_03EBD9:
    LDA #$0000

  loc_03EBDC:
    STA $7F0200, X
    INX 
    INX 
    DEY 
    BNE loc_03EBDC
    RTS 
}
---------------------------------------------

sub_03EBE6 {
    PHA 
    TXA 
    CLC 
    ADC #$002C
    TAX 
    STA $06
    CMP #$0100
    BCS loc_03EBF9
    PLA 
    LDY #$000A
    RTS 

  loc_03EBF9:
    PLA 
    PLA 
    RTS 
}
---------------------------------------------

cmd_0B_03EBFC {
    PHY 
    STZ $0008
    LDA $enemyHpDisplay
    CMP #$0029
    BMI loc_03EC1C
    LDA #$0028
    STA $enemyHpDisplay
    LDA $09E6
    CMP #$0029
    BMI loc_03EC1C
    LDA #$0028
    STA $09E6

  loc_03EC1C:
    LDA $09E6
    LSR 
    STA $00
    BCC loc_03EC26
    INC $08

  loc_03EC26:
    ASL 
    CLC 
    ADC $08
    SEC 
    SBC $enemyHpDisplay
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
    SBC $enemyHpDisplay
    BCS loc_03EC46
    INC $02

  loc_03EC46:
    LDA #$0400
    STA $04
    LDA $05, S
    JSR $&sub_03EB71
    PLY 
    RTS 
}
---------------------------------------------

cmd_00_03EC52 {
    PLA 
    PLX 
    PLB 
    PLP 
    RTL 
}
---------------------------------------------

cmd_0D_03EC57 {
    LDA $09A0
    CLC 
    ADC #$0080
    STA $09A0
    STA $03, S
    RTS 
}
---------------------------------------------

cmd_0E_03EC64 {
    PHY 
    LDA $05, S
    TAX 
    STZ $0006
    STZ $0000
    LDA $099E
    ORA #$0030
    STA $0004
    LDA $0000, Y
    TAY 
    LDA $0000, Y
    SEC 

  loc_03EC7F:
    INC $0000
    SBC #$0064
    BCS loc_03EC7F
    ADC #$0064
    STA $0002
    LDA $0000
    DEC 
    CMP #$0009
    BCC loc_03EC99
    LDA #$0009

  loc_03EC99:
    BIT #$000F
    BEQ loc_03ECA6
    ORA $0004
    INC $0006
    BRA loc_03ECA9

  loc_03ECA6:
    LDA #$2000

  loc_03ECA9:
    STZ $0000
    LDA $0002
    SEC 

  loc_03ECB0:
    INC $0000
    SBC #$000A
    BCS loc_03ECB0
    ADC #$000A
    STA $0002
    LDA $0000
    DEC 
    BNE loc_03ECD1
    LDA $0006
    BNE loc_03ECCE
    LDA #$2000
    BRA loc_03ECD4

  loc_03ECCE:
    LDA #$0000

  loc_03ECD1:
    ORA $0004

  loc_03ECD4:
    STZ $0000
    STA $7F0200, X
    INX 
    INX 
    LDA $0002
    SEC 

  loc_03ECE1:
    INC $0000
    SBC #$0001
    BCS loc_03ECE1
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
---------------------------------------------

cmd_01_03ED00 {
    LDA $0000, Y
    INY 
    INY 
    STA $09A0
    STA $03, S
    RTS 
}
---------------------------------------------

cmd_02_03ED0B {
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
    JSL $@func_03EA62
    PLB 
    PLY 
    INY 
    INY 
    INY 
    TXA 
    STA $03, S
    RTS 
}
---------------------------------------------

cmd_03_03ED2B {
    SEP #$20
    LDA $sceneStateHelper
    AND #$E3
    ORA $0000, Y
    INY 
    STA $sceneStateHelper
    REP #$20
    RTS 
}
---------------------------------------------

cmd_04_03ED3C {
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
    JSL $@func_03EA62
    PLB 
    PLA 
    CLC 
    ADC #$0005
    TAY 
    TXA 
    STA $03, S
    RTS 
}
---------------------------------------------

cmd_05_03ED6F {
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
    LDA $099E
    SEP #$20

  loc_03ED90:
    LDA $0000, Y
    AND #$0F
    ORA #$30
    REP #$20
    DEX 
    DEX 
    STA $7F0200, X
    SEP #$20
    DEC $000E
    BEQ loc_03EDC1
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
    BNE loc_03ED90

  loc_03EDC1:
    DEC $0010
    BEQ loc_03EDD8
    LDA $7F0200, X
    CMP #$30
    BNE loc_03EDD8
    LDA #$20
    STA $7F0200, X
    INX 
    INX 
    BRA loc_03EDC1

  loc_03EDD8:
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
---------------------------------------------

cmd_06_03EDE3 {
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
    LDA $099E
    ORA #$0010
    STA $7F0200, X
    LDA $0000
    STA $000E
    LDA $099E
    ORA #$0011

  loc_03EE11:
    STA $7F0202, X
    INX 
    INX 
    DEC $000E
    BNE loc_03EE11
    LDA $099E
    ORA #$4010
    STA $7F0202, X
    LDA $01, S
    CLC 
    ADC #$0040
    TAX 
    LDA $0002
    STA $000E

  loc_03EE33:
    PHX 
    LDA $099E
    ORA #$0012
    STA $7F0200, X
    LDA $0000
    STA $0010
    LDA $099E
    ORA #$0040

  loc_03EE4A:
    STA $7F0202, X
    INX 
    INX 
    DEC $0010
    BNE loc_03EE4A
    LDA $099E
    ORA #$4012
    STA $7F0202, X
    PLA 
    CLC 
    ADC #$0040
    TAX 
    DEC $000E
    BNE loc_03EE33
    LDA $099E
    ORA #$8010
    STA $7F0200, X
    LDA $0000
    STA $000E
    LDA $099E
    ORA #$8011

  loc_03EE80:
    STA $7F0202, X
    INX 
    INX 
    DEC $000E
    BNE loc_03EE80
    LDA $099E
    ORA #$C010
    STA $7F0202, X
    PLA 
    PLY 
    CLC 
    ADC #$0082
    STA $09A0
    STA $03, S
    INY 
    INY 
    INY 
    INY 
    RTS 
}
---------------------------------------------

cmd_07_03EEA5 {
    PHY 
    LDA $0000, Y
    TAX 
    STZ $0000
    SEP #$20
    PHX 

  loc_03EEB0:
    LDA $7F0200, X
    BEQ loc_03EEBD
    INX 
    INX 
    INC $0000
    BRA loc_03EEB0

  loc_03EEBD:
    DEC $0000
    REP #$20
    PLX 

  loc_03EEC3:
    LDA $0000
    STA $000E
    PHX 
    LDA #$0000

  loc_03EECD:
    STA $7F0200, X
    INX 
    INX 
    DEC $000E
    BNE loc_03EECD
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
    BNE loc_03EEC3
    PLY 
    INY 
    INY 
    RTS 
}
---------------------------------------------

cmd_08_03EEF5 {
    PHY 
    LDA $0001, Y
    TAX 
    LDA $0000, X
    PHA 
    LDA $07, S
    TAX 
    LDA $099E
    SEP #$20
    LDA $0000, Y
    REP #$20
    PLY 
    BEQ loc_03EF17

  loc_03EF0E:
    STA $7F0200, X
    INX 
    INX 
    DEY 
    BNE loc_03EF0E

  loc_03EF17:
    PLY 
    INY 
    INY 
    INY 
    TXA 
    STA $03, S
    RTS 
}
---------------------------------------------

cmd_0C_03EF1F {
    LDA $03, S
    TAX 

  loc_03EF22:
    LDA $0000, Y
    AND #$00FF
    CMP #$00FF
    BEQ loc_03EF39
    ORA $099E
    STA $7F0200, X
    INX 
    INX 
    INY 
    BRA loc_03EF22

  loc_03EF39:
    INY 
    TXA 
    STA $03, S
    RTS 
}
---------------------------------------------

cmd_09_03EF3E {
    LDA $03, S
    TAX 
    LDA #$0000
    PHA 
    PHY 

  loc_03EF46:
    SEP #$20
    LDA $0000, Y
    BMI loc_03EF8A
    REP #$20
    AND #$00FF
    CMP #$0008
    BCS loc_03EF5D
    ASL 
    ORA #$01E0
    BRA loc_03EF65

  loc_03EF5D:
    SEC 
    SBC #$0008
    ASL 
    ORA #$02E0

  loc_03EF65:
    ORA $099E
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
    BRA loc_03EF46

  loc_03EF8A:
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
---------------------------------------------

func_03EF97 {
    PHP 
    SEP #$20
    BIT #$80
    BNE loc_03EFB3
    PHA 
    LDY #$0000

  loc_03EFA2:
    LDA $inventorySlots, Y
    BNE loc_03EFAA
    JMP $&code_03F070

  loc_03EFAA:
    INY 
    CPY #$0010
    BNE loc_03EFA2
    JMP $&code_03F080

  loc_03EFB3:
    SEC 
    SBC #$80
    BEQ loc_03F00C
    DEC 
    BEQ loc_03F032
    DEC 
    BNE loc_03EFC1
    JMP $&code_03F051

  loc_03EFC1:
    DEC 
    BEQ loc_03EFE9
    DEC 
    BEQ loc_03EFED
    DEC 
    BEQ loc_03EFF1
    REP #$20
    LDA #$0005
    CLC 
    ADC $damageFlashTimer
    STA $damageFlashTimer
    PHD 
    TXA 
    TCD 
    COP [SpawnLastRel] ( @SpawnHitSparkSprites, #00, #00, #$2F00 )
    PLD 
    COP [PlaySoundCh2] ( #22 )
    JMP $&code_03F07D

  loc_03EFE9:
    LDA #$01
    BRA loc_03EFF3

  loc_03EFED:
    LDA #$02
    BRA loc_03EFF3

  loc_03EFF1:
    LDA #$05

  loc_03EFF3:
    REP #$20
    AND #$00FF
    CLC 
    ADC $gemCount
    CMP #$03E7
    BCC loc_03F004
    LDA #$03E7

  loc_03F004:
    STA $gemCount
    COP [PlaySoundCh2] ( #22 )
    BRA code_03F07D

  loc_03F00C:
    REP #$20
    LDA #$0080
    TRB $displayModeFlags
    SEP #$20
    COP [PlaySoundCh2] ( #25 )
    LDA $playerMaxHp
    CLC 
    ADC #$01
    BVC loc_03F023
    LDA #$55

  loc_03F023:
    STA $playerMaxHp
    SEC 
    SBC $playerHp
    STA $damageFlashTimer
    LDY #$0000
    BRA code_03F07D

  loc_03F032:
    REP #$20
    LDA #$0080
    TRB $displayModeFlags
    SEP #$20
    COP [PlaySoundCh2] ( #25 )
    LDA $playerStr
    CLC 
    ADC #$01
    BVC loc_03F049
    LDA #$55

  loc_03F049:
    STA $playerStr
    LDY #$0000
    BRA code_03F07D
}

code_03F051 {
    REP #$20
    LDA #$0080
    TRB $displayModeFlags
    SEP #$20
    COP [PlaySoundCh2] ( #25 )
    LDA $playerDef
    CLC 
    ADC #$01
    BVC loc_03F068
    LDA #$55

  loc_03F068:
    STA $playerDef
    LDY #$0000
    BRA code_03F07D
}

code_03F070 {
    PLA 
    STA $inventorySlots, Y
    STA $0DB8
    STZ $0DB9
    LDY #$&itemget_table_01FD24.widestring_01FF1F
}

code_03F07D {
    PLP 
    CLC 
    RTL 
}

code_03F080 {
    PLA 
    STA $0DB8
    STZ $0DB9
    LDY #$&itemget_table_01FD24.widestring_01FF02
    PLP 
    SEC 
    RTL 
}
---------------------------------------------

func_03F08D {
    PHP 
    SEP #$20
    LDY #$0000

  loc_03F093:
    CMP $inventorySlots, Y
    BEQ loc_03F0A0
    INY 
    CPY #$0010
    BNE loc_03F093
    BRA loc_03F0B1

  loc_03F0A0:
    LDA #$00
    STA $inventorySlots, Y
    REP #$20
    LDA #$0000
    STA $inventoryEquippedType
    DEC 
    STA $inventoryEquippedIndex

  loc_03F0B1:
    PLP 
    RTL 
}
---------------------------------------------

func_03F0B3 {
    PHP 
    SEP #$20
    LDY #$0000

  loc_03F0B9:
    CMP $inventorySlots, Y
    BEQ loc_03F0C7
    INY 
    CPY #$0010
    BNE loc_03F0B9
    PLP 
    SEC 
    RTL 

  loc_03F0C7:
    PLP 
    CLC 
    RTL 
}
---------------------------------------------

func_03F0CA {
    PHP 
    REP #$20
    TXY 
    LDX $playerActor
    LDA $playerFlags
    BMI loc_03F0F1

  loc_03F0D6:
    LDA $0028, X
    TAX 
    LDA $@binary_03F11F, X
    AND #$00FF
    CMP #$0004
    BPL loc_03F0EA
    TYX 
    PLP 
    CLC 
    RTL 

  loc_03F0EA:
    TYX 
    PLP 
    SEC 
    RTL 
}

code_03F0EE {
    PLY 
    BRA loc_03F0D6

  loc_03F0F1:
    PHY 
    TXY 
    LDA $0AC8
    AND #$00FF
    SEC 
    SBC #$0004
    BMI code_03F0EE
    ASL 
    TAX 
    LDA $@table_03F177, X
    SEC 
    SBC #$&table_03F177
    CLC 
    ADC $0028, Y
    TAX 
    PLY 
    LDA $@table_03F177, X
    AND #$00FF
    CMP #$0004
    BPL loc_03F0EA
    TYX 
    PLP 
    CLC 
    RTL 
}
---------------------------------------------

binary_03F11F #00010203000102030001020300010203000102030001020300000000000101010202020303030101000001000100010002030203020300010203000102030001020302030001020300010404040404040001020304040404
---------------------------------------------

table_03F177 [
  &binary_03F17F   ;00
  &binary_03F19A   ;01
  &binary_03F1C6   ;02
  &binary_03F1CA   ;03
]

binary_03F17F #000102030001020300010203000000010101020202030303040404

binary_03F19A #0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

binary_03F1C6 #00000000

binary_03F1CA #000000000000
---------------------------------------------

func_03F1D0 {
    PHP 
    REP #$20
    LDA $7F0C07
    BEQ loc_03F1FF
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

  loc_03F1FF:
    PLP 
    RTL 
}