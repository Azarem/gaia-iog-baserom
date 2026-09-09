---------------------------------------------

spm_descent_sprites [
  &sprite_set_000010   ;00
  &sprite_set_00001A   ;01
  &sprite_set_00002C   ;02
  &sprite_set_000032   ;03
  &sprite_set_000040   ;04
  &sprite_set_00004E   ;05
  &sprite_set_000060   ;06
  &sprite_set_00006E   ;07
]

sprite_set_000010 [
  sprite-set < #$0002, &sprite_group_00007C >   ;00
  sprite-set < #$0002, &sprite_group_000090 >   ;01
]

sprite_set_00001A [
  sprite-set < #$0002, &sprite_group_0000A4 >   ;00
  sprite-set < #$0002, &sprite_group_0000B8 >   ;01
  sprite-set < #$0002, &sprite_group_0000CC >   ;02
  sprite-set < #$0002, &sprite_group_0000B8 >   ;03
]

sprite_set_00002C [
  sprite-set < #$0000, &sprite_group_0000E0 >
]

sprite_set_000032 [
  sprite-set < #$0001, &sprite_group_0000F4 >   ;00
  sprite-set < #$0001, &sprite_group_000178 >   ;01
  sprite-set < #$0001, &sprite_group_0001FC >   ;02
]

sprite_set_000040 [
  sprite-set < #$0001, &sprite_group_000280 >   ;00
  sprite-set < #$0001, &sprite_group_000320 >   ;01
  sprite-set < #$0001, &sprite_group_0003C0 >   ;02
]

sprite_set_00004E [
  sprite-set < #$000F, &sprite_group_000460 >   ;00
  sprite-set < #$000F, &sprite_group_000489 >   ;01
  sprite-set < #$000F, &sprite_group_000460 >   ;02
  sprite-set < #$000F, &sprite_group_0004B2 >   ;03
]

sprite_set_000060 [
  sprite-set < #$0001, &sprite_group_0004DB >   ;00
  sprite-set < #$0001, &sprite_group_000558 >   ;01
  sprite-set < #$0001, &sprite_group_0005D5 >   ;02
]

sprite_set_00006E [
  sprite-set < #$0001, &sprite_group_000652 >   ;00
  sprite-set < #$0001, &sprite_group_0006DD >   ;01
  sprite-set < #$0001, &sprite_group_000768 >   ;02
]

sprite_group_00007C [
  sprite-group < #08, #08, #10, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #01, #00, #00, #00, #00, #$01E0 >
  ] >
]

sprite_group_000090 [
  sprite-group < #08, #08, #10, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #01, #00, #00, #00, #00, #$01E2 >
  ] >
]

sprite_group_0000A4 [
  sprite-group < #04, #04, #0B, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #00, #00, #00, #00, #03, #$01D0 >
  ] >
]

sprite_group_0000B8 [
  sprite-group < #04, #04, #0C, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #00, #00, #00, #00, #04, #$01D1 >
  ] >
]

sprite_group_0000CC [
  sprite-group < #03, #05, #0C, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #00, #00, #00, #00, #04, #$01D2 >
  ] >
]

sprite_group_0000E0 [
  sprite-group < #08, #08, #10, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #01, #00, #00, #00, #00, #$01E4 >
  ] >
]

sprite_group_0000F4 [
  sprite-group < #30, #24, #30, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #11, [
    sprite-part < #01, #43, #01, #1F, #01, #$C160 >   ;00
    sprite-part < #01, #44, #00, #10, #10, #$0160 >   ;01
    sprite-part < #01, #04, #40, #11, #0F, #$0786 >   ;02
    sprite-part < #01, #2D, #17, #10, #10, #$07A2 >   ;03
    sprite-part < #01, #26, #1E, #1B, #05, #$07A4 >   ;04
    sprite-part < #01, #40, #04, #10, #10, #$0B28 >   ;05
    sprite-part < #01, #40, #04, #20, #00, #$0B48 >   ;06
    sprite-part < #01, #30, #14, #00, #20, #$0B06 >   ;07
    sprite-part < #01, #30, #14, #10, #10, #$0B26 >   ;08
    sprite-part < #01, #30, #14, #20, #00, #$0B46 >   ;09
    sprite-part < #01, #20, #24, #20, #00, #$0B44 >   ;0A
    sprite-part < #01, #20, #24, #10, #10, #$0B24 >   ;0B
    sprite-part < #01, #20, #24, #00, #20, #$0B04 >   ;0C
    sprite-part < #01, #10, #34, #20, #00, #$0B42 >   ;0D
    sprite-part < #01, #10, #34, #10, #10, #$0B22 >   ;0E
    sprite-part < #01, #00, #44, #10, #10, #$0B20 >   ;0F
    sprite-part < #01, #00, #44, #20, #00, #$0B40 >   ;10
  ] >
]

