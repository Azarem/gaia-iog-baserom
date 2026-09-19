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
    LDY $0004, X
    BNE loc_00AF55
    LDY $0006, X
    STY $0056
    BEQ loc_00AF69
    LDA #$0000
    STA $0004, Y
    BRA loc_00AF69

  loc_00AF55:
    LDA $0006, X
    STA $0006, Y
    BNE loc_00AF62
    STY $0058
    BRA loc_00AF69

  loc_00AF62:
    TAY 
    LDA $0004, X
    STA $0004, Y

  loc_00AF69:
    JSR $&ReturnActorSlot
    RTS 
}

SetActorBody {
    LDA $characterForm
    ASL 
    CLC 
    ADC $characterForm
    ASL 
    TAY 
    LDA $&body_table, Y
    STA $spritesetPtr, X
    LDA $&body_table+2, Y
    AND #$00FF
    STA $7F0008, X
    LDA #$8000
    TRB $playerFlags
    RTS 
}
---------------------------------------------

; Internal JSR helper that maps an animation step index in A to a frame duration. Doubles A to index movement_delta_table and loads the duration byte. Called by StageSprX, StageSprY, StageSprXY, and their loop variants to convert COP animation operands into frame counts stored in $2C/$2E.

AnimFrameLookup {
    ASL 
    TAY 
    LDA $&movement_delta_table, Y
    RTS 
}

AllocateActorBefore {
    PHD 
    LDA #$0000
    TCD 
    JSL $@ActorPoolAllocator
    PLD 
    BCS loc_00B188
    TXA 
    STA $0006, Y
    LDA $04
    STA $0004, Y
    TYA 
    STA $04
    PHX 
    LDX $0004, Y
    BNE loc_00B180
    STY $0056
    BRA loc_00B184

  loc_00B180:
    TYA 
    STA $0006, X

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
    JSL $@ActorPoolAllocator ; ActorPoolAllocator for spawn-after linked list insert
    PLD 
    BCS loc_00B1B4
    TXA 
    STA $0004, Y
    LDA $06
    STA $0006, Y
    TYA 
    STA $06
    PHX 
    LDX $0006, Y
    BEQ loc_00B1AD
    TYA 
    STA $0004, X
    BRA loc_00B1B0

  loc_00B1AD:
    STY $0058

  loc_00B1B0:
    PLX 
    JSR $&CopyActorState

  loc_00B1B4:
    RTS 
}

ReturnActorSlot {
    LDA #$0000
    TCD 
    SEP #$20
    DEC $004E
    DEC $004E
    DEC $activeActorCount
    REP #$20
    TXA 
    STA [$4E]
    TCD 
    RTS 
}

MarkChildActor {
    LDA $parentId, X
    BNE loc_00B1D2
    TDC 

  loc_00B1D2:
    TYX 
    STA $parentId, X
    TDC 
    TAX 
    RTS 
}

CopyActorState {
    PHX 
    LDA $0E
    STA $000E, Y
    LDA $10
    ORA #$2000            ; ORA #$2000: preserve thinker bit during CopyActorState
    AND #$F7FC
    STA $0010, Y
    LDA $12
    AND #$EFFF            ; AND #$EFFF: clear render-active on newly copied actor
    STA $0012, Y
    LDA $14
    STA $0014, Y
    LDA $16
    STA $0016, Y
    LDA $28
    STA $0028, Y
    LDA $2A
    STA $002A, Y
    TXA 
    STA $0024, Y
    LDA $statsPtr, X
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
    LDA #$0000
    STA $parentId, X
    STA $002C, X
    STA $002E, X
    STA $moveScratch1, X
    STA $moveScratch2, X
    STA $0008, X
    STA $chatPtr, X
    LDA $sceneCurrent
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
    JSL $@actor_execution.ThinkerPoolAlloc
    BCS loc_00B29D
    LDX $005C
    TXA 
    STA $0004, Y
    LDA #$0000
    STA $0008, Y
    STA $0006, Y
    TYA 
    STA $0006, X
    STY $005C

  loc_00B29D:
    PLD 
    RTS 
}
---------------------------------------------

; Internal JSL/JSR allocator that pops the next free actor slot from the LIFO free list at ($4E). On success returns carry clear with Y = new actor WRAM base ($1000 + index×$30) and zeroes the free-list entry; on pool exhaustion returns carry set with Y = $1FC0. Increments activeActorCount on allocation. Called by SpawnSceneActors, AllocateActorBefore/After, and SpawnBefore/After COP handlers.

ActorPoolAllocator {
    LDA ($4E)
    BMI loc_00B514
    TAY 
    LDA #$0000
    STA ($4E)
    INC $4E
    INC $4E
    INC $activeActorCount
    CLC 
    RTL 

  loc_00B514:
    LDY #$1FC0
    SEC 
    RTL 
}

PaletteResetAndKillThinker {
    COP [PaletteRestart]
    COP [PaletteStep]
    COP [KillThinker]
    RTL 
}