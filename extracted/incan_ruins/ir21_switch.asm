?INCLUDE 'enemy_stats_table'
?INCLUDE 'table_0EE000'

!statsPtr                       7F0020
!currentHp                      7F0026

---------------------------------------------

ir21_switch [
  actor-def < #0F, #01, #01, {

  code_0A9029:
    LDA #$&enemy_stats_table+118
    STA $statsPtr, X
    LDA #$0030
    TSB $12
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [SolidHighHere]

  loc_0A9041:
    LDA #$00FF
    STA $currentHp, X
    COP [SetHitCallback] ( &code_0A9054 )
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
} >
]

code_0A9054 {
    COP [StageSpriteFrame] ( #10 )
    COP [AnimOnce]
    COP [SetFlagByte] ( #0F )
    COP [WaitByte] ( #3B )
    BRA loc_0A9041
}