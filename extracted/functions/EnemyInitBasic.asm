?INCLUDE 'enemy_stats_table'

!statsPtr                       7F0020
!currentHp                      7F0026
!extendedFlags                  7F002A

---------------------------------------------

EnemyInitBasic {
    LDA #$0030
    TSB $12
    LDA $extendedFlags, X
    ORA #$0080
    STA $extendedFlags, X
    LDA #$&enemy_stats_table
    STA $statsPtr, X
    LDA #$0001
    STA $currentHp, X
    RTL 
}