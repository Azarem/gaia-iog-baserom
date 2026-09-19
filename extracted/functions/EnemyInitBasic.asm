; Standard enemy initialization JSL called by most enemy actors at spawn.
; 
; Sets status bits $0030 (solid + interactable) in $12, marks extendedFlags
; bit $0080 (enemy type), points statsPtr to the shared enemy_stats_table,
; and initializes currentHp to 1 (overwritten by stat lookup on first hit).
---------------------------------------------

?INCLUDE 'enemy_stats_table'

!statsPtr                       7F0020
!currentHp                      7F0026
!extendedFlags                  7F002A

---------------------------------------------

EnemyInitBasic {
    LDA #$0030            ; Solid + interactable flags
    TSB $12
    LDA $extendedFlags, X
    ORA #$0080            ; Mark as enemy actor
    STA $extendedFlags, X
    LDA #$&enemy_stats_table ; Shared stat table pointer
    STA $statsPtr, X
    LDA #$0001            ; Initial HP (replaced on first damage calc)
    STA $currentHp, X
    RTL 
}