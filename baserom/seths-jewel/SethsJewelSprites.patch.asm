; Seth's Jewel - inventory sprite (item ID $29).
;
; The inventory / equipped-item display picks its sprite from inventory_spritemap[item ID]. Entry $29 was
; sprite_set_10822C -> sprite_group_1089B4, a blank $0A00 tile. It is replaced here with a copy of the
; Red Jewel animation (sprite_set_1080A0, 4 sparkle frames of 5 ticks) where the jewel tile itself ($02)
; uses OAM palette 2 (attr byte $04) instead of palette 6 (attr byte $0C). The sparkle parts keep palette 6.
;
; sprite_group_1089B4 is reused as frame 0; frames 1-3 are new groups chained in right after it, so
; everything stays in the same bank as inventory_spritemap ($&-pointers).
;
; Part word layout: high byte = OAM attr (vhoo pppN), low byte = tile. $0402 = tile $02, palette 2.

?INCLUDE 'inventory_spritemap'

sprite_set_10822C! [
  sprite-set < #$0005, &sprite_group_1089B4 >   ;00
  sprite-set < #$0005, &sprite_group_seths_jewel_1 >   ;01
  sprite-set < #$0005, &sprite_group_seths_jewel_2 >   ;02
  sprite-set < #$0005, &sprite_group_seths_jewel_3 >   ;03
]

sprite_group_1089B4! [
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
