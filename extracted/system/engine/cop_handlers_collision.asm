; Collision-layer COP handlers and their shared helpers (Bank 00). The block is not contiguous: the handlers sit at 34934–35864, SetCollisionAbs at 38191–38250, and the helpers at 44943–46208.
; 
; The collision layer ($7FC000, collisionLayer) holds one byte per 16×16-pixel tile: the high nibble ($F0) marks the tile solid/occupied (actors paint it with the MarkSolid* ops), the low nibble is the terrain type. Map indices use the page layout described in tile_collision_physics (16×16-tile pages, $10 bytes per tile row, mapRowStrideL0 pages per page row). Tile scratch lives in WRAM $0018 (X) and $001C (Y), reached through absolute addressing because D is zeroed inside the helpers.
; 
; Paint ops (script call sites): MarkSolidHere #0B (462), ClearSolidHere #0C (163), MarkSolidOffset #0D (20), ClearSolidOffset #0E (11), MarkSolidAbs #0F (86), ClearSolidAbs #10 (60), ClearCollisionHere #11 (9), ClearTypeAbs #12 (27), SetCollisionAbs #42 (1). "Here" ops cover the actor's metasprite hitbox rectangle; Offset and Abs ops touch a single tile.
; 
; Probe ops: BranchIfSolidHere/Offset/North/South/West/East #13–#18 (27/160/75/78/67/71), the type probes #1A–#1E (9/4/6/4/4), BranchIfNotOnGridline #1F. The type probes appear as BranchIfSolidType* in copdef.json; the handler labels here (BranchIfSolidType ... BranchIfSolidTypeEast) use different names. All probes go through TileCollisionQuery, which returns $000F for a blocked (high nibble set) or out-of-bounds probe and the tile's own low-nibble type otherwise, so a type operand of $0F cannot tell a solid tile from a non-solid tile of type $0F. Handlers return by writing the next script address to the COP frame ($02,S) and RTI.
; 
; Helpers: ParseSignedTileOffset (used by MarkSolidOffset, ClearSolidOffset), ComputeDirectionToPlayer (used by cop_handlers_player_query), MarkCollisionRect / ClearCollisionRect / ClearCollisionRectFull / AdvanceMapY (rectangle paint), and TileCollisionQuery (used by every probe here and by the WallAnim handlers in cop_handlers_player_sprite). The Offset and Abs handlers do not range-check the index returned by TileCoordsToMapIndex (the rectangle helpers do).
---------------------------------------------

?BANK 00

?INCLUDE 'map_coords'
?INCLUDE 'tile_collision_physics'

!mapBoundsX                     0692
!mapRowStrideL0                 0693
!cameraOffsetX                  06D6
!cameraOffsetY                  06D8
!cameraBoundsX                  06DA
!cameraLowerYBound              06DE
!playerActor                    09AA
!metaspritePtr                  7F000C
!collisionLayer                 7FC000

---------------------------------------------

; COP #0B (legacy name SolidHighHere) collision marker with no operands. Copies the actor pixel position from $14/$16 into the probe scratch $18/$1C and calls MarkCollisionRect to OR $F0 onto every collision-layer tile covered by the actor's metasprite hitbox (the terrain nibble is preserved). The STZ $0000 beforehand is only meaningful to the Clear variants; MarkCollisionRect ignores it. Used by nearly every solid NPC, enemy and prop (462 call sites).

