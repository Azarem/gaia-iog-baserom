; Two Freejia tile animations (Bank 14, 1359872-1360071). It is a spriteset only in format: its one user streams the frames into VRAM as tiles.
; 
; The only user is fr32_laborer_npc (Freejia): two actors run SetScratchPointer(misc_fx_1CD080) (the tile art), SetMetasprite(spriteset_freejia_tilefx), SetTileStreamAnim and AdvanceSpriteAnim. code_05B021 first stores #$0420 in cameraBoundsY ($06DC) and spawns code_05B03E (SpawnAfter), then plays animation 0 into VRAM word $3FE0; code_05B03E plays animation 1 into VRAM word $3FF0. The two destinations are one 4bpp tile apart ($10 words = 32 bytes).
; 
; === WHAT AdvanceSpriteAnim READS ===
; 
; Only the size flag of the first sub-sprite (group +$0D, 0 = a 32-byte tile DMA here) and its tile byte (group +$12, times 32 = offset in the art). The other header and sub-sprite fields are not read on this path. General struct format: see spriteset_freedan.
; 
; === CONTENT ===
; 
; - Animation 0: 4 frames, hold 7 (8 ticks, a 32-tick loop), groups 14C028-14C064, tile bytes 0, 1, 2, 3.
; - Animation 1: 4 frames, hold 6 (7 ticks, a 28-tick loop), groups 14C078-14C0B4, tile bytes 4, 5, 6, 7 (tile words $0604-$0607; the high byte is not read here).
; - All 8 groups are alike: header extents 8, 0, 8, 0, default boxes, one size-0 sub-sprite at offset 0, 0. Each frame is one 8x8 tile.
; 
; Not traced: what the tiles show. The two actors run no sprite movement (code_05B021 only stores cameraBoundsY and spawns code_05B03E), although the file header of fr32_laborer_npc describes a walking laborer.
---------------------------------------------

?BANK 14

---------------------------------------------

; Two animation pointers (index 0 and 1), selected by the first operand of SetTileStreamAnim in fr32_laborer_npc.

spriteset_freejia_tilefx [
  &freejia_tilefx_3FE0   ;00
  &freejia_tilefx_3FF0   ;01
]

---------------------------------------------
; Animation 0: groups 14C028, 14C03C, 14C050, 14C064 (tile bytes 0 to 3), each held 7 (8 ticks); the hidden $FFFF terminator wraps the loop. Streamed to VRAM word $3FE0.

freejia_tilefx_3FE0 [
  sprite-set < #$0007, &sprite_group_14C028 >   ;00
  sprite-set < #$0007, &sprite_group_14C03C >   ;01
  sprite-set < #$0007, &sprite_group_14C050 >   ;02
  sprite-set < #$0007, &sprite_group_14C064 >   ;03
]

---------------------------------------------
; Animation 1: groups 14C078, 14C08C, 14C0A0, 14C0B4 (tile bytes 4 to 7), each held 6 (7 ticks). Streamed to VRAM word $3FF0.

freejia_tilefx_3FF0 [
  sprite-set < #$0006, &sprite_group_14C078 >   ;00
  sprite-set < #$0006, &sprite_group_14C08C >   ;01
  sprite-set < #$0006, &sprite_group_14C0A0 >   ;02
  sprite-set < #$0006, &sprite_group_14C0B4 >   ;03
]

sprite_group_14C028 [
  sprite-group < #08, #00, #08, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #00, #00, #00, #00, #00, #$0000 >
  ] >
]

sprite_group_14C03C [
  sprite-group < #08, #00, #08, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #00, #00, #00, #00, #00, #$0001 >
  ] >
]

sprite_group_14C050 [
  sprite-group < #08, #00, #08, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #00, #00, #00, #00, #00, #$0002 >
  ] >
]

sprite_group_14C064 [
  sprite-group < #08, #00, #08, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #00, #00, #00, #00, #00, #$0003 >
  ] >
]

sprite_group_14C078 [
  sprite-group < #08, #00, #08, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #00, #00, #00, #00, #00, #$0604 >
  ] >
]

sprite_group_14C08C [
  sprite-group < #08, #00, #08, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #00, #00, #00, #00, #00, #$0605 >
  ] >
]

sprite_group_14C0A0 [
  sprite-group < #08, #00, #08, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #00, #00, #00, #00, #00, #$0606 >
  ] >
]

sprite_group_14C0B4 [
  sprite-group < #08, #00, #08, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #00, #00, #00, #00, #00, #$0607 >
  ] >
]