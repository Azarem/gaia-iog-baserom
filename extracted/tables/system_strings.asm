; The console-string text of the menus (Bank 01, 121304-125711 = $01:D9D8): the boot and title strings, ten pointer tables and the loose strings between them, all drawn by ConsoleStringRenderer. It is read in two ways: RunBg3Script runs a loose string directly (a BG3 script), and the text tag [TBL:@table,addr] picks a table entry with a 16-bit RAM variable as the index (item_name_table by $0AC6, the other tables by $0AE8, character_name_table by $0AD4 and misc_ui_strings by $0B26). Text tags: [N] = line break of one tilemap row, [DBL] = two rows, [LU:n] = shared word n (shared_word_table), [POS:x,y] = cursor, [PAL:n] = palette, [RCC:w,h] = clear (w+1) x (h+1) tiles. The old note called the block 'all game UI text organized into 10 sub-tables'; the dialogue lines are DialogString data elsewhere, and seven of the ten part notes were wrong (see below).
; 
; === TABLES (the index variable decides what the number means) ===
; 
; | Part | Bytes | Entries | Index | Content |
; |------|-------|---------|-------|---------|
; | boot_title_strings | 121304-121535 | 3 loose strings | | The region lockout warning (sFB_boot_logo, @system_strings.boot_title_strings), then 'PUSH START BUTTON' and the copyright text (sFC_title_intro) |
; | item_name_table | 121535-122398 | 64 | item ID ($0AC6 = equipped item) | The name with [N] line breaks for the two-row name areas (status screen: [TBL:@item_name_table,AC6] at (8C,3)). $00 empty, $29-$37 blank (8 spaces), $38-$3F 'Mystic Statue' |
; | item_name_line_table | 122398-123178 | 64 | item ID ($0AE8) | The same names on ONE line, printed as the first part of the item description box: [TBL item_name_line_table][TBL item_description_table] (E9D0) and 'name, Discard?, No, Yes' (E9E2). $29-$37 blank, $38-$3F 'Mystery Doll' |
; | non_discardable_item_bits | 123178-123186 | 8 bytes | item ID | Bit table: byte = ID >> 3, bit = BitMaskTable[ID & 7] (bit 0 = lowest ID of the byte); CheckItemDiscardable (inventory_menu) |
; | item_description_table | 123186-124396 | 41 ($00-$28) | item ID ($0AE8) | Description text of two to four rows, each starting with [DBL] so it continues under the name; $00 = 'Nothing'. Items $29-$3F have no entry |
; | ability_menu_table | 124396-124509 | 12 | ability index ($0AE8) | One-line ability name, header of the ability description box (EAB4) |
; | ability_name_table | 124509-124636 | 12 | ability index ($0AE8) | The ability name with [N] line breaks, printed on the status rows (EA49, EA56, EA63) |
; | ability_description_table | 124636-124878 | 13 ($00-$0C) | ability index ($0AE8) | Ability description text starting with [DBL]; $00 = 'Nothing' |
; | character_name_table | 124878-125260 | 4 | characterForm ($0AD4) | ' Will', ' Freedan', ' Shadow' and ' Shadow' (form 3 repeats form 2), followed by 15 loose HUD and status-screen strings |
; | misc_ui_strings | 125260-125711 | 2 | button layout ($0B26) | 'B' (layout 0 = Type 1) and 'Y' (layout 1 = Type 2), the item-use button name printed in E919; followed by 20 loose menu strings |
; 
; Ability index = characterForm x 4 + ability slot + 1 ($0AE8, ComputeAbilityIndex); entry 0 is the empty / 'Nothing' entry. Will: $01 Psycho Dash, $02 Psycho Slider, $03 Spin Dash, $04 empty; Freedan: $05 Dark Friar, $06 Aura Barrier, $07 Earthquaker, $08 empty; Shadow: $09-$0B are the placeholder strings DEFENCERK, DARKCOREK and BLACK4K (descriptions 'Dark 1' in $09-$0C), not real abilities.
; 
; Item IDs named here are the same IDs as in the chest table and the inventory icons: $01 Red Jewel, $02 Prison Key, $03-$04 Incan Statue A / B, $05 Incan Melody, $06 Herb, $07 Blue Block, $08 Wind Melody, $09 Lola's Melody, $0A Meat, $0B-$0C Mine Key A / B, $0D Memory Melody, $0E Crystal Ball, $0F Elevator Key, $10 Palace Key, $11 Purify Stone, $12 Statue of Hope, $13 Rama Statue, $14 Magic Dust, $15 Blue Journal, $16 Lance's Letter, $17 Necklace Stones, $18 Will, $19 Teapot, $1A Mushroom Drop, $1B Bag of Gold, $1C Black Glasses, $1D Gorgon Flower, $1E-$23 Hieroglyph (six), $24 Aura, $25 Lola's Letter, $26 Father's Journal, $27 Crystal Ring, $28 Red Apple.
; 
; === NON-DISCARDABLE BITS ===
; 
; The bytes are $BC $FF $FF $FE $DF $00 $00 $00. Discardable (bit clear): $00, $01 Red Jewel, $06 Herb, $18 Will, $25 Lola's Letter, $28-$3F. Protected: $02-$05, $07-$17, $19-$24, $26 and $27. $18 and $25 being discardable is unexplained (OQ-I072-2).
; 
; === WHAT WAS WRONG IN THE OLD NOTES ===
; 
; item_name_line_table was 'longer descriptions shown when hovering': it is the one-line NAME (the description is item_description_table). The blank item range was given as $2A-$38 and the 'Mystic Statue' range as $39-$3F; they are $29-$37 and $38-$3F (8 statues, as the 8 'Mystery Doll' tags of shared_word_table say). item_description_table was 'multi-line descriptions of function and lore': it has 41 entries of short function text. non_discardable_item_bits was 'padding / alignment data between two tables'; it is read by CheckItemDiscardable. misc_ui_strings was 'status labels, save/load prompts, game over text': the table is just 'B' and 'Y' and the loose strings are inventory-menu prompts, tab titles and three screen labels (PAUSE, FORCE, the button legend). The old part notes of item_name_table (blank and statue ranges) and boot_title_strings ('displayed at boot': two of the three are title-screen strings) were also off. character_name_table was 'Will, Kara, Lance, Erik, Seth and other story characters': it holds the three player forms.
; 
; Byte check: the ten parts add up to 4407 bytes = 125711 - 121304. Part addresses are from blocks.json; the strings between the tables are listed in the part notes.
---------------------------------------------

