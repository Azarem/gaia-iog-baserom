; Scene initialization script interpreter and graphics loading pipeline (164795–168078, Bank 02).
; 
; This is the scene setup engine — when the game transitions to a new area (map, dungeon room, cutscene backdrop, etc.), the scene script system reads byte-coded commands from scene data and executes them to configure the PPU display mode, load BG tile graphics, transfer tilemaps, set up map geometry, load sprite tiles, and transfer SPC music data.
; 
; === ARCHITECTURE ===
; 
; The system centers on a command interpreter (SceneScriptMain) that reads one-byte opcodes from a scene script stream, dispatches them through a 24-entry jump table (scene_script_jump_table), and loops until opcode $00 (end-of-scene) is reached. SceneScriptNoMusic is a variant that filters out music load commands ($11) by skipping their operand bytes.
; 
; Scene script data is structured as: [scene_id:u16, command_stream...] entries. FindCurrentScene scans the table for a matching scene ID, then the interpreter processes commands sequentially using ReadScriptByte + Y-register stream position.
; 
; === COMMAND SET (scene_script_jump_table, 24 entries) ===
; 
; | Opcode | Handler | Description |
; |--------|---------|-------------|
; | $02 | SceneCmd_ConfigDisplay | Configure PPU display mode from table_018000 |
; | $03 | SceneCmd_LoadBgTiles | Load BG tile graphics (2bpp/4bpp) with decompression |
; | $04 | SceneCmd_LoadTilemap | Load single-layer tilemap data to WRAM |
; | $05 | SceneCmd_LoadDualTilemap | Load dual-layer tilemaps with cache and attributes |
; | $06 | SceneCmd_FullGraphics | Full scene graphics: tiles + tilemaps + map geometry |
; | $0E | SceneCmd_Skip3 | Skip 3 bytes in script stream |
; | $10 | SceneCmd_LoadSpriteTiles | Load sprite tile graphics |
; | $11 | SpcMusicLoadCmd | Transfer SPC music data via APU handshake |
; | $13 | SceneCmd_ConditionalLoad | Conditional execution based on game flag |
; | $14 | SceneCmd_Nop | No operation |
; | $15 | SkipScriptCommands | Skip remaining commands in current scene block |
; | $17 | SceneCmd_LoadCharTiles | Load character/object tiles with flexible VRAM targeting |
; 
; Opcodes $00-$01, $07-$0D, $0F, $12, $16 all map to code_02845C (RTS, no-op).
; 
; === GRAPHICS PIPELINE ===
; 
; Scene commands use a shared pipeline for loading compressed tile data:
; 1. ReadScriptByte reads tile parameters (VRAM offset, size, flags)
; 2. LoadScriptPointer reads a 3-byte ROM pointer from the script stream
; 3. CheckSourceCacheHit compares against cached source addresses to skip redundant loads
; 4. If cache miss: QuintetLzDecompress decompresses to staging buffer ($7E:7000)
; 5. DMA transfer via DmaTileStripToVram or DmaRomToWram sends data to VRAM or WRAM
; 6. SaveVramToRingBuffer backs up VRAM contents for fast cache-hit restoration
; 
; Three tile data formats:
; - Standard 2bpp/4bpp tiles (SceneCmd_LoadBgTiles mode 0)
; - Full 4bpp page load (Load4bppPage, mode 3)
; - Priority-interleaved tiles (DeinterleavePlanarTiles → code_0285F3, used when layerPriorityFlag bit $0800 is set)
; 
; === GRAPHICS CACHE SYSTEM ===
; 
; A 4-entry ring buffer cache (GraphicsCacheLookup/GraphicsCacheStore) tracks recently-loaded tile source addresses at $0084-$008F (3 bytes each: addr_lo, addr_hi, bank). On cache hit, RestoreCachedVram DMA-copies the previously-saved VRAM data from a WRAM ring buffer (4 × $2000 byte slots at $7F:4000-$7F:DFFF) back to VRAM — avoiding the expensive decompression step entirely.
; 
; SaveVramToRingBuffer reads current VRAM back to WRAM after each load, rotating through ring buffer slots via ComputeRingBufferAddr. For tile data exceeding $2000 bytes, two consecutive ring buffer slots are used.
; 
; === MAP GEOMETRY ===
; 
; SceneCmd_FullGraphics handles complete scene setup including map dimensions:
; - Reads width ($00/$01) and height ($02/$03) from script data
; - StoreMapAndDecompress sets map row stride, computes total map byte count via SignedMultiply, and decompresses tilemap data to the layer's tilemap base address
; - WriteMapBounds stores computed dimensions to mapBoundsX/mapBoundsY for the camera system
; - Dual-layer support: bit 1 of flags loads layer 0 (primary tilemap at $A000), bit 2 loads layer 1 (overlay at $C000)
; 
; === TILEMAP ATTRIBUTE SYSTEM ===
; 
; RebuildTilemapAttrs processes loaded tilemap data to extract and rebuild SNES-format attribute bytes (palette, priority, flip). Reads 4 consecutive tilemap entries, extracts bit 1 (palette high bit) from each, packs them into a single attribute byte using ROL/ASL bit manipulation, and stores via indirect write.
; 
; BuildAttributeTable creates a lookup table mapping metatile indices to their attribute bytes, referenced during deinterleaved tile rendering.
; 
; === PPU DISPLAY CONFIGURATION ===
; 
; SceneCmd_ConfigDisplay reads a table_018000 index and configures 10 PPU-related fields: TM/TS (main/sub screen designation), TMW/TSW (window masks), CGWSEL/CGADSUB (color math), layerPriorityFlag, scrollModeFlags, BGMODE, and BG tilemap addresses (BG1SC/BG2SC). The layerPriorityFlag bit 7 swaps BG1/BG2 tilemap base address assignment between $10xx and $18xx.
; 
; === SPC MUSIC LOADING ===
; 
; SpcMusicLoadCmd implements the full SPC700 IPL transfer protocol: Wait frames → optional stop command ($F2) → ready signal ($F0) → handshake poll → start command ($FF) → wait → SpcBlockTransfer for bulk data → play command. The musicRoomGroup field gates loading to prevent redundant transfers when re-entering the same music region.
; 
; === SCRIPT POINTER ADDRESS MAPPING ===
; 
; LoadScriptPointer reads 3-byte ROM pointers from the script stream and applies SNES address space mapping: bank bytes $00-$6F are offset to $80-$EF (LoROM → HiROM equivalent), banks $70-$9F use an additional $20 offset with bit 15 clearing on the address word. This translates script-embedded compact pointers to the full 24-bit addresses needed for DMA and indirect access.
---------------------------------------------

?BANK 02

?INCLUDE 'cop_handlers_script'
?INCLUDE 'hardware_math'
?INCLUDE 'QuintetLzDecompress'
?INCLUDE 'spc_transfer'
?INCLUDE 'system_init'
?INCLUDE 'table_018000'
?INCLUDE 'vblank_joypad'

!sceneCurrent                   0644
!mapBoundsX                     0692
!mapRowStrideL0                 0693
!effectBoundsX                  0694
!mapRowStrideL1                 0695
!mapBoundsY                     0696
!effectBoundsY                  0698
!mapTilemapBaseA                069E
!layerPriorityFlag              06EE
!scrollModeFlags                06EF
!musicParentActor               06F2
!musicRoomGroup                 06F6
!S_metatileMapLayer             2000
!BGMODE                         2105
!BG1SC                          2107
!BG2SC                          2108
!VMAIN                          2115
!VMADDL                         2116
!TM                             212C
!TS                             212D
!TMW                            212E
!TSW                            212F
!CGWSEL                         2130
!CGADSUB                        2131
!VMDATALREAD                    2139
!APUIO0                         2140
!WMADDL                         2181
!WMADDH                         2183
!S_metatileEffectLayer          2800
!MDMAEN                         420B
!DMAP0                          4300
!BBAD0                          4301
!A1T0L                          4302
!A1B0                           4304
!DAS0L                          4305
!S_tileStagingBuffer            7000
!animScratch                    7F0000
!cgramPalette                   7F0A00
!S_mapLayerTilemap              A000

---------------------------------------------

; Main scene script interpreter. Saves processor state, calls FindCurrentScene to locate the current scene's command block, then enters a dispatch loop: ReadScriptByte → opcode $00 ends the scene (ReloadMapData unless sceneCurrent == $F7, then return) → otherwise index scene_script_jump_table and dispatch via the RTS trick (PEA return-1, load handler address, DEC, PHA, RTS). Script pointer lives at [$3A],Y throughout.

SceneScriptMain {
    PHP                   ; Save processor state for scene script execution
    SEP #$20
    JSR $&FindCurrentScene ; Locate current scene entry in script table

  code_0283C1:
    JSR $&ReadScriptByte  ; Main command loop: read next scene command opcode
    CMP #$00
    BEQ loc_0283DB        ; Opcode $00 = end-of-scene marker
    PEA $&code_0283C1-1   ; Push return address for RTS dispatch trick (loop back to code_0283C1)
    REP #$20
    AND #$00FF            ; Zero-extend opcode byte to 16-bit for table index
    ASL 
    TAX 
    LDA $@scene_script_jump_table, X ; Read handler address from scene_script_jump_table
    DEC                   ; DEC+PHA+RTS dispatch: decrement handler address, push, RTS jumps to it
    PHA 
    SEP #$20
    RTS 

  loc_0283DB:
    LDA $sceneCurrent     ; Check for scene $F7 (special case — skip map reload)
    CMP #$F7
    BEQ loc_0283E5
    JSR $&ReloadMapData   ; Reload map data for normal scene transitions

  loc_0283E5:
    PLP 
    RTL 
}

---------------------------------------------
; Variant of SceneScriptMain used when reloading scene graphics without restarting music. Same dispatch loop, but after jump-table lookup compares the handler address against SpcMusicLoadCmd — on match, skips 5 operand bytes (INY ×5) instead of executing. Does not call ReloadMapData on scene end; simply restores state and returns.

