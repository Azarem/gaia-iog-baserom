; Actor pool infrastructure — slot allocation, linked-list management and state copying (Bank $00, 11 routines).
; 
; ActorPoolAllocator (JSL; needs D = 0 because it reads the DP pointer ($4E)) pops the next free slot from a LIFO free list of slot addresses. The list lives in page $0E (InitActorPool builds it at $0E00, 84 entries of $30-byte slots from $1000). Carry clear + Y = new slot base ($1000 + index×$30), or carry set + Y = $1FC0 when exhausted (a negative entry marks the end). It increments activeActorCount.
; 
; AllocateActorBefore/After allocate with D temporarily 0, splice the new slot into the doubly-linked actor list ($04 = prev, $06 = next, head/tail in $56/$58) before or after the current actor (X = D = current), then call CopyActorState. UnlinkActor removes the actor at X from the list and calls ReturnActorSlot, which pushes the slot back on the free list and decrements the counters. It must be entered with D = X (the actor being freed); Die, MarkDeath, KillPrev and KillNext all arrange that.
; 
; CopyActorState (spawner X = D, new actor Y) copies $0E, $10, $12, the X/Y position, animation index and frame counter, the spriteset/metasprite/stats pointers and the spriteset bank. It forces $2000 on in $10 and clears $0803 there, clears $1000 in $12 (the display-filter flag), and stores the spawner's slot in $0024 (OQ-65). It zeroes parentId, the $2C/$2E movement chain pointers, moveScratch1/2, the $08 timer and chatPtr, and, except in scene $FF (inventory), also extendedFlags and the callback fields.
; 
; MarkChildActor sets the new actor's parentId to the spawner's parentId, or to the spawner's own slot if it has none. SetActorBody applies the current characterForm's body_table entry (6 bytes per form) to the actor's spriteset pointer and bank and clears playerFlags bit $8000 (sprite override). AnimFrameLookup returns the word at move_chain_table[A×2], the head pointer of a movement delta chain; its callers are the force-move COP handlers. AllocateSpecialActor appends a slot from the thinker pool to the thinker list (tail in $5C). PaletteResetAndKillThinker is a thinker script body: COP PaletteRestart, PaletteStep, KillThinker.
---------------------------------------------

?BANK 00

?INCLUDE 'actor_execution'
?INCLUDE 'body_table'
?INCLUDE 'move_chain_table'

!actorListFirst                 0056
!actorListLast                  0058
!sceneCurrent                   0644
!playerFlags                    09AE
!characterForm                  0AD4
!activeActorCount               0DBC
!spritesetPtr                   7F0006
!chatPtr                        7F000A
!metaspritePtr                  7F000C
!parentId                       7F001C
!statsPtr                       7F0020
!extendedFlags                  7F002A
!moveScratch1                   7F002C
!moveScratch2                   7F002E
!onHitCallback                  7F1000
!onDodgeCallback                7F1002
!onDeathCallback                7F1004
!onCollideCallback              7F1008
!scratch1010                    7F1010
!free101C                       7F101C
!chainDamage                    7F101E

---------------------------------------------

; Internal JSR helper that removes the actor at X from the scene's doubly-linked list ($04 previous, $06 next).
; 
; Patches the neighbours and the head/tail pointers at $56/$58, then calls ReturnActorSlot. Must be entered with D = X: ReturnActorSlot zeroes D and then sets D = X again. Callers: Die and MarkDeath (the actor itself), KillPrev and KillNext (they switch D and X to the victim first). Removing a sole list entry leaves actorListLast ($58) stale (OQ-66).

