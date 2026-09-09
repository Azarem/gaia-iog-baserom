?INCLUDE 'stats_01ABF0'
?INCLUDE 'table_0EE000'

!statsPtr                       7F0020
!currentHp                      7F0026

---------------------------------------------

dm3F_switch [
  actor-def < #0F, #01, #01, {

  code_05D023:
    LDA #$&stats_01ABF0+118
    STA $statsPtr, X
    LDA #$0030
    TSB $12
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [SolidHighHere]
    SEP #$20
    STZ $0A01
    REP #$20
    COP [SetHitCallback] ( &code_05D050 )
    LDA #$00FF
    STA $currentHp, X
    COP [SetEntryContinue]
    RTL 
} >
]

code_05D050 {
    COP [StageSpriteFrame] ( #11 )
    COP [AnimOnce]
    SEP #$20
    INC $0A01
    REP #$20
    COP [SetEntryContinue]
    LDA #$00FF
    STA $currentHp, X
    RTL 
}