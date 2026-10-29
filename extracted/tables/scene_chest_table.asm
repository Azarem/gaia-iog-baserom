; Treasure chest placement (Bank 01, 109992-110726 = $01:ADA8): a pointer table of 255 words (scene ID $00-$FE) followed by the chest lists. Only 39 scenes have chests, in 46 records; the other 216 entries point at one shared empty list (chest_list_none, a single $FF byte). The table holds chest records only; a list ends at a record whose first (X) byte has bit 7 set.
; 
; === RECORD (4 bytes, extraction: chest-entry < X, Y, contents, flag >) ===
; 
; | Byte | Field |
; |------|-------|
; | +0 | X tile of the chest's left column. A value with bit 7 set ends the list ($FF in every list) |
; | +1 | Y tile of the chest's BOTTOM row (the top row is Y-1) |
; | +2 | Contents: the item ID given by GiveItemToPlayer (names in system_strings.item_name_table); 0 = flag-only chest (shows 'It is empty!') |
; | +3 | Bits 0-6: event flag ($0200 group, TestEventFlag_0200 / SetEventFlag_0200) set when the chest is opened; bit 7: open with the fanfare (ChestOpeningActor with the music transition) instead of the plain 'found' dialogue |
; 
; A chest is 2x2 map tiles: closed $FA/$FB (top row) and $F8/$F9 (bottom row), open $FE/$FF and $FC/$FD. The list is chosen by the scene index $0646 (scene x 2) into the pointer table.
; 
; === READERS ===
; 
; - PlaceOpenedChestTiles (warps_interaction): at scene build, every record whose flag is set is drawn open.
; - HandleChestInteraction (warps_interaction, via CheckWarpAndChest): matches the chest tile in front of the player against bytes +0 / +1, then DrawChestTiles and GiveItemToPlayer. A chest tile with no record shows 'The jewel box is tightly closed.'
; - radar_map_screen: one icon for every chest whose flag is still clear.
; 
; === CONTENT (all 46 records; item numbers as in item_name_table) ===
; 
; | Scene | Records < X, Y -> contents, flag > (F = fanfare) |
; |-------|-----------------------------------------------|
; | $0E | 04,1A -> Herb, $01 |
; | $10 | 07,08 -> Red Jewel, $02 |
; | $12 | 11,1E -> Red Jewel, $03 |
; | $1D | 06,06 -> Blue Block, $04 F |
; | $21 | 02,17 -> Herb, $05 |
; | $26 | 10,1B -> Herb, $06; 08,1F -> Red Jewel, $07 |
; | $2E | 25,19 -> Mystic Statue ($38), $08 F |
; | $3F | 38,27 -> Herb, $09 |
; | $4D | 39,31 -> Crystal Ball, $0A F; 09,33 -> Herb, $0B; 34,05 -> Red Jewel, $0C |
; | $50 | 37,06 -> Crystal Ball, $0D F |
; | $51 | 03,2F -> Crystal Ball, $0E F |
; | $52 | 07,08 -> Red Jewel, $0F |
; | $53 | 35,32 -> Herb, $10; 31,36 -> Crystal Ball, $11 F |
; | $5A, $5B, $5C | 37,1A / 07,07 / 09,17 -> Red Jewel, $12 / $13 / $14 |
; | $5F | 20,19 -> Rama Statue, $15 F; 2F,27 -> Red Jewel, $16 |
; | $60 | 1E,18 -> flag only, $2E; 2D,1C -> Rama Statue, $17 F |
; | $61 | 0A,33 -> flag only, $18 |
; | $70 | 07,28 -> Red Jewel, $19 |
; | $74 | 27,08 -> Magic Dust, $1A F |
; | $75 | 47,08 -> Herb, $1B; 57,08 -> Red Jewel, $1C |
; | $83 | 1A,59 -> Red Jewel, $1D |
; | $85 | 05,1A -> Herb, $1E |
; | $A2 | 18,36 -> Red Jewel, $1F |
; | $A4, $A6, $A7 | 12,0B / 05,08 / 22,10 -> Mushroom Drop, $20 / $21 / $22 F |
; | $A9 | 0E,05 -> Teapot, $23 F |
; | $B1 | 67,05 -> Red Jewel, $24 |
; | $B5 | 07,4E -> Herb, $25 |
; | $B9, $BB, $BE | 07,06 / 11,20 / 05,16 -> Red Jewel, $26 / $27 / $28 |
; | $D1, $D4, $D6, $D9 | 37,59 / 46,49 / 47,09 / 75,29 -> Red Jewel, $29 / $2A / $2B / $2C |
; | $E9 | 37,16 -> Herb, $2D |
; 
; Counts: 44 item chests (21 Red Jewel, 10 Herb, 4 Crystal Ball, 3 Mushroom Drop, 2 Rama Statue, and one each of Blue Block, Mystic Statue, Magic Dust, Teapot) and 2 flag-only chests (scenes $60 and $61). The 13 records with the fanfare bit are exactly the chests that hold something other than a Herb or a Red Jewel. Each flag $01-$2E is used once; $2E is the flag-only chest of scene $60, out of sequence.
; 
; Byte check: 734 = 255 x 2 (pointers) + 1 (the shared empty list) + 46 x 4 (records) + 39 (one $FF per non-empty list). The extraction does not print the $FF terminators.
---------------------------------------------

