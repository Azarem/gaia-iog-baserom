; Per-frame HDMA thinker that configures multi-layer background parallax scrolling from the parallax_scroll_table indexed by the spawning actor's animScratch.
; 
; Clears HDMA scratch at $0720, computes per-region scroll offsets from camera delta and BG scroll registers, and programs HDMA channels via SetupHdmaChannel_Direct. Spawned on many overworld and dungeon scenes (Edward Castle, Itory, Incan Ruins, inventory screen, and others). Enables layered cloud, water, and background depth effects.
---------------------------------------------

?INCLUDE 'hardware_math'
?INCLUDE 'hdma_dma_spc'
?INCLUDE 'hdma_ramp_tables'
?INCLUDE 'parallax_scroll_table'

!bg1ScrollH                     068A
!bg1ScrollV                     068C
!bg2ScrollH                     068E
!savedCameraDelta               0690
!effectDeltaX                   06E4
!animScratch                    7F0000
!chatPtr                        7F000A

---------------------------------------------

parallax_thinker [
  thinker-def < #04, #08, {

  code_00B88D:
    JSR $&ParallaxClearHdmaScratch ; Parallax thinker: clear HDMA scratch, SetEntryHere, bind channel
    LDA #$0000
    STA $chatPtr, X
    COP [SetEntryHere]
    LDA $chatPtr, X
    STA $0012
    INC 
    STA $chatPtr, X
    JSR $&ParallaxBuildHdmaTable
    SEP #$20
    LDA $0002
    XBA 
    LDA $0060
    LDY $005E
    JSL $@hdma_dma_spc.SetupHdmaChannel_Direct
    LDA #$01
    STA $0060
    REP #$20
    STZ $005E
    RTL 
} >
]

ParallaxClearHdmaScratch {
    LDY #$0000            ; Zero 48 bytes ($30 words) of parallax HDMA staging buffer at $0720
    LDA #$0000

  loc_00B8C9:
    STA $0720, Y
    INY 
    INY 
    CPY #$0030
    BNE loc_00B8C9
    RTS 
}

