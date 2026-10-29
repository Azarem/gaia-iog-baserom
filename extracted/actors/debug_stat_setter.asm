; Unused debug actor (Bank 0B, 784986-785010): sets four player stats to $0040 and kills itself. Nothing in extracted/ spawns it - it is in no scene_actors list and no script spawn - so it is dead code kept in the ROM.
; 
; The four writes are playerStr, playerDef, playerMaxHp and hpToHeal, all $0040 (64). It does not touch playerHp, so the player's current HP only rises through the heal request. For comparison debug_man sets HP 40 / STR 127 / DEF 127 (plus the ability mask and a warp menu) and unused_debug_mode sets HP 19 / STR 32 / DEF 33.
; 
; hpToHeal ($0B22) is a heal request that UpdateHUD (UpdateHUD_Active in system_core) plays out: on every 8th frame, unless the game-over bit of playerStateByte is set, a nonzero hpToHeal is decremented by one and playerHp is incremented by one with sound $0D; when playerHp equals playerMaxHp the request is cleared instead. The $0040 written here is therefore a request for up to 64 points of HP, capped at playerMaxHp.
---------------------------------------------

!playerMaxHp                    0ACA
!playerDef                      0ADC
!playerStr                      0ADE
!hpToHeal                       0B22

---------------------------------------------

debug_stat_setter [
  actor-def < #00, #00, #28, {

; One-shot: stats = $0040, then COP Die.

  DebugStatSetterInit:
    LDA #$0040            ; A = 64
    STA $playerStr        ; Strength = 64
    LDA #$0040
    STA $playerDef        ; Defense = 64
    LDA #$0040
    STA $playerMaxHp      ; Maximum HP = 64
    LDA #$0040
    STA $hpToHeal         ; Heal request of 64 (HP recovery animation per the WRAM map); playerHp itself is not written
    COP [Die]             ; One-shot actor: remove itself
} >
]