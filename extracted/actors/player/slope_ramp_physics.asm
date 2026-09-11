; Slope/ramp terrain physics and flat-ground deceleration — SpawnAfter companion actor (177195–178099).
; 
; Spawned by PlayerCharacterDef. Runs every frame after player_move_controller. Probes collision tiles at the player's feet to detect slope/ramp terrain and applies acceleration curves; also handles deceleration on flat ground.
; 
; === TILE TYPE MAPPING (SlopeTileDispatch) ===
; 
; | Type | Handler | Direction | Curve |
; |------|---------|-----------|-------|
; | $03  | SlopeType03Handler | South (NS+) | slopeCurvePtrB |
; | $05  | SlopeType05Handler | West (EW−) | slopeCurvePtrA |
; | $0A  | SlopeType0AHandler | East (EW+) | slopeCurvePtrA |
; | $0C  | SlopeType0CHandler | North (NS−) | slopeCurvePtrB |
; 
; All other types (0-2, 4, 6-9, B-F) are zero → no slope handler.
; 
; === CURVE SYSTEM ===
; 
; Two acceleration curve pointers (slopeCurvePtrA for EW, slopeCurvePtrB for NS) reference 16-entry tables in WRAM. Each frame on a slope, slopeStepCounter (mod 16) indexes the table to get a speed delta. When speed reaches zero, the $1000 flag (stopped-on-slope) is set and the counter resets.
; 
; === DECELERATION ===
; 
; On flat ground (no slope tile detected), speed is reduced via decelCurvePtr (separate 16-entry table). Deceleration is skipped if the $1000 flag is set (player stopped on slope but not pushing off). If |speed| < 3, it's instantly zeroed. If the player holds the opposite D-pad direction, an extra decel step is applied (braking). If holding the same direction as current speed, deceleration is suppressed.
; 
; === SPECIAL TILE TYPES 06/09 ===
; 
; When the tile directly under the player is type $06 or $09 (transition tiles), the system checks the right and left adjacent cells for actual slope types ($05 or $0A). This handles edge cases where the player stands between a slope and flat ground.
; 
; === WALK-ATTACK MULTI-CELL PROBE ===
; 
; When the player has zero speed but the $1000 flag is set (stopped on slope), a 4-cell adjacency probe searches Current, Down, Right, and Down-Right cells for any slope tile. If found, the appropriate slope handler is called. If none found, the slope state is cleared via SlopeFlatExit.
---------------------------------------------

?BANK 02

?INCLUDE 'tile_collision'

!joypadCurrent                  0656
!playerXPos                     09A2
!playerYPos                     09A4
!playerActor                    09AA
!playerFlags                    09AE
!playerSpeedEw                  09B2
!playerSpeedNs                  09B4
!slopeStepCounter               09B6
!decelStepCounter               09B8
!slopeCurvePtrA                 09BA
!slopeCurvePtrB                 09BC
!decelCurvePtr                  09C2
!slopeFracAccum                 09C6
!maxSpeedEw                     09C8
!maxSpeedNs                     09CA
!iframeCounter                  7F0028

---------------------------------------------

; Slope/ramp terrain detection and physics — SpawnAfter companion actor.
; 
; Three main paths each frame:
; 1. MOVING (speed nonzero): Probe tile at player's feet (Y-8) via TileProbeMain. Look up collision nibble in SlopeTileDispatch (16-entry table). If valid slope type → dispatch to handler. If type $06/$09 (transition tiles) → check right/left adjacent cells for $05/$0A slopes.
; 2. STOPPED ON SLOPE ($1000 flag, zero speed): 4-cell adjacency probe (current, down, right, down-right) searching for any slope tile. If found → dispatch handler. If none → SlopeFlatExit clears slope state.
; 3. NO SLOPE / FLAT GROUND: SlopeFlatDecelerate reduces speed via deceleration curve tables.
; 
; Freeze/orb gate: skips slope detection if actor flags $00C0 set (freeze $0080 + orb $0040) with no active iframes.

