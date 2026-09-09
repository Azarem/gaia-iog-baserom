# Bank $02 — Inventory System & Utility Functions

**Bank:** `$02` (FastROM; accessed via `$@` long calls from other banks)  
**Document scope:** Inventory menu actor system (69 parts), full-screen overlay orchestrator (6 parts), dialogue frame utility (1 part), VRAM buffer clear (2 parts).  
**Address span:** `$02E396`–`$02F08C` (3,318 bytes)  
**Total parts:** 78

---


## Overview


This document covers four ASM compilation units in bank `$02` that implement Illusion of Gaia's **inventory UI pipeline**:

1. **`inventory_menu.asm`** — COP-scripted actor scene with four tabs (Use, Arrange, Discard, Status), 16 item slots, equipment cursor, and character status rows.
2. **`inventory_overlay.asm`** — State-sandwich wrapper: saves gameplay, switches to scene `$FF`, runs inventory, restores on exit.
3. **`dialogue_display.asm`** — Thin JSL entry that renders one dialogue frame while suppressing joypad input.
4. **`vram_buffer_clear.asm`** — Clears the BG tilemap VRAM staging buffer at `$7F:0200`.

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


## inventory_menu.asm

| Property | Value |
|----------|-------|
| **Path** | [`extracted/system/inventory/inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |
| **Block** | `inventory_menu` |
| **Scene** | `inventory` |
| **Address range** | `$02E396`–`$02ED02` (2,412 bytes) |
| **Type** | `actor_def` + freestanding labels |
| **Includes** | `cop_handlers_script`, `inventory_spritemap`, `system_strings` |


#### 20A — Init & Main Loop

### InventoryMenuDef

| Property | Value |
|----------|-------|
| **Name** | `InventoryMenuDef` |
| **Address** | $02E396 |
| **Decimal** | 189334 |
| **Size** | 3 B |
| **Type** | actor_def |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

Actor definition header for the inventory menu controller. Type `$00`, priority `$00`, flags `$28`. The `{ … }` block embeds `InventoryMenuInit` and `InventoryMainLoop` as COP bytecode scripts.


**Algorithm:**

1. Define actor type, priority, flags `$28`
2. Embed init script label `InventoryMenuInit`
3. Embed main loop label `InventoryMainLoop`


**Source:**

```13:75:../../../extracted/system/inventory/inventory_menu.asm
```


**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$0010` | RW | Actor flags; bit `$1000` marks slots-hidden mode |


**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `InventoryMenuInit` | Embedded init |
| `InventoryMainLoop` | Embedded loop |
| `TabHoverDispatch` | Referenced via SwitchCase |

### InventoryMenuInit

| Property | Value |
|----------|-------|
| **Name** | `InventoryMenuInit` |
| **Address** | $02E399 |
| **Decimal** | 189337 |
| **Size** | 115 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

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

| Property | Value |
|----------|-------|
| **Name** | `InventoryMainLoop` |
| **Address** | $02E40C |
| **Decimal** | 189452 |
| **Size** | 57 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

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

### TabHoverDispatch

| Property | Value |
|----------|-------|
| **Name** | `TabHoverDispatch` |
| **Address** | $02E43D |
| **Decimal** | 189501 |
| **Size** | 8 B |
| **Type** | &Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

Four word pointers for tab hover preview handlers, indexed by `$0AFA`.


**Algorithm:**

1. [0] TabHoverUse
2. [1] TabHoverArrange
3. [2] TabHoverDiscard
4. [3] TabHoverStatus


**Source:**

```77:82:../../../extracted/system/inventory/inventory_menu.asm
```


**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$0000` | R | Tab index |


**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `TabHoverUse` | Entry 0 |
| `TabHoverArrange` | Entry 1 |
| `TabHoverDiscard` | Entry 2 |
| `TabHoverStatus` | Entry 3 |

### TabConfirmDispatch

| Property | Value |
|----------|-------|
| **Name** | `TabConfirmDispatch` |
| **Address** | $02E445 |
| **Decimal** | 189509 |
| **Size** | 25 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

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

### TabActionDispatch

| Property | Value |
|----------|-------|
| **Name** | `TabActionDispatch` |
| **Address** | $02E456 |
| **Decimal** | 189526 |
| **Size** | 8 B |
| **Type** | &Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

Four word pointers for confirmed tab action handlers.


**Algorithm:**

1. [0] UseItemTab
2. [1] ArrangeItemsTab
3. [2] DiscardItemTab
4. [3] StatusViewTab


**Source:**

```92:97:../../../extracted/system/inventory/inventory_menu.asm
```


**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$0000` | R | Tab index |


**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `UseItemTab` | Entry 0 |
| `ArrangeItemsTab` | Entry 1 |
| `DiscardItemTab` | Entry 2 |
| `StatusViewTab` | Entry 3 |


#### 20B — Use Item Tab

### UseItemTab

| Property | Value |
|----------|-------|
| **Name** | `UseItemTab` |
| **Address** | $02E45E |
| **Decimal** | 189534 |
| **Size** | 129 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

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

### UseItemCursorUp

| Property | Value |
|----------|-------|
| **Name** | `UseItemCursorUp` |
| **Address** | $02E4B8 |
| **Decimal** | 189624 |
| **Size** | 22 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

Equip cursor up: subtract 4 with `$0F` wrap (one grid row).


**Algorithm:**

1. Mask `$0B00`, sound `#10`
2. `$1A = ($1A − 4) & $0F`
3. BRA redraw


**Source:**

```128:138:../../../extracted/system/inventory/inventory_menu.asm
```


**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$1A` | RW | Slot index |


**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `GridCursorUp` | Same math on `$22` |

### UseItemCursorDown

| Property | Value |
|----------|-------|
| **Name** | `UseItemCursorDown` |
| **Address** | $02E4CE |
| **Decimal** | 189646 |
| **Size** | 22 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

Equip cursor down: add 4 with wrap.


**Algorithm:**

1. Mask `$0700`, sound `#10`
2. `$1A = ($1A + 4) & $0F`


**Source:**

```140:150:../../../extracted/system/inventory/inventory_menu.asm
```


**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$1A` | RW | Slot index |


**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `GridCursorDown` | Shared handler |

### UseItemCursorLeft

| Property | Value |
|----------|-------|
| **Name** | `UseItemCursorLeft` |
| **Address** | $02E4E4 |
| **Decimal** | 189668 |
| **Size** | 19 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

Equip cursor left: decrement with wrap.


**Algorithm:**

1. Mask `$0200`, sound `#10`
2. `$1A = ($1A − 1) & $0F`


**Source:**

```152:161:../../../extracted/system/inventory/inventory_menu.asm
```


**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$1A` | RW | Slot index |


**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `GridCursorLeft` | Shared handler |

### UseItemCursorRight

| Property | Value |
|----------|-------|
| **Name** | `UseItemCursorRight` |
| **Address** | $02E4F7 |
| **Decimal** | 189687 |
| **Size** | 20 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

Equip cursor right: increment with wrap.


**Algorithm:**

1. Mask `$0100`, sound `#10`
2. `$1A = ($1A + 1) & $0F`


**Source:**

```163:172:../../../extracted/system/inventory/inventory_menu.asm
```


**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$1A` | RW | Slot index |


**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `GridCursorRight` | Shared handler |

### UseItemConfirm

| Property | Value |
|----------|-------|
| **Name** | `UseItemConfirm` |
| **Address** | $02E50B |
| **Decimal** | 189707 |
| **Size** | 43 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

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

| Property | Value |
|----------|-------|
| **Name** | `ArrangeItemsTab` |
| **Address** | $02E536 |
| **Decimal** | 189750 |
| **Size** | 77 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

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

| Property | Value |
|----------|-------|
| **Name** | `ArrangePickTarget` |
| **Address** | $02E583 |
| **Decimal** | 189827 |
| **Size** | 87 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

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

| Property | Value |
|----------|-------|
| **Name** | `ArrangePerformSwap` |
| **Address** | $02E5DA |
| **Decimal** | 189914 |
| **Size** | 112 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

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

### ArrangeCancelTarget

| Property | Value |
|----------|-------|
| **Name** | `ArrangeCancelTarget` |
| **Address** | $02E64A |
| **Decimal** | 190026 |
| **Size** | 2 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:** `COP [KillNext]` — removes only the target selection cursor.


**Source:**

```310:312:../../../extracted/system/inventory/inventory_menu.asm
```

### ArrangeCancelTab

| Property | Value |
|----------|-------|
| **Name** | `ArrangeCancelTab` |
| **Address** | $02E64C |
| **Decimal** | 190028 |
| **Size** | 11 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

Kills active cursor, sets input mask, returns to tab bar.


**Algorithm:**

1. KillNext cursor
2. Mask `$4040`
3. JMP InventoryMainLoop


**Source:**

```314:319:../../../extracted/system/inventory/inventory_menu.asm
```


**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$0658` | W | Joypad mask |


**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `InventoryMainLoop` | Return |


#### 20D — Discard Item Tab

### DiscardItemTab

| Property | Value |
|----------|-------|
| **Name** | `DiscardItemTab` |
| **Address** | $02E657 |
| **Decimal** | 190039 |
| **Size** | 180 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

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

### DiscardCancelTab

| Property | Value |
|----------|-------|
| **Name** | `DiscardCancelTab` |
| **Address** | $02E70B |
| **Decimal** | 190219 |
| **Size** | 14 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

Cancel discard tab: restore equip cursor visibility and return to main loop.


**Algorithm:**

1. Mask `$4040`
2. KillNext cursor
3. ShowEquipCursor
4. JMP InventoryMainLoop


**Source:**

```396:402:../../../extracted/system/inventory/inventory_menu.asm
```


**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `ShowEquipCursor` | JSR |
| `InventoryMainLoop` | Return |


#### 20E — Status View Tab

### StatusViewTab

| Property | Value |
|----------|-------|
| **Name** | `StatusViewTab` |
| **Address** | $02E719 |
| **Decimal** | 190233 |
| **Size** | 138 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

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

### StatusCursorUp

| Property | Value |
|----------|-------|
| **Name** | `StatusCursorUp` |
| **Address** | $02E768 |
| **Decimal** | 190312 |
| **Size** | 21 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

Decrement ability row; wrap 0 → 2.


**Algorithm:**

1. Mask `$0800`, sound `#10`
2. DEC `$22`; if negative set 2


**Source:**

```433:445:../../../extracted/system/inventory/inventory_menu.asm
```


**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$22` | RW | Row index |


**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `StatusViewTab` | Loop target |

### StatusCursorDown

| Property | Value |
|----------|-------|
| **Name** | `StatusCursorDown` |
| **Address** | $02E77D |
| **Decimal** | 190333 |
| **Size** | 20 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

Increment ability row; wrap 3 → 0.


**Algorithm:**

1. Mask `$0400`, sound `#10`
2. INC `$22`; if ≥ 3 set 0


**Source:**

```447:460:../../../extracted/system/inventory/inventory_menu.asm
```


**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$22` | RW | Row index |


**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `StatusViewTab` | Loop target |

### StatusConfirmExit

| Property | Value |
|----------|-------|
| **Name** | `StatusConfirmExit` |
| **Address** | $02E795 |
| **Decimal** | 190357 |
| **Size** | 14 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

Exit status tab back to tab bar.


**Algorithm:**

1. Sound `#11`, mask `$C040`
2. KillNext cursor
3. JMP InventoryMainLoop


**Source:**

```462:468:../../../extracted/system/inventory/inventory_menu.asm
```


**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `InventoryMainLoop` | Return |

### StatusPositionCursor

| Property | Value |
|----------|-------|
| **Name** | `StatusPositionCursor` |
| **Address** | $02E7A3 |
| **Decimal** | 190371 |
| **Size** | 24 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

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

### StatusCursorPositions

| Property | Value |
|----------|-------|
| **Name** | `StatusCursorPositions` |
| **Address** | $02E7BB |
| **Decimal** | 190395 |
| **Size** | 12 B |
| **Type** | unk10 |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

Three XY coordinate pairs for status ability rows at X=`$98`, Y=`$48`/`$60`/`$78`.


**Algorithm:**

1. Row 0: ($98, $48)
2. Row 1: ($98, $60)
3. Row 2: ($98, $78)


**Source:**

```485:489:../../../extracted/system/inventory/inventory_menu.asm
```


**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `StatusPositionCursor` | Consumer |


#### 20F — Tab Hover Display

### TabHoverUse

| Property | Value |
|----------|-------|
| **Name** | `TabHoverUse` |
| **Address** | $02E7C7 |
| **Decimal** | 190407 |
| **Size** | 31 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

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

| Property | Value |
|----------|-------|
| **Name** | `TabHoverArrange` |
| **Address** | $02E7E6 |
| **Decimal** | 190438 |
| **Size** | 17 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

Arrange tab hover: hide slots, show equip cursor, draw grid layout preview.


**Algorithm:**

1. HideAllItemSlots
2. ShowEquipCursor
3. BG3 grid scripts


**Source:**

```503:509:../../../extracted/system/inventory/inventory_menu.asm
```


**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `TabHoverDispatch` | Entry 1 |

### TabHoverDiscard

| Property | Value |
|----------|-------|
| **Name** | `TabHoverDiscard` |
| **Address** | $02E7F7 |
| **Decimal** | 190455 |
| **Size** | 31 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

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

| Property | Value |
|----------|-------|
| **Name** | `TabHoverStatus` |
| **Address** | $02E816 |
| **Decimal** | 190486 |
| **Size** | 177 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

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

| Property | Value |
|----------|-------|
| **Name** | `InventorySlotActor` |
| **Address** | $02E8C7 |
| **Decimal** | 190663 |
| **Size** | 32 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

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

| Property | Value |
|----------|-------|
| **Name** | `EquipCursorActor` |
| **Address** | $02E8E7 |
| **Decimal** | 190695 |
| **Size** | 24 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

Equipped-item highlight cursor. Hidden if no item equipped (`inventory_equipped_index` negative); otherwise falls through to SelectionCursorActor animation.


**Algorithm:**

1. If equipped index ≥ 0 → SelectionCursorActor
2. Else set hide flag `$2000`


**Source:**

```615:620:../../../extracted/system/inventory/inventory_menu.asm
```


**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$inventory_equipped_index` | R | Equip slot |


**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `SelectionCursorActor` | Fall-through target |

### SelectionCursorActor

| Property | Value |
|----------|-------|
| **Name** | `SelectionCursorActor` |
| **Address** | $02E8F1 |
| **Decimal** | 190705 |
| **Size** | 14 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

Generic blinking selection cursor used by Arrange, Discard, and Status tabs.


**Algorithm:**

1. StageSprAndHitbox `#40`
2. One-frame animation loop until `$2A` expires


**Source:**

```622:632:../../../extracted/system/inventory/inventory_menu.asm
```


**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$2A` | R | Frame counter |


**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `ArrangeItemsTab` | Spawner |

### EquippedItemDisplay

| Property | Value |
|----------|-------|
| **Name** | `EquippedItemDisplay` |
| **Address** | $02E8FF |
| **Decimal** | 190719 |
| **Size** | 16 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

Fixed-position icon showing currently equipped item type at ($28, $78).


**Algorithm:**

1. Set position ($28, $78)
2. Sprite = inventory_equipped_type
3. Animate one frame


**Source:**

```634:645:../../../extracted/system/inventory/inventory_menu.asm
```


**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$inventory_equipped_type` | R | Item ID |


**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `TabHoverStatus` | Shows/hides via flags |

### StatusCharRow3

| Property | Value |
|----------|-------|
| **Name** | `StatusCharRow3` |
| **Address** | $02E915 |
| **Decimal** | 190741 |
| **Size** | 31 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

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

| Property | Value |
|----------|-------|
| **Name** | `StatusCharRow2` |
| **Address** | $02E934 |
| **Decimal** | 190772 |
| **Size** | 31 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

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

| Property | Value |
|----------|-------|
| **Name** | `StatusCharRow1` |
| **Address** | $02E953 |
| **Decimal** | 190803 |
| **Size** | 31 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

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

### ComputeAbilityIndex

| Property | Value |
|----------|-------|
| **Name** | `ComputeAbilityIndex` |
| **Address** | $02E972 |
| **Decimal** | 190834 |
| **Size** | 15 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

Computes BG3 ability description string index: `$0AE8 = ($0AD4 × 4) + row_arg + 1`.


**Algorithm:**

1. Push row arg
2. `$0AE8 = form×4 + arg + 1`
3. Pop and return


**Source:**

```701:712:../../../extracted/system/inventory/inventory_menu.asm
```


**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$0AD4` | R | Character form |
| `$0AE8` | W | String index |


**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `StatusViewTab` | Caller |
| `TabHoverStatus` | Caller |

### GridCursorUp

| Property | Value |
|----------|-------|
| **Name** | `GridCursorUp` |
| **Address** | $02E981 |
| **Decimal** | 190849 |
| **Size** | 21 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

Shared grid up for Arrange/Discard: `$22 = ($22 − 4) & $0F`.


**Algorithm:**

1. Mask `$0B00`, sound `#10`
2. Subtract 4, AND `$0F`
3. RTS (PEA caller resumes)


**Source:**

```714:724:../../../extracted/system/inventory/inventory_menu.asm
```


**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$22` | RW | Slot index |


**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `ArrangeItemsTab` | PEA caller |

### GridCursorDown

| Property | Value |
|----------|-------|
| **Name** | `GridCursorDown` |
| **Address** | $02E996 |
| **Decimal** | 190870 |
| **Size** | 21 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

Shared grid down: add 4 with wrap.


**Algorithm:**

1. Mask `$0700`, sound `#10`
2. Add 4, AND `$0F`


**Source:**

```726:736:../../../extracted/system/inventory/inventory_menu.asm
```


**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$22` | RW | Slot index |


**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `DiscardItemTab` | PEA caller |

### GridCursorLeft

| Property | Value |
|----------|-------|
| **Name** | `GridCursorLeft` |
| **Address** | $02E9AB |
| **Decimal** | 190891 |
| **Size** | 17 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

Shared grid left: decrement with wrap.


**Algorithm:**

1. Mask `$0200`, sound `#10`
2. DEC, AND `$0F`


**Source:**

```738:747:../../../extracted/system/inventory/inventory_menu.asm
```


**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$22` | RW | Slot index |

### GridCursorRight

| Property | Value |
|----------|-------|
| **Name** | `GridCursorRight` |
| **Address** | $02E9BD |
| **Decimal** | 190909 |
| **Size** | 17 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

Shared grid right: increment with wrap.


**Algorithm:**

1. Mask `$0100`, sound `#10`
2. INC, AND `$0F`


**Source:**

```749:758:../../../extracted/system/inventory/inventory_menu.asm
```


**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$22` | RW | Slot index |

### SetSlotSprite

| Property | Value |
|----------|-------|
| **Name** | `SetSlotSprite` |
| **Address** | $02E9CF |
| **Decimal** | 190927 |
| **Size** | 11 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

Writes item sprite type to actor `$0028,Y` and clears animation state.


**Algorithm:**

1. Store A → `$0028,Y`
2. Zero `$002A,Y` and `$0008,Y`


**Source:**

```760:766:../../../extracted/system/inventory/inventory_menu.asm
```


**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$0028,Y` | W | Sprite/item type |


**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `TabHoverStatus` | Equipped display |

### TestAbilityFlag

| Property | Value |
|----------|-------|
| **Name** | `TestAbilityFlag` |
| **Address** | $02E9DC |
| **Decimal** | 190940 |
| **Size** | 17 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

Tests whether an ability tier is unlocked. Flag index = `$0AD4 × 4 + row`. Calls `TestFlag_0510` in bank `$05`; carry set = unlocked.


**Algorithm:**

1. Compute flag index from form + row on stack
2. JSL TestFlag_0510
3. Return with carry


**Source:**

```768:779:../../../extracted/system/inventory/inventory_menu.asm
```


**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$0AD4` | R | Character form |
| `$0004` | R | Form copy |


**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `TestFlag_0510` | Bank $05 callee |

### UpdateSlotActorSprite

| Property | Value |
|----------|-------|
| **Name** | `UpdateSlotActorSprite` |
| **Address** | $02E9ED |
| **Decimal** | 190957 |
| **Size** | 35 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

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

| Property | Value |
|----------|-------|
| **Name** | `CheckItemDiscardable` |
| **Address** | $02EA13 |
| **Decimal** | 190995 |
| **Size** | 34 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

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

### BitMaskTable

| Property | Value |
|----------|-------|
| **Name** | `BitMaskTable` |
| **Address** | $02EA35 |
| **Decimal** | 191029 |
| **Size** | 8 B |
| **Type** | Byte |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

Eight single-bit masks `$01`–`$80` for discardable-item lookup.


**Algorithm:**

1. Index by item_id mod 8
2. AND with protection byte


**Source:**

```827:836:../../../extracted/system/inventory/inventory_menu.asm
```


**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `CheckItemDiscardable` | Consumer |


#### 20I — Cursor Positioning

### PositionGridCursor

| Property | Value |
|----------|-------|
| **Name** | `PositionGridCursor` |
| **Address** | $02EA3D |
| **Decimal** | 191037 |
| **Size** | 54 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

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

| Property | Value |
|----------|-------|
| **Name** | `PositionEquipCursor` |
| **Address** | $02EA73 |
| **Decimal** | 191091 |
| **Size** | 46 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

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

### GridColumnPositions

| Property | Value |
|----------|-------|
| **Name** | `GridColumnPositions` |
| **Address** | $02EAB0 |
| **Decimal** | 191152 |
| **Size** | 16 B |
| **Type** | unk10 |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

Four column base coordinates for 4×4 grid cursors at Y=`$30`, X=`$5C`/`$74`/`$8C`/`A4`.


**Algorithm:**

1. Col 0–3 base XY pairs
2. Row adds `$10` per grid row via index bits 2–3


**Source:**

```905:910:../../../extracted/system/inventory/inventory_menu.asm
```


**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `PositionGridCursor` | Consumer |
| `PositionEquipCursor` | Consumer |


#### 20J — Item Grid Visibility

### HideStatusActors

| Property | Value |
|----------|-------|
| **Name** | `HideStatusActors` |
| **Address** | $02EAC0 |
| **Decimal** | 191168 |
| **Size** | 55 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

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

| Property | Value |
|----------|-------|
| **Name** | `ShowEquipCursor` |
| **Address** | $02EAF7 |
| **Decimal** | 191223 |
| **Size** | 20 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

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

### HideEquipCursor

| Property | Value |
|----------|-------|
| **Name** | `HideEquipCursor` |
| **Address** | $02EB0B |
| **Decimal** | 191243 |
| **Size** | 15 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

Hides equip cursor actor via flag bit `$2000`.


**Algorithm:**

1. ORA `$2000` on equip cursor `$0010`


**Source:**

```947:954:../../../extracted/system/inventory/inventory_menu.asm
```


**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$7F0012,X` | R | Equip cursor ID |


**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `ArrangeItemsTab` | Caller |

### HideAllItemSlots

| Property | Value |
|----------|-------|
| **Name** | `HideAllItemSlots` |
| **Address** | $02EB1A |
| **Decimal** | 191258 |
| **Size** | 43 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

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

| Property | Value |
|----------|-------|
| **Name** | `ShowAllItemSlots` |
| **Address** | $02EB45 |
| **Decimal** | 191301 |
| **Size** | 32 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

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

| Property | Value |
|----------|-------|
| **Name** | `ComputeSlotPosition` |
| **Address** | $02EB70 |
| **Decimal** | 191344 |
| **Size** | 22 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

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

### SlotPositionTable

| Property | Value |
|----------|-------|
| **Name** | `SlotPositionTable` |
| **Address** | $02EB86 |
| **Decimal** | 191366 |
| **Size** | 64 B |
| **Type** | unk10 |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

16 XY pairs for item slot positions on 4×4 grid. Columns `$5C/$74/$8C/$A4`, rows Y=`$31/$41/$51/$61`.


**Algorithm:**

1. Index 0–15 → screen coordinates


**Source:**

```1021:1038:../../../extracted/system/inventory/inventory_menu.asm
```


**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `ComputeSlotPosition` | Consumer |


#### 20K — Yes/No Prompt & Tab Selection

### YesNoPromptLoop

| Property | Value |
|----------|-------|
| **Name** | `YesNoPromptLoop` |
| **Address** | $02EBC6 |
| **Decimal** | 191430 |
| **Size** | 44 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

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

### YesNoSelectUp

| Property | Value |
|----------|-------|
| **Name** | `YesNoSelectUp` |
| **Address** | $02EBF2 |
| **Decimal** | 191474 |
| **Size** | 24 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

Toggle Yes/No selection up (toward Yes).


**Algorithm:**

1. Sound `#10`, mask `$0800`
2. `$28 = ($28 − 1) & 1`
3. Redraw cursor


**Source:**

```1064:1076:../../../extracted/system/inventory/inventory_menu.asm
```


**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$28` | RW | Selection |


**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `YesNoDrawCursor` | JSR |

### YesNoSelectDown

| Property | Value |
|----------|-------|
| **Name** | `YesNoSelectDown` |
| **Address** | $02EC0A |
| **Decimal** | 191498 |
| **Size** | 24 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

Toggle Yes/No selection down (toward No).


**Algorithm:**

1. Sound `#10`, mask `$0400`
2. `$28 = ($28 + 1) & 1`
3. Redraw cursor


**Source:**

```1078:1090:../../../extracted/system/inventory/inventory_menu.asm
```


**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$28` | RW | Selection |

### YesNoConfirm

| Property | Value |
|----------|-------|
| **Name** | `YesNoConfirm` |
| **Address** | $02EC22 |
| **Decimal** | 191522 |
| **Size** | 11 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

Confirms Yes/No choice. Returns carry set.


**Algorithm:**

1. Mask `$8000`
2. Redraw cursor
3. SEC RTS


**Source:**

```1092:1098:../../../extracted/system/inventory/inventory_menu.asm
```


**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$0658` | W | Joypad mask |


**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `YesNoPromptLoop` | Caller |

### YesNoDrawCursor

| Property | Value |
|----------|-------|
| **Name** | `YesNoDrawCursor` |
| **Address** | $02EC2D |
| **Decimal** | 191533 |
| **Size** | 25 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

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

### YesNoClearCursor

| Property | Value |
|----------|-------|
| **Name** | `YesNoClearCursor` |
| **Address** | $02EC46 |
| **Decimal** | 191558 |
| **Size** | 18 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

Clears Yes/No cursor tiles and sets VRAM flush flag.


**Algorithm:**

1. Set `$09EC` bit `$0001`
2. Write blank tile `$2040` at `$7F:0896` and `$7F:0916`


**Source:**

```1116:1123:../../../extracted/system/inventory/inventory_menu.asm
```


**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$09EC` | W | VRAM flush flag |


**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `YesNoDrawCursor` | Caller |

### TabSelectionLoop

| Property | Value |
|----------|-------|
| **Name** | `TabSelectionLoop` |
| **Address** | $02EC58 |
| **Decimal** | 191576 |
| **Size** | 50 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

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

### TabSelectUp

| Property | Value |
|----------|-------|
| **Name** | `TabSelectUp` |
| **Address** | $02EC8A |
| **Decimal** | 191626 |
| **Size** | 26 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

Previous tab (wrap 0 → 3).


**Algorithm:**

1. Sound `#10`, mask `$0800`
2. `$0AFA = ($0AFA − 1) & 3`
3. Redraw tab cursor


**Source:**

```1150:1162:../../../extracted/system/inventory/inventory_menu.asm
```


**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$0AFA` | RW | Tab index |

### TabSelectDown

| Property | Value |
|----------|-------|
| **Name** | `TabSelectDown` |
| **Address** | $02ECA4 |
| **Decimal** | 191652 |
| **Size** | 26 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

Next tab (wrap 3 → 0).


**Algorithm:**

1. Sound `#10`, mask `$0400`
2. `$0AFA = ($0AFA + 1) & 3`
3. Redraw tab cursor


**Source:**

```1164:1176:../../../extracted/system/inventory/inventory_menu.asm
```


**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$0AFA` | RW | Tab index |

### TabCancel

| Property | Value |
|----------|-------|
| **Name** | `TabCancel` |
| **Address** | $02ECBE |
| **Decimal** | 191678 |
| **Size** | 5 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:** `COP [SetFlagByte] (#00)` — signals overlay exit loop. Returns carry clear.


**Source:**

```1178:1182:../../../extracted/system/inventory/inventory_menu.asm
```

### TabConfirm

| Property | Value |
|----------|-------|
| **Name** | `TabConfirm` |
| **Address** | $02ECC3 |
| **Decimal** | 191683 |
| **Size** | 11 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

Confirms tab selection. Returns carry set to InventoryMainLoop.


**Algorithm:**

1. Mask `$8000`
2. Redraw cursor
3. SEC RTS


**Source:**

```1184:1190:../../../extracted/system/inventory/inventory_menu.asm
```


**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `TabSelectionLoop` | Caller |

### TabDrawCursor

| Property | Value |
|----------|-------|
| **Name** | `TabDrawCursor` |
| **Address** | $02ECCE |
| **Decimal** | 191694 |
| **Size** | 26 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

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

| Property | Value |
|----------|-------|
| **Name** | `TabClearCursor` |
| **Address** | $02ECE8 |
| **Decimal** | 191720 |
| **Size** | 26 B |
| **Type** | Code |
| **ASM file** | [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) |


**Description:**

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


## inventory_overlay.asm

| Property | Value |
|----------|-------|
| **Path** | [`extracted/functions/inventory/inventory_overlay.asm`](../../../extracted/functions/inventory/inventory_overlay.asm) |
| **Block** | `inventory_overlay` |
| **Scene** | `inventory` |
| **Address range** | `$02ED02`–`$02F048` (838 bytes) |
| **Includes** | `chunk_03BAE1`, `event_blocks`, `scene_script`, `system_core`, `system_init`, `system_strings`, `vblank_joypad`, `vram_buffer_clear`, `warps_interaction` |


`OpenInventoryScreen` is the JSL entry point called from gameplay when the player opens inventory. It implements a **state sandwich** — save everything, run an isolated scene, restore everything.

### State Preservation Map

| Saved Region | Size | Source → Temp Location |
|---|---|---|
| Joypad state | 6 B | `$0656` / `$0658` → `$7E:38AC` / `$7E:38AE` |
| Joypad mask | 2 B | `$065A` → `$7E:38B0` |
| Joypad repeat timer | 2 B | `$0DBC` ↔ `$0DBE` (swap) |
| Direct-page vars | 16 B | `$004E`–`$005D` → `$7E:389C` |
| Camera positions | 12 B | `$06BE`–`$06C9` → `$7E:3890` |
| WRAM `$00:0E00` | 256 B | → `$7E:3490` |
| WRAM `$7E:3000` | 256 B | self-swap MVN |
| WRAM `$00:1000` | 4 KB | → `$7F:E000` |
| WRAM `$7F:1000` | 4 KB | self-swap MVN |
| WRAM `$00:0F00` | 256 B | → `$7E:3690` |
| WRAM `$7F:0F00` | 256 B | self-swap MVN |
| Palette buffer | 515 B | `$7F:0A00` → `$7E:38B4` |

### OpenInventoryScreen

| Property | Value |
|----------|-------|
| **Name** | `OpenInventoryScreen` |
| **Address** | $02ED02 |
| **Decimal** | 191746 |
| **Size** | 389 B |
| **Type** | Code |
| **ASM file** | [`inventory_overlay.asm`](../../../extracted/functions/inventory/inventory_overlay.asm) |


**Description:**

Master inventory orchestrator (JSL entry). Implements the state sandwich: save gameplay, switch to scene `$FF`, run inventory UI loop, restore everything on exit.


**Algorithm:**

1. Disable HDMA; SaveGameState
2. Set inventory joypad mask `$0F00`
3. Push/pop `$06E4`, `$09EC`, `$0A00`, scene ID
4. scene_current ← `$FF`; SceneScriptNoMusic
5. Upload palette, zero camera, ClearVramBufferFull
6. Run actor init chain (chunk_03BAE1)
7. Loop UpdateFrame_Dialogue until `$0AE6` flag set
8. RestoreGameState, reload scene, event blocks, palette
9. ReloadAbilityFX, ClearVramBufferFull, map refresh
10. DrainActorQueue; exit flag `$FF`


**Source:**

```34:190:../../../extracted/functions/inventory/inventory_overlay.asm
```


**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$0644` | RW | scene_current |
| `$065C` | W | joypad_mask_inv |
| `$0AE6` | RW | Exit/tab flag |
| `$065A` | RW | joypad_mask_std |


**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `SaveGameState` | JSR |
| `RestoreGameState` | JSR |
| `ShowDialogueFrame` | Via UpdateFrame_Dialogue |
| `ClearVramBufferFull` | JSL |

### ReloadAbilityFX

| Property | Value |
|----------|-------|
| **Name** | `ReloadAbilityFX` |
| **Address** | $02EECC |
| **Decimal** | 192204 |
| **Size** | 63 B |
| **Type** | Code |
| **ASM file** | [`inventory_overlay.asm`](../../../extracted/functions/inventory/inventory_overlay.asm) |


**Description:**

Post-close ability graphics reload. DMAs Dark Friar or Aura FX tiles and palette based on active ability `$00EA`.


**Algorithm:**

1. If `$00EA = 0`: RTS
2. If 1 (Dark Friar): DMA misc_fx_1CC000 → VRAM `$4400`, copy palette
3. If 2 (Aura): DMA misc_fx_1CC480, alternate palette


**Source:**

```192:218:../../../extracted/functions/inventory/inventory_overlay.asm
```


**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$00EA` | R | Active ability |


**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `OpenInventoryScreen` | Caller on exit |
| `DmaWordToVram` | Bank scene_script |

### DrainActorQueue

| Property | Value |
|----------|-------|
| **Name** | `DrainActorQueue` |
| **Address** | $02EF0B |
| **Decimal** | 192267 |
| **Size** | 15 B |
| **Type** | Code |
| **ASM file** | [`inventory_overlay.asm`](../../../extracted/functions/inventory/inventory_overlay.asm) |


**Description:**

Walks actor linked list from `$5A` and zeroes frame counter `$0008` on each actor.


**Algorithm:**

1. TCD to each actor via `$0006` chain
2. STZ `$08` on each


**Source:**

```220:237:../../../extracted/functions/inventory/inventory_overlay.asm
```


**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$5A` | R | Actor list head |


**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `OpenInventoryScreen` | Caller on exit |

### SaveGameState

| Property | Value |
|----------|-------|
| **Name** | `SaveGameState` |
| **Address** | $02EF1D |
| **Decimal** | 192285 |
| **Size** | 149 B |
| **Type** | Code |
| **ASM file** | [`inventory_overlay.asm`](../../../extracted/functions/inventory/inventory_overlay.asm) |


**Description:**

Snapshots ~5.5 KB of gameplay WRAM, joypad state, camera, and palette buffer before inventory opens.


**Algorithm:**

1. Save joypad `$0656`/`$0658`/`065A` (zero live copies)
2. Swap repeat timer `$0DBC`↔`$0DBE`
3. Copy DP vars `$4E–$5D`, camera `$06BE–$06C9`
4. MVN six WRAM regions to scratch (see state map)
5. Copy palette `$7F:0A00` → `$7E:38B4`


**Source:**

```239:299:../../../extracted/functions/inventory/inventory_overlay.asm
```


**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$0656` | RW | Joypad held |
| `$0658` | RW | Joypad pressed |
| `$7E:3490` | W | Scratch save area |


**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `RestoreGameState` | Inverse |
| `OpenInventoryScreen` | Caller |

### RestoreGameState

| Property | Value |
|----------|-------|
| **Name** | `RestoreGameState` |
| **Address** | $02EFB2 |
| **Decimal** | 192434 |
| **Size** | 131 B |
| **Type** | Code |
| **ASM file** | [`inventory_overlay.asm`](../../../extracted/functions/inventory/inventory_overlay.asm) |


**Description:**

Inverse of SaveGameState: restores all six MVN regions, joypad, repeat timer, DP vars, and camera.


**Algorithm:**

1. Restore joypad from `$7E:38AC`/`38AE`/`38B0`
2. Swap repeat timer back
3. Restore DP + camera
4. Inverse MVN for all six regions


**Source:**

```301:355:../../../extracted/functions/inventory/inventory_overlay.asm
```


**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$0656` | W | Joypad held |
| `$06BE` | W | Camera X |


**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `RestorePaletteBuffer` | Separate palette restore |
| `OpenInventoryScreen` | Caller |

### RestorePaletteBuffer

| Property | Value |
|----------|-------|
| **Name** | `RestorePaletteBuffer` |
| **Address** | $02F035 |
| **Decimal** | 192565 |
| **Size** | 19 B |
| **Type** | Code |
| **ASM file** | [`inventory_overlay.asm`](../../../extracted/functions/inventory/inventory_overlay.asm) |


**Description:**

Copies 515 bytes of saved palette from `$7E:38B4` back to `$7F:0A00` after scene script may have overwritten it.


**Algorithm:**

1. MVN `$7E:38B4` → `$7F:0A00`, 515 bytes


**Source:**

```357:368:../../../extracted/functions/inventory/inventory_overlay.asm
```


**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$7E:38B4` | R | Saved palette |


**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `OpenInventoryScreen` | Caller |


---


## dialogue_display.asm

| Property | Value |
|----------|-------|
| **Path** | [`extracted/functions/dialogue_display.asm`](../../../extracted/functions/dialogue_display.asm) |
| **Block** | `dialogue_display` |
| **Address range** | `$02F048`–`$02F06A` (34 bytes) |

### ShowDialogueFrame

| Property | Value |
|----------|-------|
| **Name** | `ShowDialogueFrame` |
| **Address** | $02F048 |
| **Decimal** | 192584 |
| **Size** | 34 B |
| **Type** | Code |
| **ASM file** | [`dialogue_display.asm`](../../../extracted/functions/dialogue_display.asm) |


**Description:**

Single dialogue render frame. Saves joypad mask, sets DBR=`$81`, calls render pipeline, restores mask. Used by inventory overlay loop.


**Algorithm:**

1. Save + zero joypad_mask_std
2. DBR ← `$81`
3. JSL UpdateFrame_Render
4. JSL sub_03E255 (dialogue box draw)
5. Restore joypad mask


**Source:**

```7:27:../../../extracted/functions/dialogue_display.asm
```


**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$065A` | RW | joypad_mask_std |


**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `OpenInventoryScreen` | Via UpdateFrame_Dialogue |
| `UpdateFrame_Render` | Bank system_core |


---


## vram_buffer_clear.asm

| Property | Value |
|----------|-------|
| **Path** | [`extracted/functions/vram_buffer_clear.asm`](../../../extracted/functions/vram_buffer_clear.asm) |
| **Block** | `vram_buffer_clear` |
| **Address range** | `$02F06A`–`$02F08C` (34 bytes) |

Both routines zero-word-fill the BG tilemap staging area at `$7F:0200`–`$7F:0800`.

### ClearVramBufferPartial

| Property | Value |
|----------|-------|
| **Name** | `ClearVramBufferPartial` |
| **Address** | $02F06A |
| **Decimal** | 192618 |
| **Size** | 12 B |
| **Type** | Code |
| **ASM file** | [`vram_buffer_clear.asm`](../../../extracted/functions/vram_buffer_clear.asm) |


**Description:**

Partial VRAM buffer clear: zeros `$7F:0340`–`$7F:0800` (offset `$0140` from base). Preserves first 320 bytes.


**Algorithm:**

1. LDX `#$0140`
2. Zero-word loop to `$0800`


**Source:**

```3:10:../../../extracted/functions/vram_buffer_clear.asm
```


**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$7F:0200,X` | W | VRAM staging buffer |


**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `ClearVramBufferFull` | Shares loop at loc_02F07E |

### ClearVramBufferFull

| Property | Value |
|----------|-------|
| **Name** | `ClearVramBufferFull` |
| **Address** | $02F076 |
| **Decimal** | 192630 |
| **Size** | 22 B |
| **Type** | Code |
| **ASM file** | [`vram_buffer_clear.asm`](../../../extracted/functions/vram_buffer_clear.asm) |


**Description:**

Full VRAM buffer clear: zeros entire `$7F:0200`–`$7F:0800` (2048 bytes). Called on inventory open and close.


**Algorithm:**

1. LDX `#$0000`
2. Shared zero loop to `$0800`


**Source:**

```12:28:../../../extracted/functions/vram_buffer_clear.asm
```


**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$7F:0200,X` | W | VRAM staging buffer |


**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `OpenInventoryScreen` | JSL on open/close |
| `TabDrawCursor` | Writes into buffer |


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


## State Sandwich Pattern


The overlay follows a strict save → transform → run → restore sequence:

```
OpenInventoryScreen
  │
  ├─1─ SAVE ─────────────────────────────────────────────
  │     SaveGameState (WRAM, joypad, camera, palette)
  │     Push scene ID, $09EC, $0A00, $06E4 on stack
  │
  ├─2─ TRANSFORM ────────────────────────────────────────
  │     scene_current ← $FF (inventory scene)
  │     SceneScriptNoMusic (load inventory BG, no BGM)
  │     UploadCgramPalette, zero camera, ClearVramBufferFull
  │     Run actor init (chunk_03BAE1 helpers)
  │
  ├─3─ RUN ──────────────────────────────────────────────
  │     Loop: UpdateFrame_Dialogue until $0AE6 ≠ 0
  │       (TabCancel sets flag via COP SetFlagByte #00)
  │
  ├─4─ RESTORE ──────────────────────────────────────────
  │     RestoreGameState + RestorePaletteBuffer
  │     Pop scene ID → re-run SceneScriptNoMusic
  │     ApplyAllEventBlocks + PlaceBarrierTiles
  │     ReloadAbilityFX, ClearVramBufferFull, map refresh
  │     DrainActorQueue, exit flag $FF
  │
  └─5─ RETURN ───────────────────────────────────────────
        RTL to gameplay caller
```

This ensures the inventory scene can freely reconfigure PPU registers, BG modes, and `$7F:1000+` script space without corrupting overworld state.


## Summary Statistics


| Metric | Value |
|--------|-------|
| **Files documented** | 4 |
| **Blocks** | `inventory_menu`, `inventory_overlay`, `dialogue_display`, `vram_buffer_clear` |
| **Total parts** | 78 |
| **Total code size** | 3,318 bytes |
| **Address span** | `$02E396`–`$02F08C` |
| **Largest function** | `OpenInventoryScreen` — 389 bytes |
| **Smallest functions** | `ArrangeCancelTarget` (2 B), `TabCancel` (5 B) |
| **COP actor defs** | 1 (`InventoryMenuDef`) |
| **Dispatch tables** | 2 (`TabHoverDispatch`, `TabActionDispatch`) |
| **Lookup tables** | 4 (`StatusCursorPositions`, `GridColumnPositions`, `SlotPositionTable`, `BitMaskTable`) |
| **Child actors spawned** | 22 (16 slots + equip cursor + equipped display + 3 status rows + up to 2 selection cursors) |

### Size Breakdown by File

| File | Parts | Bytes | Hex Range |
|------|-------|-------|-----------|
| `inventory_menu.asm` | 69 | 2,412 | `$02E396`–`$02ED02` |
| `inventory_overlay.asm` | 6 | 838 | `$02ED02`–`$02F048` |
| `dialogue_display.asm` | 1 | 34 | `$02F048`–`$02F06A` |
| `vram_buffer_clear.asm` | 2 | 34 | `$02F06A`–`$02F08C` |

### Size Breakdown by Subgroup (`inventory_menu`)

| Subgroup | Parts | Description |
|----------|-------|-------------|
| 20A — Init & Main Loop | 6 | Actor def, init, tab dispatch |
| 20B — Use Item Tab | 6 | Equip cursor navigation |
| 20C — Arrange Tab | 5 | Two-phase swap flow |
| 20D — Discard Tab | 2 | Delete with Yes/No guard |
| 20E — Status Tab | 6 | Ability row viewer |
| 20F — Tab Hover | 4 | Preview UI per tab |
| 20G — Slot Actors | 7 | Sprites and cursors |
| 20H — Grid Utilities | 10 | Navigation, flags, discard test |
| 20I — Cursor Position | 3 | XY computation |
| 20J — Visibility | 7 | Show/hide batch control |
| 20K — Prompts & Tabs | 13 | Yes/No + tab bar input |
| **Subtotal** | **69** | **2,412 bytes** |
