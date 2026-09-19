; COP handlers for collision layer manipulation, DMA/HDMA queue operations, and tile collision queries (Bank $00, 30 handlers).
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
    PHP 
    JSR $&cop_handlers_effects.BuildSineLookupTable ; Build 512-entry sine table via SNES hardware multiplier
    LDA $spritesetPtr, X
    INC 
    STA $spritesetPtr, X
    AND #$01FE            ; AND #$01FE: ping-pong sine buffers via spritesetPtr LSB
    CLC 
    ADC #$8900            ; ADC #$8900: HDMA source pointer into WRAM sineTableA
    STA $7E8801
    CLC 
    ADC #$00FE
    STA $7E8804
    SEP #$20
    LDA #$FF
    STA $7E8800           ; HDMA table entry 0: $FF terminator byte
    LDA #$E0
    STA $7E8803           ; HDMA table entry 1: $E0 → CGRAM (palette) write port
    LDA #$00
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
    LDA [$0A]
    INC $0A
    INC $0A
    TAY 
    LDA [$0A]
    INC $0A
    INC $0A
    JSL $@hdma_dma_spc.SetupHdmaChannel_Indirect
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #02 with two word operands (source/destination setup words). Passes them to SetupHdmaChannel_Direct to configure a linear DMA channel rather than indirect HDMA.

