; ==============================================================================
; Red Jewel sparkle helper actor
; ==============================================================================
; What it does: Child actor that toggles priority bit $2000 on $10 while the player has
;   inventoryEquippedType == activator_type ($1C); animates one frame when equipped type
;   matches, otherwise idles hidden. Dies when parent sets $0026,Y to $0001 after pickup.
; Vanilla behavior: (new actor; not in extracted ROM.)
; Adds: generic_sparkle init, generic_sparkle_normal_loop / _loop / _destroy entry points.
; Depends on: spriteset_pickups_effects metasprite; COP SetEntryHere, AnimOneFrame, Die.
; State: Reads inventoryEquippedType; uses actor fields $0E/$10/$26 per parent patches.
; Hazards/notes: X must remain actor slot ID across COP instructions in parent and here.
; ==============================================================================

!activator_type      001C

-----------------------------------

generic_sparkle {
    LDA #$2000
    STA $0E
    LDA #$0402
    STA $10
    LDA #$0000
    STA $26
    COP [SetMetasprite] ( @spriteset_pickups_effects )
    COP [StageSpriteFrame] ( #02 )
    COP [SetSpritePriority] ( #30 )
}

generic_sparkle_normal_loop {
    LDA #$2000
    TSB $10
    COP [SetEntryHere]
    LDA $26
    BNE generic_sparkle_destroy
    LDA $inventoryEquippedType
    CMP #$activator_type
    BEQ generic_sparkle_loop
    RTL
}

generic_sparkle_loop {
    LDA #$2000
    TRB $10
    COP [SetEntryHere]
    LDA $26
    BNE generic_sparkle_destroy
    LDA $inventoryEquippedType
    CMP #$activator_type
    BNE generic_sparkle_normal_loop
    COP [AnimOneFrame]
    RTL 
}

generic_sparkle_destroy {
    COP [Die]
}
