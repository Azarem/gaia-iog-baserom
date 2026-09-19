?INCLUDE 'enemy_stats_table'
?INCLUDE 'spriteset_enemies'

!statsPtr                       7F0020
!currentHp                      7F0026

---------------------------------------------

ec11_aqueduct_blocker [
  actor-def < #0F, #01, #01, {

  code_09BC8E:
    LDA #$&enemy_stats_table+118
    STA $statsPtr, X
    LDA #$0031
    TSB $12
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [SolidHighHere]

  loc_09BCA6:
    LDA #$00FF
    STA $currentHp, X

  code_09BCAD:
    COP [SetHitCallback] ( &code_09BCBB )
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [SetEntryExitNow] ( @code_09BCAD )
} >
]

code_09BCBB {
    LDA #$0200
    TSB $10
    COP [StageSpriteFrame] ( #11 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    LDA #$0200
    TRB $10
    BRA loc_09BCA6
}