?BANK 01

---------------------------------------------

; 3 fixed strings, none of them printed by the menus: this one is the region lockout screen of sFB_boot_logo ('WARNING! This game pak is not designed for your SUPER FAMICOM or Super NES.' and the Enix line; a 50 Hz console never leaves it). The next two, consolestring_01DA47 'PUSH START BUTTON' and consolestring_01DA5E the copyright text, are drawn by sFC_title_intro (the copyright first). The names file calls address 121304 boot_title_strings, the label sFB_boot_logo uses.

boot_title_strings |[PAL:4][POS:18,2]WARNING![DBL][DBL][PAL:0][POS:0,3] This game pak is not designed[DBL] for your SUPER FAMICOM or[DBL] Super NES.[DBL][DBL][POS:DC,4]ENIX CORPORATION|

consolestring_01DA47 |[PAL:4][POS:D0,4]PUSH START BUTTON|

consolestring_01DA5E |[PAL:0][POS:C8,5](C) 1994  QUINTET⸓ENIX[POS:8,6]MARIKO OHARA⸓MOTO HAGIO[POS:4E,6]YASUHIRO KAWASAKI[POS:8C,6]LICENSED TO NINTENDO|
---------------------------------------------

; 64 pointers, index = item ID. The names carry [N] line breaks for the two-row status area; item_name_line_table has the same names on one line. Empty at $00, blank (8 spaces) at $29-$37, 'Mystic Statue' at $38-$3F (the old note put the blank range at $2A-$38 and the statues at $39-$3F). $00 points at consolestring_01DB3F, the empty string shared with ability_menu_table and ability_name_table.

