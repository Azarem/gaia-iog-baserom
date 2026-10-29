; Follow/chase movement engine: a small helper actor that steers its spawner toward a target actor (Bank $00; code at $E683 and $EDA8 plus a 544-byte slope table).
; 
; Usage: a script starts the helper with COP SpawnAfterMarked at InitFollowAndChase or CopySiblingFollowState, then stores the target actor ID in the new actor's $24 and may preset its animScratch2 (initial facing). The new actor's prev-link ($04) is the spawner, so each step moves both to the same position.
; 
; Fields (shared mnemonics, repurposed here): loopCounter ($7F0014) = speed in pixels per frame on the major axis; chatPtr ($7F000A) = base animation ID for the spawner's 16 facings (bit 15 set = leave the spawner's animation and OAM mirror bits alone); animScratch2 ($7F000E) = current facing frame 0-15, clockwise from north ($FFFF = not set yet); orbitAngle ($7F0010) = slope row 0-16 (0 = 45 degrees, 16 = axis-aligned); orbitDiameter ($7F0012) = dither phase 0-15; moveScratch1/2 ($7F002C/2E) = last X/Y step, read back by mu5F_flasher and sEA_solid_arm.
; 
; Each aim, FollowChaseMainLoop computes dx = target.X − X and dy = target.Y − 8 − Y, takes absolute values and picks one of 8 octant handlers from the signs and the larger axis (the handler labels name the heading each one produces: ESE, SSE, SSW, WSW, WNW, NNW, NNE, ENE). The handler computes the slope row (ComputeFollowAngle when |dy| dominates, ComputeFollowAngleAlt when |dx| dominates), turns the facing one frame toward the desired one (ResolveFacingFromAxisBase/Alt) and, once aligned, takes a step with ComputeFollowStep: the major axis moves loopCounter pixels and the minor axis moves by the number of 1s in a window of a FollowSlopeDitherTable row (a Bresenham-style dither table, not a sine table).
; 
; ApplyFollowMovement adds the step to follower and spawner. The handlers save a resume point with SetEntryHere, so the direction is recomputed (JumpNextFrame to FollowChaseMainLoop) only once the dither phase reaches 8 or more. While the facing is still turning, the actor keeps moving along its current facing (the FollowDirHandler sets the heading and slope; SelectFallbackDirection dispatches it). smooth_follow_child also calls ComputeFollowAngle, ComputeFollowAngleAlt and ComputeFollowStep directly.
; 
; Spawned by: InitFollowAndChase from aw_spirit_follower, sg4D_knight_armor, pyDD_queen_spirit_attack, dm_follower_behavior (and an unused initializer); CopySiblingFollowState from mu5F_flasher, sE8_dark_gaia, sEA_solid_arm.
---------------------------------------------

?BANK 00

?INCLUDE 'hardware_math'
?INCLUDE 'sprite_composition'

!chatPtr                        7F000A
!animScratch2                   7F000E
!orbitAngle                     7F0010
!orbitDiameter                  7F0012
!loopCounter                    7F0014
!moveScratch1                   7F002C
!moveScratch2                   7F002E

---------------------------------------------

; Entry for helpers whose spawner has already set the follow parameters.
; 
; Copies loopCounter (speed) and chatPtr (animation base) from the prev-link actor ($0004,Y — the spawner, because SpawnAfterMarked inserts the new actor right after it) into this actor, then enters FollowChaseMainLoop. Unlike InitFollowAndChase it leaves animScratch2 alone, so the spawner can preset the initial facing (mu5F_flasher stores $26 there before the helper first runs).

CopySiblingFollowState {
    TXY                   ; Y = this actor
    LDX $0004, Y          ; X = spawner (prev-link $04, set when SpawnAfterMarked inserted this actor after it)
    LDA $loopCounter, X   ; Spawner's loopCounter (speed in pixels per frame) to scratch $0000
    STA $0000
    LDA $chatPtr, X       ; Spawner's chatPtr (animation base ID; bit 15 = leave animation alone) to scratch $0002
    STA $0002
    TYX 
    LDA $0000
    STA $loopCounter, X   ; This actor's loopCounter = spawner's
    LDA $0002
    STA $chatPtr, X       ; This actor's chatPtr = spawner's
    BRA FollowChaseMainLoop
}

---------------------------------------------
; Entry for helpers that start with no facing.
; 
; Same copy of loopCounter and chatPtr from the spawner as CopySiblingFollowState, then sets animScratch2 = $FFFF (facing not set) so the first ResolveFacingFromAxisBase snaps straight to the desired frame, and runs into FollowChaseMainLoop. The block also contains the two up-right handlers (the FollowChaseHeadNNE/NW and FollowChaseApplyNNE/ENE sub-labels): target up-right and Y dominant heads mostly north (facing base 0, X += minor, Y −= major), target up-right and X dominant heads mostly east (base 2, X += major, Y −= minor).

