; ==============================================================================
; Seth's Jewel (item $29) - inventory item definition and use handler
; ==============================================================================
; What it does: Adds a non-key collectible that looks like a Red Jewel but occupies
;   its own inventory slot; manual Use prints custom text, clears the slot, then runs
;   the same BCD +1 and orbit VFX path as a real Red Jewel (UseItem_AddAndSpawn).
; Vanilla behavior: Item $29 had blank name strings, unused UseItem_Unused handler,
;   no description-table row, and shared blank pickup text (item_pickup_text_1B).
; Hooks (overrides): item_use_system.ItemHandlerJumpTable @+$52 -> UseItem_SethsJewel;
;   system_strings name/description strings; item_pickup_text_table @+$52 pickup line.
; Adds: UseItem_SethsJewel, dialogstring_seths_jewel_use/get/desc (chained near tables).
; Depends on: ?INCLUDE item_use_system, system_strings, item_pickup_text_table;
;   InventoryManagement UseItem_AddAndSpawn / RemoveEquippedItem; SethsJewelGoldShip gives #29.
; State: Item ID $29; increments $0AB0 (jewelsCollected) only via UseItem_AddAndSpawn on use.
; Hazards/notes: Not in KeyItemFlagIndex ($FF); AutoUseRedJewelHandler still only hooks $01.
;   Table patches use byte offset #52 (entry $29 in word-indexed tables).
; ==============================================================================

?INCLUDE 'item_use_system'
?INCLUDE 'system_strings'
?INCLUDE 'item_pickup_text_table'

-------------------------------------------------------------
; Use handler dispatch. Array entries cannot be patched individually, so the whole table is replaced;
; the only difference from the extracted table is entry $29.

item_use_system.ItemHandlerJumpTable#52: &UseItem_SethsJewel


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

system_strings.consolestring_01DD47! |Seth's [N] Jewel |

system_strings.consolestring_01E06B! |Seth's Jewel |

system_strings.item_description_table+= [
  &consolestring_seths_jewel_desc   ;29
]

consolestring_seths_jewel_desc |[DBL]Strange jewel[DBL]Seth found on[DBL]the Gold Ship.|

-------------------------------------------------------------
; Item-get / inventory-full line printed through [ADR:&item_pickup_text_table,DB8].
; Replaces the shared blank entry for $29 (everything else unchanged).

item_pickup_text_table.item_pickup_text_table#52: &dialogstring_seths_jewel_get


dialogstring_seths_jewel_get `You found Seth's Jewel!`
