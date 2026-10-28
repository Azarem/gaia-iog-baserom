; Debug Man - an unused developer NPC that maxes the player's stats and offers a warp menu with 21 destinations (Bank 0B, 781856-782712). No scene script, scene_actors record or spawn call in extracted/ references it, so it never appears in the retail game.
; 
; === STRUCTURE ===
; 
; The actor-def (sprite index 2, flags 0, header byte $10) entry runs once: MarkSolidHere, SetInteractHandler(DebugManInteract), SetEntryHere, RTL. Nothing runs per frame afterwards; talking to the NPC starts DebugManInteract.
; DebugManInteract writes max HP and HP = 40, STR and DEF = 127 (16-bit stores, so the high bytes become 0) and abilityBitmask = $FF (all abilities), prints the greeting and opens the first menu. It does this on every conversation, so talking to Debug Man again resets the stats to those values.
; 
; === MENU CHAIN ===
; 
; The menu is 7 levels. Each level is PrintDialogString (one page of 4 rows) followed by COP DialogueOptions( #04, #00, table ): the two operand bytes form the menu-layout word handed to MenuSelectionHandler, which returns 0 for B (cancel) or the confirmed row + 1. DialogueOptions uses that as the index into the word table and resumes the script there. Every table therefore has 5 entries: [0] = DebugManQuit (B), [1] to [4] = rows 1 to 4.
; Row 1 of levels 1 to 6 is 'Others' and opens the next level; rows 2 to 4 are destinations. Level 7 has 'Quit' as row 1 (table entries 0 and 1 are both DebugManQuit) and three destinations.
; A destination leaf prints 'Ok! See you again!', queues the scene change with COP QueueMapChange( scene, X px, Y px, facing, scroll params ) and returns with RTL. The facing byte is an index into walk_step_table (it selects the first sprite frame of the spawned player). The leaves change no stats and no flags.
; 
; === DESTINATIONS (scene id, then the leaf label) ===
; 
; Level 1: Great Wall $82 (DebugWarpGreatWall), LAST GAIA LOOK = the ending sequence $E5 (DebugWarpLastGaiaLook), EDOWA-DO = Edward Castle $0A (DebugWarpEdowaDo). The ROM order of the last two leaves is the reverse of the row order; the table maps row 3 to the $E5 leaf and row 4 to the $0A leaf.
; Level 2: Itory Village $15, Moon Tribe camp $1A, underground castle $0F. Level 3: Euro $91, Natives' Village $AC, Dao $C3. Level 4: Inca Ruins $1C, Freejia $32 (HANANOMIYAKO), Diamond Mine $3E (DAIYAMONDO).
; Level 5: Sky Garden $4C, Seaside Palace $5A, Mu $5F. Level 6: Angel Village $69, a second entry point of Natives' Village $AC and of Dao $C3. Level 7: Pyramid $CC, Watermia $78, Angkor Wat $B0.
; That is 21 leaves; the old header said about 35 destinations, and the old labels for $32 (Gold Ship) and $3E (Diamond Coast) and the swapped $0A / $E5 comments were wrong.
---------------------------------------------

!abilityBitmask                 0AA2
!playerMaxHp                    0ACA
!playerHp                       0ACE
!playerDef                      0ADC
!playerStr                      0ADE

---------------------------------------------

; Actor definition: sprite index 2, flags 0, header byte $10. The body is the single label DebugManEntry.

debug_man [
  actor-def < #02, #00, #10, {

; One-shot entry: solid NPC, interact handler = DebugManInteract, SetEntryHere, RTL. Nothing runs afterwards.

  DebugManEntry:
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &DebugManInteract )
    COP [SetEntryHere]
    RTL 
} >
]

---------------------------------------------
; Talk handler: HP and max HP := 40, STR and DEF := 127, abilityBitmask := $FF, greeting, then the level 1 menu (table DebugMenuTable1). DialogueOptions resumes the script at the chosen table entry, so the handler never returns here; the leaf or DebugManQuit does the RTL.

