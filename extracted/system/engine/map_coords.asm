; Map coordinate utilities (Bank 02): tile and pixel coordinates to map indices and BG1 VRAM addresses, map index stepping, and the two slope probes used by player movement.
; 
; === Map index format ===
; The map is a grid of 16x16-tile pages of 256 bytes, row-major, with a per-layer page stride (mapRowStrideL0/L1, $0693/$0695, selected by X = 0 or 2). index = (((tileY >> 4) x stride + (tileX >> 4)) << 8) or ((tileY and $F) << 4) or (tileX and $F). The same index addresses mapLayerTilemap ($7EA000), the collision map ($7FC000; an index at or above $4000 is out of range) and the effect layer.
; - TileCoordsToMapIndex: DP $18/$1C (tile X/Y), X = layer selector -> X = index. Multiply8x8Unsigned multiplies the stride (A low) by the page row (A high = tileY >> 4). 16 JSL sites in warps_interaction, event_blocks, cop_handlers_metatile and cop_handlers_collision.
; - PixelToVramAddress: DP $1A/$1E (pixel X/Y) -> A = ((Y and $F8) << 2) + ((X and $F8) >> 3) + ((X and $100) << 2) + $1000: the BG1 nametable (64x32 words at VRAM $1000, second 32x32 half for X bit 8; X wraps at 512 px and Y at 256 px). event_blocks adds $0800 for BG2.
; - MapIndexMoveRight/Left/Down/Down_L1 step the index kept in $02 by one cell and return it in X. Right and both Down variants also store it back in $02; MapIndexMoveLeft returns X only. MapIndexMoveDown_L1 loads $02 without a REP, so it relies on the caller's M width (its two callers in event_blocks have M = 16).
; 
; === Slope probes ===
; FindSlopeForWestMove and FindSlopeForEastMove have exactly one caller each: DispatchWestMove (player_move_west) calls FindSlopeForWestMove and DispatchEastMove (player_move_east) calls FindSlopeForEastMove. They are interleaved with the coordinate code only because they share its tile_collision helpers. Both look for the slope collision types $0A (east-facing) and $05 (west-facing) at the corner probe, at the cell one ROW up (only after a transition tile) and one ROW down (MapCellUp/MapCellDown on the index in $00; the old comments called them MapCellLeft/Right), then at two future-position corners (ProbeFutureTL/BL for the right probe, TR/BR for the left one).
; Return convention (callers test Z first): Z set = a slope was found, with carry clear for $0A and carry set for $05; Z clear = nothing found. The callers branch BNE (none), then BCS ($05: WestRampUp / WestRampDescend) or fall through ($0A: EastRampDown / WestRampAscend). The old 'carry clear when found' header was wrong. The probe pixel X in $1A is modified in place (+8 for the right probe, -8 for the left one).
---------------------------------------------

?BANK 02

?INCLUDE 'hardware_math'
?INCLUDE 'tile_collision'

!mapRowStrideL0                 0693
!mapRowStrideL1                 0695

---------------------------------------------

; DP $18 = tile X, $1C = tile Y, X register = layer selector (0 = layer 0, 2 = layer 1; picks mapRowStrideL0 or L1). Returns X = map index (see the block note for the format). Preserves P through PHP/PLP; 16 callers.

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
    JSL $@hardware_math.Multiply8x8Unsigned ; stride (A low) x page row (A high = tileY >> 4)
    STA $02, S            ; Page byte = (page row x stride) and $FF; the saved low byte is (tileY and $F) x 16
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
; DP $1A = pixel X, $1E = pixel Y. Returns A = VRAM word address in the BG1 nametable (64x32 words at $1000): row (Y and $F8) x 4, column (X and $F8) / 8, plus $0400 when X bit 8 is set. Callers: cop_handlers_metatile.ResolveTileData and two sites in event_blocks (one adds $0800 for BG2).

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
; Steps the index in $02 one cell east: increments the column nibble, and when it wraps (page boundary) increments the page byte and adds $F0 to restore the column. Stores the result in $02 and returns it in X. 11 callers (warps_interaction, event_blocks).

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
; Steps the index in $02 one cell west (column nibble - 1; on underflow the page byte - 1 and the low byte - $F0). Returns the result in X only: unlike MapIndexMoveRight and Down it does NOT store it back in $02. 1 caller (warps_interaction chest check).

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
    TAX                   ; Result returned in X only: $02 is not updated by this routine
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
; Steps the index in $02 one row down for layer 0: low byte + $10; on carry adds mapRowStrideL0 to the page byte. Stores in $02 and returns it in X. 4 callers.

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
; Same as MapIndexMoveDown with mapRowStrideL1. The initial LDA $02 has no REP, so it uses the caller's accumulator width (both callers, in event_blocks, have M = 16). Stores in $02 and returns it in X.

