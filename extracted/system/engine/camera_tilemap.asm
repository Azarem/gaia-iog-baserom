; Camera tilemap rendering, VRAM DMA transfer, and scroll stripe management (Bank 02).
; 
; Implements the complete pipeline for updating SNES background layer tilemaps in response to camera scrolling. The system manages two BG layers (indexed by X=0 for layer 0, X=2 for layer 1) with independent scroll positions, using a staging buffer at $7E3100 to prepare tilemap data for DMA transfer during V-Blank.
; 
; Two primary modes:
; - CameraFullRefresh: Redraws the entire visible tilemap by iterating all 32 rows, clamping camera to map bounds, rendering each row via RenderScrollRow, and immediately DMA-transferring it to VRAM. Called on scene load or major camera repositioning.
; - CameraSmoothScroll: Per-frame incremental scroll. Deltas are clamped to ±16px per frame for smooth motion. When scrolling crosses a 16px tile boundary (detected by XOR of old/new positions on bit 4), the newly-visible row or column is rendered into the staging buffer for DMA during V-Blank.
; 
; The rendering pipeline (RenderScrollRow, RenderScrollColumn) converts map tile indices to 2×2 VRAM tilemap entries (16×16 metatiles → four 8×8 tiles), handles nametable wrapping via WrapMapIndex, and writes to the staging buffer. FillHorizTilemapSeg and FillVertTilemapSeg are the inner loops that expand metatile indices into VRAM-format tilemap words.
; 
; FlushDirtyTilemapStrips is called during V-Blank (NMI) to DMA any staged horizontal and vertical strips to VRAM using DmaHorizontalStrip (64 bytes = one row) and DmaVerticalStrip (128 bytes = one column).
; 
; SpriteVramDma handles sprite tile transfers from WRAM $7F to VRAM during V-Blank, with full ($0800 bytes for character form changes) and partial ($0140 bytes for animation frame updates) transfer modes.
---------------------------------------------

?BANK 02

?INCLUDE 'hardware_math'
?INCLUDE 'system_init'

!bg1ScrollH                     068A
!bg1ScrollV                     068C
!bg2ScrollH                     068E
!savedCameraDelta               0690
!mapBoundsX                     0692
!mapBoundsY                     0696
!mapTilemapBaseA                069E
!cameraTargetX                  06BE
!cameraDeltaX                   06C0
!cameraTargetY                  06C2
!cameraDeltaY                   06C4
!scrollDeltaXClamped            06CE
!scrollDeltaYClamped            06D2
!layerPriorityFlag              06EE
!scrollModeFlags                06EF
!displayModeFlags               09EC
!VMAIN                          2115
!VMADDL                         2116
!MDMAEN                         420B
!DMAP0                          4300
!BBAD0                          4301
!A1T0L                          4302
!A1B0                           4304
!DAS0L                          4305
!tilemapStaging                 7E3100

---------------------------------------------

; Full tilemap refresh — redraws the entire visible screen.
; 
; Clamps camera target positions to map bounds using bitmask clamping (AND with bounds−1). Copies clamped positions to the BG scroll registers ($068A+X for horizontal, $068E+X for vertical) and aligns to the 16px tile grid for rendering origin.
; 
; Sets up VRAM DMA registers: VMAIN=$81 (word-access, column-mode auto-increment), DMAP0=$01 (two-register), BBAD0=$18 (VRAM data port), source bank=$7E.
; 
; Iterates 32 rows (full screen height in metatiles): for each row, calls RenderScrollRow to build tilemap data in the staging buffer, then immediately DMA-transfers it via DmaHorizontalStrip. After each row, advances the X position by 16px and wraps against map bounds.
; 
; After all rows are rendered, clears the four staging buffer VRAM address words to prevent re-triggering, then calls UploadCgramPalette to sync the color palette.
; 
; Called during scene loading and major camera repositioning where the entire tilemap must be rebuilt.

