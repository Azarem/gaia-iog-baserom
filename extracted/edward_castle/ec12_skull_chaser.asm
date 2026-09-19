; Skull Chaser enemy for the aqueduct back area.
; 
; Aggressive enemy that tracks and chases the player.
; Multi-pattern AI with directional pursuit.
---------------------------------------------

?INCLUDE 'enemy_stats_table'
?INCLUDE 'spriteset_enemies'

!orbitAngle                     7F0010
!statsPtr                       7F0020
!currentHp                      7F0026

---------------------------------------------

ec12_skull_chaser [
  actor-def < #00, #00, #00, {

  code_0A8479:
    COP [SetSpritePalette] ( #0C )
    COP [SetSpritePriority] ( #30 )
    COP [WaitWhileOffscreen] ( #08 )
    COP [SetDeathCallback] ( @code_0A853E )
    COP [SetEntryExit]

  code_0A8489:
    COP [BranchNearerAxis] ( &code_0A848F, &code_0A8499 )
} >
]

code_0A848F {
    COP [BranchOnPlayerX] ( #$0008, &code_0A84BC, &code_0A8499, &code_0A84DC )
}

code_0A8499 {
    COP [BranchOnPlayerY] ( #$0008, &code_0A84FC, &code_0A84A3, &code_0A851D )
}

code_0A84A3 {
    RTL 
}

code_0A84A4 {
    COP [SetEntryExit]
    COP [RngByte]
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0A84B4 )
}

code_list_0A84B4 [
  &code_0A84BC   ;00
  &code_0A84DC   ;01
  &code_0A84FC   ;02
  &code_0A851D   ;03
]

code_0A84BC {
    COP [BranchIfSolidWest] ( &code_0A84A4 )
    COP [StageSprAndHitbox] ( #07 )
    COP [StageForceMoveX] ( #02 )
    COP [SetEntryContinue]
    COP [ContinueIfFrame] ( #02 )
    COP [SetEntryExit]
    STZ $2C
    COP [BranchIfSolidWest] ( &code_0A84A4 )
    COP [StageForceMoveX] ( #02 )
    COP [SetEntryContinue]
    COP [AnimOnce]
    BRA code_0A8489
}

code_0A84DC {
    COP [BranchIfSolidEast] ( &code_0A84A4 )
    COP [StageSprAndHitbox] ( #87 )
    COP [StageForceMoveX] ( #01 )
    COP [SetEntryContinue]
    COP [ContinueIfFrame] ( #02 )
    COP [SetEntryExit]
    STZ $2C
    COP [BranchIfSolidEast] ( &code_0A84A4 )
    COP [StageForceMoveX] ( #01 )
    COP [SetEntryContinue]
    COP [AnimOnce]
    BRA code_0A8489
}

code_0A84FC {
    COP [BranchIfSolidNorth] ( &code_0A84A4 )
    COP [StageSprAndHitbox] ( #05 )
    COP [StageForceMoveY] ( #02 )
    COP [SetEntryContinue]
    COP [ContinueIfFrame] ( #02 )
    COP [SetEntryExit]
    STZ $2E
    COP [BranchIfSolidNorth] ( &code_0A84A4 )
    COP [StageForceMoveY] ( #02 )
    COP [SetEntryContinue]
    COP [AnimOnce]
    JMP $&code_0A8489
}

code_0A851D {
    COP [BranchIfSolidSouth] ( &code_0A84A4 )
    COP [StageSprAndHitbox] ( #03 )
    COP [StageForceMoveY] ( #01 )
    COP [SetEntryContinue]
    COP [ContinueIfFrame] ( #02 )
    COP [SetEntryExit]
    STZ $2E
    COP [BranchIfSolidSouth] ( &code_0A84A4 )
    COP [StageForceMoveY] ( #01 )
    COP [SetEntryContinue]
    COP [AnimOnce]
    JMP $&code_0A8489
}

code_0A853E {
    COP [SpawnAfterFlags] ( @code_0A854C, #$0300 )
    COP [SetEntryDelayExit] ( @code_0A8563, #$0002 )
}

code_0A854C {
    COP [PlaySoundCh1] ( #06 )
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [SetSpritePalette] ( #00 )
    LDA #$0002
    TSB $10
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    COP [Die]
}

code_0A8563 {
    COP [SetSpritePalette] ( #00 )
    COP [SetSpritePriority] ( #30 )
    COP [SetDeathCallback] ( $000000 )
    LDA #$&enemy_stats_table+44
    STA $statsPtr, X
    LDA $@enemy_stats_table+44
    AND #$00FF
    STA $currentHp, X
    LDA #$0340
    TRB $10
    COP [AddPosition] ( #00, #E0 )

  loc_0A8589:
    LDA $orbitAngle, X
    AND #$0003
    BNE loc_0A8598
    COP [StageSpriteLoop] ( #0D, #0C )
    COP [AnimLoop]

  loc_0A8598:
    LDA $orbitAngle, X
    INC 
    STA $orbitAngle, X
    COP [BranchOnPlayerX] ( #$0000, &code_0A85AB, &code_0A85AB, &code_0A85D1 )
}

code_0A85AB {
    COP [BranchOnPlayerY] ( #$0000, &code_0A85B5, &code_0A85B5, &code_0A85C3 )
}

code_0A85B5 {
    COP [StageSpriteMoveXY] ( #0C, #29, #02 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0C )
    COP [AnimOnce]
    BRA loc_0A8589
}

code_0A85C3 {
    COP [StageSpriteMoveXY] ( #0C, #29, #01 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0C )
    COP [AnimOnce]
    BRA loc_0A8589
}

code_0A85D1 {
    COP [BranchOnPlayerY] ( #$0000, &code_0A85DB, &code_0A85DB, &code_0A85E9 )
}

code_0A85DB {
    COP [StageSpriteMoveXY] ( #0C, #2B, #02 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0C )
    COP [AnimOnce]
    BRA loc_0A8589
}

code_0A85E9 {
    COP [StageSpriteMoveXY] ( #0C, #2B, #01 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0C )
    COP [AnimOnce]
    BRA loc_0A8589
}