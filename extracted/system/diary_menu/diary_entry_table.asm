; Diary location table (Bank 0B, 256 pointers = 512 bytes, then 23 diary-entry records). Index = scene ID; the diary menu looks up the scene saved in each slot ($0D74 / $0D76 / $0D78, 0 = empty, filled by DiaryScanSramSlots) to print the location name and to pan the Mode 7 camera.
; 
; Each diary-entry is a name string closed by $CA (not shown) followed by 4 bytes printed in memory order: the camera target X word and the camera target Y word (little-endian). DiaryCameraPan scans for the $CA, reads the two words and moves cameraTargetX / cameraTargetY towards them. The default entry's (X, Y) = ($0080, $0300) is the diary menu's initial camera. The [ADR:&diary_entry_table,D74] tokens of the slot strings print the name by the same lookup.
; 
; The table is the 256-word jump table; 221 scenes point at the default entry ('Start from beginning') and 35 scenes (the places that have a Dark Space and a save) at 22 named locations. Names with a trailing space ('Itory Village ', 'City of Euro ', 'Natives' Village ') are in the ROM that way.
; 
; === CORRECTIONS ===
; 
; The old header said the 4 bytes are a 'packed camera position value'. They are two words (X, Y), not packed. docs/structs-reference.md calls diary-entry a 'warp destination' with 'scene ID + X/Y coordinates'; the entry holds no scene ID (the scene is the table index) and nothing warps with it: the load goes to scene $E6 (DiaryStartLoadConfirm).
---------------------------------------------

?BANK 0B

---------------------------------------------

; Scene ID -> diary entry pointer (2 bytes each, scenes $00-$FF). Named scenes: $01, $0B, $12, $15, $1E, $26, $28, $34, $3D, $40, $42, $4C, $51, $54, $56, $5A, $60, $62, $6C, $7C, $85, $86, $88, $99, $A1, $A3, $A7, $AC, $B6, $B8, $BB, $C3, $CC, $E0, $E3; all others use the default entry.

diary_entry_table [
  &diary_entry_default   ;00
  &diary_entry_south_cape   ;01
  &diary_entry_default   ;02
  &diary_entry_default   ;03
  &diary_entry_default   ;04
  &diary_entry_default   ;05
  &diary_entry_default   ;06
  &diary_entry_default   ;07
  &diary_entry_default   ;08
  &diary_entry_default   ;09
  &diary_entry_default   ;0A
  &diary_entry_edward_prison   ;0B
  &diary_entry_default   ;0C
  &diary_entry_default   ;0D
  &diary_entry_default   ;0E
  &diary_entry_default   ;0F
  &diary_entry_default   ;10
  &diary_entry_default   ;11
  &diary_entry_underground_tunnel   ;12
  &diary_entry_default   ;13
  &diary_entry_default   ;14
  &diary_entry_itory_village   ;15
  &diary_entry_default   ;16
  &diary_entry_default   ;17
  &diary_entry_default   ;18
  &diary_entry_default   ;19
  &diary_entry_default   ;1A
  &diary_entry_default   ;1B
  &diary_entry_default   ;1C
  &diary_entry_default   ;1D
  &diary_entry_larai_cliff   ;1E
  &diary_entry_default   ;1F
  &diary_entry_default   ;20
  &diary_entry_default   ;21
  &diary_entry_default   ;22
  &diary_entry_default   ;23
  &diary_entry_default   ;24
  &diary_entry_default   ;25
  &diary_entry_incan_ruins   ;26
  &diary_entry_default   ;27
  &diary_entry_incan_ruins   ;28
  &diary_entry_default   ;29
  &diary_entry_default   ;2A
  &diary_entry_default   ;2B
  &diary_entry_default   ;2C
  &diary_entry_default   ;2D
  &diary_entry_default   ;2E
  &diary_entry_default   ;2F
  &diary_entry_default   ;30
  &diary_entry_default   ;31
  &diary_entry_default   ;32
  &diary_entry_default   ;33
  &diary_entry_freejia   ;34
  &diary_entry_default   ;35
  &diary_entry_default   ;36
  &diary_entry_default   ;37
  &diary_entry_default   ;38
  &diary_entry_default   ;39
  &diary_entry_default   ;3A
  &diary_entry_default   ;3B
  &diary_entry_default   ;3C
  &diary_entry_diamond_mine   ;3D
  &diary_entry_default   ;3E
  &diary_entry_default   ;3F
  &diary_entry_diamond_mine   ;40
  &diary_entry_default   ;41
  &diary_entry_diamond_mine   ;42
  &diary_entry_default   ;43
  &diary_entry_default   ;44
  &diary_entry_default   ;45
  &diary_entry_default   ;46
  &diary_entry_default   ;47
  &diary_entry_default   ;48
  &diary_entry_default   ;49
  &diary_entry_default   ;4A
  &diary_entry_default   ;4B
  &diary_entry_sky_garden   ;4C
  &diary_entry_default   ;4D
  &diary_entry_default   ;4E
  &diary_entry_default   ;4F
  &diary_entry_default   ;50
  &diary_entry_sky_garden   ;51
  &diary_entry_default   ;52
  &diary_entry_default   ;53
  &diary_entry_sky_garden   ;54
  &diary_entry_default   ;55
  &diary_entry_sky_garden   ;56
  &diary_entry_default   ;57
  &diary_entry_default   ;58
  &diary_entry_default   ;59
  &diary_entry_seaside_palace   ;5A
  &diary_entry_default   ;5B
  &diary_entry_default   ;5C
  &diary_entry_default   ;5D
  &diary_entry_default   ;5E
  &diary_entry_default   ;5F
  &diary_entry_mu   ;60
  &diary_entry_default   ;61
  &diary_entry_mu   ;62
  &diary_entry_default   ;63
  &diary_entry_default   ;64
  &diary_entry_default   ;65
  &diary_entry_default   ;66
  &diary_entry_default   ;67
  &diary_entry_default   ;68
  &diary_entry_default   ;69
  &diary_entry_default   ;6A
  &diary_entry_default   ;6B
  &diary_entry_angel_village   ;6C
  &diary_entry_default   ;6D
  &diary_entry_default   ;6E
  &diary_entry_default   ;6F
  &diary_entry_default   ;70
  &diary_entry_default   ;71
  &diary_entry_default   ;72
  &diary_entry_default   ;73
  &diary_entry_default   ;74
  &diary_entry_default   ;75
  &diary_entry_default   ;76
  &diary_entry_default   ;77
  &diary_entry_default   ;78
  &diary_entry_default   ;79
  &diary_entry_default   ;7A
  &diary_entry_default   ;7B
  &diary_entry_watermia   ;7C
  &diary_entry_default   ;7D
  &diary_entry_default   ;7E
  &diary_entry_default   ;7F
  &diary_entry_default   ;80
  &diary_entry_default   ;81
  &diary_entry_default   ;82
  &diary_entry_default   ;83
  &diary_entry_default   ;84
  &diary_entry_great_wall   ;85
  &diary_entry_great_wall   ;86
  &diary_entry_default   ;87
  &diary_entry_great_wall   ;88
  &diary_entry_default   ;89
  &diary_entry_default   ;8A
  &diary_entry_default   ;8B
  &diary_entry_default   ;8C
  &diary_entry_default   ;8D
  &diary_entry_default   ;8E
  &diary_entry_default   ;8F
  &diary_entry_default   ;90
  &diary_entry_default   ;91
  &diary_entry_default   ;92
  &diary_entry_default   ;93
  &diary_entry_default   ;94
  &diary_entry_default   ;95
  &diary_entry_default   ;96
  &diary_entry_default   ;97
  &diary_entry_default   ;98
  &diary_entry_euro   ;99
  &diary_entry_default   ;9A
  &diary_entry_default   ;9B
  &diary_entry_default   ;9C
  &diary_entry_default   ;9D
  &diary_entry_default   ;9E
  &diary_entry_default   ;9F
  &diary_entry_default   ;A0
  &diary_entry_mt_temple   ;A1
  &diary_entry_default   ;A2
  &diary_entry_mt_temple   ;A3
  &diary_entry_default   ;A4
  &diary_entry_default   ;A5
  &diary_entry_default   ;A6
  &diary_entry_mt_temple   ;A7
  &diary_entry_default   ;A8
  &diary_entry_default   ;A9
  &diary_entry_default   ;AA
  &diary_entry_default   ;AB
  &diary_entry_natives_village   ;AC
  &diary_entry_default   ;AD
  &diary_entry_default   ;AE
  &diary_entry_default   ;AF
  &diary_entry_default   ;B0
  &diary_entry_default   ;B1
  &diary_entry_default   ;B2
  &diary_entry_default   ;B3
  &diary_entry_default   ;B4
  &diary_entry_default   ;B5
  &diary_entry_garden   ;B6
  &diary_entry_default   ;B7
  &diary_entry_ankor_wat   ;B8
  &diary_entry_default   ;B9
  &diary_entry_default   ;BA
  &diary_entry_ankor_wat   ;BB
  &diary_entry_default   ;BC
  &diary_entry_default   ;BD
  &diary_entry_default   ;BE
  &diary_entry_default   ;BF
  &diary_entry_default   ;C0
  &diary_entry_default   ;C1
  &diary_entry_default   ;C2
  &diary_entry_dao_village   ;C3
  &diary_entry_default   ;C4
  &diary_entry_default   ;C5
  &diary_entry_default   ;C6
  &diary_entry_default   ;C7
  &diary_entry_default   ;C8
  &diary_entry_default   ;C9
  &diary_entry_default   ;CA
  &diary_entry_default   ;CB
  &diary_entry_pyramid   ;CC
  &diary_entry_default   ;CD
  &diary_entry_default   ;CE
  &diary_entry_default   ;CF
  &diary_entry_default   ;D0
  &diary_entry_default   ;D1
  &diary_entry_default   ;D2
  &diary_entry_default   ;D3
  &diary_entry_default   ;D4
  &diary_entry_default   ;D5
  &diary_entry_default   ;D6
  &diary_entry_default   ;D7
  &diary_entry_default   ;D8
  &diary_entry_default   ;D9
  &diary_entry_default   ;DA
  &diary_entry_default   ;DB
  &diary_entry_default   ;DC
  &diary_entry_default   ;DD
  &diary_entry_default   ;DE
  &diary_entry_default   ;DF
  &diary_entry_babel_tower   ;E0
  &diary_entry_default   ;E1
  &diary_entry_default   ;E2
  &diary_entry_babel_tower   ;E3
  &diary_entry_default   ;E4
  &diary_entry_default   ;E5
  &diary_entry_default   ;E6
  &diary_entry_default   ;E7
  &diary_entry_default   ;E8
  &diary_entry_default   ;E9
  &diary_entry_default   ;EA
  &diary_entry_default   ;EB
  &diary_entry_default   ;EC
  &diary_entry_default   ;ED
  &diary_entry_default   ;EE
  &diary_entry_default   ;EF
  &diary_entry_default   ;F0
  &diary_entry_default   ;F1
  &diary_entry_default   ;F2
  &diary_entry_default   ;F3
  &diary_entry_default   ;F4
  &diary_entry_default   ;F5
  &diary_entry_default   ;F6
  &diary_entry_default   ;F7
  &diary_entry_default   ;F8
  &diary_entry_default   ;F9
  &diary_entry_default   ;FA
  &diary_entry_default   ;FB
  &diary_entry_default   ;FC
  &diary_entry_default   ;FD
  &diary_entry_default   ;FE
  &diary_entry_default   ;FF
]

---------------------------------------------
; Default 'Start from beginning': camera ($0080, $0300), the diary menu's start position. Used by 221 scene IDs.

diary_entry_default [
  diary-entry < `Start from beginning`, #80000003 >
]

---------------------------------------------
; South Cape: scene $01; camera ($0080, $0320).

diary_entry_south_cape [
  diary-entry < `South Cape`, #80002003 >
]

---------------------------------------------
; Edward Prison: scene $0B; camera ($0080, $02B0).

diary_entry_edward_prison [
  diary-entry < `Edward Prison`, #8000B002 >
]

---------------------------------------------
; Underground Tunnel: scene $12; camera ($0080, $02B0), the same as Edward Prison.

diary_entry_underground_tunnel [
  diary-entry < `Underground Tunnel`, #8000B002 >
]

---------------------------------------------
; Itory Village: scene $15; camera ($004A, $0238).

diary_entry_itory_village [
  diary-entry < `Itory Village `, #4A003802 >
]

---------------------------------------------
; Larai Cliff: scene $1E; camera ($00BA, $020C).

diary_entry_larai_cliff [
  diary-entry < `Larai Cliff`, #BA000C02 >
]

---------------------------------------------
; Incan ruins: scenes $26, $28; camera ($00BA, $020C), the same as Larai Cliff.

diary_entry_incan_ruins [
  diary-entry < `Incan ruins`, #BA000C02 >
]

---------------------------------------------
; Freejia: scene $34; camera ($01DA, $025C).

diary_entry_freejia [
  diary-entry < `Freejia`, #DA015C02 >
]

---------------------------------------------
; Diamond Mine: scenes $3D, $40, $42; camera ($02C0, $02EC).

diary_entry_diamond_mine [
  diary-entry < `Diamond Mine`, #C002EC02 >
]

---------------------------------------------
; Sky Garden: scenes $4C, $51, $54, $56; camera ($028A, $021C).

diary_entry_sky_garden [
  diary-entry < `Sky Garden`, #8A021C02 >
]

---------------------------------------------
; Seaside Palace: scene $5A; camera ($02F3, $001A).

diary_entry_seaside_palace [
  diary-entry < `Seaside Palace`, #F3021A00 >
]

---------------------------------------------
; Mu: scenes $60, $62; camera ($02B0, $0000).

diary_entry_mu [
  diary-entry < `Mu`, #B0020000 >
]

---------------------------------------------
; Angel Village: scene $6C; camera ($02F3, $0100).

diary_entry_angel_village [
  diary-entry < `Angel Village`, #F3020001 >
]

---------------------------------------------
; Watermia: scene $7C; camera ($0254, $012A).

diary_entry_watermia [
  diary-entry < `Watermia`, #54022A01 >
]

---------------------------------------------
; Great Wall: scenes $85, $86, $88; camera ($0228, $00B0).

diary_entry_great_wall [
  diary-entry < `Great Wall`, #2802B000 >
]

---------------------------------------------
; City of Euro: scene $99; camera ($0158, $00C0).

diary_entry_euro [
  diary-entry < `City of Euro `, #5801C000 >
]

---------------------------------------------
; Mt. Temple: scenes $A1, $A3, $A7; camera ($018E, $0046).

diary_entry_mt_temple [
  diary-entry < `Mt. Temple`, #8E014600 >
]

---------------------------------------------
; Natives' Village: scene $AC; camera ($00A8, $0134).

diary_entry_natives_village [
  diary-entry < `Natives' Village `, #A8003401 >
]

---------------------------------------------
; Garden: scene $B6; camera ($00B8, $00E0), the same as Ankor Wat.

diary_entry_garden [
  diary-entry < `Garden`, #B800E000 >
]

---------------------------------------------
; Ankor Wat: scenes $B8, $BB; camera ($00B8, $00E0).

diary_entry_ankor_wat [
  diary-entry < `Ankor Wat`, #B800E000 >
]

---------------------------------------------
; Dao Village: scene $C3; camera ($0014, $00A2).

diary_entry_dao_village [
  diary-entry < `Dao Village`, #1400A200 >
]

---------------------------------------------
; Pyramid: scene $CC; camera ($0000, $0038).

diary_entry_pyramid [
  diary-entry < `Pyramid`, #00003800 >
]

---------------------------------------------
; Babel Tower: scenes $E0, $E3; camera ($0184, $0190).

diary_entry_babel_tower [
  diary-entry < `Babel Tower`, #84019001 >
]