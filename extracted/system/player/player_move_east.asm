; East (positive $20) horizontal-phase collision dispatch, east wall-slide handlers and the Y auto-align (186076-186435 + 187085-187264, Bank 02). DispatchEastMove is called once per tick by PlayerMovementTick after $AA bit $0040 is set. It is the mirror image of DispatchWestMove (player_move_west, the WEST half) and probes the right-hand corners (TR / BR) where the west file probes TL / BL. The slope handlers it jumps to live in player_move_ramps.
; 
; === CONVENTIONS ===
; 
; As in player_move_ns: sub-pixels (4 per pixel), $20 / $22 = X velocity / position, $24 / $26 = Y velocity / position (Y grows downward), $1A / $1E = probe pixel, $00 = map index of the last probe (X still holds it right after a probe), CheckSubTileAlignX / Y carry clear = flush on a 16-px line, carry set = straddling two cells. $06 / $09 are undecoded wall-like types, so 'north wall' / 'south wall' are handler names. In this phase the vertical velocity is parked on PlayerMovementTick's stack and $24 is 0, so the SnapYNorthCollision / SnapYSouthCollision calls here work on the CURRENT Y, not a stepped one.
; 
; === DISPATCH ORDER (DispatchEastMove) ===
; 
; 1. map_coords.FindSlopeForEastMove: slope search at the hitbox centre column (the TR probe X minus 8, i.e. X itself; not a sample 8 px to the left). Z set = slope found: carry set = $05 -> WestRampUp, carry clear = $0A -> EastRampDown.
; 2. ProbeCurrentTR $09 -> EastWallPushDown; ProbeCurrentBR $06 -> EastWallPushUp.
; 3. ProbeFutureTR: $0E and above -> blocked path; $09 -> EastWallNorthFlag.
; 4. CheckSubTileAlignY. Y flush: future TR $06 -> EastWallSouthFlag, anything else on to step 5. Y straddling: future TR $06 -> blocked path; otherwise the cell below the future TR cell (MapCellDown) is read: $0E and above -> blocked, $06 -> EastWallSouthFlag, $09 -> blocked, anything else on to step 5 with A = that lower cell's type.
; 5. A = $07 -> EastLadderTile (A is the future TR type when Y is flush and the lower cell's type when Y straddles). Then ProbeCurrentBL: $05 -> WestRampDown, $0A -> EastRampUp.
; 6. Otherwise $22 += $20.
; 
; Blocked path (loc_02D753): SetActorCollisionFlag, AutoAlignNS_East (Y nudge, carry clear = nudged), then SnapXEastCollision. After a nudge the X snap runs without zeroing playerSpeedEw, so the player keeps pushing east and is walked around the corner.
; 
; SnapXEastCollision: X' = (((X + $20) - 32) AND $FFC0) + 32 (the second $20 is the immediate constant): the column of the stepped left edge, centred, so the right edge (X + 7 px) ends on the last pixel of that column, flush to the wall. With $20 = 0 (the callers in player_move_ns and player_move_south) it only moves X west. It zeroes $20; the full entry also zeroes playerSpeedEw.
; 
; === WALL-SLIDE HANDLERS ===
; 
; EastWallPushDown (current TR $09, or future TR $09 through EastWallNorthFlag) and EastWallPushUp (current BR $06, or future BR $06 through EastWallSouthFlag) mirror code_02DC4B and code_02DC9F of the west file. They set $AB bit 7 (the Flag entries set bit 2 / bit 3 instead); nothing reads those bits. The probe at the future corner plus CheckSubTileAlignX picks the path. X STRADDLING and the corner type matches ($09 / $06): gap chain. X flush, or another type: SnapYNorthCollision / SnapYSouthCollision first (with $24 = 0: the north snap moves the player DOWN to the next row line, 1..16 px; the south snap floors Y, up to 15 px north), then the corner is re-probed: clear or the same type -> the slide, anything else -> SnapXEastCollision + ApplyMovementDeltas.
; 
; Gap chains. North (loc_02D7AB): MapCellDown from the future TR cell must be empty or $0A, then MapCellLeft from that cell must be empty or $09. South (loc_02D7FF): MapCellUp from the future BR cell must be empty or $05, then MapCellLeft must be empty or $06. A failed test goes to ClearSpeedEW_5 / _6 (playerSpeedEw = 0, no position applied this tick). Both pass: ComputeEastSnapOffset, then WallSlidePushDown (north handler) or WallSlidePushUp (south handler).
; 
; Push direction: WallSlidePushDown stores a positive $24 and WallSlidePushUp a negative one (player_move_west) and ApplyMovementDeltas adds $24 to Y, so the $09 handler pushes the player SOUTH and the $06 handler pushes NORTH. Read together with the west file: TL $06 and TR $09 both push south, BL $09 and BR $06 both push north.
; 
; === AutoAlignNS_East / ComputeEastSnapOffset ===
; 
; AutoAlignNS_East returns carry set (no nudge) when the vertical velocity word parked at $06,S is nonzero, when the collision byte at the last probe index carries an actor solid mark (high nibble), or when n = (($26 >> 2) AND $0F) is 0. For n >= 4 it nudges Y south ($26 += 8 sub-pixels, clamped at the next row line) if FutureBR is below $0E; failing that, for n <= 10, it nudges north ($26 -= 8, clamped at the row line) if FutureTR is below $0E. So n = 1..3 can only go north, 4..10 prefers south, 11..15 can only go south.
; 
; ComputeEastSnapOffset: $02 = ($1A AND $0F), plus $10 on the wall path when this step moves the probe across a 16-px column line (bit 4 of $1A XOR ($1A - $20 / 4)). The wall path is taken when the current TR is $09, or when Y straddles and the cell below the current TR is $06; otherwise $02 = $1A AND $0F alone. WallSlidePushDown / WallSlidePushUp add a Y-derived offset to $02 and, above $10, push Y by (total AND $0F) pixels.
; 
; Everything here is UNVERIFIED-RUNTIME (no emulator trace); the arithmetic is read from the code.
---------------------------------------------

?BANK 02

?INCLUDE 'map_coords'
?INCLUDE 'player_character'
?INCLUDE 'player_move_main'
?INCLUDE 'player_move_ns'
?INCLUDE 'player_move_ramps'
?INCLUDE 'player_move_south'
?INCLUDE 'player_move_west'
?INCLUDE 'tile_collision'

!playerActor                    09AA
!playerSpeedEw                  09B2
!collisionLayer                 7FC000

---------------------------------------------

; Entry for positive $20, 8-bit probe mode. Order, exits and the blocked path are described in the block note: JMPs into player_move_ramps or the wall handlers, the plain step $22 += $20, or the blocked path loc_02D753.

DispatchEastMove {
    SEP #$20              ; DispatchEastMove: east/+X movement collision dispatch — 8-bit probe mode
    JSR $&map_coords.FindSlopeForEastMove ; FindSlopeForEastMove (map_coords): slope search at the centre column (TR probe X - 8 = X); Z set = found, carry set = $05, clear = $0A
    BNE loc_02D6EB        ; Z clear = no slope: go on to the wall probes; Z set: carry set -> WestRampUp, carry clear -> EastRampDown
    BCS loc_02D6E8        ; Carry set = $05 -> WestRampUp (the probe is the centre column)
    JMP $&player_move_ramps.EastRampDown ; Carry clear = $0A -> EastRampDown

  loc_02D6E8:
    JMP $&player_move_ramps.WestRampUp ; WestRampUp

  loc_02D6EB:
    JSR $&tile_collision.ProbeCurrentTR ; ProbeCurrentTR at player's leading top-right corner
    CMP #$09              ; Current TR type $09 -> EastWallPushDown (undecoded wall type)
    BNE loc_02D6F5
    JMP $&EastWallPushDown

  loc_02D6F5:
    JSR $&tile_collision.ProbeCurrentBR ; ProbeCurrentBR at leading bottom-right for south-wall check
    CMP #$06              ; Current BR type $06 -> EastWallPushUp (undecoded wall type)
    BNE loc_02D6FF
    JMP $&EastWallPushUp

  loc_02D6FF:
    JSR $&tile_collision.ProbeFutureTR ; ProbeFutureTR one cell east (destination top-right)
    CMP #$0E              ; Solid tile: collision nibble ≥ $0E blocks east entry
    BCS loc_02D753
    CMP #$09              ; Type $09 north wall at destination → EastWallNorthFlag compact handler
    BNE loc_02D70D
    JMP $&EastWallNorthFlag

  loc_02D70D:
    JSR $&tile_collision.CheckSubTileAlignY ; Carry clear = Y flush on a row line (TR and BR in one row); carry set = Y straddles two rows. A keeps the future TR type
    BCS loc_02D71B
    CMP #$06              ; Y flush and future TR $06 -> EastWallSouthFlag; anything else goes on to the ladder test
    BNE loc_02D719
    JMP $&EastWallSouthFlag

  loc_02D719:
    BRA loc_02D734

  loc_02D71B:
    CMP #$06              ; Y straddling (carry set): future TR $06 blocks east entry
    BEQ loc_02D753
    JSR $&tile_collision.MapCellDown ; Y straddling: MapCellDown from the future TR cell = the lower row of the destination column
    JSR $&tile_collision.ReadCollisionNibble
    CMP #$0E              ; Solid ($0E+) in secondary cell → hard block path
    BCS loc_02D753
    CMP #$06              ; South wall ($06) in secondary cell → slide shim redirect
    BNE loc_02D730
    JMP $&EastWallSouthFlag

  loc_02D730:
    CMP #$09              ; North wall ($09) in secondary cell → block east movement
    BEQ loc_02D753

  loc_02D734:
    CMP #$07              ; A = future TR type (Y flush) or lower-cell type (Y straddling, nothing blocked): $07 -> EastLadderTile
    BEQ EastLadderTile
    JSR $&tile_collision.ProbeCurrentBL ; ProbeCurrentBL at bottom-left for slope ascent checks
    CMP #$05              ; Current BL type $05 -> WestRampDown (the ramp names do not give the Y direction, see player_move_ramps)
    BNE loc_02D742
    JMP $&player_move_ramps.WestRampDown

  loc_02D742:
    CMP #$0A              ; Current BL type $0A -> EastRampUp (same remark)
    BNE loc_02D749
    JMP $&player_move_ramps.EastRampUp

  loc_02D749:
    REP #$20
    LDA $22               ; Unblocked east move: $22 (X sub-pixel) += $20 (EW velocity)
    CLC 
    ADC $20
    STA $22
    RTS 

  loc_02D753:
    JSR $&tile_collision.SetActorCollisionFlag ; East blocked: set actor collision-contact flag for this frame
    JSR $&AutoAlignNS_East ; AutoAlignNS_East: try Y-axis ($26) grid nudge before hard snap
    BCS SnapXEastCollision ; Y nudge failed (carry set) → SnapXEastCollision X-snap path
    PHP                   ; Y was nudged: X snap WITHOUT zeroing playerSpeedEw (entry loc_02D766); the push continues next tick
    REP #$20
    BRA loc_02D766
}

---------------------------------------------
; X snap after a blocked east step: X' = (((X + $20) - 32) AND $FFC0) + 32, $20 = 0. The right edge ends flush to the wall; with $20 = 0 (callers in player_move_ns / player_move_south) it only moves X west. The full entry zeroes playerSpeedEw first; the loc_02D766 entry (after a successful Y nudge) keeps it.

SnapXEastCollision {
    PHP                   ; SnapXEastCollision: zero $playerSpeedEw on hard X snap
    REP #$20
    STZ $playerSpeedEw

  loc_02D766:
    LDA $20               ; X' = (((X + $20) - $0020) AND $FFC0) + $0020: centre of the column holding the stepped left edge (right edge flush to the wall)
    CLC 
    ADC $22
    SEC 
    SBC #$0020
    AND #$FFC0
    CLC 
    ADC #$0020
    STA $22
    STZ $20
    PLP 
    RTS 

; Type $07 ahead while moving east (a local label inside DispatchEastMove). CheckSubTileAlignY: Y straddling (carry set) -> blocked path. Y flush: CancelVerticalPhase cancels the vertical phase, the player actor's entry becomes ShimmyRightEntry (low word only) with $0008 = 0, then the blocked path runs (collision flag, Y nudge, X snap). Mirror of DiagLadderTile (ShimmyLeftEntry) in player_move_west. The old 'West prefix' remark refers to a former name; ShimmyRightEntry is the east case.

  EastLadderTile:
    JSR $&tile_collision.CheckSubTileAlignY ; Ladder tile ($07): require Y sub-tile alignment before east shimmy
    BCS loc_02D753
    JSR $&player_move_west.CancelVerticalPhase ; Clear diag return flags; switch player state to ShimmyRightEntry
    PHY 
    REP #$20
    LDY $playerActor
    LDA #$&player_character.ShimmyRightEntry
    STA $0000, Y          ; Write ShimmyRightEntry to actor +$0000; zero the wait counter +$0008
    LDA #$0000
    STA $0008, Y
    PLY 
    BRA loc_02D753        ; Then the blocked path (collision flag, Y nudge, X snap): holds the player at the ladder tile edge

; A single SEP #$20 that falls into EastWallPushDown. player_move_ramps jumps here when its post-ramp FutureTR probe reads $09.

  EastWallNorthDiag:
    SEP #$20              ; EastWallNorthDiag entry (falls through to EastWallPushDown north-wall slide)
}

---------------------------------------------
; Wall-slide handler for TR $09 while moving east. Sets $AB bit 7, ProbeFutureTR, CheckSubTileAlignX. X straddling and $09: gap chain (loc_02D7AB). Otherwise SnapYNorthCollision (player goes DOWN to the next row line), re-probe: clear or $09 -> slide, else SnapXEastCollision + ApplyMovementDeltas. Slide: ComputeEastSnapOffset + WallSlidePushDown, which pushes Y DOWN (positive $24). See the block note.

EastWallPushDown {
    LDA #$80              ; Set $AB bit 7: wall-slide flag, no reader found
    TSB $AB
    JSR $&tile_collision.ProbeFutureTR ; ProbeFutureTR at east destination + CheckSubTileAlignX for slide eligibility
    JSR $&tile_collision.CheckSubTileAlignX ; Carry clear = X flush; carry set = X straddles two columns. A keeps the future TR type
    BCC loc_02D7C7        ; X flush: skip the gap chain, go to the SnapYNorthCollision re-probe path (loc_02D7C7)
    CMP #$09              ; Future TR must be $09 north wall for slide-along-wall path
    BNE loc_02D7C7

  loc_02D7AB:
    JSR $&tile_collision.MapCellDown ; Gap chain: the cell below the future TR cell must be empty or $0A
    STX $00
    JSR $&tile_collision.ReadCollisionNibble
    BEQ loc_02D7B9
    CMP #$0A              ; Not empty and not $0A: abort (ClearSpeedEW_5)
    BNE ClearSpeedEW_5

  loc_02D7B9:
    JSR $&tile_collision.MapCellLeft ; MapCellLeft from that lower cell: its west neighbour must be empty or $09
    JSR $&tile_collision.ReadCollisionNibble
    BEQ loc_02D7D9
    CMP #$09              ; Open north-wall chain → ComputeEastSnapOffset + WallSlidePushDown slide
    BNE ClearSpeedEW_5
    BRA loc_02D7D9

  loc_02D7C7:
    JSR $&player_move_ns.SnapYNorthCollision ; X flush (or type not $09): SnapYNorthCollision first ($24 = 0, so the player goes DOWN to the next row line, 1..16 px)
    JSR $&tile_collision.ProbeFutureTR ; Re-probe FutureTR after Y snap; still $09 → open slide path
    BCC loc_02D7D9
    CMP #$09
    BEQ loc_02D7D9
    JSR $&SnapXEastCollision ; Still blocked: SnapXEastCollision then ApplyMovementDeltas
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02D7D9:
    REP #$20
    JSR $&ComputeEastSnapOffset ; ComputeEastSnapOffset: $02 = push offset (see its note)
    JMP $&player_move_west.WallSlidePushDown ; WallSlidePushDown: positive $24 (Y grows), so the player is pushed SOUTH
}

---------------------------------------------
; Compact entry used when the future TR is already known to be $09: sets $AB bit 2 (no reader) and joins the gap chain at loc_02D7AB, skipping the probe and the X alignment test. ClearSpeedEW_5 is the shared abort: playerSpeedEw = 0 and return.

EastWallNorthFlag {
    LDA #$04              ; Compact entry: set $AB bit 2 (no reader found), then join the gap chain at loc_02D7AB
    TSB $AB
    BRA loc_02D7AB        ; Join shared north-wall adjacency probe chain at loc_02D7AB

; Abort of the north-wall gap chain: playerSpeedEw = 0 and RTS. ApplyMovementDeltas is not run, so no position is applied this tick.

  ClearSpeedEW_5:
    REP #$20              ; ClearSpeedEW_5: abort slide — zero $playerSpeedEw and return
    STZ $playerSpeedEw
    RTS 
}

---------------------------------------------
; A single SEP #$20 that falls into EastWallPushUp. player_move_ramps jumps here when its post-ramp FutureBR probe reads $06.

EastWallSouthDiag {
    SEP #$20              ; EastWallSouthDiag entry (falls through to EastWallPushUp south-wall slide)
}

---------------------------------------------
; Wall-slide handler for BR $06 while moving east. Sets $AB bit 7, ProbeFutureBR, CheckSubTileAlignX. X straddling and $06: gap chain (loc_02D7FF): MapCellUp (empty or $05), then MapCellLeft (empty or $06). Otherwise SnapYSouthCollision (Y floored, up to 15 px north), re-probe: clear or $06 -> slide, else SnapXEastCollision + ApplyMovementDeltas. Slide: ComputeEastSnapOffset + WallSlidePushUp, which pushes Y UP (negative $24).

EastWallPushUp {
    LDA #$80              ; Set $AB bit 7: wall-slide flag, no reader found
    TSB $AB
    JSR $&tile_collision.ProbeFutureBR ; ProbeFutureBR at east destination + CheckSubTileAlignX for slide eligibility
    JSR $&tile_collision.CheckSubTileAlignX ; Carry clear = X flush; carry set = X straddles two columns. A keeps the future BR type
    BCC loc_02D823        ; X flush: skip the gap chain, go to the SnapYSouthCollision re-probe path (loc_02D823)
    CMP #$06              ; Future BR must be $06 south wall for slide-along-wall path
    BNE loc_02D823

  loc_02D7FF:
    JSR $&tile_collision.MapCellUp ; Gap chain: the cell above the future BR cell must be empty or $05
    STX $00
    JSR $&tile_collision.ReadCollisionNibble
    BEQ loc_02D80D
    CMP #$05              ; Not empty and not $05: abort (ClearSpeedEW_6)
    BNE ClearSpeedEW_6

  loc_02D80D:
    JSR $&tile_collision.MapCellLeft ; MapCellLeft from that upper cell: its west neighbour must be empty or $06
    JSR $&tile_collision.ReadCollisionNibble
    BEQ loc_02D835
    CMP #$06
    BNE ClearSpeedEW_6
    BRA loc_02D835
}

---------------------------------------------
; Entry for a future TR / BR $06 (from DispatchEastMove): STX $00 (X still holds the map index of the last probe or MapCell step), sets $AB bit 3 (no reader) and joins the gap chain at loc_02D7FF. ClearSpeedEW_6 is the shared abort.

EastWallSouthFlag {
    STX $00               ; $00 = X: the map index left by the last probe or MapCell step; then set $AB bit 3 (no reader) and join the chain
    LDA #$08
    TSB $AB
    BRA loc_02D7FF

  loc_02D823:
    JSR $&player_move_south.SnapYSouthCollision ; X flush (or type not $06): SnapYSouthCollision first ($24 = 0, so Y is floored, up to 15 px north)
    JSR $&tile_collision.ProbeFutureBR ; Re-probe FutureBR; still $06 → open south-wall slide path
    BCC loc_02D835
    CMP #$06
    BEQ loc_02D835
    JSR $&SnapXEastCollision ; Still blocked: SnapXEastCollision then ApplyMovementDeltas
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02D835:
    REP #$20
    JSR $&ComputeEastSnapOffset ; ComputeEastSnapOffset: $02 = push offset (see its note)
    JMP $&player_move_west.WallSlidePushUp ; WallSlidePushUp: negative $24 (Y shrinks), so the player is pushed NORTH

; Abort of the south-wall gap chain: playerSpeedEw = 0 and RTS; no position is applied this tick.

  ClearSpeedEW_6:
    REP #$20              ; ClearSpeedEW_6: abort slide — zero $playerSpeedEw and return
    STZ $playerSpeedEw
    RTS 
}
---------------------------------------------

; Y auto-align before the east X snap. Carry set = no nudge: vertical velocity parked at $06,S nonzero, actor solid mark at the last probe cell, or n = (($26 >> 2) AND $0F) = 0. n >= 4: south nudge (NudgeAxisPlus8Clamped, $26 += 8) if FutureBR < $0E; else n <= 10: north nudge (NudgeAxisMinus8Clamped, $26 -= 8) if FutureTR < $0E. Carry clear = nudged. Structural mirror of AutoAlignEW_North (player_move_main) on the Y axis.

AutoAlignNS_East {
    PHP                   ; AutoAlignNS_East: Y-axis ($26) auto-align before east-wall snap
    REP #$20
    LDA $06, S            ; $06,S = the vertical velocity parked by PlayerMovementTick (PHP + two return addresses above it); nonzero = a vertical move is pending
    BNE loc_02DB1F
    LDA $collisionLayer, X ; Collision byte at the last probe index (X)
    AND #$00FF            ; BIT #$00F0 on collision layer — special tiles disable auto-align
    BIT #$00F0            ; High nibble nonzero = an actor solid mark ($F0): no nudge
    BNE loc_02DB1F
    LDA $26               ; n = ($26 >> 2) AND $0F: pixels past the row line (0 = flush)
    LSR 
    LSR 
    AND #$000F
    BEQ loc_02DB1F        ; Offset zero → already on Y grid line, skip nudge
    STA $04
    CMP #$0004            ; n >= 4: try a south nudge first (needs FutureBR below $0E)
    BCC loc_02DB04
    JSR $&tile_collision.ProbeFutureBR ; ProbeFutureBR: destination must be passable (nibble < $0E)
    AND #$00FF
    CMP #$000E
    BCS loc_02DB04
    LDX #$0026            ; LDX #$0026 — NudgeAxisPlus8Clamped operates on Y sub-pixel register
    JSR $&player_move_main.NudgeAxisPlus8Clamped ; NudgeAxisPlus8Clamped: $26 += 8 sub-pixels (2 px south), clamped at the next row line
    PLP 
    CLC 
    RTS 

  loc_02DB04:
    LDA $04               ; South not possible: north nudge only for n <= 10 (needs FutureTR below $0E)
    CMP #$000B
    BCS loc_02DB1F
    JSR $&tile_collision.ProbeFutureTR ; ProbeFutureTR: upper-grid nudge requires passable tile (nibble < $0E)
    AND #$00FF
    CMP #$000E
    BCS loc_02DB1F
    LDX #$0026            ; LDX #$0026 — NudgeAxisMinus8Clamped operates on Y sub-pixel register
    JSR $&player_move_main.NudgeAxisMinus8Clamped ; NudgeAxisMinus8Clamped: $26 -= 8 sub-pixels (2 px north), clamped at the row line
    PLP 
    CLC 
    RTS 

  loc_02DB1F:
    PLP                   ; No nudge applied — return carry set (alignment skipped/failed)
    SEC 
    RTS 
}

---------------------------------------------
; Builds the push offset $02 for the east wall slide: ($1A AND $0F), plus $10 on the wall path when the step carries the probe across a 16-px column line. Wall path: current TR $09, or Y straddling with $06 in the cell below the current TR. The saved probe pixels $1A / $1E are restored before the final sum.

ComputeEastSnapOffset {
    REP #$20              ; ComputeEastSnapOffset: east-wall slide snap — save probe coords $1A/$1E
    STZ $02               ; Zero accumulated snap offset $02 before wall/velocity contribution
    LDA $1A
    PHA 
    LDA $1E
    PHA 
    SEP #$20
    JSR $&tile_collision.ProbeCurrentTR ; ProbeCurrentTR: north wall $09 at current cell → velocity snap path
    CMP #$09
    BEQ loc_02DB44
    JSR $&tile_collision.CheckSubTileAlignY ; Carry clear = Y flush -> non-wall path; carry set = Y straddles: read the cell below the current TR
    BCC loc_02DB6B
    JSR $&tile_collision.MapCellDown ; MapCellDown from the current TR cell (from $00)
    JSR $&tile_collision.ReadCollisionNibble
    CMP #$06              ; Lower cell $06 selects the wall path; anything else the non-wall path
    BNE loc_02DB6B

  loc_02DB44:
    REP #$20              ; Wall path: restore saved coords, begin EW velocity boundary-cross offset
    PLA 
    STA $1E
    PLA 
    STA $1A
    STZ $02
    LDA $1A               ; Convert EW velocity $20 to pixel step (>>2) for boundary prediction
    PHA 
    LDA $20
    LSR 
    LSR 
    SEC                   ; Negate predicted X step; XOR with saved sub-tile detects 16px line cross
    SBC $01, S
    EOR #$FFFF
    INC 
    EOR $01, S
    BIT #$0010            ; BIT #$0010: crossed 16px sub-tile X boundary → add $10 to snap offset $02
    BEQ loc_02DB68
    LDA #$0010
    STA $02

  loc_02DB68:
    PLA 
    BRA loc_02DB75

  loc_02DB6B:
    REP #$20              ; Non-wall path: restore coords, zero velocity snap — use sub-tile X only
    PLA 
    STA $1E
    PLA 
    STA $1A
    STZ $02

  loc_02DB75:
    LDA $1A               ; Final offset: low nibble of probe X ($1A & $0F) plus accumulated $02
    AND #$000F
    CLC 
    ADC $02
    STA $02
    RTS 
}