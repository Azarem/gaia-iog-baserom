; Seth's Jewel - Seth (Gold Ship wreck, gs2B_seth) gives item $29 instead of a Red Jewel.
;
; Same flow and flags as the original: flag $51 despawns Seth, flag $E0 marks the jewel as given
; (first talk -> dialog + GiveItem + SetFlagByte $E0; afterwards the "first time I've ever given you
; anything" line). Only the item ID (#01 -> #29) and the "Will gets ..." text change. If the inventory is
; full the original fallback is kept (code_059665 -> HiddenRedJewelInventoryFull) and flag $E0 stays clear,
; so Seth offers the jewel again.

?INCLUDE 'gs2B_seth'

code_059652! {
    COP [BranchOnFlagByte] ( #E0, #01, &code_059669 )
    COP [PrintDialogString] ( &dialogstring_05966E )
    COP [GiveItem] ( #29, &code_059665 )
    COP [SetFlagByte] ( #E0 )
    RTL
}

dialogstring_05966E! `[TPL:F][TPL:5]Seth: I found [N]a strange jewel [N]on board the ship. [N]I'll give it to you. [FIN][PAL:0]Will gets Seth's Jewel![PAL:0][END]`
