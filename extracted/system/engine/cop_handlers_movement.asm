; COP handlers for smooth interpolated movement, grid snapping, proximity testing, and RNG (Bank $00, 9 COP handlers + 10 internal subroutines).
; 
; BranchIfActorNear/BranchIfPlayerNear test Manhattan distance within a radius operand (operand × 16 + 1 pixels). ResolveActorIndex converts an 8-bit actor list index to a WRAM pointer ($30 × index + $1000).
; 
; MoveToward is a yielding handler that interpolates position from current to target over N frames using hardware multiply/divide. InitSmoothMovement sets up the interpolation state: converts target deltas to absolute distances, computes per-frame velocity via UnsignedDivide, and sets extendedFlags bit 1. MoveTowardFinish clears the smooth-move flag when complete.
; 
; The hardware math pipeline uses three chained helpers: MultiplyThenDivide feeds WRMPYB → RDMPYL → WRDIVL → RDDIVL for per-frame velocity, with ReadMultiplyResult (1 NOP) and ReadDivideResult (5 NOPs) providing the required hardware latency delays. MovementVelocityCompute wraps this pipeline for TickMove's per-axis calculations.
; 
; SnapToGrid yields to func_0AA3A7 until the actor aligns to the 16×16 tile grid. ResumeAfterSnap restores the script pointer from snapResumePtr.
; 
; StageMove/TickMove implement frame-counted movement with sub-pixel precision. StageMove reads direction, speed, and frame delay operands, halving distance via HalveMovementDistance when the high byte is non-zero. TickMove advances each frame; TickMoveComplete handles halving-pass re-entry or final cleanup.
; 
; RngByte steps a 16-byte Galois LFSR. RngMod applies a modulo to the RNG output.
; 
; CameraScrollStepLookup reads scroll speed entries from scrollStepTableBase for the four CameraPan COP handlers in cop_handlers_effects.
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
    LDA [$0A]             ; Read actor list index byte operand
    INC $0A
    AND #$00FF
    JSR $&ResolveActorIndex ; ResolveActorIndex: index × $30 + $1000 → Y = actor WRAM pointer
    BRA loc_008C2A
}

---------------------------------------------
; COP #21 with one byte (radius) and one &Code operand. Shares the same Manhattan proximity test as BranchIfActorNear but compares against playerActor instead of a script-specified actor index.

