---------------------------------------------

sc01_girl1 [
  actor-def < #35, #00, #10, {

  code_0480AB:
    LDA #$0200
    TSB $12
    COP [SolidHighHere]

  loc_0480B2:
    COP [SetEntryContinue]

  code_0480B4:
    COP [StageSpriteLoop] ( #32, #06 )
    COP [AnimLoop]
    COP [SetFlagByte] ( #02 )
    COP [SetOnInteract] ( &code_0480F0 )
    COP [StageSpriteLoop] ( #34, #46 )
    COP [AnimLoop]
    COP [ClearFlagByte] ( #02 )
    COP [StageSpriteLoop] ( #34, #1E )
    COP [AnimLoop]
    COP [SetOnInteract] ( &code_0480F5 )
    COP [StageSpriteLoop] ( #32, #06 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #35, #3C )
    COP [AnimLoop]
    COP [BranchIfFlagByte] ( #03, #00, &code_0480B4 )
    COP [SetOnInteract] ( &code_0480FA )
    COP [ExitIfFlagByte] ( #03, #00 )
    BRA loc_0480B2
} >
]

code_0480F0 {
    COP [PrintDialogString] ( &dialogstring_0480FF )
    RTL 
}

code_0480F5 {
    COP [PrintDialogString] ( &dialogstring_048112 )
    RTL 
}

code_0480FA {
    COP [PrintDialogString] ( &dialogstring_048125 )
    RTL 
}

dialogstring_0480FF `[DEF][DLY:2]1..2..3..4..5..[END]`

dialogstring_048112 `[DEF][DLY:2]6..7..8..9..10![END]`

dialogstring_048125 `[DEF]Mmmm. Only me...[END]`