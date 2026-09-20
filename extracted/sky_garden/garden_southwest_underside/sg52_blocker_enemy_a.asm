; Blocking enemy A on the garden southwest underside.
; 
; Enemy that blocks a passage until defeated. Simpler AI
; than the main garden enemies — guards a specific position
; and must be killed to proceed.
---------------------------------------------

?INCLUDE 'enemy_stats_table'
?INCLUDE 'spriteset_enemies'

!statsPtr                       7F0020
!currentHp                      7F0026

---------------------------------------------

sg52_blocker_enemy_a [
  actor-def < #0F, #01, #01, {

  code_05F5E1:
    LDA #$&enemy_stats_table+118
    STA $statsPtr, X
    LDA #$00FF
    STA $currentHp, X
    LDA #$0030
    TSB $12
    COP [SetMetasprite] ( @spriteset_enemies )
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