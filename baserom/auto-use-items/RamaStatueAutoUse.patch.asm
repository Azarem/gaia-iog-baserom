; ==============================================================================
; Rama Statue auto-use (Mu scene $66 altars) - interact + item-use stubs
; ==============================================================================
; What it does: Spawns altar interact activators at both pedestals. Altar 1
;   interact always runs use stub (dialog + item handler); altar 2 requires item
;   #13 or shows empty-shrine text. Stubs call patched code_039349/35A then RTL.
; Vanilla behavior: mu66 altar actors nudge/wait on flags #80/#81 with cutscene
;   logic; UseItem_RamaStatue from inventory checks scene $66 and tile regions,
;   RemoveEquippedItem via JSR, sets flags #80/#81.
; Hooks (overrides): mu66_altar1.code_069C2D-, mu66_altar2.code_069C70- prepend
;   SpawnAfterOffsetFlags for activators; item_use_system.code_039349!,
;   code_03935A! use COP RemoveItem; code_03936B+ adds mu66_altar*_use_stub.
; Adds: mu66_altar1/2_activator, *_interact, *_use_stub; JML to stubs from
;   altar2_use; JSR code_039349/35A from stubs after raise dialog.
; Depends on: ItemUseStub not used on altars (direct JML/JSR to item handlers);
;   dialogstring_039370/03939F from item_use_system; flags #80, #81.
; State: Item #13 Rama Statue; scene $66 altar room; SpawnAfterOffsetFlags
;   offset #$0008 on altar actors.
; Hazards/notes: Altar1 interact skips BranchIfHasItem (always attempts use);
;   COP RemoveItem in overrides vs vanilla JSR RemoveEquippedItem; X=actor for COP.
; ==============================================================================



mu66_altar1_activator {
    COP [SetInteractHandler] ( &mu66_altar1_interact )
    COP [WaitOnFlagByte] ( #80, #01 )
    COP [Die]
}

mu66_altar1_interact {
    JML $@mu66_altar1_use_stub
}

mu66_altar_interact_str `[DEF]Looks like an empty[N]shrine...[END]`

-----------------------------------------

mu66_altar2_activator {
    COP [SetInteractHandler] ( &mu66_altar2_interact )
    COP [WaitOnFlagByte] ( #81, #01 )
    COP [Die]
}

mu66_altar2_interact {
    COP [BranchIfHasItem] ( #13, &mu66_altar2_use )
    COP [PrintDialogString] ( &mu66_altar_interact_str )
    RTL
}

mu66_altar2_use {
    JML $@mu66_altar2_use_stub
}


-----------------------------------------

mu66_altar1.code_069C2D- {
    COP [SpawnAfterOffsetFlags] ( @mu66_altar1_activator, #$0000, #$0008, #$7000 )
}

-----------------------------------------

mu66_altar2.code_069C70- {
    COP [SpawnAfterOffsetFlags] ( @mu66_altar2_activator, #$0000, #$0008, #$7000 )
}

-----------------------------------------

item_use_system.code_039349! {
    COP [BranchOnFlagByte] ( #80, #01, &code_03936B )
    COP [RemoveItem] ( #13 )
    COP [PrintDialogString] ( &dialogstring_03939F )
    COP [SetFlagByte] ( #80 )
    RTS 
}

-----------------------------------------

item_use_system.code_03935A! {
    COP [BranchOnFlagByte] ( #81, #01, &code_03936B )
    COP [RemoveItem] ( #13 )
    COP [PrintDialogString] ( &dialogstring_03939F )
    COP [SetFlagByte] ( #81 )
    RTS 
}

-----------------------------------------

item_use_system.code_03936B+ {
  mu66_altar1_use_stub:
    COP [PrintDialogString] ( &dialogstring_039370 )
    JSR code_039349
    RTL

  mu66_altar2_use_stub:
    COP [PrintDialogString] ( &dialogstring_039370 )
    JSR code_03935A
    RTL
}