; COP handlers for the player's body spriteset and player-specific animation staging (Bank 00, 11 handlers, COP #8E-#98). The copdef names for #90-#92 are StagePlayerMoveX/Y/XY (the labels here are StagePlayerMoveX/Y/XY).
; 
; Script sites: SetPlayerSpriteDirect 24, StagePlayerSprite 93, StagePlayerMoveX 2, MoveY 21, MoveXY 9, RunPlayerAnim 8, StagePlayerSprFromDP 8 (all in forced_walk). StagePlayerSprWall and WallAnimHere/North/South have no script sites.
; 
; === Body table ===
; SetPlayerSpriteDirect takes an index into the 6-byte body_table entries (word spriteset pointer, bank byte, ...): 0 Will ($95), 1 Freedan ($8E), 2 and 3 Shadow ($94), 4 spriteset_will_abilities ($8F), 5 spriteset_transform_poses ($8F), 6 spriteset_freedan_fx ($97), 7 spriteset_shadow_fx ($97), 8 spriteset_shadow_aura_body ($97). It writes spritesetPtr ($7F0006), the bank byte ($7F0008), the table offset into animScratch2 ($7F000E, read by the sprite decomposer while playerFlags bit 15 is set) and the raw index into $0AC8, then sets playerFlags $8000. It does NOT stage an animation: no $28/$2A change. $7F0008 is polymorphic (sprite bank for sprite actors, amplitude for HDMA sine thinkers).
; The StagePlayerSprite family calls SetActorBody instead, which picks the body from characterForm, so one script works for Will, Freedan and Shadow.
; 
; === Staging ===
; These ops store the raw animation operand in $28 (no ProcessAnimFlag, so no mirror handling), clear $2A, and save the next-op address in $00 and the script bank in $02 (the lines LDA $0C / STA $02 before each store are inserted by db-us/transforms.json and have no address tag). The movement operands of MoveX/MoveY/MoveXY are movement indices, not distances or durations: AnimFrameLookup turns each into the head of a delta chain (move_chain_table) stored in $2C (X) or $2E (Y); moveXAlt/moveYAlt ($7F0018/$7F001A) keep the raw index. StagePlayerSprFromDP takes the animation index from the actor's $00 word, which the forced_walk helpers ReadDirSprite_* park there just before; the handler then overwrites $00 with the new entry address. RunPlayerAnim behaves exactly like AnimOnce (#89).
; 
; === WallAnimHere/North/South (#96-#98, unused) ===
; Take a joypad mask word and compare it with joypadCurrent for equality; on mismatch they continue without waiting. Only the Y alignment is checked (Y low nibble must be 0); when misaligned they animate without probing. The probe tile is at the actor (Here), Y - $10 (North) or Y + $10 (South). TileCollisionQuery already folds solid tiles and out-of-bounds into $000F, so the BIT #$00F0 test never fires and only the $000F compare detects a block (the actor flag $0004 is then set and the op continues). Otherwise, when the tile type equals playerWallType ($09B0) they run UpdateActorAnimation (yield while it runs, continue when it finishes); a different type continues without animating. $0018/$001C are the page-0 scratch pair read by TileCollisionQuery.
---------------------------------------------

?BANK 00

?INCLUDE 'actor_pool'
?INCLUDE 'body_table'
?INCLUDE 'cop_handlers_collision'
?INCLUDE 'sprite_composition'

!joypadCurrent                  0656
!playerFlags                    09AE
!playerWallType                 09B0
!spritesetPtr                   7F0006
!animScratch2                   7F000E
!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

; COP #8E with one byte operand (body_table index 0-8). Writes spritesetPtr ($7F0006) and the bank byte ($7F0008) from the 6-byte body_table entry, caches index x 6 in animScratch2 ($7F000E) and the raw index in $0AC8, and sets playerFlags $8000. Does not touch the animation index or frame counter. 24 sites (the Psycho Slider code uses #04 = spriteset_will_abilities).

SetPlayerSpriteDirect {
    TYX 
    SEP #$20              ; 8-bit mode for byte operand read and body_table index math
    LDA [$0A]             ; Operand: body_table index 0-8 (row names are listed in the block note, section Body table)
    STA $0AC8             ; Cache raw index in $0AC8 for external reference
    ASL                   ; Index ×6: ASL(×2) + ADC self(×3) + ASL(×6) — 6 bytes per body_table entry
    CLC 
    ADC [$0A]
    ASL 
    REP #$20
    AND #$00FF
    STA $animScratch2, X  ; index x 6 into animScratch2: the sprite decomposer reads it while playerFlags bit 15 is set
    TAY 
    LDA $&body_table, Y   ; Load spriteset pointer from body_table[index]
    STA $spritesetPtr, X  ; Write to actor spritesetPtr ($7F0006)
    LDA $&body_table+2, Y ; Load bank byte from body_table[index]+2
    AND #$00FF
    STA $7F0008, X        ; Bank byte ($7F0008): $8F rows 4-5 (spriteset_will_abilities, spriteset_transform_poses), $95 Will, $8E Freedan, $94 Shadow, $97 rows 6-8
    LDA #$8000            ; Set playerFlags $8000 (player sprite was directly overridden)
    TSB $playerFlags      ; playerFlags bit 15 = sprite override; SetActorBody (every StagePlayerSprite* op) clears it again. This op stages no animation
    INC $0A
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #8F with one byte operand (animation index). Stores it raw in $28, clears $2A, applies the characterForm body with SetActorBody, then saves the next-op address in $00 and the bank in $02. 93 sites.

StagePlayerSprite {
    TYX 
    LDA [$0A]             ; StagePlayerSprite: read animation index byte
    INC $0A
    AND #$00FF
    STA $28               ; Raw animation index to $28 (no ProcessAnimFlag, so no mirror handling); $2A cleared next
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
; COP #90 (copdef StagePlayerMoveX) with two byte operands: animation index and an X movement index. Same staging as StagePlayerSprite; the movement index is kept in moveXAlt ($7F0018) and AnimFrameLookup turns it into the X delta-chain head stored in $2C. 2 sites.

StagePlayerMoveX {
    TYX 
    LDA [$0A]
    INC $0A               ; StagePlayerMoveX: read anim index, stage X axis
    AND #$00FF
    STA $28
    STZ $2A
    JSR $&actor_pool.SetActorBody
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveXAlt, X      ; Movement index (not a distance); AnimFrameLookup converts it to a delta-chain head
    JSR $&actor_pool.AnimFrameLookup ; A = movement index -> move_chain_table chain head
    STA $2C               ; $2C = X delta-chain head (applied per frame by the actor runner), not a duration
    LDA $0C
    STA $02
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #91 (copdef StagePlayerMoveY) with two byte operands: animation index and a Y movement index; the Y delta-chain head goes to $2E, the index to moveYAlt ($7F001A). 21 sites.

StagePlayerMoveY {
    TYX 
    LDA [$0A]
    INC $0A               ; StagePlayerMoveY: read anim index, stage Y axis
    AND #$00FF
    STA $28
    STZ $2A
    JSR $&actor_pool.SetActorBody
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveYAlt, X      ; Y movement index (not a distance), kept in moveYAlt
    JSR $&actor_pool.AnimFrameLookup ; A = movement index -> move_chain_table chain head
    STA $2E               ; $2E = Y delta-chain head, not a duration
    LDA $0C
    STA $02
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #92 (copdef StagePlayerMoveXY) with three byte operands: animation index, X movement index, Y movement index; delta-chain heads go to $2C and $2E. 9 sites.

StagePlayerMoveXY {
    TYX 
    LDA [$0A]
    INC $0A               ; StagePlayerMoveXY: read anim index, stage both axes
    AND #$00FF
    STA $28
    STZ $2A
    JSR $&actor_pool.SetActorBody
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveXAlt, X      ; X movement index, kept in moveXAlt
    JSR $&actor_pool.AnimFrameLookup
    STA $2C               ; $2C = X delta-chain head
    LDA [$0A]
    INC $0A
    AND #$00FF            ; Mask the Y movement index operand to a byte
    STA $moveYAlt, X      ; Y movement index, kept in moveYAlt
    JSR $&actor_pool.AnimFrameLookup
    STA $2E               ; $2E = Y delta-chain head
    LDA $0C
    STA $02
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #93 with no operands, identical to AnimOnce (#89): one UpdateActorAnimation pass; yields (PLA PLA RTL) while the animation runs, and on completion zeroes $2C/$2E and continues. 8 sites.

RunPlayerAnim {
    TYX 
    JSL $@sprite_composition.UpdateActorAnimation ; Update player animation; carry set = sequence completed
    BCC loc_00A116        ; Not done: yield RTL
    LDA #$0000            ; Animation finished: stop the staged movement chains
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
; COP #94 with four byte operands (animation index, X movement index, Y movement index, wall type). Same as StagePlayerMoveXY plus a fourth byte stored in playerWallType ($09B0) for the WallAnim ops. No script sites.

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
    STA $moveXAlt, X      ; X movement index, kept in moveXAlt
    JSR $&actor_pool.AnimFrameLookup
    STA $2C               ; $2C = X delta-chain head
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveYAlt, X      ; Y movement index, kept in moveYAlt
    JSR $&actor_pool.AnimFrameLookup
    STA $2E               ; $2E = Y delta-chain head
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
; COP #95 with no operands. The animation index is the low byte of the actor's $00 word, which the forced_walk helpers ReadDirSprite_XVelocity/YVelocity store there before the op; afterwards the handler overwrites $00 with the next-op address like StagePlayerSprite. 8 sites, all in forced_walk.

StagePlayerSprFromDP {
    TYX 
    LDA $0000             ; Index parked in $00 by forced_walk's ReadDirSprite_* helpers; overwritten with the next-op address below
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
; COP #96 with one word operand (joypad mask, compared for equality with joypadCurrent). If the masks differ the op continues at once. If Y is 16-aligned it probes the tile at the actor; a block (TileCollisionQuery returned $000F) sets actor flag $0004 and continues; a tile type different from playerWallType continues without animating; otherwise (or when Y is not aligned) it runs UpdateActorAnimation and yields until the animation finishes. No script sites.

WallAnimHere {
    TYX 
    LDA [$0A]             ; WallAnimHere: read joypad mask operand (word)
    INC $0A
    INC $0A
    CMP $joypadCurrent    ; Exact compare of joypadCurrent with the mask; on mismatch the op continues without waiting
    BNE loc_00A1A4
    LDA $16               ; Only Y is checked for alignment; if it is off-grid the op animates without probing
    BIT #$000F            ; Test grid alignment: Y low nibble must be 0 (on 16px boundary)
    BNE loc_00A19E
    STA $001C             ; Page-0 scratch $1C = probe pixel Y (read by TileCollisionQuery)
    LDA $14               ; Set probe X coordinate from actor position
    STA $0018             ; Page-0 scratch $18 = probe pixel X
    JSR $&cop_handlers_collision.TileCollisionQuery ; Returns the collision byte, or $000F for solid and out-of-bounds tiles
    AND #$00FF
    BIT #$00F0            ; Never taken: TileCollisionQuery already turned solid tiles into $000F
    BNE loc_00A1A9
    CMP #$000F            ; $000F = blocked (solid or out of bounds)
    BEQ loc_00A1A9
    CMP $playerWallType   ; Tile type must equal playerWallType ($09B0) for the animation to run; otherwise continue
    BNE loc_00A1A4

  loc_00A19E:
    JSL $@sprite_composition.UpdateActorAnimation ; Type matches: advance wall animation via UpdateActorAnimation
    BCC loc_00A1B2        ; Carry clear = animation still running → yield RTL

  loc_00A1A4:
    LDA $0A
    STA $02, S
    RTI 

  loc_00A1A9:
    LDA $10               ; Blocked: set actor flag $0004 (per-frame solid-contact flag) and continue
    ORA #$0004            ; Set actor flag $0004 (wall contact) on blocked tile
    STA $10
    BRA loc_00A1A4

  loc_00A1B2:
    PLA 
    PLA 
    RTL 
}

---------------------------------------------
; COP #97, same as WallAnimHere but the probe pixel is Y - $10. No script sites.

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
    STA $001C             ; Probe pixel Y - $10 into page-0 scratch $1C
    LDA $14
    STA $0018
    JSR $&cop_handlers_collision.TileCollisionQuery ; TileCollisionQuery at tile north of actor
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
; COP #98, same as WallAnimHere but the probe pixel is Y + $10. No script sites.

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
    STA $001C             ; Probe pixel Y + $10 into page-0 scratch $1C
    LDA $14
    STA $0018
    JSR $&cop_handlers_collision.TileCollisionQuery ; Query collision at tile south of actor
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