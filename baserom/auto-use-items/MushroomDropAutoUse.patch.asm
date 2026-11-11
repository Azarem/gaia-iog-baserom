; ==============================================================================
; Mushroom Drop auto-use (Mountain Temple) - interact at vines, use water via stub
; ==============================================================================
; What it does: Before each mushroom-drop gate opens, spawns a vine interact
;   actor. With Mushroom Drop (#1A) owned, interact jumps to ItemUseStub at the
;   vanilla use-site handler for that gate; otherwise shows a hint string (gate
;   3 skips dialog and RTL).
; Vanilla behavior: Gate actors (mtA2/A5) wait on flag byte #01 then consume
;   item #1A in-place with BG changes and set flag words #$0159 / #$015F / #$0167.
; Hooks (overrides): mtA2_mushroom_drop_gate.code_07E7F3-, mtA5_mushroom_drop_gate_a
;   .code_07E846-, mtA5_mushroom_drop_gate_b.code_07E899- prepend SpawnAfterAbsFlags
;   for mt_mushroom_activator1/2/3 at vine coordinates.
; Adds: mt_mushroom_activator1/2/3 (+ _interact/_use); A=long addr of code_0398D2/
;   code_0398EC/code_0398F4 then JML ItemUseStub (same sites as UseItem_MushroomWater).
; Depends on: ItemUseStub; flag words #$0159, #$015F, #$0167 gate completion.
; State: SpawnAfterAbsFlags abs positions per override; activators WaitOnFlagWord
;   matching each gate; item #1A (Mushroom Drop).
; Hazards/notes: COP interact handlers need X=actor slot; SetInteractHandler paths
;   preserve engine COP conventions.
; ==============================================================================

mt_mushroom_activator1 {
    COP [SetInteractHandler] ( &mt_mushroom_activator1_interact )
    COP [WaitOnFlagWord] ( #$0159, #01 )
    COP [Die]
}

mt_mushroom_activator1_interact {
    COP [BranchIfHasItem] ( #1A, &mt_mushroom_activator1_use )
    COP [PrintDialogString] ( &mt_mushroom_interact_str )
    RTL
}

mt_mushroom_activator1_use {
    LDA #$code_0398D2
    JML $@ItemUseStub
}

-------------------------------------------

mt_mushroom_activator2 {
    COP [SetInteractHandler] ( &mt_mushroom_activator2_interact )
    COP [WaitOnFlagWord] ( #$015F, #01 )
    COP [Die]
}

mt_mushroom_activator2_interact {
    COP [BranchIfHasItem] ( #1A, &mt_mushroom_activator2_use )
    COP [PrintDialogString] ( &mt_mushroom_interact_str )
    RTL
}

mt_mushroom_activator2_use {
    LDA #$code_0398EC
    JML $@ItemUseStub
}

-------------------------------------------

mt_mushroom_activator3 {
    COP [SetInteractHandler] ( &mt_mushroom_activator3_interact )
    COP [WaitOnFlagWord] ( #$0167, #01 )
    COP [Die]
}

mt_mushroom_activator3_interact {
    COP [BranchIfHasItem] ( #1A, &mt_mushroom_activator3_use )
    ;COP [PrintDialogString] ( &mt_mushroom_interact_str )
    RTL
}

mt_mushroom_activator3_use {
    LDA #$code_0398F4
    JML $@ItemUseStub
}

-------------------------------------------

mt_mushroom_interact_str `[DEF]These vines look rather[N]peculiar...[END]`

---------------------------------------------
;mtA2_mushroom_drop_gate

mtA2_mushroom_drop_gate.code_07E7F3- {
    COP [SpawnAfterAbsFlags] ( @mt_mushroom_activator1, #$0148, #$0088, #$7000 )
}

---------------------------------------------
;mtA5_mushroom_drop_gate_a

mtA5_mushroom_drop_gate_a.code_07E846- {
    COP [SpawnAfterAbsFlags] ( @mt_mushroom_activator2, #$02E8, #$0128, #$7000 )

}

---------------------------------------------
;mtA5_mushroom_drop_gate_b
mtA5_mushroom_drop_gate_b.code_07E899- {
    COP [SpawnAfterAbsFlags] ( @mt_mushroom_activator3, #$0298, #$0248, #$7000 )
}
