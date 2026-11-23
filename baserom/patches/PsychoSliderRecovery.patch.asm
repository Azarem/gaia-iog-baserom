; Halve only the two recovery-frame holds of each directional Psycho Slider.
; Stored hold is ticks minus one: 6 + 10 ticks becomes 3 + 5 ticks.
?INCLUDE 'spriteset_will_abilities'

spriteset_will_abilities.sprite_set_0F8166! [
  sprite-set < #$0002, &sprite_group_0F8909 >   ;00
  sprite-set < #$0004, &sprite_group_0F8932 >   ;01
]

spriteset_will_abilities.sprite_set_0F8190! [
  sprite-set < #$0002, &sprite_group_0F8A75 >   ;00
  sprite-set < #$0004, &sprite_group_0F8AA5 >   ;01
]

spriteset_will_abilities.sprite_set_0F81BA! [
  sprite-set < #$0002, &sprite_group_0F8BCC >   ;00
  sprite-set < #$0004, &sprite_group_0F8470 >   ;01
]

spriteset_will_abilities.sprite_set_0F81E4! [
  sprite-set < #$0002, &sprite_group_0F8D4D >   ;00
  sprite-set < #$0004, &sprite_group_0F8D7D >   ;01
]

