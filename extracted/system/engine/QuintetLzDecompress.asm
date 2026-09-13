; QuintetLZ decompression engine (164464–164770, Bank 02).
; 
; Implements the LZSS-variant compression algorithm used across Quintet (Enix) games — Illusion of Gaia, Soul Blazer, and Robotrek — for compressing graphics, tilemaps, and other data.
; 
; === ALGORITHM ===
; Dictionary-based compression with a 256-byte sliding window. A bitstream control layer determines token types:
; - Bit = 1 → Literal: read 8 bits via LzReadBitField, write byte to output and dictionary
; - Bit = 0 → Back-reference: read 8-bit dictionary index via LzReadBitField, then 4-bit length via LzReadBackRef. Copy (length + 2) bytes from dictionary to both output and dictionary write position
; 
; The dictionary is initialized to $20 (space character), providing good compression for text-heavy data. The starting write position is $EF (DICTIONARY_OFFSET), matching the Quintet standard across all three games.
; 
; === BITSTREAM FORMAT ===
; Bits are read MSB-first within each source byte. DP $72 holds a one-hot bit mask starting at $80 (bit 7). Each control bit consumed shifts the mask right via LSR. When the mask shifts out entirely (all 8 bits consumed), it resets to $80 via ROR and the source pointer [$3E] advances.
; 
; LzReadBitField (8-bit read) and LzReadBackRef (4-bit nibble read) both use optimized bit-position cascades. When the required bits straddle a byte boundary, they read a 16-bit word from the source, XBA to swap byte order, and enter ASL or LSR fall-through cascades to align the result.
; 
; === WRAM LAYOUT ===
; $3E/$3F/$40: 24-bit source pointer to compressed data (past the 2-byte size header)
; $72: Bit mask — one-hot, MSB-first, resets to $80 on byte boundary
; $74/$75: Dictionary write pointer (low byte = position within 256-byte page at $7E0200)
; $76/$77: Back-reference read pointer (same $02xx page; set per back-ref token)
; $78/$79: Decompressed byte count (loaded into Y as countdown)
; $7A/$7B: Output buffer absolute address (loaded into X for STA $0000,X)
; $7E0200–$7E02FF: 256-byte sliding dictionary (WRAM bank $7E)
; 
; === ENTRY CONDITIONS ===
; Caller sets: [$3E] = source pointer (past size header), $78 = decompressed size, $7A = output address. Data bank is set to $7E internally. All registers preserved across the call.
; 
; Reference: QuintetLZ class in @gaialabs/core (src/compression/QuintetLZ.ts).
---------------------------------------------

?BANK 02

---------------------------------------------

; Main QuintetLZ decompression routine.
; 
; Sets data bank to $7E, initializes the 256-byte dictionary ($7E0200–$02FF) with $20 (space), sets the dictionary write position to $EF, and enters the main decompression loop.
; 
; Main loop reads one control bit per iteration:
; - Bit = 1 (literal): reads 8-bit byte via LzReadBitField, writes to both the output buffer (STA $0000,X) and dictionary (STA ($74))
; - Bit = 0 (back-reference): reads 8-bit dictionary index via LzReadBitField (stored to $76), then 4-bit copy length via LzReadBackRef (+2 minimum). Copies bytes from dictionary at the read position ($76) to both the output and dictionary write position ($74). Uses the XBA trick to stash the copy counter in the B register, freeing A for dictionary reads
; 
; The output counter (Y) decrements per byte written. When Y reaches zero, decompression is complete.
; 
; Preserves all registers and data bank via PHP/PHB/PHX/PHY at entry.

