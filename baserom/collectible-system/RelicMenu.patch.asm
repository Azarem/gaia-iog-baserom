; ==============================================================================
; Inventory Relics tab - key-item grid and acquired-relic viewer
; ==============================================================================
; What it does: Replaces Discard tab UI with Relics: slot actors show key-item stacks via
;   KeyItemCountAndInit / InventoryCountersGenerateSprite; fourth tab lists owned relics with
;   name and description tables; ShowAllItemSlots routes key slots to isa_key_entry loop.
; Vanilla behavior: DiscardGridLoop discarded items; InventorySlotActor only AnimOneFrame;
;   ShowAllItemSlots always walked SlotActorEvaluate chain; status tab strings said Discard.
; Hooks (overrides): inventory_menu InventorySlotActor (loc_02E8DE+), Show/HideAllItemSlots,
;   ShowEquipCursor, DiscardGridLoop, InventoryMenuInit- / loc_02E3AB!; system_strings tab text.
; Adds: RelicMenuScanIcon (bank 02); isa_key_entry key-slot animation path in slot actor insert.
; Depends on: key_item_core (KeyItemCountAndInit, KeyItemGetNext, key_item_flags $0B58);
;   InventoryCountersGenerateSprite; item_name_line_table / item_description_table TBL tags.
; State: Scratch $7F0010-$7F001A,X slot actor chain; $18 tab index; $22 relic list cursor.
; Hazards/notes: Patch truncates HideAllItemSlots body (;...); verify against vanilla if extending.
; ==============================================================================
?BANK 02

!keyItemDisplayFrames    0060

RelicMenuScanIcon {
    STA $0000
    LDA $7F0010, X
    TAY
    
  rmis_loop:
    DEC $0000
    BMI rmis_end
    LDA $0006, Y
    TAY
    BRA rmis_loop
    
  rmis_end:
    LDA $0028, Y
    RTS
}

-----------------------------------------

inventory_menu.loc_02E8DE+ {

  isa_key_entry:
    COP [SetEntryHere]
    LDA $7F0010, X
    JSL $@KeyItemCountAndInit
    STA $7F0012, X
    STY $28
    CPY #$0000
    BNE kisa_key_shown
    LDA #$2000
    TSB $10
    COP [SetEntryHere]
    RTL 

  kisa_key_shown:
    CMP #$0002
    BCS kisa_multi_prep
    LDA #$FFFF
    STA $7F0018, X  ;Negate the display timer
    BRA kisa_key_prep

  kisa_multi_prep:
    LDA $0002   ;0002 is current index
    AND #$00FF
    STA $7F0014, X
    LDA #$keyItemDisplayFrames
    STA $7F0018, X    ;7F0018 is the current display timer
    LDA $7F0012, X
    JSR $&InventoryCountersGenerateSprite

  kisa_key_prep:
    LDA #$2000
    TRB $10

    COP [SetEntryHere]

  kisa_key_loop:
    COP [AnimOneFrame]
    LDA $7F0018, X
    BMI kisa_key_loop_continue
    BEQ kisa_key_swap
    DEC
    STA $7F0018, X
    BRA kisa_key_loop_continue

  kisa_key_swap:
    LDA $7F0014, X
    TAY
    LDA $7F0010, X
    JSL $@KeyItemGetNext
    STA $7F0014, X
    STY $28
    LDA #$keyItemDisplayFrames
    STA $7F0018, X
    STZ $2A
    BRA kisa_key_loop

  kisa_key_loop_continue:
    LDA $2A
    BEQ kisa_key_loop
    RTL 
}

---------------------------------------------

