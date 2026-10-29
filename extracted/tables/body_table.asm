; Player body table (Bank 01, 121201-121254): nine 6-byte body-entry rows that choose the sprite set and the tile graphics the player is drawn with. Row layout: { word spriteset pointer, byte spriteset bank, word tile-graphics source address, byte tile-graphics bank } - the extraction shows it as two long pointers, < @spriteset_X, @gfx >.
; 
; Two ways to select a row:
; - characterForm x 6: InitActorFromSceneData (scene entry) and actor_pool.SetActorBody copy the spriteset pointer and bank into the actor ($7F0006, $7F0008) and clear playerFlags bit 15. Only rows 0-3 are reached this way.
; - SetPlayerSpriteDirect (COP #8E, operand 0-8): writes the same two fields, keeps the table offset in animScratch2 ($7F000E) and the row number in $0AC8, and sets playerFlags bit 15 (sprite override).
; 
; DecomposePlayerSprites (sprite_composition) reads row +3 / +5, the tile-graphics source address and bank, for the player's tile DMA list ($06FC / $06FE) in both cases. playerFlags bit 15 only changes where the row offset comes from: animScratch2 when it is set, characterForm x 6 when it is clear. GetPlayerFacingDirection uses $0AC8 - 4 to choose a per-form facing table for rows 4-7.
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
; | $03 | spriteset_shadow ($94) | shad_sprites_1BC000 | Identical to row $02 (characterForm 3; nothing found selects this row, see below) |
; | $04 | spriteset_will_abilities ($8F) | will_sprites_1A8000 | Will's alternate poses: Psycho Dash, Psycho Slider and Spin Dash charge, the flute pose, the hold pose and the credits (all SetPlayerSpriteDirect #04); shares Will's tile graphics |
; | $05 | spriteset_transform_poses ($8F) | abil_sprites_1B8000 | The transform poses: selected only by the seven Transform_* scripts of sE6_gaia (SetPlayerSpriteDirect #05) |
; | $06 | spriteset_freedan_fx ($97) | free_fx_1C8000 | Freedan effect sprites |
; | $07 | spriteset_shadow_fx ($97) | shad_fx_1CA000 | Shadow effect sprites; not selected by any SetPlayerSpriteDirect operand |
; | $08 | spriteset_shadow_aura_body ($97) | shad_sprites_1BC000 | Shadow's Aura body (SetPlayerSpriteDirect #08 in PlayerAuraTransformEntry); shares Shadow's tile graphics |
; 
; Rows 4-7 have a facing table each. FacingFormOffsetTable is indexed by $0AC8 - 4 and holds, in order, FacingData_WillAbilities (row 4, spriteset_will_abilities), FacingData_TransformPoses (row 5, spriteset_transform_poses), FacingData_FreedanFx (row 6, spriteset_freedan_fx) and FacingData_ShadowFx (row 7, spriteset_shadow_fx). With playerFlags bit 15 set, rows 0-3 fall back to FacingDirectionLookup. Row 8 is in neither group: $0AC8 = 8 gives index 8 - 4 = 4, which is not negative, so there is no fallback, and GetPlayerFacingDirection reads FacingFormOffsetTable + 8, past the 4-entry (8-byte) table; the word it reads there is the first two bytes of FacingData_WillAbilities, which follows the table directly. Not traced: whether GetPlayerFacingDirection runs while row 8 is active.
; 
; Selection by number: the only SetPlayerSpriteDirect operands in the scripts are 04, 05, 06 and 08 (24 sites). Row $07 is not selected by any of them. sE6_gaia is the only user of row $05. Row $08 is selected by SetPlayerSpriteDirect #08 in player_transition_handlers.PlayerAuraTransformEntry (item_use_system.UseItem_Aura, Shadow standing still). Nothing found selects row $03 by number (no SetPlayerSpriteDirect #03, and characterForm 3 is not traced), so what makes row $03 reachable is not traced.

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