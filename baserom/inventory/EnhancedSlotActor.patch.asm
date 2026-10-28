

InventorySlotActor! {
    LDA $inventoryTabIndex
    STA $7F0010, X
    INC
    STA $inventoryTabIndex
    JSR $&ComputeSlotPosition

  SlotActorEvaluate!:
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

  loc_02E8D9!:
    JSR $&InventoryCountersGetCount
    STA $7F0012, X
    JSR $&InventoryCountersGenerateSprite

    LDA #$2000
    TRB $10

  loc_02E8DE!:
    COP [SetEntryHere]
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_02E8DE
    RTL 
}