BranchIfPlayerNear {
    TYX 
    LDY $playerActor      ; Use player actor pointer for proximity test

  loc_008C2A:
    LDA [$0A]             ; Read radius byte operand
    INC $0A
    AND #$00FF
    ASL                   ; Radius × 16 + 1: tile radius → pixel threshold
    ASL 
    ASL 
    ASL 
    INC 
    STA $0000             ; Store pixel threshold in DP $0000 for axis comparisons
    LDA $14               ; ΔX = actor.X − target.X
    SEC 
    SBC $0014, Y
    BPL loc_008C45
    EOR #$FFFF            ; Absolute value of ΔX for proximity comparison
    INC 

  loc_008C45:
    CMP $0000             ; |ΔX| ≥ threshold → not near (skip branch)
    BCS loc_008C64
    LDA $16               ; ΔY = actor.Y − target.Y
    SEC 
    SBC $0016, Y
    BPL loc_008C56
    EOR #$FFFF
    INC 

  loc_008C56:
    CMP $0000             ; |ΔY| ≥ threshold → not near
    BCS loc_008C64
    LDA [$0A]             ; Both axes within radius: take branch to &Code target
    INC $0A
    INC $0A
    STA $02, S
    RTI 

  loc_008C64:
    LDA [$0A]             ; Outside radius: skip branch operand and continue
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
    LDA $extendedFlags, X ; Check extendedFlags bit 1: skip init if smooth move already active
    BIT #$0002
    BNE loc_008C7C
    JSR $&InitSmoothMovement ; First entry: init interpolation (velocity, accumulators, flags)

  loc_008C7C:
    LDA $animScratch2, X  ; Read target tick count from animScratch2 low byte
    AND #$00FF
    CMP $24               ; Compare target ticks against current tick counter $24
    BNE loc_008C8A
    JMP $&MoveTowardFinish ; Tick count reached: jump to MoveTowardFinish (clear flags, yield)

  loc_008C8A:
    SEP #$20
    LDA $24
    STA $WRMPYA           ; STA WRMPYA: tick counter as hardware multiplier input
    LDA $moveXAlt, X      ; Load X axis distance byte for velocity computation
    AND #$FF
    JSR $&MultiplyThenDivide ; MultiplyThenDivide: tick×distance / frameCount → per-frame X velocity
    SEC                   ; Subtract previous accumulator to get this frame's X delta
    SBC $animScratch, X
    BEQ loc_008CC3        ; Zero X delta this frame: skip X position update
    REP #$20
    AND #$00FF
    PHA 
    LDA $animScratch2, X
    ASL                   ; Test X direction sign via bit 15 of animScratch2
    BMI loc_008CB1
    PLA 
    BRA loc_008CB6

  loc_008CB1:
    PLA                   ; X direction negative: negate velocity
    EOR #$FFFF
    INC 

  loc_008CB6:
    STA $moveScratch1, X  ; Store signed X velocity in moveScratch1 ($7F002C)
    SEP #$20
    LDA $0000             ; Update X accumulator to match expected position at this tick
    STA $animScratch, X

  loc_008CC3:
    LDA $moveYAlt, X      ; Load Y axis distance byte for velocity computation
    AND #$FF
    JSR $&MultiplyThenDivide ; MultiplyThenDivide: tick×distance / frameCount → per-frame Y velocity
    SEC                   ; Subtract previous Y accumulator for frame delta
    SBC $animScratch+1, X
    REP #$20
    BEQ loc_008CF7
    AND #$00FF
    PHA 
    LDA $animScratch2, X  ; Test Y direction sign via carry from ASL bit 14
    ASL 
    BCS loc_008CE3
    PLA 
    BRA loc_008CE8

  loc_008CE3:
    PLA 
    EOR #$FFFF
    INC 

  loc_008CE8:
    STA $moveScratch2, X  ; Store signed Y velocity in moveScratch2 ($7F002E)
    SEP #$20
    LDA $0000             ; Update Y accumulator
    STA $animScratch+1, X
    REP #$20

  loc_008CF7:
    INC $24               ; Increment tick counter for next frame
    LDA $animScratch+2, X ; Decrement animation frame delay counter
    DEC 
    BPL loc_008D08

  loc_008D00:
    JSL $@sprite_composition.UpdateActorAnimation ; Spin UpdateActorAnimation until cycle complete (BCS loop)
    BCS loc_008D00
    LDA $08

  loc_008D08:
    STZ $08               ; Zero frame timer and store delay for next cycle
    STA $animScratch+2, X
    PLA                   ; Pop COP frame and yield RTL until next tick
    PLA 
    RTL 
}

---------------------------------------------
; Cleanup exit for MoveToward when the frame counter matches the target tick count.
; 
; Clears extendedFlags bit 1 (smooth move active) via AND #$FFFD, skips the two-byte operand by advancing $0A, and yields RTL to resume the calling script. Called via JMP from MoveToward when animScratch2 low byte equals $24.

MoveTowardFinish {
    LDA $extendedFlags, X ; Clear extendedFlags bit 1 (smooth move), skip operands, yield RTL
    AND #$FFFD
    STA $extendedFlags, X
    LDA $0A               ; Skip 2-byte operand and save resume PC
    INC 
    INC 
    STA $00
    PLA                   ; Yield RTL to resume calling script
    PLA 
    RTL 
}

---------------------------------------------
; Hardware multiply latency wrapper. One NOP provides the 8-cycle wait required after writing WRMPYB before the SNES hardware multiplier result is valid, then reads RDMPYL into Y. Called by MultiplyThenDivide.

ReadMultiplyResult {
    NOP                   ; 1 NOP: 8-cycle wait for SNES hardware multiplier result
    LDY $RDMPYL           ; Read multiply product from RDMPYL → Y
    RTS 
}

---------------------------------------------
; Hardware divide latency wrapper. Five NOPs provide the 16-cycle wait required after writing WRDIVB before the SNES hardware divider result is valid, then reads RDDIVL into A. Called by MultiplyThenDivide.

