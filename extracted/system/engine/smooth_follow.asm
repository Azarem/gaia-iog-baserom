; Shared follow/chase AI engine for actors that homing-track a target position (Bank $00, ~1.3 KB).
; 
; Main entries CopySiblingFollowState (copies loopCounter and chatPtr from a sibling actor) and InitFollowAndChase (same copy plus resets direction state in $7F000E to $FFFF, then enters the 8-direction chase loop).
; 
; Compares delta-X and delta-Y to the target (parent actor in $24, Y offset −8 for sprite anchor) to pick a dominant axis, then dispatches through ComputeFollowAngle/ComputeFollowAngleAlt, ResolveFollowDirection/ResolveFollowDirectionAlt, and ComputeFollowStep.
; 
; ComputeFollowStep walks the SmoothFollowLookup sine table to produce sub-pixel movement deltas; ApplyFollowMovement writes results to actor and parent positions ($14/$16) and re-queues via SetEntryExitNow when orbitDiameter ≥ 8.
; 
; Sixteen FollowDirectionTable handlers set facing sprites and OAM flip bits ($000E) per direction; SelectFallbackDirection rotates through alternatives on blocked paths. Called programmatically by smooth_follow_child actor scripts (bosses, projectiles, platforms) and hard $& references from Pyramid, Angkor Wat, and similar scenes.
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

; Lightweight entry into the smooth-follow engine that mirrors state from a sibling actor.
; 
; Reads the sibling actor ID at $0004,Y, swaps loopCounter ($7F0014) and chatPtr ($7F000A) between sibling and self, then branches into the shared chase loop without resetting direction state in animScratch2. Spawned via SpawnMarkedAfter from boss and puzzle scripts.

CopySiblingFollowState {
    TXY                   ; CopySiblingFollowState: mirror loopCounter and chatPtr from sibling $04
    LDX $0004, Y          ; Load sibling actor ID from prev-link $0004
    LDA $loopCounter, X   ; Copy sibling's loopCounter to scratch $0000
    STA $0000
    LDA $chatPtr, X       ; Copy sibling's chatPtr to scratch $0002
    STA $0002
    TYX 
    LDA $0000
    STA $loopCounter, X   ; Store sibling's loopCounter into this actor
    LDA $0002
    STA $chatPtr, X       ; Store sibling's chatPtr into this actor
    BRA FollowChaseMainLoop
}