DebugManInteract {
    LDA #$0028            ; MaxHP & HP = 40
    STA $playerMaxHp
    STA $playerHp
    LDA #$007F            ; STR & DEF = 127
    STA $playerStr
    STA $playerDef
    LDA #$00FF            ; Unlock all abilities
    STA $abilityBitmask
    COP [PrintDialogString] ( &dialogstring_0BF010 ) ; "Hello! I am Debug-man!"
    COP [DialogueOptions] ( #04, #00, &DebugMenuTable1 ) ; Menu word $0004 (4 rows); table entry 0 = B cancel (DebugManQuit), entries 1 to 4 = rows 1 to 4 (the confirmed row + 1)
}

---------------------------------------------
; Level 1 branch table: [0] B = DebugManQuit, [1] Others = DebugMenuLevel2 (level 2), [2] Great Wall, [3] LAST GAIA LOOK ($E5 leaf), [4] EDOWA-DO ($0A leaf).

DebugMenuTable1 [
  &DebugManQuit   ;00
  &DebugMenuLevel2   ;01
  &DebugWarpGreatWall   ;02
  &DebugWarpLastGaiaLook   ;03
  &DebugWarpEdowaDo   ;04
]

---------------------------------------------
; Level 2 page and menu: Others / Itorie / HOME OF MOON TRIBE / Underground castle (dialogstring_0BF05C, table DebugMenuTable2).

DebugMenuLevel2 {
    COP [PrintDialogString] ( &dialogstring_0BF05C )
    COP [DialogueOptions] ( #04, #00, &DebugMenuTable2 )
}

---------------------------------------------
; Level 2 branch table: [0] B = DebugManQuit, [1] Others = DebugMenuLevel3 (level 3), [2] to [4] = Itory, Moon Tribe, underground castle leaves.

DebugMenuTable2 [
  &DebugManQuit   ;00
  &DebugMenuLevel3   ;01
  &DebugWarpItory   ;02
  &DebugWarpMoonTribe   ;03
  &DebugWarpUndergroundCastle   ;04
]

---------------------------------------------
; Level 3 page and menu: Others / City of Euro / Native's Village / Desert Village Dao (dialogstring_0BF095, table DebugMenuTable3).

DebugMenuLevel3 {
    COP [PrintDialogString] ( &dialogstring_0BF095 )
    COP [DialogueOptions] ( #04, #00, &DebugMenuTable3 )
}

---------------------------------------------
; Level 3 branch table: [0] B = DebugManQuit, [1] Others = DebugMenuLevel4 (level 4), [2] to [4] = Euro, Natives' Village, Dao leaves.

DebugMenuTable3 [
  &DebugManQuit   ;00
  &DebugMenuLevel4   ;01
  &DebugWarpEuro   ;02
  &DebugWarpNativesVillage   ;03
  &DebugWarpDao   ;04
]

---------------------------------------------
; Level 4 page and menu: Others / INCA / HANANOMIYAKO / DAIYAMONDO (dialogstring_0BF0C3, table DebugMenuTable4).

DebugMenuLevel4 {
    COP [PrintDialogString] ( &dialogstring_0BF0C3 )
    COP [DialogueOptions] ( #04, #00, &DebugMenuTable4 )
}

---------------------------------------------
; Level 4 branch table: [0] B = DebugManQuit, [1] Others = DebugMenuLevel5 (level 5), [2] to [4] = Inca Ruins, Freejia, Diamond Mine leaves.

DebugMenuTable4 [
  &DebugManQuit   ;00
  &DebugMenuLevel5   ;01
  &DebugWarpInca   ;02
  &DebugWarpFreejia   ;03
  &DebugWarpDiamondMine   ;04
]

---------------------------------------------
; Level 5 page and menu: Others / Sky Garden / Palace / Mu (dialogstring_0BF0EC, table DebugMenuTable5).

DebugMenuLevel5 {
    COP [PrintDialogString] ( &dialogstring_0BF0EC )
    COP [DialogueOptions] ( #04, #00, &DebugMenuTable5 )
}

---------------------------------------------
; Level 5 branch table: [0] B = DebugManQuit, [1] Others = DebugMenuLevel6 (level 6), [2] to [4] = Sky Garden, Palace, Mu leaves.

DebugMenuTable5 [
  &DebugManQuit   ;00
  &DebugMenuLevel6   ;01
  &DebugWarpSkyGarden   ;02
  &DebugWarpSeasidePalace   ;03
  &DebugWarpMu   ;04
]

---------------------------------------------
; Level 6 page and menu: Others / Angel Village / Native's Village / Dao (dialogstring_0BF10D, table DebugMenuTable6).

DebugMenuLevel6 {
    COP [PrintDialogString] ( &dialogstring_0BF10D )
    COP [DialogueOptions] ( #04, #00, &DebugMenuTable6 )
}

---------------------------------------------
; Level 6 branch table: [0] B = DebugManQuit, [1] Others = DebugMenuLevel7 (level 7), [2] to [4] = Angel Village and the second Natives' Village and Dao entry points.

DebugMenuTable6 [
  &DebugManQuit   ;00
  &DebugMenuLevel7   ;01
  &DebugWarpAngelVillage   ;02
  &DebugWarpNativesVillageAlt   ;03
  &DebugWarpDaoAlt   ;04
]

---------------------------------------------
; Level 7 (last) page and menu: Quit / Pyramid / Watermia / Ankor Wat (dialogstring_0BF135, table DebugMenuTable7).

DebugMenuLevel7 {
    COP [PrintDialogString] ( &dialogstring_0BF135 )
    COP [DialogueOptions] ( #04, #00, &DebugMenuTable7 )
}

---------------------------------------------
; Level 7 branch table: [0] B and [1] Quit both = DebugManQuit, [2] to [4] = Pyramid, Watermia, Ankor Wat leaves.

DebugMenuTable7 [
  &DebugManQuit   ;00
  &DebugManQuit   ;01
  &DebugWarpPyramid   ;02
  &DebugWarpWatermia   ;03
  &DebugWarpAngkorWat   ;04
]

---------------------------------------------
; Prints 'Bye bye!' and returns. Target of B (entry 0) at every level and of row 1 at level 7.

DebugManQuit {
    COP [PrintDialogString] ( &dialogstring_0BF15A )
    RTL 
}

---------------------------------------------
; Leaf, level 1 row 2: Great Wall.

DebugWarpGreatWall {
    COP [PrintDialogString] ( &dialogstring_0BF164 ) ; Same confirmation string for all 21 leaves
    COP [QueueMapChange] ( #82, #$0020, #$0090, #07, #$1800 ) ; Great Wall: scene $82, X $0020, Y $0090, facing 7, scroll params $1800
    RTL 
}

---------------------------------------------
; Leaf, level 1 row 4: EDOWA-DO (Edward Castle).

DebugWarpEdowaDo {
    COP [PrintDialogString] ( &dialogstring_0BF164 )
    COP [QueueMapChange] ( #0A, #$01E3, #$00A0, #03, #$4500 ) ; EDOWA-DO = Edward Castle: scene $0A, X $01E3, Y $00A0, facing 3, scroll params $4500
    RTL 
}

---------------------------------------------
; Leaf, level 1 row 3: LAST GAIA LOOK (the ending sequence).

DebugWarpLastGaiaLook {
    COP [PrintDialogString] ( &dialogstring_0BF164 )
    COP [QueueMapChange] ( #E5, #$00A8, #$00A0, #00, #$1100 ) ; LAST GAIA LOOK = ending sequence: scene $E5, X $00A8, Y $00A0, facing 0, scroll params $1100
    RTL 
}

---------------------------------------------
; Leaf, level 2 row 2: Itory Village.

DebugWarpItory {
    COP [PrintDialogString] ( &dialogstring_0BF164 )
    COP [QueueMapChange] ( #15, #$0339, #$01B0, #00, #$3500 ) ; Itory Village: scene $15, X $0339, Y $01B0, facing 0, scroll params $3500
    RTL 
}

---------------------------------------------
; Leaf, level 2 row 3: Moon Tribe camp.

DebugWarpMoonTribe {
    COP [PrintDialogString] ( &dialogstring_0BF164 )
    COP [QueueMapChange] ( #1A, #$0110, #$00C3, #00, #$2200 ) ; Moon Tribe camp: scene $1A, X $0110, Y $00C3, facing 0, scroll params $2200
    RTL 
}

---------------------------------------------
; Leaf, level 2 row 4: underground castle.

DebugWarpUndergroundCastle {
    COP [PrintDialogString] ( &dialogstring_0BF164 )
    COP [QueueMapChange] ( #0F, #$0078, #$05D0, #00, #$6100 ) ; Underground castle: scene $0F, X $0078, Y $05D0, facing 0, scroll params $6100
    RTL 
}

---------------------------------------------
; Leaf, level 3 row 2: Euro.

DebugWarpEuro {
    COP [PrintDialogString] ( &dialogstring_0BF164 )
    COP [QueueMapChange] ( #91, #$0370, #$0430, #03, #$5400 ) ; Euro: scene $91, X $0370, Y $0430, facing 3, scroll params $5400
    RTL 
}

---------------------------------------------
; Leaf, level 3 row 3: Natives' Village.

DebugWarpNativesVillage {
    COP [PrintDialogString] ( &dialogstring_0BF164 )
    COP [QueueMapChange] ( #AC, #$01C0, #$01D0, #07, #$2200 ) ; Natives' Village: scene $AC, X $01C0, Y $01D0, facing 7, scroll params $2200
    RTL 
}

---------------------------------------------
; Leaf, level 3 row 4: Dao.

DebugWarpDao {
    COP [PrintDialogString] ( &dialogstring_0BF164 )
    COP [QueueMapChange] ( #C3, #$0010, #$00E8, #07, #$2300 ) ; Dao: scene $C3, X $0010, Y $00E8, facing 7, scroll params $2300
    RTL 
}

---------------------------------------------
; Leaf, level 4 row 2: Inca Ruins.

DebugWarpInca {
    COP [PrintDialogString] ( &dialogstring_0BF164 )
    COP [QueueMapChange] ( #1C, #$006C, #$0174, #07, #$2200 ) ; Inca Ruins: scene $1C, X $006C, Y $0174, facing 7, scroll params $2200
    RTL 
}

---------------------------------------------
; Leaf, level 4 row 3: Freejia (HANANOMIYAKO).

DebugWarpFreejia {
    COP [PrintDialogString] ( &dialogstring_0BF164 )
    COP [QueueMapChange] ( #32, #$0138, #$0360, #07, #$4500 ) ; Freejia: scene $32, X $0138, Y $0360, facing 7, scroll params $4500
    RTL 
}

---------------------------------------------
; Leaf, level 4 row 4: Diamond Mine (DAIYAMONDO).

DebugWarpDiamondMine {
    COP [PrintDialogString] ( &dialogstring_0BF164 )
    COP [QueueMapChange] ( #3E, #$00B0, #$03D0, #07, #$4200 ) ; Diamond Mine: scene $3E, X $00B0, Y $03D0, facing 7, scroll params $4200
    RTL 
}

---------------------------------------------
; Leaf, level 5 row 2: Sky Garden.

DebugWarpSkyGarden {
    COP [PrintDialogString] ( &dialogstring_0BF164 )
    COP [QueueMapChange] ( #4C, #$0100, #$0136, #07, #$2200 ) ; Sky Garden: scene $4C, X $0100, Y $0136, facing 7, scroll params $2200
    RTL 
}

---------------------------------------------
; Leaf, level 5 row 3: Seaside Palace.

DebugWarpSeasidePalace {
    COP [PrintDialogString] ( &dialogstring_0BF164 )
    COP [QueueMapChange] ( #5A, #$0088, #$00A0, #07, #$6400 ) ; Seaside Palace: scene $5A, X $0088, Y $00A0, facing 7, scroll params $6400
    RTL 
}

---------------------------------------------
; Leaf, level 5 row 4: Mu.

DebugWarpMu {
    COP [PrintDialogString] ( &dialogstring_0BF164 )
    COP [QueueMapChange] ( #5F, #$0088, #$0050, #07, #$4400 ) ; Mu: scene $5F, X $0088, Y $0050, facing 7, scroll params $4400
    RTL 
}

---------------------------------------------
; Leaf, level 6 row 2: Angel Village.

DebugWarpAngelVillage {
    COP [PrintDialogString] ( &dialogstring_0BF164 )
    COP [QueueMapChange] ( #69, #$02A8, #$00A0, #07, #$1300 ) ; Angel Village: scene $69, X $02A8, Y $00A0, facing 7, scroll params $1300
    RTL 
}

---------------------------------------------
; Leaf, level 6 row 3: Natives' Village (a second entry point).

DebugWarpNativesVillageAlt {
    COP [PrintDialogString] ( &dialogstring_0BF164 )
    COP [QueueMapChange] ( #AC, #$01C8, #$01E0, #07, #$2200 ) ; Natives' Village, second entry point: scene $AC, X $01C8, Y $01E0, facing 7, scroll params $2200
    RTL 
}

---------------------------------------------
; Leaf, level 6 row 4: Dao (a second entry point).

DebugWarpDaoAlt {
    COP [PrintDialogString] ( &dialogstring_0BF164 )
    COP [QueueMapChange] ( #C3, #$0020, #$00F0, #07, #$2300 ) ; Dao, second entry point: scene $C3, X $0020, Y $00F0, facing 7, scroll params $2300
    RTL 
}

---------------------------------------------
; Leaf, level 7 row 2: Pyramid.

DebugWarpPyramid {
    COP [PrintDialogString] ( &dialogstring_0BF164 )
    COP [QueueMapChange] ( #CC, #$002C, #$00E0, #07, #$4400 ) ; Pyramid: scene $CC, X $002C, Y $00E0, facing 7, scroll params $4400
    RTL 
}

---------------------------------------------
; Leaf, level 7 row 3: Watermia.

DebugWarpWatermia {
    COP [PrintDialogString] ( &dialogstring_0BF164 )
    COP [QueueMapChange] ( #78, #$027E, #$03A0, #07, #$4500 ) ; Watermia: scene $78, X $027E, Y $03A0, facing 7, scroll params $4500
    RTL 
}

---------------------------------------------
; Leaf, level 7 row 4: Ankor Wat.

DebugWarpAngkorWat {
    COP [PrintDialogString] ( &dialogstring_0BF164 )
    COP [QueueMapChange] ( #B0, #$0200, #$04D0, #07, #$5400 ) ; Angkor Wat: scene $B0, X $0200, Y $04D0, facing 7, scroll params $5400
    RTL 
}

---------------------------------------------
; Level 1 page: greeting 'Hello! I am Debug-man! Where you go?' followed by the four rows Others / Great Wall / LAST GAIA LOOK / EDOWA-DO.

dialogstring_0BF010 `[DEF]Hello! I am Debug-man![N]Where you go?[FIN] Others[N] Great Wall[N] LAST GAIA LOOK[N] EDOWA-DO`

---------------------------------------------
; Level 2 page (4 rows).

dialogstring_0BF05C `[CLR] Others[N] Itorie[N] HOME OF MOON TRIBE[N] Underground castle`

---------------------------------------------
; Level 3 page (4 rows).

dialogstring_0BF095 `[CLR] Others[N] City of Euro[N] Native's Village[N] Desert Village Dao`

---------------------------------------------
; Level 4 page (4 rows).

dialogstring_0BF0C3 `[CLR] Others[N] INCA[N] HANANOMIYAKO[N] DAIYAMONDO`

---------------------------------------------
; Level 5 page (4 rows).

dialogstring_0BF0EC `[CLR] Others[N] Sky Garden[N] Palace[N] Mu`

---------------------------------------------
; Level 6 page (4 rows).

dialogstring_0BF10D `[CLR] Others[N] Angel Village[N] Native's Village[N] Dao`

---------------------------------------------
; Level 7 page: Quit / Pyramid / Watermia / Ankor Wat.

dialogstring_0BF135 `[CLR] Quit[N] Pyramid[N] Watermia[N] Ankor Wat`

---------------------------------------------
; 'Bye bye!' farewell used by DebugManQuit.

dialogstring_0BF15A `[CLR]Bye bye![END]`

---------------------------------------------
; 'Ok! See you again!' confirmation shared by all 21 leaves.

dialogstring_0BF164 `[CLR]Ok![N]See you again![END]`