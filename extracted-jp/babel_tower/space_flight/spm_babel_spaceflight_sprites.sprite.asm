---------------------------------------------

sprite_set_list_000000 [
  &sprite_set_000008   ;00
  &sprite_set_00000E   ;01
  &sprite_set_000014   ;02
  &sprite_set_00001A   ;03
]

sprite_set_000008 [
  sprite-set < #$0000, &sprite_group_000020 >
]

sprite_set_00000E [
  sprite-set < #$0000, &sprite_group_000057 >
]

sprite_set_000014 [
  sprite-set < #$0000, &sprite_group_00008E >
]

sprite_set_00001A [
  sprite-set < #$0000, &sprite_group_0000B7 >
]

sprite_group_000020 [
  sprite-group < #10, #10, #18, #18, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #00, #10, #00, #20, #$0700 >   ;00
    sprite-part < #01, #00, #10, #10, #10, #$0720 >   ;01
    sprite-part < #01, #00, #10, #20, #00, #$0740 >   ;02
    sprite-part < #01, #10, #00, #00, #20, #$0702 >   ;03
    sprite-part < #01, #10, #00, #10, #10, #$0722 >   ;04
    sprite-part < #01, #10, #00, #20, #00, #$0742 >   ;05
  ] >
]

sprite_group_000057 [
  sprite-group < #10, #10, #18, #18, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #00, #10, #00, #20, #$0704 >   ;00
    sprite-part < #01, #00, #10, #10, #10, #$0724 >   ;01
    sprite-part < #01, #00, #10, #20, #00, #$0744 >   ;02
    sprite-part < #01, #10, #00, #00, #20, #$0706 >   ;03
    sprite-part < #01, #10, #00, #10, #10, #$0726 >   ;04
    sprite-part < #01, #10, #00, #20, #00, #$0746 >   ;05
  ] >
]

sprite_group_00008E [
  sprite-group < #10, #10, #10, #10, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #04, [
    sprite-part < #01, #00, #10, #00, #10, #$0708 >   ;00
    sprite-part < #01, #10, #00, #00, #10, #$070A >   ;01
    sprite-part < #01, #00, #10, #10, #00, #$0728 >   ;02
    sprite-part < #01, #10, #00, #10, #00, #$072A >   ;03
  ] >
]

sprite_group_0000B7 [
  sprite-group < #08, #18, #10, #10, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #04, [
    sprite-part < #01, #00, #10, #00, #10, #$070C >   ;00
    sprite-part < #01, #10, #00, #00, #10, #$070E >   ;01
    sprite-part < #01, #00, #10, #10, #00, #$072C >   ;02
    sprite-part < #01, #10, #00, #10, #00, #$072E >   ;03
  ] >
]