?INCLUDE 'stats_01ABF0'
?INCLUDE 'table_0EE000'

!statsPtr                       7F0020
!currentHp                      7F0026

---------------------------------------------

sg52_actor_05F5DE [
  actor-def < #0F, #01, #01, {

  code_05F5E1:
    LDA #$&stats_01ABF0+118
    STA $statsPtr, X
    LDA #$00FF
    STA $currentHp, X
    LDA #$0030
    TSB $12
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [BranchIfFlagWord] ( #$0126, #01, &code_05F62E )

  code_05F607:
    COP [SetHitCallback] ( &code_05F62E )
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [StageBgChange] ( #90 )
    COP [ApplyBgChange]
    COP [ClearFlagWord] ( #$0125 )
    COP [ClearFlagWord] ( #$0126 )
    COP [SetEntryContinue]
    COP [BranchIfFlagWord] ( #$0126, #01, &code_05F62E )
    LDA #$00FF
    STA $currentHp, X
    RTL 
} >
]

code_05F62E {
    COP [SetHitCallback] ( &code_05F607 )
    COP [StageSpriteFrame] ( #10 )
    COP [AnimOnce]
    COP [StageBgChange] ( #26 )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0125 )
    COP [SetFlagWord] ( #$0126 )
    COP [SetEntryContinue]
    COP [BranchIfFlagWord] ( #$0126, #00, &code_05F607 )
    LDA #$00FF
    STA $currentHp, X
    RTL 
}