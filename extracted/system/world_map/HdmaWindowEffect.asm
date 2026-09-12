; HDMA window effect thinker — scanline-based iris/spotlight for world map travel (239678–239936, Bank 03).
; 
; Spawned by WorldMapController.ArrivalAndTravelSetup during travel. Manages double-buffered sine table data for HDMA window registers to create an iris/spotlight visual transition on the world map.
; 
; === DOUBLE-BUFFERED SINE TABLES ===
; 
; Two buffer pairs, selected by frame parity ($0036 bit 0):
; - Even frames: $7E8800 (channel 5) + $7E8A00 (channel $32)
; - Odd frames: $7E8900 (channel 5) + $7E8B00 (channel $32)
; 
; InitSineTableBuffers fills both buffers with $01FF (76 entries + $0000 terminator), representing a fully-open window state.
; 
; === ANIMATION PHASES ===
; 
; Steady-state (route active, $0D58 ≠ 0 and $0D5A = 0): UpdateHdmaWindowParams + QueueHdmaSineBuffers each frame.
; 
; Opening animation ($0D58 = 0 or $0D5A ≠ 0):
; 1. 2-frame initial hold
; 2. 40-frame iris animation: $7F2104,X (per-actor HDMA offset) advances by 2 each frame, scrolling the sine table read position
; 3. Hold final state indefinitely
; 
; === HDMA PARAMETER WRITES (UpdateHdmaWindowParams) ===
; 
; Sets DBR to $7E, selects buffer by frame parity (Y = $0000 or $0100). Writes 7-byte HDMA parameter blocks from two templates (hdma_window1/2_template) into $8800,Y and $8A00,Y. Adds the actor's HDMA frame offset ($7F2104,X) to byte 2 of each template to animate the scanline source. Terminates with $0000 sentinel.
---------------------------------------------

!sineTableA                     7E8900
!sineTableB                     7E8B00
!S_sineTableB                   8B00

---------------------------------------------

; HDMA iris/window thinker — manages scanline-based windowing effect for world map travel.
; 
; Spawned by ArrivalAndTravelSetup. Initializes $7F2104,X (per-actor HDMA frame offset) to 0 and fills both sine table buffers with $01FF via InitSineTableBuffers (fully open window).
; 
; Steady-state (route active, $0D58 ≠ 0 and $0D5A = 0): updates HDMA params + queues DMA each frame, returns for next tick.
; 
; Opening animation ($0D58 = 0 or $0D5A ≠ 0):
; 1. 2-frame initial hold: update + DMA
; 2. 40-frame iris animation: increment $7F2104,X by 2 each frame (advances the sine table read offset), update + DMA
; 3. SetEntryContinue: hold final state indefinitely, update + DMA each tick

