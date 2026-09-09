---------------------------------------------

na4B_kara [
  actor-def < #1B, #00, #10, {

  code_05EC8E:
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [SetOnInteract] ( &code_05ED46 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveX] ( #21, #08, #01 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #1E, #01 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #21, #02, #01 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #1D )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05ED4B )
    LDA #$0200
    TSB $12
    COP [ExitIfFlagByte] ( #05, #01 )
    LDA #$0200
    TRB $12
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveY] ( #1E, #09, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #20, #05, #02 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05ED53 )
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [ClearLowHere]
    COP [SetTilePos] ( #13, #09 )
    COP [StageSpriteFrame] ( #1B )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05ED46 )
    COP [ExitIfFlagByte] ( #08, #01 )
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #09, #01 )
    COP [SetOnInteract] ( &code_05ED5B )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveY] ( #1E, #09, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #21, #06, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #1E, #08, #01 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #0C, #01 )
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    LDA #$0800
    TSB $10
    COP [ExitIfFlagByte] ( #0D, #01 )
    COP [StageSpriteMoveX] ( #20, #12 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
} >
]

code_05ED46 {
    COP [PrintWideString] ( &widestring_05ED60 )
    RTL 
}

code_05ED4B {
    COP [PrintWideString] ( &widestring_05EDA1 )
    COP [SetFlagByte] ( #05 )
    RTL 
}

code_05ED53 {
    COP [PrintWideString] ( &widestring_05EE15 )
    COP [SetFlagByte] ( #06 )
    RTL 
}

code_05ED5B {
    COP [PrintWideString] ( &widestring_05EE7C )
    RTL 
}

widestring_05ED60 `[DEF][TPL:1]Kara: It must [N]be great to paint [N]such a huge painting on [N]a natural canvas.[PAL:0][END]`

widestring_05EDA1 `[DEF][TPL:1]Kara: When you look at [N]it this way, it's like [N]the white lines at an [N]athletic event. [FIN]Maybe the ancient Nazca[N]people ran the 100 yard[N]dash here.[END]`

widestring_05EE15 `[DEF][TPL:1]Kara: This is the [N]Condor's stomach. If [N]you dig here, you [N]might find eggs. [FIN]It's a joke (laughs).[N]Don't be so serious.[END]`

widestring_05EE7C `[DEF][TPL:1]Kara: [N]What an exciting [N]experience...[PAL:0][END]`