item_name_table [
  &consolestring_01DB3F   ;00
  &consolestring_01DB40   ;01
  &consolestring_01DB4B   ;02
  &consolestring_01DB51   ;03
  &consolestring_01DB5C   ;04
  &consolestring_01DB68   ;05
  &consolestring_01DB78   ;06
  &consolestring_01DB81   ;07
  &consolestring_01DB8C   ;08
  &consolestring_01DB9B   ;09
  &consolestring_01DBAC   ;0A
  &consolestring_01DBB2   ;0B
  &consolestring_01DBBD   ;0C
  &consolestring_01DBC8   ;0D
  &consolestring_01DBD8   ;0E
  &consolestring_01DBE7   ;0F
  &consolestring_01DBF8   ;10
  &consolestring_01DC05   ;11
  &consolestring_01DC14   ;12
  &consolestring_01DC20   ;13
  &consolestring_01DC2E   ;14
  &consolestring_01DC3B   ;15
  &consolestring_01DC4A   ;16
  &consolestring_01DC5C   ;17
  &consolestring_01DC6E   ;18
  &consolestring_01DC73   ;19
  &consolestring_01DC7C   ;1A
  &consolestring_01DC8C   ;1B
  &consolestring_01DC9A   ;1C
  &consolestring_01DCAC   ;1D
  &consolestring_01DCBD   ;1E
  &consolestring_01DCC8   ;1F
  &consolestring_01DCD3   ;20
  &consolestring_01DCDE   ;21
  &consolestring_01DCE9   ;22
  &consolestring_01DCF4   ;23
  &consolestring_01DCFF   ;24
  &consolestring_01DD06   ;25
  &consolestring_01DD17   ;26
  &consolestring_01DD2B   ;27
  &consolestring_01DD3A   ;28
  &consolestring_01DD47   ;29
  &consolestring_01DD50   ;2A
  &consolestring_01DD59   ;2B
  &consolestring_01DD62   ;2C
  &consolestring_01DD6B   ;2D
  &consolestring_01DD74   ;2E
  &consolestring_01DD7D   ;2F
  &consolestring_01DD86   ;30
  &consolestring_01DD8F   ;31
  &consolestring_01DD98   ;32
  &consolestring_01DDA1   ;33
  &consolestring_01DDAA   ;34
  &consolestring_01DDB3   ;35
  &consolestring_01DDBC   ;36
  &consolestring_01DDC5   ;37
  &consolestring_01DDCE   ;38
  &consolestring_01DDD8   ;39
  &consolestring_01DDE2   ;3A
  &consolestring_01DDEC   ;3B
  &consolestring_01DDF6   ;3C
  &consolestring_01DE00   ;3D
  &consolestring_01DE0A   ;3E
  &consolestring_01DE14   ;3F
]

consolestring_01DB3F ||

consolestring_01DB40 |Red Jewel |

consolestring_01DB4B |[LU:6]Key|

consolestring_01DB51 |Incan[N] [LU:C]A|

consolestring_01DB5C |Incan[N] [LU:C]B |

consolestring_01DB68 |Incan [N] Melody |

consolestring_01DB78 |Herb    |

consolestring_01DB81 |Blue Block|

consolestring_01DB8C |Wind [N] Melody |

consolestring_01DB9B |Lola's [N] Melody |

consolestring_01DBAC |Meat |

consolestring_01DBB2 |Mine Key A|

consolestring_01DBBD |Mine Key B|

consolestring_01DBC8 |Memory [N] Melody|

consolestring_01DBD8 |Crystal [N] Ball|

consolestring_01DBE7 |Elevator [N] Key  |

consolestring_01DBF8 |Palace [N] Key|

consolestring_01DC05 |Purify [N] Stone|

consolestring_01DC14 |[LU:C]of[N] Hope |

consolestring_01DC20 |Rama [N] Statue|

consolestring_01DC2E |Magic [N] Dust|

consolestring_01DC3B |Blue [N] Journal|

consolestring_01DC4A |Lance's [N]  Letter|

consolestring_01DC5C |Necklace [N] Stones|

consolestring_01DC6E |Will|

consolestring_01DC73 |Teapot  |

consolestring_01DC7C |Mushroom [N] Drop|

consolestring_01DC8C |Bag of [N] Gold|

consolestring_01DC9A |Black [N] Glasses  |

consolestring_01DCAC |Gorgon [N] Flower |

consolestring_01DCBD |Hieroglyph|

consolestring_01DCC8 |Hieroglyph|

consolestring_01DCD3 |Hieroglyph|

consolestring_01DCDE |Hieroglyph|

consolestring_01DCE9 |Hieroglyph|

consolestring_01DCF4 |Hieroglyph|

consolestring_01DCFF |Aura  |

consolestring_01DD06 |Lola's [N] Letter |

consolestring_01DD17 |Father's [N] Journal |

consolestring_01DD2B |Crystal [N] Ring|

consolestring_01DD3A |Red [N] Apple |

consolestring_01DD47 |        |

consolestring_01DD50 |        |

consolestring_01DD59 |        |

consolestring_01DD62 |        |

consolestring_01DD6B |        |

consolestring_01DD74 |        |

consolestring_01DD7D |        |

consolestring_01DD86 |        |

consolestring_01DD8F |        |

consolestring_01DD98 |        |

consolestring_01DDA1 |        |

consolestring_01DDAA |        |

consolestring_01DDB3 |        |

consolestring_01DDBC |        |

consolestring_01DDC5 |        |

consolestring_01DDCE |Mystic [LU:C]|

consolestring_01DDD8 |Mystic [LU:C]|

consolestring_01DDE2 |Mystic [LU:C]|

consolestring_01DDEC |Mystic [LU:C]|

consolestring_01DDF6 |Mystic [LU:C]|

consolestring_01DE00 |Mystic [LU:C]|

consolestring_01DE0A |Mystic [LU:C]|

consolestring_01DE14 |Mystic [LU:C]|
---------------------------------------------

