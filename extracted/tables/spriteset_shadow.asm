; Shadow player spriteset (Bank 14, 1343488-1355931 = $14:8000): every frame the player can show in form 2. 76 animations ($00-$4B), 261 frame records, 168 sprite groups, 1273 sub-sprites (at most 14 per group). Chosen by body_table rows $02 and $03 (spriteset bank $94, art shad_sprites_1BC000; row $03 is a copy, OQ-I061-1); SetActorBody copies the table pointer and bank into the actor ($7F0006, $7F0008). The animation numbering is shared with spriteset_will and spriteset_freedan, and the struct format (table, frame list, group header, sub-sprite) is described once, in the spriteset_freedan block note.
; 
; The old header ('walking, idle, attack and liquify animation frames', 'Shadow's unique morph poses') named poses the code does not use: 'liquify' appears nowhere outside the headers of this file and spriteset_shadow_fx, and the table has the same 76 indices as the Freedan table. Shadow's separate mode body is spriteset_shadow_aura_body (body_table row $08) and the effect sprites are in spriteset_shadow_fx.
; 
; === WHAT DIFFERS FROM THE FREEDAN TABLE (same indices, other frame counts) ===
; 
; - Idle $00-$07 and $10-$17 are one frame with hold 9 (10 ticks). The player scripts stage $10-$13 for Shadow only; they use groups of their own (for example $00 shows sprite_group_148544, $10 shows sprite_group_14857B).
; - Walk $08-$0F is 6 frames of hold 7 (Freedan 4 frames).
; - Climb poses: the vine cycle $19-$1B, the ladder idles $2A-$2B and $2E-$2F and the detach poses $30-$31 and $34-$35 are one-frame lists (Freedan: 4 frames each); the ladder move $2C-$2D and the shimmy $32-$33 are 6 frames (holds 7, 3, 3, 7, 3, 3; Freedan 20 and 5); $18 is 4 frames (holds 9, 6, 4, 9). Other lists: $1C is 11 frames (holds 0, 1, 2, 3, 4, 1, 2, 3, 2, 1, 0), $1D-$25 are one frame each, $26-$29 are 4 frames.
; - Melee attack $36-$39 is 7 frames (holds 3, 2, 1, 0, 0, 1, 2 = 16 ticks), the same frame count as Freedan; guard $3A-$3D is 8 frames of hold 0 (Freedan 4); $42-$43 and $48-$49 are 7 frames, $44-$47 and $4A-$4B one frame of hold 0.
; - $3E-$41 (7 frames, holds 3, 1, 8, 4, 3, 3, 8) is not staged by the player scripts.
; 
; === CHECKS ===
; 
; All 168 groups have a count byte equal to their number of sub-sprites, all 168 keep the default attack box $F8 $F0 $01 $01, all are referenced, all 76 frame lists are 4n + 2 bytes long (the label spacing of 75 consecutive lists was checked by hand) and 12443 bytes = 152 (table) + 4 x 261 + 2 x 76 (lists and their hidden $FFFF terminators) + 13 x 168 + 7 x 1273.
---------------------------------------------

?BANK 14

---------------------------------------------

; 76 word pointers to frame lists, indexed by the actor animation index ($28); the same index space as spriteset_freedan (see its table part note for the staged indices). The Shadow shapes are listed in the block note: idle 1 frame (hold 9), walk 6 frames (hold 7), melee 7 frames, guard 8 frames of hold 0; the vine cycle and the ladder idles are single frames.

spriteset_shadow [
  &shadow_anim_00   ;00
  &shadow_anim_01   ;01
  &shadow_anim_02   ;02
  &shadow_anim_03   ;03
  &shadow_anim_04   ;04
  &shadow_anim_05   ;05
  &shadow_anim_06   ;06
  &shadow_anim_07   ;07
  &shadow_anim_08_walk_south   ;08
  &shadow_anim_09_walk_north   ;09
  &shadow_anim_0A_walk_west   ;0A
  &shadow_anim_0B_walk_east   ;0B
  &shadow_anim_0C_moving_south   ;0C
  &shadow_anim_0D_moving_north   ;0D
  &shadow_anim_0E_moving_west   ;0E
  &shadow_anim_0F_moving_east   ;0F
  &shadow_anim_10_idle_south   ;10
  &shadow_anim_11_idle_north   ;11
  &shadow_anim_12_idle_west   ;12
  &shadow_anim_13_idle_east   ;13
  &shadow_anim_14   ;14
  &shadow_anim_15   ;15
  &shadow_anim_16   ;16
  &shadow_anim_17   ;17
  &shadow_anim_18_vine_enter   ;18
  &shadow_anim_19_vine_climb_3   ;19
  &shadow_anim_1A_vine_climb_1   ;1A
  &shadow_anim_1B_vine_climb_2   ;1B
  &shadow_anim_1C   ;1C
  &shadow_anim_1D   ;1D
  &shadow_anim_1E   ;1E
  &shadow_anim_1F   ;1F
  &shadow_anim_20   ;20
  &shadow_anim_21   ;21
  &shadow_anim_22   ;22
  &shadow_anim_23   ;23
  &shadow_anim_24   ;24
  &shadow_anim_25   ;25
  &shadow_anim_26   ;26
  &shadow_anim_27   ;27
  &shadow_anim_28   ;28
  &shadow_anim_29   ;29
  &shadow_anim_2A   ;2A
  &shadow_anim_2B   ;2B
  &shadow_anim_2C_ladder_up   ;2C
  &shadow_anim_2D_ladder_down   ;2D
  &shadow_anim_2E_ladder_idle_north   ;2E
  &shadow_anim_2F_ladder_idle_south   ;2F
  &shadow_anim_30   ;30
  &shadow_anim_31   ;31
  &shadow_anim_32_shimmy_left   ;32
  &shadow_anim_33_shimmy_right   ;33
  &shadow_anim_34_shimmy_detach_left   ;34
  &shadow_anim_35_shimmy_detach_right   ;35
  &shadow_anim_36_attack_south   ;36
  &shadow_anim_37_attack_north   ;37
  &shadow_anim_38_attack_west   ;38
  &shadow_anim_39_attack_east   ;39
  &shadow_anim_3A_guard_south   ;3A
  &shadow_anim_3B_guard_north   ;3B
  &shadow_anim_3C_guard_west   ;3C
  &shadow_anim_3D_guard_east   ;3D
  &shadow_anim_3E   ;3E
  &shadow_anim_3F   ;3F
  &shadow_anim_40   ;40
  &shadow_anim_41   ;41
  &shadow_anim_42   ;42
  &shadow_anim_43   ;43
  &shadow_anim_44   ;44
  &shadow_anim_45   ;45
  &shadow_anim_46   ;46
  &shadow_anim_47   ;47
  &shadow_anim_48   ;48
  &shadow_anim_49   ;49
  &shadow_anim_4A   ;4A
  &shadow_anim_4B   ;4B
]

shadow_anim_00 [
  sprite-set < #$0009, &sprite_group_148544 >
]

shadow_anim_01 [
  sprite-set < #$0009, &sprite_group_1487F1 >
]

shadow_anim_02 [
  sprite-set < #$0009, &sprite_group_148657 >
]

shadow_anim_03 [
  sprite-set < #$0009, &sprite_group_148724 >
]

shadow_anim_04 [
  sprite-set < #$0009, &sprite_group_1485B2 >
]

shadow_anim_05 [
  sprite-set < #$0009, &sprite_group_14885F >
]

shadow_anim_06 [
  sprite-set < #$0009, &sprite_group_1486A9 >
]

shadow_anim_07 [
  sprite-set < #$0009, &sprite_group_148776 >
]

shadow_anim_08_walk_south [
  sprite-set < #$0007, &sprite_group_14857B >   ;00
  sprite-set < #$0007, &sprite_group_1485B2 >   ;01
  sprite-set < #$0007, &sprite_group_1485E9 >   ;02
  sprite-set < #$0007, &sprite_group_148620 >   ;03
  sprite-set < #$0007, &sprite_group_1485E9 >   ;04
  sprite-set < #$0007, &sprite_group_1485B2 >   ;05
]

shadow_anim_09_walk_north [
  sprite-set < #$0007, &sprite_group_148828 >   ;00
  sprite-set < #$0007, &sprite_group_14885F >   ;01
  sprite-set < #$0007, &sprite_group_148896 >   ;02
  sprite-set < #$0007, &sprite_group_1488CD >   ;03
  sprite-set < #$0007, &sprite_group_148896 >   ;04
  sprite-set < #$0007, &sprite_group_14885F >   ;05
]

shadow_anim_0A_walk_west [
  sprite-set < #$0007, &sprite_group_148680 >   ;00
  sprite-set < #$0007, &sprite_group_1486A9 >   ;01
  sprite-set < #$0007, &sprite_group_1486D2 >   ;02
  sprite-set < #$0007, &sprite_group_1486FB >   ;03
  sprite-set < #$0007, &sprite_group_1486D2 >   ;04
  sprite-set < #$0007, &sprite_group_1486A9 >   ;05
]

shadow_anim_0B_walk_east [
  sprite-set < #$0007, &sprite_group_14874D >   ;00
  sprite-set < #$0007, &sprite_group_148776 >   ;01
  sprite-set < #$0007, &sprite_group_14879F >   ;02
  sprite-set < #$0007, &sprite_group_1487C8 >   ;03
  sprite-set < #$0007, &sprite_group_14879F >   ;04
  sprite-set < #$0007, &sprite_group_148776 >   ;05
]

shadow_anim_0C_moving_south [
  sprite-set < #$0007, &sprite_group_148904 >   ;00
  sprite-set < #$0007, &sprite_group_14893B >   ;01
  sprite-set < #$0007, &sprite_group_148972 >   ;02
  sprite-set < #$0007, &sprite_group_1489A9 >   ;03
  sprite-set < #$0007, &sprite_group_1489E0 >   ;04
  sprite-set < #$0007, &sprite_group_148A17 >   ;05
]

shadow_anim_0D_moving_north [
  sprite-set < #$0007, &sprite_group_148CBA >   ;00
  sprite-set < #$0007, &sprite_group_148CF1 >   ;01
  sprite-set < #$0007, &sprite_group_148D28 >   ;02
  sprite-set < #$0007, &sprite_group_148D5F >   ;03
  sprite-set < #$0007, &sprite_group_148D28 >   ;04
  sprite-set < #$0007, &sprite_group_148CF1 >   ;05
]

shadow_anim_0E_moving_west [
  sprite-set < #$0007, &sprite_group_148A4E >   ;00
  sprite-set < #$0007, &sprite_group_148A8C >   ;01
  sprite-set < #$0007, &sprite_group_148ACA >   ;02
  sprite-set < #$0007, &sprite_group_148B08 >   ;03
  sprite-set < #$0007, &sprite_group_148B46 >   ;04
  sprite-set < #$0007, &sprite_group_148B84 >   ;05
]

shadow_anim_0F_moving_east [
  sprite-set < #$0007, &sprite_group_148BC2 >   ;00
  sprite-set < #$0007, &sprite_group_148C00 >   ;01
  sprite-set < #$0007, &sprite_group_148C3E >   ;02
  sprite-set < #$0007, &sprite_group_148C7C >   ;03
  sprite-set < #$0007, &sprite_group_148C3E >   ;04
  sprite-set < #$0007, &sprite_group_148C00 >   ;05
]

shadow_anim_10_idle_south [
  sprite-set < #$0009, &sprite_group_14857B >
]

shadow_anim_11_idle_north [
  sprite-set < #$0009, &sprite_group_148828 >
]

shadow_anim_12_idle_west [
  sprite-set < #$0009, &sprite_group_148680 >
]

shadow_anim_13_idle_east [
  sprite-set < #$0009, &sprite_group_14874D >
]

shadow_anim_14 [
  sprite-set < #$0009, &sprite_group_14857B >
]

shadow_anim_15 [
  sprite-set < #$0009, &sprite_group_148828 >
]

shadow_anim_16 [
  sprite-set < #$0009, &sprite_group_148680 >
]

shadow_anim_17 [
  sprite-set < #$0009, &sprite_group_14874D >
]

shadow_anim_18_vine_enter [
  sprite-set < #$0009, &sprite_group_148D96 >   ;00
  sprite-set < #$0006, &sprite_group_148DCD >   ;01
  sprite-set < #$0004, &sprite_group_148DFD >   ;02
  sprite-set < #$0009, &sprite_group_148E2D >   ;03
]

shadow_anim_19_vine_climb_3 [
  sprite-set < #$0003, &sprite_group_148E5D >
]

shadow_anim_1A_vine_climb_1 [
  sprite-set < #$0003, &sprite_group_148E5D >
]

shadow_anim_1B_vine_climb_2 [
  sprite-set < #$0003, &sprite_group_148E5D >
]

shadow_anim_1C [
  sprite-set < #$0000, &sprite_group_148E94 >   ;00
  sprite-set < #$0001, &sprite_group_148EBD >   ;01
  sprite-set < #$0002, &sprite_group_148EE6 >   ;02
  sprite-set < #$0003, &sprite_group_148F39 >   ;03
  sprite-set < #$0004, &sprite_group_148F9A >   ;04
  sprite-set < #$0001, &sprite_group_149009 >   ;05
  sprite-set < #$0002, &sprite_group_149078 >   ;06
  sprite-set < #$0003, &sprite_group_1490CB >   ;07
  sprite-set < #$0002, &sprite_group_14912C >   ;08
  sprite-set < #$0001, &sprite_group_149186 >   ;09
  sprite-set < #$0000, &sprite_group_1491B6 >   ;0A
]

shadow_anim_1D [
  sprite-set < #$001F, &sprite_group_148D96 >
]

shadow_anim_1E [
  sprite-set < #$0007, &sprite_group_149285 >
]

shadow_anim_1F [
  sprite-set < #$001F, &sprite_group_148D96 >
]

shadow_anim_20 [
  sprite-set < #$001F, &sprite_group_148D96 >
]

shadow_anim_21 [
  sprite-set < #$0007, &sprite_group_1491ED >
]

shadow_anim_22 [
  sprite-set < #$001F, &sprite_group_148D96 >
]

shadow_anim_23 [
  sprite-set < #$001F, &sprite_group_148D96 >
]

shadow_anim_24 [
  sprite-set < #$0007, &sprite_group_149239 >
]

shadow_anim_25 [
  sprite-set < #$001F, &sprite_group_148D96 >
]

shadow_anim_26 [
  sprite-set < #$000B, &sprite_group_149474 >   ;00
  sprite-set < #$000B, &sprite_group_1494AB >   ;01
  sprite-set < #$000B, &sprite_group_1494E2 >   ;02
  sprite-set < #$000B, &sprite_group_149519 >   ;03
]

shadow_anim_27 [
  sprite-set < #$0009, &sprite_group_149519 >   ;00
  sprite-set < #$0009, &sprite_group_1494E2 >   ;01
  sprite-set < #$000A, &sprite_group_1494AB >   ;02
  sprite-set < #$000A, &sprite_group_149474 >   ;03
]

shadow_anim_28 [
  sprite-set < #$0009, &sprite_group_1495B0 >   ;00
  sprite-set < #$0009, &sprite_group_1495E0 >   ;01
  sprite-set < #$000A, &sprite_group_149550 >   ;02
  sprite-set < #$000A, &sprite_group_149580 >   ;03
]

shadow_anim_29 [
  sprite-set < #$0005, &sprite_group_149580 >   ;00
  sprite-set < #$000C, &sprite_group_149550 >   ;01
  sprite-set < #$000D, &sprite_group_1495E0 >   ;02
  sprite-set < #$000E, &sprite_group_1495B0 >   ;03
]

shadow_anim_2A [
  sprite-set < #$0000, &sprite_group_149617 >
]

shadow_anim_2B [
  sprite-set < #$0000, &sprite_group_149580 >
]

shadow_anim_2C_ladder_up [
  sprite-set < #$0007, &sprite_group_149647 >   ;00
  sprite-set < #$0003, &sprite_group_14967E >   ;01
  sprite-set < #$0003, &sprite_group_1496B5 >   ;02
  sprite-set < #$0007, &sprite_group_1496EC >   ;03
  sprite-set < #$0003, &sprite_group_1496B5 >   ;04
  sprite-set < #$0003, &sprite_group_14967E >   ;05
]

shadow_anim_2D_ladder_down [
  sprite-set < #$0007, &sprite_group_149723 >   ;00
  sprite-set < #$0003, &sprite_group_14975A >   ;01
  sprite-set < #$0003, &sprite_group_149791 >   ;02
  sprite-set < #$0007, &sprite_group_1497C8 >   ;03
  sprite-set < #$0003, &sprite_group_149791 >   ;04
  sprite-set < #$0003, &sprite_group_14975A >   ;05
]

shadow_anim_2E_ladder_idle_north [
  sprite-set < #$0009, &sprite_group_149617 >
]

shadow_anim_2F_ladder_idle_south [
  sprite-set < #$0009, &sprite_group_149580 >
]

shadow_anim_30 [
  sprite-set < #$0009, &sprite_group_1492BC >
]

shadow_anim_31 [
  sprite-set < #$0009, &sprite_group_149398 >
]

shadow_anim_32_shimmy_left [
  sprite-set < #$0007, &sprite_group_1492BC >   ;00
  sprite-set < #$0003, &sprite_group_1492F3 >   ;01
  sprite-set < #$0003, &sprite_group_14932A >   ;02
  sprite-set < #$0007, &sprite_group_149361 >   ;03
  sprite-set < #$0003, &sprite_group_14932A >   ;04
  sprite-set < #$0003, &sprite_group_1492F3 >   ;05
]

shadow_anim_33_shimmy_right [
  sprite-set < #$0007, &sprite_group_149398 >   ;00
  sprite-set < #$0003, &sprite_group_1493CF >   ;01
  sprite-set < #$0003, &sprite_group_149406 >   ;02
  sprite-set < #$0007, &sprite_group_14943D >   ;03
  sprite-set < #$0003, &sprite_group_149406 >   ;04
  sprite-set < #$0003, &sprite_group_1493CF >   ;05
]

shadow_anim_34_shimmy_detach_left [
  sprite-set < #$0009, &sprite_group_1492BC >
]

shadow_anim_35_shimmy_detach_right [
  sprite-set < #$0009, &sprite_group_149398 >
]

shadow_anim_36_attack_south [
  sprite-set < #$0003, &sprite_group_1497FF >   ;00
  sprite-set < #$0002, &sprite_group_149852 >   ;01
  sprite-set < #$0001, &sprite_group_1498B3 >   ;02
  sprite-set < #$0000, &sprite_group_14991B >   ;03
  sprite-set < #$0000, &sprite_group_149975 >   ;04
  sprite-set < #$0001, &sprite_group_1499CF >   ;05
  sprite-set < #$0002, &sprite_group_149A1B >   ;06
]

shadow_anim_37_attack_north [
  sprite-set < #$0003, &sprite_group_149E88 >   ;00
  sprite-set < #$0002, &sprite_group_149ED4 >   ;01
  sprite-set < #$0001, &sprite_group_149F27 >   ;02
  sprite-set < #$0000, &sprite_group_149F88 >   ;03
  sprite-set < #$0000, &sprite_group_149FDB >   ;04
  sprite-set < #$0001, &sprite_group_14A02E >   ;05
  sprite-set < #$0002, &sprite_group_14A073 >   ;06
]

shadow_anim_38_attack_west [
  sprite-set < #$0003, &sprite_group_149A60 >   ;00
  sprite-set < #$0002, &sprite_group_149AAC >   ;01
  sprite-set < #$0001, &sprite_group_149AF1 >   ;02
  sprite-set < #$0000, &sprite_group_149B4B >   ;03
  sprite-set < #$0000, &sprite_group_149B9E >   ;04
  sprite-set < #$0001, &sprite_group_149BF1 >   ;05
  sprite-set < #$0002, &sprite_group_149C36 >   ;06
]

shadow_anim_39_attack_east [
  sprite-set < #$0003, &sprite_group_149C74 >   ;00
  sprite-set < #$0002, &sprite_group_149CC0 >   ;01
  sprite-set < #$0001, &sprite_group_149D05 >   ;02
  sprite-set < #$0000, &sprite_group_149D5F >   ;03
  sprite-set < #$0000, &sprite_group_149DB2 >   ;04
  sprite-set < #$0001, &sprite_group_149E05 >   ;05
  sprite-set < #$0002, &sprite_group_149E4A >   ;06
]

shadow_anim_3A_guard_south [
  sprite-set < #$0000, &sprite_group_14A0B1 >   ;00
  sprite-set < #$0000, &sprite_group_14A70D >   ;01
  sprite-set < #$0000, &sprite_group_14A0B1 >   ;02
  sprite-set < #$0000, &sprite_group_14A744 >   ;03
  sprite-set < #$0000, &sprite_group_14A0B1 >   ;04
  sprite-set < #$0000, &sprite_group_14A77B >   ;05
  sprite-set < #$0000, &sprite_group_14A0B1 >   ;06
  sprite-set < #$0000, &sprite_group_14A7B2 >   ;07
]

shadow_anim_3B_guard_north [
  sprite-set < #$0000, &sprite_group_14A1F0 >   ;00
  sprite-set < #$0000, &sprite_group_14A70D >   ;01
  sprite-set < #$0000, &sprite_group_14A1F0 >   ;02
  sprite-set < #$0000, &sprite_group_14A744 >   ;03
  sprite-set < #$0000, &sprite_group_14A1F0 >   ;04
  sprite-set < #$0000, &sprite_group_14A77B >   ;05
  sprite-set < #$0000, &sprite_group_14A1F0 >   ;06
  sprite-set < #$0000, &sprite_group_14A7B2 >   ;07
]

shadow_anim_3C_guard_west [
  sprite-set < #$0000, &sprite_group_14A120 >   ;00
  sprite-set < #$0000, &sprite_group_14A70D >   ;01
  sprite-set < #$0000, &sprite_group_14A120 >   ;02
  sprite-set < #$0000, &sprite_group_14A744 >   ;03
  sprite-set < #$0000, &sprite_group_14A120 >   ;04
  sprite-set < #$0000, &sprite_group_14A77B >   ;05
  sprite-set < #$0000, &sprite_group_14A120 >   ;06
  sprite-set < #$0000, &sprite_group_14A7B2 >   ;07
]

shadow_anim_3D_guard_east [
  sprite-set < #$0000, &sprite_group_14A188 >   ;00
  sprite-set < #$0000, &sprite_group_14A70D >   ;01
  sprite-set < #$0000, &sprite_group_14A188 >   ;02
  sprite-set < #$0000, &sprite_group_14A744 >   ;03
  sprite-set < #$0000, &sprite_group_14A188 >   ;04
  sprite-set < #$0000, &sprite_group_14A77B >   ;05
  sprite-set < #$0000, &sprite_group_14A188 >   ;06
  sprite-set < #$0000, &sprite_group_14A7B2 >   ;07
]

shadow_anim_3E [
  sprite-set < #$0003, &sprite_group_14A251 >   ;00
  sprite-set < #$0001, &sprite_group_14A288 >   ;01
  sprite-set < #$0008, &sprite_group_14A2BF >   ;02
  sprite-set < #$0004, &sprite_group_14A288 >   ;03
  sprite-set < #$0003, &sprite_group_14A2F6 >   ;04
  sprite-set < #$0003, &sprite_group_14A2F6 >   ;05
  sprite-set < #$0008, &sprite_group_14A32D >   ;06
]

shadow_anim_3F [
  sprite-set < #$0003, &sprite_group_14A364 >   ;00
  sprite-set < #$0001, &sprite_group_14A39B >   ;01
  sprite-set < #$0008, &sprite_group_14A3D2 >   ;02
  sprite-set < #$0004, &sprite_group_14A39B >   ;03
  sprite-set < #$0003, &sprite_group_14A409 >   ;04
  sprite-set < #$0003, &sprite_group_14A409 >   ;05
  sprite-set < #$0008, &sprite_group_14A440 >   ;06
]

shadow_anim_40 [
  sprite-set < #$0003, &sprite_group_14A477 >   ;00
  sprite-set < #$0001, &sprite_group_14A4B5 >   ;01
  sprite-set < #$0008, &sprite_group_14A508 >   ;02
  sprite-set < #$0004, &sprite_group_14A4B5 >   ;03
  sprite-set < #$0003, &sprite_group_14A55B >   ;04
  sprite-set < #$0003, &sprite_group_14A55B >   ;05
  sprite-set < #$0008, &sprite_group_14A599 >   ;06
]

shadow_anim_41 [
  sprite-set < #$0003, &sprite_group_14A5C2 >   ;00
  sprite-set < #$0001, &sprite_group_14A600 >   ;01
  sprite-set < #$0008, &sprite_group_14A653 >   ;02
  sprite-set < #$0004, &sprite_group_14A600 >   ;03
  sprite-set < #$0003, &sprite_group_14A6A6 >   ;04
  sprite-set < #$0003, &sprite_group_14A6A6 >   ;05
  sprite-set < #$0008, &sprite_group_14A6E4 >   ;06
]

shadow_anim_42 [
  sprite-set < #$0003, &sprite_group_14AA4A >   ;00
  sprite-set < #$0002, &sprite_group_14AA96 >   ;01
  sprite-set < #$0001, &sprite_group_14AADB >   ;02
  sprite-set < #$0000, &sprite_group_14AB35 >   ;03
  sprite-set < #$0000, &sprite_group_14AB88 >   ;04
  sprite-set < #$0001, &sprite_group_14ABDB >   ;05
  sprite-set < #$0002, &sprite_group_14AC20 >   ;06
]

shadow_anim_43 [
  sprite-set < #$0003, &sprite_group_14AC5E >   ;00
  sprite-set < #$0002, &sprite_group_14ACAA >   ;01
  sprite-set < #$0001, &sprite_group_14ACEF >   ;02
  sprite-set < #$0000, &sprite_group_14AD49 >   ;03
  sprite-set < #$0000, &sprite_group_14AD9C >   ;04
  sprite-set < #$0001, &sprite_group_14ADEF >   ;05
  sprite-set < #$0002, &sprite_group_14AE34 >   ;06
]

shadow_anim_44 [
  sprite-set < #$0000, &sprite_group_14A7E9 >
]

shadow_anim_45 [
  sprite-set < #$0000, &sprite_group_14A7E9 >
]

shadow_anim_46 [
  sprite-set < #$0000, &sprite_group_14A7E9 >
]

shadow_anim_47 [
  sprite-set < #$0000, &sprite_group_14A7E9 >
]

shadow_anim_48 [
  sprite-set < #$0003, &sprite_group_14A7E9 >   ;00
  sprite-set < #$0002, &sprite_group_14A83C >   ;01
  sprite-set < #$0001, &sprite_group_14A89D >   ;02
  sprite-set < #$0000, &sprite_group_14A905 >   ;03
  sprite-set < #$0000, &sprite_group_14A95F >   ;04
  sprite-set < #$0001, &sprite_group_14A9B9 >   ;05
  sprite-set < #$0002, &sprite_group_14AA05 >   ;06
]

shadow_anim_49 [
  sprite-set < #$0003, &sprite_group_14AE72 >   ;00
  sprite-set < #$0002, &sprite_group_14AEBE >   ;01
  sprite-set < #$0001, &sprite_group_14AF11 >   ;02
  sprite-set < #$0000, &sprite_group_14AF72 >   ;03
  sprite-set < #$0000, &sprite_group_14AFC5 >   ;04
  sprite-set < #$0001, &sprite_group_14B018 >   ;05
  sprite-set < #$0002, &sprite_group_14B05D >   ;06
]

shadow_anim_4A [
  sprite-set < #$0000, &sprite_group_14A7E9 >
]

shadow_anim_4B [
  sprite-set < #$0000, &sprite_group_14A7E9 >
]

---------------------------------------------
; Example group: Shadow idle south, the only frame of animation $00. Header: extents X 16 / 16, Y 45 / 8, default attack and body boxes, 6 sub-sprites of 16x16 (tile words $0000, $0020, $0102, $0100, $0022, $000E; $0102 and $0100 use the second name table, bit 8).

sprite_group_148544 [
  sprite-group < #10, #10, #2D, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #08, #08, #00, #25, #$0000 >   ;00
    sprite-part < #01, #00, #10, #0B, #1A, #$0020 >   ;01
    sprite-part < #01, #10, #00, #1B, #0A, #$0102 >   ;02
    sprite-part < #01, #00, #10, #1B, #0A, #$0100 >   ;03
    sprite-part < #01, #10, #00, #0B, #1A, #$0022 >   ;04
    sprite-part < #01, #08, #08, #25, #00, #$000E >   ;05
  ] >
]

