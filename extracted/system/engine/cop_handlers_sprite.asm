; COP handlers for generic sprite staging, animation control, and metasprite assignment (Bank $00, 16 COP handlers + 1 internal routine).
; 
; ResetSpriteState initializes animation index ($28), frame counter ($2A), and spriteset pointer ($24). AdvanceSpriteAnim steps through animation frames using the spriteset table.
; 
; StageSpr and its axis variants (StageSprX/Y/XY) set the animation frame and optionally compute movement durations via AnimFrameLookup. StageSprLoop variants add a repeat timer via sprTimer. ProcessAnimFlag is the shared internal helper that interprets the animation flag byte, handles direction-based flip ($4000), and writes to the animation index.
; 
; SetMetasprite points the actor at a metasprite table entry with bank byte. AnimOnce/AnimLoop/AnimOneFrame/WaitForAnimFrame control animation playback — AnimOnce yields until complete, AnimLoop repeats with a timer, WaitForAnimFrame yields until a specific frame index is reached. StageSprAndHitbox combines sprite staging with hitbox update via UpdateActorAnimation.
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

; COP #55 (script name ResetSpriteInit) sprite/animation reset taking one byte and one word operand. Stores the animation index in $28, clears the frame counter $2A, and sets the spriteset/script bank pointer $24. Does not advance animation itself — it reinitializes state before StageSpr/AnimOnce sequences.

