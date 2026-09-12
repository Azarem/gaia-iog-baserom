; HDMA iris/circle window effect — per-scanline window generator using hardware multiply (239290–239678, Bank 03).
; 
; Thinker (type $04, priority $08) that generates circular window HDMA tables each frame. Double-buffered: odd frames write to $7E8D00, even frames to $7E8E00. Used in the prologue prophecy scene (scene $8C) and the world map (scene $FE) for spotlight/iris transitions.
; 
; === CIRCLE ALGORITHM ===
; 
; The circle radius is controlled by actor field $B6:
; - Base radius = $0400 − ($B6 / 2)
; - Step decrement per band: base_radius × 2 → $0E
; - Initial circle value: base_radius × 32 → $00 (fixed-point scaled)
; 
; For each of 16 scanline bands (X from $1E down to $00, 2 bytes per entry):
; 1. Perform 16×8 hardware multiply: circle_value × $60 (96) using WRMPYA/WRMPYB
; 2. Two 8×8 multiplies (low byte then high byte) with NOP delays for hardware latency
; 3. Combined 24-bit result: high byte ($04) = scanline count (window half-width at this band)
; 4. Write HDMA entry: scanline count at $8D00,X / window right edge at $8D01,X
; 5. Accumulate scanline count into running total ($08); handle overflow past 255
; 6. Right edge ($06) starts at $E0 and increments by 1 per band
; 7. Subtract step ($0E) from circle_value — each successive band is narrower
; 
; The result is a per-scanline window position gradient that approximates a circle cross-section. As $B6 increases, the radius shrinks and the iris closes.
; 
; === HDMA TABLE FORMAT ===
; 
; Each 2-byte entry: byte 0 = scanline count, byte 1 = window right edge position. Terminated by $E07F sentinel at end+2 and $0000 padding at end+4. The table is passed to SetupHdmaChannel_Direct with register $32 and bank $7E.
; 
; === OVERFLOW HANDLING ===
; 
; When the accumulated scanline count exceeds 255 (BCS after ADC $08), the final entry is adjusted: the excess is subtracted from the scanline count, and the right edge is written without incrementing. This ensures the table doesn't specify more than 256 total scanlines.
---------------------------------------------

?INCLUDE 'hdma_dma_spc'

!WRMPYA                         4202
!WRMPYB                         4203
!RDMPYL                         4216

---------------------------------------------

; HDMA iris/circle thinker entry point — odd-frame path writing to $7E8D00.
; 
; Saves and zeros the direct page register (PHD/TCD $0000) so all DP references use absolute addresses $00–$FF. Checks frame counter parity ($0036 bit 0): odd frames execute inline, even frames jump to IrisCircleEvenFrame.
; 
; === COMPUTATION (16 bands, odd frame → $7E8D00) ===
; 
; Setup:
; - WRMPYA = $60 (96) — constant multiplier for circle curve shaping
; - $06 = $E0 — starting right window edge (224px, near right side of screen)
; - $08 = $1F — running scanline accumulator (initial offset 31)
; - $0E = ($0400 − $B6/2) × 2 — per-band step decrement (controls circle curvature)
; - $00 = step × 16 — initial circle value (scaled up for fixed-point math)
; - X = $1E — start from band 15, decrement to 0
; - Write $E07F/$0000 sentinels at end of HDMA table
; 
; Per-band loop (loc_03A6FF):
; 1. 16×8 multiply via two 8×8 hardware ops: ($00 low × $60) → $02, ($01 high × $60) + carry → $03/$04
; 2. $04 = scanline count for this band (clamped to minimum 1)
; 3. Write scanline count to $7E8D00,X, right edge to $7E8D01,X
; 4. Accumulate scanline count into $08; BCS → overflow handler
; 5. Increment right edge ($06), subtract $0E from circle value ($00), DEX×2
; 
; === HDMA CHANNEL SETUP (loc_03A755) ===
; 
; Restores DP (PLA/TCD), constructs A = $7E32 (bank $7E, register $32), Y = $7E8D00 + X offset, calls SetupHdmaChannel_Direct to configure the HDMA channel for next VBlank.
; 
; === OVERFLOW HANDLER (loc_03A76F) ===
; 
; When accumulated scanlines exceed 255: subtracts the excess from the last band's scanline count and writes the final right edge without incrementing. Falls through to HDMA setup.

