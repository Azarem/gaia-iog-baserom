; Inventory management (Bank 03, 257943-258249): give an item or pickup (GiveItemToPlayer), remove an item by id (RemoveItemFromInventory) and test whether an item is held (CheckInventoryForItem).
; 
; === CALLERS ===
; 
; GiveItemToPlayer has 10 JSL sites in 5 files: the COP GiveItem handler (cop_handlers_inventory), chests (warps_interaction), the NPC / pickup touch handler (combat_collision.InteractionDamage_NPCChat, which gives the gem and heal drops of EnemyDropSystem), item_use_system and pyCD_puzzle (6). RemoveItemFromInventory and CheckInventoryForItem are reached only through their COP handlers.
; 
; === ITEM ID ENCODING (A, low byte) ===
; 
; $00 to $7F: regular items, stored in the first free slot of the 16-byte inventorySlots ($0AB4). $80 = HP Max Up, $81 = STR Up, $82 = DEF Up (each +1). $83 / $84 / $85 = 1 / 2 / 5 gems (gemCount capped at 999). $86 and above = heal: hpToHeal += 5 plus the SpawnItemSparkleEffect effect. After the PHP / SEP #$20 prologue the code tests bit 7 of the id and, for specials, subtracts $80 and walks a DEC chain.
; 
; === STAT-UP ITEMS ===
; 
; Each one clears displayModeFlags bit $0080 (leave the display-filter actor mode, in which RunActors_Normal runs only actors flagged $1000; the chest code in warps_interaction sets it around the call), plays SFX $25, adds 1 to the 8-bit stat and returns with Y = 0. The add is 8-bit signed: only when the old value is $7F does the overflow flag trigger and the stat is set to $55 (85) instead. That is a reset, not a cap: below $7F and above it (wrapping at $FF to 0) the stat is unbounded.
; HP Max Up also sets hpToHeal := new max HP - HP (an 8-bit difference), so UpdateHUD refills the bar to the new maximum at 1 HP every 8 frames. STR Up and DEF Up do not touch hpToHeal.
; 
; === OTHER SPECIAL ITEMS ===
; 
; Gems add 1, 2 or 5 to gemCount, clamp at $03E7 and play SFX $22. The heal ($86 and above) adds 5 to hpToHeal, switches D to the calling actor (D := X) so that COP SpawnListAppend( SpawnItemSparkleEffect, #00, #00, flags $2F00 ) creates the sparkle at that actor, and plays SFX $22. X must therefore be the calling actor's slot on this path. Neither the gems nor the heal change Y or $0DB8.
; 
; === RETURN CONVENTION ===
; 
; Carry clear = given, carry set = inventory full. Regular items: Y = dialog_item_found (success), $0DB8 = item id ($0DB9 = 0) for the dialogue text; full inventory: Y = dialog_item_full, $0DB8 = item id. Stat-ups return Y = 0; gems and the heal leave Y as the caller had it, so a caller must not show Y for ids of $80 and above. P is restored (PLP).
; RemoveItemFromInventory: first slot equal to A is zeroed and, only then, inventoryEquippedType := 0 and inventoryEquippedIndex := $FFFF (nothing equipped); a missing id changes nothing, and in both cases carry is restored by the PLP (the routine reports nothing). CheckInventoryForItem: carry clear = found, carry set = not found.
---------------------------------------------

?BANK 03

?INCLUDE 'item_pickup_text_table'
?INCLUDE 'SpawnItemSparkleEffect'

!displayModeFlags               09EC
!inventorySlots                 0AB4
!inventoryEquippedIndex         0AC4
!inventoryEquippedType          0AC6
!playerMaxHp                    0ACA
!playerHp                       0ACE
!gemCount                       0AD6
!playerDef                      0ADC
!playerStr                      0ADE
!hpToHeal                       0B22

---------------------------------------------

; Give the item whose id is in A (low byte). Regular ids $00 to $7F go into the first empty slot of inventorySlots; ids from $80 are specials, decoded as id - $80: 0 HP Max Up, 1 STR Up, 2 DEF Up (GiveItem_DefUp), 3 / 4 / 5 = 1 / 2 / 5 gems, 6 and up = heal 5 HP with the spark effect.
; Returns carry clear = given, carry set = inventory full; Y = dialogue string for regular items and for the full case. Details in the block note.

GiveItemToPlayer {
    PHP 
    SEP #$20
    BIT #$80              ; Bit 7 of the id: set = special item ($80 and up), clear = regular inventory item
    BNE loc_03EFB3
    PHA                   ; Keep the id for GiveItem_StoreInSlot or GiveItem_InventoryFull (both PLA it)
    LDY #$0000            ; Regular item path — scan 16 inventorySlots for first empty slot (Y=0)

; Slot scan for regular items: Y = 0 to 15, the first slot holding 0 is used.

  loc_03EFA2:
    LDA $inventorySlots, Y ; Load slot value; non-zero = occupied, continue scan
    BNE loc_03EFAA
    JMP $&GiveItem_StoreInSlot ; Empty slot found → GiveItem_StoreInSlot (store item, success dialogue)

; Slot occupied: next slot; after 16 slots the inventory is full.

  loc_03EFAA:
    INY 
    CPY #$0010
    BNE loc_03EFA2
    JMP $&GiveItem_InventoryFull ; All 16 slots occupied → GiveItem_InventoryFull (SEC on return)

; Special item: effect index := id - $80, then a DEC chain tests 0 (HP), 1 (STR), 2 (DEF), 3 to 5 (gems); anything else falls into the heal code that follows.

  loc_03EFB3:
    SEC                   ; Special item: A := id - $80 = effect index (0 HP, 1 STR, 2 DEF, 3 to 5 gems, 6 and up heal); the DEC chain below tests it
    SBC #$80
    BEQ loc_03F00C
    DEC 
    BEQ loc_03F032
    DEC 
    BNE loc_03EFC1
    JMP $&GiveItem_DefUp  ; Effect index 2 (item $82) → GiveItem_DefUp

; Effect index 3 and above: gems (3, 4, 5) or the heal.

  loc_03EFC1:
    DEC                   ; Effect index 3 (item $83) → add 1 gem
    BEQ loc_03EFE9
    DEC 
    BEQ loc_03EFED        ; Effect index 4 (item $84) → add 2 gems
    DEC 
    BEQ loc_03EFF1        ; Effect index 5 (item $85) → add 5 gems
    REP #$20
    LDA #$0005            ; Effect index ≥6 (item $86+): hpToHeal += 5
    CLC 
    ADC $hpToHeal
    STA $hpToHeal
    PHD                   ; D := X, the calling actor, so that the spawn below is placed at that actor
    TXA 
    TCD 
    COP [SpawnListAppend] ( @SpawnItemSparkleEffect, #00, #00, #$2F00 ) ; Spark effect (SpawnItemSparkleEffect) at the calling actor; flags word $2F00 becomes the child's $10
    PLD 
    COP [PlaySoundCh2] ( #22 ) ; SFX $22, shared with the gems
    JMP $&GiveItem_Success

; Gem amount 1 (item $83).

  loc_03EFE9:
    LDA #$01
    BRA loc_03EFF3

; Gem amount 2 (item $84).

  loc_03EFED:
    LDA #$02
    BRA loc_03EFF3

; Gem amount 5 (item $85).

  loc_03EFF1:
    LDA #$05

; Adds the amount in A to gemCount, clamps at 999 and plays SFX $22.

  loc_03EFF3:
    REP #$20
    AND #$00FF
    CLC 
    ADC $gemCount         ; Add gem increment to gemCount ($0AD6)
    CMP #$03E7            ; Compare to gem cap 999 ($03E7)
    BCC loc_03F004
    LDA #$03E7            ; Clamp gemCount to max 999 ($03E7)

; Stores gemCount, plays SFX $22 and returns through GiveItem_Success.

  loc_03F004:
    STA $gemCount
    COP [PlaySoundCh2] ( #22 ) ; SFX $22
    BRA GiveItem_Success

; HP Max Up (item $80): display-filter clear, SFX $25, max HP + 1 with the $7F reset, hpToHeal := new max - HP, Y = 0.

  loc_03F00C:
    REP #$20
    LDA #$0080
    TRB $displayModeFlags ; Clear displayModeFlags bit $0080: leave the display-filter actor mode (the chest code sets it)
    SEP #$20
    COP [PlaySoundCh2] ( #25 ) ; SFX $25, shared by the three stat-ups
    LDA $playerMaxHp      ; playerMaxHp += 1
    CLC 
    ADC #$01
    BVC loc_03F023        ; The 8-bit signed add overflows only when the old value was $7F
    LDA #$55              ; Overflow: set $55 (a reset, not a cap; other values are unbounded)

; Stores the new max HP and sets hpToHeal.

  loc_03F023:
    STA $playerMaxHp
    SEC 
    SBC $playerHp         ; hpToHeal := new max HP - HP: UpdateHUD refills to the new maximum, 1 HP every 8 frames
    STA $hpToHeal
    LDY #$0000
    BRA GiveItem_Success

; STR Up (item $81): display-filter clear, SFX $25, STR + 1 with the $7F reset, Y = 0.

  loc_03F032:
    REP #$20
    LDA #$0080
    TRB $displayModeFlags ; Display-filter clear as for HP Max Up
    SEP #$20
    COP [PlaySoundCh2] ( #25 )
    LDA $playerStr        ; playerStr += 1
    CLC 
    ADC #$01
    BVC loc_03F049
    LDA #$55              ; Same $7F overflow rule

; Stores the new STR.

  loc_03F049:
    STA $playerStr
    LDY #$0000
    BRA GiveItem_Success
}

---------------------------------------------
; DEF Up (item $82): clears displayModeFlags bit $0080, plays SFX $25, adds 1 to playerDef (8-bit; an old value of $7F becomes $55), Y = 0, then returns through GiveItem_Success.

GiveItem_DefUp {
    REP #$20
    LDA #$0080
    TRB $displayModeFlags ; Display-filter clear as for HP Max Up
    SEP #$20
    COP [PlaySoundCh2] ( #25 )
    LDA $playerDef        ; playerDef += 1
    CLC 
    ADC #$01
    BVC loc_03F068
    LDA #$55              ; Same $7F overflow rule

; Stores the new DEF.

  loc_03F068:
    STA $playerDef
    LDY #$0000
    BRA GiveItem_Success
}

---------------------------------------------
; Store regular item in inventory. Pops item ID from stack, writes to inventorySlots[Y] (first empty slot found by GiveItemToPlayer). Stores item ID at $0DB8 for dialogue display. Sets Y to the item-get success dialogue string pointer. Falls through to GiveItem_Success.

GiveItem_StoreInSlot {
    PLA                   ; Pop saved item ID from stack, store in inventorySlots[Y]
    STA $inventorySlots, Y
    STA $0DB8             ; Copy item ID to $0DB8 for dialogue display
    STZ $0DB9
    LDY #$&item_pickup_text_table.dialog_item_found ; Y → itemget success dialogue string (dialog_item_found)
}

---------------------------------------------
; Return from GiveItemToPlayer with success. Restores processor flags and returns with carry clear.

GiveItem_Success {
    PLP 
    CLC 
    RTL 
}

---------------------------------------------
; Return from GiveItemToPlayer when inventory is full. Pops item ID from stack, stores at $0DB8 for dialogue display. Sets Y to the inventory-full dialogue string pointer. Returns with carry set.

GiveItem_InventoryFull {
    PLA 
    STA $0DB8
    STZ $0DB9
    LDY #$&item_pickup_text_table.dialog_item_full ; Y → inventory full dialogue string (dialog_item_full)
    PLP 
    SEC                   ; SEC, RTL — carry set signals inventory full to caller
    RTL 
}

---------------------------------------------
; Remove an item from inventory by ID.
; 
; Searches all 16 inventorySlots for the item ID in A. If found: zeroes the slot, resets inventoryEquippedType to 0 and inventoryEquippedIndex to $FFFF (nothing equipped). If not found: returns silently.

RemoveItemFromInventory {
    PHP 
    SEP #$20
    LDY #$0000

; Slot scan for RemoveItemFromInventory: compares each slot with the id in A.

  loc_03F093:
    CMP $inventorySlots, Y ; Compare slot against item ID; match → clear slot
    BEQ loc_03F0A0
    INY 
    CPY #$0010
    BNE loc_03F093
    BRA loc_03F0B1        ; Item not found — skip equipped-state reset

; Match: zero the slot, then unequip (type 0, index $FFFF).

  loc_03F0A0:
    LDA #$00
    STA $inventorySlots, Y ; Zero matched slot (remove item from inventory)
    REP #$20
    LDA #$0000
    STA $inventoryEquippedType ; Reset inventoryEquippedType to 0
    DEC 
    STA $inventoryEquippedIndex ; Reset inventoryEquippedIndex to −1 ($FFFF)

; Common exit of RemoveItemFromInventory (PLP, RTL).

  loc_03F0B1:
    PLP 
    RTL 
}

---------------------------------------------
; Check if an item exists in the player's inventory.
; 
; Searches all 16 inventorySlots for the item ID in A. Returns carry clear if found, carry set if not found.

CheckInventoryForItem {
    PHP 
    SEP #$20
    LDY #$0000

; Slot scan for CheckInventoryForItem.

  loc_03F0B9:
    CMP $inventorySlots, Y ; Compare slot against item ID
    BEQ loc_03F0C7
    INY 
    CPY #$0010
    BNE loc_03F0B9
    PLP 
    SEC 
    RTL 

; Item found: carry clear.

  loc_03F0C7:
    PLP 
    CLC 
    RTL 
}