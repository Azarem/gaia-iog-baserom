; Event block tile swap system — runtime map modification triggered by event flags (172521–173533, Bank 02).
; 
; Manages event-triggered tile modifications on the game map: doors opening, bridges appearing, barriers being removed, and other scripted tile changes. Each event block defines a rectangular region of tiles to swap between a source and destination position on the map.
; 
; === EVENT FLAG INDEXING ===
; 
; ApplyAllEventBlocks iterates through event flags stored as bitfields at $0A20. Each byte contains 8 flag bits, processed via LSR+BCC per bit. When a flag bit is set, the corresponding event block index ($04) is looked up via LookupEventBlock. The loop processes all 256 event indices (counter wraps at zero).
; 
; === EVENT BLOCK TABLE FORMAT ===
; 
; LookupEventBlock reads 8-byte entries from event_block_table (index × 8):
;   Byte 0: Scene ID — must match sceneCurrent or the entry is skipped (carry set = no match)
;   Bytes 1-2: Source tile X/Y coordinates ($96/$98)
;   Bytes 3-4: Width ($A2/$9E) and height ($A0) of the rectangle
;   Bytes 5-6: Destination tile X/Y coordinates ($9A/$9C)
;   Byte 7: Layer flag ($A4) — 0 = layer 0 (mapLayerTilemap), nonzero = layer 1 (effectLayerTilemap)
; 
; === TILE SWAP OPERATIONS ===
; 
; Two modes of tile swapping:
; 
; 1. SwapEventBlockTiles (instant): Copies tiles from source to destination in a nested row/column loop using map_coords.MapIndexMoveRight and MapIndexMoveDown for traversal. Layer 0 path swaps both mapLayerTilemap and collisionLayer bytes directly. Layer 1 path additionally resolves collision via indirect pointer [$3E] in bank $7F — only writes collision if the resolved byte is non-zero.
; 
; 2. AnimateEventBlock (visual): Same tile-swapping logic but with per-tile VRAM updates. For each swapped tile within the camera viewport, QueueVisibleTileVram expands the metatile index into four 8×8 VRAM tilemap words and queues them to the VRAM write buffer ($0800+Y). Calls UpdateFrameDialogue between batches to allow the display to refresh, producing a visible animation of tiles changing.
; 
; === VRAM WRITE QUEUE ===
; 
; FlushVramWriteQueue processes queued tile updates during VBlank. Two paths:
; - Queued mode (dmaSkipFlag nonzero): Switches SP to $07FF and POPs address/data pairs (PLA → VMADDL, PLA → VMDATAL) until a zero sentinel. This bulk-flushes all queued metatile updates in a single VBlank.
; - Direct mode (dmaSkipFlag zero): Writes tileQueryResult entries directly to VRAM — four words at $0902/$0904/$0906/$0908/$090A/$090C for interactive tile probe results.
; 
; === VISIBILITY CHECK ===
; 
; QueueVisibleTileVram tests whether a tile's pixel position falls within the camera viewport by comparing against bg1ScrollH/bg2ScrollH and bg1ScrollV/savedCameraDelta. Tiles outside the visible area are skipped — only on-screen tiles get queued for VRAM update. Returns carry set if off-screen, carry clear + Z flag for queue full ($0100 bytes = 16 metatiles), or carry clear + NZ for successful queue.
; 
; === HELPER ROUTINES ===
; 
; AdvanceEventColumn: Decrements the column counter ($9E), advances pixel X by 16, increments source and destination tile X coordinates, and moves both map indices right. Returns carry set when all columns in the current row are done.
; 
; AdvanceEventRow: Decrements the row counter ($A0), advances pixel Y by 16, increments tile Y coordinates, reloads the source X coordinate from the original event_block_table entry ($A8 = table offset), and resets the column counter from $A2. Returns carry set when all rows are done.
---------------------------------------------

?BANK 02

?INCLUDE 'event_block_table'
?INCLUDE 'map_coords'
?INCLUDE 'system_core'

!sceneCurrent                   0644
!bg1ScrollH                     068A
!bg1ScrollV                     068C
!bg2ScrollH                     068E
!savedCameraDelta               0690
!dmaSkipFlag                    0800
!tileQueryResult                0902
!VMAIN                          2115
!VMADDL                         2116
!VMDATAL                        2118
!metatileMapLayer               7E2000
!metatileEffectLayer            7E2800
!mapLayerTilemap                7EA000
!effectLayerTilemap             7EC000
!collisionLayer                 7FC000

