; Inventory art for the custom items.
?INCLUDE 'inventory_spritemap'

inventory_spritemap.inventory_spritemap#52: &sprite_set_108232   ;29
inventory_spritemap.inventory_spritemap#54: &sprite_set_108238   ;2A
inventory_spritemap.inventory_spritemap#56: &CustomItemShirasGiftMenuIcon ;2B

; Gem's Ledger: tiles $1E2/$1E3/$1F2/$1F3, donor inventory palette 6.
inventory_spritemap.sprite_group_1089C8! [
  sprite-group < #08, #08, #10, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #01, #00, #00, #00, #00, #$0DE2 >
  ] >
]

; Knight's Emblem: tiles $1E4/$1E5/$1F4/$1F5, donor inventory palette 3.
inventory_spritemap.sprite_group_1089F0! [
  sprite-group < #08, #08, #10, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #01, #00, #00, #00, #00, #$07E4 >
  ] >
]

; Negative Arc uses tiles $1E6/$1E7/$1F6/$1F7 and unused colors 1-5 in palette 7.
inventory_spritemap.sprite_group_1089DC! [
  sprite-group < #08, #08, #10, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #01, #00, #00, #00, #00, #$0FE6 >
  ] >
]

; Shira's Gift uses tiles $1E8/$1E9/$1F8/$1F9 in palette 7.
CustomItemShirasGiftMenuIcon [
  sprite-set < #$0000, &CustomItemShirasGiftMenuSprite >
]

CustomItemShirasGiftMenuSprite [
  sprite-group < #08, #08, #10, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #01, #00, #00, #00, #00, #$0FE8 >
  ] >
]