InitFollowAndChase {
    TXY                   ; InitFollowAndChase: reset animScratch2=$FFFF, enter 8-direction chase dispatch
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
    LDA #$FFFF            ; Reset direction state to $FFFF (uninitialized — forces fresh direction pick)
    STA $animScratch2, X

  FollowChaseMainLoop:
    LDY $24               ; FollowChaseMainLoop: compare |deltaX| vs |deltaY−8| to pick dominant axis
    LDA $0014, Y          ; deltaX = target.X − self.X; deltaY = target.Y − 8 − self.Y
    SEC 
    SBC $14               ; Subtract own X from target X
    BMI FollowChaseYDiffNegative ; Negative deltaX → target is to the left (Y diff path)
    STA $0018             ; Store |deltaX| in $0018 (positive = target is right)
    LDA $0016, Y          ; deltaY = target.Y ($0016,Y) − 8 (sprite anchor offset) − self.Y
    SEC 
    SBC #$0008            ; Subtract 8px for sprite anchor offset on Y axis
    SEC                   ; Subtract 8px sprite anchor offset from Y delta
    SBC $16
    BMI FollowChaseXDiffNegativePrimary
    STA $001C             ; Store |deltaY| in $001C
    CMP $0018             ; Compare |deltaY| vs |deltaX| to pick dominant movement axis
    BCC FollowChaseDominantXGreater ; |deltaY| < |deltaX| → X axis dominates → move west/east
    JMP $&FollowChaseMoveEast ; |deltaY| ≥ |deltaX| → Y dominates → move east

  FollowChaseDominantXGreater:
    JMP $&FollowChaseMoveWest ; X dominates → dispatch west/east path

  FollowChaseXDiffNegativePrimary:
    EOR #$FFFF            ; Negate deltaY: EOR #$FFFF + INC = two's complement
    INC 
    STA $001C
    CMP $0018
    BCS FollowChaseDiagQuadrantSW
    BRA FollowChaseDiagQuadrantNW

  FollowChaseYDiffNegative:
    EOR #$FFFF            ; Negate deltaX for target-is-left case
    INC 
    STA $0018
    LDA $0016, Y
    SEC 
    SBC #$0008
    SEC 
    SBC $16
    BMI FollowChaseXDiffNegativeSecondary
    STA $001C
    CMP $0018
    BCC FollowChaseDominantXGreaterAlt
    JMP $&FollowChaseMoveNorth

  FollowChaseDominantXGreaterAlt:
    JMP $&FollowChaseMoveSouth

  FollowChaseXDiffNegativeSecondary:
    EOR #$FFFF
    INC 
    STA $001C
    CMP $0018
    BCC FollowChaseDiagQuadrantNE
    JMP $&FollowChaseMoveDiagSE

  FollowChaseDiagQuadrantNE:
    JMP $&FollowChaseMoveDiagNE

  FollowChaseDiagQuadrantSW:
    JSR $&ComputeFollowAngle ; ComputeFollowAngle for SW quadrant
    LDA #$0000            ; Direction base index 0 (SW diagonal)
    STA $0000
    JSR $&ResolveFollowDirection ; Resolve sub-direction from angle + base index
    LDA $0000
    BMI FollowChaseMoveDiagSW ; $0000 < 0 → direction resolved, proceed with movement
    JMP $&SelectFallbackDirection ; Direction blocked → rotate through fallback directions

  FollowChaseMoveDiagSW:
    COP [SetEntryContinue]
    JSR $&ComputeFollowStep ; ComputeFollowStep: sine-table walk → sub-pixel deltas
    LDA $0000             ; Negate X delta (flip to SW direction)
    EOR #$FFFF
    INC 
    TAY 
    LDA $0002             ; Swap X/Y for diagonal movement: $0000=Y, $0002=X
    STA $0000
    STY $0002
    JMP $&ApplyFollowMovement

  FollowChaseDiagQuadrantNW:
    JSR $&ComputeFollowAngleAlt
    LDA #$0002
    STA $0000
    JSR $&ResolveFollowDirectionAlt
    LDA $0000
    BMI FollowChaseMoveDiagNW
    JMP $&SelectFallbackDirection

  FollowChaseMoveDiagNW:
    COP [SetEntryContinue]
    JSR $&ComputeFollowStep
    LDA $0002
    EOR #$FFFF
    INC 
    STA $0002
    JMP $&ApplyFollowMovement
}

FollowChaseMoveWest {
    JSR $&ComputeFollowAngleAlt
    LDA #$0004            ; Direction base 4 = west (pure horizontal)
    STA $0000
    JSR $&ResolveFollowDirection
    LDA $0000
    BMI FollowChaseApplyWest
    JMP $&SelectFallbackDirection

  FollowChaseApplyWest:
    COP [SetEntryContinue]
    JSR $&ComputeFollowStep
    JMP $&ApplyFollowMovement
}

FollowChaseMoveEast {
    JSR $&ComputeFollowAngle
    LDA #$0006            ; Direction base index 6 (east)
    STA $0000
    JSR $&ResolveFollowDirectionAlt
    LDA $0000
    BMI FollowChaseApplyEast
    JMP $&SelectFallbackDirection

  FollowChaseApplyEast:
    COP [SetEntryContinue]
    JSR $&ComputeFollowStep
    LDA $0000
    TAY 
    LDA $0002
    STA $0000
    STY $0002
    JMP $&ApplyFollowMovement
}

FollowChaseMoveNorth {
    JSR $&ComputeFollowAngle
    LDA #$0008            ; Direction base index 8 (north)
    STA $0000
    JSR $&ResolveFollowDirection
    LDA $0000
    BMI FollowChaseApplyNorth
    JMP $&SelectFallbackDirection

  FollowChaseApplyNorth:
    COP [SetEntryContinue]
    JSR $&ComputeFollowStep
    LDA $0002
    EOR #$FFFF            ; Negate Y for northward movement
    INC 
    TAY 
    LDA $0000
    STA $0002             ; Swap: X becomes Y step, Y becomes X step
    STY $0000
    JMP $&ApplyFollowMovement
}

