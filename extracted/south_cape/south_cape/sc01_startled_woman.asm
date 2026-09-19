; South Cape woman who is startled when Will talks to her.
; 
; First interaction triggers a surprised reaction. Subsequent
; interactions show a different dialog about the sea breeze.
---------------------------------------------

---------------------------------------------

sc01_startled_woman [
  actor-def < #14, #00, #10, {

  code_048765:
    COP [SetOnInteract] ( &code_0487BA )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    COP [BranchIfPlayerAt] ( #$02A8, #$01C8, &code_048776 )
    RTL 
} >
]

code_048776 {
    COP [ClearLowHere]
    COP [SetTilePos] ( #28, #25 )
    COP [StageSpriteLoopMoveX] ( #19, #01, #11 )
    COP [AnimLoop]
    COP [SetEntryContinue]
    COP [BranchIfPlayerAt] ( #$02A8, #$0250, &code_04878E )
    RTL 
}

code_04878E {
    COP [SetEntryDelayExit] ( @code_048795, #$0010 )
}

code_048795 {
    COP [PrintDialogString] ( &dialogstring_0487BF )
    COP [SetOnInteract] ( &code_0487B5 )
    COP [StageSpriteLoopMoveX] ( #18, #04, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #17, #02, #12 )
    COP [AnimLoop]
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
}

code_0487B0 {
    COP [PrintDialogString] ( &dialogstring_0487BF )
    RTL 
}

code_0487B5 {
    COP [PrintDialogString] ( &dialogstring_0487F1 )
    RTL 
}

code_0487BA {
    COP [PrintDialogString] ( &dialogstring_0487F5 )
    RTL 
}

dialogstring_0487BF `[DEF]Oh, no![FIN][::]What are you doing![N]This child![N]Honestly...[END]`

dialogstring_0487F1 `[DEF][JMP:&dialogstring_0487BF+M]`

dialogstring_0487F5 `[DEF]I envy you when I see [N]the sea breeze blowing [N]your hair like that... [FIN]Not like mine,[N]under this scarf.... [END]`