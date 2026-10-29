; Tile collision primitives: corner probes, collision-byte reader, map-cell stepping and movement helpers for the player (188674–189334, Bank 02). Outputs to system/player/ next to its callers.
; 
; Callers: every player_move_* block (main, ns, south, east, diag, ramps), the slope_ramp_physics actor (actors/player) and map_coords (FindSlopeForWestMove / FindSlopeForEastMove, which borrow the probes and MapCell steps). Nothing outside the player/slope code uses them (the earlier note said only the player_move_* blocks do).
; 
; === COLLISION BYTE ===
; 
; The collision layer ($7FC000, one byte per 16x16 tile) holds the terrain type in the low nibble and, in the high nibble, the solid mark that actors OR in with MarkSolidHere / MarkSolidOffset / MarkSolidAbs ($F0) and remove with the Clear ops. ReadCollisionNibble returns the high nibble shifted down when it is nonzero ($F0 becomes $0F, solid) and the terrain type otherwise. Types seen by callers: $05 west-facing slope, $0A east-facing slope, $07 ladder, $06 and $09 wall-like types (meaning not decoded; see tile_collision_physics), $0E and above solid.
; 
; === CORNER PROBES ===
; 
; Eight probes sample the corners of the 16x16 hitbox, whose reference point is the centre of the bottom edge: left = pixel - 8, right = pixel + 7, top = pixel - 16, bottom = pixel - 1 (ProbeCurrentTL/TR/BL/BR use $22/$26, ProbeFutureTL/TR/BL/BR use $22 + $20 and $26 + $24; sub-pixels are shifted down by 2 first). Each stores the probe pixel in $1A (X) and $1E (Y) and calls TileProbeMain. Return protocol: A = collision type; carry set when the type is NONZERO, which includes slopes, ladders and wall types as well as solid tiles (callers compare A with $0E for solid); carry clear for type 0. Out of bounds gives A = $0F, carry set.
; 
; The INC $1A / INC $1E after the call in the TR, BL and BR probes move the stored right or bottom coordinate one pixel past the hitbox edge (+8, bottom + 1). That is what makes CheckSubTileAlignX/Y ($1A / $1E & $0F = 0) test 'is this edge flush with a tile boundary' for all four edges (TL needs no INC: its left and top edges are already the first covered pixel). It is not a shift 'inward for MapCell navigation': the MapCell steps start from the map index in $00.
; 
; === TILE PROBE ENGINE ===
; 
; TileProbeMain checks $1A and $1E against the camera bounds (cameraOffsetX/Y up to cameraBoundsX / cameraLowerYBound; negative values are rejected too). Out of bounds: $00 = $4001, A = $0F, carry set. In bounds: tile column $18 = $1A >> 4, tile row $1C = $1E >> 4, CalcTileMapOffset (tile_collision_physics) returns the map index in Y, which is stored in $00 and passed in X to ReadCollisionNibble.
; 
; === MAP CELL STEPS ===
; 
; The map index is page (high byte) and row/column nibbles (low byte): +$10 in the low byte is one row down, +1 one column right. MapCellDown / MapCellUp add or subtract $10 and, on carry or borrow, add or subtract mapRowStrideL0 in the high byte; MapCellRight / MapCellLeft step the low byte and, when the column nibble wraps, step the high byte (one page right or left) and undo the row step with + or - $F0, which lands on column 0 of the next page (right) or column 15 of the previous page (left), same row. Each returns the new index in X; none reads or writes $1A/$1E. Equivalent to the map_coords MapIndexMove* routines. Some callers (slope_ramp_physics) still describe MapCellDown as the 'right' cell.
; 
; === MOVEMENT HELPERS ===
; 
; ApplyMovementDeltas: $22 += $20, $26 += $24, then both velocities are zeroed (standard epilogue of an unblocked step). ClearMovementDeltas zeroes $20 and $24. SetActorCollisionFlag ORs $0004 into the flags word at actor + $10 (solid contact this tick) for the actor slot in $000A. CheckTileBoundaryXor tests whether the X step crosses a 16-pixel column. CombinedProbe_Unused has no call site.
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
    CMP #$000E            ; Primary cell type >= $0E: blocked (falls through to the SEC). Below $0E: go on to the row-above check
    BCC loc_02E128
    PLP 

  loc_02E126:
    SEC                   ; Blocking confirmed — SEC RTS (carry set = collision)
    RTS 

  loc_02E128:
    PLP 
    BEQ loc_02E13D        ; Z from the AND #$000F saved by PHP: set = probe Y is on a 16-pixel boundary, so skip the row-above probe and report passable
    SEP #$20
    JSR $&MapCellUp
    JSR $&ReadCollisionNibble ; Cell above (Y straddles two rows): a type >= $0E there makes the move blocked
    REP #$20
    AND #$00FF
    CMP #$000E            ; Upward neighbor also ≥ $0E → still blocked (SEC path)
    BCS loc_02E126

  loc_02E13D:
    CLC                   ; Passable after neighbor check — CLC RTS
    RTS 
}

---------------------------------------------
; Does the X step $20 move the player into a different 16-pixel column?
; 
; Computes (($22 >> 2) + ($20 >> 2)) XOR ($22 >> 2) (the XOR is with the PRE-step pixel, as the code comment says, not with the step) and tests bit 4 with BIT #$0010. The answer is in Z, not in carry: Z clear = a column boundary is crossed, Z set = no crossing; callers branch with BNE. The step is a logical shift, so a negative velocity becomes a large positive word, but it stays congruent to the signed step modulo $4000 and only bit 4 is used, so the result is still right.

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
    BIT #$0010            ; BIT #$0010 sets Z, not carry: Z clear = a 16-pixel column boundary is crossed
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
; Mark the current actor as having touched a solid tile this tick (flag $0004).
; 
; Y is loaded from $000A, the actor slot address that PlayerMovementTick stored there (the earlier note's 'actor ID x 2' is wrong: Y is used directly as the actor's base address). Bit $0004 of the flags word at actor + $10 is the per-tick solid-contact flag; PlayerMovementTick clears it before each collision pass.