sprite_group_14857B [
  sprite-group < #10, #10, #30, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #08, #08, #00, #28, #$0000 >   ;00
    sprite-part < #01, #00, #10, #0B, #1D, #$0020 >   ;01
    sprite-part < #01, #10, #00, #0B, #1D, #$0022 >   ;02
    sprite-part < #01, #00, #10, #1B, #0D, #$0040 >   ;03
    sprite-part < #01, #10, #00, #1B, #0D, #$0042 >   ;04
    sprite-part < #01, #08, #08, #28, #00, #$000E >   ;05
  ] >
]

sprite_group_1485B2 [
  sprite-group < #10, #10, #31, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #08, #08, #00, #29, #$0000 >   ;00
    sprite-part < #01, #00, #10, #0B, #1E, #$0020 >   ;01
    sprite-part < #01, #10, #00, #0B, #1E, #$0022 >   ;02
    sprite-part < #01, #00, #10, #1B, #0E, #$0040 >   ;03
    sprite-part < #01, #10, #00, #1B, #0E, #$0042 >   ;04
    sprite-part < #01, #08, #08, #29, #00, #$000E >   ;05
  ] >
]

sprite_group_1485E9 [
  sprite-group < #10, #10, #32, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #08, #08, #00, #2A, #$0000 >   ;00
    sprite-part < #01, #00, #10, #0B, #1F, #$0020 >   ;01
    sprite-part < #01, #10, #00, #0B, #1F, #$0022 >   ;02
    sprite-part < #01, #00, #10, #1B, #0F, #$0040 >   ;03
    sprite-part < #01, #10, #00, #1B, #0F, #$0042 >   ;04
    sprite-part < #01, #08, #08, #2A, #00, #$000E >   ;05
  ] >
]

sprite_group_148620 [
  sprite-group < #10, #10, #33, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #08, #08, #00, #2B, #$0000 >   ;00
    sprite-part < #01, #00, #10, #0B, #20, #$0020 >   ;01
    sprite-part < #01, #10, #00, #0B, #20, #$0022 >   ;02
    sprite-part < #01, #00, #10, #1B, #10, #$0040 >   ;03
    sprite-part < #01, #10, #00, #1B, #10, #$0042 >   ;04
    sprite-part < #01, #08, #08, #2B, #00, #$000E >   ;05
  ] >
]

sprite_group_148657 [
  sprite-group < #08, #09, #2E, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #04, [
    sprite-part < #01, #01, #00, #00, #26, #$0002 >   ;00
    sprite-part < #01, #01, #00, #0B, #1B, #$0024 >   ;01
    sprite-part < #01, #01, #00, #1B, #0B, #$004E >   ;02
    sprite-part < #01, #00, #01, #26, #00, #$000E >   ;03
  ] >
]

sprite_group_148680 [
  sprite-group < #09, #09, #30, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #04, [
    sprite-part < #01, #00, #02, #00, #28, #$0002 >   ;00
    sprite-part < #01, #02, #00, #0A, #1E, #$0024 >   ;01
    sprite-part < #01, #02, #00, #1A, #0E, #$0044 >   ;02
    sprite-part < #01, #01, #01, #28, #00, #$000E >   ;03
  ] >
]

sprite_group_1486A9 [
  sprite-group < #09, #09, #31, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #04, [
    sprite-part < #01, #00, #02, #00, #29, #$0002 >   ;00
    sprite-part < #01, #02, #00, #0A, #1F, #$0024 >   ;01
    sprite-part < #01, #02, #00, #1A, #0F, #$0044 >   ;02
    sprite-part < #01, #01, #01, #29, #00, #$000E >   ;03
  ] >
]

sprite_group_1486D2 [
  sprite-group < #09, #09, #32, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #04, [
    sprite-part < #01, #00, #02, #00, #2A, #$0002 >   ;00
    sprite-part < #01, #02, #00, #0A, #20, #$0024 >   ;01
    sprite-part < #01, #02, #00, #1A, #10, #$0044 >   ;02
    sprite-part < #01, #01, #01, #2A, #00, #$000E >   ;03
  ] >
]

sprite_group_1486FB [
  sprite-group < #09, #09, #33, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #04, [
    sprite-part < #01, #00, #02, #00, #2B, #$0002 >   ;00
    sprite-part < #01, #02, #00, #0A, #21, #$0024 >   ;01
    sprite-part < #01, #02, #00, #1A, #11, #$0044 >   ;02
    sprite-part < #01, #01, #01, #2B, #00, #$000E >   ;03
  ] >
]

sprite_group_148724 [
  sprite-group < #0B, #08, #2E, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #04, [
    sprite-part < #01, #00, #03, #00, #26, #$4002 >   ;00
    sprite-part < #01, #02, #01, #0B, #1B, #$4024 >   ;01
    sprite-part < #01, #02, #01, #1B, #0B, #$404E >   ;02
    sprite-part < #01, #03, #00, #26, #00, #$400E >   ;03
  ] >
]

sprite_group_14874D [
  sprite-group < #09, #09, #30, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #04, [
    sprite-part < #01, #02, #00, #00, #28, #$4002 >   ;00
    sprite-part < #01, #00, #02, #0A, #1E, #$4024 >   ;01
    sprite-part < #01, #00, #02, #1A, #0E, #$4044 >   ;02
    sprite-part < #01, #01, #01, #28, #00, #$400E >   ;03
  ] >
]

sprite_group_148776 [
  sprite-group < #09, #09, #31, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #04, [
    sprite-part < #01, #02, #00, #00, #29, #$4002 >   ;00
    sprite-part < #01, #00, #02, #0A, #1F, #$4024 >   ;01
    sprite-part < #01, #00, #02, #1A, #0F, #$4044 >   ;02
    sprite-part < #01, #01, #01, #29, #00, #$400E >   ;03
  ] >
]

sprite_group_14879F [
  sprite-group < #09, #09, #32, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #04, [
    sprite-part < #01, #02, #00, #00, #2A, #$4002 >   ;00
    sprite-part < #01, #00, #02, #0A, #20, #$4024 >   ;01
    sprite-part < #01, #00, #02, #1A, #10, #$4044 >   ;02
    sprite-part < #01, #01, #01, #2A, #00, #$400E >   ;03
  ] >
]

sprite_group_1487C8 [
  sprite-group < #09, #09, #33, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #04, [
    sprite-part < #01, #02, #00, #00, #2B, #$4002 >   ;00
    sprite-part < #01, #00, #02, #0A, #21, #$4024 >   ;01
    sprite-part < #01, #00, #02, #1A, #11, #$4044 >   ;02
    sprite-part < #01, #01, #01, #2B, #00, #$400E >   ;03
  ] >
]

sprite_group_1487F1 [
  sprite-group < #10, #10, #2C, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #00, #10, #0A, #1A, #$0006 >   ;00
    sprite-part < #01, #10, #00, #0A, #1A, #$0008 >   ;01
    sprite-part < #01, #00, #10, #1A, #0A, #$0120 >   ;02
    sprite-part < #01, #10, #00, #1A, #0A, #$0122 >   ;03
    sprite-part < #01, #08, #08, #00, #24, #$0004 >   ;04
    sprite-part < #01, #08, #08, #24, #00, #$000E >   ;05
  ] >
]

sprite_group_148828 [
  sprite-group < #10, #10, #30, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #00, #10, #0A, #1E, #$0006 >   ;00
    sprite-part < #01, #10, #00, #0A, #1E, #$0008 >   ;01
    sprite-part < #01, #00, #10, #1A, #0E, #$0026 >   ;02
    sprite-part < #01, #10, #00, #1A, #0E, #$0028 >   ;03
    sprite-part < #01, #08, #08, #00, #28, #$0004 >   ;04
    sprite-part < #01, #08, #08, #28, #00, #$000E >   ;05
  ] >
]

sprite_group_14885F [
  sprite-group < #10, #10, #31, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #00, #10, #0A, #1F, #$0006 >   ;00
    sprite-part < #01, #10, #00, #0A, #1F, #$0008 >   ;01
    sprite-part < #01, #00, #10, #1A, #0F, #$0026 >   ;02
    sprite-part < #01, #10, #00, #1A, #0F, #$0028 >   ;03
    sprite-part < #01, #08, #08, #00, #29, #$0004 >   ;04
    sprite-part < #01, #08, #08, #29, #00, #$000E >   ;05
  ] >
]

sprite_group_148896 [
  sprite-group < #10, #10, #32, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #00, #10, #0A, #20, #$0006 >   ;00
    sprite-part < #01, #10, #00, #0A, #20, #$0008 >   ;01
    sprite-part < #01, #00, #10, #1A, #10, #$0026 >   ;02
    sprite-part < #01, #10, #00, #1A, #10, #$0028 >   ;03
    sprite-part < #01, #08, #08, #00, #2A, #$0004 >   ;04
    sprite-part < #01, #08, #08, #2A, #00, #$000E >   ;05
  ] >
]

sprite_group_1488CD [
  sprite-group < #10, #10, #33, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #00, #10, #0A, #21, #$0006 >   ;00
    sprite-part < #01, #10, #00, #0A, #21, #$0008 >   ;01
    sprite-part < #01, #00, #10, #1A, #11, #$0026 >   ;02
    sprite-part < #01, #10, #00, #1A, #11, #$0028 >   ;03
    sprite-part < #01, #08, #08, #00, #2B, #$0004 >   ;04
    sprite-part < #01, #08, #08, #2B, #00, #$000E >   ;05
  ] >
]

sprite_group_148904 [
  sprite-group < #10, #10, #29, #07, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #06, #0A, #00, #20, #$0000 >   ;00
    sprite-part < #01, #10, #00, #01, #1F, #$0062 >   ;01
    sprite-part < #01, #00, #10, #11, #0F, #$0080 >   ;02
    sprite-part < #01, #10, #00, #11, #0F, #$0082 >   ;03
    sprite-part < #01, #08, #08, #20, #00, #$000E >   ;04
    sprite-part < #01, #00, #10, #01, #1F, #$0060 >   ;05
  ] >
]

