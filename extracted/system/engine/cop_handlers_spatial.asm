; COP handlers for direction computation, position branching, and map transitions (Bank $00, 14 COP handlers + 1 internal stub).
; 
; SetTilePos converts byte tile coordinates to pixel positions ($14/$16). QueueMapChange writes scene/position/flag data for map transitions with optional save-restore.
; 
; WaitWhileOffscreen yields when actor flag $4000 (off-screen) is set. BranchIfPlayerAt/BranchIfActorAt compare exact pixel coordinates. BranchOnPlayerX/Y perform 3-way branches (left/center/right or above/center/below) based on distance thresholds. BranchNearerAxis branches on the closer axis.
; 
; DirToPlayer/CardinalToPlayer/DirToPlayerFrom compute direction indices (0–7 or 0–3) from the actor to the player. BranchIfDirToPlayer/From branch on computed direction. BranchOnPlayerFacing dispatches on the player's 4-way facing direction.
; 
; Internal: code_009230 is the return epilogue for CardinalToPlayer's RTS-trick dispatch.
---------------------------------------------

?BANK 00

?INCLUDE 'cop_handlers_movement'
?INCLUDE 'cop_handlers_solid'
?INCLUDE 'GetPlayerFacingDirection'

!sceneNext                      0642
!playerActor                    09AA
!sceneSaveData                  0AF0

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
; COP #26 with one byte (scene ID), two words (X, Y position), one byte (flags), and one word (extra data). Writes map-transition staging data to $0642–$0652; if flags bit 7 is set, also saves the script PC and bank to sceneSaveData for post-transition restoration.

QueueMapChange {
    TYX 
    LDA [$0A]             ; Read destination scene ID byte operand
    INC $0A
    AND #$00FF
    STA $sceneNext        ; Store destination scene to sceneNext ($0642)
    LDA [$0A]             ; Read destination X pixel position (word operand)
    INC $0A
    INC $0A
    STA $064C             ; Store spawn X to $064C
    LDA [$0A]             ; Read destination Y pixel position (word operand)
    INC $0A
    INC $0A
    STA $064E             ; Store spawn Y to $064E
    LDA [$0A]             ; Read transition flags byte
    INC $0A
    AND #$00FF
    STA $0650             ; Store flags to $0650
    LDA [$0A]             ; Read extra transition data word
    INC $0A
    INC $0A
    STA $0652             ; Store extra data to $0652
    LDA $0650
    BIT #$0080            ; Test bit 7 = save-restore flag (resume script after map change)
    BNE loc_0090AF
    LDA $0A
    STA $02, S
    RTI 

  loc_0090AF:
    AND #$FF7F            ; Clear save-game flag after capturing script PC
    STA $0650             ; Clear bit 7 after capturing the save flag
    LDA $0A
    SEC 
    SBC #$0008            ; Rewind $0A by 8 bytes to start of QueueMapChange operands
    STA $sceneSaveData    ; Save rewound script PC to sceneSaveData for post-transition resume
    STA $0AF4
    LDA $0C               ; Load script bank byte to sceneSaveData+2
    STA $0AF2
    STA $0AF6
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #27 with one byte operand (frame delay). If actor flag $4000 (off-screen) is set on $10, rewinds the script pointer and yields RTL with the delay timer; otherwise skips the operand and continues.

WaitWhileOffscreen {
    TYX 
    LDA $10               ; Check actor status flags for off-screen test
    BIT #$4000            ; Test off-screen flag $4000 — set when actor is outside camera bounds
    BEQ loc_0090E8
    LDA $0A               ; Off-screen: rewind script pointer to re-enter this handler next frame
    DEC 
    DEC 
    STA $00
    LDA [$0A]             ; Read delay timer byte operand
    INC $0A               ; Read delay timer byte
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
    CMP $0014, Y          ; Compare operand X vs player X — exact match required
    BNE loc_009124        ; X mismatch → skip remaining operands (no branch)
    LDA [$0A]             ; Read Y coordinate
    INC $0A
    INC $0A
    CMP $0016, Y          ; Compare operand Y vs player Y
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
    BCC loc_00915A        ; Above + positive -> east branch (Y=6)
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
; COP #2C with two &Code operands. Compares absolute |ΔX| vs |ΔY| to the player; branches to operand[0] if Y is the nearer axis, operand[1] if X is nearer or equal.

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
    BCC loc_0091AF        ; |deltaY| < |deltaX| → Y is nearer axis (operand[0], Y=0)
    LDY #$0002            ; |deltaY| ≥ |deltaX| → X is nearer axis (operand[1], Y=2)
    BRA loc_0091B2        ; |deltaY| >= |deltaX| -> X axis nearer (Y=2)

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
    JSR $&cop_handlers_solid.ComputeDirectionToPlayer ; Compute 0–7 octant direction to player from reference point
    LDA $0A
    STA $02, S
    TYA 
    RTI 
}

---------------------------------------------
; COP #35 with no operands. Returns 0–3 (N/E/S/W) by comparing absolute X and Y deltas to the player and selecting the cardinal axis with the larger magnitude.

CardinalToPlayer {
    TYX 
    LDY #$&code_009230-1  ; Push code_009230−1 for RTS-trick dispatch (return epilogue address)
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

code_009230 {
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
    JSR $&cop_handlers_solid.ComputeDirectionToPlayer ; Compute 8-way direction from offset reference to player
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
    JSR $&cop_handlers_solid.ComputeDirectionToPlayer
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
    JSR $&cop_handlers_solid.ComputeDirectionToPlayer
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
; COP #31 with four &Code operands. Calls GetPlayerFacingDirection and dispatches to one of four branch targets for player facing values 0–3.

BranchOnPlayerFacing {
    TYX 
    JSL $@GetPlayerFacingDirection ; Get player's 4-way facing (0=N, 1=E, 2=S, 3=W)
    BEQ loc_009300        ; Facing 0 (North) → operand[0] at Y=0
    DEC 
    BEQ loc_009305        ; Facing 1 (East) → operand[1] at Y=2
    DEC 
    BEQ loc_00930A        ; Facing 2 (South) → operand[2] at Y=4
    DEC 
    BEQ loc_00930F        ; Facing 3 (West) → operand[3] at Y=6
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