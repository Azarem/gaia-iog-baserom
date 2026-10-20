
code_05D7CB! {
    COP [NudgePosition] ( #08, #00 )
    LDA #$2000
    TSB $10
    COP [StageSpriteFrame] ( #0C )
    COP [AnimOnce]
    COP [SpawnAfterOffset] ( @generic_sparkle, #$0000, #$FFF8 )
    STY $26
    COP [WaitOnFlagByte] ( #D9, #01 )
    LDY $26
    LDA #$0001
    STA $0026, Y
    LDA #$2000
    TRB $10
    LDA #$EFFC
    TSB $joypadMaskStd
    COP [WaitByte] ( #77 )
    COP [ClearFlagByte] ( #00 )
    COP [GiveItem] ( #01, &dm40_trapped_slave_inventory_full )
    COP [GiveItem] ( #01, &dm40_trapped_slave_inventory_full )
    COP [GiveItem] ( #01, &dm40_trapped_slave_inventory_full )
    COP [PrintDialogString] ( &dm40_trapped_slave_normal_str )
    BRA dm40_trapped_slave_continue

  dm40_trapped_slave_inventory_full:
    SED 
    LDA $jewelsCollected
    CLC 
    ADC #$0003
    STA $jewelsCollected
    CLD 
    COP [PrintDialogString] ( &dm40_trapped_slave_full_str )

  dm40_trapped_slave_continue:
    LDA #$EFFC
    TRB $joypadMaskStd
    LDA #$0080
    TSB $displayModeFlags
    COP [StageSpriteLoopMoveY] ( #0D, #08, #01 )
    COP [AnimLoop]
    LDA #$0080
    TRB $displayModeFlags
    COP [Die]
}

dm40_trapped_slave_normal_str `[PRT:@dialogstring_05D819]I want to give you a[N]present. Here's 3 Red[N]Jewels for your trouble.[END]`
dm40_trapped_slave_full_str `[PRT:@dialogstring_05D819]I want to give you a[N]present. I'm sending 3[N]Red Jewels to[N]the Jeweler.[END]`

dialogstring_05D819! `[DEF]Thank you.[N]I was buried in[N]the cave-in...[FIN]What would happen if[N]we took longer...[FIN]`
