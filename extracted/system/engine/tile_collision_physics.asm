; Tile collision physics and axis-separated movement (250357–251879, Bank 03).
; 
; Implements actor movement with and without tile-based collision detection. The collision system uses axis-separated processing: X axis is resolved first (MoveLeft/MoveRight), then Y axis (MoveUp/MoveDown), each returning carry set on block or carry clear on pass.
; 
; === MOVEMENT SYSTEM ===
; 
; Two movement entry points called from the actor execution post-tick:
; - ApplyMovement: direct delta application with no collision — used when bit 3 ($0008) of $10 is clear, and always by RunActors_OverlayOnly
; - ApplyMovementWithCollision: full tile collision pipeline, used when bit 3 ($0008) of $10 is set
; 
; Both read movement from either an override chain pointer ($2C/$2E → linked movement sources) or per-actor scratch fields (moveScratch1/moveScratch2 at $7F002C/$7F002E). Direction word $12 controls negation: bit 14 ($4000) flips X, bit 13 ($2000) flips Y.
; 
; === COLLISION PIPELINE ===
; 
; For each axis, the pipeline:
; 1. Read delta from override or scratch
; 2. Negate per direction flags
; 3. PEA a post-collision handler as return address
; 4. JMP to MoveLeft/Right or MoveUp/Down based on delta sign
; 5. MoveXxx checks tiles along the leading edge of the hitbox
; 6. Returns carry set (blocked → position snapped to tile boundary) or carry clear (passed)
; 7. Post-collision handler applies residual movement and clears scratch
; 
; CollisionY_Setup includes a bounce mechanism: if both solid-contact ($10 bit 2) and bounce flag (extendedFlags bit 6 = $0040) are set, direction bits are reversed via EOR $6000 on $12.
; 
; === TILE MAP FORMAT ===
; 
; The collision tile map is accessed via long pointer [$80] with offsets computed by CalcTileMapOffset. Each byte encodes two collision nibbles:
; - High nibble ($F0): nonzero = immediately solid (wall)
; - Low nibble ($0F): tile type for dispatch table (0 = passable/check-adjacent, 1–F = solid)
; 
; The map is stored as 256-byte pages of 16×16 tiles (a tile is 16×16 pixels). CalcTileMapOffset builds the offset as: high byte = page = (tileY >> 4) × mapRowStrideL0 ($0693) + (tileX >> 4); low byte = (tileY & $F) << 4 | (tileX & $F). So +$10 in the low byte steps one tile DOWN (+Y) and +1 steps one tile RIGHT (+X).
; 
; === HITBOX DATA ===
; 
; Hitbox dimensions come from the metasprite header at [metaspritePtr]:
; - $0000: X left offset (ORA #$FF00 forces the high byte, so it is always treated as negative: the byte must be ≥ $80)
; - $0001: Y top offset (same treatment)
; - $0002: X width in tiles (horizontal scan count for vertical edges)
; - $0003: Y height in tiles (vertical scan count for horizontal edges)
; 
; For horizontal movement, the leading edge X is computed and tiles are scanned vertically across $0003 rows. For vertical movement, the leading edge Y is computed and tiles are scanned horizontally across $0002 columns.
; 
; === POSITION SNAPPING ===
; 
; When collision occurs, BlockH/BlockV snap the actor position to the nearest tile boundary:
; - Positive delta (moving right/down): AND $FFF0 (snap to left/top edge of blocking tile)
; - Negative delta (moving left/up): AND $FFF0 + $0010 if sub-tile aligned (snap to right/bottom edge)
; 
; The hitbox offset is then subtracted to compute the final actor position. The snap uses only the left/top offset, so it leaves the hitbox flush against the blocking tile only for hitboxes one tile wide/tall.
; 
; === SPECIAL TILES ===
; 
; CheckActorOnSpecialTile probes (actorX − 8, actorY − 16) for two tile patterns:
; - Type $06 at the probe tile and at the diagonal (+X,+Y) neighbor
; - Type $00 at the probe tile with type $09 at both the right (+X) and the below (+Y) neighbor (L-pattern)
; When a pattern matches, the axis routine returns carry set immediately — the axis movement is dropped without snapping and without setting the solid-contact flag ($10 bit 2). Collision types $06 and $09 are not traced to a purpose.
---------------------------------------------

?BANK 03

?INCLUDE 'hardware_math'

!mapRowStrideL0                 0693
!cameraOffsetX                  06D6
!cameraOffsetY                  06D8
!cameraBoundsX                  06DA
!cameraLowerYBound              06DE
!metaspritePtr                  7F000C
!extendedFlags                  7F002A
!moveScratch1                   7F002C
!moveScratch2                   7F002E

---------------------------------------------

; Simple movement delta application without collision checking.
; 
; Reads X delta from override chain pointer $2C (if set) or moveScratch1 ($7F002C,X). If direction flag $12 bit 14 ($4000) is set, negates the delta (X flip). Adds result to actor X position $14 and clears moveScratch1.
; 
; Y axis is identical: reads from $2E / moveScratch2, negates per $12 bit 13 ($2000), applies to $16.
; 
; Override pointers form a linked chain: $0000,Y = movement value, $0002,Y = next link pointer (written to $2C/$2E for the next frame). If the pointer is zero, falls through to the per-actor scratch field.
; 
; Called by the actor post-tick when bit 3 ($0008) of $10 is clear, and by RunActors_OverlayOnly for every overlay actor.

ApplyMovement {
    LDA $2C               ; X override pointer $2C: if set, chains delta from external movement source
    BEQ loc_03D214
    TAY 
    LDA $0002, Y
    STA $2C               ; $0002,Y = next link in movement chain
    LDA $12
    BIT #$4000            ; Bit 14 ($4000) in $12: negate (flip) the X delta
    BEQ loc_03D20F
    LDA $0000, Y
    EOR #$FFFF
    INC 
    BRA loc_03D229

  loc_03D20F:
    LDA $0000, Y
    BRA loc_03D229

  loc_03D214:
    LDA $12
    BIT #$4000
    BEQ loc_03D225
    LDA $moveScratch1, X
    EOR #$FFFF
    INC 
    BRA loc_03D229

  loc_03D225:
    LDA $moveScratch1, X

  loc_03D229:
    CLC                   ; Apply delta to X position; zero scratch to prevent re-application
    ADC $14
    STA $14
    LDA #$0000
    STA $moveScratch1, X
    LDA $2E               ; Y axis: same override/negate/apply via $2E, moveScratch2, bit 13 ($2000)
    BEQ loc_03D254
    TAY 
    LDA $0002, Y
    STA $2E
    LDA $12
    BIT #$2000
    BEQ loc_03D24F
    LDA $0000, Y
    EOR #$FFFF
    INC 
    BRA loc_03D269

  loc_03D24F:
    LDA $0000, Y
    BRA loc_03D269

  loc_03D254:
    LDA $12
    BIT #$2000
    BEQ loc_03D265
    LDA $moveScratch2, X
    EOR #$FFFF
    INC 
    BRA loc_03D269

  loc_03D265:
    LDA $moveScratch2, X

  loc_03D269:
    CLC 
    ADC $16
    STA $16
    LDA #$0000
    STA $moveScratch2, X
    RTS 
}

---------------------------------------------
; Collision-aware movement entry point — axis-separated tile collision pipeline.
; 
; Pre-computes the lower Y camera bound (absolute scratch $0004 = cameraLowerYBound − $0010) for vertical clipping; MoveUp/MoveDown compare against it. Then processes X and Y axes independently:
; 
; X axis: reads delta from override $2C or moveScratch1, negates per $12 bit 14. PEA pushes CollisionX_PostMove − 1 as the return address, then dispatches to TileCollision_MoveLeft (negative delta) or TileCollision_MoveRight (positive). The collision routine returns via RTS into CollisionX_PostMove.
; 
; Y axis: same pattern with $2E / moveScratch2, bit 13, dispatching to MoveUp/MoveDown via CollisionY_Setup.
; 
; Called by the actor post-tick when bit 3 ($0008) of $10 is set.

ApplyMovementWithCollision {
    LDA $cameraLowerYBound ; Lower camera Y bound − 16px: vertical collision limit → $0004
    SEC 
    SBC #$0010
    STA $0004
    LDA $2C               ; X override chain: read delta or fall back to moveScratch1
    BEQ loc_03D291
    TAY 
    LDA $0000, Y
    BNE loc_03D297
    LDA $0002, Y
    STA $2C
    BRA loc_03D2FD

  loc_03D291:
    LDA $moveScratch1, X
    BEQ loc_03D2FD

  loc_03D297:
    STA $001A             ; Store raw delta to $001A for collision subroutines
    LDA $12
    BIT #$4000            ; Negate if direction bit 14 ($4000) set
    BEQ loc_03D2AB
    LDA $001A
    EOR #$FFFF
    INC 
    STA $001A

  loc_03D2AB:
    LDA $001A
    PEA $&CollisionX_PostMove-1 ; PEA return to CollisionX_PostMove; dispatch left/right by delta sign
    BPL loc_03D2B6
    JMP $&TileCollision_MoveLeft

  loc_03D2B6:
    JMP $&TileCollision_MoveRight
}

---------------------------------------------
; Post-collision handler for the X axis — applies residual movement after tile check.
; 
; Returned to via PEA/RTS from MoveLeft/MoveRight. Carry flag from the collision routine indicates result: set = blocked, clear = passed.
; 
; If not blocked (carry clear), reads residual delta from override chain or moveScratch1 (same negation logic as the initial path) and adds to $14. Clears moveScratch1 regardless.
; 
; Then begins the Y axis pipeline: reads Y delta from $2E / moveScratch2, stores to $001E, negates per $12 bit 13, and dispatches to MoveUp/MoveDown with CollisionY_Setup as the PEA return.

CollisionX_PostMove {
    LDA $2C               ; After X collision: check for residual override movement
    BEQ loc_03D2DA
    TAY 
    LDA $0002, Y
    STA $2C
    BCS loc_03D2FD        ; Carry set from MoveLeft/Right = X blocked; skip remaining delta
    LDA $12
    BIT #$4000
    BEQ loc_03D2D5
    LDA $0000, Y
    EOR #$FFFF
    INC 
    BRA loc_03D2F1

  loc_03D2D5:
    LDA $0000, Y
    BRA loc_03D2F1

  loc_03D2DA:
    BCS loc_03D2F6
    LDA $12
    BIT #$4000
    BEQ loc_03D2ED
    LDA $moveScratch1, X
    EOR #$FFFF
    INC 
    BRA loc_03D2F1

  loc_03D2ED:
    LDA $moveScratch1, X

  loc_03D2F1:
    CLC 
    ADC $14
    STA $14

  loc_03D2F6:
    LDA #$0000            ; Clear X movement scratch regardless of collision result
    STA $moveScratch1, X

  loc_03D2FD:
    CLC                   ; Begin Y axis: read override $2E or moveScratch2 for vertical delta
    LDA $2E
    BEQ loc_03D30F
    TAY 
    LDA $0000, Y
    BNE loc_03D315
    LDA $0002, Y
    STA $2E
    BRA loc_03D37B

  loc_03D30F:
    LDA $moveScratch2, X
    BEQ loc_03D37B

  loc_03D315:
    STA $001E
    LDA $12
    BIT #$2000
    BEQ loc_03D329
    LDA $001E
    EOR #$FFFF
    INC 
    STA $001E

  loc_03D329:
    LDA $001E             ; PEA return to CollisionY_Setup; dispatch up/down by Y delta sign
    PEA $&CollisionY_Setup-1
    BPL loc_03D334
    JMP $&TileCollision_MoveUp

  loc_03D334:
    JMP $&TileCollision_MoveDown
}

---------------------------------------------
; Post-collision handler for the Y axis, plus bounce/reflect detection.
; 
; Same residual-movement pattern as CollisionX_PostMove but for Y: applies remaining Y delta to $16 if not blocked. Clears moveScratch2.
; 
; After movement, checks for the bounce condition:
; 1. $10 bit 2 ($0004) = solid contact occurred this frame
; 2. extendedFlags bit 6 ($0040) = bounce flag (set by actor AI scripts)
; 
; If both are set, clears the bounce flag and reverses both direction bits by EOR $6000 on $12 — effectively reflecting the actor's movement direction on both axes.

CollisionY_Setup {
    LDA $2E               ; After Y collision: apply residual Y override if not blocked
    BEQ loc_03D358
    TAY 
    LDA $0002, Y
    STA $2E
    BCS loc_03D37B        ; Carry set = Y blocked; skip to cleanup
    LDA $12
    BIT #$2000
    BEQ loc_03D353
    LDA $0000, Y
    EOR #$FFFF
    INC 
    BRA loc_03D36F

  loc_03D353:
    LDA $0000, Y
    BRA loc_03D36F

  loc_03D358:
    BCS loc_03D374
    LDA $12
    BIT #$2000
    BEQ loc_03D36B
    LDA $moveScratch2, X
    EOR #$FFFF
    INC 
    BRA loc_03D36F

  loc_03D36B:
    LDA $moveScratch2, X

  loc_03D36F:
    CLC 
    ADC $16
    STA $16

  loc_03D374:
    LDA #$0000            ; Clear Y movement scratch
    STA $moveScratch2, X

  loc_03D37B:
    LDA $10               ; Bounce detect: bit 2 ($0004) in $10 = solid contact this frame
    BIT #$0004
    BNE loc_03D383
    RTS 

  loc_03D383:
    LDA $extendedFlags, X ; extendedFlags bit 6 ($0040) = bounce flag set by actor AI
    BIT #$0040
    BNE loc_03D38D
    RTS 

  loc_03D38D:
    AND #$FFBF            ; Clear bounce flag; EOR $6000 reverses both X and Y direction bits
    STA $extendedFlags, X
    LDA $12
    EOR #$6000
    STA $12
    RTS 
}

---------------------------------------------
; Check leftward tile collision along the actor's left hitbox edge.
; 
; Saves DBR and sets DP to page zero for scratch access. Computes trial X = delta + position ($18). Calls CheckActorOnSpecialTile; if on special tile, aborts immediately (restore DBR, return).
; 
; Switches DBR to the actor's sprite-data bank ($7F0008,X, the bank byte next to spritesetPtr, via PHA/PLB) so that $0000,Y reads the hitbox header; the collision map itself is read through the long pointer [$80]. Reads hitbox from metasprite header: height ($0003,Y) = vertical tile span, X offset ($0000,Y) = left edge (always negative, see header). Computes left-edge pixel X and validates against camera bounds; out-of-bounds positions are treated as type $0F (unconditional solid).
; 
; Converts pixel coordinates to tile indices (>>4) and calls CalcTileMapOffset. Scans down the leading edge (+Y, via AdvanceTileOffsetY) through $0E tiles: for each, reads the collision byte via [$80],Y. High nibble ($F0) nonzero = immediate solid → BlockH. Low nibble = tile type; type 0 with rows remaining → advance and continue. Otherwise (a nonzero type, or type 0 on the last row) dispatch through TileTypeJumpTable_Horizontal; type 0 then lands in CheckAdjacentH, which looks one row further when the actor is not tile-aligned in Y.
; 
; The PHA before the Y-to-tile conversion pushes the raw pixel Y for use by CheckAdjacentH's sub-tile alignment test.

TileCollision_MoveLeft {
    PHB                   ; Save DBR; trial X = delta + current position
    CLC 
    ADC $14
    STA $0018
    LDA #$0000            ; DP = page zero for scratch variable access ($00–$1E)
    TCD 
    JSR $&CheckActorOnSpecialTile ; Special-tile pattern ($06/$09): return carry set — this axis' movement is dropped, no snap
    BCC loc_03D3B0
    PLB 
    TXA 
    TCD 
    RTS 

  loc_03D3B0:
    LDA $metaspritePtr, X ; Load metasprite header for hitbox dimensions
    TAY 
    SEP #$20
    LDA $7F0008, X        ; Switch DBR to the actor's sprite-data bank ($7F0008,X) via PHA/PLB so $0000,Y reads the hitbox header
    PHA 
    PLB 
    REP #$20
    LDA $0003, Y          ; Hitbox height ($0003,Y) = vertical tile rows to scan
    AND #$00FF
    STA $0E
    LDA $0000, Y          ; Left edge X: signed offset ($0000,Y | $FF00) + trial position
    ORA #$FF00
    CLC 
    ADC $18
    BMI loc_03D419        ; Out of camera bounds → fall through to type $0F (solid wall)
    CMP $cameraOffsetX
    BCC loc_03D419
    CMP $cameraBoundsX
    BCS loc_03D419
    LSR                   ; Pixel-to-tile: >>4 converts pixel coordinate to tile column
    LSR 
    LSR 
    LSR 
    STA $18
    LDA $0001, Y          ; Top Y: signed offset ($0001,Y) + actor Y → push raw pixel for stack
    ORA #$FF00
    CLC 
    ADC $0016, X
    PHA 
    LSR 
    LSR 
    LSR 
    LSR 
    STA $1C
    JSL $@CalcTileMapOffset ; Compute tile map offset; begin vertical scan of leading left edge
    STY $00

  loc_03D3F9:
    LDA [$80], Y
    BIT #$00F0            ; High nibble ($F0) nonzero = immediate solid → BlockH
    BEQ loc_03D403
    JMP $&TileCollision_BlockH

  loc_03D403:
    AND #$000F            ; Low nibble = tile type; 0 with rows remaining → advance and rescan
    BNE loc_03D413
    DEC $0E
    BEQ loc_03D413
    JSR $&AdvanceTileOffsetY
    STY $00
    BRA loc_03D3F9

  loc_03D413:
    ASL                   ; Type ×2 = word-table index (X); TXY parks the actor slot in Y for the handler
    TXY 
    TAX 
    JMP ($&TileTypeJumpTable_Horizontal, X)

  loc_03D419:
    PHA                   ; Off-camera fallback: treat as type $0F (unconditional solid)
    LDA #$000F
    BRA loc_03D413
}

---------------------------------------------
; Check rightward tile collision along the actor's right hitbox edge.
; 
; Same structure as TileCollision_MoveLeft with two differences:
; 1. Right edge X = left offset + trial X − 1 (DEC for inclusive edge), plus hitbox width ($0002,Y) added to the tile column after conversion
; 2. Camera bounds check adds +$0010 (one tile width) then subtracts back, ensuring the full 16-pixel right edge fits within bounds
; 
; Otherwise identical vertical scan loop and tile type dispatch.

TileCollision_MoveRight {
    PHB                   ; Same structure as MoveLeft for rightward movement
    CLC 
    ADC $14
    STA $0018
    LDA #$0000
    TCD 
    JSR $&CheckActorOnSpecialTile
    BCC loc_03D433
    PLB 
    TXA 
    TCD 
    RTS 

  loc_03D433:
    LDA $metaspritePtr, X
    TAY 
    SEP #$20
    LDA $7F0008, X
    PHA 
    PLB 
    REP #$20
    LDA $0003, Y          ; Hitbox height for vertical scan; right edge = offset + trial X − 1
    AND #$00FF
    STA $0E
    LDA $0000, Y
    ORA #$FF00
    CLC 
    ADC $18
    DEC 
    BMI loc_03D419
    CMP $cameraOffsetX
    BCC loc_03D419
    CLC                   ; Right edge + 16 must be within camera bounds
    ADC #$0010
    CMP $cameraBoundsX
    BCS loc_03D419
    SEC 
    SBC #$0010
    LSR 
    LSR 
    LSR 
    LSR 
    STA $18
    LDA $0002, Y          ; Add hitbox width ($0002,Y) for rightmost tile column
    AND #$00FF
    CLC 
    ADC $18
    STA $18
    LDA $0001, Y
    ORA #$FF00
    CLC 
    ADC $0016, X
    PHA 
    LSR 
    LSR 
    LSR 
    LSR 
    STA $1C
    JSL $@CalcTileMapOffset
    STY $00

  loc_03D490:
    LDA [$80], Y          ; Same vertical scan loop: high/low nibble collision check
    BIT #$00F0
    BNE TileCollision_BlockH
    AND #$000F
    BNE loc_03D4A7
    DEC $0E
    BEQ loc_03D4A7
    JSR $&AdvanceTileOffsetY
    STY $00
    BRA loc_03D490

  loc_03D4A7:
    ASL 
    TXY 
    TAX 
    JMP ($&TileTypeJumpTable_Horizontal, X)
}

---------------------------------------------
; 16-entry jump table for horizontal tile type dispatch.
; 
; Indexed by (tile_type × 2) from the low nibble of the collision byte. Entry 0 = TileCollision_CheckAdjacentH (sub-tile boundary test). Entries 1–F all point to TileCollision_SolidH (unconditional solid).

TileTypeJumpTable_Horizontal [
  &TileCollision_CheckAdjacentH   ;00
  &TileCollision_SolidH   ;01
  &TileCollision_SolidH   ;02
  &TileCollision_SolidH   ;03
  &TileCollision_SolidH   ;04
  &TileCollision_SolidH   ;05
  &TileCollision_SolidH   ;06
  &TileCollision_SolidH   ;07
  &TileCollision_SolidH   ;08
  &TileCollision_SolidH   ;09
  &TileCollision_SolidH   ;0A
  &TileCollision_SolidH   ;0B
  &TileCollision_SolidH   ;0C
  &TileCollision_SolidH   ;0D
  &TileCollision_SolidH   ;0E
  &TileCollision_SolidH   ;0F
]

---------------------------------------------
; Unconditional horizontal solid — TYX restores X = actor slot (Y held it since the jump-table dispatch) and falls through to TileCollision_BlockH.

TileCollision_SolidH {
    TYX 
}

---------------------------------------------
; Handle horizontal collision blocking — snap actor position to tile boundary.
; 
; Restores DP from actor slot (TXA/TCD). Sets solid-contact flag ($0004) in actor flags $10 via TSB.
; 
; Two snap paths based on movement direction ($001A sign):
; 
; Positive (rightward): computes (position + hitboxOffset + delta), AND $FFF0 to snap to the left edge of the blocking tile. Subtracts hitbox offset for final actor X.
; 
; Negative (leftward): same computation but rounds up — if not already tile-aligned (BIT $000F), applies AND $FFF0 + $0010 to snap to the next tile boundary (right edge of blocking tile). Subtracts hitbox offset.
; 
; Both paths PLA/PLB to discard the stacked pixel position and restore DBR, then return with carry set (blocked).

TileCollision_BlockH {
    TXA 
    TCD 
    LDA #$0004            ; Set solid-contact flag $0004 in actor flags $10
    TSB $10
    LDA $001A             ; Positive delta = rightward: snap to left edge of blocking tile
    BMI loc_03D506
    LDA $metaspritePtr, X ; actorX + hitboxOffset + delta → AND $FFF0 = tile-aligned position
    TAY 
    LDA $0000, Y
    ORA #$FF00
    CLC 
    ADC $14
    CLC 
    ADC $001A
    AND #$FFF0
    STA $001A
    LDA $0000, Y          ; Final X = snapped − hitbox offset; SEC = blocked
    ORA #$FF00
    EOR #$FFFF
    INC 
    CLC 
    ADC $001A
    STA $14
    PLA 
    PLB 
    SEC 
    RTS 

  loc_03D506:
    LDA $metaspritePtr, X ; Negative delta = leftward: snap with round-up if sub-tile
    TAY 
    LDA $0000, Y
    ORA #$FF00
    CLC 
    ADC $14
    CLC 
    ADC $001A
    BIT #$000F
    BEQ loc_03D524
    AND #$FFF0            ; Not tile-aligned: AND $FFF0 + $0010 = right edge of blocking tile
    CLC 
    ADC #$0010

  loc_03D524:
    STA $001A
    LDA $0000, Y          ; Final X = snapped − hitbox offset; SEC = blocked
    ORA #$FF00
    EOR #$FFFF
    INC 
    CLC 
    ADC $001A
    STA $14
    PLA 
    PLB 
    SEC 
    RTS 
}

---------------------------------------------
; No horizontal collision — restore DP from actor slot, discard stacked pixel position (PLA), restore DBR (PLB), return with carry clear.

TileCollision_PassH {
    TXA                   ; No collision: restore DP and DBR; CLC = unblocked
    TCD 
    PLA 
    PLB 
    CLC 
    RTS 
}

---------------------------------------------
; Sub-tile boundary check for horizontal type-0 tiles.
; 
; Reads the stacked pixel Y ($01,S, pushed by MoveLeft/MoveRight) and tests the low 4 bits. If exactly on a tile boundary (bits = 0), passes through — the actor's edge covers only the scanned rows.
; 
; If misaligned, the edge also overlaps one more row: AdvanceTileOffsetY (+Y, one tile down) and test that byte via [$80],Y. If it is zero (empty), passes. If nonzero, jumps to BlockH.

TileCollision_CheckAdjacentH {
    TYX 
    LDA $01, S            ; Read pixel Y from stack (pushed in MoveLeft/Right)
    BIT #$000F            ; Low 4 bits = 0 → on exact tile boundary → pass through
    BEQ TileCollision_PassH
    JSR $&AdvanceTileOffsetY ; Misaligned in Y: also check the next row down (+Y)
    LDA [$80], Y
    AND #$00FF
    BEQ TileCollision_PassH
    JMP $&TileCollision_BlockH
}

---------------------------------------------
; Check upward tile collision along the actor's top hitbox edge.
; 
; Same structure as TileCollision_MoveLeft but for vertical movement. Uses hitbox width ($0002,Y) as the horizontal tile span to scan, and Y offset ($0001,Y) for the top edge. Computes X from $0000,Y + actor X.
; 
; Scans along the top edge (+X, via AdvanceTileOffsetX) through $0E tiles. Out-of-bounds Y positions are treated as type $0F (solid).

TileCollision_MoveUp {
    PHB                   ; Same pattern as MoveLeft but for upward Y movement
    CLC 
    ADC $16
    STA $001C
    LDA #$0000
    TCD 
    JSR $&CheckActorOnSpecialTile
    BCC loc_03D56A
    PLB 
    TXA 
    TCD 
    RTS 

  loc_03D56A:
    LDA $metaspritePtr, X
    TAY 
    SEP #$20
    LDA $7F0008, X
    PHA 
    PLB 
    REP #$20
    LDA $0002, Y          ; Hitbox width ($0002,Y) = horizontal tile columns to scan
    AND #$00FF
    STA $0E
    LDA $0000, Y          ; Hitbox X from $0000,Y + actor X; push raw pixel for stack
    ORA #$FF00
    CLC 
    ADC $0014, X
    PHA 
    LSR 
    LSR 
    LSR 
    LSR 
    STA $18
    LDA $0001, Y          ; Top edge Y: signed offset ($0001,Y) + trial Y position
    ORA #$FF00
    CLC 
    ADC $1C
    BMI loc_03D5D2        ; Camera bounds check; $04 = lower Y limit from ApplyMovementWithCollision
    CMP $cameraOffsetY
    BCC loc_03D5D2
    CMP $04
    BCS loc_03D5D2
    LSR 
    LSR 
    LSR 
    LSR 
    STA $1C
    JSL $@CalcTileMapOffset ; CalcTileMapOffset; scan horizontally via AdvanceTileOffsetX
    STY $00

  loc_03D5B2:
    LDA [$80], Y
    BIT #$00F0            ; High nibble nonzero = solid → BlockV
    BEQ loc_03D5BC
    JMP $&TileCollision_BlockV

  loc_03D5BC:
    AND #$000F
    BNE loc_03D5CC
    DEC $0E
    BEQ loc_03D5CC
    JSR $&AdvanceTileOffsetX
    STY $00
    BRA loc_03D5B2

  loc_03D5CC:
    ASL 
    TXY 
    TAX 
    JMP ($&TileTypeJumpTable_Vertical, X)

  loc_03D5D2:
    LDA #$000F            ; Off-camera fallback → type $0F (solid wall)
    BRA loc_03D5CC
}

---------------------------------------------
; Check downward tile collision along the actor's bottom hitbox edge.
; 
; Same structure as TileCollision_MoveUp with bottom-edge adjustments: DEC before >>4 to get the correct tile row, then adds hitbox height ($0003,Y) to the tile Y coordinate for the bottommost row.
; 
; Otherwise identical horizontal scan loop and vertical tile type dispatch.

TileCollision_MoveDown {
    PHB                   ; Downward collision: same structure as MoveUp
    CLC 
    ADC $16
    STA $001C
    LDA #$0000
    TCD 
    JSR $&CheckActorOnSpecialTile
    BCC loc_03D5EB
    PLB 
    TXA 
    TCD 
    RTS 

  loc_03D5EB:
    LDA $metaspritePtr, X
    TAY 
    SEP #$20
    LDA $7F0008, X
    PHA 
    PLB 
    REP #$20
    LDA $0002, Y          ; Hitbox width for horizontal scan
    AND #$00FF
    STA $0E
    LDA $0000, Y
    ORA #$FF00
    CLC 
    ADC $0014, X
    PHA 
    LSR 
    LSR 
    LSR 
    LSR 
    STA $18
    LDA $0001, Y          ; Bottom edge Y: offset + trial Y; DEC before >>4 for correct tile row
    ORA #$FF00
    CLC 
    ADC $1C
    BMI loc_03D5D2
    CMP $cameraOffsetY
    BCC loc_03D5D2
    CMP $04
    BCS loc_03D5D2
    DEC 
    LSR 
    LSR 
    LSR 
    LSR 
    STA $1C
    LDA $0003, Y          ; Add hitbox height ($0003,Y) for bottommost tile row
    AND #$00FF
    CLC 
    ADC $1C
    STA $1C
    JSL $@CalcTileMapOffset ; CalcTileMapOffset; scan bottom edge horizontally
    STY $00

  loc_03D63F:
    LDA [$80], Y
    BIT #$00F0
    BNE TileCollision_BlockV
    AND #$000F
    BNE loc_03D656
    DEC $0E
    BEQ loc_03D656
    JSR $&AdvanceTileOffsetX
    STY $00
    BRA loc_03D63F

  loc_03D656:
    ASL 
    TXY 
    TAX 
    JMP ($&TileTypeJumpTable_Vertical, X)
}

---------------------------------------------
; 16-entry jump table for vertical tile type dispatch.
; 
; Indexed by (tile_type × 2). Entry 0 = TileCollision_CheckAdjacentV, entries 1–F = TileCollision_SolidV.

TileTypeJumpTable_Vertical [
  &TileCollision_CheckAdjacentV   ;00
  &TileCollision_SolidV   ;01
  &TileCollision_SolidV   ;02
  &TileCollision_SolidV   ;03
  &TileCollision_SolidV   ;04
  &TileCollision_SolidV   ;05
  &TileCollision_SolidV   ;06
  &TileCollision_SolidV   ;07
  &TileCollision_SolidV   ;08
  &TileCollision_SolidV   ;09
  &TileCollision_SolidV   ;0A
  &TileCollision_SolidV   ;0B
  &TileCollision_SolidV   ;0C
  &TileCollision_SolidV   ;0D
  &TileCollision_SolidV   ;0E
  &TileCollision_SolidV   ;0F
]

---------------------------------------------
; Handle vertical collision blocking — snap actor Y position to tile boundary.
; 
; Same algorithm as TileCollision_BlockH but operates on the Y axis: uses $001E (Y delta), $0001,Y (Y hitbox offset), and writes final position to $16.
; 
; Positive (downward): AND $FFF0 snap to top edge of blocking tile.
; Negative (upward): AND $FFF0 + $0010 round-up snap.
; 
; Returns with carry set (blocked).

TileCollision_BlockV {
    TXA 
    TCD 
    LDA #$0004            ; Same snap algorithm as BlockH but for Y axis using $001E/$0001,Y/$16
    TSB $10
    LDA $001E             ; Positive delta = downward: AND $FFF0 snap to top of blocking tile
    BMI loc_03D6B4
    LDA $metaspritePtr, X
    TAY 
    LDA $0001, Y
    ORA #$FF00
    CLC 
    ADC $16
    CLC 
    ADC $001E
    AND #$FFF0
    STA $001E
    LDA $0001, Y
    ORA #$FF00
    EOR #$FFFF
    INC 
    CLC 
    ADC $001E
    STA $16
    PLA 
    PLB 
    SEC 
    RTS 

  loc_03D6B4:
    LDA $metaspritePtr, X ; Negative delta = upward: round-up snap (AND $FFF0 + $10 if sub-tile)
    TAY 
    LDA $0001, Y
    ORA #$FF00
    CLC 
    ADC $16
    CLC 
    ADC $001E
    BIT #$000F
    BEQ loc_03D6D2
    AND #$FFF0
    CLC 
    ADC #$0010

  loc_03D6D2:
    STA $001E
    LDA $0001, Y
    ORA #$FF00
    EOR #$FFFF
    INC 
    CLC 
    ADC $001E
    STA $16
    PLA 
    PLB 
    SEC 
    RTS 
}

---------------------------------------------
; No vertical collision — restore DP, discard stacked pixel position, restore DBR, return carry clear.

TileCollision_PassV {
    TXA 
    TCD 
    PLA 
    PLB 
    CLC 
    RTS 
}

---------------------------------------------
; Sub-tile boundary check for vertical type-0 tiles.
; 
; Same logic as TileCollision_CheckAdjacentH but for vertical movement: tests low 4 bits of the stacked pixel X (pushed by MoveUp/MoveDown). If misaligned, also checks the tile to the right (+X, AdvanceTileOffsetX). Nonzero → BlockV, zero → pass.

TileCollision_CheckAdjacentV {
    TYX 
    LDA $01, S            ; Stacked pixel X: sub-tile alignment test
    BIT #$000F
    BEQ TileCollision_PassV
    JSR $&AdvanceTileOffsetX ; Misaligned in X: also check the next tile to the right (+X)
    LDA [$80], Y
    AND #$00FF
    BEQ TileCollision_PassV
    JMP $&TileCollision_BlockV
}

---------------------------------------------
; Unconditional vertical solid — TYX restores X = actor slot (Y held it since the jump-table dispatch) and jumps to TileCollision_BlockV.

TileCollision_SolidV {
    TYX 
    JMP $&TileCollision_BlockV
}

---------------------------------------------
; Check if the actor is standing on special tile patterns that bypass normal collision.
; 
; Saves $18/$1C. Probes the tile at (actorX − 8, actorY − 16) — the tile above-left of the actor origin. If either coordinate is tile-aligned (low 4 bits = 0), returns CLC (no special tile).
; 
; Converts to tile coordinates and reads the collision map. Two detection patterns:
; 
; 1. Tile = $06: checks the (+X,+Y) diagonal neighbor. If that is also $06, returns SEC (special).
; 2. Tile = $00 (empty): checks the tile to the right (+X); if it is $09, restores the offset and checks the tile below (+Y). If both are $09, returns SEC (L-shaped special pattern).
; 
; All other tiles or incomplete patterns → CLC (normal collision applies). Callers treat SEC as "axis blocked" (see header).

CheckActorOnSpecialTile {
    LDA $18               ; Load tile coords $18/$1C; will restore on exit
    PHA 
    LDA $1C
    PHA 
    LDA $0014, X          ; Actor X − 8: probe column (hitbox offsets not used)
    SEC 
    SBC #$0008
    BIT #$000F            ; Sub-tile aligned (low 4 bits = 0) → no special tile
    BEQ loc_03D782
    LSR 
    LSR 
    LSR 
    LSR 
    STA $18
    LDA $0016, X          ; Actor Y − 16: probe row (hitbox offsets not used)
    SEC 
    SBC #$0010
    BIT #$000F
    BEQ loc_03D782
    LSR 
    LSR 
    LSR 
    LSR 
    STA $1C
    JSL $@CalcTileMapOffset ; CalcTileMapOffset for probe position
    STY $00
    LDA [$80], Y
    AND #$00FF            ; Read tile type; $00 → check $09 L-pattern below
    BEQ loc_03D758
    CMP #$0006            ; Type $06 → verify right + down diagonal also $06
    BNE loc_03D782
    JSR $&AdvanceTileOffsetY ; +Y (one tile down)
    STY $00
    JSR $&AdvanceTileOffsetX
    LDA [$80], Y
    AND #$00FF
    CMP #$0006
    BNE loc_03D782
    BRA loc_03D77A

  loc_03D758:
    LDA $00               ; Type $00: save offset, check right (+X) for $09, then below (+Y) for $09
    STA $02
    JSR $&AdvanceTileOffsetX
    LDA [$80], Y
    AND #$00FF
    CMP #$0009
    BNE loc_03D782
    LDA $02
    STA $00
    JSR $&AdvanceTileOffsetY
    LDA [$80], Y
    AND #$00FF
    CMP #$0009
    BNE loc_03D782

  loc_03D77A:
    PLA                   ; Pattern matched: restore coords, SEC = special tile detected
    STA $1C
    PLA 
    STA $18
    SEC 
    RTS 

  loc_03D782:
    PLA                   ; No match: restore coords, CLC = normal collision applies
    STA $1C
    PLA 
    STA $18
    CLC 
    RTS 
}

---------------------------------------------
; Convert tile coordinates ($18 = X, $1C = Y) to a tile map byte offset in Y.
; 
; The map is stored as 256-byte pages of 16×16 tiles. The offset's low byte is (tileY & $F) << 4 | (tileX & $F) (row-major inside the page); its high byte is the page number = (tileY >> 4) × mapRowStrideL0 + (tileX >> 4), where the product comes from hardware Multiply8x8Unsigned (A low byte = stride, B = tileY >> 4 left over from the shift). Returns the 16-bit offset in Y.
; 
; The tile map is accessed via long pointer [$80] which points to the current scene's collision data.

CalcTileMapOffset {
    PHP 
    LDA $1C               ; tileY << 4: low byte = in-page row (high nibble), high byte = tileY >> 4 = page row
    ASL 
    ASL 
    ASL 
    ASL 
    PHA 
    SEP #$20
    LDA $mapRowStrideL0   ; A = stride, B = page row → Multiply8x8Unsigned gives stride × page row (the high byte of the offset)
    JSL $@hardware_math.Multiply8x8Unsigned
    STA $02, S
    LDA $18               ; X tile low nibble = column inside the page; add to low byte
    AND #$0F
    CLC 
    ADC $01, S
    STA $01, S
    LDA $18               ; X tile high nibble = page column; add to high byte
    LSR 
    LSR 
    LSR 
    LSR 
    CLC 
    ADC $02, S
    STA $02, S
    PLY 
    PLP 
    RTL 
}

---------------------------------------------
; Advance the tile map offset one tile DOWN (+Y).
; 
; Adds $10 to the low byte of $00 — the next row inside the 16×16 page. If the addition carries (crossed the page's bottom edge), adds mapRowStrideL0 to the high byte to reach the same column of the next page row. Result in Y. Same operation as map_coords.MapIndexMoveDown.

AdvanceTileOffsetY {
    PHP 
    LDA $00               ; Add $10 to the low byte: next tile row (+Y)
    SEP #$20
    CLC 
    ADC #$10
    BCS loc_03D7C1
    TAY 
    PLP 
    RTS 

  loc_03D7C1:
    XBA                   ; Carry: crossed the page's bottom edge → next page row (+mapRowStrideL0 on the high byte)
    CLC 
    ADC $mapRowStrideL0
    XBA 
    TAY 
    PLP 
    RTS 
}

---------------------------------------------
; Advance the tile map offset one tile RIGHT (+X).
; 
; Increments the low nibble of $00 — the next column inside the 16×16 page. If the low nibble wraps to zero, the page's right edge was crossed: the carry has bumped the row nibble, so +$F0 undoes it, and the high byte is incremented (next page column). Result in Y. Same operation as map_coords.MapIndexMoveRight.

AdvanceTileOffsetX {
    PHP 
    SEP #$20
    LDA $00               ; Increment the low nibble: next column (+X) inside the page
    INC 
    BIT #$0F
    BEQ loc_03D7DC
    STA $00
    REP #$20
    LDY $00
    PLP 
    RTS 

  loc_03D7DC:
    XBA                   ; Low nibble wrapped to 0: next page column (high byte +1); +$F0 below cancels the carry into the row nibble
    LDA $01
    INC 
    XBA 
    CLC 
    ADC #$F0
    TAY 
    PLP 
    RTS 
}