; Inventory menu UI system — full-screen inventory overlay with tab navigation, item management, and status display (189334–191746, Bank 02).
; 
; Implements the complete pause-menu inventory as an actor-def (InventoryMenuDef). The menu spawns 16 child actors for item slots, plus cursor, equipped-item display, and status row actors. Four tabs provide different inventory functions, each with its own input loop and display configuration.
; 
; === ARCHITECTURE ===
; 
; InventoryMenuInit spawns all child actors in a loop (16 InventorySlotActors, plus EquipCursorActor, EquippedItemDisplay, StatusCharRow1/2/3) and saves their actor indices in long-address scratch fields:
;   orbitAngle ($7F0010,X) = first slot actor Y index (linked list head)
;   orbitDiameter ($7F0012,X) = equip cursor actor Y index
;   moveXAlt ($7F0018,X) = equipped item display actor Y index
;   moveYAlt ($7F001A,X) = last status row actor Y index (chain head)
; 
; The main loop (InventoryMainLoop) runs TabSelectionLoop for tab navigation. Tab changes dispatch to TabHover* routines (preview) via SwitchCase on TabHoverDispatch. Tab confirmation dispatches to TabAction* routines via TabActionDispatch.
; 
; === TAB SYSTEM (4 tabs) ===
; 
; 0 = Use: Equip/unequip items. 4×4 grid cursor ($1A = slot index). B/Y/X confirms selection as equipped; selecting an empty slot or re-selecting clears equipment ($FFFF).
; 
; 1 = Arrange: Swap items between slots. Two-phase: pick source ($22) → pick target ($22/$2E). ArrangePerformSwap does an 8-bit byte swap in inventorySlots, updates both slot actor sprites via UpdateSlotActorSprite, and tracks inventoryEquippedIndex across the swap.
; 
; 2 = Discard: Remove items. Grid cursor selects a slot; CheckItemDiscardable gates via a bitfield table (BitMaskTable × system_strings.item_table_separator). If discardable, YesNoPromptLoop confirms. On yes: zeroes the slot's item byte (AND $FF00), updates sprite, clears equip state if discarding the equipped item.
; 
; 3 = Status: View character abilities. 3-row vertical cursor ($22 = 0/1/2). For each row, TestAbilityFlag checks whether the ability is unlocked for the current characterForm. Unlocked abilities show their name via ComputeAbilityIndex → RunBg3Script.
; 
; === GRID LAYOUT ===
; 
; 16 inventory slots arranged in a 4×4 grid. Slot index bits: low 2 bits = column (0-3), bits 2-3 = row (0-3). GridColumnPositions provides X positions for columns ($005C, $0074, $008C, $00A4). Y position = row × $10 + base ($0030 for grid, $0031 for slot actors). SlotPositionTable stores all 16 pre-computed screen positions.
; 
; Grid cursor navigation (GridCursorUp/Down/Left/Right): ±4 for vertical (skip one row = 4 columns), ±1 for horizontal, all AND $000F for wrapping.
; 
; === CURSOR BLINK ===
; 
; Both TabSelectionLoop and YesNoPromptLoop implement a frame-counter blink:
;   $1C increments each frame. Bits 0-3 ($000F): non-zero → skip draw/clear.
;   Bit 4 ($0010): 0 → draw cursor, 1 → clear cursor.
;   Result: cursor toggles visibility every 16 frames.
; 
; Tab cursor writes tile $202B (arrow glyph) to BG3 tilemap at $7F0200 + computed offset. Clear writes $2040 (blank) to all 4 tab cursor positions. YesNo cursor uses the same pattern at different offsets.
; 
; === ACTOR VISIBILITY ===
; 
; Actor flag bit 13 ($2000) in actor+$0010 controls render visibility: SET = hidden, CLEAR = visible.
; 
; The DP $10 bit $1000 tracks the toggle state to prevent redundant operations.
; 
; === ITEM DATA MODEL ===
; 
; inventorySlots ($0AB4): 16-byte array. Low byte = item ID (0 = empty), high byte = flags.
; inventoryEquippedIndex ($0AC4): Slot index of equipped item ($FFFF = nothing equipped).
; inventoryEquippedType ($0AC6): Item type ID of equipped item.
; itemAbilityIndex ($0AE8): Set before RunBg3Script to display item/ability descriptions.
; characterForm ($0AD4): Current character (0=Will, 1=Freedan, 2=Shadow) — affects status abilities.
; 
; === ABILITY SYSTEM ===
; 
; ComputeAbilityIndex: Maps (characterForm, abilitySlot) → global ability index = characterForm × 4 + slot + 1. Stored to itemAbilityIndex for description display.
; 
; TestAbilityFlag: Maps (characterForm, abilitySlot) → game flag index = characterForm × 4 + slot, calls TestFlag_0510. Returns carry set if the ability is unlocked.
; 
; CheckItemDiscardable: Tests item ID against a bitfield at system_strings.item_table_separator. Item ID >> 3 = byte index, item ID & 7 = bit via BitMaskTable. Returns carry set if item is non-discardable (quest item).
---------------------------------------------

?BANK 02

?INCLUDE 'flag_helpers'
?INCLUDE 'inventory_spritemap'
?INCLUDE 'system_strings'

!joypadHeld                     0658
!displayModeFlags               09EC
!inventorySlots                 0AB4
!inventoryEquippedIndex         0AC4
!inventoryEquippedType          0AC6
!characterForm                  0AD4
!bg1ConfigMode                  0AE6
!itemAbilityIndex               0AE8
!inventoryTabIndex              0AFA
!orbitAngle                     7F0010
!orbitDiameter                  7F0012
!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