---------------------------------------------

; Apply all active event block tile swaps for the current scene.
; 
; Iterates through the event flag bitfield at $0A20 in 8-bit chunks. Each byte contains 8 flag bits — LSR shifts each bit into carry. When carry is set, the current event index ($04) is looked up via LookupEventBlock. If the lookup succeeds (scene matches, carry clear), SwapEventBlockTiles performs the tile swap.
; 
; The event index counter ($04) increments for every bit position. After processing 8 bits per byte ($0E counts down from 8), the byte index Y advances. The outer loop terminates when $04 wraps to zero (all 256 event indices processed).
; 
; Saves and restores processor state (PHP/PLP). Operates in 8-bit accumulator mode for the bitfield iteration, switching to 16-bit for the lookup call.

ApplyAllEventBlocks {
    PHP 
    SEP #$20
    LDY #$0000            ; Event block index counter $04 = 0; will walk all 256 event flag bits
    STY $04

  loc_02A1F1:
    LDA $0A20, Y          ; Load next byte from event flag bitfield at $0A20 (8 flags per byte)
    INY 
    STA $06
    LDA #$08              ; $0E = 8 — inner loop shifts one bit at a time via LSR
    STA $0E

  loc_02A1FB:
    LSR $06               ; Test current flag bit; carry clear = inactive, skip this event index
    BCC loc_02A214
    LDA $04               ; Flag set — pass current event index ($04) to LookupEventBlock
    REP #$20
    PHY 
    AND #$00FF
    JSL $@LookupEventBlock ; Validate scene + load 8-byte event_block_table entry into DP params
    PLY 
    SEP #$20
    BCS loc_02A214        ; Lookup failed (wrong scene) — skip tile swap for this index
    JSL $@SwapEventBlockTiles ; Scene match — instantly copy source rectangle to destination on map

  loc_02A214:
    INC $04
    DEC $0E
    BNE loc_02A1FB
    LDA $04               ; Outer loop until $04 wraps to 0 (all 256 event indices scanned)
    BNE loc_02A1F1
    PLP 
    RTL 
}

---------------------------------------------
; Swap a rectangular region of tiles between source and destination map positions.
; 
; Entry: DP $96/$98 = source X/Y tile coordinates, $9A/$9C = destination X/Y tile coordinates, $9E = width (columns remaining), $A0 = height (rows remaining), $A2 = original width, $A4 = layer flag (0 = layer 0, nonzero = layer 1).
; 
; Layer 0 path (loc_02A264): For each tile in the rectangle, copies mapLayerTilemap and collisionLayer bytes from source index ($02) to destination index ($00). Uses MapIndexMoveRight for column traversal and MapIndexMoveDown for row traversal.
; 
; Layer 1 path (loc_02A2B9): Similar structure but operates on effectLayerTilemap instead of mapLayerTilemap. Collision is resolved through an indirect pointer: the effectLayerTilemap byte is stored to $3E, then LDA [$3E] reads the resolved collision value from bank $7F ($06AC). Only writes collision if the resolved byte is non-zero (BEQ skips the write), preserving existing collision for empty overlay tiles.
; 
; For both layers, sets up the collision bank pointer ($3E/$40) from $06AC and $7F at entry.