InitFollowAndChase {
    TXY                   ; Same copy as CopySiblingFollowState (Y = this actor, X = spawner below)
    LDX $0004, Y
    LDA $loopCounter, X
    STA $0000
    LDA $chatPtr, X
    STA $0002
    TYX 
    LDA $0000
    STA $loopCounter, X
    LDA $0002
    STA $chatPtr, X
    LDA #$FFFF            ; animScratch2 = $FFFF: facing not set yet, so the first ResolveFacingFromAxisBase snaps to the desired frame
    STA $animScratch2, X

  FollowChaseMainLoop:
    LDY $24               ; FollowChaseMainLoop: Y = target actor ($24)
    LDA $0014, Y          ; dx = target.X − X
    SEC 
    SBC $14               ; Subtract own X from target X
    BMI FollowChaseDxNegative ; dx < 0: target is to the left
    STA $0018             ; $0018 = |dx| (dx ≥ 0: target is to the right)
    LDA $0016, Y          ; dy = target.Y − 8 − Y: aim 8px above the target's origin (inferred: its sprite centre)
    SEC 
    SBC #$0008            ; Aim 8px above the target's origin
    SEC 
    SBC $16
    BMI FollowChaseDyNegativePrimary
    STA $001C             ; $001C = |dy| (dy ≥ 0: target is below)
    CMP $0018             ; Compare |dy| with |dx| to find the dominant axis
    BCC FollowChaseDominantXGreater ; |dy| < |dx|: X dominates → FollowChaseHeadESE (target down-right; heads mostly east)
    JMP $&FollowChaseHeadSSE ; |dy| ≥ |dx|: Y dominates → FollowChaseHeadSSE (target down-right; heads mostly south)

  FollowChaseDominantXGreater:
    JMP $&FollowChaseHeadESE ; Target down-right, X dominant: see FollowChaseHeadESE

  FollowChaseDyNegativePrimary:
    EOR #$FFFF            ; dy < 0 (target above): |dy| = −dy (EOR #$FFFF + INC = two’s complement)
    INC 
    STA $001C
    CMP $0018
    BCS FollowChaseHeadNNE ; |dy| ≥ |dx|: Y dominant, target up-right → north-leaning heading
    BRA FollowChaseHeadENE

  FollowChaseDxNegative:
    EOR #$FFFF            ; dx < 0: |dx| = −dx
    INC 
    STA $0018
    LDA $0016, Y
    SEC 
    SBC #$0008
    SEC 
    SBC $16
    BMI FollowChaseDyNegativeSecondary ; dy < 0: target up-left
    STA $001C
    CMP $0018
    BCC FollowChaseDominantXGreaterAlt ; |dy| < |dx|: target down-left, X dominant → FollowChaseHeadWSW (heads mostly west)
    JMP $&FollowChaseHeadSSW ; |dy| ≥ |dx|: target down-left, Y dominant → FollowChaseHeadSSW (heads mostly south)

  FollowChaseDominantXGreaterAlt:
    JMP $&FollowChaseHeadWSW

  FollowChaseDyNegativeSecondary:
    EOR #$FFFF
    INC 
    STA $001C
    CMP $0018
    BCC FollowChaseDominantXGreaterUpLeft ; |dy| < |dx|: target up-left, X dominant → FollowChaseHeadWNW (heads mostly west)
    JMP $&FollowChaseHeadNNW ; |dy| ≥ |dx|: target up-left, Y dominant → FollowChaseHeadNNW (heads mostly north)

  FollowChaseDominantXGreaterUpLeft:
    JMP $&FollowChaseHeadWNW

  FollowChaseHeadNNE:
    JSR $&ComputeFollowAngle ; Target up-right, Y dominant: slope row = |dx| / (|dy| / 16), folded
    LDA #$0000            ; Facing base 0 = N (frames 0-2: N, NNE, NE)
    STA $0000
    JSR $&ResolveFacingFromAxisBase ; Turn the facing one frame toward base + offset; $0000 = $FFFF once aligned
    LDA $0000
    BMI FollowChaseApplyNNE ; $0000 < 0: facing aligned, move along the computed slope
    JMP $&SelectFallbackDirection ; Still turning: keep moving along the current facing (heading in $0000)

  FollowChaseApplyNNE:
    COP [SetEntryHere]
    JSR $&ComputeFollowStep ; $0000 = major step (loopCounter px), $0002 = minor step (dither table)
    LDA $0000             ; Major step, negated: becomes the Y delta (north)
    EOR #$FFFF
    INC 
    TAY 
    LDA $0002             ; X delta = minor step, Y delta = −major step
    STA $0000
    STY $0002
    JMP $&ApplyFollowMovement

  FollowChaseHeadENE:
    JSR $&ComputeFollowAngleAlt
    LDA #$0002
    STA $0000
    JSR $&ResolveFacingFromDiagonalBase
    LDA $0000
    BMI FollowChaseApplyENE
    JMP $&SelectFallbackDirection

  FollowChaseApplyENE:
    COP [SetEntryHere]
    JSR $&ComputeFollowStep
    LDA $0002
    EOR #$FFFF
    INC 
    STA $0002
    JMP $&ApplyFollowMovement
}

---------------------------------------------
; Octant handler: target down-right, |dx| > |dy|. The actor heads mostly EAST.
; 
; Slope row from ComputeFollowAngleAlt, facing base 4 (E, ESE, SE) via ResolveFacingFromAxisBase, step X += major, Y += minor. If the facing is still turning ($0000 not negative) the actor continues along its current facing through SelectFallbackDirection instead. (The eight FollowChaseHead* handlers are named for the heading they produce: ESE, SSE, SSW, WSW, WNW, NNW, NNE, ENE.)

