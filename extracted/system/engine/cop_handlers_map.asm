; COP handlers for metatile painting, world-map streaming, VRAM DMA, decompression, and occlusion queries (Bank $00, 12 COP handlers + 3 internal subroutines).
; 
; DrawMetatileAbs/Here write a metatile ID to mapLayerTilemap and collisionLayer, queue BG VRAM tile writes when on-screen. WorldMapStream3/4 parse sequential map-entry records (3 or 4 bytes) to stream tile changes with optional SFX.
; 
; AdhocVramDma stages a one-off VRAM DMA transfer gated by extendedFlags bit 0. CopyPalette transfers palette data between CGRAM staging areas. Decompress calls QuintetLzDecompress and clears the actor render list. SetScratchPointer writes a far pointer into animScratch fields.
; 
; BranchIfBehindWall tests tile-layer occlusion via CalcTileMapOffset. BranchIfCollisionTypeNe branches when the tile type nibble differs from an operand. BranchIfOffCamera compares actor position against camera bounds. HaltIfMaxFrames yields when the frame counter exceeds a threshold.
; 
; Internal: ParseMapEntry decodes tile X/Y/ID from a 3-byte stream record; returns carry set on end sentinel. ResolveTileData converts tile coordinates to a map-layer index, writes metatile and collision bytes, and queues VRAM tile updates when the tile is on-screen. TileQueryGate prevents concurrent tile queries by yielding RTL when tileQueryResult is non-zero.
---------------------------------------------

?BANK 00

?INCLUDE 'map_coords'
?INCLUDE 'QuintetLzDecompress'
?INCLUDE 'sprite_composition'
?INCLUDE 'tile_collision_physics'

!bg1ScrollH                     068A
!bg2ScrollH                     068E
!cameraOffsetX                  06D6
!cameraOffsetY                  06D8
!cameraBoundsX                  06DA
!cameraBoundsY                  06DC
!sfxQueueCh2                    06F9
!tileQueryResult                0902
!metatileMapLayer               7E2000
!mapLayerTilemap                7EA000
!animScratch                    7F0000
!orbitAngle                     7F0010
!extendedFlags                  7F002A
!adhocVramDma                   7F0C03
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

---------------------------------------------
; COP #4F with staged operands on first use: reads source word, byte, dest word, and size word into adhocVramDma staging and sets extendedFlags bit 0, then yields RTL. Later calls while bit 0 is set poll completion against the staged size; clears bit 0 and RTI to resume when done.

