; Entry index for scanline_band_hdma_thinker (Bank 01, 37 word pointers, $00-$24). The spawn-record parameter byte of the thinker is the index. Each pointer addresses one entry blob: buffer address (word, bank $7E), bank byte, config byte, record size, then records. The format and the decoded contents of every used entry are in the scanline_band_hdma_thinker block note.
; 
; The header bytes are NOT a BG mode / layer setting. Config bits 0-5 are the B-bus register index the HDMA channel writes, bit 6 multiplies the camera delta by 16 and bit 7 swaps the scroll sources.
; 
; Entries $09, $0C, $0D and $0F-$1A are bare $FFFF words (unused). Types $09 and $19 share one $FFFF word.
---------------------------------------------

?BANK 01

---------------------------------------------

; 37 entry pointers (word table, bank 01) indexed by the scanline_band_hdma_thinker spawn parameter. See the block note.

parallax_scroll_table [
  &parallax_type_00   ;00
  &parallax_type_01   ;01
  &parallax_type_02   ;02
  &parallax_type_03   ;03
  &parallax_type_04   ;04
  &parallax_type_05   ;05
  &parallax_type_06   ;06
  &parallax_type_07   ;07
  &parallax_type_08   ;08
  &parallax_empty_09_19   ;09
  &parallax_type_0A   ;0A
  &parallax_type_0B   ;0B
  &parallax_empty_0C   ;0C
  &parallax_empty_0D   ;0D
  &parallax_type_0E   ;0E
  &parallax_empty_0F   ;0F
  &parallax_empty_10   ;10
  &parallax_empty_11   ;11
  &parallax_empty_12   ;12
  &parallax_empty_13   ;13
  &parallax_empty_14   ;14
  &parallax_empty_15   ;15
  &parallax_empty_16   ;16
  &parallax_empty_17   ;17
  &parallax_empty_18   ;18
  &parallax_empty_09_19   ;19
  &parallax_empty_1A   ;1A
  &parallax_type_1B   ;1B
  &parallax_type_1C   ;1C
  &parallax_type_1D   ;1D
  &parallax_type_1E   ;1E
  &parallax_type_1F   ;1F
  &parallax_type_20   ;20
  &parallax_type_21   ;21
  &parallax_type_22   ;22
  &parallax_type_23   ;23
  &parallax_type_24   ;24
]

---------------------------------------------
; Table type $00: BG2HOFS: 7 scroll bands (5 proportional, 2 auto), buffer $7800. Used by scenes 0A. Bands (top to bottom): 127 lines x0.5, 128 lines auto +1/16, 80 lines x0.5, 32 lines x1, 144 lines auto +1/16, 75 lines x0.5, 1280 lines x1.

parallax_type_00 #00787E0F0881FF20070801000080FF220700000100B0FF240708010000E0FF26071001000070FF280700000100B5FF2A070801000000FB2C07100100000000

---------------------------------------------
; Table type $01: BG2HOFS: 4 scroll bands (1 proportional, 3 auto), buffer $7800. Used by scenes 15, 1A, 1C. Bands (top to bottom): 47 lines auto +32/16, 16 lines auto +24/16, 8 lines auto +16/16, 200 lines x0.875.

parallax_type_01 #00787E0F08D1FF200700002000F0FF220700001800F8FF24070000100038FF2E070E010000

---------------------------------------------
; Table type $03: BG2HOFS (delta x16): 11 scroll bands (0 proportional, 11 auto), buffer $8000, config bit 6 (camera delta x16). Used by scenes FD, FF. Bands (top to bottom): 6 lines auto +2/16, 8 lines auto +4/16, 8 lines auto +6/16, 8 lines auto +8/16, 10 lines auto +10/16, 14 lines auto +12/16, 16 lines auto +14/16, 16 lines auto +16/16, 24 lines auto +18/16, 48 lines auto +20/16, 48 lines auto +22/16.

parallax_type_03 #00807E4F08FAFF200700000200F8FF220700000400F8FF240700000600F8FF260700000800F6FF280700000A00F2FF2A0700000C00F0FF2C0700000E00F0FF2E0700001000E8FF300700001200D0FF320700001400D0FF3407000016000000

---------------------------------------------
; Table type $02: COLDATA: 96 constant bands, buffer $7C00. Used by scenes 02-08, 16-18, 2A, 31, 33-38, 3A-3C, 49, 56, 5E, 79-7E, 92-9D, AD, AE, C4-C9, DF, E0, E3. First bands (lines:value): 3:$F7, 3:$F6, 3:$F5, 3:$F4 ...

