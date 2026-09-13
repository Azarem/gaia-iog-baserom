; North-south movement collision — handles upward (north) player movement dispatch, wall interaction, slope physics, and wall-slide correction (184376–184902, Bank 02).
; 
; Contains the DispatchNorthMove entry point called from PlayerMovementTick for negative $24 (NS velocity). The complementary south movement dispatch (DispatchSouthMove) is in player_move_ew.
; 
; === DISPATCH STRUCTURE ===
; 
; DispatchNorthMove: Probes top tiles (CurrentTL, CurrentTR, FutureTL) to detect collision, interaction, and slope tiles above the player.
; 
; Dispatch chain:
;   CurrentTL $06 (south wall) → SouthWallHandler (wall blocks northward entry)
;   CurrentTL $03 → NorthSlopeRight (right-descending slope at TL)
;   CurrentTL $0C → NorthSlopeLeft (left-descending slope at TL)
;   CurrentTR $09 (north wall) → NorthWallHandler
;   FutureTL ≥ $0E or $08 → blocked wall (SetActorCollisionFlag + AutoAlignEW + snap)
;   FutureTL $02 → NorthInteractTile (ladder → LadderClimbSouth)
;   FutureTL $06 → SouthWallNudge (nudge/redirect for south wall ahead)
;   FutureTL $09 + sub-tile → NorthProbeRedirect
;   Sub-tile aligned: MapCellDown secondary probe for $0E/$08/$02/$09/$06
; 
; Non-blocked path: $26 += $24 (apply negative NS velocity → Y decreases → player moves up).
; 
; === COLLISION SNAPPING ===
; 
; SnapYNorthCollision: $26 = ($24+$26) AND $FFC0 + $0040. Snaps Y upward to the bottom edge of the blocking tile (rounds down to 64px boundary then adds one 64px step). Zeroes $24 and playerSpeedNs. Shares the snap calculation with the AutoAlignEW success path.
; 
; === SLOPE PHYSICS ===
; 
; NorthSlopeRight ($03) and NorthSlopeLeft ($0C): Both verify the adjacent corner tile matches the same slope type. The sub-tile position is computed as ($10 − (($26+$24)>>2 & $0F)) via SBC $10 / EOR $FF / INC — an inverted offset measuring distance from the TOP of the tile. If < $08 (upper half), movement is applied directly; otherwise the slope flag ($09AF bit $10) is set.
; 
; NorthSlopeLeft includes slopeFracAccum ($09C6) fractional physics, but with inverted sign handling since $24 is negative: the velocity is negated before >>4 extraction, and the integer result is re-negated back to negative for $24.
; 
; === WALL HANDLERS ===
; 
; SouthWallHandler ($06 at TL): Checks BR for double-$06 (fully enclosed → ClearMovementDeltas). Probes FutureTL with sub-tile alignment, then MapCellDown/Right adjacency chain. SnapXDiagCollision fallback. ComputeYSnapOffset + FineAdjustXWest for wall sliding (player slides west along south wall).
; 
; SouthWallNudge: Special case when FutureTL is $06. Checks $AB bit $02 (wall interaction flag) — if set and sub-tile X aligned, zeroes $24 and applies deltas (stops NS, keeps EW). Otherwise: MapCellDown → solid → SnapYSouthCollision; non-solid → SouthWallHandler adjacency chain.
; 
; NorthWallHandler ($09 at TR): Checks BL for double-$09 → ClearMovementDeltas. FutureTR with alignment, MapCellUp/Right adjacency. SnapXEastCollision fallback (snaps X). SnapYSouthCollision if re-probe fails. ComputeYSnapOffset + FineAdjustXEast (player slides east along north wall).
; 
; NorthProbeRedirect: Bridge routine when sub-tile check finds $09 — probes MapCellRight then falls into NorthWallHandler's adjacency chain.
---------------------------------------------

?BANK 02

