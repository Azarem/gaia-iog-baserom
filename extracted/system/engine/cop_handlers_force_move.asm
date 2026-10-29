; Force-move COP handlers ($AA–$B1, 8 opcodes): stage movement delta chains and flip movement direction.
; 
; A movement index (0-$54) selects a delta chain in move_chain_table: a linked list of nodes, each a signed per-frame delta plus a link to the next node. StageMoveX/Y/XY store the index in moveXAlt/moveYAlt ($7F:0018/$7F:001A + actor slot) and put the chain pointer that AnimFrameLookup returns in actor field $2C (X chain) or $2E (Y chain); ApplyMovement and the collision-checked move in tile_collision_physics consume one node per frame from each chain.
; 
; SetMoveNegateX/NE/Both set (operand nonzero) or clear (operand 0) $12 bit $4000 (negate the X delta), bit $2000 (negate the Y delta), or both ($6000). ApplyMoveToChild stages both indices on the newest actor in the list ($0058, actorListLast) instead of the caller. ReloadMoveChains re-runs the lookup for the current indices, which rewinds $2C/$2E to the start of their chains.
; 
; Each handler reads its operand bytes through the script pointer [$0A], advances $0A, and writes it back into the stacked return address ($02,S) before RTI. Entry has Y = actor slot (TYX).
---------------------------------------------

?BANK 00

?INCLUDE 'actor_pool'

!actorListLast                  0058
!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

; COP #AA with one byte operand (X movement index). Stores it in moveXAlt and puts the X delta chain pointer for that index (AnimFrameLookup into move_chain_table) in actor field $2C.

StageMoveX {
    TYX 
    LDA [$0A]             ; Read X movement index byte
    INC $0A
    AND #$00FF
    STA $moveXAlt, X      ; moveXAlt = X movement index (move_chain_table entry, $7F0018 + slot)
    JSR $&actor_pool.AnimFrameLookup ; A = pointer to the delta chain for the index
    STA $2C               ; Actor field $2C = X delta chain pointer
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #AB with one byte operand (Y movement index). Stores it in moveYAlt and puts the Y delta chain pointer for that index in actor field $2E.

StageMoveY {
    TYX 
    LDA [$0A]             ; Read Y movement index byte
    INC $0A               ; Advance script pointer past Y index byte
    AND #$00FF
    STA $moveYAlt, X      ; moveYAlt = Y movement index ($7F001A + slot)
    JSR $&actor_pool.AnimFrameLookup ; A = pointer to the Y delta chain
    STA $2E               ; Actor field $2E = Y delta chain pointer
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #AC with two byte operands (X index, Y index). Does StageMoveX then StageMoveY: stores moveXAlt/moveYAlt and loads the delta chain pointers into $2C and $2E.

StageMoveXY {
    TYX 
    LDA [$0A]
    INC $0A               ; Advance script pointer past X index byte
    AND #$00FF
    STA $moveXAlt, X      ; moveXAlt = X movement index
    JSR $&actor_pool.AnimFrameLookup ; A = X delta chain pointer
    STA $2C               ; $2C = X chain
    LDA [$0A]
    INC $0A               ; Advance script pointer past Y index byte
    AND #$00FF
    STA $moveYAlt, X      ; moveYAlt = Y movement index
    JSR $&actor_pool.AnimFrameLookup ; A = Y delta chain pointer
    STA $2E               ; $2E = Y chain
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #AD with one byte operand (nonzero sets, zero clears). TSB or TRB bit $4000 on actor flags $12: while set, ApplyMovement and the collision-checked move negate the actor's X delta (the copdef name says SW; the effect is an X flip).

SetMoveNegateX {
    TYX 
    LDA [$0A]
    INC $0A               ; Advance script pointer past facing flag operand
    AND #$00FF
    BEQ loc_00A727
    LDA #$4000            ; $4000: negate the X delta
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
; COP #AE with one byte operand (nonzero sets, zero clears). TSB or TRB bit $2000 on actor flags $12: while set, the Y delta is negated (the copdef name says NE; the effect is a Y flip).

SetMoveNegateY {
    TYX 
    LDA [$0A]
    INC $0A               ; Advance script pointer past NE facing flag operand
    AND #$00FF
    BEQ loc_00A745
    LDA #$2000            ; $2000: negate the Y delta
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
; COP #AF with one byte operand (nonzero sets, zero clears). TSB or TRB bits $6000 on actor flags $12: negates both the X and Y deltas (reverses the staged movement).

SetMoveNegateXY {
    TYX 
    LDA [$0A]
    INC $0A               ; Advance script pointer past diagonal flag operand
    AND #$00FF
    BEQ loc_00A763
    LDA #$6000            ; $6000: negate both deltas
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
; COP #B0 with two byte operands (X index, Y index). Same staging as StageMoveXY, but written to the newest actor in the list (actorListLast, $0058) rather than the caller, so spawn the child immediately before it. The caller's slot is saved with PHY and restored with PLX.

ApplyMoveToChild {
    PHY                   ; Save the caller's slot (Y = actor at COP entry)
    LDX $actorListLast    ; X = newest actor in the list (actorListLast, $0058), not the caller
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveXAlt, X      ; Child's moveXAlt = X index
    JSR $&actor_pool.AnimFrameLookup ; A = X delta chain pointer
    STA $002C, X          ; Child's $2C = X chain
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveYAlt, X      ; Child's moveYAlt = Y index
    JSR $&actor_pool.AnimFrameLookup ; A = Y delta chain pointer
    STA $002E, X          ; Child's $2E = Y chain
    PLX                   ; Restore X = caller slot (the PHY value)
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #B1 with no operands. Re-runs AnimFrameLookup for the current moveXAlt and moveYAlt and stores the chain pointers in $2C and $2E again, rewinding both chains to their first node.

ReloadMoveChains {
    TYX 
    LDA $moveXAlt, X      ; Current X index (unchanged)
    JSR $&actor_pool.AnimFrameLookup ; A = pointer to the first node of the X chain
    STA $002C, X          ; $2C = rewound X chain
    LDA $moveYAlt, X      ; Current Y index (unchanged)
    JSR $&actor_pool.AnimFrameLookup ; A = pointer to the first node of the Y chain
    STA $002E, X          ; $2E = rewound Y chain
    LDA $0A
    STA $02, S
    RTI 
}