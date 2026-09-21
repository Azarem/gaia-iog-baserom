# Inventory Menu — `inventory_menu.asm`

*Part of the [Bank $02 Documentation Suite](README.md)*

> Actor-based 4-tab inventory UI with 16-slot grid navigation

**Source:** [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm)

---

## Overview

This document covers four ASM compilation units in bank `$02` that implement Illusion of Gaia's **inventory UI pipeline**:

1. **`inventory_menu.asm`** — COP-scripted actor scene with four tabs (Use, Arrange, Discard, Status), 16 item slots, equipment cursor, and character status rows.

These routines follow player movement/collision code ([tile-collision.md](tile-collision.md) — `tile_collision.asm` ends at `$02E396`) and depend on the scene script engine ([scene-script.md](scene-script.md)), VBlank/joypad layer ([hardware-and-init.md](hardware-and-init.md)), and world-state glue ([game-systems.md](game-systems.md)).

### Block Layout

```
$02E396 ┌─ InventoryMenuDef ──────────────────────────┐
        │  InventoryMenuInit / InventoryMainLoop       │
        │  TabHoverDispatch / TabActionDispatch        │
        │  UseItemTab … StatusViewTab                  │  inventory_menu
        │  TabHover* / Slot & Cursor actors            │
        │  Grid navigation / Yes-No / Tab selection    │
$02ED02 ├─ OpenInventoryScreen ───────────────────────┤
        │  SaveGameState / RestoreGameState            │  inventory_overlay
        │  ReloadAbilityFX / DrainActorQueue           │
$02F048 ├─ ShowDialogueFrame ─────────────────────────┤  dialogue_display
$02F06A └─ ClearVramBufferPartial / Full ─────────────┘  vram_buffer_clear
```

### Shared WRAM Variables

| Address | Name / Role | Used by |
|---------|-------------|---------|
| `$0AB4`–`$0AD2` | `inventory_slots` — 16 item words (low byte = item ID) | All inventory tabs |
| `$0AC4` | `inventory_equipped_index` — equipped slot (`$FFFF` = none) | Use tab, equip cursor |
| `$0AC6` | `inventory_equipped_type` — equipped item ID | Use confirm, equipped display |
| `$0AD4` | Character form index (0=normal, 1=Dark Friar, 2=Aura) | Status tab, ability flags |
| `$0AE6` | BG1 scroll/config mode; overlay exit poll flag | Overlay, tab handlers |
| `$0AE8` | Item/ability index for BG3 description strings | Use, discard, status |
| `$0AFA` | Tab index (0–3); slot spawn counter during init | Tab selection |
| `$0644` | `scene_current` — set to `$FF` during overlay | OpenInventoryScreen |
| `$0656` / `$0658` | Joypad held / newly-pressed bits | All input handlers |
| `$065A` | `joypad_mask_std` — input suppression mask | Overlay, dialogue |
| `$065C` | `joypad_mask_inv` — inventory mask (`$0F00`) | Overlay |
| `$7F:0200`–`$7F:0800` | VRAM tilemap write buffer (2048 bytes) | Cursors, overlay |
| `$7F:0010,X` / `$12` / `$18` / `$1A` | Cached child actor IDs on menu controller | Slot/equip/status actors |
| `$7E:3490`–`$7E:38B4` | Overlay save-area scratch | SaveGameState / RestoreGameState |

---

## Memory Map

