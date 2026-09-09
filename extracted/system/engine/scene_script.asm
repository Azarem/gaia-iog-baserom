?BANK 02

?INCLUDE 'cop_handlers_script'
?INCLUDE 'decompress'
?INCLUDE 'hardware_math'
?INCLUDE 'spc_transfer'
?INCLUDE 'system_init'
?INCLUDE 'table_018000'

!sceneCurrent                   0644
!mapRowStrideL0                 0693
!mapRowStrideL1                 0695
!mapTilemapBaseA                069E
!layerPriorityFlag              06EE
!scrollModeFlags                06EF
!S_metatileMapLayer             2000
!VMAIN                          2115
!VMADDL                         2116
!S_metatileEffectLayer          2800
!MDMAEN                         420B
!DMAP0                          4300
!BBAD0                          4301
!A1T0L                          4302
!A1B0                           4304
!DAS0L                          4305
!S_tileStagingBuffer            7000
!animScratch                    7F0000
!cgramPalette                   7F0A00
!S_mapLayerTilemap              A000

---------------------------------------------

DmaWordToVram {
    STX $A1T0L
    STA $A1B0
    STY $DAS0L
    LDA #$01
    STA $DMAP0
    LDA #$18
    STA $BBAD0
    LDA #$01
    STA $MDMAEN
    RTL 
}

SceneScriptMain {
    PHP 
    SEP #$20
    JSR $&FindCurrentScene

  code_0283C1:
    JSR $&ReadScriptByte
    CMP #$00
    BEQ loc_0283DB
    PEA $&code_0283C1-1
    REP #$20
    AND #$00FF
    ASL 
    TAX 
    LDA $@scene_script_jump_table, X
    DEC 
    PHA 
    SEP #$20
    RTS 

  loc_0283DB:
    LDA $sceneCurrent
    CMP #$F7
    BEQ loc_0283E5
    JSR $&ReloadMapData

  loc_0283E5:
    PLP 
    RTL 
}

SceneScriptNoMusic {
    PHP 
    SEP #$20
    JSR $&FindCurrentScene

  code_0283ED:
    JSR $&ReadScriptByte
    CMP #$00
    BEQ loc_028414
    PEA $&code_0283ED-1
    REP #$20
    AND #$00FF
    ASL 
    TAX 
    LDA $@scene_script_jump_table, X
    CMP #$&spc_transfer.SpcMusicLoadCmd
    BEQ loc_02840C
    DEC 
    PHA 
    SEP #$20
    RTS 

  loc_02840C:
    INY 
    INY 
    INY 
    INY 
    INY 
    SEP #$20
    RTS 

  loc_028414:
    PLP 
    RTL 
}

scene_script_jump_table [
  &code_02845C   ;00
  &code_02845C   ;01
  &SceneCmd_ConfigDisplay   ;02
  &SceneCmd_LoadBgTiles   ;03
  &SceneCmd_LoadTilemap   ;04
  &SceneCmd_LoadDualTilemap   ;05
  &SceneCmd_FullGraphics   ;06
  &code_02845C   ;07
  &code_02845C   ;08
  &code_02845C   ;09
  &code_02845C   ;0A
  &code_02845C   ;0B
  &code_02845C   ;0C
  &code_02845C   ;0D
  &SceneCmd_Skip3   ;0E
  &code_02845C   ;0F
  &SceneCmd_LoadSpriteTiles   ;10
  &spc_transfer.SpcMusicLoadCmd   ;11
  &code_02845C   ;12
  &SceneCmd_ConditionalLoad   ;13
  &SceneCmd_Nop   ;14
  &SkipScriptCommands   ;15
  &code_02845C   ;16
  &SceneCmd_LoadCharTiles   ;17
]

