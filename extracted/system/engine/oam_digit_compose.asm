; OAM digit sprite composition (244449–244613, Bank 03).
; 
; Converts packed BCD damage numbers into individual digit sprites in the OAM compose buffer ($7F3100). Called by combat hit effects (SpawnAttackTrailEffect) to render floating damage numbers above actors.
; 
; === PACKED BCD FORMAT ===
; 
; Input at DP $0000 is a 16-bit packed value from FormatDamageDigits:
; - Byte $0001 (high byte), low nibble = hundreds digit (0–9)
; - Byte $0000 (low byte), bits 7–4 = tens digit (0–9)
; - Byte $0000 (low byte), bits 3–0 = ones digit (0–9)
; 
; Digits are rendered left-to-right: hundreds → tens → ones. Zero digits are skipped (no sprite) but still advance the cursor by 4px (half-width gap). Nonzero digits advance by 8px (full glyph width).
; 
; === OAM BUFFER ENTRY FORMAT ===
; 
; Each digit produces a 6-byte entry in the compose buffer at $7F3100:
; - Bytes 0–1: X position (16-bit)
; - Bytes 2–3: Y position (16-bit)
; - Bytes 4–5: tile index ($70 + digit) | palette/priority from DP $0002
; 
; The buffer write cursor at $00D8 advances by 6 per entry.
; 
; === ENTRY CONDITIONS ===
; 
; - DP $0000: packed BCD value from FormatDamageDigits
; - DP $0014: actor X position (starting X = actorX − 12)
; - DP $0016: actor Y position
; - DP $000E: sprite palette/priority field
; - $00D8: OAM compose buffer write cursor
---------------------------------------------

?BANK 03

!oamComposeBuffer               7F3100

---------------------------------------------

; Re-entry point for appending additional digits to an existing damage display.
; 
; Saves the current cursor X ($0018) to $001A, shifts the cursor left by 6px, then falls through to the digit rendering loop at loc_03BB0D. Used when multiple damage numbers need to be composed adjacent to each other.

ComposeDigits_Continuation {
    PHX 
    LDA $0018
    STA $001A
    SEC 
    SBC #$0006            ; Shift cursor left 6px for adjacent number placement
    STA $0018
    BRA loc_03BB0D
}

---------------------------------------------
; Main entry point for damage digit composition.
; 
; Reads packed BCD from DP $0000. If $F000 bits are set, exits immediately (guards against invalid/overflowed values). Otherwise sets up the rendering cursor at actorX − 12, then processes digits left-to-right: hundreds → tens → ones. Each nonzero digit is rendered via EmitDigitOamEntry; zero digits advance the cursor by only 4px (half-width placeholder) instead of the full 8px.

ComposeDigitSprites {
    PHX 
    LDA $0000
    BIT #$F000            ; $F000 guard: skip if packed value is invalid/overflowed
    BNE loc_03BB5C
    LDA $14
    SEC 
    SBC #$000C            ; Starting X = actorX − 12
    STA $0018
    LDA $16
    STA $001C
    LDA $0E
    STA $0002             ; Palette/priority for tile composition in EmitDigitOamEntry

  loc_03BB0D:
    LDA $0001             ; Hundreds digit: low nibble of high byte
    AND #$000F
    BEQ loc_03BB24
    JSR $&EmitDigitOamEntry
    LDA $0018
    CLC 
    ADC #$0008            ; 8px per rendered digit; 4px gap for skipped zero
    STA $0018
    BRA loc_03BB2E

  loc_03BB24:
    LDA $0018
    CLC 
    ADC #$0004
    STA $0018

  loc_03BB2E:
    LDA $0000             ; LSR ×4 shifts tens to low nibble; BEQ = leading zero suppression
    LSR 
    LSR 
    LSR 
    LSR 
    BEQ loc_03BB49
    AND #$000F
    JSR $&EmitDigitOamEntry
    LDA $0018
    CLC 
    ADC #$0008
    STA $0018
    BRA loc_03BB53

  loc_03BB49:
    LDA $0018
    CLC 
    ADC #$0004
    STA $0018

  loc_03BB53:
    LDA $0000             ; Ones digit (always rendered)
    AND #$000F
    JSR $&EmitDigitOamEntry

  loc_03BB5C:
    PLX 
    RTL 
}

---------------------------------------------
; Write one digit sprite to the OAM compose buffer.
; 
; Digit value in A (0–9). Adds $70 to convert to tile index (digit font starts at tile $70), ORs with palette/priority from DP $0002. Writes X position ($0018), Y position ($001C), and tile word to the buffer at $7F3100 + $00D8. Advances the buffer cursor by 6 bytes.

EmitDigitOamEntry {
    LDX $00D8
    CLC 
    ADC #$0070            ; $70 = digit font base tile; digit 0 → tile $70, etc.
    ORA $0002
    STA $7F3104, X
    LDA $0018
    STA $oamComposeBuffer, X
    LDA $001C
    STA $7F3102, X
    LDA $00D8
    CLC 
    ADC #$0006            ; 6 bytes per OAM entry
    STA $00D8
    RTS 
}