SlopePhysicsEntry {
    COP [SetEntryContinue] ; Slope physics companion: runs each frame after player_move_controller
    PHX                   ; Check player actor flags $00C0 = freeze ($0080) + orb ($0040)
    LDX $playerActor
    LDA $0010, X
    BIT #$00C0
    BEQ loc_02B443
    LDA $iframeCounter, X ; Negative iframe counter → allow physics even while frozen/orbiting
    BMI loc_02B443
    PLX 
    JMP $&SlopeFlatDecelerate ; Frozen or orb active (no iframes) → skip slope detection, only decelerate

  loc_02B443:
    PLX 
    LDA $playerSpeedEw    ; Check if player has any active speed (EW or NS nonzero)
    ORA $playerSpeedNs
    BEQ loc_02B4C0        ; No speed → check walk-attack flag for stopped-on-slope multi-cell probe
    PHX                   ; Has speed → begin slope tile detection
    PHD 
    LDA #$0000            ; Set DP to $0000 for tile_collision work area access ($1A, $1E)
    TCD 
    LDY $playerActor
    LDA $0014, Y          ; Load player X position for tile probe
    STA $1A
    LDA $0016, Y
    SEC                   ; Player Y minus 8 pixels → probe at feet level (player hotspot is 8px above base)
    SBC #$0008
    STA $1E
    JSR $&tile_collision.TileProbeMain ; TileProbeMain: read collision nibble at player's feet
    AND #$00FF
    ASL 
    TAX 
    LDA $@SlopeTileDispatch, X ; Look up slope handler in SlopeTileDispatch by collision type
    BEQ loc_02B474        ; Non-zero → valid slope handler; DEC+PHA+RTS dispatch trick
    DEC 
    PHA 
    RTS 

  loc_02B474:
    TXA                   ; Zero result: check for transition tile types $06 or $09
    LSR 
    CMP #$0006
    BEQ loc_02B483
    CMP #$0009            ; Type $09: same treatment as $06 — check adjacent cells
    BEQ loc_02B483
    JMP $&SlopeFlatExit   ; Not $06 or $09 → flat ground exit

  loc_02B483:
    JSR $&tile_collision.MapCellRight ; Transition tile: check RIGHT adjacent cell for slope types $05 or $0A
    SEP #$20
    JSR $&tile_collision.ReadCollisionNibble
    REP #$20
    AND #$00FF
    CMP #$0005
    BNE loc_02B498
    JMP $&SlopeType05Handler

  loc_02B498:
    CMP #$000A            ; Right cell was type $0A → east slope handler
    BNE loc_02B4A0
    JMP $&SlopeType0AHandler

  loc_02B4A0:
    JSR $&tile_collision.MapCellLeft ; Right cell not a slope → check LEFT adjacent cell for $05 or $0A
    SEP #$20
    JSR $&tile_collision.ReadCollisionNibble
    REP #$20
    AND #$00FF
    CMP #$0005
    BNE loc_02B4B5
    JMP $&SlopeType05Handler

  loc_02B4B5:
    CMP #$000A
    BNE loc_02B4BD
    JMP $&SlopeType0AHandler

  loc_02B4BD:
    JMP $&SlopeFlatExit   ; Neither adjacent cell has a slope → flat exit

  loc_02B4C0:
    LDA $playerFlags      ; Zero speed path: check $1000 flag (stopped on slope)
    BIT #$1000
    BNE loc_02B4CB
    JMP $&SlopeFlatDecelerate ; No $1000 flag → normal flat-ground deceleration

  loc_02B4CB:
    STZ $slopeStepCounter ; Stopped on slope: reset slope/decel counters, begin 4-cell adjacency probe
    STZ $decelStepCounter
    PHX 
    PHD 
    LDY $playerActor
    LDA $playerXPos       ; Load player pixel position directly (not actor local coords) for probe
    STA $001A
    LDA $playerYPos
    STA $001E
    LDA #$0000
    TCD 
    JSR $&tile_collision.TileProbeMain ; Probe 1: current cell — check for slope tile
    AND #$00FF
    ASL 
    TAX 
    LDA $@SlopeTileDispatch, X
    BNE loc_02B535        ; Found slope → dispatch to handler
    JSR $&tile_collision.MapCellDown ; Probe 2: cell below player
    SEP #$20
    JSR $&tile_collision.ReadCollisionNibble
    REP #$20
    AND #$00FF
    ASL 
    TAX 
    LDA $@SlopeTileDispatch, X
    BNE loc_02B535
    JSR $&tile_collision.MapCellRight ; Probe 3: cell to the right of player
    STX $00
    SEP #$20
    JSR $&tile_collision.ReadCollisionNibble
    REP #$20
    AND #$00FF
    ASL 
    TAX 
    LDA $@SlopeTileDispatch, X
    BNE loc_02B535
    JSR $&tile_collision.MapCellDown ; Probe 4: cell below-right (diagonal)
    SEP #$20
    JSR $&tile_collision.ReadCollisionNibble
    REP #$20
    AND #$00FF
    ASL 
    TAX 
    LDA $@SlopeTileDispatch, X
    BEQ SlopeFlatExit     ; All 4 cells checked, no slope found → clear slope state via SlopeFlatExit

  loc_02B535:
    DEC                   ; Slope found in multi-cell probe → dispatch to handler via RTS trick
    PHA 
    RTS 
}