SceneScriptNoMusic {
    PHP                   ; Music-filtered variant — skips SpcMusicLoadCmd during scene load
    SEP #$20
    JSR $&FindCurrentScene

  code_0283ED:
    JSR $&ReadScriptByte  ; Read next command opcode (same loop structure as SceneScriptMain)
    CMP #$00
    BEQ loc_028414
    PEA $&code_0283ED-1
    REP #$20
    AND #$00FF
    ASL 
    TAX 
    LDA $@scene_script_jump_table, X ; Read handler address from jump table
    CMP #$&SpcMusicLoadCmd ; Compare handler against SpcMusicLoadCmd address to filter music
    BEQ loc_02840C
    DEC 
    PHA 
    SEP #$20
    RTS 

  loc_02840C:
    INY                   ; Skip 5 bytes of music command operands (INY ×5)
    INY 
    INY 
    INY 
    INY 
    SEP #$20
    RTS 

  loc_028414:
    PLP 
    RTL 
}

---------------------------------------------
; 24-entry word jump table mapping scene opcode indices ($00–$17) to handler addresses. Unused slots ($00–$01, $07–$0D, $0F, $12, $16) point to code_02845C (RTS no-op). Active handlers: $02=ConfigDisplay, $03=LoadBgTiles, $04=LoadTilemap, $05=LoadDualTilemap, $06=FullGraphics, $0E=Skip3, $10=LoadSpriteTiles, $11=SpcMusicLoad, $13=ConditionalLoad, $14=Nop, $15=SkipScriptCommands, $17=LoadCharTiles.

scene_script_jump_table [
  &code_02845C   ;00
  &code_02845C   ;01
  &SceneCmd_ConfigDisplay   ;02
  &SceneCmd_LoadBgTiles   ;03
  &SceneCmd_LoadTilemap   ;04
  &SceneCmd_LoadDualTilemap   ;05
  &SceneCmd_FullGraphics   ;06
  &code_02845C   ;07
  &code_02845C   ;08
  &code_02845C   ;09
  &code_02845C   ;0A
  &code_02845C   ;0B
  &code_02845C   ;0C
  &code_02845C   ;0D
  &SceneCmd_Skip3   ;0E
  &code_02845C   ;0F
  &SceneCmd_LoadSpriteTiles   ;10
  &SpcMusicLoadCmd   ;11
  &code_02845C   ;12
  &SceneCmd_ConditionalLoad   ;13
  &SceneCmd_Nop   ;14
  &SkipScriptCommands   ;15
  &code_02845C   ;16
  &SceneCmd_LoadCharTiles   ;17
]

---------------------------------------------
; Conditional script execution gate. Reads one byte (flag index) from the script stream and calls TestFlagRaw. If the flag is set (carry set), jumps to SkipScriptCommands to bypass the remaining commands in the block. If clear, advances Y past the flag operand and returns so subsequent commands execute normally.

SceneCmd_ConditionalLoad {
    PHP 
    REP #$20
    JSR $&ReadScriptByte  ; Read game flag index from script stream
    PHY 
    JSL $@cop_handlers_script.TestFlagRaw ; Test flag via TestFlagRaw — carry set if flag is active
    PLY 
    BCC loc_028458
    PLP                   ; Flag active: skip remaining scene commands (conditional block)
    JMP $&SkipScriptCommands

  loc_028458:
    INY                   ; Flag inactive: advance past operand byte and continue normally
    PLP 
    RTS 
}

---------------------------------------------
; No-operation scene command — advances the script pointer by one byte (INY) and returns. Used as a placeholder or padding byte in command streams.

SceneCmd_Nop {
    INY 
}

---------------------------------------------
; Default scene-command handler: single RTS instruction. Jump-table target for all unimplemented opcode slots; consumes no operands.

code_02845C {
    RTS 
}

---------------------------------------------
; Load BG tile graphics from ROM to VRAM. Reads four script operands into $0664 (VRAM start, word), $0666 (VRAM end, word), and $0668 (flags/mode). Mode byte selects one of four paths: 0 = standard 2bpp strip (+$20 to flags, cache slot $066C/$066F), 1 = double strip (+$40, slot $0672/$0675), 2 = triple strip (+$60), 3 = full 4bpp page via Load4bppPage. After mode setup, CheckSourceCacheHit — cache hit returns early. On miss: optionally DeinterleavePlanarTiles when layerPriorityFlag $0800 is set and slot $066C; else GraphicsCacheLookup → RestoreCachedVram on hit. Otherwise decompresses via QuintetLZ to $7000, DMAs through SceneDmaTileShim, and saves to the VRAM ring buffer.

SceneCmd_LoadBgTiles {
    PHP 
    REP #$20
    JSR $&ReadScriptByte  ; Read VRAM tile start offset (×256 via XBA, ×2 via ASL)
    XBA 
    ASL 
    STA $0664
    JSR $&ReadScriptByte  ; Read VRAM tile end offset (same scaling)
    XBA 
    ASL 
    STA $0666
    JSR $&ReadScriptByte  ; Read tile flags byte to $0668
    STA $0668
    LDX #$003E            ; Load pointer register X=$003E for LoadScriptPointer destination
    JSR $&LoadScriptPointer
    JSR $&ReadScriptByte  ; Read tile format/mode byte (0=standard, 1=double, 2=triple, 3=4bpp page)
    CMP #$0000
    BEQ loc_02848D        ; Mode 0: standard 2bpp tile strip
    DEC 
    BEQ loc_0284BC        ; Mode 1: double-size tile strip
    DEC 
    BEQ loc_0284E7        ; Mode 2: triple-size tile strip
    DEC 
    BEQ loc_0284F3        ; Mode 3: full 4bpp page load

  loc_02848D:
    LDA $0668             ; Mode 0 entry: add $20 to flags for VRAM page offset
    BIT #$0010            ; Bit 4 of flags: determines which cache slot to use ($066C or $066F)
    BNE loc_0284B0
    CLC 
    ADC #$0020
    STA $0668
    LDX #$066C
    LDA $0666             ; Check if tile data exceeds $2000 bytes
    SEC 
    SBC $0664
    CMP #$2001
    BMI loc_0284FC
    STZ $0670             ; Large tile set — clear overflow tracking at $0670
    BRA loc_0284FC

  loc_0284B0:
    CLC 
    ADC #$0020
    STA $0668
    LDX #$066F
    BRA loc_0284FC

  loc_0284BC:
    LDA $0668             ; Mode 1 entry: add $40 to flags for double-page VRAM offset
    BIT #$0010
    BNE loc_0284DB
    CLC 
    ADC #$0040
    STA $0668
    BIT #$0028
    BEQ loc_0284D3
    STZ $0676

  loc_0284D3:
    STZ $0673
    LDX #$0672
    BRA loc_0284FC

  loc_0284DB:
    CLC 
    ADC #$0040
    STA $0668
    LDX #$0675
    BRA loc_0284FC

  loc_0284E7:
    LDA $0668             ; Mode 2 entry: add $60 to flags for triple-page offset
    CLC 
    ADC #$0060
    STA $0668
    BRA loc_028503

  loc_0284F3:
    LDA $0668             ; Mode 3 entry: store flags, jump to Load4bppPage
    STA $0668
    JMP $&Load4bppPage

  loc_0284FC:
    JSR $&CheckSourceCacheHit ; Check source cache — carry clear means cache hit (no load needed)
    BCS loc_028503
    PLP 
    RTS 

  loc_028503:
    LDA [$3E]             ; Read compressed data size/pointer from source
    INC $3E
    INC $3E
    STA $78
    CMP #$0000            ; Zero compressed size = no tile data (skip to interleave check)
    BEQ CheckInterleavedFlag
    CPX #$066C            ; Check if this is the primary cache slot ($066C)
    BNE loc_028520
    LDA $layerPriorityFlag ; Check layerPriorityFlag bit $0800 for priority deinterleaving
    BIT #$0800
    BEQ loc_028520
    JMP $&DeinterleavePlanarTiles ; Priority mode active — jump to DeinterleavePlanarTiles

  loc_028520:
    JSR $&GraphicsCacheLookup ; Look up source in graphics cache for potential VRAM restore shortcut
    BCC loc_02852A
    JSR $&RestoreCachedVram ; Cache hit — restore tile data from WRAM ring buffer, skip decompression
    PLP 
    RTS 

  loc_02852A:
    JSR $&GraphicsCacheStore ; Cache miss — store new entry to graphics cache
    LDA $78
    CMP #$2001
    BCC loc_028537
    STZ $067F

  loc_028537:
    LDX #$7000            ; Decompress tile data via QuintetLZ to staging buffer $7000
    STX $7A
    JSL $@QuintetLzDecompress
    LDX #$7000
    STX $3E
    LDA #$007E            ; Set source bank to $7E (decompressed data in WRAM)
    STA $40
    JSR $&SceneDmaTileShim ; DMA tile data from staging buffer to VRAM
    JSR $&SaveVramToRingBuffer ; Back up VRAM contents to ring buffer for future cache hits
    PLP 
    RTS 
}

---------------------------------------------
; Entry wrapper for DmaTileStripToVram. Saves processor state and BRA branches into DmaTileStripToVram. CheckInterleavedFlag is an alternate entry in the same block: if layerPriorityFlag bit $0800 is set, jumps to code_0285F3 for priority deinterleaving instead of a direct DMA.

SceneDmaTileShim {
    PHP                   ; Entry shim: save state, branch to DMA routine
    BRA DmaTileStripToVram

; Alternate entry within SceneDmaTileShim. Tests layerPriorityFlag bit $0800 — if set, jumps to code_0285F3 for planar-to-priority tile conversion; if clear, falls through to DmaTileStripToVram for a normal WRAM→VRAM tile strip transfer.

  CheckInterleavedFlag:
    LDA $layerPriorityFlag ; Check layerPriorityFlag $0800 for interleaved tile mode
    BIT #$0800
    BEQ DmaTileStripToVram
    JMP $&code_0285F3     ; Priority interleave active — jump to code_0285F3 for deinterleaving

; DMA a tile data strip from WRAM ($3E+$0664, bank $40) to VRAM. Sets VMADDL from $0668 (XBA for page alignment), transfer size = $0666 − $0664. Configures channel 0: mode $01 (two-register word write), B-bus $18 (VMDATAL), triggers MDMAEN.

  DmaTileStripToVram:
    LDA $0668             ; Compute VRAM destination from tile page ($0668 XBA = ×256 word address)
    XBA 
    STA $VMADDL
    LDA $3E
    CLC 
    ADC $0664             ; Compute DMA source = base pointer + start offset
    STA $A1T0L
    LDA $0666             ; Compute transfer size = end offset − start offset
    SEC 
    SBC $0664
    STA $DAS0L
    SEP #$20
    LDA #$01              ; DMA mode $01: two-register word write to VMDATAL/VMDATAH
    STA $DMAP0
    LDA #$18
    STA $BBAD0
    LDA $40
    STA $A1B0
    LDA #$01              ; Trigger DMA channel 0
    STA $MDMAEN
    PLP 
    RTS 
}

