; Statue of the girl in the middle of the Gorgon Hut (scene $AE, tile (08,07)). Same script as nvAE_stone_girl1 with flag $C0 (tiles (08,06)-(09,08) of UseItem_GorgonFlower). The restored girl's handler gives a reward once: with $E6 clear it prints 'The girl silently offers a Red Jewel as a reward... Will gets a Red Jewel!', gives item $01 (a full inventory jumps to HiddenRedJewelInventoryFull and leaves $E6 clear) and sets $E6; with $E6 set it prints 'You don't understand...'. The text 'Somehow the statue has become a human girl! A tear comes to the girl's eyes...' is defined in the file but no code references it.
---------------------------------------------

?INCLUDE 'hidden_red_jewel'

---------------------------------------------

nvAE_stone_girl2 [
  actor-def < #36, #00, #10, {

  code_089369:
    COP [MarkSolidHere]
    COP [BranchOnFlagByte] ( #C0, #01, &code_089392 )
    LDA #$0200
    TSB $12
    COP [SetInteractHandler] ( &code_08939E )
    COP [WaitOnFlagByte] ( #C0, #01 )
    COP [LoopStart] ( #1E )
    COP [StageSpriteFrame] ( #36 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #32 )
    COP [AnimOnce]
    COP [LoopEnd]
    LDA #$0200
    TRB $12
} >
]

code_089392 {
    COP [SetInteractHandler] ( &code_0893A3 )
    COP [StageSpriteFrame] ( #32 )
    COP [AnimOnce]
    COP [SetEntryHere]
    RTL 
}

code_08939E {
    COP [PrintDialogString] ( &dialogstring_0893BF )
    RTL 
}

code_0893A3 {
    COP [BranchOnFlagByte] ( #E6, #01, &code_0893BA )
    COP [PrintDialogString] ( &dialogstring_08942A )
    COP [GiveItem] ( #01, &code_0893B6 )
    COP [SetFlagByte] ( #E6 )
    RTL 
}

code_0893B6 {
    JML $@hidden_red_jewel.HiddenRedJewelInventoryFull
}

code_0893BA {
    COP [PrintDialogString] ( &dialogstring_089415 )
    RTL 
}

dialogstring_0893BF `[DEF]The statue of the girl[N]stands silently.[END]`

dialogstring_0893DE `[DEF]Somehow the statue has[N]become a human girl![FIN]A tear comes to[N]the girl's eyes...[END]`

dialogstring_089415 `[DEF]You don't understand...[END]`

dialogstring_08942A `[DEF]The girl silently offers[N]a Red Jewel[N]as a reward...[FIN]Will gets a Red Jewel! [END]`