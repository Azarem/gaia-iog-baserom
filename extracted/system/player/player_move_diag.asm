; Diagonal movement collision — down-left diagonal with slope ramp physics (187264–188674, Bank 02).
; 
; Handles the player's diagonal (down-left) movement, including wall collision, slope traversal, and grid alignment. This is the diagonal counterpart to the cardinal-direction movement files (player_move_south, player_move_ns, player_move_east).
; 
; === ARCHITECTURE ===
; 
; Diagonal movement combines X and Y displacement simultaneously. The collision detection must handle interactions with both cardinal-direction wall tiles and slope tiles, which creates complex branching:
; 
; 1. SLOPE CHECK: First checks for slope tiles using ProbeRightTiles. If a west-facing ($05) or east-facing ($0A) slope is found, dispatches to DiagRampUpLeft or DiagRampDownRight respectively.
; 
; 2. WALL PROBING: If no slope, probes current and future tile positions (ProbeCurrentTL, ProbeCurrentBL, ProbeFutureTL) checking for wall tiles:
;   - Tile $06: North-facing wall (handled by code_02DC4B/code_02DC77)
;   - Tile $09: South-facing wall (handled by code_02DC9F/code_02DCCB)
;   - Tile $07: Ladder (enters shimmy-left via DiagLadderTile)
;   - Tile $0E+: Solid wall (collision stop)
;   - Tile $05/$0A: Slope edge (DiagRampEdgeUL/DiagRampEdgeDR)
; 
; 3. SLOPE RAMP HANDLERS: DiagRampUpLeft and DiagRampDownRight implement the same slope physics as the cardinal ramp handlers but adapted for diagonal movement. They compute Y displacement proportional to X position within the slope tile, set playerFlags $1000 (on-slope), and perform post-slope wall checks.
; 
; 4. SNAP/PUSH RESOLUTION: When collisions occur, the system computes snap offsets (SnapXDiagCollision, ComputeDiagSnapOffset) and applies directional push (DiagPushLeft, DiagPushRight) to slide the player along walls during diagonal movement.
; 
; 5. AUTO-ALIGN: DiagAutoAlignNS checks if the player is slightly off-grid vertically and nudges toward alignment, preventing corner-catching on walls.
; 
; === DP VARIABLES ===
; 
; $20 = X movement delta (sub-pixel), $22 = X position, $24 = X snap adjustment
; $26 = Y position, $AA = collision flags accumulator, $AB = diagonal direction flags
; $1A/$1E = tile probe coordinates (modified during slope checks)
; $04 = scratch for sub-tile offset calculations
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

; Main dispatcher for down-left diagonal player movement.
; 
; Entry: sets direction flag $AB bit 1. Probe sequence:
; 1. ProbeRightTiles → slope check: west slope ($05) → DiagRampUpLeft, east slope ($0A) → DiagRampDownRight
; 2. ProbeCurrentTL for tile $06 (north wall) → code_02DC4B
; 3. ProbeCurrentBL for tile $09 (south wall) → code_02DC9F
; 4. ProbeFutureTL: $0E+ = wall collision, $06 = code_02DC77
; 5. CheckSubTileAlignY + MapCellDown adjacency checks for $09/$06/$07
; 6. ProbeCurrentTR for slope edges ($05 → DiagRampEdgeUL, $0A → DiagRampEdgeDR)
; 7. Default: apply X delta ($22 += $20)
; 
; Wall collision path: SetActorCollisionFlag → DiagAutoAlignNS → SnapXDiagCollision.

