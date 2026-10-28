; Static sprite prop in Tower of Babel. Non-interactive decorative sprite for scene dressing.
---------------------------------------------

?INCLUDE 'spriteset_pickups_effects'

---------------------------------------------

bt_static_sprite {
    LDA #$1000
    TSB $12
    COP [SetMetasprite] ( @spriteset_pickups_effects )
    COP [SetEntryHere]
    COP [StageSpriteFrame] ( #2C )
    COP [AnimOnce]
    RTL 
}