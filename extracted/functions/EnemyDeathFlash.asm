?INCLUDE 'table_0EE000'

---------------------------------------------

EnemyDeathFlash {
    COP [SetMetasprite] ( @table_0EE000 )
    COP [SetSpritePalette] ( #00 )
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    LDA #$2000
    TSB $10
    COP [Die]
}