| Address | Name | Description |
|---------|------|-------------|
| `$02E396` | InventoryMenuDef | Actor definition header for the inventory menu controller. Type `$00`, priority `$00`, flags `$28`. The `{ … }` block... |
| `$02E399` | InventoryMenuInit | One-time menu bootstrap. Assigns spritemap, draws BG3 backdrop text, spawns 16 linked `InventorySlotActor` instances ... |
| `$02E40C` | InventoryMainLoop | Tab-bar main loop running each actor frame. Refreshes BG3 header/footer, polls tab input, dispatches hover previews o... |
| `$02E43D` | TabHoverDispatch | Four word pointers for tab hover preview handlers, indexed by `$0AFA`. |
| `$02E445` | TabConfirmDispatch | Called when the player presses A on a tab in the tab bar. Plays the tab-enter sound effect, then hands off to the confirmed tab handler — opening the Use grid for equipping, the Arrange swap flow, the Discard confirmation flow, or the Status ability viewer depending on which of the four tabs was highlighted. |
| `$02E456` | TabActionDispatch | Four word pointers for confirmed tab action handlers. |
| `$02E45E` | UseItemTab | Equip-item tab. Configures BG scroll mode, draws USE header, shows equip cursor on the 4×4 grid, displays item descri... |
| `$02E4B8` | UseItemCursorUp | Equip cursor up: subtract 4 with `$0F` wrap (one grid row). |
| `$02E4CE` | UseItemCursorDown | Equip cursor down: add 4 with wrap. |
| `$02E4E4` | UseItemCursorLeft | Equip cursor left: decrement with wrap. |
| `$02E4F7` | UseItemCursorRight | Equip cursor right: increment with wrap. |
| `$02E50B` | UseItemConfirm | Writes selected slot to `inventory_equipped_index` and item type to `inventory_equipped_type`. Empty slot clears equi... |
| `$02E536` | ArrangeItemsTab | Swap setup phase. Hides equip cursor, spawns selection cursor, draws ARRANGE header, positions cursor on grid slot `$... |
| `$02E583` | ArrangePickTarget | Swap target phase. Saves source slot/cursor, spawns second cursor, draws SWAP prompt, navigates target index `$22` vs... |
| `$02E5DA` | ArrangePerformSwap | Executes slot swap. No-op if source == target. Swaps low bytes of two `inventory_slots` entries, refreshes both slot ... |
| `$02E64A` | ArrangeCancelTarget | `COP [KillNext]` — removes only the target selection cursor. |
| `$02E64C` | ArrangeCancelTab | Kills active cursor, sets input mask, returns to tab bar. |
| `$02E657` | DiscardItemTab | Discard flow with Yes/No confirmation. Hides equip cursor, spawns selection cursor, validates non-empty discardable i... |
| `$02E70B` | DiscardCancelTab | Cancel discard tab: restore equip cursor visibility and return to main loop. |
| `$02E719` | StatusViewTab | Character ability status viewer. Sets BG mode 0, draws status header, spawns cursor, shows ability description for un... |
| `$02E768` | StatusCursorUp | Decrement ability row; wrap 0 → 2. |
| `$02E77D` | StatusCursorDown | Increment ability row; wrap 3 → 0. |
| `$02E795` | StatusConfirmExit | Exit status tab back to tab bar. |
| `$02E7A3` | StatusPositionCursor | Called when the player moves the cursor between ability rows on the Status tab. Reads the selected row index from `$22`, looks up the Y pixel position in the `StatusCursorPositions` table (fixed X = `$98`, Y = `$48`/`$60`/`$78`), and repositions the blinking selection cursor sprite. This creates the visible cursor movement between the three character-form ability tiers (Will, Freedan, Shadow). |
| `$02E7BB` | StatusCursorPositions | Three XY coordinate pairs for status ability rows at X=`$98`, Y=`$48`/`$60`/`$78`. |
| `$02E7C7` | TabHoverUse | Hover preview for the Use tab while the player moves Up/Down through the four tab labels. Keeps the 4×4 item grid visible, shows the equip cursor on the currently equipped slot, hides the status-panel portraits, and redraws BG3 with the Use-tab header plus item-description area. Switches BG1 to the items background so the player sees what the equip screen will look like before pressing A. |
| `$02E7E6` | TabHoverArrange | Hover preview for the Arrange tab. Keeps the 4×4 item grid and equip cursor visible while redrawing BG3 with the Arrange header and swap instructions. Gives the player a read-only glimpse of the grid-reorder screen before they commit to picking source and target slots. |
| `$02E7F7` | TabHoverDiscard | Hover preview for the Discard tab. Matches the Use tab layout — 4×4 grid with equip cursor, status portraits hidden — but redraws BG3 with Discard-specific header text and warning copy. Lets the player preview the discard screen's look and BG1 items background before entering the Yes/No confirmation flow. |
| `$02E816` | TabHoverStatus | Hover preview for the Status tab. Hides the 4×4 grid icons and equip cursor, switches BG1 to the status background, and shows the equipped-item icon plus the three character-form ability portrait rows. For each unlocked ability, unhides the row actor and draws its name on BG3 — giving a static summary of Will/Freedan/Shadow abilities before the player enters the interactive row cursor. |
| `$02E8C7` | InventorySlotActor | Item slot sprite actor. Increments spawn counter, computes grid position, shows/hides based on item type in `$28`. |
| `$02E8E7` | EquipCursorActor | Equipped-item highlight cursor. Hidden if no item equipped (`inventory_equipped_index` negative); otherwise falls thr... |
| `$02E8F1` | SelectionCursorActor | The blinking arrow sprite (metasprite #40) that marks the player's current selection on the Arrange, Discard, and Status tabs. Animates every frame until a parent script sets `$2A` to force a refresh — for example after the cursor moves to a new grid slot or ability row. Visually distinct from the equip cursor, which only highlights the worn item on the Use tab. |
| `$02E8FF` | EquippedItemDisplay | Static sprite actor pinned at screen position ($28, $78) on the left side of the Status tab layout. Displays the icon for `inventory_equipped_type` — the item currently worn by the player — so the status screen shows both ability tiers and what is equipped. Hidden whenever Use/Arrange/Discard tabs are hovered or active, since those views use the grid equip cursor instead. |
| `$02E915` | StatusCharRow3 | Third ability tier row actor at ($98, $48). Sprite index = `$0AD4 × 3 + $44`. |
| `$02E934` | StatusCharRow2 | Second ability tier row at ($98, $60). Sprite index = `$0AD4 × 3 + $45`. |
| `$02E953` | StatusCharRow1 | First ability tier row at ($98, $78). Sprite index = `$0AD4 × 3 + $46`. |
| `$02E972` | ComputeAbilityIndex | Computes BG3 ability description string index: `$0AE8 = ($0AD4 × 4) + row_arg + 1`. |
| `$02E981` | GridCursorUp | Shared grid up for Arrange/Discard: `$22 = ($22 − 4) & $0F`. |
| `$02E996` | GridCursorDown | Shared grid down: add 4 with wrap. |
| `$02E9AB` | GridCursorLeft | Shared grid left: decrement with wrap. |
| `$02E9BD` | GridCursorRight | Shared grid right: increment with wrap. |
| `$02E9CF` | SetSlotSprite | Writes item sprite type to actor `$0028,Y` and clears animation state. |
| `$02E9DC` | TestAbilityFlag | Tests whether an ability tier is unlocked. Flag index = `$0AD4 × 4 + row`. Calls `TestFlag_0510` in bank `$05`; carry... |
| `$02E9ED` | UpdateSlotActorSprite | Refreshes a slot actor's sprite after inventory mutation. Walks linked list from `$7F0010,X` to slot index in A, rese... |
| `$02EA13` | CheckItemDiscardable | Tests whether item ID in A may be discarded. Indexes 3-bit-per-item bit array at `item_table_separator`. Carry set = discard... |
| `$02EA35` | BitMaskTable | Eight single-bit masks `$01`–`$80` for discardable-item lookup. |
| `$02EA3D` | PositionGridCursor | Computes XY for grid selection cursor. Uses `$22` (or `$2E` for second cursor in arrange) and `GridColumnPositions`. |
| `$02EA73` | PositionEquipCursor | Positions equip cursor on grid using `$1A`. If index negative, hides cursor instead. |
| `$02EAB0` | GridColumnPositions | Four column base coordinates for 4×4 grid cursors at Y=`$30`, X=`$5C`/`$74`/`$8C`/`A4`. |
| `$02EAC0` | HideStatusActors | Removes the status-panel sprites from view when the player hovers or enters Use, Arrange, or Discard tabs. Walks the equipped-item display actor and the three linked ability-row actors, setting the hidden flag on each so only the 4×4 grid and equip cursor remain visible. Called to prevent the status portraits from overlapping the item-management layout. |
| `$02EAF7` | ShowEquipCursor | Makes the equip cursor visible on the 4×4 grid when an item is currently worn. If `inventory_equipped_index` is `$FFFF` (nothing equipped), delegates to `HideEquipCursor` instead. Called when entering Use tab or hovering tabs that show the grid, so the player always sees which slot holds the equipped item. |
| `$02EB0B` | HideEquipCursor | Hides equip cursor actor via flag bit `$2000`. |
| `$02EB1A` | ShowAllItemSlots | Switches to grid mode: shows all 16 slot icons by clearing `$2000` on each slot actor. Guarded — only runs when menu flag `$1000` is clear (slots currently hidden). |
| `$02EB45` | HideAllItemSlots | Switches to list mode: hides all 16 slot icon sprites by setting `$2000` on each slot actor. Guarded — only runs when `$1000` is set (slots currently shown). |
| `$02EB70` | ComputeSlotPosition | Places each of the 16 item slot icons on the 4×4 grid during menu init. Uses the spawn counter in `$0AFA` (decremented to 0-based) to index `SlotPositionTable`, which stores precomputed X/Y pairs for columns `$5C`/`$74`/`$8C`/`A4` and rows Y = `$31`/`$41`/`$51`/`$61`. Writes the result to the spawning slot actor so icons appear in the correct grid cell. |
| `$02EB86` | SlotPositionTable | 16 XY pairs for item slot positions on 4×4 grid. Columns `$5C/$74/$8C/$A4`, rows Y=`$31/$41/$51/$61`. |
| `$02EBC6` | YesNoPromptLoop | Yes/No dialog input loop with blinking cursor. Returns carry set on confirm. |
| `$02EBF2` | YesNoSelectUp | Toggle Yes/No selection up (toward Yes). |
| `$02EC0A` | YesNoSelectDown | Toggle Yes/No selection down (toward No). |
| `$02EC22` | YesNoConfirm | Confirms Yes/No choice. Returns carry set. |
| `$02EC2D` | YesNoDrawCursor | Renders the blinking highlight arrow on the Discard tab's Yes/No confirmation prompt. Clears any previous highlight, then writes tile `$202B` to the BG3 tilemap buffer at the offset for the current selection (`$28` = 0 for Yes, 1 for No). The tile is uploaded on the next VRAM flush, so the player sees which answer is highlighted before confirming discard. |
| `$02EC46` | YesNoClearCursor | Clears Yes/No cursor tiles and sets VRAM flush flag. |
| `$02EC58` | TabSelectionLoop | Main tab bar input loop with blinking cursor. Confirm enters tab; Cancel closes inventory. |
| `$02EC8A` | TabSelectUp | Previous tab (wrap 0 → 3). |
| `$02ECA4` | TabSelectDown | Next tab (wrap 3 → 0). |
| `$02ECBE` | TabCancel | `COP [SetFlagByte] (#00)` — signals overlay exit loop. Returns carry clear. |
| `$02ECC3` | TabConfirm | Confirms tab selection. Returns carry set to InventoryMainLoop. |
| `$02ECCE` | TabDrawCursor | Renders the blinking arrow beneath the currently selected tab label (Use, Arrange, Discard, or Status). Clears all four tab cursor slots first, then writes tile `$202B` to the BG3 buffer at the column offset for `$0AFA`. Called every 16 frames during tab-bar navigation and immediately after Up/Down tab changes, giving the player a visible indicator of which tab will open on A. |
| `$02ECE8` | TabClearCursor | Erases the tab highlight arrow during the blink-off phase of tab-bar navigation. Writes blank tile `$2040` to all four tab cursor positions in the BG3 tilemap buffer and sets the VRAM flush flag so the highlight disappears for half the blink cycle. Paired with `TabDrawCursor` to produce the 16-frame on/off blink on the tab bar. |

---

#### 20A — Init & Main Loop

### InventoryMenuInit

One-time menu bootstrap. Assigns spritemap, draws BG3 backdrop text, spawns 16 linked `InventorySlotActor` instances with item IDs from WRAM, then spawns equip cursor, equipped-item icon, and three status-row actors before entering the tab main loop.

**Algorithm:**
1. `COP [SetMetasprite]` inventory spritemap
2. Zero `$0AFA`, loop counter `$24 = $000F`
3. Spawn each `InventorySlotActor`; copy `inventory_slots[Y]` low byte → child `$0028`
4. Cache list head at `$7F0010,X`
5. Spawn equip cursor → `$7F0012,X`; position via `PositionEquipCursor`
6. Spawn equipped display + StatusCharRow1/2/3
7. Set menu flag `$1000`, zero tab index


**Variables:**
| Location | Direction | Role |
|----------|-----------|------|
| `$0AFA` | RW | Tab index / spawn counter |
| `$24` | RW | Spawn loop counter |
| `$1A` | W | Equip slot index |
| `$inventory_slots` | R | 16 item words |
| `$7F0010,X` | W | Slot list head |
| `$7F0012,X` | W | Equip cursor ID |
| `$7F0018,X` | W | Equipped display ID |
| `$7F001A,X` | W | Status row chain head |

**Cross-References:**
| Symbol | Relationship |
|--------|--------------|
| `InventorySlotActor` | Spawned ×16 |
| `PositionEquipCursor` | JSR |
| `InventoryMainLoop` | Entry point |

### InventoryMainLoop

Tab-bar main loop running each actor frame. Refreshes BG3 header/footer, polls tab input, dispatches hover previews on tab change, and branches to tab confirm on A-button press.

**Algorithm:**
1. Run BG3 header + footer scripts
2. Init `$18 = $FFFF`, `$1C = 0`
3. Set joypad `$8000` on `$0658`
4. JSR `TabSelectionLoop` — BCS → confirm
5. Compare `$0AFA` vs `$18`; if equal RTL
6. Update `$18`, `SwitchCase` → `TabHoverDispatch`, loop


**Variables:**
| Location | Direction | Role |
|----------|-----------|------|
| `$0AFA` | R | Current tab 0–3 |
| `$18` | RW | Last hovered tab |
| `$0658` | W | Joypad pressed mask |

**Cross-References:**
| Symbol | Relationship |
|--------|--------------|
| `TabSelectionLoop` | Input |
| `TabConfirmDispatch` | On carry |
| `TabHoverDispatch` | Preview table |

### TabConfirmDispatch

Called when the player presses A on a tab in the tab bar. Plays the tab-enter sound effect, then hands off to the confirmed tab handler — opening the Use grid for equipping, the Arrange swap flow, the Discard confirmation flow, or the Status ability viewer depending on which of the four tabs was highlighted.

**Algorithm:**
1. Sound `#0D`
2. Copy `$0AFA` → `$18`, `$0000`
3. `SwitchCase` → `TabActionDispatch`


**Variables:**
| Location | Direction | Role |
|----------|-----------|------|
| `$0AFA` | R | Tab index |

**Cross-References:**
| Symbol | Relationship |
|--------|--------------|
| `TabActionDispatch` | Action table |
| `TabSelectionLoop` | Caller on carry |

#### 20B — Use Item Tab

### UseItemTab

Equip-item tab. Configures BG scroll mode, draws USE header, shows equip cursor on the 4×4 grid, displays item description for highlighted slot, and polls directional + confirm input.

**Algorithm:**
1. `$0AE6 = 4`
2. BG3 USE header scripts
3. Show equip cursor; clamp `$1A` ≥ 0
4. Position cursor, item ID → `$0AE8`, description script
5. BranchIfButton: directions → cursor handlers, A → confirm


**Variables:**
| Location | Direction | Role |
|----------|-----------|------|
| `$0AE6` | W | BG1 scroll mode |
| `$1A` | RW | Slot index |
| `$0AE8` | W | String index |
| `$inventory_slots` | R | Items |

**Cross-References:**
| Symbol | Relationship |
|--------|--------------|
| `UseItemConfirm` | A button |
| `PositionEquipCursor` | JSR |
| `ShowEquipCursor` | JSR |

### UseItemConfirm

Writes selected slot to `inventory_equipped_index` and item type to `inventory_equipped_type`. Empty slot clears equip state (`$FFFF` index).

**Algorithm:**
1. Mask `$C040`, sound `#11`
2. Store index from `$1A`
3. Non-zero item → store type; zero → clear index/type
4. JMP InventoryMainLoop


**Variables:**
| Location | Direction | Role |
|----------|-----------|------|
| `$1A` | R | Slot |
| `$inventory_equipped_index` | W | Equipped slot |
| `$inventory_equipped_type` | W | Item ID |

**Cross-References:**
| Symbol | Relationship |
|--------|--------------|
| `InventoryMainLoop` | Return |

#### 20C — Arrange Items Tab

### ArrangeItemsTab

Swap setup phase. Hides equip cursor, spawns selection cursor, draws ARRANGE header, positions cursor on grid slot `$22`, waits for pick or cancel.

**Algorithm:**
1. Hide equip cursor
2. Spawn SelectionCursorActor → `$20`
3. Zero `$22`
4. Draw ARRANGE BG3 scripts
5. PositionGridCursor; poll Cancel/Pick/directions via PEA return stack


**Variables:**
| Location | Direction | Role |
|----------|-----------|------|
| `$20` | W | Cursor actor ID |
| `$22` | RW | Slot index |

**Cross-References:**
| Symbol | Relationship |
|--------|--------------|
| `ArrangePickTarget` | On confirm |
| `GridCursor*` | Navigation |
| `HideEquipCursor` | JSR |

### ArrangePickTarget

Swap target phase. Saves source slot/cursor, spawns second cursor, draws SWAP prompt, navigates target index `$22` vs saved `$2E`.

**Algorithm:**
1. Sound `#11`, mask `$8000`
2. Save `$20→$2C`, `$22→$2E`
3. Spawn second cursor → `$20`
4. Draw SWAP scripts
5. Confirm → PerformSwap; Cancel → CancelTarget


**Variables:**
| Location | Direction | Role |
|----------|-----------|------|
| `$20` | RW | Active cursor ID |
| `$2C` | W | Source cursor ID |
| `$2E` | W | Source slot |
| `$22` | RW | Target slot |

**Cross-References:**
| Symbol | Relationship |
|--------|--------------|
| `ArrangePerformSwap` | Confirm |
| `ArrangeCancelTarget` | Cancel |

### ArrangePerformSwap

Executes slot swap. No-op if source == target. Swaps low bytes of two `inventory_slots` entries, refreshes both slot actor sprites, fixes equip index if needed, kills source cursor.

**Algorithm:**
1. Skip if `$22 == $2E`
2. SEP #$20; XBA swap low bytes of both slots
3. UpdateSlotActorSprite for both slots
4. Fix inventory_equipped_index if swapped slot was equipped
5. MarkDeath on source cursor `$2C`
6. JMP arrange setup


**Variables:**
| Location | Direction | Role |
|----------|-----------|------|
| `$22` | R | Target slot |
| `$2E` | R | Source slot |
| `$inventory_slots` | RW | Item data |
| `$inventory_equipped_index` | RW | Equip slot |

**Cross-References:**
| Symbol | Relationship |
|--------|--------------|
| `UpdateSlotActorSprite` | JSR ×2 |
| `ArrangeItemsTab` | Return to setup |

#### 20D — Discard Item Tab

### DiscardItemTab

Discard flow with Yes/No confirmation. Hides equip cursor, spawns selection cursor, validates non-empty discardable items via `CheckItemDiscardable`, clears slot on Yes.

**Algorithm:**
1. Set `$0AE6=4`, hide equip cursor
2. Spawn cursor, draw DISCARD header
3. Grid navigation loop
4. On confirm (inline `code_02E6AA`): validate item, YesNo prompt
5. Yes: zero slot, update sprite, clear equip if needed, sound `#13`
6. No/invalid: sound `#12`, redraw


**Variables:**
| Location | Direction | Role |
|----------|-----------|------|
| `$22` | RW | Slot index |
| `$0AE8` | W | Item string index |
| `$28` | RW | Yes/No selection |
| `$inventory_slots` | RW | Items |

**Cross-References:**
| Symbol | Relationship |
|--------|--------------|
| `CheckItemDiscardable` | JSR |
| `YesNoPromptLoop` | JSR |
| `DiscardCancelTab` | Cancel |

#### 20E — Status View Tab

### StatusViewTab

Character ability status viewer. Sets BG mode 0, draws status header, spawns cursor, shows ability description for unlocked rows.

**Algorithm:**
1. `$0AE6 = 0`
2. Draw status BG3 scripts
3. Spawn cursor, zero row `$22`
4. Position cursor, test ability flag
5. If unlocked: ComputeAbilityIndex + description script
6. Up/Down rows; A → exit


**Variables:**
| Location | Direction | Role |
|----------|-----------|------|
| `$22` | RW | Ability row 0–2 |
| `$0AD4` | R | Character form |
| `$0AE8` | W | String index |

**Cross-References:**
| Symbol | Relationship |
|--------|--------------|
| `TestAbilityFlag` | JSR |
| `StatusConfirmExit` | A button |

### StatusPositionCursor

Called when the player moves the cursor between ability rows on the Status tab. Reads the selected row index from `$22`, looks up the Y pixel position in the `StatusCursorPositions` table (fixed X = `$98`, Y = `$48`/`$60`/`$78`), and repositions the blinking selection cursor sprite. This creates the visible cursor movement between the three character-form ability tiers (Will, Freedan, Shadow).

**Algorithm:**
1. `$22 × 4` → index into table
2. Write X/Y to cursor actor `$0014`/`$0016`


**Variables:**
| Location | Direction | Role |
|----------|-----------|------|
| `$22` | R | Row index |
| `$20` | R | Cursor actor ID |

**Cross-References:**
| Symbol | Relationship |
|--------|--------------|
| `StatusCursorPositions` | Lookup table |

#### 20F — Tab Hover Display

### TabHoverUse

Hover preview for the Use tab while the player moves Up/Down through the four tab labels. Keeps the 4×4 item grid visible, shows the equip cursor on the currently equipped slot, hides the status-panel portraits, and redraws BG3 with the Use-tab header plus item-description area. Switches BG1 to the items background so the player sees what the equip screen will look like before pressing A.

**Algorithm:**
1. HideAllItemSlots
2. ShowEquipCursor
3. HideStatusActors
4. BG3 list + description scripts
5. `$0AE6 = 4`


**Variables:**
| Location | Direction | Role |
|----------|-----------|------|
| `$0AE6` | W | BG scroll mode |

**Cross-References:**
| Symbol | Relationship |
|--------|--------------|
| `HideAllItemSlots` | JSR |
| `TabHoverDispatch` | Entry 0 |

### TabHoverArrange

Hover preview for the Arrange tab. Keeps the 4×4 item grid and equip cursor visible while redrawing BG3 with the Arrange header and swap instructions. Gives the player a read-only glimpse of the grid-reorder screen before they commit to picking source and target slots.

**Algorithm:**
1. HideAllItemSlots
2. ShowEquipCursor
3. BG3 ARRANGE preview scripts
4. RTL


**Variables:**
| Location | Direction | Role |
|----------|-----------|------|
| `$0AE6` | W | BG scroll mode |

**Cross-References:**
| Symbol | Relationship |
|--------|--------------|
| `HideAllItemSlots` | JSR |
| `TabHoverDispatch` | Entry 1 |

### TabHoverDiscard

Hover preview for the Discard tab. Matches the Use tab layout — 4×4 grid with equip cursor, status portraits hidden — but redraws BG3 with Discard-specific header text and warning copy. Lets the player preview the discard screen's look and BG1 items background before entering the Yes/No confirmation flow.

**Algorithm:**
1. HideAllItemSlots
2. ShowEquipCursor
3. HideStatusActors
4. BG3 scripts
5. `$0AE6 = 4`


**Variables:**
| Location | Direction | Role |
|----------|-----------|------|
| `$0AE6` | W | BG mode |

**Cross-References:**
| Symbol | Relationship |
|--------|--------------|
| `TabHoverDispatch` | Entry 2 |

### TabHoverStatus

Hover preview for the Status tab. Hides the 4×4 grid icons and equip cursor, switches BG1 to the status background, and shows the equipped-item icon plus the three character-form ability portrait rows. For each unlocked ability, unhides the row actor and draws its name on BG3 — giving a static summary of Will/Freedan/Shadow abilities before the player enters the interactive row cursor.

**Algorithm:**
1. ShowAllItemSlots
2. HideEquipCursor
3. Draw status header scripts
4. Show equipped item on EquippedItemDisplay
5. For rows 0–2: TestAbilityFlag → show row + BG3 description


**Variables:**
| Location | Direction | Role |
|----------|-----------|------|
| `$0AD4` | R | Character form |
| `$7F0018,X` | R | Equipped display ID |
| `$7F001A,X` | R | Status row chain |

**Cross-References:**
| Symbol | Relationship |
|--------|--------------|
| `TestAbilityFlag` | JSR ×3 |
| `ComputeAbilityIndex` | JSR |
| `TabHoverDispatch` | Entry 3 |

#### 20G — Slot Actors & Cursors

### InventorySlotActor

Item slot sprite actor. Increments spawn counter, computes grid position, shows/hides based on item type in `$28`.

**Algorithm:**
1. INC `$0AFA`
2. ComputeSlotPosition
3. If `$28` non-zero: clear hide flag, animate
4. If zero: set hide flag `$2000`, RTL


**Variables:**
| Location | Direction | Role |
|----------|-----------|------|
| `$0AFA` | RW | Spawn counter |
| `$28` | R | Item type/sprite |
| `$10` | RW | Actor flags |

**Cross-References:**
| Symbol | Relationship |
|--------|--------------|
| `ComputeSlotPosition` | JSR |
| `UpdateSlotActorSprite` | Resets to loc_02E8CD |

### EquipCursorActor

Equipped-item highlight cursor. Hidden if no item equipped (`inventory_equipped_index` negative); otherwise falls through to the shared selection-cursor animation loop.

**Algorithm:**
1. If `inventory_equipped_index` negative → set hide flag `$2000`
2. Else continue into `SelectionCursorActor`


**Variables:**
| Location | Direction | Role |
|----------|-----------|------|
| `$inventory_equipped_index` | R | Equipped slot |
| `$10` | W | Actor flags |

**Cross-References:**
| Symbol | Relationship |
|--------|--------------|
| `SelectionCursorActor` | Shared tail |
| `InventoryMenuInit` | Spawner |

### SelectionCursorActor

The blinking arrow sprite (metasprite #40) that marks the player's current selection on the Arrange, Discard, and Status tabs. Animates every frame until a parent script sets `$2A` to force a refresh — for example after the cursor moves to a new grid slot or ability row. Visually distinct from the equip cursor, which only highlights the worn item on the Use tab.

**Algorithm:**
1. Stage sprite `#40`, set entry/exit
2. Animate each frame until `$2A` non-zero


**Variables:**
| Location | Direction | Role |
|----------|-----------|------|
| `$2A` | R | Animation trigger |
| `$10` | RW | Actor flags |

**Cross-References:**
| Symbol | Relationship |
|--------|--------------|
| `ArrangeItemsTab` | Spawner |
| `DiscardItemTab` | Spawner |
| `StatusViewTab` | Spawner |

### EquippedItemDisplay

Static sprite actor pinned at screen position ($28, $78) on the left side of the Status tab layout. Displays the icon for `inventory_equipped_type` — the item currently worn by the player — so the status screen shows both ability tiers and what is equipped. Hidden whenever Use/Arrange/Discard tabs are hovered or active, since those views use the grid equip cursor instead.

**Algorithm:**
1. Position ($28, $78)
2. Load `inventory_equipped_type` → `$28`
3. Single-frame animation


**Variables:**
| Location | Direction | Role |
|----------|-----------|------|
| `$inventory_equipped_type` | R | Item ID |
| `$28` | W | Sprite type |

**Cross-References:**
| Symbol | Relationship |
|--------|--------------|
| `InventoryMenuInit` | Spawner |
| `TabHoverStatus` | Shows on hover |

### StatusCharRow3

Third ability tier row actor at ($98, $48). Sprite index = `$0AD4 × 3 + $44`.

**Algorithm:**
1. Position ($98, $48)
2. Compute sprite from character form
3. Animate


**Variables:**
| Location | Direction | Role |
|----------|-----------|------|
| `$0AD4` | R | Character form |

**Cross-References:**
| Symbol | Relationship |
|--------|--------------|
| `StatusCharRow2` | Linked via $0006 |

### StatusCharRow2

Second ability tier row at ($98, $60). Sprite index = `$0AD4 × 3 + $45`.

**Algorithm:**
1. Position ($98, $60)
2. Compute sprite
3. Animate


**Variables:**
| Location | Direction | Role |
|----------|-----------|------|
| `$0AD4` | R | Character form |

**Cross-References:**
| Symbol | Relationship |
|--------|--------------|
| `StatusCharRow1` | Linked via $0006 |

### StatusCharRow1

First ability tier row at ($98, $78). Sprite index = `$0AD4 × 3 + $46`.

**Algorithm:**
1. Position ($98, $78)
2. Compute sprite
3. Animate


**Variables:**
| Location | Direction | Role |
|----------|-----------|------|
| `$0AD4` | R | Character form |

**Cross-References:**
| Symbol | Relationship |
|--------|--------------|
| `InventoryMenuInit` | Spawner |

#### 20H — Grid Navigation Subroutines

### UpdateSlotActorSprite

Refreshes a slot actor's sprite after inventory mutation. Walks linked list from `$7F0010,X` to slot index in A, resets function pointer to `loc_02E8CD`.

**Algorithm:**
1. Save slot index in `$000E`
2. Walk `$0006` chain
3. Reset `$0000` → loc_02E8CD
4. Clear `$0028`, `$0008`, `$002A`


**Variables:**
| Location | Direction | Role |
|----------|-----------|------|
| `$7F0010,X` | R | List head |
| `A` | In | Slot index |

**Cross-References:**
| Symbol | Relationship |
|--------|--------------|
| `ArrangePerformSwap` | Caller |
| `DiscardItemTab` | Caller |

### CheckItemDiscardable

Tests whether item ID in A may be discarded. Indexes 3-bit-per-item bit array at `item_table_separator`. Carry set = discardable, clear = protected.

**Algorithm:**
1. Item ID → byte index (÷8) + bit index (mod 8)
2. AND with BitMaskTable entry
3. SEC if non-zero (discardable)


**Variables:**
| Location | Direction | Role |
|----------|-----------|------|
| `A` | In | Item ID |

**Cross-References:**
| Symbol | Relationship |
|--------|--------------|
| `BitMaskTable` | Lookup |
| `item_table_separator` | Protection bit array |

#### 20I — Cursor Positioning

### PositionGridCursor

Computes XY for grid selection cursor. Uses `$22` (or `$2E` for second cursor in arrange) and `GridColumnPositions`.

**Algorithm:**
1. Select index from `$22` or `$2E` based on cursor ID
2. Column = index & 3 → GridColumnPositions
3. Row offset = index & `$0C` added to base Y `$30`
4. Write to cursor `$0014`/`$0016`


**Variables:**
| Location | Direction | Role |
|----------|-----------|------|
| `$22` | R | Active slot |
| `$2E` | R | Saved source slot |
| `$20` | R | Active cursor ID |

**Cross-References:**
| Symbol | Relationship |
|--------|--------------|
| `GridColumnPositions` | X/Y bases |

### PositionEquipCursor

Positions equip cursor on grid using `$1A`. If index negative, hides cursor instead.

**Algorithm:**
1. If `$1A` negative → hide equip cursor actor
2. Else same column/row math as PositionGridCursor


**Variables:**
| Location | Direction | Role |
|----------|-----------|------|
| `$1A` | R | Equip slot index |
| `$7F0012,X` | R | Equip cursor ID |

**Cross-References:**
| Symbol | Relationship |
|--------|--------------|
| `GridColumnPositions` | Lookup |
| `UseItemTab` | Caller |

#### 20J — Item Grid Visibility

### HideStatusActors

Removes the status-panel sprites from view when the player hovers or enters Use, Arrange, or Discard tabs. Walks the equipped-item display actor and the three linked ability-row actors, setting the hidden flag on each so only the 4×4 grid and equip cursor remain visible. Called to prevent the status portraits from overlapping the item-management layout.

**Algorithm:**
1. Walk chain from `$7F0018,X` and `$7F001A,X`
2. ORA `$2000` on each actor `$0010`


**Variables:**
| Location | Direction | Role |
|----------|-----------|------|
| `$7F0018,X` | R | Equipped display ID |
| `$7F001A,X` | R | Status chain head |

**Cross-References:**
| Symbol | Relationship |
|--------|--------------|
| `TabHoverUse` | Caller |

### ShowEquipCursor

Makes the equip cursor visible on the 4×4 grid when an item is currently worn. If `inventory_equipped_index` is `$FFFF` (nothing equipped), delegates to `HideEquipCursor` instead. Called when entering Use tab or hovering tabs that show the grid, so the player always sees which slot holds the equipped item.

**Algorithm:**
1. If inventory_equipped_index negative → HideEquipCursor
2. Else AND `#$DFFF` on cursor `$0010`


**Variables:**
| Location | Direction | Role |
|----------|-----------|------|
| `$inventory_equipped_index` | R | Equip slot |

**Cross-References:**
| Symbol | Relationship |
|--------|--------------|
| `HideEquipCursor` | BMI branch |

### ShowAllItemSlots

Switches to grid mode: shows all 16 slot icons by clearing `$2000` on each slot actor. Guarded — only runs when menu flag `$1000` is clear (slots currently hidden).

**Algorithm:**
1. If `$10` bit `$1000` set → RTS (already showing)
2. Set `$1000` on menu actor
3. Walk 16 slot actors via `$0006` chain
4. AND `#$DFFF` on each slot `$0010` (clear `$2000` → visible)


**Variables:**
| Location | Direction | Role |
|----------|-----------|------|
| `$10` | RW | Menu actor flags |
| `$7F0010,X` | R | Slot list head |

**Cross-References:**
| Symbol | Relationship |
|--------|--------------|
| `HideAllItemSlots` | Inverse |
| `TabHoverUse` | Caller |

### HideAllItemSlots

Switches to list mode: hides all 16 slot icon sprites by setting `$2000` on each slot actor. Guarded — only runs when `$1000` is set (slots currently shown).

**Algorithm:**
1. If `$1000` clear → RTS (already hidden)
2. Clear `$1000`
3. Walk slot list, ORA `$2000` on each (hide)


**Variables:**
| Location | Direction | Role |
|----------|-----------|------|
| `$10` | RW | Menu actor flags |

**Cross-References:**
| Symbol | Relationship |
|--------|--------------|
| `ShowAllItemSlots` | Inverse |
| `TabHoverStatus` | Caller |

### ComputeSlotPosition

Places each of the 16 item slot icons on the 4×4 grid during menu init. Uses the spawn counter in `$0AFA` (decremented to 0-based) to index `SlotPositionTable`, which stores precomputed X/Y pairs for columns `$5C`/`$74`/`$8C`/`A4` and rows Y = `$31`/`$41`/`$51`/`$61`. Writes the result to the spawning slot actor so icons appear in the correct grid cell.

**Algorithm:**
1. DEC `$0AFA`, ×4 → table index
2. Load X/Y → menu actor `$14`/`$16`


**Variables:**
| Location | Direction | Role |
|----------|-----------|------|
| `$0AFA` | R | Spawn counter |

**Cross-References:**
| Symbol | Relationship |
|--------|--------------|
| `SlotPositionTable` | Lookup |
| `InventorySlotActor` | Caller |

#### 20K — Yes/No Prompt & Tab Selection

### YesNoPromptLoop

Yes/No dialog input loop with blinking cursor. Returns carry set on confirm.

**Algorithm:**
1. Poll A / Up / Down
2. Blink every 16 frames (`$1C` bit 4 toggles draw/clear)
3. Carry clear while waiting


**Variables:**
| Location | Direction | Role |
|----------|-----------|------|
| `$28` | RW | Selection 0=Yes 1=No |
| `$1C` | RW | Blink counter |

**Cross-References:**
| Symbol | Relationship |
|--------|--------------|
| `YesNoConfirm` | A button |
| `DiscardItemTab` | Caller |

### YesNoDrawCursor

Renders the blinking highlight arrow on the Discard tab's Yes/No confirmation prompt. Clears any previous highlight, then writes tile `$202B` to the BG3 tilemap buffer at the offset for the current selection (`$28` = 0 for Yes, 1 for No). The tile is uploaded on the next VRAM flush, so the player sees which answer is highlighted before confirming discard.

**Algorithm:**
1. Clear old cursor
2. Compute buffer offset `$0696 + ($28>>8)`
3. Write tile `$202B` to `$7F:0200,X`


**Variables:**
| Location | Direction | Role |
|----------|-----------|------|
| `$28` | R | Selection |
| `$7F:0200` | W | VRAM buffer |

**Cross-References:**
| Symbol | Relationship |
|--------|--------------|
| `YesNoClearCursor` | JSR first |

### TabSelectionLoop

Main tab bar input loop with blinking cursor. Confirm enters tab; Cancel closes inventory.

**Algorithm:**
1. Poll A / Up / Down / Cancel (`$6040`)
2. Blink cursor every 16 frames
3. Carry set on confirm


**Variables:**
| Location | Direction | Role |
|----------|-----------|------|
| `$0AFA` | RW | Tab index |
| `$1C` | RW | Blink counter |

**Cross-References:**
| Symbol | Relationship |
|--------|--------------|
| `TabConfirm` | A button |
| `TabCancel` | Cancel |
| `InventoryMainLoop` | Caller |

### TabDrawCursor

Renders the blinking arrow beneath the currently selected tab label (Use, Arrange, Discard, or Status). Clears all four tab cursor slots first, then writes tile `$202B` to the BG3 buffer at the column offset for `$0AFA`. Called every 16 frames during tab-bar navigation and immediately after Up/Down tab changes, giving the player a visible indicator of which tab will open on A.

**Algorithm:**
1. Clear all tab cursors
2. Write `$202B` at computed offset


**Variables:**
| Location | Direction | Role |
|----------|-----------|------|
| `$0AFA` | R | Tab index |
| `$7F:0200` | W | VRAM buffer |

**Cross-References:**
| Symbol | Relationship |
|--------|--------------|
| `TabClearCursor` | JSR first |

### TabClearCursor

Erases the tab highlight arrow during the blink-off phase of tab-bar navigation. Writes blank tile `$2040` to all four tab cursor positions in the BG3 tilemap buffer and sets the VRAM flush flag so the highlight disappears for half the blink cycle. Paired with `TabDrawCursor` to produce the 16-frame on/off blink on the tab bar.

**Algorithm:**
1. Set VRAM flush flag
2. Write `$2040` at `$0784`, `$0804`, `$0884`, `$0904`


**Variables:**
| Location | Direction | Role |
|----------|-----------|------|
| `$09EC` | W | Flush flag |

**Cross-References:**
| Symbol | Relationship |
|--------|--------------|
| `TabDrawCursor` | Caller |

---

## 4×4 Item Grid Navigation

The inventory stores 16 items in `inventory_slots` (`$0AB4`–`$0AD2`). Both the **Use** tab (cursor in `$1A`) and **Arrange/Discard** tabs (cursor in `$22`) treat the index as a linear slot number 0–15 with **wrap-around toroidal navigation** on a 4-column grid.

### Index Layout

```
     Col 0    Col 1    Col 2    Col 3
Row 0: [ 0]     [ 1]     [ 2]     [ 3]
Row 1: [ 4]     [ 5]     [ 6]     [ 7]
Row 2: [ 8]     [ 9]     [10]     [11]
Row 3: [12]     [13]     [14]     [15]
```

### Movement Rules

| Direction | Operation | Example (from slot 5) |
|-----------|-----------|------------------------|
| Up | `index − 4`, `AND #$0F` | 5 → 1 |
| Down | `index + 4`, `AND #$0F` | 5 → 9 |
| Left | `index − 1`, `AND #$0F` | 5 → 4 |
| Right | `index + 1`, `AND #$0F` | 5 → 6 |

The `AND #$0F` mask wraps all edges. `PositionGridCursor` / `PositionEquipCursor` decompose the index: column = `index & 3` (X from `GridColumnPositions`), row = `index & $0C` added to base Y `$30`. Slot sprites use `SlotPositionTable` at Y `$31/$41/$51/$61`. Sound `#10` on move; `#11` on confirm.