IrisCircleEffect [
  thinker-def < #04, #08, {

  code_03A6BC:
    PHD                   ; Save direct page; will zero DP so $00–$FF act as absolute addresses
    LDA #$0000            ; Set DP = $0000 for absolute zero-page access to scratch variables
    TCD 
    LDA $0036             ; Frame counter parity check: odd → inline path, even → IrisCircleEvenFrame
    LSR 
    BCS loc_03A6CA
    JMP $&IrisCircleEvenFrame ; Even frame → jump to second buffer path ($7E8E00)

  loc_03A6CA:
    LDA #$0060            ; Hardware multiply constant: WRMPYA = $60 (96) for circle curve scaling
    STA $WRMPYA
    LDA #$00E0            ; Starting right window edge = $E0 (224px, near right side of 256px screen)
    STA $06
    LDA #$001F            ; Running scanline accumulator initial value = $1F (31)
    STA $08
    LDA $B6               ; Read animation parameter $B6 — controls iris radius (larger = smaller circle)
    LSR                   ; Half of $B6 → subtract from base radius
    STA $0E
    LDA #$0400            ; Base radius $0400 (1024)
    SEC 
    SBC $0E               ; Effective radius = $0400 − ($B6/2); shrinks as $B6 increases
    ASL                   ; ×2 → per-band step decrement ($0E)
    STA $0E
    ASL                   ; Continue scaling: ×4 total from base
    ASL 
    ASL 
    ASL 
    STA $00               ; ×32 total → initial circle value in fixed-point ($00)
    LDX #$001E            ; Start from band 15 (X=$1E), processing 16 bands top-to-bottom
    LDA #$E07F            ; $E07F = HDMA table end sentinel
    STA $7E8D02, X
    LDA #$0000            ; $0000 padding after sentinel
    STA $7E8D04, X

  loc_03A6FF:
    STZ $04               ; Clear multiply accumulator high bytes
    STZ $02
    SEP #$20
    LDA $00               ; Low byte of circle value → WRMPYB (triggers $60 × low byte multiply)
    STA $WRMPYB
    REP #$20              ; Switch back to 16-bit to read result
    NOP                   ; 4× NOP: wait 8 cycles for hardware multiply to complete
    NOP 
    NOP 
    NOP 
    LDA $RDMPYL           ; Read multiply result (low portion) → $02
    STA $02
    SEP #$20
    LDA $01               ; High byte of circle value → WRMPYB (triggers $60 × high byte multiply)
    STA $WRMPYB
    REP #$20
    NOP 
    NOP 
    NOP 
    NOP 
    LDA $RDMPYL           ; Read high multiply result
    CLC 
    ADC $03               ; Add to accumulated low result at $03 — combined 24-bit product
    STA $03
    SEP #$20
    LDA $04               ; High byte $04 = scanline count (window half-width at this band)
    BNE loc_03A732        ; Nonzero → use as-is
    LDA #$01              ; Clamp minimum scanline count to 1 (zero would mean 256 in HDMA)

  loc_03A732:
    STA $7E8D00, X        ; Write scanline count to HDMA table at $7E8D00,X
    CLC 
    ADC $08               ; Accumulate scanline count into running total
    STA $08
    BCS loc_03A76F        ; Carry = total > 255 → overflow handler (final band adjustment)
    LDA $06               ; Write current right edge position to $7E8D01,X
    STA $7E8D01, X
    INC                   ; Advance right edge by 1 for next band (window widens)
    STA $06
    REP #$20
    LDA $00               ; Subtract step ($0E) from circle value — next band is narrower
    SEC 
    SBC $0E
    STA $00
    DEX                   ; DEX×2: move to next 2-byte HDMA entry
    DEX 
    BPL loc_03A6FF        ; Loop until all 16 bands processed (X goes negative)
    INX                   ; Adjust X back to 0 (first valid entry) for HDMA source offset
    INX 

  loc_03A755:
    TXY                   ; X → Y: HDMA table start offset for SetupHdmaChannel_Direct
    PLA                   ; Restore original direct page from stack (pushed by PHD at entry)
    TCD 
    TAX                   ; DP value → X: restore actor index
    SEP #$20
    LDA #$32              ; HDMA register target $32 → high byte of A
    XBA 
    LDA #$7E              ; Bank $7E → low byte of A; A = $7E32 (bank + register packed)
    REP #$20
    PHA 
    TYA 
    CLC 
    ADC #$8D00            ; Y = $8D00 + offset = WRAM source address for HDMA table
    TAY 
    PLA 
    JSL $@hdma_dma_spc.SetupHdmaChannel_Direct ; Configure HDMA channel with table source and register target
    RTL 

  loc_03A76F:
    LDA $7E8D00, X        ; Overflow: read last scanline count from $7E8D00,X
    SEC 
    SBC $08               ; Subtract the excess (amount past 255) from last band
    STA $7E8D00, X
    LDA $06               ; Write right edge for truncated final band
    STA $7E8D01, X
    REP #$20              ; Switch to 16-bit and fall through to HDMA channel setup
    BRA loc_03A755
} >
]