sprite_group_000178 [
  sprite-group < #30, #24, #30, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #11, [
    sprite-part < #01, #43, #01, #1F, #01, #$C162 >   ;00
    sprite-part < #01, #44, #00, #10, #10, #$0162 >   ;01
    sprite-part < #01, #04, #40, #11, #0F, #$0766 >   ;02
    sprite-part < #01, #2D, #17, #10, #10, #$0782 >   ;03
    sprite-part < #01, #26, #1E, #1B, #05, #$0784 >   ;04
    sprite-part < #01, #40, #04, #10, #10, #$0B28 >   ;05
    sprite-part < #01, #40, #04, #20, #00, #$0B48 >   ;06
    sprite-part < #01, #30, #14, #00, #20, #$0B06 >   ;07
    sprite-part < #01, #30, #14, #10, #10, #$0B26 >   ;08
    sprite-part < #01, #30, #14, #20, #00, #$0B46 >   ;09
    sprite-part < #01, #20, #24, #20, #00, #$0B44 >   ;0A
    sprite-part < #01, #20, #24, #10, #10, #$0B24 >   ;0B
    sprite-part < #01, #20, #24, #00, #20, #$0B04 >   ;0C
    sprite-part < #01, #10, #34, #20, #00, #$0B42 >   ;0D
    sprite-part < #01, #10, #34, #10, #10, #$0B22 >   ;0E
    sprite-part < #01, #00, #44, #10, #10, #$0B20 >   ;0F
    sprite-part < #01, #00, #44, #20, #00, #$0B40 >   ;10
  ] >
]

sprite_group_0001FC [
  sprite-group < #30, #24, #30, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #11, [
    sprite-part < #01, #43, #01, #1F, #01, #$C164 >   ;00
    sprite-part < #01, #44, #00, #10, #10, #$0164 >   ;01
    sprite-part < #01, #04, #40, #11, #0F, #$0786 >   ;02
    sprite-part < #01, #2D, #17, #10, #10, #$07A2 >   ;03
    sprite-part < #01, #26, #1E, #1B, #05, #$07A4 >   ;04
    sprite-part < #01, #40, #04, #10, #10, #$0B28 >   ;05
    sprite-part < #01, #40, #04, #20, #00, #$0B48 >   ;06
    sprite-part < #01, #30, #14, #00, #20, #$0B06 >   ;07
    sprite-part < #01, #30, #14, #10, #10, #$0B26 >   ;08
    sprite-part < #01, #30, #14, #20, #00, #$0B46 >   ;09
    sprite-part < #01, #20, #24, #20, #00, #$0B44 >   ;0A
    sprite-part < #01, #20, #24, #10, #10, #$0B24 >   ;0B
    sprite-part < #01, #20, #24, #00, #20, #$0B04 >   ;0C
    sprite-part < #01, #10, #34, #20, #00, #$0B42 >   ;0D
    sprite-part < #01, #10, #34, #10, #10, #$0B22 >   ;0E
    sprite-part < #01, #00, #44, #10, #10, #$0B20 >   ;0F
    sprite-part < #01, #00, #44, #20, #00, #$0B40 >   ;10
  ] >
]

