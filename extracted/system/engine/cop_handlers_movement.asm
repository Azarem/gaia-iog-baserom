; COP handlers for smooth interpolated movement, grid snapping, proximity testing, and RNG (Bank $00, 15 handlers).
; 
; BranchIfActorNear/BranchIfPlayerNear test Manhattan distance within a radius operand (operand × 16 + 1 pixels). ResolveActorIndex converts an 8-bit actor list index to a WRAM pointer ($30 × index + $1000).
; 
; MoveToward is a yielding handler that interpolates position from current to target over N frames using hardware multiply/divide. InitSmoothMovement sets up the interpolation state: converts target deltas to absolute distances, computes per-frame velocity via UnsignedDivide, and sets extendedFlags bit 1.
; 
; SnapToGrid yields to func_0AA3A7 until the actor aligns to the 16×16 tile grid. ResumeAfterSnap restores the script pointer from snapResumePtr.
; 
; StageMove/TickMove implement frame-counted movement with sub-pixel precision. StageMove reads direction, speed, and frame delay operands, halving distance when the high byte is non-zero. TickMove advances each frame using hardware multiply/divide for velocity.
; 
; RngByte steps a 16-byte Galois LFSR. RngMod applies a modulo to the RNG output.
---------------------------------------------

?BANK 00

?INCLUDE 'cop_handlers_sprite'
?INCLUDE 'func_0AA3A7'
?INCLUDE 'hardware_math'
?INCLUDE 'sprite_composition'

!rngState                       040F
!rngModuloResult                0420
!scrollStepTableBase            06E0
!scrollStepIndex                06E2
!playerActor                    09AA
!WRMPYA                         4202
!WRMPYB                         4203
!WRDIVL                         4204
!WRDIVB                         4206
!RDDIVL                         4214
!RDMPYL                         4216
!animScratch                    7F0000
!chatPtr                        7F000A
!animScratch2                   7F000E
!moveXAlt                       7F0018
!moveYAlt                       7F001A
!extendedFlags                  7F002A
!moveScratch1                   7F002C
!moveScratch2                   7F002E
!snapResumePtr                  7F1018

---------------------------------------------

; COP #20 with one byte (actor list index), one byte (radius), and one &Code operand. Resolves the actor via ResolveActorIndex (index×$30+$1000) and branches if both Manhattan |ΔX| and |ΔY| are within (radius×16+1) pixels; otherwise skips the branch address.

BranchIfActorNear {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSR $&ResolveActorIndex
    BRA loc_008C2A
}

---------------------------------------------
; COP #21 with one byte (radius) and one &Code operand. Shares the same Manhattan proximity test as BranchIfActorNear but compares against playerActor instead of a script-specified actor index.

