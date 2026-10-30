; West-movement collision dispatcher with slope-ramp physics (187264–188674, Bank 02).
; 
; This file is the WEST half of the horizontal (EW) movement phase and the mirror image of DispatchEastMove in player_move_east. PlayerMovementTick (player_move_main) runs two phases per tick: horizontal first, with the vertical velocity $24 parked on the stack and zeroed, then vertical. In the horizontal phase a negative $20 enters DispatchWestMove and a positive $20 enters DispatchEastMove, both after setting $AA bit $0040 (the horizontal-phase flag; 'diagonal' only means that the vertical phase may follow in the same tick). The leading corners probed here are the left ones (TL/BL); the east file probes TR/BR.
; 
; === VELOCITY AND DP CONVENTIONS ===
; 
; $20 = X velocity and $22 = X position; $24 = Y velocity and $26 = Y position (sub-pixels, 4 per pixel; Y grows downward). ApplyMovementDeltas adds $24 to $26. Every store to $24 in this file (WestRampEdgeDescend/Ascend, WallSlidePushUp/Down) is therefore a Y adjustment, not an X snap. $1A/$1E = X/Y probe pixel, $00 = map index of the last probe (used by the MapCell* steps), $02 = push offset, $AA = per-tick movement flags (only $0040 is ever set in the extracted code; the $0800/$0400 guards in PlayerMovementTick have no setter), $AB = direction/wall bits (bit 1 is read by player_move_ns SouthWallNudge; bits 2/3/7 have no reader).
; 
; === STACK CONTRACT WITH PlayerMovementTick ===
; 
; These routines are entered with JSR/JMP from PlayerMovementTick's frame still on the stack: the return address, then the parked vertical velocity word. CancelVerticalPhase writes it ($05,S), AutoAlignYToGrid reads it ($06,S, one byte deeper because of its PHP) and WallSlidePushUp/Down read it ($03,S). Zeroing it (also done by player_move_east and player_move_ramps through CancelVerticalPhase) cancels the vertical phase for this tick: the ramp code moves Y itself, and the shimmy redirect leaves the movement state. Traced with a diagonal input on ramps and walls: at entry the parked $24 is the stack word at S+5 for CancelVerticalPhase, AutoAlignNS_East, AutoAlignYToGrid and ComputeWallSlidePush (S is the stack pointer before the routine pushes anything; AutoAlignYToGrid pushes P first, hence $06,S), and at S+3 for WestRampDescend, EastRampDown and WallSlidePushUp/Down. After CancelVerticalPhase the north and south dispatchers do not run in that tick; on flat ground they do.
; 
; === TILE TYPES ===
; 
; $05 west-facing slope and $0A east-facing slope (WestRampDescend / WestRampAscend), $07 wall-shimmy tile (WestShimmyTile), $0E and above solid. Types $06 and $09 are the diagonal-edge types ($06 = top-right + bottom-left quadrants, $09 = top-left + bottom-right); this file routes TL $06 and BL $09 to the code_02DC4B / code_02DC9F handlers while the east file routes TR $09 and BR $06, and the two files label them 'north' and 'south' in opposite ways. Read those words as handler names, not directions.
; 
; === SLOPE RAMPS ===
; 
; Both ramp handlers move Y in proportion to X: while walking west on a $05 slope the code adds the negated X velocity to $26 (Y grows, so the player goes DOWN-left), while on a $0A slope it adds $20, which is negative (Y shrinks, so the player goes UP-left). WestRampDescend handles the $05 tile and WestRampAscend the $0A tile. The slope search probes the hitbox's centre column: after ProbeCurrentTL/ProbeFutureTL the code adds 8 to $1A, the X pixel, not to a Y coordinate. Both set playerFlags $1000 (on a slope) and finish with a post-ramp wall check (future TL and BL, $0E and above solid), with a dual-wall X snap when both are blocked.
; 
; === WALL SLIDE ===
; 
; The code_02DC4B / code_02DC77 and code_02DC9F / code_02DCCB handlers decide whether the player may slide along a wall, then ComputeWallSlidePush turns the X sub-tile position into a push distance and WallSlidePushDown / WallSlidePushUp store it in $24 (positive: Y grows, down; negative: up) before ApplyMovementDeltas. player_move_east reuses both push routines. AutoAlignYToGrid first tries to nudge Y onto the 16-pixel grid when no vertical movement is pending.
; 
; Wall collision path (loc_02DC03): SetActorCollisionFlag, AutoAlignYToGrid, then SnapXWestCollision (X snap and zero playerSpeedEw) when no nudge was possible, or the same X snap without zeroing the speed when Y was nudged.
---------------------------------------------

?BANK 02

?INCLUDE 'map_coords'
?INCLUDE 'player_character'
?INCLUDE 'player_move_main'
?INCLUDE 'player_move_ns'
?INCLUDE 'player_move_south'
?INCLUDE 'tile_collision'

!playerActor                    09AA
!playerFlags                    09AE
!playerSpeedEw                  09B2
!collisionLayer                 7FC000

---------------------------------------------

; Entry of the west (negative $20) horizontal-phase dispatcher; called once per tick by PlayerMovementTick.
; 
; Sets $AB bit 1 (SouthWallNudge in player_move_ns reads it as 'the west dispatcher ran this tick'), then probes in this order:
; 1. map_coords.FindSlopeForWestMove: slope search at the hitbox's centre column. Z clear = no slope; Z set with carry set = type $05 (WestRampDescend), carry clear = type $0A (WestRampAscend).
; 2. ProbeCurrentTL: type $06 goes to code_02DC4B. ProbeCurrentBL: type $09 goes to code_02DC9F.
; 3. ProbeFutureTL: $0E and above is a wall collision, $06 goes to code_02DC77 (the variant entry of the same handler).
; 4. CheckSubTileAlignY (carry clear = Y on a 16-pixel boundary): aligned, future-TL type $09 goes to code_02DCCB. Off the boundary: $09 is a wall collision, then the cell below (MapCellDown) is read: $0E and above blocks, $09 goes to code_02DCCB, $06 blocks.
; 5. Type $07 goes to WestShimmyTile. ProbeCurrentTR: $05 goes to WestRampEdgeDescend, $0A to WestRampEdgeAscend.
; 6. Otherwise $22 += $20.
; 
; Wall collision path: SetActorCollisionFlag, AutoAlignYToGrid, SnapXWestCollision.

