
code_07DF07- {
    COP [BranchOnFlagByte] ( #D6, #01, &code_07DF07 )
    COP [SpawnAfterOffset] ( @generic_sparkle, #$0000, #$FFF8 )
    STY $26
}

code_07DF43! {
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
