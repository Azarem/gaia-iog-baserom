; North (negative $24) vertical-phase collision dispatch, wall handlers and north slope physics (184376-184902, Bank 02). DispatchNorthMove is called once per tick by PlayerMovementTick after the horizontal phase; the mirror image for positive $24 is DispatchSouthMove in player_move_south.
; 
; === CONVENTIONS ===
; 
; Positions are sub-pixels (4 per pixel; a 16-px tile is 64, so AND #$FFC0 floors to a row line). $24 / $26 are the Y velocity / position (negative = north, Y grows downward) and $22 is X. $1A / $1E are the probe pixel X / Y and $00 is the map index of the last probe; MapCellUp / Down / Left / Right read $00 and return the new index in X only (a caller that wants to keep it does STX $00; a result that is not stored is lost). CheckSubTileAlignX / Y: carry CLEAR = the probe sits on a 16-px line (flush), carry SET = it straddles two cells. Probe types: $02 ladder, $08 vine, $0E and above solid, $03 / $0C slopes; $06 / $09 are undecoded wall-like types (audit OQ-16, OQ-I029-5), so 'south wall' / 'north wall' below are handler names, not directions.
; 
; === DISPATCH ORDER (DispatchNorthMove) ===
; 
; 1. ProbeCurrentTL (carry set only): $06 -> SouthWallHandler, $03 -> NorthSlopeRight, $0C -> NorthSlopeLeft; any other type falls on.
; 2. ProbeCurrentTR: $09 -> NorthWallHandler.
; 3. ProbeFutureTL (top-left after the step): $0E and above or $08 -> blocked path; $02 -> NorthInteractTile; $06 -> SouthWallNudge.
; 4. CheckSubTileAlignX. X flush: future TL $09 -> NorthProbeRedirect, anything else -> the plain step. X straddling: future TL $09 -> blocked path; otherwise MapCellRight (the future TR cell) is read: $0E and above, $08, $02 or $06 -> blocked path, $09 -> NorthProbeRedirect, anything else -> the plain step.
; 5. Plain step: $26 += $24 (Y shrinks). $22 and $20 are not touched; PlayerMovementTick commits the position afterwards.
; 6. Blocked path (loc_02D0AF): SetActorCollisionFlag, AutoAlignEW_North (nudge X onto the column grid, carry clear = nudged), then SnapYNorthCollision. After a nudge the Y snap runs without zeroing playerSpeedNs (entry loc_02D0C2), so the player keeps pushing and is walked around the corner a couple of pixels per tick.
; 
; The older header had step 4 reversed ('sub-tile aligned: MapCellRight'); the code runs the MapCellRight probe only when X is NOT flush.
; 
; === SNAPPING ===
; 
; SnapYNorthCollision: Y' = $24 + $26 (the stepped Y), floored to a row line and moved one row down: $26 = (Y' AND $FFC0) + $40, $24 = 0. The hitbox top (feet - 16 px) then sits flush under the blocking row. In the normal blocked case Y' lies north of the old Y and the result falls between Y' and Y, so it backs the player off the step. Callers that run with $24 parked at 0 (the east and west wall-slide handlers) push the player SOUTH by 1..16 px instead (16 when already flush). The full entry also zeroes playerSpeedNs.
; 
; === SLOPES ===
; 
; NorthSlopeRight ($03) and NorthSlopeLeft ($0C) are entered when the current TL has that type and need the current TR to match, else the move counts as blocked. The slope flag $09AF bit $10 (playerFlags $1000, on a slope) is set when Y is flush, when the cell below has the same type, or when d >= 8. Here d = 16 - n and n = (($26 + $24) >> 2) AND $0F is the row offset of the top probe inside the slope tile, so d >= 8 means the upper half of the tile; in the lower half (n >= 9, d < 8) the move is applied without the flag. The old text called d < 8 the 'upper half'. The slope directions ('right' / 'left') are undecoded (OQ-I033-3); the old part notes called the same types 'descending' and 'ascending' inconsistently.
; 
; NorthSlopeLeft additionally filters the step through slopeFracAccum ($09C6, shared with the south handlers): a positive leftover is zeroed, then accum += $24. With |accum| >> 4 = 0 the unchanged $24 is applied and accum keeps the sum. Otherwise $24 is REPLACED by -(|accum| >> 4) and accum gains 16 per step. Nothing subtracts the distance that was actually moved, so for $24 = -8 the player alternates a full 2-px step and a 1-sub-pixel step (about 56 percent of the speed on average). UNVERIFIED-RUNTIME.
; 
; === WALL HANDLERS ===
; 
; SouthWallHandler (current TL $06) and NorthWallHandler (current TR $09): if the opposite bottom corner (BR / BL) has the same type the player is enclosed and ClearMovementDeltas runs. Otherwise the future corner is probed and CheckSubTileAlignY decides. Y STRADDLING and future type $06 / $09: gap chain. Y flush, or another type: the snap path.
; Gap chain: the neighbour cell east (SouthWallHandler, MapCellRight) or west (NorthWallHandler, MapCellLeft) of the future corner cell and the cell below that neighbour must both be type 0, else ClearSpeedNS_1 / _2 (playerSpeedNs = 0, nothing applied this tick). Both empty: ComputeYSnapOffset, then FineAdjustXWest / FineAdjustXEast. FineAdjustXWest moves X EAST and FineAdjustXEast moves X WEST (the names refer to the wall side), so SouthWallHandler slides the player east and NorthWallHandler west; the old headers said the opposite.
; Snap path: SnapXWestCollision (SouthWallHandler: X to the centre of the next column east, also zeroes playerSpeedEw) or SnapXEastCollision (NorthWallHandler: X floored to its column centre, i.e. west), then the future corner is re-probed. Still $06 / $09: take the slide. Anything else: zero $24 (so SnapYSouthCollision floors the CURRENT Y with no step added) and apply the move.
; 
; SouthWallNudge (future TL $06): $AB bit 1 is set by DispatchWestMove in every tick where the west horizontal phase ran (a negative $20) and is cleared together with $AA at the start of the tick; the old text called it a 'wall interaction flag from a prior collision pass'. If it is set and X is flush, the north step is cancelled ($24 = 0) and the X move is applied. Otherwise MapCellRight from the future TL cell: $0E and above -> zero $24 + SnapYSouthCollision + apply (loc_02D1BC); anything else -> the SouthWallHandler gap chain.
; 
; NorthProbeRedirect: reached from DispatchNorthMove when future TL is $09 (X flush) or the east cell is $09. Its MapCellDown + ReadCollisionNibble have no effect (MapCellDown only changes X, the nibble is dropped and MapCellLeft at loc_02D208 reads $00 again), so the chain starts from the cell recorded in $00 (OQ-I039-4).
; 
; Everything here is UNVERIFIED-RUNTIME (no emulator trace); the arithmetic is read from the code.
---------------------------------------------