FollowChaseHeadESE {
    JSR $&ComputeFollowAngleAlt
    LDA #$0004            ; Facing base 4 = E (frames 4-6: E, ESE, SE)
    STA $0000
    JSR $&ResolveFacingFromAxisBase
    LDA $0000
    BMI FollowChaseApplyESE
    JMP $&SelectFallbackDirection

  FollowChaseApplyESE:
    COP [SetEntryHere]
    JSR $&ComputeFollowStep
    JMP $&ApplyFollowMovement
}

---------------------------------------------
; Octant handler: target down-right, |dy| ≥ |dx|. The actor heads mostly SOUTH.
; 
; ComputeFollowAngle, facing base 6 (SE, SSE, S) via ResolveFacingFromDiagonalBase, step swapped: X += minor, Y += major.

FollowChaseHeadSSE {
    JSR $&ComputeFollowAngle
    LDA #$0006            ; Facing base 6 = SE (frames 6-8: SE, SSE, S)
    STA $0000
    JSR $&ResolveFacingFromDiagonalBase
    LDA $0000
    BMI FollowChaseApplySSE
    JMP $&SelectFallbackDirection

  FollowChaseApplySSE:
    COP [SetEntryHere]
    JSR $&ComputeFollowStep
    LDA $0000
    TAY 
    LDA $0002
    STA $0000
    STY $0002
    JMP $&ApplyFollowMovement
}

---------------------------------------------
; Octant handler: target down-left, |dy| ≥ |dx|. The actor heads mostly SOUTH.
; 
; ComputeFollowAngle, facing base 8 (S, SSW, SW) via ResolveFacingFromAxisBase, step X −= minor, Y += major.

FollowChaseHeadSSW {
    JSR $&ComputeFollowAngle
    LDA #$0008            ; Facing base 8 = S (frames 8-10: S, SSW, SW)
    STA $0000
    JSR $&ResolveFacingFromAxisBase
    LDA $0000
    BMI FollowChaseApplySSW
    JMP $&SelectFallbackDirection

  FollowChaseApplySSW:
    COP [SetEntryHere]
    JSR $&ComputeFollowStep
    LDA $0002
    EOR #$FFFF            ; Minor step negated: X delta = −minor (west)
    INC 
    TAY 
    LDA $0000
    STA $0002             ; Y delta = major step (south), X delta = −minor
    STY $0000
    JMP $&ApplyFollowMovement
}

---------------------------------------------
; Octant handler: target down-left, |dx| > |dy|. The actor heads mostly WEST.
; 
; ComputeFollowAngleAlt, facing base $A (SW, WSW, W) via ResolveFacingFromDiagonalBase, step X −= major, Y += minor.

FollowChaseHeadWSW {
    JSR $&ComputeFollowAngleAlt
    LDA #$000A            ; Facing base $A = SW (frames 10-12: SW, WSW, W)
    STA $0000
    JSR $&ResolveFacingFromDiagonalBase
    LDA $0000
    BMI FollowChaseApplyWSW
    JMP $&SelectFallbackDirection

  FollowChaseApplyWSW:
    COP [SetEntryHere]
    JSR $&ComputeFollowStep
    LDA $0000
    EOR #$FFFF            ; X delta = −major (west); Y delta = +minor (south)
    INC 
    STA $0000
    JMP $&ApplyFollowMovement
}

---------------------------------------------
; Octant handler: target up-left, |dx| > |dy|. The actor heads mostly WEST.
; 
; ComputeFollowAngleAlt, facing base $C (W, WNW, NW) via ResolveFacingFromAxisBase, step X −= major, Y −= minor.

FollowChaseHeadWNW {
    JSR $&ComputeFollowAngleAlt
    LDA #$000C            ; Facing base $C = W (frames 12-14: W, WNW, NW)
    STA $0000
    JSR $&ResolveFacingFromAxisBase
    LDA $0000
    BMI FollowChaseApplyWNW
    JMP $&SelectFallbackDirection

  FollowChaseApplyWNW:
    COP [SetEntryHere]
    JSR $&ComputeFollowStep
    LDA $0000
    EOR #$FFFF            ; X delta = −major (west)
    INC 
    STA $0000
    LDA $0002
    EOR #$FFFF
    INC 
    STA $0002
    BRA ApplyFollowMovement
}

---------------------------------------------
; Octant handler: target up-left, |dy| ≥ |dx|. The actor heads mostly NORTH.
; 
; ComputeFollowAngle, facing base $E (NW, NNW, N) via ResolveFacingFromDiagonalBase, step X −= minor, Y −= major. Its apply half runs straight on into ApplyFollowMovement.

FollowChaseHeadNNW {
    JSR $&ComputeFollowAngle
    LDA #$000E            ; Facing base $E = NW (frames 14-0: NW, NNW, N)
    STA $0000
    JSR $&ResolveFacingFromDiagonalBase
    LDA $0000
    BMI FollowChaseApplyNNW
    JMP $&SelectFallbackDirection

  FollowChaseApplyNNW:
    COP [SetEntryHere]
    JSR $&ComputeFollowStep
    LDA $0000
    EOR #$FFFF            ; Negate both steps and swap: X delta = −minor (west), Y delta = −major (north)
    INC 
    TAY 
    LDA $0002
    EOR #$FFFF
    INC 
    STA $0000
    STY $0002
}

