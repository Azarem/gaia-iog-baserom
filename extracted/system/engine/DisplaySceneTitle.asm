; Scene title display system - centered area name overlay during scene transitions (172315-172521, Bank 02).
; 
; Called from ClearSceneState after actor spawning and before thinker spawning and palette loading. Displays the current scene's area name (e.g. 'South Cape', 'Edward's Castle') in a one-row dialogue box, giving the player a visual cue of the new location.
; 
; === DISPLAY PIPELINE (DisplaySceneTitle) ===
; 
; 1. Scene change guard: compares $0D6E (the scene just left, recorded by ExecuteSceneTransition; for a world-map entry it is the deferred destination) against sceneCurrent ($0644). If they are equal (a reload of the same scene ID) the title is suppressed.
; 
; 2. Width measurement: CountTitleGlyphs walks the scene title wide-string, counting visible characters while expanding dictionary references ($D6/$D7) and cursor advances ($CC). The string is the one stored right after the scene's actor list: SpawnSceneActors leaves $3E on the list's $FF terminator and CountTitleGlyphs moves it one byte on, to the first title byte. Returns the glyph count in $00.
; 
; 3. Empty title guard: if the count is zero the routine returns immediately (177 of the 241 scene records have an empty title, only $CA).
; 
; 4. Centering: (18 - glyphCount), forced even by AND $FE, used as a byte offset into the VRAM write buffer, i.e. (18 - N) / 2 tile cells. 18 is presumably the interior of the 10-column box if a column is 2 tiles wide (inferred; there is no clamp for N > 18, OQ-58).
; 
; 5. Box setup: sets $00B4 = $E0 (nonzero flag that makes ExecuteSceneTransition wait for a button press) and clears $00B5. Opens the box via scene_title_box_format ([DLG:7,7][SIZ:A,1]), i.e. a DialogStringRenderer OpenDialogueBox command with width $0A and height 1 at position (7, 7).
; 
; 6. Centered render: adds the padding to the VRAM write cursor ($0998), then calls DialogStringRenderer a second time with the title string pointer.
; 
; === GLYPH COUNTING (CountTitleGlyphs) ===
; 
; A specialized wide-string character counter for the commands found in scene title strings:
; - Literal tiles (< $C0): 1 glyph each
; - $CA (Return): ends the count
; - $CC (AdvanceCursor): adds the operand byte to the count
; - $D6/$D7 (DictionaryA/B): looks up the word in dialog_dictionary_a/b and counts each expanded character up to its $CA terminator
; - Other commands (>= $C0): skips one operand byte without counting
; 
; The scan starts at [$3E] + 1. SpawnSceneActors ends with $3E pointing at the $FF that closes the scene's actor list (scene_lifecycle calls DisplaySceneTitle right after it), and the title string follows that terminator directly in the scene record (see scene_actors). INC $3E steps over the $FF; it is not a type or length byte, and the title's first byte is counted.
---------------------------------------------

?BANK 02

?INCLUDE 'dialog_dictionaries'
?INCLUDE 'DialogStringRenderer'

!sceneCurrent                   0644

---------------------------------------------

; Display the current scene's area name in a centered dialogue box overlay.
; 
; Called from ClearSceneState after actor spawning. Compares $0D6E (scene just left) with sceneCurrent and returns when they are equal.
; 
; Pipeline:
; 1. CountTitleGlyphs measures the title string that follows the actor list ($3E = the list's $FF terminator on entry; CountTitleGlyphs advances it to the first title byte)
; 2. Returns if the count is zero (no title for this scene)
; 3. Centering offset: (18 - count) forced even, pushed for later
; 4. $00B4 = $E0 (wait-for-button flag for ExecuteSceneTransition), $00B5 = 0
; 5. Saves $40 and the title pointer $3E (in Y), sets DBR to this bank
; 6. DialogStringRenderer with scene_title_box_format opens the box
; 7. Restores the pointer, adds the offset to the VRAM cursor ($0998)
; 8. DialogStringRenderer again renders the title, then restores DBR and flags

DisplaySceneTitle {
    LDA $0D6E             ; $0D6E = scene just left (set by ExecuteSceneTransition)
    CMP $sceneCurrent     ; Equal to the new scene ID: suppress the title
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
    SEC                   ; A = glyph count − 18; negated below to 18 − N, forced even: a byte offset = (18 − N) / 2 tile cells
    SBC #$12
    EOR #$FF
    INC 
    AND #$FE
    PHA                   ; Push centering offset for later retrieval
    LDA #$E0              ; $E0 → $00B4: wait-for-input flag checked by scene transition epilogue
    STA $00B4             ; Nonzero flag: ExecuteSceneTransition waits for a button while $00B4 is set
    STZ $00B5             ; Clear $00B5 (only ExecuteSceneTransition also clears it; no reader found)
    LDA $0040             ; Load current $40 (string bank) — DialogStringRenderer may overwrite it
    PHA 
    LDY $3E               ; Load scene title pointer $3E/Y on stack
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
; Walks the byte stream at [$3E] + 1 (INC $3E steps over the $FF actor-list terminator that SpawnSceneActors left in $3E; the title string starts right after it). Accumulates glyph count in $00. Handles the command subset used in scene title strings:
; 
; - Bytes < $C0: literal tile characters - increments count by 1
; - $CA (Return): end of string - returns with count in $00
; - $CC (AdvanceCursor): reads 1-byte operand as additional glyph width, adds to count
; - $D6 (DictionaryA): resolves compressed word from dictionary_01EBA8. Reads 1-byte index, looks up the word pointer (index x 2 + base), then counts each character until $CA terminator
; - $D7 (DictionaryB): same as $D6 but uses dictionary_01F54D
; - Other commands (>= $C0): skips one operand byte without counting
; 
; The dictionary expansion switches DBR to the dictionary bank (PHA/PLB), saves/restores Y across the lookup, and returns to the main loop after counting all expanded characters.

CountTitleGlyphs {
    PHP                   ; Save processor state; will use mixed 8/16-bit
    REP #$20
    INC $3E               ; Step over the $FF actor-list terminator left in $3E by SpawnSceneActors; $3E now points at the first title byte
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