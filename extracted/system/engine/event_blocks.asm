?BANK 02

?INCLUDE 'event_block_table'
?INCLUDE 'map_coords'
?INCLUDE 'system_core'

!sceneCurrent                   0644
!bg1ScrollH                     068A
!bg1ScrollV                     068C
!bg2ScrollH                     068E
!savedCameraDelta               0690
!dmaSkipFlag                    0800
!tileQueryResult                0902
!VMAIN                          2115
!VMADDL                         2116
!VMDATAL                        2118
!metatileMapLayer               7E2000
!metatileEffectLayer            7E2800
!mapLayerTilemap                7EA000
!effectLayerTilemap             7EC000
!collisionLayer                 7FC000

---------------------------------------------

ApplyAllEventBlocks {
    PHP 
    SEP #$20
    LDY #$0000
    STY $04

  loc_02A1F1:
    LDA $0A20, Y
    INY 
    STA $06
    LDA #$08
    STA $0E

  loc_02A1FB:
    LSR $06
    BCC loc_02A214
    LDA $04
    REP #$20
    PHY 
    AND #$00FF
    JSL $@LookupEventBlock
    PLY 
    SEP #$20
    BCS loc_02A214
    JSL $@SwapEventBlockTiles

  loc_02A214:
    INC $04
    DEC $0E
    BNE loc_02A1FB
    LDA $04
    BNE loc_02A1F1
    PLP 
    RTL 
}

SwapEventBlockTiles {
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
    BEQ loc_02A23C
    LDA #$0002
    STA $A6

  loc_02A23C:
    LDA $9A
    STA $18
    LDA $9C
    STA $1C
    LDX $A6
    JSL $@map_coords.TileCoordsToMapIndex
    STX $00
    STX $1A
    LDA $96
    STA $18
    LDA $98
    STA $1C
    LDX $A6
    JSL $@map_coords.TileCoordsToMapIndex
    STX $02
    STX $1E
    LDA $A6
    BNE loc_02A2B9

  loc_02A264:
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
    BEQ loc_02A296
    JSL $@map_coords.MapIndexMoveRight
    PHX 
    LDA $00
    STA $02
    JSL $@map_coords.MapIndexMoveRight
    STX $00
    PLX 
    STX $02
    BRA loc_02A264

  loc_02A296:
    DEC $A0
    BEQ loc_02A2B6
    LDA $A2
    STA $9E
    LDA $1A
    STA $02
    JSL $@map_coords.MapIndexMoveDown
    STX $00
    STX $1A
    LDA $1E
    STA $02
    JSL $@map_coords.MapIndexMoveDown
    STX $1E
    BRA loc_02A264

  loc_02A2B6:
    PLY 
    PLP 
    RTL 

  loc_02A2B9:
    LDX $02
    SEP #$20
    LDA $effectLayerTilemap, X
    PHA 
    LDX $00
    STA $3E
    LDA [$3E]
    BEQ loc_02A2CE
    STA $collisionLayer, X

  loc_02A2CE:
    PLA 
    STA $effectLayerTilemap, X
    REP #$20
    DEC $9E
    BEQ loc_02A2ED
    JSL $@map_coords.MapIndexMoveRight
    PHX 
    LDA $00
    STA $02
    JSL $@map_coords.MapIndexMoveRight
    STX $00
    PLX 
    STX $02
    BRA loc_02A2B9

  loc_02A2ED:
    DEC $A0
    BEQ loc_02A30D
    LDA $A2
    STA $9E
    LDA $1A
    STA $02
    JSL $@map_coords.MapIndexMoveDown_L1
    STX $00
    STX $1A
    LDA $1E
    STA $02
    JSL $@map_coords.MapIndexMoveDown_L1
    STX $1E
    BRA loc_02A2B9

  loc_02A30D:
    PLY 
    PLP 
    RTL 
}

FlushVramWriteQueue {
    TSX 
    LDY $dmaSkipFlag
    BEQ loc_02A32F
    REP #$20
    LDA #$07FF
    TCS 

  loc_02A31C:
    PLA 
    BEQ loc_02A328
    STA $VMADDL
    PLA 
    STA $VMDATAL
    BRA loc_02A31C

  loc_02A328:
    TXS 
    STZ $dmaSkipFlag
    SEP #$20
    RTL 

  loc_02A32F:
    TXS 
    LDA #$80
    STA $VMAIN
    REP #$20
    LDA $tileQueryResult
    BEQ loc_02A35D
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

  loc_02A35D:
    STZ $tileQueryResult
    SEP #$20
    RTL 
}

LookupEventBlock {
    ASL 
    ASL 
    ASL 
    TAY 
    STA $00A8
    LDA $&event_block_table, Y
    AND #$00FF
    CMP $sceneCurrent
    BNE loc_02A3A6
    PHD 
    LDA #$0000
    TCD 
    SEP #$20
    LDA $&event_block_table+7, Y
    STA $A4
    LDA $&event_block_table+5, Y
    STA $9A
    LDA $&event_block_table+6, Y
    STA $9C
    LDA $&event_block_table+1, Y
    STA $96
    LDA $&event_block_table+2, Y
    STA $98
    LDA $&event_block_table+3, Y
    STA $A2
    STA $9E
    LDA $&event_block_table+4, Y
    STA $A0
    PLD 
    REP #$20
    CLC 
    RTL 

  loc_02A3A6:
    SEC 
    RTL 
}

