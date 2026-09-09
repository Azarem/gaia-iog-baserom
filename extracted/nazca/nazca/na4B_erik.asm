---------------------------------------------

na4B_erik [
  actor-def < #0B, #00, #10, {

  code_05F1FC:
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [SetOnInteract] ( &code_05F269 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveY] ( #0F, #03, #12 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #10, #12 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [ClearLowHere]
    COP [SetTilePos] ( #14, #09 )
    COP [StageSpriteFrame] ( #0B )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05F26E )
    COP [ExitIfFlagByte] ( #08, #01 )
    COP [StageSpriteFrame] ( #0C )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #09, #01 )
    COP [SetOnInteract] ( &code_05F273 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveY] ( #0E, #09, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #11, #05, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #0E, #07, #01 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #0E, #11 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_05F269 {
    COP [PrintWideString] ( &widestring_05F278 )
    RTL 
}

code_05F26E {
    COP [PrintWideString] ( &widestring_05F29F )
    RTL 
}

code_05F273 {
    COP [PrintWideString] ( &widestring_05F2C7 )
    RTL 
}

widestring_05F278 `[DEF][TPL:3]Erik: [N]It's scary... I'll stay [N]with Neil.[PAL:0][END]`

widestring_05F29F `[DEF][TPL:3]Erik: [N]What's going to [N]happen? It's exciting![PAL:0][END]`

widestring_05F2C7 `[DEF][TPL:3]Erik:[N]What's going to[N]happen... It's exciting![PAL:0][END]`