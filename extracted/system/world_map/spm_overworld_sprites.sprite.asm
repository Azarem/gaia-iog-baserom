---------------------------------------------

spm_overworld_sprites [
  &sprite_set_00001C   ;00
  &sprite_set_00002E   ;01
  &sprite_set_000040   ;02
  &sprite_set_000052   ;03
  &sprite_set_000064   ;04
  &sprite_set_000076   ;05
  &sprite_set_000088   ;06
  &sprite_set_00009A   ;07
  &sprite_set_0000B0   ;08
  &sprite_set_0000C6   ;09
  &sprite_set_0000DC   ;0A
  &sprite_set_0000F2   ;0B
  &sprite_set_000100   ;0C
  &sprite_set_00010E   ;0D
]

sprite_set_00001C [
  sprite-set < #$0007, &sprite_group_000120 >   ;00
  sprite-set < #$0007, &sprite_group_00015E >   ;01
  sprite-set < #$0007, &sprite_group_000195 >   ;02
  sprite-set < #$0007, &sprite_group_0001D3 >   ;03
]

sprite_set_00002E [
  sprite-set < #$0007, &sprite_group_00020A >   ;00
  sprite-set < #$0007, &sprite_group_00025D >   ;01
  sprite-set < #$0007, &sprite_group_00020A >   ;02
  sprite-set < #$0007, &sprite_group_00029B >   ;03
]

sprite_set_000040 [
  sprite-set < #$0007, &sprite_group_0002D9 >   ;00
  sprite-set < #$0007, &sprite_group_00031E >   ;01
  sprite-set < #$0007, &sprite_group_0002D9 >   ;02
  sprite-set < #$0007, &sprite_group_00034E >   ;03
]

sprite_set_000052 [
  sprite-set < #$0007, &sprite_group_00037E >   ;00
  sprite-set < #$0007, &sprite_group_0003C3 >   ;01
  sprite-set < #$0007, &sprite_group_00037E >   ;02
  sprite-set < #$0007, &sprite_group_0003F3 >   ;03
]

sprite_set_000064 [
  sprite-set < #$0007, &sprite_group_000423 >   ;00
  sprite-set < #$0007, &sprite_group_000468 >   ;01
  sprite-set < #$0007, &sprite_group_000423 >   ;02
  sprite-set < #$0007, &sprite_group_000498 >   ;03
]

sprite_set_000076 [
  sprite-set < #$0007, &sprite_group_0004C8 >   ;00
  sprite-set < #$0007, &sprite_group_00051B >   ;01
  sprite-set < #$0007, &sprite_group_0004C8 >   ;02
  sprite-set < #$0007, &sprite_group_000559 >   ;03
]

sprite_set_000088 [
  sprite-set < #$0007, &sprite_group_000597 >   ;00
  sprite-set < #$0007, &sprite_group_0005AB >   ;01
  sprite-set < #$0007, &sprite_group_000597 >   ;02
  sprite-set < #$0007, &sprite_group_0005BF >   ;03
]

sprite_set_00009A [
  sprite-set < #$0007, &sprite_group_0005D3 >   ;00
  sprite-set < #$0007, &sprite_group_00062D >   ;01
  sprite-set < #$0007, &sprite_group_000687 >   ;02
  sprite-set < #$0009, &sprite_group_0006EF >   ;03
  sprite-set < #$0007, &sprite_group_000687 >   ;04
]

sprite_set_0000B0 [
  sprite-set < #$0007, &sprite_group_000750 >   ;00
  sprite-set < #$0007, &sprite_group_0007AA >   ;01
  sprite-set < #$0007, &sprite_group_000804 >   ;02
  sprite-set < #$0009, &sprite_group_00086C >   ;03
  sprite-set < #$0007, &sprite_group_000804 >   ;04
]

sprite_set_0000C6 [
  sprite-set < #$0007, &sprite_group_0008CD >   ;00
  sprite-set < #$0007, &sprite_group_000927 >   ;01
  sprite-set < #$0007, &sprite_group_000981 >   ;02
  sprite-set < #$0009, &sprite_group_0009E9 >   ;03
  sprite-set < #$0007, &sprite_group_000981 >   ;04
]

sprite_set_0000DC [
  sprite-set < #$0007, &sprite_group_000A4A >   ;00
  sprite-set < #$0007, &sprite_group_000AA4 >   ;01
  sprite-set < #$0007, &sprite_group_000AFE >   ;02
  sprite-set < #$0009, &sprite_group_000B66 >   ;03
  sprite-set < #$0007, &sprite_group_000AFE >   ;04
]

sprite_set_0000F2 [
  sprite-set < #$0001, &sprite_group_000BC7 >   ;00
  sprite-set < #$0001, &sprite_group_000C7C >   ;01
  sprite-set < #$0001, &sprite_group_000D31 >   ;02
]

sprite_set_000100 [
  sprite-set < #$0001, &sprite_group_000DE6 >   ;00
  sprite-set < #$0001, &sprite_group_000EB0 >   ;01
  sprite-set < #$0001, &sprite_group_000F7A >   ;02
]

sprite_set_00010E [
  sprite-set < #$0009, &sprite_group_001044 >   ;00
  sprite-set < #$0009, &sprite_group_0010B3 >   ;01
  sprite-set < #$0009, &sprite_group_001122 >   ;02
  sprite-set < #$0009, &sprite_group_0011C9 >   ;03
]

sprite_group_000120 [
  sprite-group < #0E, #11, #23, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #07, [
    sprite-part < #01, #09, #06, #0A, #11, #$0062 >   ;00
    sprite-part < #01, #07, #08, #00, #1B, #$0000 >   ;01
    sprite-part < #00, #09, #0E, #1A, #09, #$00FE >   ;02
    sprite-part < #00, #11, #06, #1A, #09, #$00FF >   ;03
    sprite-part < #01, #00, #0F, #0A, #11, #$4004 >   ;04
    sprite-part < #01, #0F, #00, #0A, #11, #$4002 >   ;05
    sprite-part < #01, #07, #08, #1B, #00, #$0042 >   ;06
  ] >
]

sprite_group_00015E [
  sprite-group < #0C, #0B, #26, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #05, #02, #00, #1E, #$0020 >   ;00
    sprite-part < #01, #07, #00, #1A, #04, #$0060 >   ;01
    sprite-part < #01, #05, #02, #1E, #00, #$0042 >   ;02
    sprite-part < #01, #07, #00, #0A, #14, #$0062 >   ;03
    sprite-part < #01, #00, #07, #0C, #12, #$4023 >   ;04
    sprite-part < #01, #07, #00, #0C, #12, #$4022 >   ;05
  ] >
]

sprite_group_000195 [
  sprite-group < #0E, #11, #23, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #07, [
    sprite-part < #01, #09, #06, #0A, #11, #$0062 >   ;00
    sprite-part < #01, #07, #08, #00, #1B, #$0000 >   ;01
    sprite-part < #00, #05, #12, #1A, #09, #$40FF >   ;02
    sprite-part < #00, #0D, #0A, #1A, #09, #$40FE >   ;03
    sprite-part < #01, #00, #0F, #0A, #11, #$4004 >   ;04
    sprite-part < #01, #07, #08, #1B, #00, #$0042 >   ;05
    sprite-part < #01, #0F, #00, #0A, #11, #$4002 >   ;06
  ] >
]

