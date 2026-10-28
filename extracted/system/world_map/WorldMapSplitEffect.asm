; HDMA thinker of the world-map travel scene (Bank 03, 239678-239936), spawned by WorldMapController's route-launch phase (COP SpawnThinker). Every frame it builds two per-scanline HDMA tables - one for BGMODE ($2105), one for COLDATA ($2132) - that split the screen at a boundary row and, when a route starts, push that row down the screen. The labels of this file were first named after a sine table, a window and an iris (HdmaWindowEffect, QueueHdmaSineBuffers, UpdateHdmaWindowParams, InitSineTableBuffers, loc_ labels, binary_ templates); no sine table or window register is involved. The mnemonics sineTableA, sineTableB and S_sineTableB keep their names because they are shared with the scroll-wave code (ApplyScrollWaveEffect), where they really are sine tables.
; 
; === BUFFERS (double-buffered by frame parity, frameCounter bit 0) ===
; 
; Even frames: $7E8800 (BGMODE) and $7E8A00 (COLDATA). Odd frames: $7E8900 (sineTableA) and $7E8B00 (sineTableB). BuildSplitTables rebuilds the pair for the current parity and QueueSplitTables queues exactly that pair with COP QueueDma. The second operand of QueueDma is the PPU B-bus register ($2100 + #05 = BGMODE, #32 = COLDATA; hdma_channel_config gives each register's transfer mode), not an HDMA channel number.
; 
; === TABLE CONTENTS ===
; 
; BGMODE (template split_bgmode_template = 7F 07 | 18 07 | 01 09 | 00): 127 lines of $07 (Mode 7), then $18 + offset lines of $07, then one line of $09 (Mode 1 with BG3 priority), then the terminator, which BuildSplitTables writes itself. The last value ($09) stays in force below the table, so the screen is Mode 7 down to row 150 + offset and Mode 1 from row 151 + offset.
; COLDATA (template split_coldata_template = 7F 00 | 18 00 | 01 FF | 00): the same line counts with data $00 (no colour plane selected = no change), then one line of $FF (all planes, full intensity = white) on the boundary row. Only the first 6 bytes are copied; the bytes after them are what InitSplitFill left in the buffer: the $01FF fill reads as a count byte $FF (repeat mode, 127 lines) followed by data 01, FF, 01, FF, ..., so every other scanline below the boundary gets a white fixed-colour write. The template's seventh byte is never used.
; The per-actor offset in $7F2104,X (0 at spawn) is added to the second line count of both tables, so the boundary row moves by one line per offset step.
; 
; === PHASES (WorldMapSplitEffect) ===
; 
; Spawn: offset := 0, InitSplitFill, then SetEntryHere. Every frame the thinker re-enters at the check below that. While worldMapChoiceId ($0D58) is nonzero and worldMapRouteId ($0D5A) is zero (destination chosen, no route playing yet) it only rebuilds and queues the tables with the current offset. Otherwise (no destination, or a route id is set) it runs the opening sequence once: 2 frames of rebuild + queue, then 40 frames in which the offset grows by 2 per frame (second line count $18 -> $68, boundary row 151 -> 231, i.e. off the bottom of the 224-line screen), then it parks on a final SetEntryHere that keeps rebuilding and queuing with offset 80.
; What the strip below the boundary looks like on the world map (and whether it is the intended 'iris') is decoded from the tables, not observed (OQ-I058-1).
---------------------------------------------

!frameCounter                   0036
!worldMapChoiceId               0D58
!worldMapRouteId                0D5A
!sineTableA                     7E8900
!sineTableB                     7E8B00
!S_sineTableB                   8B00

---------------------------------------------

; Thinker entry: offset := 0, InitSplitFill, SetEntryHere; hold the tables at the current offset while a destination is chosen but no route plays; otherwise run the 2-frame hold, the 40-frame offset ramp (+2 per frame) and park (see the block note).

WorldMapSplitEffect {
    LDA #$0000            ; Boundary-row offset ($7F2104,X) := 0
    STA $7F2104, X
    JSR $&InitSplitFill   ; Fill the COLDATA buffers' tail pattern (see its note)
    COP [SetEntryHere]
    LDA $worldMapChoiceId ; Check destination ($0D58): zero = no travel, go to opening animation
    BEQ SplitOpeningSequence
    LDA $worldMapRouteId  ; Route id ($0D5A): nonzero = a route is playing, go to the opening sequence
    BNE SplitOpeningSequence
    JSR $&BuildSplitTables ; Destination chosen, route id still 0: rebuild + queue at the current offset
    JSR $&QueueSplitTables
    RTL 

; Opening sequence: 2 frames of rebuild + queue, 40 frames of offset += 2, then the parked final state.

  SplitOpeningSequence:
    COP [LoopStart] ( #02 ) ; Opening animation: 2-frame initial hold
    JSR $&BuildSplitTables
    JSR $&QueueSplitTables
    COP [LoopEnd]
    COP [LoopStart] ( #28 ) ; 40-frame split animation: advance the boundary-row offset by 2 each frame
    LDA $7F2104, X        ; Load the current boundary-row offset
    CLC 
    ADC #$0002            ; +2 lines: the boundary row moves down 2 lines per frame
    STA $7F2104, X
    JSR $&BuildSplitTables
    JSR $&QueueSplitTables
    COP [LoopEnd]
    COP [SetEntryHere]    ; Park: keep rebuilding + queuing with the final offset (80)
    JSR $&BuildSplitTables
    JSR $&QueueSplitTables
    RTL 
}

---------------------------------------------
; Queue the two tables built this frame with COP QueueDma: even frames $7E8800 -> BGMODE ($2105) and $7E8A00 -> COLDATA ($2132); odd frames $7E8900 and $7E8B00 to the same registers. Each COP takes a direct-table HDMA channel for the next frame.

QueueSplitTables {
    LDA $frameCounter     ; Frame parity check: even → buffer A ($8800/$8A00), odd → buffer B ($8900/$8B00)
    LSR 
    BCS QueueSplitTablesOdd
    COP [QueueDma] ( $7E8800, #05 ) ; Even frame: BGMODE ($2105) table at $7E8800
    COP [QueueDma] ( $7E8A00, #32 ) ; Even frame: COLDATA ($2132) table at $7E8A00
    RTS 

; Odd frames: tables at $7E8900 (sineTableA) and $7E8B00 (sineTableB).

  QueueSplitTablesOdd:
    COP [QueueDma] ( $sineTableA, #05 ) ; Odd frame: BGMODE ($2105) table at $7E8900
    COP [QueueDma] ( $sineTableB, #32 ) ; Odd frame: COLDATA ($2132) table at $7E8B00
    RTS 
}

---------------------------------------------
; Rebuild both HDMA tables for the buffer chosen by frame parity (Y = $0000 even, $0100 odd, with DBR = $7E): copy template 1 into $8800,Y and template 2 into $8A00,Y, adding the actor's offset ($7F2104,X) to each template's second line count (byte 2), and write the $0000 terminator after the BGMODE table only. The COLDATA table has no terminator; its tail is the fill from InitSplitFill.

BuildSplitTables {
    PHB                   ; Set DBR to $7E for direct WRAM buffer access
    SEP #$20
    LDA #$7E
    PHA 
    PLB 
    REP #$20
    LDA $0036             ; Frame parity: select buffer offset (even → Y=0, odd → Y=$100)
    LSR 
    BCS BuildSplitTablesOdd
    LDY #$0000
    BRA BuildSplitTablesCopy

; Odd frame: buffer offset Y = $0100.

  BuildSplitTablesOdd:
    LDY #$0100

; Copy both templates into the selected buffer pair.

  BuildSplitTablesCopy:
    LDA $@split_bgmode_template ; Template 1 bytes 0-1 (line count $7F, BGMODE $07) -> $8800,Y
    STA $8800, Y
    LDA $@split_coldata_template ; Template 2 bytes 0-1 (line count $7F, COLDATA $00) -> $8A00,Y
    STA $8A00, Y
    SEP #$20
    LDA $@split_bgmode_template+2 ; Template 1 byte 2: second line count ($18)
    CLC 
    ADC $7F2104, X        ; Plus the offset: the second step grows with it
    STA $8802, Y
    LDA $@split_bgmode_template+3 ; Template 1 byte 3: BGMODE $07
    STA $8803, Y
    LDA $@split_coldata_template+2 ; Template 2 byte 2: second line count ($18)
    CLC 
    ADC $7F2104, X        ; Plus the offset (same growth as table 1)
    STA $8A02, Y
    LDA $@split_coldata_template+3 ; Template 2 byte 3: COLDATA $00
    STA $8A03, Y
    REP #$20
    LDA $@split_bgmode_template+4 ; Template 1 bytes 4-5: 1 line of BGMODE $09 (Mode 1, BG3 priority) -> $8804,Y
    STA $8804, Y
    LDA $@split_coldata_template+4 ; Template 2 bytes 4-5: 1 line of COLDATA $FF (white) -> $8A04,Y
    STA $8A04, Y
    LDA #$0000            ; Terminator of the BGMODE table at $8806,Y (the COLDATA table has none)
    STA $8806, Y
    PLB 
    RTS 
}

---------------------------------------------
; Fill the two COLDATA buffers ($7E8A00 and $7E8B00; the BGMODE buffers are not touched) with 76 words of $01FF, then a $0000 word (DBR = $7E). Not a 'fully open window' (no window register is involved): after the template's first 6 bytes the fill reads as a repeat-mode count byte $FF and data 01, FF, 01, FF, ..., the alternating COLDATA writes below the boundary row. The terminator word is never reached because the screen ends first. Called once at spawn.

InitSplitFill {
    PHB                   ; Set DBR to $7E for direct buffer access
    SEP #$20
    LDA #$7E
    PHA 
    PLB 
    REP #$20
    LDY #$0000
    LDA #$01FF            ; Fill word $01FF (bytes FF 01): reads as repeat count $FF, then data 01, FF, 01, FF...

; Fill loop: one $01FF word into each COLDATA buffer per pass, 76 passes.

  InitSplitFillLoop:
    STA $8A00, Y          ; COLDATA buffer, even frames ($8A00)
    STA $S_sineTableB, Y  ; COLDATA buffer, odd frames ($8B00)
    INY 
    INY 
    CPY #$0098            ; 76 words (152 bytes) of tail
    BCC InitSplitFillLoop
    LDA #$0000            ; Terminator word after the fill (never reached: the screen ends first)
    STA $8A00, Y
    STA $S_sineTableB, Y
    PLB 
    RTS 
}

---------------------------------------------
; BGMODE template: 7F 07 | 18 07 | 01 09 | 00 (line count, value pairs; the final byte is never copied).

split_bgmode_template #7F071807010900

---------------------------------------------
; COLDATA template: 7F 00 | 18 00 | 01 FF | 00 (line count, value pairs; the final byte is never copied).

split_coldata_template #7F00180001FF00