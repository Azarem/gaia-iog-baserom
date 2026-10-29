; Warp table of all scenes (Bank 01, 98868-108893, 10026 bytes): 255 word pointers, indexed by scene ID ($00-$FE, sceneTableIndex $0646), to 200 `warp-def` lists. InitWarpTable (warps_interaction) reads it when a scene is set up; CheckWarpRectangles tests the player against it every frame. The second list holds forced-walk warps (see below), all of them vertical walks.
; 
; === LIST FORMAT ===
; 
; A list is `[scene-warps] $FF [forced-walk warps] $FF`. Both terminators are the single byte $FF (a negative byte 0 ends a list in InitWarpTable, $FF in CheckWarpRectangles); the extractor does not print them, so an empty list is 2 bytes. 200 lists hold 543 scene-warps x 12 B + 200 forced-walk warps x 13 B + 400 B of terminators = 9516 B, and 255 x 2 = 510 B of pointers, which is exactly the 10026 bytes. Pointers share lists: 51 scene IDs point at the empty list warp_def_empty, $E6-$E9 share warp_def_E6 and $EB-$ED share warp_def_EB; 8 lists are empty.
; 
; Both kinds start with the trigger rectangle (bytes +0 X tile, +1 Y tile, +2 width, +3 height, in 16-pixel tiles). The player triggers it when playerXTile/YTile fall inside the rectangle AND the pixel position lies in the first (16 x size - 15) pixels (ConvertWarpToPixels).
; 
; === scene-warp (12 bytes): change scene (ExecuteWarp) ===
; 
; +4 destination scene (sceneNext $0642), +5 word destination X pixel, +7 word destination Y pixel (warpDestX/Y), +9 facing (warpFacing $0650; the low bits index walk_step_table, bit 7 = save warp: ExecuteWarp also stores the entry in sceneSaveData as the game-over reload point), +10 word packed camera window (warpScrollParams $0652: low byte = offsetY<<4 | offsetX, high byte = boundsY<<4 | boundsX, in 256-pixel units; read by InitCameraBounds). Example: warp_def_01 entry ;00 `< #11, #0D, #02, #02, #08, #$01B8, #$0080, #00, #$1200 >` = trigger tiles ($11,$0D) 2 x 2, go to scene $08 at pixel (440, 128), facing 0, camera window $1200.
; 
; Data facts: facing is $00 x225, $03 x229, $06 x32, $07 x32 and $01 x2, plus bit 7 on 23 entries (11 x $80, 9 x $83, 2 x $87, 1 x $86). All 543 entries carry a nonzero camera window (61 distinct values; $1100 x86 and $4400 x84 are the commonest), so the 'normal bounds' path of InitCameraBounds is never taken from this table. 36 entries lead to scene $E6 (sE6_gaia, the Dark Space scene) and all use destination (120, 192), facing 0 and window $1100.
; 
; === forced-walk warp (13 bytes; the extractor type is `stair-warp`) ===
; 
; Not a scene change: ExecuteForcedWalkWarp keeps the player in the scene, pans the camera and walks the player by script. Layout by BYTE (the extractor splits it into words at the wrong boundaries): +4/+5 camera window (same packing as above, warpScrollParams), +6 direction and pan list (scrollStepTableBase: bit 7 = north, bits 4/5 = east/west, otherwise south; the low nibble indexes forced_walk_pan_table), +7..+12 a 6-byte walk stream `[direction byte][X offset word][Y offset word][final direction byte]` (the pointer to +7 goes to warpFacing; ForcedWalk* in forced_walk adds the offsets to the player position). Example: warp_def_E3 `stair-warp < #29, #27, #02, #02, #$4430, #$0240, #$0000, #08, #$0301 >` = bytes 29 27 02 02 | 30 44 | 40 | 02 00 00 08 01 03: window $4430, south (bit 6 is not decoded), pan list $00, stream: direction 2, X offset 0, Y offset +$0108 (264 px), final direction 3. The next entry ;01 goes back (byte 6 $80 = north, Y offset $FF10 = -240 px).
; 
; Data facts: all 200 are vertical, 100 north (bit 7) and 100 south (bit 6 only, the default). East/West (bits 4/5) never occur, so ForcedWalkEast/West are not reachable from this table. The pan list index in the low nibble of byte 6 is $00 for 143 entries (256-pixel pan), $03 x11, $02 x10, $01 x5, $0D x5, $0E x5 and 21 more spread over $04-$0C and $0F. Not traced: which warp uses which pan list.
; 
; === OTHER NOTES ===
; 
; GameOverSequence reloads a warp from the entry+4 pointer stored in reviveWarpPtr ($0AF4; every warp) and sceneSaveData (save warps). The two forced-walk entries of warp_def_03 use unusual first stream bytes ($04, $05); not traced: what the walk does with them.
---------------------------------------------

?BANK 01

---------------------------------------------

; 255 word pointers to the `warp-def` lists, indexed by scene ID $00-$FE (sceneTableIndex $0646). InitWarpTable stores the selected pointer in $00D4 and finds the forced-walk list at the byte after the first $FF terminator ($00D6). 51 IDs share the empty list warp_def_empty.

scene_warps [
  &warp_def_empty   ;00
  &warp_def_01   ;01
  &warp_def_02   ;02
  &warp_def_03   ;03
  &warp_def_04   ;04
  &warp_def_05   ;05
  &warp_def_06   ;06
  &warp_def_07   ;07
  &warp_def_08   ;08
  &warp_def_09   ;09
  &warp_def_0A   ;0A
  &warp_def_0B   ;0B
  &warp_def_0C   ;0C
  &warp_def_0D   ;0D
  &warp_def_0E   ;0E
  &warp_def_0F   ;0F
  &warp_def_10   ;10
  &warp_def_11   ;11
  &warp_def_12   ;12
  &warp_def_13   ;13
  &warp_def_14   ;14
  &warp_def_15   ;15
  &warp_def_16   ;16
  &warp_def_17   ;17
  &warp_def_18   ;18
  &warp_def_19   ;19
  &warp_def_1A   ;1A
  &warp_def_1B   ;1B
  &warp_def_1C   ;1C
  &warp_def_1D   ;1D
  &warp_def_1E   ;1E
  &warp_def_1F   ;1F
  &warp_def_20   ;20
  &warp_def_21   ;21
  &warp_def_22   ;22
  &warp_def_23   ;23
  &warp_def_24   ;24
  &warp_def_25   ;25
  &warp_def_26   ;26
  &warp_def_27   ;27
  &warp_def_28   ;28
  &warp_def_29   ;29
  &warp_def_2A   ;2A
  &warp_def_2B   ;2B
  &warp_def_2C   ;2C
  &warp_def_2D   ;2D
  &warp_def_2E   ;2E
  &warp_def_2F   ;2F
  &warp_def_30   ;30
  &warp_def_31   ;31
  &warp_def_32   ;32
  &warp_def_33   ;33
  &warp_def_34   ;34
  &warp_def_35   ;35
  &warp_def_36   ;36
  &warp_def_37   ;37
  &warp_def_38   ;38
  &warp_def_39   ;39
  &warp_def_3A   ;3A
  &warp_def_3B   ;3B
  &warp_def_3C   ;3C
  &warp_def_3D   ;3D
  &warp_def_3E   ;3E
  &warp_def_3F   ;3F
  &warp_def_40   ;40
  &warp_def_41   ;41
  &warp_def_42   ;42
  &warp_def_43   ;43
  &warp_def_44   ;44
  &warp_def_45   ;45
  &warp_def_46   ;46
  &warp_def_47   ;47
  &warp_def_empty   ;48
  &warp_def_empty   ;49
  &warp_def_empty   ;4A
  &warp_def_empty   ;4B
  &warp_def_4C   ;4C
  &warp_def_4D   ;4D
  &warp_def_4E   ;4E
  &warp_def_4F   ;4F
  &warp_def_50   ;50
  &warp_def_51   ;51
  &warp_def_52   ;52
  &warp_def_53   ;53
  &warp_def_54   ;54
  &warp_def_55   ;55
  &warp_def_56   ;56
  &warp_def_empty   ;57
  &warp_def_empty   ;58
  &warp_def_empty   ;59
  &warp_def_5A   ;5A
  &warp_def_5B   ;5B
  &warp_def_5C   ;5C
  &warp_def_5D   ;5D
  &warp_def_5E   ;5E
  &warp_def_5F   ;5F
  &warp_def_60   ;60
  &warp_def_61   ;61
  &warp_def_62   ;62
  &warp_def_63   ;63
  &warp_def_64   ;64
  &warp_def_65   ;65
  &warp_def_66   ;66
  &warp_def_67   ;67
  &warp_def_empty   ;68
  &warp_def_69   ;69
  &warp_def_6A   ;6A
  &warp_def_6B   ;6B
  &warp_def_6C   ;6C
  &warp_def_6D   ;6D
  &warp_def_6E   ;6E
  &warp_def_6F   ;6F
  &warp_def_70   ;70
  &warp_def_71   ;71
  &warp_def_72   ;72
  &warp_def_73   ;73
  &warp_def_74   ;74
  &warp_def_75   ;75
  &warp_def_empty   ;76
  &warp_def_empty   ;77
  &warp_def_78   ;78
  &warp_def_79   ;79
  &warp_def_7A   ;7A
  &warp_def_7B   ;7B
  &warp_def_7C   ;7C
  &warp_def_7D   ;7D
  &warp_def_7E   ;7E
  &warp_def_empty   ;7F
  &warp_def_empty   ;80
  &warp_def_empty   ;81
  &warp_def_82   ;82
  &warp_def_83   ;83
  &warp_def_empty   ;84
  &warp_def_85   ;85
  &warp_def_86   ;86
  &warp_def_87   ;87
  &warp_def_88   ;88
  &warp_def_empty   ;89
  &warp_def_8A   ;8A
  &warp_def_8B   ;8B
  &warp_def_empty   ;8C
  &warp_def_empty   ;8D
  &warp_def_empty   ;8E
  &warp_def_empty   ;8F
  &warp_def_empty   ;90
  &warp_def_91   ;91
  &warp_def_92   ;92
  &warp_def_93   ;93
  &warp_def_94   ;94
  &warp_def_95   ;95
  &warp_def_96   ;96
  &warp_def_97   ;97
  &warp_def_98   ;98
  &warp_def_99   ;99
  &warp_def_9A   ;9A
  &warp_def_9B   ;9B
  &warp_def_9C   ;9C
  &warp_def_9D   ;9D
  &warp_def_empty   ;9E
  &warp_def_empty   ;9F
  &warp_def_A0   ;A0
  &warp_def_A1   ;A1
  &warp_def_A2   ;A2
  &warp_def_A3   ;A3
  &warp_def_A4   ;A4
  &warp_def_A5   ;A5
  &warp_def_A6   ;A6
  &warp_def_A7   ;A7
  &warp_def_A8   ;A8
  &warp_def_A9   ;A9
  &warp_def_empty   ;AA
  &warp_def_empty   ;AB
  &warp_def_AC   ;AC
  &warp_def_AD   ;AD
  &warp_def_AE   ;AE
  &warp_def_empty   ;AF
  &warp_def_B0   ;B0
  &warp_def_B1   ;B1
  &warp_def_B2   ;B2
  &warp_def_B3   ;B3
  &warp_def_B4   ;B4
  &warp_def_B5   ;B5
  &warp_def_B6   ;B6
  &warp_def_B7   ;B7
  &warp_def_B8   ;B8
  &warp_def_B9   ;B9
  &warp_def_BA   ;BA
  &warp_def_BB   ;BB
  &warp_def_BC   ;BC
  &warp_def_BD   ;BD
  &warp_def_BE   ;BE
  &warp_def_BF   ;BF
  &warp_def_empty   ;C0
  &warp_def_empty   ;C1
  &warp_def_empty   ;C2
  &warp_def_C3   ;C3
  &warp_def_C4   ;C4
  &warp_def_C5   ;C5
  &warp_def_C6   ;C6
  &warp_def_C7   ;C7
  &warp_def_C8   ;C8
  &warp_def_C9   ;C9
  &warp_def_empty   ;CA
  &warp_def_empty   ;CB
  &warp_def_CC   ;CC
  &warp_def_CD   ;CD
  &warp_def_CE   ;CE
  &warp_def_CF   ;CF
  &warp_def_D0   ;D0
  &warp_def_D1   ;D1
  &warp_def_D2   ;D2
  &warp_def_D3   ;D3
  &warp_def_D4   ;D4
  &warp_def_D5   ;D5
  &warp_def_D6   ;D6
  &warp_def_D7   ;D7
  &warp_def_D8   ;D8
  &warp_def_D9   ;D9
  &warp_def_DA   ;DA
  &warp_def_DB   ;DB
  &warp_def_empty   ;DC
  &warp_def_empty   ;DD
  &warp_def_DE   ;DE
  &warp_def_DF   ;DF
  &warp_def_E0   ;E0
  &warp_def_E1   ;E1
  &warp_def_E2   ;E2
  &warp_def_E3   ;E3
  &warp_def_empty   ;E4
  &warp_def_empty   ;E5
  &warp_def_E6   ;E6
  &warp_def_E6   ;E7
  &warp_def_E6   ;E8
  &warp_def_E6   ;E9
  &warp_def_EA   ;EA
  &warp_def_EB   ;EB
  &warp_def_EB   ;EC
  &warp_def_EB   ;ED
  &warp_def_empty   ;EE
  &warp_def_empty   ;EF
  &warp_def_empty   ;F0
  &warp_def_empty   ;F1
  &warp_def_empty   ;F2
  &warp_def_empty   ;F3
  &warp_def_empty   ;F4
  &warp_def_empty   ;F5
  &warp_def_empty   ;F6
  &warp_def_empty   ;F7
  &warp_def_empty   ;F8
  &warp_def_empty   ;F9
  &warp_def_empty   ;FA
  &warp_def_empty   ;FB
  &warp_def_empty   ;FC
  &warp_def_empty   ;FD
  &warp_def_FE   ;FE
]

---------------------------------------------
; Shared empty list (two $FF terminators): 51 scene IDs point here; they have no scene warps and no forced-walk warps.

warp_def_empty [
  warp-def < [
  ], [
  ] >
]

