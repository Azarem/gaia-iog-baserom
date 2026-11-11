; ==============================================================================
; Seth's Jewel (item $29) - inventory menu sprite animation
; ==============================================================================
; What it does: Shows a Red-Jewel-style four-frame sparkle animation in the item grid,
;   with the jewel tile drawn using OAM palette 2 (attr $04) instead of palette 6 ($0C).
; Vanilla behavior: inventory_spritemap[29] pointed at sprite_set_10822C with a single
;   blank $0A00 frame (sprite_group_1089B4, duration $0000).
; Hooks (overrides): inventory_spritemap.sprite_set_10822C and sprite_group_1089B4;
;   adds sprite_group_seths_jewel_1-3 chained after the reused frame-0 group.
; Depends on: ?INCLUDE inventory_spritemap; same-bank $& pointers to new groups.
; Hazards/notes: Part words are attr high byte + tile low byte ($0402 = tile $02, pal 2).
; ==============================================================================

inventory_spritemap.sprite_set_10822C! [
  sprite-set < #$0005, &sprite_group_1089B4 >   ;00
  sprite-set < #$0005, &sprite_group_seths_jewel_1 >   ;01
  sprite-set < #$0005, &sprite_group_seths_jewel_2 >   ;02
  sprite-set < #$0005, &sprite_group_seths_jewel_3 >   ;03
]

inventory_spritemap.sprite_group_1089B4! [
  sprite-group < #08, #08, #10, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #02, [
    sprite-part < #00, #05, #03, #07, #01, #$0CE2 >   ;00
    sprite-part < #01, #00, #00, #00, #00, #$0402 >   ;01
  ] >
]

sprite_group_seths_jewel_1 [
  sprite-group < #08, #08, #10, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #02, [
    sprite-part < #00, #05, #03, #07, #01, #$0CF2 >   ;00
    sprite-part < #01, #00, #00, #00, #00, #$0402 >   ;01
  ] >
]

sprite_group_seths_jewel_2 [
  sprite-group < #08, #08, #11, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #03, [
    sprite-part < #00, #05, #03, #08, #01, #$0CF3 >   ;00
    sprite-part < #00, #05, #03, #00, #09, #$0CE3 >   ;01
    sprite-part < #01, #00, #00, #01, #00, #$0402 >   ;02
  ] >
]

sprite_group_seths_jewel_3 [
  sprite-group < #08, #08, #11, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #03, [
    sprite-part < #00, #05, #03, #08, #01, #$0CF4 >   ;00
    sprite-part < #01, #00, #00, #01, #00, #$0402 >   ;01
    sprite-part < #00, #05, #03, #00, #09, #$0CE4 >   ;02
  ] >
]