sprite_group_14893B [
  sprite-group < #10, #10, #28, #07, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #06, #0A, #00, #1F, #$0000 >   ;00
    sprite-part < #01, #00, #10, #01, #1E, #$0060 >   ;01
    sprite-part < #01, #10, #00, #01, #1E, #$0062 >   ;02
    sprite-part < #01, #00, #10, #11, #0E, #$0080 >   ;03
    sprite-part < #01, #10, #00, #11, #0E, #$0082 >   ;04
    sprite-part < #01, #08, #08, #1F, #00, #$000E >   ;05
  ] >
]

sprite_group_148972 [
  sprite-group < #10, #10, #27, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #06, #0A, #00, #1F, #$0000 >   ;00
    sprite-part < #01, #00, #10, #01, #1E, #$0060 >   ;01
    sprite-part < #01, #10, #00, #01, #1E, #$0062 >   ;02
    sprite-part < #01, #00, #10, #11, #0E, #$0080 >   ;03
    sprite-part < #01, #10, #00, #11, #0E, #$0082 >   ;04
    sprite-part < #01, #08, #08, #1F, #00, #$000E >   ;05
  ] >
]

sprite_group_1489A9 [
  sprite-group < #10, #10, #26, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #06, #0A, #00, #1E, #$0000 >   ;00
    sprite-part < #01, #00, #10, #01, #1D, #$0060 >   ;01
    sprite-part < #01, #10, #00, #01, #1D, #$0062 >   ;02
    sprite-part < #01, #00, #10, #11, #0D, #$0080 >   ;03
    sprite-part < #01, #10, #00, #11, #0D, #$0082 >   ;04
    sprite-part < #01, #08, #08, #1E, #00, #$000E >   ;05
  ] >
]

sprite_group_1489E0 [
  sprite-group < #10, #10, #27, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #06, #0A, #00, #1F, #$0000 >   ;00
    sprite-part < #01, #00, #10, #01, #1E, #$0060 >   ;01
    sprite-part < #01, #10, #00, #01, #1E, #$0062 >   ;02
    sprite-part < #01, #00, #10, #11, #0E, #$0080 >   ;03
    sprite-part < #01, #10, #00, #11, #0E, #$0082 >   ;04
    sprite-part < #01, #08, #08, #1F, #00, #$000E >   ;05
  ] >
]

sprite_group_148A17 [
  sprite-group < #10, #10, #28, #07, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #06, #0A, #00, #1F, #$0000 >   ;00
    sprite-part < #01, #00, #10, #01, #1E, #$0060 >   ;01
    sprite-part < #01, #10, #00, #01, #1E, #$0062 >   ;02
    sprite-part < #01, #00, #10, #11, #0E, #$0080 >   ;03
    sprite-part < #01, #10, #00, #11, #0E, #$0082 >   ;04
    sprite-part < #01, #08, #08, #1F, #00, #$000E >   ;05
  ] >
]

sprite_group_148A4E [
  sprite-group < #18, #10, #2A, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #07, [
    sprite-part < #01, #03, #15, #00, #22, #$0002 >   ;00
    sprite-part < #01, #00, #18, #02, #20, #$0064 >   ;01
    sprite-part < #01, #10, #08, #02, #20, #$0066 >   ;02
    sprite-part < #01, #00, #18, #12, #10, #$0084 >   ;03
    sprite-part < #01, #10, #08, #12, #10, #$0086 >   ;04
    sprite-part < #00, #20, #00, #1D, #0D, #$0098 >   ;05
    sprite-part < #01, #10, #08, #22, #00, #$000E >   ;06
  ] >
]

sprite_group_148A8C [
  sprite-group < #19, #0F, #29, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #07, [
    sprite-part < #01, #03, #15, #00, #21, #$0002 >   ;00
    sprite-part < #01, #00, #18, #02, #1F, #$0064 >   ;01
    sprite-part < #01, #10, #08, #02, #1F, #$0066 >   ;02
    sprite-part < #01, #00, #18, #12, #0F, #$0084 >   ;03
    sprite-part < #01, #10, #08, #12, #0F, #$0086 >   ;04
    sprite-part < #00, #20, #00, #1D, #0C, #$0098 >   ;05
    sprite-part < #01, #10, #08, #21, #00, #$000E >   ;06
  ] >
]

sprite_group_148ACA [
  sprite-group < #1A, #0E, #28, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #07, [
    sprite-part < #01, #03, #15, #00, #20, #$0002 >   ;00
    sprite-part < #01, #00, #18, #02, #1E, #$0064 >   ;01
    sprite-part < #01, #10, #08, #02, #1E, #$0066 >   ;02
    sprite-part < #01, #00, #18, #12, #0E, #$0084 >   ;03
    sprite-part < #01, #10, #08, #12, #0E, #$0086 >   ;04
    sprite-part < #00, #20, #00, #1D, #0B, #$0098 >   ;05
    sprite-part < #01, #10, #08, #20, #00, #$000E >   ;06
  ] >
]

sprite_group_148B08 [
  sprite-group < #1B, #0D, #27, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #07, [
    sprite-part < #01, #03, #15, #00, #1F, #$0002 >   ;00
    sprite-part < #01, #00, #18, #02, #1D, #$0064 >   ;01
    sprite-part < #01, #10, #08, #02, #1D, #$0066 >   ;02
    sprite-part < #01, #00, #18, #12, #0D, #$0084 >   ;03
    sprite-part < #01, #10, #08, #12, #0D, #$0086 >   ;04
    sprite-part < #00, #20, #00, #1D, #0A, #$0098 >   ;05
    sprite-part < #01, #10, #08, #1F, #00, #$000E >   ;06
  ] >
]

sprite_group_148B46 [
  sprite-group < #1A, #0E, #28, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #07, [
    sprite-part < #01, #03, #15, #00, #20, #$0002 >   ;00
    sprite-part < #01, #00, #18, #02, #1E, #$0064 >   ;01
    sprite-part < #01, #10, #08, #02, #1E, #$0066 >   ;02
    sprite-part < #01, #00, #18, #12, #0E, #$0084 >   ;03
    sprite-part < #01, #10, #08, #12, #0E, #$0086 >   ;04
    sprite-part < #00, #20, #00, #1D, #0B, #$0098 >   ;05
    sprite-part < #01, #10, #08, #20, #00, #$000E >   ;06
  ] >
]

sprite_group_148B84 [
  sprite-group < #19, #0F, #29, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #07, [
    sprite-part < #01, #03, #15, #00, #21, #$0002 >   ;00
    sprite-part < #01, #00, #18, #02, #1F, #$0064 >   ;01
    sprite-part < #01, #10, #08, #02, #1F, #$0066 >   ;02
    sprite-part < #01, #00, #18, #12, #0F, #$0084 >   ;03
    sprite-part < #01, #10, #08, #12, #0F, #$0086 >   ;04
    sprite-part < #00, #20, #00, #1D, #0C, #$0098 >   ;05
    sprite-part < #01, #10, #08, #21, #00, #$000E >   ;06
  ] >
]

sprite_group_148BC2 [
  sprite-group < #10, #18, #2A, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #07, [
    sprite-part < #01, #15, #03, #00, #22, #$4002 >   ;00
    sprite-part < #01, #18, #00, #02, #20, #$4064 >   ;01
    sprite-part < #01, #08, #10, #02, #20, #$4066 >   ;02
    sprite-part < #01, #18, #00, #12, #10, #$4084 >   ;03
    sprite-part < #01, #08, #10, #12, #10, #$4086 >   ;04
    sprite-part < #00, #00, #20, #1D, #0D, #$4098 >   ;05
    sprite-part < #01, #08, #10, #22, #00, #$400E >   ;06
  ] >
]

sprite_group_148C00 [
  sprite-group < #0F, #19, #29, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #07, [
    sprite-part < #01, #15, #03, #00, #21, #$4002 >   ;00
    sprite-part < #01, #18, #00, #02, #1F, #$4064 >   ;01
    sprite-part < #01, #08, #10, #02, #1F, #$4066 >   ;02
    sprite-part < #01, #18, #00, #12, #0F, #$4084 >   ;03
    sprite-part < #01, #08, #10, #12, #0F, #$4086 >   ;04
    sprite-part < #00, #00, #20, #1D, #0C, #$4098 >   ;05
    sprite-part < #01, #08, #10, #21, #00, #$400E >   ;06
  ] >
]

sprite_group_148C3E [
  sprite-group < #0E, #1A, #28, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #07, [
    sprite-part < #01, #15, #03, #00, #20, #$4002 >   ;00
    sprite-part < #01, #18, #00, #02, #1E, #$4064 >   ;01
    sprite-part < #01, #08, #10, #02, #1E, #$4066 >   ;02
    sprite-part < #01, #18, #00, #12, #0E, #$4084 >   ;03
    sprite-part < #01, #08, #10, #12, #0E, #$4086 >   ;04
    sprite-part < #00, #00, #20, #1D, #0B, #$4098 >   ;05
    sprite-part < #01, #08, #10, #20, #00, #$400E >   ;06
  ] >
]

sprite_group_148C7C [
  sprite-group < #0D, #1B, #27, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #07, [
    sprite-part < #01, #15, #03, #00, #1F, #$4002 >   ;00
    sprite-part < #01, #18, #00, #02, #1D, #$4064 >   ;01
    sprite-part < #01, #08, #10, #02, #1D, #$4066 >   ;02
    sprite-part < #01, #18, #00, #12, #0D, #$4084 >   ;03
    sprite-part < #01, #08, #10, #12, #0D, #$4086 >   ;04
    sprite-part < #00, #00, #20, #1D, #0A, #$4098 >   ;05
    sprite-part < #01, #08, #10, #1F, #00, #$400E >   ;06
  ] >
]

sprite_group_148CBA [
  sprite-group < #10, #10, #30, #07, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #00, #10, #09, #1E, #$000A >   ;00
    sprite-part < #01, #08, #08, #27, #00, #$000E >   ;01
    sprite-part < #01, #10, #00, #09, #1E, #$000C >   ;02
    sprite-part < #01, #09, #07, #00, #27, #$0004 >   ;03
    sprite-part < #01, #00, #10, #19, #0E, #$002A >   ;04
    sprite-part < #01, #10, #00, #19, #0E, #$002C >   ;05
  ] >
]

sprite_group_148CF1 [
  sprite-group < #10, #10, #2F, #07, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #00, #10, #09, #1D, #$000A >   ;00
    sprite-part < #01, #08, #08, #26, #00, #$000E >   ;01
    sprite-part < #01, #10, #00, #09, #1D, #$000C >   ;02
    sprite-part < #01, #09, #07, #00, #26, #$0004 >   ;03
    sprite-part < #01, #00, #10, #19, #0D, #$002A >   ;04
    sprite-part < #01, #10, #00, #19, #0D, #$002C >   ;05
  ] >
]

sprite_group_148D28 [
  sprite-group < #10, #10, #2E, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #00, #10, #09, #1D, #$000A >   ;00
    sprite-part < #01, #08, #08, #26, #00, #$000E >   ;01
    sprite-part < #01, #10, #00, #09, #1D, #$000C >   ;02
    sprite-part < #01, #09, #07, #00, #26, #$0004 >   ;03
    sprite-part < #01, #00, #10, #19, #0D, #$002A >   ;04
    sprite-part < #01, #10, #00, #19, #0D, #$002C >   ;05
  ] >
]

sprite_group_148D5F [
  sprite-group < #10, #10, #2D, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #00, #10, #09, #1C, #$000A >   ;00
    sprite-part < #01, #10, #00, #09, #1C, #$000C >   ;01
    sprite-part < #01, #09, #07, #00, #25, #$0004 >   ;02
    sprite-part < #01, #00, #10, #19, #0C, #$002A >   ;03
    sprite-part < #01, #10, #00, #19, #0C, #$002C >   ;04
    sprite-part < #01, #08, #08, #25, #00, #$000E >   ;05
  ] >
]

sprite_group_148D96 [
  sprite-group < #10, #10, #2E, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #08, #08, #00, #26, #$0000 >   ;00
    sprite-part < #01, #00, #10, #0B, #1B, #$0020 >   ;01
    sprite-part < #01, #10, #00, #0B, #1B, #$0022 >   ;02
    sprite-part < #01, #00, #10, #1B, #0B, #$0100 >   ;03
    sprite-part < #01, #10, #00, #1B, #0B, #$0102 >   ;04
    sprite-part < #01, #08, #08, #26, #00, #$000E >   ;05
  ] >
]

sprite_group_148DCD [
  sprite-group < #10, #10, #32, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #05, [
    sprite-part < #01, #08, #08, #00, #22, #$4000 >   ;00
    sprite-part < #01, #10, #00, #0B, #17, #$4020 >   ;01
    sprite-part < #01, #00, #10, #0B, #17, #$4022 >   ;02
    sprite-part < #01, #10, #00, #1B, #07, #$4040 >   ;03
    sprite-part < #01, #00, #10, #1B, #07, #$4042 >   ;04
  ] >
]

sprite_group_148DFD [
  sprite-group < #10, #10, #29, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #05, [
    sprite-part < #01, #06, #0A, #00, #19, #$002E >   ;00
    sprite-part < #01, #00, #10, #01, #18, #$0060 >   ;01
    sprite-part < #01, #10, #00, #01, #18, #$0062 >   ;02
    sprite-part < #01, #00, #10, #11, #08, #$0080 >   ;03
    sprite-part < #01, #10, #00, #11, #08, #$0082 >   ;04
  ] >
]

sprite_group_148E2D [
  sprite-group < #10, #10, #1F, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #05, [
    sprite-part < #01, #08, #08, #17, #00, #$002E >   ;00
    sprite-part < #01, #10, #00, #10, #07, #$C00A >   ;01
    sprite-part < #01, #00, #10, #10, #07, #$C00C >   ;02
    sprite-part < #01, #10, #00, #00, #17, #$C02A >   ;03
    sprite-part < #01, #00, #10, #00, #17, #$C02C >   ;04
  ] >
]

sprite_group_148E5D [
  sprite-group < #10, #10, #28, #10, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #08, #08, #28, #00, #$002E >   ;00
    sprite-part < #01, #00, #10, #20, #08, #$00AC >   ;01
    sprite-part < #01, #10, #00, #20, #08, #$00AE >   ;02
    sprite-part < #01, #00, #10, #10, #18, #$008C >   ;03
    sprite-part < #01, #10, #00, #10, #18, #$008E >   ;04
    sprite-part < #01, #08, #08, #00, #28, #$006E >   ;05
  ] >
]

sprite_group_148E94 [
  sprite-group < #10, #10, #1E, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #04, [
    sprite-part < #01, #00, #10, #00, #0E, #$0048 >   ;00
    sprite-part < #01, #10, #00, #08, #06, #$4058 >   ;01
    sprite-part < #01, #10, #00, #00, #0E, #$4048 >   ;02
    sprite-part < #01, #00, #10, #08, #06, #$0058 >   ;03
  ] >
]

sprite_group_148EBD [
  sprite-group < #0E, #0E, #1B, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #04, [
    sprite-part < #01, #00, #0C, #00, #0B, #$0048 >   ;00
    sprite-part < #01, #0C, #00, #08, #03, #$4058 >   ;01
    sprite-part < #01, #0C, #00, #00, #0B, #$4048 >   ;02
    sprite-part < #01, #00, #0C, #08, #03, #$0058 >   ;03
  ] >
]

sprite_group_148EE6 [
  sprite-group < #18, #18, #18, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #0A, [
    sprite-part < #01, #20, #00, #08, #00, #$03A6 >   ;00
    sprite-part < #01, #00, #20, #05, #03, #$03A6 >   ;01
    sprite-part < #00, #10, #18, #0E, #02, #$00D8 >   ;02
    sprite-part < #00, #18, #10, #0E, #02, #$40D8 >   ;03
    sprite-part < #00, #0E, #1A, #0E, #02, #$00D7 >   ;04
    sprite-part < #00, #1B, #0D, #0E, #02, #$40D7 >   ;05
    sprite-part < #00, #07, #21, #0E, #02, #$00D6 >   ;06
    sprite-part < #00, #22, #06, #0E, #02, #$40D6 >   ;07
    sprite-part < #01, #18, #08, #00, #08, #$03A6 >   ;08
    sprite-part < #01, #08, #18, #02, #06, #$03A6 >   ;09
  ] >
]

sprite_group_148F39 [
  sprite-group < #1B, #18, #1F, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #0C, [
    sprite-part < #01, #16, #0D, #04, #0B, #$03A6 >   ;00
    sprite-part < #00, #13, #18, #15, #02, #$00D8 >   ;01
    sprite-part < #00, #1B, #10, #15, #02, #$40D8 >   ;02
    sprite-part < #00, #0B, #20, #15, #02, #$00D7 >   ;03
    sprite-part < #00, #23, #08, #15, #02, #$40D7 >   ;04
    sprite-part < #00, #03, #28, #15, #02, #$00D6 >   ;05
    sprite-part < #00, #2B, #00, #15, #02, #$40D6 >   ;06
    sprite-part < #01, #0B, #18, #00, #0F, #$03A6 >   ;07
    sprite-part < #01, #00, #23, #07, #08, #$03D8 >   ;08
    sprite-part < #01, #08, #1B, #07, #08, #$03D9 >   ;09
    sprite-part < #01, #1B, #08, #07, #08, #$03D8 >   ;0A
    sprite-part < #01, #23, #00, #07, #08, #$03D9 >   ;0B
  ] >
]

sprite_group_148F9A [
  sprite-group < #1C, #1E, #28, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #0E, [
    sprite-part < #01, #00, #2A, #15, #03, #$03E0 >   ;00
    sprite-part < #01, #10, #1A, #14, #04, #$03E2 >   ;01
    sprite-part < #00, #15, #1D, #1E, #02, #$00D8 >   ;02
    sprite-part < #00, #1C, #16, #1E, #02, #$40D8 >   ;03
    sprite-part < #00, #0D, #25, #1E, #02, #$00D7 >   ;04
    sprite-part < #01, #19, #11, #02, #16, #$83E0 >   ;05
    sprite-part < #00, #23, #0F, #1E, #02, #$40D7 >   ;06
    sprite-part < #00, #05, #2D, #1E, #02, #$00D6 >   ;07
    sprite-part < #00, #2B, #07, #1E, #02, #$40D6 >   ;08
    sprite-part < #01, #00, #2A, #05, #13, #$03C0 >   ;09
    sprite-part < #01, #10, #1A, #04, #14, #$03C2 >   ;0A
    sprite-part < #01, #29, #01, #00, #18, #$83E2 >   ;0B
    sprite-part < #01, #1A, #10, #12, #06, #$83C0 >   ;0C
    sprite-part < #01, #2A, #00, #10, #08, #$83C2 >   ;0D
  ] >
]

