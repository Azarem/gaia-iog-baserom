; Snake pit visual effects.
; 
; Ambient effects for the snake pit area. Provides
; the dark, confined atmosphere of the pit.
---------------------------------------------

?INCLUDE 'spriteset_snake_pit_fx'

---------------------------------------------

awB4_snake_pit_fx [
  actor-def < #00, #00, #28, {

  code_0897CE:
    COP [SetScratchPointer] ( @misc_fx_1CD380 )
    COP [SetMetasprite] ( @spriteset_snake_pit_fx )
    COP [SetTileStreamAnim] ( #00, #$2020 )
    COP [AdvanceSpriteAnim]
    RTL 
} >
]