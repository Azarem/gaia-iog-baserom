---------------------------------------------

ec0A_stair_guard [
  actor-def < #1A, #00, #10, {

  code_04C301:
    COP [SolidHighHere]
    COP [BranchIfFlagByte] ( #21, #01, &code_04C32A )
    COP [SetOnInteract] ( &code_04C336 )
    COP [ExitIfFlagByte] ( #19, #01 )
    COP [ClearLowHere]
    COP [StageSpriteMoveY] ( #1E, #11 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #21, #02, #13 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_04C32A {
    COP [SetOnInteract] ( &code_04C346 )
    LDA #$0200
    TSB $12
    COP [SetEntryContinue]
    RTL 
}

code_04C336 {
    COP [BranchIfFlagByte] ( #19, #01, &code_04C341 )
    COP [PrintWideString] ( &widestring_04C34B )
    RTL 
}

code_04C341 {
    COP [PrintWideString] ( &widestring_04C379 )
    RTL 
}

code_04C346 {
    COP [PrintWideString] ( &widestring_04C3B4 )
    RTL 
}

widestring_04C34B `[DEF]King Edward is having[N]breakfast. Wait a while,[N]then enter.[END]`

widestring_04C379 `[DEF]The interview room is[N]before you. Climb the[N]stairs to meet the king.[END]`

widestring_04C3B4 `[DEF]Zzzzzz...Zzzzzz...[END]`