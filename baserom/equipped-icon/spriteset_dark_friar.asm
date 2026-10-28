?BANK 17

---------------------------------------------

spriteset_dark_friar [
  &dark_friar_00_cast_flash   ;00
  &dark_friar_01_trail1   ;01
  &dark_friar_02_trail2   ;02
  &dark_friar_03_trail3   ;03
  &dark_friar_04_fragment   ;04
  &dark_friar_05_follower_a   ;05
  &dark_friar_06_follower_b   ;06
]

dark_friar_00_cast_flash [
  sprite-set < #$0000, &sprite_group_178098 >   ;00
  sprite-set < #$0000, &sprite_group_1780C8 >   ;01
  sprite-set < #$0000, &sprite_group_1780F8 >   ;02
  sprite-set < #$0001, &sprite_group_178128 >   ;03
  sprite-set < #$0001, &sprite_group_178151 >   ;04
  sprite-set < #$0003, &sprite_group_17817A >   ;05
  sprite-set < #$0003, &sprite_group_1781AA >   ;06
  sprite-set < #$0003, &sprite_group_1781DA >   ;07
  sprite-set < #$0000, &sprite_group_17820A >   ;08
]

dark_friar_01_trail1 [
  sprite-set < #$0000, &sprite_group_1783B1 >   ;00
  sprite-set < #$0000, &sprite_group_1783C5 >   ;01
  sprite-set < #$0000, &sprite_group_178128 >   ;02
]

dark_friar_02_trail2 [
  sprite-set < #$0000, &sprite_group_178375 >   ;00
  sprite-set < #$0000, &sprite_group_178389 >   ;01
  sprite-set < #$0000, &sprite_group_1783ED >   ;02
]

dark_friar_03_trail3 [
  sprite-set < #$0000, &sprite_group_17821E >   ;00
  sprite-set < #$0000, &sprite_group_178247 >   ;01
  sprite-set < #$0000, &sprite_group_178270 >   ;02
  sprite-set < #$0000, &sprite_group_1782B5 >   ;03
]

dark_friar_04_fragment [
  sprite-set < #$0001, &sprite_group_1782FA >   ;00
  sprite-set < #$0001, &sprite_group_178323 >   ;01
  sprite-set < #$0001, &sprite_group_17834C >   ;02
  sprite-set < #$0001, &sprite_group_178323 >   ;03
]

dark_friar_05_follower_a [
  sprite-set < #$0001, &sprite_group_178375 >   ;00
  sprite-set < #$0001, &sprite_group_178389 >   ;01
  sprite-set < #$0001, &sprite_group_17839D >   ;02
  sprite-set < #$0001, &sprite_group_178389 >   ;03
]

dark_friar_06_follower_b [
  sprite-set < #$0001, &sprite_group_1783B1 >   ;00
  sprite-set < #$0001, &sprite_group_1783C5 >   ;01
  sprite-set < #$0001, &sprite_group_1783D9 >   ;02
  sprite-set < #$0001, &sprite_group_1783C5 >   ;03
]

sprite_group_178098 [
  sprite-group < #1A, #1C, #1B, #1B, #F8, #F0, #01, #01, #F8, #10, #F7, #10, #05, [
    sprite-part < #00, #17, #17, #17, #17, #$0ED5 >   ;00
    sprite-part < #00, #00, #2E, #17, #17, #$0ED5 >   ;01
    sprite-part < #00, #17, #17, #2E, #00, #$0ED5 >   ;02
    sprite-part < #00, #2E, #00, #17, #17, #$0ED5 >   ;03
    sprite-part < #00, #17, #17, #00, #2E, #$0ED5 >   ;04
  ] >
]

sprite_group_1780C8 [
  sprite-group < #16, #18, #17, #17, #F8, #F0, #01, #01, #F8, #10, #F7, #10, #05, [
    sprite-part < #00, #13, #13, #13, #13, #$0EC4 >   ;00
    sprite-part < #00, #00, #26, #17, #0F, #$0EC4 >   ;01
    sprite-part < #00, #17, #0F, #26, #00, #$0EC4 >   ;02
    sprite-part < #00, #26, #00, #0F, #17, #$0EC4 >   ;03
    sprite-part < #00, #0F, #17, #00, #26, #$0EC4 >   ;04
  ] >
]

sprite_group_1780F8 [
  sprite-group < #12, #14, #13, #13, #F8, #F0, #01, #01, #F8, #10, #F7, #10, #05, [
    sprite-part < #00, #0F, #0F, #0F, #0F, #$0EC5 >   ;00
    sprite-part < #00, #00, #1E, #17, #07, #$0EC5 >   ;01
    sprite-part < #00, #17, #07, #1E, #00, #$0EC5 >   ;02
    sprite-part < #00, #1E, #00, #07, #17, #$0EC5 >   ;03
    sprite-part < #00, #07, #17, #00, #1E, #$0EC5 >   ;04
  ] >
]