FollowChaseMoveSouth {
    JSR $&ComputeFollowAngleAlt
    LDA #$000A            ; Direction base index $A (south)
    STA $0000
    JSR $&ResolveFollowDirectionAlt
    LDA $0000
    BMI FollowChaseApplySouth
    JMP $&SelectFallbackDirection

  FollowChaseApplySouth:
    COP [SetEntryContinue]
    JSR $&ComputeFollowStep
    LDA $0000
    EOR #$FFFF            ; Negate for southward (positive Y delta → negative step)
    INC 
    STA $0000
    JMP $&ApplyFollowMovement
}

FollowChaseMoveDiagNE {
    JSR $&ComputeFollowAngleAlt
    LDA #$000C            ; Direction base index $C (NE diagonal)
    STA $0000
    JSR $&ResolveFollowDirection
    LDA $0000
    BMI FollowChaseApplyDiagNE
    JMP $&SelectFallbackDirection

  FollowChaseApplyDiagNE:
    COP [SetEntryContinue]
    JSR $&ComputeFollowStep
    LDA $0000
    EOR #$FFFF            ; Negate both X and Y for NE quadrant
    INC 
    STA $0000
    LDA $0002
    EOR #$FFFF
    INC 
    STA $0002
    BRA ApplyFollowMovement
}

FollowChaseMoveDiagSE {
    JSR $&ComputeFollowAngle
    LDA #$000E            ; Direction base index $E (SE diagonal)
    STA $0000
    JSR $&ResolveFollowDirectionAlt
    LDA $0000
    BMI FollowChaseApplyDiagSE
    JMP $&SelectFallbackDirection

  FollowChaseApplyDiagSE:
    COP [SetEntryContinue]
    JSR $&ComputeFollowStep
    LDA $0000
    EOR #$FFFF            ; Negate both for SE quadrant direction
    INC 
    TAY 
    LDA $0002
    EOR #$FFFF
    INC 
    STA $0000
    STY $0002
}

ApplyFollowMovement {
    LDY $04               ; ApplyFollowMovement: write sub-pixel deltas to parent $14/$16 and moveScratch
    LDA $14               ; Apply X delta: self.X += $0000 (computed step)
    CLC                   ; Add computed X step ($0000) to self.X
    ADC $0000
    STA $14
    STA $0014, Y          ; Sync position to parent actor Y via $04 link
    LDA $0000
    STA $moveScratch1, X  ; Store X step in moveScratch1 for external reference
    LDA $16
    CLC 
    ADC $0002             ; Add computed Y step ($0002) to self.Y
    STA $16
    STA $0016, Y          ; Sync Y position to parent actor
    LDA $0002
    STA $moveScratch2, X  ; Store Y step in moveScratch2
    LDA $orbitDiameter, X ; orbitDiameter ≥ 8 → re-queue to FollowChaseMainLoop
    CMP #$0008            ; Reset diameter and re-enter chase loop via SetEntryExitNow
    BPL FollowChaseRequeueLoop
    RTL 

  FollowChaseRequeueLoop:
    LDA #$0000            ; orbitDiameter≥8 triggers SetEntryExitNow re-queue to FollowChaseMainLoop
    STA $orbitDiameter, X
    COP [SetEntryExitNow] ( @FollowChaseMainLoop )
}

