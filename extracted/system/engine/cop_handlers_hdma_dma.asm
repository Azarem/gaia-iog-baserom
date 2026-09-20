?BANK 00

?INCLUDE 'cop_handlers_effects'
?INCLUDE 'flag_helpers'
?INCLUDE 'hdma_dma_spc'
?INCLUDE 'hdma_ramp_tables'

!DMAP0                          4300
!BBAD0                          4301
!A1T0L                          4302
!A1B0                           4304
!DASB0                          4307
!spritesetPtr                   7F0006

---------------------------------------------

; COP #00 HDMA sine-table generator with no script operands. Calls BuildSineLookupTable to fill a 512-entry sine wave at WRAM $7E8800+ using the actor amplitude byte at $7F0008, then writes a three-entry HDMA indirect table. Double-buffers via spritesetPtr so regenerated tables alternate between $8800 and $8900 offsets. Callers include sine_hdma_ending_wave and the unused gen_hdma_sine_oneshot path, typically followed by COP QueueHdma.

GenHdmaSine {
    TYX 
    PHP                   ; Save processor state before multiplier/HDMA setup
    JSR $&cop_handlers_effects.BuildSineLookupTable ; Build 512-entry sine lookup via SNES hardware multiplier ($4202/$4203)
    LDA $spritesetPtr, X  ; Read and increment sine buffer ping-pong index
    INC 
    STA $spritesetPtr, X
    AND #$01FE            ; Toggle between $8900/$8A00 double-buffer pages
    CLC 
    ADC #$8900            ; HDMA source pointer into WRAM sineTableA
    STA $7E8801           ; HDMA indirect table entry 0: source address in sine buffer
    CLC 
    ADC #$00FE            ; +$00FE: second half of sine data for table entry 1
    STA $7E8804
    SEP #$20
    LDA #$FF
    STA $7E8800           ; HDMA table entry 0: $FF terminator byte
    LDA #$E0              ; HDMA entry 1 line count: $E0 (224 remaining visible scanlines)
    STA $7E8803           ; HDMA table entry 1: $E0 → CGRAM (palette) write port
    LDA #$00              ; HDMA entry 2: $00 terminator (end of indirect table)
    STA $7E8806           ; HDMA table entry 2: $00 line-count terminator
    PLP 
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #01 with two word operands (HDMA table address, channel configuration word). Reads both from the script pointer and calls SetupHdmaChannel_Indirect to queue an indirect HDMA transfer.

QueueHdma {
    TYX 
    LDA [$0A]             ; Read HDMA table address word from script
    INC $0A
    INC $0A
    TAY 
    LDA [$0A]             ; Read channel configuration word
    INC $0A
    INC $0A
    JSL $@hdma_dma_spc.SetupHdmaChannel_Indirect ; Configure HDMA channel with indirect addressing mode
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #02 with two word operands (source/destination setup words). Passes them to SetupHdmaChannel_Direct to configure a linear DMA channel rather than indirect HDMA.

QueueDma {
    TYX 
    LDA [$0A]             ; Read DMA source/dest setup word
    INC $0A
    INC $0A
    TAY 
    LDA [$0A]             ; Read second DMA configuration word
    INC $0A
    INC $0A
    JSL $@hdma_dma_spc.SetupHdmaChannel_Direct ; Configure linear DMA channel (non-HDMA transfer)
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #03 with one byte (channel ID) plus two words (A-bus table address, then B-bus register byte in low 8 bits and source bank in high 8 bits). Computes the $4300 register block offset as channel×16, ORs the channel bit into cached HDMA enable mask $0066, looks up transfer mode from hdma_channel_config, ORs #$40 into DMAP for HDMA mode, and writes DMAP/BBAD/A1T/A1B for that channel.

QueueHdmaChannel {
    PHY 
    LDA [$0A]             ; Read HDMA channel ID byte (0–7)
    INC $0A
    AND #$00FF
    STA $0002             ; Save channel ID in $0002 for bitmask lookup
    ASL                   ; Channel × 16: offset into $4300 DMA register block
    ASL 
    ASL 
    ASL 
    STA $0000
    LDX $0002
    SEP #$20
    LDA $@flag_helpers.bitmasks_bit_position, X ; Look up single-bit channel mask from position table
    TSB $0066             ; OR channel bit into cached HDMA enable mask ($0066)
    REP #$20
    LDA [$0A]             ; Read HDMA A-bus table address word from script
    INC $0A
    INC $0A
    TAY 
    LDA [$0A]             ; Read packed B-bus register byte (low) + source bank (high)
    INC $0A
    INC $0A
    PHP 
    SEP #$20
    PHA 
    LDA #$00
    XBA 
    PHA 
    TAX 
    LDA $&hdma_ramp_tables.hdma_channel_config, X ; Look up transfer mode from hdma_channel_config table
    LDX $0000
    ORA #$40              ; DMAP bit 6 = HDMA transfer mode (not linear DMA)
    STA $DMAP0, X         ; Write DMAP transfer mode for this HDMA channel
    LDA $02, S
    STA $DASB0, X
    PLA 
    STA $BBAD0, X         ; Write B-bus destination register (BBAD)
    REP #$20
    TYA 
    STA $A1T0L, X         ; Write A-bus source address low word (A1TL)
    SEP #$20
    PLA 
    STA $A1B0, X          ; A-bus source bank byte for HDMA fetch
    PLP 
    PLX 
    LDA $0A
    STA $02, S
    RTI 
}