?BANK 02

?INCLUDE 'player_character'
?INCLUDE 'player_move_east'
?INCLUDE 'player_move_main'
?INCLUDE 'player_move_south'
?INCLUDE 'player_move_west'
?INCLUDE 'tile_collision'

!playerActor                    09AA
!playerStateByte                09AF
!playerSpeedNs                  09B4
!slopeFracAccum                 09C6

---------------------------------------------

; Entry for negative $24, 8-bit probe mode, called from PlayerMovementTick after the horizontal phase. Probe order, the plain step and the blocked path are described in the block note; exits are JMPs into the slope / wall handlers, the plain step (loc_02D0A5) or the blocked path (loc_02D0AF).

DispatchNorthMove {
    SEP #$20              ; Vertical-phase entry for negative $24; the horizontal phase already ran this tick. 8-bit probe mode
    JSR $&tile_collision.ProbeCurrentTL ; Probe current top-left tile at player leading north corner; BCC = no TL collision
    BCC loc_02D054
    CMP #$06              ; Current TL type $06 -> SouthWallHandler (undecoded wall type: 'south wall' is a handler name, OQ-I029-5)
    BNE loc_02D046
    JMP $&SouthWallHandler

  loc_02D046:
    CMP #$03              ; Current TL type $03 -> NorthSlopeRight (slope direction undecoded, OQ-I033-3; the old 'ascending' wording was a guess)
    BNE loc_02D04D
    JMP $&NorthSlopeRight

  loc_02D04D:
    CMP #$0C              ; Current TL type $0C -> NorthSlopeLeft (the variant with the slopeFracAccum filter)
    BNE loc_02D054
    JMP $&NorthSlopeLeft

  loc_02D054:
    JSR $&tile_collision.ProbeCurrentTR ; Probe current top-right corner for complementary north-wall check
    CMP #$09              ; Current TR type $09 -> NorthWallHandler (undecoded wall type, mirror of the TL $06 case)
    BNE loc_02D05E
    JMP $&NorthWallHandler

  loc_02D05E:
    JSR $&tile_collision.ProbeFutureTL ; ProbeFutureTL: top-left corner after the north step (type in A)
    CMP #$0E              ; Solid tile: collision nibble ≥ $0E blocks north entry
    BCS loc_02D0AF
    CMP #$08              ; Type $08 (vine) cannot be entered walking north: blocked path (it is a south-only tile)
    BEQ loc_02D0AF
    CMP #$02              ; Type $02 ladder ahead -> NorthInteractTile (the climb starts only with X on a column line)
    BEQ NorthInteractTile
    CMP #$06              ; Type $06 south wall at destination → SouthWallNudge
    BNE loc_02D074
    JMP $&SouthWallNudge

  loc_02D074:
    JSR $&tile_collision.CheckSubTileAlignX ; Carry clear = left edge on a column line (X flush); carry set = X straddles two columns. A keeps the future TL type
    BCS loc_02D082
    CMP #$09              ; X flush and future TL $09 -> NorthProbeRedirect; any other type takes the plain step (loc_02D0A5)
    BNE loc_02D080
    JMP $&NorthProbeRedirect

  loc_02D080:
    BRA loc_02D0A5

  loc_02D082:
    CMP #$09              ; X straddling and future TL $09: blocked path
    BEQ loc_02D0AF
    JSR $&tile_collision.MapCellRight ; X straddling: MapCellRight = the cell east of the future TL cell (the future TR cell); STX $00 keeps it
    STX $00
    JSR $&tile_collision.ReadCollisionNibble
    CMP #$0E              ; That east cell solid ($0E and above): blocked path (the old text said 'below')
    BCS loc_02D0AF
    CMP #$08              ; East cell is a vine ($08): blocked path
    BEQ loc_02D0AF
    CMP #$02              ; East cell is a ladder ($02): blocked path until X is flush
    BEQ loc_02D0AF
    CMP #$09              ; East cell $09 -> NorthProbeRedirect chain ($00 = that cell)
    BNE loc_02D0A1
    JMP $&NorthProbeRedirect

  loc_02D0A1:
    CMP #$06              ; East cell $06 while X straddles: blocked path; any other type falls to the plain step
    BEQ loc_02D0AF

  loc_02D0A5:
    REP #$20
    LDA $26               ; Plain step: $26 (Y) += $24 (negative, so the player moves north); $22 and $20 are not touched here
    CLC 
    ADC $24
    STA $26
    RTS 

  loc_02D0AF:
    JSR $&tile_collision.SetActorCollisionFlag ; North blocked: set actor collision-contact flag for this frame
    JSR $&player_move_main.AutoAlignEW_North ; AutoAlignEW_North: X nudge onto the column grid (carry clear = nudged); SEC when $AA bit $0040 is set or no nudge fits
    BCS SnapYNorthCollision ; No nudge: full Y snap (also zeroes playerSpeedNs)
    PHP                   ; X was nudged: Y snap WITHOUT zeroing playerSpeedNs (entry loc_02D0C2); the push continues next tick
    REP #$20
    BRA loc_02D0C2

; Y snap after a blocked north step: $26 = (($24 + $26) AND $FFC0) + $40, $24 = 0, so the hitbox top ends flush under the blocking row. The full entry zeroes playerSpeedNs first; the loc_02D0C2 entry (used after a successful AutoAlignEW_North nudge) keeps it. With $24 = 0 (east / west wall-slide callers) it pushes south by 1..16 px. See the block note.

  SnapYNorthCollision:
    PHP 
    REP #$20
    STZ $playerSpeedNs    ; SnapYNorthCollision: zero $playerSpeedNs on hard Y snap

  loc_02D0C2:
    LDA $24               ; Y' = $24 + $26, the stepped Y (equal to the current Y when a caller parked $24 at 0)
    CLC 
    ADC $26
    AND #$FFC0            ; Floor to the row line (64 sub-pixels = 16 px)
    CLC 
    ADC #$0040            ; One row down: the hitbox top (feet - 16 px) ends flush under the blocking row
    STA $26
    STZ $24               ; Velocity consumed: $24 = 0
    PLP 
    RTS 

; Type $02 ladder ahead while moving north (a local label inside DispatchNorthMove). CheckSubTileAlignX: X straddling (carry set) -> blocked path. X flush: the player actor's entry becomes LadderClimbSouth (the ladder state entered from below: it checks Up before Down, then LadderIdleNorth) and $0008 = 0; then the blocked path runs, which holds the player at the ladder base.

  NorthInteractTile:
    JSR $&tile_collision.CheckSubTileAlignX ; Ladder tile ($02): require X sub-tile alignment before climbing
    BCS loc_02D0AF
    PHY 
    LDY $playerActor
    REP #$20
    LDA #$&player_character.LadderClimbSouth ; LadderClimbSouth: the ladder state entered from below (checks Up before Down, then LadderIdleNorth)
    STA $0000, Y
    LDA #$0000            ; Zero the actor wait counter (+$0008) for a clean ladder climb entry
    STA $0008, Y
    PLY 
    BRA loc_02D0AF        ; Then the blocked path (collision flag, X nudge, Y snap): holds the player at the base of the ladder
}