SwapEventBlockTiles {
    PHP 
    PHY 
    REP #$20
    LDA $06AC             ; Collision indirect pointer: $3E = $06AC base, $40 = bank $7F
    STA $3E
    LDA #$007F
    STA $40
    STZ $A6               ; $A6 = 0 (layer 0); nonzero $A4 selects layer 1 path ($A6 = 2)
    LDA $A4
    AND #$00FF
    BEQ loc_02A23C
    LDA #$0002
    STA $A6

  loc_02A23C:
    LDA $9A               ; Convert destination tile coords ($9A/$9C) to map index via TileCoordsToMapIndex
    STA $18
    LDA $9C
    STA $1C
    LDX $A6
    JSL $@map_coords.TileCoordsToMapIndex
    STX $00
    STX $1A
    LDA $96               ; Convert source tile coords ($96/$98) to map index — stored at $02/$00
    STA $18
    LDA $98
    STA $1C
    LDX $A6
    JSL $@map_coords.TileCoordsToMapIndex
    STX $02
    STX $1E
    LDA $A6
    BNE loc_02A2B9

  loc_02A264:
    LDX $02               ; L0 row loop: swap mapLayerTilemap + collisionLayer source→dest
    SEP #$20
    LDA $mapLayerTilemap, X ; Read source map tile and collision bytes at index $02
    PHA 
    LDA $collisionLayer, X
    LDX $00
    STA $collisionLayer, X ; Write collision to destination index $00, then map tile byte
    PLA 
    STA $mapLayerTilemap, X
    REP #$20
    DEC $9E               ; Column counter ($9E) exhausted — end of current row
    BEQ loc_02A296
    JSL $@map_coords.MapIndexMoveRight ; Advance both source and dest map indices one tile right
    PHX 
    LDA $00
    STA $02
    JSL $@map_coords.MapIndexMoveRight
    STX $00
    PLX 
    STX $02
    BRA loc_02A264

  loc_02A296:
    DEC $A0               ; Row counter ($A0) exhausted — entire rectangle copied
    BEQ loc_02A2B6
    LDA $A2               ; Reset column count from stored width ($A2) for next row
    STA $9E
    LDA $1A               ; Restore source row start index ($1A) before moving down
    STA $02
    JSL $@map_coords.MapIndexMoveDown ; MapIndexMoveDown advances both indices to next map row
    STX $00
    STX $1A
    LDA $1E
    STA $02
    JSL $@map_coords.MapIndexMoveDown
    STX $1E
    BRA loc_02A264

  loc_02A2B6:
    PLY 
    PLP 
    RTL 

  loc_02A2B9:
    LDX $02               ; L1 row loop: swap effectLayerTilemap with indirect collision resolve
    SEP #$20
    LDA $effectLayerTilemap, X ; Read effect overlay tile at source map index
    PHA 
    LDX $00
    STA $3E               ; Store tile ID to $3E — LDA [$3E] fetches collision from bank $7F
    LDA [$3E]
    BEQ loc_02A2CE        ; Zero collision result: skip overwrite, preserve existing tile data
    STA $collisionLayer, X

  loc_02A2CE:
    PLA 
    STA $effectLayerTilemap, X ; Always write effectLayerTilemap byte to destination
    REP #$20
    DEC $9E               ; More columns in L1 row — advance indices right
    BEQ loc_02A2ED
    JSL $@map_coords.MapIndexMoveRight
    PHX 
    LDA $00
    STA $02
    JSL $@map_coords.MapIndexMoveRight
    STX $00
    PLX 
    STX $02
    BRA loc_02A2B9

  loc_02A2ED:
    DEC $A0               ; L1 row complete — decrement height and start next row
    BEQ loc_02A30D
    LDA $A2
    STA $9E
    LDA $1A
    STA $02
    JSL $@map_coords.MapIndexMoveDown_L1 ; L1 rows use MapIndexMoveDown_L1 (effect-layer map stride)
    STX $00
    STX $1A
    LDA $1E
    STA $02
    JSL $@map_coords.MapIndexMoveDown_L1
    STX $1E
    BRA loc_02A2B9

  loc_02A30D:
    PLY 
    PLP 
    RTL 
}

---------------------------------------------
; Process queued VRAM tile updates during VBlank.
; 
; Two operating modes based on dmaSkipFlag ($0800):
; 
; 1. Queued mode (dmaSkipFlag nonzero): Saves the current stack pointer, switches SP to $07FF (the VRAM write queue region). Pops address/data pairs in a loop: PLA → VMADDL (VRAM address), PLA → VMDATAL (tile data), until a zero sentinel is reached. Restores SP and clears dmaSkipFlag.
; 
; 2. Direct mode (dmaSkipFlag zero): Sets VMAIN to $80 (word-access sequential increment). Checks tileQueryResult ($0902) — if nonzero, writes two pairs of VRAM address/data words from $0902–$090C to update a single interactive tile query result (4 words = one 2×2 metatile). Clears tileQueryResult after writing.

