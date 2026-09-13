; Hardware math utilities — SNES multiplication and division using PPU math registers (163840–164464, Bank 02).
; 
; Provides wrappers around the SNES hardware multiplier ($4202/$4203/$4216/$4217) and divider ($4204/$4205/$4206/$4214) registers. The SNES 5A22 CPU has built-in 8×8 unsigned multiply and 16÷8 unsigned divide units, but they require careful setup and timing (NOP delays for result latency).
; 
; === ROUTINES ===
; 
; MulDivide: Cascaded 16×8 multiply then 8-bit divide. Splits the 16-bit accumulator into A_high (divisor) and A_low (multiplicand), performs A_low × Y (16-bit) using two cascaded 8×8 hardware multiplies with cross-product accumulation, then divides the 32-bit intermediate by A_high using the hardware divider. Returns the 16-bit quotient. Used for scaled arithmetic (e.g., proportional coordinate calculations).
; 
; SignedMultiply: 8×8 signed multiply using long-address hardware registers ($80:4202/$80:4203). Returns 16-bit signed result in A (high:low via XBA). Uses long addresses to access the hardware registers from any data bank.
; 
; UnsignedDivide: 16÷8 unsigned divide. Y = dividend (16-bit), A = divisor (8-bit). Returns quotient in A low byte ($4214), remainder in A high byte ($4216). 8 NOP delay for divide completion.
; 
; SoftDivide_Unused: Software long division (unused). Implements bit-by-bit division using DP scratch space. Likely a fallback or development artifact.
; 
; IncrementCounter_Unused: Adds 16 bytes from $0410 to the RNG state at $040F (unused). Appears to be a counter-based RNG seeding function.
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

; Cascaded 16×8 multiply-then-divide using SNES hardware math registers.
; 
; Input: A = packed operand (A_high = divisor, A_low = multiplicand), Y = 16-bit multiplier.
; Algorithm: Splits A into high/low bytes. Performs A_low × Y using two cascaded 8×8 hardware multiplies with cross-product accumulation to produce a 24-bit intermediate. Then divides by A_high using the hardware divider.
; Output: 16-bit quotient in A.
; Timing: 3 NOPs after multiply, 8 NOPs after divide (hardware latency).

MulDivide {
    SEP #$20              ; MulDivide: cascaded 16×8 hardware multiply, then divide by A high byte
    STA $WRMPYA           ; WRMPYA = A low byte (multiplicand for first partial product)
    XBA 
    PHA                   ; Push A high byte — used as 8-bit divisor after multiply
    REP #$20
    TYA 
    SEP #$20
    STA $WRMPYB           ; WRMPYB = Y; hardware 8×8 multiply (A_low × Y)
    XBA 
    NOP                   ; Wait for multiply result (hardware latency)
    NOP 
    NOP 
    LDY $RDMPYL
    STA $WRMPYB           ; Second 8×8 multiply for high-byte cross product term
    REP #$20
    TYA 
    SEP #$20
    STA $WRDIVL           ; WRDIVL = low byte of combined 16×8 product (dividend)
    XBA 
    CLC 
    ADC $RDMPYL           ; WRDIVH += high byte of cross product (finish dividend)
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

; 8×8 signed multiply using long-address hardware registers.
; 
; Input: A = 8-bit multiplicand, stored via STA $80:4202 (WRMPYA). Second operand from XBA stored to $80:4203 (WRMPYB).
; Output: 16-bit signed result in A (high byte from $80:4217, low byte from $80:4216, assembled via XBA).
; Uses long addresses ($80:xxxx) to access hardware registers regardless of current data bank.

SignedMultiply {
    STA $L_WRMPYA         ; SignedMultiply: 8×8 signed via long-address WRMPYA/WRMPYB ($80:4202/$80:4203)
    XBA 
    STA $L_WRMPYB         ; WRMPYB = second signed operand (from B via XBA)
    NOP                   ; Wait for multiply result (hardware latency)
    NOP 
    NOP 
    NOP 
    LDA $L_RDMPYH         ; Load signed product high byte; XBA assembles 16-bit result in A
    XBA 
    LDA $L_RDMPYL
    RTL 
}

---------------------------------------------
; 16÷8 unsigned hardware divide.
; 
; Input: Y = 16-bit dividend (stored to WRDIVL/WRDIVH), A = 8-bit divisor (stored to WRDIVB).
; Output: A = quotient (low byte from $4214/RDDIVL) | remainder (high byte from $4216/RDMPYL), assembled via XBA.
; 8 NOP delay for hardware divide completion.

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
    LDA $RDMPYL           ; Return A = quotient|remainder (RDDIVL low, RDMPYL high via XBA)
    XBA 
    LDA $RDDIVL
    RTL 
}

---------------------------------------------
; Software long division (unused). Implements bit-by-bit binary division using direct page scratch ($00–$06). Sets up a temporary DP at $0000, normalizes the dividend by left-shifting until MSB is set, then performs two 16-iteration division loops to produce a 32-bit quotient in $04:$06. Likely a development fallback before the hardware divider wrapper was finalized.

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
    TYA                   ; Store normalized divisor in $02; Y holds the dividend
    LDY #$0010            ; Build high quotient word ($06): 16-iteration bit-by-bit trial subtract
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
    LDY #$0010            ; Build low quotient word ($04): second 16-iteration divide pass
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
; Counter/RNG state increment (unused). Adds 16 bytes from $0410 to the RNG state array at $040F with carry propagation across all bytes, then increments the first non-$FF byte in the state array. Appears to be an entropy accumulation function.

IncrementCounter_Unused {
    PHP 
    SEP #$20
    PHA 
    PHX 
    PHY 
    LDX #$000F            ; IncrementCounter (unused): add $0410[0..F] into rngState with carry
    LDA #$00
    XBA 
    CLC 

  loc_028254:
    LDA $0410, X          ; 16-byte ripple add: rngState[i] += $0410[i]
    ADC $rngState, X
    STA $rngState, X
    DEX 
    BNE loc_028254
    LDX #$0010            ; Propagate carry — increment next rngState byte until no wrap

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