---------------------------------------------
; Current TL $03 while moving north. Needs the current TR to be $03 too, else blocked path. Y flush, or the cell below also $03: set the slope flag and apply. Otherwise d = 16 - n (see the block note): d < 8 applies the move without the flag, d >= 8 sets $09AF bit $10 first. The direction of the slope is undecoded (OQ-I033-3).

NorthSlopeRight {
    JSR $&tile_collision.ProbeCurrentTR ; Right slope ($03): verify matching $03 at current TR corner
    CMP #$03
    BNE loc_02D0AF
    JSR $&tile_collision.CheckSubTileAlignY ; CheckSubTileAlignY: Y sub-tile position gates slope traversal
    BCC loc_02D11A
    JSR $&tile_collision.MapCellDown ; MapCellDown: cell below must also be $03 for smooth slope continue
    JSR $&tile_collision.ReadCollisionNibble
    CMP #$03
    BEQ loc_02D11A
    LDA $26               ; n = (($26 + $24) >> 2) AND $0F: row offset of the top probe inside the slope tile (8-bit: low bytes only)
    CLC 
    ADC $24
    LSR 
    LSR 
    AND #$0F
    SEC 
    SBC #$10
    EOR #$FF
    INC                   ; d = 16 - n (1..16)
    CMP #$08              ; d < 8 (n >= 9, lower half of the tile): apply without the flag; d >= 8 goes on to set it
    BPL loc_02D11A
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02D11A:
    LDA #$10              ; Set $09AF bit $10 (playerFlags $1000, on a slope): Y flush, same slope below, or d >= 8
    TSB $playerStateByte
    JMP $&tile_collision.ApplyMovementDeltas
}

