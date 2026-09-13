; South (downward) movement collision dispatch and grid alignment (185206–186076, Bank 02).
; 
; Handles positive $24 (NS velocity) movement — the player moving downward on screen. DispatchSouthMove probes bottom tiles (CurrentBL, CurrentBR, FutureBL) and dispatches to wall handlers, slope routines, or interaction tile handlers based on collision type.
; 
; Includes: DispatchSouthMove, SouthBlockedWall, SnapYSouthCollision (Y-axis snap to 64px grid), SouthInteractTile (ladder), SouthStairsTile (vine), SouthSlopeRight/Left (slope tile dispatch), SouthWallNorthInteract/SouthWallNorthProbe (north-wall $09 handlers), SouthWallSouthInteract (south-wall $06 handler), SouthSlideJumpShim, AutoAlignEW_South (X grid nudge during south movement), ComputeSouthSnapOffset, FineAdjustXEast/FineAdjustXWest (precision X-position correction for wall sliding).
---------------------------------------------

?BANK 02

?INCLUDE 'player_character'
?INCLUDE 'player_move_diag'
?INCLUDE 'player_move_east'
?INCLUDE 'player_move_main'
?INCLUDE 'player_move_ns'
?INCLUDE 'tile_collision'

!playerActor                    09AA
!playerSpeedNs                  09B4
!slopeFracAccum                 09C6
!collisionLayer                 7FC000

---------------------------------------------

; Main entry for positive $24 (NS velocity). Probes bottom tiles (CurrentBL, CurrentBR, FutureBL) to detect wall, slope, and interaction tiles below the player.
; 
; Dispatch chain:
;   CurrentBL $09 → SouthWallNorthInteract (north-wall tile below-left)
;   CurrentBL $03 → SouthSlopeRight (right-descending slope)
;   CurrentBL $0C → SouthSlopeLeft (left-descending slope)
;   CurrentBR $06 → SouthWallSouthInteract (south-wall tile below-right)
;   FutureBL ≥ $0E → SouthBlockedWall (solid wall)
;   FutureBL $02 → SouthInteractTile (ladder)
;   FutureBL $08 → SouthStairsTile (vine)
;   FutureBL $09 → SouthWallNorthProbe (north wall ahead)
;   FutureBL $06 + sub-tile align → SouthSlideJumpShim
;   Sub-tile aligned + MapCellDown checks → additional wall/interaction tests
; 
; Non-blocked path: $26 += $24 (apply NS velocity to Y sub-pixel position).

