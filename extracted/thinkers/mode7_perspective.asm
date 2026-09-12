; Mode 7 perspective rotation thinker — per-scanline matrix computation via hardware divide (239936–240520, Bank 03).
; 
; Thinker (type $04, priority $08) that generates per-scanline Mode 7 rotation/scaling matrices and queues them as HDMA tables for M7A/M7B/M7C/M7D registers ($211B–$211E). Creates the perspective-projected rotation effect used on the world map, prologue prophecy, Sky Garden crash, and Angkor Wat future vision scenes.
; 
; === INITIALIZATION (Mode7PerspectiveInit) ===
; 
; Sets M7SEL = $80 (repeat playfield outside screen area). Initializes $7F0B22/$7F0B24 to $FFFF. Loads initial position from $0D54/$0D56, centers camera (X−$80, Y−$70) with scroll override flags (bit 15 set). Initializes $B6 = 0 (rotation angle), $BC = 0 (perspective parameter), $B8 = $0400 (base scale).
; 
; === PER-FRAME UPDATE (Mode7PerspectiveUpdate) ===
; 
; Phase 1 — Table initialization: fills three 224-entry HDMA tables ($7E7000, $7E7800, $7E8000) with 1-scanline-per-entry defaults (3 bytes each: count=1, data=0). Yields via SetEntryContinue.
; 
; Phase 2 — Matrix computation (each tick after init):
; 1. Load scale ($B8 → $02), rotation angle ($B6 → $04), perspective rotation ($BC)
; 2. Index into sine table (binary_01C595) and cosine table (binary_01C695) using $BC × 2
; 3. Dispatch to one of 4 quadrant handlers based on sine/cosine signs:
;    - Mode7Quadrant_PosCosPosSin: +cos, +sin
;    - Mode7Quadrant_PosCosNegSin: +cos, −sin
;    - Mode7Quadrant_NegCosPosSin: −cos, +sin
;    - Mode7Quadrant_NegCosNegSin: −cos, −sin
; 4. NormalizeDivisor right-shifts all values until the scale divisor fits in 8 bits
; 5. Per-scanline loop: hardware 16÷8 divide (WRDIVL/WRDIVB → RDDIVL) computes cos/scale and sin/scale
; 6. Results written to three HDMA tables: M7A (cos/scale), M7B (±sin/scale), M7C (∓sin/scale)
; 7. Adaptive overflow: when accumulator carries, all values are halved to maintain ratio
; 
; Phase 3 — DMA queue (QueueMode7HdmaTables): queues 4 HDMA channels:
; - $7E7000 → #$1B (M7A)
; - $7E7800 → #$1C (M7B)
; - $7E8000 → #$1D (M7C)
; - $7E7000 → #$1E (M7D = same as A, since D = cos/scale for pure rotation)
; 
; === MODE 7 ROTATION MATRIX ===
; 
; The four HDMA tables encode the 2×2 rotation matrix per scanline:
; 
; | Register | Value | HDMA Table |
; |----------|-------|------------|
; | M7A ($211B) | cos θ / scale | $7E7000 |
; | M7B ($211C) | sin θ / scale | $7E7800 |
; | M7C ($211D) | −sin θ / scale | $7E8000 |
; | M7D ($211E) | cos θ / scale | $7E7000 (reused) |
; 
; Scale increases per scanline (via accumulating $04 into $01), creating the perspective foreshortening effect: scanlines near the top of the screen are more zoomed-out (distant) than those near the bottom (close).
---------------------------------------------

?BANK 03

?INCLUDE 'binary_01C384'

!scrollOverrideH                06C6
!scrollOverrideV                06CA
!M7SEL                          211A
!WRDIVL                         4204
!WRDIVB                         4206
!RDDIVL                         4214
!tileStagingBuffer              7E7000

---------------------------------------------

; Mode 7 perspective thinker initialization — sets up playfield, scroll overrides, and initial parameters.
; 
; Sets M7SEL = $80 (character 0 fill outside playfield). Writes $FFFF to $7F0B22 and $7F0B24 (Mode 7 configuration flags). Loads initial world position from $0D54/$0D56 → $00CA/$00CC, computes camera targets (X−$80, Y−$70) with bit 15 set in scrollOverrideH/V to activate hardware scroll override. Initializes actor fields: $B6 = 0 (rotation angle), $BC = 0 (perspective rotation index), $B8 = $0400 (base scale factor).

