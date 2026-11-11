
; ==============================================================================
; Neil's father (EU95) - chair interact activator in prologue
; ==============================================================================
; What it does: Spawns a hidden activator at the chair so the player can talk
;   to Neil's father during the prologue wait (flag $A8 bit 1).
; Vanilla behavior: Scene sets interact on code_07E21C only; no chair activator.
; Hooks (overrides): eu95_neils_father code_07E1BD prepend spawn;
;   code_07E21C append activator actor script.
; Adds: eu95_neils_father_activator (SpawnAfterOffsetFlags child).
; Depends on: eu95_neils_father scene, flag byte $A8.
; Hazards/notes: Activator uses SetInteractHandler on parent code_07E21C.
; ==============================================================================

------------------------------------------

eu95_neils_father.code_07E1BD- {
    COP [SpawnAfterOffsetFlags] ( @eu95_neils_father_activator, #$0000, #$FFF0, #$7000 )
}

eu95_neils_father.code_07E21C+ {
  eu95_neils_father_activator:
    COP [SetInteractHandler] ( &code_07E21C )
    COP [WaitOnFlagByte] ( #A8, #01 )
    COP [Die]
}
