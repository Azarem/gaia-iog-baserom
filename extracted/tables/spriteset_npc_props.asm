; Spriteset for NPC props and interactive objects.
; 
; Town furniture, signs, chests, and decorative elements used across multiple scene types.
---------------------------------------------

?BANK 0E

---------------------------------------------

spriteset_npc_props [
  &sprite_set_0EDA16   ;00
  &sprite_set_0EDA1C   ;01
  &sprite_set_0EDA22   ;02
  &sprite_set_0EDA28   ;03
  &sprite_set_0EDA2E   ;04
  &sprite_set_0EDA40   ;05
  &sprite_set_0EDA46   ;06
  &sprite_set_0EDA58   ;07
  &sprite_set_0EDA5E   ;08
  &sprite_set_0EDA70   ;09
  &sprite_set_0EDA76   ;0A
]

sprite_set_0EDA16 [
  sprite-set < #$0000, &sprite_group_0EDA7C >
]

sprite_set_0EDA1C [
  sprite-set < #$0000, &sprite_group_0EDA90 >
]

sprite_set_0EDA22 [
  sprite-set < #$0000, &sprite_group_0EDAC7 >
]

sprite_set_0EDA28 [
  sprite-set < #$0000, &sprite_group_0EDAF7 >
]

sprite_set_0EDA2E [
  sprite-set < #$0005, &sprite_group_0EDB0B >   ;00
  sprite-set < #$0005, &sprite_group_0EDB3B >   ;01
  sprite-set < #$0005, &sprite_group_0EDB6B >   ;02
  sprite-set < #$0005, &sprite_group_0EDB9B >   ;03
]

sprite_set_0EDA40 [
  sprite-set < #$0000, &sprite_group_0EDBCB >
]

sprite_set_0EDA46 [
  sprite-set < #$0003, &sprite_group_0EDBE6 >   ;00
  sprite-set < #$0003, &sprite_group_0EDBFA >   ;01
  sprite-set < #$0003, &sprite_group_0EDC0E >   ;02
  sprite-set < #$0003, &sprite_group_0EDC29 >   ;03
]

sprite_set_0EDA58 [
  sprite-set < #$0000, &sprite_group_0EDC44 >
]

sprite_set_0EDA5E [
  sprite-set < #$0003, &sprite_group_0EDC6D >   ;00
  sprite-set < #$0003, &sprite_group_0EDC88 >   ;01
  sprite-set < #$0003, &sprite_group_0EDCA3 >   ;02
  sprite-set < #$0003, &sprite_group_0EDCC5 >   ;03
]

sprite_set_0EDA70 [
  sprite-set < #$0000, &sprite_group_0EDCE7 >
]

sprite_set_0EDA76 [
  sprite-set < #$0000, &sprite_group_0EDCFB >
]

sprite_group_0EDA7C [
  sprite-group < #04, #04, #08, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #00, #00, #00, #00, #00, #$02AE >
  ] >
]

sprite_group_0EDA90 [
  sprite-group < #10, #10, #28, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #00, #10, #18, #00, #$0442 >   ;00
    sprite-part < #01, #10, #00, #18, #00, #$4442 >   ;01
    sprite-part < #01, #00, #10, #00, #18, #$0440 >   ;02
    sprite-part < #01, #10, #00, #00, #18, #$4440 >   ;03
    sprite-part < #01, #00, #10, #0B, #0D, #$0440 >   ;04
    sprite-part < #01, #10, #00, #0B, #0D, #$4440 >   ;05
  ] >
]

sprite_group_0EDAC7 [
  sprite-group < #0A, #0B, #12, #03, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #05, [
    sprite-part < #00, #00, #0D, #02, #0B, #$0460 >   ;00
    sprite-part < #00, #00, #0D, #0A, #03, #$0470 >   ;01
    sprite-part < #00, #07, #06, #0D, #00, #$0461 >   ;02
    sprite-part < #00, #06, #07, #02, #0B, #$0471 >   ;03
    sprite-part < #01, #05, #00, #00, #05, #$0462 >   ;04
  ] >
]

sprite_group_0EDAF7 [
  sprite-group < #08, #08, #10, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #01, #00, #00, #00, #00, #$0264 >
  ] >
]

sprite_group_0EDB0B [
  sprite-group < #08, #08, #18, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #05, [
    sprite-part < #00, #00, #08, #10, #00, #$0254 >   ;00
    sprite-part < #00, #08, #00, #10, #00, #$4254 >   ;01
    sprite-part < #00, #00, #08, #08, #08, #$0246 >   ;02
    sprite-part < #00, #08, #00, #08, #08, #$0247 >   ;03
    sprite-part < #00, #04, #04, #00, #10, #$0245 >   ;04
  ] >
]

sprite_group_0EDB3B [
  sprite-group < #08, #08, #19, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #05, [
    sprite-part < #00, #00, #08, #10, #01, #$0254 >   ;00
    sprite-part < #00, #08, #00, #10, #01, #$4254 >   ;01
    sprite-part < #00, #00, #08, #08, #09, #$0249 >   ;02
    sprite-part < #00, #08, #00, #08, #09, #$024A >   ;03
    sprite-part < #00, #04, #04, #00, #11, #$0248 >   ;04
  ] >
]

