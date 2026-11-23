; Edward Castle's sleeping guard offers the same Red Jewel as his awake
; interaction. Both routes use $D8, set only after GiveItem succeeds.

?INCLUDE 'ec0A_right_guard'
?INCLUDE 'hidden_red_jewel'

ec0A_right_guard.code_04C1F4! {
    COP [SetTilePos] ( #37, #29 )
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    COP [SetInteractHandler] ( &code_04C224 )
    COP [SetEntryHere]
    RTL
}

ec0A_right_guard.code_04C224! {
    COP [BranchOnFlagByte] ( #D8, #01, &EdwardSleepingGuardRepeat )
    COP [PrintDialogString] ( &EdwardSleepingGuardNotice )
    COP [GiveItem] ( #01, &EdwardSleepingGuardInventoryFull )
    COP [SetFlagByte] ( #D8 )
    COP [PrintDialogString] ( &EdwardSleepingGuardSuccess )
    RTL

  EdwardSleepingGuardRepeat:
    COP [PrintDialogString] ( &dialogstring_04C2E9 )
    RTL

  EdwardSleepingGuardInventoryFull:
    JML $@hidden_red_jewel.HiddenRedJewelInventoryFull
}

EdwardSleepingGuardNotice `[BOR:7][DLG:3,4][SIZ:D,3][PRT:@RetranslationTheme19]Zzz[AD] Zzz[AD][WAI][CLR]A Red Jewel glints from[N]the sleeping guard's[N]pocket.[FIN]`
EdwardSleepingGuardSuccess `[CLR]Will quietly takes it.[END]`
