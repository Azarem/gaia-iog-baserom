; DMA, HDMA, and SPC audio utility routines (252033–252182 + 254128–254549 + 258512–258561, Bank 03).
; 
; A mixed utility block spanning three non-contiguous address ranges, providing hardware transfer and audio infrastructure used by the scene lifecycle, NMI handler, and actor systems.
; 
; === PLAYER TILE DMA (252033–252182) ===
; 
; DmaPlayerTilesToVram transfers up to 8 queued 16×16 player character tiles from RAM to VRAM during V-Blank. The tile pointer table at $06FE provides source addresses; tiles are DMA’d in four passes (upper/lower halves × primary/overflow VRAM regions $4000–$4300). Called by ClearSceneState during scene loading and by the NMI handler for per-frame animation updates.
; 
; === PALETTE/GRAPHICS LOADING (254128–254278) ===
; 
; LoadPaletteBundle parses structured palette/spriteset bundles from the palette_bundles table, populating actor WRAM fields (spritesetPtr, chatPtr, metaspritePtr) for each bundle entry. DecompressGfxToVram wraps the $0402 decompression helper to decompress graphics data into VRAM from parameters stored in actor WRAM.
; 
; === HDMA CHANNEL MANAGEMENT (254278–254378) ===
; 
; ResetHdmaState initializes the HDMA channel allocation state ($66 enable mask, $68 channel bit, $6A register offset). SetupHdmaChannel_Indirect and SetupHdmaChannel_Direct configure individual HDMA channels from a register lookup table (binary_01D8BE), with indirect mode adding the $40 flag and bank byte for pointer-based HDMA tables. Both advance the allocation state for the next channel.
; 
; === SPC AUDIO TRANSFER (254378–254549) ===
; 
; Three-stage SPC700 music data pipeline: SpcCheckMusicReady handshakes with the SPC via APUIO0 ($2140) to verify readiness, SpcTransferMusicData sends the actual music data with confirmation protocol, and LoadMusicFromTransitionState resolves a music ID from musicTransitionState to a music_array pointer and initiates the block transfer via SpcBlockTransfer.
; 
; === AD-HOC VRAM DMA (258512–258561) ===
; 
; DmaAdhocVramBlock executes one-shot VRAM transfers queued at $7F0C03–$7F0C09. Checks for a pending destination address at $7F0C07, and if nonzero, transfers the specified byte count from the source address to VRAM via DMA channel 0. Used by various systems for deferred VRAM writes outside the normal V-Blank pipeline.
---------------------------------------------

?BANK 03

?INCLUDE 'hdma_ramp_tables'
?INCLUDE 'music_pointer_array'
?INCLUDE 'palette_bundles'
?INCLUDE 'spc_transfer'
?INCLUDE 'vblank_joypad'

!sfxQueueCh1                    06F8
!musicTransitionState           06FA
!displayModeFlags               09EC
!VMAIN                          2115
!VMADDL                         2116
!APUIO0                         2140
!MDMAEN                         420B
!DMAP0                          4300
!BBAD0                          4301
!A1T0L                          4302
!A1B0                           4304
!DAS0L                          4305
!DASB0                          4307
!animScratch                    7F0000
!spritesetPtr                   7F0006
!chatPtr                        7F000A
!metaspritePtr                  7F000C
!adhocVramDma                   7F0C03

---------------------------------------------

; Transfer player character sprite tiles from RAM to VRAM during V-Blank.
; 
; Checks displayModeFlags bit 3 ($08) — returns immediately if not set (no pending tile update). Clears the flag after entry to prevent re-triggering.
; 
; Sets up DMA channel 0 in word-increment mode (VMAIN=$80, DMAP0=$01, BBAD0=$18) with the source bank from $06FE. Transfers tiles in four passes:
; 1. Upper-half tiles to VRAM $4000 via DmaPlayerTiles_UpperHalf
; 2. If all 8 tile entries consumed (Y=$11): upper-half continuation to VRAM $4200
; 3. Lower-half tiles to VRAM $4100 via DmaPlayerTiles_LowerHalf
; 4. If all 8 entries consumed: lower-half continuation to VRAM $4300
; 
; The tile source table at $06FE contains up to 8 word-sized pointers. Each pointer is a RAM address holding 64 bytes ($40) of tile data (one 16×16 metatile = four 8×8 tiles). The lower half adds $0200 to each source address to reach the bottom tile rows.
; 
; Used by both ClearSceneState (scene loading) and the NMI handler (per-frame animation updates).