DispatchDiagDownLeft {
    SEP #$20              ; DispatchDiagDownLeft: down-left diagonal collision entry (8-bit probe mode)
    LDA #$02              ; Set $AB bit 1 ($0002) — down-left diagonal direction/status flag
    TSB $AB
    JSR $&map_coords.ProbeRightTiles ; ProbeRightTiles: sample east-adjacent row for slope vs open path
    BNE loc_02DB93        ; Passable right probe → check walls; carry set → west slope $05 (DiagRampUpLeft)
    BCS loc_02DB90
    JMP $&DiagRampDownRight ; Clear right probe → east descending slope $0A (DiagRampDownRight)

  loc_02DB90:
    JMP $&DiagRampUpLeft

  loc_02DB93:
    JSR $&tile_collision.ProbeCurrentTL ; ProbeCurrentTL: north-facing wall check at leading top-left corner
    BCC loc_02DB9F
    CMP #$06              ; Tile $06 north wall at current TL → code_02DC4B north-wall slide handler
    BNE loc_02DB9F
    JMP $&code_02DC4B

  loc_02DB9F:
    JSR $&tile_collision.ProbeCurrentBL ; ProbeCurrentBL: south-facing wall check at leading bottom-left corner
    BCC loc_02DBAB
    CMP #$09              ; Tile $09 south wall at current BL → code_02DC9F south-wall slide handler
    BNE loc_02DBAB
    JMP $&code_02DC9F

  loc_02DBAB:
    JSR $&tile_collision.ProbeFutureTL ; ProbeFutureTL: destination top-left before committing diagonal step
    BCC loc_02DBBB
    CMP #$0E              ; Future TL solid ($0E+) → hard wall collision (SetActorCollisionFlag path)
    BCS loc_02DC03
    CMP #$06              ; Future TL $06 north wall → code_02DC77 variant north-wall handler
    BNE loc_02DBBB
    JMP $&code_02DC77

  loc_02DBBB:
    JSR $&tile_collision.CheckSubTileAlignY ; CheckSubTileAlignY: Y sub-tile alignment gates south-wall adjacency probes
    BCS loc_02DBC9
    CMP #$09              ; Y misaligned + probe row $09 south wall → code_02DCCB south slide
    BNE loc_02DBC7
    JMP $&code_02DCCB

  loc_02DBC7:
    BRA loc_02DBE2

  loc_02DBC9:
    CMP #$09              ; Y aligned + south wall $09 in probe row → hard wall collision
    BEQ loc_02DC03
    JSR $&tile_collision.MapCellDown ; MapCellDown: probe tile below current for south/north wall chain
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
    CMP #$07              ; Tile type $07 ladder → DiagLadderTile climb/shimmy redirect
    BEQ DiagLadderTile
    JSR $&tile_collision.ProbeCurrentTR ; ProbeCurrentTR: west/east slope edge check at top-right corner
    BCC loc_02DBF9
    CMP #$05              ; TR tile $05 west slope edge → DiagRampEdgeUL partial ramp entry
    BNE loc_02DBF2
    JMP $&DiagRampEdgeUL

  loc_02DBF2:
    CMP #$0A              ; TR tile $0A east slope edge → DiagRampEdgeDR partial ramp entry
    BNE loc_02DBF9
    JMP $&DiagRampEdgeDR

  loc_02DBF9:
    REP #$20
    LDA $22               ; Unblocked diagonal: apply X sub-pixel delta ($22 += $20)
    CLC 
    ADC $20
    STA $22
    RTS 

  loc_02DC03:
    JSR $&tile_collision.SetActorCollisionFlag ; Wall collision: SetActorCollisionFlag marks actor contact this frame
    JSR $&DiagAutoAlignNS ; DiagAutoAlignNS: try Y grid nudge before hard X snap
    BCS SnapXDiagCollision ; Auto-align failed (carry set) → SnapXDiagCollision hard X grid snap
    PHP 
    REP #$20              ; Auto-align succeeded — still run X snap with processor state preserved
    BRA loc_02DC16
}

---------------------------------------------
; Snap X position to grid boundary on diagonal collision.
; 
; Computes: X = (X + delta - $20) & $FFC0 + $60, then zeroes X delta ($20). Optionally zeros playerSpeedEw. The $FFC0/$0060 mask rounds X to the nearest 16-pixel grid center (sub-pixel coordinates use ×4 scaling, so $40 = 16 pixels, $60 = center).

