; COP handlers for player-specific sprite staging, body-form switching, and wall-collision animation (Bank $00, 11 COP handlers).
; 
; SetPlayerSpriteDirect writes a body sprite index directly to spriteset/bank fields and sets playerFlags bit $8000. StagePlayerSpr and its axis variants (X/Y/XY) call SetActorBody to apply the current characterForm's body_table entry before staging. RunPlayerAnim runs a single animation pass via UpdateActorAnimation.
; 
; StagePlayerSprWall adds a wall-type operand stored in playerWallType for wall-slide detection. StagePlayerSprFromDP reads the animation index from DP $0000 instead of a script operand.
; 
; WallAnimHere/North/South check joypad state, grid alignment, and tile collision type against playerWallType before advancing animation. If the tile is blocked ($F0) or type $0F, they set actor flag $0004 (wall contact). These handlers yield via RTL when animation is incomplete.
---------------------------------------------

?BANK 00

?INCLUDE 'actor_pool'
?INCLUDE 'body_table'
?INCLUDE 'cop_handlers_solid'
?INCLUDE 'sprite_composition'

!joypadCurrent                  0656
!playerFlags                    09AE
!playerWallType                 09B0
!spritesetPtr                   7F0006
!animScratch2                   7F000E
!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

; COP #8E with one byte operand (body index). Multiplies the index by six to index 6-byte body_table entries, writes spritesetPtr and bank byte ($7F0008), caches the index in animScratch2, and sets playerFlags bit $8000.