sprite_group_000280 [
  sprite-group < #27, #28, #31, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #15, [
    sprite-part < #01, #27, #18, #09, #20, #$4BA9 >   ;00
    sprite-part < #01, #38, #07, #13, #16, #$0700 >   ;01
    sprite-part < #01, #0D, #32, #01, #28, #$014C >   ;02
    sprite-part < #01, #27, #18, #1A, #0F, #$07EB >   ;03
    sprite-part < #01, #18, #27, #09, #20, #$0BA9 >   ;04
    sprite-part < #01, #18, #27, #19, #10, #$0BC9 >   ;05
    sprite-part < #01, #27, #18, #19, #10, #$4BC9 >   ;06
    sprite-part < #01, #18, #27, #29, #00, #$0BE9 >   ;07
    sprite-part < #01, #27, #18, #29, #00, #$4BE9 >   ;08
    sprite-part < #01, #08, #37, #09, #20, #$0BA7 >   ;09
    sprite-part < #01, #37, #08, #09, #20, #$4BA7 >   ;0A
    sprite-part < #01, #08, #37, #19, #10, #$0BC7 >   ;0B
    sprite-part < #01, #37, #08, #19, #10, #$4BC7 >   ;0C
    sprite-part < #01, #00, #3F, #09, #20, #$0BA6 >   ;0D
    sprite-part < #01, #3F, #00, #09, #20, #$4BA6 >   ;0E
    sprite-part < #01, #00, #3F, #19, #10, #$0BC6 >   ;0F
    sprite-part < #01, #3F, #00, #19, #10, #$4BC6 >   ;10
    sprite-part < #01, #18, #27, #01, #28, #$0168 >   ;11
    sprite-part < #01, #27, #18, #00, #29, #$C188 >   ;12
    sprite-part < #01, #27, #18, #10, #19, #$C168 >   ;13
    sprite-part < #01, #18, #27, #11, #18, #$0188 >   ;14
  ] >
]

sprite_group_000320 [
  sprite-group < #27, #28, #31, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #15, [
    sprite-part < #01, #27, #18, #09, #20, #$4BA9 >   ;00
    sprite-part < #01, #38, #07, #13, #16, #$0702 >   ;01
    sprite-part < #01, #0D, #32, #01, #28, #$014A >   ;02
    sprite-part < #01, #27, #18, #1A, #0F, #$07ED >   ;03
    sprite-part < #01, #18, #27, #09, #20, #$0BA9 >   ;04
    sprite-part < #01, #18, #27, #19, #10, #$0BC9 >   ;05
    sprite-part < #01, #27, #18, #19, #10, #$4BC9 >   ;06
    sprite-part < #01, #18, #27, #29, #00, #$0BE9 >   ;07
    sprite-part < #01, #27, #18, #29, #00, #$4BE9 >   ;08
    sprite-part < #01, #08, #37, #09, #20, #$0BA7 >   ;09
    sprite-part < #01, #37, #08, #09, #20, #$4BA7 >   ;0A
    sprite-part < #01, #08, #37, #19, #10, #$0BC7 >   ;0B
    sprite-part < #01, #37, #08, #19, #10, #$4BC7 >   ;0C
    sprite-part < #01, #00, #3F, #09, #20, #$0BA6 >   ;0D
    sprite-part < #01, #3F, #00, #09, #20, #$4BA6 >   ;0E
    sprite-part < #01, #00, #3F, #19, #10, #$0BC6 >   ;0F
    sprite-part < #01, #3F, #00, #19, #10, #$4BC6 >   ;10
    sprite-part < #01, #18, #27, #01, #28, #$01AB >   ;11
    sprite-part < #01, #27, #18, #00, #29, #$C1CB >   ;12
    sprite-part < #01, #27, #18, #10, #19, #$C1AB >   ;13
    sprite-part < #01, #18, #27, #11, #18, #$01CB >   ;14
  ] >
]

