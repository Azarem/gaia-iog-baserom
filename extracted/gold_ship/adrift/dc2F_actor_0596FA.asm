?INCLUDE 'table_14C0C8'

---------------------------------------------

dc2F_actor_0596FA [
  actor-def < #00, #00, #28, {

  code_0596FD:
    COP [SetAnimScratch] ( @misc_fx_1CD180 )
    COP [SetMetasprite] ( @table_14C0C8 )
    COP [ResetSpriteInit] ( #00, #$2010 )
    COP [LoadSpriteAnimGlobal]
    RTL 
} >
]