CameraFullRefresh {
    PHP                   ; Save flags; routine uses mixed 8/16-bit modes for VRAM register setup and map math
    REP #$20
    LDA $cameraTargetX, X ; Load camera target X position for this BG layer (X = 0 or 2 selects layer)
    CMP $mapBoundsX, X    ; Compare against map width bound — camera must not scroll past map edge
    BCC loc_02ABA3
    LDA $mapBoundsX, X
    DEC                   ; Create bitmask (bounds−1) for AND-based position clamping
    STA $00
    LDA $cameraTargetX, X
    AND $00
    STA $cameraTargetX, X

  loc_02ABA3:
    STA $bg1ScrollH, X    ; Copy clamped X to BG horizontal scroll register ($068A+X)
    AND #$FFF0            ; Align to 16px metatile grid — tilemap rendering operates on 16×16 granularity
    STA $18
    LDA $cameraTargetY, X ; Load camera target Y for vertical bounds checking and clamping
    BMI loc_02ABC3
    CMP $mapBoundsY, X
    BCC loc_02ABC3
    LDA $mapBoundsY, X
    DEC 
    STA $00
    LDA $cameraTargetY, X
    AND $00
    STA $cameraTargetY, X

  loc_02ABC3:
    STA $bg2ScrollH, X    ; Copy clamped Y to BG vertical scroll register ($068E+X)
    AND #$FFF0
    STA $1C
    SEP #$20
    LDA #$81              ; VMAIN=$81: word-access VRAM, auto-increment by 32 words (column-mode for strips)
    STA $VMAIN
    LDA #$01
    STA $DMAP0
    LDA #$18
    STA $BBAD0
    LDA #$7E
    STA $A1B0
    REP #$20
    LDA #$0020            ; Loop counter = 32: full visible screen height in metatiles

  loc_02ABE6:
    PHA                   ; === Full tilemap row rendering loop (32 iterations) ===
    JSR $&RenderScrollRow ; Render one horizontal row of metatiles into the staging buffer
    PHX 
    LDA $06B2, X
    TAX 
    LDA $7E0000, X
    TAY 
    JSR $&DmaHorizontalStrip ; Immediately DMA the rendered row to VRAM (no staging — direct transfer)
    PLX 
    LDA $18
    CLC 
    ADC #$0010            ; Advance rendering position by 16px (one metatile row height)
    CMP $mapBoundsX, X    ; Check if position has passed map width bound; wrap if needed
    BCC loc_02AC0F
    AND #$0100
    CMP $mapBoundsX, X
    BCC loc_02AC0F
    SEC 
    SBC $mapBoundsX, X

  loc_02AC0F:
    STA $18               ; Store wrapped row position; continue loop
    PLA 
    DEC 
    BNE loc_02ABE6
    LDA #$0000            ; Clear all four staging buffer VRAM address words to prevent V-Blank re-trigger
    STA $tilemapStaging
    STA $7E3288
    STA $7E3184
    STA $7E330C
    JSL $@system_init.UploadCgramPalette ; Upload full CGRAM palette after tilemap refresh to sync colors with new tiles
    PLP 
    RTL 
}

---------------------------------------------
; Per-frame incremental smooth scrolling for both BG layers.
; 
; Three modes based on flags:
; 1. Direct mode (scrollModeFlags bit 3): Copies camera targets directly to scroll registers without any smoothing or delta clamping.
; 2. Layer 1 priority mode (X≠0 and layerPriorityFlag bit $0400): Copies camera deltas directly to the secondary layer scroll registers (bg1ScrollV and savedCameraDelta).
; 3. Normal smooth scroll: For each axis (X then Y):
;    a. Computes delta = target − current scroll position
;    b. Clamps delta to ±16px maximum per frame for smooth motion
;    c. Stores clamped delta (scrollDeltaXClamped/scrollDeltaYClamped)
;    d. Applies delta to update the scroll position
;    e. XORs old and new positions and tests bit 4 — if this bit changed, the camera crossed a 16px tile boundary
;    f. On boundary crossing: calls UpdateScrollColumn (for X) or UpdateScrollRow (for Y) to render the newly-visible tile strip into the staging buffer
; 
; The XOR boundary detection is elegant: bit 4 represents the 16px tile grid alignment, so any change in this bit means a new column or row of tiles has scrolled into view.

CameraSmoothScroll {
    PHP 
    REP #$20
    LDA $scrollModeFlags  ; Test scrollModeFlags bit 3: direct scroll mode bypasses delta clamping entirely
    BIT #$0008
    BEQ loc_02AC47
    LDA $cameraTargetX, X ; Direct mode: copy camera targets straight to scroll position registers (no smoothing)
    STA $bg1ScrollH, X
    LDA $cameraTargetY, X
    STA $bg2ScrollH, X
    PLP 
    RTL 

  loc_02AC47:
    CPX #$0000            ; Check if processing secondary BG layer (X≠0) with priority flag active
    BEQ loc_02AC62
    LDA $layerPriorityFlag
    BIT #$0400
    BEQ loc_02AC62
    LDA $cameraDeltaX     ; Layer 1 priority: store deltas directly to bg1ScrollV and savedCameraDelta
    STA $bg1ScrollV
    LDA $cameraDeltaY
    STA $savedCameraDelta
    PLP 
    RTL 

  loc_02AC62:
    LDA $bg1ScrollH, X    ; Load current horizontal scroll position on stack for tile-boundary XOR detection
    PHA 
    LDA $cameraTargetX, X
    SEC 
    SBC $bg1ScrollH, X    ; Compute X delta = camera target X − current BG scroll X
    BPL loc_02AC79
    CMP #$FFF0            ; Clamp negative delta: if less than −16, force to −16px per frame
    BCS loc_02AC81
    LDA #$FFF0
    BRA loc_02AC81

  loc_02AC79:
    CMP #$0010            ; Clamp positive delta: if greater than +16, force to +16px per frame
    BCC loc_02AC81
    LDA #$0010

  loc_02AC81:
    STA $scrollDeltaXClamped, X ; Store clamped horizontal delta for later use by tilemap rendering system
    CLC 
    ADC $bg1ScrollH, X    ; Update scroll position: new = old + clamped delta
    STA $bg1ScrollH, X
    EOR $01, S            ; XOR old and new scroll positions to detect which bits changed
    BIT #$0010            ; Bit 4 = 16px tile alignment; if this bit flipped, camera crossed a metatile boundary
    BEQ loc_02AC95
    JSR $&UpdateScrollColumn ; Tile boundary crossed horizontally: render newly-visible column into staging buffer

  loc_02AC95:
    PLA 
    LDA $bg2ScrollH, X    ; Begin vertical scroll processing — same delta/clamp/XOR logic as horizontal
    PHA 
    LDA $cameraTargetY, X
    SEC 
    SBC $bg2ScrollH, X
    BPL loc_02ACAD
    CMP #$FFF0
    BCS loc_02ACB5
    LDA #$FFF0
    BRA loc_02ACB5

  loc_02ACAD:
    CMP #$0010            ; Clamp positive vertical delta to +16px maximum
    BCC loc_02ACB5
    LDA #$0010

  loc_02ACB5:
    STA $scrollDeltaYClamped, X ; Store clamped vertical delta
    CLC 
    ADC $bg2ScrollH, X
    STA $bg2ScrollH, X
    EOR $01, S
    BIT #$0010            ; Test vertical tile boundary crossing via XOR on bit 4
    BEQ loc_02ACC9
    JSR $&UpdateScrollRow ; Tile boundary crossed vertically: render newly-visible row into staging buffer

  loc_02ACC9:
    PLA 
    PLP 
    RTL 
}