inventory_menu.ShowAllItemSlots! {
    LDA $18
    BEQ sais_entry_normal
    LDA #$1000
    TRB $10
    LDA #$8000
    LDY #$&isa_key_entry
    BRA sais_entry_check

  sais_entry_normal:
    LDA #$8000
    TRB $10
    LDA #$1000
    LDY #$&SlotActorEvaluate
    
  sais_entry_check:
    BIT $10
    BEQ loc_02EB22
    RTS

  inventory_menu.loc_02EB22!:
    TSB $10
    LDA #$1000
    TSB $06EE
    STZ $00DA

    LDA #$000F
    STY $0000
    STA $0002
    LDA $7F0010, X
    TAY 

  inventory_menu.loc_02EB32!:
    LDA $0010, Y
    AND #$DFFF
    STA $0010, Y

    LDA $0000
    STA $0000, Y
    LDA #$0000
    STA $0028, Y
    STA $0008, Y
    STA $002A, Y

    LDA $0006, Y
    TAY 
    DEC $0002
    BPL loc_02EB32
    RTS 
}

-------------------------------------

inventory_menu.HideAllItemSlots! {
    LDA $10
    BIT #$9000
    BNE loc_02EB4D
    RTS 

  inventory_menu.loc_02EB4D!:
    LDA #$1000
    TRB $06EE
    STZ $00DA
    LDA #$9000
    TRB $10
    LDA #$000F
    STA $0000
    LDA $7F0010, X
    TAY 
    
;...
}

-----------------------------------------------

inventory_menu.ShowEquipCursor! {
    LDA $18
    BNE HideEquipCursor
    LDA $inventoryEquippedIndex
    BMI HideEquipCursor
    LDA $7F0012, X
    TAY 
    LDA $0010, Y
    AND #$DFFF
    STA $0010, Y
    RTS 
}

-----------------------------------------------

system_strings.consolestring_01E962! |[PAL:0][POS:96,5]View acquired[DBL]Relics.|

system_strings.consolestring_01E9B7! |[PAL:0][POS:96,5][TBL:@item_name_line_table,AE8][TBL:@item_description_table,AE8]|

system_strings.consolestring_01EA27! |[PAL:0][POS:84,5]View[DBL]Relics|


  inventory_menu.DiscardGridLoop!:
    JSR $&PositionGridCursor
    COP [RunBg3Script] ( @system_strings.consolestring_01E912 )
    LDA $22
    JSR $&RelicMenuScanIcon
    STA $itemAbilityIndex
    COP [RunBg3Script] ( @system_strings.consolestring_01E9D0 )
    COP [SetEntryHereAndYield]
    COP [BranchIfPressed] ( #$4000, &DiscardCancelTab )
    ;COP [BranchIfPressed] ( #$8000, &DiscardAttempt )
    PEA $&DiscardGridLoop-1
    COP [BranchIfPressed] ( #$0800, &GridCursorUp )
    COP [BranchIfPressed] ( #$0400, &GridCursorDown )
    COP [BranchIfPressed] ( #$0200, &GridCursorLeft )
    COP [BranchIfPressed] ( #$0100, &GridCursorRight )
    PLA 
    RTL 
  
inventory_menu.InventoryMenuInit- {
    LDA #$1000
    TSB $06EE
    STZ $00DA
}
    
  inventory_menu.loc_02E3AB!:
    COP [SpawnAfterFlags] ( @InventorySlotActor, #$1800 )
    DEC $24
    BPL loc_02E3AB
    TYA 
    STA $7F0010, X
    COP [SpawnAfterFlags] ( @EquipCursorActor, #$0802 )
    TYA 
    STA $7F0012, X
    LDA $inventoryEquippedIndex
    STA $1A
    JSR $&PositionEquipCursor
    COP [SpawnAfterFlags] ( @EquippedItemDisplay, #$0800 )
    TYA 
    STA $7F0018, X
    COP [SpawnAfterFlags] ( @StatusAbilityRow2, #$0800 )
    COP [SpawnAfterFlags] ( @StatusAbilityRow1, #$0800 )
    COP [SpawnAfterFlags] ( @StatusAbilityRow0, #$0800 )
    TYA 
    STA $7F001A, X
    COP [SetEntryHereAndYield]
    STZ $inventoryTabIndex
    LDA #$1000
    TSB $10
