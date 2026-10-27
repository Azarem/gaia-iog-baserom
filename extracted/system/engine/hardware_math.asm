; Hardware math utilities — SNES multiplication and division using the 5A22 math registers (163840–164464, Bank 02).
; 
; Wrappers around the hardware multiplier ($4202/$4203 → $4216/$4217, unsigned 8×8) and divider ($4204/$4205/$4206 → $4214/$4216, unsigned 16÷8). Results need NOP delays (8 machine cycles after a multiply, 16 after a divide).
; 
; === ROUTINES ===
; 
; MulDivide: (A low × Y) ÷ A high. A low = multiplier, A high = divisor, Y = 16-bit multiplicand. Two 8×8 multiplies (A low × Y low, A low × Y high) are combined into the 16-bit dividend: the product's low 16 bits only — anything above bit 15 is discarded, so the product must fit in 16 bits. A divisor of 0 gives $FFFF. Returns the 16-bit quotient. Users: camera_scroll, parallax_thinker, visual_effect_pipeline.
; 
; Multiply8x8Unsigned: 8×8 multiply with the operands in the two bytes of A (low = first, high = second), through long addresses ($80:4202/4203/4216/4217) so any data bank works. Returns the 16-bit product in A. The hardware multiplier is unsigned, so despite the name this is an unsigned multiply (see rename proposal 84). Used for index × $30 actor addressing, map index calculation, orbital offsets and others.
; 
; UnsignedDivide: 16÷8 divide. Y = 16-bit dividend, A = 8-bit divisor. Returns the quotient's low byte in A low and the remainder in A high (the quotient's high byte is dropped).
; 
; SoftDivide_Unused: software long division, no callers.
; 
; RngStep_Unused: standalone copy of the generator step that RngByte (cop_handlers_movement) runs inline; no callers.
---------------------------------------------

?BANK 02

!rngState                       040F
!WRMPYA                         4202
!WRMPYB                         4203
!WRDIVL                         4204
!WRDIVH                         4205
!WRDIVB                         4206
!RDDIVL                         4214
!RDMPYL                         4216
!L_WRMPYA                       804202
!L_WRMPYB                       804203
!L_RDMPYL                       804216
!L_RDMPYH                       804217

---------------------------------------------

; Multiply then divide with the hardware registers: (A low × Y) ÷ A high.
; 
; Input: A = packed operand (low byte = multiplier, high byte = divisor), Y = 16-bit multiplicand.
; Algorithm: P1 = A low × Y low and P2 = A low × Y high (two 8×8 multiplies). The dividend is the 16-bit value P1 + (P2 low byte << 8): the carry out and P2's high byte are discarded, so only the low 16 bits of A low × Y are divided. The divisor is A high; WRDIVB triggers the divide.
; Output: 16-bit quotient in A (RDDIVL/RDDIVH). Divisor 0 returns $FFFF (hardware behaviour).
; Timing: 3 NOPs after the multiplies (plus the instructions between), 8 NOPs (16 cycles) after the divide.

MulDivide {
    SEP #$20              ; MulDivide: cascaded 16×8 hardware multiply, then divide by A high byte
    STA $WRMPYA           ; WRMPYA = A low byte (multiplicand for first partial product)
    XBA 
    PHA                   ; Push A high byte — used as 8-bit divisor after multiply
    REP #$20
    TYA 
    SEP #$20
    STA $WRMPYB           ; WRMPYB = Y low byte → P1 = A low × Y low
    XBA 
    NOP                   ; Wait for multiply result (hardware latency)
    NOP 
    NOP 
    LDY $RDMPYL           ; Y = P1 (16-bit read of RDMPYL/RDMPYH)
    STA $WRMPYB           ; WRMPYB = Y high byte (XBA moved it into A low) → P2 = A low × Y high
    REP #$20
    TYA 
    SEP #$20
    STA $WRDIVL           ; WRDIVL = P1 low byte
    XBA 
    CLC 
    ADC $RDMPYL           ; WRDIVH = P1 high + P2 low; the carry and P2 high are discarded (16-bit dividend)
    STA $WRDIVH
    PLA 
    STA $WRDIVB           ; WRDIVB = divisor (A high); triggers 16÷8 hardware divide
    NOP                   ; Wait for divide result (hardware latency)
    NOP 
    NOP 
    NOP 
    NOP 
    NOP 
    NOP 
    NOP 
    REP #$20
    LDA $RDDIVL           ; Return 16-bit quotient from RDDIVL
    RTL 
}
---------------------------------------------

; 8×8 multiply through long-address hardware registers (named Multiply8x8Unsigned, but the $4202/$4203 multiplier is unsigned).
; 
; Input: A low = first operand, A high = second operand (8-bit accumulator). STA $80:4202, XBA, STA $80:4203.
; Output: 16-bit product in A (high byte from $80:4217 via XBA, low byte from $80:4216).
; Long addresses make it independent of the current data bank.

