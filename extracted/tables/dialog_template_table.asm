; Dialog template strings (Bank 01, 117397-117669): 22 word pointers ($00-$15) to 22 short dialog strings that the [TPL:nn] control code ($C2, DialogCmd_InsertTemplate) splices into the string being drawn. The handler doubles the operand, switches DBR to this bank, reads the pointer from dialog_template_table and draws the template with a recursive JSL DialogStringRenderer; afterwards it restores the caller's string pointer, the bank and the processor flags, and reloads the cursor from $0998, where the template's last character left it, so a [DLG] template positions the text that follows (the speaker templates only set colours, palette and sound, so they leave the cursor where it was). Most templates select the colours of a speaker.
; 
; === THE TAGS USED HERE (DialogStringRenderer; all numbers in the tags are hex) ===
; 
; - [SEP:ii,cccc] (DialogCmd_SetPaletteColor): writes the BGR555 word cccc to CGRAM buffer colour ii ($7F0A00 + ii x 2). The speaker templates write colours $11 and $12, which are entries 1 and 2 of 2bpp palette 4 ($10-$13).
; - [PAL:4] (DialogCmd_SetPalette): the following characters use tile palette 4 (palette bits 10-12 of the tile word). Dialog strings return to the normal palette with [PAL:0] at their end.
; - [SFX:ss] (DialogCmd_SetSfx): the per-character sound effect id kept in $0996 ([SFX:0] = silent). DialogCmd_OpenDialogueBox resets it to $10, the typing click.
; - [DLG:col,row] (DialogCmd_SetPosition) and [SIZ:w,h] (DialogCmd_OpenDialogueBox): put the cursor at a column and row, then open a box w columns wide and h rows high.
; 
; === THE 22 TEMPLATES (uses = occurrences of [TPL:nn] in the extracted strings, comment lines excluded) ===
; 
; | Id | Effect | Uses | Seen before |
; |----|--------|------|-------------|
; | $00 | Will colours, SFX $10 | 222 | Will: and narration (the default) |
; | $01 | Kara colours, SFX $1B | 180 | Kara:, Ann:, Vampiress:, Karen: |
; | $02 | Lilly colours, SFX $19 | 144 | Lilly:, Vampire:, Girl: |
; | $03 | Erik colours, SFX $19 | 82 | Erik:, Lola:, Rofsky:, Queen Edwina:, Ishtar: |
; | $04 | Lance colours, SFX $1C | 154 | Lance:, Bill:, Flute:, Elder:, Will's father:, Opponent: |
; | $05 | Seth colours, SFX $1A | 27 | Seth:, Sam:, Remus:, Imas: |
; | $06 | Neil colours, SFX $1A | 80 | Neil:, Man:, Spectator: |
; | $07 | pink / red colours, no SFX | 2 | two lines without a speaker name |
; | $08-$0B | box 13 columns x 1 / 2 / 3 / 4 rows at column 3, row 6 (upper box) | 9 / 28 / 303 / 122 | narration and cutscene text |
; | $0C-$0F | box 13 columns x 1 / 2 / 3 / 4 rows at column 3, row $11 (the lower default position) | 2 / 4 / 55 / 19 | |
; | $10 | the same box as $0F (a duplicate) | 6 | house descriptions |
; | $11 | 14 x 3 box at column 2, row $14 and the text 'Where do you go?' | 37 | the route menus ([TPL:11][SFX:0] Quit [N] ...) |
; | $12-$15 | the colours of $00, $01, $02 and $04 without the SFX tag (silent speaker colours) | 7 / 7 / 4 / 7 | Will:, Kara:, Will's mother:, Will's father: in the long cutscene strings |
; 
; The speaker names come from the 'Name:' that follows the tag in the strings. Not traced: which of the two colour words is the glyph and which the outline. The table is 44 bytes, the 22 strings 229 bytes.
---------------------------------------------

?BANK 01

---------------------------------------------

; 22 pointers to the template strings, indexed by the operand of [TPL:nn] ($C2). Layout of the ids: $00-$07 speaker colours, $08-$10 box shapes, $11 route prompt, $12-$15 silent speaker colours. See the block note for the table of effects and use counts.

dialog_template_table [
  &dialog_template_00_will   ;00
  &dialog_template_01_kara   ;01
  &dialog_template_02_lilly   ;02
  &dialog_template_03_erik   ;03
  &dialog_template_04_lance   ;04
  &dialog_template_05_seth   ;05
  &dialog_template_06_neil   ;06
  &dialog_template_07_pink   ;07
  &dialog_template_08_box_top_1   ;08
  &dialog_template_09_box_top_2   ;09
  &dialog_template_0A_box_top_3   ;0A
  &dialog_template_0B_box_top_4   ;0B
  &dialog_template_0C_box_low_1   ;0C
  &dialog_template_0D_box_low_2   ;0D
  &dialog_template_0E_box_low_3   ;0E
  &dialog_template_0F_box_low_4   ;0F
  &dialog_template_10_box_low_4_dup   ;10
  &dialog_template_11_where_do_you_go   ;11
  &dialog_template_12_will_silent   ;12
  &dialog_template_13_kara_silent   ;13
  &dialog_template_14_lilly_silent   ;14
  &dialog_template_15_lance_silent   ;15
]

---------------------------------------------
; Template $00 (222 uses): Will colours. Palette 4 colour 1 = $6FDF (R31 G30 B27, cream), colour 2 = $0B1E (R30 G24 B2, orange); per-character SFX $10 (the typing click); [PAL:4]. Also the default for narration.

dialog_template_00_will `[SEP:11,6FDF][SEP:12,B1E][SFX:10][PAL:4]`

