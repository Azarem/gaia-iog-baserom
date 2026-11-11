; ==============================================================================
; Player input hook host - AttackSystemEntry extension point
; ==============================================================================
; What it does: Defines an empty PlayerInputHooks chain (RTL sentinel) and runs
;   it from AttackSystemEntry every frame before vanilla attack polling gates.
; Vanilla behavior: AttackSystemEntry cleared combat-lock bit $0008 on playerFlags
;   then ran attack input only; no module hook.
; Hooks (overrides): attack_ability_system.AttackSystemEntry (JSL to hooks before
;   idle/attack paths); attack_ability_system.code_02B7BD (same JSL on idle path).
; Adds: PlayerInputHooks / PlayerInputHooksEnd (other patches chain with PlayerInputHooks+).
; Depends on: attack_ability_system.
; State: Reads playerFlags $09AE bit 3 ($0008 combat lock).
; Hazards: JSL from actor context; hooks must preserve COP register rules if they
;   call COP (X = actor slot); AttackSystemEntry override must keep vanilla gates.
; ==============================================================================
?INCLUDE 'attack_ability_system'

!playerFlags                    09AE

--------------------------------------

PlayerInputHooks {
}

PlayerInputHooksEnd {
    RTL
}

--------------------------------------

;Call site of the player input hook chain (registry: player_input_core.asm).
;Identical to the original block except for the JSL: it runs right after the
;companion's per-frame re-entry point, before the attack polling gates.

attack_ability_system.AttackSystemEntry! {
    LDA $playerFlags
    BIT #$0008 
    BEQ code_02B7BD
    JSL $@PlayerInputHooks
    RTL

  attack_ability_system.code_02B7BD!:
    LDA #$0001
    TRB $playerFlags
    COP [SetEntryHere]
    JSL $@PlayerInputHooks
    LDA $playerFlags
    BIT #$2A00
    BEQ loc_02B7CE
    RTL 
}