sprite_group_0001D3 [
  sprite-group < #09, #0E, #25, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #04, #03, #0A, #13, #$0062 >   ;00
    sprite-part < #01, #02, #05, #00, #1D, #$0040 >   ;01
    sprite-part < #01, #07, #00, #0C, #11, #$0023 >   ;02
    sprite-part < #01, #00, #07, #1A, #03, #$4060 >   ;03
    sprite-part < #01, #00, #07, #0C, #11, #$0022 >   ;04
    sprite-part < #01, #02, #05, #1D, #00, #$0042 >   ;05
  ] >
]

sprite_group_00020A [
  sprite-group < #0A, #0B, #21, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #0A, [
    sprite-part < #00, #00, #0D, #09, #10, #$0844 >   ;00
    sprite-part < #00, #0D, #00, #09, #10, #$4844 >   ;01
    sprite-part < #00, #0A, #03, #00, #19, #$0837 >   ;02
    sprite-part < #00, #03, #0A, #00, #19, #$4837 >   ;03
    sprite-part < #00, #0A, #03, #08, #11, #$0847 >   ;04
    sprite-part < #00, #03, #0A, #08, #11, #$4847 >   ;05
    sprite-part < #00, #0A, #03, #10, #09, #$0857 >   ;06
    sprite-part < #00, #03, #0A, #10, #09, #$4857 >   ;07
    sprite-part < #00, #0A, #03, #18, #01, #$0867 >   ;08
    sprite-part < #00, #03, #0A, #18, #01, #$4867 >   ;09
  ] >
]

sprite_group_00025D [
  sprite-group < #09, #0B, #20, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #07, [
    sprite-part < #00, #00, #0C, #09, #0F, #$0844 >   ;00
    sprite-part < #00, #0C, #00, #09, #0F, #$4844 >   ;01
    sprite-part < #00, #09, #03, #00, #18, #$0837 >   ;02
    sprite-part < #00, #02, #0A, #00, #18, #$4837 >   ;03
    sprite-part < #01, #02, #02, #08, #08, #$080A >   ;04
    sprite-part < #00, #02, #0A, #18, #00, #$082A >   ;05
    sprite-part < #00, #0A, #02, #18, #00, #$082B >   ;06
  ] >
]

sprite_group_00029B [
  sprite-group < #0A, #0A, #20, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #07, [
    sprite-part < #00, #0C, #00, #09, #0F, #$4844 >   ;00
    sprite-part < #00, #00, #0C, #09, #0F, #$0844 >   ;01
    sprite-part < #00, #03, #09, #00, #18, #$4837 >   ;02
    sprite-part < #00, #0A, #02, #00, #18, #$0837 >   ;03
    sprite-part < #01, #02, #02, #08, #08, #$480A >   ;04
    sprite-part < #00, #0A, #02, #18, #00, #$482A >   ;05
    sprite-part < #00, #02, #0A, #18, #00, #$482B >   ;06
  ] >
]

sprite_group_0002D9 [
  sprite-group < #07, #08, #21, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #08, [
    sprite-part < #00, #07, #00, #00, #19, #$0A38 >   ;00
    sprite-part < #00, #00, #07, #00, #19, #$4A38 >   ;01
    sprite-part < #00, #07, #00, #08, #11, #$0A48 >   ;02
    sprite-part < #00, #00, #07, #08, #11, #$4A48 >   ;03
    sprite-part < #00, #07, #00, #10, #09, #$0A58 >   ;04
    sprite-part < #00, #00, #07, #10, #09, #$4A58 >   ;05
    sprite-part < #00, #07, #00, #18, #01, #$0A68 >   ;06
    sprite-part < #00, #00, #07, #18, #01, #$4A68 >   ;07
  ] >
]

sprite_group_00031E [
  sprite-group < #07, #09, #20, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #05, [
    sprite-part < #00, #07, #01, #00, #18, #$0A38 >   ;00
    sprite-part < #00, #00, #08, #00, #18, #$4A38 >   ;01
    sprite-part < #01, #00, #00, #08, #08, #$0A0C >   ;02
    sprite-part < #00, #08, #00, #18, #00, #$0A2D >   ;03
    sprite-part < #00, #00, #08, #18, #00, #$0A2C >   ;04
  ] >
]

sprite_group_00034E [
  sprite-group < #08, #08, #20, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #05, [
    sprite-part < #00, #01, #07, #00, #18, #$4A38 >   ;00
    sprite-part < #00, #08, #00, #00, #18, #$0A38 >   ;01
    sprite-part < #01, #00, #00, #08, #08, #$4A0C >   ;02
    sprite-part < #00, #00, #08, #18, #00, #$4A2D >   ;03
    sprite-part < #00, #08, #00, #18, #00, #$4A2C >   ;04
  ] >
]

sprite_group_00037E [
  sprite-group < #07, #08, #21, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #08, [
    sprite-part < #00, #07, #00, #00, #19, #$0635 >   ;00
    sprite-part < #00, #00, #07, #00, #19, #$4635 >   ;01
    sprite-part < #00, #07, #00, #08, #11, #$0645 >   ;02
    sprite-part < #00, #00, #07, #08, #11, #$4645 >   ;03
    sprite-part < #00, #07, #00, #10, #09, #$0655 >   ;04
    sprite-part < #00, #00, #07, #10, #09, #$4655 >   ;05
    sprite-part < #00, #07, #00, #18, #01, #$0665 >   ;06
    sprite-part < #00, #00, #07, #18, #01, #$4665 >   ;07
  ] >
]

sprite_group_0003C3 [
  sprite-group < #07, #09, #20, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #05, [
    sprite-part < #00, #07, #01, #00, #18, #$0635 >   ;00
    sprite-part < #00, #00, #08, #00, #18, #$4635 >   ;01
    sprite-part < #00, #08, #00, #18, #00, #$0627 >   ;02
    sprite-part < #01, #00, #00, #08, #08, #$0606 >   ;03
    sprite-part < #00, #00, #08, #18, #00, #$0626 >   ;04
  ] >
]

sprite_group_0003F3 [
  sprite-group < #08, #08, #20, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #05, [
    sprite-part < #00, #01, #07, #00, #18, #$4635 >   ;00
    sprite-part < #00, #08, #00, #00, #18, #$0635 >   ;01
    sprite-part < #00, #00, #08, #18, #00, #$4627 >   ;02
    sprite-part < #01, #00, #00, #08, #08, #$4606 >   ;03
    sprite-part < #00, #08, #00, #18, #00, #$4626 >   ;04
  ] >
]

