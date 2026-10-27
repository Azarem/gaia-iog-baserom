; Console string renderer — bytecode-driven HUD/UI text and widget system (256610–257943, Bank 03).
; 
; Implements a complete rendering engine for non-dialogue text output: inventory screens, status displays, HP bars, equipment icons, and bordered UI boxes. Separate from the wide-string dialogue renderer (DialogStringRenderer at 254549) — this system uses a simpler 8-bit character set where bytes >= $12 are literal tile indices written directly to the VRAM staging buffer, and bytes $00–$11 are command opcodes dispatched through an 18-entry command table.
; 
; === RENDERING ARCHITECTURE ===
; 
; Entry point: ConsoleStringRenderer, called via JSL. Y = string data pointer (in the current data bank), X = VRAM buffer write position (byte offset into $7F0200, one tilemap row = $40 bytes). Each character writes a 16-bit VRAM tilemap word: low byte = tile index, high byte = attribute (palette/priority/flip) from sceneStateHelper ($099F).
; 
; Display state: $099E/$099F form one 16-bit attribute word (the low byte is always 0 in the vanilla game, the high byte is sceneStateHelper). The multi-tile commands (numbers, boxes, fills, raw bytes) OR $099E into each tile word. $09A0 is the line-start cursor: SetVramAddr and DrawBox set it, and the two row-advance commands move it by a whole row and make it the new cursor, so a line break returns to the column of the last position command, not the current column.
; 
; The command dispatch uses JSR ($addr,X) — indirect indexed JSR through ConsoleStringCommandTable. Commands may recursively call ConsoleStringRenderer (InsertRemoteString, IndirectString, InsertSharedWord) and return the new X by writing it to the saved-X slot on the stack ($03,S, or $05,S after one extra PHY).
; 
; Operand addresses (digit sources, counts, index variables) are 16-bit offsets in the CURRENT data bank, so they only reach RAM because banks $00–$3F mirror WRAM $0000–$1FFF. Callers set the data bank to the string's bank.
; 
; === COMMAND TABLE ($00–$11) ===
; 
; The "Tag" column is the name used in the ConsoleString text syntax (db-us/stringTypes.json). In the vanilla strings (tables/system_strings) the commands STR, CLR, CPY and UNK never occur, and BCD occurs once with one digit; the retranslation/patch strings may use more.
; 
; | Cmd | Tag | Handler | Operand | Description |
; |-----|-----|---------|---------|-------------|
; | $00 | (end) | End | — | Pop registers, RTL to caller |
; | $01 | POS | SetVramAddr | 2B word | Set the cursor (and line start) to a buffer offset; the text form writes it as low byte, high byte |
; | $02 | STR | InsertRemoteString | 2B addr + 1B bank | Recursive render from another bank |
; | $03 | PAL | SetPalette | 1B bits | Set palette bits 2-4 in the attribute byte |
; | $04 | TBL | IndirectString | 2B table + 1B bank + 2B index address | Render the string selected by a RAM index |
; | $05 | BCD | PrintBcdNumber | 1B digit count + 2B addr | Packed BCD digits, low digit first in memory, printed right-to-left |
; | $06 | BOX | DrawBox | 1B w + 1B h + 2B pos | Bordered rectangle with corners/edges/fill |
; | $07 | CLR | ClearColumn | 2B pos | Blank a block whose width is measured from the existing tiles |
; | $08 | CPY | FillTile | 1B tile + 2B count address | Write a tile N times (N read from RAM) |
; | $09 | UNK | PrintEquipIcons | var (term $80+) | 2×2 equipment metatiles (no use found in the extracted strings) |
; | $0A | HP | DrawPlayerHpBar | — | Player HP as full/half/empty segments |
; | $0B | HE | DrawEnemyHpBar | — | Enemy HP bar (same algorithm, different palette) |
; | $0C | ESC | PrintRawBytes | var (term $FF) | Raw tile bytes until terminator |
; | $0D | DBL | DoubleNewLine | — | Line break of 2 tilemap rows: cursor = line start + $0080 |
; | $0E | NUM | Print3DigitNumber | 2B addr | 16-bit value at addr as up to 3 decimal digits |
; | $0F | RCC | ClearRect | 1B width + 1B height | Blank (width+1) × (height+1) tiles; must be the last command before the end byte |
; | $10 | LU | InsertSharedWord | 1B index | Insert entry N of shared_word_table (shared words such as 'Crystal ', 'Psycho '; used by item and ability names alike) |
; | $11 | N | NewLine | — | Line break of 1 tilemap row: cursor = line start + $0040 |
; 
; === HP BAR SYSTEM ===
; 
; DrawPlayerHpBar/DrawEnemyHpBar share DrawHpBar for rendering. HP is divided into three segment types:
; - Full segments ($00): playerHp/2, tile $2006 (filled)
; - Half segment ($08): 1 if HP is odd, tile $2007 (half-filled)
; - Empty segments ($02): (maxHP − HP)/2, tile $20FF (empty)
; 
; The bar is at most 40 half-units (20 segments). The clamp is written back to the source variable, and the current HP is only clamped when the maximum had to be clamped. Bars wrap to a second row via HpBar_AdvanceRow after 10 tiles. Player uses palette $0800 (palette 2), enemy uses $0400 (palette 1).
; 
; === DRAW BOX ===
; 
; Constructs a bordered rectangle (width × height interior, so width+2 by height+2 tiles) using 4 tile types: $10 (corners, with V/H flip bits for each corner), $11 (horizontal edges), $12 (vertical edges), $40 (interior fill). All OR'd with the $099E attribute word. After drawing, the cursor is set to box start + $0082 (2 rows down, 1 column right).
; 
; === EQUIPMENT ICONS ===
; 
; PrintEquipIcons renders variable-length equipment lists as 2×2 metatiles, 2 tiles wide each. Items 0-7 use tile base $01E0, items 8+ use $02E0 (2 tiles per icon in the tile sheet). Each icon writes 4 tiles: upper-left (N), upper-right (N+1), lower-left (N+$10), lower-right (N+$11); the upper pair goes in the row above the cursor, the lower pair in the cursor row.
---------------------------------------------

