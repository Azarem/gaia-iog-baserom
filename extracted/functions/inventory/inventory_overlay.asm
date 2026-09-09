?INCLUDE 'chunk_03BAE1'
?INCLUDE 'event_blocks'
?INCLUDE 'scene_script'
?INCLUDE 'system_core'
?INCLUDE 'system_init'
?INCLUDE 'system_strings'
?INCLUDE 'vblank_joypad'
?INCLUDE 'vram_buffer_clear'
?INCLUDE 'warps_interaction'

!sceneCurrent                   0644
!joypadCurrent                  0656
!joypadHeld                     0658
!joypadMaskStd                  065A
!joypadMaskInv                  065C
!bg1ScrollH                     068A
!bg1ScrollV                     068C
!bg2ScrollH                     068E
!savedCameraDelta               0690
!cameraTargetX                  06BE
!cameraDeltaX                   06C0
!cameraTargetY                  06C2
!cameraDeltaY                   06C4
!scrollOverrideH                06C6
!forcedScrollOverride           06C8
!scrollOverrideV                06CA
!effectDeltaX                   06E4
!displayModeFlags               09EC
!eventFlags                     0A00
!cachedPrevMaxHp                0ACC
!cachedPrevHp                   0AD0
!bg1ConfigMode                  0AE6
!activeActorCount               0DBC
!INIDISP                        2100
!BG1SC                          2107
!BG2SC                          2108
!BG3SC                          2109
!BG3HOFS                        2111
!BG3VOFS                        2112
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
!HDMAEN                         420C
!oamComposeBuffer               7F3100

---------------------------------------------

OpenInventoryScreen {
    PHP 
    SEP #$20
    JSL $@vblank_joypad.EnableNmiOnly
    JSL $@vblank_joypad.EnableDisplay
    STZ $HDMAEN
    JSR $&SaveGameState
    REP #$20
    LDA #$0F00
    STA $joypadMaskInv
    LDA $effectDeltaX
    PHA 
    STZ $effectDeltaX
    LDA $displayModeFlags
    PHA 
    LDA #$4000
    STA $displayModeFlags
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
    JSL $@scene_script.SceneScriptNoMusic
    LDA #$0C
    STA $BG2SC
    LDA #$04
    STA $BG1SC
    STA $bg1ConfigMode
    JSL $@chunk_03BAE1.func_03DFA0
    LDA #$1B
    STA $7F0A04
    LDA #$5B
    STA $7F0A05
    JSL $@system_init.UploadCgramPalette
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
    JSL $@vram_buffer_clear.ClearVramBufferFull
    JSL $@chunk_03BAE1.func_03CDDC
    JSL $@chunk_03BAE1.func_03CEA1
    JSL $@chunk_03BAE1.func_03D7E7
    JSL $@chunk_03BAE1.zero_bytes_03D86A
    JSL $@chunk_03BAE1.run_actors_03CAF5
    JSL $@chunk_03BAE1.run_actors_03CAF5
    JSL $@chunk_03BAE1.func_03C5FF
    LDA #$FF
    STA $oamComposeBuffer
    STA $7F3101
    JSL $@chunk_03BAE1.func_03C714
    JSL $@system_core.UpdateFrameDialogue
    JSL $@vblank_joypad.EnableNmiAndJoypad
    JSL $@vblank_joypad.VBlankWaitAndJoypad
    LDA #$0F
    STA $INIDISP
    JSL $@vblank_joypad.EnableNmiOnly

  code_02EE17:
    JSL $@system_core.UpdateFrameDialogue
    LDA $bg1ConfigMode
    STA $BG1SC
    COP [BranchIfFlagByte] ( #00, #00, &code_02EE17 )
    STZ $BG3VOFS
    STZ $BG3VOFS
    JSL $@vblank_joypad.EnableNmiOnly
    JSL $@vblank_joypad.EnableDisplay
    STZ $HDMAEN
    JSR $&RestoreGameState
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
    STA $displayModeFlags
    PLA 
    STA $effectDeltaX
    SEP #$20
    JSL $@scene_script.SceneScriptNoMusic
    JSL $@event_blocks.ApplyAllEventBlocks
    JSL $@warps_interaction.PlaceBarrierTiles
    JSR $&RestorePaletteBuffer
    JSL $@chunk_03BAE1.func_03DFA0
    JSL $@chunk_03BAE1.func_03DFF8
    JSR $&ReloadAbilityFX
    JSL $@chunk_03BAE1.zero_bytes_03D86A
    JSL $@vram_buffer_clear.ClearVramBufferFull
    LDA #$41
    TSB $displayModeFlags
    JSL $@chunk_03BAE1.func_03DECD
    LDX #$0000
    STX $09CC
    STX $09CE
    STX $cachedPrevHp
    STX $cachedPrevMaxHp
    STX $joypadMaskInv
    STX $00F4
    STX $00F8
    COP [RunBg3Script] ( @system_strings.asciistring_01E818 )
    JSR $&DrainActorQueue
    JSL $@chunk_03BAE1.func_03E146
    JSL $@system_core.UpdateFrameRender
    COP [SetFlagByte] ( #FF )
    JSL $@system_core.UpdateFrameRender
    LDA #$0F
    STA $INIDISP
    PLP 
    RTL 
}

ReloadAbilityFX {
    LDA $00EA
    BNE loc_02EED2
    RTS 

  loc_02EED2:
    DEC 
    BNE loc_02EEF0
    LDX #$4400
    STX $VMADDL
    LDX #$&misc_fx_1CC000
    LDA #$^misc_fx_1CC000
    LDY #$0480
    JSL $@scene_script.DmaWordToVram
    COP [CopyPalette] ( @fx_palette_198070, #00, #A0, #10 )
    RTS 

  loc_02EEF0:
    LDX #$4400
    STX $VMADDL
    LDX #$&misc_fx_1CC480
    LDA #$^misc_fx_1CC480
    LDY #$0600
    JSL $@scene_script.DmaWordToVram
    COP [CopyPalette] ( @fx_palette_198090, #00, #A9, #07 )
    RTS 
}

DrainActorQueue {
    PHP 
    PHD 
    REP #$20
    LDA $5A
    BEQ loc_02EF1A

  loc_02EF13:
    TCD 
    STZ $08
    LDA $06
    BNE loc_02EF13

  loc_02EF1A:
    PLD 
    PLP 
    RTS 
}

SaveGameState {
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
    LDA $activeActorCount
    STA $0DBE
    LDX #$0000

  loc_02EF45:
    LDA $004E, X
    STA $7E389C, X
    INX 
    INX 
    CPX #$0010
    BNE loc_02EF45
    LDX #$0000

  loc_02EF56:
    LDA $cameraTargetX, X
    STA $7E3890, X
    INX 
    INX 
    CPX #$000C
    BNE loc_02EF56
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

RestoreGameState {
    PHP 
    PHB 
    REP #$20
    LDA $7E38AC
    STA $joypadCurrent
    LDA $7E38AE
    STA $joypadHeld
    LDA $7E38B0
    STA $joypadMaskStd
    LDA $0DBE
    STA $activeActorCount
    LDX #$0000

  loc_02EFD4:
    LDA $7E389C, X
    STA $004E, X
    INX 
    INX 
    CPX #$0010
    BNE loc_02EFD4
    LDX #$0000

  loc_02EFE5:
    LDA $7E3890, X
    STA $cameraTargetX, X
    INX 
    INX 
    CPX #$000C
    BNE loc_02EFE5
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

RestorePaletteBuffer {
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