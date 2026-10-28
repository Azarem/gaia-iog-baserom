; Slope physics for eastward player movement (186435-187085, Bank 02). The four handlers are entered ONLY from DispatchEastMove (player_move_east); the west dispatcher (player_move_west) has its own ramp code (WestRampDescend and friends) and does not call here. The older header said 'shared between east and diagonal dispatchers'.
; 
; They call back into player_move_west (CancelVerticalPhase), player_move_east (EastWallNorthDiag / EastWallSouthDiag), player_move_south (SnapYSouthCollision) and player_move_ns (SnapYNorthCollision).
; 
; === ENTRY MAP ===
; 
;   EastRampDown : FindSlopeForEastMove found $0A (carry clear)
;   WestRampUp   : FindSlopeForEastMove found $05 (carry set)
;   EastRampUp   : ProbeCurrentBL read $0A (late path of DispatchEastMove)
;   WestRampDown : ProbeCurrentBL read $05
; 
; (The header of player_move_east says the $05 FindSlopeForEastMove result goes to WestRampDown; its code jumps to WestRampUp.)
; 
; Tile types: $0A (east-facing) is a surface that falls toward the east, Y grows with X; $05 (west-facing) rises toward the east. Both direct paths agree: $0A adds the X velocity to Y ($26 += $20), $05 subtracts it. 'Up' / 'Down' in the names is not the Y direction: EastRampUp's direct path also descends.
; 
; === COORDINATES ===
; 
; $1A is the probe pixel X and $1E the probe pixel Y (tile_collision convention). '$1A -= 8' therefore moves the probe 8 px WEST; it is not 'Y up' as many older inline comments said. ProbeCurrentTR leaves $1A = X + 8 and $1E = Y - 16 (hitbox top row); ProbeCurrentBR leaves $1A = X + 8 and $1E = Y (bottom + 1); ProbeCurrentBL leaves $1A = X - 8 and $1E = Y. The -8 / +8 therefore lands on the hitbox centre column X. FutureTR minus 9 is one pixel west of the post-step centre column.
; 
; === COMMON FLOW ===
; 
; 1. CancelVerticalPhase zeroes the word at $05,S, the vertical velocity PlayerMovementTick parked on its stack, so the NS phase later does nothing and these handlers own the Y movement.
; 2. Probe the slope type in several cells (listed in each handler note). No slope: the Redirect handlers (FutureTR $09 -> EastWallNorthDiag, FutureBR $06 -> EastWallSouthDiag) or ApplyMovementDeltas.
; 3. Slope found:
;    - direct entries (the first samples hit the slope cell or the cell next to it, no crossing test): $26 -/+= $20, the X velocity copied 1:1 into Y (a 45-degree slope).
;    - after the future probe: CheckTileBoundaryXor (Z clear = this step crosses a 16-px column line). No crossing: plain ApplyMovementDeltas. Crossing: n = ((X + step) in px) AND $0F, the pixels past the line. EastRampDown: $26 += 4n; WestRampUp: $26 -= 4n; then +4 / -4 (one pixel; positions are quarter pixels) when bit 2 of ($26 + $20 + $22) is set (a Y position plus X values, as in the original). EastRampUp / WestRampDown instead set $24 = $20 - 4n / 4n - $20, which ApplyMovementDeltas applies.
; 4. playerFlags |= $1000 (on slope / ramp), then the FutureTR and FutureBR wall check ($0E+ = solid): both open -> ApplyMovementDeltas; TR open and BR solid -> SnapYSouthCollision; TR solid and BR open -> SnapYNorthCollision; both solid -> corner snap.
; 5. Corner snap: X = (left edge of the post-step position, floored to a 16-px column line) + 8, so it only ever moves west; $26 += old X + $20 - new X (the distance pulled back); $20, $24 and playerSpeedEw are zeroed and SetActorCollisionFlag is called. The Y compensation has the same sign in the $0A and $05 handlers (OQ-I038-2).
; 
; Everything here is UNVERIFIED-RUNTIME (no emulator trace); the arithmetic is read from the code.
---------------------------------------------

?BANK 02

?INCLUDE 'player_move_east'
?INCLUDE 'player_move_ns'
?INCLUDE 'player_move_south'
?INCLUDE 'player_move_west'
?INCLUDE 'tile_collision'

!playerFlags                    09AE
!playerSpeedEw                  09B2

---------------------------------------------