SceneCmd_ConditionalLoad {
    PHP 
    REP #$20
    JSR $&ReadScriptByte
    PHY 
    JSL $@cop_handlers_script.TestFlagRaw
    PLY 
    BCC loc_028458
    PLP 
    JMP $&SkipScriptCommands

  loc_028458:
    INY 
    PLP 
    RTS 
}

SceneCmd_Nop {
    INY 
}

code_02845C {
    RTS 
}

SceneCmd_LoadBgTiles {
    PHP 
    REP #$20
    JSR $&ReadScriptByte
    XBA 
    ASL 
    STA $0664
    JSR $&ReadScriptByte
    XBA 
    ASL 
    STA $0666
    JSR $&ReadScriptByte
    STA $0668
    LDX #$003E
    JSR $&LoadScriptPointer
    JSR $&ReadScriptByte
    CMP #$0000
    BEQ loc_02848D
    DEC 
    BEQ loc_0284BC
    DEC 
    BEQ loc_0284E7
    DEC 
    BEQ loc_0284F3

  loc_02848D:
    LDA $0668
    BIT #$0010
    BNE loc_0284B0
    CLC 
    ADC #$0020
    STA $0668
    LDX #$066C
    LDA $0666
    SEC 
    SBC $0664
    CMP #$2001
    BMI loc_0284FC
    STZ $0670
    BRA loc_0284FC

  loc_0284B0:
    CLC 
    ADC #$0020
    STA $0668
    LDX #$066F
    BRA loc_0284FC

  loc_0284BC:
    LDA $0668
    BIT #$0010
    BNE loc_0284DB
    CLC 
    ADC #$0040
    STA $0668
    BIT #$0028
    BEQ loc_0284D3
    STZ $0676

  loc_0284D3:
    STZ $0673
    LDX #$0672
    BRA loc_0284FC

  loc_0284DB:
    CLC 
    ADC #$0040
    STA $0668
    LDX #$0675
    BRA loc_0284FC

  loc_0284E7:
    LDA $0668
    CLC 
    ADC #$0060
    STA $0668
    BRA loc_028503

  loc_0284F3:
    LDA $0668
    STA $0668
    JMP $&Load4bppPage

  loc_0284FC:
    JSR $&CheckSourceCacheHit
    BCS loc_028503
    PLP 
    RTS 

  loc_028503:
    LDA [$3E]
    INC $3E
    INC $3E
    STA $78
    CMP #$0000
    BEQ CheckInterleavedFlag
    CPX #$066C
    BNE loc_028520
    LDA $layerPriorityFlag
    BIT #$0800
    BEQ loc_028520
    JMP $&DeinterleavePlanarTiles

  loc_028520:
    JSR $&GraphicsCacheLookup
    BCC loc_02852A
    JSR $&RestoreCachedVram
    PLP 
    RTS 

  loc_02852A:
    JSR $&GraphicsCacheStore
    LDA $78
    CMP #$2001
    BCC loc_028537
    STZ $067F

  loc_028537:
    LDX #$7000
    STX $7A
    JSL $@decompress.QuintetLzDecompress
    LDX #$7000
    STX $3E
    LDA #$007E
    STA $40
    JSR $&SceneDmaTileShim
    JSR $&SaveVramToRingBuffer
    PLP 
    RTS 
}

SceneDmaTileShim {
    PHP 
    BRA DmaTileStripToVram

  CheckInterleavedFlag:
    LDA $layerPriorityFlag
    BIT #$0800
    BEQ DmaTileStripToVram
    JMP $&code_0285F3

  DmaTileStripToVram:
    LDA $0668
    XBA 
    STA $VMADDL
    LDA $3E
    CLC 
    ADC $0664
    STA $A1T0L
    LDA $0666
    SEC 
    SBC $0664
    STA $DAS0L
    SEP #$20
    LDA #$01
    STA $DMAP0
    LDA #$18
    STA $BBAD0
    LDA $40
    STA $A1B0
    LDA #$01
    STA $MDMAEN
    PLP 
    RTS 
}