FlushVramWriteQueue {
    TSX 
    LDY $dmaSkipFlag      ; dmaSkipFlag ($0800) nonzero → stack holds queued VRAM writes
    BEQ loc_02A32F
    REP #$20
    LDA #$07FF            ; TCS: repoint stack to $07FF (VRAM write queue at top of stack page)
    TCS 

  loc_02A31C:
    PLA                   ; Pop loop: PLA=0 is sentinel; else addr→VMADDL, data→VMDATAL
    BEQ loc_02A328
    STA $VMADDL
    PLA 
    STA $VMDATAL
    BRA loc_02A31C

  loc_02A328:
    TXS 
    STZ $dmaSkipFlag      ; Restore caller stack and clear dmaSkipFlag after bulk flush
    SEP #$20
    RTL 

  loc_02A32F:
    TXS 
    LDA #$80              ; Direct path: VMAIN=$80 — word write, auto-increment VRAM addr
    STA $VMAIN
    REP #$20
    LDA $tileQueryResult  ; tileQueryResult ($0902) pending — single interactive 2×2 tile probe
    BEQ loc_02A35D
    STA $VMADDL           ; Write VRAM addr from $0902 + first two tile words ($0904/$0906)
    LDA $0904
    STA $VMDATAL
    LDA $0906
    STA $VMDATAL
    LDA $0908             ; Load second row VRAM addr ($0908) + tile words ($090A/$090C)
    STA $VMADDL
    LDA $090A
    STA $VMDATAL
    LDA $090C
    STA $VMDATAL

  loc_02A35D:
    STZ $tileQueryResult  ; Clear tileQueryResult after direct VRAM update
    SEP #$20
    RTL 
}

---------------------------------------------
; Look up an event block entry from the event_block_table.
; 
; Entry: A = event block index (0-based). Multiplied by 8 (ASL×3) to compute the table offset, stored to $A8 for later row-reset use.
; 
; Validation: Reads byte 0 (scene ID) from event_block_table and compares against sceneCurrent. Returns carry set (SEC) if the scene doesn't match.
; 
; On match: Switches direct page to $0000 and loads all 7 parameter bytes from the table entry into DP variables in 8-bit mode:
;   Byte 7 → $A4 (layer flag)
;   Bytes 5-6 → $9A/$9C (destination X/Y)
;   Bytes 1-2 → $96/$98 (source X/Y)
;   Byte 3 → $A2 and $9E (width, stored twice for reset)
;   Byte 4 → $A0 (height)
; 
; Restores DP, returns carry clear (CLC) on success.

LookupEventBlock {
    ASL                   ; Event index ×8 (ASL×3) — each event_block_table entry is 8 bytes
    ASL 
    ASL 
    TAY 
    STA $00A8             ; Save table byte offset to $A8 for AdvanceEventRow source-X reset
    LDA $&event_block_table, Y ; Byte 0 = scene ID; compare against sceneCurrent
    AND #$00FF
    CMP $sceneCurrent
    BNE loc_02A3A6
    PHD                   ; Scene match — switch DP to $0000 for 8-bit param load
    LDA #$0000
    TCD 
    SEP #$20
    LDA $&event_block_table+7, Y ; Byte 7 → $A4 layer flag (0=L0 map, nonzero=L1 effect)
    STA $A4
    LDA $&event_block_table+5, Y ; Bytes 5-6 → $9A/$9C destination tile X/Y
    STA $9A
    LDA $&event_block_table+6, Y
    STA $9C
    LDA $&event_block_table+1, Y ; Bytes 1-2 → $96/$98 source tile X/Y
    STA $96
    LDA $&event_block_table+2, Y
    STA $98
    LDA $&event_block_table+3, Y ; Byte 3 → $A2 width and $9E column counter (both initialized)
    STA $A2
    STA $9E
    LDA $&event_block_table+4, Y ; Byte 4 → $A0 row counter (height in tiles)
    STA $A0
    PLD 
    REP #$20
    CLC 
    RTL 

  loc_02A3A6:
    SEC                   ; Scene mismatch — SEC/RTL (carry set = skip this event block)
    RTL 
}

