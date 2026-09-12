; Unused Mode 7 perspective variant — alternate HDMA table generation with indirect headers (240520–241015, Bank 03).
; 
; An earlier or alternate implementation of the Mode 7 perspective rotation system (compare mode7_perspective at 239936). Never referenced by any scene actor, thinker spawn, or COP handler in the shipped ROM. Uses the same sine/cosine tables and 4-quadrant hardware divide approach but differs in several significant ways.
; 
; === DIFFERENCES FROM ACTIVE VERSION (mode7_perspective) ===
; 
; 1. HDMA table format: Uses 3-entry indirect HDMA headers. Each table gets three $F0 (240) scanline-count entries at offset 0/3/6, with WRAM data addresses ($7100/$71E0 for M7A, $7900/$79E0 for M7B, $8100/$81E0 for M7C) written as 16-bit words. Matrix data fills the data regions ($7E7100, $7E7900, $7E8100) separately.
; 
; 2. Fill direction: X starts at $01C0 and decrements (DEX×2), filling data regions from high offset to low. The active version fills from X=$0000 upward.
; 
; 3. Perspective direction: Subtracts rotation increment (SEC/SBC $04) instead of adding (CLC/ADC). This inverts the foreshortening — near scanlines would be scaled more than distant ones.
; 
; 4. No NormalizeDivisor: Does not pre-normalize the divisor to fit 8 bits. If scale ($B8) exceeds 255, the hardware divide would receive a truncated divisor, producing incorrect results. The active version right-shifts all operands until the divisor fits.
; 
; 5. Underflow handling: Uses BCC/DEC $03 (borrow detection) instead of BCS/INC $03 (carry detection), matching the subtraction-based accumulation.
; 
; 6. DMA command: Uses COP QueueHdma instead of COP QueueDma.
; 
; 7. NOP count: Quadrants 3/4 use only 4 NOPs (vs 6 in Q1/Q2) — fewer hardware divide delay cycles, potentially reading results too early on some hardware revisions.
; 
; Likely superseded by mode7_perspective during development due to the missing divisor normalization and simpler per-scanline table format.
---------------------------------------------

?INCLUDE 'binary_01C384'

!WRDIVL                         4204
!WRDIVB                         4206
!RDDIVL                         4214
!tileStagingBuffer              7E7000

---------------------------------------------

; Unused Mode 7 perspective entry point — HDMA table init and per-frame matrix computation.
; 
; Phase 1 — Header initialization: sets up 3-entry indirect HDMA headers for all three tables. Each header has three $F0 (240 scanline) count bytes at offsets 0/3/6, with 16-bit WRAM data addresses pointing into the table data regions:
; - Table A ($7E7000): headers → $7100/$71E0 (M7A data)
; - Table B ($7E7800): headers → $7900/$79E0 (M7B data)
; - Table C ($7E8000): headers → $8100/$81E0 (M7C data)
; 
; Yields via SetEntryContinue after header setup.
; 
; Phase 2 — Per-frame computation: loads scale ($B8 → $02), rotation ($B6 → $04), perspective angle ($BC). Sine/cosine lookup from binary_01C595/01C695 with 4-quadrant dispatch. Starts from X=$01C0 and works downward. Pushes QueueMode7HdmaAlt−1 as RTS-trick return. Does NOT call NormalizeDivisor — divisor is used as-is.
; 
; Key difference from active version: subtracts rotation increment (SEC/SBC $04 → $01) instead of adding, and uses BCC/DEC for underflow handling.

