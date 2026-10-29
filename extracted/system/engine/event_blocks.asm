; Event block tile system — runtime map edits (doors, bridges, barriers) driven by event flags (172521–173533, Bank 02).
; 
; An event block copies a rectangle of map tiles from a source position over a destination position, either instantly (CopyEventBlockTiles) or animated with VRAM updates (AnimateEventBlock). Despite its name CopyEventBlockTiles does not exchange the two rectangles: the source is left unchanged.
; 
; === EVENT FLAG INDEXING ===
; 
; ApplyAllEventBlocks walks the 32-byte event flag bitfield at $0A20 (LSR per bit). For every set flag the event index ($04, 8-bit, wraps after 256 indices) goes through LookupEventBlock; when the scene matches, CopyEventBlockTiles runs. Callers: scene_lifecycle and inventory_overlay. Defeated-enemy blocks call LookupEventBlock + CopyEventBlockTiles from actor_execution; COP #32 StageBgChange calls LookupEventBlock and COP #33 ApplyBgChange loops AnimateEventBlock.
; 
; === EVENT BLOCK TABLE FORMAT ===
; 
; LookupEventBlock reads 8-byte entries from event_block_table (index × 8) into WRAM $0096-$00A8 (absolute addresses, used as DP with D = 0):
;   Byte 0: Scene ID — must match sceneCurrent or the entry is skipped (carry set = no match)
;   Bytes 1-2: Source tile X/Y ($96/$98)
;   Byte 3: Width ($A2, and $9E as the column counter); byte 4: height ($A0)
;   Bytes 5-6: Destination tile X/Y ($9A/$9C)
;   Byte 7: Layer flag ($A4) — 0 = layer 0 (mapLayerTilemap + collisionLayer), nonzero = layer 1 (effectLayerTilemap)
; $A8 keeps the entry's byte offset so AdvanceEventRow can reload the start X coordinates.
; 
; === TILE COPY OPERATIONS ===
; 
; 1. CopyEventBlockTiles (instant): nested row/column loop using map_coords.MapIndexMoveRight/MapIndexMoveDown. Layer 0 copies the mapLayerTilemap and collisionLayer bytes. Layer 1 copies effectLayerTilemap and looks the collision byte up through the [$3E] pointer (base $06AC, low byte replaced by the tile ID, bank $7F); the collision byte is written only when the lookup is non-zero.
; 
; 2. AnimateEventBlock (animated): same copy, but each copied tile that is inside the camera window also queues a 2×2 metatile VRAM update. Layer 0 queues through QueueVisibleTileVram (BG1 nametable) and, when the queue is full, flushes inside the routine (UpdateFrameDialogue) and restarts; layer 1 has its own inline copy of the visibility and queue code (BG2 nametable, $0800 offset) and instead returns carry clear when the queue is full so the caller (COP #33) flushes a frame and calls again. Carry set = all tiles done.
; 
; === VRAM WRITE QUEUE ($0800-$08FF) ===
; 
; A queue entry is a pair of words (VRAM word address, tile word); one 2×2 metatile is four entries = $10 bytes, so the queue holds 16 metatiles (Y = $0100 = full). The queue's first word is dmaSkipFlag ($0800): nonzero means entries are pending. A zero address word terminates the list; both animate paths write that terminator at $0800+Y.
; FlushVramWriteQueue (called twice from system_core's frame update) has two modes:
; - Queued mode (dmaSkipFlag nonzero): SP is pointed at $07FF so PLA pops address/tile pairs straight into VMADDL/VMDATAL until the zero terminator; dmaSkipFlag is cleared afterwards.
; - Direct mode (dmaSkipFlag zero): if tileQueryResult ($0902, really the VRAM address of a pending 2×2 metatile update staged by cop_handlers_metatile) is nonzero, writes its two tile rows ($0904/$0906 at $0902, $090A/$090C at $0908), then clears it.
; 
; === VISIBILITY CHECK ===
; 
; A tile is queued only when its pixel position is inside the camera window: (pixelX + 16 − scrollH) < $0111 and (pixelY − ((scrollV − 16) AND $FFF0)) in 0..$F0. Layer 0 and QueueVisibleTileVram use bg1ScrollH / mapScrollV; the layer 1 path uses effectScrollH / effectScrollV.
; QueueVisibleTileVram contract: carry set = off-screen (nothing queued); carry clear and Z set = queue full (the LDX #0 exists only to force Z); carry clear on success, where Z is whatever the caller's flags were (PLP restores them). DrawChestTiles in warps_interaction is its other caller and ignores the result.
; 
; === HELPER ROUTINES ===
; 
; AdvanceEventColumn: decrements the column counter ($9E); carry set when the row is done, otherwise pixel X += 16, source/destination tile X += 1 and both map indices step right.
; AdvanceEventRow: decrements the row counter ($A0); carry set when all rows are done, otherwise pixel Y += 16, tile Y += 1 (both), source X and destination X are reloaded from the original table entry ($A8) and the column counter is reset from $A2.
---------------------------------------------

?BANK 02

?INCLUDE 'event_block_table'
?INCLUDE 'map_coords'
?INCLUDE 'system_core'

!sceneCurrent                   0644
!bg1ScrollH                     068A
!effectScrollH                  068C
!mapScrollV                     068E
!effectScrollV                  0690
!collisionFlagTableL1           06AC
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

; Apply every active event block for the current scene.
; 
; Walks the event flag bitfield at $0A20 in 8-bit chunks (LSR shifts each flag into carry). For each set flag the event index ($04) goes through LookupEventBlock; when the scene matches (carry clear), CopyEventBlockTiles copies the rectangle instantly. The outer loop ends when $04 wraps to zero (256 indices, 32 bytes).
; 
; Saves and restores processor state (PHP/PLP). The bitfield loop is 8-bit; the lookup call switches to 16-bit.

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
    JSL $@CopyEventBlockTiles ; Scene match — instantly copy source rectangle to destination on map

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
; Copy a rectangle of tiles from the source position over the destination position (the source is not modified, so this is a copy, not a swap).
; 
; Entry: parameters at WRAM $0096-$00A4 as loaded by LookupEventBlock, read through DP with D = 0: $96/$98 source X/Y tile, $9A/$9C destination X/Y tile, $9E columns remaining, $A0 rows remaining, $A2 original width, $A4 layer flag (0 = layer 0, nonzero = layer 1).
; 
; Layer 0 path (loc_02A264): per tile, copies mapLayerTilemap and collisionLayer bytes from the source map index ($02) to the destination index ($00); MapIndexMoveRight/MapIndexMoveDown traverse the rectangle.
; 
; Layer 1 path (loc_02A2B9): same traversal on effectLayerTilemap. The collision byte comes from an indirect lookup: $3E/$40 hold the collision flag table pointer ($06AC, bank $7F) and the tile ID replaces the low byte of $3E, so [$3E] returns the table entry for that tile. The collision byte is written only if the entry is non-zero (empty overlay tiles keep the existing collision).

CopyEventBlockTiles {
    PHP 
    PHY 
    REP #$20
    LDA $collisionFlagTableL1 ; Collision indirect pointer: $3E = $06AC base, $40 = bank $7F
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
    LDX $02               ; L0 row loop: copy mapLayerTilemap + collisionLayer from source ($02) to destination ($00)
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
    LDX $02               ; L1 row loop: copy effectLayerTilemap source→dest; collision via [$3E] lookup
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
; Write queued tile updates to VRAM during VBlank.
; 
; 1. Queued mode (dmaSkipFlag nonzero): saves SP, sets SP = $07FF so the first PLA reads word $0800 (dmaSkipFlag itself, the first queued VRAM address). Pops address/tile pairs (PLA → VMADDL, PLA → VMDATAL) until a zero address word, then restores SP and clears dmaSkipFlag.
; 
; 2. Direct mode (dmaSkipFlag zero): VMAIN = $80 (word access, increment after the high byte). If $0902 (tileQueryResult) is nonzero it is the VRAM address of the top row of a 2×2 metatile: tile words $0904/$0906 go there, then $090A/$090C go to the address in $0908. $0902 is cleared afterwards (it is also cleared when it was already zero).

FlushVramWriteQueue {
    TSX 
    LDY $dmaSkipFlag      ; dmaSkipFlag ($0800) nonzero → stack holds queued VRAM writes
    BEQ loc_02A32F
    REP #$20
    LDA #$07FF            ; SP = $07FF: the first PLA reads word $0800 (dmaSkipFlag = first queued VRAM address)
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
    LDA $tileQueryResult  ; $0902 nonzero = a 2×2 metatile update is pending (VRAM address of its top row; staged by cop_handlers_metatile)
    BEQ loc_02A35D
    STA $VMADDL           ; Top row: VRAM address = $0902, then two tile words ($0904, $0906) with auto-increment
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
; Animated event block copy: same rectangle copy as CopyEventBlockTiles, but every copied tile inside the camera window also queues a 2×2 metatile VRAM update so the change appears progressively.
; 
; Layer 0 path (loc_02A3EF): copies mapLayerTilemap + collisionLayer, calls QueueVisibleTileVram with pixel positions $1A (X) / $1E (Y). Carry set (off-screen) advances to the next tile. Z set with carry clear (queue full) advances, writes the zero terminator at $0800+Y, calls UpdateFrameDialogue so the NMI flushes the queue, and restarts from the current tile with Y = 0.
; 
; Layer 1 path (code_02A443): copies effectLayerTilemap, resolves collision through [$3E] like CopyEventBlockTiles, and has its own inline visibility test (effectScrollH / effectScrollV) and queue code (metatileEffectLayer, VRAM address + $0800). When its queue fills and tiles remain it writes the terminator and returns carry clear: the caller must flush a frame and call again.
; 
; Returns carry set when every tile has been processed (terminator written), carry clear when interrupted by a full layer 1 queue. Uses DP = 0 and keeps all progress in $96-$A8, so a repeated call resumes where it stopped.

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
    BCS loc_02A40E        ; Carry set = tile off-screen, nothing queued: just advance to the next tile
    BEQ loc_02A41C        ; Z set (carry clear) = queue full after queuing this tile: advance, then flush and restart

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
    LDA $collisionFlagTableL1 ; L1 path: setup $3E/$40 collision bank and effect-layer swap loop
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
    LDA $1A               ; L1 viewport X: (pixelX + 16 − effectScrollH) must be < $0111 (273 px)
    CLC 
    ADC #$0010
    SEC 
    SBC $effectScrollH
    CMP #$0111
    BCS loc_02A4DF
    LDA $effectScrollV    ; L1 viewport Y baseline: (effectScrollV − 16) AND $FFF0
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
    STA $dmaSkipFlag, Y   ; VRAM address into queue slot $0800+Y; the other three entries get +1, +$20, +$21 (2×2 on a 32-wide nametable)
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
    LDA #$0000            ; L1 queue full, tiles remain: write the zero terminator and return CLC (caller flushes a frame and calls again)
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
; Queue the 2×2 metatile VRAM update for the tile at pixel position ($1A, $1E) if it is inside the camera window. Layer 0 only: X = map index of the tile in mapLayerTilemap, Y = queue offset (JSR, same bank).
; 
; Window test: (pixelX + 16 − bg1ScrollH) < $0111, and (pixelY − ((mapScrollV − 16) AND $FFF0)) in 0..$F0.
; 
; On-screen: reads the mapLayerTilemap byte, ×8 indexes metatileMapLayer ($7E2000), copies its four tile words to $0802/$0806/$080A/$080E + Y, and stores PixelToVramAddress (BG1 nametable) and the +1 / +$20 / +$21 neighbours as the four address words ($0800/$0804/$0808/$080C + Y). Y advances by $10 per metatile.
; 
; Returns: carry set = off-screen; carry clear + Z set = queue full (Y reached $0100, LDX #0 forces Z); carry clear otherwise (Z is inherited from the caller's flags). Also used by DrawChestTiles in warps_interaction.

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
    LDA $mapScrollV       ; Vertical scroll baseline: mapScrollV − 16, snapped to 16px grid
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
    STA $dmaSkipFlag, Y   ; VRAM address into queue slot $0800+Y; the other three entries get +1, +$20, +$21
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
    CMP #$0100            ; Y reached $0100 = queue full (16 metatiles)
    BEQ loc_02A582
    PLP 
    CLC 
    RTS 

  loc_02A582:
    PLP 
    LDX #$0000            ; Queue full: LDX #0 forces Z=1 for the caller's BEQ (X is not used afterwards; restart recomputes map indices) (inferred)
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
; Advance to the next row of the event block rectangle.
; 
; Decrements the row counter ($A0); carry set (SEC) when all rows are done. Otherwise: pixel Y ($1E) += 16, source ($98) and destination ($9C) tile Y += 1, source X ($96) and destination X ($9A) are reloaded from the original event_block_table entry (offset kept in $A8, bytes +1 and +5), and the column counter ($9E) is reset from the width ($A2). Returns carry clear (more rows).

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