; 64 pointers, index = item ID. One-line item names: the first half of the item description box (consolestring_01E9D0 = this table + item_description_table) and the Discard? prompt (consolestring_01E9E2). It is not a table of descriptions. $29-$37 are blank and $38-$3F read 'Mystery Doll', unlike the 'Mystic Statue' of item_name_table (OQ-I072-1).

item_name_line_table [
  &consolestring_01DE9E   ;00
  &consolestring_01DE9F   ;01
  &consolestring_01DEAA   ;02
  &consolestring_01DEB0   ;03
  &consolestring_01DEB6   ;04
  &consolestring_01DEBC   ;05
  &consolestring_01DEC5   ;06
  &consolestring_01DECE   ;07
  &consolestring_01DED9   ;08
  &consolestring_01DEE6   ;09
  &consolestring_01DEF5   ;0A
  &consolestring_01DEFB   ;0B
  &consolestring_01DF06   ;0C
  &consolestring_01DF11   ;0D
  &consolestring_01DF1F   ;0E
  &consolestring_01DF2C   ;0F
  &consolestring_01DF3B   ;10
  &consolestring_01DF46   ;11
  &consolestring_01DF53   ;12
  &consolestring_01DF5D   ;13
  &consolestring_01DF69   ;14
  &consolestring_01DF74   ;15
  &consolestring_01DF81   ;16
  &consolestring_01DF92   ;17
  &consolestring_01DFA2   ;18
  &consolestring_01DFA7   ;19
  &consolestring_01DFB0   ;1A
  &consolestring_01DFBE   ;1B
  &consolestring_01DFCA   ;1C
  &consolestring_01DFDA   ;1D
  &consolestring_01DFE9   ;1E
  &consolestring_01DFF4   ;1F
  &consolestring_01DFFF   ;20
  &consolestring_01E00A   ;21
  &consolestring_01E015   ;22
  &consolestring_01E020   ;23
  &consolestring_01E02B   ;24
  &consolestring_01E032   ;25
  &consolestring_01E041   ;26
  &consolestring_01E053   ;27
  &consolestring_01E060   ;28
  &consolestring_01E06B   ;29
  &consolestring_01E074   ;2A
  &consolestring_01E07D   ;2B
  &consolestring_01E086   ;2C
  &consolestring_01E08F   ;2D
  &consolestring_01E098   ;2E
  &consolestring_01E0A1   ;2F
  &consolestring_01E0AA   ;30
  &consolestring_01E0B3   ;31
  &consolestring_01E0BC   ;32
  &consolestring_01E0C5   ;33
  &consolestring_01E0CE   ;34
  &consolestring_01E0D7   ;35
  &consolestring_01E0E0   ;36
  &consolestring_01E0E9   ;37
  &consolestring_01E0F2   ;38
  &consolestring_01E0F9   ;39
  &consolestring_01E100   ;3A
  &consolestring_01E107   ;3B
  &consolestring_01E10E   ;3C
  &consolestring_01E115   ;3D
  &consolestring_01E11C   ;3E
  &consolestring_01E123   ;3F
]

consolestring_01DE9E ||

consolestring_01DE9F |Red Jewel |

consolestring_01DEAA |[LU:6]Key|

consolestring_01DEB0 |[LU:4][LU:C]A|

consolestring_01DEB6 |[LU:4][LU:C]B|

consolestring_01DEBC |[LU:4]Melody|

consolestring_01DEC5 |Herb    |

consolestring_01DECE |Blue Block|

consolestring_01DED9 |Wind Melody |

consolestring_01DEE6 |Lola's Melody |

consolestring_01DEF5 |Meat |

consolestring_01DEFB |Mine Key A|

consolestring_01DF06 |Mine Key B|

consolestring_01DF11 |Memory Melody|

consolestring_01DF1F |Crystal Ball|

consolestring_01DF2C |Elevator Key  |

consolestring_01DF3B |Palace Key|

consolestring_01DF46 |Purify Stone|

consolestring_01DF53 |[LU:C]of Hope|

consolestring_01DF5D |Rama Statue|

consolestring_01DF69 |Magic Dust|

consolestring_01DF74 |Blue Journal|

consolestring_01DF81 |Lance's letter  |

consolestring_01DF92 |Necklace Stones|

consolestring_01DFA2 |Will|

consolestring_01DFA7 |Teapot  |

consolestring_01DFB0 |Mushroom Drop|

consolestring_01DFBE |Bag of Gold|

consolestring_01DFCA |Black Glasses  |

consolestring_01DFDA |Gorgon Flower |

consolestring_01DFE9 |Hieroglyph|

consolestring_01DFF4 |Hieroglyph|

consolestring_01DFFF |Hieroglyph|

consolestring_01E00A |Hieroglyph|

consolestring_01E015 |Hieroglyph|

consolestring_01E020 |Hieroglyph|