warp_def_01 [
  warp-def < [
    scene-warp < #11, #0D, #02, #02, #08, #$01B8, #$0080, #00, #$1200 >   ;00
    scene-warp < #13, #0D, #02, #01, #08, #$01B8, #$0080, #00, #$1200 >   ;01
    scene-warp < #12, #22, #01, #03, #03, #$0058, #$00C0, #00, #$1100 >   ;02
    scene-warp < #22, #1E, #01, #03, #04, #$00C8, #$01C0, #00, #$2210 >   ;03
    scene-warp < #07, #22, #01, #03, #05, #$0098, #$00C0, #00, #$1100 >   ;04
    scene-warp < #20, #0B, #01, #03, #06, #$0058, #$01C0, #00, #$2110 >   ;05
    scene-warp < #29, #0B, #01, #03, #07, #$0078, #$00C0, #00, #$1100 >   ;06
    scene-warp < #29, #28, #01, #03, #02, #$0078, #$00C0, #00, #$1100 >   ;07
    scene-warp < #0A, #0B, #02, #01, #08, #$0040, #$0070, #01, #$1200 >   ;08
    scene-warp < #21, #17, #01, #02, #04, #$0030, #$0090, #01, #$1200 >   ;09
    scene-warp < #0E, #05, #01, #01, #E6, #$0078, #$00C0, #00, #$1100 >   ;0A
  ], [
  ] >
]

warp_def_02 [
  warp-def < [
  ], [
  ] >
]

warp_def_03 [
  warp-def < [
    scene-warp < #05, #0D, #02, #02, #01, #$0120, #$0250, #03, #$4300 >
  ], [
    stair-warp < #0B, #05, #01, #02, #$2110, #$0440, #$0000, #48, #$0301 >   ;00
    stair-warp < #0B, #19, #01, #02, #$1100, #$0580, #$0000, #D0, #$01FE >   ;01
  ] >
]

warp_def_04 [
  warp-def < [
    scene-warp < #0C, #1D, #02, #02, #01, #$0220, #$0210, #03, #$4300 >   ;00
    scene-warp < #03, #06, #01, #02, #01, #$0210, #$0150, #00, #$4300 >   ;01
  ], [
    stair-warp < #09, #15, #01, #02, #$1200, #$0080, #$0000, #10, #$01FF >   ;00
    stair-warp < #09, #05, #01, #02, #$2210, #$0240, #$0000, #08, #$0301 >   ;01
  ] >
]

warp_def_05 [
  warp-def < [
    scene-warp < #09, #0D, #02, #02, #01, #$0070, #$0250, #03, #$4300 >
  ], [
  ] >
]

warp_def_06 [
  warp-def < [
    scene-warp < #05, #1D, #02, #02, #01, #$0200, #$00E0, #03, #$4300 >
  ], [
    stair-warp < #03, #17, #01, #02, #$1100, #$0080, #$0000, #10, #$01FF >   ;00
    stair-warp < #03, #07, #01, #02, #$2110, #$0240, #$0000, #08, #$0301 >   ;01
  ] >
]

warp_def_07 [
  warp-def < [
    scene-warp < #07, #0D, #02, #02, #01, #$0290, #$00E0, #03, #$4300 >
  ], [
  ] >
]

warp_def_08 [
  warp-def < [
    scene-warp < #04, #04, #01, #02, #01, #$00C0, #$00B0, #07, #$4300 >   ;00
    scene-warp < #1B, #09, #02, #01, #01, #$0138, #$00E0, #03, #$4300 >   ;01
  ], [
  ] >
]

warp_def_09 [
  warp-def < [
  ], [
  ] >
]

warp_def_0A [
  warp-def < [
    scene-warp < #06, #35, #01, #02, #13, #$0078, #$0050, #03, #$2100 >
  ], [
    stair-warp < #15, #25, #02, #02, #$2410, #$0080, #$0000, #10, #$01FF >   ;00
    stair-warp < #15, #15, #02, #02, #$3420, #$0240, #$0000, #08, #$0301 >   ;01
    stair-warp < #05, #25, #02, #02, #$2410, #$0080, #$0000, #10, #$01FF >   ;02
    stair-warp < #05, #15, #02, #02, #$3420, #$0240, #$0000, #08, #$0301 >   ;03
    stair-warp < #35, #25, #02, #02, #$2410, #$0080, #$0000, #10, #$01FF >   ;04
    stair-warp < #35, #15, #02, #02, #$3420, #$0240, #$0000, #08, #$0301 >   ;05
    stair-warp < #39, #25, #02, #02, #$4430, #$0240, #$0000, #08, #$0301 >   ;06
    stair-warp < #39, #35, #02, #02, #$3420, #$0080, #$0000, #10, #$01FF >   ;07
    stair-warp < #39, #15, #02, #02, #$1400, #$0080, #$0000, #20, #$01FF >   ;08
    stair-warp < #39, #06, #02, #02, #$2410, #$0240, #$0000, #F8, #$0300 >   ;09
  ] >
]

warp_def_0B [
  warp-def < [
    scene-warp < #0D, #2E, #04, #02, #0C, #$0058, #$0050, #03, #$1200 >   ;00
    scene-warp < #1A, #14, #01, #01, #E6, #$0078, #$00C0, #00, #$1100 >   ;01
  ], [
  ] >
]

warp_def_0C [
  warp-def < [
    scene-warp < #05, #02, #02, #02, #0B, #$00F8, #$02D0, #00, #$3200 >   ;00
    scene-warp < #1A, #0C, #02, #02, #0D, #$0058, #$0050, #03, #$4200 >   ;01
  ], [
  ] >
]

warp_def_0D [
  warp-def < [
    scene-warp < #05, #02, #02, #02, #0C, #$01A8, #$00B0, #00, #$1200 >   ;00
    scene-warp < #00, #3E, #20, #02, #0E, #$0308, #$0060, #03, #$2400 >   ;01
  ], [
  ] >
]

warp_def_0E [
  warp-def < [
    scene-warp < #30, #03, #02, #02, #0D, #$0058, #$03D0, #00, #$4200 >   ;00
    scene-warp < #05, #01, #02, #02, #0F, #$0078, #$05D0, #00, #$6100 >   ;01
  ], [
  ] >
]

warp_def_0F [
  warp-def < [
    scene-warp < #07, #03, #02, #02, #11, #$00F8, #$00C0, #00, #$1200 >   ;00
    scene-warp < #07, #5F, #02, #02, #0E, #$0058, #$0040, #03, #$2400 >   ;01
    scene-warp < #0B, #27, #02, #02, #10, #$0078, #$00C0, #00, #$1100 >   ;02
  ], [
  ] >
]

warp_def_10 [
  warp-def < [
    scene-warp < #07, #0D, #02, #02, #0F, #$00B8, #$02A0, #03, #$6100 >
  ], [
  ] >
]

warp_def_11 [
  warp-def < [
    scene-warp < #0F, #0D, #02, #02, #0F, #$0078, #$0050, #03, #$6100 >   ;00
    scene-warp < #0F, #08, #02, #02, #12, #$0278, #$05D0, #00, #$6300 >   ;01
  ], [
  ] >
]

warp_def_12 [
  warp-def < [
    scene-warp < #27, #5E, #02, #01, #11, #$00F8, #$00A0, #03, #$1200 >   ;00
    scene-warp < #18, #03, #02, #02, #13, #$0078, #$01E0, #00, #$2100 >   ;01
    scene-warp < #0A, #4B, #01, #01, #E6, #$0078, #$00C0, #00, #$1100 >   ;02
  ], [
  ] >
]

warp_def_13 [
  warp-def < [
    scene-warp < #07, #1F, #02, #01, #12, #$0188, #$0050, #03, #$6300 >   ;00
    scene-warp < #07, #03, #02, #02, #0A, #$0060, #$0370, #03, #$4430 >   ;01
  ], [
  ] >
]

warp_def_14 [
  warp-def < [
  ], [
  ] >
]

warp_def_15 [
  warp-def < [
    scene-warp < #29, #21, #01, #02, #16, #$0088, #$00C0, #00, #$1100 >   ;00
    scene-warp < #44, #1D, #02, #02, #17, #$0010, #$00A8, #07, #$1100 >   ;01
    scene-warp < #4D, #23, #01, #02, #17, #$0098, #$00C0, #00, #$1100 >   ;02
    scene-warp < #32, #13, #01, #02, #18, #$0058, #$00C0, #00, #$1100 >   ;03
    scene-warp < #0A, #29, #02, #03, #19, #$0078, #$01C0, #00, #$2100 >   ;04
    scene-warp < #43, #07, #01, #01, #E6, #$0078, #$00C0, #00, #$1100 >   ;05
  ], [
  ] >
]

warp_def_16 [
  warp-def < [
    scene-warp < #08, #0D, #02, #02, #15, #$0290, #$0240, #03, #$3500 >
  ], [
  ] >
]

warp_def_17 [
  warp-def < [
    scene-warp < #00, #0A, #01, #02, #15, #$0410, #$01E0, #06, #$3500 >   ;00
    scene-warp < #09, #0D, #02, #02, #15, #$04D0, #$0270, #03, #$3500 >   ;01
  ], [
  ] >
]

warp_def_18 [
  warp-def < [
    scene-warp < #05, #0D, #02, #02, #15, #$0320, #$0170, #03, #$3500 >
  ], [
  ] >
]

warp_def_19 [
  warp-def < [
    scene-warp < #07, #1D, #02, #02, #15, #$00A0, #$02C0, #03, #$3500 >   ;00
    scene-warp < #09, #05, #01, #02, #19, #$0078, #$02C0, #00, #$3120 >   ;01
    scene-warp < #07, #2D, #02, #01, #19, #$0090, #$0070, #03, #$2100 >   ;02
  ], [
  ] >
]

warp_def_1A [
  warp-def < [
    scene-warp < #15, #1D, #02, #02, #15, #$02D8, #$02B0, #00, #$3500 >   ;00
    scene-warp < #0C, #17, #01, #02, #1B, #$00F8, #$01C0, #80, #$2200 >   ;01
  ], [
  ] >
]

warp_def_1B [
  warp-def < [
    scene-warp < #0F, #1D, #02, #02, #1A, #$00C0, #$0190, #03, #$2200 >
  ], [
  ] >
]

warp_def_1C [
  warp-def < [
    scene-warp < #1A, #0B, #01, #02, #1D, #$02A8, #$0060, #83, #$6300 >
  ], [
  ] >
]

warp_def_1D [
  warp-def < [
    scene-warp < #2A, #04, #02, #02, #1C, #$01A0, #$00D0, #03, #$2200 >   ;00
    scene-warp < #04, #25, #02, #03, #1F, #$0038, #$01D0, #00, #$2200 >   ;01
    scene-warp < #19, #21, #02, #03, #20, #$00B8, #$01C0, #00, #$2200 >   ;02
    scene-warp < #04, #45, #02, #03, #21, #$0138, #$03D0, #00, #$4400 >   ;03
    scene-warp < #24, #3D, #02, #03, #22, #$0058, #$03D0, #00, #$4400 >   ;04
    scene-warp < #06, #33, #02, #03, #23, #$01B8, #$02D0, #00, #$3400 >   ;05
    scene-warp < #1E, #03, #02, #03, #25, #$0198, #$01C0, #00, #$2300 >   ;06
    scene-warp < #0E, #07, #02, #03, #25, #$0098, #$01D0, #00, #$2300 >   ;07
    scene-warp < #28, #2B, #02, #03, #26, #$0098, #$02C0, #00, #$3200 >   ;08
    scene-warp < #04, #01, #02, #03, #27, #$0178, #$01C0, #00, #$2400 >   ;09
    scene-warp < #04, #13, #02, #03, #28, #$0178, #$02C0, #00, #$3200 >   ;0A
  ], [
  ] >
]

warp_def_1E [
  warp-def < [
    scene-warp < #3A, #01, #02, #03, #24, #$00F8, #$01D0, #00, #$2200 >   ;00
    scene-warp < #06, #0D, #02, #03, #29, #$0078, #$00C0, #00, #$1100 >   ;01
    scene-warp < #2C, #04, #01, #01, #E6, #$0078, #$00C0, #00, #$1100 >   ;02
  ], [
  ] >
]

warp_def_1F [
  warp-def < [
    scene-warp < #12, #2A, #02, #02, #28, #$0198, #$0040, #03, #$3200 >   ;00
    scene-warp < #0F, #04, #02, #02, #1F, #$01B8, #$02B0, #00, #$3221 >   ;01
    scene-warp < #1B, #2C, #02, #02, #1F, #$00F8, #$0060, #03, #$2200 >   ;02
    scene-warp < #03, #1E, #02, #02, #1D, #$0048, #$0280, #03, #$5300 >   ;03
  ], [
  ] >
]

warp_def_20 [
  warp-def < [
    scene-warp < #0B, #1D, #02, #03, #1D, #$0198, #$0240, #03, #$5300 >   ;00
    scene-warp < #03, #06, #02, #03, #23, #$02D8, #$0040, #03, #$3400 >   ;01
  ], [
  ] >
]

warp_def_21 [
  warp-def < [
    scene-warp < #13, #3E, #02, #03, #1D, #$0048, #$0480, #03, #$5300 >   ;00
    scene-warp < #07, #01, #02, #03, #23, #$0108, #$02B0, #00, #$3400 >   ;01
  ], [
  ] >
]

warp_def_22 [
  warp-def < [
    scene-warp < #05, #3E, #02, #03, #1D, #$0248, #$0400, #03, #$5300 >   ;00
    scene-warp < #1E, #3C, #02, #02, #24, #$00F8, #$0040, #03, #$2200 >   ;01
    scene-warp < #37, #01, #02, #03, #26, #$01B8, #$0040, #03, #$3200 >   ;02
  ], [
  ] >
]

warp_def_23 [
  warp-def < [
    scene-warp < #2D, #01, #02, #03, #20, #$0038, #$0090, #03, #$2200 >   ;00
    scene-warp < #10, #2C, #02, #02, #21, #$0078, #$0040, #03, #$4400 >   ;01
    scene-warp < #1B, #2E, #02, #03, #1D, #$0068, #$0360, #03, #$5300 >   ;02
  ], [
  ] >
]

warp_def_24 [
  warp-def < [
    scene-warp < #0F, #01, #02, #03, #22, #$01E8, #$03B0, #00, #$4400 >   ;00
    scene-warp < #0F, #1E, #02, #03, #1E, #$03A8, #$0040, #83, #$2400 >   ;01
  ], [
  ] >
]

warp_def_25 [
  warp-def < [
    scene-warp < #19, #1D, #02, #03, #1D, #$01E8, #$0060, #03, #$5300 >   ;00
    scene-warp < #09, #1E, #02, #03, #1D, #$00E8, #$00A0, #03, #$5300 >   ;01
    scene-warp < #00, #17, #02, #04, #27, #$03D0, #$0190, #06, #$2400 >   ;02
  ], [
  ] >
]