---------------------------------------------
; Determines which horizontal row to render when vertical scrolling crosses a tile boundary.
; 
; Sets $18 to the current horizontal scroll (full X extent for the row). Computes the Y position of the newly-visible row based on scroll direction: if scrolling up (negative delta), uses −16 to get the top screen edge; if scrolling down (positive delta), uses +224 ($00E0) to get the bottom edge (14 tiles × 16px).
; 
; The Y position is added to the current vertical scroll and then wrapped against mapBoundsY via a subtraction loop to handle maps that wrap vertically.
; 
; Finally calls RenderScrollColumn to render that row of tiles into the staging buffer for V-Blank DMA.

UpdateScrollRow {
    LDA $bg1ScrollH, X    ; Copy current horizontal scroll to $18 (full X extent for the row being rendered)
    STA $18
    LDA #$FFF0            ; Default row offset = −16: top screen edge for upward scrolling
    LDY $scrollDeltaYClamped, X
    BMI loc_02ACDC
    LDA #$00E0            ; Scrolling down: use +$E0 (224px) offset for bottom screen edge

  loc_02ACDC:
    CLC 
    ADC $bg2ScrollH, X    ; Compute actual row Y = current vertical scroll + edge offset

  loc_02ACE0:
    STA $1C               ; Wrap Y against map height: subtract mapBoundsY until within valid range
    CMP $mapBoundsY, X
    BCC loc_02ACED
    SEC 
    SBC $mapBoundsY, X
    BRA loc_02ACE0

  loc_02ACED:
    JSR $&RenderScrollColumn ; Render the computed row position as a horizontal tilemap strip
    RTS 
}

---------------------------------------------
; Determines which vertical column to render when horizontal scrolling crosses a tile boundary.
; 
; Computes the X position of the newly-visible column based on scroll direction: if scrolling left (negative delta), uses offset 0 (left screen edge); if scrolling right (positive delta), uses +256 ($0100, one nametable width for the right edge).
; 
; Sets $18 = computed X position, $1C = current vertical scroll, then calls RenderScrollRow to render that column of tiles into the staging buffer.

UpdateScrollColumn {
    LDA #$0000            ; Default column offset = 0: left screen edge for leftward scrolling
    LDY $scrollDeltaXClamped, X
    BMI loc_02ACFC
    LDA #$0100            ; Scrolling right: use +$100 (256px = one nametable width) for right edge

  loc_02ACFC:
    CLC 
    ADC $bg1ScrollH, X    ; Compute column X = current horizontal scroll + edge offset
    STA $18
    LDA $bg2ScrollH, X
    STA $1C
    JSR $&RenderScrollRow ; Render the computed column as a vertical tilemap strip
    RTS 
}

---------------------------------------------
; Renders a horizontal row of metatiles into the tilemap staging buffer for V-Blank DMA.
; 
; Computes the map tile offset from Y position ($1C) using the map row stride and tilemap base address via SignedMultiply. Determines the VRAM tilemap address from the Y-aligned position, accounting for which 32×32 nametable half the position falls in.
; 
; Splits rendering into two passes when the row crosses the nametable boundary (X bit 8): assigns VRAM addresses to the staging buffer slots at $06B6+X, placing them in the correct nametable order.
; 
; Each pass calls FillHorizTilemapSeg to expand 16 metatile indices into VRAM-format 2×2 tile entries. After the first 16 tiles, advances the map index by one map row, wraps via WrapMapIndex, and renders the second half.
; 
; Operates in bank $7E (data bank set via PHB) for direct access to the map and staging buffers.