ParallaxBuildHdmaTable {
    PHX                   ; Index parallax_scroll_table by animScratch2×2 to select layer scroll config
    LDA #$0000
    TCD 
    LDA $effectDeltaX
    STA $1A
    LDA #$00E0
    STA $10
    LDA $animScratch+2, X
    ASL 
    TAX 
    LDA $&parallax_scroll_table, X
    TAX 
    LDA $0003, X
    BIT #$0040
    BEQ loc_00B8FD
    LDA $1A
    ASL 
    ASL 
    ASL 
    ASL 
    STA $1A

  loc_00B8FD:
    LDA $savedCameraDelta ; Config bit $40: left-shift effectDeltaX×4 before adding to scroll accumulator
    STA $1C
    LDA $bg1ScrollH
    STA $18
    LDA $0003, X
    BIT #$0080
    BEQ loc_00B919
    LDA $bg2ScrollH
    STA $1C
    LDA $bg1ScrollV
    STA $18

  loc_00B919:
    LDA $0012             ; Config bit $80: swap scroll inputs to BG2H horizontal + BG1V vertical
    LSR 
    BCS loc_00B92F
    LDA $0002, X
    STA $64
    STA $60
    LDA $0000, X
    STA $62
    STA $5E
    BRA loc_00B941

  loc_00B92F:
    LDA $0002, X
    STA $64
    STA $60
    LDA $0000, X
    CLC 
    ADC #$0200
    STA $62
    STA $5E

  loc_00B941:
    LDA $0003, X          ; Lower 6 bits of config select hdma_channel_config and parallax_speed_config row
    AND #$003F
    STA $02
    JSR $&ParallaxResolveChannelSpeed
    LDA $0004, X
    AND #$00FF
    STA $00
    TXA 
    CLC 
    ADC #$0005
    TAX 
    LDA $00
    CMP #$0004
    BEQ loc_00B98E
    CMP #$0009
    BEQ loc_00B9B3

  loc_00B966:
    LDA $0000, X          ; Mode 9 HDMA: compare ramp breakpoints against live BG1/BG2 scroll registers
    BEQ loc_00B981
    CLC 
    ADC $1C
    STA $1C
    BMI loc_00B97E
    PHA 
    JSR $&ParallaxApplyScrollOffset
    TXA 
    CLC 
    ADC $00
    TAX 
    PLA 
    BRA loc_00B966

  loc_00B97E:
    JSR $&ParallaxWriteNegativeScrollRamp

  loc_00B981:
    LDA #$0000
    STA [$62]
    STZ $62
    STZ $64
    PLA 
    TCD 
    TAX 
    RTS 

  loc_00B98E:
    LDA $0000, X
    BEQ loc_00B9A6
    CLC 
    ADC $1C
    STA $1C
    BMI loc_00B9A3
    TAY 
    TXA 
    CLC 
    ADC $00
    TAX 
    TYA 
    BRA loc_00B98E

  loc_00B9A3:
    JSR $&ParallaxWriteNegativeScrollRampY

  loc_00B9A6:
    LDA #$0000
    STA [$62]
    STZ $62
    STZ $64
    PLA 
    TCD 
    TAX 
    RTS 

  loc_00B9B3:
    DEC $00
    STZ $08

  loc_00B9B7:
    LDA $0000, X
    BMI loc_00BA00
    SEC 
    SBC $bg1ScrollH
    BMI loc_00B9C9
    CMP #$00FF
    BCS loc_00B9F9
    BRA loc_00B9D6

  loc_00B9C9:
    CLC 
    ADC $0002, X
    BMI loc_00B9F9
    CMP #$00FF
    BCS loc_00B9F9
    BRA loc_00B9D6

  loc_00B9D6:
    LDA $0004, X
    SEC 
    SBC $bg2ScrollH
    BMI loc_00B9E9
    CMP #$00FF
    BCS loc_00B9F9
    JSR $&ParallaxWriteWindowHdmaEntry
    BRA loc_00B9F9

  loc_00B9E9:
    CLC 
    ADC $0006, X
    BEQ loc_00B9F9
    BMI loc_00B9F9
    CMP #$00FF
    BCS loc_00B9F9
    JSR $&ParallaxWriteWindowHdmaEntry

  loc_00B9F9:
    TXA 
    CLC 
    ADC $00
    TAX 
    BRA loc_00B9B7

  loc_00BA00:
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

ParallaxWriteWindowHdmaEntry {
    LDA $0004, X
    SEC 
    SBC $bg2ScrollH
    BCS loc_00BA2E
    CLC 
    ADC $0006, X
    STA $26
    STZ $24
    BRA loc_00BA35

  loc_00BA2E:
    STA $24
    LDA $0006, X
    STA $26

  loc_00BA35:
    LDA $0000, X
    SEC 
    SBC $bg1ScrollH
    BCS loc_00BA4A
    CLC 
    ADC $0002, X
    AND #$00FF
    XBA 
    STA $20
    BRA loc_00BA5A

  loc_00BA4A:
    STA $20
    CLC 
    ADC $0002, X
    CMP #$0100
    BCC loc_00BA58
    LDA #$FFFF

  loc_00BA58:
    STA $21

  loc_00BA5A:
    LDY $20
    JSR $&ParallaxFillHdmaRampRow
    RTS 
}

ParallaxFillHdmaRampRow {
    LDA $24
    SEC 
    SBC $08
    BEQ loc_00BA91
    STA $0E
    CLC 
    ADC $08
    STA $08
    LDA $0E

  loc_00BA70:
    STZ $0E
    CMP #$0080
    BMI loc_00BA80
    SEC 
    SBC #$007F
    STA $0E
    LDA #$007F

  loc_00BA80:
    STA [$62]
    INC $62
    LDA #$0000
    STA [$62]
    INC $62
    INC $62
    LDA $0E
    BNE loc_00BA70

  loc_00BA91:
    LDA $26
    CLC 
    ADC $08
    STA $08
    LDA $26

  loc_00BA9A:
    STZ $26
    CMP #$0080
    BMI loc_00BAAA
    SEC 
    SBC #$007F
    STA $26
    LDA #$007F

  loc_00BAAA:
    STA [$62]
    INC $62
    TYA 
    STA [$62]
    INC $62
    INC $62
    LDA $26
    BNE loc_00BA9A
    RTS 
}

ParallaxResolveChannelSpeed {
    LDA $02               ; Mask channel index to 3 bits; look up DMAP transfer mode and speed divisor
    TAY 
    LDA $&hdma_ramp_tables.hdma_channel_config, Y
    AND #$0007
    TAY 
    LDA $&hdma_ramp_tables.parallax_speed_config, Y
    AND #$00FF
    STA $04
    RTS 
}

ParallaxWriteNegativeScrollRamp {
    EOR #$FFFF            ; Negative scroll ramp: emit $7F scanline HDMA entries with nibble scroll high bytes
    INC 
    PHA 
    JSR $&ParallaxApplyScrollOffset
    LDA $10
    SEC 
    SBC $01, S
    STA $10
    PLA 

  loc_00BADD:
    STZ $0E
    CMP #$0080
    BMI loc_00BAED
    SEC 
    SBC #$007F
    STA $0E
    LDA #$007F

  loc_00BAED:
    STA [$62]
    LDY #$0001
    LDA $06
    LSR 
    LSR 
    LSR 
    LSR 
    BIT #$0800
    BEQ loc_00BB00
    ORA #$F000

  loc_00BB00:
    STA [$62], Y
    LDA $62
    CLC 
    ADC $04
    STA $62
    LDA $0E
    BNE loc_00BADD
    LDA $10
    BPL loc_00BB12
    RTS 

  loc_00BB12:
    TXA 
    CLC 
    ADC $00
    TAX 
    LDA $0000, X
    BNE loc_00BB1D
    RTS 

  loc_00BB1D:
    BRA ParallaxWriteNegativeScrollRamp
}

ParallaxWriteNegativeScrollRampY {
    EOR #$FFFF
    INC 
    PHA 
    LDA $10
    SEC 
    SBC $01, S
    STA $10
    PLA 

  loc_00BB2C:
    STZ $0E
    CMP #$0080
    BMI loc_00BB3C
    SEC 
    SBC #$007F
    STA $0E
    LDA #$007F

  loc_00BB3C:
    STA [$62]
    LDA $0002, X
    LDY #$0001
    STA [$62], Y
    LDA $62
    CLC 
    ADC $04
    STA $62
    LDA $0E
    BNE loc_00BB2C
    LDA $10
    BPL loc_00BB56
    RTS 

  loc_00BB56:
    TXA 
    CLC 
    ADC $00
    TAX 
    LDA $0000, X
    BNE loc_00BB61
    RTS 

  loc_00BB61:
    BRA ParallaxWriteNegativeScrollRampY
}

ParallaxApplyScrollOffset {
    LDA $0004, X          ; Zero scroll-factor path: accumulate offset from linked WRAM table plus effectDeltaX
    BEQ loc_00BB7B
    LDY $18
    JSL $@hardware_math.MulDivide
    CLC 
    ADC $0006, X
    LDY $0002, X
    STA $0000, Y
    STA $06
    RTS 

  loc_00BB7B:
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