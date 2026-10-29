; Exit-to-world-map actor (Bank 00, 51781-52569). One copy is placed in each of 15 town, village and dungeon-entrance scenes (spawn record x 00, y 01, type 00). It waits for the player to reach a fixed exit zone, then stages the world-map arrival position and a destination-menu id and lets the engine switch to the world map.
; 
; === FLOW ===
; 
; 1. OverworldExitDispatch compares sceneCurrent with 15 scene ids and JMPs to the region handler. The handler tests the exit zone every frame (South Cape re-enters its own handler with SetEntryHere; all other regions go through the compare chain again each frame).
; 2. Zone tests: a pixel test on playerYPos (South Cape: Y < $10, Edward's Castle: Y == $2D0) or COP BranchIfPlayerInAbsTiles ( minX, minY, maxX, maxY ). The tile test runs on (player X, player Y - 8) and is strict at the minimum edge and inclusive at the maximum edge, in tiles x 16.
; 3. Inside the zone the handler may test story flags with BranchOnFlagByte. The first flag found set wins, so the later-story flag is tested first where there are two.
; 4. Every success path does the same: $0D60 := 0, COP StageWorldMapChoice ( start X, start Y, choice id ), JMP OverworldExitFinalize. StageWorldMapChoice only writes worldMapStagedX/PlayerY/ChoiceId; a nonzero staged X makes CheckSceneTransition send the game to scene $FE (the world map). WorldMapController then drops the player at the staged position and runs world_map_options[choice] (a 'Quit / destination' menu).
; 5. OverworldExitFinalize sets gfxCacheIdxB := $0400, SetEntryHere and RTL: the actor then idles at the RTL until the scene changes.
; 
; === EXITS ===
; 
; Choice ids select the menu text in world_map_options (39 entries; ids $01-$1B are staged here). The flag setters are the first match found by searching extracted/ for SetFlagByte.
; 
; | Scene | Area | Exit zone | Gate (first match wins) | Start X,Y | Choice id and menu |
; |-------|------|-----------|-------------------------|-----------|--------------------|
; | 01 | south_cape/south_cape | Y < $10 | flag $26 (sc06_kara_return), then flag $25 (also sc06_kara_return) | $D4,$3A4 | $02 Itory Village; $1B Quit only; default $01 Edward's Castle |
; | 0A | edward_castle/edward_castle | Y == $2D0 | none | $104,$334 | $03 South Cape |
; | 15 | itory/itory_village | tiles (2D,2E)-(2F,30) | flag $01 disables the exit; flag $4A (it1A_lily) | $C4,$2B4 | $06 Inca Ruins; default $04 South Cape |
; | 1C | incan_ruins/incan_ruins_entrance | tiles (06,1C)-(08,1E) | none | $134,$284 | $05 Itory Village |
; | 32 | freejia/freejia | tiles (12,3C)-(16,3E) | flag $65 (fr33_erik) | $254,$2D4 | $07 Diamond Mine; default $09 Quit only |
; | 3E | diamond_mine/mine_entrance | tiles (0A,3F)-(0C,40) | none | $334,$334 | $08 Freejia |
; | 69 | angel_village/angel_entrance | tiles (29,0D)-(2C,0F) | flag $8D (wa78_intro) | $384,$164 | $0A Watermia; default $15 Quit only |
; | 78 | watermia/watermia | tiles (27,3D)-(29,40) | flag $94 (wa79_neil), then flag $8E (Lance's Letter used) | $2D4,$1A4 | $0E Angel Village / Great Wall / Euro city; $0C Angel Village / Great Wall; default $0B Angel Village |
; | 82 | great_wall/wall_entrance | tiles (00,08)-(01,0B) | none | $2A4,$124 | $0D Watermia |
; | 91 | euro/euro | tiles (3F,42)-(40,48) | flag $AC (nvAC_kara), then flag $9F (eu92_erasquez) | $1D4,$134 | $1A Mt.Temple / Watermia / Natives' Vil.; $10 Mt.Temple / Watermia; default $0F Watermia |
; | A0 | mountain_temple/kress_entrance | tiles (2F,1B)-(30,1C) | none | $214,$B4 | $11 Euro city |
; | AC | native_village/native_village | tiles (1F,1B)-(20,20) | flag $B6 (daC4_kara), then flag $B1 (nvAC_map_kid) | $124,$1A4 | $19 Ankor Wat / Euro city / Dao Village; $13 Ankor Wat / Euro city; default $12 Euro city |
; | B0 | angkor_wat/angkor_entrance | tiles (1D,4F)-(24,50) | none | $134,$154 | $14 Natives' Village |
; | C3 | dao/dao | tiles (00,0D)-(01,11) | flag $B4 (daC8_neil) | $94,$114 | $17 Pyramid / Natives' Village; default $16 Natives' Village |
; | CC | pyramid/pyramid_main | tiles (00,0D)-(01,0F) or (3F,0D)-(40,0F) | none | $74,$B4 | $18 Dao Village |
; 
; Reading the table: the route menus grow with the story (flags set by the NPC scripts listed), and three choice ids ($09, $15, $1B) are menus that offer only 'Quit'. Choice ids $1C-$26 of world_map_options are never staged here.
; 
; === QUIRKS ===
; 
; - Edward's Castle compares playerYPos with == $2D0, not a range. If the player can skip that row the exit never fires; not checked.
; - The Itory Village exit is disabled while flag $01 is set. $01 is set by unrelated scripts (angel_village, undersea_tunnel, great_wall floor buttons); whether it is cleared on scene load was not traced.
; - $0D60 is cleared on every path. It is the first word of the six-word companion array at $0D60-$0D6A that WorldMapController scans to place companion dots; why only the first word is cleared is not known.
; - The handlers do not fall through into OverworldExitFinalize: they JMP to it.
---------------------------------------------

!sceneCurrent                   0644
!gfxCacheIdxB                   064A
!playerYPos                     09A4

---------------------------------------------

overworld_exit [
  actor-def < #00, #00, #30, {

; Scene dispatch: compare sceneCurrent with 15 ids in turn and JMP to the matching region handler; an unknown id ends in OverworldExitNoMatch.

  OverworldExitDispatch:
    LDA $sceneCurrent     ; Dispatch: compare sceneCurrent with the 15 scene ids in turn and JMP to the matching region handler (no match: OverworldExitNoMatch)
    CMP #$0001
    BNE OverworldExitNotScene01
    JMP $&OverworldExitSouthCape

  OverworldExitNotScene01:
    CMP #$000A
    BNE OverworldExitNotScene0A
    JMP $&OverworldExitEdwardCastle

  OverworldExitNotScene0A:
    CMP #$0015
    BNE OverworldExitNotScene15
    JMP $&OverworldExitItoryVillage

  OverworldExitNotScene15:
    CMP #$001C
    BNE OverworldExitNotScene1C
    JMP $&OverworldExitRuinsEntrance

  OverworldExitNotScene1C:
    CMP #$0032
    BNE OverworldExitNotScene32
    JMP $&OverworldExitFreejia

  OverworldExitNotScene32:
    CMP #$003E
    BNE OverworldExitNotScene3E
    JMP $&OverworldExitDiamondMine

  OverworldExitNotScene3E:
    CMP #$0069
    BNE OverworldExitNotScene69
    JMP $&OverworldExitAngelVillage

  OverworldExitNotScene69:
    CMP #$0078
    BNE OverworldExitNotScene78
    JMP $&OverworldExitWatermia

  OverworldExitNotScene78:
    CMP #$0082
    BNE OverworldExitNotScene82
    JMP $&OverworldExitGreatWall

  OverworldExitNotScene82:
    CMP #$0091
    BNE OverworldExitNotScene91
    JMP $&OverworldExitEuro

  OverworldExitNotScene91:
    CMP #$00A0
    BNE OverworldExitNotSceneA0
    JMP $&OverworldExitMountainTemple

  OverworldExitNotSceneA0:
    CMP #$00AC
    BNE OverworldExitNotSceneAC
    JMP $&OverworldExitNativeVillage

  OverworldExitNotSceneAC:
    CMP #$00B0
    BNE OverworldExitNotSceneB0
    JMP $&OverworldExitAngkorWatDoor

  OverworldExitNotSceneB0:
    CMP #$00C3
    BNE OverworldExitNotSceneC3
    JMP $&OverworldExitDaoVillage

  OverworldExitNotSceneC3:
    CMP #$00CC
    BNE OverworldExitNoMatch
    JMP $&OverworldExitPyramid

; No handler for this scene id: RTL (the dispatch runs again next frame).

  OverworldExitNoMatch:
    RTL 
} >
]

---------------------------------------------
; Common tail of every success path: gfxCacheIdxB := $0400, SetEntryHere, RTL. The actor idles here until the scene changes.

OverworldExitFinalize {
    LDA #$0400            ; gfxCacheIdxB := $0400 on every exit path (purpose of the value not traced)
    STA $gfxCacheIdxB
    COP [SetEntryHere]    ; Re-enter at the RTL below from now on: the actor idles until the scene changes
    RTL 
}

---------------------------------------------
; Scene 01. The only handler that uses SetEntryHere: it re-tests playerYPos < $10 every frame. At the north edge it picks the menu from flags $26 and $25.

OverworldExitSouthCape {
    COP [SetEntryHere]    ; Re-enter here every frame (the scene dispatch is skipped)
    LDA $playerYPos       ; Y < $10: the player is at the north edge of the scene
    CMP #$0010
    BCC OverworldExitSouthCapeEdge
    RTL 

; Player is at the north edge: flag $26 -> menu $02 (Itory Village), flag $25 -> menu $1B (Quit only), otherwise menu $01 (Edward's Castle). Start ($D4,$3A4).

  OverworldExitSouthCapeEdge:
    COP [BranchOnFlagByte] ( #26, #01, &OverworldExitSouthCapeFlag26 )
    COP [BranchOnFlagByte] ( #25, #01, &OverworldExitSouthCapeFlag25 )
    LDA #$0000
    STA $0D60             ; Every success path clears $0D60, the first word of the world map's six-word companion array (effect not traced)
    COP [StageWorldMapChoice] ( #$00D4, #$03A4, #01 ) ; Stage world-map start X, Y and menu id; a nonzero X arms the transition to the world map (see the block note for the values of each handler)
    JMP $&OverworldExitFinalize
}

---------------------------------------------
; Stage menu $02 (Quit / Itory Village), start ($D4,$3A4).

OverworldExitSouthCapeFlag26 {
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$00D4, #$03A4, #02 )
    JMP $&OverworldExitFinalize
}

---------------------------------------------
; Stage menu $1B (Quit only), start ($D4,$3A4).

OverworldExitSouthCapeFlag25 {
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$00D4, #$03A4, #1B )
    JMP $&OverworldExitFinalize
}

---------------------------------------------
; Scene 0A. Exit when playerYPos is exactly $2D0.

OverworldExitEdwardCastle {
    LDA $playerYPos
    CMP #$02D0            ; Exit row: Y exactly $2D0 (equality, not a range)
    BEQ OverworldExitEdwardCastleStage
    RTL 

; Stage menu $03 (Quit / South Cape), start ($104,$334).

  OverworldExitEdwardCastleStage:
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$0104, #$0334, #03 )
    JMP $&OverworldExitFinalize
}

---------------------------------------------
; Scene 15. Flag $01 disables the exit; otherwise tiles (2D,2E)-(2F,30) trigger it.

OverworldExitItoryVillage {
    COP [BranchOnFlagByte] ( #01, #01, &OverworldExitItoryVillageBlocked ) ; Flag $01 set (set by many unrelated scripts): exit disabled
    COP [BranchIfPlayerInAbsTiles] ( #2D, #2E, #2F, #30, &OverworldExitItoryVillageStage ) ; BranchIfPlayerInAbsTiles tests (player X, player Y - 8) against the tile rectangle: strict at the minimum edge, inclusive at the maximum
}

---------------------------------------------
; Exit disabled by flag $01, or the player is outside the rectangle: RTL.

OverworldExitItoryVillageBlocked {
    RTL 
}

---------------------------------------------
; Flag $4A -> menu $06 (Inca Ruins); otherwise menu $04 (South Cape). Start ($C4,$2B4).

OverworldExitItoryVillageStage {
    COP [BranchOnFlagByte] ( #4A, #01, &OverworldExitItoryVillageFlag4A )
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$00C4, #$02B4, #04 )
    JMP $&OverworldExitFinalize
}

---------------------------------------------
; Stage menu $06 (Quit / Inca Ruins), start ($C4,$2B4).

OverworldExitItoryVillageFlag4A {
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$00C4, #$02B4, #06 )
    JMP $&OverworldExitFinalize
}

---------------------------------------------
; Scene 1C. Tiles (06,1C)-(08,1E) trigger the exit.

OverworldExitRuinsEntrance {
    COP [BranchIfPlayerInAbsTiles] ( #06, #1C, #08, #1E, &OverworldExitRuinsEntranceStage )
    RTL 
}

---------------------------------------------
; Stage menu $05 (Quit / Itory Village), start ($134,$284).

OverworldExitRuinsEntranceStage {
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$0134, #$0284, #05 )
    JMP $&OverworldExitFinalize
}

---------------------------------------------
; Scene 32. Tiles (12,3C)-(16,3E) trigger the exit.

OverworldExitFreejia {
    COP [BranchIfPlayerInAbsTiles] ( #12, #3C, #16, #3E, &OverworldExitFreejiaStage )
    RTL 
}

---------------------------------------------
; Flag $65 -> menu $07 (Diamond Mine); otherwise menu $09 (Quit only). Start ($254,$2D4).

OverworldExitFreejiaStage {
    COP [BranchOnFlagByte] ( #65, #01, &OverworldExitFreejiaFlag65 )
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$0254, #$02D4, #09 )
    JMP $&OverworldExitFinalize
}

---------------------------------------------
; Stage menu $07 (Quit / Diamond Mine), start ($254,$2D4).

OverworldExitFreejiaFlag65 {
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$0254, #$02D4, #07 )
    JMP $&OverworldExitFinalize
}

---------------------------------------------
; Scene 3E. Tiles (0A,3F)-(0C,40) trigger the exit.

OverworldExitDiamondMine {
    COP [BranchIfPlayerInAbsTiles] ( #0A, #3F, #0C, #40, &OverworldExitDiamondMineStage )
    RTL 
}

---------------------------------------------
; Stage menu $08 (Quit / Freejia), start ($334,$334).

OverworldExitDiamondMineStage {
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$0334, #$0334, #08 )
    JMP $&OverworldExitFinalize
}

---------------------------------------------
; Scene 69. Tiles (29,0D)-(2C,0F) trigger the exit.

OverworldExitAngelVillage {
    COP [BranchIfPlayerInAbsTiles] ( #29, #0D, #2C, #0F, &OverworldExitAngelVillageStage )
    RTL 
}

---------------------------------------------
; Flag $8D -> menu $0A (Watermia); otherwise menu $15 (Quit only). Start ($384,$164).

OverworldExitAngelVillageStage {
    COP [BranchOnFlagByte] ( #8D, #01, &OverworldExitAngelVillageFlag8D )
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$0384, #$0164, #15 )
    JMP $&OverworldExitFinalize
}

---------------------------------------------
; Stage menu $0A (Quit / Watermia), start ($384,$164).

OverworldExitAngelVillageFlag8D {
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$0384, #$0164, #0A )
    JMP $&OverworldExitFinalize
}

---------------------------------------------
; Scene 78. Tiles (27,3D)-(29,40) trigger the exit.

OverworldExitWatermia {
    COP [BranchIfPlayerInAbsTiles] ( #27, #3D, #29, #40, &OverworldExitWatermiaStage )
    RTL 
}

---------------------------------------------
; Flag $94 -> menu $0E, flag $8E -> menu $0C, otherwise menu $0B. Start ($2D4,$1A4). The later-story flag is tested first.

OverworldExitWatermiaStage {
    COP [BranchOnFlagByte] ( #94, #01, &OverworldExitWatermiaFlag94 )
    COP [BranchOnFlagByte] ( #8E, #01, &OverworldExitWatermiaFlag8E )
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$02D4, #$01A4, #0B )
    JMP $&OverworldExitFinalize
}

---------------------------------------------
; Stage menu $0C (Quit / Angel Village / Great Wall), start ($2D4,$1A4).

OverworldExitWatermiaFlag8E {
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$02D4, #$01A4, #0C )
    JMP $&OverworldExitFinalize
}

---------------------------------------------
; Stage menu $0E (Quit / Angel Village / Great Wall / Euro city), start ($2D4,$1A4).

OverworldExitWatermiaFlag94 {
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$02D4, #$01A4, #0E )
    JMP $&OverworldExitFinalize
}

---------------------------------------------
; Scene 82. Tiles (00,08)-(01,0B) trigger the exit.

OverworldExitGreatWall {
    COP [BranchIfPlayerInAbsTiles] ( #00, #08, #01, #0B, &OverworldExitGreatWallStage )
    RTL 
}

---------------------------------------------
; Stage menu $0D (Quit / Watermia), start ($2A4,$124).

OverworldExitGreatWallStage {
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$02A4, #$0124, #0D )
    JMP $&OverworldExitFinalize
}

---------------------------------------------
; Scene 91. Tiles (3F,42)-(40,48) trigger the exit.

OverworldExitEuro {
    COP [BranchIfPlayerInAbsTiles] ( #3F, #42, #40, #48, &OverworldExitEuroStage )
    RTL 
}

---------------------------------------------
; Flag $AC -> menu $1A, flag $9F -> menu $10, otherwise menu $0F. Start ($1D4,$134).

OverworldExitEuroStage {
    COP [BranchOnFlagByte] ( #AC, #01, &OverworldExitEuroFlagAC )
    COP [BranchOnFlagByte] ( #9F, #01, &OverworldExitEuroFlag9F )
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$01D4, #$0134, #0F )
    JMP $&OverworldExitFinalize
}

---------------------------------------------
; Stage menu $10 (Quit / Mt.Temple / Watermia), start ($1D4,$134).

OverworldExitEuroFlag9F {
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$01D4, #$0134, #10 )
    JMP $&OverworldExitFinalize
}

---------------------------------------------
; Stage menu $1A (Quit / Mt.Temple / Watermia / Natives' Vil.), start ($1D4,$134).

OverworldExitEuroFlagAC {
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$01D4, #$0134, #1A )
    JMP $&OverworldExitFinalize
}

---------------------------------------------
; Scene A0. Tiles (2F,1B)-(30,1C) trigger the exit.

OverworldExitMountainTemple {
    COP [BranchIfPlayerInAbsTiles] ( #2F, #1B, #30, #1C, &OverworldExitMountainTempleStage )
    RTL 
}

---------------------------------------------
; Stage menu $11 (Quit / Euro city), start ($214,$B4).

OverworldExitMountainTempleStage {
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$0214, #$00B4, #11 )
    JMP $&OverworldExitFinalize
}

---------------------------------------------
; Scene AC. Tiles (1F,1B)-(20,20) trigger the exit.

OverworldExitNativeVillage {
    COP [BranchIfPlayerInAbsTiles] ( #1F, #1B, #20, #20, &OverworldExitNativeVillageStage )
    RTL 
}

---------------------------------------------
; Flag $B6 -> menu $19, flag $B1 -> menu $13, otherwise menu $12. Start ($124,$1A4).

OverworldExitNativeVillageStage {
    COP [BranchOnFlagByte] ( #B6, #01, &OverworldExitNativeVillageFlagB6 )
    COP [BranchOnFlagByte] ( #B1, #01, &OverworldExitNativeVillageFlagB1 )
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$0124, #$01A4, #12 )
    JMP $&OverworldExitFinalize
}

---------------------------------------------
; Stage menu $13 (Quit / Ankor Wat / Euro city), start ($124,$1A4).

OverworldExitNativeVillageFlagB1 {
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$0124, #$01A4, #13 )
    JMP $&OverworldExitFinalize
}

---------------------------------------------
; Stage menu $19 (Quit / Ankor Wat / Euro city / Dao Village), start ($124,$1A4).

OverworldExitNativeVillageFlagB6 {
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$0124, #$01A4, #19 )
    JMP $&OverworldExitFinalize
}

---------------------------------------------
; Scene B0. Tiles (1D,4F)-(24,50) trigger the exit.

OverworldExitAngkorWatDoor {
    COP [BranchIfPlayerInAbsTiles] ( #1D, #4F, #24, #50, &OverworldExitAngkorWatDoorStage )
    RTL 
}

---------------------------------------------
; Stage menu $14 (Quit / Natives' Village), start ($134,$154).

OverworldExitAngkorWatDoorStage {
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$0134, #$0154, #14 )
    JMP $&OverworldExitFinalize
}

---------------------------------------------
; Scene C3. Tiles (00,0D)-(01,11) trigger the exit.

OverworldExitDaoVillage {
    COP [BranchIfPlayerInAbsTiles] ( #00, #0D, #01, #11, &OverworldExitDaoVillageStage )
    RTL 
}

---------------------------------------------
; Flag $B4 -> menu $17; otherwise menu $16. Start ($94,$114).

OverworldExitDaoVillageStage {
    COP [BranchOnFlagByte] ( #B4, #01, &OverworldExitDaoVillageFlagB4 )
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$0094, #$0114, #16 )
    JMP $&OverworldExitFinalize
}

---------------------------------------------
; Stage menu $17 (Quit / Pyramid / Natives' Village), start ($94,$114).

OverworldExitDaoVillageFlagB4 {
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$0094, #$0114, #17 )
    JMP $&OverworldExitFinalize
}

---------------------------------------------
; Scene CC. Two rectangles, (00,0D)-(01,0F) and (3F,0D)-(40,0F), trigger the same exit.

OverworldExitPyramid {
    COP [BranchIfPlayerInAbsTiles] ( #00, #0D, #01, #0F, &OverworldExitPyramidStage )
    COP [BranchIfPlayerInAbsTiles] ( #3F, #0D, #40, #0F, &OverworldExitPyramidStage )
    RTL 
}

---------------------------------------------
; Stage menu $18 (Quit / Dao Village), start ($74,$B4).

OverworldExitPyramidStage {
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$0074, #$00B4, #18 )
    JMP $&OverworldExitFinalize
}