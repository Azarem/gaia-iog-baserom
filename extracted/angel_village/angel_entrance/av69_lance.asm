!joypadMaskStd                  065A

---------------------------------------------

av69_lance [
  actor-def < #03, #00, #10, {

  code_06BA88:
    COP [BranchIfFlagByte] ( #8D, #01, &av69_lance_destroy )
    COP [BranchIfFlagByte] ( #75, #01, &av69_lance_destroy )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_06BAFA )
    COP [StageSpriteLoopMoveY] ( #07, #02, #02 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #08, #12 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    COP [PrintWideString] ( &widestring_06BB50 )
    COP [SetFlagByte] ( #01 )
    COP [StageSpriteLoop] ( #05, #1E )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #04, #01 )
    COP [SetFlagByte] ( #75 )
    COP [StageSpriteMoveX] ( #08, #12 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveY] ( #07, #02, #02 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #09, #01 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #09, #11 )
    COP [AnimOnce]
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [StageSpriteMoveY] ( #06, #11 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveY] ( #07, #02, #13 )
    COP [AnimLoop]
} >
]

av69_lance_destroy {
    COP [Die]
}

widestring_06BAFA `[TPL:B][TPL:6]Neil: We're here [N]at last. We've walked[N]through the tunnel for[N]almost a month... [FIN][TPL:4]Lance: [N]Look! A sign![PAL:0][END]`

widestring_06BB50 `[TPL:A][TPL:4]Lance: What? [N]Angel Tribe? Travellers, [N]please use this room?[FIN][TPL:6]Neil: Angels living [N]in a place like this? [FIN][TPL:6]Neil: They say angels [N]don't like meeting [N]with people. [FIN]First we can rest in[N]that room...[PAL:0][END]`