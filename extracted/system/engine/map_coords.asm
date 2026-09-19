; Map coordinate utilities — tile/pixel/VRAM address conversion and map index traversal (176291–176654, Bank 02).
; 
; Provides the fundamental coordinate system primitives used by the camera, event block, collision, and rendering systems. All map data is stored as a flat 1D array indexed by a 16-bit map index. Tiles are 16×16 pixels (metatiles composed of four 8×8 SNES tiles). Map indices encode both X position (low nibble of low byte = column within a 16-tile-wide page) and Y position (remaining bits = row × page stride).
; 
; === COORDINATE CONVERSION ===
; 
; TileCoordsToMapIndex: Converts tile coordinates ($18 = X tile, $1C = Y tile) to a linear map data index. Y is multiplied by mapRowStride (per-layer: mapRowStrideL0 or mapRowStrideL1 selected by X register = 0 or 2) via SignedMultiply. X is split into low nibble (column within page) and high nibble (page offset), added to the Y product. Returns map index in X.
; 
; PixelToVramAddress: Converts pixel coordinates ($1A = X, $1E = Y) to a VRAM tilemap nametable address. Y bits 3-7 provide the row (×32 via ASL×2), X bits 3-7 provide the column (÷8 via LSR×3). X bit 8 selects the second nametable half (+$0400 via ASL×2). Base offset $1000 is added for BG1 nametable base.
; 
; === MAP INDEX TRAVERSAL ===
; 
; Four directional traversal routines operate on the map index at $02 (16-bit):
; 
; MapIndexMoveRight: Increments the low nibble (column). On page boundary (low nibble wraps from $0F to $00), increments the high byte (row page) and adds $F0 to compensate — effectively advancing to the first column of the next 16-tile page.
; 
; MapIndexMoveLeft: Decrements the low nibble. On underflow ($0F detected), decrements the high byte and subtracts $F0 — moving to the last column of the previous page.
; 
; MapIndexMoveDown: Adds $10 to the low byte (next row within the same page). On carry (page boundary crossed), adds mapRowStrideL0 to the high byte to advance to the next map row page.
; 
; MapIndexMoveDown_L1: Same as MapIndexMoveDown but uses mapRowStrideL1 for the layer 1 effect tilemap stride.
; 
; === SLOPE TILE PROBES (player-movement-specific) ===
; 
; ProbeRightTiles and ProbeLeftTiles are used exclusively by the player movement system (slope_ramp_physics and player_move_east/diag). They probe collision tiles at an 8-pixel offset in the specified direction, checking for slope types $05 (west-facing) and $0A (east-facing). The probing sequence checks:
; 1. Current tile at the probe position (TileProbeMain)
; 2. Adjacent cells (MapCellLeft/Right + ReadCollisionNibble)
; 3. Future tiles (ProbeFutureTL/BL or ProbeFutureTR/BR)
; 
; Return carry clear if a slope tile of the matching type is found (indicating the player should receive slope acceleration), or fall through with carry set (no slope).
; 
; Note: These slope probes are physically interleaved with the coordinate conversion routines and share their implementation (TileProbeMain, MapCell* from tile_collision). They remain in this engine-scoped block rather than system/player because splitting them would break physical contiguity with the coordinate utilities they depend on.
---------------------------------------------

?BANK 02

?INCLUDE 'hardware_math'
?INCLUDE 'tile_collision'

!mapRowStrideL0                 0693
!mapRowStrideL1                 0695

---------------------------------------------

; Convert tile coordinates to a linear map data index.
; 
; Entry: $18 = X tile coordinate, $1C = Y tile coordinate, X register = layer selector (0 = layer 0, 2 = layer 1).
; 
; Computation: Y tile is multiplied by 16 (ASL×4), then the map row stride (mapRowStrideL0 or mapRowStrideL1, selected by X) is applied via SignedMultiply. X tile is split: low nibble (AND $0F) adds the intra-page column offset, high nibble (LSR×4) adds the page offset to the high byte. The combined result is returned in X as the map index.
; 
; Uses the stack for intermediate results (PHA/PLA). Returns with X = map index, preserves processor state via PHP/PLP.

