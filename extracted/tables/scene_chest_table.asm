; Per-scene barrier/chest placement data. Scene-indexed pointer table to variable-length records of tile coordinates, content IDs, and event flags. Controls treasure chest positions and event-blocking barrier tiles.
---------------------------------------------

?BANK 01

---------------------------------------------

; Per-scene table of barrier tile and treasure chest placement data. Indexed by scene ID, each entry points to a variable-length list of 4-byte records: X tile, Y tile, content (item ID or tile index), flags (event flag ID, bit 7 = end sentinel). Most scenes point to $FF (no barriers/chests). Used by PlaceOpenedChestTiles (blocking tiles tied to event flags), HandleChestInteraction (treasure by player position), and radar_map_screen (transition markers on world map).

scene_chest_table [
  &chest_entry_01AFA6   ;00
  &chest_entry_01AFA6   ;01
  &chest_entry_01AFA6   ;02
  &chest_entry_01AFA6   ;03
  &chest_entry_01AFA6   ;04
  &chest_entry_01AFA6   ;05
  &chest_entry_01AFA6   ;06
  &chest_entry_01AFA6   ;07
  &chest_entry_01AFA6   ;08
  &chest_entry_01AFA6   ;09
  &chest_entry_01AFA6   ;0A
  &chest_entry_01AFA6   ;0B
  &chest_entry_01AFA6   ;0C
  &chest_entry_01AFA6   ;0D
  &chest_entry_01AFA7   ;0E
  &chest_entry_01AFA6   ;0F
  &chest_entry_01AFAC   ;10
  &chest_entry_01AFA6   ;11
  &chest_entry_01AFB1   ;12
  &chest_entry_01AFA6   ;13
  &chest_entry_01AFA6   ;14
  &chest_entry_01AFA6   ;15
  &chest_entry_01AFA6   ;16
  &chest_entry_01AFA6   ;17
  &chest_entry_01AFA6   ;18
  &chest_entry_01AFA6   ;19
  &chest_entry_01AFA6   ;1A
  &chest_entry_01AFA6   ;1B
  &chest_entry_01AFA6   ;1C
  &chest_entry_01AFB6   ;1D
  &chest_entry_01AFA6   ;1E
  &chest_entry_01AFA6   ;1F
  &chest_entry_01AFA6   ;20
  &chest_entry_01AFBB   ;21
  &chest_entry_01AFA6   ;22
  &chest_entry_01AFA6   ;23
  &chest_entry_01AFA6   ;24
  &chest_entry_01AFA6   ;25
  &chest_entry_01AFC0   ;26
  &chest_entry_01AFA6   ;27
  &chest_entry_01AFA6   ;28
  &chest_entry_01AFA6   ;29
  &chest_entry_01AFA6   ;2A
  &chest_entry_01AFA6   ;2B
  &chest_entry_01AFA6   ;2C
  &chest_entry_01AFA6   ;2D
  &chest_entry_01AFC9   ;2E
  &chest_entry_01AFA6   ;2F
  &chest_entry_01AFA6   ;30
  &chest_entry_01AFA6   ;31
  &chest_entry_01AFA6   ;32
  &chest_entry_01AFA6   ;33
  &chest_entry_01AFA6   ;34
  &chest_entry_01AFA6   ;35
  &chest_entry_01AFA6   ;36
  &chest_entry_01AFA6   ;37
  &chest_entry_01AFA6   ;38
  &chest_entry_01AFA6   ;39
  &chest_entry_01AFA6   ;3A
  &chest_entry_01AFA6   ;3B
  &chest_entry_01AFA6   ;3C
  &chest_entry_01AFA6   ;3D
  &chest_entry_01AFA6   ;3E
  &chest_entry_01AFCE   ;3F
  &chest_entry_01AFA6   ;40
  &chest_entry_01AFA6   ;41
  &chest_entry_01AFA6   ;42
  &chest_entry_01AFA6   ;43
  &chest_entry_01AFA6   ;44
  &chest_entry_01AFA6   ;45
  &chest_entry_01AFA6   ;46
  &chest_entry_01AFA6   ;47
  &chest_entry_01AFA6   ;48
  &chest_entry_01AFA6   ;49
  &chest_entry_01AFA6   ;4A
  &chest_entry_01AFA6   ;4B
  &chest_entry_01AFA6   ;4C
  &chest_entry_01AFD3   ;4D
  &chest_entry_01AFA6   ;4E
  &chest_entry_01AFA6   ;4F
  &chest_entry_01AFE0   ;50
  &chest_entry_01AFE5   ;51
  &chest_entry_01AFEA   ;52
  &chest_entry_01AFEF   ;53
  &chest_entry_01AFA6   ;54
  &chest_entry_01AFA6   ;55
  &chest_entry_01AFA6   ;56
  &chest_entry_01AFA6   ;57
  &chest_entry_01AFA6   ;58
  &chest_entry_01AFA6   ;59
  &chest_entry_01AFF8   ;5A
  &chest_entry_01AFFD   ;5B
  &chest_entry_01B002   ;5C
  &chest_entry_01AFA6   ;5D
  &chest_entry_01AFA6   ;5E
  &chest_entry_01B007   ;5F
  &chest_entry_01B010   ;60
  &chest_entry_01B019   ;61
  &chest_entry_01AFA6   ;62
  &chest_entry_01AFA6   ;63
  &chest_entry_01AFA6   ;64
  &chest_entry_01AFA6   ;65
  &chest_entry_01AFA6   ;66
  &chest_entry_01AFA6   ;67
  &chest_entry_01AFA6   ;68
  &chest_entry_01AFA6   ;69
  &chest_entry_01AFA6   ;6A
  &chest_entry_01AFA6   ;6B
  &chest_entry_01AFA6   ;6C
  &chest_entry_01AFA6   ;6D
  &chest_entry_01AFA6   ;6E
  &chest_entry_01AFA6   ;6F
  &chest_entry_01B01E   ;70
  &chest_entry_01AFA6   ;71
  &chest_entry_01AFA6   ;72
  &chest_entry_01AFA6   ;73
  &chest_entry_01B023   ;74
  &chest_entry_01B028   ;75
  &chest_entry_01AFA6   ;76
  &chest_entry_01AFA6   ;77
  &chest_entry_01AFA6   ;78
  &chest_entry_01AFA6   ;79
  &chest_entry_01AFA6   ;7A
  &chest_entry_01AFA6   ;7B
  &chest_entry_01AFA6   ;7C
  &chest_entry_01AFA6   ;7D
  &chest_entry_01AFA6   ;7E
  &chest_entry_01AFA6   ;7F
  &chest_entry_01AFA6   ;80
  &chest_entry_01AFA6   ;81
  &chest_entry_01AFA6   ;82
  &chest_entry_01B031   ;83
  &chest_entry_01AFA6   ;84
  &chest_entry_01B036   ;85
  &chest_entry_01AFA6   ;86
  &chest_entry_01AFA6   ;87
  &chest_entry_01AFA6   ;88
  &chest_entry_01AFA6   ;89
  &chest_entry_01AFA6   ;8A
  &chest_entry_01AFA6   ;8B
  &chest_entry_01AFA6   ;8C
  &chest_entry_01AFA6   ;8D
  &chest_entry_01AFA6   ;8E
  &chest_entry_01AFA6   ;8F
  &chest_entry_01AFA6   ;90
  &chest_entry_01AFA6   ;91
  &chest_entry_01AFA6   ;92
  &chest_entry_01AFA6   ;93
  &chest_entry_01AFA6   ;94
  &chest_entry_01AFA6   ;95
  &chest_entry_01AFA6   ;96
  &chest_entry_01AFA6   ;97
  &chest_entry_01AFA6   ;98
  &chest_entry_01AFA6   ;99
  &chest_entry_01AFA6   ;9A
  &chest_entry_01AFA6   ;9B
  &chest_entry_01AFA6   ;9C
  &chest_entry_01AFA6   ;9D
  &chest_entry_01AFA6   ;9E
  &chest_entry_01AFA6   ;9F
  &chest_entry_01AFA6   ;A0
  &chest_entry_01AFA6   ;A1
  &chest_entry_01B03B   ;A2
  &chest_entry_01AFA6   ;A3
  &chest_entry_01B040   ;A4
  &chest_entry_01AFA6   ;A5
  &chest_entry_01B045   ;A6
  &chest_entry_01B04A   ;A7
  &chest_entry_01AFA6   ;A8
  &chest_entry_01B04F   ;A9
  &chest_entry_01AFA6   ;AA
  &chest_entry_01AFA6   ;AB
  &chest_entry_01AFA6   ;AC
  &chest_entry_01AFA6   ;AD
  &chest_entry_01AFA6   ;AE
  &chest_entry_01AFA6   ;AF
  &chest_entry_01AFA6   ;B0
  &chest_entry_01B054   ;B1
  &chest_entry_01AFA6   ;B2
  &chest_entry_01AFA6   ;B3
  &chest_entry_01AFA6   ;B4
  &chest_entry_01B059   ;B5
  &chest_entry_01AFA6   ;B6
  &chest_entry_01AFA6   ;B7
  &chest_entry_01AFA6   ;B8
  &chest_entry_01B05E   ;B9
  &chest_entry_01AFA6   ;BA
  &chest_entry_01B063   ;BB
  &chest_entry_01AFA6   ;BC
  &chest_entry_01AFA6   ;BD
  &chest_entry_01B068   ;BE
  &chest_entry_01AFA6   ;BF
  &chest_entry_01AFA6   ;C0
  &chest_entry_01AFA6   ;C1
  &chest_entry_01AFA6   ;C2
  &chest_entry_01AFA6   ;C3
  &chest_entry_01AFA6   ;C4
  &chest_entry_01AFA6   ;C5
  &chest_entry_01AFA6   ;C6
  &chest_entry_01AFA6   ;C7
  &chest_entry_01AFA6   ;C8
  &chest_entry_01AFA6   ;C9
  &chest_entry_01AFA6   ;CA
  &chest_entry_01AFA6   ;CB
  &chest_entry_01AFA6   ;CC
  &chest_entry_01AFA6   ;CD
  &chest_entry_01AFA6   ;CE
  &chest_entry_01AFA6   ;CF
  &chest_entry_01AFA6   ;D0
  &chest_entry_01B06D   ;D1
  &chest_entry_01AFA6   ;D2
  &chest_entry_01AFA6   ;D3
  &chest_entry_01B072   ;D4
  &chest_entry_01AFA6   ;D5
  &chest_entry_01B077   ;D6
  &chest_entry_01AFA6   ;D7
  &chest_entry_01AFA6   ;D8
  &chest_entry_01B07C   ;D9
  &chest_entry_01AFA6   ;DA
  &chest_entry_01AFA6   ;DB
  &chest_entry_01AFA6   ;DC
  &chest_entry_01AFA6   ;DD
  &chest_entry_01AFA6   ;DE
  &chest_entry_01AFA6   ;DF
  &chest_entry_01AFA6   ;E0
  &chest_entry_01AFA6   ;E1
  &chest_entry_01AFA6   ;E2
  &chest_entry_01AFA6   ;E3
  &chest_entry_01AFA6   ;E4
  &chest_entry_01AFA6   ;E5
  &chest_entry_01AFA6   ;E6
  &chest_entry_01AFA6   ;E7
  &chest_entry_01AFA6   ;E8
  &chest_entry_01B081   ;E9
  &chest_entry_01AFA6   ;EA
  &chest_entry_01AFA6   ;EB
  &chest_entry_01AFA6   ;EC
  &chest_entry_01AFA6   ;ED
  &chest_entry_01AFA6   ;EE
  &chest_entry_01AFA6   ;EF
  &chest_entry_01AFA6   ;F0
  &chest_entry_01AFA6   ;F1
  &chest_entry_01AFA6   ;F2
  &chest_entry_01AFA6   ;F3
  &chest_entry_01AFA6   ;F4
  &chest_entry_01AFA6   ;F5
  &chest_entry_01AFA6   ;F6
  &chest_entry_01AFA6   ;F7
  &chest_entry_01AFA6   ;F8
  &chest_entry_01AFA6   ;F9
  &chest_entry_01AFA6   ;FA
  &chest_entry_01AFA6   ;FB
  &chest_entry_01AFA6   ;FC
  &chest_entry_01AFA6   ;FD
  &chest_entry_01AFA6   ;FE
]

