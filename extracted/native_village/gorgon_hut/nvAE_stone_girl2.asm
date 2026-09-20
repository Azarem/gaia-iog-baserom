; Stone girl statue 2 in the Gorgon Hut — can be restored.
; 
; Dual-state object. Before: "The statue of the girl stands
; silently." After restoration: "Somehow the statue has become
; a human girl! A tear comes to the girl's eyes..." Emotional
; scene when the petrification is reversed.
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