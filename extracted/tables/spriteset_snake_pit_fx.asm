; Snake pit effect tile animation (Bank 14, 1360172-1360279). It is a spriteset only in format: its one user streams the frames into VRAM as tiles.
; 
; The only user is awB4_snake_pit_fx (Angkor Wat snake pit): SetScratchPointer(misc_fx_1CD380) names the tile art, SetMetasprite(spriteset_snake_pit_fx) names this table, SetTileStreamAnim(0, $2020) picks animation 0 and the VRAM word address $2020, and AdvanceSpriteAnim runs the frames.
; 
; === WHAT AdvanceSpriteAnim READS ===
; 
; On this tile-streaming path only two bytes of each sprite group matter: the size flag of its first sub-sprite (group +$0D: 0 = 32 bytes, nonzero = 128 bytes = four 4bpp tiles) and the tile byte of that sub-sprite (group +$12, times 32 = the offset of the frame in the art). The extents, the two collision boxes and the X/Y offsets are not read here. The frame hold is the usual word (hold n lasts n + 1 ticks).
; 
; === CONTENT ===
; 
; One animation (the table has one entry): 6 frame records, hold 5 (6 ticks each, a 36-tick loop), showing 4 distinct groups in the order 0, 1, 2, 3, 2, 1 (a ping-pong). Each group has the default header (extents 8, 8, 16, 0 and the boxes $F8 $F0 $01 $01 / $F8 $10 $F0 $10) and one sub-sprite of size 1 with tile word $0E00, $0E04, $0E08, $0E0C. Tile bytes 0, 4, 8, $0C are four 128-byte frames laid back to back in misc_fx_1CD380; each is DMAed to VRAM word $2020. The high byte $0E of the tile word (palette / priority bits in an OAM word) is not read by this path.
; 
; General format of the sprite-set / sprite-group / sprite-part structs: see the block note of spriteset_freedan.
---------------------------------------------

?BANK 14

---------------------------------------------

; Animation table with a single entry (index 0), used by awB4_snake_pit_fx. Any other animation index would read past the table.

spriteset_snake_pit_fx [
  &sprite_set_snake_pit_fx_loop
]

---------------------------------------------
; Frame list of animation 0: groups snake_pit_fx_frame_0, snake_pit_fx_frame_1, snake_pit_fx_frame_2, snake_pit_fx_frame_3, snake_pit_fx_frame_2, snake_pit_fx_frame_1, each held 5 (6 ticks). The hidden $FFFF terminator after the last record wraps the loop (AdvanceSpriteAnim clears the frame counter at it). 36 ticks per cycle.

sprite_set_snake_pit_fx_loop [
  sprite-set < #$0005, &snake_pit_fx_frame_0 >   ;00
  sprite-set < #$0005, &snake_pit_fx_frame_1 >   ;01
  sprite-set < #$0005, &snake_pit_fx_frame_2 >   ;02
  sprite-set < #$0005, &snake_pit_fx_frame_3 >   ;03
  sprite-set < #$0005, &snake_pit_fx_frame_2 >   ;04
  sprite-set < #$0005, &snake_pit_fx_frame_1 >   ;05
]

---------------------------------------------
; Frame 0: tile byte $00 = the first 128 bytes of misc_fx_1CD380. snake_pit_fx_frame_1, snake_pit_fx_frame_2 and snake_pit_fx_frame_3 differ only by the tile byte ($04, $08, $0C).

snake_pit_fx_frame_0 [
  sprite-group < #08, #08, #10, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #01, #00, #00, #00, #00, #$0E00 >
  ] >
]

snake_pit_fx_frame_1 [
  sprite-group < #08, #08, #10, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #01, #00, #00, #00, #00, #$0E04 >
  ] >
]

snake_pit_fx_frame_2 [
  sprite-group < #08, #08, #10, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #01, #00, #00, #00, #00, #$0E08 >
  ] >
]

snake_pit_fx_frame_3 [
  sprite-group < #08, #08, #10, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #01, #00, #00, #00, #00, #$0E0C >
  ] >
]