warp_def_26 [
  warp-def < [
    scene-warp < #1B, #01, #02, #03, #22, #$0378, #$0040, #03, #$4400 >   ;00
    scene-warp < #09, #2D, #02, #03, #1D, #$0288, #$02E0, #03, #$5300 >   ;01
    scene-warp < #1C, #13, #01, #01, #E6, #$0078, #$00C0, #00, #$1100 >   ;02
  ], [
  ] >
]

warp_def_27 [
  warp-def < [
    scene-warp < #3E, #17, #02, #04, #25, #$0020, #$0190, #07, #$2300 >   ;00
    scene-warp < #17, #1D, #02, #03, #1D, #$0048, #$0040, #03, #$5300 >   ;01
  ], [
  ] >
]

warp_def_28 [
  warp-def < [
    scene-warp < #19, #01, #02, #03, #1F, #$0128, #$0290, #00, #$3221 >   ;00
    scene-warp < #17, #2D, #02, #03, #1D, #$0048, #$0160, #03, #$6300 >   ;01
    scene-warp < #11, #07, #01, #01, #E6, #$0078, #$00C0, #00, #$1100 >   ;02
  ], [
  ] >
]

warp_def_29 [
  warp-def < [
    scene-warp < #07, #0D, #02, #02, #1E, #$0068, #$0100, #03, #$2400 >   ;00
    scene-warp < #07, #00, #02, #02, #29, #$0078, #$02C0, #00, #$3110 >   ;01
    scene-warp < #07, #2D, #02, #01, #29, #$0078, #$0020, #03, #$1100 >   ;02
    scene-warp < #08, #17, #04, #02, #2C, #$0000, #$0000, #00, #$3300 >   ;03
  ], [
  ] >
]

warp_def_2A [
  warp-def < [
  ], [
    stair-warp < #03, #17, #01, #02, #$1100, #$0080, #$0000, #10, #$01FF >   ;00
    stair-warp < #03, #07, #01, #02, #$2110, #$0240, #$0000, #08, #$0301 >   ;01
  ] >
]

warp_def_2B [
  warp-def < [
    scene-warp < #20, #26, #01, #01, #2D, #$0020, #$00A0, #07, #$1300 >
  ], [
  ] >
]

warp_def_2C [
  warp-def < [
    scene-warp < #20, #26, #01, #01, #2E, #$0020, #$00A0, #07, #$1300 >
  ], [
  ] >
]

warp_def_2D [
  warp-def < [
    scene-warp < #00, #0A, #01, #02, #2B, #$01E0, #$0250, #06, #$3300 >
  ], [
    stair-warp < #05, #06, #01, #02, #$2310, #$0240, #$0000, #08, #$0301 >   ;00
    stair-warp < #05, #16, #01, #02, #$1300, #$0080, #$0000, #10, #$01FF >   ;01
  ] >
]

warp_def_2E [
  warp-def < [
    scene-warp < #00, #0A, #01, #02, #2C, #$01E0, #$0250, #06, #$3300 >
  ], [
    stair-warp < #05, #06, #01, #02, #$2310, #$0240, #$0000, #08, #$0301 >   ;00
    stair-warp < #05, #16, #01, #02, #$1300, #$0080, #$0000, #10, #$01FF >   ;01
  ] >
]

warp_def_2F [
  warp-def < [
  ], [
  ] >
]

warp_def_30 [
  warp-def < [
    scene-warp < #0C, #07, #01, #02, #31, #$0028, #$00C0, #00, #$1100 >
  ], [
  ] >
]

warp_def_31 [
  warp-def < [
    scene-warp < #02, #0D, #02, #01, #30, #$00C0, #$0090, #03, #$2100 >
  ], [
  ] >
]

warp_def_32 [
  warp-def < [
    scene-warp < #04, #0C, #01, #02, #33, #$0028, #$00C0, #00, #$1100 >   ;00
    scene-warp < #19, #0C, #01, #02, #34, #$0078, #$00C0, #00, #$1100 >   ;01
    scene-warp < #2F, #0D, #01, #02, #35, #$0118, #$00C0, #00, #$1200 >   ;02
    scene-warp < #2D, #06, #01, #02, #35, #$00E0, #$0090, #03, #$1200 >   ;03
    scene-warp < #07, #29, #01, #02, #36, #$00A8, #$01C0, #00, #$2110 >   ;04
    scene-warp < #16, #2B, #01, #02, #37, #$0078, #$01C0, #00, #$2110 >   ;05
    scene-warp < #14, #21, #01, #02, #37, #$0030, #$0090, #03, #$1100 >   ;06
    scene-warp < #21, #29, #01, #02, #38, #$00B8, #$01C0, #00, #$2110 >   ;07
    scene-warp < #27, #21, #01, #02, #39, #$0048, #$01C0, #00, #$2210 >   ;08
    scene-warp < #2F, #29, #01, #02, #3A, #$0038, #$00C0, #00, #$1100 >   ;09
    scene-warp < #2C, #23, #01, #02, #3A, #$0030, #$0090, #03, #$1100 >   ;0A
    scene-warp < #41, #2A, #01, #02, #3B, #$0098, #$00C0, #00, #$1100 >   ;0B
    scene-warp < #48, #06, #01, #02, #3C, #$0078, #$00C0, #00, #$1100 >   ;0C
  ], [
  ] >
]

warp_def_33 [
  warp-def < [
    scene-warp < #02, #0D, #02, #02, #32, #$0040, #$00E0, #03, #$4500 >
  ], [
  ] >
]

warp_def_34 [
  warp-def < [
    scene-warp < #07, #0D, #02, #02, #32, #$0190, #$00E0, #03, #$4500 >   ;00
    scene-warp < #04, #08, #01, #01, #E6, #$0078, #$00C0, #00, #$1100 >   ;01
  ], [
  ] >
]

warp_def_35 [
  warp-def < [
    scene-warp < #11, #0D, #02, #02, #32, #$02F0, #$00F0, #03, #$4500 >   ;00
    scene-warp < #0E, #07, #01, #02, #32, #$02D0, #$0050, #00, #$4500 >   ;01
  ], [
  ] >
]

warp_def_36 [
  warp-def < [
    scene-warp < #0A, #1D, #02, #01, #32, #$0070, #$02B0, #03, #$4500 >
  ], [
    stair-warp < #03, #07, #01, #02, #$2110, #$0240, #$0000, #08, #$0301 >   ;00
    stair-warp < #03, #17, #01, #02, #$1100, #$0080, #$0000, #10, #$01FF >   ;01
  ] >
]

warp_def_37 [
  warp-def < [
    scene-warp < #07, #1D, #02, #02, #32, #$0160, #$02D0, #03, #$4500 >   ;00
    scene-warp < #03, #07, #01, #02, #32, #$0140, #$0200, #00, #$4500 >   ;01
  ], [
    stair-warp < #0C, #07, #01, #02, #$2110, #$0240, #$0000, #08, #$0301 >   ;00
    stair-warp < #0C, #17, #01, #02, #$1100, #$0080, #$0000, #10, #$01FF >   ;01
  ] >
]

warp_def_38 [
  warp-def < [
    scene-warp < #0B, #1D, #02, #02, #32, #$0210, #$02B0, #03, #$4500 >
  ], [
    stair-warp < #03, #07, #01, #02, #$2110, #$0240, #$0000, #08, #$0301 >   ;00
    stair-warp < #03, #17, #01, #02, #$1100, #$0080, #$0000, #10, #$01FF >   ;01
  ] >
]

warp_def_39 [
  warp-def < [
    scene-warp < #04, #1D, #02, #02, #32, #$0270, #$0230, #03, #$4500 >   ;00
    scene-warp < #0E, #09, #01, #02, #39, #$0228, #$01C0, #00, #$2312 >   ;01
    scene-warp < #19, #09, #01, #02, #39, #$0228, #$00C0, #00, #$1302 >   ;02
    scene-warp < #22, #1D, #02, #02, #39, #$00E0, #$00B0, #03, #$1200 >   ;03
    scene-warp < #22, #0D, #02, #02, #39, #$0190, #$00B0, #03, #$1200 >   ;04
  ], [
    stair-warp < #07, #05, #01, #02, #$2210, #$0240, #$0000, #08, #$0301 >   ;00
    stair-warp < #07, #15, #11, #02, #$1200, #$0080, #$0000, #10, #$01FF >   ;01
  ] >
]

warp_def_3A [
  warp-def < [
    scene-warp < #03, #07, #01, #02, #32, #$02C0, #$0220, #00, #$4500 >   ;00
    scene-warp < #03, #0D, #02, #02, #32, #$02F0, #$02B0, #03, #$4500 >   ;01
  ], [
  ] >
]

warp_def_3B [
  warp-def < [
    scene-warp < #09, #0D, #02, #02, #32, #$0410, #$02C0, #03, #$4500 >
  ], [
  ] >
]

warp_def_3C [
  warp-def < [
    scene-warp < #07, #0D, #02, #02, #32, #$0480, #$0080, #03, #$4500 >
  ], [
  ] >
]

warp_def_3D [
  warp-def < [
    scene-warp < #07, #5E, #02, #02, #41, #$03A0, #$00E0, #03, #$3400 >   ;00
    scene-warp < #05, #01, #02, #02, #42, #$0278, #$00C0, #00, #$1302 >   ;01
    scene-warp < #0D, #0A, #01, #01, #E6, #$0078, #$00C0, #00, #$1100 >   ;02
  ], [
  ] >
]

warp_def_3E [
  warp-def < [
    scene-warp < #05, #01, #01, #03, #3F, #$00A8, #$03B0, #00, #$4400 >
  ], [
  ] >
]

warp_def_3F [
  warp-def < [
    scene-warp < #0A, #3C, #02, #02, #3E, #$0050, #$0040, #03, #$4200 >   ;00
    scene-warp < #20, #1E, #02, #01, #40, #$0070, #$0040, #03, #$3200 >   ;01
    scene-warp < #18, #36, #02, #01, #42, #$0048, #$0040, #03, #$2100 >   ;02
  ], [
  ] >
]

warp_def_40 [
  warp-def < [
    scene-warp < #07, #01, #01, #03, #3F, #$0208, #$01C0, #00, #$4400 >   ;00
    scene-warp < #16, #29, #02, #01, #41, #$02A0, #$0250, #03, #$3400 >   ;01
    scene-warp < #1C, #15, #01, #01, #E6, #$0078, #$00C0, #00, #$1100 >   ;02
  ], [
  ] >
]

warp_def_41 [
  warp-def < [
    scene-warp < #2A, #22, #01, #03, #40, #$0168, #$0270, #00, #$3200 >   ;00
    scene-warp < #3A, #01, #01, #03, #42, #$0288, #$01C0, #00, #$2312 >   ;01
    scene-warp < #3A, #0D, #01, #01, #3D, #$0078, #$05D0, #00, #$6100 >   ;02
  ], [
  ] >
]

warp_def_42 [
  warp-def < [
    scene-warp < #04, #00, #02, #02, #3F, #$0188, #$0340, #00, #$4400 >   ;00
    scene-warp < #00, #1A, #01, #02, #43, #$05E0, #$0340, #06, #$4600 >   ;01
    scene-warp < #1F, #06, #01, #02, #43, #$0010, #$0080, #07, #$4600 >   ;02
    scene-warp < #16, #1E, #02, #02, #44, #$00F0, #$0060, #03, #$2200 >   ;03
    scene-warp < #27, #0E, #02, #02, #3D, #$0058, #$0030, #03, #$6100 >   ;04
    scene-warp < #28, #1E, #02, #02, #41, #$03A0, #$0040, #03, #$3400 >   ;05
    scene-warp < #27, #05, #01, #01, #E6, #$0078, #$00C0, #00, #$1100 >   ;06
  ], [
  ] >
]

warp_def_43 [
  warp-def < [
    scene-warp < #5F, #34, #01, #02, #42, #$0010, #$01A0, #07, #$2100 >   ;00
    scene-warp < #00, #08, #01, #02, #42, #$01E0, #$0060, #06, #$2201 >   ;01
  ], [
  ] >
]

warp_def_44 [
  warp-def < [
    scene-warp < #0F, #03, #01, #03, #42, #$0168, #$01C0, #00, #$2201 >   ;00
    scene-warp < #05, #15, #02, #01, #45, #$0150, #$0060, #03, #$2200 >   ;01
    scene-warp < #0F, #18, #02, #01, #47, #$0070, #$0040, #03, #$3100 >   ;02
    scene-warp < #19, #15, #02, #01, #46, #$0090, #$0060, #03, #$2200 >   ;03
  ], [
  ] >
]

warp_def_45 [
  warp-def < [
    scene-warp < #15, #03, #01, #03, #44, #$0058, #$0130, #00, #$2200 >
  ], [
  ] >
]

warp_def_46 [
  warp-def < [
    scene-warp < #09, #03, #01, #03, #44, #$0198, #$0130, #00, #$2200 >
  ], [
  ] >
]

warp_def_47 [
  warp-def < [
    scene-warp < #07, #01, #01, #03, #44, #$00F8, #$0160, #00, #$2200 >
  ], [
  ] >
]

warp_def_4C [
  warp-def < [
    scene-warp < #0F, #00, #02, #02, #55, #$0070, #$01E0, #00, #$2200 >   ;00
    scene-warp < #1F, #0D, #01, #02, #4D, #$0010, #$00E8, #87, #$4400 >   ;01
    scene-warp < #16, #1F, #02, #01, #4F, #$0078, #$0030, #83, #$4400 >   ;02
    scene-warp < #00, #0D, #01, #02, #53, #$03E0, #$0068, #86, #$4400 >   ;03
    scene-warp < #08, #1F, #02, #01, #51, #$0378, #$0030, #83, #$4400 >   ;04
    scene-warp < #09, #05, #01, #01, #E6, #$0078, #$00C0, #00, #$1100 >   ;05
  ], [
  ] >
]

warp_def_4D [
  warp-def < [
    scene-warp < #00, #0E, #01, #02, #4C, #$01E0, #$00D8, #06, #$2200 >   ;00
    scene-warp < #30, #2A, #02, #01, #4E, #$00E8, #$0280, #00, #$4400 >   ;01
    scene-warp < #25, #3E, #02, #01, #4E, #$0198, #$03C0, #00, #$4400 >   ;02
    scene-warp < #09, #3E, #02, #01, #4E, #$0358, #$03C0, #00, #$4400 >   ;03
  ], [
  ] >
]