DmaPlayerTilesToVram {
    LDA $displayModeFlags ; Check displayModeFlags bit 3 — pending player tile VRAM upload?
    BIT #$08
    BNE loc_03D889
    RTL                   ; No pending tile update — return

  loc_03D889:
    AND #$F7              ; Clear bit 3 — acknowledge tile-update request
    STA $displayModeFlags
    LDA #$80              ; VMAIN=$80 word-increment mode for tile DMA
    STA $VMAIN
    LDA #$01              ; DMA channel 0: mode $01, target VMDATAL ($18)
    STA $DMAP0
    LDA #$18
    STA $BBAD0
    LDA $06FE             ; Source bank from $06FE tile pointer table header
    STA $A1B0
    LDY #$0001            ; Y=1 — first tile pointer (skip table header)
    LDX #$4000            ; Upper-half tiles → VRAM $4000
    STX $VMADDL
    JSR $&DmaPlayerTiles_UpperHalf ; DMA upper rows of all queued tiles
    CPY #$0011            ; All 8 slots consumed? (Y=$11) — overflow to $4200
    BNE loc_03D8BD
    LDX #$4200
    STX $VMADDL
    JSR $&DmaPlayerTiles_UpperHalf

  loc_03D8BD:
    LDY #$0001            ; Re-walk table for lower halves → VRAM $4100
    LDX #$4100
    STX $VMADDL
    JSR $&DmaPlayerTiles_LowerHalf
    CPY #$0011            ; Lower overflow → VRAM $4300
    BNE loc_03D8D7
    LDX #$4300
    STX $VMADDL
    JSR $&DmaPlayerTiles_LowerHalf

  loc_03D8D7:
    RTL 
}