parallax_type_02 #007C7E3204FDFFF700FDFFF600FDFFF500FDFFF400FDFFF300FDFFF200FDFFF100FDFFF000FDFFEF00FDFFEE00FDFFED00FDFFEC00FDFFEB00FDFFEA00FDFFE900FDFFE800FDFFE700FDFFE600FDFFE500FDFFE400FDFFE300FDFFE200FDFFE10055FFE000EDFFF700FDFFF600FDFFF500FDFFF400FDFFF300FDFFF200FDFFF100FDFFF000FDFFEF00FDFFEE00FDFFED00FDFFEC00FDFFEB00FDFFEA00FDFFE900FDFFE800FDFFE700FDFFE600FDFFE500FDFFE400FDFFE300FDFFE200FDFFE10055FFE000EDFFF700FDFFF600FDFFF500FDFFF400FDFFF300FDFFF200FDFFF100FDFFF000FDFFEF00FDFFEE00FDFFED00FDFFEC00FDFFEB00FDFFEA00FDFFE900FDFFE800FDFFE700FDFFE600FDFFE500FDFFE400FDFFE300FDFFE200FDFFE10055FFE000EDFFF700FDFFF600FDFFF500FDFFF400FDFFF300FDFFF200FDFFF100FDFFF000FDFFEF00FDFFEE00FDFFED00FDFFEC00FDFFEB00FDFFEA00FDFFE900FDFFE800FDFFE700FDFFE600FDFFE500FDFFE400FDFFE300FDFFE200FDFFE100FFFFE0000000

---------------------------------------------
; Table type $04: COLDATA: 9 constant bands, buffer $7400. Not spawned by any scene thinker list. First bands (lines:value): 32:$E0, 16:$E1, 16:$E2, 16:$E3 ...

parallax_type_04 #00747E3204E0FFE000F0FFE100F0FFE200F0FFE300F0FFE400F0FFE500F0FFE600F0FFE70000FFE800

---------------------------------------------
; Table type $05: BG2HOFS (delta x16): 29 scroll bands (0 proportional, 29 auto), buffer $8000, config bit 6 (camera delta x16). Used by scenes 2B-2E. Bands (top to bottom): 78 lines auto -16/16, 1 lines auto -2/16, 1 lines auto -4/16, 1 lines auto -6/16, 2 lines auto -8/16, 2 lines auto -10/16, 2 lines auto -12/16, 3 lines auto -14/16, 3 lines auto -16/16, 3 lines auto -18/16, 4 lines auto -20/16, 4 lines auto -22/16, 4 lines auto -24/16, 6 lines auto -26/16, 6 lines auto -28/16, 6 lines auto -30/16, 8 lines auto -32/16, 8 lines auto -34/16, 8 lines auto -36/16, 10 lines auto -38/16, 10 lines auto -40/16, 10 lines auto -42/16, 12 lines auto -44/16, 12 lines auto -46/16, 14 lines auto -48/16, 14 lines auto -50/16, 16 lines auto -52/16, 16 lines auto -54/16, 1024 lines auto -56/16.

parallax_type_05 #00807E4F08B2FF20070000F0FFFFFF22070000FEFFFFFF24070000FCFFFFFF26070000FAFFFEFF28070000F8FFFEFF2A070000F6FFFEFF2C070000F4FFFDFF2E070000F2FFFDFF30070000F0FFFDFF32070000EEFFFCFF34070000ECFFFCFF36070000EAFFFCFF38070000E8FFFAFF3A070000E6FFFAFF3C070000E4FFFAFF3E070000E2FFF8FF40070000E0FFF8FF42070000DEFFF8FF44070000DCFFF6FF46070000DAFFF6FF48070000D8FFF6FF4A070000D6FFF4FF4C070000D4FFF4FF4E070000D2FFF2FF50070000D0FFF2FF52070000CEFFF0FF54070000CCFFF0FF56070000CAFF00FC58070000C8FF

---------------------------------------------
; Table type $06: COLDATA: 24 constant bands, buffer $7400. Used by scenes 2B, 2D, 2F. First bands (lines:value): 78:$0, 1:$F4, 1:$F3, 1:$F2 ...

parallax_type_06 #00747E3204B2FF0000FFFFF400FFFFF300FFFFF200FFFFF100FFFFF000FFFFEF00FFFFEE00FFFFED00FEFFEC00FEFFEB00FEFFEA00FEFFE900FEFFE800FEFFE700FCFFE600FCFFE500FCFFE400FCFFE300FAFFE200FAFFE100FFFFE00081FFE00000FC0000

---------------------------------------------
; Table type $07: CGADSUB: 2 constant bands, buffer $7800, config bit 7 (swapped scroll sources). Used by scenes 2D. Bands (lines:value): 76:$A1, 1024:$22.

parallax_type_07 #00787EB104B4FFA10000FC2200

---------------------------------------------
; Table type $08: COLDATA: 24 constant bands, buffer $7C00, config bit 7 (swapped scroll sources). Used by scenes 2D, 2E. First bands (lines:value): 3:$F7, 3:$F6, 3:$F5, 3:$F4 ...