ReadDivideResult {
    NOP                   ; 5 NOPs: 16-cycle wait for SNES hardware divider result
    NOP 
    NOP 
    NOP 
    NOP 
    LDA $RDDIVL           ; Read divide quotient from RDDIVL → A
    RTS 
}

---------------------------------------------
; Chained hardware multiply→divide for per-frame interpolation velocity.
; 
; Writes the axis distance byte to WRMPYB (starting the multiply), reads the product from RDMPYL into WRDIVL as the dividend, uses animScratch2−1 as the frame-count divisor in WRDIVB, and returns the quotient (pixels per frame) in A via $0000. When the divisor is zero (BEQ), skips the divide to avoid a division-by-zero hang. Called twice per MoveToward tick for X and Y axes.

MultiplyThenDivide {
    STA $WRMPYB           ; STA WRMPYB: start hardware multiply for velocity calc
    JSR $&ReadMultiplyResult ; Wait for multiply result
    STY $WRDIVL           ; STY WRDIVL: feed multiply product into divider as dividend
    LDA $animScratch2, X  ; Load frame count from animScratch2
    DEC                   ; DEC: frame count − 1 as divisor
    STA $WRDIVB           ; STA WRDIVB: frame count divisor from animScratch2
    BEQ loc_008D49        ; Zero divisor guard: skip divide to avoid hardware hang
    JSR $&ReadDivideResult

  loc_008D49:
    STA $0000             ; Store quotient (pixels-per-frame velocity) in $0000
    RTS 
}

---------------------------------------------
; Computes interpolation setup for MoveToward on first entry.
; 
; Converts moveXAlt/moveYAlt from absolute target coordinates to signed deltas from the current position ($14/$16), takes their absolute values, caps each at $00FE when the high byte is non-zero, and records the sign of each axis in $0004 via ROR. Selects the larger axis as the travel distance, divides by the frame-count operand via UnsignedDivide for per-frame velocity, zeroes animScratch/tick state, and sets extendedFlags bit 1 to mark smooth movement active.

InitSmoothMovement {
    STZ $0004             ; Zero direction sign accumulator ($0004) for ROR tracking
    LDA $0A               ; Load rewind PC (COP − 2) as entry point
    DEC 
    DEC 
    STA $00
    LDY #$0001
    LDA [$0A]             ; Read animation index operand
    AND #$00FF
    CMP #$00FF            ; $FF = keep current animation index unchanged
    BNE loc_008D65
    LDA $28

  loc_008D65:
    JSR $&cop_handlers_sprite.ProcessAnimFlag ; ProcessAnimFlag: set $28 with directional flip handling
    LDA $moveXAlt, X      ; Compute X delta: moveXAlt (target) − current actor.X ($14)
    SEC 
    SBC $14
    CLC 
    BPL loc_008D77        ; Positive → rightward movement
    EOR #$FFFF            ; Negative → negate for absolute distance
    INC 
    SEC 

  loc_008D77:
    ROR $0004             ; ROR $0004: shift X sign bit into direction tracking word
    BIT #$FF00            ; High byte nonzero → cap distance at $00FE (single-byte max)
    BEQ loc_008D82
    LDA #$00FE

  loc_008D82:
    STA $moveXAlt, X      ; Store absolute X distance back to moveXAlt
    LDA $moveYAlt, X      ; Compute Y delta: moveYAlt (target) − current actor.Y ($16)
    SEC 
    SBC $16
    CLC 
    BPL loc_008D95
    EOR #$FFFF
    INC 
    SEC 

  loc_008D95:
    ROR $0004             ; ROR $0004: shift Y sign into direction word
    BIT #$FF00
    BEQ loc_008DA0
    LDA #$00FE

  loc_008DA0:
    STA $moveYAlt, X      ; Store absolute Y distance back to moveYAlt
    CMP $moveXAlt, X      ; Compare Y vs X distance: select larger axis for primary travel
    BCS loc_008DAE
    LDA $moveXAlt, X

  loc_008DAE:
    PHA                   ; Push larger distance as dividend for velocity calc
    LDA [$0A], Y          ; Read frame-count operand (duration in ticks)
    AND #$00FF
    PLY 
    SEP #$20
    JSL $@hardware_math.UnsignedDivide ; JSL UnsignedDivide: distance/duration → pixels per frame
    INC 
    STA $animScratch2, X  ; Store velocity+1 as tick limit in animScratch2
    LDA $0005             ; Load animation frame delay byte in $7F000F
    STA $7F000F, X
    REP #$20
    LDA #$0000            ; Zero accumulators, tick counter, and movement deltas
    STA $animScratch, X
    STA $animScratch+2, X
    STA $24
    STZ $2C
    STZ $2E
    LDA $extendedFlags, X
    ORA #$0002            ; Set extendedFlags bit 1 (smooth interpolated move active)
    STA $extendedFlags, X
    RTS 
}

