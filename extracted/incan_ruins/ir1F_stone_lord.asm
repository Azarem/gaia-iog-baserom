; Stone Lord enemy — advanced variant of Stone Guard with ranged attacks.
; 
; Similar structure to Stone Guard but with added projectile spawning
; and wider attack patterns. Uses MoveToward for homing behavior
; and SpawnMarkedAfterRel for firing directional projectiles.
; Harder enemy found in the deeper rooms of the ruins.
---------------------------------------------

?INCLUDE 'interaction_handlers'

!orbitAngle                     7F0010
!currentHp                      7F0026

---------------------------------------------

ir1F_stone_lord [
  actor-def < #00, #00, #03, {

  code_0A95B6:
    BRA loc_0A95C9
} >
]

ir1F_stone_lord2 [
  actor-def < #01, #00, #03, {

  code_0A95BB:
    BRA loc_0A95C9
} >
]

ir1F_stone_lord3 [
  actor-def < #02, #00, #03, {

  code_0A95C0:
    BRA loc_0A95C9
} >
]

ir1F_stone_lord4 [
  actor-def < #02, #00, #03, {

  code_0A95C5:
    COP [SetHFlip]
    BRA loc_0A95C9

  loc_0A95C9:
    LDA #$0010
    TSB $12
    LDA $0F
    AND #$0010
    LSR 
    LSR 
    LSR 
    LSR 
    STA $orbitAngle, X
    COP [SetSpritePalette] ( #0E )
    COP [SetSpritePriority] ( #20 )
    COP [SolidHighHere]
    COP [WaitWhileOffscreen] ( #08 )
    COP [SpawnMarkedAfter] ( @interaction_handlers.push_handler_solid, #$2300 )
    LDA $orbitAngle, X
    BEQ loc_0A960D
    BRA loc_0A9615

  loc_0A95F5:
    LDA #$0200
    TRB $10
    COP [SetEntryContinue]
    LDA $currentHp, X
    CMP #$000A
    BNE loc_0A9606
    RTL 

  loc_0A9606:
    LDA #$0200
    TSB $10
    BRA code_0A9619

  loc_0A960D:
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #02, &code_0A9619 )
    RTL 

  loc_0A9615:
    COP [ExitIfFlagByte] ( #0F, #01 )
} >
]

code_0A9619 {
    COP [BranchIfNotOnGridline] ( &code_0A961F )
    BRA loc_0A9624
}

code_0A961F {
    COP [SetEntryExitNow] ( @code_0A9619 )

  loc_0A9624:
    COP [KillNext]
    COP [LoopInit] ( #1E )
    COP [SetSpritePalette] ( #0E )
    COP [SetEntryExit]
    COP [SetSpritePalette] ( #02 )
    COP [LoopNext]
    COP [LoopInit] ( #0F )
    COP [SetSpritePalette] ( #0E )
    COP [SetEntryExit]
    COP [SetEntryExit]
    COP [SetSpritePalette] ( #02 )
    COP [SetEntryExit]
    COP [LoopNext]
    LDA #$0300
    TRB $10
    LDA #$0010
    TRB $12
    COP [ClearLowHere]
    JMP $&code_0A965F
}

ir1F_stone_lord5 [
  actor-def < #00, #00, #00, {

  code_0A9656:
    COP [SetSpritePriority] ( #20 )
    COP [SetSpritePalette] ( #02 )
    COP [WaitWhileOffscreen] ( #0E )
} >
]

code_0A965F {
    COP [SetEntryExit]

  code_0A9661:
    COP [BranchNearerAxis] ( &code_0A9667, &code_0A9671 )
}

code_0A9667 {
    COP [BranchOnPlayerX] ( #$0008, &code_0A9694, &code_0A9671, &code_0A96B2 )
}

code_0A9671 {
    COP [BranchOnPlayerY] ( #$0008, &code_0A96D0, &code_0A967B, &code_0A96EF )
}

code_0A967B {
    RTL 
}

code_0A967C {
    COP [SetEntryExit]
    COP [RngByte]
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0A968C )
}

code_list_0A968C [
  &code_0A9694   ;00
  &code_0A96B2   ;01
  &code_0A96D0   ;02
  &code_0A96EF   ;03
]

code_0A9694 {
    COP [BranchIfPlayerInRelTiles] ( #FA, #FF, #00, #01, &code_0A970E )

  code_0A969C:
    COP [BranchIfSolidWest] ( &code_0A967C )
    COP [StageSpriteMoveX] ( #07, #02 )
    COP [AnimOnce]
    COP [BranchIfSolidWest] ( &code_0A967C )
    COP [StageSpriteMoveX] ( #08, #02 )
    COP [AnimOnce]
    BRA code_0A9661
}

code_0A96B2 {
    COP [BranchIfPlayerInRelTiles] ( #00, #FF, #06, #01, &code_0A972A )

  code_0A96BA:
    COP [BranchIfSolidEast] ( &code_0A967C )
    COP [StageSpriteMoveX] ( #87, #01 )
    COP [AnimOnce]
    COP [BranchIfSolidEast] ( &code_0A967C )
    COP [StageSpriteMoveX] ( #88, #01 )
    COP [AnimOnce]
    BRA code_0A9661
}

code_0A96D0 {
    COP [BranchIfPlayerInRelTiles] ( #FF, #FA, #01, #00, &code_0A9746 )

  code_0A96D8:
    COP [BranchIfSolidNorth] ( &code_0A967C )
    COP [StageSpriteMoveY] ( #05, #02 )
    COP [AnimOnce]
    COP [BranchIfSolidNorth] ( &code_0A967C )
    COP [StageSpriteMoveY] ( #06, #02 )
    COP [AnimOnce]
    JMP $&code_0A9661
}

code_0A96EF {
    COP [BranchIfPlayerInRelTiles] ( #FF, #00, #01, #06, &code_0A9762 )

  code_0A96F7:
    COP [BranchIfSolidSouth] ( &code_0A967C )
    COP [StageSpriteMoveY] ( #03, #01 )
    COP [AnimOnce]
    COP [BranchIfSolidSouth] ( &code_0A967C )
    COP [StageSpriteMoveY] ( #04, #01 )
    COP [AnimOnce]
    JMP $&code_0A9661
}

code_0A970E {
    COP [PlaySoundCh1] ( #1F )
    COP [StageSpriteFrame] ( #0B )
    COP [AnimOnce]
    COP [PlaySoundCh1] ( #21 )
    COP [SpawnLastRel] ( @code_0A977E, #E0, #00, #$0200 )
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    JMP $&code_0A969C
}

code_0A972A {
    COP [PlaySoundCh1] ( #1F )
    COP [StageSpriteFrame] ( #8B )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @code_0A979A, #20, #00, #$0200 )
    COP [PlaySoundCh1] ( #21 )
    COP [StageSpriteFrame] ( #9A )
    COP [AnimOnce]
    JMP $&code_0A96BA
}

code_0A9746 {
    COP [PlaySoundCh1] ( #1F )
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @code_0A97B6, #00, #E0, #$0200 )
    COP [PlaySoundCh1] ( #21 )
    COP [StageSpriteFrame] ( #19 )
    COP [AnimOnce]
    JMP $&code_0A96D8
}

code_0A9762 {
    COP [PlaySoundCh1] ( #1F )
    COP [StageSpriteFrame] ( #09 )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @code_0A97D2, #00, #08, #$0200 )
    COP [PlaySoundCh1] ( #21 )
    COP [StageSpriteFrame] ( #18 )
    COP [AnimOnce]
    JMP $&code_0A96F7
}

code_0A977E {
    COP [SetSpritePalette] ( #00 )

  code_0A9781:
    COP [BranchIfSolid] ( &code_0A97EC )
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @code_0A9781, #FA, #00, #$0200 )
    COP [StageSpriteFrame] ( #24 )
    COP [AnimOnce]
    COP [Die]
}

code_0A979A {
    COP [SetSpritePalette] ( #00 )

  code_0A979D:
    COP [BranchIfSolid] ( &code_0A97EC )
    COP [StageSpriteFrame] ( #A3 )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @code_0A979D, #06, #00, #$0200 )
    COP [StageSpriteFrame] ( #A4 )
    COP [AnimOnce]
    COP [Die]
}

code_0A97B6 {
    COP [SetSpritePalette] ( #00 )

  code_0A97B9:
    COP [BranchIfSolid] ( &code_0A97EC )
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @code_0A97B9, #00, #FA, #$0200 )
    COP [StageSpriteFrame] ( #24 )
    COP [AnimOnce]
    COP [Die]
}

code_0A97D2 {
    COP [SetSpritePalette] ( #00 )

  code_0A97D5:
    COP [BranchIfSolid] ( &code_0A97EC )
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @code_0A97D5, #00, #06, #$0200 )
    COP [StageSpriteFrame] ( #24 )
    COP [AnimOnce]
}

code_0A97EC {
    COP [Die]
}