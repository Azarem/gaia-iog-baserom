; QuintetLZ decompression engine (164464–164770, Bank 02).
; 
; Implements the LZSS-variant compression algorithm used across Quintet (Enix) games — Illusion of Gaia, Soul Blazer, and Robotrek — for compressing graphics, tilemaps, and other data.
; 
; === ALGORITHM ===
; Dictionary-based compression with a 256-byte sliding window. A bitstream control layer determines token types:
; - Bit = 1 → Literal: read 8 bits via LzReadBitField, write byte to output and dictionary
; - Bit = 0 → Back-reference: read 8-bit dictionary index via LzReadBitField, then 4-bit length via LzReadNibble. Copy (length + 2) bytes from dictionary to both output and dictionary write position
; 
; The dictionary is initialized to $20 (space character), providing good compression for text-heavy data. The starting write position is $EF (DICTIONARY_OFFSET), matching the Quintet standard across all three games.
; 
; === BITSTREAM FORMAT ===
; Bits are read MSB-first within each source byte. DP $72 holds a one-hot mask of the NEXT unread bit, starting at $80 (bit 7). Each control bit consumed shifts the mask right via LSR. When the mask shifts out entirely (all 8 bits consumed), it resets to $80 via ROR and the source pointer [$3E] advances.
; 
; LzReadBitField (8-bit read) and LzReadNibble (4-bit read) use position cascades keyed on the mask. When the required bits straddle a byte boundary they read a 16-bit word from the source, XBA to swap byte order, and enter ASL (8-bit read) or LSR (4-bit read) fall-through cascades to align the result. In LzReadNibble the one-hot mask itself sits in the low byte of the 16-bit word and acts as the shift counter: LSR runs until the mask's single set bit is shifted out into carry.
; 
; === WRAM LAYOUT ===
; $3E/$3F/$40: 24-bit source pointer to compressed data (past the 2-byte size header). The routine advances $3E/$3F with 16-bit increments and never carries into the bank byte $40, so a stream must not cross a bank boundary; the pointer is left one past the last byte used.
; $72: Bit mask — one-hot, MSB-first, resets to $80 on byte boundary
; $74/$75: Dictionary write pointer (low byte = position within 256-byte page at $7E0200; the 8-bit INC wraps it inside the page)
; $76/$77: Back-reference read pointer (same $02xx page; set per back-ref token)
; $78/$79: Decompressed byte count (loaded into Y as countdown)
; $7A/$7B: Output buffer address in bank $7E (loaded into X for STA $0000,X)
; $7E0200–$7E02FF: 256-byte sliding dictionary. This page is also the first half of the depth-sort bucket array that sprite_composition's ClearActorRenderList zeroes ($0200–$03FE; mnemonic deathFlag = $0200), so every decompression leaves garbage there: callers must run ClearActorRenderList afterwards (the Decompress COP and the scene-load sequence do).
; 
; === ENTRY CONDITIONS ===
; Caller sets: [$3E] = source pointer (past size header), $78 = decompressed size (must be non-zero: a zero count runs for 65,536 bytes; scene_script skips size 0, the Decompress COP does not test it), $7A = output address within bank $7E (the data bank is set to $7E internally, so $7F output is impossible). X, Y, P and DBR are preserved across the call; A is not.
; 
; Reference: QuintetLZ class in @gaialabs/core (src/compression/QuintetLZ.ts).
---------------------------------------------

?BANK 02

---------------------------------------------

; Main QuintetLZ decompression routine.
; 
; Sets data bank to $7E, initializes the 256-byte dictionary ($7E0200–$02FF, shared with the depth-sort bucket array) with $20 (space), sets the dictionary write position to $EF, and enters the main decompression loop.
; 
; Main loop reads one control bit per iteration:
; - Bit = 1 (literal): reads 8-bit byte via LzReadBitField, writes to both the output buffer (STA $0000,X) and dictionary (STA ($74))
; - Bit = 0 (back-reference): reads 8-bit dictionary index via LzReadBitField (stored to $76), then 4-bit copy length via LzReadNibble (+2 minimum). Copies bytes from dictionary at the read position ($76) to both the output and dictionary write position ($74). Uses the XBA trick to stash the copy counter in the B register, freeing A for dictionary reads
; 
; The output counter (Y) decrements per byte written. When Y reaches zero, decompression is complete (even in the middle of a back-reference copy).
; 
; Preserves X, Y, P and the data bank via PHP/PHB/PHX/PHY at entry; A is not preserved.

