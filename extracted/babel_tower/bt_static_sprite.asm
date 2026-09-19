?INCLUDE 'spriteset_enemies'

---------------------------------------------

bt_static_sprite {
    LDA #$1000
    TSB $12
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #2C )
    COP [AnimOnce]
    RTL 
}