sprite_group_000423 [
  sprite-group < #07, #08, #21, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #08, [
    sprite-part < #00, #07, #00, #00, #19, #$0A36 >   ;00
    sprite-part < #00, #00, #07, #00, #19, #$4A36 >   ;01
    sprite-part < #00, #07, #00, #08, #11, #$0A46 >   ;02
    sprite-part < #00, #00, #07, #08, #11, #$4A46 >   ;03
    sprite-part < #00, #07, #00, #10, #09, #$0A56 >   ;04
    sprite-part < #00, #00, #07, #10, #09, #$4A56 >   ;05
    sprite-part < #00, #00, #07, #18, #01, #$4A66 >   ;06
    sprite-part < #00, #07, #00, #18, #01, #$0A66 >   ;07
  ] >
]

sprite_group_000468 [
  sprite-group < #07, #09, #20, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #05, [
    sprite-part < #00, #07, #01, #00, #18, #$0A36 >   ;00
    sprite-part < #00, #00, #08, #00, #18, #$4A36 >   ;01
    sprite-part < #01, #00, #00, #08, #08, #$0A08 >   ;02
    sprite-part < #00, #08, #00, #18, #00, #$0A29 >   ;03
    sprite-part < #00, #00, #08, #18, #00, #$0A28 >   ;04
  ] >
]

sprite_group_000498 [
  sprite-group < #08, #08, #20, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #05, [
    sprite-part < #00, #01, #07, #00, #18, #$4A36 >   ;00
    sprite-part < #00, #08, #00, #00, #18, #$0A36 >   ;01
    sprite-part < #01, #00, #00, #08, #08, #$4A08 >   ;02
    sprite-part < #00, #00, #08, #18, #00, #$4A29 >   ;03
    sprite-part < #00, #08, #00, #18, #00, #$4A28 >   ;04
  ] >
]

sprite_group_0004C8 [
  sprite-group < #07, #08, #29, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #0A, [
    sprite-part < #00, #00, #07, #00, #21, #$0C25 >   ;00
    sprite-part < #00, #07, #00, #00, #21, #$4C25 >   ;01
    sprite-part < #00, #00, #07, #08, #19, #$0C39 >   ;02
    sprite-part < #00, #07, #00, #08, #19, #$4C39 >   ;03
    sprite-part < #00, #00, #07, #10, #11, #$0C49 >   ;04
    sprite-part < #00, #07, #00, #10, #11, #$4C49 >   ;05
    sprite-part < #00, #00, #07, #18, #09, #$0C59 >   ;06
    sprite-part < #00, #07, #00, #18, #09, #$4C59 >   ;07
    sprite-part < #00, #07, #00, #20, #01, #$4C69 >   ;08
    sprite-part < #00, #00, #07, #20, #01, #$0C69 >   ;09
  ] >
]

sprite_group_00051B [
  sprite-group < #07, #09, #28, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #07, [
    sprite-part < #00, #00, #08, #00, #20, #$0C25 >   ;00
    sprite-part < #00, #07, #01, #00, #20, #$4C25 >   ;01
    sprite-part < #00, #00, #08, #08, #18, #$0C39 >   ;02
    sprite-part < #00, #07, #01, #08, #18, #$4C39 >   ;03
    sprite-part < #01, #00, #00, #10, #08, #$0C0E >   ;04
    sprite-part < #00, #08, #00, #20, #00, #$0C2F >   ;05
    sprite-part < #00, #00, #08, #20, #00, #$0C2E >   ;06
  ] >
]

sprite_group_000559 [
  sprite-group < #08, #08, #28, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #07, [
    sprite-part < #00, #08, #00, #00, #20, #$4C25 >   ;00
    sprite-part < #00, #01, #07, #00, #20, #$0C25 >   ;01
    sprite-part < #00, #08, #00, #08, #18, #$4C39 >   ;02
    sprite-part < #00, #01, #07, #08, #18, #$0C39 >   ;03
    sprite-part < #01, #00, #00, #10, #08, #$4C0E >   ;04
    sprite-part < #00, #00, #08, #20, #00, #$4C2F >   ;05
    sprite-part < #00, #08, #00, #20, #00, #$4C2E >   ;06
  ] >
]

sprite_group_000597 [
  sprite-group < #08, #08, #11, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #01, #00, #00, #00, #01, #$083A >
  ] >
]

sprite_group_0005AB [
  sprite-group < #08, #08, #10, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #01, #00, #00, #00, #00, #$085A >
  ] >
]

sprite_group_0005BF [
  sprite-group < #08, #08, #10, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #01, #00, #00, #00, #00, #$485A >
  ] >
]

sprite_group_0005D3 [
  sprite-group < #10, #10, #30, #01, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #0B, [
    sprite-part < #01, #09, #07, #03, #1E, #$003C >   ;00
    sprite-part < #01, #09, #07, #13, #0E, #$005C >   ;01
    sprite-part < #01, #00, #10, #00, #21, #$04A0 >   ;02
    sprite-part < #01, #10, #00, #00, #21, #$44A0 >   ;03
    sprite-part < #01, #08, #08, #1C, #05, #$04E2 >   ;04
    sprite-part < #01, #00, #10, #10, #11, #$04C0 >   ;05
    sprite-part < #01, #10, #00, #10, #11, #$44C0 >   ;06
    sprite-part < #01, #10, #00, #20, #01, #$44E0 >   ;07
    sprite-part < #01, #00, #10, #20, #01, #$04E0 >   ;08
    sprite-part < #01, #04, #0C, #21, #00, #$04E8 >   ;09
    sprite-part < #01, #0C, #04, #21, #00, #$44E8 >   ;0A
  ] >
]

sprite_group_00062D [
  sprite-group < #10, #10, #2A, #06, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #0B, [
    sprite-part < #01, #09, #07, #03, #1D, #$003C >   ;00
    sprite-part < #01, #09, #07, #13, #0D, #$005C >   ;01
    sprite-part < #01, #00, #10, #00, #20, #$04A0 >   ;02
    sprite-part < #01, #08, #08, #1B, #05, #$04C2 >   ;03
    sprite-part < #01, #10, #00, #00, #20, #$44A0 >   ;04
    sprite-part < #01, #00, #10, #10, #10, #$04C0 >   ;05
    sprite-part < #01, #10, #00, #10, #10, #$44C0 >   ;06
    sprite-part < #01, #00, #10, #20, #00, #$04E4 >   ;07
    sprite-part < #01, #01, #0F, #1B, #05, #$04E8 >   ;08
    sprite-part < #01, #10, #00, #20, #00, #$44E4 >   ;09
    sprite-part < #01, #0F, #01, #1B, #05, #$44E8 >   ;0A
  ] >
]

