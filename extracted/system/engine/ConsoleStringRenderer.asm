; ASCII string renderer — bytecode-driven HUD/UI text and widget system (256610–257943, Bank 03).
; 
; Implements a complete rendering engine for non-dialogue text output: inventory screens, status displays, HP bars, equipment icons, and bordered UI boxes. Separate from the wide-string dialogue renderer (DialogStringRenderer at 254549) — this system uses a simpler 8-bit character set where bytes >= $12 are literal tile indices written directly to the VRAM staging buffer, and bytes $00–$11 are command opcodes dispatched through an 18-entry command table.
; 
; === RENDERING ARCHITECTURE ===
; 
; Entry point: ConsoleStringRenderer, called via JSL. Y = string data pointer, X = VRAM buffer write position (byte offset into $7F0200). Each character writes a 16-bit VRAM tilemap word: low byte = tile index, high byte = palette/priority from sceneStateHelper ($099F).
; 
; The command dispatch uses JSR ($addr,X) — indirect indexed JSR through ConsoleStringCommandTable. Commands may recursively call ConsoleStringRenderer (InsertRemoteString, IndirectString, InsertItemName) and update X via the stack ($03,S or $05,S depending on stack depth).
; 
; === COMMAND TABLE ($00–$11) ===
; 
; | Cmd | Handler | Operand | Description |
; |-----|---------|---------|-------------|
; | $00 | End | — | Pop registers, RTL to caller |
; | $01 | SetVramAddr | 2B addr | Set VRAM write cursor |
; | $02 | InsertRemoteString | 2B addr + 1B bank | Recursive render from another bank |
; | $03 | SetPalette | 1B bits | Set palette bits 2-4 in attribute byte |
; | $04 | IndirectString | 2B base + 1B bank + 2B idx | Indexed string table lookup + render |
; | $05 | PrintBcdNumber | 1B count + 2B addr | Print packed BCD digits right-to-left |
; | $06 | DrawBox | 1B w + 1B h + 2B pos | Draw bordered rectangle with corners/edges/fill |
; | $07 | ClearColumn | 2B addr | Clear tiles in a column region |
; | $08 | FillTile | 1B count + 2B tile addr | Repeat a tile N times |
; | $09 | PrintEquipIcons | var (term $80+) | Draw 2×2 equipment metatiles |
; | $0A | DrawPlayerHpBar | — | Render player HP as filled/half/empty segments |
; | $0B | DrawEnemyHpBar | — | Render enemy HP bar (same algorithm, different palette) |
; | $0C | PrintRawBytes | var (term $FF) | Output raw tile bytes until terminator |
; | $0D | AdvanceRow4 | — | Advance cursor +$0080 (4 rows) |
; | $0E | Print3DigitNumber | 2B addr | Format and print a 3-digit decimal number |
; | $0F | ClearRect | 1B w + (see notes) | Clear a rectangular area |
; | $10 | InsertItemName | 1B index | Look up and render item name from itemcomp_table |
; | $11 | AdvanceRow2 | — | Advance cursor +$0040 (2 rows) |
; 
; === HP BAR SYSTEM ===
; 
; DrawPlayerHpBar/DrawEnemyHpBar share DrawHpBar for rendering. HP is divided into three segment types:
; - Full segments ($00): playerHp/2, tile $2006 (filled)
; - Half segment ($08): 1 if HP is odd, tile $2007 (half-filled)
; - Empty segments ($02): (maxHP − HP)/2, tile $20FF (empty)
; 
; Both HP values are clamped to max 40 ($28). Bars wrap to a second row via HpBar_AdvanceRow after 10 tiles. Player uses palette $0800, enemy uses $0400.
; 
; === DRAW BOX ===
; 
; Constructs a bordered rectangle using 4 tile types: $10 (corners, with V/H flip bits for each corner), $11 (horizontal edges), $12 (vertical edges), $40 (interior fill). All OR'd with $099E palette. After drawing, cursor is positioned at first interior content cell (+$0082 from box start).
; 
; === EQUIPMENT ICONS ===
; 
; PrintEquipIcons renders variable-length equipment lists as 2×2 metatiles. Items 0-7 use tile base $01E0, items 8+ use $02E0. Each icon writes 4 tiles: upper-left (N), upper-right (N+1), lower-left (N+$10), lower-right (N+$11), using VRAM offsets to the current and previous tilemap rows.
---------------------------------------------

