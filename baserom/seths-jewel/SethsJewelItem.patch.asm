; Seth's Jewel - item $29.
;
; A one-off Red Jewel look-alike given by Seth on the wrecked Gold Ship (see SethsJewelGoldShip.patch.asm).
; It is a normal, non-stacking inventory item: it is NOT in InventoryCountersAddressMap / KeyItemFlagIndex
; (both $FF for $29) and AutoUseRedJewelHandler only intercepts item $01, so it is never auto-used and
; always occupies its own slot. Using it manually adds 1 to the Red Jewel collection count ($0AB0) and
; plays the same orbit VFX as a Red Jewel, by reusing UseItem_AddAndSpawn from InventoryManagement.patch.asm.
;
; Pieces (all rewrite content, nothing topmost):
;   - ItemHandlerJumpTable        $29 -> UseItem_SethsJewel (everything else unchanged)
;   - UseItem_SethsJewel          use handler (chained insert next to the table, same bank 03)
;   - item_name_table[$29]        existing blank string consolestring_01DD47
;   - item_name_line_table[$29]        existing blank string consolestring_01E06B
;   - item_description_table      only has $00-$28, so the $29 entry is appended
;   - item_pickup_text_table[$29]  pickup / "inventory full" line (was the shared blank item_pickup_text_1B)
;
; Inventory sprite:    SethsJewelSprites.patch.asm
; Equipped HUD icon:   SethsJewelIcon.patch.asm

?INCLUDE 'item_use_system'
?INCLUDE 'system_strings'
?INCLUDE 'item_pickup_text_table'

-------------------------------------------------------------
; Use handler dispatch. Array entries cannot be patched individually, so the whole table is replaced;
; the only difference from the extracted table is entry $29.

ItemHandlerJumpTable#52: &UseItem_SethsJewel


; Mirrors UseItem_RedJewel!: print text, free the slot, then BCD +1 and the orbit VFX.
; RemoveEquippedItem treats any non-$01 item as a plain slot clear and un-equips it.
; UseItem_AddAndSpawn ends in RTS, which returns to ItemUseEpilogue.

UseItem_SethsJewel {
    COP [PrintDialogString] ( &dialogstring_seths_jewel_use )
    JSR $&RemoveEquippedItem
    JMP $&UseItem_AddAndSpawn
}

dialogstring_seths_jewel_use `[DEF]He raised Seth's Jewel![FIN]Seth's Jewel flies to[N]Jeweler Gem's in a[N]single ray of light![END]`

-------------------------------------------------------------
; Names / menu text / description (item ID $29). The two blank slots already exist in the tables.

consolestring_01DD47! |Seth's [N] Jewel |

consolestring_01E06B! |Seth's Jewel |

item_description_table+= [
  &consolestring_seths_jewel_desc   ;29
]

consolestring_seths_jewel_desc |[DBL]Strange jewel[DBL]Seth found on[DBL]the Gold Ship.|

-------------------------------------------------------------
; Item-get / inventory-full line printed through [ADR:&item_pickup_text_table,DB8].
; Replaces the shared blank entry for $29 (everything else unchanged).

item_pickup_text_table#52: &dialogstring_seths_jewel_get


dialogstring_seths_jewel_get `You found Seth's Jewel!`
