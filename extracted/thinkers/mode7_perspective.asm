; Mode 7 perspective thinker (Bank 03, 239936-240520). Every frame it rebuilds three 224-line HDMA tables that drive the Mode 7 matrix registers M7A-M7D, so the flat Mode 7 plane is rotated by an angle index and gets a perspective gradient (the zoom grows from the top scanline to the bottom one).
; 
; === ENTRY POINTS ===
; 
; - Mode7PerspectiveInit is a thinker-def <#04,#08>: the two header bytes are the word $0804 that goes into animScratch2. Bit 2 puts the thinker into RunThinkers_TypeB, which runs after ResetHdmaState every frame; the four HDMA channels queued below are therefore re-armed each frame. Bit 11 is the lighter-frame flag. Only the scene thinker list of scene $FE (the world map, thinker_spawn_0CEB3D = Init + IrisCircleEffect) spawns it through the list.
; - Init has no RTL: it falls straight into Mode7PerspectiveUpdate (the Update block starts at the byte after Init's last STA).
; - Four actor scripts spawn Mode7PerspectiveUpdate directly with COP SpawnThinker and skip Init: pr8C_prologue1 and pr8C_prologue5 (prologue prophecy), garden_crash_cutscene (Sky Garden crash) and future_vision_cutscene (Angkor Wat). SpawnThinker does not read the thinker-def header, so each of them stores $0804 into the new thinker's animScratch2 itself, writes M7SEL = 0 (map repeats) and drives the three parameters below from a companion script.
; 
; === PARAMETERS (global low-RAM words, not actor fields) ===
; 
; The thinker reads absolute low-RAM words (D is forced to 0), so every script writes them with STA $00B8 style absolute stores. They are not per-thinker fields.
; 
; | Word | Role here | Written by |
; |------|-----------|------------|
; | $00B8 | Starting divisor ('scale'). The quotient is abs(cos) / divisor in 8.8 fixed point, so $80 is about 1:1 ($7FFF / $80 = $FF), a smaller divisor zooms out and a larger one zooms in. Init sets $0400 | Cutscene controllers (future vision $001C up to $0080, prologue $0020), WorldMapController (adds gravity deltas) |
; | $00B6 | Divisor increment per scanline, 8.8 fixed point. 0 gives a flat plane without perspective. Init sets 0 | Prologue controllers ($0280 / $0200 counted down towards 0), future vision (INC), WorldMapController (descent loop subtracts $10 per frame) |
; | $00BC | Rotation index. ($BC AND $01FF) x 2 indexes the 512-step sine and cosine tables (0.703 degrees per step). Init sets 0 | Cutscenes INC it; WorldMapController route steps add their third delta axis to it (its own comments call that axis elevation) |
; | $00CA / $00CC | Mode 7 centre X / Y (copied to M7X / M7Y by the NMI). Init takes them from worldMapPlayerX / Y ($0D54 / $0D56) | Init, the cutscene controllers, WorldMapController |
; 
; === ONE-TIME TABLE FILL ===
; 
; The first tick writes 224 entries of {count 1, data word 0} plus a $00 terminator into $7E7000 (M7A), $7E7800 (M7B) and $7E8000 (M7C): 673 bytes each. A count of 1 with bit 7 clear is a one-scanline, non-repeat entry. COP SetEntryHere follows, so only the data words are rewritten on later frames.
; 
; === PER-FRAME COMPUTATION ===
; 
; 1. D := 0. Scratch is absolute $00-$04, $0E, $18 and $1C. $00/$01 := 0 (this clears the fraction byte $01), $02 := $B8 (the divisor word $02/$03), $04 := $B6, $0E := 224.
; 2. Y = ($BC AND $1FF) x 2. cos is read from cosine_table_16bit[Y] and sin from sine_table_16bit[Y] ($7FFF = 1.0). Both tables are read past their nominal length on purpose (math_lookup_tables adjacency contract). The absolute values go to $18 (|cos|) and $1C (|sin|); the two signs choose one of four routines.
; 3. PEA QueueMode7HdmaTables-1 makes the routine's final RTS continue in the queue code (return-address trick).
; 4. NormalizeDivisor shifts $02, $18, $1C and $04 right together until the divisor word has no high byte. The quotients do not change; the 8-bit WRDIVB divisor input is satisfied.
; 5. For each of the 224 scanlines: divide |cos| by the divisor with the hardware 16/8 divider, divide |sin|, store the signed results into the three tables, then add $04 to the 16-bit word at $01/$02. $01 is the fraction byte and $02 the low byte of the divisor word, so this adds $B6 / 256 to the divisor: the divisor, and with it the zoom, grows down the screen.
; 6. If that add carries out of $02, the carry is added to $03 and |cos|, |sin|, the divisor word and $04 are all halved. Their ratios are kept and the divisor returns to 8 bits. The fraction byte $01 is not halved.
; 
; | Case | M7A (table $7E7000) | M7B ($7E7800) | M7C ($7E8000) |
; |------|---------------------|---------------|---------------|
; | +cos, +sin | +cos/div | +sin/div | -sin/div |
; | +cos, -sin | +cos/div | -abs(sin)/div | +abs(sin)/div |
; | -cos, +sin | -abs(cos)/div | +sin/div | -sin/div |
; | -cos, -sin | -abs(cos)/div | -abs(sin)/div | +abs(sin)/div |
; 
; In every case A = D = cos/div, B = sin/div and C = -sin/div: the rotation matrix divided by the per-scanline divisor.
; 
; === HDMA QUEUE ===
; 
; QueueMode7HdmaTables issues four COP QueueHdmaDirect. The second operand is a B-bus register index (#1B..#1E = $211B..$211E), not a channel number. QueueHdmaDirect sets up a DIRECT-table HDMA channel on the next free channel (cop_handlers_hdma_dma), so four channels are used per frame and released again by the next ResetHdmaState. Table A is queued twice, for M7A and for M7D.
; 
; === QUIRKS ===
; 
; - M7SEL = $80 written by Init means: tilemap repeat off and non-tilemap fill = 0, i.e. the area outside the 1024x1024 map is transparent (nesdev PPU registers). The old notes said 'repeat'. The cutscene spawners write M7SEL = 0 instead, which repeats the map.
; - $B6 is the per-scanline divisor increment, not a rotation angle; the rotation is $BC.
; - STY $WRDIVB with 16-bit Y also writes $4207 (HTIMEL) with the divisor high byte, which is 0 here. No H-IRQ use was checked.
; - Quadrants 3 and 4 use 4 NOPs where 1 and 2 use 6: the extra LDA #0 / SEC before the SBC fill the divider's 16-cycle delay (derived from cycle counts, not run).
; - The three tables live at $7E7000, $7E7800 and $7E8000, the same addresses as tileStagingBuffer and as buffers of parallax_thinker. No check was made for scenes that use both (OQ-I041-3).
; - Init writes $FFFF to the words $7F0B22 and $7F0B24. No reader was found in extracted/ (OQ-I041-1).
---------------------------------------------

?BANK 03

?INCLUDE 'math_lookup_tables'

!scrollOverrideH                06C6
!scrollOverrideV                06CA
!worldMapPlayerX                0D54
!worldMapPlayerY                0D56
!M7SEL                          211A
!WRDIVL                         4204
!WRDIVB                         4206
!RDDIVL                         4214
!tileStagingBuffer              7E7000

---------------------------------------------

; Thinker entry for scene $FE only. M7SEL := $80; $7F0B22 and $7F0B24 := $FFFF; Mode 7 centre := world-map start position; camera := centre - ($80, $70) with the bit 15 scroll-override flag; $B6 := 0, $BC := 0, $B8 := $0400. Falls through into Mode7PerspectiveUpdate.

Mode7PerspectiveInit [
  thinker-def < #04, #08, {

; Thinker code entry (after the 2-byte header $0804).

  Mode7InitEntry:
    SEP #$20
    LDA #$80              ; M7SEL $80: outside the 1024x1024 map is transparent (no repeat, no tile-0 fill), no flip
    STA $M7SEL
    REP #$20
    LDA #$FFFF            ; $7F0B22 and $7F0B24 := $FFFF (no reader found in extracted/, OQ-I041-1)
    STA $7F0B22
    LDA #$FFFF
    STA $7F0B24
    LDA $worldMapPlayerX  ; Mode 7 centre := world-map start position (the NMI copies $00CA / $00CC to M7X / M7Y)
    STA $00CA
    SEC 
    SBC #$0080            ; Camera X = centre X - $80 (half of the 256-pixel screen); bit 15 = scroll override, so the scroll writer uses this word
    ORA #$8000
    STA $scrollOverrideH
    LDA $worldMapPlayerY
    STA $00CC
    SEC 
    SBC #$0070            ; Camera Y = centre Y - $70 (half of the 224-line screen), same override bit
    ORA #$8000
    STA $scrollOverrideV
    STZ $00B6             ; $B6 := 0 (flat plane), $BC := 0 (rotation), $B8 := $0400 (divisor); falls into Mode7PerspectiveUpdate (no RTL)
    STZ $00BC
    LDA #$0400
    STA $00B8
} >
]

---------------------------------------------
; Table fill (first tick only) followed by the per-frame matrix computation. Entered by fall-through from Init (scene $FE) or directly as the SpawnThinker target of the prologue, Sky Garden crash and Angkor Wat vision scripts. COP SetEntryHere separates the one-time fill from the per-frame part.
; Per frame: scratch $02 := $B8 (divisor), $04 := $B6 (increment), index Y := ($BC AND $1FF) x 2, then cos and sin from the 16-bit tables, absolute values in $18 and $1C, jump to the matching quadrant routine with QueueMode7HdmaTables-1 on the stack.

Mode7PerspectiveUpdate {
    PHX 
    PHD 
    LDA #$0000            ; D := 0: the scratch below is absolute low RAM ($00-$1C), not actor fields
    TCD 
    SEP #$20
    LDX #$0000
    LDA #$E0              ; 224 entries, one per scanline
    STA $0E

; Fill loop: one entry per scanline in all three tables (count byte 1, data bytes left 0), 224 times, then $00 terminators.

  Mode7FillTableLoop:
    LDA #$01              ; Per entry: count byte 1 (one scanline, no repeat) in all three tables; the data word stays 0 until the first computation
    STA $tileStagingBuffer, X
    STA $7E7800, X
    STA $7E8000, X
    INX 
    INX 
    INX 
    DEC $0E
    BNE Mode7FillTableLoop
    LDA #$00              ; A $00 count byte ends each HDMA table
    STA $tileStagingBuffer, X
    STA $7E7800, X
    STA $7E8000, X
    REP #$20
    PLD 
    PLX 
    COP [SetEntryHere]    ; Yield; the fill above runs only once, later frames resume below
    PHX 
    PHD 
    LDA #$0000
    TCD 
    LDA $B8               ; Per frame: $02 := $B8 (divisor), $04 := $B6 (increment), $00/$01 := 0 (accumulator fraction)
    STZ $00
    STA $02
    LDA $B6
    STA $04
    LDA #$00E0
    STA $0E
    LDA $BC               ; Y := ($BC AND $1FF) x 2: word index into the 512-step sine and cosine tables
    AND #$01FF
    ASL 
    TAY 
    LDX #$0000
    PEA $&QueueMode7HdmaTables-1 ; Return-address trick: the quadrant routine's final RTS continues in QueueMode7HdmaTables
    LDA $&math_lookup_tables.cosine_table_16bit, Y ; cos (the index may run past the table end by design); its sign and sin's sign choose one of four quadrant routines
    BMI Mode7CosNegative
    STA $18
    LDA $&math_lookup_tables.sine_table_16bit, Y
    BMI Mode7SinNegative
    STA $1C
    JMP $&Mode7Quadrant_PosCosPosSin ; Quadrant 1: +cos, +sin

; cos >= 0 and sin < 0: negate sin and enter the second quadrant routine.

  Mode7SinNegative:
    EOR #$FFFF
    INC 
    STA $1C
    JMP $&Mode7Quadrant_PosCosNegSin ; Quadrant 2: +cos, -sin

; cos < 0: negate cos, re-read sin and choose the third or fourth quadrant routine.

  Mode7CosNegative:
    EOR #$FFFF
    INC 
    STA $18
    LDA $&math_lookup_tables.sine_table_16bit, Y ; Re-read sin (A held cos)
    BMI Mode7CosNegSinNegative
    STA $1C
    JMP $&Mode7Quadrant_NegCosPosSin ; Quadrant 3: -cos, +sin

; cos < 0 and sin < 0: negate sin and enter the fourth quadrant routine.

  Mode7CosNegSinNegative:
    EOR #$FFFF
    INC 
    STA $1C
    JMP $&Mode7Quadrant_NegCosNegSin ; Quadrant 4: -cos, -sin
}

---------------------------------------------
; RTS-trick return target. Restores D and the thinker slot, then queues four direct-table HDMA transfers: table A to M7A ($211B), B to M7B ($211C), C to M7C ($211D) and A again to M7D ($211E). Ends with RTL back to the thinker loop.

QueueMode7HdmaTables {
    PLD 
    PLX 
    COP [QueueHdmaDirect] ( $tileStagingBuffer, #1B ) ; Direct HDMA table A ($7E7000) to B-bus register $1B = M7A
    COP [QueueHdmaDirect] ( $7E7800, #1C ) ; Table B ($7E7800) to register $1C = M7B
    COP [QueueHdmaDirect] ( $7E8000, #1D ) ; Table C ($7E8000) to register $1D = M7C
    COP [QueueHdmaDirect] ( $tileStagingBuffer, #1E ) ; Table A again to register $1E = M7D (D = A)
    RTL 
}

---------------------------------------------
; Quadrant 1 (+cos, +sin). NormalizeDivisor, then 224 scanlines: A := cos/div, B := sin/div, C := -(sin/div), divisor += $B6/256. Carry out of the accumulator halves everything (Mode7Q1Overflow).

Mode7Quadrant_PosCosPosSin {
    JSR $&NormalizeDivisor

; Scanline loop of quadrant 1: two divides, three table writes, divisor accumulation.

  Mode7Q1Scanline:
    LDY $02               ; Y := divisor (8 bits after NormalizeDivisor)
    LDA $18               ; Divide |cos| by the divisor with the hardware divider (WRDIVL / WRDIVB; the 16-bit STY also writes $4207 = 0)
    STA $WRDIVL
    STY $WRDIVB
    NOP                   ; 6 NOPs wait out the 16-cycle divide
    NOP 
    NOP 
    NOP 
    NOP 
    NOP 
    INX                   ; X += 3 per entry (2 here, 1 below): the data word sits at entry + 1
    INX 
    LDA $RDDIVL
    STA $7E6FFF, X        ; M7A := +cos/divisor (8.8 fixed point)
    LDA $1C               ; Second divide: |sin| by the same divisor
    STA $WRDIVL
    STY $WRDIVB
    INX 
    LDA $04               ; Divisor word $01/$02 += $04: the divisor grows by $B6/256 per scanline; carry out of $02 is tested at the BCS
    CLC 
    ADC $01
    STA $01
    LDA $RDDIVL
    STA $7E77FE, X        ; M7B := +sin/divisor
    EOR #$FFFF
    INC 
    STA $7E7FFE, X        ; M7C := -sin/divisor
    BCS Mode7Q1Overflow   ; Carry: the divisor overflowed into $03
    DEC $0E
    BNE Mode7Q1Scanline
    RTS                   ; All 224 done: RTS continues in QueueMode7HdmaTables

; Quadrant 1 overflow: add the carry to the divisor high byte, halve |cos|, |sin|, the divisor word and the increment, and continue the loop.

  Mode7Q1Overflow:
    INC $03               ; Overflow: add the carry to $03, then halve |cos|, |sin|, the divisor word and the increment together (ratios kept, divisor back to 8 bits)
    LSR $18
    LSR $1C
    LSR $02
    LSR $04
    DEC $0E
    BNE Mode7Q1Scanline
    RTS 
}

---------------------------------------------
; Quadrant 2 (+cos, -sin). Same as quadrant 1 but the sin quotient goes to table C unchanged and its negation to table B, so B = sin/div (negative) and C = -sin/div (positive).

Mode7Quadrant_PosCosNegSin {
    JSR $&NormalizeDivisor

; Scanline loop of quadrant 2.

  Mode7Q2Scanline:
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
    LDA $RDDIVL
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
    STA $7E7FFE, X        ; M7C := +|sin|/divisor (= -sin/divisor, sin < 0)
    EOR #$FFFF
    INC 
    STA $7E77FE, X        ; M7B := -|sin|/divisor (= sin/divisor)
    BCS Mode7Q2Overflow
    DEC $0E
    BNE Mode7Q2Scanline
    RTS 

; Quadrant 2 overflow (halve and continue).

  Mode7Q2Overflow:
    INC $03
    LSR $18
    LSR $1C
    LSR $02
    LSR $04
    DEC $0E
    BNE Mode7Q2Scanline
    RTS 
}

---------------------------------------------
; Quadrant 3 (-cos, +sin). A := 0 - cos/div, B := sin/div, C := -(sin/div). Uses 4 NOPs because the LDA #0 / SEC / SBC read delays the RDDIVL access.

Mode7Quadrant_NegCosPosSin {
    JSR $&NormalizeDivisor

; Scanline loop of quadrant 3.

  Mode7Q3Scanline:
    LDY $02
    LDA $18
    STA $WRDIVL
    STY $WRDIVB
    NOP                   ; 4 NOPs, not 6: the LDA #0 / SEC below fill the rest of the 16-cycle wait (from cycle counts, not run)
    NOP 
    NOP 
    NOP 
    INX 
    INX 
    LDA #$0000            ; M7A := 0 - |cos|/divisor
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
    STA $7E77FE, X        ; M7B := +sin/divisor
    EOR #$FFFF
    INC 
    STA $7E7FFE, X        ; M7C := -sin/divisor
    BCS Mode7Q3Overflow
    DEC $0E
    BNE Mode7Q3Scanline
    RTS 

; Quadrant 3 overflow (halve and continue).

  Mode7Q3Overflow:
    INC $03
    LSR $18
    LSR $1C
    LSR $02
    LSR $04
    DEC $0E
    BNE Mode7Q3Scanline
    RTS 
}

---------------------------------------------
; Quadrant 4 (-cos, -sin). A := 0 - cos/div, C := +|sin|/div, B := -|sin|/div.

Mode7Quadrant_NegCosNegSin {
    JSR $&NormalizeDivisor

; Scanline loop of quadrant 4.

  Mode7Q4Scanline:
    LDY $02
    LDA $18
    STA $WRDIVL
    STY $WRDIVB
    NOP                   ; 4 NOPs as in quadrant 3
    NOP 
    NOP 
    NOP 
    INX 
    INX 
    LDA #$0000            ; M7A := 0 - |cos|/divisor
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
    STA $7E7FFE, X        ; M7C := +|sin|/divisor (= -sin/divisor, sin < 0)
    EOR #$FFFF
    INC 
    STA $7E77FE, X        ; M7B := -|sin|/divisor (= sin/divisor)
    BCS Mode7Q4Overflow
    DEC $0E
    BNE Mode7Q4Scanline
    RTS 

; Quadrant 4 overflow (halve and continue).

  Mode7Q4Overflow:
    INC $03
    LSR $18
    LSR $1C
    LSR $02
    LSR $04
    DEC $0E
    BNE Mode7Q4Scanline
    RTS 
}

---------------------------------------------
; Shift the divisor word, |cos|, |sin| and the increment right together until the divisor high byte is zero, so the divisor fits the 8-bit WRDIVB register. The ratios, and therefore the quotients, are unchanged.

NormalizeDivisor {
    LDA $02
    BIT #$FF00            ; High byte set: the divisor does not fit the 8-bit WRDIVB
    BNE NormalizeDivisorShift
    RTS 

; Shift step of NormalizeDivisor: A = divisor >> 1, then $18, $1C and $04 shifted too, and test again.

  NormalizeDivisorShift:
    LSR 
    STA $02
    LSR $18               ; Shift |cos|, |sin| and the increment too, so the ratios stay the same
    LSR $1C
    LSR $04
    BRA NormalizeDivisor
}