; Erik in the Angel Village annex — remarks on sunlight.
; 
; Multi-dialog NPC. Says: "The sun is really bright. I never
; noticed that before." Reflects on the contrast between
; the dark underground village and the surface world.
---------------------------------------------

!joypadMaskStd                  065A

---------------------------------------------

av6A_erik [
  actor-def < #0C, #00, #10, {

  code_06C4BC:
    COP [BranchOnFlagByte] ( #8D, #01, &av6A_erik_destroy )
    COP [BranchOnFlagByte] ( #A9, #01, &code_06C513 )
    COP [BranchOnFlagByte] ( #8C, #01, &code_06C4D7 )
    COP [SetInteractHandler] ( &code_06C52A )
    COP [MarkSolidHere]
    COP [SetEntryHere]
    RTL 
} >
]

code_06C4D7 {
    COP [SetTilePos] ( #0F, #0C )
    COP [MarkSolidHere]
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [SetInteractHandler] ( &code_06C525 )
    COP [ClearSolidHere]
    COP [StageSpriteMoveX] ( #11, #11 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #0D, #28 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #11, #03, #01 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #0D )
    COP [AnimOnce]
    COP [MarkSolidHere]
    COP [PrintDialogString] ( &dialogstring_06C568 )
    COP [SetFlagByte] ( #A9 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SetEntryHere]
    RTL 
}

code_06C513 {
    COP [SetTilePos] ( #16, #0C )
    COP [StageSpriteFrame] ( #0D )
    COP [AnimOnce]
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_06C525 )
    COP [SetEntryHere]
    RTL 
}

code_06C525 {
    COP [PrintDialogString] ( &dialogstring_06C6A0 )
    RTL 
}

code_06C52A {
    COP [PrintDialogString] ( &dialogstring_06C52F )
    RTL 
}

dialogstring_06C52F `[TPL:A][TPL:3]Erik: The sun is really [N]bright. I never [N]noticed that before.[PAL:0][END]`

dialogstring_06C568 `[TPL:A][TPL:6][SFX:1A]Neil: [N]Kara! I was worried! [FIN][TPL:2][SFX:19]Lilly:[N]Why are you always[N]running around alone?![FIN]Didn't you think about[N]the rest of us?[FIN][TPL:1][SFX:1B]Kara: [N]Will already yelled [N]at me about that. [FIN]My apologies to [N]everyone! [FIN][TPL:6][SFX:1A]Neil: She understands [N]now. We should [N]forgive her. [FIN]I think the Floating[N]City is about three days[N]south of here.[FIN]I think we should go[N]there right away. Tell[N]me when you're ready.[PAL:0][END]`

dialogstring_06C6A0 `[TPL:A][TPL:3]Erik: I think I saw [N]a Red Jewel [N]in the Angel Village.[PAL:0][END]`
---------------------------------------------

av6A_erik_destroy {
    COP [Die]
}