; Hittable switch block in the mine main area — counts laborer progress.
; 
; Displays as enemy sprite frame #0F with stat entry 118 and $FF HP.
; When attacked (hit callback), shows pressed sprite frame #11 and
; increments the laborer count at RAM $0A01. HP resets to $FF each
; frame so it can be hit repeatedly. Used with dm3F_mine_collapse_trigger
; which fires when $0A01 reaches 4.
---------------------------------------------

?INCLUDE 'enemy_stats_table'
?INCLUDE 'spriteset_enemies'

!statsPtr                       7F0020
!currentHp                      7F0026

---------------------------------------------

dm3F_switch [
  actor-def < #0F, #01, #01, {

  code_05D023:
    LDA #$&enemy_stats_table+118
    STA $statsPtr, X
    LDA #$0030
    TSB $12
    COP [SetMetasprite] ( @spriteset_enemies )
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