; Hittable switch block in the mine main chamber — a hit counter.
; 
; Displays as enemy sprite frame #0F with stat entry 118 and $FF HP. Each of the four placements zeroes the byte $0A01 when it spawns, so the counter starts at 0 in every visit. When attacked (hit callback) it shows the pressed sprite frame #11 and adds 1 to $0A01 (the scratch flags $08-$0F of scene $3F read as one byte); HP resets to $FF every frame so it can be hit repeatedly.
; 
; The counter is not tied to a particular switch or laborer: dm3F_mine_collapse_trigger fires when the byte equals 4.
---------------------------------------------

?INCLUDE 'enemy_stats_table'
?INCLUDE 'spriteset_pickups_effects'

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
    COP [SetMetasprite] ( @spriteset_pickups_effects )
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [MarkSolidHere]
    SEP #$20
    STZ $0A01
    REP #$20
    COP [SetHitCallback] ( &code_05D050 )
    LDA #$00FF
    STA $currentHp, X
    COP [SetEntryHere]
    RTL 
} >
]

code_05D050 {
    COP [StageSpriteFrame] ( #11 )
    COP [AnimOnce]
    SEP #$20
    INC $0A01
    REP #$20
    COP [SetEntryHere]
    LDA #$00FF
    STA $currentHp, X
    RTL 
}