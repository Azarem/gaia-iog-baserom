; Player form spriteset/tileset pointer table. 9 entries mapping form IDs (Will, Freedan, Shadow, FX variants) to their spriteset data and sprite tile locations for DMA loading.
---------------------------------------------

?BANK 01

?INCLUDE 'table_0E8000'
?INCLUDE 'table_0F8000'
?INCLUDE 'table_0FC000'
?INCLUDE 'table_148000'
?INCLUDE 'table_158000'
?INCLUDE 'table_17A000'
?INCLUDE 'table_17B000'
?INCLUDE 'table_17C000'

---------------------------------------------

; Maps 9 player form IDs to spriteset and sprite tile data locations. Each 6-byte body-entry: { Address spriteset_ptr, @Binary sprite_tiles_ptr }. Forms: Will (normal), Freedan, Shadow, Shadow alt, Will alt, Ability FX, Will FX, Shadow FX, Shadow mode. Referenced by sprite_composition.asm (spriteset/tile DMA source) and actor_execution.asm (form transitions).

body_table [
  body-entry < @table_158000, @will_sprites_1A8000 >   ;00
  body-entry < @table_0E8000, @free_sprites_1AC000 >   ;01
  body-entry < @table_148000, @shad_sprites_1BC000 >   ;02
  body-entry < @table_148000, @shad_sprites_1BC000 >   ;03
  body-entry < @table_0F8000, @will_sprites_1A8000 >   ;04
  body-entry < @table_0FC000, @abil_sprites_1B8000 >   ;05
  body-entry < @table_17A000, @free_fx_1C8000 >   ;06
  body-entry < @table_17B000, @shad_fx_1CA000 >   ;07
  body-entry < @table_17C000, @shad_sprites_1BC000 >   ;08
]