RenderScrollColumn {
    PHP 
    PHB 
    PHX 
    LDA $06AE, X          ; Load metatile definition table base pointer for this BG layer
    STA $02               ; Store tile def pointer at DP $02 for FillHorizTilemapSeg to reference
    SEP #$20              ; Switch to 8-bit A for byte-level map coordinate math
    LDA #$7E              ; Set data bank to $7E for direct WRAM map and staging buffer access
    PHA 
    PLB 
    LDA $1D               ; Load high byte of Y position ($1D = map page component)
    XBA 
    LDA $0693, X          ; Load map row stride low byte for this layer
    JSL $@hardware_math.SignedMultiply ; SignedMultiply: compute map page offset = Y_page × row_stride
    CLC 
    ADC $19               ; Add X position page component ($19 = high byte of $18)
    CLC 
    ADC $069F, X          ; Add tilemap column base offset for this layer
    XBA 
    LDA $1C               ; Load Y position low byte for row-within-page alignment
    AND #$F0              ; Mask to 16px boundary (AND #$F0) — clear sub-tile bits
    TAY 
    STY $04               ; Store combined map row/column index at DP $04 for WrapMapIndex
    REP #$20              ; Restore 16-bit A for VRAM address calculation
    JSR $&WrapMapIndex    ; Normalize map index within tilemap bounds
    LDA $1C
    AND #$00F0            ; Isolate Y row within 256-byte VRAM tilemap page (AND #$00F0)
    ASL                   ; ASL ×2: multiply by 4 for VRAM word addressing
    ASL 
    CLC 
    ADC $06BA, X          ; Add VRAM tilemap base address for this layer ($06BA+X)
    PHA 
    LDA $06B6, X          ; Load vertical strip staging buffer pointer for this layer ($06B6+X)
    TAX 
    LDA $18               ; Load X scroll position to determine nametable half
    BIT #$0100            ; Test bit 8: left nametable (0) vs right nametable (1)
    BNE loc_02AD5B
    PLA 
    STA $0000, X          ; Left half: store VRAM address into staging slot 0 (primary nametable)
    CLC 
    ADC #$0400            ; Second nametable is $400 VRAM words offset from first
    STA $0082, X          ; Store second nametable VRAM address at staging +$82
    BRA loc_02AD66

  loc_02AD5B:
    PLA 
    STA $0082, X          ; Right half: store VRAM address into staging slot 1 (nametable order swapped)
    CLC 
    ADC #$0400
    STA $0000, X          ; Secondary nametable address → staging slot 0 (swapped for right half)

  loc_02AD66:
    PHX 
    LDA #$0010            ; 16 metatiles = first half of visible horizontal row
    JSR $&FillHorizTilemapSeg ; Expand 16 metatile indices into VRAM tile entries for first half
    LDA $04               ; Load current map Y index to advance to second row section
    CLC 
    ADC #$0100            ; Add $100 to move to next 256-byte map section
    STA $04
    LDA $03, S            ; Peek at saved staging base pointer on stack for second pass setup
    TAX 
    LDA $04
    JSR $&WrapMapIndex    ; Wrap the advanced map index within tilemap bounds
    PLA 
    CLC 
    ADC #$0082            ; Advance staging pointer by $82 to second nametable slot
    TAX 
    LDA #$0010            ; 16 metatiles for second half of visible row
    JSR $&FillHorizTilemapSeg ; Expand second half of metatile indices into staging buffer
    PLX 
    PLB 
    PLP 
    RTS 
}

---------------------------------------------
; Wraps a map data index back within valid tilemap bounds.
; 
; Subtracts the tilemap base address ($069E+X) and row stride ($069A+X) from the current index. If the result is still positive (carry set), the index has overflowed past the end of the map data — the base is re-added and the check repeats in a loop until the index normalizes.
; 
; Stores the wrapped index to DP $04 and Y register. Called by both RenderScrollColumn and RenderScrollRow whenever map access indices might exceed the allocated tilemap region.

WrapMapIndex {
    SEC                   ; Subtract tilemap base address and row stride to normalize map index
    SBC $069E, X
    SEC 
    SBC $069A, X
    BCS loc_02AD98        ; Carry set = index overflowed past map bounds; needs wrapping
    RTS 

  loc_02AD98:
    CLC                   ; Re-add tilemap base to wrap around; store result and loop until normalized
    ADC $069E, X
    STA $0004
    TAY 
    BRA WrapMapIndex
}

---------------------------------------------
; Renders a vertical column of metatiles into the tilemap staging buffer for V-Blank DMA.
; 
; The most complex rendering routine. Computes the map data offset from tile coordinates using SignedMultiply for the Y component and shift/add for the X component. Handles left/right nametable halves (BIT $0020 on the tile X index) with different VRAM address assignments at $06B2+X staging slots.
; 
; For each nametable half, splits the column into two vertical segments when it crosses the map Y boundary:
; 1. First segment: from current Y position to either the bottom of the map or 16 tiles, whichever comes first
; 2. Second segment: wraps around to the top of the map for the remaining tiles
; 
; Each segment calls FillVertTilemapSeg to expand metatile indices into VRAM-format entries. After both nametable halves, handles the edge case of the last metatile row (checks for map wrapping on the final row boundary).
; 
; The staging buffer entries at $06B2+X contain VRAM destination addresses followed by tilemap data. The staging buffer uses two slots per layer for the two nametable halves.