?BANK 03

?INCLUDE 'itemcomp_table_01EB0F'

!sceneStateHelper               099F
!enemyHpDisplay                 09E4
!playerMaxHp                    0ACA
!playerHp                       0ACE

---------------------------------------------

; Main entry point for the ASCII string rendering engine.
; 
; Called via JSL with Y = string data pointer, X = VRAM buffer byte offset into $7F0200. Saves processor state and data bank (restored by AsciiCmd_End). Processes the bytecode stream in a loop:
; - Bytes >= $12: literal tile characters — written to VRAM buffer as a 16-bit tilemap word (low byte = tile index, high byte = palette from sceneStateHelper $099F)
; - Bytes $00–$11: command opcodes — dispatched via indexed indirect JSR through ConsoleStringCommandTable
; 
; The X register (VRAM write position) is preserved across command calls via PHX/PLX in the main loop. Commands update X through the stack ($03,S) to reflect cursor advancement.

ConsoleStringRenderer {
    PHP 
    PHB 

  loc_03EA64:
    SEP #$20
    LDA $0000, Y          ; Read next byte from string data at Y
    INY 
    CMP #$12              ; Bytes < $12 = command opcodes; >= $12 = literal tile characters
    BCS loc_03EA7C
    REP #$20
    PHX 
    AND #$00FF
    ASL 
    TAX 
    JSR ($&ConsoleStringCommandTable, X) ; Dispatch via indexed indirect JSR through ConsoleStringCommandTable
    PLX 
    BRA loc_03EA64

  loc_03EA7C:
    STA $7F0200, X        ; Write tile index to low byte of VRAM tilemap word
    XBA 
    LDA $sceneStateHelper ; Palette/priority attribute from sceneStateHelper ($099F)
    STA $7F0201, X        ; Write attribute to high byte — completes 16-bit VRAM tile word
    INX 
    INX 
    BRA loc_03EA64
}

---------------------------------------------
; 18-entry word table of command handler addresses for the ASCII string renderer.
; 
; Indexed by command byte (0–$11), each entry is a 16-bit JSR target. Commands are dispatched via JSR ($addr,X) indirect indexed through this table. Entries cover text positioning, string insertion, number formatting, HP bars, equipment icons, and UI box drawing.

ConsoleStringCommandTable [
  &AsciiCmd_End   ;00
  &AsciiCmd_SetVramAddr   ;01
  &AsciiCmd_InsertRemoteString   ;02
  &AsciiCmd_SetPalette   ;03
  &AsciiCmd_IndirectString   ;04
  &AsciiCmd_PrintBcdNumber   ;05
  &AsciiCmd_DrawBox   ;06
  &AsciiCmd_ClearColumn   ;07
  &AsciiCmd_FillTile   ;08
  &AsciiCmd_PrintEquipIcons   ;09
  &AsciiCmd_DrawPlayerHpBar   ;0A
  &AsciiCmd_DrawEnemyHpBar   ;0B
  &AsciiCmd_PrintRawBytes   ;0C
  &AsciiCmd_AdvanceRow4   ;0D
  &AsciiCmd_Print3DigitNumber   ;0E
  &AsciiCmd_ClearRect   ;0F
  &AsciiCmd_InsertItemName   ;10
  &AsciiCmd_AdvanceRow2   ;11
]

---------------------------------------------
; Advance the VRAM cursor by 2 tilemap rows.
; 
; Adds $0040 (64 bytes = 32 words = 2 rows × 32 tiles/row) to the cursor position stored in $09A0, then writes the new position to both $09A0 and the stack ($03,S) to update X on return.
; 
; No operand bytes consumed.

AsciiCmd_AdvanceRow2 {
    LDA $09A0
    CLC 
    ADC #$0040            ; +$0040 = advance 2 tilemap rows (32 words × 2 bytes per row)
    STA $09A0
    STA $03, S
    RTS 
}

---------------------------------------------
; Insert an item name string by item index.
; 
; 1-byte operand: item index. Multiplies by 2 (ASL) for word table offset, switches data bank to itemcomp_table_01EB0F's bank, looks up the item name string pointer, and recursively calls ConsoleStringRenderer to render the name. Updates the VRAM cursor through the stack on return.

