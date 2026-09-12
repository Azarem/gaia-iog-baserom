?BANK 02

?INCLUDE 'cop_handlers_script'
?INCLUDE 'dialogue_display'
?INCLUDE 'event_blocks'
?INCLUDE 'forced_walk'
?INCLUDE 'GetPlayerFacingDirection'
?INCLUDE 'hdma_dma_spc'
?INCLUDE 'inventory_mgmt'
?INCLUDE 'itemget_table_01FD24'
?INCLUDE 'map_coords'
?INCLUDE 'player_transition_handlers'
?INCLUDE 'scene_lifecycle'
?INCLUDE 'scene_warps'
?INCLUDE 'system_core'
?INCLUDE 'table_01ADA8'

!sceneNext                      0642
!sceneCurrent                   0644
!joypadCurrent                  0656
!joypadMaskStd                  065A
!cameraOffsetX                  06D6
!cameraOffsetY                  06D8
!cameraBoundsX                  06DA
!cameraBoundsY                  06DC
!scrollStepTableBase            06E0
!scrollStepIndex                06E2
!layerPriorityFlag              06EE
!musicParentActor               06F2
!sfxQueueCh2                    06F9
!musicTransitionState           06FA
!dmaSkipFlag                    0800
!playerXPos                     09A2
!playerYPos                     09A4
!playerXTile                    09A6
!playerYTile                    09A8
!playerActor                    09AA
!playerFlags                    09AE
!playerSpeedEw                  09B2
!playerSpeedNs                  09B4
!displayModeFlags               09EC
!sceneSaveData                  0AF0
!APUIO1                         2141
!mapLayerTilemap                7EA000
!chatPtr                        7F000A
!orbitAngle                     7F0010

---------------------------------------------

CheckWarpAndChest {
    PHP 
    REP #$20
    JSR $&CheckWarpRectangles
    BCS loc_02A5EA
    JSR $&HandleChestInteraction
    BCS loc_02A5EA

  loc_02A5EA:
    NOP 
    NOP 
    NOP 
    NOP 
    PLP 
    RTL 
}

PlaceBarrierTiles {
    PHP 
    REP #$20
    LDY $0646
    LDX $&table_01ADA8, Y

  loc_02A5F9:
    LDA $0000, X
    BIT #$0080
    BNE loc_02A65B
    LDA $0003, X
    AND #$007F
    JSL $@cop_handlers_script.TestEventFlag_0200
    BCC loc_02A655
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
    JSL $@map_coords.TileCoordsToMapIndex
    STX $02
    STX $00
    LDA #$FE
    STA $mapLayerTilemap, X
    JSL $@map_coords.MapIndexMoveRight
    LDA #$FF
    STA $mapLayerTilemap, X
    LDX $00
    STX $02
    JSL $@map_coords.MapIndexMoveDown
    LDA #$FC
    STA $mapLayerTilemap, X
    JSL $@map_coords.MapIndexMoveRight
    LDA #$FD
    STA $mapLayerTilemap, X
    REP #$20
    PLX 

  loc_02A655:
    INX 
    INX 
    INX 
    INX 
    BRA loc_02A5F9

  loc_02A65B:
    PLP 
    RTL 
}