; Actor-def wrapper for the inventory menu. Declares the actor definition header (#00, #00, #28) and contains InventoryMenuInit as the inline entry point.

InventoryMenuDef [
  actor-def < #00, #00, #28, {

; Initialize the inventory menu. Spawns 16 InventorySlotActors in a loop (counter $24 = 15→0), each receiving its item sprite from inventorySlots[i]. Saves the first slot actor index to orbitAngle. Spawns EquipCursorActor (saved to orbitDiameter), EquippedItemDisplay (saved to moveXAlt), and three StatusCharRow actors (last saved to moveYAlt). Positions the equip cursor at inventoryEquippedIndex, sets entry/exit point, initializes inventoryTabIndex = 0 and DP $10 bit $1000.

  InventoryMenuInit:
    COP [SetMetasprite] ( @inventory_spritemap ) ; InventoryMenuInit: set inventory menu metasprite
    COP [RunBg3Script] ( @system_strings.consolestring_01E869 )
    STZ $inventoryTabIndex ; Reset tab index to Use (0)
    LDA #$000F            ; $24 = 15 — reverse loop counter for slot actors
    STA $24

  loc_02E3AB:
    COP [SpawnAfterFlags] ( @InventorySlotActor, #$1800 ) ; Spawn InventorySlotActor for slots 15→0
    PHY                   ; Save spawned actor Y on stack
    LDY $24
    LDA $inventorySlots, Y ; Load item ID from inventorySlots[slot]
    AND #$00FF
    PLY 
    STA $0028, Y          ; Init slot actor sprite index ($0028,Y)
    DEC $24
    BPL loc_02E3AB
    TYA 
    STA $orbitAngle, X    ; orbitAngle = head of 16-slot actor linked list
    COP [SpawnAfterFlags] ( @EquipCursorActor, #$0802 ) ; Spawn EquipCursorActor (flags $0802)
    TYA 
    STA $orbitDiameter, X ; orbitDiameter = equip cursor actor Y
    LDA $inventoryEquippedIndex ; Copy inventoryEquippedIndex into Use-tab slot $1A
    STA $1A
    JSR $&PositionEquipCursor ; Position equip cursor on current $1A slot
    COP [SpawnAfterFlags] ( @EquippedItemDisplay, #$0800 )
    TYA 
    STA $moveXAlt, X      ; moveXAlt = equipped item display actor Y
    COP [SpawnAfterFlags] ( @StatusCharRow1, #$0800 ) ; Spawn three StatusCharRow actors for ability rows
    COP [SpawnAfterFlags] ( @StatusCharRow2, #$0800 )
    COP [SpawnAfterFlags] ( @StatusCharRow3, #$0800 )
    TYA 
    STA $moveYAlt, X      ; moveYAlt = status row chain head actor Y
    COP [SetEntryHereAndYield]
    STZ $inventoryTabIndex ; Clear tab index again before main loop
    LDA #$1000            ; Set $1000 in $10 — track item slot visibility state
    TSB $10

; Main menu event loop. Renders BG3 tab bar and info area via RunBg3Script, resets blink counter ($1C = 0), sets previous-tab tracker ($18 = $FFFF), consumes B button, and enters TabSelectionLoop. On confirm (carry set) → TabConfirmDispatch. On tab change (inventoryTabIndex ≠ $18) → SwitchCase through TabHoverDispatch. On cancel (carry clear, no change) → RTL exits menu.

  InventoryMainLoop:
    COP [RunBg3Script] ( @system_strings.consolestring_01E90B )
    COP [RunBg3Script] ( @system_strings.consolestring_01E8E9 )
    STZ $1C               ; Clear tab-hover debounce ($1C)
    LDA #$FFFF            ; $18 = $FFFF — no prior tab processed
    STA $18
    LDA #$8000            ; Mask B in joypadHeld during tab selection
    TSB $joypadHeld
    COP [SetEntryHereAndYield]
    JSR $&TabSelectionLoop
    BCS TabConfirmDispatch ; Tab confirmed with A — run action dispatch
    LDA $inventoryTabIndex ; Same tab as last frame — exit menu (RTL)
    CMP $18
    BNE loc_02E432
    RTL                   ; Tab unchanged — return to caller without redraw

  loc_02E432:
    STA $18               ; Tab changed — save index and run hover preview
    STA $0000
    COP [SwitchCase] ( #$0000, &TabHoverDispatch ) ; Dispatch tab hover preview by inventoryTabIndex
} >
]

---------------------------------------------
; Jump table for tab hover preview handlers. 4 entries: TabHoverUse (0), TabHoverArrange (1), TabHoverDiscard (2), TabHoverStatus (3).

TabHoverDispatch [
  &TabHoverUse   ;00
  &TabHoverArrange   ;01
  &TabHoverDiscard   ;02
  &TabHoverStatus   ;03
]

---------------------------------------------
; Play confirm SFX (#$0D), store current tab to $18 and $0000, dispatch through TabActionDispatch via SwitchCase.

TabConfirmDispatch {
    COP [PlaySoundCh2] ( #0D ) ; Tab confirm sound; dispatch confirmed tab action
    LDA $inventoryTabIndex
    STA $18
    STA $0000
    COP [SwitchCase] ( #$0000, &TabActionDispatch ) ; Dispatch confirmed tab handler (Use/Arrange/Discard/Status)
}

---------------------------------------------
; Jump table for tab action handlers. 4 entries: UseItemTab (0), ArrangeItemsTab (1), DiscardItemTab (2), StatusViewTab (3).

TabActionDispatch [
  &UseItemTab   ;00
  &ArrangeItemsTab   ;01
  &DiscardItemTab   ;02
  &StatusViewTab   ;03
]

---------------------------------------------
; Use/Equip tab action handler. Sets bg1ConfigMode = 4, draws item grid UI strings, resets inventoryEquippedIndex = 0, shows equip cursor. If $1A < 0 (no prior selection), resets to 0. Enters cursor positioning and button dispatch loop: A/X confirm ($C040), D-pad cursor movement. RTL returns to SetEntryExit yield.

UseItemTab {
    LDA #$0004            ; Use tab: bg1ConfigMode = 4 (items background)
    STA $bg1ConfigMode
    COP [RunBg3Script] ( @system_strings.consolestring_01E90B )
    COP [RunBg3Script] ( @system_strings.consolestring_01EA02 )
    COP [RunBg3Script] ( @system_strings.consolestring_01E975 )
    STZ $inventoryEquippedIndex ; Clear equipped slot on entering Use tab
    JSR $&ShowEquipCursor ; Show equip cursor entering Use tab
    LDA $1A               ; Use-tab cursor slot in $1A
    BPL code_02E47F
    STZ $1A               ; Clamp invalid negative $1A to slot 0

  code_02E47F:
    JSR $&PositionEquipCursor
    COP [RunBg3Script] ( @system_strings.consolestring_01E912 )
    LDY $1A
    LDA $inventorySlots, Y ; Item ID at cursor slot for description text
    AND #$00FF
    STA $itemAbilityIndex ; itemAbilityIndex for BG3 item detail strings
    COP [RunBg3Script] ( @system_strings.consolestring_01E9D0 )
    COP [SetEntryHereAndYield]
    COP [BranchIfPressed] ( #$C040, &UseItemConfirm ) ; B, Y, or X ($C040) confirms equip selection
    COP [BranchIfPressed] ( #$0800, &UseItemCursorUp )
    COP [BranchIfPressed] ( #$0400, &UseItemCursorDown )
    COP [BranchIfPressed] ( #$0200, &UseItemCursorLeft )
    COP [BranchIfPressed] ( #$0100, &UseItemCursorRight )
    RTL 
}

---------------------------------------------
; Move equip cursor up one row in Use tab. Consumes vertical D-pad bits ($0B00), plays SFX #10. $1A − 4 with AND $000F wrapping. Branches to code_02E47F.

UseItemCursorUp {
    LDA #$0B00            ; Move cursor up one row (−$4, AND $0F wrap)
    TSB $joypadHeld       ; Consume Up from joypadHeld
    COP [PlaySoundCh2] ( #10 )
    LDA $1A
    SEC 
    SBC #$0004
    AND #$000F
    STA $1A
    BRA code_02E47F
}

---------------------------------------------
; Move equip cursor down one row in Use tab. $1A + 4 with AND $000F wrapping.

UseItemCursorDown {
    LDA #$0700            ; Move cursor down one row (+$4, AND $0F wrap)
    TSB $joypadHeld
    COP [PlaySoundCh2] ( #10 )
    LDA $1A
    CLC 
    ADC #$0004
    AND #$000F
    STA $1A
    BRA code_02E47F
}

---------------------------------------------
; Move equip cursor left one column in Use tab. $1A − 1 with AND $000F wrapping.

UseItemCursorLeft {
    LDA #$0200            ; Move cursor left one column (DEC, AND $0F)
    TSB $joypadHeld
    COP [PlaySoundCh2] ( #10 )
    LDA $1A
    DEC 
    AND #$000F
    STA $1A
    BRA code_02E47F
}

---------------------------------------------
; Move equip cursor right one column in Use tab. $1A + 1 with AND $000F wrapping. Uses JMP instead of BRA (out of branch range).

UseItemCursorRight {
    LDA #$0100            ; Move cursor right one column (INC, AND $0F)
    TSB $joypadHeld
    COP [PlaySoundCh2] ( #10 )
    LDA $1A
    INC 
    AND #$000F
    STA $1A
    JMP $&code_02E47F
}

---------------------------------------------
; Confirm item selection in Use tab. Stores $1A → inventoryEquippedIndex. If slot is empty (item byte = 0): sets inventoryEquippedIndex = $FFFF, clears inventoryEquippedType. If non-empty: stores item type to inventoryEquippedType. Both paths return to InventoryMainLoop.

UseItemConfirm {
    LDA #$C040            ; Equip confirm: mask B+Y+X held
    TSB $joypadHeld
    COP [PlaySoundCh2] ( #11 )
    LDA $1A
    STA $inventoryEquippedIndex ; inventoryEquippedIndex = cursor slot $1A
    TAY 
    LDA $inventorySlots, Y ; Load item ID at equipped slot
    AND #$00FF
    BNE loc_02E530
    LDA #$FFFF            ; Empty slot — unequip ($FFFF) and clear type
    STA $inventoryEquippedIndex
    STA $1A
    STZ $inventoryEquippedType
    JMP $&InventoryMainLoop ; Unequipped — re-enter main tab loop

  loc_02E530:
    STA $inventoryEquippedType ; inventoryEquippedType = selected item type
    JMP $&InventoryMainLoop
}

---------------------------------------------
; Arrange tab action handler. Hides equip cursor, spawns SelectionCursorActor (saved to $20), initializes $22 = 0. Source selection loop: draws Arrange UI, positions grid cursor, listens for cancel → ArrangeCancelTab, confirm → ArrangePickTarget, D-pad → GridCursor* via PEA/RTS trick.

ArrangeItemsTab {
    JSR $&HideEquipCursor ; Arrange tab: hide equip cursor
    COP [SpawnAfterFlags] ( @SelectionCursorActor, #$0802 ) ; Spawn selection cursor for 4×4 grid
    STY $20               ; $20 = cursor actor Y; $22 = grid slot 0
    STZ $22

  code_02E544:
    STZ $1C               ; Clear tab-hover flag
    COP [RunBg3Script] ( @system_strings.consolestring_01E90B )
    COP [RunBg3Script] ( @system_strings.consolestring_01EA14 )
    COP [RunBg3Script] ( @system_strings.consolestring_01E98C )

  code_02E555:
    JSR $&PositionGridCursor ; Position grid selection cursor at slot $22
    COP [SetEntryHereAndYield]
    COP [BranchIfPressed] ( #$4040, &ArrangeCancelTab ) ; Y or X ($4040) cancels Arrange tab
    COP [BranchIfPressed] ( #$8000, &ArrangePickTarget ) ; B picks source slot for swap
    PEA $&code_02E555-1   ; Push resume address for shared grid navigation
    COP [BranchIfPressed] ( #$0800, &GridCursorUp )
    COP [BranchIfPressed] ( #$0400, &GridCursorDown )
    COP [BranchIfPressed] ( #$0200, &GridCursorLeft )
    COP [BranchIfPressed] ( #$0100, &GridCursorRight )
    PLA 
    RTL 
}

---------------------------------------------
; Second phase of Arrange: pick swap target. Saves source cursor ($20 → $2C, $22 → $2E), spawns second SelectionCursorActor, draws target selection UI. Confirm → ArrangePerformSwap, cancel → ArrangeCancelTarget.

ArrangePickTarget {
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

  code_02E5AC:
    JSR $&PositionGridCursor ; Position target cursor during swap pick
    COP [SetEntryHereAndYield]
    COP [BranchIfPressed] ( #$4040, &ArrangeCancelTarget ) ; Cancel target pick (Y/X)
    COP [BranchIfPressed] ( #$8000, &ArrangePerformSwap ) ; B confirms swap destination slot
    PEA $&code_02E5AC-1
    COP [BranchIfPressed] ( #$0800, &GridCursorUp )
    COP [BranchIfPressed] ( #$0400, &GridCursorDown )
    COP [BranchIfPressed] ( #$0200, &GridCursorLeft )
    COP [BranchIfPressed] ( #$0100, &GridCursorRight )
    PLA 
    RTL 
}

---------------------------------------------
; Execute item swap between source ($2E) and target ($22). Guards against same-slot swap (BEQ). 8-bit XBA swap of inventorySlots bytes. Updates both slot actor sprites via UpdateSlotActorSprite. Tracks inventoryEquippedIndex: if either slot was equipped, updates to new location. Kills source cursor via MarkDeath, returns to source selection.

ArrangePerformSwap {
    LDA #$8000            ; Swap: consume B; skip if source equals target
    TSB $joypadHeld
    LDA $22
    CMP $2E
    BEQ code_02E5AC
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

  loc_02E631:
    LDA $2E               ; Equipped index was source slot — follow to target
    CMP $inventoryEquippedIndex
    BNE loc_02E63D
    LDA $22
    STA $inventoryEquippedIndex

  loc_02E63D:
    PHX                   ; Kill saved source cursor actor via MarkDeath
    PHD 
    LDA $2C
    TAX 
    TCD 
    COP [MarkDeath]
    PLD 
    PLX 
    JMP $&code_02E544
}

---------------------------------------------
; Cancel target selection. COP KillNext kills second cursor, falls through to ArrangeCancelTab.

ArrangeCancelTarget {
    COP [KillNext]        ; Cancel target cursor (KillNext)
}

---------------------------------------------
; Cancel Arrange tab. KillNext kills cursor, consumes B/Y ($4040), returns to InventoryMainLoop.

ArrangeCancelTab {
    COP [KillNext]        ; Cancel Arrange tab — kill cursor, return to main loop
    LDA #$4040
    TSB $joypadHeld
    JMP $&InventoryMainLoop
}

---------------------------------------------
; Discard tab handler. Sets bg1ConfigMode = 4, hides equip cursor, spawns SelectionCursorActor. Grid cursor loop with confirm → code_02E6AA (discard attempt), cancel → DiscardCancelTab.

DiscardItemTab {
    LDA #$0004            ; Discard tab: bg1ConfigMode = 4 (items background)
    STA $bg1ConfigMode
    JSR $&HideEquipCursor ; Hide equip cursor for discard grid
    COP [SpawnAfterFlags] ( @SelectionCursorActor, #$0802 )
    STY $20
    STZ $22               ; Init discard cursor at grid slot 0

  code_02E66B:
    STZ $1C               ; Discard loop: reset tab-hover flag
    COP [RunBg3Script] ( @system_strings.consolestring_01E90B )
    COP [RunBg3Script] ( @system_strings.consolestring_01EA27 )
    COP [RunBg3Script] ( @system_strings.consolestring_01E9B7 )

  code_02E67C:
    JSR $&PositionGridCursor
    COP [SetEntryHereAndYield]
    COP [BranchIfPressed] ( #$4040, &DiscardCancelTab ) ; Y/X exits Discard tab
    COP [BranchIfPressed] ( #$8000, &code_02E6AA ) ; B selects slot to discard
    PEA $&code_02E67C-1
    COP [BranchIfPressed] ( #$0800, &GridCursorUp )
    COP [BranchIfPressed] ( #$0400, &GridCursorDown )
    COP [BranchIfPressed] ( #$0200, &GridCursorLeft )
    COP [BranchIfPressed] ( #$0100, &GridCursorRight )
    PLA 
    RTL 
}

---------------------------------------------
; Discard item attempt. If slot empty or non-discardable → SFX #12, retry. Shows item description, enters YesNoPromptLoop ($28 = 0 default). On confirm: $28 = 0 (No) → retry. $28 = 1 (Yes): zeroes item byte (AND $FF00), updates sprite, clears equip state if discarding equipped item, SFX #13.

code_02E6AA {
    LDA #$8000            ; Discard attempt: mask B held
    TSB $joypadHeld
    LDY $22               ; Load item ID in selected grid slot
    LDA $inventorySlots, Y
    AND #$00FF
    BEQ loc_02E705        ; Empty slot — play error sound and retry
    STA $itemAbilityIndex ; Set itemAbilityIndex for discardability check
    JSR $&CheckItemDiscardable ; CheckItemDiscardable — carry if item protected
    BCS loc_02E705
    COP [RunBg3Script] ( @system_strings.consolestring_01E912 )
    COP [RunBg3Script] ( @system_strings.consolestring_01E9E2 )
    STZ $28               ; Clear Yes/No prompt result ($28)
    COP [SetEntryHereAndYield]
    JSR $&YesNoPromptLoop ; Yes/No prompt — carry set if user chose Yes
    BCS loc_02E6D6
    RTL                   ; User declined discard — exit tab handler

  loc_02E6D6:
    LDA $28               ; User confirmed discard ($28 nonzero)
    BEQ loc_02E702
    LDY $22               ; Clear item ID byte; preserve high-byte flags
    LDA $inventorySlots, Y
    AND #$FF00
    STA $inventorySlots, Y
    LDA $22               ; Update slot actor sprite to empty
    JSR $&UpdateSlotActorSprite
    LDA $22               ; Discarded slot was equipped — clear equip state
    CMP $inventoryEquippedIndex
    BNE loc_02E6FC
    STZ $inventoryEquippedType
    LDA #$FFFF
    STA $inventoryEquippedIndex
    STA $1A

  loc_02E6FC:
    COP [PlaySoundCh2] ( #13 ) ; Discard success sound (#13)
    JMP $&code_02E66B

  loc_02E702:
    JMP $&code_02E66B

  loc_02E705:
    COP [PlaySoundCh2] ( #12 ) ; Protected/empty discard — error sound (#12)
    JMP $&code_02E66B
}

---------------------------------------------
; Cancel Discard tab. Consumes B/Y, kills cursor, shows equip cursor, returns to InventoryMainLoop.

DiscardCancelTab {
    LDA #$4040            ; Discard cancel: mask Y+X, kill cursor, show equip cursor
    TSB $joypadHeld
    COP [KillNext]
    JSR $&ShowEquipCursor
    JMP $&InventoryMainLoop
}

---------------------------------------------
; Status tab handler. Sets bg1ConfigMode = 0, draws status UI, spawns cursor. Vertical cursor ($22 = 0/1/2) selects ability rows. For each: TestAbilityFlag checks unlock, ComputeAbilityIndex + RunBg3Script shows name if unlocked. D-pad up/down moves, A/X/B/Y exits.

StatusViewTab {
    LDA #$0000            ; Status tab: bg1ConfigMode = 0 (status background)
    STA $bg1ConfigMode
    COP [RunBg3Script] ( @system_strings.consolestring_01E90B )
    COP [RunBg3Script] ( @system_strings.consolestring_01EA39 )
    COP [SpawnAfterFlags] ( @SelectionCursorActor, #$0802 )
    STY $20
    STZ $22               ; Status cursor starts at row 0 ($22)

  loc_02E734:
    JSR $&StatusPositionCursor ; Position cursor on status row $22
    COP [RunBg3Script] ( @system_strings.consolestring_01E912 )
    LDA $characterForm    ; Pass characterForm to ability flag test
    STA $0004
    LDA $22               ; Test whether party member has row $22 ability
    JSR $&TestAbilityFlag
    BCC loc_02E753
    LDA $22               ; Ability present — compute index and show description
    JSR $&ComputeAbilityIndex
    COP [RunBg3Script] ( @system_strings.consolestring_01EAB4 )

  loc_02E753:
    COP [SetEntryHereAndYield] ; Status view input poll entry point
    COP [BranchIfPressed] ( #$0800, &StatusCursorUp ) ; Up moves status cursor (wrap row 0 → 2)
    COP [BranchIfPressed] ( #$0400, &StatusCursorDown )
    COP [BranchIfPressed] ( #$C040, &StatusConfirmExit )
    RTL 
}

---------------------------------------------
; Move status cursor up. DEC $22; wraps 0 → 2 via BPL guard.

StatusCursorUp {
    LDA #$0800            ; Status cursor up — play move sound
    TSB $joypadHeld
    COP [PlaySoundCh2] ( #10 )
    LDA $22
    DEC 
    BPL loc_02E779
    LDA #$0002            ; Wrapped above row 0 — clamp to row 2

  loc_02E779:
    STA $22
    BRA loc_02E734
}

---------------------------------------------
; Move status cursor down. INC $22; wraps 3 → 0 via CMP #3 guard.

StatusCursorDown {
    LDA #$0400            ; Status cursor down — play move sound
    TSB $joypadHeld
    COP [PlaySoundCh2] ( #10 )
    LDA $22
    INC 
    CMP #$0003
    BCC loc_02E791
    LDA #$0000            ; Wrapped below row 2 — clamp to row 0

  loc_02E791:
    STA $22
    BRA loc_02E734
}

---------------------------------------------
; Exit Status tab. SFX #11, consumes A/X/B/Y ($C040), kills cursor, returns to InventoryMainLoop.

StatusConfirmExit {
    COP [PlaySoundCh2] ( #11 ) ; A confirms exit from Status view
    LDA #$C040
    TSB $joypadHeld
    COP [KillNext]
    JMP $&InventoryMainLoop
}

---------------------------------------------
; Position status cursor from StatusCursorPositions. $22 × 4 indexes the table; writes X/Y to cursor actor $0014/$0016,Y.

StatusPositionCursor {
    PHX                   ; StatusPositionCursor: row×4 → position table index
    LDY $20
    LDA $22
    ASL 
    ASL 
    TAX 
    LDA $@StatusCursorPositions, X ; Load cursor X/Y from StatusCursorPositions
    STA $0014, Y
    LDA $@StatusCursorPositions+2, X
    STA $0016, Y
    PLX 
    RTS 
}

---------------------------------------------
; Screen positions for 3 status rows: ($0098,$0048), ($0098,$0060), ($0098,$0078). Fixed X, Y increments by $18.

StatusCursorPositions [
  screen-pos < #$0098, #$0048 >   ;00
  screen-pos < #$0098, #$0060 >   ;01
  screen-pos < #$0098, #$0078 >   ;02
]

---------------------------------------------
; Use tab hover preview. Shows item slot actors (ShowAllItemSlots), shows equip cursor, hides status actors, draws Use tab UI, sets bg1ConfigMode = 4.

TabHoverUse {
    JSR $&ShowAllItemSlots ; Tab hover Use: hide slots, show equip cursor, hide status
    JSR $&ShowEquipCursor
    JSR $&HideStatusActors ; Hide status row actors for Use tab preview
    COP [RunBg3Script] ( @system_strings.consolestring_01E8E2 )
    COP [RunBg3Script] ( @system_strings.consolestring_01E912 )
    COP [RunBg3Script] ( @system_strings.consolestring_01E919 )
    LDA #$0004            ; Preview Use tab items background (mode 4)
    STA $bg1ConfigMode
    RTL 
}

---------------------------------------------
; Arrange tab hover preview. Shows item slots, shows equip cursor, draws Arrange description.

TabHoverArrange {
    JSR $&ShowAllItemSlots ; Tab hover Arrange: hide slots, keep equip cursor
    JSR $&ShowEquipCursor
    COP [RunBg3Script] ( @system_strings.consolestring_01E912 )
    COP [RunBg3Script] ( @system_strings.consolestring_01E954 )
    RTL 
}

---------------------------------------------
; Discard tab hover preview. Shows item slots, shows equip cursor, hides status actors, draws Discard UI, sets bg1ConfigMode = 4.

TabHoverDiscard {
    JSR $&ShowAllItemSlots ; Tab hover Discard: hide slots, hide status actors
    JSR $&ShowEquipCursor
    JSR $&HideStatusActors ; Hide status row actors for Discard preview
    COP [RunBg3Script] ( @system_strings.consolestring_01E912 )
    COP [RunBg3Script] ( @system_strings.consolestring_01E8E2 )
    COP [RunBg3Script] ( @system_strings.consolestring_01E962 )
    LDA #$0004            ; Preview Discard tab items background (mode 4)
    STA $bg1ConfigMode
    RTL 
}

---------------------------------------------
; Status tab hover preview. Hides item slots (HideAllItemSlots), hides equip cursor, draws status UI with character info. Shows equipped item display if equipped. Iterates 3 ability slots via $0006,Y linked list: checks TestAbilityFlag, shows actor and ability name if unlocked.

TabHoverStatus {
    JSR $&HideAllItemSlots ; Tab hover Status: show all slots, hide equip cursor
    JSR $&HideEquipCursor ; Hide equip cursor for Status tab preview
    COP [RunBg3Script] ( @system_strings.consolestring_01E912 )
    COP [RunBg3Script] ( @system_strings.consolestring_01E870 )
    COP [RunBg3Script] ( @system_strings.consolestring_01EA70 )
    LDA #$0000            ; Preview Status background (mode 0)
    STA $bg1ConfigMode
    LDA $moveXAlt, X      ; If item equipped, refresh display actor sprite
    TAY 
    LDA $inventoryEquippedIndex
    BMI loc_02E84A        ; No equipped item — skip display actor update
    LDA $inventoryEquippedType
    JSR $&SetSlotSprite   ; Set equipped item sprite on display actor
    LDA $0010, Y          ; Clear $2000 hidden flag on equipped display actor
    AND #$DFFF
    STA $0010, Y

  loc_02E84A:
    LDA $moveYAlt, X      ; Start at status row chain head (moveYAlt)
    STA $0002
    LDA $characterForm    ; Test Will (characterForm 0) ability on row 0
    STA $0004
    LDA #$0000
    JSR $&TestAbilityFlag
    BCC loc_02E876
    LDY $0002             ; Unhide status row actor if ability owned
    LDA $0010, Y
    AND #$DFFF
    STA $0010, Y
    LDA #$0000            ; Show Will ability description via BG3
    JSR $&ComputeAbilityIndex ; Compute ability index for Will row description
    COP [RunBg3Script] ( @system_strings.consolestring_01EA49 )

  loc_02E876:
    LDY $0002             ; Follow $0006 link to next status row actor
    LDA $0006, Y
    STA $0002
    LDA #$0001            ; Test Freedan (form 1) ability on row 1
    JSR $&TestAbilityFlag
    BCC loc_02E89E
    LDY $0002             ; Unhide Freedan row actor if ability owned
    LDA $0010, Y
    AND #$DFFF
    STA $0010, Y
    LDA #$0001            ; Show Freedan ability description
    JSR $&ComputeAbilityIndex ; Compute ability index for Freedan row description
    COP [RunBg3Script] ( @system_strings.consolestring_01EA56 )

  loc_02E89E:
    LDY $0002             ; Follow link to Shadow status row actor
    LDA $0006, Y
    STA $0002
    LDA #$0002            ; Test Shadow (form 2) ability on row 2
    JSR $&TestAbilityFlag
    BCC loc_02E8C6
    LDY $0002             ; Unhide Shadow row actor if ability owned
    LDA $0010, Y
    AND #$DFFF
    STA $0010, Y
    LDA #$0002            ; Show Shadow ability description
    JSR $&ComputeAbilityIndex ; Compute ability index for Shadow row description
    COP [RunBg3Script] ( @system_strings.consolestring_01EA63 )

  loc_02E8C6:
    RTL 
}

---------------------------------------------
; Per-slot item display actor. Increments inventoryTabIndex (spawn counter), calls ComputeSlotPosition for screen placement. Main loop: if $28 = 0 (empty) → set $2000 (hide) and yield. If nonzero → clear $2000 (show), animate until $2A triggers.

InventorySlotActor {
    INC $inventoryTabIndex ; Increment spawn counter (inventoryTabIndex → slot index)
    JSR $&ComputeSlotPosition ; Look up slot screen position via ComputeSlotPosition

  loc_02E8CD:
    COP [SetEntryHere]    ; Slot actor main loop entry
    LDA $28               ; Empty slot if item sprite frame ($28) is zero
    BNE loc_02E8D9
    LDA #$2000            ; Hide empty slot actor (TSB $2000 on flags)
    TSB $10
    RTL 

  loc_02E8D9:
    LDA #$2000            ; Item present — show slot (TRB $2000 hidden flag)
    TRB $10

  loc_02E8DE:
    COP [SetEntryHere]    ; Animate visible slot until $2A signals refresh
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_02E8DE
    RTL 
}

---------------------------------------------
; Equip cursor init. If inventoryEquippedIndex ≥ 0 → falls through to SelectionCursorActor. If negative ($FFFF) → set $2000 (hide) and fall through.

EquipCursorActor {
    LDA $inventoryEquippedIndex ; Equip cursor init — show only if item equipped
    BPL SelectionCursorActor
    LDA #$2000            ; No equipped item ($FFFF) — hide cursor (TSB $2000)
    TSB $10
}

---------------------------------------------
; Generic animated cursor actor. StageSprAndHitbox with sprite #40, SetEntryExit. Loop: SetEntryContinue + AnimOneFrame until $2A signals update.

SelectionCursorActor {
    COP [StageSprAndHitbox] ( #40 ) ; Stage cursor sprite #40 and register exit point
    COP [SetEntryHereAndYield]

  loc_02E8F6:
    COP [SetEntryHere]    ; Selection cursor anim loop until $2A update
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_02E8F6
    RTL 
}

---------------------------------------------
; Static equipped item icon at ($0028, $0078). Loads inventoryEquippedType as sprite, renders one frame.

EquippedItemDisplay {
    LDA #$0028            ; Equipped item display at screen X=$0028
    STA $14
    LDA #$0078            ; Equipped item display Y=$0078
    STA $16
    LDA $inventoryEquippedType ; Load inventoryEquippedType as sprite frame
    STA $28
    STZ $2A
    COP [SetEntryHere]
    COP [AnimOneFrame]
    RTL 
}

---------------------------------------------
; Ability row 3 actor (topmost, Y=$0048). Sprite = characterForm × 3 + $44.

StatusCharRow3 {
    LDA #$0098            ; Status row 3 (top) actor at X=$0098
    STA $14
    LDA #$0048            ; Status row 3 Y=$0048
    STA $16
    LDA $characterForm    ; Sprite = characterForm × 3 + row base offset
    ASL 
    CLC 
    ADC $characterForm
    CLC 
    ADC #$0044            ; Row 3 portrait base sprite #$0044
    STA $28
    STZ $2A
    COP [SetEntryHere]
    COP [AnimOneFrame]
    RTL 
}

---------------------------------------------
; Ability row 2 actor (middle, Y=$0060). Sprite = characterForm × 3 + $45.

StatusCharRow2 {
    LDA #$0098            ; Status row 2 actor at X=$0098
    STA $14
    LDA #$0060            ; Status row 2 Y=$0060
    STA $16
    LDA $characterForm    ; characterForm × 3 portrait sprite calc
    ASL 
    CLC 
    ADC $characterForm
    CLC 
    ADC #$0045            ; Row 2 portrait base offset #$0045
    STA $28
    STZ $2A
    COP [SetEntryHere]
    COP [AnimOneFrame]
    RTL 
}

---------------------------------------------
; Ability row 1 actor (bottom, Y=$0078). Sprite = characterForm × 3 + $46.

StatusCharRow1 {
    LDA #$0098            ; Status row 1 (bottom) at X=$0098
    STA $14
    LDA #$0078            ; Status row 1 Y=$0078
    STA $16
    LDA $characterForm    ; characterForm × 3 portrait sprite calc
    ASL 
    CLC 
    ADC $characterForm
    CLC 
    ADC #$0046            ; Row 1 portrait base offset #$0046
    STA $28
    STZ $2A
    COP [SetEntryHere]
    COP [AnimOneFrame]
    RTL 
}

---------------------------------------------
; Compute global ability index: characterForm × 4 + abilitySlot + 1 → itemAbilityIndex ($0AE8). The +1 skips reserved entry 0.

ComputeAbilityIndex {
    PHA                   ; ComputeAbilityIndex — preserve ability slot on stack
    LDA $characterForm    ; characterForm × 4 for per-character flag stride
    ASL 
    ASL 
    CLC 
    ADC $01, S            ; Add ability row slot from stack parameter
    INC 
    STA $itemAbilityIndex ; Store itemAbilityIndex (+1 skips reserved entry 0)
    PLA 
    RTS 
}

---------------------------------------------
; Grid cursor up. $22 − 4 (one row = 4 columns), AND $000F. Shared by Arrange/Discard via PEA/RTS. Returns RTS.

GridCursorUp {
    LDA #$0B00            ; Grid up — consume Up in joypadHeld ($0B00)
    TSB $joypadHeld
    COP [PlaySoundCh2] ( #10 )
    LDA $22               ; Move grid slot index up one row (−4 columns)
    SEC 
    SBC #$0004
    AND #$000F            ; Wrap 4×4 slot index AND $000F
    STA $22
    RTS 
}

---------------------------------------------
; Grid cursor down. $22 + 4, AND $000F.

GridCursorDown {
    LDA #$0700            ; Grid down — consume Down ($0700)
    TSB $joypadHeld
    COP [PlaySoundCh2] ( #10 )
    LDA $22               ; Move slot index down one row (+4)
    CLC 
    ADC #$0004
    AND #$000F            ; Wrap slot index AND $000F
    STA $22
    RTS 
}

---------------------------------------------
; Grid cursor left. DEC $22, AND $000F.

GridCursorLeft {
    LDA #$0200            ; Grid left — consume Left ($0200)
    TSB $joypadHeld
    COP [PlaySoundCh2] ( #10 )
    LDA $22               ; DEC column; wrap slot AND $000F
    DEC 
    AND #$000F
    STA $22
    RTS 
}

---------------------------------------------
; Grid cursor right. INC $22, AND $000F.

GridCursorRight {
    LDA #$0100            ; Grid right — consume Right ($0100)
    TSB $joypadHeld
    COP [PlaySoundCh2] ( #10 )
    LDA $22               ; INC column; wrap slot AND $000F
    INC 
    AND #$000F
    STA $22
    RTS 
}

---------------------------------------------
; Set actor sprite data: A → $0028,Y (frame), zero $002A,Y (anim) and $0008,Y (timer).

SetSlotSprite {
    STA $0028, Y          ; Set slot actor sprite frame (A → $28,Y)
    LDA #$0000            ; Clear anim trigger ($2A) and frame timer ($08)
    STA $002A, Y
    STA $0008, Y
    RTS 
}

---------------------------------------------
; Test ability unlock: flag index = $0004 (characterForm) × 4 + A (slot). Calls TestFlag_0510. Carry set = unlocked.

TestAbilityFlag {
    PHA                   ; TestAbilityFlag — save ability slot on stack
    LDA $0004             ; Flag index = characterForm × 4 + slot
    ASL 
    ASL 
    CLC 
    ADC $01, S
    STA $01, S
    PLA 
    JSL $@flag_helpers.TestFlag_0510 ; JSL TestFlag_0510 — carry set if ability unlocked
    RTS 
}

---------------------------------------------
; Walk slot actor linked list to Nth actor (A = slot index). At target: set function pointer to loc_02E8CD, zero sprite/anim/timer fields. Refreshes display after swap/discard.

UpdateSlotActorSprite {
    STA $000E             ; UpdateSlotActorSprite — A = slot index to refresh
    LDA $orbitAngle, X    ; Start at orbitAngle slot-actor linked-list head
    TAY 

  loc_02E9F5:
    DEC $000E             ; Walk $0006 chain to Nth slot actor
    BMI loc_02EA00
    LDA $0006, Y
    TAY 
    BRA loc_02E9F5

  loc_02EA00:
    LDA #$&loc_02E8CD     ; Reset actor to slot display loop (loc_02E8CD)
    STA $0000, Y
    LDA #$0000
    STA $0028, Y
    STA $0008, Y
    STA $002A, Y
    RTS 
}

---------------------------------------------
; Test if item is non-discardable. Item ID → byte index (>>3) + bit (& 7) via BitMaskTable. ANDs with system_strings.item_table_separator bitfield. Carry set = non-discardable (quest item).

CheckItemDiscardable {
    PHX                   ; CheckItemDiscardable — save index register
    STA $0000             ; Item ID → byte index (>>3) and bit (&7)
    LSR 
    LSR 
    LSR 
    TAY 
    LDA #$0000
    SEP #$20
    LDA $0000
    AND #$07
    TAX 
    LDA $@BitMaskTable, X ; AND bit against non-discardable item bitfield
    AND $&system_strings.item_table_separator, Y
    SEC                   ; Carry set = protected/quest item (not discardable)
    BNE loc_02EA31
    CLC 

  loc_02EA31:
    REP #$20
    PLX 
    RTS 
}

---------------------------------------------
; Single-bit mask lookup: $01,$02,$04,$08,$10,$20,$40,$80. Indexed by (item ID & 7).

BitMaskTable [
  #01   ;00
  #02   ;01
  #04   ;02
  #08   ;03
  #10   ;04
  #20   ;05
  #40   ;06
  #80   ;07
]

---------------------------------------------
; Position grid cursor actor from slot index. Primary: $22/$20, secondary: $2E/$2C (Arrange source). Bits 2-3 → column via GridColumnPositions, bits 4-5 → row offset ($0030 base + row × $10). Writes to actor $0014/$0016,Y.

PositionGridCursor {
    LDA $22               ; Position primary grid cursor from slot $22
    STA $0000
    LDY $20
    BRA loc_02EA4D

  loc_02EA46:
    LDA $2E               ; Arrange path: position source cursor from slot $2E
    STA $0000
    LDY $2C

  loc_02EA4D:
    PHX                   ; Slot×4 → extract grid column and row components
    LDA $0000
    ASL 
    ASL 
    PHA 
    AND #$000C            ; Column index from slot bits 2-3 (AND $000C)
    TAX 
    LDA #$0030            ; Row Y offset = base $0030 + row×$10
    AND $01, S
    STA $01, S
    LDA $@GridColumnPositions, X ; Load column X from GridColumnPositions
    STA $0014, Y
    LDA $@GridColumnPositions+2, X
    CLC 
    ADC $01, S
    STA $0016, Y
    PLA 
    PLX 
    RTS 
}

---------------------------------------------
; Position equip cursor at slot $1A. If $1A ≥ 0: same grid math as PositionGridCursor. If $1A < 0: hides cursor (ORA $2000).

PositionEquipCursor {
    LDA $1A               ; Equip cursor — hide if slot index $1A is negative
    BMI loc_02EAA1
    PHX 
    LDA $orbitDiameter, X ; Target equip cursor actor via orbitDiameter
    TAY 
    LDA $1A               ; Grid math for equipped slot index $1A
    ASL 
    ASL 
    PHA 
    AND #$000C            ; Equip slot column from bits 2-3
    TAX 
    LDA #$0030
    AND $01, S
    STA $01, S
    LDA $@GridColumnPositions, X
    STA $0014, Y
    LDA $@GridColumnPositions+2, X
    CLC 
    ADC $01, S
    STA $0016, Y
    PLA 
    PLX 
    RTS 

  loc_02EAA1:
    LDA $orbitDiameter, X ; Invalid equip slot — hide cursor (ORA $2000)
    TAY 
    LDA $0010, Y
    ORA #$2000
    STA $0010, Y
    RTS 
}

---------------------------------------------
; Grid column X positions: $005C, $0074, $008C, $00A4 (Y base = $0030).

GridColumnPositions [
  screen-pos < #$005C, #$0030 >   ;00
  screen-pos < #$0074, #$0030 >   ;01
  screen-pos < #$008C, #$0030 >   ;02
  screen-pos < #$00A4, #$0030 >   ;03
]

---------------------------------------------
; Hide 4 status actors by walking linked list (moveXAlt → moveYAlt → $0006,Y × 3). Sets $2000 on each. Correctly named.

HideStatusActors {
    LDA $moveXAlt, X      ; HideStatusActors — hide equipped-item display
    TAY 
    LDA $0010, Y
    ORA #$2000
    STA $0010, Y
    LDA $moveYAlt, X      ; Hide status row chain head (moveYAlt)
    TAY 
    LDA $0010, Y
    ORA #$2000
    STA $0010, Y
    LDA $0006, Y          ; Follow $0006 link — hide 2nd status row actor
    TAY 
    LDA $0010, Y
    ORA #$2000
    STA $0010, Y
    LDA $0006, Y          ; Follow $0006 link — hide 3rd status row actor
    TAY 
    LDA $0010, Y
    ORA #$2000
    STA $0010, Y
    RTS 
}

---------------------------------------------
; Show equip cursor (clear $2000). If nothing equipped, falls through to HideEquipCursor. Correctly named.

ShowEquipCursor {
    LDA $inventoryEquippedIndex ; ShowEquipCursor — skip if inventoryEquippedIndex < 0
    BMI HideEquipCursor
    LDA $orbitDiameter, X ; Unhide equip cursor actor (clear $2000 flag)
    TAY 
    LDA $0010, Y
    AND #$DFFF
    STA $0010, Y
    RTS 
}

---------------------------------------------
; Hide equip cursor (set $2000). Correctly named.

HideEquipCursor {
    LDA $orbitDiameter, X ; HideEquipCursor via orbitDiameter actor index
    TAY 
    LDA $0010, Y
    ORA #$2000
    STA $0010, Y
    RTS 
}

---------------------------------------------
; Show all 16 item slot actors. Guard: if DP $10 bit $1000 is already set, returns (already visible). Otherwise sets $1000 and walks the slot actor linked list (orbitAngle → $0006,Y chain × 16), CLEARING $2000 from each actor (making them visible).

ShowAllItemSlots {
    LDA $10               ; guard bit $1000
    BIT #$1000            ; Already showing slots — skip (bit $1000 set)
    BEQ loc_02EB22
    RTS 

  loc_02EB22:
    LDA #$1000            ; Enter slot-list mode — set actor flag bit $1000
    TSB $10
    LDA #$000F            ; Iterate 16 slot actors (counter 15→0)
    STA $0000
    LDA $orbitAngle, X    ; Walk orbitAngle linked list of slot actors
    TAY 

  loc_02EB32:
    LDA $0010, Y          ; Clear $2000 on slot actor — make visible
    AND #$DFFF
    STA $0010, Y
    LDA $0006, Y
    TAY 
    DEC $0000
    BPL loc_02EB32
    RTS 
}

---------------------------------------------
; Hide all 16 item slot actors. Guard: if DP $10 bit $1000 is NOT set, returns (already hidden). Otherwise clears $1000 and walks the slot actor linked list, SETTING $2000 on each actor (making them invisible).

HideAllItemSlots {
    LDA $10               ; guard bit $1000
    BIT #$1000            ; Slots already hidden — skip (bit $1000 clear)
    BNE loc_02EB4D
    RTS 

  loc_02EB4D:
    LDA #$1000            ; Exit slot-list mode — clear bit $1000
    TRB $10
    LDA #$000F            ; Loop counter for all 16 slot actors
    STA $0000
    LDA $orbitAngle, X    ; Walk slot-actor linked list from orbitAngle
    TAY 

  loc_02EB5D:
    LDA $0010, Y          ; Set $2000 on slot actor — hide icon
    ORA #$2000
    STA $0010, Y
    LDA $0006, Y
    TAY 
    DEC $0000
    BPL loc_02EB5D
    RTS 
}

---------------------------------------------
; Look up slot screen position. inventoryTabIndex − 1 (0-based) × 4 indexes SlotPositionTable. Writes to $14/$16.

ComputeSlotPosition {
    PHX                   ; ComputeSlotPosition — preserve X
    LDA $inventoryTabIndex ; 0-based slot index = inventoryTabIndex − 1
    DEC 
    ASL 
    ASL 
    TAX 
    LDA $@SlotPositionTable, X ; Look up slot X/Y from SlotPositionTable
    STA $14
    LDA $@SlotPositionTable+2, X
    STA $16
    PLX 
    RTS 
}

---------------------------------------------
; 16 slot screen positions. 4×4 grid: X = $005C/$0074/$008C/$00A4, Y = $0031/$0041/$0051/$0061.

SlotPositionTable [
  screen-pos < #$005C, #$0031 >   ;00
  screen-pos < #$0074, #$0031 >   ;01
  screen-pos < #$008C, #$0031 >   ;02
  screen-pos < #$00A4, #$0031 >   ;03
  screen-pos < #$005C, #$0041 >   ;04
  screen-pos < #$0074, #$0041 >   ;05
  screen-pos < #$008C, #$0041 >   ;06
  screen-pos < #$00A4, #$0041 >   ;07
  screen-pos < #$005C, #$0051 >   ;08
  screen-pos < #$0074, #$0051 >   ;09
  screen-pos < #$008C, #$0051 >   ;0A
  screen-pos < #$00A4, #$0051 >   ;0B
  screen-pos < #$005C, #$0061 >   ;0C
  screen-pos < #$0074, #$0061 >   ;0D
  screen-pos < #$008C, #$0061 >   ;0E
  screen-pos < #$00A4, #$0061 >   ;0F
]

---------------------------------------------
; Yes/No prompt input handler. A → YesNoConfirm, Up/Down → toggle $28. Blink counter $1C toggles draw/clear every 16 frames. Returns carry set on confirm.

YesNoPromptLoop {
    COP [BranchIfPressed] ( #$8000, &YesNoConfirm ) ; Yes/No prompt input — poll A / Up / Down
    COP [BranchIfPressed] ( #$0800, &YesNoSelectUp )
    COP [BranchIfPressed] ( #$0400, &YesNoSelectDown )
    LDA $1C               ; Blink timer $1C — toggle cursor every 16 frames
    INC $1C
    BIT #$000F            ; Test low nibble — time to flip cursor blink
    BEQ loc_02EBE3
    CLC 
    RTS 

  loc_02EBE3:
    BIT #$0010            ; Blink phase bit 4 — choose draw vs clear
    BNE loc_02EBED
    JSR $&YesNoDrawCursor ; Blink on — draw Yes/No cursor on BG3
    CLC 
    RTS 

  loc_02EBED:
    JSR $&YesNoClearCursor ; Blink off — clear Yes/No cursor tiles
    CLC 
    RTS 
}

---------------------------------------------
; Toggle Yes/No up. DEC $28, AND $0001. Redraws cursor.

YesNoSelectUp {
    COP [PlaySoundCh2] ( #10 ) ; Yes/No select up — toggle choice
    LDA #$0800            ; Mask Up held in joypadHeld ($0800)
    TSB $joypadHeld
    LDA $28               ; Toggle Yes/No selection ($28 DEC, wrap AND 1)
    DEC 
    AND #$0001
    STA $28
    STZ $1C
    JSR $&YesNoDrawCursor
    CLC 
    RTS 
}

---------------------------------------------
; Toggle Yes/No down. INC $28, AND $0001.

YesNoSelectDown {
    COP [PlaySoundCh2] ( #10 ) ; Yes/No select down — INC $28 AND #$0001
    LDA #$0400
    TSB $joypadHeld
    LDA $28
    INC 
    AND #$0001
    STA $28
    STZ $1C
    JSR $&YesNoDrawCursor
    CLC 
    RTS 
}

---------------------------------------------
; Confirm Yes/No. Consumes A, draws cursor, returns carry set.

YesNoConfirm {
    LDA #$8000            ; Confirm Yes/No — mask A; return carry set
    TSB $joypadHeld
    JSR $&YesNoDrawCursor
    SEC 
    RTS 
}

---------------------------------------------
; Draw Yes/No cursor on BG3. Offset = $28 × $0100 >> 1 + $0696. Tile $202B at $7F0200+offset.

YesNoDrawCursor {
    JSR $&YesNoClearCursor ; Draw Yes/No highlight cursor on BG3
    PHX 
    LDA $28               ; BG3 offset = ($28 × $0100 >> 1) + $0696
    AND #$00FF
    XBA 
    LSR 
    CLC 
    ADC #$0696
    TAX 
    LDA #$202B            ; Write cursor arrow tile $202B to $7F0200+X
    STA $7F0200, X
    PLX 
    RTS 
}

---------------------------------------------
; Clear Yes/No cursor positions. $2040 (blank) to $7F0896 and $7F0916. Sets displayModeFlags bit 0.

YesNoClearCursor {
    LDA #$0001            ; Clear Yes/No cursor tile positions
    TSB $displayModeFlags ; Mark BG3 tilemap dirty (displayModeFlags bit 0)
    LDA #$2040            ; Blank tile $2040 at Yes ($0896) and No ($0916)
    STA $7F0896
    STA $7F0916
    RTS 
}

---------------------------------------------
; Tab navigation handler. A → TabConfirm, Up/Down → TabSelect, B/Y/X → TabCancel. Blink $1C toggles cursor. Carry set = confirmed.

TabSelectionLoop {
    COP [BranchIfPressed] ( #$8000, &TabConfirm ) ; Tab selection loop — poll A/Up/Down/B/Y/X
    COP [BranchIfPressed] ( #$0800, &TabSelectUp )
    COP [BranchIfPressed] ( #$0400, &TabSelectDown )
    COP [BranchIfPressed] ( #$6040, &TabCancel ) ; Y/Select/X ($6040) cancels tab hover
    LDA $1C               ; Tab cursor blink counter increment
    INC $1C
    BIT #$000F
    BEQ loc_02EC7B
    CLC 
    RTS 

  loc_02EC7B:
    BIT #$0010            ; Tab blink phase — draw or clear cursor
    BNE loc_02EC85
    JSR $&TabDrawCursor   ; Blink on — draw tab cursor
    CLC 
    RTS 

  loc_02EC85:
    JSR $&TabClearCursor  ; Blink off — clear tab cursor tiles
    CLC 
    RTS 
}

---------------------------------------------
; Tab up. DEC inventoryTabIndex, AND $0003. Redraws cursor.

TabSelectUp {
    COP [PlaySoundCh2] ( #10 ) ; Tab select up — previous tab (wrap 4)
    LDA #$0800            ; Mask Up in joypadHeld
    TSB $joypadHeld
    STZ $1C
    LDA $inventoryTabIndex ; DEC inventoryTabIndex, wrap AND #$0003
    DEC 
    AND #$0003
    STA $inventoryTabIndex
    JSR $&TabDrawCursor
    CLC 
    RTS 
}

---------------------------------------------
; Tab down. INC inventoryTabIndex, AND $0003.

TabSelectDown {
    COP [PlaySoundCh2] ( #10 ) ; Tab select down — next tab (wrap 4)
    LDA #$0400
    TSB $joypadHeld
    STZ $1C
    LDA $inventoryTabIndex ; INC inventoryTabIndex, wrap AND #$0003
    INC 
    AND #$0003
    STA $inventoryTabIndex
    JSR $&TabDrawCursor
    CLC 
    RTS 
}

---------------------------------------------
; Tab cancel. SetFlagByte #00, carry clear.

TabCancel {
    COP [SetFlagByte] ( #00 ) ; Tab cancel — SetFlagByte #00, carry clear
    CLC 
    RTS 
}

---------------------------------------------
; Tab confirm. Consumes A, draws cursor, carry set.

TabConfirm {
    LDA #$8000            ; Tab confirm — mask A; return carry set
    TSB $joypadHeld
    JSR $&TabDrawCursor
    SEC 
    RTS 
}

---------------------------------------------
; Draw tab cursor on BG3. Offset = inventoryTabIndex × $0100 >> 1 + $0584. Tile $202B at $7F0200+offset.

TabDrawCursor {
    JSR $&TabClearCursor  ; Draw tab highlight cursor on BG3
    PHX 
    LDA $inventoryTabIndex ; BG3 offset = (inventoryTabIndex × $0100 >> 1) + $0584
    AND #$00FF
    XBA 
    LSR 
    CLC 
    ADC #$0584
    TAX 
    LDA #$202B            ; Write cursor arrow tile $202B at active tab
    STA $7F0200, X
    PLX 
    RTS 
}

---------------------------------------------
; Clear all 4 tab cursor positions. $2040 to $7F0784/$0804/$0884/$0904. Sets displayModeFlags bit 0.

TabClearCursor {
    LDA #$0001            ; Clear all four tab cursor positions on BG3
    TSB $displayModeFlags
    LDA #$2040            ; Blank tile $2040 at each tab column ($0784…$0904)
    STA $7F0784
    STA $7F0804
    STA $7F0884
    STA $7F0904
    RTS 
}