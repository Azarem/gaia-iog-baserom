; Sprite map of the Dark Space / Gaia hub: 11 animations, 34 sprite-groups. scene_meta_00E6 (the hub, sE6_gaia) and scene_meta_0010 (music bgm_descent_into_darkness) both load it ($0579 bytes) with gfx_darkspace_sprites and pal_darkspace_sprites. FireflyParticle and DarkSpaceExit use spriteset_pickups_effects, not this file.
; 
; === ANIMATIONS ===
; 
; - #00 spm_darkspace_sprites_sprite_set_000016: 4 frames, holds $63, $0C, $0C, $0C (100, 13, 13, 13 ticks), groups spm_darkspace_sprites_sprite_group_000150, spm_darkspace_sprites_sprite_group_00016B, spm_darkspace_sprites_sprite_group_000186, spm_darkspace_sprites_sprite_group_00016B: a 32 x 16 figure drawn as a 16 x 16 half plus its H-flipped copy (tile words $0900, $0902, $0904 and the same with $4000). GaiaNpcSprite plays it once per run.
; - #01 spm_darkspace_sprites_sprite_set_000028, #02 spm_darkspace_sprites_sprite_set_00003A, #03 spm_darkspace_sprites_sprite_set_00004C: 4 frames of hold 9 (10 ticks), shared frame 0 (spm_darkspace_sprites_sprite_group_0001A1) and two variants (A B C B). 32 x 24 px, 4 parts (two 16 x 16 halves in each of two rows, tile words $0920 / $0930 and their +2 variants). They are the three voice sparkles of GaiaVoiceSparkle.
; - #04 spm_darkspace_sprites_sprite_set_00005E: 4 frames of hold 7 (8 ticks), 16 x 24-26 px, five 8 x 8 parts (tiles $0350-$0352, $0370).
; - #05 spm_darkspace_sprites_sprite_set_000070: 7 frames of one 8 x 8 part (tile $0380, the sixth frame $0371) at Y offsets $0B to $08; holds 7, 7, 7, $1B, 7, 7, 9.
; - #06 spm_darkspace_sprites_sprite_set_00008E: 2 frames of hold 7 (the groups of the fourth and fifth frame of #05).
; - #07 spm_darkspace_sprites_sprite_set_000098, #08 spm_darkspace_sprites_sprite_set_0000AA, #09 spm_darkspace_sprites_sprite_set_0000BC: a 32 x 32 px figure of 4 parts (three 16 x 16, tile words $0990, $0992, $0972, and one 8 x 8, $0981), 4 frames each. #07 holds 7, 7, 7, 7; #08 holds 7, 5, 3, 6; #09 holds 6, 2, 3, 0.
; - #0A spm_darkspace_sprites_sprite_set_0000CE: 32 frames of hold 0 (1 tick): a 16 x 16 spark (eight groups, tile words $09E0-$09EE, each shown twice) alternates with the 8 x 8 dot of spm_darkspace_sprites_sprite_group_000565 (tile $0BD0). It is the ability orb (AbilityOrbActor: StageSprAndHitbox #0A and StageSpriteLoopMoveY #0A, #03, #14).
; 
; sE6_gaia does not select #04 to #09, and no other user was found in extracted/ (its Transform_* scripts play the player's body spriteset with SetPlayerSpriteDirect #05, not this file). Not traced: what #04-#09 draw.
; 
; === FORMAT ===
; 
; A sprite map file has three layers (same format as the spriteset_* files, see spriteset_freedan):
; - Pointer table (the first label): one word per animation index. The engine reads entry $28 of the actor (UpdateActorAnimation: table + 2 x $28), then the frame record $2A x 4 inside that list.
; - Sprite-set (frame list): 4-byte records < hold, &sprite_group >, closed by a hidden $FFFF. A frame is shown for hold + 1 ticks.
; - Sprite-group: 12 header bytes, the part count, then 7-byte sprite-parts. Bytes 0-3 are the X extents (left, right) and Y extents (above, below) of the frame box; UpdateActorAnimation loads them into $18/$1C and $1A/$1E and swaps each pair for a flipped actor. Bytes 4-7 are a tile-unit box (X offset, Y offset, width and height in 16-pixel units) read by PlayerAttackHitTest, the solid-rectangle COP handlers and the tile collision code (tile_collision_physics); bytes 8-11 are the body box (X offset, width, Y offset, height in pixels, signed offsets) read by CombatCollision and the interaction collision code.
; - Sprite-part < size, x, x', y, y', tile word >: size 0 = 8 x 8, 1 = 16 x 16 (the OAM size bit); x and y are offsets inside the extent box, x' and y' the offsets used when the actor is H / V flipped (x + x' = box width - part width); the tile word is an OAM word (bit 8 name table, bits 9-11 palette, bits 12-13 priority, $4000 H flip, $8000 V flip) that the engine XORs with the actor's attribute word $0E.
; Every group of this file carries the engine's default boxes ($F8 $F0 $01 $01 and $F8 $10 $F0 $10): the same eight bytes are in all 85 groups of spm_boot_logos, spm_title_actors, spm_darkspace_sprites and spm_overworld_sprites.
---------------------------------------------

---------------------------------------------

; Animation table: #00 Gaia NPC, #01-#03 the three voice sparkles, #04-#09 not selected by sE6_gaia, #0A the ability orb.

spm_darkspace_sprites [
  &spm_darkspace_sprites_sprite_set_000016   ;00
  &spm_darkspace_sprites_sprite_set_000028   ;01
  &spm_darkspace_sprites_sprite_set_00003A   ;02
  &spm_darkspace_sprites_sprite_set_00004C   ;03
  &spm_darkspace_sprites_sprite_set_00005E   ;04
  &spm_darkspace_sprites_sprite_set_000070   ;05
  &spm_darkspace_sprites_sprite_set_00008E   ;06
  &spm_darkspace_sprites_sprite_set_000098   ;07
  &spm_darkspace_sprites_sprite_set_0000AA   ;08
  &spm_darkspace_sprites_sprite_set_0000BC   ;09
  &spm_darkspace_sprites_sprite_set_0000CE   ;0A
]

spm_darkspace_sprites_sprite_set_000016 [
  sprite-set < #$0063, &spm_darkspace_sprites_sprite_group_000150 >   ;00
  sprite-set < #$000C, &spm_darkspace_sprites_sprite_group_00016B >   ;01
  sprite-set < #$000C, &spm_darkspace_sprites_sprite_group_000186 >   ;02
  sprite-set < #$000C, &spm_darkspace_sprites_sprite_group_00016B >   ;03
]

spm_darkspace_sprites_sprite_set_000028 [
  sprite-set < #$0009, &spm_darkspace_sprites_sprite_group_0001A1 >   ;00
  sprite-set < #$0009, &spm_darkspace_sprites_sprite_group_0001CA >   ;01
  sprite-set < #$0009, &spm_darkspace_sprites_sprite_group_0001F3 >   ;02
  sprite-set < #$0009, &spm_darkspace_sprites_sprite_group_0001CA >   ;03
]

spm_darkspace_sprites_sprite_set_00003A [
  sprite-set < #$0009, &spm_darkspace_sprites_sprite_group_0001A1 >   ;00
  sprite-set < #$0009, &spm_darkspace_sprites_sprite_group_00021C >   ;01
  sprite-set < #$0009, &spm_darkspace_sprites_sprite_group_000245 >   ;02
  sprite-set < #$0009, &spm_darkspace_sprites_sprite_group_00021C >   ;03
]

spm_darkspace_sprites_sprite_set_00004C [
  sprite-set < #$0009, &spm_darkspace_sprites_sprite_group_0001A1 >   ;00
  sprite-set < #$0009, &spm_darkspace_sprites_sprite_group_00026E >   ;01
  sprite-set < #$0009, &spm_darkspace_sprites_sprite_group_000297 >   ;02
  sprite-set < #$0009, &spm_darkspace_sprites_sprite_group_00026E >   ;03
]

spm_darkspace_sprites_sprite_set_00005E [
  sprite-set < #$0007, &spm_darkspace_sprites_sprite_group_0002C0 >   ;00
  sprite-set < #$0007, &spm_darkspace_sprites_sprite_group_0002F0 >   ;01
  sprite-set < #$0007, &spm_darkspace_sprites_sprite_group_000320 >   ;02
  sprite-set < #$0007, &spm_darkspace_sprites_sprite_group_000350 >   ;03
]

spm_darkspace_sprites_sprite_set_000070 [
  sprite-set < #$0007, &spm_darkspace_sprites_sprite_group_000380 >   ;00
  sprite-set < #$0007, &spm_darkspace_sprites_sprite_group_000394 >   ;01
  sprite-set < #$0007, &spm_darkspace_sprites_sprite_group_0003A8 >   ;02
  sprite-set < #$001B, &spm_darkspace_sprites_sprite_group_0003BC >   ;03
  sprite-set < #$0007, &spm_darkspace_sprites_sprite_group_00044B >   ;04
  sprite-set < #$0007, &spm_darkspace_sprites_sprite_group_00045F >   ;05
  sprite-set < #$0009, &spm_darkspace_sprites_sprite_group_0003BC >   ;06
]

spm_darkspace_sprites_sprite_set_00008E [
  sprite-set < #$0007, &spm_darkspace_sprites_sprite_group_0003BC >   ;00
  sprite-set < #$0007, &spm_darkspace_sprites_sprite_group_00044B >   ;01
]

spm_darkspace_sprites_sprite_set_000098 [
  sprite-set < #$0007, &spm_darkspace_sprites_sprite_group_000422 >   ;00
  sprite-set < #$0007, &spm_darkspace_sprites_sprite_group_0003F9 >   ;01
  sprite-set < #$0007, &spm_darkspace_sprites_sprite_group_0003D0 >   ;02
  sprite-set < #$0007, &spm_darkspace_sprites_sprite_group_0003F9 >   ;03
]

spm_darkspace_sprites_sprite_set_0000AA [
  sprite-set < #$0007, &spm_darkspace_sprites_sprite_group_000422 >   ;00
  sprite-set < #$0005, &spm_darkspace_sprites_sprite_group_000473 >   ;01
  sprite-set < #$0003, &spm_darkspace_sprites_sprite_group_0003F9 >   ;02
  sprite-set < #$0006, &spm_darkspace_sprites_sprite_group_000473 >   ;03
]

spm_darkspace_sprites_sprite_set_0000BC [
  sprite-set < #$0006, &spm_darkspace_sprites_sprite_group_000422 >   ;00
  sprite-set < #$0002, &spm_darkspace_sprites_sprite_group_000473 >   ;01
  sprite-set < #$0003, &spm_darkspace_sprites_sprite_group_00049C >   ;02
  sprite-set < #$0000, &spm_darkspace_sprites_sprite_group_000473 >   ;03
]

spm_darkspace_sprites_sprite_set_0000CE [
  sprite-set < #$0000, &spm_darkspace_sprites_sprite_group_0004C5 >   ;00
  sprite-set < #$0000, &spm_darkspace_sprites_sprite_group_000565 >   ;01
  sprite-set < #$0000, &spm_darkspace_sprites_sprite_group_0004C5 >   ;02
  sprite-set < #$0000, &spm_darkspace_sprites_sprite_group_000565 >   ;03
  sprite-set < #$0000, &spm_darkspace_sprites_sprite_group_0004D9 >   ;04
  sprite-set < #$0000, &spm_darkspace_sprites_sprite_group_000565 >   ;05
  sprite-set < #$0000, &spm_darkspace_sprites_sprite_group_0004D9 >   ;06
  sprite-set < #$0000, &spm_darkspace_sprites_sprite_group_000565 >   ;07
  sprite-set < #$0000, &spm_darkspace_sprites_sprite_group_0004ED >   ;08
  sprite-set < #$0000, &spm_darkspace_sprites_sprite_group_000565 >   ;09
  sprite-set < #$0000, &spm_darkspace_sprites_sprite_group_0004ED >   ;0A
  sprite-set < #$0000, &spm_darkspace_sprites_sprite_group_000565 >   ;0B
  sprite-set < #$0000, &spm_darkspace_sprites_sprite_group_000501 >   ;0C
  sprite-set < #$0000, &spm_darkspace_sprites_sprite_group_000565 >   ;0D
  sprite-set < #$0000, &spm_darkspace_sprites_sprite_group_000501 >   ;0E
  sprite-set < #$0000, &spm_darkspace_sprites_sprite_group_000565 >   ;0F
  sprite-set < #$0000, &spm_darkspace_sprites_sprite_group_000515 >   ;10
  sprite-set < #$0000, &spm_darkspace_sprites_sprite_group_000565 >   ;11
  sprite-set < #$0000, &spm_darkspace_sprites_sprite_group_000515 >   ;12
  sprite-set < #$0000, &spm_darkspace_sprites_sprite_group_000565 >   ;13
  sprite-set < #$0000, &spm_darkspace_sprites_sprite_group_000529 >   ;14
  sprite-set < #$0000, &spm_darkspace_sprites_sprite_group_000565 >   ;15
  sprite-set < #$0000, &spm_darkspace_sprites_sprite_group_000529 >   ;16
  sprite-set < #$0000, &spm_darkspace_sprites_sprite_group_000565 >   ;17
  sprite-set < #$0000, &spm_darkspace_sprites_sprite_group_00053D >   ;18
  sprite-set < #$0000, &spm_darkspace_sprites_sprite_group_000565 >   ;19
  sprite-set < #$0000, &spm_darkspace_sprites_sprite_group_00053D >   ;1A
  sprite-set < #$0000, &spm_darkspace_sprites_sprite_group_000565 >   ;1B
  sprite-set < #$0000, &spm_darkspace_sprites_sprite_group_000551 >   ;1C
  sprite-set < #$0000, &spm_darkspace_sprites_sprite_group_000565 >   ;1D
  sprite-set < #$0000, &spm_darkspace_sprites_sprite_group_000551 >   ;1E
  sprite-set < #$0000, &spm_darkspace_sprites_sprite_group_000565 >   ;1F
]

spm_darkspace_sprites_sprite_group_000150 [
  sprite-group < #10, #10, #10, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #02, [
    sprite-part < #01, #00, #10, #00, #00, #$0900 >   ;00
    sprite-part < #01, #10, #00, #00, #00, #$4900 >   ;01
  ] >
]

