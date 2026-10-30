; South (+Y) movement collision dispatch and grid alignment (185206-186076, Bank 02).
; 
; Entered from PlayerMovementTick (player_move_main) with $24 > 0, after the horizontal (EW) phase has run (so $20 is already zero), unless $AA bit $0400 is set (nothing sets it). Everything here works on sub-pixels (4 per pixel): $22/$26 are the X/Y position, $24 the Y velocity (positive = south, Y grows downward). A 16-pixel tile is 64 sub-pixels, so AND #$FFC0 floors to a tile line.
; 
; === CONVENTIONS ===
; 
; - Probe* routines (tile_collision) return A = collision type nibble and carry SET for any nonzero type, with the probed map index left in $00. Solid is A >= $0E, tested by the callers here.
; - MapCellRight / MapCellLeft / MapCellUp read the index in $00 and return the neighbouring cell in X; the callers commit it with STX $00 before ReadCollisionNibble.
; - CheckSubTileAlignX / Y: carry CLEAR = the probe edge is flush with a tile line (the hitbox covers a single column / row), carry SET = it straddles two cells. A is preserved.
; - Types seen here: $02 ladder, $08 ledge jump (a gap in a ledge edge; can only be entered while walking south; the north dispatcher treats $08 as a wall), $03 / $0C slopes, $06 / $09 diagonal-edge types ($06 = top-right + bottom-left quadrants, $09 = top-left + bottom-right). The 'North' / 'South' in SouthWallNorth* / SouthWallSouth* names comes from the type ($09 / $06), not from a direction.
; 
; === DispatchSouthMove ORDER ===
; 
;   CurrentBL $09 -> SouthWallNorthInteract
;   CurrentBL $03 -> SouthSlopeRight, $0C -> SouthSlopeLeft
;   CurrentBR $06 -> SouthWallSouthInteract
;   FutureBL >= $0E -> SouthBlockedWall
;   FutureBL $02 -> SouthLadderTile (ladder), $08 -> SouthLedgeTile (ledge jump), $09 -> SouthWallNorthProbe
;   Left column aligned: FutureBL $06 -> SouthSlideJumpShim, else a plain step
;   Left column straddling two columns: FutureBL $06 blocks; then the cell to the right is tested ($0E+ / $02 / $09 block, $06 -> SouthSlideJumpShim)
;   Otherwise: $26 += $24 (the step does not touch $22 and does not clear $24).
; 
; === WALL SNAP AND CORNER ASSIST ===
; 
; SouthBlockedWall first tries AutoAlignEW_South (a 2 px X nudge toward the open column). A nudge keeps playerSpeedNs, so the player keeps pushing and slides past the corner on the next tick; no nudge goes through SnapYSouthCollision, which zeroes playerSpeedNs. Both end in the shared floor ((Y + $24) AND $FFC0, then $24 = 0): the feet end flush against the top of the blocked row.
; 
; === SLOPES ===
; 
; SouthSlopeRight ($03) and SouthSlopeLeft ($0C) require the matching type under both feet, otherwise SouthBlockedWall. The slope flag (playerFlags $1000, set through the high byte playerStateByte $09AF bit $10) is set when the feet are on a tile line, when the cell above is the same slope type, or when the row offset of the new Y is >= 8; only a misaligned player with a different cell above and an offset < 8 moves without it. SouthSlopeLeft additionally runs slopeFracAccum: the step is replaced by accumulator >> 4 whenever that is nonzero, so ticks alternate between the full step and a very small one (effective slow-down unverified). Which diagonal each slope type follows is not decoded here.
; 
; === WALL-LIKE TYPES $09 / $06 ===
; 
; SouthWallNorthInteract (left foot on $09) and SouthWallSouthInteract (right foot on $06) are mirror images. If the opposite top corner is the same type the player is fully stopped (ClearMovementDeltas). Otherwise the handler probes the destination, tests the cells beside it, and either clears playerSpeedNs (ClearSpeedNS_3 / _4), floors Y, or takes the slide: ComputeSouthSnapOffset measures how far the step penetrates and FineAdjustXWest / FineAdjustXEast move X out of the wall. By the arithmetic the $09 / left-foot case pushes the player EAST (SnapXWestCollision moves X to the next tile centre east, FineAdjustXWest ends east of the old X) and the $06 / right-foot case pushes WEST (SnapXEastCollision floors to the tile centre, FineAdjustXEast ends west of the old X). The 'East' / 'West' in the FineAdjustX* names names the side the wall is on.
; 
; Includes: DispatchSouthMove, SouthBlockedWall, SnapYSouthCollision, SouthLadderTile (ladder), SouthLedgeTile (ledge jump), SouthSlopeRight / Left, SouthWallNorthInteract / SouthWallNorthProbe, SouthWallSouthInteract, SouthSlideJumpShim, ClearSpeedNS_3 / _4, AutoAlignEW_South, ComputeSouthSnapOffset, FineAdjustXEast / FineAdjustXWest.
---------------------------------------------