sprite_group_149009 [
  sprite-group < #1D, #1E, #2B, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #0E, [
    sprite-part < #01, #00, #2B, #15, #06, #$03E4 >   ;00
    sprite-part < #01, #10, #1B, #15, #06, #$03E6 >   ;01
    sprite-part < #00, #15, #1E, #21, #02, #$00D8 >   ;02
    sprite-part < #00, #1D, #16, #21, #02, #$40D8 >   ;03
    sprite-part < #00, #0F, #24, #21, #02, #$00D7 >   ;04
    sprite-part < #00, #23, #10, #21, #02, #$40D7 >   ;05
    sprite-part < #01, #1B, #10, #00, #1B, #$03C4 >   ;06
    sprite-part < #00, #08, #2B, #21, #02, #$00D6 >   ;07
    sprite-part < #00, #2A, #09, #21, #02, #$40D6 >   ;08
    sprite-part < #01, #00, #2B, #05, #16, #$03C4 >   ;09
    sprite-part < #01, #10, #1B, #05, #16, #$03C6 >   ;0A
    sprite-part < #01, #1B, #10, #10, #0B, #$03E4 >   ;0B
    sprite-part < #01, #2B, #00, #00, #1B, #$03C6 >   ;0C
    sprite-part < #01, #2B, #00, #10, #0B, #$03E6 >   ;0D
  ] >
]

sprite_group_149078 [
  sprite-group < #1E, #1C, #30, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #0A, [
    sprite-part < #01, #1A, #10, #10, #10, #$03E4 >   ;00
    sprite-part < #01, #10, #1A, #10, #10, #$03E6 >   ;01
    sprite-part < #01, #00, #2A, #13, #0D, #$03E4 >   ;02
    sprite-part < #01, #10, #1A, #1D, #03, #$0046 >   ;03
    sprite-part < #01, #1C, #0E, #1D, #03, #$4046 >   ;04
    sprite-part < #01, #00, #2A, #03, #1D, #$03C4 >   ;05
    sprite-part < #01, #10, #1A, #00, #20, #$03C6 >   ;06
    sprite-part < #01, #2A, #00, #02, #1E, #$03C6 >   ;07
    sprite-part < #01, #2A, #00, #12, #0E, #$03E6 >   ;08
    sprite-part < #01, #1A, #10, #00, #20, #$03C4 >   ;09
  ] >
]

sprite_group_1490CB [
  sprite-group < #1C, #19, #40, #01, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #0C, [
    sprite-part < #01, #1B, #0A, #31, #00, #$C048 >   ;00
    sprite-part < #01, #0F, #16, #30, #01, #$8048 >   ;01
    sprite-part < #01, #0F, #16, #28, #09, #$8058 >   ;02
    sprite-part < #01, #1B, #0A, #28, #09, #$C058 >   ;03
    sprite-part < #01, #07, #1E, #0F, #22, #$03A8 >   ;04
    sprite-part < #01, #00, #25, #18, #19, #$03A8 >   ;05
    sprite-part < #01, #0D, #18, #18, #19, #$03AA >   ;06
    sprite-part < #01, #1D, #08, #00, #31, #$03AA >   ;07
    sprite-part < #01, #25, #00, #08, #29, #$03A8 >   ;08
    sprite-part < #01, #1D, #08, #10, #21, #$03A8 >   ;09
    sprite-part < #01, #25, #00, #18, #19, #$03AA >   ;0A
    sprite-part < #01, #01, #24, #09, #28, #$03AA >   ;0B
  ] >
]

sprite_group_14912C [
  sprite-group < #1E, #1B, #47, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #0B, [
    sprite-part < #01, #0B, #1E, #17, #28, #$03AA >   ;00
    sprite-part < #01, #00, #29, #1F, #20, #$03AA >   ;01
    sprite-part < #01, #0F, #1A, #34, #0B, #$006C >   ;02
    sprite-part < #01, #0F, #1A, #25, #1A, #$004C >   ;03
    sprite-part < #01, #1E, #0B, #34, #0B, #$406C >   ;04
    sprite-part < #01, #16, #13, #3F, #00, #$000E >   ;05
    sprite-part < #01, #1E, #0B, #25, #1A, #$404C >   ;06
    sprite-part < #01, #04, #25, #0B, #34, #$03AA >   ;07
    sprite-part < #01, #20, #09, #00, #3F, #$03AA >   ;08
    sprite-part < #01, #29, #00, #0F, #30, #$03AA >   ;09
    sprite-part < #01, #1B, #0E, #17, #28, #$03AA >   ;0A
  ] >
]

sprite_group_149186 [
  sprite-group < #0F, #0F, #24, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #05, [
    sprite-part < #01, #00, #0E, #00, #1C, #$004C >   ;00
    sprite-part < #01, #0E, #00, #00, #1C, #$404C >   ;01
    sprite-part < #01, #00, #0E, #10, #0C, #$006C >   ;02
    sprite-part < #01, #0E, #00, #10, #0C, #$406C >   ;03
    sprite-part < #01, #07, #07, #1C, #00, #$000E >   ;04
  ] >
]

sprite_group_1491B6 [
  sprite-group < #10, #10, #2F, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #08, #08, #00, #27, #$0000 >   ;00
    sprite-part < #01, #00, #10, #0B, #1C, #$0020 >   ;01
    sprite-part < #01, #10, #00, #0B, #1C, #$0022 >   ;02
    sprite-part < #01, #00, #10, #1B, #0C, #$0040 >   ;03
    sprite-part < #01, #10, #00, #1B, #0C, #$0042 >   ;04
    sprite-part < #01, #08, #08, #27, #00, #$000E >   ;05
  ] >
]

sprite_group_1491ED [
  sprite-group < #16, #18, #10, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #09, [
    sprite-part < #01, #00, #1E, #01, #07, #$008A >   ;00
    sprite-part < #01, #06, #18, #00, #08, #$00A7 >   ;01
    sprite-part < #01, #16, #08, #00, #08, #$00A9 >   ;02
    sprite-part < #01, #1E, #00, #00, #08, #$00AA >   ;03
    sprite-part < #00, #06, #20, #10, #00, #$00C7 >   ;04
    sprite-part < #00, #0E, #18, #10, #00, #$00C8 >   ;05
    sprite-part < #00, #16, #10, #10, #00, #$00C9 >   ;06
    sprite-part < #00, #1E, #08, #10, #00, #$00CA >   ;07
    sprite-part < #00, #26, #00, #10, #00, #$00CB >   ;08
  ] >
]

sprite_group_149239 [
  sprite-group < #18, #16, #10, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #09, [
    sprite-part < #01, #1E, #00, #01, #07, #$408A >   ;00
    sprite-part < #01, #18, #06, #00, #08, #$40A7 >   ;01
    sprite-part < #01, #08, #16, #00, #08, #$40A9 >   ;02
    sprite-part < #01, #00, #1E, #00, #08, #$40AA >   ;03
    sprite-part < #00, #20, #06, #10, #00, #$40C7 >   ;04
    sprite-part < #00, #18, #0E, #10, #00, #$40C8 >   ;05
    sprite-part < #00, #10, #16, #10, #00, #$40C9 >   ;06
    sprite-part < #00, #08, #1E, #10, #00, #$40CA >   ;07
    sprite-part < #00, #00, #26, #10, #00, #$40CB >   ;08
  ] >
]

sprite_group_149285 [
  sprite-group < #0F, #11, #14, #20, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #08, #08, #00, #24, #$8004 >   ;00
    sprite-part < #01, #00, #10, #09, #1B, #$00CC >   ;01
    sprite-part < #01, #10, #00, #09, #1B, #$00CE >   ;02
    sprite-part < #01, #00, #10, #19, #0B, #$00EC >   ;03
    sprite-part < #01, #10, #00, #19, #0B, #$00EE >   ;04
    sprite-part < #01, #07, #09, #24, #00, #$806E >   ;05
  ] >
]

sprite_group_1492BC [
  sprite-group < #10, #11, #2F, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #0B, #06, #00, #27, #$0002 >   ;00
    sprite-part < #01, #11, #00, #0A, #1D, #$4020 >   ;01
    sprite-part < #01, #08, #09, #27, #00, #$400E >   ;02
    sprite-part < #01, #01, #10, #0A, #1D, #$4022 >   ;03
    sprite-part < #01, #10, #01, #1A, #0D, #$4040 >   ;04
    sprite-part < #01, #00, #11, #1A, #0D, #$4042 >   ;05
  ] >
]

sprite_group_1492F3 [
  sprite-group < #10, #11, #30, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #0B, #06, #00, #28, #$0002 >   ;00
    sprite-part < #01, #11, #00, #0A, #1E, #$4020 >   ;01
    sprite-part < #01, #08, #09, #28, #00, #$400E >   ;02
    sprite-part < #01, #01, #10, #0A, #1E, #$4022 >   ;03
    sprite-part < #01, #10, #01, #1A, #0E, #$4040 >   ;04
    sprite-part < #01, #00, #11, #1A, #0E, #$4042 >   ;05
  ] >
]

sprite_group_14932A [
  sprite-group < #10, #11, #31, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #0B, #06, #00, #29, #$0002 >   ;00
    sprite-part < #01, #11, #00, #0A, #1F, #$4020 >   ;01
    sprite-part < #01, #08, #09, #29, #00, #$400E >   ;02
    sprite-part < #01, #01, #10, #0A, #1F, #$4022 >   ;03
    sprite-part < #01, #10, #01, #1A, #0F, #$4040 >   ;04
    sprite-part < #01, #00, #11, #1A, #0F, #$4042 >   ;05
  ] >
]

sprite_group_149361 [
  sprite-group < #10, #11, #32, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #0B, #06, #00, #2A, #$0002 >   ;00
    sprite-part < #01, #11, #00, #0A, #20, #$4020 >   ;01
    sprite-part < #01, #08, #09, #2A, #00, #$400E >   ;02
    sprite-part < #01, #01, #10, #0A, #20, #$4022 >   ;03
    sprite-part < #01, #10, #01, #1A, #10, #$4040 >   ;04
    sprite-part < #01, #00, #11, #1A, #10, #$4042 >   ;05
  ] >
]

sprite_group_149398 [
  sprite-group < #11, #10, #2F, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #06, #0B, #00, #27, #$4002 >   ;00
    sprite-part < #01, #00, #11, #0A, #1D, #$0020 >   ;01
    sprite-part < #01, #09, #08, #27, #00, #$000E >   ;02
    sprite-part < #01, #10, #01, #0A, #1D, #$0022 >   ;03
    sprite-part < #01, #01, #10, #1A, #0D, #$0040 >   ;04
    sprite-part < #01, #11, #00, #1A, #0D, #$0042 >   ;05
  ] >
]

sprite_group_1493CF [
  sprite-group < #11, #10, #30, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #06, #0B, #00, #28, #$4002 >   ;00
    sprite-part < #01, #00, #11, #0A, #1E, #$0020 >   ;01
    sprite-part < #01, #09, #08, #28, #00, #$000E >   ;02
    sprite-part < #01, #10, #01, #0A, #1E, #$0022 >   ;03
    sprite-part < #01, #01, #10, #1A, #0E, #$0040 >   ;04
    sprite-part < #01, #11, #00, #1A, #0E, #$0042 >   ;05
  ] >
]

sprite_group_149406 [
  sprite-group < #11, #10, #31, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #06, #0B, #00, #29, #$4002 >   ;00
    sprite-part < #01, #00, #11, #0A, #1F, #$0020 >   ;01
    sprite-part < #01, #09, #08, #29, #00, #$000E >   ;02
    sprite-part < #01, #10, #01, #0A, #1F, #$0022 >   ;03
    sprite-part < #01, #01, #10, #1A, #0F, #$0040 >   ;04
    sprite-part < #01, #11, #00, #1A, #0F, #$0042 >   ;05
  ] >
]

sprite_group_14943D [
  sprite-group < #11, #10, #32, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #06, #0B, #00, #2A, #$4002 >   ;00
    sprite-part < #01, #00, #11, #0A, #20, #$0020 >   ;01
    sprite-part < #01, #09, #08, #2A, #00, #$000E >   ;02
    sprite-part < #01, #10, #01, #0A, #20, #$0022 >   ;03
    sprite-part < #01, #01, #10, #1A, #10, #$0040 >   ;04
    sprite-part < #01, #11, #00, #1A, #10, #$0042 >   ;05
  ] >
]

sprite_group_149474 [
  sprite-group < #10, #10, #2C, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #00, #10, #0A, #1A, #$0006 >   ;00
    sprite-part < #01, #10, #00, #0A, #1A, #$0008 >   ;01
    sprite-part < #01, #00, #10, #1A, #0A, #$0120 >   ;02
    sprite-part < #01, #10, #00, #1A, #0A, #$0122 >   ;03
    sprite-part < #01, #08, #08, #00, #24, #$0004 >   ;04
    sprite-part < #01, #08, #08, #24, #00, #$000E >   ;05
  ] >
]

sprite_group_1494AB [
  sprite-group < #10, #10, #2D, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #10, #00, #0A, #1B, #$4006 >   ;00
    sprite-part < #01, #00, #10, #0A, #1B, #$4008 >   ;01
    sprite-part < #01, #10, #00, #1A, #0B, #$4026 >   ;02
    sprite-part < #01, #00, #10, #1A, #0B, #$4028 >   ;03
    sprite-part < #01, #08, #08, #00, #25, #$0004 >   ;04
    sprite-part < #01, #08, #08, #25, #00, #$000E >   ;05
  ] >
]

sprite_group_1494E2 [
  sprite-group < #10, #10, #2F, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #00, #10, #19, #0E, #$0160 >   ;00
    sprite-part < #01, #10, #00, #19, #0E, #$0162 >   ;01
    sprite-part < #01, #08, #08, #27, #00, #$000E >   ;02
    sprite-part < #01, #00, #10, #0A, #1D, #$000A >   ;03
    sprite-part < #01, #10, #00, #0A, #1D, #$000C >   ;04
    sprite-part < #01, #08, #08, #00, #27, #$0004 >   ;05
  ] >
]

sprite_group_149519 [
  sprite-group < #10, #10, #32, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #08, #08, #2A, #00, #$000E >   ;00
    sprite-part < #01, #00, #10, #1A, #10, #$002A >   ;01
    sprite-part < #01, #10, #00, #1A, #10, #$002C >   ;02
    sprite-part < #01, #00, #10, #0A, #20, #$000A >   ;03
    sprite-part < #01, #10, #00, #0A, #20, #$000C >   ;04
    sprite-part < #01, #08, #08, #00, #2A, #$0004 >   ;05
  ] >
]

sprite_group_149550 [
  sprite-group < #10, #10, #22, #01, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #05, [
    sprite-part < #01, #07, #09, #00, #13, #$002E >   ;00
    sprite-part < #01, #00, #10, #03, #10, #$0060 >   ;01
    sprite-part < #01, #10, #00, #03, #10, #$0062 >   ;02
    sprite-part < #01, #00, #10, #13, #00, #$0080 >   ;03
    sprite-part < #01, #10, #00, #13, #00, #$0082 >   ;04
  ] >
]

sprite_group_149580 [
  sprite-group < #10, #10, #1D, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #05, [
    sprite-part < #01, #07, #09, #15, #00, #$4004 >   ;00
    sprite-part < #01, #10, #00, #00, #15, #$C02A >   ;01
    sprite-part < #01, #00, #10, #00, #15, #$C02C >   ;02
    sprite-part < #01, #10, #00, #10, #05, #$C00A >   ;03
    sprite-part < #01, #00, #10, #10, #05, #$C00C >   ;04
  ] >
]

sprite_group_1495B0 [
  sprite-group < #10, #10, #2F, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #05, [
    sprite-part < #01, #08, #08, #00, #1F, #$0000 >   ;00
    sprite-part < #01, #00, #10, #0A, #15, #$0020 >   ;01
    sprite-part < #01, #10, #00, #0A, #15, #$0022 >   ;02
    sprite-part < #01, #00, #10, #1A, #05, #$0040 >   ;03
    sprite-part < #01, #10, #00, #1A, #05, #$0042 >   ;04
  ] >
]

sprite_group_1495E0 [
  sprite-group < #10, #10, #2C, #01, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #07, #09, #00, #1D, #$0000 >   ;00
    sprite-part < #01, #0F, #01, #03, #1A, #$0062 >   ;01
    sprite-part < #01, #10, #00, #12, #0B, #$00C2 >   ;02
    sprite-part < #01, #08, #08, #1D, #00, #$00D1 >   ;03
    sprite-part < #01, #00, #10, #03, #1A, #$0182 >   ;04
    sprite-part < #01, #00, #10, #13, #0A, #$01A2 >   ;05
  ] >
]

sprite_group_149617 [
  sprite-group < #10, #10, #2B, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #05, [
    sprite-part < #01, #10, #00, #0A, #11, #$4006 >   ;00
    sprite-part < #01, #00, #10, #0A, #11, #$4008 >   ;01
    sprite-part < #01, #10, #00, #1A, #01, #$4026 >   ;02
    sprite-part < #01, #00, #10, #1A, #01, #$4028 >   ;03
    sprite-part < #01, #08, #08, #00, #1B, #$0004 >   ;04
  ] >
]

sprite_group_149647 [
  sprite-group < #10, #10, #2E, #0B, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #09, #07, #00, #29, #$8004 >   ;00
    sprite-part < #01, #00, #10, #09, #20, #$80AC >   ;01
    sprite-part < #01, #10, #00, #09, #20, #$80AE >   ;02
    sprite-part < #01, #00, #10, #19, #10, #$808C >   ;03
    sprite-part < #01, #10, #00, #19, #10, #$808E >   ;04
    sprite-part < #01, #08, #08, #29, #00, #$806E >   ;05
  ] >
]

sprite_group_14967E [
  sprite-group < #10, #10, #2D, #0C, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #09, #07, #00, #29, #$8004 >   ;00
    sprite-part < #01, #00, #10, #09, #20, #$80AC >   ;01
    sprite-part < #01, #10, #00, #09, #20, #$80AE >   ;02
    sprite-part < #01, #00, #10, #19, #10, #$808C >   ;03
    sprite-part < #01, #10, #00, #19, #10, #$808E >   ;04
    sprite-part < #01, #08, #08, #29, #00, #$806E >   ;05
  ] >
]

sprite_group_1496B5 [
  sprite-group < #10, #10, #2C, #0D, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #09, #07, #00, #29, #$8004 >   ;00
    sprite-part < #01, #00, #10, #09, #20, #$80AC >   ;01
    sprite-part < #01, #10, #00, #09, #20, #$80AE >   ;02
    sprite-part < #01, #00, #10, #19, #10, #$808C >   ;03
    sprite-part < #01, #10, #00, #19, #10, #$808E >   ;04
    sprite-part < #01, #08, #08, #29, #00, #$806E >   ;05
  ] >
]

sprite_group_1496EC [
  sprite-group < #10, #10, #2B, #0E, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #09, #07, #00, #29, #$8004 >   ;00
    sprite-part < #01, #00, #10, #09, #20, #$80AC >   ;01
    sprite-part < #01, #10, #00, #09, #20, #$80AE >   ;02
    sprite-part < #01, #00, #10, #19, #10, #$808C >   ;03
    sprite-part < #01, #10, #00, #19, #10, #$808E >   ;04
    sprite-part < #01, #08, #08, #29, #00, #$806E >   ;05
  ] >
]

sprite_group_149723 [
  sprite-group < #10, #10, #36, #03, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #09, #07, #29, #00, #$0004 >   ;00
    sprite-part < #01, #00, #10, #20, #09, #$00AC >   ;01
    sprite-part < #01, #10, #00, #20, #09, #$00AE >   ;02
    sprite-part < #01, #00, #10, #10, #19, #$008C >   ;03
    sprite-part < #01, #10, #00, #10, #19, #$008E >   ;04
    sprite-part < #01, #08, #08, #00, #29, #$006E >   ;05
  ] >
]

