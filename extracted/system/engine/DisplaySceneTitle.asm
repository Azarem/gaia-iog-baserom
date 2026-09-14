?BANK 02

?INCLUDE 'dialog_dictionaries'
?INCLUDE 'DialogStringRenderer'

!sceneCurrent                   0644

---------------------------------------------

; Display the current scene's area name in a centered dialogue box overlay.
; 
; Called during ClearSceneState after actor spawning. Compares source scene ($0D6E) against sceneCurrent to suppress the title when re-entering the same area.
; 
; Pipeline:
; 1. CountTitleGlyphs measures the visible character width of the title string at [$3E]
; 2. If zero glyphs, returns immediately (no title for this scene)
; 3. Computes centering offset: (18 − glyphCount), negated, AND $FE for even alignment
; 4. Sets $00B4 = $E0 (wait-for-input flag for the scene transition epilogue), clears $00B5
; 5. Saves current string state ($40, $3E/Y), sets DBR to current bank
; 6. Calls DialogStringRenderer with scene_title_box_format to open a 10×1 dialogue box at position (7, 7)
; 7. Restores string state, adds centering offset to VRAM cursor ($0998)
; 8. Calls DialogStringRenderer again with the scene title string to render the centered area name
; 9. Restores DBR and processor state

DisplaySceneTitle {
    LDA $0D6E             ; Scene change guard: load source scene ($0D6E, recorded during transition)
    CMP $sceneCurrent     ; Compare against current scene — same scene = suppress title
    BNE loc_02A124
    RTL 

  loc_02A124:
    JSR $&CountTitleGlyphs ; Count visible glyph width of scene title string at [$3E]
    LDA $00               ; Zero glyphs = no title for this scene → skip display
    BNE loc_02A12C
    RTL 

  loc_02A12C:
    PHP                   ; Save processor state and data bank for DialogStringRenderer calls
    PHB 
    SEC                   ; Centering: (18 − glyphCount), negate, AND $FE → even-aligned left padding
    SBC #$12
    EOR #$FF
    INC 
    AND #$FE
    PHA                   ; Push centering offset for later retrieval
    LDA #$E0              ; $E0 → $00B4: wait-for-input flag checked by scene transition epilogue
    STA $00B4
    STZ $00B5             ; Clear $00B5 (secondary display control byte)
    LDA $0040             ; Save current $40 (string bank) — DialogStringRenderer may overwrite it
    PHA 
    LDY $3E               ; Save scene title pointer $3E/Y on stack
    PHY 
    PHK                   ; Set DBR to current program bank for format string access
    PLB 
    LDY #$&scene_title_box_format ; Load scene_title_box_format: opens 10×1 dialogue box at position (7, 7)
    REP #$20              ; Switch to 16-bit for DialogStringRenderer JSL
    JSL $@DialogStringRenderer ; First call: open dialogue box and initialize VRAM write cursor
    PLY                   ; Restore scene title pointer Y and data bank
    PLB 
    SEP #$20
    PLA                   ; Retrieve centering offset from stack
    REP #$20
    AND #$00FF            ; Zero-extend 8-bit offset to 16-bit for cursor arithmetic
    CLC 
    ADC $0998             ; Add centering offset to VRAM write cursor ($0998) — shifts text start rightward
    STA $0998
    JSL $@DialogStringRenderer ; Second call: render the actual scene title string into the centered box
    PLB 
    PLP 
    RTL 
}

scene_title_box_format `[DLG:7,7][SIZ:A,1][SFX:0]`

---------------------------------------------
; Count visible character width of a scene title wide-string.
; 
; Walks the byte stream at [$3E] + 1 (INC $3E skips a leading type byte). Accumulates glyph count in $00. Handles the command subset used in scene title strings:
; 
; - Bytes < $C0: literal tile characters — increments count by 1
; - $CA (Return): end of string — returns with count in $00
; - $CC (AdvanceCursor): reads 1-byte operand as additional glyph width, adds to count
; - $D6 (DictionaryA): resolves compressed word from dictionary_01EBA8. Reads 1-byte index, looks up the word pointer (index × 2 + base), then counts each character until $CA terminator
; - $D7 (DictionaryB): same as $D6 but uses dictionary_01F54D
; - Other commands (≥ $C0): skips one operand byte without counting
; 
; The dictionary expansion switches DBR to the dictionary bank (PHA/PLB), saves/restores Y across the lookup, and returns to the main loop after counting all expanded characters.

CountTitleGlyphs {
    PHP                   ; Save processor state; will use mixed 8/16-bit
    REP #$20
    INC $3E               ; INC $3E: skip leading type/length byte before character data
    STZ $00               ; Zero glyph counter ($00)
    SEP #$20
    LDY #$0000

  loc_02A17E:
    LDA [$3E], Y          ; Read next byte from title string at [$3E],Y
    CMP #$CA              ; $CA = Return command → end of string
    BEQ loc_02A1A7
    CMP #$C0              ; Bytes < $C0 = literal tile character
    BCC loc_02A1A2
    CMP #$CC              ; $CC = AdvanceCursor command — operand is additional glyph width
    BNE loc_02A197
    INY                   ; Read $CC operand byte (cursor advance count)
    LDA [$3E], Y
    INY 
    CLC                   ; Add operand to glyph count — cursor advance counts as visible width
    ADC $00
    STA $00
    BRA loc_02A17E

  loc_02A197:
    CMP #$D6              ; $D6 = DictionaryA — compressed word in dictionary_01EBA8
    BEQ loc_02A1A9
    CMP #$D7              ; $D7 = DictionaryB — compressed word in dictionary_01F54D
    BEQ loc_02A1BE
    INY                   ; Unknown command (≥ $C0): skip one operand byte
    BRA loc_02A17E

  loc_02A1A2:
    INY                   ; Literal character: advance Y, increment glyph count
    INC $00
    BRA loc_02A17E

  loc_02A1A7:
    PLP 
    RTS 

  loc_02A1A9:
    INY                   ; DictionaryA: read 1-byte word index from stream
    PHB 
    PHY 
    LDA #$^dialog_dictionaries.dialog_dictionary_a ; Switch DBR to dictionary bank for pointer table access
    PHA 
    PLB 
    REP #$20
    LDA [$3E], Y          ; Read word index, zero-extend, ×2 for word-sized pointer table
    AND #$00FF
    ASL 
    CLC 
    ADC #$&dialog_dictionaries.dialog_dictionary_a ; Add dictionary_01EBA8 base → word pointer address
    BRA loc_02A1D1        ; Jump to shared dictionary word counting loop

  loc_02A1BE:
    INY                   ; DictionaryB: same lookup pattern using dictionary_01F54D
    PHB 
    PHY 
    LDA #$^dialog_dictionaries.dialog_dictionary_b
    PHA 
    PLB 
    REP #$20
    LDA [$3E], Y
    AND #$00FF
    ASL 
    CLC 
    ADC #$&dialog_dictionaries.dialog_dictionary_b

  loc_02A1D1:
    TAY                   ; Resolve word pointer → Y = start of expanded word characters
    LDA $0000, Y
    TAY 
    SEP #$20

  loc_02A1D8:
    LDA $0000, Y          ; Count expanded characters: read each byte until $CA terminator
    CMP #$CA
    BEQ loc_02A1E4
    INC $00               ; Increment glyph count for each expanded character
    INY 
    BRA loc_02A1D8

  loc_02A1E4:
    PLY                   ; Restore stream position Y and data bank after dictionary expansion
    PLB 
    INY                   ; Advance past the dictionary command operand byte
    BRA loc_02A17E
}