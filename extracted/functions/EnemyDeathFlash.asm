; Minimal enemy death flash: sets metasprite, palette #00, animates sprite frame #01 once with flag $2000, then dies.
; 
; Spawned at enemy death positions by combat handlers and boss scripts. Brief white flash marking an enemy's defeat.
---------------------------------------------

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