?BANK 01

---------------------------------------------

; Pointer table: 255 words, index = scene ID ($00-$FE; scene $FF has no entry). 216 entries point at chest_list_none; 39 scenes point at their own list.

scene_chest_table [
  &chest_list_none   ;00
  &chest_list_none   ;01
  &chest_list_none   ;02
  &chest_list_none   ;03
  &chest_list_none   ;04
  &chest_list_none   ;05
  &chest_list_none   ;06
  &chest_list_none   ;07
  &chest_list_none   ;08
  &chest_list_none   ;09
  &chest_list_none   ;0A
  &chest_list_none   ;0B
  &chest_list_none   ;0C
  &chest_list_none   ;0D
  &chest_list_scene_0E   ;0E
  &chest_list_none   ;0F
  &chest_list_scene_10   ;10
  &chest_list_none   ;11
  &chest_list_scene_12   ;12
  &chest_list_none   ;13
  &chest_list_none   ;14
  &chest_list_none   ;15
  &chest_list_none   ;16
  &chest_list_none   ;17
  &chest_list_none   ;18
  &chest_list_none   ;19
  &chest_list_none   ;1A
  &chest_list_none   ;1B
  &chest_list_none   ;1C
  &chest_list_scene_1D   ;1D
  &chest_list_none   ;1E
  &chest_list_none   ;1F
  &chest_list_none   ;20
  &chest_list_scene_21   ;21
  &chest_list_none   ;22
  &chest_list_none   ;23
  &chest_list_none   ;24
  &chest_list_none   ;25
  &chest_list_scene_26   ;26
  &chest_list_none   ;27
  &chest_list_none   ;28
  &chest_list_none   ;29
  &chest_list_none   ;2A
  &chest_list_none   ;2B
  &chest_list_none   ;2C
  &chest_list_none   ;2D
  &chest_list_scene_2E   ;2E
  &chest_list_none   ;2F
  &chest_list_none   ;30
  &chest_list_none   ;31
  &chest_list_none   ;32
  &chest_list_none   ;33
  &chest_list_none   ;34
  &chest_list_none   ;35
  &chest_list_none   ;36
  &chest_list_none   ;37
  &chest_list_none   ;38
  &chest_list_none   ;39
  &chest_list_none   ;3A
  &chest_list_none   ;3B
  &chest_list_none   ;3C
  &chest_list_none   ;3D
  &chest_list_none   ;3E
  &chest_list_scene_3F   ;3F
  &chest_list_none   ;40
  &chest_list_none   ;41
  &chest_list_none   ;42
  &chest_list_none   ;43
  &chest_list_none   ;44
  &chest_list_none   ;45
  &chest_list_none   ;46
  &chest_list_none   ;47
  &chest_list_none   ;48
  &chest_list_none   ;49
  &chest_list_none   ;4A
  &chest_list_none   ;4B
  &chest_list_none   ;4C
  &chest_list_scene_4D   ;4D
  &chest_list_none   ;4E
  &chest_list_none   ;4F
  &chest_list_scene_50   ;50
  &chest_list_scene_51   ;51
  &chest_list_scene_52   ;52
  &chest_list_scene_53   ;53
  &chest_list_none   ;54
  &chest_list_none   ;55
  &chest_list_none   ;56
  &chest_list_none   ;57
  &chest_list_none   ;58
  &chest_list_none   ;59
  &chest_list_scene_5A   ;5A
  &chest_list_scene_5B   ;5B
  &chest_list_scene_5C   ;5C
  &chest_list_none   ;5D
  &chest_list_none   ;5E
  &chest_list_scene_5F   ;5F
  &chest_list_scene_60   ;60
  &chest_list_scene_61   ;61
  &chest_list_none   ;62
  &chest_list_none   ;63
  &chest_list_none   ;64
  &chest_list_none   ;65
  &chest_list_none   ;66
  &chest_list_none   ;67
  &chest_list_none   ;68
  &chest_list_none   ;69
  &chest_list_none   ;6A
  &chest_list_none   ;6B
  &chest_list_none   ;6C
  &chest_list_none   ;6D
  &chest_list_none   ;6E
  &chest_list_none   ;6F
  &chest_list_scene_70   ;70
  &chest_list_none   ;71
  &chest_list_none   ;72
  &chest_list_none   ;73
  &chest_list_scene_74   ;74
  &chest_list_scene_75   ;75
  &chest_list_none   ;76
  &chest_list_none   ;77
  &chest_list_none   ;78
  &chest_list_none   ;79
  &chest_list_none   ;7A
  &chest_list_none   ;7B
  &chest_list_none   ;7C
  &chest_list_none   ;7D
  &chest_list_none   ;7E
  &chest_list_none   ;7F
  &chest_list_none   ;80
  &chest_list_none   ;81
  &chest_list_none   ;82
  &chest_list_scene_83   ;83
  &chest_list_none   ;84
  &chest_list_scene_85   ;85
  &chest_list_none   ;86
  &chest_list_none   ;87
  &chest_list_none   ;88
  &chest_list_none   ;89
  &chest_list_none   ;8A
  &chest_list_none   ;8B
  &chest_list_none   ;8C
  &chest_list_none   ;8D
  &chest_list_none   ;8E
  &chest_list_none   ;8F
  &chest_list_none   ;90
  &chest_list_none   ;91
  &chest_list_none   ;92
  &chest_list_none   ;93
  &chest_list_none   ;94
  &chest_list_none   ;95
  &chest_list_none   ;96
  &chest_list_none   ;97
  &chest_list_none   ;98
  &chest_list_none   ;99
  &chest_list_none   ;9A
  &chest_list_none   ;9B
  &chest_list_none   ;9C
  &chest_list_none   ;9D
  &chest_list_none   ;9E
  &chest_list_none   ;9F
  &chest_list_none   ;A0
  &chest_list_none   ;A1
  &chest_list_scene_A2   ;A2
  &chest_list_none   ;A3
  &chest_list_scene_A4   ;A4
  &chest_list_none   ;A5
  &chest_list_scene_A6   ;A6
  &chest_list_scene_A7   ;A7
  &chest_list_none   ;A8
  &chest_list_scene_A9   ;A9
  &chest_list_none   ;AA
  &chest_list_none   ;AB
  &chest_list_none   ;AC
  &chest_list_none   ;AD
  &chest_list_none   ;AE
  &chest_list_none   ;AF
  &chest_list_none   ;B0
  &chest_list_scene_B1   ;B1
  &chest_list_none   ;B2
  &chest_list_none   ;B3
  &chest_list_none   ;B4
  &chest_list_scene_B5   ;B5
  &chest_list_none   ;B6
  &chest_list_none   ;B7
  &chest_list_none   ;B8
  &chest_list_scene_B9   ;B9
  &chest_list_none   ;BA
  &chest_list_scene_BB   ;BB
  &chest_list_none   ;BC
  &chest_list_none   ;BD
  &chest_list_scene_BE   ;BE
  &chest_list_none   ;BF
  &chest_list_none   ;C0
  &chest_list_none   ;C1
  &chest_list_none   ;C2
  &chest_list_none   ;C3
  &chest_list_none   ;C4
  &chest_list_none   ;C5
  &chest_list_none   ;C6
  &chest_list_none   ;C7
  &chest_list_none   ;C8
  &chest_list_none   ;C9
  &chest_list_none   ;CA
  &chest_list_none   ;CB
  &chest_list_none   ;CC
  &chest_list_none   ;CD
  &chest_list_none   ;CE
  &chest_list_none   ;CF
  &chest_list_none   ;D0
  &chest_list_scene_D1   ;D1
  &chest_list_none   ;D2
  &chest_list_none   ;D3
  &chest_list_scene_D4   ;D4
  &chest_list_none   ;D5
  &chest_list_scene_D6   ;D6
  &chest_list_none   ;D7
  &chest_list_none   ;D8
  &chest_list_scene_D9   ;D9
  &chest_list_none   ;DA
  &chest_list_none   ;DB
  &chest_list_none   ;DC
  &chest_list_none   ;DD
  &chest_list_none   ;DE
  &chest_list_none   ;DF
  &chest_list_none   ;E0
  &chest_list_none   ;E1
  &chest_list_none   ;E2
  &chest_list_none   ;E3
  &chest_list_none   ;E4
  &chest_list_none   ;E5
  &chest_list_none   ;E6
  &chest_list_none   ;E7
  &chest_list_none   ;E8
  &chest_list_scene_E9   ;E9
  &chest_list_none   ;EA
  &chest_list_none   ;EB
  &chest_list_none   ;EC
  &chest_list_none   ;ED
  &chest_list_none   ;EE
  &chest_list_none   ;EF
  &chest_list_none   ;F0
  &chest_list_none   ;F1
  &chest_list_none   ;F2
  &chest_list_none   ;F3
  &chest_list_none   ;F4
  &chest_list_none   ;F5
  &chest_list_none   ;F6
  &chest_list_none   ;F7
  &chest_list_none   ;F8
  &chest_list_none   ;F9
  &chest_list_none   ;FA
  &chest_list_none   ;FB
  &chest_list_none   ;FC
  &chest_list_none   ;FD
  &chest_list_none   ;FE
]

