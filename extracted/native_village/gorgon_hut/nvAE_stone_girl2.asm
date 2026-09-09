?INCLUDE 'hidden_red_jewel'

---------------------------------------------

nvAE_stone_girl2 [
  actor-def < #36, #00, #10, {

  code_089369:
    COP [SolidHighHere]
    COP [BranchIfFlagByte] ( #C0, #01, &code_089392 )
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_08939E )
    COP [ExitIfFlagByte] ( #C0, #01 )
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

code_089392 {
    COP [SetOnInteract] ( &code_0893A3 )
    COP [StageSpriteFrame] ( #32 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
}

code_08939E {
    COP [PrintWideString] ( &widestring_0893BF )
    RTL 
}

code_0893A3 {
    COP [BranchIfFlagByte] ( #E6, #01, &code_0893BA )
    COP [PrintWideString] ( &widestring_08942A )
    COP [GiveItem] ( #01, &code_0893B6 )
    COP [SetFlagByte] ( #E6 )
    RTL 
}

code_0893B6 {
    JML $@hidden_red_jewel.code_00C6A1
}

code_0893BA {
    COP [PrintWideString] ( &widestring_089415 )
    RTL 
}

widestring_0893BF `[DEF]The statue of the girl[N]stands silently.[END]`

widestring_0893DE `[DEF]Somehow the statue has[N]become a human girl![FIN]A tear comes to[N]the girl's eyes...[END]`

widestring_089415 `[DEF]You don't understand...[END]`

widestring_08942A `[DEF]The girl silently offers[N]a Red Jewel[N]as a reward...[FIN]Will gets a Red Jewel! [END]`