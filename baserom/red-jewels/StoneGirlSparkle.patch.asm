
code_089369- {
    COP [BranchOnFlagByte] ( #E6, #01, &code_089369 )
    COP [SpawnAfterOffset] ( @generic_sparkle, #$0000, #$FFF8 )
    STY $26
}

code_0893A3! {
    COP [BranchOnFlagByte] ( #E6, #01, &code_0893BA )
    COP [GiveItem] ( #01, &code_0893B6 )
    LDY $26
    LDA #$0001
    STA $0026, Y
    COP [PrintDialogString] ( &dialogstring_08942A )
    COP [SetFlagByte] ( #E6 )
    RTL 
}
