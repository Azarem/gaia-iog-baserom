; Inventory management — item give/remove/check utilities (257943–258250, Bank 03).
; 
; Provides the core inventory manipulation routines called by COP item-give commands, chest interactions, and script events.
; 
; === ITEM ID ENCODING ===
; 
; Item IDs use bit 7 as a type discriminator:
;   - $00–$7F: Regular inventory items → stored in inventorySlots ($0AB4, 16 slots)
;   - $80: HP Max Up (+1 HP, capped at $55)
;   - $81: STR Up (+1 STR, capped at $55)
;   - $82: DEF Up (+1 DEF, capped at $55)
;   - $83: 1 gem
;   - $84: 2 gems
;   - $85: 5 gems (gem cap: 999/$03E7)
;   - $86+: Damage flash effect (adds 5 to damageFlashTimer, spawns hit spark sprites, plays SFX $22)
; 
; Stat-up items ($80–$82) clear displayModeFlags bit $80 (disables HUD during the stat-up animation), play SFX $25, and set damageFlashTimer = (newMaxHp - currentHp) for the healing flash effect.
; 
; GiveItemToPlayer returns: carry clear = success (Y = item-get dialogue string pointer), carry set = inventory full (Y = full-inventory dialogue string pointer). The item ID is stored at $0DB8 for dialogue display.
; 
; RemoveItemFromInventory: Searches all 16 slots for the item ID in A, zeroes the matching slot, and resets equipped state (inventoryEquippedType = 0, inventoryEquippedIndex = $FFFF).
; 
; CheckInventoryForItem: Searches for item ID in A, returns carry clear if found, carry set if not.
---------------------------------------------

?BANK 03

?INCLUDE 'item_get_dialog_table'
?INCLUDE 'SpawnHitSparkSprites'

!displayModeFlags               09EC
!inventorySlots                 0AB4
!inventoryEquippedIndex         0AC4
!inventoryEquippedType          0AC6
!playerMaxHp                    0ACA
!playerHp                       0ACE
!gemCount                       0AD6
!playerDef                      0ADC
!playerStr                      0ADE
!damageFlashTimer               0B22

---------------------------------------------

; Give an item to the player by ID in A.
; 
; Item ID encoding:
;   $00–$7F: Regular item → scan inventorySlots ($0AB4, 16 entries) for first empty slot
;   $80: HP Max Up (+1, cap $55) → set damageFlashTimer for heal flash, SFX $25
;   $81: STR Up (+1, cap $55) → SFX $25
;   $82: DEF Up (+1, cap $55) → branches to GiveItem_DefUp
;   $83/$84/$85: Add 1/2/5 gems (cap 999), SFX $22
;   $86+: Damage effect → damageFlashTimer += 5, spawn hit spark sprites, SFX $22
; 
; Stat-up items clear displayModeFlags bit $80 (suppress HUD during animation).
; Return: carry clear = success, carry set = inventory full. Y = dialogue string pointer.