---------------------------------------------
; Load a full 4bpp tile page ($4000 bytes) to VRAM starting at $2000. Reads optional compressed pointer from [$3E]; if non-zero, decompresses via QuintetLZ to $7000 and uses that as source. DMA uses mode $00 (byte write), B-bus $19 (VMDATAH), size $4000 — high-byte-first 4bpp VRAM layout.

Load4bppPage {
    LDA [$3E]             ; Read compressed data pointer from source stream
    STA $78
    INC $3E
    INC $3E
    CMP #$0000            ; Null pointer = uncompressed data (skip decompression)
    BEQ loc_0285B2
    LDX #$7000            ; Decompress compressed tile data to staging buffer $7000
    STX $7A
    JSL $@QuintetLzDecompress
    LDX #$7000
    STX $3E
    LDA #$007E
    STA $40

  loc_0285B2:
    SEP #$20
    LDX #$2000            ; VRAM destination = $2000 (start of 4bpp tile region)
    STX $VMADDL
    LDA #$00              ; DMA mode $00: single-register byte write to VMDATAH ($19)
    STA $DMAP0
    LDA #$19
    STA $BBAD0
    LDX $3E
    STX $A1T0L
    LDA $40
    STA $A1B0
    LDX #$4000            ; Transfer size = $4000 (16KB = full 4bpp tile page)
    STX $DAS0L
    LDA #$01
    STA $MDMAEN
    PLP 
    RTS 
}

---------------------------------------------
; Initialize priority-deinterleave path: clears cache invalidation slots $0670/$067F/$0682/$0679/$067C, then decompresses tile data via QuintetLZ to $7000. Falls through into code_0285F3 for the actual bitplane interleaving pass.

DeinterleavePlanarTiles {
    STZ $0670             ; Clear all deinterleave tracking variables ($0670/$067F/$0682/$0679/$067C)
    STZ $067F
    STZ $0682
    STZ $0679
    STZ $067C
    LDX #$7000            ; Decompress tile data to staging buffer $7000
    STX $7A
    JSL $@QuintetLzDecompress
}

---------------------------------------------
; Deinterleave planar SNES 4bpp tiles into priority-split VRAM format. Sets data bank $7E, calls BuildAttributeTable, then processes $2000 bytes from $7000 in 8-byte chunks (one tile row per inner loop). For each of 8 pixel rows, ROL-cascades four bitplanes plus a per-pixel attribute bit from the lookup table into interleaved bytes at $7E:A000. Finishes with a $4000-byte DMA from $7E:A000 to VRAM $0000 via VMDATAH (mode $00, VMAIN=$80).

code_0285F3 {
    PHY                   ; Save Y and switch bank to $7E for direct WRAM access
    PHB 
    SEP #$20
    LDA #$7E
    PHA 
    PLB 
    LDX #$0000
    STZ $0E
    LDY #$A000            ; Output buffer at $A000 ($5E pointer)
    STY $5E
    JSR $&BuildAttributeTable ; Build metatile attribute lookup table before deinterleaving

  loc_028608:
    LDA #$07              ; Outer loop: process 8 rows per tile (7 down to 0)
    STA $12
    LDA ($3E)             ; Read attribute byte for this tile from the attribute table
    STA $10
    INC $3E
    BNE loc_028616
    INC $3F

  loc_028616:
    LDA $S_tileStagingBuffer, X ; Load 4 bitplane bytes from tile data: planes 0, 1, 2, 3
    STA $00
    LDA $7001, X
    STA $02
    LDA $7010, X
    STA $04
    LDA $7011, X
    STA $06
    LDY #$0007

  loc_02862D:
    LDA #$00              ; Inner loop: merge 4 bitplanes into priority-interleaved bytes via ROL cascade
    ROL $06
    ROL 
    ROL $04
    ROL 
    ROL $02
    ROL 
    ROL $00
    ROL 
    ORA $10               ; OR with attribute byte to inject palette/priority bits
    STA ($5E)             ; Write merged byte to output buffer
    INC $5E
    BNE loc_028645
    INC $5F

  loc_028645:
    DEY 
    BPL loc_02862D
    INX 
    INX 
    DEC $12
    BPL loc_028616
    REP #$20              ; Advance X by $10 (skip to next tile in 2bpp-interleaved layout)
    TXA 
    CLC 
    ADC #$0010
    TAX 
    SEP #$20
    CPX #$2000            ; Check if all $2000 bytes of tile data processed
    BCC loc_028608
    PLB 
    LDX #$0000            ; DMA $4000 bytes from $7E:A000 to VRAM $0000
    STX $VMADDL
    LDA #$80
    STA $VMAIN
    LDA #$00
    STA $DMAP0
    LDA #$19
    STA $BBAD0
    LDX #$A000
    STX $A1T0L
    LDA #$7E
    STA $A1B0
    LDX #$4000
    STX $DAS0L
    LDA #$01
    STA $MDMAEN
    PLY 
    PLP 
    RTS 
}