SelectFallbackDirection {
    DEC                   ; SelectFallbackDirection: DEC+AND #$07 rotates through 8 chase handlers
    AND #$0007
    STA $0004             ; Equal deltas → angle = 0 (45° diagonal)
    COP [SwitchCase] ( #$0004, &follow_fallback_table ) ; Equal deltas → angle = 0 (45° diagonal); dispatch via switch table
}

follow_fallback_table [
  &FollowChaseMoveDiagSW   ;00
  &FollowChaseMoveDiagNW   ;01
  &FollowChaseApplyWest   ;02
  &FollowChaseApplyEast   ;03
  &FollowChaseApplyNorth   ;04
  &FollowChaseApplySouth   ;05
  &FollowChaseApplyDiagNE   ;06
  &FollowChaseApplyDiagSE   ;07
]
---------------------------------------------

; Computes the angular step for smooth follow when horizontal separation dominates.
; 
; Inputs are absolute delta-X ($0018) and delta-Y ($001C) prepared by InitFollowAndChase; if equal, stores angle zero. Otherwise divides the smaller axis by 16 and calls hardware_math.UnsignedDivide to map the ratio into a 0–23 orbit index. Stores the result in orbitAngle ($7F0010,X), clears orbitDiameter, and returns via RTS.

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

ComputeFollowStep {
    LDA $orbitAngle, X    ; ComputeFollowStep: walk SmoothFollowLookup table using orbitAngle×32 as index
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
    LDA $@SmoothFollowLookup, X
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

ResolveFollowDirection {
    LDA $orbitAngle, X    ; ResolveFollowDirection: angle bands $05–$0D pick X, diagonal, or Y step
    CMP #$000D
    BPL ResolveFollowDirMoveXOnly
    CMP #$0005
    BPL ResolveFollowDirMoveDiagonal
    BRA ResolveFollowDirMoveYOnly
}

ResolveFollowDirectionAlt {
    LDA $orbitAngle, X
    CMP #$000D
    BPL ResolveFollowDirMoveYOnly
    CMP #$0005
    BPL ResolveFollowDirMoveDiagonal

  ResolveFollowDirMoveXOnly:
    LDA #$0000
    STA $0002
    BRA ResolveFollowDirAdvanceFrame

  ResolveFollowDirMoveDiagonal:
    LDA #$0001
    STA $0002
    BRA ResolveFollowDirAdvanceFrame

  ResolveFollowDirMoveYOnly:
    LDA #$0002
    STA $0002

  ResolveFollowDirAdvanceFrame:
    LDA $0000
    CLC 
    ADC $0002
    AND #$000F
    STA $0004
    LDA $chatPtr, X
    LDA $animScratch2, X
    BMI ResolveFollowDirAltSnapFrame
    SEC 
    SBC $0004
    BMI ResolveFollowDirAltWrapNeg
    BEQ ResolveFollowDirAltSnapFrame
    CMP #$0001
    BEQ ResolveFollowDirAltSnapFrame
    CMP #$000F
    BEQ ResolveFollowDirAltSnapFrame
    CMP #$0009
    BPL ResolveFollowDirAltIncFrame
    BRA ResolveFollowDirAltDecFrame

  ResolveFollowDirAltWrapNeg:
    CMP #$FFFF
    BEQ ResolveFollowDirAltSnapFrame
    CMP #$FFF1
    BEQ ResolveFollowDirAltSnapFrame
    CMP #$FFF9
    BPL ResolveFollowDirAltIncFrame
    BRA ResolveFollowDirAltDecFrame

  ResolveFollowDirAltDecFrame:
    LDA $animScratch2, X
    DEC 
    STA $animScratch2, X
    STA $0004
    BPL ResolveFollowDirAltApplyFrame
    LDA #$000F
    STA $animScratch2, X
    STA $0004
    BRA ResolveFollowDirAltApplyFrame

  ResolveFollowDirAltIncFrame:
    LDA $animScratch2, X
    INC 
    AND #$000F
    STA $animScratch2, X
    STA $0004
    BRA ResolveFollowDirAltApplyFrame

  ResolveFollowDirAltSnapFrame:
    LDA $0004
    STA $animScratch2, X
    LDA #$FFFF
    STA $0000

  ResolveFollowDirAltApplyFrame:
    LDA $0004, X          ; ResolveFollowDirAltApplyFrame: update $0028 facing from FollowDirectionTable
    TAY 
    LDA $chatPtr, X
    BMI ResolveFollowDirAltSkipAnimUpdate
    CLC 
    ADC $0004
    STA $0028, Y
    LDA #$0000
    STA $002A, Y

  ResolveFollowDirAltSkipAnimUpdate:
    LDA $chatPtr, X
    BMI ResolveFollowDirAltUpdateAnim
    PHX 
    TYX 
    TYA 
    TCD 
    JSL $@sprite_composition.UpdateActorAnimation
    PLA 
    TXY 
    TAX 
    TCD 

  ResolveFollowDirAltUpdateAnim:
    LDA $chatPtr, X
    STA $0006
    LDA $animScratch2, X
    AND #$000F
    PHX 
    ASL 
    TAX 
    CLC 
    LDA $0006
    BPL ResolveFollowDirAltLoadTable
    SEC 

  ResolveFollowDirAltLoadTable:
    LDA $@FollowDirectionTable, X
    DEC 
    PLX 
    PHA 
    RTS                   ; FollowDirectionTable: 16 handlers set OAM flip bits $4000/$8000/$C000 on $000E
}

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

FollowDirHandler00 {
    BCS FollowDir00ClearHFlip
    LDA $000E, Y          ; Clear H-flip ($4000) and V-flip ($8000) from OAM attribute $000E
    AND #$3FFF
    STA $000E, Y

  FollowDir00ClearHFlip:
    LDA $0000             ; Check if direction already resolved ($0000 < 0)
    BMI FollowDir00SetFacing
    LDA #$0001            ; Not resolved: set fallback direction index 1
    STA $0000
    LDA #$0010            ; Reset orbitAngle to $10 (perpendicular)
    STA $orbitAngle, X

  FollowDir00SetFacing:
    RTS 
}

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
    LDA #$0010            ; Fallback direction 3, orbitAngle $10
    STA $orbitAngle, X

  FollowDir04SetFacing:
    RTS 
}

FollowDirHandler05 {
    BCS FollowDir05SetVFlip
    LDA $000E, Y
    AND #$3FFF            ; Set V-flip ($8000) in OAM attribute for mirrored facing
    ORA #$8000
    STA $000E, Y

  FollowDir05SetVFlip:
    LDA $0000
    BMI FollowDir05SetFacing
    LDA #$0003
    STA $0000
    LDA #$0008
    STA $orbitAngle, X    ; Set H-flip ($4000) for horizontally mirrored facing

  FollowDir05SetFacing:
    RTS 
}

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
    STA $0000             ; Set both V+H flip ($C000) for diagonal mirror
    LDA #$0000
    STA $orbitAngle, X

  FollowDir06SetFacing:
    RTS 
}