Mode7PerspectiveInit [
  thinker-def < #04, #08, {

  code_03A942:
    SEP #$20              ; Switch to 8-bit for M7SEL register write
    LDA #$80              ; M7SEL = $80: repeat character 0 outside Mode 7 playfield area
    STA $M7SEL
    REP #$20
    LDA #$FFFF            ; Initialize Mode 7 config flags at $7F0B22/$7F0B24 to $FFFF
    STA $7F0B22
    LDA #$FFFF
    STA $7F0B24
    LDA $0D54             ; Load initial X position from $0D54 → world X ($00CA)
    STA $00CA
    SEC 
    SBC #$0080            ; Camera X = world X − $80 (center 256px screen)
    ORA #$8000            ; Bit 15 = scroll override active (engine uses hardware scroll)
    STA $scrollOverrideH
    LDA $0D56             ; Load initial Y position from $0D56 → world Y ($00CC)
    STA $00CC
    SEC 
    SBC #$0070            ; Camera Y = world Y − $70 (center 224px screen)
    ORA #$8000
    STA $scrollOverrideV
    STZ $00B6             ; Zero rotation angle ($B6) — no initial rotation
    STZ $00BC             ; Zero perspective rotation index ($BC)
    LDA #$0400            ; Initial scale = $0400 (base perspective distance)
    STA $00B8
} >
]

---------------------------------------------
; Per-frame Mode 7 HDMA table generator — computes rotation matrix for 224 scanlines.
; 
; First tick (after SetEntryContinue yield): initializes three HDMA tables at $7E7000, $7E7800, $7E8000 with 224 entries × 3 bytes each (scanline count = 1, two zero data bytes), terminated by $00. This sets a neutral default before the first perspective computation.
; 
; Subsequent ticks: loads scale ($B8), rotation ($B6), and perspective angle ($BC). Looks up sine (binary_01C595) and cosine (binary_01C695) from 512-entry tables using ($BC AND $01FF) × 2 as index. Pushes QueueMode7HdmaTables−1 as RTS-trick return address.
; 
; Dispatches to one of 4 quadrant handlers based on the signs of cos and sin:
; - Both positive → Mode7Quadrant_PosCosPosSin
; - cos positive, sin negative → Mode7Quadrant_PosCosNegSin (negate sin via EOR $FFFF + INC)
; - cos negative, sin positive → Mode7Quadrant_NegCosPosSin
; - Both negative → Mode7Quadrant_NegCosNegSin
; 
; Each quadrant handler calls NormalizeDivisor, then runs a 224-iteration loop using SNES hardware divide to compute per-scanline matrix entries.

Mode7PerspectiveUpdate {
    PHX                   ; Save actor index and direct page for restoration after computation
    PHD 
    LDA #$0000            ; Set DP = $0000 for absolute zero-page addressing of scratch variables
    TCD 
    SEP #$20
    LDX #$0000
    LDA #$E0              ; 224 scanlines = visible screen height
    STA $0E

  loc_03A994:
    LDA #$01              ; Initialize HDMA entries: 1 scanline per entry, zero data bytes
    STA $tileStagingBuffer, X ; Table A ($7E7000) — will hold M7A per-scanline values
    STA $7E7800, X        ; Table B ($7E7800) — will hold M7B per-scanline values
    STA $7E8000, X        ; Table C ($7E8000) — will hold M7C per-scanline values
    INX                   ; 3 bytes per HDMA entry (1 count + 2 data)
    INX 
    INX 
    DEC $0E
    BNE loc_03A994
    LDA #$00              ; $00 terminator at end of each 224-entry HDMA table
    STA $tileStagingBuffer, X
    STA $7E7800, X
    STA $7E8000, X
    REP #$20
    PLD 
    PLX 
    COP [SetEntryContinue] ; Yield after init — re-enter here each subsequent frame
    PHX 
    PHD 
    LDA #$0000
    TCD 
    LDA $B8               ; Load scale factor ($B8) → $02 as hardware divide divisor
    STZ $00
    STA $02
    LDA $B6               ; Load rotation angle ($B6) → $04 as per-scanline increment
    STA $04
    LDA #$00E0            ; 224 scanlines to compute
    STA $0E
    LDA $BC               ; Perspective rotation index ($BC), masked to 9 bits (0–511)
    AND #$01FF
    ASL                   ; ×2 for word-sized sine/cosine table index
    TAY 
    LDX #$0000
    PEA $&QueueMode7HdmaTables-1 ; Push QueueMode7HdmaTables−1 as RTS-trick return address
    LDA $&binary_01C384.binary_01C695, Y ; Look up cosine value from binary_01C695 table
    BMI loc_03A9F9        ; Negative cosine → quadrant 3 or 4
    STA $18               ; $18 = |cos| (positive cosine)
    LDA $&binary_01C384.binary_01C595, Y ; Look up sine value from binary_01C595 table
    BMI loc_03A9F0        ; Negative sine → quadrant 2 (+cos, −sin)
    STA $1C               ; $1C = |sin| (positive sine)
    JMP $&Mode7Quadrant_PosCosPosSin ; Quadrant 1: +cos, +sin → Mode7Quadrant_PosCosPosSin

  loc_03A9F0:
    EOR #$FFFF            ; Negate sine: EOR $FFFF + INC = two's complement
    INC 
    STA $1C
    JMP $&Mode7Quadrant_PosCosNegSin ; Quadrant 2: +cos, −sin → Mode7Quadrant_PosCosNegSin

  loc_03A9F9:
    EOR #$FFFF            ; Negate cosine for quadrants 3/4
    INC 
    STA $18
    LDA $&binary_01C384.binary_01C595, Y ; Re-read sine for negative cosine quadrants
    BMI loc_03AA09
    STA $1C
    JMP $&Mode7Quadrant_NegCosPosSin ; Quadrant 3: −cos, +sin → Mode7Quadrant_NegCosPosSin

  loc_03AA09:
    EOR #$FFFF            ; Negate sine for quadrant 4
    INC 
    STA $1C
    JMP $&Mode7Quadrant_NegCosNegSin ; Quadrant 4: −cos, −sin → Mode7Quadrant_NegCosNegSin
}

