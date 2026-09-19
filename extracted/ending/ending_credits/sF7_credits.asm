?BANK 09

?INCLUDE 'CreditPositionLookup'
?INCLUDE 'sF7_credits_misc_timeline'

!joypadMaskStd                  065A
!cameraTargetX                  06BE
!cameraTargetY                  06C2
!sceneStateHelper               099F
!displayModeFlags               09EC
!BG3SC                          2109
!W12SEL                         2123
!TM                             212C
!TS                             212D
!CGWSEL                         2130
!CGADSUB                        2131
!COLDATA                        2132
!mapLayerTilemap                7EA000
!effectLayerTilemap             7EC000
!mode7Tilemap                   7EE000
!thinkerExtendedData            7EF000
!cgramPalette                   7F0A00
!vramCacheRing                  7F4000
!decompressStaging              7F7000
!collisionLayer                 7FC000
!invBackupActors                7FE000
!invBackupSystem                7FF000

---------------------------------------------

sF7_credits [
  actor-def < #00, #00, #38, {

  code_09D650:
    LDA #$0080
    STA $00F6
    LDA #$007F
    STA $00FA
    STZ $00FE
    DEC $00FE
    STZ $09F6
    LDA #$FFFF
    STA $00E4
    LDA #$4001
    TSB $displayModeFlags
    SEP #$20
    LDA #$33
    STA $W12SEL
    LDA #$02
    STA $CGWSEL
    LDA #$00
    STA $TM
    STA $TS
    REP #$20
    LDA #$0000
    STA $cgramPalette
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [Decompress] ( @gfx_sc02_main_characters, $7EE000 )
    LDY #$4000
    JSR $&code_09DB4B
    COP [Decompress] ( @gfx_credits_actors1, $7EE000 )
    LDY #$6000
    JSR $&code_09DB4B
    COP [Decompress] ( @gfx_credits_actors2, $7EE000 )
    LDY #$8000
    JSR $&code_09DB4B
    COP [Decompress] ( @gfx_credits_actors3, $7EA000 )
    LDY #$C000
    JSR $&code_09DB59
    COP [Decompress] ( @gfx_credits_scenery, $7EA000 )
    COP [Decompress] ( @file_002380, $7EE000 )
    STZ $0084
    STZ $0086
    STZ $0088
    STZ $008A
    STZ $0094
    COP [Decompress] ( @spm_credits, $7E6000 )
    COP [AdhocVramDma] ( $7F0200, #$7C00, #$0800 )
    COP [PaletteStart] ( #0B )
    COP [PaletteStep]
    COP [StartMusic] ( #14 )
    STZ $cameraTargetX
    STZ $cameraTargetY
    COP [SpawnLastRel] ( @code_09E9D2, #00, #00, #$2000 )
    COP [SpawnLastRel] ( @code_09E919, #00, #00, #$2000 )
    STZ $00E4
    COP [CallScript] ( &code_09E934 )
    COP [HaltIfCounterGte] ( #$00C8 )
    SEP #$20
    LDA #$10
    STA $TM
    REP #$20
    COP [AdhocVramDma] ( $7FC000, #$2000, #$0800 )
    COP [AdhocVramDma] ( $7FC800, #$2400, #$0800 )
    COP [AdhocVramDma] ( $7FD000, #$2800, #$0800 )
    COP [AdhocVramDma] ( $7FD800, #$2C00, #$0800 )
    COP [AdhocVramDma] ( $7FE000, #$3000, #$0800 )
    COP [AdhocVramDma] ( $7FE800, #$3400, #$0800 )
    COP [AdhocVramDma] ( $7FF000, #$3800, #$0800 )
    COP [AdhocVramDma] ( $7FF800, #$3C00, #$0800 )
    COP [AdhocVramDma] ( $7EE000, #$1180, #$0200 )
    COP [AdhocVramDma] ( $7EE200, #$1980, #$0200 )
    COP [CopyPalette] ( @palette_1E094C, #00, #00, #80 )
    COP [HaltIfCounterGte] ( #$0CA8 )
    COP [SpawnLastRel] ( @code_09F4AA, #00, #00, #$2000 )
    COP [HaltIfCounterGte] ( #$11BC )
    COP [SpawnLastRel] ( @code_09F4ED, #00, #00, #$2000 )
    COP [HaltIfCounterGte] ( #$1FF4 )
    COP [AdhocVramDma] ( $7EE400, #$1180, #$0200 )
    COP [AdhocVramDma] ( $7EE600, #$1980, #$0200 )
    COP [SpawnLastRel] ( @code_09F4AA, #00, #00, #$2000 )
    COP [HaltIfCounterGte] ( #$251C )
    COP [SpawnLastRel] ( @code_09F4ED, #00, #00, #$2000 )
    COP [HaltIfCounterGte] ( #$2710 )
    COP [AdhocVramDma] ( $7EE800, #$1180, #$0200 )
    COP [AdhocVramDma] ( $7EEA00, #$1980, #$0200 )
    COP [SpawnLastRel] ( @code_09F4AA, #00, #00, #$2000 )
    COP [HaltIfCounterGte] ( #$2CEC )
    COP [SpawnLastRel] ( @code_09F4ED, #00, #00, #$2000 )
    COP [HaltIfCounterGte] ( #$2FA8 )
    COP [AdhocVramDma] ( $7EEC00, #$1180, #$0200 )
    COP [AdhocVramDma] ( $7EEE00, #$1980, #$0200 )
    COP [SpawnLastRel] ( @code_09F4AA, #00, #00, #$2000 )
    COP [WaitByte] ( #3F )
    SEP #$20
    LDA #$41
    STA $CGADSUB
    LDA #$02
    STA $TS
    REP #$20
    COP [HaltIfCounterGte] ( #$3200 )
    COP [SpawnLastRel] ( @code_09F4ED, #00, #00, #$2000 )
    SEP #$20
    LDA #$83
    STA $CGADSUB
    LDA #$00
    STA $TS
    REP #$20
    COP [HaltIfCounterGte] ( #$3264 )
    COP [SpawnLastRel] ( @code_09E62F, #00, #00, #$0500 )
    COP [HaltIfCounterGte] ( #$32E4 )
    COP [SpawnLastRel] ( @code_09E637, #00, #00, #$0500 )
    COP [HaltIfCounterGte] ( #$32FC )
    COP [SpawnLastRel] ( @code_09E62F, #00, #00, #$0500 )
    COP [HaltIfCounterGte] ( #$3396 )
    COP [SpawnLastRel] ( @code_09E62F, #00, #00, #$0500 )
    COP [HaltIfCounterGte] ( #$344A )
    COP [SpawnLastRel] ( @code_09E637, #00, #00, #$0500 )
    COP [HaltIfCounterGte] ( #$37B4 )
    COP [SpawnLastRel] ( @sF7_credits_misc_timeline.code_09E65D, #00, #00, #$0500 )
    COP [HaltIfCounterGte] ( #$39FC )
    COP [SpawnLastRel] ( @sF7_credits_misc_timeline.code_09E67C, #00, #00, #$2500 )
    COP [HaltIfCounterGte] ( #$3C8C )
    COP [CallScript] ( &code_09E9A4 )
    COP [AdhocVramDma] ( $7EA000, #$2000, #$0800 )
    COP [AdhocVramDma] ( $7EA800, #$2400, #$0800 )
    COP [AdhocVramDma] ( $7EB000, #$2800, #$0800 )
    COP [AdhocVramDma] ( $7EB800, #$2C00, #$0800 )
    COP [AdhocVramDma] ( $7EC000, #$3000, #$0800 )
    COP [AdhocVramDma] ( $7EC800, #$3400, #$0800 )
    COP [AdhocVramDma] ( $7ED000, #$3800, #$0800 )
    COP [AdhocVramDma] ( $7ED800, #$3C00, #$0800 )
    COP [AdhocVramDma] ( $7EF000, #$1180, #$0200 )
    COP [AdhocVramDma] ( $7EF200, #$1980, #$0200 )
    COP [CopyPalette] ( @palette_1E0A6C, #00, #00, #80 )
    COP [HaltIfCounterGte] ( #$3CF0 )
    COP [SpawnLastRel] ( @code_09F4AA, #00, #00, #$2000 )
    COP [HaltIfCounterGte] ( #$3D46 )
    COP [SpawnLastRel] ( @func_09F69F, #00, #00, #$2000 )
    COP [SetEntryExit]
    SEP #$20
    LDA #$01
    STA $CGADSUB
    LDA #$02
    STA $TS
    REP #$20
    COP [HaltIfCounterGte] ( #$3F48 )
    SEP #$20
    LDA #$83
    STA $CGADSUB
    LDA #$00
    STA $TS
    REP #$20
    COP [SpawnLastRel] ( @code_09F4ED, #00, #00, #$2000 )
    COP [HaltIfCounterGte] ( #$4920 )
    COP [CallScript] ( &code_09E962 )
    COP [AdhocVramDma] ( $7EF400, #$1180, #$0200 )
    COP [AdhocVramDma] ( $7EF600, #$1980, #$0200 )
    COP [HaltIfCounterGte] ( #$4AA1 )
    COP [SpawnLastRel] ( @code_09F4AA, #00, #00, #$2000 )
    COP [HaltIfCounterGte] ( #$4CF9 )
    COP [SpawnLastRel] ( @code_09F4ED, #00, #00, #$2000 )
    COP [HaltIfCounterGte] ( #$500C )
    COP [SpawnLastRel] ( @sF7_credits_misc_timeline.code_09E68D, #00, #00, #$0500 )
    COP [HaltIfCounterGte] ( #$5208 )
    COP [SpawnLastRel] ( @sF7_credits_misc_timeline.code_09E6A5, #00, #00, #$0500 )
    COP [HaltIfCounterGte] ( #$526C )
    COP [AdhocVramDma] ( $7EF800, #$1180, #$0200 )
    COP [AdhocVramDma] ( $7EFA00, #$1980, #$0200 )
    COP [HaltIfCounterGte] ( #$52D0 )
    COP [SpawnLastRel] ( @code_09F4AA, #00, #00, #$2000 )
    COP [HaltIfCounterGte] ( #$5366 )
    COP [SpawnLastRel] ( @code_09F4ED, #00, #00, #$2000 )
    COP [HaltIfCounterGte] ( #$5398 )
    COP [SpawnLastRel] ( @sF7_credits_misc_timeline.code_09E6C0, #00, #00, #$0500 )
    COP [HaltIfCounterGte] ( #$53A8 )
    COP [SpawnLastRel] ( @sF7_credits_misc_timeline.code_09E6DB, #00, #00, #$0500 )
    COP [HaltIfCounterGte] ( #$5528 )
    COP [SpawnLastRel] ( @sF7_credits_misc_timeline.code_09E6F6, #00, #00, #$0500 )
    COP [HaltIfCounterGte] ( #$5538 )
    COP [SpawnLastRel] ( @sF7_credits_misc_timeline.code_09E711, #00, #00, #$0500 )
    COP [HaltIfCounterGte] ( #$56B8 )
    COP [SpawnLastRel] ( @sF7_credits_misc_timeline.code_09E72C, #00, #00, #$0500 )
    COP [HaltIfCounterGte] ( #$5848 )
    COP [SpawnLastRel] ( @sF7_credits_misc_timeline.code_09E747, #00, #00, #$0500 )
    COP [HaltIfCounterGte] ( #$5860 )
    COP [SpawnLastRel] ( @sF7_credits_misc_timeline.code_09E762, #00, #00, #$0500 )
    COP [HaltIfCounterGte] ( #$59CE )
    COP [CallScript] ( &code_09E990 )
    COP [HaltIfCounterGte] ( #$59D8 )
    COP [SpawnLastRel] ( @sF7_credits_misc_timeline.code_09E77D, #00, #00, #$0500 )
    COP [HaltIfCounterGte] ( #$59F0 )
    COP [SpawnLastRel] ( @sF7_credits_misc_timeline.code_09E798, #00, #00, #$0500 )
    COP [HaltIfCounterGte] ( #$5B68 )
    COP [SpawnLastRel] ( @sF7_credits_misc_timeline.code_09E7B3, #00, #00, #$0500 )
    COP [HaltIfCounterGte] ( #$5CF8 )
    COP [SpawnLastRel] ( @sF7_credits_misc_timeline.code_09E7CE, #00, #00, #$0500 )
    COP [HaltIfCounterGte] ( #$5D10 )
    COP [SpawnLastRel] ( @sF7_credits_misc_timeline.code_09E7E9, #00, #00, #$0500 )
    COP [HaltIfCounterGte] ( #$5E88 )
    COP [SpawnLastRel] ( @sF7_credits_misc_timeline.code_09E804, #00, #00, #$0500 )
    COP [HaltIfCounterGte] ( #$5EA0 )
    COP [SpawnLastRel] ( @sF7_credits_misc_timeline.code_09E81F, #00, #00, #$0500 )
    COP [HaltIfCounterGte] ( #$600E )
    COP [CallScript] ( &code_09E99A )
    COP [HaltIfCounterGte] ( #$6018 )
    COP [SpawnLastRel] ( @sF7_credits_misc_timeline.code_09E83A, #00, #00, #$0500 )
    COP [HaltIfCounterGte] ( #$6038 )
    COP [SpawnLastRel] ( @sF7_credits_misc_timeline.code_09E855, #00, #00, #$0500 )
    COP [HaltIfCounterGte] ( #$6198 )
    COP [SpawnLastRel] ( @sF7_credits_misc_timeline.code_09E870, #00, #00, #$0500 )
    COP [HaltIfCounterGte] ( #$61C8 )
    COP [SpawnLastRel] ( @sF7_credits_misc_timeline.code_09E88B, #00, #00, #$0500 )
    COP [HaltIfCounterGte] ( #$6338 )
    COP [SpawnLastRel] ( @sF7_credits_misc_timeline.code_09E8A6, #00, #00, #$0500 )
    COP [HaltIfCounterGte] ( #$6400 )
    COP [CopyPalette] ( @palette_1E0B8C, #00, #00, #80 )
    COP [AdhocVramDma] ( $7EFC00, #$1180, #$0200 )
    COP [AdhocVramDma] ( $7EFE00, #$1980, #$0200 )
    COP [SpawnLastRel] ( @code_09F4AA, #00, #00, #$2000 )
    COP [HaltIfCounterGte] ( #$64C8 )
    COP [SpawnLastRel] ( @sF7_credits_misc_timeline.code_09E8C1, #00, #00, #$0500 )
    COP [HaltIfCounterGte] ( #$652C )
    COP [SpawnLastRel] ( @code_09F4ED, #00, #00, #$2000 )
    COP [HaltIfCounterGte] ( #$7068 )
    STZ $066D
    STZ $0670
    STZ $0673
    STZ $0676
    STZ $0679
    STZ $067C
    STZ $067F
    STZ $0682
    STZ $0685
    COP [QueueMapChange] ( #F0, #$0090, #$0178, #06, #$1201 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_09DB4B {
    PHX 
    PHB 
    LDX #$E000
    LDA #$1FFF
    MVN #$7F, #$7E
    PLB 
    PLX 
    RTS 
}

code_09DB59 {
    PHX 
    PHB 
    LDX #$A000
    LDA #$3FFF
    MVN #$7F, #$7E
    PLB 
    PLX 
    RTS 
}
---------------------------------------------

code_09E62F {
    LDA #$0012
    JSL $@CreditPositionLookup
    BRA loc_09E63D
}

code_09E637 {
    LDA #$0022
    JSL $@CreditPositionLookup

  loc_09E63D:
    COP [SetMetasprite] ( $7E6000 )
    COP [StageSpriteLoopMoveX] ( #10, #07, #02 )
    COP [AnimLoop]
    COP [Die]
}
---------------------------------------------

code_09E919 {
    COP [SetEntryContinue]
    INC $00E4
    SED 
    LDA $00E6
    CLC 
    ADC #$0001
    STA $00E6
    LDA $00E8
    ADC #$0000
    STA $00E8
    CLD 
    RTL 
}

code_09E934 {
    COP [AdhocVramDma] ( $7F6000, #$5000, #$0800 )
    COP [AdhocVramDma] ( $7F6800, #$5400, #$0800 )
    COP [AdhocVramDma] ( $7F7000, #$5800, #$0800 )
    COP [AdhocVramDma] ( $7F7800, #$5C00, #$0800 )
    COP [CopyPalette] ( @palette_1F3333, #00, #90, #40 )
    COP [RestoreSavedPtr]
}

code_09E962 {
    COP [AdhocVramDma] ( $7F8000, #$5000, #$0800 )
    COP [AdhocVramDma] ( $7F8800, #$5400, #$0800 )
    COP [AdhocVramDma] ( $7F9000, #$5800, #$0800 )
    COP [AdhocVramDma] ( $7F9800, #$5C00, #$0800 )
    COP [CopyPalette] ( @palette_1E65F3, #00, #90, #70 )
    COP [RestoreSavedPtr]
}

code_09E990 {
    COP [CopyPalette] ( @palette_1E66D3, #00, #90, #70 )
    COP [RestoreSavedPtr]
}

code_09E99A {
    COP [CopyPalette] ( @palette_1E67B3, #00, #90, #70 )
    COP [RestoreSavedPtr]
}

code_09E9A4 {
    COP [AdhocVramDma] ( $7F4000, #$5000, #$0800 )
    COP [AdhocVramDma] ( $7F4800, #$5400, #$0800 )
    COP [AdhocVramDma] ( $7F5000, #$5800, #$0800 )
    COP [AdhocVramDma] ( $7F5800, #$5C00, #$0800 )
    COP [CopyPalette] ( @pal_sc02_main_characters, #00, #A0, #60 )
    COP [RestoreSavedPtr]
}

code_09E9D2 {
    LDA $00E4
    BPL loc_09E9D8
    RTL 

  loc_09E9D8:
    COP [HaltIfCounterGte] ( #$01F4 )
    LDA #$&dialogstring_09ECBF
    STA $26
    COP [CallScript] ( &code_09EB64 )
    COP [WaitByte] ( #4A )
    LDA #$&dialogstring_09ECE7
    STA $26
    COP [CallScript] ( &code_09EB64 )
    COP [WaitByte] ( #4A )
    LDA #$&dialogstring_09ED10
    STA $26
    COP [CallScript] ( &code_09EB64 )
    COP [WaitByte] ( #4A )
    LDA #$&dialogstring_09ED3C
    STA $26
    COP [CallScript] ( &code_09EB64 )
    COP [WaitByte] ( #4A )
    LDA #$&dialogstring_09ED68
    STA $26
    COP [CallScript] ( &code_09EB64 )
    COP [WaitByte] ( #4A )
    LDA #$&dialogstring_09ED96
    STA $26
    COP [CallScript] ( &code_09EB64 )
    COP [WaitByte] ( #4A )
    LDA #$&dialogstring_09EDC3
    STA $26
    COP [CallScript] ( &code_09EB64 )
    COP [WaitByte] ( #4A )
    LDA #$&dialogstring_09EDF1
    STA $26
    COP [CallScript] ( &code_09EB64 )
    COP [WaitByte] ( #4A )
    LDA #$&dialogstring_09EE2D
    STA $26
    COP [CallScript] ( &code_09EB64 )
    COP [WaitByte] ( #4A )
    LDA #$&dialogstring_09EE7D
    STA $26
    COP [CallScript] ( &code_09EB64 )
    COP [WaitByte] ( #4A )
    LDA #$&dialogstring_09EEAA
    STA $26
    COP [CallScript] ( &code_09EB64 )
    COP [WaitByte] ( #4A )
    LDA #$&dialogstring_09EEF7
    STA $26
    COP [CallScript] ( &code_09EB64 )
    COP [WaitByte] ( #4A )
    LDA #$&dialogstring_09EF22
    STA $26
    COP [CallScript] ( &code_09EB64 )
    COP [WaitByte] ( #4A )
    LDA #$&dialogstring_09EF75
    STA $26
    COP [CallScript] ( &code_09EB64 )
    COP [WaitByte] ( #4A )
    LDA #$&dialogstring_09EFB1
    STA $26
    COP [CallScript] ( &code_09EB64 )
    COP [WaitByte] ( #4A )
    LDA #$&dialogstring_09EFFB
    STA $26
    COP [CallScript] ( &code_09EB64 )
    COP [WaitByte] ( #4A )
    LDA #$&dialogstring_09F038
    STA $26
    COP [CallScript] ( &code_09EB64 )
    COP [WaitByte] ( #4A )
    LDA #$&dialogstring_09F073
    STA $26
    COP [CallScript] ( &code_09EB64 )
    COP [WaitByte] ( #4A )
    LDA #$&dialogstring_09F0B2
    STA $26
    COP [CallScript] ( &code_09EB64 )
    COP [WaitByte] ( #4A )
    LDA #$&dialogstring_09F0F2
    STA $26
    COP [CallScript] ( &code_09EB64 )
    COP [WaitByte] ( #4A )
    LDA #$&dialogstring_09F12C
    STA $26
    COP [CallScript] ( &code_09EB64 )
    COP [WaitByte] ( #4A )
    LDA #$&dialogstring_09F18A
    STA $26
    COP [CallScript] ( &code_09EB64 )
    COP [WaitByte] ( #4A )
    LDA #$&dialogstring_09F1C8
    STA $26
    COP [CallScript] ( &code_09EB64 )
    COP [WaitByte] ( #4A )
    LDA #$&dialogstring_09F1F2
    STA $26
    COP [CallScript] ( &code_09EB64 )
    COP [WaitByte] ( #4A )
    LDA #$&dialogstring_09F220
    STA $26
    COP [CallScript] ( &code_09EB64 )
    COP [WaitByte] ( #4A )
    LDA #$&dialogstring_09F248
    STA $26
    COP [CallScript] ( &code_09EB64 )
    COP [WaitByte] ( #4A )
    LDA #$&dialogstring_09F273
    STA $26
    COP [CallScript] ( &code_09EB64 )
    COP [WaitByte] ( #4A )
    LDA #$&dialogstring_09F2A9
    STA $26
    COP [CallScript] ( &code_09EB64 )
    COP [WaitByte] ( #4A )
    LDA #$&dialogstring_09F2FA
    STA $26
    COP [CallScript] ( &code_09EB64 )
    COP [WaitByte] ( #4A )
    SEP #$20
    LDA #$79
    STA $BG3SC
    REP #$20
    LDY #$&dialogstring_09F315
    JSR $&code_09EC23
    COP [AdhocVramDma] ( $7F0200, #$7800, #$0800 )
    SEP #$20
    LDA #$14
    ORA $09F6
    STA $TM
    LDA #$00
    STA $TS
    REP #$20
    COP [SetEntryContinue]
    RTL 
}

code_09EB64 {
    SEP #$20
    LDA #$79
    STA $BG3SC
    REP #$20
    LDA #$0000
    STA $0720
    LDA #$0100
    LDY #$0024

  loc_09EB79:
    STA $0726, Y
    DEY 
    DEY 
    BPL loc_09EB79
    LDA $0724
    LDA $0748
    STZ $074A
    LDY $26
    JSR $&code_09EC23
    COP [AdhocVramDma] ( $7F0200, #$7800, #$0800 )
    SEP #$20
    LDA #$14
    ORA $09F6
    STA $TM
    LDA $09F7
    STA $TS
    REP #$20
    COP [LoopInit] ( #80 )
    LDA $0726
    SEC 
    SEC 
    SBC #$0002
    STA $0726
    LDA $0728
    CLC 
    ADC #$0002
    STA $0728
    LDA $0036
    LSR 
    BCC loc_09EBDB
    LDY $074A
    CPY #$0022
    BEQ loc_09EBDB
    INC $074A
    INC $074A
    LDA #$0000
    STA $072A, Y

  loc_09EBDB:
    COP [LoopNext]
    COP [WaitWord] ( #$0257 )
    SEP #$20
    LDA #$7A
    STA $BG3SC
    REP #$20
    COP [LoopInit] ( #80 )
    LDA $0720
    CLC 
    ADC #$0001
    STA $0720
    COP [LoopNext]
    SEP #$20
    LDA #$10
    ORA $09F6
    STA $TM
    REP #$20
    LDA #$0000
    STA $0720
    PHX 
    LDX #$0400

  loc_09EC0F:
    STA $7F0200, X
    DEX 
    DEX 
    BPL loc_09EC0F
    PLX 
    COP [AdhocVramDma] ( $7F0200, #$7800, #$0800 )
    COP [RestoreSavedPtr]
}

code_09EC23 {
    PHX 
    PHB 
    SEP #$20
    LDA #$^dialogstring_09ECBF
    PHA 
    PLB 
    REP #$20
    STZ $0000
    LDA #$2100
    STA $099E

  loc_09EC36:
    SEP #$20
    LDA $0000, Y
    INY 
    CMP #$C0
    BCS loc_09EC5E
    LDX $0000
    REP #$20
    AND #$00FF
    ORA $099E
    STA $7F0200, X
    CLC 
    ADC #$0010
    STA $7F0240, X
    INX 
    INX 
    STX $0000
    BRA loc_09EC36

  loc_09EC5E:
    STX $0000
    REP #$20
    AND #$001F
    ASL 
    TAX 
    JSR ($&table_09EC74, X)
    LDX $0000
    BRA loc_09EC36

  code_09EC70:
    PLA 
    PLB 
    PLX 

  code_09EC73:
    RTS 
}
---------------------------------------------

table_09EC74 [
  &code_09EC70   ;00
  &code_09EC94   ;01
  &code_09EC73   ;02
  &code_09ECA0   ;03
  &code_09EC73   ;04
  &code_09EC73   ;05
  &code_09EC73   ;06
  &code_09EC73   ;07
  &code_09EC73   ;08
  &code_09EC73   ;09
  &code_09EC73   ;0A
  &code_09ECB1   ;0B
  &code_09EC73   ;0C
  &code_09EC73   ;0D
  &code_09EC73   ;0E
  &code_09EC73   ;0F
]

code_09EC94 {
    LDA $0000, Y
    INY 
    INY 
    STA $0000
    STA $09A0
    RTS 
}

code_09ECA0 {
    SEP #$20
    LDA $sceneStateHelper
    AND #$E3
    ORA $0000, Y
    INY 
    STA $sceneStateHelper
    REP #$20
    RTS 
}

code_09ECB1 {
    LDA $09A0
    CLC 
    ADC #$0080
    STA $09A0
    STA $0000
    RTS 
}
---------------------------------------------

dialogstring_09ECBF `[PAL:0][DLG:4C,1]The Illusion of GAIA[N][N]       STAFF[END]`!

dialogstring_09ECE7 `[PAL:0][DLG:4C,1]  Original Story[N][N][PAL:C]   MARIKO OHARA[END]`!

dialogstring_09ED10 `[PAL:0][DLG:4C,1] Character Designer[N][N][PAL:C]     MOTO HAGIO[END]`!

dialogstring_09ED3C `[PAL:0][DLG:4C,1]   Game Designer[N][N][PAL:8]TOMOYOSHI MIYAZAKI[END]`!

dialogstring_09ED68 `[PAL:0][DLG:4C,1]  Program Director[N][N][PAL:8]  MASAYA HASHIMOTO[END]`!

dialogstring_09ED96 `[PAL:0][DLG:4C,1]  Main Programmer[N][N][PAL:8]  AKIRA KITANOHARA[END]`!

dialogstring_09EDC3 `[PAL:0][DLG:4C,1]Background Designer[N][N][PAL:8]   HISASHI YOKOTA[END]`!

dialogstring_09EDF1 `[PAL:0][DLG:4C,1]  Object Designer[N][PAL:8]   JUNICHI ISHIDA[N]   HITOSHI ARIGA[END]`!

dialogstring_09EE2D `[PAL:0][DLG:4C,1]  Graphic Designer[N][PAL:C]    NAOKO SUZUKI[N][PAL:8]   TAKAHIRO OHURA[N]    KOUJI YOKOTA[END]`!

dialogstring_09EE7D `[PAL:0][DLG:4A,1]   Sound Composer[N][N][PAL:8] YASUHIRO KAWASAKI[END]`!

dialogstring_09EEAA `[PAL:0][DLG:4C,1]  English Text by[N][PAL:8]   Scott Pelland[N]     Tim Rooney[N]  Robert L.Jerauld[END]`!

dialogstring_09EEF7 `[PAL:0][DLG:4C,1] Title Coordinator[N][N][PAL:C]    Mary Cocoma[END]`!

dialogstring_09EF22 `[PAL:0][DLG:4C,1]   Quintet Staff[N][PAL:8]T.HASHIMOTO  S.KITA[N]K.SUGAYA     T.TURU[N][PAL:C]   R.TAKEBAYASHI[END]`!

dialogstring_09EF75 `[PAL:0][DLG:4C,1]   Quintet Staff[N][PAL:C]M.TSURUNO Y.SASHIDA[N]    M.KOBAYASHI[END]`!

dialogstring_09EFB1 `[PAL:0][DLG:4C,1]     ENIX Staff[N][PAL:8]   YUKINOBU CHIDA[N]    KEIJI HONDA[N]   YASUYUKI SONE[END]`!

dialogstring_09EFFB `[PAL:0][DLG:4C,1]   Art Direction[N][N][PAL:8]  HIDEKI YAMAMOTO[N]  TAKASHI OOTSUKA[END]`!

dialogstring_09F038 `[PAL:0][DLG:4C,1] Technical Support[N][N][PAL:8]   SADAO YAHAGI[N]   KENJIRO KANO[END]`!

dialogstring_09F073 `[PAL:0][DLG:4C,1] Enix America Staff[N][N][PAL:8]    TSUNEO MORITA[N]     Paul Bowler[END]`!

dialogstring_09F0B2 `[PAL:0][DLG:4C,1] Enix America Staff[N][N][PAL:8]    Paul Handelman[N]     Jake Kazdal[END]`!

dialogstring_09F0F2 `[PAL:0][DLG:4C,1] Special Thanks to[N][N][PAL:8]     Dan Owsen[N]    Hiro Yamada[END]`!

dialogstring_09F12C `[PAL:0][DLG:4A,1]  Special Thanks to[N][PAL:8]H.KURODA   A.SHIGENO[N]K.KUWABARA [PAL:C]M.SUMITA[N][PAL:8]Y.SASAKI   N.SUGINAKA[END]`!

dialogstring_09F18A `[PAL:0][DLG:4C,1] Special Thanks to[N][PAL:8]M.KAKIZAWA   A.ARAI[N][PAL:C]K.WAKABAYASHI[END]`!

dialogstring_09F1C8 `[PAL:0][DLG:4C,1]      Director[N][N][PAL:8]  MASAYA HASHIMOTO[END]`!

dialogstring_09F1F2 `[PAL:0][DLG:4C,1] Assistant Producer[N][N][PAL:8]  KAZUNORI TAKADO[END]`!

dialogstring_09F220 `[PAL:0][DLG:4C,1]      Producer[N][N][PAL:8]   SHINJI FUTAMI[END]`!

dialogstring_09F248 `[PAL:0][DLG:4C,1]     Publisher[N][N][PAL:8] YASUHIRO FUKUSHIMA[END]`!

dialogstring_09F273 `[PAL:0][DLG:4C,1]     Copyright[N][N][PAL:8]    1994 ENIX[N]    1994 QUINTET[END]`!

dialogstring_09F2A9 `[PAL:0][DLG:4A,1]     Copyright[N][PAL:C]1994 MARIKO OHARA[N]1994 MOTO HAGIO[N][PAL:8]1994 YASUHIRO KAWASAKI[END]`!

dialogstring_09F2FA `[PAL:0][DLG:4A,2] Licensed to NINTENDO[END]`!

dialogstring_09F315 `[PAL:0][DLG:4C,3]Thank you for playing[END]`!
---------------------------------------------

code_09F4AA {
    LDA #$0003
    TSB $09F6
    SEP #$20
    LDA #$17
    STA $TM
    LDA #$FF
    STA $COLDATA
    REP #$20
    AND #$00FF
    STA $24
    STZ $00FE
    COP [SetEntryContinue]
    LDA $00FE
    CMP #$003F
    BCS loc_09F4EB
    INC 
    STA $00FE
    LSR 
    BCC loc_09F4D8
    RTL 

  loc_09F4D8:
    LDA $24
    CMP #$00E0
    BNE loc_09F4E0
    RTL 

  loc_09F4E0:
    DEC 
    STA $24
    SEP #$20
    STA $COLDATA
    REP #$20
    RTL 

  loc_09F4EB:
    COP [Die]
}

code_09F4ED {
    LDA #$00E0
    STA $24
    COP [SetEntryContinue]
    LDA $24
    CMP #$00FF
    BEQ loc_09F508
    INC 
    STA $24
    SEP #$20
    STA $COLDATA
    REP #$20
    INC $08
    RTL 

  loc_09F508:
    STZ $00FE
    DEC $00FE
    COP [Die]
}
---------------------------------------------

func_09F69F {
    COP [PaletteStart] ( #65 )
    COP [PaletteStep]
    COP [Die]
}