---------------------------------------------
; The shared empty list (just the $FF terminator), used by every scene without a chest.

chest_list_none [
]

---------------------------------------------
; First non-empty list: scene $0E, one Herb chest (flag $01).

chest_list_scene_0E [
  chest-entry < #04, #1A, #06, #01 >
]

chest_list_scene_10 [
  chest-entry < #07, #08, #01, #02 >
]

chest_list_scene_12 [
  chest-entry < #11, #1E, #01, #03 >
]

chest_list_scene_1D [
  chest-entry < #06, #06, #07, #84 >
]

chest_list_scene_21 [
  chest-entry < #02, #17, #06, #05 >
]

chest_list_scene_26 [
  chest-entry < #10, #1B, #06, #06 >   ;00
  chest-entry < #08, #1F, #01, #07 >   ;01
]

---------------------------------------------
; Scene $2E: the Mystic Statue chest (item $38, flag $08, fanfare).

chest_list_scene_2E [
  chest-entry < #25, #19, #38, #88 >
]

chest_list_scene_3F [
  chest-entry < #38, #27, #06, #09 >
]

---------------------------------------------
; Scene $4D: the only list with 3 chests (Crystal Ball with fanfare, Herb, Red Jewel).

chest_list_scene_4D [
  chest-entry < #39, #31, #0E, #8A >   ;00
  chest-entry < #09, #33, #06, #0B >   ;01
  chest-entry < #34, #05, #01, #0C >   ;02
]