spm_darkspace_sprites_sprite_group_00016B [
  sprite-group < #10, #10, #10, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #02, [
    sprite-part < #01, #00, #10, #00, #00, #$0902 >   ;00
    sprite-part < #01, #10, #00, #00, #00, #$4902 >   ;01
  ] >
]

spm_darkspace_sprites_sprite_group_000186 [
  sprite-group < #10, #10, #10, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #02, [
    sprite-part < #01, #00, #10, #00, #00, #$0904 >   ;00
    sprite-part < #01, #10, #00, #00, #00, #$4904 >   ;01
  ] >
]

spm_darkspace_sprites_sprite_group_0001A1 [
  sprite-group < #10, #10, #18, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #04, [
    sprite-part < #01, #00, #10, #00, #08, #$0920 >   ;00
    sprite-part < #01, #10, #00, #00, #08, #$4920 >   ;01
    sprite-part < #01, #00, #10, #08, #00, #$0930 >   ;02
    sprite-part < #01, #10, #00, #08, #00, #$4930 >   ;03
  ] >
]

spm_darkspace_sprites_sprite_group_0001CA [
  sprite-group < #10, #10, #18, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #04, [
    sprite-part < #01, #00, #10, #00, #08, #$0922 >   ;00
    sprite-part < #01, #10, #00, #00, #08, #$4922 >   ;01
    sprite-part < #01, #00, #10, #08, #00, #$0932 >   ;02
    sprite-part < #01, #10, #00, #08, #00, #$4932 >   ;03
  ] >
]

