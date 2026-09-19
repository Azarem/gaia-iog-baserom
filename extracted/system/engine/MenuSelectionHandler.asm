; Wide-string menu selection system (256073–256610, Bank 03).
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

?INCLUDE 'DialogStringRenderer'

!joypadCurrent                  0656
!joypadHeld                     0658
!sfxQueueCh2                    06F9
!displayModeFlags               09EC

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
    PHD 
    PHX 
    PHA                   ; Packed grid descriptor: high nibble = total items, low nibble = columns per page
    LDA #$0000
    TCD 
    PHA 
    STA $0994             ; Initial selection index = 0; blink counter cleared

  MenuSelection_PollLoop:
    JSR $&DrawMenuCursor
    JSR $&DialogStringRenderer.WaitOneFrame
    LDA $joypadCurrent
    BIT #$CF80            ; $CF80 mask = any navigation or action button
    BEQ MenuSelection_PollLoop
    PHA 
    LDA #$CFF0            ; Suppress all auto-repeat ($CFF0) once any input detected
    TSB $joypadHeld
    PLA 
    BIT #$0800            ; Input priority chain: Up → Down → L/R → A/Start → B
    BNE loc_03E8C6
    BIT #$0400
    BEQ loc_03E877
    JMP $&MenuSelection_Down

  loc_03E877:
    BIT #$0300
    BEQ loc_03E87F
    JMP $&MenuSelection_LeftRight

  loc_03E87F:
    BIT #$8080
    BNE loc_03E892
    BIT #$4000
    BEQ MenuSelection_PollLoop
    JSR $&ReadMenuSelection ; B = cancel: restore tiles via ReadMenuSelection, return 0
    PLA 
    LDA #$0000
    BRA loc_03E8B3

  loc_03E892:
    LDA $000A             ; A/Start = confirm: preserve $0A/$0C work areas across SFX write
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
    STZ $0994
    JSR $&DrawMenuCursor  ; Redraw cursor in solid (non-blinking) confirmed state
    PLA 
    INC                   ; INC: convert 0-based selection to 1-based result

  loc_03E8B3:
    PHA 
    JSR $&DialogStringRenderer.WaitOneFrame
    PLA 
    STZ $0994             ; Clean up: zero blink counter, clear saved cursor tiles ($0990/$0992)
    STZ $0990
    STZ $0992
    PLY 
    PLX 
    PLD 
    SEC                   ; Return with carry set; A = 1-based selection (0 = cancelled)
    RTL 

  loc_03E8C6:
    SEP #$20
    LDA #$10              ; Navigation SFX = $10
    STA $sfxQueueCh2
    REP #$20
    STZ $0994
    SEP #$20
    LDA $03, S            ; Unpack grid: AND $0F = columns → $1C; LSR×4 = total → $18
    AND #$0F
    STA $1C
    LDA $03, S
    LSR 
    LSR 
    LSR 
    LSR 
    STA $18
    LDA $01, S
    DEC                   ; Decrement selection; if negative, wrap to (total − 1) or (columns − 1)
    BMI loc_03E8EE
    STA $01, S
    REP #$20
    JMP $&MenuSelection_PollLoop

  loc_03E8EE:
    LDA $18
    BNE loc_03E8F4
    LDA $1C

  loc_03E8F4:
    DEC 
    STA $01, S
    REP #$20
    JMP $&MenuSelection_PollLoop
}

---------------------------------------------
; Handle Down input in menu selection.
; 
; Extracts grid dimensions from the packed stack parameter (high nibble = total, low nibble = columns). Increments the selection index. If it exceeds the column count (entering the second page), wraps or caps to the total count. Plays navigation sound and returns to the poll loop.

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
    LDA $01, S            ; Selection < columns = first page; ≥ columns = second page
    CMP $1C
    BCS loc_03E92E
    INC                   ; First page: increment, wrap to 0 at column boundary
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
    INC                   ; Second page: increment, wrap to column count at total boundary
    CMP $18
    BCC loc_03E935
    LDA $1C

  loc_03E935:
    STA $01, S
    REP #$20
    JMP $&MenuSelection_PollLoop
}

