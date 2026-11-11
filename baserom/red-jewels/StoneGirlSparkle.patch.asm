; ==============================================================================
; Gorgon hut stone girl - hidden Red Jewel sparkle
; ==============================================================================
; What it does: On init, if flag $E6 clear, spawns generic_sparkle; interact gives Red
;   Jewel $01, sets $E6, and signals sparkle child to die via $0026,Y.
; Vanilla behavior: nvAE_stone_girl2 init and code_0893A3 gift without sparkle hint.
; Hooks (overrides): nvAE_stone_girl2.code_089369- insert; code_0893A3! full interact replace.
; Depends on: generic_sparkle; flag byte $E6; HiddenRedJewelInventoryFull on full inventory.
; ==============================================================================

nvAE_stone_girl2.code_089369- {
    COP [BranchOnFlagByte] ( #E6, #01, &code_089369 )
    COP [SpawnAfterOffset] ( @generic_sparkle, #$0000, #$FFF8 )
    STY $26
}

nvAE_stone_girl2.code_0893A3! {
    COP [BranchOnFlagByte] ( #E6, #01, &code_0893BA )
    COP [GiveItem] ( #01, &code_0893B6 )
    LDY $26
    LDA #$0001
    STA $0026, Y
    COP [PrintDialogString] ( &dialogstring_08942A )
    COP [SetFlagByte] ( #E6 )
    RTL 
}
