; HDMA channel COP handlers (34382–34579, Bank 00): GenHdmaSine (#00), QueueHdma (#01), QueueDma (#02) and QueueHdmaChannel (#03), 51 script sites in total.
; 
; Shared operand layout for #01–#03: a 3-byte table address followed by a byte naming the PPU B-bus register ($21xx, e.g. #0F = BG2HOFS, #26 = WH0, #1B = M7A). The setup helpers (hdma_dma_spc) use that register number as the index into hdma_channel_config to get the DMAP transfer mode, so the table is really "PPU register → transfer mode".
; 
; All three bind an HDMA channel: #01 uses indirect addressing, #02 uses direct addressing (despite the name it is not a plain DMA), and #03 programs a caller-chosen channel instead of the next free one. Channel allocation starts at channel 1 and is reset by ResetHdmaState. #00 prepares the sine-wave table that #01 then binds.
---------------------------------------------

?BANK 00

?INCLUDE 'cop_handlers_effects'
?INCLUDE 'flag_helpers'
?INCLUDE 'hdma_dma_spc'
?INCLUDE 'hdma_ramp_tables'

!hdmaEnableMask                 0066
!DMAP0                          4300
!BBAD0                          4301
!A1T0L                          4302
!A1B0                           4304
!DASB0                          4307
!spritesetPtr                   7F0006

---------------------------------------------

; COP #00 sine-wave HDMA table generator with no operands (2 sites: sine_hdma_ending_wave and the unused gen_hdma_sine_oneshot). First calls BuildSineLookupTable, which refills the two 256-word tables sineTableA ($7E8900) and sineTableB ($7E8B00, a copy directly after A) from the actor amplitude $7F0008, but only when displayModeFlags bit 6 or animScratch2 bit 0 requests it. Then it writes a 7-byte indirect HDMA table at $7E8800: [$FF, pointer, $E0, pointer+$FE, $00], i.e. 127 repeat-mode scanlines followed by 96 (223 in total), each scanline taking one word from a window of the sine data. spritesetPtr is a phase counter incremented on every call; the window starts at sineTableA + (counter AND $01FE), so the wave slides by one word every second call. It is not a double buffer. A following COP QueueHdma ($7E8800 with B-bus #0F or #10, i.e. BG2HOFS/BG2VOFS) binds the table to a channel.

GenHdmaSine {
    TYX 
    PHP                   ; Save processor state before multiplier/HDMA setup
    JSR $&cop_handlers_effects.BuildSineLookupTable ; Refill sineTableA/B if flagged (hardware multiply by the amplitude)
    LDA $spritesetPtr, X  ; Phase counter, +1 per call
    INC 
    STA $spritesetPtr, X
    AND #$01FE            ; Window offset in bytes: whole words, advances every 2nd call, wraps after 256 words
    CLC 
    ADC #$8900            ; + sineTableA base ($7E8900)
    STA $7E8801           ; Entry 0 data pointer (indirect HDMA)
    CLC 
    ADC #$00FE            ; + $FE = 127 scanlines × 2 bytes: entry 1 continues where entry 0 ends
    STA $7E8804           ; Entry 1 data pointer
    SEP #$20
    LDA #$FF
    STA $7E8800           ; Entry 0 line count $FF = repeat mode, 127 scanlines
    LDA #$E0              ; Entry 1 line count $E0 = repeat mode, 96 scanlines (127 + 96 = 223)
    STA $7E8803
    LDA #$00              ; End-of-table byte
    STA $7E8806
    PLP 
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #01 (18 sites). Operands: a 3-byte table address (word + bank, e.g. $7E8800 or @label) and a byte naming the PPU B-bus register ($21xx, e.g. #0F = BG2HOFS). The handler reads them as two words: Y = address, A = bank (low byte) | register (high byte). SetupHdmaChannel_Indirect then picks the DMAP transfer mode from hdma_channel_config[register], ORs $40 (indirect addressing), uses the bank for both the table and the indirect data, and binds the NEXT free channel (allocated from channel 1 upward via $68/$6A; reset by ResetHdmaState). The channel is armed through the HDMA enable mask ($66).

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
; COP #02 (28 sites). Same operands as QueueHdma (3-byte table address, B-bus register byte; used for window position registers #26, mode 7 matrix registers #1B–#1E, scroll registers and others). It calls SetupHdmaChannel_Direct, which writes DMAP WITHOUT the $40 flag and still sets the channel's bit in the HDMA enable mask, so this is a DIRECT-table HDMA channel (each table entry holds the register data inline), not a general linear DMA transfer. The name QueueDma is misleading; QueueHdma is the indirect variant.

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
; COP #03 (2 sites, both in scene_lifecycle: channels 6 and 7 for the BG1/BG2 horizontal scroll window). Operands: a byte channel number (0–7), a 3-byte table address, and a byte B-bus register. Unlike #01/#02 it programs the named channel directly: register block offset = channel × 16 ($4300 + offset), channel bit ORed into the HDMA enable mask $66, DMAP = hdma_channel_config[register] | $40 (indirect), DASB = A1B = bank, BBAD = register, A1T = table address. The handler PHYs the slot and PLXes it back at the end instead of using TYX, and uses WRAM $0000/$0002 as scratch.

QueueHdmaChannel {
    PHY 
    LDA [$0A]             ; Channel number byte (0–7)
    INC $0A
    AND #$00FF
    STA $0002             ; Scratch: channel number, used as the bit-mask table index
    ASL                   ; Channel × 16: offset into $4300 DMA register block
    ASL 
    ASL 
    ASL 
    STA $0000
    LDX $0002
    SEP #$20
    LDA $@flag_helpers.bitmasks_bit_position, X ; Look up single-bit channel mask from position table
    TSB $hdmaEnableMask   ; OR channel bit into cached HDMA enable mask ($0066)
    REP #$20
    LDA [$0A]             ; Table address (low word) from the script
    INC $0A
    INC $0A
    TAY 
    LDA [$0A]             ; Bank byte (low) + B-bus register byte (high)
    INC $0A
    INC $0A
    PHP 
    SEP #$20
    PHA 
    LDA #$00
    XBA 
    PHA 
    TAX 
    LDA $&hdma_ramp_tables.hdma_channel_config, X ; X = B-bus register: DMAP transfer mode for that PPU register
    LDX $0000
    ORA #$40              ; DMAP bit 6 = HDMA transfer mode (not linear DMA)
    STA $DMAP0, X         ; Write DMAP transfer mode for this HDMA channel
    LDA $02, S            ; Bank byte (pushed first, under the register byte)
    STA $DASB0, X         ; Indirect data bank
    PLA                   ; B-bus register byte
    STA $BBAD0, X         ; Write B-bus destination register (BBAD)
    REP #$20
    TYA 
    STA $A1T0L, X         ; Write A-bus source address low word (A1TL)
    SEP #$20
    PLA 
    STA $A1B0, X          ; Table bank (same byte as the indirect data bank)
    PLP 
    PLX 
    LDA $0A
    STA $02, S
    RTI 
}