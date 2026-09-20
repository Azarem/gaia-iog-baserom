; Mummy Queen invincible orb — shields the boss.
; 
; Small child actor (16 lines) that orbits the queen during
; invulnerability phases. Cannot be destroyed. Blocks player
; attacks and deals contact damage.
---------------------------------------------

---------------------------------------------

pyDD_queen_invincible_orb [
  actor-def < #15, #01, #07, {

  code_0BADC1:
    LDA #$7FFF
    STA $08
    RTL 
} >
]