Mode7PerspectiveAlt {
    PHX 
    SEP #$20              ; [UNUSED] Alternate Mode 7 perspective — switch to 8-bit for header writes
    LDX #$0000
    LDA #$F0              ; Scanline count $F0 (240) for all three HDMA table header entries
    STA $tileStagingBuffer, X ; Table A header: 3 entries × (count + addr) at $7E7000/7003/7006
    STA $7E7003, X
    STA $7E7006, X
    STA $7E7800, X        ; Table B header: 3 entries at $7E7800/7803/7806
    STA $7E7803, X
    STA $7E7806, X
    STA $7E8000, X        ; Table C header: 3 entries at $7E8000/8003/8006
    STA $7E8003, X
    STA $7E8006, X
    REP #$20
    LDA #$7100            ; Table A data address: $7100 (M7A data region in WRAM)
    STA $7E7001, X
    LDA #$71E0            ; Table A second data address: $71E0 (M7A high scanlines)
    STA $7E7004, X
    LDA #$7900            ; Table B data address: $7900 (M7B data region)
    STA $7E7801, X
    LDA #$79E0
    STA $7E7804, X
    LDA #$8100            ; Table C data address: $8100 (M7C data region)
    STA $7E8001, X
    LDA #$81E0
    STA $7E8004, X
    PLX 
    COP [SetEntryContinue] ; Yield after header init — re-enter here each subsequent frame
    PHX 
    PHD 
    LDA #$0000
    TCD 
    LDA $B8               ; Load scale ($B8) → $02 as hardware divide divisor (NOT normalized)
    STZ $00
    STA $02
    LDA $B6               ; Load rotation angle ($B6) → $04 as per-scanline decrement
    STA $04
    LDA #$00E0
    STA $0E
    LDA $BC               ; Perspective rotation index ($BC), masked to 9 bits
    AND #$01FF
    ASL 
    TAY 
    LDX #$01C0            ; Start from X=$01C0 — fill data regions from high to low (reverse of active version)
    PEA $&QueueMode7HdmaAlt-1 ; Push QueueMode7HdmaAlt−1 as RTS-trick return
    LDA $&binary_01C384.binary_01C695, Y ; Cosine lookup from binary_01C695 table
    BMI loc_03AC1F
    STA $18
    LDA $&binary_01C384.binary_01C595, Y ; Sine lookup from binary_01C595 table
    BMI loc_03AC16
    STA $1C
    JMP $&Mode7AltQ1_PosCosPosSin ; Quadrant 1: +cos, +sin

  loc_03AC16:
    EOR #$FFFF
    INC 
    STA $1C
    JMP $&Mode7AltQ2_PosCosNegSin ; Quadrant 2: +cos, −sin

  loc_03AC1F:
    EOR #$FFFF
    INC 
    STA $18
    LDA $&binary_01C384.binary_01C595, Y
    BMI loc_03AC2F
    STA $1C
    JMP $&Mode7AltQ3_NegCosPosSin ; Quadrant 3: −cos, +sin

  loc_03AC2F:
    EOR #$FFFF
    INC 
    STA $1C
    JMP $&Mode7AltQ4_NegCosNegSin ; Quadrant 4: −cos, −sin
}

---------------------------------------------
; RTS-trick return target — queues 4 HDMA transfers via COP QueueHdma.
; 
; Identical register targets to the active version ($1B–$1E for M7A–M7D), but uses QueueHdma instead of QueueDma. Table A ($7E7000) is reused for both M7A ($1B) and M7D ($1E).