SetActorCollisionFlag {
    PHP                   ; SetActorCollisionFlag: mark current actor as collision-responded
    REP #$20
    PHY 
    LDY $000A
    LDA $0010, Y          ; Actor flags word at actor + $10; Y = $000A, the actor slot address stored by PlayerMovementTick
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
; Probe the bottom-right corner of the player's hitbox at the current position.
; 
; X pixel = $22 >> 2 + 7 (right edge), Y pixel = $26 >> 2 - 1 (bottom edge); calls TileProbeMain; afterwards INC $1A (+8) and INC $1E (bottom + 1) place the stored coordinates one pixel past the right and bottom edges, so that CheckSubTileAlignX/Y report whether those edges are flush with a tile boundary (MapCell steps use the index in $00, not these pixels). Carry set when the type is nonzero.

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
    JSR $&TileProbeMain   ; TileProbeMain at BR: carry set = any nonzero collision type (slopes and ladders too), A = the type
    INC $1A               ; INC $1A / $1E: move the stored right and bottom coordinates one pixel past the hitbox edge for CheckSubTileAlignX/Y
    INC $1E
    BCC loc_02E1A6
    PLP                   ; Nonzero type at BR: restore flags, return with carry set
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
    INC $1A               ; INC $1A: right edge + 1, so CheckSubTileAlignX tests whether the edge is flush with a tile boundary
    BCC loc_02E1CA
    PLP 
    SEC                   ; TR probe found a nonzero type: return with carry set
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
    INC $1E               ; INC $1E: bottom edge + 1, so CheckSubTileAlignY tests whether the edge is flush with a tile boundary
    BCC loc_02E1EE
    PLP 
    SEC                   ; BL probe found a nonzero type: return with carry set
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
    PHP                   ; ProbeCurrentTL: top-left corner; no INC afterwards (the left and top edges are already the first covered pixel)
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
    INC $1A               ; INC $1A: right edge + 1 (CheckSubTileAlignX)
    BCC loc_02E234
    PLP 
    SEC                   ; Future TR found a nonzero type: return with carry set
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
    INC $1A               ; INC $1A / $1E: right and bottom edge + 1 (CheckSubTileAlignX/Y)
    INC $1E
    BCC loc_02E260
    PLP 
    SEC                   ; Future BR found a nonzero type: return with carry set
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
    PHP                   ; ProbeFutureTL: top-left corner at the future position; no INC afterwards
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
    INC $1E               ; INC $1E: bottom edge + 1 (CheckSubTileAlignY)
    BCC loc_02E2AC
    PLP 
    SEC                   ; Future BL found a nonzero type: return with carry set
    RTS 

  loc_02E2AC:
    PLP 
    CLC                   ; Passable future BL — CLC RTS
    RTS 
}

---------------------------------------------
; Core tile collision probe: converts pixel coordinates to a collision type.
; 
; Entry: $1A = X pixel, $1E = Y pixel. Both must lie inside the camera bounds (cameraOffsetX <= $1A < cameraBoundsX, cameraOffsetY <= $1E < cameraLowerYBound; negative values are rejected). Out of bounds: $00 = X = $4001, A = $0F, carry set.
; 
; In bounds: tile column $18 = $1A >> 4 and tile row $1C = $1E >> 4, CalcTileMapOffset (tile_collision_physics) returns the map index in Y, stored in $00 and passed in X to ReadCollisionNibble. Returns A = collision type with carry SET when it is nonzero (any slope, ladder, wall type or solid tile, not only blocking ones; solid is A >= $0E) and carry clear when it is zero.

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
    JSR $&ReadCollisionNibble ; ReadCollisionNibble: Z clear = nonzero type (any terrain type or an actor solid mark, not only solid tiles)
    BNE loc_02E2ED        ; Zero nibble → passable (CLC RTS, carry clear)
    PLP 
    CLC 
    RTS 

  loc_02E2ED:
    PLP                   ; Nonzero type: restore flags, return with carry set (this does not mean solid)
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
; Read the collision type at map index X (8-bit A).
; 
; X >= $4000 (outside the map) returns $0F. Otherwise the byte at collisionLayer ($7FC000) + X is read: if its high nibble is nonzero (the solid mark that actors OR in with $F0) the high nibble is shifted down and returned ($F0 becomes $0F, solid); if it is zero the byte, i.e. the terrain type in the low nibble, is returned. BIT #$FF at the end sets Z when the type is 0.

ReadCollisionNibble {
    CPX #$4000            ; Map index ≥ $4000 → invalid/OOB sentinel path
    BCS loc_02E310
    LDA $collisionLayer, X ; Load collision byte from collisionLayer ($7FC000), X
    BIT #$F0              ; High nibble nonzero = actor solid mark ($F0 from MarkSolidHere and friends): it overrides the terrain type
    BEQ loc_02E30D
    LSR                   ; Shift the high nibble down: $F0 becomes $0F (solid)
    LSR 
    LSR 
    LSR 

  loc_02E30D:
    BIT #$FF              ; High nibble zero: the low nibble, the terrain type, is returned; BIT #$FF sets Z for type 0
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
    ADC #$F0              ; Page wrap right: the INC carried into the row nibble ($x0 of the next row), + $F0 undoes that row step: column 0 of the next page, same row
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