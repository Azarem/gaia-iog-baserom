; Inventory menu UI system — full-screen inventory overlay with tab navigation, item management, and status display (189334–191746, Bank 02).
; 
; Implements the complete pause-menu inventory as an actor-def (InventoryMenuDef). The menu spawns 16 child actors for item slots, plus cursor, equipped-item display, and status row actors. Four tabs provide different inventory functions, each with its own input loop and display configuration.
; 
; === ARCHITECTURE ===
; 
; InventoryMenuInit spawns all child actors in a loop (16 InventorySlotActors, plus EquipCursorActor, EquippedItemDisplay, StatusAbilityRow0/1/2) and saves their actor indices in long-address scratch fields:
;   orbitAngle ($7F0010,X) = first slot actor Y index (linked list head)
;   orbitDiameter ($7F0012,X) = equip cursor actor Y index
;   moveXAlt ($7F0018,X) = equipped item display actor Y index
;   moveYAlt ($7F001A,X) = last status row actor Y index (chain head)
; 
; The main loop (InventoryMainLoop) runs TabSelectionLoop for tab navigation. Tab changes dispatch to TabHover* routines (preview) via SwitchCase on TabHoverDispatch. Tab confirmation dispatches to TabAction* routines via TabActionDispatch.
; 
; === BUTTONS AND FRAME MODEL (this baserom) ===
; 
; BranchIfPressed tests joypadCurrent, the remapped logical bits. The menu uses two face-button bits: $8000 = confirm, $4000 = cancel. The baserom remap defaults (db-us/transforms.json) give physical A the value $8080, physical B $4008, X $0004, Y $0040 and Select $2000, so A confirms, B cancels, and X and Y are software-only bits that the menu ignores (except the widened swap mask, see ArrangePickTarget). A test with $C000 (UseItemTab, StatusViewTab) accepts A or B; the tab bar cancels on $6000 (B or Select). The diary menu can rebind the buttons, and the vanilla ROM tests different masks.
; 
; Consumption: TSB $joypadHeld masks the given bits out of joypadCurrent until the physical button is released. The code consumes exactly the bit it matched, so a consume of $8000 leaves the $0080 half of A's value visible (never tested here). A D-pad consume is wider than its direction: Up consumes $0B00 (Up, Left and Right) and Down consumes $0700 (Down, Left and Right), so one diagonal press moves one step; Left ($0200) and Right ($0100) consume only themselves.
; 
; Frame model: every handler is a COP script that yields with SetEntryHereAndYield / SetEntryHere + RTL and resumes at the saved entry point next frame. An RTL is therefore the idle path of a frame, never "exit the menu". The menu closes when TabCancel sets exit flag byte #00, which the main loop of inventory_overlay polls.
; 
; === TAB SYSTEM (4 tabs) ===
; 
; 0 = Use: Equip/unequip items. 4×4 grid cursor ($1A = slot index). A or B ($C000) confirms the cursor slot as the equipped item; confirming an empty slot clears the equipment ($FFFF). Entering the tab first writes inventoryEquippedIndex = 0 (a non-negative placeholder that lets ShowEquipCursor reveal the cursor); UseItemConfirm always overwrites it, because the tab can only end through the confirm. The tab title string reads "Gather Items".
; 
; 1 = Arrange: Swap items between slots. Two-phase: A picks the source slot ($22; B leaves the tab), then a second cursor picks the target (the source moves to $2E/$2C, the target cursor uses $22/$20; B cancels only the target). ArrangePerformSwap does an 8-bit byte swap in inventorySlots, updates both slot actor sprites via UpdateSlotActorSprite, and tries to keep inventoryEquippedIndex on the moved item. Only the case "the source slot was equipped" works: the case "the target slot was equipped" compares a slot actor address with a slot index and can never match (see the ArrangePerformSwap part note). Swapping a slot with itself is ignored.
; 
; 2 = Discard: Remove items. Grid cursor selects a slot; CheckItemDiscardable gates via a bitfield table (BitMaskTable × system_strings.non_discardable_item_bits). If discardable, YesNoPromptLoop asks "Discard? No / Yes" with the cursor on No ($28 = 0); only $28 = 1 (Yes) discards. On yes: zeroes the slot's item byte (AND #$FF00 on a 16-bit read/write: slots are single bytes, so the high byte is the NEXT slot, written back unchanged), updates the sprite, clears the equip state if the equipped item was discarded. Empty slots and protected items play SFX #12 instead.
; 
; 3 = Status: View character abilities. 3-row vertical cursor ($22 = 0/1/2). For each row, TestAbilityFlag checks whether the ability is unlocked for the current characterForm. Unlocked abilities show their name via ComputeAbilityIndex → RunBg3Script. The rows are the first three ability flags of the CURRENT form (row r tests flag $0510 + characterForm×4 + r, the same flags as abilityBitmask $0AA2); the form's fourth ability flag is never listed. A or B ($C000) leaves the tab.
; 
; === MYSTIC STATUE PEDESTALS ===
; 
; The inventory menu does NOT spawn or manage the mystic statue pedestal actors directly. Six inventory_statue_slot actors (Bank 00) are spawned independently by SpawnSceneActors from the scene $FF actor list. They share the screen with the inventory menu but operate as autonomous actors.
; 
; The pedestals are arranged symmetrically around the 4×4 item grid: 3 on the left (X ~24–40) and 3 on the right (X ~200–216), at three vertical positions (Y ~48, ~88, ~136). Each pedestal checks one of six event flags ($F8–$FD at $0A1F) via TestFlagRaw. If the flag is set (statue collected), the pedestal shows its inventory_spritemap sprite ($3A–$3F). If not set, the actor immediately dies (no display).
; 
; The statues auto-hide when inventoryTabIndex == 3 (Status tab) and show on all other tabs (Use/Arrange/Discard), matching the item grid visibility.
; 
; Flags are set by the statue_inventory_reward ceremony (scene $FD), triggered after defeating bosses:
;   $F8 = Gold Ship event, $F9 = Viper (Sky Garden), $FA = Vampires (Mu),
;   $FB = Sand Fanger (Great Wall), $FC = Mummy Queen (Pyramid), $FD = Olman (Babel Tower).
; 
; See inventory_statue_slot and statue_inventory_reward block notes (Bank 00) for complete data flow.
; 
; === GRID LAYOUT ===
; 
; 16 inventory slots arranged in a 4×4 grid. Slot index bits: low 2 bits = column (0-3), bits 2-3 = row (0-3). GridColumnPositions provides X positions for columns ($005C, $0074, $008C, $00A4). Y position = row × $10 + base ($0030 for grid, $0031 for slot actors). SlotPositionTable stores all 16 pre-computed screen positions.
; 
; Grid cursor navigation (GridCursorUp/Down/Left/Right): ±4 for vertical (skip one row = 4 columns), ±1 for horizontal, all AND $000F for wrapping. Left/Right do not wrap inside a row: column 3 + 1 lands on column 0 of the NEXT row and slot 15 + 1 wraps to slot 0 (the vertical moves wrap inside their column).
; 
; === CURSOR BLINK ===
; 
; Both TabSelectionLoop and YesNoPromptLoop implement a frame-counter blink:
;   $1C increments each frame. Bits 0-3 ($000F): non-zero → skip draw/clear.
;   Bit 4 ($0010): 0 → draw cursor, 1 → clear cursor.
;   Result: cursor toggles visibility every 16 frames.
; 
; Tab cursor writes tile $202B (arrow glyph) to BG3 tilemap at $7F0200 + computed offset. Clear writes a blank tile to all 4 tab cursor positions (tile $2060 in this baserom; db-us/transforms.json rewrites the vanilla constant). YesNo cursor uses the same pattern at different offsets.
; 
; === ACTOR VISIBILITY ===
; 
; Actor flag bit 13 ($2000) in actor+$0010 controls render visibility: SET = hidden, CLEAR = visible.
; 
; The menu actor's own DP $10 bit $1000 means "the 16 item slots are visible": set by InventoryMenuInit and ShowAllItemSlots, cleared by HideAllItemSlots. Both routines test it first, so repeated hover previews cost nothing.
; 
; === ITEM DATA MODEL ===
; 
; inventorySlots ($0AB4): 16 bytes, one item ID per slot (0 = empty), no per-slot flags. Code reads a slot as a 16-bit word and masks it (AND #$00FF); the high byte of that word is the next slot.
; inventoryEquippedIndex ($0AC4): Slot index of equipped item ($FFFF = nothing equipped).
; inventoryEquippedType ($0AC6): Item type ID of equipped item.
; itemAbilityIndex ($0AE8): Set before RunBg3Script to display item/ability descriptions.
; characterForm ($0AD4): Current character (0=Will, 1=Freedan, 2=Shadow) — affects status abilities.
; 
; === ABILITY SYSTEM ===
; 
; ComputeAbilityIndex: Maps (characterForm, abilitySlot) → global ability index = characterForm × 4 + slot + 1. Stored to itemAbilityIndex for description display.
; 
; TestAbilityFlag: Maps (characterForm, abilitySlot) → game flag index = characterForm × 4 + slot, calls TestFlag_0510. Returns carry set if the ability is unlocked (the current form is passed in $0004, not read from characterForm).
; 
; CheckItemDiscardable: Tests item ID against a bitfield at system_strings.non_discardable_item_bits (the 8 bytes are a "non-discardable items" bit table). Item ID >> 3 = byte index, item ID & 7 = bit via BitMaskTable. Returns carry set if item is non-discardable (quest item).
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
!bg3TilemapBuffer               7F0200

---------------------------------------------

; Actor-def wrapper for the inventory menu. Declares the actor definition header (#00, #00, #28) and contains InventoryMenuInit as the inline entry point.

InventoryMenuDef [
  actor-def < #00, #00, #28, {

; Initialize the inventory menu. Draws the first BG3 strings, spawns 16 InventorySlotActors in a loop (counter $24 = 15→0, so the last one spawned, slot 0, heads the actor chain because SpawnAfter inserts directly after the spawner), each given its item ID as sprite frame. Saves that head to orbitAngle. Spawns EquipCursorActor (orbitDiameter), EquippedItemDisplay (moveXAlt) and the three StatusAbilityRow actors (spawned in the order StatusAbilityRow2, StatusAbilityRow1, StatusAbilityRow0; moveYAlt = the last one spawned, StatusAbilityRow0, the top row). Positions the equip cursor at inventoryEquippedIndex, yields once, then resets inventoryTabIndex to 0 (the 16 slot actors used it as their spawn counter during that yield) and sets DP $10 bit $1000 (item slots visible).

  InventoryMenuInit:
    COP [SetMetasprite] ( @inventory_spritemap ) ; InventoryMenuInit: set inventory menu metasprite
    COP [RunBg3Script] ( @system_strings.consolestring_01E869 )
    STZ $inventoryTabIndex ; Tab index is also the spawn counter of the slot actors during the yield below
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
    COP [SpawnAfterFlags] ( @StatusAbilityRow2, #$0800 ) ; Spawn the three StatusAbilityRow actors (Row2, Row1, Row0), one per ability row
    COP [SpawnAfterFlags] ( @StatusAbilityRow1, #$0800 )
    COP [SpawnAfterFlags] ( @StatusAbilityRow0, #$0800 )
    TYA 
    STA $moveYAlt, X      ; moveYAlt = status row chain head actor Y
    COP [SetEntryHereAndYield]
    STZ $inventoryTabIndex ; The 16 slot actors incremented inventoryTabIndex while this actor yielded; reset it to tab 0
    LDA #$1000            ; Set $1000 in $10 — track item slot visibility state
    TSB $10

; Main menu event loop. Draws the BG3 tab bar and info strings, resets the blink counter ($1C = 0), sets the last-handled-tab tracker ($18 = $FFFF, so the first pass always runs a hover preview), consumes the confirm bit ($8000) and yields. Each frame it polls TabSelectionLoop: carry set (A pressed) → TabConfirmDispatch; otherwise, if inventoryTabIndex differs from $18, the new tab is stored and its hover preview runs through SwitchCase on TabHoverDispatch; if the tab is unchanged the RTL only ends this frame's turn (it does not close the menu; TabCancel's exit flag does).

  InventoryMainLoop:
    COP [RunBg3Script] ( @system_strings.consolestring_01E90B )
    COP [RunBg3Script] ( @system_strings.consolestring_01E8E9 )
    STZ $1C               ; Reset $1C, the tab-bar blink counter
    LDA #$FFFF            ; $18 = $FFFF — no prior tab processed
    STA $18
    LDA #$8000            ; Consume the confirm bit (physical A) so a held A cannot re-confirm a tab on return
    TSB $joypadHeld
    COP [SetEntryHereAndYield]
    JSR $&TabSelectionLoop
    BCS TabConfirmDispatch ; Tab confirmed with A — run action dispatch
    LDA $inventoryTabIndex ; No confirm: compare the cursor tab with the last handled tab ($18)
    CMP $18
    BNE loc_02E432
    RTL                   ; Tab unchanged: end of this frame (RTL yields, it does not close the menu)

  loc_02E432:
    STA $18               ; Tab changed (or first pass, $18 = $FFFF): remember it, run its hover preview
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
; Use tab action handler. Sets bg1ConfigMode = 4, draws the item grid strings, writes inventoryEquippedIndex = 0 (a non-negative placeholder so ShowEquipCursor reveals the cursor; UseItemConfirm always overwrites it), clamps $1A to 0 if negative, positions the equip cursor, prints the item name for the cursor slot via itemAbilityIndex, then polls every frame: A or B (mask $C000) → UseItemConfirm, D-pad → cursor moves. There is no cancel in this tab.

UseItemTab {
    LDA #$0004            ; Use tab: bg1ConfigMode = 4 (items background)
    STA $bg1ConfigMode
    COP [RunBg3Script] ( @system_strings.consolestring_01E90B )
    COP [RunBg3Script] ( @system_strings.consolestring_01EA02 )
    COP [RunBg3Script] ( @system_strings.consolestring_01E975 )
    STZ $inventoryEquippedIndex ; Set to 0, not $FFFF: non-negative so ShowEquipCursor reveals the cursor; UseItemConfirm overwrites it
    JSR $&ShowEquipCursor ; Show equip cursor entering Use tab
    LDA $1A               ; Use-tab cursor slot in $1A
    BPL UseItemRefreshCursor
    STZ $1A               ; Clamp invalid negative $1A to slot 0

; Use-tab loop head: positions the equip cursor from $1A, runs BG3 item list and detail scripts, yields, and branches on D-pad or confirm masks; entered from UseItemTab and after cursor moves.

  UseItemRefreshCursor:
    JSR $&PositionEquipCursor
    COP [RunBg3Script] ( @system_strings.consolestring_01E912 )
    LDY $1A
    LDA $inventorySlots, Y ; Item ID at cursor slot for description text
    AND #$00FF
    STA $itemAbilityIndex ; itemAbilityIndex for BG3 item detail strings
    COP [RunBg3Script] ( @system_strings.consolestring_01E9D0 )
    COP [SetEntryHereAndYield]
    COP [BranchIfPressed] ( #$C000, &UseItemConfirm ) ; Mask $C000: A or B (confirm or cancel bit) equips the cursor slot; the tab has no cancel
    COP [BranchIfPressed] ( #$0800, &UseItemCursorUp )
    COP [BranchIfPressed] ( #$0400, &UseItemCursorDown )
    COP [BranchIfPressed] ( #$0200, &UseItemCursorLeft )
    COP [BranchIfPressed] ( #$0100, &UseItemCursorRight )
    RTL 
}

---------------------------------------------
; Move the equip cursor up one row in the Use tab. Consumes Up, Left and Right ($0B00), SFX #10, $1A − 4 with AND $000F wrapping, then back to UseItemRefreshCursor.

UseItemCursorUp {
    LDA #$0B00            ; Consume Up, Left and Right ($0B00) so a diagonal press moves one step; up = slot −4
    TSB $joypadHeld       ; Consume Up from joypadHeld
    COP [PlaySoundCh2] ( #10 )
    LDA $1A
    SEC 
    SBC #$0004
    AND #$000F
    STA $1A
    BRA UseItemRefreshCursor
}

---------------------------------------------
; Move the equip cursor down one row in the Use tab. Consumes Down, Left and Right ($0700), SFX #10, $1A + 4 with AND $000F wrapping.

UseItemCursorDown {
    LDA #$0700            ; Consume Down, Left and Right ($0700); down = slot +4
    TSB $joypadHeld
    COP [PlaySoundCh2] ( #10 )
    LDA $1A
    CLC 
    ADC #$0004
    AND #$000F
    STA $1A
    BRA UseItemRefreshCursor
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
    BRA UseItemRefreshCursor
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
    JMP $&UseItemRefreshCursor
}

---------------------------------------------
; Confirm item selection in the Use tab. Consumes the confirm and cancel bits ($C000), stores $1A → inventoryEquippedIndex. Empty slot (item byte 0): inventoryEquippedIndex = $1A = $FFFF and inventoryEquippedType = 0. Otherwise stores the item ID in inventoryEquippedType. Both paths return to InventoryMainLoop.

UseItemConfirm {
    LDA #$C000            ; Consume the confirm and cancel bits ($C000)
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
; Arrange tab action handler. Hides the equip cursor, spawns SelectionCursorActor (saved to $20), sets $22 = 0. Source loop: B ($4000) → ArrangeCancelTab, A ($8000) → ArrangePickTarget, D-pad → GridCursor* via the PEA/RTS trick (PEA pushes ArrangeSourceLoop − 1 as the return address of the GridCursor* RTS; when no button matched, PLA discards it).

ArrangeItemsTab {
    JSR $&HideEquipCursor ; Arrange tab: hide equip cursor
    COP [SpawnAfterFlags] ( @SelectionCursorActor, #$0802 ) ; Spawn selection cursor for 4×4 grid
    STY $20               ; $20 = cursor actor Y; $22 = grid slot 0
    STZ $22

; Arrange tab setup after spawning the selection cursor: clears blink counter $1C, draws Arrange tab BG3 strings, then enters ArrangeSourceLoop.

  ArrangeSourceReset:
    STZ $1C               ; Reset $1C (the tab/Yes-No blink counter; the grid loops never read it)
    COP [RunBg3Script] ( @system_strings.consolestring_01E90B )
    COP [RunBg3Script] ( @system_strings.consolestring_01EA14 )
    COP [RunBg3Script] ( @system_strings.consolestring_01E98C )

; First-phase Arrange poll: positions the grid cursor at slot $22, yields, B cancels the tab, A picks a source slot via ArrangePickTarget, or D-pad navigation returns through a pushed resume address.

  ArrangeSourceLoop:
    JSR $&PositionGridCursor ; Position grid selection cursor at slot $22
    COP [SetEntryHereAndYield]
    COP [BranchIfPressed] ( #$4000, &ArrangeCancelTab ) ; Mask $4000: the cancel bit (physical B by default) leaves the Arrange tab
    COP [BranchIfPressed] ( #$8000, &ArrangePickTarget ) ; Confirm bit (physical A by default) picks the source slot
    PEA $&ArrangeSourceLoop-1 ; Push resume address for shared grid navigation
    COP [BranchIfPressed] ( #$0800, &GridCursorUp )
    COP [BranchIfPressed] ( #$0400, &GridCursorDown )
    COP [BranchIfPressed] ( #$0200, &GridCursorLeft )
    COP [BranchIfPressed] ( #$0100, &GridCursorRight )
    PLA 
    RTL 
}

---------------------------------------------
; Second phase of Arrange: pick the swap target. Saves the source cursor ($20 → $2C, $22 → $2E), spawns a second SelectionCursorActor, draws the target strings. B ($4000) → ArrangeCancelTarget; mask $8044 → ArrangePerformSwap. The vanilla ROM tests only the confirm bit here; the transform widens it to $8044, which also accepts the X ($0004) and Y ($0040) bits of the default remap.

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

; Second-phase Arrange poll after a source slot is saved in $2E/$2C: positions the target cursor, B cancels target pick, confirm mask $8044 runs ArrangePerformSwap, else grid navigation loops.

  ArrangeTargetLoop:
    JSR $&PositionGridCursor ; Position target cursor during swap pick
    COP [SetEntryHereAndYield]
    COP [BranchIfPressed] ( #$4000, &ArrangeCancelTarget ) ; Cancel target pick (Y/X)
    COP [BranchIfPressed] ( #$8044, &ArrangePerformSwap ) ; Mask $8044 also accepts the X and Y bits of the default remap; the vanilla ROM tests only the confirm bit
    PEA $&ArrangeTargetLoop-1
    COP [BranchIfPressed] ( #$0800, &GridCursorUp )
    COP [BranchIfPressed] ( #$0400, &GridCursorDown )
    COP [BranchIfPressed] ( #$0200, &GridCursorLeft )
    COP [BranchIfPressed] ( #$0100, &GridCursorRight )
    PLA 
    RTL 
}

---------------------------------------------
; Execute the swap between source ($2E) and target ($22). Consumes the confirm bit; same-slot is ignored (back to the target loop). 8-bit swap of inventorySlots[$22] and [$2E] through XBA. Refreshes both slot actors: UpdateSlotActorSprite returns Y = the slot ACTOR, which is why STA $0028,Y after it addresses the actor. Equipped tracking: the first test (TYA; CMP inventoryEquippedIndex) compares that actor address, not a slot index, so "target slot was equipped" never matches; the second test (source slot equipped → follow to $22) works. Kills the saved source cursor ($2C) via MarkDeath and returns to the source loop.

ArrangePerformSwap {
    LDA #$8000            ; Consume the confirm bit; a swap of a slot with itself is ignored (next check)
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
    LDY $2E               ; Refresh the source slot ($2E) actor sprite after swap
    LDA $inventorySlots, Y
    AND #$00FF
    PHA 
    TYA 
    JSR $&UpdateSlotActorSprite ; Returns with Y = the slot actor (not the slot index); STA $0028,Y below relies on that
    PLA 
    STA $0028, Y
    LDY $22               ; Refresh the target slot ($22) actor sprite after swap
    LDA $inventorySlots, Y
    AND #$00FF
    PHA 
    TYA 
    JSR $&UpdateSlotActorSprite ; Same: Y = the target slot actor after the call
    PLA 
    STA $0028, Y
    TYA                   ; Y is now a slot ACTOR address, so this compare with the slot index never matches
    CMP $inventoryEquippedIndex
    BNE loc_02E631
    LDA $2E
    STA $inventoryEquippedIndex
    BRA loc_02E63D

  loc_02E631:
    LDA $2E               ; Source slot was equipped: the equipped index follows the item to the target slot ($22)
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
    JMP $&ArrangeSourceReset
}

---------------------------------------------
; Cancel target selection. COP KillNext kills second cursor, falls through to ArrangeCancelTab.

ArrangeCancelTarget {
    COP [KillNext]        ; Cancel target cursor (KillNext)
}

---------------------------------------------
; Cancel the Arrange tab. KillNext removes the cursor, the cancel bit ($4000) is consumed, and control returns to InventoryMainLoop.

ArrangeCancelTab {
    COP [KillNext]        ; Cancel Arrange tab — kill cursor, return to main loop
    LDA #$4000            ; Consume the cancel bit ($4000)
    TSB $joypadHeld
    JMP $&InventoryMainLoop
}

---------------------------------------------
; Discard tab handler. Sets bg1ConfigMode = 4, hides the equip cursor, spawns SelectionCursorActor, $22 = 0. Grid loop: B ($4000) → DiscardCancelTab, A ($8000) → DiscardAttempt (discard attempt), D-pad → GridCursor*.

DiscardItemTab {
    LDA #$0004            ; Discard tab: bg1ConfigMode = 4 (items background)
    STA $bg1ConfigMode
    JSR $&HideEquipCursor ; Hide equip cursor for discard grid
    COP [SpawnAfterFlags] ( @SelectionCursorActor, #$0802 )
    STY $20
    STZ $22               ; Init discard cursor at grid slot 0

; Discard tab setup: clears $1C, draws Discard tab BG3 strings, then enters DiscardGridLoop.

  DiscardGridReset:
    STZ $1C               ; Reset $1C (the grid loops never read it)
    COP [RunBg3Script] ( @system_strings.consolestring_01E90B )
    COP [RunBg3Script] ( @system_strings.consolestring_01EA27 )
    COP [RunBg3Script] ( @system_strings.consolestring_01E9B7 )

; Discard tab poll: positions cursor, B leaves the tab, A runs DiscardAttempt, D-pad moves the grid with resume on the stack.

  DiscardGridLoop:
    JSR $&PositionGridCursor
    COP [SetEntryHereAndYield]
    COP [BranchIfPressed] ( #$4000, &DiscardCancelTab ) ; Mask $4000: the cancel bit (physical B by default) leaves the Discard tab
    COP [BranchIfPressed] ( #$8000, &DiscardAttempt ) ; Confirm bit (physical A by default) tries to discard the slot
    PEA $&DiscardGridLoop-1
    COP [BranchIfPressed] ( #$0800, &GridCursorUp )
    COP [BranchIfPressed] ( #$0400, &GridCursorDown )
    COP [BranchIfPressed] ( #$0200, &GridCursorLeft )
    COP [BranchIfPressed] ( #$0100, &GridCursorRight )
    PLA 
    RTL 
}

---------------------------------------------
; Discard attempt. Consumes the confirm bit. Empty slot or protected item (CheckItemDiscardable carry set) → SFX #12 and back to the grid. Otherwise draws the item name and the "Discard? No / Yes" prompt ($28 = 0 = No) and polls YesNoPromptLoop once per frame (RTL while carry is clear). Answer No ($28 = 0) → back to the grid. Answer Yes: clears the slot's item byte (16-bit AND #$FF00 keeps the next slot's byte), refreshes the slot actor, clears inventoryEquippedIndex/Type and $1A if that slot was equipped, SFX #13.

DiscardAttempt {
    LDA #$8000            ; Consume the confirm bit
    TSB $joypadHeld
    LDY $22               ; Load item ID in selected grid slot
    LDA $inventorySlots, Y
    AND #$00FF
    BEQ loc_02E705        ; Empty slot — play error sound and retry
    STA $itemAbilityIndex ; Item ID for the name string drawn below (CheckItemDiscardable takes the ID in A, not this)
    JSR $&CheckItemDiscardable ; CheckItemDiscardable — carry if item protected
    BCS loc_02E705
    COP [RunBg3Script] ( @system_strings.consolestring_01E912 )
    COP [RunBg3Script] ( @system_strings.consolestring_01E9E2 )
    STZ $28               ; Clear Yes/No prompt result ($28)
    COP [SetEntryHereAndYield]
    JSR $&YesNoPromptLoop ; Yes/No prompt — carry set if user chose Yes
    BCS loc_02E6D6        ; Carry set = prompt answered
    RTL                   ; Prompt still open: yield; the entry point above resumes at the JSR next frame

  loc_02E6D6:
    LDA $28               ; User confirmed discard ($28 nonzero)
    BEQ loc_02E702        ; $28 = 0 is "No": back to the grid, nothing removed
    LDY $22               ; Y = slot index of the discarded item (from $22)
    LDA $inventorySlots, Y
    AND #$FF00            ; Clear this slot's item byte; the 16-bit write keeps the next slot's byte (slots are bytes)
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
    JMP $&DiscardGridReset

  loc_02E702:
    JMP $&DiscardGridReset

  loc_02E705:
    COP [PlaySoundCh2] ( #12 ) ; Protected/empty discard — error sound (#12)
    JMP $&DiscardGridReset
}

---------------------------------------------
; Cancel the Discard tab. Consumes the cancel bit ($4000), kills the cursor, shows the equip cursor again, returns to InventoryMainLoop.

DiscardCancelTab {
    LDA #$4000            ; Consume the cancel bit ($4000), kill the cursor, show the equip cursor again
    TSB $joypadHeld
    COP [KillNext]
    JSR $&ShowEquipCursor
    JMP $&InventoryMainLoop
}

---------------------------------------------
; Status tab handler. Sets bg1ConfigMode = 0, draws the status strings, spawns a cursor, $22 = 0. For the row in $22 it tests the ability flag of the current form (TestAbilityFlag with $0004 = characterForm) and, if unlocked, prints its description (ComputeAbilityIndex + RunBg3Script). Polls Up/Down for the row cursor and $C000 (A or B) → StatusConfirmExit.

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
    COP [BranchIfPressed] ( #$C000, &StatusConfirmExit ) ; Mask $C000: A or B leaves the Status tab
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
; Exit the Status tab. SFX #11, consumes the confirm and cancel bits ($C000), kills the cursor, returns to InventoryMainLoop.

StatusConfirmExit {
    COP [PlaySoundCh2] ( #11 ) ; A or B exits the Status tab (confirm SFX)
    LDA #$C000            ; Consume the confirm and cancel bits ($C000)
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
; Use tab hover preview. Shows the 16 item slots (ShowAllItemSlots), shows the equip cursor if something is equipped, hides the equipped-item display and the status rows (HideStatusActors), draws the Use tab strings and sets bg1ConfigMode = 4.

TabHoverUse {
    JSR $&ShowAllItemSlots ; Use preview: SHOW the 16 item slots (guarded by $10 bit $1000), then the equip cursor
    JSR $&ShowEquipCursor
    JSR $&HideStatusActors ; Hide the equipped-item display and the three status rows
    COP [RunBg3Script] ( @system_strings.consolestring_01E8E2 )
    COP [RunBg3Script] ( @system_strings.consolestring_01E912 )
    COP [RunBg3Script] ( @system_strings.consolestring_01E919 )
    LDA #$0004            ; Preview Use tab items background (mode 4)
    STA $bg1ConfigMode
    RTL 
}

---------------------------------------------
; Arrange tab hover preview. Shows the item slots and the equip cursor and draws the Arrange description. It does not hide the status actors: the neighbours of tab 1 are the Use and Discard previews, which already did.

TabHoverArrange {
    JSR $&ShowAllItemSlots ; Arrange preview: show the item slots and the equip cursor
    JSR $&ShowEquipCursor
    COP [RunBg3Script] ( @system_strings.consolestring_01E912 )
    COP [RunBg3Script] ( @system_strings.consolestring_01E954 )
    RTL 
}

---------------------------------------------
; Discard tab hover preview. Shows the item slots and the equip cursor, hides the equipped-item display and status rows, draws the Discard strings and sets bg1ConfigMode = 4.

TabHoverDiscard {
    JSR $&ShowAllItemSlots ; Discard preview: show the item slots and the equip cursor
    JSR $&ShowEquipCursor
    JSR $&HideStatusActors ; Hide the equipped-item display and the three status rows
    COP [RunBg3Script] ( @system_strings.consolestring_01E912 )
    COP [RunBg3Script] ( @system_strings.consolestring_01E8E2 )
    COP [RunBg3Script] ( @system_strings.consolestring_01E962 )
    LDA #$0004            ; Preview Discard tab items background (mode 4)
    STA $bg1ConfigMode
    RTL 
}

---------------------------------------------
; Status tab hover preview. HIDES the 16 item slots and the equip cursor, draws the status strings (character info), shows the equipped-item display if something is equipped, then walks the three status row actors (chain head moveYAlt = StatusAbilityRow0, the top row, then the $0006 links). For row r = 0..2 it tests flag characterForm×4 + r (TestAbilityFlag); if set it unhides the row actor and prints the ability name (ComputeAbilityIndex + RunBg3Script). The rows are ability slots 0–2 of the current form, not Will/Freedan/Shadow.

TabHoverStatus {
    JSR $&HideAllItemSlots ; Status preview: HIDE the 16 item slots (clears $10 bit $1000), then the equip cursor
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
    LDA $characterForm    ; Row 0 test: flag characterForm×4 + 0, i.e. the current form's ability slot 0
    STA $0004
    LDA #$0000
    JSR $&TestAbilityFlag
    BCC loc_02E876
    LDY $0002             ; Unhide status row actor if ability owned
    LDA $0010, Y
    AND #$DFFF
    STA $0010, Y
    LDA #$0000            ; Ability slot 0 of the current form
    JSR $&ComputeAbilityIndex ; itemAbilityIndex for the row 0 description string
    COP [RunBg3Script] ( @system_strings.consolestring_01EA49 )

  loc_02E876:
    LDY $0002             ; Follow $0006 link to next status row actor
    LDA $0006, Y
    STA $0002
    LDA #$0001            ; Row 1 = ability slot 1 of the current form (flag characterForm×4 + 1)
    JSR $&TestAbilityFlag
    BCC loc_02E89E
    LDY $0002             ; Unhide Freedan row actor if ability owned
    LDA $0010, Y
    AND #$DFFF
    STA $0010, Y
    LDA #$0001            ; Ability slot 1 of the current form
    JSR $&ComputeAbilityIndex ; itemAbilityIndex for the row 1 description string
    COP [RunBg3Script] ( @system_strings.consolestring_01EA56 )

  loc_02E89E:
    LDY $0002             ; Follow the link to the next status row actor (row 2)
    LDA $0006, Y
    STA $0002
    LDA #$0002            ; Row 2 = ability slot 2 of the current form (flag characterForm×4 + 2)
    JSR $&TestAbilityFlag
    BCC loc_02E8C6
    LDY $0002             ; Unhide Shadow row actor if ability owned
    LDA $0010, Y
    AND #$DFFF
    STA $0010, Y
    LDA #$0002            ; Ability slot 2 of the current form
    JSR $&ComputeAbilityIndex ; itemAbilityIndex for the row 2 description string
    COP [RunBg3Script] ( @system_strings.consolestring_01EA63 )

  loc_02E8C6:
    RTL 
}

---------------------------------------------
; Per-slot item display actor. Increments inventoryTabIndex (spawn counter), calls ComputeSlotPosition for screen placement. Main loop: if $28 = 0 (empty) → set $2000 (hide) and yield. If nonzero → clear $2000 (show), animate until $2A triggers.

InventorySlotActor {
    INC $inventoryTabIndex ; Increment spawn counter (inventoryTabIndex → slot index)
    JSR $&ComputeSlotPosition ; Look up slot screen position via ComputeSlotPosition

; Per-frame entry for InventorySlotActor after ComputeSlotPosition: hides the slot actor when sprite frame $28 is zero, otherwise shows it and AnimOneFrame loops until refresh flag $2A is set.

  SlotActorEvaluate:
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
; Generic animated cursor actor. StageSprAndHitbox with sprite #40, SetEntryExit. Loop: SetEntryHere + AnimOneFrame until $2A signals update.

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
; Ability row 0 actor (topmost, Y=$0048). Sprite = characterForm × 3 + $44.

StatusAbilityRow0 {
    LDA #$0098            ; Status row 0 (top) actor at X=$0098
    STA $14
    LDA #$0048            ; Status row 0 Y=$0048
    STA $16
    LDA $characterForm    ; Sprite = characterForm × 3 + row base offset
    ASL 
    CLC 
    ADC $characterForm
    CLC 
    ADC #$0044            ; Row 0 portrait base sprite #$0044
    STA $28
    STZ $2A
    COP [SetEntryHere]
    COP [AnimOneFrame]
    RTL 
}

---------------------------------------------
; Ability row 1 actor (middle, Y=$0060). Sprite = characterForm × 3 + $45.

StatusAbilityRow1 {
    LDA #$0098            ; Status row 1 (middle) actor at X=$0098
    STA $14
    LDA #$0060            ; Status row 1 Y=$0060
    STA $16
    LDA $characterForm    ; characterForm × 3 portrait sprite calc
    ASL 
    CLC 
    ADC $characterForm
    CLC 
    ADC #$0045            ; Row 1 portrait base offset #$0045
    STA $28
    STZ $2A
    COP [SetEntryHere]
    COP [AnimOneFrame]
    RTL 
}

---------------------------------------------
; Ability row 2 actor (bottom, Y=$0078). Sprite = characterForm × 3 + $46.

StatusAbilityRow2 {
    LDA #$0098            ; Status row 2 (bottom) at X=$0098
    STA $14
    LDA #$0078            ; Status row 2 Y=$0078
    STA $16
    LDA $characterForm    ; characterForm × 3 portrait sprite calc
    ASL 
    CLC 
    ADC $characterForm
    CLC 
    ADC #$0046            ; Row 2 portrait base offset #$0046
    STA $28
    STZ $2A
    COP [SetEntryHere]
    COP [AnimOneFrame]
    RTL 
}

---------------------------------------------
; Compute the global ability index characterForm × 4 + abilitySlot + 1 and store it in itemAbilityIndex ($0AE8), the index the BG3 ability description strings use. Preserves A. The +1 means no slot selects entry 0: entry 0 of ability_menu_table and ability_name_table is the empty string and entry 0 of ability_description_table is 'Nothing' (system_strings).

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
; Grid cursor up. Consumes Up, Left and Right ($0B00), SFX #10, $22 − 4 with AND $000F wrapping. Shared by Arrange/Discard through the PEA/RTS trick; returns with RTS.

GridCursorUp {
    LDA #$0B00            ; Consume Up, Left and Right ($0B00) so a diagonal press moves one step
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
; Grid cursor down. Consumes Down, Left and Right ($0700), SFX #10, $22 + 4 with AND $000F wrapping.

GridCursorDown {
    LDA #$0700            ; Consume Down, Left and Right ($0700)
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
; Walk the slot actor chain (orbitAngle, $0006 links) to the Nth actor (A = slot index) and reset it: entry point ($0000) = SlotActorEvaluate, $28/$08/$2A = 0 so it re-evaluates empty/non-empty. Returns with Y = that slot ACTOR (not the slot index); callers use it for STA $0028,Y.

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
    LDA #$&SlotActorEvaluate ; Reset actor to slot display loop (SlotActorEvaluate)
    STA $0000, Y
    LDA #$0000
    STA $0028, Y
    STA $0008, Y
    STA $002A, Y
    RTS 
}

---------------------------------------------
; Test whether an item is non-discardable. A = item ID (not itemAbilityIndex): byte index = ID >> 3, bit = BitMaskTable[ID & 7], ANDed with the bit table at system_strings.non_discardable_item_bits. Carry set = protected (not discardable). Preserves X.

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
    AND $&system_strings.non_discardable_item_bits, Y
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
; Position a grid cursor actor from a slot index: primary entry uses $22 / actor $20. After slot × 4, bits 2–3 select the column (stride 4 into GridColumnPositions) and bits 4–5 select the row ($0030 mask = row × $10, added to the base Y). Writes $0014/$0016. The second entry loc_02EA46 (source cursor $2E / $2C) has no caller.

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
; Yes/No prompt poll, once per frame. A ($8000) → YesNoConfirm (B does not cancel); Up/Down toggle $28 (0 = No on the first row, 1 = Yes). Blink counter $1C: every 16 frames the cursor is drawn (bit 4 clear) or cleared (bit 4 set). Carry set = answered.

YesNoPromptLoop {
    COP [BranchIfPressed] ( #$8000, &YesNoConfirm ) ; Confirm bit (A) answers the prompt (B does not cancel); Up/Down toggle
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
    LDA #$8000            ; Consume the confirm bit; return carry set
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
    STA $bg3TilemapBuffer, X
    PLX 
    RTS 
}

---------------------------------------------
; Clear the two Yes/No cursor cells ($7F0896 = No row, $7F0916 = Yes row) with the blank tile (tile $2060 in this baserom). Sets displayModeFlags bit 0 to flag the BG3 tilemap as dirty.

YesNoClearCursor {
    LDA #$0001            ; Clear Yes/No cursor tile positions
    TSB $displayModeFlags ; Mark BG3 tilemap dirty (displayModeFlags bit 0)
    LDA #$2060            ; Blank tile (tile $2060 here) at the No cell ($7F0896) and the Yes cell ($7F0916)
    STA $7F0896
    STA $7F0916
    RTS 
}

---------------------------------------------
; Tab bar poll, once per frame. A ($8000) → TabConfirm, Up/Down → TabSelectUp/Down, mask $6000 (B or Select) → TabCancel. Blink counter $1C draws or clears the cursor every 16 frames. Carry set = confirmed.

TabSelectionLoop {
    COP [BranchIfPressed] ( #$8000, &TabConfirm ) ; Confirm bit (A) confirms the tab
    COP [BranchIfPressed] ( #$0800, &TabSelectUp )
    COP [BranchIfPressed] ( #$0400, &TabSelectDown )
    COP [BranchIfPressed] ( #$6000, &TabCancel ) ; Mask $6000: B or Select cancels (the vanilla ROM tests a different mask)
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
; Set exit flag byte #00 (polled by the main loop of inventory_overlay, which then tears the menu down) and return carry clear. The cancel bits are not consumed, so InventoryMainLoop keeps passing through here each frame until the overlay ends.

TabCancel {
    COP [SetFlagByte] ( #00 ) ; Set exit flag byte #00 (inventory_overlay polls it), carry clear
    CLC 
    RTS 
}

---------------------------------------------
; Tab confirm. Consumes A, draws cursor, carry set.

TabConfirm {
    LDA #$8000            ; Consume the confirm bit; return carry set
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
    STA $bg3TilemapBuffer, X
    PLX 
    RTS 
}

---------------------------------------------
; Clear the four tab cursor cells ($7F0784 / $0804 / $0884 / $0904) with the blank tile (tile $2060 in this baserom). Sets displayModeFlags bit 0.

TabClearCursor {
    LDA #$0001            ; Clear all four tab cursor positions on BG3
    TSB $displayModeFlags
    LDA #$2060            ; Blank tile (tile $2060 here) at each of the four tab cursor cells
    STA $7F0784
    STA $7F0804
    STA $7F0884
    STA $7F0904
    RTS 
}