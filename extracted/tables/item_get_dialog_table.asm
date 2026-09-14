; Item acquisition dialog messages. Maps item IDs to the dialog strings displayed when the player obtains each item. Covers stat increases, key items, inventory-full messages, and defaults.
---------------------------------------------

?BANK 01

---------------------------------------------

; Maps item IDs to acquisition dialog strings ('Will got a Red Jewel!', 'HP increased by 1!', etc.). Includes formulaic stat-increase strings, unique key item messages, shared Mystic Statue strings, inventory-full messages, and 'nothing found' defaults. Referenced by inventory_mgmt.asm and combat_collision.asm.

item_get_dialog_table [
  &dialogstring_01FDA4   ;00
  &dialogstring_01FDA7   ;01
  &dialogstring_01FDBB   ;02
  &dialogstring_01FDC2   ;03
  &dialogstring_01FDCD   ;04
  &dialogstring_01FDD8   ;05
  &dialogstring_01FDE1   ;06
  &dialogstring_01FDF1   ;07
  &dialogstring_01FE12   ;08
  &dialogstring_01FE17   ;09
  &dialogstring_01FE1C   ;0A
  &dialogstring_01FE29   ;0B
  &dialogstring_01FE2B   ;0C
  &dialogstring_01FE2D   ;0D
  &dialogstring_01FE2F   ;0E
  &dialogstring_01FE45   ;0F
  &dialogstring_01FE47   ;10
  &dialogstring_01FE52   ;11
  &dialogstring_01FE54   ;12
  &dialogstring_01FE56   ;13
  &dialogstring_01FE6B   ;14
  &dialogstring_01FE7D   ;15
  &dialogstring_01FE7D   ;16
  &dialogstring_01FE7D   ;17
  &dialogstring_01FE7D   ;18
  &dialogstring_01FE7D   ;19
  &dialogstring_01FE90   ;1A
  &dialogstring_01FEA6   ;1B
  &dialogstring_01FEA6   ;1C
  &dialogstring_01FEA6   ;1D
  &dialogstring_01FEA6   ;1E
  &dialogstring_01FEA6   ;1F
  &dialogstring_01FEA6   ;20
  &dialogstring_01FEA6   ;21
  &dialogstring_01FEA6   ;22
  &dialogstring_01FEA6   ;23
  &dialogstring_01FEA6   ;24
  &dialogstring_01FEA6   ;25
  &dialogstring_01FEA6   ;26
  &dialogstring_01FEA6   ;27
  &dialogstring_01FEA6   ;28
  &dialogstring_01FEA6   ;29
  &dialogstring_01FEA6   ;2A
  &dialogstring_01FEA6   ;2B
  &dialogstring_01FEA6   ;2C
  &dialogstring_01FEA6   ;2D
  &dialogstring_01FEA6   ;2E
  &dialogstring_01FEA6   ;2F
  &dialogstring_01FEA6   ;30
  &dialogstring_01FEA6   ;31
  &dialogstring_01FEA6   ;32
  &dialogstring_01FEA6   ;33
  &dialogstring_01FEA6   ;34
  &dialogstring_01FEA6   ;35
  &dialogstring_01FEA6   ;36
  &dialogstring_01FEA6   ;37
  &dialogstring_01FEA8   ;38
  &dialogstring_01FEBC   ;39
  &dialogstring_01FEC6   ;3A
  &dialogstring_01FED0   ;3B
  &dialogstring_01FEDA   ;3C
  &dialogstring_01FEE4   ;3D
  &dialogstring_01FEEE   ;3E
  &dialogstring_01FEF8   ;3F
]

dialogstring_01FDA4 `  `

dialogstring_01FDA7 `You found a Red Jewel! `

dialogstring_01FDBB `Prison Key `

dialogstring_01FDC2 `Incan Statue A `

dialogstring_01FDCD `Incan Statue B `

dialogstring_01FDD8 `Incan Melody `

dialogstring_01FDE1 `You found an herb! `

dialogstring_01FDF1 `You found [N]the diamond-shaped block!`

dialogstring_01FE12 `Wind Melody `

dialogstring_01FE17 `Lola's Melody `

dialogstring_01FE1C `Large Roast `

dialogstring_01FE29 ` `

dialogstring_01FE2B ` `

dialogstring_01FE2D ` `

dialogstring_01FE2F `You found[N]the Crystal Ball!`

dialogstring_01FE45 ` `

dialogstring_01FE47 `Palace Key`

dialogstring_01FE52 ` `

dialogstring_01FE54 ` `

dialogstring_01FE56 `You found Rama's Statue!`

dialogstring_01FE6B `You found Magic Dust!`

dialogstring_01FE7D `You found the Teapot! `

dialogstring_01FE90 `It's the Mushroom Drops!`

dialogstring_01FEA6 ` `

dialogstring_01FEA8 `It's a Mystic Statue! `

dialogstring_01FEBC `Mystic Statue `

dialogstring_01FEC6 `Mystic Statue `

dialogstring_01FED0 `Mystic Statue `

dialogstring_01FEDA `Mystic Statue `

dialogstring_01FEE4 `Mystic Statue `

dialogstring_01FEEE `Mystic Statue `

dialogstring_01FEF8 `Mystic Statue `

dialogstring_01FF02 `[DEF][DLY:1][ADR:&item_get_dialog_table,DB8][N]Your inventory's full![END]`

dialogstring_01FF1F `[DEF][DLY:5][SFX:0][ADR:&item_get_dialog_table,DB8][PAU:FF][CLD]`

dialogstring_01FF2D `[DEF][DLY:1][ADR:&item_get_dialog_table,DB8][END]`

dialogstring_01FF36 `[DEF][DLY:1][SFX:0]It is empty![END]`

dialogstring_01FF48 `[DEF][DLY:0]The jewel box is[N]tightly closed.[END]`