---------------------------------------------
; Build a 256-byte metatile attribute lookup at $7E:2800. Zeroes $100 bytes at S_metatileEffectLayer, then walks $800 bytes of S_metatileMapLayer map-layer data in 2-byte steps: indexes by the low metatile byte, extracts the 3-bit palette field from the high byte (ASL×2, AND #$70), and stores into the attribute slot.

BuildAttributeTable {
    PHP 
    REP #$20
    LDA #$0000            ; Zero the 256-byte attribute table at S_metatileEffectLayer ($2800)
    TAY 

  loc_028693:
    STA $S_metatileEffectLayer, Y
    INY 
    INY 
    CPY #$0100
    BCC loc_028693
    LDY #$2800            ; Set attribute table write pointer to $2800
    STY $3E
    LDY #$0000
    SEP #$20

  loc_0286A7:
    LDA $S_metatileMapLayer, Y ; Read metatile index from map layer data
    STA $3E
    LDA $2001, Y          ; Read high byte of tilemap entry ($2001+Y) for palette field
    ASL                   ; Extract palette bits: ASL ×2, AND #$70 → isolate 3-bit palette
    ASL 
    AND #$70
    STA ($3E)             ; Store palette attribute at the metatile's slot in the attribute table
    INY 
    INY 
    CPY #$0800
    BCC loc_0286A7
    LDY #$2800
    STY $3E
    PLP 
    RTS 
}

---------------------------------------------
; Load tilemap data from ROM to WRAM. Reads three script operands (start, end, WRAM destination offset), each doubled (ASL) into $0664/$0666/$0668 for word addressing. Loads source pointer via LoadScriptPointer, then DmaRomToWram into $7F:0A00 + offset. Special case: destination offset $0020 (palette tilemap) copies one palette entry from $7F0A20 into cgramPalette after the DMA.

SceneCmd_LoadTilemap {
    PHP 
    REP #$20
    JSR $&ReadScriptByte  ; Read start offset from script (ASL for word addressing)
    ASL 
    STA $0664
    JSR $&ReadScriptByte  ; Read end offset (ASL)
    ASL 
    STA $0666
    JSR $&ReadScriptByte  ; Read WRAM destination page (ASL)
    ASL 
    STA $0668
    CMP #$0020            ; Special case: destination $0020 = palette tilemap
    BEQ loc_0286F5
    LDX #$003E            ; Standard path: load pointer and DMA tilemap to WRAM $7F:0A00
    JSR $&LoadScriptPointer
    LDX #$0A00
    STX $42
    LDA #$007F
    STA $44
    JSR $&DmaRomToWram
    PLP 
    RTS 

  loc_0286F5:
    LDX #$003E            ; Palette path: same DMA, then copy palette data from $7F0A20 to cgramPalette
    JSR $&LoadScriptPointer
    LDX #$0A00
    STX $42
    LDA #$007F
    STA $44
    JSR $&DmaRomToWram
    LDA $7F0A20
    STA $cgramPalette
    PLP 
    RTS 
}

---------------------------------------------
; Load tilemaps for both BG layers from shared compressed source data. Reads three size operands (XBA + LSR×2 for >>2 scaling) plus flags byte $066A (bit 0 = layer 0, bit 1 = layer 1). Each active layer is checked against its source cache slot ($0678/$067B); cache hits clear that layer bit. If any layers remain: decompress once to $7000, then for each active layer DMA to $7E:2000 (layer 0) or $7E:2800 (layer 1) and call RebuildTilemapAttrs.

SceneCmd_LoadDualTilemap {
    PHP 
    REP #$20
    JSR $&ReadScriptByte  ; Read 3 tile parameters with >>2 scaling (XBA+LSR+LSR)
    XBA 
    LSR 
    LSR 
    STA $0664
    JSR $&ReadScriptByte
    XBA 
    LSR 
    LSR 
    STA $0666
    JSR $&ReadScriptByte
    XBA 
    LSR 
    LSR 
    STA $0668
    JSR $&ReadScriptByte  ; Read flags byte — bit 0 = layer 0, bit 1 = layer 1
    STA $066A
    LDX #$003E
    JSR $&LoadScriptPointer
    LDA #$0001            ; Check layer 0 bit against source cache slot $0678
    AND $066A
    BEQ loc_028752
    LDX #$0678
    JSR $&CheckSourceCacheHit
    BCS loc_028752
    LDA #$0001
    TRB $066A

  loc_028752:
    LDA #$0002            ; Check layer 1 bit against source cache slot $067B
    AND $066A
    BEQ loc_028768
    LDX #$067B
    JSR $&CheckSourceCacheHit
    BCS loc_028768
    LDA #$0002
    TRB $066A

  loc_028768:
    LDA $066A             ; Check if any layers still need loading after cache checks
    BEQ loc_0287BA
    LDA [$3E]             ; Read compressed data pointer and decompress via QuintetLZ
    STA $78
    INC $3E
    INC $3E
    BEQ loc_02878A
    LDX #$7000
    STX $7A
    JSL $@QuintetLzDecompress
    LDX #$7000
    STX $3E
    LDA #$007E
    STA $40

  loc_02878A:
    LSR $066A             ; Shift flag bits right to test layer 0 (bit 0 → carry)
    BCC loc_0287A2
    LDX #$2000            ; Layer 0: DMA tilemap to WRAM $2000, rebuild tilemap attributes
    STX $42
    LDA #$007E
    STA $44
    JSR $&DmaRomToWram
    LDX #$0000
    JSR $&RebuildTilemapAttrs

  loc_0287A2:
    LSR $066A             ; Shift to test layer 1 (bit 1 → carry)
    BCC loc_0287BA
    LDX #$2800            ; Layer 1: DMA tilemap to WRAM $2800, rebuild tilemap attributes
    STX $42
    LDA #$007E
    STA $44
    JSR $&DmaRomToWram
    LDX #$0002
    JSR $&RebuildTilemapAttrs

  loc_0287BA:
    PLP 
    RTS 
}

---------------------------------------------
; Complete scene graphics load — the most complex scene command. Reads flags $066A and source pointer; optionally clears layer bits on source cache hits ($067E layer 0, $0681 layer 1). Reads map width/height pairs into $00/$01 (X) and $02/$03 (Y). If no layers active after cache filtering, returns early. With active layers but zero geometry (compressed pointer $0000), HandleEmptyGeometry. With nonzero geometry: StoreMapAndDecompress per active layer; layer 1 also copies primary decompressed data from $A000 to $C000 and stores secondary map dimensions. If flags indicate no tilemap layers (AND #$7F == 0), DmaLowVramTileset loads tiles directly to low VRAM.

SceneCmd_FullGraphics {
    STZ $0664             ; Clear start offset accumulators
    STZ $0665
    JSR $&ReadScriptByte  ; Read combined flags byte ($066A)
    STA $066A
    LDX #$003E            ; Load script pointer for graphics data source
    JSR $&LoadScriptPointer
    LDA $066A
    AND #$7F              ; Mask off high bit: check if any layer flags are set
    BEQ loc_02880D
    LDA #$01              ; Check layer 0 flag (bit 0)
    AND $066A
    BEQ loc_0287F0
    LDA $scrollModeFlags  ; Check scroll mode flag bit 3 — direct mode skips cache
    BIT #$08
    BNE loc_028818
    LDX #$067E            ; Layer 0 source cache check (slot $067E)
    JSR $&CheckSourceCacheHit
    BCS loc_0287F0
    LDA #$01
    TRB $066A

  loc_0287F0:
    LDA #$02              ; Check layer 1 flag (bit 1)
    AND $066A
    BEQ loc_028804
    LDX #$0681            ; Layer 1 source cache check (slot $0681)
    JSR $&CheckSourceCacheHit
    BCS loc_028804
    LDA #$02
    TRB $066A

  loc_028804:
    LDA $066A             ; Recheck flags after cache culling — if none left, return
    AND #$7F
    BEQ loc_02883C
    BRA loc_028818

  loc_02880D:
    LDA $066A             ; No layer flags: check high bit ($80) for DMA-only mode
    BMI loc_028818
    STZ $067F             ; Clear VRAM cache references $067F/$0680 for fresh load
    STZ $0680

  loc_028818:
    REP #$20              ; Read map width bytes ($00/$01 from stream) via paired byte reads
    LDA [$3E]
    INC $3E
    AND #$00FF
    XBA 
    STA $00
    LDA [$3E]             ; Read map height bytes ($02/$03)
    INC $3E
    AND #$00FF
    XBA 
    STA $02
    SEP #$20
    LDA $066A             ; Check remaining layer flags to determine graphics path
    AND #$7F
    BNE loc_02883A
    JMP $&DmaLowVramTileset ; No layers but data present → DmaLowVramTileset (direct VRAM load)

  loc_02883A:
    BRA loc_02883D

  loc_02883C:
    RTS 

  loc_02883D:
    REP #$20              ; Main path: read compressed tilemap size
    LDA [$3E]
    STA $78
    STA $0666
    INC $3E
    INC $3E
    CMP #$0000            ; Zero size = empty geometry (handle without decompression)
    BEQ HandleEmptyGeometry
    SEP #$20
    LDA $066A             ; Check layer 0 bit to decide which StoreMapAndDecompress call
    BIT #$01
    BEQ loc_02888E
    LDX #$0000            ; Layer 0: decompress to primary tilemap base
    JSR $&StoreMapAndDecompress
    LDA $066A             ; Check layer 1 bit for secondary tilemap
    BIT #$02
    BEQ loc_028894
    LDX #$A000            ; Layer 1: set up source from decompressed layer 0 ($A000)
    STX $3E
    LDA #$7E
    STA $40
    LDX #$C000
    STX $42
    LDA #$7E
    STA $44
    JSR $&DmaRomToWram    ; DMA layer 0 data to layer 1 WRAM destination ($C000)
    LDA $01
    STA $mapRowStrideL1   ; Store layer 1 map row stride
    XBA 
    LDA $03
    STA $0699
    JSL $@hardware_math.SignedMultiply ; Compute layer 1 total byte count via SignedMultiply
    STA $069D
    BRA loc_028894

  loc_02888E:
    LDX #$0002            ; No layer 0: use layer 1 (X=2) directly
    JSR $&StoreMapAndDecompress

  loc_028894:
    RTS 
}

---------------------------------------------
; Store map parameters and decompress one layer's tilemap. X selects layer (0 = primary, 2 = secondary): stores row stride ($01) and column count ($03) to mapRowStrideL0+X / $0697+X, computes total byte count via SignedMultiply → $069B+X, then decompresses map data via QuintetLZ directly to mapTilemapBaseA+X. HandleEmptyGeometry is the alternate entry for zero-size compressed maps.

StoreMapAndDecompress {
    LDA $01               ; Store map row stride from data byte $01 to mapRowStrideL0+X
    STA $mapRowStrideL0, X
    XBA 
    LDA $03               ; Store column count from $03 to $0697+X
    STA $0697, X
    JSL $@hardware_math.SignedMultiply ; Compute total map byte count = stride × columns
    STA $069B, X
    REP #$20
    LDA $mapTilemapBaseA, X ; Load tilemap base address for this layer
    STA $7A
    JSL $@QuintetLzDecompress ; Decompress map data directly to tilemap base address
    SEP #$20
    RTS 

; Handle scenes with empty (uncompressed/zero-size) map geometry. Computes map byte count from $01×$03 via SignedMultiply into $0666/$0667. For each active layer flag: DMAs raw map data via WriteMapBounds/DmaRomToWram. Layer 0 → $7E:A000; layer 1 only → $7E:C000; both layers → layer 0 first, then copies primary to overlay at $C000 and stores effectBoundsX/Y from map dimensions.

  HandleEmptyGeometry:
    SEP #$20              ; Compute map byte count from dimensions without actual geometry data
    LDA $01
    XBA 
    LDA $03
    JSL $@hardware_math.SignedMultiply
    STZ $0666             ; Clear compressed size — no compressed data to transfer
    STA $0667
    LDA $066A             ; Check layer 0 flag for DMA destination routing
    BIT #$01
    BEQ loc_028904
    LDX #$A000            ; Layer 0: DMA destination at $A000 for primary tilemap
    STX $42
    LDA #$7E
    STA $44
    LDX #$0000
    JSR $&WriteMapBounds  ; Write map bounds for layer 0 (X=0)
    LDA $066A             ; Check layer 1 flag
    BIT #$02
    BEQ loc_028913
    LDX #$A000
    STX $3E
    LDA #$7E
    STA $40
    LDX #$C000
    STX $42
    LDA #$7E
    STA $44
    JSR $&DmaRomToWram    ; Layer 1 copy: DMA from $A000 to $C000 (duplicate primary as overlay)
    LDX $00               ; Store effect bounds from computed dimensions
    STX $effectBoundsX
    LDX $02
    STX $effectBoundsY
    BRA loc_028913

  loc_028904:
    LDX #$C000            ; No layer 0: route to layer 1 destination ($C000) directly
    STX $42
    LDA #$7E
    STA $44
    LDX #$0002
    JSR $&WriteMapBounds

  loc_028913:
    RTS 
}

---------------------------------------------
; Write map dimension bounds for one BG layer and transfer map data. Stores X bounds ($00) to mapBoundsX+X and Y bounds ($02) to mapBoundsY+X, then calls DmaRomToWram using current $0664/$0666/$0668 and destination in $42/$44. X selects layer (0 or 2).

WriteMapBounds {
    REP #$20
    LDA $00               ; Store X bounds to mapBoundsX+X for camera system
    STA $mapBoundsX, X
    LDA $02
    STA $mapBoundsY, X    ; Store Y bounds to mapBoundsY+X
    JSR $&DmaRomToWram    ; DMA the actual map data from ROM to WRAM
    SEP #$20
    RTS 
}

---------------------------------------------
; DMA tile data directly to low VRAM ($2000, $4000 bytes). Reads compressed pointer from [$3E]; if non-null, decompresses to $7E:A000 and DMAs from there; if null, DMAs from the raw ROM pointer. Uses VMAIN=$00 (sequential byte), mode $00, B-bus $18; restores VMAIN=$80 after transfer.

DmaLowVramTileset {
    REP #$20
    LDA [$3E]             ; Read compressed data pointer from source stream
    INC $3E
    INC $3E
    STA $78
    CMP #$0000            ; Null pointer = raw (uncompressed) source data
    BNE loc_028943
    SEP #$20
    LDX $3E               ; Raw path: use ROM pointer directly as DMA source
    STX $A1T0L
    LDA $40
    STA $A1B0
    BRA loc_028959

  loc_028943:
    SEP #$20
    LDX #$A000            ; Compressed path: decompress to $7E:A000, use as DMA source
    STX $7A
    JSL $@QuintetLzDecompress
    LDX #$A000
    STX $A1T0L
    LDA #$7E
    STA $A1B0

  loc_028959:
    STZ $VMAIN            ; VMAIN=$00: sequential byte access for low VRAM write
    LDX #$2000            ; VRAM destination = $2000
    STX $VMADDL
    LDA #$00
    STA $DMAP0
    LDA #$18
    STA $BBAD0
    LDX #$4000            ; Transfer size = $4000 bytes (full low-VRAM tileset)
    STX $DAS0L
    LDA #$01
    STA $MDMAEN
    LDA #$80
    STA $VMAIN            ; Restore VMAIN=$80 (word access mode)
    RTS 
}

---------------------------------------------
; Render palette-indexed metatile map data into a $4000-byte tile buffer at $7E:B000 for VRAM upload. Zeroes output in 8-byte chunks, caps visible rows at 4 (from $0693/$0697). Triple-nested loop walks map pages and expands each metatile index through S_metatileMapLayer into four 8×8 tile words with $80-byte row stride. DMAs $4000 bytes from $B000 to VRAM $0000 (VMAIN=$00, low-byte writes), then restores VMAIN=$80.

RenderPaletteTiles {
    PHY 
    PHB 
    LDA #$7E              ; Set data bank to $7E for WRAM tile buffer access
    PHA 
    PLB 
    LDX #$0000
    REP #$20

  loc_028988:
    LDA #$0000            ; Zero $4000 bytes of output buffer at $B000 (8 bytes per iteration)
    STA $B000, X
    STA $B002, X
    STA $B004, X
    STA $B006, X
    TXA 
    CLC 
    ADC #$0008
    TAX 
    CPX #$4000
    BCC loc_028988
    SEP #$20
    LDA $0693             ; Load map row stride as column limit ($18)
    STA $18
    LDA $0697             ; Load map page count, cap at 4 maximum ($1C)
    CMP #$05
    BCC loc_0289B2
    LDA #$04

  loc_0289B2:
    STA $1C
    LDA #$00
    STA $0E
    STA $10
    LDY #$0000
    TYX 
    STX $00

  loc_0289C0:
    REP #$20              ; Outer page loop: compute 256-byte page boundary for inner row limit
    TYA 
    CLC 
    ADC #$0100
    STA $14
    SEP #$20

  loc_0289CB:
    LDA #$0F              ; Row loop: 16 metatiles per row ($12 = $0F, decrements)
    STA $12

  loc_0289CF:
    REP #$20
    LDA $S_mapLayerTilemap, Y ; Read metatile index from map layer tilemap
    PHY 
    AND #$00FF
    ASL                   ; Multiply index by 8 (ASL ×3) for metatile definition table lookup
    ASL 
    ASL 
    TAY 
    SEP #$20
    LDA $S_metatileMapLayer, Y ; Read 4 tile definition bytes: top-left, top-right, bottom-left, bottom-right
    STA $B000, X          ; Write top-left tile byte to output buffer $B000+X
    LDA $2002, Y
    STA $B001, X
    LDA $2004, Y
    STA $B080, X          ; Write bottom-left to $B080+X (128-byte row stride in output)
    LDA $2006, Y
    STA $B081, X
    PLY 
    INY 
    INX 
    INX 
    DEC $12
    BPL loc_0289CF
    REP #$20
    TXA 
    CLC 
    ADC #$00E0            ; Advance output pointer by $E0 to skip to next tile row (accounting for 2-byte entries)
    TAX 
    SEP #$20
    CPY $14
    BCC loc_0289CB
    REP #$20
    LDA $00
    CLC 
    ADC #$0020
    STA $00
    TAX 
    SEP #$20
    LDA $0E
    INC 
    STA $0E
    CMP $18
    BCC loc_0289C0
    STZ $0E
    LDA $10
    INC 
    STA $10
    CMP $1C
    BCS loc_028A3C
    REP #$20
    AND #$00FF
    XBA 
    ASL 
    ASL 
    ASL 
    ASL 
    STA $00
    TAX 
    BRA loc_0289C0

  loc_028A3C:
    PLB 
    STZ $VMAIN            ; DMA $4000 bytes from $7E:B000 to VRAM $0000 via low-byte writes (VMAIN=$00)
    LDX #$0000
    STX $VMADDL
    LDX #$B000
    STX $A1T0L
    LDA #$7E
    STA $A1B0
    LDA #$00
    STA $DMAP0
    LDA #$18
    STA $BBAD0
    LDX #$4000
    STX $DAS0L
    LDA #$01
    STA $MDMAEN
    LDA #$80
    STA $VMAIN
    PLY 
    RTL 
}

---------------------------------------------
; Configure PPU display mode and engine scroll state from table_018000. Reads config index from script, loads a 10-byte entry, and applies: TM/TMW, TS/TSW, CGWSEL, CGADSUB, layer priority/size bitfield ($06F1, BG tilemap bases $06A2–$06A8 via ROR rotation), visible height ($06EC = $E0 or $100), layerPriorityFlag (bit 7 swaps BG1SC/BG2SC base assignment), BGMODE, scrollModeFlags (bit 3 clears $066E), sprite priority ($09ED bit 6), and invalidates tilemap cache slots when BG bases change.

SceneCmd_ConfigDisplay {
    JSR $&ReadScriptByte  ; Read configuration table index from script stream
    PHY 
    REP #$20
    AND #$00FF
    ASL                   ; Double index for word-sized table_018000 pointer entries
    TAX 
    LDA $@table_018000, X ; Read pointer from table_018000, convert to local offset
    SEC 
    SBC #$&table_018000
    TAX 
    SEP #$20
    LDA $@table_018000, X ; Apply entry bytes 0-1: TM (main screen layers) + TMW (window mask)
    STA $TM
    STA $TMW
    LDA $@table_018000+1, X ; Apply bytes 2-3: TS (sub screen) + TSW (window mask)
    STA $TS
    STA $TSW
    LDA $@table_018000+2, X ; Apply byte 4: CGWSEL (color math window selection)
    STA $CGWSEL
    LDA $@table_018000+3, X ; Apply byte 5: CGADSUB (color add/subtract config)
    STA $CGADSUB
    LDA $@table_018000+4, X ; Apply byte 6: extract bits 4-5 for $06F1 (layer priority tracking)
    AND #$30
    STA $06F1
    LDA $@table_018000+4, X ; Parse bitfield via ROR cascade: bit 0 → BG tilemap $06A2 (layer 0 size flag)
    STZ $06A3
    STZ $06A5
    LDY #$2000
    ROR 
    BCC loc_028AC1
    STY $06A2

  loc_028AC1:
    ROR                   ; Bit 1 → BG tilemap $06A4 (layer 1 size flag)
    BCC loc_028AC7
    STY $06A4

  loc_028AC7:
    ROR 
    ROR 
    ROR 
    ROR 
    ROR 
    LDY #$00E0            ; Bits 2-6 → screen height: $E0 (224 lines) or $100 (256 lines)
    BCC loc_028AD4
    LDY #$0100

  loc_028AD4:
    STY $06EC
    ROR 
    BCS loc_028ADF
    LDA #$01              ; Bit 7 → alternative layer flag ($06A5 bit 0)
    TSB $06A5

  loc_028ADF:
    REP #$20
    LDA $06A2             ; Compare new tilemap settings against previous — invalidate cache on change
    CMP $06A6
    BEQ loc_028AEC
    STZ $0679

  loc_028AEC:
    STA $06A6
    LDA $06A4
    CMP $06A8
    BEQ loc_028AFA
    STZ $067C

  loc_028AFA:
    STA $06A8
    SEP #$20
    LDA $@table_018000+5, X ; Apply byte 7: layerPriorityFlag (BG layer ordering and tilemap base config)
    STA $layerPriorityFlag
    BMI loc_028B22        ; Bit 7 of layerPriorityFlag: swap BG1SC/BG2SC base addresses
    LDA $layerPriorityFlag
    AND #$03              ; Normal: BG1SC = (flag & $03) + $10, BG2SC = ((flag >> 2) & $03) + $18
    CLC 
    ADC #$10
    STA $BG1SC
    LDA $layerPriorityFlag
    LSR 
    LSR 
    AND #$03
    CLC 
    ADC #$18
    STA $BG2SC
    BRA loc_028B3A

  loc_028B22:
    LDA $layerPriorityFlag ; Swapped: BG1SC = (flag & $03) + $18, BG2SC = ((flag >> 2) & $03) + $10
    AND #$03
    CLC 
    ADC #$18
    STA $BG1SC
    LDA $layerPriorityFlag
    LSR 
    LSR 
    AND #$03
    CLC 
    ADC #$10
    STA $BG2SC

  loc_028B3A:
    LDA $@table_018000+6, X ; Apply byte 8: BGMODE register (background mode 0-7 + tile size bits)
    STA $BGMODE
    LDA $@table_018000+7, X ; Apply byte 9: scroll mode + sprite priority flags
    PHA 
    AND #$1F              ; Extract low 5 bits as scrollModeFlags
    STA $scrollModeFlags
    BIT #$08              ; Bit 3 of scroll flags: clear $066E (camera following state)
    BEQ loc_028B52
    STZ $066E

  loc_028B52:
    LDA #$40              ; Manage $09ED bit 6 based on byte 9 bit 7 (sprite DMA suppress control)
    TRB $09ED
    PLA 
    BPL loc_028B5F
    LDA #$40
    TSB $09ED

  loc_028B5F:
    LDA $@table_018000+8, X
    LDA $@table_018000+9, X
    PLY 
    RTS 
}

---------------------------------------------
; Skip three bytes in the scene script stream (INY ×3) and return. Used for commands with a fixed 3-byte operand the engine does not interpret.

SceneCmd_Skip3 {
    INY 
    INY 
    INY 
    RTS 
}

---------------------------------------------
; Load SPC music data when the room group matches. Reads musicParentActor and room group from script, loads ROM pointer, compares musicRoomGroup to script group — mismatch exits. CheckSourceCacheHit on $0687 skips redundant loads. On load: WaitFrames(26), optional stop ($F2 + 32 frames if $0D72 set), handshake ($F0 poll, $FF), SpcBlockTransfer from $46/$48, sets $0D72=1, then writes play ($01) or stop ($00) to APUIO0 based on musicParentActor.

SpcMusicLoadCmd {
    JSR $&ReadScriptByte  ; Read music parent actor ID from script
    STA $musicParentActor
    JSR $&ReadScriptByte  ; Read room group identifier for music region tracking
    STA $06F4
    LDX #$003E
    JSR $&LoadScriptPointer
    LDA $musicRoomGroup   ; Compare current musicRoomGroup — same group means music is already loaded
    CMP $06F4
    BEQ loc_028B88
    RTS 

  loc_028B88:
    LDX #$0687            ; Check source cache ($0687) for redundant music data transfer
    JSR $&CheckSourceCacheHit
    BCS loc_028B91
    RTS 

  loc_028B91:
    LDA #$1A              ; Wait 26 frames ($1A) for audio system settling
    JSL $@vblank_joypad.WaitFrames
    LDA $0D72             ; Check if music engine was previously loaded ($0D72)
    BEQ loc_028BA7
    LDA #$F2              ; Send stop command $F2 to APU I/O port 0
    STA $APUIO0
    LDA #$20              ; Wait 32 frames ($20) for SPC to process stop
    JSL $@vblank_joypad.WaitFrames

  loc_028BA7:
    LDA #$F0              ; Send ready signal $F0 to initiate IPL handshake
    STA $APUIO0

  loc_028BAC:
    LDA $APUIO0           ; Poll APUIO0 until SPC acknowledges with $00
    BNE loc_028BAC
    LDA #$02
    JSL $@vblank_joypad.WaitFrames ; Wait 2 frames for handshake completion
    LDA #$FF              ; Send $FF to signal data transfer imminent
    STA $APUIO0
    LDA #$02
    JSL $@vblank_joypad.WaitFrames
    LDX $3E               ; Set up ROM pointer ($3E→$46, $40→$48) for SpcBlockTransfer
    STX $46
    LDX $40
    STX $48
    JSL $@spc_transfer.SpcBlockTransfer ; Execute bulk SPC data transfer
    LDA #$01              ; Set music loaded flag ($0D72 = 1)
    STA $0D72
    LDA #$03              ; Wait 3 frames for SPC to initialize transferred data
    JSL $@vblank_joypad.WaitFrames
    LDA $musicParentActor ; Check musicParentActor — nonzero triggers music playback
    BEQ loc_028BE0
    LDA #$01

  loc_028BE0:
    STA $APUIO0           ; Write play/stop command to APUIO0 (1=play, 0=stop)
    RTS 
}

---------------------------------------------
; Load sprite tile graphics. Reads 16-bit tile data size from [$3A],Y (stores to $0666), advances Y by 3, loads source pointer. CheckSourceCacheHit on $0684 — hit returns without work. On miss: if compressed pointer non-null, decompresses to $4000; if null ($0000), DmaRomToWram from ROM to $7E:4000 (uncompressed sprite tile staging).

SceneCmd_LoadSpriteTiles {
    PHP 
    REP #$20
    LDA [$3A], Y          ; Read 16-bit tile data size directly from script ([$3A],Y)
    STA $0666
    SEP #$20              ; Switch to 8-bit for byte-level pointer parsing
    INY 
    INY 
    INY 
    LDX #$003E            ; Load pointer destination register X=$003E
    JSR $&LoadScriptPointer
    LDX #$0684            ; Check sprite tile source cache (slot $0684)
    JSR $&CheckSourceCacheHit
    BCC loc_028C19        ; Cache hit (carry clear): skip loading entirely
    REP #$20
    LDA [$3E]             ; Read compressed sprite tile pointer from source
    INC $3E
    INC $3E
    CMP #$0000            ; Null pointer check — $0000 means uncompressed data
    BEQ loc_028C1B
    STA $78               ; Compressed: store size, decompress to VRAM $4000 (sprite tile area)
    SEP #$20
    LDX #$4000
    STX $7A
    JSL $@QuintetLzDecompress

  loc_028C19:
    PLP 
    RTS 

  loc_028C1B:
    STZ $0664             ; Uncompressed path: DMA raw data to WRAM $7E:4000
    STZ $0668
    LDX #$4000
    STX $42
    LDA #$007E
    STA $44
    JSR $&DmaRomToWram
    PLP 
    RTS 
}

---------------------------------------------
; Load character/object tiles with flexible VRAM targeting. Reads flags $066A and source pointer; reads width×height words, SignedMultiply, then ×8 for tile byte size in $0666. Decompresses to $7000 if compressed pointer non-null. VRAM destination from flags: bit 7 = (flags & $7F)×4 absolute address; bit 0 = $1000 (PEA+RTS chains to bit 1 check); bit 1 = $1800; neither bit → return without DMA. Transfer: mode $01, B-bus $18, size $0666.

SceneCmd_LoadCharTiles {
    PHP 
    JSR $&ReadScriptByte  ; Read VRAM target flags byte from script
    STA $066A
    LDX #$003E
    JSR $&LoadScriptPointer
    REP #$20              ; Read width and height from source data as paired bytes
    LDA [$3E]
    STA $00
    INC $3E
    INC $3E
    LDA [$3E]
    XBA                   ; Combine width/height via XBA+ORA for dimension value
    ORA $00
    INC $3E
    INC $3E
    SEP #$20
    JSL $@hardware_math.SignedMultiply ; Compute tile byte count via SignedMultiply
    REP #$20
    STA $00
    XBA 
    ASL                   ; Convert to VRAM transfer size: XBA+ASL×3 → $0666
    ASL 
    ASL 
    STA $0666
    LDA [$3E]             ; Read compressed tile pointer from source
    INC $3E
    INC $3E
    BEQ loc_028C81        ; Null pointer = skip to uncompressed path
    STA $78               ; Compressed: decompress to staging buffer $7000
    SEP #$20
    LDX #$7000
    STX $7A
    JSL $@QuintetLzDecompress
    LDX #$7000
    STX $3E
    LDA #$7E
    STA $40
    BRA loc_028C87

  loc_028C81:
    INC $3E
    INC $3E
    SEP #$20

  loc_028C87:
    LDA $066A             ; Parse VRAM destination from flags byte
    BPL loc_028C9A        ; Bit 7 set: absolute VRAM address = (flags & $7F) × 4
    AND #$7F
    XBA 
    LDA #$00
    REP #$20
    ASL 
    ASL 
    STA $VMADDL
    BRA loc_028CC4

  loc_028C9A:
    REP #$20              ; Bit 7 clear: check bit pattern for predefined VRAM slots
    AND #$00FF
    BIT #$0001
    BEQ code_028CB0
    LDA #$1000            ; Bit 0: VRAM $1000 (first character page), chain to bit 1 check via PEA+RTS
    STA $VMADDL
    PEA $&code_028CB0-1
    PHP 
    BRA loc_028CC4
}

code_028CB0 {
    REP #$20
    LDA $066A
    BIT #$0002
    BEQ loc_028CC2
    LDA #$1800            ; Bit 1: VRAM $1800 (second character page)
    STA $VMADDL
    BRA loc_028CC4

  loc_028CC2:
    PLP 
    RTS 

  loc_028CC4:
    SEP #$20              ; Final DMA setup: mode $01, B-bus $18, size from $0666
    LDA #$01
    STA $DMAP0
    LDA #$18
    STA $BBAD0
    LDX $3E
    STX $A1T0L
    LDA $40
    STA $A1B0
    LDX $0666
    STX $DAS0L
    LDA #$01
    STA $MDMAEN
    PLP 
    RTS 
}

---------------------------------------------
; Read one byte from the scene script stream at [$3A],Y. Saves/restores processor state, clears the B accumulator (XBA with #$00) so callers in 16-bit mode receive a clean low byte in A, advances Y, and returns.

ReadScriptByte {
    PHP                   ; Save processor state — callers may be in 8-bit or 16-bit mode
    SEP #$20
    LDA #$00              ; Clear B accumulator (XBA with #$00) for clean 16-bit result
    XBA 
    LDA [$3A], Y          ; Read one byte from script data stream at [$3A]+Y offset
    INY 
    PLP 
    RTS 
}

---------------------------------------------
; Locate the current scene's command block in script data. Starts at Y=0, reads scene ID byte at [$3A],Y, skips one byte, compares to sceneCurrent — match returns with Y at the first command opcode. On mismatch, scans forward: reads each opcode and advances Y by operand size using a fall-through INY cascade ($02/$13/$14/$15 = +2, $04/$10 = +3, $03/$05 = +5, $06 = +4, $0E = +3, $11 = +4). Repeats until the target scene is found.

FindCurrentScene {
    LDY #$0000            ; Start scanning at beginning of scene table (Y=0)

  loc_028CF5:
    LDA [$3A], Y          ; Read 16-bit scene ID from script data
    INY 
    INY 
    CMP $sceneCurrent     ; Compare against current scene — match returns immediately
    BNE loc_028CFF
    RTS 

  loc_028CFF:
    SEP #$20              ; No match: switch to 8-bit for command byte parsing
    LDA [$3A], Y          ; Read command opcode to determine skip size
    INY 
    CMP #$00              ; Opcode $00 = scene boundary — advance to next scene entry
    BEQ loc_028CF5
    CMP #$13              ; Fall-through cascade: each command type branches to appropriate skip count
    BEQ loc_028D39
    CMP #$02
    BEQ loc_028D3A
    CMP #$03
    BEQ loc_028D34
    CMP #$04
    BEQ loc_028D35
    CMP #$05
    BEQ loc_028D34
    CMP #$06
    BEQ loc_028D37
    CMP #$0E
    BEQ loc_028D38
    CMP #$10
    BEQ loc_028D35
    CMP #$11
    BEQ loc_028D36
    CMP #$14
    BEQ loc_028D3A
    CMP #$15
    BEQ loc_028D3A

  loc_028D34:
    INY                   ; Skip cascade: INY fall-throughs give 5/4/3/2/1 byte skips per command type

  loc_028D35:
    INY 

  loc_028D36:
    INY 

  loc_028D37:
    INY 

  loc_028D38:
    INY 

  loc_028D39:
    INY 

  loc_028D3A:
    INY 
    BRA loc_028CFF
}

---------------------------------------------
; Skip a counted block of scene commands. Reads a count byte (pushed as stack boundary), then scans opcodes with the same operand-size logic as FindCurrentScene. Opcode $12 terminates immediately; nested opcode $15 compares its inner count byte against the stacked boundary — equal count ends the skip. All other opcodes advance Y by their operand size until termination.

SkipScriptCommands {
    JSR $&ReadScriptByte  ; Read command count (boundary marker) and push to stack
    PHA 
    LDY #$0000

  loc_028D44:
    INY                   ; Advance past 2-byte scene ID header
    INY 

  loc_028D46:
    LDA [$3A], Y          ; Read command byte for skip-size determination
    INY 
    CMP #$00
    BEQ loc_028D44
    CMP #$02
    BEQ loc_028D83
    CMP #$03
    BEQ loc_028D7D
    CMP #$04
    BEQ loc_028D7E
    CMP #$05
    BEQ loc_028D7D
    CMP #$06
    BEQ loc_028D80
    CMP #$0E
    BEQ loc_028D81
    CMP #$10
    BEQ loc_028D7E
    CMP #$11
    BEQ loc_028D7F
    CMP #$12
    BEQ loc_028D8D
    CMP #$13
    BEQ loc_028D82
    CMP #$14
    BEQ loc_028D86
    CMP #$15
    BEQ loc_028D83

  loc_028D7D:
    INY 

  loc_028D7E:
    INY 

  loc_028D7F:
    INY 

  loc_028D80:
    INY 

  loc_028D81:
    INY 

  loc_028D82:
    INY 

  loc_028D83:
    INY 
    BRA loc_028D46

  loc_028D86:
    LDA [$3A], Y          ; Command $15 (SkipScriptCommands): compare nested count against stacked boundary
    INY 
    CMP $01, S
    BNE loc_028D46

  loc_028D8D:
    PLA 
    RTS 
}

---------------------------------------------
; Read a 3-byte ROM pointer from the script stream into address X. Stores 16-bit word to $0000,X and bank byte to $0002,X, then applies SNES LoROM mapping: banks $00–$6F get +$80; banks $80–$9F additionally get +$20 with address bit 15 cleared (HiROM canonical form).

LoadScriptPointer {
    PHP 
    REP #$20
    LDA [$3A], Y          ; Read 16-bit address word from script stream, store at $0000+X
    INY 
    INY 
    STA $0000, X
    SEP #$20
    LDA [$3A], Y          ; Read 8-bit bank byte, store at $0002+X
    INY 
    STA $0002, X
    CMP #$70              ; Bank >= $70: HiROM range, no mapping needed
    BCS loc_028DBF
    CLC 
    ADC #$80              ; Add $80: map LoROM bank $00-$6F to HiROM $80-$EF
    CMP #$A0              ; Check $A0 threshold: banks $20-$3F need additional adjustment
    BCC loc_028DBC
    CLC 
    ADC #$20              ; Add $20 for banks $20-$3F (→ $C0-$DF)
    STA $0002, X
    LDA $0001, X          ; Clear bit 15 of address word for canonical HiROM format
    AND #$7F
    STA $0001, X
    BRA loc_028DBF

  loc_028DBC:
    STA $0002, X

  loc_028DBF:
    PLP 
    RTS 
}

---------------------------------------------
; Compare current source pointer ($3E/$40) against cached entry at [$0000+X]. Address and bank match → return carry clear (cache hit, skip load). Mismatch → store new pointer to cache slot, return carry set (cache miss, load required).

CheckSourceCacheHit {
    PHP 
    REP #$20
    LDA $3E               ; Compare current source address ($3E) against cached entry
    CMP $0000, X
    BNE loc_028DD9
    SEP #$20
    LDA $40               ; Compare bank byte ($40) against cached bank
    CMP $0002, X
    BNE loc_028DD9
    REP #$20
    PLP 
    CLC                   ; Match: return carry clear (cache hit — skip loading)
    RTS 

  loc_028DD9:
    SEP #$20              ; Mismatch: store new source pointer to cache slot
    LDA $40
    STA $0002, X
    REP #$20
    LDA $3E
    STA $0000, X
    PLP 
    SEC                   ; Return carry set (cache miss — load needed)
    RTS 
}

---------------------------------------------
; DMA or copy from ROM to WRAM with SNES address-space handling. HiROM path (source bank ≥ $80 with addr ≥ $8000, or bank ≥ $C0): hardware DMA — source = $3E+$0664, dest = $42+$0668 → WMADDL, size = $0666−$0664, WMADDH=1 when dest bank is $7F. LoROM path (bank < $80): software copy via JSR $0402 with banks at $0404/$0405 and byte count = ($0666−$0664)−1.

DmaRomToWram {
    PHP 
    PHY 
    SEP #$20
    LDA $3E               ; Check source bank for address space routing
    CMP #$80              ; Bank < $80: potential LoROM or mirrored address
    BCC loc_028E43
    CMP #$C0
    BCS loc_028E01
    REP #$20              ; Check full 16-bit address for mirrored range ($8000 threshold)
    LDA $3E
    CMP #$8000
    BCC loc_028E43

  loc_028E01:
    REP #$20
    LDA $0666             ; HiROM DMA: compute transfer size = end − start offset
    SEC 
    SBC $0664
    STA $DAS0L
    LDA $3E
    CLC 
    ADC $0664             ; Compute source address = pointer + start offset
    STA $A1T0L
    LDA $42
    CLC 
    ADC $0668             ; Compute WRAM destination = base + page offset
    STA $WMADDL
    SEP #$20
    LDA $44               ; Determine WMADDH: $7F bank → high WRAM page (bit 0 = 1)
    CMP #$7F
    LDA #$00
    ADC #$00
    STA $WMADDH
    LDA #$00              ; DMA mode $00: single byte write to WRAM port ($2180)
    STA $DMAP0
    LDA #$80
    STA $BBAD0
    LDA $40
    STA $A1B0
    LDA #$01
    STA $MDMAEN
    PLY 
    PLP 
    RTS 

  loc_028E43:
    PHX                   ; LoROM path: set up banks for software copy via $0402 routine
    SEP #$20
    LDA $40
    STA $0405
    LDA $44
    STA $0404
    REP #$20
    LDA $3E
    CLC 
    ADC $0664
    TAX 
    LDA $42
    CLC 
    ADC $0668
    TAY 
    LDA $0666
    SEC 
    SBC $0664
    DEC 
    JSR $0402             ; Call software copy at $0402 for LoROM-to-WRAM transfer
    PLX 
    PLY 
    PLP 
    RTS 
}

---------------------------------------------
; Search the 4-entry graphics cache at $0084–$008F for a matching source address. Each entry is 3 bytes (addr lo/hi, bank). Compares $3E then $40; X steps 0, 3, 6, 9. Returns carry set if found, carry clear if not.

GraphicsCacheLookup {
    LDX #$0000            ; Start search at cache slot 0

  loc_028E72:
    LDA $3E               ; Compare source address ($3E) against slot address
    CMP $0084, X
    BEQ loc_028E83

  loc_028E79:
    INX                   ; No match: advance to next 3-byte slot (INX ×3)
    INX 
    INX 
    CPX #$000C            ; Check if all 4 slots searched (X == $000C)
    BNE loc_028E72
    CLC 
    RTS 

  loc_028E83:
    SEP #$20              ; Address match: verify bank byte ($40) in 8-bit mode
    LDA $40
    CMP $0086, X
    BEQ loc_028E90
    REP #$20
    BRA loc_028E79

  loc_028E90:
    REP #$20              ; Full match: return carry set (cache hit found)
    SEC 
    RTS 
}

---------------------------------------------
; Store current source pointer ($3E/$40) into the graphics cache ring buffer. Reads ring index $0094, increments with wrap (AND #$0003), computes slot offset (index×3 via ASL+ADC), writes address and bank to $0084+X.

GraphicsCacheStore {
    LDX $0094             ; Read current ring buffer index from $0094
    TXA 
    INC                   ; Advance index, wrap at 4 (AND #$0003)
    AND #$0003
    STA $0094
    TXA 
    PHA 
    ASL                   ; Compute 3-byte slot offset: index × 3 (ASL + ADC)
    CLC 
    ADC $01, S
    TAX 
    PLA 
    LDA $003E             ; Store source address and bank to computed cache slot
    STA $0084, X
    SEP #$20
    LDA $0040
    STA $0086, X
    REP #$20
    RTS 
}

---------------------------------------------
; Back up newly loaded VRAM tile data to the WRAM ring buffer for later cache restoration. Sets VMADDL from $0668. If size exceeds $2000, splits: first $2000 bytes via DmaVramToRam, then advances ring index (wrap at 4), invalidates that cache slot ($FFFF/$FF), offsets VMADDL by $1000, and DMAs the remainder.

SaveVramToRingBuffer {
    PHY 
    LDA $0668             ; Set VRAM read address from tile page ($0668 XBA for ×256 word addressing)
    XBA 
    STA $VMADDL
    LDA $0666             ; Check if tile data exceeds $2000 bytes (needs 2 ring buffer slots)
    CMP #$2001
    BMI loc_028ED4
    SEC 
    SBC #$2000            ; Large data: split first $2000, save remainder
    STA $0666
    LDA #$2000
    BRA loc_028ED7

  loc_028ED4:
    STZ $0666             ; Small data: clear remainder tracking

  loc_028ED7:
    JSR $&DmaVramToRam    ; DMA first block from VRAM to WRAM ring buffer
    LDA $0666
    BEQ loc_028F16
    PHA 
    LDY $0094             ; Advance ring buffer index for second slot
    TYA 
    INC 
    CMP #$0004
    BCC loc_028EED
    LDA #$0000

  loc_028EED:
    STA $0094
    TYA 
    PHA 
    ASL 
    CLC 
    ADC $01, S
    TAY 
    PLA 
    LDA #$FFFF            ; Invalidate the overflow slot's cache entry ($FFFF/$FF)
    STA $0084, Y
    SEP #$20
    LDA #$FF
    STA $0086, Y
    REP #$20
    LDA $0668
    XBA 
    CLC 
    ADC #$1000            ; Offset VRAM read address by $1000 for second block
    STA $VMADDL
    PLA 
    JSR $&DmaVramToRam    ; DMA second block from VRAM to WRAM

  loc_028F16:
    PLY 
    RTS 
}

---------------------------------------------
; DMA from VRAM to WRAM (reverse direction). Sets transfer size from A, calls ComputeRingBufferAddr for destination, primes read via VMDATALREAD. DMA mode $81, B-bus $39 (VMDATAHREAD), source bank $7F; restores DMAP0 to $01 afterward.

DmaVramToRam {
    PHP 
    STA $DAS0L            ; Set transfer size from A register
    JSR $&ComputeRingBufferAddr ; Compute WRAM ring buffer destination address
    TAY 
    LDA $VMDATALREAD      ; Prime VRAM read buffer by reading VMDATALREAD
    SEP #$20
    STY $A1T0L
    LDA #$7F
    STA $A1B0
    LDA #$81              ; DMA mode $81: VRAM-to-WRAM (read B-bus $39 = VMDATAHREAD)
    STA $DMAP0
    LDA #$39
    STA $BBAD0
    LDA #$01
    STA $MDMAEN
    LDA #$01              ; Restore DMA mode to $01 (normal write direction)
    STA $DMAP0
    PLP 
    RTS 
}

---------------------------------------------
; Compute WRAM ring-buffer slot address from current index $0094. DEC, ROR×4 to place the 2-bit index into bits 13–14, AND #$6000, ADC #$4000. Yields $4000, $6000, $8000, or $A000 (each slot holds $2000 bytes).

ComputeRingBufferAddr {
    LDA $0094             ; Read current ring index, decrement for the just-used slot
    DEC 
    ROR                   ; ROR ×4: shift 2-bit index to bits 13-14 ($2000 alignment)
    ROR 
    ROR 
    ROR 
    AND #$6000            ; AND #$6000: isolate the 2-bit slot selector
    CLC 
    ADC #$4000            ; Add $4000 base: produces $4000/$6000/$8000/$A000 slot addresses
    RTS 
}

---------------------------------------------
; Restore previously cached VRAM tile data from the WRAM ring buffer. Reads slot index from CacheSlotIndices table (X), computes WRAM source via ROR×4 + AND + ADC. If total size fits in one $2000 block, single DmaWramToVram; otherwise splits into $2000 + remainder with VRAM offset bumped ($0668 + $10) and next ring slot for the second transfer.

RestoreCachedVram {
    PHY 
    LDA $@system_init.CacheSlotIndices, X ; Read cache slot index from CacheSlotIndices table
    AND #$00FF
    PHA 
    ROR                   ; Compute WRAM source address via same ROR×4+AND+ADC pattern
    ROR 
    ROR 
    ROR 
    AND #$6000
    CLC 
    ADC #$4000
    TAX 
    LDA $0666             ; Check total restore size ($0666-$0664) against $2000 threshold
    SEC 
    SBC $0664
    CMP #$2001
    BCS loc_028F7B        ; Small data: single DmaWramToVram transfer
    TAY 
    JSR $&DmaWramToVram
    PLA 
    PLY 
    RTS 

  loc_028F7B:
    SEC                   ; Large data: first $2000 bytes
    SBC #$2000
    PHA 
    LDA #$2000
    TAY 
    JSR $&DmaWramToVram
    LDA $0668
    CLC 
    ADC #$0010            ; Advance VRAM page offset by $10 for second transfer
    STA $0668
    LDA $03, S            ; Compute next ring buffer slot address for overflow data
    INC 
    ROR 
    ROR 
    ROR 
    ROR 
    AND #$6000
    CLC 
    ADC #$4000
    TAX 
    PLA 
    JSR $&DmaWramToVram   ; DMA second block from WRAM to VRAM
    PLA 
    PLY 
    RTS 
}

---------------------------------------------
; DMA from WRAM to VRAM. Sets VMADDL from $0668 (XBA), source address X, size Y. Mode $01, B-bus $18 (VMDATAL), source bank $7F. Returns in 16-bit mode (REP #$20).

DmaWramToVram {
    LDA $0668             ; Set VRAM destination from tile page ($0668 XBA for ×256 words)
    XBA 
    STA $VMADDL
    STX $A1T0L            ; Source address from X register, transfer size from Y
    STY $DAS0L
    SEP #$20
    LDA #$01              ; DMA mode $01: two-register word write to VMDATAL ($18)
    STA $DMAP0
    LDA #$18
    STA $BBAD0
    LDA #$7F              ; Source bank = $7F (WRAM ring buffer)
    STA $A1B0
    LDA #$01
    STA $MDMAEN
    REP #$20
    RTS 
}

---------------------------------------------
; Rebuild SNES tilemap attribute bytes for a loaded tilemap layer. X selects layer (0 or 2). Loads tilemap pointer from $06AA+X and attribute table from $06AE+X. Processes entries in groups of 4: patches each tilemap word with layer base from $06A2+X, extracts palette high bit (AND #$02) from each high byte, packs four bits via ASL+ORA cascade into one attribute byte stored via [$42]. Repeats for the full tilemap extent in $0E outer loops.

RebuildTilemapAttrs {
    PHP 
    SEP #$20              ; Switch to 8-bit for byte-level tilemap attribute extraction
    PHB 
    PHY 
    LDA #$7E              ; Set data bank to $7E for direct WRAM tilemap access
    PHA 
    PLB 
    LDY $06AA, X          ; Load tilemap output pointer from layer-specific slot ($06AA+X)
    STY $42
    LDA #$7F
    STA $44
    LDY $06AE, X          ; Load attribute source pointer from $06AE+X
    LDA #$00
    STA $0E

  loc_028FE6:
    LDA #$04              ; Outer loop: process groups of 4 tilemap entries
    STA $10

  loc_028FEA:
    LDA $0001, Y          ; Read high byte of tilemap entry for attribute extraction
    AND #$02              ; Isolate bit 1 (palette high bit) via AND #$02
    PHA                   ; Push attribute bit to stack (accumulate 4 bits)
    REP #$20
    LDA $0000, Y          ; Clear bit 9 ($FDFF) and merge layer flags ($06A2+X) into tilemap entry
    AND #$FDFF
    ORA $06A2, X
    STA $0000, Y
    SEP #$20
    INY 
    INY 
    DEC $10
    BNE loc_028FEA
    PLA                   ; Pack 4 stacked attribute bits via ASL+ORA cascade
    ASL 
    ORA $01, S
    ASL 
    ORA $02, S
    ASL 
    ORA $03, S
    LSR 
    STA [$42]             ; Store packed attribute byte via indirect write to [$42]
    INC $42
    PLA 
    PLA 
    PLA 
    DEC $0E
    BNE loc_028FE6
    PLY 
    PLB 
    PLP 
    RTS 
}

---------------------------------------------
; Reload map layer tilemaps after scene script end. Calls ReloadMapLayer0 for layer 0; if scrollModeFlags bit 0 is set, also calls ReloadMapLayer1 for the secondary layer.

ReloadMapData {
    LDX #$0000            ; Reload layer 0 map data from external storage
    JSR $&ReloadMapLayer0
    LDA $scrollModeFlags  ; Check scrollModeFlags bit 0 — dual-layer mode enables layer 1 reload
    BIT #$01
    BEQ loc_029033
    LDX #$0002            ; Reload layer 1 map data
    JSR $&ReloadMapLayer1

  loc_029033:
    RTS 
}

---------------------------------------------
; Reload layer 0 tilemap from runtime modification storage. Source pointer from $06AA (bank $7F); byte count = mapRowStrideL0 × $0697 via SignedMultiply. For each byte: reads indirection chain $7E0000,X → [$3E] → stores to $7F2000,X, re-applying runtime tilemap edits held in WRAM bank $7F.

ReloadMapLayer0 {
    LDY $06AA             ; Load source pointer from $06AA (layer 0 tilemap backup)
    STY $3E
    LDA #$7F
    STA $40
    LDA $mapRowStrideL0   ; Compute total byte count: mapRowStrideL0 × column count
    XBA 
    LDA $0697
    JSL $@hardware_math.SignedMultiply
    XBA 
    TAY 
    BEQ loc_02905F
    LDX $mapTilemapBaseA  ; Load tilemap base address as copy start index

  loc_02904F:
    LDA $7E0000, X        ; Copy loop: read source byte, use as indirect pointer, store to $7F bank
    STA $3E
    LDA [$3E]             ; Indirect read through [$3E] — re-applies runtime tilemap modifications
    STA $7F2000, X
    INX 
    DEY 
    BNE loc_02904F

  loc_02905F:
    RTS 
}

---------------------------------------------
; Reload layer 1 overlay tilemap — same structure as ReloadMapLayer0 but uses $06AC, mapRowStrideL1/$0699, map base $0080, and writes to animScratch ($7F:0000+X). Skips store when the resolved value is $0000 to preserve sparse overlay entries.

ReloadMapLayer1 {
    LDY $06AC             ; Load source pointer from $06AC (layer 1 tilemap backup)
    STY $3E
    LDA #$7F
    STA $40
    LDA $mapRowStrideL1   ; Compute byte count: mapRowStrideL1 × column count
    XBA 
    LDA $0699
    JSL $@hardware_math.SignedMultiply
    XBA 
    TAY 
    BEQ loc_02908D
    LDX $0080             ; Load map base address from $0080

  loc_02907B:
    LDA $7E0000, X
    STA $3E
    LDA [$3E]             ; Read through indirect pointer — check for zero
    BEQ loc_029089        ; Zero check: skip store for null entries (preserve existing sparse overlay data)
    STA $animScratch, X   ; Store non-null entry to animScratch (overlay animation layer)

  loc_029089:
    INX 
    DEY 
    BNE loc_02907B

  loc_02908D:
    RTS 
}