; Entered when FindSlopeForEastMove found $0A: descend while moving east. Samples: TR probe at (X, top row); the cell below it; FutureTR at (X + step - 1); the cell below that. Hits on the first two take the direct step (code_02D8C7); hits on the last two take the column-crossing test; no hit -> EastRedirectToNorth. See the block note.

EastRampDown {
    JSR $&player_move_west.CancelVerticalPhase ; Zero the word at $05,S (vertical velocity parked by PlayerMovementTick): the NS phase does nothing, this handler owns Y
    JSR $&tile_collision.ProbeCurrentTR ; TR probe: $1A = X + 8 (right edge + 1), $1E = Y - 16 (hitbox top row)
    LDA $1A               ; $1A is the probe pixel X (not Y): 8 px west of the right edge = the hitbox centre column; $1E keeps the top row
    SEC 
    SBC #$0008
    STA $1A
    JSR $&tile_collision.TileProbeMain ; Slope sample at (X, top row): type $0A takes the direct step
    AND #$00FF
    CMP #$000A
    BEQ code_02D8C7
    JSR $&tile_collision.MapCellDown ; No $0A there: step the map index in $00 one row down and read that cell
    SEP #$20
    JSR $&tile_collision.ReadCollisionNibble
    REP #$20
    AND #$00FF
    CMP #$000A
    BEQ code_02D8C7
    JSR $&tile_collision.ProbeFutureTR ; Probe at the post-step position: $1A = X + step + 8
    LDA $1A               ; $1A -= 9: one pixel west of the post-step centre column (X pixels, not Y)
    SEC 
    SBC #$0009
    STA $1A
    JSR $&tile_collision.TileProbeMain ; Post-step sample must be $0A for the slope to continue
    AND #$00FF
    CMP #$000A
    BEQ loc_02D899
    JSR $&tile_collision.MapCellDown ; Or the cell one row below the post-step sample
    SEP #$20
    JSR $&tile_collision.ReadCollisionNibble
    REP #$20
    AND #$00FF
    CMP #$000A
    BEQ loc_02D899
    JMP $&EastRedirectToNorth ; No $0A slope in any probe: EastRedirectToNorth (north-wall fallback)

  loc_02D899:
    JSR $&tile_collision.CheckTileBoundaryXor ; Z clear = this step crosses a 16-px column line
    BNE loc_02D8A1
    JMP $&tile_collision.ApplyMovementDeltas ; No boundary cross → ApplyMovementDeltas without slope Y adjustment

  loc_02D8A1:
    LDA $20               ; n = ((step + X) >> 2) AND $0F = pixels past the column line after the step (not a mean X); Y gets 4n quarter-pixels
    CLC 
    ADC $22
    LSR 
    LSR 
    AND #$000F
    ASL 
    ASL 
    CLC 
    ADC $26               ; $26 += 4n: Y follows the slope by the part of the step inside the new column
    STA $26
    CLC 
    ADC $20
    CLC 
    ADC $22
    LSR                   ; Three LSRs: the carry out of the third is bit 2 of ($26 + $20 + $22), a Y position plus X values as in the original
    LSR 
    LSR 
    BCC code_02D8CE
    LDA $26               ; Carry set: $26 += 4 (one pixel; positions are quarter pixels, so not a half-pixel)
    CLC 
    ADC #$0004
    STA $26
    BRA code_02D8CE

  code_02D8C7:
    LDA $20               ; Direct step: $26 += $20, the X velocity copied 1:1 into Y (45-degree slope); used when the sample or the cell below is $0A
    CLC 
    ADC $26
    STA $26

  code_02D8CE:
    LDA #$1000            ; Set playerFlags bit $1000 — player is traversing a slope this frame
    TSB $playerFlags
    SEP #$20
    JSR $&tile_collision.ProbeFutureTR ; Post-slope wall check: ProbeFutureTR for solid ($0E+) at destination
    CMP #$0E
    BCS loc_02D8EA
    JSR $&tile_collision.ProbeFutureBR ; TR passable: also probe FutureBR — both corners must be open
    CMP #$0E
    BCS loc_02D8E7
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02D8E7:
    JMP $&RampSnapEastSouthBrWall ; TR open, BR solid -> RampSnapEastSouthBrWall (SnapYSouthCollision)

  loc_02D8EA:
    JSR $&tile_collision.ProbeFutureBR ; TR blocked: probe FutureBR — partial wall contact at top-right corner
    CMP #$0E
    BCS loc_02D8F4
    JMP $&RampSnapEastNorthTrWall ; TR wall + BR open → SnapYNorthCollision corner resolution

  loc_02D8F4:
    REP #$20              ; Both TR and BR blocked: full corner snap — align X to tile grid, recompute Y
    LDA $22               ; Both blocked: save $22, then X' = post-step left edge floored to a 16-px column line, + 8 (centre), in quarter pixels
    PHA 
    CLC 
    ADC $20
    LSR 
    LSR 
    SEC                   ; Left edge = (X + step) px - 8; floor to a 16-px line unless already flush; +8 and x4 give the new centre X (west moves only)
    SBC #$0008
    BIT #$000F
    BEQ loc_02D90A
    AND #$FFF0

  loc_02D90A:
    CLC 
    ADC #$0008
    ASL 
    ASL 
    STA $22
    SEC 
    SBC $01, S            ; A = new X - old X, minus $20, negated below: $26 += the distance pulled back (same sign as WestRampUp)
    SEC 
    SBC $20
    EOR #$FFFF
    INC 
    CLC 
    ADC $26
    STA $26
    PLA 
    STZ $20               ; Zero the X velocity ($20), Y velocity ($24) and playerSpeedEw after the snap
    STZ $24
    STZ $playerSpeedEw
    JSR $&tile_collision.SetActorCollisionFlag
    JMP $&tile_collision.ApplyMovementDeltas
}

