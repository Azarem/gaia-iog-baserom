; Tile collision primitives — probe, navigation, alignment, and movement utilities used by all player movement dispatchers (188674–189334, Bank 02). Outputs to system/player/ alongside its callers.
; 
; This is the shared utility layer for the player movement system. Every movement dispatcher (DispatchNorthMove, DispatchSouthMove, DispatchEastMove, and their diagonal/ramp variants) calls into these routines for tile probing, collision reading, map cell navigation, and movement application. No other system references these routines — they exist exclusively as the probe/navigation foundation for the player_move_* blocks.
; 
; === HITBOX PROBING ===
; 
; 8 probe routines sample collision at the 4 corners of the player's 16×16 hitbox:
;   - Current probes (ProbeCurrentTL/TR/BL/BR): Use current position ($22, $26)
;   - Future probes (ProbeFutureTL/TR/BL/BR): Use position + velocity ($22+$20, $26+$24)
; 
; Hitbox geometry (relative to sub-pixel reference point):
;   Left edge: pixel − 8 (ADC $FFF8)
;   Right edge: pixel + 7 (ADC $0007)
;   Top edge: pixel − 16 (ADC $FFF0)
;   Bottom edge: pixel − 1 (ADC $FFFF)
;   Total: 16×16 pixels, reference at center-bottom
; 
; All probes convert sub-pixel (>>2) to pixel, add the hitbox offset, call TileProbeMain, and return collision type in A with carry set = collision detected. Post-probe adjustments (INC $1A, INC $1E) shift the stored coordinates one pixel inward for subsequent MapCell navigation by the caller.
; 
; === TILE PROBE ENGINE ===
; 
; TileProbeMain: Validates pixel coordinates ($1A, $1E) are within camera bounds (cameraOffsetX/Y to cameraBoundsX/cameraLowerYBound). If out-of-bounds: returns $0F (solid) with carry set and sets $00 = $4001 (sentinel). If in-bounds: converts to tile coordinates (>>4 → $18, $1C), calls CalcTileMapOffset (tile_collision_physics) to get map index in Y, stores to $00/X, then ReadCollisionNibble.
; 
; ReadCollisionNibble: Reads collision layer byte at $7FC000+X. If X ≥ $4000 (out of map): returns $0F (solid). Otherwise: if the high nibble is nonzero, shifts right (>>4) to extract it as the collision type (override). If the high nibble is zero, uses the low nibble as the collision type. Sets Z flag via BIT #$FF.
; 
; === MAP CELL NAVIGATION ===
; 
; Four routines navigate the map index at $00 to an adjacent cell, returning the new index in X:
; 
;   MapCellDown: adds $10 to low byte (next row within page). On carry, adds mapRowStrideL0 to high byte. Same operation as MapIndexMoveDown in map_coords.
; 
;   MapCellUp: subtracts $10 from low byte. On borrow, subtracts mapRowStrideL0 from high byte. Reverse of MapCellDown.
; 
;   MapCellRight: increments low byte. If low nibble wraps to $x0 (BIT #$0F = 0), increments high byte and adds $F0 to compensate. Same operation as MapIndexMoveRight in map_coords.
; 
;   MapCellLeft: decrements low byte. If low nibble underflows to $xF (AND $0F = $0F), decrements high byte and subtracts $F0. Same as MapIndexMoveLeft.
; 
; === MOVEMENT UTILITIES ===
; 
; ApplyMovementDeltas: Adds velocity ($20, $24) to position ($22, $26) and zeroes velocity. Standard epilogue for non-blocked movement.
; 
; ClearMovementDeltas: Zeroes both velocity components ($20, $24). Used when movement is fully blocked (e.g., enclosed between two wall tiles).
; 
; SetActorCollisionFlag: Sets bit $0004 in the actor flags word at actor+$0010 (indexed via $000A). Marks the actor as having contacted a solid tile.
; 
; CheckTileBoundaryXor: XORs pre- and post-velocity X positions to detect a 16px tile boundary crossing (BIT #$0010). Used by ramp routines to determine when diagonal displacement should be applied.
; 
; CheckSubTileAlignX/Y: Tests whether pixel coordinate ($1A or $1E) is 16px-aligned (low nibble == 0). Returns carry clear = aligned, carry set = not aligned. Preserves A.
---------------------------------------------

?BANK 02

?INCLUDE 'tile_collision_physics'

!mapRowStrideL0                 0693
!cameraOffsetX                  06D6
!cameraOffsetY                  06D8
!cameraBoundsX                  06DA
!cameraLowerYBound              06DE
!collisionLayer                 7FC000

---------------------------------------------

; Unreferenced combined tile probe — checks collision at a computed position with optional adjacent-cell fallback.
; 
; Entry: A = Y velocity component (caller-supplied), $22/$20 = X sub-pixel position/velocity, $26 = Y sub-pixel position, $1A = X pixel offset (added to computed X pixel).
; 
; Converts (A + $26) >> 2 → Y pixel, ($22 + $20) >> 2 + $1A → X pixel, probes TileProbeMain. If collision type ≥ $0E (blocking), returns carry set. If not blocking but Y pixel is not 16px-aligned, also probes MapCellUp for adjacent collision. Returns carry set if either probe ≥ $0E.
; 
; Marked _Unused: no call sites found in the codebase. Likely a debug or cut routine.

CombinedProbe_Unused {
    CLC                   ; CombinedProbe_Unused: A + Y sub-pixel → combined future corner probe
    ADC $26               ; Y pixel = (A + $26) >> 2 then DEC — bottom-edge row (−1px from feet)
    LSR 
    LSR 
    DEC 
    STA $1E
    AND #$000F            ; Mask probe Y sub-tile nibble; PHP saves alignment flag on stack
    PHP 
    LDA $22               ; X pixel = ($22 + $20) >> 2 + caller offset already in $1A
    CLC 
    ADC $20
    LSR 
    LSR 
    CLC 
    ADC $1A
    STA $1A
    JSR $&TileProbeMain   ; TileProbeMain at combined future position
    AND #$00FF            ; Mask collision nibble to byte for $0E threshold compare
    CMP #$000E            ; Primary cell ≥ $0E → blocking; branch to fail if passable
    BCC loc_02E128
    PLP 

  loc_02E126:
    SEC                   ; Blocking confirmed — SEC RTS (carry set = collision)
    RTS 

  loc_02E128:
    PLP 
    BEQ loc_02E13D        ; Primary nonzero but < $0E: probe one row up (MapCellLeft = UP)
    SEP #$20
    JSR $&MapCellUp
    JSR $&ReadCollisionNibble ; Read upward neighbor — passable override if adjacent row is open
    REP #$20
    AND #$00FF
    CMP #$000E            ; Upward neighbor also ≥ $0E → still blocked (SEC path)
    BCS loc_02E126

  loc_02E13D:
    CLC                   ; Passable after neighbor check — CLC RTS
    RTS 
}

---------------------------------------------
; Detect whether X movement crosses a 16-pixel tile boundary.
; 
; Computes: (($22 >> 2) + ($20 >> 2)) XOR ($20 >> 2) and tests bit 4 ($0010). If bit 4 is set in the XOR result → the movement crosses from one 16px tile column to another. Returns result in Z flag (BIT #$0010: Z clear = crossed, Z set = no crossing). Used by ramp/slope routines to gate diagonal Y displacement on tile boundary crossings.

CheckTileBoundaryXor {
    LDA $22               ; CheckTileBoundaryXor: base X pixel = $22 >> 2
    LSR 
    LSR 
    PHA 
    LDA $20               ; X velocity pixel step = $20 >> 2
    LSR 
    LSR 
    CLC 
    ADC $01, S            ; Future X pixel on stack = base + velocity step
    EOR $01, S            ; EOR with pre-step pixel — bit 4 set if 16px sub-column crossed
    STA $01, S
    PLA 
    BIT #$0010            ; BIT #$0010 → carry = crossed tile sub-column boundary
    RTS 
}

---------------------------------------------
; Zero both movement velocity components ($24 = 0, $20 = 0).
; 
; Called when the player is fully blocked in a direction (e.g., sandwiched between two walls) to cancel all pending displacement. 16-bit mode (REP #$20) ensures both bytes are cleared.

ClearMovementDeltas {
    REP #$20              ; ClearMovementDeltas: zero both velocity registers
    STZ $24               ; Zero Y velocity $24
    STZ $20               ; Zero X velocity $20
    RTS 
}

---------------------------------------------
; Set the 'wall collision' flag ($0004) on the current actor.
; 
; Loads actor table index from $000A (saved actor ID × 2), ORs bit $0004 into the actor's flags word at $0010+Y, and stores back. This flag signals to other systems that the actor touched a solid tile during this frame's movement processing.

SetActorCollisionFlag {
    PHP                   ; SetActorCollisionFlag: mark current actor as collision-responded
    REP #$20
    PHY 
    LDY $000A
    LDA $0010, Y          ; Load actor flags word via table index $000A (actor ID × 2)
    ORA #$0004            ; OR in bit 2 ($0004) — actor collided this frame
    STA $0010, Y
    PLY 
    PLP 
    RTS 
}

---------------------------------------------
; Apply pending velocity to position and zero the velocity.
; 
; Adds $20 (X velocity) to $22 (X position) and $24 (Y velocity) to $26 (Y position), then zeroes both velocity words. Standard movement epilogue when the movement check determines no collision blocks the path.

ApplyMovementDeltas {
    REP #$20              ; ApplyMovementDeltas: commit velocities then clear them
    LDA $22               ; $22 += $20 — apply X sub-pixel delta
    CLC 
    ADC $20
    STA $22
    LDA $26               ; $26 += $24 — apply Y sub-pixel delta
    CLC 
    ADC $24
    STA $26
    STZ $20               ; Zero $20/$24 after movement applied
    STZ $24
    RTS 
}

---------------------------------------------
; Probe the bottom-right corner of the player's hitbox at current position.
; 
; X pixel = $22 >> 2 + 7 (right edge), Y pixel = $26 >> 2 − 1 (bottom edge). Calls TileProbeMain. Post-probe: INC $1A (→ +8, one pixel past right edge), INC $1E (→ 0, bottom + 1). These adjustments position the stored coordinates for MapCell navigation by the caller. Returns carry set if collision detected.

ProbeCurrentBR {
    PHP                   ; ProbeCurrentBR: bottom-right corner of current 16×16 hitbox
    REP #$20
    LDA $22               ; $1A = $22>>2 + 7 — right edge (+7px from center-bottom ref)
    LSR 
    LSR 
    CLC 
    ADC #$0007
    STA $1A
    LDA $26               ; $1E = $26>>2 − 1 ($FFFF) — bottom edge (−1px)
    LSR 
    LSR 
    CLC 
    ADC #$FFFF
    STA $1E
    JSR $&TileProbeMain   ; TileProbeMain — carry set if blocking collision at BR
    INC $1A               ; Post-probe INC $1A/$1E — shift 1px inward for MapCell origin
    INC $1E
    BCC loc_02E1A6
    PLP                   ; TileProbeMain blocked — restore flags, SEC RTS
    SEC 
    RTS 

  loc_02E1A6:
    PLP 
    CLC                   ; Passable BR — restore flags, CLC RTS
    RTS 
}

---------------------------------------------
; Probe the top-right corner of the player's hitbox at current position.
; 
; X pixel = $22 >> 2 + 7 (right edge), Y pixel = $26 >> 2 − 16 (top edge). Calls TileProbeMain. Post-probe: INC $1A (→ +8). Returns carry set if collision detected.

ProbeCurrentTR {
    PHP                   ; ProbeCurrentTR: top-right corner at current position
    REP #$20
    LDA $22               ; $1A = $22>>2 + 7 — right edge
    LSR 
    LSR 
    CLC 
    ADC #$0007
    STA $1A
    LDA $26               ; $1E = $26>>2 − 16 ($FFF0) — top edge (−16px)
    LSR 
    LSR 
    CLC 
    ADC #$FFF0
    STA $1E
    JSR $&TileProbeMain   ; TileProbeMain at current TR
    INC $1A               ; INC $1A only — inward from right edge for east MapCell steps
    BCC loc_02E1CA
    PLP 
    SEC                   ; TR probe blocked — SEC RTS
    RTS 

  loc_02E1CA:
    PLP 
    CLC                   ; Passable TR — CLC RTS
    RTS 
}

---------------------------------------------
; Probe the bottom-left corner of the player's hitbox at current position.
; 
; X pixel = $22 >> 2 − 8 (left edge), Y pixel = $26 >> 2 − 1 (bottom edge). Calls TileProbeMain. Post-probe: INC $1E (→ 0). Returns carry set if collision detected.

ProbeCurrentBL {
    PHP                   ; ProbeCurrentBL: bottom-left corner at current position
    REP #$20
    LDA $22               ; $1A = $22>>2 − 8 ($FFF8) — left edge (−8px)
    LSR 
    LSR 
    CLC 
    ADC #$FFF8
    STA $1A
    LDA $26               ; $1E = $26>>2 − 1 — bottom edge
    LSR 
    LSR 
    CLC 
    ADC #$FFFF
    STA $1E
    JSR $&TileProbeMain   ; TileProbeMain at current BL
    INC $1E               ; INC $1E only — inward from bottom for south MapCell steps
    BCC loc_02E1EE
    PLP 
    SEC                   ; BL probe blocked — SEC RTS
    RTS 

  loc_02E1EE:
    PLP 
    CLC                   ; Passable BL — CLC RTS
    RTS 
}

---------------------------------------------
; Probe the top-left corner of the player's hitbox at current position.
; 
; X pixel = $22 >> 2 − 8 (left edge), Y pixel = $26 >> 2 − 16 (top edge). Calls TileProbeMain. No post-probe adjustment. Returns carry from TileProbeMain directly (nonzero collision type = carry set).

ProbeCurrentTL {
    PHP                   ; ProbeCurrentTL: top-left anchor (no post-probe inward shift)
    REP #$20
    LDA $22               ; $1A = $22>>2 − 8 — left edge
    LSR 
    LSR 
    CLC 
    ADC #$FFF8
    STA $1A
    LDA $26               ; $1E = $26>>2 − 16 — top edge
    LSR 
    LSR 
    CLC 
    ADC #$FFF0
    STA $1E
    PLP 
    JSR $&TileProbeMain   ; TileProbeMain at current TL corner
    RTS 
}

---------------------------------------------
; Probe the top-right corner of the player's hitbox at future (post-velocity) position.
; 
; X pixel = ($20 + $22) >> 2 + 7, Y pixel = ($24 + $26) >> 2 − 16. Calls TileProbeMain. Post-probe: INC $1A (→ +8). Returns carry set if collision detected.

ProbeFutureTR {
    PHP                   ; ProbeFutureTR: top-right at position after velocity step
    REP #$20
    LDA $20               ; $1A = ($22+$20)>>2 + 7 — future right edge
    CLC 
    ADC $22
    LSR 
    LSR 
    CLC 
    ADC #$0007
    STA $1A
    LDA $26               ; $1E = ($26+$24)>>2 − 16 — future top edge
    CLC 
    ADC $24
    LSR 
    LSR 
    CLC 
    ADC #$FFF0
    STA $1E
    JSR $&TileProbeMain   ; TileProbeMain at destination TR
    INC $1A               ; INC $1A — inward from right edge
    BCC loc_02E234
    PLP 
    SEC                   ; Future TR blocked — SEC RTS
    RTS 

  loc_02E234:
    PLP 
    CLC                   ; Passable future TR — CLC RTS
    RTS 
}

---------------------------------------------
; Probe the bottom-right corner of the player's hitbox at future position.
; 
; X pixel = ($20 + $22) >> 2 + 7, Y pixel = ($24 + $26) >> 2 − 1. Calls TileProbeMain. Post-probe: INC $1A (→ +8), INC $1E (→ 0). Returns carry set if collision detected.

ProbeFutureBR {
    PHP                   ; ProbeFutureBR: bottom-right at future position
    REP #$20
    LDA $20               ; $1A = ($22+$20)>>2 + 7
    CLC 
    ADC $22
    LSR 
    LSR 
    CLC 
    ADC #$0007
    STA $1A
    LDA $26               ; $1E = ($26+$24)>>2 − 1
    CLC 
    ADC $24
    LSR 
    LSR 
    CLC 
    ADC #$FFFF
    STA $1E
    JSR $&TileProbeMain   ; TileProbeMain at destination BR
    INC $1A               ; INC $1A/$1E — inward from BR corner
    INC $1E
    BCC loc_02E260
    PLP 
    SEC                   ; Future BR blocked — SEC RTS
    RTS 

  loc_02E260:
    PLP 
    CLC                   ; Passable future BR — CLC RTS
    RTS 
}

---------------------------------------------
; Probe the top-left corner of the player's hitbox at future position.
; 
; X pixel = ($20 + $22) >> 2 − 8, Y pixel = ($24 + $26) >> 2 − 16. Calls TileProbeMain. No post-probe adjustment. Returns carry from TileProbeMain directly.

ProbeFutureTL {
    PHP                   ; ProbeFutureTL: top-left at future position (anchor, no inward shift)
    REP #$20
    LDA $20               ; $1A = ($22+$20)>>2 − 8 — future left edge
    CLC 
    ADC $22
    LSR 
    LSR 
    CLC 
    ADC #$FFF8
    STA $1A
    LDA $26               ; $1E = ($26+$24)>>2 − 16 — future top edge
    CLC 
    ADC $24
    LSR 
    LSR 
    CLC 
    ADC #$FFF0
    STA $1E
    PLP 
    JSR $&TileProbeMain   ; TileProbeMain at destination TL
    RTS 
}

---------------------------------------------
; Probe the bottom-left corner of the player's hitbox at future position.
; 
; X pixel = ($20 + $22) >> 2 − 8, Y pixel = ($24 + $26) >> 2 − 1. Calls TileProbeMain. Post-probe: INC $1E (→ 0). Returns carry set if collision detected.

ProbeFutureBL {
    PHP                   ; ProbeFutureBL: bottom-left at future position
    REP #$20
    LDA $20               ; $1A = ($22+$20)>>2 − 8
    CLC 
    ADC $22
    LSR 
    LSR 
    CLC 
    ADC #$FFF8
    STA $1A
    LDA $26               ; $1E = ($26+$24)>>2 − 1
    CLC 
    ADC $24
    LSR 
    LSR 
    CLC 
    ADC #$FFFF
    STA $1E
    JSR $&TileProbeMain   ; TileProbeMain at destination BL
    INC $1E               ; INC $1E — inward from bottom edge
    BCC loc_02E2AC
    PLP 
    SEC                   ; Future BL blocked — SEC RTS
    RTS 

  loc_02E2AC:
    PLP 
    CLC                   ; Passable future BL — CLC RTS
    RTS 
}

---------------------------------------------
; Core tile collision probe — converts pixel coordinates to a collision type.
; 
; Entry: $1A = X pixel, $1E = Y pixel. Validates both are within camera bounds (cameraOffsetX ≤ $1A < cameraBoundsX, cameraOffsetY ≤ $1E < cameraLowerYBound). If out-of-bounds: stores sentinel ($4001) in $00, sets X to $4001, returns A = $0F (solid), carry set.
; 
; If in-bounds: converts to tile coordinates ($1A >> 4 → $18 = tile column, $1E >> 4 → $1C = tile row), calls CalcTileMapOffset (tile_collision_physics) to compute map index in Y, stores map index to $00 and X, then calls ReadCollisionNibble to extract the collision type. Returns A = collision type, carry set if nonzero (blocking), carry clear if zero (passable).

TileProbeMain {
    PHP                   ; TileProbeMain: validate probe pixel in camera bounds, read collision
    REP #$20              ; REP #$20 — 16-bit compares against camera bound words
    LDA $1A               ; Bounds check X: reject negative $1A (BMI → OOB)
    BMI loc_02E2F0
    CMP $cameraOffsetX    ; Reject if $1A < $cameraOffsetX (left of visible map)
    BCC loc_02E2F0
    CMP $cameraBoundsX    ; Reject if $1A ≥ $cameraBoundsX (right of visible map)
    BCS loc_02E2F0
    LSR                   ; In-bounds X: tile column $18 = $1A >> 4
    LSR 
    LSR 
    LSR 
    STA $18
    LDA $1E               ; Bounds check Y: reject negative $1E
    BMI loc_02E2F0
    CMP $cameraOffsetY    ; Reject if $1E < $cameraOffsetY (above visible map)
    BCC loc_02E2F0
    CMP $cameraLowerYBound ; Reject if $1E ≥ $cameraLowerYBound (below visible map)
    BCS loc_02E2F0
    LSR                   ; In-bounds Y: tile row $1C = $1E >> 4
    LSR 
    LSR 
    LSR 
    STA $1C
    PHY 
    JSL $@tile_collision_physics.CalcTileMapOffset ; CalcTileMapOffset($18,$1C) → 16-bit map index in Y
    STY $00               ; Store map index in $00 for MapCell navigation routines
    TYX                   ; TYX — pass map index in X to ReadCollisionNibble
    PLY 
    SEP #$20              ; SEP #$20 — 8-bit index into collisionLayer table
    JSR $&ReadCollisionNibble ; ReadCollisionNibble — BNE if nonzero (blocking)
    BNE loc_02E2ED        ; Zero nibble → passable (CLC RTS, carry clear)
    PLP 
    CLC 
    RTS 

  loc_02E2ED:
    PLP                   ; Nonzero collision → blocked (SEC RTS, carry set)
    SEC 
    RTS 

  loc_02E2F0:
    SEP #$20              ; OOB path: store sentinel map index $4001 in $00
    LDX #$4001
    STX $00
    LDA #$0F              ; OOB returns solid type $0F with carry set
    PLP 
    SEC 
    RTS 
}

---------------------------------------------
; Read collision type from the collision layer at map index X.
; 
; If X ≥ $4000 (out of map bounds), returns $0F (solid). Otherwise loads the byte at collisionLayer ($7FC000) + X. Collision encoding: if the high nibble is nonzero, shifts right ×4 to extract the high nibble as the collision type (layer-priority override). If the high nibble is zero, uses the byte as-is (low nibble = collision type). Sets Z flag via BIT #$FF before returning. Called in 8-bit accumulator mode.

ReadCollisionNibble {
    CPX #$4000            ; Map index ≥ $4000 → invalid/OOB sentinel path
    BCS loc_02E310
    LDA $collisionLayer, X ; Load collision byte from collisionLayer ($7FC000), X
    BIT #$F0              ; High nibble nonzero → use high nibble as collision type override
    BEQ loc_02E30D
    LSR                   ; Shift high nibble down to low byte for return/compare
    LSR 
    LSR 
    LSR 

  loc_02E30D:
    BIT #$FF              ; High nibble zero → low nibble is collision type (BIT sets NZ)
    RTS 

  loc_02E310:
    LDA #$0F              ; Invalid index: return $0F (impassable/solid)
    RTS 
}

---------------------------------------------
; Navigate the map index at $00 to the cell one row below (next row).
; 
; Adds $10 to the low byte (row step within page). On carry (row overflow), adds mapRowStrideL0 to the high byte (advance to next page row). Returns new index in X. Equivalent to MapIndexMoveDown in map_coords.asm.

MapCellDown {
    PHP                   ; MapCellDown: step map index one ROW down (+$10)
    REP #$20
    LDA $00
    SEP #$20
    CLC 
    ADC #$10              ; Add $10 to low byte — next row within 16-row page
    BCS loc_02E322        ; Carry set → row crossed 16-row page boundary downward
    TAX                   ; In-page row step complete — updated index in X
    PLP 
    RTS 

  loc_02E322:
    XBA 
    CLC 
    ADC $mapRowStrideL0   ; Page wrap down: add mapRowStrideL0 ($0693) to high byte
    XBA 
    TAX 
    PLP 
    RTS 
}

---------------------------------------------
; Navigate the map index at $00 to the cell one row above (previous row).
; 
; Subtracts $10 from the low byte. On borrow, subtracts mapRowStrideL0 from the high byte (retreat to previous page row). Returns new index in X. Reverse of MapCellDown.

MapCellUp {
    PHP                   ; MapCellUp: step map index one ROW up (−$10)
    REP #$20
    LDA $00
    SEP #$20
    SEC 
    SBC #$10              ; Subtract $10 from low byte — previous row in page
    BCC loc_02E33A        ; Borrow → crossed page boundary upward
    TAX                   ; In-page row step up complete — updated index in X
    PLP 
    RTS 

  loc_02E33A:
    XBA 
    SEC 
    SBC $mapRowStrideL0   ; Page wrap up: subtract mapRowStrideL0 from high byte
    XBA 
    TAX 
    PLP 
    RTS 
}

---------------------------------------------
; Navigate the map index at $00 to the cell one column to the right (next column).
; 
; Increments the low byte. If the low nibble wraps to zero (BIT #$0F = 0), increments the high byte and adds $F0 to compensate for page boundary crossing. Returns new index in X. Equivalent to MapIndexMoveRight in map_coords.asm.

MapCellRight {
    PHP                   ; MapCellRight: step map index one COLUMN right (INC)
    REP #$20
    LDA $00
    SEP #$20
    INC                   ; INC low byte — next column within current row page
    BIT #$0F
    BEQ loc_02E352        ; Low nibble zero after INC → wrapped past column 15
    TAX                   ; In-page column step right complete — updated index in X
    PLP 
    RTS 

  loc_02E352:
    XBA 
    LDA $01               ; Column wrap: increment high byte (page/row index)
    INC 
    XBA 
    CLC 
    ADC #$F0              ; Reset column to 15 of new page row: low += $F0
    TAX 
    PLP 
    RTS 
}

---------------------------------------------
; Navigate the map index at $00 to the cell one column to the left (previous column).
; 
; Decrements the low byte. If the low nibble underflows to $F (AND #$0F = $0F), decrements the high byte and subtracts $F0. Returns new index in X. Equivalent to MapIndexMoveLeft in map_coords.asm.

MapCellLeft {
    PHP                   ; MapCellLeft: step map index one COLUMN left (DEC)
    REP #$20
    LDA $00
    SEP #$20
    DEC                   ; DEC low byte — previous column within row page
    PHA 
    AND #$0F
    CMP #$0F              ; Low nibble = $0F after DEC → was column 0, need page wrap
    BEQ loc_02E370
    PLA 
    TAX                   ; In-page column step left complete — updated index in X
    PLP 
    RTS 

  loc_02E370:
    PLA 
    XBA 
    LDA $01               ; Column wrap left: decrement high byte (page index)
    DEC 
    XBA 
    SEC                   ; Reset to column 15 of prior page row: low − $F0
    SBC #$F0
    TAX 
    PLP 
    RTS 
}

---------------------------------------------
; Test whether the X pixel coordinate ($1A) is aligned to a 16-pixel tile boundary.
; 
; Tests $1A AND $0F: if zero → carry clear (aligned), if nonzero → carry set (not aligned). Preserves A via PHA/PLA. Used after probes to determine whether the probe hit sits exactly on a tile edge.

CheckSubTileAlignX {
    PHA                   ; CheckSubTileAlignX: carry clear if probe X on 16px tile grid
    LDA $1A
    BIT #$0F              ; Low nibble of $1A — zero means column-aligned
    BNE loc_02E386        ; Nonzero sub-column nibble → misaligned (SEC RTS)
    PLA 
    CLC 
    RTS 

  loc_02E386:
    PLA 
    SEC 
    RTS 
}

---------------------------------------------
; Test whether the Y pixel coordinate ($1E) is aligned to a 16-pixel tile boundary.
; 
; Tests $1E AND $0F: if zero → carry clear (aligned), if nonzero → carry set (not aligned). Preserves A via PHA/PLA. Mirrors CheckSubTileAlignX for the vertical axis.

CheckSubTileAlignY {
    PHA                   ; CheckSubTileAlignY: carry clear if probe Y on 16px tile grid
    LDA $1E
    BIT #$0F              ; Low nibble of $1E — zero means row-aligned
    BNE loc_02E393        ; Nonzero sub-row nibble → misaligned (SEC RTS)
    PLA 
    CLC 
    RTS 

  loc_02E393:
    PLA 
    SEC 
    RTS 
}