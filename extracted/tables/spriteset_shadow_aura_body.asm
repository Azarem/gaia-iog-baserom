; Shadow's Aura body sprites (Bank 17, 1556480-1557571 = $17:C000): 3 animations, 55 frame records, 23 sprite groups, 80 sub-sprites. This is the spriteset of body_table row $08 (art shad_sprites_1BC000, the same tile graphics as Shadow's normal body, spriteset_shadow). Nothing else selects the row: PlayerAuraTransformEntry (player_transition_handlers, entered from item_use_system.UseItem_Aura when Shadow uses the Aura item standing still) calls SetPlayerSpriteDirect #08. The item's own description string is 'Dark Knight Shadow's Body turns to water' (item_description_table $24), which is what these frames show. The old note ('Shadow's unique movement and combat modes') named no code, and the body_table note said that nothing selects row $08; both were wrong.
; 
; The struct format (table, frame list, group header, sub-sprite) is described once, in the spriteset_freedan block note.
; 
; === ANIMATIONS ===
; 
; | Index | Records | Caller | Content |
; |-------|---------|--------|---------|
; | $00 | 20 (holds $13, 5, 5, 4, 4, 3, then 13 x 2, then 0) | PlayerAuraTransformEntry: StageSpriteFrame #00 + AnimOnce, first thing after SetPlayerSpriteDirect #08 | 6 groups of 6, 6, 4, 4, 2 and 4 sub-sprites, then 13 groups of 1-7 sub-sprites, then the one-sprite group 17C42F |
; | $01 | 19 | PlayerAuraBlockedBySolid (the abort path): StageSpriteFrame #01 + AnimOnce at the original spot, then exit | The same groups as $00 in reverse order (13 small groups, then the 6 large ones, last hold $13), without the final group 17C42F |
; | $02 | 16, all hold 0 | PlayerAuraLandAnimLoop: StageSpriteMoveY #02, #01 (Y chain 1 = +1 px per frame) | Alternates the single-sprite groups 17C3DE / 17C3F2 and the four-sprite group 17C406 with the one-sprite group 17C42F every second frame |
; 
; The order of the calls is traced; what the frames look like on screen (a body that flattens, rises again, drips) is only read off the shapes: the shrinking sub-sprite counts of $00 and their reversal in $01 match 'turns to water' and the abort that shows the body again, but the art was not viewed (OQ-I071-1). The palette the frames use and where the Aura sequence ends (PlayerAuraTransformExit) are not covered here.
; 
; === CHECKS ===
; 
; 1091 bytes = 6 (3 pointers) + 3 x 2 (list terminators) + 55 x 4 (records) + 23 x 13 (group headers) + 80 x 7 (sub-sprites). All 23 groups are referenced by the three lists; groups 17C0E8 to 17C1C3 are the six large ones, 17C3DE / 17C3F2 / 17C406 / 17C42F are only used by $02 (17C42F also ends $00).
---------------------------------------------

?BANK 17

---------------------------------------------

; Animation table of the Aura body (body_table row $08), 3 pointers: $00 = the body turning to water (played once), $01 = the same groups in reverse (the abort path), $02 = 16 one-tick frames played while the player sinks (Y +1 px per frame). The caller of all three is player_transition_handlers.PlayerAuraTransformEntry.

spriteset_shadow_aura_body [
  &shadow_aura_anim_sink   ;00
  &shadow_aura_anim_abort   ;01
  &shadow_aura_anim_land_loop   ;02
]

---------------------------------------------
; Animation $00, 20 records: the large body group 17C0E8 for 20 ticks, five shrinking groups (holds 5, 5, 4, 4, 3), thirteen small groups of 2 ticks each, and the closing one-sprite group 17C42F.

shadow_aura_anim_sink [
  sprite-set < #$0013, &sprite_group_17C0E8 >   ;00
  sprite-set < #$0005, &sprite_group_17C11F >   ;01
  sprite-set < #$0005, &sprite_group_17C156 >   ;02
  sprite-set < #$0004, &sprite_group_17C17F >   ;03
  sprite-set < #$0004, &sprite_group_17C1A8 >   ;04
  sprite-set < #$0003, &sprite_group_17C1C3 >   ;05
  sprite-set < #$0002, &sprite_group_17C3C3 >   ;06
  sprite-set < #$0002, &sprite_group_17C3A8 >   ;07
  sprite-set < #$0002, &sprite_group_17C38D >   ;08
  sprite-set < #$0002, &sprite_group_17C356 >   ;09
  sprite-set < #$0002, &sprite_group_17C32D >   ;0A
  sprite-set < #$0002, &sprite_group_17C2F6 >   ;0B
  sprite-set < #$0002, &sprite_group_17C2B8 >   ;0C
  sprite-set < #$0002, &sprite_group_17C27A >   ;0D
  sprite-set < #$0002, &sprite_group_17C251 >   ;0E
  sprite-set < #$0002, &sprite_group_17C22F >   ;0F
  sprite-set < #$0002, &sprite_group_17C214 >   ;10
  sprite-set < #$0002, &sprite_group_17C200 >   ;11
  sprite-set < #$0002, &sprite_group_17C1EC >   ;12
  sprite-set < #$0000, &sprite_group_17C42F >   ;13
]

