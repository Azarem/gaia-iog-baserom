; OAM digit sprite composition (244449–244613, Bank 03).
; 
; Converts a packed BCD number into individual digit sprites in the OAM compose buffer ($7F3100). Callers: SpawnAttackTrailEffect (floating damage numbers, via ComposeDigitSprites), the three-two-one countdown digits in ec11_countdown, mu67_bomb and it1B_trial (ComposeDigitSprites), the diary counter (ComposeDigits_Continuation) and the unused AttackTrailShort.
; 
; === PACKED BCD FORMAT ===
; 
; Input at DP $0000 is a 16-bit packed value (FormatDamageDigits produces it; the countdown scripts store 1, 2 or 3 directly):
; - Byte $0001 (high byte), low nibble = hundreds digit (0–9)
; - Byte $0000 (low byte), bits 7–4 = tens digit (0–9)
; - Byte $0000 (low byte), bits 3–0 = ones digit (0–9)
; 
; Digits are rendered left-to-right: hundreds → tens → ones. Leading zeros are skipped (no sprite) but still advance the cursor by 4px; the ones digit is always drawn. Drawn digits advance the cursor by 8px.
; 
; === OAM BUFFER ENTRY FORMAT ===
; 
; Each digit produces a 6-byte entry in the compose buffer at $7F3100 (world coordinates; RenderComposeBuffer subtracts the scroll):
; - Bytes 0–1: X position (16-bit)
; - Bytes 2–3: Y position (16-bit)
; - Bytes 4–5: tile word = ($70 + digit) | the attribute word in DP $0002 (callers use $3200 or $2200: priority and palette bits)
; 
; The buffer write cursor at $00D8 advances by 6 per entry. No end marker is written here; the main loop in system_core writes the $FF terminator at the cursor after all actors have run.
; 
; === ENTRY CONDITIONS (ComposeDigitSprites) ===
; 
; - DP $0000: packed BCD value
; - DP $0014: actor X position (first digit X = actorX − 12)
; - DP $0016: Y position of the digits (used unchanged)
; - DP $000E: tile attribute word (copied to DP $0002)
; - $00D8: OAM compose buffer write cursor
; 
; Scratch used: DP $0002 (attribute), $0018 (digit X cursor), $001C (digit Y). ComposeDigits_Continuation instead expects the caller to have set $0018, $001C and $0002 itself.
---------------------------------------------

?BANK 03

!oamWriteOffset                 00D8
!oamComposeBuffer               7F3100

---------------------------------------------

; Second entry that skips the actor-position setup and the $F000 guard.
; 
; The caller supplies the digit X cursor ($0018), Y ($001C) and attribute ($0002) itself; the diary counter does this from the BG1 scroll position. The routine copies $0018 to $001A (not read anywhere in this file), moves the cursor left by 6px, and joins ComposeDigitSprites at its hundreds-digit step (loc_03BB0D). Purpose of the 6px shift: not documented (inferred as a fixed alignment offset for the diary counter, the only user).

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
; Reads packed BCD from DP $0000. If any bit of $F000 is set (not a valid packed number) it returns without drawing; FormatDamageDigits cannot produce such a value, so this is only a defensive check. Otherwise it sets the cursor X to actorX − 12, Y to DP $16 and the attribute to DP $0E, then processes digits left-to-right: hundreds → tens → ones. Each digit that is not a leading zero is drawn via EmitDigitOamEntry (+8px); a leading zero is not drawn and advances the cursor by only 4px.

ComposeDigitSprites {
    PHX 
    LDA $0000
    BIT #$F000            ; Defensive: any bit of $F000 set = not a valid packed number, draw nothing
    BNE loc_03BB5C
    LDA $14
    SEC 
    SBC #$000C            ; Starting X = actorX − 12
    STA $0018
    LDA $16
    STA $001C
    LDA $0E
    STA $0002             ; Tile attribute word, ORed into each digit tile by EmitDigitOamEntry

  loc_03BB0D:
    LDA $0001             ; Hundreds digit: low nibble of the value's high byte (DP $01; the AND drops DP $02)
    AND #$000F
    BEQ loc_03BB24
    JSR $&EmitDigitOamEntry
    LDA $0018
    CLC 
    ADC #$0008            ; +8px after a drawn digit (a skipped zero advances 4px, see below)
    STA $0018
    BRA loc_03BB2E

  loc_03BB24:
    LDA $0018
    CLC 
    ADC #$0004
    STA $0018

  loc_03BB2E:
    LDA $0000             ; 16-bit LSR ×4 moves the tens digit to bits 3-0 and the hundreds digit to bits 7-4; zero = both are zero (leading zero)
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
    LDA $0000             ; Ones digit (always drawn)
    AND #$000F
    JSR $&EmitDigitOamEntry

  loc_03BB5C:
    PLX 
    RTL 
}

---------------------------------------------
; Write one digit sprite to the OAM compose buffer.
; 
; Digit value in A (0–9). Adds $70 to convert to a tile index (digit font starts at tile $70), ORs in the attribute word from DP $0002. Writes X ($0018), Y ($001C) and the tile word to the buffer at $7F3100 + $00D8 (offsets +0, +2, +4) and advances the cursor by 6 bytes.

EmitDigitOamEntry {
    LDX $oamWriteOffset
    CLC 
    ADC #$0070            ; $70 = digit font base tile; digit 0 → tile $70, etc.
    ORA $0002
    STA $oamComposeBuffer+4, X
    LDA $0018
    STA $oamComposeBuffer, X
    LDA $001C
    STA $oamComposeBuffer+2, X
    LDA $oamWriteOffset
    CLC 
    ADC #$0006            ; 6 bytes per OAM entry
    STA $oamWriteOffset
    RTS 
}