?BANK 03

?INCLUDE 'shared_word_table'

!consoleAttrWord                099E
!sceneStateHelper               099F
!consoleLineStart               09A0
!enemyHpDisplay                 09E4
!enemyHpCurrentDisplay          09E6
!playerMaxHp                    0ACA
!playerHp                       0ACE
!bg3TilemapBuffer               7F0200

---------------------------------------------

; Main entry point for the Console string rendering engine.
; 
; Called via JSL with Y = string data pointer, X = VRAM buffer byte offset into $7F0200. Saves processor state and data bank (restored by ConsoleCmd_End); it never changes the data bank itself, only the commands that recurse do. Processes the bytecode stream in a loop:
; - Bytes >= $12: literal tile characters — written to VRAM buffer as a 16-bit tilemap word (low byte = tile index, high byte = attribute from sceneStateHelper $099F)
; - Bytes $00–$11: command opcodes — dispatched via indexed indirect JSR through ConsoleStringCommandTable
; 
; The X register (VRAM write position) is pushed around each command (PHX/PLX), so a command that moves the cursor writes the new position into the pushed copy ($03,S).

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
    STA $bg3TilemapBuffer, X ; Write tile index to low byte of VRAM tilemap word
    XBA 
    LDA $sceneStateHelper ; Palette/priority attribute from sceneStateHelper ($099F)
    STA $bg3TilemapBuffer+1, X ; Write attribute to high byte — completes 16-bit VRAM tile word
    INX 
    INX 
    BRA loc_03EA64
}

---------------------------------------------
; 18-entry word table of command handler addresses for the Console string renderer.
; 
; Indexed by command byte (0–$11), each entry is a 16-bit JSR target (same bank). Entries cover text positioning, string insertion, number formatting, HP bars, equipment icons, and UI box drawing.

