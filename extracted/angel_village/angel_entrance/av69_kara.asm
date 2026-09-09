---------------------------------------------

av69_kara [
  actor-def < #1B, #00, #10, {

  code_06C34B:
    COP [BranchIfFlagByte] ( #8D, #01, &av69_kara_destroy )
    COP [BranchIfFlagByte] ( #75, #01, &av69_kara_destroy )
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [StageSpriteFrame] ( #1D )
    COP [AnimOnce]
    COP [PrintWideString] ( &widestring_06C3B1 )
    LDA #$0800
    TSB $10
    COP [StageSpriteMoveX] ( #20, #02 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveY] ( #1F, #02, #02 )
    COP [AnimLoop]
    COP [SetFlagByte] ( #03 )
    COP [StageSpriteLoopMoveX] ( #20, #05, #02 )
    COP [AnimLoop]
} >
]

av69_kara_destroy {
    COP [Die]
}
---------------------------------------------

widestring_06C3B1 `[TPL:A][TPL:1]Kara: What! [N]Will! Come with me! [FIN]What are you [N]grinning about? [FIN]I'll explore this place [N]myself. Don't [N]try to follow me![PAL:0][END]`