AsciiCmd_InsertItemName {
    PHY 
    PHB 
    LDA $06, S
    TAX 
    LDA $0000, Y
    AND #$00FF            ; 1-byte item index operand (×2 for word table offset)
    ASL 
    PHA 
    SEP #$20
    LDA #$^itemcomp_table_01EB0F
    PHA 
    PLB 
    REP #$20
    PLY 
    LDA $&itemcomp_table_01EB0F, Y ; Look up item name string from itemcomp_table_01EB0F
    TAY 
    JSL $@ConsoleStringRenderer ; Recursively render item name string via JSL
    TXA 
    STA $06, S
    PLB 
    PLY 
    INY 
    RTS 
}

---------------------------------------------
; Clear a rectangular area of the VRAM staging buffer.
; 
; 2-byte operand: byte 0 = width (tiles), byte 1 = height (rows). Fills the rectangle with blank tiles ($0000) starting at the current VRAM cursor position. The inner loop writes (width + 1) tiles per row (BPL loop from width down to 0), then advances to the next tilemap row (+$0040) and resets the width counter.
; 
; Note: height is loaded as a 16-bit word from the operand stream, incorporating the following byte in the high byte. The BMI exit condition depends on the overall 16-bit value going negative.

AsciiCmd_ClearRect {
    PHY 
    LDA $05, S
    STA $00
    TAX 
    LDA $0000, Y
    AND #$00FF            ; Byte operand: rectangle width (tiles to clear per row)
    STA $0E
    STA $10
    LDA $0001, Y
    STA $12

  loc_03EAF7:
    LDA #$0000

  loc_03EAFA:
    STA $7F0200, X
    INX 
    INX 
    DEC $10
    BPL loc_03EAFA
    DEC $12
    BMI loc_03EB17
    LDA $00
    CLC 
    ADC #$0040            ; +$0040 = advance to next tilemap row
    STA $00
    TAX 
    LDA $0E
    STA $10
    BRA loc_03EAF7

  loc_03EB17:
    PLY 
    INY 
    INY 
    RTS 
}

---------------------------------------------
; Draw the player's HP bar using filled, half, and empty segments.
; 
; No operand. Clamps both playerMaxHp ($0ACA) and playerHp ($0ACE) to a maximum of 40 ($28). Computes three segment counts:
; - $00 = full segments (playerHp / 2)
; - $08 = half-unit flag (1 if playerHp is odd)
; - $02 = empty segments ((maxHP − HP) / 2, with rounding correction)
; 
; Sets palette offset to $0800 (player color) and calls DrawHpBar to render.

AsciiCmd_DrawPlayerHpBar {
    PHY 
    STZ $08
    LDA $playerMaxHp
    CMP #$0029            ; Clamp player HP to max 40 ($28 = 20 full bar segments)
    BMI loc_03EB3A
    LDA #$0028
    STA $playerMaxHp
    LDA $playerHp
    CMP #$0029
    BMI loc_03EB3A
    LDA #$0028
    STA $playerHp

  loc_03EB3A:
    LDA $playerHp
    LSR                   ; Full bar segments = playerHp / 2
    STA $00
    BCC loc_03EB44
    INC $08               ; Odd HP → set half-unit marker flag

  loc_03EB44:
    ASL 
    CLC 
    ADC $08
    SEC 
    SBC $playerMaxHp
    EOR #$FFFF
    INC 
    LSR 
    STA $02               ; Empty segments = (maxHP − HP) / 2
    LDA $08
    CLC 
    ADC $02
    CLC 
    ADC $00
    ASL 
    SEC 
    SBC $playerMaxHp
    BCS loc_03EB64
    INC $02

  loc_03EB64:
    LDA #$0800            ; Player HP palette offset $0800
    STA $0004
    LDA $05, S
    JSR $&DrawHpBar
    PLY 
    RTS 
}

---------------------------------------------
; Shared HP bar rendering routine used by both player and enemy HP commands.
; 
; Takes VRAM position from A, sets Y = 10 (max tiles per row). Draws segments in order:
; 1. Full segments ($00 count): tile $2006 | palette
; 2. Half segment ($08 flag): tile $2007 | palette (skipped if 0)
; 3. Empty segments ($02 count): tile $20FF | palette
; 4. Blank padding: tile $0000 to fill remaining row
; 
; When Y depletes to 0 (10 tiles drawn), calls HpBar_AdvanceRow to move to the next tilemap row and reset Y. Palette in $04 ($0800 = player, $0400 = enemy) is OR'd into each segment tile.