spm_darkspace_sprites_sprite_group_0001F3 [
  sprite-group < #10, #10, #18, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #04, [
    sprite-part < #01, #00, #10, #00, #08, #$0924 >   ;00
    sprite-part < #01, #10, #00, #00, #08, #$4924 >   ;01
    sprite-part < #01, #00, #10, #08, #00, #$0934 >   ;02
    sprite-part < #01, #10, #00, #08, #00, #$4934 >   ;03
  ] >
]

spm_darkspace_sprites_sprite_group_00021C [
  sprite-group < #10, #10, #18, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #04, [
    sprite-part < #01, #00, #10, #00, #08, #$0906 >   ;00
    sprite-part < #01, #10, #00, #00, #08, #$4906 >   ;01
    sprite-part < #01, #00, #10, #08, #00, #$0916 >   ;02
    sprite-part < #01, #10, #00, #08, #00, #$4916 >   ;03
  ] >
]

spm_darkspace_sprites_sprite_group_000245 [
  sprite-group < #10, #10, #18, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #04, [
    sprite-part < #01, #00, #10, #00, #08, #$0908 >   ;00
    sprite-part < #01, #10, #00, #00, #08, #$4908 >   ;01
    sprite-part < #01, #00, #10, #08, #00, #$0918 >   ;02
    sprite-part < #01, #10, #00, #08, #00, #$4918 >   ;03
  ] >
]