sprite_group_178128 [
  sprite-group < #0F, #10, #0F, #10, #F8, #F0, #01, #01, #F7, #12, #F7, #12, #04, [
    sprite-part < #01, #00, #0F, #00, #0F, #$0E42 >   ;00
    sprite-part < #01, #0F, #00, #00, #0F, #$4E42 >   ;01
    sprite-part < #01, #00, #0F, #0F, #00, #$8E42 >   ;02
    sprite-part < #01, #0F, #00, #0F, #00, #$CE42 >   ;03
  ] >
]

sprite_group_178151 [
  sprite-group < #0F, #10, #0F, #10, #F8, #F0, #01, #01, #F8, #10, #F6, #12, #04, [
    sprite-part < #01, #00, #0F, #00, #0F, #$02E8 >   ;00
    sprite-part < #01, #0F, #00, #00, #0F, #$42E8 >   ;01
    sprite-part < #01, #00, #0F, #0F, #00, #$82E8 >   ;02
    sprite-part < #01, #0F, #00, #0F, #00, #$C2E8 >   ;03
  ] >
]

sprite_group_17817A [
  sprite-group < #10, #12, #11, #11, #F8, #F0, #01, #01, #F8, #10, #F6, #11, #05, [
    sprite-part < #00, #0D, #0D, #0D, #0D, #$02C5 >   ;00
    sprite-part < #00, #00, #1A, #04, #16, #$02C5 >   ;01
    sprite-part < #00, #16, #04, #00, #1A, #$02C5 >   ;02
    sprite-part < #00, #1A, #00, #16, #04, #$02C5 >   ;03
    sprite-part < #00, #04, #16, #1A, #00, #$02C5 >   ;04
  ] >
]

sprite_group_1781AA [
  sprite-group < #14, #16, #15, #15, #F8, #F0, #01, #01, #F8, #10, #F6, #11, #05, [
    sprite-part < #00, #11, #11, #11, #11, #$02C4 >   ;00
    sprite-part < #00, #22, #00, #16, #0C, #$02C4 >   ;01
    sprite-part < #00, #0C, #16, #22, #00, #$02C4 >   ;02
    sprite-part < #00, #00, #22, #0C, #16, #$02C4 >   ;03
    sprite-part < #00, #16, #0C, #00, #22, #$02C4 >   ;04
  ] >
]

sprite_group_1781DA [
  sprite-group < #1A, #1C, #1B, #1B, #F8, #F0, #01, #01, #F8, #10, #F7, #10, #05, [
    sprite-part < #00, #17, #17, #17, #17, #$02D5 >   ;00
    sprite-part < #00, #00, #2E, #18, #16, #$02D5 >   ;01
    sprite-part < #00, #18, #16, #2E, #00, #$02D5 >   ;02
    sprite-part < #00, #2E, #00, #16, #18, #$02D5 >   ;03
    sprite-part < #00, #16, #18, #00, #2E, #$02D5 >   ;04
  ] >
]

sprite_group_17820A [
  sprite-group < #40, #C8, #60, #00, #F8, #F0, #01, #01, #F8, #10, #F7, #10, #01, [
    sprite-part < #00, #00, #00, #00, #58, #$02AF >
  ] >
]

sprite_group_17821E [
  sprite-group < #0F, #10, #0F, #10, #F8, #F0, #01, #01, #F6, #15, #F6, #16, #04, [
    sprite-part < #01, #00, #0F, #00, #0F, #$0E40 >   ;00
    sprite-part < #01, #0F, #00, #00, #0F, #$4E40 >   ;01
    sprite-part < #01, #00, #0F, #0F, #00, #$8E40 >   ;02
    sprite-part < #01, #0F, #00, #0F, #00, #$CE40 >   ;03
  ] >
]

sprite_group_178247 [
  sprite-group < #0E, #0F, #0E, #0F, #F8, #F0, #01, #01, #F7, #13, #F7, #14, #04, [
    sprite-part < #01, #0D, #00, #00, #0D, #$4E40 >   ;00
    sprite-part < #01, #00, #0D, #00, #0D, #$0E40 >   ;01
    sprite-part < #01, #00, #0D, #0D, #00, #$8E40 >   ;02
    sprite-part < #01, #0D, #00, #0D, #00, #$CE40 >   ;03
  ] >
]

sprite_group_178270 [
  sprite-group < #0F, #10, #0F, #10, #F8, #F0, #01, #01, #F6, #14, #F6, #15, #08, [
    sprite-part < #00, #08, #0F, #08, #0F, #$0E60 >   ;00
    sprite-part < #00, #0F, #08, #08, #0F, #$4E60 >   ;01
    sprite-part < #00, #08, #0F, #0F, #08, #$8E60 >   ;02
    sprite-part < #00, #0F, #08, #0F, #08, #$CE60 >   ;03
    sprite-part < #01, #00, #0F, #00, #0F, #$0E42 >   ;04
    sprite-part < #01, #0F, #00, #00, #0F, #$4E42 >   ;05
    sprite-part < #01, #00, #0F, #0F, #00, #$8E42 >   ;06
    sprite-part < #01, #0F, #00, #0F, #00, #$CE42 >   ;07
  ] >
]