sprite_group_0EDB6B [
  sprite-group < #08, #08, #1A, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #05, [
    sprite-part < #00, #00, #08, #10, #02, #$0254 >   ;00
    sprite-part < #00, #08, #00, #10, #02, #$4254 >   ;01
    sprite-part < #00, #00, #08, #08, #0A, #$0256 >   ;02
    sprite-part < #00, #08, #00, #08, #0A, #$0257 >   ;03
    sprite-part < #00, #05, #03, #00, #12, #$0255 >   ;04
  ] >
]

sprite_group_0EDB9B [
  sprite-group < #08, #08, #19, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #05, [
    sprite-part < #00, #00, #08, #10, #01, #$0254 >   ;00
    sprite-part < #00, #08, #00, #10, #01, #$4254 >   ;01
    sprite-part < #00, #00, #08, #08, #09, #$0259 >   ;02
    sprite-part < #00, #08, #00, #08, #09, #$025A >   ;03
    sprite-part < #00, #02, #06, #00, #11, #$0258 >   ;04
  ] >
]

sprite_group_0EDBCB [
  sprite-group < #08, #08, #18, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #02, [
    sprite-part < #01, #00, #00, #00, #08, #$0466 >   ;00
    sprite-part < #00, #03, #05, #10, #00, #$0468 >   ;01
  ] >
]

sprite_group_0EDBE6 [
  sprite-group < #04, #04, #08, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #00, #00, #00, #00, #00, #$024B >
  ] >
]

sprite_group_0EDBFA [
  sprite-group < #04, #04, #08, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #00, #00, #00, #00, #00, #$025B >
  ] >
]

sprite_group_0EDC0E [
  sprite-group < #04, #04, #10, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #02, [
    sprite-part < #00, #00, #00, #08, #00, #$025C >   ;00
    sprite-part < #00, #00, #00, #00, #08, #$024C >   ;01
  ] >
]

sprite_group_0EDC29 [
  sprite-group < #04, #04, #10, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #02, [
    sprite-part < #00, #00, #00, #08, #00, #$025D >   ;00
    sprite-part < #00, #00, #00, #00, #08, #$024D >   ;01
  ] >
]

sprite_group_0EDC44 [
  sprite-group < #10, #10, #24, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #04, [
    sprite-part < #01, #10, #00, #00, #14, #$444E >   ;00
    sprite-part < #01, #00, #10, #00, #14, #$044E >   ;01
    sprite-part < #01, #00, #10, #10, #04, #$046E >   ;02
    sprite-part < #01, #10, #00, #10, #04, #$446E >   ;03
  ] >
]

sprite_group_0EDC6D [
  sprite-group < #08, #08, #10, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #02, [
    sprite-part < #00, #04, #04, #00, #08, #$024B >   ;00
    sprite-part < #01, #00, #00, #00, #00, #$046C >   ;01
  ] >
]

sprite_group_0EDC88 [
  sprite-group < #08, #08, #10, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #02, [
    sprite-part < #00, #04, #04, #00, #08, #$025B >   ;00
    sprite-part < #01, #00, #00, #00, #00, #$046C >   ;01
  ] >
]

sprite_group_0EDCA3 [
  sprite-group < #08, #08, #18, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #03, [
    sprite-part < #00, #04, #04, #08, #08, #$025C >   ;00
    sprite-part < #01, #00, #00, #08, #00, #$046C >   ;01
    sprite-part < #00, #04, #04, #00, #10, #$024C >   ;02
  ] >
]

sprite_group_0EDCC5 [
  sprite-group < #08, #08, #18, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #03, [
    sprite-part < #00, #04, #04, #08, #08, #$025D >   ;00
    sprite-part < #01, #00, #00, #08, #00, #$046C >   ;01
    sprite-part < #00, #04, #04, #00, #10, #$024D >   ;02
  ] >
]

sprite_group_0EDCE7 [
  sprite-group < #08, #08, #10, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #01, #00, #00, #00, #00, #$026A >
  ] >
]

sprite_group_0EDCFB [
  sprite-group < #08, #08, #20, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #08, [
    sprite-part < #00, #00, #08, #00, #18, #$0244 >   ;00
    sprite-part < #00, #08, #00, #00, #18, #$4244 >   ;01
    sprite-part < #00, #00, #08, #08, #10, #$0278 >   ;02
    sprite-part < #00, #08, #00, #08, #10, #$4278 >   ;03
    sprite-part < #00, #00, #08, #10, #08, #$0269 >   ;04
    sprite-part < #00, #08, #00, #10, #08, #$4269 >   ;05
    sprite-part < #00, #00, #08, #18, #00, #$0279 >   ;06
    sprite-part < #00, #08, #00, #18, #00, #$4279 >   ;07
  ] >
]