warp_def_4E [
  warp-def < [
    scene-warp < #0E, #2A, #02, #01, #4D, #$0308, #$0290, #00, #$4400 >   ;00
    scene-warp < #19, #3E, #02, #01, #4D, #$0258, #$03D0, #00, #$4400 >   ;01
    scene-warp < #35, #3E, #02, #01, #4D, #$0098, #$03D0, #00, #$4400 >   ;02
  ], [
  ] >
]

warp_def_4F [
  warp-def < [
    scene-warp < #07, #00, #02, #02, #4C, #$0168, #$01D0, #00, #$2200 >   ;00
    scene-warp < #33, #12, #02, #01, #50, #$00B8, #$0100, #00, #$4400 >   ;01
    scene-warp < #15, #10, #02, #01, #50, #$0298, #$00E0, #00, #$4400 >   ;02
    scene-warp < #1F, #29, #02, #01, #50, #$01F8, #$0270, #00, #$4400 >   ;03
    scene-warp < #2E, #1D, #01, #02, #56, #$00A0, #$00B0, #00, #$1100 >   ;04
  ], [
  ] >
]

warp_def_50 [
  warp-def < [
    scene-warp < #0B, #12, #02, #01, #4F, #$0338, #$0110, #00, #$4400 >   ;00
    scene-warp < #29, #10, #02, #01, #4F, #$0158, #$00F0, #00, #$4400 >   ;01
    scene-warp < #1F, #29, #02, #01, #4F, #$01F8, #$0280, #00, #$4400 >   ;02
  ], [
  ] >
]

warp_def_51 [
  warp-def < [
    scene-warp < #37, #00, #02, #02, #4C, #$0088, #$01D0, #00, #$2200 >   ;00
    scene-warp < #2A, #15, #02, #01, #52, #$0148, #$0130, #03, #$4400 >   ;01
    scene-warp < #0E, #11, #02, #01, #52, #$0308, #$00F0, #03, #$4400 >   ;02
    scene-warp < #35, #3D, #02, #01, #52, #$0098, #$03B0, #03, #$4400 >   ;03
    scene-warp < #03, #0A, #01, #01, #E6, #$0078, #$00C0, #00, #$1100 >   ;04
  ], [
  ] >
]

warp_def_52 [
  warp-def < [
    scene-warp < #14, #15, #02, #01, #51, #$02A8, #$0140, #03, #$4400 >   ;00
    scene-warp < #30, #11, #02, #01, #51, #$00E8, #$0100, #03, #$4400 >   ;01
    scene-warp < #09, #3D, #02, #01, #51, #$0358, #$03C0, #03, #$4400 >   ;02
  ], [
  ] >
]

warp_def_53 [
  warp-def < [
    scene-warp < #3F, #06, #01, #02, #4C, #$0010, #$00D8, #07, #$2200 >   ;00
    scene-warp < #20, #2A, #02, #01, #54, #$01E8, #$0270, #03, #$4400 >   ;01
    scene-warp < #06, #3F, #02, #01, #54, #$0388, #$03D0, #03, #$4400 >   ;02
    scene-warp < #2E, #2F, #02, #01, #54, #$0108, #$02F0, #03, #$4400 >   ;03
    scene-warp < #0A, #11, #02, #01, #54, #$0348, #$00F0, #03, #$4400 >   ;04
  ], [
  ] >
]

warp_def_54 [
  warp-def < [
    scene-warp < #1E, #29, #02, #01, #53, #$0208, #$0290, #03, #$4400 >   ;00
    scene-warp < #38, #3F, #02, #01, #53, #$0068, #$03E0, #03, #$4400 >   ;01
    scene-warp < #10, #31, #02, #01, #53, #$02E8, #$02E0, #03, #$4400 >   ;02
    scene-warp < #34, #11, #02, #01, #53, #$00A8, #$0100, #03, #$4400 >   ;03
    scene-warp < #02, #05, #01, #01, #E6, #$0078, #$00C0, #00, #$1100 >   ;04
  ], [
  ] >
]

warp_def_55 [
  warp-def < [
    scene-warp < #07, #1F, #02, #01, #4C, #$00F8, #$0030, #03, #$2200 >
  ], [
  ] >
]

warp_def_56 [
  warp-def < [
    scene-warp < #0A, #0C, #01, #01, #4F, #$02E0, #$01F0, #03, #$4400 >   ;00
    scene-warp < #07, #08, #01, #01, #E6, #$0078, #$00C0, #00, #$1100 >   ;01
  ], [
  ] >
]

warp_def_5A [
  warp-def < [
    scene-warp < #2F, #07, #01, #01, #E6, #$0078, #$00C0, #00, #$1100 >   ;00
    scene-warp < #08, #57, #01, #02, #5C, #$0080, #$0070, #03, #$2400 >   ;01
    scene-warp < #3E, #09, #02, #02, #5B, #$0030, #$0090, #07, #$1100 >   ;02
    scene-warp < #00, #1A, #03, #02, #5B, #$00C0, #$0190, #06, #$2110 >   ;03
    scene-warp < #3E, #3A, #02, #02, #5B, #$0030, #$0390, #07, #$4130 >   ;04
    scene-warp < #09, #05, #01, #02, #5E, #$0380, #$00B0, #00, #$1400 >   ;05
  ], [
    stair-warp < #37, #05, #01, #02, #$3420, #$0241, #$0000, #18, #$0302 >   ;00
    stair-warp < #37, #26, #01, #02, #$1400, #$0081, #$0000, #00, #$01FE >   ;01
    stair-warp < #09, #16, #01, #02, #$3420, #$0240, #$0000, #D8, #$0300 >   ;02
    stair-warp < #09, #23, #01, #02, #$2410, #$0080, #$0000, #40, #$01FF >   ;03
    stair-warp < #0E, #23, #01, #02, #$4430, #$0240, #$0000, #38, #$0301 >   ;04
    stair-warp < #0E, #36, #01, #02, #$3420, #$0080, #$0000, #E0, #$01FE >   ;05
    stair-warp < #19, #36, #01, #02, #$5440, #$0240, #$0000, #18, #$0301 >   ;06
    stair-warp < #19, #47, #01, #02, #$4430, #$0080, #$0000, #00, #$01FF >   ;07
    stair-warp < #37, #36, #01, #02, #$5440, #$0240, #$0000, #18, #$0301 >   ;08
    stair-warp < #37, #47, #01, #02, #$4430, #$0080, #$0000, #00, #$01FF >   ;09
    stair-warp < #2B, #47, #01, #02, #$6450, #$0240, #$0000, #08, #$0301 >   ;0A
    stair-warp < #2B, #57, #01, #02, #$5440, #$0080, #$0000, #10, #$01FF >   ;0B
  ] >
]

warp_def_5B [
  warp-def < [
    scene-warp < #00, #09, #02, #02, #5A, #$03C0, #$0090, #06, #$1400 >   ;00
    scene-warp < #0E, #19, #02, #02, #5A, #$0040, #$01A0, #07, #$2410 >   ;01
    scene-warp < #00, #39, #02, #02, #5A, #$03C0, #$03A0, #06, #$4430 >   ;02
    scene-warp < #0E, #29, #02, #02, #5C, #$0030, #$03A0, #07, #$4430 >   ;03
  ], [
  ] >
]

warp_def_5C [
  warp-def < [
    scene-warp < #08, #05, #01, #02, #5A, #$0080, #$0590, #03, #$6450 >   ;00
    scene-warp < #35, #36, #01, #02, #5D, #$00D0, #$0100, #03, #$2300 >   ;01
    scene-warp < #00, #3A, #02, #02, #5B, #$00C0, #$0290, #06, #$3120 >   ;02
  ], [
    stair-warp < #38, #06, #01, #02, #$2400, #$0242, #$0000, #F0, #$0800 >   ;00
    stair-warp < #38, #14, #01, #02, #$1400, #$0082, #$0000, #30, #$01FF >   ;01
    stair-warp < #35, #14, #01, #02, #$3420, #$0244, #$0000, #30, #$0801 >   ;02
    stair-warp < #35, #26, #01, #02, #$2400, #$0083, #$0000, #F0, #$01FE >   ;03
    stair-warp < #07, #15, #01, #02, #$3420, #$0240, #$0000, #18, #$0301 >   ;04
    stair-warp < #07, #26, #01, #02, #$2410, #$0080, #$0000, #00, #$01FF >   ;05
    stair-warp < #15, #26, #01, #02, #$4430, #$0240, #$0000, #08, #$0301 >   ;06
    stair-warp < #15, #36, #01, #02, #$3420, #$0080, #$0000, #10, #$01FF >   ;07
  ] >
]

warp_def_5D [
  warp-def < [
    scene-warp < #0D, #0E, #01, #02, #5C, #$0350, #$0380, #03, #$4430 >
  ], [
  ] >
]

warp_def_5E [
  warp-def < [
    scene-warp < #38, #0C, #01, #01, #5A, #$0090, #$0070, #03, #$1400 >   ;00
    scene-warp < #06, #0C, #01, #01, #5F, #$0080, #$0040, #83, #$4400 >   ;01
  ], [
  ] >
]

warp_def_5F [
  warp-def < [
    scene-warp < #08, #02, #01, #02, #5E, #$0060, #$00B0, #00, #$1400 >   ;00
    scene-warp < #3F, #08, #01, #04, #60, #$0010, #$0090, #07, #$4400 >   ;01
    scene-warp < #14, #3F, #03, #01, #62, #$0150, #$0030, #03, #$4400 >   ;02
    scene-warp < #32, #3F, #04, #01, #62, #$0338, #$0040, #03, #$4400 >   ;03
    scene-warp < #31, #00, #01, #04, #63, #$0180, #$00B0, #00, #$1201 >   ;04
  ], [
  ] >
]

warp_def_60 [
  warp-def < [
    scene-warp < #00, #08, #01, #04, #5F, #$03E0, #$0090, #06, #$4400 >   ;00
    scene-warp < #13, #3F, #03, #01, #61, #$0140, #$0030, #03, #$4400 >   ;01
    scene-warp < #0C, #3F, #03, #01, #61, #$00D0, #$0030, #03, #$4400 >   ;02
    scene-warp < #06, #3F, #02, #01, #61, #$0068, #$0030, #03, #$4400 >   ;03
    scene-warp < #07, #22, #01, #01, #E6, #$0078, #$00C0, #00, #$1100 >   ;04
  ], [
  ] >
]

warp_def_61 [
  warp-def < [
    scene-warp < #13, #00, #03, #02, #60, #$0140, #$03E0, #00, #$4400 >   ;00
    scene-warp < #0C, #00, #03, #02, #60, #$00D0, #$03E0, #00, #$4400 >   ;01
    scene-warp < #06, #00, #02, #02, #60, #$0068, #$03E0, #00, #$4400 >   ;02
    scene-warp < #00, #39, #01, #04, #62, #$03E0, #$03A0, #06, #$4400 >   ;03
    scene-warp < #00, #28, #01, #07, #62, #$03E0, #$02A8, #06, #$4400 >   ;04
    scene-warp < #00, #1F, #01, #07, #62, #$03E0, #$0220, #06, #$4400 >   ;05
    scene-warp < #28, #02, #01, #02, #63, #$0080, #$00B0, #00, #$1100 >   ;06
  ], [
  ] >
]

warp_def_62 [
  warp-def < [
    scene-warp < #14, #00, #03, #02, #5F, #$0150, #$03E0, #00, #$4400 >   ;00
    scene-warp < #3F, #39, #01, #04, #61, #$0010, #$03A0, #07, #$4400 >   ;01
    scene-warp < #3F, #28, #01, #07, #61, #$0010, #$02A8, #07, #$4400 >   ;02
    scene-warp < #3F, #1F, #01, #07, #61, #$0010, #$0220, #07, #$4400 >   ;03
    scene-warp < #32, #00, #04, #01, #5F, #$0338, #$03D0, #00, #$4400 >   ;04
    scene-warp < #18, #3F, #03, #01, #64, #$0190, #$0030, #03, #$4200 >   ;05
    scene-warp < #0D, #3F, #07, #01, #64, #$0100, #$0030, #03, #$4200 >   ;06
    scene-warp < #04, #3F, #05, #01, #64, #$0060, #$0030, #03, #$4200 >   ;07
    scene-warp < #10, #19, #01, #01, #E6, #$0078, #$00C0, #00, #$1100 >   ;08
  ], [
  ] >
]

warp_def_63 [
  warp-def < [
    scene-warp < #08, #0C, #01, #01, #61, #$0280, #$0040, #03, #$4400 >   ;00
    scene-warp < #18, #0C, #01, #01, #5F, #$0310, #$0040, #03, #$4400 >   ;01
  ], [
  ] >
]

warp_def_64 [
  warp-def < [
    scene-warp < #18, #00, #03, #02, #62, #$0190, #$03E0, #00, #$4400 >   ;00
    scene-warp < #0D, #00, #07, #02, #62, #$0100, #$03E0, #00, #$4400 >   ;01
    scene-warp < #04, #00, #05, #02, #62, #$0060, #$03E0, #00, #$4400 >   ;02
    scene-warp < #1F, #29, #01, #04, #65, #$0010, #$02A0, #07, #$4400 >   ;03
    scene-warp < #1F, #33, #01, #04, #65, #$0010, #$0340, #07, #$4400 >   ;04
    scene-warp < #1F, #39, #01, #05, #65, #$0010, #$03B0, #07, #$4400 >   ;05
  ], [
  ] >
]

warp_def_65 [
  warp-def < [
    scene-warp < #00, #29, #01, #04, #64, #$01E0, #$02A0, #06, #$4200 >   ;00
    scene-warp < #00, #33, #01, #04, #64, #$01E0, #$0340, #06, #$4200 >   ;01
    scene-warp < #00, #39, #01, #05, #64, #$01E0, #$03B0, #06, #$4200 >   ;02
    scene-warp < #0B, #26, #02, #02, #66, #$0278, #$00B0, #00, #$1302 >   ;03
  ], [
  ] >
]

warp_def_66 [
  warp-def < [
    scene-warp < #0F, #1F, #02, #01, #65, #$00B8, #$0280, #03, #$4400 >   ;00
    scene-warp < #27, #0D, #02, #03, #65, #$00B8, #$0280, #03, #$4400 >   ;01
    scene-warp < #0F, #00, #02, #02, #67, #$0178, #$01D0, #00, #$2201 >   ;02
  ], [
  ] >
]