RenderScrollRow {
    PHP 
    PHB 
    PHX 
    LDA $mapBoundsX, X    ; Load map width bound (mapBoundsX) for wrap calculations
    STA $1A               ; Store map width at DP $1A for boundary comparisons
    LDA $069A, X          ; Load map row stride (bytes per row in tilemap data)
    STA $08               ; Store row stride at DP $08 for wrap subtraction
    CLC 
    ADC $mapTilemapBaseA, X ; Compute upper bound = tilemap base address + row stride
    STA $1E               ; Store upper bound at DP $1E for boundary checks
    LDA $06AE, X          ; Load metatile definition table base pointer for this layer
    STA $02               ; Store tile def pointer at DP $02 for FillVertTilemapSeg lookups
    SEP #$20              ; Switch to 8-bit A for byte-level map coordinate math
    LDA #$7E              ; Set data bank to $7E for direct WRAM map data access
    PHA 
    PLB 
    LDA $1D               ; Load Y position page (high byte of $1C) for row page calculation
    XBA 
    LDA $1B               ; Load map width page (high byte of mapBoundsX)
    JSL $@hardware_math.SignedMultiply ; SignedMultiply: map page offset = Y_page × mapWidth_page
    CLC 
    ADC $19               ; Add X position page ($19 = high byte of $18)
    CLC 
    ADC $069F, X          ; Add tilemap column offset base for this layer ($069F+X)
    STA $05               ; Store complete column page index at DP $05
    LDA $1C               ; Load Y position low byte for metatile row index extraction
    LSR                   ; LSR ×4: divide by 16 to convert pixel Y → metatile row index
    LSR 
    LSR 
    LSR 
    XBA 
    LDA #$10              ; Map row width = 16 metatile entries
    JSL $@hardware_math.SignedMultiply ; SignedMultiply: row offset = metatile_row_index × 16
    STA $04               ; Store row offset in map data at DP $04
    LDA $18               ; Load X position low byte for metatile column index
    LSR                   ; LSR ×4: divide by 16 to convert pixel X → metatile column index
    LSR 
    LSR 
    LSR 
    CLC 
    ADC $04               ; Add column index to row offset = complete linear map data index
    STA $04               ; Store total map data index at DP $04
    REP #$20              ; Restore 16-bit A for VRAM address and staging buffer calculations
    LDA $04
    JSR $&WrapMapIndex    ; Normalize map data index within tilemap bounds via WrapMapIndex
    LDA $04
    STA $06               ; Save original map offset at DP $06 for edge-case wrapping check later
    LDA $06B2, X          ; Load horizontal strip staging buffer pointer for this layer ($06B2+X)
    PHA 
    LDA $18               ; Load X scroll position for nametable column determination
    LSR 
    LSR 
    LSR 
    AND #$003E            ; Mask to column index × 2 bytes (AND #$003E, range 0-62)
    BIT #$0020            ; Bit 5: determines left (0) or right (1) nametable half
    BNE loc_02AE58        ; Branch to right-half nametable VRAM address assignment
    CLC 
    ADC $06BA, X          ; Left half: add VRAM nametable base address for this layer
    PLX 
    STA $0000, X          ; Store VRAM column address in staging slot 0
    INC                   ; INC: adjacent VRAM column for right side of 2-wide metatile
    STA $0042, X          ; Store adjacent column VRAM address at staging +$42
    PHX 
    LDA $1C
    LSR 
    LSR 
    LSR 
    LSR 
    AND #$000F            ; Metatile Y offset within visible screen (AND #$000F, range 0-15)
    STA $10               ; Store split point at DP $10 — tiles from current Y to screen bottom
    ASL 
    ASL 
    CLC 
    ADC $01, S
    TAX 
    LDA #$0010            ; 16 total visible metatile rows in the column
    SEC 
    SBC $10               ; First segment count = 16 − Y_offset (tiles from current row to screen bottom)
    JSR $&FillVertTilemapSeg ; Fill first vertical segment of column with FillVertTilemapSeg
    PLY 
    LDA $10               ; Check if second segment needed (Y_offset > 0 means column wraps)
    BEQ loc_02AE56        ; Skip second segment if column starts at metatile row 0 (no wrap)
    TYX 
    LDA $04
    AND #$FF0F            ; Clear row bits from map offset (AND #$FF0F) — reset to row 0 of current column
    CLC 
    ADC $1A               ; Add map width to advance to next map row section
    CMP $1E               ; Check against tilemap upper bound for wrap detection
    BCC loc_02AE44
    SEC 
    SBC $08               ; Subtract row stride to wrap back within tilemap bounds

  loc_02AE44:
    STA $04
    TAY 
    PHX 
    LDA $03, S
    TAX 
    LDA $04
    JSR $&WrapMapIndex    ; Normalize wrapped map offset via WrapMapIndex
    PLX 
    LDA $10               ; Load remaining tile count for second segment
    JSR $&FillVertTilemapSeg ; Fill second vertical segment — tiles that wrap from bottom to top of map

  loc_02AE56:
    BRA loc_02AEB0

  loc_02AE58:
    AND #$001E            ; Right half: mask column index to even values (AND #$001E)
    CLC 
    ADC $06BA, X
    CLC 
    ADC #$0400            ; Add $400 for right-half nametable VRAM offset
    PLX 
    STA $0000, X          ; Store right-half VRAM address in staging slot 0
    CLC 
    ADC #$0001            ; Adjacent column address for right side of metatile
    STA $0042, X          ; Store adjacent VRAM address at staging +$42
    PHX 
    LDA $1C
    LSR 
    LSR 
    LSR 
    LSR 
    AND #$000F
    STA $10
    ASL 
    ASL 
    CLC 
    ADC $01, S
    TAX 
    LDA #$0010
    SEC 
    SBC $10
    JSR $&FillVertTilemapSeg
    PLY 
    LDA $10
    BEQ loc_02AEB0
    TYX 
    LDA $04
    AND #$FF0F
    CLC 
    ADC $1A
    CMP $1E
    BCC loc_02AE9E
    SEC 
    SBC $08

  loc_02AE9E:
    STA $04
    TAY 
    PHX 
    LDA $03, S
    TAX 
    LDA $04
    JSR $&WrapMapIndex
    PLX 
    LDA $10
    JSR $&FillVertTilemapSeg

  loc_02AEB0:
    TXA                   ; === Edge tile handling: render the preceding metatile row for seamless scrolling ===
    SEC 
    SBC #$0004            ; Back up staging pointer by 4 bytes (one metatile entry width)
    TAX 
    LDA $06               ; Load original map offset saved at DP $06
    BIT #$00F0            ; Test Y row offset bits — zero means at top of map section boundary
    BNE loc_02AED7        ; Non-zero row: skip to normal preceding-row calculation
    SEC 
    SBC $1A               ; At row 0 boundary: subtract map width to reach previous map section
    CLC 
    ADC #$00F0            ; Add $F0 to index the bottom row of the previous section
    STA $04
    PHX 
    LDA $03, S
    TAX 
    LDA $04
    CMP $069E, X          ; Check if computed offset is before tilemap start address
    BMI loc_02AED4        ; Negative (before tilemap): skip edge tile rendering entirely
    PLX 
    BRA loc_02AEDD

  loc_02AED4:
    PLX 
    BRA loc_02AEED

  loc_02AED7:
    SEC 
    SBC #$0010            ; Subtract $10 (one map row of 16 entries) to get the preceding row
    STA $04

  loc_02AEDD:
    PHX 
    LDA $03, S
    TAX 
    LDA $04
    JSR $&WrapMapIndex
    PLX 
    LDA #$0001            ; Render just 1 edge metatile for seamless visual continuity
    JSR $&FillVertTilemapSeg ; Fill single edge tile via FillVertTilemapSeg

  loc_02AEED:
    PLX 
    PLB 
    PLP 
    RTS 
}

