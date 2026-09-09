---------------------------------------------

fr38_girlfriend [
  actor-def < #0D, #00, #10, {

  code_05BA90:
    COP [SetOnInteract] ( &code_05BABD )
    COP [AddPosition] ( #04, #00 )
    COP [WaitWhileOffscreen] ( #01 )
    COP [WaitByte] ( #1D )
    COP [StageSprAndHitbox] ( #10 )
    COP [StageForceMoveX] ( #14 )
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    COP [SetEntryExit]
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    COP [SetEntryExit]
    COP [StageForceMoveX] ( #00 )
    COP [StageSpriteFrame] ( #0C )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_05BABD {
    COP [PrintWideString] ( &widestring_05BAC2 )
    RTL 
}

widestring_05BAC2 `[DEF]He had something [N]in his eye... [N]Ha ha ha. [END]`