ConsoleStringCommandTable [
  &ConsoleCmd_End   ;00
  &ConsoleCmd_SetVramAddr   ;01
  &ConsoleCmd_InsertRemoteString   ;02
  &ConsoleCmd_SetPalette   ;03
  &ConsoleCmd_IndirectString   ;04
  &ConsoleCmd_PrintBcdNumber   ;05
  &ConsoleCmd_DrawBox   ;06
  &ConsoleCmd_ClearColumn   ;07
  &ConsoleCmd_FillTile   ;08
  &ConsoleCmd_PrintEquipIcons   ;09
  &ConsoleCmd_DrawPlayerHpBar   ;0A
  &ConsoleCmd_DrawEnemyHpBar   ;0B
  &ConsoleCmd_PrintRawBytes   ;0C
  &ConsoleCmd_DoubleNewLine   ;0D
  &ConsoleCmd_Print3DigitNumber   ;0E
  &ConsoleCmd_ClearRect   ;0F
  &ConsoleCmd_InsertSharedWord   ;10
  &ConsoleCmd_NewLine   ;11
]

---------------------------------------------
; Line break of one tilemap row (text tag [N]).
; 
; Adds $0040 (64 bytes = 32 words = one 32-tile tilemap row) to the line start in $09A0 and writes the result to both $09A0 and the saved X on the stack ($03,S). The old cursor column is discarded: text continues in the column of the last position command. The step is one tilemap row; ConsoleCmd_DoubleNewLine below advances two.
; 
; No operand bytes consumed.

ConsoleCmd_NewLine {
    LDA $consoleLineStart
    CLC 
    ADC #$0040            ; +$0040 = one tilemap row (32 words × 2 bytes)
    STA $consoleLineStart
    STA $03, S
    RTS 
}

---------------------------------------------
; Insert a shared word from shared_word_table (text tag [LU:n]).
; 
; 1-byte operand: entry index 0–$E. Multiplies by 2 (ASL) for the word table offset, switches the data bank to shared_word_table's bank, loads the string pointer and recursively calls ConsoleStringRenderer to render it (e.g. [LU:C] = 'Statue ', [LU:8] = 'Psycho '). Used by item names, item and ability descriptions and the ability menu. Returns the new cursor in the saved X on the stack.