AnimateEventBlock {
    PHX 
    PHD 
    LDA #$0000
    TCD 

  code_02A3AE:
    STA $A6
    LDA $A4
    AND #$00FF
    BEQ loc_02A3BC
    LDA #$0002
    STA $A6

  loc_02A3BC:
    LDY #$0000

  code_02A3BF:
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
    JSL $@map_coords.TileCoordsToMapIndex
    STX $00
    LDA $96
    STA $18
    LDA $98
    STA $1C
    LDX $A6
    JSL $@map_coords.TileCoordsToMapIndex
    STX $02
    LDA $A6
    BNE code_02A443

  loc_02A3EF:
    LDX $02
    SEP #$20
    LDA $mapLayerTilemap, X
    PHA 
    LDA $collisionLayer, X
    LDX $00
    STA $collisionLayer, X
    PLA 
    STA $mapLayerTilemap, X
    JSR $&QueueVisibleTileVram
    BCS loc_02A40E
    BEQ loc_02A41C

  loc_02A40E:
    REP #$20
    JSR $&AdvanceEventColumn
    BCC loc_02A3EF
    JSR $&AdvanceEventRow
    BCS loc_02A439
    BRA code_02A3BF

  loc_02A41C:
    REP #$20
    JSR $&AdvanceEventColumn
    BCC loc_02A428
    JSR $&AdvanceEventRow
    BCS loc_02A439

  loc_02A428:
    LDA #$0000
    STA $dmaSkipFlag, Y
    SEP #$20
    JSL $@system_core.UpdateFrameDialogue
    REP #$20
    JMP $&code_02A3AE

  loc_02A439:
    LDA #$0000
    STA $dmaSkipFlag, Y
    PLD 
    PLX 
    SEC 
    RTL 

  code_02A443:
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
    BEQ loc_02A462
    STA $collisionLayer, X

  loc_02A462:
    PLA 
    STA $effectLayerTilemap, X
    REP #$20
    LDA $1A
    CLC 
    ADC #$0010
    SEC 
    SBC $bg1ScrollV
    CMP #$0111
    BCS loc_02A4DF
    LDA $savedCameraDelta
    SEC 
    SBC #$0010
    AND #$FFF0
    PHA 
    LDA $1E
    SEC 
    SBC $01, S
    BMI loc_02A4DE
    CMP #$00F1
    BCS loc_02A4DE
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
    JSL $@map_coords.PixelToVramAddress
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
    BEQ loc_02A4EF
    BRA loc_02A4DF

  loc_02A4DE:
    PLA 

  loc_02A4DF:
    JSR $&AdvanceEventColumn
    BCS loc_02A4E7
    JMP $&code_02A443

  loc_02A4E7:
    JSR $&AdvanceEventRow
    BCS loc_02A503
    JMP $&code_02A3BF

  loc_02A4EF:
    JSR $&AdvanceEventColumn
    BCC loc_02A4F9
    JSR $&AdvanceEventRow
    BCS loc_02A503

  loc_02A4F9:
    LDA #$0000
    STA $dmaSkipFlag, Y
    PLD 
    PLX 
    CLC 
    RTL 

  loc_02A503:
    LDA #$0000
    STA $dmaSkipFlag, Y
    PLD 
    PLX 
    SEC 
    RTL 
}

QueueVisibleTileVram {
    PHP 
    REP #$20
    LDA $1A
    CLC 
    ADC #$0010
    SEC 
    SBC $bg1ScrollH
    CMP #$0111
    BCS loc_02A588
    LDA $bg2ScrollH
    SEC 
    SBC #$0010
    AND #$FFF0
    PHA 
    LDA $1E
    SEC 
    SBC $01, S
    BMI loc_02A587
    CMP #$00F1
    BCS loc_02A587
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
    JSL $@map_coords.PixelToVramAddress
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
    BEQ loc_02A582
    PLP 
    CLC 
    RTS 

  loc_02A582:
    PLP 
    LDX #$0000
    RTS 

  loc_02A587:
    PLA 

  loc_02A588:
    PLP 
    SEC 
    RTS 
}

AdvanceEventColumn {
    SEC 
    DEC $9E
    BNE loc_02A591
    RTS 

  loc_02A591:
    LDA $1A
    CLC 
    ADC #$0010
    STA $1A
    INC $96
    INC $9A
    JSL $@map_coords.MapIndexMoveRight
    PHX 
    LDA $00
    STA $02
    JSL $@map_coords.MapIndexMoveRight
    STX $00
    PLX 
    STX $02
    CLC 
    RTS 
}

AdvanceEventRow {
    SEC 
    DEC $A0
    BNE loc_02A5B7
    RTS 

  loc_02A5B7:
    LDA $1E
    CLC 
    ADC #$0010
    STA $1E
    INC $98
    INC $9C
    LDX $A8
    LDA $@event_block_table+1, X
    AND #$00FF
    STA $96
    LDA $@event_block_table+5, X
    AND #$00FF
    STA $9A
    LDA $A2
    STA $9E
    CLC 
    RTS 
}