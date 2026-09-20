; Static decorative prop in the Diamond Mine inner area. Non-interactive scene element.
---------------------------------------------

---------------------------------------------

dm_mine_static_prop {
    LDA #$0030
    TSB $12
    COP [OrExtraFlags] ( #$0080 )
    COP [StageSpriteFrame] ( #29 )
    COP [AnimOnce]
    COP [SetEntryHere]
    RTL 
}