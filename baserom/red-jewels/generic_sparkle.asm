
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