---------------------------------------------
; RTS-trick return target — queues 4 HDMA transfers for Mode 7 matrix registers.
; 
; Restores DP and actor index (PLD/PLX), then queues:
; - $7E7000 → channel $1B (M7A: cos θ / scale)
; - $7E7800 → channel $1C (M7B: sin θ / scale)
; - $7E8000 → channel $1D (M7C: −sin θ / scale)
; - $7E7000 → channel $1E (M7D: reuses A table, since D = A for rotation)
; 
; Returns via RTL to the thinker tick loop.

QueueMode7HdmaTables {
    PLD 
    PLX 
    COP [QueueDma] ( $7E7000, #1B ) ; Table A → HDMA channel $1B (M7A register $211B: cos/scale)
    COP [QueueDma] ( $7E7800, #1C ) ; Table B → HDMA channel $1C (M7B register $211C: sin/scale)
    COP [QueueDma] ( $7E8000, #1D ) ; Table C → HDMA channel $1D (M7C register $211D: −sin/scale)
    COP [QueueDma] ( $7E7000, #1E ) ; Table A reused → HDMA channel $1E (M7D register $211E: D=A for rotation)
    RTL 
}

---------------------------------------------
; Quadrant 1 scanline loop: +cos, +sin.
; 
; Calls NormalizeDivisor to right-shift scale/cos/sin until the divisor fits in 8 bits. Then for each of 224 scanlines:
; 1. Load scale → Y (divisor). Divide |cos| by scale via WRDIVL/WRDIVB → result to $7E7000 table (M7A)
; 2. Divide |sin| by scale → result to $7E7800 table (M7B). Negate result → $7E8000 table (M7C = −sin)
; 3. Accumulate rotation increment ($04 + $01 → $01) per scanline for perspective foreshortening
; 4. On carry overflow: halve all values (cos, sin, divisor, angle) and continue
; 
; The other three quadrant handlers (PosCosNegSin, NegCosPosSin, NegCosNegSin) are structurally identical but swap which results are negated and which tables receive positive vs. negative values to handle all four sign combinations.

Mode7Quadrant_PosCosPosSin {
    JSR $&NormalizeDivisor ; Normalize divisor before entering scanline loop

  loc_03AA30:
    LDY $02               ; Y = divisor (scale, fits in 8 bits after normalization)
    LDA $18               ; |cos| → WRDIVL (16-bit dividend for hardware divide)
    STA $WRDIVL
    STY $WRDIVB           ; Scale → WRDIVB (8-bit divisor, triggers 16÷8 division)
    NOP                   ; 6× NOP: wait ~16 cycles for hardware divider to complete
    NOP 
    NOP 
    NOP 
    NOP 
    NOP 
    INX 
    INX 
    LDA $RDDIVL           ; Read quotient cos/scale → M7A table at $7E7000
    STA $7E6FFF, X
    LDA $1C               ; |sin| → WRDIVL for second divide
    STA $WRDIVL
    STY $WRDIVB
    INX 
    LDA $04               ; Accumulate rotation increment: $04 + $01 → $01 (perspective foreshortening)
    CLC 
    ADC $01
    STA $01
    LDA $RDDIVL           ; Read quotient sin/scale → M7B table at $7E7800
    STA $7E77FE, X
    EOR #$FFFF            ; Negate: EOR $FFFF + INC = −(sin/scale)
    INC 
    STA $7E7FFE, X        ; Negated result → M7C table at $7E8000 (−sin for rotation matrix)
    BCS loc_03AA6F        ; Carry = accumulator overflow → halve all values and continue
    DEC $0E
    BNE loc_03AA30
    RTS 

  loc_03AA6F:
    INC $03               ; Overflow: increment high byte of accumulator
    LSR $18               ; Halve cos, sin, divisor, angle to prevent further overflow
    LSR $1C
    LSR $02
    LSR $04
    DEC $0E
    BNE loc_03AA30
    RTS 
}

Mode7Quadrant_PosCosNegSin {
    JSR $&NormalizeDivisor ; Quadrant 2 (+cos, −sin): normalize and enter loop

  loc_03AA81:
    LDY $02
    LDA $18
    STA $WRDIVL
    STY $WRDIVB
    NOP 
    NOP 
    NOP 
    NOP 
    NOP 
    NOP 
    INX 
    INX 
    LDA $RDDIVL           ; cos/scale → M7A table (same as Q1)
    STA $7E6FFF, X
    LDA $1C
    STA $WRDIVL
    STY $WRDIVB
    INX 
    LDA $04
    CLC 
    ADC $01
    STA $01
    LDA $RDDIVL           ; sin/scale → M7C table (swapped vs Q1: −sin goes to B)
    STA $7E7FFE, X        ; Write sin/scale to $7E8000 (M7C) — positive in Q2
    EOR #$FFFF
    INC 
    STA $7E77FE, X        ; Negated → $7E7800 (M7B) — negative sin in Q2
    BCS loc_03AAC0
    DEC $0E
    BNE loc_03AA81
    RTS 

  loc_03AAC0:
    INC $03
    LSR $18
    LSR $1C
    LSR $02
    LSR $04
    DEC $0E
    BNE loc_03AA81
    RTS 
}

Mode7Quadrant_NegCosPosSin {
    JSR $&NormalizeDivisor ; Quadrant 3 (−cos, +sin): normalize and enter loop

  loc_03AAD2:
    LDY $02
    LDA $18
    STA $WRDIVL
    STY $WRDIVB
    NOP 
    NOP 
    NOP 
    NOP 
    INX 
    INX 
    LDA #$0000            ; Negate divide result: 0 − cos/scale for negative cosine
    SEC 
    SBC $RDDIVL
    STA $7E6FFF, X        ; Negated cos/scale → M7A table
    LDA $1C
    STA $WRDIVL
    STY $WRDIVB
    INX 
    LDA $04
    CLC 
    ADC $01
    STA $01
    LDA $RDDIVL
    STA $7E77FE, X        ; sin/scale → M7B table (positive in Q3)
    EOR #$FFFF
    INC 
    STA $7E7FFE, X        ; Negated sin/scale → M7C table
    BCS loc_03AB13
    DEC $0E
    BNE loc_03AAD2
    RTS 

  loc_03AB13:
    INC $03
    LSR $18
    LSR $1C
    LSR $02
    LSR $04
    DEC $0E
    BNE loc_03AAD2
    RTS 
}

Mode7Quadrant_NegCosNegSin {
    JSR $&NormalizeDivisor ; Quadrant 4 (−cos, −sin): normalize and enter loop

  loc_03AB25:
    LDY $02
    LDA $18
    STA $WRDIVL
    STY $WRDIVB
    NOP 
    NOP 
    NOP 
    NOP 
    INX 
    INX 
    LDA #$0000            ; Negate divide result for negative cosine
    SEC 
    SBC $RDDIVL
    STA $7E6FFF, X
    LDA $1C
    STA $WRDIVL
    STY $WRDIVB
    INX 
    LDA $04
    CLC 
    ADC $01
    STA $01
    LDA $RDDIVL
    STA $7E7FFE, X        ; sin result → M7C table (swapped signs for Q4)
    EOR #$FFFF
    INC 
    STA $7E77FE, X        ; Negated → M7B table
    BCS loc_03AB66
    DEC $0E
    BNE loc_03AB25
    RTS 

  loc_03AB66:
    INC $03
    LSR $18
    LSR $1C
    LSR $02
    LSR $04
    DEC $0E
    BNE loc_03AB25
    RTS 
}

---------------------------------------------
; Right-shift divisor and all related values until the divisor fits in 8 bits.
; 
; Checks $02 (scale/divisor) high byte via BIT #$FF00. If nonzero: LSR $02, LSR $18 (cos), LSR $1C (sin), LSR $04 (rotation increment), and loop. Ensures the 8-bit WRDIVB divisor register receives a valid value while maintaining proportional ratios across all operands.

NormalizeDivisor {
    LDA $02               ; Check if divisor high byte is nonzero (won't fit in WRDIVB)
    BIT #$FF00
    BNE loc_03AB7D        ; High byte set → need to right-shift everything
    RTS 

  loc_03AB7D:
    LSR                   ; Halve divisor, cos ($18), sin ($1C), angle ($04) together
    STA $02
    LSR $18
    LSR $1C
    LSR $04
    BRA NormalizeDivisor
}