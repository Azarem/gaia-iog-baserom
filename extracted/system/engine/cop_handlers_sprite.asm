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
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $28
    STZ $2A
    LDA [$0A]
    INC $0A
    INC $0A
    STA $24
    LDA $0C
    STA $02
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #56 with no operands. Indexes the spriteset table by anim index ($28) and frame counter ($2A), stages sprite-tile DMA via animScratch, and RTL while DMA is pending ($00B2); clears $2A and RTI when the frame sequence ends (negative entry).

AdvanceSpriteAnim {
    TYX 
    LDA $00B2
    BEQ loc_0099FE
    PLA 
    PLA 
    RTL 

  loc_0099FE:
    PHB 
    LDA $24
    STA $00B0
    SEP #$20
    LDA $7F0008, X
    PHA 
    PLB 
    REP #$20
    LDA $28
    ASL 
    CLC 
    ADC $spritesetPtr, X
    TAY 
    LDA $2A
    INC $2A
    ASL 
    ASL 
    CLC 
    ADC $0000, Y
    TAY 
    LDA $0000, Y
    BMI loc_009A5F
    STA $08
    LDA $0002, Y
    TAY 
    LDA $0012, Y
    AND #$00FF
    ASL 
    ASL 
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $animScratch, X
    STA $00AC
    LDA $animScratch+2, X
    STA $00AE
    LDA #$0020
    STA $00B2
    LDA $000D, Y
    AND #$00FF
    BEQ loc_009A5B
    LDA #$0080
    STA $00B2

  loc_009A5B:
    PLB 
    PLA 
    PLA 
    RTL 

  loc_009A5F:
    STZ $2A
    PLB 
    LDA $0A
    STA $02, S
    RTI 
}
---------------------------------------------

; COP #80 with one byte operand (animation index). Calls ProcessAnimFlag to set $28 (with optional horizontal flip on $0E) and refreshes script bank/pointer fields from $0C/$0A.

StageSpr {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSR $&ProcessAnimFlag
    LDA $0C
    STA $02
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #81 with two byte operands (animation index, X distance). Runs ProcessAnimFlag, stores X distance in moveXAlt, and sets frame duration $2C via AnimFrameLookup.

StageSprX {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSR $&ProcessAnimFlag
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
; COP #82 with two byte operands (animation index, Y distance). Runs ProcessAnimFlag, stores Y distance in moveYAlt, and sets frame duration $2E via AnimFrameLookup.

StageSprY {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSR $&ProcessAnimFlag
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
; COP #83 with three byte operands (animation index, X distance, Y distance). Runs ProcessAnimFlag and AnimFrameLookup for both axes, setting $2C and $2E.

StageSprXY {
    TYX 
    LDA [$0A]
    INC $0A
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
    INC $0A
    AND #$00FF
    JSR $&ProcessAnimFlag
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $sprTimer, X
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
    INC $0A
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
    INC $0A
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
    INC $0A
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
    STZ $2A
    CMP #$00FF
    BNE loc_009F67
    RTS 

  loc_009F67:
    BIT #$0080
    BEQ loc_009F7F
    AND #$FF7F
    STA $28
    LDA $12
    BIT #$0002
    BEQ loc_009F79
    RTS 

  loc_009F79:
    LDA #$4000
    TSB $0E
    RTS 

  loc_009F7F:
    STA $28
    LDA $12
    BIT #$0002
    BEQ loc_009F89
    RTS 

  loc_009F89:
    LDA #$4000
    TRB $0E
    RTS 
}

---------------------------------------------
; COP #88 with one word plus one byte operand. Sets spritesetPtr ($7F0006) and spriteset bank ($7F0008) to point the actor at a new metasprite table.

SetMetasprite {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $spritesetPtr, X
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $7F0008, X
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #89 with no operands. Calls UpdateActorAnimation each frame, yielding RTL while animation is in progress; on completion clears movement deltas $2C/$2E and RTI.

AnimOnce {
    TYX 
    JSL $@sprite_composition.UpdateActorAnimation
    BCC loc_009FBD
    LDA #$0000
    STA $2C
    STA $2E
    LDA $0A
    STA $02, S
    RTI 

  loc_009FBD:
    PLA 
    PLA 
    RTL 
}

---------------------------------------------
; COP #8A with no operands. Repeats UpdateActorAnimation until a cycle completes, then decrements sprTimer and loops the animation until the timer reaches zero before clearing deltas and continuing.

AnimLoop {
    TYX 

  loc_009FC1:
    JSL $@sprite_composition.UpdateActorAnimation
    BCC loc_009FDB
    LDA $sprTimer, X
    DEC 
    STA $sprTimer, X
    BNE loc_009FC1
    STZ $2C
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
    JSL $@sprite_composition.UpdateActorAnimation
    BCC loc_009FEC
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
    JSL $@sprite_composition.UpdateActorAnimation
    BCC loc_00A00B
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
    LDA [$0A]
    INC $0A
    AND #$00FF
    CMP $2A
    BEQ loc_00A019
    PLA 
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
    INC $0A
    AND #$00FF
    JSR $&ProcessAnimFlag
    JSL $@sprite_composition.UpdateActorAnimation
    STZ $2A
    LDA $0C
    STA $02
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}