GiveItemToPlayer {
    PHP                   ; GiveItemToPlayer entry — item ID in A; save P register
    SEP #$20
    BIT #$80              ; Bit 7 test: $00–$7F = regular inventory item, $80+ = special effect
    BNE loc_03EFB3
    PHA 
    LDY #$0000            ; Regular item path — scan 16 inventorySlots for first empty slot (Y=0)

  loc_03EFA2:
    LDA $inventorySlots, Y ; Load slot value; non-zero = occupied, continue scan
    BNE loc_03EFAA
    JMP $&GiveItem_StoreInSlot ; Empty slot found → GiveItem_StoreInSlot (store item, success dialogue)

  loc_03EFAA:
    INY 
    CPY #$0010
    BNE loc_03EFA2
    JMP $&GiveItem_InventoryFull ; All 16 slots occupied → GiveItem_InventoryFull (SEC on return)

  loc_03EFB3:
    SEC                   ; Special item: subtract $80 → effect index (0=HP, 1=STR, 2=DEF, 3–5=gems, 6+=damage)
    SBC #$80
    BEQ loc_03F00C
    DEC 
    BEQ loc_03F032
    DEC 
    BNE loc_03EFC1
    JMP $&GiveItem_DefUp  ; Effect index 2 (item $82) → GiveItem_DefUp

  loc_03EFC1:
    DEC                   ; Effect index 3 (item $83) → add 1 gem
    BEQ loc_03EFE9
    DEC 
    BEQ loc_03EFED        ; Effect index 4 (item $84) → add 2 gems
    DEC 
    BEQ loc_03EFF1        ; Effect index 5 (item $85) → add 5 gems
    REP #$20
    LDA #$0005            ; Effect index ≥6 (item $86+): damageFlashTimer += 5
    CLC 
    ADC $damageFlashTimer
    STA $damageFlashTimer
    PHD 
    TXA 
    TCD 
    COP [SpawnLastRel] ( @SpawnHitSparkSprites, #00, #00, #$2F00 ) ; COP SpawnLastRel — spawn hit spark sprites at player position (#$2F00 offset)
    PLD 
    COP [PlaySoundCh2] ( #22 ) ; COP PlaySoundCh2 #22 — hurt/damage SFX
    JMP $&GiveItem_Success

  loc_03EFE9:
    LDA #$01
    BRA loc_03EFF3

  loc_03EFED:
    LDA #$02
    BRA loc_03EFF3

  loc_03EFF1:
    LDA #$05

  loc_03EFF3:
    REP #$20
    AND #$00FF
    CLC 
    ADC $gemCount         ; Add gem increment to gemCount ($0AD6)
    CMP #$03E7            ; Compare to gem cap 999 ($03E7)
    BCC loc_03F004
    LDA #$03E7            ; Clamp gemCount to max 999 ($03E7)

  loc_03F004:
    STA $gemCount
    COP [PlaySoundCh2] ( #22 ) ; COP PlaySoundCh2 #22 — gem pickup SFX
    BRA GiveItem_Success

  loc_03F00C:
    REP #$20
    LDA #$0080            ; TRB displayModeFlags bit $80 — clear stat-up HUD refresh flag
    TRB $displayModeFlags
    SEP #$20
    COP [PlaySoundCh2] ( #25 ) ; COP PlaySoundCh2 #25 — stat increase SFX (HP Max Up, item $80)
    LDA $playerMaxHp      ; playerMaxHp += 1
    CLC 
    ADC #$01
    BVC loc_03F023
    LDA #$55              ; Overflow → cap max HP at $55

  loc_03F023:
    STA $playerMaxHp
    SEC 
    SBC $playerHp         ; damageFlashTimer = newMaxHp − currentHp (green heal flash duration)
    STA $damageFlashTimer
    LDY #$0000
    BRA GiveItem_Success

  loc_03F032:
    REP #$20
    LDA #$0080            ; TRB displayModeFlags bit $80 — clear stat-up HUD refresh flag
    TRB $displayModeFlags
    SEP #$20
    COP [PlaySoundCh2] ( #25 ) ; COP PlaySoundCh2 #25 — stat increase SFX (STR Up, item $81)
    LDA $playerStr        ; playerStr += 1
    CLC 
    ADC #$01
    BVC loc_03F049
    LDA #$55              ; Overflow → cap STR at $55

  loc_03F049:
    STA $playerStr
    LDY #$0000
    BRA GiveItem_Success
}

---------------------------------------------
; DEF stat increase handler. Clears displayModeFlags bit $80, plays SFX $25, increments playerDef by 1 (capped at $55/85). Falls through to GiveItem_Success.

GiveItem_DefUp {
    REP #$20              ; GiveItem_DefUp — DEF Up handler (item $82)
    LDA #$0080            ; TRB displayModeFlags bit $80 — clear stat-up HUD refresh flag
    TRB $displayModeFlags
    SEP #$20
    COP [PlaySoundCh2] ( #25 ) ; COP PlaySoundCh2 #25 — stat increase SFX
    LDA $playerDef        ; playerDef += 1
    CLC 
    ADC #$01
    BVC loc_03F068
    LDA #$55              ; Overflow → cap DEF at $55

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
    LDY #$&item_get_dialog_table.dialogstring_01FF1F ; Y → itemget success dialogue string (dialogstring_01FF1F)
}

---------------------------------------------
; Return from GiveItemToPlayer with success. Restores processor flags and returns with carry clear.

GiveItem_Success {
    PLP                   ; GiveItem_Success — PLP, CLC, RTL (carry clear = success)
    CLC 
    RTL 
}

---------------------------------------------
; Return from GiveItemToPlayer when inventory is full. Pops item ID from stack, stores at $0DB8 for dialogue display. Sets Y to the inventory-full dialogue string pointer. Returns with carry set.

GiveItem_InventoryFull {
    PLA                   ; GiveItem_InventoryFull — pop item ID to $0DB8 for display
    STA $0DB8
    STZ $0DB9
    LDY #$&item_get_dialog_table.dialogstring_01FF02 ; Y → inventory full dialogue string (dialogstring_01FF02)
    PLP 
    SEC                   ; SEC, RTL — carry set signals inventory full to caller
    RTL 
}

---------------------------------------------
; Remove an item from inventory by ID.
; 
; Searches all 16 inventorySlots for the item ID in A. If found: zeroes the slot, resets inventoryEquippedType to 0 and inventoryEquippedIndex to $FFFF (nothing equipped). If not found: returns silently.

RemoveItemFromInventory {
    PHP                   ; RemoveItemFromInventory — item ID in A; search 16 slots
    SEP #$20
    LDY #$0000

  loc_03F093:
    CMP $inventorySlots, Y ; Compare slot against item ID; match → clear slot
    BEQ loc_03F0A0
    INY 
    CPY #$0010
    BNE loc_03F093
    BRA loc_03F0B1        ; Item not found — skip equipped-state reset

  loc_03F0A0:
    LDA #$00
    STA $inventorySlots, Y ; Zero matched slot (remove item from inventory)
    REP #$20
    LDA #$0000
    STA $inventoryEquippedType ; Reset inventoryEquippedType to 0
    DEC 
    STA $inventoryEquippedIndex ; Reset inventoryEquippedIndex to −1 ($FFFF)

  loc_03F0B1:
    PLP 
    RTL 
}

---------------------------------------------
; Check if an item exists in the player's inventory.
; 
; Searches all 16 inventorySlots for the item ID in A. Returns carry clear if found, carry set if not found.

CheckInventoryForItem {
    PHP                   ; CheckInventoryForItem — item ID in A; search 16 slots
    SEP #$20
    LDY #$0000

  loc_03F0B9:
    CMP $inventorySlots, Y ; Compare slot against item ID
    BEQ loc_03F0C7
    INY 
    CPY #$0010
    BNE loc_03F0B9
    PLP 
    SEC                   ; Not found — SEC, RTL (carry set = item absent)
    RTL 

  loc_03F0C7:
    PLP 
    CLC                   ; Found — CLC, RTL (carry clear = item present)
    RTL 
}