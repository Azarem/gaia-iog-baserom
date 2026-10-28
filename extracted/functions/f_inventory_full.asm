; Inventory-full dialog handler (InventoryFullMessage) that prints "Your inventory is full. You can't carry more." via PrintDialogString.
; 
; Entered with JML from eight actor scripts when GiveItemToPlayer fails (gw82_necklace_stone, ec0A_barrel_roast, ec0B_cell, awBA_glasses, eu91_merchant_counter, dm47_sam, sc06_lola, pyDA_lithograph1); its RTL returns to the actor runner that called the script. combat_collision.InteractionDamage_NPCChat has its own overflow path and does not use this handler.
---------------------------------------------

---------------------------------------------

InventoryFullMessage {
    COP [PrintDialogString] ( &dialogstring_00C993 ) ; Print the inventory-full message (dialogstring_00C993 below); the RTL ends the calling actor script's tick
    RTL 
}

dialogstring_00C993 `[DEF][CLR][TPL:0]Your inventory is full.[N]You can't carry more.[PAL:0][END]`