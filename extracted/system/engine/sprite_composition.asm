; Sprite composition, depth sorting, OAM table construction, and render list management (247295–248565 + 252010–252033, Bank 03).
; 
; Implements the complete pipeline for converting actor metasprite definitions into the hardware OAM table each frame. The system processes the actor linked list in four stages: render list clearing, depth sorting, metasprite decomposition, and OAM table packing.
; 
; === RENDER LIST CLEARING (ClearActorRenderList, 252010) ===
; 
; ClearActorRenderList zeroes the 512-byte depth-sort bucket array at $0200–$03FE and writes a $FFFF end sentinel at $0400, preparing it for SortActorsByDepth. It is called at scene setup (scene_lifecycle, inventory_overlay), not every frame: SortActors_BuildFinalList re-zeroes each bucket it consumes (a PHA written over the popped bucket word), so the array is already clean at the start of the next frame's sort.
; 
; === DEPTH SORTING (SortActorsByDepth) ===
; 
; Uses a bucket sort algorithm with the $0200–$03FE WRAM region as a bucket array indexed by sort key. Each actor's screen-space Y position is converted to an inverted sort key (lower on screen = lower key = emitted first = lowest OAM index, which the PPU draws in front of higher indexes). The stack pointer is repurposed to iterate the sort buffer efficiently via PLX/PLA.
; 
; Sort key assignment based on actor flags ($10):
; - Bit 13 ($2000): Actor hidden — skipped entirely
; - Bits 0+1 ($0003) both clear: Y-based depth key (screen Y inverted via EOR, doubled via ASL)
; - Bit 0 only ($0001): Fixed key $01FE — emitted last = highest OAM index = always behind (COP SetPriorityMin sets this bit)
; - Bit 1 ($0002): Fixed key $0000 — emitted first = OAM index 0 = always in front (COP SetPriorityMax); wins when both bits are set
; 
; BuildFinalList reads the bucket array front-to-back via PLY (SP set to $01FF), producing the final depth-sorted actor list at $0C00.
; 
; === SPRITE COMPOSITION (ComposeAllSprites) ===
; 
; Entry point called from the main game loop after actor execution. Pre-fills the entire 128-entry OAM table with the hidden value $E080 (X byte $80, Y byte $E0 — Y $E0 is below the 224-line screen), then processes two sprite sources:
; 1. Compose buffer at $7F3100 (pre-composed sprites from damage digits, VFX)
; 2. Sorted actor list at $0C00 (metasprite decomposition per actor)
; 
; For each actor, dispatches to DecomposeActorMetasprites (generic) or DecomposePlayerSprites (player, identified by bit 15 of $10).
; 
; === OAM TABLE LAYOUT ===
; 
; SNES OAM: 128 entries × 4 bytes at $0422–$0621, plus a 32-byte high table at $0622–$0641 (write pointer in $06). Each low-table entry: byte 0 = X[7:0], byte 1 = Y, bytes 2-3 = tile/attribute. The high table packs 2 bits per sprite (X bit 8, size flag) into groups of 4 via a rolling shift register ($00) with a 4-sprite counter ($0E).
; 
; === METASPRITE FORMAT ===
; 
; 7 bytes per sub-sprite in a metasprite definition:
; - Byte 0: Size/priority flags (bit 0 → OAM hi-table size bit)
; - Bytes 1-2: X offset pair (swapped via XBA when H-mirrored)
; - Bytes 3-4: Y offset pair (swapped via XBA when V-mirrored)
; - Bytes 5-6: Tile index + palette/priority attributes
; 
; Mirroring comes from the actor's OAM attribute word ($000E,X, copied to $04): bit 14 (H-flip) swaps the X offset pair and bit 15 (V-flip) swaps the Y offset pair, each tested via the carry from ASL. The whole word is also EOR'd into every sub-sprite's tile/attribute word, so $0E acts as an XOR mask for flips, palette and priority (see cop_handlers_oam_attribs).
; 
; === PLAYER SPRITE HANDLING ===
; 
; DecomposePlayerSprites adds character-form body table lookups (tile source address and bank), a per-sub-sprite list of tile source pointers at $06FF+ that DmaPlayerTilesToVram streams to VRAM, sequential OAM tile numbering, and sprite cache validation ($09CC/$09CE) to skip the re-upload when the metasprite pointer and bank haven't changed.
; 
; === COMPOSE BUFFER ($7F3100) ===
; 
; Pre-composed sprite buffer for systems that generate sprites outside the metasprite pipeline (damage digits, visual effects). Each entry: X position (2B) + Y position (2B) + tile/attribute (2B), in world coordinates (RenderComposeBuffer subtracts the scroll). A word with bit 15 set ($FFFF, written by the main loop at oamWriteOffset) ends the buffer. RenderComposeBuffer runs before the actor metasprite loop, so these sprites take the lowest OAM indexes and draw in front of every actor.
; 
; === ANIMATION (UpdateActorAnimation) ===
; 
; Indexes into the spriteset → animation → frame hierarchy to advance an actor's current animation. Returns carry set on sequence end (negative frame data), signaling the actor to loop or transition.
---------------------------------------------

