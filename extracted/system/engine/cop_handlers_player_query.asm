; COP handlers that place an actor, stage map changes and compare the actor's position with the player's (Bank $00; COP #25–#31 and #35).
; 
; SetTilePos puts the actor on a tile. QueueMapChange stages a scene change (sceneNext, spawn X/Y, facing/flags, scroll parameters at $0642–$0652) and can record a revive/save warp point. WaitWhileOffscreen polls the actor's off-screen flag. The query handlers compare the actor's pixel position ($14/$16) with the player's; all deltas are signed 16-bit (player − actor).
; 
; - BranchIfPlayerAt / BranchIfActorAt: exact pixel match.
; - BranchOnPlayerX / BranchOnPlayerY: three-way branch (zero delta or |Δ| below the threshold → centre; otherwise west/east or above/below).
; - BranchNearerAxis: branch on whether |ΔX| or |ΔY| is larger.
; - DirToPlayer / DirToPlayerFrom return the 0–7 direction from ComputeDirectionToPlayer in A; BranchIfDirToPlayer / ...From branch when it equals an operand.
; - CardinalToPlayer returns 0–3 = N/E/S/W for the dominant axis (ties go to the vertical axis).
; - BranchOnPlayerFacing branches on GetPlayerFacingDirection, whose order is 0 = down, 1 = up, 2 = left, 3 = right (not the N/E/S/W order of CardinalToPlayer).
; 
; Every handler exits with RTI after storing the new script PC at $02,S.
---------------------------------------------

?BANK 00

?INCLUDE 'cop_handlers_collision'
?INCLUDE 'cop_handlers_movement'
?INCLUDE 'GetPlayerFacingDirection'

!sceneNext                      0642
!warpDestX                      064C
!warpDestY                      064E
!warpFacing                     0650
!warpScrollParams               0652
!playerActor                    09AA
!sceneSaveData                  0AF0
!sceneSaveDataBank              0AF2
!reviveWarpPtr                  0AF4
!reviveWarpBank                 0AF6

---------------------------------------------

; COP #25 with two byte operands (tile X, tile Y). Converts tile coordinates to pixel positions by shifting each ×16; adds 8 to X for horizontal tile-centering and stores results in actor $14/$16.

SetTilePos {
    TYX 
    LDA [$0A]             ; Read tile X byte from script operand
    INC $0A
    AND #$00FF
    ASL                   ; ASL ×4 = multiply by 16 (tile → pixel, each metatile = 16px)
    ASL 
    ASL 
    ASL 
    CLC 
    ADC #$0008            ; Add 8px horizontal centering offset (sprite midpoint on tile)
    STA $14
    LDA [$0A]             ; Read tile Y byte operand
    INC $0A
    AND #$00FF
    ASL                   ; ASL ×4 = tile Y × 16 → pixel Y position
    ASL 
    ASL 
    ASL 
    STA $16
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #26 with one byte (scene ID), two words (spawn X, Y), one byte (flags) and one word (scroll parameters). Writes sceneNext ($0642), warpDestX/Y ($064C/$064E), warpFacing ($0650, the flags byte) and warpScrollParams ($0652).
; 
; If flags bit 7 is set it is cleared in warpFacing and the address of this operand block (PC − 8) and its bank are stored in sceneSaveData and reviveWarpPtr. The operand block has the layout of a warp record (entry+4 in the warp table), and game_over_sequence reloads from these pointers, so bit 7 marks the scene change as the new revive/save point; nothing resumes at that address as script code.

QueueMapChange {
    TYX 
    LDA [$0A]             ; Read destination scene ID byte operand
    INC $0A
    AND #$00FF
    STA $sceneNext        ; Store destination scene to sceneNext ($0642)
    LDA [$0A]             ; Read destination X pixel position (word operand)
    INC $0A
    INC $0A
    STA $warpDestX        ; Store spawn X to $064C
    LDA [$0A]             ; Read destination Y pixel position (word operand)
    INC $0A
    INC $0A
    STA $warpDestY        ; Store spawn Y to $064E
    LDA [$0A]             ; Read transition flags byte
    INC $0A
    AND #$00FF
    STA $warpFacing       ; Flags byte (bit 7 = save/revive warp) → warpFacing ($0650)
    LDA [$0A]             ; Read extra transition data word
    INC $0A
    INC $0A
    STA $warpScrollParams ; Store extra data to $0652
    LDA $warpFacing
    BIT #$0080            ; Bit 7 = save warp: record this operand block as the revive/save point
    BNE loc_0090AF
    LDA $0A
    STA $02, S
    RTI 

  loc_0090AF:
    AND #$FF7F            ; Bit 7 consumed: clear it so warpFacing holds only the facing value
    STA $warpFacing       ; Clear bit 7 after capturing the save flag
    LDA $0A
    SEC 
    SBC #$0008            ; Rewind $0A by 8 bytes to start of QueueMapChange operands
    STA $sceneSaveData    ; sceneSaveData/reviveWarpPtr = address of this operand block (warp-record layout); game over reloads from it
    STA $reviveWarpPtr
    LDA $0C               ; Load script bank byte to sceneSaveData+2
    STA $sceneSaveDataBank
    STA $reviveWarpBank
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #27 with one byte operand (delay in frames). If actor flag $4000 is set in $10 (off-screen), sets the entry ($00) to this COP instruction (PC − 2), stores the delay in $08 and yields, so the test repeats after the delay; otherwise it skips the operand and continues.

WaitWhileOffscreen {
    TYX 
    LDA $10               ; Check actor status flags for off-screen test
    BIT #$4000            ; Test off-screen flag $4000 — set when actor is outside camera bounds
    BEQ loc_0090E8
    LDA $0A               ; Off-screen: entry ($00) = this COP instruction (PC − 2) so it re-runs after the delay
    DEC 
    DEC 
    STA $00
    LDA [$0A]             ; Read delay timer byte operand
    INC $0A               ; Advance script pointer past delay timer byte
    AND #$00FF
    STA $08               ; Store frame delay to actor $08 timer
    PLA                   ; Pop COP frame and yield via RTL — re-execute next frame
    PLA 
    RTL 

  loc_0090E8:
    LDA [$0A]             ; On-screen: read and skip the delay operand (no yield needed)
    INC $0A
    AND #$00FF
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #28 with two words (X, Y) and one &Code operand. Branches if the player's exact pixel coordinates match the operand position; otherwise skips the branch address.

BranchIfPlayerAt {
    TYX 
    LDY $playerActor      ; Load player actor pointer for coordinate comparison
    BRA loc_009105
}

---------------------------------------------
; COP #29 with one byte (actor list index), two words (X, Y), and one &Code operand. Resolves the actor via ResolveActorIndex then performs the same exact pixel coordinate compare as BranchIfPlayerAt.

BranchIfActorAt {
    TYX 
    LDA [$0A]             ; BranchIfActorAt: resolve 8-bit actor index
    INC $0A
    AND #$00FF
    JSR $&cop_handlers_movement.ResolveActorIndex ; Resolve 8-bit actor index → Y = actor WRAM pointer ($30×idx+$1000)

  loc_009105:
    LDA [$0A]             ; Read X coordinate operand to compare against
    INC $0A
    INC $0A
    CMP $0014, Y          ; Operand X vs target X (the player for BranchIfPlayerAt, the resolved actor for BranchIfActorAt)
    BNE loc_009124        ; X mismatch → skip remaining operands (no branch)
    LDA [$0A]             ; Read Y coordinate
    INC $0A
    INC $0A
    CMP $0016, Y          ; Operand Y vs target Y
    BNE loc_00912A        ; Y mismatch → skip branch address operand
    LDA [$0A]             ; Both match: read branch target &Code operand
    INC $0A
    INC $0A
    STA $02, S
    RTI 

  loc_009124:
    LDA [$0A]
    INC $0A
    INC $0A

  loc_00912A:
    LDA [$0A]
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #2A with one word (threshold) and three &Code addresses (west, center, east). Three-way branch on horizontal player offset: zero delta → center, |ΔX| within threshold → center, beyond threshold → west or east.

BranchOnPlayerX {
    TYX 
    LDY $playerActor      ; Load player actor for X comparison
    LDA $0014, Y          ; Get player X pixel position
    LDY #$0004            ; Default branch index Y=4 (center, operand[2])
    SEC 
    SBC $14               ; deltaX = player.X − actor.X
    BEQ loc_00915A        ; Zero delta → center branch
    BPL loc_009153
    EOR #$FFFF            ; Negate: |deltaX| for absolute comparison
    INC 
    CMP [$0A]             ; Compare |deltaX| against threshold operand
    BCC loc_00915A        ; Below threshold → center branch (player close enough)
    LDY #$0002            ; Above threshold + negative → west branch (Y=2, operand[1])
    BRA loc_00915A

  loc_009153:
    CMP [$0A]
    BCC loc_00915A        ; |ΔX| below the threshold → centre branch (Y=4)
    LDY #$0006            ; Above threshold + positive → east branch (Y=6, operand[3])

  loc_00915A:
    LDA [$0A], Y          ; Indirect load: branch target = operand block[$0A + Y]
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #2B with one word (threshold) and three &Code addresses (above, center, below). Same three-way logic as BranchOnPlayerX but compares vertical player offset on Y.

BranchOnPlayerY {
    TYX 
    LDY $playerActor
    LDA $0016, Y          ; Get player Y pixel position
    LDY #$0004            ; Default Y=4 (center branch)
    SEC 
    SBC $16               ; deltaY = player.Y − actor.Y
    BEQ loc_009184        ; Zero delta → center
    BPL loc_00917D
    EOR #$FFFF
    INC 
    CMP [$0A]             ; Compare |deltaY| against threshold
    BCC loc_009184
    LDY #$0002            ; Above threshold + negative → above branch (Y=2)
    BRA loc_009184

  loc_00917D:
    CMP [$0A]
    BCC loc_009184
    LDY #$0006            ; Above threshold + positive → below branch (Y=6)

  loc_009184:
    LDA [$0A], Y
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #2C with two &Code operands. Compares |ΔX| and |ΔY| to the player: operand[0] when |ΔY| < |ΔX| (horizontal separation dominates), operand[1] when |ΔY| ≥ |ΔX| (vertical dominates or tie).

BranchNearerAxis {
    TYX 
    LDY $playerActor
    LDA $0014, Y          ; Get player X for axis comparison
    SEC 
    SBC $14               ; deltaX = player.X − actor.X
    BPL loc_009199
    EOR #$FFFF
    INC 

  loc_009199:
    PHA                   ; Push |deltaX| for stack comparison
    LDA $0016, Y          ; Get player Y
    SEC 
    SBC $16               ; deltaY = player.Y − actor.Y
    BPL loc_0091A6
    EOR #$FFFF
    INC 

  loc_0091A6:
    CMP $01, S            ; Compare |deltaY| vs |deltaX| on stack
    BCC loc_0091AF        ; |ΔY| < |ΔX| (horizontal separation dominates) → operand[0]
    LDY #$0002            ; |ΔY| ≥ |ΔX| (vertical dominates or tie) → operand[1] (Y=2)
    BRA loc_0091B2

  loc_0091AF:
    LDY #$0000

  loc_0091B2:
    PLA 
    LDA [$0A], Y
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #2D with no operands. Sets reference coordinates from the actor's $14/$16 and returns a 0–7 octant direction in A via ComputeDirectionToPlayer.

DirToPlayer {
    TYX 
    LDA $14               ; Set reference X = actor.X for direction computation
    STA $0018
    LDA $16               ; Set reference Y = actor.Y
    STA $001C
    JSR $&cop_handlers_collision.ComputeDirectionToPlayer ; Compute 0–7 octant direction to player from reference point
    LDA $0A
    STA $02, S
    TYA 
    RTI 
}

---------------------------------------------
; COP #35 with no operands. Returns Y/A = 0 north, 1 east, 2 south, 3 west, picking the axis with the larger |Δ|; ties go to north/south. This is not the order of GetPlayerFacingDirection.
; 
; Uses an RTS trick: the handler pushes CardinalToPlayer_Exit−1 and every exit path is an RTS into CardinalToPlayer_Exit, which stores the script PC and returns Y in A.

CardinalToPlayer {
    TYX 
    LDY #$&CardinalToPlayer_Exit-1 ; Load CardinalToPlayer_Exit−1 for RTS-trick dispatch (return epilogue address)
    PHY 
    LDY $playerActor
    LDA $0014, Y          ; Get player X position
    SEC 
    SBC $14               ; deltaX = player.X − actor.X
    BMI loc_009203        ; Negative deltaX → player is to the left
    STA $0018
    LDA $0016, Y          ; Get player Y position
    SEC 
    SBC $16               ; deltaY = player.Y − actor.Y
    BMI loc_0091F0
    CMP $0018             ; Compare |deltaY| vs |deltaX| — pick dominant axis
    BCC loc_0091FB
    LDY #$0002            ; Y=2 (south): positive deltaY exceeds |deltaX|
    RTS 

  loc_0091F0:
    BPL loc_0091F6
    EOR #$FFFF
    INC 

  loc_0091F6:
    CMP $0018
    BCS loc_0091FF

  loc_0091FB:
    LDY #$0001            ; Y=1 (east): positive deltaX is the dominant axis
    RTS 

  loc_0091FF:
    LDY #$0000            ; Y=0 (north): negative deltaY dominant or equal
    RTS 

  loc_009203:
    BPL loc_009209
    EOR #$FFFF
    INC 

  loc_009209:
    STA $0018
    LDA $0016, Y
    SEC 
    SBC $16
    BMI loc_00921D
    CMP $0018
    BCC loc_009228
    LDY #$0002            ; Y=2 (south): deltaY positive and exceeds |deltaX|
    RTS 

  loc_00921D:
    BPL loc_009223
    EOR #$FFFF
    INC 

  loc_009223:
    CMP $0018
    BCS loc_00922C

  loc_009228:
    LDY #$0003            ; Y=3 (west): negative deltaX is the dominant axis
    RTS 

  loc_00922C:
    LDY #$0000            ; Y=0 (north): deltaY dominant when X is negative
    RTS 
}

---------------------------------------------
; Shared exit of CardinalToPlayer, reached by RTS: stores the script PC ($0A) as the return PC and returns the direction (Y) in A via RTI.

CardinalToPlayer_Exit {
    LDA $0A               ; RTS-trick return epilogue: update COP return PC and pass direction in A
    STA $02, S
    TYA 
    RTI 
}

---------------------------------------------
; COP #2E with two signed byte operands (X, Y pixel offsets). Adds sign-extended offsets to the actor position as the reference point and returns 0–7 direction via ComputeDirectionToPlayer.

DirToPlayerFrom {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080            ; Test sign bit of X byte offset for sign extension
    BEQ loc_009246
    ORA #$FF00

  loc_009246:
    CLC 
    ADC $14               ; Add signed X offset to actor.X as direction reference point
    STA $0018
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080            ; Test sign bit of Y byte offset
    BEQ loc_00925B
    ORA #$FF00

  loc_00925B:
    CLC 
    ADC $16               ; Add signed Y offset to actor.Y as reference
    STA $001C
    JSR $&cop_handlers_collision.ComputeDirectionToPlayer ; Compute 8-way direction from offset reference to player
    LDA $0A
    STA $02, S
    TYA 
    RTI 
}

---------------------------------------------
; COP #2F with one byte (direction) and one &Code operand. Branches if ComputeDirectionToPlayer from the actor matches the operand direction; otherwise skips the branch address.

BranchIfDirToPlayer {
    TYX 
    LDA $14               ; Set reference X from actor position for direction check
    STA $0018
    LDA $16               ; Set reference Y
    STA $001C
    JSR $&cop_handlers_collision.ComputeDirectionToPlayer
    SEP #$20              ; Switch to 8-bit for byte comparison with direction operand
    CMP [$0A]             ; Compare computed direction vs expected direction operand
    REP #$20
    BEQ loc_009289
    LDA $0A               ; Direction mismatch: skip 3 operand bytes (dir + &Code) without branching
    CLC 
    ADC #$0003
    STA $02, S
    RTI 

  loc_009289:
    LDA [$0A]
    INC $0A
    AND #$00FF
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #30 with two signed byte offsets (X, Y), one byte (direction), and one &Code operand. Same as BranchIfDirToPlayer but computes direction from an offset reference point added to the actor position.

BranchIfDirToPlayerFrom {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_0092A9
    ORA #$FF00

  loc_0092A9:
    CLC 
    ADC $14
    STA $0018
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_0092BE
    ORA #$FF00

  loc_0092BE:
    CLC 
    ADC $16
    STA $001C
    JSR $&cop_handlers_collision.ComputeDirectionToPlayer
    SEP #$20
    CMP [$0A]
    REP #$20
    BEQ loc_0092D8
    LDA $0A
    CLC 
    ADC #$0003
    STA $02, S
    RTI 

  loc_0092D8:
    LDA [$0A]
    INC $0A
    AND #$00FF
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #31 with four &Code operands. Calls GetPlayerFacingDirection (0 = down, 1 = up, 2 = left, 3 = right) and branches to operand[facing]. If the player has no facing (carry set, value ≥ 4) the 8 operand bytes are skipped.

BranchOnPlayerFacing {
    TYX 
    JSL $@GetPlayerFacingDirection ; Player facing from GetPlayerFacingDirection: 0 = down, 1 = up, 2 = left, 3 = right
    BEQ loc_009300        ; Facing 0 (down) → operand[0] at Y=0
    DEC 
    BEQ loc_009305        ; Facing 1 (up) → operand[1] at Y=2
    DEC 
    BEQ loc_00930A        ; Facing 2 (left) → operand[2] at Y=4
    DEC 
    BEQ loc_00930F        ; Facing 3 (right) → operand[3] at Y=6
    LDA #$0008            ; Invalid facing (>3): skip all 8 bytes of branch operands
    CLC 
    ADC $0A
    BRA loc_009314

  loc_009300:
    LDY #$0000
    BRA loc_009312

  loc_009305:
    LDY #$0002
    BRA loc_009312

  loc_00930A:
    LDY #$0004
    BRA loc_009312

  loc_00930F:
    LDY #$0006

  loc_009312:
    LDA [$0A], Y          ; Load selected branch target from operand block at index Y

  loc_009314:
    STA $02, S
    RTI 
}