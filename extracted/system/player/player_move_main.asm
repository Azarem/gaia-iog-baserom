; Player movement tick and collision helpers — main movement dispatch and grid alignment (184272–185206, Bank 02).
; 
; Contains the per-frame player movement entry point and shared collision helper routines used by the north/south and east/west movement handlers (in player_move_ns and player_move_east respectively).
; 
; === MOVEMENT TICK (PlayerMovementTick) ===
; 
; The main entry point called by the player_move_controller companion actor when the player is grounded (flag $0008 set). Processes movement in two phases:
; 
; Phase 1 — Horizontal (EW) movement:
;   - Reads DP $20 (EW velocity from JoypadToVelocity)
;   - Zero velocity → skip. Negative → diagonal down-left dispatch (DispatchDiagDownLeft with $0040 flag). Positive → east dispatch (DispatchEastMove with $0040 flag).
;   - After dispatch: converts sub-pixel X ($22) back to pixel via >>2, stores to player actor $0014. Same for Y ($26 → $0016).
; 
; Phase 2 — Vertical (NS) movement:
;   - Restores the saved NS velocity from stack ($24). Negative → north dispatch (DispatchNorthMove, gated by $0800 collision flag). Positive → south dispatch (DispatchSouthMove, gated by $0400 flag).
; 
; The $AA register accumulates collision flags during movement: bit $0800 = south wall contact, bit $0400 = east wall contact, bit $0040 = diagonal mode active.
; 
; === GRID ALIGNMENT (AutoAlignEW) ===
; 
; When the player moves north or south past a tile boundary, AutoAlignEW checks whether the player's X position is slightly misaligned with the 16px tile grid. If the sub-tile offset is in the nudge range (6-8 or 9+ pixels), and the adjacent tile is passable (collision < $0E, not $06/$09), the player is nudged toward grid alignment. This prevents the player from getting caught on tile corners during vertical movement.
; 
; Two nudge directions: NudgeToLowerGrid (toward lower X boundary, offset 6-8) and NudgeToUpperGrid (toward upper X boundary, offset 9+). Both adjust the position by ±8 pixels and snap to a 64-pixel grid boundary ($FFC0 mask) if the adjustment crosses a grid line.
; 
; === SNAP OFFSET COMPUTATION ===
; 
; ComputeYSnapOffset: Computes a Y-axis snap correction. Takes the low nibble of $1E (sub-tile Y position), inverts it via two's complement (ORA $FFF0, EOR $FFFF, INC), producing a signed offset that would align Y to the next tile boundary downward. Used by south movement collision to snap the player to the tile edge on wall contact.
; 
; DiagSnapCompute_Unused: An unused diagonal snap routine that combines slope tile detection ($06/$09) with Y-axis alignment. Probes the current tile, checks sub-tile X alignment, and computes a combined snap offset incorporating both the Y snap and an optional $10 (16-pixel) slope correction. The _Unused suffix indicates this code is present but not called by any active code path.
---------------------------------------------

?BANK 02

?INCLUDE 'player_move_diag'
?INCLUDE 'player_move_east'
?INCLUDE 'player_move_ns'
?INCLUDE 'player_move_south'
?INCLUDE 'tile_collision'

!playerActor                    09AA
!collisionLayer                 7FC000

---------------------------------------------

; Per-frame grounded player movement dispatch with collision.
; 
; Entry: X = player actor DP offset (stored to $000A). Called by player_move_controller when the player is grounded (flag $0008).
; 
; Two-phase processing:
; 
; Phase 1 (EW/diagonal): Reads DP $20 (horizontal velocity). Saves $24 (vertical velocity) to stack, zeroes $24 and $AA (collision flags). Clears player actor flag $0004 (solid contact). Dispatches based on $20 sign: negative → DispatchDiagDownLeft (with $0040 diagonal flag), positive → DispatchEastMove (with $0040). After dispatch, converts sub-pixel positions ($22, $26) back to pixel (>>2) and stores to player actor $0014/$0016.
; 
; Phase 2 (NS): Restores $24 from stack. Negative → DispatchNorthMove (skipped if $AA bit $0800 set = south wall). Positive → DispatchSouthMove (skipped if $AA bit $0400 set = east wall).
; 
; DP is set to $0000 during movement calculations. Player actor pointer X is saved and restored via PHX/PLX.

