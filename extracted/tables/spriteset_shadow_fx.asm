; Sprite set of body_table row $07 (Bank 17, 1552384-1553318, 934 bytes; tile graphics shad_fx_1CA000). The old note ('Shadow-specific visual effects', 'attack trail sprites and liquify transformation overlays') is not supported: no frame list of this set is staged by any extracted script, because nothing selects body row $07 (SetPlayerSpriteDirect #07 does not occur; the only rows picked by number are $04, $05, $06 and $08). The word 'liquify' appears only in the old header text; no code or table supports it. GetPlayerFacingDirection would index FacingFormOffsetTable with row - 4 = 3 if row $07 were ever selected (OQ-I069-1).
; 
; Structure (format in the spriteset_freedan block note): 14 animations, 16 groups of about 5 sub-sprites each (82 in total). 28 B pointer table + 124 B frame lists + 782 B groups = 934 bytes.
; 
; | Index | Set | Frames (hold) | Group |
; |-------|-----|---------------|-------|
; | $00 | shadow_fx_00 | 4 (9, 9, 9, 1) | 17B098, 17B0CF, 17B0FF, 17B12F |
; | $01-$03 | shadow_fx_01, 17B034, 17B03A | 1 (3) each | the same group 17B15F |
; | $04 | shadow_fx_04 | 8 (3, 3, 3, 6, 4, 3, 2, 0) | 17B18F ... 17B2D1 |
; | $05, $07, $08, $0A, $0B, $0D | shadow_fx_05, 17B06E, 17B074, 17B080, 17B086, 17B092 | 1 (31) each | the same group 17B098 (also frame 0 of $00) |
; | $06, $09, $0C | shadow_fx_06, 17B07A, 17B08C | 1 (7) each | 17B376, 17B308, 17B33F |
; 
; Twelve of the 14 animations are a single frame, and six of those are the identical 32-tick hold of group 17B098 (hold 31 + 1), which looks like placeholder entries (OQ-I069-1). The art was not viewed.
---------------------------------------------

?BANK 17

---------------------------------------------

; 14 pointers to the animation frame lists ($00-$0D). Nothing stages any of them (see the block note).

spriteset_shadow_fx [
  &shadow_fx_00   ;00
  &shadow_fx_01   ;01
  &shadow_fx_02   ;02
  &shadow_fx_03   ;03
  &shadow_fx_04   ;04
  &shadow_fx_05   ;05
  &shadow_fx_06   ;06
  &shadow_fx_07   ;07
  &shadow_fx_08   ;08
  &shadow_fx_09   ;09
  &shadow_fx_0A   ;0A
  &shadow_fx_0B   ;0B
  &shadow_fx_0C   ;0C
  &shadow_fx_0D   ;0D
]

---------------------------------------------
; Animation $00: 4 frames (hold 9, 9, 9, 1).

shadow_fx_00 [
  sprite-set < #$0009, &sprite_group_17B098 >   ;00
  sprite-set < #$0009, &sprite_group_17B0CF >   ;01
  sprite-set < #$0009, &sprite_group_17B0FF >   ;02
  sprite-set < #$0001, &sprite_group_17B12F >   ;03
]

shadow_fx_01 [
  sprite-set < #$0003, &sprite_group_17B15F >
]

shadow_fx_02 [
  sprite-set < #$0003, &sprite_group_17B15F >
]

shadow_fx_03 [
  sprite-set < #$0003, &sprite_group_17B15F >
]

---------------------------------------------
; Animation $04: 8 frames (hold 3, 3, 3, 6, 4, 3, 2, 0), the longest list of the set.

shadow_fx_04 [
  sprite-set < #$0003, &sprite_group_17B18F >   ;00
  sprite-set < #$0003, &sprite_group_17B1BF >   ;01
  sprite-set < #$0003, &sprite_group_17B1EF >   ;02
  sprite-set < #$0006, &sprite_group_17B211 >   ;03
  sprite-set < #$0004, &sprite_group_17B233 >   ;04
  sprite-set < #$0003, &sprite_group_17B263 >   ;05
  sprite-set < #$0002, &sprite_group_17B293 >   ;06
  sprite-set < #$0000, &sprite_group_17B2D1 >   ;07
]

---------------------------------------------
; Animation $05: one frame, hold 31, group 17B098 (same as $07, $08, $0A, $0B, $0D).

shadow_fx_05 [
  sprite-set < #$001F, &sprite_group_17B098 >
]

shadow_fx_06 [
  sprite-set < #$0007, &sprite_group_17B376 >
]

shadow_fx_07 [
  sprite-set < #$001F, &sprite_group_17B098 >
]

shadow_fx_08 [
  sprite-set < #$001F, &sprite_group_17B098 >
]

shadow_fx_09 [
  sprite-set < #$0007, &sprite_group_17B308 >
]

shadow_fx_0A [
  sprite-set < #$001F, &sprite_group_17B098 >
]

shadow_fx_0B [
  sprite-set < #$001F, &sprite_group_17B098 >
]

shadow_fx_0C [
  sprite-set < #$0007, &sprite_group_17B33F >
]

shadow_fx_0D [
  sprite-set < #$001F, &sprite_group_17B098 >
]

sprite_group_17B098 [
  sprite-group < #10, #10, #30, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #08, #08, #00, #28, #$0000 >   ;00
    sprite-part < #01, #00, #10, #0B, #1D, #$0020 >   ;01
    sprite-part < #01, #10, #00, #0B, #1D, #$0022 >   ;02
    sprite-part < #01, #00, #10, #1B, #0D, #$0040 >   ;03
    sprite-part < #01, #10, #00, #1B, #0D, #$0042 >   ;04
    sprite-part < #01, #08, #08, #28, #00, #$000E >   ;05
  ] >
]

