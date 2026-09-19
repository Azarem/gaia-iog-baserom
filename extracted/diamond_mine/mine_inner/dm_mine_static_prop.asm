---------------------------------------------

dm_mine_static_prop {
    LDA #$0030
    TSB $12
    COP [OrActorFlags] ( #$0080 )
    COP [StageSpriteFrame] ( #29 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
}