ConsoleCmd_InsertSharedWord {
    PHY 
    PHB 
    LDA $06, S
    TAX 
    LDA $0000, Y
    AND #$00FF            ; 1-byte component index operand (×2 for word table offset)
    ASL 
    PHA 
    SEP #$20
    LDA #$^shared_word_table
    PHA 
    PLB 
    REP #$20
    PLY 
    LDA $&shared_word_table, Y ; Pointer to the shared-word string
    TAY 
    JSL $@ConsoleStringRenderer ; Recursively render the shared word (X = cursor)
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
; 2-byte operand: byte 0 = width, byte 1 = height. Fills (width + 1) × (height + 1) tiles with $0000 (blank, attribute 0) starting at the current cursor position: the inner loop writes width+1 tiles (BPL loop from width down to 0), and the row loop runs until the height counter goes negative. Rows are $0040 bytes apart.
; 
; Hazard: the height counter is loaded as a 16-bit word, so the byte AFTER the operand becomes its high byte. This only works when that byte is $00, so every use in the game is the last command before the end byte (e.g. [POS:0,0][RCC:1F,4]). Any other following byte would make the loop run for hundreds of rows. It does not change the cursor on the stack.

ConsoleCmd_ClearRect {
    PHY 
    LDA $05, S
    STA $00
    TAX 
    LDA $0000, Y
    AND #$00FF            ; Operand byte 0: width (the row loop writes width+1 tiles)
    STA $0E
    STA $10
    LDA $0001, Y
    STA $12               ; Height: 16-bit read, so the next string byte is the high byte (must be $00)

  loc_03EAF7:
    LDA #$0000

  loc_03EAFA:
    STA $bg3TilemapBuffer, X
    INX 
    INX 
    DEC $10
    BPL loc_03EAFA
    DEC $12
    BMI loc_03EB17
    LDA $00
    CLC 
    ADC #$0040            ; +$0040 = next tilemap row
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
; No operand. If playerMaxHp ($0ACA) exceeds 40 ($28) it is clamped to 40 in RAM and playerHp ($0ACE) is then clamped the same way (HP is not checked when the maximum is already ≤ 40). Computes three segment counts in DP scratch:
; - $00 = full segments (playerHp / 2)
; - $08 = half-unit flag (1 if playerHp is odd)
; - $02 = empty segments ((maxHP − HP) / 2, plus one when the three counts do not cover maxHP, i.e. an odd maximum)
; 
; Sets the palette word to $0800 (palette 2) in $04 and calls DrawHpBar with A = the cursor.

ConsoleCmd_DrawPlayerHpBar {
    PHY 
    STZ $08
    LDA $playerMaxHp
    CMP #$0029            ; Max above 40 ($28 = 20 segments)? Clamp it, then clamp HP
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
    LDA #$0800            ; Player bar attribute bits: palette 2
    STA $0004
    LDA $05, S
    JSR $&DrawHpBar
    PLY 
    RTS 
}

---------------------------------------------
; Shared HP bar rendering routine used by both player and enemy HP commands.
; 
; Takes the cursor (buffer offset) in A, sets Y = 10 (tiles left in the row). Draws segments in order:
; 1. Full segments ($00 count): tile $2006 | $04
; 2. Half segment ($08 flag): tile $2007 | $04 (skipped if 0)
; 3. Empty segments ($02 count): tile $20FF | $04
; 4. Blank tiles ($0000): the rest of the first 10-tile row (unless the bar already wrapped), then the rest of the second row, so a shrinking bar erases its old tiles
; 
; When Y reaches 0 (10 tiles drawn), HpBar_AdvanceRow moves to the next tilemap row and resets Y. $04 ($0800 = player, $0400 = enemy) is OR'd into each segment tile. It does not return the cursor: the HP commands leave the caller's cursor unchanged, so text after [HP]/[HE] continues where the bar started.

DrawHpBar {
    TAX 
    LDY #$000A            ; Y = 10 tiles per row (max bar display width)
    STZ $06
    LDA $00
    BEQ loc_03EB93
    LDA #$2006            ; Tile $2006 = filled bar segment
    ORA $0004

  loc_03EB81:
    STA $bg3TilemapBuffer, X
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
    STA $bg3TilemapBuffer, X
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
    STA $bg3TilemapBuffer, X
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
    LDA #$0000            ; Tile $0000 = blank padding for the rest of the first row

  loc_03EBCA:
    STA $bg3TilemapBuffer, X
    INX 
    INX 
    DEY 
    BNE loc_03EBCA
    JSR $&HpBar_AdvanceRow
    LDY #$000A

  loc_03EBD9:
    LDA #$0000

  loc_03EBDC:
    STA $bg3TilemapBuffer, X
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
; Guard: if the new X is $0100 or more (past buffer row 3), it pops an extra return address (PLA, discarding the return into DrawHpBar) so the RTS returns straight to DrawHpBar's caller and the rest of the bar is skipped.

HpBar_AdvanceRow {
    PHA 
    TXA 
    CLC 
    ADC #$002C            ; +$002C compensates for 10 tiles already drawn ($14) to reach next row ($0040)
    TAX 
    STA $06
    CMP #$0100            ; Bail if buffer offset >= $0100 (past the first four rows)
    BCS loc_03EBF9
    PLA 
    LDY #$000A
    RTS 

  loc_03EBF9:
    PLA 
    PLA                   ; Discard the return address into DrawHpBar → RTS exits DrawHpBar
    RTS 
}

---------------------------------------------
; Draw the enemy's HP bar using the same segment algorithm as player HP.
; 
; No operand. Uses enemyHpCurrentDisplay ($09E6) as current HP and enemyHpDisplay ($09E4) as the maximum. Same clamp (max above 40 is clamped in place, then HP) and segment calculation as ConsoleCmd_DrawPlayerHpBar. Sets the palette word to $0400 (palette 1) and calls DrawHpBar.

ConsoleCmd_DrawEnemyHpBar {
    PHY 
    STZ $0008
    LDA $enemyHpDisplay
    CMP #$0029
    BMI loc_03EC1C
    LDA #$0028
    STA $enemyHpDisplay
    LDA $enemyHpCurrentDisplay
    CMP #$0029
    BMI loc_03EC1C
    LDA #$0028
    STA $enemyHpCurrentDisplay

  loc_03EC1C:
    LDA $enemyHpCurrentDisplay
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
    LDA #$0400            ; Enemy bar attribute bits: palette 1
    STA $04
    LDA $05, S
    JSR $&DrawHpBar
    PLY 
    RTS 
}

---------------------------------------------
; Terminate the Console string renderer and return to the caller.
; 
; Command $00 (the string terminator). Called via JSR from the main loop, so it first pops that call's return address (PLA) and the pushed X (PLX), then restores the data bank and processor status pushed at ConsoleStringRenderer's entry (PLB/PLP) and returns to the JSL caller with RTL. This is the only exit from the rendering loop.

ConsoleCmd_End {
    PLA 
    PLX 
    PLB 
    PLP 
    RTL 
}

---------------------------------------------
; Line break of two tilemap rows (text tag [DBL]).
; 
; Adds $0080 (128 bytes = 2 rows × 32 words/row × 2 bytes/word) to the line start in $09A0 and writes the result to $09A0 and the saved X on the stack. Double the step of ConsoleCmd_NewLine.

ConsoleCmd_DoubleNewLine {
    LDA $consoleLineStart
    CLC 
    ADC #$0080            ; +$0080 = two tilemap rows
    STA $consoleLineStart
    STA $03, S
    RTS 
}

---------------------------------------------
; Format and print a decimal number as up to 3 digits.
; 
; 2-byte operand: address of a 16-bit source value (in the current data bank, see the header). Extracts hundreds, tens, and ones digits via repeated subtraction (÷100, ÷10, ÷1). Each digit is OR'd with the $099E attribute word + $30 tile base (the '0' glyph).
; 
; Leading zero suppression: hundreds digit is replaced with blank tile $2000 if zero. Tens digit is blank only if hundreds was also zero (tracked via $0006 flag). Ones digit is always displayed.
; 
; The hundreds digit is clamped to 9, but the tens and ones still come from value mod 100, so 1005 prints 905 (not 999). Always writes 3 tiles and moves the cursor past them.

ConsoleCmd_Print3DigitNumber {
    PHY 
    LDA $05, S
    TAX 
    STZ $0006
    STZ $0000
    LDA $consoleAttrWord
    ORA #$0030            ; Tile $30 = '0' glyph; digit n = $30 + n
    STA $0004
    LDA $0000, Y          ; 2-byte operand: address of the 16-bit source value
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
    STA $bg3TilemapBuffer, X
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
    STA $bg3TilemapBuffer, X
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
; Reads a 16-bit buffer offset from the string data (text tag [POS:lo,hi]), stores it in both $09A0 (line start, used by the line-break commands) and the saved X on the stack ($03,S), which becomes X when the command returns. Advances Y past the 2-byte operand.

ConsoleCmd_SetVramAddr {
    LDA $0000, Y          ; 2-byte operand: new buffer offset (row × $40 + column × 2)
    INY 
    INY 
    STA $consoleLineStart
    STA $03, S
    RTS 
}

---------------------------------------------
; Recursively render a string from another bank.
; 
; 3-byte operand (text tag [STR:@address]): 2-byte address + 1-byte bank. Takes the current cursor from the saved X on the stack, sets the data bank to the operand's bank (PHB, then PLB from a pushed byte), then calls ConsoleStringRenderer recursively via JSL with the new string address in Y. After return, restores the bank, advances Y past the 3-byte operand and stores the new cursor back.

ConsoleCmd_InsertRemoteString {
    LDA $03, S
    TAX 
    PHY 
    PHB 
    LDA $0000, Y          ; 3-byte operand: address (2) + bank (1) of the string to insert
    PHA 
    SEP #$20
    LDA $0002, Y
    PHA 
    PLB 
    REP #$20
    PLY 
    JSL $@ConsoleStringRenderer ; Recursive JSL — render the inserted string (X = cursor)
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
; 1-byte operand (text tag [PAL:n], n is the already-shifted bit pattern, e.g. 4 = palette 1, 8 = palette 2, $14 = palette 5). Reads sceneStateHelper ($099F), clears the palette bits 2-4 (AND $E3), ORs the operand into them and writes back, so the priority bit (bit 5) and flips are kept. This sets the attribute byte of all following tiles.

ConsoleCmd_SetPalette {
    SEP #$20
    LDA $sceneStateHelper
    AND #$E3              ; $E3 clears palette bits 2-4 (keeps priority and flips)
    ORA $0000, Y          ; 1-byte operand: new palette bits, ORed in
    INY 
    STA $sceneStateHelper
    REP #$20
    RTS 
}

---------------------------------------------
; Render a string selected by an indirect index lookup.
; 
; 5-byte operand (text tag [TBL:@table,addr]): 2-byte table address + 1-byte bank + 2-byte address of the index variable. Reads the 16-bit index from that address (in the caller's data bank, so a RAM variable), multiplies by 2, adds it to the table address, sets the data bank to the table's bank, reads the string pointer from the entry and recursively calls ConsoleStringRenderer.
; 
; Used for dynamic string selection, e.g. the item name or description for the item index in a RAM variable (item_name_table, item_description_table, ability_name_table, character_name_table, misc_ui_strings in system_strings).

ConsoleCmd_IndirectString {
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
; 3-byte operand (text tag [BCD:count,addr]): 1-byte digit count + 2-byte source address (current data bank, so a RAM variable). Digits are read from packed BCD bytes (2 digits per byte, least significant byte first, low nibble first) and printed right-to-left from cursor + 2×count. Each tile is $30 + digit in the low byte with the attribute byte $099F as the high byte ($099E's low byte is overwritten, not ORed).
; 
; After printing all digits, a suppression pass replaces leading '0' tiles ($30) with tile $20, always leaving the last digit. The cursor is advanced past the number. Every vanilla use is a 1-digit number, so the suppression pass has no vanilla effect; the project's string map names tile $20 '.', which is probably a blank in the actual font (unverified).

ConsoleCmd_PrintBcdNumber {
    LDA $03, S
    TAX 
    PHY 
    LDA $0000, Y
    AND #$00FF            ; Operand byte 0: digit count (the source address follows)
    STA $000E
    STA $0010
    ASL 
    PHX 
    CLC 
    ADC $01, S
    STA $01, S            ; End position = cursor + 2 × digits: also the cursor returned to the caller
    TAX 
    LDA $0001, Y
    TAY 
    LDA $consoleAttrWord
    SEP #$20

  loc_03ED90:
    LDA $0000, Y
    AND #$0F              ; Extract low nibble (least significant BCD digit)
    ORA #$30
    REP #$20
    DEX 
    DEX 
    STA $bg3TilemapBuffer, X
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
    STA $bg3TilemapBuffer, X
    SEP #$20
    DEC $000E
    BNE loc_03ED90

  loc_03EDC1:
    DEC $0010             ; Leading zero suppression pass
    BEQ loc_03EDD8
    LDA $bg3TilemapBuffer, X
    CMP #$30
    BNE loc_03EDD8
    LDA #$20              ; Replace a leading '0' ($30) with tile $20 (see note)
    STA $bg3TilemapBuffer, X
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
; 4-byte operand (text tag [BOX:w,h,pos]): 1-byte interior width + 1-byte interior height + 2-byte buffer offset of the top-left corner. Constructs the box using tile types OR'd with the $099E attribute word:
; - $10: corner tiles (4 variants via V/H flip: $0010 TL, $4010 TR, $8010 BL, $C010 BR)
; - $11: horizontal edges (top $0011, bottom $8011)
; - $12: vertical edges (left $0012, right $4012)
; - $40: interior fill
; 
; Draws top row (corner + edges + corner), then height rows of (border + fill + border), then bottom row. After drawing, the cursor and line start become box start + $0082 (2 rows down, 1 column right of the top-left corner, which is the second interior row, not the first).

ConsoleCmd_DrawBox {
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
    LDA $consoleAttrWord
    ORA #$0010            ; Top-left corner tile ($0010 | palette)
    STA $bg3TilemapBuffer, X
    LDA $0000
    STA $000E
    LDA $consoleAttrWord
    ORA #$0011            ; Horizontal edge tile ($0011 | attribute) for the top edge

  loc_03EE11:
    STA $bg3TilemapBuffer+2, X
    INX 
    INX 
    DEC $000E
    BNE loc_03EE11
    LDA $consoleAttrWord
    ORA #$4010
    STA $bg3TilemapBuffer+2, X
    LDA $01, S
    CLC 
    ADC #$0040
    TAX 
    LDA $0002
    STA $000E

  loc_03EE33:
    PHX 
    LDA $consoleAttrWord
    ORA #$0012            ; Vertical edge tile ($0012 | attribute) for the left edge (right edge uses $4012)
    STA $bg3TilemapBuffer, X
    LDA $0000
    STA $0010
    LDA $consoleAttrWord
    ORA #$0040            ; Interior fill tile ($0040 | attribute)

  loc_03EE4A:
    STA $bg3TilemapBuffer+2, X
    INX 
    INX 
    DEC $0010
    BNE loc_03EE4A
    LDA $consoleAttrWord
    ORA #$4012
    STA $bg3TilemapBuffer+2, X
    PLA 
    CLC 
    ADC #$0040
    TAX 
    DEC $000E
    BNE loc_03EE33
    LDA $consoleAttrWord
    ORA #$8010
    STA $bg3TilemapBuffer, X
    LDA $0000
    STA $000E
    LDA $consoleAttrWord
    ORA #$8011

  loc_03EE80:
    STA $bg3TilemapBuffer+2, X
    INX 
    INX 
    DEC $000E
    BNE loc_03EE80
    LDA $consoleAttrWord
    ORA #$C010
    STA $bg3TilemapBuffer+2, X
    PLA 
    PLY 
    CLC 
    ADC #$0082            ; Cursor = box start + $0082 (2 rows down, 1 column right)
    STA $consoleLineStart
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
; 2-byte operand (text tag [CLR:pos], not used by any vanilla string): buffer offset of the top-left tile. First scans rightward from there, testing only the low byte of each tile word, counting words until one is zero; that count minus one is stored as the width. Then blanks width tiles plus the tile after them in each row (so the whole measured run), advancing down by $0040, and stops when the first tile of the next row is zero (word test). A run of one tile gives width 0, which makes the 16-bit counter wrap and clear 64K words, so it must not be used that way. The TAY after reading the trailing tile is dead (the result is never used).
; 
; Erases a text block whose width is read from the tiles already on screen. It does not move the cursor.

ConsoleCmd_ClearColumn {
    PHY 
    LDA $0000, Y
    TAX 
    STZ $0000
    SEP #$20
    PHX 

  loc_03EEB0:
    LDA $bg3TilemapBuffer, X ; Scan right while the tile's low byte is non-zero, counting tiles
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
    LDA $0000             ; Per row: clear width tiles (+1 after the loop); repeat while the next row starts non-zero
    STA $000E
    PHX 
    LDA #$0000

  loc_03EECD:
    STA $bg3TilemapBuffer, X
    INX 
    INX 
    DEC $000E
    BNE loc_03EECD
    LDA $bg3TilemapBuffer, X
    TAY 
    LDA #$0000
    STA $bg3TilemapBuffer, X
    PLX 
    TXA 
    CLC 
    ADC #$0040
    TAX 
    LDA $bg3TilemapBuffer, X
    BNE loc_03EEC3
    PLY 
    INY 
    INY 
    RTS 
}

---------------------------------------------
; Fill N tile positions with a single tile value.
; 
; 3-byte operand (text tag [CPY:tile,addr], not used by any vanilla string): 1-byte tile index + 2-byte address of a 16-bit repeat count (current data bank). The tile byte replaces the low byte of the $099E attribute word to form the tile word, which is written count times (nothing if the count is 0). The cursor is advanced past the run.

ConsoleCmd_FillTile {
    PHY 
    LDA $0001, Y
    TAX                   ; Operand bytes 1-2: address of the repeat count
    LDA $0000, X          ; Repeat count (16-bit)
    PHA 
    LDA $07, S
    TAX 
    LDA $consoleAttrWord
    SEP #$20
    LDA $0000, Y          ; Operand byte 0: tile index (replaces the low byte; the high byte stays $099F)
    REP #$20
    PLY 
    BEQ loc_03EF17

  loc_03EF0E:
    STA $bg3TilemapBuffer, X
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
; Variable-length operand terminated by $FF (text tag [ESC:b1,b2,...]). Each byte is zero-extended to 16 bits, OR'd with the $099E attribute word, and written as a tile word to the VRAM buffer; this reaches tile indices below $12, which the main loop treats as commands (e.g. tiles 1–5 in the HUD string at consolestring_01E7F6). The $FF terminator is consumed but not written. The cursor is advanced past the run.

ConsoleCmd_PrintRawBytes {
    LDA $03, S
    TAX 

  loc_03EF22:
    LDA $0000, Y
    AND #$00FF
    CMP #$00FF            ; $FF = terminator of the raw run
    BEQ loc_03EF39
    ORA $consoleAttrWord  ; Raw byte OR'd with the $099E attribute word
    STA $bg3TilemapBuffer, X
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
; Variable-length operand (text tag [UNK], no use in any vanilla string): a list of 1-byte equipment indices terminated by any byte with bit 7 set (>= $80). Each item produces a 2×2 tile icon:
; - Items 0-7: tile $01E0 + 2 × index (first equipment page)
; - Items 8+: tile $02E0 + 2 × (index − 8) (second page)
; 
; The 4 tiles of each icon are N and N+1 in the row above the cursor and N+$10 and N+$11 in the cursor row (the sheet is 16 tiles wide). The cursor advances 4 bytes (2 tiles) per icon. A counter on the stack tracks the number of icons so Y can skip the operand and its terminator.

ConsoleCmd_PrintEquipIcons {
    LDA $03, S
    TAX 
    LDA #$0000
    PHA 
    PHY 

  loc_03EF46:
    SEP #$20
    LDA $0000, Y
    BMI loc_03EF8A        ; Byte >= $80 ends the list
    REP #$20
    AND #$00FF
    CMP #$0008
    BCS loc_03EF5D        ; Items 0-7 → tile $01E0 + 2×index; items 8+ → $02E0 + 2×(index−8)
    ASL 
    ORA #$01E0
    BRA loc_03EF65

  loc_03EF5D:
    SEC 
    SBC #$0008
    ASL 
    ORA #$02E0

  loc_03EF65:
    ORA $consoleAttrWord
    INX 
    INX 
    STA $7F01BE, X        ; Upper-left tile: X − $42 = row above, same column as the cursor (X was advanced by 2)
    INC 
    STA $7F01C0, X
    CLC 
    ADC #$000F            ; N+1 + $F = N+$10: lower-left tile (one sheet row below)
    STA $7F01FE, X
    INC 
    STA $bg3TilemapBuffer, X
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