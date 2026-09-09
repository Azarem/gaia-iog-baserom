---------------------------------------------

h_sc01_worried_woman [
  actor-def < #15, #00, #10, {

  code_0485FE:
    COP [SetOnInteract] ( &code_0486C0 )
    COP [SolidHighHere]
    COP [WaitByte] ( #B3 )
    COP [StageSpriteFrame] ( #14 )
    COP [AnimOnce]
    COP [WaitByte] ( #77 )
    COP [StageSpriteFrame] ( #15 )
    COP [AnimOnce]
    COP [SetEntryDelayExit] ( @code_04861B, #$053C )
} >
]

code_04861B {
    COP [DrawMetatileAbs] ( #2C, #0E, #F9 )
    LDA #$0200
    TSB $12
    COP [StageSpriteFrame] ( #3C )
    COP [AnimOnce]
    LDA #$0200
    TRB $12
    COP [ClearLowHere]
    COP [StageSpriteMoveY] ( #2E, #11 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #30, #10, #12 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #2F, #12 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #2C )
    COP [AnimOnce]
    COP [WaitByte] ( #1D )
    COP [StageSpriteFrame] ( #2D )
    COP [AnimOnce]
    LDA #$0200
    TSB $12
    COP [StageSpriteFrame] ( #3D )
    COP [AnimOnce]
    LDA #$0200
    TRB $12
    COP [DrawMetatileAbs] ( #1C, #0E, #F8 )
    COP [StageSpriteFrame] ( #14 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [WaitByte] ( #EF )
    COP [ClearLowHere]
    COP [StageSpriteFrame] ( #15 )
    COP [AnimOnce]
    COP [DrawMetatileAbs] ( #1C, #0E, #F9 )
    LDA #$0200
    TSB $12
    COP [StageSpriteFrame] ( #3C )
    COP [AnimOnce]
    LDA #$0200
    TRB $12
    COP [StageSpriteMoveY] ( #2E, #11 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #31, #10, #11 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #2F, #12 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #2D )
    COP [AnimOnce]
    LDA #$0200
    TSB $12
    COP [StageSpriteFrame] ( #3D )
    COP [AnimOnce]
    LDA #$0200
    TRB $12
    COP [DrawMetatileAbs] ( #2C, #0E, #F8 )
    COP [StageSpriteFrame] ( #15 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
}

code_0486C0 {
    COP [PrintWideString] ( &widestring_0486C5 )
    RTL 
}

widestring_0486C5 `[DEF]最近 変な 商人が 多くて[N]困っちゃう.[FIN]まものが あらわれるようになって[N]みんな 困ってるっていうのに[N]それを 商売にするんだからね··[END]`