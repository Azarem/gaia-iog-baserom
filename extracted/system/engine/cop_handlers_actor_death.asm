?BANK 00

?INCLUDE 'actor_pool'

!parentId                       7F001C

---------------------------------------------

; COP #A7 with no operands. Unlinks the actor via UnlinkActor; if actor flag bit $0040 on $12 is set, first cascade-unlinks child actors sharing the same parentId, then resumes the calling script via MarkDeathResumeHandler.

MarkDeath {
    TYX 
    PHD                   ; Save direct page before potential child-cascade path
    LDA $12               ; Load actor flags for child-flag test ($0040)
    BIT #$0040            ; Child flag $0040: route through DieNow_UnlinkChildren to cascade-remove children
    BEQ loc_00A5EC
    PEA $&MarkDeathResumeHandler-1 ; Push MarkDeathResumeHandler−1 for RTS-trick return from child cascade
    BRA loc_00A60E

  loc_00A5EC:
    JSR $&actor_pool.UnlinkActor ; UnlinkActor: direct removal when no children
}

---------------------------------------------
; PEA/RTS return target reached from MarkDeath when the dying actor has child flag $0040 set.
; 
; Restores the actor's direct page (TCD) and index register (TAX) from the stack after the child-unlinking code in loc_00A60E completes, then RTIs to resume the calling script. Separated from MarkDeath because the child-unlinking path is shared with Die via BRA loc_00A60E.

MarkDeathResumeHandler {
    PLA                   ; Resume handler: restore DP/X after child-unlinking and continue script
    TAX 
    TCD 
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #E0 with no operands. If actor flag bit $0040 on $12 is set, routes through DieNow_UnlinkChildren to cascade-remove linked child actors by parentId match; otherwise calls UnlinkActor directly. Returns via RTL to terminate the script.

Die {
    TYX 
    PHD 
    LDA $12               ; Test for child flag $0040 on dying actor
    BIT #$0040
    BEQ loc_00A605        ; No children: direct unlink path
    PEA $&DieNow_UnlinkChildren-1 ; Push DieNow_UnlinkChildren−1 for RTS-trick (RTL exit after cascade)
    BRA loc_00A60E

  loc_00A605:
    JSR $&actor_pool.UnlinkActor
}

---------------------------------------------
; Cascade child-actor removal for Die/MarkDeath when actor flag $0040 is set.
; 
; The entry point (PLA/TAX/TCD/PLA/PLA/RTL) is the normal non-child Die exit. The shared child-removal code at loc_00A60E walks the doubly-linked actor list both backward ($04 pointers) and forward ($06 pointers) from the dying actor, collecting contiguous runs of actors whose parentId matches the dying actor. It then returns all collected child slots via ReturnActorSlot and patches the list pointers with three cases: head-removed (new head = forward boundary), tail-removed (new tail = backward boundary), or mid-list splice (link boundaries to each other).

DieNow_UnlinkChildren {
    PLA 
    TAX 
    TCD 
    PLA 
    PLA 
    RTL 

  loc_00A60E:
    STX $0000             ; Save dying actor pointer to $0000 for parentId matching
    LDA $0004, X          ; Start backward walk: load prev pointer ($04)
    TAX 
    BEQ loc_00A626

  loc_00A617:
    LDA $parentId, X      ; Check if prev actor's parentId matches dying actor
    CMP $0000
    BNE loc_00A626        ; Mismatch: this is the backward boundary (first non-child)
    LDA $0004, X          ; Match: continue walking backward through prev pointers
    TAX 
    BNE loc_00A617

  loc_00A626:
    STX $0002             ; Store backward boundary actor to $0002
    LDX $0000
    LDA $0006, X          ; Start forward walk: load next pointer ($06) from dying actor
    TAX 
    BEQ loc_00A641

  loc_00A632:
    LDA $parentId, X      ; Check if next actor's parentId matches dying actor
    CMP $0000
    BNE loc_00A641        ; Mismatch: forward boundary found
    LDA $0006, X
    TAX 
    BNE loc_00A632

  loc_00A641:
    STX $0004             ; Store forward boundary to $0004
    LDX $0002             ; Start at backward boundary, return all child slots to pool
    BNE loc_00A64F
    LDX $0056             ; Backward boundary is null: start from list head ($0056)
    JSR $&actor_pool.ReturnActorSlot

  loc_00A64F:
    LDA $0006, X          ; Walk forward through next pointers returning each child
    CMP $0004             ; Compare current against forward boundary ($0004)
    BEQ loc_00A65D        ; Reached boundary: stop returning slots
    TAX 
    JSR $&actor_pool.ReturnActorSlot ; Return this child slot to free list
    BRA loc_00A64F

  loc_00A65D:
    LDA $0002             ; Patch linked list: handle head-removed, tail-removed, or mid-splice
    BNE loc_00A675
    LDX $0004             ; Head removed: forward boundary becomes new list head ($0056)
    STX $0056
    STZ $0004, X          ; Clear new head's prev pointer
    LDA $03, S
    TAX 
    TCD 
    LDA $0004
    STA $06
    RTS 

  loc_00A675:
    LDA $0004
    BNE loc_00A68A
    LDX $0002             ; Tail removed: backward boundary becomes new tail ($0058)
    STX $0058
    STZ $0006, X          ; Clear new tail's next pointer
    LDA $03, S
    TAX 
    TCD 
    STZ $06
    RTS 

  loc_00A68A:
    LDY $0004             ; Mid-list splice: link boundaries to each other
    LDA $0002             ; Mid-splice: link forward.prev = backward boundary
    STA $0004, Y          ; Forward boundary's prev = backward boundary
    TAX 
    TYA 
    STA $0006, X          ; Backward boundary's next = forward boundary
    TAY 
    LDA $03, S
    TAX 
    TCD 
    TYA 
    STA $06
    RTS 
}

---------------------------------------------
; COP #A8 with no operands. Switches context to the previous linked actor ($04) and unlinks it via UnlinkActor.

KillPrev {
    PHY 
    LDA $04               ; Load prev pointer for KillPrev
    TCD                   ; Switch DP to prev actor (TCD makes prev's fields accessible)
    TAX 
    JSR $&actor_pool.UnlinkActor ; Unlink the previous actor from the linked list
    PLA                   ; Restore original actor context
    TCD 
    TAX 
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #A9 with no operands. Switches context to the next linked actor ($06) and unlinks it via UnlinkActor.

KillNext {
    PHY 
    LDA $06               ; Load next pointer for KillNext
    TCD 
    TAX 
    JSR $&actor_pool.UnlinkActor ; Unlink the next actor from the linked list
    PLA 
    TCD 
    TAX 
    LDA $0A
    STA $02, S
    RTI 
}