sprite_group_0003C0 [
  sprite-group < #27, #28, #31, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #15, [
    sprite-part < #01, #27, #18, #09, #20, #$4BA9 >   ;00
    sprite-part < #01, #38, #07, #13, #16, #$0700 >   ;01
    sprite-part < #01, #0D, #32, #01, #28, #$014C >   ;02
    sprite-part < #01, #27, #18, #1A, #0F, #$07EB >   ;03
    sprite-part < #01, #18, #27, #09, #20, #$0BA9 >   ;04
    sprite-part < #01, #18, #27, #19, #10, #$0BC9 >   ;05
    sprite-part < #01, #27, #18, #19, #10, #$4BC9 >   ;06
    sprite-part < #01, #18, #27, #29, #00, #$0BE9 >   ;07
    sprite-part < #01, #27, #18, #29, #00, #$4BE9 >   ;08
    sprite-part < #01, #08, #37, #09, #20, #$0BA7 >   ;09
    sprite-part < #01, #37, #08, #09, #20, #$4BA7 >   ;0A
    sprite-part < #01, #08, #37, #19, #10, #$0BC7 >   ;0B
    sprite-part < #01, #37, #08, #19, #10, #$4BC7 >   ;0C
    sprite-part < #01, #00, #3F, #09, #20, #$0BA6 >   ;0D
    sprite-part < #01, #3F, #00, #09, #20, #$4BA6 >   ;0E
    sprite-part < #01, #00, #3F, #19, #10, #$0BC6 >   ;0F
    sprite-part < #01, #3F, #00, #19, #10, #$4BC6 >   ;10
    sprite-part < #01, #18, #27, #01, #28, #$01AD >   ;11
    sprite-part < #01, #27, #18, #00, #29, #$C1CD >   ;12
    sprite-part < #01, #27, #18, #10, #19, #$C1AD >   ;13
    sprite-part < #01, #18, #27, #11, #18, #$01CD >   ;14
  ] >
]

sprite_group_000460 [
  sprite-group < #08, #08, #20, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #04, [
    sprite-part < #01, #00, #00, #00, #10, #$0190 >   ;00
    sprite-part < #00, #00, #08, #10, #08, #$01B0 >   ;01
    sprite-part < #00, #07, #01, #10, #08, #$41B0 >   ;02
    sprite-part < #00, #04, #04, #17, #01, #$07C0 >   ;03
  ] >
]

sprite_group_000489 [
  sprite-group < #08, #08, #20, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #04, [
    sprite-part < #01, #00, #00, #00, #10, #$017A >   ;00
    sprite-part < #00, #00, #08, #10, #08, #$019A >   ;01
    sprite-part < #00, #08, #00, #10, #08, #$019B >   ;02
    sprite-part < #00, #05, #03, #17, #01, #$07C0 >   ;03
  ] >
]

sprite_group_0004B2 [
  sprite-group < #09, #07, #20, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #04, [
    sprite-part < #01, #00, #00, #00, #10, #$417A >   ;00
    sprite-part < #00, #08, #00, #10, #08, #$419A >   ;01
    sprite-part < #00, #00, #08, #10, #08, #$419B >   ;02
    sprite-part < #00, #04, #04, #17, #01, #$07C0 >   ;03
  ] >
]

sprite_group_0004DB [
  sprite-group < #24, #30, #30, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #10, [
    sprite-part < #01, #01, #43, #1F, #01, #$8160 >   ;00
    sprite-part < #01, #00, #44, #10, #10, #$4160 >   ;01
    sprite-part < #01, #17, #2D, #10, #10, #$47A2 >   ;02
    sprite-part < #01, #1E, #26, #1B, #05, #$47A4 >   ;03
    sprite-part < #01, #04, #40, #10, #10, #$4B28 >   ;04
    sprite-part < #01, #04, #40, #20, #00, #$4B48 >   ;05
    sprite-part < #01, #14, #30, #00, #20, #$4B06 >   ;06
    sprite-part < #01, #14, #30, #10, #10, #$4B26 >   ;07
    sprite-part < #01, #14, #30, #20, #00, #$4B46 >   ;08
    sprite-part < #01, #24, #20, #20, #00, #$4B44 >   ;09
    sprite-part < #01, #24, #20, #10, #10, #$4B24 >   ;0A
    sprite-part < #01, #24, #20, #00, #20, #$4B04 >   ;0B
    sprite-part < #01, #34, #10, #20, #00, #$4B42 >   ;0C
    sprite-part < #01, #34, #10, #10, #10, #$4B22 >   ;0D
    sprite-part < #01, #44, #00, #10, #10, #$4B20 >   ;0E
    sprite-part < #01, #44, #00, #20, #00, #$4B40 >   ;0F
  ] >
]