sprite_group_000687 [
  sprite-group < #10, #10, #3F, #01, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #0D, [
    sprite-part < #01, #08, #08, #1C, #14, #$04E2 >   ;00
    sprite-part < #01, #09, #07, #03, #2D, #$003C >   ;01
    sprite-part < #01, #09, #07, #13, #1D, #$005C >   ;02
    sprite-part < #01, #00, #10, #00, #30, #$04A0 >   ;03
    sprite-part < #01, #10, #00, #00, #30, #$44A0 >   ;04
    sprite-part < #01, #00, #10, #10, #20, #$04C0 >   ;05
    sprite-part < #01, #10, #00, #10, #20, #$44C0 >   ;06
    sprite-part < #01, #00, #10, #20, #10, #$04D6 >   ;07
    sprite-part < #01, #10, #00, #20, #10, #$44D6 >   ;08
    sprite-part < #01, #00, #10, #28, #08, #$04E6 >   ;09
    sprite-part < #01, #10, #00, #28, #08, #$44E6 >   ;0A
    sprite-part < #01, #05, #0B, #30, #00, #$04E8 >   ;0B
    sprite-part < #01, #0B, #05, #30, #00, #$44E8 >   ;0C
  ] >
]

sprite_group_0006EF [
  sprite-group < #10, #10, #44, #05, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #0C, [
    sprite-part < #01, #08, #08, #1C, #1D, #$04E2 >   ;00
    sprite-part < #01, #09, #07, #03, #36, #$003C >   ;01
    sprite-part < #01, #09, #07, #13, #26, #$005C >   ;02
    sprite-part < #01, #00, #10, #00, #39, #$04A0 >   ;03
    sprite-part < #01, #10, #00, #00, #39, #$44A0 >   ;04
    sprite-part < #01, #00, #10, #10, #29, #$04C0 >   ;05
    sprite-part < #01, #10, #00, #10, #29, #$44C0 >   ;06
    sprite-part < #01, #00, #10, #20, #19, #$04D6 >   ;07
    sprite-part < #01, #10, #00, #20, #19, #$44D6 >   ;08
    sprite-part < #01, #00, #10, #28, #11, #$04E6 >   ;09
    sprite-part < #01, #10, #00, #28, #11, #$44E6 >   ;0A
    sprite-part < #01, #08, #08, #39, #00, #$0042 >   ;0B
  ] >
]

sprite_group_000750 [
  sprite-group < #10, #10, #30, #01, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #0B, [
    sprite-part < #01, #09, #07, #03, #1E, #$0A6C >   ;00
    sprite-part < #01, #09, #07, #13, #0E, #$0A8C >   ;01
    sprite-part < #01, #00, #10, #00, #21, #$04A0 >   ;02
    sprite-part < #01, #10, #00, #00, #21, #$44A0 >   ;03
    sprite-part < #01, #08, #08, #1C, #05, #$04E2 >   ;04
    sprite-part < #01, #00, #10, #10, #11, #$04C0 >   ;05
    sprite-part < #01, #10, #00, #10, #11, #$44C0 >   ;06
    sprite-part < #01, #10, #00, #20, #01, #$44E0 >   ;07
    sprite-part < #01, #00, #10, #20, #01, #$04E0 >   ;08
    sprite-part < #01, #04, #0C, #21, #00, #$04E8 >   ;09
    sprite-part < #01, #0C, #04, #21, #00, #$44E8 >   ;0A
  ] >
]

sprite_group_0007AA [
  sprite-group < #10, #10, #2A, #06, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #0B, [
    sprite-part < #01, #09, #07, #03, #1D, #$0A6C >   ;00
    sprite-part < #01, #09, #07, #13, #0D, #$0A8C >   ;01
    sprite-part < #01, #00, #10, #00, #20, #$04A0 >   ;02
    sprite-part < #01, #08, #08, #1B, #05, #$04C2 >   ;03
    sprite-part < #01, #10, #00, #00, #20, #$44A0 >   ;04
    sprite-part < #01, #00, #10, #10, #10, #$04C0 >   ;05
    sprite-part < #01, #10, #00, #10, #10, #$44C0 >   ;06
    sprite-part < #01, #00, #10, #20, #00, #$04E4 >   ;07
    sprite-part < #01, #01, #0F, #1B, #05, #$04E8 >   ;08
    sprite-part < #01, #10, #00, #20, #00, #$44E4 >   ;09
    sprite-part < #01, #0F, #01, #1B, #05, #$44E8 >   ;0A
  ] >
]

sprite_group_000804 [
  sprite-group < #10, #10, #3F, #01, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #0D, [
    sprite-part < #01, #08, #08, #1C, #14, #$04E2 >   ;00
    sprite-part < #01, #09, #07, #03, #2D, #$0A6C >   ;01
    sprite-part < #01, #09, #07, #13, #1D, #$0A8C >   ;02
    sprite-part < #01, #00, #10, #00, #30, #$04A0 >   ;03
    sprite-part < #01, #10, #00, #00, #30, #$44A0 >   ;04
    sprite-part < #01, #00, #10, #10, #20, #$04C0 >   ;05
    sprite-part < #01, #10, #00, #10, #20, #$44C0 >   ;06
    sprite-part < #01, #00, #10, #20, #10, #$04D6 >   ;07
    sprite-part < #01, #10, #00, #20, #10, #$44D6 >   ;08
    sprite-part < #01, #00, #10, #28, #08, #$04E6 >   ;09
    sprite-part < #01, #10, #00, #28, #08, #$44E6 >   ;0A
    sprite-part < #01, #05, #0B, #30, #00, #$04E8 >   ;0B
    sprite-part < #01, #0B, #05, #30, #00, #$44E8 >   ;0C
  ] >
]

sprite_group_00086C [
  sprite-group < #10, #10, #44, #05, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #0C, [
    sprite-part < #01, #08, #08, #1C, #1D, #$04E2 >   ;00
    sprite-part < #01, #09, #07, #03, #36, #$0A6C >   ;01
    sprite-part < #01, #09, #07, #13, #26, #$0A8C >   ;02
    sprite-part < #01, #00, #10, #00, #39, #$04A0 >   ;03
    sprite-part < #01, #10, #00, #00, #39, #$44A0 >   ;04
    sprite-part < #01, #00, #10, #10, #29, #$04C0 >   ;05
    sprite-part < #01, #10, #00, #10, #29, #$44C0 >   ;06
    sprite-part < #01, #00, #10, #20, #19, #$04D6 >   ;07
    sprite-part < #01, #10, #00, #20, #19, #$44D6 >   ;08
    sprite-part < #01, #00, #10, #28, #11, #$04E6 >   ;09
    sprite-part < #01, #10, #00, #28, #11, #$44E6 >   ;0A
    sprite-part < #01, #08, #08, #39, #00, #$0042 >   ;0B
  ] >
]

sprite_group_0008CD [
  sprite-group < #10, #10, #32, #01, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #0B, [
    sprite-part < #01, #08, #08, #00, #23, #$0C7E >   ;00
    sprite-part < #01, #08, #08, #10, #13, #$0C9E >   ;01
    sprite-part < #01, #00, #10, #02, #21, #$04A0 >   ;02
    sprite-part < #01, #10, #00, #02, #21, #$44A0 >   ;03
    sprite-part < #01, #08, #08, #1E, #05, #$04E2 >   ;04
    sprite-part < #01, #00, #10, #12, #11, #$04C0 >   ;05
    sprite-part < #01, #10, #00, #12, #11, #$44C0 >   ;06
    sprite-part < #01, #10, #00, #22, #01, #$44E0 >   ;07
    sprite-part < #01, #00, #10, #22, #01, #$04E0 >   ;08
    sprite-part < #01, #04, #0C, #23, #00, #$04E8 >   ;09
    sprite-part < #01, #0C, #04, #23, #00, #$44E8 >   ;0A
  ] >
]