UnlinkActor {
    LDY $0004, X          ; Load prev pointer of actor being removed
    BNE loc_00AF55        ; No prev → actor is the list head; update $0056
    LDY $0006, X          ; Load next pointer to become new head
    STY $actorListFirst   ; New list head = removed actor's next
    BEQ loc_00AF69
    LDA #$0000            ; New head has no prev → zero its $0004
    STA $0004, Y
    BRA loc_00AF69

  loc_00AF55:
    LDA $0006, X          ; Mid/tail removal: get removed actor's next
    STA $0006, Y          ; Patch: prev.next → removed.next (splice around removed)
    BNE loc_00AF62        ; If removed.next is null, prev becomes the new tail
    STY $actorListLast    ; Update list tail ($0058) to prev actor
    BRA loc_00AF69

  loc_00AF62:
    TAY                   ; Y = removed.next for the reverse patch
    LDA $0004, X          ; Get removed.prev
    STA $0004, Y          ; Patch: next.prev → removed.prev (complete doubly-linked splice)

  loc_00AF69:
    JSR $&ReturnActorSlot
    RTS 
}

---------------------------------------------
; Apply the current characterForm's body_table entry to actor X (JSR helper).
; 
; Index = form × 6 (each body_table entry is 6 bytes). Writes the spriteset pointer ($7F0006) and bank ($7F0008), then clears playerFlags bit $8000, the sprite-override flag (set by SetPlayerSpriteDirect, see GetPlayerFacingDirection).

SetActorBody {
    LDA $characterForm    ; Load characterForm (0=Will, 1=Freedan, 2=Shadow)
    ASL                   ; Index = form × 6 (each body_table entry is 6 bytes: ptr+bank+pad)
    CLC 
    ADC $characterForm
    ASL 
    TAY 
    LDA $&body_table, Y   ; Load spriteset pointer word from body_table[form]
    STA $spritesetPtr, X  ; Write spriteset pointer to actor $7F0006
    LDA $&body_table+2, Y ; Load bank byte from body_table[form]+2
    AND #$00FF
    STA $7F0008, X        ; Write spriteset bank to actor $7F0008
    LDA #$8000
    TRB $playerFlags      ; Clear playerFlags bit $8000 (player sprite override)
    RTS 
}
---------------------------------------------

; Internal JSR helper: A = movement index → A = move_chain_table[A×2].
; 
; The returned word is the head pointer of a movement delta chain (a linked list of signed per-frame deltas), not a frame duration. Callers store it in $2C (X chain) or $2E (Y chain): StageMoveX/Y/XY, ForceDirSW/NE/Both and ReloadMoveDurations in cop_handlers_force_move.

AnimFrameLookup {
    ASL                   ; Double index for word-sized table access (move_chain_table)
    TAY 
    LDA $&move_chain_table, Y ; Load the movement delta chain head pointer from move_chain_table[index] (not a frame duration)
    RTS 
}

---------------------------------------------
; Allocate a slot and insert it before the current actor (X = D = current), then CopyActorState.
; 
; Returns Y = new actor. If the pool is exhausted (carry set from the allocator) nothing is linked and the routine returns at once.

AllocateActorBefore {
    PHD 
    LDA #$0000
    TCD 
    JSL $@ActorPoolAllocator ; Allocate slot from LIFO free list; Y=new WRAM base
    PLD 
    BCS loc_00B188        ; Allocation failed → return without inserting
    TXA                   ; new.next ($0006) = current actor X (insert before current)
    STA $0006, Y
    LDA $04               ; new.prev ($0004) = current.prev (inherit link)
    STA $0004, Y
    TYA 
    STA $04               ; current.prev ($04) = new actor Y (link update)
    PHX 
    LDX $0004, Y          ; Check if new actor's prev exists (was current's prev)
    BNE loc_00B180        ; Prev exists → patch prev.next = new actor
    STY $actorListFirst   ; No prev → new actor is the new list head ($0056)
    BRA loc_00B184

  loc_00B180:
    TYA 
    STA $0006, X          ; Patch: old prev.next = new actor

  loc_00B184:
    PLX 
    JSR $&CopyActorState

  loc_00B188:
    RTS 
}

---------------------------------------------
; Allocate a slot and insert it after the current actor (X = D = current), then CopyActorState.
; 
; Returns Y = new actor; if the new actor has no next it becomes the list tail ($58). If the pool is exhausted nothing is linked.