spm_darkspace_sprites_sprite_group_00026E [
  sprite-group < #10, #10, #18, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #04, [
    sprite-part < #01, #00, #10, #00, #08, #$090A >   ;00
    sprite-part < #01, #10, #00, #00, #08, #$490A >   ;01
    sprite-part < #01, #00, #10, #08, #00, #$091A >   ;02
    sprite-part < #01, #10, #00, #08, #00, #$491A >   ;03
  ] >
]

spm_darkspace_sprites_sprite_group_000297 [
  sprite-group < #10, #10, #18, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #04, [
    sprite-part < #01, #00, #10, #00, #08, #$090C >   ;00
    sprite-part < #01, #10, #00, #00, #08, #$490C >   ;01
    sprite-part < #01, #00, #10, #08, #00, #$091C >   ;02
    sprite-part < #01, #10, #00, #08, #00, #$491C >   ;03
  ] >
]

spm_darkspace_sprites_sprite_group_0002C0 [
  sprite-group < #08, #08, #18, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #05, [
    sprite-part < #00, #00, #08, #10, #00, #$0370 >   ;00
    sprite-part < #00, #08, #00, #10, #00, #$4370 >   ;01
    sprite-part < #00, #00, #08, #08, #08, #$0351 >   ;02
    sprite-part < #00, #08, #00, #08, #08, #$0352 >   ;03
    sprite-part < #00, #04, #04, #00, #10, #$0350 >   ;04
  ] >
]

