; Snake pit visual effects.
; 
; Ambient effects for the snake pit area. Provides
; the dark, confined atmosphere of the pit.
---------------------------------------------

?INCLUDE 'spriteset_particle_fx'

---------------------------------------------

awB4_snake_pit_fx [
  actor-def < #00, #00, #28, {

  code_0897CE:
    COP [SetScratchPointer] ( @misc_fx_1CD380 )
    COP [SetMetasprite] ( @spriteset_particle_fx )
    COP [ResetSpriteState] ( #00, #$2020 )
    COP [AdvanceSpriteAnim]
    RTL 
} >
]