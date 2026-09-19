; COP handlers for collision layer manipulation, DMA/HDMA queue operations, and tile collision queries (Bank $00, 25 COP handlers + 7 internal routines).
; 
; DMA/HDMA queue: GenHdmaSine builds a 512-entry sine wave via the hardware multiplier and writes a 3-entry HDMA indirect table. QueueHdma/QueueDma/QueueHdmaChannel set up HDMA and DMA channel registers.
; 
; Solid marking: MarkSolidHere/Offset/Abs OR $F0 onto collisionLayer tiles. ClearSolidHere/Offset/Abs AND $0F to remove solid flags. ClearCollisionHere clears both nibbles. ClearTypeAbs clears only the type nibble.
; 
; Solid branching: BranchIfSolidHere/Offset/North/South/West/East test the solid nibble at directional offsets. BranchIfTypeHere/North/South/West/East compare the type nibble against an operand. BranchIfNotOnGridline checks 16px alignment.
; 
; SetCollisionAbs writes a full collision byte at absolute tile coordinates.
; 
; Internal: MarkCollisionRect/ClearCollisionRect/ClearCollisionRectFull iterate over metasprite hitbox tiles. ParseSignedTileOffset decodes signed tile offsets. ComputeDirectionToPlayer computes 8-direction index. TileCollisionQuery samples a tile via CalcTileMapOffset. AdvanceMapY handles row wrapping.
---------------------------------------------

?BANK 00

?INCLUDE 'cop_handlers_effects'
?INCLUDE 'cop_handlers_flags'
?INCLUDE 'hdma_dma_spc'
?INCLUDE 'hdma_ramp_tables'
?INCLUDE 'map_coords'
?INCLUDE 'tile_collision_physics'

!mapBoundsX                     0692
!mapRowStrideL0                 0693
!cameraOffsetX                  06D6
!cameraOffsetY                  06D8
!cameraBoundsX                  06DA
!cameraLowerYBound              06DE
!playerActor                    09AA
!DMAP0                          4300
!BBAD0                          4301
!A1T0L                          4302
!A1B0                           4304
!DASB0                          4307
!spritesetPtr                   7F0006
!metaspritePtr                  7F000C
!collisionLayer                 7FC000

---------------------------------------------

; COP #00 HDMA sine-table generator with no script operands. Calls BuildSineLookupTable to fill a 512-entry sine wave at WRAM $7E8800+ using the actor amplitude byte at $7F0008, then writes a three-entry HDMA indirect table. Double-buffers via spritesetPtr so regenerated tables alternate between $8800 and $8900 offsets. Callers include sine_hdma_ending_wave and the unused gen_hdma_sine_oneshot path, typically followed by COP QueueHdma.