---------------------------------------------
; Animated event block tile swap with per-tile VRAM updates.
; 
; Same rectangular tile swap as SwapEventBlockTiles, but queues VRAM updates for each visible tile so the change is visually animated rather than instant.
; 
; The loop structure is more complex than the instant swap:
; - For each tile, after swapping map data, calls QueueVisibleTileVram to check visibility and queue the 2×2 metatile VRAM data
; - When the queue fills up ($0100 bytes = 16 metatiles, indicated by Z flag), writes a zero sentinel to the queue, calls UpdateFrameDialogue to flush the display, then restarts the loop from the current position
; - When a tile is off-screen (carry set from QueueVisibleTileVram), advances to the next tile without queuing
; 
; Layer 0 path: Swaps mapLayerTilemap + collisionLayer, calls QueueVisibleTileVram. Uses pixel positions $1A (X) and $1E (Y) for visibility testing.
; 
; Layer 1 path (code_02A443): Swaps effectLayerTilemap, resolves collision via [$3E] indirect (same as SwapEventBlockTiles). Visibility check compares pixel positions against bg1ScrollV and savedCameraDelta. On-screen tiles have their metatile data expanded from metatileEffectLayer ($7E2800) and queued to the VRAM write buffer with $0800 VRAM offset (BG2 nametable).
; 
; Returns carry set when all tiles are processed, carry clear if interrupted by queue full (caller should retry).

AnimateEventBlock {
    PHX 
    PHD 
    LDA #$0000            ; DP = $0000 — animation state uses zero-page ($96–$A2 range)
    TCD 

  code_02A3AE:
    STA $A6               ; $A6 layer selector: 0 = map layer, 2 = effect layer when $A4 set
    LDA $A4
    AND #$00FF
    BEQ loc_02A3BC
    LDA #$0002
    STA $A6

  loc_02A3BC:
    LDY #$0000

  code_02A3BF:
    LDA $9A               ; Tile coords → pixel coords: ASL×4 on X ($1A) and Y ($1E) for viewport test
    STA $18
    ASL 
    ASL 
    ASL 
    ASL 
    STA $1A
    LDA $9C
    STA $1C
    ASL 
    ASL 
    ASL 
    ASL 
    STA $1E
    LDX $A6
    JSL $@map_coords.TileCoordsToMapIndex ; Compute destination map index from pixel position ($9A/$9C)
    STX $00
    LDA $96
    STA $18
    LDA $98
    STA $1C
    LDX $A6
    JSL $@map_coords.TileCoordsToMapIndex ; Compute source map index from pixel position ($96/$98)
    STX $02
    LDA $A6
    BNE code_02A443

  loc_02A3EF:
    LDX $02               ; L0 animated swap: copy mapLayerTilemap + collisionLayer per tile
    SEP #$20
    LDA $mapLayerTilemap, X
    PHA 
    LDA $collisionLayer, X
    LDX $00
    STA $collisionLayer, X
    PLA 
    STA $mapLayerTilemap, X
    JSR $&QueueVisibleTileVram ; If tile visible, queue 2×2 metatile VRAM data for BG1 nametable
    BCS loc_02A40E        ; Queue full (carry set) — must flush before continuing
    BEQ loc_02A41C        ; Off-screen (BEQ) — skip VRAM queue, advance to next tile

  loc_02A40E:
    REP #$20
    JSR $&AdvanceEventColumn ; Advance column; on row end call AdvanceEventRow
    BCC loc_02A3EF
    JSR $&AdvanceEventRow
    BCS loc_02A439
    BRA code_02A3BF

  loc_02A41C:
    REP #$20
    JSR $&AdvanceEventColumn
    BCC loc_02A428
    JSR $&AdvanceEventRow
    BCS loc_02A439

  loc_02A428:
    LDA #$0000            ; VRAM queue hit $0100 bytes — write zero sentinel at dmaSkipFlag,Y
    STA $dmaSkipFlag, Y
    SEP #$20
    JSL $@system_core.UpdateFrameDialogue ; UpdateFrameDialogue flushes display mid-animation, then restart tile loop
    REP #$20
    JMP $&code_02A3AE

  loc_02A439:
    LDA #$0000
    STA $dmaSkipFlag, Y
    PLD 
    PLX 
    SEC 
    RTL 

  code_02A443:
    LDA $06AC             ; L1 path: setup $3E/$40 collision bank and effect-layer swap loop
    STA $3E
    LDA #$007F
    STA $40
    LDX $02
    SEP #$20
    LDA $effectLayerTilemap, X ; Read effectLayerTilemap at source; resolve collision via [$3E]
    PHA 
    LDX $00
    STA $3E
    LDA [$3E]
    BEQ loc_02A462        ; Zero indirect byte: skip collision write, preserve existing data
    STA $collisionLayer, X

  loc_02A462:
    PLA 
    STA $effectLayerTilemap, X
    REP #$20
    LDA $1A               ; Viewport X: (pixelX+16 − bg1ScrollV) must be < $0111 (273px)
    CLC 
    ADC #$0010
    SEC 
    SBC $bg1ScrollV
    CMP #$0111
    BCS loc_02A4DF
    LDA $savedCameraDelta ; Viewport Y origin: (savedCameraDelta − 16) aligned to 16px ($FFF0 mask)
    SEC 
    SBC #$0010
    AND #$FFF0
    PHA 
    LDA $1E
    SEC 
    SBC $01, S            ; Viewport Y: delta must be 0..$F0 (241px visible height)
    BMI loc_02A4DE
    CMP #$00F1
    BCS loc_02A4DE
    PLA 
    LDA $effectLayerTilemap, X ; On-screen L1 tile: effect metatile index ×8 from tilemap byte
    AND #$00FF
    ASL 
    ASL 
    ASL 
    TAX 
    LDA $metatileEffectLayer, X ; Expand 2×2 metatile from metatileEffectLayer ($7E2800) into queue buffer
    STA $0802, Y
    LDA $7E2802, X        ; Stage four 16-bit VRAM tile words at $0802/$0806/$080A/$080E,Y
    STA $0806, Y
    LDA $7E2804, X
    STA $080A, Y
    LDA $7E2806, X
    STA $080E, Y
    JSL $@map_coords.PixelToVramAddress ; PixelToVramAddress + $0800 → BG2 nametable VRAM write address
    CLC 
    ADC #$0800
    STA $dmaSkipFlag, Y   ; Store VRAM addr to dmaSkipFlag slot; derive +1, +$1F, +$20 sibling addrs
    INC 
    STA $0804, Y
    CLC 
    ADC #$001F
    STA $0808, Y
    INC 
    STA $080C, Y
    TYA 
    CLC 
    ADC #$0010
    TAY 
    CMP #$0100            ; Queue offset Y += $10 per metatile; $0100 = 16 tiles → force mid-frame flush
    BEQ loc_02A4EF
    BRA loc_02A4DF

  loc_02A4DE:
    PLA 

  loc_02A4DF:
    JSR $&AdvanceEventColumn ; L1 column advance; loop until row then restart from code_02A3BF
    BCS loc_02A4E7
    JMP $&code_02A443

  loc_02A4E7:
    JSR $&AdvanceEventRow
    BCS loc_02A503
    JMP $&code_02A3BF

  loc_02A4EF:
    JSR $&AdvanceEventColumn
    BCC loc_02A4F9
    JSR $&AdvanceEventRow
    BCS loc_02A503

  loc_02A4F9:
    LDA #$0000            ; Animation complete — zero dmaSkipFlag sentinel, CLC return
    STA $dmaSkipFlag, Y
    PLD 
    PLX 
    CLC 
    RTL 

  loc_02A503:
    LDA #$0000            ; All tiles processed — zero sentinel, SEC return (done)
    STA $dmaSkipFlag, Y
    PLD 
    PLX 
    SEC 
    RTL 
}