SetPlayerSpriteDirect {
    TYX 
    SEP #$20              ; 8-bit mode for byte operand read and body_table index math
    LDA [$0A]             ; Read body sprite index byte from script
    STA $0AC8             ; Cache raw index in $0AC8 for external reference
    ASL                   ; Index ×6: ASL(×2) + ADC self(×3) + ASL(×6) — 6 bytes per body_table entry
    CLC 
    ADC [$0A]
    ASL 
    REP #$20
    AND #$00FF
    STA $animScratch2, X  ; Cache computed table offset in animScratch2
    TAY 
    LDA $&body_table, Y   ; Load spriteset pointer from body_table[index]
    STA $spritesetPtr, X  ; Write to actor spritesetPtr ($7F0006)
    LDA $&body_table+2, Y ; Load bank byte from body_table[index]+2
    AND #$00FF
    STA $7F0008, X        ; Write to actor sprite bank ($7F0008)
    LDA #$8000            ; Set playerFlags $8000 (player sprite was directly overridden)
    TSB $playerFlags
    INC $0A
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #8F with one byte operand (animation index). Stores the anim in actor $28, clears $2A, calls SetActorBody to apply the current characterForm body, then saves the script PC/bank in $00/$02 for deferred animation staging.

StagePlayerSpr {
    TYX 
    LDA [$0A]             ; StagePlayerSpr: read animation index byte
    INC $0A
    AND #$00FF
    STA $28               ; Store anim index to $28; clear frame counter $2A
    STZ $2A               ; Clear frame counter — start from frame 0
    JSR $&actor_pool.SetActorBody ; SetActorBody: apply characterForm body_table to spriteset/bank
    LDA $0C
    STA $02
    LDA $0A
    STA $00               ; Cache script pointer in $00 for deferred animation entry
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #90 with two byte operands (animation index, X step). Same SetActorBody staging as StagePlayerSpr, stores X distance in moveXAlt ($7F0018), and uses AnimFrameLookup to resolve the X frame duration into $2C.

StagePlayerSprX {
    TYX 
    LDA [$0A]
    INC $0A               ; StagePlayerSprX: read anim index, stage X axis
    AND #$00FF
    STA $28
    STZ $2A
    JSR $&actor_pool.SetActorBody
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveXAlt, X      ; Store X distance in moveXAlt ($7F0018)
    JSR $&actor_pool.AnimFrameLookup ; Look up frame duration for X axis
    STA $2C               ; Store X-axis frame duration to $2C
    LDA $0C
    STA $02
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #91 with two byte operands (animation index, Y step). Like StagePlayerSprX but stores Y distance in moveYAlt ($7F001A) and writes the looked-up Y frame duration to $2E.

StagePlayerSprY {
    TYX 
    LDA [$0A]
    INC $0A               ; StagePlayerSprY: read anim index, stage Y axis
    AND #$00FF
    STA $28
    STZ $2A
    JSR $&actor_pool.SetActorBody
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveYAlt, X      ; Store Y distance in moveYAlt ($7F001A)
    JSR $&actor_pool.AnimFrameLookup ; Look up frame duration for Y axis
    STA $2E               ; Store Y-axis frame duration to $2E
    LDA $0C
    STA $02
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #92 with three byte operands (animation index, X distance, Y distance). Combines both axis staging: SetActorBody, then AnimFrameLookup for X→$2C and Y→$2E, with moveXAlt/moveYAlt updated.

StagePlayerSprXY {
    TYX 
    LDA [$0A]
    INC $0A               ; StagePlayerSprXY: read anim index, stage both axes
    AND #$00FF
    STA $28
    STZ $2A
    JSR $&actor_pool.SetActorBody
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveXAlt, X      ; moveXAlt: X-axis distance
    JSR $&actor_pool.AnimFrameLookup
    STA $2C               ; AnimFrameLookup for X → $2C
    LDA [$0A]
    INC $0A
    AND #$00FF            ; Mask Y distance operand to byte
    STA $moveYAlt, X
    JSR $&actor_pool.AnimFrameLookup
    STA $2E               ; AnimFrameLookup for Y → $2E
    LDA $0C
    STA $02
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #93 with no operands. Calls UpdateActorAnimation once per script tick; clears $2C/$2E when the animation finishes (carry set). Yields via RTL while the animation is still running.

RunPlayerAnim {
    TYX 
    JSL $@sprite_composition.UpdateActorAnimation ; Update player animation; carry set = sequence completed
    BCC loc_00A116        ; Not done: yield RTL
    LDA #$0000            ; Done: clear both movement deltas
    STA $2C
    STA $2E
    LDA $0A
    STA $02, S
    RTI 

  loc_00A116:
    PLA 
    PLA 
    RTL 
}

---------------------------------------------
; COP #94 with four byte operands (animation index, X distance, Y distance, wall type). Identical XY staging to StagePlayerSprXY, plus a fourth byte stored in playerWallType ($09B0) for subsequent wall-collision checks.

StagePlayerSprWall {
    TYX 
    LDA [$0A]
    INC $0A               ; StagePlayerSprWall: read anim+X+Y+wall type (4 operands)
    AND #$00FF
    STA $28
    STZ $2A
    JSR $&actor_pool.SetActorBody
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveXAlt, X
    JSR $&actor_pool.AnimFrameLookup
    STA $2C
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveYAlt, X
    JSR $&actor_pool.AnimFrameLookup
    STA $2E
    LDA [$0A]             ; Read wall-type byte operand (4th operand)
    INC $0A
    AND #$00FF
    STA $playerWallType   ; Store to playerWallType ($09B0) for WallAnim checks
    LDA $0C
    STA $02
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #95 with no script operands. Reads the animation index from direct-page $0000 instead of the script stream, then runs SetActorBody and saves $00/$02 like StagePlayerSpr.

StagePlayerSprFromDP {
    TYX 
    LDA $0000             ; Read anim index from DP $0000 instead of script stream
    AND #$00FF
    STA $28
    STZ $2A
    JSR $&actor_pool.SetActorBody ; Apply body table without script operand consumption
    LDA $0C
    STA $02
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #96 with one word operand (joypad button mask). When joypadCurrent matches and the actor is grid-aligned, queries the tile at the actor position via TileCollisionQuery. Sets actor flag $0004 on blocked tiles ($F0 solid or type $0F). If the tile type matches playerWallType, advances animation via UpdateActorAnimation. Yields RTL until animation completes.

WallAnimHere {
    TYX 
    LDA [$0A]             ; WallAnimHere: read joypad mask operand (word)
    INC $0A
    INC $0A
    CMP $joypadCurrent    ; Compare mask against joypadCurrent — skip if no matching button held
    BNE loc_00A1A4
    LDA $16
    BIT #$000F            ; Test grid alignment: Y low nibble must be 0 (on 16px boundary)
    BNE loc_00A19E
    STA $001C
    LDA $14               ; Set probe X coordinate from actor position
    STA $0018
    JSR $&cop_handlers_solid.TileCollisionQuery ; Query collision layer tile at actor's feet
    AND #$00FF
    BIT #$00F0            ; Test solid nibble ($F0) — any bit set means blocked tile
    BNE loc_00A1A9
    CMP #$000F            ; Type $0F also counts as blocked
    BEQ loc_00A1A9
    CMP $playerWallType   ; Compare tile type against playerWallType — must match for animation
    BNE loc_00A1A4

  loc_00A19E:
    JSL $@sprite_composition.UpdateActorAnimation ; Type matches: advance wall animation via UpdateActorAnimation
    BCC loc_00A1B2        ; Carry clear = animation still running → yield RTL

  loc_00A1A4:
    LDA $0A
    STA $02, S
    RTI 

  loc_00A1A9:
    LDA $10
    ORA #$0004            ; Set actor flag $0004 (wall contact) on blocked tile
    STA $10
    BRA loc_00A1A4

  loc_00A1B2:
    PLA 
    PLA 
    RTL 
}

---------------------------------------------
; COP #97 with one word operand (joypad mask). Same logic as WallAnimHere but TileCollisionQuery uses Y−$0010 (one tile north of the actor).

WallAnimNorth {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    CMP $joypadCurrent
    BNE loc_00A1EF
    LDA $16
    BIT #$000F
    BNE loc_00A1E9
    SEC 
    SBC #$0010            ; North variant: subtract $10 (one tile north) from Y for collision probe
    STA $001C             ; WallAnimNorth: probe Y−$10 (one tile north)
    LDA $14
    STA $0018
    JSR $&cop_handlers_solid.TileCollisionQuery ; TileCollisionQuery at tile north of actor
    AND #$00FF
    BIT #$00F0
    BNE loc_00A1F4
    CMP #$000F
    BEQ loc_00A1F4
    CMP $playerWallType
    BNE loc_00A1EF

  loc_00A1E9:
    JSL $@sprite_composition.UpdateActorAnimation
    BCC loc_00A1FD

  loc_00A1EF:
    LDA $0A
    STA $02, S
    RTI 

  loc_00A1F4:
    LDA $10
    ORA #$0004
    STA $10
    BRA loc_00A1EF

  loc_00A1FD:
    PLA 
    PLA 
    RTL 
}

---------------------------------------------
; COP #98 with one word operand (joypad mask). Same logic as WallAnimHere but TileCollisionQuery uses Y+$0010 (one tile south of the actor).

WallAnimSouth {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    CMP $joypadCurrent
    BNE loc_00A23A
    LDA $16
    BIT #$000F
    BNE loc_00A234
    CLC 
    ADC #$0010            ; South variant: add $10 (one tile south) to Y for collision probe
    STA $001C             ; WallAnimSouth: probe Y+$10 (one tile south)
    LDA $14
    STA $0018
    JSR $&cop_handlers_solid.TileCollisionQuery ; Query collision at tile south of actor
    AND #$00FF
    BIT #$00F0
    BNE loc_00A23F
    CMP #$000F
    BEQ loc_00A23F
    CMP $playerWallType
    BNE loc_00A23A

  loc_00A234:
    JSL $@sprite_composition.UpdateActorAnimation
    BCC loc_00A248

  loc_00A23A:
    LDA $0A
    STA $02, S
    RTI 

  loc_00A23F:
    LDA $10
    ORA #$0004
    STA $10
    BRA loc_00A23A

  loc_00A248:
    PLA 
    PLA 
    RTL 
}