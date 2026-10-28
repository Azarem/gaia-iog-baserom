; Player body table (Bank 01, 121201-121254): nine 6-byte body-entry rows that choose the sprite set and the tile graphics the player is drawn with. Row layout: { word spriteset pointer, byte spriteset bank, word tile-graphics source address, byte tile-graphics bank } - the extraction shows it as two long pointers, < @spriteset_X, @gfx >.
; 
; Two ways to select a row:
; - characterForm x 6: InitActorFromSceneData (scene entry) and actor_pool.SetActorBody copy the spriteset pointer and bank into the actor ($7F0006, $7F0008) and clear playerFlags bit 15. Only rows 0-3 are reached this way.
; - SetPlayerSpriteDirect (COP #8E, operand 0-8): writes the same two fields, keeps the table offset in animScratch2 ($7F000E) and the row number in $0AC8, and sets playerFlags bit 15 (sprite override). While bit 15 is set, DecomposePlayerSprites (sprite_composition) reads row +3 / +5, the tile-graphics source address and bank, for the player's tile DMA list ($06FC / $06FE). GetPlayerFacingDirection uses $0AC8 - 4 to choose a per-form facing table for rows 4-7.
; 
; The old header listed the rows as Will, Freedan, Shadow, Shadow alt, Will alt, Ability FX, Will FX, Shadow FX, Shadow mode. There is no 'Will FX' row and row 3 is not an alternate: it is a copy of row 2 (see the part note).
; 
; Checked: rows decoded from the extraction, every body_table consumer read (sprite_composition, actor_execution, actor_pool, cop_handlers_player_sprite, GetPlayerFacingDirection, slider_glide). The spriteset banks come from cop_handlers_player_sprite and slider_glide ($95 Will, $8E Freedan, $94 Shadow, $8F rows 4-5, $97 rows 6-8). Not traced at runtime (UNVERIFIED-RUNTIME).
---------------------------------------------

?BANK 01

?INCLUDE 'spriteset_freedan'
?INCLUDE 'spriteset_freedan_fx'
?INCLUDE 'spriteset_shadow'
?INCLUDE 'spriteset_shadow_aura_body'
?INCLUDE 'spriteset_shadow_fx'
?INCLUDE 'spriteset_transform_poses'
?INCLUDE 'spriteset_will'
?INCLUDE 'spriteset_will_abilities'

---------------------------------------------

; | Row | Spriteset (bank) | Tile graphics | Use |
; |-----|------------------|---------------|-----|
; | $00 | spriteset_will ($95) | will_sprites_1A8000 | Will, normal body (characterForm 0) |
; | $01 | spriteset_freedan ($8E) | free_sprites_1AC000 | Freedan (characterForm 1) |
; | $02 | spriteset_shadow ($94) | shad_sprites_1BC000 | Shadow (characterForm 2) |
; | $03 | spriteset_shadow ($94) | shad_sprites_1BC000 | Identical to row $02 (characterForm 3, see OQ-I061-1) |
; | $04 | spriteset_will_abilities ($8F) | will_sprites_1A8000 | Will's alternate poses: Psycho Dash, Psycho Slider and Spin Dash charge, the flute pose, the hold pose and the credits (all SetPlayerSpriteDirect #04); shares Will's tile graphics |
; | $05 | spriteset_transform_poses ($8F) | abil_sprites_1B8000 | Ability poses and effects |
; | $06 | spriteset_freedan_fx ($97) | free_fx_1C8000 | Freedan effect sprites |
; | $07 | spriteset_shadow_fx ($97) | shad_fx_1CA000 | Shadow effect sprites |
; | $08 | spriteset_shadow_aura_body ($97) | shad_sprites_1BC000 | Shadow's Aura body (SetPlayerSpriteDirect #08 in PlayerAuraTransformEntry); shares Shadow's tile graphics |
; 
; Rows 4-7 have a facing table each (FacingFormOffsetTable: will_alt, ability_fx, freedan_fx, shadow_fx); rows 0-3 and 8 use FacingDirectionLookup. Row $08 is selected by SetPlayerSpriteDirect #08 in player_transition_handlers.PlayerAuraTransformEntry (item_use_system.UseItem_Aura, Shadow standing still). Nothing found selects row $03 by number (no SetPlayerSpriteDirect #03 and characterForm 3 is not traced), so what makes row $03 reachable is open (OQ-I061-1).

body_table [
  body-entry < @spriteset_will, @will_sprites_1A8000 >   ;00
  body-entry < @spriteset_freedan, @free_sprites_1AC000 >   ;01
  body-entry < @spriteset_shadow, @shad_sprites_1BC000 >   ;02
  body-entry < @spriteset_shadow, @shad_sprites_1BC000 >   ;03
  body-entry < @spriteset_will_abilities, @will_sprites_1A8000 >   ;04
  body-entry < @spriteset_transform_poses, @abil_sprites_1B8000 >   ;05
  body-entry < @spriteset_freedan_fx, @free_fx_1C8000 >   ;06
  body-entry < @spriteset_shadow_fx, @shad_fx_1CA000 >   ;07
  body-entry < @spriteset_shadow_aura_body, @shad_sprites_1BC000 >   ;08
]