chest_list_scene_50 [
  chest-entry < #37, #06, #0E, #8D >
]

chest_list_scene_51 [
  chest-entry < #03, #2F, #0E, #8E >
]

chest_list_scene_52 [
  chest-entry < #07, #08, #01, #0F >
]

chest_list_scene_53 [
  chest-entry < #35, #32, #06, #10 >   ;00
  chest-entry < #31, #36, #0E, #91 >   ;01
]

chest_list_scene_5A [
  chest-entry < #37, #1A, #01, #12 >
]

chest_list_scene_5B [
  chest-entry < #07, #07, #01, #13 >
]

chest_list_scene_5C [
  chest-entry < #09, #17, #01, #14 >
]

chest_list_scene_5F [
  chest-entry < #20, #19, #13, #95 >   ;00
  chest-entry < #2F, #27, #01, #16 >   ;01
]

---------------------------------------------
; Scene $60: the first record is a flag-only chest (contents 0, flag $2E, the only flag out of sequence), the second a Rama Statue chest (flag $17, fanfare).

chest_list_scene_60 [
  chest-entry < #1E, #18, #00, #2E >   ;00
  chest-entry < #2D, #1C, #13, #97 >   ;01
]

---------------------------------------------
; Scene $61: a single flag-only chest (contents 0, flag $18); it shows 'It is empty!' and sets its flag.

