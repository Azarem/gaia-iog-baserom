
code_08AE4C- {
    COP [BranchOnFlagByte] ( #E7, #01, &code_08AE4C )
    COP [SpawnAfterOffset] ( @generic_sparkle, #$0000, #$FFF8 )
    STY $26
}


loc_08B010! {
    COP [SetFlagByte] ( #E7 )
    LDY $26
    LDA #$0001
    STA $0026, Y
    COP [GiveItem] ( #01, &snake_panic_inventory_full )
    COP [GiveItem] ( #01, &snake_panic_inventory_full )
    COP [PrintDialogString] ( &daC6_snake_panic_normal_str )
    BRA loc_08AFFF
}

snake_panic_inventory_full {
    SED 
    LDA $jewelsCollected
    CLC 
    ADC #$0002
    STA $jewelsCollected
    CLD 
    COP [PrintDialogString] ( &daC6_snake_panic_full_str )
    BRA loc_08AFFF
}

daC6_snake_panic_normal_str `[PRT:@dialogstring_08B052][CLD]`
daC6_snake_panic_full_str `[PRT:@dialogstring_08B052]I'll send them to[N]the Jeweler.[END]`

dialogstring_08B052! `[TPL:A][DLY:2]Wow [BCD:3,AAC] snakes. Very[N]good![FIN]For your prize, I'll give [N]you two Red Jewels. [FIN]`