?INCLUDE 'player_character'
?INCLUDE 'player_move_diag'
?INCLUDE 'player_move_east'
?INCLUDE 'player_move_main'
?INCLUDE 'player_move_south'
?INCLUDE 'tile_collision'

!playerActor                    09AA
!playerSpeedNs                  09B4
!slopeFracAccum                 09C6

---------------------------------------------

; Main entry for negative $24 (NS velocity) — dispatches upward (north) movement collision.
; 
; Probes top tiles in priority order:
;   CurrentTL (with carry set): $06 → SouthWallHandler, $03 → NorthSlopeRight, $0C → NorthSlopeLeft
;   CurrentTR: $09 → NorthWallHandler
;   FutureTL: ≥$0E or $08 → blocked wall, $02 → NorthInteractTile, $06 → SouthWallNudge, $09 → NorthProbeRedirect
; 
; Sub-tile aligned path: MapCellDown reads the cell below the future tile for additional $0E/$08/$02/$09/$06 checks.
; 
; Blocked wall handler (loc_02D0AF): SetActorCollisionFlag → AutoAlignEW (X nudge) → SnapYNorthCollision if no nudge applied.
; 
; Non-blocked path: $26 += $24 (negative velocity decreases Y → player moves up).

DispatchNorthMove {
    SEP #$20              ; DispatchNorthMove: north/-Y movement collision dispatch — 8-bit probe mode
    JSR $&tile_collision.ProbeCurrentTL ; Probe current top-left tile at player leading north corner; BCC = no TL collision
    BCC loc_02D054
    CMP #$06              ; Type $06 south-facing wall at current TL → SouthWallHandler
    BNE loc_02D046
    JMP $&SouthWallHandler

  loc_02D046:
    CMP #$03              ; Type $03 right-ascending slope at current TL → NorthSlopeRight
    BNE loc_02D04D
    JMP $&NorthSlopeRight

  loc_02D04D:
    CMP #$0C              ; Type $0C left-ascending slope at current TL → NorthSlopeLeft
    BNE loc_02D054
    JMP $&NorthSlopeLeft

  loc_02D054:
    JSR $&tile_collision.ProbeCurrentTR ; Probe current top-right corner for complementary north-wall check
    CMP #$09              ; Type $09 north-facing wall at current TR → NorthWallHandler
    BNE loc_02D05E
    JMP $&NorthWallHandler

  loc_02D05E:
    JSR $&tile_collision.ProbeFutureTL ; Probe destination top-left tile one step north (FutureTL)
    CMP #$0E              ; Solid tile: collision nibble ≥ $0E blocks north entry
    BCS loc_02D0AF
    CMP #$08              ; Type $08 stairs/vine at destination → block north entry
    BEQ loc_02D0AF
    CMP #$02              ; Type $02 ladder at destination → NorthInteractTile climb transition
    BEQ NorthInteractTile
    CMP #$06              ; Type $06 south wall at destination → SouthWallNudge
    BNE loc_02D074
    JMP $&SouthWallNudge

  loc_02D074:
    JSR $&tile_collision.CheckSubTileAlignX ; CheckSubTileAlignX: is player X-sub-tile aligned for wall slide?
    BCS loc_02D082
    CMP #$09              ; X aligned + destination north wall $09 → NorthProbeRedirect
    BNE loc_02D080
    JMP $&NorthProbeRedirect

  loc_02D080:
    BRA loc_02D0A5

  loc_02D082:
    CMP #$09              ; X misaligned + north wall $09 below path → hard block
    BEQ loc_02D0AF
    JSR $&tile_collision.MapCellRight ; MapCellDown: secondary probe on tile directly below misaligned destination
    STX $00
    JSR $&tile_collision.ReadCollisionNibble
    CMP #$0E              ; Solid ($0E+) below → block north movement
    BCS loc_02D0AF
    CMP #$08              ; Stairs ($08) below → block
    BEQ loc_02D0AF
    CMP #$02              ; Ladder ($02) below → block (must align X first)
    BEQ loc_02D0AF
    CMP #$09              ; North wall ($09) below → NorthProbeRedirect adjacency chain
    BNE loc_02D0A1
    JMP $&NorthProbeRedirect

  loc_02D0A1:
    CMP #$06              ; South wall ($06) below while misaligned → hard block
    BEQ loc_02D0AF

  loc_02D0A5:
    REP #$20
    LDA $26               ; Unblocked north move: $26 (Y sub-pixel) += $24 (NS velocity)
    CLC 
    ADC $24
    STA $26
    RTS 

  loc_02D0AF:
    JSR $&tile_collision.SetActorCollisionFlag ; North blocked: set actor collision-contact flag for this frame
    JSR $&player_move_main.AutoAlignEW ; AutoAlignEW: try X-axis ($22) grid nudge before hard snap
    BCS SnapYNorthCollision ; X nudge failed (carry set) → SnapYNorthCollision Y-snap path
    PHP 
    REP #$20
    BRA loc_02D0C2

; Snap Y position upward after north movement wall collision.
; 
; Zeroes playerSpeedNs ($09B4). Computes $26 = ($24+$26) AND $FFC0 + $0040 — rounds Y down to the 64px grid boundary, then adds one 64px step to place the player just below the tile they collided with.
; 
; Shares the snap path at loc_02D0C2 with DispatchNorthMove's AutoAlignEW success path (which enters without zeroing playerSpeedNs).

  SnapYNorthCollision:
    PHP 
    REP #$20
    STZ $playerSpeedNs    ; SnapYNorthCollision: zero $playerSpeedNs on hard Y snap

  loc_02D0C2:
    LDA $24               ; Snap Y up: ($24+$26) to 64px grid ceiling (AND #$FFC0 + $0040), clear fractional $24
    CLC 
    ADC $26
    AND #$FFC0
    CLC 
    ADC #$0040
    STA $26
    STZ $24
    PLP 
    RTS 

; Ladder interaction during north movement.
; 
; Guard: CheckSubTileAlignX — if past the sub-tile boundary (carry set), treat as blocked wall. Otherwise: sets player actor state ($0000,Y) to LadderClimbSouth and zeroes sub-state ($0008,Y), then falls into the blocked wall handler for position snapping.
; 
; Local label within the DispatchNorthMove brace group.

  NorthInteractTile:
    JSR $&tile_collision.CheckSubTileAlignX ; Ladder tile ($02): require X sub-tile alignment before climbing
    BCS loc_02D0AF
    PHY 
    LDY $playerActor
    REP #$20
    LDA #$&player_character.LadderClimbSouth ; Switch player state to LadderClimbSouth (north approach onto ladder)
    STA $0000, Y
    LDA #$0000            ; Clear actor movement sub-state (+$0008) for clean climb entry
    STA $0008, Y
    PLY 
    BRA loc_02D0AF
}

---------------------------------------------
; Right-descending slope ($03) during north movement.
; 
; Verifies CurrentTR is also $03 (consistent slope across both corners). If TR doesn't match → blocked wall. Checks sub-tile Y alignment and MapCellRight adjacency: if the right neighbor is also $03, skip the position check.
; 
; Sub-tile position: ($26+$24) >> 2, AND $0F, then inverted from top (SBC $10, EOR $FF, INC → distance from top of tile). If < $08 (player in upper half), applies movement deltas directly. Otherwise sets $09AF bit $10 (slope flag) and applies deltas.

NorthSlopeRight {
    JSR $&tile_collision.ProbeCurrentTR ; Right slope ($03): verify matching $03 at current TR corner
    CMP #$03
    BNE loc_02D0AF
    JSR $&tile_collision.CheckSubTileAlignY ; CheckSubTileAlignY: Y sub-tile position gates slope traversal
    BCC loc_02D11A
    JSR $&tile_collision.MapCellDown ; MapCellRight: adjacent cell must also be $03 for smooth slope continue
    JSR $&tile_collision.ReadCollisionNibble
    CMP #$03
    BEQ loc_02D11A
    LDA $26               ; Compute inverted Y sub-tile: ($26+$24)>>2 & $0F → distance from tile top ($10 - offset)
    CLC 
    ADC $24
    LSR 
    LSR 
    AND #$0F
    SEC 
    SBC #$10
    EOR #$FF
    INC 
    CMP #$08              ; Distance < $08 (upper half) → ApplyMovementDeltas without snap flag
    BPL loc_02D11A
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02D11A:
    LDA #$10              ; Distance ≥ $08: set slope snap flag bit $10 in $09AF, then apply movement
    TSB $09AF
    JMP $&tile_collision.ApplyMovementDeltas
}

---------------------------------------------
; Left-descending slope ($0C) during north movement, with fractional accumulation.
; 
; Same initial structure as NorthSlopeRight: verify TR matches $0C, check sub-tile Y alignment and MapCellRight adjacency.
; 
; Fractional slope physics (inverted for negative velocity):
;   1. Clamp slopeFracAccum to non-positive (positive → zero, using BMI/STZ). Opposite polarity from EastSlopeLeft since $24 is negative.
;   2. Add $24 to accumulator, then negate (EOR $FFFF, INC) to get magnitude
;   3. Extract integer part (>>4): if nonzero, use as positive $24 magnitude
;   4. Subtract consumed integer (<<4) from accumulator (ADD, keeping negative sign)
;   5. Negate the extracted integer back to negative for $24 (EOR $FFFF, INC)
; 
; Produces smooth diagonal movement on steep slopes with sub-pixel fractional tracking.

NorthSlopeLeft {
    JSR $&tile_collision.ProbeCurrentTR ; Left slope ($0C): verify matching $0C at current TR corner
    CMP #$0C
    BNE loc_02D0AF
    JSR $&tile_collision.CheckSubTileAlignY ; CheckSubTileAlignY for left-slope traversal gate
    BCC loc_02D14E
    JSR $&tile_collision.MapCellDown ; MapCellRight adjacency: neighbor must be $0C for continued slope
    JSR $&tile_collision.ReadCollisionNibble
    CMP #$0C
    BEQ loc_02D14E
    LDA $24               ; Y sub-tile threshold test: ($24+$26)>>2 & $0F inverted vs $08
    CLC 
    ADC $26
    LSR 
    LSR 
    AND #$0F
    SEC 
    SBC #$10
    EOR #$FF
    INC 
    CMP #$08
    BPL loc_02D14E
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02D14E:
    LDA #$10              ; Slope snap flag bit $10 when sub-tile in lower half
    TSB $09AF
    REP #$20
    LDA $slopeFracAccum   ; Left-slope fractional step: clamp positive $slopeFracAccum to zero (north = negative velocity)
    BMI loc_02D15D
    STZ $slopeFracAccum

  loc_02D15D:
    LDA $24               ; Accumulate NS velocity $24 into $slopeFracAccum (sub-pixel slope storage)
    CLC 
    ADC $slopeFracAccum
    STA $slopeFracAccum
    EOR #$FFFF            ; Negate accumulator before >>4 — north velocity is negative
    INC 
    LSR 
    LSR 
    LSR 
    LSR 
    BEQ loc_02D185        ; Extract integer pixel step: |$slopeFracAccum| >> 4; zero → skip fraction adjust
    STA $24               ; Store negated pixel step back into $24 for ApplyMovementDeltas
    ASL 
    ASL 
    ASL 
    ASL 
    CLC                   ; Subtract consumed fraction: (step<<4), add back to $slopeFracAccum
    ADC $slopeFracAccum
    STA $slopeFracAccum
    LDA $24               ; Re-negate final $24 pixel delta for northward movement
    EOR #$FFFF
    INC 
    STA $24

  loc_02D185:
    JMP $&tile_collision.ApplyMovementDeltas
}

---------------------------------------------
; South-wall ($06) interaction during north movement — handles CurrentTL being a south-wall tile.
; 
; First checks CurrentBR: if also $06 → ClearMovementDeltas (player enclosed between two south walls). Otherwise: ProbeFutureTL with sub-tile Y alignment.
;   - Aligned + FutureTL $06: MapCellDown/MapCellRight adjacency chain — if either nonzero → ClearSpeedNS_1. If both zero → ComputeYSnapOffset + FineAdjustXWest (slide west along south wall).
;   - Not aligned: SnapXDiagCollision, re-probe FutureTL — if $06 → compute snap. Otherwise → zero $24, SnapYSouthCollision, ApplyMovementDeltas.

SouthWallHandler {
    JSR $&tile_collision.ProbeCurrentBR ; South wall ($06) during north move: probe current bottom-right for continuous wall
    CMP #$06              ; BR also $06 → fully blocked; ClearMovementDeltas
    BNE loc_02D192
    JMP $&tile_collision.ClearMovementDeltas

  loc_02D192:
    JSR $&tile_collision.ProbeFutureTL ; ProbeFutureTL + CheckSubTileAlignY: can player slide past south-wall edge?
    JSR $&tile_collision.CheckSubTileAlignY
    BCC loc_02D1B2
    CMP #$06              ; Future TL must be $06 south wall for slide-along-wall path
    BNE loc_02D1B2

  loc_02D19E:
    JSR $&tile_collision.MapCellRight ; Gap probe: MapCellDown below south wall — empty cell allows passthrough
    STX $00
    JSR $&tile_collision.ReadCollisionNibble
    BNE ClearSpeedNS_1
    JSR $&tile_collision.MapCellDown ; MapCellRight from gap cell — both must be walkable or clear NS speed
    JSR $&tile_collision.ReadCollisionNibble
    BNE ClearSpeedNS_1
    BRA loc_02D1C6

  loc_02D1B2:
    JSR $&player_move_diag.SnapXDiagCollision ; No gap: SnapXDiagCollision adjusts X before re-testing destination
    JSR $&tile_collision.ProbeFutureTL ; Re-probe FutureTL after diagonal X snap
    CMP #$06              ; Still south wall at TL → take open slide path
    BEQ loc_02D1C6

  loc_02D1BC:
    REP #$20
    STZ $24               ; Still blocked: zero fractional $24, SnapYSouthCollision for Y grid snap
    JSR $&player_move_south.SnapYSouthCollision
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02D1C6:
    REP #$20
    JSR $&player_move_main.ComputeYSnapOffset ; Open south-wall slide: ComputeYSnapOffset + FineAdjustXWest
    JMP $&player_move_south.FineAdjustXWest
}

---------------------------------------------
; Special south-wall nudge when FutureTL is $06.
; 
; Guard: $AB bit $02 (wall interaction flag from prior collision pass). If set AND sub-tile X aligned (CheckSubTileAlignX carry clear): zero $24 and apply deltas immediately — stops NS movement while preserving EW velocity for diagonal cases.
; 
; Otherwise: MapCellDown → if ≥ $0E (solid wall) → redirect to SnapYSouthCollision path (loc_02D1BC). If non-solid → redirect to SouthWallHandler's adjacency chain (loc_02D19E) for MapCellDown/Right gap checking.

SouthWallNudge {
    LDA $AB               ; SouthWallNudge: $AB bit $02 set → special aligned push path
    BIT #$02
    BEQ loc_02D1E0
    JSR $&tile_collision.CheckSubTileAlignX ; Require X sub-tile alignment for fast zero-$24 nudge
    BCS loc_02D1E0
    REP #$20
    STZ $24               ; Aligned nudge: zero $24, apply remaining movement without Y snap
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02D1E0:
    JSR $&tile_collision.MapCellRight ; MapCellDown from future TL for south-wall boundary case
    JSR $&tile_collision.ReadCollisionNibble
    CMP #$0E              ; Solid ≥ $0E below → redirect to hard Y-snap + apply path
    BCS loc_02D1BC
    BRA loc_02D19E        ; Passable below → join south-wall gap probe chain (loc_02D19E)

; Zero playerSpeedNs ($09B4) and return. Instance 1 — used by SouthWallHandler's MapCellDown/Right adjacency checks when an impassable neighbor is found.

  ClearSpeedNS_1:
    REP #$20              ; Gap found under south wall lip: clear $playerSpeedNs
    STZ $playerSpeedNs
    RTS 
}

---------------------------------------------
; North-wall ($09) interaction during north movement — handles CurrentTR being a north-wall tile.
; 
; First checks CurrentBL: if also $09 → ClearMovementDeltas (enclosed between two north walls). Otherwise: ProbeFutureTR with sub-tile Y alignment.
;   - Aligned + FutureTR $09: MapCellUp/MapCellRight adjacency — if either nonzero → ClearSpeedNS_2. If both zero → ComputeYSnapOffset + FineAdjustXEast (slide east along north wall).
;   - Not aligned: SnapXEastCollision (snap X from player_move_ew), re-probe FutureTR — if $09 → compute snap. Otherwise → zero $24, SnapYSouthCollision, ApplyMovementDeltas.

NorthWallHandler {
    JSR $&tile_collision.ProbeCurrentBL ; North wall ($09) during north move: probe current bottom-left for continuous wall
    CMP #$09              ; BL also $09 → fully blocked; ClearMovementDeltas
    BNE loc_02D1FC
    JMP $&tile_collision.ClearMovementDeltas

  loc_02D1FC:
    JSR $&tile_collision.ProbeFutureTR ; ProbeFutureTR + CheckSubTileAlignY for north-wall slide eligibility
    JSR $&tile_collision.CheckSubTileAlignY
    BCC loc_02D21C
    CMP #$09              ; Future TR must be $09 north wall
    BNE loc_02D21C

  loc_02D208:
    JSR $&tile_collision.MapCellLeft ; Gap probe: MapCellUp above north-wall lip — walkable cell allows passthrough
    STX $00
    JSR $&tile_collision.ReadCollisionNibble
    BNE ClearSpeedNS_2
    JSR $&tile_collision.MapCellDown ; MapCellRight from gap — both cells must be open or clear NS speed
    JSR $&tile_collision.ReadCollisionNibble
    BNE ClearSpeedNS_2
    BRA loc_02D230

  loc_02D21C:
    JSR $&player_move_east.SnapXEastCollision ; No gap: SnapXEastCollision adjusts X before re-testing destination
    JSR $&tile_collision.ProbeFutureTR ; Re-probe FutureTR after east X snap
    CMP #$09              ; Still north wall at TR → take open slide path
    BEQ loc_02D230
    REP #$20
    STZ $24               ; Still blocked: zero fractional $24, SnapYSouthCollision for Y grid snap
    JSR $&player_move_south.SnapYSouthCollision
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02D230:
    REP #$20
    JSR $&player_move_main.ComputeYSnapOffset ; Open north-wall slide: ComputeYSnapOffset + FineAdjustXEast
    JMP $&player_move_south.FineAdjustXEast
}

---------------------------------------------
; Bridge routine when sub-tile alignment finds $09 during north movement.
; 
; Probes MapCellRight + ReadCollisionNibble at the future position, then falls into NorthWallHandler's MapCellUp adjacency chain at loc_02D208. This provides an alternate entry point that bypasses the initial FutureTR probe since $09 was already confirmed by the caller.

NorthProbeRedirect {
    JSR $&tile_collision.MapCellDown ; Extended north-wall probe: MapCellRight from future TL destination
    JSR $&tile_collision.ReadCollisionNibble
    BRA loc_02D208        ; Bridge into NorthWallHandler gap probe chain at loc_02D208

; Zero playerSpeedNs and return. Instance 2 — used by NorthWallHandler's MapCellUp/Right adjacency checks.

  ClearSpeedNS_2:
    REP #$20              ; Gap found above north wall lip: clear $playerSpeedNs
    STZ $playerSpeedNs
    RTS 
}