spm_darkspace_sprites_sprite_group_0002F0 [
  sprite-group < #08, #08, #19, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #05, [
    sprite-part < #00, #00, #08, #10, #01, #$0370 >   ;00
    sprite-part < #00, #08, #00, #10, #01, #$4370 >   ;01
    sprite-part < #00, #00, #08, #08, #09, #$0354 >   ;02
    sprite-part < #00, #08, #00, #08, #09, #$0355 >   ;03
    sprite-part < #00, #04, #04, #00, #11, #$0353 >   ;04
  ] >
]

spm_darkspace_sprites_sprite_group_000320 [
  sprite-group < #08, #08, #1A, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #05, [
    sprite-part < #00, #00, #08, #10, #02, #$0370 >   ;00
    sprite-part < #00, #08, #00, #10, #02, #$4370 >   ;01
    sprite-part < #00, #00, #08, #08, #0A, #$0361 >   ;02
    sprite-part < #00, #08, #00, #08, #0A, #$0362 >   ;03
    sprite-part < #00, #04, #04, #00, #12, #$0360 >   ;04
  ] >
]

spm_darkspace_sprites_sprite_group_000350 [
  sprite-group < #08, #08, #19, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #05, [
    sprite-part < #00, #00, #08, #10, #01, #$0370 >   ;00
    sprite-part < #00, #08, #00, #10, #01, #$4370 >   ;01
    sprite-part < #00, #00, #08, #08, #09, #$0364 >   ;02
    sprite-part < #00, #08, #00, #08, #09, #$0365 >   ;03
    sprite-part < #00, #02, #06, #00, #11, #$0363 >   ;04
  ] >
]

spm_darkspace_sprites_sprite_group_000380 [
  sprite-group < #06, #02, #13, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #00, #00, #00, #00, #0B, #$0380 >
  ] >
]

spm_darkspace_sprites_sprite_group_000394 [
  sprite-group < #03, #05, #13, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #00, #00, #00, #00, #0B, #$0380 >
  ] >
]

spm_darkspace_sprites_sprite_group_0003A8 [
  sprite-group < #02, #06, #12, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #00, #00, #00, #00, #0A, #$0380 >
  ] >
]

spm_darkspace_sprites_sprite_group_0003BC [
  sprite-group < #00, #08, #11, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #00, #00, #00, #00, #09, #$0380 >
  ] >
]