SnapXDiagCollision {
    PHP 
    REP #$20
    STZ $playerSpeedEw    ; Hard X snap: zero east-west speed ($playerSpeedEw)

  loc_02DC16:
    LDA $20               ; Snap X to 64px grid center: ((X+$20-$20)&$FFC0)+$60
    CLC 
    ADC $22
    SEC 
    SBC #$0020
    AND #$FFC0
    CLC 
    ADC #$0060
    STA $22
    STZ $20               ; Clear X velocity $20 after diagonal wall snap
    PLP 
    RTS 

  DiagLadderTile:
    JSR $&tile_collision.CheckSubTileAlignY ; Ladder $07: require Y sub-tile alignment (CheckSubTileAlignY)
    BCS loc_02DC03
    JSR $&DiagClearReturnFlags ; Clear stack return flags before switching player state
    PHY 
    REP #$20
    LDY $playerActor
    LDA #$&player_character.ShimmyLeftEntry ; Aligned on ladder: redirect actor state to ShimmyLeftEntry
    STA $0000, Y
    LDA #$0000            ; Clear actor movement sub-state (+$0008) for clean ladder grab
    STA $0008, Y
    PLY 
    BRA loc_02DC03

  DiagWallSouthFromDL:
    SEP #$20
}

code_02DC4B {
    LDA #$80              ; North wall handler: set $AB bit 7 ($0080) — north-wall slide flag
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
    LDA #$04              ; Variant north wall: set $AB bit 2 ($0004) from future TL probe
    TSB $AB
    BRA loc_02DC5B

  loc_02DC7D:
    JSR $&player_move_ns.SnapYNorthCollision ; Not slide-eligible: SnapYNorthCollision then re-probe future TL
    JSR $&tile_collision.ProbeFutureTL
    BCC loc_02DC8F
    CMP #$06              ; Still $06 north wall after Y snap → SnapXDiagCollision + apply
    BEQ loc_02DC8F
    JSR $&SnapXDiagCollision
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02DC8F:
    REP #$20
    JSR $&ComputeDiagSnapOffset ; North-wall slide open: ComputeDiagSnapOffset → DiagPushRight
    JMP $&DiagPushRight

  loc_02DC97:
    REP #$20
    STZ $playerSpeedEw    ; North-wall corner blocked: zero EW speed and abort
    RTS 
}

DiagWallNorthFromDL {
    SEP #$20
}

code_02DC9F {
    LDA #$80              ; South wall handler: set $AB bit 7 ($0080) — south-wall slide flag
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
    LDA #$08              ; Variant south wall: set $AB bit 3 ($0008) from adjacency probe
    TSB $AB
    BRA loc_02DCAF

  loc_02DCD3:
    JSR $&player_move_south.SnapYSouthCollision ; Not slide-eligible: SnapYSouthCollision then re-probe future BL
    JSR $&tile_collision.ProbeFutureBL
    BCC loc_02DCE5
    CMP #$09              ; Still $09 south wall after Y snap → SnapXDiagCollision + apply
    BEQ loc_02DCE5
    JSR $&SnapXDiagCollision
    JMP $&tile_collision.ApplyMovementDeltas

  loc_02DCE5:
    REP #$20
    JSR $&ComputeDiagSnapOffset ; South-wall slide open: ComputeDiagSnapOffset → DiagPushLeft
    JMP $&DiagPushLeft

  loc_02DCED:
    REP #$20
    STZ $playerSpeedEw    ; South-wall corner blocked: zero EW speed and abort
    RTS 
}

---------------------------------------------
; West-facing slope ($05) ascending handler for diagonal movement.
; 
; Multi-pass slope search: checks current TL tile at +8 Y offset, then adjacent MapCellDown, then future TL at +8. If no slope found in 4 probes, redirects to DiagRedirectToSouth.
; 
; On slope found: computes Y displacement proportional to X position within tile (sub-tile offset ×4), sets playerFlags $1000 (on-slope). Post-slope: checks both future TL and BL for wall collision, with full snap resolution for double-wall case.