---------------------------------------------
; COP #43 with no operands. If the actor is not 16×16 tile-aligned ((X−8)|Y & $0F ≠ 0), saves snapResumePtr/$7F101A and yields RTI into func_0AA3A7; otherwise continues immediately.

SnapToGrid {
    TYX 
    STZ $2C               ; Clear movement deltas ($2C/$2E) before snap
    STZ $2E
    LDA $14               ; Check X grid alignment: (actor.X − 8) for sprite centering
    SEC 
    SBC #$0008
    ORA $16               ; OR with Y to check both axes simultaneously
    AND #$000F            ; AND #$000F: skip snap if already on 16×16 tile grid
    BEQ loc_008E14
    LDA $0A               ; Not aligned: save script resume PC in snapResumePtr
    STA $snapResumePtr, X
    LDA $02
    STA $7F101A, X        ; Save bank byte for post-snap restoration
    LDA #$&func_0AA3A7    ; Yield to func_0AA3A7 snap helper; resume via snapResumePtr
    STA $02, S
    SEP #$20
    LDA #$^func_0AA3A7
    STA $02
    STA $04, S
    REP #$20
    RTI 

  loc_008E14:
    LDA $0A               ; Already aligned: continue script immediately
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #4A with no operands. Restores the saved script PC and bank from snapResumePtr ($7F1018) and $7F101A after grid snapping completes, then clears both save slots.

ResumeAfterSnap {
    TYX 
    LDA $snapResumePtr, X ; Restore saved script PC from snapResumePtr ($7F1018)
    STA $02, S
    SEP #$20
    LDA $7F101A, X        ; Restore saved bank byte from $7F101A
    STA $04, S
    REP #$20
    LDA #$0000            ; Clear both save slots after restoration
    STA $snapResumePtr, X
    STA $7F101A, X
    RTI 
}

---------------------------------------------
; COP #52 with three byte operands (animation index, speed, frame delay). Computes signed pixel deltas from moveXAlt/moveYAlt vs current position, repeatedly halves them while the high byte is non-zero, divides total distance by signed speed for frame count, and initializes TickMove state before RTI continuation.

StageMove {
    TYX 
    LDA [$0A]             ; Read animation index byte for staged movement
    INC $0A
    AND #$00FF
    CMP #$00FF            ; $FF = keep current animation
    BNE loc_008E45
    LDA $28

  loc_008E45:
    JSR $&cop_handlers_sprite.ProcessAnimFlag ; ProcessAnimFlag: set animation with directional flip
    LDY #$0000
    LDA $moveXAlt, X      ; Compute X delta: moveXAlt − actor.X ($14)
    SEC 
    SBC $14
    BPL loc_008E5B
    LDY #$4000            ; LDY #$4000: animScratch2 bit 14 = negative X delta
    EOR #$FFFF
    INC 

  loc_008E5B:
    STA $moveXAlt, X      ; Store absolute X distance in moveXAlt
    TYA 
    STA $animScratch2, X
    LDY #$0000
    LDA $moveYAlt, X      ; Compute Y delta: moveYAlt − actor.Y ($16)
    SEC 
    SBC $16
    BPL loc_008E77
    LDY #$8000            ; LDY #$8000: animScratch2 bit 15 = negative Y delta
    EOR #$FFFF
    INC 

  loc_008E77:
    STA $moveYAlt, X      ; Store absolute Y distance in moveYAlt
    CMP $moveXAlt, X      ; Select larger axis distance for frame count calculation
    BCS loc_008E85
    LDA $moveXAlt, X

  loc_008E85:
    PHA 
    TYA 
    ORA $animScratch2, X  ; Combine X/Y direction bits into animScratch2
    STA $animScratch2, X
    LDA #$0000
    STA $chatPtr, X       ; Zero halving-pass counter in chatPtr
    PLA 

  loc_008E97:
    BIT #$FF00            ; Loop: halve distances while high byte nonzero (fit in single byte)
    BEQ loc_008EA4
    LSR 
    PHA 
    JSR $&HalveMovementDistance ; HalveMovementDistance: LSR both axes, increment pass counter
    PLA 
    BRA loc_008E97

  loc_008EA4:
    STA $WRDIVL           ; STA WRDIVL: distance (now single byte) as dividend
    LDA [$0A]             ; Read speed byte operand
    INC $0A
    AND #$00FF
    SEP #$20
    CMP #$80              ; Speed ≥ $80: treat as signed negative (negate for absolute value)
    BCC loc_008EB7
    EOR #$FF
    INC 

  loc_008EB7:
    STA $WRDIVB           ; STA WRDIVB: signed speed divisor for frame count
    REP #$20
    LDA [$0A]             ; Read frame delay byte operand
    INC $0A
    AND #$00FF
    XBA                   ; XBA: frame counter high byte from script operand
    STA $animScratch+2, X
    LDA $RDDIVL           ; RDDIVL: quotient = total frames for staged trajectory
    INC 
    ORA $animScratch2, X  ; Combine frame count with direction sign bits
    STA $animScratch2, X
    BCC loc_008ED9        ; Carry set from divide: need extra halving pass
    JSR $&HalveMovementDistance

  loc_008ED9:
    LDA #$0000            ; Zero accumulators, tick counter, and movement deltas
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

---------------------------------------------
; Iterative distance halver called by StageMove when the pixel distance high byte is non-zero.
; 
; Halves both moveXAlt and moveYAlt via LSR, then increments a halving-pass counter in chatPtr. StageMove calls this in a loop until the distance fits in a single byte, enabling the hardware divider to compute per-frame velocity accurately.

HalveMovementDistance {
    LDA $moveXAlt, X      ; LSR: halve remaining X distance
    LSR                   ; Halve remaining X distance each halving iteration
    STA $moveXAlt, X
    LDA $moveYAlt, X
    LSR                   ; Halve remaining Y distance each halving iteration
    STA $moveYAlt, X
    LDA $chatPtr, X       ; Increment halving-pass counter in chatPtr
    INC 
    STA $chatPtr, X
    RTS 
}

---------------------------------------------
; COP #53 with no operands. Per-frame companion to StageMove: MovementVelocityCompute uses hardware multiply/divide to advance position on both axes, waits on UpdateActorAnimation when needed, and yields RTL until the staged trajectory (and any halving passes) completes.

TickMove {
    TYX 

  TickMoveStep:
    LDA $animScratch2, X  ; Mask direction sign bits (14–15) for frame-count comparison against tick $24
    AND #$3FFF            ; Mask off sign bits (14–15) for pure frame count
    CMP $24               ; Compare against tick counter $24
    BNE loc_008F1C
    JMP $&TickMoveComplete ; Frame count reached: movement complete → TickMoveComplete

  loc_008F1C:
    SEP #$20
    LDA $24               ; STA WRMPYA: tick counter drives per-frame velocity scale
    STA $WRMPYA
    LDA $moveYAlt, X      ; Load Y distance for per-frame velocity
    JSR $&MovementVelocityCompute ; MovementVelocityCompute: hardware multiply/divide → Y velocity
    SBC $animScratch+1, X ; Subtract previous Y accumulator for this frame's delta
    BEQ loc_008F55
    PHA 
    LDA $animScratch2, X  ; Test Y direction sign (bit 15 via ASL)
    ASL 
    PLA 
    BCC loc_008F3D
    EOR #$FFFF            ; Y negative: negate velocity for southward movement
    INC 

  loc_008F3D:
    AND #$00FF
    BIT #$0080
    BEQ loc_008F48
    ORA #$FF00

  loc_008F48:
    STA $moveScratch2, X  ; Store signed Y velocity in moveScratch2
    SEP #$20
    LDA $0000
    STA $animScratch+1, X

  loc_008F55:
    SEP #$20
    LDA $moveXAlt, X      ; MovementVelocityCompute: same multiply/divide for X axis
    JSR $&MovementVelocityCompute ; MovementVelocityCompute: → X velocity
    SBC $animScratch, X   ; Subtract previous X accumulator
    BEQ loc_008F8A
    PHA 
    LDA $animScratch2, X
    ASL                   ; Test X direction sign (bit 14 via double ASL)
    ASL 
    PLA 
    BCC loc_008F72
    EOR #$FFFF            ; X negative: negate velocity for westward movement
    INC 

  loc_008F72:
    AND #$00FF
    BIT #$0080
    BEQ loc_008F7D
    ORA #$FF00

  loc_008F7D:
    STA $moveScratch1, X  ; Store signed X velocity in moveScratch1
    SEP #$20
    LDA $0000
    STA $animScratch, X

  loc_008F8A:
    SEP #$20
    LDA $animScratch+3, X ; Frame delay in animScratch+3 before next move step
    BMI loc_008F9C
    DEC                   ; Decrement delay counter; zero → pass complete
    BNE loc_008F98
    JMP $&TickMoveComplete ; Delay expired: jump to TickMoveComplete for pass check

  loc_008F98:
    STA $animScratch+3, X

  loc_008F9C:
    LDA $animScratch+2, X
    DEC                   ; Animation sub-frame counter
    BPL loc_008FAF
    REP #$20              ; Spin until UpdateActorAnimation completes (BCS loop)

  loc_008FA5:
    JSL $@sprite_composition.UpdateActorAnimation ; Spin UpdateActorAnimation until cycle finishes
    BCS loc_008FA5
    SEP #$20
    LDA $08

  loc_008FAF:
    STA $animScratch+2, X
    REP #$20
    STZ $08
    INC $24               ; Increment tick counter for next frame
    PLA                   ; Yield RTL until next tick
    PLA 
    RTL 
}

---------------------------------------------
; End-of-pass handler for TickMove. Checks chatPtr for remaining halving passes: if non-zero, decrements it, zeroes animScratch and tick counter $24, and jumps back to TickMoveStep for another interpolation pass at halved scale. When chatPtr reaches zero, saves the script PC to $00 and yields RTL to resume the calling script.

TickMoveComplete {
    REP #$20              ; Halving passes remain in chatPtr: decrement and re-enter at half scale
    LDA $chatPtr, X       ; Check chatPtr for remaining halving passes
    BEQ loc_008FD5        ; Zero → all passes done, save PC and yield
    DEC                   ; Decrement halving pass counter
    STA $chatPtr, X
    LDA #$0000            ; Reset accumulators and tick for next pass at halved scale
    STA $animScratch, X
    STA $24
    JMP $&TickMoveStep    ; Jump back to TickMoveStep for another interpolation pass

  loc_008FD5:
    LDA $0A               ; All passes complete: save resume PC
    STA $00
    PLA                   ; Yield RTL to return to calling script
    PLA 
    RTL 
}

---------------------------------------------
; Per-axis velocity calculator for TickMove.
; 
; Writes the axis distance byte to WRMPYB, reads the multiply product from RDMPYL into WRDIVL, divides by animScratch2−1 (frame count) via WRDIVB, waits 5 NOPs for divider latency, then returns the per-frame pixel step in A ($0000). Called twice per TickMove tick: once for Y axis, once for X axis.

MovementVelocityCompute {
    STA $WRMPYB           ; MovementVelocityCompute entry — WRMPYB then RDMPYL→WRDIV
    LDA $animScratch2, X  ; Load frame count from animScratch2 for divisor
    DEC                   ; DEC: frame count − 1 as divisor
    LDY $RDMPYL           ; RDMPYL → WRDIVL: multiply output feeds hardware divider
    STY $WRDIVL
    STA $WRDIVB           ; STA WRDIVB: start hardware divide
    NOP 
    NOP 
    NOP 
    NOP 
    NOP 
    REP #$20
    SEC 
    LDA $RDDIVL           ; RDDIVL: pixels-per-frame result after divide latency
    STA $0000             ; Store velocity result in $0000
    RTS 
}

---------------------------------------------
; COP #23 with no operands. Advances a 16-byte Galois LFSR chain at $040F–$041F and returns the latest output byte from $0410 in A.

RngByte {
    PHY 
    SEP #$20
    LDX #$000F            ; Init loop X=15 for 16-byte Galois LFSR state
    LDA #$00
    XBA 
    CLC 

  loc_009006:
    LDA $0410, X          ; 16-byte Galois LFSR step across $040F–$041F state
    ADC $rngState, X      ; ADC chain: propagate carry through $0410+X state bytes
    STA $rngState, X      ; ADC chain propagates carry through 16-byte RNG state
    DEX 
    BNE loc_009006
    LDX #$0010

  loc_009015:
    INC $rngState, X      ; Ripple increment: find first non-overflow byte
    BNE loc_00901D
    DEX 
    BNE loc_009015

  loc_00901D:
    REP #$20
    PLX 
    LDA $0A
    STA $02, S
    LDA $0410             ; Return RNG output byte from $0410
    AND #$00FF
    RTI 
}

---------------------------------------------
; COP #24 with one byte operand (modulus). Applies repeated subtraction modulo to the current RngByte output ($0410) and stores the result in rngModuloResult ($0420).

RngMod {
    TYX 
    LDA [$0A]             ; Read modulus byte operand
    INC $0A
    AND #$00FF
    STA $0000
    LDA $0410             ; Load current RNG output from $0410
    AND #$00FF

  loc_00903C:
    SEC                   ; Repeated subtraction loop: A -= modulus until negative
    SBC $0000
    BPL loc_00903C        ; Repeated subtract modulo — bias RNG byte to [0, operand)
    CLC 
    ADC $0000             ; Add modulus back for correct remainder
    STA $rngModuloResult  ; Store modulo result in rngModuloResult ($0420)
    LDA $0A
    STA $02, S
    RTI 
}
---------------------------------------------

; Internal JSR helper that converts an 8-bit actor list index in A to a WRAM actor pointer in Y. Computes Y = index × $30 + $1000 using SignedMultiply, matching the fixed $30-byte actor structure layout. Called by BranchIfActorNear and BranchIfActorAt before distance or coordinate comparisons.

ResolveActorIndex {
    SEP #$20
    XBA                   ; XBA: swap index byte to high position for SignedMultiply
    LDA #$30
    JSL $@hardware_math.SignedMultiply ; Multiply index × $30 (48 bytes per actor structure)
    REP #$20
    CLC 
    ADC #$1000            ; Add $1000 base → Y = WRAM actor table address
    TAY 
    RTS 
}

---------------------------------------------
; Reads the next scroll speed entry from the table at scrollStepTableBase, indexed by scrollStepIndex. Increments the index and doubles it for word access. Returns carry clear with the speed value in A when the entry high byte is non-zero (valid step); returns carry set and resets scrollStepIndex to zero when a zero high-byte terminator is reached. Called by all four CameraPan handlers (Down/Up/Right/Left) to fetch per-frame scroll step values.

CameraScrollStepLookup {
    PHP 
    PHX 
    LDA $scrollStepIndex  ; Read current scroll step table index
    INC $scrollStepIndex  ; Advance index for next call
    ASL                   ; ASL: ×2 for word-sized table entries
    CLC 
    ADC $scrollStepTableBase ; Add scrollStepTableBase for absolute entry address
    TAX 
    LDA $0000, X          ; Read speed value from scroll step table
    BIT #$FF00            ; High byte zero = end-of-table terminator
    BEQ loc_00B150
    PLX                   ; Valid entry: return carry clear with speed in A
    PLP 
    CLC 
    RTS 

  loc_00B150:
    STZ $scrollStepIndex  ; End of table: reset index to 0, return carry set
    PLX 
    PLP 
    SEC 
    RTS 
}