consolestring_01E02B |Aura  |

consolestring_01E032 |Lola's Letter |

consolestring_01E041 |Father's Journal |

consolestring_01E053 |Crystal Ring|

consolestring_01E060 |Red Apple |

consolestring_01E06B |        |

consolestring_01E074 |        |

consolestring_01E07D |        |

consolestring_01E086 |        |

consolestring_01E08F |        |

consolestring_01E098 |        |

consolestring_01E0A1 |        |

consolestring_01E0AA |        |

consolestring_01E0B3 |        |

consolestring_01E0BC |        |

consolestring_01E0C5 |        |

consolestring_01E0CE |        |

consolestring_01E0D7 |        |

consolestring_01E0E0 |        |

consolestring_01E0E9 |        |

consolestring_01E0F2 |[LU:5]Doll|

consolestring_01E0F9 |[LU:5]Doll|

consolestring_01E100 |[LU:5]Doll|

consolestring_01E107 |[LU:5]Doll|

consolestring_01E10E |[LU:5]Doll|

consolestring_01E115 |[LU:5]Doll|

consolestring_01E11C |[LU:5]Doll|

consolestring_01E123 |[LU:5]Doll|
---------------------------------------------

; 8 bytes $BC $FF $FF $FE $DF 0 0 0: one bit per item ID, set = cannot be discarded (byte = ID >> 3, bit = BitMaskTable[ID & 7]). Read by CheckItemDiscardable. Discardable: $00, $01, $06, $18, $25, $28-$3F.

non_discardable_item_bits #BCFFFFFEDF000000
---------------------------------------------

; 41 pointers ($00-$28), index = item ID; there is no entry for $29-$3F. Short descriptions of three or four rows, each starting with [DBL] so it continues below the name line; $00 = 'Nothing'.

item_description_table [
  &consolestring_01E184   ;00
  &consolestring_01E18C   ;01
  &consolestring_01E1A6   ;02
  &consolestring_01E1BC   ;03
  &consolestring_01E1D5   ;04
  &consolestring_01E1EE   ;05
  &consolestring_01E21A   ;06
  &consolestring_01E227   ;07
  &consolestring_01E23F   ;08
  &consolestring_01E25E   ;09
  &consolestring_01E276   ;0A
  &consolestring_01E296   ;0B
  &consolestring_01E2AC   ;0C
  &consolestring_01E2D1   ;0D
  &consolestring_01E2F5   ;0E
  &consolestring_01E30E   ;0F
  &consolestring_01E324   ;10
  &consolestring_01E337   ;11
  &consolestring_01E355   ;12
  &consolestring_01E377   ;13
  &consolestring_01E399   ;14
  &consolestring_01E3C4   ;15
  &consolestring_01E3E1   ;16
  &consolestring_01E3F3   ;17
  &consolestring_01E413   ;18
  &consolestring_01E43A   ;19
  &consolestring_01E452   ;1A
  &consolestring_01E472   ;1B
  &consolestring_01E48D   ;1C
  &consolestring_01E4B9   ;1D
  &consolestring_01E4D4   ;1E
  &consolestring_01E4E8   ;1F
  &consolestring_01E4FC   ;20
  &consolestring_01E510   ;21
  &consolestring_01E524   ;22
  &consolestring_01E538   ;23
  &consolestring_01E54C   ;24
  &consolestring_01E574   ;25
  &consolestring_01E590   ;26
  &consolestring_01E5BC   ;27
  &consolestring_01E5D3   ;28
]

consolestring_01E184 |Nothing|

consolestring_01E18C |[DBL]Trade for goods[DBL]in town.|

consolestring_01E1A6 |[DBL]Edward Castle[DBL][LU:6]Key.|

consolestring_01E1BC |[DBL][LU:C]shaped[DBL]like a spirit.|

consolestring_01E1D5 |[DBL][LU:C]shaped[DBL]like a spirit.|

consolestring_01E1EE |[DBL]Told by father[DBL]to go to Incas[DBL]with melody.|

consolestring_01E21A |[DBL][LU:9]strength.|

consolestring_01E227 |[DBL]Diamond-shaped [DBL]block.|

consolestring_01E23F |[DBL]Melody played by [DBL]Incan Wind.|

consolestring_01E25E |[DBL]Melody learned[DBL][LU:E]Lola.|

consolestring_01E276 |[DBL]Large Roast [DBL][LU:E]Edward [DBL]Castle.|

consolestring_01E296 |[DBL]Key found[DBL]in morgue.|

consolestring_01E2AC |[DBL]Key obtained [DBL][LU:E]Laborer [DBL]in [LU:1]Mine.|

consolestring_01E2D1 |[DBL]Memory Melody[DBL][LU:E]Laborer.[DBL][LU:9]Memory.|

