?BANK 00

?INCLUDE 'inventory_mgmt'

!inventorySlots                 0AB4
!inventoryEquippedIndex         0AC4

---------------------------------------------

; COP #D4 with one byte (item ID) and one &Code (overflow handler). Calls GiveItemToPlayer; on success (carry clear) skips the overflow branch, on failure (carry set) jumps to the &Code overflow target.

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
; COP #D5 with one byte operand (item ID). Calls RemoveItemFromInventory and continues.

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
; COP #D6 with one byte (item ID) and one &Code operand. Calls CheckInventoryForItem; branches to the &Code offset when the item is absent (carry clear).

BranchIfMissingItem {
    TYX 
    LDA [$0A]             ; Read item ID for inventory check
    INC $0A
    AND #$00FF
    JSL $@inventory_mgmt.CheckInventoryForItem ; CheckInventoryForItem; carry clear = absent
    BCC loc_00AC51        ; Item absent (carry clear): branch to &Code target
    LDA [$0A]
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 

  loc_00AC51:
    LDA [$0A]             ; Item absent: read &Code branch target and jump
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #D7 with one byte (item ID) and one &Code operand. Compares the operand against inventorySlots[inventoryEquippedIndex]; branches to &Code when the equipped slot matches.

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