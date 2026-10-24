
code_07ACEC! {
    COP [SetTilePos] ( #07, #09 )
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [MarkSolidHere]
    COP [NudgePosition] ( #00, #F8 )
    COP [BranchOnFlagByte] ( #A5, #00, &wa79_lance_init_normal )
    COP [BranchOnFlagByte] ( #E2, #01, &wa79_lance_init_normal )
    COP [SpawnAfterOffset] ( @generic_sparkle, #$0000, #$FFF8 )
    STY $26

  wa79_lance_init_normal:
    COP [SetInteractHandler] ( &code_07AD07 )
    COP [SetEntryHere]
    RTL 
}

code_07AD15! {
    COP [BranchOnFlagByte] ( #E2, #01, &code_07AD2C )
    COP [GiveItem] ( #01, &code_07AD28 )
    LDY $26
    LDA #$0001
    STA $0026, Y
    COP [PrintDialogString] ( &dialogstring_07AEDE )
    COP [SetFlagByte] ( #E2 )
    RTL 
}