chest_entry_01AFA6 [
]

chest_entry_01AFA7 [
  chest-entry < #04, #1A, #06, #01 >
]

chest_entry_01AFAC [
  chest-entry < #07, #08, #01, #02 >
]

chest_entry_01AFB1 [
  chest-entry < #11, #1E, #01, #03 >
]

chest_entry_01AFB6 [
  chest-entry < #06, #06, #07, #84 >
]

chest_entry_01AFBB [
  chest-entry < #02, #17, #06, #05 >
]

chest_entry_01AFC0 [
  chest-entry < #10, #1B, #06, #06 >   ;00
  chest-entry < #08, #1F, #01, #07 >   ;01
]

chest_entry_01AFC9 [
  chest-entry < #25, #19, #38, #88 >
]

chest_entry_01AFCE [
  chest-entry < #38, #27, #06, #09 >
]

chest_entry_01AFD3 [
  chest-entry < #39, #31, #0E, #8A >   ;00
  chest-entry < #09, #33, #06, #0B >   ;01
  chest-entry < #34, #05, #01, #0C >   ;02
]

chest_entry_01AFE0 [
  chest-entry < #37, #06, #0E, #8D >
]

chest_entry_01AFE5 [
  chest-entry < #03, #2F, #0E, #8E >
]

chest_entry_01AFEA [
  chest-entry < #07, #08, #01, #0F >
]