DrawHpBar {
    TAX 
    LDY #$000A            ; Y = 10 tiles per row (max bar display width)
    STZ $06
    LDA $00
    BEQ loc_03EB93
    LDA #$2006            ; Tile $2006 = filled bar segment
    ORA $0004

  loc_03EB81:
    STA $7F0200, X
    INX 
    INX 
    DEY 
    BNE loc_03EB8D
    JSR $&HpBar_AdvanceRow

  loc_03EB8D:
    DEC $00
    BEQ loc_03EB93
    BRA loc_03EB81

  loc_03EB93:
    LDA $08
    BEQ loc_03EBA8
    LDA #$2007            ; Tile $2007 = half-filled bar segment (odd HP remainder)
    ORA $04
    STA $7F0200, X
    INX 
    INX 
    DEY 
    BNE loc_03EBA8
    JSR $&HpBar_AdvanceRow

  loc_03EBA8:
    LDA $02
    BEQ loc_03EBC3
    LDA #$20FF            ; Tile $20FF = empty bar segment
    ORA $04

  loc_03EBB1:
    STA $7F0200, X
    INX 
    INX 
    DEY 
    BNE loc_03EBBD
    JSR $&HpBar_AdvanceRow

  loc_03EBBD:
    DEC $02
    BEQ loc_03EBC3
    BRA loc_03EBB1

  loc_03EBC3:
    LDA $06
    BNE loc_03EBD9
    LDA #$0000            ; Tile $0000 = blank padding (clear remainder of row)

  loc_03EBCA:
    STA $7F0200, X
    INX 
    INX 
    DEY 
    BNE loc_03EBCA
    JSR $&HpBar_AdvanceRow
    LDY #$000A

  loc_03EBD9:
    LDA #$0000

  loc_03EBDC:
    STA $7F0200, X
    INX 
    INX 
    DEY 
    BNE loc_03EBDC
    RTS 
}

---------------------------------------------
; Advance to the next VRAM row during HP bar rendering.
; 
; Adds $002C to X, which combined with the 10 tiles × 2 bytes already drawn ($14) equals one full tilemap row stride ($0040 = 64 bytes). Saves the new position to $06 as a row-continuation flag. Resets Y to 10 for the new row.
; 
; Guard: if the new X exceeds $0100, the bar has exceeded the display area — pops an extra return address (PLA) to exit DrawHpBar early instead of continuing to render.

HpBar_AdvanceRow {
    PHA 
    TXA 
    CLC 
    ADC #$002C            ; +$002C compensates for 10 tiles already drawn ($14) to reach next row ($0040)
    TAX 
    STA $06
    CMP #$0100            ; Bail if VRAM position >= $0100 (bar exceeds display area)
    BCS loc_03EBF9
    PLA 
    LDY #$000A
    RTS 

  loc_03EBF9:
    PLA 
    PLA                   ; Extra PLA pops DrawHpBar return address → force early exit
    RTS 
}

---------------------------------------------
; Draw the enemy's HP bar using the same segment algorithm as player HP.
; 
; No operand. Uses enemyHpDisplay ($09E4) as current HP and $09E6 as max HP. Same clamping (max 40) and segment calculation as AsciiCmd_DrawPlayerHpBar. Sets palette offset to $0400 (enemy color) and calls DrawHpBar.

AsciiCmd_DrawEnemyHpBar {
    PHY 
    STZ $0008
    LDA $enemyHpDisplay
    CMP #$0029
    BMI loc_03EC1C
    LDA #$0028
    STA $enemyHpDisplay
    LDA $09E6
    CMP #$0029
    BMI loc_03EC1C
    LDA #$0028
    STA $09E6

  loc_03EC1C:
    LDA $09E6
    LSR 
    STA $00
    BCC loc_03EC26
    INC $08

  loc_03EC26:
    ASL 
    CLC 
    ADC $08
    SEC 
    SBC $enemyHpDisplay
    EOR #$FFFF
    INC 
    LSR 
    STA $02
    LDA $08
    CLC 
    ADC $02
    CLC 
    ADC $00
    ASL 
    SEC 
    SBC $enemyHpDisplay
    BCS loc_03EC46
    INC $02

  loc_03EC46:
    LDA #$0400            ; Enemy HP palette offset $0400
    STA $04
    LDA $05, S
    JSR $&DrawHpBar
    PLY 
    RTS 
}

