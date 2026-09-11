; Wide-string dialogue renderer, dialogue box management, and menu selection system (254549–256610, Bank 03).
; 
; Implements the complete text rendering pipeline for IOG's dialogue system. The engine processes a bytecode-driven wide-string format where characters below $C0 are tile indices rendered directly to a VRAM staging buffer, and bytes $C0–$FF are command opcodes dispatched through a 25-entry command table.
; 
; === WIDE STRING RENDERER (254549) ===
; 
; Entry point: WideStringRenderer, called via JSL from COP script handlers and other engine systems.
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
; WideCmd_OpenDialogueBox (255039) and WideCmd_OpenDefaultBox (255735) construct the box frame:
; 1. Set border tile pointer to DialogueBorderTiles (8 tiles: corners + edges)
; 2. DrawDialogueBorderRow renders top/bottom borders
; 3. DrawDialogueBodyRows fills interior rows with blank tiles ($2040) and side borders
; 4. An optional prompt row is appended when worldReadyFlag is set and $00EE is zero
; 
; The VRAM staging buffer at $7F0200 uses a linear layout: each row is $40 words (64 tiles). Box position is computed as: base = (row × 32 + column) × 2, where the ×32 comes from XBA + LSR + LSR.
; 
; === MENU SELECTION SYSTEM (256073) ===
; 
; MenuSelectionHandler provides a general-purpose menu cursor for dialogue choices. It uses a packed byte format on the stack: high nibble = total rows, low nibble = columns per page. The current selection index is at SP+1.
; 
; Input handling:
; - Up ($0800): Decrement selection with wraparound
; - Down ($0400): Increment selection with wraparound
; - L/R ($0300): Page left/right (add/subtract column count)
; - A/Start ($8080): Confirm selection — play sound #11, increment result by 1, return with carry set
; - B ($4000): Cancel — call ReadMenuSelection, return result = 0
; 
; DrawMenuCursor (256387) handles cursor animation: a 16-frame blink cycle alternates between highlight tiles ($212C/$213C) and dim tiles ($21AC). It saves/restores the tile under the cursor via $0990/$0992.
; 
; ReadMenuSelection (256554) restores the original tiles and converts the cursor position to OAM-compatible sprite data at $090E/$0910.
---------------------------------------------

?BANK 03

?INCLUDE 'dictionary_01EBA8'
?INCLUDE 'dictionary_01F54D'
?INCLUDE 'system_core'
?INCLUDE 'templates_01CA95'

!sceneCurrent                   0644
!worldReadyFlag                 0654
!joypadCurrent                  0656
!joypadHeld                     0658
!sfxQueueCh1                    06F8
!sfxQueueCh2                    06F9
!displayModeFlags               09EC
!cgramPalette                   7F0A00

---------------------------------------------

