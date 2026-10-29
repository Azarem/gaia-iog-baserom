; Shared init JSL used by only two actors: dm3F_laborer (code_0AA9E0, Diamond Mine) and fr32_kidnapper (Freejia).
; 
; Sets $12 |= $0030 (TSB): in combat_collision $12 bit $0010 is damage / stagger immunity and bit $0020 is 'boss' (damage digits and the player-attack hit test are skipped).
; Sets extendedFlags ($7F002A,X) |= $0080, which the OrExtraFlags notes in cop_handlers_callbacks identify as the boss bit (not 'enemy type'), points statsPtr ($7F0020,X) at enemy_stats_table and sets currentHp ($7F0026,X) = 1.
; fr32_kidnapper overwrites currentHp with 5 right after the JSL. Whether the damage code replaces the HP with a stats-table lookup on the first hit was not traced (UNVERIFIED-RUNTIME).
---------------------------------------------

?INCLUDE 'enemy_stats_table'

!statsPtr                       7F0020
!currentHp                      7F0026
!extendedFlags                  7F002A

---------------------------------------------

EnemyInitBasic {
    LDA #$0030            ; $12 |= $0030: bit $0010 = damage / stagger immune, bit $0020 = boss (combat_collision readers)
    TSB $12
    LDA $extendedFlags, X
    ORA #$0080            ; extendedFlags $0080 = boss bit (OrExtraFlags notes), not an 'enemy type' marker
    STA $extendedFlags, X
    LDA #$&enemy_stats_table ; Shared stat table pointer
    STA $statsPtr, X
    LDA #$0001            ; currentHp = 1; fr32_kidnapper sets 5 right after this JSL
    STA $currentHp, X
    RTL 
}