; Aqueduct lockway switch actor.
; 
; Interactive switch that toggles barrier state when activated.
; Part of the lockway puzzle mechanic.
---------------------------------------------

?INCLUDE 'enemy_stats_table'
?INCLUDE 'spriteset_enemies'

!statsPtr                       7F0020
!currentHp                      7F0026

---------------------------------------------

ec0E_switch [
  actor-def < #0F, #01, #01, {

  code_0A8934:
    LDA #$&enemy_stats_table+118
    STA $statsPtr, X
    LDA #$0031
    TSB $12
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [SolidHighHere]
    LDA #$00FF
    STA $currentHp, X

  code_0A8953:
    COP [ClearFlagByte] ( #01 )
    COP [SetHitCallback] ( &code_0A8962 )
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
} >
]

code_0A8962 {
    COP [SetFlagByte] ( #01 )
    COP [SetHitCallback] ( &code_0A8953 )
    COP [StageSpriteFrame] ( #10 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
}