BranchIfPlayerNear {
    TYX 
    LDY $playerActor

  loc_008C2A:
    LDA [$0A]
    INC $0A
    AND #$00FF
    ASL                   ; Near-test radius = (operand × 16) + 1 pixel
    ASL 
    ASL 
    ASL 
    INC 
    STA $0000
    LDA $14
    SEC 
    SBC $0014, Y
    BPL loc_008C45
    EOR #$FFFF            ; Absolute value of ΔX for proximity comparison
    INC 

  loc_008C45:
    CMP $0000
    BCS loc_008C64
    LDA $16
    SEC 
    SBC $0016, Y
    BPL loc_008C56
    EOR #$FFFF
    INC 

  loc_008C56:
    CMP $0000
    BCS loc_008C64
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 

  loc_008C64:
    LDA [$0A]
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #22 with two byte operands (animation index, frame count). On first entry InitSmoothMovement computes per-frame velocity from moveXAlt/moveYAlt deltas via UnsignedDivide and sets extendedFlags bit 1; subsequent calls interpolate position each frame using hardware multiply/divide and yield RTL until the frame count expires.

MoveToward {
    TYX 
    LDA $extendedFlags, X ; MoveToward reads extendedFlags before axis step logic
    BIT #$0002
    BNE loc_008C7C
    JSR $&InitSmoothMovement

  loc_008C7C:
    LDA $animScratch2, X
    AND #$00FF
    CMP $24
    BNE loc_008C8A
    JMP $&MoveTowardFinish

  loc_008C8A:
    SEP #$20
    LDA $24
    STA $WRMPYA
    LDA $moveXAlt, X
    AND #$FF
    JSR $&MultiplyThenDivide
    SEC 
    SBC $animScratch, X
    BEQ loc_008CC3
    REP #$20
    AND #$00FF
    PHA 
    LDA $animScratch2, X
    ASL 
    BMI loc_008CB1
    PLA 
    BRA loc_008CB6

  loc_008CB1:
    PLA 
    EOR #$FFFF
    INC 

  loc_008CB6:
    STA $moveScratch1, X
    SEP #$20
    LDA $0000
    STA $animScratch, X

  loc_008CC3:
    LDA $moveYAlt, X
    AND #$FF
    JSR $&MultiplyThenDivide
    SEC 
    SBC $animScratch+1, X
    REP #$20
    BEQ loc_008CF7
    AND #$00FF
    PHA 
    LDA $animScratch2, X
    ASL 
    BCS loc_008CE3
    PLA 
    BRA loc_008CE8

  loc_008CE3:
    PLA 
    EOR #$FFFF
    INC 

  loc_008CE8:
    STA $moveScratch2, X
    SEP #$20
    LDA $0000
    STA $animScratch+1, X
    REP #$20

  loc_008CF7:
    INC $24
    LDA $animScratch+2, X
    DEC 
    BPL loc_008D08

  loc_008D00:
    JSL $@sprite_composition.UpdateActorAnimation
    BCS loc_008D00
    LDA $08

  loc_008D08:
    STZ $08
    STA $animScratch+2, X
    PLA 
    PLA 
    RTL 
}

MoveTowardFinish {
    LDA $extendedFlags, X ; MoveTowardFinish
    AND #$FFFD
    STA $extendedFlags, X
    LDA $0A
    INC 
    INC 
    STA $00
    PLA 
    PLA 
    RTL 
}

ReadMultiplyResult {
    NOP 
    LDY $RDMPYL
    RTS 
}

ReadDivideResult {
    NOP 
    NOP 
    NOP 
    NOP 
    NOP 
    LDA $RDDIVL
    RTS 
}

MultiplyThenDivide {
    STA $WRMPYB           ; STA WRMPYB: start hardware multiply for velocity calc
    JSR $&ReadMultiplyResult
    STY $WRDIVL           ; Product → WRDIVL: feed multiply result into divider
    LDA $animScratch2, X
    DEC 
    STA $WRDIVB           ; STA WRDIVB: frame count divisor from animScratch2
    BEQ loc_008D49
    JSR $&ReadDivideResult

  loc_008D49:
    STA $0000
    RTS 
}

InitSmoothMovement {
    STZ $0004
    LDA $0A
    DEC 
    DEC 
    STA $00
    LDY #$0001
    LDA [$0A]
    AND #$00FF
    CMP #$00FF
    BNE loc_008D65
    LDA $28

  loc_008D65:
    JSR $&cop_handlers_sprite.ProcessAnimFlag
    LDA $moveXAlt, X
    SEC 
    SBC $14
    CLC 
    BPL loc_008D77
    EOR #$FFFF
    INC 
    SEC 

  loc_008D77:
    ROR $0004             ; ROR $0004: record dominant movement axis in bit 0
    BIT #$FF00
    BEQ loc_008D82
    LDA #$00FE

  loc_008D82:
    STA $moveXAlt, X
    LDA $moveYAlt, X
    SEC 
    SBC $16
    CLC 
    BPL loc_008D95
    EOR #$FFFF
    INC 
    SEC 

  loc_008D95:
    ROR $0004
    BIT #$FF00
    BEQ loc_008DA0
    LDA #$00FE

  loc_008DA0:
    STA $moveYAlt, X
    CMP $moveXAlt, X
    BCS loc_008DAE
    LDA $moveXAlt, X

  loc_008DAE:
    PHA 
    LDA [$0A], Y
    AND #$00FF
    PLY 
    SEP #$20
    JSL $@hardware_math.UnsignedDivide ; JSL UnsignedDivide: distance/duration → pixels per frame
    INC 
    STA $animScratch2, X
    LDA $0005
    STA $7F000F, X
    REP #$20
    LDA #$0000
    STA $animScratch, X
    STA $animScratch+2, X
    STA $24
    STZ $2C
    STZ $2E
    LDA $extendedFlags, X
    ORA #$0002            ; ORA #$0002: extendedFlags bit 1 = smooth move active
    STA $extendedFlags, X
    RTS 
}

---------------------------------------------
; COP #43 with no operands. If the actor is not 16×16 tile-aligned ((X−8)|Y & $0F ≠ 0), saves snapResumePtr/$7F101A and yields RTI into func_0AA3A7; otherwise continues immediately.

SnapToGrid {
    TYX 
    STZ $2C
    STZ $2E
    LDA $14
    SEC 
    SBC #$0008
    ORA $16
    AND #$000F            ; AND #$000F: skip snap if already on 16×16 tile grid
    BEQ loc_008E14
    LDA $0A
    STA $snapResumePtr, X
    LDA $02
    STA $7F101A, X
    LDA #$&func_0AA3A7    ; Yield to func_0AA3A7 snap helper; resume via snapResumePtr
    STA $02, S
    SEP #$20
    LDA #$^func_0AA3A7
    STA $02
    STA $04, S
    REP #$20
    RTI 

  loc_008E14:
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #4A with no operands. Restores the saved script PC and bank from snapResumePtr ($7F1018) and $7F101A after grid snapping completes, then clears both save slots.

ResumeAfterSnap {
    TYX 
    LDA $snapResumePtr, X
    STA $02, S
    SEP #$20
    LDA $7F101A, X
    STA $04, S
    REP #$20
    LDA #$0000
    STA $snapResumePtr, X
    STA $7F101A, X
    RTI 
}

---------------------------------------------
; COP #52 with three byte operands (animation index, speed, frame delay). Computes signed pixel deltas from moveXAlt/moveYAlt vs current position, repeatedly halves them while the high byte is non-zero, divides total distance by signed speed for frame count, and initializes TickMove state before RTI continuation.

StageMove {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    CMP #$00FF
    BNE loc_008E45
    LDA $28

  loc_008E45:
    JSR $&cop_handlers_sprite.ProcessAnimFlag
    LDY #$0000
    LDA $moveXAlt, X
    SEC 
    SBC $14
    BPL loc_008E5B
    LDY #$4000            ; LDY #$4000: animScratch2 bit 14 = negative X delta
    EOR #$FFFF
    INC 

  loc_008E5B:
    STA $moveXAlt, X
    TYA 
    STA $animScratch2, X
    LDY #$0000
    LDA $moveYAlt, X
    SEC 
    SBC $16
    BPL loc_008E77
    LDY #$8000            ; LDY #$8000: animScratch2 bit 15 = negative Y delta
    EOR #$FFFF
    INC 

  loc_008E77:
    STA $moveYAlt, X
    CMP $moveXAlt, X
    BCS loc_008E85
    LDA $moveXAlt, X

  loc_008E85:
    PHA 
    TYA 
    ORA $animScratch2, X
    STA $animScratch2, X
    LDA #$0000
    STA $chatPtr, X
    PLA 

  loc_008E97:
    BIT #$FF00            ; Halve distance loop while high byte of delta non-zero
    BEQ loc_008EA4
    LSR 
    PHA 
    JSR $&HalveMovementDistance
    PLA 
    BRA loc_008E97

  loc_008EA4:
    STA $WRDIVL           ; STA WRDIVL: total pixel distance as dividend
    LDA [$0A]
    INC $0A
    AND #$00FF
    SEP #$20
    CMP #$80              ; CMP #$80: treat speed byte as signed if ≥$80
    BCC loc_008EB7
    EOR #$FF
    INC 

  loc_008EB7:
    STA $WRDIVB           ; STA WRDIVB: signed speed divisor for frame count
    REP #$20
    LDA [$0A]
    INC $0A
    AND #$00FF
    XBA                   ; XBA: frame counter high byte from script operand
    STA $animScratch+2, X
    LDA $RDDIVL
    INC 
    ORA $animScratch2, X
    STA $animScratch2, X
    BCC loc_008ED9
    JSR $&HalveMovementDistance

  loc_008ED9:
    LDA #$0000
    STA $animScratch, X
    STA $24
    STA $00002C, X
    STA $00002E, X
    LDA $0C
    STA $02
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

HalveMovementDistance {
    LDA $moveXAlt, X
    LSR                   ; Halve remaining X distance each halving iteration
    STA $moveXAlt, X
    LDA $moveYAlt, X
    LSR                   ; Halve remaining Y distance each halving iteration
    STA $moveYAlt, X
    LDA $chatPtr, X
    INC 
    STA $chatPtr, X
    RTS 
}

---------------------------------------------
; COP #53 with no operands. Per-frame companion to StageMove: MovementVelocityCompute uses hardware multiply/divide to advance position on both axes, waits on UpdateActorAnimation when needed, and yields RTL until the staged trajectory (and any halving passes) completes.

TickMove {
    TYX 

  TickMoveStep:
    LDA $animScratch2, X  ; TickMoveStep
    AND #$3FFF
    CMP $24
    BNE loc_008F1C
    JMP $&TickMoveComplete

  loc_008F1C:
    SEP #$20
    LDA $24               ; STA WRMPYA: tick counter drives per-frame velocity scale
    STA $WRMPYA
    LDA $moveYAlt, X
    JSR $&MovementVelocityCompute ; MovementVelocityCompute: WRMPY then WRDIV for Y axis
    SBC $animScratch+1, X
    BEQ loc_008F55
    PHA 
    LDA $animScratch2, X
    ASL 
    PLA 
    BCC loc_008F3D
    EOR #$FFFF
    INC 

  loc_008F3D:
    AND #$00FF
    BIT #$0080
    BEQ loc_008F48
    ORA #$FF00

  loc_008F48:
    STA $moveScratch2, X
    SEP #$20
    LDA $0000
    STA $animScratch+1, X

  loc_008F55:
    SEP #$20
    LDA $moveXAlt, X      ; MovementVelocityCompute: same multiply/divide for X axis
    JSR $&MovementVelocityCompute
    SBC $animScratch, X
    BEQ loc_008F8A
    PHA 
    LDA $animScratch2, X
    ASL 
    ASL 
    PLA 
    BCC loc_008F72
    EOR #$FFFF
    INC 

  loc_008F72:
    AND #$00FF
    BIT #$0080
    BEQ loc_008F7D
    ORA #$FF00

  loc_008F7D:
    STA $moveScratch1, X
    SEP #$20
    LDA $0000
    STA $animScratch, X

  loc_008F8A:
    SEP #$20
    LDA $animScratch+3, X ; Frame delay in animScratch+3 before next move step
    BMI loc_008F9C
    DEC 
    BNE loc_008F98
    JMP $&TickMoveComplete

  loc_008F98:
    STA $animScratch+3, X

  loc_008F9C:
    LDA $animScratch+2, X
    DEC 
    BPL loc_008FAF
    REP #$20              ; Spin until UpdateActorAnimation completes (BCS loop)

  loc_008FA5:
    JSL $@sprite_composition.UpdateActorAnimation
    BCS loc_008FA5
    SEP #$20
    LDA $08

  loc_008FAF:
    STA $animScratch+2, X
    REP #$20
    STZ $08
    INC $24
    PLA 
    PLA 
    RTL 
}

TickMoveComplete {
    REP #$20              ; TickMoveComplete
    LDA $chatPtr, X
    BEQ loc_008FD5
    DEC 
    STA $chatPtr, X
    LDA #$0000
    STA $animScratch, X
    STA $24
    JMP $&TickMoveStep

  loc_008FD5:
    LDA $0A
    STA $00
    PLA 
    PLA 
    RTL 
}

MovementVelocityCompute {
    STA $WRMPYB           ; MovementVelocityCompute entry — WRMPYB then RDMPYL→WRDIV
    LDA $animScratch2, X
    DEC 
    LDY $RDMPYL           ; RDMPYL → WRDIVL: multiply output feeds hardware divider
    STY $WRDIVL
    STA $WRDIVB
    NOP 
    NOP 
    NOP 
    NOP 
    NOP 
    REP #$20
    SEC 
    LDA $RDDIVL           ; RDDIVL: pixels-per-frame result after divide latency
    STA $0000
    RTS 
}

---------------------------------------------
; COP #23 with no operands. Advances a 16-byte Galois LFSR chain at $040F–$041F and returns the latest output byte from $0410 in A.

RngByte {
    PHY 
    SEP #$20
    LDX #$000F
    LDA #$00
    XBA 
    CLC 

  loc_009006:
    LDA $0410, X          ; 16-byte Galois LFSR step across $040F–$041F state
    ADC $rngState, X
    STA $rngState, X      ; ADC chain propagates carry through 16-byte RNG state
    DEX 
    BNE loc_009006
    LDX #$0010

  loc_009015:
    INC $rngState, X
    BNE loc_00901D
    DEX 
    BNE loc_009015

  loc_00901D:
    REP #$20
    PLX 
    LDA $0A
    STA $02, S
    LDA $0410
    AND #$00FF
    RTI 
}

---------------------------------------------
; COP #24 with one byte operand (modulus). Applies repeated subtraction modulo to the current RngByte output ($0410) and stores the result in rngModuloResult ($0420).

RngMod {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0000
    LDA $0410
    AND #$00FF

  loc_00903C:
    SEC 
    SBC $0000
    BPL loc_00903C
    CLC 
    ADC $0000
    STA $rngModuloResult
    LDA $0A
    STA $02, S
    RTI 
}
---------------------------------------------

; Internal JSR helper that converts an 8-bit actor list index in A to a WRAM actor pointer in Y. Computes Y = index × $30 + $1000 using SignedMultiply, matching the fixed $30-byte actor structure layout. Called by BranchIfActorNear and BranchIfActorAt before distance or coordinate comparisons.

ResolveActorIndex {
    SEP #$20
    XBA 
    LDA #$30
    JSL $@hardware_math.SignedMultiply
    REP #$20
    CLC 
    ADC #$1000
    TAY 
    RTS 
}

CameraScrollStepLookup {
    PHP 
    PHX 
    LDA $scrollStepIndex
    INC $scrollStepIndex
    ASL 
    CLC 
    ADC $scrollStepTableBase
    TAX 
    LDA $0000, X
    BIT #$FF00
    BEQ loc_00B150
    PLX 
    PLP 
    CLC 
    RTS 

  loc_00B150:
    STZ $scrollStepIndex
    PLX 
    PLP 
    SEC 
    RTS 
}