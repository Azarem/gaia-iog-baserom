
!activator_type      001C

-----------------------------------
;hidden_red_jewel

code_00C672! {
    LDA $0E
    AND #$001F
    CLC 
    ADC #$0080
    JSL $@flag_helpers.TestEventFlag_0200
    BCS hidden_red_jewel_destroy
    COP [SetInteractHandler] ( &HiddenRedJewelInteract )
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [StageSprAndHitbox] ( #02 )
    COP [SetSpritePriority] ( #30 )

  hidden_red_jewel_normal_loop:
    LDA #$2000
    TSB $10
    COP [SetEntryHere]
    LDA $inventoryEquippedType
    CMP #$activator_type
    BEQ hidden_red_jewel_sparkle_loop
    RTL 
}

hidden_red_jewel_sparkle_loop {
    LDA #$2000
    TRB $10
    COP [SetEntryHere]
    LDA $inventoryEquippedType
    CMP #$activator_type
    BNE hidden_red_jewel_normal_loop
    COP [AnimOneFrame]
    RTL 
}

hidden_red_jewel_destroy {
    COP [Die]
}

HiddenRedJewelInteract! {
    LDA $0E
    AND #$001F
    CLC 
    ADC #$0080
    JSL $@flag_helpers.TestEventFlag_0200
    BCS hidden_red_jewel_destroy
    COP [GiveItem] ( #01, &HiddenRedJewelInventoryFull )
    COP [PrintDialogString] ( &dialogstring_00C6A6 )
    LDA $0E
    AND #$001F
    CLC 
    ADC #$0080
    JSL $@flag_helpers.SetEventFlag_0200
    COP [Die]
}