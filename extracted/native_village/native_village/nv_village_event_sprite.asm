?INCLUDE 'spriteset_enemies'

---------------------------------------------

nv_village_event_sprite {
    COP [StageSpriteFrame] ( #30 )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #05, #01 )
}

code_0881AE {
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [AddPosition] ( #00, #F6 )
    COP [StageSpriteFrame] ( #07 )
    COP [AnimOnce]
    COP [Die]
}