parallax_type_08 #007C7EB204FDFFF700FDFFF600FDFFF500FDFFF400FDFFF300FDFFF200FDFFF100FDFFF000FDFFEF00FDFFEE00FDFFED00FDFFEC00FDFFEB00FDFFEA00FDFFE900FDFFE800FDFFE700FDFFE600FDFFE500FDFFE400FDFFE300FDFFE200FEFFE10000FEE000

---------------------------------------------
; Table type $0A: COLDATA: 17 constant bands, buffer $7400. Used by scenes 29. First bands (lines:value): 80:$E0, 5:$EF, 5:$EE, 5:$ED ...

parallax_type_0A #00747E3204B0FFE000FBFFEF00FBFFEE00FBFFED00FBFFEC00FBFFEB00FBFFEA00FBFFE900FBFFE800FBFFE700FBFFE600FBFFE500FBFFE400FBFFE300FBFFE200FBFFE10000FFE000

---------------------------------------------
; Table type $0B: BG1HOFS (delta x16): 7 scroll bands (0 proportional, 7 auto), buffer $7800, config bit 6 (camera delta x16). Used by scenes 1D. Bands (top to bottom): 798 lines auto +0/16, 176 lines auto +8/16, 64 lines auto +0/16, 128 lines auto +4/16, 160 lines auto +8/16, 192 lines auto +4/16, 256 lines auto +0/16.

parallax_type_0B #00787E4D08E2FC20070000000050FF220700000800C0FF24070000000080FF26070000040060FF28070000080040FF2A070000040000FF2C07000000000000

---------------------------------------------
; Table type $0E: BG2HOFS (delta x16): 2 scroll bands (0 proportional, 2 auto), buffer $8000, config bit 6 (camera delta x16). Used by scenes 2F. Bands (top to bottom): 78 lines auto +16/16, 1 lines auto +0/16.

parallax_type_0E #00807E4F08B2FF200700001000FFFF2207000000000000

---------------------------------------------
; Bare $FFFF word, the entry of table index $13. No scene thinker list spawns this type (see the block note).

parallax_empty_13 #FFFF

---------------------------------------------
; Bare $FFFF word, the entry of table index $14. Not spawned by any scene.

parallax_empty_14 #FFFF

---------------------------------------------
; Bare $FFFF word shared by table indices $09 and $19. Not spawned by any scene.

parallax_empty_09_19 #FFFF

---------------------------------------------
; Bare $FFFF word, the entry of table index $1A. Not spawned by any scene.

parallax_empty_1A #FFFF

---------------------------------------------
; Bare $FFFF word, the entry of table index $0C. Not spawned by any scene.

parallax_empty_0C #FFFF

---------------------------------------------
; Bare $FFFF word, the entry of table index $0D. Not spawned by any scene.

parallax_empty_0D #FFFF

---------------------------------------------
; Bare $FFFF word, the entry of table index $0F. Not spawned by any scene.

parallax_empty_0F #FFFF

---------------------------------------------
; Bare $FFFF word, the entry of table index $10. Not spawned by any scene.

parallax_empty_10 #FFFF

---------------------------------------------
; Bare $FFFF word, the entry of table index $11. Not spawned by any scene.

parallax_empty_11 #FFFF

---------------------------------------------
; Bare $FFFF word, the entry of table index $12. Not spawned by any scene.

parallax_empty_12 #FFFF

---------------------------------------------
; Bare $FFFF word, the entry of table index $15. Not spawned by any scene.

parallax_empty_15 #FFFF

---------------------------------------------
; Bare $FFFF word, the entry of table index $16. Not spawned by any scene.

parallax_empty_16 #FFFF

---------------------------------------------
; Bare $FFFF word, the entry of table index $17. Not spawned by any scene.

parallax_empty_17 #FFFF

---------------------------------------------
; Bare $FFFF word, the entry of table index $18. Not spawned by any scene.

parallax_empty_18 #FFFF

---------------------------------------------
; Table type $1B: CGDATA: 2 constant bands, buffer $7800. Used by scenes 5C. Bands (lines:value): 239:$4162, 238:$2906.

parallax_type_1B #00787E220411FF624112FF06290000

---------------------------------------------
; Table type $1C: CGADSUB: 2 constant bands, buffer $7400. Used by scenes 6B. Bands (lines:value): 256:$1, 768:$41.

parallax_type_1C #00747E310400FF010000FD41000000

---------------------------------------------
; Table type $1D: COLDATA: 23 constant bands, buffer $7400. Used by scenes 59. First bands (lines:value): 14:$F5, 1:$F4, 1:$F3, 1:$F2 ...

