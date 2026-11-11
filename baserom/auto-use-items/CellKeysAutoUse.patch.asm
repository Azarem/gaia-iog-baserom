; ==============================================================================
; CellKeysAutoUse - auto-use mine keys on the double-locked cell door
; ==============================================================================
; What it does: At the mine foyer cell door, treats keys as already satisfied
;   when key_item_flags say Mine Key A/B were auto-consumed, skipping inventory
;   checks that vanilla BranchIfHasItem would require.
; Vanilla behavior: code_05D54B/code_05D552 each BranchIfHasItem (#0B / #0C) before
;   dialog or opening; missing keys show two-keyhole messages (dm44_cell_door).
; Hooks (overrides): dm44_cell_door.code_05D54B-= / code_05D552-= key checks.
; Depends on: !key_item_flags $0B58 (InventoryManagement); item IDs #0B, #0C.
; State: Reads $0B58 bits $0040 (key A) and $0080 (key B); flags $5B/$5C unchanged.
; Hazards/notes: COP interact context (X = actor slot); -= patches must stay in sync
;   with vanilla branch targets code_05D552 / code_05D56D.
; ==============================================================================

!key_item_flags      0B58

-------------------------------------------

dm44_cell_door.code_05D54B-= {
    LDA $key_item_flags
    BIT #$0040
    BNE code_05D552
}

dm44_cell_door.code_05D552-= {
    LDA $key_item_flags
    BIT #$0080
    BNE code_05D56D
}
