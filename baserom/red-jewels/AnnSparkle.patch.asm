; ==============================================================================
; Rolek Mansion Ann - Red Jewel for Gorgon Flower trade sparkle
; ==============================================================================
; What it does: Before flags $E3/$E4 block the trade, spawns generic_sparkle on init;
;   successful interact removes item $28, gives Red Jewel, sets $E5, kills sparkle child.
; Vanilla behavior: eu95_ann code_07DF07 init and code_07DF43 trade script without sparkle.
; Hooks (overrides): eu95_ann.code_07DF07- insert; code_07DF43! interact replace.
; Depends on: generic_sparkle; flag bytes $D6, $E3-$E5; RemoveItem #28 / GiveItem #01.
; ==============================================================================

eu95_ann.code_07DF07- {
    COP [BranchOnFlagByte] ( #D6, #01, &code_07DF07 )
    COP [SpawnAfterOffset] ( @generic_sparkle, #$0000, #$FFF8 )
    STY $26
}

eu95_ann.code_07DF43! {
    COP [BranchOnFlagByte] ( #E3, #00, &code_07DF63 )
    COP [BranchOnFlagByte] ( #E4, #00, &code_07DF68 )
    COP [RemoveItem] ( #28 )
    COP [GiveItem] ( #01, &code_07DF5F )
    LDY $26
    LDA #$0001
    STA $0026, Y
    COP [PrintDialogString] ( &dialogstring_07E10A )
    COP [SetFlagByte] ( #E5 )
    RTL 
}