AdhocVramDma {
    TYX 
    LDA $extendedFlags, X ; Check extendedFlags bit 0 (adhoc VRAM DMA already staged)
    BIT #$0001
    BNE loc_00990E
    LDA $7F0C07           ; Check if DMA staging area is clear ($7F0C07 = 0)
    BEQ loc_0098D1        ; Check if DMA staging area clear ($7F0C07)
    LDA $0A               ; DMA busy: rewind and yield RTL
    DEC 
    DEC 
    STA $00
    PLA 
    PLA 
    RTL 

  loc_0098D1:
    LDA $0A               ; First call: rewind PC and stage all DMA operands
    DEC 
    DEC 
    STA $00
    LDA [$0A]             ; Read source address word into adhocVramDma ($7F0C03)
    INC $0A
    INC $0A
    STA $adhocVramDma
    LDA [$0A]             ; Read source bank byte into $7F0C05
    INC $0A
    AND #$00FF
    STA $7F0C05
    LDA [$0A]             ; Read VRAM destination word into $7F0C07
    INC $0A
    INC $0A
    STA $7F0C07
    LDA [$0A]             ; Read transfer size word into $7F0C09
    INC $0A
    INC $0A
    STA $7F0C09
    LDA $extendedFlags, X
    ORA #$0001            ; Set extendedFlags bit 0 (DMA pending)
    STA $extendedFlags, X
    PLA 
    PLA 
    RTL 

  loc_00990E:
    LDY #$0003            ; Polling path: compare current VRAM dest against staged dest
    LDA [$0A], Y          ; Polling: compare current VRAM dest vs staged
    CMP $7F0C07           ; If staged and current match → DMA still pending, yield
    BNE loc_00991C
    PLA 
    PLA 
    RTL 

  loc_00991C:
    LDA $extendedFlags, X ; DMA complete: clear bit 0 and skip 7-byte operand block
    AND #$FFFE            ; DMA complete: clear bit 0, skip 7-byte operand block
    STA $extendedFlags, X
    LDA $0A
    CLC 
    ADC #$0007
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #50 with five operands: word source base, byte bank, byte source palette index, byte dest palette index, byte count. Copies palette entries through the $0402 DMA helper into CGRAM staging (indices scaled ×2, dest base $0A00).

CopyPalette {
    PHY 
    LDA [$0A]             ; Read palette source base address (word)
    INC $0A
    INC $0A
    PHA 
    LDA [$0A]             ; Read palette source bank byte
    INC $0A
    AND #$00FF
    SEP #$20
    STA $0405             ; Store bank byte to DMA helper register $0405
    REP #$20
    LDA [$0A]             ; Read source palette index byte
    INC $0A
    AND #$00FF
    ASL                   ; Index ×2 for word-sized palette entries
    CLC                   ; Add to source base → X = source palette address
    ADC $01, S            ; Palette copy: source index ×2 into CGRAM staging buffer
    TAX 
    PLA 
    LDA [$0A]             ; Read destination palette index byte
    INC $0A
    AND #$00FF
    ASL                   ; Index ×2 for CGRAM word entries
    CLC 
    ADC #$0A00            ; Add $0A00 (CGRAM staging base) → Y = dest address
    TAY 
    SEP #$20
    LDA #$7F              ; Set source bank to $7F (animScratch region)
    STA $0404
    REP #$20
    LDA [$0A]             ; Read palette entry count
    INC $0A
    AND #$00FF
    ASL                   ; Count ×2 for word-sized entries, DEC for loop counter
    DEC 
    JSR $0402             ; Call DMA helper at $0402 to copy palette data
    PLX 
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #51 with word source pointer, byte source bank, and word VRAM destination. Calls QuintetLzDecompress then ClearActorRenderList before resuming the script.

Decompress {
    PHY 
    PHD 
    LDA [$0A]             ; Decompress: read LZ source pointer word
    INC $0A
    INC $0A
    STA $003E             ; Store source address at DP $3E for QuintetLzDecompress
    LDA [$0A]             ; Read source bank byte
    INC $0A
    AND #$00FF
    SEP #$20
    STA $0040             ; Store source bank at DP $40
    REP #$20
    LDA [$0A]             ; Read VRAM destination word
    INC $0A
    INC $0A
    STA $007A             ; Store VRAM dest at DP $7A
    LDA [$0A]
    INC $0A
    AND #$00FF
    LDA #$0000
    TCD                   ; Zero DP for decompression workspace
    LDA [$3E]             ; Read compressed data length word from source stream
    STA $78
    INC $3E
    INC $3E
    JSL $@QuintetLzDecompress ; Decompress Quintet LZ data to VRAM staging
    JSL $@sprite_composition.ClearActorRenderList ; Clear actor render list after graphics rewrite
    PLD 
    PLX 
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #54 with one word plus one byte operand. Stores the far pointer in animScratch ($7F0000 word, $7F0002 bank) for later use by handler or callback code.

SetScratchPointer {
    TYX 
    LDA [$0A]             ; Read far pointer word for animScratch
    INC $0A
    INC $0A
    STA $animScratch, X   ; Store pointer to animScratch ($7F0000+X)
    LDA [$0A]             ; Read bank byte for far pointer
    INC $0A
    AND #$00FF
    STA $animScratch+2, X ; Store bank to animScratch+2 ($7F0002+X)
    LDA $0A
    STA $02, S
    RTI 
}
---------------------------------------------

; COP #5D wall-occlusion branch taking one &Code operand. Converts the actor pixel position to tile coordinates, samples collisionLayer via CalcTileMapOffset, and checks layer-aware visibility. If the actor is visible (not behind a blocking tile), the script jumps to the branch target; if occluded, it skips the operand and continues. Used by Eyesore, diamond-mine enemies, and similar actors that should only activate when unobstructed.

BranchIfBehindWall {
    TYX 
    LDA $14               ; Convert actor X to tile coordinate (pixel ÷ 16 via LSR ×4)
    LSR 
    LSR 
    LSR 
    LSR 
    STA $0018
    LDA $16               ; Convert actor Y to tile coordinate
    LSR 
    LSR 
    LSR 
    LSR 
    STA $001C
    PHD 
    LDA #$0000
    TCD                   ; CalcTileMapOffset: collision layer pointer for tile
    JSL $@tile_collision_physics.CalcTileMapOffset ; CalcTileMapOffset: get collision layer pointer for tile
    CPY #$4000            ; Y ≥ $4000 means out-of-bounds → treat as occluded
    BCS loc_009B37
    LDA $000F, X
    AND #$0010            ; Test actor flag $0010 for layer-aware occlusion mode
    BEQ loc_009B1C
    LDA [$80], Y          ; Layer-aware mode: check collision nibble
    AND #$000F
    BEQ loc_009B2D
    BRA loc_009B2D

  loc_009B1C:
    LDA [$80], Y          ; Standard mode: test solid nibble ($F0)
    BIT #$00F0
    BNE loc_009B37        ; Any solid bit → occluded (take branch)
    AND #$000F            ; Low nibble = 0 (empty) → visible
    BEQ loc_009B2D
    CMP #$000E            ; Type $0E = passthrough → visible despite nonzero nibble
    BNE loc_009B37

  loc_009B2D:
    PLD                   ; Visible: skip branch operand and continue script
    LDA $0A
    CLC 
    ADC #$0002
    STA $02, S
    RTI 

  loc_009B37:
    PLD                   ; Occluded: take branch to target
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #62 with one byte (collision type nibble) and one &Code branch target. Samples collisionLayer at the actor's tile via CalcTileMapOffset; jumps to the branch target when the tile's low nibble equals the operand or the position is out of bounds, otherwise skips the branch operand.

BranchIfCollisionTypeNe {
    TYX 
    LDA $14               ; Convert actor X pixel to tile coords (÷16)
    LSR 
    LSR 
    LSR 
    LSR 
    STA $0018
    LDA $16               ; Convert actor Y to tile coords
    LSR 
    LSR 
    LSR 
    LSR 
    STA $001C
    LDA [$0A]             ; Read expected collision type byte operand
    INC $0A
    AND #$00FF
    STA $0000             ; Store in DP $00 for comparison
    PHD 
    LDA #$0000
    TCD 
    JSL $@tile_collision_physics.CalcTileMapOffset ; CalcTileMapOffset for collision lookup
    CPY #$4000            ; Y ≥ $4000 = out of bounds → take branch
    BCS loc_009B7F
    LDA [$80], Y          ; Read collision layer byte at tile position
    AND #$000F            ; Mask to low nibble (collision type)
    CMP $00               ; Compare against expected type
    BEQ loc_009B7F        ; Match → take branch target
    PLD 
    LDA $0A               ; No match: skip branch operand and continue
    CLC 
    ADC #$0002
    STA $02, S
    RTI 

  loc_009B7F:
    PLD 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}
---------------------------------------------

; COP #68 (script name BranchIfOffscreen) camera-bounds branch taking one &Code operand. Compares the actor pixel position ($14/$16) against cameraOffsetX/Y and cameraBoundsX/Y; if the actor is on screen, the branch operand is skipped and execution continues. If the actor is outside the visible window, the script jumps to the branch target. Used by off-screen despawn and activation logic.

BranchIfOffCamera {
    TYX 
    LDA $14               ; Compare actor X against cameraOffsetX/cameraBoundsX window
    BMI loc_009DE1
    CMP $cameraOffsetX    ; Below cameraOffsetX → off-camera left
    BCC loc_009DE1
    CMP $cameraBoundsX    ; Above cameraBoundsX → off-camera right
    BCS loc_009DE1
    LDA $16               ; Compare actor Y position against vertical camera window
    BMI loc_009DE1
    CMP $cameraOffsetY    ; Below cameraOffsetY → off-camera top
    BCC loc_009DE1
    CMP $cameraBoundsY    ; Above cameraBoundsY → off-camera bottom
    BCS loc_009DE1
    LDA $0A               ; All bounds passed: actor is on-camera, skip branch operand
    INC 
    INC 
    STA $02, S
    RTI 

  loc_009DE1:
    LDA [$0A]             ; Off-camera: take branch to target
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #69 with one word operand (max frame count). Compares against global frame counter $00E4; yields RTL when the counter has reached or exceeded the limit, otherwise RTI and continues.

HaltIfMaxFrames {
    TYX 
    LDA [$0A]             ; Read max frame count threshold (word)
    INC $0A
    INC $0A
    CMP $00E4             ; Compare threshold against global frame counter $00E4
    BCC loc_009E01        ; Counter ≥ threshold → yield has expired, resume script
    LDA $0A               ; Counter < threshold: rewind script and yield RTL
    SEC 
    SBC #$0004
    STA $00
    PLA 
    PLA 
    RTL 

  loc_009E01:
    LDA $0A
    STA $02, S
    RTI 
}