ResetSpriteState {
    TYX 
    LDA [$0A]             ; Read animation index byte operand
    INC $0A
    AND #$00FF
    STA $28               ; Store anim index to $28; clear counter $2A
    STZ $2A               ; Clear frame counter $2A (start animation from frame 0)
    LDA [$0A]             ; Read spriteset pointer word operand
    INC $0A
    INC $0A
    STA $24               ; Store spriteset data pointer to $24
    LDA $0C
    STA $02
    LDA $0A
    STA $00               ; Save script pointer to actor $00 (entry point cache)
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #56 with no operands. Indexes the spriteset table by anim index ($28) and frame counter ($2A), stages sprite-tile DMA via animScratch, and RTL while DMA is pending ($00B2); clears $2A and RTI when the frame sequence ends (negative entry).

AdvanceSpriteAnim {
    TYX 
    LDA $00B2             ; Check if VRAM DMA is pending — cannot stage new tiles until transfer completes
    BEQ loc_0099FE        ; No DMA pending ($00B2 = 0): continue to process next animation frame
    PLA                   ; DMA pending: pop COP frame and yield RTL until next VBlank
    PLA 
    RTL 

  loc_0099FE:
    PHB                   ; Save data bank before switching to spriteset bank
    LDA $24               ; Load spriteset base address into DMA staging destination ($00B0)
    STA $00B0
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
    ASL                   ; ×4: each frame entry is 4 bytes (tile source + metasprite ptr)
    ASL 
    CLC 
    ADC $0000, Y          ; Add sequence base → Y = current frame data address
    TAY 
    LDA $0000, Y          ; Read frame data word — negative = end-of-sequence sentinel
    BMI loc_009A5F        ; Negative: animation complete → reset counter and RTI
    STA $08               ; Store frame tile offset in $08
    LDA $0002, Y          ; Metasprite data pointer from frame entry word 2
    TAY 
    LDA $0012, Y          ; Read sprite tile index from metasprite header
    AND #$00FF
    ASL                   ; ASL ×5 = ×32 bytes per SNES 4bpp tile
    ASL 
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $animScratch, X   ; Add animScratch tile base → source ROM address for DMA
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

; COP #80 with one byte operand (animation index). Calls ProcessAnimFlag to set $28 (with optional horizontal flip on $0E) and refreshes script bank/pointer fields from $0C/$0A.

StageSpr {
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
; COP #81 with two byte operands (animation index, X distance). Runs ProcessAnimFlag, stores X distance in moveXAlt, and sets frame duration $2C via AnimFrameLookup.

StageSprX {
    TYX 
    LDA [$0A]
    INC $0A               ; StageSprX: read anim byte
    AND #$00FF
    JSR $&ProcessAnimFlag
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveXAlt, X      ; Store X movement distance in moveXAlt ($7F0018)
    JSR $&actor_pool.AnimFrameLookup ; Look up frame duration from movement_delta_table
    STA $2C               ; Store X-axis frame duration to $2C
    LDA $0C
    STA $02
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #82 with two byte operands (animation index, Y distance). Runs ProcessAnimFlag, stores Y distance in moveYAlt, and sets frame duration $2E via AnimFrameLookup.

StageSprY {
    TYX 
    LDA [$0A]
    INC $0A               ; StageSprY: read anim byte
    AND #$00FF
    JSR $&ProcessAnimFlag
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveYAlt, X      ; Store Y movement distance in moveYAlt ($7F001A)
    JSR $&actor_pool.AnimFrameLookup ; Look up Y frame duration
    STA $2E               ; Store Y-axis frame duration to $2E
    LDA $0C
    STA $02
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #83 with three byte operands (animation index, X distance, Y distance). Runs ProcessAnimFlag and AnimFrameLookup for both axes, setting $2C and $2E.

StageSprXY {
    TYX 
    LDA [$0A]
    INC $0A               ; StageSprXY: read anim byte
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
; COP #84 with two byte operands (animation index, loop count). Runs ProcessAnimFlag and stores the loop count in sprTimer for use by AnimLoop.

StageSprLoop {
    TYX 
    LDA [$0A]
    INC $0A               ; StageSprLoop: read anim byte
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
; COP #85 with three byte operands (animation index, loop count, X distance). Runs ProcessAnimFlag, sets sprTimer, stores moveXAlt, and computes $2C via AnimFrameLookup.

StageSprLoopX {
    TYX 
    LDA [$0A]
    INC $0A               ; StageSprLoopX: read anim byte + loop + X distance
    AND #$00FF
    JSR $&ProcessAnimFlag
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $sprTimer, X
    LDA [$0A]             ; sprTimer: repeat count
    INC $0A
    AND #$00FF            ; moveXAlt: X distance
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
; COP #86 with three byte operands (animation index, loop count, Y distance). Runs ProcessAnimFlag, sets sprTimer, stores moveYAlt, and computes $2E via AnimFrameLookup.

StageSprLoopY {
    TYX 
    LDA [$0A]
    INC $0A               ; StageSprLoopY: read anim byte + loop + Y distance
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
; COP #87 with four byte operands (animation index, loop count, X distance, Y distance). Runs ProcessAnimFlag, sets sprTimer, and computes both $2C and $2E via AnimFrameLookup.

StageSprLoopXY {
    TYX 
    LDA [$0A]
    INC $0A               ; StageSprLoopXY: all four operands
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
; Internal JSR helper shared by all StageSpr variants. Clears frame counter $2A, then interprets the animation index byte: $FF leaves $28 unchanged (no-op), bit $80 set masks to the low 7 bits and conditionally sets horizontal flip ($4000 on $0E) based on actor flag $0002, and all other values store directly to $28 while clearing the flip bit. Returns via RTS.

ProcessAnimFlag {
    STZ $2A               ; Clear frame counter — new stage always starts at frame 0
    CMP #$00FF            ; $FF = no-op: keep current animation index unchanged
    BNE loc_009F67
    RTS 

  loc_009F67:
    BIT #$0080            ; Bit 7 set = direction-aware flip mode
    BEQ loc_009F7F
    AND #$FF7F            ; Mask off bit 7 → actual animation index
    STA $28               ; Store direction-aware animation index to $28
    LDA $12               ; Check actor direction flag $0002 on secondary status $12
    BIT #$0002            ; Bit 2 set → facing right: leave flip state as-is
    BEQ loc_009F79
    RTS 

  loc_009F79:
    LDA #$4000            ; Facing left: set horizontal flip $4000 on OAM attributes $0E
    TSB $0E
    RTS 

  loc_009F7F:
    STA $28               ; Normal mode: store index directly to $28
    LDA $12
    BIT #$0002            ; Check direction flag for normal mode
    BEQ loc_009F89
    RTS 

  loc_009F89:
    LDA #$4000            ; Normal facing: clear horizontal flip $4000 on $0E
    TRB $0E
    RTS 
}

---------------------------------------------
; COP #88 with one word plus one byte operand. Sets spritesetPtr ($7F0006) and spriteset bank ($7F0008) to point the actor at a new metasprite table.

SetMetasprite {
    TYX 
    LDA [$0A]             ; Read spriteset pointer word
    INC $0A
    INC $0A
    STA $spritesetPtr, X  ; Write new spriteset pointer to actor $7F0006
    LDA [$0A]             ; Read bank byte for spriteset
    INC $0A
    AND #$00FF
    STA $7F0008, X        ; Write spriteset bank to actor $7F0008
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #89 with no operands. Calls UpdateActorAnimation each frame, yielding RTL while animation is in progress; on completion clears movement deltas $2C/$2E and RTI.

AnimOnce {
    TYX 
    JSL $@sprite_composition.UpdateActorAnimation ; Update animation; carry set = sequence completed this frame
    BCC loc_009FBD        ; Carry set → animation done: clear movement deltas and resume
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
; COP #8A with no operands. Repeats UpdateActorAnimation until a cycle completes, then decrements sprTimer and loops the animation until the timer reaches zero before clearing deltas and continuing.

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
; COP #8B with no operands. Calls UpdateActorAnimation once and always RTI; clears $2C/$2E if the animation sequence finished that frame.

AnimOneFrame {
    TYX 
    JSL $@sprite_composition.UpdateActorAnimation ; Update animation once this frame (single-step)
    BCC loc_009FEC        ; Carry set = finished: clear deltas
    LDA #$0000
    STA $2C
    STA $2E

  loc_009FEC:
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #8C with one byte operand (target frame index). Updates animation each call and yields RTL until frame counter $2A matches the operand, then RTI.

WaitForAnimFrame {
    TYX 
    JSL $@sprite_composition.UpdateActorAnimation ; Update animation
    BCC loc_00A00B        ; Carry set = animation ended before target frame — clear deltas and skip
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
    CMP $2A               ; Compare current frame counter ($2A) vs target
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
; COP #8D with one byte operand (animation index). Runs ProcessAnimFlag, immediately calls UpdateActorAnimation to refresh sprite and hitbox data, resets $2A to zero, and updates script bank/pointer fields.

StageSprAndHitbox {
    TYX 
    LDA [$0A]
    INC $0A               ; StageSprAndHitbox: read anim index
    AND #$00FF
    JSR $&ProcessAnimFlag ; ProcessAnimFlag + immediate UpdateActorAnimation
    JSL $@sprite_composition.UpdateActorAnimation ; Immediately update sprite+hitbox (doesn't yield — single-frame staging)
    STZ $2A               ; Reset frame counter after staging (staging only, not advancing)
    LDA $0C
    STA $02
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}