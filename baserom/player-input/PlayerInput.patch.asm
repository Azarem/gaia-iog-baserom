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

AttackSystemEntry! {
    LDA $playerFlags
    BIT #$0008 
    BEQ code_02B7BD
    JSL $@PlayerInputHooks
    RTL

  code_02B7BD!:
    LDA #$0001
    TRB $playerFlags
    COP [SetEntryHere]
    JSL $@PlayerInputHooks
    LDA $playerFlags
    BIT #$2A00
    BEQ loc_02B7CE
    RTL 
}