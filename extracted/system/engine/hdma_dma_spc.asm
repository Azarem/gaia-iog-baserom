; DMA, HDMA, and SPC audio utility routines (252033–252182 + 254128–254549 + 258512–258561, Bank 03).
; 
; A mixed utility block spanning three non-contiguous address ranges, providing hardware transfer and audio infrastructure used by the scene lifecycle, NMI handler, and actor/thinker systems.
; 
; === PLAYER TILE DMA (252033–252182) ===
; 
; DmaPlayerTilesToVram uploads the player's queued 16×16 sprite tiles from WRAM to VRAM. ClearSceneState calls it during scene loading and the NMI handler calls it whenever displayModeFlags bit 3 is set (in that NMI it replaces DmaAdhocVramBlock and the write-queue flush). The list at $06FE is one bank byte (playerTileDmaBank) followed by word pointers; each pointer addresses 64 bytes of upper-half tile rows and the lower half lies $0200 bytes further on. Four passes: upper halves of the first 8 pointers to VRAM $4000, upper halves of the pointers after the 8th (until a zero pointer) to $4200, lower halves to $4100, lower-half continuation to $4300.
; 
; === PALETTE-BUNDLE ANIMATION (254128–254278) ===
; 
; LoadPaletteBundle and CopyPaletteBundleFrame are the two halves of one palette-animation step. Only the five palette-bundle COP handlers (#36–#3A, cop_handlers_palette) call them. A bundle (palette_bundles table, ROM bank $96) is a list of 6-byte sub-entries, and each sub-entry is an animation STRIP of N frames: byte 0 = frame count N (0 ends the bundle), bytes 1–2 = address in bank $96 of the first frame's colors, byte 3 = first CGRAM color index (destination = $7F0A00 + 2 × index, the palette staging buffer), byte 4 = frame size − 1 in bytes ($0D = 7 colors, $03 = 2 colors, $02 = one 3-byte backdrop RGB triplet), byte 5 = extra ticks to wait between frames. The frames of a strip are stored back to back (a strip with N = 8 and byte 4 = 3 is followed by exactly 32 bytes of colors, then the next sub-entry's data), and every step overwrites the same destination with the next frame. LoadPaletteBundle fills the actor fields from the next sub-entry (N → spritesetPtr, source → chatPtr, destination → metaspritePtr, size − 1 → $7F0008, wait → DP $08 and animScratch); CopyPaletteBundleFrame (nothing is decompressed and VRAM is not touched) block-moves one frame with the RAM stub at $0402 (PHB / MVN $7F,$96 / PLB / RTS, written by system_init) and advances chatPtr to the next frame. The 14 shipped sub-entries with byte 4 = 2 write the backdrop triplet: LoadPaletteBundle then adds $0200 to the destination so $7F0A00 + $0200 = backdropColors ($7F0C00).
; 
; === HDMA CHANNEL MANAGEMENT (254278–254378) ===
; 
; ResetHdmaState (called by every frame routine: the main loop, UpdateFrameDialogue, UpdateFrameRender, UpdateFrameFull and the scene-start sequence, always after the type-A/C thinkers and before the type-B/D ones) clears the allocation state: enable mask $66 = 0, next channel bit $68 = $02 (channel 1), register block offset $6A = $10. $6C is a one-shot lock: when negative the reset is skipped once; scene_lifecycle's wave transition calls ResetHdmaState explicitly, arms $6C = $FF and runs ApplyScrollWaveEffect, whose UpdateFrameDialogue call then skips its reset (and clears $6C) so the HDMA the wave just bound survives that frame.
; 
; SetupHdmaChannel_Indirect and SetupHdmaChannel_Direct bind the next free channel (1–7): A = bank byte (low) | B-bus register number (high), Y = table address. The register number indexes hdma_channel_config to get the DMAP transfer mode (the indirect entry ORs $40 and also writes the table bank to DASB). Both finish in a shared tail that writes BBADx, A1Tx and A1Bx, sets the channel's bit in the enable mask and advances $68/$6A. The tail's ADC #$10 has no CLC: the carry is the carry-out of ASL $0068, which is clear for channels 1–6, so seven channels is the maximum (binding the 7th leaves $6A = $81).
; 
; === SPC MUSIC CHANGE (254378–254549) ===
; 
; StartMusic and FadeThenStartMusic (cop_handlers_audio) spawn a thinker that enters at SpcTransferMusicData or SpcFadeOutHandshake with the music ID in chatPtr. The thinker talks to the SPC sound engine through port commands on APUIO0 (docs/audio/spc-disassembly.md, ProcessPortCommand): $F1 = CmdFadeOut (sets the engine's fade counters $30/$31 to $FF), $F0 = CmdStop, $FF = jump into the engine's resident clone of the IPL loader (sub_0f89), which posts $BBAA and speaks the boot-ROM upload protocol; $01 enters the engine's ASL-to-$02 path (ClearAramTail, stream pointer from ARAM $0FFC). SpcFadeOutHandshake's $F1 IS the fade-out request, performed inside the SPC engine, not by 65816 code (not traced: whether the fade is audible before the following $01/$F0 commands).
; 
; Sequence: the thinker stages the ID in musicTransitionState; the main loop's LoadMusicFromTransitionState (once per pass, after UpdateHUD) turns it into a music_pointer_array entry, enables NMI and joypad and runs spc_transfer.SpcBlockTransfer (blocking; the NMI calls UpdateFrameFull each frame meanwhile), then stores $FFFF, which releases the thinker: it waits two actor ticks (COP WaitByte #01 = N + 1 ticks: a plain delay, not an SPC acknowledgment), sends $01, clears sfxQueueCh1 and musicTransitionState and dies.
; 
; === AD-HOC VRAM DMA (258512–258561) ===
; 
; DmaAdhocVramBlock executes one-shot VRAM transfers queued at $7F0C03–$7F0C09 (source word, source bank, destination word = trigger, byte count). It only runs from the NMI handler, which has just programmed VMAIN = $80, DMAP0 = $01 and BBAD0 = $18 for it, and it is skipped when dmaSkipFlag is set or when displayModeFlags bit 3 selected the player-tile path instead. The destination word is the pending flag: the NMI runs the transfer when it is nonzero. Both writers (RadarScreenSetup and the AdhocVramDma COP handler) store the destination before the size. Measured: in every pair (radar screen, credits scene, boot) the NMI was off at both stores and no NMI ran between them. Actors normally run with NMITIMEN = $01, but the first UpdateFrameDialogue pass after a scene load runs RunActors_CutsceneOnly with NMITIMEN = $81, and neither writer guards against an NMI between its two stores there. A writer that can run with the NMI on has to store the size first.
---------------------------------------------

?BANK 03

?INCLUDE 'hdma_ramp_tables'
?INCLUDE 'music_pointer_array'
?INCLUDE 'palette_bundles'
?INCLUDE 'spc_transfer'
?INCLUDE 'vblank_joypad'

!hdmaEnableMask                 0066
!srcCacheMusic                  0687
!sfxQueueCh1                    06F8
!musicTransitionState           06FA
!playerTileDmaBank              06FE
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
!adhocVramDmaBank               7F0C05
!adhocVramDmaDest               7F0C07
!adhocVramDmaSize               7F0C09

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
    LDA $playerTileDmaBank ; Source bank from $06FE tile pointer table header
    STA $A1B0
    LDY #$0001            ; Y=1 — first tile pointer (skip table header)
    LDX #$4000            ; Upper-half tiles → VRAM $4000
    STX $VMADDL
    JSR $&DmaPlayerTiles_UpperHalf ; DMA upper rows of all queued tiles
    CPY #$0011            ; All 8 slots consumed? (Y=$11) — overflow to $4200
    BNE loc_03D8BD
    LDX #$4200
    STX $VMADDL
    JSR $&DmaPlayerTiles_UpperHalf ; Second pass continues with the 9th pointer (Y is not reset) until a zero pointer; VRAM $4200

  loc_03D8BD:
    LDY #$0001            ; Re-walk table for lower halves → VRAM $4100
    LDX #$4100
    STX $VMADDL
    JSR $&DmaPlayerTiles_LowerHalf
    CPY #$0011            ; Lower overflow → VRAM $4300
    BNE loc_03D8D7
    LDX #$4300
    STX $VMADDL
    JSR $&DmaPlayerTiles_LowerHalf ; Same continuation for the lower halves; VRAM $4300

  loc_03D8D7:
    RTL 
}

---------------------------------------------
; Transfer up to 8 upper-half tile rows to VRAM. Reads word pointers from the playerTileDmaBank list starting at Y (from $06FF), programs one 64-byte DMA per pointer (A1T0 = pointer, DAS0 = $40) and stops when Y reaches $11 (8 entries) or a pointer is zero. Y is not reset between the first and the continuation pass.

DmaPlayerTiles_UpperHalf {
    LDX $playerTileDmaBank, Y ; Load next tile source pointer from $06FE,Y
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
    LDA $playerTileDmaBank, Y
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

; Load the next palette-bundle sub-entry into the actor's fields (called by the palette-bundle COP handlers with X = D = the thinker slot).
; 
; Switches the data bank to $96 (ROM bank of palette_bundles), takes the bundle ID from animScratch+2, finds the sub-entry at palette_bundles[ID] + 6 × $0E and reads its six bytes:
; - byte 0: frame count N of this strip (zero = end of bundle) → spritesetPtr ($7F0006); PaletteStep decrements it once per step;
; - bytes 1–2: source address of the strip's first frame, in bank $96 → chatPtr ($7F000A);
; - byte 3: first CGRAM color index; destination offset = $0A00 + 2 × index (the $7F0A00 palette staging buffer) → metaspritePtr ($7F000C);
; - byte 4: frame size − 1 in bytes ($0D = 7 colors, $03 = 2 colors, $02 = one backdrop RGB triplet) → $7F0008;
; - byte 5: extra ticks to wait between frames → DP $08 (the wait counter) and animScratch ($7F0000), so PaletteStep can re-seed $08.
; 
; Then increments the sub-entry index $0E. When byte 4 is 2, the word at $7F000D (the high byte of metaspritePtr) gets +2, i.e. the destination moves by +$0200: index 0 then lands on backdropColors ($7F0C00); all 14 shipped length-2 sub-entries use color index 0.
; 
; Returns carry clear when a sub-entry was loaded, carry set (and $0E reset to 0) when byte 0 was zero. The field names (spritesetPtr, chatPtr, metaspritePtr) are borrowed from the sprite actors; the thinkers use them as frames-left, source pointer and destination pointer.

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
    LDA $0E               ; Sub-entry offset: $0E x 6 (6-byte sub-entries: count, source word, color index, size - 1, wait)
    ASL 
    CLC 
    ADC $0E
    ASL 
    CLC 
    ADC $01, S
    PLY 
    TAY 
    LDA $0000, Y          ; Sub-entry byte 0 = frame count of the strip (zero = end of bundle)
    AND #$00FF
    BEQ loc_03E11F
    STA $spritesetPtr, X  ; Frame count N → spritesetPtr; PaletteStep decrements it once per step
    LDA $0001, Y          ; Bytes 1-2: address of the strip's first frame, in bank $96
    STA $chatPtr, X       ; chatPtr = source pointer; CopyPaletteBundleFrame advances it frame by frame
    LDA $0003, Y          ; Byte 3 = first CGRAM color index to overwrite
    AND #$00FF
    ASL 
    CLC 
    ADC #$0A00            ; Destination offset in bank $7F: $0A00 + 2 × index (palette staging buffer)
    STA $metaspritePtr, X ; metaspritePtr is reused as the MVN destination offset
    LDA $0004, Y          ; Byte 4 = frame size - 1 in bytes ($0D = 7 colors, $02 = backdrop RGB triplet)
    AND #$00FF
    STA $7F0008, X        ; Frame size - 1 kept in $7F0008 for CopyPaletteBundleFrame
    PHA 
    LDA $0005, Y          ; Byte 5 = extra ticks to wait between frames
    AND #$00FF
    STA $08               ; DP $08 is the wait counter: the next step runs after this many extra ticks
    STA $animScratch, X   ; Copy kept in animScratch so PaletteStep can re-seed $08 for the later frames
    INC $0E               ; Advance sub-entry counter for next LoadPaletteBundle call
    PLA 
    CMP #$0002            ; Frame size - 1 = 2: a 3-byte backdrop color triplet
    BNE loc_03E11B
    LDA $7F000D, X        ; Word at $7F000D covers the high byte of metaspritePtr; +2 moves the destination by +$0200
    INC 
    INC 
    STA $7F000D, X        ; $0A00 + $0200 = $0C00 = backdropColors (color index 0 in all 14 shipped sub-entries)

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
; Apply one palette-bundle frame: copy a block of colors from ROM into the palette staging buffer (not a decompression, and no VRAM is touched).
; 
; Programs the RAM block-move stub at $0402 (PHB / MVN / PLB / RTS, written by system_init): one 16-bit store of $967F puts $7F in $0404 (MVN destination bank) and $96 in $0405 (source bank, the palette_bundles bank). Then A = $7F0008,X (frame size − 1), Y = metaspritePtr (destination offset in bank $7F), X = chatPtr (source offset in bank $96) and JSR $0402. MVN leaves X one past the last source byte; it is stored back to chatPtr, so the next call copies the following frame of the strip to the same destination. The caller's X is saved around the call.
; 
; The NMI later uploads the $7F0A00 staging buffer to CGRAM (UploadCgramPalette) and the backdrop triplet at $7F0C00 to the fixed color; this routine only edits those RAM mirrors.

CopyPaletteBundleFrame {
    PHX 
    LDA #$967F            ; $0404 = $7F (MVN destination bank), $0405 = $96 (source bank); one 16-bit store
    STA $0404
    LDA $7F0008, X        ; A = frame size - 1 (byte count for MVN)
    PHA 
    LDA $metaspritePtr, X ; Y = destination offset (palette staging buffer, bank $7F)
    TAY 
    LDA $chatPtr, X       ; X = source offset (bank $96)
    TAX 
    PLA 
    JSR $0402             ; RAM stub: PHB, MVN $7F,$96, PLB, return; copies A + 1 bytes (palette staging, no VRAM)
    TXA                   ; MVN leaves X one past the last source byte
    PLX 
    STA $chatPtr, X       ; chatPtr now addresses the strip's next frame for the next call
    RTL 
}

---------------------------------------------
; Reset the HDMA channel allocation state for fresh channel assignment (every frame routine calls this once per frame before the type-B/D thinkers).
; 
; If $6C is negative (bit 7 set) the reset is skipped. $6C is a one-shot lock: scene_lifecycle's wave transition arms it ($FF) right after its own explicit reset so that the ApplyScrollWaveEffect → UpdateFrameDialogue call does not wipe the HDMA channels the wave just bound.
; 
; Otherwise clears the HDMA enable mask ($66 = 0), resets the next channel bit to channel 1 ($68 = $02) and the DMA register block offset to channel 1 ($6A = $10). SetupHdmaChannel_Indirect/Direct consume these three bytes.
; 
; Always clears the lock ($6C = 0) on exit, so the lock covers exactly one call.

ResetHdmaState {
    LDA $6C               ; $6C is a one-shot lock: negative skips this reset only
    BMI loc_03E154        ; Locked: keep the channels bound since the last reset
    STZ $66               ; Clear HDMA enable mask, reset channel allocation to ch1/$10
    LDA #$02
    STA $68
    LDA #$10
    STA $6A

  loc_03E154:
    STZ $6C               ; Consume the lock (the wave transition re-arms it after its explicit reset)
    RTL 
}

---------------------------------------------
; Bind the next free HDMA channel in indirect mode (JSL from the HDMA COP handlers and the thinker scripts).
; 
; Entry: 16-bit A = table bank (low byte) | PPU B-bus register number (high byte, e.g. $0D = BG1HOFS), Y = HDMA table address. The routine pushes the bank, then the register number, uses the register number to index hdma_channel_config (DMAP transfer mode), ORs $40 (indirect) into it and writes DMAP of the channel whose register block offset is in $6A. The bank also goes to DASB (indirect data bank), so the table and the data it points to share one bank. It then branches into the shared tail inside SetupHdmaChannel_Direct (loc_03E186).
; 
; Indirect HDMA: each table entry is a line count plus a pointer to the data, so the data can live elsewhere in the bank and be changed per frame without rewriting the table.

SetupHdmaChannel_Indirect {
    PHP 
    PHX 
    SEP #$20
    PHA                   ; Push the bank byte (A low)
    LDA #$00
    XBA                   ; XBA brings the B-bus register number (A high) into A; it is pushed and used as the table index
    PHA 
    TAX 
    LDA $&hdma_ramp_tables.hdma_channel_config, X ; hdma_channel_config[register]: DMAP transfer mode for this B-bus register
    LDX $006A             ; X = DMA register block offset of the channel being bound ($10, $20, ...)
    ORA #$40              ; Set indirect mode flag ($40) in DMAP register
    STA $DMAP0, X
    LDA $02, S            ; Stack holds register number (S+1) and bank (S+2): the bank is also the indirect data bank
    STA $DASB0, X         ; Set indirect bank byte (DASB0) for pointer resolution
    BRA loc_03E186
}

---------------------------------------------
; Bind the next free HDMA channel in direct mode. Same entry convention as SetupHdmaChannel_Indirect (A = bank | register << 8, Y = table address) but DMAP gets the plain hdma_channel_config mode.
; 
; The shared tail (loc_03E186, also reached from the indirect entry) pops the register number into BBADx, stores Y into A1Tx and the bank into A1Bx, sets this channel's bit ($68) in the HDMA enable mask ($66), shifts $68 left and adds $10 to $6A. There is no CLC before that ADC: the carry is the carry-out of ASL $0068, clear for channels 1–6, so at most seven channels (1–7) can be bound per frame.
; 
; Direct HDMA: each table entry is a line count followed by the register value(s) to write.

SetupHdmaChannel_Direct {
    PHP 
    PHX 
    SEP #$20
    PHA 
    LDA #$00
    XBA 
    PHA 
    TAX 
    LDA $&hdma_ramp_tables.hdma_channel_config, X ; Same register lookup as the indirect entry, without the $40 flag
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
    STA $A1B0, X          ; Table bank (the byte pushed first)
    LDA $0068             ; Enable this channel bit in HDMA mask ($0066)
    TSB $hdmaEnableMask
    ASL $0068             ; Next channel bit; the carry-out feeds the ADC below
    LDA $006A             ; Advance register offset +$10 to next DMA channel block
    ADC #$10              ; No CLC: carry is the ASL out of bit 7 (set only after channel 7); next block offset = +$10
    STA $006A
    PLX 
    PLP 
    RTL 
}

---------------------------------------------
; Entry of the FadeThenStartMusic thinker: request the SPC engine's fade-out, then hand over to SpcTransferMusicData.
; 
; 1. Sends $F1 to APUIO0 (the engine's CmdFadeOut: fade counters $30/$31 = $FF) and yields one frame. If APUIO0 does not echo $F1 the routine returns and runs again next frame.
; 2. With the echo seen, sends $01 and yields again. If APUIO0 now reads zero, execution falls into SpcTransferMusicData; otherwise it returns and retries.
; 
; Runs as a thinker script: each COP SetEntryHereAndYield suspends it until the next frame, so the handshake costs a few frames but never blocks the main loop. Not traced: whether the fade is audible before SpcTransferMusicData's $F0 stop arrives one or two frames later.

SpcFadeOutHandshake {
    SEP #$20
    LDA #$F1              ; Port command $F1 = SPC engine CmdFadeOut (fade counters $30/$31 = $FF)
    STA $APUIO0
    REP #$20
    COP [SetEntryHereAndYield] ; Yield — wait one frame for SPC to process
    LDA $APUIO0
    AND #$00FF
    CMP #$00F1            ; Check for $F1 echo — SPC acknowledged?
    BEQ loc_03E1C1
    RTL                   ; Not ready — return (retry next frame)

  loc_03E1C1:
    SEP #$20
    LDA #$01              ; Port command $01: engine path ASL to $02 (ClearAramTail, stream pointer from ARAM $0FFC); not traced further
    STA $APUIO0           ; SPC ready — send $01 transfer request
    REP #$20
    COP [SetEntryHereAndYield]
    SEP #$20
    LDA $APUIO0
    REP #$20
    BEQ SpcTransferMusicData ; SPC confirmed zero → begin data transfer
    RTL 
}

---------------------------------------------
; Thinker script that requests the music upload and waits for the main loop to perform it (entry of StartMusic's thinker; also reached from SpcFadeOutHandshake).
; 
; Sends $F0 (the engine's CmdStop), yields and requires a zero echo; yields again, sends $FF (jump into the engine's resident IPL-clone loader, which then posts $BBAA) and copies the music ID from chatPtr into musicTransitionState ($06FA); this staged ID is what LoadMusicFromTransitionState picks up.
; 
; Then waits (one yield per frame) for musicTransitionState = $FFFF, which LoadMusicFromTransitionState writes after the blocking SpcBlockTransfer. Once seen: COP WaitByte #01 (a two-tick delay, N + 1; not an SPC acknowledgment), sends $01, yields once more, clears sfxQueueCh1 and musicTransitionState and ends with COP Die.
; 
; Only the block transfer itself blocks the main loop; every protocol step here is spread over frames.

SpcTransferMusicData {
    SEP #$20
    LDA #$F0              ; Port command $F0 = CmdStop (the engine's stop command, not a transfer-start signal)
    STA $APUIO0
    REP #$20
    COP [SetEntryHereAndYield]
    SEP #$20
    LDA $APUIO0
    REP #$20
    BEQ loc_03E1EB        ; SPC acknowledged — proceed with transfer
    RTL 

  loc_03E1EB:
    COP [SetEntryHereAndYield]
    SEP #$20
    LDA #$FF              ; Port command $FF = jump into the engine's resident IPL-clone loader, which posts $BBAA
    STA $APUIO0
    REP #$20
    LDA $chatPtr, X       ; chatPtr holds the music ID from StartMusic/FadeThenStartMusic (an ID, not a pointer)
    STA $musicTransitionState
    COP [SetEntryHereAndYield]
    LDA $musicTransitionState
    CMP #$FFFF            ; Wait for $FFFF (written by the main loop's LoadMusicFromTransitionState after the SPC upload)
    BEQ loc_03E208
    RTL 

  loc_03E208:
    COP [WaitByte] ( #01 ) ; WaitByte #01 = 2 actor ticks (N + 1): a plain delay, not an SPC acknowledgment
    SEP #$20
    LDA #$01
    STA $APUIO0
    REP #$20
    COP [SetEntryHereAndYield]
    STZ $sfxQueueCh1      ; Clear SFX queue and musicTransitionState, then die
    STZ $musicTransitionState
    COP [Die]
}

---------------------------------------------
; Resolve a staged music ID and run the SPC block transfer.
; 
; Called once per main-loop pass from MainLoop, after UpdateHUD. Returns at once if musicTransitionState is zero or negative (no pending music change or already done).
; 
; For a positive ID it computes the music_pointer_array offset (ID − 1) × 3 (3-byte entries: address + bank) and loads the address into DP $46/$47 and into the shadow bytes $0687/$0688. It then enables NMI and joypad, calls SpcBlockTransfer (blocking; the NMI calls UpdateFrameFull every frame while musicTransitionState is positive), switches to DisableNmiKeepJoypad (NMITIMEN = $01: NMI off, joypad auto-read on; the main loop turns NMI on again at the end of the pass) and stores $FFFF into musicTransitionState to release the waiting SpcTransferMusicData thinker.

LoadMusicFromTransitionState {
    LDX $musicTransitionState
    BEQ loc_03E254        ; No pending music (zero) — return immediately
    BMI loc_03E254        ; Negative musicTransitionState — return (already complete)
    REP #$20
    TXA                   ; music_pointer_array offset: the ID x 3 is added below and the table is read at -3, so the entry is (ID - 1) x 3
    ASL 
    CLC 
    ADC $musicTransitionState
    TAX 
    LDA $@music_pointer_array-3, X ; Load music data address + bank from music_array table
    STA $46
    STA $srcCacheMusic
    LDA $@music_pointer_array-2, X
    STA $47
    STA $srcCacheMusic+1
    JSL $@vblank_joypad.EnableNmiAndJoypad ; NMI on for the blocking transfer: the NMI runs UpdateFrameFull while the ID is positive
    JSL $@spc_transfer.SpcBlockTransfer ; Blocking SPC upload: SpcBlockTransfer speaks the IPL byte-stream protocol (not DMA)
    JSL $@vblank_joypad.DisableNmiKeepJoypad ; NMITIMEN = $01: NMI off again, joypad auto-read only; the main loop re-enables NMI at the end of the pass
    LDA #$FFFF            ; Mark musicTransitionState = $FFFF (transfer complete)
    STA $musicTransitionState
    SEP #$20

  loc_03E254:
    RTL 
}
---------------------------------------------

; Execute a one-shot VRAM DMA from the queued parameters (called only from NmiHandler).
; 
; Checks $7F0C07 for a pending VRAM destination. If zero, returns immediately. Otherwise:
; 1. Writes the destination to VMADDL and clears $7F0C07 (the trigger);
; 2. Loads the byte count from $7F0C09 into DAS0;
; 3. Loads the source address from adhocVramDma ($7F0C03) and the bank from $7F0C05;
; 4. Fires DMA channel 0.
; 
; Channel 0 is not programmed here: NmiHandler has just written VMAIN = $80, DMAP0 = $01 and BBAD0 = $18 (word writes to VRAM data), so this routine is not safe to call from anywhere else. It is skipped when dmaSkipFlag is set, and the NMI uses the player-tile path instead when displayModeFlags bit 3 is set.

DmaAdhocVramBlock {
    PHP 
    REP #$20
    LDA $adhocVramDmaDest ; Check $7F0C07 for pending VRAM destination address
    BEQ loc_03F1FF        ; No pending transfer — skip
    STA $VMADDL           ; Set VRAM destination, clear pending flag
    LDA #$0000
    STA $adhocVramDmaDest
    LDA $adhocVramDmaSize
    STA $DAS0L
    LDA $adhocVramDma     ; Source address from ad-hoc DMA parameter block ($7F0C03)
    STA $A1T0L
    SEP #$20
    LDA $adhocVramDmaBank
    STA $A1B0
    LDA #$01
    STA $MDMAEN           ; Channel 0 uses VMAIN/DMAP0/BBAD0 as NmiHandler programmed them just before; not callable elsewhere

  loc_03F1FF:
    PLP 
    RTL 
}