QueueMode7HdmaAlt {
    PLD 
    PLX 
    COP [QueueHdma] ( $7E7000, #1B ) ; Table A → HDMA channel $1B (M7A) via QueueHdma (not QueueDma)
    COP [QueueHdma] ( $7E7800, #1C ) ; Table B → HDMA channel $1C (M7B)
    COP [QueueHdma] ( $7E8000, #1D ) ; Table C → HDMA channel $1D (M7C)
    COP [QueueHdma] ( $7E7000, #1E ) ; Table A reused → channel $1E (M7D = A for rotation matrix)
    RTL 
}

---------------------------------------------
; Unused quadrant 1 (+cos, +sin) — reverse-fill scanline loop.
; 
; Per-scanline: hardware divide |cos| ÷ scale → $7E7100,X (M7A), |sin| ÷ scale → $7E7900,X (M7B), negate → $7E8100,X (M7C). DEX×2 per iteration from $01C0 down to 0. Subtracts $04 from accumulator $01 each scanline. On borrow (BCC → DEC $03), continues without halving. Quadrants 2–4 follow the same pattern with appropriate sign inversions and swapped table destinations.

Mode7AltQ1_PosCosPosSin {
    LDY $02               ; Q1: Y = scale divisor (used as-is, no normalization)
    LDA $18
    STA $WRDIVL           ; |cos| → WRDIVL (16-bit dividend)
    STY $WRDIVB           ; Scale → WRDIVB (8-bit divisor, triggers hardware divide)
    NOP                   ; 6× NOP: wait for hardware divider
    NOP 
    NOP 
    NOP 
    NOP 
    NOP 
    DEX                   ; DEX×2: fill data region from high offset downward
    DEX 
    LDA $RDDIVL           ; cos/scale quotient → M7A data region at $7E7100,X
    STA $7E7100, X
    LDA $1C
    STA $WRDIVL           ; |sin| → WRDIVL for second divide
    STY $WRDIVB
    NOP 
    LDA $01               ; Subtract rotation increment: $01 − $04 (opposite of active version's add)
    SEC 
    SBC $04
    STA $01
    LDA $RDDIVL           ; sin/scale → M7B data at $7E7900,X
    STA $7E7900, X
    EOR #$FFFF            ; Negate for M7C: −(sin/scale)
    INC 
    STA $7E8100, X        ; Negated result → M7C data at $7E8100,X
    BCC loc_03AC93        ; BCC = no borrow → continue normally
    CPX #$0000            ; Check if X reached 0 (all scanlines computed)
    BPL Mode7AltQ1_PosCosPosSin
    RTS 

  loc_03AC93:
    DEC $03               ; Borrow: DEC high byte of accumulator (underflow handling)
    CPX #$0000
    BPL Mode7AltQ1_PosCosPosSin
    RTS 
}

Mode7AltQ2_PosCosNegSin {
    LDY $02               ; Q2 (+cos, −sin): same structure, swapped M7B/M7C writes
    LDA $18
    STA $WRDIVL
    STY $WRDIVB
    NOP 
    NOP 
    NOP 
    NOP 
    NOP 
    NOP 
    DEX 
    DEX 
    LDA $RDDIVL
    STA $7E7100, X
    LDA $1C
    STA $WRDIVL
    STY $WRDIVB
    NOP 
    LDA $01
    SEC 
    SBC $04
    STA $01
    LDA $RDDIVL
    STA $7E8100, X        ; sin/scale → M7C at $7E8100,X (swapped from Q1)
    EOR #$FFFF
    INC 
    STA $7E7900, X        ; Negated → M7B at $7E7900,X (swapped from Q1)
    BCC loc_03ACDB
    CPX #$0000
    BPL Mode7AltQ2_PosCosNegSin
    RTS 

  loc_03ACDB:
    DEC $03
    CPX #$0000
    BPL Mode7AltQ2_PosCosNegSin
    RTS 
}

Mode7AltQ3_NegCosPosSin {
    LDY $02               ; Q3 (−cos, +sin): negate cosine divide result
    LDA $18
    STA $WRDIVL
    STY $WRDIVB
    NOP 
    NOP 
    NOP 
    NOP 
    DEX 
    DEX 
    LDA #$0000            ; 0 − cos/scale for negative cosine
    SEC 
    SBC $RDDIVL
    STA $7E7100, X        ; Negated cos/scale → M7A at $7E7100,X
    LDA $1C
    STA $WRDIVL
    STY $WRDIVB
    NOP 
    LDA $01
    SEC 
    SBC $04
    STA $01
    LDA $RDDIVL
    STA $7E7900, X
    EOR #$FFFF
    INC 
    STA $7E8100, X
    BCC loc_03AD25
    CPX #$0000
    BPL Mode7AltQ3_NegCosPosSin
    RTS 

  loc_03AD25:
    DEC $03
    CPX #$0000
    BPL Mode7AltQ3_NegCosPosSin
    RTS 
}

Mode7AltQ4_NegCosNegSin {
    LDY $02               ; Q4 (−cos, −sin): negate both divide results
    LDA $18
    STA $WRDIVL
    STY $WRDIVB
    NOP 
    NOP 
    NOP 
    NOP 
    DEX 
    DEX 
    LDA #$0000
    SEC 
    SBC $RDDIVL
    STA $7E7100, X        ; Negated cos/scale → M7A
    LDA $1C
    STA $WRDIVL
    STY $WRDIVB
    NOP 
    LDA $01
    SEC 
    SBC $04
    STA $01
    LDA $RDDIVL
    STA $7E8100, X        ; sin/scale → M7C (swapped)
    EOR #$FFFF
    INC 
    STA $7E7900, X        ; Negated sin → M7B (swapped)
    BCC loc_03AD6F
    CPX #$0000
    BPL Mode7AltQ4_NegCosNegSin
    RTS 

  loc_03AD6F:
    DEC $03
    CPX #$0000
    BPL Mode7AltQ4_NegCosNegSin
    RTS 
}