TileCoordsToMapIndex {
    PHP 
    REP #$20
    LDA $1C               ; TileCoordsToMapIndex: Y tile coordinate ($1C) — row component of map index
    ASL                   ; Y tile ×16 (ASL×4) — scale tile row to map byte stride units
    ASL 
    ASL 
    ASL 
    PHA 
    SEP #$20
    LDA $mapRowStrideL0, X ; mapRowStrideL0+X: layer 0 (X=0) or layer 1 (X=2) row page stride
    JSL $@hardware_math.SignedMultiply ; SignedMultiply: Y×16 × row stride → row page offset; store high byte at $02,S
    STA $02, S
    LDA $18               ; X tile coordinate ($18) — split into intra-page column and page index
    AND #$0F              ; Low nibble of X tile = column offset within 16-tile metatile page
    CLC 
    ADC $01, S            ; Add column offset to stack low byte ($01,S)
    STA $01, S
    LDA $18
    LSR                   ; High nibble of X tile (LSR×4) = metatile column page index
    LSR 
    LSR 
    LSR 
    CLC 
    ADC $02, S            ; Add page index to row product → complete 16-bit map index on stack
    STA $02, S
    PLX                   ; PLX: pop final map index from stack into X for caller
    PLP 
    RTL 
}

---------------------------------------------
; Convert pixel coordinates to a VRAM nametable tilemap address.
; 
; Entry: $1A = pixel X, $1E = pixel Y (both 16-bit).
; 
; Computation:
;   Row: ($1E AND $00F8) × 4 (ASL×2) — extracts the 8-pixel-aligned row and scales to the 32-entry tilemap row stride
;   Column: ($1A AND $00F8) ÷ 8 (LSR×3) — extracts the 8-pixel-aligned column as a word offset
;   Nametable: ($1A AND $0100) × 4 (ASL×2) — bit 8 of X selects the second 32×32 nametable half (+$0400)
;   Base: + $1000 for BG1 nametable base address
; 
; Row, column, and nametable offsets are accumulated on the stack via PHA/ADC/$01,S/PLA. Returns the VRAM address in A.

PixelToVramAddress {
    LDA $1E               ; PixelToVramAddress: pixel Y ($1E) for nametable row addressing
    AND #$00F8            ; AND $00F8 — align Y to 8-pixel tile row boundary
    ASL                   ; Row offset ×4 (ASL×2) — 32 word entries per nametable scanline
    ASL 
    PHA 
    LDA $1A               ; Pixel X ($1A) for column word offset within the row
    AND #$00F8            ; AND $00F8 — align X to 8-pixel tile column boundary
    LSR                   ; Column ÷8 (LSR×3) — word index within the 32-tile row
    LSR 
    LSR 
    CLC 
    ADC $01, S            ; Accumulate row + column offset on stack ($01,S)
    STA $01, S
    LDA $1A
    AND #$0100            ; AND $0100 — bit 8 of pixel X selects second 32×32 nametable half (+$0400)
    ASL                   ; Nametable half offset ×4 (ASL×2) — adds $0400 when X ≥ 256 px
    ASL 
    CLC 
    ADC $01, S            ; Add nametable half offset to accumulated row/column address
    STA $01, S
    PLA 
    CLC                   ; Add $1000 — BG1 tilemap VRAM base address; result in A
    ADC #$1000
    RTL 
}

