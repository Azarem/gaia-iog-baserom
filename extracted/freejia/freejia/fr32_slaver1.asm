---------------------------------------------

fr32_slaver1 [
  actor-def < #1D, #00, #10, {

  code_05B819:
    COP [BranchIfFlagByte] ( #5A, #01, &code_05B839 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05B83B )

  code_05B825:
    COP [StageSpriteFrame] ( #21 )
    COP [AnimOnce]
    COP [BranchIfFlagByte] ( #5A, #00, &code_05B825 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveX] ( #20, #04, #02 )
    COP [AnimLoop]
} >
]

code_05B839 {
    COP [Die]
}

code_05B83B {
    COP [PrintWideString] ( &widestring_05B840 )
    RTL 
}

widestring_05B840 `[DEF]Where'd he go...[END]`