?BANK 17

---------------------------------------------

spriteset_dark_friar [
  &sprite_set_17800E   ;00
  &sprite_set_178034   ;01
  &sprite_set_178042   ;02
  &sprite_set_178050   ;03
  &sprite_set_178062   ;04
  &sprite_set_178074   ;05
  &sprite_set_178086   ;06
]

sprite_set_17800E [
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

sprite_set_178034 [
  sprite-set < #$0000, &sprite_group_1783B1 >   ;00
  sprite-set < #$0000, &sprite_group_1783C5 >   ;01
  sprite-set < #$0000, &sprite_group_178128 >   ;02
]

sprite_set_178042 [
  sprite-set < #$0000, &sprite_group_178375 >   ;00
  sprite-set < #$0000, &sprite_group_178389 >   ;01
  sprite-set < #$0000, &sprite_group_1783ED >   ;02
]

sprite_set_178050 [
  sprite-set < #$0000, &sprite_group_17821E >   ;00
  sprite-set < #$0000, &sprite_group_178247 >   ;01
  sprite-set < #$0000, &sprite_group_178270 >   ;02
  sprite-set < #$0000, &sprite_group_1782B5 >   ;03
]

sprite_set_178062 [
  sprite-set < #$0001, &sprite_group_1782FA >   ;00
  sprite-set < #$0001, &sprite_group_178323 >   ;01
  sprite-set < #$0001, &sprite_group_17834C >   ;02
  sprite-set < #$0001, &sprite_group_178323 >   ;03
]

sprite_set_178074 [
  sprite-set < #$0001, &sprite_group_178375 >   ;00
  sprite-set < #$0001, &sprite_group_178389 >   ;01
  sprite-set < #$0001, &sprite_group_17839D >   ;02
  sprite-set < #$0001, &sprite_group_178389 >   ;03
]

sprite_set_178086 [
  sprite-set < #$0001, &sprite_group_1783B1 >   ;00
  sprite-set < #$0001, &sprite_group_1783C5 >   ;01
  sprite-set < #$0001, &sprite_group_1783D9 >   ;02
  sprite-set < #$0001, &sprite_group_1783C5 >   ;03
]

sprite_group_178098 [
  sprite-group < #1A, #1C, #1B, #1B, #F8, #F0, #01, #01, #F8, #10, #F7, #10, #05, [
    sprite-part < #00, #17, #17, #17, #17, #$04D5 >   ;00
    sprite-part < #00, #00, #2E, #17, #17, #$04D5 >   ;01
    sprite-part < #00, #17, #17, #2E, #00, #$04D5 >   ;02
    sprite-part < #00, #2E, #00, #17, #17, #$04D5 >   ;03
    sprite-part < #00, #17, #17, #00, #2E, #$04D5 >   ;04
  ] >
]

sprite_group_1780C8 [
  sprite-group < #16, #18, #17, #17, #F8, #F0, #01, #01, #F8, #10, #F7, #10, #05, [
    sprite-part < #00, #13, #13, #13, #13, #$04C4 >   ;00
    sprite-part < #00, #00, #26, #17, #0F, #$04C4 >   ;01
    sprite-part < #00, #17, #0F, #26, #00, #$04C4 >   ;02
    sprite-part < #00, #26, #00, #0F, #17, #$04C4 >   ;03
    sprite-part < #00, #0F, #17, #00, #26, #$04C4 >   ;04
  ] >
]

sprite_group_1780F8 [
  sprite-group < #12, #14, #13, #13, #F8, #F0, #01, #01, #F8, #10, #F7, #10, #05, [
    sprite-part < #00, #0F, #0F, #0F, #0F, #$04C5 >   ;00
    sprite-part < #00, #00, #1E, #17, #07, #$04C5 >   ;01
    sprite-part < #00, #17, #07, #1E, #00, #$04C5 >   ;02
    sprite-part < #00, #1E, #00, #07, #17, #$04C5 >   ;03
    sprite-part < #00, #07, #17, #00, #1E, #$04C5 >   ;04
  ] >
]

sprite_group_178128 [
  sprite-group < #0F, #10, #0F, #10, #F8, #F0, #01, #01, #F7, #12, #F7, #12, #04, [
    sprite-part < #01, #00, #0F, #00, #0F, #$0442 >   ;00
    sprite-part < #01, #0F, #00, #00, #0F, #$4442 >   ;01
    sprite-part < #01, #00, #0F, #0F, #00, #$8442 >   ;02
    sprite-part < #01, #0F, #00, #0F, #00, #$C442 >   ;03
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
    sprite-part < #01, #00, #0F, #00, #0F, #$0440 >   ;00
    sprite-part < #01, #0F, #00, #00, #0F, #$4440 >   ;01
    sprite-part < #01, #00, #0F, #0F, #00, #$8440 >   ;02
    sprite-part < #01, #0F, #00, #0F, #00, #$C440 >   ;03
  ] >
]

sprite_group_178247 [
  sprite-group < #0E, #0F, #0E, #0F, #F8, #F0, #01, #01, #F7, #13, #F7, #14, #04, [
    sprite-part < #01, #0D, #00, #00, #0D, #$4440 >   ;00
    sprite-part < #01, #00, #0D, #00, #0D, #$0440 >   ;01
    sprite-part < #01, #00, #0D, #0D, #00, #$8440 >   ;02
    sprite-part < #01, #0D, #00, #0D, #00, #$C440 >   ;03
  ] >
]