---------------------------------------------
; East ramp post-move corner fix when future TR is passable but BR is solid: calls SnapYSouthCollision then ApplyMovementDeltas; reached from EastRampDown/EastRampUp wall probes.

RampSnapEastSouthBrWall {
    REP #$20              ; TR open, BR solid: SnapYSouthCollision (the old text said TR-only and SnapXEastCollision)
    JSR $&player_move_south.SnapYSouthCollision
    JMP $&tile_collision.ApplyMovementDeltas
}

---------------------------------------------
; East ramp path when TR is blocked but BR is open: SnapYNorthCollision then ApplyMovementDeltas.

RampSnapEastNorthTrWall {
    REP #$20              ; TR solid, BR open: SnapYNorthCollision (the old text said BR-only)
    JSR $&player_move_ns.SnapYNorthCollision
    JMP $&tile_collision.ApplyMovementDeltas
}

---------------------------------------------
; Entered from DispatchEastMove when ProbeCurrentBL read $0A. Samples (X, bottom + 1); not $0A -> ApplyMovementDeltas. $0A with no column crossing -> the direct step (Y += $20); with a crossing $24 = $20 - 4n (n = pixels past the column line after the step). Finishes at code_02D8CE.

EastRampUp {
    JSR $&player_move_west.CancelVerticalPhase ; EastRampUp: east on slope $0A (the surface falls toward east, Y grows with X; 'Up' in the name is misleading)
    LDA $1A               ; $1A (probe pixel X) = BL probe X - 8; +8 below makes it the centre column X; $1E = bottom + 1 from the BL probe
    CLC 
    ADC #$0008
    STA $1A
    JSR $&tile_collision.TileProbeMain ; Sample at (X, bottom + 1) must be $0A, else movement proceeds unchanged
    AND #$00FF
    CMP #$000A
    BEQ loc_02D958
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02D958:
    JSR $&tile_collision.CheckTileBoundaryXor ; Z clear = this step crosses a 16-px column line
    BNE loc_02D960
    JMP $&code_02D8C7     ; No crossing: direct step $26 += $20 (a descent along $0A despite the Up name)

  loc_02D960:
    LDA $20               ; Crossing: n = ((step px) + X) AND $0F; $24 = $20 - 4n replaces the vertical velocity
    LSR 
    LSR 
    CLC 
    ADC $1A
    AND #$000F
    ASL 
    ASL 
    SEC                   ; 4n - $20, negated by EOR / INC below, so $24 = $20 - 4n
    SBC $20
    EOR #$FFFF
    INC 
    STA $24
    JMP $&code_02D8CE     ; Finish: set the slope flag and run the FutureTR / FutureBR wall check
}

---------------------------------------------
; Fallback when no slope tile is found after the full EastRampDown probe sequence.
; 
; Probes FutureTR: if $09 (north wall) → redirect to EastWallNorthDiag for diagonal wall interaction. Otherwise → ApplyMovementDeltas (continue movement unimpeded).