---------------------------------------------
; Adds the step in $0000 (X) and $0002 (Y) to this actor's position ($14/$16) and copies the new position to the prev-link actor (the spawner), so the spawner moves with the helper. The step is also stored in moveScratch1/2, which the spawner scripts read back.
; 
; If the dither phase in orbitDiameter is 8 or more, it is cleared and the helper re-aims next frame (JumpNextFrame to FollowChaseMainLoop). Otherwise RTL ends the frame and the actor resumes at the SetEntryHere inside its handler, repeating the same heading with the next dither window.

ApplyFollowMovement {
    LDY $04               ; ApplyFollowMovement: Y = prev-link actor (the spawner), moved together with this actor
    LDA $14               ; X += $0000 (X step)
    CLC 
    ADC $0000
    STA $14
    STA $0014, Y          ; Spawner.X = new X
    LDA $0000
    STA $moveScratch1, X  ; Last X step (read back by the spawner scripts, e.g. mu5F_flasher via its next-link)
    LDA $16
    CLC 
    ADC $0002             ; Y += $0002 (Y step)
    STA $16
    STA $0016, Y          ; Spawner.Y = new Y
    LDA $0002
    STA $moveScratch2, X  ; Last Y step
    LDA $orbitDiameter, X ; orbitDiameter = dither phase (0-15) left by ComputeFollowStep
    CMP #$0008            ; Phase ≥ 8: re-aim; otherwise RTL and resume at the handler’s SetEntryHere next frame
    BPL FollowChaseRequeueLoop
    RTL 

  FollowChaseRequeueLoop:
    LDA #$0000            ; Clear the phase and re-aim next frame (JumpNextFrame to FollowChaseMainLoop)
    STA $orbitDiameter, X
    COP [JumpNextFrame] ( @FollowChaseMainLoop )
}

---------------------------------------------
; Entered while the facing is still turning ($0000 not yet $FFFF). A = heading 1-8 stored in $0000 by the FollowDirHandler; (A − 1) & 7 indexes follow_fallback_table, whose entries are the apply halves of the eight octant handlers (headings N, NE, E, SE, S, SW, W, NW), so the actor keeps moving along its current facing with the slope row the handler set.

