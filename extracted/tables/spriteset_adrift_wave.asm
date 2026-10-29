; Spriteset of the adrift-sequence wave effect (Bank 14, 1360072-1360171 = 14C0C8-14C12B): one animation of four single-sprite frames. Its only user is gold_ship/adrift/dc2F_adrift_fx, one of the four tile-streaming effect actors (cop_handlers_sprite): it sets the art source with SetScratchPointer ( misc_fx_1CD180 ), passes spriteset_adrift_wave to SetMetasprite, starts animation 0 with SetTileStreamAnim ( #00, #$2010 ) and loops AdvanceSpriteAnim. Each AdvanceSpriteAnim stages one frame of art from the source to VRAM word $2010 (the NMI does the DMA) and takes the hold time from this table. That file's header describes the result as ocean waves over the adrift scene.
; 
; Structure (same as every spriteset): spriteset_adrift_wave is the animation-index table (one word pointer here); sprite_set_adrift_wave_loop is that animation's frame list of 4-byte records < hold word, &sprite-group > ended by a hidden $FFFF; each sprite-group is a 13-byte header followed by one 7-byte sprite-part. All four frames hold $0007 (8 ticks each, 32 ticks per loop) and have identical headers. The last word of the sprite-part ($0A00, $0A04, $0A08, $0A0C) is the only difference: for a tile-streaming animation its low byte is the art offset in 32-byte tiles (AdvanceSpriteAnim copies from animScratch + 32 x byte at +$12 of the frame data), and because the sprite-part's first byte is nonzero each frame is 128 bytes (four tiles), so the four frames are consecutive 128-byte pictures at offsets 0, 128, 256 and 384 of misc_fx_1CD180. The high byte $0A is not read by the streaming code.
---------------------------------------------

?BANK 14

---------------------------------------------

; Animation-index table: one entry, animation 0 = sprite_set_adrift_wave_loop. dc2F_adrift_fx starts it with SetTileStreamAnim ( #00, #$2010 ): animation index 0, VRAM word address $2010.

spriteset_adrift_wave [
  &sprite_set_adrift_wave_loop
]

---------------------------------------------
; Animation 0, four frames of 8 ticks each (hold word $0007), looping through sprite_group_adrift_wave_0, sprite_group_adrift_wave_1, sprite_group_adrift_wave_2 and sprite_group_adrift_wave_3.

sprite_set_adrift_wave_loop [
  sprite-set < #$0007, &sprite_group_adrift_wave_0 >   ;00
  sprite-set < #$0007, &sprite_group_adrift_wave_1 >   ;01
  sprite-set < #$0007, &sprite_group_adrift_wave_2 >   ;02
  sprite-set < #$0007, &sprite_group_adrift_wave_3 >   ;03
]

---------------------------------------------
; Frame 0: one sprite-part, word $0A00 (art offset 0 in the streamed source).

sprite_group_adrift_wave_0 [
  sprite-group < #08, #08, #10, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #01, #00, #00, #00, #00, #$0A00 >
  ] >
]

---------------------------------------------
; Frame 1: one sprite-part, word $0A04 (art offset 4 tiles = 128 bytes).

sprite_group_adrift_wave_1 [
  sprite-group < #08, #08, #10, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #01, #00, #00, #00, #00, #$0A04 >
  ] >
]

---------------------------------------------
; Frame 2: one sprite-part, word $0A08 (art offset 8 tiles = 256 bytes).

sprite_group_adrift_wave_2 [
  sprite-group < #08, #08, #10, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #01, #00, #00, #00, #00, #$0A08 >
  ] >
]

---------------------------------------------
; Frame 3: one sprite-part, word $0A0C (art offset 12 tiles = 384 bytes).

sprite_group_adrift_wave_3 [
  sprite-group < #08, #08, #10, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #01, #00, #00, #00, #00, #$0A0C >
  ] >
]