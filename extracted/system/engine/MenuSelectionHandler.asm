; Choice-menu cursor for the dialog option op (COP #BE, cop_handlers_dialog.DialogueOptions, its only caller; 92 script sites) (256073–256610, Bank 03).
; 
; The button bits in this file are the logical bits the remap produces, not the raw pad bits: with the default remap (system_init) the A button gives $8080 (confirm is $8000) and the B button gives $4008 (cancel is $4000). The raw pad word has B = $8000, Y = $4000, Start = $1000, Select = $2000 (vblank_joypad).
; 
; === Parameter ===
; A on entry (read from the script as one 16-bit word): low byte = packed layout, high byte = first text row. Packed byte: low nibble C = items in the first column, high nibble N = total items when there are two columns; N = 0 means a single column of C items. First operand byte over the 92 script sites: $02 (69 sites; second byte 0-3), $04 (8), $03 (4), $32 (4: 3 items, 2 + 1), $42 (3: 4 items, 2 + 2), $01 (3), $63 (1: 6 items, 3 + 3).
; Stack frame in the handler: SP+1/2 = selection (0-based, starts at 0), SP+3 = packed byte, SP+4 = first row, then the saved X and D. Inside DrawMenuCursor every offset is 2 higher (JSR return address).
; 
; === Input ===
; Polls joypadCurrent once per frame (DrawMenuCursor, then WaitOneFrame) against the mask $CF00: Up $0800, Down $0400, Left or Right $0300, confirm $8000 (the A button), cancel $4000 (the B button). Start is not accepted, and 'L/R' means the D-pad. Priority: Up, Down, Left/Right, confirm, cancel.
; The bits $CFFC are then added to joypadHeld, which marks them consumed. That does not suppress the D-pad repeat: DialogueOptions sets joypadMaskInv = $0F00, so the consumed D-pad bits repeat every 12 joypad updates while held (vblank_joypad).
; The vanilla code tests $8080 for confirm (the B or A button), masks with $CF80 and consumes with $CFF0; db-us/transforms.json rewrites them to $8000, $CF00 and $CFFC, and every value in these notes is the rewritten one.
; - Up: previous item; from item 0 it wraps to the LAST item of the second column (or of the only column), and from the top of column 2 it goes to the bottom of column 1 (not symmetric with Down).
; - Down: next item inside the current column; wraps to the top of the SAME column.
; - Left and Right do the same thing: toggle the column (index + C when that item exists, index - C from the second column); the sound plays only when the column changed.
; - Sound effects go to sfxQueueCh2: navigation $10, confirm $11.
; 
; === Cursor ===
; DrawMenuCursor writes two tiles (top $212C or $21AC, bottom $213C or $21AC) into the BG3 tilemap staging buffer (bg3TilemapBuffer, bg3TilemapRow1 = next row) at ((((first row + row in column) x 2 + $0980) x 32 + $097E) x 2) bytes plus the column offset ($18 bytes = 12 tiles for column 2), where $097E/$0980 are the dialog box origin. Bit 4 of the blink counter $0994 chooses the tile pair, so the cursor is lit for 16 frames and dim for 16 (32-frame period). The tiles under the cursor are saved in $0990/$0992 (position $098E) and restored before the cursor moves. displayModeFlags bit 0 (the full BG3 upload request) is set on every redraw.
; 
; === Result ===
; Returns A = 1-based selection with carry set; cancel returns A = 0. Y is clobbered (the parameter word is popped into it); X and D are restored. Confirm leaves the highlighted cursor drawn (the saved tiles are only cleared, not restored); cancel restores them through ReadMenuSelection first. The initial selection is always 0.
---------------------------------------------

?BANK 03

?INCLUDE 'DialogStringRenderer'

!joypadCurrent                  0656
!joypadHeld                     0658
!sfxQueueCh2                    06F9
!displayModeFlags               09EC
!bg3TilemapBuffer               7F0200
!bg3TilemapRow1                 7F0240

---------------------------------------------

; Entry point. Pushes D, X and the parameter word, zeroes D, starts the selection at 0 with a cleared blink counter and loops in MenuSelection_PollLoop: draw the cursor, wait one frame, read joypadCurrent, dispatch on the first matching bit (Up, Down, Left/Right, confirm, cancel). Returns A = 1-based selection (0 = cancelled) with carry set. See the block note.

MenuSelectionHandler {
    PHD 
    PHX 
    PHA                   ; Menu parameter word: low byte = packed layout (N x 16 + C), high byte = first text row
    LDA #$0000
    TCD 
    PHA                   ; SP+1/2 = selection, starts at 0
    STA $0994             ; Blink counter = 0 (the selection pushed above is 0 too)

  MenuSelection_PollLoop:
    JSR $&DrawMenuCursor
    JSR $&DialogStringRenderer.WaitOneFrame
    LDA $joypadCurrent
    BIT #$CF00            ; Any of Up/Down/Left/Right ($0F00), confirm ($8000) or cancel ($4000); Start is not accepted
    BEQ MenuSelection_PollLoop
    PHA 
    LDA #$CFFC            ; Marks the nav/action bits consumed in joypadHeld (the D-pad still repeats: joypadMaskInv = $0F00, set by DialogueOptions)
    TSB $joypadHeld
    PLA 
    BIT #$0800            ; Priority: Up, Down, Left/Right, confirm, cancel
    BNE MenuSelection_Up
    BIT #$0400
    BEQ loc_03E877
    JMP $&MenuSelection_Down

  loc_03E877:
    BIT #$0300
    BEQ loc_03E87F
    JMP $&MenuSelection_LeftRight

  loc_03E87F:
    BIT #$8000            ; Confirm bit: $8000 is set by the A button (default remap gives A $8080)
    BNE MenuSelection_Confirm
    BIT #$4000            ; Cancel bit: $4000 is set by the B button (default remap gives B $4008)
    BEQ MenuSelection_PollLoop
    JSR $&ReadMenuSelection ; B = cancel: restore tiles via ReadMenuSelection, return 0
    PLA 
    LDA #$0000
    BRA MenuSelection_Return

; Confirm branch of the poll loop: saves $0A/$0C around the SFX write (no instruction between the push and the pop writes either), plays SFX $11, clears the blink counter, redraws the cursor lit, turns the 0-based selection into a 1-based result and falls into MenuSelection_Return.

  MenuSelection_Confirm:
    LDA $000A             ; Confirm: saves $0A/$0C around the SFX write, which touches neither (the push/pop pair has no effect)
    PHA 
    LDA $000C
    PHA 
    SEP #$20
    LDA #$11              ; Confirm SFX = $11
    STA $sfxQueueCh2
    REP #$20
    PLA 
    STA $000C
    PLA 
    STA $000A
    STZ $0994             ; Blink counter 0: the redraw below (counter becomes 1) shows the lit cursor
    JSR $&DrawMenuCursor  ; Redraw cursor in solid (non-blinking) confirmed state
    PLA 
    INC                   ; INC: convert 0-based selection to 1-based result

; Shared exit of MenuSelectionHandler: one-frame wait, clears the blink counter and the saved cursor tiles, pops the parameter word into Y, restores X and D and returns carry set with the 1-based selection (0 = cancelled).

  MenuSelection_Return:
    PHA 
    JSR $&DialogStringRenderer.WaitOneFrame
    PLA 
    STZ $0994             ; Cleanup: zero blink counter and saved tiles; the tiles are NOT restored, so the lit cursor stays in the BG3 buffer after a confirm
    STZ $0990
    STZ $0992
    PLY                   ; Pops the parameter word into Y (Y is clobbered)
    PLX 
    PLD 
    SEC                   ; Return with carry set; A = 1-based selection (0 = cancelled)
    RTL 

; Up branch of MenuSelection_PollLoop: plays SFX $10, unpacks the grid position from the stack byte, decrements the selection (wrapping through MenuSelection_UpWrap when it goes below zero) and returns to the poll loop.

  MenuSelection_Up:
    SEP #$20
    LDA #$10              ; Navigation SFX = $10
    STA $sfxQueueCh2
    REP #$20
    STZ $0994
    SEP #$20
    LDA $03, S            ; Unpack the packed byte: AND $0F = C (items in the first column) -> $1C; LSR x4 = N (total, 0 = one column) -> $18
    AND #$0F
    STA $1C
    LDA $03, S
    LSR 
    LSR 
    LSR 
    LSR 
    STA $18
    LDA $01, S
    DEC                   ; Decrement the selection; below zero it wraps to the last item (MenuSelection_UpWrap)
    BMI MenuSelection_UpWrap
    STA $01, S
    REP #$20
    JMP $&MenuSelection_PollLoop

; Reached when Up takes the selection below zero: wraps to the last item (the last index of the column, or of the second column) and returns to the poll loop.

  MenuSelection_UpWrap:
    LDA $18               ; Up from item 0: last item of the second column, or of the only column when N = 0
    BNE loc_03E8F4
    LDA $1C

  loc_03E8F4:
    DEC 
    STA $01, S
    REP #$20
    JMP $&MenuSelection_PollLoop
}

---------------------------------------------
; Down handler. Plays the navigation sound, resets the blink counter, unpacks C and N from SP+3 and advances the selection inside its column: in column 1 it wraps from C-1 to 0, in column 2 from N-1 back to C.

MenuSelection_Down {
    SEP #$20
    LDA #$10              ; Navigation SFX = $10
    STA $sfxQueueCh2
    REP #$20
    STZ $0994
    SEP #$20
    LDA $03, S
    AND #$0F
    STA $1C
    LDA $03, S
    LSR 
    LSR 
    LSR 
    LSR 
    STA $18
    LDA $01, S            ; Index < C: first column; otherwise second column
    CMP $1C
    BCS loc_03E92E
    INC                   ; First column: increment, wrap to 0 after C-1 (never leaves the column)
    CMP $1C
    BCS loc_03E925
    BRA loc_03E927

  loc_03E925:
    LDA #$00

  loc_03E927:
    STA $01, S
    REP #$20
    JMP $&MenuSelection_PollLoop

  loc_03E92E:
    INC                   ; Second column: increment, wrap back to C (top of the column) after N-1
    CMP $18
    BCC loc_03E935
    LDA $1C

  loc_03E935:
    STA $01, S
    REP #$20
    JMP $&MenuSelection_PollLoop
}

---------------------------------------------
; Left/Right handler (both buttons act identically). Resets the blink counter. Column 1: index + C if that item exists (below N), otherwise unchanged. Column 2: index - C. The navigation sound plays only when the column actually changed.

MenuSelection_LeftRight {
    STZ $0994
    SEP #$20
    LDA $03, S
    AND #$0F
    STA $1C
    LDA $03, S
    LSR 
    LSR 
    LSR 
    LSR 
    STA $18
    LDA $01, S            ; Index < C: first column; otherwise second column
    CMP $1C
    BCS loc_03E969
    CLC                   ; First column: same row in column 2 (index + C) if that item exists (below N), else stay
    ADC $1C
    CMP $18
    BCC loc_03E95E
    LDA $01, S

  loc_03E95E:
    STA $01, S
    CMP $1C
    REP #$20
    BCS loc_03E977
    JMP $&MenuSelection_PollLoop

  loc_03E969:
    SEC                   ; Second column: same row in column 1 (index - C)
    SBC $1C
    STA $01, S
    CMP $1C
    REP #$20
    BCC loc_03E977
    JMP $&MenuSelection_PollLoop

  loc_03E977:
    SEP #$20              ; Navigation SFX, reached only when the column changed
    LDA #$10
    STA $sfxQueueCh2
    REP #$20
    JMP $&MenuSelection_PollLoop
}

---------------------------------------------
; Draws the blinking two-tile cursor. Increments the blink counter $0994 (bit 4 chooses the lit pair $212C/$213C or the dim pair $21AC/$21AC), restores the tiles saved at the previous cursor position, computes the new tilemap offset from the first row, the row inside the column, the dialog box origin ($097E/$0980) and the column offset ($18 bytes for column 2), saves the two tiles now under the cursor in $0990/$0992 and writes the cursor tiles. Sets displayModeFlags bit 0. Parameter offsets are 2 higher than in the handler because of the JSR.

DrawMenuCursor {
    LDA $0994             ; Blink counter: lit for 16 frames, dim for 16 (32-frame period)
    INC 
    STA $0994
    BIT #$0010            ; Bit 4 of counter: clear = highlight ($212C/$213C), set = dim ($21AC)
    BNE loc_03E99B
    LDA #$212C
    STA $00
    LDA #$213C
    STA $02
    BRA loc_03E9A2

  loc_03E99B:
    LDA #$21AC
    STA $00
    STA $02

  loc_03E9A2:
    LDA $0990             ; Restore previous tiles at old cursor position before drawing new cursor
    BEQ loc_03E9B8
    LDX $098E
    LDA $0990
    STA $bg3TilemapBuffer, X
    LDA $0992
    STA $bg3TilemapRow1, X

  loc_03E9B8:
    SEP #$20
    LDA $05, S            ; Unpack grid from SP+5 (offset shifted by JSR return address)
    AND #$0F
    STA $1C
    LDA $05, S
    LSR 
    LSR 
    LSR 
    LSR 
    STA $18
    LDA $03, S            ; Selection index (SP+3 here: +2 for the JSR return address)
    CMP $1C               ; Index >= C: second column, row = index - C; else first column
    BCC loc_03E9DC
    SEC 
    SBC $1C
    STA $1C
    STZ $1D
    LDX #$0018            ; Second column offset = $18 bytes = 12 tiles
    STX $18
    BRA loc_03E9E5

  loc_03E9DC:
    STA $1C
    STZ $1D
    LDX #$0000
    STX $18

  loc_03E9E5:
    REP #$20
    LDA $06, S            ; Offset = ((((first row + row in column) x 2 + $0980) x 32 + $097E) x 2) + column offset, into the BG3 staging buffer
    AND #$00FF
    CLC 
    ADC $1C
    ASL 
    CLC 
    ADC $0980
    ASL 
    ASL 
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $097E
    ASL 
    CLC 
    ADC $18
    TAX 
    LDA $bg3TilemapBuffer, X ; Load tiles under cursor to $0990/$0992, write cursor tiles over them
    PHA 
    LDA $00
    STA $bg3TilemapBuffer, X
    LDA $bg3TilemapRow1, X
    PHA 
    LDA $02
    STA $bg3TilemapRow1, X
    STX $098E             ; Store cursor VRAM position to $098E for next-frame restore
    PLA 
    STA $0992
    PLA 
    STA $0990
    LDA #$0001
    TSB $displayModeFlags ; Set displayModeFlags bit 0 (full BG3 upload request)
    RTS 
}

---------------------------------------------
; Cancel path: puts the saved tiles back into the BG3 buffer, stores (tile and $03FF) x 8 + $6000 for each of the two tiles in $090E/$0910 (the VRAM word address of that tile's characters when BG3 uses the character base $6000; not an OAM value, and no instruction in extracted/ addresses $090E or $0910 besides these two stores), clears $0990/$0992 and sets displayModeFlags bit 0.

ReadMenuSelection {
    PHY 
    LDX $098E
    LDA $0990             ; Restore saved tiles ($0990/$0992) to original VRAM positions
    STA $bg3TilemapBuffer, X
    AND #$03FF            ; Tile number x 8 + $6000 = VRAM word address of this tile's characters (BG3 character base $6000), not an OAM value
    ASL 
    ASL 
    ASL 
    ORA #$6000
    STA $090E             ; $090E/$0910 = those addresses for the two tiles under the cursor; no instruction in extracted/ addresses them besides these two stores
    LDA $0992
    STA $bg3TilemapRow1, X
    AND #$03FF
    ASL 
    ASL 
    ASL 
    ORA #$6000
    STA $0910
    STZ $0990             ; Clear saved tile state ($0990/$0992 = 0)
    STZ $0992
    LDA #$0001
    TSB $displayModeFlags
    PLY 
    RTS 
}