---------------------------------------------
; Check tile visibility and queue metatile VRAM data for DMA update.
; 
; Tests whether a tile at pixel position ($1A, $1E) is within the camera viewport:
; - X check: ($1A + 16 − bg1ScrollH) must be < $0111 (visible horizontal range)
; - Y check: ($1E − (bg2ScrollH − 16, aligned to 16px)) must be >= 0 and < $00F1
; 
; If off-screen: returns carry set (PLP restores processor state). If on-screen: reads the mapLayerTilemap byte at map index X, multiplies by 8 (ASL×3) to index metatileMapLayer ($7E2000). Copies four 16-bit tile words from the metatile definition to the VRAM write queue at $0802+Y (top-left, top-right at +$02/+$06; bottom-left, bottom-right at +$0A/+$0E). Calls PixelToVramAddress to compute the VRAM nametable address, stores to dmaSkipFlag+Y.
; 
; Queue index Y advances by $10 per metatile. Returns carry clear with Z flag set if queue is full ($0100), carry clear with NZ if successfully queued.

QueueVisibleTileVram {
    PHP 
    REP #$20
    LDA $1A               ; Horizontal visibility: (pixelX+16 − bg1ScrollH) < $0111
    CLC 
    ADC #$0010
    SEC 
    SBC $bg1ScrollH
    CMP #$0111
    BCS loc_02A588
    LDA $bg2ScrollH       ; Vertical scroll baseline: bg2ScrollH − 16, snapped to 16px grid
    SEC 
    SBC #$0010
    AND #$FFF0
    PHA 
    LDA $1E
    SEC                   ; Vertical visibility: pixelY − baseline in range 0..$F0
    SBC $01, S
    BMI loc_02A587
    CMP #$00F1
    BCS loc_02A587
    PLA 
    LDA $mapLayerTilemap, X ; Map tile byte ×8 (ASL×3) indexes metatileMapLayer ($7E2000)
    AND #$00FF
    ASL 
    ASL 
    ASL 
    TAX 
    LDA $metatileMapLayer, X ; Copy 2×2 metatile tilemap words to VRAM queue staging ($0802+Y)
    STA $0802, Y
    LDA $7E2002, X
    STA $0806, Y
    LDA $7E2004, X
    STA $080A, Y
    LDA $7E2006, X
    STA $080E, Y
    JSL $@map_coords.PixelToVramAddress ; PixelToVramAddress → BG1 nametable VRAM destination
    STA $dmaSkipFlag, Y   ; Queue VRAM addr + compute three adjacent row addresses for 2×2 write
    INC 
    STA $0804, Y
    CLC 
    ADC #$001F
    STA $0808, Y
    INC 
    STA $080C, Y
    TYA 
    CLC 
    ADC #$0010
    TAY 
    CMP #$0100            ; Queue full at Y=$0100 — return Z=1, X=0 (signals flush to caller)
    BEQ loc_02A582
    PLP 
    CLC 
    RTS 

  loc_02A582:
    PLP 
    LDX #$0000            ; Queue full exit: reset X=0 for AnimateEventBlock restart path
    RTS 

  loc_02A587:
    PLA 

  loc_02A588:
    PLP                   ; Off-screen — SEC/RTS (carry set, caller skips VRAM update)
    SEC 
    RTS 
}

