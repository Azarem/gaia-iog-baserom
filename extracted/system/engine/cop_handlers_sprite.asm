; COP handlers for sprite animation, frame staging and spriteset assignment (Bank $00, 16 COP handlers + 1 internal routine).
; 
; === FRAME-LIST ANIMATION (#80–#8D, 6,687 script sites) ===
; An actor owns a spriteset table (spritesetPtr $7F0006 + bank $7F0008, set by SetMetasprite): word pointers, one frame list per animation index ($28). A frame list is a sequence of 4-byte records addressed by the frame counter $2A: word 0 = hold time, word 2 = pointer to the frame's sprite data; a negative word 0 ends the list. sprite_composition.UpdateActorAnimation reads the record, stores the hold time in DP $08 (the wait counter the actor runner decrements with DEC $08 / BPL skip, so a hold of n shows the frame for n + 1 ticks), sets metaspritePtr and the extents/hitbox, and increments $2A; at the end of a list it resets $2A and returns carry SET without staging anything.
; - StageSpriteFrame (#80) and its Move/Loop variants only CHOOSE the animation: ProcessAnimFlag stores the index in $28 and clears $2A. Optional operands set the repeat count (sprTimer $7F0016: StageSpriteLoop*) and the movement chains (StageSpriteMove*: movement indices 0-$54 kept in moveXAlt/moveYAlt $7F0018/$7F001A, and the delta-chain heads from move_chain_table in $2C/$2E, exactly as StageMoveX/Y/XY in cop_handlers_force_move; the operands are indices, not distances or durations).
; - AnimOnce (#89), AnimLoop (#8A), AnimOneFrame (#8B) and WaitForAnimFrame (#8C) PLAY it: each call runs UpdateActorAnimation and either yields (PLA PLA RTL; the entry point is unchanged, so the same op runs again after the hold) or continues with RTI. When a list ends they zero $2C/$2E, so the staged movement stops with the animation.
; - StageSprAndHitbox (#8D) stages the animation and calls UpdateActorAnimation at once (no yield) to set the first frame's sprite and hitbox, then clears $2A again: it poses an actor without playing it.
; 
; === Entry address and bank ===
; SetTileStreamAnim and every StageSprite* op store the address after the op in $00 and so act like SetEntryHere: the actor re-enters at the next op. The Anim* ops yield WITHOUT touching $00, so a Stage* op before them makes the same Anim* op run again every time the actor runs until the animation finishes. The two lines LDA $0C / STA $02 in front of each such store have no address tag because db-us/transforms.json (cop_handlers_sprite) inserts them: they also store the script bank in $02, so the entry bank follows the op (the original ROM saved only $00).
; 
; === TILE-STREAMING ANIMATION (#55 SetTileStreamAnim, #56 AdvanceSpriteAnim, 4 script sites) ===
; Used by four effect actors (awB4_snake_pit_fx, fr32_laborer_npc ×2, dc2F_adrift_fx): a script runs SetScratchPointer (art source: word in animScratch, bank in animScratch+2), SetMetasprite, SetTileStreamAnim (animation index, VRAM word address in $24), then AdvanceSpriteAnim in a loop. Each AdvanceSpriteAnim call waits while the previous DMA is pending ($B2 nonzero), stages one frame (32 bytes, or 128 when the byte at +$0D of the frame's sprite data is nonzero) taken from animScratch + 32 × (byte at +$12) to the VRAM word address in $24 (the NMI performs the DMA), loads the hold time into $08 and yields. At the end of a list the counter restarts and the script continues past the op.
; 
; === Animation index byte (ProcessAnimFlag) ===
; $FF keeps the current index. Bit 7 selects the mirrored variant: the low 7 bits go to $28 and the horizontal flip bit $4000 of the OAM attribute word $0E is set; without bit 7 the flip bit is cleared. Both flip updates are skipped when bit 1 ($0002) of the actor status $12 is set: that bit is a persistent mirror lock, not a facing flag (awB0_zombie sets it after a mirrored StageSprAndHitbox and sE8_dark_gaia right after SetHMirror; OQ-I022-1).
; 
; Uses in extracted/: AnimOnce 2075, StageSpriteFrame 1200, AnimLoop 1048, StageSpriteLoop 455, StageSpriteMoveY 331, StageSpriteMoveX 310, StageSpriteLoopMoveX 278, StageSpriteLoopMoveY 252, StageSprAndHitbox 229, SetMetasprite 186, AnimOneFrame 165, StageSpriteMoveXY 68, StageSpriteLoopMoveXY 61, WaitForAnimFrame 29, SetTileStreamAnim 4, AdvanceSpriteAnim 4.
---------------------------------------------

?BANK 00

?INCLUDE 'actor_pool'
?INCLUDE 'sprite_composition'

!animScratch                    7F0000
!spritesetPtr                   7F0006
!sprTimer                       7F0016
!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

; COP #55 with one byte and one word operand (4 sites, all tile-streaming effect actors). Stores the byte in $28 (animation index), clears the frame counter $2A, stores the word in $24 (the VRAM word address AdvanceSpriteAnim streams tiles to; it is copied to $B0) and saves the address after the op in $00 (normally the AdvanceSpriteAnim op) before RTI. Despite the name it resets no sprite state of the composition system.

SetTileStreamAnim {
    TYX 
    LDA [$0A]             ; Read animation index byte operand
    INC $0A
    AND #$00FF
    STA $28               ; Store the animation index to $28 (the next line clears the frame counter $2A)
    STZ $2A               ; Clear frame counter $2A (start animation from frame 0)
    LDA [$0A]             ; Read the VRAM word-address operand (stored to $24 below)
    INC $0A
    INC $0A
    STA $24               ; $24 = VRAM word address that AdvanceSpriteAnim streams the tiles to (it is copied to $B0)
    LDA $0C
    STA $02
    LDA $0A
    STA $00               ; Save script pointer to actor $00 (entry point cache)
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #56 with no operands (4 sites). Yields (PLA PLA RTL) while a VRAM DMA is pending ($B2 nonzero). Otherwise reads the frame record (list at spritesetPtr[$28] + 4 × $2A) with DBR = the spriteset bank: word 0 (hold time) → $08, word 2 → sprite data; stages a tile DMA (source animScratch + 32 × the byte at +$12 of the sprite data, bank animScratch+2, destination $24, size 32 or 128 bytes by the byte at +$0D) and yields. A negative word 0 ends the list: $2A is cleared and the script continues with RTI.

AdvanceSpriteAnim {
    TYX 
    LDA $00B2             ; Check if VRAM DMA is pending — cannot stage new tiles until transfer completes
    BEQ loc_0099FE        ; No DMA pending ($00B2 = 0): continue to process next animation frame
    PLA                   ; DMA pending: pop COP frame and yield RTL until next VBlank
    PLA 
    RTL 

  loc_0099FE:
    PHB                   ; Save data bank before switching to spriteset bank
    LDA $24               ; VRAM destination word chosen by SetTileStreamAnim
    STA $00B0             ; $B0 = VRAM destination of the pending DMA (ExecuteVramDma in the NMI)
    SEP #$20
    LDA $7F0008, X        ; Load spriteset bank byte from actor $7F0008
    PHA 
    PLB                   ; Set DBR to spriteset bank for bank-relative table reads
    REP #$20
    LDA $28               ; Animation index ($28) ×2 for word pointer table
    ASL                   ; ×2 for word-sized pointer table entry
    CLC 
    ADC $spritesetPtr, X  ; Add spritesetPtr base → Y = animation sequence pointer
    TAY 
    LDA $2A               ; Load frame counter ($2A) then advance for next call
    INC $2A
    ASL                   ; x4: 4-byte frame records (hold time word, sprite data pointer word)
    ASL 
    CLC 
    ADC $0000, Y          ; Add sequence base → Y = current frame data address
    TAY 
    LDA $0000, Y          ; Read frame data word — negative = end-of-sequence sentinel
    BMI loc_009A5F        ; Negative: animation complete → reset counter and RTI
    STA $08               ; Frame hold time -> $08, the wait counter (a stored n waits n extra ticks)
    LDA $0002, Y          ; Metasprite data pointer from frame entry word 2
    TAY 
    LDA $0012, Y          ; Byte at +$12 of the frame's sprite data: tile index (x32 bytes) into the art at animScratch
    AND #$00FF
    ASL                   ; ASL ×5 = ×32 bytes per SNES 4bpp tile
    ASL 
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $animScratch, X   ; Art base set by SetScratchPointer + 32 x tile index = source address of the tile DMA
    STA $00AC             ; Write DMA source address to $00AC
    LDA $animScratch+2, X ; Load DMA source bank to $00AE
    STA $00AE
    LDA #$0020            ; $20 = 32 bytes (one 8×8 4bpp tile) default transfer size
    STA $00B2             ; Store size to $00B2 (nonzero = DMA pending flag)
    LDA $000D, Y          ; Metasprite size flag: 0 = standard, nonzero = large
    AND #$00FF
    BEQ loc_009A5B        ; Zero flag = standard 32-byte tile transfer
    LDA #$0080            ; Nonzero: large sprite = $80 (128 bytes = four tiles)
    STA $00B2

  loc_009A5B:
    PLB 
    PLA 
    PLA 
    RTL 

  loc_009A5F:
    STZ $2A               ; End of sequence: reset frame counter to 0
    PLB 
    LDA $0A
    STA $02, S
    RTI 
}
---------------------------------------------

; COP #80 with one byte operand (animation index, 1200 sites). ProcessAnimFlag sets $28 (and the horizontal flip) and clears $2A; then the entry point ($00) and bank ($02) are set from the next op and the script continues with RTI. The animation is played by a following Anim* op.

StageSpriteFrame {
    TYX 
    LDA [$0A]             ; Read animation index byte operand
    INC $0A
    AND #$00FF
    JSR $&ProcessAnimFlag ; Interpret anim flag: handle flip and store to $28
    LDA $0C
    STA $02
    LDA $0A               ; Update script pointer for entry point cache
    STA $00
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #81 with two byte operands (animation index, X movement index; 310 sites). ProcessAnimFlag, then moveXAlt = the index and $2C = move_chain_table[index × 2], the head of the X delta chain (AnimFrameLookup returns a chain pointer, not a duration). Saves the entry point and continues with RTI.

StageSpriteMoveX {
    TYX 
    LDA [$0A]
    INC $0A               ; StageSpriteMoveX: read anim byte
    AND #$00FF
    JSR $&ProcessAnimFlag
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveXAlt, X      ; X movement index (move_chain_table), not a distance
    JSR $&actor_pool.AnimFrameLookup ; A = head pointer of the X delta chain for that index (not a duration)
    STA $2C               ; $2C = X delta chain pointer
    LDA $0C
    STA $02
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #82 with two byte operands (animation index, Y movement index; 331 sites). ProcessAnimFlag, then moveYAlt = the index and $2E = the head of the Y delta chain from move_chain_table. Saves the entry point and continues with RTI.

StageSpriteMoveY {
    TYX 
    LDA [$0A]
    INC $0A               ; StageSpriteMoveY: read anim byte
    AND #$00FF
    JSR $&ProcessAnimFlag
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveYAlt, X      ; Y movement index (move_chain_table), not a distance
    JSR $&actor_pool.AnimFrameLookup ; A = head pointer of the Y delta chain for that index
    STA $2E               ; $2E = Y delta chain pointer
    LDA $0C
    STA $02
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #83 with three byte operands (animation index, X movement index, Y movement index; 68 sites). ProcessAnimFlag, then both chains as in StageSpriteMoveX/Y: moveXAlt/moveYAlt hold the indices, $2C/$2E the delta-chain heads.

StageSpriteMoveXY {
    TYX 
    LDA [$0A]
    INC $0A               ; StageSpriteMoveXY: read anim byte
    AND #$00FF
    JSR $&ProcessAnimFlag
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
; COP #84 with two byte operands (animation index, repeat count; 455 sites). ProcessAnimFlag and sprTimer = the count, the number of complete passes AnimLoop makes (a count of 0 would give 65,536 passes). No movement is staged.

StageSpriteLoop {
    TYX 
    LDA [$0A]
    INC $0A               ; StageSpriteLoop: read anim byte
    AND #$00FF
    JSR $&ProcessAnimFlag
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $sprTimer, X      ; Store loop/repeat count in sprTimer ($7F0016)
    LDA $0C
    STA $02
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #85 with three byte operands (animation index, repeat count, X movement index; 278 sites). ProcessAnimFlag, sprTimer = count, moveXAlt = index and $2C = the X delta-chain head.

StageSpriteLoopMoveX {
    TYX 
    LDA [$0A]
    INC $0A               ; StageSpriteLoopMoveX: read the animation byte; the repeat count and the X movement index follow
    AND #$00FF
    JSR $&ProcessAnimFlag
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $sprTimer, X
    LDA [$0A]             ; Read the X movement index byte
    INC $0A
    AND #$00FF            ; X movement index (not a distance)
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
; COP #86 with three byte operands (animation index, repeat count, Y movement index; 252 sites). ProcessAnimFlag, sprTimer = count, moveYAlt = index and $2E = the Y delta-chain head.

StageSpriteLoopMoveY {
    TYX 
    LDA [$0A]
    INC $0A               ; StageSpriteLoopMoveY: read the animation byte; the repeat count and the Y movement index follow
    AND #$00FF
    JSR $&ProcessAnimFlag
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $sprTimer, X
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
; COP #87 with four byte operands (animation index, repeat count, X movement index, Y movement index; 61 sites). ProcessAnimFlag, sprTimer = count, both indices stored and both delta-chain heads loaded into $2C/$2E.

StageSpriteLoopMoveXY {
    TYX 
    LDA [$0A]
    INC $0A               ; StageSpriteLoopMoveXY: all four operands
    AND #$00FF
    JSR $&ProcessAnimFlag
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $sprTimer, X
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
; Internal JSR helper shared by all StageSprite* ops. Clears the frame counter $2A, then interprets the animation index byte in A:
; - $FF: keep $28 unchanged and return (the flip bit is not touched either).
; - bit 7 set: $28 = low 7 bits; unless $12 bit 1 is set, set the horizontal flip $4000 in the OAM attribute word $0E (the mirrored variant of the animation).
; - otherwise: $28 = the byte; unless $12 bit 1 is set, clear the flip bit.
; $12 bit 1 therefore acts as a mirror lock that freezes the flip state across later Stage ops (OQ-I022-1). Returns with RTS.

ProcessAnimFlag {
    STZ $2A               ; Clear frame counter — new stage always starts at frame 0
    CMP #$00FF            ; $FF = no-op: keep current animation index unchanged
    BNE loc_009F67
    RTS 

  loc_009F67:
    BIT #$0080            ; Bit 7 set = mirrored variant (the low 7 bits are the animation index)
    BEQ loc_009F7F
    AND #$FF7F            ; Mask off bit 7 → actual animation index
    STA $28               ; Store the animation index (low 7 bits) to $28
    LDA $12               ; $12 bit 1 = persistent mirror lock; when set the flip bit in $0E is left alone
    BIT #$0002            ; Lock set: keep the current flip state
    BEQ loc_009F79
    RTS 

  loc_009F79:
    LDA #$4000            ; Mirrored variant: set the horizontal flip $4000 in the OAM attribute word $0E
    TSB $0E
    RTS 

  loc_009F7F:
    STA $28               ; Normal mode: store index directly to $28
    LDA $12
    BIT #$0002            ; Same mirror-lock test for the unmirrored variant
    BEQ loc_009F89
    RTS 

  loc_009F89:
    LDA #$4000            ; Unmirrored variant: clear the horizontal flip $4000 in $0E
    TRB $0E
    RTS 
}

---------------------------------------------
; COP #88 with one word plus one byte operand (186 sites). Sets spritesetPtr ($7F0006) to the word and the spriteset bank ($7F0008) to the byte: the actor's table of frame lists (one list per animation index), not a single metasprite. The next Stage* op selects the list. Does not touch $00/$02 and continues with RTI.

SetMetasprite {
    TYX 
    LDA [$0A]             ; Read spriteset pointer word
    INC $0A
    INC $0A
    STA $spritesetPtr, X  ; spriteset table: word pointers to one frame list per animation index ($28)
    LDA [$0A]             ; Read bank byte for spriteset
    INC $0A
    AND #$00FF
    STA $7F0008, X        ; Write spriteset bank to actor $7F0008
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #89 with no operands (2,075 sites). Calls UpdateActorAnimation once per run: carry clear = a frame was staged, so the actor yields (PLA PLA RTL) and the same op repeats after the frame's hold time; carry set = the list ended, so $2C/$2E are zeroed (movement stops) and the script continues with RTI.

AnimOnce {
    TYX 
    JSL $@sprite_composition.UpdateActorAnimation ; Update animation; carry set = sequence completed this frame
    BCC loc_009FBD        ; Carry clear: a frame was staged, branch to the yield. Carry set (list ended) falls through and clears the deltas
    LDA #$0000            ; Zero both movement deltas ($2C/$2E) on completion
    STA $2C
    STA $2E
    LDA $0A
    STA $02, S
    RTI 

  loc_009FBD:
    PLA                   ; Animation still in progress: pop COP frame and yield RTL
    PLA 
    RTL 
}

---------------------------------------------
; COP #8A with no operands (1,048 sites). Like AnimOnce, but at the end of a list it decrements sprTimer and, while that is nonzero, restarts the list at once (the same run stages frame 0, so there is no idle tick between passes). When the count reaches zero it clears $2C/$2E and continues. A count of 0 gives 65,536 passes.

AnimLoop {
    TYX 

  loc_009FC1:
    JSL $@sprite_composition.UpdateActorAnimation ; Update one animation frame
    BCC loc_009FDB        ; Cycle incomplete: yield RTL
    LDA $sprTimer, X      ; Cycle complete: decrement repeat counter in sprTimer
    DEC 
    STA $sprTimer, X
    BNE loc_009FC1        ; Counter nonzero: restart animation cycle from frame 0
    STZ $2C               ; All repeats done: clear movement deltas and resume script
    STZ $2E
    LDA $0A
    STA $02, S
    RTI 

  loc_009FDB:
    PLA 
    PLA 
    RTL 
}

---------------------------------------------
; COP #8B with no operands (165 sites). Calls UpdateActorAnimation once and always continues with RTI (no yield); zeroes $2C/$2E when the list ended. It stages the next frame (and its hold time in $08) without waiting for it.

AnimOneFrame {
    TYX 
    JSL $@sprite_composition.UpdateActorAnimation ; Update animation once this frame (single-step)
    BCC loc_009FEC        ; Carry clear: a frame was staged, skip the delta clear. Carry set (list ended) falls through and clears the deltas
    LDA #$0000
    STA $2C
    STA $2E

  loc_009FEC:
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #8C with one byte operand (target frame index; 29 sites). Calls UpdateActorAnimation and yields until the frame counter $2A equals the operand. $2A is read after UpdateActorAnimation already incremented it, so the script resumes one stage earlier than a literal reading suggests: when frame operand − 1 has just been staged. If the list ends first the movement chains are cleared and the script continues; the operand is consumed on every path.

WaitForAnimFrame {
    TYX 
    JSL $@sprite_composition.UpdateActorAnimation ; Update animation
    BCC loc_00A00B        ; Carry clear: still animating, branch to the frame test. Carry set (ended) falls through, clears the deltas and continues
    LDA #$0000
    STA $2C
    STA $2E
    LDA [$0A]
    INC $0A
    AND #$00FF
    LDA $0A
    STA $02, S
    RTI 

  loc_00A00B:
    LDA [$0A]             ; Still animating: read target frame index operand
    INC $0A
    AND #$00FF
    CMP $2A               ; $2A was already incremented by UpdateActorAnimation: matches once frame (operand - 1) has been staged
    BEQ loc_00A019        ; Frame matched: advance past operand and RTI (continue script)
    PLA                   ; Not reached yet: yield RTL until target frame
    PLA 
    RTL 

  loc_00A019:
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #8D with one byte operand (animation index, 229 sites). ProcessAnimFlag, then UpdateActorAnimation immediately (without yielding) so the first frame's sprite, extents and collision box are set at once, then $2A is cleared again so the animation starts at frame 0 when played. Saves the entry point and continues with RTI.

StageSprAndHitbox {
    TYX 
    LDA [$0A]
    INC $0A               ; StageSprAndHitbox: read anim index
    AND #$00FF
    JSR $&ProcessAnimFlag ; Interpret anim flag: handle flip and store to $28
    JSL $@sprite_composition.UpdateActorAnimation ; Immediately update sprite+hitbox (doesn't yield — single-frame staging)
    STZ $2A               ; Reset frame counter after staging (staging only, not advancing)
    LDA $0C
    STA $02
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}