sprite_group_000927 [
  sprite-group < #10, #10, #2C, #06, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #0B, [
    sprite-part < #01, #08, #08, #00, #22, #$0C7E >   ;00
    sprite-part < #01, #08, #08, #10, #12, #$0C9E >   ;01
    sprite-part < #01, #00, #10, #02, #20, #$04A0 >   ;02
    sprite-part < #01, #08, #08, #1D, #05, #$04C2 >   ;03
    sprite-part < #01, #10, #00, #02, #20, #$44A0 >   ;04
    sprite-part < #01, #00, #10, #12, #10, #$04C0 >   ;05
    sprite-part < #01, #10, #00, #12, #10, #$44C0 >   ;06
    sprite-part < #01, #00, #10, #22, #00, #$04E4 >   ;07
    sprite-part < #01, #01, #0F, #1D, #05, #$04E8 >   ;08
    sprite-part < #01, #10, #00, #22, #00, #$44E4 >   ;09
    sprite-part < #01, #0F, #01, #1D, #05, #$44E8 >   ;0A
  ] >
]

sprite_group_000981 [
  sprite-group < #10, #10, #41, #01, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #0D, [
    sprite-part < #01, #08, #08, #1E, #14, #$04E2 >   ;00
    sprite-part < #01, #08, #08, #00, #32, #$0C7E >   ;01
    sprite-part < #01, #08, #08, #10, #22, #$0C9E >   ;02
    sprite-part < #01, #00, #10, #02, #30, #$04A0 >   ;03
    sprite-part < #01, #10, #00, #02, #30, #$44A0 >   ;04
    sprite-part < #01, #00, #10, #12, #20, #$04C0 >   ;05
    sprite-part < #01, #10, #00, #12, #20, #$44C0 >   ;06
    sprite-part < #01, #00, #10, #22, #10, #$04D6 >   ;07
    sprite-part < #01, #10, #00, #22, #10, #$44D6 >   ;08
    sprite-part < #01, #00, #10, #2A, #08, #$04E6 >   ;09
    sprite-part < #01, #10, #00, #2A, #08, #$44E6 >   ;0A
    sprite-part < #01, #05, #0B, #32, #00, #$04E8 >   ;0B
    sprite-part < #01, #0B, #05, #32, #00, #$44E8 >   ;0C
  ] >
]

sprite_group_0009E9 [
  sprite-group < #10, #10, #46, #05, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #0C, [
    sprite-part < #01, #08, #08, #1E, #1D, #$04E2 >   ;00
    sprite-part < #01, #08, #08, #00, #3B, #$0C7E >   ;01
    sprite-part < #01, #08, #08, #10, #2B, #$0C9E >   ;02
    sprite-part < #01, #00, #10, #02, #39, #$04A0 >   ;03
    sprite-part < #01, #10, #00, #02, #39, #$44A0 >   ;04
    sprite-part < #01, #00, #10, #12, #29, #$04C0 >   ;05
    sprite-part < #01, #10, #00, #12, #29, #$44C0 >   ;06
    sprite-part < #01, #00, #10, #22, #19, #$04D6 >   ;07
    sprite-part < #01, #10, #00, #22, #19, #$44D6 >   ;08
    sprite-part < #01, #00, #10, #2A, #11, #$04E6 >   ;09
    sprite-part < #01, #10, #00, #2A, #11, #$44E6 >   ;0A
    sprite-part < #01, #08, #08, #3B, #00, #$0042 >   ;0B
  ] >
]

sprite_group_000A4A [
  sprite-group < #10, #10, #32, #01, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #0B, [
    sprite-part < #01, #0A, #06, #00, #23, #$083E >   ;00
    sprite-part < #01, #0A, #06, #10, #13, #$085E >   ;01
    sprite-part < #01, #00, #10, #02, #21, #$04A0 >   ;02
    sprite-part < #01, #10, #00, #02, #21, #$44A0 >   ;03
    sprite-part < #01, #08, #08, #1E, #05, #$04E2 >   ;04
    sprite-part < #01, #00, #10, #12, #11, #$04C0 >   ;05
    sprite-part < #01, #10, #00, #12, #11, #$44C0 >   ;06
    sprite-part < #01, #10, #00, #22, #01, #$44E0 >   ;07
    sprite-part < #01, #00, #10, #22, #01, #$04E0 >   ;08
    sprite-part < #01, #04, #0C, #23, #00, #$04E8 >   ;09
    sprite-part < #01, #0C, #04, #23, #00, #$44E8 >   ;0A
  ] >
]

sprite_group_000AA4 [
  sprite-group < #10, #10, #2C, #06, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #0B, [
    sprite-part < #01, #0A, #06, #00, #22, #$083E >   ;00
    sprite-part < #01, #0A, #06, #10, #12, #$085E >   ;01
    sprite-part < #01, #00, #10, #02, #20, #$04A0 >   ;02
    sprite-part < #01, #08, #08, #1D, #05, #$04C2 >   ;03
    sprite-part < #01, #10, #00, #02, #20, #$44A0 >   ;04
    sprite-part < #01, #00, #10, #12, #10, #$04C0 >   ;05
    sprite-part < #01, #10, #00, #12, #10, #$44C0 >   ;06
    sprite-part < #01, #00, #10, #22, #00, #$04E4 >   ;07
    sprite-part < #01, #01, #0F, #1D, #05, #$04E8 >   ;08
    sprite-part < #01, #10, #00, #22, #00, #$44E4 >   ;09
    sprite-part < #01, #0F, #01, #1D, #05, #$44E8 >   ;0A
  ] >
]

sprite_group_000AFE [
  sprite-group < #10, #10, #41, #01, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #0D, [
    sprite-part < #01, #08, #08, #1E, #14, #$04E2 >   ;00
    sprite-part < #01, #0A, #06, #00, #32, #$083E >   ;01
    sprite-part < #01, #0A, #06, #10, #22, #$085E >   ;02
    sprite-part < #01, #00, #10, #02, #30, #$04A0 >   ;03
    sprite-part < #01, #10, #00, #02, #30, #$44A0 >   ;04
    sprite-part < #01, #00, #10, #12, #20, #$04C0 >   ;05
    sprite-part < #01, #10, #00, #12, #20, #$44C0 >   ;06
    sprite-part < #01, #00, #10, #22, #10, #$04D6 >   ;07
    sprite-part < #01, #10, #00, #22, #10, #$44D6 >   ;08
    sprite-part < #01, #00, #10, #2A, #08, #$04E6 >   ;09
    sprite-part < #01, #10, #00, #2A, #08, #$44E6 >   ;0A
    sprite-part < #01, #05, #0B, #32, #00, #$04E8 >   ;0B
    sprite-part < #01, #0B, #05, #32, #00, #$44E8 >   ;0C
  ] >
]