---------------------------------------------
; Animation $01, 19 records: the groups of $00 in reverse order, from the smallest (17C1EC) back to the large body group 17C0E8 (last hold $13). Shown by the abort branch of the Aura sequence.

shadow_aura_anim_abort [
  sprite-set < #$0002, &sprite_group_17C1EC >   ;00
  sprite-set < #$0002, &sprite_group_17C200 >   ;01
  sprite-set < #$0002, &sprite_group_17C214 >   ;02
  sprite-set < #$0002, &sprite_group_17C22F >   ;03
  sprite-set < #$0002, &sprite_group_17C251 >   ;04
  sprite-set < #$0002, &sprite_group_17C27A >   ;05
  sprite-set < #$0002, &sprite_group_17C2B8 >   ;06
  sprite-set < #$0002, &sprite_group_17C2F6 >   ;07
  sprite-set < #$0002, &sprite_group_17C32D >   ;08
  sprite-set < #$0002, &sprite_group_17C356 >   ;09
  sprite-set < #$0002, &sprite_group_17C38D >   ;0A
  sprite-set < #$0002, &sprite_group_17C3A8 >   ;0B
  sprite-set < #$0002, &sprite_group_17C3C3 >   ;0C
  sprite-set < #$0003, &sprite_group_17C1C3 >   ;0D
  sprite-set < #$0004, &sprite_group_17C1A8 >   ;0E
  sprite-set < #$0004, &sprite_group_17C17F >   ;0F
  sprite-set < #$0005, &sprite_group_17C156 >   ;10
  sprite-set < #$0005, &sprite_group_17C11F >   ;11
  sprite-set < #$0013, &sprite_group_17C0E8 >   ;12
]

---------------------------------------------
; Animation $02, 16 records, all hold 0: the groups 17C3DE, 17C406, 17C3F2 and 17C406 (two records each) alternate with the one-sprite group 17C42F. Staged with Y chain 1 while the player sinks.

shadow_aura_anim_land_loop [
  sprite-set < #$0000, &sprite_group_17C3DE >   ;00
  sprite-set < #$0000, &sprite_group_17C42F >   ;01
  sprite-set < #$0000, &sprite_group_17C3DE >   ;02
  sprite-set < #$0000, &sprite_group_17C42F >   ;03
  sprite-set < #$0000, &sprite_group_17C406 >   ;04
  sprite-set < #$0000, &sprite_group_17C42F >   ;05
  sprite-set < #$0000, &sprite_group_17C406 >   ;06
  sprite-set < #$0000, &sprite_group_17C42F >   ;07
  sprite-set < #$0000, &sprite_group_17C3F2 >   ;08
  sprite-set < #$0000, &sprite_group_17C42F >   ;09
  sprite-set < #$0000, &sprite_group_17C3F2 >   ;0A
  sprite-set < #$0000, &sprite_group_17C42F >   ;0B
  sprite-set < #$0000, &sprite_group_17C406 >   ;0C
  sprite-set < #$0000, &sprite_group_17C42F >   ;0D
  sprite-set < #$0000, &sprite_group_17C406 >   ;0E
  sprite-set < #$0000, &sprite_group_17C42F >   ;0F
]

---------------------------------------------
; The large body group: 6 sub-sprites, first record of $00 and last of $01.

sprite_group_17C0E8 [
  sprite-group < #10, #10, #2D, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #08, #08, #00, #25, #$0000 >   ;00
    sprite-part < #01, #00, #10, #0B, #1A, #$0020 >   ;01
    sprite-part < #01, #10, #00, #1B, #0A, #$0102 >   ;02
    sprite-part < #01, #00, #10, #1B, #0A, #$0100 >   ;03
    sprite-part < #01, #10, #00, #0B, #1A, #$0022 >   ;04
    sprite-part < #01, #08, #08, #25, #00, #$000E >   ;05
  ] >
]

