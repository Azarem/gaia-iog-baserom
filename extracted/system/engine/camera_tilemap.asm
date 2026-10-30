; Camera tilemap rendering, VRAM DMA transfer, and scroll stripe management (Bank 02).
; 
; Implements the complete pipeline for updating SNES background layer tilemaps in response to camera scrolling. The system manages two BG layers (indexed by X=0 for layer 0, X=2 for layer 1) with independent scroll positions, using four staging buffers from $7E3100 (a column strip and a row strip per layer; initial pointers $06B2/$06B4 = column strips, $06B6/$06B8 = row strips, set by system_init) to prepare tilemap data for DMA transfer during V-Blank.
; 
; Naming: RenderColumnStrip, DmaColumnStrip and the $06B2/$06B4 buffers deal with COLUMN strips (a vertical run of 16 metatiles, DMA'd with VRAM increment 32), while RenderRowStrip, DmaRowStrip and the $06B6/$06B8 buffers deal with ROW strips. UpdateScrollRow/UpdateScrollColumn and the Fill*TilemapSeg routines use the geometric meaning, so the two vocabularies meet inside this file.
; 
; Two primary modes:
; - CameraFullRefresh: Redraws the whole 64-tile-wide tilemap of one layer: wraps the camera target into the map bounds, then renders 32 metatile columns 16px apart via RenderColumnStrip and immediately DMA-transfers each one to VRAM. Called on scene load.
; - CameraSmoothScroll: Per-frame incremental scroll. Deltas are clamped to ±16px per frame for smooth motion. When scrolling crosses a 16px tile boundary (detected by XOR of old/new positions on bit 4), the newly-visible row or column is rendered into the staging buffer for DMA during V-Blank.
; 
; The rendering pipeline (RenderColumnStrip, RenderRowStrip) converts map tile indices to 2×2 VRAM tilemap entries (16×16 metatiles → four 8×8 tiles), handles nametable wrapping via WrapMapIndex, and writes to the staging buffer. FillHorizTilemapSeg and FillVertTilemapSeg are the inner loops that expand metatile indices into VRAM-format tilemap words.
; 
; FlushDirtyTilemapStrips is called during V-Blank (NMI) to DMA any staged horizontal and vertical strips to VRAM using DmaColumnStrip (column strips: two 64-byte tile columns) and DmaRowStrip (row strips: two 128-byte halves, one per nametable).
; 
; Bg3TilemapVramDma uploads the BG3 tilemap staging buffer at $7F0200 (bg3TilemapBuffer, used by the console string renderer) to the BG3 tilemap at VRAM $7800 during V-Blank: a full transfer ($0800 bytes = the whole 32×32 map, displayModeFlags bit 0) or a partial one ($0140 bytes = five tile rows starting at row 2, bits 4/5). BG3SC is initialised to $78, which places the BG3 tilemap at $7800.
---------------------------------------------

?BANK 02

?INCLUDE 'hardware_math'
?INCLUDE 'system_init'

!bg1ScrollH                     068A
!effectScrollH                  068C
!mapScrollV                     068E
!effectScrollV                  0690
!mapBoundsX                     0692
!mapBoundsY                     0696
!mapTilemapBaseA                069E
!metatileDefBase                06AE
!colStripStagingPtr             06B2
!rowStripStagingPtr             06B6
!cameraTargetX                  06BE
!cameraDeltaX                   06C0
!cameraTargetY                  06C2
!cameraDeltaY                   06C4
!scrollDeltaXClamped            06CE
!scrollDeltaYClamped            06D2
!layerPriorityFlag              06EE
!scrollModeFlags                06EF
!displayModeFlags               09EC
!hudDisableFlag                 09ED
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
; Wraps camera target positions into the map bounds with a bitmask (AND with bounds−1; an exact modulo only when the bound is a power of two). Copies the wrapped positions to the BG scroll registers ($068A+X for horizontal, $068E+X for vertical) and aligns to the 16px tile grid for rendering origin.
; 
; Sets up VRAM DMA registers: VMAIN=$81 (word-access, column-mode auto-increment), DMAP0=$01 (two-register), BBAD0=$18 (VRAM data port), source bank=$7E.
; 
; Iterates 32 metatile columns (32 × 16px = 512px, the full two-nametable width): for each column, calls RenderColumnStrip to build a 16-metatile vertical strip in the column staging buffer, then immediately DMA-transfers it via DmaColumnStrip. After each column, advances the X position ($18) by 16px and wraps it against the map width.
; 
; After all columns are rendered, clears the four staging buffer VRAM address words to prevent re-triggering, then calls UploadCgramPalette to sync the color palette.
; 
; Called during scene loading and major camera repositioning where the entire tilemap must be rebuilt.

CameraFullRefresh {
    PHP                   ; Save flags; routine uses mixed 8/16-bit modes for VRAM register setup and map math
    REP #$20
    LDA $cameraTargetX, X ; Load camera target X position for this BG layer (X = 0 or 2 selects layer)
    CMP $mapBoundsX, X    ; Target at or beyond the map width bound is wrapped below (AND with width−1)
    BCC loc_02ABA3
    LDA $mapBoundsX, X
    DEC                   ; Create bitmask (bounds−1) for AND-based position wrap (exact only for power-of-two bounds)
    STA $00
    LDA $cameraTargetX, X
    AND $00
    STA $cameraTargetX, X

  loc_02ABA3:
    STA $bg1ScrollH, X    ; Copy wrapped X to BG horizontal scroll register ($068A+X)
    AND #$FFF0            ; Align to 16px metatile grid — tilemap rendering operates on 16×16 granularity
    STA $18
    LDA $cameraTargetY, X ; Load camera target Y for vertical bounds check (negative values are left unchanged)
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
    STA $mapScrollV, X    ; Copy wrapped Y to BG vertical scroll register ($068E+X)
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
    LDA #$0020            ; Loop counter = 32 columns × 16px = 512px: the full two-nametable width of the layer

  loc_02ABE6:
    PHA                   ; === Column loop: one 16px-wide metatile column per iteration (32×) ===
    JSR $&RenderColumnStrip ; Render one metatile column (16 metatiles tall) at X=$18 into the column staging buffer ($06B2+X)
    PHX 
    LDA $colStripStagingPtr, X
    TAX 
    LDA $7E0000, X
    TAY 
    JSR $&DmaColumnStrip  ; DMA the rendered column to VRAM right away (two tile columns, VRAM +32 per word); runs from scene load, not NMI
    PLX 
    LDA $18
    CLC 
    ADC #$0010            ; Advance rendering position by 16px (one metatile column width)
    CMP $mapBoundsX, X    ; Check if position has passed map width bound; wrap if needed
    BCC loc_02AC0F
    AND #$0100
    CMP $mapBoundsX, X
    BCC loc_02AC0F
    SEC 
    SBC $mapBoundsX, X

  loc_02AC0F:
    STA $18               ; Store wrapped column X position; continue loop
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
; 1. Direct mode (scrollModeFlags bit 3, i.e. $06EF bit 3): Copies camera targets directly to scroll registers without any smoothing, delta clamping or strip rendering.
; 2. Layer 1 delta mode (X≠0 and bit $0400 of the word at layerPriorityFlag/$06EE, i.e. $06EF bit 2): Copies cameraDeltaX/Y ($06C0/$06C4) straight into effectScrollH/V ($068C/$0690), so the second layer's scroll follows the camera delta instead of its own target. No strips are rendered.
; 3. Normal smooth scroll: For each axis (X then Y):
;    a. Computes delta = target − current scroll position
;    b. Clamps delta to ±16px maximum per frame for smooth motion
;    c. Stores clamped delta (scrollDeltaXClamped/scrollDeltaYClamped)
;    d. Applies delta to update the scroll position
;    e. XORs old and new positions and tests bit 4 — if this bit changed, the camera crossed a 16px tile boundary
;    f. On boundary crossing: calls UpdateScrollColumn (for X) or UpdateScrollRow (for Y) to render the newly-visible tile strip into the staging buffer
; 
; Because the delta is at most ±16px, bit 4 of the position changes at most once per frame, so at most one new column and one new row are rendered per layer per frame.

CameraSmoothScroll {
    PHP 
    REP #$20
    LDA $scrollModeFlags  ; Test scrollModeFlags bit 3: direct scroll mode bypasses delta clamping entirely
    BIT #$0008
    BEQ loc_02AC47
    LDA $cameraTargetX, X ; Direct mode: copy camera targets straight to scroll position registers (no smoothing)
    STA $bg1ScrollH, X
    LDA $cameraTargetY, X
    STA $mapScrollV, X
    PLP 
    RTL 

  loc_02AC47:
    CPX #$0000            ; Only the second layer (X≠0) can use delta mode (needs $06EF bit 2 set)
    BEQ loc_02AC62
    LDA $layerPriorityFlag
    BIT #$0400
    BEQ loc_02AC62
    LDA $cameraDeltaX     ; Layer 1 delta mode: effectScrollH/V = cameraDeltaX/Y (no target tracking)
    STA $effectScrollH
    LDA $cameraDeltaY
    STA $effectScrollV
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
    LDA $mapScrollV, X    ; Begin vertical scroll processing — same delta/clamp/XOR logic as horizontal
    PHA 
    LDA $cameraTargetY, X
    SEC 
    SBC $mapScrollV, X
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
    ADC $mapScrollV, X
    STA $mapScrollV, X
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
; Finally calls RenderRowStrip to render that row of tiles into the staging buffer for V-Blank DMA.

UpdateScrollRow {
    LDA $bg1ScrollH, X    ; Copy current horizontal scroll to $18 (full X extent for the row being rendered)
    STA $18
    LDA #$FFF0            ; Default row offset = −16: top screen edge for upward scrolling
    LDY $scrollDeltaYClamped, X
    BMI loc_02ACDC
    LDA #$00E0            ; Scrolling down: use +$E0 (224px) offset for bottom screen edge

  loc_02ACDC:
    CLC 
    ADC $mapScrollV, X    ; Compute actual row Y = current vertical scroll + edge offset

  loc_02ACE0:
    STA $1C               ; Wrap Y against map height: subtract mapBoundsY until within valid range
    CMP $mapBoundsY, X
    BCC loc_02ACED
    SEC 
    SBC $mapBoundsY, X
    BRA loc_02ACE0

  loc_02ACED:
    JSR $&RenderRowStrip  ; Render the computed row position as a horizontal tilemap strip
    RTS 
}

---------------------------------------------
; Determines which vertical column to render when horizontal scrolling crosses a tile boundary.
; 
; Computes the X position of the newly-visible column based on scroll direction: if scrolling left (negative delta), uses offset 0 (left screen edge); if scrolling right (positive delta), uses +256 ($0100, the screen width) for the right edge.
; 
; Sets $18 = computed X position, $1C = current vertical scroll, then calls RenderColumnStrip to render that column of tiles into the staging buffer.

UpdateScrollColumn {
    LDA #$0000            ; Default column offset = 0: left screen edge for leftward scrolling
    LDY $scrollDeltaXClamped, X
    BMI loc_02ACFC
    LDA #$0100            ; Scrolling right: use +$100 (256px = screen width) for right edge

  loc_02ACFC:
    CLC 
    ADC $bg1ScrollH, X    ; Compute column X = current horizontal scroll + edge offset
    STA $18
    LDA $mapScrollV, X
    STA $1C
    JSR $&RenderColumnStrip ; Render the computed column as a vertical tilemap strip
    RTS 
}

---------------------------------------------
; Renders one ROW strip (a horizontal run of 32 metatiles = 512px, two 256px map pages) into the row staging buffer ($06B6+X) for V-Blank DMA (DmaRowStrip).
; 
; Computes the map data offset from the Y position ($1C/$1D) using the map width in pages ($0693+X, the high byte of mapBoundsX) and the tilemap base address via Multiply8x8Unsigned. The strip always starts at the left edge of a map page: the Y metatile row (×64 VRAM words) selects the VRAM row, and bit 8 of X ($18) selects which nametable receives the first page.
; 
; Always makes two passes: each calls FillHorizTilemapSeg to expand 16 metatile indices (one map page) into VRAM-format 2×2 tile entries. Between the passes the map index advances one page (+$100) and is wrapped via WrapMapIndex. The two passes use staging slot 0 and the slot at +$82, with their VRAM addresses ordered by the nametable bit.
; 
; Operates in bank $7E (data bank set via PHB) for direct access to the map and staging buffers.

RenderRowStrip {
    PHP 
    PHB 
    PHX 
    LDA $metatileDefBase, X ; Load metatile definition table base pointer for this BG layer
    STA $02               ; Store tile def pointer at DP $02 for FillHorizTilemapSeg to reference
    SEP #$20              ; Switch to 8-bit A for byte-level map coordinate math
    LDA #$7E              ; Set data bank to $7E for direct WRAM map and staging buffer access
    PHA 
    PLB 
    LDA $1D               ; Load high byte of Y position ($1D = map page component)
    XBA 
    LDA $0693, X          ; Load map width in 256px pages for this layer ($0693+X = high byte of mapBoundsX)
    JSL $@hardware_math.Multiply8x8Unsigned ; Multiply8x8Unsigned: compute map page offset = Y_page × map width in pages
    CLC 
    ADC $19               ; Add X position page component ($19 = high byte of $18)
    CLC 
    ADC $069F, X          ; Add the layer's map data base page ($069F = high byte of mapTilemapBaseA)
    XBA 
    LDA $1C               ; Load Y position low byte for row-within-page alignment
    AND #$F0              ; Mask to 16px boundary (AND #$F0) — clear sub-tile bits
    TAY 
    STY $04               ; Store combined map row/column index at DP $04 for WrapMapIndex
    REP #$20              ; Restore 16-bit A for VRAM address calculation
    JSR $&WrapMapIndex    ; Normalize map index within tilemap bounds
    LDA $1C
    AND #$00F0            ; Y metatile row within the page (AND #$00F0); ×4 below = ×64 VRAM words per metatile row (2 tile rows × 32)
    ASL                   ; ASL ×2: multiply by 4 for VRAM word addressing
    ASL 
    CLC 
    ADC $06BA, X          ; Add VRAM tilemap base address for this layer ($06BA+X)
    PHA 
    LDA $06B6, X          ; Load row strip staging buffer pointer for this layer ($06B6+X)
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
    LDA #$0010            ; 16 metatiles = first 256px map page of the row strip
    JSR $&FillHorizTilemapSeg ; Expand 16 metatile indices into VRAM tile entries for first half
    LDA $04               ; Load current map index; +$100 below advances to the next page to the right
    CLC 
    ADC #$0100            ; Add $100: next 256-byte map page (the page to the right)
    STA $04
    LDA $03, S            ; Peek at saved staging base pointer on stack for second pass setup
    TAX 
    LDA $04
    JSR $&WrapMapIndex    ; Wrap the advanced map index within tilemap bounds
    PLA 
    CLC 
    ADC #$0082            ; Advance staging pointer by $82 to second nametable slot
    TAX 
    LDA #$0010            ; 16 metatiles for the second map page of the row strip
    JSR $&FillHorizTilemapSeg ; Expand second half of metatile indices into staging buffer
    PLX 
    PLB 
    PLP 
    RTS 
}

---------------------------------------------
; Wraps a map data index back within valid tilemap bounds.
; 
; Subtracts the tilemap base address ($069E+X) and the map data size ($069A+X; the wrap modulus: the number of map data bytes, measured equal to map width / 16 x map height / 16 in every scene) from the current index. If no borrow occurs (carry set), the index has overflowed past the end of the map data — the base is re-added, leaving index − size, and the check repeats until the index normalizes.
; 
; Stores the wrapped index to DP $04 and Y register. Called by both RenderRowStrip and RenderColumnStrip whenever map access indices might exceed the allocated tilemap region.

WrapMapIndex {
    SEC                   ; Subtract tilemap base address and map data size to test for overflow
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
; Renders one COLUMN strip (a vertical run of 16 metatiles = 256px, one tile-column pair) into the column staging buffer ($06B2+X) for V-Blank DMA (DmaColumnStrip).
; 
; The most complex rendering routine. Computes the map data index from the pixel position: page = Y_page × map width in pages (Multiply8x8Unsigned) + X_page + base page, then metatile row ×16 + metatile column within the page. The tile column (X >> 3, forced even) is the VRAM word offset in the 64-wide ring; bit 5 of it selects the left or right nametable, which changes only the VRAM address ($400 higher for the right one).
; 
; The strip is filled in VRAM order (buffer row = VRAM metatile row), starting at the current Y row, in up to two segments:
; 1. First segment: 16 − Y_row metatiles, from the current row to the bottom of the map page
; 2. Second segment (only if Y_row > 0): the remaining Y_row metatiles from the top of the next page row (map width bytes further, wrapped at the map data end)
; 
; Each segment calls FillVertTilemapSeg to expand metatile indices into VRAM-format entries. Finally an edge-tile step overwrites the last slot with the metatile row just above the strip start (same VRAM ring row), stepping back a page row when the start row is 0 (inferred from the arithmetic; not runtime-verified).
; 
; The buffer holds two tile columns: [VRAM addr][32 words] at +0 and [VRAM addr+1][32 words] at +$42 (the right tile column of each 2-wide metatile).

RenderColumnStrip {
    PHP 
    PHB 
    PHX 
    LDA $mapBoundsX, X    ; Load map width bound (mapBoundsX) for wrap calculations
    STA $1A               ; Store map width at DP $1A for boundary comparisons
    LDA $069A, X          ; Load map data size ($069A+X; wrap modulus, equals map width / 16 x map height / 16)
    STA $08               ; Store map data size at DP $08 for wrap subtraction
    CLC 
    ADC $mapTilemapBaseA, X ; Compute upper bound = tilemap base address + map data size
    STA $1E               ; Store upper bound at DP $1E for boundary checks
    LDA $metatileDefBase, X ; Load metatile definition table base pointer for this layer
    STA $02               ; Store tile def pointer at DP $02 for FillVertTilemapSeg lookups
    SEP #$20              ; Switch to 8-bit A for byte-level map coordinate math
    LDA #$7E              ; Set data bank to $7E for direct WRAM map data access
    PHA 
    PLB 
    LDA $1D               ; Load Y position page (high byte of $1C) for row page calculation
    XBA 
    LDA $1B               ; Load map width page (high byte of mapBoundsX)
    JSL $@hardware_math.Multiply8x8Unsigned ; Multiply8x8Unsigned: map page offset = Y_page × mapWidth_page
    CLC 
    ADC $19               ; Add X position page ($19 = high byte of $18)
    CLC 
    ADC $069F, X          ; Add the layer's map data base page ($069F+X = high byte of mapTilemapBaseA)
    STA $05               ; Store complete column page index at DP $05
    LDA $1C               ; Load Y position low byte for metatile row index extraction
    LSR                   ; LSR ×4: divide by 16 to convert pixel Y → metatile row index
    LSR 
    LSR 
    LSR 
    XBA 
    LDA #$10              ; Each map page is 16 metatiles wide
    JSL $@hardware_math.Multiply8x8Unsigned ; Multiply8x8Unsigned: row offset = metatile_row_index × 16
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
    LDA $06B2, X          ; Load column strip staging buffer pointer for this layer ($06B2+X)
    PHA 
    LDA $18               ; Load X scroll position for nametable column determination
    LSR 
    LSR 
    LSR 
    AND #$003E            ; Tile column (X >> 3) forced even = VRAM word offset in the 64-wide ring (range 0-62)
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
    AND #$000F            ; Metatile row within the 256px map page (0-15) = first VRAM ring row of the strip
    STA $10               ; Store at DP $10: also the size of the wrapped second segment
    ASL 
    ASL 
    CLC 
    ADC $01, S
    TAX 
    LDA #$0010            ; 16 metatile rows = one full 256px ring height
    SEC 
    SBC $10               ; First segment count = 16 − start row (current row to the bottom of the page)
    JSR $&FillVertTilemapSeg ; Fill first vertical segment of column with FillVertTilemapSeg
    PLY 
    LDA $10               ; Second segment needed only if the start row > 0
    BEQ loc_02AE56        ; Start row 0: the first segment filled all 16 rows, skip the second
    TYX 
    LDA $04
    AND #$FF0F            ; Clear the row nibble (AND #$FF0F) — back to row 0 of the same column
    CLC 
    ADC $1A               ; Add map width (mapBoundsX bytes) to advance to the next page row
    CMP $1E               ; Check against tilemap upper bound for wrap detection
    BCC loc_02AE44
    SEC 
    SBC $08               ; Subtract map data size to wrap back within the map data

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
    JSR $&FillVertTilemapSeg ; Fill second vertical segment — the rows that continue in the next page row

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
    TXA                   ; === Edge tile: last slot is overwritten with the metatile row just above the strip start ===
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
; Inner loop that expands metatile indices into VRAM tilemap entries for a horizontal run of metatiles (a ROW strip segment; used by RenderRowStrip).
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
; Inner loop that expands metatile indices into VRAM tilemap entries for a vertical run of metatiles (a COLUMN strip segment; used by RenderColumnStrip).
; 
; Reads $0E consecutive metatile index bytes from map data, advancing the source Y pointer by $10 (16 bytes = one map row) per iteration to traverse vertically through the map.
; 
; For each metatile byte: masks to 8 bits, multiplies by 8 to index the tile definition table. Copies 4 tile entries to the staging buffer in a column-oriented layout:
; - Words 0,2 → buffer+$02/+$04 (left column, top and bottom)
; - Words 1,3 → buffer+$44/+$46 (right column, top and bottom)
; 
; The buffer holds two tile columns of 32 words each: the left column's data at +$02 (after its VRAM address word at +0) and the right column's data at +$44 (after its own VRAM address word at +$42). X advances by 4 bytes (two words per tile column) per metatile.

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
    STA $0044, X          ; Write right-upper into the right tile column's data at +$44
    LDA $0004, Y          ; Load tile word 2: left column, lower half
    STA $0004, X          ; Write left-lower to staging +$04 (the next word of the left column)
    LDA $0006, Y          ; Load tile word 3: right column, lower half
    STA $0046, X          ; Write right-lower at +$46 (the next word of the right column)
    INX                   ; Advance staging pointer by 4 bytes per metatile (two words in each tile column)
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
; 1. Column strip, layer 0 ($06B2 → $7E3100): DMA via DmaColumnStrip
; 2. Column strip, layer 1 ($06B4 → $7E3288): DMA via DmaColumnStrip
; 3. Row strip, layer 0 ($06B6 → $7E3184): DMA via DmaRowStrip (VMAIN switched to $80 for sequential access)
; 4. Row strip, layer 1 ($06B8 → $7E330C): DMA via DmaRowStrip
; (The $06B2/$06B4 and $06B6/$06B8 pairs are the pointers initialised by system_init. "Horizontal"/"Vertical" in the routine names refers to the scroll direction that produces the strip, not to its shape.)
; 
; Each slot is skipped (BEQ) if its VRAM address word is zero (no pending update). After all transfers, clears all four staging buffer VRAM address words and the related staging areas to prevent re-triggering.

FlushDirtyTilemapStrips {
    PHP 
    SEP #$20              ; Switch to 8-bit A for DMA register configuration
    LDA #$81              ; VMAIN=$81: word-access VRAM with 32-word auto-increment (column strips write down a tile column)
    STA $VMAIN
    LDA #$01
    STA $DMAP0
    LDA #$18
    STA $BBAD0
    LDA #$7E
    STA $A1B0
    REP #$20
    LDX $colStripStagingPtr ; Check and DMA column strip 0 ($06B2) — pending column for BG layer 0
    LDA $7E0000, X
    TAY 
    BEQ loc_02AF85
    JSR $&DmaColumnStrip

  loc_02AF85:
    LDX $colStripStagingPtr+2 ; Check and DMA column strip 1 ($06B4) — pending column for BG layer 1
    LDA $7E0000, X
    TAY 
    BEQ loc_02AF92
    JSR $&DmaColumnStrip

  loc_02AF92:
    LDA #$0080            ; Switch VMAIN to $80: word-access with sequential increment for row strips
    STA $VMAIN
    LDX $rowStripStagingPtr ; Check and DMA row strip 0 ($06B6) — pending row for BG layer 0
    LDA $7E0000, X
    TAY 
    BEQ loc_02AFA5
    JSR $&DmaRowStrip

  loc_02AFA5:
    LDX $rowStripStagingPtr+2 ; Check and DMA row strip 1 ($06B8) — pending row for BG layer 1
    LDA $7E0000, X
    TAY 
    BEQ loc_02AFB2
    JSR $&DmaRowStrip

  loc_02AFB2:
    LDA #$0000            ; Zero the VRAM-address word at the head of each of the four strip buffers ($7E3100/$7E3184/$7E3288/$7E330C) so nothing re-fires next frame
    STA $tilemapStaging
    STA $7E3288
    STA $7E3184
    STA $7E330C
    PLP 
    RTL 
}

---------------------------------------------
; Transfers one COLUMN strip (a 16px-wide metatile column = two adjacent tile columns) from the staging buffer to VRAM via DMA. This is the strip used for horizontal scrolling: the caller sets VMAIN=$81, so each word lands 32 words (one tile row) after the previous one.
; 
; The staging buffer layout for each strip: [VRAM_addr:u16, data:64_bytes, VRAM_addr:u16, data:64_bytes]. The two halves are the left and right tile columns of the metatile column (VRAM address and address+1) — not two nametables.
; 
; First DMA: Sets VMADDL to the first VRAM address (from Y parameter), sets A1T0L to the staging data pointer (X+2), transfers $40 bytes (64 bytes = 32 tilemap entries = one full 32-tile-high column).
; 
; Second DMA: Advances the source pointer by $40 bytes, reads the second column's VRAM address, and transfers another $40 bytes.

DmaColumnStrip {
    PHP 
    SEP #$20
    INX                   ; Skip past 2-byte VRAM destination address word to reach tilemap data in staging buffer
    INX 
    PHX 
    STY $VMADDL           ; Set VRAM destination address from the staging buffer header word
    STX $A1T0L
    LDA #$40              ; $40 = 64 bytes = 32 tilemap entries = one tile column (32 tiles high) in VRAM
    STA $DAS0L
    LDA #$01
    STA $MDMAEN
    REP #$20
    PLA 
    CLC 
    ADC #$0040            ; Advance source pointer by $40 bytes to the second tile column's header
    TAX 
    LDA $7E0000, X        ; Load VRAM destination address for the second (right) tile column
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
; Transfers one ROW strip (a 16px-tall metatile row = two adjacent tile rows) from the staging buffer to VRAM via DMA. This is the strip used for vertical scrolling.
; 
; Same buffer layout as DmaColumnStrip but each half is $80 bytes (128 bytes = 64 words): with VRAM increment 1 the first 32 words fill one tile row of a nametable and the next 32 words fill the tile row below it. The two halves are the two nametables (the 512px strip is split across them); the second half's header is at source+$80.
; 
; VMAIN must be set to $80 (word-access, increment by 1) by the caller, unlike column strips, which need increment 32.

DmaRowStrip {
    PHP 
    SEP #$20
    INX 
    INX 
    PHX 
    STY $VMADDL
    STX $A1T0L
    LDA #$80              ; $80 = 128 bytes = 64 tilemap entries = two consecutive tile rows of one nametable
    STA $DAS0L
    LDA #$01
    STA $MDMAEN
    REP #$20
    PLA 
    CLC 
    ADC #$0080            ; Advance source by $80 bytes to the second nametable's half of the row strip
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
; Uploads the BG3 tilemap staging buffer (bg3TilemapBuffer, WRAM $7F0200) to the BG3 tilemap in VRAM during V-Blank. BG3SC is initialised to $78, so VRAM $7800 is the BG3 tilemap (32×32 words = $0800 bytes), not sprite graphics; the buffer is the one the console string renderer writes. Called every NMI from system_core.
; 
; First checks hudDisableFlag ($09ED) bit 7 — if set, the upload is suppressed (returns immediately): the request bits stay pending and the upload runs in the first NMI after the bit is cleared (measured). No instruction sets this bit; the PAUSE path of GlobalInputHandler clears it. Then checks displayModeFlags ($09EC) for bits $31 — if none are set, nothing is pending.
; 
; Two transfer modes based on flag bits:
; 1. Bit 0 (full update): Transfers $0800 bytes (the whole 32×32 BG3 tilemap) from WRAM $7F0200 to VRAM $7800.
; 2. Bits 4 or 5 (partial update): Transfers $0140 bytes (160 words = five tile rows) from WRAM $7F0280 to VRAM $7840 (tile row 2 onward). Bits 4 and 5 behave identically: the bit-5 path pre-clears that bit, but the common TRB below clears bits 0, 4 and 5 either way. Measured: bit 0 gives the full upload and bit 4 or bit 5 gives the same partial upload (VRAM words $7840-$7983 = staging offsets $80-$1BF), each in the first NMI after the request, which also clears the bit. The ROM only ever requests bit 4 (UpdateHUD, three sites); no instruction sets bit 5.
; 
; After the transfer, clears the request flags (bits 0,4,5 via TRB with $31). Sets VMAIN=$80, DMAP0=$01, BBAD0=$18, source bank=$7F, then triggers DMA channel 0. (displayModeFlags bit 3 is the separate player-tile DMA request handled in system_core.)

Bg3TilemapVramDma {
    LDA $hudDisableFlag   ; Check hudDisableFlag ($09ED) bit 7 — if set, the BG3 tilemap upload is suppressed
    BPL loc_02B03E
    RTL 

  loc_02B03E:
    LDA $displayModeFlags ; Check displayModeFlags bits 0/4/5 ($31 mask) — any set requests a BG3 tilemap upload
    BIT #$31
    BNE loc_02B046
    RTL 

  loc_02B046:
    BIT #$01              ; Bit 0 = full BG3 tilemap upload
    BEQ loc_02B05E
    LDX #$0800            ; $0800 = 2048 bytes = 1024 tilemap words (32×32 BG3 tilemap)
    STX $DAS0L
    LDX #$7800            ; VRAM word address $7800 = BG3 tilemap (BG3SC = $78)
    STX $VMADDL
    LDX #$0200            ; Source $7F0200 = bg3TilemapBuffer
    STX $A1T0L
    BRA loc_02B084

  loc_02B05E:
    LDA $displayModeFlags ; Bits 4-5: partial BG3 tilemap upload (functionally identical; see note)
    BIT #$20
    BNE loc_02B06D
    LDX #$0140            ; $0140 = 320 bytes = 160 words = five tilemap rows (5 × 32 words)
    STX $DAS0L
    BRA loc_02B078

  loc_02B06D:
    AND #$DF              ; Bit 5 path: clear bit 5 now (redundant — the TRB at the end clears bits 0/4/5 anyway)
    STA $displayModeFlags
    LDX #$0140
    STX $DAS0L

  loc_02B078:
    LDX #$7840            ; VRAM word address $7840 = BG3 tilemap row 2 ($7800 + 2 × 32 words)
    STX $VMADDL
    LDX #$0280            ; Source $7F0280 = bg3TilemapBuffer + $80 (tilemap row 2, same row as the VRAM target)
    STX $A1T0L

  loc_02B084:
    LDA #$31              ; Clear the BG3 upload request flags (bits 0,4,5) via TRB to prevent re-triggering
    TRB $displayModeFlags
    LDA #$80              ; VMAIN=$80: standard word-access VRAM with sequential auto-increment
    STA $VMAIN
    LDA #$01
    STA $DMAP0
    LDA #$18
    STA $BBAD0
    LDA #$7F              ; Source bank $7F = upper WRAM bank (bg3TilemapBuffer lives at $7F0200)
    STA $A1B0
    LDA #$01
    STA $MDMAEN           ; Trigger DMA channel 0 to run the BG3 tilemap transfer
    RTL 
}