Load4bppPage {
    LDA [$3E]
    STA $78
    INC $3E
    INC $3E
    CMP #$0000
    BEQ loc_0285B2
    LDX #$7000
    STX $7A
    JSL $@decompress.QuintetLzDecompress
    LDX #$7000
    STX $3E
    LDA #$007E
    STA $40

  loc_0285B2:
    SEP #$20
    LDX #$2000
    STX $VMADDL
    LDA #$00
    STA $DMAP0
    LDA #$19
    STA $BBAD0
    LDX $3E
    STX $A1T0L
    LDA $40
    STA $A1B0
    LDX #$4000
    STX $DAS0L
    LDA #$01
    STA $MDMAEN
    PLP 
    RTS 
}

DeinterleavePlanarTiles {
    STZ $0670
    STZ $067F
    STZ $0682
    STZ $0679
    STZ $067C
    LDX #$7000
    STX $7A
    JSL $@decompress.QuintetLzDecompress
}

code_0285F3 {
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
    JSR $&BuildAttributeTable

  loc_028608:
    LDA #$07
    STA $12
    LDA ($3E)
    STA $10
    INC $3E
    BNE loc_028616
    INC $3F

  loc_028616:
    LDA $S_tileStagingBuffer, X
    STA $00
    LDA $7001, X
    STA $02
    LDA $7010, X
    STA $04
    LDA $7011, X
    STA $06
    LDY #$0007

  loc_02862D:
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
    BNE loc_028645
    INC $5F

  loc_028645:
    DEY 
    BPL loc_02862D
    INX 
    INX 
    DEC $12
    BPL loc_028616
    REP #$20
    TXA 
    CLC 
    ADC #$0010
    TAX 
    SEP #$20
    CPX #$2000
    BCC loc_028608
    PLB 
    LDX #$0000
    STX $VMADDL
    LDA #$80
    STA $VMAIN
    LDA #$00
    STA $DMAP0
    LDA #$19
    STA $BBAD0
    LDX #$A000
    STX $A1T0L
    LDA #$7E
    STA $A1B0
    LDX #$4000
    STX $DAS0L
    LDA #$01
    STA $MDMAEN
    PLY 
    PLP 
    RTS 
}

BuildAttributeTable {
    PHP 
    REP #$20
    LDA #$0000
    TAY 

  loc_028693:
    STA $S_metatileEffectLayer, Y
    INY 
    INY 
    CPY #$0100
    BCC loc_028693
    LDY #$2800
    STY $3E
    LDY #$0000
    SEP #$20

  loc_0286A7:
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
    BCC loc_0286A7
    LDY #$2800
    STY $3E
    PLP 
    RTS 
}

SceneCmd_LoadTilemap {
    PHP 
    REP #$20
    JSR $&ReadScriptByte
    ASL 
    STA $0664
    JSR $&ReadScriptByte
    ASL 
    STA $0666
    JSR $&ReadScriptByte
    ASL 
    STA $0668
    CMP #$0020
    BEQ loc_0286F5
    LDX #$003E
    JSR $&LoadScriptPointer
    LDX #$0A00
    STX $42
    LDA #$007F
    STA $44
    JSR $&DmaRomToWram
    PLP 
    RTS 

  loc_0286F5:
    LDX #$003E
    JSR $&LoadScriptPointer
    LDX #$0A00
    STX $42
    LDA #$007F
    STA $44
    JSR $&DmaRomToWram
    LDA $7F0A20
    STA $cgramPalette
    PLP 
    RTS 
}