sprite_group_000558 [
  sprite-group < #24, #30, #30, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #10, [
    sprite-part < #01, #01, #43, #1F, #01, #$8162 >   ;00
    sprite-part < #01, #00, #44, #10, #10, #$4162 >   ;01
    sprite-part < #01, #17, #2D, #10, #10, #$4782 >   ;02
    sprite-part < #01, #1E, #26, #1B, #05, #$4784 >   ;03
    sprite-part < #01, #04, #40, #10, #10, #$4B28 >   ;04
    sprite-part < #01, #04, #40, #20, #00, #$4B48 >   ;05
    sprite-part < #01, #14, #30, #00, #20, #$4B06 >   ;06
    sprite-part < #01, #14, #30, #10, #10, #$4B26 >   ;07
    sprite-part < #01, #14, #30, #20, #00, #$4B46 >   ;08
    sprite-part < #01, #24, #20, #20, #00, #$4B44 >   ;09
    sprite-part < #01, #24, #20, #10, #10, #$4B24 >   ;0A
    sprite-part < #01, #24, #20, #00, #20, #$4B04 >   ;0B
    sprite-part < #01, #34, #10, #20, #00, #$4B42 >   ;0C
    sprite-part < #01, #34, #10, #10, #10, #$4B22 >   ;0D
    sprite-part < #01, #44, #00, #10, #10, #$4B20 >   ;0E
    sprite-part < #01, #44, #00, #20, #00, #$4B40 >   ;0F
  ] >
]

sprite_group_0005D5 [
  sprite-group < #24, #30, #30, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #10, [
    sprite-part < #01, #01, #43, #1F, #01, #$8164 >   ;00
    sprite-part < #01, #00, #44, #10, #10, #$4164 >   ;01
    sprite-part < #01, #17, #2D, #10, #10, #$47A2 >   ;02
    sprite-part < #01, #1E, #26, #1B, #05, #$47A4 >   ;03
    sprite-part < #01, #04, #40, #10, #10, #$4B28 >   ;04
    sprite-part < #01, #04, #40, #20, #00, #$4B48 >   ;05
    sprite-part < #01, #14, #30, #00, #20, #$4B06 >   ;06
    sprite-part < #01, #14, #30, #10, #10, #$4B26 >   ;07
    sprite-part < #01, #14, #30, #20, #00, #$4B46 >   ;08
    sprite-part < #01, #24, #20, #20, #00, #$4B44 >   ;09
    sprite-part < #01, #24, #20, #10, #10, #$4B24 >   ;0A
    sprite-part < #01, #24, #20, #00, #20, #$4B04 >   ;0B
    sprite-part < #01, #34, #10, #20, #00, #$4B42 >   ;0C
    sprite-part < #01, #34, #10, #10, #10, #$4B22 >   ;0D
    sprite-part < #01, #44, #00, #10, #10, #$4B20 >   ;0E
    sprite-part < #01, #44, #00, #20, #00, #$4B40 >   ;0F
  ] >
]

sprite_group_000652 [
  sprite-group < #30, #24, #36, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #12, [
    sprite-part < #01, #2B, #19, #00, #26, #$01C4 >   ;00
    sprite-part < #01, #43, #01, #25, #01, #$C160 >   ;01
    sprite-part < #01, #44, #00, #16, #10, #$0160 >   ;02
    sprite-part < #01, #04, #40, #17, #0F, #$0786 >   ;03
    sprite-part < #01, #2D, #17, #16, #10, #$07A2 >   ;04
    sprite-part < #01, #26, #1E, #21, #05, #$07A4 >   ;05
    sprite-part < #01, #40, #04, #16, #10, #$0B28 >   ;06
    sprite-part < #01, #40, #04, #26, #00, #$0B48 >   ;07
    sprite-part < #01, #30, #14, #06, #20, #$0B06 >   ;08
    sprite-part < #01, #30, #14, #16, #10, #$0B26 >   ;09
    sprite-part < #01, #30, #14, #26, #00, #$0B46 >   ;0A
    sprite-part < #01, #20, #24, #26, #00, #$0B44 >   ;0B
    sprite-part < #01, #20, #24, #16, #10, #$0B24 >   ;0C
    sprite-part < #01, #20, #24, #06, #20, #$0B04 >   ;0D
    sprite-part < #01, #10, #34, #26, #00, #$0B42 >   ;0E
    sprite-part < #01, #10, #34, #16, #10, #$0B22 >   ;0F
    sprite-part < #01, #00, #44, #16, #10, #$0B20 >   ;10
    sprite-part < #01, #00, #44, #26, #00, #$0B40 >   ;11
  ] >
]

