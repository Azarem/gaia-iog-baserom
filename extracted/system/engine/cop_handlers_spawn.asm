; COP handlers for actor spawning — the full SpawnBefore/After/Abs/Offset/Marked family plus list append (Bank $00, 14 COP handlers).
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
    TYX                   ; Restore caller's actor ID in X for AllocateActorBefore
    JSR $&actor_pool.AllocateActorBefore ; AllocateActorBefore: insert new slot, CopyActorState from spawner
    LDA [$0A]             ; Read entry pointer word (operands 1–2) from script stream [$0A]
    INC $0A
    INC $0A
    STA $0000, Y          ; Write entry pointer low word to new actor $0000
    LDA [$0A]             ; Read bank byte (operand 3) from script stream
    INC $0A
    AND #$00FF            ; Mask to byte — bank is bits 0–7 only
    STA $0002, Y          ; Write entry bank byte to new actor $0002
    LDA $0A               ; Load script pointer (now past all operands)
    STA $02, S            ; Update COP return PC on stack — script resumes past operands on RTI
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
    STA $0010, Y          ; SpawnBeforeFlags: write initial status flags to new actor $0010
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #9B with one Address operand. Calls AllocateActorAfter (list insert + CopyActorState), then sets the new actor script entry pointer from the operand.

SpawnAfter {
    TYX 
    JSR $&actor_pool.AllocateActorAfter ; SpawnAfter: AllocateActorAfter inserts after current actor
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
    STA $0010, Y          ; SpawnAfterFlags: status flags → new actor $0010
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
    LDA [$0A]             ; SpawnAfterOffset: read signed X offset word
    INC $0A
    INC $0A
    CLC 
    ADC $0014, Y          ; Add X offset to position inherited from CopyActorState
    STA $0014, Y
    LDA [$0A]             ; Read signed Y offset word (operands 6–7)
    INC $0A
    INC $0A
    CLC 
    ADC $0016, Y          ; Add Y offset to inherited Y position
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
    CLC                   ; SpawnAfterOffsetFlags: X offset + inherited position
    ADC $0014, Y
    STA $0014, Y
    LDA [$0A]
    INC $0A
    INC $0A
    CLC                   ; Y offset + inherited position
    ADC $0016, Y
    STA $0016, Y
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0010, Y          ; Flags → new actor $0010
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
    INC $0A               ; SpawnAfterAbs: absolute X → new actor $0014
    INC $0A
    STA $0014, Y
    LDA [$0A]
    INC $0A               ; Absolute Y → new actor $0016
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
    STA $0014, Y          ; SpawnAfterAbsFlags: absolute X
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0016, Y          ; Absolute Y
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0010, Y          ; Status flags → new actor $0010
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
    LDA #$0040            ; Flag $0040 = parent has marked children (enables cascade death in Die)
    TSB $12               ; Set child flag on spawner's own status word $12
    JSR $&actor_pool.MarkChildActor ; Link parentId from spawner to new actor for group lifecycle
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
    LDA #$0040
    TSB $12               ; Mark spawned actor as child node ($0040 on spawner flags)
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
    TSB $12               ; SpawnAfterAbsMarked: $0040 + MarkChildActor
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
    AND #$00FF            ; Zero-extend signed byte offset to 16-bit for arithmetic
    STA $0002, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080            ; Test sign bit of byte offset ($80+ = negative)
    BEQ loc_00A466
    ORA #$FF00            ; Sign-extend: $80–$FF → $FF80–$FFFF (negative offset)

  loc_00A466:
    CLC 
    ADC $0014, Y          ; Add signed X offset to inherited X position
    STA $0014, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080            ; Test sign bit of Y byte offset
    BEQ loc_00A47C
    ORA #$FF00            ; Sign-extend Y offset for negative values

  loc_00A47C:
    CLC 
    ADC $0016, Y          ; Add signed Y offset to inherited Y position
    STA $0016, Y
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0010, Y
    LDA #$0040
    TSB $12               ; MarkChildActor for group lifecycle tracking
    JSR $&actor_pool.MarkChildActor
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #A5 with one Address, two signed bytes (X/Y offset), and one word (flags). Uses ActorPoolAllocator and appends the new slot at the actor-list tail ($0058), CopyActorState, then applies entry pointer, signed offsets, and flags. On pool exhaustion (carry set) skips all operands without spawning.

SpawnListAppend {
    PHY 
    LDA #$0000            ; Zero DP — ActorPoolAllocator expects DP=0 for pool field access
    TCD 
    JSL $@actor_pool.ActorPoolAllocator ; Allocate from LIFO free list; Y=new WRAM base, carry set=pool exhausted
    BCS loc_00A50A        ; Pool full → skip all operand bytes without spawning
    TYX 
    LDY $0058             ; Load current actor list tail pointer ($0058)
    TXA 
    STA $0006, Y          ; Link: old tail.next ($0006) → new actor
    STA $0058             ; Update global list tail to new actor
    TYA 
    STA $0004, X          ; Link: new actor.prev ($0004) → old tail
    STZ $0006, X          ; New actor.next = null (is the new list tail)
    TXY 
    PLA                   ; Restore spawner actor ID from stack
    TCD                   ; Restore DP to spawner actor base address
    TAX                   ; X = spawner ID as source for CopyActorState
    JSR $&actor_pool.CopyActorState ; CopyActorState: clone spawner fields to new actor
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
    BIT #$0080            ; SpawnListAppend: sign-extend X byte offset
    BEQ loc_00A4DF
    ORA #$FF00            ; Sign-extend X offset for negative values

  loc_00A4DF:
    CLC 
    ADC $0014, Y
    STA $0014, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080            ; Test sign bit of Y byte offset
    BEQ loc_00A4F5
    ORA #$FF00            ; Sign-extend Y offset for negative values

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
    PLA                   ; Pool exhaustion path: restore spawner DP
    TCD 
    TAX 
    LDA [$0A]             ; Read-and-discard all operand bytes (entry ptr + bank + offsets + flags)
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
    LDA #$0000            ; Zero DP for ActorPoolAllocator
    TCD 
    JSL $@actor_pool.ActorPoolAllocator ; Allocate slot; carry set on pool exhaustion
    BCS loc_00A5AE        ; Pool full → skip all operands (including extra anim index byte)
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
    AND #$00FF            ; Mask animation index byte from operand
    STA $0028, Y          ; Store animation index to new actor $0028 (sprite frame)
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
    PLA                   ; Pool exhaustion: discard entry+bank+anim+offsets+flags
    TCD 
    TAX 
    LDA [$0A]             ; Read-and-discard all operands (entry + bank + anim + offsets + flags)
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