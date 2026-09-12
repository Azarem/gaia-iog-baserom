; Sprite composition, depth sorting, OAM table construction, and render list management (247295–248565 + 252010–252033, Bank 03).
; 
; Implements the complete pipeline for converting actor metasprite definitions into the hardware OAM table each frame. The system processes the actor linked list in four stages: render list clearing, depth sorting, metasprite decomposition, and OAM table packing.
; 
; === RENDER LIST CLEARING (ClearActorRenderList, 252010) ===
; 
; ClearActorRenderList zeroes the 512-byte depth-sort bucket array at $0200–$03FE and writes a $FFFF end sentinel at $0400, preparing it for the next frame's SortActorsByDepth pass. Called from the main game loop before actor processing begins.
; 
; === DEPTH SORTING (SortActorsByDepth) ===
; 
; Uses a bucket sort algorithm with the $0200–$03FE WRAM region as a bucket array indexed by sort key. Each actor's screen-space Y position is converted to an inverted sort key (higher Y = lower key = rendered first = behind). The stack pointer is repurposed to iterate the sort buffer efficiently via PLX/PLA.
; 
; Sort key assignment based on actor flags ($10):
; - Bit 13 ($2000): Actor hidden — skipped entirely
; - Bits 0+1 ($0003) both clear: Y-based depth key (screen Y inverted via EOR, doubled via ASL)
; - Bit 0 only ($0001): Fixed key $01FE — always rendered in front
; - Bit 1 ($0002): Fixed key $0000 — always rendered behind
; 
; BuildFinalList reads the bucket array front-to-back via PLY (SP set to $01FF), producing the final depth-sorted actor list at $0C00.
; 
; === SPRITE COMPOSITION (ComposeAllSprites) ===
; 
; Entry point called from the main game loop after actor execution. Pre-fills the entire 128-entry OAM table with off-screen values ($E080 = hidden), then processes two sprite sources:
; 1. Compose buffer at $7F3100 (pre-composed sprites from damage digits, VFX)
; 2. Sorted actor list at $0C00 (metasprite decomposition per actor)
; 
; For each actor, dispatches to DecomposeActorMetasprites (generic) or DecomposePlayerSprites (player, identified by bit 15 of $10).
; 
; === OAM TABLE LAYOUT ===
; 
; SNES OAM: 128 entries × 4 bytes at $0422–$0621, plus a 32-byte high table starting at ($06). Each low-table entry: byte 0 = X[7:0], byte 1 = Y, bytes 2-3 = tile/attribute. The high table packs 2 bits per sprite (X bit 8, size flag) into groups of 4 via a rolling shift register ($00) with a 4-sprite counter ($0E).
; 
; === METASPRITE FORMAT ===
; 
; 7 bytes per sub-sprite in a metasprite definition:
; - Byte 0: Size/priority flags (bit 0 → OAM hi-table size bit)
; - Bytes 1-2: X offset pair (swapped via XBA when H-mirrored)
; - Bytes 3-4: Y offset pair (swapped via XBA when H-mirrored)
; - Bytes 5-6: Tile index + palette/priority attributes
; 
; H-mirror is determined by the carry from ASL on sprite field $04 ($000E,X). When carry is set, X/Y offset bytes are swapped and tile flip bits are EOR'd.
; 
; === PLAYER SPRITE HANDLING ===
; 
; DecomposePlayerSprites adds character-form body table lookups, VRAM tile index remapping (player tiles are dynamically DMA'd), and sprite cache validation ($09CC/$09CE) to avoid redundant VRAM updates when the metasprite pointer and bank haven't changed.
; 
; === COMPOSE BUFFER ($7F3100) ===
; 
; Pre-composed sprite buffer for systems that generate sprites outside the metasprite pipeline (damage digits, visual effects). Each entry: X position (2B) + Y position (2B) + tile/attribute (2B). RenderComposeBuffer processes this before the actor metasprite loop.
; 
; === ANIMATION (UpdateActorAnimation) ===
; 
; Indexes into the spriteset → animation → frame hierarchy to advance an actor's current animation. Returns carry set on sequence end (negative frame data), signaling the actor to loop or transition.
---------------------------------------------

?BANK 03

?INCLUDE 'body_table'

!deathFlag                      0200
!bg1ScrollH                     068A
!bg2ScrollH                     068E
!layerPriorityFlag              06EE
!playerFlags                    09AE
!displayModeFlags               09EC
!characterForm                  0AD4
!spritesetPtr                   7F0006
!metaspritePtr                  7F000C
!animScratch2                   7F000E
!iframeCounter                  7F0028
!oamComposeBuffer               7F3100

---------------------------------------------

; Clear the depth-sort bucket array at $0200 in preparation for the next frame.
; 
; Zeroes 512 bytes ($0200–$03FE, 256 words) and writes $FFFF as an end sentinel at $0400. This array is used by SortActorsByDepth as bucket storage for the Y-position depth sort.

ClearActorRenderList {
    PHP                   ; Zero 512 bytes ($0200–$03FE) of depth-sort bucket array
    REP #$20
    LDX #$0000
    TXA 

  loc_03D871:
    STA $deathFlag, X
    INX 
    INX 
    CPX #$0200
    BNE loc_03D871
    DEC                   ; Write $FFFF end sentinel at $0400
    STA $deathFlag, X
    PLP 
    RTL 
}
---------------------------------------------

; Depth-sort all on-screen actors into the render list at $0C00 using bucket sort.
; 
; Iterates the actor linked list ($0058 head → $04 next). For each actor, performs screen-bounds culling on both axes (X range 0–$100 against bg1ScrollH, Y range 0–$E0 against bg2ScrollH), accounting for actor dimensions ($18/$1C offset, $1A/$1E size). Off-screen actors get flag $4000 set in $10 via SortActors_OffScreen.
; 
; On-screen actors receive a depth sort key based on flags ($10):
; - Bit 13 ($2000): hidden — skipped, no buffer entry
; - Bits 0-1 ($0003) both clear: Y-based key = (screenY EOR $FF) ASL → back-to-front order
; - Bit 0 only: key $01FE → always rendered in front of Y-sorted actors
; - Bit 1: key $00FF EOR $FF ASL = $0000 → always rendered behind
; 
; Actor slot IDs and sort keys are written as 4-byte pairs to $0C00,Y. After all actors are processed, falls through to SortActors_BuildFinalList.

SortActorsByDepth {
    PHP 
    PHD 
    REP #$20
    LDY #$0000
    LDA $0058             ; Head of actor linked list → TAX/TCD sets DP per actor

  code_03C609:
    TAX 
    TCD 
    BNE loc_03C610
    JMP $&SortActors_BuildFinalList

  loc_03C610:
    LDA $14               ; Left-edge screen X = posX − originX − bg1ScrollH
    SEC 
    SBC $18
    SEC 
    SBC $bg1ScrollH
    CMP #$0100
    BCC loc_03C631
    BMI loc_03C623
    JMP $&SortActors_OffScreen

  loc_03C623:
    LDA $14               ; Left edge off-screen left: check right edge (posX + width)
    CLC 
    ADC $1C
    SEC 
    SBC $bg1ScrollH
    CMP #$0100
    BCS SortActors_OffScreen

  loc_03C631:
    LDA $16               ; Top-edge screen Y = posY − originY − bg2ScrollH
    SEC 
    SBC $1A
    SEC 
    SBC $bg2ScrollH
    CMP #$00E0
    BCC loc_03C64F
    BPL SortActors_OffScreen
    LDA $16               ; Top edge off-screen top: check bottom edge (posY + height)
    CLC 
    ADC $1E
    SEC 
    SBC $bg2ScrollH
    CMP #$00E0
    BCS SortActors_OffScreen

  loc_03C64F:
    LDA $10               ; Sort key selection from actor flags ($10)
    BIT #$2000            ; $2000: hidden — skip without creating buffer entry
    BNE loc_03C687
    BIT #$0003            ; $0003: depth override (0=Y-based, 1=front, 2=back)
    BEQ loc_03C665
    BIT #$0002
    BNE loc_03C670
    LDA #$01FE            ; Bit 0 only → key $01FE: always rendered in front
    BRA loc_03C677

  loc_03C665:
    LDA $16               ; Y-based key: compute from screen Y position
    SEC 
    SBC $bg2ScrollH
    CMP #$0100
    BCC loc_03C673

  loc_03C670:
    LDA #$00FF            ; Bit 1 → $00FF → after EOR+ASL = $0000: always behind

  loc_03C673:
    EOR #$00FF            ; Invert (high Y → low key = drawn first = behind) and double for word align
    ASL 

  loc_03C677:
    CMP #$0200            ; Guard: key < $0200 always holds given 8-bit Y clamping
    BCS loc_03C677
    STA $0C00, Y          ; Write 4-byte sort entry: key + actor slot ID to $0C00,Y
    TXA 
    STA $0C02, Y
    INY 
    INY 
    INY 
    INY 

  loc_03C687:
    LDA #$4000            ; Clear previous-frame off-screen flag ($4000), advance via next-ptr ($04)
    TRB $10
    LDA $04
    JMP $&code_03C609
}

---------------------------------------------
; Mark an actor as off-screen during depth sort processing.
; 
; Sets bit 14 ($4000) in the actor's primary flags ($10) via TSB, then continues to the next actor in the linked list via $04.

SortActors_OffScreen {
    LDA #$4000
    TSB $10
    LDA $04
    JMP $&code_03C609
}

---------------------------------------------
; Build the final depth-sorted actor list from the bucket sort buffer.
; 
; Phase 1 — Bucket insertion: Sets SP to $0BFF to iterate the $0C00 sort buffer via PLX/PLA. For each entry, uses the sort key as an index into the $0200–$03FE bucket array. Each bucket holds a linked list of 4-byte nodes (actor slot word + next pointer word) allocated from a sequential pool starting at $0422.
; 
; Phase 2 — Linearization: Sets SP to $01FF to iterate the bucket array front-to-back via PLY. Empty buckets (zero) are skipped. Each non-empty bucket's linked list is traversed and the actor slot IDs are written sequentially to $0C00,X, producing the final render-order list. Terminated with STZ.
; 
; Restores original SP, DP, and processor state before returning via RTL.

SortActors_BuildFinalList {
    LDA #$FFFF            ; $FFFF sentinel terminates sort buffer
    STA $0C00, Y
    LDA #$0000
    TCD 
    LDA #$0422            ; Node pool pointer — 4-byte nodes allocated from $0422 upward
    STA $02
    TSC 
    STA $00
    LDA #$0BFF            ; SP=$0BFF: PLX/PLA iterate $0C00 sort buffer front-to-back
    TCS 

  loc_03C6B1:
    PLX                   ; Pop sort key — $FFFF sentinel sets N flag, ending phase 1
    BMI loc_03C6EB
    LDY $deathFlag, X     ; Bucket lookup: $0200 + sort_key → zero = new, nonzero = chain head
    BNE loc_03C6D3
    LDA $02
    STA $deathFlag, X
    TAY 
    PLA                   ; Pop actor slot, store as first node with null next-pointer
    STA $0000, Y
    LDA #$0000
    STA $0002, Y
    LDA $02
    CLC 
    ADC #$0004
    STA $02
    BRA loc_03C6B1

  loc_03C6D3:
    LDA $02               ; Existing chain: allocate new head node, link old head as next
    STA $deathFlag, X
    TAX 
    PLA 
    STA $0000, X
    TYA 
    STA $0002, X
    LDA $02
    CLC 
    ADC #$0004
    STA $02
    BRA loc_03C6B1

  loc_03C6EB:
    LDA #$01FF            ; Phase 2: SP=$01FF — PLY pops bucket array $0200+ in sort order
    TCS 
    LDX #$0000
    BRA loc_03C6F6

  loc_03C6F4:
    PHA                   ; PHA+PLA no-op: timing delay between chain traversals
    PLA 

  loc_03C6F6:
    PLY                   ; Pop next bucket — zero = empty (retry), negative = done
    BEQ loc_03C6F6
    BMI loc_03C70B

  loc_03C6FB:
    LDA $0000, Y          ; Traverse chain: copy actor slot IDs to final $0C00 render list
    STA $0C00, X
    INX 
    INX 
    LDA $0002, Y
    BEQ loc_03C6F4
    TAY 
    BRA loc_03C6FB

  loc_03C70B:
    STZ $0C00, X          ; Zero-terminate render list
    LDA $00
    TCS 
    PLD 
    PLP 
    RTL 
}

---------------------------------------------
; Main per-frame sprite composition entry point — builds the complete OAM table.
; 
; Pre-fills all 128 OAM entries with off-screen position ($E080) by pushing $E080 × 256 words onto a temporary stack at $0621. Then processes two sprite sources:
; 
; 1. RenderComposeBuffer: converts pre-composed sprites from $7F3100 to OAM entries
; 2. Sorted actor list ($0C00): for each actor, calls DecomposeActorMetasprites to expand metasprite definitions into individual OAM entries
; 
; OAM state: $08 points to hi-table write position ($06FE), $06 points to current hi-table byte ($0622), $0E counts sprites within the current hi-table group (4 per byte). The compose buffer cursor ($00D8) is cleared before actor processing.
; 
; When the actor list is exhausted (zero entry) or OAM is full (carry set from decomposition), finalizes the hi-table remainder by shifting and storing the last partial byte.

ComposeAllSprites {
    PHP 
    REP #$20
    LDA #$06FE            ; OAM hi-table staging pointer at $06FE
    STA $08
    STZ $06FF
    STZ $070F
    STZ $14               ; Zero player tile DMA counter
    LDA $bg1ScrollH       ; Screen X origin = bg1ScrollH − 16px margin
    SEC 
    SBC #$0010
    STA $1A
    LDA $bg2ScrollH
    SEC 
    SBC #$0010
    STA $1E
    LDA #$0622
    STA $06
    LDA #$0004
    STA $0E
    TSC 
    STA $00
    LDA #$0621            ; SP=$0621 for stack-based OAM pre-fill
    TCS 
    LDX #$0010            ; 16 outer × 16 inner PHA = 256 words fills all 128 OAM entries
    LDA #$E080            ; $E080: off-screen default (X=$E0 wraps left, Y=$80 below visible)

  loc_03C74D:
    PHA 
    PHA 
    PHA 
    PHA 
    PHA 
    PHA 
    PHA 
    PHA 
    PHA 
    PHA 
    PHA 
    PHA 
    PHA 
    PHA 
    PHA 
    PHA 
    DEX 
    BNE loc_03C74D
    LDA $00
    TCS 
    JSR $&RenderComposeBuffer
    STZ $00D8             ; Clear compose buffer cursor before actor sprite processing
    LDX #$0000

  loc_03C76C:
    LDA $0C00, X          ; Iterate sorted render list — zero entry = end of list
    BEQ loc_03C77D
    INX 
    INX 
    PHX 
    TAX                   ; X = actor slot ID for metasprite decomposition
    JSR $&DecomposeActorMetasprites
    PLX 
    BCC loc_03C76C        ; Carry clear = OAM not full, continue; carry set = bail out
    BRA loc_03C789

  loc_03C77D:
    SEP #$20              ; Render list done: flush remaining hi-table bits to partial byte
    LDA $00

  loc_03C781:
    LSR 
    LSR 
    DEC $0E
    BNE loc_03C781
    STA ($06)

  loc_03C789:
    PLP 
    RTL 
}

---------------------------------------------
; Render pre-composed sprites from the compose buffer ($7F3100) into OAM.
; 
; Two rendering modes based on layerPriorityFlag bit 12 ($1000):
; 
; Normal mode (bit clear): Iterates the compose buffer (6 bytes per entry). For each entry, subtracts scroll offsets to convert to screen coordinates, bounds-checks Y (< $F0) and X (< $110), and writes to OAM low table ($0422,Y) with hi-table bit packing. Entries are consumed in groups of 6 bytes (X += 6), OAM advances by 4 bytes (Y += 4).
; 
; Layer priority mode (bit set): Block-copies compose buffer data directly to OAM via MVN $00,$7F. Copies min($00DA, $0200) bytes from $7F0600 to $0422. Then computes the hi-table byte count ($00DA >> 4) and packs the remaining hi-table state from the transfer count.

RenderComposeBuffer {
    LDX #$0000
    TXY 
    LDA $layerPriorityFlag ; Check layer priority flag for rendering mode
    BIT #$1000            ; Bit 12: layer priority mode → MVN block-copy path
    BNE loc_03C7F0

  loc_03C797:
    LDA $oamComposeBuffer, X ; Compose buffer X word — negative = end of buffer
    BPL loc_03C79E
    RTS 

  loc_03C79E:
    LDA $7F3102, X        ; Screen Y = bufferY − bg2ScrollH; skip if ≥ $F0
    SEC 
    SBC $bg2ScrollH
    CMP #$00F0
    BCS loc_03C7E8
    STA $0423, Y
    LDA $7F3104, X
    STA $0424, Y
    LDA $oamComposeBuffer, X ; Screen X = bufferX − bg1ScrollH; skip if ≥ $110
    SEC 
    SBC $bg1ScrollH
    CMP #$0110
    BCS loc_03C7E8
    SEP #$20
    STA $0422, Y
    XBA                   ; Hi-table packing: X[8] via XBA+LSR+ROR, size=0 via CLC+ROR into $00
    LSR 
    ROR $00
    CLC 
    ROR $00
    DEC $0E
    BNE loc_03C7DC
    LDA $00               ; Every 4th sprite: flush packed byte to hi-table at ($06)
    STA ($06)
    INC $06
    LDA #$04
    STA $0E

  loc_03C7DC:
    REP #$20
    INY 
    INY 
    INY 
    INY 
    CPY #$0200
    BNE loc_03C7E8
    RTS 

  loc_03C7E8:
    INX 
    INX 
    INX 
    INX 
    INX 
    INX 
    BRA loc_03C797

  loc_03C7F0:
    LDA $00DA             ; Priority mode: block-copy $00DA sprites from $7F0600 to OAM
    BNE loc_03C7F6
    RTS 

  loc_03C7F6:
    LDX #$0600
    LDY #$0422
    LDA $00DA
    BIT #$FE00            ; Clamp to $0200 bytes max (128 OAM entries)
    BEQ loc_03C807
    LDA #$0200

  loc_03C807:
    DEC 
    PHB 
    MVN #$00, #$7F        ; MVN block transfer: $7F (WRAM upper) → $00 (main RAM)
    PLB 
    LDA $00DA
    LSR                   ; Hi-table byte count = sprite count >> 4
    LSR 
    LSR 
    LSR 
    STA $0E
    LDA $00DA
    LSR 
    AND #$0006
    STA $00
    SEP #$20

  loc_03C821:
    DEC $0E
    BMI loc_03C82D
    LDA #$AA              ; $AA = %10101010: all 4 sprites large-size, X[8]=0
    STA ($06)
    INC $06
    BRA loc_03C821

  loc_03C82D:
    LDY $00DA
    LDX $00
    LDA $@OamHiTableMasks, X ; OamHiTableMasks: pre-computed partial-byte mask for leftover sprites
    STA $00
    LDA $@OamHiTableMasks+1, X
    STA $0E
    REP #$20
    RTS 
}

---------------------------------------------
; 8-byte lookup table for OAM high-table bit packing.
; 
; Provides pre-computed mask pairs used to finalize partial hi-table bytes when the compose buffer sprite count doesn't align to a 4-sprite boundary. Indexed by ($00DA LSR AND $06) — the number of leftover sprites mod 4, doubled for word access.

OamHiTableMasks #00048003A002A801

---------------------------------------------
; Expand a generic actor's metasprite definition into individual OAM entries.
; 
; Switches DBR to the actor's sprite bank ($7F0008,X). Computes screen-relative position by subtracting scroll offsets ($1A, $1E) from the actor's world position minus origin ($14-$18, $16-$1A). Loads the sprite field ($000E,X → $04) for H-mirror detection.
; 
; Iframe blinking: if the actor has a nonzero iframe counter ($7F0028,X) and it's an odd frame (LSR carry set), sets palette override $02 = $0E00 to produce the invincibility flash effect.
; 
; Dispatches to DecomposePlayerSprites if bit 15 ($8000) of $10 is set (player actor).
; 
; For generic actors: reads the metasprite pointer ($7F000C,X + 8), extracts the sub-sprite count from byte 0, then iterates each 7-byte sub-sprite entry. For each sub-sprite:
; 1. Y offset: read bytes 3-4 (XBA if H-mirrored), add screen Y ($1C), bounds-check < $F0
; 2. Tile/attribute: read bytes 5-6, EOR with flip field ($04), OR with palette override ($02)
; 3. X offset: read bytes 1-2 (XBA if H-mirrored), add screen X ($18), bounds-check < $110
; 4. Write OAM low-table entry and pack hi-table bits
; 5. Advance to next sub-sprite (+7 bytes) or bail if OAM full (Y = $0200)
; 
; Off-screen sub-sprites get $E080 written to their OAM slot (hidden).

DecomposeActorMetasprites {
    PHB 
    SEP #$20
    LDA $7F0008, X        ; Set DBR to actor's sprite bank for absolute addressing
    PHA 
    PLB 
    REP #$20
    LDA $0014, X          ; Screen X = actorX − originX − scrollOffsetX ($1A)
    SEC 
    SBC $0018, X
    SEC 
    SBC $1A
    STA $18
    LDA $0016, X          ; Screen Y = actorY − originY − scrollOffsetY ($1E)
    SEC 
    SBC $001A, X
    SEC 
    SBC $1E
    STA $1C
    LDA $000E, X          ; Sprite field → $04: high bit carries H-mirror for ASL tests
    STA $04
    STZ $02               ; Clear palette override (set to $0E00 later if iframe-blinking)
    LDA $0010, X          ; Check actor flags for visibility and iframe state
    BIT #$0080            ; $0080: actor visible — if clear, skip to player/generic dispatch
    BEQ loc_03C896
    BIT #$0010            ; $0010: damage-immune — skip iframe blink check
    BNE loc_03C896
    BIT #$0400
    BNE loc_03C885

  loc_03C885:
    LDA $iframeCounter, X ; Iframe blink: nonzero counter + odd frame → flash palette $0E00
    BEQ loc_03C893
    LSR 
    BCC loc_03C893
    LDA #$0E00
    STA $02

  loc_03C893:
    LDA $0010, X

  loc_03C896:
    BIT #$8000            ; Bit 15: player actor → DecomposePlayerSprites
    BPL loc_03C89E
    JMP $&DecomposePlayerSprites

  loc_03C89E:
    LDA $metaspritePtr, X ; Skip 8-byte metasprite header to sub-sprite array
    CLC 
    ADC #$0008
    TAX 
    LDA $0000, X          ; Byte 0 = sub-sprite count
    AND #$00FF
    INX 
    STA $10

  loc_03C8B0:
    LDA $04               ; ASL $04 → carry = H-mirror: swap Y offset bytes 3-4 via XBA
    ASL 
    LDA $0003, X
    BCC loc_03C8B9
    XBA 

  loc_03C8B9:
    AND #$00FF            ; Y offset + screen Y; off-screen sub-sprite if ≥ $F0
    CLC 
    ADC $1C
    CMP #$00F0
    BCS loc_03C920
    SBC #$0010            ; Subtract 16px for SNES sprite origin offset
    STA $0423, Y
    LDA $0005, X          ; Tile word: EOR flip flags ($04), OR iframe palette ($02)
    EOR $04
    ORA $02
    STA $0424, Y
    LDA $04               ; Double-ASL $04 → carry = H-mirror: swap X offset bytes 1-2
    ASL 
    ASL 
    LDA $0001, X
    BCC loc_03C8DE
    XBA 

  loc_03C8DE:
    AND #$00FF            ; X offset + screen X; off-screen if ≥ $110
    CLC 
    ADC $18
    CMP #$0110
    BCS loc_03C920
    SBC #$000F
    SEP #$20
    STA $0422, Y
    XBA                   ; Hi-table: X[8] via XBA+LSR+ROR, size from byte 0 LSR+ROR → $00
    LSR 
    ROR $00
    LDA $0000, X
    LSR 
    ROR $00
    DEC $0E
    BNE loc_03C909
    LDA $00               ; Flush packed hi-table byte every 4 sprites
    STA ($06)
    INC $06
    LDA #$04
    STA $0E

  loc_03C909:
    REP #$20
    INY 
    INY 
    INY 
    INY 
    CPY #$0200            ; OAM full at 128 entries ($0200 bytes)
    BEQ loc_03C91E

  loc_03C914:
    TXA 
    CLC 
    ADC #$0007            ; +7 to next sub-sprite; decrement count
    TAX 
    DEC $10
    BNE loc_03C8B0

  loc_03C91E:
    PLB 
    RTS 

  loc_03C920:
    LDA #$E080            ; $E080: hide off-screen sub-sprite in OAM
    STA $0422, Y
    BRA loc_03C914
}

---------------------------------------------
; Expand the player character's metasprite into OAM entries with VRAM tile remapping.
; 
; Calls CheckPlayerSpriteCache to detect metasprite/bank changes. Loads the character form ($0AD4) and computes a body table index (form × 6 via ASL+ADC+ASL). If playerFlags bit 15 is set (transformation/override), uses animScratch2 ($7F000E,X) directly as the body table index instead.
; 
; From the body table: reads the VRAM tile base offset into $06FC and the tile count into ($08). Then reads the metasprite at the cached pointer ($09CC + 8) and iterates sub-sprites similarly to DecomposeActorMetasprites, with two additions:
; 
; 1. VRAM tile remapping: each sub-sprite's tile index is multiplied by 32 (AND $01FF, ASL ×5) and added to $06FC to produce the actual VRAM tile address, written to the ($08) tile pointer table for DMA.
; 2. Tile counter tracking ($14): incremented by 2 per sub-sprite. When bit 4 ($0010) is set (16 tiles), adds $10 to skip to the overflow VRAM region.
; 
; On completion, writes $0000 to ($08) as a tile list terminator.

DecomposePlayerSprites {
    JSR $&CheckPlayerSpriteCache
    LDA $playerFlags      ; Bit 15 of playerFlags: override mode uses animScratch2 as body index
    BPL loc_03C936
    LDA $animScratch2, X
    BRA loc_03C93F

  loc_03C936:
    LDA $characterForm    ; Normal: body table index = characterForm × 6 (ASL+ADC+ASL)
    ASL 
    CLC 
    ADC $characterForm
    ASL 

  loc_03C93F:
    TAX 
    LDA $@body_table+3, X ; Body table +3: VRAM tile base offset → $06FC
    STA $06FC
    LDA $@body_table+5, X ; Body table +5: tile DMA count → tile pointer list at ($08)
    AND #$00FF
    STA ($08)
    INC $08
    LDA $09CC             ; Cached metasprite ($09CC) + 8 → sub-sprite array
    CLC 
    ADC #$0008
    TAX 
    LDA $0000, X
    AND #$00FF
    INX 
    STA $10

  code_03C963:
    LDA $04
    ASL 
    LDA $0003, X
    BCC loc_03C96C
    XBA 

  loc_03C96C:
    AND #$00FF
    CLC 
    ADC $1C
    CMP #$00F0
    BCC loc_03C97A
    JMP $&PlayerSprite_OffScreen

  loc_03C97A:
    SBC #$0010
    STA $0423, Y
    LDA $0005, X
    EOR $04
    ORA $02
    PHA 
    AND #$01FF            ; VRAM remap: (tile AND $01FF) × 32 + base → DMA list at ($08)
    ASL 
    ASL 
    ASL 
    ASL 
    ASL 
    ADC $06FC
    STA ($08)
    INC $08
    INC $08
    PLA 
    AND #$FE00            ; Recombine attribute bits (palette/priority) with sequential VRAM index
    ORA $14
    STA $0424, Y
    LDA $14               ; Tile counter +=2; at 16 tiles, skip +$10 to overflow VRAM region
    INC 
    INC 
    BIT #$0010
    BEQ loc_03C9AF
    CLC 
    ADC #$0010

  loc_03C9AF:
    STA $14
    LDA $04
    ASL 
    ASL 
    LDA $0001, X
    BCC loc_03C9BB
    XBA 

  loc_03C9BB:
    AND #$00FF
    CLC 
    ADC $18
    CMP #$0110
    BCS PlayerSprite_OffScreen
    SBC #$000F
    SEP #$20
    STA $0422, Y
    XBA 
    LSR 
    ROR $00
    LDA $0000, X
    LSR 
    ROR $00
    DEC $0E
    BNE loc_03C9E6
    LDA $00
    STA ($06)
    INC $06
    LDA #$04
    STA $0E

  loc_03C9E6:
    REP #$20
    INY 
    INY 
    INY 
    INY 
    CPY #$0200
    BEQ loc_03C9FE

  loc_03C9F1:
    TXA 
    CLC 
    ADC #$0007
    TAX 
    DEC $10
    BEQ loc_03C9FE
    JMP $&code_03C963

  loc_03C9FE:
    LDA #$0000            ; Zero-terminate tile DMA pointer list
    STA ($08)
    PLB 
    RTS 
}

---------------------------------------------
; Handle player sprite being off-screen during decomposition.
; 
; Sets bit 2 ($0004) in playerFlags to flag the player as off-screen, and bit 3 ($0008) in displayModeFlags to request a VRAM refresh on next visible frame. Writes $E080 to the current OAM slot to hide the sprite, then continues processing remaining sub-sprites.

PlayerSprite_OffScreen {
    LDA #$0004            ; Set playerFlags bit 2: player off-screen
    TSB $playerFlags
    LDA #$0008            ; Set displayModeFlags bit 3: request VRAM refresh on return
    TSB $displayModeFlags
    LDA #$E080            ; $E080: hide sprite in OAM
    STA $0422, Y
    BRA loc_03C9F1
}

---------------------------------------------
; Check whether the player's sprite data needs VRAM re-upload.
; 
; Compares the current metasprite pointer ($7F000C,X) and sprite bank ($7F0008,X) against cached values at $09CC and $09CE. If both match and the force-redraw flag (bit 2 $0004 in playerFlags) is not set, returns the cached pointer — no VRAM update needed.
; 
; On cache miss: clears the force-redraw flag, stores the new pointer and bank to $09CC/$09CE, and sets bit 3 ($0008) in displayModeFlags to trigger a player tile DMA during the next VBlank.

CheckPlayerSpriteCache {
    LDA $playerFlags
    BIT #$0004            ; Force-redraw flag (bit 2): bypass cache if set
    BNE loc_03CA37
    LDA $metaspritePtr, X ; Compare metasprite pointer and bank against $09CC/$09CE cache
    CMP $09CC
    BNE loc_03CA37
    LDA $7F0008, X
    CMP $09CE
    BNE loc_03CA37
    LDA $09CC
    RTS 

  loc_03CA37:
    LDA $playerFlags      ; Cache miss: clear force-redraw flag, update cache values
    AND #$FFFB
    STA $playerFlags
    LDA $7F0008, X
    STA $09CE
    LDA $metaspritePtr, X
    STA $09CC
    LDA #$0008            ; Set displayModeFlags bit 3: trigger player tile DMA in VBlank
    TSB $displayModeFlags
    RTS 
}

---------------------------------------------
; Advance an actor's animation frame and update metasprite/bounding box pointers.
; 
; Switches DBR to the actor's sprite bank ($7F0008,X). Indexes into the spriteset table at entry $28 (animation set), then indexes frame $2A within that animation (×4 for 4-byte frame entries).
; 
; If the frame data word is negative (BMI), the animation has ended: resets $2A to 0 and returns with carry SET to signal the caller.
; 
; Otherwise, updates the metasprite pointer ($7F000C,X) to the frame's sprite data (+ 4 for the sub-sprite array). Reads X/Y bounding box offset pairs from the frame header, sign-extending bytes via $0080 check and ORA $FF00. The H-mirror flag from $0E (carry from ROL) swaps byte order in each offset pair via XBA.
; 
; Stores offsets to $18/$1C (origin offsets) and conditionally updates the collision box ($20/$22) based on $12 flags:
; - Bit 8 ($0100): skip collision box update entirely
; - Bit 7 ($0080): copy raw offsets to $20/$22 (no ×8 centering adjustment)
; - Neither: apply -8px centering to $22 before storing
; 
; Increments frame counter $2A. Returns with carry CLEAR on success.

UpdateActorAnimation {
    PHB 
    SEP #$20
    LDA $7F0008, X
    PHA 
    PLB 
    REP #$20
    LDA $28               ; Spriteset[$28] → animation table pointer
    ASL 
    CLC 
    ADC $spritesetPtr, X
    TAY 
    LDA $2A               ; Frame[$2A × 4] → 4-byte frame entry
    ASL 
    ASL 
    CLC 
    ADC $0000, Y
    TAY 
    LDA $0000, Y
    BMI loc_03CAF0        ; Negative frame data: animation ended → reset $2A, return carry set
    STA $08
    LDA $0002, Y
    TAY 
    CLC 
    ADC #$0004            ; Metasprite = frame sprite base + 4 (skip header to sub-sprites)
    STA $metaspritePtr, X
    LDA $0E               ; ROL sprite field: C = bit15 (Y-flip), N = bit14 (X-flip); saved via PHP
    ROL 
    PHP 
    LDA $0002, Y          ; Y bounding box offsets; XBA if Y-flipped (carry set)
    STA $0002
    BCC loc_03CA92
    XBA 

  loc_03CA92:
    SEP #$20              ; Split offset pair: low → $1A, high → $1E
    STA $1A
    XBA 
    STA $1E
    REP #$20
    LDA $0000, Y          ; X bounding box offsets; PLP restores flip flags, BPL tests X-flip (N)
    STA $0000
    PLP 
    BPL loc_03CAA5
    XBA 

  loc_03CAA5:
    STA $0000
    AND #$00FF            ; Sign-extend: bit 7 set → ORA $FF00 for negative offset
    BIT #$0080
    BEQ loc_03CAB3
    ORA #$FF00

  loc_03CAB3:
    STA $18
    LDA $0001
    AND #$00FF
    BIT #$0080
    BEQ loc_03CAC3
    ORA #$FF00

  loc_03CAC3:
    STA $1C
    INC $2A               ; Advance animation frame counter
    LDA $12               ; Collision box update mode from $12
    BIT #$0100            ; $0100: skip collision box update entirely
    BNE loc_03CAED
    BIT #$0080            ; $0080: raw copy — no centering adjustment
    BNE loc_03CAE3
    LDA $0000             ; Standard: copy offsets to collision box, −8px Y centering on $22
    STA $20
    LDA $0002
    SEC 
    SBC #$0008
    STA $22
    BRA loc_03CAED

  loc_03CAE3:
    LDA $0000             ; Raw mode: copy offsets directly to $20/$22
    STA $20
    LDA $0002
    STA $22

  loc_03CAED:
    CLC 
    PLB 
    RTL 

  loc_03CAF0:
    STZ $2A               ; Animation end: reset frame to 0, return carry set
    SEC 
    PLB 
    RTL 
}