PlayerMovementTick {
    PHP 
    PHD 
    PHX 
    STX $000A
    LDA #$0000            ; Set DP=$0000 — movement scratch vars live at $20-$26, $AA, $02-$04
    TCD 
    LDA $24               ; Stash NS velocity $24 on stack; clear so EW collision phase runs first
    STZ $24
    STZ $AA               ; Clear per-tick movement/collision flags ($AA)
    PHA 
    LDA $0010, X          ; Clear actor solid-contact flag bit 2 ($0004) at actor+$0010 before collision pass
    AND #$FFFB
    STA $0010, X
    LDA $20               ; EW velocity gate: $20==0 skip; negative→diag down-left, positive→east
    BEQ loc_02D002
    BPL loc_02CFFA
    LDA #$0040            ; Set diagonal flag $0040 in $AA before DispatchDiagDownLeft
    TSB $AA
    JSR $&player_move_diag.DispatchDiagDownLeft ; Dispatch diagonal down-left collision (negative EW velocity)
    BRA loc_02D002

  loc_02CFFA:
    LDA #$0040            ; Set diagonal flag $0040 in $AA before DispatchEastMove
    TSB $AA
    JSR $&player_move_east.DispatchEastMove ; Dispatch east collision (positive EW velocity)

  loc_02D002:
    REP #$20              ; 16-bit mode: reload player actor index for pixel writeback
    LDX $playerActor
    LDA $22               ; Sub-pixel X delta ($22>>2) → actor pixel offset +$0014
    LSR 
    LSR 
    STA $0014, X
    LDA $26               ; Sub-pixel Y delta ($26>>2) → actor pixel offset +$0016
    LSR 
    LSR 
    STA $0016, X
    STZ $20               ; Clear EW velocity $20 after EW collision phase completes
    PLA                   ; Restore saved NS velocity $24 from stack
    STA $24
    BEQ loc_02D034        ; NS velocity gate: zero→done; sign selects north vs south dispatch
    BPL loc_02D02A
    LDA $AA               ; North move (negative $24): skip if $AA bit $0800 set (south wall from EW/diag)
    BIT #$0800
    BNE loc_02D034
    JSR $&player_move_ns.DispatchNorthMove ; NS phase: dispatch north collision (negative NS velocity)
    BRA loc_02D034

  loc_02D02A:
    LDA $AA               ; South move (positive $24): skip if $AA bit $0400 set (east wall from EW/diag)
    BIT #$0400
    BNE loc_02D034
    JSR $&player_move_south.DispatchSouthMove ; NS phase: dispatch south collision (positive NS velocity)

  loc_02D034:
    PLX 
    PLD 
    PLP 
    RTL 
}
---------------------------------------------

; Compute a Y-axis snap correction to align the player to the next tile boundary.
; 
; Reads the low nibble of $1E (sub-tile Y position within the 16px grid), inverts it via two's complement: OR $FFF0 (sign-extend to 16-bit), XOR $FFFF + INC (negate). The result in $02 is the number of sub-pixels to add to snap Y downward to the tile boundary.
; 
; For example: if $1E low nibble = $04, the offset is $000C (12 pixels to the next boundary). If $00, offset is $0000 (already aligned).

ComputeYSnapOffset {
    REP #$20
    LDA $1E               ; ComputeYSnapOffset: read sub-tile Y position from $1E
    AND #$000F            ; Mask to low nibble — position within 16px tile row
    ORA #$FFF0            ; Sign-extend nibble to signed 16-bit (-16..+15 via ORA #$FFF0)
    EOR #$FFFF            ; Two's complement negate +1 → pixels to snap Y up to previous grid line
    INC 
    STA $02
    RTS 
}

