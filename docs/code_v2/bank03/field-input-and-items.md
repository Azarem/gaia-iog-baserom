# Category 1 — Field Input, Items & Inventory

> The player-facing interaction layer of bank `$03`: the top-level field button
> gate, the Y-button item-use dispatcher and its 41 handlers, inventory slot
> management, and the player-facing-direction helper.
>
> Part of Bank `$03` — see the [bank index](index.md). All addresses are
> hexadecimal (bank byte `$03`).

## Parts in this category

| Part | Range | Source |
|------|-------|--------|
| GlobalInputHandler | `$038000`–`$0380BF` | [GlobalInputHandler.asm](../../../extracted/system/engine/GlobalInputHandler.asm) |
| item_use_system | `$038410`–`$03A0AA` | [item_use_system.asm](../../../extracted/system/engine/item_use_system.asm) |
| inventory_mgmt | `$03EF97`–`$03F0CA` | [inventory_mgmt.asm](../../../extracted/system/inventory/inventory_mgmt.asm) |
| GetPlayerFacingDirection | `$03F0CA`–`$03F1D0` | [GetPlayerFacingDirection.asm](../../../extracted/system/engine/GetPlayerFacingDirection.asm) |

## Overview

This category covers what happens when the player presses a UI button on the
field. `GlobalInputHandler` is the single entry point called once per frame by the
`system_core` main loop; it gates on game state, then routes **Start** to the
radar/map overlay ([Category 2](radar-and-world-map.md)), **Select** to the
inventory screen, and **Y** to `item_use_system`. The item system reads the
equipped slot, dispatches through a 64-entry table to one of 41 item handlers, and
runs a shared epilogue. `inventory_mgmt` provides the slot bookkeeping that item
handlers use to give/remove items, and `GetPlayerFacingDirection` is a small
orientation helper for interaction logic.

---

## GlobalInputHandler — `$038000`–`$0380BF`

Source: [GlobalInputHandler.asm](../../../extracted/system/engine/GlobalInputHandler.asm)

### Purpose

Per-frame UI input dispatcher, called from `system_core` between warp/chest checks
and actor execution. Five guard conditions suppress all UI input before dispatch:

1. `sceneNext` nonzero — a scene transition is pending.
2. `playerFlags` bit 9 (`$0200`) — game-over sequence active.
3. `IsMusicPlaying` returns carry set — a melody item is playing (SPC transfer).
4. `playerFlags` bits 13|11 (`$2800`) — running or ability active (blocks Select
   and Y but **not** Start).
5. No recognized button pressed.

Button dispatch: **Start** (`$1000`) → map/radar (normal radar overlay, or a
dimmed `PAUSE` text overlay when the input-lock flag `$0008` is set); **Select**
(`$2000`) → `OpenInventoryScreen`; **Y** (`$4000`) → `ItemUseDispatch`. Start is
checked before the run/ability guard, so the map is accessible while running.

### Entry points & callers

- `$038000` — `GlobalInputHandler`: single entry. Called via `JSL` from
  `system_core` main loop, between warp/chest checks and actor execution.

### Key internal labels

| Address | Label | Purpose |
|---------|-------|---------|
| `$038000` | `GlobalInputHandler` | entry: PHP, guard checks, button priority dispatch |
| `$038039` | *(exit)* | guard-fail path: `PLP` / `RTL` |
| `$03803B` | *(Select path)* | mark Select consumed → `VBlankWait` → `OpenInventoryScreen` → mark Select+L consumed |
| `$038055` | *(Start path)* | mark Start consumed → check input-lock bit → branch to radar or pause |
| `$03806D` | *(pause overlay)* | input-locked: `COP RunBg3Script` for PAUSE text → dim to `INIDISP $09` |
| `$03808B` | *(hold-to-view init)* | push border animation index X=0 |
| `$03808F` | *(hold-to-view loop)* | `EnableNmiAndJoypad` → `VBlankWait` → `EnableNmiOnly` → `RadarBorderAnimate` → poll Start |

### Cross-references out