AllocateActorAfter {
    PHD 
    LDA #$0000
    TCD 
    JSL $@ActorPoolAllocator ; Allocate slot for spawn-after linked-list insert
    PLD 
    BCS loc_00B1B4        ; Allocation failed → return without inserting
    TXA                   ; new.prev ($0004) = current actor X (insert after current)
    STA $0004, Y
    LDA $06               ; new.next ($0006) = current.next (inherit link)
    STA $0006, Y
    TYA 
    STA $06               ; current.next ($06) = new actor Y (link update)
    PHX 
    LDX $0006, Y          ; Check if new actor's next exists (was current's next)
    BEQ loc_00B1AD        ; No next → new actor is the new list tail ($0058)
    TYA 
    STA $0004, X          ; Patch: old next.prev = new actor
    BRA loc_00B1B0

  loc_00B1AD:
    STY $actorListLast    ; Update list tail to new actor

  loc_00B1B0:
    PLX 
    JSR $&CopyActorState

  loc_00B1B4:
    RTS 
}

---------------------------------------------
; Push actor slot X back on the free list and decrement the counters (JSR; D must equal X).
; 
; Zeroes D so the free-list pointer ($4E) can be used as [$4E], backs the pointer up by 2 with an 8-bit DEC (no borrow; safe because the whole list sits inside page $0E), decrements activeActorCount, stores X into the freed entry and finally sets D = X again, undoing its own TCD #0.

ReturnActorSlot {
    LDA #$0000            ; Zero DP for free list field access
    TCD 
    SEP #$20
    DEC $004E             ; Back up the free list pointer by 2 (8-bit DEC; the list sits inside page $0E, so no borrow)
    DEC $004E
    DEC $activeActorCount ; Decrement global active actor count
    REP #$20
    TXA 
    STA [$4E]             ; Push freed actor address back onto free list
    TCD                   ; D = X again: undo TCD #0 above (D was the freed actor on entry)
    RTS 
}

---------------------------------------------
; Set the new actor's (Y) parentId: the spawner's (X) parentId if non-zero, otherwise the spawner's own slot (TDC).
; 
; Returns with X = D = the spawner again.

MarkChildActor {
    LDA $parentId, X      ; Load spawner's parentId — inherit parent chain if spawner is already a child
    BNE loc_00B1D2        ; Nonzero = spawner has a parent → use it as the child's parent too
    TDC                   ; No parent chain → spawner's own DP (TDC) becomes the parent ID

  loc_00B1D2:
    TYX 
    STA $parentId, X      ; Write parent ID to new actor's parentId ($7F001C)
    TDC                   ; Restore X to caller's actor for subsequent operations
    TAX 
    RTS 
}

---------------------------------------------
; Initialise the new actor Y from the spawner X (= D). See the file header for the field list.
; 
; $10: ORA #$2000 forces that bit on and AND #$F7FC clears $0803 (bit meanings: OQ-60). $12: clears $1000 (runs in display-filter mode). $0024 receives the spawner's slot (OQ-65). Zeroes parentId, $2C/$2E, moveScratch1/2, $08 and chatPtr; extendedFlags and the callback block are zeroed only when sceneCurrent ≠ $FF.