---------------------------------------------
; Move a map index one tile to the right (increment X within the current row).
; 
; Operates on the 16-bit map index at $02. Increments the low nibble (column within the 16-tile page). If the low nibble wraps from $0F to $00 (BIT #$0F == 0), the routine crosses a page boundary: increments the high byte (page) and adds $F0 to the low byte to compensate for the nibble reset.
; 
; Returns with X = updated map index, $02 updated. Preserves processor state.

MapIndexMoveRight {
    PHP 
    SEP #$20
    LDA $02               ; MapIndexMoveRight: 16-bit map index at $02 — increment one tile east
    INC                   ; INC low byte — advance column nibble within current 16-tile page
    BIT #$0F              ; BIT $0F — low nibble zero after INC = crossed page boundary at column 16
    BEQ loc_02B106
    STA $02
    LDX $02
    PLP 
    RTL 

  loc_02B106:
    XBA                   ; Page wrap path: swap bytes to increment metatile column page (high byte)
    LDA $03
    INC 
    XBA 
    CLC 
    ADC #$F0              ; ADC $F0 — restore low byte to $F0 after nibble wrapped $0F→$00
    TAX 
    STX $02
    PLP 
    RTL 
}

---------------------------------------------
; Move a map index one tile to the left (decrement X within the current row).
; 
; Operates on the 16-bit map index at $02. Decrements the low nibble. If the result's low nibble is $0F (underflow from $00), the routine crosses a page boundary: decrements the high byte (page) and subtracts $F0 from the low byte to compensate.
; 
; Returns with X = updated map index. Preserves processor state.

MapIndexMoveLeft {
    PHP 
    REP #$20
    LDA $02               ; MapIndexMoveLeft: load map index at $02 for one-tile westward move
    SEP #$20
    DEC                   ; DEC low byte — decrement column within current page
    PHA 
    AND #$0F              ; AND $0F / CMP $0F — detect underflow wrap ($00→$0F = crossed page left
    CMP #$0F
    BEQ loc_02B126
    PLA 
    TAX 
    PLP 
    RTL 

  loc_02B126:
    PLA 
    XBA 
    LDA $03               ; Page underflow: DEC high byte — previous metatile column page
    DEC 
    XBA 
    SEC 
    SBC #$F0              ; SBC $F0 — compensate low byte after nibble underflow past column 0
    TAX 
    PLP 
    RTL 
}

---------------------------------------------
; Move a map index one tile down (next row) for layer 0.
; 
; Adds $10 to the low byte of the map index at $02 (advance one row within the current page). If the addition carries (page boundary crossed), adds mapRowStrideL0 ($0693) to the high byte to jump to the corresponding column in the next row page.
; 
; Returns with X = updated map index, $02 updated. Preserves processor state.

MapIndexMoveDown {
    PHP 
    REP #$20
    LDA $02               ; MapIndexMoveDown: map index at $02 — advance one tile row (layer 0)
    SEP #$20
    CLC 
    ADC #$10              ; ADC $10 — +16 bytes = next row within same 16-row metatile page
    BCS loc_02B143        ; BCS — carry = crossed bottom row of page, need stride correction
    TAX 
    STX $02
    PLP 
    RTL 

  loc_02B143:
    XBA                   ; Page wrap: XBA to add stride to high byte without disturbing low
    CLC 
    ADC $mapRowStrideL0   ; ADC mapRowStrideL0 — jump to same column in next row page (layer 0)
    XBA 
    TAX 
    STX $02
    PLP 
    RTL 
}

---------------------------------------------
; Move a map index one tile down for layer 1 (effect tilemap).
; 
; Same structure as MapIndexMoveDown but uses mapRowStrideL1 ($0695) instead of mapRowStrideL0 for the page stride. Layer 1 maps may have different dimensions than layer 0.

MapIndexMoveDown_L1 {
    PHP 
    LDA $02               ; MapIndexMoveDown_L1: layer 1 map index — same +$10 row advance
    SEP #$20
    CLC 
    ADC #$10              ; ADC $10 — next row within current 16-row page (8-bit fast path)
    BCS loc_02B15D
    TAX 
    STX $02
    PLP 
    RTL 

  loc_02B15D:
    XBA 
    CLC 
    ADC $mapRowStrideL1   ; Carry path: ADC mapRowStrideL1 — layer 1 row stride ($0695) may differ from L0
    XBA 
    TAX 
    STX $02
    PLP 
    RTL 
}

---------------------------------------------
; Probe collision tiles 8 pixels to the right for slope detection.
; 
; Used by the slope/ramp physics system. Sequence:
; 1. ProbeCurrentTL at the current position
; 2. Offset $1A by +8 pixels, call TileProbeMain
; 3. Check for slope type $0A (east-facing) → return carry clear
; 4. Check for $05 (west-facing) → return carry set (no east slope)
; 5. Check for transition type $09 → probe MapCellLeft for hidden $0A
; 6. Probe MapCellRight → check for $0A or $05
; 7. Probe ProbeFutureTL and ProbeFutureBL for $0A or $05
; 
; Returns carry clear if an east-facing slope ($0A) is found at any probe position, indicating the player should receive eastward slope acceleration.

ProbeRightTiles {
    JSR $&tile_collision.ProbeCurrentTL ; ProbeRightTiles: probe top-left collision nibble at current position
    REP #$20
    LDA $1A               ; Offset pixel X ($1A) by +8 — probe one half-tile to the right
    CLC 
    ADC #$0008
    STA $1A
    SEP #$20
    JSR $&tile_collision.TileProbeMain ; TileProbeMain at offset position — primary right-edge slope sample
    CMP #$0A              ; Collision $0A = east-facing slope → CLC (carry clear = apply east accel)
    BEQ loc_02B1B5
    CMP #$05              ; Collision $05 = west-facing slope → RTS carry set (blocks eastward)
    BEQ loc_02B1B7
    CMP #$09              ; Collision $09 = transition tile — check adjacent cell for hidden slope
    BNE loc_02B190
    JSR $&tile_collision.MapCellUp ; Transition $09: probe MapCellLeft for concealed east slope behind edge
    JSR $&tile_collision.ReadCollisionNibble
    CMP #$0A
    BEQ loc_02B1B5

  loc_02B190:
    JSR $&tile_collision.MapCellDown ; Probe MapCellRight — immediate right metatile collision nibble
    JSR $&tile_collision.ReadCollisionNibble
    CMP #$0A              ; Right cell $0A → east slope detected (carry clear)
    BEQ loc_02B1B5
    CMP #$05              ; Right cell $05 → west slope blocks east probe (carry set)
    BEQ loc_02B1B7
    JSR $&tile_collision.ProbeFutureTL ; ProbeFutureTL — forward top-left at next tile boundary (right movement)
    CMP #$0A              ; Future TL $0A → upcoming east slope (carry clear)
    BEQ loc_02B1B8
    CMP #$05              ; Future TL $05 → upcoming west slope blocks (carry set)
    BEQ loc_02B1BA
    JSR $&tile_collision.ProbeFutureBL ; ProbeFutureBL — forward bottom-left for diagonal ramp coverage
    CMP #$0A              ; Future BL $0A → east slope on lower forward corner
    BEQ loc_02B1B8
    CMP #$05              ; Future BL $05 → west slope on lower forward corner (carry set)
    BEQ loc_02B1BA
    RTS 

  loc_02B1B5:
    CLC                   ; Exit east-slope ($0A) found: CLC before RTS — caller applies eastward ramp physics
    RTS 

  loc_02B1B7:
    RTS 

  loc_02B1B8:
    CLC 
    RTS 

  loc_02B1BA:
    RTS 
}

---------------------------------------------
; Probe collision tiles 8 pixels to the left for slope detection.
; 
; Mirror of ProbeRightTiles for westward slope detection. Sequence:
; 1. ProbeCurrentTR at the current position
; 2. Offset $1A by −8 pixels, call TileProbeMain
; 3. Check for $0A (east-facing) → carry clear. Check for $05 (west-facing) → carry set.
; 4. Check for transition type $06 → probe MapCellLeft for hidden $05
; 5. Probe MapCellRight → check for $0A or $05
; 6. Probe ProbeFutureTR and ProbeFutureBR for $0A or $05
; 
; Returns carry clear if a west-facing slope ($05) is found, indicating westward slope acceleration.

ProbeLeftTiles {
    JSR $&tile_collision.ProbeCurrentTR ; ProbeLeftTiles: probe top-right collision nibble at current position
    REP #$20
    LDA $1A               ; Offset pixel X ($1A) by −8 — probe one half-tile to the left
    SEC 
    SBC #$0008
    STA $1A
    SEP #$20
    JSR $&tile_collision.TileProbeMain ; TileProbeMain at left offset — primary left-edge slope sample
    CMP #$0A              ; Collision $0A = east-facing slope → CLC (carry clear → EastRampDown)
    BEQ loc_02B209
    CMP #$05              ; Collision $05 = west-facing slope → carry set (BCS → WestRampUp)
    BEQ loc_02B208
    CMP #$06              ; Collision $06 = left transition tile — probe neighbor for hidden west slope
    BNE loc_02B1E3
    JSR $&tile_collision.MapCellUp ; Transition $06: probe MapCellLeft for concealed west slope ($05)
    JSR $&tile_collision.ReadCollisionNibble
    CMP #$05
    BEQ loc_02B208

  loc_02B1E3:
    JSR $&tile_collision.MapCellDown ; Probe MapCellRight — immediate right cell collision check
    JSR $&tile_collision.ReadCollisionNibble
    CMP #$0A
    BEQ loc_02B209
    CMP #$05
    BEQ loc_02B208
    JSR $&tile_collision.ProbeFutureTR ; ProbeFutureTR — forward top-right at next tile boundary (left movement)
    CMP #$0A
    BEQ loc_02B20C
    CMP #$05
    BEQ loc_02B20B
    JSR $&tile_collision.ProbeFutureBR ; ProbeFutureBR — forward bottom-right for diagonal ramp coverage
    CMP #$0A
    BEQ loc_02B20C
    CMP #$05
    BEQ loc_02B20B
    RTS 

  loc_02B208:
    RTS 

  loc_02B209:
    CLC                   ; Exit $0A found: CLC before RTS — westward ramp entry for DispatchEastMove
    RTS 

  loc_02B20B:
    RTS 

  loc_02B20C:
    CLC 
    RTS                   ; Check character form — this shimmer actor is Shadow-only (form 2)
}