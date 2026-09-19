; COP handlers for actor spawning — the full SpawnBefore/After/Abs/Offset/Marked family plus list append (Bank $00, 14 handlers).
; 
; All spawn handlers allocate a new actor slot via AllocateActorBefore or AllocateActorAfter, then read script operands for entry pointer (word + bank byte), optional position offsets or absolute coordinates, and optional status flags ($0010).
; 
; The Marked variants (SpawnBeforeMarked, SpawnAfterMarked, SpawnAfterAbsMarked, SpawnAfterOffsetMarked) additionally set actor flag $0040 and call MarkChildActor to establish parent–child links for group lifecycle management.
; 
; SpawnListAppend/SpawnListAppendSpr use ActorPoolAllocator to add actors to the tail of the active list. On pool exhaustion they skip all operand bytes without spawning. SpawnListAppendSpr additionally reads an animation index operand for the spawned actor.
---------------------------------------------

?BANK 00

?INCLUDE 'actor_pool'

---------------------------------------------

; COP #99 with one Address operand (word+bank entry pointer). Calls AllocateActorBefore (which inserts a list slot and CopyActorState from the spawner), then writes the script entry address to the new actor $0000/$0002.

SpawnBefore {
    TYX 
    JSR $&actor_pool.AllocateActorBefore
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0000, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0002, Y
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #9A with one Address plus one word operand. Same as SpawnBefore, additionally writing the word operand to the spawned actor status flags ($0010).

SpawnBeforeFlags {
    TYX 
    JSR $&actor_pool.AllocateActorBefore
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0000, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0002, Y
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0010, Y
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #9B with one Address operand. Calls AllocateActorAfter (list insert + CopyActorState), then sets the new actor script entry pointer from the operand.

SpawnAfter {
    TYX 
    JSR $&actor_pool.AllocateActorAfter
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0000, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0002, Y
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #9C with one Address plus one word operand. SpawnAfter plus an initial status-flags word written to $0010.

SpawnAfterFlags {
    TYX 
    JSR $&actor_pool.AllocateActorAfter
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0000, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0002, Y
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0010, Y
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #9D with one Address plus two word operands (X/Y offset). Spawns after the current actor and adds the 16-bit offset words to the new actor $0014/$0016.

SpawnAfterOffset {
    TYX 
    JSR $&actor_pool.AllocateActorAfter
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0000, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0002, Y
    LDA [$0A]
    INC $0A
    INC $0A
    CLC 
    ADC $0014, Y
    STA $0014, Y
    LDA [$0A]
    INC $0A
    INC $0A
    CLC 
    ADC $0016, Y
    STA $0016, Y
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #9E with one Address, two word offsets, and one word (flags). SpawnAfterOffset with an additional status-flags word stored in $0010.

SpawnAfterOffsetFlags {
    TYX 
    JSR $&actor_pool.AllocateActorAfter
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0000, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0002, Y
    LDA [$0A]
    INC $0A
    INC $0A
    CLC 
    ADC $0014, Y
    STA $0014, Y
    LDA [$0A]
    INC $0A
    INC $0A
    CLC 
    ADC $0016, Y
    STA $0016, Y
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0010, Y
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #9F with one Address plus two word operands (absolute X/Y). Spawns after the current actor and assigns $0014/$0016 directly from the operand words.

SpawnAfterAbs {
    TYX 
    JSR $&actor_pool.AllocateActorAfter
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0000, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0002, Y
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0014, Y
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0016, Y
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #A0 with one Address, two words (X/Y), and one word (flags). SpawnAfterAbs with status flags written to $0010.

SpawnAfterAbsFlags {
    TYX 
    JSR $&actor_pool.AllocateActorAfter
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0000, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0002, Y
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0014, Y
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0016, Y
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0010, Y
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #A1 with one Address plus one word (flags). SpawnBeforeFlags variant that also ORs $0040 into the spawner flags ($12) and calls MarkChildActor to link parent and child.

SpawnBeforeMarked {
    TYX 
    JSR $&actor_pool.AllocateActorBefore
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0000, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0002, Y
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0010, Y
    LDA #$0040
    TSB $12
    JSR $&actor_pool.MarkChildActor
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #A2 with one Address plus one word (flags). SpawnAfterFlags variant that sets spawner flag $0040 and calls MarkChildActor for parent–child lifecycle tracking.

SpawnAfterMarked {
    TYX 
    JSR $&actor_pool.AllocateActorAfter
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0000, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0002, Y
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0010, Y
    LDA #$0040            ; TSB #$0040 on $0012: mark spawned actor as child node
    TSB $12
    JSR $&actor_pool.MarkChildActor
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #A3 with one Address, two words (X/Y), and one word (flags). SpawnAfterAbsFlags plus $0040 flag and MarkChildActor.

SpawnAfterAbsMarked {
    TYX 
    JSR $&actor_pool.AllocateActorAfter
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0000, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0002, Y
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0014, Y
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0016, Y
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0010, Y
    LDA #$0040
    TSB $12
    JSR $&actor_pool.MarkChildActor
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #A4 with one Address, two signed bytes (X/Y offset), and one word (flags). Spawns after current actor with sign-extended byte offsets added to $0014/$0016, sets flags, ORs $0040, and calls MarkChildActor.

SpawnAfterOffsetMarked {
    TYX 
    JSR $&actor_pool.AllocateActorAfter
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0000, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0002, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_00A466
    ORA #$FF00

  loc_00A466:
    CLC 
    ADC $0014, Y
    STA $0014, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_00A47C
    ORA #$FF00

  loc_00A47C:
    CLC 
    ADC $0016, Y
    STA $0016, Y
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0010, Y
    LDA #$0040
    TSB $12
    JSR $&actor_pool.MarkChildActor
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #A5 with one Address, two signed bytes (X/Y offset), and one word (flags). Uses ActorPoolAllocator and appends the new slot at the actor-list tail ($0058), CopyActorState, then applies entry pointer, signed offsets, and flags. On pool exhaustion (carry set) skips all operands without spawning.

SpawnListAppend {
    PHY 
    LDA #$0000
    TCD 
    JSL $@actor_pool.ActorPoolAllocator
    BCS loc_00A50A
    TYX 
    LDY $0058
    TXA 
    STA $0006, Y
    STA $0058
    TYA 
    STA $0004, X
    STZ $0006, X
    TXY 
    PLA 
    TCD 
    TAX 
    JSR $&actor_pool.CopyActorState
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0000, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0002, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_00A4DF
    ORA #$FF00

  loc_00A4DF:
    CLC 
    ADC $0014, Y
    STA $0014, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_00A4F5
    ORA #$FF00

  loc_00A4F5:
    CLC 
    ADC $0016, Y
    STA $0016, Y
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0010, Y
    LDA $0A
    STA $02, S
    RTI 

  loc_00A50A:
    PLA 
    TCD 
    TAX 
    LDA [$0A]
    INC $0A
    INC $0A
    LDA [$0A]
    INC $0A
    AND #$00FF
    LDA [$0A]
    INC $0A
    AND #$00FF
    LDA [$0A]
    INC $0A
    AND #$00FF
    LDA [$0A]
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #A6 with one Address, one byte (animation index), two signed bytes (X/Y offset), and one word (flags). Like SpawnListAppend but also stores an animation index byte in the spawned actor $0028; skips one extra operand byte on pool exhaustion.

SpawnListAppendSpr {
    PHY 
    LDA #$0000
    TCD 
    JSL $@actor_pool.ActorPoolAllocator
    BCS loc_00A5AE
    TYX 
    LDY $0058
    TXA 
    STA $0006, Y
    STA $0058
    TYA 
    STA $0004, X
    STZ $0006, X
    TXY 
    PLA 
    TCD 
    TAX 
    JSR $&actor_pool.CopyActorState
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0000, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0002, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0028, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_00A583
    ORA #$FF00

  loc_00A583:
    CLC 
    ADC $0014, Y
    STA $0014, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_00A599
    ORA #$FF00

  loc_00A599:
    CLC 
    ADC $0016, Y
    STA $0016, Y
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0010, Y
    LDA $0A
    STA $02, S
    RTI 

  loc_00A5AE:
    PLA 
    TCD 
    TAX 
    LDA [$0A]
    INC $0A
    INC $0A
    LDA [$0A]
    INC $0A
    AND #$00FF
    LDA [$0A]
    INC $0A
    AND #$00FF
    LDA [$0A]
    INC $0A
    AND #$00FF
    LDA [$0A]
    INC $0A
    AND #$00FF
    LDA [$0A]
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 
}