chest_entry_01AFEF [
  chest-entry < #35, #32, #06, #10 >   ;00
  chest-entry < #31, #36, #0E, #91 >   ;01
]

chest_entry_01AFF8 [
  chest-entry < #37, #1A, #01, #12 >
]

chest_entry_01AFFD [
  chest-entry < #07, #07, #01, #13 >
]

chest_entry_01B002 [
  chest-entry < #09, #17, #01, #14 >
]

chest_entry_01B007 [
  chest-entry < #20, #19, #13, #95 >   ;00
  chest-entry < #2F, #27, #01, #16 >   ;01
]

chest_entry_01B010 [
  chest-entry < #1E, #18, #00, #2E >   ;00
  chest-entry < #2D, #1C, #13, #97 >   ;01
]

chest_entry_01B019 [
  chest-entry < #0A, #33, #00, #18 >
]

chest_entry_01B01E [
  chest-entry < #07, #28, #01, #19 >
]

chest_entry_01B023 [
  chest-entry < #27, #08, #14, #9A >
]

chest_entry_01B028 [
  chest-entry < #47, #08, #06, #1B >   ;00
  chest-entry < #57, #08, #01, #1C >   ;01
]

chest_entry_01B031 [
  chest-entry < #1A, #59, #01, #1D >
]