sprite_group_0006DD [
  sprite-group < #30, #24, #36, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #12, [
    sprite-part < #01, #2B, #19, #00, #26, #$01E6 >   ;00
    sprite-part < #01, #43, #01, #25, #01, #$C162 >   ;01
    sprite-part < #01, #44, #00, #16, #10, #$0162 >   ;02
    sprite-part < #01, #04, #40, #17, #0F, #$0766 >   ;03
    sprite-part < #01, #2D, #17, #16, #10, #$0782 >   ;04
    sprite-part < #01, #26, #1E, #21, #05, #$0784 >   ;05
    sprite-part < #01, #40, #04, #16, #10, #$0B28 >   ;06
    sprite-part < #01, #40, #04, #26, #00, #$0B48 >   ;07
    sprite-part < #01, #30, #14, #06, #20, #$0B06 >   ;08
    sprite-part < #01, #30, #14, #16, #10, #$0B26 >   ;09
    sprite-part < #01, #30, #14, #26, #00, #$0B46 >   ;0A
    sprite-part < #01, #20, #24, #26, #00, #$0B44 >   ;0B
    sprite-part < #01, #20, #24, #16, #10, #$0B24 >   ;0C
    sprite-part < #01, #20, #24, #06, #20, #$0B04 >   ;0D
    sprite-part < #01, #10, #34, #26, #00, #$0B42 >   ;0E
    sprite-part < #01, #10, #34, #16, #10, #$0B22 >   ;0F
    sprite-part < #01, #00, #44, #16, #10, #$0B20 >   ;10
    sprite-part < #01, #00, #44, #26, #00, #$0B40 >   ;11
  ] >
]

sprite_group_000768 [
  sprite-group < #30, #24, #36, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #12, [
    sprite-part < #01, #2B, #19, #00, #26, #$01C4 >   ;00
    sprite-part < #01, #43, #01, #25, #01, #$C164 >   ;01
    sprite-part < #01, #44, #00, #16, #10, #$0164 >   ;02
    sprite-part < #01, #04, #40, #17, #0F, #$0786 >   ;03
    sprite-part < #01, #2D, #17, #16, #10, #$07A2 >   ;04
    sprite-part < #01, #26, #1E, #21, #05, #$07A4 >   ;05
    sprite-part < #01, #40, #04, #16, #10, #$0B28 >   ;06
    sprite-part < #01, #40, #04, #26, #00, #$0B48 >   ;07
    sprite-part < #01, #30, #14, #06, #20, #$0B06 >   ;08
    sprite-part < #01, #30, #14, #16, #10, #$0B26 >   ;09
    sprite-part < #01, #30, #14, #26, #00, #$0B46 >   ;0A
    sprite-part < #01, #20, #24, #26, #00, #$0B44 >   ;0B
    sprite-part < #01, #20, #24, #16, #10, #$0B24 >   ;0C
    sprite-part < #01, #20, #24, #06, #20, #$0B04 >   ;0D
    sprite-part < #01, #10, #34, #26, #00, #$0B42 >   ;0E
    sprite-part < #01, #10, #34, #16, #10, #$0B22 >   ;0F
    sprite-part < #01, #00, #44, #16, #10, #$0B20 >   ;10
    sprite-part < #01, #00, #44, #26, #00, #$0B40 >   ;11
  ] >
]