?BANK 03

?INCLUDE 'body_table'

!actorListLast                  0058
!oamWriteOffset                 00D8
!deathFlag                      0200
!oamStaging                     0422
!bg1ScrollH                     068A
!mapScrollV                     068E
!layerPriorityFlag              06EE
!playerTileSrcBase              06FC
!playerTileDmaBank              06FE
!playerFlags                    09AE
!playerSpriteCachePtr           09CC
!playerSpriteCacheBank          09CE
!displayModeFlags               09EC
!characterForm                  0AD4
!actorRenderList                0C00
!spritesetPtr                   7F0006
!metaspritePtr                  7F000C
!animScratch2                   7F000E
!iframeCounter                  7F0028
!oamComposeBuffer               7F3100

---------------------------------------------

; Clear the depth-sort bucket array at $0200 in preparation for the next frame.
; 
; Zeroes 512 bytes ($0200–$03FE, 256 words) and writes $FFFF as an end sentinel at $0400. This array is used by SortActorsByDepth as bucket storage for the Y-position depth sort. Called only at scene setup (scene_lifecycle) and by inventory_overlay; during normal frames the sort leaves the buckets zeroed on its own.

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
; Iterates the actor linked list ($0058 head → $04 next). For each actor, performs screen-bounds culling on both axes (X range 0–$100 against bg1ScrollH, Y range 0–$E0 against mapScrollV), using the actor's left/right extents ($18/$1C, from the sign-extended X offset pair) and top/bottom extents ($1A/$1E, from the Y pair) that UpdateActorAnimation loads from the frame header. Off-screen actors get flag $4000 set in $10 via SortActors_OffScreen.
; 
; On-screen actors receive a depth sort key based on flags ($10):
; - Bit 13 ($2000): hidden — skipped, no buffer entry
; - Bits 0-1 ($0003) both clear: Y-based key = (screenY EOR $FF) ASL → actors lower on screen get lower keys and OAM indexes, so they draw in front of actors higher up
; - Bit 0 only (COP SetPriorityMin): key $01FE → last in the list, behind every Y-sorted actor
; - Bit 1 (COP SetPriorityMax): key $00FF EOR $FF ASL = $0000 → first in the list, in front of everything (also the result for a screen Y of $100 or more, which includes negative values)
; 
; Actor slot IDs and sort keys are written as 4-byte pairs to $0C00,Y. After all actors are processed, falls through to SortActors_BuildFinalList.