?BANK 02

?INCLUDE 'player_character'
?INCLUDE 'player_move_east'
?INCLUDE 'player_move_main'
?INCLUDE 'player_move_ns'
?INCLUDE 'player_move_west'
?INCLUDE 'tile_collision'

!playerActor                    09AA
!playerStateByte                09AF
!playerSpeedNs                  09B4
!slopeFracAccum                 09C6
!collisionLayer                 7FC000

---------------------------------------------

; Main entry for positive $24. Reads the left foot's current type first ($09, $03, $0C), then the right foot's ($06), then the destination under the left foot (FutureBL), and finally the second column when the hitbox straddles two columns. The non-blocked path ends with $26 += $24 only.
; 
; Register state: the routine runs with A 8-bit for the type compares and X/Y 16-bit; after ProbeFutureBL, X and $00 hold FutureBL's map index, which MapCellRight steps from.

DispatchSouthMove {
    SEP #$20              ; South half of the vertical phase: entered with $24 > 0 after the horizontal phase ran ($20 is zero by now); A is 8-bit for the type compares
    JSR $&tile_collision.ProbeCurrentBL ; Current bottom-left corner: A = collision type nibble, carry set when it is nonzero
    CMP #$09              ; Type $09 under the left foot (diagonal-edge type, top-left + bottom-right quadrants): SouthWallNorthInteract. The North is the type name, not a direction
    BNE loc_02D382
    JMP $&SouthWallNorthInteract

  loc_02D382:
    CMP #$03              ; Type $03 slope under the left foot: SouthSlopeRight (slope geometry undecoded)
    BNE loc_02D389
    JMP $&SouthSlopeRight

  loc_02D389:
    CMP #$0C              ; Type $0C slope under the left foot: SouthSlopeLeft (adds the slopeFracAccum step reduction)
    BNE loc_02D390
    JMP $&SouthSlopeLeft

  loc_02D390:
    JSR $&tile_collision.ProbeCurrentBR ; Current bottom-right corner, only reached when the left foot is on neither a wall-like nor a slope type
    CMP #$06              ; Type $06 under the right foot (diagonal-edge type, top-right + bottom-left quadrants): SouthWallSouthInteract, mirror of the $09 case
    BNE loc_02D39A
    JMP $&SouthWallSouthInteract

  loc_02D39A:
    JSR $&tile_collision.ProbeFutureBL ; Bottom-left corner after the step ($26 + $24); X and $00 now hold that cell's map index
    CMP #$0E              ; Solid terrain (type >= $0E) at the destination blocks the step
    BCC loc_02D3A4
    JMP $&SouthBlockedWall

  loc_02D3A4:
    CMP #$02              ; Ladder at the destination: SouthLadderTile (needs a single-column hitbox)
    BEQ SouthLadderTile
    CMP #$08              ; Ledge-jump cell at the destination: SouthLedgeTile (it can only be entered while walking south)
    BEQ SouthLedgeTile
    CMP #$09              ; Type $09 at the destination: SouthWallNorthProbe
    BNE loc_02D3B3
    JMP $&SouthWallNorthProbe

  loc_02D3B3:
    JSR $&tile_collision.CheckSubTileAlignX ; Carry clear = left edge flush with a tile column (single column), carry set = straddles two columns; A keeps the FutureBL type
    BCS loc_02D3C1
    CMP #$06              ; Single column and FutureBL is type $06: SouthSlideJumpShim; any other type is a free step
    BNE loc_02D3BF
    JMP $&SouthSlideJumpShim

  loc_02D3BF:
    BRA loc_02D3E0        ; Single column and nothing special at the destination: plain step

  loc_02D3C1:
    CMP #$06              ; Straddling two columns and FutureBL is type $06: hard block
    BEQ SouthBlockedWall
    JSR $&tile_collision.MapCellRight ; MapCellRight reads $00 (FutureBL index) and returns the cell one column to the right in X: the hitbox covers it as well
    STX $00
    JSR $&tile_collision.ReadCollisionNibble
    CMP #$0E              ; Right-hand cell solid: blocked
    BCS SouthBlockedWall
    CMP #$02              ; Right-hand cell is a ladder: blocked (the player must be column-aligned to use it)
    BEQ SouthBlockedWall
    CMP #$06              ; Right-hand cell type $06: SouthSlideJumpShim
    BNE loc_02D3DC
    JMP $&SouthSlideJumpShim

  loc_02D3DC:
    CMP #$09              ; Right-hand cell type $09: blocked
    BEQ SouthBlockedWall

  loc_02D3E0:
    REP #$20              ; Unblocked step: only $26 += $24; unlike ApplyMovementDeltas this leaves $22 and $24 alone
    LDA $26
    CLC 
    ADC $24
    STA $26
    RTS 
}