---------------------------------------------
; Advance to the next column within an event block rectangle.
; 
; Decrements the column counter ($9E). If it reaches zero, returns carry set (SEC, row complete). Otherwise: advances pixel X ($1A) by 16, increments both source ($96) and destination ($9A) tile X coordinates, and moves both map indices right via MapIndexMoveRight. Returns carry clear (CLC, more columns remain).

AdvanceEventColumn {
    SEC                   ; AdvanceEventColumn: SEC preset — carry set when $9E reaches 0
    DEC $9E
    BNE loc_02A591
    RTS 

  loc_02A591:
    LDA $1A               ; Next column: pixel X ($1A) += 16, increment source/dest tile X
    CLC 
    ADC #$0010
    STA $1A
    INC $96
    INC $9A
    JSL $@map_coords.MapIndexMoveRight ; MapIndexMoveRight on both destination ($00) and source ($02) indices
    PHX 
    LDA $00
    STA $02
    JSL $@map_coords.MapIndexMoveRight
    STX $00
    PLX 
    STX $02
    CLC                   ; More columns remain — CLC/RTS
    RTS 
}

---------------------------------------------
; Advance to the next row within an event block rectangle.
; 
; Decrements the row counter ($A0). If it reaches zero, returns carry set (SEC, all rows done). Otherwise: advances pixel Y ($1E) by 16, increments both source ($98) and destination ($9C) tile Y coordinates. Reloads the source X coordinate from the original event_block_table entry (indexed by $A8) to reset to the left edge of the rectangle. Resets the column counter ($9E) from the stored width ($A2). Returns carry clear (CLC, more rows remain).

AdvanceEventRow {
    SEC                   ; AdvanceEventRow: SEC preset — carry set when $A0 reaches 0
    DEC $A0
    BNE loc_02A5B7
    RTS 

  loc_02A5B7:
    LDA $1E               ; Next row: pixel Y ($1E) += 16, increment source/dest tile Y
    CLC 
    ADC #$0010
    STA $1E
    INC $98
    INC $9C
    LDX $A8               ; Reload source X from event_block_table+1 via saved offset $A8
    LDA $@event_block_table+1, X
    AND #$00FF
    STA $96
    LDA $@event_block_table+5, X ; Reload destination X from event_block_table+5 (byte at $A8+5)
    AND #$00FF
    STA $9A
    LDA $A2               ; Reset column counter $9E from stored rectangle width $A2
    STA $9E
    CLC 
    RTS 
}