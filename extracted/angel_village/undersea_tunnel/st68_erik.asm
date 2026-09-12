!gfxCacheIdxB                   064A

---------------------------------------------

st68_erik [
  actor-def < #0A, #00, #10, {

  code_06ADF0:
    LDA $0AA6
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_06ADFC )
} >
]

code_list_06ADFC [
  &code_06AE02   ;00
  &code_06AE62   ;01
  &code_06AE64   ;02
]

code_06AE02 {
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [StageSpriteMoveY] ( #0E, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #10, #02 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #0E, #01 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #10, #03, #02 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #10, #12 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_06AE6B )
    COP [ExitIfFlagByte] ( #04, #01 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveX] ( #11, #03, #01 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #0F, #12 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0D )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_06AE88 )
    INC $0AA6
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #68, #$0070, #$01A0, #03, #$2110 )
    COP [SetEntryContinue]
    RTL 
}

code_06AE62 {
    COP [Die]
}

code_06AE64 {
    COP [SetTilePos] ( #17, #1A )
    COP [SetEntryContinue]
    RTL 
}

code_06AE6B {
    COP [PrintDialogString] ( &dialogstring_06AE70 )
    RTL 
}

dialogstring_06AE70 `[TPL:A][TPL:3]Erik: [N]Hey, [N]don't look![PAL:0][END]`

dialogstring_06AE88 `[TPL:A][TPL:0]In this way, another day [N]passed slowly...[PAL:0][END]`