---------------------------------------------
; Wall handler for south movement: SetActorCollisionFlag, then AutoAlignEW_South. Carry clear (X nudged) enters the shared floor code at loc_02D3FD without zeroing playerSpeedNs; carry set falls into SnapYSouthCollision, which does zero it. The PHP before the BRA balances the PLP at the end of the shared code.

SouthBlockedWall {
    JSR $&tile_collision.SetActorCollisionFlag ; South blocked: set actor collision-contact flag for this frame
    JSR $&AutoAlignEW_South ; Corner assist: nudge X by 2 px toward the open column; carry clear = nudged, carry set = nothing done
    BCS SnapYSouthCollision ; No nudge: hard Y snap through SnapYSouthCollision (which also zeroes playerSpeedNs)
    PHP                   ; Balances the PLP at the end of the shared snap code; the SnapYSouthCollision entry pushes its own
    REP #$20              ; X nudge succeeded: join shared snap math at loc_02D3FD
    BRA loc_02D3FD        ; Nudged: same Y floor but playerSpeedNs is kept, so the player keeps pushing and slides past the corner next tick
}

---------------------------------------------
; Hard Y snap after a south wall hit: zero playerSpeedNs, then Y = (Y + $24) AND $FFC0 (floor to a 16-pixel row line), $24 = 0. Callers outside this file reach it from the east / ns / diag dispatchers as well, with $24 already zero or not.