warp_def_67 [
  warp-def < [
    scene-warp < #17, #1E, #02, #01, #66, #$00F8, #$0020, #03, #$2200 >   ;00
    scene-warp < #17, #03, #02, #02, #67, #$0078, #$01D0, #00, #$2100 >   ;01
    scene-warp < #07, #1F, #02, #01, #67, #$0178, #$0050, #03, #$2201 >   ;02
  ], [
  ] >
]

warp_def_69 [
  warp-def < [
    scene-warp < #2A, #05, #01, #01, #6A, #$01A0, #$0030, #00, #$1200 >   ;00
    scene-warp < #07, #09, #01, #01, #6B, #$0050, #$0030, #00, #$1300 >   ;01
  ], [
  ] >
]

warp_def_6A [
  warp-def < [
    scene-warp < #1A, #01, #01, #01, #69, #$02A0, #$0038, #00, #$1300 >
  ], [
  ] >
]

warp_def_6B [
  warp-def < [
    scene-warp < #05, #01, #01, #01, #69, #$0070, #$0078, #00, #$1300 >   ;00
    scene-warp < #11, #07, #01, #02, #6C, #$00A8, #$00B0, #00, #$1100 >   ;01
    scene-warp < #19, #15, #01, #02, #6C, #$0228, #$00C0, #00, #$1402 >   ;02
    scene-warp < #05, #26, #01, #02, #6C, #$01A8, #$00B0, #00, #$1201 >   ;03
    scene-warp < #23, #24, #01, #02, #6C, #$0188, #$01B0, #00, #$2211 >   ;04
    scene-warp < #3A, #25, #02, #02, #6D, #$0078, #$0070, #83, #$1400 >   ;05
  ], [
    stair-warp < #27, #06, #01, #02, #$2410, #$0240, #$0000, #F8, #$0300 >   ;00
    stair-warp < #27, #15, #01, #02, #$1300, #$0080, #$0000, #20, #$01FF >   ;01
    stair-warp < #3A, #07, #01, #02, #$2410, #$0240, #$0000, #D8, #$0300 >   ;02
    stair-warp < #3A, #14, #01, #02, #$1403, #$0080, #$0000, #40, #$01FF >   ;03
    stair-warp < #0E, #14, #01, #02, #$3420, #$0240, #$0000, #08, #$0301 >   ;04
    stair-warp < #0E, #24, #01, #02, #$2410, #$0080, #$0000, #10, #$01FF >   ;05
  ] >
]

warp_def_6C [
  warp-def < [
    scene-warp < #0A, #0C, #02, #01, #6B, #$0110, #$0090, #03, #$1300 >   ;00
    scene-warp < #0A, #1C, #02, #01, #6B, #$0190, #$0170, #03, #$2410 >   ;01
    scene-warp < #1A, #0C, #02, #01, #6B, #$0050, #$0280, #03, #$3420 >   ;02
    scene-warp < #18, #1C, #02, #01, #6B, #$0230, #$0260, #03, #$3420 >   ;03
    scene-warp < #22, #0D, #02, #01, #6B, #$0190, #$0170, #03, #$2410 >   ;04
    scene-warp < #19, #09, #01, #01, #E6, #$0078, #$00C0, #00, #$1100 >   ;05
  ], [
  ] >
]

warp_def_6D [
  warp-def < [
    scene-warp < #39, #25, #01, #02, #6E, #$0060, #$0070, #03, #$1400 >   ;00
    scene-warp < #07, #05, #02, #02, #6B, #$03A8, #$0270, #03, #$3420 >   ;01
  ], [
    stair-warp < #2C, #05, #01, #02, #$2410, #$0240, #$0000, #08, #$0301 >   ;00
    stair-warp < #2C, #15, #01, #02, #$1400, #$0080, #$0000, #10, #$01FF >   ;01
    stair-warp < #09, #15, #01, #02, #$3420, #$0240, #$0000, #08, #$0301 >   ;02
    stair-warp < #09, #25, #01, #02, #$2410, #$0080, #$0000, #10, #$01FF >   ;03
  ] >
]

warp_def_6E [
  warp-def < [
    scene-warp < #06, #05, #01, #02, #6D, #$0390, #$0270, #03, #$3420 >   ;00
    scene-warp < #39, #26, #01, #02, #6F, #$0040, #$00A0, #03, #$1300 >   ;01
  ], [
    stair-warp < #0D, #05, #01, #02, #$2210, #$0240, #$0000, #08, #$0301 >   ;00
    stair-warp < #0D, #15, #01, #02, #$1400, #$0080, #$0000, #10, #$01FF >   ;01
    stair-warp < #17, #08, #01, #02, #$2210, #$0240, #$0000, #08, #$0301 >   ;02
    stair-warp < #17, #18, #01, #02, #$1400, #$0080, #$0000, #10, #$01FF >   ;03
    stair-warp < #1C, #18, #01, #02, #$3220, #$0240, #$0000, #08, #$0301 >   ;04
    stair-warp < #1C, #28, #01, #02, #$2210, #$0080, #$0000, #10, #$01FF >   ;05
    stair-warp < #28, #06, #01, #02, #$3422, #$0241, #$0000, #F8, #$0301 >   ;06
    stair-warp < #28, #25, #01, #02, #$1400, #$0081, #$0000, #20, #$01FE >   ;07
    stair-warp < #37, #05, #01, #02, #$2412, #$0240, #$0000, #08, #$0301 >   ;08
    stair-warp < #37, #15, #01, #02, #$1400, #$0080, #$0000, #10, #$01FF >   ;09
  ] >
]

warp_def_6F [
  warp-def < [
    scene-warp < #04, #08, #01, #02, #6E, #$0390, #$0280, #03, #$3422 >   ;00
    scene-warp < #2B, #08, #01, #02, #70, #$0090, #$0070, #03, #$1300 >   ;01
  ], [
  ] >
]

warp_def_70 [
  warp-def < [
    scene-warp < #09, #05, #01, #02, #6F, #$02B0, #$00A0, #03, #$1300 >   ;00
    scene-warp < #25, #14, #04, #01, #70, #$00A8, #$02B0, #00, #$3120 >   ;01
    scene-warp < #09, #2F, #04, #01, #70, #$0270, #$0170, #03, #$2310 >   ;02
    scene-warp < #17, #06, #01, #02, #70, #$0080, #$01C0, #00, #$2310 >   ;03
    scene-warp < #08, #1D, #01, #01, #70, #$0170, #$0080, #03, #$1300 >   ;04
    scene-warp < #2A, #15, #01, #02, #71, #$0060, #$0080, #03, #$1300 >   ;05
  ], [
  ] >
]

warp_def_71 [
  warp-def < [
    scene-warp < #06, #06, #01, #02, #70, #$02A0, #$0170, #03, #$2310 >   ;00
    scene-warp < #29, #05, #01, #02, #72, #$0070, #$00C0, #00, #$1600 >   ;01
  ], [
  ] >
]

warp_def_72 [
  warp-def < [
    scene-warp < #07, #0D, #01, #01, #71, #$0290, #$0070, #03, #$1300 >   ;00
    scene-warp < #55, #04, #05, #01, #73, #$0080, #$01C0, #00, #$2410 >   ;01
  ], [
  ] >
]

warp_def_73 [
  warp-def < [
    scene-warp < #07, #1F, #04, #01, #72, #$0570, #$0070, #03, #$1600 >   ;00
    scene-warp < #2C, #15, #01, #02, #73, #$00D0, #$00C0, #00, #$1400 >   ;01
    scene-warp < #0D, #0D, #01, #01, #73, #$02C0, #$0170, #03, #$2410 >   ;02
    scene-warp < #27, #04, #01, #02, #74, #$00B0, #$00B0, #00, #$1100 >   ;03
    scene-warp < #2E, #04, #01, #02, #74, #$01B0, #$00B0, #00, #$1201 >   ;04
    scene-warp < #35, #04, #01, #02, #74, #$0290, #$00B0, #00, #$1302 >   ;05
  ], [
  ] >
]

warp_def_74 [
  warp-def < [
    scene-warp < #0B, #0C, #01, #01, #73, #$0270, #$0060, #03, #$1400 >   ;00
    scene-warp < #1B, #0C, #01, #01, #73, #$02E0, #$0060, #03, #$1400 >   ;01
    scene-warp < #29, #0C, #01, #01, #73, #$0350, #$0060, #03, #$1400 >   ;02
    scene-warp < #2A, #06, #01, #02, #75, #$0088, #$01C0, #00, #$2710 >   ;03
  ], [
  ] >
]

warp_def_75 [
  warp-def < [
    scene-warp < #08, #17, #02, #03, #75, #$00A8, #$00C0, #00, #$1100 >   ;00
    scene-warp < #12, #17, #02, #03, #75, #$01A8, #$00C0, #00, #$1201 >   ;01
    scene-warp < #25, #17, #02, #03, #75, #$0298, #$00B0, #00, #$1302 >   ;02
    scene-warp < #2F, #17, #02, #03, #75, #$0398, #$00B0, #00, #$1403 >   ;03
    scene-warp < #42, #17, #02, #03, #75, #$0498, #$00B0, #00, #$1504 >   ;04
    scene-warp < #4C, #17, #02, #03, #75, #$0598, #$00B0, #00, #$1605 >   ;05
    scene-warp < #5F, #17, #02, #03, #75, #$0698, #$00B0, #00, #$1706 >   ;06
    scene-warp < #69, #17, #02, #03, #75, #$0798, #$00B0, #00, #$1807 >   ;07
    scene-warp < #0A, #0D, #02, #02, #75, #$0088, #$01A0, #03, #$2710 >   ;08
    scene-warp < #1A, #0D, #02, #02, #75, #$0128, #$01A0, #03, #$2710 >   ;09
    scene-warp < #29, #0C, #02, #02, #75, #$0258, #$01A0, #03, #$2710 >   ;0A
    scene-warp < #39, #0C, #02, #02, #75, #$02F8, #$01A0, #03, #$2710 >   ;0B
    scene-warp < #49, #0C, #02, #02, #75, #$0428, #$01A0, #03, #$2710 >   ;0C
    scene-warp < #59, #0C, #02, #02, #75, #$04C8, #$01A0, #03, #$2710 >   ;0D
    scene-warp < #69, #0C, #02, #02, #75, #$05F8, #$01A0, #03, #$2710 >   ;0E
    scene-warp < #79, #0C, #02, #02, #75, #$0698, #$01A0, #03, #$2710 >   ;0F
    scene-warp < #08, #1D, #02, #02, #74, #$02A0, #$0080, #03, #$1302 >   ;10
  ], [
  ] >
]

warp_def_78 [
  warp-def < [
    scene-warp < #35, #0C, #01, #01, #79, #$0080, #$00B0, #00, #$1100 >   ;00
    scene-warp < #19, #0C, #01, #01, #7A, #$0070, #$0080, #00, #$1100 >   ;01
    scene-warp < #3E, #31, #01, #02, #7B, #$00F8, #$00C0, #00, #$1200 >   ;02
    scene-warp < #19, #35, #01, #01, #7C, #$0070, #$0080, #00, #$1100 >   ;03
    scene-warp < #25, #25, #01, #01, #7D, #$0070, #$0080, #00, #$1100 >   ;04
    scene-warp < #3C, #1E, #01, #01, #7E, #$0070, #$0080, #00, #$1100 >   ;05
  ], [
  ] >
]

warp_def_79 [
  warp-def < [
    scene-warp < #08, #0D, #02, #02, #78, #$0350, #$00E0, #03, #$4500 >
  ], [
  ] >
]

warp_def_7A [
  warp-def < [
    scene-warp < #07, #09, #01, #01, #78, #$0190, #$00E0, #03, #$4500 >
  ], [
  ] >
]

warp_def_7B [
  warp-def < [
    scene-warp < #0F, #0D, #02, #02, #78, #$03E0, #$0330, #03, #$4500 >
  ], [
  ] >
]

warp_def_7C [
  warp-def < [
    scene-warp < #07, #09, #01, #01, #78, #$0190, #$0370, #03, #$4500 >   ;00
    scene-warp < #04, #08, #01, #01, #E6, #$0078, #$00C0, #00, #$1100 >   ;01
  ], [
  ] >
]

warp_def_7D [
  warp-def < [
    scene-warp < #07, #09, #01, #01, #78, #$0250, #$0270, #03, #$4500 >
  ], [
  ] >
]

warp_def_7E [
  warp-def < [
    scene-warp < #07, #09, #01, #01, #78, #$03C0, #$0200, #03, #$4500 >
  ], [
  ] >
]

warp_def_82 [
  warp-def < [
    scene-warp < #7F, #08, #01, #03, #83, #$0020, #$0090, #07, #$8400 >
  ], [
    stair-warp < #39, #06, #01, #01, #$4810, #$0240, #$0000, #08, #$0301 >   ;00
    stair-warp < #39, #16, #01, #01, #$1800, #$0080, #$0000, #10, #$01FF >   ;01
    stair-warp < #77, #26, #01, #01, #$2810, #$0080, #$0000, #10, #$01FF >   ;02
    stair-warp < #77, #16, #01, #01, #$4810, #$0240, #$0000, #08, #$0301 >   ;03
    stair-warp < #45, #16, #01, #01, #$1800, #$0080, #$0000, #10, #$01FF >   ;04
    stair-warp < #45, #06, #01, #01, #$2810, #$0240, #$0000, #08, #$0301 >   ;05
  ] >
]