spm_darkspace_sprites_sprite_group_0003D0 [
  sprite-group < #13, #0D, #10, #10, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #04, [
    sprite-part < #01, #00, #10, #10, #00, #$0990 >   ;00
    sprite-part < #01, #10, #00, #10, #00, #$0992 >   ;01
    sprite-part < #01, #10, #00, #00, #10, #$0972 >   ;02
    sprite-part < #00, #08, #10, #08, #10, #$0981 >   ;03
  ] >
]

spm_darkspace_sprites_sprite_group_0003F9 [
  sprite-group < #13, #0D, #11, #0F, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #04, [
    sprite-part < #01, #00, #10, #10, #00, #$0990 >   ;00
    sprite-part < #00, #08, #10, #08, #10, #$0981 >   ;01
    sprite-part < #01, #10, #00, #10, #00, #$0992 >   ;02
    sprite-part < #01, #10, #00, #00, #10, #$0972 >   ;03
  ] >
]

spm_darkspace_sprites_sprite_group_000422 [
  sprite-group < #12, #0E, #13, #0D, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #04, [
    sprite-part < #01, #00, #10, #10, #00, #$0990 >   ;00
    sprite-part < #01, #10, #00, #10, #00, #$0992 >   ;01
    sprite-part < #00, #08, #10, #08, #10, #$0981 >   ;02
    sprite-part < #01, #10, #00, #00, #10, #$0972 >   ;03
  ] >
]

spm_darkspace_sprites_sprite_group_00044B [
  sprite-group < #00, #08, #10, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #00, #00, #00, #00, #08, #$0380 >
  ] >
]

spm_darkspace_sprites_sprite_group_00045F [
  sprite-group < #00, #08, #10, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #00, #00, #00, #00, #08, #$0371 >
  ] >
]

spm_darkspace_sprites_sprite_group_000473 [
  sprite-group < #12, #0E, #12, #0E, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #04, [
    sprite-part < #01, #00, #10, #10, #00, #$0990 >   ;00
    sprite-part < #01, #10, #00, #10, #00, #$0992 >   ;01
    sprite-part < #00, #08, #10, #08, #10, #$0981 >   ;02
    sprite-part < #01, #10, #00, #00, #10, #$0972 >   ;03
  ] >
]

spm_darkspace_sprites_sprite_group_00049C [
  sprite-group < #12, #0E, #0F, #11, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #04, [
    sprite-part < #01, #10, #00, #10, #00, #$0992 >   ;00
    sprite-part < #01, #00, #10, #10, #00, #$0990 >   ;01
    sprite-part < #01, #10, #00, #00, #10, #$0972 >   ;02
    sprite-part < #00, #08, #10, #08, #10, #$0981 >   ;03
  ] >
]

spm_darkspace_sprites_sprite_group_0004C5 [
  sprite-group < #08, #08, #10, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #01, #00, #00, #00, #00, #$09E0 >
  ] >
]

spm_darkspace_sprites_sprite_group_0004D9 [
  sprite-group < #08, #08, #11, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #01, #00, #00, #00, #01, #$09E2 >
  ] >
]

spm_darkspace_sprites_sprite_group_0004ED [
  sprite-group < #08, #08, #12, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #01, #00, #00, #00, #02, #$09E4 >
  ] >
]

spm_darkspace_sprites_sprite_group_000501 [
  sprite-group < #08, #08, #11, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #01, #00, #00, #00, #01, #$09E6 >
  ] >
]

spm_darkspace_sprites_sprite_group_000515 [
  sprite-group < #08, #08, #10, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #01, #00, #00, #00, #00, #$09E8 >
  ] >
]

spm_darkspace_sprites_sprite_group_000529 [
  sprite-group < #08, #08, #0F, #01, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #01, #00, #00, #00, #00, #$09EA >
  ] >
]

spm_darkspace_sprites_sprite_group_00053D [
  sprite-group < #08, #08, #0E, #02, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #01, #00, #00, #00, #00, #$09EC >
  ] >
]

spm_darkspace_sprites_sprite_group_000551 [
  sprite-group < #08, #08, #0F, #01, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #01, #00, #00, #00, #00, #$09EE >
  ] >
]

spm_darkspace_sprites_sprite_group_000565 [
  sprite-group < #08, #00, #08, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #00, #00, #00, #00, #00, #$0BD0 >
  ] >
]