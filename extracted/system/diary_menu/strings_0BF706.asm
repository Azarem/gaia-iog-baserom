; Diary entry lookup table — maps scene IDs (0–255) to diary entry records for the save menu.
; 
; Each diary-entry contains a location name string and a packed camera position value
; used by the diary menu's Mode 7 camera pan (code_0BE527). Most scenes share the default
; entry diary_entry_0BF906 ("Start from beginning"). Named locations correspond to the
; game's major areas (South Cape, Itory Village, Freejia, etc.).
---------------------------------------------

?BANK 0B

---------------------------------------------

strings_0BF706 [
  &diary_entry_0BF906   ;00
  &diary_entry_0BF91C   ;01
  &diary_entry_0BF906   ;02
  &diary_entry_0BF906   ;03
  &diary_entry_0BF906   ;04
  &diary_entry_0BF906   ;05
  &diary_entry_0BF906   ;06
  &diary_entry_0BF906   ;07
  &diary_entry_0BF906   ;08
  &diary_entry_0BF906   ;09
  &diary_entry_0BF906   ;0A
  &diary_entry_0BF927   ;0B
  &diary_entry_0BF906   ;0C
  &diary_entry_0BF906   ;0D
  &diary_entry_0BF906   ;0E
  &diary_entry_0BF906   ;0F
  &diary_entry_0BF906   ;10
  &diary_entry_0BF906   ;11
  &diary_entry_0BF934   ;12
  &diary_entry_0BF906   ;13
  &diary_entry_0BF906   ;14
  &diary_entry_0BF94B   ;15
  &diary_entry_0BF906   ;16
  &diary_entry_0BF906   ;17
  &diary_entry_0BF906   ;18
  &diary_entry_0BF906   ;19
  &diary_entry_0BF906   ;1A
  &diary_entry_0BF906   ;1B
  &diary_entry_0BF906   ;1C
  &diary_entry_0BF906   ;1D
  &diary_entry_0BF95E   ;1E
  &diary_entry_0BF906   ;1F
  &diary_entry_0BF906   ;20
  &diary_entry_0BF906   ;21
  &diary_entry_0BF906   ;22
  &diary_entry_0BF906   ;23
  &diary_entry_0BF906   ;24
  &diary_entry_0BF906   ;25
  &diary_entry_0BF96A   ;26
  &diary_entry_0BF906   ;27
  &diary_entry_0BF96A   ;28
  &diary_entry_0BF906   ;29
  &diary_entry_0BF906   ;2A
  &diary_entry_0BF906   ;2B
  &diary_entry_0BF906   ;2C
  &diary_entry_0BF906   ;2D
  &diary_entry_0BF906   ;2E
  &diary_entry_0BF906   ;2F
  &diary_entry_0BF906   ;30
  &diary_entry_0BF906   ;31
  &diary_entry_0BF906   ;32
  &diary_entry_0BF906   ;33
  &diary_entry_0BF97A   ;34
  &diary_entry_0BF906   ;35
  &diary_entry_0BF906   ;36
  &diary_entry_0BF906   ;37
  &diary_entry_0BF906   ;38
  &diary_entry_0BF906   ;39
  &diary_entry_0BF906   ;3A
  &diary_entry_0BF906   ;3B
  &diary_entry_0BF906   ;3C
  &diary_entry_0BF986   ;3D
  &diary_entry_0BF906   ;3E
  &diary_entry_0BF906   ;3F
  &diary_entry_0BF986   ;40
  &diary_entry_0BF906   ;41
  &diary_entry_0BF986   ;42
  &diary_entry_0BF906   ;43
  &diary_entry_0BF906   ;44
  &diary_entry_0BF906   ;45
  &diary_entry_0BF906   ;46
  &diary_entry_0BF906   ;47
  &diary_entry_0BF906   ;48
  &diary_entry_0BF906   ;49
  &diary_entry_0BF906   ;4A
  &diary_entry_0BF906   ;4B
  &diary_entry_0BF991   ;4C
  &diary_entry_0BF906   ;4D
  &diary_entry_0BF906   ;4E
  &diary_entry_0BF906   ;4F
  &diary_entry_0BF906   ;50
  &diary_entry_0BF991   ;51
  &diary_entry_0BF906   ;52
  &diary_entry_0BF906   ;53
  &diary_entry_0BF991   ;54
  &diary_entry_0BF906   ;55
  &diary_entry_0BF991   ;56
  &diary_entry_0BF906   ;57
  &diary_entry_0BF906   ;58
  &diary_entry_0BF906   ;59
  &diary_entry_0BF9A0   ;5A
  &diary_entry_0BF906   ;5B
  &diary_entry_0BF906   ;5C
  &diary_entry_0BF906   ;5D
  &diary_entry_0BF906   ;5E
  &diary_entry_0BF906   ;5F
  &diary_entry_0BF9AD   ;60
  &diary_entry_0BF906   ;61
  &diary_entry_0BF9AD   ;62
  &diary_entry_0BF906   ;63
  &diary_entry_0BF906   ;64
  &diary_entry_0BF906   ;65
  &diary_entry_0BF906   ;66
  &diary_entry_0BF906   ;67
  &diary_entry_0BF906   ;68
  &diary_entry_0BF906   ;69
  &diary_entry_0BF906   ;6A
  &diary_entry_0BF906   ;6B
  &diary_entry_0BF9B4   ;6C
  &diary_entry_0BF906   ;6D
  &diary_entry_0BF906   ;6E
  &diary_entry_0BF906   ;6F
  &diary_entry_0BF906   ;70
  &diary_entry_0BF906   ;71
  &diary_entry_0BF906   ;72
  &diary_entry_0BF906   ;73
  &diary_entry_0BF906   ;74
  &diary_entry_0BF906   ;75
  &diary_entry_0BF906   ;76
  &diary_entry_0BF906   ;77
  &diary_entry_0BF906   ;78
  &diary_entry_0BF906   ;79
  &diary_entry_0BF906   ;7A
  &diary_entry_0BF906   ;7B
  &diary_entry_0BF9C6   ;7C
  &diary_entry_0BF906   ;7D
  &diary_entry_0BF906   ;7E
  &diary_entry_0BF906   ;7F
  &diary_entry_0BF906   ;80
  &diary_entry_0BF906   ;81
  &diary_entry_0BF906   ;82
  &diary_entry_0BF906   ;83
  &diary_entry_0BF906   ;84
  &diary_entry_0BF9D3   ;85
  &diary_entry_0BF9D3   ;86
  &diary_entry_0BF906   ;87
  &diary_entry_0BF9D3   ;88
  &diary_entry_0BF906   ;89
  &diary_entry_0BF906   ;8A
  &diary_entry_0BF906   ;8B
  &diary_entry_0BF906   ;8C
  &diary_entry_0BF906   ;8D
  &diary_entry_0BF906   ;8E
  &diary_entry_0BF906   ;8F
  &diary_entry_0BF906   ;90
  &diary_entry_0BF906   ;91
  &diary_entry_0BF906   ;92
  &diary_entry_0BF906   ;93
  &diary_entry_0BF906   ;94
  &diary_entry_0BF906   ;95
  &diary_entry_0BF906   ;96
  &diary_entry_0BF906   ;97
  &diary_entry_0BF906   ;98
  &diary_entry_0BF9DE   ;99
  &diary_entry_0BF906   ;9A
  &diary_entry_0BF906   ;9B
  &diary_entry_0BF906   ;9C
  &diary_entry_0BF906   ;9D
  &diary_entry_0BF906   ;9E
  &diary_entry_0BF906   ;9F
  &diary_entry_0BF906   ;A0
  &diary_entry_0BF9ED   ;A1
  &diary_entry_0BF906   ;A2
  &diary_entry_0BF9ED   ;A3
  &diary_entry_0BF906   ;A4
  &diary_entry_0BF906   ;A5
  &diary_entry_0BF906   ;A6
  &diary_entry_0BF9ED   ;A7
  &diary_entry_0BF906   ;A8
  &diary_entry_0BF906   ;A9
  &diary_entry_0BF906   ;AA
  &diary_entry_0BF906   ;AB
  &diary_entry_0BF9FC   ;AC
  &diary_entry_0BF906   ;AD
  &diary_entry_0BF906   ;AE
  &diary_entry_0BF906   ;AF
  &diary_entry_0BF906   ;B0
  &diary_entry_0BF906   ;B1
  &diary_entry_0BF906   ;B2
  &diary_entry_0BF906   ;B3
  &diary_entry_0BF906   ;B4
  &diary_entry_0BF906   ;B5
  &diary_entry_0BFA12   ;B6
  &diary_entry_0BF906   ;B7
  &diary_entry_0BFA1D   ;B8
  &diary_entry_0BF906   ;B9
  &diary_entry_0BF906   ;BA
  &diary_entry_0BFA1D   ;BB
  &diary_entry_0BF906   ;BC
  &diary_entry_0BF906   ;BD
  &diary_entry_0BF906   ;BE
  &diary_entry_0BF906   ;BF
  &diary_entry_0BF906   ;C0
  &diary_entry_0BF906   ;C1
  &diary_entry_0BF906   ;C2
  &diary_entry_0BFA2B   ;C3
  &diary_entry_0BF906   ;C4
  &diary_entry_0BF906   ;C5
  &diary_entry_0BF906   ;C6
  &diary_entry_0BF906   ;C7
  &diary_entry_0BF906   ;C8
  &diary_entry_0BF906   ;C9
  &diary_entry_0BF906   ;CA
  &diary_entry_0BF906   ;CB
  &diary_entry_0BFA3B   ;CC
  &diary_entry_0BF906   ;CD
  &diary_entry_0BF906   ;CE
  &diary_entry_0BF906   ;CF
  &diary_entry_0BF906   ;D0
  &diary_entry_0BF906   ;D1
  &diary_entry_0BF906   ;D2
  &diary_entry_0BF906   ;D3
  &diary_entry_0BF906   ;D4
  &diary_entry_0BF906   ;D5
  &diary_entry_0BF906   ;D6
  &diary_entry_0BF906   ;D7
  &diary_entry_0BF906   ;D8
  &diary_entry_0BF906   ;D9
  &diary_entry_0BF906   ;DA
  &diary_entry_0BF906   ;DB
  &diary_entry_0BF906   ;DC
  &diary_entry_0BF906   ;DD
  &diary_entry_0BF906   ;DE
  &diary_entry_0BF906   ;DF
  &diary_entry_0BFA47   ;E0
  &diary_entry_0BF906   ;E1
  &diary_entry_0BF906   ;E2
  &diary_entry_0BFA47   ;E3
  &diary_entry_0BF906   ;E4
  &diary_entry_0BF906   ;E5
  &diary_entry_0BF906   ;E6
  &diary_entry_0BF906   ;E7
  &diary_entry_0BF906   ;E8
  &diary_entry_0BF906   ;E9
  &diary_entry_0BF906   ;EA
  &diary_entry_0BF906   ;EB
  &diary_entry_0BF906   ;EC
  &diary_entry_0BF906   ;ED
  &diary_entry_0BF906   ;EE
  &diary_entry_0BF906   ;EF
  &diary_entry_0BF906   ;F0
  &diary_entry_0BF906   ;F1
  &diary_entry_0BF906   ;F2
  &diary_entry_0BF906   ;F3
  &diary_entry_0BF906   ;F4
  &diary_entry_0BF906   ;F5
  &diary_entry_0BF906   ;F6
  &diary_entry_0BF906   ;F7
  &diary_entry_0BF906   ;F8
  &diary_entry_0BF906   ;F9
  &diary_entry_0BF906   ;FA
  &diary_entry_0BF906   ;FB
  &diary_entry_0BF906   ;FC
  &diary_entry_0BF906   ;FD
  &diary_entry_0BF906   ;FE
  &diary_entry_0BF906   ;FF
]