FollowDirHandler07 {
    BCS FollowDir07SetVFlip
    LDA $000E, Y
    AND #$3FFF
    ORA #$8000
    STA $000E, Y

  FollowDir07SetVFlip:
    LDA $0000             ; Direction 8: facing left-down; AND #$3FFF clear both flips
    BMI FollowDir07SetFacing
    LDA #$0004
    STA $0000
    LDA #$0008
    STA $orbitAngle, X

  FollowDir07SetFacing:
    RTS 
}

FollowDirHandler08 {
    BCS FollowDir08SetVFlip
    LDA $000E, Y
    AND #$3FFF
    ORA #$8000
    STA $000E, Y          ; Direction 9: facing left; clear flips

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

FollowDirHandler09 {
    BCS FollowDir09SetHVFlip
    LDA $000E, Y
    AND #$3FFF
    ORA #$C000            ; Direction A: facing left-up; clear flips
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

SmoothFollowLookup #01000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100000001000100010001000100010001000100010001000100010000000100010001000100010001000100000001000100010001000100000001000100010001000000010001000100010001000000010001000100010000000100010001000000010001000100000001000100010000000100010000000100010001000000010000000100010001000000010001000000010001000000010001000000010000000100010000000100010000000100000001000100000001000000010000000100000001000100000001000000010000000100000001000000010000000100000001000000010000000100000001000000010000000100000001000000010000000100000000000100000001000000010000000000010000000000010000000100000000000100000000000100000001000000000001000000000000000100000001000000000000000100000000000100000000000000010000000000000001000000000000000100000000000000010000000000000001000000000000000000010000000000000000000000010000000000000000000000000001000000000000000000000000000000010000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000