HandleChestInteraction {
    LDA $layerPriorityFlag
    BIT #$0200
    BEQ loc_02A666
    RTS 

  loc_02A666:
    LDY $playerActor
    LDA $0010, Y
    BIT #$0004
    BNE loc_02A672
    RTS 

  loc_02A672:
    LDA $joypadCurrent
    BIT #$0800
    BNE loc_02A67B
    RTS 

  loc_02A67B:
    JSL $@GetPlayerFacingDirection
    AND #$00FF
    CMP #$0001
    BEQ loc_02A688
    RTS 

  loc_02A688:
    LDY $playerActor
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
    JSL $@map_coords.TileCoordsToMapIndex
    LDA $mapLayerTilemap, X
    STX $02
    CMP #$F8
    BEQ loc_02A6D8
    CMP #$F9
    BEQ loc_02A6C8

  loc_02A6C5:
    REP #$20
    RTS 

  loc_02A6C8:
    JSL $@map_coords.MapIndexMoveLeft
    LDA $mapLayerTilemap, X
    CMP #$F8
    BNE loc_02A6C5
    DEC $18
    BRA loc_02A6E4

  loc_02A6D8:
    JSL $@map_coords.MapIndexMoveRight
    LDA $mapLayerTilemap, X
    CMP #$F9
    BNE loc_02A6C5

  loc_02A6E4:
    LDY $0646
    LDX $&table_01ADA8, Y

  loc_02A6EA:
    LDA $0000, X
    BMI loc_02A700
    CMP $18
    BNE loc_02A6FA
    LDA $0001, X
    CMP $1C
    BEQ loc_02A70A

  loc_02A6FA:
    INX 
    INX 
    INX 
    INX 
    BRA loc_02A6EA

  loc_02A700:
    REP #$20
    LDY #$&itemget_table_01FD24.dialogstring_01FF48
    JSL $@dialogue_display.ShowDialogueFrame
    RTS 

  loc_02A70A:
    REP #$20
    PHX 
    LDA #$0080
    TSB $displayModeFlags
    LDA #$00FC
    STA $06
    JSR $&DrawChestTiles
    LDA $01, S
    TAX 
    LDA $0002, X
    AND #$00FF
    BEQ loc_02A73D
    JSL $@inventory_mgmt.GiveItemToPlayer
    BCC loc_02A753
    JSL $@dialogue_display.ShowDialogueFrame
    LDA $01, S
    TAX 
    LDA #$00F8
    STA $06
    JSR $&DrawChestTiles
    BRA loc_02A7B0

  loc_02A73D:
    LDY #$&itemget_table_01FD24.dialogstring_01FF36
    JSL $@dialogue_display.ShowDialogueFrame
    LDA $01, S
    TAX 
    LDA $0003, X
    AND #$007F
    JSL $@cop_handlers_script.SetEventFlag_0200
    BRA loc_02A7B0

  loc_02A753:
    LDA $01, S
    PHX 
    TAX 
    LDA $0003, X
    BIT #$0080
    BNE loc_02A778
    LDA #$0080
    TRB $displayModeFlags
    SEP #$20
    LDA #$2A
    STA $sfxQueueCh2
    REP #$20
    PLX 
    LDY #$&itemget_table_01FD24.dialogstring_01FF2D
    JSL $@dialogue_display.ShowDialogueFrame
    BRA loc_02A7A1

  loc_02A778:
    PLX 
    PHY 
    PHX 
    LDX #$0000
    COP [SpawnLastRel] ( @ChestOpeningActor, #00, #00, #$2000 )
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

  loc_02A7A1:
    LDA $01, S
    TAX 
    LDA $0003, X
    AND #$007F
    JSL $@cop_handlers_script.SetEventFlag_0200
    PLX 
    RTS 

  loc_02A7B0:
    LDA #$0080
    TRB $displayModeFlags
    PLX 
    RTS 
}

ChestOpeningActor {
    LDA $musicParentActor
    STA $orbitAngle, X
    COP [SpawnAfterFlags] ( @hdma_dma_spc.SpcTransferMusicData, #$2000 )
    CPY #$1FC0
    BNE loc_02A7CE
    JMP $&code_02A88B

  loc_02A7CE:
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
    LDA #$CFF0
    TSB $joypadMaskStd
    LDY $playerActor
    LDA $0012, Y
    ORA #$1000
    STA $0012, Y
    LDA #$*player_transition_handlers.loc_00C432
    STA $0002, Y
    LDA #$&player_transition_handlers.loc_00C432
    JSR $&SetAnimStatePointer
    LDA #$0800
    TSB $playerFlags
    COP [SetEntryContinue]
    LDA $musicTransitionState
    CMP #$FFFF
    BEQ loc_02A813
    RTL 

  loc_02A813:
    COP [SpawnAfterFlags] ( @ChestDialogueActor, #$2000 )
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
    BEQ loc_02A83F
    RTL 

  loc_02A83F:
    LDY $playerActor
    LDA $0012, Y
    AND #$EFFF
    STA $0012, Y
    LDA #$*player_transition_handlers.loc_00C45A
    STA $0002, Y
    LDA #$&player_transition_handlers.loc_00C45A
    JSR $&SetAnimStatePointer
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SpawnAfterFlags] ( @hdma_dma_spc.SpcTransferMusicData, #$2000 )
    CPY #$1FC0
    BEQ code_02A88B
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
    BEQ loc_02A888
    RTL 

  loc_02A888:
    COP [WaitByte] ( #0B )
}

code_02A88B {
    LDA #$0080
    TRB $displayModeFlags
    COP [Die]
}

ChestDialogueActor {
    COP [WaitByte] ( #48 )
    LDA #$1000
    TRB $12
    LDA $20
    STA $0DB8
    LDY $24
    JSL $@dialogue_display.ShowDialogueFrame
    COP [Die]
}

SetAnimStatePointer {
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    RTS 
}

DrawChestTiles {
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
    JSL $@map_coords.TileCoordsToMapIndex
    STX $02
    STX $00
    LDY #$0000
    LDA $06
    CLC 
    ADC #$02
    STA $mapLayerTilemap, X
    JSR $&event_blocks.QueueVisibleTileVram
    JSL $@map_coords.MapIndexMoveRight
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
    JSR $&event_blocks.QueueVisibleTileVram
    LDX $00
    STX $02
    JSL $@map_coords.MapIndexMoveDown
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
    JSR $&event_blocks.QueueVisibleTileVram
    JSL $@map_coords.MapIndexMoveRight
    LDA $06
    INC 
    STA $mapLayerTilemap, X
    REP #$20
    LDA $1A
    CLC 
    ADC #$0010
    STA $1A
    SEP #$20
    JSR $&event_blocks.QueueVisibleTileVram
    REP #$20
    LDA #$0000
    STA $dmaSkipFlag, Y
    SEP #$20
    JSL $@system_core.UpdateFrameRender
    PLP 
    RTS 
}

InitWarpTable {
    REP #$20
    LDA $0646
    TAX 
    LDA $&scene_warps, X
    STA $00D4

  loc_02A963:
    SEP #$20
    TAX 
    LDA $0000, X
    BMI loc_02A974
    REP #$20
    TXA 
    CLC 
    ADC #$000C
    BRA loc_02A963

  loc_02A974:
    INX 
    STX $00D6
    SEP #$20
    RTL 
}

CheckWarpRectangles {
    SEP #$20
    LDX $00D4
    BEQ loc_02A9C9

  loc_02A982:
    LDA $0000, X
    CMP #$FF
    BEQ loc_02A9C9
    LDA $playerXTile
    SEC 
    SBC $0000, X
    CMP $0002, X
    BCS loc_02A9A1
    LDA $playerYTile
    SEC 
    SBC $0001, X
    CMP $0003, X
    BCC loc_02A9AD

  loc_02A9A1:
    REP #$20
    TXA 
    CLC 
    ADC #$000C
    TAX 
    SEP #$20
    BRA loc_02A982

  loc_02A9AD:
    REP #$20
    JSR $&ConvertWarpToPixels
    LDA $playerXPos
    SEC 
    SBC $00
    CMP $04
    BCS loc_02A9C9
    LDA $playerYPos
    SEC 
    SBC $02
    CMP $06
    BCS loc_02A9C9
    JMP $&ExecuteWarp

  loc_02A9C9:
    SEP #$20
    LDX $00D6
    BEQ loc_02AA17

  loc_02A9D0:
    LDA $0000, X
    CMP #$FF
    BEQ loc_02AA17
    LDA $playerXTile
    SEC 
    SBC $0000, X
    CMP $0002, X
    BCS loc_02A9EF
    LDA $playerYTile
    SEC 
    SBC $0001, X
    CMP $0003, X
    BCC loc_02A9FB

  loc_02A9EF:
    REP #$20
    TXA 
    CLC 
    ADC #$000D
    TAX 
    SEP #$20
    BRA loc_02A9D0

  loc_02A9FB:
    REP #$20
    JSR $&ConvertWarpToPixels
    LDA $playerXPos
    SEC 
    SBC $00
    CMP $04
    BCS loc_02AA17
    LDA $playerYPos
    SEC 
    SBC $02
    CMP $06
    BCS loc_02AA17
    JMP $&code_02AAF2

  loc_02AA17:
    REP #$20
    LDA #$0100
    TRB $playerFlags
    CLC 
    RTS 
}

ConvertWarpToPixels {
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

ExecuteWarp {
    PHP 
    TXA 
    CLC 
    ADC #$0004
    STA $0AF4
    SEP #$20
    LDA #$^scene_warps
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
    BNE loc_02AADA
    PLP 
    SEC 
    RTS 

  loc_02AADA:
    AND #$7F
    STA $0650
    REP #$20
    TXA 
    CLC 
    ADC #$0004
    STA $sceneSaveData
    LDA #$*scene_warps
    STA $0AF2
    PLP 
    SEC 
    RTS 
}

code_02AAF2 {
    LDA $playerFlags
    BIT #$0100
    BEQ loc_02AAFB
    RTS 

  loc_02AAFB:
    TXA 
    CLC 
    ADC #$0007
    STA $0650
    LDA #$0000
    STA $playerSpeedEw
    STA $playerSpeedNs
    SEP #$20
    LDY $0004, X
    STY $0652
    LDA $0006, X
    STA $scrollStepTableBase
    JSL $@scene_lifecycle.InitCameraBounds
    JSR $&StartForcedWalk
    REP #$20
    SEC 
    RTS 
}

StartForcedWalk {
    REP #$20
    LDA #$0100
    TSB $playerFlags
    LDY $playerActor
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
    BNE loc_02AB63
    BIT #$0010
    BNE loc_02AB70
    BIT #$0080
    BNE loc_02AB7D
    PHD 
    LDA $playerActor
    TAX 
    TCD 
    COP [SpawnBefore] ( @forced_walk.ForcedWalkSouth )
    PLD 
    RTS 

  loc_02AB63:
    PHD 
    LDA $playerActor
    TAX 
    TCD 
    COP [SpawnBefore] ( @forced_walk.ForcedWalkWest )
    PLD 
    RTS 

  loc_02AB70:
    PHD 
    LDA $playerActor
    TAX 
    TCD 
    COP [SpawnBefore] ( @forced_walk.ForcedWalkEast )
    PLD 
    RTS 

  loc_02AB7D:
    PHD 
    LDA $playerActor
    TAX 
    TCD 
    COP [SpawnBefore] ( @forced_walk.ForcedWalkNorth )
    PLD 
    RTS 
}