; East (rightward) movement collision dispatch and grid alignment (186076–186435 + 187085–187264, Bank 02).
; 
; Handles positive $20 (EW velocity) movement — the player moving rightward on screen. DispatchEastMove first checks for slope tiles via ProbeLeftTiles (which dispatches to player_move_ramps), then probes right-side tiles for wall, ladder, and interaction collisions.
; 
; Includes: DispatchEastMove, SnapXEastCollision (X-axis snap to 64px grid), EastLadderTile (shimmy), EastWallNorthHandler/EastWallNorthDiag/EastWallNorthFlag (north-wall $09 handlers), EastWallSouthHandler/EastWallSouthDiag/EastWallSouthFlag (south-wall $06 handlers), AutoAlignNS_East (Y grid nudge during east movement), ComputeEastSnapOffset.
---------------------------------------------

?BANK 02

?INCLUDE 'map_coords'
?INCLUDE 'player_character'
?INCLUDE 'player_move_diag'
?INCLUDE 'player_move_main'
?INCLUDE 'player_move_ns'
?INCLUDE 'player_move_ramps'
?INCLUDE 'player_move_south'
?INCLUDE 'tile_collision'

!playerActor                    09AA
!playerSpeedEw                  09B2
!collisionLayer                 7FC000

---------------------------------------------

; Main entry for positive $20 (EW velocity). First checks slopes via ProbeLeftTiles (checking 8px to the left for slope tiles behind the player):
;   - No slope (Z=0): continue to wall collision
;   - West slope $05 found (C=1): → WestRampDown
;   - East slope $0A found (C=0): → EastRampDown
; 
; Wall collision dispatch:
;   CurrentTR $09 → EastWallNorthHandler (north-wall interaction)
;   CurrentBR $06 → EastWallSouthHandler (south-wall interaction)
;   FutureTR ≥ $0E → wall blocked → SnapXEastCollision
;   FutureTR $09 → EastWallNorthFlag
;   FutureTR $06 + sub-tile → EastWallSouthFlag
;   Sub-tile aligned + MapCellRight → additional wall checks
;   Tile $07 → EastLadderTile
;   CurrentBL $05 → WestRampUp, $0A → EastRampUp
; 
; Non-blocked path: $22 += $20 (apply EW velocity to X sub-pixel position).

DispatchEastMove {
    SEP #$20              ; DispatchEastMove: east/+X movement collision dispatch — 8-bit probe mode
    JSR $&map_coords.ProbeLeftTiles ; ProbeLeftTiles ahead of eastward step: detects slope tiles in leading column
    BNE loc_02D6EB        ; Nonzero probe → skip slope routing; continue wall/tile collision checks
    BCS loc_02D6E8        ; Carry set → west-facing slope $05 below → WestRampUp
    JMP $&player_move_ramps.EastRampDown ; Carry clear → east-facing slope $0A below → EastRampDown

  loc_02D6E8:
    JMP $&player_move_ramps.WestRampUp

  loc_02D6EB:
    JSR $&tile_collision.ProbeCurrentTR ; ProbeCurrentTR at player's leading top-right corner
    CMP #$09              ; Type $09 north-facing wall at current TR → immediate north-wall handler
    BNE loc_02D6F5
    JMP $&EastWallNorthHandler

  loc_02D6F5:
    JSR $&tile_collision.ProbeCurrentBR ; ProbeCurrentBR at leading bottom-right for south-wall check
    CMP #$06              ; Type $06 south-facing wall at current BR → south-wall handler
    BNE loc_02D6FF
    JMP $&EastWallSouthHandler

  loc_02D6FF:
    JSR $&tile_collision.ProbeFutureTR ; ProbeFutureTR one cell east (destination top-right)
    CMP #$0E              ; Solid tile: collision nibble ≥ $0E blocks east entry
    BCS loc_02D753
    CMP #$09              ; Type $09 north wall at destination → EastWallNorthFlag compact handler
    BNE loc_02D70D
    JMP $&EastWallNorthFlag

  loc_02D70D:
    JSR $&tile_collision.CheckSubTileAlignY ; CheckSubTileAlignY: is player Y-sub-tile aligned for wall slide?
    BCS loc_02D71B
    CMP #$06              ; Y misaligned + destination south wall $06 → EastWallSouthFlag flag variant
    BNE loc_02D719
    JMP $&EastWallSouthFlag

  loc_02D719:
    BRA loc_02D734

  loc_02D71B:
    CMP #$06              ; Y aligned at destination: south wall $06 still blocks east entry
    BEQ loc_02D753
    JSR $&tile_collision.MapCellDown ; Y misaligned: MapCellRight secondary probe on adjacent east cell
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
    CMP #$07              ; Type $07 ladder tile at destination → EastLadderTile shimmy transition
    BEQ EastLadderTile
    JSR $&tile_collision.ProbeCurrentBL ; ProbeCurrentBL at bottom-left for slope ascent checks
    CMP #$05              ; Type $05 west-facing slope at BL → WestRampDown (ascend while moving east)
    BNE loc_02D742
    JMP $&player_move_ramps.WestRampDown

  loc_02D742:
    CMP #$0A              ; Type $0A east-facing slope at BL → EastRampUp (ascend while moving east)
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
    PHP 
    REP #$20
    BRA loc_02D766
}