---------------------------------------------
; Terminate the ASCII string renderer and return to the caller.
; 
; Pops saved X (VRAM position), data bank, and processor status that were pushed by ConsoleStringRenderer's entry (PHP/PHB), then returns via RTL. This is the only way to cleanly exit the rendering loop.

AsciiCmd_End {
    PLA 
    PLX 
    PLB 
    PLP 
    RTL 
}

---------------------------------------------
; Advance the VRAM cursor by 4 tilemap rows.
; 
; Adds $0080 (128 bytes = 4 rows × 32 words/row × 2 bytes/word) to $09A0 and updates the stack. Double the stride of AdvanceRow2.

AsciiCmd_AdvanceRow4 {
    LDA $09A0
    CLC 
    ADC #$0080            ; +$0080 = advance 4 tilemap rows
    STA $09A0
    STA $03, S
    RTS 
}

---------------------------------------------
; Format and print a decimal number as up to 3 digits.
; 
; 2-byte operand: pointer to a 16-bit source value. Extracts hundreds, tens, and ones digits via repeated subtraction (÷100, ÷10, ÷1). Each digit is OR'd with $099E palette + $30 tile base (ASCII '0').
; 
; Leading zero suppression: hundreds digit is replaced with blank tile $2000 if zero. Tens digit is blank only if hundreds was also zero (tracked via $0006 flag). Ones digit is always displayed.
; 
; Values are capped at 999 (hundreds clamped to 9). Updates VRAM position on the stack after writing 3 tiles.

AsciiCmd_Print3DigitNumber {
    PHY 
    LDA $05, S
    TAX 
    STZ $0006
    STZ $0000
    LDA $099E
    ORA #$0030            ; ORA #$0030 = ASCII '0' tile base for digit rendering
    STA $0004
    LDA $0000, Y          ; 2-byte operand: pointer to 16-bit source value
    TAY 
    LDA $0000, Y
    SEC 

  loc_03EC7F:
    INC $0000             ; Extract hundreds digit via repeated subtraction of 100 ($0064)
    SBC #$0064
    BCS loc_03EC7F
    ADC #$0064
    STA $0002
    LDA $0000
    DEC 
    CMP #$0009
    BCC loc_03EC99
    LDA #$0009

  loc_03EC99:
    BIT #$000F
    BEQ loc_03ECA6
    ORA $0004
    INC $0006
    BRA loc_03ECA9

  loc_03ECA6:
    LDA #$2000            ; Hundreds = 0 → blank tile $2000 (suppress leading zero)

  loc_03ECA9:
    STZ $0000
    LDA $0002
    SEC 

  loc_03ECB0:
    INC $0000             ; Extract tens digit via repeated subtraction of 10 ($000A)
    SBC #$000A
    BCS loc_03ECB0
    ADC #$000A
    STA $0002
    LDA $0000
    DEC 
    BNE loc_03ECD1
    LDA $0006
    BNE loc_03ECCE
    LDA #$2000
    BRA loc_03ECD4

  loc_03ECCE:
    LDA #$0000

  loc_03ECD1:
    ORA $0004

  loc_03ECD4:
    STZ $0000
    STA $7F0200, X
    INX 
    INX 
    LDA $0002
    SEC 

  loc_03ECE1:
    INC $0000
    SBC #$0001
    BCS loc_03ECE1
    LDA $0000
    DEC 
    ORA $0004
    STZ $0000
    STA $7F0200, X
    INX 
    INX 
    TXA 
    STA $05, S
    PLY 
    INY 
    INY 
    RTS 
}

---------------------------------------------
; Set the VRAM buffer write position from a 2-byte operand.
; 
; Reads a 16-bit VRAM address from the string data, stores it in both $09A0 (persistent cursor) and on the stack ($03,S), which becomes X when the command returns. Advances Y past the 2-byte operand.

AsciiCmd_SetVramAddr {
    LDA $0000, Y          ; 2-byte operand: new VRAM buffer write position
    INY 
    INY 
    STA $09A0
    STA $03, S
    RTS 
}

