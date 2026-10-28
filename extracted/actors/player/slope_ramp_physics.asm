; Slope/ramp terrain physics and flat-ground deceleration - SpawnAfter companion of the player actor (177195-178099, Bank 02).
; 
; PlayerCharacterDef spawns it with SpawnAfter, so it sits right behind the player actor in the actor list and runs every frame after the player's own scripts. It never moves the player. It only edits playerSpeedEw / playerSpeedNs (and the playerFlags $1000 latch); player_move_controller turns those speeds into movement (speed x 4 plus external velocity) in the same frame: the actor list order is attack, player, slope, controller, so the controller runs right after this actor.
; 
; === FRAME FLOW (SlopePhysicsEntry) ===
; 
; 1. Gate: if the player actor's $10 has bit $0080 or bit $0040 set (hit marker / orb state) and iframeCounter is not negative, slope detection is skipped and only SlopeFlatDecelerate runs.
; 2. Speed nonzero (EW or NS): probe the collision tile at (actor X, actor Y - 8) with TileProbeMain, look the type up in SlopeTileDispatch and jump to the handler. A type with no handler goes to the transition-tile test (below), otherwise to SlopeFlatExit.
; 3. Speed zero and playerFlags $1000 set: reset both step counters and probe four cells (below). A slope found runs its handler, none goes to SlopeFlatExit.
; 4. Speed zero and no latch: SlopeFlatDecelerate.
; A slope handler adds one curve value to one axis (ApplySlopeCurve*) and returns through ClampSpeeds.
; 
; === TILE TYPES (SlopeTileDispatch) ===
; 
; | Type | Handler | Pushes the player | Curve |
; |------|---------|-------------------|-------|
; | $03  | SlopeType03Handler | south (NS +) | slopeCurvePtrB |
; | $05  | SlopeType05Handler | west (EW -) | slopeCurvePtrA, negated |
; | $0A  | SlopeType0AHandler | east (EW +) | slopeCurvePtrA |
; | $0C  | SlopeType0CHandler | north (NS -) | slopeCurvePtrB, negated |
; 
; All other types (0-2, 4, 6-9, B, D-F) have a zero entry: no slope. The table holds the handler addresses; the dispatch does DEC, PHA, RTS so that the RTS lands on the handler. Whether a handler pushes DOWNHILL was not checked against the map art; the direction column is what the code does to the speed.
; 
; === CURVES ===
; 
; slopeCurvePtrA ($09BA, east-west) and slopeCurvePtrB ($09BC, north-south) both point at the start of the math_lookup_tables block, and decelCurvePtr ($09C2) at that block + $20; system_core sets them once at boot. Each curve is 16 words, read as (counter & $0F) x 2 bytes from the pointer. Default slope curve: $0001 at steps 0, 4, 8 and 12, otherwise 0, i.e. +1 speed unit every fourth frame. Default deceleration curve: $0001 at steps 7 and 15. slopeStepCounter ($09B6) advances once per frame on a slope and is cleared when the slope speed reaches zero, when SlopeFlatExit runs and on every frame of the stopped probe (so a slope always starts at step 0). decelStepCounter ($09B8) advances on EVERY ReadDecelerationStep call, including calls that return 0. maxSpeedEw / maxSpeedNs ($09C8 / $09CA) are set to 9 in system_core and not written again in the extracted code; ClampSpeeds limits |speed| to max - 1 = 8.
; 
; === THE $1000 ON-SLOPE LATCH (playerFlags) ===
; 
; Set by the ramp walkers (player_move_ramps, player_move_west) while the player traverses a ramp and by these handlers when a slope curve brings an axis speed to exactly zero. Cleared by player_move_controller whenever the EW or the NS speed is nonzero, and by SlopeFlatDecelerate when EW speed is zero. While it is set player_move_controller drops the joypad velocity, DecelerateEW / DecelerateNS return at once, the Aura Barrier cannot be used and the walk code skips its L/R block check. By this reading a player at rest on the latch gets no joypad movement: the four-cell probe finds the slope again, the first curve step (+1 or -1) gives a nonzero speed, and the next controller pass clears the latch.
; 
; === TRANSITION TILES $06 AND $09 ===
; 
; If the tile under the probe has no handler but is type $06 or $09, the code looks at two other cells with MapCellDown (one map row below the probe tile) and then MapCellUp (one row above), both relative to the index TileProbeMain left in $00. A type $05 or $0A in either cell runs that handler; otherwise SlopeFlatExit. The earlier text said "right and left adjacent cells"; MapCellDown/Up step by rows (+/-$10), MapCellRight/Left by columns.
; 
; === STOPPED-ON-SLOPE PROBE ===
; 
; Four cells are tested in this order: the probe cell, the cell to its RIGHT (MapCellRight), the cell BELOW it (MapCellDown) and the cell below-right (MapCellRight from the new base; the code stores the new index in $00 after MapCellDown). The first slope type found runs its handler. The probe point here is playerXPos / playerYPos (camera_scroll_controller writes actor X - 8 and actor Y - $10 there), while the moving probe uses (actor X, actor Y - 8); the two phases therefore look at different points (open question).
; 
; === DECELERATION (SlopeFlatDecelerate, DecelerateEW / DecelerateNS) ===
; 
; SlopeFlatDecelerate decelerates the EW axis when EW speed is nonzero and then returns; the NS axis is only handled on a frame in which EW speed is already zero (after clearing the $1000 latch). Per axis: skipped while the latch is set; |speed| < 3 is set to zero at once (the step counter is not reset); otherwise a D-pad bit for the direction of travel suppresses deceleration, else one curve value is subtracted (added for negative speeds) and, whether that step was applied or returned 0, a D-pad bit for the opposite direction applies a second curve value (braking). Reaching zero resets decelStepCounter in the EW routine; the NS routine resets slopeStepCounter instead (probable copy slip, open question).
; 
; === OTHER QUIRKS (open questions) ===
; 
; ClampSpeeds examines the NS speed only when EW speed is zero. ReadDecelerationStepNS is a byte-for-byte copy of ReadDecelerationStep (same counter, same curve). slopeFracAccum ($09C6) is the sub-pixel accumulator of the north/south slope walkers (player_move_south, player_move_ns); this file only clears it (SlopeFlatExit), as player_move_controller does when the NS speed is zero.
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