SlopeType03Handler {
    JSR $&ApplySlopeCurvePosNS ; Slope type $03: south-descending ramp → apply positive NS speed curve
    BRA loc_02B54A
}

SlopeType05Handler {
    JSR $&ApplySlopeCurveNegEW ; Slope type $05: west-descending ramp → apply negative EW speed curve (decelerate eastward/accelerate westward)
    BRA loc_02B54A
}

SlopeType0AHandler {
    JSR $&ApplySlopeCurvePosEW ; Slope type $0A: east-descending ramp → apply positive EW speed curve
    BRA loc_02B54A

  SlopeType0CHandler:
    JSR $&ApplySlopeCurveNegNS ; Slope type $0C: north-descending ramp → apply negative NS speed curve

  loc_02B54A:
    JSR $&ClampSpeeds     ; After slope curve applied → clamp speeds to max, restore DP, exit
    PLD 
    PLX 
    RTL 
}

SlopeFlatExit {
    JSR $&ClampSpeeds     ; Flat exit: clamp speeds, clear slope fractional accumulator and step counter
    STZ $slopeFracAccum
    STZ $slopeStepCounter
    PLD 
    PLX 
}

---------------------------------------------
; Flat-ground deceleration entry point.
; 
; First decelerates EW speed (if nonzero) via DecelerateEW. Then checks NS speed — if zero, checks and clears the $1000 flag (stopped-on-slope) if it was set. If NS speed is nonzero, decelerates via DecelerateNS.
; 
; The $1000 flag clearance ensures that when a player leaves a slope and comes to a full stop on flat ground, the slope state is properly cleaned up.

SlopeFlatDecelerate {
    LDA $playerSpeedEw    ; Flat deceleration entry: check EW speed first, then NS
    BEQ loc_02B564        ; No EW speed → check for walk-attack flag before NS deceleration
    JSR $&DecelerateEW
    RTL 

  loc_02B564:
    LDA $playerFlags      ; Check $1000 (stopped-on-slope) — if set, clear it (player left the slope)
    BIT #$1000
    BEQ loc_02B572
    AND #$EFFF
    STA $playerFlags

  loc_02B572:
    LDA $playerSpeedNs    ; Check NS speed: if nonzero, decelerate
    BNE loc_02B578
    RTL 

  loc_02B578:
    JSR $&DecelerateNS
    RTL 
}

---------------------------------------------
; 16-entry collision type dispatch table for slope handlers.
; 
; Only 4 of 16 entries are populated (types $03, $05, $0A, $0C → slope handlers). All others are zero (no slope). Indexed by collision nibble × 2 for word-sized entries. Non-zero entries use the RTS dispatch trick (address - 1 stored, DEC+PHA+RTS to jump).

SlopeTileDispatch [
  #$0000   ;00
  #$0000   ;01
  #$0000   ;02
  &SlopeType03Handler   ;03
  #$0000   ;04
  &SlopeType05Handler   ;05
  #$0000   ;06
  #$0000   ;07
  #$0000   ;08
  #$0000   ;09
  &SlopeType0AHandler   ;0A
  #$0000   ;0B
  &SlopeType0CHandler   ;0C
  #$0000   ;0D
  #$0000   ;0E
  #$0000   ;0F
]