DiagRampUpLeft {
    JSR $&DiagClearReturnFlags ; DiagRampUpLeft: west ascending slope $05 — clear stack return flags
    JSR $&tile_collision.ProbeCurrentTL ; Probe current TL with Y raised +8px for west slope surface sample
    LDA $1A
    CLC 
    ADC #$0008
    STA $1A
    JSR $&tile_collision.TileProbeMain
    AND #$00FF
    CMP #$0005            ; Raised TL reads $05 west slope → full-tile ramp (code_02DD82)
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
    JSR $&tile_collision.ProbeFutureTL ; Probe future TL at Y+8 for west slope continuation
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
    LDA $20               ; Ramp fraction: X sub-tile = (($22+$20)>>2) & $0F from leading edge
    CLC 
    ADC $22
    LSR 
    LSR 
    AND #$000F
    EOR #$FFFF            ; Proportional Y step: (16 − sub-tile) << 2 added to $26 (west ramp ascent)
    INC 
    CLC 
    ADC #$0010
    ASL 
    ASL 
    CLC 
    ADC $26
    STA $26
    CLC                   ; Add X delta to Y accumulator for fractional ramp carry-through
    ADC $20
    CLC 
    ADC $22
    LSR 
    LSR 
    LSR                   ; Sub-tile in upper half (carry) → extra +4px Y bump on west ramp
    BCC code_02DD8D
    LDA $26
    CLC 
    ADC #$0004
    STA $26
    BRA code_02DD8D
}

