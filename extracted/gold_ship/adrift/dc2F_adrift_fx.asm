?INCLUDE 'spriteset_field_fx'

---------------------------------------------

dc2F_adrift_fx [
  actor-def < #00, #00, #28, {

  code_0596FD:
    COP [SetAnimScratch] ( @misc_fx_1CD180 )
    COP [SetMetasprite] ( @spriteset_field_fx )
    COP [ResetSpriteInit] ( #00, #$2010 )
    COP [LoadSpriteAnimGlobal]
    RTL 
} >
]