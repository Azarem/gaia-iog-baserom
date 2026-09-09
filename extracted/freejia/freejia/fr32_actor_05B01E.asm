?INCLUDE 'table_14C000'

!cameraBoundsY                  06DC

---------------------------------------------

fr32_actor_05B01E [
  actor-def < #00, #00, #28, {

  code_05B021:
    LDA #$0420
    STA $cameraBoundsY
    COP [SpawnAfter] ( @code_05B03E )
    COP [SetAnimScratch] ( @misc_fx_1CD080 )
    COP [SetMetasprite] ( @table_14C000 )
    COP [ResetSpriteInit] ( #00, #$3FE0 )
    COP [LoadSpriteAnimGlobal]
    RTL 
} >
]

code_05B03E {
    COP [SetAnimScratch] ( @misc_fx_1CD080 )
    COP [SetMetasprite] ( @table_14C000 )
    COP [ResetSpriteInit] ( #01, #$3FF0 )
    COP [LoadSpriteAnimGlobal]
    RTL 
}