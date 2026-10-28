; Scanline-band HDMA thinker driven by parallax_scroll_table (Bank 00, 47245-48013). One spawn = one HDMA channel that rewrites a single PPU register per scanline band every frame. Only some table entries scroll a background: others stream COLDATA / CGADSUB / CGDATA colour values or a WH0/WH1 window rectangle through the same band format.
; 
; === SPAWN AND FRAME FLOW ===
; 
; thinker-def <#04,#08>: the filter word is $0804, so bit 2 puts it in RunThinkers_Hdma. That pass runs every frame right after ResetHdmaState, so the channel binding is redone every frame. The spawn-record parameter byte (animScratch+2) is the INDEX into parallax_scroll_table (37 word pointers, $00-$24).
; 1. Entry (once): ParallaxClearBandAccumulators zeroes the 24 band accumulators at $0720-$074F and chatPtr is set to 0.
; 2. SetEntryHere, then every frame: chatPtr is copied to the global word $0012 and incremented (a frame counter whose bit 0 picks the buffer half), ParallaxBuildHdmaTable rewrites the whole table, and SetupHdmaChannel_Direct binds it to the B-bus register from the entry config (A = register index << 8 | bank $7E, Y = table start). The thinker then leaves $0060 = 1 and $005E = 0.
; 
; === TABLE ENTRY FORMAT (parallax_scroll_table) ===
; 
; | Offset | Meaning |
; |--------|---------|
; | +0 word | WRAM buffer address in bank $7E. Even frames build there, odd frames at +$0200 (double buffer: the HDMA channel reads the half written last frame) |
; | +2 byte | Bank $7E |
; | +3 byte | Config: bits 0-5 = B-bus register index n ($2100 + n; also the index into hdma_channel_config); bit 6 ($40) = camera delta x16; bit 7 ($80) = swap the scroll sources (below) |
; | +4 byte | Record size: 4 = constant band, 8 = scroll band, 9 = window rectangle |
; | +5 ... | Records, ended by a zero height word (size 4 / 8) or a word with bit 15 set (size 9). An entry that is just $FFFF is unused |
; 
; Buffers: $7000, $7400, $7800, $7C00, $8000 and $8400, 1 KB each (two $200 halves). Scenes with two or more parallax thinkers (2B, 2D, 2E, 2F, DF, E0, E3) give them different buffers.
; 
; === SCROLL SOURCES AND STRIDE ===
; 
; Default: $18 = bg1ScrollH ($068A, BG1 horizontal scroll) as the multiplicand for proportional bands, and $1C = effectScrollV ($0690, BG2 vertical scroll) as the vertical position that the band heights are measured against. With config bit 7 the sources become $18 = effectScrollH ($068C, BG2 horizontal) and $1C = mapScrollV ($068E, BG1 vertical). $1A = effectDeltaX ($06E4, this frame's camera X delta), shifted left 4 times with config bit 6.
; ParallaxResolveEntryStride sets $04 = hdma_entry_stride_by_mode[hdma_channel_config[n] & 7]. That byte is the HDMA ENTRY STRIDE (count byte plus data): 2 for transfer mode 0 (one byte) and 3 for modes 1 and 2 (one word). It is not a speed. The band writers advance the buffer pointer $62 by $04 per entry.
; 
; === RECORD TYPES ===
; 
; Size 4 (colour bands): {height word, value word}. The height is a NEGATIVE line count. $1C accumulates the heights; bands whose running sum is still >= 0 lie above the visible area and are skipped. The first band that makes the sum negative starts the table with |sum| lines; later bands use |height|. Each band is written as count byte (at most $7F lines per HDMA entry, longer bands are split) plus the 1 or 2 value bytes. The value word is read from record +2.
; Size 8 (scroll bands): {height word, accumulator pointer, factor word, base word}. The accumulator pointer addresses a word in $0720-$0760. Factor <> 0: MulDivide(A = factor, Y = $18) = (factor low byte x $18) / factor high byte, plus base. This is fixed point with 4 fractional bits: factor $0108 is x0.5 and $0110 is x1.0 of the scroll value, $010E is x0.875. Factor = 0: accumulator += base + $1A, an auto-scroll of base/16 pixels per frame that also follows the camera delta. The value stored per HDMA entry is the accumulator >> 4 with the sign extended from bit 11. Bands above the visible area still update their accumulator; bands below the 224-line budget are not processed.
; Size 9 (window rectangles, register $2126/$2127 pair WH0/WH1): {x, width, y, height} in map pixels. Each rectangle is converted against bg1ScrollH and mapScrollV into a WH0 (left) / WH1 (right) byte pair. Lines between rectangles get the value $0000. Horizontally a rectangle is skipped when it starts at column $FF or beyond, ends left of the screen, or starts left of the screen and its right edge is at column $FF or beyond; otherwise the right edge is clamped to $FF. Vertically it is skipped when its top is at line $FF or beyond or, if it starts above the screen, when its bottom is at or above line 0 or at line $FF or beyond. The table ends with one more $0000 line.
; 
; === ENTRIES USED BY SCENES ===
; 
; | Type | Register / content | Buffer | Scenes (spawn lists) |
; |------|--------------------|--------|----------------------|
; | $00 | BG2HOFS: 7 scroll bands (5 proportional, 2 auto) | $7800 | 0A |
; | $01 | BG2HOFS: 4 scroll bands (1 proportional, 3 auto) | $7800 | 15, 1A, 1C |
; | $02 | COLDATA: 96 constant bands | $7C00 | 02-08, 16-18, 2A, 31, 33-38, 3A-3C, 49, 56, 5E, 79-7E, 92-9D, AD, AE, C4-C9, DF, E0, E3 |
; | $03 | BG2HOFS (delta x16): 11 scroll bands (0 proportional, 11 auto) | $8000 | FD, FF |
; | $05 | BG2HOFS (delta x16): 29 scroll bands (0 proportional, 29 auto) | $8000 | 2B-2E |
; | $06 | COLDATA: 24 constant bands | $7400 | 2B, 2D, 2F |
; | $07 | CGADSUB: 2 constant bands | $7800 | 2D |
; | $08 | COLDATA: 24 constant bands | $7C00 | 2D, 2E |
; | $0A | COLDATA: 17 constant bands | $7400 | 29 |
; | $0B | BG1HOFS (delta x16): 7 scroll bands (0 proportional, 7 auto) | $7800 | 1D |
; | $0E | BG2HOFS (delta x16): 2 scroll bands (0 proportional, 2 auto) | $8000 | 2F |
; | $1B | CGDATA: 2 constant bands | $7800 | 5C |
; | $1C | CGADSUB: 2 constant bands | $7400 | 6B |
; | $1D | COLDATA: 23 constant bands | $7400 | 59 |
; | $1E | BG2HOFS: 6 scroll bands (6 proportional, 0 auto) | $7800 | 82, 83, 86-88, 8B |
; | $1F | BG2HOFS: 2 scroll bands (2 proportional, 0 auto) | $7800 | 84, 8A |
; | $20 | window: 1 rectangle(s) | $7000 | C3 |
; | $21 | BG2HOFS: 6 scroll bands (6 proportional, 0 auto) | $7800 | 85 |
; | $23 | BG2HOFS: 1 scroll bands (1 proportional, 0 auto) | $7800 | DF-E1, E3 |
; | $24 | BG1HOFS: 33 scroll bands (0 proportional, 33 auto) | $7800 | E5 |
; 
; Types $04 and $22 (COLDATA bands) and all $FFFF entries are not spawned by any scene thinker list. Type $02 (COLDATA colour gradient) accounts for 53 of the 81 scenes with a parallax thinker; its scene list includes the South Cape interiors 03-08 (which also run flag_gated_palette_cool). Type $03 is spawned by scenes $FD and $FF; scene $FF also spawns inventory_bg3_scroll_hdma, the inventory-screen scene.
; 
; === QUIRKS ===
; 
; - The accumulator clear covers only $0720-$074F, but entry $05 uses accumulators up to $0758 and entry $24 up to $0760. Those extra words are never cleared by this thinker. $0720 is also used by sE7_space_bg_scroll and the F7 credits code, so this region is shared.
; - A table that covers fewer than 224 lines ends with an explicit count-0 byte; the PPU register then simply keeps the last value written for the rest of the frame.
; - The window path hard-codes a 3-byte stride, which only matches register pair WH0/WH1 (mode 1).
; - All reads of the table use absolute addressing under DBR $81, which mirrors ROM bank 01.
; - Runtime behaviour of the individual entries (what the screen looks like) was not checked; see the questions file.
---------------------------------------------

?INCLUDE 'hardware_math'
?INCLUDE 'hdma_dma_spc'
?INCLUDE 'hdma_ramp_tables'
?INCLUDE 'parallax_scroll_table'

!bg1ScrollH                     068A
!effectScrollH                  068C
!mapScrollV                     068E
!effectScrollV                  0690
!effectDeltaX                   06E4
!animScratch                    7F0000
!chatPtr                        7F000A

---------------------------------------------

scanline_band_hdma_thinker [
  thinker-def < #04, #08, {

; Thinker body. Runs once to clear the accumulators, then loops through SetEntryHere every frame: build the table, bind the channel. See the block note for the entry format.

  ParallaxThinkerEntry:
    JSR $&ParallaxClearBandAccumulators ; Spawn only: zero the 24 band accumulators $0720-$074F before the first frame
    LDA #$0000
    STA $chatPtr, X       ; chatPtr (thinker's own word at +$0A) = frame counter, starts at 0
    COP [SetEntryHere]    ; Every later frame resumes here, so the accumulator clear above runs once
    LDA $chatPtr, X
    STA $0012             ; Copy the frame counter to global $0012; the builder tests its bit 0 to choose the buffer half
    INC 
    STA $chatPtr, X       ; Count this frame
    JSR $&ParallaxBuildHdmaTable ; Rewrite the HDMA table for the entry selected by the spawn parameter; returns $02 = register index, $5E / $60 = table start / bank
    SEP #$20
    LDA $0002             ; A low byte = B-bus register index of the entry
    XBA                   ; Move it to the high byte
    LDA $0060             ; A low byte = table bank ($7E), so A = register << 8 | bank
    LDY $005E             ; Y = table start address in bank $7E
    JSL $@hdma_dma_spc.SetupHdmaChannel_Direct ; Bind a free HDMA channel in direct mode to the table (HDMA-phase thinker: runs after ResetHdmaState, so this repeats every frame)
    LDA #$01              ; Leave $60 = 1 ...
    STA $0060
    REP #$20
    STZ $005E             ; ... and $5E = 0 (reason not found, see questions)
    RTL                   ; Back to the thinker runner; resumes at SetEntryHere next frame
} >
]

---------------------------------------------
; Zeroes the 24 words $0720-$074F that hold the per-band scroll accumulators. Called only at spawn, so accumulators persist (and keep running) across frames. Entries that use more than 24 accumulators (types $05 and $24) are not fully covered.

ParallaxClearBandAccumulators {
    LDY #$0000            ; Zero $0720-$074F: 24 words of band accumulators
    LDA #$0000

  loc_00B8C9:
    STA $0720, Y
    INY 
    INY 
    CPY #$0030            ; 48 bytes = 24 words
    BNE loc_00B8C9
    RTS 
}

---------------------------------------------
; Rewrites the whole HDMA table for the entry chosen by the spawn parameter. Switches D to 0 (restored from the stacked X at every exit) so $00-$26 are global scratch: $00 = record size then stride, $02 = register index, $04 = entry stride, $08 = lines emitted (window path), $0E = lines left in the current band, $10 = lines still to fill (starts at 224), $18 = scroll multiplicand, $1A = camera delta, $1C = vertical position, $20-$26 = window working values, $5E / $60 = table start / bank for the HDMA bind, $62 / $64 = write pointer.
; Dispatches on the record size: 4 = ParallaxConstantBandRecords, 9 = ParallaxWindowRecords, anything else (8) = ParallaxScrollBandRecords.

ParallaxBuildHdmaTable {
    PHX                   ; Save the thinker slot; every exit restores D and X from this value
    LDA #$0000
    TCD                   ; D = 0: $00-$26 below are global scratch bytes
    LDA $effectDeltaX     ; Camera X delta of this frame
    STA $1A               ; $1A = camera delta
    LDA #$00E0            ; 224 scanlines to fill
    STA $10               ; $10 = lines still to fill
    LDA $animScratch+2, X ; Spawn parameter byte = table entry index
    ASL                   ; Word table: index x 2
    TAX 
    LDA $&parallax_scroll_table, X ; Entry pointer from parallax_scroll_table (bank 01, read through DBR $81)
    TAX                   ; X = entry pointer
    LDA $0003, X          ; Config byte at entry +3 (the word load also picks up +4)
    BIT #$0040            ; Config bit 6: camera delta x16
    BEQ loc_00B8FD
    LDA $1A               ; Bit 6 set: shift the camera delta left four times ...
    ASL 
    ASL 
    ASL 
    ASL 
    STA $1A               ; ... so auto-scroll bands follow the camera 1:1 in 12.4 fixed point

  loc_00B8FD:
    LDA $effectScrollV    ; Default vertical source: BG2 vertical scroll ($0690)
    STA $1C               ; $1C = vertical position the band heights are measured against
    LDA $bg1ScrollH       ; Default horizontal source: BG1 horizontal scroll ($068A)
    STA $18               ; $18 = multiplicand for proportional bands
    LDA $0003, X
    BIT #$0080            ; Config bit 7: swap the sources
    BEQ loc_00B919
    LDA $mapScrollV       ; Bit 7 set: vertical source = BG1 vertical scroll ($068E) ...
    STA $1C               ; ... into $1C
    LDA $effectScrollH    ; ... and horizontal source = BG2 horizontal scroll ($068C) ...
    STA $18               ; ... into $18

  loc_00B919:
    LDA $0012             ; Frame counter bit 0 chooses the buffer half
    LSR 
    BCS loc_00B92F        ; Odd frame: use the second half
    LDA $0002, X          ; Entry word +2 = bank $7E (low byte) and config (high byte)
    STA $64               ; $64 = bank of the write pointer
    STA $60               ; $60 = bank for the HDMA bind
    LDA $0000, X          ; Entry word +0 = buffer address
    STA $62               ; $62 = write pointer (long pointer $62-$64)
    STA $5E               ; $5E = table start for the HDMA bind
    BRA loc_00B941

  loc_00B92F:
    LDA $0002, X
    STA $64
    STA $60
    LDA $0000, X          ; Odd frame: buffer address + $0200 ...
    CLC 
    ADC #$0200            ; ... second half of the 1 KB buffer
    STA $62
    STA $5E

  loc_00B941:
    LDA $0003, X          ; Low 6 bits of the config select the B-bus register
    AND #$003F
    STA $02               ; $02 = register index
    JSR $&ParallaxResolveEntryStride ; $04 = HDMA entry stride (2 or 3 bytes) for that register
    LDA $0004, X          ; Entry byte +4 = record size
    AND #$00FF
    STA $00               ; $00 = record size (4, 8 or 9)
    TXA 
    CLC 
    ADC #$0005            ; Records start after the 5-byte header
    TAX                   ; X = first record
    LDA $00
    CMP #$0004
    BEQ ParallaxConstantBandRecords ; Size 4: constant colour bands
    CMP #$0009
    BEQ ParallaxWindowRecords ; Size 9: window rectangles; any other size is treated as 8 (scroll bands)

; Scroll-band records (size 8). Walks the records; a band whose running height sum is still non-negative is above the screen and only updates its accumulator (ParallaxComputeBandValue). The first band that crosses into the visible area jumps to ParallaxEmitScrollBands, which emits it and every following band.

  ParallaxScrollBandRecords:
    LDA $0000, X          ; Scroll bands: height word, negative line count; 0 ends the list
    BEQ loc_00B981        ; End of list before any band reached the screen: empty table
    CLC 
    ADC $1C               ; $1C = vertical position + running sum of band heights
    STA $1C
    BMI loc_00B97E        ; Sum became negative: this band is the first visible one
    PHA 
    JSR $&ParallaxComputeBandValue ; Band above the screen: still advance its accumulator so auto-scroll keeps running
    TXA 
    CLC 
    ADC $00               ; Next record: X += record size
    TAX 
    PLA 
    BRA ParallaxScrollBandRecords

  loc_00B97E:
    JSR $&ParallaxEmitScrollBands ; Emit the visible bands until 224 lines are filled or the list ends

  loc_00B981:
    LDA #$0000            ; Table terminator: a count byte of 0 ends the HDMA table ...
    STA [$62]             ; ... written through the long pointer at $62
    STZ $62               ; Clear the write pointer
    STZ $64
    PLA                   ; Restore the thinker slot ...
    TCD                   ; ... into D ...
    TAX                   ; ... and X
    RTS 

; Constant-band records (size 4). Skips bands above the screen, then ParallaxEmitConstantBands emits the rest.

  ParallaxConstantBandRecords:
    LDA $0000, X          ; Colour bands: height word, negative line count; 0 ends the list
    BEQ loc_00B9A6
    CLC 
    ADC $1C               ; Add the height to the running vertical position
    STA $1C
    BMI loc_00B9A3        ; Negative: this band is the first visible one
    TAY 
    TXA 
    CLC 
    ADC $00               ; Skipped band: X += record size
    TAX 
    TYA 
    BRA ParallaxConstantBandRecords

  loc_00B9A3:
    JSR $&ParallaxEmitConstantBands ; Emit the visible constant bands

  loc_00B9A6:
    LDA #$0000            ; Table terminator (count 0)
    STA [$62]
    STZ $62
    STZ $64
    PLA                   ; Restore thinker slot into D and X
    TCD 
    TAX 
    RTS 

; Window-rectangle records (size 9). Each rectangle is clipped against bg1ScrollH / mapScrollV and, if visible, emitted by ParallaxEmitWindowRect. A negative x word ends the list, after which one final $0000 line and the terminator are written.

  ParallaxWindowRecords:
    DEC $00               ; Window records are 8 bytes of data, not 9: stride 9 -> 8
    STZ $08               ; $08 = lines emitted so far

  loc_00B9B7:
    LDA $0000, X          ; Rectangle x; a word with bit 15 set ends the list
    BMI loc_00BA00
    SEC 
    SBC $bg1ScrollH       ; Left edge on screen = x - BG1 horizontal scroll
    BMI loc_00B9C9        ; Negative: starts left of the screen
    CMP #$00FF            ; Left edge at column $FF or beyond: skip
    BCS loc_00B9F9
    BRA loc_00B9D6

  loc_00B9C9:
    CLC 
    ADC $0002, X          ; Starts off screen to the left: right edge = left + width
    BMI loc_00B9F9        ; Entirely off screen to the left: skip
    CMP #$00FF            ; Right edge at column $FF or beyond: skip
    BCS loc_00B9F9
    BRA loc_00B9D6

  loc_00B9D6:
    LDA $0004, X          ; Rectangle y
    SEC 
    SBC $mapScrollV       ; Top edge on screen = y - BG1 vertical scroll
    BMI loc_00B9E9        ; Negative: starts above the screen
    CMP #$00FF            ; Top at line $FF or beyond: skip
    BCS loc_00B9F9
    JSR $&ParallaxEmitWindowRect ; Emit this rectangle
    BRA loc_00B9F9

  loc_00B9E9:
    CLC 
    ADC $0006, X          ; Starts above the screen: bottom edge = top + height
    BEQ loc_00B9F9        ; Bottom edge exactly at the top of the screen: nothing visible
    BMI loc_00B9F9
    CMP #$00FF            ; Bottom edge at line $FF or beyond: skip
    BCS loc_00B9F9
    JSR $&ParallaxEmitWindowRect ; Emit the visible part

  loc_00B9F9:
    TXA                   ; Next record: X += stride
    CLC 
    ADC $00
    TAX 
    BRA loc_00B9B7

  loc_00BA00:
    LDY #$0001            ; End of list: one last line of window value $0000 ...
    LDA #$0001
    STA [$62]             ; ... count byte 1
    LDA #$0000            ; Value $0000 ...
    STA [$62], Y          ; ... written as the data word (1 line) ...
    LDY #$0003
    STA [$62], Y          ; ... and again after the next count slot ...
    LDY #$0004
    STA [$62], Y          ; ... then the terminator byte
    PLA                   ; Restore thinker slot into D and X
    TCD 
    TAX 
    RTS 
}

---------------------------------------------
; Converts one visible rectangle into $24 (first line), $26 (line count) and a WH0/WH1 word (left in the low byte, right in the high byte, right clamped to $FF). A rectangle partly above the screen starts at line 0 with the visible part of its height; one that starts left of the screen gets WH0 = 0.

ParallaxEmitWindowRect {
    LDA $0004, X          ; Rectangle y
    SEC 
    SBC $mapScrollV       ; dy = y - BG1 vertical scroll
    BCS loc_00BA2E        ; dy >= 0: the top edge is on screen
    CLC 
    ADC $0006, X          ; Starts above: visible lines = height + dy
    STA $26               ; $26 = line count
    STZ $24               ; $24 = first line 0
    BRA loc_00BA35

  loc_00BA2E:
    STA $24               ; $24 = first line = dy
    LDA $0006, X          ; Full height is visible
    STA $26               ; $26 = line count

  loc_00BA35:
    LDA $0000, X          ; Rectangle x
    SEC 
    SBC $bg1ScrollH       ; dx = x - BG1 horizontal scroll
    BCS loc_00BA4A        ; dx >= 0: the left edge is on screen
    CLC 
    ADC $0002, X          ; Left of the screen: right edge = dx + width
    AND #$00FF            ; Keep the low byte
    XBA                   ; WH1 (right) in the high byte, WH0 (left) = 0
    STA $20               ; $20 = window word
    BRA loc_00BA5A

  loc_00BA4A:
    STA $20               ; $20 = left edge (WH0)
    CLC 
    ADC $0002, X          ; Right edge = left + width
    CMP #$0100            ; Past column $FF?
    BCC loc_00BA58
    LDA #$FFFF            ; Clamp: right = $FF (high byte of the word)

  loc_00BA58:
    STA $21               ; Right edge into the high byte of the window word

  loc_00BA5A:
    LDY $20               ; Y = window word, left | right << 8
    JSR $&ParallaxEmitWindowRows ; Emit the gap before the rectangle and the rectangle itself
    RTS 
}

---------------------------------------------
; Emits the gap between the previous rectangle and this one (value $0000) and then the rectangle's own lines (the window word in Y). Counts are split into HDMA entries of at most $7F lines and $08 tracks the total. The 3-byte stride is hard-coded.

ParallaxEmitWindowRows {
    LDA $24               ; First line of the rectangle ...
    SEC 
    SBC $08               ; ... minus lines already emitted = gap size
    BEQ loc_00BA91        ; No gap
    STA $0E               ; $0E = gap lines still to emit
    CLC 
    ADC $08
    STA $08               ; Lines emitted += gap
    LDA $0E

  loc_00BA70:
    STZ $0E
    CMP #$0080            ; More than $7F lines?
    BMI loc_00BA80
    SEC 
    SBC #$007F            ; Take $7F now, keep the rest in $0E
    STA $0E
    LDA #$007F

  loc_00BA80:
    STA [$62]             ; Count byte
    INC $62
    LDA #$0000
    STA [$62]             ; Gap value $0000 (WH0 = WH1 = 0)
    INC $62
    INC $62               ; Advance the write pointer by the 3-byte entry
    LDA $0E
    BNE loc_00BA70        ; More gap lines left

  loc_00BA91:
    LDA $26
    CLC 
    ADC $08               ; Lines emitted += rectangle lines
    STA $08
    LDA $26

  loc_00BA9A:
    STZ $26
    CMP #$0080            ; More than $7F lines?
    BMI loc_00BAAA
    SEC 
    SBC #$007F            ; Take $7F now, keep the rest in $26
    STA $26
    LDA #$007F

  loc_00BAAA:
    STA [$62]             ; Count byte
    INC $62
    TYA 
    STA [$62]             ; Window word (left | right << 8)
    INC $62
    INC $62               ; Advance the write pointer by the 3-byte entry
    LDA $26
    BNE loc_00BA9A        ; More lines left in this rectangle
    RTS 
}

---------------------------------------------
; Looks up hdma_channel_config[register index] & 7 (the DMAP transfer mode), then hdma_entry_stride_by_mode[mode] into $04. The result is the byte stride of one HDMA entry (count + data): 2 for mode 0, 3 for modes 1 and 2. It is a stride, not a speed.

ParallaxResolveEntryStride {
    LDA $02               ; $02 = B-bus register index
    TAY 
    LDA $&hdma_ramp_tables.hdma_channel_config, Y ; DMAP transfer mode byte of that register
    AND #$0007            ; Mode in the low 3 bits
    TAY 
    LDA $&hdma_ramp_tables.hdma_entry_stride_by_mode, Y ; Bytes per HDMA entry for that mode (count + data)
    AND #$00FF
    STA $04               ; $04 = stride
    RTS 
}

---------------------------------------------
; Emits scroll bands (size 8) starting at the current record until $10 (lines left) reaches 0 or the list ends. The first band uses only its visible part (-running sum). Each band calls ParallaxComputeBandValue, writes count bytes of at most $7F lines and stores the accumulator >> 4, sign-extended from bit 11, as the value. The band heights it consumes are stored as negative words.

ParallaxEmitScrollBands {
    EOR #$FFFF            ; A = running height sum (negative): negate to the visible line count
    INC 
    PHA 
    JSR $&ParallaxComputeBandValue ; Advance this band's accumulator; its value is left in $06
    LDA $10               ; Lines still to fill ...
    SEC 
    SBC $01, S            ; ... minus this band's lines
    STA $10               ; $10 = remaining
    PLA 

  loc_00BADD:
    STZ $0E
    CMP #$0080            ; More than $7F lines?
    BMI loc_00BAED
    SEC 
    SBC #$007F            ; Take $7F now, keep the rest in $0E
    STA $0E
    LDA #$007F

  loc_00BAED:
    STA [$62]             ; Count byte
    LDY #$0001
    LDA $06               ; Band value in 12.4 fixed point
    LSR 
    LSR 
    LSR 
    LSR                   ; Drop the 4 fractional bits
    BIT #$0800            ; Sign bit of the 12-bit result
    BEQ loc_00BB00
    ORA #$F000            ; Sign-extend

  loc_00BB00:
    STA [$62], Y          ; Data word for this HDMA entry
    LDA $62
    CLC 
    ADC $04               ; Advance the write pointer by the entry stride ($04)
    STA $62
    LDA $0E
    BNE loc_00BADD        ; More lines left in this band
    LDA $10               ; Lines left to fill?
    BPL loc_00BB12
    RTS                   ; 224 lines done: stop

  loc_00BB12:
    TXA 
    CLC 
    ADC $00               ; Next record: X += record size
    TAX 
    LDA $0000, X
    BNE loc_00BB1D        ; Zero height ends the list
    RTS 

  loc_00BB1D:
    BRA ParallaxEmitScrollBands ; Next band
}

---------------------------------------------
; The same loop for constant bands (size 4): value = record word +2 copied unchanged. Used by the COLDATA, CGADSUB and CGDATA entries.

ParallaxEmitConstantBands {
    EOR #$FFFF            ; A = running height sum (negative): negate to the visible line count
    INC 
    PHA 
    LDA $10               ; Lines still to fill ...
    SEC 
    SBC $01, S            ; ... minus this band's lines
    STA $10               ; $10 = remaining
    PLA 

  loc_00BB2C:
    STZ $0E
    CMP #$0080            ; More than $7F lines?
    BMI loc_00BB3C
    SEC 
    SBC #$007F            ; Take $7F now, keep the rest in $0E
    STA $0E
    LDA #$007F

  loc_00BB3C:
    STA [$62]             ; Count byte
    LDA $0002, X          ; Record word +2 = value
    LDY #$0001
    STA [$62], Y          ; Data word for this HDMA entry
    LDA $62
    CLC 
    ADC $04               ; Advance the write pointer by the entry stride ($04)
    STA $62
    LDA $0E
    BNE loc_00BB2C        ; More lines left in this band
    LDA $10               ; Lines left to fill?
    BPL loc_00BB56
    RTS                   ; 224 lines done: stop

  loc_00BB56:
    TXA 
    CLC 
    ADC $00               ; Next record: X += record size
    TAX 
    LDA $0000, X
    BNE loc_00BB61        ; Zero height ends the list
    RTS 

  loc_00BB61:
    BRA ParallaxEmitConstantBands ; Next band
}

---------------------------------------------
; Computes one scroll band's value into $06 and its accumulator word. Factor <> 0: accumulator = (factor low byte x $18 / factor high byte) + base, i.e. a proportional follow of the scroll source. Factor = 0: accumulator += base + $1A, an auto-scroll.

ParallaxComputeBandValue {
    LDA $0004, X          ; Record word +4 = factor; 0 selects the auto-scroll path
    BEQ loc_00BB7B
    LDY $18               ; Y = scroll source ($18)
    JSL $@hardware_math.MulDivide ; (factor low byte x Y) / factor high byte
    CLC 
    ADC $0006, X          ; Plus the band's base value
    LDY $0002, X          ; Record word +2 = accumulator address
    STA $0000, Y          ; Store the result in the accumulator
    STA $06               ; $06 = band value for the caller
    RTS 

  loc_00BB7B:
    LDY $0002, X          ; Auto-scroll: accumulator address
    LDA $0006, X          ; Base = speed in 1/16 pixel per frame
    CLC 
    ADC $0000, Y          ; Plus the old accumulator value ...
    CLC 
    ADC $1A               ; ... plus the camera delta
    STA $0000, Y          ; Store it back
    STA $06               ; $06 = band value for the caller
    RTS 
}