---------------------------------------------
; Inner loop that expands metatile indices into VRAM tilemap entries for a horizontal strip.
; 
; Reads $0E consecutive metatile index bytes from map data (pointed to by Y=$04). For each byte: masks to 8 bits, multiplies by 8 (ASL ×3) to index into the tile definition table at $02+offset. Copies 4 words (8 bytes) from the tile definition — the four 8×8 tile entries that compose one 16×16 metatile — into the staging buffer:
; - Words 0,1 → buffer+$02/+$04 (top-left, top-right)
; - Words 2,3 → buffer+$42/+$44 (bottom-left, bottom-right)
; 
; The +$42 offset places the bottom row exactly one VRAM tilemap row (32 entries × 2 bytes = 64 bytes = $40) below the top row. X advances by 4 bytes (2 entries) per metatile.

FillHorizTilemapSeg {
    LDY $04               ; Load map data source pointer from DP $04 into Y for indexed reads
    STA $0E               ; Store A (metatile count) as loop counter at DP $0E

  loc_02AEF5:
    LDA $0000, Y          ; Read metatile index byte from map data in bank $7E
    PHY                   ; Save map data pointer Y on stack for next iteration
    AND #$00FF            ; Mask to 8-bit index (AND #$00FF) — metatile indices are single bytes
    ASL                   ; ASL ×3: multiply index by 8 (each metatile def = 4 tile words = 8 bytes)
    ASL 
    ASL 
    CLC 
    ADC $02               ; Add tile definition table base (DP $02) to get this metatile's address
    TAY 
    LDA $0000, Y          ; Load tile word 0: top-left 8×8 tile (tile#, palette, flip flags)
    STA $0002, X          ; Write top-left tile to staging buffer at +$02
    LDA $0002, Y          ; Load tile word 1: top-right 8×8 tile
    STA $0004, X          ; Write top-right tile to staging +$04
    LDA $0004, Y          ; Load tile word 2: bottom-left 8×8 tile
    STA $0042, X          ; Write bottom-left at +$42 (one VRAM tilemap row = $40 bytes below top-left)
    LDA $0006, Y          ; Load tile word 3: bottom-right 8×8 tile
    STA $0044, X          ; Write bottom-right at +$44 ($40 below top-right)
    INX                   ; Advance staging pointer by 4 bytes (2 VRAM entries = one metatile width)
    INX 
    INX 
    INX 
    PLY                   ; Restore map data pointer from stack
    INY                   ; Advance to next consecutive metatile in map row
    DEC $0E               ; Decrement metatile counter
    BNE loc_02AEF5        ; Loop until all metatiles in this horizontal segment are processed
    RTS 
}

---------------------------------------------
; Inner loop that expands metatile indices into VRAM tilemap entries for a vertical strip.
; 
; Reads $0E consecutive metatile index bytes from map data, advancing the source Y pointer by $10 (16 bytes = one map row) per iteration to traverse vertically through the map.
; 
; For each metatile byte: masks to 8 bits, multiplies by 8 to index the tile definition table. Copies 4 tile entries to the staging buffer in a column-oriented layout:
; - Words 0,2 → buffer+$02/+$04 (left column, top and bottom)
; - Words 1,3 → buffer+$44/+$46 (right column, top and bottom)
; 
; The +$44 offset places the right column one VRAM tilemap row plus one entry to the right. X advances by 4 bytes per metatile vertically.

FillVertTilemapSeg {
    LDY $04               ; Load map data source pointer from DP $04 into Y
    STA $0E               ; Store A (metatile count) as loop counter at DP $0E

  loc_02AF2A:
    LDA $0000, Y          ; Read metatile index byte from map data in bank $7E
    PHY                   ; Save map pointer via PHY; will recover with PLA for vertical row advance
    AND #$00FF            ; Mask to 8-bit metatile index (AND #$00FF)
    ASL                   ; ASL ×3: multiply by 8 to index into tile definition table
    ASL 
    ASL 
    CLC 
    ADC $02               ; Add tile definition table base pointer (DP $02)
    TAY 
    LDA $0000, Y          ; Load tile word 0: left column, upper half of metatile
    STA $0002, X          ; Write left-upper tile to staging buffer +$02
    LDA $0002, Y          ; Load tile word 1: right column, upper half
    STA $0044, X          ; Write right-upper at staging +$44 (next VRAM row + one column right)
    LDA $0004, Y          ; Load tile word 2: left column, lower half
    STA $0004, X          ; Write left-lower to staging +$04 (below left-upper in staging layout)
    LDA $0006, Y          ; Load tile word 3: right column, lower half
    STA $0046, X          ; Write right-lower at staging +$46 (next VRAM row + one column right of lower)
    INX                   ; Advance staging pointer by 4 bytes per metatile row
    INX 
    INX 
    INX 
    PLA                   ; PLA: recover saved map pointer into A (was pushed as Y via PHY)
    CLC 
    ADC #$0010            ; Add $10 (16 bytes = one map row) to advance vertically through map data
    TAY                   ; Transfer updated map pointer back to Y for next iteration
    DEC $0E               ; Decrement metatile counter
    BNE loc_02AF2A        ; Loop until all metatiles in this vertical segment are processed
    RTS 
}

---------------------------------------------
; V-Blank routine that DMA-transfers all staged tilemap strips to VRAM.
; 
; Called during the NMI handler after scroll updates have been computed. Sets up common DMA registers: VMAIN=$81 (word-access, 32-word increment for column-mode), DMAP0=$01 (two-register), source bank=$7E.
; 
; Processes four staging buffer slots in order:
; 1. Horizontal strip 0 ($06B2): DMA via DmaHorizontalStrip — row update for layer 0
; 2. Horizontal strip 1 ($06B4): DMA via DmaHorizontalStrip — row update for layer 1
; 3. Vertical strip 0 ($06B6): DMA via DmaVerticalStrip — column update for layer 0 (VMAIN switched to $80 for sequential access)
; 4. Vertical strip 1 ($06B8): DMA via DmaVerticalStrip — column update for layer 1
; 
; Each slot is skipped (BEQ) if its VRAM address word is zero (no pending update). After all transfers, clears all four staging buffer VRAM address words and the related staging areas to prevent re-triggering.

FlushDirtyTilemapStrips {
    PHP 
    SEP #$20              ; Switch to 8-bit A for DMA register configuration
    LDA #$81              ; VMAIN=$81: word-access VRAM with 32-word auto-increment for horizontal strips
    STA $VMAIN
    LDA #$01
    STA $DMAP0
    LDA #$18
    STA $BBAD0
    LDA #$7E
    STA $A1B0
    REP #$20
    LDX $06B2             ; Check and DMA horizontal strip 0 ($06B2) — row update for BG layer 0
    LDA $7E0000, X
    TAY 
    BEQ loc_02AF85
    JSR $&DmaHorizontalStrip

  loc_02AF85:
    LDX $06B4             ; Check and DMA horizontal strip 1 ($06B4) — row update for BG layer 1
    LDA $7E0000, X
    TAY 
    BEQ loc_02AF92
    JSR $&DmaHorizontalStrip

  loc_02AF92:
    LDA #$0080            ; Switch VMAIN to $80: word-access with sequential increment for vertical strips
    STA $VMAIN
    LDX $06B6             ; Check and DMA vertical strip 0 ($06B6) — column update for BG layer 0
    LDA $7E0000, X
    TAY 
    BEQ loc_02AFA5
    JSR $&DmaVerticalStrip

  loc_02AFA5:
    LDX $06B8             ; Check and DMA vertical strip 1 ($06B8) — column update for BG layer 1
    LDA $7E0000, X
    TAY 
    BEQ loc_02AFB2
    JSR $&DmaVerticalStrip

  loc_02AFB2:
    LDA #$0000            ; Clear all four staging buffer VRAM addresses to prevent stale re-triggering next frame
    STA $tilemapStaging
    STA $7E3288
    STA $7E3184
    STA $7E330C
    PLP 
    RTL 
}

---------------------------------------------
; Transfers one horizontal tilemap strip (row) from the staging buffer to VRAM via DMA.
; 
; The staging buffer layout for each strip: [VRAM_addr:u16, data:64_bytes, VRAM_addr:u16, data:64_bytes]. Each half represents one 32×32 nametable.
; 
; First DMA: Sets VMADDL to the first VRAM address (from Y parameter), sets A1T0L to the staging data pointer (X+2), transfers $40 bytes (64 bytes = 32 tilemap entries = one metatile row).
; 
; Second DMA: Advances the source pointer by $40 bytes to the second nametable half, reads its VRAM address, and transfers another $40 bytes.
; 
; The two transfers cover both nametable halves of a horizontal row.

DmaHorizontalStrip {
    PHP 
    SEP #$20
    INX                   ; Skip past 2-byte VRAM destination address word to reach tilemap data in staging buffer
    INX 
    PHX 
    STY $VMADDL           ; Set VRAM destination address from the staging buffer header word
    STX $A1T0L
    LDA #$40              ; $40 = 64 bytes = 32 tilemap entries = one complete metatile row in VRAM
    STA $DAS0L
    LDA #$01
    STA $MDMAEN
    REP #$20
    PLA 
    CLC 
    ADC #$0040            ; Advance source pointer by $40 bytes to second nametable half of the row
    TAX 
    LDA $7E0000, X        ; Load VRAM destination address for second 32×32 nametable
    TAY 
    INX 
    INX 
    SEP #$20
    STY $VMADDL
    STX $A1T0L
    LDA #$40
    STA $DAS0L
    LDA #$01
    STA $MDMAEN
    PLP 
    RTS 
}

---------------------------------------------
; Transfers one vertical tilemap strip (column) from the staging buffer to VRAM via DMA.
; 
; Similar structure to DmaHorizontalStrip but transfers $80 bytes (128 bytes = 64 tilemap entries) per nametable half. The larger size covers a full column height (32 rows × 2 entries per metatile row = 64 entries).
; 
; VMAIN must be set to $80 (word-access, increment by 1) by the caller — unlike horizontal strips which use column-mode increment. The second nametable half is at source+$80.

DmaVerticalStrip {
    PHP 
    SEP #$20
    INX 
    INX 
    PHX 
    STY $VMADDL
    STX $A1T0L
    LDA #$80              ; $80 = 128 bytes = 64 tilemap entries = full column height across both nametable halves
    STA $DAS0L
    LDA #$01
    STA $MDMAEN
    REP #$20
    PLA 
    CLC 
    ADC #$0080            ; Advance source by $80 bytes to second nametable half of the column
    TAX 
    LDA $7E0000, X
    STA $VMADDL
    INX 
    INX 
    SEP #$20
    STX $A1T0L
    LDA #$80
    STA $DAS0L
    LDA #$01
    STA $MDMAEN
    PLP 
    RTS 
}

---------------------------------------------
; Transfers sprite tile graphics from WRAM to VRAM during V-Blank.
; 
; First checks $09ED bit 7 — if set, sprite DMA is globally suppressed (returns immediately). Then checks displayModeFlags ($09EC) for bits $31 — if none are set, no sprite update is needed.
; 
; Three transfer modes based on flag bits:
; 1. Bit 0 (full update): Transfers $0800 bytes (2048 = 128 complete 8×8 tiles) from WRAM $7F0200 to VRAM $7800. Used for character form changes (Will → Freedan → Shadow).
; 2. Bits 4-5 (partial update): Transfers $0140 bytes (320 = 40 tiles) from WRAM $7F0280 to VRAM $7840. Used for animation frame updates. If bit 5 is set, it's a single-shot transfer — the flag is cleared after DMA.
; 
; After transfer, clears the request flags (bits 0,4,5 via TRB with $31) to prevent re-triggering. Sets VMAIN=$80, DMAP0=$01, BBAD0=$18, source bank=$7F, then triggers DMA channel 0.

SpriteVramDma {
    LDA $09ED             ; Check $09ED bit 7 — if set, sprite VRAM DMA is globally suppressed
    BPL loc_02B03E
    RTL 

  loc_02B03E:
    LDA $displayModeFlags ; Check displayModeFlags bits 0/4/5 ($31 mask) — any set triggers sprite tile DMA
    BIT #$31
    BNE loc_02B046
    RTL 

  loc_02B046:
    BIT #$01              ; Bit 0 = full sprite tileset transfer mode (character form change)
    BEQ loc_02B05E
    LDX #$0800            ; $0800 = 2048 bytes = 128 complete 8×8 tiles for full character sprite set
    STX $DAS0L
    LDX #$7800            ; VRAM $7800 = sprite character tile destination (upper sprite page)
    STX $VMADDL
    LDX #$0200            ; Source $7F0200 = sprite tileset staging area in extended WRAM
    STX $A1T0L
    BRA loc_02B084

  loc_02B05E:
    LDA $displayModeFlags ; Bits 4-5: partial sprite tile update modes (animation frame updates)
    BIT #$20
    BNE loc_02B06D
    LDX #$0140            ; $0140 = 320 bytes = 40 tiles for partial sprite animation update
    STX $DAS0L
    BRA loc_02B078

  loc_02B06D:
    AND #$DF              ; Bit 5 special: clear flag after DMA for single-shot extended partial transfer
    STA $displayModeFlags
    LDX #$0140
    STX $DAS0L

  loc_02B078:
    LDX #$7840            ; VRAM $7840 = sprite animation tile area (offset within sprite tile page)
    STX $VMADDL
    LDX #$0280            ; Source $7F0280 = animation tile staging area in extended WRAM
    STX $A1T0L

  loc_02B084:
    LDA #$31              ; Clear sprite DMA request flags (bits 0,4,5) via TRB to prevent re-triggering
    TRB $displayModeFlags
    LDA #$80              ; VMAIN=$80: standard word-access VRAM with sequential auto-increment
    STA $VMAIN
    LDA #$01
    STA $DMAP0
    LDA #$18
    STA $BBAD0
    LDA #$7F              ; Source bank $7F = extended WRAM (second 64KB bank for sprite staging)
    STA $A1B0
    LDA #$01
    STA $MDMAEN           ; Trigger DMA channel 0 to execute the sprite tile VRAM transfer
    RTL 
}