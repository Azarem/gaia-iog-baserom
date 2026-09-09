?INCLUDE 'table_0EE000'

---------------------------------------------

bt_actor_099B1C {
    LDA #$1000
    TSB $12
    COP [SetMetasprite] ( @table_0EE000 )
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #2C )
    COP [AnimOnce]
    RTL 
}