sprite_group_000B66 [
  sprite-group < #10, #10, #46, #05, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #0C, [
    sprite-part < #01, #08, #08, #1E, #1D, #$04E2 >   ;00
    sprite-part < #01, #0A, #06, #00, #3B, #$083E >   ;01
    sprite-part < #01, #0A, #06, #10, #2B, #$085E >   ;02
    sprite-part < #01, #00, #10, #02, #39, #$04A0 >   ;03
    sprite-part < #01, #10, #00, #02, #39, #$44A0 >   ;04
    sprite-part < #01, #00, #10, #12, #29, #$04C0 >   ;05
    sprite-part < #01, #10, #00, #12, #29, #$44C0 >   ;06
    sprite-part < #01, #00, #10, #22, #19, #$04D6 >   ;07
    sprite-part < #01, #10, #00, #22, #19, #$44D6 >   ;08
    sprite-part < #01, #00, #10, #2A, #11, #$04E6 >   ;09
    sprite-part < #01, #10, #00, #2A, #11, #$44E6 >   ;0A
    sprite-part < #01, #08, #08, #3B, #00, #$0042 >   ;0B
  ] >
]

sprite_group_000BC7 [
  sprite-group < #27, #28, #30, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #18, [
    sprite-part < #01, #18, #27, #18, #08, #$0EDE >   ;00
    sprite-part < #01, #27, #18, #18, #08, #$4EDE >   ;01
    sprite-part < #01, #08, #37, #18, #08, #$0EDC >   ;02
    sprite-part < #01, #37, #08, #18, #08, #$4EDC >   ;03
    sprite-part < #01, #08, #37, #08, #18, #$0EBC >   ;04
    sprite-part < #01, #37, #08, #08, #18, #$4EBC >   ;05
    sprite-part < #00, #18, #2F, #28, #00, #$0ED8 >   ;06
    sprite-part < #00, #2F, #18, #28, #00, #$4ED8 >   ;07
    sprite-part < #00, #20, #27, #28, #00, #$0ED9 >   ;08
    sprite-part < #00, #27, #20, #28, #00, #$4ED9 >   ;09
    sprite-part < #00, #00, #47, #10, #18, #$0ED5 >   ;0A
    sprite-part < #00, #47, #00, #10, #18, #$4ED5 >   ;0B
    sprite-part < #00, #00, #47, #08, #20, #$0ED4 >   ;0C
    sprite-part < #00, #47, #00, #08, #20, #$4ED4 >   ;0D
    sprite-part < #00, #00, #47, #20, #08, #$0E64 >   ;0E
    sprite-part < #00, #47, #00, #20, #08, #$4E64 >   ;0F
    sprite-part < #00, #00, #47, #18, #10, #$0E54 >   ;10
    sprite-part < #00, #47, #00, #18, #10, #$4E54 >   ;11
    sprite-part < #01, #18, #27, #08, #18, #$0EBE >   ;12
    sprite-part < #01, #18, #27, #10, #10, #$00A2 >   ;13
    sprite-part < #01, #27, #18, #08, #18, #$4EBE >   ;14
    sprite-part < #01, #27, #18, #0F, #11, #$C082 >   ;15
    sprite-part < #01, #18, #27, #00, #20, #$0082 >   ;16
    sprite-part < #01, #27, #18, #00, #20, #$C0A2 >   ;17
  ] >
]

sprite_group_000C7C [
  sprite-group < #27, #28, #30, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #18, [
    sprite-part < #01, #08, #37, #18, #08, #$0EDC >   ;00
    sprite-part < #01, #37, #08, #18, #08, #$4EDC >   ;01
    sprite-part < #01, #08, #37, #08, #18, #$0EBC >   ;02
    sprite-part < #01, #37, #08, #08, #18, #$4EBC >   ;03
    sprite-part < #00, #18, #2F, #28, #00, #$0ED8 >   ;04
    sprite-part < #00, #2F, #18, #28, #00, #$4ED8 >   ;05
    sprite-part < #00, #20, #27, #28, #00, #$0ED9 >   ;06
    sprite-part < #00, #27, #20, #28, #00, #$4ED9 >   ;07
    sprite-part < #00, #00, #47, #10, #18, #$0ED5 >   ;08
    sprite-part < #00, #47, #00, #10, #18, #$4ED5 >   ;09
    sprite-part < #00, #00, #47, #08, #20, #$0ED4 >   ;0A
    sprite-part < #00, #47, #00, #08, #20, #$4ED4 >   ;0B
    sprite-part < #00, #00, #47, #20, #08, #$0E64 >   ;0C
    sprite-part < #00, #47, #00, #20, #08, #$4E64 >   ;0D
    sprite-part < #00, #00, #47, #18, #10, #$0E54 >   ;0E
    sprite-part < #00, #47, #00, #18, #10, #$4E54 >   ;0F
    sprite-part < #01, #27, #18, #18, #08, #$4EDE >   ;10
    sprite-part < #01, #18, #27, #08, #18, #$0EBE >   ;11
    sprite-part < #01, #18, #27, #00, #20, #$0094 >   ;12
    sprite-part < #01, #27, #18, #08, #18, #$4EBE >   ;13
    sprite-part < #01, #27, #18, #0F, #11, #$C094 >   ;14
    sprite-part < #01, #27, #18, #00, #20, #$C0B4 >   ;15
    sprite-part < #01, #18, #27, #18, #08, #$0EDE >   ;16
    sprite-part < #01, #18, #27, #10, #10, #$00B4 >   ;17
  ] >
]

sprite_group_000D31 [
  sprite-group < #27, #28, #30, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #18, [
    sprite-part < #01, #08, #37, #18, #08, #$0EDC >   ;00
    sprite-part < #01, #37, #08, #18, #08, #$4EDC >   ;01
    sprite-part < #01, #08, #37, #08, #18, #$0EBC >   ;02
    sprite-part < #01, #37, #08, #08, #18, #$4EBC >   ;03
    sprite-part < #00, #18, #2F, #28, #00, #$0ED8 >   ;04
    sprite-part < #00, #2F, #18, #28, #00, #$4ED8 >   ;05
    sprite-part < #00, #20, #27, #28, #00, #$0ED9 >   ;06
    sprite-part < #00, #27, #20, #28, #00, #$4ED9 >   ;07
    sprite-part < #00, #00, #47, #10, #18, #$0ED5 >   ;08
    sprite-part < #00, #47, #00, #10, #18, #$4ED5 >   ;09
    sprite-part < #00, #00, #47, #08, #20, #$0ED4 >   ;0A
    sprite-part < #00, #47, #00, #08, #20, #$4ED4 >   ;0B
    sprite-part < #00, #00, #47, #20, #08, #$0E64 >   ;0C
    sprite-part < #00, #47, #00, #20, #08, #$4E64 >   ;0D
    sprite-part < #00, #00, #47, #18, #10, #$0E54 >   ;0E
    sprite-part < #00, #47, #00, #18, #10, #$4E54 >   ;0F
    sprite-part < #01, #27, #18, #18, #08, #$4EDE >   ;10
    sprite-part < #01, #18, #27, #08, #18, #$0EBE >   ;11
    sprite-part < #01, #18, #27, #00, #20, #$0096 >   ;12
    sprite-part < #01, #27, #18, #08, #18, #$4EBE >   ;13
    sprite-part < #01, #27, #18, #00, #20, #$C0B6 >   ;14
    sprite-part < #01, #27, #18, #0F, #11, #$C096 >   ;15
    sprite-part < #01, #18, #27, #18, #08, #$0EDE >   ;16
    sprite-part < #01, #18, #27, #10, #10, #$00B6 >   ;17
  ] >
]

