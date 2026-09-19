; COP handlers for metatile painting, world-map streaming, VRAM DMA, decompression, and occlusion queries (Bank $00, 12 handlers).
; 
; DrawMetatileAbs/Here write a metatile ID to mapLayerTilemap and collisionLayer, queue BG VRAM tile writes when on-screen. WorldMapStream3/4 parse sequential map-entry records (3 or 4 bytes) to stream tile changes with optional SFX.
; 
; AdhocVramDma stages a one-off VRAM DMA transfer gated by extendedFlags bit 0. CopyPalette transfers palette data between CGRAM staging areas. Decompress calls QuintetLzDecompress and clears the actor render list. SetScratchPointer writes a far pointer into animScratch fields.
; 
; BranchIfBehindWall tests tile-layer occlusion via CalcTileMapOffset. BranchIfCollisionTypeNe branches when the tile type nibble differs from an operand. BranchIfOffCamera compares actor position against camera bounds. HaltIfMaxFrames yields when the frame counter exceeds a threshold.
; 
; Internal: ParseMapEntry decodes tile X/Y/ID from a byte stream. ResolveTileData converts tile coordinates to map index and writes metatile/collision bytes. TileQueryGate prevents concurrent tile queries.
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
    JSR $&TileQueryGate
    BCC loc_00968E
    PLA 
    PLA 
    RTL 

  loc_00968E:
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0018
    ASL 
    ASL 
    ASL 
    ASL 
    STA $001A
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $001C
    ASL 
    ASL 
    ASL 
    ASL 
    STA $001E
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0000
    PHY 
    PHD 
    LDA #$0000
    TCD 
    JSR $&ResolveTileData
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
    JSR $&TileQueryGate
    BCC loc_0096D3
    PLA 
    PLA 
    RTL 

  loc_0096D3:
    PHY 
    PHD 
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0000
    LDA #$0000
    TCD 
    LDA $0014, X
    STA $18
    ASL 
    ASL 
    ASL 
    ASL 
    STA $1A
    LDA $0016, X
    STA $1C
    ASL 
    ASL 
    ASL 
    ASL 
    STA $1E
    JSR $&ResolveTileData
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
    JSR $&TileQueryGate
    BCC loc_00970C
    PLA 
    PLA 
    RTL 

  loc_00970C:
    LDA $extendedFlags, X
    BIT #$0002
    BNE loc_009720
    ORA #$0002
    STA $extendedFlags, X
    LDA [$0A]
    STA $24

  loc_009720:
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
    INC 
    INC 
    INC 
    STA $24
    JSR $&ParseMapEntry
    BCS loc_00975B
    PLB 
    JSR $&ResolveTileData
    PLD 
    PLX 
    LDA $extendedFlags, X
    BIT #$0004
    BEQ loc_009752
    SEP #$20
    LDA $orbitAngle, X
    STA $sfxQueueCh2
    REP #$20

  loc_009752:
    LDA $0A
    DEC 
    DEC 
    STA $00
    PLA 
    PLA 
    RTL 

  loc_00975B:
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
    BIT #$0002            ; BIT #$0002: first WorldMapStream3 call caches script ptr in $24
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
    ADC #$0004            ; Stream pointer += 4 bytes per map entry (4-byte records)
    STA $24
    JSR $&ParseMapEntry
    BCS loc_0097D6
    LDA $0003, X
    AND #$00FF
    STA $0008, Y
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

ParseMapEntry {
    LDA #$0000
    TCD 
    SEP #$20
    LDA $0000, X
    BMI loc_009827
    STA $18
    LDA $0001, X
    STA $1C
    LDA $0002, X
    REP #$20
    AND #$00FF
    STA $00
    LDA $18
    AND #$00FF
    STA $18
    ASL 
    ASL 
    ASL 
    ASL 
    STA $1A
    LDA $1C
    AND #$00FF
    STA $1C
    ASL 
    ASL 
    ASL 
    ASL 
    STA $1E
    CLC 
    RTS 

  loc_009827:
    SEC 
    RTS 
}

ResolveTileData {
    LDX #$0000
    JSL $@map_coords.TileCoordsToMapIndex
    LDA $00
    PHX 
    TAX 
    SEP #$20
    LDA $animScratch, X
    STA $02
    TXA 
    PLX 
    STA $mapLayerTilemap, X
    LDA $02
    STA $collisionLayer, X
    REP #$20
    LDA $1A
    CLC 
    ADC #$0010
    SEC 
    SBC $bg1ScrollH
    CMP #$0111
    BCS loc_0098A8
    LDA $bg2ScrollH
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
    LDA $mapLayerTilemap, X
    AND #$00FF
    ASL 
    ASL 
    ASL 
    TAX 
    LDA $metatileMapLayer, X
    STA $0904
    LDA $7E2002, X
    STA $0906
    LDA $7E2004, X
    STA $090A
    LDA $7E2006, X
    STA $090C
    JSL $@map_coords.PixelToVramAddress
    STA $tileQueryResult
    CLC 
    ADC #$0020
    STA $0908
    RTS 

  loc_0098A7:
    PLA 

  loc_0098A8:
    RTS 
}

