; Wide-string dialogue renderer and dialogue box management (254549–256073, Bank 03).
; 
; Implements the complete text rendering pipeline for IOG's dialogue system. The engine processes a bytecode-driven wide-string format where characters below $C0 are tile indices rendered directly to a VRAM staging buffer, and bytes $C0–$FF are command opcodes dispatched through a 25-entry command table.
; 
; === DIALOG STRING RENDERER (254549) ===
; 
; Entry point: DialogStringRenderer, called via JSL from COP script handlers and other engine systems.
; 
; The renderer maintains state in work RAM:
; - $0998: Current VRAM buffer write cursor (X index into $7F0200)
; - $0986: Palette bits (OR'd into each tile word, shifted left by XBA + ASL ×2)
; - $097A/$097C: Dialogue box column/row position
; - $097E/$0980: Saved column/row origin for cursor calculations
; - $099A: VRAM buffer base offset (start of current dialogue box content area)
; - $099C: Current line number within the dialogue box
; - $0996: Per-character sound effect ID
; - $007E: Frame delay between characters (controls text speed)
; - $0B04: Saved frame delay value (restored on box open/close)
; 
; Each character tile is written to two VRAM buffer rows: $7F0200,X (top half) and $7F0240,X (bottom half, offset +$10 from top). This produces 16×16 pixel characters from pairs of 8×8 tiles.
; 
; The command dispatch uses an RTS trick: PEA pushes the loop return address (code_03E25F − 1), then the command table address − 1 is pushed and RTS jumps to it. Commands return via RTS back to the character loop.
; 
; === COMMAND TABLE (254659) ===
; 
; 25 commands indexed 0x00–0x18:
; - $C0 EndAndWait: Wait for input, clear box, restore frame delay
; - $C1 SetPosition: Set column/row from 2-byte operand
; - $C2 InsertTemplate: Recursively render a template string from templates_01CA95
; - $C3 SetPalette: Set palette bits from 1-byte operand
; - $C4 InfiniteLoop: Halt (NOP NOP BRA self)
; - $C5 IndirectString: Read string pointer from an indirect table (4-byte operand)
; - $C6 PrintNumber: Format and render a multi-digit number (4-byte operand: table pointer + column count)
; - $C7 OpenDialogueBox: Open a custom-sized dialogue box (2-byte operand: width, height)
; - $C8 ClearDialogueBox: Clear box contents, reset palette to default, wait one frame
; - $C9 WaitFrames: Pause for N frames (1-byte operand)
; - $CA Return: Exit the renderer (pop call stack, PLP, RTL)
; - $CB NewLine: Advance to next line; scroll up if at bottom
; - $CC AdvanceCursor: Move cursor forward by N tiles (1-byte operand)
; - $CD InsertRemoteString: Render a string from another bank (3-byte operand: address + bank)
; - $CE ClearBox: Clear box interior (keep border), reset cursor
; - $CF WaitForButton: Wait for A/B button with blinking cursor
; - $D0 WaitForAnyInput: Wait for any button press
; - $D1 JumpToAddress: Set Y to new string address (2-byte operand)
; - $D2 SetSfx: Set per-character sound effect (1-byte operand)
; - $D3 OpenDefaultBox: Open standard 13×4 dialogue box at position (3, 17)
; - $D4 SetPaletteColor: Write a 15-bit color to CGRAM (3-byte operand: index + color)
; - $D5 SetFrameDelay: Set text speed (1-byte operand, +2 bias)
; - $D6 DictionaryA: Insert a word from dictionary_01EBA8 (1-byte operand)
; - $D7 DictionaryB: Insert a word from dictionary_01F54D (1-byte operand)
; - $D8 PrintRawTiles: Output raw tile bytes until zero terminator
; 
; === DIALOGUE BOX RENDERING ===
; 
; DialogCmd_OpenDialogueBox (255039) and DialogCmd_OpenDefaultBox (255735) construct the box frame:
; 1. Set border tile pointer to DialogueBorderTiles (8 tiles: corners + edges)
; 2. DrawDialogueBorderRow renders top/bottom borders
; 3. DrawDialogueBodyRows fills interior rows with blank tiles ($2040) and side borders
; 4. An optional prompt row is appended when worldReadyFlag is set and $00EE is zero
; 
; The VRAM staging buffer at $7F0200 uses a linear layout: each row is $40 words (64 tiles). Box position is computed as: base = (row × 32 + column) × 2, where the ×32 comes from XBA + LSR + LSR.
---------------------------------------------

?BANK 03

?INCLUDE 'dialog_dictionaries'
?INCLUDE 'dialog_template_table'
?INCLUDE 'system_core'

!sceneCurrent                   0644
!worldReadyFlag                 0654
!joypadCurrent                  0656
!joypadHeld                     0658
!sfxQueueCh1                    06F8
!displayModeFlags               09EC
!cgramPalette                   7F0A00

---------------------------------------------

; Main bytecode interpreter for the wide-string dialogue format.
; 
; Entry: JSL with Y = string data pointer, X = VRAM buffer cursor (saved to $0998). Sets DP = 0 for zero-page scratch access.
; 
; The character loop (DialogString_CharLoop) reads one byte at a time from [Y]. Bytes < $C0 are treated as tile indices: masked to 8 bits, OR'd with palette bits ($0986) and priority ($2100), then written to both $7F0200,X (top tile row) and $7F0240,X (bottom row, +$10 offset). The cursor X advances by 2 per character.
; 
; Bytes ≥ $C0 are command opcodes: masked to 5 bits (AND #$001F), doubled as a word index, looked up in DialogStringCommandTable, and dispatched via an RTS trick (PEA loop_addr−1, push cmd_addr−1, RTS).
; 
; After each visible character: if worldReadyFlag is set, calls WaitNFrames_PerChar for the typing delay, checks for the ellipsis tile ($AC) to suppress sound, and queues the per-character SFX ($0996) to sfxQueueCh1.

DialogStringRenderer {
    PHP 
    PHD 
    PHX 
    LDA #$0000
    TCD                   ; DP = 0 for scratch variables at $00–$FF
    LDX $0998

  DialogString_CharLoop:
    SEP #$20
    LDA $0000, Y
    CMP #$C0              ; < $C0 = printable tile character; ≥ $C0 = command opcode
    BCC loc_03E27C
    REP #$20
    INY 
    PEA $&DialogString_CharLoop-1 ; RTS dispatch: push loop return addr − 1, then push command addr − 1
    AND #$001F            ; Mask to 5-bit command index ($C0–$D8 → 0–24), double for word table
    ASL 
    PHX 
    TAX 
    LDA $@DialogStringCommandTable, X
    PLX 
    DEC                   ; DEC for RTS trick — RTS adds 1 back to reach correct handler
    PHA 
    RTS                   ; RTS dispatches to command handler; handler returns here via its own RTS

  loc_03E27C:
    REP #$20
    AND #$00FF
    INY 
    STA $00               ; Save tile index to $00 for ellipsis check after typing delay
    ORA $0986             ; Compose tile word: index | palette ($0986) | priority ($2100)
    ORA #$2100
    LDX $0998
    STA $7F0200, X        ; Write to both VRAM rows: top at $0200,X and bottom at $0240,X (tile + $10)
    CLC 
    ADC #$0010
    STA $7F0240, X
    INX 
    INX 
    STX $0998
    LDA $worldReadyFlag   ; worldReadyFlag not set → skip typing delay and sound
    BEQ DialogString_CharLoop
    LDA $00
    PHA 
    LDA #$0001            ; TSB displayModeFlags triggers VRAM DMA on next VBlank
    TSB $displayModeFlags
    JSR $&WaitNFrames_PerChar
    PLA 
    CMP #$00AC            ; Ellipsis tile ($AC) suppresses per-character click sound
    BEQ DialogString_CharLoop
    LDA $sfxQueueCh1      ; Merge SFX: clear queue low byte, OR in per-character sound ($0996)
    AND #$FF00
    ORA $0996
    STA $sfxQueueCh1
    BRA DialogString_CharLoop
}

DialogStringCommandTable [
  &DialogCmd_EndAndWait   ;00
  &DialogCmd_SetPosition   ;01
  &DialogCmd_InsertTemplate   ;02
  &DialogCmd_SetPalette   ;03
  &DialogCmd_InfiniteLoop   ;04
  &DialogCmd_IndirectString   ;05
  &DialogCmd_PrintNumber   ;06
  &DialogCmd_OpenDialogueBox   ;07
  &DialogCmd_ClearDialogueBox   ;08
  &DialogCmd_WaitFrames   ;09
  &DialogCmd_Return   ;0A
  &DialogCmd_NewLine   ;0B
  &DialogCmd_AdvanceCursor   ;0C
  &DialogCmd_InsertRemoteString   ;0D
  &DialogCmd_ClearBox   ;0E
  &DialogCmd_WaitForButton   ;0F
  &DialogCmd_WaitForAnyInput   ;10
  &DialogCmd_JumpToAddress   ;11
  &DialogCmd_SetSfx   ;12
  &DialogCmd_OpenDefaultBox   ;13
  &DialogCmd_SetPaletteColor   ;14
  &DialogCmd_SetFrameDelay   ;15
  &DialogCmd_DictionaryA   ;16
  &DialogCmd_DictionaryB   ;17
  &DialogCmd_PrintRawTiles   ;18
]

---------------------------------------------
; End-of-dialogue command: waits for any input, clears the dialogue box, suppresses attack/start held flags ($0F00), and restores the saved frame delay from $0B04 to $007E.

DialogCmd_EndAndWait {
    JSR $&DialogCmd_WaitForAnyInput
    JSR $&DialogCmd_ClearDialogueBox
    LDA #$0F00            ; Clear $0F00 — release attack/start button suppression from joypadHeld
    TRB $joypadHeld
    LDA $0B04             ; Restore frame delay from saved value ($0B04 → $007E)
    STA $007E
}

---------------------------------------------
; Exit the wide-string renderer. Saves the VRAM cursor back to $0998, pops the return address and saved registers (X, X, DP, P), then RTL returns to the caller. The double PLX discards the PEA'd loop return address from the command dispatch stack frame.

DialogCmd_Return {
    STX $0998
    PLX                   ; Pop PEA'd loop return address — unwinding renderer stack frame
    PLX 
    PLD 
    PLP 
    RTL 
}

---------------------------------------------
; Set the dialogue cursor to a specific (column, row) position.
; 
; Reads a 2-byte operand: low byte = column → $097A, high byte = row → $097C. Computes the VRAM buffer offset as: (row >> 2) + column + column = row×32×2 + column×2, matching the $7F0200 tilemap layout. Updates both X register and $0998.

DialogCmd_SetPosition {
    PHY 
    LDA $0000, Y          ; 2-byte operand: low = column, high = row
    PHA 
    AND #$00FF
    STA $097A             ; Store column to $097A, row to $097C
    PLA 
    XBA 
    AND #$00FF
    STA $097C
    XBA                   ; VRAM offset = row × 32 + column × 2 via XBA + LSR×2 + ADC column twice
    LSR 
    LSR 
    CLC 
    ADC $097A
    CLC 
    ADC $097A
    TAX 
    STA $0998
    PLY 
    INY 
    INY 
    RTS 
}

---------------------------------------------
; Recursively render a template string from the templates_01CA95 table.
; 
; Reads a 1-byte operand (template index), multiplies by 2 for the word-sized pointer table, switches DBR to the template bank, and calls DialogStringRenderer recursively via JSL. Restores the VRAM cursor, string pointer, bank, and processor state on return.

DialogCmd_InsertTemplate {
    PHP 
    PHB 
    PHY 
    LDA $0000, Y          ; 1-byte template index, doubled for word pointer table
    AND #$00FF
    ASL 
    TAY 
    SEP #$20
    LDA #$^dialog_template_table ; Switch DBR to template bank for absolute reads
    PHA 
    PLB 
    REP #$20
    LDA $&dialog_template_table, Y
    TAY 
    STX $0998
    JSL $@DialogStringRenderer ; Recursive JSL DialogStringRenderer to render template string
    LDX $0998
    PLY 
    INY 
    PLB 
    PLP 
    RTS 
}

---------------------------------------------
; Set the tile palette for subsequent characters.
; 
; Reads a 1-byte palette index, swaps bytes (XBA) and shifts left 2 (ASL ×2) to position palette bits in the VRAM tile word format (bits 12-10). Stores to $0986 which is OR'd into every tile written by the character loop.

DialogCmd_SetPalette {
    PHY 
    LDA $0000, Y
    AND #$00FF
    XBA                   ; XBA + ASL×2: position palette index into bits 12-10 of VRAM tile word
    ASL 
    ASL 
    STA $0986             ; Stored to $0986 — OR'd into every subsequent tile by the character loop
    PLY 
    INY 
    RTS 
}

DialogCmd_InfiniteLoop {
    NOP 
    NOP 
    BRA DialogCmd_InfiniteLoop ; BRA self — halts the dialogue engine
}

---------------------------------------------
; Render a string selected from an indirect pointer table.
; 
; Reads a 4-byte operand: bytes 0-1 = base pointer offset, bytes 2-3 = table address. Computes the string pointer as: table[base[table_addr]] + base_offset. Then recursively renders via JSL DialogStringRenderer.

DialogCmd_IndirectString {
    PHY 
    STX $0998
    LDX $0002, Y          ; 4-byte operand: bytes 0-1 = base offset, bytes 2-3 = table address
    LDA $0000, X          ; Double indirection: table[addr] → index → ×2 + base → string pointer
    ASL 
    CLC 
    ADC $0000, Y
    TAX 
    LDA $0000, X
    TAY 
    LDX $0998
    JSL $@DialogStringRenderer ; Recursive JSL DialogStringRenderer for resolved string
    LDX $0998
    PLY 
    INY 
    INY 
    INY 
    INY 
    RTS 
}

---------------------------------------------
; Format and render a multi-digit number as tile characters.
; 
; Reads a 4-byte operand: bytes 0-1 = number table address, bytes 2-3 = column/digit configuration. Uses a stack frame with 6 words for loop state: divider, table base, current digit position, iteration counter, digit index, and digits-printed flag.
; 
; The algorithm divides the number into 4-pixel-wide digit groups, extracts each nibble by repeated LSR ×4, looks up the tile in HexDigitTileTable, and writes it to the VRAM buffer. Leading zeros are suppressed (skipped until the first nonzero digit or last position). Each digit triggers WaitNFrames_PerChar for the typing effect.

DialogCmd_PrintNumber {
    PHY 
    LDA #$0000            ; Allocate 6-word stack frame for loop state
    PHA 
    PHA 
    PHA 
    PHA 
    STX $0998
    LDA $0000, Y          ; Operand: bytes 0-1 = number table base, bytes 2-3 = column/digit config
    PHA 
    LDA $0002, Y
    PHA 

  loc_03E3A6:
    LDA $03, S            ; Remaining columns = config(SP+3) − iteration counter(SP+7)
    SEC 
    SBC $07, S
    LDY #$0000

  loc_03E3AE:
    SEC                   ; Divide by 4 via repeated subtraction to find digit group index
    SBC #$0004
    BMI loc_03E3B9
    BEQ loc_03E3B9
    INY 
    BRA loc_03E3AE

  loc_03E3B9:
    CLC 
    ADC #$0004            ; Remainder (0–3) = digit position within packed nibble word → SP+5
    STA $05, S
    TYA 
    STA $09, S            ; Digit group index → SP+9, doubled to index into number table
    ASL 
    CLC 
    ADC $01, S
    TAY 
    LDA $0000, Y          ; Read packed nibble word from number data table
    TAX 
    LDA $05, S
    TAY 
    TXA 

  loc_03E3CF:
    DEY                   ; LSR×4 per iteration to shift target nibble into low 4 bits
    BEQ loc_03E3D8
    LSR 
    LSR 
    LSR 
    LSR 
    BRA loc_03E3CF

  loc_03E3D8:
    AND #$000F            ; Mask to single hex digit (0–F)
    TAX 
    BNE loc_03E3E7        ; Nonzero → always print; zero → check for last digit or leading zero
    LDA $05, S
    DEC 
    BEQ loc_03E3E7
    LDA $0B, S            ; Leading zero suppression: skip if no digits printed yet (SP+11 = 0)
    BEQ loc_03E40D

  loc_03E3E7:
    LDA $@HexDigitTileTable, X ; Look up digit tile from HexDigitTileTable
    AND #$00FF
    ORA $0986             ; Compose and write tile to both VRAM rows (same as character path)
    ORA #$2100
    LDX $0998
    STA $7F0200, X
    CLC 
    ADC #$0010
    STA $7F0240, X
    INX 
    INX 
    STX $0998
    LDA $0B, S            ; Set digits-printed flag at SP+11
    INC 
    STA $0B, S

  loc_03E40D:
    LDA $09, S            ; More digit groups (SP+9 ≠ 0) or positions (SP+5 > 1) → continue
    BNE loc_03E416
    LDA $05, S
    DEC 
    BEQ loc_03E420

  loc_03E416:
    LDA $07, S
    INC 
    STA $07, S
    JSR $&WaitNFrames_PerChar ; Typing delay between digits via WaitNFrames_PerChar
    BRA loc_03E3A6

  loc_03E420:
    LDX $0998
    PLA                   ; Clean up 6-word stack frame
    PLA 
    PLA 
    PLA 
    PLA 
    PLA 
    PLY 
    INY 
    INY 
    INY 
    INY 
    RTS 
}

HexDigitTileTable #20212223242526272829404142434445

---------------------------------------------
; Open a custom-sized dialogue box with border and interior.
; 
; Reads 2-byte operand: byte 0 = width (columns), byte 1 = height (rows). Stores dimensions to $0982/$0984. Falls through to OpenDialogueBox_Body which constructs the box frame using DialogueBorderTiles, fills the interior via DrawDialogueBodyRows, and triggers a display update. Skips the WaitOneFrame at the end for scene $FA (title screen).

DialogCmd_OpenDialogueBox {
    LDA $0000, Y          ; 2-byte operand: byte 0 = width (columns), byte 1 = height (rows)
    AND #$00FF
    STA $0982
    LDA $0001, Y
    AND #$00FF
    STA $0984
    INY 
    INY 

  OpenDialogueBox_Body:
    PHY 
    PHX 
    LDA $0B04             ; Restore text speed from saved frame delay ($0B04 → $007E)
    STA $007E
    LDA #$0010            ; Default per-character SFX = $10 (typing click)
    STA $0996
    STZ $00DC             ; Clear overlay flag ($00DC) and reset line counter ($099C)
    STZ $099C
    LDA $097A             ; Load column/row origins: $097A→$097E, $097C→$0980
    STA $097E
    LDA $097C
    STA $0980
    XBA                   ; Compute box content origin: row×32 + column×2 → $099A
    LSR 
    LSR 
    CLC 
    ADC $097A
    CLC 
    ADC $097A
    STA $099A
    STZ $0986
    LDA #$*DialogueBorderTiles ; Set [$3E] pointer to DialogueBorderTiles for border drawing
    STA $40
    LDA #$&DialogueBorderTiles
    STA $3E
    LDA $0982             ; Width and height doubled: 2 tiles per column, 2 tile rows per text row
    ASL 
    STA $18
    PHA 
    LDA $0984
    ASL 
    STA $1C
    LDA $0998             ; Position at border top-left: cursor − 2 bytes (1 col) − $40 (1 row)
    DEC 
    DEC 
    SEC 
    SBC #$0040
    STA $00
    TAX 
    JSR $&DrawDialogueBorderRow ; Draw: top border → body rows with side borders → bottom border
    PLX 
    PHX 
    STX $18
    JSR $&DrawDialogueBodyRows
    PLY 
    STY $18
    JSR $&DrawDialogueBorderRow
    LDA #$0001
    TSB $displayModeFlags
    LDA $sceneCurrent     ; Skip WaitOneFrame on scene $FA (title screen)
    AND #$00FF
    CMP #$00FA
    BEQ loc_03E4CB
    JSR $&WaitOneFrame

  loc_03E4CB:
    PLX 
    PLY 
    RTS 
}

DialogueBorderTiles [
  #$2010   ;00
  #$2011   ;01
  #$6010   ;02
  #$2012   ;03
  #$6012   ;04
  #$A010   ;05
  #$A011   ;06
  #$E010   ;07
]

---------------------------------------------
; Render one horizontal border row of the dialogue box.
; 
; Reads three tiles from the border tile pointer [$3E]: left corner, repeated middle tile (width times), and right corner. Writes directly to the VRAM staging buffer at $7F0200,X. Advances the tile pointer by 6 bytes (3 words) for the next border set.

DrawDialogueBorderRow {
    LDA [$3E]             ; Read left tile from [$3E], write to buffer; advance pointer by 2
    STA $7F0200, X
    INX 
    INX 
    INC $3E
    INC $3E
    LDA [$3E]             ; Read middle tile, write it width-many times (inner loop)

  loc_03E4EC:
    STA $7F0200, X
    INX 
    INX 
    DEC $18
    BNE loc_03E4EC
    INC $3E
    INC $3E
    LDA [$3E]             ; Read right tile, write; advance pointer past all 3 tiles (+6 bytes)
    STA $7F0200, X
    INC $3E
    INC $3E
    RTS 
}

---------------------------------------------
; Fill the interior rows of the dialogue box.
; 
; For each row: draws the left border tile, fills the interior with blank tiles ($2040), and draws the right border tile. Decrements the height counter $1C. After all body rows, optionally draws an additional prompt row if worldReadyFlag is set and $00EE is zero (used for the continuation prompt area). Advances the tile pointer past the border data (+4 bytes).

DrawDialogueBodyRows {
    PHY 
    LDY #$0002            ; Y = 2: offset in [$3E] for right-side border tile

  loc_03E509:
    LDA $00               ; Each body row: advance $00 by $40, draw left border + blank fill + right border
    CLC 
    ADC #$0040
    STA $00
    TAX 
    LDA [$3E]
    STA $7F0200, X
    INX 
    INX 
    LDA $18
    STA $EC
    LDA #$2040            ; Interior fill tile = $2040 (blank with BG priority)

  loc_03E521:
    STA $7F0200, X
    INX 
    INX 
    DEC $EC
    BNE loc_03E521
    LDA [$3E], Y
    STA $7F0200, X
    DEC $1C
    BNE loc_03E509
    LDA $00               ; After body rows: optional prompt row if worldReadyFlag set and $00EE = 0
    CLC 
    ADC #$0040
    STA $00
    TAX 
    LDA $00EE
    BNE loc_03E56F
    LDA $worldReadyFlag
    AND #$00FF
    BEQ loc_03E56F
    LDA [$3E]
    STA $7F0200, X
    INX 
    INX 
    LDA #$2040

  loc_03E556:
    STA $7F0200, X
    INX 
    INX 
    DEC $18
    BNE loc_03E556
    LDA [$3E], Y
    STA $7F0200, X
    LDA $00
    CLC 
    ADC #$0040
    STA $00
    TAX 

  loc_03E56F:
    LDA $3E               ; Advance border pointer past 4 tile entries (+8 bytes) for next call
    CLC 
    ADC #$0004
    STA $3E
    PLY 
    RTS 
}

---------------------------------------------
; Clear the entire dialogue box and reset rendering state.
; 
; Resets the VRAM cursor to the box origin ($099A). Zeroes all tiles within the box boundaries (width+1 × height+1 doubled). Restores the default dialogue palette: writes $675D (white), $10F2 (shadow), $0000 (transparent) to CGRAM palette offset $22. Triggers display update, resets cursor and line counter ($099C).

DialogCmd_ClearDialogueBox {
    PHY 
    PHB 
    LDA $099A             ; Reset VRAM cursor to box origin $099A
    STA $0998
    LDA $0982
    ASL                   ; Clear dimensions: (width+1) columns × (height+1)×2 tile rows
    INC 
    STA $00
    STA $18
    LDA $0984
    INC 
    ASL 
    STA $1C
    LDA $099A
    SEC 
    SBC #$0042            ; Start clearing at −$42 from origin (border top-left corner)
    STA $099A
    TAX 

  loc_03E59C:
    LDA #$0000            ; Zero-fill all tiles within box boundaries row by row

  loc_03E59F:
    STA $7F0200, X
    INX 
    INX 
    DEC $18
    BPL loc_03E59F
    LDA $00
    STA $18
    LDA $099A
    CLC 
    ADC #$0040
    STA $099A
    TAX 
    DEC $1C
    BPL loc_03E59C
    PHX 
    LDX #$0022            ; Restore dialogue palette at CGRAM $22: $675D white, $10F2 shadow, $0000 transparent
    LDA #$675D
    STA $cgramPalette, X
    LDA #$10F2
    STA $7F0A02, X
    LDA #$0000
    STA $7F0A04, X
    PLX 
    LDA #$0001
    TSB $displayModeFlags
    JSR $&WaitOneFrame
    LDX $0998             ; Update box origin to current cursor and reset line counter
    STX $099A
    STZ $099C
    PLB 
    PLY 
    RTS 
}

DialogCmd_WaitFrames {
    PHY 
    LDA $0000, Y          ; 1-byte frame count operand → WaitNFrames_Entry
    AND #$00FF
    JSR $&WaitNFrames_Entry
    PLY 
    INY 
    RTS 
}

---------------------------------------------
; Advance to the next line within the dialogue box.
; 
; Increments the line counter ($099C). If it equals the box height ($0984), scrolls the dialogue up twice (with WaitOneFrame between each scroll) to make room. Computes the new VRAM cursor position: base ($099A) + line × 32 tiles. Updates both X and $0998.

DialogCmd_NewLine {
    LDA $099C
    INC 
    CMP $0984             ; At box bottom (line = height): scroll up twice with frame pauses for smooth animation
    BNE loc_03E610
    JSR $&ScrollDialogueUp
    JSR $&WaitOneFrame
    JSR $&ScrollDialogueUp
    JSR $&WaitOneFrame
    LDA $099C

  loc_03E610:
    STA $099C
    XBA                   ; New cursor position = origin + line × 128 bytes (XBA + LSR for double-height rows)
    LSR 
    CLC 
    ADC $099A
    STA $0998
    TAX 
    RTS 
}

DialogCmd_AdvanceCursor {
    PHY 
    LDA $0000, Y
    AND #$00FF
    LSR                   ; LSR then ASL: strip low bit for 2-byte tile word alignment
    BEQ loc_03E633
    ASL 
    PHA 
    TXA                   ; Add advance amount to current cursor X
    CLC 
    ADC $01, S
    TAX 
    STA $0998
    PLA 

  loc_03E633:
    PLY 
    INY 
    RTS 
}

DialogCmd_InsertRemoteString {
    PHY 
    PHB 
    LDA $0000, Y          ; 3-byte operand: bytes 0-1 = address, byte 2 = bank
    PHA 
    SEP #$20
    LDA $0002, Y
    PHA                   ; Set DBR to remote bank, then JSL DialogStringRenderer recursively
    PLB 
    REP #$20
    PLY 
    STX $0998
    JSL $@DialogStringRenderer
    LDX $0998
    PLB 
    PLY 
    INY 
    INY 
    INY 
    RTS 
}

---------------------------------------------
; Clear the box interior without removing borders.
; 
; Fills the interior region with blank tiles ($2040) in both tile rows ($7F0200 and $7F0240). Uses dimensions ($0982−1 × $0984−1) with doubled row stride ($0080 per row = 64 tiles × 2 bytes for both top and bottom tile halves). Resets cursor to box origin and line counter to 0.

DialogCmd_ClearBox {
    LDA $0998
    LDA $0982             ; Clear interior only: (width×2 − 1) × (height − 1), excluding borders
    ASL 
    DEC 
    STA $00
    STA $18
    LDA $0984
    DEC 
    STA $1C
    LDA $099A
    STA $02
    TAX 

  loc_03E66E:
    LDA #$2040            ; Blank tile $2040 → write to both top ($0200) and bottom ($0240) VRAM rows

  loc_03E671:
    STA $7F0200, X
    STA $7F0240, X
    INX 
    INX 
    DEC $18
    BPL loc_03E671
    LDA $00
    STA $18
    LDA $02
    CLC 
    ADC #$0080            ; +$0080 per row (2 VRAM rows per double-height text line)
    STA $02
    TAX 
    DEC $1C
    BPL loc_03E66E
    LDA $099A             ; Reset cursor to box origin, zero line counter, trigger display update
    STA $0998
    TAX 
    STZ $099C
    LDA #$0001
    TSB $displayModeFlags
    JSR $&WaitOneFrame
    RTS 
}

---------------------------------------------
; Wait for the player to press A, B, or Start with a blinking cursor indicator.
; 
; Sets $C080 in joypadHeld to suppress auto-repeat. Loops calling WaitOneFrame until $C080 is detected in joypadCurrent. During the wait, draws a blinking cursor via DrawDialogueCursor (carry set = animate). On button press, clears the cursor (carry clear) and calls DialogCmd_ClearBox to prepare for the next page.

DialogCmd_WaitForButton {
    LDA #$C080            ; Suppress A/B/Start auto-repeat ($C080 in joypadHeld)
    TSB $joypadHeld

  loc_03E6AA:
    JSR $&WaitOneFrame
    LDA $joypadCurrent
    AND #$C080            ; $C080 mask: A ($0080), B ($8000), or Start ($4000)
    BNE loc_03E6C1
    SEC                   ; SEC = animate blinking cursor, CLC = erase cursor
    JSR $&DrawDialogueCursor
    LDA #$0001
    TSB $displayModeFlags
    BRA loc_03E6AA

  loc_03E6C1:
    STA $joypadHeld       ; On button: acknowledge input, erase cursor, clear box for next page
    CLC 
    JSR $&DrawDialogueCursor
    LDA #$0001
    TSB $displayModeFlags
    JSR $&DialogCmd_ClearBox
    RTS 
}

---------------------------------------------
; Wait for any button press.
; 
; Sets $CFF0 in joypadHeld to suppress all auto-repeat. Loops calling WaitOneFrame until any button in $CFFF is pressed. Stores the pressed button to joypadHeld and returns.

DialogCmd_WaitForAnyInput {
    LDA #$CFF0            ; Suppress all button auto-repeat ($CFF0)
    TSB $joypadHeld

  loc_03E6D8:
    JSR $&WaitOneFrame
    LDA $joypadCurrent
    AND #$CFFF            ; $CFFF mask — poll for any button press
    BEQ loc_03E6D8
    STA $joypadHeld
    RTS 
}

DialogCmd_JumpToAddress {
    LDA $0000, Y          ; 2-byte operand → set Y to new string address
    TAY 
    RTS 
}

DialogCmd_SetSfx {
    LDA $0000, Y
    INY 
    AND #$00FF
    STA $0996             ; Store per-character SFX ID to $0996
    RTS 
}

---------------------------------------------
; Open the standard dialogue box used for most NPC conversations.
; 
; Hardcoded dimensions: 13 columns × 4 rows, positioned at column 3, row 17 (bottom of screen). Computes the VRAM buffer offset and jumps to OpenDialogueBox_Body to share the box construction logic with DialogCmd_OpenDialogueBox.

DialogCmd_OpenDefaultBox {
    LDA #$000D            ; Hardcoded default box: 13 columns × 4 rows at position (3, 17)
    STA $0982
    LDA #$0004
    STA $0984
    LDA #$0003
    STA $097A
    LDA #$0011
    STA $097C
    XBA 
    LSR 
    LSR 
    CLC 
    ADC $097A
    CLC 
    ADC $097A
    TAX 
    STA $0998
    JMP $&OpenDialogueBox_Body ; Jump to shared OpenDialogueBox_Body construction logic
}

---------------------------------------------
; Write a single 15-bit color value directly to the CGRAM palette buffer.
; 
; Reads 3-byte operand: byte 0 = palette index (×2 for word offset), bytes 1-2 = 15-bit BGR color value. Writes to $7F0A00 + index×2. Used for dialogue-specific color effects.

DialogCmd_SetPaletteColor {
    PHX 
    LDA $0000, Y          ; 3-byte operand: palette index (×2 for word offset), then 15-bit BGR color
    AND #$00FF
    ASL 
    TAX 
    LDA $0001, Y
    STA $cgramPalette, X  ; Write color directly to CGRAM buffer at $7F0A00 + index×2
    INY 
    INY 
    INY 
    PLX 
    RTS 
}

---------------------------------------------
; Set the per-character typing delay.
; 
; Reads a 1-byte operand, adds 2 (INC INC), masks to byte, and stores to $007E. The +2 bias means operand 0 = 2-frame delay, operand 1 = 3-frame delay, etc. A value of 0 in $007E (from the BEQ check in WaitNFrames_PerChar) causes instant rendering.

DialogCmd_SetFrameDelay {
    LDA $0000, Y
    INY 
    INC                   ; +2 bias: operand 0 → 2-frame delay, 1 → 3-frame, etc.
    INC 
    AND #$00FF
    STA $007E             ; Store to $007E — controls per-character typing speed
    RTS 
}

---------------------------------------------
; Insert a word from dictionary A (dictionary_01EBA8).
; 
; Reads a 1-byte index, doubles it for the word pointer table, switches DBR to the dictionary bank, reads the string pointer, and recursively renders via JSL DialogStringRenderer. Used for common words to save space in dialogue scripts.

DialogCmd_DictionaryA {
    PHP 
    PHB 
    PHY 
    LDA $0000, Y          ; 1-byte index, doubled for word pointer table
    AND #$00FF
    ASL 
    TAY 
    SEP #$20
    LDA #$^dialog_dictionaries.dialog_dictionary_a ; Switch DBR to dictionary bank, read string pointer, JSL recursive render
    PHA 
    PLB 
    REP #$20
    LDA $&dialog_dictionaries.dialog_dictionary_a, Y
    TAY 
    STX $0998
    JSL $@DialogStringRenderer
    LDX $0998
    PLY 
    INY 
    PLB 
    PLP 
    RTS 
}

---------------------------------------------
; Insert a word from dictionary B (dictionary_01F54D).
; 
; Identical to DictionaryA but reads from the second dictionary table. Two dictionaries allow more than 256 common words while keeping operands to 1 byte each.

DialogCmd_DictionaryB {
    PHP 
    PHB 
    PHY 
    LDA $0000, Y          ; Same structure as DictionaryA but reads from dictionary_01F54D
    AND #$00FF
    ASL 
    TAY 
    SEP #$20
    LDA #$^dialog_dictionaries.dialog_dictionary_b
    PHA 
    PLB 
    REP #$20
    LDA $&dialog_dictionaries.dialog_dictionary_b, Y
    TAY 
    STX $0998
    JSL $@DialogStringRenderer
    LDX $0998
    PLY 
    INY 
    PLB 
    PLP 
    RTS 
}

---------------------------------------------
; Output raw tile bytes directly until a zero terminator.
; 
; Reads bytes from the string stream one at a time. Each nonzero byte is OR'd with palette and priority bits and written to both VRAM buffer rows. Zero byte terminates. Used for rendering pre-composed tile sequences (icons, special characters).

DialogCmd_PrintRawTiles {
    LDA $0000, Y          ; Read byte → compose tile → write both rows; loop until zero terminator
    INY 
    AND #$00FF
    BEQ loc_03E7AE
    ORA $0986
    ORA #$2100
    STA $7F0200, X
    CLC 
    ADC #$0010
    STA $7F0240, X
    INX 
    INX 
    BRA DialogCmd_PrintRawTiles

  loc_03E7AE:
    STX $0998
    RTS 
}

---------------------------------------------
; Wait exactly one frame by loading A = 1 and falling through to WaitNFrames_Entry.

WaitOneFrame {
    LDA #$0001            ; Falls through to WaitNFrames_Entry with A = 1
}

---------------------------------------------
; Wait for A frames. Saves processor state (PHP), switches to 8-bit A (SEP #$20), and branches to the wait loop body. If worldReadyFlag is zero, returns immediately without waiting (game not yet in rendering state).

WaitNFrames_Entry {
    PHP 
    SEP #$20
    BRA loc_03E7C2
}

---------------------------------------------
; Wait for the per-character frame delay stored in $007E.
; 
; Saves processor state, switches to 8-bit. If $007E = 0, returns immediately (instant text mode). Otherwise falls into the wait loop. Each iteration calls UpdateFrameDialogue to process a lightweight frame update (audio, display sync) without advancing game logic.

WaitNFrames_PerChar {
    PHP 
    SEP #$20
    LDA $007E             ; $007E = 0 → instant text mode, skip frame wait
    BEQ loc_03E7D4

  loc_03E7C2:
    PHA 
    LDA $worldReadyFlag   ; worldReadyFlag not set → return immediately (no frame sync during init)
    BNE loc_03E7CC
    PLA 
    PLP 
    RTS 
}

WaitNFrames_Loop {
    PHA 

  loc_03E7CC:
    JSL $@system_core.UpdateFrameDialogue ; UpdateFrameDialogue: lightweight frame tick (audio/display, no game logic)
    PLA 
    DEC 
    BNE WaitNFrames_Loop

  loc_03E7D4:
    PLP 
    RTS 
}

---------------------------------------------
; Scroll all dialogue box content up by one line.
; 
; Copies each row from $7F0240 (bottom tile row) to $7F0200 (top tile row) across the full box width. Repeats for (height × 2 − 1) rows. Triggers display update when complete. Called twice (with WaitOneFrame between) by DialogCmd_NewLine for smooth visual scrolling.

ScrollDialogueUp {
    LDA $099A
    STA $00
    TAX 
    LDA $0984
    ASL                   ; Scroll height×2 − 1 rows (last row left blank for new text)
    DEC 
    STA $1C

  loc_03E7E3:
    LDA $0982
    ASL 
    DEC 
    STA $18

  loc_03E7EA:
    LDA $7F0240, X        ; Inner loop: copy each tile from bottom row ($0240) to top row ($0200)
    STA $7F0200, X
    INX 
    INX 
    DEC $18
    BPL loc_03E7EA
    LDA $00
    CLC 
    ADC #$0040            ; +$40 per row advances through VRAM staging buffer
    STA $00
    TAX 
    DEC $1C
    BPL loc_03E7E3
    LDA #$0001
    TSB $displayModeFlags
    RTS 
}

---------------------------------------------
; Draw or erase the blinking continuation cursor at the bottom-right of the dialogue box.
; 
; Carry flag controls mode: SEC = animate (blink), CLC = erase. In animate mode, uses a frame counter ($0994) with a 16-frame period: odd frames show the cursor tile ($2091), even frames show blank ($2040). Computes the cursor position from box dimensions and origin.
; 
; The position formula: X = ((height×2 + row_origin) × 32 + width + column_origin) × 2, indexing into $7F0200.

DrawDialogueCursor {
    PHP                   ; Carry flag controls mode: SEC = animate (blink), CLC = erase
    LDA $0984
    ASL 
    CLC 
    ADC $0980             ; Position at box bottom-right: (height×2 + row_origin) × 32 + width + col_origin
    ASL 
    ASL 
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $0982
    CLC 
    ADC $097E
    ASL                   ; ×2 for byte offset into $7F0200 tilemap buffer
    TAX 
    PLP 
    BCC loc_03E83F
    LDA $36               ; 16-frame blink cycle: toggle via bit 4 of global frame counter $36
    BIT #$000F
    BNE loc_03E831
    INC $0994

  loc_03E831:
    LDA $0994
    BIT #$0001            ; Blink counter bit 0: odd = cursor tile $2091, even = blank $2040
    BEQ loc_03E83F
    LDA #$2091
    PHA 
    BRA loc_03E843

  loc_03E83F:
    LDA #$2040
    PHA 

  loc_03E843:
    PLA 
    STA $7F0200, X
    RTS 
}