SceneCmd_LoadDualTilemap {
    PHP 
    REP #$20
    JSR $&ReadScriptByte
    XBA 
    LSR 
    LSR 
    STA $0664
    JSR $&ReadScriptByte
    XBA 
    LSR 
    LSR 
    STA $0666
    JSR $&ReadScriptByte
    XBA 
    LSR 
    LSR 
    STA $0668
    JSR $&ReadScriptByte
    STA $066A
    LDX #$003E
    JSR $&LoadScriptPointer
    LDA #$0001
    AND $066A
    BEQ loc_028752
    LDX #$0678
    JSR $&CheckSourceCacheHit
    BCS loc_028752
    LDA #$0001
    TRB $066A

  loc_028752:
    LDA #$0002
    AND $066A
    BEQ loc_028768
    LDX #$067B
    JSR $&CheckSourceCacheHit
    BCS loc_028768
    LDA #$0002
    TRB $066A

  loc_028768:
    LDA $066A
    BEQ loc_0287BA
    LDA [$3E]
    STA $78
    INC $3E
    INC $3E
    BEQ loc_02878A
    LDX #$7000
    STX $7A
    JSL $@decompress.QuintetLzDecompress
    LDX #$7000
    STX $3E
    LDA #$007E
    STA $40

  loc_02878A:
    LSR $066A
    BCC loc_0287A2
    LDX #$2000
    STX $42
    LDA #$007E
    STA $44
    JSR $&DmaRomToWram
    LDX #$0000
    JSR $&RebuildTilemapAttrs

  loc_0287A2:
    LSR $066A
    BCC loc_0287BA
    LDX #$2800
    STX $42
    LDA #$007E
    STA $44
    JSR $&DmaRomToWram
    LDX #$0002
    JSR $&RebuildTilemapAttrs

  loc_0287BA:
    PLP 
    RTS 
}

SceneCmd_FullGraphics {
    STZ $0664
    STZ $0665
    JSR $&ReadScriptByte
    STA $066A
    LDX #$003E
    JSR $&LoadScriptPointer
    LDA $066A
    AND #$7F
    BEQ loc_02880D
    LDA #$01
    AND $066A
    BEQ loc_0287F0
    LDA $06EF
    BIT #$08
    BNE loc_028818
    LDX #$067E
    JSR $&CheckSourceCacheHit
    BCS loc_0287F0
    LDA #$01
    TRB $066A

  loc_0287F0:
    LDA #$02
    AND $066A
    BEQ loc_028804
    LDX #$0681
    JSR $&CheckSourceCacheHit
    BCS loc_028804
    LDA #$02
    TRB $066A

  loc_028804:
    LDA $066A
    AND #$7F
    BEQ loc_02883C
    BRA loc_028818

  loc_02880D:
    LDA $066A
    BMI loc_028818
    STZ $067F
    STZ $0680

  loc_028818:
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
    BNE loc_02883A
    JMP $&DmaLowVramTileset

  loc_02883A:
    BRA loc_02883D

  loc_02883C:
    RTS 

  loc_02883D:
    REP #$20
    LDA [$3E]
    STA $78
    STA $0666
    INC $3E
    INC $3E
    CMP #$0000
    BEQ HandleEmptyGeometry
    SEP #$20
    LDA $066A
    BIT #$01
    BEQ loc_02888E
    LDX #$0000
    JSR $&StoreMapAndDecompress
    LDA $066A
    BIT #$02
    BEQ loc_028894
    LDX #$A000
    STX $3E
    LDA #$7E
    STA $40
    LDX #$C000
    STX $42
    LDA #$7E
    STA $44
    JSR $&DmaRomToWram
    LDA $01
    STA $0695
    XBA 
    LDA $03
    STA $0699
    JSL $@hardware_math.SignedMultiply
    STA $069D
    BRA loc_028894

  loc_02888E:
    LDX #$0002
    JSR $&StoreMapAndDecompress

  loc_028894:
    RTS 
}

