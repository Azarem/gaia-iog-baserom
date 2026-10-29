; Item name strings (Bank 01, 130340-130923): a 64-entry pointer table indexed by item ID ($00-$3F) plus the strings it points to, and five dialogue wrapper strings stored at the end of the block. The 64 strings are the item names (or a short found-message for a few items); the complete messages are the five wrappers.
; 
; === HOW IT IS READ ===
; 
; The wrappers contain [ADR:&item_pickup_text_table,DB8]. DialogCmd_IndirectString (DialogStringRenderer) takes the item ID that GiveItemToPlayer stored at $0DB8 (ChestDialogueActor also restores it there) and renders the table entry for that ID in place, so one wrapper prints whichever item was just given. The table is read only through this tag.
; 
; | Wrapper | Text | Used by |
; |---------|------|---------|
; | dialog_item_found | name, 255-frame pause, clear | GiveItem_StoreInSlot (inventory_mgmt): Y returned for a regular pickup |
; | dialog_item_full | name, 'Your inventory's full!' | GiveItem_InventoryFull (inventory_mgmt), InteractionDamage_NPCChat in combat_collision (an NPC that gives an item), and chests through GiveItemToPlayer's Y |
; | dialog_item_chest | name only | HandleChestInteraction (warps_interaction) overrides Y with it after a successful chest pickup |
; | dialog_chest_empty | 'It is empty!' | flag-only chests (warps_interaction); no item name |
; | dialog_chest_locked | 'The jewel box is tightly closed.' | chest tile without a scene_chest_table record (warps_interaction); no item name |
; 
; The last two are not item strings; they are stored here next to the other chest dialogue. COP #D4 (cop_handlers_inventory) ignores the Y string, so scripts that give items show their own text.
; 
; === ENTRIES ===
; 
; The IDs are the inventory item IDs of docs/ram_map.txt ($01 Red Jewel ... $28 Apple).
; - Full sentence: $01 'You found a Red Jewel! ', $06 'You found an herb! ', $07 (diamond-shaped block), $0E (Crystal Ball), $13 (Rama's Statue), $14 (Magic Dust), $15-$19 (Teapot), $1A 'It's the Mushroom Drops!'.
; - Bare name (the wrapper supplies the rest): $02 'Prison Key ', $03/$04 'Incan Statue A/B ', $05 'Incan Melody ', $08 'Wind Melody ', $09 'Lola's Melody ', $0A 'Large Roast ', $10 'Palace Key'.
; - Mystic Statues: $38 'It's a Mystic Statue! ', then seven separate copies of 'Mystic Statue ' for $39-$3F.
; - Blank (a single space): $00, $0B, $0C, $0D, $0F, $11, $12 and the 29 IDs $1B-$37, which share one string. These items print nothing through this table.
; - $15-$19 all point to the Teapot string, although ram_map names $15-$18 Blue Journal, Lance's Letter, Necklace Stones and Will.
; 
; Layout: 128 bytes of pointers + 456 bytes of strings and wrappers.
---------------------------------------------

?BANK 01

---------------------------------------------

; 64 word pointers indexed by item ID ($00-$3F), read through [ADR:&item_pickup_text_table,DB8] in the wrapper strings below. Entry contents: see the block note.

item_pickup_text_table [
  &item_pickup_text_00   ;00
  &item_pickup_text_01   ;01
  &item_pickup_text_02   ;02
  &item_pickup_text_03   ;03
  &item_pickup_text_04   ;04
  &item_pickup_text_05   ;05
  &item_pickup_text_06   ;06
  &item_pickup_text_07   ;07
  &item_pickup_text_08   ;08
  &item_pickup_text_09   ;09
  &item_pickup_text_0A   ;0A
  &item_pickup_text_0B   ;0B
  &item_pickup_text_0C   ;0C
  &item_pickup_text_0D   ;0D
  &item_pickup_text_0E   ;0E
  &item_pickup_text_0F   ;0F
  &item_pickup_text_10   ;10
  &item_pickup_text_11   ;11
  &item_pickup_text_12   ;12
  &item_pickup_text_13   ;13
  &item_pickup_text_14   ;14
  &item_pickup_text_15   ;15
  &item_pickup_text_15   ;16
  &item_pickup_text_15   ;17
  &item_pickup_text_15   ;18
  &item_pickup_text_15   ;19
  &item_pickup_text_1A   ;1A
  &item_pickup_text_1B   ;1B
  &item_pickup_text_1B   ;1C
  &item_pickup_text_1B   ;1D
  &item_pickup_text_1B   ;1E
  &item_pickup_text_1B   ;1F
  &item_pickup_text_1B   ;20
  &item_pickup_text_1B   ;21
  &item_pickup_text_1B   ;22
  &item_pickup_text_1B   ;23
  &item_pickup_text_1B   ;24
  &item_pickup_text_1B   ;25
  &item_pickup_text_1B   ;26
  &item_pickup_text_1B   ;27
  &item_pickup_text_1B   ;28
  &item_pickup_text_1B   ;29
  &item_pickup_text_1B   ;2A
  &item_pickup_text_1B   ;2B
  &item_pickup_text_1B   ;2C
  &item_pickup_text_1B   ;2D
  &item_pickup_text_1B   ;2E
  &item_pickup_text_1B   ;2F
  &item_pickup_text_1B   ;30
  &item_pickup_text_1B   ;31
  &item_pickup_text_1B   ;32
  &item_pickup_text_1B   ;33
  &item_pickup_text_1B   ;34
  &item_pickup_text_1B   ;35
  &item_pickup_text_1B   ;36
  &item_pickup_text_1B   ;37
  &item_pickup_text_38   ;38
  &item_pickup_text_39   ;39
  &item_pickup_text_3A   ;3A
  &item_pickup_text_3B   ;3B
  &item_pickup_text_3C   ;3C
  &item_pickup_text_3D   ;3D
  &item_pickup_text_3E   ;3E
  &item_pickup_text_3F   ;3F
]

---------------------------------------------
; Entry $00 (no item): a single space.

item_pickup_text_00 `  `

item_pickup_text_01 `You found a Red Jewel! `

item_pickup_text_02 `Prison Key `

item_pickup_text_03 `Incan Statue A `

item_pickup_text_04 `Incan Statue B `

item_pickup_text_05 `Incan Melody `

item_pickup_text_06 `You found an herb! `

item_pickup_text_07 `You found [N]the diamond-shaped block!`

item_pickup_text_08 `Wind Melody `

item_pickup_text_09 `Lola's Melody `

item_pickup_text_0A `Large Roast `

item_pickup_text_0B ` `

item_pickup_text_0C ` `

item_pickup_text_0D ` `

item_pickup_text_0E `You found[N]the Crystal Ball!`

item_pickup_text_0F ` `

item_pickup_text_10 `Palace Key`

item_pickup_text_11 ` `

item_pickup_text_12 ` `

item_pickup_text_13 `You found Rama's Statue!`

item_pickup_text_14 `You found Magic Dust!`

---------------------------------------------
; Entries $15-$19: shared 'You found the Teapot!'.

item_pickup_text_15 `You found the Teapot! `

item_pickup_text_1A `It's the Mushroom Drops!`

---------------------------------------------
; Entries $1B-$37 (29 IDs): shared single space; nothing is printed for these items.

item_pickup_text_1B ` `

item_pickup_text_38 `It's a Mystic Statue! `

item_pickup_text_39 `Mystic Statue `

item_pickup_text_3A `Mystic Statue `

item_pickup_text_3B `Mystic Statue `

item_pickup_text_3C `Mystic Statue `

item_pickup_text_3D `Mystic Statue `

item_pickup_text_3E `Mystic Statue `

item_pickup_text_3F `Mystic Statue `

---------------------------------------------
; Inventory-full message: [DEF] opens the default box, [DLY:1] sets the typing delay, [ADR] prints the item name from $0DB8, [N], 'Your inventory's full!', [END]. Returned in Y by GiveItem_InventoryFull; loaded by the pickup code of combat_collision.

dialog_item_full `[DEF][DLY:1][ADR:&item_pickup_text_table,DB8][N]Your inventory's full![END]`

---------------------------------------------
; Pickup message for regular items: [DLY:5] slow typing (operand + 2 frames per character), [SFX:0] per-character sound 0, [ADR] the item name from $0DB8, [PAU:FF] waits 255 frames (DialogCmd_WaitFrames), [CLD] clears the box. Returned in Y by GiveItem_StoreInSlot.

dialog_item_found `[DEF][DLY:5][SFX:0][ADR:&item_pickup_text_table,DB8][PAU:FF][CLD]`

---------------------------------------------
; Chest pickup text: the item name only, ended by [END] (waits for a button). HandleChestInteraction loads it into Y after a successful GiveItemToPlayer.

dialog_item_chest `[DEF][DLY:1][ADR:&item_pickup_text_table,DB8][END]`

---------------------------------------------
; 'It is empty!' for a flag-only chest (scene_chest_table record byte 2 = 0). Used by HandleChestInteraction; not an item string.

dialog_chest_empty `[DEF][DLY:1][SFX:0]It is empty![END]`

---------------------------------------------
; 'The jewel box is tightly closed.' when the player pushes a chest tile that has no scene_chest_table record. Used by HandleChestInteraction; not an item string.

dialog_chest_locked `[DEF][DLY:0]The jewel box is[N]tightly closed.[END]`