consolestring_01E2F5 |[DBL]Fits into[DBL]Crystal Tile.|

consolestring_01E30E |[DBL][LU:1]Mine[DBL]Elevator Key.|

consolestring_01E324 |[DBL]Key to[DBL]Mu tunnel.|

consolestring_01E337 |[DBL]Purifies fountain[DBL]in palace.|

consolestring_01E355 |[DBL][LU:C]containing[DBL]hopes of[DBL]Mu people.|

consolestring_01E377 |[DBL][LU:C]which[DBL]breaks the seal[DBL]of Rama.|

consolestring_01E399 |[DBL]Magic powder.[DBL]Releases person[DBL][LU:E]painting.|

consolestring_01E3C4 |[DBL]Journal found[DBL]by fireplace.|

consolestring_01E3E1 |[DBL]Letter [LU:E][DBL]Lance.|

consolestring_01E3F3 |[DBL]Necklace Lance[DBL]made for Lilly.|

consolestring_01E413 |[DBL]Will given to[DBL]Russian Glass[DBL]Opponent.|

consolestring_01E43A |[DBL]Jar filled[DBL]with tears.|

consolestring_01E452 |[DBL]Grows plants[DBL][LU:E]ends of[DBL]stalks.|

consolestring_01E472 |[DBL]Prize from[DBL]Russian Glass.|

consolestring_01E48D |[DBL]Black glasses.[DBL]Protects from[DBL]bright light.|

consolestring_01E4B9 |[DBL][LU:9]things[DBL]turned to stone.|

consolestring_01E4D4 |[DBL][LU:7]with[DBL]hieroglyph.|

consolestring_01E4E8 |[DBL][LU:7]with[DBL]hieroglyph.|

consolestring_01E4FC |[DBL][LU:7]with[DBL]hieroglyph.|

consolestring_01E510 |[DBL][LU:7]with[DBL]hieroglyph.|

consolestring_01E524 |[DBL][LU:7]with[DBL]hieroglyph.|

consolestring_01E538 |[DBL][LU:7]with[DBL]hieroglyph.|

consolestring_01E54C |[DBL][LU:2]Knight[DBL]Shadow's Body[DBL]turns to water.|

consolestring_01E574 |[DBL]Letter from[DBL]Lola and Bill.|

consolestring_01E590 |[DBL]Will's father's[DBL]journal. Info on [DBL]Pyramid.|

consolestring_01E5BC |[DBL]Ring hidden[DBL]in Flute.|

consolestring_01E5D3 |[DBL]Apple from[DBL]Euro Market.|
---------------------------------------------

; 12 pointers, index = ability index (characterForm x 4 + slot + 1). One-line ability names; slots 4 of Will and Freedan are empty and the three Shadow entries are the placeholders DEFENCERK, DARKCOREK and BLACK4K.

ability_menu_table [
  &consolestring_01DB3F   ;00
  &consolestring_01E604   ;01
  &consolestring_01E60B   ;02
  &consolestring_01E614   ;03
  &consolestring_01E61E   ;04
  &consolestring_01E61F   ;05
  &consolestring_01E627   ;06
  &consolestring_01E634   ;07
  &consolestring_01E640   ;08
  &consolestring_01E641   ;09
  &consolestring_01E64B   ;0A
  &consolestring_01E655   ;0B
]

consolestring_01E604 |[LU:8]Dash|

consolestring_01E60B |[LU:8]Slider|

consolestring_01E614 |Spin Dash|

consolestring_01E61E ||

consolestring_01E61F |[LU:2]Friar|

consolestring_01E627 |Aura Barrier|

consolestring_01E634 |Earthquaker|

consolestring_01E640 ||

consolestring_01E641 |DEFENCERK|

consolestring_01E64B |DARKCOREK|

consolestring_01E655 |BLACK4K|
---------------------------------------------

; 12 pointers, index = ability index. The same names with [N] line breaks, printed after ':' on the status rows (consolestring_01EA49 / 01EA56 / 01EA63).

ability_name_table [
  &consolestring_01DB3F   ;00
  &consolestring_01E675   ;01
  &consolestring_01E67F   ;02
  &consolestring_01E68A   ;03
  &consolestring_01E696   ;04
  &consolestring_01E697   ;05
  &consolestring_01E6A1   ;06
  &consolestring_01E6B0   ;07
  &consolestring_01E6BF   ;08
  &consolestring_01E6C0   ;09
  &consolestring_01E6CA   ;0A
  &consolestring_01E6D4   ;0B
]

consolestring_01E675 |[LU:8][N] Dash |

consolestring_01E67F |[LU:8][N] Slider|

consolestring_01E68A |Spin [N] Dash|

consolestring_01E696 ||

