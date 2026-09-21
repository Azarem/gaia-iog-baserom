; Overworld-to-world-map exit actor (Bank 00) placed in 15 overworld field scenes, dispatched by scene ID from the actor entry.
; 
; The main actor compares sceneCurrent against 15 hardcoded overworld scene indices and jumps to per-region handlers that gate on player tile position (BranchIfPlayerInAbsTiles), Y coordinate thresholds, and story flag bytes before calling StageWorldMapChoice with map coordinates and destination region index. Handlers cover South Cape, Great Wall, Incan Ruins, Watermia, Freejia, Euro, Angkor Wat, and other overworld zones with alternate destinations when progression flags differ.
; 
; All successful paths zero $0D60, stage the world-map cursor, and fall through to the exit handler which sets gfxCacheIdxB to $0400 before returning. Unmatched scenes or failed gate checks RTL without triggering a warp.
---------------------------------------------

!sceneCurrent                   0644
!gfxCacheIdxB                   064A
!playerYPos                     09A4

---------------------------------------------

overworld_exit [
  actor-def < #00, #00, #30, {

  OverworldExitDispatch:
    LDA $sceneCurrent     ; Overworld exit: sceneCurrent switch dispatches to per-region warp handler table
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

  OverworldExitNoMatch:
    RTL 
} >
]

OverworldExitFinalize {
    LDA #$0400            ; All warp paths converge: set gfxCacheIdxB=$0400, SetEntryHere, RTL
    STA $gfxCacheIdxB
    COP [SetEntryHere]
    RTL 
}