; Per-frame entry of the companion actor (see the block note for the four paths). X is saved around the player-flag gate. When the actor has speed it saves D, sets D = 0 for TileProbeMain's work area ($1A = pixel X, $1E = pixel Y, tile index in $00) and probes (actor X, actor Y - 8). The collision type, doubled, indexes SlopeTileDispatch: a nonzero entry is the handler (DEC, PHA, RTS dispatch), zero means no slope. For types $06 and $09 the cells one row below and one row above the probe tile are tested for $05 / $0A. With zero speed and the $1000 latch it clears slopeStepCounter and decelStepCounter, probes the current, right, below and below-right cells at playerXPos / playerYPos and dispatches the first slope found; otherwise it ends in SlopeFlatExit.

SlopePhysicsEntry {
    COP [SetEntryHere]    ; Slope physics companion: runs each frame after player_move_controller
    PHX                   ; Gate: bit $0080 (hit marker) or $0040 (orb state) in the player actor's $10
    LDX $playerActor
    LDA $0010, X
    BIT #$00C0
    BEQ loc_02B443
    LDA $iframeCounter, X ; Negative iframe counter (recovery) lets slope physics run; positive = hit-stun
    BMI loc_02B443
    PLX 
    JMP $&SlopeFlatDecelerate ; Hit-stun or orb state: skip slope detection, only decelerate

  loc_02B443:
    PLX 
    LDA $playerSpeedEw    ; Check if player has any active speed (EW or NS nonzero)
    ORA $playerSpeedNs
    BEQ loc_02B4C0        ; No speed → check the on-slope flag ($1000) for stopped-on-slope multi-cell probe
    PHX                   ; Has speed → begin slope tile detection
    PHD 
    LDA #$0000            ; Set DP to $0000 for tile_collision work area access ($1A, $1E)
    TCD 
    LDY $playerActor
    LDA $0014, Y          ; Probe X = player actor X ($14)
    STA $1A
    LDA $0016, Y
    SEC                   ; Player Y minus 8 pixels → probe at feet level (player hotspot is 8px above base)
    SBC #$0008            ; Probe Y = player actor Y ($16) - 8
    STA $1E
    JSR $&tile_collision.TileProbeMain ; TileProbeMain: map index into $00, collision type in A (actor solid marks read as $0F)
    AND #$00FF
    ASL 
    TAX 
    LDA $@SlopeTileDispatch, X ; Look up slope handler in SlopeTileDispatch by collision type
    BEQ loc_02B474        ; Zero table entry = type without a slope handler; nonzero falls through to the dispatch
    DEC                   ; The table holds the handler address; DEC so that the return below lands on it
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
    JSR $&tile_collision.MapCellDown ; Transition tile: test the cell one map row BELOW the probe tile (MapCellDown = +1 row)
    SEP #$20
    JSR $&tile_collision.ReadCollisionNibble ; Read the collision type at map index X
    REP #$20
    AND #$00FF
    CMP #$0005
    BNE loc_02B498
    JMP $&SlopeType05Handler

  loc_02B498:
    CMP #$000A            ; Cell below is type $0A: east handler
    BNE loc_02B4A0
    JMP $&SlopeType0AHandler

  loc_02B4A0:
    JSR $&tile_collision.MapCellUp ; Cell below is no slope: test the cell one row ABOVE the probe tile (MapCellUp)
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
    JMP $&SlopeFlatExit   ; Neither the cell below nor the cell above is a slope

  loc_02B4C0:
    LDA $playerFlags      ; Zero speed path: check $1000 flag (stopped on slope)
    BIT #$1000
    BNE loc_02B4CB
    JMP $&SlopeFlatDecelerate ; No $1000 flag → normal flat-ground deceleration

  loc_02B4CB:
    STZ $slopeStepCounter ; Stopped on the latch: both counters restart every frame, so a slope always starts at step 0
    STZ $decelStepCounter
    PHX 
    PHD 
    LDY $playerActor
    LDA $playerXPos       ; Probe point = playerXPos / playerYPos (camera_scroll_controller: actor X - 8, actor Y - $10)
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
    JSR $&tile_collision.MapCellRight ; Probe 2: the cell to the RIGHT (+1 column from the probe cell)
    SEP #$20
    JSR $&tile_collision.ReadCollisionNibble
    REP #$20
    AND #$00FF
    ASL 
    TAX 
    LDA $@SlopeTileDispatch, X
    BNE loc_02B535
    JSR $&tile_collision.MapCellDown ; Probe 3: the cell BELOW (+1 row from the probe cell; $00 still holds the probe index)
    STX $00               ; Make the cell below the base index for probe 4
    SEP #$20
    JSR $&tile_collision.ReadCollisionNibble
    REP #$20
    AND #$00FF
    ASL 
    TAX 
    LDA $@SlopeTileDispatch, X
    BNE loc_02B535
    JSR $&tile_collision.MapCellRight ; Probe 4: the cell below-right (+1 column from probe 3)
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

---------------------------------------------
; Collision type $03: apply the positive NS curve (slopeCurvePtrB) to playerSpeedNs, then ClampSpeeds, PLD, PLX, RTL. Pushes the player south.

SlopeType03Handler {
    JSR $&ApplySlopeCurvePosNS ; Type $03: positive NS curve, pushes the player south
    BRA SlopeHandlerExit
}

---------------------------------------------
; Collision type $05: apply the negated EW curve (slopeCurvePtrA) to playerSpeedEw. Pushes the player west (eastward speed shrinks, westward speed grows). Shares the exit SlopeHandlerExit (ClampSpeeds, PLD, PLX, RTL) with the other three handlers.

SlopeType05Handler {
    JSR $&ApplySlopeCurveNegEW ; Type $05: negated EW curve, pushes the player west (eastward speed shrinks, westward grows)
    BRA SlopeHandlerExit
}

---------------------------------------------
; Collision type $0A: apply the positive EW curve (slopeCurvePtrA) to playerSpeedEw. Pushes the player east. The next label SlopeType0CHandler (type $0C, negated NS curve of slopeCurvePtrB, pushes north) lives inside this block; the common exit SlopeHandlerExit calls ClampSpeeds and returns with PLD, PLX, RTL.

SlopeType0AHandler {
    JSR $&ApplySlopeCurvePosEW ; Type $0A: positive EW curve, pushes the player east
    BRA SlopeHandlerExit

  SlopeType0CHandler:
    JSR $&ApplySlopeCurveNegNS ; Type $0C: negated NS curve, pushes the player north

; Common tail after slope curve handlers in SlopeType0AHandler: calls ClampSpeeds, restores direct page and X from the entry save, returns with RTL.

  SlopeHandlerExit:
    JSR $&ClampSpeeds     ; After slope curve applied → clamp speeds to max, restore DP, exit
    PLD 
    PLX 
    RTL 
}

---------------------------------------------
; No slope under the player: ClampSpeeds, clear slopeFracAccum and slopeStepCounter, restore D and X (pushed in SlopePhysicsEntry) and fall straight into SlopeFlatDecelerate, which returns with RTL. There is no RTL in this block.

SlopeFlatExit {
    JSR $&ClampSpeeds     ; Flat exit: clamp speeds, clear the slope fractional accumulator and the slope step counter
    STZ $slopeFracAccum
    STZ $slopeStepCounter
    PLD 
    PLX                   ; No RTL: execution falls into SlopeFlatDecelerate
}

---------------------------------------------
; Flat-ground deceleration entry (also reached directly from the frozen gate and the zero-speed path). EW speed nonzero: DecelerateEW and RTL, so the NS axis is not touched on that frame. EW speed zero: clear playerFlags $1000 if it is set (the player has come to rest), then DecelerateNS if the NS speed is nonzero. RTL.

SlopeFlatDecelerate {
    LDA $playerSpeedEw    ; EW speed nonzero: decelerate EW and return (NS waits until EW is zero)
    BEQ loc_02B564        ; No EW speed → check for the on-slope flag before NS deceleration
    JSR $&DecelerateEW
    RTL 

  loc_02B564:
    LDA $playerFlags      ; EW speed is zero: clear the $1000 latch if it is set
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
; 16-word table indexed by collision type x 2. Types $03, $05, $0A and $0C hold the address of a slope handler; the rest are $0000. SlopePhysicsEntry reads it with a long-indexed LDA, then DEC, PHA, RTS dispatches (the table stores the handler address itself; the DEC makes the RTS land on it).

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
; Read the curve word at slopeCurvePtrA + (slopeStepCounter & $0F) x 2, negate it and add it to playerSpeedEw. A result of exactly zero jumps to SlopeSpeedZeroLatch (shared by all four curve routines: clear slopeStepCounter and set the $1000 latch); otherwise slopeStepCounter is incremented. Default curve: +1 every fourth step.
; ApplySlopeCurvePosEW, ApplySlopeCurvePosNS and ApplySlopeCurveNegNS are the same routine for the positive EW curve, the positive NS curve (slopeCurvePtrB, playerSpeedNs) and the negated NS curve.

ApplySlopeCurveNegEW {
    LDA $slopeStepCounter ; Read slope curve table at slopeCurvePtrA, index by slopeStepCounter mod 16, negate and add to EW speed
    AND #$000F
    ASL 
    CLC 
    ADC $slopeCurvePtrA
    TAY 
    LDA $0000, Y          ; Curve word: table at slopeCurvePtrA, read through the data bank
    EOR #$FFFF            ; Negate the curve word (EOR #$FFFF + INC): the west slope pushes playerSpeedEw toward negative
    INC 
    CLC 
    ADC $playerSpeedEw
    STA $playerSpeedEw
    BEQ SlopeSpeedZeroLatch ; Speed reached zero → stopped on slope (set $1000 flag)
    INC $slopeStepCounter ; Speed still nonzero → advance step counter for next frame
    RTS 
}

---------------------------------------------
; Positive EW curve (slopeCurvePtrA): add the curve word to playerSpeedEw (eastward). Speed zero -> SlopeSpeedZeroLatch (clear slopeStepCounter, set $1000); otherwise slopeStepCounter + 1. The label SlopeSpeedZeroLatch sits in this block but is also the target of the three sibling routines.

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
    BEQ SlopeSpeedZeroLatch
    INC $slopeStepCounter
    RTS 

; Shared zero-speed branch from ApplySlopeCurvePosEW and NS helpers: clears slopeStepCounter, sets playerFlags bit $1000 (stopped on slope), returns with RTS to the caller.

  SlopeSpeedZeroLatch:
    STZ $slopeStepCounter ; Speed zeroed: reset slope step counter, set $1000 flag (stopped-on-slope), return
    LDA #$1000
    TSB $playerFlags
    RTS 
}

---------------------------------------------
; Positive NS curve (slopeCurvePtrB): add the curve word to playerSpeedNs (southward). Speed zero -> SlopeSpeedZeroLatch; otherwise slopeStepCounter + 1.

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
    BEQ SlopeSpeedZeroLatch
    INC $slopeStepCounter
    RTS 
}