consolestring_01E697 |[LU:2][N] Friar|

consolestring_01E6A1 |Aura [N] Barrier|

consolestring_01E6B0 |Earth-[N] quaker|

consolestring_01E6BF ||

consolestring_01E6C0 |DEFENCERK|

consolestring_01E6CA |DARKCOREK|

consolestring_01E6D4 |BLACK4K|
---------------------------------------------

; 13 pointers ($00-$0C), index = ability index. $00 = 'Nothing'; $04 and $08 are empty; $09-$0C read 'Dark 1' (placeholders of the unused form-2 rows).

ability_description_table [
  &consolestring_01E184   ;00
  &consolestring_01E6F6   ;01
  &consolestring_01E718   ;02
  &consolestring_01E73C   ;03
  &consolestring_01E75B   ;04
  &consolestring_01E75C   ;05
  &consolestring_01E779   ;06
  &consolestring_01E795   ;07
  &consolestring_01E7CD   ;08
  &consolestring_01E7B9   ;09
  &consolestring_01E7BE   ;0A
  &consolestring_01E7C3   ;0B
  &consolestring_01E7C8   ;0C
]

consolestring_01E6F6 |[DBL]Smash enemies[DBL]Destroy obstacles.|

consolestring_01E718 |[DBL]Use Slide Attack[DBL]For small spaces.|

consolestring_01E73C |[DBL]Spinning attack.[DBL]Climb hills.|

consolestring_01E75B ||

consolestring_01E75C |[DBL]Attack shoots[DBL]out of sword.|

consolestring_01E779 |[DBL]Wraps Barrier[DBL]around body.|

consolestring_01E795 |[DBL]Causes Earthquake[DBL]Paralyzes Enemy.|

consolestring_01E7B9 |[LU:2]1 |

consolestring_01E7BE |[LU:2]1 |

consolestring_01E7C3 |[LU:2]1 |

consolestring_01E7C8 |[LU:2]1 |

consolestring_01E7CD ||
---------------------------------------------

