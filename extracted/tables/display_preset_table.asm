; PPU display presets (Bank 01, 98304-98868): 47 word pointers ($00-$2E) and the 47 ten-byte records they point to. A scene script picks one with scene command $02 (SceneCmd_ConfigDisplay, scene_script); the old note said 'selected by scene metadata', which is not what the code does. SceneCmd_ConfigDisplay documents what each byte does; this note adds what the 47 records contain.
; 
; Record (in the order they are applied): +0 TM and TMW (main-screen layers), +1 TS and TSW (sub-screen layers), +2 CGWSEL, +3 CGADSUB, +4 layer flags, +5 layerPriorityFlag, +6 BGMODE, +7 scroll/HUD flags, +8 and +9 unused.
; 
; | Byte | Values in the 47 records |
; |------|--------------------------|
; | +0 | $17 x34 (BG1+BG2+BG3+OBJ), $15 x10 (BG1+BG3+OBJ), $11 x2 (BG1+OBJ), $13 x1 (BG1+BG2+OBJ) |
; | +1 | $00 x22, $02 x8, $12 x6, $11 x4, $03 x3, $01 x2, $16 x2 |
; | +2 | $80 x23, $82 x13, $00 x4, $02 x4, $12 x3 (bit 1 = sub screen is the math addend) |
; | +3 | 18 distinct values; bits 0-3 BG1-BG4, bit 4 OBJ, bit 5 backdrop, bit 6 half, bit 7 subtract. Most common: $A1 x6, $41 x5, $A3 x5, $00 x5 |
; | +4 | $E4 x13, $A4 x12, $24 x10, $64 x6, $14 x2, $A5, $A6, $65, $66 x1 each: 21 records have bit 6 set (visible height $100), 26 have it clear ($E0); 20 have bit 7 clear |
; | +5 | $05 x25, $85 x12, $01 x5, $00 x2, $80, $81, $84 x1 each |
; | +6 | $09 x45 (BG mode 1 with BG3 priority), $07 x2 (mode 7: presets $19 and $2D) |
; | +7 | $00 x35, $04 x6, $01 x2, $10 x2, $1C x2 (the two mode-7 presets); bit 7 never set, so no preset disables the HUD |
; | +8, +9 | $00 in all 47 records (closes OQ-5 of the first audit pass) |
; 
; The pointers run in order: record n is at $01805E + 10 x n, so the table is 94 bytes and the records 470 bytes. Which scenes use which preset was not traced (OQ-I068-3).
---------------------------------------------

?BANK 01

---------------------------------------------

; 47 word pointers ($00-$2E) to the 10-byte records below, in order (record n at $01805E + 10 x n). The operand of scene command $02 indexes this table.

display_preset_table [
  &display_preset_00   ;00
  &display_preset_01   ;01
  &display_preset_02   ;02
  &display_preset_03   ;03
  &display_preset_04   ;04
  &display_preset_05   ;05
  &display_preset_06   ;06
  &display_preset_07   ;07
  &display_preset_08   ;08
  &display_preset_09   ;09
  &display_preset_0A   ;0A
  &display_preset_0B   ;0B
  &display_preset_0C   ;0C
  &display_preset_0D   ;0D
  &display_preset_0E   ;0E
  &display_preset_0F   ;0F
  &display_preset_10   ;10
  &display_preset_11   ;11
  &display_preset_12   ;12
  &display_preset_13   ;13
  &display_preset_14   ;14
  &display_preset_15   ;15
  &display_preset_16   ;16
  &display_preset_17   ;17
  &display_preset_18   ;18
  &display_preset_19_mode7   ;19
  &display_preset_1A   ;1A
  &display_preset_1B   ;1B
  &display_preset_1C   ;1C
  &display_preset_1D   ;1D
  &display_preset_1E   ;1E
  &display_preset_1F   ;1F
  &display_preset_20   ;20
  &display_preset_21   ;21
  &display_preset_22   ;22
  &display_preset_23   ;23
  &display_preset_24   ;24
  &display_preset_25   ;25
  &display_preset_26   ;26
  &display_preset_27   ;27
  &display_preset_28   ;28
  &display_preset_29   ;29
  &display_preset_2A   ;2A
  &display_preset_2B   ;2B
  &display_preset_2C   ;2C
  &display_preset_2D_mode7   ;2D
  &display_preset_2E   ;2E
]

display_preset_00 [
  display-preset < #17, #00, #80, #00, #24, #85, #09, #00, #00, #00 >
]

display_preset_01 [
  display-preset < #17, #00, #80, #A3, #64, #05, #09, #00, #00, #00 >
]

display_preset_02 [
  display-preset < #17, #00, #80, #A3, #E4, #01, #09, #00, #00, #00 >
]

display_preset_03 [
  display-preset < #17, #02, #82, #01, #24, #05, #09, #00, #00, #00 >
]

display_preset_04 [
  display-preset < #17, #03, #82, #00, #64, #05, #09, #00, #00, #00 >
]

display_preset_05 [
  display-preset < #15, #00, #80, #A1, #64, #05, #09, #00, #00, #00 >
]

display_preset_06 [
  display-preset < #17, #00, #80, #83, #24, #85, #09, #01, #00, #00 >
]

display_preset_07 [
  display-preset < #17, #00, #80, #A0, #65, #05, #09, #00, #00, #00 >
]