; Main bytecode interpreter for the wide-string dialogue format.
; 
; Entry: JSL with Y = string data pointer, X = VRAM buffer cursor (saved to $0998). Sets DP = 0 for zero-page scratch access.
; 
; The character loop (WideString_CharLoop) reads one byte at a time from [Y]. Bytes < $C0 are treated as tile indices: masked to 8 bits, OR'd with palette bits ($0986) and priority ($2100), then written to both $7F0200,X (top tile row) and $7F0240,X (bottom row, +$10 offset). The cursor X advances by 2 per character.
; 
; Bytes ≥ $C0 are command opcodes: masked to 5 bits (AND #$001F), doubled as a word index, looked up in WideStringCommandTable, and dispatched via an RTS trick (PEA loop_addr−1, push cmd_addr−1, RTS).
; 
; After each visible character: if worldReadyFlag is set, calls WaitNFrames_PerChar for the typing delay, checks for the ellipsis tile ($AC) to suppress sound, and queues the per-character SFX ($0996) to sfxQueueCh1.

WideStringRenderer {
    PHP                   ; Save processor status for clean RTL exit via WideCmd_Return
    PHD                   ; Save caller's direct page — restored on exit
    PHX                   ; Save X register (VRAM cursor) for return
    LDA #$0000            ; Set A = 0 for TCD
    TCD                   ; DP = $0000 — enables DP-relative scratch access at $00–$FF
    LDX $0998             ; Load current VRAM buffer write cursor into X

  WideString_CharLoop:
    SEP #$20              ; Switch to 8-bit A for single-byte character reads
    LDA $0000, Y          ; Read next byte from string data stream at [Y]
    CMP #$C0              ; Compare to $C0 — command opcode threshold
    BCC loc_03E27C        ; Below $C0 = printable tile character → render at loc_03E27C
    REP #$20              ; Command byte: switch to 16-bit A for table lookup
    INY                   ; Advance string pointer past the command byte
    PEA $&WideString_CharLoop-1 ; PEA loop_addr−1: push return address for RTS trick (back to CharLoop)
    AND #$001F            ; Mask command to 5 bits (indices 0–24 = $C0–$D8)
    ASL                   ; Double for word-sized table index
    PHX                   ; Save VRAM cursor X before table lookup uses X
    TAX                   ; Transfer table index to X
    LDA $@WideStringCommandTable, X ; Load command handler address from WideStringCommandTable (long,X)
    PLX                   ; Restore VRAM cursor X
    DEC                   ; Subtract 1 — RTS will add 1 to make the correct jump target
    PHA                   ; Push command address onto stack
    RTS                   ; RTS: pops address+1 and jumps to command handler

  loc_03E27C:
    REP #$20              ; Printable character: switch to 16-bit A for tile word construction
    AND #$00FF            ; Zero-extend the tile byte to 16 bits
    INY                   ; Advance string pointer past the character byte
    STA $00               ; Save raw tile index to DP $00 for sound comparison later
    ORA $0986             ; OR with palette bits from $0986 (set by SetPalette command)
    ORA #$2100            ; OR with $2100 — set tile priority bit and high tile page
    LDX $0998             ; Load current VRAM cursor position
    STA $7F0200, X        ; Write composed tile word to top tile row in staging buffer
    CLC                   ; CLC for bottom row offset addition
    ADC #$0010            ; Add $0010 — bottom tile is 16 entries after top tile
    STA $7F0240, X        ; Write bottom tile row
    INX                   ; Advance cursor by one tile (2 bytes per tile word)
    INX 
    STX $0998             ; Store updated cursor position back to $0998
    LDA $worldReadyFlag   ; Check worldReadyFlag ($0654) — is the game in rendering state?
    BEQ WideString_CharLoop ; Not ready → skip typing delay, loop back immediately
    LDA $00               ; Reload raw tile index from DP $00
    PHA                   ; Save tile index for post-delay comparison
    LDA #$0001            ; Set display-dirty flag: bit 0 ($0001) in displayModeFlags
    TSB $displayModeFlags ; TSB $09EC triggers VRAM DMA on next VBlank
    JSR $&WaitNFrames_PerChar ; JSR WaitNFrames_PerChar — pause for typing effect ($007E frames)
    PLA                   ; Restore tile index from stack
    CMP #$00AC            ; Compare to $00AC — ellipsis tile (…) suppresses click sound
    BEQ WideString_CharLoop ; Ellipsis → skip sound, loop back silently
    LDA $sfxQueueCh1      ; Load current SFX queue state from $06F8
    AND #$FF00            ; Clear low byte (preserve high byte channel state)
    ORA $0996             ; OR in the per-character sound ID from $0996
    STA $sfxQueueCh1      ; Write merged SFX to queue — plays on next audio tick
    BRA WideString_CharLoop ; Loop back to process next character
}

WideStringCommandTable [
  &WideCmd_EndAndWait   ;00
  &WideCmd_SetPosition   ;01
  &WideCmd_InsertTemplate   ;02
  &WideCmd_SetPalette   ;03
  &WideCmd_InfiniteLoop   ;04
  &WideCmd_IndirectString   ;05
  &WideCmd_PrintNumber   ;06
  &WideCmd_OpenDialogueBox   ;07
  &WideCmd_ClearDialogueBox   ;08
  &WideCmd_WaitFrames   ;09
  &WideCmd_Return   ;0A
  &WideCmd_NewLine   ;0B
  &WideCmd_AdvanceCursor   ;0C
  &WideCmd_InsertRemoteString   ;0D
  &WideCmd_ClearBox   ;0E
  &WideCmd_WaitForButton   ;0F
  &WideCmd_WaitForAnyInput   ;10
  &WideCmd_JumpToAddress   ;11
  &WideCmd_SetSfx   ;12
  &WideCmd_OpenDefaultBox   ;13
  &WideCmd_SetPaletteColor   ;14
  &WideCmd_SetFrameDelay   ;15
  &WideCmd_DictionaryA   ;16
  &WideCmd_DictionaryB   ;17
  &WideCmd_PrintRawTiles   ;18
]

---------------------------------------------
; End-of-dialogue command: waits for any input, clears the dialogue box, suppresses attack/start held flags ($0F00), and restores the saved frame delay from $0B04 to $007E.

WideCmd_EndAndWait {
    JSR $&WideCmd_WaitForAnyInput ; JSR WaitForAnyInput — block until player presses a button
    JSR $&WideCmd_ClearDialogueBox ; JSR ClearDialogueBox — erase box contents and borders
    LDA #$0F00            ; Clear $0F00 from joypadHeld — release attack/start suppression
    TRB $joypadHeld       ; TRB clears the bits in $0658
    LDA $0B04             ; Load saved frame delay from $0B04
    STA $007E             ; Restore to $007E — return text speed to pre-dialogue value
}

---------------------------------------------
; Exit the wide-string renderer. Saves the VRAM cursor back to $0998, pops the return address and saved registers (X, X, DP, P), then RTL returns to the caller. The double PLX discards the PEA'd loop return address from the command dispatch stack frame.

WideCmd_Return {
    STX $0998             ; Save VRAM cursor back to $0998 before unwinding stack
    PLX                   ; Pop PEA'd loop return address (discarded — exiting renderer)
    PLX                   ; Pop second loop address word
    PLD                   ; Restore caller's direct page
    PLP                   ; Restore caller's processor flags (M/X mode)
    RTL                   ; Return to caller via RTL
}

---------------------------------------------
; Set the dialogue cursor to a specific (column, row) position.
; 
; Reads a 2-byte operand: low byte = column → $097A, high byte = row → $097C. Computes the VRAM buffer offset as: (row >> 2) + column + column = row×32×2 + column×2, matching the $7F0200 tilemap layout. Updates both X register and $0998.

WideCmd_SetPosition {
    PHY                   ; Save string pointer Y — operand read will advance it
    LDA $0000, Y          ; Read 2-byte operand: low = column, high = row
    PHA                   ; Save combined value for row extraction
    AND #$00FF            ; Mask low byte = column index
    STA $097A             ; Store column to $097A
    PLA                   ; Restore combined column|row
    XBA                   ; XBA: swap bytes — now low byte = row
    AND #$00FF            ; Mask to byte = row index
    STA $097C             ; Store row to $097C
    XBA                   ; XBA back to get row in high byte position
    LSR                   ; LSR: begin computing VRAM offset = row × 32
    LSR 
    CLC                   ; CLC for addition
    ADC $097A             ; Add column (first of two additions = column × 2 + row_offset)
    CLC 
    ADC $097A             ; Add column again (total offset = row×32 + column×2)
    TAX                   ; Transfer computed offset to X (VRAM cursor)
    STA $0998             ; Store to $0998
    PLY                   ; Restore string pointer Y
    INY                   ; Skip past 2 consumed operand bytes
    INY 
    RTS                   ; Return to character loop
}

---------------------------------------------
; Recursively render a template string from the templates_01CA95 table.
; 
; Reads a 1-byte operand (template index), multiplies by 2 for the word-sized pointer table, switches DBR to the template bank, and calls WideStringRenderer recursively via JSL. Restores the VRAM cursor, string pointer, bank, and processor state on return.

WideCmd_InsertTemplate {
    PHP                   ; Save processor flags (mode bits)
    PHB                   ; Save data bank — will switch to template bank
    PHY                   ; Save string pointer Y
    LDA $0000, Y          ; Read 1-byte template index from operand
    AND #$00FF            ; Mask to byte
    ASL                   ; Double for word-sized pointer table entry
    TAY                   ; Transfer index to Y for table read
    SEP #$20              ; Switch to 8-bit to push bank byte
    LDA #$^templates_01CA95 ; Load template bank byte ($^templates_01CA95)
    PHA                   ; Push bank byte
    PLB                   ; Set DBR to template bank for absolute reads
    REP #$20              ; Back to 16-bit for pointer read
    LDA $&templates_01CA95, Y ; Read template string pointer from table
    TAY                   ; Transfer to Y — string pointer for recursive call
    STX $0998             ; Save current VRAM cursor to $0998 before recursive call
    JSL $@WideStringRenderer ; JSL WideStringRenderer — recursively render template string
    LDX $0998             ; Restore VRAM cursor from $0998 (may have advanced in recursion)
    PLY                   ; Restore original string pointer Y
    INY                   ; Skip past 1 consumed operand byte
    PLB                   ; Restore data bank
    PLP                   ; Restore processor flags
    RTS                   ; Return to character loop
}

---------------------------------------------
; Set the tile palette for subsequent characters.
; 
; Reads a 1-byte palette index, swaps bytes (XBA) and shifts left 2 (ASL ×2) to position palette bits in the VRAM tile word format (bits 12-10). Stores to $0986 which is OR'd into every tile written by the character loop.

WideCmd_SetPalette {
    PHY                   ; Save string pointer Y
    LDA $0000, Y          ; Read 1-byte palette index
    AND #$00FF            ; Mask to byte
    XBA                   ; XBA: move palette index to high byte
    ASL                   ; ASL: shift into palette bit position (bits 12-10 of tile word)
    ASL                   ; Second ASL completes positioning
    STA $0986             ; Store palette bits to $0986 — OR'd into every subsequent tile
    PLY                   ; Restore Y
    INY                   ; Skip past 1 operand byte
    RTS                   ; Return
}

WideCmd_InfiniteLoop {
    NOP                   ; Two NOPs as delay padding
    NOP 
    BRA WideCmd_InfiniteLoop ; BRA self — infinite loop (halts the dialogue engine)
}

---------------------------------------------
; Render a string selected from an indirect pointer table.
; 
; Reads a 4-byte operand: bytes 0-1 = base pointer offset, bytes 2-3 = table address. Computes the string pointer as: table[base[table_addr]] + base_offset. Then recursively renders via JSL WideStringRenderer.

WideCmd_IndirectString {
    PHY                   ; Save string pointer Y
    STX $0998             ; Save VRAM cursor to $0998
    LDX $0002, Y          ; Read table address from operand bytes 2-3
    LDA $0000, X          ; Read the value at the table address (index into pointer array)
    ASL                   ; Double for word-sized pointer entry
    CLC                   ; CLC for addition
    ADC $0000, Y          ; Add base offset from operand bytes 0-1
    TAX                   ; Transfer computed pointer to X
    LDA $0000, X          ; Read the actual string address from the resolved pointer
    TAY                   ; Transfer string address to Y for recursive rendering
    LDX $0998             ; Reload VRAM cursor from $0998
    JSL $@WideStringRenderer ; JSL WideStringRenderer — render the indirect string
    LDX $0998             ; Restore VRAM cursor
    PLY                   ; Restore original string pointer Y
    INY                   ; Skip past 4 consumed operand bytes
    INY 
    INY 
    INY 
    RTS                   ; Return
}

---------------------------------------------
; Format and render a multi-digit number as tile characters.
; 
; Reads a 4-byte operand: bytes 0-1 = number table address, bytes 2-3 = column/digit configuration. Uses a stack frame with 6 words for loop state: divider, table base, current digit position, iteration counter, digit index, and digits-printed flag.
; 
; The algorithm divides the number into 4-pixel-wide digit groups, extracts each nibble by repeated LSR ×4, looks up the tile in HexDigitTileTable, and writes it to the VRAM buffer. Leading zeros are suppressed (skipped until the first nonzero digit or last position). Each digit triggers WaitNFrames_PerChar for the typing effect.

WideCmd_PrintNumber {
    PHY                   ; Save string pointer Y — will be restored after number rendering
    LDA #$0000            ; Push 4 zero words onto stack for loop state frame
    PHA 
    PHA 
    PHA 
    PHA 
    STX $0998             ; Save VRAM cursor to $0998
    LDA $0000, Y          ; Read number data table base pointer from operand bytes 0-1
    PHA                   ; Push table base to stack
    LDA $0002, Y          ; Read column/digit configuration from operand bytes 2-3
    PHA                   ; Push config to stack

  loc_03E3A6:
    LDA $03, S            ; Load column counter from SP+3
    SEC                   ; SEC for subtraction
    SBC $07, S            ; Subtract iteration counter from SP+7 — remaining columns to process
    LDY #$0000            ; Initialize digit Y index to 0

  loc_03E3AE:
    SEC                   ; SEC for repeated subtraction (div by 4)
    SBC #$0004            ; Subtract 4 from remainder
    BMI loc_03E3B9        ; Negative → division complete
    BEQ loc_03E3B9        ; Zero → division complete
    INY                   ; Increment quotient (digit group count)
    BRA loc_03E3AE        ; Loop division by 4

  loc_03E3B9:
    CLC                   ; CLC — add back the overshoot
    ADC #$0004            ; ADC #$0004 restores the remainder (0–3)
    STA $05, S            ; Store remainder to SP+5 (digit position within group)
    TYA                   ; Transfer quotient Y → A
    STA $09, S            ; Store digit group index to SP+9
    ASL                   ; Double for word-sized table entry
    CLC                   ; CLC for addition
    ADC $01, S            ; Add table base from SP+1 to get nibble data pointer
    TAY                   ; Transfer to Y for table read
    LDA $0000, Y          ; Read the packed nibble word from number data table
    TAX                   ; Transfer to X (nibble data in X)
    LDA $05, S            ; Reload digit position from SP+5
    TAY                   ; Transfer to Y (shift count)
    TXA                   ; Transfer nibble data back to A

  loc_03E3CF:
    DEY                   ; Decrement shift count — extract next nibble
    BEQ loc_03E3D8        ; Shift count = 0 → nibble is in low 4 bits, ready
    LSR                   ; Shift right 4 bits to expose next nibble
    LSR 
    LSR 
    LSR 
    BRA loc_03E3CF        ; Loop until correct nibble is in low 4 bits

  loc_03E3D8:
    AND #$000F            ; Mask to single nibble (0–F)
    TAX                   ; Transfer digit value to X for tile lookup
    BNE loc_03E3E7        ; Nonzero digit → always print it
    LDA $05, S            ; Zero digit: check position — is this the last digit?
    DEC                   ; DEC position: if position was 1, this is the last → print zero
    BEQ loc_03E3E7        ; Last position → must print zero
    LDA $0B, S            ; Load digits-printed flag from SP+11
    BEQ loc_03E40D        ; No digits printed yet and not last → suppress leading zero

  loc_03E3E7:
    LDA $@HexDigitTileTable, X ; Look up digit tile from HexDigitTileTable (long,X)
    AND #$00FF            ; Mask to byte
    ORA $0986             ; OR with palette bits
    ORA #$2100            ; OR with priority $2100
    LDX $0998             ; Load VRAM cursor
    STA $7F0200, X        ; Write top tile row
    CLC                   ; CLC for bottom row offset
    ADC #$0010            ; Add $0010 for bottom tile
    STA $7F0240, X        ; Write bottom tile row
    INX                   ; Advance cursor by 2
    INX 
    STX $0998             ; Store cursor back to $0998
    LDA $0B, S            ; Load digits-printed flag
    INC                   ; Increment — mark that at least one digit has been printed
    STA $0B, S            ; Store updated flag back to SP+11

  loc_03E40D:
    LDA $09, S            ; Load digit group index from SP+9
    BNE loc_03E416        ; Nonzero → more digit groups remain
    LDA $05, S            ; Load digit position from SP+5
    DEC                   ; Decrement position
    BEQ loc_03E420        ; Position = 0 → all digits in this column processed

  loc_03E416:
    LDA $07, S            ; Load iteration counter from SP+7
    INC                   ; Increment iteration counter
    STA $07, S            ; Store updated counter
    JSR $&WaitNFrames_PerChar ; JSR WaitNFrames_PerChar — typing delay between digit groups
    BRA loc_03E3A6        ; Loop back to process next column

  loc_03E420:
    LDX $0998             ; Load VRAM cursor — all digits rendered
    PLA                   ; Clean up stack: pop 6 words of loop state
    PLA 
    PLA 
    PLA 
    PLA 
    PLA 
    PLY                   ; Restore original string pointer Y
    INY                   ; Skip past 4 consumed operand bytes
    INY 
    INY 
    INY 
    RTS                   ; Return to character loop
}

HexDigitTileTable #20212223242526272829404142434445

---------------------------------------------
; Open a custom-sized dialogue box with border and interior.
; 
; Reads 2-byte operand: byte 0 = width (columns), byte 1 = height (rows). Stores dimensions to $0982/$0984. Falls through to OpenDialogueBox_Body which constructs the box frame using DialogueBorderTiles, fills the interior via DrawDialogueBodyRows, and triggers a display update. Skips the WaitOneFrame at the end for scene $FA (title screen).

WideCmd_OpenDialogueBox {
    LDA $0000, Y          ; Read 1st operand byte = box width (columns)
    AND #$00FF            ; Mask to byte
    STA $0982             ; Store width to $0982
    LDA $0001, Y          ; Read 2nd operand byte = box height (rows)
    AND #$00FF            ; Mask to byte
    STA $0984             ; Store height to $0984
    INY                   ; Advance string pointer past 2 operand bytes
    INY 

  OpenDialogueBox_Body:
    PHY                   ; Save string pointer Y for after box construction
    PHX                   ; Save VRAM cursor X
    LDA $0B04             ; Load saved frame delay from $0B04
    STA $007E             ; Store to $007E — set text speed for this dialogue
    LDA #$0010            ; Set per-character SFX to $0010 (default click sound)
    STA $0996             ; Store to $0996
    STZ $00DC             ; Zero $00DC — clear dialogue overlay flag
    STZ $099C             ; Zero $099C — reset current line counter to 0
    LDA $097A             ; Load column position $097A
    STA $097E             ; Copy to $097E — save column origin for cursor calculations
    LDA $097C             ; Load row position $097C
    STA $0980             ; Copy to $0980 — save row origin
    XBA                   ; XBA: row to high byte for VRAM offset computation
    LSR                   ; LSR ×2: begin row × 32 calculation (row × 256 >> 2 >> 2 = row × 16...
    LSR 
    CLC 
    ADC $097A             ; Add column twice to complete: offset = row×32 + column×2
    CLC 
    ADC $097A
    STA $099A             ; Store computed base offset to $099A (box content origin)
    STZ $0986             ; Zero palette bits $0986 — default palette
    LDA #$*DialogueBorderTiles ; Load DialogueBorderTiles bank byte
    STA $40               ; Store to $40 (high byte of [$3E] pointer)
    LDA #$&DialogueBorderTiles ; Load DialogueBorderTiles base address
    STA $3E               ; Store to $3E (low word of border tile data pointer)
    LDA $0982             ; Load width from $0982
    ASL                   ; Double for tile count (each column = 2 bytes in VRAM)
    STA $18               ; Store doubled width to DP $18 (middle tile repeat count)
    PHA                   ; Save doubled width on stack for bottom border
    LDA $0984             ; Load height from $0984
    ASL                   ; Double for tile rows (each row = 2 tile rows in VRAM)
    STA $1C               ; Store doubled height to DP $1C (body row count)
    LDA $0998             ; Load current VRAM cursor from $0998
    DEC                   ; Back up 1 column (DEC DEC = −2 bytes)
    DEC 
    SEC 
    SBC #$0040            ; Subtract $0040 (one full VRAM row = 64 bytes) to position above content
    STA $00               ; Store top-left corner position to DP $00
    TAX                   ; Transfer to X for DrawDialogueBorderRow
    JSR $&DrawDialogueBorderRow ; JSR DrawDialogueBorderRow — draw top border
    PLX                   ; Restore doubled width for body rows
    PHX 
    STX $18               ; Set middle tile count from width
    JSR $&DrawDialogueBodyRows ; JSR DrawDialogueBodyRows — fill interior and side borders
    PLY                   ; Restore doubled width for bottom border
    STY $18
    JSR $&DrawDialogueBorderRow ; JSR DrawDialogueBorderRow — draw bottom border
    LDA #$0001            ; Set display-dirty flag
    TSB $displayModeFlags ; TSB displayModeFlags triggers VRAM update
    LDA $sceneCurrent     ; Load current scene ID from $0644
    AND #$00FF            ; Mask to byte
    CMP #$00FA            ; Compare to scene $FA (title screen)
    BEQ loc_03E4CB        ; Title screen → skip WaitOneFrame (no visual delay needed)
    JSR $&WaitOneFrame    ; JSR WaitOneFrame — pause to let box render to screen

  loc_03E4CB:
    PLX                   ; Restore VRAM cursor X
    PLY                   ; Restore string pointer Y
    RTS                   ; Return to character loop
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
    LDA [$3E]             ; Read left corner/edge tile from border data pointer [$3E]
    STA $7F0200, X        ; Write to VRAM staging buffer at current position
    INX                   ; Advance buffer position by 2 bytes
    INX 
    INC $3E               ; Advance border tile pointer by 2 (next = middle tile)
    INC $3E
    LDA [$3E]             ; Read middle border tile from [$3E]

  loc_03E4EC:
    STA $7F0200, X        ; Write middle tile to buffer (inner loop start)
    INX                   ; Advance buffer position
    INX 
    DEC $18               ; Decrement middle tile count
    BNE loc_03E4EC        ; More middle tiles → repeat
    INC $3E               ; Advance border pointer to right corner tile
    INC $3E
    LDA [$3E]             ; Read right corner/edge tile
    STA $7F0200, X        ; Write right corner to buffer
    INC $3E               ; Advance border pointer past right tile (ready for next row set)
    INC $3E
    RTS                   ; Return — border row complete
}

---------------------------------------------
; Fill the interior rows of the dialogue box.
; 
; For each row: draws the left border tile, fills the interior with blank tiles ($2040), and draws the right border tile. Decrements the height counter $1C. After all body rows, optionally draws an additional prompt row if worldReadyFlag is set and $00EE is zero (used for the continuation prompt area). Advances the tile pointer past the border data (+4 bytes).

DrawDialogueBodyRows {
    PHY                   ; Save Y (= 2, used as [$3E] offset for right border tile)
    LDY #$0002            ; Y = 2: index for right-side border tile in [$3E] data

  loc_03E509:
    LDA $00               ; Advance DP $00 by one VRAM row ($40 = 64 bytes)
    CLC 
    ADC #$0040
    STA $00               ; Store new row start position to DP $00
    TAX                   ; Transfer to X for buffer writes
    LDA [$3E]             ; Read left border tile from [$3E]
    STA $7F0200, X        ; Write left border to VRAM buffer
    INX                   ; Advance past left border
    INX 
    LDA $18               ; Load box width (doubled) for interior fill count
    STA $EC               ; Copy to temporary counter $EC
    LDA #$2040            ; Blank interior tile = $2040 (empty with priority)

  loc_03E521:
    STA $7F0200, X        ; Write blank tile to buffer (inner fill loop)
    INX                   ; Advance position
    INX 
    DEC $EC               ; Decrement fill counter
    BNE loc_03E521        ; More columns → repeat fill
    LDA [$3E], Y          ; Read right border tile from [$3E], Y (offset Y=2)
    STA $7F0200, X        ; Write right border to buffer
    DEC $1C               ; Decrement row counter $1C
    BNE loc_03E509        ; More rows → loop back to loc_03E509
    LDA $00               ; All body rows done — check if prompt row is needed
    CLC                   ; CLC for row advance
    ADC #$0040            ; Advance to next VRAM row
    STA $00               ; Store position
    TAX                   ; Transfer to X
    LDA $00EE             ; Load $00EE — prompt row suppression flag
    BNE loc_03E56F        ; Nonzero → skip prompt row entirely
    LDA $worldReadyFlag   ; Load worldReadyFlag ($0654)
    AND #$00FF            ; Mask to byte
    BEQ loc_03E56F        ; Not ready → skip prompt row
    LDA [$3E]             ; Read left border tile for prompt row
    STA $7F0200, X        ; Write left border
    INX                   ; Advance position
    INX 
    LDA #$2040            ; Blank fill tile for prompt row

  loc_03E556:
    STA $7F0200, X        ; Write blank tile (prompt row fill loop)
    INX                   ; Advance position
    INX 
    DEC $18               ; Decrement width counter
    BNE loc_03E556        ; More columns → repeat
    LDA [$3E], Y          ; Read right border tile for prompt row
    STA $7F0200, X        ; Write right border
    LDA $00               ; Load current position
    CLC                   ; CLC
    ADC #$0040            ; Advance past prompt row to position pointer for next operations
    STA $00               ; Store updated position
    TAX                   ; Transfer to X

  loc_03E56F:
    LDA $3E               ; Advance border tile pointer past all 4 tile entries (+4 words = 8 bytes)
    CLC 
    ADC #$0004
    STA $3E               ; Store updated pointer
    PLY                   ; Restore Y
    RTS                   ; Return
}

---------------------------------------------
; Clear the entire dialogue box and reset rendering state.
; 
; Resets the VRAM cursor to the box origin ($099A). Zeroes all tiles within the box boundaries (width+1 × height+1 doubled). Restores the default dialogue palette: writes $675D (white), $10F2 (shadow), $0000 (transparent) to CGRAM palette offset $22. Triggers display update, resets cursor and line counter ($099C).

WideCmd_ClearDialogueBox {
    PHY                   ; Save string pointer Y
    PHB                   ; Save data bank (will be modified by palette writes)
    LDA $099A             ; Reset VRAM cursor to box content origin ($099A)
    STA $0998             ; Store to $0998 — cursor now at top-left of content area
    LDA $0982             ; Load box width from $0982
    ASL                   ; ASL: double for tile count
    INC                   ; INC: add 1 for border column (clear width+1 tiles per row)
    STA $00               ; Store to DP $00 (row width counter reset value)
    STA $18               ; Also store to DP $18 (active counter)
    LDA $0984             ; Load box height from $0984
    INC                   ; INC: add 1 for border row
    ASL                   ; ASL: double for tile rows (clear height+1 doubled rows)
    STA $1C               ; Store to DP $1C (row counter)
    LDA $099A             ; Load box origin $099A
    SEC                   ; SEC
    SBC #$0042            ; Subtract $0042 to start clearing from top-left border position
    STA $099A             ; Store adjusted origin back to $099A
    TAX                   ; Transfer to X for buffer writes

  loc_03E59C:
    LDA #$0000            ; Load $0000 — zero value for clearing

  loc_03E59F:
    STA $7F0200, X        ; Write zero to clear tile (inner loop)
    INX                   ; Advance position by 2
    INX 
    DEC $18               ; Decrement column counter
    BPL loc_03E59F        ; More columns → repeat
    LDA $00               ; Reset column counter from DP $00
    STA $18
    LDA $099A             ; Load current origin $099A
    CLC                   ; CLC
    ADC #$0040            ; Advance by one VRAM row ($40)
    STA $099A             ; Store new row start to $099A
    TAX                   ; Transfer to X
    DEC $1C               ; Decrement row counter $1C
    BPL loc_03E59C        ; More rows → repeat outer loop
    PHX                   ; Save X (current position) for palette write
    LDX #$0022            ; Load palette index $22 (dialogue text palette slot #17)
    LDA #$675D            ; Write default white color $675D to CGRAM buffer at offset $22
    STA $cgramPalette, X  ; Store to cgramPalette+$22 ($7F0A22)
    LDA #$10F2            ; Write shadow color $10F2 to CGRAM+$24
    STA $7F0A02, X        ; Store to $7F0A24
    LDA #$0000            ; Write transparent $0000 to CGRAM+$26
    STA $7F0A04, X        ; Store to $7F0A26
    PLX                   ; Restore X position
    LDA #$0001            ; Set display-dirty flag
    TSB $displayModeFlags ; TSB displayModeFlags
    JSR $&WaitOneFrame    ; JSR WaitOneFrame — let the clear render to screen
    LDX $0998             ; Load VRAM cursor from $0998
    STX $099A             ; Store to $099A — update box content origin to current cursor
    STZ $099C             ; Zero line counter $099C
    PLB                   ; Restore data bank
    PLY                   ; Restore string pointer Y
    RTS                   ; Return
}

WideCmd_WaitFrames {
    PHY                   ; Save string pointer Y
    LDA $0000, Y          ; Read 1-byte frame count operand
    AND #$00FF            ; Mask to byte
    JSR $&WaitNFrames_Entry ; JSR WaitNFrames_Entry — pause for N frames
    PLY                   ; Restore Y
    INY                   ; Skip past 1 operand byte
    RTS                   ; Return
}

---------------------------------------------
; Advance to the next line within the dialogue box.
; 
; Increments the line counter ($099C). If it equals the box height ($0984), scrolls the dialogue up twice (with WaitOneFrame between each scroll) to make room. Computes the new VRAM cursor position: base ($099A) + line × 32 tiles. Updates both X and $0998.

WideCmd_NewLine {
    LDA $099C             ; Load current line counter from $099C
    INC                   ; Increment to next line
    CMP $0984             ; Compare to box height ($0984)
    BNE loc_03E610        ; Not at bottom → skip scroll at loc_03E610
    JSR $&ScrollDialogueUp ; At bottom: JSR ScrollDialogueUp — shift text up one line
    JSR $&WaitOneFrame    ; JSR WaitOneFrame — visual pause between scroll steps
    JSR $&ScrollDialogueUp ; JSR ScrollDialogueUp — second scroll for smooth 2-step animation
    JSR $&WaitOneFrame    ; JSR WaitOneFrame — second visual pause
    LDA $099C             ; Reload line counter (still at max — stays on bottom line)

  loc_03E610:
    STA $099C             ; Store (possibly unchanged) line counter to $099C
    XBA                   ; XBA: move line to high byte for VRAM row calc
    LSR                   ; LSR: line × 128 (half of 256) for double-height tile rows
    CLC 
    ADC $099A             ; CLC
    STA $0998             ; Add box content origin $099A — compute absolute cursor position
    TAX                   ; Store to $0998
    RTS                   ; Return
}

WideCmd_AdvanceCursor {
    PHY                   ; Save string pointer Y
    LDA $0000, Y          ; Read 1-byte advance count operand
    AND #$00FF            ; Mask to byte
    LSR                   ; LSR: halve for tile count (operand is in pixel units)
    BEQ loc_03E633        ; Zero advance → skip directly to exit
    ASL                   ; Restore to double (ASL undoes LSR) — advance in 2-byte tile units
    PHA                   ; Save advance amount on stack
    TXA                   ; Transfer current cursor X to A
    CLC                   ; CLC for addition
    ADC $01, S            ; Add advance amount from stack
    TAX                   ; Transfer result back to X (new cursor position)
    STA $0998             ; Store to $0998
    PLA                   ; Clean up stack

  loc_03E633:
    PLY                   ; Restore string pointer Y
    INY                   ; Skip past 1 operand byte
    RTS                   ; Return
}

WideCmd_InsertRemoteString {
    PHY                   ; Save string pointer Y
    PHB                   ; Save data bank — will switch to remote string's bank
    LDA $0000, Y          ; Read 2-byte address operand from bytes 0-1
    PHA                   ; Push address to stack (will become Y for recursive call)
    SEP #$20              ; Switch to 8-bit to read bank byte
    LDA $0002, Y          ; Read bank byte from operand byte 2
    PHA                   ; Pull into DBR — absolute addresses now read from remote bank
    PLB                   ; Back to 16-bit A
    REP #$20
    PLY                   ; Save VRAM cursor to $0998
    STX $0998
    JSL $@WideStringRenderer
    LDX $0998
    PLB                   ; Restore original string pointer Y
    PLY                   ; Skip past 3 consumed operand bytes
    INY 
    INY 
    INY                   ; Return
    RTS 
}

---------------------------------------------
; Clear the box interior without removing borders.
; 
; Fills the interior region with blank tiles ($2040) in both tile rows ($7F0200 and $7F0240). Uses dimensions ($0982−1 × $0984−1) with doubled row stride ($0080 per row = 64 tiles × 2 bytes for both top and bottom tile halves). Resets cursor to box origin and line counter to 0.

WideCmd_ClearBox {
    LDA $0998             ; Load current VRAM cursor (unused — immediately overwritten)
    LDA $0982             ; Load box width from $0982
    ASL                   ; ASL: double for tile count
    DEC                   ; DEC: subtract 1 (clear width×2−1 tiles per row, excluding borders)
    STA $00               ; Store to DP $00 (row width reset value)
    STA $18               ; Copy to active counter DP $18
    LDA $0984             ; Load box height from $0984
    DEC                   ; DEC: subtract 1 (clear only interior rows)
    STA $1C               ; Store to DP $1C (row counter)
    LDA $099A             ; Load box content origin $099A
    STA $02               ; Store to DP $02 (running row pointer)
    TAX                   ; Transfer to X for buffer writes

  loc_03E66E:
    LDA #$2040            ; Blank tile with priority = $2040

  loc_03E671:
    STA $7F0200, X        ; Write blank to top tile row (inner clear loop)
    STA $7F0240, X        ; Also write blank to bottom tile row ($7F0240)
    INX                   ; Advance position by 2
    INX 
    DEC $18               ; Decrement column counter
    BPL loc_03E671        ; More columns → repeat
    LDA $00               ; Reset column counter from DP $00
    STA $18
    LDA $02               ; Load current row pointer from DP $02
    CLC                   ; CLC
    ADC #$0080            ; Advance by $0080 (two VRAM rows = 128 bytes, for double-height tiles)
    STA $02               ; Store new row pointer
    TAX                   ; Transfer to X
    DEC $1C               ; Decrement row counter
    BPL loc_03E66E        ; More rows → repeat outer loop
    LDA $099A             ; Load box origin $099A — reset cursor to top-left
    STA $0998             ; Store to $0998
    TAX                   ; Transfer to X
    STZ $099C             ; Zero line counter $099C
    LDA #$0001            ; Set display-dirty flag
    TSB $displayModeFlags ; TSB displayModeFlags
    JSR $&WaitOneFrame    ; JSR WaitOneFrame — let the clear render
    RTS                   ; Return
}

---------------------------------------------
; Wait for the player to press A, B, or Start with a blinking cursor indicator.
; 
; Sets $C080 in joypadHeld to suppress auto-repeat. Loops calling WaitOneFrame until $C080 is detected in joypadCurrent. During the wait, draws a blinking cursor via DrawDialogueCursor (carry set = animate). On button press, clears the cursor (carry clear) and calls WideCmd_ClearBox to prepare for the next page.

WideCmd_WaitForButton {
    LDA #$C080            ; Set $C080 in joypadHeld — suppress A/B/Start auto-repeat
    TSB $joypadHeld       ; TSB $0658

  loc_03E6AA:
    JSR $&WaitOneFrame    ; JSR WaitOneFrame — wait for next VBlank
    LDA $joypadCurrent    ; Load current joypad state from $0656
    AND #$C080            ; Test for A ($0080), B ($8000), or Start ($0040 unused here — C080 mask)
    BNE loc_03E6C1        ; Button pressed → proceed to dismiss at loc_03E6C1
    SEC                   ; SEC: carry set tells DrawDialogueCursor to animate (blink mode)
    JSR $&DrawDialogueCursor ; JSR DrawDialogueCursor — draw blinking cursor indicator
    LDA #$0001            ; Set display-dirty flag for cursor update
    TSB $displayModeFlags ; TSB displayModeFlags
    BRA loc_03E6AA        ; Loop back to wait for button

  loc_03E6C1:
    STA $joypadHeld       ; Store pressed button to joypadHeld to acknowledge input
    CLC                   ; CLC: carry clear tells DrawDialogueCursor to erase cursor
    JSR $&DrawDialogueCursor ; JSR DrawDialogueCursor — erase the cursor
    LDA #$0001            ; Set display-dirty flag
    TSB $displayModeFlags ; TSB displayModeFlags
    JSR $&WideCmd_ClearBox ; JSR WideCmd_ClearBox — clear box interior for next page
    RTS                   ; Return
}

---------------------------------------------
; Wait for any button press.
; 
; Sets $CFF0 in joypadHeld to suppress all auto-repeat. Loops calling WaitOneFrame until any button in $CFFF is pressed. Stores the pressed button to joypadHeld and returns.

WideCmd_WaitForAnyInput {
    LDA #$CFF0            ; Set $CFF0 in joypadHeld — suppress all button auto-repeat
    TSB $joypadHeld       ; TSB $0658

  loc_03E6D8:
    JSR $&WaitOneFrame    ; JSR WaitOneFrame — wait for VBlank
    LDA $joypadCurrent    ; Load joypad state from $0656
    AND #$CFFF            ; Mask to $CFFF — check all standard buttons
    BEQ loc_03E6D8        ; No buttons pressed → keep waiting
    STA $joypadHeld       ; Store pressed button(s) to joypadHeld to acknowledge
    RTS                   ; Return
}

WideCmd_JumpToAddress {
    LDA $0000, Y          ; Read 2-byte operand = new string address
    TAY                   ; Transfer to Y — string pointer jumps to new location
    RTS                   ; Return to character loop (Y now points at new string data)
}

WideCmd_SetSfx {
    LDA $0000, Y          ; Read 1-byte operand = SFX ID
    INY                   ; Advance string pointer past operand
    AND #$00FF            ; Mask to byte
    STA $0996             ; Store to $0996 — per-character sound effect for typing
    RTS                   ; Return
}

---------------------------------------------
; Open the standard dialogue box used for most NPC conversations.
; 
; Hardcoded dimensions: 13 columns × 4 rows, positioned at column 3, row 17 (bottom of screen). Computes the VRAM buffer offset and jumps to OpenDialogueBox_Body to share the box construction logic with WideCmd_OpenDialogueBox.

WideCmd_OpenDefaultBox {
    LDA #$000D            ; Set default width = 13 columns
    STA $0982             ; Store to $0982
    LDA #$0004            ; Set default height = 4 rows
    STA $0984             ; Store to $0984
    LDA #$0003            ; Set default column = 3
    STA $097A             ; Store to $097A
    LDA #$0011            ; Set default row = 17 (0x11)
    STA $097C             ; Store to $097C
    XBA                   ; XBA: row to high byte for offset calc
    LSR                   ; Begin row × 32 computation
    LSR 
    CLC 
    ADC $097A             ; Add column (first time)
    CLC 
    ADC $097A             ; Add column (second time) — offset = row×32 + col×2
    TAX                   ; Transfer to X (VRAM cursor)
    STA $0998             ; Store to $0998
    JMP $&OpenDialogueBox_Body ; JMP to OpenDialogueBox_Body — share construction logic
}

---------------------------------------------
; Write a single 15-bit color value directly to the CGRAM palette buffer.
; 
; Reads 3-byte operand: byte 0 = palette index (×2 for word offset), bytes 1-2 = 15-bit BGR color value. Writes to $7F0A00 + index×2. Used for dialogue-specific color effects.

WideCmd_SetPaletteColor {
    PHX                   ; Save VRAM cursor X — palette write will use X for index
    LDA $0000, Y          ; Read 1st operand byte = palette index
    AND #$00FF            ; Mask to byte
    ASL                   ; ASL: ×2 for word offset into CGRAM palette buffer
    TAX                   ; Transfer palette offset to X
    LDA $0001, Y          ; Read 15-bit color value from operand bytes 1-2
    STA $cgramPalette, X  ; Write color to CGRAM palette buffer at $7F0A00,X
    INY                   ; Advance string pointer past 3 operand bytes
    INY 
    INY 
    PLX                   ; Restore VRAM cursor X
    RTS                   ; Return
}

---------------------------------------------
; Set the per-character typing delay.
; 
; Reads a 1-byte operand, adds 2 (INC INC), masks to byte, and stores to $007E. The +2 bias means operand 0 = 2-frame delay, operand 1 = 3-frame delay, etc. A value of 0 in $007E (from the BEQ check in WaitNFrames_PerChar) causes instant rendering.

WideCmd_SetFrameDelay {
    LDA $0000, Y          ; Read 1-byte operand = frame delay value
    INY                   ; Advance string pointer past operand
    INC                   ; INC: add 1 (bias adjustment)
    INC                   ; INC: add 1 more (total +2 bias)
    AND #$00FF            ; Mask to byte
    STA $007E             ; Store adjusted delay to $007E — controls typing speed
    RTS                   ; Return
}

---------------------------------------------
; Insert a word from dictionary A (dictionary_01EBA8).
; 
; Reads a 1-byte index, doubles it for the word pointer table, switches DBR to the dictionary bank, reads the string pointer, and recursively renders via JSL WideStringRenderer. Used for common words to save space in dialogue scripts.

WideCmd_DictionaryA {
    PHP                   ; Save processor flags (mode bits)
    PHB                   ; Save data bank — will switch to dictionary bank
    PHY                   ; Save string pointer Y
    LDA $0000, Y          ; Read 1-byte dictionary entry index
    AND #$00FF            ; Mask to byte
    ASL                   ; Double for word-sized pointer table
    TAY                   ; Transfer index to Y
    SEP #$20              ; 8-bit A for bank byte push
    LDA #$^dictionary_01EBA8 ; Load dictionary_01EBA8 bank byte
    PHA                   ; Push bank byte
    PLB                   ; Set DBR to dictionary bank
    REP #$20              ; 16-bit A for pointer read
    LDA $&dictionary_01EBA8, Y ; Read word string pointer from dictionary table
    TAY                   ; Transfer to Y for recursive rendering
    STX $0998             ; Save VRAM cursor to $0998
    JSL $@WideStringRenderer ; JSL WideStringRenderer — render the dictionary word
    LDX $0998             ; Restore VRAM cursor
    PLY                   ; Restore original string pointer Y
    INY                   ; Skip past 1 operand byte
    PLB                   ; Restore data bank
    PLP                   ; Restore processor flags
    RTS                   ; Return
}

---------------------------------------------
; Insert a word from dictionary B (dictionary_01F54D).
; 
; Identical to DictionaryA but reads from the second dictionary table. Two dictionaries allow more than 256 common words while keeping operands to 1 byte each.

WideCmd_DictionaryB {
    PHP                   ; Save processor flags
    PHB                   ; Save data bank
    PHY                   ; Save string pointer Y
    LDA $0000, Y          ; Read 1-byte dictionary B entry index
    AND #$00FF            ; Mask to byte
    ASL                   ; Double for word-sized pointer table
    TAY                   ; Transfer to Y
    SEP #$20              ; 8-bit A for bank byte
    LDA #$^dictionary_01F54D ; Load dictionary_01F54D bank byte
    PHA                   ; Push bank byte
    PLB                   ; Set DBR to dictionary B bank
    REP #$20              ; 16-bit A for pointer read
    LDA $&dictionary_01F54D, Y ; Read word string pointer from dictionary B table
    TAY                   ; Transfer to Y
    STX $0998             ; Save VRAM cursor
    JSL $@WideStringRenderer ; JSL WideStringRenderer — render dictionary B word
    LDX $0998             ; Restore VRAM cursor
    PLY                   ; Restore Y
    INY                   ; Skip past 1 operand byte
    PLB                   ; Restore data bank
    PLP                   ; Restore processor flags
    RTS                   ; Return
}

---------------------------------------------
; Output raw tile bytes directly until a zero terminator.
; 
; Reads bytes from the string stream one at a time. Each nonzero byte is OR'd with palette and priority bits and written to both VRAM buffer rows. Zero byte terminates. Used for rendering pre-composed tile sequences (icons, special characters).

WideCmd_PrintRawTiles {
    LDA $0000, Y          ; Read next tile byte from string data
    INY                   ; Advance string pointer
    AND #$00FF            ; Mask to byte
    BEQ loc_03E7AE        ; Zero byte = terminator → exit loop
    ORA $0986             ; OR with palette bits
    ORA #$2100            ; OR with priority $2100
    STA $7F0200, X        ; Write to top tile row in VRAM buffer
    CLC                   ; CLC for bottom row offset
    ADC #$0010            ; Add $0010 for bottom tile
    STA $7F0240, X        ; Write bottom tile row
    INX                   ; Advance cursor by 2
    INX 
    BRA WideCmd_PrintRawTiles ; Loop back to read next tile

  loc_03E7AE:
    STX $0998             ; Save final cursor position to $0998
    RTS                   ; Return
}

---------------------------------------------
; Wait exactly one frame by loading A = 1 and falling through to WaitNFrames_Entry.

WaitOneFrame {
    LDA #$0001            ; Load frame count = 1 (falls through to WaitNFrames_Entry)
}

---------------------------------------------
; Wait for A frames. Saves processor state (PHP), switches to 8-bit A (SEP #$20), and branches to the wait loop body. If worldReadyFlag is zero, returns immediately without waiting (game not yet in rendering state).

WaitNFrames_Entry {
    PHP                   ; Save processor flags — restored after wait loop
    SEP #$20              ; Switch to 8-bit A for frame counter decrement loop
    BRA loc_03E7C2        ; Branch to wait loop body at loc_03E7C2
}

---------------------------------------------
; Wait for the per-character frame delay stored in $007E.
; 
; Saves processor state, switches to 8-bit. If $007E = 0, returns immediately (instant text mode). Otherwise falls into the wait loop. Each iteration calls UpdateFrameDialogue to process a lightweight frame update (audio, display sync) without advancing game logic.

WaitNFrames_PerChar {
    PHP                   ; Save processor flags
    SEP #$20              ; Switch to 8-bit A
    LDA $007E             ; Load per-character frame delay from $007E
    BEQ loc_03E7D4        ; Delay = 0 → instant text, skip wait entirely

  loc_03E7C2:
    PHA                   ; Push frame count to stack for loop
    LDA $worldReadyFlag   ; Check worldReadyFlag ($0654) — is the game rendering?
    BNE loc_03E7CC        ; Rendering active → proceed to frame wait at loc_03E7CC
    PLA                   ; Not rendering: discard frame count from stack
    PLP                   ; Restore processor flags
    RTS                   ; Return immediately — no frame sync during loading
}

WaitNFrames_Loop {
    PHA                   ; Push frame count for loop iteration

  loc_03E7CC:
    JSL $@system_core.UpdateFrameDialogue ; JSL UpdateFrameDialogue — process one lightweight frame update
    PLA                   ; Restore frame count
    DEC                   ; Decrement (8-bit) — one frame consumed
    BNE WaitNFrames_Loop  ; More frames remaining → loop back to WaitNFrames_Loop

  loc_03E7D4:
    PLP                   ; Restore processor flags
    RTS                   ; Return — all frames waited
}

---------------------------------------------
; Scroll all dialogue box content up by one line.
; 
; Copies each row from $7F0240 (bottom tile row) to $7F0200 (top tile row) across the full box width. Repeats for (height × 2 − 1) rows. Triggers display update when complete. Called twice (with WaitOneFrame between) by WideCmd_NewLine for smooth visual scrolling.

ScrollDialogueUp {
    LDA $099A             ; Load box content origin from $099A
    STA $00               ; Store to DP $00 (working row pointer)
    TAX                   ; Transfer to X for buffer reads/writes
    LDA $0984             ; Load box height from $0984
    ASL                   ; ASL: double for tile rows
    DEC                   ; DEC: subtract 1 (scroll N−1 rows, last row stays blank)
    STA $1C               ; Store to DP $1C (row counter)

  loc_03E7E3:
    LDA $0982             ; Load box width from $0982 (outer loop start)
    ASL                   ; ASL: double for tile count
    DEC                   ; DEC: subtract 1 for inner loop counter
    STA $18               ; Store to DP $18 (column counter)

  loc_03E7EA:
    LDA $7F0240, X        ; Copy tile from bottom row ($7F0240) to top row ($7F0200) — scroll up
    STA $7F0200, X        ; Write to current position in top row buffer
    INX                   ; Advance position by 2
    INX 
    DEC $18               ; Decrement column counter
    BPL loc_03E7EA        ; More columns → repeat
    LDA $00               ; Reload row pointer from DP $00
    CLC                   ; CLC
    ADC #$0040            ; Advance by one VRAM row ($40)
    STA $00               ; Store updated row pointer
    TAX                   ; Transfer to X
    DEC $1C               ; Decrement row counter
    BPL loc_03E7E3        ; More rows → loop back to outer loop start
    LDA #$0001            ; Set display-dirty flag
    TSB $displayModeFlags ; TSB displayModeFlags — trigger VRAM update
    RTS                   ; Return
}

---------------------------------------------
; Draw or erase the blinking continuation cursor at the bottom-right of the dialogue box.
; 
; Carry flag controls mode: SEC = animate (blink), CLC = erase. In animate mode, uses a frame counter ($0994) with a 16-frame period: odd frames show the cursor tile ($2091), even frames show blank ($2040). Computes the cursor position from box dimensions and origin.
; 
; The position formula: X = ((height×2 + row_origin) × 32 + width + column_origin) × 2, indexing into $7F0200.

DrawDialogueCursor {
    PHP                   ; Save processor flags (carry flag determines draw/erase mode)
    LDA $0984             ; Load box height from $0984
    ASL                   ; ASL: double for tile rows
    CLC                   ; CLC
    ADC $0980             ; Add row origin $0980 — cursor Y position (box bottom + origin)
    ASL                   ; ASL ×5: multiply by 32 to convert row to VRAM row offset
    ASL 
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $0982             ; Add box width $0982 — cursor is at right edge of box
    CLC 
    ADC $097E             ; Add column origin $097E
    ASL                   ; ASL: ×2 for byte offset (each tile = 2 bytes)
    TAX                   ; Transfer computed VRAM offset to X
    PLP                   ; Restore carry flag from PHP (SEC=animate, CLC=erase)
    BCC loc_03E83F        ; Carry clear → erase cursor at loc_03E83F
    LDA $36               ; Animate mode: load frame counter $36 (global frame tick)
    BIT #$000F            ; Test low 4 bits — only toggle on frame boundary (every 16 frames)
    BNE loc_03E831        ; Not on boundary → keep current state
    INC $0994             ; Increment cursor blink counter $0994

  loc_03E831:
    LDA $0994             ; Load updated blink counter
    BIT #$0001            ; Test bit 0 — odd/even for blink phase
    BEQ loc_03E83F        ; Even → erase cursor (blank tile) at loc_03E83F
    LDA #$2091            ; Odd → show cursor arrow tile $2091
    PHA                   ; Push cursor tile to stack
    BRA loc_03E843        ; Branch to write path

  loc_03E83F:
    LDA #$2040            ; Erase/even phase: blank tile $2040
    PHA                   ; Push tile to stack

  loc_03E843:
    PLA                   ; Pull tile from stack
    STA $7F0200, X        ; Write cursor tile to VRAM buffer at computed position
    RTS                   ; Return
}

---------------------------------------------
; General-purpose menu selection handler for dialogue choices.
; 
; Entry: JSL. Stack parameter at SP+3 encodes the menu grid: high nibble = total item count (rows × columns), low nibble = items per row (column count). SP+1 = initial selection index. SP+5 = starting row offset.
; 
; Saves DP and sets it to 0. Initializes cursor blink counter ($0994) to 0.
; 
; The main loop (MenuSelection_PollLoop) draws the cursor, waits one frame, and checks joypad input:
; - Up ($0800): Decrement index with row-aware wrapping
; - Down ($0400): Increment index with row-aware wrapping
; - L/R ($0300): Add/subtract column count for page navigation
; - A/Start ($8080): Confirm — play sound #11, restore tiles under cursor, increment selection by 1, return carry set
; - B ($4000): Cancel — call ReadMenuSelection to restore tiles, return A = 0, carry set
; 
; All navigation plays sound #10 and resets cursor blink. Returns: A = 1-based selection index (0 = cancelled), carry set.

MenuSelectionHandler {
    PHD                   ; Save caller's direct page
    PHX                   ; Save caller's X register
    PHA                   ; Push parameter A (will become SP+3 packed grid descriptor)
    LDA #$0000            ; Set A = 0 for TCD
    TCD                   ; DP = 0 for scratch access
    PHA                   ; Push initial selection index (0) to SP+1
    STA $0994             ; Zero cursor blink counter $0994

  MenuSelection_PollLoop:
    JSR $&DrawMenuCursor  ; JSR DrawMenuCursor — draw cursor at current selection
    JSR $&WaitOneFrame    ; JSR WaitOneFrame — sync to VBlank
    LDA $joypadCurrent    ; Load joypad state from $0656
    BIT #$CF80            ; Test for any navigation or action button ($CF80 mask)
    BEQ MenuSelection_PollLoop ; No input → loop back to poll
    PHA                   ; Save joypad state for individual button tests
    LDA #$CFF0            ; Set $CFF0 in joypadHeld — suppress auto-repeat for all buttons
    TSB $joypadHeld       ; TSB $0658
    PLA                   ; Restore joypad state
    BIT #$0800            ; Test Up ($0800)
    BNE loc_03E8C6        ; Up pressed → handle cursor up at loc_03E8C6
    BIT #$0400            ; Test Down ($0400)
    BEQ loc_03E877        ; Down not pressed → check L/R at loc_03E877
    JMP $&MenuSelection_Down ; Down pressed → JMP MenuSelection_Down

  loc_03E877:
    BIT #$0300            ; Test L+R ($0300)
    BEQ loc_03E87F        ; Neither → check A/B at loc_03E87F
    JMP $&MenuSelection_LeftRight ; L or R pressed → JMP MenuSelection_LeftRight

  loc_03E87F:
    BIT #$8080            ; Test A ($0080) or Start ($8000)
    BNE loc_03E892        ; A/Start pressed → confirm selection at loc_03E892
    BIT #$4000            ; Test B ($4000)
    BEQ MenuSelection_PollLoop ; B not pressed → no recognized input, return to poll loop
    JSR $&ReadMenuSelection ; B pressed: JSR ReadMenuSelection — restore tiles, get position
    PLA                   ; Discard saved joypad from stack
    LDA #$0000            ; Set result = 0 (cancel)
    BRA loc_03E8B3        ; Branch to exit path at loc_03E8B3

  loc_03E892:
    LDA $000A             ; Save DP $0A work area (will be modified by confirm logic)
    PHA                   ; Push to stack for later restore
    LDA $000C             ; Save DP $0C work area
    PHA                   ; Push to stack
    SEP #$20              ; 8-bit A for SFX byte write
    LDA #$11              ; Load confirm sound effect = $11
    STA $sfxQueueCh2      ; Write to sfxQueueCh2 ($06F9) — play confirm chime
    REP #$20              ; Back to 16-bit A
    PLA                   ; Restore $0C from stack
    STA $000C
    PLA                   ; Restore $0A from stack
    STA $000A
    STZ $0994             ; Zero cursor blink counter
    JSR $&DrawMenuCursor  ; JSR DrawMenuCursor — redraw cursor in confirmed state
    PLA                   ; Pop saved joypad state from stack
    INC                   ; INC: convert 0-based index to 1-based result

  loc_03E8B3:
    PHA                   ; Push result for WaitOneFrame (preserves A across call)
    JSR $&WaitOneFrame    ; JSR WaitOneFrame — brief confirmation delay
    PLA                   ; Restore result
    STZ $0994             ; Zero cursor blink counter $0994
    STZ $0990             ; Clear saved tile under cursor $0990
    STZ $0992             ; Clear saved shadow tile $0992
    PLY                   ; Pop unused stack value → Y
    PLX                   ; Restore X
    PLD                   ; Restore direct page
    SEC                   ; SEC: carry set = valid selection made
    RTL                   ; RTL — return with A = selection index (1-based), carry set

  loc_03E8C6:
    SEP #$20              ; Up pressed: 8-bit A for stack byte manipulation
    LDA #$10              ; Navigation sound effect = $10
    STA $sfxQueueCh2      ; Write to sfxQueueCh2 ($06F9)
    REP #$20              ; Back to 16-bit A
    STZ $0994             ; Reset cursor blink counter
    SEP #$20              ; 8-bit A for grid math
    LDA $03, S            ; Load packed grid descriptor from SP+3
    AND #$0F              ; AND #$0F: extract column count (low nibble)
    STA $1C               ; Store column count to DP $1C
    LDA $03, S            ; Reload packed descriptor
    LSR                   ; Shift right 4: extract total item count (high nibble)
    LSR 
    LSR 
    LSR 
    STA $18               ; Store total to DP $18
    LDA $01, S            ; Load current selection index from SP+1
    DEC                   ; Decrement selection (move up)
    BMI loc_03E8EE        ; Negative → wrap around at loc_03E8EE
    STA $01, S            ; Store decremented index
    REP #$20              ; 16-bit A for JMP
    JMP $&MenuSelection_PollLoop ; Return to poll loop

  loc_03E8EE:
    LDA $18               ; Wrap-around: load total item count $18
    BNE loc_03E8F4        ; Nonzero → use total as wrap target
    LDA $1C               ; Total = 0: use column count $1C as last valid index

  loc_03E8F4:
    DEC                   ; Decrement to make 0-based
    STA $01, S            ; Store wrapped index to SP+1
    REP #$20              ; 16-bit A
    JMP $&MenuSelection_PollLoop ; Return to poll loop
}

---------------------------------------------
; Handle Down input in menu selection.
; 
; Extracts grid dimensions from the packed stack parameter (high nibble = total, low nibble = columns). Increments the selection index. If it exceeds the column count (entering the second page), wraps or caps to the total count. Plays navigation sound and returns to the poll loop.

MenuSelection_Down {
    SEP #$20              ; 8-bit A for SFX write
    LDA #$10              ; Navigation sound = $10
    STA $sfxQueueCh2      ; Write to sfxQueueCh2
    REP #$20              ; 16-bit A
    STZ $0994             ; Reset cursor blink
    SEP #$20              ; 8-bit A for grid math
    LDA $03, S            ; Load packed grid descriptor from SP+3
    AND #$0F              ; Extract column count (low nibble)
    STA $1C               ; Store to DP $1C
    LDA $03, S            ; Reload descriptor
    LSR                   ; Extract total (high nibble, shift right 4)
    LSR 
    LSR 
    LSR 
    STA $18               ; Store to DP $18
    LDA $01, S            ; Load current selection from SP+1
    CMP $1C               ; Compare to column count — first page or second?
    BCS loc_03E92E        ; Selection ≥ columns → second page at loc_03E92E
    INC                   ; First page: increment selection
    CMP $1C               ; Compare to column count
    BCS loc_03E925        ; Reached column count → wrap to 0 at loc_03E925
    BRA loc_03E927        ; Still in first page → store and continue

  loc_03E925:
    LDA #$00              ; Wrap to 0 (first item on first page)

  loc_03E927:
    STA $01, S            ; Store new selection to SP+1
    REP #$20              ; 16-bit A
    JMP $&MenuSelection_PollLoop ; Return to poll loop

  loc_03E92E:
    INC                   ; Second page: increment selection
    CMP $18               ; Compare to total item count
    BCC loc_03E935        ; Below total → valid, store at loc_03E935
    LDA $1C               ; At or past total: wrap to column count (first item on second page)

  loc_03E935:
    STA $01, S            ; Store new selection to SP+1
    REP #$20              ; 16-bit A
    JMP $&MenuSelection_PollLoop ; Return to poll loop
}

---------------------------------------------
; Handle L/R input for column-based menu navigation.
; 
; Adds or subtracts the column count to/from the current selection. Clamps to grid bounds. If the result crosses a page boundary, plays the navigation sound; otherwise returns silently to the poll loop.

MenuSelection_LeftRight {
    STZ $0994             ; Reset cursor blink counter
    SEP #$20              ; 8-bit A for grid math
    LDA $03, S            ; Load packed grid descriptor from SP+3
    AND #$0F              ; Extract column count (low nibble)
    STA $1C               ; Store to DP $1C
    LDA $03, S            ; Reload descriptor
    LSR                   ; Extract total (high nibble)
    LSR 
    LSR 
    LSR 
    STA $18               ; Store to DP $18
    LDA $01, S            ; Load current selection from SP+1
    CMP $1C               ; Compare to column count — determine current page
    BCS loc_03E969        ; Selection ≥ columns → currently on second page at loc_03E969
    CLC                   ; First page: CLC for right movement
    ADC $1C               ; Add column count — move to second page
    CMP $18               ; Compare to total
    BCC loc_03E95E        ; Below total → valid position at loc_03E95E
    LDA $01, S            ; Past total: reload current (stay in place)

  loc_03E95E:
    STA $01, S            ; Store selection to SP+1
    CMP $1C               ; Compare to column count
    REP #$20              ; 16-bit A
    BCS loc_03E977        ; If selection ≥ columns → on second page, play sound at loc_03E977
    JMP $&MenuSelection_PollLoop ; Still on first page → return to poll loop without sound

  loc_03E969:
    SEC                   ; Second page: SEC for left movement
    SBC $1C               ; Subtract column count — move to first page
    STA $01, S            ; Store new selection to SP+1
    CMP $1C               ; Compare to column count
    REP #$20              ; 16-bit A
    BCC loc_03E977        ; Below columns → on first page, don't play extra sound
    JMP $&MenuSelection_PollLoop ; Still on second page → return to poll

  loc_03E977:
    SEP #$20              ; L/R page change sound: 8-bit A
    LDA #$10              ; Navigation sound = $10
    STA $sfxQueueCh2      ; Write to sfxQueueCh2
    REP #$20              ; 16-bit A
    JMP $&MenuSelection_PollLoop ; Return to poll loop
}

---------------------------------------------
; Draw the menu selection cursor with a 16-frame blink animation.
; 
; Increments the blink counter ($0994). Bit 4 determines the cursor phase: clear = highlight tiles ($212C/$213C for top/bottom), set = dim tiles ($21AC both). Saves the tiles currently under the cursor to $0990/$0992, then overwrites with cursor tiles.
; 
; Computes the cursor position from: the base row offset (SP+6), the grid selection index (SP+3), the column count (from packed dimensions), and the box origin ($097E/$0980). The X offset ($18) is 0 for the first page or $18 for the second page.

DrawMenuCursor {
    LDA $0994             ; Load cursor blink counter from $0994
    INC                   ; Increment for animation
    STA $0994             ; Store updated counter
    BIT #$0010            ; Test bit 4 ($0010) — 16-frame blink cycle
    BNE loc_03E99B        ; Bit set → dim phase at loc_03E99B
    LDA #$212C            ; Highlight phase: load top cursor tile $212C
    STA $00               ; Store to DP $00 (top tile)
    LDA #$213C            ; Load bottom cursor tile $213C
    STA $02               ; Store to DP $02 (bottom tile)
    BRA loc_03E9A2        ; Branch to common draw path

  loc_03E99B:
    LDA #$21AC            ; Dim phase: load dim tile $21AC
    STA $00               ; Store to DP $00 (same tile for top and bottom in dim phase)
    STA $02               ; Store to DP $02

  loc_03E9A2:
    LDA $0990             ; Check if there's a previous cursor position to restore
    BEQ loc_03E9B8        ; No previous position → skip restore
    LDX $098E             ; Load previous cursor VRAM offset from $098E
    LDA $0990             ; Load saved top tile from $0990
    STA $7F0200, X        ; Restore original top tile to VRAM buffer
    LDA $0992             ; Load saved bottom tile from $0992
    STA $7F0240, X        ; Restore original bottom tile to VRAM buffer

  loc_03E9B8:
    SEP #$20              ; 8-bit A for grid dimension extraction
    LDA $05, S            ; Load packed grid descriptor from SP+5
    AND #$0F              ; Extract column count (low nibble)
    STA $1C               ; Store to DP $1C
    LDA $05, S            ; Reload descriptor
    LSR                   ; Extract total (high nibble, shift right 4)
    LSR 
    LSR 
    LSR 
    STA $18               ; Store to DP $18
    LDA $03, S            ; Load current selection from SP+3
    CMP $1C               ; Compare to column count — first page or second?
    BCC loc_03E9DC        ; First page → simple offset at loc_03E9DC
    SEC                   ; Second page: SEC
    SBC $1C               ; Subtract column count to get page-relative index
    STA $1C               ; Store page-relative index to DP $1C
    STZ $1D               ; Zero $1D (high byte of $1C for 16-bit addition later)
    LDX #$0018            ; Load X = $0018: second page X pixel offset (24 = 12 tiles × 2)
    STX $18               ; Store page X offset to DP $18
    BRA loc_03E9E5        ; Branch to position computation

  loc_03E9DC:
    STA $1C               ; First page: store selection directly to DP $1C
    STZ $1D               ; Zero $1D
    LDX #$0000            ; X = $0000: first page has no X offset
    STX $18               ; Store zero page offset to DP $18

  loc_03E9E5:
    REP #$20              ; 16-bit A for position math
    LDA $06, S            ; Load starting row offset from SP+6
    AND #$00FF            ; Mask to byte
    CLC                   ; CLC
    ADC $1C               ; Add page-relative selection index from DP $1C
    ASL                   ; ASL: ×2 for double-height tiles
    CLC                   ; CLC
    ADC $0980             ; Add row origin $0980
    ASL                   ; ASL ×5: multiply by 32 to convert row to VRAM offset
    ASL 
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $097E             ; Add column origin $097E
    ASL                   ; ASL: ×2 for byte offset
    CLC                   ; CLC
    ADC $18               ; Add page X offset from DP $18
    TAX                   ; Transfer to X — cursor VRAM position
    LDA $7F0200, X        ; Save tile currently at cursor position (top row)
    PHA                   ; Push to stack for later save
    LDA $00               ; Load top cursor tile from DP $00
    STA $7F0200, X        ; Write cursor tile to VRAM buffer (top row)
    LDA $7F0240, X        ; Save tile currently at cursor position (bottom row)
    PHA                   ; Push to stack
    LDA $02               ; Load bottom cursor tile from DP $02
    STA $7F0240, X        ; Write cursor tile to VRAM buffer (bottom row)
    STX $098E             ; Save cursor VRAM offset to $098E (for restore later)
    PLA                   ; Pop saved bottom tile
    STA $0992             ; Store to $0992 (saved shadow tile)
    PLA                   ; Pop saved top tile
    STA $0990             ; Store to $0990 (saved original tile)
    LDA #$0001            ; Set display-dirty flag
    TSB $displayModeFlags ; TSB displayModeFlags
    RTS                   ; Return
}

---------------------------------------------
; Restore tiles under the menu cursor and convert position to OAM data.
; 
; Restores the saved tiles ($0990/$0992) to their original VRAM buffer positions. Converts the tile values to OAM-compatible format: strips palette/priority bits (AND $03FF), shifts left 3 (ASL ×3), and OR's with $6000 for the OAM priority. Writes to $090E/$0910 for sprite overlay use. Clears the saved tile state.

ReadMenuSelection {
    PHY                   ; Save Y (string pointer)
    LDX $098E             ; Load cursor VRAM offset from $098E
    LDA $0990             ; Load saved top tile from $0990
    STA $7F0200, X        ; Restore original tile to VRAM buffer
    AND #$03FF            ; Mask to tile index (strip palette/priority)
    ASL                   ; ASL ×3: shift to OAM tile format
    ASL 
    ASL 
    ORA #$6000            ; OR $6000: set OAM priority bits
    STA $090E             ; Store to $090E (OAM data for selected item top)
    LDA $0992             ; Load saved bottom tile from $0992
    STA $7F0240, X        ; Restore original tile to VRAM buffer
    AND #$03FF            ; Mask to tile index
    ASL                   ; ASL ×3: OAM tile format
    ASL 
    ASL 
    ORA #$6000            ; OR $6000: OAM priority
    STA $0910             ; Store to $0910 (OAM data for selected item bottom)
    STZ $0990             ; Clear saved top tile $0990
    STZ $0992             ; Clear saved bottom tile $0992
    LDA #$0001            ; Set display-dirty flag
    TSB $displayModeFlags ; TSB displayModeFlags
    PLY                   ; Restore Y
    RTS                   ; Return
}