sprite_group_14975A [
  sprite-group < #10, #10, #35, #04, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #09, #07, #29, #00, #$0004 >   ;00
    sprite-part < #01, #00, #10, #20, #09, #$00AC >   ;01
    sprite-part < #01, #10, #00, #20, #09, #$00AE >   ;02
    sprite-part < #01, #00, #10, #10, #19, #$008C >   ;03
    sprite-part < #01, #10, #00, #10, #19, #$008E >   ;04
    sprite-part < #01, #08, #08, #00, #29, #$006E >   ;05
  ] >
]

sprite_group_149791 [
  sprite-group < #10, #10, #34, #05, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #09, #07, #29, #00, #$0004 >   ;00
    sprite-part < #01, #00, #10, #20, #09, #$00AC >   ;01
    sprite-part < #01, #10, #00, #20, #09, #$00AE >   ;02
    sprite-part < #01, #00, #10, #10, #19, #$008C >   ;03
    sprite-part < #01, #10, #00, #10, #19, #$008E >   ;04
    sprite-part < #01, #08, #08, #00, #29, #$006E >   ;05
  ] >
]

sprite_group_1497C8 [
  sprite-group < #10, #10, #32, #07, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #09, #07, #29, #00, #$0004 >   ;00
    sprite-part < #01, #00, #10, #20, #09, #$00AC >   ;01
    sprite-part < #01, #10, #00, #20, #09, #$00AE >   ;02
    sprite-part < #01, #00, #10, #10, #19, #$008C >   ;03
    sprite-part < #01, #10, #00, #10, #19, #$008E >   ;04
    sprite-part < #01, #08, #08, #00, #29, #$006E >   ;05
  ] >
]

sprite_group_1497FF [
  sprite-group < #11, #11, #29, #08, #F8, #F0, #01, #01, #F8, #17, #E0, #18, #0A, [
    sprite-part < #01, #12, #00, #10, #11, #$014A >   ;00
    sprite-part < #01, #02, #10, #11, #10, #$0148 >   ;01
    sprite-part < #01, #10, #02, #13, #0E, #$00C2 >   ;02
    sprite-part < #01, #00, #12, #13, #0E, #$00C0 >   ;03
    sprite-part < #01, #07, #0B, #00, #21, #$0000 >   ;04
    sprite-part < #01, #00, #12, #03, #1E, #$00A0 >   ;05
    sprite-part < #01, #12, #00, #00, #21, #$012A >   ;06
    sprite-part < #01, #10, #02, #03, #1E, #$0062 >   ;07
    sprite-part < #01, #08, #0A, #1B, #06, #$00D1 >   ;08
    sprite-part < #01, #09, #09, #21, #00, #$000E >   ;09
  ] >
]

sprite_group_149852 [
  sprite-group < #13, #14, #29, #08, #F8, #F0, #01, #01, #F8, #17, #EF, #18, #0C, [
    sprite-part < #01, #00, #17, #0A, #17, #$010C >   ;00
    sprite-part < #01, #17, #00, #10, #11, #$016A >   ;01
    sprite-part < #01, #17, #00, #20, #01, #$018A >   ;02
    sprite-part < #01, #07, #10, #10, #11, #$0168 >   ;03
    sprite-part < #01, #07, #10, #20, #01, #$0188 >   ;04
    sprite-part < #01, #09, #0E, #00, #21, #$0000 >   ;05
    sprite-part < #01, #02, #15, #03, #1E, #$00A0 >   ;06
    sprite-part < #01, #12, #05, #03, #1E, #$0062 >   ;07
    sprite-part < #01, #0A, #0D, #1B, #06, #$00D1 >   ;08
    sprite-part < #01, #0B, #0C, #21, #00, #$000E >   ;09
    sprite-part < #01, #02, #15, #13, #0E, #$00C0 >   ;0A
    sprite-part < #01, #12, #05, #13, #0E, #$00C2 >   ;0B
  ] >
]

sprite_group_1498B3 [
  sprite-group < #14, #16, #29, #20, #F8, #F0, #01, #01, #F6, #17, #F1, #2D, #0D, [
    sprite-part < #01, #07, #13, #19, #20, #$014C >   ;00
    sprite-part < #01, #0A, #10, #00, #39, #$0000 >   ;01
    sprite-part < #01, #17, #03, #29, #10, #$0128 >   ;02
    sprite-part < #01, #1A, #00, #39, #00, #$018E >   ;03
    sprite-part < #01, #0A, #10, #39, #00, #$018C >   ;04
    sprite-part < #01, #07, #13, #29, #10, #$016C >   ;05
    sprite-part < #01, #00, #1A, #09, #30, #$010C >   ;06
    sprite-part < #01, #03, #17, #13, #26, #$00C0 >   ;07
    sprite-part < #01, #03, #17, #03, #36, #$00A0 >   ;08
    sprite-part < #01, #13, #07, #03, #36, #$0062 >   ;09
    sprite-part < #01, #0B, #0F, #1B, #1E, #$00D1 >   ;0A
    sprite-part < #01, #0C, #0E, #21, #18, #$000E >   ;0B
    sprite-part < #01, #13, #07, #13, #26, #$00C2 >   ;0C
  ] >
]

sprite_group_14991B [
  sprite-group < #14, #0F, #29, #20, #F8, #F0, #01, #01, #F1, #15, #E9, #32, #0B, [
    sprite-part < #01, #02, #11, #19, #20, #$012E >   ;00
    sprite-part < #01, #00, #13, #09, #30, #$010C >   ;01
    sprite-part < #01, #02, #11, #29, #10, #$014E >   ;02
    sprite-part < #01, #03, #10, #13, #26, #$00C0 >   ;03
    sprite-part < #01, #0A, #09, #00, #39, #$0000 >   ;04
    sprite-part < #01, #03, #10, #03, #36, #$00A0 >   ;05
    sprite-part < #01, #13, #00, #03, #36, #$0062 >   ;06
    sprite-part < #01, #05, #0E, #39, #00, #$016E >   ;07
    sprite-part < #01, #13, #00, #13, #26, #$00C2 >   ;08
    sprite-part < #01, #0B, #08, #1B, #1E, #$00D1 >   ;09
    sprite-part < #01, #0C, #07, #21, #18, #$000E >   ;0A
  ] >
]

sprite_group_149975 [
  sprite-group < #17, #0F, #29, #11, #F8, #F0, #01, #01, #EE, #1B, #E4, #29, #0B, [
    sprite-part < #01, #01, #15, #2A, #00, #$016E >   ;00
    sprite-part < #01, #00, #16, #0A, #20, #$010E >   ;01
    sprite-part < #01, #00, #16, #21, #09, #$014E >   ;02
    sprite-part < #01, #00, #16, #15, #15, #$012E >   ;03
    sprite-part < #01, #06, #10, #13, #17, #$00C0 >   ;04
    sprite-part < #01, #0D, #09, #00, #2A, #$0000 >   ;05
    sprite-part < #01, #06, #10, #03, #27, #$00A0 >   ;06
    sprite-part < #01, #16, #00, #03, #27, #$0062 >   ;07
    sprite-part < #01, #16, #00, #13, #17, #$00C2 >   ;08
    sprite-part < #01, #0E, #08, #1B, #0F, #$00D1 >   ;09
    sprite-part < #01, #0F, #07, #21, #09, #$000E >   ;0A
  ] >
]

sprite_group_1499CF [
  sprite-group < #19, #0F, #29, #08, #F8, #F0, #01, #01, #E8, #17, #E2, #1E, #09, [
    sprite-part < #01, #00, #18, #0C, #15, #$00C4 >   ;00
    sprite-part < #01, #08, #10, #13, #0E, #$00C0 >   ;01
    sprite-part < #01, #0F, #09, #00, #21, #$0000 >   ;02
    sprite-part < #01, #08, #10, #03, #1E, #$00A0 >   ;03
    sprite-part < #01, #18, #00, #03, #1E, #$0062 >   ;04
    sprite-part < #01, #18, #00, #13, #0E, #$00C2 >   ;05
    sprite-part < #01, #10, #08, #1B, #06, #$00D1 >   ;06
    sprite-part < #01, #11, #07, #21, #00, #$000E >   ;07
    sprite-part < #01, #00, #18, #1C, #05, #$00E4 >   ;08
  ] >
]

sprite_group_149A1B [
  sprite-group < #17, #0F, #29, #08, #F8, #F0, #01, #01, #EB, #17, #E0, #18, #08, [
    sprite-part < #01, #00, #16, #06, #1B, #$00A4 >   ;00
    sprite-part < #01, #06, #10, #13, #0E, #$00C0 >   ;01
    sprite-part < #01, #0D, #09, #00, #21, #$0000 >   ;02
    sprite-part < #01, #06, #10, #03, #1E, #$00A0 >   ;03
    sprite-part < #01, #16, #00, #03, #1E, #$0062 >   ;04
    sprite-part < #01, #16, #00, #13, #0E, #$00C2 >   ;05
    sprite-part < #01, #0E, #08, #1B, #06, #$00D1 >   ;06
    sprite-part < #01, #0F, #07, #21, #00, #$000E >   ;07
  ] >
]

sprite_group_149A60 [
  sprite-group < #16, #0B, #23, #08, #F8, #F0, #01, #01, #F3, #13, #E5, #1A, #09, [
    sprite-part < #01, #10, #01, #04, #17, #$012A >   ;00
    sprite-part < #01, #11, #00, #12, #09, #$014A >   ;01
    sprite-part < #01, #06, #0B, #13, #08, #$0148 >   ;02
    sprite-part < #01, #05, #0C, #00, #1B, #$008A >   ;03
    sprite-part < #01, #00, #11, #03, #18, #$0124 >   ;04
    sprite-part < #01, #00, #11, #13, #08, #$0144 >   ;05
    sprite-part < #01, #10, #01, #03, #18, #$0126 >   ;06
    sprite-part < #01, #10, #01, #13, #08, #$0146 >   ;07
    sprite-part < #01, #0E, #03, #1B, #00, #$000E >   ;08
  ] >
]

sprite_group_149AAC [
  sprite-group < #16, #0F, #23, #08, #F8, #F0, #01, #01, #F2, #1A, #E5, #1A, #08, [
    sprite-part < #01, #15, #00, #13, #08, #$C0E6 >   ;00
    sprite-part < #01, #05, #10, #00, #1B, #$008A >   ;01
    sprite-part < #01, #05, #10, #13, #08, #$C0E8 >   ;02
    sprite-part < #01, #00, #15, #03, #18, #$0124 >   ;03
    sprite-part < #01, #00, #15, #13, #08, #$0144 >   ;04
    sprite-part < #01, #10, #05, #03, #18, #$0126 >   ;05
    sprite-part < #01, #10, #05, #13, #08, #$0146 >   ;06
    sprite-part < #01, #0E, #07, #1B, #00, #$000E >   ;07
  ] >
]

sprite_group_149AF1 [
  sprite-group < #38, #0A, #23, #0B, #F8, #F0, #01, #01, #C8, #28, #E5, #1A, #0B, [
    sprite-part < #01, #27, #0B, #00, #1E, #$008A >   ;00
    sprite-part < #01, #32, #00, #03, #1B, #$0126 >   ;01
    sprite-part < #01, #32, #00, #13, #0B, #$0146 >   ;02
    sprite-part < #01, #22, #10, #03, #1B, #$0124 >   ;03
    sprite-part < #01, #22, #10, #13, #0B, #$0144 >   ;04
    sprite-part < #01, #20, #12, #0B, #13, #$0166 >   ;05
    sprite-part < #01, #10, #22, #0B, #13, #$0164 >   ;06
    sprite-part < #01, #10, #22, #1B, #03, #$0184 >   ;07
    sprite-part < #01, #00, #32, #0E, #10, #$0180 >   ;08
    sprite-part < #01, #00, #32, #1E, #00, #$01A0 >   ;09
    sprite-part < #01, #30, #02, #1B, #03, #$000E >   ;0A
  ] >
]

sprite_group_149B4B [
  sprite-group < #3A, #0A, #23, #08, #F8, #F0, #01, #01, #C8, #28, #E5, #1A, #0A, [
    sprite-part < #01, #24, #10, #13, #08, #$0144 >   ;00
    sprite-part < #01, #29, #0B, #00, #1B, #$008A >   ;01
    sprite-part < #01, #34, #00, #03, #18, #$0126 >   ;02
    sprite-part < #01, #34, #00, #13, #08, #$0146 >   ;03
    sprite-part < #01, #32, #02, #1B, #00, #$000E >   ;04
    sprite-part < #01, #24, #10, #03, #18, #$0124 >   ;05
    sprite-part < #01, #19, #1B, #04, #17, #$0108 >   ;06
    sprite-part < #01, #0C, #28, #04, #17, #$0106 >   ;07
    sprite-part < #01, #25, #0F, #02, #19, #$012C >   ;08
    sprite-part < #01, #00, #34, #06, #15, #$0104 >   ;09
  ] >
]

sprite_group_149B9E [
  sprite-group < #32, #0A, #25, #08, #F8, #F0, #01, #01, #D1, #22, #E5, #1B, #0A, [
    sprite-part < #01, #21, #0B, #02, #1B, #$008A >   ;00
    sprite-part < #01, #2C, #00, #05, #18, #$0126 >   ;01
    sprite-part < #01, #1C, #10, #15, #08, #$0144 >   ;02
    sprite-part < #01, #2C, #00, #15, #08, #$0146 >   ;03
    sprite-part < #01, #2A, #02, #1D, #00, #$000E >   ;04
    sprite-part < #01, #1C, #10, #05, #18, #$0124 >   ;05
    sprite-part < #01, #1D, #0F, #01, #1C, #$010A >   ;06
    sprite-part < #01, #16, #16, #01, #1C, #$0108 >   ;07
    sprite-part < #01, #0D, #1F, #00, #1D, #$0106 >   ;08
    sprite-part < #01, #00, #2C, #01, #1C, #$0104 >   ;09
  ] >
]

sprite_group_149BF1 [
  sprite-group < #26, #0A, #23, #08, #F8, #F0, #01, #01, #E4, #1B, #E1, #1F, #08, [
    sprite-part < #01, #15, #0B, #00, #1B, #$008A >   ;00
    sprite-part < #01, #10, #10, #03, #18, #$0124 >   ;01
    sprite-part < #01, #20, #00, #03, #18, #$0126 >   ;02
    sprite-part < #01, #10, #10, #13, #08, #$0144 >   ;03
    sprite-part < #01, #20, #00, #13, #08, #$0146 >   ;04
    sprite-part < #01, #1E, #02, #1B, #00, #$000E >   ;05
    sprite-part < #01, #10, #10, #00, #1B, #$00E8 >   ;06
    sprite-part < #01, #00, #20, #00, #1B, #$00E6 >   ;07
  ] >
]

sprite_group_149C36 [
  sprite-group < #16, #0A, #2B, #08, #F8, #F0, #01, #01, #F0, #10, #E0, #20, #07, [
    sprite-part < #01, #05, #0B, #08, #1B, #$008A >   ;00
    sprite-part < #01, #06, #0A, #00, #23, #$00EA >   ;01
    sprite-part < #01, #00, #10, #0B, #18, #$0124 >   ;02
    sprite-part < #01, #10, #00, #0B, #18, #$0126 >   ;03
    sprite-part < #01, #00, #10, #1B, #08, #$0144 >   ;04
    sprite-part < #01, #10, #00, #1B, #08, #$0146 >   ;05
    sprite-part < #01, #0E, #02, #23, #00, #$000E >   ;06
  ] >
]

sprite_group_149C74 [
  sprite-group < #0B, #16, #23, #08, #F8, #F0, #01, #01, #F3, #13, #E5, #1A, #09, [
    sprite-part < #01, #01, #10, #04, #17, #$412A >   ;00
    sprite-part < #01, #00, #11, #12, #09, #$414A >   ;01
    sprite-part < #01, #0B, #06, #13, #08, #$4148 >   ;02
    sprite-part < #01, #0C, #05, #00, #1B, #$408A >   ;03
    sprite-part < #01, #11, #00, #03, #18, #$4124 >   ;04
    sprite-part < #01, #11, #00, #13, #08, #$4144 >   ;05
    sprite-part < #01, #01, #10, #03, #18, #$4126 >   ;06
    sprite-part < #01, #01, #10, #13, #08, #$4146 >   ;07
    sprite-part < #01, #03, #0E, #1B, #00, #$400E >   ;08
  ] >
]

sprite_group_149CC0 [
  sprite-group < #0F, #16, #23, #08, #F8, #F0, #01, #01, #F2, #1A, #E5, #1A, #08, [
    sprite-part < #01, #00, #15, #13, #08, #$80E6 >   ;00
    sprite-part < #01, #10, #05, #00, #1B, #$408A >   ;01
    sprite-part < #01, #10, #05, #13, #08, #$80E8 >   ;02
    sprite-part < #01, #15, #00, #03, #18, #$4124 >   ;03
    sprite-part < #01, #15, #00, #13, #08, #$4144 >   ;04
    sprite-part < #01, #05, #10, #03, #18, #$4126 >   ;05
    sprite-part < #01, #05, #10, #13, #08, #$4146 >   ;06
    sprite-part < #01, #07, #0E, #1B, #00, #$400E >   ;07
  ] >
]

sprite_group_149D05 [
  sprite-group < #0A, #38, #23, #0B, #F8, #F0, #01, #01, #0F, #28, #E5, #1A, #0B, [
    sprite-part < #01, #0B, #27, #00, #1E, #$408A >   ;00
    sprite-part < #01, #00, #32, #03, #1B, #$4126 >   ;01
    sprite-part < #01, #00, #32, #13, #0B, #$4146 >   ;02
    sprite-part < #01, #10, #22, #03, #1B, #$4124 >   ;03
    sprite-part < #01, #10, #22, #13, #0B, #$4144 >   ;04
    sprite-part < #01, #12, #20, #0B, #13, #$4166 >   ;05
    sprite-part < #01, #22, #10, #0B, #13, #$4164 >   ;06
    sprite-part < #01, #22, #10, #1B, #03, #$4184 >   ;07
    sprite-part < #01, #32, #00, #0E, #10, #$4180 >   ;08
    sprite-part < #01, #32, #00, #1E, #00, #$41A0 >   ;09
    sprite-part < #01, #02, #30, #1B, #03, #$400E >   ;0A
  ] >
]

sprite_group_149D5F [
  sprite-group < #0A, #3A, #23, #08, #F8, #F0, #01, #01, #11, #26, #E4, #1B, #0A, [
    sprite-part < #01, #10, #24, #13, #08, #$4144 >   ;00
    sprite-part < #01, #0B, #29, #00, #1B, #$408A >   ;01
    sprite-part < #01, #00, #34, #03, #18, #$4126 >   ;02
    sprite-part < #01, #00, #34, #13, #08, #$4146 >   ;03
    sprite-part < #01, #02, #32, #1B, #00, #$400E >   ;04
    sprite-part < #01, #10, #24, #03, #18, #$4124 >   ;05
    sprite-part < #01, #1B, #19, #04, #17, #$4108 >   ;06
    sprite-part < #01, #28, #0C, #04, #17, #$4106 >   ;07
    sprite-part < #01, #0F, #25, #02, #19, #$412C >   ;08
    sprite-part < #01, #34, #00, #06, #15, #$4104 >   ;09
  ] >
]

