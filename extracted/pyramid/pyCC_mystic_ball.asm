?INCLUDE 'cop_handlers_flags'
?INCLUDE 'field_reveal_object'
?INCLUDE 'sg_actors_0ADA52'
?INCLUDE 'SpawnFieldRevealEffect'
?INCLUDE 'StandardEnemyDefeatHandler'
?INCLUDE 'table_0EE000'

!orbitAngle                     7F0010
!deathActionIdx                 7F0024
!extendedFlags                  7F002A
!moveScratch1                   7F002C
!moveScratch2                   7F002E

---------------------------------------------

pyCC_mystic_ball [
  actor-def < #0F, #00, #00, {

  code_0BC5A6:
    COP [SetDeathCallback] ( @code_0BC6E7 )
    LDA #$0010
    TSB $12

  loc_0BC5B0:
    COP [WaitWhileOffscreen] ( #07 )

  code_0BC5B3:
    LDA $10
    BIT #$4000
    BNE loc_0BC5B0
    COP [SetSavedPtr] ( &code_0BC5C8 )
    COP [BranchOnPlayerY] ( #$0018, &code_0BC5C8, &code_0BC655, &code_0BC5C8 )
} >
]

code_0BC5C8 {
    COP [SetEntryExit]
    COP [BranchIfSolidWest] ( &code_0BC5D9 )
    COP [StageSpriteMoveX] ( #0F, #12 )
    COP [AnimOnce]
    BRA code_0BC5B3

  loc_0BC5D6:
    COP [WaitWhileOffscreen] ( #07 )
}

code_0BC5D9 {
    LDA $10
    BIT #$4000
    BNE loc_0BC5D6
    COP [SetSavedPtr] ( &code_0BC5EE )
    COP [BranchOnPlayerY] ( #$0018, &code_0BC5EE, &code_0BC655, &code_0BC5EE )
}

code_0BC5EE {
    COP [SetEntryExit]
    COP [BranchIfSolidEast] ( &code_0BC5B3 )
    COP [StageSpriteMoveX] ( #0F, #11 )
    COP [AnimOnce]
    BRA code_0BC5D9
}

pyCC_mystic_ball2 [
  actor-def < #0F, #00, #00, {

  code_0BC5FF:
    COP [SetDeathCallback] ( @code_0BC6E7 )
    LDA #$0010
    TSB $12

  loc_0BC609:
    COP [WaitWhileOffscreen] ( #07 )

  code_0BC60C:
    LDA $10
    BIT #$4000
    BNE loc_0BC609
    COP [SetSavedPtr] ( &code_0BC621 )
    COP [BranchOnPlayerY] ( #$0018, &code_0BC621, &code_0BC655, &code_0BC621 )
} >
]

code_0BC621 {
    COP [SetEntryExit]
    COP [BranchIfSolidNorth] ( &code_0BC632 )
    COP [StageSpriteMoveY] ( #0F, #12 )
    COP [AnimOnce]
    BRA code_0BC60C

  loc_0BC62F:
    COP [WaitWhileOffscreen] ( #07 )
}

code_0BC632 {
    LDA $10
    BIT #$4000
    BNE loc_0BC62F
    COP [SetSavedPtr] ( &code_0BC647 )
    COP [BranchOnPlayerY] ( #$0018, &code_0BC647, &code_0BC655, &code_0BC647 )
}

code_0BC647 {
    COP [SetEntryExit]
    COP [BranchIfSolidSouth] ( &code_0BC60C )
    COP [StageSpriteMoveY] ( #0F, #11 )
    COP [AnimOnce]
    BRA code_0BC632
}

code_0BC655 {
    COP [BranchOnPlayerX] ( #$0000, &code_0BC6BF, &code_0BC6BF, &code_0BC697 )
}

pyCC_mystic_ball3 [
  actor-def < #0F, #00, #00, {

  code_0BC662:
    COP [SetDeathCallback] ( @code_0BC6E7 )
    LDA #$0010
    TSB $12

  loc_0BC66C:
    COP [SetSavedPtr] ( &code_0BC67A )
    COP [BranchOnPlayerY] ( #$0010, &code_0BC67A, &code_0BC681, &code_0BC67A )
} >
]

code_0BC67A {
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    BRA loc_0BC66C
}

code_0BC681 {
    COP [CardinalToPlayer]
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0BC68F )
}

code_list_0BC68F [
  &code_0BC67A   ;00
  &code_0BC697   ;01
  &code_0BC67A   ;02
  &code_0BC6BF   ;03
]

code_0BC697 {
    COP [LoopInit] ( #05 )
    COP [SpawnAfterRelFlags] ( @code_0BC70D, #$000A, #$FFF6, #$0300 )
    COP [RngByte]
    AND #$000F
    STA $08
    COP [SetEntryExit]
    COP [LoopNext]
    COP [SpawnAfterRelFlags] ( @sg_actors_0ADA52.code_0ADAB5, #$000A, #$FFF6, #$2200 )
    COP [SetEntryExit]
    COP [RestoreSavedPtr]
}

code_0BC6BF {
    COP [LoopInit] ( #05 )
    COP [SpawnAfterRelFlags] ( @code_0BC70D, #$FFF6, #$FFF6, #$0300 )
    COP [RngByte]
    AND #$000F
    STA $08
    COP [SetEntryExit]
    COP [LoopNext]
    COP [SpawnAfterRelFlags] ( @sg_actors_0ADA52.code_0ADAA0, #$FFF6, #$FFF6, #$2200 )
    COP [SetEntryExit]
    COP [RestoreSavedPtr]
}

code_0BC6E7 {
    COP [StageSpriteFrame] ( #19 )
    COP [AnimOnce]
    LDA $0AEC
    CMP #$0001
    BNE loc_0BC6F9
    COP [JumpScript] ( @StandardEnemyDefeatHandler )

  loc_0BC6F9:
    COP [CallScript] ( &code_0BC738 )
    COP [SpawnAfterFlags] ( @field_reveal_object, #$0020 )
    LDA $orbitAngle, X
    STA $0026, Y
    COP [Die]
}

code_0BC70D {
    COP [SetMetasprite] ( @table_0EE000 )
    COP [RngByte]
    AND #$0007
    SEC 
    SBC #$0003
    CLC 
    ADC $16
    STA $16
    LDA $0410
    LSR 
    LSR 
    AND #$0007
    SEC 
    SBC #$0003
    CLC 
    ADC $14
    STA $14
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [Die]
}

code_0BC738 {
    COP [PlaySoundCh1] ( #06 )
    SED 
    LDA $0AEE
    SEC 
    SBC #$0001
    STA $0AEE
    CLD 
    LDA $0AEC
    DEC 
    STA $0AEC
    STA $orbitAngle, X
    COP [StageForceMoveXY] ( #00, #00 )
    LDA #$0000
    STA $moveScratch1, X
    STA $moveScratch2, X
    COP [SetDungeonKillFlag]
    LDA $extendedFlags, X
    BIT #$0008
    BEQ loc_0BC76E
    COP [ClearLowHere]

  loc_0BC76E:
    LDA $deathActionIdx, X
    BEQ loc_0BC796
    JSL $@cop_handlers_flags.TestFlag_0100
    BCS loc_0BC796
    LDA $deathActionIdx, X
    JSL $@cop_handlers_flags.SetFlag_0100
    COP [SpawnLastRel] ( @SpawnFieldRevealEffect, #00, #00, #$0342 )
    PHX 
    LDA $deathActionIdx, X
    TYX 
    STA $deathActionIdx, X
    PLX 

  loc_0BC796:
    COP [RestoreSavedPtr]
}