---------------------------------------------
; Negated NS curve (slopeCurvePtrB): subtract the curve word from playerSpeedNs (northward). Speed zero -> SlopeSpeedZeroLatch; otherwise slopeStepCounter + 1.

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
    BEQ SlopeSpeedZeroLatch
    INC $slopeStepCounter
    RTS 
}

---------------------------------------------
; Limit |speed| to maxSpeed - 1 (8 with the default maximum of 9). EW first: nonzero speed is compared (negated when negative) and clamped; the routine then returns without looking at NS. NS is only examined when the EW speed is zero. Called after every slope handler and from SlopeFlatExit.

ClampSpeeds {
    LDA $playerSpeedEw    ; Clamp to +-(max - 1); NS is only examined when the EW speed is zero
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
; EW flat-ground deceleration (details in the block note). Return at once while the $1000 latch is set. |speed| < 3 -> speed = 0 (decelStepCounter not reset). Positive speed: D-pad right ($0100) held -> return; otherwise one ReadDecelerationStep value is subtracted (speed 0 -> reset decelStepCounter, return), then, also when that value was 0, D-pad left ($0200) held applies a second step. Negative speed mirrors this with left suppressing and right braking. Each ReadDecelerationStep call advances decelStepCounter, so braking uses the curve twice per frame.

DecelerateEW {
    LDA $playerFlags      ; Return at once while the $1000 on-slope latch is set
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
    STZ $playerSpeedEw    ; Zero speed: decelStepCounter is not reset on this path
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
    BEQ DecelResetCounterEW ; Speed zeroed → reset decel counter

  loc_02B6B0:
    LDA $joypadCurrent    ; After the first step (applied or zero): west D-pad held -> second, braking step
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
    BEQ DecelResetCounterEW
    RTS 

; Tail inside DecelerateEW when east-west speed reaches zero after a decel step: clears decelStepCounter and returns with RTS; also used from the west-moving decel paths.

  DecelResetCounterEW:
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
    BEQ DecelResetCounterEW

  loc_02B6E8:
    LDA $joypadCurrent    ; After the first step (applied or zero): east D-pad held -> second, braking step
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
    BEQ DecelResetCounterEW
    RTS 
}

---------------------------------------------
; Return in A the curve word at decelCurvePtr + (decelStepCounter & $0F) x 2 (flags set from A: zero = no deceleration this step) and increment decelStepCounter, whether or not the word is zero. Default curve: $0001 at steps 7 and 15.

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

---------------------------------------------
; NS counterpart of DecelerateEW: same latch test, |speed| < 3 snap, same-direction suppression (down $0400 for positive speed, up $0800 for negative), one step plus a braking step for the opposite D-pad direction. Difference: when the speed reaches zero it clears slopeStepCounter (loc_02B76C) where DecelerateEW clears decelStepCounter, so after an NS stop the deceleration curve keeps its position.

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
    LDA $joypadCurrent    ; After the first step (applied or zero): north D-pad ($0800) held -> braking step
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
    STZ $slopeStepCounter ; NS stopped: clears slopeStepCounter (the EW routine clears decelStepCounter), probably a copy slip
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
    LDA $joypadCurrent    ; After the first step (applied or zero): south D-pad held -> second, braking step
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

---------------------------------------------
; Exact copy of ReadDecelerationStep for the NS routine: same decelStepCounter, same decelCurvePtr, same result. It could simply be a JSR to ReadDecelerationStep.

ReadDecelerationStepNS {
    LDA $decelStepCounter ; Exact copy of ReadDecelerationStep: the same decelStepCounter and curve
    INC $decelStepCounter
    AND #$000F
    ASL 
    CLC 
    ADC $decelCurvePtr
    TAY 
    LDA $0000, Y
    RTS 
}