| Type | Target | Context |
|------|--------|---------|
| `JSR` | `radar_map_screen.RadarScreenSetup` | normal-mode radar minimap |
| `JSR` | `radar_map_screen.RadarBorderAnimate` | hold-to-view loop border cycling |
| `JMP` | `item_use_system.ItemUseDispatch` | Y button → item use (no return push) |
| `JSL` | `music_actors.IsMusicPlaying` | guard: melody playing check |
| `JSL` | `vblank_joypad.VBlankWaitAndJoypad` | sync to VBlank with joypad |
| `JSL` | `vblank_joypad.EnableNmiAndJoypad` | hold loop NMI setup |
| `JSL` | `vblank_joypad.EnableNmiOnly` | restore NMI-only after joypad read |
| `JSL` | `inventory_overlay.OpenInventoryScreen` | Select → full inventory UI |
| `JSL` | `vram_buffer_clear.ClearVramBufferPartial` | overlay teardown |
| `JSL` | `system_core.UpdateFrameDialogue` | restore normal display after radar |
| `COP` | `RunBg3Script(consolestring_01EAC6)` | PAUSE text overlay (input-locked mode) |

### Notes

**Pause overlay:** When `playerFlags` bit 3 (`$0008`, input lock) is set, Start
displays a simple "PAUSE" text via `COP RunBg3Script` targeting
`consolestring_01EAC6`, rather than the full radar minimap. Before showing the
text, `displayModeFlags` bit 15 (`$8000`) is cleared. The screen brightness is
dimmed to `INIDISP = $09` (9/15). On release, `INIDISP` is restored to `$0F`.

**Input consumption (TSB pattern):** Each button handler uses `LDA #$xxxx` /
`TSB $joypadHeld` to set the button bit in the held-buttons register. This
prevents the same button press from being recognized again on the next frame.
Start uses `$1000`, Select uses `$2000`, and on inventory return, Select+L
(`$6000`) are both suppressed to prevent immediate re-trigger.

**JMP to ItemUseDispatch:** The Y-button path uses `JMP` (not `JSL`), so
`GlobalInputHandler` does not push a return address. The stacked `PHP` from entry
is consumed by `ItemUseEpilogue`, which ends with `PLP` / `RTL` — returning
directly to `system_core`.

---

## item_use_system — `$038410`–`$03A0AA`

Source: [item_use_system.asm](../../../extracted/system/engine/item_use_system.asm)

### Purpose

The complete inventory item-usage pipeline. `ItemUseDispatch` reads the equipped
slot index, extracts the 6-bit item ID (`$00`–`$3F`), and dispatches through a
64-entry jump table to the matching handler. Every handler ends in `RTS`, which
returns into `ItemUseEpilogue` via a stacked-return `PEA` trick (the dispatcher
pushes `epilogue-1` before jumping); the epilogue runs a dialogue-frame update and
suppresses Start re-entry.

### Handler families

