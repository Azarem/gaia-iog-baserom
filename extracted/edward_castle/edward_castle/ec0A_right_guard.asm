?INCLUDE 'hidden_red_jewel'

---------------------------------------------

ec0A_right_guard [
  actor-def < #1C, #00, #10, {

  code_04C1B5:
    COP [BranchIfFlagByte] ( #21, #01, &code_04C1F4 )
    COP [SetOnInteract] ( &code_04C1FF )
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
    COP [SetOnInteract] ( &code_04C204 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_04C1F4 {
    COP [SetTilePos] ( #38, #29 )
    COP [SetOnInteract] ( &code_04C224 )
    COP [SetEntryContinue]
    RTL 
}

code_04C1FF {
    COP [PrintWideString] ( &widestring_04C229 )
    RTL 
}

code_04C204 {
    COP [BranchIfFlagByte] ( #D8, #01, &code_04C21F )
    COP [PrintWideString] ( &widestring_04C271 )
    COP [GiveItem] ( #01, &code_04C21B )
    COP [PrintWideString] ( &widestring_04C299 )
    COP [SetFlagByte] ( #D8 )
    RTL 
}

code_04C21B {
    JML $@hidden_red_jewel.code_00C6A1
}

code_04C21F {
    COP [PrintWideString] ( &widestring_04C2C2 )
    RTL 
}

code_04C224 {
    COP [PrintWideString] ( &widestring_04C2E9 )
    RTL 
}

widestring_04C229 `[TPL:B]This is King Edward's[N]castle. Be courteous[N]and know that the King[N]is very strict.[END]`

widestring_04C271 `[TPL:9]Don't raise your voice.[N]And mind your manners.[FIN]`

widestring_04C299 `In exchange, I will give[N]you one Red Jewel.[END]`

widestring_04C2C2 `[TPL:9]Don't raise your voice.[N]And mind your manners.[END]`

widestring_04C2E9 `[TPL:8]Zzzzzz...Zzzzzz...[END]`