sprite_group_000DE6 [
  sprite-group < #27, #28, #30, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #1B, [
    sprite-part < #01, #0F, #30, #00, #20, #$0098 >   ;00
    sprite-part < #01, #38, #07, #12, #0E, #$0A74 >   ;01
    sprite-part < #01, #27, #18, #19, #07, #$0678 >   ;02
    sprite-part < #01, #18, #27, #18, #08, #$0EDE >   ;03
    sprite-part < #01, #27, #18, #18, #08, #$4EDE >   ;04
    sprite-part < #01, #08, #37, #18, #08, #$0EDC >   ;05
    sprite-part < #01, #37, #08, #18, #08, #$4EDC >   ;06
    sprite-part < #01, #08, #37, #08, #18, #$0EBC >   ;07
    sprite-part < #01, #37, #08, #08, #18, #$4EBC >   ;08
    sprite-part < #00, #18, #2F, #28, #00, #$0ED8 >   ;09
    sprite-part < #00, #2F, #18, #28, #00, #$4ED8 >   ;0A
    sprite-part < #00, #20, #27, #28, #00, #$0ED9 >   ;0B
    sprite-part < #00, #27, #20, #28, #00, #$4ED9 >   ;0C
    sprite-part < #00, #00, #47, #10, #18, #$0ED5 >   ;0D
    sprite-part < #00, #47, #00, #10, #18, #$4ED5 >   ;0E
    sprite-part < #00, #00, #47, #08, #20, #$0ED4 >   ;0F
    sprite-part < #00, #47, #00, #08, #20, #$4ED4 >   ;10
    sprite-part < #00, #00, #47, #20, #08, #$0E64 >   ;11
    sprite-part < #00, #47, #00, #20, #08, #$4E64 >   ;12
    sprite-part < #00, #00, #47, #18, #10, #$0E54 >   ;13
    sprite-part < #00, #47, #00, #18, #10, #$4E54 >   ;14
    sprite-part < #01, #18, #27, #08, #18, #$0EBE >   ;15
    sprite-part < #01, #18, #27, #10, #10, #$00A2 >   ;16
    sprite-part < #01, #27, #18, #08, #18, #$4EBE >   ;17
    sprite-part < #01, #27, #18, #0F, #11, #$C082 >   ;18
    sprite-part < #01, #18, #27, #00, #20, #$0082 >   ;19
    sprite-part < #01, #27, #18, #00, #20, #$C0A2 >   ;1A
  ] >
]

sprite_group_000EB0 [
  sprite-group < #27, #28, #30, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #1B, [
    sprite-part < #01, #38, #07, #12, #0E, #$0A76 >   ;00
    sprite-part < #01, #0F, #30, #00, #20, #$009A >   ;01
    sprite-part < #01, #08, #37, #18, #08, #$0EDC >   ;02
    sprite-part < #01, #37, #08, #18, #08, #$4EDC >   ;03
    sprite-part < #01, #08, #37, #08, #18, #$0EBC >   ;04
    sprite-part < #01, #37, #08, #08, #18, #$4EBC >   ;05
    sprite-part < #00, #18, #2F, #28, #00, #$0ED8 >   ;06
    sprite-part < #01, #27, #18, #19, #07, #$067A >   ;07
    sprite-part < #00, #2F, #18, #28, #00, #$4ED8 >   ;08
    sprite-part < #00, #20, #27, #28, #00, #$0ED9 >   ;09
    sprite-part < #00, #27, #20, #28, #00, #$4ED9 >   ;0A
    sprite-part < #00, #00, #47, #10, #18, #$0ED5 >   ;0B
    sprite-part < #00, #47, #00, #10, #18, #$4ED5 >   ;0C
    sprite-part < #00, #00, #47, #08, #20, #$0ED4 >   ;0D
    sprite-part < #00, #47, #00, #08, #20, #$4ED4 >   ;0E
    sprite-part < #00, #00, #47, #20, #08, #$0E64 >   ;0F
    sprite-part < #00, #00, #47, #18, #10, #$0E54 >   ;10
    sprite-part < #00, #47, #00, #20, #08, #$4E64 >   ;11
    sprite-part < #00, #47, #00, #18, #10, #$4E54 >   ;12
    sprite-part < #01, #27, #18, #18, #08, #$4EDE >   ;13
    sprite-part < #01, #18, #27, #08, #18, #$0EBE >   ;14
    sprite-part < #01, #18, #27, #00, #20, #$0094 >   ;15
    sprite-part < #01, #27, #18, #08, #18, #$4EBE >   ;16
    sprite-part < #01, #27, #18, #0F, #11, #$C094 >   ;17
    sprite-part < #01, #27, #18, #00, #20, #$C0B4 >   ;18
    sprite-part < #01, #18, #27, #18, #08, #$0EDE >   ;19
    sprite-part < #01, #18, #27, #10, #10, #$00B4 >   ;1A
  ] >
]

sprite_group_000F7A [
  sprite-group < #27, #28, #30, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #1B, [
    sprite-part < #01, #0F, #30, #00, #20, #$0098 >   ;00
    sprite-part < #01, #38, #07, #12, #0E, #$0A74 >   ;01
    sprite-part < #01, #27, #18, #19, #07, #$0678 >   ;02
    sprite-part < #01, #08, #37, #18, #08, #$0EDC >   ;03
    sprite-part < #01, #37, #08, #18, #08, #$4EDC >   ;04
    sprite-part < #01, #08, #37, #08, #18, #$0EBC >   ;05
    sprite-part < #01, #37, #08, #08, #18, #$4EBC >   ;06
    sprite-part < #00, #18, #2F, #28, #00, #$0ED8 >   ;07
    sprite-part < #00, #2F, #18, #28, #00, #$4ED8 >   ;08
    sprite-part < #00, #20, #27, #28, #00, #$0ED9 >   ;09
    sprite-part < #00, #27, #20, #28, #00, #$4ED9 >   ;0A
    sprite-part < #00, #00, #47, #10, #18, #$0ED5 >   ;0B
    sprite-part < #00, #47, #00, #10, #18, #$4ED5 >   ;0C
    sprite-part < #00, #00, #47, #08, #20, #$0ED4 >   ;0D
    sprite-part < #00, #47, #00, #08, #20, #$4ED4 >   ;0E
    sprite-part < #00, #00, #47, #20, #08, #$0E64 >   ;0F
    sprite-part < #00, #47, #00, #20, #08, #$4E64 >   ;10
    sprite-part < #00, #00, #47, #18, #10, #$0E54 >   ;11
    sprite-part < #00, #47, #00, #18, #10, #$4E54 >   ;12
    sprite-part < #01, #27, #18, #18, #08, #$4EDE >   ;13
    sprite-part < #01, #18, #27, #08, #18, #$0EBE >   ;14
    sprite-part < #01, #18, #27, #00, #20, #$0096 >   ;15
    sprite-part < #01, #27, #18, #08, #18, #$4EBE >   ;16
    sprite-part < #01, #27, #18, #00, #20, #$C0B6 >   ;17
    sprite-part < #01, #27, #18, #0F, #11, #$C096 >   ;18
    sprite-part < #01, #18, #27, #18, #08, #$0EDE >   ;19
    sprite-part < #01, #18, #27, #10, #10, #$00B6 >   ;1A
  ] >
]