HdmaWindowEffect {
    LDA #$0000            ; Initialize HDMA frame offset to 0 for this actor
    STA $7F2104, X
    JSR $&InitSineTableBuffers ; Fill both sine table buffers with $01FF (fully open window)
    COP [SetEntryContinue]
    LDA $0D58             ; Check destination ($0D58): zero = no travel, go to opening animation
    BEQ loc_03A85B
    LDA $0D5A             ; Check route active ($0D5A): nonzero = arriving, go to opening animation
    BNE loc_03A85B
    JSR $&UpdateHdmaWindowParams ; Route in progress: update HDMA params + queue DMA, yield
    JSR $&QueueHdmaSineBuffers
    RTL 

  loc_03A85B:
    COP [LoopInit] ( #02 ) ; Opening animation: 2-frame initial hold
    JSR $&UpdateHdmaWindowParams
    JSR $&QueueHdmaSineBuffers
    COP [LoopNext]
    COP [LoopInit] ( #28 ) ; 40-frame iris animation: advance HDMA offset by 2 each frame
    LDA $7F2104, X        ; Load current HDMA frame offset
    CLC 
    ADC #$0002            ; Advance by 2 (scroll sine table by one entry)
    STA $7F2104, X
    JSR $&UpdateHdmaWindowParams
    JSR $&QueueHdmaSineBuffers
    COP [LoopNext]
    COP [SetEntryContinue] ; Hold final iris state indefinitely — update + DMA each tick
    JSR $&UpdateHdmaWindowParams
    JSR $&QueueHdmaSineBuffers
    RTL 
}

---------------------------------------------
; Queue DMA transfers for the active sine table buffer.
; 
; Double-buffered by frame parity (frame counter $0036 bit 0): even frames transfer from $7E8800 (channels 5+$32), odd frames from $7E8900. Each call queues two DMA operations via COP QueueDma to push the HDMA scanline data to the PPU during the next VBlank.

QueueHdmaSineBuffers {
    LDA $0036             ; Frame parity check: even → buffer A ($8800/$8A00), odd → buffer B ($8900/$8B00)
    LSR 
    BCS loc_03A899
    COP [QueueDma] ( $7E8800, #05 ) ; Even frame: queue DMA from $7E8800 (HDMA channel 5)
    COP [QueueDma] ( $7E8A00, #32 ) ; Even frame: queue DMA from $7E8A00 (HDMA channel $32)
    RTS 

  loc_03A899:
    COP [QueueDma] ( $7E8900, #05 ) ; Odd frame: queue DMA from $7E8900 (HDMA channel 5)
    COP [QueueDma] ( $7E8B00, #32 ) ; Odd frame: queue DMA from $7E8B00 (HDMA channel $32)
    RTS 
}

---------------------------------------------
; Write per-scanline HDMA window parameters into the double-buffered sine table WRAM.
; 
; Sets DBR to $7E for direct WRAM access. Selects buffer offset by frame parity (even → Y=$0000, odd → Y=$0100). Writes 7-byte HDMA parameter blocks from hdma_window1_template → $8800,Y and hdma_window2_template → $8A00,Y. Adds the current actor's HDMA frame offset ($7F2104,X) to byte 2 of each template (the scanline source row), producing the scrolling/iris animation. Terminates with a $0000 sentinel at $8806,Y.

UpdateHdmaWindowParams {
    PHB                   ; Set DBR to $7E for direct WRAM sine table access
    SEP #$20
    LDA #$7E
    PHA 
    PLB 
    REP #$20
    LDA $0036             ; Frame parity: select buffer offset (even → Y=0, odd → Y=$100)
    LSR 
    BCS loc_03A8BA
    LDY #$0000
    BRA loc_03A8BD

  loc_03A8BA:
    LDY #$0100

  loc_03A8BD:
    LDA $@binary_03A932   ; Write HDMA template 1 header to $8800,Y (window params)
    STA $8800, Y
    LDA $@binary_03A939   ; Write HDMA template 2 header to $8A00,Y
    STA $8A00, Y
    SEP #$20
    LDA $@binary_03A932+2 ; Load source row byte from template 1
    CLC 
    ADC $7F2104, X        ; Add HDMA frame offset ($7F2104,X) — animate scanline source
    STA $8802, Y
    LDA $@binary_03A932+3
    STA $8803, Y
    LDA $@binary_03A939+2 ; Load source row byte from template 2
    CLC 
    ADC $7F2104, X        ; Add HDMA frame offset for template 2 animation
    STA $8A02, Y
    LDA $@binary_03A939+3
    STA $8A03, Y
    REP #$20
    LDA $@binary_03A932+4 ; Write remaining template 1 parameters to $8804,Y
    STA $8804, Y
    LDA $@binary_03A939+4 ; Write remaining template 2 parameters to $8A04,Y
    STA $8A04, Y
    LDA #$0000            ; Write $0000 terminator at $8806,Y — end of HDMA table
    STA $8806, Y
    PLB 
    RTS 
}

---------------------------------------------
; Initialize both sine table double buffers to fully-open window state.
; 
; Sets DBR to $7E. Fills $8A00 and $8B00 (sineTableB) with $01FF for 76 entries (152 bytes = $0098), then writes a $0000 terminator. The $01FF value represents a fully-open HDMA window (left edge 1, right edge 255 = entire scanline visible). Called once during HdmaWindowEffect initialization.

InitSineTableBuffers {
    PHB                   ; Set DBR to $7E for direct buffer access
    SEP #$20
    LDA #$7E
    PHA 
    PLB 
    REP #$20
    LDY #$0000
    LDA #$01FF            ; Fill value $01FF = fully open window (left=1, right=255)

  loc_03A91A:
    STA $8A00, Y          ; Fill $8A00,Y (buffer B even) with $01FF
    STA $S_sineTableB, Y  ; Fill $8B00,Y (buffer B odd / sineTableB) with $01FF
    INY 
    INY 
    CPY #$0098            ; 76 entries (152 bytes / $0098) covers visible scanlines
    BCC loc_03A91A
    LDA #$0000            ; Write $0000 terminator after the last entry
    STA $8A00, Y
    STA $S_sineTableB, Y
    PLB 
    RTS 
}

binary_03A932 #7F071807010900

binary_03A939 #7F00180001FF00