sprite_group_17B0CF [
  sprite-group < #10, #10, #31, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #05, [
    sprite-part < #01, #08, #08, #00, #21, #$0000 >   ;00
    sprite-part < #01, #00, #10, #0B, #16, #$0020 >   ;01
    sprite-part < #01, #10, #00, #0B, #16, #$0022 >   ;02
    sprite-part < #01, #00, #10, #1B, #06, #$0040 >   ;03
    sprite-part < #01, #10, #00, #1B, #06, #$0042 >   ;04
  ] >
]

sprite_group_17B0FF [
  sprite-group < #10, #10, #32, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #05, [
    sprite-part < #01, #08, #08, #00, #22, #$0000 >   ;00
    sprite-part < #01, #00, #10, #0B, #17, #$0020 >   ;01
    sprite-part < #01, #10, #00, #0B, #17, #$0022 >   ;02
    sprite-part < #01, #00, #10, #1B, #07, #$0040 >   ;03
    sprite-part < #01, #10, #00, #1B, #07, #$0042 >   ;04
  ] >
]

sprite_group_17B12F [
  sprite-group < #10, #10, #33, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #05, [
    sprite-part < #01, #08, #08, #00, #23, #$0000 >   ;00
    sprite-part < #01, #00, #10, #0B, #18, #$0020 >   ;01
    sprite-part < #01, #10, #00, #0B, #18, #$0022 >   ;02
    sprite-part < #01, #00, #10, #1B, #08, #$0040 >   ;03
    sprite-part < #01, #10, #00, #1B, #08, #$0042 >   ;04
  ] >
]

sprite_group_17B15F [
  sprite-group < #10, #10, #11, #10, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #05, [
    sprite-part < #01, #06, #0A, #00, #11, #$0000 >   ;00
    sprite-part < #01, #00, #10, #01, #10, #$0060 >   ;01
    sprite-part < #01, #10, #00, #01, #10, #$0062 >   ;02
    sprite-part < #01, #00, #10, #11, #00, #$0080 >   ;03
    sprite-part < #01, #10, #00, #11, #00, #$0082 >   ;04
  ] >
]

sprite_group_17B18F [
  sprite-group < #10, #10, #28, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #05, [
    sprite-part < #01, #08, #08, #20, #00, #$000E >   ;00
    sprite-part < #01, #00, #10, #00, #20, #$05C0 >   ;01
    sprite-part < #01, #10, #00, #00, #20, #$05C2 >   ;02
    sprite-part < #01, #00, #10, #10, #10, #$05E0 >   ;03
    sprite-part < #01, #10, #00, #10, #10, #$05E2 >   ;04
  ] >
]

sprite_group_17B1BF [
  sprite-group < #10, #10, #28, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #05, [
    sprite-part < #01, #08, #08, #20, #00, #$000E >   ;00
    sprite-part < #01, #00, #10, #00, #20, #$05C4 >   ;01
    sprite-part < #01, #10, #00, #00, #20, #$05C6 >   ;02
    sprite-part < #01, #00, #10, #10, #10, #$05E4 >   ;03
    sprite-part < #01, #10, #00, #10, #10, #$05E6 >   ;04
  ] >
]