---------------------------------------------
; Apply slope deceleration/acceleration curve to EW speed (negative direction = westward).
; 
; Reads a 16-bit value from the acceleration curve table pointed to by slopeCurvePtrA, indexed by (slopeStepCounter & $0F) × 2. Negates the value (two's complement) and adds to playerSpeedEw. If speed reaches zero, sets the $1000 flag (stopped-on-slope) and resets the step counter. Otherwise increments the counter for the next frame.
; 
; The four curve routines (NegEW, PosEW, PosNS, NegNS) share identical structure — they differ only in which curve pointer they use (A for EW, B for NS) and whether they negate the table value.

ApplySlopeCurveNegEW {
    LDA $slopeStepCounter ; Read slope curve table at slopeCurvePtrA, index by slopeStepCounter mod 16, negate and add to EW speed
    AND #$000F
    ASL 
    CLC 
    ADC $slopeCurvePtrA
    TAY 
    LDA $0000, Y          ; Read curve value from WRAM table (absolute indexed by Y)
    EOR #$FFFF            ; Negate curve value (EOR $FFFF + INC = two's complement) for westward deceleration
    INC 
    CLC 
    ADC $playerSpeedEw
    STA $playerSpeedEw
    BEQ loc_02B5D8        ; Speed reached zero → stopped on slope (set $1000 flag)
    INC $slopeStepCounter ; Speed still nonzero → advance step counter for next frame
    RTS 
}

ApplySlopeCurvePosEW {
    LDA $slopeStepCounter ; Positive EW curve: read curve value and add directly to EW speed (eastward acceleration)
    AND #$000F
    ASL 
    CLC 
    ADC $slopeCurvePtrA
    TAY 
    LDA $0000, Y
    CLC 
    ADC $playerSpeedEw
    STA $playerSpeedEw
    BEQ loc_02B5D8
    INC $slopeStepCounter
    RTS 

  loc_02B5D8:
    STZ $slopeStepCounter ; Speed zeroed: reset slope step counter, set $1000 flag (stopped-on-slope), return
    LDA #$1000
    TSB $playerFlags
    RTS 
}

ApplySlopeCurvePosNS {
    LDA $slopeStepCounter ; Positive NS curve: read from slopeCurvePtrB, add to NS speed (southward acceleration)
    AND #$000F
    ASL 
    CLC 
    ADC $slopeCurvePtrB
    TAY 
    LDA $0000, Y
    CLC 
    ADC $playerSpeedNs
    STA $playerSpeedNs
    BEQ loc_02B5D8
    INC $slopeStepCounter
    RTS 
}

ApplySlopeCurveNegNS {
    LDA $slopeStepCounter ; Negative NS curve: read from slopeCurvePtrB, negate, add to NS speed (northward acceleration)
    AND #$000F
    ASL 
    CLC 
    ADC $slopeCurvePtrB
    TAY 
    LDA $0000, Y
    EOR #$FFFF
    INC 
    CLC 
    ADC $playerSpeedNs
    STA $playerSpeedNs
    BEQ loc_02B5D8
    INC $slopeStepCounter
    RTS 
}

---------------------------------------------
; Clamp both axis speeds to maximum values (maxSpeedEw, maxSpeedNs).
; 
; For each axis: if |speed| >= maxSpeed, clamp to ±(maxSpeed - 1). The -1 prevents oscillation at the boundary. Handles both positive and negative speeds by negating, comparing, and re-negating.
; 
; Called after every slope curve application and on flat exit to ensure speeds never exceed configured limits.

ClampSpeeds {
    LDA $playerSpeedEw    ; Clamp player speeds to ±(maxSpeed-1). Checks EW first, then NS
    BEQ loc_02B649
    BPL loc_02B63B        ; EW negative → compute |speed|, compare to maxSpeedEw
    EOR #$FFFF
    INC 
    CMP $maxSpeedEw
    BPL loc_02B62F
    RTS 

  loc_02B62F:
    LDA $maxSpeedEw       ; Over max: clamp to -(maxSpeedEw-1)
    DEC 
    EOR #$FFFF
    INC 
    STA $playerSpeedEw
    RTS 

  loc_02B63B:
    CMP $maxSpeedEw       ; EW positive → compare to maxSpeedEw
    BPL loc_02B641
    RTS 

  loc_02B641:
    LDA $maxSpeedEw       ; Over max: clamp to +(maxSpeedEw-1)
    DEC 
    STA $playerSpeedEw
    RTS 

  loc_02B649:
    LDA $playerSpeedNs    ; EW was zero → check NS speed
    BNE loc_02B64F
    RTS 

  loc_02B64F:
    BPL loc_02B667        ; NS negative → compute |speed|, compare to maxSpeedNs
    EOR #$FFFF
    INC 
    CMP $maxSpeedNs
    BPL loc_02B65B
    RTS 

  loc_02B65B:
    LDA $maxSpeedNs       ; Over max: clamp to -(maxSpeedNs-1)
    DEC 
    EOR #$FFFF
    INC 
    STA $playerSpeedNs
    RTS 

  loc_02B667:
    CMP $maxSpeedNs       ; NS positive → compare to maxSpeedNs
    BPL loc_02B66D
    RTS 

  loc_02B66D:
    LDA $maxSpeedNs       ; Over max: clamp to +(maxSpeedNs-1)
    DEC 
    STA $playerSpeedNs
    RTS 
}

---------------------------------------------
; Flat-ground east-west speed deceleration.
; 
; Gated: skips if $1000 flag set (stopped on slope — player hasn't pushed off yet). If |speed| < 3, instantly zeros speed (snap-to-stop at low speeds).
; 
; For |speed| >= 3, direction-aware deceleration:
; - Same-direction D-pad held (e.g. east when moving east): suppress deceleration entirely
; - No D-pad: apply one deceleration step from curve table (subtract from speed)
; - Opposite-direction D-pad held (e.g. west when moving east): apply an extra deceleration step (active braking)
; 
; Deceleration curve read from decelCurvePtr indexed by decelStepCounter mod 16. Counter auto-increments each read. Resets to zero when speed reaches zero.
; 
; DecelerateNS mirrors this for the north-south axis with corresponding D-pad bits.

DecelerateEW {
    LDA $playerFlags      ; EW deceleration: skip if $1000 flag set (stopped on slope, waiting for player input)
    BIT #$1000
    BEQ loc_02B67E
    RTS 

  loc_02B67E:
    LDA $playerSpeedEw    ; Compute |speedEw|: if negative, negate to get absolute value
    BPL loc_02B687
    EOR #$FFFF
    INC 

  loc_02B687:
    CMP #$0003            ; If |speed| < 3 → instantly zero EW speed (snap to stop at low speeds)
    BPL loc_02B690
    STZ $playerSpeedEw
    RTS 

  loc_02B690:
    LDA $playerSpeedEw    ; Speed >= 3: branch by sign for direction-aware deceleration
    BMI loc_02B6D1
    LDA $joypadCurrent    ; Positive (moving east): check if east D-pad ($0100) is held → suppress decel
    BIT #$0100
    BEQ loc_02B69E
    RTS 

  loc_02B69E:
    JSR $&ReadDecelerationStep ; East not held → apply deceleration step (subtract from speed)
    BEQ loc_02B6B0
    EOR #$FFFF
    INC 
    CLC 
    ADC $playerSpeedEw
    STA $playerSpeedEw
    BEQ loc_02B6CD        ; Speed zeroed → reset decel counter

  loc_02B6B0:
    LDA $joypadCurrent    ; Decel step was zero → check if west D-pad ($0200) held for braking
    BIT #$0200
    BNE loc_02B6B9
    RTS 

  loc_02B6B9:
    JSR $&ReadDecelerationStep ; West held → apply extra decel step (active braking against direction)
    BNE loc_02B6BF
    RTS 

  loc_02B6BF:
    EOR #$FFFF
    INC 
    CLC 
    ADC $playerSpeedEw
    STA $playerSpeedEw
    BEQ loc_02B6CD
    RTS 

  loc_02B6CD:
    STZ $decelStepCounter ; Speed reached zero → reset deceleration step counter
    RTS 

  loc_02B6D1:
    LDA $joypadCurrent    ; Negative (moving west): check if west D-pad ($0200) held → suppress decel
    BIT #$0200
    BEQ loc_02B6DA
    RTS 

  loc_02B6DA:
    JSR $&ReadDecelerationStep ; West not held → apply decel step (add positive value to negative speed)
    BEQ loc_02B6E8
    CLC 
    ADC $playerSpeedEw
    STA $playerSpeedEw
    BEQ loc_02B6CD

  loc_02B6E8:
    LDA $joypadCurrent    ; Decel step was zero → check if east D-pad ($0100) held for braking
    BIT #$0100
    BNE loc_02B6F1
    RTS 

  loc_02B6F1:
    JSR $&ReadDecelerationStep ; East held → apply extra decel step (braking)
    BNE loc_02B6F7
    RTS 

  loc_02B6F7:
    CLC 
    ADC $playerSpeedEw
    STA $playerSpeedEw
    BEQ loc_02B6CD
    RTS 
}

---------------------------------------------
; Read one deceleration delta from the curve table.
; 
; Reads a 16-bit value from the table at decelCurvePtr, indexed by (decelStepCounter & $0F) × 2. Auto-increments decelStepCounter. Returns the curve value in A (zero means no deceleration this frame).
; 
; ReadDecelerationStepNS is an identical copy for the NS axis (shares the same decelCurvePtr and decelStepCounter).

ReadDecelerationStep {
    LDA $decelStepCounter ; Read decel curve value from decelCurvePtr indexed by decelStepCounter mod 16; auto-increment counter
    INC $decelStepCounter
    AND #$000F
    ASL 
    CLC 
    ADC $decelCurvePtr
    TAY 
    LDA $0000, Y
    RTS 
}

DecelerateNS {
    LDA $playerFlags      ; NS deceleration: mirror of DecelerateEW for north-south axis. Skip if $1000 flag set
    BIT #$1000
    BEQ loc_02B71D
    RTS 

  loc_02B71D:
    LDA $playerSpeedNs    ; Compute |speedNs|: if negative, negate to get absolute value
    BPL loc_02B726
    EOR #$FFFF
    INC 

  loc_02B726:
    CMP #$0003            ; If |speed| < 3 → instantly zero NS speed (snap to stop at low speeds)
    BPL loc_02B72F
    STZ $playerSpeedNs
    RTS 

  loc_02B72F:
    LDA $playerSpeedNs    ; Speed >= 3: branch by sign for direction-aware deceleration
    BMI loc_02B770
    LDA $joypadCurrent
    BIT #$0400
    BEQ loc_02B73D        ; Positive (moving south): check south D-pad ($0400) → suppress decel
    RTS 

  loc_02B73D:
    JSR $&ReadDecelerationStepNS ; South not held → apply deceleration step (subtract from positive speed)
    BEQ loc_02B74F
    EOR #$FFFF
    INC 
    CLC 
    ADC $playerSpeedNs
    STA $playerSpeedNs
    BEQ loc_02B76C

  loc_02B74F:
    LDA $joypadCurrent
    BIT #$0800
    BNE loc_02B758        ; Check north D-pad ($0800) for braking
    RTS 

  loc_02B758:
    JSR $&ReadDecelerationStepNS
    BNE loc_02B75E
    RTS 

  loc_02B75E:
    EOR #$FFFF
    INC 
    CLC 
    ADC $playerSpeedNs
    STA $playerSpeedNs
    BEQ loc_02B76C
    RTS 

  loc_02B76C:
    STZ $slopeStepCounter
    RTS 

  loc_02B770:
    LDA $joypadCurrent    ; Negative (moving north): check if north D-pad ($0800) is held → suppress decel
    BIT #$0800
    BEQ loc_02B779
    RTS 

  loc_02B779:
    JSR $&ReadDecelerationStepNS ; North not held → apply decel step (add positive value to negative speed)
    BEQ loc_02B787
    CLC 
    ADC $playerSpeedNs
    STA $playerSpeedNs
    BEQ loc_02B76C

  loc_02B787:
    LDA $joypadCurrent    ; Decel step was zero → check if south D-pad ($0400) held for braking
    BIT #$0400
    BNE loc_02B790
    RTS 

  loc_02B790:
    JSR $&ReadDecelerationStepNS
    BNE loc_02B796
    RTS 

  loc_02B796:
    CLC 
    ADC $playerSpeedNs
    STA $playerSpeedNs
    BEQ loc_02B76C
    RTS 
}

ReadDecelerationStepNS {
    LDA $decelStepCounter ; Read NS decel curve value (identical logic to ReadDecelerationStep, separate counter increment)
    INC $decelStepCounter
    AND #$000F
    ASL 
    CLC 
    ADC $decelCurvePtr
    TAY 
    LDA $0000, Y
    RTS 
}