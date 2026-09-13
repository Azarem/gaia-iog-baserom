; Slope/ramp physics for eastward movement — shared between east and diagonal dispatchers (186435–187085, Bank 02).
; 
; Handles slope traversal when the player encounters east-facing ($0A) or west-facing ($05) slope tiles during rightward movement. Each slope type has two handlers: a primary (entering the slope) and a continuation (exiting/transitioning).
; 
; East-facing slope $0A (descends eastward):
;   - EastRampDown: primary — Y += sub-tile offset (player descends)
;   - EastRampUp: continuation — Y -= sub-tile offset (player ascends at top of slope)
;   - EastRedirectToNorth: fallback when no slope found, probes for north wall
; 
; West-facing slope $05 (descends westward):
;   - WestRampUp: primary — Y -= $20 (negated, player ascends going against slope)
;   - WestRampDown: continuation — Y += sub-tile offset (player descends at bottom)
;   - WestRedirectToSouth: fallback when no slope found, probes for south wall
; 
; All ramp routines share a common structure: probe ahead/behind for slope tile → compute sub-tile Y displacement proportional to X position within the tile → set playerFlags $1000 (on-slope) → post-slope wall check at FutureTR/FutureBR with corner snap paths. Sub-pixel half-rounding ($0004 bias) provides smooth ramp traversal. DiagClearReturnFlags is called at entry to reset collision state.
---------------------------------------------

?BANK 02

?INCLUDE 'player_move_diag'
?INCLUDE 'player_move_east'
?INCLUDE 'player_move_ns'
?INCLUDE 'player_move_south'
?INCLUDE 'tile_collision'

!playerFlags                    09AE
!playerSpeedEw                  09B2

---------------------------------------------

; Descend an east-facing slope ($0A) while moving east.
; 
; Despite the 'West' prefix, this handles the case where ProbeLeftTiles found an east-facing slope ($0A, carry clear). The player moves rightward and downward simultaneously.
; 
; Probe sequence: ProbeCurrentTR, then TileProbeMain at $1A−8 (8px left) for $0A. If not found, checks MapCellRight. If still not found, probes FutureTR at $1A−9. If no slope → EastRedirectToNorth.
; 
; Slope physics (if slope found + boundary crossed):
;   - Sub-tile X offset ($22+$20, >>2, AND $0F) ×4 → add to $26 (Y displacement proportional to X position)
;   - Half-pixel rounding: if LSR×3 produces carry, add $0004 to $26
;   - Direct slope (no boundary cross): $26 += $20 (1:1 Y from X velocity)
; 
; After slope displacement: sets playerFlags $1000 (on-slope). Checks FutureTR and FutureBR for walls: both solid → full corner collision snap. One solid → single-axis snap via code_02D92F or code_02D937.