QuintetLzDecompress {
    PHP 
    PHB 
    PHX 
    PHY 
    SEP #$20
    LDA #$7E              ; Set data bank to $7E — dictionary and output buffer are in WRAM
    PHA 
    PLB 
    LDX #$0200            ; Dictionary base at $7E0200 (256 bytes); also initializes back-ref pointer page
    STX $74
    STX $76
    LDA #$20              ; $20 = space character — Quintet standard dictionary initialization value

  loc_028283:
    STA ($74)             ; Fill loop: write $20 to all 256 bytes ($0200–$02FF) until low byte wraps to $00
    INC $74
    BNE loc_028283
    LDA #$EF              ; $EF = DICTIONARY_OFFSET — standard starting write position within the dictionary
    STA $74
    LDA #$80              ; $80 = initial bit mask (MSB-first); $72 tracks current bit position in source byte
    STA $72
    LDX $7A               ; Load output pointer (X from $7A) and remaining byte count (Y from $78) set by caller
    LDY $78

  loc_028295:
    LDA [$3E]             ; Main loop: read source byte, AND with mask to extract one control bit
    AND $72
    PHA 
    LSR $72               ; Advance bit mask right; carry set when all 8 bits consumed from current byte
    BCC loc_0282A6
    ROR $72               ; Byte exhausted: ROR carry into bit 7 resets mask to $80; advance source pointer
    INC $3E
    BNE loc_0282A6
    INC $3F

  loc_0282A6:
    PLA                   ; Control bit: zero = back-reference token, nonzero = literal byte
    BEQ loc_0282B9
    JSR $&LzReadBitField  ; Literal: read 8-bit byte value from bitstream
    STA $0000, X          ; Write literal to output buffer and update dictionary at write position ($74)
    INX 
    STA ($74)
    INC $74
    DEY 
    BNE loc_028295
    BRA loc_0282D9

  loc_0282B9:
    JSR $&LzReadBitField  ; Back-ref: read 8-bit dictionary index, store as read pointer ($76 in $02xx page)
    STA $76
    JSR $&LzReadBackRef   ; Read 4-bit length nibble; +2 gives minimum copy length of 2 bytes
    INC 
    INC 

  loc_0282C3:
    XBA                   ; XBA trick: stash copy counter in B register, freeing A for dictionary byte reads
    LDA ($76)             ; Copy loop: read from dictionary at back-ref position, write to output and dictionary
    INC $76
    STA ($74)
    INC $74
    STA $0000, X
    INX 
    DEY 
    BEQ loc_0282D9
    XBA                   ; Swap back to counter, decrement; loop until copy complete or output full
    DEC 
    BNE loc_0282C3
    BRA loc_028295

  loc_0282D9:
    PLY 
    PLX 
    PLB 
    PLP 
    RTL 
}

---------------------------------------------
; Read 8 bits from the compressed bitstream and return in A.
; 
; Optimized for the common case where bits straddle a byte boundary. Tests the current bit position ($72 mask) via a cascade of ASL+BMI checks to determine how many bits remain in the current source byte.
; 
; Fast path ($72 = $80, byte-aligned): reads the source byte directly via LDA [$3E], advances the pointer, returns — no bit-shifting needed.
; 
; Slow path (unaligned): reads a 16-bit word from the source (two consecutive bytes), XBAs to swap byte order, then enters an ASL fall-through cascade. The entry point into the cascade determines the shift count (1–7), which aligns the 8-bit result within the 16-bit value. After shifting, advances the source pointer, XBAs to extract the aligned byte, and returns in 8-bit mode.

