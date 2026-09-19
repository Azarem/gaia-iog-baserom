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
    SEP #$20
    LDA [$0A]
    STA $0AC8
    ASL                   ; Index ×6: ASL (×2) + ADC self (×3) + ASL (×6) for 6-byte body_table entries
    CLC 
    ADC [$0A]
    ASL 
    REP #$20
    AND #$00FF
    STA $animScratch2, X
    TAY 
    LDA $&body_table, Y
    STA $spritesetPtr, X
    LDA $&body_table+2, Y
    AND #$00FF
    STA $7F0008, X
    LDA #$8000
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
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $28
    STZ $2A
    JSR $&actor_pool.SetActorBody
    LDA $0C
    STA $02
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #90 with two byte operands (animation index, X step). Same SetActorBody staging as StagePlayerSpr, stores X distance in moveXAlt ($7F0018), and uses AnimFrameLookup to resolve the X frame duration into $2C.

StagePlayerSprX {
    TYX 
    LDA [$0A]
    INC $0A
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
    INC $0A
    AND #$00FF
    STA $28
    STZ $2A
    JSR $&actor_pool.SetActorBody
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveYAlt, X
    JSR $&actor_pool.AnimFrameLookup
    STA $2E
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
    INC $0A
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
    JSL $@sprite_composition.UpdateActorAnimation
    BCC loc_00A116
    LDA #$0000
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
    INC $0A
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
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $playerWallType
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
    LDA $0000
    AND #$00FF
    STA $28
    STZ $2A
    JSR $&actor_pool.SetActorBody
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
    LDA [$0A]
    INC $0A
    INC $0A
    CMP $joypadCurrent
    BNE loc_00A1A4
    LDA $16
    BIT #$000F            ; Grid-aligned test: low nibble of Y must be zero (16px tile boundary)
    BNE loc_00A19E
    STA $001C
    LDA $14
    STA $0018
    JSR $&cop_handlers_solid.TileCollisionQuery
    AND #$00FF
    BIT #$00F0            ; Solid nibble ($F0): any set bit means blocked tile → set wall contact flag
    BNE loc_00A1A9
    CMP #$000F
    BEQ loc_00A1A9
    CMP $playerWallType   ; Tile collision type must match playerWallType for animation to advance
    BNE loc_00A1A4

  loc_00A19E:
    JSL $@sprite_composition.UpdateActorAnimation
    BCC loc_00A1B2

  loc_00A1A4:
    LDA $0A
    STA $02, S
    RTI 

  loc_00A1A9:
    LDA $10
    ORA #$0004
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
    SBC #$0010
    STA $001C
    LDA $14
    STA $0018
    JSR $&cop_handlers_solid.TileCollisionQuery
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
    ADC #$0010
    STA $001C
    LDA $14
    STA $0018
    JSR $&cop_handlers_solid.TileCollisionQuery
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