parallax_type_1D #00747E3204F2FFF500FFFFF400FFFFF300FFFFF200FFFFF100FFFFF000FFFFEF00FFFFEE00FFFFED00FEFFEC00FEFFEB00FEFFEA00FEFFE900FEFFE800FEFFE700FCFFE600FCFFE500FCFFE400FCFFE300FAFFE200FAFFE100FFFFE00000FC00000000

---------------------------------------------
; Table type $1E: BG2HOFS: 6 scroll bands (6 proportional, 0 auto), buffer $7800. Used by scenes 82, 83, 86-88, 8B. Bands (top to bottom): 96 lines x0.5, 160 lines x1, 80 lines x0.5, 176 lines x1, 80 lines x0.5, 2048 lines x1.

parallax_type_1E #00787E0F08A0FF20070801000060FF220710010000B0FF24070801000050FF260710010000B0FF28070801000000F82A07100100000000

---------------------------------------------
; Table type $1F: BG2HOFS: 2 scroll bands (2 proportional, 0 auto), buffer $7800. Used by scenes 84, 8A. Bands (top to bottom): 96 lines x0.5, 1024 lines x1.

parallax_type_1F #00787E0F08A0FF20070801000000FC2207100100000000

---------------------------------------------
; Table type $20: window: 1 rectangle(s), buffer $7000. Used by scenes C3. Rectangle x=320, width=63, y=367, height=48 (map pixels).

parallax_type_20 #00707E260940013F006F013000FFFF

---------------------------------------------
; Table type $21: BG2HOFS: 6 scroll bands (6 proportional, 0 auto), buffer $7800. Used by scenes 85. Bands (top to bottom): 128 lines x0.5, 160 lines x1, 80 lines x0.5, 176 lines x1, 80 lines x0.5, 2048 lines x1.

parallax_type_21 #00787E0F0880FF20070801000060FF220710010000B0FF24070801000050FF260710010000B0FF28070801000000F82A07100100000000

---------------------------------------------
; Table type $22: COLDATA: 22 constant bands, buffer $8400. Not spawned by any scene thinker list. First bands (lines:value): 14:$F5, 1:$F4, 1:$F3, 1:$F2 ...

parallax_type_22 #00847E3204F2FFF500FFFFF400FFFFF300FFFFF200FFFFF100FFFFF000FFFFEF00FFFFEE00FFFFED00FEFFEC00FEFFEB00FEFFEA00FEFFE900FEFFE800FEFFE700FCFFE600FCFFE500FCFFE400FCFFE300FAFFE200FAFFE100FFFFE0000000

---------------------------------------------
; Table type $23: BG2HOFS: 1 scroll bands (1 proportional, 0 auto), buffer $7800. Used by scenes DF-E1, E3. Bands (top to bottom): 2048 lines x1.

parallax_type_23 #00787E0F0800F82007100100000000

---------------------------------------------
; Table type $24: BG1HOFS: 33 scroll bands (0 proportional, 33 auto), buffer $7800. Used by scenes E5. Bands (top to bottom): 159 lines auto +0/16, 2 lines auto -1/16, 2 lines auto -2/16, 2 lines auto -3/16, 2 lines auto -4/16, 2 lines auto -5/16, 2 lines auto -6/16, 2 lines auto -7/16, 2 lines auto -8/16, 2 lines auto -9/16, 2 lines auto -10/16, 2 lines auto -11/16, 2 lines auto -12/16, 2 lines auto -13/16, 2 lines auto -14/16, 2 lines auto -15/16, 2 lines auto -16/16, 2 lines auto -17/16, 2 lines auto -18/16, 2 lines auto -19/16, 2 lines auto -20/16, 2 lines auto -21/16, 2 lines auto -22/16, 2 lines auto -23/16, 2 lines auto -24/16, 2 lines auto -25/16, 2 lines auto -26/16, 2 lines auto -27/16, 2 lines auto -28/16, 2 lines auto -29/16, 2 lines auto -30/16, 2 lines auto -31/16, 2 lines auto -32/16.

parallax_type_24 #00787E0D0861FF200700000000FEFF22070000FFFFFEFF24070000FEFFFEFF26070000FDFFFEFF28070000FCFFFEFF2A070000FBFFFEFF2C070000FAFFFEFF2E070000F9FFFEFF30070000F8FFFEFF32070000F7FFFEFF34070000F6FFFEFF36070000F5FFFEFF38070000F4FFFEFF3A070000F3FFFEFF3C070000F2FFFEFF3E070000F1FFFEFF40070000F0FFFEFF42070000EFFFFEFF44070000EEFFFEFF46070000EDFFFEFF48070000ECFFFEFF4A070000EBFFFEFF4C070000EAFFFEFF4E070000E9FFFEFF50070000E8FFFEFF52070000E7FFFEFF54070000E6FFFEFF56070000E5FFFEFF58070000E4FFFEFF5A070000E3FFFEFF5C070000E2FFFEFF5E070000E1FFFEFF60070000E0FF0000