sprite_group_149DB2 [
  sprite-group < #0A, #32, #25, #08, #F8, #F0, #01, #01, #0B, #23, #E5, #1A, #0A, [
    sprite-part < #01, #0B, #21, #02, #1B, #$408A >   ;00
    sprite-part < #01, #00, #2C, #05, #18, #$4126 >   ;01
    sprite-part < #01, #10, #1C, #15, #08, #$4144 >   ;02
    sprite-part < #01, #00, #2C, #15, #08, #$4146 >   ;03
    sprite-part < #01, #02, #2A, #1D, #00, #$400E >   ;04
    sprite-part < #01, #10, #1C, #05, #18, #$4124 >   ;05
    sprite-part < #01, #0F, #1D, #01, #1C, #$410A >   ;06
    sprite-part < #01, #16, #16, #01, #1C, #$4108 >   ;07
    sprite-part < #01, #1F, #0D, #00, #1D, #$4106 >   ;08
    sprite-part < #01, #2C, #00, #01, #1C, #$4104 >   ;09
  ] >
]

sprite_group_149E05 [
  sprite-group < #0A, #26, #23, #08, #F8, #F0, #01, #01, #01, #1A, #E0, #20, #08, [
    sprite-part < #01, #0B, #15, #00, #1B, #$408A >   ;00
    sprite-part < #01, #10, #10, #03, #18, #$4124 >   ;01
    sprite-part < #01, #00, #20, #03, #18, #$4126 >   ;02
    sprite-part < #01, #10, #10, #13, #08, #$4144 >   ;03
    sprite-part < #01, #00, #20, #13, #08, #$4146 >   ;04
    sprite-part < #01, #02, #1E, #1B, #00, #$400E >   ;05
    sprite-part < #01, #10, #10, #00, #1B, #$40E8 >   ;06
    sprite-part < #01, #20, #00, #00, #1B, #$40E6 >   ;07
  ] >
]

sprite_group_149E4A [
  sprite-group < #0A, #16, #2B, #08, #F8, #F0, #01, #01, #01, #10, #E1, #1F, #07, [
    sprite-part < #01, #0B, #05, #08, #1B, #$408A >   ;00
    sprite-part < #01, #0A, #06, #00, #23, #$40EA >   ;01
    sprite-part < #01, #10, #00, #0B, #18, #$4124 >   ;02
    sprite-part < #01, #00, #10, #0B, #18, #$4126 >   ;03
    sprite-part < #01, #10, #00, #1B, #08, #$4144 >   ;04
    sprite-part < #01, #00, #10, #1B, #08, #$4146 >   ;05
    sprite-part < #01, #02, #0E, #23, #00, #$400E >   ;06
  ] >
]

sprite_group_149E88 [
  sprite-group < #16, #10, #2B, #08, #F8, #F0, #01, #01, #EB, #16, #D7, #1A, #09, [
    sprite-part < #01, #06, #10, #0A, #19, #$0140 >   ;00
    sprite-part < #01, #00, #16, #10, #13, #$C12A >   ;01
    sprite-part < #01, #06, #10, #1A, #09, #$0160 >   ;02
    sprite-part < #01, #16, #00, #1A, #09, #$0162 >   ;03
    sprite-part < #01, #0E, #08, #23, #00, #$000E >   ;04
    sprite-part < #01, #16, #00, #0A, #19, #$00A2 >   ;05
    sprite-part < #01, #0E, #08, #00, #23, #$0004 >   ;06
    sprite-part < #01, #10, #06, #01, #22, #$C148 >   ;07
    sprite-part < #01, #00, #16, #00, #23, #$C14A >   ;08
  ] >
]

sprite_group_149ED4 [
  sprite-group < #14, #10, #39, #08, #F8, #F0, #01, #01, #ED, #1C, #C9, #1D, #0A, [
    sprite-part < #01, #00, #14, #00, #31, #$C18A >   ;00
    sprite-part < #01, #00, #14, #10, #21, #$C16A >   ;01
    sprite-part < #01, #10, #04, #10, #21, #$C168 >   ;02
    sprite-part < #01, #14, #00, #18, #19, #$0142 >   ;03
    sprite-part < #01, #04, #10, #18, #19, #$0140 >   ;04
    sprite-part < #01, #0C, #08, #0E, #23, #$0004 >   ;05
    sprite-part < #01, #04, #10, #28, #09, #$0160 >   ;06
    sprite-part < #01, #14, #00, #28, #09, #$0162 >   ;07
    sprite-part < #01, #0C, #08, #31, #00, #$000E >   ;08
    sprite-part < #01, #10, #04, #00, #31, #$C188 >   ;09
  ] >
]

sprite_group_149F27 [
  sprite-group < #18, #13, #54, #08, #F8, #F0, #01, #01, #EB, #22, #AD, #35, #0C, [
    sprite-part < #01, #1B, #00, #30, #1C, #$C10C >   ;00
    sprite-part < #01, #18, #03, #33, #19, #$0142 >   ;01
    sprite-part < #01, #08, #13, #33, #19, #$0140 >   ;02
    sprite-part < #01, #10, #0B, #29, #23, #$0004 >   ;03
    sprite-part < #01, #08, #13, #43, #09, #$0160 >   ;04
    sprite-part < #01, #18, #03, #43, #09, #$0162 >   ;05
    sprite-part < #01, #10, #0B, #4C, #00, #$000E >   ;06
    sprite-part < #01, #14, #07, #20, #2C, #$C14C >   ;07
    sprite-part < #01, #14, #07, #10, #3C, #$C16C >   ;08
    sprite-part < #01, #10, #0B, #00, #4C, #$C18C >   ;09
    sprite-part < #01, #00, #1B, #00, #4C, #$C18E >   ;0A
    sprite-part < #01, #04, #17, #10, #3C, #$C128 >   ;0B
  ] >
]

sprite_group_149F88 [
  sprite-group < #10, #14, #52, #08, #F8, #F0, #01, #01, #F8, #16, #B0, #40, #0A, [
    sprite-part < #01, #14, #00, #2E, #1C, #$C10C >   ;00
    sprite-part < #01, #00, #14, #31, #19, #$0140 >   ;01
    sprite-part < #01, #10, #04, #31, #19, #$0142 >   ;02
    sprite-part < #01, #00, #14, #41, #09, #$0160 >   ;03
    sprite-part < #01, #10, #04, #41, #09, #$0162 >   ;04
    sprite-part < #01, #08, #0C, #27, #23, #$0004 >   ;05
    sprite-part < #01, #08, #0C, #4A, #00, #$000E >   ;06
    sprite-part < #01, #12, #02, #1E, #2C, #$C12E >   ;07
    sprite-part < #01, #12, #02, #0F, #3B, #$C14E >   ;08
    sprite-part < #01, #10, #04, #00, #4A, #$C16E >   ;09
  ] >
]

sprite_group_149FDB [
  sprite-group < #10, #18, #44, #08, #F8, #F0, #01, #01, #F8, #1E, #BF, #40, #0A, [
    sprite-part < #01, #17, #01, #1F, #1D, #$C10E >   ;00
    sprite-part < #01, #00, #18, #23, #19, #$0140 >   ;01
    sprite-part < #01, #10, #08, #23, #19, #$0142 >   ;02
    sprite-part < #01, #00, #18, #33, #09, #$0160 >   ;03
    sprite-part < #01, #10, #08, #33, #09, #$0162 >   ;04
    sprite-part < #01, #08, #10, #19, #23, #$0004 >   ;05
    sprite-part < #01, #08, #10, #3C, #00, #$000E >   ;06
    sprite-part < #01, #17, #01, #12, #2A, #$C12E >   ;07
    sprite-part < #01, #18, #00, #0A, #32, #$C14E >   ;08
    sprite-part < #01, #17, #01, #00, #3C, #$C16E >   ;09
  ] >
]

sprite_group_14A02E [
  sprite-group < #10, #18, #34, #08, #F8, #F0, #01, #01, #F7, #21, #CE, #1F, #08, [
    sprite-part < #01, #18, #00, #0F, #1D, #$C0C4 >   ;00
    sprite-part < #01, #00, #18, #13, #19, #$0140 >   ;01
    sprite-part < #01, #10, #08, #13, #19, #$0142 >   ;02
    sprite-part < #01, #00, #18, #23, #09, #$0160 >   ;03
    sprite-part < #01, #10, #08, #23, #09, #$0162 >   ;04
    sprite-part < #01, #08, #10, #09, #23, #$0004 >   ;05
    sprite-part < #01, #08, #10, #2C, #00, #$000E >   ;06
    sprite-part < #01, #18, #00, #00, #2C, #$C0E4 >   ;07
  ] >
]

sprite_group_14A073 [
  sprite-group < #10, #17, #2B, #08, #F8, #F0, #01, #01, #F8, #1A, #E1, #16, #07, [
    sprite-part < #01, #17, #00, #0C, #17, #$C0A4 >   ;00
    sprite-part < #01, #00, #17, #0A, #19, #$0140 >   ;01
    sprite-part < #01, #10, #07, #0A, #19, #$0142 >   ;02
    sprite-part < #01, #00, #17, #1A, #09, #$0160 >   ;03
    sprite-part < #01, #10, #07, #1A, #09, #$0162 >   ;04
    sprite-part < #01, #08, #0F, #00, #23, #$0004 >   ;05
    sprite-part < #01, #08, #0F, #23, #00, #$000E >   ;06
  ] >
]

sprite_group_14A0B1 [
  sprite-group < #10, #10, #30, #08, #F8, #F0, #01, #01, #F0, #1E, #D8, #2C, #0E, [
    sprite-part < #01, #07, #09, #06, #22, #$0000 >   ;00
    sprite-part < #01, #00, #10, #19, #0F, #$01A2 >   ;01
    sprite-part < #01, #00, #10, #19, #0F, #$00C0 >   ;02
    sprite-part < #01, #10, #00, #19, #0F, #$00C2 >   ;03
    sprite-part < #01, #08, #08, #21, #07, #$00D1 >   ;04
    sprite-part < #01, #00, #10, #09, #1F, #$0182 >   ;05
    sprite-part < #01, #0F, #01, #09, #1F, #$0062 >   ;06
    sprite-part < #01, #08, #08, #28, #00, #$000E >   ;07
    sprite-part < #01, #00, #10, #20, #08, #$01EC >   ;08
    sprite-part < #01, #10, #00, #20, #08, #$01EE >   ;09
    sprite-part < #01, #00, #10, #10, #18, #$01CC >   ;0A
    sprite-part < #01, #10, #00, #10, #18, #$01CE >   ;0B
    sprite-part < #01, #00, #10, #00, #28, #$01AC >   ;0C
    sprite-part < #01, #10, #00, #00, #28, #$01AE >   ;0D
  ] >
]

sprite_group_14A120 [
  sprite-group < #13, #10, #30, #08, #F8, #F0, #01, #01, #EE, #20, #DB, #28, #0D, [
    sprite-part < #01, #03, #10, #0D, #1B, #$008A >   ;00
    sprite-part < #01, #00, #13, #20, #08, #$0144 >   ;01
    sprite-part < #01, #10, #03, #20, #08, #$0146 >   ;02
    sprite-part < #01, #0C, #07, #28, #00, #$000E >   ;03
    sprite-part < #01, #10, #03, #10, #18, #$0126 >   ;04
    sprite-part < #01, #00, #13, #10, #18, #$0124 >   ;05
    sprite-part < #01, #00, #13, #17, #11, #$0186 >   ;06
    sprite-part < #01, #03, #10, #20, #08, #$01EC >   ;07
    sprite-part < #01, #13, #00, #20, #08, #$01EE >   ;08
    sprite-part < #01, #03, #10, #10, #18, #$01CC >   ;09
    sprite-part < #01, #13, #00, #10, #18, #$01CE >   ;0A
    sprite-part < #01, #03, #10, #00, #28, #$01AC >   ;0B
    sprite-part < #01, #13, #00, #00, #28, #$01AE >   ;0C
  ] >
]

sprite_group_14A188 [
  sprite-group < #10, #13, #30, #08, #F8, #F0, #01, #01, #F0, #22, #DA, #29, #0D, [
    sprite-part < #01, #10, #03, #0D, #1B, #$408A >   ;00
    sprite-part < #01, #13, #00, #10, #18, #$4124 >   ;01
    sprite-part < #01, #13, #00, #20, #08, #$4144 >   ;02
    sprite-part < #01, #13, #00, #17, #11, #$4186 >   ;03
    sprite-part < #01, #03, #10, #10, #18, #$4126 >   ;04
    sprite-part < #01, #03, #10, #20, #08, #$4146 >   ;05
    sprite-part < #01, #07, #0C, #28, #00, #$400E >   ;06
    sprite-part < #01, #00, #13, #20, #08, #$01EC >   ;07
    sprite-part < #01, #10, #03, #20, #08, #$01EE >   ;08
    sprite-part < #01, #00, #13, #10, #18, #$01CC >   ;09
    sprite-part < #01, #00, #13, #00, #28, #$01AC >   ;0A
    sprite-part < #01, #10, #03, #00, #28, #$01AE >   ;0B
    sprite-part < #01, #10, #03, #10, #18, #$01CE >   ;0C
  ] >
]

sprite_group_14A1F0 [
  sprite-group < #10, #10, #30, #08, #F8, #F0, #01, #01, #F1, #1C, #D9, #28, #0C, [
    sprite-part < #01, #00, #10, #20, #08, #$0160 >   ;00
    sprite-part < #01, #10, #00, #20, #08, #$0162 >   ;01
    sprite-part < #01, #08, #08, #28, #00, #$400E >   ;02
    sprite-part < #01, #00, #10, #10, #18, #$0140 >   ;03
    sprite-part < #01, #10, #00, #10, #18, #$01A4 >   ;04
    sprite-part < #01, #08, #08, #06, #22, #$0004 >   ;05
    sprite-part < #01, #00, #10, #20, #08, #$01EC >   ;06
    sprite-part < #01, #10, #00, #20, #08, #$01EE >   ;07
    sprite-part < #01, #00, #10, #10, #18, #$01CC >   ;08
    sprite-part < #01, #00, #10, #00, #28, #$01AC >   ;09
    sprite-part < #01, #10, #00, #00, #28, #$01AE >   ;0A
    sprite-part < #01, #10, #00, #10, #18, #$01CE >   ;0B
  ] >
]

sprite_group_14A251 [
  sprite-group < #10, #10, #26, #08, #F8, #F0, #01, #01, #F2, #1B, #E8, #10, #06, [
    sprite-part < #01, #06, #0A, #00, #1E, #$0000 >   ;00
    sprite-part < #01, #00, #10, #01, #1D, #$0060 >   ;01
    sprite-part < #01, #10, #00, #01, #1D, #$0062 >   ;02
    sprite-part < #01, #00, #10, #11, #0D, #$0080 >   ;03
    sprite-part < #01, #10, #00, #11, #0D, #$0082 >   ;04
    sprite-part < #01, #08, #08, #1E, #00, #$000E >   ;05
  ] >
]

sprite_group_14A288 [
  sprite-group < #10, #10, #2B, #0D, #F8, #F0, #01, #01, #F2, #1B, #F3, #10, #06, [
    sprite-part < #01, #08, #08, #28, #00, #$002E >   ;00
    sprite-part < #01, #00, #10, #20, #08, #$00AC >   ;01
    sprite-part < #01, #10, #00, #20, #08, #$00AE >   ;02
    sprite-part < #01, #00, #10, #10, #18, #$008C >   ;03
    sprite-part < #01, #10, #00, #10, #18, #$008E >   ;04
    sprite-part < #01, #08, #08, #00, #28, #$006E >   ;05
  ] >
]

sprite_group_14A2BF [
  sprite-group < #10, #10, #28, #10, #F8, #F0, #01, #01, #F2, #1C, #F9, #10, #06, [
    sprite-part < #01, #08, #08, #28, #00, #$002E >   ;00
    sprite-part < #01, #00, #10, #20, #08, #$00AC >   ;01
    sprite-part < #01, #10, #00, #20, #08, #$00AE >   ;02
    sprite-part < #01, #00, #10, #10, #18, #$008C >   ;03
    sprite-part < #01, #10, #00, #10, #18, #$008E >   ;04
    sprite-part < #01, #08, #08, #00, #28, #$006E >   ;05
  ] >
]

sprite_group_14A2F6 [
  sprite-group < #10, #10, #1F, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #07, #09, #00, #17, #$002E >   ;00
    sprite-part < #01, #00, #10, #01, #16, #$0060 >   ;01
    sprite-part < #01, #10, #00, #01, #16, #$0062 >   ;02
    sprite-part < #01, #00, #10, #11, #06, #$0080 >   ;03
    sprite-part < #01, #10, #00, #11, #06, #$0082 >   ;04
    sprite-part < #01, #08, #08, #17, #00, #$000E >   ;05
  ] >
]

sprite_group_14A32D [
  sprite-group < #10, #10, #2C, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #08, #08, #00, #24, #$0000 >   ;00
    sprite-part < #01, #00, #10, #1A, #0A, #$0040 >   ;01
    sprite-part < #01, #10, #00, #1A, #0A, #$0042 >   ;02
    sprite-part < #01, #00, #10, #0A, #1A, #$0020 >   ;03
    sprite-part < #01, #10, #00, #0A, #1A, #$0022 >   ;04
    sprite-part < #01, #08, #08, #24, #00, #$000E >   ;05
  ] >
]

sprite_group_14A364 [
  sprite-group < #10, #10, #2D, #08, #F8, #F0, #01, #01, #F4, #17, #DF, #10, #06, [
    sprite-part < #01, #00, #10, #09, #1C, #$000A >   ;00
    sprite-part < #01, #10, #00, #09, #1C, #$000C >   ;01
    sprite-part < #01, #09, #07, #00, #25, #$0004 >   ;02
    sprite-part < #01, #00, #10, #19, #0C, #$002A >   ;03
    sprite-part < #01, #10, #00, #19, #0C, #$002C >   ;04
    sprite-part < #01, #08, #08, #25, #00, #$000E >   ;05
  ] >
]

sprite_group_14A39B [
  sprite-group < #10, #10, #29, #08, #F8, #F0, #01, #01, #F2, #1B, #DE, #10, #06, [
    sprite-part < #01, #08, #08, #00, #21, #$8004 >   ;00
    sprite-part < #01, #00, #10, #19, #08, #$00EC >   ;01
    sprite-part < #01, #10, #00, #19, #08, #$00EE >   ;02
    sprite-part < #01, #00, #10, #09, #18, #$00CC >   ;03
    sprite-part < #01, #10, #00, #09, #18, #$00CE >   ;04
    sprite-part < #01, #08, #08, #21, #00, #$000E >   ;05
  ] >
]

sprite_group_14A3D2 [
  sprite-group < #10, #10, #2B, #08, #F8, #F0, #01, #01, #F2, #1C, #DC, #10, #06, [
    sprite-part < #01, #08, #08, #00, #23, #$8004 >   ;00
    sprite-part < #01, #00, #10, #19, #0A, #$00EC >   ;01
    sprite-part < #01, #10, #00, #19, #0A, #$00EE >   ;02
    sprite-part < #01, #00, #10, #09, #1A, #$00CC >   ;03
    sprite-part < #01, #10, #00, #09, #1A, #$00CE >   ;04
    sprite-part < #01, #08, #08, #23, #00, #$000E >   ;05
  ] >
]