SnapYSouthCollision {
    PHP 
    REP #$20
    STZ $playerSpeedNs    ; SnapYSouthCollision: zero $playerSpeedNs on hard Y snap

  loc_02D3FD:
    LDA $24               ; New Y = (Y + $24) AND $FFC0: post-step Y floored to a 16-pixel row line, feet flush with the top of the blocked row
    CLC 
    ADC $26
    AND #$FFC0            ; 64 sub-pixels = 16 pixels = one tile row
    STA $26
    STZ $24
    PLP 
    RTS 

; Ladder reached while walking south. The hitbox must be over a single column (CheckSubTileAlignX carry clear), otherwise the tile counts as a wall. Sets the player actor's entry address ($0000,Y) to LadderClimbNorth and clears its wait counter ($0008,Y), then branches to SouthBlockedWall so the usual Y snap runs. LadderClimbNorth is the climb state entered from above (it checks Down before Up and falls to LadderIdleSouth); the name follows its entry animation, not the walking direction.

  SouthLadderTile:
    JSR $&tile_collision.CheckSubTileAlignX ; Ladder: the hitbox must be over a single column (carry clear) to start the climb, otherwise it counts as blocked
    BCS SouthBlockedWall
    PHY 
    REP #$20
    LDY $playerActor
    LDA #$&player_character.LadderClimbNorth ; Player entry becomes LadderClimbNorth: the climb state used when stepping onto a ladder from above (checks Down before Up, else LadderIdleSouth)
    STA $0000, Y          ; Overwrites the player actor's entry address ($00); the actor resumes at the new state on its next pass
    LDA #$0000            ; Zero the wait counter ($08) so the new state starts at its next pass
    STA $0008, Y
    PLY 
    BRA SouthBlockedWall  ; Then snap like a wall: Y floored to a row line and AutoAlignEW_South gets a try first

; Type $08 cell reached while walking south: the start of a ledge jump. The old names (SouthStairsTile, then SouthVineTile) were wrong: nothing here is a stair, a vine or a ladder. In Mesen2 (scene $01, South Cape) the player walks into the gap of a mossy wall edge, steps off and falls onto the roof below. It is south-only because a ledge can only be jumped down from the north; the north handler treats the cell as a wall.
; 
; $08 is a real collision type, not a script flag: 59 of the 223 map scenes hold it (Angkor Wat, the Pyramid, Sky Garden, the Great Wall, Freejia, the Gold Ship, Incan Ruins, South Cape, Edward's Castle, Itory and others; B1 census, plans/extracted-audit/mesen2-results). Only South Cape was watched; the other scenes are assumed to be ledges of the same kind. The Mt. Temple scenes $A0-$A9 hold no $02, $07 or $08 cell.
; 
; Entry rule: column-aligned (carry clear): go straight in. Straddling (carry set): the cell to the RIGHT must also be type $08, otherwise blocked. Sets playerFlags $0800 (script / ability lock) through the high byte playerStateByte, switches the player to LedgeJumpEntry (which sets actor flag $0200 and hides the use-item button), clears the wait counter and floors Y through SnapYSouthCollision (which also zeroes playerSpeedNs).

  SouthLedgeTile:
    JSR $&tile_collision.CheckSubTileAlignX ; Ledge jump: carry clear (single column) enters directly; carry set requires the cell to the right to be $08 as well
    BCC loc_02D434
    JSR $&tile_collision.MapCellRight ; Straddling two columns: the cell one column to the RIGHT of FutureBL must also be a ledge-jump cell
    JSR $&tile_collision.ReadCollisionNibble
    CMP #$08              ; Not $08 in the right-hand cell: treat as a blocked wall
    BNE SouthBlockedWall

  loc_02D434:
    LDA #$08              ; A is 8-bit here: the TSB below sets bit 3 of the high byte of playerFlags
    TSB $playerStateByte  ; $09AF is the high byte of playerFlags ($09AE): this sets playerFlags $0800 (script / ability lock), not a stair flag
    PHY 
    LDY $playerActor
    REP #$20
    LDA #$&player_character.LedgeJumpEntry ; Player entry becomes LedgeJumpEntry (sets actor flag $0200, hides the use-item button, steps off the ledge)
    STA $0000, Y
    LDA #$0000            ; Zero the wait counter ($08) so the ledge jump starts at its next pass
    STA $0008, Y
    PLY 
    BRA SnapYSouthCollision ; Then the hard snap: Y floored to a row line, playerSpeedNs and $24 zeroed
}

---------------------------------------------
; Slope type $03 under the left foot. The right foot (ProbeCurrentBR) must be $03 as well, else SouthBlockedWall. Slope flag path (playerFlags $1000 via playerStateByte bit $10, then ApplyMovementDeltas): feet on a row line (CheckSubTileAlignY carry clear), or the cell above is also $03, or the new row offset is >= 8. Otherwise (misaligned, different cell above, offset < 8) plain ApplyMovementDeltas without the flag.

SouthSlopeRight {
    JSR $&tile_collision.ProbeCurrentBR ; Right foot: type must be $03 as well (the dispatcher already tested the left foot); a mismatch is a wall
    CMP #$03
    BEQ loc_02D458
    JMP $&SouthBlockedWall

  loc_02D458:
    JSR $&tile_collision.CheckSubTileAlignY ; Carry clear = Y probe flush with a row line
    BCC loc_02D477        ; On a row line: take the slope path (sets the slope flag)
    JSR $&tile_collision.MapCellUp ; Straddling rows: the cell above must be $03 too to take the slope path
    JSR $&tile_collision.ReadCollisionNibble
    CMP #$03
    BEQ loc_02D477
    LDA $24               ; Row offset of the new Y: ((Y + $24) >> 2) AND $0F; 8-bit math is enough for those bits
    CLC 
    ADC $26
    LSR 
    LSR 
    AND #$0F
    CMP #$08              ; Offset >= 8 takes the slope path (flag set); offset < 8 moves plain
    BPL loc_02D477
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02D477:
    LDA #$10              ; A is 8-bit: TSB sets playerFlags $1000 (on a slope or ramp) through the high byte
    TSB $playerStateByte  ; Sets bit 4 of the high byte of playerFlags, i.e. playerFlags $1000 (on a slope / ramp)
    JMP $&tile_collision.ApplyMovementDeltas ; ApplyMovementDeltas: $22 += $20, $26 += $24, then both velocities are zeroed
}

---------------------------------------------
; Slope type $0C: same dispatch as SouthSlopeRight (right foot must be $0C, same three conditions for the slope flag), followed by the slopeFracAccum step reduction. slopeFracAccum ($09C6): clamp negative to zero, += $24, step = accumulator >> 4; if the step is nonzero $24 becomes the step and the accumulator drops by step << 4, otherwise $24 is left at the full value. Net effect: alternating full and tiny steps. player_move_controller zeroes the accumulator when the NS speed is zero.

SouthSlopeLeft {
    JSR $&tile_collision.ProbeCurrentBR ; Right foot: type must be $0C as well; a mismatch is a wall
    CMP #$0C
    BEQ loc_02D489
    JMP $&SouthBlockedWall

  loc_02D489:
    JSR $&tile_collision.CheckSubTileAlignY ; Carry clear = Y probe flush with a row line
    BCC loc_02D4A8
    JSR $&tile_collision.MapCellUp ; Straddling rows: the cell above must be $0C too to take the slope path
    JSR $&tile_collision.ReadCollisionNibble
    CMP #$0C
    BEQ loc_02D4A8
    LDA $24               ; Row offset of the new Y: ((Y + $24) >> 2) AND $0F
    CLC 
    ADC $26
    LSR 
    LSR 
    AND #$0F
    CMP #$08
    BPL loc_02D4A8
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02D4A8:
    LDA #$10              ; Reached when the feet are on a row line, the cell above is $0C, or the row offset is >= 8: sets playerFlags $1000 through the high byte
    TSB $playerStateByte
    REP #$20
    LDA $slopeFracAccum   ; slopeFracAccum ($09C6): clamp a negative value to zero first
    BPL loc_02D4B7
    STZ $slopeFracAccum

  loc_02D4B7:
    LDA $24               ; accumulator += $24 (A is 16-bit again)
    CLC 
    ADC $slopeFracAccum
    STA $slopeFracAccum
    LSR                   ; step = accumulator >> 4
    LSR 
    LSR 
    LSR 
    BEQ loc_02D4D7        ; Step is zero: keep the full $24 for this tick
    STA $24               ; Nonzero step: $24 is replaced by the step (a much smaller move than the full $24)
    ASL                   ; accumulator -= step << 4 (ASL x4, negate with EOR / INC, add)
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
; Left foot (current BL) on type $09. If the current top-right is $09 too the player is stopped (ClearMovementDeltas). Otherwise ProbeFutureBL: when the row is not on a tile line and FutureBL is $09, the cell right of it and the cell above that must both be empty (any other result clears playerSpeedNs through ClearSpeedNS_3), then the slide runs. In every other case SnapXWestCollision moves X to the next tile centre east, FutureBL is probed again: type 0, $01 or $09 slides, any other type floors Y (SnapYSouthCollision) and applies the move. The slide is ComputeSouthSnapOffset then FineAdjustXWest.

SouthWallNorthInteract {
    JSR $&tile_collision.ProbeCurrentTR ; Current top-right corner: also $09 means the player is boxed in
    CMP #$09              ; Top-right $09 as well: ClearMovementDeltas ($20 and $24 = 0) and stop
    BNE loc_02D4E4
    JMP $&tile_collision.ClearMovementDeltas

  loc_02D4E4:
    JSR $&tile_collision.ProbeFutureBL ; Destination bottom-left probe; carry is not used, CheckSubTileAlignY and the type compare follow
    JSR $&tile_collision.CheckSubTileAlignY ; Carry clear = Y flush with a row line
    BCC loc_02D504        ; On a row line: skip the gap test, go to the X snap at loc_02D504
    CMP #$09              ; Straddling rows and FutureBL is $09: run the gap test; any other type goes to the X snap
    BNE loc_02D504

  loc_02D4F0:
    JSR $&tile_collision.MapCellRight ; Gap test: the cell one column right of FutureBL (index from $00) must be empty
    STX $00
    JSR $&tile_collision.ReadCollisionNibble
    BNE ClearSpeedNS_3
    JSR $&tile_collision.MapCellUp ; Then the cell above that one must be empty too; otherwise ClearSpeedNS_3
    JSR $&tile_collision.ReadCollisionNibble
    BNE ClearSpeedNS_3
    BRA loc_02D51C        ; Both cells empty: slide (loc_02D51C)

  loc_02D504:
    JSR $&player_move_west.SnapXWestCollision ; SnapXWestCollision with $20 = 0: X = ((X - 32) AND $FFC0) + $60, the next tile centre EAST (up to 16 px), playerSpeedEw zeroed
    JSR $&tile_collision.ProbeFutureBL ; Re-probe FutureBL after diagonal X snap
    BCC loc_02D51C        ; Type 0 at the destination: slide
    CMP #$01              ; Type $01 or $09 at the destination: slide
    BEQ loc_02D51C
    CMP #$09
    BEQ loc_02D51C
    REP #$20

  loc_02D516:
    JSR $&SnapYSouthCollision ; Any other nonzero type: floor Y (zeroes playerSpeedNs) and apply the move
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02D51C:
    REP #$20
    JSR $&ComputeSouthSnapOffset ; Measure the penetration into $02
    JMP $&FineAdjustXWest ; FineAdjustXWest: net movement EAST, away from the wall under the left foot
}

---------------------------------------------
; FutureBL is type $09. If the cell right of it is solid ($0E+) the Y floor path at loc_02D516 runs (SnapYSouthCollision then ApplyMovementDeltas), otherwise it joins the gap test in SouthWallNorthInteract (loc_02D4F0).

SouthWallNorthProbe {
    JSR $&tile_collision.MapCellRight ; Cell one column right of FutureBL (index in $00)
    JSR $&tile_collision.ReadCollisionNibble
    CMP #$0E              ; Solid there: floor Y and apply (loc_02D516); otherwise join the gap test
    BCS loc_02D516
    BRA loc_02D4F0        ; Passable below future BL → join north-wall gap probe chain

; Zero playerSpeedNs and return; no position change. Used by the $09 gap test when a neighbouring cell is occupied.

  ClearSpeedNS_3:
    REP #$20
    STZ $playerSpeedNs    ; Gap under the north wall: zero playerSpeedNs and return, no movement applied
    RTS 
}

---------------------------------------------
; Right foot (current BR) on type $06; mirror of SouthWallNorthInteract. Current top-left $06 stops the player. Otherwise ProbeFutureBR: when the row is off a tile line and FutureBR is $06 the cell left of it and the one above must be empty (else ClearSpeedNS_4), then the slide runs. In every other case SnapXEastCollision (X floored to the tile centre, i.e. moved WEST) and FutureBR is re-probed: still $06 slides; otherwise $24 is zeroed, SnapYNorthCollision runs and the move is applied. The slide is ComputeSouthSnapOffset then FineAdjustXEast. Using the NORTH snap here adds one extra row ($40) after the floor.

SouthWallSouthInteract {
    JSR $&tile_collision.ProbeCurrentTL ; Current top-left corner: also $06 means the player is boxed in
    CMP #$06              ; Top-left $06 as well: ClearMovementDeltas and stop
    BNE loc_02D540
    JMP $&tile_collision.ClearMovementDeltas

  loc_02D540:
    JSR $&tile_collision.ProbeFutureBR ; Destination bottom-right probe
    JSR $&tile_collision.CheckSubTileAlignY ; Carry clear = Y flush with a row line
    BCC loc_02D560        ; On a row line: skip the gap test, go to the X snap at loc_02D560
    CMP #$06              ; Straddling rows and FutureBR is $06: run the gap test; any other type goes to the X snap
    BNE loc_02D560

  loc_02D54C:
    JSR $&tile_collision.MapCellLeft ; Gap test: the cell one column LEFT of FutureBR must be empty
    STX $00
    JSR $&tile_collision.ReadCollisionNibble
    BNE ClearSpeedNS_4
    JSR $&tile_collision.MapCellUp ; Then the cell above that one must be empty too; otherwise ClearSpeedNS_4
    JSR $&tile_collision.ReadCollisionNibble
    BNE ClearSpeedNS_4
    BRA loc_02D574        ; Both cells empty: slide (loc_02D574)

  loc_02D560:
    JSR $&player_move_east.SnapXEastCollision ; SnapXEastCollision with $20 = 0: X = ((X - 32) AND $FFC0) + $20, the tile centre to the WEST (up to 16 px), playerSpeedEw zeroed
    JSR $&tile_collision.ProbeFutureBR ; Probe FutureBR again after the X snap
    CMP #$06              ; Still $06: slide
    BEQ loc_02D574
    REP #$20              ; Still blocked: back to 16-bit A
    STZ $24
    JSR $&player_move_ns.SnapYNorthCollision ; SnapYNorthCollision floors then adds $40, one row further south than SnapYSouthCollision would
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02D574:
    REP #$20
    JSR $&ComputeSouthSnapOffset ; Measure the penetration into $02
    JMP $&FineAdjustXEast ; FineAdjustXEast: net movement WEST, away from the wall under the right foot
}

---------------------------------------------
; Branch shim: enters the south-wall gap test (loc_02D54C in SouthWallSouthInteract) from DispatchSouthMove when FutureBL or the cell to its right is type $06.

SouthSlideJumpShim {
    BRA loc_02D54C        ; Jump into the south-wall gap test (left cell and cell above)

; Zero playerSpeedNs and return; no position change. Used by the $06 gap test (SouthWallSouthInteract and SouthSlideJumpShim).

  ClearSpeedNS_4:
    REP #$20
    STZ $playerSpeedNs    ; Gap under south wall lip: clear $playerSpeedNs
    RTS 
}

---------------------------------------------
; Corner assist for a blocked south step: nudge X by 2 pixels toward the open column. Returns carry CLEAR when X was nudged, carry SET when nothing happened.
; 
; Gates: $AA bit $0040 (the horizontal phase ran this tick), an actor solid mark in the collision byte at X, or n = 0 each return carry set. n = ((X >> 2) - 8) AND $0F is the left-edge offset inside its 16-pixel column (X is the centre, the left edge is X - 8). n >= 6: east nudge, if FutureBR is passable (< $0E): $22 is shifted by -$20 so the helper works on the left edge, NudgeAxisPlus8Clamped adds 8 sub-pixels, then +$20 restores the reference. n <= 8 (also when the east test failed): west nudge, if FutureBL is passable, through NudgeAxisMinus8Clamped (-8 sub-pixels).

AutoAlignEW_South {
    REP #$20
    LDA $AA               ; Gate 1: $AA bit $0040 = the horizontal (EW) phase ran this tick
    BIT #$0040            ; Horizontal phase ran: no nudge, carry set
    BNE loc_02D5F7
    LDA $collisionLayer, X ; Raw collision byte at the map index in X (left by the last probe)
    AND #$00FF
    BIT #$00F0            ; High nibble = actor solid mark (MarkSolid*): an actor occupies the cell, no nudge
    BNE loc_02D5F7
    LDA $22               ; n = ((X >> 2) - 8) AND $0F = left-edge offset inside its 16-pixel column (X is the centre, the left edge is X - 8)
    LSR 
    LSR 
    AND #$000F
    SEC 
    SBC #$0008
    AND #$000F
    STA $04               ; $04 = n for the range tests below
    BEQ loc_02D5F7        ; Offset zero → already on X grid line, skip nudge
    CMP #$0006            ; n >= 6: try the east nudge first (needs FutureBR passable)
    BCC loc_02D5D0
    JSR $&tile_collision.ProbeFutureBR ; Right foot's destination must be passable (< $0E)
    CMP #$000E
    BCS loc_02D5D0
    LDX #$0022            ; X = $22: the Nudge helpers work on the word at $00,X; shifting it by -$20 (8 px) makes them test the left edge
    LDA $00, X
    SEC 
    SBC #$0020
    STA $00, X
    JSR $&player_move_main.NudgeAxisPlus8Clamped ; NudgeAxisPlus8Clamped: +8 sub-pixels (2 px east), snapped when it would cross a $40 boundary
    LDA $00, X
    CLC 
    ADC #$0020            ; Undo the -$20 reference shift; the nudge itself stays in $22
    STA $00, X
    CLC                   ; Carry clear: X was nudged east
    RTS 

  loc_02D5D0:
    LDA $04
    CMP #$0009            ; n >= 9: no west nudge; only n 1-8 may nudge west
    BCS loc_02D5F7
    JSR $&tile_collision.ProbeFutureBL ; Left foot's destination must be passable (< $0E) for the west nudge
    CMP #$000E
    BCS loc_02D5F7
    LDX #$0022            ; Same left-edge reference shift as above
    LDA $00, X
    SEC 
    SBC #$0020
    STA $00, X
    JSR $&player_move_main.NudgeAxisMinus8Clamped ; NudgeAxisMinus8Clamped: -8 sub-pixels (2 px west)
    LDA $00, X
    CLC 
    ADC #$0020
    STA $00, X
    CLC                   ; Carry clear: X was nudged west
    RTS 

  loc_02D5F7:
    SEC                   ; Nothing nudged: carry set, the caller does the hard Y snap
    RTS 
}

---------------------------------------------
; Computes $02, the penetration measure for the wall slide: low nibble of the probe Y ($1E AND $0F) plus $10 when the south step crosses a 16-pixel row line. The wall path (current BL is $09, or the cell right of a straddling hitbox is $06) tests the crossing: with v = $24 >> 2 and Y the restored probe Y, bit 4 of ((Y - v) XOR Y) set means the row line was crossed. All other cases use the low nibble alone. $1A / $1E are saved on the stack and restored before the final add, so the caller's probe coordinates survive.

ComputeSouthSnapOffset {
    REP #$20              ; Save the caller's probe pixels $1A / $1E on the stack
    LDA $1A
    PHA 
    LDA $1E
    PHA 
    SEP #$20
    JSR $&tile_collision.ProbeCurrentBL ; Current bottom-left probe: type $09 takes the wall path
    CMP #$09
    BEQ loc_02D619
    JSR $&tile_collision.CheckSubTileAlignX ; Not $09: straddling two columns is needed to test the right-hand cell
    BCC loc_02D640
    JSR $&tile_collision.MapCellRight ; Cell one column right of the current BL: type $06 takes the wall path
    JSR $&tile_collision.ReadCollisionNibble
    CMP #$06
    BNE loc_02D640

  loc_02D619:
    REP #$20              ; Wall path: restore $1E / $1A, then predict whether the step crosses a row line
    PLA 
    STA $1E
    PLA 
    STA $1A
    STZ $02               ; $02 = 0 before the crossing test
    LDA $1E
    PHA 
    LDA $24               ; v = $24 >> 2 (the step in pixels)
    LSR 
    LSR 
    SEC                   ; A = v - Y (Y = restored $1E on the stack); the EOR / INC below negates it to Y - v
    SBC $01, S
    EOR #$FFFF
    INC 
    EOR $01, S            ; (Y - v) XOR Y
    BIT #$0010            ; Bit 4 changed = the step crosses a 16-pixel row line
    BEQ loc_02D63D
    LDA #$0010            ; Crossing: $02 = $10
    STA $02

  loc_02D63D:
    PLA 
    BRA loc_02D64A

  loc_02D640:
    REP #$20              ; Non-wall path: restore $1E / $1A and use the low nibble alone ($02 = 0)
    PLA 
    STA $1E
    PLA 
    STA $1A
    STZ $02

  loc_02D64A:
    LDA $1E               ; $02 += $1E AND $0F (the probe Y's offset inside its row)
    AND #$000F
    CLC 
    ADC $02
    STA $02
    RTS 
}

---------------------------------------------
; X correction for the $06 / right-foot case. n = left-edge offset in its column (16 when flush). If n + $02 <= 16 only ApplyMovementDeltas runs. Otherwise $02 becomes 16 - $02, the left edge is set to (column line, one column back when flush) | $02, and $22 = (left edge + 8) << 2. Because 16 - $02 < n in that branch, the net movement is WEST by n + $02 - 16 pixels (away from a wall under the right foot), not east. $02 can reach $1F; above $10 the subtraction goes negative and the ORA produces a wrapped X. FineAdjustXWest handles that range (it subtracts 16); this routine does not.

FineAdjustXEast {
    LDX $playerActor      ; Player actor base for the pixel X read below
    LDA $0014, X          ; Actor pixel X (centre)
    SEC                   ; Sub-tile X distance from pixel: (actor+$14 - 8) & $0F
    SBC #$0008            ; Left edge = X - 8
    AND #$000F            ; n = left-edge offset in its column
    BNE loc_02D667
    LDA #$0010            ; Flush with a column line: n = 16

  loc_02D667:
    CLC 
    ADC $02               ; t = n + $02; up to 16 needs no X correction
    CMP #$0011
    BCS loc_02D672
    JMP $&tile_collision.ApplyMovementDeltas ; No correction: apply the move

  loc_02D672:
    LDA #$0010            ; t > 16: $02 = 16 - $02. For $02 above $10 this goes negative and the ORA below wraps X
    SEC 
    SBC $02
    STA $02
    LDA $0014, X          ; Re-read pixel X for grid alignment step
    SEC 
    SBC #$0008
    BIT #$000F            ; Flush with a column line?
    BNE loc_02D68A
    SEC                   ; Flush: step back one column first
    SBC #$0010

  loc_02D68A:
    AND #$FFF0            ; Left edge = column line | $02 (an offset smaller than n, so X moves west)
    ORA $02
    CLC 
    ADC #$0008            ; Back to the centre (+8)
    ASL                   ; Pixels to sub-pixels (x4) into $22
    ASL 
    STA $22
    JMP $&tile_collision.ApplyMovementDeltas
}

---------------------------------------------
; X correction for the $09 / left-foot case. m = 16 - n (distance to the next column line east, 16 when flush). If m + $02 <= 16 only ApplyMovementDeltas runs. Otherwise $02 is re-derived through ORA #$FFF0 / EOR #$FFFF / INC (equal to $02 for 1-16, $02 - 16 above that), the left edge is set to (column line | $02) and $22 = (left edge + 8) << 2: net movement EAST by $02 - n pixels (away from a wall under the left foot). Handles $02 > 16, which FineAdjustXEast does not.

FineAdjustXWest {
    LDX $playerActor      ; FineAdjustXWest: push X EAST away from the $09 wall under the left foot (the mirror of FineAdjustXEast)
    LDA $0014, X
    SEC                   ; m = 16 - n: negate the offset through ORA #$FFF0 / EOR #$FFFF / INC (16 when flush)
    SBC #$0008
    ORA #$FFF0
    EOR #$FFFF
    INC 
    CLC                   ; t = m + $02; up to 16 needs no X correction
    ADC $02
    CMP #$0011
    BCS loc_02D6B6
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02D6B6:
    LDA #$0010            ; t > 16: re-derive $02 (stays $02 for 1-16, becomes $02 - 16 above)
    SEC 
    SBC $02
    ORA #$FFF0
    EOR #$FFFF
    INC 
    STA $02
    LDA $0014, X          ; Pixel X again
    SEC 
    SBC #$0008
    AND #$FFF0            ; Left edge = column line | $02: east of the old edge by $02 - n
    ORA $02
    CLC 
    ADC #$0008            ; Back to the centre (+8)
    ASL                   ; Pixels to sub-pixels (x4) into $22
    ASL 
    STA $22
    JMP $&tile_collision.ApplyMovementDeltas
}