sprite_group_178270 [
  sprite-group < #0F, #10, #0F, #10, #F8, #F0, #01, #01, #F6, #14, #F6, #15, #08, [
    sprite-part < #00, #08, #0F, #08, #0F, #$0460 >   ;00
    sprite-part < #00, #0F, #08, #08, #0F, #$4460 >   ;01
    sprite-part < #00, #08, #0F, #0F, #08, #$8460 >   ;02
    sprite-part < #00, #0F, #08, #0F, #08, #$C460 >   ;03
    sprite-part < #01, #00, #0F, #00, #0F, #$0442 >   ;04
    sprite-part < #01, #0F, #00, #00, #0F, #$4442 >   ;05
    sprite-part < #01, #00, #0F, #0F, #00, #$8442 >   ;06
    sprite-part < #01, #0F, #00, #0F, #00, #$C442 >   ;07
  ] >
]

sprite_group_1782B5 [
  sprite-group < #0F, #10, #0F, #10, #F8, #F0, #01, #01, #F6, #14, #F6, #15, #08, [
    sprite-part < #00, #09, #0E, #09, #0E, #$0460 >   ;00
    sprite-part < #00, #0E, #09, #09, #0E, #$4460 >   ;01
    sprite-part < #00, #09, #0E, #0E, #09, #$8460 >   ;02
    sprite-part < #00, #0E, #09, #0E, #09, #$C460 >   ;03
    sprite-part < #01, #00, #0F, #00, #0F, #$0442 >   ;04
    sprite-part < #01, #0F, #00, #00, #0F, #$4442 >   ;05
    sprite-part < #01, #00, #0F, #0F, #00, #$8442 >   ;06
    sprite-part < #01, #0F, #00, #0F, #00, #$C442 >   ;07
  ] >
]

sprite_group_1782FA [
  sprite-group < #10, #10, #10, #10, #F8, #F0, #01, #01, #F2, #1C, #F3, #1B, #04, [
    sprite-part < #01, #00, #10, #00, #10, #$0444 >   ;00
    sprite-part < #01, #10, #00, #00, #10, #$4444 >   ;01
    sprite-part < #01, #00, #10, #10, #00, #$8444 >   ;02
    sprite-part < #01, #10, #00, #10, #00, #$C444 >   ;03
  ] >
]

sprite_group_178323 [
  sprite-group < #10, #10, #10, #10, #F8, #F0, #01, #01, #F2, #1C, #F3, #1B, #04, [
    sprite-part < #01, #00, #10, #00, #10, #$0446 >   ;00
    sprite-part < #01, #10, #00, #00, #10, #$4446 >   ;01
    sprite-part < #01, #00, #10, #10, #00, #$8446 >   ;02
    sprite-part < #01, #10, #00, #10, #00, #$C446 >   ;03
  ] >
]

sprite_group_17834C [
  sprite-group < #10, #10, #10, #10, #F8, #F0, #01, #01, #F2, #1C, #F3, #1B, #04, [
    sprite-part < #01, #00, #10, #00, #10, #$0448 >   ;00
    sprite-part < #01, #10, #00, #00, #10, #$4448 >   ;01
    sprite-part < #01, #00, #10, #10, #00, #$8448 >   ;02
    sprite-part < #01, #10, #00, #10, #00, #$C448 >   ;03
  ] >
]

sprite_group_178375 [
  sprite-group < #08, #08, #08, #08, #F8, #F0, #01, #01, #F8, #0F, #FA, #0E, #01, [
    sprite-part < #01, #00, #00, #00, #00, #$044A >
  ] >
]

sprite_group_178389 [
  sprite-group < #08, #08, #08, #08, #F8, #F0, #01, #01, #F9, #0E, #F9, #0F, #01, [
    sprite-part < #01, #00, #00, #00, #00, #$044C >
  ] >
]

sprite_group_17839D [
  sprite-group < #08, #08, #08, #08, #F8, #F0, #01, #01, #F9, #0D, #FA, #0E, #01, [
    sprite-part < #01, #00, #00, #00, #00, #$044E >
  ] >
]

sprite_group_1783B1 [
  sprite-group < #04, #04, #04, #04, #F8, #F0, #01, #01, #FB, #0A, #FC, #0A, #01, [
    sprite-part < #00, #00, #00, #00, #00, #$0461 >
  ] >
]

sprite_group_1783C5 [
  sprite-group < #04, #04, #04, #04, #F8, #F0, #01, #01, #FB, #0A, #FC, #0A, #01, [
    sprite-part < #00, #00, #00, #00, #00, #$0462 >
  ] >
]

sprite_group_1783D9 [
  sprite-group < #04, #04, #04, #04, #F8, #F0, #01, #01, #FB, #0A, #FC, #0A, #01, [
    sprite-part < #00, #00, #00, #00, #00, #$0463 >
  ] >
]

sprite_group_1783ED [
  sprite-group < #0F, #10, #0F, #10, #F8, #F0, #01, #01, #F5, #15, #F5, #15, #05, [
    sprite-part < #01, #00, #0F, #0F, #00, #$8442 >   ;00
    sprite-part < #01, #00, #0F, #00, #0F, #$0442 >   ;01
    sprite-part < #01, #0F, #00, #00, #0F, #$4442 >   ;02
    sprite-part < #01, #0F, #00, #0F, #00, #$C442 >   ;03
    sprite-part < #01, #07, #08, #08, #07, #$044E >   ;04
  ] >
]