# Inventory Menu — `inventory_menu.asm`

> Actor-based 4-tab inventory UI with 16-slot grid navigation

**Source:** [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm)

---

## Overview

This document covers four ASM compilation units in bank `$02` that implement Illusion of Gaia's **inventory UI pipeline**:

1. **`inventory_menu.asm`** — COP-scripted actor scene with four tabs (Use, Arrange, Discard, Status), 16 item slots, equipment cursor, and character status rows.

These routines follow player movement/collision code ([camera-and-map.md](camera-and-map.md) — `tile_collision.asm` ends at `$02E396`) and depend on the scene script engine ([scene-engine.md](scene-engine.md)), VBlank/joypad layer ([hardware-and-init.md](hardware-and-init.md)), and world-state glue ([game-systems.md](game-systems.md)).

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

| Address | Name | Size | Description |
|---------|------|------|-------------|
| `$02E396` | InventoryMenuDef | 3 B | Actor definition header for the inventory menu controller. Type `$00`, priority `$00`, flags `$28`. The `{ … }` block... |
| `$02E399` | InventoryMenuInit | 115 B | One-time menu bootstrap. Assigns spritemap, draws BG3 backdrop text, spawns 16 linked `InventorySlotActor` instances ... |
| `$02E40C` | InventoryMainLoop | 57 B | Tab-bar main loop running each actor frame. Refreshes BG3 header/footer, polls tab input, dispatches hover previews o... |
| `$02E43D` | TabHoverDispatch | 8 B | Four word pointers for tab hover preview handlers, indexed by `$0AFA`. |
| `$02E445` | TabConfirmDispatch | 25 B | Plays tab-enter sound and dispatches the confirmed tab action via `TabActionDispatch`. |
| `$02E456` | TabActionDispatch | 8 B | Four word pointers for confirmed tab action handlers. |
| `$02E45E` | UseItemTab | 129 B | Equip-item tab. Configures BG scroll mode, draws USE header, shows equip cursor on the 4×4 grid, displays item descri... |
| `$02E4B8` | UseItemCursorUp | 22 B | Equip cursor up: subtract 4 with `$0F` wrap (one grid row). |
| `$02E4CE` | UseItemCursorDown | 22 B | Equip cursor down: add 4 with wrap. |
| `$02E4E4` | UseItemCursorLeft | 19 B | Equip cursor left: decrement with wrap. |
| `$02E4F7` | UseItemCursorRight | 20 B | Equip cursor right: increment with wrap. |
| `$02E50B` | UseItemConfirm | 43 B | Writes selected slot to `inventory_equipped_index` and item type to `inventory_equipped_type`. Empty slot clears equi... |
| `$02E536` | ArrangeItemsTab | 77 B | Swap setup phase. Hides equip cursor, spawns selection cursor, draws ARRANGE header, positions cursor on grid slot `$... |
| `$02E583` | ArrangePickTarget | 87 B | Swap target phase. Saves source slot/cursor, spawns second cursor, draws SWAP prompt, navigates target index `$22` vs... |
| `$02E5DA` | ArrangePerformSwap | 112 B | Executes slot swap. No-op if source == target. Swaps low bytes of two `inventory_slots` entries, refreshes both slot ... |
| `$02E64A` | ArrangeCancelTarget | 2 B | `COP [KillNext]` — removes only the target selection cursor. |
| `$02E64C` | ArrangeCancelTab | 11 B | Kills active cursor, sets input mask, returns to tab bar. |
| `$02E657` | DiscardItemTab | 180 B | Discard flow with Yes/No confirmation. Hides equip cursor, spawns selection cursor, validates non-empty discardable i... |
| `$02E70B` | DiscardCancelTab | 14 B | Cancel discard tab: restore equip cursor visibility and return to main loop. |
| `$02E719` | StatusViewTab | 138 B | Character ability status viewer. Sets BG mode 0, draws status header, spawns cursor, shows ability description for un... |
| `$02E768` | StatusCursorUp | 21 B | Decrement ability row; wrap 0 → 2. |
| `$02E77D` | StatusCursorDown | 20 B | Increment ability row; wrap 3 → 0. |
| `$02E795` | StatusConfirmExit | 14 B | Exit status tab back to tab bar. |
| `$02E7A3` | StatusPositionCursor | 24 B | Positions selection cursor at Y coordinate for ability row `$22` using `StatusCursorPositions` table. |
| `$02E7BB` | StatusCursorPositions | 12 B | Three XY coordinate pairs for status ability rows at X=`$98`, Y=`$48`/`$60`/`$78`. |
| `$02E7C7` | TabHoverUse | 31 B | Use tab hover preview: list mode (hide slot icons), show equip cursor, hide status actors, draw item list + description. |
| `$02E7E6` | TabHoverArrange | 17 B | Arrange tab hover: hide slots, show equip cursor, draw grid layout preview. |
| `$02E7F7` | TabHoverDiscard | 31 B | Discard tab hover: same visibility as Use tab — list mode with equip cursor visible. |
| `$02E816` | TabHoverStatus | 177 B | Status tab hover: show all 16 slot icons, hide equip cursor, display equipped item and unlocked ability rows with tie... |
| `$02E8C7` | InventorySlotActor | 32 B | Item slot sprite actor. Increments spawn counter, computes grid position, shows/hides based on item type in `$28`. |
| `$02E8E7` | EquipCursorActor | 24 B | Equipped-item highlight cursor. Hidden if no item equipped (`inventory_equipped_index` negative); otherwise falls thr... |
| `$02E8F1` | SelectionCursorActor | 14 B | Generic blinking selection cursor used by Arrange, Discard, and Status tabs. |
| `$02E8FF` | EquippedItemDisplay | 16 B | Fixed-position icon showing currently equipped item type at ($28, $78). |
| `$02E915` | StatusCharRow3 | 31 B | Third ability tier row actor at ($98, $48). Sprite index = `$0AD4 × 3 + $44`. |
| `$02E934` | StatusCharRow2 | 31 B | Second ability tier row at ($98, $60). Sprite index = `$0AD4 × 3 + $45`. |
| `$02E953` | StatusCharRow1 | 31 B | First ability tier row at ($98, $78). Sprite index = `$0AD4 × 3 + $46`. |
| `$02E972` | ComputeAbilityIndex | 15 B | Computes BG3 ability description string index: `$0AE8 = ($0AD4 × 4) + row_arg + 1`. |
| `$02E981` | GridCursorUp | 21 B | Shared grid up for Arrange/Discard: `$22 = ($22 − 4) & $0F`. |
| `$02E996` | GridCursorDown | 21 B | Shared grid down: add 4 with wrap. |
| `$02E9AB` | GridCursorLeft | 17 B | Shared grid left: decrement with wrap. |
| `$02E9BD` | GridCursorRight | 17 B | Shared grid right: increment with wrap. |
| `$02E9CF` | SetSlotSprite | 11 B | Writes item sprite type to actor `$0028,Y` and clears animation state. |
| `$02E9DC` | TestAbilityFlag | 17 B | Tests whether an ability tier is unlocked. Flag index = `$0AD4 × 4 + row`. Calls `TestFlag_0510` in bank `$05`; carry... |
| `$02E9ED` | UpdateSlotActorSprite | 35 B | Refreshes a slot actor's sprite after inventory mutation. Walks linked list from `$7F0010,X` to slot index in A, rese... |
| `$02EA13` | CheckItemDiscardable | 34 B | Tests whether item ID in A may be discarded. Indexes 3-bit-per-item bit array at `binary_01E12A`. Carry set = discard... |
| `$02EA35` | BitMaskTable | 8 B | Eight single-bit masks `$01`–`$80` for discardable-item lookup. |
| `$02EA3D` | PositionGridCursor | 54 B | Computes XY for grid selection cursor. Uses `$22` (or `$2E` for second cursor in arrange) and `GridColumnPositions`. |
| `$02EA73` | PositionEquipCursor | 46 B | Positions equip cursor on grid using `$1A`. If index negative, hides cursor instead. |
| `$02EAB0` | GridColumnPositions | 16 B | Four column base coordinates for 4×4 grid cursors at Y=`$30`, X=`$5C`/`$74`/`$8C`/`A4`. |
| `$02EAC0` | HideStatusActors | 55 B | Hides equipped-item display and all three status row actors by setting flag bit `$2000`. |
| `$02EAF7` | ShowEquipCursor | 20 B | Shows equip cursor if an item is equipped (index ≥ 0). |
| `$02EB0B` | HideEquipCursor | 15 B | Hides equip cursor actor via flag bit `$2000`. |
| `$02EB1A` | HideAllItemSlots | 43 B | Switches to list mode: hides all 16 slot icon sprites. Guarded — only runs when menu flag `$1000` is clear. |
| `$02EB45` | ShowAllItemSlots | 32 B | Switches to grid mode: shows all 16 slot icons. Guarded — only when `$1000` is set. |
| `$02EB70` | ComputeSlotPosition | 22 B | Computes spawn XY for slot actor using `($0AFA − 1) × 4` index into SlotPositionTable. |
| `$02EB86` | SlotPositionTable | 64 B | 16 XY pairs for item slot positions on 4×4 grid. Columns `$5C/$74/$8C/$A4`, rows Y=`$31/$41/$51/$61`. |
| `$02EBC6` | YesNoPromptLoop | 44 B | Yes/No dialog input loop with blinking cursor. Returns carry set on confirm. |
| `$02EBF2` | YesNoSelectUp | 24 B | Toggle Yes/No selection up (toward Yes). |
| `$02EC0A` | YesNoSelectDown | 24 B | Toggle Yes/No selection down (toward No). |
| `$02EC22` | YesNoConfirm | 11 B | Confirms Yes/No choice. Returns carry set. |
| `$02EC2D` | YesNoDrawCursor | 25 B | Draws Yes/No highlight cursor tile `$202B` in VRAM buffer at offset derived from `$28`. |
| `$02EC46` | YesNoClearCursor | 18 B | Clears Yes/No cursor tiles and sets VRAM flush flag. |
| `$02EC58` | TabSelectionLoop | 50 B | Main tab bar input loop with blinking cursor. Confirm enters tab; Cancel closes inventory. |
| `$02EC8A` | TabSelectUp | 26 B | Previous tab (wrap 0 → 3). |
| `$02ECA4` | TabSelectDown | 26 B | Next tab (wrap 3 → 0). |
| `$02ECBE` | TabCancel | 5 B | `COP [SetFlagByte] (#00)` — signals overlay exit loop. Returns carry clear. |
| `$02ECC3` | TabConfirm | 11 B | Confirms tab selection. Returns carry set to InventoryMainLoop. |
| `$02ECCE` | TabDrawCursor | 26 B | Draws tab highlight cursor tile at VRAM buffer offset `$0584 + ($0AFA × $100)`. |
| `$02ECE8` | TabClearCursor | 26 B | Clears all four tab cursor positions in VRAM buffer. |

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

**Source:**

```16:52:../../../extracted/system/inventory/inventory_menu.asm
```

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

**Source:**

```54:68:../../../extracted/system/inventory/inventory_menu.asm
```

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

Plays tab-enter sound and dispatches the confirmed tab action via `TabActionDispatch`.

**Algorithm:**
1. Sound `#0D`
2. Copy `$0AFA` → `$18`, `$0000`
3. `SwitchCase` → `TabActionDispatch`

**Source:**

```84:90:../../../extracted/system/inventory/inventory_menu.asm
```

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

**Source:**

```99:126:../../../extracted/system/inventory/inventory_menu.asm
```

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

**Source:**

```174:193:../../../extracted/system/inventory/inventory_menu.asm
```

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

**Source:**

```195:219:../../../extracted/system/inventory/inventory_menu.asm
```

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

**Source:**

```221:247:../../../extracted/system/inventory/inventory_menu.asm
```

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

**Source:**

```249:308:../../../extracted/system/inventory/inventory_menu.asm
```

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

**Source:**

```321:394:../../../extracted/system/inventory/inventory_menu.asm
```

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

**Source:**

```404:431:../../../extracted/system/inventory/inventory_menu.asm
```

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

Positions selection cursor at Y coordinate for ability row `$22` using `StatusCursorPositions` table.

**Algorithm:**
1. `$22 × 4` → index into table
2. Write X/Y to cursor actor `$0014`/`$0016`

**Source:**

```470:483:../../../extracted/system/inventory/inventory_menu.asm
```

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

Use tab hover preview: list mode (hide slot icons), show equip cursor, hide status actors, draw item list + description.

**Algorithm:**
1. HideAllItemSlots
2. ShowEquipCursor
3. HideStatusActors
4. BG3 list + description scripts
5. `$0AE6 = 4`

**Source:**

```491:501:../../../extracted/system/inventory/inventory_menu.asm
```

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

Arrange tab hover: hide slots, show equip cursor, draw grid layout preview.

**Algorithm:**
1. HideAllItemSlots
2. ShowEquipCursor
3. BG3 ARRANGE preview scripts
4. RTL

**Source:**

```513:519:../../../extracted/system/inventory/inventory_menu.asm
```

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

Discard tab hover: same visibility as Use tab — list mode with equip cursor visible.

**Algorithm:**
1. HideAllItemSlots
2. ShowEquipCursor
3. HideStatusActors
4. BG3 scripts
5. `$0AE6 = 4`

**Source:**

```511:521:../../../extracted/system/inventory/inventory_menu.asm
```

**Variables:**
| Location | Direction | Role |
|----------|-----------|------|
| `$0AE6` | W | BG mode |

**Cross-References:**
| Symbol | Relationship |
|--------|--------------|
| `TabHoverDispatch` | Entry 2 |

### TabHoverStatus

Status tab hover: show all 16 slot icons, hide equip cursor, display equipped item and unlocked ability rows with tier descriptions.

**Algorithm:**
1. ShowAllItemSlots
2. HideEquipCursor
3. Draw status header scripts
4. Show equipped item on EquippedItemDisplay
5. For rows 0–2: TestAbilityFlag → show row + BG3 description

**Source:**

```523:589:../../../extracted/system/inventory/inventory_menu.asm
```

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

**Source:**

```591:613:../../../extracted/system/inventory/inventory_menu.asm
```

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

**Source:**

```625:630:../../../extracted/system/inventory/inventory_menu.asm
```

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

Generic blinking selection cursor used by Arrange, Discard, and Status tabs.

**Algorithm:**
1. Stage sprite `#40`, set entry/exit
2. Animate each frame until `$2A` non-zero

**Source:**

```632:642:../../../extracted/system/inventory/inventory_menu.asm
```

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

Fixed-position icon showing currently equipped item type at ($28, $78).

**Algorithm:**
1. Position ($28, $78)
2. Load `inventory_equipped_type` → `$28`
3. Single-frame animation

**Source:**

```644:655:../../../extracted/system/inventory/inventory_menu.asm
```

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

**Source:**

```647:663:../../../extracted/system/inventory/inventory_menu.asm
```

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

**Source:**

```665:681:../../../extracted/system/inventory/inventory_menu.asm
```

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

**Source:**

```683:699:../../../extracted/system/inventory/inventory_menu.asm
```

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

**Source:**

```781:801:../../../extracted/system/inventory/inventory_menu.asm
```

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

Tests whether item ID in A may be discarded. Indexes 3-bit-per-item bit array at `binary_01E12A`. Carry set = discardable, clear = protected.

**Algorithm:**
1. Item ID → byte index (÷8) + bit index (mod 8)
2. AND with BitMaskTable entry
3. SEC if non-zero (discardable)

**Source:**

```803:825:../../../extracted/system/inventory/inventory_menu.asm
```

**Variables:**
| Location | Direction | Role |
|----------|-----------|------|
| `A` | In | Item ID |

**Cross-References:**
| Symbol | Relationship |
|--------|--------------|
| `BitMaskTable` | Lookup |
| `binary_01E12A` | Protection bit array |

#### 20I — Cursor Positioning

### PositionGridCursor

Computes XY for grid selection cursor. Uses `$22` (or `$2E` for second cursor in arrange) and `GridColumnPositions`.

**Algorithm:**
1. Select index from `$22` or `$2E` based on cursor ID
2. Column = index & 3 → GridColumnPositions
3. Row offset = index & `$0C` added to base Y `$30`
4. Write to cursor `$0014`/`$0016`

**Source:**

```838:869:../../../extracted/system/inventory/inventory_menu.asm
```

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

**Source:**

```871:903:../../../extracted/system/inventory/inventory_menu.asm
```

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

Hides equipped-item display and all three status row actors by setting flag bit `$2000`.

**Algorithm:**
1. Walk chain from `$7F0018,X` and `$7F001A,X`
2. ORA `$2000` on each actor `$0010`

**Source:**

```912:934:../../../extracted/system/inventory/inventory_menu.asm
```

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

Shows equip cursor if an item is equipped (index ≥ 0).

**Algorithm:**
1. If inventory_equipped_index negative → HideEquipCursor
2. Else AND `#$DFFF` on cursor `$0010`

**Source:**

```936:945:../../../extracted/system/inventory/inventory_menu.asm
```

**Variables:**
| Location | Direction | Role |
|----------|-----------|------|
| `$inventory_equipped_index` | R | Equip slot |

**Cross-References:**
| Symbol | Relationship |
|--------|--------------|
| `HideEquipCursor` | BMI branch |

### HideAllItemSlots

Switches to list mode: hides all 16 slot icon sprites. Guarded — only runs when menu flag `$1000` is clear.

**Algorithm:**
1. If `$10` bit `$1000` set → RTS
2. Set `$1000` on menu actor
3. Walk 16 slot actors via `$0006` chain
4. AND `#$DFFF` on each slot `$0010`

**Source:**

```956:979:../../../extracted/system/inventory/inventory_menu.asm
```

**Variables:**
| Location | Direction | Role |
|----------|-----------|------|
| `$10` | RW | Menu actor flags |
| `$7F0010,X` | R | Slot list head |

**Cross-References:**
| Symbol | Relationship |
|--------|--------------|
| `ShowAllItemSlots` | Inverse |
| `TabHoverUse` | Caller |

### ShowAllItemSlots

Switches to grid mode: shows all 16 slot icons. Guarded — only when `$1000` is set.

**Algorithm:**
1. If `$1000` clear → RTS
2. Clear `$1000`
3. Walk slot list, ORA `$2000` on each (show)

**Source:**

```981:1004:../../../extracted/system/inventory/inventory_menu.asm
```

**Variables:**
| Location | Direction | Role |
|----------|-----------|------|
| `$10` | RW | Menu actor flags |

**Cross-References:**
| Symbol | Relationship |
|--------|--------------|
| `HideAllItemSlots` | Inverse |
| `TabHoverStatus` | Caller |

### ComputeSlotPosition

Computes spawn XY for slot actor using `($0AFA − 1) × 4` index into SlotPositionTable.

**Algorithm:**
1. DEC `$0AFA`, ×4 → table index
2. Load X/Y → menu actor `$14`/`$16`

**Source:**

```1006:1019:../../../extracted/system/inventory/inventory_menu.asm
```

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

**Source:**

```1040:1062:../../../extracted/system/inventory/inventory_menu.asm
```

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

Draws Yes/No highlight cursor tile `$202B` in VRAM buffer at offset derived from `$28`.

**Algorithm:**
1. Clear old cursor
2. Compute buffer offset `$0696 + ($28>>8)`
3. Write tile `$202B` to `$7F:0200,X`

**Source:**

```1100:1114:../../../extracted/system/inventory/inventory_menu.asm
```

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

**Source:**

```1125:1148:../../../extracted/system/inventory/inventory_menu.asm
```

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

Draws tab highlight cursor tile at VRAM buffer offset `$0584 + ($0AFA × $100)`.

**Algorithm:**
1. Clear all tab cursors
2. Write `$202B` at computed offset

**Source:**

```1192:1206:../../../extracted/system/inventory/inventory_menu.asm
```

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

Clears all four tab cursor positions in VRAM buffer.

**Algorithm:**
1. Set VRAM flush flag
2. Write `$2040` at `$0784`, `$0804`, `$0884`, `$0904`

**Source:**

```1208:1217:../../../extracted/system/inventory/inventory_menu.asm
```

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
