; ==============================================================================
; Inventory slot actor - tab index and stack count display
; ==============================================================================
; What it does: Each inventory slot actor stores its grid index in $7F0010,X,
;   reads the item byte into $28, and when non-empty draws a numeric stack
;   count via InventoryCounters helpers before AnimOneFrame.
; Vanilla behavior: Slot actor only toggled visibility from $28 and animated.
; Hooks (overrides): inventory_menu InventorySlotActor, SlotActorEvaluate,
;   loc_02E8D9, loc_02E8DE.
; Depends on: inventory_menu (ComputeSlotPosition), InventoryCounters.patch.
; State: $7F0010 slot index scratch, $28 item/frame, $2A refresh flag, $10 DP.
; Hazards/notes: SetEntryHere loops; COP calls require X = actor slot id.
; ==============================================================================

inventory_menu.InventorySlotActor! {
    LDA $inventoryTabIndex
    STA $7F0010, X
    INC
    STA $inventoryTabIndex
    JSR $&ComputeSlotPosition

  inventory_menu.SlotActorEvaluate!:
    COP [SetEntryHere]
    LDA $7F0010, X
    TAY
    LDA $inventorySlots, Y
    AND #$00FF
    STA $28
    BNE loc_02E8D9
    
    LDA #$2000
    TSB $10
    COP [SetEntryHere]
    RTL 

  inventory_menu.loc_02E8D9!:
    JSR $&InventoryCountersGetCount
    STA $7F0012, X
    JSR $&InventoryCountersGenerateSprite

    LDA #$2000
    TRB $10

  inventory_menu.loc_02E8DE!:
    COP [SetEntryHere]
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_02E8DE
    RTL 
}