sprite_group_14A409 [
  sprite-group < #10, #10, #24, #08, #F8, #F0, #01, #01, #F3, #1A, #E2, #10, #06, [
    sprite-part < #01, #00, #10, #09, #13, #$000A >   ;00
    sprite-part < #01, #10, #00, #09, #13, #$000C >   ;01
    sprite-part < #01, #09, #07, #00, #1C, #$0004 >   ;02
    sprite-part < #01, #00, #10, #19, #03, #$002A >   ;03
    sprite-part < #01, #10, #00, #19, #03, #$002C >   ;04
    sprite-part < #01, #08, #08, #1C, #00, #$000E >   ;05
  ] >
]

sprite_group_14A440 [
  sprite-group < #10, #10, #2E, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #00, #10, #1B, #0B, #$0026 >   ;00
    sprite-part < #01, #10, #00, #1B, #0B, #$0028 >   ;01
    sprite-part < #01, #00, #10, #0B, #1B, #$0006 >   ;02
    sprite-part < #01, #10, #00, #0B, #1B, #$0008 >   ;03
    sprite-part < #01, #08, #08, #26, #00, #$000E >   ;04
    sprite-part < #01, #08, #08, #00, #26, #$0004 >   ;05
  ] >
]

sprite_group_14A477 [
  sprite-group < #18, #10, #27, #08, #F8, #F0, #01, #01, #EB, #10, #DF, #1F, #07, [
    sprite-part < #01, #03, #15, #00, #1F, #$0002 >   ;00
    sprite-part < #01, #00, #18, #02, #1D, #$0064 >   ;01
    sprite-part < #01, #10, #08, #02, #1D, #$0066 >   ;02
    sprite-part < #01, #00, #18, #12, #0D, #$0084 >   ;03
    sprite-part < #01, #10, #08, #12, #0D, #$0086 >   ;04
    sprite-part < #00, #20, #00, #1D, #0A, #$0098 >   ;05
    sprite-part < #01, #10, #08, #1F, #00, #$000E >   ;06
  ] >
]

sprite_group_14A4B5 [
  sprite-group < #1D, #10, #20, #08, #F8, #F0, #01, #01, #E6, #10, #E0, #1C, #0A, [
    sprite-part < #01, #00, #1D, #01, #17, #$008A >   ;00
    sprite-part < #01, #15, #08, #18, #00, #$000E >   ;01
    sprite-part < #01, #05, #18, #00, #18, #$00A7 >   ;02
    sprite-part < #01, #15, #08, #00, #18, #$00A9 >   ;03
    sprite-part < #01, #1D, #00, #00, #18, #$00AA >   ;04
    sprite-part < #00, #05, #20, #10, #10, #$00C7 >   ;05
    sprite-part < #00, #0D, #18, #10, #10, #$00C8 >   ;06
    sprite-part < #00, #15, #10, #10, #10, #$00C9 >   ;07
    sprite-part < #00, #1D, #08, #10, #10, #$00CA >   ;08
    sprite-part < #00, #25, #00, #10, #10, #$00CB >   ;09
  ] >
]

sprite_group_14A508 [
  sprite-group < #20, #0D, #20, #08, #F8, #F0, #01, #01, #E2, #10, #DF, #1E, #0A, [
    sprite-part < #01, #00, #1D, #01, #17, #$008A >   ;00
    sprite-part < #01, #15, #08, #18, #00, #$000E >   ;01
    sprite-part < #01, #05, #18, #00, #18, #$00A7 >   ;02
    sprite-part < #01, #15, #08, #00, #18, #$00A9 >   ;03
    sprite-part < #01, #1D, #00, #00, #18, #$00AA >   ;04
    sprite-part < #00, #05, #20, #10, #10, #$00C7 >   ;05
    sprite-part < #00, #0D, #18, #10, #10, #$00C8 >   ;06
    sprite-part < #00, #15, #10, #10, #10, #$00C9 >   ;07
    sprite-part < #00, #1D, #08, #10, #10, #$00CA >   ;08
    sprite-part < #00, #25, #00, #10, #10, #$00CB >   ;09
  ] >
]

sprite_group_14A55B [
  sprite-group < #15, #13, #26, #08, #F8, #F0, #01, #01, #EB, #10, #E1, #1A, #07, [
    sprite-part < #01, #03, #15, #00, #1E, #$0002 >   ;00
    sprite-part < #01, #00, #18, #02, #1C, #$0064 >   ;01
    sprite-part < #01, #10, #08, #02, #1C, #$0066 >   ;02
    sprite-part < #01, #00, #18, #12, #0C, #$0084 >   ;03
    sprite-part < #01, #10, #08, #12, #0C, #$0086 >   ;04
    sprite-part < #00, #20, #00, #1D, #09, #$0098 >   ;05
    sprite-part < #01, #0D, #0B, #1E, #00, #$000E >   ;06
  ] >
]

sprite_group_14A599 [
  sprite-group < #09, #08, #2E, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #04, [
    sprite-part < #01, #00, #01, #00, #26, #$0002 >   ;00
    sprite-part < #01, #01, #00, #0C, #1A, #$0024 >   ;01
    sprite-part < #01, #01, #00, #1C, #0A, #$0044 >   ;02
    sprite-part < #01, #01, #00, #26, #00, #$000E >   ;03
  ] >
]

sprite_group_14A5C2 [
  sprite-group < #10, #18, #27, #08, #F8, #F0, #01, #01, #05, #10, #E1, #1C, #07, [
    sprite-part < #01, #15, #03, #00, #1F, #$4002 >   ;00
    sprite-part < #01, #18, #00, #02, #1D, #$4064 >   ;01
    sprite-part < #01, #08, #10, #02, #1D, #$4066 >   ;02
    sprite-part < #01, #18, #00, #12, #0D, #$4084 >   ;03
    sprite-part < #01, #08, #10, #12, #0D, #$4086 >   ;04
    sprite-part < #00, #00, #20, #1D, #0A, #$4098 >   ;05
    sprite-part < #01, #08, #10, #1F, #00, #$400E >   ;06
  ] >
]

sprite_group_14A600 [
  sprite-group < #10, #1D, #20, #08, #F8, #F0, #01, #01, #08, #10, #E0, #1C, #0A, [
    sprite-part < #01, #1D, #00, #01, #17, #$408A >   ;00
    sprite-part < #01, #08, #15, #18, #00, #$400E >   ;01
    sprite-part < #01, #18, #05, #00, #18, #$40A7 >   ;02
    sprite-part < #01, #08, #15, #00, #18, #$40A9 >   ;03
    sprite-part < #01, #00, #1D, #00, #18, #$40AA >   ;04
    sprite-part < #00, #20, #05, #10, #10, #$40C7 >   ;05
    sprite-part < #00, #18, #0D, #10, #10, #$40C8 >   ;06
    sprite-part < #00, #10, #15, #10, #10, #$40C9 >   ;07
    sprite-part < #00, #08, #1D, #10, #10, #$40CA >   ;08
    sprite-part < #00, #00, #25, #10, #10, #$40CB >   ;09
  ] >
]

sprite_group_14A653 [
  sprite-group < #0D, #20, #20, #08, #F8, #F0, #01, #01, #0D, #10, #E2, #1C, #0A, [
    sprite-part < #01, #1D, #00, #01, #17, #$408A >   ;00
    sprite-part < #01, #08, #15, #18, #00, #$400E >   ;01
    sprite-part < #01, #18, #05, #00, #18, #$40A7 >   ;02
    sprite-part < #01, #08, #15, #00, #18, #$40A9 >   ;03
    sprite-part < #01, #00, #1D, #00, #18, #$40AA >   ;04
    sprite-part < #00, #20, #05, #10, #10, #$40C7 >   ;05
    sprite-part < #00, #18, #0D, #10, #10, #$40C8 >   ;06
    sprite-part < #00, #10, #15, #10, #10, #$40C9 >   ;07
    sprite-part < #00, #08, #1D, #10, #10, #$40CA >   ;08
    sprite-part < #00, #00, #25, #10, #10, #$40CB >   ;09
  ] >
]

sprite_group_14A6A6 [
  sprite-group < #13, #15, #26, #08, #F8, #F0, #01, #01, #EB, #10, #E1, #1A, #07, [
    sprite-part < #01, #15, #03, #00, #1E, #$4002 >   ;00
    sprite-part < #01, #18, #00, #02, #1C, #$4064 >   ;01
    sprite-part < #01, #08, #10, #02, #1C, #$4066 >   ;02
    sprite-part < #01, #18, #00, #12, #0C, #$4084 >   ;03
    sprite-part < #01, #08, #10, #12, #0C, #$4086 >   ;04
    sprite-part < #00, #00, #20, #1D, #09, #$4098 >   ;05
    sprite-part < #01, #0B, #0D, #1E, #00, #$400E >   ;06
  ] >
]

sprite_group_14A6E4 [
  sprite-group < #08, #09, #2E, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #04, [
    sprite-part < #01, #01, #00, #00, #26, #$4002 >   ;00
    sprite-part < #01, #00, #01, #0C, #1A, #$4024 >   ;01
    sprite-part < #01, #00, #01, #1C, #0A, #$4044 >   ;02
    sprite-part < #01, #00, #01, #26, #00, #$400E >   ;03
  ] >
]

sprite_group_14A70D [
  sprite-group < #10, #10, #2F, #01, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #00, #10, #00, #20, #$01AC >   ;00
    sprite-part < #01, #00, #10, #10, #10, #$01CC >   ;01
    sprite-part < #01, #00, #10, #20, #00, #$01EC >   ;02
    sprite-part < #01, #10, #00, #20, #00, #$01EE >   ;03
    sprite-part < #01, #10, #00, #10, #10, #$01CE >   ;04
    sprite-part < #01, #10, #00, #00, #20, #$01AE >   ;05
  ] >
]

sprite_group_14A744 [
  sprite-group < #10, #10, #31, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #00, #10, #00, #21, #$01AC >   ;00
    sprite-part < #01, #00, #10, #10, #11, #$01CC >   ;01
    sprite-part < #01, #00, #10, #20, #01, #$01EC >   ;02
    sprite-part < #01, #10, #00, #20, #01, #$01EE >   ;03
    sprite-part < #01, #10, #00, #10, #11, #$01CE >   ;04
    sprite-part < #01, #10, #00, #00, #21, #$01AE >   ;05
  ] >
]

sprite_group_14A77B [
  sprite-group < #11, #0F, #30, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #00, #10, #00, #20, #$01AC >   ;00
    sprite-part < #01, #00, #10, #10, #10, #$01CC >   ;01
    sprite-part < #01, #00, #10, #20, #00, #$01EC >   ;02
    sprite-part < #01, #10, #00, #20, #00, #$01EE >   ;03
    sprite-part < #01, #10, #00, #10, #10, #$01CE >   ;04
    sprite-part < #01, #10, #00, #00, #20, #$01AE >   ;05
  ] >
]

sprite_group_14A7B2 [
  sprite-group < #0F, #11, #30, #00, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #06, [
    sprite-part < #01, #00, #10, #00, #20, #$01AC >   ;00
    sprite-part < #01, #00, #10, #10, #10, #$01CC >   ;01
    sprite-part < #01, #00, #10, #20, #00, #$01EC >   ;02
    sprite-part < #01, #10, #00, #20, #00, #$01EE >   ;03
    sprite-part < #01, #10, #00, #10, #10, #$01CE >   ;04
    sprite-part < #01, #10, #00, #00, #20, #$01AE >   ;05
  ] >
]

sprite_group_14A7E9 [
  sprite-group < #11, #11, #29, #08, #F8, #F0, #01, #01, #F8, #17, #E0, #18, #0A, [
    sprite-part < #01, #12, #00, #10, #11, #$014A >   ;00
    sprite-part < #01, #02, #10, #11, #10, #$0148 >   ;01
    sprite-part < #01, #10, #02, #13, #0E, #$00C2 >   ;02
    sprite-part < #01, #00, #12, #13, #0E, #$00C0 >   ;03
    sprite-part < #01, #07, #0B, #00, #21, #$0000 >   ;04
    sprite-part < #01, #00, #12, #03, #1E, #$00A0 >   ;05
    sprite-part < #01, #12, #00, #00, #21, #$012A >   ;06
    sprite-part < #01, #10, #02, #03, #1E, #$0062 >   ;07
    sprite-part < #01, #08, #0A, #1B, #06, #$00D1 >   ;08
    sprite-part < #01, #09, #09, #21, #00, #$000E >   ;09
  ] >
]

sprite_group_14A83C [
  sprite-group < #13, #14, #29, #08, #F8, #F0, #01, #01, #F8, #17, #EF, #18, #0C, [
    sprite-part < #01, #00, #17, #0A, #17, #$010C >   ;00
    sprite-part < #01, #17, #00, #10, #11, #$016A >   ;01
    sprite-part < #01, #17, #00, #20, #01, #$018A >   ;02
    sprite-part < #01, #07, #10, #10, #11, #$0168 >   ;03
    sprite-part < #01, #07, #10, #20, #01, #$0188 >   ;04
    sprite-part < #01, #09, #0E, #00, #21, #$0000 >   ;05
    sprite-part < #01, #02, #15, #03, #1E, #$00A0 >   ;06
    sprite-part < #01, #12, #05, #03, #1E, #$0062 >   ;07
    sprite-part < #01, #0A, #0D, #1B, #06, #$00D1 >   ;08
    sprite-part < #01, #0B, #0C, #21, #00, #$000E >   ;09
    sprite-part < #01, #02, #15, #13, #0E, #$00C0 >   ;0A
    sprite-part < #01, #12, #05, #13, #0E, #$00C2 >   ;0B
  ] >
]

sprite_group_14A89D [
  sprite-group < #14, #16, #29, #20, #F8, #F0, #01, #01, #F6, #17, #F1, #2D, #0D, [
    sprite-part < #01, #07, #13, #19, #20, #$014C >   ;00
    sprite-part < #01, #0A, #10, #00, #39, #$0000 >   ;01
    sprite-part < #01, #17, #03, #29, #10, #$0128 >   ;02
    sprite-part < #01, #1A, #00, #39, #00, #$018E >   ;03
    sprite-part < #01, #0A, #10, #39, #00, #$018C >   ;04
    sprite-part < #01, #07, #13, #29, #10, #$016C >   ;05
    sprite-part < #01, #00, #1A, #09, #30, #$010C >   ;06
    sprite-part < #01, #03, #17, #13, #26, #$00C0 >   ;07
    sprite-part < #01, #03, #17, #03, #36, #$00A0 >   ;08
    sprite-part < #01, #13, #07, #03, #36, #$0062 >   ;09
    sprite-part < #01, #0B, #0F, #1B, #1E, #$00D1 >   ;0A
    sprite-part < #01, #0C, #0E, #21, #18, #$000E >   ;0B
    sprite-part < #01, #13, #07, #13, #26, #$00C2 >   ;0C
  ] >
]

sprite_group_14A905 [
  sprite-group < #14, #0F, #29, #20, #F8, #F0, #01, #01, #F1, #15, #E9, #32, #0B, [
    sprite-part < #01, #02, #11, #19, #20, #$012E >   ;00
    sprite-part < #01, #00, #13, #09, #30, #$010C >   ;01
    sprite-part < #01, #02, #11, #29, #10, #$014E >   ;02
    sprite-part < #01, #03, #10, #13, #26, #$00C0 >   ;03
    sprite-part < #01, #0A, #09, #00, #39, #$0000 >   ;04
    sprite-part < #01, #03, #10, #03, #36, #$00A0 >   ;05
    sprite-part < #01, #13, #00, #03, #36, #$0062 >   ;06
    sprite-part < #01, #05, #0E, #39, #00, #$016E >   ;07
    sprite-part < #01, #13, #00, #13, #26, #$00C2 >   ;08
    sprite-part < #01, #0B, #08, #1B, #1E, #$00D1 >   ;09
    sprite-part < #01, #0C, #07, #21, #18, #$000E >   ;0A
  ] >
]

sprite_group_14A95F [
  sprite-group < #17, #0F, #29, #11, #F8, #F0, #01, #01, #EE, #1B, #E4, #29, #0B, [
    sprite-part < #01, #01, #15, #2A, #00, #$016E >   ;00
    sprite-part < #01, #00, #16, #0A, #20, #$010E >   ;01
    sprite-part < #01, #00, #16, #21, #09, #$014E >   ;02
    sprite-part < #01, #00, #16, #15, #15, #$012E >   ;03
    sprite-part < #01, #06, #10, #13, #17, #$00C0 >   ;04
    sprite-part < #01, #0D, #09, #00, #2A, #$0000 >   ;05
    sprite-part < #01, #06, #10, #03, #27, #$00A0 >   ;06
    sprite-part < #01, #16, #00, #03, #27, #$0062 >   ;07
    sprite-part < #01, #16, #00, #13, #17, #$00C2 >   ;08
    sprite-part < #01, #0E, #08, #1B, #0F, #$00D1 >   ;09
    sprite-part < #01, #0F, #07, #21, #09, #$000E >   ;0A
  ] >
]

sprite_group_14A9B9 [
  sprite-group < #19, #0F, #29, #08, #F8, #F0, #01, #01, #E8, #17, #E2, #1E, #09, [
    sprite-part < #01, #00, #18, #0C, #15, #$00C4 >   ;00
    sprite-part < #01, #08, #10, #13, #0E, #$00C0 >   ;01
    sprite-part < #01, #0F, #09, #00, #21, #$0000 >   ;02
    sprite-part < #01, #08, #10, #03, #1E, #$00A0 >   ;03
    sprite-part < #01, #18, #00, #03, #1E, #$0062 >   ;04
    sprite-part < #01, #18, #00, #13, #0E, #$00C2 >   ;05
    sprite-part < #01, #10, #08, #1B, #06, #$00D1 >   ;06
    sprite-part < #01, #11, #07, #21, #00, #$000E >   ;07
    sprite-part < #01, #00, #18, #1C, #05, #$00E4 >   ;08
  ] >
]

sprite_group_14AA05 [
  sprite-group < #17, #0F, #29, #08, #F8, #F0, #01, #01, #EB, #17, #E0, #18, #08, [
    sprite-part < #01, #00, #16, #06, #1B, #$00A4 >   ;00
    sprite-part < #01, #06, #10, #13, #0E, #$00C0 >   ;01
    sprite-part < #01, #0D, #09, #00, #21, #$0000 >   ;02
    sprite-part < #01, #06, #10, #03, #1E, #$00A0 >   ;03
    sprite-part < #01, #16, #00, #03, #1E, #$0062 >   ;04
    sprite-part < #01, #16, #00, #13, #0E, #$00C2 >   ;05
    sprite-part < #01, #0E, #08, #1B, #06, #$00D1 >   ;06
    sprite-part < #01, #0F, #07, #21, #00, #$000E >   ;07
  ] >
]

