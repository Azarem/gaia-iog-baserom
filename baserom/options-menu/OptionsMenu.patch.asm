; =============================================================================
; Options Menu — Inventory restructure, item reorder, button mapping UI
; =============================================================================
;
; Module layer on top of the baserom InputRemap system.
; Adds the Options tab to the inventory menu for button remapping UI.
; Adds item reorder feature (Run-button in Items tab).
; Overrides ApplySoundAndRemap to call ApplyButtonMapping on save load.
;
; The baserom InputRemap.patch.asm + transforms.json handle all mask changes.
; This module only adds: tab restructure, reorder, options UI, save hooks.

?INCLUDE 'options_menu_core'
?INCLUDE 'options_input_remap'
?INCLUDE 'inventory_menu'
?INCLUDE 'inventory_overlay'
?INCLUDE 'system_strings'
?INCLUDE 'vblank_joypad'
?INCLUDE 'save_system'
?INCLUDE 'sFA_diary_menu'
?INCLUDE 'system_init'


!btnMapA                        0B34
!btnMapB                        0B35
!btnMapX                        0B36
!btnMapY                        0B37
!btnMapL                        0B38
!btnMapR                        0B39

; =============================================================================
; PHASE 0: Save byte defaults for new games
; =============================================================================

; Save bytes $0B34-$0B39 store the user's button assignments in compressed
; form for persistence across save/load.
; Note that this is not necessary, leaving them empty will allow the new game diary 
; load process to replace them with ones defined by DefaultButtonMap/AlternateButtonMap

;SystemInitConstants+ [
;  wram-init < #$0B34, #$42A0 >   ; Save: A=$A0(Cnf+Ark), B=$42(Cnc+Itm)
;  wram-init < #$0B36, #$1001 >   ; Save: X=$01(Cycle),   Y=$10(Run)
;  wram-init < #$0B38, #$0408 >   ; Save: L=$08(Cycle),   R=$04(Block)
;]

; =============================================================================
; PHASE 1: Menu Restructure — 4 tabs
; =============================================================================

; --- Tab sidebar labels ---
; Old: " Items / Order / Remove / Cond."
; New: " Items / Remove / Cond. / Optn."
consolestring_01E8E9! |[PAL:0][POS:84,5] Items[DBL] Relics[DBL] Status[DBL] Option|

; --- Tab hover dispatch (4 entries) ---
; TabHoverStatus does not clear the upper panel BG3 content on its own.
; TabHoverStatusClear wraps it to clear Options/other residual BG3 tiles.
TabHoverDispatch! [
  &TabHoverUse   ;00 Items
  &TabHoverDiscard   ;01 Remove
  &TabHoverStatusClear   ;02 Cond.
  &options_menu_core.TabHoverOptions   ;03 Optn.
]

; Clear wrapper: clears upper panel BG3 (rows 4-14) then runs original handler.
TabHoverStatusClear {
    COP [RunBg3Script] ( @system_strings.consolestring_01E8E2 )
    JMP $&TabHoverStatus
}

; --- Tab action dispatch ---
TabActionDispatch! [
  &UseItemTab   ;00 Items
  &DiscardItemTab   ;01 Remove
  &StatusViewTab   ;02 Cond.
  &options_menu_core.OptionsTab   ;03 Optn.
]



; Place the following content after UseItemCursorRight to avoid branch distance issues
UseItemCursorRight+ { }

; --- Reorder: pick source slot ---
UseItemReorderStart {
    LDA #$0044
    TSB $joypadHeld
    COP [PlaySoundCh2] ( #11 )

    ; Save source position
    LDA $1A
    STA $2E

    ; Spawn second cursor for target selection
    COP [SpawnAfterFlags] ( @SelectionCursorActor, #$0802 )
    STY $20

    ; Copy source slot to grid cursor
    LDA $2E
    STA $22

    COP [RunBg3Script] ( @system_strings.consolestring_01E90B )
    COP [RunBg3Script] ( @system_strings.consolestring_01EA02 )

  uir_target_loop:
    JSR $&PositionGridCursor
    COP [SetEntryHereAndYield]
    COP [BranchIfPressed] ( #$8044, &UseItemReorderConfirm )
    COP [BranchIfPressed] ( #$4000, &UseItemReorderCancel )
    PEA $&uir_target_loop-1
    COP [BranchIfPressed] ( #$0800, &GridCursorUp )
    COP [BranchIfPressed] ( #$0400, &GridCursorDown )
    COP [BranchIfPressed] ( #$0200, &GridCursorLeft )
    COP [BranchIfPressed] ( #$0100, &GridCursorRight )
    PLA
    RTL
}


; --- Reorder: confirm swap ---
UseItemReorderConfirm {
    LDA #$8044
    TSB $joypadHeld
    LDA $22
    CMP $2E
    BEQ uir_cancel_silent

    COP [PlaySoundCh2] ( #11 )

    ; Perform 8-bit byte swap of inventory slots
    LDY $22
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

    ; Refresh target slot actor sprite
    LDY $2E
    LDA $inventorySlots, Y
    AND #$00FF
    PHA
    TYA
    JSR $&UpdateSlotActorSprite
    PLA
    STA $0028, Y

    ; Refresh source slot actor sprite
    LDY $22
    LDA $inventorySlots, Y
    AND #$00FF
    PHA
    TYA
    JSR $&UpdateSlotActorSprite
    PLA
    STA $0028, Y

    ; Track equipped index across swap
    TYA
    CMP $inventoryEquippedIndex
    BNE uirc_check_source
    LDA $2E
    STA $inventoryEquippedIndex
    BRA uirc_done

  uirc_check_source:
    LDA $2E
    CMP $inventoryEquippedIndex
    BNE uirc_done
    LDA $22
    STA $inventoryEquippedIndex

  uirc_done:
    LDA $22
    STA $1A

  uir_cancel_silent:
    COP [KillNext]
    JMP $&InventoryMainLoop
}

; --- Reorder: cancel ---
UseItemReorderCancel {
    LDA #$4000
    TSB $joypadHeld
    COP [PlaySoundCh2] ( #0D )
    COP [KillNext]
    JMP $&InventoryMainLoop
}

; =============================================================================
; PHASE 3: Save data persistence
; =============================================================================

; Override ApplySoundAndRemap to call ApplyButtonMapping after sound setup.
; This module override supersedes the baserom InputRemap's sound-only version.
loc_0BE695!:
loc_0BE6B3! {
    JSL $@options_input_remap.DetectAndInitButtonMap
    JSL $@options_input_remap.ApplyButtonMapping
    RTS
}