code_02DD82 {
    LDA $20               ; Full-tile west ramp: Y += negated X velocity ($26 += −$20)
    EOR #$FFFF
    INC 
    CLC 
    ADC $26
    STA $26

  code_02DD8D:
    LDA #$1000            ; Set playerFlags bit $1000 — on west/east diagonal slope this frame
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
    JSR $&tile_collision.ProbeFutureBL ; Future TL blocked — probe BL: only BL wall → south Y snap (code_02DDF2)
    CMP #$0E
    BCS loc_02DDB3
    JMP $&code_02DDFA     ; Future TL blocked, BL passable → north Y snap (code_02DDFA)

  loc_02DDB3:
    REP #$20
    LDA $22               ; Dual-wall ($0E+ both TL and BL): snap X to tile center, reconcile Y
    PHA 
    CLC 
    ADC $20
    LSR                   ; Dual-wall X snap: align to 16px sub-column grid from ($22+$20)
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
; Upper-left edge handler for west slope ($05) during diagonal movement.
; 
; Probes at current position minus 9 Y pixels for slope tile. If slope found and crossing tile boundary: computes proportional Y offset from X position with sub-pixel rounding, stores as X snap adjustment ($24). Falls through to post-slope wall check (code_02DD8D).

DiagRampEdgeUL {
    JSR $&DiagClearReturnFlags ; DiagRampEdgeUL: west slope edge probe at current Y − 9px
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
    LDA $20               ; Edge ramp: sub-pixel proportional Y offset from X velocity → $24
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
; Redirect to south wall handling when no slope tile found during diagonal west-slope search.
; 
; Checks ProbeFutureTL for tile $06 (north wall) → DiagWallSouthFromDL. Otherwise applies movement deltas normally.

DiagRedirectToSouth {
    JSR $&tile_collision.ProbeFutureTL ; DiagRedirectToSouth: no west slope — probe FutureTL for north wall $06
    CMP #$0006
    BNE loc_02DE4E
    JMP $&DiagWallSouthFromDL ; Future TL $06 → DiagWallSouthFromDL north-wall entry shim

  loc_02DE4E:
    JMP $&tile_collision.ApplyMovementDeltas
}

---------------------------------------------
; East-facing slope ($0A) descending handler for diagonal movement.
; 
; Mirror of DiagRampUpLeft for east slopes. Multi-pass search checks current BL, adjacent MapCellUp, future TL, and adjacent MapCellDown for tile $0A. Computes negated Y displacement (player descends along slope). Sets playerFlags $1000 (on-slope). Post-slope wall check with double-wall snap resolution.

DiagRampDownRight {
    JSR $&DiagClearReturnFlags ; DiagRampDownRight: east descending slope $0A — clear return flags
    JSR $&tile_collision.ProbeCurrentBL ; Probe current BL with Y raised +8px for east slope surface sample
    LDA $1A
    CLC 
    ADC #$0008
    STA $1A
    JSR $&tile_collision.TileProbeMain
    AND #$00FF
    CMP #$000A            ; Raised BL reads $0A east slope → full-tile ramp (code_02DEE4)
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
    JSR $&tile_collision.ProbeFutureTL ; Probe future TL at Y+8 for east slope continuation
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
    EOR #$FFFF            ; Proportional Y step: negated (16 − sub-tile) << 2 added to $26 (east ramp descent)
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
    CLC                   ; Add X delta to Y accumulator for fractional east-ramp carry-through
    ADC $20
    CLC 
    ADC $22
    LSR 
    LSR 
    LSR                   ; Sub-tile in upper half (carry) → extra −4px Y trim on east ramp
    BCC code_02DEEB
    LDA $26
    SEC 
    SBC #$0004
    STA $26
    BRA code_02DEEB
}

code_02DEE4 {
    LDA $20               ; Full-tile east ramp: Y += X velocity ($26 += $20)
    CLC 
    ADC $26
    STA $26

  code_02DEEB:
    LDA #$1000            ; Set playerFlags bit $1000 — on diagonal slope this frame
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
    JSR $&tile_collision.ProbeFutureBL ; Future TL blocked — probe BL: only BL wall → south Y snap (code_02DF4C)
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
; Down-right edge handler for east slope ($0A) during diagonal movement.
; 
; Mirror of DiagRampEdgeUL. Probes at position minus 9 Y for east slope tile, computes proportional Y offset, stores as X snap ($24), falls through to post-slope wall check.

DiagRampEdgeDR {
    JSR $&DiagClearReturnFlags ; DiagRampEdgeDR: east slope edge probe at current Y − 9px
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
    LDA $20               ; Edge ramp: sub-pixel proportional Y offset from X velocity → $24
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
; Redirect to north wall handling when no east slope found.
; 
; Checks ProbeFutureBL for tile $09 (south wall) → DiagWallNorthFromDL. Otherwise applies movement deltas normally.

DiagRedirectToNorth {
    JSR $&tile_collision.ProbeFutureBL ; DiagRedirectToNorth: no east slope — probe FutureBL for south wall $09
    CMP #$0009
    BNE loc_02DFA4
    JMP $&DiagWallNorthFromDL ; Future BL $09 → DiagWallNorthFromDL south-wall entry shim

  loc_02DFA4:
    JMP $&tile_collision.ApplyMovementDeltas
}

---------------------------------------------
; Auto-align player to north/south grid during diagonal movement.
; 
; Prevents corner-catching by nudging the player's Y coordinate toward grid alignment. Checks:
; 1. Skip if return flags are nonzero (already handling collision)
; 2. Skip if collision layer has upper nibble set (special terrain)
; 3. Get Y sub-tile offset (0–15); skip if already aligned (0)
; 4. If offset ≥ 4: check ProbeFutureBL for wall, NudgeToLowerGrid
; 5. If offset < 11: check ProbeFutureTL for wall, NudgeToUpperGrid
; 
; Returns carry clear = nudge applied, carry set = no nudge possible.

DiagAutoAlignNS {
    PHP                   ; DiagAutoAlignNS: Y-axis auto-align before diagonal X wall snap
    REP #$20
    LDA $06, S            ; Skip nudge if stack frame EW return flag ($06,S) is nonzero
    BNE loc_02DFF3
    LDA $collisionLayer, X ; Skip nudge if collision layer high nibble set (overlay/special layer)
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
    BCC loc_02DFDB        ; Offset ≥ 4: probe FutureBL — passable (< $0E) → NudgeToLowerGrid on $26
    JSR $&tile_collision.ProbeFutureBL
    CMP #$000E
    BCS loc_02DFDB
    LDX #$0026
    JSR $&player_move_main.NudgeToLowerGrid ; Lower-grid Y nudge succeeded → return carry clear
    PLP 
    CLC 
    RTS 

  loc_02DFDB:
    LDA $04
    CMP #$000B            ; Offset < $0B: probe FutureTL — passable (< $0E) → NudgeToUpperGrid on $26
    BCS loc_02DFF3
    JSR $&tile_collision.ProbeFutureTL
    CMP #$000E
    BCS loc_02DFF3
    LDX #$0026
    JSR $&player_move_main.NudgeToUpperGrid ; Upper-grid Y nudge succeeded → return carry clear
    PLP 
    CLC 
    RTS 

  loc_02DFF3:
    PLP 
    SEC                   ; No nudge applied — return carry set (alignment skipped/failed)
    RTS 
}

---------------------------------------------
; Compute snap offset for diagonal wall collision resolution.
; 
; Saves and restores tile probe coordinates ($1A/$1E). Checks if current TL is tile $09 or if MapCellDown below is tile $06 (boundary between wall types). If so, computes additional $10 offset for cross-boundary snapping. Final offset = (sub-tile X position masked to upper nibble, complemented) + boundary adjustment. Result stored in $02 for DiagPushLeft/DiagPushRight.

ComputeDiagSnapOffset {
    REP #$20              ; ComputeDiagSnapOffset: save probe coords $1A/$1E on stack
    STZ $02
    LDA $1A
    PHA 
    LDA $1E
    PHA 
    SEP #$20
    JSR $&tile_collision.ProbeCurrentTL ; ProbeCurrentTL: south wall $09 at TL → wall-boundary snap path
    CMP #$09
    BEQ loc_02E018
    JSR $&tile_collision.CheckSubTileAlignY ; Y right-half aligned: MapCellDown for north wall $06 below
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
; Apply leftward (negative X) push during diagonal collision.
; 
; Takes snap offset from $02, adds Y sub-tile position. If total exceeds $11 (one full tile + 1): checks if X delta ($20) exceeds the caller's return value ($03,S) — if exceeded, zeroes delta and clears collision flags $0840 from $AA. Otherwise converts offset to negative sub-pixel X adjustment ($24 = -offset × 4). Applies movement deltas.

DiagPushLeft {
    LDA $26               ; DiagPushLeft: negative X push along south-wall slide
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
    LDA $03, S            ; Compare |$20| vs caller return threshold ($03,S) for overshoot detection
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
    LDA #$0840            ; Overshoot past wall: zero $20, clear $AA bits $0840 (south-wall collision flags)
    TRB $AA
    RTS 

  loc_02E096:
    LDA $02               ; Valid push: store negated sub-pixel X snap in $24, apply movement
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
; Apply rightward (positive X) push during diagonal collision.
; 
; Mirror of DiagPushLeft. Uses complemented Y sub-tile position. Positive X adjustment ($24 = offset × 4). Clears collision flags $0440 from $AA on overshoot.

DiagPushRight {
    LDA $26               ; DiagPushRight: positive X push along north-wall slide
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
    LDA $03, S            ; Compare |$20| vs caller return threshold ($03,S) for overshoot detection
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
    LDA #$0440            ; Overshoot past wall: zero $20, clear $AA bits $0440 (north-wall collision flags)
    TRB $AA
    RTS 

  loc_02E0E9:
    LDA $02               ; Valid push: store positive sub-pixel X snap in $24, apply movement
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
; Clear return flags on the caller's stack frame. Zeroes the 16-bit value at stack offset $05 (the caller's saved flags), signaling that no collision/redirect has occurred yet.

DiagClearReturnFlags {
    REP #$20              ; DiagClearReturnFlags: zero stack frame return flags at offset $05,S
    LDA #$0000
    STA $05, S
    RTS 
}