MapIndexMoveDown_L1 {
    PHP 
    LDA $02               ; Loads with the CALLER's M width (no REP here): both callers have M = 16
    SEP #$20
    CLC 
    ADC #$10              ; Next row inside the page (+$10); carry means the page's last row was passed
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
; Slope probe used by DispatchWestMove. ProbeCurrentTL positions the probe pixels (its own result is discarded), then $1A is moved +8 and TileProbeMain samples the corner. Types: $0A or $05 end the routine at once; $09 (transition tile) also checks the cell one row up for $0A; then the cell one row down ($0A or $05), then ProbeFutureTL and ProbeFutureBL. Returns Z set when a slope was found (carry clear = $0A, set = $05) and Z clear when none.

FindSlopeForWestMove {
    JSR $&tile_collision.ProbeCurrentTL ; Result ignored: this call only positions the probe pixels $1A/$1E for the offset sample below
    REP #$20
    LDA $1A               ; Offset pixel X ($1A) by +8 — probe one half-tile to the right
    CLC 
    ADC #$0008
    STA $1A
    SEP #$20
    JSR $&tile_collision.TileProbeMain ; TileProbeMain at offset position — primary right-edge slope sample
    CMP #$0A              ; $0A (east-facing slope) found: exit with Z set and carry clear
    BEQ loc_02B1B5
    CMP #$05              ; $05 (west-facing slope) found: exit with Z set and carry set
    BEQ loc_02B1B7
    CMP #$09              ; Collision $09 = transition tile — check adjacent cell for hidden slope
    BNE loc_02B190
    JSR $&tile_collision.MapCellUp ; Transition tile $09: look at the cell ONE ROW UP (MapCellUp on the probe index in $00) for a hidden $0A
    JSR $&tile_collision.ReadCollisionNibble
    CMP #$0A
    BEQ loc_02B1B5

  loc_02B190:
    JSR $&tile_collision.MapCellDown ; Cell ONE ROW DOWN from the probe (MapCellDown), not the right-hand cell
    JSR $&tile_collision.ReadCollisionNibble
    CMP #$0A              ; Cell one row below the probe is $0A: east slope (exit with Z set, carry clear)
    BEQ loc_02B1B5
    CMP #$05              ; Cell one row below the probe is $05: west slope (exit with Z set, carry set)
    BEQ loc_02B1B7
    JSR $&tile_collision.ProbeFutureTL ; ProbeFutureTL: slope sample at the stepped top-left corner (this routine serves DispatchWestMove, not a rightward move)
    CMP #$0A              ; Future TL $0A → upcoming east slope (carry clear)
    BEQ loc_02B1B8
    CMP #$05              ; Future TL $05 → upcoming west slope blocks (carry set)
    BEQ loc_02B1BA
    JSR $&tile_collision.ProbeFutureBL ; ProbeFutureBL — forward bottom-left for diagonal ramp coverage
    CMP #$0A              ; Future BL $0A → east slope on lower forward corner
    BEQ loc_02B1B8
    CMP #$05              ; Future BL $05 → west slope on lower forward corner (carry set)
    BEQ loc_02B1BA
    RTS                   ; Nothing found: the last compare failed, so Z is clear

  loc_02B1B5:
    CLC                   ; $0A found: Z still set from the compare, carry cleared; callers branch on Z first
    RTS 

  loc_02B1B7:
    RTS                   ; $05 found: Z set, carry set (from the compare)

  loc_02B1B8:
    CLC                   ; $0A found at a future corner: Z set, carry clear
    RTS 

  loc_02B1BA:
    RTS 
}

---------------------------------------------
; Slope probe used by DispatchEastMove; mirror of FindSlopeForWestMove. ProbeCurrentTR positions the probe pixels (result discarded), $1A is moved -8, then the corner sample; transition type $06 also checks the cell one row up for $05; then one row down, then ProbeFutureTR and ProbeFutureBR. Returns Z set when found (carry clear = $0A, set = $05), Z clear when none.

FindSlopeForEastMove {
    JSR $&tile_collision.ProbeCurrentTR ; Result ignored: this call only positions the probe pixels $1A/$1E for the offset sample below
    REP #$20
    LDA $1A               ; Offset pixel X ($1A) by −8 — probe one half-tile to the left
    SEC 
    SBC #$0008
    STA $1A
    SEP #$20
    JSR $&tile_collision.TileProbeMain ; TileProbeMain at left offset — primary left-edge slope sample
    CMP #$0A              ; $0A (east-facing slope) found: Z set, carry clear (caller takes EastRampDown)
    BEQ loc_02B209
    CMP #$05              ; $05 (west-facing slope) found: Z set, carry set (caller takes WestRampUp)
    BEQ loc_02B208
    CMP #$06              ; Collision $06 = left transition tile — probe neighbor for hidden west slope
    BNE loc_02B1E3
    JSR $&tile_collision.MapCellUp ; Transition tile $06: look at the cell ONE ROW UP (MapCellUp) for a hidden $05
    JSR $&tile_collision.ReadCollisionNibble
    CMP #$05
    BEQ loc_02B208

  loc_02B1E3:
    JSR $&tile_collision.MapCellDown ; Cell ONE ROW DOWN from the probe (MapCellDown), not the right-hand cell
    JSR $&tile_collision.ReadCollisionNibble
    CMP #$0A
    BEQ loc_02B209
    CMP #$05
    BEQ loc_02B208
    JSR $&tile_collision.ProbeFutureTR ; ProbeFutureTR: slope sample at the stepped top-right corner (this routine serves DispatchEastMove, not a leftward move)
    CMP #$0A
    BEQ loc_02B20C
    CMP #$05
    BEQ loc_02B20B
    JSR $&tile_collision.ProbeFutureBR ; ProbeFutureBR — forward bottom-right for diagonal ramp coverage
    CMP #$0A
    BEQ loc_02B20C
    CMP #$05
    BEQ loc_02B20B
    RTS                   ; Nothing found: Z clear

  loc_02B208:
    RTS                   ; $05 found: Z set, carry set

  loc_02B209:
    CLC                   ; $0A found: Z set, carry cleared
    RTS 

  loc_02B20B:
    RTS 

  loc_02B20C:
    CLC                   ; $0A found at a future corner: Z set, carry clear
    RTS 
}