---------------------------------------------
; Recursively render a string from another bank.
; 
; 3-byte operand: 2-byte address + 1-byte bank. Saves the current VRAM position from the stack, pushes the bank byte via PHB/PLB to set the data bank register, then calls ConsoleStringRenderer recursively via JSL with the new string address in Y. After return, restores the original bank and advances Y past the 3-byte operand.

AsciiCmd_InsertRemoteString {
    LDA $03, S
    TAX 
    PHY 
    PHB 
    LDA $0000, Y          ; 3-byte operand: address (2) + bank (1) for remote string
    PHA 
    SEP #$20
    LDA $0002, Y
    PHA 
    PLB 
    REP #$20
    PLY 
    JSL $@ConsoleStringRenderer ; Recursive JSL — render string from remote bank
    PLB 
    PLY 
    INY 
    INY 
    INY 
    TXA 
    STA $03, S
    RTS 
}

---------------------------------------------
; Set the palette attribute for subsequent tile writes.
; 
; 1-byte operand: palette bits. Reads sceneStateHelper ($099F), masks off bits 2-4 (AND $E3), OR's the operand value into those bits, and writes back. This controls the palette field in the high byte of all subsequently rendered tile words.

AsciiCmd_SetPalette {
    SEP #$20
    LDA $sceneStateHelper
    AND #$E3              ; AND $E3 clears palette bits 2-4 in attribute byte
    ORA $0000, Y          ; 1-byte operand: new palette bits OR'd into sceneStateHelper
    INY 
    STA $sceneStateHelper
    REP #$20
    RTS 
}

---------------------------------------------
; Render a string selected by an indirect index lookup.
; 
; 5-byte operand: 2-byte base address + 1-byte bank + 2-byte index pointer. Reads the index value from the index pointer address, multiplies by 2 for word offset, adds to the base address, reads the string pointer from that table entry, switches data bank, and recursively calls ConsoleStringRenderer.
; 
; Used for dynamic string selection — e.g., selecting text based on a game variable that indexes into a string pointer table.

AsciiCmd_IndirectString {
    PHY 
    PHB 
    LDX $0003, Y          ; 5-byte operand: base addr (2) + bank (1) + index addr (2)
    LDA $0000, X
    ASL 
    PHA 
    LDA $0000, Y
    PHA 
    SEP #$20
    LDA $0002, Y
    PHA 
    PLB 
    REP #$20
    PLA 
    CLC 
    ADC $01, S
    TAY 
    PLA 
    LDA $0000, Y
    TAY 
    LDA $06, S
    TAX 
    JSL $@ConsoleStringRenderer ; Recursive JSL — render the looked-up indexed string
    PLB 
    PLA 
    CLC 
    ADC #$0005
    TAY 
    TXA 
    STA $03, S
    RTS 
}

---------------------------------------------
; Print a packed BCD number with leading zero suppression.
; 
; 3-byte operand: 1-byte digit count + 2-byte source address. Digits are extracted from packed BCD bytes (2 digits per byte: low nibble first, then high nibble) and printed right-to-left. Each digit is OR'd with $099E palette and $30 (tile base for '0').
; 
; After printing all digits, a suppression pass replaces leading '0' tiles ($30) with space tiles ($20), stopping at the first non-zero digit. VRAM position is updated on the stack after writing.

AsciiCmd_PrintBcdNumber {
    LDA $03, S
    TAX 
    PHY 
    LDA $0000, Y
    AND #$00FF            ; 3-byte operand: digit count (1) + BCD source address (2)
    STA $000E
    STA $0010
    ASL 
    PHX 
    CLC 
    ADC $01, S
    STA $01, S            ; Compute VRAM end position — BCD digits print right-to-left
    TAX 
    LDA $0001, Y
    TAY 
    LDA $099E
    SEP #$20

  loc_03ED90:
    LDA $0000, Y
    AND #$0F              ; Extract low nibble (least significant BCD digit)
    ORA #$30
    REP #$20
    DEX 
    DEX 
    STA $7F0200, X
    SEP #$20
    DEC $000E
    BEQ loc_03EDC1
    LDA $0000, Y
    INY 
    AND #$F0              ; Extract high nibble (next BCD digit) via >> 4
    LSR 
    LSR 
    LSR 
    LSR 
    ORA #$30
    REP #$20
    DEX 
    DEX 
    STA $7F0200, X
    SEP #$20
    DEC $000E
    BNE loc_03ED90

  loc_03EDC1:
    DEC $0010             ; Leading zero suppression pass
    BEQ loc_03EDD8
    LDA $7F0200, X
    CMP #$30
    BNE loc_03EDD8
    LDA #$20              ; Replace ASCII '0' ($30) with space tile ($20)
    STA $7F0200, X
    INX 
    INX 
    BRA loc_03EDC1

  loc_03EDD8:
    REP #$20
    PLX 
    PLY 
    INY 
    INY 
    INY 
    TXA 
    STA $03, S
    RTS 
}

