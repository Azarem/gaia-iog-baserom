; Actor-death COP handlers (Bank $00): MarkDeath (#A7), Die (#E0), KillPrev (#A8) and KillNext (#A9).
; 
; All of them remove an actor from the doubly linked actor list ($04 = prev, $06 = next, list ends in $0056/$0058) through actor_pool.UnlinkActor, which also returns the slot to the free list. MarkDeath and Die first test $12 bit $0040 ("this actor has marked children", set by the Marked spawn COPs): when it is set they take the shared cascade at UnlinkChildrenCascade, which removes the actor together with every adjacent actor whose parentId ($7F001C) equals its slot address. MarkDeath then resumes the script (RTI through MarkDeathResumeHandler); Die ends it (RTL).
; 
; KillPrev and KillNext switch context to the neighbouring actor ($04 / $06) and unlink that actor instead. Neither checks for a null link, so the neighbour must exist.
---------------------------------------------

?BANK 00

?INCLUDE 'actor_pool'

!actorListFirst                 0056
!actorListLast                  0058
!parentId                       7F001C

---------------------------------------------

; COP #A7 with no operands. Unlinks the actor via UnlinkActor; if actor flag bit $0040 on $12 is set, first cascade-unlinks child actors sharing the same parentId, then resumes the calling script via MarkDeathResumeHandler.

MarkDeath {
    TYX 
    PHD                   ; Save direct page before potential child-cascade path
    LDA $12               ; Load actor flags for child-flag test ($0040)
    BIT #$0040            ; Child flag $0040: route through DieExit to cascade-remove children
    BEQ loc_00A5EC
    PEA $&MarkDeathResumeHandler-1 ; Push MarkDeathResumeHandler−1 for RTS-trick return from child cascade
    BRA UnlinkChildrenCascade

  loc_00A5EC:
    JSR $&actor_pool.UnlinkActor ; UnlinkActor: direct removal when no children
}

---------------------------------------------
; PEA/RTS return target reached from MarkDeath when the dying actor has child flag $0040 set.
; 
; Restores the actor's direct page (TCD) and index register (TAX) from the stack after the child-unlinking code in UnlinkChildrenCascade completes, then RTIs to resume the calling script. Separated from MarkDeath because the child-unlinking path is shared with Die via BRA UnlinkChildrenCascade.

MarkDeathResumeHandler {
    PLA                   ; Resume handler: restore DP/X after child-unlinking and continue script
    TAX 
    TCD 
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #E0 with no operands. If actor flag bit $0040 on $12 is set, routes through DieExit to cascade-remove linked child actors by parentId match; otherwise calls UnlinkActor directly. Returns via RTL to terminate the script.

Die {
    TYX 
    PHD 
    LDA $12               ; Test for child flag $0040 on dying actor
    BIT #$0040
    BEQ loc_00A605        ; No children: direct unlink path
    PEA $&DieExit-1       ; Push DieExit−1 for RTS-trick (RTL exit after cascade)
    BRA UnlinkChildrenCascade

  loc_00A605:
    JSR $&actor_pool.UnlinkActor
}

---------------------------------------------
; Cascade child-actor removal for Die/MarkDeath when actor flag $0040 is set.
; 
; The entry point (PLA/TAX/TCD/PLA/PLA/RTL) is the normal non-child Die exit. The shared cascade at UnlinkChildrenCascade walks the doubly-linked actor list backward ($04 pointers) and forward ($06 pointers) from the dying actor, stopping at the first actor on each side whose parentId does not match the dying actor (the backward and forward boundaries). It then returns every slot strictly between the two boundaries (the children and the dying actor itself) via ReturnActorSlot and patches the list pointers with three cases: head-removed (new head = forward boundary), tail-removed (new tail = backward boundary), or mid-list splice (link the boundaries to each other). Finally it points the dying actor's own next pointer ($06) at the forward boundary so the actor run loop continues past the removed span.

DieExit {
    PLA 
    TAX 
    TCD 
    PLA 
    PLA 
    RTL 

; Entry of the child-removal cascade (X = dying actor, reached when actor flag $0040 is set): walks the doubly-linked actor list backward and forward from the dying actor while parentId matches it, returns every slot in that span to the pool with ReturnActorSlot, and patches the list links around the removed span.

  UnlinkChildrenCascade:
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
    LDX $actorListFirst   ; Backward boundary is null: start from list head ($0056)
    JSR $&actor_pool.ReturnActorSlot ; Return the head first (it belongs to the removed span)

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
    STX $actorListFirst
    STZ $0004, X          ; Clear new head's prev pointer
    LDA $03, S            ; Saved D (the dying actor, pushed by PHD in Die/MarkDeath) under the RTS target
    TAX 
    TCD 
    LDA $0004
    STA $06               ; Dying actor's next ($06) = forward boundary: the run loop skips the removed span
    RTS 

  loc_00A675:
    LDA $0004
    BNE loc_00A68A
    LDX $0002             ; Tail removed: backward boundary becomes new tail ($0058)
    STX $actorListLast
    STZ $0006, X          ; Clear new tail's next pointer
    LDA $03, S
    TAX 
    TCD 
    STZ $06               ; No next actor: the run loop ends after this actor
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
    STA $06               ; Dying actor's next ($06) = forward boundary
    RTS 
}

---------------------------------------------
; COP #A8 with no operands. Switches context to the previous linked actor ($04) and unlinks it via UnlinkActor. There is no null check, so the actor must have a prev link.

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
; COP #A9 with no operands. Switches context to the next linked actor ($06) and unlinks it via UnlinkActor. There is no null check, so the actor must have a next link.

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