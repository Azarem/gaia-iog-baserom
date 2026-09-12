!joypadMaskStd                  065A

---------------------------------------------

eu96_neil [
  actor-def < #13, #00, #10, {

  code_07DB28:
    COP [BranchIfFlagByte] ( #AC, #01, &code_07DB5D )
    COP [BranchIfFlagByte] ( #AB, #01, &code_07DBD2 )
    COP [BranchIfFlagByte] ( #AA, #01, &code_07DB5F )
    COP [BranchIfFlagByte] ( #A4, #01, &code_07DB5D )
    COP [SetFlagByte] ( #A4 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_07DBE9 )
    COP [StageSpriteLoopMoveY] ( #16, #02, #01 )
    COP [AnimLoop]
    LDA #$CFF0
    TRB $joypadMaskStd
} >
]

code_07DB5D {
    COP [Die]
}

code_07DB5F {
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [SetTilePos] ( #0A, #11 )
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_07DC37 )
    COP [WaitByte] ( #1D )
    COP [StageSpriteLoopMoveY] ( #17, #04, #12 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #13 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [PrintDialogString] ( &dialogstring_07DC63 )
    COP [WaitByte] ( #27 )
    COP [StartMusic] ( #1B )
    COP [WaitByte] ( #3B )
    COP [PrintDialogString] ( &dialogstring_07DD70 )
    COP [SetFlagByte] ( #01 )
    COP [ExitIfFlagByte] ( #01, #00 )
    COP [StageSpriteLoop] ( #14, #10 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #12, #10 )
    COP [AnimLoop]
    COP [PrintDialogString] ( &dialogstring_07DDBF )
    COP [SpawnAfterRelFlags] ( @code_07DECB, #$0000, #$0020, #$1800 )
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [StartMusic] ( #02 )
    COP [WaitByte] ( #77 )
    COP [PrintDialogString] ( &dialogstring_07DDD2 )
    COP [SetFlagByte] ( #AB )
    COP [SetOnInteract] ( &code_07DBE4 )
    LDA #$EFF0
    TRB $joypadMaskStd
    COP [SetEntryContinue]
    RTL 
}

code_07DBD2 {
    COP [SetTilePos] ( #0A, #0A )
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_07DBE4 )
    COP [SetEntryContinue]
    RTL 
}

code_07DBE4 {
    COP [PrintDialogString] ( &dialogstring_07DEAD )
    RTL 
}

dialogstring_07DBE9 `[TPL:A][TPL:6]Neil: [N]Well, make yourself at [N]home.. [FIN]I want to talk to my[N]parents. It's been[N]three years.[PAL:0][END]`

dialogstring_07DC37 `[TPL:A][TPL:0]The next morning.[N]Disappointment awaits...[END]`

dialogstring_07DC63 `[TPL:B][TPL:6]Neil: Good morning. [N]Sorry about yesterday.[FIN]I thought about it all[N]night. I'm next in line[N]to inherit this company.[FIN]If I want to stop the[N]labor trade, I have to[N]change the company[N]that started it...[FIN]They make money on[N]human misfortune.[FIN][TPL:1]Kara: You're going to [N]become the president of [N]the company? Amazing! [FIN][TPL:6]Neil: Heh heh. Stop it.[N]You're embarrassing me.[END]`

dialogstring_07DD70 `[TPL:B][TPL:6][DLY:2]Neil: Kara, someone's [N]come asking about you. [N]Something about being [N]an old friend. [FIN][TPL:1][DLY:0]Kara: [N]What!!!? [END]`

dialogstring_07DDBF `[TPL:A][TPL:6]Neil: [N]Hey! Come on in! [END]`

dialogstring_07DDD2 `[TPL:B][TPL:1]Kara: [N]Hamlet!! [FIN][TPL:6][DLY:1]Oink oink![FIN][TPL:1]What happened?[N]Are you OK!?[FIN][TPL:6]Neil: Ha ha. [N]He's come all this way [N]looking for you. [FIN]Lilly found him in [N]Watermia and sent him by[N]Rolek's Delivery[N]Service.[FIN]Even if I'm losing my[N]travelling companions,[N]my allies are increasing![PAL:0][END]`

dialogstring_07DEAD `[TPL:A][TPL:6]Neil: [N]Take care, everyone.[PAL:0][END]`

code_07DECB {
    COP [StageSpriteMoveY] ( #2F, #02 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #30, #12 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #2F, #02 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #30, #02, #12 )
    COP [AnimLoop]
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_07DEF4 )
    COP [SetFlagByte] ( #02 )
    COP [SetEntryContinue]
    RTL 
}

code_07DEF4 {
    COP [PrintDialogString] ( &dialogstring_07DEF9 )
    RTL 
}

dialogstring_07DEF9 `[TPL:8]Oink oink[PAL:0][END]`