OverworldExitSouthCape {
    COP [SetEntryHere]    ; South Cape exit: playerY<$10 plus flag $26/$25 selects world-map destination
    LDA $playerYPos
    CMP #$0010
    BCC OverworldExitSouthCapeNorthGate
    RTL 

  OverworldExitSouthCapeNorthGate:
    COP [BranchOnFlagByte] ( #26, #01, &OverworldExitSouthCapeFlag26 )
    COP [BranchOnFlagByte] ( #25, #01, &OverworldExitSouthCapeFlag25 )
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$00D4, #$03A4, #01 )
    JMP $&OverworldExitFinalize
}

OverworldExitSouthCapeFlag26 {
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$00D4, #$03A4, #02 )
    JMP $&OverworldExitFinalize
}

OverworldExitSouthCapeFlag25 {
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$00D4, #$03A4, #1B )
    JMP $&OverworldExitFinalize
}

OverworldExitEdwardCastle {
    LDA $playerYPos
    CMP #$02D0
    BEQ OverworldExitEdwardCastleSouthEdge
    RTL 

  OverworldExitEdwardCastleSouthEdge:
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$0104, #$0334, #03 )
    JMP $&OverworldExitFinalize
}

OverworldExitItoryVillage {
    COP [BranchOnFlagByte] ( #01, #01, &OverworldExitItoryVillageBlocked ) ; Itory exit: flag $01 blocks; tile rect check plus flag $4A picks map node
    COP [BranchIfPlayerInAbsTiles] ( #2D, #2E, #2F, #30, &OverworldExitItoryVillageEnter )
}

OverworldExitItoryVillageBlocked {
    RTL 
}

OverworldExitItoryVillageEnter {
    COP [BranchOnFlagByte] ( #4A, #01, &OverworldExitItoryVillageFlag4A )
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$00C4, #$02B4, #04 )
    JMP $&OverworldExitFinalize
}

OverworldExitItoryVillageFlag4A {
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$00C4, #$02B4, #06 )
    JMP $&OverworldExitFinalize
}

OverworldExitRuinsEntrance {
    COP [BranchIfPlayerInAbsTiles] ( #06, #1C, #08, #1E, &OverworldExitRuinsEntranceEast )
    RTL 
}

OverworldExitRuinsEntranceEast {
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$0134, #$0284, #05 )
    JMP $&OverworldExitFinalize
}

OverworldExitFreejia {
    COP [BranchIfPlayerInAbsTiles] ( #12, #3C, #16, #3E, &OverworldExitFreejiaDefault )
    RTL 
}

OverworldExitFreejiaDefault {
    COP [BranchOnFlagByte] ( #65, #01, &OverworldExitFreejiaFlag65 )
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$0254, #$02D4, #09 )
    JMP $&OverworldExitFinalize
}

OverworldExitFreejiaFlag65 {
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$0254, #$02D4, #07 )
    JMP $&OverworldExitFinalize
}

OverworldExitDiamondMine {
    COP [BranchIfPlayerInAbsTiles] ( #0A, #3F, #0C, #40, &OverworldExitDiamondMineEast )
    RTL 
}

OverworldExitDiamondMineEast {
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$0334, #$0334, #08 )
    JMP $&OverworldExitFinalize
}

OverworldExitAngelVillage {
    COP [BranchIfPlayerInAbsTiles] ( #29, #0D, #2C, #0F, &OverworldExitAngelVillageDefault )
    RTL 
}

OverworldExitAngelVillageDefault {
    COP [BranchOnFlagByte] ( #8D, #01, &OverworldExitAngelVillageFlag8D )
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$0384, #$0164, #15 )
    JMP $&OverworldExitFinalize
}

OverworldExitAngelVillageFlag8D {
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$0384, #$0164, #0A )
    JMP $&OverworldExitFinalize
}

OverworldExitWatermia {
    COP [BranchIfPlayerInAbsTiles] ( #27, #3D, #29, #40, &OverworldExitWatermiaDefault )
    RTL 
}

OverworldExitWatermiaDefault {
    COP [BranchOnFlagByte] ( #94, #01, &OverworldExitWatermiaFlag94 )
    COP [BranchOnFlagByte] ( #8E, #01, &OverworldExitWatermiaFlag8E )
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$02D4, #$01A4, #0B )
    JMP $&OverworldExitFinalize
}

OverworldExitWatermiaFlag8E {
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$02D4, #$01A4, #0C )
    JMP $&OverworldExitFinalize
}

OverworldExitWatermiaFlag94 {
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$02D4, #$01A4, #0E )
    JMP $&OverworldExitFinalize
}

OverworldExitGreatWall {
    COP [BranchIfPlayerInAbsTiles] ( #00, #08, #01, #0B, &OverworldExitGreatWallNorth )
    RTL 
}

OverworldExitGreatWallNorth {
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$02A4, #$0124, #0D )
    JMP $&OverworldExitFinalize
}

OverworldExitEuro {
    COP [BranchIfPlayerInAbsTiles] ( #3F, #42, #40, #48, &OverworldExitEuroDefault )
    RTL 
}

OverworldExitEuroDefault {
    COP [BranchOnFlagByte] ( #AC, #01, &OverworldExitEuroFlagAC )
    COP [BranchOnFlagByte] ( #9F, #01, &OverworldExitEuroFlag9F )
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$01D4, #$0134, #0F )
    JMP $&OverworldExitFinalize
}

OverworldExitEuroFlag9F {
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$01D4, #$0134, #10 )
    JMP $&OverworldExitFinalize
}

OverworldExitEuroFlagAC {
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$01D4, #$0134, #1A )
    JMP $&OverworldExitFinalize
}

OverworldExitMountainTemple {
    COP [BranchIfPlayerInAbsTiles] ( #2F, #1B, #30, #1C, &OverworldExitMountainTempleEast )
    RTL 
}

OverworldExitMountainTempleEast {
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$0214, #$00B4, #11 )
    JMP $&OverworldExitFinalize
}

OverworldExitNativeVillage {
    COP [BranchIfPlayerInAbsTiles] ( #1F, #1B, #20, #20, &OverworldExitNativeVillageDefault )
    RTL 
}

OverworldExitNativeVillageDefault {
    COP [BranchOnFlagByte] ( #B6, #01, &OverworldExitNativeVillageFlagB6 )
    COP [BranchOnFlagByte] ( #B1, #01, &OverworldExitNativeVillageFlagB1 )
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$0124, #$01A4, #12 )
    JMP $&OverworldExitFinalize
}

OverworldExitNativeVillageFlagB1 {
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$0124, #$01A4, #13 )
    JMP $&OverworldExitFinalize
}

OverworldExitNativeVillageFlagB6 {
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$0124, #$01A4, #19 )
    JMP $&OverworldExitFinalize
}

OverworldExitAngkorWatDoor {
    COP [BranchIfPlayerInAbsTiles] ( #1D, #4F, #24, #50, &OverworldExitAngkorWatDoorSouth )
    RTL 
}

OverworldExitAngkorWatDoorSouth {
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$0134, #$0154, #14 )
    JMP $&OverworldExitFinalize
}

OverworldExitDaoVillage {
    COP [BranchIfPlayerInAbsTiles] ( #00, #0D, #01, #11, &OverworldExitDaoVillageDefault )
    RTL 
}

OverworldExitDaoVillageDefault {
    COP [BranchOnFlagByte] ( #B4, #01, &OverworldExitDaoVillageFlagB4 )
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$0094, #$0114, #16 )
    JMP $&OverworldExitFinalize
}

OverworldExitDaoVillageFlagB4 {
    LDA #$0000
    STA $0D60
    COP [StageWorldMapChoice] ( #$0094, #$0114, #17 )
    JMP $&OverworldExitFinalize
}

OverworldExitPyramid {
    COP [BranchIfPlayerInAbsTiles] ( #00, #0D, #01, #0F, &OverworldExitPyramidNorth )
    COP [BranchIfPlayerInAbsTiles] ( #3F, #0D, #40, #0F, &OverworldExitPyramidNorth )
    RTL 
}

OverworldExitPyramidNorth {
    LDA #$0000            ; Pyramid exit: two tile rects both route to world-map node #18
    STA $0D60
    COP [StageWorldMapChoice] ( #$0074, #$00B4, #18 )
    JMP $&OverworldExitFinalize
}