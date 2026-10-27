; Inventory COP handlers (44037–44161, Bank 00).
; 
; Script-level wrappers around inventory_mgmt:
; - GiveItem (COP #D4): add an item, branch to an overflow target when the inventory is full (49 sites).
; - RemoveItem (COP #D5): remove an item by ID (34 sites).
; - BranchIfHasItem (COP #D6): branch when the item is in the inventory (35 sites).
; - BranchIfItemEquipped (COP #D7): branch when the operand matches the equipped item (5 sites).
; 
; The branch operands are &Code offsets in the script bank. Handlers return by writing the resume address into the COP stack frame ($02,S) and RTI.
---------------------------------------------

?BANK 00

?INCLUDE 'inventory_mgmt'

!inventorySlots                 0AB4
!inventoryEquippedIndex         0AC4

---------------------------------------------

; COP #D4 with one byte (item ID) and one &Code (overflow handler). Calls GiveItemToPlayer; on success (carry clear) skips the overflow branch, on failure (carry set, inventory full) jumps to the &Code overflow target. Side effects of GiveItemToPlayer: the item ID is stored at $0DB8 for the dialogue text, and Y returns a dialogue string pointer that this handler ignores (scripts show their own dialogue).

GiveItem {
    TYX 
    LDA [$0A]             ; Read item ID byte for GiveItemToPlayer
    INC $0A
    AND #$00FF
    JSL $@inventory_mgmt.GiveItemToPlayer ; Call GiveItemToPlayer; carry set = inventory full
    BCS loc_00AC1E        ; Carry set = inventory full: jump to overflow &Code handler
    LDA [$0A]             ; Success: skip overflow branch operand
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 

  loc_00AC1E:
    LDA [$0A]             ; Overflow: read &Code target and jump
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #D5 with one byte operand (item ID). Calls RemoveItemFromInventory (zeroes the matching slot and, as a side effect, resets the equipped state: inventoryEquippedType = 0, inventoryEquippedIndex = $FFFF) and continues.

RemoveItem {
    TYX 
    LDA [$0A]             ; Read item ID byte
    INC $0A
    AND #$00FF
    JSL $@inventory_mgmt.RemoveItemFromInventory ; JSL RemoveItemFromInventory on script item ID byte
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #D6 with one byte (item ID) and one &Code operand. Calls CheckInventoryForItem; branches to the &Code offset when the item is present (carry clear = found).

BranchIfHasItem {
    TYX 
    LDA [$0A]             ; Read item ID for inventory check
    INC $0A
    AND #$00FF
    JSL $@inventory_mgmt.CheckInventoryForItem ; CheckInventoryForItem; carry clear = found
    BCC loc_00AC51        ; Item found (carry clear): branch to &Code target
    LDA [$0A]
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 

  loc_00AC51:
    LDA [$0A]             ; Item found: read &Code branch target and jump
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #D7 with one byte (item ID) and one &Code operand. Compares the operand against inventorySlots[inventoryEquippedIndex]; branches to &Code when they match. inventorySlots is a 16-byte array ($0AB4–$0AC3, one item ID per byte; CheckInventoryForItem steps it with INY), so the index is a plain byte index. When nothing is equipped (index $FFFF, e.g. after RemoveItem) the indexed read wraps to $0AB3 — the byte before the array — so the compare reads unrelated data (analysis only, unverified at runtime).

BranchIfItemEquipped {
    TYX 
    LDA [$0A]             ; Read item ID byte for equipped check
    INC $0A
    AND #$00FF
    SEP #$20              ; 8-bit compare: item ID byte vs equipped slot in inventorySlots[equippedIndex]
    LDY $inventoryEquippedIndex ; Load equipped inventory slot index
    CMP $inventorySlots, Y ; Compare item ID against equipped slot
    REP #$20
    BEQ loc_00AC79        ; Match: take branch (item is equipped)
    LDA [$0A]             ; Not equipped: skip branch operand
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 

  loc_00AC79:
    LDA [$0A]             ; Equipped: read &Code target and jump
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}