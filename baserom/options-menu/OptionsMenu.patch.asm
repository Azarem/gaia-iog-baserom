; ==============================================================================
; Options Menu (module) - inventory tabs, item reorder, save-load remap hook
; ==============================================================================
; What it does: Replaces the four inventory tabs with Items / Remove / Status /
;   Optn.; wires the Optn. tab to options_menu_core; adds Run+confirm item
;   reorder in the Items tab; rebuilds joypad remap words after diary load.
; Vanilla behavior: Tabs were Items / Order / Remove / Cond.; no in-inventory
;   button UI; ApplySoundAndRemap set legacy Type-1/2 remap bytes from $0B26 only.
; Hooks (overrides): system_strings.consolestring_01E8E9 (tab labels);
;   inventory_menu.TabHoverDispatch / TabActionDispatch (fourth tab -> Optn.);
;   inventory_menu.UseItemCursorRight+ (anchor for reorder helpers);
;   sFA_diary_menu.ApplySoundAndRemap_ButtonTypeSelect / ApplySoundAndRemap_ButtonType2 (ApplySoundAndRemap tail ->
;   DetectAndInitButtonMap + ApplyButtonMapping).
; Adds: TabHoverStatusClear, UseItemReorderStart/Confirm/Cancel (reorder flow).
; Depends on: options_menu_core, options_input_remap, inventory_menu,
;   inventory_overlay, save_system, sFA_diary_menu, system_init.
; State: Button map bytes $0B34-$0B39 (save block); tab index $0AFA unchanged.
; Hazards: COP paths need X = actor slot; reorder uses $2E/$22 scratch like vanilla
;   Arrange flow; save hook must run after LoadGameState succeeds (diary paths).
; ==============================================================================

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
system_strings.consolestring_01E8E9! |[PAL:0][POS:84,5] Items[DBL] Relics[DBL] Status[DBL] Option|

; --- Tab hover dispatch (4 entries) ---
; TabHoverStatus does not clear the upper panel BG3 content on its own.
; TabHoverStatusClear wraps it to clear Options/other residual BG3 tiles.
inventory_menu.TabHoverDispatch! [
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
inventory_menu.TabActionDispatch! [
  &UseItemTab   ;00 Items
  &DiscardItemTab   ;01 Remove
  &StatusViewTab   ;02 Cond.
  &options_menu_core.OptionsTab   ;03 Optn.
]



; Place the following content after UseItemCursorRight to avoid branch distance issues
inventory_menu.UseItemCursorRight+ { }

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
sFA_diary_menu.ApplySoundAndRemap_ButtonTypeSelect!:
sFA_diary_menu.ApplySoundAndRemap_ButtonType2! {
    JSL $@options_input_remap.DetectAndInitButtonMap
    JSL $@options_input_remap.ApplyButtonMapping
    RTS
}