SelectFallbackDirection {
    DEC                   ; A = heading 1-8 set by a FollowDirHandler; (A−1) & 7 = table index
    AND #$0007
    STA $0004             ; Scratch $0004 is the SwitchCase variable
    COP [SwitchCase] ( #$0004, &follow_fallback_table ) ; Jump to the apply half of the handler for that heading
}

---------------------------------------------
; Apply halves (the code after each COP SetEntryHere) of the eight octant handlers, indexed by heading − 1: N, NE, E, SE, S, SW, W, NW.

follow_fallback_table [
  &FollowChaseApplyNNE   ;00
  &FollowChaseApplyENE   ;01
  &FollowChaseApplyESE   ;02
  &FollowChaseApplySSE   ;03
  &FollowChaseApplySSW   ;04
  &FollowChaseApplyWSW   ;05
  &FollowChaseApplyWNW   ;06
  &FollowChaseApplyNNW   ;07
]
---------------------------------------------

; Slope row for a Y-dominant aim (|dy| ≥ |dx|), stored in orbitAngle (0 = 45 degrees … 16 = axis-aligned).
; 
; Inputs: $0018 = |dx|, $001C = |dy| (set by FollowChaseMainLoop or smooth_follow_child). Equal deltas give row 0. Otherwise q = |dx| / (|dy| >> 4) ≈ 16·|dx|/|dy| using the hardware divide (UnsignedDivide, Y = dividend, A = divisor; a |dy| below 16 uses divisor 1), folded into a row: q ≥ $18 → 32 − q, $11-$17 → q − 16, ≤ $10 → 16 − q. Clears orbitDiameter (dither phase) and returns with RTS.

ComputeFollowAngle {
    LDA $0018
    CMP $001C
    BNE ComputeFollowAngleDivide
    LDA #$0000
    BRA ComputeFollowAngleStore

  ComputeFollowAngleDivide:
    LDY $0018
    LDA $001C
    LSR 
    LSR 
    LSR 
    LSR 
    BNE ComputeFollowAngleAltDoDivide
    BRA ComputeFollowAngleAltIncY
}

---------------------------------------------
; Same as ComputeFollowAngle with the axes swapped, for an X-dominant aim (|dx| > |dy|): q = |dy| / (|dx| >> 4). The shared tail (divide, fold, store) is in the sub-labels of this block.

ComputeFollowAngleAlt {
    LDA $001C
    CMP $0018
    BNE ComputeFollowAngleAltDivide
    LDA #$0000
    BRA ComputeFollowAngleStore

  ComputeFollowAngleAltDivide:
    LDY $001C
    LDA $0018
    LSR 
    LSR 
    LSR 
    LSR 
    BNE ComputeFollowAngleAltDoDivide

  ComputeFollowAngleAltIncY:
    INC 

  ComputeFollowAngleAltDoDivide:
    SEP #$20
    JSL $@hardware_math.UnsignedDivide
    REP #$20
    AND #$00FF
    CMP #$0018
    BPL ComputeFollowAngleAltReflectHigh
    CMP #$0011
    BPL ComputeFollowAngleAltSubtractMid
    BRA ComputeFollowAngleAltReflectLow

  ComputeFollowAngleAltReflectHigh:
    SEC 
    SBC #$0010
    EOR #$FFFF
    INC 
    CLC 
    ADC #$0010
    BRA ComputeFollowAngleStore

  ComputeFollowAngleAltSubtractMid:
    SEC 
    SBC #$0010
    BRA ComputeFollowAngleStore

  ComputeFollowAngleAltReflectLow:
    EOR #$FFFF
    INC 
    CLC 
    ADC #$0010

  ComputeFollowAngleStore:
    STA $orbitAngle, X
    LDA #$0000
    STA $orbitDiameter, X
    RTS 
}

---------------------------------------------
; Produces this frame's step: $0000 = loopCounter (major-axis pixels) and $0002 = minor-axis pixels = the sum of the next loopCounter words (each 0 or 1) of FollowSlopeDitherTable row orbitAngle, starting at column orbitDiameter and wrapping at 16. The new phase (old + loopCounter) & 15 is stored back in orbitDiameter. Scratch: $0004 column counter, $0006/$0008 start and end phase. Also called directly by smooth_follow_child.

ComputeFollowStep {
    LDA $orbitAngle, X    ; ComputeFollowStep: Y = slope row offset = orbitAngle × 32 bytes (16 words)
    ASL 
    ASL 
    ASL 
    ASL 
    ASL 
    TAY 
    LDA $orbitDiameter, X
    STA $0004
    ASL 
    STA $0006
    TYA 
    CLC 
    ADC $0006
    TAY 
    LDA $loopCounter, X
    STA $0000
    CLC 
    ADC $0004
    AND #$000F
    STA $0008
    STA $orbitDiameter, X
    PHX 
    TYX 
    STZ $0002

  ComputeFollowStepAccumLoop:
    LDA $@FollowSlopeDitherTable, X
    CLC 
    ADC $0002
    STA $0002
    INX 
    INX 
    INC $0004
    LDA $0004
    BIT #$FFF0
    BEQ ComputeFollowStepTableWrap
    TXA 
    SEC 
    SBC #$0020
    TAX 
    LDA #$0000
    STA $0004

  ComputeFollowStepTableWrap:
    CMP $0008
    BNE ComputeFollowStepAccumLoop
    PLX 
    RTS 
}

---------------------------------------------
; Picks the desired facing frame and turns toward it. Desired = ($0000 base + offset) & 15, where the offset comes from the slope row in orbitAngle: row ≥ $0D → 0, $05-$0C → 1, < 5 → 2; ResolveFacingFromDiagonalBase (next block) swaps offsets 0 and 2.
; 
; The shared tail (sub-labels in the Alt block) then compares it with animScratch2 (the current facing, 16 frames clockwise from north): $FFFF (unset) or within one frame snaps to the desired frame and sets $0000 = $FFFF (aligned); otherwise the facing moves one frame the short way round (a half-turn counts as counter-clockwise). Unless chatPtr bit 15 is set, the spawner's animation becomes chatPtr + facing ($28, frame counter $2A = 0) and UpdateActorAnimation is run for it. Finally it jumps through FollowDirectionTable to the FollowDirHandler for the new facing, with carry = chatPtr bit 15.

ResolveFacingFromAxisBase {
    LDA $orbitAngle, X    ; ResolveFacingFromAxisBase: slope row ≥ $0D → offset 0, $05-$0C → 1, < 5 → 2 (the Alt entry swaps 0 and 2)
    CMP #$000D
    BPL ResolveFacingOffset0
    CMP #$0005
    BPL ResolveFacingOffset1
    BRA ResolveFacingOffset2
}

---------------------------------------------
; Alt entry of ResolveFacingFromAxisBase with offsets 0 and 2 swapped (row ≥ $0D → 2, < 5 → 0). The normal entry is used by the handlers whose base frame is an axis frame (N, E, S, W: axis-aligned row = base), the Alt entry by those whose base is a diagonal frame (NE, SE, SW, NW: axis-aligned row = base + 2). The labels ResolveFacingOffset0/Diagonal/MoveYOnly describe the normal entry only.

ResolveFacingFromDiagonalBase {
    LDA $orbitAngle, X
    CMP #$000D
    BPL ResolveFacingOffset2
    CMP #$0005
    BPL ResolveFacingOffset1

  ResolveFacingOffset0:
    LDA #$0000
    STA $0002
    BRA ResolveFacingCompare

  ResolveFacingOffset1:
    LDA #$0001
    STA $0002
    BRA ResolveFacingCompare

  ResolveFacingOffset2:
    LDA #$0002
    STA $0002

  ResolveFacingCompare:
    LDA $0000
    CLC 
    ADC $0002
    AND #$000F
    STA $0004
    LDA $chatPtr, X       ; Dead load: overwritten by the next LDA
    LDA $animScratch2, X  ; Current facing frame (−1 = not set)
    BMI ResolveFacingSnapToDesired
    SEC 
    SBC $0004
    BMI ResolveFacingCompareNegative
    BEQ ResolveFacingSnapToDesired
    CMP #$0001
    BEQ ResolveFacingSnapToDesired
    CMP #$000F
    BEQ ResolveFacingSnapToDesired
    CMP #$0009
    BPL ResolveFacingStepClockwise
    BRA ResolveFacingStepCounterclockwise

  ResolveFacingCompareNegative:
    CMP #$FFFF
    BEQ ResolveFacingSnapToDesired
    CMP #$FFF1
    BEQ ResolveFacingSnapToDesired
    CMP #$FFF9
    BPL ResolveFacingStepClockwise
    BRA ResolveFacingStepCounterclockwise

  ResolveFacingStepCounterclockwise:
    LDA $animScratch2, X
    DEC 
    STA $animScratch2, X
    STA $0004
    BPL ResolveFacingSetSpawnerAnim
    LDA #$000F
    STA $animScratch2, X
    STA $0004
    BRA ResolveFacingSetSpawnerAnim

  ResolveFacingStepClockwise:
    LDA $animScratch2, X
    INC 
    AND #$000F
    STA $animScratch2, X
    STA $0004
    BRA ResolveFacingSetSpawnerAnim

  ResolveFacingSnapToDesired:
    LDA $0004
    STA $animScratch2, X
    LDA #$FFFF
    STA $0000

  ResolveFacingSetSpawnerAnim:
    LDA $0004, X          ; ResolveFacingSetSpawnerAnim: Y = prev-link actor (the spawner)
    TAY 
    LDA $chatPtr, X
    BMI ResolveFacingRefreshSpawnerSprite
    CLC 
    ADC $0004
    STA $0028, Y          ; Spawner animation = chatPtr + facing frame
    LDA #$0000
    STA $002A, Y          ; Restart the spawner animation frame counter

  ResolveFacingRefreshSpawnerSprite:
    LDA $chatPtr, X
    BMI ResolveFacingDispatch
    PHX 
    TYX 
    TYA 
    TCD 
    JSL $@sprite_composition.UpdateActorAnimation ; Rebuild the spawner’s sprite data for the new animation (D = X = spawner)
    PLA 
    TXY 
    TAX 
    TCD 

  ResolveFacingDispatch:
    LDA $chatPtr, X
    STA $0006
    LDA $animScratch2, X
    AND #$000F
    PHX 
    ASL 
    TAX 
    CLC 
    LDA $0006
    BPL ResolveFacingLoadHandler
    SEC 

  ResolveFacingLoadHandler:
    LDA $@FollowDirectionTable, X
    DEC 
    PLX 
    PHA 
    RTS                   ; Computed jump: push handler−1 and RTS into FollowDirHandlerNN for the new facing; carry = chatPtr bit 15
}

---------------------------------------------
; One handler per facing frame (animScratch2 & 15), clockwise from north: N, NNE, NE, ENE, E, ESE, SE, SSE, S, SSW, SW, WSW, W, WNW, NW, NNW. ResolveFacingFromAxisBase pushes the entry minus one and RTSes into it.

FollowDirectionTable [
  &FollowDirHandler00   ;00
  &FollowDirHandler01   ;01
  &FollowDirHandler02   ;02
  &FollowDirHandler03   ;03
  &FollowDirHandler04   ;04
  &FollowDirHandler05   ;05
  &FollowDirHandler06   ;06
  &FollowDirHandler07   ;07
  &FollowDirHandler08   ;08
  &FollowDirHandler09   ;09
  &FollowDirHandler0A   ;0A
  &FollowDirHandler0B   ;0B
  &FollowDirHandler0C   ;0C
  &FollowDirHandler0D   ;0D
  &FollowDirHandler0E   ;0E
  &FollowDirHandler0F   ;0F
]

---------------------------------------------
; Facing N (frame 0): clears the spawner’s OAM mirror bits (skipped when carry = chatPtr bit 15). While the facing is still turning it sets heading 1 and slope row $10 (axis-aligned), so SelectFallbackDirection keeps the actor moving N. Handlers 00-0F differ only in these constants.

FollowDirHandler00 {
    BCS FollowDir00ClearHFlip
    LDA $000E, Y          ; Clear both OAM mirror bits in the spawner's attribute word $0E
    AND #$3FFF
    STA $000E, Y

  FollowDir00ClearHFlip:
    LDA $0000             ; $0000 < 0 = facing aligned: keep the computed slope
    BMI FollowDir00SetFacing
    LDA #$0001            ; Still turning: heading 1 (north)
    STA $0000
    LDA #$0010            ; Slope row $10 = axis-aligned (no minor-axis steps)
    STA $orbitAngle, X

  FollowDir00SetFacing:
    RTS 
}

---------------------------------------------
; Facing NNE (frame 1): clears the spawner’s OAM mirror bits (skipped when carry = chatPtr bit 15). While the facing is still turning it sets heading 1 and slope row $08 (half slope), so SelectFallbackDirection keeps the actor moving NNE.

FollowDirHandler01 {
    BCS FollowDir01ClearHFlip
    LDA $000E, Y
    AND #$3FFF
    STA $000E, Y

  FollowDir01ClearHFlip:
    LDA $0000
    BMI FollowDir01SetFacing
    LDA #$0001
    STA $0000
    LDA #$0008
    STA $orbitAngle, X

  FollowDir01SetFacing:
    RTS 
}

---------------------------------------------
; Facing NE (frame 2): clears the spawner’s OAM mirror bits (skipped when carry = chatPtr bit 15). While the facing is still turning it sets heading 2 and slope row $00 (45 degrees), so SelectFallbackDirection keeps the actor moving NE.

FollowDirHandler02 {
    BCS FollowDir02ClearHFlip
    LDA $000E, Y
    AND #$3FFF
    STA $000E, Y

  FollowDir02ClearHFlip:
    LDA $0000
    BMI FollowDir02SetFacing
    LDA #$0002
    STA $0000
    LDA #$0000
    STA $orbitAngle, X

  FollowDir02SetFacing:
    RTS 
}

---------------------------------------------
; Facing ENE (frame 3): clears the spawner’s OAM mirror bits (skipped when carry = chatPtr bit 15). While the facing is still turning it sets heading 2 and slope row $08 (half slope), so SelectFallbackDirection keeps the actor moving ENE.

FollowDirHandler03 {
    BCS FollowDir03ClearHFlip
    LDA $000E, Y
    AND #$3FFF
    STA $000E, Y

  FollowDir03ClearHFlip:
    LDA $0000
    BMI FollowDir03SetFacing
    LDA #$0002
    STA $0000
    LDA #$0008
    STA $orbitAngle, X

  FollowDir03SetFacing:
    RTS 
}

---------------------------------------------
; Facing E (frame 4): clears the spawner’s OAM mirror bits (skipped when carry = chatPtr bit 15). While the facing is still turning it sets heading 3 and slope row $10 (axis-aligned), so SelectFallbackDirection keeps the actor moving E.

FollowDirHandler04 {
    BCS FollowDir04ClearHFlip
    LDA $000E, Y
    AND #$3FFF
    STA $000E, Y

  FollowDir04ClearHFlip:
    LDA $0000
    BMI FollowDir04SetFacing
    LDA #$0003
    STA $0000
    LDA #$0010            ; Heading 3 (east), slope row $10
    STA $orbitAngle, X

  FollowDir04SetFacing:
    RTS 
}

---------------------------------------------
; Facing ESE (frame 5): sets V-mirror ($8000) on the spawner (skipped when carry = chatPtr bit 15). While the facing is still turning it sets heading 3 and slope row $08 (half slope), so SelectFallbackDirection keeps the actor moving ESE.

FollowDirHandler05 {
    BCS FollowDir05SetVFlip
    LDA $000E, Y
    AND #$3FFF            ; Clear both OAM mirror bits
    ORA #$8000
    STA $000E, Y

  FollowDir05SetVFlip:
    LDA $0000
    BMI FollowDir05SetFacing
    LDA #$0003
    STA $0000
    LDA #$0008
    STA $orbitAngle, X    ; Slope row 8 (half slope)

  FollowDir05SetFacing:
    RTS 
}

---------------------------------------------
; Facing SE (frame 6): sets V-mirror ($8000) on the spawner (skipped when carry = chatPtr bit 15). While the facing is still turning it sets heading 4 and slope row $00 (45 degrees), so SelectFallbackDirection keeps the actor moving SE.

FollowDirHandler06 {
    BCS FollowDir06SetVFlip
    LDA $000E, Y
    AND #$3FFF
    ORA #$8000
    STA $000E, Y

  FollowDir06SetVFlip:
    LDA $0000
    BMI FollowDir06SetFacing
    LDA #$0004
    STA $0000
    LDA #$0000
    STA $orbitAngle, X

  FollowDir06SetFacing:
    RTS 
}

---------------------------------------------
; Facing SSE (frame 7): sets V-mirror ($8000) on the spawner (skipped when carry = chatPtr bit 15). While the facing is still turning it sets heading 4 and slope row $08 (half slope), so SelectFallbackDirection keeps the actor moving SSE.

FollowDirHandler07 {
    BCS FollowDir07SetVFlip
    LDA $000E, Y
    AND #$3FFF
    ORA #$8000
    STA $000E, Y

  FollowDir07SetVFlip:
    LDA $0000
    BMI FollowDir07SetFacing
    LDA #$0004
    STA $0000
    LDA #$0008
    STA $orbitAngle, X

  FollowDir07SetFacing:
    RTS 
}

---------------------------------------------
; Facing S (frame 8): sets V-mirror ($8000) on the spawner (skipped when carry = chatPtr bit 15). While the facing is still turning it sets heading 5 and slope row $10 (axis-aligned), so SelectFallbackDirection keeps the actor moving S.

FollowDirHandler08 {
    BCS FollowDir08SetVFlip
    LDA $000E, Y
    AND #$3FFF
    ORA #$8000
    STA $000E, Y

  FollowDir08SetVFlip:
    LDA $0000
    BMI FollowDir08SetFacing
    LDA #$0005
    STA $0000
    LDA #$0010
    STA $orbitAngle, X

  FollowDir08SetFacing:
    RTS 
}

---------------------------------------------
; Facing SSW (frame 9): sets H+V mirror ($C000) on the spawner (skipped when carry = chatPtr bit 15). While the facing is still turning it sets heading 5 and slope row $08 (half slope), so SelectFallbackDirection keeps the actor moving SSW.

FollowDirHandler09 {
    BCS FollowDir09SetHVFlip
    LDA $000E, Y
    AND #$3FFF
    ORA #$C000
    STA $000E, Y

  FollowDir09SetHVFlip:
    LDA $0000
    BMI FollowDir09SetFacing
    LDA #$0005
    STA $0000
    LDA #$0008
    STA $orbitAngle, X

  FollowDir09SetFacing:
    RTS 
}

---------------------------------------------
; Facing SW (frame 10): sets H+V mirror ($C000) on the spawner (skipped when carry = chatPtr bit 15). While the facing is still turning it sets heading 6 and slope row $00 (45 degrees), so SelectFallbackDirection keeps the actor moving SW.

FollowDirHandler0A {
    BCS FollowDir0ASetHVFlip
    LDA $000E, Y
    AND #$3FFF
    ORA #$C000
    STA $000E, Y

  FollowDir0ASetHVFlip:
    LDA $0000
    BMI FollowDir0ASetFacing
    LDA #$0006
    STA $0000
    LDA #$0000
    STA $orbitAngle, X

  FollowDir0ASetFacing:
    RTS 
}

---------------------------------------------
; Facing WSW (frame 11): sets H+V mirror ($C000) on the spawner (skipped when carry = chatPtr bit 15). While the facing is still turning it sets heading 6 and slope row $08 (half slope), so SelectFallbackDirection keeps the actor moving WSW.

FollowDirHandler0B {
    BCS FollowDir0BSetHVFlip
    LDA $000E, Y
    AND #$3FFF
    ORA #$C000
    STA $000E, Y

  FollowDir0BSetHVFlip:
    LDA $0000
    BMI FollowDir0BSetFacing
    LDA #$0006
    STA $0000
    LDA #$0008
    STA $orbitAngle, X

  FollowDir0BSetFacing:
    RTS 
}

---------------------------------------------
; Facing W (frame 12): sets H-mirror ($4000) on the spawner (skipped when carry = chatPtr bit 15). While the facing is still turning it sets heading 7 and slope row $10 (axis-aligned), so SelectFallbackDirection keeps the actor moving W.

FollowDirHandler0C {
    BCS FollowDir0CSetHFlipOnly
    LDA $000E, Y
    AND #$3FFF
    ORA #$4000
    STA $000E, Y

  FollowDir0CSetHFlipOnly:
    LDA $0000
    BMI FollowDir0CSetFacing
    LDA #$0007
    STA $0000
    LDA #$0010
    STA $orbitAngle, X

  FollowDir0CSetFacing:
    RTS 
}

---------------------------------------------
; Facing WNW (frame 13): sets H-mirror ($4000) on the spawner (skipped when carry = chatPtr bit 15). While the facing is still turning it sets heading 7 and slope row $08 (half slope), so SelectFallbackDirection keeps the actor moving WNW.

FollowDirHandler0D {
    BCS FollowDir0DSetHFlipOnly
    LDA $000E, Y
    AND #$3FFF
    ORA #$4000
    STA $000E, Y

  FollowDir0DSetHFlipOnly:
    LDA $0000
    BMI FollowDir0DSetFacing
    LDA #$0007
    STA $0000
    LDA #$0008
    STA $orbitAngle, X

  FollowDir0DSetFacing:
    RTS 
}

---------------------------------------------
; Facing NW (frame 14): sets H-mirror ($4000) on the spawner (skipped when carry = chatPtr bit 15). While the facing is still turning it sets heading 8 and slope row $00 (45 degrees), so SelectFallbackDirection keeps the actor moving NW.

FollowDirHandler0E {
    BCS FollowDir0ESetHFlipOnly
    LDA $000E, Y
    AND #$3FFF
    ORA #$4000
    STA $000E, Y

  FollowDir0ESetHFlipOnly:
    LDA $0000
    BMI FollowDir0ESetFacing
    LDA #$0008
    STA $0000
    LDA #$0000
    STA $orbitAngle, X

  FollowDir0ESetFacing:
    RTS 
}

---------------------------------------------
; Facing NNW (frame 15): sets H-mirror ($4000) on the spawner (skipped when carry = chatPtr bit 15). While the facing is still turning it sets heading 8 and slope row $08 (half slope), so SelectFallbackDirection keeps the actor moving NNW.

FollowDirHandler0F {
    BCS FollowDir0FSetHFlipOnly
    LDA $000E, Y
    AND #$3FFF
    ORA #$4000
    STA $000E, Y

  FollowDir0FSetHFlipOnly:
    LDA $0000
    BMI FollowDir0FSetFacing
    LDA #$0008
    STA $0000
    LDA #$0008
    STA $orbitAngle, X

  FollowDir0FSetFacing:
    RTS 
}

---------------------------------------------
; Dither table for ComputeFollowStep: 17 rows (orbitAngle 0 = 45 degrees ... 16 = axis-aligned) of 16 words, each 0 or 1.
; 
; ComputeFollowStep sums a window of loopCounter entries starting at the dither phase (orbitDiameter); that count is the minor-axis pixels moved this frame. Row 0 is all 1s (equal axes); later rows have fewer 1s as the aim gets closer to an axis.

FollowSlopeDitherTable #01000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100000001000100010001000100010001000100010001000100010000000100010001000100010001000100000001000100010001000100000001000100010001000000010001000100010001000000010001000100010000000100010001000000010001000100000001000100010000000100010000000100010001000000010000000100010001000000010001000000010001000000010001000000010000000100010000000100010000000100000001000100000001000000010000000100000001000100000001000000010000000100000001000000010000000100000001000000010000000100000001000000010000000100000001000000010000000100000000000100000001000000010000000000010000000000010000000100000000000100000000000100000001000000000001000000000000000100000001000000000000000100000000000100000000000000010000000000000001000000000000000100000000000000010000000000000001000000000000000000010000000000000000000000010000000000000000000000000001000000000000000000000000000000010000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000