CopyActorState {
    PHX 
    LDA $0E
    STA $000E, Y
    LDA $10
    ORA #$2000            ; Force $2000 on (not 'preserve'); AND #$F7FC below clears $0803 (OQ-60)
    AND #$F7FC            ; Clear bits on new actor: movement flags and animation-active bits
    STA $0010, Y
    LDA $12
    AND #$EFFF            ; Clear $1000 in $12: the new actor does not inherit the display-filter run flag
    STA $0012, Y
    LDA $14               ; Copy X pixel position from spawner to new actor
    STA $0014, Y
    LDA $16               ; Copy Y pixel position
    STA $0016, Y
    LDA $28               ; Copy animation index ($28)
    STA $0028, Y
    LDA $2A               ; Copy frame counter ($2A)
    STA $002A, Y
    TXA 
    STA $0024, Y          ; $0024 = spawner's slot (scripts later use $24 as scratch; reader of the initial value unknown, OQ-65)
    LDA $statsPtr, X      ; Copy statsPtr, metaspritePtr, spritesetPtr via stack (cross-actor copy)
    PHA 
    LDA $metaspritePtr, X
    PHA 
    LDA $spritesetPtr, X
    PHA 
    LDA $7F0008, X
    TYX 
    STA $7F0008, X
    PLA 
    STA $spritesetPtr, X
    PLA 
    STA $metaspritePtr, X
    PLA 
    STA $statsPtr, X
    LDA #$0000            ; Zero all dynamic fields: parentId, movement deltas, frame timer, chatPtr
    STA $parentId, X
    STA $002C, X
    STA $002E, X
    STA $moveScratch1, X
    STA $moveScratch2, X
    STA $0008, X
    STA $chatPtr, X
    LDA $sceneCurrent     ; Scene $FF (inventory): keep extendedFlags and callbacks (inferred, see InitActorPool note)
    CMP #$00FF
    BEQ loc_00B279
    LDA #$0000
    STA $extendedFlags, X
    STA $onHitCallback, X
    STA $onDodgeCallback, X
    STA $onDeathCallback, X
    STA $onCollideCallback, X
    STA $scratch1010+6, X
    STA $free101C, X
    STA $chainDamage, X

  loc_00B279:
    PLX 
    RTS 
}

---------------------------------------------
; Allocate a thinker slot (ThinkerPoolAlloc) and append it to the thinker list (tail in $5C); returns Y = new thinker.
; 
; No CopyActorState: only prev/next are linked and $06/$08 are zeroed. Allocation failure (carry set) returns without linking.

AllocateSpecialActor {
    PHD 
    LDA #$0000
    TCD 
    JSL $@actor_execution.ThinkerPoolAlloc ; Allocate from thinker-specific pool (separate from scene actor pool)
    BCS loc_00B29D        ; Allocation failed → return
    LDX $005C             ; Load thinker list tail ($005C)
    TXA 
    STA $0004, Y          ; Link: new thinker.prev = old tail
    LDA #$0000            ; Zero frame counter ($0008) and next pointer ($0006) for new thinker
    STA $0008, Y
    STA $0006, Y
    TYA 
    STA $0006, X          ; Old tail.next = new thinker
    STY $005C             ; Update thinker list tail to new thinker

  loc_00B29D:
    PLD 
    RTS 
}
---------------------------------------------

; Internal JSL/JSR allocator that pops the next free actor slot from the LIFO free list at ($4E). On success returns carry clear with Y = new actor WRAM base ($1000 + index×$30) and zeroes the free-list entry; on pool exhaustion returns carry set with Y = $1FC0. Increments activeActorCount on allocation. Called by SpawnSceneActors, AllocateActorBefore/After, and SpawnBefore/After COP handlers.

ActorPoolAllocator {
    LDA ($4E)             ; Next free entry; a negative word is the end sentinel (pool exhausted)
    BMI loc_00B514
    TAY 
    LDA #$0000            ; Zero the popped entry (the slot is now taken)
    STA ($4E)
    INC $4E
    INC $4E
    INC $activeActorCount ; One more active actor
    CLC 
    RTL 

  loc_00B514:
    LDY #$1FC0
    SEC 
    RTL 
}

---------------------------------------------
; Thinker script body (spawned with COP SpawnThinkerParam, about a dozen callers): COP PaletteRestart, PaletteStep, then KillThinker.
; 
; Resets the palette fade machinery for one frame and removes the thinker.

PaletteResetAndKillThinker {
    COP [PaletteRestart]
    COP [PaletteStep]
    COP [KillThinker]
    RTL 
}