warp_def_83 [
  warp-def < [
    scene-warp < #00, #08, #01, #03, #82, #$07D0, #$0090, #06, #$1800 >   ;00
    scene-warp < #3F, #08, #01, #03, #85, #$0010, #$0070, #07, #$1800 >   ;01
  ], [
    stair-warp < #34, #76, #01, #01, #$7460, #$0080, #$0000, #10, #$01FF >   ;00
    stair-warp < #34, #66, #01, #01, #$8470, #$0240, #$0000, #08, #$0301 >   ;01
    stair-warp < #2C, #66, #01, #01, #$6450, #$0080, #$0000, #10, #$01FF >   ;02
    stair-warp < #2C, #56, #01, #01, #$7460, #$0240, #$0000, #08, #$0301 >   ;03
    stair-warp < #1E, #66, #01, #01, #$6450, #$0080, #$0000, #10, #$01FF >   ;04
    stair-warp < #1E, #56, #01, #01, #$7460, #$0240, #$0000, #08, #$0301 >   ;05
    stair-warp < #38, #56, #01, #01, #$5440, #$0080, #$0000, #10, #$01FF >   ;06
    stair-warp < #38, #46, #01, #01, #$6450, #$0240, #$0000, #08, #$0301 >   ;07
    stair-warp < #2C, #46, #01, #01, #$4430, #$0080, #$0000, #10, #$01FF >   ;08
    stair-warp < #2C, #36, #01, #01, #$5440, #$0240, #$0000, #08, #$0301 >   ;09
    stair-warp < #1E, #46, #01, #01, #$4430, #$0080, #$0000, #10, #$01FF >   ;0A
    stair-warp < #1E, #36, #01, #01, #$5440, #$0240, #$0000, #08, #$0301 >   ;0B
    stair-warp < #21, #36, #01, #01, #$3420, #$0080, #$0000, #10, #$01FF >   ;0C
    stair-warp < #21, #26, #01, #01, #$4430, #$0240, #$0000, #08, #$0301 >   ;0D
    stair-warp < #29, #26, #01, #01, #$2410, #$0080, #$0000, #10, #$01FF >   ;0E
    stair-warp < #29, #16, #01, #01, #$3420, #$0240, #$0000, #08, #$0301 >   ;0F
    stair-warp < #2D, #26, #01, #01, #$2410, #$0080, #$0000, #10, #$01FF >   ;10
    stair-warp < #2D, #16, #01, #01, #$3420, #$0240, #$0000, #08, #$0301 >   ;11
    stair-warp < #31, #26, #01, #01, #$2410, #$0080, #$0000, #10, #$01FF >   ;12
    stair-warp < #31, #16, #01, #01, #$3420, #$0240, #$0000, #08, #$0301 >   ;13
    stair-warp < #35, #26, #01, #01, #$2410, #$0080, #$0000, #10, #$01FF >   ;14
    stair-warp < #35, #16, #01, #01, #$3420, #$0240, #$0000, #08, #$0301 >   ;15
    stair-warp < #39, #26, #01, #01, #$2410, #$0080, #$0000, #10, #$01FF >   ;16
    stair-warp < #39, #16, #01, #01, #$3420, #$0240, #$0000, #08, #$0301 >   ;17
    stair-warp < #1E, #16, #01, #01, #$1400, #$0080, #$0000, #10, #$01FF >   ;18
    stair-warp < #1E, #06, #01, #01, #$2410, #$0240, #$0000, #08, #$0301 >   ;19
  ] >
]

warp_def_85 [
  warp-def < [
    scene-warp < #00, #06, #01, #03, #83, #$03E0, #$0090, #06, #$8400 >   ;00
    scene-warp < #7F, #0A, #01, #03, #86, #$0010, #$0090, #07, #$6300 >   ;01
    scene-warp < #06, #2A, #01, #01, #E6, #$0078, #$00C0, #00, #$1100 >   ;02
  ], [
    stair-warp < #0B, #05, #01, #01, #$2810, #$0240, #$0000, #38, #$0301 >   ;00
    stair-warp < #0B, #18, #01, #01, #$1800, #$0080, #$0000, #E0, #$01FE >   ;01
    stair-warp < #2F, #08, #01, #01, #$2810, #$0240, #$0000, #08, #$0301 >   ;02
    stair-warp < #2F, #18, #01, #01, #$1800, #$0080, #$0000, #10, #$01FF >   ;03
    stair-warp < #5A, #08, #01, #01, #$2810, #$0240, #$0000, #08, #$0301 >   ;04
    stair-warp < #5A, #18, #01, #01, #$1800, #$0080, #$0000, #10, #$01FF >   ;05
    stair-warp < #6F, #08, #01, #01, #$2810, #$0240, #$0000, #08, #$0301 >   ;06
    stair-warp < #6F, #18, #01, #01, #$1800, #$0080, #$0000, #10, #$01FF >   ;07
    stair-warp < #40, #18, #01, #01, #$3820, #$0240, #$0000, #08, #$0301 >   ;08
    stair-warp < #40, #28, #01, #01, #$2810, #$0080, #$0000, #10, #$01FF >   ;09
  ] >
]

warp_def_86 [
  warp-def < [
    scene-warp < #00, #08, #01, #03, #85, #$07E0, #$00B0, #06, #$1800 >   ;00
    scene-warp < #2F, #08, #01, #03, #87, #$0010, #$0090, #07, #$1400 >   ;01
    scene-warp < #15, #46, #01, #01, #E6, #$0078, #$00C0, #00, #$1100 >   ;02
  ], [
    stair-warp < #0D, #05, #01, #02, #$6300, #$0240, #$0000, #08, #$0301 >   ;00
    stair-warp < #0D, #15, #01, #02, #$6300, #$0080, #$0000, #10, #$01FF >   ;01
    stair-warp < #21, #05, #01, #02, #$6300, #$0240, #$0000, #08, #$0301 >   ;02
    stair-warp < #21, #15, #01, #02, #$6300, #$0080, #$0000, #10, #$01FF >   ;03
    stair-warp < #17, #05, #01, #02, #$6300, #$0245, #$0000, #08, #$0305 >   ;04
    stair-warp < #17, #55, #01, #02, #$6300, #$0085, #$0000, #10, #$01FB >   ;05
    stair-warp < #25, #35, #01, #02, #$6300, #$024E, #$0000, #08, #$0302 >   ;06
    stair-warp < #25, #55, #01, #02, #$6300, #$008D, #$0000, #10, #$01FE >   ;07
  ] >
]

warp_def_87 [
  warp-def < [
    scene-warp < #00, #08, #01, #03, #86, #$02E0, #$0090, #06, #$6300 >   ;00
    scene-warp < #3F, #08, #01, #03, #88, #$0010, #$0090, #07, #$1400 >   ;01
  ], [
    stair-warp < #18, #06, #01, #01, #$2410, #$0240, #$0000, #08, #$0301 >   ;00
    stair-warp < #18, #16, #01, #01, #$1400, #$0080, #$0000, #10, #$01FF >   ;01
    stair-warp < #24, #06, #01, #01, #$2410, #$0240, #$0000, #08, #$0301 >   ;02
    stair-warp < #24, #16, #01, #01, #$1400, #$0080, #$0000, #10, #$01FF >   ;03
    stair-warp < #06, #16, #01, #01, #$3420, #$0240, #$0000, #08, #$0301 >   ;04
    stair-warp < #06, #26, #01, #01, #$2410, #$0080, #$0000, #10, #$01FF >   ;05
    stair-warp < #32, #16, #01, #01, #$3420, #$0240, #$0000, #08, #$0301 >   ;06
    stair-warp < #32, #26, #01, #01, #$2410, #$0080, #$0000, #10, #$01FF >   ;07
  ] >
]

warp_def_88 [
  warp-def < [
    scene-warp < #00, #08, #01, #03, #87, #$03E0, #$0090, #06, #$1400 >   ;00
    scene-warp < #3F, #08, #01, #03, #8A, #$0050, #$0090, #87, #$3300 >   ;01
    scene-warp < #1C, #27, #01, #01, #E6, #$0078, #$00C0, #00, #$1100 >   ;02
  ], [
    stair-warp < #0F, #05, #01, #02, #$2410, #$0240, #$0000, #08, #$0301 >   ;00
    stair-warp < #0F, #15, #01, #02, #$1400, #$0080, #$0000, #10, #$01FF >   ;01
    stair-warp < #21, #15, #01, #02, #$3420, #$0240, #$0000, #08, #$0301 >   ;02
    stair-warp < #21, #25, #01, #02, #$2410, #$0080, #$0000, #10, #$01FF >   ;03
  ] >
]

warp_def_8A [
  warp-def < [
    scene-warp < #03, #08, #01, #03, #88, #$03E0, #$0090, #06, #$1400 >   ;00
    scene-warp < #2C, #08, #01, #03, #8B, #$0010, #$0090, #07, #$1200 >   ;01
  ], [
  ] >
]

warp_def_8B [
  warp-def < [
    scene-warp < #00, #08, #01, #03, #8A, #$02B0, #$0090, #06, #$3300 >
  ], [
    stair-warp < #16, #06, #01, #01, #$2210, #$0240, #$0000, #08, #$0301 >   ;00
    stair-warp < #16, #16, #01, #01, #$1200, #$0080, #$0000, #10, #$01FF >   ;01
  ] >
]

warp_def_91 [
  warp-def < [
    scene-warp < #34, #2F, #01, #02, #92, #$0098, #$00C0, #00, #$1100 >   ;00
    scene-warp < #33, #17, #01, #01, #93, #$0078, #$00C0, #00, #$1100 >   ;01
    scene-warp < #06, #3E, #01, #02, #94, #$0078, #$01C0, #00, #$2110 >   ;02
    scene-warp < #15, #06, #01, #02, #95, #$0198, #$01C0, #00, #$2410 >   ;03
    scene-warp < #1A, #06, #01, #02, #95, #$0228, #$01C0, #00, #$2410 >   ;04
    scene-warp < #22, #3E, #01, #02, #97, #$0068, #$00C0, #00, #$1200 >   ;05
    scene-warp < #2C, #3E, #01, #02, #97, #$0168, #$00C0, #00, #$1200 >   ;06
    scene-warp < #0D, #3E, #01, #02, #98, #$0098, #$00C0, #00, #$1100 >   ;07
    scene-warp < #33, #3E, #01, #02, #99, #$0078, #$01C0, #00, #$2110 >   ;08
    scene-warp < #23, #21, #01, #02, #9A, #$0078, #$00C0, #00, #$1100 >   ;09
    scene-warp < #29, #21, #01, #02, #9B, #$0078, #$00C0, #00, #$1100 >   ;0A
    scene-warp < #31, #21, #01, #02, #9C, #$0078, #$00C0, #00, #$1100 >   ;0B
    scene-warp < #29, #05, #01, #02, #9D, #$00F8, #$00C0, #00, #$1200 >   ;0C
  ], [
  ] >
]

warp_def_92 [
  warp-def < [
    scene-warp < #09, #0D, #02, #01, #91, #$0340, #$0310, #03, #$5400 >
  ], [
  ] >
]

warp_def_93 [
  warp-def < [
    scene-warp < #07, #0D, #02, #01, #91, #$0330, #$0180, #03, #$5400 >
  ], [
  ] >
]

warp_def_94 [
  warp-def < [
    scene-warp < #07, #1D, #02, #01, #91, #$0060, #$0400, #03, #$5400 >
  ], [
    stair-warp < #06, #06, #01, #01, #$2110, #$0240, #$0000, #08, #$0301 >   ;00
    stair-warp < #06, #16, #01, #01, #$1100, #$0080, #$0000, #10, #$01FF >   ;01
  ] >
]

warp_def_95 [
  warp-def < [
    scene-warp < #19, #1D, #02, #01, #91, #$0150, #$0080, #03, #$5400 >   ;00
    scene-warp < #22, #1D, #02, #01, #91, #$01A0, #$0080, #03, #$5400 >   ;01
    scene-warp < #37, #15, #01, #02, #96, #$00A8, #$00C0, #00, #$1100 >   ;02
  ], [
    stair-warp < #06, #06, #01, #01, #$2410, #$0240, #$0000, #08, #$0301 >   ;00
    stair-warp < #06, #16, #01, #01, #$1100, #$0080, #$0000, #10, #$01FF >   ;01
    stair-warp < #26, #06, #01, #01, #$2410, #$0240, #$0000, #08, #$0301 >   ;02
    stair-warp < #26, #16, #01, #01, #$1301, #$0080, #$0000, #10, #$01FF >   ;03
  ] >
]

warp_def_96 [
  warp-def < [
    scene-warp < #0A, #0D, #02, #01, #95, #$0370, #$0170, #03, #$2410 >
  ], [
  ] >
]

warp_def_97 [
  warp-def < [
    scene-warp < #16, #0D, #02, #01, #91, #$02C0, #$0400, #03, #$5400 >
  ], [
  ] >
]

warp_def_98 [
  warp-def < [
    scene-warp < #09, #0D, #02, #01, #91, #$00D0, #$0400, #03, #$5400 >
  ], [
  ] >
]

warp_def_99 [
  warp-def < [
    scene-warp < #07, #1D, #02, #01, #91, #$0330, #$0400, #03, #$5400 >   ;00
    scene-warp < #0B, #09, #01, #01, #E6, #$0078, #$00C0, #00, #$1100 >   ;01
  ], [
    stair-warp < #06, #06, #01, #01, #$2110, #$0240, #$0000, #08, #$0301 >   ;00
    stair-warp < #06, #16, #01, #01, #$1100, #$0080, #$0000, #10, #$01FF >   ;01
  ] >
]

warp_def_9A [
  warp-def < [
    scene-warp < #07, #0D, #02, #01, #91, #$0230, #$0230, #03, #$5400 >
  ], [
  ] >
]

warp_def_9B [
  warp-def < [
    scene-warp < #07, #0D, #02, #01, #91, #$0290, #$0230, #03, #$5400 >
  ], [
  ] >
]

warp_def_9C [
  warp-def < [
    scene-warp < #07, #0D, #02, #01, #91, #$0310, #$0230, #03, #$5400 >
  ], [
  ] >
]

warp_def_9D [
  warp-def < [
    scene-warp < #0F, #0D, #02, #01, #91, #$0290, #$0070, #03, #$5400 >
  ], [
    stair-warp < #0F, #06, #01, #01, #$2210, #$0240, #$0000, #08, #$0301 >   ;00
    stair-warp < #0F, #16, #01, #01, #$1200, #$0080, #$0000, #10, #$01FF >   ;01
  ] >
]

warp_def_A0 [
  warp-def < [
    scene-warp < #00, #04, #01, #01, #A1, #$03E0, #$0330, #06, #$4400 >
  ], [
  ] >
]

warp_def_A1 [
  warp-def < [
    scene-warp < #3F, #33, #01, #01, #A0, #$0010, #$0040, #07, #$2300 >   ;00
    scene-warp < #06, #00, #02, #02, #A2, #$0068, #$03E0, #00, #$4200 >   ;01
    scene-warp < #0C, #00, #02, #02, #A2, #$00C8, #$03E0, #00, #$4200 >   ;02
    scene-warp < #1F, #2F, #01, #01, #E6, #$0078, #$00C0, #00, #$1100 >   ;03
  ], [
  ] >
]