---------------------------------------------
; Draw a bordered UI rectangle with corners, edges, and interior fill.
; 
; 4-byte operand: 1-byte width + 1-byte height + 2-byte VRAM position. Constructs the box using palette-OR'd tile types:
; - $10: corner tiles (4 variants via V/H flip: $0010 TL, $4010 TR, $8010 BL, $C010 BR)
; - $11: horizontal edges (top $0011, bottom $8011)
; - $12: vertical edges (left $0012, right $4012)
; - $40: interior fill
; 
; Draws top row (corner + edges + corner), then height rows of (border + fill + border), then bottom row. After drawing, positions the cursor at the first interior content cell by adding $0082 to the box start address.

AsciiCmd_DrawBox {
    PHY 
    LDA $0000, Y
    AND #$00FF
    STA $0000
    LDA $0001, Y
    AND #$00FF
    STA $0002
    LDA $0002, Y
    TAX 
    PHA 
    LDA $099E
    ORA #$0010            ; Top-left corner tile ($0010 | palette)
    STA $7F0200, X
    LDA $0000
    STA $000E
    LDA $099E
    ORA #$0011            ; Horizontal border tile ($0011 | palette) — fill top edge

  loc_03EE11:
    STA $7F0202, X
    INX 
    INX 
    DEC $000E
    BNE loc_03EE11
    LDA $099E
    ORA #$4010
    STA $7F0202, X
    LDA $01, S
    CLC 
    ADC #$0040
    TAX 
    LDA $0002
    STA $000E

  loc_03EE33:
    PHX 
    LDA $099E
    ORA #$0012            ; Vertical border tile ($0012 | palette) — left/right edges
    STA $7F0200, X
    LDA $0000
    STA $0010
    LDA $099E
    ORA #$0040            ; Interior fill tile ($0040 | palette)

  loc_03EE4A:
    STA $7F0202, X
    INX 
    INX 
    DEC $0010
    BNE loc_03EE4A
    LDA $099E
    ORA #$4012
    STA $7F0202, X
    PLA 
    CLC 
    ADC #$0040
    TAX 
    DEC $000E
    BNE loc_03EE33
    LDA $099E
    ORA #$8010
    STA $7F0200, X
    LDA $0000
    STA $000E
    LDA $099E
    ORA #$8011

  loc_03EE80:
    STA $7F0202, X
    INX 
    INX 
    DEC $000E
    BNE loc_03EE80
    LDA $099E
    ORA #$C010
    STA $7F0202, X
    PLA 
    PLY 
    CLC 
    ADC #$0082            ; Position cursor after box: start + $0082 for first content cell
    STA $09A0
    STA $03, S
    INY 
    INY 
    INY 
    INY 
    RTS 
}

---------------------------------------------
; Clear a variable-width column region downward through the VRAM buffer.
; 
; 2-byte operand: VRAM start address. First scans rightward from the start position in 8-bit mode, counting non-zero tiles to determine the column width. Then clears that width of tiles in each row, advancing down by $0040 per row, until encountering a row that starts with a zero tile (end of column).
; 
; Used to erase a column of UI content whose width is determined dynamically from the existing tile data.

AsciiCmd_ClearColumn {
    PHY 
    LDA $0000, Y
    TAX 
    STZ $0000
    SEP #$20
    PHX 

  loc_03EEB0:
    LDA $7F0200, X        ; Scan rightward counting non-zero tiles to find column width
    BEQ loc_03EEBD
    INX 
    INX 
    INC $0000
    BRA loc_03EEB0

  loc_03EEBD:
    DEC $0000
    REP #$20
    PLX 

  loc_03EEC3:
    LDA $0000             ; Clear width × N rows, advancing down until hitting a zero row
    STA $000E
    PHX 
    LDA #$0000

  loc_03EECD:
    STA $7F0200, X
    INX 
    INX 
    DEC $000E
    BNE loc_03EECD
    LDA $7F0200, X
    TAY 
    LDA #$0000
    STA $7F0200, X
    PLX 
    TXA 
    CLC 
    ADC #$0040
    TAX 
    LDA $7F0200, X
    BNE loc_03EEC3
    PLY 
    INY 
    INY 
    RTS 
}

