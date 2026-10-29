; Sprite map of the boot logo scene $FB: 2 animations, 2 sprite-groups, 51 parts. scene_meta_00FB loads it ($018F bytes) to $7E4000 as the actor spriteset; sFB_boot_logo selects the animations with StageSpriteLoop and plays them with AnimLoop. Colours: pal_boot_logos (80 colours, OBJ palettes 0 to 4).
; 
; === ANIMATIONS ===
; 
; - #00 spm_boot_logos_sprite_set_000004: one frame, hold $3B (60 ticks), spm_boot_logos_sprite_group_000010 = the second logo (Enix): box 122 x 156 px, 35 parts.
; - #01 spm_boot_logos_sprite_set_00000A: one frame, hold $3B (60 ticks), spm_boot_logos_sprite_group_000112 = the first logo: box 96 x 48 px, 16 parts.
; 
; === FORMAT ===
; 
; A sprite map file has three layers (same format as the spriteset_* files, see spriteset_freedan):
; - Pointer table (the first label): one word per animation index. The engine reads entry $28 of the actor (UpdateActorAnimation: table + 2 x $28), then the frame record $2A x 4 inside that list.
; - Sprite-set (frame list): 4-byte records < hold, &sprite_group >, closed by a hidden $FFFF. A frame is shown for hold + 1 ticks.
; - Sprite-group: 12 header bytes, the part count, then 7-byte sprite-parts. Bytes 0-3 are the X extents (left, right) and Y extents (above, below) of the frame box; UpdateActorAnimation loads them into $18/$1C and $1A/$1E and swaps each pair for a flipped actor. Bytes 4-7 are a tile-unit box (X offset, Y offset, width and height in 16-pixel units) read by PlayerAttackHitTest, the solid-rectangle COP handlers and the tile collision code (tile_collision_physics); bytes 8-11 are the body box (X offset, width, Y offset, height in pixels, signed offsets) read by CombatCollision and the interaction collision code.
; - Sprite-part < size, x, x', y, y', tile word >: size 0 = 8 x 8, 1 = 16 x 16 (the OAM size bit); x and y are offsets inside the extent box, x' and y' the offsets used when the actor is H / V flipped (x + x' = box width - part width); the tile word is an OAM word (bit 8 name table, bits 9-11 palette, bits 12-13 priority, $4000 H flip, $8000 V flip) that the engine XORs with the actor's attribute word $0E.
; 
; === BOXES ===
; 
; Every group of this file carries the engine's default boxes ($F8 $F0 $01 $01 and $F8 $10 $F0 $10): the same eight bytes are in all 85 groups of spm_boot_logos, spm_title_actors, spm_darkspace_sprites and spm_overworld_sprites. They are the two collision boxes (PlayerAttackHitTest, CombatCollision, tile_collision_physics).
---------------------------------------------

---------------------------------------------

; Animation table: entry #00 is the second logo (Enix), entry #01 the first logo. sFB_boot_logo picks them with StageSpriteLoop.

spm_boot_logos [
  &spm_boot_logos_sprite_set_000004   ;00
  &spm_boot_logos_sprite_set_00000A   ;01
]

spm_boot_logos_sprite_set_000004 [
  sprite-set < #$003B, &spm_boot_logos_sprite_group_000010 >
]

spm_boot_logos_sprite_set_00000A [
  sprite-set < #$003B, &spm_boot_logos_sprite_group_000112 >
]

spm_boot_logos_sprite_group_000010 [
  sprite-group < #3A, #40, #5C, #40, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #23, [
    sprite-part < #01, #2A, #40, #1C, #70, #$0302 >   ;00
    sprite-part < #01, #1A, #50, #1C, #70, #$0300 >   ;01
    sprite-part < #01, #3A, #30, #1C, #70, #$0304 >   ;02
    sprite-part < #01, #4A, #20, #1C, #70, #$0306 >   ;03
    sprite-part < #01, #4A, #20, #2C, #60, #$0326 >   ;04
    sprite-part < #01, #4A, #20, #3C, #50, #$0146 >   ;05
    sprite-part < #01, #4A, #20, #4C, #40, #$0166 >   ;06
    sprite-part < #01, #3A, #30, #4C, #40, #$0164 >   ;07
    sprite-part < #01, #2A, #40, #4C, #40, #$0162 >   ;08
    sprite-part < #01, #1A, #50, #4C, #40, #$0160 >   ;09
    sprite-part < #01, #1A, #50, #3C, #50, #$0140 >   ;0A
    sprite-part < #01, #1A, #50, #2C, #60, #$0320 >   ;0B
    sprite-part < #01, #2A, #40, #2C, #60, #$0322 >   ;0C
    sprite-part < #01, #3A, #30, #2C, #60, #$0324 >   ;0D
    sprite-part < #01, #3A, #30, #3C, #50, #$0144 >   ;0E
    sprite-part < #01, #2A, #40, #3C, #50, #$0142 >   ;0F
    sprite-part < #01, #1A, #50, #5C, #30, #$0580 >   ;10
    sprite-part < #01, #1A, #50, #6C, #20, #$05A0 >   ;11
    sprite-part < #01, #2A, #40, #5C, #30, #$0582 >   ;12
    sprite-part < #01, #2A, #40, #6C, #20, #$05A2 >   ;13
    sprite-part < #01, #3A, #30, #6C, #20, #$05A4 >   ;14
    sprite-part < #01, #3A, #30, #5C, #30, #$0584 >   ;15
    sprite-part < #01, #4A, #20, #5C, #30, #$0586 >   ;16
    sprite-part < #01, #4A, #20, #6C, #20, #$05A6 >   ;17
    sprite-part < #01, #00, #6A, #8C, #00, #$0948 >   ;18
    sprite-part < #01, #36, #34, #00, #8C, #$0928 >   ;19
    sprite-part < #01, #0C, #5E, #8C, #00, #$094A >   ;1A
    sprite-part < #01, #18, #52, #8C, #00, #$094C >   ;1B
    sprite-part < #01, #48, #22, #8C, #00, #$096A >   ;1C
    sprite-part < #01, #24, #46, #8C, #00, #$094E >   ;1D
    sprite-part < #01, #3C, #2E, #8C, #00, #$0968 >   ;1E
    sprite-part < #01, #53, #17, #8C, #00, #$096C >   ;1F
    sprite-part < #01, #5E, #0C, #8C, #00, #$094C >   ;20
    sprite-part < #01, #6A, #00, #8C, #00, #$096E >   ;21
    sprite-part < #01, #30, #3A, #8C, #00, #$092E >   ;22
  ] >
]

