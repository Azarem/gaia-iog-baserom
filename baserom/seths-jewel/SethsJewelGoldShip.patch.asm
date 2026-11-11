; ==============================================================================
; Seth's Jewel - Gold Ship Seth NPC gift
; ==============================================================================
; What it does: Seth on the wrecked Gold Ship gives item $29 (Seth's Jewel) on first talk
;   instead of Red Jewel $01; repeat dialog unchanged after flag $E0.
; Vanilla behavior: gs2B_seth GiveItem #01, "Will gets a Red Jewel!" text; same flags
;   $51 (despawn) and $E0 (already gave jewel); inventory-full -> HiddenRedJewelInventoryFull.
; Hooks (overrides): gs2B_seth.code_059652 interact handler; dialogstring_05966E pickup line.
; Depends on: ?INCLUDE gs2B_seth; hidden_red_jewel for code_059665 full-inventory JML.
; State: Flag byte $E0 set on successful give; $51 unchanged from vanilla.
; ==============================================================================


gs2B_seth.code_059652! {
    COP [BranchOnFlagByte] ( #E0, #01, &code_059669 )
    COP [PrintDialogString] ( &dialogstring_05966E )
    COP [GiveItem] ( #29, &code_059665 )
    COP [SetFlagByte] ( #E0 )
    RTL
}

gs2B_seth.dialogstring_05966E! `[TPL:F][TPL:5]Seth: I found [N]a strange jewel [N]on board the ship. [N]I'll give it to you. [FIN][PAL:0]Will gets Seth's Jewel![PAL:0][END]`