SortActorsByDepth {
    PHP 
    PHD 
    REP #$20
    LDY #$0000
    LDA $actorListLast    ; Head of actor linked list → TAX/TCD sets DP per actor

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
    LDA $16               ; Top-edge screen Y = posY − originY − mapScrollV
    SEC 
    SBC $1A
    SEC 
    SBC $mapScrollV
    CMP #$00E0
    BCC loc_03C64F
    BPL SortActors_OffScreen
    LDA $16               ; Top edge off-screen top: check bottom edge (posY + height)
    CLC 
    ADC $1E
    SEC 
    SBC $mapScrollV
    CMP #$00E0
    BCS SortActors_OffScreen

  loc_03C64F:
    LDA $10               ; Sort key selection from actor flags ($10)
    BIT #$2000            ; $2000: hidden — skip without creating buffer entry
    BNE loc_03C687
    BIT #$0003            ; $0003: depth override (0 = Y-based, 1 = SetPriorityMin → back, 2 = SetPriorityMax → front)
    BEQ loc_03C665
    BIT #$0002
    BNE loc_03C670
    LDA #$01FE            ; Bit 0 only → key $01FE: last in the list = highest OAM index = behind all other actors
    BRA loc_03C677

  loc_03C665:
    LDA $16               ; Y-based key: compute from screen Y position
    SEC 
    SBC $mapScrollV
    CMP #$0100
    BCC loc_03C673

  loc_03C670:
    LDA #$00FF            ; Bit 1, or screen Y ≥ $100 → $00FF → after EOR+ASL = $0000: first in the list = OAM index 0 = in front

  loc_03C673:
    EOR #$00FF            ; Invert: lower on screen → lower key → emitted first → lower OAM index → drawn in front; ASL doubles the key for word-indexed buckets
    ASL 

  loc_03C677:
    CMP #$0200            ; Guard: would spin forever if key ≥ $0200; cannot happen (largest key is $01FE)
    BCS loc_03C677
    STA $actorRenderList, Y ; Write 4-byte sort entry: key + actor slot ID to $0C00,Y
    TXA 
    STA $actorRenderList+2, Y
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
; Phase 2 — Linearization: Sets SP to $01FF to iterate the bucket array front-to-back via PLY. Empty buckets (zero) are skipped. Each non-empty bucket's linked list is traversed and the actor slot IDs are written sequentially to $0C00,X, producing the final render-order list. Terminated with STZ. Each chain is walked newest-node-first, so actors that share a key come out in reverse list order. After copying a chain, a PHA/PLA pair writes the zero end-of-chain word back over the bucket word just popped, which re-zeroes the bucket for the next frame's sort.
; 
; Restores original SP, DP, and processor state before returning via RTL.

SortActors_BuildFinalList {
    LDA #$FFFF            ; $FFFF sentinel terminates sort buffer
    STA $actorRenderList, Y
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
    PHA                   ; End of chain (A = 0): PHA writes the zero over the bucket word PLY just popped, PLA re-reads it — re-zeroes the bucket for next frame
    PLA 

  loc_03C6F6:
    PLY                   ; Pop next bucket — zero = empty (retry), negative = done
    BEQ loc_03C6F6
    BMI loc_03C70B

  loc_03C6FB:
    LDA $0000, Y          ; Traverse chain: copy actor slot IDs to final $0C00 render list
    STA $actorRenderList, X
    INX 
    INX 
    LDA $0002, Y
    BEQ loc_03C6F4
    TAY 
    BRA loc_03C6FB

  loc_03C70B:
    STZ $actorRenderList, X ; Zero-terminate render list
    LDA $00
    TCS 
    PLD 
    PLP 
    RTL 
}

---------------------------------------------
; Main per-frame sprite composition entry point — builds the complete OAM table.
; 
; Pre-fills all 128 OAM entries with the hidden value $E080 (X $80, Y $E0 = below the screen) by pushing $E080 × 256 words onto a temporary stack at $0621. Then processes two sprite sources:
; 
; 1. RenderComposeBuffer: converts pre-composed sprites from $7F3100 to OAM entries
; 2. Sorted actor list ($0C00): for each actor, calls DecomposeActorMetasprites to expand metasprite definitions into individual OAM entries
; 
; OAM state: $06 points to the current hi-table byte (starts at $0622), $0E counts sprites left in the current hi-table group (4 per byte) and $00 is the rolling hi-table shift register. $08 is not OAM state: it is the write pointer of the player tile-DMA list (starts at $06FE), and $14 is the sequential OAM tile counter for player sub-sprites. After the compose buffer has been consumed, the compose-buffer write offset ($00D8) is reset so the next frame's entries start at $7F3100.
; 
; When the actor list is exhausted (zero entry) or OAM is full (carry set from decomposition), finalizes the hi-table remainder by shifting and storing the last partial byte.

ComposeAllSprites {
    PHP 
    REP #$20
    LDA #$06FE            ; $08 = player tile-DMA list pointer: $06FE = source bank byte, source pointers follow from $06FF
    STA $08
    STZ $playerTileDmaBank+1 ; Empty the tile-source list: a zero first pointer ends DmaPlayerTilesToVram's walk if the player is not drawn this frame
    STZ $playerTileDmaBank+11 ; Also zero the ninth slot (start of the overflow pass); defensive — the list normally ends at its own $0000 terminator
    STZ $14               ; Reset the sequential OAM tile counter used by DecomposePlayerSprites
    LDA $bg1ScrollH       ; Screen X origin = bg1ScrollH − 16px margin
    SEC 
    SBC #$0010
    STA $1A
    LDA $mapScrollV
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
    LDA #$E080            ; $E080 = X byte $80, Y byte $E0: Y $E0 is below the 224-line screen, so unused entries stay hidden

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
    STZ $oamWriteOffset   ; Compose buffer consumed: reset its write offset so next frame's entries restart at $7F3100
    LDX #$0000

  loc_03C76C:
    LDA $actorRenderList, X ; Iterate sorted render list — zero entry = end of list
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
; Layer priority mode (bit set): Block-copies compose buffer data directly to OAM via MVN $00,$7F. Copies min($00DA, $0200) bytes from $7F0600 to $0422 ($00DA is a byte count, 4 per sprite — pr_text_placement_calc builds the entries and doubles its sprite count twice). Then computes the hi-table byte count ($00DA >> 4), fills those bytes with $AA (every sprite large-size, X bit 8 clear) and sets the rolling register for the leftover sprites from OamHiTableMasks. Y is left at $00DA, so actor sprites follow the copied block. No setter for bit 12 of layerPriorityFlag was found in the extracted code, so what triggers this mode is unconfirmed.

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
    LDA $oamComposeBuffer+2, X ; Screen Y = bufferY − mapScrollV; skip if ≥ $F0
    SEC 
    SBC $mapScrollV
    CMP #$00F0
    BCS loc_03C7E8
    STA $oamStaging+1, Y
    LDA $oamComposeBuffer+4, X
    STA $oamStaging+2, Y
    LDA $oamComposeBuffer, X ; Screen X = bufferX − bg1ScrollH; skip if ≥ $110
    SEC 
    SBC $bg1ScrollH
    CMP #$0110
    BCS loc_03C7E8
    SEP #$20
    STA $oamStaging, Y
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
    LDA $00DA             ; Priority mode: block-copy $00DA bytes (4 per sprite) from $7F0600 to OAM; zero = nothing to copy
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
    LSR                   ; Hi-table byte count = byte count >> 4 (4 bytes per sprite, 4 sprites per hi-table byte)
    LSR 
    LSR 
    LSR 
    STA $0E
    LDA $00DA
    LSR 
    AND #$0006            ; Leftover sprites mod 4, doubled → OamHiTableMasks index
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
    LDA $@OamHiTableMasks, X ; Table byte 0: initial rolling register ($00) holding the leftover sprites' hi bits
    STA $00
    LDA $@OamHiTableMasks+1, X ; Table byte 1: sprites still needed to fill the current hi-table byte → $0E
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
; Switches DBR to the actor's sprite bank ($7F0008,X). Computes screen-relative position by subtracting scroll offsets ($1A, $1E) from the actor's world position minus origin ($14-$18, $16-$1A). Loads the OAM attribute word ($000E,X → $04) for mirror detection.
; 
; Iframe blinking: only when actor flag $0080 (iframe/hit-reaction active, set by ApplyPlayerHitstun together with the counter) is set and $0010 is clear: if the iframe counter ($7F0028,X) is nonzero and its low bit is set (LSR carry; the counter counts each frame, so the flash alternates — inferred), sets palette override $02 = $0E00 (palette 7) to produce the flash.
; 
; Dispatches to DecomposePlayerSprites if bit 15 ($8000) of $10 is set (player actor).
; 
; For generic actors: reads the metasprite pointer ($7F000C,X + 8), extracts the sub-sprite count from byte 0, then iterates each 7-byte sub-sprite entry. For each sub-sprite:
; 1. Y offset: read bytes 3-4 (XBA if V-mirrored), add screen Y ($1C), bounds-check < $F0
; 2. Tile/attribute: read bytes 5-6, EOR with the attribute word ($04), OR with palette override ($02)
; 3. X offset: read bytes 1-2 (XBA if H-mirrored), add screen X ($18), bounds-check < $110
; 4. Write OAM low-table entry and pack hi-table bits
; 5. Advance to next sub-sprite (+7 bytes) or bail if OAM full (Y = $0200)
; 
; Off-screen sub-sprites do not consume an OAM slot: $E080 is written over the current slot only to scrub any partly written entry, and the next sub-sprite reuses it. Returns carry set when OAM is full (128 entries), carry clear otherwise.

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
    LDA $000E, X          ; OAM attribute word → $04: bit 15 = V-flip, bit 14 = H-flip, tested later via ASL carry
    STA $04
    STZ $02               ; Clear palette override (set to $0E00 later if iframe-blinking)
    LDA $0010, X          ; Check actor flags for visibility and iframe state
    BIT #$0080            ; $0080: iframe/hit-reaction active (ApplyPlayerHitstun sets it with the counter) — if clear, skip the blink
    BEQ loc_03C896
    BIT #$0010            ; $0010 (bit 4 of $10): suppresses the blink; meaning not traced (damage immunity is bit 4 of $12, a different word)
    BNE loc_03C896
    BIT #$0400            ; No-op test: both outcomes continue at the iframe check below
    BNE loc_03C885

  loc_03C885:
    LDA $iframeCounter, X ; Iframe blink: nonzero counter with bit 0 set → OR palette 7 ($0E00) into every sub-sprite
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
    LDA $metaspritePtr, X ; metaspritePtr + 8 → sub-sprite count byte (the 8 bytes after the pointer are skipped, not used here)
    CLC 
    ADC #$0008
    TAX 
    LDA $0000, X          ; Byte 0 = sub-sprite count
    AND #$00FF
    INX 
    STA $10

  loc_03C8B0:
    LDA $04               ; ASL $04 → carry = bit 15 (V-flip): swap Y offset pair (bytes 3-4) via XBA
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
    SBC #$0010            ; Carry is clear, so this subtracts $11: the 16px margin added via $1E plus 1 (OAM Y shows one scanline low)
    STA $oamStaging+1, Y
    LDA $0005, X          ; Tile word: EOR the actor's attribute mask ($04), OR the iframe palette ($02)
    EOR $04
    ORA $02
    STA $oamStaging+2, Y
    LDA $04               ; Double-ASL $04 → carry = bit 14 (H-flip): swap X offset pair (bytes 1-2)
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
    SBC #$000F            ; Carry is clear, so this subtracts $10: removes the 16px margin added via $1A
    SEP #$20
    STA $oamStaging, Y
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
    LDA #$E080            ; Off-screen sub-sprite: scrub the slot to hidden $E080 (Y was possibly written already); Y is not advanced, so the slot is reused
    STA $oamStaging, Y
    BRA loc_03C914
}

---------------------------------------------
; Expand the player character's metasprite into OAM entries with VRAM tile remapping.
; 
; Calls CheckPlayerSpriteCache to detect metasprite/bank changes. Loads the character form ($0AD4) and computes a body table index (form × 6 via ASL+ADC+ASL). If playerFlags bit 15 is set (transformation/override), uses animScratch2 ($7F000E,X) directly as the body table index instead.
; 
; From the body table (6 bytes per form): the word at +3 is the tile graphics source address, stored to $06FC; the byte at +5 is its bank, stored as the first byte of the tile-DMA list at $06FE (DmaPlayerTilesToVram reads it back as the DMA source bank). Then reads the metasprite at the cached pointer ($09CC + 8) and iterates sub-sprites similarly to DecomposeActorMetasprites, with two additions:
; 
; 1. Tile source remapping: each sub-sprite's tile number is multiplied by 32 (AND $01FF, ASL ×5, 32 bytes per 4bpp tile) and added to $06FC to give the RAM address of that tile's graphics; the address is appended to the list at ($08) for DMA.
; 2. Sequential OAM tile numbering ($14): the OAM tile written for each sub-sprite is $14, which grows by 2 per sub-sprite. When it reaches $10 it jumps by $10 more, skipping the tile rows $10–$1F that hold the lower halves of the first eight sprites (VRAM $4100); sprites 9 and up land in the $4200 overflow region.
; 
; On completion, writes $0000 to ($08) as the list terminator.

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
    LDA $@body_table+3, X ; Body table +3: tile graphics source address → $06FC
    STA $playerTileSrcBase
    LDA $@body_table+5, X ; Body table +5: source bank → first byte of the DMA list at ($08) = $06FE
    AND #$00FF
    STA ($08)
    INC $08
    LDA $playerSpriteCachePtr ; Cached metasprite ($09CC) + 8 → sub-sprite array
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
    STA $oamStaging+1, Y
    LDA $0005, X
    EOR $04
    ORA $02
    PHA 
    AND #$01FF            ; Source remap: (tile AND $01FF) × 32 + $06FC = RAM address of this tile's graphics → DMA list at ($08)
    ASL 
    ASL 
    ASL 
    ASL 
    ASL 
    ADC $playerTileSrcBase
    STA ($08)
    INC $08
    INC $08
    PLA 
    AND #$FE00            ; Keep the attribute bits ($FE00: flips, priority, palette, name table) and replace the tile number with the sequential counter $14
    ORA $14
    STA $oamStaging+2, Y
    LDA $14               ; Tile counter += 2 (one 16×16 sprite = two tile columns); at $10 add $10 more, skipping the lower-half rows
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
    STA $oamStaging, Y
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
; Sets bit 2 ($0004) in playerFlags (sprite-redraw request: CheckPlayerSpriteCache bypasses its cache while it is set) and bit 3 ($0008) in displayModeFlags (player tile DMA pending). Writes $E080 to the current OAM slot to scrub it, without advancing Y, then continues with the remaining sub-sprites. Reached from the Y check before the sub-sprite's tile is queued, and from the X check after it was queued.

PlayerSprite_OffScreen {
    LDA #$0004            ; Set playerFlags bit 2: sprite-redraw request (a clipped sub-sprite means the tiles must be re-sent)
    TSB $playerFlags
    LDA #$0008            ; Set displayModeFlags bit 3: player tile DMA pending
    TSB $displayModeFlags
    LDA #$E080            ; Scrub the current slot to hidden $E080 (Y stays put; next sub-sprite reuses it)
    STA $oamStaging, Y
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
    CMP $playerSpriteCachePtr
    BNE loc_03CA37
    LDA $7F0008, X
    CMP $playerSpriteCacheBank
    BNE loc_03CA37
    LDA $playerSpriteCachePtr
    RTS 

  loc_03CA37:
    LDA $playerFlags      ; Cache miss: clear force-redraw flag, update cache values
    AND #$FFFB
    STA $playerFlags
    LDA $7F0008, X
    STA $playerSpriteCacheBank
    LDA $metaspritePtr, X
    STA $playerSpriteCachePtr
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
; Otherwise, updates the metasprite pointer ($7F000C,X) to the frame's sprite data (+ 4 for the sub-sprite array). Reads X/Y bounding box offset pairs from the frame header, sign-extending bytes via $0080 check and ORA $FF00. The mirror bits of $0E (ROL moves bit 15 into carry and bit 14 into N) swap the byte order of each offset pair via XBA: V-flip for the Y pair, H-flip for the X pair.
; 
; Stores the X pair as signed extents $18 (left) / $1C (right) and the Y pair as unsigned extents $1A (top) / $1E (bottom) — the values SortActorsByDepth uses for culling — and conditionally updates the collision box ($20 = X pair, $22 = Y pair) based on $12 flags:
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
    LDA $0E               ; ROL attribute word: C = bit 15 (V-flip), N = bit 14 (H-flip); saved via PHP
    ROL 
    PHP 
    LDA $0002, Y          ; Y extent pair; XBA if V-flipped (carry = bit 15)
    STA $0002
    BCC loc_03CA92
    XBA 

  loc_03CA92:
    SEP #$20              ; Split the Y pair with 8-bit stores: low → $1A (top), high → $1E (bottom); their high bytes are not touched
    STA $1A
    XBA 
    STA $1E
    REP #$20
    LDA $0000, Y          ; X extent pair; PLP restores the flip flags, BPL skips the swap unless N = bit 14 (H-flip)
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
    STA $18               ; $18 = left extent (signed)
    LDA $0001             ; High byte of the X pair → sign-extend into $1C (right extent)
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