spm_boot_logos_sprite_group_000112 [
  sprite-group < #30, #30, #10, #20, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #10, [
    sprite-part < #01, #00, #50, #00, #20, #$07C0 >   ;00
    sprite-part < #01, #10, #40, #00, #20, #$07C2 >   ;01
    sprite-part < #01, #20, #30, #00, #20, #$07C4 >   ;02
    sprite-part < #01, #30, #20, #00, #20, #$07C6 >   ;03
    sprite-part < #01, #40, #10, #00, #20, #$07C8 >   ;04
    sprite-part < #01, #50, #00, #00, #20, #$07CA >   ;05
    sprite-part < #01, #00, #50, #10, #10, #$07E0 >   ;06
    sprite-part < #01, #10, #40, #10, #10, #$07E2 >   ;07
    sprite-part < #01, #20, #30, #10, #10, #$07E4 >   ;08
    sprite-part < #01, #30, #20, #10, #10, #$07E6 >   ;09
    sprite-part < #01, #40, #10, #10, #10, #$07E8 >   ;0A
    sprite-part < #01, #50, #00, #10, #10, #$07EA >   ;0B
    sprite-part < #01, #10, #40, #20, #00, #$0708 >   ;0C
    sprite-part < #01, #20, #30, #20, #00, #$070A >   ;0D
    sprite-part < #01, #30, #20, #20, #00, #$070C >   ;0E
    sprite-part < #01, #40, #10, #20, #00, #$070E >   ;0F
  ] >
]