diary_entry_0BF906 [
  diary-entry < `Start from beginning`, #80000003 >
]

diary_entry_0BF91C [
  diary-entry < `South Cape`, #80002003 >
]

diary_entry_0BF927 [
  diary-entry < `Edward Prison`, #8000B002 >
]

diary_entry_0BF934 [
  diary-entry < `Underground Tunnel`, #8000B002 >
]

diary_entry_0BF94B [
  diary-entry < `Itory Village `, #4A003802 >
]

diary_entry_0BF95E [
  diary-entry < `Larai Cliff`, #BA000C02 >
]

diary_entry_0BF96A [
  diary-entry < `Incan ruins`, #BA000C02 >
]

diary_entry_0BF97A [
  diary-entry < `Freejia`, #DA015C02 >
]

diary_entry_0BF986 [
  diary-entry < `Diamond Mine`, #C002EC02 >
]

diary_entry_0BF991 [
  diary-entry < `Sky Garden`, #8A021C02 >
]

diary_entry_0BF9A0 [
  diary-entry < `Seaside Palace`, #F3021A00 >
]

diary_entry_0BF9AD [
  diary-entry < `Mu`, #B0020000 >
]

diary_entry_0BF9B4 [
  diary-entry < `Angel Village`, #F3020001 >
]

diary_entry_0BF9C6 [
  diary-entry < `Watermia`, #54022A01 >
]

diary_entry_0BF9D3 [
  diary-entry < `Great Wall`, #2802B000 >
]

diary_entry_0BF9DE [
  diary-entry < `City of Euro `, #5801C000 >
]

diary_entry_0BF9ED [
  diary-entry < `Mt. Temple`, #8E014600 >
]

diary_entry_0BF9FC [
  diary-entry < `Natives' Village `, #A8003401 >
]

diary_entry_0BFA12 [
  diary-entry < `Garden`, #B800E000 >
]

diary_entry_0BFA1D [
  diary-entry < `Ankor Wat`, #B800E000 >
]

diary_entry_0BFA2B [
  diary-entry < `Dao Village`, #1400A200 >
]

diary_entry_0BFA3B [
  diary-entry < `Pyramid`, #00003800 >
]

diary_entry_0BFA47 [
  diary-entry < `Babel Tower`, #84019001 >
]