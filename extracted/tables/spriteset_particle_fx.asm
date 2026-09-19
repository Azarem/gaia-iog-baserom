; Spriteset for small particle effects.
; 
; Minimal sprite groups for sparkles, dust, and other lightweight ambient particles.
---------------------------------------------

?BANK 14

---------------------------------------------

spriteset_particle_fx [
  &sprite_set_14C12E
]

sprite_set_14C12E [
  sprite-set < #$0005, &sprite_group_14C148 >   ;00
  sprite-set < #$0005, &sprite_group_14C15C >   ;01
  sprite-set < #$0005, &sprite_group_14C170 >   ;02
  sprite-set < #$0005, &sprite_group_14C184 >   ;03
  sprite-set < #$0005, &sprite_group_14C170 >   ;04
  sprite-set < #$0005, &sprite_group_14C15C >   ;05
]

sprite_group_14C148 [
  sprite-group < #08, #08, #10, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #01, #00, #00, #00, #00, #$0E00 >
  ] >
]

sprite_group_14C15C [
  sprite-group < #08, #08, #10, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #01, #00, #00, #00, #00, #$0E04 >
  ] >
]

sprite_group_14C170 [
  sprite-group < #08, #08, #10, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #01, #00, #00, #00, #00, #$0E08 >
  ] >
]

sprite_group_14C184 [
  sprite-group < #08, #08, #10, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #01, #00, #00, #00, #00, #$0E0C >
  ] >
]