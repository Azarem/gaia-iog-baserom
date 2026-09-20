; Right guard at the castle entrance.
; 
; Multi-state dialog about castle etiquette and strict rules.
---------------------------------------------

?INCLUDE 'hidden_red_jewel'

---------------------------------------------

ec0A_right_guard [
  actor-def < #1C, #00, #10, {

  code_04C1B5:
    COP [BranchOnFlagByte] ( #21, #01, &code_04C1F4 )
    COP [SetInteractHandler] ( &code_04C1FF )
    COP [StageSpriteLoopMoveX] ( #20, #07, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1C, #08 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1A, #08 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1D, #08 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #21, #1B, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #1F, #03, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #20, #03, #12 )
    COP [AnimLoop]
    COP [SetInteractHandler] ( &code_04C204 )
    COP [SetEntryHere]
    RTL 
} >
]

code_04C1F4 {
    COP [SetTilePos] ( #38, #29 )
    COP [SetInteractHandler] ( &code_04C224 )
    COP [SetEntryHere]
    RTL 
}

code_04C1FF {
    COP [PrintDialogString] ( &dialogstring_04C229 )
    RTL 
}

code_04C204 {
    COP [BranchOnFlagByte] ( #D8, #01, &code_04C21F )
    COP [PrintDialogString] ( &dialogstring_04C271 )
    COP [GiveItem] ( #01, &code_04C21B )
    COP [PrintDialogString] ( &dialogstring_04C299 )
    COP [SetFlagByte] ( #D8 )
    RTL 
}

code_04C21B {
    JML $@hidden_red_jewel.HiddenRedJewelInventoryFull
}

code_04C21F {
    COP [PrintDialogString] ( &dialogstring_04C2C2 )
    RTL 
}

code_04C224 {
    COP [PrintDialogString] ( &dialogstring_04C2E9 )
    RTL 
}

dialogstring_04C229 `[TPL:B]This is King Edward's[N]castle. Be courteous[N]and know that the King[N]is very strict.[END]`

dialogstring_04C271 `[TPL:9]Don't raise your voice.[N]And mind your manners.[FIN]`

dialogstring_04C299 `In exchange, I will give[N]you one Red Jewel.[END]`

dialogstring_04C2C2 `[TPL:9]Don't raise your voice.[N]And mind your manners.[END]`

dialogstring_04C2E9 `[TPL:8]Zzzzzz...Zzzzzz...[END]`