; 4 pointers, index = characterForm ($0AD4): ' Will', ' Freedan', ' Shadow', ' Shadow' (form 3 repeats form 2; each name has a leading space). Used by the status screen (STYLE) and consolestring_01EA70 ('<name>'s cond.'). The part also holds the loose strings consolestring_01E7F6 to 01E919 (HUD, status screen and panel clears), see consolestring_01E7F6.

character_name_table [
  &consolestring_01E7D6   ;00
  &consolestring_01E7DD   ;01
  &consolestring_01E7E6   ;02
  &consolestring_01E7EE   ;03
]

consolestring_01E7D6 | Will|

consolestring_01E7DD | Freedan|

consolestring_01E7E6 | Shadow|

consolestring_01E7EE | Shadow|

---------------------------------------------
; HUD line redrawn by system_core: 5 raw tiles (ESC:1-5), the player HP bar [HP], the hundreds digit of DP ($0AD8, BCD) and the DP number ($0AD6). HudRedesign.patch.asm overrides it. consolestring_01E818 is the second HUD line (enemy bar [HE] with raw tiles 8-C, drawn by inventory_overlay and system_core). The six small strings consolestring_01E82B to 01E85C (digits 1-3 and raw tiles at (DE,1) / (9E,1)) have no label reference in the code or the patches (OQ-I072-3).

consolestring_01E7F6 |[POS:48,0][PAL:14][ESC:1,2,3,4,5][POS:84,0][PAL:8][HP][POS:9C,0][PAL:14][BCD:1,AD8][POS:A2,0][NUM:AD6]|

consolestring_01E818 |[PAL:14][POS:6C,0][ESC:8,9,A,B,C][PAL:4][POS:A8,0][HE]|

consolestring_01E82B |[POS:DE,1][PAL:14]1[PAL:0]|

consolestring_01E834 |[POS:DE,1][PAL:14]2[PAL:0]|

consolestring_01E83D |[POS:DE,1][PAL:14]3[PAL:0]|

consolestring_01E846 |[POS:DE,1][PAL:14][ESC:0][PAL:0]|

consolestring_01E851 |[POS:9E,1][PAL:14][NUM:8][PAL:0]|

consolestring_01E85C |[POS:9E,1][ESC:0][POS:DE,1][ESC:0]|

consolestring_01E869 |[POS:0,0][RCC:1F,4]|

---------------------------------------------
; Status-tab screen of the inventory: STYLE and the form name ([TBL:@character_name_table,AD4]), HP, DP, STR and DEF labels with their numbers, 'Items' with the equipped item name ([TBL:@item_name_table,AC6]) and the 'Dark Power' label (inventory_menu, the Status tab hover).

consolestring_01E870 |[POS:46,1][PAL:14]STYLE[PAL:0][TBL:@character_name_table,AD4][PAL:14][POS:C6,1]HP[POS:6,2]DP[POS:46,2]STR[POS:86,2]DEF[POS:CE,1][PAL:0][NUM:ACE]⸓[NUM:ACA][POS:E,2][NUM:AD6][POS:4E,2][NUM:ADE][POS:8E,2][NUM:ADC][POS:14,2][NUM:AD8][PAL:14][POS:14,2]S[PAL:0][POS:6,3]Items[POS:8C,3][TBL:@item_name_table,AC6][POS:64,1][LU:2]Power|

consolestring_01E8E2 |[POS:4,1][RCC:1C,B]|

consolestring_01E8E9 |[PAL:0][POS:84,5] Items[DBL] Order[DBL] Remove[DBL] Cond.|

consolestring_01E90B |[POS:44,5][RCC:1C,7]|

consolestring_01E912 |[POS:56,5][RCC:13,7]|

---------------------------------------------
; 'Equipped. Equipment <B or Y> button to use.': the button letter comes from misc_ui_strings through [TBL:@misc_ui_strings,B26], the button layout of the save ($0B26).

consolestring_01E919 |[PAL:0][POS:96,5]Equipped.[DBL]Equipment[DBL][PAL:14][TBL:@misc_ui_strings,B26][PAL:0] button to use.|
---------------------------------------------

; 2 pointers: 'B' and 'Y', index = button layout ($0B26: 0 = Type 1, 1 = Type 2). The part continues with the loose menu strings: the tab prompts ('Rearrange items.', 'Discard item.', 'Select item and enter.', 'Rearrange items? Select 1st item.', 'Select 2nd item.', 'Discard which item?'), the item and ability description boxes (consolestring_01E9D0, 01EAB4), the tab titles (Gather Items, Arrange Items, Discard Item, Dark Power), the ability rows (consolestring_01EA49 to 01EA63), the Status-tab hint (consolestring_01EA70), 'PAUSE' (consolestring_01EAC6, GlobalInputHandler), 'FORCE' (consolestring_01EAD1, radar_map_screen) and the button legend box (consolestring_01EADC, sFA_diary_menu).

misc_ui_strings [
  &consolestring_01E950   ;00
  &consolestring_01E952   ;01
]

consolestring_01E950 |B|

consolestring_01E952 |Y|

consolestring_01E954 |[PAL:0][POS:96,5][LU:A]items.|

consolestring_01E962 |[PAL:0][POS:96,5]Discard item.|

consolestring_01E975 |[PAL:0][POS:96,5][LU:B]item[DBL]and enter.|

consolestring_01E98C |[PAL:0][POS:96,5][LU:A]items?[DBL][LU:B]1st item.|

consolestring_01E9A6 |[PAL:0][POS:96,5][LU:B]2nd item.|

consolestring_01E9B7 |[PAL:0][POS:96,5]Discard which[DBL]item?|

consolestring_01E9D0 |[PAL:0][POS:96,5][TBL:@item_name_line_table,AE8][TBL:@item_description_table,AE8]|

consolestring_01E9E2 |[PAL:0][POS:96,5][TBL:@item_name_line_table,AE8][DBL]Discard?[DBL]  No[DBL]  Yes|

consolestring_01EA02 |[PAL:0][POS:84,5]Gather[DBL]Items|

consolestring_01EA14 |[PAL:0][POS:84,5]Arrange[DBL]Items|

consolestring_01EA27 |[PAL:0][POS:84,5]Discard[DBL]Item|

consolestring_01EA39 |[PAL:0][POS:84,5]Dark[DBL]Power|

consolestring_01EA49 |[PAL:0][POS:28,2]:[TBL:@ability_name_table,AE8]|

consolestring_01EA56 |[PAL:0][POS:E8,2]:[TBL:@ability_name_table,AE8]|

consolestring_01EA63 |[PAL:0][POS:A8,3]:[TBL:@ability_name_table,AE8]|

consolestring_01EA70 |[PAL:0][POS:96,5][TBL:@character_name_table,AD4]'s cond. [DBL]Use Attack Button [DBL]for explanation of[DBL][LU:2]Power.|

consolestring_01EAB4 |[PAL:0][POS:96,5][TBL:@ability_menu_table,AE8][TBL:@ability_description_table,AE8]|

consolestring_01EAC6 |[POS:1A,3][PAL:14]PAUSE|

consolestring_01EAD1 |[POS:C6,1][PAL:14]FORCE|

consolestring_01EADC |[PAL:0][BOX:B,4,A4][POS:E6,0]Ạ█Ḇṵṯṯōṉ█˭[N]███Ḛṉṯḛṟ[N]Ḃ█Ḇṵṯṯōṉ█˭[N]███Ĉāṉĉḛḻ|