---------------------------------------------
; Template $01 (180 uses): Kara colours. Colour 1 = $777F (R31 G27 B29, pale pink), colour 2 = $561E (R30 G16 B21, pink); SFX $1B.

dialog_template_01_kara `[SEP:11,777F][SEP:12,561E][SFX:1B][PAL:4]`

---------------------------------------------
; Template $02 (144 uses): Lilly colours. Colour 1 = $7FB7 (R23 G29 B31, pale blue), colour 2 = $79C2 (R2 G14 B30, blue); SFX $19.

dialog_template_02_lilly `[SEP:11,7FB7][SEP:12,79C2][SFX:19][PAL:4]`

---------------------------------------------
; Template $03 (82 uses): Erik colours (also Lola, Rofsky, Queen Edwina, Ishtar). Colour 1 = $5F7F (R31 G27 B23, pale orange), colour 2 = $09FF (R31 G15 B2, orange); SFX $19.

dialog_template_03_erik `[SEP:11,5F7F][SEP:12,9FF][SFX:19][PAL:4]`

---------------------------------------------
; Template $04 (154 uses): Lance colours (also Bill, Flute, Elder, Will's father, Opponent). Colour 1 = $73F7 (R23 G31 B28, pale green), colour 2 = $2322 (R2 G25 B8, green); SFX $1C.

dialog_template_04_lance `[SEP:11,73F7][SEP:12,2322][SFX:1C][PAL:4]`

---------------------------------------------
; Template $05 (27 uses): Seth, Sam, Remus and Imas. Colour 1 = $7F3D (R29 G25 B31, lavender), colour 2 = $7137 (R23 G9 B28, purple); SFX $1A.

dialog_template_05_seth `[SEP:11,7F3D][SEP:12,7137][SFX:1A][PAL:4]`

---------------------------------------------
; Template $06 (80 uses): Neil (also Man, Spectator). Colour 1 = $739C (R28 G28 B28, light grey), colour 2 = $4631 (R17 G17 B17, grey); SFX $1A.

dialog_template_06_neil `[SEP:11,739C][SEP:12,4631][SFX:1A][PAL:4]`

---------------------------------------------
; Template $07 (2 uses): pink / red colours without SFX. Colour 1 = $673F (R31 G25 B25), colour 2 = $24FF (R31 G7 B9). Both uses are lines without a speaker name ('I... I love... you...' and a slap).

dialog_template_07_pink `[SEP:11,673F][SEP:12,24FF][PAL:4]`

---------------------------------------------
; Template $08 (9 uses): position column 3, row 6, then a box 13 columns x 1 row.

dialog_template_08_box_top_1 `[DLG:3,6][SIZ:D,1]`

---------------------------------------------
; Template $09 (28 uses): column 3, row 6, box 13 x 2.

dialog_template_09_box_top_2 `[DLG:3,6][SIZ:D,2]`

---------------------------------------------
; Template $0A (303 uses, the most common): column 3, row 6, box 13 x 3.

dialog_template_0A_box_top_3 `[DLG:3,6][SIZ:D,3]`

---------------------------------------------
; Template $0B (122 uses): column 3, row 6, box 13 x 4.

dialog_template_0B_box_top_4 `[DLG:3,6][SIZ:D,4]`

---------------------------------------------
; Template $0C (2 uses): column 3, row $11 (17, the lower position of the default box), box 13 x 1.

dialog_template_0C_box_low_1 `[DLG:3,11][SIZ:D,1]`

---------------------------------------------
; Template $0D (4 uses): column 3, row $11, box 13 x 2.

dialog_template_0D_box_low_2 `[DLG:3,11][SIZ:D,2]`

---------------------------------------------
; Template $0E (55 uses): column 3, row $11, box 13 x 3.

dialog_template_0E_box_low_3 `[DLG:3,11][SIZ:D,3]`

---------------------------------------------
; Template $0F (19 uses): column 3, row $11, box 13 x 4 (the size of DialogCmd_OpenDefaultBox).

dialog_template_0F_box_low_4 `[DLG:3,11][SIZ:D,4]`

---------------------------------------------
; Template $10 (6 uses): identical to $0F (column 3, row $11, box 13 x 4). Seen in house description strings ('This is my house.', 'This is Lance's house.').

dialog_template_10_box_low_4_dup `[DLG:3,11][SIZ:D,4]`

---------------------------------------------
; Template $11 (37 uses): position column 2, row $14 (20), box 14 columns x 3 rows, the text 'Where do you go?' and a newline. The route menus ([TPL:11][SFX:0] Quit [N] ...) put the choices after it.

dialog_template_11_where_do_you_go `[DLG:2,14][SIZ:E,3]Where do you go?[N]`

---------------------------------------------
; Template $12 (7 uses): the colours of $00 (Will) without SFX; the long cutscene strings use it with an explicit [SFX:0].

dialog_template_12_will_silent `[SEP:11,6FDF][SEP:12,B1E][PAL:4]`

---------------------------------------------
; Template $13 (7 uses): the colours of $01 (Kara) without SFX.

dialog_template_13_kara_silent `[SEP:11,777F][SEP:12,561E][PAL:4]`

---------------------------------------------
; Template $14 (4 uses): the colours of $02 (blue) without SFX; seen before 'Will's mother:' and one 'Strange Voice:'.

dialog_template_14_lilly_silent `[SEP:11,7FB7][SEP:12,79C2][PAL:4]`

---------------------------------------------
; Template $15 (7 uses): the colours of $04 (green) without SFX; seen before 'Will's father:'.

dialog_template_15_lance_silent `[SEP:11,73F7][SEP:12,2322][PAL:4]`