QuintetLzDecompress {
    PHP 
    PHB 
    PHX 
    PHY 
    SEP #$20
    LDA #$7E              ; Set data bank to $7E — dictionary and output buffer are in WRAM
    PHA 
    PLB 
    LDX #$0200            ; Dictionary = $7E:0200-02FF, which is also the depth-sort bucket array (callers clear it with ClearActorRenderList)
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
    LDX $7A               ; X = output offset in bank $7E (the data bank); Y = byte count below (0 would mean 65,536 bytes)
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
    INC $3F               ; 16-bit pointer increment: no carry into the bank byte $40, so a stream cannot cross a bank boundary

  loc_0282A6:
    PLA                   ; Control bit: zero = back-reference token, nonzero = literal byte
    BEQ loc_0282B9
    JSR $&LzReadBitField  ; Literal: read 8-bit byte value from bitstream
    STA $0000, X          ; Write literal to output buffer and update dictionary at write position ($74)
    INX 
    STA ($74)
    INC $74               ; 8-bit INC: the write pointer wraps inside the $0200 page (256-entry ring)
    DEY 
    BNE loc_028295
    BRA loc_0282D9

  loc_0282B9:
    JSR $&LzReadBitField  ; Back-ref: read 8-bit dictionary index, store as read pointer ($76 in $02xx page)
    STA $76
    JSR $&LzReadNibble    ; Read 4-bit length nibble; +2 gives minimum copy length of 2 bytes
    INC 
    INC 

  loc_0282C3:
    XBA                   ; XBA trick: stash copy counter in B register, freeing A for dictionary byte reads
    LDA ($76)             ; Copy loop: read from dictionary at back-ref position, write to output and dictionary
    INC $76               ; 8-bit INC: the read pointer wraps inside the $0200 page as well
    STA ($74)
    INC $74
    STA $0000, X
    INX 
    DEY 
    BEQ loc_0282D9        ; Output full: stop at once, even in the middle of a copy
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
; Tests the current bit position ($72 mask) via a cascade of ASL+BMI checks; the cascade finds which bit of the mask is set, i.e. how many bits (k = 0–7) of the current source byte are already consumed.
; 
; Fast path (mask $80, k = 0, byte-aligned): reads the source byte directly via LDA [$3E], advances the pointer, returns — no shifting.
; 
; Slow path (k = 1–7): reads a 16-bit word from the source (two consecutive bytes), XBAs it to b0:b1 and ASLs it k times (the entry point into the fall-through cascade selects k: mask $40 = 1 shift ... mask $01 = 7 shifts). The high byte then holds the remaining bits of b0 followed by the top k bits of b1. Advances the source pointer by one byte, XBAs to extract that byte and returns in 8-bit mode. The mask is unchanged: 8 bits consumed leave the bit position where it was.

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
    REP #$20              ; Mask $01 (7 bits already used): load the byte pair, XBA, enter the ASL cascade at the top (7 shifts)
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
; Read 4 bits (a nibble) from the compressed bitstream and return in A (the back-reference copy length before the +2).
; 
; Two strategies keyed on the mask:
; 
; High path (mask >= $10: at least 5 bits left in the current byte, so the nibble fits): LSR the mask 4 times to consume 4 positions and store it. The source byte and the new mask are packed into one 16-bit word (byte in the high half, mask in the low half) and LSR shifts that word right until the mask's one-hot bit falls into carry (1–4 shifts, the shift count the nibble needs); the nibble is the low 4 bits of the high byte after XBA and AND #$0F. The source pointer does not advance.
; 
; Low path (mask < $10: 4 or fewer bits left): the nibble may straddle the byte boundary. Mask $08 = exactly 4 bits left: low nibble of the current byte, mask reset to $80, pointer advanced. Mask $04 = 3 bits left + 1 from the next byte (next mask $40, one ASL), mask $02 = 2 + 2 (next mask $20, two ASLs), mask $01 = 1 + 3 (next mask $10, three ASLs); the byte pair is read as a word, XBA'd, shifted left, and the pointer advances.
; 
; All paths return the nibble in A with AND #$0F masking.

LzReadNibble {
    LDA $72               ; Mask $72 >= $10 means 5 or more bits are left in the source byte (high path); 4 or fewer takes the low path below
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
    LSR                   ; Shift the byte+mask word right until the one-hot mask bit leaves through carry: 1-4 shifts
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
    LDA #$40              ; Mask $04: 3 bits left in this byte + 1 from the next; next mask $40, one ASL on the XBA'd pair
    STA $72
    REP #$20
    LDA [$3E]
    XBA 
    ASL 
    BRA loc_02839A

  loc_028381:
    LDA #$20              ; Mask $02: 2 bits left + 2 from the next byte; next mask $20, two ASLs
    STA $72
    REP #$20
    LDA [$3E]
    XBA 
    ASL 
    ASL 
    BRA loc_02839A

  loc_02838E:
    LDA #$10              ; Mask $01: 1 bit left + 3 from the next byte; next mask $10, three ASLs
    STA $72
    REP #$20
    LDA [$3E]
    XBA 
    ASL 
    ASL 
    ASL 

  loc_02839A:
    INC $3E               ; The nibble used bits of the next byte: advance the source pointer
    SEP #$20
    XBA 
    AND #$0F              ; AND #$0F: extracted nibble from boundary-straddling read
    RTS 
}