
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

code_07E7F3- {
    COP [SpawnAfterAbsFlags] ( @mt_mushroom_activator1, #$0148, #$0088, #$7000 )
}

---------------------------------------------
;mtA5_mushroom_drop_gate_a

code_07E846- {
    COP [SpawnAfterAbsFlags] ( @mt_mushroom_activator2, #$02E8, #$0128, #$7000 )

}

---------------------------------------------
;mtA5_mushroom_drop_gate_b
code_07E899- {
    COP [SpawnAfterAbsFlags] ( @mt_mushroom_activator3, #$0298, #$0248, #$7000 )
}