---------------------------------------------
; Fill N tile positions with a value loaded from a specified address.
; 
; 3-byte operand: 1-byte count + 2-byte address of tile source. Loads the tile word from the source address, OR's it with $099E palette, and writes it to N consecutive positions in the VRAM buffer. Count is read in 8-bit mode (1-byte). Updates cursor on the stack after writing.

AsciiCmd_FillTile {
    PHY 
    LDA $0001, Y
    TAX                   ; 2-byte address operand → load tile value from that address
    LDA $0000, X
    PHA 
    LDA $07, S
    TAX 
    LDA $099E
    SEP #$20
    LDA $0000, Y          ; 1-byte count operand (read in 8-bit mode)
    REP #$20
    PLY 
    BEQ loc_03EF17

  loc_03EF0E:
    STA $7F0200, X
    INX 
    INX 
    DEY 
    BNE loc_03EF0E

  loc_03EF17:
    PLY 
    INY 
    INY 
    INY 
    TXA 
    STA $03, S
    RTS 
}

---------------------------------------------
; Output raw tile bytes from the string until a $FF terminator.
; 
; Variable-length operand terminated by $FF. Each byte is zero-extended to 16 bits, OR'd with $099E palette, and written as a tile word to the VRAM buffer. The $FF terminator is consumed but not written. Updates cursor on the stack.

AsciiCmd_PrintRawBytes {
    LDA $03, S
    TAX 

  loc_03EF22:
    LDA $0000, Y
    AND #$00FF
    CMP #$00FF            ; $FF byte = end-of-data terminator for raw output
    BEQ loc_03EF39
    ORA $099E             ; Each raw byte OR'd with $099E palette for tile attribute
    STA $7F0200, X
    INX 
    INX 
    INY 
    BRA loc_03EF22

  loc_03EF39:
    INY 
    TXA 
    STA $03, S
    RTS 
}

---------------------------------------------
; Print equipment item icons as 2×2 metatiles.
; 
; Variable-length operand: a list of 1-byte equipment indices terminated by any byte with bit 7 set (>= $80). Each item produces a 2×2 tile icon:
; - Items 0-7: tile base $01E0 (first equipment page)
; - Items 8+: tile base $02E0 (second page, index offset by 8)
; 
; The 4 tiles of each metatile are written using VRAM offsets: upper-left = tile N at row−1, upper-right = N+1, lower-left = N+$10 at current row, lower-right = N+$11. A counter on the stack tracks total icons drawn to compute the final Y advancement past the operand data.

AsciiCmd_PrintEquipIcons {
    LDA $03, S
    TAX 
    LDA #$0000
    PHA 
    PHY 

  loc_03EF46:
    SEP #$20
    LDA $0000, Y
    BMI loc_03EF8A        ; Byte >= $80 = end of equipment list sentinel
    REP #$20
    AND #$00FF
    CMP #$0008
    BCS loc_03EF5D        ; Items 0-7 → tile base $01E0; items 8+ → base $02E0
    ASL 
    ORA #$01E0
    BRA loc_03EF65

  loc_03EF5D:
    SEC 
    SBC #$0008
    ASL 
    ORA #$02E0

  loc_03EF65:
    ORA $099E
    INX 
    INX 
    STA $7F01BE, X        ; Upper-left tile of 2×2 metatile (VRAM row−1, col−1 offset)
    INC 
    STA $7F01C0, X
    CLC 
    ADC #$000F            ; ADC #$000F = lower-half tile row offset (+$10 − 1 for preceding INC)
    STA $7F01FE, X
    INC 
    STA $7F0200, X
    INX 
    INX 
    INY 
    LDA $01, S
    INC 
    STA $01, S
    BRA loc_03EF46

  loc_03EF8A:
    REP #$20
    PLA 
    CLC 
    ADC $01, S
    INC 
    TAY 
    PLA 
    TXA 
    STA $03, S
    RTS 
}