---------------------------------------------
; Unused diagonal movement snap computation with slope tile detection.
; 
; Saves pixel positions $1A/$1E, probes the current tile via ProbeCurrentTL. If the tile is type $06 (transition), or sub-tile X alignment + adjacent $09 check passes, computes a combined snap offset incorporating a $10 (16-pixel) slope correction in $02.
; 
; The main snap calculation takes the NS velocity ($24), converts to pixel offset (>>2, OR $C000 for sign preservation), negates, adds to $1E, and XORs with the original to detect a 16px boundary crossing (BIT #$0010). If crossed, $02 gets $0010 added.
; 
; Finally adds the standard Y snap offset (same as ComputeYSnapOffset) to $02.
; 
; Not called by any active code — appears to be a development-era diagonal collision experiment that was superseded by the current DispatchDiag* system.

DiagSnapCompute_Unused {
    REP #$20              ; DiagSnapCompute_Unused: save probe coords ($1A, $1E) on stack
    LDA $1A
    PHA 
    LDA $1E
    PHA 
    SEP #$20              ; Switch to 8-bit for tile collision probe routines
    JSR $&tile_collision.ProbeCurrentTL ; Probe current TL tile; slope type $06 → take slope snap path
    CMP #$06
    BEQ loc_02D277
    JSR $&tile_collision.CheckSubTileAlignX ; X sub-tile in right half (CheckSubTileAlignX carry) → inspect cell below
    BCC loc_02D2A3
    JSR $&tile_collision.MapCellRight ; MapCellRight from probe; type $09 (slope) → take slope snap path
    JSR $&tile_collision.ReadCollisionNibble
    CMP #$09
    BNE loc_02D2A3

  loc_02D277:
    REP #$20              ; Slope path: restore saved coords, begin X snap offset computation
    PLA 
    STA $1E
    PLA 
    STA $1A
    STZ $02               ; Zero base snap offset ($02) before velocity contribution
    LDA $1E               ; Push current Y sub-tile for 16px boundary crossing test
    PHA 
    LDA $24               ; If NS velocity $24 nonzero: convert to pixel delta (>>2)
    BEQ loc_02D28D        ; No NS velocity → skip velocity contribution to X snap
    LSR 
    LSR 
    ORA #$C000            ; Sign-extend pixel velocity: ORA #$C000 after >>2

  loc_02D28D:
    EOR #$FFFF            ; Negate predicted pixel step; add to saved sub-tile Y on stack
    INC 
    CLC 
    ADC $01, S
    EOR $01, S            ; XOR old/new Y sub-tiles; BIT #$0010 detects 16px grid line crossing
    BIT #$0010
    BEQ loc_02D2A0
    LDA #$0010            ; Grid line crossed → add 16px ($0010) to snap offset
    STA $02

  loc_02D2A0:
    PLA 
    BRA loc_02D2AD

  loc_02D2A3:
    REP #$20              ; Non-slope path: restore coords, zero velocity snap component
    PLA 
    STA $1E
    PLA 
    STA $1A
    STZ $02

  loc_02D2AD:
    LDA $1E               ; Add base Y snap (ComputeYSnapOffset formula) to accumulated offset in $02
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
; Auto-align player X position to the tile grid during vertical movement.
; 
; Called during north/south movement to prevent the player from catching on tile corners. Checks if the player's sub-tile X offset ($22 >> 2 − 8, AND $0F → $04) is in a nudgeable range:
; 
; Skip conditions (return SEC = no alignment):
;   - $AA bit $0040 set (diagonal mode active — alignment handled elsewhere)
;   - collisionLayer high nibble nonzero (special collision type)
;   - Sub-tile offset is exactly 0 (already aligned)
; 
; Nudge toward lower grid (offset 6-8): Probes ProbeFutureTR — if collision is passable (< $0E, not $06), subtracts $20 from $22, calls NudgeToLowerGrid, restores +$20. Returns CLC (alignment applied).
; 
; Nudge toward upper grid (offset 1-8, via 9+ check): Probes ProbeFutureTL with the same passability check. Subtracts $20, calls NudgeToUpperGrid, restores +$20. Returns CLC.
; 
; The ±$20 offset adjusts the probe position to test the tile the player would enter after the nudge.

AutoAlignEW {
    REP #$20              ; AutoAlignEW: skip if diagonal flag $0040 set in $AA
    LDA $AA
    BIT #$0040
    BNE loc_02D339
    LDA $collisionLayer, X ; Skip if collision layer high nibble nonzero (special tile layer active)
    AND #$00FF
    BIT #$00F0
    BNE loc_02D339
    LDA $22               ; Compute X sub-tile offset: (pixelX>>2) - 8, masked to $0F
    LSR 
    LSR 
    SEC 
    SBC #$0008
    AND #$000F
    STA $04               ; Offset zero → already grid-aligned, no nudge needed
    BEQ loc_02D339
    CMP #$0006            ; Offset >= 6 → try nudge down to lower grid line (TR probe path)
    BCC loc_02D30D
    JSR $&tile_collision.ProbeFutureTR ; ProbeFutureTR at hypothetical position
    CMP #$000E            ; Passable only if collision nibble < $0E (not solid wall)
    BCS loc_02D30D
    CMP #$0006            ; Exclude slope tile $06 from lower-grid nudge target
    BEQ loc_02D30D
    LDX #$0022            ; Temporarily shift probe X back $20 sub-pixels for nudge test
    LDA $00, X
    SEC 
    SBC #$0020
    STA $00, X
    JSR $&NudgeToLowerGrid ; NudgeToLowerGrid on working X; restore probe offset afterward
    LDA $00, X
    CLC 
    ADC #$0020
    STA $00, X
    CLC                   ; Lower-grid nudge succeeded — return carry clear
    RTS 

  loc_02D30D:
    LDA $04               ; Offset < 9 → try nudge up to upper grid line (TL probe path)
    CMP #$0009
    BCS loc_02D339
    JSR $&tile_collision.ProbeFutureTL ; ProbeFutureTL at hypothetical position
    CMP #$000E            ; Passable if nibble < $0E and ≠ $09 (exclude north-wall slope tile)
    BCS loc_02D339
    CMP #$0009
    BEQ loc_02D339
    LDX #$0022            ; Temporarily shift probe X back $20; NudgeToUpperGrid; restore
    LDA $00, X
    SEC 
    SBC #$0020
    STA $00, X
    JSR $&NudgeToUpperGrid
    LDA $00, X
    CLC 
    ADC #$0020
    STA $00, X
    CLC                   ; Upper-grid nudge succeeded — return carry clear
    RTS 

  loc_02D339:
    SEC                   ; No nudge applied — return carry set (alignment skipped/failed)
    RTS 
}

---------------------------------------------
; Nudge a sub-pixel position toward the lower 64-pixel grid boundary.
; 
; Adds 8 to the position at [$00+X]. XORs old and new values — if bit 6 changed (crossed a $40 boundary), snaps to the boundary via AND $FFC0. This ensures the nudge doesn't overshoot into the next grid cell.
; 
; X register selects which position to nudge ($22 for X sub-pixel, $26 for Y sub-pixel).

NudgeToLowerGrid {
    LDA $00, X            ; NudgeToLowerGrid: +8 sub-pixels toward next lower 64px boundary
    PHA 
    CLC 
    ADC #$0008
    STA $00, X
    EOR $01, S            ; XOR pre/post value; BIT #$0040 detects 64px half-tile boundary crossing
    BIT #$0040
    BEQ loc_02D352
    LDA $00, X
    AND #$FFC0            ; Boundary crossed → snap down with AND #$FFC0 (align to 64px grid)
    STA $00, X

  loc_02D352:
    PLA 
    RTS 
}

---------------------------------------------
; Nudge a sub-pixel position toward the upper 64-pixel grid boundary.
; 
; Subtracts 8 from the position at [$00+X]. XORs old and new — if bit 6 changed (crossed a $40 boundary upward), snaps to the next $40 boundary above via AND $FFC0 + ADC $0040. Handles the case where the subtraction would undershoot by checking BIT $003F (non-zero means not already at boundary).

NudgeToUpperGrid {
    LDA $00, X            ; NudgeToUpperGrid: -8 sub-pixels toward previous upper grid line
    PHA 
    SEC 
    SBC #$0008
    STA $00, X
    EOR $01, S            ; XOR detects $0040 half-tile boundary crossing (same technique as lower nudge)
    BIT #$0040
    BEQ loc_02D374
    LDA $00, X            ; If low 6 bits remain after cross, snap with AND #$FFC0 then add $0040
    BIT #$003F
    BEQ loc_02D374        ; Sub-tile remainder zero after upper nudge → no further snap needed
    AND #$FFC0
    CLC 
    ADC #$0040
    STA $00, X

  loc_02D374:
    PLA 
    RTS 
}