LzReadBitField {
    LDA $72               ; Cascade: test mask bits 7→1 via ASL+BMI to find current position in source byte
    BMI loc_028325
    ASL 
    BMI loc_02831E
    ASL 
    BMI loc_028317
    ASL 
    BMI loc_028310
    ASL 
    BMI loc_028309
    ASL 
    BMI loc_028302
    ASL 
    BMI loc_0282FB
    REP #$20              ; No bits remain: read 16-bit word from source, XBA swap, enter ASL cascade to align
    LDA [$3E]
    XBA 
    BRA loc_02832E

  loc_0282FB:
    REP #$20
    LDA [$3E]
    XBA 
    BRA loc_02832F

  loc_028302:
    REP #$20
    LDA [$3E]
    XBA 
    BRA loc_028330

  loc_028309:
    REP #$20
    LDA [$3E]
    XBA 
    BRA loc_028331

  loc_028310:
    REP #$20
    LDA [$3E]
    XBA 
    BRA loc_028332

  loc_028317:
    REP #$20
    LDA [$3E]
    XBA 
    BRA loc_028333

  loc_02831E:
    REP #$20
    LDA [$3E]
    XBA 
    BRA loc_028334

  loc_028325:
    LDA [$3E]             ; Fast path ($72=$80): byte-aligned — read source byte directly, advance, return
    REP #$20
    INC $3E
    SEP #$20
    RTS 

  loc_02832E:
    ASL                   ; ASL fall-through cascade: entry point sets shift count (7 down to 1) for alignment

  loc_02832F:
    ASL 

  loc_028330:
    ASL 

  loc_028331:
    ASL 

  loc_028332:
    ASL 

  loc_028333:
    ASL 

  loc_028334:
    ASL 
    INC $3E               ; Advance source past consumed byte; XBA + SEP returns aligned result in 8-bit A
    XBA 
    SEP #$20
    RTS 
}

---------------------------------------------
; Read 4 bits (a nibble) from the compressed bitstream and return in A.
; 
; Two strategies based on remaining bit count:
; 
; High path ($72 >= $10, 4+ bits at position 4–7): LSR the mask 4 times to consume 4 positions. Reads the source byte into a 16-bit pair and uses an LSR fall-through cascade (1–4 right shifts) to align the nibble. No source pointer advance needed.
; 
; Low path ($72 < $10, position 0–3): the nibble may straddle the byte boundary. Tests how many bits remain (3, 2, 1, or 4). Each case resets the mask to the post-read position, reads the 16-bit source word, and uses ASL shifts to combine the straddling bits. The 4-bits-remaining case ($08) is the simplest — reads the current byte's low nibble directly and resets the mask to $80.
; 
; All paths return the nibble in A with AND #$0F masking.

LzReadBackRef {
    LDA $72               ; Check if 4+ bits remain ($72 >= $10) for nibble extraction strategy
    CMP #$10
    BCC loc_02835D
    LSR                   ; High path: consume 4 mask positions via LSR ×4; nibble is within current byte
    LSR 
    LSR 
    LSR 
    STA $72
    XBA 
    LDA [$3E]
    XBA 
    REP #$20
    LSR                   ; LSR cascade: 1–4 right shifts align the nibble within the 16-bit byte pair
    BCS loc_028357
    LSR 
    BCS loc_028357
    LSR 
    BCS loc_028357
    LSR 

  loc_028357:
    SEP #$20
    XBA 
    AND #$0F              ; AND #$0F: extract the 4-bit nibble (back-reference copy length before +2)
    RTS 

  loc_02835D:
    LSR                   ; Low path: 1–4 bits remain — nibble may straddle the byte boundary
    BCS loc_02838E
    LSR 
    BCS loc_028381
    LSR 
    BCS loc_028375
    LDA #$80              ; Exactly 4 bits remain (mask was $08): low nibble of current byte is the result
    STA $72
    LDA [$3E]
    REP #$20
    INC $3E
    SEP #$20
    AND #$0F
    RTS 

  loc_028375:
    LDA #$40              ; 1 bit in current byte: read next byte, ASL ×1 to combine straddling nibble
    STA $72
    REP #$20
    LDA [$3E]
    XBA 
    ASL 
    BRA loc_02839A

  loc_028381:
    LDA #$20              ; 2 bits in current byte: ASL ×2 across boundary — same straddling pattern
    STA $72
    REP #$20
    LDA [$3E]
    XBA 
    ASL 
    ASL 
    BRA loc_02839A

  loc_02838E:
    LDA #$10              ; 3 bits in current byte: ASL ×3 across boundary
    STA $72
    REP #$20
    LDA [$3E]
    XBA 
    ASL 
    ASL 
    ASL 

  loc_02839A:
    INC $3E
    SEP #$20
    XBA 
    AND #$0F              ; AND #$0F: extracted nibble from boundary-straddling read
    RTS 
}