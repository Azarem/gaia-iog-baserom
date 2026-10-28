; Runtime pull / collect interaction handlers (Bank 00): three small actor scripts spawned with SpawnAfterMarked as children of a gem or a movable solid (collect_handler_gem, push_handler_solid, push_handler_forceball).
; 
; The child's $04 (prevActorLink) is the actor it was marked after, i.e. the object being moved (the 'parent'). The handler reads the player position ($0014 / $0016 of playerActor) and edits the parent's posX / posY ($14 / $16). Its own $14 / $16 start as a copy of the parent's (CopyActorState) and are used as the reference position for every distance test.
; 
; === SHARED STRUCTURE ===
; 
; 1. SetSavedPtr( &self ) keeps the idle entry in retPtr1 ($7F0004). RestoreSavedPtr later resumes there (and clears retPtr1), which re-arms the handler. Every 'Restore' label below is that exit.
; 2. SetEntryHereAndYield + BranchIfPressed( #$0031 ): bit 0 of the mask selects joypadRaw, and $0030 is the L / R shoulder pair (the guard / channel button; player_character BlockStopToIdle tests the same $0030 for 'L/R released'). Not held: RTL, poll again next frame.
; 3. BranchIfPlayerNear( #0F ): radius 15 tiles, a square |dx| and |dy| < 241 px. A coarse gate only.
; 4. BranchOnPlayerX( #$000F, ... ): the engine handler (cop_handlers_player_query) loads operand slot +2 when the player is more than 15 px WEST of the actor, +6 when more than 15 px EAST and +4 when within 15 px (including 0). The slot +4 operand is therefore 'player in the same column', and in this file it leads to the block that works on the Y axis ($0016, posY). BranchOnPlayerY does the same for the row and leads to the blocks that work on posX ($0014).
;    (docs/cop/families/player_query.md and the copdef label the three operands West / East / Here, but the handler's order is West / Here / East; see OQ-I037-3.)
; 5. Each axis block computes d = player - own position. d < 0 means the player is above (Y blocks) or west of (X blocks) the object. |d| is needed, then GetPlayerFacingDirection must report that the player faces the object (codes 0 down, 1 up, 2 left, 3 right), then the object is moved ONE direction: toward the player. These handlers therefore pull the object to the player; the 'push' in the old names and header was a guess.
; 6. The label pairs are named after the wrong axis: *AlignWest / *MoveWest and *AlignEast / *MoveEast are the vertical blocks (player above / below), *AlignNorth / *MoveNorth and *AlignSouth / *MoveSouth are the horizontal ones (player west / east). Each block's second BPL after the first BPL is dead (N is still set), so the abs() always runs for d < 0.
; 
; === HANDLERS ===
; 
; collect_handler_gem: no clearance test and no collision painting. Step count = |d| / 2 (kept in orbitAngle, $7F0010,X). After the first facing test it SetEntryHere's, so the following frames skip the button / facing tests and move the parent 2 px per frame (parent posY / posX -/+ 2, own copy updated too) until the count reaches zero, then restore idle. The old header said it nudges the player; it moves the parent (the gem) and only reads the player.
; push_handler_solid: needs |d| >= $20 (32 px), BranchIfSolidOffset( dx, dy ) one tile toward the player clear (any lower-nibble bit set = blocked), ClearSolidHere, own pos -/+ $10, MarkSolidHere (collision moves at once), SFX $2C, then parent $12 bit $0010 is set (old state kept in $24) while LoopStart( $10 ) slides the parent 1 px per pass (16 passes = one tile), then the bit is restored. $12 bit $0010 is damage / stagger immunity in combat_collision (the wram map calls it push-in-progress). The check state skips a frame when the parent's $10 bit $0080 (victim iframe flag) is set and $12 bit $0010 is clear.
; push_handler_forceball: same distance and facing tests, but additionally the player's sprite index ($28) must be $3A (player above the ball), $3B (below), $3D (west) or $3C (east), the poses that match down / up / left / right. It uses NudgePosition( dx, dy ) on its own position instead of Clear / MarkSolidHere, and while the button is not held it copies the parent's posX / posY every frame.
; 
; Spawn sites (SpawnAfterMarked): collect_handler_gem - EnemyDropSystem (3), field_reveal_object, ec0B_cell (prison cell); push_handler_solid - gw82_archer (2), ir26_statue, ir20_statue, ir1F_stone_lord, ir1F_stone_guard, ec0E_statue, sc02_seth, sg51_statue, sg4D_knight_armor (2); push_handler_forceball - mu60_force_ball.
; UNVERIFIED-RUNTIME: that the object really moves toward the player in play and which in-game action the L / R + facing pose is.
---------------------------------------------

?INCLUDE 'GetPlayerFacingDirection'

!playerActor                    09AA
!orbitAngle                     7F0010

---------------------------------------------

; Idle loop for a collectable gem: arm, poll L / R, gate on 15 tiles, then the same-column / same-row dispatch (see the block note).

collect_handler_gem {
    COP [SetSavedPtr] ( &collect_handler_gem ) ; Save the idle entry (&collect_handler_gem) in retPtr1; RestoreSavedPtr later resumes here to re-arm
    COP [SetEntryHereAndYield]
    COP [BranchIfPressed] ( #$0031, &CollectGemOnButton ) ; Mask $0031: bit 0 = test joypadRaw, $0030 = L or R shoulder; not held -> RTL and poll again next frame

  CollectGemIdleRtl:
    RTL 
}

CollectGemOnButton {
    COP [BranchIfPlayerNear] ( #0F, &CollectGemBranchOnX ) ; Radius $0F = 15 tiles (|dx| and |dy| < 241 px): coarse gate before the axis tests
    RTL 
}

CollectGemBranchOnX {
    COP [BranchOnPlayerX] ( #$000F, &CollectGemBranchOnY, &CollectGemAlignPlayerNorth, &CollectGemBranchOnY ) ; Slots: +2 player >15 px west, +4 within 15 px (same column), +6 >15 px east; slot +4 = vertical block
}

---------------------------------------------
; Same-column block (player above or below). d = player posY - own posY. d < 0: player above, so the facing code must be 0 (down); the gem then moves up 2 px per frame.

CollectGemAlignPlayerNorth {
    LDY $playerActor      ; Same column: use the Y axis. d = player posY ($0016) - own posY ($16); negative = player above the gem
    LDA $0016, Y
    SEC 
    SBC $16
    BPL CollectGemAlignPlayerSouth ; d >= 0 (player at or below the gem): south block
    BPL CollectGemNudgePlayerNorthHalf ; Dead branch: N is still set here, so this is never taken and the abs() below always runs
    EOR #$FFFF
    INC 

; After abs Y delta halved into orbitAngle: requires facing down, SetEntryHere, moves linked gem posY up 2 px per frame until the counter expires, then restores.

  CollectGemNudgePlayerNorthHalf:
    LSR                   ; Step count = |d| / 2 (2-px steps), kept in orbitAngle ($7F0010,X)
    STA $orbitAngle, X
    JSL $@GetPlayerFacingDirection ; Facing codes: 0 down, 1 up, 2 left, 3 right; must be 0 (player above, looking down at the gem)
    CMP #$0000
    BNE CollectGemRestorePlayerNorth
    COP [SetEntryHere]    ; Resume point: later frames skip the button and facing tests and keep nudging until the count runs out
    LDY $04               ; $04 = prevActorLink = the gem this handler was marked after; it is the actor that moves
    LDA $0016, Y
    SEC 
    SBC #$0002            ; Gem posY -= 2 (up, toward the player); the next STA also mirrors it into own $16
    STA $0016, Y
    STA $16
    LDA $orbitAngle, X
    BEQ CollectGemRestorePlayerNorth
    DEC 
    STA $orbitAngle, X
    BEQ CollectGemRestorePlayerNorth ; Count exhausted: back to idle
    RTL 

; RestoreSavedPtr when north-side gem alignment fails or the nudge step count in orbitAngle reaches zero.

  CollectGemRestorePlayerNorth:
    COP [RestoreSavedPtr] ; RestoreSavedPtr resumes at the saved idle entry (or yields if none); the code below is not reached from here

; d >= 0: player at or below the gem; facing must be 1 (up); the gem moves down 2 px per frame.

  CollectGemAlignPlayerSouth:
    LSR                   ; South block (player below the gem): same steps with facing 1 (up) and gem posY += 2
    STA $orbitAngle, X
    JSL $@GetPlayerFacingDirection
    CMP #$0001
    BNE CollectGemRestorePlayerSouth
    COP [SetEntryHere]
    LDY $04
    LDA $0016, Y
    CLC 
    ADC #$0002
    STA $0016, Y
    STA $16
    LDA $orbitAngle, X
    BEQ CollectGemRestorePlayerSouth
    DEC 
    STA $orbitAngle, X
    BEQ CollectGemRestorePlayerSouth
    RTL 

; RestoreSavedPtr for the south-side gem nudge path.

  CollectGemRestorePlayerSouth:
    COP [RestoreSavedPtr]
}

CollectGemBranchOnY {
    COP [BranchOnPlayerY] ( #$000F, &CollectGemIdleRtl, &CollectGemAlignPlayerWest, &CollectGemIdleRtl ) ; Not in the same column: within 15 px on Y (slot +4) takes the horizontal block, else idle
}

---------------------------------------------
; Same-row block (player west or east). d = player posX - own posX. d < 0: player west, facing must be 3 (right); the gem moves west 2 px per frame.

CollectGemAlignPlayerWest {
    LDY $playerActor      ; Same row: d = player posX ($0014) - own posX ($14); negative = player west, facing 3 (right), gem posX -= 2
    LDA $0014, Y
    SEC 
    SBC $14
    BPL CollectGemAlignPlayerEast
    BPL CollectGemNudgePlayerWestHalf
    EOR #$FFFF
    INC 

; West gem nudge: facing right, gem posX minus 2 per frame with the same orbitAngle countdown.

  CollectGemNudgePlayerWestHalf:
    LSR 
    STA $orbitAngle, X
    JSL $@GetPlayerFacingDirection
    CMP #$0003
    BNE CollectGemRestorePlayerWest
    COP [SetEntryHere]
    LDY $04
    LDA $0014, Y
    SEC 
    SBC #$0002
    STA $0014, Y
    STA $14
    LDA $orbitAngle, X
    BEQ CollectGemRestorePlayerWest
    DEC 
    STA $orbitAngle, X
    BEQ CollectGemRestorePlayerWest
    RTL 

; RestoreSavedPtr for the west-side gem nudge path.

  CollectGemRestorePlayerWest:
    COP [RestoreSavedPtr]

; d >= 0: player east of the gem; facing must be 2 (left); the gem moves east 2 px per frame.

  CollectGemAlignPlayerEast:
    LSR                   ; East block: player east of the gem, facing 2 (left), gem posX += 2
    STA $orbitAngle, X
    JSL $@GetPlayerFacingDirection
    CMP #$0002
    BNE CollectGemRestorePlayerEast
    COP [SetEntryHere]
    LDY $04
    LDA $0014, Y
    CLC 
    ADC #$0002
    STA $0014, Y
    STA $14
    LDA $orbitAngle, X
    BEQ CollectGemRestorePlayerEast
    DEC 
    STA $orbitAngle, X
    BEQ CollectGemRestorePlayerEast
    RTL 

; RestoreSavedPtr for the east-side gem nudge path.

  CollectGemRestorePlayerEast:
    COP [RestoreSavedPtr]

; Idle loop for a pullable solid: same arm / poll / gate preamble as the gem handler.

  push_handler_solid:
    COP [SetSavedPtr] ( &push_handler_solid ) ; Same preamble as the gem handler: mask $0031 = L / R shoulder (not A, which is $0080); gate radius $0F tiles
    COP [SetEntryHereAndYield]
    COP [BranchIfPressed] ( #$0031, &PushSolidOnButton )

  PushSolidIdleRtl:
    RTL 
}

PushSolidOnButton {
    COP [BranchIfPlayerNear] ( #0F, &PushSolidCheckState )
    RTL 
}

---------------------------------------------
; Skips this frame (RTL) while the parent has $10 bit $0080 (iframe-active per combat_collision) and does not carry $12 bit $0010.

PushSolidCheckState {
    LDY $04               ; Parent = actor at $04. If its $10 bit $0080 (iframe flag) is set and its $12 bit $0010 is clear, skip this frame
    LDA $0010, Y
    BIT #$0080
    BEQ PushSolidBranchOnX
    LDA $0012, Y
    BIT #$0010
    BNE PushSolidBranchOnX
    NOP                   ; NOP padding, no effect
    NOP 
    NOP 
    RTL 

  PushSolidBranchOnX:
    COP [BranchOnPlayerX] ( #$000F, &PushSolidBranchOnY, &PushSolidMovePlayerNorth, &PushSolidBranchOnY ) ; Slot +4 (|dx| <= $0F, same column) -> PushSolidMovePlayerNorth, which is the vertical block; +2 / +6 go to the Y test
}

---------------------------------------------
; Same-column block (player above or below the solid): needs |posY delta| >= $20, facing 0 (down), tile one row up free; the solid moves up one tile.

PushSolidMovePlayerNorth {
    LDY $playerActor      ; Vertical block: d = player posY - own posY (negative = above). Needs |d| >= $20, facing 0 (down), tile one row up free
    LDA $0016, Y
    SEC 
    SBC $16
    BPL PushSolidMovePlayerSouth ; d >= 0 (player below): south half at PushSolidMovePlayerSouth
    BPL PushSolidDistPlayerNorth ; Dead branch: N is still set here, so the abs() below always runs
    EOR #$FFFF
    INC 

; Distance gate in the north-side solid pull path after abs Y delta: compares to $20 and branches to PushSolidRestorePlayerNorth when the player is too close; otherwise checks facing and collision.

  PushSolidDistPlayerNorth:
    CMP #$0020            ; Player must be at least 32 px away; the object stops pulling once it is closer
    BCC PushSolidRestorePlayerNorth
    JSL $@GetPlayerFacingDirection
    CMP #$0000
    BNE PushSolidRestorePlayerNorth
    COP [BranchIfSolidOffset] ( #00, #FF, &PushSolidRestorePlayerNorth ) ; Tile (dx 0, dy -1) from the object must be free (no lower-nibble type bit), else restore idle
    COP [ClearSolidHere]  ; Remove the object's collision at the old position
    LDA $16
    SEC 
    SBC #$0010            ; Own posY -= $10 (one tile toward the player); MarkSolidHere then paints collision at the destination at once
    STA $16
    COP [MarkSolidHere]
    COP [PlaySoundCh1] ( #2C )
    JSR $&PushSolidSetPushingFlag ; Parent $12 bit $0010 on for the slide (immune per combat_collision); old bit saved in $24
    COP [LoopStart] ( #10 ) ; 16 passes x 1 px: the parent's sprite slides one tile toward the player (assumes LoopEnd yields per pass)
    LDY $04
    LDA $0016, Y
    DEC 
    STA $0016, Y
    COP [LoopEnd]
    JSR $&PushSolidClearPushingFlag
}

---------------------------------------------
; Idle restore for the north-side solid pull path: COP RestoreSavedPtr only.

PushSolidRestorePlayerNorth {
    COP [RestoreSavedPtr]

; Player below the solid: facing 1 (up), tile one row down free; the solid moves down one tile.

  PushSolidMovePlayerSouth:
    CMP #$0020            ; South half: player below the solid, same checks with facing 1 (up), tile (0,+1), own posY += $10
    BCC PushSolidRestorePlayerSouth
    JSL $@GetPlayerFacingDirection
    CMP #$0001
    BNE PushSolidRestorePlayerSouth
    COP [BranchIfSolidOffset] ( #00, #01, &PushSolidRestorePlayerSouth )
    COP [ClearSolidHere]
    LDA $16
    CLC 
    ADC #$0010
    STA $16
    COP [MarkSolidHere]
    COP [PlaySoundCh1] ( #2C )
    JSR $&PushSolidSetPushingFlag
    COP [LoopStart] ( #10 )
    LDY $04
    LDA $0016, Y
    INC 
    STA $0016, Y
    COP [LoopEnd]
    JSR $&PushSolidClearPushingFlag
}

---------------------------------------------
; RestoreSavedPtr exit for the south-side solid pull.

PushSolidRestorePlayerSouth {
    COP [RestoreSavedPtr]
}

PushSolidBranchOnY {
    COP [BranchOnPlayerY] ( #$000F, &PushSolidIdleRtl, &PushSolidMovePlayerWest, &PushSolidIdleRtl ) ; Within 15 px on Y (slot +4): horizontal block, else idle
}

---------------------------------------------
; Same-row block (player west or east): needs |posX delta| >= $20, facing 3 (right), tile one column west free; the solid moves west one tile.

PushSolidMovePlayerWest {
    LDY $playerActor      ; Horizontal block: d = player posX - own posX (negative = west); facing 3 (right), tile (-1,0), own posX -= $10
    LDA $0014, Y
    SEC 
    SBC $14
    BPL PushSolidMovePlayerEast ; d >= 0 (player east): east half at PushSolidMovePlayerEast
    BPL PushSolidDistPlayerWest ; Dead branch: N is still set here, so the abs() below always runs
    EOR #$FFFF
    INC 

; Distance gate in the west-side solid pull path after abs X delta: same $20 minimum before facing and tile tests.

  PushSolidDistPlayerWest:
    CMP #$0020
    BCC PushSolidRestorePlayerWest
    JSL $@GetPlayerFacingDirection
    CMP #$0003
    BNE PushSolidRestorePlayerWest
    COP [BranchIfSolidOffset] ( #FF, #00, &PushSolidRestorePlayerWest )
    COP [ClearSolidHere]
    LDA $14
    SEC 
    SBC #$0010
    STA $14
    COP [MarkSolidHere]
    COP [PlaySoundCh1] ( #2C )
    JSR $&PushSolidSetPushingFlag
    COP [LoopStart] ( #10 )
    LDY $04
    LDA $0014, Y
    DEC 
    STA $0014, Y
    COP [LoopEnd]
    JSR $&PushSolidClearPushingFlag
}

---------------------------------------------
; RestoreSavedPtr exit for the west-side solid pull.

PushSolidRestorePlayerWest {
    COP [RestoreSavedPtr]

; Player east of the solid: facing 2 (left), tile one column east free; the solid moves east one tile.

  PushSolidMovePlayerEast:
    CMP #$0020            ; East half: player east of the solid, facing 2 (left), tile (+1,0), own posX += $10
    BCC PushSolidRestorePlayerEast
    JSL $@GetPlayerFacingDirection
    CMP #$0002
    BNE PushSolidRestorePlayerEast
    COP [BranchIfSolidOffset] ( #01, #00, &PushSolidRestorePlayerEast )
    COP [ClearSolidHere]
    LDA $14
    CLC 
    ADC #$0010
    STA $14
    COP [MarkSolidHere]
    COP [PlaySoundCh1] ( #2C )
    JSR $&PushSolidSetPushingFlag
    COP [LoopStart] ( #10 )
    LDY $04
    LDA $0014, Y
    INC 
    STA $0014, Y
    COP [LoopEnd]
    JSR $&PushSolidClearPushingFlag
}

---------------------------------------------
; RestoreSavedPtr exit for the east-side solid pull.

PushSolidRestorePlayerEast {
    COP [RestoreSavedPtr]
}

---------------------------------------------
; Parent $12 |= $0010 for the slide. The previous value of that bit goes to $24 (this handler's scratch); returns with RTS.

PushSolidSetPushingFlag {
    LDY $04               ; Parent $12 |= $0010 for the slide; the previous bit is kept in $24 (own scratch)
    LDA $0012, Y
    PHA 
    ORA #$0010
    STA $0012, Y
    PLA 
    AND #$0010
    STA $24
    RTS 
}

---------------------------------------------
; Parent $12 = ($12 and $FFEF) or the saved bit in $24, i.e. restore the state from before the slide.

PushSolidClearPushingFlag {
    LDY $04               ; Restore the parent's $12 bit $0010 from $24 (clear it, then OR the saved bit)
    LDA $0012, Y
    AND #$FFEF
    ORA $24
    STA $0012, Y
    RTS 
}

---------------------------------------------
; Force-ball variant: also needs the matching player pose ($28 = $3A..$3D) and mirrors the parent position while idle.

push_handler_forceball {
    COP [SetSavedPtr] ( &push_handler_forceball ) ; Same preamble; also needs the player sprite index ($28) to be the $3A-$3D pose that matches the side
    COP [SetEntryHereAndYield]
    COP [BranchIfPressed] ( #$0031, &PushForceballOnButton )
    LDY $04               ; Idle (button not held): mirror the parent's posX / posY into this handler every frame
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    STA $16

  PushForceballIdleRtl:
    RTL 
}

PushForceballOnButton {
    COP [BranchIfPlayerNear] ( #0F, &PushForceballBranchOnX )
    RTL 
}

PushForceballBranchOnX {
    COP [BranchOnPlayerX] ( #$000F, &PushForceballBranchOnY, &PushForceballMovePlayerNorth, &PushForceballBranchOnY )
}

---------------------------------------------
; Forceball pull when the player is above: distance and sprIdx $3A checks, facing down, NudgePosition (0,-$10), sound $2C, 16-step parent Y slide; south/west/east halves mirror with other facings and offsets.

PushForceballMovePlayerNorth {
    LDY $playerActor
    LDA $0016, Y
    SEC 
    SBC $16
    BPL PushForceballMovePlayerSouth
    BPL PushForceballDistPlayerNorth
    EOR #$FFFF
    INC 

; Minimum-distance check ($20) in PushForceballMovePlayerNorth before sprite and facing tests.

  PushForceballDistPlayerNorth:
    CMP #$0020
    BCC PushForceballRestorePlayerNorth
    LDA $0028, Y          ; Player sprIdx: $3A when above the ball, $3B below, $3D west of it, $3C east of it
    CMP #$003A
    BNE PushForceballRestorePlayerNorth
    JSL $@GetPlayerFacingDirection
    CMP #$0000
    BNE PushForceballRestorePlayerNorth
    COP [BranchIfSolidOffset] ( #00, #FF, &PushForceballRestorePlayerNorth )
    COP [NudgePosition] ( #00, #F0 ) ; Own posY -= $10 (collision is not repainted here, unlike push_handler_solid)
    COP [PlaySoundCh1] ( #2C )
    COP [LoopStart] ( #10 ) ; 16 passes x 1 px: the parent slides one tile toward the player
    LDY $04
    LDA $0016, Y
    DEC 
    STA $0016, Y
    COP [LoopEnd]
}

---------------------------------------------
; RestoreSavedPtr exit for the north-side forceball pull.

PushForceballRestorePlayerNorth {
    COP [RestoreSavedPtr]

; South half of forceball vertical pull: sprIdx $3B, facing up, nudge Y+$10, slide loop toward player.

  PushForceballMovePlayerSouth:
    CMP #$0020
    BCC PushForceballRestorePlayerSouth
    LDA $0028, Y
    CMP #$003B
    BNE PushForceballRestorePlayerSouth
    JSL $@GetPlayerFacingDirection
    CMP #$0001
    BNE PushForceballRestorePlayerSouth
    COP [BranchIfSolidOffset] ( #00, #01, &PushForceballRestorePlayerSouth )
    COP [NudgePosition] ( #00, #10 )
    COP [PlaySoundCh1] ( #2C )
    COP [LoopStart] ( #10 )
    LDY $04
    LDA $0016, Y
    INC 
    STA $0016, Y
    COP [LoopEnd]
}

---------------------------------------------
; RestoreSavedPtr for south forceball pull failures or completion.

PushForceballRestorePlayerSouth {
    COP [RestoreSavedPtr]
}

PushForceballBranchOnY {
    COP [BranchOnPlayerY] ( #$000F, &PushForceballIdleRtl, &PushForceballMovePlayerWest, &PushForceballIdleRtl )
}

---------------------------------------------
; West-side forceball pull with sprIdx $3D, facing right, X nudge -$10.

PushForceballMovePlayerWest {
    LDY $playerActor
    LDA $0014, Y
    SEC 
    SBC $14
    BPL PushForceballMovePlayerEast
    BPL PushForceballDistPlayerWest
    EOR #$FFFF
    INC 

; Minimum-distance check ($20) in PushForceballMovePlayerWest before sprite and facing tests.

  PushForceballDistPlayerWest:
    CMP #$0020
    BCC PushForceballRestorePlayerWest
    LDA $0028, Y
    CMP #$003D
    BNE PushForceballRestorePlayerWest
    JSL $@GetPlayerFacingDirection
    CMP #$0003
    BNE PushForceballRestorePlayerWest
    COP [BranchIfSolidOffset] ( #FF, #00, &PushForceballRestorePlayerWest )
    COP [NudgePosition] ( #F0, #00 )
    COP [PlaySoundCh1] ( #2C )
    COP [LoopStart] ( #10 )
    LDY $04
    LDA $0014, Y
    DEC 
    STA $0014, Y
    COP [LoopEnd]
}

---------------------------------------------
; RestoreSavedPtr for west forceball pull.

PushForceballRestorePlayerWest {
    COP [RestoreSavedPtr]

; East-side forceball pull with sprIdx $3C, facing left, X nudge +$10.

  PushForceballMovePlayerEast:
    CMP #$0020
    BCC PushForceballRestorePlayerEast
    LDA $0028, Y
    CMP #$003C
    BNE PushForceballRestorePlayerEast
    JSL $@GetPlayerFacingDirection
    CMP #$0002
    BNE PushForceballRestorePlayerEast
    COP [BranchIfSolidOffset] ( #01, #00, &PushForceballRestorePlayerEast )
    COP [NudgePosition] ( #10, #00 )
    COP [PlaySoundCh1] ( #2C )
    COP [LoopStart] ( #10 )
    LDY $04
    LDA $0014, Y
    INC 
    STA $0014, Y
    COP [LoopEnd]
}

---------------------------------------------
; RestoreSavedPtr for east forceball pull.

PushForceballRestorePlayerEast {
    COP [RestoreSavedPtr]
}