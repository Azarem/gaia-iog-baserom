?INCLUDE 'table_0EE000'

---------------------------------------------

nv_actor_0881A5 {
    COP [StageSpriteFrame] ( #30 )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #05, #01 )
}

code_0881AE {
    COP [SetMetasprite] ( @table_0EE000 )
    COP [AddPosition] ( #00, #F6 )
    COP [StageSpriteFrame] ( #07 )
    COP [AnimOnce]
    COP [Die]
}