chest_list_scene_61 [
  chest-entry < #0A, #33, #00, #18 >
]

chest_list_scene_70 [
  chest-entry < #07, #28, #01, #19 >
]

chest_list_scene_74 [
  chest-entry < #27, #08, #14, #9A >
]

chest_list_scene_75 [
  chest-entry < #47, #08, #06, #1B >   ;00
  chest-entry < #57, #08, #01, #1C >   ;01
]

chest_list_scene_83 [
  chest-entry < #1A, #59, #01, #1D >
]

chest_list_scene_85 [
  chest-entry < #05, #1A, #06, #1E >
]

chest_list_scene_A2 [
  chest-entry < #18, #36, #01, #1F >
]

chest_list_scene_A4 [
  chest-entry < #12, #0B, #1A, #A0 >
]

chest_list_scene_A6 [
  chest-entry < #05, #08, #1A, #A1 >
]

chest_list_scene_A7 [
  chest-entry < #22, #10, #1A, #A2 >
]

chest_list_scene_A9 [
  chest-entry < #0E, #05, #19, #A3 >
]

chest_list_scene_B1 [
  chest-entry < #67, #05, #01, #24 >
]

chest_list_scene_B5 [
  chest-entry < #07, #4E, #06, #25 >
]

chest_list_scene_B9 [
  chest-entry < #07, #06, #01, #26 >
]

chest_list_scene_BB [
  chest-entry < #11, #20, #01, #27 >
]

chest_list_scene_BE [
  chest-entry < #05, #16, #01, #28 >
]

chest_list_scene_D1 [
  chest-entry < #37, #59, #01, #29 >
]

chest_list_scene_D4 [
  chest-entry < #46, #49, #01, #2A >
]

chest_list_scene_D6 [
  chest-entry < #47, #09, #01, #2B >
]

chest_list_scene_D9 [
  chest-entry < #75, #29, #01, #2C >
]

chest_list_scene_E9 [
  chest-entry < #37, #16, #06, #2D >
]