!playerMaxHp                    0ACA
!playerDef                      0ADC
!playerStr                      0ADE
!damageFlashTimer               0B22

---------------------------------------------

actor_0BFA57 [
  actor-def < #00, #00, #28, {

  code_0BFA5A:
    LDA #$0040
    STA $playerStr
    LDA #$0040
    STA $playerDef
    LDA #$0040
    STA $playerMaxHp
    LDA #$0040
    STA $damageFlashTimer
    COP [Die]
} >
]