; Per-tick flicker helper: flips bit $2000 of the PARENT actor's flags $10 (the parent is the actor whose slot is in $24).
; 
; Spawned with SpawnAfterAbsFlags (flags $2800) by the Seaside Palace party-member rooms (sp5B_neil, sp5B_lance, sp5B_kara, sp5B_erik; spawned only while flag #70 is clear) and by sp5A_phantom_ribber. CopyActorState stores the spawner's slot in $24 of every spawned actor, which is how the helper finds its parent. The routine ends with RTL and never changes its entry point or calls Die, so it runs again on every tick and flips the bit every tick. sprite_composition.SortActorsByDepth skips actors with $2000 set, so the parent is drawn on alternate frames: a 50 % flicker, probably the ghost look of these actors (UNVERIFIED-RUNTIME). It is not a one-shot show/hide, and it is not a marked child, so it outlives the parent.
---------------------------------------------

---------------------------------------------

FlickerParentActor {
    LDY $24               ; Y = parent actor slot (CopyActorState stored the spawner's slot in $24)
    LDA $0010, Y
    EOR #$2000            ; Flip bit $2000 of the parent's $10 (SortActorsByDepth skips actors with it set)
    STA $0010, Y
    RTL                   ; RTL without Die or a new entry point: the helper runs again next tick, so the bit flips every tick
}