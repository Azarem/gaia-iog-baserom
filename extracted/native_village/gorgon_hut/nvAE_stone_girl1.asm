; Statue of the girl on the left of the Gorgon Hut (scene $AE, tile (06,07)). Flag $BF set at load: frame $32 with the handler 'You don't understand...'. Clear: solid statue with 'The statue of a girl stands silently.'; it waits for $BF (set by UseItem_GorgonFlower when the player stands in tiles (06,06)-(07,08)), alternates frames $36 and $32 thirty times, clears bit $0200 of its flags $12 and falls into the restored state. The text 'Somehow the statue has become a human girl! A tear comes to the girl's eyes...' is defined in the file but no code references it.
---------------------------------------------

---------------------------------------------

nvAE_stone_girl1 [
  actor-def < #36, #00, #10, {

  code_0892A5:
    COP [MarkSolidHere]
    COP [BranchOnFlagByte] ( #BF, #01, &code_0892CE )
    LDA #$0200
    TSB $12
    COP [SetInteractHandler] ( &code_0892DA )
    COP [WaitOnFlagByte] ( #BF, #01 )
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

code_0892CE {
    COP [SetInteractHandler] ( &code_0892DF )
    COP [StageSpriteFrame] ( #32 )
    COP [AnimOnce]
    COP [SetEntryHere]
    RTL 
}

code_0892DA {
    COP [PrintDialogString] ( &dialogstring_0892E4 )
    RTL 
}

code_0892DF {
    COP [PrintDialogString] ( &dialogstring_089351 )
    RTL 
}

dialogstring_0892E4 `[DEF]The statue of a girl [N]stands silently.[END]`

dialogstring_0892FF `The statue of a girl [N]stands silently. [END]`

dialogstring_08931A `[DEF]Somehow the statue has[N]become a human girl![FIN]A tear comes to[N]the girl's eyes...[END]`

dialogstring_089351 `[DEF]You don't understand...[END]`