---------------------------------------------
; Current TL $0C while moving north. Same gate and flag logic as NorthSlopeRight, but with d < 8 the move is applied without touching the accumulator; otherwise the flag is set and the step goes through the slopeFracAccum filter (block note): the full $24 when |accum + $24| < 16, else -(|accum + $24| >> 4). For $24 = -8 the steps alternate -8 and -1 sub-pixels. UNVERIFIED-RUNTIME.

NorthSlopeLeft {
    JSR $&tile_collision.ProbeCurrentTR ; Left slope ($0C): verify matching $0C at current TR corner
    CMP #$0C
    BNE loc_02D0AF
    JSR $&tile_collision.CheckSubTileAlignY ; CheckSubTileAlignY for left-slope traversal gate
    BCC loc_02D14E
    JSR $&tile_collision.MapCellDown ; MapCellDown adjacency: cell below must be $0C for continued slope
    JSR $&tile_collision.ReadCollisionNibble
    CMP #$0C
    BEQ loc_02D14E
    LDA $24               ; n = (($24 + $26) >> 2) AND $0F as in NorthSlopeRight (same sum, 8-bit)
    CLC 
    ADC $26
    LSR 
    LSR 
    AND #$0F
    SEC 
    SBC #$10
    EOR #$FF
    INC                   ; d = 16 - n (1..16)
    CMP #$08              ; d < 8: apply the move without the flag and without the accumulator; d >= 8 sets the flag and filters the step
    BPL loc_02D14E
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02D14E:
    LDA #$10              ; Set the slope flag (same condition as NorthSlopeRight), then run the fractional filter
    TSB $playerStateByte
    REP #$20
    LDA $slopeFracAccum   ; slopeFracAccum ($09C6, shared with the south handlers): a positive (south-signed) leftover is zeroed first
    BMI loc_02D15D
    STZ $slopeFracAccum

  loc_02D15D:
    LDA $24               ; sum = $24 + accum (both negative here); stored back as the new accumulator
    CLC 
    ADC $slopeFracAccum
    STA $slopeFracAccum
    EOR #$FFFF            ; |sum|; shifted right 4 below to get the step
    INC 
    LSR 
    LSR 
    LSR 
    LSR 
    BEQ loc_02D185        ; step = |sum| >> 4. Zero: apply the unchanged $24 (a full step) and keep the sum in the accumulator
    STA $24               ; Temporary: $24 = step (positive)
    ASL 
    ASL 
    ASL 
    ASL 
    CLC                   ; Subtract consumed fraction: (step<<4), add back to $slopeFracAccum
    ADC $slopeFracAccum   ; accum = sum + (step << 4): 16 per step consumed (the distance actually moved is never subtracted)
    STA $slopeFracAccum
    LDA $24               ; $24 = -step REPLACES the velocity this tick (1/16 of the accumulated total, usually a very small move)
    EOR #$FFFF
    INC 
    STA $24

  loc_02D185:
    JMP $&tile_collision.ApplyMovementDeltas
}

