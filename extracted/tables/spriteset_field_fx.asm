; Spriteset for miscellaneous field visual effects.
; 
; Small set with 4 sprite groups used for non-combat environmental particles.
---------------------------------------------

?BANK 14

---------------------------------------------

spriteset_field_fx [
  &sprite_set_14C0CA
]

sprite_set_14C0CA [
  sprite-set < #$0007, &sprite_group_14C0DC >   ;00
  sprite-set < #$0007, &sprite_group_14C0F0 >   ;01
  sprite-set < #$0007, &sprite_group_14C104 >   ;02
  sprite-set < #$0007, &sprite_group_14C118 >   ;03
]

sprite_group_14C0DC [
  sprite-group < #08, #08, #10, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #01, #00, #00, #00, #00, #$0A00 >
  ] >
]

sprite_group_14C0F0 [
  sprite-group < #08, #08, #10, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #01, #00, #00, #00, #00, #$0A04 >
  ] >
]

sprite_group_14C104 [
  sprite-group < #08, #08, #10, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #01, #00, #00, #00, #00, #$0A08 >
  ] >
]

sprite_group_14C118 [
  sprite-group < #08, #08, #10, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #01, #00, #00, #00, #00, #$0A0C >
  ] >
]