StoreMapAndDecompress {
    LDA $01
    STA $0693, X
    XBA 
    LDA $03
    STA $0697, X
    JSL $@hardware_math.SignedMultiply
    STA $069B, X
    REP #$20
    LDA $069E, X
    STA $7A
    JSL $@decompress.QuintetLzDecompress
    SEP #$20
    RTS 

  HandleEmptyGeometry:
    SEP #$20
    LDA $01
    XBA 
    LDA $03
    JSL $@hardware_math.SignedMultiply
    STZ $0666
    STA $0667
    LDA $066A
    BIT #$01
    BEQ loc_028904
    LDX #$A000
    STX $42
    LDA #$7E
    STA $44
    LDX #$0000
    JSR $&WriteMapBounds
    LDA $066A
    BIT #$02
    BEQ loc_028913
    LDX #$A000
    STX $3E
    LDA #$7E
    STA $40
    LDX #$C000
    STX $42
    LDA #$7E
    STA $44
    JSR $&DmaRomToWram
    LDX $00
    STX $0694
    LDX $02
    STX $0698
    BRA loc_028913

  loc_028904:
    LDX #$C000
    STX $42
    LDA #$7E
    STA $44
    LDX #$0002
    JSR $&WriteMapBounds

  loc_028913:
    RTS 
}

WriteMapBounds {
    REP #$20
    LDA $00
    STA $0692, X
    LDA $02
    STA $0696, X
    JSR $&DmaRomToWram
    SEP #$20
    RTS 
}

