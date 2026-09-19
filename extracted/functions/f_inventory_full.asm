; Inventory-full dialog handler (InventoryFullMessage) that prints "Your inventory is full" via PrintDialogString.
; 
; Jumped to by item pickup and merchant actors throughout the game when GiveItem fails (Pyramid lithograph, Angkor glasses, Euro merchant, Great Wall necklace, and others). Central overflow message for any full-inventory case.
---------------------------------------------

---------------------------------------------

InventoryFullMessage {
    COP [PrintDialogString] ( &dialogstring_00C993 )
    RTL 
}

dialogstring_00C993 `[DEF][CLR][TPL:0]Your inventory is full.[N]You can't carry more.[PAL:0][END]`