MarkSolidHere {
    TYX 
    LDA $14               ; Copy actor pixel X to the probe scratch $0018
    STA $0018
    LDA $16               ; Copy actor pixel Y to the probe scratch $001C
    STA $001C
    STZ $0000             ; Flag word for the Clear helpers; unused by MarkCollisionRect
    JSR $&MarkCollisionRect ; OR $F0 onto every tile in the actor hitbox
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #0C with no operands. Copies the actor pixel position into the probe scratch $18/$1C and calls ClearCollisionRect with flag $0000, ANDing #$0F on every collisionLayer tile in the metasprite hitbox to clear the solid nibble while preserving the terrain type nibble.

ClearSolidHere {
    TYX 
    LDA $14               ; Copy actor X for clearing
    STA $0018
    LDA $16               ; Copy actor Y
    STA $001C
    STZ $0000
    JSR $&ClearCollisionRect ; Clear solid nibble (AND #$0F) on all hitbox tiles
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #0D with two signed byte operands (tile X/Y offsets). ParseSignedTileOffset sign-extends each offset, scales by 16 pixels, converts to tile coordinates (Y adjusted −16), then ORs #$F0 onto the single collisionLayer byte at that map index.

MarkSolidOffset {
    TYX 
    JSR $&ParseSignedTileOffset ; Sign-extend tile offsets, add to position, convert to tile coords
    PHX 
    PHD 
    LDA #$0000
    TCD 
    LDX #$0000            ; TileCoordsToMapIndex: DP $18/$1C → linear collision index
    JSL $@map_coords.TileCoordsToMapIndex
    SEP #$20              ; TileCoordsToMapIndex → byte offset in $7FC000 collision layer
    LDA $collisionLayer, X
    ORA #$F0              ; Set upper nibble — mark tile solid for collision
    STA $collisionLayer, X
    REP #$20
    PLD 
    PLX 
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #0E with two signed byte tile offsets. Uses the same ParseSignedTileOffset path as MarkSolidOffset, then ANDs #$0F on one collisionLayer tile to clear the solid nibble only.

ClearSolidOffset {
    TYX 
    JSR $&ParseSignedTileOffset ; Decode signed offsets to tile coordinates
    PHX 
    PHD 
    LDA #$0000
    TCD 
    LDX #$0000
    JSL $@map_coords.TileCoordsToMapIndex
    SEP #$20
    LDA $collisionLayer, X
    AND #$0F              ; Clear solid nibble, preserve collision type nibble
    STA $collisionLayer, X
    REP #$20
    PLD 
    PLX 
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #0F with two byte operands (absolute tile X and Y). Converts coordinates through TileCoordsToMapIndex and ORs #$F0 onto the collision byte at that index.

MarkSolidAbs {
    TYX 
    LDA [$0A]             ; Read absolute tile X byte
    INC $0A
    AND #$00FF
    STA $0018
    LDA [$0A]             ; Read absolute tile Y byte
    INC $0A
    AND #$00FF
    STA $001C
    PHX 
    PHD 
    LDA #$0000
    TCD 
    LDX #$0000
    JSL $@map_coords.TileCoordsToMapIndex ; TileCoordsToMapIndex for absolute tile position
    SEP #$20
    LDA $collisionLayer, X
    ORA #$F0
    STA $collisionLayer, X
    REP #$20
    PLD 
    PLX 
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #10 with two byte operands (absolute tile X and Y). Resolves the map index and ANDs #$0F on that collisionLayer byte to remove solid flags.

ClearSolidAbs {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0018
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $001C
    PHX 
    PHD 
    LDA #$0000
    TCD 
    LDX #$0000
    JSL $@map_coords.TileCoordsToMapIndex
    SEP #$20
    LDA $collisionLayer, X
    AND #$0F
    STA $collisionLayer, X
    REP #$20
    PLD 
    PLX 
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #11 with no operands. Calls ClearCollisionRect with flag $0001, which routes to ClearCollisionRectFull and ANDs #$00 on every hitbox tile to zero both solid and type nibbles.

ClearCollisionHere {
    TYX 
    LDA $14               ; ClearCollisionHere: copy actor position
    STA $0018
    LDA $16
    STA $001C
    LDA #$0001            ; Flag $0001 routes to ClearCollisionRectFull (zero both nibbles)
    STA $0000
    JSR $&ClearCollisionRect
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #12 with two byte operands (absolute tile X and Y). Converts to a map index and ANDs #$F0 on the collision byte, clearing only the type nibble while leaving solid flags intact.

ClearTypeAbs {
    TYX 
    LDA [$0A]             ; Read tile X, Y; resolve index; AND #$F0 to clear type only
    INC $0A
    AND #$00FF
    STA $0018
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $001C
    PHX 
    PHD 
    LDA #$0000
    TCD 
    LDX #$0000
    JSL $@map_coords.TileCoordsToMapIndex
    SEP #$20
    LDA $collisionLayer, X
    AND #$F0              ; AND #$F0: preserve solid flags, clear type nibble
    STA $collisionLayer, X
    REP #$20
    PLD 
    PLX 
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #13 with one &Code operand. Probes the actor's own tile with TileCollisionQuery and branches to the target when the result has any bit of $000F set: the tile is blocked (high nibble set), the probe is outside the camera bounds, or the tile's terrain type is non-zero. Otherwise the operand is skipped. The same $000F test is used by the directional variants (#15–#18).

BranchIfSolidHere {
    TYX 
    LDA $14               ; Set probe X from actor position
    STA $0018
    LDA $16               ; Set probe Y from actor position
    STA $001C
    JSR $&TileCollisionQuery ; Query collision at actor's tile position
    BIT #$000F            ; Any of $000F set (blocked, out of bounds, or non-zero terrain type) → branch
    BNE loc_0089CA
    LDA [$0A]             ; Not solid: skip branch operand and continue
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 

  loc_0089CA:
    LDA [$0A]             ; Solid: take branch to target address
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #14 with two signed byte tile offsets plus one &Code operand. Sign-extends and ×16-scales each offset, adds them to the actor position, runs TileCollisionQuery at the resulting pixel position, and branches on the same $000F test as BranchIfSolidHere. It repeats the offset math of ParseSignedTileOffset inline but keeps pixel units (TileCollisionQuery does the tile conversion and its own −1 row adjustment).

BranchIfSolidOffset {
    TYX 
    LDA [$0A]             ; BranchIfSolidOffset: read signed X tile offset
    INC $0A
    AND #$00FF
    BIT #$0080            ; Sign extension: bit 7 set → OR #$FF00 for negative offset
    BEQ loc_0089E3
    ORA #$FF00

  loc_0089E3:
    ASL                   ; Tile→pixel: ASL ×4 = ×16, add to actor.X
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $14
    STA $0018
    LDA [$0A]             ; Read signed Y tile offset
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_0089FC
    ORA #$FF00

  loc_0089FC:
    ASL 
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $16
    STA $001C
    JSR $&TileCollisionQuery ; Query collision at offset position
    BIT #$000F
    BNE loc_008A19
    LDA [$0A]
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 

  loc_008A19:
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #15 with one &Code operand. Queries the tile one row north (Y − $10) via TileCollisionQuery and branches to the script offset when the result has any lower-nibble bit set.

BranchIfSolidNorth {
    TYX 
    LDA $14               ; North probe: set X from actor, Y − $10 (one tile up)
    STA $0018
    LDA $16
    SEC 
    SBC #$0010
    STA $001C
    JSR $&TileCollisionQuery
    BIT #$000F
    BNE loc_008A44
    LDA [$0A]
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 

  loc_008A44:
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #16 with one &Code operand. Queries the tile one row south (Y + $10) and branches on the same lower-nibble solid test as BranchIfSolidHere.

BranchIfSolidSouth {
    TYX 
    LDA $14               ; South probe: Y + $10 (one tile down)
    STA $0018
    LDA $16
    CLC 
    ADC #$0010
    STA $001C
    JSR $&TileCollisionQuery
    BIT #$000F
    BNE loc_008A6F
    LDA [$0A]
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 

  loc_008A6F:
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #17 with one &Code operand. Queries the tile one column west (X − $10) and branches if TileCollisionQuery reports a set lower-nibble bit.

BranchIfSolidWest {
    TYX 
    LDA $14               ; West probe: X − $10 (one tile left)
    SEC 
    SBC #$0010
    STA $0018
    LDA $16
    STA $001C
    JSR $&TileCollisionQuery
    BIT #$000F
    BNE loc_008A9A
    LDA [$0A]
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 

  loc_008A9A:
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #18 with one &Code operand. Queries the tile one column east (X + $10) and branches on the same solid-nibble test pattern.

BranchIfSolidEast {
    TYX 
    LDA $14               ; East probe: X + $10 (one tile right)
    CLC 
    ADC #$0010
    STA $0018
    LDA $16
    STA $001C
    JSR $&TileCollisionQuery
    BIT #$000F
    BNE loc_008AC5
    LDA [$0A]
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 

  loc_008AC5:
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #1A (copdef name BranchIfSolidType) with one byte (expected type) plus one &Code operand. TileCollisionQuery at the actor position; branches if the low byte of the result equals the operand. Blocked and out-of-bounds probes return $0F, so they match an operand of $0F. On a mismatch the pushed result is popped into Y (Y is clobbered; X and D still hold the slot).

BranchIfSolidType {
    TYX 
    LDA $14               ; Type query: probe at actor position
    STA $0018
    LDA $16
    STA $001C
    JSR $&TileCollisionQuery ; Get collision byte at actor tile
    AND #$00FF            ; Mask to full byte for type comparison
    PHA 
    LDA [$0A]             ; Read expected collision type operand
    INC $0A
    AND #$00FF
    CMP $01, S            ; Compare query result against expected type
    BEQ loc_008AF7        ; Match → take branch
    LDA [$0A]
    INC $0A
    INC $0A
    PLY 
    LDA $0A
    STA $02, S
    RTI 

  loc_008AF7:
    PLA 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #1B with one byte type and one &Code operand. Compares the collision type at Y − $10 against the operand and branches on equality.

BranchIfSolidTypeNorth {
    TYX 
    LDA $14               ; TypeNorth: probe Y − $10
    STA $0018
    LDA $16
    SEC 
    SBC #$0010
    STA $001C
    JSR $&TileCollisionQuery
    AND #$00FF
    PHA 
    LDA [$0A]
    INC $0A
    AND #$00FF
    CMP $01, S
    BEQ loc_008B2E
    LDA [$0A]
    INC $0A
    INC $0A
    PLY 
    LDA $0A
    STA $02, S
    RTI 

  loc_008B2E:
    PLA 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #1C with one byte type and one &Code operand. Same type comparison as BranchIfSolidType but samples the tile at Y + $10.

BranchIfSolidTypeSouth {
    TYX 
    LDA $14               ; TypeSouth: probe Y + $10
    STA $0018
    LDA $16
    CLC 
    ADC #$0010
    STA $001C
    JSR $&TileCollisionQuery
    AND #$00FF
    PHA 
    LDA [$0A]
    INC $0A
    AND #$00FF
    CMP $01, S
    BEQ loc_008B65
    LDA [$0A]
    INC $0A
    INC $0A
    PLY 
    LDA $0A
    STA $02, S
    RTI 

  loc_008B65:
    PLA 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #1D with one byte type and one &Code operand. Compares collision type at X − $10 and branches to &Code on match.

BranchIfSolidTypeWest {
    TYX 
    LDA $14               ; TypeWest: probe X − $10
    SEC 
    SBC #$0010
    STA $0018
    LDA $16
    STA $001C
    JSR $&TileCollisionQuery
    AND #$00FF
    PHA 
    LDA [$0A]
    INC $0A
    AND #$00FF
    CMP $01, S
    BEQ loc_008B9C
    LDA [$0A]
    INC $0A
    INC $0A
    PLY 
    LDA $0A
    STA $02, S
    RTI 

  loc_008B9C:
    PLA 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #1E with one byte type and one &Code operand. Compares collision type at X + $10 and branches to &Code on match.

BranchIfSolidTypeEast {
    TYX 
    LDA $14               ; TypeEast: probe X + $10
    CLC 
    ADC #$0010
    STA $0018
    LDA $16
    STA $001C
    JSR $&TileCollisionQuery
    AND #$00FF
    PHA 
    LDA [$0A]
    INC $0A
    AND #$00FF
    CMP $01, S
    BEQ loc_008BD3
    LDA [$0A]
    INC $0A
    INC $0A
    PLY 
    LDA $0A
    STA $02, S
    RTI 

  loc_008BD3:
    PLA 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #1F with one &Code operand. Branches when the actor is off the 16-pixel grid: either its Y has a non-zero low nibble, or its X plus the metasprite hitbox X offset (hitbox byte 0, forced negative by ORA #$FF00) has one. Falls through (operand skipped) only when both are aligned. DBR is switched to the sprite-data bank ($7F0008,X) to read the hitbox header and restored on both exits.

BranchIfNotOnGridline {
    TYX 
    PHB 
    LDA $16               ; Test actor Y for 16px grid alignment (low nibble must be 0)
    BIT #$000F            ; Reject if actor Y not on 16px gridline
    BEQ loc_008BF0        ; Aligned → continue to X grid check

  loc_008BE6:
    PLB 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 

  loc_008BF0:
    LDA $metaspritePtr, X ; Metasprite pointer: its first 4 bytes are the hitbox header
    TAY 
    SEP #$20
    LDA $7F0008, X
    PHA 
    PLB 
    REP #$20
    LDA $0000, Y          ; Hitbox header word: byte 0 = X offset from the actor origin, byte 1 = Y offset
    ORA #$FF00            ; Force the high byte to $FF: byte 0 is treated as a negative offset (byte 1 is discarded)
    CLC 
    ADC $14               ; Actor X + hitbox X offset = left edge of the footprint
    BIT #$000F            ; Left edge not on the 16px grid → branch (via loc_008BE6)
    BNE loc_008BE6
    PLB 
    LDA [$0A]
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 
}
---------------------------------------------

; COP #42 (legacy name SetSolidAbs) absolute collision writer taking three byte operands: tile X, tile Y, and a full collision-layer byte value. Converts the tile coordinates through TileCoordsToMapIndex and stores the byte directly into collisionLayer, replacing both nibbles (solid and type) in one write. Used once in the game. The handler has no TYX: it pushes Y (the slot) at entry and recovers it with PLX at the end, after X has been used for the map index.

SetCollisionAbs {
    PHY                   ; Y = slot at COP entry; popped into X by the PLX at the end
    PHD 
    LDA [$0A]             ; SetCollisionAbs: read tile X operand
    INC $0A
    AND #$00FF
    STA $0018
    LDA [$0A]             ; Read tile Y byte operand
    INC $0A
    AND #$00FF
    STA $001C
    LDA [$0A]             ; Read collision byte value operand
    INC $0A
    AND #$00FF
    STA $0000
    LDA #$0000
    TCD 
    LDX #$0000
    JSL $@map_coords.TileCoordsToMapIndex ; Convert tile coords to map index
    SEP #$20
    LDA $00               ; Load full collision byte to map layer
    STA $collisionLayer, X
    REP #$20
    PLD 
    PLX 
    LDA $0A
    STA $02, S
    RTI 
}
---------------------------------------------

; Internal JSR helper that reads two signed byte operands from the script pointer at $0A (D = actor slot). Sign-extends each offset, scales by 16 pixels, adds them to the actor position ($14/$16, with Y reduced by $10, one tile row), and converts the result to tile coordinates in $0018/$001C. Returns via RTS with $0A advanced past both operands. Called only by MarkSolidOffset and ClearSolidOffset; BranchIfSolidOffset repeats the arithmetic inline in pixel units.

ParseSignedTileOffset {
    LDA [$0A]             ; ParseSignedTileOffset: read signed X offset byte from script
    INC $0A
    AND #$00FF
    BIT #$0080            ; Test bit 7 for negative sign extension
    BEQ loc_00AF9E
    ORA #$FF00

  loc_00AF9E:
    ASL                   ; Tile→pixel: ×16 via ASL ×4
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $14               ; Add scaled X offset to actor X ($14)
    LSR                   ; Pixel→tile: LSR ×4 = ÷16 (convert back to tile coords)
    LSR 
    LSR 
    LSR 
    STA $0018
    LDA [$0A]             ; Read signed Y tile offset byte
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_00AFBB
    ORA #$FF00

  loc_00AFBB:
    ASL 
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $16               ; Add scaled offset to actor Y ($16)
    SEC                   ; Subtract one tile row ($10 px) before the tile conversion; TileCollisionQuery applies the same −1 row (reason inferred: actor Y carries a 16-pixel offset)
    SBC #$0010
    LSR                   ; Pixel→tile: LSR ×4 = ÷16
    LSR 
    LSR 
    LSR 
    STA $001C
    RTS 
}

---------------------------------------------
; Internal JSR helper that computes an 8-direction octant index (0–7) from the reference point in $0018/$001C (pixels) to the player position. Compass order is clockwise from north: 0=N, 1=NE, 2=E, 3=SE, 4=S, 5=SW, 6=W, 7=NW (not the same numbering as GetPlayerFacingDirection). Rule: if |ΔY| < $10 the result is pure E or W whatever ΔX is (including the player standing on the reference point, which gives E); otherwise the vertical component is N or S, and it becomes a diagonal only when |ΔX| ≥ $10. Returns the octant in A. Called by DirToPlayer, DirToPlayerFrom, BranchIfDirToPlayer and BranchIfDirToPlayerFrom (cop_handlers_player_query).

ComputeDirectionToPlayer {
    LDY $playerActor      ; Load player actor pointer for direction calc
    LDA $0014, Y          ; Load player X position for direction comparison
    SEC                   ; ΔX = player.X − actor.X
    SBC $0018             ; ΔX = player.X − actor.X; positive = player is east
    BMI loc_00B01A        ; Negative ΔX → player is west of actor
    STA $0000
    LDA $0016, Y          ; Get player Y position
    SEC                   ; ΔY = player.Y − actor.Y
    SBC $001C             ; ΔY = player.Y − actor.Y; positive = player is south
    BMI loc_00AFFE        ; Negative ΔY → player is north
    LDY #$0002            ; Default Y=2 (East) — player east, ΔY check next
    CMP #$0010            ; Within ±$10 pixels: classify as near on this axis
    BCC loc_00B05C
    LDY #$0004            ; Far on Y axis → Y=4 (South), check X distance
    LDA $0000
    CMP #$0010            ; |ΔX| < $10 → far Y but near X = pure South
    BCC loc_00B05C
    LDY #$0003            ; Both far → direction 3 (Southeast)
    BRA loc_00B05C

  loc_00AFFE:
    EOR #$FFFF
    INC 
    LDY #$0002            ; ΔY negative: Y=2 (East), check Y distance for North bias
    CMP #$0010
    BCC loc_00B05C        ; |ΔY| < $10 → stay at East (2)
    LDY #$0000            ; |ΔY| ≥ $10 and player north → N (0), refine with X
    LDA $0000
    CMP #$0010
    BCC loc_00B05C        ; |ΔX| < $10 → pure North (0)
    LDY #$0001            ; |ΔX| ≥ $10 too → NE (1)
    BRA loc_00B05C

  loc_00B01A:
    EOR #$FFFF            ; ΔX negative: take |ΔX| for comparison
    INC 
    STA $0000
    LDA $0016, Y
    SEC 
    SBC $001C
    BMI loc_00B042
    LDY #$0006            ; West side: Y=6 (West), check ΔY for S/N bias
    CMP #$0010
    BCC loc_00B05C
    LDY #$0004            ; Far positive ΔY → direction 4 (South); check X
    LDA $0000
    CMP #$0010
    BCC loc_00B05C
    LDY #$0005            ; SW quadrant, both far → direction 5 (Southwest)
    BRA loc_00B05C

  loc_00B042:
    EOR #$FFFF
    INC 
    LDY #$0006            ; West+North: Y=6 (West), check ΔY
    CMP #$0010
    BCC loc_00B05C
    LDY #$0000            ; Far negative ΔY → direction 0 (North); check X
    LDA $0000
    CMP #$0010
    BCC loc_00B05C
    LDY #$0007            ; NW quadrant, both far → Y=7 (Northwest)

  loc_00B05C:
    TYA 
    RTS 
}
---------------------------------------------

; Internal JSR helper that marks a solid rectangle on the collision map. The actor's metasprite hitbox header (4 bytes at metaspritePtr, read in the sprite-data bank: X offset, Y offset, width in tiles, height in tiles) is combined with the pixel position in $0018/$001C (X/Y offsets are forced negative with ORA #$FF00), converted to a starting tile, and $F0 is ORed onto every collisionLayer byte of the rectangle. Columns step +1, crossing to the next 16-tile page with +$F0; rows step with AdvanceMapY. The whole rectangle is skipped if the starting index is ≥ $4000. Called only by MarkSolidHere (the other mark ops write a single tile).

MarkCollisionRect {
    PHB 
    PHD                   ; Save direct page and actor X before rectangle iteration
    PHX                   ; MarkCollisionRect: save DP and X before rectangle iteration
    LDA #$0000
    TCD 
    LDA $metaspritePtr, X ; Load metasprite pointer for hitbox bounds
    TAY 
    SEP #$20
    LDA $7F0008, X
    PHA 
    PLB 
    REP #$20
    LDA $0000, Y          ; Hitbox byte 0 = X offset (byte 1 is replaced by the ORA below)
    ORA #$FF00            ; Force negative: offsets are assumed ≤ 0
    CLC 
    ADC $18               ; Actor pixel X + offset = left edge
    LSR                   ; Pixel → tile column (÷16)
    LSR 
    LSR 
    LSR 
    STA $18
    LDA $0002, Y          ; Read metasprite hitbox tile width
    AND #$00FF
    STA $1A
    LDA $0001, Y          ; Hitbox byte 1 = Y offset (byte 2, the width, is replaced by the ORA below)
    ORA #$FF00            ; Force negative, as for X
    CLC 
    ADC $1C
    LSR 
    LSR 
    LSR 
    LSR 
    STA $1C
    LDA $0003, Y          ; Read metasprite hitbox tile height (rows to iterate)
    AND #$00FF
    STA $1E
    LDX #$0000
    JSL $@map_coords.TileCoordsToMapIndex ; TileCoordsToMapIndex: starting position → collision map offset
    CPX #$4000            ; Bounds check: X ≥ $4000 means out-of-map
    BCS loc_00B325
    LDA $1A               ; Load tile width as column counter
    STA $18
    TXA 
    STA $1C               ; Save starting map index as row pointer

  loc_00B2F6:
    SEP #$20
    TAX 
    LDA $collisionLayer, X ; Read collision byte at current tile
    ORA #$F0              ; OR #$F0: set solid nibble on collision layer
    STA $collisionLayer, X
    DEC $18               ; Decrement column counter
    BEQ loc_00B316
    REP #$20
    TXA 
    INC                   ; Next tile to the right (+1 byte)
    BIT #$000F            ; Column nibble 0 again = crossed into the next 16-tile page
    BNE loc_00B2F6
    CLC 
    ADC #$00F0            ; Crossed the 16-tile page edge: INC carried into the row nibble, +$F0 (= +$100 − $10) lands on column 0 of the next page, same row
    BRA loc_00B2F6

  loc_00B316:
    DEC $1E               ; Decrement row counter; 0 = rectangle complete
    BEQ loc_00B325
    LDA $1A               ; Reset column counter for new row
    STA $18
    JSR $&AdvanceMapY     ; Advance map pointer to next tile row
    LDA $1C
    BRA loc_00B2F6

  loc_00B325:
    REP #$20
    PLX 
    PLD 
    PLB 
    RTS 
}

---------------------------------------------
; Internal JSR helper that advances the collision map index in $001C by one tile row ($10 bytes within a page). When the low byte overflows (the row nibble wrapped past 15) it adds mapRowStrideL0 to a page byte taken from the accumulator's hidden high half (the caller's last 16-bit A, inferred to be the page of the last tile written; not reloaded from $1C), moving to the first row of the next page row. This matches the intended result only while the rectangle's row does not cross a page edge horizontally; ClearCollisionRect and its Full variant use a 16-bit ADC of mapBoundsX instead, which does not have this dependency. Called by MarkCollisionRect between rectangle rows.

AdvanceMapY {
    PHP 
    SEP #$20              ; 8-bit mode for byte-level map address manipulation
    LDA $1C
    CLC 
    ADC #$10              ; Add $10 to map pointer low byte (advance one row = 16 tiles)
    BCS loc_00B339        ; Carry set = crossed page boundary → add row stride
    STA $1C
    PLP 
    RTS 

  loc_00B339:
    XBA 
    CLC 
    ADC $mapRowStrideL0   ; Hidden high byte of A + pages per page row. $1C is read as 8 bits, so that byte is whatever the caller's last 16-bit A left (inferred: page of the last tile written), not a reload of $1C's page
    XBA 
    REP #$20
    STA $1C
    PLP 
    RTS 
}

---------------------------------------------
; Internal JSR helper that clears solid flags from a rectangle on the collision map. Reads the metasprite hitbox exactly like MarkCollisionRect, then ANDs #$0F on every tile in the rectangle to remove the solid nibble while preserving the type nibble. If the flag word in WRAM $0000 is nonzero it jumps to ClearCollisionRectFull instead. Row stepping is inlined: +$10 on the low byte, and on carry the page byte is advanced by adding the word mapBoundsX (see the note at that ADC). Called by ClearSolidHere (flag 0) and ClearCollisionHere (flag 1).

ClearCollisionRect {
    PHB 
    PHD 
    PHX                   ; ClearCollisionRect: save state for rectangle clear
    LDA #$0000
    TCD 
    LDA $metaspritePtr, X ; Load metasprite hitbox for rectangle bounds
    TAY 
    SEP #$20
    LDA $7F0008, X
    PHA 
    PLB 
    REP #$20
    LDA $0000, Y
    ORA #$FF00
    CLC 
    ADC $18
    LSR                   ; Pixel→tile conversion for clear rectangle
    LSR 
    LSR 
    LSR 
    STA $18               ; Starting tile column
    LDA $0002, Y          ; Read hitbox tile width for column count
    AND #$00FF
    STA $1A
    LDA $0001, Y          ; Sign-extend top Y offset and convert to tile
    ORA #$FF00
    CLC 
    ADC $1C
    LSR 
    LSR 
    LSR 
    LSR 
    STA $1C
    LDA $0003, Y          ; Read hitbox tile height (row count)
    AND #$00FF
    STA $1E
    LDX #$0000
    JSL $@map_coords.TileCoordsToMapIndex ; TileCoordsToMapIndex for starting clear position
    CPX #$4000
    BCS loc_00B3E9
    LDA $1A
    STA $18
    TXA 
    STA $1C
    LDA $00               ; Flag word (set by the caller; D = 0 here): nonzero → full clear (both nibbles)
    BEQ loc_00B3A3
    JMP $&ClearCollisionRectFull ; Jump to ClearCollisionRectFull for zeroing both nibbles

  loc_00B3A3:
    TXA 

  loc_00B3A4:
    SEP #$20
    TAX 
    LDA $collisionLayer, X ; Read collision byte at current tile
    AND #$0F              ; AND #$0F: clear solid nibble, keep type
    STA $collisionLayer, X
    DEC $18
    BEQ loc_00B3C4
    REP #$20
    TXA 
    INC 
    BIT #$000F            ; BIT #$000F: check metatile boundary for column wrap
    BNE loc_00B3A4
    CLC 
    ADC #$00F0
    BRA loc_00B3A4

  loc_00B3C4:
    DEC $1E
    BEQ loc_00B3E9
    LDA $1A
    STA $18
    LDA $1C
    CLC 
    ADC #$10
    BCS loc_00B3DB        ; Carry set → add page stride to row pointer
    STA $1C
    REP #$20
    LDA $1C
    BRA loc_00B3A4

  loc_00B3DB:
    STA $1C
    REP #$20
    LDA $1C
    CLC 
    ADC $mapBoundsX       ; 16-bit add: its high byte (= mapRowStrideL0, inferred; low byte 0) advances the page byte by one page row
    STA $1C
    BRA loc_00B3A4

  loc_00B3E9:
    REP #$20
    PLX 
    PLD 
    PLB 
    RTS 
}

---------------------------------------------
; Internal subroutine reached via JMP from ClearCollisionRect when the full-clear flag ($0001) is set. ANDs #$00 on every tile in the metasprite hitbox rectangle, zeroing both the solid and type nibbles. Used by ClearCollisionHere to completely remove collision data at the actor footprint.

ClearCollisionRectFull {
    TXA 

  loc_00B3F0:
    SEP #$20
    TAX                   ; ClearCollisionRectFull: AND #$00 zeros both nibbles
    LDA $collisionLayer, X ; ClearCollisionRectFull: read collision byte
    AND #$00              ; AND #$00: zero both solid and type nibbles
    STA $collisionLayer, X
    DEC $18
    BEQ loc_00B410
    REP #$20
    TXA 
    INC 
    BIT #$000F            ; Check metatile boundary for wrap
    BNE loc_00B3F0        ; Metatile boundary check for column wrap
    CLC 
    ADC #$00F0
    BRA loc_00B3F0

  loc_00B410:
    DEC $1E
    BEQ loc_00B435
    LDA $1A
    STA $18
    LDA $1C
    CLC 
    ADC #$10
    BCS loc_00B427
    STA $1C
    REP #$20
    LDA $1C
    BRA loc_00B3F0

  loc_00B427:
    STA $1C
    REP #$20
    LDA $1C
    CLC 
    ADC $mapBoundsX       ; Same page-row advance as in ClearCollisionRect
    STA $1C
    BRA loc_00B3F0

  loc_00B435:
    REP #$20
    PLX 
    PLD 
    PLB 
    RTS 
}

---------------------------------------------
; Internal JSR helper that probes one tile of the $7FC000 collision layer. The probe pixel (WRAM $0018 = X, $001C = Y) must lie inside the camera bounds rectangle (cameraOffsetX/Y up to cameraBoundsX/cameraLowerYBound, X masked to a 16-pixel boundary); it is converted to tile coordinates (Y reduced by one more row), mapped with CalcTileMapOffset, and the collision byte is read through [$80],Y. Returns in A: $000F when the probe is negative or outside the bounds, the map index is ≥ $4000, or the tile's high nibble is non-zero; otherwise the 16-bit word at that index (low byte = the tile's terrain type 0–$F, high byte = the next collision byte, which callers ignore). Called by every BranchIfSolid/BranchIfType handler and the WallAnim handlers.

TileCollisionQuery {
    PHD 
    LDA #$0000            ; Zero DP for WRAM direct access in collision lookup
    TCD                   ; TileCollisionQuery: zero DP for WRAM direct access
    LDA $18               ; Load probe pixel X
    AND #$FFF0            ; Align probe X to 16px boundary (AND #$FFF0)
    BMI loc_00B47C        ; Negative pixel X → off-map (return $000F solid fallback)
    CMP $cameraOffsetX    ; Compare against camera left bound (cameraOffsetX)
    BCC loc_00B47C
    CMP $cameraBoundsX    ; Compare against camera right bound (cameraBoundsX)
    BCS loc_00B47C
    LSR                   ; Pixel→tile: LSR ×4 = ÷16
    LSR 
    LSR 
    LSR 
    STA $18
    LDA $1C               ; Load probe pixel Y
    BMI loc_00B47C
    CMP $cameraOffsetY    ; Compare against camera top bound (cameraOffsetY)
    BCC loc_00B47C
    CMP $cameraLowerYBound ; Compare against camera bottom bound (cameraLowerYBound)
    BCS loc_00B47C
    LSR 
    LSR 
    LSR 
    LSR 
    DEC                   ; Tile row − 1 (same adjustment as ParseSignedTileOffset; reason inferred: collision rows are offset one row from pixel Y)
    STA $1C
    JSL $@tile_collision_physics.CalcTileMapOffset ; CalcTileMapOffset: tile coords → collision layer pointer
    CPY #$4000            ; Y ≥ $4000 = out-of-bounds → fallback
    BCS loc_00B47C
    LDA [$80], Y          ; Read collision byte from layer via pointer
    BIT #$00F0            ; Non-zero upper nibble = solid tile → query reports blocked
    BEQ loc_00B47F

  loc_00B47C:
    LDA #$000F            ; $000F = solid fallback for all out-of-bounds queries

  loc_00B47F:
    PLD 
    RTS 
}