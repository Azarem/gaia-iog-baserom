?BANK 00

?INCLUDE 'map_coords'

!bg1ScrollH                     068A
!bg2ScrollH                     068E
!sfxQueueCh2                    06F9
!tileQueryResult                0902
!metatileMapLayer               7E2000
!mapLayerTilemap                7EA000
!animScratch                    7F0000
!orbitAngle                     7F0010
!extendedFlags                  7F002A
!collisionLayer                 7FC000

---------------------------------------------

; COP #4B metatile painter taking three byte operands: absolute tile X, tile Y, and metatile ID. Passes through TileQueryGate (RTL early-out if a tile query is already pending), converts tile coords to pixel positions, and calls ResolveTileData to update mapLayerTilemap and collisionLayer and queue BG VRAM tile writes when the target lies on screen. Used heavily in puzzle rooms and mine collapse scenes to swap floor/wall tiles.

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
    STA $0018             ; Store tile X coordinate in DP $18
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
    STA $0000             ; Store metatile ID in DP $00 for ResolveTileData
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
; COP #4C with one byte operand (metatile ID). Uses the actor's pixel position ($14/$16), passes TileQueryGate, then calls ResolveTileData to write mapLayerTilemap/collisionLayer and queue on-screen BG VRAM tile updates.

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
    LDA $0014, X          ; Get actor pixel X ($14) and use as tile X
    STA $18
    ASL 
    ASL 
    ASL 
    ASL 
    STA $1A
    LDA $0016, X          ; Get actor pixel Y ($16) for tile Y
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
; COP #4D with one word operand (stream pointer, cached in $24 on first call). Each invocation reads one 3-byte record (X, Y, tile ID) via ParseMapEntry and ResolveTileData, yields RTL per tile, and optionally queues orbitAngle as SFX on channel 2 when extendedFlags bit 2 is set; RTI continues the stream until ParseMapEntry signals end.

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
; COP #4E with one word operand, same streaming model as WorldMapStream3 but advances 4 bytes per record. The fourth stream byte is stored in $0008,Y before ResolveTileData; SFX and yield behavior match the 3-byte variant.

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
    LDA $0003, X          ; Read 4th stream byte (extended tile attribute)
    AND #$00FF
    STA $0008, Y          ; Store extended attribute in $0008,Y
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
; Decodes a 3-byte stream record at address X into tile coordinates and metatile ID.
; 
; Zeroes direct page, reads 3 bytes from the stream: byte 0 = tile X, byte 1 = tile Y, byte 2 = metatile ID. If byte 0 has bit 7 set, returns carry set (end-of-stream sentinel). Otherwise sign-extends tile coords, computes pixel positions (×16) in DP $1A/$1E, stores tile coords in DP $18/$1C and metatile ID in DP $00, and returns carry clear. Called by WorldMapStream3/4 for sequential tile painting.

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
    AND #$00FF
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
; Converts parsed tile coordinates to a map-layer index and writes metatile and collision data.
; 
; Calls TileCoordsToMapIndex (DP $18/$1C → linear index in X), reads the collision byte from animScratch[index], writes the metatile ID to mapLayerTilemap[index] and collision byte to collisionLayer[index]. Then checks if the tile is on-screen by comparing pixel X against BG1 scroll and pixel Y against BG2 scroll. When visible, expands the metatile into four 16×16 VRAM tile words from metatileMapLayer, stages them in the tile-update queue ($0904–$090C), and computes the VRAM address pair via PixelToVramAddress. Called by DrawMetatileAbs/Here and WorldMapStream3/4.

ResolveTileData {
    LDX #$0000            ; Convert tile coords (DP $18/$1C) to linear map index via TileCoordsToMapIndex
    JSL $@map_coords.TileCoordsToMapIndex ; TileCoordsToMapIndex: DP $18/$1C → linear map index in X
    LDA $00               ; Load metatile ID from DP $00
    PHX 
    TAX 
    SEP #$20              ; 8-bit mode for byte-level map layer writes
    LDA $animScratch, X   ; Look up collision byte from animScratch; write metatile+collision to map layers
    STA $02               ; Cache collision byte in DP $02
    TXA 
    PLX 
    STA $mapLayerTilemap, X ; Write metatile ID to mapLayerTilemap (7EA000+X)
    LDA $02
    STA $collisionLayer, X ; Write collision byte to collisionLayer (7FC000+X)
    REP #$20
    LDA $1A
    CLC                   ; On-screen check: pixel X + 16 vs BG1 horizontal scroll
    ADC #$0010            ; Check if tile is on-screen: pixel X vs BG1 scroll, pixel Y vs BG2 scroll
    SEC 
    SBC $bg1ScrollH
    CMP #$0111            ; Off-screen if distance ≥ $0111 pixels (beyond visible width)
    BCS loc_0098A8
    LDA $bg2ScrollH       ; Compare pixel Y against BG2 vertical scroll window
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
    LDA $metatileMapLayer, X ; Load top-left tile word from metatile definition
    STA $0904             ; Store to tile update queue $0904 (top-left)
    LDA $7E2002, X
    STA $0906             ; Store top-right tile word to $0906
    LDA $7E2004, X
    STA $090A             ; Store bottom-left to $090A
    LDA $7E2006, X
    STA $090C             ; Store bottom-right to $090C
    JSL $@map_coords.PixelToVramAddress ; Compute VRAM address pair from pixel position
    STA $tileQueryResult  ; Store VRAM address for top tile row to tileQueryResult
    CLC 
    ADC #$0020            ; +$0020 = VRAM offset for bottom tile row (32 words per row)
    STA $0908             ; Store bottom row VRAM address to $0908
    RTS 

  loc_0098A7:
    PLA 

  loc_0098A8:
    RTS 
}

---------------------------------------------
; Concurrency guard for tile mutation handlers. Returns carry clear (proceed) when tileQueryResult ($0902) is zero, indicating no pending tile update. Returns carry set (busy) when a previous tile update is still queued — rewinds the script PC by 2 bytes so the COP handler yields RTL and re-enters on the next frame. Called at the top of DrawMetatileAbs/Here and WorldMapStream3/4.

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