; Debug stat setter — forces STR, DEF, MaxHP, and damageFlashTimer all to $40 (64), then dies.
; One-shot actor used for development testing. Never spawned in normal gameplay.
---------------------------------------------

!playerMaxHp                    0ACA
!playerDef                      0ADC
!playerStr                      0ADE
!damageFlashTimer               0B22

---------------------------------------------

debug_stat_setter [
  actor-def < #00, #00, #28, {

  DebugStatSetterInit:
    LDA #$0040            ; Set all stats to 64
    STA $playerStr
    LDA #$0040
    STA $playerDef
    LDA #$0040
    STA $playerMaxHp
    LDA #$0040
    STA $damageFlashTimer ; Triggers HP bar flash
    COP [Die]
} >
]