EastRedirectToNorth {
    JSR $&tile_collision.ProbeFutureTR ; EastRedirectToNorth: no $0A slope found — probe FutureTR for north wall $09
    CMP #$0009
    BNE loc_02D983
    JMP $&player_move_east.EastWallNorthDiag ; North wall at destination → EastWallNorthDiag slide redirect

  loc_02D983:
    JMP $&tile_collision.ApplyMovementDeltas
}

---------------------------------------------
; Entered when FindSlopeForEastMove found $05. Mirror of EastRampDown: BR probe at (X, bottom + 1), MapCellUp on the first retry, FutureTR at (X + step - 1) then MapCellDown, and negated Y (crossing: $26 -= 4n with a -4 bias; direct: $26 -= $20). Finishes at code_02DA19 with the same snaps.

WestRampUp {
    JSR $&player_move_west.CancelVerticalPhase ; WestRampUp: ascend west-facing slope $05 while moving east (+X)
    JSR $&tile_collision.ProbeCurrentBR ; BR probe: $1A = X + 8, $1E = Y (bottom + 1)
    LDA $1A               ; $1A is the probe pixel X: -8 below moves it west to the centre column (not Y)
    SEC 
    SBC #$0008
    STA $1A
    JSR $&tile_collision.TileProbeMain ; Sample at (X, bottom + 1) must be $05: direct step
    AND #$00FF
    CMP #$0005
    BEQ code_02DA0E
    JSR $&tile_collision.MapCellUp ; No $05: step the map index in $00 one row up and read that cell
    SEP #$20
    JSR $&tile_collision.ReadCollisionNibble
    REP #$20
    AND #$00FF
    CMP #$0005
    BEQ code_02DA0E
    JSR $&tile_collision.ProbeFutureTR ; Post-step probe (TR here, BR for the first sample): $1A = X + step + 8
    LDA $1A               ; $1A -= 9: one pixel west of the post-step centre column (X pixels, not Y)
    SEC 
    SBC #$0009
    STA $1A
    JSR $&tile_collision.TileProbeMain ; Post-step sample must be $05 for the slope to continue
    AND #$00FF
    CMP #$0005
    BEQ loc_02D9DC
    JSR $&tile_collision.MapCellDown ; MapCellDown on future cell for alternate $05 detection
    SEP #$20
    JSR $&tile_collision.ReadCollisionNibble
    REP #$20
    AND #$00FF
    CMP #$0005
    BEQ loc_02D9DC
    JMP $&WestRedirectToSouth ; No matching $05 slope chain → WestRedirectToSouth wall fallback

  loc_02D9DC:
    JSR $&tile_collision.CheckTileBoundaryXor ; CheckTileBoundaryXor: boundary-cross Y displacement for west-facing ramp
    BNE loc_02D9E4
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02D9E4:
    LDA $20               ; n as in EastRampDown; $26 -= 4n (EOR / INC below negates)
    CLC 
    ADC $22
    LSR 
    LSR 
    AND #$000F
    ASL 
    ASL 
    EOR #$FFFF
    INC 
    CLC 
    ADC $26
    STA $26
    CLC 
    ADC $20
    CLC 
    ADC $22
    LSR                   ; Carry out of the third LSR = bit 2 of ($26 + $20 + $22); set -> $26 -= 4 (one pixel)
    LSR 
    LSR 
    BCC code_02DA19
    LDA $26               ; Carry set: $26 -= 4 (one pixel, not a half-pixel)
    SEC 
    SBC #$0004
    STA $26
    BRA code_02DA19

  code_02DA0E:
    LDA $20               ; Direct step: $26 -= $20, the X velocity mirrored into Y (the surface rises toward the east)
    EOR #$FFFF
    INC 
    CLC 
    ADC $26
    STA $26

  code_02DA19:
    LDA #$1000            ; Set playerFlags bit $1000 — slope traversal active
    TSB $playerFlags
    SEP #$20
    JSR $&tile_collision.ProbeFutureTR ; Post-slope wall check: ProbeFutureTR then FutureBR for solid ($0E+)
    CMP #$0E
    BCS loc_02DA35
    JSR $&tile_collision.ProbeFutureBR
    CMP #$0E
    BCS loc_02DA32
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02DA32:
    JMP $&RampSnapWestSouthBrWall ; TR open, BR solid -> RampSnapWestSouthBrWall (SnapYSouthCollision)

  loc_02DA35:
    JSR $&tile_collision.ProbeFutureBR ; TR blocked at corner: probe FutureBR for partial wall resolution
    CMP #$0E
    BCS loc_02DA3F
    JMP $&RampSnapWestNorthTrWall ; TR solid, BR open -> RampSnapWestNorthTrWall (SnapYNorthCollision)

  loc_02DA3F:
    REP #$20              ; Both blocked: same corner snap as EastRampDown (identical code, same Y sign)
    LDA $22
    PHA 
    CLC 
    ADC $20
    LSR 
    LSR 
    SEC                   ; Floor the post-step left edge (X px - 8) to a 16-px line; +8 below recentres on that column; x4 back to sub-pixels
    SBC #$0008
    BIT #$000F
    BEQ loc_02DA55
    AND #$FFF0

  loc_02DA55:
    CLC 
    ADC #$0008
    ASL 
    ASL 
    STA $22
    SEC                   ; Y snap from X grid delta, negated, merged into $26
    SBC $01, S
    SEC 
    SBC $20
    EOR #$FFFF
    INC 
    CLC 
    ADC $26
    STA $26
    PLA 
    STZ $20
    STZ $24
    STZ $playerSpeedEw
    JSR $&tile_collision.SetActorCollisionFlag
    JMP $&tile_collision.ApplyMovementDeltas
}