TileQueryGate {
    CLC 
    LDA $tileQueryResult
    BNE loc_0098B0
    RTS 

  loc_0098B0:
    LDA $0A
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
    LDA $extendedFlags, X ; BIT #$0001 extendedFlags: defer VRAM DMA until staging ready
    BIT #$0001
    BNE loc_00990E
    LDA $7F0C07
    BEQ loc_0098D1
    LDA $0A
    DEC 
    DEC 
    STA $00
    PLA 
    PLA 
    RTL 

  loc_0098D1:
    LDA $0A
    DEC 
    DEC 
    STA $00
    LDA [$0A]
    INC $0A
    INC $0A
    STA $adhocVramDma
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $7F0C05
    LDA [$0A]
    INC $0A
    INC $0A
    STA $7F0C07
    LDA [$0A]
    INC $0A
    INC $0A
    STA $7F0C09
    LDA $extendedFlags, X
    ORA #$0001            ; ORA #$0001: flag adhoc VRAM DMA pending on extendedFlags
    STA $extendedFlags, X
    PLA 
    PLA 
    RTL 

  loc_00990E:
    LDY #$0003
    LDA [$0A], Y
    CMP $7F0C07
    BNE loc_00991C
    PLA 
    PLA 
    RTL 

  loc_00991C:
    LDA $extendedFlags, X
    AND #$FFFE
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
    LDA [$0A]
    INC $0A
    INC $0A
    PHA 
    LDA [$0A]
    INC $0A
    AND #$00FF
    SEP #$20
    STA $0405
    REP #$20
    LDA [$0A]
    INC $0A
    AND #$00FF
    ASL 
    CLC 
    ADC $01, S            ; Palette copy: source index ×2 into CGRAM staging buffer
    TAX 
    PLA 
    LDA [$0A]
    INC $0A
    AND #$00FF
    ASL 
    CLC 
    ADC #$0A00
    TAY 
    SEP #$20
    LDA #$7F
    STA $0404
    REP #$20
    LDA [$0A]
    INC $0A
    AND #$00FF
    ASL 
    DEC 
    JSR $0402
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
    LDA [$0A]
    INC $0A
    INC $0A
    STA $003E
    LDA [$0A]
    INC $0A
    AND #$00FF
    SEP #$20
    STA $0040
    REP #$20
    LDA [$0A]
    INC $0A
    INC $0A
    STA $007A
    LDA [$0A]
    INC $0A
    AND #$00FF
    LDA #$0000
    TCD 
    LDA [$3E]
    STA $78
    INC $3E
    INC $3E
    JSL $@QuintetLzDecompress ; QuintetLzDecompress then clear actor render list
    JSL $@sprite_composition.ClearActorRenderList
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
    LDA [$0A]
    INC $0A
    INC $0A
    STA $animScratch, X
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $animScratch+2, X
    LDA $0A
    STA $02, S
    RTI 
}
---------------------------------------------

; COP #5D wall-occlusion branch taking one &Code operand. Converts the actor pixel position to tile coordinates, samples collisionLayer via CalcTileMapOffset, and checks layer-aware visibility. If the actor is visible (not behind a blocking tile), the script jumps to the branch target; if occluded, it skips the operand and continues. Used by Eyesore, diamond-mine enemies, and similar actors that should only activate when unobstructed.

BranchIfBehindWall {
    TYX 
    LDA $14
    LSR 
    LSR 
    LSR 
    LSR 
    STA $0018
    LDA $16
    LSR 
    LSR 
    LSR 
    LSR 
    STA $001C
    PHD 
    LDA #$0000
    TCD 
    JSL $@tile_collision_physics.CalcTileMapOffset
    CPY #$4000
    BCS loc_009B37
    LDA $000F, X
    AND #$0010
    BEQ loc_009B1C
    LDA [$80], Y
    AND #$000F
    BEQ loc_009B2D
    BRA loc_009B2D

  loc_009B1C:
    LDA [$80], Y
    BIT #$00F0
    BNE loc_009B37
    AND #$000F
    BEQ loc_009B2D
    CMP #$000E
    BNE loc_009B37

  loc_009B2D:
    PLD 
    LDA $0A
    CLC 
    ADC #$0002
    STA $02, S
    RTI 

  loc_009B37:
    PLD 
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
    LDA $14
    LSR 
    LSR 
    LSR 
    LSR 
    STA $0018
    LDA $16
    LSR 
    LSR 
    LSR 
    LSR 
    STA $001C
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0000
    PHD 
    LDA #$0000
    TCD 
    JSL $@tile_collision_physics.CalcTileMapOffset
    CPY #$4000
    BCS loc_009B7F
    LDA [$80], Y
    AND #$000F
    CMP $00
    BEQ loc_009B7F
    PLD 
    LDA $0A
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
    CMP $cameraOffsetX
    BCC loc_009DE1
    CMP $cameraBoundsX
    BCS loc_009DE1
    LDA $16
    BMI loc_009DE1
    CMP $cameraOffsetY
    BCC loc_009DE1
    CMP $cameraBoundsY
    BCS loc_009DE1
    LDA $0A
    INC 
    INC 
    STA $02, S
    RTI 

  loc_009DE1:
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #69 with one word operand (max frame count). Compares against global frame counter $00E4; yields RTL when the counter has reached or exceeded the limit, otherwise RTI and continues.

HaltIfMaxFrames {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    CMP $00E4
    BCC loc_009E01
    LDA $0A
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