chest_entry_01B036 [
  chest-entry < #05, #1A, #06, #1E >
]

chest_entry_01B03B [
  chest-entry < #18, #36, #01, #1F >
]

chest_entry_01B040 [
  chest-entry < #12, #0B, #1A, #A0 >
]

chest_entry_01B045 [
  chest-entry < #05, #08, #1A, #A1 >
]

chest_entry_01B04A [
  chest-entry < #22, #10, #1A, #A2 >
]

chest_entry_01B04F [
  chest-entry < #0E, #05, #19, #A3 >
]

chest_entry_01B054 [
  chest-entry < #67, #05, #01, #24 >
]

chest_entry_01B059 [
  chest-entry < #07, #4E, #06, #25 >
]

chest_entry_01B05E [
  chest-entry < #07, #06, #01, #26 >
]

chest_entry_01B063 [
  chest-entry < #11, #20, #01, #27 >
]

chest_entry_01B068 [
  chest-entry < #05, #16, #01, #28 >
]

chest_entry_01B06D [
  chest-entry < #37, #59, #01, #29 >
]

chest_entry_01B072 [
  chest-entry < #46, #49, #01, #2A >
]

chest_entry_01B077 [
  chest-entry < #47, #09, #01, #2B >
]

chest_entry_01B07C [
  chest-entry < #75, #29, #01, #2C >
]

chest_entry_01B081 [
  chest-entry < #37, #16, #06, #2D >
]