DispatchSouthMove {
    SEP #$20              ; DispatchSouthMove: south/+Y movement collision dispatch — 8-bit probe mode
    JSR $&tile_collision.ProbeCurrentBL ; Probe current bottom-left tile at player's leading south corner
    CMP #$09              ; Type $09 north-facing wall at current BL → SouthWallNorthInteract
    BNE loc_02D382
    JMP $&SouthWallNorthInteract

  loc_02D382:
    CMP #$03              ; Type $03 right-descending slope at current BL → SouthSlopeRight
    BNE loc_02D389
    JMP $&SouthSlopeRight

  loc_02D389:
    CMP #$0C              ; Type $0C left-descending slope at current BL → SouthSlopeLeft
    BNE loc_02D390
    JMP $&SouthSlopeLeft

  loc_02D390:
    JSR $&tile_collision.ProbeCurrentBR ; Probe current bottom-right corner for complementary south-wall check
    CMP #$06              ; Type $06 south-facing wall at current BR → SouthWallSouthInteract
    BNE loc_02D39A
    JMP $&SouthWallSouthInteract

  loc_02D39A:
    JSR $&tile_collision.ProbeFutureBL ; Probe destination bottom-left tile one step south (FutureBL)
    CMP #$0E              ; Solid tile: collision nibble ≥ $0E blocks south entry
    BCC loc_02D3A4
    JMP $&SouthBlockedWall

  loc_02D3A4:
    CMP #$02              ; Type $02 ladder at destination → SouthInteractTile climb transition
    BEQ SouthInteractTile
    CMP #$08              ; Type $08 vine/stairs at destination → SouthStairsTile climb transition
    BEQ SouthStairsTile
    CMP #$09              ; Type $09 north wall at destination → extended SouthWallNorthProbe
    BNE loc_02D3B3
    JMP $&SouthWallNorthProbe

  loc_02D3B3:
    JSR $&tile_collision.CheckSubTileAlignX ; CheckSubTileAlignX: is player X-sub-tile aligned for wall slide?
    BCS loc_02D3C1
    CMP #$06              ; X aligned + destination south wall $06 → SouthSlideJumpShim redirect
    BNE loc_02D3BF
    JMP $&SouthSlideJumpShim

  loc_02D3BF:
    BRA loc_02D3E0

  loc_02D3C1:
    CMP #$06              ; X misaligned and cell below is south wall $06 → hard block
    BEQ SouthBlockedWall
    JSR $&tile_collision.MapCellRight ; MapCellDown: secondary probe on tile directly below misaligned destination
    STX $00
    JSR $&tile_collision.ReadCollisionNibble
    CMP #$0E              ; Solid ($0E+) below → block south movement
    BCS SouthBlockedWall
    CMP #$02              ; Ladder ($02) below → block (must align X first)
    BEQ SouthBlockedWall
    CMP #$06              ; South wall ($06) below while misaligned → slide shim redirect
    BNE loc_02D3DC
    JMP $&SouthSlideJumpShim

  loc_02D3DC:
    CMP #$09              ; North wall ($09) below → block south movement
    BEQ SouthBlockedWall

  loc_02D3E0:
    REP #$20              ; Unblocked south move: $26 (Y sub-pixel) += $24 (NS velocity)
    LDA $26
    CLC 
    ADC $24
    STA $26
    RTS 
}

---------------------------------------------
; Wall collision handler for DispatchSouthMove (south movement).
; 
; Calls SetActorCollisionFlag, then AutoAlignEW_South to attempt X grid alignment. If alignment succeeds (carry clear), enters the shared snap path without zeroing playerSpeedNs. If alignment fails (carry set), falls through to SnapYSouthCollision which zeroes playerSpeedNs.
; 
; The shared snap path at loc_02D3FD computes $26 = ($24+$26) AND $FFC0 (snap Y to 64px grid), then zeroes $24.

SouthBlockedWall {
    JSR $&tile_collision.SetActorCollisionFlag ; South blocked: set actor collision-contact flag for this frame
    JSR $&AutoAlignEW_South ; AutoAlignEW_South: try X-axis ($22) grid nudge before hard snap
    BCS SnapYSouthCollision ; X nudge failed (carry set) → SnapYSouthCollision Y-snap path
    PHP 
    REP #$20              ; X nudge succeeded: join shared snap math at loc_02D3FD
    BRA loc_02D3FD
}

---------------------------------------------
; Snaps the player's Y sub-pixel position to the 64px grid boundary after a wall collision during south movement. Zeroes playerSpeedNs ($09B4), then computes $26 = ($24+$26) AND $FFC0, zeroes $24.
; 
; Shares the snap calculation (loc_02D3FD) with SouthBlockedWall — the only difference is whether playerSpeedNs is zeroed (this routine) or not (SouthBlockedWall with successful alignment).

