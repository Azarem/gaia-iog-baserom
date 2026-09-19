; Actor pool infrastructure — slot allocation, linked-list management, and state copying (Bank $00, 12 internal routines).
; 
; ActorPoolAllocator is the core JSL allocator that pops the next free actor slot from the LIFO free list at ($4E). Returns carry clear with Y = new WRAM base ($1000 + index×$30); carry set with Y = $1FC0 on exhaustion. Increments activeActorCount.
; 
; AllocateActorBefore/After insert a new slot into the doubly-linked actor list before or after the current actor, then call CopyActorState. UnlinkActor removes an actor from the list, patching head/tail pointers, and calls ReturnActorSlot. ReturnActorSlot decrements activeActorCount and pushes the slot back onto the free list.
; 
; CopyActorState copies position, animation state, spriteset/metasprite/stats pointers, and flags from the spawning actor. It preserves the thinker bit ($2000), clears render-active ($EFFF), and zeroes callback and movement fields.
; 
; SetActorBody applies the current characterForm's body_table entry to spriteset and bank fields. AnimFrameLookup indexes movement_delta_table to convert animation step indices to frame durations. MarkChildActor sets the parentId link. AllocateSpecialActor allocates from the thinker pool. PaletteResetAndKillThinker is a COP macro that chains PaletteRestart, PaletteStep, and KillThinker.
---------------------------------------------

?BANK 00

?INCLUDE 'actor_execution'
?INCLUDE 'body_table'
?INCLUDE 'movement_delta_table'

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

; Internal JSR helper that removes the actor at X from the scene doubly-linked list ($04 previous, $06 next). Patches head/tail pointers at $56/$58 when removing list ends, then calls ReturnActorSlot to push the WRAM slot back onto the free list and decrement activeActorCount. Called by Die, MarkDeath, KillPrev, and KillNext COP handlers.

UnlinkActor {
    LDY $0004, X          ; Load prev pointer of actor being removed
    BNE loc_00AF55        ; No prev → actor is the list head; update $0056
    LDY $0006, X          ; Load next pointer to become new head
    STY $0056             ; New list head = removed actor's next
    BEQ loc_00AF69
    LDA #$0000            ; New head has no prev → zero its $0004
    STA $0004, Y
    BRA loc_00AF69

  loc_00AF55:
    LDA $0006, X          ; Mid/tail removal: get removed actor's next
    STA $0006, Y          ; Patch: prev.next → removed.next (splice around removed)
    BNE loc_00AF62        ; If removed.next is null, prev becomes the new tail
    STY $0058             ; Update list tail ($0058) to prev actor
    BRA loc_00AF69

  loc_00AF62:
    TAY                   ; Y = removed.next for the reverse patch
    LDA $0004, X          ; Get removed.prev
    STA $0004, Y          ; Patch: next.prev → removed.prev (complete doubly-linked splice)

  loc_00AF69:
    JSR $&ReturnActorSlot
    RTS 
}

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

; Internal JSR helper that maps an animation step index in A to a frame duration. Doubles A to index movement_delta_table and loads the duration byte. Called by StageSprX, StageSprY, StageSprXY, and their loop variants to convert COP animation operands into frame counts stored in $2C/$2E.

AnimFrameLookup {
    ASL                   ; Double index for word-sized table access (movement_delta_table)
    TAY 
    LDA $&movement_delta_table, Y ; Load frame duration from movement_delta_table[index]
    RTS 
}

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
    STY $0056             ; No prev → new actor is the new list head ($0056)
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
    STY $0058             ; Update list tail to new actor

  loc_00B1B0:
    PLX 
    JSR $&CopyActorState

  loc_00B1B4:
    RTS 
}

ReturnActorSlot {
    LDA #$0000            ; Zero DP for free list field access
    TCD 
    SEP #$20
    DEC $004E             ; Decrement free list pointer by 2 (push entry onto LIFO stack)
    DEC $004E
    DEC $activeActorCount ; Decrement global active actor count
    REP #$20
    TXA 
    STA [$4E]             ; Push freed actor address back onto free list
    TCD                   ; Restore DP to caller's actor base
    RTS 
}

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

CopyActorState {
    PHX 
    LDA $0E
    STA $000E, Y
    LDA $10
    ORA #$2000            ; Preserve thinker bit ($2000) and mask out bits $0803
    AND #$F7FC            ; Clear bits on new actor: movement flags and animation-active bits
    STA $0010, Y
    LDA $12
    AND #$EFFF            ; Clear render-active bit $1000 on copied secondary flags ($12)
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
    STA $0024, Y          ; Store spawner actor ID as reference in new actor $0024 (parent link)
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
    LDA $sceneCurrent     ; Skip callback zeroing on inventory scene ($FF) — inventory actors keep callbacks
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
    LDA ($4E)             ; Read next free slot from LIFO stack pointed to by ($4E)
    BMI loc_00B514        ; Negative (bit 15 set) = pool exhausted sentinel
    TAY                   ; Y = actor WRAM base address from free list
    LDA #$0000
    STA ($4E)             ; Zero the free list entry (mark slot as allocated)
    INC $4E               ; Advance free list pointer by 2 bytes (word-sized stack entries)
    INC $4E
    INC $activeActorCount ; Increment active actor count
    CLC                   ; Carry clear = allocation successful
    RTL 

  loc_00B514:
    LDY #$1FC0            ; Pool exhausted: return sentinel Y=$1FC0
    SEC                   ; Carry set = allocation failed
    RTL                   ; Set extendedFlags bit 1 (smooth interpolated move active)
}

PaletteResetAndKillThinker {
    COP [PaletteRestart]
    COP [PaletteStep]
    COP [KillThinker]
    RTL                   ; Ambient palette cycler — infinite PaletteRestart/PaletteStep loop
}