---------------------------------------------
; West ramp analogue of the TR-open BR-solid case: SnapYSouthCollision then ApplyMovementDeltas from WestRampDown/WestRampUp probes.

RampSnapWestSouthBrWall {
    REP #$20              ; TR open, BR solid: SnapYSouthCollision (the old text said TR-only and SnapXEastCollision)
    JSR $&player_move_south.SnapYSouthCollision
    JMP $&tile_collision.ApplyMovementDeltas
}

---------------------------------------------
; West ramp TR-blocked BR-open case: SnapYNorthCollision then ApplyMovementDeltas.

RampSnapWestNorthTrWall {
    REP #$20              ; TR solid, BR open: SnapYNorthCollision (the old text said BR-only)
    JSR $&player_move_ns.SnapYNorthCollision
    JMP $&tile_collision.ApplyMovementDeltas
}

---------------------------------------------
; Entered from DispatchEastMove when ProbeCurrentBL read $05. Samples (X, bottom + 1) for $05; no crossing -> code_02DA0E (Y -= $20); crossing: $24 = 4n - $20 (n as in EastRampUp), negative (upward) while 4n < $20. Y grows downward, so the older 'positive, producing upward displacement' was wrong. Finishes at code_02DA19.

WestRampDown {
    JSR $&player_move_west.CancelVerticalPhase ; WestRampDown: descend west-facing slope $05 while moving east (+X)
    LDA $1A               ; $1A (probe pixel X) = BL X - 8; +8 below makes it the centre column X (not Y); $1E = bottom + 1
    CLC 
    ADC #$0008
    STA $1A
    JSR $&tile_collision.TileProbeMain ; Sample at (X, bottom + 1) must be $05, else movement proceeds unchanged
    AND #$00FF
    CMP #$0005
    BEQ loc_02DAA3
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02DAA3:
    JSR $&tile_collision.CheckTileBoundaryXor ; Z clear = this step crosses a 16-px column line
    BNE loc_02DAAB
    JMP $&code_02DA0E     ; No crossing: direct step $26 -= $20 (the surface rises toward the east)

  loc_02DAAB:
    LDA $20               ; Crossing: n = ((step px) + X) AND $0F; $24 = 4n - $20 (negative = upward while 4n < $20)
    LSR 
    LSR 
    CLC 
    ADC $1A
    AND #$000F
    ASL 
    ASL 
    SEC 
    SBC $20
    STA $24
    JMP $&code_02DA19     ; Finish: set the slope flag and run the FutureTR / FutureBR wall check
}

---------------------------------------------
; Fallback when no $05 slope is found after the WestRampDown probe sequence.
; 
; Probes FutureBR: if $06 (south wall) → redirect to EastWallSouthDiag. Otherwise → ApplyMovementDeltas.

WestRedirectToSouth {
    JSR $&tile_collision.ProbeFutureBR ; WestRedirectToSouth: no $05 slope — probe FutureBR for south wall $06
    CMP #$0006
    BNE loc_02DACA
    JMP $&player_move_east.EastWallSouthDiag ; South wall at destination → EastWallSouthDiag slide redirect

  loc_02DACA:
    JMP $&tile_collision.ApplyMovementDeltas
}