QueueDma {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    TAY 
    LDA [$0A]
    INC $0A
    INC $0A
    JSL $@hdma_dma_spc.SetupHdmaChannel_Direct
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #03 with one byte (channel ID) plus two words (A-bus table address, then B-bus register byte in low 8 bits and source bank in high 8 bits). Computes the $4300 register block offset as channel×16, ORs the channel bit into cached HDMA enable mask $0066, looks up transfer mode from hdma_channel_config, ORs #$40 into DMAP for HDMA mode, and writes DMAP/BBAD/A1T/A1B for that channel.

QueueHdmaChannel {
    PHY 
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0002
    ASL                   ; Channel ID × 16 → CPU $4300 DMA register block offset
    ASL 
    ASL 
    ASL 
    STA $0000
    LDX $0002
    SEP #$20
    LDA $@cop_handlers_flags.bitmasks_bit_position, X
    TSB $0066             ; TSB $0066: OR bit into cached HDMA channel enable mask
    REP #$20
    LDA [$0A]
    INC $0A
    INC $0A
    TAY 
    LDA [$0A]
    INC $0A
    INC $0A
    PHP 
    SEP #$20
    PHA 
    LDA #$00
    XBA 
    PHA 
    TAX 
    LDA $&hdma_ramp_tables.hdma_channel_config, X
    LDX $0000
    ORA #$40              ; ORA #$40: DMAP bit 6 selects HDMA (not linear DMA) mode
    STA $DMAP0, X         ; STA $DMAP0,X: write transfer mode for this HDMA channel
    LDA $02, S
    STA $DASB0, X
    PLA 
    STA $BBAD0, X         ; STA $BBAD0,X: B-bus destination register (VRAM/CGRAM port)
    REP #$20
    TYA 
    STA $A1T0L, X         ; STA $A1T0L,X: A-bus source address low word
    SEP #$20
    PLA 
    STA $A1B0, X          ; STA $A1B0,X: A-bus source bank byte for HDMA fetch
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
    LDA $14
    STA $0018
    LDA $16
    STA $001C
    STZ $0000
    JSR $&MarkCollisionRect
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #0C with no operands. Copies the actor pixel position into tile coordinates and calls ClearCollisionRect with flag zero, ANDing #$0F on every collisionLayer tile in the metasprite hitbox to clear solid flags while preserving the type nibble.

ClearSolidHere {
    TYX 
    LDA $14
    STA $0018
    LDA $16
    STA $001C
    STZ $0000
    JSR $&ClearCollisionRect
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #0D with two signed byte operands (tile X/Y offsets). ParseSignedTileOffset sign-extends each offset, scales by 16 pixels, converts to tile coordinates (Y adjusted −16), then ORs #$F0 onto the single collisionLayer byte at that map index.

MarkSolidOffset {
    TYX 
    JSR $&ParseSignedTileOffset
    PHX 
    PHD 
    LDA #$0000
    TCD 
    LDX #$0000
    JSL $@map_coords.TileCoordsToMapIndex
    SEP #$20
    LDA $collisionLayer, X
    ORA #$F0              ; ORA #$F0: set upper nibble — mark tile solid for collision
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
    JSR $&ParseSignedTileOffset
    PHX 
    PHD 
    LDA #$0000
    TCD 
    LDX #$0000
    JSL $@map_coords.TileCoordsToMapIndex ; AND #$0F: clear solid nibble, preserve collision type nibble
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
; COP #0F with two byte operands (absolute tile X and Y). Converts coordinates through TileCoordsToMapIndex and ORs #$F0 onto the collision byte at that index.

MarkSolidAbs {
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
    LDA $14
    STA $0018
    LDA $16
    STA $001C
    LDA #$0001
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
    LDA $collisionLayer, X ; AND #$F0: clear type nibble only, keep solid flags
    AND #$F0
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
    LDA $14
    STA $0018
    LDA $16
    STA $001C
    JSR $&TileCollisionQuery
    BIT #$000F            ; BIT #$000F: branch taken if any solid nibble bit set
    BNE loc_0089CA
    LDA [$0A]
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 

  loc_0089CA:
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #14 with two signed byte tile offsets plus one &Code operand. Sign-extends and ×16-scales each offset, adds them to actor position, runs TileCollisionQuery at the computed pixel location, and branches if the query result has any #$000F bit set.

BranchIfSolidOffset {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080            ; Sign-extend $0080 tile offset to 16-bit before ×16 shift
    BEQ loc_0089E3
    ORA #$FF00

  loc_0089E3:
    ASL 
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $14
    STA $0018
    LDA [$0A]
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
    JSR $&TileCollisionQuery
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
    LDA $14
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
    LDA $14
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
    LDA $14
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
    LDA $14
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
    LDA $14
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
    BEQ loc_008AF7
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
    LDA $14
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
    LDA $14
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
    LDA $14
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
    LDA $14
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
    LDA $16
    BIT #$000F            ; BIT #$000F: reject if actor Y not on 16px gridline
    BEQ loc_008BF0

  loc_008BE6:
    PLB 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 

  loc_008BF0:
    LDA $metaspritePtr, X
    TAY 
    SEP #$20
    LDA $7F0008, X
    PHA 
    PLB 
    REP #$20
    LDA $0000, Y
    ORA #$FF00            ; Sign-extend metasprite hitbox width from script byte
    CLC 
    ADC $14
    BIT #$000F            ; BIT #$000F: player must be grid-aligned on Y axis
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
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0018
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $001C
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0000
    LDA #$0000
    TCD 
    LDX #$0000
    JSL $@map_coords.TileCoordsToMapIndex
    SEP #$20
    LDA $00               ; Write full collision byte (type+solid) to map layer
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
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_00AF9E
    ORA #$FF00

  loc_00AF9E:
    ASL 
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $14
    LSR 
    LSR 
    LSR 
    LSR 
    STA $0018
    LDA [$0A]
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
    ADC $16
    SEC 
    SBC #$0010
    LSR 
    LSR 
    LSR 
    LSR 
    STA $001C
    RTS 
}

ComputeDirectionToPlayer {
    LDY $playerActor
    LDA $0014, Y
    SEC 
    SBC $0018
    BMI loc_00B01A
    STA $0000
    LDA $0016, Y
    SEC 
    SBC $001C
    BMI loc_00AFFE
    LDY #$0002
    CMP #$0010
    BCC loc_00B05C
    LDY #$0004
    LDA $0000
    CMP #$0010
    BCC loc_00B05C
    LDY #$0003
    BRA loc_00B05C

  loc_00AFFE:
    EOR #$FFFF
    INC 
    LDY #$0002
    CMP #$0010
    BCC loc_00B05C
    LDY #$0000
    LDA $0000
    CMP #$0010
    BCC loc_00B05C
    LDY #$0001
    BRA loc_00B05C

  loc_00B01A:
    EOR #$FFFF
    INC 
    STA $0000
    LDA $0016, Y
    SEC 
    SBC $001C
    BMI loc_00B042
    LDY #$0006
    CMP #$0010
    BCC loc_00B05C
    LDY #$0004
    LDA $0000
    CMP #$0010
    BCC loc_00B05C
    LDY #$0005
    BRA loc_00B05C

  loc_00B042:
    EOR #$FFFF
    INC 
    LDY #$0006
    CMP #$0010
    BCC loc_00B05C
    LDY #$0000
    LDA $0000
    CMP #$0010
    BCC loc_00B05C
    LDY #$0007

  loc_00B05C:
    TYA 
    RTS 
}
---------------------------------------------

; Internal JSR helper that marks a solid rectangle on the collision map. Reads metasprite hitbox width/height from the actor metasprite table, offsets from tile coordinates in DP $18/$1C, and ORs $F0 onto collisionLayer for every tile in the rectangle, wrapping rows via AdvanceMapY at map edges. Called by MarkSolidHere, MarkSolidAbs, and related solid-marking COP handlers.

MarkCollisionRect {
    PHB 
    PHD 
    PHX 
    LDA #$0000
    TCD 
    LDA $metaspritePtr, X
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
    LSR 
    LSR 
    LSR 
    LSR 
    STA $18
    LDA $0002, Y
    AND #$00FF
    STA $1A
    LDA $0001, Y
    ORA #$FF00
    CLC 
    ADC $1C
    LSR 
    LSR 
    LSR 
    LSR 
    STA $1C
    LDA $0003, Y
    AND #$00FF
    STA $1E
    LDX #$0000
    JSL $@map_coords.TileCoordsToMapIndex
    CPX #$4000
    BCS loc_00B325
    LDA $1A
    STA $18
    TXA 
    STA $1C

  loc_00B2F6:
    SEP #$20
    TAX 
    LDA $collisionLayer, X
    ORA #$F0
    STA $collisionLayer, X
    DEC $18
    BEQ loc_00B316
    REP #$20
    TXA 
    INC 
    BIT #$000F
    BNE loc_00B2F6
    CLC 
    ADC #$00F0
    BRA loc_00B2F6

  loc_00B316:
    DEC $1E
    BEQ loc_00B325
    LDA $1A
    STA $18
    JSR $&AdvanceMapY
    LDA $1C
    BRA loc_00B2F6

  loc_00B325:
    REP #$20
    PLX 
    PLD 
    PLB 
    RTS 
}

AdvanceMapY {
    PHP 
    SEP #$20
    LDA $1C
    CLC 
    ADC #$10
    BCS loc_00B339
    STA $1C
    PLP 
    RTS 

  loc_00B339:
    XBA 
    CLC 
    ADC $mapRowStrideL0
    XBA 
    REP #$20
    STA $1C
    PLP 
    RTS 
}

ClearCollisionRect {
    PHB 
    PHD 
    PHX 
    LDA #$0000
    TCD 
    LDA $metaspritePtr, X
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
    LSR                   ; LSR×4: convert pixel coords to tile coords for map edit
    LSR 
    LSR 
    LSR 
    STA $18               ; Tile width/height in tiles from metasprite hitbox / 16
    LDA $0002, Y
    AND #$00FF
    STA $1A
    LDA $0001, Y
    ORA #$FF00
    CLC 
    ADC $1C
    LSR 
    LSR 
    LSR 
    LSR 
    STA $1C
    LDA $0003, Y
    AND #$00FF
    STA $1E
    LDX #$0000
    JSL $@map_coords.TileCoordsToMapIndex
    CPX #$4000
    BCS loc_00B3E9
    LDA $1A
    STA $18
    TXA 
    STA $1C
    LDA $00
    BEQ loc_00B3A3
    JMP $&ClearCollisionRectFull

  loc_00B3A3:
    TXA 

  loc_00B3A4:
    SEP #$20
    TAX 
    LDA $collisionLayer, X
    AND #$0F
    STA $collisionLayer, X
    DEC $18
    BEQ loc_00B3C4
    REP #$20
    TXA 
    INC 
    BIT #$000F
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
    BCS loc_00B3DB
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

ClearCollisionRectFull {
    TXA 

  loc_00B3F0:
    SEP #$20
    TAX 
    LDA $collisionLayer, X
    AND #$00
    STA $collisionLayer, X
    DEC $18
    BEQ loc_00B410
    REP #$20
    TXA 
    INC 
    BIT #$000F
    BNE loc_00B3F0
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

TileCollisionQuery {
    PHD 
    LDA #$0000
    TCD 
    LDA $18
    AND #$FFF0
    BMI loc_00B47C
    CMP $cameraOffsetX
    BCC loc_00B47C
    CMP $cameraBoundsX
    BCS loc_00B47C
    LSR 
    LSR 
    LSR 
    LSR 
    STA $18
    LDA $1C
    BMI loc_00B47C
    CMP $cameraOffsetY
    BCC loc_00B47C
    CMP $cameraLowerYBound
    BCS loc_00B47C
    LSR 
    LSR 
    LSR 
    LSR 
    DEC 
    STA $1C
    JSL $@tile_collision_physics.CalcTileMapOffset
    CPY #$4000
    BCS loc_00B47C
    LDA [$80], Y
    BIT #$00F0            ; BIT #$00F0 on tile byte: non-zero type nibble = solid query hit
    BEQ loc_00B47F

  loc_00B47C:
    LDA #$000F

  loc_00B47F:
    PLD 
    RTS 
}