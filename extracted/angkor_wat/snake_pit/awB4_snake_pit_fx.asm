?INCLUDE 'spriteset_particle_fx'

---------------------------------------------

awB4_snake_pit_fx [
  actor-def < #00, #00, #28, {

  code_0897CE:
    COP [SetAnimScratch] ( @misc_fx_1CD380 )
    COP [SetMetasprite] ( @spriteset_particle_fx )
    COP [ResetSpriteInit] ( #00, #$2020 )
    COP [LoadSpriteAnimGlobal]
    RTL 
} >
]