DmaLowVramTileset {
    REP #$20
    LDA [$3E]
    INC $3E
    INC $3E
    STA $78
    CMP #$0000
    BNE loc_028943
    SEP #$20
    LDX $3E
    STX $4302
    LDA $40
    STA $4304
    BRA loc_028959

  loc_028943:
    SEP #$20
    LDX #$A000
    STX $7A
    JSL $@decompress.QuintetLzDecompress
    LDX #$A000
    STX $4302
    LDA #$7E
    STA $4304

  loc_028959:
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

RenderPaletteTiles {
    PHY 
    PHB 
    LDA #$7E
    PHA 
    PLB 
    LDX #$0000
    REP #$20

  loc_028988:
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
    BCC loc_028988
    SEP #$20
    LDA $0693
    STA $18
    LDA $0697
    CMP #$05
    BCC loc_0289B2
    LDA #$04

  loc_0289B2:
    STA $1C
    LDA #$00
    STA $0E
    STA $10
    LDY #$0000
    TYX 
    STX $00

  loc_0289C0:
    REP #$20
    TYA 
    CLC 
    ADC #$0100
    STA $14
    SEP #$20

  loc_0289CB:
    LDA #$0F
    STA $12

  loc_0289CF:
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
    BPL loc_0289CF
    REP #$20
    TXA 
    CLC 
    ADC #$00E0
    TAX 
    SEP #$20
    CPY $14
    BCC loc_0289CB
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
    BCC loc_0289C0
    STZ $0E
    LDA $10
    INC 
    STA $10
    CMP $1C
    BCS loc_028A3C
    REP #$20
    AND #$00FF
    XBA 
    ASL 
    ASL 
    ASL 
    ASL 
    STA $00
    TAX 
    BRA loc_0289C0

  loc_028A3C:
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

SceneCmd_ConfigDisplay {
    JSR $&ReadScriptByte
    PHY 
    REP #$20
    AND #$00FF
    ASL 
    TAX 
    LDA $@table_018000, X
    SEC 
    SBC #$&table_018000
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
    BCC loc_028AC1
    STY $06A2

  loc_028AC1:
    ROR 
    BCC loc_028AC7
    STY $06A4

  loc_028AC7:
    ROR 
    ROR 
    ROR 
    ROR 
    ROR 
    LDY #$00E0
    BCC loc_028AD4
    LDY #$0100

  loc_028AD4:
    STY $06EC
    ROR 
    BCS loc_028ADF
    LDA #$01
    TSB $06A5

  loc_028ADF:
    REP #$20
    LDA $06A2
    CMP $06A6
    BEQ loc_028AEC
    STZ $0679

  loc_028AEC:
    STA $06A6
    LDA $06A4
    CMP $06A8
    BEQ loc_028AFA
    STZ $067C

  loc_028AFA:
    STA $06A8
    SEP #$20
    LDA $@table_018000+5, X
    STA $06EE
    BMI loc_028B22
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
    BRA loc_028B3A

  loc_028B22:
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

  loc_028B3A:
    LDA $@table_018000+6, X
    STA $2105
    LDA $@table_018000+7, X
    PHA 
    AND #$1F
    STA $06EF
    BIT #$08
    BEQ loc_028B52
    STZ $066E

  loc_028B52:
    LDA #$40
    TRB $09ED
    PLA 
    BPL loc_028B5F
    LDA #$40
    TSB $09ED

  loc_028B5F:
    LDA $@table_018000+8, X
    LDA $@table_018000+9, X
    PLY 
    RTS 
}

SceneCmd_Skip3 {
    INY 
    INY 
    INY 
    RTS 
}
---------------------------------------------

SceneCmd_LoadSpriteTiles {
    PHP 
    REP #$20
    LDA [$3A], Y
    STA $0666
    SEP #$20
    INY 
    INY 
    INY 
    LDX #$003E
    JSR $&LoadScriptPointer
    LDX #$0684
    JSR $&CheckSourceCacheHit
    BCC loc_028C19
    REP #$20
    LDA [$3E]
    INC $3E
    INC $3E
    CMP #$0000
    BEQ loc_028C1B
    STA $78
    SEP #$20
    LDX #$4000
    STX $7A
    JSL $@decompress.QuintetLzDecompress

  loc_028C19:
    PLP 
    RTS 

  loc_028C1B:
    STZ $0664
    STZ $0668
    LDX #$4000
    STX $42
    LDA #$007E
    STA $44
    JSR $&DmaRomToWram
    PLP 
    RTS 
}

SceneCmd_LoadCharTiles {
    PHP 
    JSR $&ReadScriptByte
    STA $066A
    LDX #$003E
    JSR $&LoadScriptPointer
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
    JSL $@hardware_math.SignedMultiply
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
    BEQ loc_028C81
    STA $78
    SEP #$20
    LDX #$7000
    STX $7A
    JSL $@decompress.QuintetLzDecompress
    LDX #$7000
    STX $3E
    LDA #$7E
    STA $40
    BRA loc_028C87

  loc_028C81:
    INC $3E
    INC $3E
    SEP #$20

  loc_028C87:
    LDA $066A
    BPL loc_028C9A
    AND #$7F
    XBA 
    LDA #$00
    REP #$20
    ASL 
    ASL 
    STA $VMADDL
    BRA loc_028CC4

  loc_028C9A:
    REP #$20
    AND #$00FF
    BIT #$0001
    BEQ code_028CB0
    LDA #$1000
    STA $VMADDL
    PEA $&code_028CB0-1
    PHP 
    BRA loc_028CC4
}

code_028CB0 {
    REP #$20
    LDA $066A
    BIT #$0002
    BEQ loc_028CC2
    LDA #$1800
    STA $VMADDL
    BRA loc_028CC4

  loc_028CC2:
    PLP 
    RTS 

  loc_028CC4:
    SEP #$20
    LDA #$01
    STA $DMAP0
    LDA #$18
    STA $BBAD0
    LDX $3E
    STX $A1T0L
    LDA $40
    STA $A1B0
    LDX $0666
    STX $DAS0L
    LDA #$01
    STA $MDMAEN
    PLP 
    RTS 
}

ReadScriptByte {
    PHP 
    SEP #$20
    LDA #$00
    XBA 
    LDA [$3A], Y
    INY 
    PLP 
    RTS 
}

FindCurrentScene {
    LDY #$0000

  loc_028CF5:
    LDA [$3A], Y
    INY 
    INY 
    CMP $0644
    BNE loc_028CFF
    RTS 

  loc_028CFF:
    SEP #$20
    LDA [$3A], Y
    INY 
    CMP #$00
    BEQ loc_028CF5
    CMP #$13
    BEQ loc_028D39
    CMP #$02
    BEQ loc_028D3A
    CMP #$03
    BEQ loc_028D34
    CMP #$04
    BEQ loc_028D35
    CMP #$05
    BEQ loc_028D34
    CMP #$06
    BEQ loc_028D37
    CMP #$0E
    BEQ loc_028D38
    CMP #$10
    BEQ loc_028D35
    CMP #$11
    BEQ loc_028D36
    CMP #$14
    BEQ loc_028D3A
    CMP #$15
    BEQ loc_028D3A

  loc_028D34:
    INY 

  loc_028D35:
    INY 

  loc_028D36:
    INY 

  loc_028D37:
    INY 

  loc_028D38:
    INY 

  loc_028D39:
    INY 

  loc_028D3A:
    INY 
    BRA loc_028CFF
}

SkipScriptCommands {
    JSR $&ReadScriptByte
    PHA 
    LDY #$0000

  loc_028D44:
    INY 
    INY 

  loc_028D46:
    LDA [$3A], Y
    INY 
    CMP #$00
    BEQ loc_028D44
    CMP #$02
    BEQ loc_028D83
    CMP #$03
    BEQ loc_028D7D
    CMP #$04
    BEQ loc_028D7E
    CMP #$05
    BEQ loc_028D7D
    CMP #$06
    BEQ loc_028D80
    CMP #$0E
    BEQ loc_028D81
    CMP #$10
    BEQ loc_028D7E
    CMP #$11
    BEQ loc_028D7F
    CMP #$12
    BEQ loc_028D8D
    CMP #$13
    BEQ loc_028D82
    CMP #$14
    BEQ loc_028D86
    CMP #$15
    BEQ loc_028D83

  loc_028D7D:
    INY 

  loc_028D7E:
    INY 

  loc_028D7F:
    INY 

  loc_028D80:
    INY 

  loc_028D81:
    INY 

  loc_028D82:
    INY 

  loc_028D83:
    INY 
    BRA loc_028D46

  loc_028D86:
    LDA [$3A], Y
    INY 
    CMP $01, S
    BNE loc_028D46

  loc_028D8D:
    PLA 
    RTS 
}

LoadScriptPointer {
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
    BCS loc_028DBF
    CLC 
    ADC #$80
    CMP #$A0
    BCC loc_028DBC
    CLC 
    ADC #$20
    STA $0002, X
    LDA $0001, X
    AND #$7F
    STA $0001, X
    BRA loc_028DBF

  loc_028DBC:
    STA $0002, X

  loc_028DBF:
    PLP 
    RTS 
}

CheckSourceCacheHit {
    PHP 
    REP #$20
    LDA $3E
    CMP $0000, X
    BNE loc_028DD9
    SEP #$20
    LDA $40
    CMP $0002, X
    BNE loc_028DD9
    REP #$20
    PLP 
    CLC 
    RTS 

  loc_028DD9:
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

DmaRomToWram {
    PHP 
    PHY 
    SEP #$20
    LDA $3E
    CMP #$80
    BCC loc_028E43
    CMP #$C0
    BCS loc_028E01
    REP #$20
    LDA $3E
    CMP #$8000
    BCC loc_028E43

  loc_028E01:
    REP #$20
    LDA $0666
    SEC 
    SBC $0664
    STA $4305
    LDA $3E
    CLC 
    ADC $0664
    STA $4302
    LDA $42
    CLC 
    ADC $0668
    STA $2181
    SEP #$20
    LDA $44
    CMP #$7F
    LDA #$00
    ADC #$00
    STA $2183
    LDA #$00
    STA $4300
    LDA #$80
    STA $4301
    LDA $40
    STA $4304
    LDA #$01
    STA $420B
    PLY 
    PLP 
    RTS 

  loc_028E43:
    PHX 
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
    TAY 
    LDA $0666
    SEC 
    SBC $0664
    DEC 
    JSR $0402
    PLX 
    PLY 
    PLP 
    RTS 
}

GraphicsCacheLookup {
    LDX #$0000

  loc_028E72:
    LDA $3E
    CMP $0084, X
    BEQ loc_028E83

  loc_028E79:
    INX 
    INX 
    INX 
    CPX #$000C
    BNE loc_028E72
    CLC 
    RTS 

  loc_028E83:
    SEP #$20
    LDA $40
    CMP $0086, X
    BEQ loc_028E90
    REP #$20
    BRA loc_028E79

  loc_028E90:
    REP #$20
    SEC 
    RTS 
}

GraphicsCacheStore {
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

SaveVramToRingBuffer {
    PHY 
    LDA $0668
    XBA 
    STA $2116
    LDA $0666
    CMP #$2001
    BMI loc_028ED4
    SEC 
    SBC #$2000
    STA $0666
    LDA #$2000
    BRA loc_028ED7

  loc_028ED4:
    STZ $0666

  loc_028ED7:
    JSR $&DmaVramToRam
    LDA $0666
    BEQ loc_028F16
    PHA 
    LDY $0094
    TYA 
    INC 
    CMP #$0004
    BCC loc_028EED
    LDA #$0000

  loc_028EED:
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
    JSR $&DmaVramToRam

  loc_028F16:
    PLY 
    RTS 
}

DmaVramToRam {
    PHP 
    STA $4305
    JSR $&ComputeRingBufferAddr
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

ComputeRingBufferAddr {
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

RestoreCachedVram {
    PHY 
    LDA $@system_init.CacheSlotIndices, X
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
    BCS loc_028F7B
    TAY 
    JSR $&DmaWramToVram
    PLA 
    PLY 
    RTS 

  loc_028F7B:
    SEC 
    SBC #$2000
    PHA 
    LDA #$2000
    TAY 
    JSR $&DmaWramToVram
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
    JSR $&DmaWramToVram
    PLA 
    PLY 
    RTS 
}

DmaWramToVram {
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

RebuildTilemapAttrs {
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

  loc_028FE6:
    LDA #$04
    STA $10

  loc_028FEA:
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
    BNE loc_028FEA
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
    BNE loc_028FE6
    PLY 
    PLB 
    PLP 
    RTS 
}

ReloadMapData {
    LDX #$0000
    JSR $&ReloadMapLayer0
    LDA $scrollModeFlags
    BIT #$01
    BEQ loc_029033
    LDX #$0002
    JSR $&ReloadMapLayer1

  loc_029033:
    RTS 
}

ReloadMapLayer0 {
    LDY $06AA
    STY $3E
    LDA #$7F
    STA $40
    LDA $mapRowStrideL0
    XBA 
    LDA $0697
    JSL $@hardware_math.SignedMultiply
    XBA 
    TAY 
    BEQ loc_02905F
    LDX $mapTilemapBaseA

  loc_02904F:
    LDA $7E0000, X
    STA $3E
    LDA [$3E]
    STA $7F2000, X
    INX 
    DEY 
    BNE loc_02904F

  loc_02905F:
    RTS 
}

ReloadMapLayer1 {
    LDY $06AC
    STY $3E
    LDA #$7F
    STA $40
    LDA $mapRowStrideL1
    XBA 
    LDA $0699
    JSL $@hardware_math.SignedMultiply
    XBA 
    TAY 
    BEQ loc_02908D
    LDX $0080

  loc_02907B:
    LDA $7E0000, X
    STA $3E
    LDA [$3E]
    BEQ loc_029089
    STA $animScratch, X

  loc_029089:
    INX 
    DEY 
    BNE loc_02907B

  loc_02908D:
    RTS 
}