---------------------------------------------
; Even-frame path of the iris circle generator — identical algorithm writing to $7E8E00.
; 
; Mirrors IrisCircleEffect's odd-frame computation exactly, with all WRAM references offset from $7E8D00 to $7E8E00. The HDMA setup (loc_03A80F) passes Y = $7E8E00 + offset to SetupHdmaChannel_Direct. The overflow handler (loc_03A829) adjusts $7E8E00,X entries. Double-buffering prevents visual tearing: while one buffer drives the current frame's HDMA, the other is being regenerated for the next frame.

IrisCircleEvenFrame {
    LDA #$0060            ; Even frame: identical algorithm writing to $7E8E00 buffer
    STA $WRMPYA
    LDA #$00E0
    STA $06
    LDA #$001F
    STA $08
    LDA $B6               ; Read $B6 animation parameter (same iris radius control)
    LSR 
    STA $0E
    LDA #$0400            ; Base radius $0400, same computation as odd frame
    SEC 
    SBC $0E
    ASL 
    STA $0E
    ASL 
    ASL 
    ASL 
    ASL 
    STA $00
    LDX #$001E
    LDA #$E07F            ; HDMA end sentinel for even buffer at $7E8E02,X
    STA $7E8E02, X
    LDA #$0000
    STA $7E8E04, X

  loc_03A7B9:
    STZ $04
    STZ $02
    SEP #$20
    LDA $00               ; 16×8 multiply: circle_value low byte × $60
    STA $WRMPYB
    REP #$20
    NOP 
    NOP 
    NOP 
    NOP 
    LDA $RDMPYL
    STA $02
    SEP #$20
    LDA $01               ; 16×8 multiply: circle_value high byte × $60
    STA $WRMPYB
    REP #$20
    NOP 
    NOP 
    NOP 
    NOP 
    LDA $RDMPYL
    CLC 
    ADC $03
    STA $03
    SEP #$20
    LDA $04
    BNE loc_03A7EC
    LDA #$01              ; Clamp minimum scanline count to 1

  loc_03A7EC:
    STA $7E8E00, X        ; Write scanline count to $7E8E00,X (even buffer)
    CLC 
    ADC $08
    STA $08
    BCS loc_03A829        ; Carry → overflow handler for even buffer
    LDA $06
    STA $7E8E01, X
    INC 
    STA $06
    REP #$20
    LDA $00
    SEC 
    SBC $0E
    STA $00
    DEX 
    DEX 
    BPL loc_03A7B9
    INX 
    INX 

  loc_03A80F:
    TXY 
    PLA 
    TCD 
    TAX 
    SEP #$20
    LDA #$32              ; HDMA register $32, bank $7E for even buffer
    XBA 
    LDA #$7E
    REP #$20
    PHA 
    TYA 
    CLC 
    ADC #$8E00            ; Y = $8E00 + offset = even frame WRAM source
    TAY 
    PLA 
    JSL $@hdma_dma_spc.SetupHdmaChannel_Direct ; Configure HDMA channel from even buffer
    RTL 

  loc_03A829:
    LDA $7E8E00, X        ; Even overflow: adjust last band's scanline count
    SEC 
    SBC $08
    STA $7E8E00, X
    LDA $06
    STA $7E8E01, X
    REP #$20
    BRA loc_03A80F
}