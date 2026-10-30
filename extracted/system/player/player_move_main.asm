; Player movement tick and collision helpers (184272-185206, Bank 02). PlayerMovementTick is the collision-checked movement entry; the other routines are the shared helpers of the north / south / east / west handlers (player_move_ns, player_move_south, player_move_east, player_move_west).
; 
; === ENTRY CONTRACT ===
; 
; PlayerMoveController (actors/player/player_move_controller) calls it with JSL once per frame when the player actor's flags word ($10) has bit $0008 set (collision-checked movement; the ledge-jump, ladder and shimmy states clear it, and then the controller adds the velocity to the position directly, with no collision). X at entry is the CONTROLLER's own actor slot: the tick saves it in the absolute scratch word $000A, and SetActorCollisionFlag later ORs bit $0004 (solid contact this tick) into that slot's $10; the controller copies the bit into the player's $10 when it writes the position back. The tick itself starts by clearing bit $0004 there.
; 
; D is set to $0000 for the whole tick, so the 2-digit operands below are low-RAM scratch words: $20 / $22 = X velocity / position, $24 / $26 = Y velocity / position, all in sub-pixels (4 per pixel, Y grows downward; the controller scaled the position by 4 before the call and wrote them to $22 / $26), $1A / $1E = the last probe's pixel X / Y, $00 / $02 / $04 = scratch, $AA / $AB = per-tick flag words (cleared together). The reference point of the 16x16 hitbox is the centre of its bottom edge.
; 
; === TWO PHASES ===
; 
; 1. Horizontal: the vertical velocity $24 is parked on the stack and zeroed. $20 = 0 skips the phase. Otherwise $AA bit $0040 is set (see below) and DispatchWestMove (negative $20) or DispatchEastMove (positive $20) runs. Afterwards $22 >> 2 and $26 >> 2 are stored in the player actor's pixel position ($0014 / $0016: the values are POSITIONS, not deltas) and $20 is cleared.
; 2. Vertical: the parked velocity is popped back into $24. Wall-slide handlers of the horizontal phase can zero the parked word (CancelVerticalPhase in player_move_west), which then cancels this phase. Zero skips it, negative runs DispatchNorthMove, positive runs DispatchSouthMove. The controller commits the final $22 / $26 after the tick returns.
; 
; $AA bits: $0040 = horizontal phase ran (read by AutoAlignEW_North here and AutoAlignEW_South, which refuse to nudge in that case). $0800 and $0400 are tested before the north and south dispatch, but nothing in extracted/ ever sets them; player_move_west only clears them (TRB #$0840 / #$0440). Those two gates therefore always pass. $AB bit 1 is set by DispatchWestMove and read by player_move_ns.
; 
; === AutoAlignEW_North (north counterpart of AutoAlignEW_South) ===
; 
; Called only from the blocked path of DispatchNorthMove. Returns carry CLEAR when X was nudged by 2 pixels toward the open column, carry SET when nothing was done. Gates (carry set): $AA bit $0040, an actor solid mark in the collision byte at the map index left in X by the last probe (high nibble), or n = 0. n = (($22 >> 2) - 8) AND $0F is the offset of the hitbox's LEFT edge (X - 8) inside its 16-pixel column. n >= 6 tries an east nudge first: it needs ProbeFutureTR to return a type below $0E and not $06. If that fails (or n < 6) and n < 9, a west nudge is tried: ProbeFutureTL below $0E and not $09. So n = 1..5 can only go west, 6..8 prefers east, 9..15 can only go east.
; Each nudge temporarily subtracts $20 sub-pixels (8 px) from $22 so that the helper tests the left edge, calls NudgeAxisPlus8Clamped (+8) or NudgeAxisMinus8Clamped (-8), then adds $20 back; the 2-pixel nudge itself stays in $22.
; 
; === NUDGE HELPERS ===
; 
; Both work on the word at [$00 + X] (X = $22 for the X position, X = $26 for the Y position in player_move_east / player_move_west). NudgeAxisPlus8Clamped adds 8 sub-pixels (toward larger coordinates: east or south); if that crosses a $40 line (16 px) the result is floored to the line (AND #$FFC0), so the edge ends exactly flush. NudgeAxisMinus8Clamped subtracts 8 and, on crossing a $40 line, clamps back up to that line ((value AND #$FFC0) + $40). The 'lower' and 'upper' in the names refer to coordinate order, not to a screen direction.
; 
; === ComputeYSnapOffset ===
; 
; $02 = 16 - (probe pixel Y AND $0F): the number of pixels to the next row line below, 1..16 ($10 when the probe is already flush). The computation is OR #$FFF0, EOR #$FFFF, INC. $1E is a pixel Y, not a sub-pixel position. Called from player_move_ns only (2 sites).
; 
; === DiagSnapCompute_Unused ===
; 
; No reference anywhere in extracted/. It probes the current TL cell and takes the 'wall path' when the type is $06, or when X straddles two columns and the cell to the right is $09 (the same wall-like types as the north handlers). On the wall path $02 starts at 0; a nonzero $24 is converted to a pixel step ((>>2) OR #$C000 sign-extends only a NEGATIVE value, so it assumes a north move), negated, added to the saved Y, and if that crosses a 16-px line ($1E bit 4 changes) $02 = $10. The ComputeYSnapOffset formula for the current $1E is then added to $02. The probe coordinates $1A / $1E are saved and restored around the probe.
; 
; Everything here is UNVERIFIED-RUNTIME (no emulator trace); the arithmetic is read from the code.
---------------------------------------------

?BANK 02

?INCLUDE 'player_move_east'
?INCLUDE 'player_move_ns'
?INCLUDE 'player_move_south'
?INCLUDE 'player_move_west'
?INCLUDE 'tile_collision'

!playerActor                    09AA
!collisionLayer                 7FC000

---------------------------------------------

; Per-frame collision-checked movement, called by PlayerMoveController. Parks $24, runs the horizontal phase (West / East dispatch), publishes the horizontal result to the player actor's pixel position, un-parks $24 and runs the vertical phase (North / South dispatch). X = controller slot at entry; D = $0000 inside; P, D and X are restored.

PlayerMovementTick {
    PHP 
    PHD 
    PHX 
    STX $000A             ; $000A := controller slot; SetActorCollisionFlag reads it (absolute scratch word, not the DP)
    LDA #$0000            ; D := $0000: $20-$26, $AA/$AB and $1A/$1E now address the low-RAM scratch words
    TCD 
    LDA $24               ; Park the vertical velocity: $24 goes on the stack and is zeroed, so the horizontal phase sees no vertical motion
    STZ $24
    STZ $AA               ; Clear $AA and $AB (word store): this tick's phase flags
    PHA 
    LDA $0010, X          ; Clear solid-contact bit $0004 in the controller's flags; SetActorCollisionFlag sets it again when a move is blocked
    AND #$FFFB
    STA $0010, X
    LDA $20               ; Horizontal velocity in sub-pixels: zero skips the phase, negative runs west, positive east
    BEQ PlayerMovementTick_AfterHorizontal
    BPL loc_02CFFA
    LDA #$0040            ; Marker: the horizontal phase ran this tick ($AA bit 6, read by the AutoAlign routines)
    TSB $AA
    JSR $&player_move_west.DispatchWestMove
    BRA PlayerMovementTick_AfterHorizontal

; East branch (positive $20): mark that the horizontal phase ran ($AA bit $0040) and run DispatchEastMove.

  loc_02CFFA:
    LDA #$0040
    TSB $AA
    JSR $&player_move_east.DispatchEastMove

; After the horizontal phase: publish the player's pixel X / Y ($22 >> 2, $26 >> 2), clear $20, un-park the vertical velocity into $24 and pick the vertical dispatch.

  PlayerMovementTick_AfterHorizontal:
    REP #$20              ; The dispatchers leave A 8-bit (probe mode)
    LDX $playerActor      ; X := the player actor (not the controller)
    LDA $22               ; Publish the player's pixel position: $22 >> 2 and $26 >> 2 (sub-pixels to pixels) into the player actor's $14 / $16
    LSR 
    LSR 
    STA $0014, X
    LDA $26
    LSR 
    LSR 
    STA $0016, X
    STZ $20
    PLA                   ; Un-park the vertical velocity into $24 (0 if a wall-slide handler cancelled the phase): zero skips, negative north, positive south
    STA $24
    BEQ PlayerMovementTick_Exit
    BPL PlayerMovementTick_SouthStep
    LDA $AA
    BIT #$0800            ; Bit $0800: never set anywhere, so the gate always passes
    BNE PlayerMovementTick_Exit
    JSR $&player_move_ns.DispatchNorthMove
    BRA PlayerMovementTick_Exit

; South branch (positive $24): gate on $AA bit $0400 (never set), then DispatchSouthMove.

  PlayerMovementTick_SouthStep:
    LDA $AA
    BIT #$0400            ; Bit $0400: never set anywhere, so the gate always passes
    BNE PlayerMovementTick_Exit
    JSR $&player_move_south.DispatchSouthMove

; Tick exit: restore X, D and P and return to PlayerMoveController.

  PlayerMovementTick_Exit:
    PLX 
    PLD 
    PLP 
    RTL 
}
---------------------------------------------

; $02 := 16 - (probe pixel Y AND $0F), 1..16: pixels down to the next row line. Used by the north wall handlers.

ComputeYSnapOffset {
    REP #$20
    LDA $1E
    AND #$000F
    ORA #$FFF0            ; OR #$FFF0 gives n - 16; EOR #$FFFF and INC negate it: 16 - n, i.e. 1..16 (16 when flush)
    EOR #$FFFF
    INC 
    STA $02
    RTS 
}

---------------------------------------------
; Unreferenced experiment: a combined Y snap offset in $02 for a wall-like current cell, from the north step and the ComputeYSnapOffset formula. Saves and restores $1A / $1E.

DiagSnapCompute_Unused {
    REP #$20              ; Save the probe coordinates $1A / $1E on the stack (restored on both paths)
    LDA $1A
    PHA 
    LDA $1E
    PHA 
    SEP #$20
    JSR $&tile_collision.ProbeCurrentTL ; Wall path if the current TL cell type is $06, or if X straddles two columns and the cell to the right is $09
    CMP #$06
    BEQ loc_02D277
    JSR $&tile_collision.CheckSubTileAlignX
    BCC loc_02D2A3
    JSR $&tile_collision.MapCellRight
    JSR $&tile_collision.ReadCollisionNibble
    CMP #$09
    BNE loc_02D2A3

; Wall path of DiagSnapCompute_Unused: restore the probe coordinates, then estimate whether the north step crosses a 16-px line.

  loc_02D277:
    REP #$20
    PLA 
    STA $1E
    PLA 
    STA $1A
    STZ $02
    LDA $1E
    PHA 
    LDA $24
    BEQ loc_02D28D
    LSR 
    LSR 
    ORA #$C000            ; Sign-extend: valid only for a NEGATIVE velocity (assumes a north move)

; Negate the pixel step, add it to the saved Y and XOR with the saved Y; bit 4 set means a row line is crossed.

  loc_02D28D:
    EOR #$FFFF
    INC 
    CLC 
    ADC $01, S
    EOR $01, S
    BIT #$0010            ; Bit 4 of (Y XOR Y + step) changed: a 16-px row line lies between
    BEQ loc_02D2A0
    LDA #$0010
    STA $02

; Drop the saved Y and join the final ComputeYSnapOffset addition.

  loc_02D2A0:
    PLA 
    BRA loc_02D2AD

; Non-wall path of DiagSnapCompute_Unused: restore the probe coordinates and start $02 at 0.

  loc_02D2A3:
    REP #$20
    PLA 
    STA $1E
    PLA 
    STA $1A
    STZ $02

; Final step of DiagSnapCompute_Unused: add 16 - ($1E AND $0F) to $02.

  loc_02D2AD:
    LDA $1E
    AND #$000F
    ORA #$FFF0            ; 16 - n: the same formula as ComputeYSnapOffset, added to $02
    EOR #$FFFF
    INC 
    CLC 
    ADC $02
    STA $02
    RTS 
}

---------------------------------------------
; Corner assist for a blocked north step: nudge X by 2 px toward the open column. Carry CLEAR = nudged, carry SET = nothing done. Gates: horizontal phase ran, actor solid mark at X, n = 0. n >= 6 east first (FutureTR below $0E, not $06), n < 9 west (FutureTL below $0E, not $09).

AutoAlignEW_North {
    REP #$20
    LDA $AA
    BIT #$0040            ; Bit $0040: the horizontal phase ran this tick: no nudge
    BNE loc_02D339
    LDA $collisionLayer, X ; Raw collision byte at the map index X left by the last probe; its high nibble is an actor solid mark: no nudge
    AND #$00FF
    BIT #$00F0
    BNE loc_02D339
    LDA $22               ; n = (($22 >> 2) - 8) AND $0F: the offset of the hitbox's left edge inside its 16-px column, kept in $04
    LSR 
    LSR 
    SEC 
    SBC #$0008
    AND #$000F
    STA $04
    BEQ loc_02D339        ; n = 0: already on a column line, nothing to nudge
    CMP #$0006            ; n >= 6: east nudge first (needs the top-right cell type below $0E and not $06); otherwise the west attempt
    BCC loc_02D30D
    JSR $&tile_collision.ProbeFutureTR
    CMP #$000E
    BCS loc_02D30D
    CMP #$0006
    BEQ loc_02D30D
    LDX #$0022            ; Nudge on the word at [$00 + X] with X = $22; the position is first shifted 8 px west (-$20) so the helper tests the LEFT edge
    LDA $00, X
    SEC 
    SBC #$0020
    STA $00, X
    JSR $&NudgeAxisPlus8Clamped ; +8 sub-pixels (2 px east), floored to the $40 line it would cross
    LDA $00, X
    CLC 
    ADC #$0020            ; Undo the shift (+$20); the 2-px nudge stays in $22
    STA $00, X
    CLC                   ; Carry clear: X was nudged east
    RTS 

; West attempt: only for n < 9; FutureTL must be below $0E and not $09; then NudgeAxisMinus8Clamped on the left-edge reference.

  loc_02D30D:
    LDA $04
    CMP #$0009            ; Only n < 9 (1..8) may go west
    BCS loc_02D339
    JSR $&tile_collision.ProbeFutureTL ; West nudge needs the top-left cell type below $0E and not $09
    CMP #$000E
    BCS loc_02D339
    CMP #$0009
    BEQ loc_02D339
    LDX #$0022            ; Same shifted-reference scheme as the east nudge
    LDA $00, X
    SEC 
    SBC #$0020
    STA $00, X
    JSR $&NudgeAxisMinus8Clamped ; -8 sub-pixels (2 px west), clamped back up to the $40 line it would cross
    LDA $00, X
    CLC 
    ADC #$0020
    STA $00, X
    CLC                   ; Carry clear: X was nudged west
    RTS 

; No nudge applied: return carry SET.

  loc_02D339:
    SEC                   ; Carry set: nothing nudged, the caller does the hard Y snap
    RTS 
}

---------------------------------------------
; +8 sub-pixels (2 px toward larger coordinates) on the word at [$00 + X], floored to the $40 line when the step crosses one. Preserves A on the stack only.

NudgeAxisPlus8Clamped {
    LDA $00, X
    PHA 
    CLC 
    ADC #$0008
    STA $00, X
    EOR $01, S            ; Old XOR new: bit 6 set means a $40 line (16 px) was crossed
    BIT #$0040
    BEQ loc_02D352
    LDA $00, X
    AND #$FFC0            ; Crossed: floored to the line so the edge ends flush
    STA $00, X

; Drop the saved old value and return.

  loc_02D352:
    PLA 
    RTS 
}

---------------------------------------------
; -8 sub-pixels (2 px toward smaller coordinates) on the word at [$00 + X]; when the step crosses a $40 line the value is clamped back up to that line.

NudgeAxisMinus8Clamped {
    LDA $00, X
    PHA 
    SEC 
    SBC #$0008
    STA $00, X
    EOR $01, S            ; Old XOR new: bit 6 set means a $40 line was crossed
    BIT #$0040
    BEQ loc_02D374
    LDA $00, X
    BIT #$003F            ; Low six bits already zero: on the line, nothing to clamp
    BEQ loc_02D374
    AND #$FFC0            ; Floor, then add $40: clamp back up to the line that was crossed
    CLC 
    ADC #$0040
    STA $00, X

; Drop the saved old value and return.

  loc_02D374:
    PLA 
    RTS 
}