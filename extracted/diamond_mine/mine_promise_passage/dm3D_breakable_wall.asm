?INCLUDE 'SpawnDebrisBurst'
?INCLUDE 'stats_01ABF0'
?INCLUDE 'table_0EE000'

!playerFlags                    09AE
!statsPtr                       7F0020
!currentHp                      7F0026

---------------------------------------------

dm3D_breakable_wall [
  actor-def < #00, #00, #01, {

  code_0AA9EF:
    COP [BranchIfFlagWord] ( #$0133, #01, &code_0AAA52 )
    COP [AddPosition] ( #08, #08 )
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    LDA #$&stats_01ABF0
    STA $statsPtr, X
    LDA #$0031
    TSB $12

  loc_0AAA10:
    LDA #$00FF
    STA $currentHp, X
    COP [SetEntryContinue]
    LDA $currentHp, X
    CMP #$00FF
    BNE loc_0AAA32
    COP [BranchIfPlayerInAbsTiles] ( #05, #03, #07, #07, &code_0AAA2E )
    COP [ClearFlagByte] ( #00 )
    RTL 
} >
]

code_0AAA2E {
    COP [SetFlagByte] ( #00 )
    RTL 

  loc_0AAA32:
    LDA $playerFlags
    BIT #$0002
    BNE loc_0AAA3F
    DEC $24
    BMI loc_0AAA10
    RTL 

  loc_0AAA3F:
    COP [SpawnAfterFlags] ( @SpawnDebrisBurst, #$2000 )
    COP [StageBgChange] ( #33 )
    COP [ApplyBgChange]
    COP [ClearFlagByte] ( #00 )
    COP [SetFlagWord] ( #$0133 )
}

code_0AAA52 {
    COP [Die]
}