; World map destination menus and their handlers (Bank 03, 242689-244449). WorldMapController runs world_map_options[choice id & $1F] with SwitchCase after SetSavedPtr(DeferSceneTransition); the chosen handler ends in RestoreSavedPtr, which returns to DeferSceneTransition.
; 
; === A MENU (choice ids $01-$1B) ===
; 
; PrintDialogString shows a Quit / destination text, then COP DialogueOptions ( grid, skip, &list ) runs MenuSelectionHandler and jumps through the list; the RestoreSavedPtr that follows in the source is never reached (the RTI goes to the list target).
; - grid byte: low nibble = items per column, high nibble = total items (0 when everything fits in one column): #01 Quit only, #02 two items, #32 three items, #42 four items. The text puts the second column after the spaces (Quit [N] ... = column one; the text after 8-12 spaces = column two).
; - skip byte: text lines skipped before the first option row (#01 everywhere here). The cursor always starts on the first item, Quit.
; - list index = MenuSelectionHandler result: 0 = B pressed, 1 = first item (column one, top), 2 = column one, second row, then column two top to bottom. So for #32 / #42 the list order is not the reading order of the text.
; - Quit and B both run the same handler: QueueMapChange back to the scene the player came from, with no route (route id stays 0), so DeferSceneTransition dies and the scene changes at once.
; 
; === HANDLERS ===
; 
; A trip handler is StageWorldMapMoveIds ( 0, route id ) followed by a QueueMapChange ( scene, X, Y, flags, scroll ) for the destination. Most handlers are two adjacent blocks: the first has no end and falls into the second (the second is also the Quit handler of the destination's own menu). Seven handlers hold both operations in one block. QueueMapChange flag bit 7 ($80) records the destination as the new revive / save point (Inca Ruins, Diamond Mine, Great Wall, Mt.Temple entrance, Ankor Wat, Pyramid). The Watermia to Euro handlers also write $0D60 := 7 (leader animation 7). Menus are named WorldMapMenu_<id> (the choice id in hex; $1C-$25 are WorldMapMenu_Empty<id>, $26 is WorldMapMenu_Nothing26; the controller keeps only the low 5 bits of a choice id, so no id selects $20-$26). Handlers are WorldMapGo_<origin>_<destination> (route staging, which falls into the destination's quit block, or both operations in one block) and WorldMapQuit_<place> (QueueMapChange back to that place); WorldMapQuit_Itory_IncaMenu and WorldMapQuit_Watermia_AngelMenu are the second quit blocks of the Itory menu with the Inca Ruins option and of the Angel Village-side Watermia menu.
; 
; === CHOICE IDS (staged by overworld_exit, first flag found wins; see its table) ===
; 
; | Id | Menu | Id | Menu |
; |----|------|----|------|
; | $01 | South Cape: Quit / Edward's Castle | $0F | Euro: Quit / Watermia |
; | $02 | South Cape: Quit / Itory Village | $10 | Euro: Quit / Watermia / Mt.Temple |
; | $03 | Edward's Castle: Quit / South Cape | $11 | Mt.Temple: Quit / Euro city |
; | $04 | Itory: Quit / South Cape | $12 | Natives' Village: Quit / Euro city |
; | $05 | Inca Ruins: Quit / Itory | $13 | Natives' Village: Quit / Euro / Ankor Wat |
; | $06 | Itory: Quit / Inca Ruins | $14 | Ankor Wat: Quit / Natives' Village |
; | $07 | Freejia: Quit / Diamond Mine | $15 | Angel Village: Quit only |
; | $08 | Diamond Mine: Quit / Freejia | $16 | Dao: Quit / Natives' Village |
; | $09 | Freejia: Quit only | $17 | Dao: Quit / Natives' Village / Pyramid |
; | $0A | Angel Village: Quit / Watermia | $18 | Pyramid: Quit / Dao |
; | $0B | Watermia: Quit / Angel Village | $19 | Natives' Village: Quit / Euro / Ankor Wat / Dao |
; | $0C | Watermia: Quit / Angel Village / Great Wall | $1A | Euro: Quit / Watermia / Mt.Temple / Natives' Village |
; | $0D | Great Wall: Quit / Watermia | $1B | South Cape: Quit only |
; | $0E | Watermia: Quit / Angel Village / Great Wall / Euro | | |
; 
; Staged ids are $01-$1B: each is written by one StageWorldMapChoice site in overworld_exit, and the only other writer of $0D58 is StageWorldMapMove, which clears it. Entry $00 only returns (the controller dies before SwitchCase when the choice id is 0). Ids $1C-$1F are never staged, but the controller keeps the low 5 bits (AND #$001F), so staging one would run its entry. Entries $20-$26 cannot be reached by any id, because the table index is at most $1F. $1C-$25 print an empty [TPL:11] and return; $26 prints Nothing!!. Route ids staged here: $01-$04, $07, $08, $0A, $0B, $11-$20 (the other routes belong to scripted trips, see world_map_route_table).
; 
; === ROUTES (world_map_route_table.asm, Bank 03 241015-242132; the merge tool cannot annotate that file: no bank information) ===
; 
; 38 table entries ($00-$25) point at 37 route arrays; $00 aliases $01. The arrays are named route_<id>_<origin>_to_<destination> (route_unused_<id> for $0E, $0F, $10, $23, $24 and $25). A step is four bytes: three move_chain_table indices (X $00CA, Y $00CC, rotation $00BC; 0 = still) and a tick count n (the step runs n + 1 ticks). The extraction shows them as route-step < b0, b1, b2, b3 >; they are not flags, direction, spare and distance bytes. Every array is 4n + 1 bytes: a hidden $FF ends it; $FE (subroutine) is never used.
; Indices used: X and Y take 1 (+1 per tick), 2 (-1), $11 (alternating +1, 0) or $12 (alternating -1, 0); rotation takes 1 (+1) or 2 (-1). Steps never mix rotation with movement: a route turns the map ($20 = 22.5 degrees, $40 = 45, $80 = 90, $C0 = 135) and runs straight in one of eight directions.
; Check: summing the steps reproduces the distance between the staged start positions of the two scenes (overworld_exit): route $09 = 128 north, $03 = 16 west and 240 north, $0A = 224 east and 96 south ($0B the reverse), $01 = 48 east and 112 north. These sums match when each step counts n deltas; the engine applies n + 1 deltas per step (the step runs n + 1 ticks), one more per active axis than the sums.
; 
; | Route | Trip | Route | Trip |
; |-------|------|-------|------|
; | $01 | South Cape to Edward Castle (menu) | $13 | Watermia to Great Wall (menu) |
; | $02 | Edward Castle to South Cape (menu, ec0A_kara) | $14 | Great Wall to Watermia (menu) |
; | $03 | South Cape to Itory (menu, sc06_kara_return) | $15 | Watermia to Euro, leader anim 7 (menu, wa79_neil) |
; | $04 | Itory to South Cape (menu) | $16 | Euro to Watermia, leader anim 7 (menu) |
; | $05 | Itory to Moon Tribe Camp (it17_lily) | $17 | Euro to Mt.Temple (menu) |
; | $06 | Moon Tribe Camp to Inca Ruins (it1A_lily) | $18 | Mt.Temple to Euro (menu) |
; | $07 | Itory to Inca Ruins (menu) | $19 | Euro to Natives Village (menu, eu96_kara) |
; | $08 | Inca Ruins to Itory (menu) | $1A | Natives Village to Euro (menu) |
; | $09 | Diamond Coast (Oakton) to Freejia (dc30_kara) | $1B | Natives Village to Ankor Wat (menu) |
; | $0A | Freejia to Diamond Mine (menu) | $1C | Ankor Wat to Natives Village (menu) |
; | $0B | Diamond Mine to Freejia (menu) | $1D | Natives Village to Dao (menu, nvAE_kara) |
; | $0C | Freejia hotel to Neil Cottage (fr39_erik) | $1E | Dao to Pyramid (menu) |
; | $0D | Neil Cottage to Nazca Painting (na49_lance) | $1F | Pyramid to Dao (menu) |
; | $0E $0F $10 | not staged by anything found | $20 | Dao to Natives Village (menu) |
; | $11 | Angel Village to Watermia (menu, av6A_neil) | $21 | Dao to Over Babel, leader anim $0B (daC8_neil) |
; | $12 | Watermia to Angel Village (menu) | $22 | Watermia to South Cape, leader anim $0D (wa78_men) |
; | | | $23 $24 $25 | not staged by anything found |
---------------------------------------------

?BANK 03

---------------------------------------------

; 39 pointers indexed by the choice id & $1F, so only entries $00-$1F can be selected: $01-$1B are the menus staged by overworld_exit, $00 and $1C-$1F are never run ($00 never reaches SwitchCase, no site stages $1C-$1F), and $20-$26 cannot be reached by any id. Several menus share handlers.

world_map_options [
  &WorldMapMenu_00   ;00
  &WorldMapMenu_01   ;01
  &WorldMapMenu_02   ;02
  &WorldMapMenu_03   ;03
  &WorldMapMenu_04   ;04
  &WorldMapMenu_05   ;05
  &WorldMapMenu_06   ;06
  &WorldMapMenu_07   ;07
  &WorldMapMenu_08   ;08
  &WorldMapMenu_09   ;09
  &WorldMapMenu_0A   ;0A
  &WorldMapMenu_0B   ;0B
  &WorldMapMenu_0C   ;0C
  &WorldMapMenu_0D   ;0D
  &WorldMapMenu_0E   ;0E
  &WorldMapMenu_0F   ;0F
  &WorldMapMenu_10   ;10
  &WorldMapMenu_11   ;11
  &WorldMapMenu_12   ;12
  &WorldMapMenu_13   ;13
  &WorldMapMenu_14   ;14
  &WorldMapMenu_15   ;15
  &WorldMapMenu_16   ;16
  &WorldMapMenu_17   ;17
  &WorldMapMenu_18   ;18
  &WorldMapMenu_19   ;19
  &WorldMapMenu_1A   ;1A
  &WorldMapMenu_1B   ;1B
  &WorldMapMenu_Empty1C   ;1C
  &WorldMapMenu_Empty1D   ;1D
  &WorldMapMenu_Empty1E   ;1E
  &WorldMapMenu_Empty1F   ;1F
  &WorldMapMenu_Empty20   ;20
  &WorldMapMenu_Empty21   ;21
  &WorldMapMenu_Empty22   ;22
  &WorldMapMenu_Empty23   ;23
  &WorldMapMenu_Empty24   ;24
  &WorldMapMenu_Empty25   ;25
  &WorldMapMenu_Nothing26   ;26
]

---------------------------------------------
; Choice $00: only RestoreSavedPtr. Never run: WorldMapController dies before SwitchCase when the choice id is 0.

WorldMapMenu_00 {
    COP [RestoreSavedPtr]
}

---------------------------------------------
; Choice $01: Quit / Edward's Castle (South Cape exit, default). List: 0, 1 -> WorldMapQuit_SouthCape (back to South Cape); 2 -> WorldMapGo_SouthCape_EdwardCastle (route $01).

WorldMapMenu_01 {
    COP [PrintDialogString] ( &dialogstring_03B463 )
    COP [DialogueOptions] ( #02, #01, &code_list_03B45D ) ; Grid #02: two items in one column, skip 1 line; list index 0 = cancel, 1 = Quit, 2 = the destination (the next op is never reached)

  loc_03B45B:
    COP [RestoreSavedPtr]
}

code_list_03B45D [
  &WorldMapQuit_SouthCape   ;00
  &WorldMapQuit_SouthCape   ;01
  &WorldMapGo_SouthCape_EdwardCastle   ;02
]

dialogstring_03B463 `[TPL:11][SFX:0] Quit [N] Edward's Castle `

---------------------------------------------
; Choice $02: Quit / Itory Village (South Cape exit after a sc06_kara_return flag). List: Quit -> WorldMapQuit_SouthCape; 2 -> WorldMapGo_SouthCape_Itory (route $03).

WorldMapMenu_02 {
    COP [PrintDialogString] ( &dialogstring_03B48F )
    COP [DialogueOptions] ( #02, #01, &code_list_03B489 )

  loc_03B487:
    COP [RestoreSavedPtr]
}

code_list_03B489 [
  &WorldMapQuit_SouthCape   ;00
  &WorldMapQuit_SouthCape   ;01
  &WorldMapGo_SouthCape_Itory   ;02
]

dialogstring_03B48F `[TPL:11][SFX:0] Quit [N] Itory Village `

---------------------------------------------
; Choice $03: Quit / South Cape (Edward's Castle exit). List: Quit -> WorldMapQuit_EdwardCastle (back to the castle); 2 -> WorldMapGo_EdwardCastle_SouthCape (route $02).

WorldMapMenu_03 {
    COP [PrintDialogString] ( &dialogstring_03B4BA )
    COP [DialogueOptions] ( #02, #01, &code_list_03B4B4 )

  loc_03B4B2:
    COP [RestoreSavedPtr]
}

code_list_03B4B4 [
  &WorldMapQuit_EdwardCastle   ;00
  &WorldMapQuit_EdwardCastle   ;01
  &WorldMapGo_EdwardCastle_SouthCape   ;02
]

dialogstring_03B4BA `[TPL:11][SFX:0] Quit[N] South Cape`

---------------------------------------------
; Choice $04: Quit / South Cape (Itory Village exit, default). List: Quit -> WorldMapQuit_Itory (back to Itory); 2 -> WorldMapGo_Itory_SouthCape (route $04).

WorldMapMenu_04 {
    COP [PrintDialogString] ( &dialogstring_03B4DE )
    COP [DialogueOptions] ( #02, #01, &code_list_03B4D8 )

  loc_03B4D6:
    COP [RestoreSavedPtr]
}

code_list_03B4D8 [
  &WorldMapQuit_Itory   ;00
  &WorldMapQuit_Itory   ;01
  &WorldMapGo_Itory_SouthCape   ;02
]

dialogstring_03B4DE `[TPL:11][SFX:0] Quit[N] South Cape`

---------------------------------------------
; Choice $05: Quit / Itory Village (Inca Ruins entrance exit). List: Quit -> WorldMapQuit_IncaRuins (back to the ruins); 2 -> WorldMapGo_IncaRuins_Itory (route $08).

WorldMapMenu_05 {
    COP [PrintDialogString] ( &dialogstring_03B502 )
    COP [DialogueOptions] ( #02, #01, &code_list_03B4FC )

  loc_03B4FA:
    COP [RestoreSavedPtr]
}

code_list_03B4FC [
  &WorldMapQuit_IncaRuins   ;00
  &WorldMapQuit_IncaRuins   ;01
  &WorldMapGo_IncaRuins_Itory   ;02
]

dialogstring_03B502 `[TPL:11][SFX:0] Quit [N] Itory Village `

---------------------------------------------
; Choice $06: Quit / Inca Ruins (Itory Village exit after flag $4A, it1A_lily). List: Quit -> WorldMapQuit_Itory_IncaMenu (back to Itory); 2 -> WorldMapGo_Itory_IncaRuins (route $07).

WorldMapMenu_06 {
    COP [PrintDialogString] ( &dialogstring_03B52C )
    COP [DialogueOptions] ( #02, #01, &code_list_03B526 )

  loc_03B524:
    COP [RestoreSavedPtr]
}

code_list_03B526 [
  &WorldMapQuit_Itory_IncaMenu   ;00
  &WorldMapQuit_Itory_IncaMenu   ;01
  &WorldMapGo_Itory_IncaRuins   ;02
]

dialogstring_03B52C `[TPL:11][SFX:0] Quit[N] Inca Ruins`

---------------------------------------------
; Choice $07: Quit / Diamond Mine (Freejia exit after flag $65, fr33_erik). List: Quit -> WorldMapQuit_Freejia (back to Freejia); 2 -> WorldMapGo_Freejia_DiamondMine (route $0A).

WorldMapMenu_07 {
    COP [PrintDialogString] ( &dialogstring_03B551 )
    COP [DialogueOptions] ( #02, #01, &code_list_03B54B )

  loc_03B549:
    COP [RestoreSavedPtr]
}

code_list_03B54B [
  &WorldMapQuit_Freejia   ;00
  &WorldMapQuit_Freejia   ;01
  &WorldMapGo_Freejia_DiamondMine   ;02
]

dialogstring_03B551 `[TPL:11][SFX:0] Quit[N] Diamond Mine`

---------------------------------------------
; Choice $08: Quit / Freejia (Diamond Mine entrance exit). List: Quit -> WorldMapQuit_DiamondMine (back to the mine); 2 -> WorldMapGo_DiamondMine_Freejia (route $0B).

WorldMapMenu_08 {
    COP [PrintDialogString] ( &dialogstring_03B575 )
    COP [DialogueOptions] ( #02, #01, &code_list_03B56F )

  loc_03B56D:
    COP [RestoreSavedPtr]
}

code_list_03B56F [
  &WorldMapQuit_DiamondMine   ;00
  &WorldMapQuit_DiamondMine   ;01
  &WorldMapGo_DiamondMine_Freejia   ;02
]

dialogstring_03B575 `[TPL:11][SFX:0] Quit [N] Freejia `

---------------------------------------------
; Choice $09: Quit only (Freejia exit, default). Quit -> WorldMapQuit_Freejia (back to Freejia).

WorldMapMenu_09 {
    COP [PrintDialogString] ( &dialogstring_03B597 )
    COP [DialogueOptions] ( #01, #01, &code_list_03B593 ) ; Grid #01: one item (Quit only)

  loc_03B591:
    COP [RestoreSavedPtr]
}

code_list_03B593 [
  &WorldMapQuit_Freejia   ;00
  &WorldMapQuit_Freejia   ;01
]

dialogstring_03B597 `[TPL:11][SFX:0] Quit`

---------------------------------------------
; Choice $0A: Quit / Watermia (Angel Village exit after flag $8D, wa78_intro). List: Quit -> WorldMapQuit_AngelVillage (back to Angel Village); 2 -> WorldMapGo_AngelVillage_Watermia (route $11).

WorldMapMenu_0A {
    COP [PrintDialogString] ( &dialogstring_03B5B3 )
    COP [DialogueOptions] ( #02, #01, &code_list_03B5AD )

  loc_03B5AB:
    COP [RestoreSavedPtr]
}

code_list_03B5AD [
  &WorldMapQuit_AngelVillage   ;00
  &WorldMapQuit_AngelVillage   ;01
  &WorldMapGo_AngelVillage_Watermia   ;02
]

dialogstring_03B5B3 `[TPL:11][SFX:0] Quit[N] Watermia`

---------------------------------------------
; Choice $0B: Quit / Angel Village (Watermia exit, default). List: Quit -> WorldMapQuit_Watermia_AngelMenu (back to Watermia); 2 -> WorldMapGo_Watermia_AngelVillage (route $12).

WorldMapMenu_0B {
    COP [PrintDialogString] ( &dialogstring_03B5D9 )
    COP [DialogueOptions] ( #02, #01, &code_list_03B5D3 )

  loc_03B5D1:
    COP [RestoreSavedPtr]
}

code_list_03B5D3 [
  &WorldMapQuit_Watermia_AngelMenu   ;00
  &WorldMapQuit_Watermia_AngelMenu   ;01
  &WorldMapGo_Watermia_AngelVillage   ;02
]

dialogstring_03B5D9 `[TPL:11][SFX:0] Quit[N] Angel Village`

---------------------------------------------
; Choice $0C: Quit / Angel Village / Great Wall, grid #32 (Watermia exit after flag $8E). List: Quit -> WorldMapQuit_Watermia; 2 = Great Wall -> WorldMapGo_Watermia_GreatWall (route $13); 3 = Angel Village -> WorldMapGo_Watermia_AngelVillage (route $12).

WorldMapMenu_0C {
    COP [PrintDialogString] ( &dialogstring_03B606 )
    COP [DialogueOptions] ( #32, #01, &code_list_03B5FE ) ; Grid #32: three items, two per column; list order is column by column: Quit, Great Wall, Angel Village

  loc_03B5FC:
    COP [RestoreSavedPtr]
}

code_list_03B5FE [
  &WorldMapQuit_Watermia   ;00
  &WorldMapQuit_Watermia   ;01
  &WorldMapGo_Watermia_GreatWall   ;02
  &WorldMapGo_Watermia_AngelVillage   ;03
]

dialogstring_03B606 `[TPL:11][SFX:0] Quit        Angel Village[N] Great Wall`

---------------------------------------------
; Choice $0D: Quit / Watermia (Great Wall entrance exit). List: Quit -> WorldMapQuit_GreatWall (back to the wall); 2 -> WorldMapGo_GreatWall_Watermia (route $14).

WorldMapMenu_0D {
    COP [PrintDialogString] ( &dialogstring_03B63C )
    COP [DialogueOptions] ( #02, #01, &code_list_03B636 )

  loc_03B634:
    COP [RestoreSavedPtr]
}

code_list_03B636 [
  &WorldMapQuit_GreatWall   ;00
  &WorldMapQuit_GreatWall   ;01
  &WorldMapGo_GreatWall_Watermia   ;02
]

dialogstring_03B63C `[TPL:11][SFX:0] Quit[N] Watermia`

---------------------------------------------
; Choice $0E: Quit / Angel Village / Great Wall / Euro city, grid #42 (Watermia exit after flag $94, wa79_neil). List: Quit -> WorldMapQuit_Watermia; 2 = Great Wall -> WorldMapGo_Watermia_GreatWall; 3 = Angel Village -> WorldMapGo_Watermia_AngelVillage; 4 = Euro city -> WorldMapGo_Watermia_Euro (route $15).

WorldMapMenu_0E {
    COP [PrintDialogString] ( &dialogstring_03B666 )
    COP [DialogueOptions] ( #42, #01, &code_list_03B65C ) ; Grid #42: four items, two per column; list order: Quit, Great Wall, Angel Village, Euro city

  loc_03B65A:
    COP [RestoreSavedPtr]
}

code_list_03B65C [
  &WorldMapQuit_Watermia   ;00
  &WorldMapQuit_Watermia   ;01
  &WorldMapGo_Watermia_GreatWall   ;02
  &WorldMapGo_Watermia_AngelVillage   ;03
  &WorldMapGo_Watermia_Euro   ;04
]

dialogstring_03B666 `[TPL:11][SFX:0] Quit        Angel Village [N] Great Wall  Euro city `

---------------------------------------------
; Choice $0F: Quit / Watermia (Euro exit, default). List: Quit -> WorldMapQuit_Euro (back to Euro); 2 -> WorldMapGo_Euro_Watermia (route $16).

WorldMapMenu_0F {
    COP [PrintDialogString] ( &dialogstring_03B6A9 )
    COP [DialogueOptions] ( #02, #01, &code_list_03B6A3 )

  loc_03B6A1:
    COP [RestoreSavedPtr]
}

code_list_03B6A3 [
  &WorldMapQuit_Euro   ;00
  &WorldMapQuit_Euro   ;01
  &WorldMapGo_Euro_Watermia   ;02
]

dialogstring_03B6A9 `[TPL:11][SFX:0] Quit[N] Watermia`

---------------------------------------------
; Choice $10: Quit / Mt.Temple / Watermia, grid #32 (Euro exit after flag $9F). List: Quit -> WorldMapQuit_Euro; 2 = Watermia -> WorldMapGo_Euro_Watermia (route $16); 3 = Mt.Temple -> WorldMapGo_Euro_MtTemple (route $17).

WorldMapMenu_10 {
    COP [PrintDialogString] ( &dialogstring_03B6D1 )
    COP [DialogueOptions] ( #32, #01, &code_list_03B6C9 )

  loc_03B6C7:
    COP [RestoreSavedPtr]
}

code_list_03B6C9 [
  &WorldMapQuit_Euro   ;00
  &WorldMapQuit_Euro   ;01
  &WorldMapGo_Euro_Watermia   ;02
  &WorldMapGo_Euro_MtTemple   ;03
]

dialogstring_03B6D1 `[TPL:11][SFX:0] Quit        Mt.Temple[N] Watermia`

---------------------------------------------
; Choice $11: Quit / Euro city (Mt.Temple entrance exit). List: Quit -> WorldMapQuit_MtTemple (back to the temple); 2 -> WorldMapGo_MtTemple_Euro (route $18).

WorldMapMenu_11 {
    COP [PrintDialogString] ( &dialogstring_03B705 )
    COP [DialogueOptions] ( #02, #01, &code_list_03B6FF )

  loc_03B6FD:
    COP [RestoreSavedPtr]
}

code_list_03B6FF [
  &WorldMapQuit_MtTemple   ;00
  &WorldMapQuit_MtTemple   ;01
  &WorldMapGo_MtTemple_Euro   ;02
]

dialogstring_03B705 `[TPL:11][SFX:0] Quit [N] Euro city `

---------------------------------------------
; Choice $12: Quit / Euro city (Natives' Village exit, default). List: Quit -> WorldMapQuit_NativesVillage (back to the village); 2 -> WorldMapGo_NativesVillage_Euro (route $1A).

WorldMapMenu_12 {
    COP [PrintDialogString] ( &dialogstring_03B72B )
    COP [DialogueOptions] ( #02, #01, &code_list_03B725 )

  loc_03B723:
    COP [RestoreSavedPtr]
}

code_list_03B725 [
  &WorldMapQuit_NativesVillage   ;00
  &WorldMapQuit_NativesVillage   ;01
  &WorldMapGo_NativesVillage_Euro   ;02
]

dialogstring_03B72B `[TPL:11][SFX:0] Quit [N] Euro city `

---------------------------------------------
; Choice $13: Quit / Ankor Wat / Euro city, grid #32 (Natives' Village exit after flag $B1). List: Quit -> WorldMapQuit_NativesVillage; 2 = Euro city -> WorldMapGo_NativesVillage_Euro (route $1A); 3 = Ankor Wat -> WorldMapGo_NativesVillage_AngkorWat (route $1B).

WorldMapMenu_13 {
    COP [PrintDialogString] ( &dialogstring_03B753 )
    COP [DialogueOptions] ( #32, #01, &code_list_03B74B )

  loc_03B749:
    COP [RestoreSavedPtr]
}

code_list_03B74B [
  &WorldMapQuit_NativesVillage   ;00
  &WorldMapQuit_NativesVillage   ;01
  &WorldMapGo_NativesVillage_Euro   ;02
  &WorldMapGo_NativesVillage_AngkorWat   ;03
]

dialogstring_03B753 `[TPL:11][SFX:0] Quit        Ankor Wat [N] Euro city `

---------------------------------------------
; Choice $14: Quit / Natives' Village (Ankor Wat entrance exit). List: Quit -> WorldMapQuit_AngkorWat (back to Ankor Wat); 2 -> WorldMapGo_AngkorWat_NativesVillage (route $1C).

WorldMapMenu_14 {
    COP [PrintDialogString] ( &dialogstring_03B78A )
    COP [DialogueOptions] ( #02, #01, &code_list_03B784 )

  loc_03B782:
    COP [RestoreSavedPtr]
}

code_list_03B784 [
  &WorldMapQuit_AngkorWat   ;00
  &WorldMapQuit_AngkorWat   ;01
  &WorldMapGo_AngkorWat_NativesVillage   ;02
]

dialogstring_03B78A `[TPL:11][SFX:0] Quit [N] Natives' Village `

---------------------------------------------
; Choice $15: Quit only (Angel Village exit, default). Quit -> WorldMapQuit_AngelVillage (back to Angel Village).

WorldMapMenu_15 {
    COP [PrintDialogString] ( &dialogstring_03B597 )
    COP [DialogueOptions] ( #01, #01, &code_list_03B7B1 )

  loc_03B7AF:
    COP [RestoreSavedPtr]
}

code_list_03B7B1 [
  &WorldMapQuit_AngelVillage   ;00
  &WorldMapQuit_AngelVillage   ;01
]

---------------------------------------------
; Choice $16: Quit / Natives' Village (Dao exit, default). List: Quit -> WorldMapQuit_Dao (back to Dao); 2 -> WorldMapGo_Dao_NativesVillage (route $20).

WorldMapMenu_16 {
    COP [PrintDialogString] ( &dialogstring_03B7C7 )
    COP [DialogueOptions] ( #02, #01, &code_list_03B7C1 )

  loc_03B7BF:
    COP [RestoreSavedPtr]
}

code_list_03B7C1 [
  &WorldMapQuit_Dao   ;00
  &WorldMapQuit_Dao   ;01
  &WorldMapGo_Dao_NativesVillage   ;02
]

dialogstring_03B7C7 `[TPL:11][SFX:0] Quit [N] Natives' Village `

---------------------------------------------
; Choice $17: Quit / Pyramid / Natives' Village, grid #32 (Dao exit after flag $B4). List: Quit -> WorldMapQuit_Dao; 2 = Natives' Village -> WorldMapGo_Dao_NativesVillage (route $20); 3 = Pyramid -> WorldMapGo_Dao_Pyramid (route $1E).

WorldMapMenu_17 {
    COP [PrintDialogString] ( &dialogstring_03B7F6 )
    COP [DialogueOptions] ( #32, #01, &code_list_03B7EE )

  loc_03B7EC:
    COP [RestoreSavedPtr]
}

code_list_03B7EE [
  &WorldMapQuit_Dao   ;00
  &WorldMapQuit_Dao   ;01
  &WorldMapGo_Dao_NativesVillage   ;02
  &WorldMapGo_Dao_Pyramid   ;03
]

dialogstring_03B7F6 `[TPL:11][SFX:0] Quit        Pyramid [N] Natives' Village `

---------------------------------------------
; Choice $18: Quit / Dao Village (Pyramid exit). List: Quit -> WorldMapQuit_Pyramid (back to the pyramid); 2 -> WorldMapGo_Pyramid_Dao (route $1F).

WorldMapMenu_18 {
    COP [PrintDialogString] ( &dialogstring_03B82C )
    COP [DialogueOptions] ( #02, #01, &code_list_03B826 )

  loc_03B824:
    COP [RestoreSavedPtr]
}

code_list_03B826 [
  &WorldMapQuit_Pyramid   ;00
  &WorldMapQuit_Pyramid   ;01
  &WorldMapGo_Pyramid_Dao   ;02
]

dialogstring_03B82C `[TPL:11][SFX:0] Quit[N] Dao Village`

---------------------------------------------
; Choice $19: Quit / Ankor Wat / Euro city / Dao Village, grid #42 (Natives' Village exit after flag $B6). List: Quit -> WorldMapQuit_NativesVillage; 2 = Euro city -> WorldMapGo_NativesVillage_Euro; 3 = Ankor Wat -> WorldMapGo_NativesVillage_AngkorWat; 4 = Dao -> WorldMapGo_NativesVillage_Dao (route $1D).

WorldMapMenu_19 {
    COP [PrintDialogString] ( &dialogstring_03B859 )
    COP [DialogueOptions] ( #42, #01, &code_list_03B84F )

  loc_03B84D:
    COP [RestoreSavedPtr]
}

code_list_03B84F [
  &WorldMapQuit_NativesVillage   ;00
  &WorldMapQuit_NativesVillage   ;01
  &WorldMapGo_NativesVillage_Euro   ;02
  &WorldMapGo_NativesVillage_AngkorWat   ;03
  &WorldMapGo_NativesVillage_Dao   ;04
]

dialogstring_03B859 `[TPL:11][SFX:0] Quit        Ankor Wat [N] Euro city   Dao Village `

---------------------------------------------
; Choice $1A: Quit / Mt.Temple / Watermia / Natives' Village, grid #42 (Euro exit after flag $AC). List: Quit -> WorldMapQuit_Euro; 2 = Watermia -> WorldMapGo_Euro_Watermia; 3 = Mt.Temple -> WorldMapGo_Euro_MtTemple; 4 = Natives' Village -> WorldMapGo_Euro_NativesVillage (route $19).

WorldMapMenu_1A {
    COP [PrintDialogString] ( &dialogstring_03B8A2 )
    COP [DialogueOptions] ( #42, #01, &code_list_03B898 )

  loc_03B896:
    COP [RestoreSavedPtr]
}

code_list_03B898 [
  &WorldMapQuit_Euro   ;00
  &WorldMapQuit_Euro   ;01
  &WorldMapGo_Euro_Watermia   ;02
  &WorldMapGo_Euro_MtTemple   ;03
  &WorldMapGo_Euro_NativesVillage   ;04
]

dialogstring_03B8A2 `[TPL:11][SFX:0] Quit        Mt.Temple [N] Watermia    Natives' Vil.`

---------------------------------------------
; Choice $1B: Quit only (South Cape exit). Quit -> WorldMapQuit_SouthCape (back to South Cape).

WorldMapMenu_1B {
    COP [PrintDialogString] ( &dialogstring_03B597 )
    COP [DialogueOptions] ( #01, #01, &code_list_03B8E2 )

  loc_03B8E0:
    COP [RestoreSavedPtr]
}

code_list_03B8E2 [
  &WorldMapQuit_SouthCape   ;00
  &WorldMapQuit_SouthCape   ;01
]

---------------------------------------------
; Choice $1C: prints an empty [TPL:11] and returns. No site stages this id; staging it would run this entry (the controller keeps the low 5 bits of the choice id).

WorldMapMenu_Empty1C {
    COP [PrintDialogString] ( &dialogstring_03B92B )
    COP [RestoreSavedPtr]
}

---------------------------------------------
; Choice $1D: prints an empty [TPL:11] and returns. No site stages this id; staging it would run this entry (the controller keeps the low 5 bits of the choice id).

WorldMapMenu_Empty1D {
    COP [PrintDialogString] ( &dialogstring_03B92E )
    COP [RestoreSavedPtr]
}

---------------------------------------------
; Choice $1E: prints an empty [TPL:11] and returns. No site stages this id; staging it would run this entry (the controller keeps the low 5 bits of the choice id).

WorldMapMenu_Empty1E {
    COP [PrintDialogString] ( &dialogstring_03B931 )
    COP [RestoreSavedPtr]
}

---------------------------------------------
; Choice $1F: prints an empty [TPL:11] and returns. No site stages this id; staging it would run this entry (the controller keeps the low 5 bits of the choice id).

WorldMapMenu_Empty1F {
    COP [PrintDialogString] ( &dialogstring_03B934 )
    COP [RestoreSavedPtr]
}

---------------------------------------------
; Choice $20: prints an empty [TPL:11] and returns. No id reaches this entry: the controller masks the choice id with AND #$001F, so the table index is at most $1F.

WorldMapMenu_Empty20 {
    COP [PrintDialogString] ( &dialogstring_03B937 )
    COP [RestoreSavedPtr]
}

---------------------------------------------
; Choice $21: prints an empty [TPL:11] and returns. No id reaches this entry: the controller masks the choice id with AND #$001F, so the table index is at most $1F.

WorldMapMenu_Empty21 {
    COP [PrintDialogString] ( &dialogstring_03B93A )
    COP [RestoreSavedPtr]
}

---------------------------------------------
; Choice $22: prints an empty [TPL:11] and returns. No id reaches this entry: the controller masks the choice id with AND #$001F, so the table index is at most $1F.

WorldMapMenu_Empty22 {
    COP [PrintDialogString] ( &dialogstring_03B93D )
    COP [RestoreSavedPtr]
}

---------------------------------------------
; Choice $23: prints an empty [TPL:11] and returns. No id reaches this entry: the controller masks the choice id with AND #$001F, so the table index is at most $1F.

WorldMapMenu_Empty23 {
    COP [PrintDialogString] ( &dialogstring_03B940 )
    COP [RestoreSavedPtr]
}

---------------------------------------------
; Choice $24: prints an empty [TPL:11] and returns. No id reaches this entry: the controller masks the choice id with AND #$001F, so the table index is at most $1F.

WorldMapMenu_Empty24 {
    COP [PrintDialogString] ( &dialogstring_03B943 )
    COP [RestoreSavedPtr]
}

---------------------------------------------
; Choice $25: prints an empty [TPL:11] and returns. No id reaches this entry: the controller masks the choice id with AND #$001F, so the table index is at most $1F.

WorldMapMenu_Empty25 {
    COP [PrintDialogString] ( &dialogstring_03B946 )
    COP [RestoreSavedPtr]
}

---------------------------------------------
; Choice $26: prints Nothing!! and returns. No id reaches this entry: the controller masks the choice id with AND #$001F, so the table index is at most $1F.

WorldMapMenu_Nothing26 {
    COP [PrintDialogString] ( &dialogstring_03B949 )
    COP [RestoreSavedPtr]
}

---------------------------------------------
; Blank [TPL:11] string, like dialogstring_03B92B. Nothing references it.

dialogstring_03B928 `[TPL:11]`

dialogstring_03B92B `[TPL:11]`

dialogstring_03B92E `[TPL:11]`

dialogstring_03B931 `[TPL:11]`

dialogstring_03B934 `[TPL:11]`

dialogstring_03B937 `[TPL:11]`

dialogstring_03B93A `[TPL:11]`

dialogstring_03B93D `[TPL:11]`

dialogstring_03B940 `[TPL:11]`

dialogstring_03B943 `[TPL:11]`

dialogstring_03B946 `[TPL:11]`

dialogstring_03B949 `[TPL:11]Nothing!![END]`

---------------------------------------------
; Route $02 (Edward's Castle to South Cape), then falls into WorldMapQuit_SouthCape.

WorldMapGo_EdwardCastle_SouthCape {
    COP [StageWorldMapMoveIds] ( #00, #02 )
}

---------------------------------------------
; Queue scene $01 South Cape at (376, 64), facing 3, scroll $4300. Quit handler of the South Cape menus and the target of route $02.

WorldMapQuit_SouthCape {
    COP [QueueMapChange] ( #01, #$0178, #$0040, #03, #$4300 )
    COP [RestoreSavedPtr]
}

---------------------------------------------
; Route $01 (South Cape to Edward's Castle), then falls into WorldMapQuit_EdwardCastle.

WorldMapGo_SouthCape_EdwardCastle {
    COP [StageWorldMapMoveIds] ( #00, #01 )
}

---------------------------------------------
; Queue scene $0A Edward's Castle at (504, 704), facing 0, scroll $3420. Quit handler of the Edward's Castle menu.

WorldMapQuit_EdwardCastle {
    COP [QueueMapChange] ( #0A, #$01F8, #$02C0, #00, #$3420 )
    COP [RestoreSavedPtr]
}

---------------------------------------------
; Route $03 (South Cape to Itory Village), then falls into WorldMapQuit_Itory.

WorldMapGo_SouthCape_Itory {
    COP [StageWorldMapMoveIds] ( #00, #03 )
}

---------------------------------------------
; Queue scene $15 Itory Village at (728, 688), facing 0, scroll $3500. Quit handler of the Itory menus.

WorldMapQuit_Itory {
    COP [QueueMapChange] ( #15, #$02D8, #$02B0, #00, #$3500 )
    COP [RestoreSavedPtr]
}

---------------------------------------------
; Route $04 (Itory Village to South Cape) and the queue for scene $01 South Cape (same operands as WorldMapQuit_SouthCape) in one block.

WorldMapGo_Itory_SouthCape {
    COP [StageWorldMapMoveIds] ( #00, #04 )
    COP [QueueMapChange] ( #01, #$0178, #$0040, #03, #$4300 )
    COP [RestoreSavedPtr]
}

---------------------------------------------
; Route $08 (Inca Ruins to Itory Village), then falls into WorldMapQuit_Itory_IncaMenu.

WorldMapGo_IncaRuins_Itory {
    COP [StageWorldMapMoveIds] ( #00, #08 )
}

---------------------------------------------
; Queue scene $15 Itory Village (same operands as WorldMapQuit_Itory). Quit handler of the Itory menu with the Inca Ruins option.

WorldMapQuit_Itory_IncaMenu {
    COP [QueueMapChange] ( #15, #$02D8, #$02B0, #00, #$3500 )
    COP [RestoreSavedPtr]
}

---------------------------------------------
; Route $07 (Itory Village to Inca Ruins), then falls into WorldMapQuit_IncaRuins.

WorldMapGo_Itory_IncaRuins {
    COP [StageWorldMapMoveIds] ( #00, #07 )
}

---------------------------------------------
; Queue scene $1C Inca Ruins at (104, 416), flags $80 (revive / save point), scroll $2200. Quit handler of the Inca Ruins menu.

WorldMapQuit_IncaRuins {
    COP [QueueMapChange] ( #1C, #$0068, #$01A0, #80, #$2200 )
    COP [RestoreSavedPtr]
}

---------------------------------------------
; Route $0A (Freejia to Diamond Mine), then falls into WorldMapQuit_DiamondMine.

WorldMapGo_Freejia_DiamondMine {
    COP [StageWorldMapMoveIds] ( #00, #0A )
}

---------------------------------------------
; Queue scene $3E Diamond Mine at (168, 976), flags $80 (revive / save point), scroll $4200. Quit handler of the mine menu.

WorldMapQuit_DiamondMine {
    COP [QueueMapChange] ( #3E, #$00A8, #$03D0, #80, #$4200 )
    COP [RestoreSavedPtr]
}

---------------------------------------------
; Route $0B (Diamond Mine to Freejia), then falls into WorldMapQuit_Freejia.

WorldMapGo_DiamondMine_Freejia {
    COP [StageWorldMapMoveIds] ( #00, #0B )
}

---------------------------------------------
; Queue scene $32 Freejia at (304, 848), facing 0, scroll $4500. Quit handler of the Freejia menus.

WorldMapQuit_Freejia {
    COP [QueueMapChange] ( #32, #$0130, #$0350, #00, #$4500 )
    COP [RestoreSavedPtr]
}

---------------------------------------------
; Route $11 (Angel Village to Watermia), then falls into WorldMapQuit_Watermia_AngelMenu.

WorldMapGo_AngelVillage_Watermia {
    COP [StageWorldMapMoveIds] ( #00, #11 )
}

---------------------------------------------
; Queue scene $78 Watermia at (632, 912), facing 0, scroll $4500. Quit handler of the Angel Village-side Watermia menu ($0B).

WorldMapQuit_Watermia_AngelMenu {
    COP [QueueMapChange] ( #78, #$0278, #$0390, #00, #$4500 )
    COP [RestoreSavedPtr]
}

---------------------------------------------
; Route $12 (Watermia to Angel Village), then falls into WorldMapQuit_AngelVillage.

WorldMapGo_Watermia_AngelVillage {
    COP [StageWorldMapMoveIds] ( #00, #12 )
}

---------------------------------------------
; Queue scene $69 Angel Village at (672, 192), facing 0, scroll $1300. Quit handler of the Angel Village menus.

WorldMapQuit_AngelVillage {
    COP [QueueMapChange] ( #69, #$02A0, #$00C0, #00, #$1300 )
    COP [RestoreSavedPtr]
}

---------------------------------------------
; Route $13 (Watermia to Great Wall), then falls into WorldMapQuit_GreatWall.

WorldMapGo_Watermia_GreatWall {
    COP [StageWorldMapMoveIds] ( #00, #13 )
}

---------------------------------------------
; Queue scene $82 Great Wall at (32, 144), flags $87 (revive / save point, facing 7), scroll $1800. Quit handler of the Great Wall menu.

WorldMapQuit_GreatWall {
    COP [QueueMapChange] ( #82, #$0020, #$0090, #87, #$1800 )
    COP [RestoreSavedPtr]
}

---------------------------------------------
; Route $14 (Great Wall to Watermia), then falls into WorldMapQuit_Watermia.

WorldMapGo_GreatWall_Watermia {
    COP [StageWorldMapMoveIds] ( #00, #14 )
}

---------------------------------------------
; Queue scene $78 Watermia (same operands as WorldMapQuit_Watermia_AngelMenu). Quit handler of the Watermia menus.

WorldMapQuit_Watermia {
    COP [QueueMapChange] ( #78, #$0278, #$0390, #00, #$4500 )
    COP [RestoreSavedPtr]
}

---------------------------------------------
; Leader animation $0D60 := 7, route $15 (Watermia to Euro), then falls into WorldMapQuit_Euro.

WorldMapGo_Watermia_Euro {
    LDA #$0007
    STA $0D60             ; Leader animation 7 (also the first of the wa79_neil 7/8/9/A set) for the Watermia to Euro leg
    COP [StageWorldMapMoveIds] ( #00, #15 )
}

---------------------------------------------
; Queue scene $91 Euro at (976, 1072), facing 6, scroll $5400. Quit handler of the Euro menus.

WorldMapQuit_Euro {
    COP [QueueMapChange] ( #91, #$03D0, #$0430, #06, #$5400 )
    COP [RestoreSavedPtr]
}

---------------------------------------------
; Leader animation $0D60 := 7, route $16 (Euro to Watermia) and the queue for scene $78 Watermia (same operands as WorldMapQuit_Watermia_AngelMenu) in one block.

WorldMapGo_Euro_Watermia {
    LDA #$0007
    STA $0D60             ; Leader animation 7 for the Euro to Watermia leg
    COP [StageWorldMapMoveIds] ( #00, #16 )
    COP [QueueMapChange] ( #78, #$0278, #$0390, #00, #$4500 )
    COP [RestoreSavedPtr]
}

---------------------------------------------
; Route $17 (Euro to Mt.Temple), then falls into WorldMapQuit_MtTemple.

WorldMapGo_Euro_MtTemple {
    COP [StageWorldMapMoveIds] ( #00, #17 )
}

---------------------------------------------
; Queue scene $A0 Mt.Temple entrance at (712, 432), flags $86 (revive / save point, facing 6), scroll $2300. Quit handler of the Mt.Temple menu.

WorldMapQuit_MtTemple {
    COP [QueueMapChange] ( #A0, #$02C8, #$01B0, #86, #$2300 )
    COP [RestoreSavedPtr]
}

---------------------------------------------
; Route $18 (Mt.Temple to Euro) and the queue for scene $91 Euro (same operands as WorldMapQuit_Euro) in one block.

WorldMapGo_MtTemple_Euro {
    COP [StageWorldMapMoveIds] ( #00, #18 )
    COP [QueueMapChange] ( #91, #$03D0, #$0430, #06, #$5400 )
    COP [RestoreSavedPtr]
}

---------------------------------------------
; Route $19 (Euro to Natives' Village), then falls into WorldMapQuit_NativesVillage.

WorldMapGo_Euro_NativesVillage {
    COP [StageWorldMapMoveIds] ( #00, #19 )
}

---------------------------------------------
; Queue scene $AC Natives' Village at (448, 464), facing 6, scroll $2200. Quit handler of the Natives' Village menus.

WorldMapQuit_NativesVillage {
    COP [QueueMapChange] ( #AC, #$01C0, #$01D0, #06, #$2200 )
    COP [RestoreSavedPtr]
}

---------------------------------------------
; Route $1A (Natives' Village to Euro) and the queue for scene $91 Euro (same operands as WorldMapQuit_Euro) in one block.

WorldMapGo_NativesVillage_Euro {
    COP [StageWorldMapMoveIds] ( #00, #1A )
    COP [QueueMapChange] ( #91, #$03D0, #$0430, #06, #$5400 )
    COP [RestoreSavedPtr]
}

---------------------------------------------
; Route $1B (Natives' Village to Ankor Wat), then falls into WorldMapQuit_AngkorWat.

WorldMapGo_NativesVillage_AngkorWat {
    COP [StageWorldMapMoveIds] ( #00, #1B )
}

---------------------------------------------
; Queue scene $B0 Ankor Wat at (504, 1216), flags $80 (revive / save point), scroll $5400. Quit handler of the Ankor Wat menu.

WorldMapQuit_AngkorWat {
    COP [QueueMapChange] ( #B0, #$01F8, #$04C0, #80, #$5400 )
    COP [RestoreSavedPtr]
}

---------------------------------------------
; Route $1C (Ankor Wat to Natives' Village) and the queue for scene $AC (same operands as WorldMapQuit_NativesVillage) in one block.

WorldMapGo_AngkorWat_NativesVillage {
    COP [StageWorldMapMoveIds] ( #00, #1C )
    COP [QueueMapChange] ( #AC, #$01C0, #$01D0, #06, #$2200 )
    COP [RestoreSavedPtr]
}

---------------------------------------------
; Route $20 (Dao to Natives' Village) and the queue for scene $AC (same operands as WorldMapQuit_NativesVillage) in one block.

WorldMapGo_Dao_NativesVillage {
    COP [StageWorldMapMoveIds] ( #00, #20 )
    COP [QueueMapChange] ( #AC, #$01C0, #$01D0, #06, #$2200 )
    COP [RestoreSavedPtr]
}

---------------------------------------------
; Route $1E (Dao to Pyramid), then falls into WorldMapQuit_Pyramid.

WorldMapGo_Dao_Pyramid {
    COP [StageWorldMapMoveIds] ( #00, #1E )
}

---------------------------------------------
; Queue scene $CC Pyramid at (16, 208), flags $87 (revive / save point, facing 7), scroll $4400. Quit handler of the Pyramid menu.

WorldMapQuit_Pyramid {
    COP [QueueMapChange] ( #CC, #$0010, #$00D0, #87, #$4400 )
    COP [RestoreSavedPtr]
}

---------------------------------------------
; Route $1D (Natives' Village to Dao), then falls into WorldMapQuit_Dao.

WorldMapGo_NativesVillage_Dao {
    COP [StageWorldMapMoveIds] ( #00, #1D )
}

---------------------------------------------
; Queue scene $C3 Dao at (16, 224), facing 7, scroll $2300. Quit handler of the Dao menus.

WorldMapQuit_Dao {
    COP [QueueMapChange] ( #C3, #$0010, #$00E0, #07, #$2300 )
    COP [RestoreSavedPtr]
}

---------------------------------------------
; Route $1F (Pyramid to Dao) and the queue for scene $C3 Dao (same operands as WorldMapQuit_Dao) in one block.

WorldMapGo_Pyramid_Dao {
    COP [StageWorldMapMoveIds] ( #00, #1F )
    COP [QueueMapChange] ( #C3, #$0010, #$00E0, #07, #$2300 )
    COP [RestoreSavedPtr]
}