; COP handlers for direction computation, position branching, map transitions, and camera scroll (Bank $00, 15 handlers).
; 
; SetTilePos converts byte tile coordinates to pixel positions ($14/$16). QueueMapChange writes scene/position/flag data for map transitions with optional save-restore.
; 
; WaitWhileOffscreen yields when actor flag $4000 (off-screen) is set. BranchIfPlayerAt/BranchIfActorAt compare exact pixel coordinates. BranchOnPlayerX/Y perform 3-way branches (left/center/right or above/center/below) based on distance thresholds. BranchNearerAxis branches on the closer axis.
; 
; DirToPlayer/CardinalToPlayer/DirToPlayerFrom compute direction indices (0–7 or 0–3) from the actor to the player. BranchIfDirToPlayer/From branch on computed direction. BranchOnPlayerFacing dispatches on the player's 4-way facing direction.
; 
; Internal: CameraScrollStepLookup reads scroll speed entries from scrollStepTableBase for camera pan handlers.
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
    LDA [$0A]
    INC $0A
    AND #$00FF
    ASL 
    ASL 
    ASL 
    ASL 
    CLC 
    ADC #$0008
    STA $14
    LDA [$0A]
    INC $0A
    AND #$00FF
    ASL 
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
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $sceneNext
    LDA [$0A]
    INC $0A
    INC $0A
    STA $064C
    LDA [$0A]
    INC $0A
    INC $0A
    STA $064E
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0650
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0652
    LDA $0650
    BIT #$0080            ; BIT #$0080 on scene flags: bit 7 triggers save-restore path
    BNE loc_0090AF
    LDA $0A
    STA $02, S
    RTI 

  loc_0090AF:
    AND #$FF7F            ; AND #$FF7F: clear save-game flag after capturing script PC
    STA $0650
    LDA $0A
    SEC 
    SBC #$0008
    STA $sceneSaveData
    STA $0AF4
    LDA $0C
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
    LDA $10
    BIT #$4000            ; BIT #$4000 on $0010: actor off-screen → yield with timer
    BEQ loc_0090E8
    LDA $0A
    DEC 
    DEC 
    STA $00
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $08
    PLA 
    PLA 
    RTL 

  loc_0090E8:
    LDA [$0A]
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
    LDY $playerActor
    BRA loc_009105
}

---------------------------------------------
; COP #29 with one byte (actor list index), two words (X, Y), and one &Code operand. Resolves the actor via ResolveActorIndex then performs the same exact pixel coordinate compare as BranchIfPlayerAt.

BranchIfActorAt {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSR $&cop_handlers_movement.ResolveActorIndex

  loc_009105:
    LDA [$0A]
    INC $0A
    INC $0A
    CMP $0014, Y
    BNE loc_009124
    LDA [$0A]
    INC $0A
    INC $0A
    CMP $0016, Y
    BNE loc_00912A
    LDA [$0A]
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
    LDY $playerActor
    LDA $0014, Y
    LDY #$0004
    SEC 
    SBC $14
    BEQ loc_00915A
    BPL loc_009153
    EOR #$FFFF
    INC 
    CMP [$0A]
    BCC loc_00915A
    LDY #$0002
    BRA loc_00915A

  loc_009153:
    CMP [$0A]
    BCC loc_00915A
    LDY #$0006

  loc_00915A:
    LDA [$0A], Y
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #2B with one word (threshold) and three &Code addresses (above, center, below). Same three-way logic as BranchOnPlayerX but compares vertical player offset on Y.

BranchOnPlayerY {
    TYX 
    LDY $playerActor
    LDA $0016, Y
    LDY #$0004
    SEC 
    SBC $16
    BEQ loc_009184
    BPL loc_00917D
    EOR #$FFFF
    INC 
    CMP [$0A]
    BCC loc_009184
    LDY #$0002
    BRA loc_009184

  loc_00917D:
    CMP [$0A]
    BCC loc_009184
    LDY #$0006

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
    LDA $0014, Y
    SEC 
    SBC $14
    BPL loc_009199
    EOR #$FFFF
    INC 

  loc_009199:
    PHA 
    LDA $0016, Y
    SEC 
    SBC $16
    BPL loc_0091A6
    EOR #$FFFF
    INC 

  loc_0091A6:
    CMP $01, S
    BCC loc_0091AF
    LDY #$0002
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
    LDA $14
    STA $0018
    LDA $16
    STA $001C
    JSR $&cop_handlers_solid.ComputeDirectionToPlayer
    LDA $0A
    STA $02, S
    TYA 
    RTI 
}

---------------------------------------------
; COP #35 with no operands. Returns 0–3 (N/E/S/W) by comparing absolute X and Y deltas to the player and selecting the cardinal axis with the larger magnitude.

CardinalToPlayer {
    TYX 
    LDY #$&code_009230-1
    PHY 
    LDY $playerActor
    LDA $0014, Y
    SEC 
    SBC $14
    BMI loc_009203
    STA $0018
    LDA $0016, Y
    SEC 
    SBC $16
    BMI loc_0091F0
    CMP $0018
    BCC loc_0091FB
    LDY #$0002
    RTS 

  loc_0091F0:
    BPL loc_0091F6
    EOR #$FFFF
    INC 

  loc_0091F6:
    CMP $0018
    BCS loc_0091FF

  loc_0091FB:
    LDY #$0001
    RTS 

  loc_0091FF:
    LDY #$0000
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
    LDY #$0002
    RTS 

  loc_00921D:
    BPL loc_009223
    EOR #$FFFF
    INC 

  loc_009223:
    CMP $0018
    BCS loc_00922C

  loc_009228:
    LDY #$0003
    RTS 

  loc_00922C:
    LDY #$0000
    RTS 
}

code_009230 {
    LDA $0A
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
    BIT #$0080
    BEQ loc_009246
    ORA #$FF00

  loc_009246:
    CLC 
    ADC $14
    STA $0018
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_00925B
    ORA #$FF00

  loc_00925B:
    CLC 
    ADC $16
    STA $001C
    JSR $&cop_handlers_solid.ComputeDirectionToPlayer
    LDA $0A
    STA $02, S
    TYA 
    RTI 
}

---------------------------------------------
; COP #2F with one byte (direction) and one &Code operand. Branches if ComputeDirectionToPlayer from the actor matches the operand direction; otherwise skips the branch address.

BranchIfDirToPlayer {
    TYX 
    LDA $14
    STA $0018
    LDA $16
    STA $001C
    JSR $&cop_handlers_solid.ComputeDirectionToPlayer
    SEP #$20
    CMP [$0A]
    REP #$20
    BEQ loc_009289
    LDA $0A
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
    JSL $@GetPlayerFacingDirection
    BEQ loc_009300
    DEC 
    BEQ loc_009305
    DEC 
    BEQ loc_00930A
    DEC 
    BEQ loc_00930F
    LDA #$0008
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
    LDA [$0A], Y

  loc_009314:
    STA $02, S
    RTI 
}