SnapYSouthCollision {
    PHP 
    REP #$20
    STZ $playerSpeedNs    ; SnapYSouthCollision: zero $playerSpeedNs on hard Y snap

  loc_02D3FD:
    LDA $24               ; Snap Y ($26): ($24+$26) down to 64px grid (AND #$FFC0), clear fractional $24
    CLC 
    ADC $26
    AND #$FFC0
    STA $26
    STZ $24
    PLP 
    RTS 

; Ladder interaction during south movement.
; 
; Guard: CheckSubTileAlignX — if already past the sub-tile boundary (carry set), treat as wall instead. Otherwise: sets the player actor's state pointer ($0000,Y) to LadderClimbNorth and zeroes the sub-state ($0008,Y), then falls through to SouthBlockedWall for position snapping.
; 
; Local label within the SouthBlockedWall/SnapYSouthCollision brace group.

  SouthInteractTile:
    JSR $&tile_collision.CheckSubTileAlignX ; Ladder tile ($02): require X sub-tile alignment before climbing
    BCS SouthBlockedWall
    PHY 
    REP #$20
    LDY $playerActor
    LDA #$&player_character.LadderClimbNorth ; Switch player state to LadderClimbNorth (south approach onto ladder)
    STA $0000, Y
    LDA #$0000            ; Clear actor movement sub-state (+$0008) for clean climb entry
    STA $0008, Y
    PLY 
    BRA SouthBlockedWall

; Vine/stairs interaction during south movement.
; 
; Guard: CheckSubTileAlignX — if aligned (carry clear), proceed directly. If past alignment, checks MapCellDown for $08 (stairs continues below); if not $08, treat as wall.
; 
; Sets playerFlags byte $09AF bit $08 (stair flag). Sets player actor state to ClimbVineEntry, zeroes sub-state. Falls through to SnapYSouthCollision (zeroes NS speed).

  SouthStairsTile:
    JSR $&tile_collision.CheckSubTileAlignX ; Vine tile ($08): X alignment required; misaligned → inspect cell below
    BCC loc_02D434
    JSR $&tile_collision.MapCellRight ; MapCellDown: vine must continue as $08 in tile below for entry
    JSR $&tile_collision.ReadCollisionNibble
    CMP #$08              ; Non-$08 below → treat as blocked wall
    BNE SouthBlockedWall

  loc_02D434:
    LDA #$08              ; Set vine-climb flag bit 8 in $09AF
    TSB $09AF
    PHY 
    LDY $playerActor
    REP #$20
    LDA #$&player_character.ClimbVineEntry ; Switch player state to ClimbVineEntry
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    PLY 
    BRA SnapYSouthCollision
}

---------------------------------------------
; Right-descending slope ($03) during south movement.
; 
; Verifies both BL and BR tiles are $03 (consistent slope). If BR doesn't match → SouthBlockedWall. Then checks sub-tile Y alignment and MapCellLeft adjacency: if the left neighbor is also $03, or if the player's sub-tile position ($24+$26, >>2, AND $0F) is in the first half (< $08), applies movement deltas directly.
; 
; Otherwise, sets $09AF bit $10 (slope flag) and applies movement deltas. The sub-tile position check prevents the player from popping onto the slope mid-tile.

SouthSlopeRight {
    JSR $&tile_collision.ProbeCurrentBR ; Right slope ($03): verify matching $03 at current BR corner
    CMP #$03
    BEQ loc_02D458
    JMP $&SouthBlockedWall

  loc_02D458:
    JSR $&tile_collision.CheckSubTileAlignY ; CheckSubTileAlignY: Y sub-tile position gates slope traversal
    BCC loc_02D477
    JSR $&tile_collision.MapCellUp ; MapCellLeft: adjacent cell must also be $03 for smooth slope continue
    JSR $&tile_collision.ReadCollisionNibble
    CMP #$03
    BEQ loc_02D477
    LDA $24               ; Compute Y sub-tile position: (Y+$24)>>2 & $0F for slope threshold test
    CLC 
    ADC $26
    LSR 
    LSR 
    AND #$0F
    CMP #$08              ; Sub-tile < $08 (upper half) → ApplyMovementDeltas without snap flag
    BPL loc_02D477
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02D477:
    LDA #$10              ; Sub-tile ≥ $08: set slope snap flag bit $10 in $09AF, then apply movement
    TSB $09AF
    JMP $&tile_collision.ApplyMovementDeltas
}

---------------------------------------------
; Left-descending slope ($0C) during south movement, with fractional slope accumulation.
; 
; Same initial structure as SouthSlopeRight: verify BR matches $0C, check sub-tile alignment and adjacency.
; 
; Uses slopeFracAccum ($09C6) for sub-pixel slope physics:
;   1. Clamp slopeFracAccum to non-negative (negative → zero)
;   2. Add $24 (NS velocity) to accumulator
;   3. Extract integer part (>>4): if nonzero, use as actual $24 velocity
;   4. Subtract the consumed integer (<<4) from accumulator to keep the fractional remainder
; 
; This produces smooth diagonal movement on steep slopes by spreading velocity across multiple frames.

SouthSlopeLeft {
    JSR $&tile_collision.ProbeCurrentBR ; Left slope ($0C): verify matching $0C at current BR corner
    CMP #$0C
    BEQ loc_02D489
    JMP $&SouthBlockedWall

  loc_02D489:
    JSR $&tile_collision.CheckSubTileAlignY ; CheckSubTileAlignY for left-slope traversal gate
    BCC loc_02D4A8
    JSR $&tile_collision.MapCellUp ; MapCellLeft adjacency: neighbor must be $0C for continued slope
    JSR $&tile_collision.ReadCollisionNibble
    CMP #$0C
    BEQ loc_02D4A8
    LDA $24               ; Y sub-tile threshold test: (Y+$24)>>2 & $0F vs $08
    CLC 
    ADC $26
    LSR 
    LSR 
    AND #$0F
    CMP #$08
    BPL loc_02D4A8
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02D4A8:
    LDA #$10              ; Slope snap flag bit $10 when sub-tile in lower half
    TSB $09AF
    REP #$20
    LDA $slopeFracAccum   ; Left-slope fractional step: clamp negative $slopeFracAccum to zero
    BPL loc_02D4B7
    STZ $slopeFracAccum

  loc_02D4B7:
    LDA $24               ; Accumulate NS velocity $24 into $slopeFracAccum (sub-pixel slope storage)
    CLC 
    ADC $slopeFracAccum
    STA $slopeFracAccum
    LSR                   ; Extract integer pixel step from accumulator: $slopeFracAccum >> 4
    LSR 
    LSR 
    LSR 
    BEQ loc_02D4D7
    STA $24
    ASL                   ; Subtract consumed fraction: negate (step<<4), add back to $slopeFracAccum
    ASL 
    ASL 
    ASL 
    EOR #$FFFF
    INC 
    CLC 
    ADC $slopeFracAccum
    STA $slopeFracAccum

  loc_02D4D7:
    JMP $&tile_collision.ApplyMovementDeltas
}

---------------------------------------------
; North-wall ($09) interaction during south movement — handles the case where CurrentBL is a north-wall tile.
; 
; First checks CurrentTR: if also $09, both corners blocked → ClearMovementDeltas (full stop). Otherwise probes FutureBL and checks sub-tile Y alignment:
;   - Aligned + FutureBL is $09 → probe MapCellDown/MapCellLeft chain: if either nonzero, ClearSpeedNS_3 (stop NS). If both zero → compute snap offset.
;   - Not aligned or FutureBL not $09 → SnapXDiagCollision, then re-probe FutureBL: if solid/wall → SnapYSouthCollision. If passable → compute EastSnapOffset + FineAdjustXWest (slide west along north wall).

SouthWallNorthInteract {
    JSR $&tile_collision.ProbeCurrentTR ; North wall ($09) during south move: probe current top-right for continuous wall
    CMP #$09              ; TR also $09 → fully walled above; ClearMovementDeltas and stop
    BNE loc_02D4E4
    JMP $&tile_collision.ClearMovementDeltas

  loc_02D4E4:
    JSR $&tile_collision.ProbeFutureBL ; ProbeFutureBL + CheckSubTileAlignY: can player slide past north-wall edge?
    JSR $&tile_collision.CheckSubTileAlignY
    BCC loc_02D504
    CMP #$09              ; Future BL must be $09 north wall for slide-along-wall path
    BNE loc_02D504

  loc_02D4F0:
    JSR $&tile_collision.MapCellRight ; Gap probe: MapCellDown below north wall — empty cell allows passthrough
    STX $00
    JSR $&tile_collision.ReadCollisionNibble
    BNE ClearSpeedNS_3
    JSR $&tile_collision.MapCellUp ; MapCellLeft from gap cell — both must be walkable or clear NS speed
    JSR $&tile_collision.ReadCollisionNibble
    BNE ClearSpeedNS_3
    BRA loc_02D51C

  loc_02D504:
    JSR $&player_move_diag.SnapXDiagCollision ; No gap: SnapXDiagCollision adjusts X before re-testing destination
    JSR $&tile_collision.ProbeFutureBL ; Re-probe FutureBL after diagonal X snap
    BCC loc_02D51C
    CMP #$01              ; Types $01 (floor) or $09 (north wall) at destination → continue slide
    BEQ loc_02D51C
    CMP #$09
    BEQ loc_02D51C
    REP #$20

  loc_02D516:
    JSR $&SnapYSouthCollision ; Blocked slide: SnapYSouthCollision (Y snap) then ApplyMovementDeltas
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02D51C:
    REP #$20
    JSR $&ComputeSouthSnapOffset ; Open slide path: ComputeSouthSnapOffset then FineAdjustXWest for X edge snap
    JMP $&FineAdjustXWest
}

---------------------------------------------
; Extended north-wall probe when FutureBL is $09 during south movement.
; 
; Probes MapCellDown from the FutureBL position: if collision ≥ $0E (solid) → SnapYSouthCollision + ApplyDeltas. Otherwise falls into the SouthWallNorthInteract multi-cell adjacency check at loc_02D4F0.
; 
; Short bridge routine connecting the FutureBL $09 case to the main north-wall interaction logic.

SouthWallNorthProbe {
    JSR $&tile_collision.MapCellRight ; Extended north-wall probe: MapCellDown from future BL destination
    JSR $&tile_collision.ReadCollisionNibble
    CMP #$0E              ; Solid ≥ $0E below → redirect to hard Y-snap + apply path
    BCS loc_02D516
    BRA loc_02D4F0        ; Passable below future BL → join north-wall gap probe chain

; Zero playerSpeedNs ($09B4) and return. Used when north/south wall probing finds impassable adjacent cells during south movement dispatch. Instance 3 of the ClearSpeed pattern (numbered to avoid label collisions across files).

  ClearSpeedNS_3:
    REP #$20
    STZ $playerSpeedNs    ; Gap found under north wall: clear $playerSpeedNs and allow movement
    RTS 
}

---------------------------------------------
; South-wall ($06) interaction during south movement — handles CurrentBR being a south-wall tile.
; 
; Checks CurrentTL: if also $06 → ClearMovementDeltas (enclosed on both sides). Otherwise probes FutureBR with sub-tile Y alignment:
;   - Aligned + FutureBR is $06 → probe MapCellUp/MapCellLeft: if either nonzero → ClearSpeedNS_4. If both zero → compute EastSnapOffset + FineAdjustXEast (slide east along south wall).
;   - Not aligned → SnapXEastCollision, re-probe FutureBR: if $06 → compute snap. Otherwise → zero $24, SnapYNorthCollision, apply deltas.

SouthWallSouthInteract {
    JSR $&tile_collision.ProbeCurrentTL ; South wall ($06) during south move: probe current top-left for continuous wall
    CMP #$06              ; TL also $06 → fully blocked; ClearMovementDeltas
    BNE loc_02D540
    JMP $&tile_collision.ClearMovementDeltas

  loc_02D540:
    JSR $&tile_collision.ProbeFutureBR ; ProbeFutureBR + CheckSubTileAlignY for south-wall slide eligibility
    JSR $&tile_collision.CheckSubTileAlignY
    BCC loc_02D560
    CMP #$06              ; Future BR must be $06 south wall
    BNE loc_02D560

  loc_02D54C:
    JSR $&tile_collision.MapCellLeft ; Gap probe: MapCellUp — walkable cell above south-wall lip
    STX $00
    JSR $&tile_collision.ReadCollisionNibble
    BNE ClearSpeedNS_4
    JSR $&tile_collision.MapCellUp ; MapCellLeft from gap — both cells must be open or clear NS speed
    JSR $&tile_collision.ReadCollisionNibble
    BNE ClearSpeedNS_4
    BRA loc_02D574

  loc_02D560:
    JSR $&player_move_east.SnapXEastCollision ; No gap: SnapXEastCollision (diag X snap toward west)
    JSR $&tile_collision.ProbeFutureBR ; Re-probe FutureBR after west snap
    CMP #$06              ; Still south wall at BR → take open slide path
    BEQ loc_02D574
    REP #$20              ; Still blocked: zero fractional $24, SnapYNorthCollision for Y grid snap
    STZ $24
    JSR $&player_move_ns.SnapYNorthCollision
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02D574:
    REP #$20
    JSR $&ComputeSouthSnapOffset ; Open south-wall slide: ComputeSouthSnapOffset + FineAdjustXEast
    JMP $&FineAdjustXEast
}

---------------------------------------------
; Short shim that jumps to the south-wall MapCellUp probe chain (loc_02D54C) in SouthWallSouthInteract.
; 
; Used when a $06 slide tile is detected during sub-tile-aligned south movement, redirecting into the south wall adjacency checking logic.

SouthSlideJumpShim {
    BRA loc_02D54C        ; Slide shim: redirect to south-wall gap probe when aligned on $06

; Zero playerSpeedNs and return. Instance 4 — used by SouthWallSouthInteract and SouthSlideJumpShim adjacency checks.

  ClearSpeedNS_4:
    REP #$20
    STZ $playerSpeedNs    ; Gap under south wall lip: clear $playerSpeedNs
    RTS 
}

---------------------------------------------
; Structurally identical to AutoAlignEW (player_move_main) but probes FutureBR/FutureBL instead of FutureTR/FutureTL, matching the downward movement direction.
; 
; Skip conditions: $AA bit $0040 (diagonal active), collisionLayer high nibble nonzero, sub-tile X offset zero.
; 
; Nudge toward lower grid (offset ≥ 6): ProbeFutureBR, passability check (< $0E). Shifts $22 by −$20, NudgeToLowerGrid, restores +$20. CLC return.
; 
; Nudge toward upper grid (offset < 9): ProbeFutureBL with same check. NudgeToUpperGrid path. SEC return if no nudge applied.

AutoAlignEW_South {
    REP #$20
    LDA $AA               ; AutoAlignEW_South: X-axis ($22) auto-align before south-wall snap
    BIT #$0040            ; Skip nudge if diagonal-move flag $0040 set in $AA
    BNE loc_02D5F7
    LDA $collisionLayer, X
    AND #$00FF
    BIT #$00F0            ; Skip if collision layer high nibble nonzero (overlay/special layer)
    BNE loc_02D5F7
    LDA $22               ; X sub-tile offset from pixel pos: ($22>>2) - 8, masked to $0F
    LSR 
    LSR 
    AND #$000F
    SEC 
    SBC #$0008
    AND #$000F
    STA $04
    BEQ loc_02D5F7        ; Offset zero → already on X grid line, skip nudge
    CMP #$0006            ; Offset 6–8: try nudge X toward lower grid via FutureBR probe
    BCC loc_02D5D0
    JSR $&tile_collision.ProbeFutureBR ; ProbeFutureBR: destination must be passable (nibble < $0E)
    CMP #$000E
    BCS loc_02D5D0
    LDX #$0022            ; Temporarily shift probe X ($22) back $20 sub-pixels for lower nudge test
    LDA $00, X
    SEC 
    SBC #$0020
    STA $00, X
    JSR $&player_move_main.NudgeToLowerGrid ; NudgeToLowerGrid on X, restore +$20 afterward; success → carry clear
    LDA $00, X
    CLC 
    ADC #$0020
    STA $00, X
    CLC 
    RTS 

  loc_02D5D0:
    LDA $04
    CMP #$0009            ; Offset ≥ 9 → no nudge; offsets 1–5 use upper-grid path below
    BCS loc_02D5F7
    JSR $&tile_collision.ProbeFutureBL ; ProbeFutureBL: upper-grid nudge requires passable tile (nibble < $0E)
    CMP #$000E
    BCS loc_02D5F7
    LDX #$0022            ; Temporarily shift probe X ($22) back $20 for upper nudge test
    LDA $00, X
    SEC 
    SBC #$0020
    STA $00, X
    JSR $&player_move_main.NudgeToUpperGrid ; NudgeToUpperGrid on X; restore +$20; success → carry clear
    LDA $00, X
    CLC 
    ADC #$0020
    STA $00, X
    CLC 
    RTS 

  loc_02D5F7:
    SEC                   ; No nudge applied — return carry set
    RTS 
}

---------------------------------------------
; Compute a directional snap offset for wall-sliding during south movement.
; 
; Saves pixel coords ($1A, $1E). Probes CurrentBL: if $09 (north wall) or MapCellDown yields $06 (south wall), takes the boundary-crossing path.
; 
; Boundary path: velocity-to-pixel conversion ($24 >> 2), subtract from saved $1E on stack, XOR to detect 16px grid line crossing (BIT $0010). If crossed, $02 = $0010.
; 
; Final computation: $02 += ($1E AND $000F) — adds the sub-tile Y offset to the crossing adjustment. Result in $02 is the total snap correction.

ComputeSouthSnapOffset {
    REP #$20              ; ComputeSouthSnapOffset: save probe coordinates $1A/$1E on stack
    LDA $1A
    PHA 
    LDA $1E
    PHA 
    SEP #$20
    JSR $&tile_collision.ProbeCurrentBL ; ProbeCurrentBL: north wall $09 at current cell → velocity snap path
    CMP #$09
    BEQ loc_02D619
    JSR $&tile_collision.CheckSubTileAlignX ; X right-half alignment (carry): probe cell below for south wall $06
    BCC loc_02D640
    JSR $&tile_collision.MapCellRight ; MapCellDown + ReadCollisionNibble for south-wall boundary case
    JSR $&tile_collision.ReadCollisionNibble
    CMP #$06
    BNE loc_02D640

  loc_02D619:
    REP #$20              ; Wall path: restore saved coords, begin velocity boundary-cross offset
    PLA 
    STA $1E
    PLA 
    STA $1A
    STZ $02               ; Zero base snap offset $02 before velocity contribution
    LDA $1E
    PHA 
    LDA $24               ; Convert NS velocity $24 to pixel step (>>2) for boundary prediction
    LSR 
    LSR 
    SEC                   ; Negate predicted Y step; XOR with saved sub-tile detects 16px line cross
    SBC $01, S
    EOR #$FFFF
    INC 
    EOR $01, S
    BIT #$0010            ; BIT #$0010: crossed 16px sub-tile boundary → add $10 to snap offset $02
    BEQ loc_02D63D
    LDA #$0010
    STA $02

  loc_02D63D:
    PLA 
    BRA loc_02D64A

  loc_02D640:
    REP #$20              ; Non-wall path: restore coords, zero velocity snap — use sub-tile Y only
    PLA 
    STA $1E
    PLA 
    STA $1A
    STZ $02

  loc_02D64A:
    LDA $1E               ; Final offset: low nibble of probe Y ($1E & $0F) plus accumulated $02
    AND #$000F
    CLC 
    ADC $02
    STA $02
    RTS 
}

---------------------------------------------
; Precision X-position correction — snap toward the EAST tile edge.
; 
; Computes sub-tile X offset from player pixel position ($0014,X − 8, AND $0F). If zero, treats as full tile ($0010). Adds snap offset ($02). If total ≤ $0010 (within one tile): just apply movement deltas.
; 
; If total > $0010 (would cross tile boundary): inverts $02, computes the target X as (pixel AND $FFF0 | $02) + 8, converts to sub-pixel (ASL×2), stores to $22. The 'East' in the name refers to snapping toward the east (right) edge of the current tile.
; 
; Called from SouthWallSouthInteract when the player slides east along a south wall.

FineAdjustXEast {
    LDX $playerActor      ; FineAdjustXEast: snap player X ($22) toward east tile edge after south-wall slide
    LDA $0014, X
    SEC                   ; Sub-tile X distance from pixel: (actor+$14 - 8) & $0F
    SBC #$0008
    AND #$000F
    BNE loc_02D667
    LDA #$0010            ; Zero sub-tile distance → treat as 16px ($10) for snap math

  loc_02D667:
    CLC 
    ADC $02               ; Add ComputeSouthSnapOffset result ($02); total < $11 → move without grid snap
    CMP #$0011
    BCS loc_02D672
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02D672:
    LDA #$0010            ; ≥ $11 threshold: compute full tile-grid X snap
    SEC 
    SBC $02
    STA $02
    LDA $0014, X          ; Re-read pixel X for grid alignment step
    SEC 
    SBC #$0008
    BIT #$000F
    BNE loc_02D68A
    SEC                   ; On exact 16px grid line (low nibble zero): step back one tile (-$10)
    SBC #$0010

  loc_02D68A:
    AND #$FFF0            ; Snap X: tile boundary (AND $FFF0 | remainder + 8), <<2 to sub-pixels → $22
    ORA $02
    CLC 
    ADC #$0008
    ASL 
    ASL 
    STA $22
    JMP $&tile_collision.ApplyMovementDeltas
}

---------------------------------------------
; Precision X-position correction — snap toward the WEST tile edge.
; 
; Same structure as FineAdjustXEast but inverts the sub-tile offset (ORA $FFF0, EOR $FFFF, INC) to measure distance from the west edge instead. The inverted offset is added to $02.
; 
; If total ≤ $0010: apply deltas. If > $0010: compute target X snapped to the west edge.
; 
; Called from SouthWallNorthInteract when the player slides west along a north wall.

FineAdjustXWest {
    LDX $playerActor      ; FineAdjustXWest: mirror snap toward west tile edge (north-wall slide path)
    LDA $0014, X
    SEC                   ; Inverted sub-tile distance: negated (pixelX-8) with ORA #$FFF0 → west edge
    SBC #$0008
    ORA #$FFF0
    EOR #$FFFF
    INC 
    CLC                   ; Add snap offset $02; < $11 → ApplyMovementDeltas without X grid snap
    ADC $02
    CMP #$0011
    BCS loc_02D6B6
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02D6B6:
    LDA #$0010            ; ≥ $11: compute west-grid snap with inverted remainder
    SEC 
    SBC $02
    ORA #$FFF0
    EOR #$FFFF
    INC 
    STA $02
    LDA $0014, X          ; Snap X ($22) to previous tile column: grid align + remainder + 8, <<2
    SEC 
    SBC #$0008
    AND #$FFF0
    ORA $02
    CLC 
    ADC #$0008
    ASL 
    ASL 
    STA $22
    JMP $&tile_collision.ApplyMovementDeltas
}