EastRampDown {
    JSR $&player_move_diag.DiagClearReturnFlags ; EastRampDown: descend east-facing slope $0A while moving east (+X)
    JSR $&tile_collision.ProbeCurrentTR ; ProbeCurrentTR to anchor slope probe at top-right corner
    LDA $1A               ; Shift probe Y up 8px ($1A -= 8) — sample slope surface one row above feet
    SEC 
    SBC #$0008
    STA $1A
    JSR $&tile_collision.TileProbeMain ; TileProbeMain: collision at raised probe must be $0A east-facing slope
    AND #$00FF
    CMP #$000A
    BEQ code_02D8C7
    JSR $&tile_collision.MapCellDown ; No slope at probe: MapCellRight and re-read collision on adjacent cell
    SEP #$20
    JSR $&tile_collision.ReadCollisionNibble
    REP #$20
    AND #$00FF
    CMP #$000A
    BEQ code_02D8C7
    JSR $&tile_collision.ProbeFutureTR ; ProbeFutureTR one step east with probe Y raised 9px ($1A -= 9)
    LDA $1A
    SEC 
    SBC #$0009
    STA $1A
    JSR $&tile_collision.TileProbeMain ; Future TR raised probe must also read $0A for continuous slope
    AND #$00FF
    CMP #$000A
    BEQ loc_02D899
    JSR $&tile_collision.MapCellDown ; MapCellRight on future cell for alternate $0A detection
    SEP #$20
    JSR $&tile_collision.ReadCollisionNibble
    REP #$20
    AND #$00FF
    CMP #$000A
    BEQ loc_02D899
    JMP $&EastRedirectToNorth ; No matching $0A slope chain → EastRedirectToNorth wall fallback

  loc_02D899:
    JSR $&tile_collision.CheckTileBoundaryXor ; CheckTileBoundaryXor: did eastward move cross a 16px sub-tile X boundary?
    BNE loc_02D8A1
    JMP $&tile_collision.ApplyMovementDeltas ; No boundary cross → ApplyMovementDeltas without slope Y adjustment

  loc_02D8A1:
    LDA $20               ; Boundary cross: derive Y step from mean X sub-tile position (>>2, ×4)
    CLC 
    ADC $22
    LSR 
    LSR 
    AND #$000F
    ASL 
    ASL 
    CLC 
    ADC $26               ; Add computed Y displacement to $26 (Y sub-pixel position)
    STA $26
    CLC 
    ADC $20
    CLC 
    ADC $22
    LSR                   ; Third-bit test on combined X: half-tile rounding adjustment path
    LSR 
    LSR 
    BCC code_02D8CE
    LDA $26               ; Sub-tile bit set → add +$0004 half-pixel bias to $26 before slope apply
    CLC 
    ADC #$0004
    STA $26
    BRA code_02D8CE

  code_02D8C7:
    LDA $20               ; Direct slope step: $26 += $20 (8px NS velocity contribution)
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
    JMP $&code_02D92F

  loc_02D8EA:
    JSR $&tile_collision.ProbeFutureBR ; TR blocked: probe FutureBR — partial wall contact at top-right corner
    CMP #$0E
    BCS loc_02D8F4
    JMP $&code_02D937     ; TR wall + BR open → SnapYNorthCollision corner resolution

  loc_02D8F4:
    REP #$20              ; Both TR and BR blocked: full corner snap — align X to tile grid, recompute Y
    LDA $22               ; Save current $22; compute tile-column X from ($22+$20)>>2
    PHA 
    CLC 
    ADC $20
    LSR 
    LSR 
    SEC                   ; Round X to 8px grid (±$8 bias, mask low nibble), <<2 back to sub-pixels
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
    SBC $01, S            ; Y snap: delta from saved X vs new grid X, negated, added to $26
    SEC 
    SBC $20
    EOR #$FFFF
    INC 
    CLC 
    ADC $26
    STA $26
    PLA 
    STZ $20               ; Clear fractional $20/$24 and $playerSpeedEw after corner collision snap
    STZ $24
    STZ $playerSpeedEw
    JSR $&tile_collision.SetActorCollisionFlag
    JMP $&tile_collision.ApplyMovementDeltas
}

code_02D92F {
    REP #$20              ; code_02D92F: TR-only wall hit → SnapXEastCollision then apply movement
    JSR $&player_move_south.SnapYSouthCollision
    JMP $&tile_collision.ApplyMovementDeltas
}

code_02D937 {
    REP #$20              ; code_02D937: BR-only wall hit → SnapYNorthCollision then apply movement
    JSR $&player_move_ns.SnapYNorthCollision
    JMP $&tile_collision.ApplyMovementDeltas
}

---------------------------------------------
; Ascend an east-facing slope ($0A) while moving east — the uphill complement of EastRampDown.
; 
; Probes TileProbeMain at $1A+8 (8px right) for $0A. If not found → ApplyMovementDeltas (no slope). If found and boundary crossed: computes Y displacement as $24 = −(sub-tile X offset ×4 − $20), producing upward movement proportional to horizontal velocity. Falls into code_02D8CE for slope finalization.
; 
; If no boundary crossing: jumps to code_02D8C7 for direct 1:1 slope displacement.