DispatchWestMove {
    SEP #$20              ; DispatchWestMove: west (negative $20) horizontal-phase collision entry, called by PlayerMovementTick (8-bit probe mode)
    LDA #$02              ; Set $AB bit 1: the west dispatcher ran this tick (read by player_move_ns SouthWallNudge)
    TSB $AB
    JSR $&map_coords.FindSlopeForWestMove ; FindSlopeForWestMove (map_coords): slope search at the centre column (TL probe + 8 px in X), not an east-adjacent row
    BNE loc_02DB93        ; Z clear = no slope: go on to the wall probes. Z set: carry set = $05 (WestRampDescend), carry clear = $0A (WestRampAscend)
    BCS loc_02DB90
    JMP $&WestRampAscend  ; Carry clear = east-facing slope $0A (WestRampAscend)

  loc_02DB90:
    JMP $&WestRampDescend

  loc_02DB93:
    JSR $&tile_collision.ProbeCurrentTL ; ProbeCurrentTL: leading top-left corner (the west edge)
    BCC loc_02DB9F
    CMP #$06              ; Type $06 at the current TL goes to the code_02DC4B wall-slide handler (type meaning undecoded)
    BNE loc_02DB9F
    JMP $&code_02DC4B

  loc_02DB9F:
    JSR $&tile_collision.ProbeCurrentBL ; ProbeCurrentBL: leading bottom-left corner (the west edge)
    BCC loc_02DBAB
    CMP #$09              ; Type $09 at the current BL goes to the code_02DC9F wall-slide handler (type meaning undecoded)
    BNE loc_02DBAB
    JMP $&code_02DC9F

  loc_02DBAB:
    JSR $&tile_collision.ProbeFutureTL ; ProbeFutureTL: top-left corner after the velocity step
    BCC loc_02DBBB
    CMP #$0E              ; Future TL solid ($0E+) → hard wall collision (SetActorCollisionFlag path)
    BCS loc_02DC03
    CMP #$06              ; Future TL type $06 goes to code_02DC77, the variant entry of the same handler (sets $AB bit 2)
    BNE loc_02DBBB
    JMP $&code_02DC77

  loc_02DBBB:
    JSR $&tile_collision.CheckSubTileAlignY ; CheckSubTileAlignY: carry clear = probe Y on a 16-pixel boundary; A still holds the future-TL type
    BCS loc_02DBC9
    CMP #$09              ; Aligned (carry clear): future-TL type $09 goes to code_02DCCB
    BNE loc_02DBC7
    JMP $&code_02DCCB

  loc_02DBC7:
    BRA loc_02DBE2

  loc_02DBC9:
    CMP #$09              ; Off the boundary (carry set): type $09 is a wall collision
    BEQ loc_02DC03
    JSR $&tile_collision.MapCellDown ; MapCellDown: step from the future-TL cell ($00) to the cell below it
    JSR $&tile_collision.ReadCollisionNibble
    CMP #$0E              ; Cell below solid ($0E+) → block diagonal entry
    BCS loc_02DC03
    CMP #$09              ; Cell below $09 south wall → code_02DCCB south-wall slide path
    BNE loc_02DBDE
    JMP $&code_02DCCB

  loc_02DBDE:
    CMP #$06              ; Cell below $06 north wall → block (corner blocked)
    BEQ loc_02DC03

  loc_02DBE2:
    CMP #$07              ; Tile type $07 (wall-shimmy tile) -> WestShimmyTile: redirect to ShimmyLeftEntry
    BEQ WestShimmyTile
    JSR $&tile_collision.ProbeCurrentTR ; ProbeCurrentTR: west/east slope edge check at top-right corner
    BCC loc_02DBF9
    CMP #$05              ; TR tile $05 west slope edge → WestRampEdgeDescend partial ramp entry
    BNE loc_02DBF2
    JMP $&WestRampEdgeDescend

  loc_02DBF2:
    CMP #$0A              ; TR tile $0A east slope edge → WestRampEdgeAscend partial ramp entry
    BNE loc_02DBF9
    JMP $&WestRampEdgeAscend

  loc_02DBF9:
    REP #$20
    LDA $22               ; Unblocked: $22 += $20 (the vertical velocity is parked on PlayerMovementTick's stack during this phase)
    CLC 
    ADC $20
    STA $22
    RTS 

  loc_02DC03:
    JSR $&tile_collision.SetActorCollisionFlag ; Wall collision: SetActorCollisionFlag sets actor flag $0004 (solid contact this tick)
    JSR $&AutoAlignYToGrid ; AutoAlignYToGrid: try a Y nudge onto the 16-pixel grid first
    BCS SnapXWestCollision ; Carry set (no nudge): SnapXWestCollision snaps X and zeroes playerSpeedEw
    PHP 
    REP #$20              ; Y was nudged: take the X snap without zeroing playerSpeedEw (joins at loc_02DC16)
    BRA loc_02DC16
}

---------------------------------------------
; Snap X to the nearest tile centre after a wall hit during west movement.
; 
; Computes X = (((X + $20) - $0020) & $FFC0) + $0060 (the first $20 is the velocity at DP $20, the second the immediate constant 32 sub-pixels), then zeroes $20. Coordinates are in sub-pixels, 4 per pixel: $FFC0 rounds to a 16-pixel tile boundary and the + $60 / - $20 pair lands on the centre of the nearest tile. The SnapXWestCollision entry also zeroes playerSpeedEw; the loc_02DC16 entry (used after a successful Y nudge) keeps the speed.

SnapXWestCollision {
    PHP 
    REP #$20
    STZ $playerSpeedEw    ; Hard X snap: zero east-west speed ($playerSpeedEw)

  loc_02DC16:
    LDA $20               ; Snap X to the nearest tile centre: (((X + $20) - $0020) & $FFC0) + $60, sub-pixels (64 = 16 pixels)
    CLC 
    ADC $22
    SEC 
    SBC #$0020
    AND #$FFC0
    CLC 
    ADC #$0060
    STA $22
    STZ $20               ; Clear the X velocity after the snap
    PLP 
    RTS 

; Type $07 ahead while moving west (a local label inside DispatchWestMove). The $07 cell is the wall-shimmy tile, not a ladder (ladders are type $02, SouthLadderTile / NorthLadderTile). CheckSubTileAlignY: Y straddling (carry set) -> blocked path. Y flush: CancelVerticalPhase cancels the vertical phase, the player actor's entry becomes ShimmyLeftEntry (low word only) with $0008 = 0, then the blocked path runs (collision flag, Y nudge, X snap). Mirror of EastShimmyTile (ShimmyRightEntry) in player_move_east. The old name DiagLadderTile called this a ladder, which it never starts.

  WestShimmyTile:
    JSR $&tile_collision.CheckSubTileAlignY ; Shimmy tile $07: require Y sub-tile alignment (CheckSubTileAlignY)
    BCS loc_02DC03
    JSR $&CancelVerticalPhase ; CancelVerticalPhase: cancel the vertical phase (zero the velocity parked on PlayerMovementTick's stack) before the state switch
    PHY 
    REP #$20
    LDY $playerActor
    LDA #$&player_character.ShimmyLeftEntry ; Aligned on the shimmy tile: redirect actor state to ShimmyLeftEntry
    STA $0000, Y
    LDA #$0000            ; Zero the actor wait counter (+$0008) before the shimmy
    STA $0008, Y
    PLY 
    BRA loc_02DC03

; Entry shim of the code_02DC4B wall handler: a lone SEP #$20 that falls into it. DiagRedirectToSouth jumps here when the future TL probe reads $06. The old name ended in FromDL, short for the old DiagLadderTile, which this label follows in the file; there is no other link to the shimmy tile.

  DiagWallSouthShim:
    SEP #$20
}

code_02DC4B {
    LDA #$80              ; Set $AB bit 7 ($80): wall-slide flag (no reader found)
    TSB $AB
    JSR $&tile_collision.ProbeFutureTL ; ProbeFutureTL + CheckSubTileAlignX: can player slide along north wall?
    JSR $&tile_collision.CheckSubTileAlignX
    BCC loc_02DC7D
    CMP #$06              ; Future TL must be $06 north wall for slide-along-wall path
    BNE loc_02DC7D

  loc_02DC5B:
    JSR $&tile_collision.MapCellDown ; MapCellDown below future TL — probe for west slope $05 or open cell
    STX $00
    JSR $&tile_collision.ReadCollisionNibble
    BEQ loc_02DC69
    CMP #$05
    BNE loc_02DC97

  loc_02DC69:
    JSR $&tile_collision.MapCellRight ; MapCellRight: east neighbor must be $06 north wall or open for corner slide
    JSR $&tile_collision.ReadCollisionNibble
    BEQ loc_02DC8F
    CMP #$06              ; East cell $06 north wall confirms L-corner slide path
    BNE loc_02DC97
    BRA loc_02DC8F
}

code_02DC77 {
    LDA #$04              ; Variant entry: set $AB bit 2 ($04) (no reader found), then join the handler
    TSB $AB
    BRA loc_02DC5B

  loc_02DC7D:
    JSR $&player_move_ns.SnapYNorthCollision ; Not slide-eligible: SnapYNorthCollision then re-probe future TL
    JSR $&tile_collision.ProbeFutureTL
    BCC loc_02DC8F
    CMP #$06              ; Still $06 north wall after Y snap → SnapXWestCollision + apply
    BEQ loc_02DC8F
    JSR $&SnapXWestCollision
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02DC8F:
    REP #$20
    JSR $&ComputeWallSlidePush ; North-wall slide open: ComputeWallSlidePush → WallSlidePushDown
    JMP $&WallSlidePushDown

  loc_02DC97:
    REP #$20
    STZ $playerSpeedEw    ; North-wall corner blocked: zero EW speed and abort
    RTS 
}

---------------------------------------------
; Entry shim of the code_02DC9F wall handler: a lone SEP #$20 that falls into it. DiagRedirectToNorth jumps here when the future BL probe reads $09. The mirror of DiagWallSouthShim; the old name ended in FromDL for the old DiagLadderTile, with which it has no link.

DiagWallNorthShim {
    SEP #$20
}

code_02DC9F {
    LDA #$80              ; Set $AB bit 7 ($80): wall-slide flag (no reader found)
    TSB $AB
    JSR $&tile_collision.ProbeFutureBL ; ProbeFutureBL + CheckSubTileAlignX: can player slide along south wall?
    JSR $&tile_collision.CheckSubTileAlignX
    BCC loc_02DCD3
    CMP #$09              ; Future BL must be $09 south wall for slide-along-wall path
    BNE loc_02DCD3

  loc_02DCAF:
    JSR $&tile_collision.MapCellUp ; MapCellUp above future BL — probe for east slope $0A or open cell
    STX $00
    JSR $&tile_collision.ReadCollisionNibble
    BEQ loc_02DCBD
    CMP #$0A
    BNE loc_02DCED

  loc_02DCBD:
    JSR $&tile_collision.MapCellRight ; MapCellRight: east neighbor must be $09 south wall or open for corner slide
    JSR $&tile_collision.ReadCollisionNibble
    BEQ loc_02DCE5
    CMP #$09              ; East cell $09 south wall confirms L-corner slide path
    BNE loc_02DCED
    BRA loc_02DCE5
}

code_02DCCB {
    STX $00
    LDA #$08              ; Variant entry: set $AB bit 3 ($08) (no reader found), then join the handler
    TSB $AB
    BRA loc_02DCAF

  loc_02DCD3:
    JSR $&player_move_south.SnapYSouthCollision ; Not slide-eligible: SnapYSouthCollision then re-probe future BL
    JSR $&tile_collision.ProbeFutureBL
    BCC loc_02DCE5
    CMP #$09              ; Still $09 south wall after Y snap → SnapXWestCollision + apply
    BEQ loc_02DCE5
    JSR $&SnapXWestCollision
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02DCE5:
    REP #$20
    JSR $&ComputeWallSlidePush ; South-wall slide open: ComputeWallSlidePush → WallSlidePushUp
    JMP $&WallSlidePushUp

  loc_02DCED:
    REP #$20
    STZ $playerSpeedEw    ; South-wall corner blocked: zero EW speed and abort
    RTS 
}

---------------------------------------------
; Handler for a west-facing slope ($05) while walking west.
; 
; Four probes look for a $05 tile: the current TL probe moved to X + 8 (the centre column), the cell below it (MapCellDown), the future TL at X + 8, and the cell below that. None found goes to DiagRedirectToSouth. Found: if the move does not cross a 16-pixel column (CheckTileBoundaryXor) the movement is applied unchanged; otherwise Y += (16 - sub-tile) << 2 with sub-tile = (($22 + $20) >> 2) & $0F, plus one more pixel when bit 2 of ($26 + $20 + $22) is set. The full-tile entry code_02DD82 adds the negated X velocity to $26 instead. Y grows, so the player descends to the left.
; 
; Then sets playerFlags $1000 and runs the post-ramp wall check: future TL and BL both below $0E apply the movement, only BL blocked goes to code_02DDF2 (SnapYSouthCollision), only TL blocked goes to code_02DDFA (SnapYNorthCollision), both blocked snaps X to a tile centre and compensates Y.

WestRampDescend {
    JSR $&CancelVerticalPhase ; WestRampDescend: west-facing slope $05 while walking west; cancel the vertical phase (Y grows here, so this descends)
    JSR $&tile_collision.ProbeCurrentTL ; Position the probe with ProbeCurrentTL; the next three lines move its X pixel +8 (centre column)
    LDA $1A
    CLC 
    ADC #$0008
    STA $1A
    JSR $&tile_collision.TileProbeMain
    AND #$00FF
    CMP #$0005            ; Probe at X + 8 reads $05: full-tile ramp (code_02DD82)
    BNE loc_02DD0F
    JMP $&code_02DD82

  loc_02DD0F:
    JSR $&tile_collision.MapCellDown ; MapCellDown from current: cell below is $05 west slope
    SEP #$20
    JSR $&tile_collision.ReadCollisionNibble
    REP #$20
    AND #$00FF
    CMP #$0005
    BEQ code_02DD82
    JSR $&tile_collision.ProbeFutureTL ; ProbeFutureTL, then X + 8 (centre column of the destination) for the slope continuation
    LDA $1A
    CLC 
    ADC #$0008
    STA $1A
    JSR $&tile_collision.TileProbeMain
    AND #$00FF
    CMP #$0005
    BEQ loc_02DD4C
    JSR $&tile_collision.MapCellDown ; MapCellDown from future: cell below is $05 west slope
    SEP #$20
    JSR $&tile_collision.ReadCollisionNibble
    REP #$20
    AND #$00FF
    CMP #$0005
    BEQ loc_02DD4C
    JMP $&DiagRedirectToSouth ; No west slope found anywhere → DiagRedirectToSouth wall fallback

  loc_02DD4C:
    JSR $&tile_collision.CheckTileBoundaryXor ; CheckTileBoundaryXor: no X sub-column cross → apply movement without ramp Y
    BNE loc_02DD54
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02DD54:
    LDA $20               ; Ramp fraction: sub-tile = (($22 + $20) >> 2) & $0F
    CLC 
    ADC $22
    LSR 
    LSR 
    AND #$000F
    EOR #$FFFF            ; Y step: (16 - sub-tile) << 2 added to $26 (Y grows: descending to the left)
    INC 
    CLC 
    ADC #$0010
    ASL 
    ASL 
    CLC 
    ADC $26
    STA $26
    CLC                   ; Mix the X sub-pixels into the Y sum: the following bit-2 test adds one more pixel of Y (purpose unclear)
    ADC $20
    CLC 
    ADC $22
    LSR 
    LSR 
    LSR                   ; Carry = bit 2 of ($26 + $20 + $22): extra +4 sub-pixels (1 pixel) of Y
    BCC code_02DD8D
    LDA $26
    CLC 
    ADC #$0004
    STA $26
    BRA code_02DD8D
}

code_02DD82 {
    LDA $20               ; Full-tile ramp: $26 += -$20; $20 is negative while walking west, so Y grows
    EOR #$FFFF
    INC 
    CLC 
    ADC $26
    STA $26

  code_02DD8D:
    LDA #$1000            ; Set playerFlags $1000 (on a slope/ramp)
    TSB $playerFlags
    SEP #$20
    JSR $&tile_collision.ProbeFutureTL ; Post-ramp wall check: ProbeFutureTL for solid tile ($0E+)
    CMP #$0E
    BCS loc_02DDA9
    JSR $&tile_collision.ProbeFutureBL ; Future TL passable — probe FutureBL for complementary wall
    CMP #$0E
    BCS loc_02DDA6
    JMP $&tile_collision.ApplyMovementDeltas ; Both future corners passable → ApplyMovementDeltas

  loc_02DDA6:
    JMP $&code_02DDF2

  loc_02DDA9:
    JSR $&tile_collision.ProbeFutureBL ; Future TL blocked: probe BL. BL passable = north Y snap (code_02DDFA); BL solid = dual-wall snap below
    CMP #$0E
    BCS loc_02DDB3
    JMP $&code_02DDFA     ; Future TL blocked, BL passable → north Y snap (code_02DDFA)

  loc_02DDB3:
    REP #$20
    LDA $22               ; Dual-wall ($0E+ both TL and BL): snap X to tile center, reconcile Y
    PHA 
    CLC 
    ADC $20
    LSR                   ; Dual-wall X snap: X px = ($22+$20)/4; the left edge (X - 8) is rounded UP to a 16-px line, then +8 and x4
    LSR 
    SEC 
    SBC #$0008
    BIT #$000F
    BEQ loc_02DDCD
    AND #$FFF0
    CLC 
    ADC #$0010

  loc_02DDCD:
    CLC 
    ADC #$0008
    ASL 
    ASL 
    STA $22               ; Dual-wall: write snapped X, back-compute Y from saved pre-snap position
    SEC 
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
    STZ $playerSpeedEw    ; Dual-wall: zero $20/$24/EW speed, SetActorCollisionFlag, apply movement
    JSR $&tile_collision.SetActorCollisionFlag
    JMP $&tile_collision.ApplyMovementDeltas
}

code_02DDF2 {
    REP #$20
    JSR $&player_move_south.SnapYSouthCollision ; Post-ramp: only BL wall → SnapYSouthCollision then apply
    JMP $&tile_collision.ApplyMovementDeltas
}

code_02DDFA {
    REP #$20
    JSR $&player_move_ns.SnapYNorthCollision ; Post-ramp: only TL wall → SnapYNorthCollision then apply
    JMP $&tile_collision.ApplyMovementDeltas
}

---------------------------------------------
; Slope-edge handler reached from ProbeCurrentTR finding a $05 tile at the trailing corner.
; 
; Probes at the TR point moved 9 pixels left in X (net X - 1, top row). If that tile is $05: no column crossing means the full-tile ramp (code_02DD82); otherwise an edge offset is computed from the X velocity and stored in $24 (a Y adjustment), then execution continues at code_02DD8D (set playerFlags $1000 and the post-ramp wall check). Not a slope: the movement is applied unchanged.

WestRampEdgeDescend {
    JSR $&CancelVerticalPhase ; WestRampEdgeDescend: cancel the vertical phase; the probe is the TR point moved 9 px left in X (net X - 1, top row)
    LDA $1A
    SEC 
    SBC #$0009
    STA $1A
    JSR $&tile_collision.TileProbeMain
    AND #$00FF
    CMP #$0005            ; Edge probe finds $05 west slope → partial ramp offset path
    BEQ loc_02DE1B
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02DE1B:
    JSR $&tile_collision.CheckTileBoundaryXor ; CheckTileBoundaryXor at edge: no X cross → full-tile ramp (code_02DD82)
    BNE loc_02DE23
    JMP $&code_02DD82

  loc_02DE23:
    LDA $20               ; Edge ramp: proportional offset from the X velocity, stored in $24 (a Y adjustment)
    LSR 
    LSR 
    ORA #$F000
    CLC 
    ADC $1A
    INC 
    ORA #$FFF0
    ASL 
    ASL 
    EOR #$FFFF
    INC 
    CLC 
    ADC $20
    EOR #$FFFF
    INC 
    STA $24
    JMP $&code_02DD8D
}

---------------------------------------------
; Fallback of WestRampDescend when no $05 tile was found.
; 
; ProbeFutureTL: type $06 enters DiagWallSouthShim, which falls into the code_02DC4B wall handler. Anything else applies the movement unchanged.

DiagRedirectToSouth {
    JSR $&tile_collision.ProbeFutureTL ; DiagRedirectToSouth: no west slope — probe FutureTL for north wall $06
    CMP #$0006
    BNE loc_02DE4E
    JMP $&DiagWallSouthShim ; Future TL $06 → DiagWallSouthShim north-wall entry shim

  loc_02DE4E:
    JMP $&tile_collision.ApplyMovementDeltas
}

---------------------------------------------
; Handler for an east-facing slope ($0A) while walking west. Mirror of WestRampDescend.
; 
; Four probes look for a $0A tile: the current BL probe moved to X + 8, the cell above it (MapCellUp), the future TL at X + 8, and the cell below that (MapCellDown). None found goes to DiagRedirectToNorth. The Y step is the negation of the west ramp's: Y -= (16 - sub-tile) << 2 and one pixel less when bit 2 of the sum is set; the full-tile entry code_02DEE4 adds $20 (negative) to $26. Y shrinks, so the player climbs to the left. Post-ramp wall check as in WestRampDescend (code_02DF4C / code_02DF54).

WestRampAscend {
    JSR $&CancelVerticalPhase ; WestRampAscend: east-facing slope $0A while walking west; cancel the vertical phase (Y shrinks here, so this climbs)
    JSR $&tile_collision.ProbeCurrentBL ; Position the probe with ProbeCurrentBL; the next three lines move its X pixel +8 (centre column)
    LDA $1A
    CLC 
    ADC #$0008
    STA $1A
    JSR $&tile_collision.TileProbeMain
    AND #$00FF
    CMP #$000A            ; Probe at X + 8 reads $0A: full-tile ramp (code_02DEE4)
    BNE loc_02DE6D
    JMP $&code_02DEE4

  loc_02DE6D:
    JSR $&tile_collision.MapCellUp ; MapCellUp from current: cell above is $0A east slope
    SEP #$20
    JSR $&tile_collision.ReadCollisionNibble
    REP #$20
    AND #$00FF
    CMP #$000A
    BEQ code_02DEE4
    JSR $&tile_collision.ProbeFutureTL ; ProbeFutureTL, then X + 8 (centre column of the destination) for the slope continuation
    LDA $1A
    CLC 
    ADC #$0008
    STA $1A
    JSR $&tile_collision.TileProbeMain
    AND #$00FF
    CMP #$000A
    BEQ loc_02DEAA
    JSR $&tile_collision.MapCellDown ; MapCellDown from future: cell below is $0A east slope
    SEP #$20
    JSR $&tile_collision.ReadCollisionNibble
    REP #$20
    AND #$00FF
    CMP #$000A
    BEQ loc_02DEAA
    JMP $&DiagRedirectToNorth ; No east slope found → DiagRedirectToNorth south-wall fallback

  loc_02DEAA:
    JSR $&tile_collision.CheckTileBoundaryXor ; CheckTileBoundaryXor: no X sub-column cross → apply without ramp Y
    BNE loc_02DEB2
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02DEB2:
    LDA $20               ; East ramp fraction: X sub-tile = (($22+$20)>>2) & $0F
    CLC 
    ADC $22
    LSR 
    LSR 
    AND #$000F
    EOR #$FFFF            ; Y step: negated (16 - sub-tile) << 2 added to $26 (Y shrinks: climbing to the left)
    INC 
    CLC 
    ADC #$0010
    ASL 
    ASL 
    EOR #$FFFF
    INC 
    CLC 
    ADC $26
    STA $26
    CLC                   ; Mix the X sub-pixels into the Y sum: the following bit-2 test removes one pixel of Y (purpose unclear)
    ADC $20
    CLC 
    ADC $22
    LSR 
    LSR 
    LSR                   ; Carry = bit 2 of ($26 + $20 + $22): extra -4 sub-pixels (1 pixel) of Y
    BCC code_02DEEB
    LDA $26
    SEC 
    SBC #$0004
    STA $26
    BRA code_02DEEB
}

code_02DEE4 {
    LDA $20               ; Full-tile ramp: $26 += $20; $20 is negative while walking west, so Y shrinks
    CLC 
    ADC $26
    STA $26

  code_02DEEB:
    LDA #$1000            ; Set playerFlags $1000 (on a slope/ramp)
    TSB $playerFlags
    SEP #$20
    JSR $&tile_collision.ProbeFutureTL ; Post-ramp wall check: ProbeFutureTL for solid tile ($0E+)
    CMP #$0E
    BCS loc_02DF07
    JSR $&tile_collision.ProbeFutureBL ; Future TL passable — probe FutureBL for complementary wall
    CMP #$0E
    BCS loc_02DF04
    JMP $&tile_collision.ApplyMovementDeltas ; Both future corners passable → ApplyMovementDeltas

  loc_02DF04:
    JMP $&code_02DF4C

  loc_02DF07:
    JSR $&tile_collision.ProbeFutureBL ; Future TL blocked: probe BL. BL passable = north Y snap (code_02DF54); BL solid = dual-wall snap below
    CMP #$0E
    BCS loc_02DF11
    JMP $&code_02DF54     ; Future TL blocked, BL passable → north Y snap (code_02DF54)

  loc_02DF11:
    REP #$20
    LDA $22               ; Dual-wall ($0E+ both): snap X to tile center, reconcile Y (east ramp mirror)
    PHA 
    CLC 
    ADC $20
    LSR 
    LSR 
    SEC 
    SBC #$0008
    BIT #$000F
    BEQ loc_02DF2B
    AND #$FFF0
    CLC 
    ADC #$0010

  loc_02DF2B:
    CLC 
    ADC #$0008
    ASL 
    ASL 
    STA $22               ; Dual-wall: write snapped X, add residual Y delta from pre-snap position
    SEC 
    SBC $01, S
    SEC 
    SBC $20
    CLC 
    ADC $26
    STA $26
    PLA 
    STZ $20
    STZ $24
    STZ $playerSpeedEw    ; Dual-wall: zero velocities/speed, SetActorCollisionFlag, apply movement
    JSR $&tile_collision.SetActorCollisionFlag
    JMP $&tile_collision.ApplyMovementDeltas
}

code_02DF4C {
    REP #$20
    JSR $&player_move_south.SnapYSouthCollision ; Post-ramp east: only BL wall → SnapYSouthCollision then apply
    JMP $&tile_collision.ApplyMovementDeltas
}

code_02DF54 {
    REP #$20
    JSR $&player_move_ns.SnapYNorthCollision ; Post-ramp east: only TL wall → SnapYNorthCollision then apply
    JMP $&tile_collision.ApplyMovementDeltas
}

---------------------------------------------
; Slope-edge handler reached from ProbeCurrentTR finding a $0A tile. Mirror of WestRampEdgeDescend.
; 
; Probes at the TR point moved 9 pixels left in X; if that tile is $0A, a column crossing computes the edge offset into $24 (Y adjustment) and continues at code_02DEEB, otherwise the full-tile ramp (code_02DEE4) runs.

WestRampEdgeAscend {
    JSR $&CancelVerticalPhase ; WestRampEdgeAscend: cancel the vertical phase; the probe is the TR point moved 9 px left in X (net X - 1, top row)
    LDA $1A
    SEC 
    SBC #$0009
    STA $1A
    JSR $&tile_collision.TileProbeMain
    AND #$00FF
    CMP #$000A            ; Edge probe finds $0A east slope → partial ramp offset path
    BEQ loc_02DF75
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02DF75:
    JSR $&tile_collision.CheckTileBoundaryXor ; CheckTileBoundaryXor at edge: no X cross → full-tile ramp (code_02DEE4)
    BNE loc_02DF7D
    JMP $&code_02DEE4

  loc_02DF7D:
    LDA $20               ; Edge ramp: proportional offset from the X velocity, stored in $24 (a Y adjustment)
    LSR 
    LSR 
    ORA #$F000
    CLC 
    ADC $1A
    INC 
    ORA #$FFF0
    ASL 
    ASL 
    EOR #$FFFF
    INC 
    CLC 
    ADC $20
    STA $24
    JMP $&code_02DEEB
}

---------------------------------------------
; Fallback of WestRampAscend when no $0A tile was found.
; 
; ProbeFutureBL: type $09 enters DiagWallNorthShim, which falls into the code_02DC9F wall handler. Anything else applies the movement unchanged.

DiagRedirectToNorth {
    JSR $&tile_collision.ProbeFutureBL ; DiagRedirectToNorth: no east slope — probe FutureBL for south wall $09
    CMP #$0009
    BNE loc_02DFA4
    JMP $&DiagWallNorthShim ; Future BL $09 → DiagWallNorthShim south-wall entry shim

  loc_02DFA4:
    JMP $&tile_collision.ApplyMovementDeltas
}

---------------------------------------------
; Try to nudge the player's Y position onto the 16-pixel grid before the X snap of a wall collision.
; 
; Gives up (carry set, no nudge) when:
; 1. the vertical velocity parked on PlayerMovementTick's stack ($06,S) is nonzero: the player is also moving vertically this tick;
; 2. the collision-layer byte at X (the map index left by the last probe or MapCell step) has a nonzero high nibble, i.e. an actor's solid mark ($F0 written by MarkSolidHere);
; 3. the Y sub-tile offset (($26 >> 2) & $0F) is 0.
; 
; Otherwise: offset >= 4 and ProbeFutureBL below $0E calls NudgeAxisPlus8Clamped on $26; offset < $0B and ProbeFutureTL below $0E calls NudgeAxisMinus8Clamped on $26 (the two windows overlap for offsets 4 to 10). Returns carry clear when a nudge happened.

AutoAlignYToGrid {
    PHP                   ; AutoAlignYToGrid: Y-axis auto-align before the X snap of a wall collision
    REP #$20
    LDA $06, S            ; Give up if the vertical velocity parked on PlayerMovementTick's stack ($06,S with this PHP) is nonzero
    BNE loc_02DFF3
    LDA $collisionLayer, X ; Give up if the cell at X carries an actor solid mark (collision-layer high nibble)
    AND #$00FF
    BIT #$00F0
    BNE loc_02DFF3
    LDA $26               ; Y sub-tile offset from pixel pos: ($26>>2) & $0F
    LSR 
    LSR 
    AND #$000F
    BEQ loc_02DFF3        ; Offset zero → already on Y grid line, skip nudge
    STA $04
    CMP #$0004
    BCC loc_02DFDB        ; Offset < 4: skip the south nudge and take the upper-grid path at loc_02DFDB; offset >= 4 falls through to probe FutureBL
    JSR $&tile_collision.ProbeFutureBL
    CMP #$000E
    BCS loc_02DFDB
    LDX #$0026
    JSR $&player_move_main.NudgeAxisPlus8Clamped ; Lower-grid Y nudge succeeded → return carry clear
    PLP 
    CLC 
    RTS 

  loc_02DFDB:
    LDA $04
    CMP #$000B            ; Offset < $0B: probe FutureTL — passable (< $0E) → NudgeAxisMinus8Clamped on $26
    BCS loc_02DFF3
    JSR $&tile_collision.ProbeFutureTL
    CMP #$000E
    BCS loc_02DFF3
    LDX #$0026
    JSR $&player_move_main.NudgeAxisMinus8Clamped ; Upper-grid Y nudge succeeded → return carry clear
    PLP 
    CLC 
    RTS 

  loc_02DFF3:
    PLP 
    SEC                   ; No nudge applied — return carry set (alignment skipped/failed)
    RTS 
}

---------------------------------------------
; Compute the push distance used by WallSlidePushUp / WallSlidePushDown, left in $02.
; 
; Saves $1A/$1E. If the current TL tile is $09, or the Y row is off the 16-pixel boundary (CheckSubTileAlignY carry set) and the cell below is $06, the probe X is restored and the X velocity (converted to pixels) is subtracted from it; when that moves it into a different 16-pixel column (bit $0010 of the XOR) $10 is added to $02. Final $02 = (16 - ($1A & $0F)) + the accumulated adjustment, so the push depends on how far the player is across the tile in X.

ComputeWallSlidePush {
    REP #$20              ; ComputeWallSlidePush: save probe coords $1A/$1E on stack
    STZ $02
    LDA $1A
    PHA 
    LDA $1E
    PHA 
    SEP #$20
    JSR $&tile_collision.ProbeCurrentTL ; ProbeCurrentTL: south wall $09 at TL → wall-boundary snap path
    CMP #$09
    BEQ loc_02E018
    JSR $&tile_collision.CheckSubTileAlignY ; Carry clear (aligned) skips the wall path; carry set reads the cell below the TL probe
    BCC loc_02E044
    JSR $&tile_collision.MapCellDown
    JSR $&tile_collision.ReadCollisionNibble
    CMP #$06              ; North wall $06 below TL → +$10 boundary adjustment to snap offset
    BNE loc_02E044

  loc_02E018:
    REP #$20
    PLA 
    STA $1E
    PLA 
    STA $1A
    STZ $02
    LDA $1A
    PHA 
    LDA $20               ; Wall path: convert EW velocity $20 to pixel step for boundary prediction
    BEQ loc_02E02E
    LSR 
    LSR 
    ORA #$0C00

  loc_02E02E:
    SEC 
    SBC $01, S            ; Negate predicted step; XOR with probe X detects 16px sub-column cross
    EOR #$FFFF
    INC 
    EOR $01, S
    BIT #$0010            ; Crossed X sub-column boundary (bit $0010) → add $10 to offset $02
    BEQ loc_02E041
    LDA #$0010
    STA $02

  loc_02E041:
    PLA 
    BRA loc_02E04E

  loc_02E044:
    REP #$20
    PLA 
    STA $1E
    PLA 
    STA $1A
    STZ $02

  loc_02E04E:
    LDA $1A               ; Final snap offset: low nibble of probe X ($1A & $0F) plus accumulated $02
    AND #$000F
    ORA #$FFF0
    EOR #$FFFF
    INC 
    CLC 
    ADC $02
    STA $02
    RTS 
}

---------------------------------------------
; Y push of the south-side wall slide (code_02DC9F / code_02DCCB chain); also used by player_move_east.
; 
; Adds the Y sub-tile position (($26 >> 2) & $0F, or $10 when zero) to the offset in $02. A total below $11 applies the movement unchanged. Otherwise $02 = total & $0F and the horizontal speed is compared with the vertical velocity parked on PlayerMovementTick's stack ($03,S): no vertical velocity or horizontal larger stores a NEGATIVE push (-$02 << 2) in $24, which ApplyMovementDeltas adds to Y (up); equal magnitudes cancel both velocities; smaller drops $20 and clears $AA bits $0840.

WallSlidePushUp {
    LDA $26               ; WallSlidePushUp: builds a negative Y push (up) in $24 from the Y sub-tile position and $02
    LSR 
    LSR 
    AND #$000F            ; Base push distance from Y sub-tile: ($26>>2)&$0F or $10 if zero
    BNE loc_02E06C
    LDA #$0010

  loc_02E06C:
    CLC 
    ADC $02
    CMP #$0011            ; Total push < $11 sub-pixels → too small, apply movement unchanged
    BCS loc_02E077
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02E077:
    AND #$000F
    STA $02
    LDA $03, S            ; Compare |$20| with the vertical velocity parked on PlayerMovementTick's stack ($03,S)
    BEQ loc_02E096
    LDA $20
    BPL loc_02E088
    EOR #$FFFF
    INC 

  loc_02E088:
    CMP $03, S
    BEQ loc_02E0A3
    BPL loc_02E096
    STZ $20
    LDA #$0840            ; Horizontal speed smaller: $20 dropped, clear $AA bits $0840 (no setter for $0800 found; $0040 is the horizontal-phase flag)
    TRB $AA
    RTS 

  loc_02E096:
    LDA $02               ; Valid push: store the negated $02 << 2 in $24 (Y velocity, up) and apply the movement
    ASL 
    ASL 
    EOR #$FFFF
    INC 
    STA $24
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02E0A3:
    LDA #$0000
    STA $03, S
    STA $20
    RTS 
}

---------------------------------------------
; Y push of the north-side wall slide (code_02DC4B / code_02DC77 chain); also used by player_move_east. Mirror of WallSlidePushUp.
; 
; Uses the complemented Y sub-tile nibble; the valid push is POSITIVE ($02 << 2 in $24, Y grows, down) and the overshoot case clears $AA bits $0440.

WallSlidePushDown {
    LDA $26               ; WallSlidePushDown: builds a positive Y push (down) in $24 from the complemented Y sub-tile position and $02
    LSR 
    LSR 
    ORA #$FFF0            ; Base push distance from inverted Y sub-tile nibble (mirror of PushLeft)
    EOR #$FFFF
    INC 
    BNE loc_02E0BB
    LDA #$0010

  loc_02E0BB:
    CLC 
    ADC $02
    CMP #$0011            ; Total push < $11 sub-pixels → too small, apply movement unchanged
    BCS loc_02E0C6
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02E0C6:
    AND #$000F
    STA $02
    LDA $03, S            ; Compare -|$20| with the vertical velocity parked on PlayerMovementTick's stack ($03,S)
    BEQ loc_02E0E9
    LDA $20
    BPL loc_02E0D7
    EOR #$FFFF
    INC 

  loc_02E0D7:
    EOR #$FFFF
    INC 
    CMP $03, S
    BEQ loc_02E0F2
    BMI loc_02E0E9
    STZ $20
    LDA #$0440            ; Horizontal speed smaller: $20 dropped, clear $AA bits $0440 (no setter for $0400 found)
    TRB $AA
    RTS 

  loc_02E0E9:
    LDA $02               ; Valid push: store $02 << 2 in $24 (Y velocity, down) and apply the movement
    ASL 
    ASL 
    STA $24
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02E0F2:
    LDA #$0000
    STA $03, S
    STA $20
    RTS 
}

---------------------------------------------
; Cancel the vertical phase of the current movement tick.
; 
; Zeroes the 16-bit word at $05,S. With the JSR return address on top, that word is the vertical velocity PlayerMovementTick parked on its stack (PHA of $24), so the NS phase finds zero and does nothing. Called by the ramp handlers (here and in player_move_ramps), the shimmy redirects (WestShimmyTile, EastShimmyTile) and player_move_east.

CancelVerticalPhase {
    REP #$20              ; CancelVerticalPhase: zero the word at $05,S, the vertical velocity PlayerMovementTick parked on its stack
    LDA #$0000
    STA $05, S
    RTS 
}