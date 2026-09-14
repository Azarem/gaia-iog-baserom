?INCLUDE 'cop_handlers_script'
?INCLUDE 'enemy_stats_table'
?INCLUDE 'table_0EE000'

!statsPtr                       7F0020
!currentHp                      7F0026

---------------------------------------------

floor_button [
  actor-def < #00, #00, #01, {

  code_00C9FE:
    LDA $0E
    STA $24
    LDA #$2000
    STA $0E
    LDA #$&enemy_stats_table+118
    STA $statsPtr, X
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [SolidHighHere]
    LDA #$0031
    TSB $12

  loc_00CA1F:
    LDA #$00FF
    STA $currentHp, X
    COP [SetHitCallback] ( &code_00CA2D )
    COP [SetEntryContinue]
    RTL 
} >
]

code_00CA2D {
    LDA $24
    JSL $@cop_handlers_script.SetFlagRaw
    COP [StageSpriteFrame] ( #10 )
    COP [AnimOnce]
    COP [WaitByte] ( #0F )
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    BRA loc_00CA1F
}