sprite_group_001044 [
  sprite-group < #20, #20, #38, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #0E, [
    sprite-part < #00, #18, #20, #32, #06, #$00BA >   ;00
    sprite-part < #00, #1F, #19, #32, #06, #$40BA >   ;01
    sprite-part < #01, #18, #18, #20, #10, #$003C >   ;02
    sprite-part < #01, #10, #20, #00, #30, #$4AEA >   ;03
    sprite-part < #01, #20, #10, #00, #30, #$0AEA >   ;04
    sprite-part < #01, #00, #30, #00, #30, #$0AEA >   ;05
    sprite-part < #01, #30, #00, #00, #30, #$4AEA >   ;06
    sprite-part < #01, #0E, #22, #0B, #25, #$0EB8 >   ;07
    sprite-part < #01, #12, #1E, #1B, #15, #$0EB8 >   ;08
    sprite-part < #01, #22, #0E, #0B, #25, #$4EB8 >   ;09
    sprite-part < #01, #1E, #12, #1B, #15, #$4EB8 >   ;0A
    sprite-part < #00, #16, #22, #2A, #0E, #$0EB8 >   ;0B
    sprite-part < #00, #22, #16, #2A, #0E, #$4EB8 >   ;0C
    sprite-part < #01, #18, #18, #30, #00, #$005C >   ;0D
  ] >
]

sprite_group_0010B3 [
  sprite-group < #20, #20, #39, #07, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #0E, [
    sprite-part < #00, #18, #20, #32, #06, #$00BA >   ;00
    sprite-part < #00, #1F, #19, #32, #06, #$40BA >   ;01
    sprite-part < #01, #18, #18, #20, #10, #$003C >   ;02
    sprite-part < #01, #10, #20, #00, #30, #$4A80 >   ;03
    sprite-part < #01, #00, #30, #00, #30, #$0A80 >   ;04
    sprite-part < #01, #20, #10, #00, #30, #$0A80 >   ;05
    sprite-part < #01, #30, #00, #00, #30, #$4A80 >   ;06
    sprite-part < #01, #0E, #22, #0B, #25, #$0EB8 >   ;07
    sprite-part < #01, #12, #1E, #1B, #15, #$0EB8 >   ;08
    sprite-part < #01, #1E, #12, #1B, #15, #$4EB8 >   ;09
    sprite-part < #01, #22, #0E, #0B, #25, #$4EB8 >   ;0A
    sprite-part < #00, #16, #22, #2A, #0E, #$0EB8 >   ;0B
    sprite-part < #01, #18, #18, #30, #00, #$005C >   ;0C
    sprite-part < #00, #22, #16, #2A, #0E, #$4EB8 >   ;0D
  ] >
]

sprite_group_001122 [
  sprite-group < #18, #18, #3A, #06, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #16, [
    sprite-part < #00, #08, #20, #08, #30, #$4AAD >   ;00
    sprite-part < #00, #20, #08, #08, #30, #$0AAD >   ;01
    sprite-part < #00, #00, #28, #08, #30, #$0AAD >   ;02
    sprite-part < #00, #10, #18, #32, #06, #$00BA >   ;03
    sprite-part < #00, #17, #11, #32, #06, #$40BA >   ;04
    sprite-part < #01, #10, #10, #30, #00, #$005C >   ;05
    sprite-part < #01, #10, #10, #20, #10, #$003C >   ;06
    sprite-part < #00, #00, #28, #10, #28, #$0AFC >   ;07
    sprite-part < #00, #08, #20, #10, #28, #$4AFC >   ;08
    sprite-part < #00, #20, #08, #10, #28, #$0AFC >   ;09
    sprite-part < #00, #28, #00, #10, #28, #$4AFC >   ;0A
    sprite-part < #01, #1A, #06, #0B, #25, #$4EB8 >   ;0B
    sprite-part < #01, #06, #1A, #0B, #25, #$0EB8 >   ;0C
    sprite-part < #01, #0A, #16, #1B, #15, #$0EB8 >   ;0D
    sprite-part < #01, #16, #0A, #1B, #15, #$4EB8 >   ;0E
    sprite-part < #00, #0E, #1A, #2A, #0E, #$0EB8 >   ;0F
    sprite-part < #00, #1A, #0E, #2A, #0E, #$4EB8 >   ;10
    sprite-part < #00, #28, #00, #08, #30, #$4AAD >   ;11
    sprite-part < #00, #00, #28, #00, #38, #$0AAC >   ;12
    sprite-part < #00, #08, #20, #00, #38, #$4AAC >   ;13
    sprite-part < #00, #20, #08, #00, #38, #$0AAC >   ;14
    sprite-part < #00, #28, #00, #00, #38, #$4AAC >   ;15
  ] >
]

sprite_group_0011C9 [
  sprite-group < #20, #20, #39, #07, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #0E, [
    sprite-part < #00, #18, #20, #32, #06, #$00BA >   ;00
    sprite-part < #00, #1F, #19, #32, #06, #$40BA >   ;01
    sprite-part < #01, #18, #18, #20, #10, #$003C >   ;02
    sprite-part < #01, #18, #18, #30, #00, #$005C >   ;03
    sprite-part < #01, #10, #20, #00, #30, #$4ACA >   ;04
    sprite-part < #01, #00, #30, #00, #30, #$0ACA >   ;05
    sprite-part < #01, #20, #10, #00, #30, #$0ACA >   ;06
    sprite-part < #01, #30, #00, #00, #30, #$4ACA >   ;07
    sprite-part < #01, #0E, #22, #0B, #25, #$0EB8 >   ;08
    sprite-part < #01, #22, #0E, #0B, #25, #$4EB8 >   ;09
    sprite-part < #01, #1E, #12, #1B, #15, #$4EB8 >   ;0A
    sprite-part < #01, #12, #1E, #1B, #15, #$0EB8 >   ;0B
    sprite-part < #00, #16, #22, #2A, #0E, #$0EB8 >   ;0C
    sprite-part < #00, #22, #16, #2A, #0E, #$4EB8 >   ;0D
  ] >
]