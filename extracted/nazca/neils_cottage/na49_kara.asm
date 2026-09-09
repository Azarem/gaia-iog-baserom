?BANK 05

!joypadMaskStd                  065A

---------------------------------------------

na49_kara [
  actor-def < #1B, #00, #10, {

  code_05E01B:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05E081 )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [StageSpriteLoopMoveY] ( #1F, #05, #12 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #1B )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #04, #01 )
    COP [StageSpriteLoop] ( #1D, #0A )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1A, #14 )
    COP [AnimLoop]
    COP [PrintWideString] ( &widestring_05E086 )
    COP [ClearFlagByte] ( #03 )
    COP [ExitIfFlagByte] ( #05, #01 )
    COP [SetSpritePriority] ( #30 )
    COP [StageSpriteLoopMoveX] ( #20, #03, #12 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #1B )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #06, #01 )
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveX] ( #21, #02, #01 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #1B )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [PrintWideString] ( &widestring_05E0C1 )
    COP [SetFlagByte] ( #07 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05E081 {
    COP [PrintWideString] ( &widestring_05E086 )
    RTL 
}

widestring_05E086 `[TPL:A][TPL:1]Kara: [N]I can't believe it! [FIN]I don't want to breathe[N]the same air as him![END]`

widestring_05E0C1 `[TPL:A][TPL:1]Kara: [N]Cygnus?! [FIN][TPL:6]Neil: That's the [N]Tower of Babel, where [N]Will's father got lost. [FIN]It's in the middle of[N]the ground painting of[N]the big white bird.[END]`