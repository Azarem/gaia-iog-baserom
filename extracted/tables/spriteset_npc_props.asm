; Sprite set of small scene props (Bank 0E, 973312-974144, 832 bytes): the town door, a bone pile, spirits, a sign, flames, a campfire and three single-frame props. The old note ('town furniture, signs, chests, and decorative elements') was too broad: no chest uses it (chests are map tiles drawn by warps_interaction), and there is no furniture.
; 
; Structure (format in the spriteset_freedan block note): 11 animations, 20 sprite groups. 22 B pointer table + 102 B frame lists (8 one-frame lists of 6 B, 3 four-frame lists of 18 B) + 708 B groups.
; 
; | Index | Set | Frames (hold) | Users (actors selecting it) |
; |-------|-----|---------------|-----------------------------|
; | $00 | npc_props_00_door_open | 1 | town_door, open frame (1 sub-sprite) |
; | $01 | npc_props_01_door_closed | 1 | town_door closed frame (6 sub-sprites); fr32_guide |
; | $02 | npc_props_02_bones | 1 | bone pile: gs2B_bones, nvAC_bones, eu9D_bones; also btDE_olman and pyCD_jackal |
; | $03 | npc_props_03 | 1 | no actor |
; | $04 | npc_props_04_spirit | 4 (5 each) | spirits: awBF_spirit_guide, btDF_spirits, btE3_dao_travel_spirit, btE4_olman, daC3_babel_travel_spirit, ec10_dp_hint_spirit, mu66_rama_spirits, sE5_epilogue, btDE_olman |
; | $05 | npc_props_05_sign | 1 | av69_signs |
; | $06 | npc_props_06_flame | 4 (3 each) | flames: av6B_flame, ec0A_torch1, ec0A_torch2 |
; | $07 | npc_props_07_street_prop | 1 | freejia_street_prop |
; | $08 | npc_props_08_campfire | 4 (3 each) | st68_campfire |
; | $09 | npc_props_09 | 1 | no actor |
; | $0A | npc_props_0A_kara | 1 | btE4_kara |
; 
; Users were found by searching for SetMetasprite ( @spriteset_npc_props ) and reading the Stage* operand that follows it (E2); the images were not viewed, so the descriptions of $02, $05, $07 and $0A come from the actor names (OQ-I068-1). Animations $03 and $09 have no user (OQ-I068-2).
---------------------------------------------

?BANK 0E

---------------------------------------------

; 11 pointers to the animation frame lists ($00-$0A); see the block note for the user of each index.

spriteset_npc_props [
  &npc_props_00_door_open   ;00
  &npc_props_01_door_closed   ;01
  &npc_props_02_bones   ;02
  &npc_props_03   ;03
  &npc_props_04_spirit   ;04
  &npc_props_05_sign   ;05
  &npc_props_06_flame   ;06
  &npc_props_07_street_prop   ;07
  &npc_props_08_campfire   ;08
  &npc_props_09   ;09
  &npc_props_0A_kara   ;0A
]

npc_props_00_door_open [
  sprite-set < #$0000, &sprite_group_0EDA7C >
]

npc_props_01_door_closed [
  sprite-set < #$0000, &sprite_group_0EDA90 >
]

npc_props_02_bones [
  sprite-set < #$0000, &sprite_group_0EDAC7 >
]

---------------------------------------------
; Animation $03: no actor selects it (OQ-I068-2).

npc_props_03 [
  sprite-set < #$0000, &sprite_group_0EDAF7 >
]

npc_props_04_spirit [
  sprite-set < #$0005, &sprite_group_0EDB0B >   ;00
  sprite-set < #$0005, &sprite_group_0EDB3B >   ;01
  sprite-set < #$0005, &sprite_group_0EDB6B >   ;02
  sprite-set < #$0005, &sprite_group_0EDB9B >   ;03
]

npc_props_05_sign [
  sprite-set < #$0000, &sprite_group_0EDBCB >
]

npc_props_06_flame [
  sprite-set < #$0003, &sprite_group_0EDBE6 >   ;00
  sprite-set < #$0003, &sprite_group_0EDBFA >   ;01
  sprite-set < #$0003, &sprite_group_0EDC0E >   ;02
  sprite-set < #$0003, &sprite_group_0EDC29 >   ;03
]

npc_props_07_street_prop [
  sprite-set < #$0000, &sprite_group_0EDC44 >
]

npc_props_08_campfire [
  sprite-set < #$0003, &sprite_group_0EDC6D >   ;00
  sprite-set < #$0003, &sprite_group_0EDC88 >   ;01
  sprite-set < #$0003, &sprite_group_0EDCA3 >   ;02
  sprite-set < #$0003, &sprite_group_0EDCC5 >   ;03
]

---------------------------------------------
; Animation $09: no actor selects it (OQ-I068-2).

npc_props_09 [
  sprite-set < #$0000, &sprite_group_0EDCE7 >
]

npc_props_0A_kara [
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