warp_def_A2 [
  warp-def < [
    scene-warp < #06, #3F, #02, #01, #A1, #$0068, #$0020, #03, #$4400 >   ;00
    scene-warp < #0C, #3F, #02, #01, #A1, #$00C8, #$0020, #03, #$4400 >   ;01
    scene-warp < #1F, #3A, #01, #01, #A3, #$0010, #$01A0, #07, #$2800 >   ;02
    scene-warp < #1F, #28, #01, #01, #A3, #$0010, #$0080, #07, #$2800 >   ;03
    scene-warp < #00, #19, #01, #01, #A4, #$03E0, #$0190, #06, #$4400 >   ;04
    scene-warp < #04, #00, #02, #02, #A5, #$0048, #$03E0, #00, #$4400 >   ;05
  ], [
  ] >
]

warp_def_A3 [
  warp-def < [
    scene-warp < #00, #1A, #01, #01, #A2, #$01E0, #$03A0, #06, #$4200 >   ;00
    scene-warp < #00, #08, #01, #01, #A2, #$01E0, #$0280, #06, #$4200 >   ;01
    scene-warp < #7C, #0A, #01, #01, #E6, #$0078, #$00C0, #00, #$1100 >   ;02
  ], [
  ] >
]

warp_def_A4 [
  warp-def < [
    scene-warp < #3F, #19, #01, #01, #A2, #$0010, #$0190, #07, #$4200 >
  ], [
  ] >
]

warp_def_A5 [
  warp-def < [
    scene-warp < #04, #3F, #02, #01, #A2, #$0048, #$0020, #03, #$4200 >   ;00
    scene-warp < #3F, #36, #01, #01, #A6, #$0010, #$0360, #07, #$4400 >   ;01
    scene-warp < #34, #00, #02, #02, #A7, #$0348, #$03E0, #00, #$4800 >   ;02
    scene-warp < #00, #06, #01, #01, #A8, #$03E0, #$0060, #06, #$2400 >   ;03
  ], [
  ] >
]

warp_def_A6 [
  warp-def < [
    scene-warp < #00, #36, #01, #01, #A5, #$03E0, #$0360, #06, #$4400 >
  ], [
  ] >
]

warp_def_A7 [
  warp-def < [
    scene-warp < #34, #3F, #02, #01, #A5, #$0348, #$0020, #03, #$4400 >   ;00
    scene-warp < #79, #30, #01, #01, #E6, #$0078, #$00C0, #00, #$1100 >   ;01
  ], [
  ] >
]

warp_def_A8 [
  warp-def < [
    scene-warp < #3F, #06, #01, #01, #A5, #$0010, #$0060, #07, #$4400 >   ;00
    scene-warp < #04, #00, #02, #02, #A9, #$0048, #$03E0, #00, #$4200 >   ;01
  ], [
  ] >
]

warp_def_A9 [
  warp-def < [
    scene-warp < #04, #3F, #02, #01, #A8, #$0048, #$0020, #03, #$2400 >
  ], [
  ] >
]

warp_def_AC [
  warp-def < [
    scene-warp < #0B, #08, #01, #02, #AD, #$0078, #$00C0, #00, #$1100 >   ;00
    scene-warp < #17, #0A, #01, #02, #AE, #$0078, #$00C0, #00, #$1100 >   ;01
    scene-warp < #1C, #03, #01, #01, #E6, #$0078, #$00C0, #00, #$1100 >   ;02
  ], [
  ] >
]

warp_def_AD [
  warp-def < [
    scene-warp < #07, #0D, #02, #02, #AC, #$00B0, #$00A0, #03, #$2200 >
  ], [
  ] >
]

warp_def_AE [
  warp-def < [
    scene-warp < #07, #0D, #02, #02, #AC, #$0170, #$00C0, #03, #$2200 >
  ], [
  ] >
]

warp_def_B0 [
  warp-def < [
    scene-warp < #1F, #05, #02, #03, #B1, #$03F8, #$01C0, #00, #$2800 >
  ], [
  ] >
]

warp_def_B1 [
  warp-def < [
    scene-warp < #3F, #1F, #02, #01, #B0, #$01F8, #$0090, #03, #$5400 >   ;00
    scene-warp < #77, #00, #02, #01, #B2, #$0078, #$07C0, #00, #$8100 >   ;01
    scene-warp < #3F, #00, #02, #01, #B6, #$02F8, #$03D0, #80, #$4600 >   ;02
    scene-warp < #07, #00, #02, #01, #B5, #$0078, #$07C0, #00, #$8100 >   ;03
  ], [
  ] >
]

warp_def_B2 [
  warp-def < [
    scene-warp < #07, #7F, #02, #01, #B1, #$0778, #$0030, #03, #$2800 >   ;00
    scene-warp < #07, #00, #02, #01, #B3, #$0778, #$01C0, #00, #$2800 >   ;01
  ], [
  ] >
]

warp_def_B3 [
  warp-def < [
    scene-warp < #77, #1F, #02, #01, #B2, #$0078, #$0030, #03, #$8100 >   ;00
    scene-warp < #6A, #0D, #06, #02, #B4, #$0570, #$0000, #03, #$2600 >   ;01
    scene-warp < #08, #0C, #02, #01, #B4, #$0088, #$00C0, #03, #$2600 >   ;02
    scene-warp < #07, #1F, #02, #01, #B5, #$0078, #$0030, #03, #$8100 >   ;03
  ], [
  ] >
]

warp_def_B4 [
  warp-def < [
    scene-warp < #08, #06, #02, #02, #B3, #$0088, #$00A0, #00, #$2800 >
  ], [
  ] >
]

warp_def_B5 [
  warp-def < [
    scene-warp < #07, #00, #02, #01, #B3, #$0078, #$01C0, #00, #$2800 >   ;00
    scene-warp < #07, #7F, #02, #01, #B1, #$0078, #$0030, #03, #$2800 >   ;01
  ], [
  ] >
]

warp_def_B6 [
  warp-def < [
    scene-warp < #2D, #3F, #06, #01, #B1, #$03F8, #$0030, #03, #$2800 >   ;00
    scene-warp < #2E, #04, #04, #02, #B7, #$02F8, #$01C0, #00, #$2600 >   ;01
    scene-warp < #42, #31, #01, #01, #E6, #$0078, #$00C0, #00, #$1100 >   ;02
  ], [
  ] >
]

warp_def_B7 [
  warp-def < [
    scene-warp < #2F, #1F, #02, #01, #B6, #$02F8, #$00A8, #03, #$4600 >   ;00
    scene-warp < #04, #00, #02, #01, #B9, #$0048, #$05D0, #00, #$6100 >   ;01
    scene-warp < #0A, #00, #02, #01, #B9, #$00A8, #$05D0, #00, #$6100 >   ;02
    scene-warp < #56, #00, #02, #01, #B8, #$0078, #$05D0, #00, #$6100 >   ;03
    scene-warp < #2F, #00, #02, #01, #BA, #$01F8, #$05D0, #80, #$6400 >   ;04
  ], [
  ] >
]

warp_def_B8 [
  warp-def < [
    scene-warp < #07, #5F, #02, #01, #B7, #$0568, #$0030, #03, #$2600 >   ;00
    scene-warp < #08, #05, #01, #01, #E6, #$0078, #$00C0, #00, #$1100 >   ;01
  ], [
  ] >
]

warp_def_B9 [
  warp-def < [
    scene-warp < #04, #5F, #02, #01, #B7, #$0048, #$0030, #03, #$2600 >   ;00
    scene-warp < #0A, #5F, #02, #01, #B7, #$00A8, #$0030, #03, #$2600 >   ;01
  ], [
  ] >
]

warp_def_BA [
  warp-def < [
    scene-warp < #1E, #5F, #04, #01, #B7, #$02F8, #$0030, #03, #$2600 >   ;00
    scene-warp < #1F, #00, #02, #01, #BB, #$0178, #$02C0, #00, #$3300 >   ;01
    scene-warp < #31, #02, #02, #02, #BB, #$0278, #$02C0, #00, #$3300 >   ;02
  ], [
  ] >
]

warp_def_BB [
  warp-def < [
    scene-warp < #2B, #1A, #01, #01, #E6, #$0078, #$00C0, #00, #$1100 >   ;00
    scene-warp < #17, #2F, #02, #01, #BA, #$01F8, #$0030, #03, #$6400 >   ;01
    scene-warp < #27, #2F, #02, #01, #BA, #$0318, #$0040, #03, #$6400 >   ;02
    scene-warp < #17, #0A, #02, #01, #BC, #$0178, #$0090, #00, #$3300 >   ;03
  ], [
  ] >
]

warp_def_BC [
  warp-def < [
    scene-warp < #17, #0C, #02, #01, #BB, #$0178, #$0100, #03, #$3300 >   ;00
    scene-warp < #0B, #12, #02, #01, #BB, #$00A0, #$0120, #03, #$3300 >   ;01
    scene-warp < #10, #12, #02, #01, #BB, #$0110, #$0120, #03, #$3300 >   ;02
    scene-warp < #29, #14, #04, #01, #BB, #$0280, #$01A0, #03, #$3300 >   ;03
    scene-warp < #0D, #21, #05, #01, #BB, #$00F0, #$0210, #03, #$3300 >   ;04
    scene-warp < #17, #22, #02, #01, #BD, #$0178, #$0200, #00, #$3300 >   ;05
  ], [
  ] >
]

warp_def_BD [
  warp-def < [
    scene-warp < #17, #23, #02, #01, #BC, #$0178, #$0280, #03, #$3300 >   ;00
    scene-warp < #07, #09, #02, #01, #BE, #$0078, #$0080, #00, #$3300 >   ;01
    scene-warp < #27, #09, #02, #01, #BE, #$0278, #$0080, #00, #$3300 >   ;02
  ], [
  ] >
]

warp_def_BE [
  warp-def < [
    scene-warp < #07, #0B, #02, #01, #BD, #$0078, #$00C0, #03, #$3300 >   ;00
    scene-warp < #27, #0B, #02, #01, #BD, #$0278, #$00C0, #03, #$3300 >   ;01
    scene-warp < #23, #20, #03, #01, #BD, #$0248, #$01F0, #03, #$3300 >   ;02
    scene-warp < #17, #1B, #02, #01, #BF, #$00F8, #$0170, #00, #$2200 >   ;03
  ], [
  ] >
]

warp_def_BF [
  warp-def < [
    scene-warp < #0F, #1A, #02, #01, #BE, #$0178, #$0200, #03, #$3300 >
  ], [
  ] >
]

warp_def_C3 [
  warp-def < [
    scene-warp < #09, #09, #01, #02, #C4, #$0078, #$00C0, #00, #$1100 >   ;00
    scene-warp < #0F, #0A, #01, #02, #C8, #$0078, #$00C0, #00, #$1100 >   ;01
    scene-warp < #18, #0A, #01, #02, #C6, #$0078, #$00C0, #00, #$1100 >   ;02
    scene-warp < #04, #18, #01, #02, #C7, #$0078, #$00C0, #00, #$1100 >   ;03
    scene-warp < #0B, #19, #01, #02, #C5, #$0078, #$00C0, #00, #$1100 >   ;04
    scene-warp < #1A, #18, #01, #02, #C9, #$0078, #$00C0, #00, #$1100 >   ;05
    scene-warp < #02, #06, #01, #01, #E6, #$0078, #$00C0, #00, #$1100 >   ;06
  ], [
  ] >
]

warp_def_C4 [
  warp-def < [
    scene-warp < #07, #0D, #02, #02, #C3, #$0090, #$00B0, #03, #$2300 >
  ], [
  ] >
]

warp_def_C5 [
  warp-def < [
    scene-warp < #07, #0D, #02, #02, #C3, #$00B0, #$01B0, #03, #$2300 >
  ], [
  ] >
]

warp_def_C6 [
  warp-def < [
    scene-warp < #07, #0D, #02, #02, #C3, #$0180, #$00C0, #03, #$2300 >
  ], [
  ] >
]

warp_def_C7 [
  warp-def < [
    scene-warp < #07, #0D, #02, #02, #C3, #$0040, #$01A0, #03, #$2300 >
  ], [
  ] >
]

warp_def_C8 [
  warp-def < [
    scene-warp < #07, #0D, #02, #02, #C3, #$00F0, #$00C0, #03, #$2300 >
  ], [
  ] >
]

warp_def_C9 [
  warp-def < [
    scene-warp < #07, #0D, #02, #02, #C3, #$01A0, #$01A0, #03, #$2300 >
  ], [
  ] >
]

warp_def_CC [
  warp-def < [
    scene-warp < #27, #1A, #01, #01, #E6, #$0078, #$00C0, #00, #$1100 >   ;00
    scene-warp < #1C, #37, #01, #01, #E6, #$0078, #$00C0, #00, #$1100 >   ;01
    scene-warp < #1F, #10, #02, #02, #CD, #$0080, #$00C0, #80, #$1100 >   ;02
    scene-warp < #07, #37, #01, #02, #CE, #$0570, #$00C0, #80, #$4600 >   ;03
    scene-warp < #0D, #37, #01, #02, #D0, #$0470, #$00C0, #80, #$5500 >   ;04
    scene-warp < #13, #37, #01, #02, #D6, #$0070, #$00C0, #80, #$5500 >   ;05
    scene-warp < #2C, #37, #01, #02, #D8, #$0480, #$00C0, #80, #$5500 >   ;06
    scene-warp < #32, #37, #01, #02, #D4, #$0070, #$00C0, #80, #$5500 >   ;07
    scene-warp < #38, #37, #01, #02, #D2, #$0070, #$00C0, #80, #$4600 >   ;08
  ], [
  ] >
]

warp_def_CD [
  warp-def < [
    scene-warp < #07, #0D, #02, #01, #CC, #$01F8, #$0120, #03, #$4400 >
  ], [
  ] >
]

warp_def_CE [
  warp-def < [
    scene-warp < #57, #0D, #01, #01, #CC, #$0070, #$0390, #03, #$4400 >   ;00
    scene-warp < #0C, #37, #01, #02, #CF, #$0570, #$00C0, #00, #$4600 >   ;01
  ], [
    stair-warp < #09, #10, #01, #02, #$4600, #$0247, #$0000, #40, #$0801 >   ;00
    stair-warp < #09, #23, #01, #02, #$4600, #$0084, #$0000, #E0, #$01FE >   ;01
    stair-warp < #06, #23, #01, #02, #$4600, #$0248, #$0000, #50, #$0801 >   ;02
    stair-warp < #06, #37, #01, #02, #$4600, #$0086, #$0000, #D0, #$01FE >   ;03
    stair-warp < #57, #07, #01, #02, #$4600, #$024E, #$0000, #10, #$0802 >   ;04
    stair-warp < #57, #27, #01, #02, #$4600, #$008D, #$0000, #10, #$01FE >   ;05
  ] >
]