---------------------------------------------
; Current TL $06 while moving north. Current BR $06 too: ClearMovementDeltas. Otherwise ProbeFutureTL + CheckSubTileAlignY. Y straddling and future TL $06: gap chain (loc_02D19E): the east cell and the cell below it must both be type 0, else ClearSpeedNS_1; both empty: ComputeYSnapOffset + FineAdjustXWest (X moves EAST). Y flush or another type: SnapXWestCollision (X east to the next column centre), re-probe; $06 -> slide, else zero $24 + SnapYSouthCollision + apply.

SouthWallHandler {
    JSR $&tile_collision.ProbeCurrentBR ; South wall ($06) during north move: probe current bottom-right for continuous wall
    CMP #$06              ; BR also $06 → fully blocked; ClearMovementDeltas
    BNE loc_02D192
    JMP $&tile_collision.ClearMovementDeltas

  loc_02D192:
    JSR $&tile_collision.ProbeFutureTL ; ProbeFutureTL + CheckSubTileAlignY: can player slide past south-wall edge?
    JSR $&tile_collision.CheckSubTileAlignY ; Carry clear = Y flush -> snap path; carry set = Y straddles two rows. A keeps the future TL type
    BCC loc_02D1B2
    CMP #$06              ; Y straddling and future TL $06: gap chain; any other type takes the snap path (loc_02D1B2)
    BNE loc_02D1B2

  loc_02D19E:
    JSR $&tile_collision.MapCellRight ; Gap chain: the cell east of the future TL cell must be empty (type 0)
    STX $00
    JSR $&tile_collision.ReadCollisionNibble
    BNE ClearSpeedNS_1    ; Any nonzero type: cancel (ClearSpeedNS_1)
    JSR $&tile_collision.MapCellDown ; The cell below that east cell (from the stored $00) must also be empty
    JSR $&tile_collision.ReadCollisionNibble
    BNE ClearSpeedNS_1
    BRA loc_02D1C6

  loc_02D1B2:
    JSR $&player_move_west.SnapXWestCollision ; Full entry: zeroes playerSpeedEw; X goes to the centre of the next column EAST ($20 is 0 in this phase)
    JSR $&tile_collision.ProbeFutureTL ; Re-probe FutureTL after diagonal X snap
    CMP #$06              ; Still $06: take the slide; any other result falls to loc_02D1BC
    BEQ loc_02D1C6

  loc_02D1BC:
    REP #$20
    STZ $24               ; Zero $24 first: SnapYSouthCollision then floors the CURRENT Y (no step added)
    JSR $&player_move_south.SnapYSouthCollision ; SnapYSouthCollision: Y floored to its row line (up to 15 px north), then the move is applied
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02D1C6:
    REP #$20
    JSR $&player_move_main.ComputeYSnapOffset ; ComputeYSnapOffset: $02 = 16 - (probe Y AND $0F), 1..16 px (16 when flush; its own header says 0)
    JMP $&player_move_south.FineAdjustXWest ; FineAdjustXWest: X moves EAST (away from the wall under the left foot) by $02 - n px, then the move is applied
}