sprite_group_17C11F [
  sprite-group < #0F, #0F, #2A, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #07, #07, #00, #22, #$0000 >   ;00
    sprite-part < #01, #00, #0E, #0A, #18, #$0020 >   ;01
    sprite-part < #01, #01, #0D, #18, #0A, #$0100 >   ;02
    sprite-part < #01, #0E, #00, #18, #0A, #$0102 >   ;03
    sprite-part < #01, #0E, #00, #0A, #18, #$0022 >   ;04
    sprite-part < #01, #07, #07, #22, #00, #$000E >   ;05
  ] >
]

sprite_group_17C156 [
  sprite-group < #10, #10, #20, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #04, [
    sprite-part < #01, #00, #10, #10, #00, #$006C >   ;00
    sprite-part < #01, #10, #00, #10, #00, #$406C >   ;01
    sprite-part < #01, #00, #10, #00, #10, #$004C >   ;02
    sprite-part < #01, #10, #00, #00, #10, #$404C >   ;03
  ] >
]

sprite_group_17C17F [
  sprite-group < #0D, #0F, #15, #03, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #04, [
    sprite-part < #01, #0A, #02, #08, #00, #$C048 >   ;00
    sprite-part < #01, #00, #0C, #08, #00, #$8048 >   ;01
    sprite-part < #01, #00, #0C, #00, #08, #$8058 >   ;02
    sprite-part < #01, #0C, #00, #00, #08, #$C058 >   ;03
  ] >
]

sprite_group_17C1A8 [
  sprite-group < #0C, #0E, #11, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #02, [
    sprite-part < #01, #00, #0A, #00, #01, #$0046 >   ;00
    sprite-part < #01, #0A, #00, #00, #01, #$4046 >   ;01
  ] >
]

sprite_group_17C1C3 [
  sprite-group < #0B, #0D, #0A, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #04, [
    sprite-part < #00, #07, #09, #00, #02, #$00D7 >   ;00
    sprite-part < #00, #09, #07, #00, #02, #$40D7 >   ;01
    sprite-part < #00, #00, #10, #00, #02, #$00D6 >   ;02
    sprite-part < #00, #10, #00, #00, #02, #$40D6 >   ;03
  ] >
]

sprite_group_17C1EC [
  sprite-group < #03, #05, #07, #01, #F0, #F0, #02, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #00, #00, #00, #00, #00, #$00E0 >
  ] >
]

sprite_group_17C200 [
  sprite-group < #04, #04, #07, #01, #F0, #F0, #02, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #00, #00, #00, #00, #00, #$00F1 >
  ] >
]

sprite_group_17C214 [
  sprite-group < #04, #08, #0F, #00, #F0, #F0, #02, #01, #F8, #10, #F0, #10, #02, [
    sprite-part < #00, #00, #04, #07, #00, #$00F0 >   ;00
    sprite-part < #00, #04, #00, #00, #07, #$00E0 >   ;01
  ] >
]

sprite_group_17C22F [
  sprite-group < #06, #08, #10, #00, #F0, #F0, #02, #01, #F8, #10, #F0, #10, #03, [
    sprite-part < #00, #00, #06, #08, #00, #$00F2 >   ;00
    sprite-part < #00, #05, #01, #08, #00, #$40F2 >   ;01
    sprite-part < #00, #06, #00, #00, #08, #$00F1 >   ;02
  ] >
]

sprite_group_17C251 [
  sprite-group < #0A, #08, #10, #00, #F0, #F0, #02, #01, #F8, #10, #F0, #10, #04, [
    sprite-part < #00, #02, #08, #08, #00, #$00F2 >   ;00
    sprite-part < #00, #0A, #00, #08, #00, #$40F2 >   ;01
    sprite-part < #00, #0A, #00, #00, #08, #$00F0 >   ;02
    sprite-part < #00, #00, #0A, #02, #06, #$00E0 >   ;03
  ] >
]

sprite_group_17C27A [
  sprite-group < #0B, #0B, #10, #04, #F0, #F0, #02, #01, #F8, #10, #F0, #10, #07, [
    sprite-part < #00, #09, #05, #00, #0C, #$00F2 >   ;00
    sprite-part < #00, #0E, #00, #00, #0C, #$40F2 >   ;01
    sprite-part < #00, #00, #0E, #02, #0A, #$00F1 >   ;02
    sprite-part < #00, #05, #09, #05, #07, #$00E3 >   ;03
    sprite-part < #00, #05, #09, #0C, #00, #$00F3 >   ;04
    sprite-part < #00, #0B, #03, #05, #07, #$40E3 >   ;05
    sprite-part < #00, #0B, #03, #0C, #00, #$40F3 >   ;06
  ] >
]