---------------------------------------------
; Handle L/R input for column-based menu navigation.
; 
; Adds or subtracts the column count to/from the current selection. Clamps to grid bounds. If the result crosses a page boundary, plays the navigation sound; otherwise returns silently to the poll loop.

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
    LDA $01, S            ; Determine current page by comparing selection to column count
    CMP $1C
    BCS loc_03E969
    CLC                   ; First page → right: add columns (clamp to total)
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
    SEC                   ; Second page → left: subtract columns
    SBC $1C
    STA $01, S
    CMP $1C
    REP #$20
    BCC loc_03E977
    JMP $&MenuSelection_PollLoop

  loc_03E977:
    SEP #$20              ; Play navigation SFX only when page actually changed
    LDA #$10
    STA $sfxQueueCh2
    REP #$20
    JMP $&MenuSelection_PollLoop
}

---------------------------------------------
; Draw the menu selection cursor with a 16-frame blink animation.
; 
; Increments the blink counter ($0994). Bit 4 determines the cursor phase: clear = highlight tiles ($212C/$213C for top/bottom), set = dim tiles ($21AC both). Saves the tiles currently under the cursor to $0990/$0992, then overwrites with cursor tiles.
; 
; Computes the cursor position from: the base row offset (SP+6), the grid selection index (SP+3), the column count (from packed dimensions), and the box origin ($097E/$0980). The X offset ($18) is 0 for the first page or $18 for the second page.

DrawMenuCursor {
    LDA $0994
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
    STA $7F0200, X
    LDA $0992
    STA $7F0240, X

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
    LDA $03, S
    CMP $1C               ; Page check: first page = direct index, second page = subtract columns
    BCC loc_03E9DC
    SEC 
    SBC $1C
    STA $1C
    STZ $1D
    LDX #$0018            ; Second page X offset = $18 (12 tiles × 2 bytes)
    STX $18
    BRA loc_03E9E5

  loc_03E9DC:
    STA $1C
    STZ $1D
    LDX #$0000
    STX $18

  loc_03E9E5:
    REP #$20
    LDA $06, S            ; Compute cursor VRAM offset: (row_base + index) × 2 rows × 32 cols + col_origin + page_offset
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
    LDA $7F0200, X        ; Load tiles under cursor to $0990/$0992, write cursor tiles over them
    PHA 
    LDA $00
    STA $7F0200, X
    LDA $7F0240, X
    PHA 
    LDA $02
    STA $7F0240, X
    STX $098E             ; Store cursor VRAM position to $098E for next-frame restore
    PLA 
    STA $0992
    PLA 
    STA $0990
    LDA #$0001
    TSB $displayModeFlags
    RTS 
}

---------------------------------------------
; Restore tiles under the menu cursor and convert position to OAM data.
; 
; Restores the saved tiles ($0990/$0992) to their original VRAM buffer positions. Converts the tile values to OAM-compatible format: strips palette/priority bits (AND $03FF), shifts left 3 (ASL ×3), and OR's with $6000 for the OAM priority. Writes to $090E/$0910 for sprite overlay use. Clears the saved tile state.

ReadMenuSelection {
    PHY 
    LDX $098E
    LDA $0990             ; Restore saved tiles ($0990/$0992) to original VRAM positions
    STA $7F0200, X
    AND #$03FF            ; Convert tile to OAM format: AND $03FF (strip palette), ASL×3, ORA $6000 (priority)
    ASL 
    ASL 
    ASL 
    ORA #$6000
    STA $090E             ; Write OAM sprite data: $090E (top half), $0910 (bottom half)
    LDA $0992
    STA $7F0240, X
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