sprite_group_17B1EF [
  sprite-group < #0D, #0D, #1E, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #03, [
    sprite-part < #01, #00, #0A, #00, #16, #$0046 >   ;00
    sprite-part < #01, #0A, #00, #00, #16, #$4046 >   ;01
    sprite-part < #01, #05, #05, #16, #00, #$000E >   ;02
  ] >
]

sprite_group_17B211 [
  sprite-group < #0E, #0E, #20, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #03, [
    sprite-part < #01, #00, #0C, #00, #18, #$8046 >   ;00
    sprite-part < #01, #0C, #00, #00, #18, #$C046 >   ;01
    sprite-part < #01, #06, #06, #18, #00, #$000E >   ;02
  ] >
]

sprite_group_17B233 [
  sprite-group < #0D, #0F, #24, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #05, [
    sprite-part < #01, #0C, #00, #09, #13, #$C048 >   ;00
    sprite-part < #01, #00, #0C, #08, #14, #$8048 >   ;01
    sprite-part < #01, #00, #0C, #00, #1C, #$8058 >   ;02
    sprite-part < #01, #05, #07, #1C, #00, #$000E >   ;03
    sprite-part < #01, #0C, #00, #00, #1C, #$C058 >   ;04
  ] >
]

sprite_group_17B263 [
  sprite-group < #0F, #10, #25, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #05, [
    sprite-part < #01, #00, #0F, #0F, #0E, #$006C >   ;00
    sprite-part < #01, #00, #0F, #00, #1D, #$004C >   ;01
    sprite-part < #01, #0F, #00, #0F, #0E, #$406C >   ;02
    sprite-part < #01, #07, #08, #1D, #00, #$000E >   ;03
    sprite-part < #01, #0F, #00, #00, #1D, #$404C >   ;04
  ] >
]

sprite_group_17B293 [
  sprite-group < #0F, #0F, #27, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #07, [
    sprite-part < #01, #07, #07, #1F, #00, #$000E >   ;00
    sprite-part < #01, #07, #07, #02, #1D, #$004A >   ;01
    sprite-part < #01, #07, #07, #12, #0D, #$006A >   ;02
    sprite-part < #01, #00, #0E, #00, #1F, #$004C >   ;03
    sprite-part < #01, #0E, #00, #00, #1F, #$404C >   ;04
    sprite-part < #01, #00, #0E, #10, #0F, #$006C >   ;05
    sprite-part < #01, #0E, #00, #10, #0F, #$406C >   ;06
  ] >
]

sprite_group_17B2D1 [
  sprite-group < #10, #10, #2F, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #08, #08, #00, #27, #$0000 >   ;00
    sprite-part < #01, #00, #10, #0B, #1C, #$0020 >   ;01
    sprite-part < #01, #10, #00, #0B, #1C, #$0022 >   ;02
    sprite-part < #01, #00, #10, #1B, #0C, #$0040 >   ;03
    sprite-part < #01, #10, #00, #1B, #0C, #$0042 >   ;04
    sprite-part < #01, #08, #08, #27, #00, #$000E >   ;05
  ] >
]

sprite_group_17B308 [
  sprite-group < #13, #15, #13, #12, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #03, #15, #00, #15, #$0002 >   ;00
    sprite-part < #01, #00, #18, #02, #13, #$0064 >   ;01
    sprite-part < #01, #10, #08, #02, #13, #$0066 >   ;02
    sprite-part < #01, #00, #18, #12, #03, #$0084 >   ;03
    sprite-part < #01, #10, #08, #12, #03, #$0086 >   ;04
    sprite-part < #00, #20, #00, #1D, #00, #$0098 >   ;05
  ] >
]

sprite_group_17B33F [
  sprite-group < #14, #14, #12, #13, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #15, #03, #00, #15, #$4002 >   ;00
    sprite-part < #01, #18, #00, #02, #13, #$4064 >   ;01
    sprite-part < #01, #08, #10, #02, #13, #$4066 >   ;02
    sprite-part < #01, #18, #00, #12, #03, #$4084 >   ;03
    sprite-part < #01, #08, #10, #12, #03, #$4086 >   ;04
    sprite-part < #00, #00, #20, #1D, #00, #$4098 >   ;05
  ] >
]

sprite_group_17B376 [
  sprite-group < #10, #10, #14, #15, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #05, [
    sprite-part < #01, #00, #10, #09, #10, #$000A >   ;00
    sprite-part < #01, #10, #00, #09, #10, #$000C >   ;01
    sprite-part < #01, #09, #07, #00, #19, #$0004 >   ;02
    sprite-part < #01, #00, #10, #19, #00, #$002A >   ;03
    sprite-part < #01, #10, #00, #19, #00, #$002C >   ;04
  ] >
]