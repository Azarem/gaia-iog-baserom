
; =============================================================================
; PHASE 2: Item Reorder — Run-button entry in Items tab
; =============================================================================

; Override UseItemRefreshCursor to add the reorder COP line.
; This sub-label contains the cursor positioning + button dispatch loop.
; The transform already changed #$C040 → #$0080 in the extracted code,
; but the override replaces the block entirely, so we use the new masks here.
UseItemRefreshCursor! {
    JSR $&PositionEquipCursor
    COP [RunBg3Script] ( @system_strings.consolestring_01E912 )
    LDY $1A
    LDA $inventorySlots, Y
    AND #$00FF
    STA $itemAbilityIndex
    COP [RunBg3Script] ( @system_strings.consolestring_01E9D0 )
    COP [SetEntryHereAndYield]
    COP [BranchIfPressed] ( #$C000, &UseItemConfirm )
    COP [BranchIfPressed] ( #$0044, &ArrangePickTarget )
    COP [BranchIfPressed] ( #$0800, &UseItemCursorUp )
    COP [BranchIfPressed] ( #$0400, &UseItemCursorDown )
    COP [BranchIfPressed] ( #$0200, &UseItemCursorLeft )
    COP [BranchIfPressed] ( #$0100, &UseItemCursorRight )
    RTL
}


ArrangePickTarget! {
    COP [PlaySoundCh2] ( #11 ) ; Source slot picked — play confirm sound
    LDA #$8000
    TSB $joypadHeld
    LDA $20               ; Save source cursor Y ($2C) and slot ($2E)
    STA $2C
    LDA $22
    STA $2E
    COP [SpawnAfterFlags] ( @SelectionCursorActor, #$0802 ) ; Spawn second cursor for swap target
    STY $20
    COP [RunBg3Script] ( @system_strings.consolestring_01E90B )
    COP [RunBg3Script] ( @system_strings.consolestring_01EA14 )
    COP [RunBg3Script] ( @system_strings.consolestring_01E9A6 )

  ArrangeTargetLoop!:
    JSR $&PositionGridCursor ; Position target cursor during swap pick
    COP [SetEntryHereAndYield]
    COP [BranchIfPressed] ( #$4000, &ArrangeCancelTarget ) ; Cancel target pick (Y/X)
    COP [BranchIfPressed] ( #$8044, &ArrangePerformSwap ) ; B confirms swap destination slot
    PEA $&ArrangeTargetLoop-1
    COP [BranchIfPressed] ( #$0800, &GridCursorUp )
    COP [BranchIfPressed] ( #$0400, &GridCursorDown )
    COP [BranchIfPressed] ( #$0200, &GridCursorLeft )
    COP [BranchIfPressed] ( #$0100, &GridCursorRight )
    PLA 
    RTL 
}

ArrangePerformSwap! {
    LDA #$8000            ; Swap: consume B; skip if source equals target
    TSB $joypadHeld
    LDA $22
    CMP $2E
    BEQ ArrangeTargetLoop
    COP [PlaySoundCh2] ( #11 )
    LDY $22               ; Swap inventory slot bytes (8-bit hi/lo pairs)
    SEP #$20
    LDA $inventorySlots, Y
    XBA 
    LDY $2E
    LDA $inventorySlots, Y
    XBA 
    STA $inventorySlots, Y
    XBA 
    LDY $22
    STA $inventorySlots, Y
    REP #$20
    LDY $2E               ; Refresh target slot actor sprite after swap
    LDA $inventorySlots, Y
    AND #$00FF
    PHA 
    TYA 
    JSR $&UpdateSlotActorSprite
    PLA 
    STA $0028, Y
    LDY $22               ; Refresh source slot actor sprite after swap
    LDA $inventorySlots, Y
    AND #$00FF
    PHA 
    TYA 
    JSR $&UpdateSlotActorSprite
    PLA 
    STA $0028, Y
    TYA                   ; Equipped index was target slot — follow to source
    CMP $inventoryEquippedIndex
    BNE loc_02E631
    LDA $2E
    STA $inventoryEquippedIndex
    BRA loc_02E63D

  loc_02E631!:
    LDA $2E               ; Equipped index was source slot — follow to target
    CMP $inventoryEquippedIndex
    BNE loc_02E63D
    LDA $22
    STA $inventoryEquippedIndex

;  loc_02E63D!:
;    PHX                   ; Kill saved source cursor actor via MarkDeath
;    PHD 
;    LDA $2C
;    TAX 
;    TCD 
;    COP [MarkDeath]
;    PLD 
;    PLX 
;    JMP $&ArrangeSourceReset
}
