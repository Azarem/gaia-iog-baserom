?INCLUDE 'enemy_stats_table'
?INCLUDE 'table_0EE000'

!statsPtr                       7F0020
!currentHp                      7F0026

---------------------------------------------

sg52_blocker_enemy_b [
  actor-def < #0F, #01, #01, {

  code_05F658:
    LDA #$&enemy_stats_table+118
    STA $statsPtr, X
    LDA #$0031
    TSB $12
    COP [SetMetasprite] ( @table_0EE000 )
    COP [BranchIfFlagWord] ( #$0127, #01, &code_05F68C )
    BRA loc_05F6BB

  code_05F672:
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [StageBgChange] ( #28 )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0127 )
    COP [SetFlagWord] ( #$0128 )
    COP [ClearFlagWord] ( #$0129 )
    COP [ClearFlagWord] ( #$012A )
} >
]

code_05F68C {
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [SolidHighHere]
    LDA #$00FF
    STA $currentHp, X
    COP [SetHitCallback] ( &code_05F6A1 )
    COP [SetEntryContinue]
    RTL 
}

code_05F6A1 {
    COP [StageSpriteFrame] ( #10 )
    COP [AnimOnce]
    COP [StageBgChange] ( #2A )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0129 )
    COP [SetFlagWord] ( #$012A )
    COP [ClearFlagWord] ( #$0127 )
    COP [ClearFlagWord] ( #$0128 )

  loc_05F6BB:
    COP [StageSpriteFrame] ( #10 )
    COP [AnimOnce]
    COP [SolidHighHere]
    LDA #$00FF
    STA $currentHp, X
    COP [SetHitCallback] ( &code_05F672 )
    COP [SetEntryContinue]
    RTL 
}