display_preset_08 [
  display-preset < #15, #00, #80, #A1, #24, #05, #09, #00, #00, #00 >
]

display_preset_09 [
  display-preset < #15, #00, #80, #A1, #A4, #05, #09, #00, #00, #00 >
]

display_preset_0A [
  display-preset < #17, #00, #80, #A2, #24, #05, #09, #00, #00, #00 >
]

display_preset_0B [
  display-preset < #15, #00, #80, #01, #64, #05, #09, #00, #00, #00 >
]

display_preset_0C [
  display-preset < #15, #02, #02, #31, #64, #05, #09, #04, #00, #00 >
]

display_preset_0D [
  display-preset < #17, #00, #80, #22, #E4, #05, #09, #00, #00, #00 >
]

display_preset_0E [
  display-preset < #17, #16, #82, #01, #66, #84, #09, #04, #00, #00 >
]

display_preset_0F [
  display-preset < #17, #12, #82, #41, #E4, #85, #09, #00, #00, #00 >
]

display_preset_10 [
  display-preset < #17, #02, #00, #00, #A4, #05, #09, #00, #00, #00 >
]

display_preset_11 [
  display-preset < #17, #00, #80, #21, #24, #85, #09, #00, #00, #00 >
]

display_preset_12 [
  display-preset < #17, #02, #00, #00, #A4, #05, #09, #00, #00, #00 >
]

display_preset_13 [
  display-preset < #17, #00, #80, #83, #24, #01, #09, #04, #00, #00 >
]

display_preset_14 [
  display-preset < #17, #00, #80, #81, #A4, #85, #09, #01, #00, #00 >
]

display_preset_15 [
  display-preset < #17, #00, #80, #A2, #E4, #05, #09, #00, #00, #00 >
]

display_preset_16 [
  display-preset < #17, #12, #82, #41, #E4, #85, #09, #00, #00, #00 >
]

display_preset_17 [
  display-preset < #17, #11, #00, #00, #A5, #85, #09, #00, #00, #00 >
]

display_preset_18 [
  display-preset < #15, #00, #80, #A1, #E4, #05, #09, #00, #00, #00 >
]

---------------------------------------------
; Preset $19: mode 7 (BGMODE $07). TM $15 (BG1+BG3+OBJ), CGWSEL $80, CGADSUB $A1, scroll flags $1C.

display_preset_19_mode7 [
  display-preset < #15, #00, #80, #A1, #14, #00, #07, #1C, #00, #00 >
]

display_preset_1A [
  display-preset < #17, #12, #82, #41, #A4, #85, #09, #00, #00, #00 >
]

display_preset_1B [
  display-preset < #15, #12, #82, #B1, #E4, #05, #09, #00, #00, #00 >
]

display_preset_1C [
  display-preset < #17, #12, #82, #01, #E4, #85, #09, #00, #00, #00 >
]

display_preset_1D [
  display-preset < #17, #02, #12, #21, #E4, #01, #09, #00, #00, #00 >
]

display_preset_1E [
  display-preset < #17, #11, #02, #72, #E4, #05, #09, #00, #00, #00 >
]

display_preset_1F [
  display-preset < #17, #00, #80, #A3, #E4, #05, #09, #00, #00, #00 >
]

display_preset_20 [
  display-preset < #17, #02, #12, #21, #A4, #05, #09, #00, #00, #00 >
]

display_preset_21 [
  display-preset < #17, #11, #02, #72, #A4, #01, #09, #00, #00, #00 >
]

display_preset_22 [
  display-preset < #15, #16, #02, #61, #A4, #85, #09, #04, #00, #00 >
]

display_preset_23 [
  display-preset < #17, #12, #82, #41, #A4, #85, #09, #04, #00, #00 >
]

display_preset_24 [
  display-preset < #15, #00, #80, #21, #24, #05, #09, #00, #00, #00 >
]

display_preset_25 [
  display-preset < #17, #00, #80, #03, #E4, #80, #09, #00, #00, #00 >
]

display_preset_26 [
  display-preset < #17, #00, #80, #A3, #A6, #85, #09, #00, #00, #00 >
]

display_preset_27 [
  display-preset < #17, #03, #82, #44, #E4, #81, #09, #00, #00, #00 >
]

display_preset_28 [
  display-preset < #17, #00, #80, #A3, #A4, #05, #09, #00, #00, #00 >
]

display_preset_29 [
  display-preset < #17, #02, #12, #61, #24, #05, #09, #00, #00, #00 >
]

display_preset_2A [
  display-preset < #13, #03, #80, #A1, #64, #05, #09, #10, #00, #00 >
]

display_preset_2B [
  display-preset < #11, #01, #82, #10, #24, #05, #09, #10, #00, #00 >
]

display_preset_2C [
  display-preset < #17, #02, #82, #41, #A4, #05, #09, #00, #00, #00 >
]

---------------------------------------------
; Preset $2D: mode 7 (BGMODE $07). TM $11 (BG1+OBJ), TS $01, CGWSEL $82, CGADSUB $10, scroll flags $1C.

display_preset_2D_mode7 [
  display-preset < #11, #01, #82, #10, #14, #00, #07, #1C, #00, #00 >
]

display_preset_2E [
  display-preset < #17, #11, #00, #83, #A4, #01, #09, #04, #00, #00 >
]