sprite_group_17C2B8 [
  sprite-group < #0B, #0D, #0F, #04, #F0, #F0, #02, #01, #F8, #10, #F0, #10, #07, [
    sprite-part < #00, #10, #00, #00, #0B, #$40F2 >   ;00
    sprite-part < #00, #00, #10, #01, #0A, #$00F0 >   ;01
    sprite-part < #00, #05, #0B, #0B, #00, #$00F3 >   ;02
    sprite-part < #00, #05, #0B, #03, #08, #$00E3 >   ;03
    sprite-part < #00, #0C, #04, #0B, #00, #$40F3 >   ;04
    sprite-part < #00, #08, #08, #00, #0B, #$00F2 >   ;05
    sprite-part < #00, #0C, #04, #03, #08, #$40E3 >   ;06
  ] >
]

sprite_group_17C2F6 [
  sprite-group < #0D, #0B, #11, #03, #F0, #F0, #02, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #00, #08, #08, #04, #08, #$00E3 >   ;00
    sprite-part < #00, #00, #10, #03, #09, #$00F2 >   ;01
    sprite-part < #00, #05, #0B, #03, #09, #$40F2 >   ;02
    sprite-part < #00, #08, #08, #0C, #00, #$00F3 >   ;03
    sprite-part < #00, #10, #00, #00, #0C, #$C0F3 >   ;04
    sprite-part < #00, #10, #00, #08, #04, #$C0E3 >   ;05
  ] >
]

sprite_group_17C32D [
  sprite-group < #0F, #0B, #10, #00, #F0, #F0, #02, #01, #F8, #10, #F0, #10, #04, [
    sprite-part < #01, #0A, #00, #00, #00, #$4078 >   ;00
    sprite-part < #00, #08, #0A, #02, #06, #$40F2 >   ;01
    sprite-part < #00, #00, #12, #03, #05, #$00F2 >   ;02
    sprite-part < #00, #03, #0F, #08, #00, #$00F3 >   ;03
  ] >
]

sprite_group_17C356 [
  sprite-group < #0D, #0C, #10, #00, #F0, #F0, #02, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #00, #02, #0F, #08, #00, #$0088 >   ;00
    sprite-part < #00, #0A, #07, #08, #00, #$0089 >   ;01
    sprite-part < #00, #08, #09, #00, #08, #$0079 >   ;02
    sprite-part < #00, #00, #11, #00, #08, #$0078 >   ;03
    sprite-part < #00, #10, #01, #01, #07, #$4078 >   ;04
    sprite-part < #00, #11, #00, #08, #00, #$4088 >   ;05
  ] >
]

sprite_group_17C38D [
  sprite-group < #0E, #0E, #10, #01, #F0, #F0, #02, #01, #F8, #10, #F0, #10, #02, [
    sprite-part < #01, #0C, #00, #01, #00, #$4078 >   ;00
    sprite-part < #01, #00, #0C, #00, #01, #$0078 >   ;01
  ] >
]

sprite_group_17C3A8 [
  sprite-group < #0E, #0F, #0F, #01, #F0, #F0, #02, #01, #F8, #10, #F0, #10, #02, [
    sprite-part < #01, #00, #0D, #00, #00, #$0078 >   ;00
    sprite-part < #01, #0D, #00, #00, #00, #$4078 >   ;01
  ] >
]

sprite_group_17C3C3 [
  sprite-group < #0F, #0F, #10, #00, #F0, #F0, #02, #01, #F5, #16, #F6, #06, #02, [
    sprite-part < #01, #00, #0E, #00, #00, #$0078 >   ;00
    sprite-part < #01, #0E, #00, #00, #00, #$4078 >   ;01
  ] >
]

sprite_group_17C3DE [
  sprite-group < #08, #08, #08, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #01, #00, #00, #00, #00, #$004A >
  ] >
]

sprite_group_17C3F2 [
  sprite-group < #08, #08, #08, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #01, #00, #00, #00, #00, #$006A >
  ] >
]

sprite_group_17C406 [
  sprite-group < #08, #08, #08, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #04, [
    sprite-part < #00, #00, #08, #00, #08, #$00A6 >   ;00
    sprite-part < #00, #00, #08, #08, #00, #$00B6 >   ;01
    sprite-part < #00, #08, #00, #08, #00, #$00C6 >   ;02
    sprite-part < #00, #08, #00, #00, #08, #$0099 >   ;03
  ] >
]

---------------------------------------------
; One sub-sprite (tile word $041E, offsets 0,0): the closing record of $00 and every second frame of $02.

sprite_group_17C42F [
  sprite-group < #08, #00, #08, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #01, [
    sprite-part < #00, #00, #00, #00, #00, #$041E >
  ] >
]