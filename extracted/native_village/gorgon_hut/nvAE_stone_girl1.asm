---------------------------------------------

nvAE_stone_girl1 [
  actor-def < #36, #00, #10, {

  code_0892A5:
    COP [SolidHighHere]
    COP [BranchIfFlagByte] ( #BF, #01, &code_0892CE )
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_0892DA )
    COP [ExitIfFlagByte] ( #BF, #01 )
    COP [LoopInit] ( #1E )
    COP [StageSpriteFrame] ( #36 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #32 )
    COP [AnimOnce]
    COP [LoopNext]
    LDA #$0200
    TRB $12
} >
]

code_0892CE {
    COP [SetOnInteract] ( &code_0892DF )
    COP [StageSpriteFrame] ( #32 )
    COP [AnimOnce]
    COP [SetEntryContinue]
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