---------------------------------------------
; Snaps player X sub-pixel position to the 64px grid after wall collision. Zeroes playerSpeedEw ($09B2). Computes $22 = ($20+$22−$20) AND $FFC0 + $20, which effectively rounds $22 down to the nearest 64px boundary offset by $20. Zeroes $20.
; 
; The −$20 / +$20 sandwich around the AND mask ensures the snap boundary accounts for the current velocity, preventing the player from being pushed through thin walls.

SnapXEastCollision {
    PHP                   ; SnapXEastCollision: zero $playerSpeedEw on hard X snap
    REP #$20
    STZ $playerSpeedEw

  loc_02D766:
    LDA $20               ; Snap X ($22): ($20+$22-$20) down to 64px grid (AND #$FFC0), +$20 bias, clear $20
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

; Ladder/shimmy interaction during east (rightward) movement.
; 
; Guard: CheckSubTileAlignY — if past the sub-tile boundary (carry set), treat as wall (→ loc_02D753 → SnapXEastCollision). Otherwise: DiagClearReturnFlags, set player actor state to ShimmyRightEntry, zero sub-state, then jump to wall snap.
; 
; Note: ShimmyRightEntry aligns with the actual rightward movement direction, despite the 'West' prefix on this routine.

  EastLadderTile:
    JSR $&tile_collision.CheckSubTileAlignY ; Ladder tile ($07): require Y sub-tile alignment before east shimmy
    BCS loc_02D753
    JSR $&player_move_diag.DiagClearReturnFlags ; Clear diag return flags; switch player state to ShimmyRightEntry
    PHY 
    REP #$20
    LDY $playerActor
    LDA #$&player_character.ShimmyRightEntry
    STA $0000, Y          ; Write ShimmyRightEntry handler to actor +$0000; clear movement sub-state +$0008
    LDA #$0000
    STA $0008, Y
    PLY 
    BRA loc_02D753

; Diagonal entry point for north-wall handling during east movement.
; 
; Single instruction: SEP #$20 (switch to 8-bit accumulator). Falls through directly into EastWallNorthHandler. Serves as a labeled entry for EastRedirectToNorth's diagonal redirect path.

  EastWallNorthDiag:
    SEP #$20              ; EastWallNorthDiag entry (falls through to EastWallNorthHandler north-wall slide)
}

---------------------------------------------
; North-wall ($09) interaction during east movement — full handler.
; 
; Sets $AB bit $80 (movement interaction flag). Probes FutureTR with sub-tile X alignment:
;   - Aligned + $09: check MapCellRight (passable or $0A) → MapCellUp (passable or $09) → compute WestSnapOffset + DiagPushRight
;   - Not aligned: SnapYNorthCollision, re-probe FutureTR: if blocked/wall → SnapXEastCollision. If passable/special → WestSnapOffset + DiagPushRight.
; 
; The DiagPushRight output causes the player to slide upward (north) along the wall while maintaining east momentum.

EastWallNorthHandler {
    LDA #$80              ; North wall ($09) slide handler: set diag flag bit $80 in $AB
    TSB $AB
    JSR $&tile_collision.ProbeFutureTR ; ProbeFutureTR at east destination + CheckSubTileAlignX for slide eligibility
    JSR $&tile_collision.CheckSubTileAlignX
    BCC loc_02D7C7
    CMP #$09              ; Future TR must be $09 north wall for slide-along-wall path
    BNE loc_02D7C7

  loc_02D7AB:
    JSR $&tile_collision.MapCellDown ; Gap probe: MapCellRight from north wall — adjacent cell must be passable
    STX $00
    JSR $&tile_collision.ReadCollisionNibble
    BEQ loc_02D7B9
    CMP #$0A              ; Adjacent east cell must be empty or east-facing slope $0A
    BNE ClearSpeedEW_5

  loc_02D7B9:
    JSR $&tile_collision.MapCellLeft ; MapCellUp from gap cell — north wall $09 must continue above
    JSR $&tile_collision.ReadCollisionNibble
    BEQ loc_02D7D9
    CMP #$09              ; Open north-wall chain → ComputeEastSnapOffset + DiagPushRight slide
    BNE ClearSpeedEW_5
    BRA loc_02D7D9

  loc_02D7C7:
    JSR $&player_move_ns.SnapYNorthCollision ; X misaligned: SnapYNorthCollision adjusts Y before re-testing destination
    JSR $&tile_collision.ProbeFutureTR ; Re-probe FutureTR after Y snap; still $09 → open slide path
    BCC loc_02D7D9
    CMP #$09
    BEQ loc_02D7D9
    JSR $&SnapXEastCollision ; Still blocked: SnapXEastCollision then ApplyMovementDeltas
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02D7D9:
    REP #$20
    JSR $&ComputeEastSnapOffset ; Open slide path: ComputeEastSnapOffset then DiagPushRight along north wall
    JMP $&player_move_diag.DiagPushRight
}

---------------------------------------------
; Compact north-wall handler — sets $AB bit $04 (north-wall flag) and jumps into EastWallNorthHandler's MapCellRight adjacency chain at loc_02D7AB.
; 
; Used when FutureTR is $09 during east movement, bypassing the initial probe and sub-tile alignment check since the $09 tile was already confirmed.

EastWallNorthFlag {
    LDA #$04              ; EastWallNorthFlag: set compact north-wall flag bit $04 in $AB
    TSB $AB
    BRA loc_02D7AB        ; Join shared north-wall adjacency probe chain at loc_02D7AB

; Zero playerSpeedEw ($09B2) and return. Instance 5 — used when north-wall adjacency probing finds impassable cells during east movement.

  ClearSpeedEW_5:
    REP #$20              ; ClearSpeedEW_5: abort slide — zero $playerSpeedEw and return
    STZ $playerSpeedEw
    RTS 
}

---------------------------------------------
; Diagonal entry point for south-wall handling during east movement.
; 
; Single instruction: SEP #$20. Falls through into EastWallSouthHandler.

EastWallSouthDiag {
    SEP #$20              ; EastWallSouthDiag entry (falls through to EastWallSouthHandler south-wall slide)
}

---------------------------------------------
; South-wall ($06) interaction during east movement — full handler.
; 
; Sets $AB bit $80. Probes FutureBR with sub-tile X alignment:
;   - Aligned + $06: check MapCellLeft (passable or $05) → MapCellUp (passable or $06) → compute WestSnapOffset + DiagPushLeft
;   - Not aligned: SnapYSouthCollision, re-probe FutureBR: if blocked → SnapXEastCollision. If passable/$06 → WestSnapOffset + DiagPushLeft.
; 
; DiagPushLeft causes the player to slide downward (south) along the wall.

EastWallSouthHandler {
    LDA #$80              ; South wall ($06) slide handler: set diag flag bit $80 in $AB
    TSB $AB
    JSR $&tile_collision.ProbeFutureBR ; ProbeFutureBR at east destination + CheckSubTileAlignX for slide eligibility
    JSR $&tile_collision.CheckSubTileAlignX
    BCC loc_02D823
    CMP #$06              ; Future BR must be $06 south wall for slide-along-wall path
    BNE loc_02D823

  loc_02D7FF:
    JSR $&tile_collision.MapCellUp ; Gap probe: MapCellLeft from south wall — adjacent cell must be passable
    STX $00
    JSR $&tile_collision.ReadCollisionNibble
    BEQ loc_02D80D
    CMP #$05              ; Adjacent west cell must be empty or west-facing slope $05
    BNE ClearSpeedEW_6

  loc_02D80D:
    JSR $&tile_collision.MapCellLeft ; MapCellUp from gap cell — south wall $06 must continue above
    JSR $&tile_collision.ReadCollisionNibble
    BEQ loc_02D835
    CMP #$06
    BNE ClearSpeedEW_6
    BRA loc_02D835
}

---------------------------------------------
; South-wall flag variant — sets $AB bit $08 (south-wall flag), saves tile map index ($00 = X), and jumps into EastWallSouthHandler's MapCellLeft adjacency chain at loc_02D7FF.
; 
; Used when FutureTR has $06 during east movement at a sub-tile boundary.

EastWallSouthFlag {
    STX $00               ; EastWallSouthFlag: south-wall flag variant — set bit $08 in $AB, join adjacency chain
    LDA #$08
    TSB $AB
    BRA loc_02D7FF

  loc_02D823:
    JSR $&player_move_south.SnapYSouthCollision ; X misaligned fallback: SnapYSouthCollision before re-probing FutureBR
    JSR $&tile_collision.ProbeFutureBR ; Re-probe FutureBR; still $06 → open south-wall slide path
    BCC loc_02D835
    CMP #$06
    BEQ loc_02D835
    JSR $&SnapXEastCollision ; Still blocked: SnapXEastCollision then ApplyMovementDeltas
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02D835:
    REP #$20
    JSR $&ComputeEastSnapOffset ; Open slide path: ComputeEastSnapOffset then DiagPushLeft along south wall
    JMP $&player_move_diag.DiagPushLeft

; Zero playerSpeedEw and return. Instance 6 — used by south-wall adjacency probing during east movement.

  ClearSpeedEW_6:
    REP #$20              ; ClearSpeedEW_6: abort slide — zero $playerSpeedEw and return
    STZ $playerSpeedEw
    RTS 
}
---------------------------------------------

; Structurally similar to AutoAlignEW (player_move_main) but operates on $26 (Y sub-pixel) instead of $22 (X), and uses different probe tiles.
; 
; Extra guard: reads the caller's EW velocity from stack ($06,S) — if nonzero, skip alignment (EW component present means diagonal handling elsewhere).
; 
; Nudge toward lower grid (offset ≥ 4): ProbeFutureBR, passability (< $0E). LDX #$0026, NudgeToLowerGrid. CLC return.
; 
; Nudge toward upper grid (offset < $0B): ProbeFutureTR. NudgeToUpperGrid. CLC return. SEC if no nudge.

AutoAlignNS_East {
    PHP                   ; AutoAlignNS_East: Y-axis ($26) auto-align before east-wall snap
    REP #$20
    LDA $06, S            ; Stack guard: skip nudge if EW velocity frame ($06,S on stack) is nonzero
    BNE loc_02DB1F
    LDA $collisionLayer, X ; Skip if collision layer high nibble nonzero (overlay/special layer active)
    AND #$00FF            ; BIT #$00F0 on collision layer — special tiles disable auto-align
    BIT #$00F0
    BNE loc_02DB1F
    LDA $26               ; Y sub-tile offset from pixel pos: ($26>>2) & $0F
    LSR 
    LSR 
    AND #$000F
    BEQ loc_02DB1F        ; Offset zero → already on Y grid line, skip nudge
    STA $04
    CMP #$0004            ; Offset ≥ 4: try nudge Y toward lower grid via FutureBR probe
    BCC loc_02DB04
    JSR $&tile_collision.ProbeFutureBR ; ProbeFutureBR: destination must be passable (nibble < $0E)
    AND #$00FF
    CMP #$000E
    BCS loc_02DB04
    LDX #$0026            ; LDX #$0026 — NudgeToLowerGrid operates on Y sub-pixel register
    JSR $&player_move_main.NudgeToLowerGrid ; Lower-grid nudge succeeded → return carry clear
    PLP 
    CLC 
    RTS 

  loc_02DB04:
    LDA $04               ; Offset < $0B: try nudge Y toward upper grid via FutureTR probe
    CMP #$000B
    BCS loc_02DB1F
    JSR $&tile_collision.ProbeFutureTR ; ProbeFutureTR: upper-grid nudge requires passable tile (nibble < $0E)
    AND #$00FF
    CMP #$000E
    BCS loc_02DB1F
    LDX #$0026            ; LDX #$0026 — NudgeToUpperGrid operates on Y sub-pixel register
    JSR $&player_move_main.NudgeToUpperGrid ; Upper-grid nudge succeeded → return carry clear
    PLP 
    CLC 
    RTS 

  loc_02DB1F:
    PLP                   ; No nudge applied — return carry set (alignment skipped/failed)
    SEC 
    RTS 
}

---------------------------------------------
; Saves pixel coords. Probes CurrentTR: if $09 (north wall) or MapCellRight/ReadCollisionNibble yields $06 (south wall), takes the boundary-crossing path.
; 
; Boundary path: $20 >> 2 (EW velocity to pixels), subtract from saved $1A on stack, XOR for 16px grid crossing (BIT $0010). If crossed, $02 = $0010.
; 
; Final: $02 += ($1A AND $000F) — sub-tile X offset added to crossing adjustment.

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
    JSR $&tile_collision.CheckSubTileAlignY ; Y right-half alignment (carry): probe cell east for south wall $06
    BCC loc_02DB6B
    JSR $&tile_collision.MapCellDown ; MapCellRight + ReadCollisionNibble for south-wall boundary case
    JSR $&tile_collision.ReadCollisionNibble
    CMP #$06
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