---------------------------------------------
; DMA inner loop — transfer upper tile rows for the player sprite.
; 
; Iterates through the tile pointer table at $06FE,Y. For each nonzero pointer: sets A1T0L to the source address, transfers $40 bytes (64 bytes = one 16×16 tile's upper half) via DMA channel 0. Advances Y by 2 per entry. Stops at Y=$11 (8 entries) or on a zero pointer (end of list).
; 
; Called with VMADDL already set to the target VRAM address by the caller.

DmaPlayerTiles_UpperHalf {
    LDX $06FE, Y          ; Load next tile source pointer from $06FE,Y
    BEQ loc_03D8F1        ; Null pointer → end of tile list
    STX $A1T0L
    LDA #$40              ; $40 bytes per tile — one 16×16 upper half
    STA $DAS0L
    LDA #$01
    STA $MDMAEN
    INY 
    INY 
    CPY #$0011            ; Loop until 8 entries (Y=$11)
    BNE DmaPlayerTiles_UpperHalf

  loc_03D8F1:
    RTS 
}

---------------------------------------------
; DMA inner loop — transfer lower tile rows for the player sprite.
; 
; Same structure as DmaPlayerTiles_UpperHalf but operates in 16-bit mode to add $0200 to each source pointer before transfer. This offset reaches the lower half of each 16×16 tile's graphics data in the source buffer. Restores 8-bit mode on exit.

DmaPlayerTiles_LowerHalf {
    REP #$20              ; 16-bit A — need to add $0200 for lower tile rows
    LDA $06FE, Y
    BEQ loc_03D913
    CLC 
    ADC #$0200            ; +$0200 offset → lower 8×8 rows in source buffer
    STA $A1T0L
    SEP #$20              ; Back to 8-bit for DMA control registers
    LDA #$40
    STA $DAS0L
    LDA #$01
    STA $MDMAEN
    INY 
    INY 
    CPY #$0011            ; Loop until 8 entries (Y=$11)
    BNE DmaPlayerTiles_LowerHalf

  loc_03D913:
    SEP #$20
    RTS 
}
---------------------------------------------

; Load a palette/spriteset bundle from the palette_bundles table into actor WRAM fields.
; 
; Switches data bank to the palette_bundles ROM bank for direct access. Uses animScratch+2,X as a bundle ID to index the palette_bundles table, then iterates through sub-entries within that bundle using $0E as the current sub-entry counter.
; 
; Each sub-entry is a 6-byte record containing:
; - Byte 0: spriteset index (zero = end of bundle)
; - Bytes 1–2: chatPtr (graphics data source pointer)
; - Byte 3: metasprite table index (×2 + $0A00 base)
; - Byte 4: graphics bank/type identifier
; - Byte 5: animation scratch value
; 
; Fields are populated to actor WRAM: spritesetPtr ($7F0006,X), chatPtr ($7F000A,X), metaspritePtr ($7F000C,X), $7F0008,X, and animScratch ($7F0000,X). The sub-entry counter $0E is incremented after each load.
; 
; Special case: when byte 4 equals 2, the secondary metasprite pointer at $7F000D,X is advanced by 2.
; 
; Returns carry clear if more sub-entries remain, carry set when the end marker (zero byte 0) is reached.

LoadPaletteBundle {
    PHP 
    PHB 
    SEP #$20              ; 8-bit A to set data bank to palette_bundles ROM bank
    LDA #$^palette_bundles
    PHA 
    PLB 
    REP #$20
    LDA $animScratch+2, X ; Bundle ID from animScratch+2 → index into palette_bundles table
    ASL 
    TAY 
    LDA $&palette_bundles, Y
    PHA 
    LDA $0E               ; Compute sub-entry offset: $0E × 6 (three 2-byte fields per sub-entry)
    ASL 
    CLC 
    ADC $0E
    ASL 
    CLC 
    ADC $01, S
    PLY 
    TAY 
    LDA $0000, Y          ; Load first byte of sub-entry — zero = end of bundle
    AND #$00FF
    BEQ loc_03E11F
    STA $spritesetPtr, X  ; Populate actor fields: spritesetPtr, chatPtr, metaspritePtr from bundle
    LDA $0001, Y
    STA $chatPtr, X
    LDA $0003, Y
    AND #$00FF
    ASL 
    CLC 
    ADC #$0A00
    STA $metaspritePtr, X ; Metasprite table index = byte[3] × 2 + $0A00 base offset
    LDA $0004, Y
    AND #$00FF
    STA $7F0008, X
    PHA 
    LDA $0005, Y
    AND #$00FF
    STA $08
    STA $animScratch, X
    INC $0E               ; Advance sub-entry counter for next LoadPaletteBundle call
    PLA 
    CMP #$0002            ; Bundle type 2: adjust secondary metasprite pointer +2
    BNE loc_03E11B
    LDA $7F000D, X
    INC 
    INC 
    STA $7F000D, X

  loc_03E11B:
    PLB 
    PLP 
    CLC                   ; Carry clear = more sub-entries available
    RTL 

  loc_03E11F:
    STZ $0E
    PLB 
    PLP 
    SEC                   ; Carry set = bundle exhausted (end marker reached)
    RTL 
}

---------------------------------------------
; Decompress graphics data to VRAM using the shared $0402 decompression helper.
; 
; Sets the decompression scratch parameter ($0404 = $967F), then loads three parameters from actor WRAM fields: the graphics identifier ($7F0008,X), the destination/metasprite pointer (metaspritePtr $7F000C,X → Y), and the source pointer (chatPtr $7F000A,X → X). Calls JSR $0402 to execute the decompression and DMA transfer.
; 
; After the call, stores the updated source pointer (returned in X) back to chatPtr so the next call continues from where the decompression left off. This allows iterative decompression of multi-part graphics sets.

DecompressGfxToVram {
    PHX 
    LDA #$967F            ; Set decompression scratch parameter $0404
    STA $0404
    LDA $7F0008, X        ; Load decompression parameters from actor WRAM fields
    PHA 
    LDA $metaspritePtr, X
    TAY 
    LDA $chatPtr, X
    TAX 
    PLA 
    JSR $0402             ; Call shared decompression/DMA helper → VRAM
    TXA 
    PLX 
    STA $chatPtr, X       ; Store updated source pointer back to actor chatPtr
    RTL 
}

---------------------------------------------
; Reset the HDMA channel allocation state for fresh channel assignment.
; 
; If $6C is negative (bit 7 set), the reset is skipped — this flag is set by callers that need to preserve the current HDMA configuration across frames (e.g., during wave transition effects).
; 
; Otherwise, clears the HDMA enable mask ($66 = 0), resets the current channel bit to channel 1 ($68 = $02), and resets the DMA register offset to channel 1 base ($6A = $10). These state variables are consumed by SetupHdmaChannel_Indirect/Direct when configuring HDMA channels.
; 
; Always clears the lock flag ($6C = 0) on exit.

ResetHdmaState {
    LDA $6C
    BMI loc_03E154        ; Skip reset if $6C negative (HDMA locked for multi-frame effect)
    STZ $66               ; Clear HDMA enable mask, reset channel allocation to ch1/$10
    LDA #$02
    STA $68
    LDA #$10
    STA $6A

  loc_03E154:
    STZ $6C
    RTL 
}

---------------------------------------------
; Configure one HDMA channel in indirect (pointer-based) mode.
; 
; Entry: A = channel index (lookup key for binary_01D8BE register table), Y = HDMA table source address, stack byte = target PPU register, additional stack byte = indirect bank.
; 
; Looks up the DMA transfer mode from binary_01D8BE and OR’s with $40 to set indirect mode in DMAP. Sets DASB0 (indirect bank byte) from the stack parameter. Falls through to the shared tail at SetupHdmaChannel_Direct to complete the channel configuration.
; 
; Indirect HDMA uses a pointer table in RAM where each entry contains a scanline count and a pointer to the actual data, allowing dynamic per-scanline register updates.

SetupHdmaChannel_Indirect {
    PHP 
    PHX 
    SEP #$20
    PHA 
    LDA #$00
    XBA 
    PHA 
    TAX 
    LDA $&hdma_ramp_tables.hdma_channel_config, X ; Look up DMA transfer mode from binary_01D8BE register table
    LDX $006A
    ORA #$40              ; Set indirect mode flag ($40) in DMAP register
    STA $DMAP0, X
    LDA $02, S
    STA $DASB0, X         ; Set indirect bank byte (DASB0) for pointer resolution
    BRA loc_03E186
}

---------------------------------------------
; Configure one HDMA channel in direct (inline data) mode.
; 
; Entry: A = channel index, Y = HDMA table source address, stack byte = source bank, additional stack byte = target PPU register.
; 
; Looks up the DMA transfer mode from binary_01D8BE and writes it directly to DMAP (no indirect flag). The shared tail code (loc_03E186) sets the target PPU register (BBAD0), source address (A1T0L from Y), and source bank (A1B0).
; 
; After configuration, enables this channel’s bit in the HDMA enable mask ($0066 via TSB $0068), shifts the channel bit left for the next channel (ASL $0068), and advances the register offset by $10 ($006A) to point at the next DMA channel’s register block.
; 
; Direct HDMA uses inline data where each entry contains a scanline count followed by the register value(s) to apply.

SetupHdmaChannel_Direct {
    PHP 
    PHX 
    SEP #$20
    PHA 
    LDA #$00
    XBA 
    PHA 
    TAX 
    LDA $&hdma_ramp_tables.hdma_channel_config, X
    LDX $006A
    STA $DMAP0, X         ; Direct mode: write transfer mode without indirect flag

  loc_03E186:
    PLA 
    STA $BBAD0, X         ; Target PPU register → BBAD0 for this HDMA channel
    REP #$20
    TYA 
    STA $A1T0L, X         ; HDMA table source address (from Y) → A1T0L
    SEP #$20
    PLA 
    STA $A1B0, X
    LDA $0068             ; Enable this channel bit in HDMA mask ($0066)
    TSB $0066
    ASL $0068
    LDA $006A             ; Advance register offset +$10 to next DMA channel block
    ADC #$10
    STA $006A
    PLX 
    PLP 
    RTL 
}

---------------------------------------------
; Check if the SPC700 audio processor is ready to receive music data.
; 
; Two-phase handshake protocol via APUIO0 ($2140):
; 
; 1. Sends $F1 to APUIO0 and yields (COP SetEntryExit). On return, checks if APUIO0 echoes $F1 — if not, the SPC is busy and the routine returns (will be called again next frame).
; 
; 2. If $F1 was echoed: sends $01 (transfer request) and yields again. Checks the response — if zero, the SPC confirmed readiness and execution falls through to SpcTransferMusicData. Otherwise returns.
; 
; Runs as a COP actor script — each COP SetEntryExit suspends this actor until the next frame, spreading the handshake across multiple frames to avoid blocking the main loop.

SpcCheckMusicReady {
    SEP #$20
    LDA #$F1              ; Send $F1 handshake to SPC via APUIO0
    STA $APUIO0
    REP #$20
    COP [SetEntryExit]    ; Yield — wait one frame for SPC to process
    LDA $APUIO0
    AND #$00FF
    CMP #$00F1            ; Check for $F1 echo — SPC acknowledged?
    BEQ loc_03E1C1
    RTL                   ; Not ready — return (retry next frame)

  loc_03E1C1:
    SEP #$20
    LDA #$01
    STA $APUIO0           ; SPC ready — send $01 transfer request
    REP #$20
    COP [SetEntryExit]
    SEP #$20
    LDA $APUIO0
    REP #$20
    BEQ SpcTransferMusicData ; SPC confirmed zero → begin data transfer
    RTL 
}

---------------------------------------------
; Transfer music data to the SPC700 audio processor.
; 
; Continues the handshake from SpcCheckMusicReady. Sends $F0 (transfer-start), yields, and verifies zero echo. Then sends $FF (ready-for-data) and loads the music data pointer from chatPtr into musicTransitionState ($06FA).
; 
; Waits for musicTransitionState to become $FFFF (set by the NMI handler’s LoadMusicFromTransitionState after the actual block transfer completes). Once confirmed, sends a final $01 acknowledgment, yields, clears sfxQueueCh1 and musicTransitionState, and terminates via COP Die.
; 
; The actor-based architecture allows the multi-frame SPC transfer protocol to run without blocking gameplay.

SpcTransferMusicData {
    SEP #$20
    LDA #$F0              ; Send $F0 transfer-start signal to SPC
    STA $APUIO0
    REP #$20
    COP [SetEntryExit]
    SEP #$20
    LDA $APUIO0
    REP #$20
    BEQ loc_03E1EB        ; SPC acknowledged — proceed with transfer
    RTL 

  loc_03E1EB:
    COP [SetEntryExit]
    SEP #$20
    LDA #$FF              ; Send $FF ready-for-data signal
    STA $APUIO0
    REP #$20
    LDA $chatPtr, X       ; Load music data pointer from chatPtr → musicTransitionState
    STA $musicTransitionState
    COP [SetEntryExit]
    LDA $musicTransitionState
    CMP #$FFFF            ; Wait for musicTransitionState = $FFFF (NMI completed transfer)
    BEQ loc_03E208
    RTL 

  loc_03E208:
    COP [WaitByte] ( #01 ) ; Wait for SPC byte acknowledgment
    SEP #$20
    LDA #$01
    STA $APUIO0
    REP #$20
    COP [SetEntryExit]
    STZ $sfxQueueCh1      ; Clear SFX queue and musicTransitionState, then die
    STZ $musicTransitionState
    COP [Die]
}

---------------------------------------------
; Resolve a music ID and initiate SPC block transfer.
; 
; Called from the NMI handler when musicTransitionState is nonzero and positive. Returns immediately if zero or negative (no pending music change).
; 
; Computes the music_array index as musicTransitionState × 3 (3-byte entries: 2-byte address + 1-byte bank). Loads the music data address and bank from music_array_01CBA6 into both direct page ($46/$47) and shadow registers ($0687/$0688).
; 
; Enables NMI and joypad, calls SpcBlockTransfer to DMA the music data to the SPC700, then re-enables NMI-only mode. Sets musicTransitionState to $FFFF to signal completion to the waiting SpcTransferMusicData actor.

LoadMusicFromTransitionState {
    LDX $musicTransitionState
    BEQ loc_03E254        ; No pending music (zero) — return immediately
    BMI loc_03E254        ; Negative musicTransitionState — return (already complete)
    REP #$20
    TXA                   ; Compute music_array index: musicTransitionState × 3
    ASL 
    CLC 
    ADC $musicTransitionState
    TAX 
    LDA $@music_pointer_array-3, X ; Load music data address + bank from music_array table
    STA $46
    STA $0687
    LDA $@music_pointer_array-2, X
    STA $47
    STA $0688
    JSL $@vblank_joypad.EnableNmiAndJoypad
    JSL $@spc_transfer.SpcBlockTransfer ; DMA music data to SPC700 via block transfer
    JSL $@vblank_joypad.EnableNmiOnly
    LDA #$FFFF            ; Mark musicTransitionState = $FFFF (transfer complete)
    STA $musicTransitionState
    SEP #$20

  loc_03E254:
    RTL 
}
---------------------------------------------

; Execute a one-shot VRAM DMA transfer from queued parameters.
; 
; Checks $7F0C07 for a pending VRAM destination address. If zero, returns immediately (no transfer queued). Otherwise:
; 1. Sets VMADDL to the destination address from $7F0C07
; 2. Clears $7F0C07 to prevent re-triggering
; 3. Loads the transfer byte count from $7F0C09
; 4. Loads the source address from adhocVramDma ($7F0C03) and bank from $7F0C05
; 5. Triggers DMA channel 0
; 
; Used by various engine systems to schedule deferred VRAM writes that execute during the next available DMA window, outside the normal NMI pipeline ordering.

DmaAdhocVramBlock {
    PHP 
    REP #$20
    LDA $7F0C07           ; Check $7F0C07 for pending VRAM destination address
    BEQ loc_03F1FF        ; No pending transfer — skip
    STA $VMADDL           ; Set VRAM destination, clear pending flag
    LDA #$0000
    STA $7F0C07
    LDA $7F0C09
    STA $DAS0L
    LDA $adhocVramDma     ; Source address from ad-hoc DMA parameter block ($7F0C03)
    STA $A1T0L
    SEP #$20
    LDA $7F0C05
    STA $A1B0
    LDA #$01
    STA $MDMAEN           ; Trigger DMA channel 0

  loc_03F1FF:
    PLP 
    RTL 
}