sprite_group_1782B5 [
  sprite-group < #0F, #10, #0F, #10, #F8, #F0, #01, #01, #F6, #14, #F6, #15, #08, [
    sprite-part < #00, #09, #0E, #09, #0E, #$0E60 >   ;00
    sprite-part < #00, #0E, #09, #09, #0E, #$4E60 >   ;01
    sprite-part < #00, #09, #0E, #0E, #09, #$8E60 >   ;02
    sprite-part < #00, #0E, #09, #0E, #09, #$CE60 >   ;03
    sprite-part < #01, #00, #0F, #00, #0F, #$0E42 >   ;04
    sprite-part < #01, #0F, #00, #00, #0F, #$4E42 >   ;05
    sprite-part < #01, #00, #0F, #0F, #00, #$8E42 >   ;06
    sprite-part < #01, #0F, #00, #0F, #00, #$CE42 >   ;07
  ] >
]

sprite_group_1782FA [
  sprite-group < #10, #10, #10, #10, #F8, #F0, #01, #01, #F2, #1C, #F3, #1B, #04, [
    sprite-part < #01, #00, #10, #00, #10, #$0E44 >   ;00
    sprite-part < #01, #10, #00, #00, #10, #$4E44 >   ;01
    sprite-part < #01, #00, #10, #10, #00, #$8E44 >   ;02
    sprite-part < #01, #10, #00, #10, #00, #$CE44 >   ;03
  ] >
]

sprite_group_178323 [
  sprite-group < #10, #10, #10, #10, #F8, #F0, #01, #01, #F2, #1C, #F3, #1B, #04, [
    sprite-part < #01, #00, #10, #00, #10, #$0E46 >   ;00
    sprite-part < #01, #10, #00, #00, #10, #$4E46 >   ;01
    sprite-part < #01, #00, #10, #10, #00, #$8E46 >   ;02
    sprite-part < #01, #10, #00, #10, #00, #$CE46 >   ;03
  ] >
]

sprite_group_17834C [
  sprite-group < #10, #10, #10, #10, #F8, #F0, #01, #01, #F2, #1C, #F3, #1B, #04, [
    sprite-part < #01, #00, #10, #00, #10, #$0E48 >   ;00
    sprite-part < #01, #10, #00, #00, #10, #$4E48 >   ;01
    sprite-part < #01, #00, #10, #10, #00, #$8E48 >   ;02
    sprite-part < #01, #10, #00, #10, #00, #$CE48 >   ;03
  ] >
]

sprite_group_178375 [
  sprite-group < #08, #08, #08, #08, #F8, #F0, #01, #01, #F8, #0F, #FA, #0E, #01, [
    sprite-part < #01, #00, #00, #00, #00, #$0E4A >
  ] >
]

sprite_group_178389 [
  sprite-group < #08, #08, #08, #08, #F8, #F0, #01, #01, #F9, #0E, #F9, #0F, #01, [
    sprite-part < #01, #00, #00, #00, #00, #$0E4C >
  ] >
]

sprite_group_17839D [
  sprite-group < #08, #08, #08, #08, #F8, #F0, #01, #01, #F9, #0D, #FA, #0E, #01, [
    sprite-part < #01, #00, #00, #00, #00, #$0E4E >
  ] >
]

sprite_group_1783B1 [
  sprite-group < #04, #04, #04, #04, #F8, #F0, #01, #01, #FB, #0A, #FC, #0A, #01, [
    sprite-part < #00, #00, #00, #00, #00, #$0E61 >
  ] >
]

sprite_group_1783C5 [
  sprite-group < #04, #04, #04, #04, #F8, #F0, #01, #01, #FB, #0A, #FC, #0A, #01, [
    sprite-part < #00, #00, #00, #00, #00, #$0E62 >
  ] >
]

sprite_group_1783D9 [
  sprite-group < #04, #04, #04, #04, #F8, #F0, #01, #01, #FB, #0A, #FC, #0A, #01, [
    sprite-part < #00, #00, #00, #00, #00, #$0E63 >
  ] >
]

sprite_group_1783ED [
  sprite-group < #0F, #10, #0F, #10, #F8, #F0, #01, #01, #F5, #15, #F5, #15, #05, [
    sprite-part < #01, #00, #0F, #0F, #00, #$8E42 >   ;00
    sprite-part < #01, #00, #0F, #00, #0F, #$0E42 >   ;01
    sprite-part < #01, #0F, #00, #00, #0F, #$4E42 >   ;02
    sprite-part < #01, #0F, #00, #0F, #00, #$CE42 >   ;03
    sprite-part < #01, #07, #08, #08, #07, #$0E4E >   ;04
  ] >
]