sprite_group_14AA4A [
  sprite-group < #16, #0B, #23, #08, #F8, #F0, #01, #01, #F3, #13, #E5, #1A, #09, [
    sprite-part < #01, #10, #01, #04, #17, #$012A >   ;00
    sprite-part < #01, #11, #00, #12, #09, #$014A >   ;01
    sprite-part < #01, #06, #0B, #13, #08, #$0148 >   ;02
    sprite-part < #01, #05, #0C, #00, #1B, #$008A >   ;03
    sprite-part < #01, #00, #11, #03, #18, #$0124 >   ;04
    sprite-part < #01, #00, #11, #13, #08, #$0144 >   ;05
    sprite-part < #01, #10, #01, #03, #18, #$0126 >   ;06
    sprite-part < #01, #10, #01, #13, #08, #$0146 >   ;07
    sprite-part < #01, #0E, #03, #1B, #00, #$000E >   ;08
  ] >
]

sprite_group_14AA96 [
  sprite-group < #16, #0F, #23, #08, #F8, #F0, #01, #01, #F2, #1A, #E5, #1A, #08, [
    sprite-part < #01, #15, #00, #13, #08, #$C0E6 >   ;00
    sprite-part < #01, #05, #10, #00, #1B, #$008A >   ;01
    sprite-part < #01, #05, #10, #13, #08, #$C0E8 >   ;02
    sprite-part < #01, #00, #15, #03, #18, #$0124 >   ;03
    sprite-part < #01, #00, #15, #13, #08, #$0144 >   ;04
    sprite-part < #01, #10, #05, #03, #18, #$0126 >   ;05
    sprite-part < #01, #10, #05, #13, #08, #$0146 >   ;06
    sprite-part < #01, #0E, #07, #1B, #00, #$000E >   ;07
  ] >
]

sprite_group_14AADB [
  sprite-group < #38, #0A, #23, #0B, #F8, #F0, #01, #01, #C8, #28, #E5, #1A, #0B, [
    sprite-part < #01, #27, #0B, #00, #1E, #$008A >   ;00
    sprite-part < #01, #32, #00, #03, #1B, #$0126 >   ;01
    sprite-part < #01, #32, #00, #13, #0B, #$0146 >   ;02
    sprite-part < #01, #22, #10, #03, #1B, #$0124 >   ;03
    sprite-part < #01, #22, #10, #13, #0B, #$0144 >   ;04
    sprite-part < #01, #20, #12, #0B, #13, #$0166 >   ;05
    sprite-part < #01, #10, #22, #0B, #13, #$0164 >   ;06
    sprite-part < #01, #10, #22, #1B, #03, #$0184 >   ;07
    sprite-part < #01, #00, #32, #0E, #10, #$0180 >   ;08
    sprite-part < #01, #00, #32, #1E, #00, #$01A0 >   ;09
    sprite-part < #01, #30, #02, #1B, #03, #$000E >   ;0A
  ] >
]

sprite_group_14AB35 [
  sprite-group < #3A, #0A, #23, #08, #F8, #F0, #01, #01, #C8, #28, #E5, #1A, #0A, [
    sprite-part < #01, #24, #10, #13, #08, #$0144 >   ;00
    sprite-part < #01, #29, #0B, #00, #1B, #$008A >   ;01
    sprite-part < #01, #34, #00, #03, #18, #$0126 >   ;02
    sprite-part < #01, #34, #00, #13, #08, #$0146 >   ;03
    sprite-part < #01, #32, #02, #1B, #00, #$000E >   ;04
    sprite-part < #01, #24, #10, #03, #18, #$0124 >   ;05
    sprite-part < #01, #19, #1B, #04, #17, #$0108 >   ;06
    sprite-part < #01, #0C, #28, #04, #17, #$0106 >   ;07
    sprite-part < #01, #25, #0F, #02, #19, #$012C >   ;08
    sprite-part < #01, #00, #34, #06, #15, #$0104 >   ;09
  ] >
]

sprite_group_14AB88 [
  sprite-group < #32, #0A, #25, #08, #F8, #F0, #01, #01, #D1, #22, #E5, #1B, #0A, [
    sprite-part < #01, #21, #0B, #02, #1B, #$008A >   ;00
    sprite-part < #01, #2C, #00, #05, #18, #$0126 >   ;01
    sprite-part < #01, #1C, #10, #15, #08, #$0144 >   ;02
    sprite-part < #01, #2C, #00, #15, #08, #$0146 >   ;03
    sprite-part < #01, #2A, #02, #1D, #00, #$000E >   ;04
    sprite-part < #01, #1C, #10, #05, #18, #$0124 >   ;05
    sprite-part < #01, #1D, #0F, #01, #1C, #$010A >   ;06
    sprite-part < #01, #16, #16, #01, #1C, #$0108 >   ;07
    sprite-part < #01, #0D, #1F, #00, #1D, #$0106 >   ;08
    sprite-part < #01, #00, #2C, #01, #1C, #$0104 >   ;09
  ] >
]

sprite_group_14ABDB [
  sprite-group < #26, #0A, #23, #08, #F8, #F0, #01, #01, #E4, #1B, #E1, #1F, #08, [
    sprite-part < #01, #15, #0B, #00, #1B, #$008A >   ;00
    sprite-part < #01, #10, #10, #03, #18, #$0124 >   ;01
    sprite-part < #01, #20, #00, #03, #18, #$0126 >   ;02
    sprite-part < #01, #10, #10, #13, #08, #$0144 >   ;03
    sprite-part < #01, #20, #00, #13, #08, #$0146 >   ;04
    sprite-part < #01, #1E, #02, #1B, #00, #$000E >   ;05
    sprite-part < #01, #10, #10, #00, #1B, #$00E8 >   ;06
    sprite-part < #01, #00, #20, #00, #1B, #$00E6 >   ;07
  ] >
]

sprite_group_14AC20 [
  sprite-group < #16, #0A, #2B, #08, #F8, #F0, #01, #01, #F0, #10, #E0, #20, #07, [
    sprite-part < #01, #05, #0B, #08, #1B, #$008A >   ;00
    sprite-part < #01, #06, #0A, #00, #23, #$00EA >   ;01
    sprite-part < #01, #00, #10, #0B, #18, #$0124 >   ;02
    sprite-part < #01, #10, #00, #0B, #18, #$0126 >   ;03
    sprite-part < #01, #00, #10, #1B, #08, #$0144 >   ;04
    sprite-part < #01, #10, #00, #1B, #08, #$0146 >   ;05
    sprite-part < #01, #0E, #02, #23, #00, #$000E >   ;06
  ] >
]

sprite_group_14AC5E [
  sprite-group < #0B, #16, #23, #08, #F8, #F0, #01, #01, #F3, #13, #E5, #1A, #09, [
    sprite-part < #01, #01, #10, #04, #17, #$412A >   ;00
    sprite-part < #01, #00, #11, #12, #09, #$414A >   ;01
    sprite-part < #01, #0B, #06, #13, #08, #$4148 >   ;02
    sprite-part < #01, #0C, #05, #00, #1B, #$408A >   ;03
    sprite-part < #01, #11, #00, #03, #18, #$4124 >   ;04
    sprite-part < #01, #11, #00, #13, #08, #$4144 >   ;05
    sprite-part < #01, #01, #10, #03, #18, #$4126 >   ;06
    sprite-part < #01, #01, #10, #13, #08, #$4146 >   ;07
    sprite-part < #01, #03, #0E, #1B, #00, #$400E >   ;08
  ] >
]

sprite_group_14ACAA [
  sprite-group < #0F, #16, #23, #08, #F8, #F0, #01, #01, #F2, #1A, #E5, #1A, #08, [
    sprite-part < #01, #00, #15, #13, #08, #$80E6 >   ;00
    sprite-part < #01, #10, #05, #00, #1B, #$408A >   ;01
    sprite-part < #01, #10, #05, #13, #08, #$80E8 >   ;02
    sprite-part < #01, #15, #00, #03, #18, #$4124 >   ;03
    sprite-part < #01, #15, #00, #13, #08, #$4144 >   ;04
    sprite-part < #01, #05, #10, #03, #18, #$4126 >   ;05
    sprite-part < #01, #05, #10, #13, #08, #$4146 >   ;06
    sprite-part < #01, #07, #0E, #1B, #00, #$400E >   ;07
  ] >
]

sprite_group_14ACEF [
  sprite-group < #0A, #38, #23, #0B, #F8, #F0, #01, #01, #C8, #28, #E5, #1A, #0B, [
    sprite-part < #01, #0B, #27, #00, #1E, #$408A >   ;00
    sprite-part < #01, #00, #32, #03, #1B, #$4126 >   ;01
    sprite-part < #01, #00, #32, #13, #0B, #$4146 >   ;02
    sprite-part < #01, #10, #22, #03, #1B, #$4124 >   ;03
    sprite-part < #01, #10, #22, #13, #0B, #$4144 >   ;04
    sprite-part < #01, #12, #20, #0B, #13, #$4166 >   ;05
    sprite-part < #01, #22, #10, #0B, #13, #$4164 >   ;06
    sprite-part < #01, #22, #10, #1B, #03, #$4184 >   ;07
    sprite-part < #01, #32, #00, #0E, #10, #$4180 >   ;08
    sprite-part < #01, #32, #00, #1E, #00, #$41A0 >   ;09
    sprite-part < #01, #02, #30, #1B, #03, #$400E >   ;0A
  ] >
]

sprite_group_14AD49 [
  sprite-group < #0A, #3A, #23, #08, #F8, #F0, #01, #01, #11, #26, #E4, #1B, #0A, [
    sprite-part < #01, #10, #24, #13, #08, #$4144 >   ;00
    sprite-part < #01, #0B, #29, #00, #1B, #$408A >   ;01
    sprite-part < #01, #00, #34, #03, #18, #$4126 >   ;02
    sprite-part < #01, #00, #34, #13, #08, #$4146 >   ;03
    sprite-part < #01, #02, #32, #1B, #00, #$400E >   ;04
    sprite-part < #01, #10, #24, #03, #18, #$4124 >   ;05
    sprite-part < #01, #1B, #19, #04, #17, #$4108 >   ;06
    sprite-part < #01, #28, #0C, #04, #17, #$4106 >   ;07
    sprite-part < #01, #0F, #25, #02, #19, #$412C >   ;08
    sprite-part < #01, #34, #00, #06, #15, #$4104 >   ;09
  ] >
]

sprite_group_14AD9C [
  sprite-group < #0A, #32, #25, #08, #F8, #F0, #01, #01, #10, #23, #E5, #1A, #0A, [
    sprite-part < #01, #0B, #21, #02, #1B, #$408A >   ;00
    sprite-part < #01, #00, #2C, #05, #18, #$4126 >   ;01
    sprite-part < #01, #10, #1C, #15, #08, #$4144 >   ;02
    sprite-part < #01, #00, #2C, #15, #08, #$4146 >   ;03
    sprite-part < #01, #02, #2A, #1D, #00, #$400E >   ;04
    sprite-part < #01, #10, #1C, #05, #18, #$4124 >   ;05
    sprite-part < #01, #0F, #1D, #01, #1C, #$410A >   ;06
    sprite-part < #01, #16, #16, #01, #1C, #$4108 >   ;07
    sprite-part < #01, #1F, #0D, #00, #1D, #$4106 >   ;08
    sprite-part < #01, #2C, #00, #01, #1C, #$4104 >   ;09
  ] >
]

sprite_group_14ADEF [
  sprite-group < #0A, #26, #23, #08, #F8, #F0, #01, #01, #01, #1A, #E0, #20, #08, [
    sprite-part < #01, #0B, #15, #00, #1B, #$408A >   ;00
    sprite-part < #01, #10, #10, #03, #18, #$4124 >   ;01
    sprite-part < #01, #00, #20, #03, #18, #$4126 >   ;02
    sprite-part < #01, #10, #10, #13, #08, #$4144 >   ;03
    sprite-part < #01, #00, #20, #13, #08, #$4146 >   ;04
    sprite-part < #01, #02, #1E, #1B, #00, #$400E >   ;05
    sprite-part < #01, #10, #10, #00, #1B, #$40E8 >   ;06
    sprite-part < #01, #20, #00, #00, #1B, #$40E6 >   ;07
  ] >
]

sprite_group_14AE34 [
  sprite-group < #0A, #16, #2B, #08, #F8, #F0, #01, #01, #01, #10, #E1, #1F, #07, [
    sprite-part < #01, #0B, #05, #08, #1B, #$408A >   ;00
    sprite-part < #01, #0A, #06, #00, #23, #$40EA >   ;01
    sprite-part < #01, #10, #00, #0B, #18, #$4124 >   ;02
    sprite-part < #01, #00, #10, #0B, #18, #$4126 >   ;03
    sprite-part < #01, #10, #00, #1B, #08, #$4144 >   ;04
    sprite-part < #01, #00, #10, #1B, #08, #$4146 >   ;05
    sprite-part < #01, #02, #0E, #23, #00, #$400E >   ;06
  ] >
]

sprite_group_14AE72 [
  sprite-group < #16, #10, #2B, #08, #F8, #F0, #01, #01, #EB, #16, #D7, #1A, #09, [
    sprite-part < #01, #06, #10, #0A, #19, #$0140 >   ;00
    sprite-part < #01, #00, #16, #10, #13, #$C12A >   ;01
    sprite-part < #01, #06, #10, #1A, #09, #$0160 >   ;02
    sprite-part < #01, #16, #00, #1A, #09, #$0162 >   ;03
    sprite-part < #01, #0E, #08, #23, #00, #$000E >   ;04
    sprite-part < #01, #16, #00, #0A, #19, #$00A2 >   ;05
    sprite-part < #01, #0E, #08, #00, #23, #$0004 >   ;06
    sprite-part < #01, #10, #06, #01, #22, #$C148 >   ;07
    sprite-part < #01, #00, #16, #00, #23, #$C14A >   ;08
  ] >
]

sprite_group_14AEBE [
  sprite-group < #14, #10, #39, #08, #F8, #F0, #01, #01, #ED, #1C, #C9, #1D, #0A, [
    sprite-part < #01, #00, #14, #00, #31, #$C18A >   ;00
    sprite-part < #01, #00, #14, #10, #21, #$C16A >   ;01
    sprite-part < #01, #10, #04, #10, #21, #$C168 >   ;02
    sprite-part < #01, #14, #00, #18, #19, #$0142 >   ;03
    sprite-part < #01, #04, #10, #18, #19, #$0140 >   ;04
    sprite-part < #01, #0C, #08, #0E, #23, #$0004 >   ;05
    sprite-part < #01, #04, #10, #28, #09, #$0160 >   ;06
    sprite-part < #01, #14, #00, #28, #09, #$0162 >   ;07
    sprite-part < #01, #0C, #08, #31, #00, #$000E >   ;08
    sprite-part < #01, #10, #04, #00, #31, #$C188 >   ;09
  ] >
]

sprite_group_14AF11 [
  sprite-group < #18, #13, #54, #08, #F8, #F0, #01, #01, #EB, #22, #AB, #35, #0C, [
    sprite-part < #01, #1B, #00, #30, #1C, #$C10C >   ;00
    sprite-part < #01, #18, #03, #33, #19, #$0142 >   ;01
    sprite-part < #01, #08, #13, #33, #19, #$0140 >   ;02
    sprite-part < #01, #10, #0B, #29, #23, #$0004 >   ;03
    sprite-part < #01, #08, #13, #43, #09, #$0160 >   ;04
    sprite-part < #01, #18, #03, #43, #09, #$0162 >   ;05
    sprite-part < #01, #10, #0B, #4C, #00, #$000E >   ;06
    sprite-part < #01, #14, #07, #20, #2C, #$C14C >   ;07
    sprite-part < #01, #14, #07, #10, #3C, #$C16C >   ;08
    sprite-part < #01, #10, #0B, #00, #4C, #$C18C >   ;09
    sprite-part < #01, #00, #1B, #00, #4C, #$C18E >   ;0A
    sprite-part < #01, #04, #17, #10, #3C, #$C128 >   ;0B
  ] >
]

sprite_group_14AF72 [
  sprite-group < #10, #14, #52, #08, #F8, #F0, #01, #01, #F8, #16, #AB, #40, #0A, [
    sprite-part < #01, #14, #00, #2E, #1C, #$C10C >   ;00
    sprite-part < #01, #00, #14, #31, #19, #$0140 >   ;01
    sprite-part < #01, #10, #04, #31, #19, #$0142 >   ;02
    sprite-part < #01, #00, #14, #41, #09, #$0160 >   ;03
    sprite-part < #01, #10, #04, #41, #09, #$0162 >   ;04
    sprite-part < #01, #08, #0C, #27, #23, #$0004 >   ;05
    sprite-part < #01, #08, #0C, #4A, #00, #$000E >   ;06
    sprite-part < #01, #12, #02, #1E, #2C, #$C12E >   ;07
    sprite-part < #01, #12, #02, #0F, #3B, #$C14E >   ;08
    sprite-part < #01, #10, #04, #00, #4A, #$C16E >   ;09
  ] >
]

sprite_group_14AFC5 [
  sprite-group < #10, #18, #44, #08, #F8, #F0, #01, #01, #F8, #1E, #B7, #40, #0A, [
    sprite-part < #01, #17, #01, #1F, #1D, #$C10E >   ;00
    sprite-part < #01, #00, #18, #23, #19, #$0140 >   ;01
    sprite-part < #01, #10, #08, #23, #19, #$0142 >   ;02
    sprite-part < #01, #00, #18, #33, #09, #$0160 >   ;03
    sprite-part < #01, #10, #08, #33, #09, #$0162 >   ;04
    sprite-part < #01, #08, #10, #19, #23, #$0004 >   ;05
    sprite-part < #01, #08, #10, #3C, #00, #$000E >   ;06
    sprite-part < #01, #17, #01, #12, #2A, #$C12E >   ;07
    sprite-part < #01, #18, #00, #0A, #32, #$C14E >   ;08
    sprite-part < #01, #17, #01, #00, #3C, #$C16E >   ;09
  ] >
]

sprite_group_14B018 [
  sprite-group < #10, #18, #34, #08, #F8, #F0, #01, #01, #F7, #21, #C7, #1F, #08, [
    sprite-part < #01, #18, #00, #0F, #1D, #$C0C4 >   ;00
    sprite-part < #01, #00, #18, #13, #19, #$0140 >   ;01
    sprite-part < #01, #10, #08, #13, #19, #$0142 >   ;02
    sprite-part < #01, #00, #18, #23, #09, #$0160 >   ;03
    sprite-part < #01, #10, #08, #23, #09, #$0162 >   ;04
    sprite-part < #01, #08, #10, #09, #23, #$0004 >   ;05
    sprite-part < #01, #08, #10, #2C, #00, #$000E >   ;06
    sprite-part < #01, #18, #00, #00, #2C, #$C0E4 >   ;07
  ] >
]

sprite_group_14B05D [
  sprite-group < #10, #17, #2B, #08, #F8, #F0, #01, #01, #F8, #1A, #E1, #16, #07, [
    sprite-part < #01, #17, #00, #0C, #17, #$C0A4 >   ;00
    sprite-part < #01, #00, #17, #0A, #19, #$0140 >   ;01
    sprite-part < #01, #10, #07, #0A, #19, #$0142 >   ;02
    sprite-part < #01, #00, #17, #1A, #09, #$0160 >   ;03
    sprite-part < #01, #10, #07, #1A, #09, #$0162 >   ;04
    sprite-part < #01, #08, #0F, #00, #23, #$0004 >   ;05
    sprite-part < #01, #08, #0F, #23, #00, #$000E >   ;06
  ] >
]