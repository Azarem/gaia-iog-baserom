---------------------------------------------

h_sc01_startled_woman [
  actor-def < #14, #00, #10, {

  code_048719:
    COP [SetOnInteract] ( &code_04876E )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    COP [BranchIfPlayerAt] ( #$02A8, #$01C8, &code_04872A )
    RTL 
} >
]

code_04872A {
    COP [ClearLowHere]
    COP [SetTilePos] ( #28, #25 )
    COP [StageSpriteLoopMoveX] ( #19, #01, #11 )
    COP [AnimLoop]
    COP [SetEntryContinue]
    COP [BranchIfPlayerAt] ( #$02A8, #$0250, &code_048742 )
    RTL 
}

code_048742 {
    COP [SetEntryDelayExit] ( @code_048749, #$0010 )
}

code_048749 {
    COP [PrintWideString] ( &widestring_048773 )
    COP [SetOnInteract] ( &code_048769 )
    COP [StageSpriteLoopMoveX] ( #18, #04, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #17, #02, #12 )
    COP [AnimLoop]
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
}

code_048764 {
    COP [PrintWideString] ( &widestring_048773 )
    RTL 
}

code_048769 {
    COP [PrintWideString] ( &widestring_04879F )
    RTL 
}

code_04876E {
    COP [PrintWideString] ( &widestring_0487A3 )
    RTL 
}

widestring_048773 `[DEF]きゃあああっ![FIN][::]なんてこと するんだろうねっ![N]この子はっ![N]まったく もう···[END]`

widestring_04879F `[DEF][JMP:&sc01_startled_woman.widestring_048773+M]`

widestring_0487A3 `[DEF]海風でなびく あんたのかみの毛を[N]見ていると うらやましいよ.[N]あたしなんざ[N]このスカーフの下は···[END]`