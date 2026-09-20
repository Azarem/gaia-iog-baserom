?BANK 00

?INCLUDE 'actor_pool'

!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

; COP #AA with one byte operand (movement index). Stores it in moveXAlt and sets animation frame duration at actor+$2C via AnimFrameLookup.

StageMoveX {
    TYX 
    LDA [$0A]             ; Read X movement index byte
    INC $0A
    AND #$00FF
    STA $moveXAlt, X      ; Store to moveXAlt ($7F0018)
    JSR $&actor_pool.AnimFrameLookup ; Compute frame duration from movement delta table
    STA $2C               ; Store X frame duration to $2C
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #AB with one byte operand (movement index). Stores it in moveYAlt and sets animation frame duration at actor+$2E via AnimFrameLookup.

StageMoveY {
    TYX 
    LDA [$0A]             ; Read Y movement index byte
    INC $0A               ; Advance script pointer past Y index byte
    AND #$00FF
    STA $moveYAlt, X      ; Store to moveYAlt ($7F001A)
    JSR $&actor_pool.AnimFrameLookup ; Compute Y frame duration
    STA $2E               ; Store to $2E
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #AC with two byte operands (X index, Y index). Stages both moveXAlt/moveYAlt and refreshes frame durations at $2C and $2E via AnimFrameLookup.

StageMoveXY {
    TYX 
    LDA [$0A]
    INC $0A               ; Advance script pointer past X index byte
    AND #$00FF
    STA $moveXAlt, X
    JSR $&actor_pool.AnimFrameLookup ; AnimFrameLookup for X -> $2C
    STA $2C
    LDA [$0A]
    INC $0A               ; Advance script pointer past Y index byte
    AND #$00FF
    STA $moveYAlt, X
    JSR $&actor_pool.AnimFrameLookup ; AnimFrameLookup for Y -> $2E
    STA $2E
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #AD with one byte operand (nonzero sets, zero clears). TSB or TRB bit $4000 on actor flags $12 to force or release southwest-facing direction.

ForceDirSW {
    TYX 
    LDA [$0A]
    INC $0A               ; Advance script pointer past facing flag operand
    AND #$00FF
    BEQ loc_00A727
    LDA #$4000
    TSB $12
    LDA $0A
    STA $02, S
    RTI 

  loc_00A727:
    LDA #$4000
    TRB $12
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #AE with one byte operand (nonzero sets, zero clears). TSB or TRB bit $2000 on actor flags $12 to force or release northeast-facing direction.

ForceDirNE {
    TYX 
    LDA [$0A]
    INC $0A               ; Advance script pointer past NE facing flag operand
    AND #$00FF
    BEQ loc_00A745
    LDA #$2000
    TSB $12
    LDA $0A
    STA $02, S
    RTI 

  loc_00A745:
    LDA #$2000
    TRB $12
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #AF with one byte operand (nonzero sets, zero clears). TSB or TRB bits $6000 on actor flags $12 to force or release both diagonal direction bits.

ForceDirBoth {
    TYX 
    LDA [$0A]
    INC $0A               ; Advance script pointer past diagonal flag operand
    AND #$00FF
    BEQ loc_00A763
    LDA #$6000
    TSB $12
    LDA $0A
    STA $02, S
    RTI 

  loc_00A763:
    LDA #$6000
    TRB $12
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #B0 with two byte operands (X index, Y index). Stages movement indices and AnimFrameLookup durations on the tail child actor referenced by $0058.

ApplyMoveToChild {
    PHY 
    LDX $0058             ; Load child actor tail pointer ($0058) for movement propagation
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveXAlt, X      ; Store X move to child's moveXAlt
    JSR $&actor_pool.AnimFrameLookup ; Compute child's X frame duration
    STA $002C, X
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveYAlt, X      ; Store Y move to child's moveYAlt
    JSR $&actor_pool.AnimFrameLookup ; Compute child's Y frame duration
    STA $002E, X
    PLX 
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #B1 with no operands. Re-runs AnimFrameLookup for the current moveXAlt and moveYAlt values, refreshing frame durations at actor+$2C and +$2E.

ReloadMoveDurations {
    TYX 
    LDA $moveXAlt, X      ; Re-read current moveXAlt (index unchanged)
    JSR $&actor_pool.AnimFrameLookup ; Recompute X frame duration
    STA $002C, X
    LDA $moveYAlt, X      ; Re-read current moveYAlt
    JSR $&actor_pool.AnimFrameLookup ; Recompute Y frame duration
    STA $002E, X
    LDA $0A
    STA $02, S
    RTI 
}