1. **Display-only** — print a description, no gameplay effect (story items:
   Lance Letter, Lilly Necklace, Will, Crystal Ring, Prize Money, Black Glasses,
   Bill & Lola Letter, Father's Journal).
2. **Scene-gated key/placement items** — check `sceneCurrent` for the target
   location, verify player tile position via `BranchIfPlayerInAbsTiles`, then
   activate (remove item, set event flag, optionally edit tilemap); print a
   failure message otherwise. (Prison/Elevator/Mine A-B/Seaside Palace keys;
   Diamond Block, Inca Statues A/B, Crystal Ball, Purification Stone, Statue of
   Hope, Rama Statue, Magic Powder, Teapot; Smoked Meat, Mushroom Water, Gorgon
   Flower.)
3. **Melody items** — Wind, Lola's, Memory melodies share
   `FluteMusicActorController` (melody index `$20` = 0/1/2). Requires Will
   (form 0).
4. **Dialogue-option items** — Herb (yes/no heal), Journal (3 topics), Hieroglyph
   Plates (6-slot swap puzzle).

### Shared helpers

- `RemoveEquippedItem` — clears the equipped slot byte, resets
  `inventoryEquippedType` to 0, sets `inventoryEquippedIndex` to `$FFFF`.
- `FluteMusicActorController` — multi-phase actor: suppress input → spawn SPC
  transfer actors → static player pose → poll music completion → `SwitchCase` to
  the melody-specific `*_Effect` handler → restore BGM.
- `SetPlayerTransition` — sets the player actor function pointer and clears its
  frame timer (used by melody handlers and `UseItem_Aura`).

### Special mechanics

- **Red Jewel** — BCD (`SED`/`CLD`) jewel counter; spawns an orbit VFX expanding
  from diameter 1→255 via `ApplyOrbitalOffsetFromRef`.
- **Hieroglyph Plates** — items `$1E`–`$23` share one handler (plate ID =
  item − `$1E`); six word slots at `$0B28` (`$FFFF` = empty); placing into an
  occupied slot swaps the old plate back via `GiveItemToPlayer`.
- **Aura** — shadow form (2) only, requires stationary player with no active
  dialogue/cutscene; overrides the player function pointer to `code_00C557`.
- **Gorgon Flower** — three petal flags (`$BF`/`$C0`/`$C1`); item removed only
  when all three are set.

### Relevant WRAM

| Address | Meaning |
|---------|---------|
| `$0AA6` | current hieroglyph plate ID (item − `$1E`) / garden-crash game flag |
| `$0AAC` | hieroglyph slot selection (0–5) |
| `$0AB0` | `jewelsCollected` — BCD jewel counter (SED/CLD arithmetic) |
| `$0AB4` | `inventorySlots` — 16 item bytes (shared with inventory_mgmt) |
| `$0AC4` | `inventoryEquippedIndex` — equipped slot index (`$FFFF` = none) |
| `$0AC6` | `inventoryEquippedType` — equipped item type ID |
| `$0AD4` | `characterForm` — current player form (0=Will, 1=Freedan, 2=Shadow) |
| `$0B22` | `damageFlashTimer` — screen flash timer (set by stat-up items) |
| `$0B28` | hieroglyph slot table (6 words; `$FFFF` = empty) |
| `$0BF`–`$0C1` | petal flags (Gorgon Flower: 3 flag bytes at `$BF`/`$C0`/`$C1`) |

### Dispatch table & handler map

The **`ItemHandlerJumpTable`** at `$03843F` contains 64 word entries (128 bytes).
Items `$00`–`$28` point to individual handlers; `$29`–`$3F` all point to
`UseItem_Unused` (a single `RTS`). Items `$1E`–`$23` (Hieroglyph Plates) share
`UseItem_HieroglyphPlate`.

| ID | Handler | Address | Category | Notes |
|----|---------|---------|----------|-------|
| `$00` | `UseItem_None` | `$0384BF` | — | nothing equipped; prints generic message |
| `$01` | `UseItem_RedJewel` | `$0384D5` | collect | BCD counter; orbit VFX `ApplyOrbitalOffsetFromRef` |
| `$02` | `UseItem_PrisonKey` | `$0385C2` | scene-key | Edward's Prison scene gate |
| `$03` | `UseItem_IncaStatueA` | `$038691` | scene-key | Inca Ruins statue A placement |
| `$04` | `UseItem_IncaStatueB` | `$0387A7` | scene-key | Inca Ruins statue B placement |
| `$05` | `UseItem_IncanMelody` | `$03881D` | melody | Incan melody via `FluteMusicActorController` |
| `$06` | `UseItem_Herb` | `$03888A` | dialogue | yes/no heal (restores HP to max) |
| `$07` | `UseItem_DiamondBlock` | `$038917` | scene-key | Diamond Mine block placement |
| `$08` | `UseItem_WindFlute` | `$03899A` | melody | Wind melody (index 0); requires Will form |
| `$09` | `UseItem_LolaMelody` | `$038BA4` | melody | Lola's melody (index 1) |
| `$0A` | `UseItem_SmokedMeat` | `$038D67` | scene-key | Seaside cave gated placement |
| `$0B` | `UseItem_MineKeyA` | `$038E15` | scene-key | Mine Key A door unlock |
| `$0C` | `UseItem_MineKeyB` | `$038E96` | scene-key | Mine Key B door unlock |
| `$0D` | `UseItem_MemoryMelody` | `$038F17` | melody | Memory melody (index 2) |
| `$0E` | `UseItem_CrystalBall` | `$038FF3` | scene-key | Crystal Ball pedestal placement |
| `$0F` | `UseItem_ElevatorKey` | `$0390CE` | scene-key | Elevator unlock |
| `$10` | `UseItem_SeasidePalaceKey` | `$039144` | scene-key | Seaside Palace door |
| `$11` | `UseItem_PurificationStone` | `$03921A` | scene-key | Purification Stone placement |
| `$12` | `UseItem_StatueOfHope` | `$039299` | scene-key | Statue of Hope placement |
| `$13` | `UseItem_RamaStatue` | `$03932B` | scene-key | Rama Statue placement |
| `$14` | `UseItem_MagicPowder` | `$0393A1` | scene-key | Magic Powder application |
| `$15` | `UseItem_Journal` | `$039427` | dialogue | 3-topic dialogue selection |
| `$16` | `UseItem_LanceLetter` | `$03950C` | display | story text only |
| `$17` | `UseItem_LillyNecklace` | `$03966A` | display | story text only |
| `$18` | `UseItem_Will` | `$039691` | display | story text (long) |
| `$19` | `UseItem_Teapot` | `$03983D` | scene-key | Teapot application |
| `$1A` | `UseItem_MushroomWater` | `$0398B2` | scene-key | Mushroom Drops placement |
| `$1B` | `UseItem_PrizeMoney` | `$03995C` | display | story text only |
| `$1C` | `UseItem_BlackGlasses` | `$03997F` | display | story text only |
| `$1D` | `UseItem_GorgonFlower` | `$0399CD` | scene-key | 3 petals (`$BF`/`$C0`/`$C1`); removed when all set |
| `$1E`–`$23` | `UseItem_HieroglyphPlate` | `$039AA0` | puzzle | 6 shared entries; plate ID = item − `$1E` |
| `$24` | `UseItem_Aura` | `$039CAF` | ability | Shadow form only; overrides player to `code_00C557` |
| `$25` | `UseItem_BillLolaLetter` | `$039D09` | display | story text only |
| `$26` | `UseItem_FatherJournal` | `$039E15` | display | story text (long) |
| `$27` | `UseItem_CrystalRing` | `$039F30` | display | story text only |
| `$28` | `UseItem_Apple` | `$039F5D` | collect | consumable fruit |
| `$29`–`$3F` | `UseItem_Unused` | `$039FB1` | — | single `RTS` (17 unused slots) |

**Utility routines (end of unit):**

| Address | Label | Purpose |
|---------|-------|---------|
| `$039FB2` | `RemoveEquippedItem` | clear equipped slot, reset `inventoryEquippedType` to 0, set `inventoryEquippedIndex` to `$FFFF` |
| `$039FCA` | `FluteMusicActorController` | multi-phase melody actor: suppress input → SPC transfer → static pose → poll completion → `SwitchCase` → melody effect → restore BGM |
| `$03A0A0` | `SetPlayerTransition` | set player actor's function pointer and clear its frame timer |

### Cross-references

- **In:** `JMP` from `GlobalInputHandler` (Y button). The `JMP` transfers control
  without a return address; the stacked `PHP` from `GlobalInputHandler` is
  consumed by `ItemUseEpilogue` (`PLP` / `RTL`).
- **Out (frequent):**
  - `inventory_mgmt.GiveItemToPlayer` — plate swap returns displaced plate
  - `inventory_mgmt.RemoveItemFromInventory` — used by scene-key handlers after placement
  - `music_actors.IsMusicPlaying` — melody handlers poll SPC completion
  - `system_core.UpdateFrameDialogue` — epilogue and dialogue-frame handlers
  - `ApplyOrbitalOffsetFromRef` — Red Jewel orbit VFX
  - `BranchIfPlayerInAbsTiles` — scene-gated item position checks
  - COP commands: `RunBg3Script`, `SpawnThinker`, `PlaySoundCh1`/`Ch2`,
    `QueueMapChange`, `SwitchCase`

### Notes

**PEA epilogue mechanism:** `ItemUseDispatch` at `$038410` pushes `ItemUseEpilogue−1`
(`$03842E`) onto the stack before dispatching through the jump table. Each handler
ends in `RTS`, which pops this address and jumps to `ItemUseEpilogue` (`$03842F`).
The epilogue calls `UpdateFrameDialogue` (one frame of UI processing), re-suppresses
Start (`$4000` via TSB), then `PLP` / `RTL` returns to `system_core`. The `−1` on
the `PEA` is necessary because `RTS` adds 1 to the popped address.

**String-data embedding:** Many handlers embed inline dialogue strings directly
after COP commands. The assembler handles this via COP operand encoding — the
dialogue data follows the COP instruction and is consumed by the COP handler,
with execution resuming after the embedded data.

**Melody item architecture:** `UseItem_WindFlute`, `UseItem_LolaMelody`, and
`UseItem_MemoryMelody` all share `FluteMusicActorController` (`$039FCA`). This
multi-phase actor: (1) masks joypad to suppress UI, (2) spawns SPC music transfer
actors, (3) holds a static player pose, (4) polls `IsMusicPlaying` until the melody
finishes, (5) dispatches via `SwitchCase` to the melody-specific effect handler
(`_Effect`), then (6) restores the previous BGM. Each melody handler sets the
melody index via `LDA #$20` with bits selecting 0/1/2.

**Hieroglyph plate puzzle:** Items `$1E`–`$23` share a single handler
`UseItem_HieroglyphPlate` (`$039AA0`). The plate ID is computed as `item − $1E`.
The detail handler at `$039AAD` manages a 6-slot word table at `$0B28` where each
slot is either a plate ID or `$FFFF` (empty). Placing a plate into an occupied slot
swaps the old plate back to inventory via `GiveItemToPlayer`.

---

## inventory_mgmt — `$03EF97`–`$03F0CA`

Source: [inventory_mgmt.asm](../../../extracted/system/inventory/inventory_mgmt.asm)

### Purpose

Inventory slot management. `GiveItemToPlayer` scans the 16-slot inventory
(`inventorySlots` at `$0AB4`) for the first empty slot and stores the item ID, or
takes the "inventory full" path. A high-bit (`$80`) input selects a special insert
path (`SBC #$80`). Referenced by item handlers (e.g., Hieroglyph plate swap
returns the displaced plate here).

### Relevant WRAM

| Address | Symbol | Meaning |
|---------|--------|---------|
| `$0AB4` | `inventorySlots` | 16 item slots |
| `$0AC4` | `inventoryEquippedIndex` | equipped slot index (`$FFFF` = none) |
| `$0AC6` | `inventoryEquippedType` | equipped item type |
| `$0ACA` | `playerMaxHp` | max HP (capped at `$55`) |
| `$0ACE` | `playerHp` | current HP |
| `$0AD6` | `gemCount` | gem count (capped at 999 / `$03E7`) |
| `$0ADC` | `playerDef` | defense stat (capped at `$55`) |
| `$0ADE` | `playerStr` | strength stat (capped at `$55`) |
| `$0B22` | `damageFlashTimer` | damage/heal flash timer |

### Key routines

| Address | Label | Role |
|---------|-------|------|
| `$03EF97` | `GiveItemToPlayer` | main entry: dispatch by high bit (`$80`) for items vs. stat-ups |
| `$03F051` | `GiveItem_DefUp` | special input `$82`: defense +1 |
| `$03F070` | `GiveItem_StoreInSlot` | store item byte in first empty `inventorySlots` entry |
| `$03F07D` | `GiveItem_Success` | return carry clear (item given successfully) |
| `$03F080` | `GiveItem_InventoryFull` | inventory full: load overflow dialogue, return carry set |
| `$03F08D` | `RemoveItemFromInventory` | scan 16 slots for matching item, zero it, reset equipped |
| `$03F0B3` | `CheckInventoryForItem` | scan 16 slots; carry clear = found, carry set = not found |

### `$80` special-insert semantics

When the input to `GiveItemToPlayer` has bit 7 set (`$80`), the high bit is
stripped (`SBC #$80`) and the value selects a stat/reward path:

| Input | Effective value | Action |
|-------|-----------------|--------|
| `$80` | 0 | HP Up: `playerMaxHp += 1` (cap `$55`), heal flash, sound #25 |
| `$81` | 1 | STR Up: `playerStr += 1` (cap `$55`), heal flash, sound #25 |
| `$82` | 2 | DEF Up: `playerDef += 1` (cap `$55`), heal flash, sound #25 |
| `$83` | 3 | Gem +1: `gemCount += 1` (cap 999), sound #22 |
| `$84` | 4 | Gem +2: `gemCount += 2` (cap 999), sound #22 |
| `$85` | 5 | Gem +5: `gemCount += 5` (cap 999), sound #22 |
| `$86+` | 6+ | Damage flash: `damageFlashTimer += 5`, spawn `SpawnHitSparkSprites`, sound #22 |

For HP/STR/DEF ups, `displayModeFlags` bit 7 (`$0080`) is cleared before the stat
write, enabling the HUD update on the next frame.

### Notes

**Item name rendering:** `GiveItem_StoreInSlot` stores the item ID into `$0DB8`
(item display register) and loads a dialogue string pointer from
`itemget_table_01FD24.dialogstring_01FF1F` for the "got item" message.
`GiveItem_InventoryFull` uses `dialogstring_01FF02` for the "can't carry" message.
Both dialogue strings are rendered by the `ConsoleStringRenderer` system, which
shares the same BG3 tile engine used for menu text.

**RemoveItemFromInventory:** After zeroing the matching slot, unconditionally resets
`inventoryEquippedType` to 0 and `inventoryEquippedIndex` to `$FFFF` (−1). This
means removing any item also un-equips the currently equipped item, regardless of
whether the removed item was the equipped one.

---

## GetPlayerFacingDirection — `$03F0CA`–`$03F1D0`

Source: [GetPlayerFacingDirection.asm](../../../extracted/system/engine/GetPlayerFacingDirection.asm)

### Purpose

Resolves the player actor's current facing direction. Reads the player's
animation/direction field (`$0028,X`) indexed into `FacingDirectionLookup`. Returns
**carry clear** for the four cardinal directions (result `< $04`), **carry set**
otherwise. Preserves the caller's X via `TXY`/`TYX`. `GetPlayerFacing_AltEntry`
provides an alternate entry that pulls its return context off the stack.

### Key routines

| Address | Label | Role |
|---------|-------|------|
| `$03F0CA` | `GetPlayerFacingDirection` | main entry: save X via TXY, load player actor, check visibility |
| `$03F0EE` | `GetPlayerFacing_AltEntry` | alternate entry: `PLY` (discard return), branch to direction lookup |
| `$03F11F` | `FacingDirectionLookup` | 88-byte table mapping animation frame → direction (0–3 cardinal, 4+ = non-cardinal) |
| `$03F177` | `FacingFormOffsetTable` | 4-entry word table: per-form offsets into form-specific facing data |
| `$03F17F` | `FacingData_Will` | 27 bytes — Will's frame→direction map (4 directions × poses + extras) |
| `$03F19A` | `FacingData_Freedan` | 44 bytes — Freedan's map (all zeros = always direction 0) |
| `$03F1C6` | `FacingData_Shadow_A` | 4 bytes — Shadow form A (all zeros) |
| `$03F1CA` | `FacingData_Shadow_B` | 6 bytes — Shadow form B (all zeros) |

### Return convention

- **Carry clear** — direction `< 4` (one of the four cardinals: 0=down, 1=right,
  2=up, 3=left). The direction value is in A.
- **Carry set** — direction `≥ 4` (diagonal or non-cardinal animation frame). The
  caller should treat this as "facing unknown."

### Cross-references

- **In:** `combat_collision.CalcKnockbackDirection` (player fallback),
  `item_use_system` scene-gated handlers (facing checks for item placement),
  various COP interaction scripts.
- Reads `playerActor` (`$09AA`), `playerFlags` (`$09AE`), `$0028,X`
  (animation/direction field), `$0AC8` (form sub-index).

### Notes

**BMI player-hidden branch:** The main entry reads `playerFlags` and checks the
sign bit (`BMI` at `$03F0D4`). If negative (bit 15 set = player actor hidden), the
code enters the alternate form-aware path at `$03F0F1` instead of the simple
lookup. This path reads `$0AC8` (form index), subtracts 4, and if the result is
negative, falls through to `GetPlayerFacing_AltEntry`. Otherwise it uses
`FacingFormOffsetTable` to compute a form-specific offset, adding the player's
current animation frame to get an index into the form's facing data table.

**FacingDirectionLookup contents:** 88 bytes mapping raw animation frame indices
to cardinal directions. Values 0/1/2/3 correspond to down/right/up/left. Value 4
indicates a non-cardinal or transitional frame. The table is structured as
repeating 4-byte groups (one group per animation set), with the pattern
`00 01 02 03` appearing frequently for standard 4-direction walk cycles.

**Form-specific tables:** Freedan and both Shadow forms have all-zero facing data,
meaning they always report direction 0 (down) via the form-aware path. Only Will
has a meaningful per-pose direction mapping, reflecting his wider animation variety
(walking, running, ability poses).

---

## Category-wide notes

**Button bit constants:**

| Bit | Mask | Button |
|-----|------|--------|
| 12 | `$1000` | Start |
| 13 | `$2000` | Select |
| 14 | `$4000` | Y |
| 15 | `$8000` | B (attack/dodge) |
| 13+14 | `$6000` | Select + L (consumed together after inventory) |

**Input-consume convention:** All button handlers use `LDA #$mask` / `TSB $joypadHeld`
to mark the triggering button as consumed. This prevents the button press from
being re-recognized on subsequent frames while the button remains physically held.
Additionally, `ItemUseDispatch` suppresses Start (`$4000` → `joypadHeld`) to prevent
the map/radar from opening during item-use processing.

**Handler address verification:** All 41 handler addresses in the dispatch table above
have been verified against the current `names.json` and cross-checked against the
extracted source `item_use_system.asm`. The jump table at `$03843F` is a contiguous
64-entry word array with entries `$29`–`$3F` all pointing to `UseItem_Unused` at
`$039FB1`.
