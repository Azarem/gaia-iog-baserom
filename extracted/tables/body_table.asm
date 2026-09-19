; Player form spriteset/tileset pointer table. 9 entries mapping form IDs (Will, Freedan, Shadow, FX variants) to their spriteset data and sprite tile locations for DMA loading.
---------------------------------------------

?BANK 01

?INCLUDE 'spriteset_ability_fx'
?INCLUDE 'spriteset_freedan'
?INCLUDE 'spriteset_freedan_fx'
?INCLUDE 'spriteset_shadow'
?INCLUDE 'spriteset_shadow_fx'
?INCLUDE 'spriteset_shadow_mode'
?INCLUDE 'spriteset_will'
?INCLUDE 'spriteset_will_alt'

---------------------------------------------

; Maps 9 player form IDs to spriteset and sprite tile data locations. Each 6-byte body-entry: { Address spriteset_ptr, @Binary sprite_tiles_ptr }. Forms: Will (normal), Freedan, Shadow, Shadow alt, Will alt, Ability FX, Will FX, Shadow FX, Shadow mode. Referenced by sprite_composition.asm (spriteset/tile DMA source) and actor_execution.asm (form transitions).

body_table [
  body-entry < @spriteset_will, @will_sprites_1A8000 >   ;00
  body-entry < @spriteset_freedan, @free_sprites_1AC000 >   ;01
  body-entry < @spriteset_shadow, @shad_sprites_1BC000 >   ;02
  body-entry < @spriteset_shadow, @shad_sprites_1BC000 >   ;03
  body-entry < @spriteset_will_alt, @will_sprites_1A8000 >   ;04
  body-entry < @spriteset_ability_fx, @abil_sprites_1B8000 >   ;05
  body-entry < @spriteset_freedan_fx, @free_fx_1C8000 >   ;06
  body-entry < @spriteset_shadow_fx, @shad_fx_1CA000 >   ;07
  body-entry < @spriteset_shadow_mode, @shad_sprites_1BC000 >   ;08
]