Multiply8x8Unsigned {
    STA $L_WRMPYA         ; WRMPYA = A low byte (the hardware multiply is unsigned)
    XBA 
    STA $L_WRMPYB         ; WRMPYB = second operand (A high byte, moved down by XBA)
    NOP                   ; Wait for multiply result (hardware latency)
    NOP 
    NOP 
    NOP 
    LDA $L_RDMPYH         ; Product high byte, XBA, then product low byte: A = 16-bit unsigned product
    XBA 
    LDA $L_RDMPYL
    RTL 
}

---------------------------------------------
; 16÷8 unsigned hardware divide.
; 
; Input: Y = 16-bit dividend (WRDIVL/WRDIVH), A = 8-bit divisor (WRDIVB, which starts the divide).
; Output: A low = quotient low byte (RDDIVL), A high = remainder (RDMPYL), assembled with XBA. The quotient's high byte is not returned.
; 8 NOPs (16 cycles) cover the divide latency.

UnsignedDivide {
    STY $WRDIVL           ; UnsignedDivide: Y = 16-bit dividend, A = 8-bit divisor
    STA $WRDIVB           ; Store divisor to WRDIVB; triggers hardware 16÷8 divide
    NOP                   ; Wait for divide result (hardware latency)
    NOP 
    NOP 
    NOP 
    NOP 
    NOP 
    NOP 
    NOP 
    LDA $RDMPYL           ; Remainder (RDMPYL) → A high via XBA, then quotient low byte (RDDIVL) → A low
    XBA 
    LDA $RDDIVL
    RTL 
}

---------------------------------------------
; Software long division (no callers). Uses DP = 0 scratch $00-$06. A = divisor, Y = dividend.
; 
; The divisor is normalized by shifting left until its MSB is set (shift count in $00, normalized divisor in $02). The dividend then acts as a running remainder through two trial-subtraction loops: the first collects the integer quotient bits into $06 (shift count + 1 iterations, at most 16), the second 16 further bits into $04 (a 16.16 fixed-point quotient, inferred). Probably a development fallback before the hardware divider wrapper.

SoftDivide_Unused {
    PHD 
    PHA 
    LDA #$0000            ; SoftDivide (unused): set DP=$0000 — scratch at $00–$06 for long division
    TCD 
    PLA 
    STZ $00
    STZ $02
    STZ $04
    STZ $06
    CMP #$0000            ; Normalize divisor: left-shift A until MSB set; shift count in $00
    BMI loc_028217

  loc_028212:
    INC $00
    ASL 
    BPL loc_028212

  loc_028217:
    STA $02
    TYA                   ; Dividend (Y) becomes the running remainder in A; $02 holds the normalized divisor
    LDY #$0010            ; Integer-part quotient bits → $06: shift count + 1 trial subtractions (at most 16)
    CLC 

  loc_02821E:
    BCS loc_028224
    CMP $02
    BCC loc_028227

  loc_028224:
    SBC $02
    SEC 

  loc_028227:
    ROL $06               ; Shift remainder and record quotient bit (ROL $06)
    DEC $00
    BMI loc_028231
    ASL 
    DEY 
    BNE loc_02821E

  loc_028231:
    ASL 
    LDY #$0010            ; Further 16 trial subtractions: fraction bits → $04 (16.16 fixed-point result, inferred)
    CLC 

  loc_028236:
    BCS loc_02823C
    CMP $02
    BCC loc_02823F

  loc_02823C:
    SBC $02
    SEC 

  loc_02823F:
    ROL $04
    ASL 
    DEY 
    BNE loc_028236
    PLD 
    RTL 
}

---------------------------------------------
; Generator step (no callers); the same loops as the inline step in RngByte (cop_handlers_movement), without the output byte.
; 
; For X = 15..1: byte[$040F+X] += byte[$0410+X] + carry (one carry chain, $041E first). Then a ripple counter at $041F is incremented, carrying toward lower addresses until a byte does not wrap. The state array is $0410-$041F; rngState ($040F) is only the base used for the X offset.

RngStep_Unused {
    PHP 
    SEP #$20
    PHA 
    PHX 
    PHY 
    LDX #$000F            ; Same step as RngByte: for X = 15..1, byte[$040F+X] += byte[$0410+X] + carry
    LDA #$00
    XBA 
    CLC 

  loc_028254:
    LDA $0410, X          ; state[X-1] += state[X] + carry (one carry chain; $041E is updated first)
    ADC $rngState, X
    STA $rngState, X
    DEX 
    BNE loc_028254
    LDX #$0010            ; Ripple counter: INC from $041F downward until a byte does not wrap

  loc_028263:
    INC $rngState, X
    BNE loc_02826B
    DEX 
    BNE loc_028263

  loc_02826B:
    PLA 
    PLY 
    PLX 
    PLP 
    RTL 
}