EastRampUp {
    JSR $&player_move_diag.DiagClearReturnFlags ; EastRampUp: ascend east-facing slope $0A while moving east (+X)
    LDA $1A               ; Raise probe Y +8px ($1A += 8) to sample slope surface above feet
    CLC 
    ADC #$0008
    STA $1A
    JSR $&tile_collision.TileProbeMain ; TileProbeMain must read $0A at raised probe or movement proceeds normally
    AND #$00FF
    CMP #$000A
    BEQ loc_02D958
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02D958:
    JSR $&tile_collision.CheckTileBoundaryXor ; CheckTileBoundaryXor gates ramp fraction vs direct velocity path
    BNE loc_02D960
    JMP $&code_02D8C7     ; No boundary cross → reuse code_02D8C7 direct $26 += $20 path

  loc_02D960:
    LDA $20               ; Boundary cross: compute ramp fraction from X sub-tile + probe row → $24
    LSR 
    LSR 
    CLC 
    ADC $1A
    AND #$000F
    ASL 
    ASL 
    SEC                   ; Negated remainder (EOR #$FFFF INC) stores NS velocity for slope ascent
    SBC $20
    EOR #$FFFF
    INC 
    STA $24
    JMP $&code_02D8CE
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
; descend_TEMP a west-facing slope ($05) while moving east.
; 
; Mirror of EastRampDown for the opposite slope orientation. ProbeCurrentBR, then TileProbeMain at $1A−8 for $05. Multi-probe sequence through MapCellLeft, FutureTR, and $1A−9.
; 
; Slope physics: same structure as EastRampDown but Y displacement is NEGATED (EOR $FFFF, INC) since the slope descend_TEMPs in the opposite direction. Sub-pixel half-rounding subtracts $0004 instead of adding.
; 
; Direct slope: $26 += −$20 (inverted velocity).
; 
; Wall finalization: same FutureTR/FutureBR double-check with code_02DA7A/code_02DA82 snap paths. Corner collision produces full X/Y snap with speed zeroing.

WestRampUp {
    JSR $&player_move_diag.DiagClearReturnFlags ; WestRampUp: descend west-facing slope $05 while moving east (+X)
    JSR $&tile_collision.ProbeCurrentBR ; ProbeCurrentBR to anchor slope probe at bottom-right corner
    LDA $1A               ; Shift probe Y up 8px ($1A -= 8) for slope surface sampling
    SEC 
    SBC #$0008
    STA $1A
    JSR $&tile_collision.TileProbeMain ; TileProbeMain: collision at raised probe must be $05 west-facing slope
    AND #$00FF
    CMP #$0005
    BEQ code_02DA0E
    JSR $&tile_collision.MapCellUp ; No slope at probe: MapCellLeft and re-read collision on adjacent cell
    SEP #$20
    JSR $&tile_collision.ReadCollisionNibble
    REP #$20
    AND #$00FF
    CMP #$0005
    BEQ code_02DA0E
    JSR $&tile_collision.ProbeFutureTR ; ProbeFutureTR one step east with probe Y raised 9px
    LDA $1A
    SEC 
    SBC #$0009
    STA $1A
    JSR $&tile_collision.TileProbeMain ; Future TR raised probe must read $05 for continuous west-facing slope
    AND #$00FF
    CMP #$0005
    BEQ loc_02D9DC
    JSR $&tile_collision.MapCellDown ; MapCellRight on future cell for alternate $05 detection
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
    LDA $20               ; Negated Y step from mean X sub-tile (EOR #$FFFF INC pattern) → $26
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
    LSR                   ; Third-bit rounding test on combined X for west-facing slope
    LSR 
    LSR 
    BCC code_02DA19
    LDA $26               ; Sub-tile bit set → subtract $0004 half-pixel bias from $26
    SEC 
    SBC #$0004
    STA $26
    BRA code_02DA19

  code_02DA0E:
    LDA $20               ; Direct slope step: negated $20 added to $26 (west-facing descent)
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
    JMP $&code_02DA7A

  loc_02DA35:
    JSR $&tile_collision.ProbeFutureBR ; TR blocked at corner: probe FutureBR for partial wall resolution
    CMP #$0E
    BCS loc_02DA3F
    JMP $&code_02DA82     ; TR wall + BR open → SnapYNorthCollision corner path

  loc_02DA3F:
    REP #$20              ; Both corners blocked: full corner snap (mirror of EastRampDown corner math)
    LDA $22
    PHA 
    CLC 
    ADC $20
    LSR 
    LSR 
    SEC                   ; Round X to 8px grid with ±$8 bias for west-facing slope corner
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

code_02DA7A {
    REP #$20              ; code_02DA7A: TR-only wall → SnapXEastCollision then apply
    JSR $&player_move_south.SnapYSouthCollision
    JMP $&tile_collision.ApplyMovementDeltas
}

code_02DA82 {
    REP #$20              ; code_02DA82: BR-only wall → SnapYNorthCollision then apply
    JSR $&player_move_ns.SnapYNorthCollision
    JMP $&tile_collision.ApplyMovementDeltas
}

---------------------------------------------
; ascend_TEMP a west-facing slope ($05) while moving east.
; 
; Probes TileProbeMain at $1A+8 for $05. If found and boundary crossed: $24 = sub-tile X offset ×4 − $20 (positive, producing upward displacement). Falls into code_02DA19 for slope finalization.
; 
; Mirror of EastRampUp with positive Y displacement instead of negative.

WestRampDown {
    JSR $&player_move_diag.DiagClearReturnFlags ; WestRampDown: ascend west-facing slope $05 while moving east (+X)
    LDA $1A               ; Raise probe Y +8px ($1A += 8) to sample west-facing slope surface
    CLC 
    ADC #$0008
    STA $1A
    JSR $&tile_collision.TileProbeMain ; TileProbeMain must read $05 at raised probe or apply movement normally
    AND #$00FF
    CMP #$0005
    BEQ loc_02DAA3
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02DAA3:
    JSR $&tile_collision.CheckTileBoundaryXor ; CheckTileBoundaryXor gates ramp fraction vs direct velocity on ascent
    BNE loc_02DAAB
    JMP $&code_02DA0E     ; No boundary cross → code_02DA0E direct negated-$20 Y step

  loc_02DAAB:
    LDA $20               ; Boundary cross: ramp fraction from X sub-tile + probe row → $24 (no negate)
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
    JMP $&code_02DA19
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