---------------------------------------------
; Future TL $06 while moving north. $AB bit 1 (the west horizontal phase ran this tick) with X flush: $24 = 0 and the X move is applied. Otherwise MapCellRight from the future TL cell: $0E and above -> loc_02D1BC (zero $24, SnapYSouthCollision, apply); anything else -> the SouthWallHandler gap chain at loc_02D19E (which cancels on any nonzero type).

SouthWallNudge {
    LDA $AB               ; $AB bit 1 = the west horizontal phase ran this tick (set in DispatchWestMove, cleared with $AA each tick)
    BIT #$02
    BEQ loc_02D1E0
    JSR $&tile_collision.CheckSubTileAlignX ; Require X sub-tile alignment for fast zero-$24 nudge
    BCS loc_02D1E0
    REP #$20
    STZ $24               ; West move and X flush: cancel the north step ($24 = 0), keep the X move
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02D1E0:
    JSR $&tile_collision.MapCellRight ; MapCellRight from the future TL cell ($00 from ProbeFutureTL); the new index is in X
    JSR $&tile_collision.ReadCollisionNibble
    CMP #$0E              ; East cell solid ($0E and above): zero $24 + SnapYSouthCollision + apply (loc_02D1BC)
    BCS loc_02D1BC
    BRA loc_02D19E        ; Not solid: join the SouthWallHandler gap chain (it re-reads this cell; any nonzero type cancels)

; Abort of the SouthWallHandler gap chain: playerSpeedNs = 0 and return. No position is applied this tick ($26 stays as it was).

  ClearSpeedNS_1:
    REP #$20              ; Gap found under south wall lip: clear $playerSpeedNs
    STZ $playerSpeedNs    ; Cancel: playerSpeedNs = 0 and return; the step is NOT applied ($26 unchanged this tick)
    RTS 
}

