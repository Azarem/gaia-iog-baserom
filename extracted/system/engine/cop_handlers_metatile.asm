; COP handlers that overwrite one metatile of LAYER 0 at run time (Bank 00, COP #4B-#4E) plus their helpers. Used by puzzle rooms, breakable walls and the item-use effects to swap floor/wall tiles.
; 
; Script sites: DrawMetatileAbs (#4B) 24, DrawMetatileHere (#4C) 8 (2 in pyD0_breakable_wall, 6 in item_use_system). WorldMapStream3 (#4D) and WorldMapStream4 (#4E) have no script sites.
; 
; All writes go to layer 0 only: collision flags come from $7F0000 + metatile ID (the layer-0 table; collisionFlagTableL1 sits at $7F0100 and is not used here), the map is $7EA000 + index (mapLayerTilemap), the collision map is $7FC000 + index, and the tile definitions are read from the hard-coded $7E2000 + ID x 8 (metatileDefBase is $2000 for layer 0, $2800 for layer 1). A tile is repainted on screen only when it lies in the visible window: horizontally (pixel X + 16 - bg1ScrollH) < $0111, vertically 0 <= pixel Y - ((mapScrollV - $10) and $FFF0) < $F1. Off-screen tiles only update the map and collision data.
; The staged update is one 2x2 metatile: $0902 = VRAM word address of the top row (BG1 nametable at $1000 via PixelToVramAddress), $0908 = that + $20, tile words $0904/$0906 (top) and $090A/$090C (bottom). The NMI flush in event_blocks writes it and clears $0902; TileQueryGate makes the next draw wait until $0902 is zero again. The name tileQueryResult is a misnomer.
; 
; Direct page: the handlers run with D = actor; the stores to $0018/$001A/$001C/$001E/$0000 are absolute (page-0 scratch) and become the DP $18/$1A/$1C/$1E/$00 seen by ResolveTileData after TCD zeroes D. The page-0 $00 here is NOT the actor's entry word. DrawMetatileHere takes the actor's $14/$16 as TILE coordinates (no divide by 16); pyD0_breakable_wall converts its pixel position first and saves the originals in orbitAngle/orbitDiameter ($7F0010/$7F0012).
; WorldMapStream3/4 stream one 3- or 4-byte record per call (X tile, Y tile, metatile ID, and for #4E a delay byte stored in the actor's $08 wait counter), cache the pointer in $24, rewind the script pointer by 2 and yield between tiles, and an X byte with bit 7 set ends the stream. extendedFlags ($7F002A) bit 1 = pointer cached, bit 2 = queue orbitAngle as a sound effect (sfxQueueCh2) per tile; nothing in the extracted scripts uses them.
---------------------------------------------

?BANK 00

?INCLUDE 'map_coords'

!bg1ScrollH                     068A
!mapScrollV                     068E
!sfxQueueCh2                    06F9
!tileQueryResult                0902
!metatileMapLayer               7E2000
!mapLayerTilemap                7EA000
!animScratch                    7F0000
!orbitAngle                     7F0010
!extendedFlags                  7F002A
!collisionLayer                 7FC000

---------------------------------------------

; COP #4B with three byte operands: tile X, tile Y, metatile ID. Waits (rewinds the script pointer and yields) while TileQueryGate reports a pending update, otherwise converts the tile coordinates to pixels and calls ResolveTileData to update the layer-0 map and collision data and, when the tile is on screen, stage the 2x2 VRAM update. 24 sites.

DrawMetatileAbs {
    TYX 
    JSR $&TileQueryGate   ; TileQueryGate: carry set = tile update pending, must yield
    BCC loc_00968E
    PLA                   ; Gate busy: pop COP frame and yield RTL (retry next frame)
    PLA 
    RTL 

  loc_00968E:
    LDA [$0A]             ; Read absolute tile X byte operand
    INC $0A
    AND #$00FF
    STA $0018             ; Absolute store to page-0 scratch $18 (tile X); it becomes DP $18 after TCD zeroes D below
    ASL                   ; Tile→pixel: ASL ×4 = ×16
    ASL 
    ASL 
    ASL 
    STA $001A             ; Store pixel X in DP $1A
    LDA [$0A]             ; Read absolute tile Y byte operand
    INC $0A
    AND #$00FF
    STA $001C             ; Store tile Y in DP $1C
    ASL                   ; Tile→pixel for Y
    ASL 
    ASL 
    ASL 
    STA $001E             ; Store pixel Y in DP $1E
    LDA [$0A]             ; Read metatile ID byte operand
    INC $0A
    AND #$00FF
    STA $0000             ; Page-0 scratch $00 = metatile ID (not the actor's entry word)
    PHY 
    PHD 
    LDA #$0000            ; Zero direct page for map_coords routines
    TCD 
    JSR $&ResolveTileData ; Write metatile to map layers and queue VRAM update if on-screen
    PLD 
    PLX 
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #4C with one byte operand (metatile ID). Uses the actor's $14/$16 as TILE X/Y (the callers, pyD0_breakable_wall and item_use_system, must have converted pixel coordinates first), then behaves like DrawMetatileAbs. 8 sites.

DrawMetatileHere {
    TYX 
    JSR $&TileQueryGate   ; TileQueryGate for DrawMetatileHere
    BCC loc_0096D3
    PLA 
    PLA 
    RTL 

  loc_0096D3:
    PHY 
    PHD 
    LDA [$0A]             ; Read metatile ID byte operand
    INC $0A
    AND #$00FF
    STA $0000             ; Store metatile ID in DP $00
    LDA #$0000
    TCD 
    LDA $0014, X          ; Actor X is used as a TILE X without dividing by 16: callers convert first (pyD0_breakable_wall does)
    STA $18
    ASL 
    ASL 
    ASL 
    ASL 
    STA $1A
    LDA $0016, X          ; Actor Y used as a TILE Y
    STA $1C
    ASL 
    ASL 
    ASL 
    ASL 
    STA $1E
    JSR $&ResolveTileData ; Resolve tile data at actor's position
    PLD 
    PLX 
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #4D with one word operand (stream pointer, cached in $24 on the first call). Each call paints one record (X, Y, tile ID) from the stream, optionally queues orbitAngle as a sound effect on channel 2 (extendedFlags bit 2), rewinds the script pointer by 2 and yields; a record whose X byte has bit 7 set ends the stream and the op continues past its 2-byte operand. No script sites.

WorldMapStream3 {
    TYX 
    JSR $&TileQueryGate   ; TileQueryGate for stream entry
    BCC loc_00970C
    PLA 
    PLA 
    RTL 

  loc_00970C:
    LDA $extendedFlags, X ; Check extendedFlags bit 1 (stream already initialized)
    BIT #$0002
    BNE loc_009720
    ORA #$0002            ; First call: set bit 1 and cache stream pointer from script
    STA $extendedFlags, X
    LDA [$0A]             ; Read stream base pointer word from script into $24
    STA $24

  loc_009720:
    PHX 
    PHD 
    PHB 
    SEP #$20              ; Switch DBR to script bank for stream data access
    LDA $02
    PHA 
    PLB 
    REP #$20
    LDA $24               ; Load current stream position from $24
    TAX 
    INC                   ; Advance stream pointer by 3 bytes (one map entry)
    INC 
    INC 
    STA $24
    JSR $&ParseMapEntry   ; Parse 3-byte map entry: X, Y, metatile ID
    BCS loc_00975B        ; Carry set = end-of-stream sentinel encountered
    PLB 
    JSR $&ResolveTileData ; Resolve tile: write metatile and queue VRAM update
    PLD 
    PLX 
    LDA $extendedFlags, X ; Check extendedFlags bit 2 (SFX-on-tile mode)
    BIT #$0004
    BEQ loc_009752
    SEP #$20
    LDA $orbitAngle, X    ; Queue orbitAngle byte as SFX on channel 2
    STA $sfxQueueCh2
    REP #$20

  loc_009752:
    LDA $0A               ; Rewind script PC by 2 (re-enter stream handler next frame)
    DEC 
    DEC 
    STA $00
    PLA 
    PLA 
    RTL 

  loc_00975B:
    REP #$20              ; End of stream: clean up and resume script
    PLB 
    PLD 
    PLX 
    LDA $extendedFlags, X
    AND #$FFFD            ; Clear stream-initialized bit in extendedFlags
    STA $extendedFlags, X
    LDA $0A
    CLC 
    ADC #$0002            ; Skip 2-byte stream pointer operand to advance past handler
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #4E, like WorldMapStream3 with 4-byte records: the fourth byte is stored in the actor's $08 (the wait counter), so it is a per-record delay, not a tile attribute. No script sites.

WorldMapStream4 {
    TYX 
    JSR $&TileQueryGate
    BCC loc_00977D
    PLA 
    PLA 
    RTL 

  loc_00977D:
    LDA $extendedFlags, X
    BIT #$0002            ; First call caches script stream pointer in $24 and sets extendedFlags bit 1
    BNE loc_009791
    ORA #$0002
    STA $extendedFlags, X
    LDA [$0A]
    STA $24

  loc_009791:
    PHX 
    PHD 
    PHB 
    SEP #$20
    LDA $02
    PHA 
    PLB 
    REP #$20
    LDA $24
    TAX 
    CLC 
    ADC #$0004            ; Advance stream by 4 bytes per entry
    STA $24
    JSR $&ParseMapEntry   ; Parse 3-byte core of map entry (X, Y, metatile)
    BCS loc_0097D6
    LDA $0003, X          ; 4th record byte: per-record delay for the actor's $08 wait counter
    AND #$00FF
    STA $0008, Y          ; $08 = wait counter; DBR is the script bank here, so this hits the LowRAM mirror of the actor's DP
    PLB 
    JSR $&ResolveTileData
    PLD 
    PLX 
    LDA $extendedFlags, X
    BIT #$0004
    BEQ loc_0097CD
    SEP #$20
    LDA $orbitAngle, X    ; Orbit angle byte queued as SFX on channel 2 when flag bit 2
    STA $sfxQueueCh2
    REP #$20

  loc_0097CD:
    LDA $0A
    DEC 
    DEC 
    STA $00
    PLA 
    PLA 
    RTL 

  loc_0097D6:
    REP #$20
    PLB 
    PLD 
    PLX 
    LDA $extendedFlags, X
    AND #$FFFD
    STA $extendedFlags, X
    LDA $0A
    CLC 
    ADC #$0002
    STA $02, S
    RTI 
}

---------------------------------------------
; Decodes the 3-byte record at stream address X: byte 0 = tile X (bit 7 set = end of stream, carry set), byte 1 = tile Y, byte 2 = metatile ID. Zero-extends (not sign-extends) the coordinates into DP $18/$1C, stores pixel positions (x16) in $1A/$1E and the metatile ID in $00, returns carry clear. Sets D = 0 itself.

ParseMapEntry {
    LDA #$0000
    TCD 
    SEP #$20              ; 8-bit mode for byte-size stream reads
    LDA $0000, X          ; Read stream byte 0 (tile X) — bit 7 = end sentinel
    BMI loc_009827        ; Bit 7 set → end of stream (return carry set)
    STA $18               ; Store tile X to DP $18
    LDA $0001, X          ; Read stream byte 1 (tile Y)
    STA $1C
    LDA $0002, X          ; Read stream byte 2 (metatile ID)
    REP #$20
    AND #$00FF
    STA $00               ; Store metatile ID in DP $00
    LDA $18
    AND #$00FF            ; Zero-extended, not sign-extended (the end sentinel is bit 7 of the X byte, tested above)
    STA $18
    ASL                   ; Tile X -> pixel X (x16) into DP $1A
    ASL 
    ASL 
    ASL 
    STA $1A
    LDA $1C
    AND #$00FF
    STA $1C
    ASL                   ; Tile Y -> pixel Y (x16) into DP $1E
    ASL 
    ASL 
    ASL 
    STA $1E
    CLC                   ; Carry clear = valid entry parsed
    RTS 

  loc_009827:
    SEC                   ; Carry set = end-of-stream signal
    RTS 
}

---------------------------------------------
; Writes one metatile of layer 0: map index from TileCoordsToMapIndex (layer selector 0), collision byte from $7F0000 + ID copied to $7FC000 + index, the ID to mapLayerTilemap ($7EA000 + index). If the tile is inside the visible window it then copies the four tile words of the definition at $7E2000 + ID x 8 to $0904/$0906/$090A/$090C and stores the VRAM word addresses of the two tile rows in $0902 and $0908 (PixelToVramAddress, BG1 nametable). Off-screen tiles stop after the map writes.

ResolveTileData {
    LDX #$0000            ; Convert tile coords (DP $18/$1C) to linear map index via TileCoordsToMapIndex
    JSL $@map_coords.TileCoordsToMapIndex ; TileCoordsToMapIndex: DP $18/$1C → linear map index in X
    LDA $00               ; Load metatile ID from DP $00
    PHX 
    TAX 
    SEP #$20              ; 8-bit mode for byte-level map layer writes
    LDA $animScratch, X   ; $7F0000 + metatile ID = layer-0 collision byte of that metatile (layer 1's table is at $7F0100, unused here)
    STA $02               ; Cache collision byte in DP $02
    TXA 
    PLX 
    STA $mapLayerTilemap, X ; Write metatile ID to mapLayerTilemap (7EA000+X)
    LDA $02
    STA $collisionLayer, X ; Write collision byte to collisionLayer (7FC000+X)
    REP #$20
    LDA $1A
    CLC                   ; On-screen check: pixel X + 16 vs BG1 horizontal scroll
    ADC #$0010            ; Visible if pixel X + 16 - bg1ScrollH < $0111, i.e. X in scroll - 16 .. scroll + $100
    SEC 
    SBC $bg1ScrollH
    CMP #$0111            ; Off-screen if distance ≥ $0111 pixels (beyond visible width)
    BCS loc_0098A8
    LDA $mapScrollV       ; Vertical window base = (mapScrollV - $10) rounded down to 16; pixel Y - base must be 0 .. $F0
    SEC 
    SBC #$0010
    AND #$FFF0
    PHA 
    LDA $1E
    SEC 
    SBC $01, S
    BMI loc_0098A7
    CMP #$00F1
    BCS loc_0098A7
    PLA 
    LDA $mapLayerTilemap, X ; Expand metatile ID → 4 VRAM tile words from metatileMapLayer table
    AND #$00FF
    ASL                   ; Metatile index × 8 (each metatile has 8 bytes = 4 tile words)
    ASL 
    ASL 
    TAX 
    LDA $metatileMapLayer, X ; Definition read from hard-coded $7E2000 + ID x 8 (layer 0 definitions; four tile words TL, TR, BL, BR)
    STA $0904             ; Store to tile update queue $0904 (top-left)
    LDA $7E2002, X
    STA $0906             ; Store top-right tile word to $0906
    LDA $7E2004, X
    STA $090A             ; Store bottom-left to $090A
    LDA $7E2006, X
    STA $090C             ; Store bottom-right to $090C
    JSL $@map_coords.PixelToVramAddress ; Compute VRAM address pair from pixel position
    STA $tileQueryResult  ; $0902 = VRAM word address of the top tile row; the NMI flush writes the 2x2 update and clears it
    CLC 
    ADC #$0020            ; +$0020 = VRAM offset for bottom tile row (32 words per row)
    STA $0908             ; $0908 = VRAM word address of the bottom row
    RTS 

  loc_0098A7:
    PLA 

  loc_0098A8:
    RTS 
}

---------------------------------------------
; Carry clear (proceed) when $0902 is zero, i.e. the previous 2x2 update has been flushed by the NMI. Otherwise rewinds the script pointer by 2 (back to the COP opcode, so the op runs again next time) and returns carry set; the callers then pop their return and yield.

TileQueryGate {
    CLC                   ; Start with carry clear (optimistic: gate open)
    LDA $tileQueryResult  ; Check tileQueryResult — nonzero means prior tile update pending
    BNE loc_0098B0        ; Pending: rewind script PC and return carry set (gate closed)
    RTS 

  loc_0098B0:
    LDA $0A               ; Rewind script pointer by 2 bytes for re-entry
    DEC 
    DEC 
    STA $00
    SEC 
    RTS 
}