warp_def_CF [
  warp-def < [
    scene-warp < #56, #0D, #03, #02, #CE, #$00C0, #$0390, #03, #$4600 >   ;00
    scene-warp < #09, #37, #01, #02, #DA, #$0078, #$00C0, #00, #$1100 >   ;01
  ], [
    stair-warp < #09, #11, #01, #02, #$4600, #$0246, #$0000, #30, #$0801 >   ;00
    stair-warp < #09, #23, #01, #02, #$4600, #$0083, #$0000, #F0, #$01FE >   ;01
  ] >
]

warp_def_D0 [
  warp-def < [
    scene-warp < #46, #0D, #03, #02, #CC, #$00D0, #$0390, #03, #$4400 >   ;00
    scene-warp < #19, #47, #01, #02, #D1, #$0080, #$00C0, #00, #$6400 >   ;01
  ], [
    stair-warp < #08, #17, #01, #02, #$5500, #$024E, #$0000, #10, #$0802 >   ;00
    stair-warp < #08, #37, #01, #02, #$5500, #$008D, #$0000, #10, #$01FE >   ;01
    stair-warp < #48, #33, #01, #02, #$5500, #$0248, #$0000, #50, #$0801 >   ;02
    stair-warp < #48, #47, #01, #02, #$5500, #$0086, #$0000, #D0, #$01FE >   ;03
  ] >
]

warp_def_D1 [
  warp-def < [
    scene-warp < #07, #0D, #03, #02, #D0, #$0190, #$0490, #00, #$5500 >   ;00
    scene-warp < #39, #45, #01, #02, #DA, #$0178, #$00C0, #00, #$1201 >   ;01
  ], [
  ] >
]

warp_def_D2 [
  warp-def < [
    scene-warp < #06, #0D, #03, #02, #CC, #$0380, #$0390, #03, #$4400 >   ;00
    scene-warp < #0C, #37, #01, #02, #D3, #$0070, #$00C0, #00, #$3800 >   ;01
  ], [
    stair-warp < #52, #0D, #01, #02, #$4600, #$024B, #$0000, #80, #$0801 >   ;00
    stair-warp < #52, #24, #01, #02, #$4600, #$0089, #$0000, #A0, #$01FE >   ;01
    stair-warp < #39, #24, #01, #02, #$4600, #$0247, #$0000, #40, #$0801 >   ;02
    stair-warp < #39, #37, #01, #02, #$4600, #$0084, #$0000, #E0, #$01FE >   ;03
    stair-warp < #15, #26, #01, #02, #$4600, #$0244, #$0000, #20, #$0801 >   ;04
    stair-warp < #15, #37, #01, #02, #$4600, #$0080, #$0000, #00, #$01FF >   ;05
  ] >
]

warp_def_D3 [
  warp-def < [
    scene-warp < #06, #0D, #03, #02, #D2, #$00C0, #$0390, #03, #$4600 >   ;00
    scene-warp < #76, #20, #01, #02, #DA, #$0578, #$00C0, #00, #$1605 >   ;01
  ], [
    stair-warp < #72, #0B, #01, #02, #$3800, #$0249, #$0000, #60, #$0801 >   ;00
    stair-warp < #72, #20, #01, #02, #$3800, #$0087, #$0000, #C0, #$01FE >   ;01
  ] >
]

warp_def_D4 [
  warp-def < [
    scene-warp < #06, #0D, #03, #02, #CC, #$0320, #$0390, #03, #$4400 >   ;00
    scene-warp < #06, #47, #01, #02, #D5, #$0070, #$00C0, #00, #$5500 >   ;01
  ], [
  ] >
]

warp_def_D5 [
  warp-def < [
    scene-warp < #06, #0D, #03, #02, #D4, #$0060, #$0490, #03, #$5500 >   ;00
    scene-warp < #07, #47, #01, #02, #DA, #$0478, #$00C0, #00, #$1504 >   ;01
  ], [
    stair-warp < #48, #28, #01, #02, #$5500, #$0241, #$0000, #00, #$0802 >   ;00
    stair-warp < #48, #47, #01, #02, #$5500, #$008C, #$0000, #20, #$01FE >   ;01
  ] >
]

warp_def_D6 [
  warp-def < [
    scene-warp < #06, #0D, #03, #02, #CC, #$0130, #$0390, #03, #$4400 >   ;00
    scene-warp < #08, #47, #01, #02, #D7, #$0070, #$01C0, #00, #$6400 >   ;01
  ], [
    stair-warp < #08, #17, #01, #02, #$5500, #$0243, #$0000, #10, #$0801 >   ;00
    stair-warp < #08, #27, #01, #02, #$5500, #$0082, #$0000, #10, #$01FF >   ;01
    stair-warp < #47, #27, #01, #02, #$5500, #$024E, #$0000, #10, #$0802 >   ;02
    stair-warp < #47, #47, #01, #02, #$5500, #$008D, #$0000, #10, #$01FE >   ;03
  ] >
]

warp_def_D7 [
  warp-def < [
    scene-warp < #06, #1D, #03, #02, #D6, #$0080, #$0490, #03, #$5500 >   ;00
    scene-warp < #37, #47, #01, #02, #DA, #$0278, #$00C0, #00, #$1302 >   ;01
  ], [
    stair-warp < #37, #27, #01, #02, #$6400, #$0243, #$0000, #10, #$0801 >   ;00
    stair-warp < #37, #37, #01, #02, #$6400, #$0082, #$0000, #10, #$01FF >   ;01
  ] >
]

warp_def_D8 [
  warp-def < [
    scene-warp < #47, #0D, #03, #02, #CC, #$02C0, #$0390, #03, #$4400 >   ;00
    scene-warp < #06, #47, #01, #02, #D9, #$0080, #$00C0, #00, #$3800 >   ;01
  ], [
    stair-warp < #09, #0E, #01, #02, #$5500, #$0246, #$0000, #30, #$0801 >   ;00
    stair-warp < #09, #20, #01, #02, #$5500, #$0083, #$0000, #F0, #$01FE >   ;01
    stair-warp < #47, #37, #01, #02, #$5500, #$0243, #$0000, #10, #$0801 >   ;02
    stair-warp < #47, #47, #01, #02, #$5500, #$0082, #$0000, #10, #$01FF >   ;03
    stair-warp < #44, #27, #01, #02, #$5500, #$0243, #$0000, #10, #$0801 >   ;04
    stair-warp < #44, #37, #01, #02, #$5500, #$0082, #$0000, #10, #$01FF >   ;05
    stair-warp < #49, #17, #01, #02, #$5500, #$0243, #$0000, #10, #$0801 >   ;06
    stair-warp < #49, #27, #01, #02, #$5500, #$0082, #$0000, #10, #$01FF >   ;07
    stair-warp < #37, #17, #01, #02, #$5500, #$0243, #$0000, #10, #$0801 >   ;08
    stair-warp < #37, #27, #01, #02, #$5500, #$0082, #$0000, #10, #$01FF >   ;09
    stair-warp < #29, #17, #01, #02, #$5500, #$024F, #$0000, #10, #$0803 >   ;0A
    stair-warp < #29, #47, #01, #02, #$5500, #$008A, #$0000, #10, #$01FD >   ;0B
    stair-warp < #19, #37, #01, #02, #$5500, #$0243, #$0000, #10, #$0801 >   ;0C
    stair-warp < #19, #47, #01, #02, #$5500, #$0082, #$0000, #10, #$01FF >   ;0D
    stair-warp < #09, #37, #01, #02, #$5500, #$0243, #$0000, #10, #$0801 >   ;0E
    stair-warp < #09, #47, #01, #02, #$5500, #$0082, #$0000, #10, #$01FF >   ;0F
  ] >
]

warp_def_D9 [
  warp-def < [
    scene-warp < #07, #0D, #03, #02, #D8, #$0060, #$0490, #03, #$5500 >   ;00
    scene-warp < #7E, #0B, #02, #02, #DB, #$0028, #$00B8, #07, #$2800 >   ;01
  ], [
    stair-warp < #78, #07, #01, #02, #$3800, #$024E, #$0000, #10, #$0802 >   ;00
    stair-warp < #78, #27, #01, #02, #$3800, #$008D, #$0000, #10, #$01FE >   ;01
  ] >
]

warp_def_DA [
  warp-def < [
    scene-warp < #07, #0D, #02, #02, #CF, #$0090, #$0390, #03, #$4600 >   ;00
    scene-warp < #17, #0D, #02, #02, #D1, #$0390, #$0470, #03, #$6400 >   ;01
    scene-warp < #57, #0D, #02, #02, #D3, #$0760, #$0220, #03, #$3800 >   ;02
    scene-warp < #47, #0D, #02, #02, #D5, #$0070, #$0490, #03, #$5500 >   ;03
    scene-warp < #27, #0D, #02, #02, #D7, #$0370, #$0490, #03, #$6400 >   ;04
    scene-warp < #37, #0D, #02, #02, #DB, #$0780, #$0090, #03, #$2800 >   ;05
  ], [
  ] >
]

warp_def_DB [
  warp-def < [
    scene-warp < #00, #0B, #02, #02, #D9, #$07C8, #$00B8, #06, #$3800 >   ;00
    scene-warp < #78, #07, #01, #02, #DA, #$0378, #$00C0, #00, #$1403 >   ;01
  ], [
  ] >
]

warp_def_DE [
  warp-def < [
    scene-warp < #07, #06, #02, #02, #DF, #$0078, #$01C0, #00, #$2800 >   ;00
    scene-warp < #17, #0D, #02, #01, #E3, #$0098, #$0090, #03, #$1300 >   ;01
  ], [
  ] >
]

warp_def_DF [
  warp-def < [
    scene-warp < #06, #1D, #04, #02, #DE, #$0078, #$0080, #03, #$1100 >   ;00
    scene-warp < #09, #07, #02, #02, #E0, #$0098, #$0390, #83, #$4830 >   ;01
  ], [
    stair-warp < #75, #07, #02, #02, #$2810, #$0240, #$0000, #08, #$0301 >   ;00
    stair-warp < #75, #17, #02, #02, #$1800, #$0080, #$0000, #10, #$01FF >   ;01
  ] >
]

warp_def_E0 [
  warp-def < [
    scene-warp < #46, #39, #01, #01, #E6, #$0078, #$00C0, #00, #$1100 >   ;00
    scene-warp < #09, #37, #02, #02, #DF, #$0098, #$0090, #03, #$1800 >   ;01
    scene-warp < #0D, #27, #02, #02, #E1, #$0078, #$0790, #03, #$8100 >   ;02
    scene-warp < #0D, #17, #02, #02, #E1, #$0078, #$0090, #03, #$8100 >   ;03
    scene-warp < #15, #07, #02, #02, #E2, #$00D0, #$06E0, #03, #$8400 >   ;04
    scene-warp < #3F, #38, #02, #02, #F2, #$0078, #$00B0, #03, #$1100 >   ;05
    scene-warp < #3F, #28, #02, #02, #F3, #$0100, #$0080, #03, #$1200 >   ;06
    scene-warp < #2F, #18, #02, #02, #F4, #$0078, #$01C0, #03, #$2100 >   ;07
    scene-warp < #2F, #08, #02, #02, #F5, #$0180, #$02C0, #03, #$3320 >   ;08
  ], [
    stair-warp < #71, #27, #02, #02, #$4830, #$0240, #$0000, #08, #$0301 >   ;00
    stair-warp < #71, #37, #02, #02, #$3820, #$0080, #$0000, #10, #$01FF >   ;01
    stair-warp < #49, #07, #02, #02, #$2810, #$0240, #$0000, #08, #$0301 >   ;02
    stair-warp < #49, #17, #02, #02, #$1800, #$0080, #$0000, #10, #$01FF >   ;03
  ] >
]

warp_def_E1 [
  warp-def < [
    scene-warp < #07, #77, #02, #02, #E0, #$00D8, #$0290, #03, #$3820 >   ;00
    scene-warp < #07, #07, #02, #02, #E0, #$00D8, #$0190, #83, #$2610 >   ;01
    scene-warp < #17, #77, #02, #02, #E3, #$0158, #$0290, #03, #$3420 >   ;02
    scene-warp < #17, #07, #02, #02, #E3, #$0078, #$0190, #03, #$2310 >   ;03
  ], [
  ] >
]

warp_def_E2 [
  warp-def < [
    scene-warp < #0D, #6C, #01, #02, #E0, #$0158, #$0090, #03, #$1600 >   ;00
    scene-warp < #0D, #0C, #01, #02, #E3, #$00D8, #$0390, #83, #$4430 >   ;01
  ], [
  ] >
]

warp_def_E3 [
  warp-def < [
    scene-warp < #0D, #37, #02, #02, #E2, #$00D0, #$00E0, #03, #$8400 >   ;00
    scene-warp < #15, #27, #02, #02, #E1, #$0178, #$0790, #03, #$8201 >   ;01
    scene-warp < #07, #17, #02, #02, #E1, #$0178, #$0090, #03, #$8201 >   ;02
    scene-warp < #09, #07, #02, #02, #DE, #$0178, #$00C0, #80, #$1201 >   ;03
    scene-warp < #1F, #38, #02, #02, #F6, #$0100, #$0190, #03, #$2200 >   ;04
    scene-warp < #2B, #19, #01, #01, #E6, #$0078, #$00C0, #00, #$1100 >   ;05
  ], [
    stair-warp < #29, #27, #02, #02, #$4430, #$0240, #$0000, #08, #$0301 >   ;00
    stair-warp < #29, #37, #02, #02, #$3420, #$0080, #$0000, #10, #$01FF >   ;01
    stair-warp < #25, #07, #02, #02, #$2310, #$0240, #$0000, #08, #$0301 >   ;02
    stair-warp < #25, #17, #02, #02, #$1300, #$0080, #$0000, #10, #$01FF >   ;03
  ] >
]

---------------------------------------------
; Shared by scenes $E6, $E7, $E8 and $E9 (four pointers).

warp_def_E6 [
  warp-def < [
    scene-warp < #37, #05, #02, #04, #EA, #$0078, #$00C0, #00, #$1100 >
  ], [
  ] >
]

warp_def_EA [
  warp-def < [
  ], [
  ] >
]

warp_def_EB [
  warp-def < [
  ], [
  ] >
]

warp_def_FE [
  warp-def < [
  ], [
  ] >
]