GenHdmaSine {
    TYX 
    PHP                   ; Save processor state before multiplier/HDMA setup
    JSR $&cop_handlers_effects.BuildSineLookupTable ; Build 512-entry sine lookup via SNES hardware multiplier ($4202/$4203)
    LDA $spritesetPtr, X  ; Read and increment sine buffer ping-pong index
    INC 
    STA $spritesetPtr, X
    AND #$01FE            ; Toggle between $8900/$8A00 double-buffer pages
    CLC 
    ADC #$8900            ; HDMA source pointer into WRAM sineTableA
    STA $7E8801           ; HDMA indirect table entry 0: source address in sine buffer
    CLC 
    ADC #$00FE            ; +$00FE: second half of sine data for table entry 1
    STA $7E8804
    SEP #$20
    LDA #$FF
    STA $7E8800           ; HDMA table entry 0: $FF terminator byte
    LDA #$E0              ; HDMA entry 1 line count: $E0 (224 remaining visible scanlines)
    STA $7E8803           ; HDMA table entry 1: $E0 → CGRAM (palette) write port
    LDA #$00              ; HDMA entry 2: $00 terminator (end of indirect table)
    STA $7E8806           ; HDMA table entry 2: $00 line-count terminator
    PLP 
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #01 with two word operands (HDMA table address, channel configuration word). Reads both from the script pointer and calls SetupHdmaChannel_Indirect to queue an indirect HDMA transfer.

QueueHdma {
    TYX 
    LDA [$0A]             ; Read HDMA table address word from script
    INC $0A
    INC $0A
    TAY 
    LDA [$0A]             ; Read channel configuration word
    INC $0A
    INC $0A
    JSL $@hdma_dma_spc.SetupHdmaChannel_Indirect ; Configure HDMA channel with indirect addressing mode
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #02 with two word operands (source/destination setup words). Passes them to SetupHdmaChannel_Direct to configure a linear DMA channel rather than indirect HDMA.

QueueDma {
    TYX 
    LDA [$0A]             ; Read DMA source/dest setup word
    INC $0A
    INC $0A
    TAY 
    LDA [$0A]             ; Read second DMA configuration word
    INC $0A
    INC $0A
    JSL $@hdma_dma_spc.SetupHdmaChannel_Direct ; Configure linear DMA channel (non-HDMA transfer)
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #03 with one byte (channel ID) plus two words (A-bus table address, then B-bus register byte in low 8 bits and source bank in high 8 bits). Computes the $4300 register block offset as channel×16, ORs the channel bit into cached HDMA enable mask $0066, looks up transfer mode from hdma_channel_config, ORs #$40 into DMAP for HDMA mode, and writes DMAP/BBAD/A1T/A1B for that channel.

QueueHdmaChannel {
    PHY 
    LDA [$0A]             ; Read HDMA channel ID byte (0–7)
    INC $0A
    AND #$00FF
    STA $0002             ; Save channel ID in $0002 for bitmask lookup
    ASL                   ; Channel × 16: offset into $4300 DMA register block
    ASL 
    ASL 
    ASL 
    STA $0000
    LDX $0002
    SEP #$20
    LDA $@cop_handlers_flags.bitmasks_bit_position, X ; Look up single-bit channel mask from position table
    TSB $0066             ; OR channel bit into cached HDMA enable mask ($0066)
    REP #$20
    LDA [$0A]             ; Read HDMA A-bus table address word from script
    INC $0A
    INC $0A
    TAY 
    LDA [$0A]             ; Read packed B-bus register byte (low) + source bank (high)
    INC $0A
    INC $0A
    PHP 
    SEP #$20
    PHA 
    LDA #$00
    XBA 
    PHA 
    TAX 
    LDA $&hdma_ramp_tables.hdma_channel_config, X ; Look up transfer mode from hdma_channel_config table
    LDX $0000
    ORA #$40              ; DMAP bit 6 = HDMA transfer mode (not linear DMA)
    STA $DMAP0, X         ; Write DMAP transfer mode for this HDMA channel
    LDA $02, S
    STA $DASB0, X
    PLA 
    STA $BBAD0, X         ; Write B-bus destination register (BBAD)
    REP #$20
    TYA 
    STA $A1T0L, X         ; Write A-bus source address low word (A1TL)
    SEP #$20
    PLA 
    STA $A1B0, X          ; A-bus source bank byte for HDMA fetch
    PLP 
    PLX 
    LDA $0A
    STA $02, S
    RTI 
}
---------------------------------------------

; COP #0B (script name SolidHighHere) collision marker with no operands. Copies the current actor pixel position from $14/$16 into tile coordinates and calls MarkCollisionRect with collision type zero to OR the high nibble ($F0) onto every tile in the actor metasprite hitbox. Used by enemy and prop scripts that need to block player movement at the actor current footprint.

MarkSolidHere {
    TYX 
    LDA $14               ; Copy actor X to collision probe coordinate
    STA $0018
    LDA $16               ; Copy actor Y to collision probe coordinate
    STA $001C
    STZ $0000
    JSR $&MarkCollisionRect ; Mark solid nibble ($F0) on all tiles in actor hitbox
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #0C with no operands. Copies the actor pixel position into tile coordinates and calls ClearCollisionRect with flag zero, ANDing #$0F on every collisionLayer tile in the metasprite hitbox to clear solid flags while preserving the type nibble.

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
; COP #13 with one &Code operand. Samples collision at the actor position via TileCollisionQuery and branches to the target if any solid nibble bit (#$000F) is set in the result.

BranchIfSolidHere {
    TYX 
    LDA $14               ; Set probe X from actor position
    STA $0018
    LDA $16               ; Set probe Y from actor position
    STA $001C
    JSR $&TileCollisionQuery ; Query collision at actor's tile position
    BIT #$000F            ; Branch taken if any solid nibble bit set
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
; COP #14 with two signed byte tile offsets plus one &Code operand. Sign-extends and ×16-scales each offset, adds them to actor position, runs TileCollisionQuery at the computed pixel location, and branches if the query result has any #$000F bit set.

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
; COP #1A with one byte (expected collision type) plus one &Code operand. TileCollisionQuery at the actor position; branches if the low byte of the result equals the type operand.

BranchIfTypeHere {
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

BranchIfTypeNorth {
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
; COP #1C with one byte type and one &Code operand. Same type comparison as BranchIfTypeHere but samples the tile at Y + $10.

BranchIfTypeSouth {
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

BranchIfTypeWest {
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

BranchIfTypeEast {
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
; COP #1F with one &Code operand. Branches if actor Y is not 16px-aligned (Y & #$000F ≠ 0), or if hitbox-adjusted X (actor X plus sign-extended metasprite width) is also off the 16px grid; otherwise falls through without branching.

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
    LDA $metaspritePtr, X ; Load metasprite pointer for hitbox width
    TAY 
    SEP #$20
    LDA $7F0008, X
    PHA 
    PLB 
    REP #$20
    LDA $0000, Y          ; Sign-extend and add metasprite width to X
    ORA #$FF00            ; Sign-extend metasprite hitbox width from script byte
    CLC 
    ADC $14               ; Test adjusted X for grid alignment
    BIT #$000F            ; Test adjusted X for grid alignment (BIT #$000F)
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

; COP #42 (script name SetSolidAbs) absolute collision writer taking three byte operands: tile X, tile Y, and a full collision-layer byte value. Converts the tile coordinates through TileCoordsToMapIndex and stores the collision byte directly into collisionLayer at the computed map index. Unlike MarkSolidHere, this sets an explicit collision nibble/type rather than always forcing the high solid nibble.

SetCollisionAbs {
    PHY 
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

; Internal JSR helper that reads two signed byte operands from the script pointer at $0A. Sign-extends each offset, scales by 16 pixels, adds them to the actor position ($14/$16, with Y adjusted by −16), and converts the result to tile coordinates in DP $18/$1C. Returns via RTS with $0A advanced past both operands. Called by MarkSolidOffset, ClearSolidOffset, BranchIfSolidOffset, and other offset-based collision COP handlers.

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
    SEC                   ; Subtract $10: compensate for camera top-edge offset before tile conversion
    SBC #$0010
    LSR                   ; Pixel→tile: LSR ×4 = ÷16
    LSR 
    LSR 
    LSR 
    STA $001C
    RTS 
}

---------------------------------------------
; Internal JSR helper that computes an 8-direction octant index (0–7) from the actor reference coordinates in DP $18/$1C to the player position. Compares |ΔX| and |ΔY| against a $0010 threshold to distinguish near vs far on each axis, producing compass directions: 0=N, 1=NE, 2=E, 3=SE, 4=S, 5=SW, 6=W, 7=NW. Returns the direction in A. Called by DirToPlayer, DirToPlayerFrom, and BranchIfDirToPlayer.

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
    BCC loc_00B05C        ; Far negative Y → direction 0 (North); check X
    LDY #$0000            ; Far on Y, negative → Y=0 (North), check X
    LDA $0000
    CMP #$0010
    BCC loc_00B05C        ; Both far NE quadrant → direction 1 (Northeast)
    LDY #$0001            ; Both far, NE quadrant → Y=1 (Northeast)
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

; Internal JSR helper that marks a solid rectangle on the collision map. Reads metasprite hitbox width/height from the actor metasprite table, offsets from tile coordinates in DP $18/$1C, and ORs $F0 onto collisionLayer for every tile in the rectangle, wrapping rows via AdvanceMapY at map edges. Called by MarkSolidHere, MarkSolidAbs, and related solid-marking COP handlers.

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
    LDA $0000, Y          ; Sign-extend metasprite left offset → add to actor X
    ORA #$FF00
    CLC 
    ADC $18               ; Pixel→tile conversion (÷16) for column start
    LSR                   ; Pixel→tile conversion (÷16) for column start
    LSR 
    LSR 
    LSR 
    STA $18
    LDA $0002, Y          ; Read metasprite hitbox tile width
    AND #$00FF
    STA $1A
    LDA $0001, Y          ; Sign-extend metasprite top offset → add to actor Y
    ORA #$FF00
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
    INC                   ; Advance to next tile in row (+1 byte in collision map)
    BIT #$000F            ; Check if crossed 16-tile metatile boundary
    BNE loc_00B2F6
    CLC 
    ADC #$00F0            ; +$F0: wrap to next metatile row in collision map
    BRA loc_00B2F6        ; +$F0: wrap to next metatile row in collision map

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
; Internal JSR helper that advances the collision map pointer in DP $1C by one tile row ($10 bytes). Handles carry-based row wrapping by adding mapRowStrideL0 when the low byte overflows, ensuring correct row addressing across tilemap boundaries. Called by MarkCollisionRect during per-row solid marking.

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
    ADC $mapRowStrideL0   ; Add mapRowStrideL0 to handle map wrapping at row boundary
    XBA 
    REP #$20
    STA $1C
    PLP 
    RTS 
}

---------------------------------------------
; Internal JSR helper that clears solid flags from a rectangle on the collision map. Reads the metasprite hitbox like MarkCollisionRect, then ANDs #$0F on every tile in the rectangle to remove the solid nibble while preserving the type nibble. If flag $0001 is set in DP $00, routes to ClearCollisionRectFull instead. Called by ClearSolidHere and ClearCollisionHere.

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
    STA $18               ; Tile width/height in tiles from metasprite hitbox / 16
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
    LDA $00               ; Flag $0001 → full clear (both nibbles) via ClearCollisionRectFull
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
    ADC $mapBoundsX
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
    ADC $mapBoundsX
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
; Internal JSR helper that samples a single collision byte from the $7FC000 collision layer. Validates that pixel coordinates in DP $18/$1C fall within the camera viewport (cameraOffsetX/Y to cameraBoundsX/cameraLowerYBound), converts to tile coordinates, calls CalcTileMapOffset, and reads the collision byte. Returns the byte in A; out-of-bounds or negative coordinates return $000F (treated as solid). Called by all BranchIfSolid/BranchIfType handlers and WallAnim routines.

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
    DEC                   ; DEC: adjust tile Y for camera top-edge row offset
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