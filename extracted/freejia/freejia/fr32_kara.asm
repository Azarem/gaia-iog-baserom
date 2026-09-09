!joypadMaskStd                  065A

---------------------------------------------

fr32_kara [
  actor-def < #2B, #00, #10, {

  code_05B053:
    COP [BranchIfFlagByte] ( #65, #01, &code_05B0F6 )
    COP [BranchIfFlagByte] ( #57, #01, &code_05B0F6 )
    COP [BranchIfFlagByte] ( #64, #01, &code_05B0B8 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [StageSpriteMoveY] ( #2F, #12 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #2B, #1E )
    COP [AnimLoop]
    COP [PrintWideString] ( &widestring_05B100 )
    COP [SetFlagByte] ( #02 )
    COP [ExitIfFlagByte] ( #02, #00 )
    COP [StageSpriteFrame] ( #2A )
    COP [AnimOnce]
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_05B14B )
    COP [SetFlagByte] ( #64 )
    COP [SetFlagByte] ( #03 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [WaitByte] ( #1F )
    COP [StageSpriteMoveX] ( #31, #11 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveY] ( #2F, #02, #02 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #31, #09, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #2F, #06, #02 )
    COP [AnimLoop]
} >
]

code_05B0B8 {
    COP [StageSpriteFrame] ( #2D )
    COP [AnimOnce]
    COP [SetTilePos] ( #27, #25 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05B0F8 )
    COP [ExitIfFlagByte] ( #04, #01 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [ClearLowHere]
    COP [StageSpriteMoveY] ( #2F, #12 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #2B )
    COP [AnimOnce]
    COP [WaitByte] ( #1D )
    COP [SetFlagByte] ( #05 )
    COP [WaitByte] ( #1D )
    COP [StageSpriteMoveY] ( #2F, #12 )
    COP [AnimOnce]
    COP [SetFlagByte] ( #57 )
    LDA #$CFF0
    TRB $joypadMaskStd
}

code_05B0F6 {
    COP [Die]
}

code_05B0F8 {
    COP [PrintWideString] ( &widestring_05B16F )
    COP [SetFlagByte] ( #04 )
    RTL 
}

widestring_05B100 `[TPL:E][TPL:1]Kara: Oh, it's nice!! [N]What a great [N]city!!! [FIN]People who live in such [N]a pretty place must [N]have beautiful hearts...[PAL:0][END]`

widestring_05B14B `[TPL:E][TPL:1]Kara: [N]Don't you like it, Will!! [N]Let's go!![PAL:0][END]`

widestring_05B16F `[TPL:E][TPL:1]Kara: [N]This is the hotel! [N]Let's go in![PAL:0][END]`