---------------------------------------------
; Current TR $09 while moving north. Current BL $09 too: ClearMovementDeltas. Otherwise ProbeFutureTR + CheckSubTileAlignY. Y straddling and future TR $09: gap chain (loc_02D208): the west cell and the cell below it must both be type 0, else ClearSpeedNS_2; both empty: ComputeYSnapOffset + FineAdjustXEast (X moves WEST). Y flush or another type: SnapXEastCollision (X floored to its column centre, west), re-probe; $09 -> slide, else zero $24 + SnapYSouthCollision + apply.

NorthWallHandler {
    JSR $&tile_collision.ProbeCurrentBL ; North wall ($09) during north move: probe current bottom-left for continuous wall
    CMP #$09              ; BL also $09 → fully blocked; ClearMovementDeltas
    BNE loc_02D1FC
    JMP $&tile_collision.ClearMovementDeltas

  loc_02D1FC:
    JSR $&tile_collision.ProbeFutureTR ; ProbeFutureTR + CheckSubTileAlignY for north-wall slide eligibility
    JSR $&tile_collision.CheckSubTileAlignY ; Carry clear = Y flush -> snap path; carry set = Y straddles two rows. A keeps the future TR type
    BCC loc_02D21C
    CMP #$09              ; Y straddling and future TR $09: gap chain; any other type takes the snap path (loc_02D21C)
    BNE loc_02D21C

  loc_02D208:
    JSR $&tile_collision.MapCellLeft ; Gap chain: the cell WEST of the future TR cell must be empty (type 0)
    STX $00
    JSR $&tile_collision.ReadCollisionNibble
    BNE ClearSpeedNS_2    ; Any nonzero type: cancel (ClearSpeedNS_2)
    JSR $&tile_collision.MapCellDown ; The cell below that west cell (from the stored $00) must also be empty
    JSR $&tile_collision.ReadCollisionNibble
    BNE ClearSpeedNS_2
    BRA loc_02D230

  loc_02D21C:
    JSR $&player_move_east.SnapXEastCollision ; SnapXEastCollision: X floored to its column centre (moves west); also zeroes playerSpeedEw
    JSR $&tile_collision.ProbeFutureTR ; Re-probe FutureTR after east X snap
    CMP #$09              ; Still north wall at TR → take open slide path
    BEQ loc_02D230        ; Still $09: take the slide; any other result falls on to zero $24 and snap Y
    REP #$20
    STZ $24               ; Zero $24 first: SnapYSouthCollision then floors the CURRENT Y (no step added)
    JSR $&player_move_south.SnapYSouthCollision ; SnapYSouthCollision: Y floored to its row line (up to 15 px north), then the move is applied
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02D230:
    REP #$20
    JSR $&player_move_main.ComputeYSnapOffset ; ComputeYSnapOffset: $02 = 16 - (probe Y AND $0F), 1..16 px
    JMP $&player_move_south.FineAdjustXEast ; FineAdjustXEast: X moves WEST (away from the wall under the right foot) by the overlap, then the move is applied
}

---------------------------------------------
; Entry from DispatchNorthMove when the future TL is $09 (X flush) or the east cell is $09. MapCellDown + ReadCollisionNibble here are dead (the result is unused and the BRA target's MapCellLeft starts from $00), so it simply joins the NorthWallHandler gap chain at loc_02D208 with the cell in $00 (OQ-I039-4).

NorthProbeRedirect {
    JSR $&tile_collision.MapCellDown ; No effect: MapCellDown only changes X, and MapCellLeft at the BRA target reads $00 again
    JSR $&tile_collision.ReadCollisionNibble ; Result unused (OQ-I039-4)
    BRA loc_02D208        ; Join the NorthWallHandler gap chain; it starts from the cell in $00

; Abort of the NorthWallHandler gap chain: playerSpeedNs = 0 and return. No position is applied this tick.

  ClearSpeedNS_2:
    REP #$20              ; Gap found above north wall lip: clear $playerSpeedNs
    STZ $playerSpeedNs    ; Cancel: playerSpeedNs = 0 and return; the step is not applied
    RTS 
}