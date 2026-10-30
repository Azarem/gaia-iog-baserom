# Inventory Menu — `inventory_menu.asm`

*Part of the [Bank $02 Documentation Suite](README.md)*

> The `InventoryMenuDef` actor and its child actors: a four-tab menu (tab index `inventoryTabIndex` 0–3) over a 16-slot item grid, run inside the overlay loop described in [inventory-overlay.md](inventory-overlay.md).

**Source:** [`inventory_menu.asm`](../../../extracted/system/inventory/inventory_menu.asm) (ROM `$02E396`–`$02ED02`, decimal 189334–191746; the next block, `inventory_overlay`, starts at `$02ED02`)

**Evidence labels.** Each major section is tagged with the kind of claim it makes: **[ASM]** = directly observed in the extracted asm of this block; **[INFERRED]** = interpretation of behavior that is not literally encoded in the file; **[XREF]** = cross-file / engine-wide convention stated elsewhere (not provable from this file alone). Sections that mix kinds split them into separately tagged bullets or paragraphs. The `.asm` files in `extracted/` are authoritative; where prose and asm comments disagree, the asm wins.

> **This baserom's input values.** The extracted asm already contains the values after `db-us/transforms.json` rewrote the `inventory_menu` block (`#$4040`→`#$4000`, `#$6040, &TabCancel`→`#$6000`, `#$C040`→`#$C000`, `#$8000, &ArrangePerformSwap`→`#$8044`, `LDA #$2040`→`LDA #$2060`). Masks written below are the literal values in the asm. The vanilla ROM tests different masks and uses tile `$2040` for the blank cursor cell.

---

## Overview

*Evidence: [ASM]*

- The file holds one actor definition (`InventoryMenuDef`, header `actor-def < #00, #00, #28 >`) with `InventoryMenuInit` and `InventoryMainLoop` inline, jump tables for the per-tab handlers, the tab and cursor routines, the child actors, and helpers.
- `InventoryMenuInit` spawns **16** `InventorySlotActor`s, one `EquipCursorActor`, one `EquippedItemDisplay` and **3** status-row actors (`StatusAbilityRow0/1/2`). It stores their actor addresses in four long-address scratch fields of the menu actor (see *Child actors and list heads*).
- The four tabs, indexed by `inventoryTabIndex` (`$0AFA`): **0** `UseItemTab`, **1** `ArrangeItemsTab`, **2** `DiscardItemTab`, **3** `StatusViewTab`. Each has a hover preview (`TabHover*`, run when the cursor lands on the tab) and an action handler (`*Tab`, run when the confirm bit is pressed on the tab).
- **[ASM]** The Use tab's title string is described by the asm comment as "Gather Items". The asm gives no other tab-title text, so the Arrange / Discard / Status names above are the routine names, not on-screen strings.
- **[ASM]** The menu closes when `TabCancel` executes `COP [SetFlagByte] ( #00 )`; the loop in `OpenInventoryScreen` polls that flag byte ([inventory-overlay.md](inventory-overlay.md) §Run loop). Nothing in this file jumps out of the menu.
- **[ASM]** The mystic-statue pedestals are **not** spawned by this file. The block note says six `inventory_statue_slot` actors are spawned by `SpawnSceneActors` from the scene `$FF` actor list; they test event flags `$F8`–`$FD` and hide themselves while `inventoryTabIndex == 3`. **[XREF]** `inventory_statue_slot.asm` confirms the `inventoryTabIndex` read and the `$2000` hide; flag-setting is in the `statue_inventory_reward` block (bank `$00`).

---

## Buttons and frame model

*Evidence: [ASM] (asm comments) + [XREF] (`transforms.json`, `cop_handlers_input.asm`)*

| Mask in asm | Used for | Where |
|---|---|---|
| `$8000` | confirm bit | tab bar (`TabSelectionLoop`), Arrange source pick, Discard attempt, Yes/No prompt |
| `$4000` | cancel bit | Arrange / Discard grid loops (leave the tab), Arrange target loop |
| `$C000` | confirm **or** cancel | `UseItemTab` (no separate cancel), `StatusViewTab` (A or B leaves) |
| `$6000` | cancel **or** Select | `TabSelectionLoop` → `TabCancel` |
| `$8044` | confirm bit plus the X (`$0004`) and Y (`$0040`) bits of the default remap | `ArrangePickTarget` target loop → `ArrangePerformSwap` (the vanilla ROM tests only `$8000` here) |
| `$0800` / `$0400` / `$0200` / `$0100` | Up / Down / Left / Right | all navigation |

- **[ASM]** `BranchIfPressed` tests `joypadCurrent` (`$0656`): the logical, remapped bits, with consumed bits hidden. The baserom remap defaults give physical A the value `$8080`, B `$4008`, X `$0004`, Y `$0040`, Select `$2000` (asm comment citing `db-us/transforms.json`). So A confirms, B cancels, and X / Y are software-only bits that the menu ignores except for the `$8044` swap mask. The diary menu can rebind the buttons.
- **[ASM]** `TSB joypadHeld` (`$0658`) consumes the given bits until the physical button is released. The code consumes exactly the bit it matched, so consuming `$8000` leaves the `$0080` half of A's value visible (never tested here).
- **[ASM]** D-pad consumption is wider than the direction: Up consumes `$0B00` (Up, Left, Right) and Down consumes `$0700` (Down, Left, Right), so one diagonal press moves one step. Left (`$0200`) and Right (`$0100`) consume only themselves. In the tab bar, Yes/No prompt and Status tab the code consumes only the direction it matched (`$0800` / `$0400`).
- **[XREF]** Held-direction repeat comes from the engine, not from this file: `OpenInventoryScreen` sets `joypadMaskInv` (`$065C`) to `$0F00`, and `vblank_joypad.asm` documents that consumed D-pad bits in that mask repeat in `joypadCurrent` on the 12th call after consumption and every 12 calls while the code keeps consuming them.
- **[ASM]** Frame model: every handler is a COP script that yields with `SetEntryHereAndYield` or `SetEntryHere` + `RTL` and resumes at the saved entry point next frame. An `RTL` is therefore the idle path of a frame, not an exit.
- **[ASM]** `BranchIfPressed` jumps to its target rather than calling it. The `PEA &Loop-1` / `PLA` pattern in the Arrange and Discard loops uses that: the D-pad targets (`GridCursor*`) end in `RTS`, which pops the pushed address and resumes at the loop head; if no button matched, `PLA` discards the pushed address and `RTL` ends the frame.
- **[XREF]** On open, `GlobalInputHandler` consumes Select (`$2000`) in `joypadHeld` before `OpenInventoryScreen`, and `SaveGameState` does not clear `joypadHeld`. **[INFERRED]** So the Select press that opened the inventory does not immediately reach `TabCancel`'s `$6000` test; Select must be released and pressed again.

---

## Shared state

*Evidence: [ASM] for names and addresses; roles are quoted from the block note and routine comments*

| Address | Name in asm | Role |
|---|---|---|
| `$0AB4`–`$0AC3` | `inventorySlots` | 16 bytes, one item ID per slot, `0` = empty, no per-slot flags. Code reads a slot as a 16-bit word and masks it (`AND #$00FF`); the high byte of that word is the **next** slot |
| `$0AC4` | `inventoryEquippedIndex` | slot index of the equipped item, `$FFFF` = nothing equipped |
| `$0AC6` | `inventoryEquippedType` | item type ID of the equipped item |
| `$0AD4` | `characterForm` | `0` = Will, `1` = Freedan, `2` = Shadow (block note) |
| `$0AE6` | `bg1ConfigMode` | BG1SC value; the overlay loop copies it to `BG1SC` every pass. Set to `4` by Use / Discard / hover Use / hover Discard, `0` by Status / hover Status |
| `$0AE8` | `itemAbilityIndex` | set before `RunBg3Script` to select an item or ability description string |
| `$0AFA` | `inventoryTabIndex` | tab index 0–3; also the **spawn counter** of the 16 slot actors during `InventoryMenuInit`'s yield |
| `$0658` | `joypadHeld` | consumption mask (see above) |
| `$09EC` | `displayModeFlags` | bit 0 set by `YesNoClearCursor` / `TabClearCursor` to flag the BG3 tilemap dirty |
| `$7F0200` | `bg3TilemapBuffer` | BG3 tilemap staging; cursor tiles are written at `$7F0200 + offset` |

Menu-actor DP scratch (**[ASM]**, from the routine comments; they are the menu actor's own direct page):

| DP | Use |
|---|---|
| `$10` bit `$1000` | "the 16 item slots are visible" (set by `InventoryMenuInit` and `ShowAllItemSlots`, cleared by `HideAllItemSlots`) |
| `$18` | last tab whose hover preview ran (`$FFFF` at loop start) |
| `$1A` | Use-tab cursor slot / equipped slot copy (negative = none) |
| `$1C` | blink counter for the tab bar and the Yes/No prompt |
| `$20` | actor address of the active `SelectionCursorActor` |
| `$22` | Arrange / Discard grid slot (also Arrange target slot) and Status row 0–2 |
| `$24` | slot-actor spawn loop counter (15 → 0) |
| `$28` | Yes/No selection (`0` = No, `1` = Yes) |
| `$2C` / `$2E` | Arrange: saved source cursor actor / source slot |

Child actors reuse `$28` as their sprite frame and `$2A` as the animation / refresh trigger (`UpdateSlotActorSprite` and `SetSlotSprite` write them).

---

## Child actors and list heads

*Evidence: [ASM]*

`InventoryMenuInit` saves child actor addresses in four long-address scratch fields whose **equate names are borrowed from other actors**, so the names do not describe their role here:

| Equate | Address | Holds | Spawn flags (`SpawnAfterFlags`) |
|---|---|---|---|
| `orbitAngle,X` | `$7F0010` | head of the 16-slot `InventorySlotActor` chain (slot 0) | `#$1800` |
| `orbitDiameter,X` | `$7F0012` | `EquipCursorActor` | `#$0802` |
| `moveXAlt,X` | `$7F0018` | `EquippedItemDisplay` | `#$0800` |
| `moveYAlt,X` | `$7F001A` | head of the three `StatusAbilityRow` actors (`StatusAbilityRow0`, the top row) | `#$0800` |

- **[ASM]** `SpawnAfter` inserts the child directly after the spawner, so the **last** spawned becomes the chain head. The slot loop counts `$24` 15 → 0, so slot 0 is spawned last and heads the chain; the `$0006` links then lead slot 0 → 15. The status rows are spawned Row2, Row1, Row0, so Row0 is the head and its `$0006` links lead to Row1, then Row2.
- **[ASM]** Each slot actor gets its item ID in `$0028,Y` straight after being spawned (`inventorySlots[$24] & $00FF`).
- **[ASM]** After the spawns, `$1A = inventoryEquippedIndex` and `PositionEquipCursor` runs, then `SetEntryHereAndYield`. During that yield each slot actor increments `inventoryTabIndex`; on resume the menu actor resets it to `0` and sets DP `$10` bit `$1000`.
- **[ASM]** The spawn flags all include bit 11 (`$0800`); **[XREF]** `RunActors_CutsceneOnly` (which drives actors while the overlay loop runs `UpdateFrameDialogue`) dispatches only actors with that bit. The meaning of the remaining bits (`$1000`, `$0002`) is not stated in this file.

---

## InventoryMenuInit and InventoryMainLoop

*Evidence: [ASM]*

**`InventoryMenuInit`:** `SetMetasprite ( @inventory_spritemap )`, `RunBg3Script ( consolestring_01E869 )`, `inventoryTabIndex = 0`, `$24 = $000F`, the 16-slot spawn loop, `EquipCursorActor`, `$1A` ← `inventoryEquippedIndex`, `PositionEquipCursor`, `EquippedItemDisplay`, the three status rows, `SetEntryHereAndYield`, `inventoryTabIndex = 0`, `$10 |= $1000`. It then falls into `InventoryMainLoop`.

**`InventoryMainLoop`:** `RunBg3Script ( consolestring_01E90B )` and `( consolestring_01E8E9 )`, `$1C = 0`, `$18 = $FFFF` (so the first pass always runs a hover preview), `TSB joypadHeld` with `$8000` (a held A cannot re-confirm a tab on return), `SetEntryHereAndYield`, then each frame:

1. `JSR TabSelectionLoop`.
2. Carry set (confirm) → branch to `TabConfirmDispatch`.
3. Otherwise compare `inventoryTabIndex` with `$18`. Equal: `RTL` (end of this frame's turn, not a menu exit). Different: store it in `$18` and `$0000` and `COP [SwitchCase] ( #$0000, &TabHoverDispatch )`.

**`TabConfirmDispatch`:** `PlaySoundCh2 ( #0D )`, tab → `$18` and `$0000`, `SwitchCase` through `TabActionDispatch`. Both dispatch tables hold four word pointers in tab order: `TabHoverDispatch` → `TabHoverUse`, `TabHoverArrange`, `TabHoverDiscard`, `TabHoverStatus`; `TabActionDispatch` → `UseItemTab`, `ArrangeItemsTab`, `DiscardItemTab`, `StatusViewTab`.

Operands such as `#0D`, `#10` are written exactly as the asm prints them (hex bytes).

---

## Tab bar

*Evidence: [ASM]; [INFERRED] where marked*

- **`TabSelectionLoop`** (once per frame; carry set = confirmed). In this order: `$8000` → `TabConfirm`; `$0800` → `TabSelectUp`; `$0400` → `TabSelectDown`; `$6000` → `TabCancel`. Otherwise the blink counter `$1C` is incremented: if its low nibble is nonzero, return with carry clear; if bit 4 is clear call `TabDrawCursor`, else `TabClearCursor`. The cursor therefore toggles every 16 frames.
- **`TabSelectUp` / `TabSelectDown`:** SFX `#10`, consume `$0800` / `$0400`, `$1C = 0`, `inventoryTabIndex ± 1` with `AND #$0003` (wraps 0 ↔ 3), `TabDrawCursor`, carry clear.
- **`TabConfirm`:** consume `$8000`, `TabDrawCursor`, carry set.
- **`TabCancel`:** `SetFlagByte ( #00 )`, carry clear. It does **not** consume the cancel bits, so `InventoryMainLoop` passes through it every frame until the overlay ends.
- **`TabDrawCursor`:** calls `TabClearCursor`, then writes tile `$202B` to `bg3TilemapBuffer + (inventoryTabIndex × $80) + $0584`.
- **`TabClearCursor`:** `displayModeFlags |= $0001`; writes the blank tile (`$2060` in this baserom) to `$7F0784`, `$7F0804`, `$7F0884`, `$7F0904`.
- **[INFERRED]** The offsets are `$80` apart. If BG3 is a 32×32 tilemap with 2-byte entries (`BG3SC = $78` is set in the overlay), that is two tilemap rows per tab, which matches Up / Down moving between tabs. The asm does not state the layout.

---

## Use tab (`UseItemTab`)

*Evidence: [ASM]*

- Entry: `bg1ConfigMode = 4`; BG3 scripts `01E90B`, `01EA02`, `01E975`; `inventoryEquippedIndex = 0` (not `$FFFF`: a non-negative placeholder so `ShowEquipCursor` reveals the cursor; `UseItemConfirm` always overwrites it); `ShowEquipCursor`; a negative `$1A` is clamped to `0`.
- `UseItemRefreshCursor` (loop head): `PositionEquipCursor`; script `01E912`; item ID at slot `$1A` → `itemAbilityIndex`; script `01E9D0`; yield; then `$C000` → `UseItemConfirm`, `$0800` Up, `$0400` Down, `$0200` Left, `$0100` Right. **There is no cancel in this tab**: A or B (`$C000`) both equip.
- Cursor moves: SFX `#10`, consume the matching mask (Up `$0B00`, Down `$0700`, Left `$0200`, Right `$0100`), then `$1A − 4`, `+ 4`, `− 1` or `+ 1`, each followed by `AND #$000F`, then back to `UseItemRefreshCursor` (`UseItemCursorRight` uses `JMP`, the others `BRA`).
- **`UseItemConfirm`:** consume `$C000`, SFX `#11`, `inventoryEquippedIndex = $1A`. If the slot's item byte is `0`: `inventoryEquippedIndex = $1A = $FFFF` and `inventoryEquippedType = 0`. Otherwise `inventoryEquippedType` = the item ID. Both paths `JMP InventoryMainLoop`.

---

## Arrange tab (`ArrangeItemsTab`)

*Evidence: [ASM]*

- **Setup:** `HideEquipCursor`; spawn `SelectionCursorActor` (`#$0802`) → `$20`; `$22 = 0`. `ArrangeSourceReset`: `$1C = 0`; scripts `01E90B`, `01EA14`, `01E98C`.
- **`ArrangeSourceLoop`:** `PositionGridCursor`; yield; `$4000` → `ArrangeCancelTab`; `$8000` → `ArrangePickTarget`; `PEA ArrangeSourceLoop-1`; D-pad → `GridCursor*`; `PLA`; `RTL`.
- **`ArrangePickTarget`:** SFX `#11`; consume `$8000`; save `$20` → `$2C` and `$22` → `$2E`; spawn a second `SelectionCursorActor` → `$20`; scripts `01E90B`, `01EA14`, `01E9A6`. **`ArrangeTargetLoop`:** `$4000` → `ArrangeCancelTarget`; `$8044` → `ArrangePerformSwap`; D-pad as above. The target cursor starts at the source slot (`$22` is unchanged).
- **`ArrangePerformSwap`:**
  1. Consume `$8000`. If `$22 == $2E`, return to `ArrangeTargetLoop` (a swap with itself is ignored).
  2. SFX `#11`; 8-bit swap of `inventorySlots[$22]` and `[$2E]` through `XBA`.
  3. For each of the two slots, `UpdateSlotActorSprite` (which returns **Y = the slot actor**, not the slot index) and `STA $0028,Y` with the new item ID.
  4. Equipped tracking: the first test (`TYA; CMP inventoryEquippedIndex`) compares a slot **actor** address with a slot index and can never match, so the case "the target slot was equipped" is not handled. The second test (the source slot was equipped) works and moves `inventoryEquippedIndex` to `$22`.
  5. `MarkDeath` on the saved source cursor (`$2C`), then `JMP ArrangeSourceReset`.
- **`ArrangeCancelTarget` / `ArrangeCancelTab`:** `ArrangeCancelTarget` is a single `COP [KillNext]` with **no `RTS` / `JMP`**, so it **falls through** into `ArrangeCancelTab`, which executes a second `KillNext`, consumes `$4000` and does `JMP InventoryMainLoop`. **[XREF]** `KillNext` unlinks the immediate next neighbour in the actor list ([`actor_death.md`](../../cop/families/actor_death.md)). Both cursors sit directly after the menu actor (the second one in front), so on the code as written **B in the target phase removes both cursors and returns to the tab bar**. **Discrepancy:** the block note ("B cancels only the target") and the `ArrangeCancelTarget` part note describe a target-only cancel; the code does not do that. Not changed here (asm is the source of truth; a fix would be a patch, not a doc change).

---

## Discard tab (`DiscardItemTab`)

*Evidence: [ASM]*

- **Setup:** `bg1ConfigMode = 4`; `HideEquipCursor`; spawn `SelectionCursorActor` → `$20`; `$22 = 0`. `DiscardGridReset`: `$1C = 0`; scripts `01E90B`, `01EA27`, `01E9B7`.
- **`DiscardGridLoop`:** `PositionGridCursor`; yield; `$4000` → `DiscardCancelTab`; `$8000` → `DiscardAttempt`; D-pad via the same `PEA` pattern.
- **`DiscardAttempt`:** consume `$8000`. Item byte at `$22`: `0` → SFX `#12` and back to `DiscardGridReset`. Otherwise `itemAbilityIndex` = item ID, then `CheckItemDiscardable` (carry set = protected → SFX `#12`). Otherwise scripts `01E912`, `01E9E2` draw the name and the prompt, `$28 = 0` (No), yield, then `JSR YesNoPromptLoop` once per frame; while carry is clear the routine `RTL`s.
  - Answer `$28 = 0` (No): back to `DiscardGridReset`, nothing removed.
  - Answer `$28 = 1` (Yes): `AND #$FF00` on the 16-bit word at `inventorySlots + $22` (clears this slot's byte; the high byte, the next slot, is written back unchanged), `UpdateSlotActorSprite`, and if `$22 == inventoryEquippedIndex` then `inventoryEquippedType = 0`, `inventoryEquippedIndex = $1A = $FFFF`. SFX `#13`, back to `DiscardGridReset`.
- **`DiscardCancelTab`:** consume `$4000`, `KillNext`, `ShowEquipCursor`, `JMP InventoryMainLoop`.
- **`CheckItemDiscardable`:** A = item ID. Byte index = ID >> 3, bit = `BitMaskTable[ID & 7]`, ANDed with `system_strings.non_discardable_item_bits`. Carry set = protected. Preserves X; uses absolute scratch `$0000`. `BitMaskTable` is `$01,$02,$04,$08,$10,$20,$40,$80`.

---

## Status tab (`StatusViewTab`)

*Evidence: [ASM]*

- **Setup:** `bg1ConfigMode = 0`; scripts `01E90B`, `01EA39`; spawn `SelectionCursorActor` → `$20`; `$22 = 0`.
- **Per row (label `loc_02E734`):** `StatusPositionCursor`; script `01E912`; `$0004 = characterForm`; `TestAbilityFlag(A = $22)`; if carry set, `ComputeAbilityIndex` and script `01EAB4`. Then yield and poll: `$0800` → `StatusCursorUp` (consume `$0800`, SFX `#10`, `$22 − 1`, a negative result becomes `2`), `$0400` → `StatusCursorDown` (consume `$0400`, SFX `#10`, `$22 + 1`, `≥ 3` becomes `0`), `$C000` → `StatusConfirmExit` (SFX `#11`, consume `$C000`, `KillNext`, `JMP InventoryMainLoop`).
- **What the three rows are:** ability slots 0–2 of the **current** `characterForm`. Row `r` tests flag `$0510 + characterForm × 4 + r` (asm comment; the same flags as `abilityBitmask` `$0AA2`). The form's fourth ability flag is never listed. The rows are **not** "Will / Freedan / Shadow".
- **`TestAbilityFlag`:** flag index = `$0004 × 4 + A` (the form comes from the absolute word `$0004`, which the caller sets, not from `characterForm` directly); `JSL flag_helpers.TestFlag_0510`; carry set = unlocked.
- **`ComputeAbilityIndex`:** `itemAbilityIndex = characterForm × 4 + slot + 1`; preserves A. The `+ 1` skips entry 0, which the asm comment says is the empty string in `ability_menu_table` / `ability_name_table` and `'Nothing'` in `ability_description_table` (`system_strings`).
- **`StatusPositionCursor`:** `$22 × 4` indexes `StatusCursorPositions` (`$0098,$0048`, `$0098,$0060`, `$0098,$0078`); writes `$0014` / `$0016` of the cursor actor `$20`.
- **Status row actors:** X = `$98`, Y = `$48` / `$60` / `$78`, sprite frame `$28 = characterForm × 3 + $44` (row 0) / `$45` (row 1) / `$46` (row 2), `$2A = 0`, then `SetEntryHere`, `AnimOneFrame`, `RTL`.
- **`EquippedItemDisplay`:** X `$0028`, Y `$0078`; sprite frame `$28 = inventoryEquippedType`; `$2A = 0`; one `AnimOneFrame`.

---

## Tab hover previews

*Evidence: [ASM]*

Each preview runs once when the cursor lands on a tab (and on the first pass, since `$18 = $FFFF`).

| Routine | Slots | Equip cursor | Status actors | `bg1ConfigMode` | BG3 scripts (in order) |
|---|---|---|---|---|---|
| `TabHoverUse` | `ShowAllItemSlots` | `ShowEquipCursor` | `HideStatusActors` | `4` | `01E8E2`, `01E912`, `01E919` |
| `TabHoverArrange` | `ShowAllItemSlots` | `ShowEquipCursor` | not touched | not touched | `01E912`, `01E954` |
| `TabHoverDiscard` | `ShowAllItemSlots` | `ShowEquipCursor` | `HideStatusActors` | `4` | `01E912`, `01E8E2`, `01E962` |
| `TabHoverStatus` | `HideAllItemSlots` | `HideEquipCursor` | see below | `0` | `01E912`, `01E870`, `01EA70`, then per-row scripts |

- **`TabHoverStatus`:** after the scripts and `bg1ConfigMode = 0`, if `inventoryEquippedIndex` is non-negative it sets the `EquippedItemDisplay` sprite (`SetSlotSprite` with `inventoryEquippedType`) and clears `$2000` on that actor. It then walks the three status-row actors from `moveYAlt` through the `$0006` links; for row `r` = 0, 1, 2 it calls `TestAbilityFlag`, and if carry is set clears `$2000` on the row actor, runs `ComputeAbilityIndex` and one script (`01EA49`, `01EA56`, `01EA63` respectively). Locked rows stay hidden.
- **`TabHoverArrange`** does not hide the status actors: its neighbours (Use and Discard) already did (asm comment).
- Hover previews never write `inventoryEquippedIndex`/`Type`, `$1A` or `$22`.

---

## Grid cursors, slot positions and visibility

*Evidence: [ASM]; layout labels [INFERRED]*

**Slot index.** Slot index bits 0–1 = column, bits 2–3 = row (block note), so `index & 3` is the column and `index >> 2` the row.

**`GridCursorUp/Down/Left/Right`** (shared by Arrange and Discard, `$22`; return with `RTS`): Up `$22 − 4`, Down `$22 + 4`, Left `$22 − 1`, Right `$22 + 1`, each `AND #$000F`, SFX `#10`, with the consumption masks listed above. The `UseItemCursor*` handlers do the same on `$1A`.

| Move | From slot 5 | Edge behaviour (**[ASM]** from the masks) |
|---|---|---|
| Up (`− 4`) | 1 | wraps inside its column (`0 → 12`) |
| Down (`+ 4`) | 9 | wraps inside its column (`12 → 0`) |
| Left (`− 1`) | 4 | **does not wrap inside the row**: slot 4 → 3 (previous row, last column); slot 0 → 15 |
| Right (`+ 1`) | 6 | slot 3 → 4 (next row, first column); slot 15 → 0 |

(The block note states this explicitly: "Left/Right do not wrap inside a row".)

**Positions.**

- `GridColumnPositions` (cursor): X `$005C`, `$0074`, `$008C`, `$00A4`, Y base `$0030`.
- `PositionGridCursor`: slot × 4; `AND #$000C` selects the column entry (4 bytes per entry), `AND #$0030` is the row offset (row × `$10`) added to Y. It reads `$22` with cursor actor `$20`; the second entry `loc_02EA46` (`$2E` / `$2C`) has no caller. `PositionEquipCursor` does the same with `$1A` and `orbitDiameter,X`; a negative `$1A` hides the cursor (`ORA #$2000`).
- `SlotPositionTable` (item icons): 16 pairs, X `$005C/$0074/$008C/$00A4`, Y `$0031/$0041/$0051/$0061`. `ComputeSlotPosition`: `(inventoryTabIndex − 1) × 4` indexes it and writes `$14` / `$16`.

**Visibility.** Actor flag bit 13 (`$2000`) in `$10`: set = hidden, clear = visible.

- `HideEquipCursor` / `ShowEquipCursor` set / clear it on the `orbitDiameter` actor (`ShowEquipCursor` branches to `HideEquipCursor` when `inventoryEquippedIndex` is negative).
- `HideStatusActors` sets it on `moveXAlt`, on `moveYAlt` (chain head) and on the next two `$0006` links (four actors).
- `ShowAllItemSlots` returns at once if menu `$10` bit `$1000` is **set**; otherwise it sets the bit and clears `$2000` on the 16 chain actors. `HideAllItemSlots` returns if the bit is **clear**; otherwise it clears the bit and sets `$2000` on all 16.
- `InventorySlotActor`: `INC inventoryTabIndex`, `ComputeSlotPosition`, then `SlotActorEvaluate`: `$28 == 0` → set `$2000` and `RTL`; otherwise clear `$2000` and loop `AnimOneFrame` until `$2A` is nonzero. `UpdateSlotActorSprite(A = slot)` walks the chain from `orbitAngle` with `$000E` as counter, resets the actor's entry (`$0000`) to `SlotActorEvaluate` and zeroes `$0028`, `$0008`, `$002A`; it returns **Y = that slot actor**.
- `EquipCursorActor`: if `inventoryEquippedIndex` is negative sets `$2000`, then falls into `SelectionCursorActor` (`StageSprAndHitbox ( #40 )`, `SetEntryHereAndYield`, `SetEntryHere` + `AnimOneFrame` until `$2A` is nonzero).
- **[INFERRED]** "Item grid / list mode" and "status view" are descriptive labels for the two visibility states of `$10` bit `$1000`; the asm names only the bit and the hide / show routines.

---

## Yes/No prompt

*Evidence: [ASM]*

- **`YesNoPromptLoop`** (once per frame; carry set = answered): `$8000` → `YesNoConfirm` (B does not cancel); `$0800` → `YesNoSelectUp`; `$0400` → `YesNoSelectDown`; otherwise the `$1C` blink as in the tab bar (`YesNoDrawCursor` / `YesNoClearCursor`), carry clear.
- **`YesNoSelectUp` / `Down`:** SFX `#10`, consume `$0800` / `$0400`, `$28 ± 1` with `AND #$0001` (so both directions toggle 0 ↔ 1), `$1C = 0`, `YesNoDrawCursor`, carry clear. **`YesNoConfirm`:** consume `$8000`, `YesNoDrawCursor`, carry set.
- **`YesNoDrawCursor`:** `YesNoClearCursor`, then writes tile `$202B` to `bg3TilemapBuffer + ($28 × $80) + $0696`.
- **`YesNoClearCursor`:** `displayModeFlags |= $0001`; blank tile (`$2060` here) to `$7F0896` (No cell) and `$7F0916` (Yes cell).

---

## Memory map

*Evidence: [ASM] (addresses from `db-us/names/bank02.json`)*

| Address | Name | Role |
|---|---|---|
| `$02E396` | `InventoryMenuDef` | actor-def header `#00, #00, #28`; contains the init and main loop |
| `$02E399` | `InventoryMenuInit` | spawns the child actors (above) |
| `$02E40C` | `InventoryMainLoop` | tab-bar frame loop |
| `$02E43D` | `TabHoverDispatch` | 4 word pointers |
| `$02E445` | `TabConfirmDispatch` | SFX `#0D`, dispatch by tab |
| `$02E456` | `TabActionDispatch` | 4 word pointers |
| `$02E45E` | `UseItemTab` | Use tab entry |
| `$02E47F` | `UseItemRefreshCursor` | Use-tab loop head |
| `$02E4B8` / `$02E4CE` / `$02E4E4` / `$02E4F7` | `UseItemCursorUp` / `Down` / `Left` / `Right` | `$1A` moves |
| `$02E50B` | `UseItemConfirm` | writes the equipped index and type |
| `$02E536` | `ArrangeItemsTab` | setup |
| `$02E544` | `ArrangeSourceReset` | redraw / reset |
| `$02E555` | `ArrangeSourceLoop` | source-slot poll |
| `$02E583` | `ArrangePickTarget` | save source, spawn second cursor |
| `$02E5AC` | `ArrangeTargetLoop` | target-slot poll |
| `$02E5DA` | `ArrangePerformSwap` | the swap |
| `$02E64A` | `ArrangeCancelTarget` | `KillNext`, falls through |
| `$02E64C` | `ArrangeCancelTab` | `KillNext`, consume `$4000`, back to the tab bar |
| `$02E657` | `DiscardItemTab` | setup |
| `$02E66B` | `DiscardGridReset` | redraw / reset |
| `$02E67C` | `DiscardGridLoop` | grid poll |
| `$02E6AA` | `DiscardAttempt` | validation, prompt, discard |
| `$02E70B` | `DiscardCancelTab` | leave the tab |
| `$02E719` | `StatusViewTab` | Status tab |
| `$02E768` / `$02E77D` | `StatusCursorUp` / `Down` | row `$22` |
| `$02E795` | `StatusConfirmExit` | leave the tab |
| `$02E7A3` | `StatusPositionCursor` | cursor placement |
| `$02E7BB` | `StatusCursorPositions` | 3 X/Y pairs |
| `$02E7C7` / `$02E7E6` / `$02E7F7` / `$02E816` | `TabHoverUse` / `Arrange` / `Discard` / `Status` | previews |
| `$02E8C7` | `InventorySlotActor` | item slot sprite actor |
| `$02E8CD` | `SlotActorEvaluate` | per-frame entry of the slot actor |
| `$02E8E7` | `EquipCursorActor` | hides itself if nothing equipped |
| `$02E8F1` | `SelectionCursorActor` | sprite `#40` loop |
| `$02E8FF` | `EquippedItemDisplay` | X `$28`, Y `$78` |
| `$02E915` / `$02E934` / `$02E953` | `StatusAbilityRow0` / `1` / `2` | Y `$48` / `$60` / `$78` |
| `$02E972` | `ComputeAbilityIndex` | `form × 4 + slot + 1` |
| `$02E981` / `$02E996` / `$02E9AB` / `$02E9BD` | `GridCursorUp` / `Down` / `Left` / `Right` | `$22` moves |
| `$02E9CF` | `SetSlotSprite` | `A → $28,Y`; zero `$2A,Y` and `$08,Y` |
| `$02E9DC` | `TestAbilityFlag` | carry = unlocked |
| `$02E9ED` | `UpdateSlotActorSprite` | reset one slot actor; returns Y = actor |
| `$02EA13` | `CheckItemDiscardable` | carry = protected |
| `$02EA35` | `BitMaskTable` | 8 single-bit masks |
| `$02EA3D` | `PositionGridCursor` | from `$22` |
| `$02EA73` | `PositionEquipCursor` | from `$1A` |
| `$02EAB0` | `GridColumnPositions` | 4 X/Y pairs |
| `$02EAC0` | `HideStatusActors` | 4 actors |
| `$02EAF7` / `$02EB0B` | `ShowEquipCursor` / `HideEquipCursor` | `$2000` clear / set |
| `$02EB1A` / `$02EB45` | `ShowAllItemSlots` / `HideAllItemSlots` | guarded by `$10` bit `$1000` |
| `$02EB70` | `ComputeSlotPosition` | from `inventoryTabIndex − 1` |
| `$02EB86` | `SlotPositionTable` | 16 X/Y pairs |
| `$02EBC6` | `YesNoPromptLoop` | prompt poll |
| `$02EBF2` / `$02EC0A` / `$02EC22` | `YesNoSelectUp` / `Down` / `Confirm` | |
| `$02EC2D` / `$02EC46` | `YesNoDrawCursor` / `YesNoClearCursor` | |
| `$02EC58` | `TabSelectionLoop` | tab-bar poll |
| `$02EC8A` / `$02ECA4` | `TabSelectUp` / `Down` | |
| `$02ECBE` | `TabCancel` | `SetFlagByte ( #00 )` |
| `$02ECC3` | `TabConfirm` | |
| `$02ECCE` / `$02ECE8` | `TabDrawCursor` / `TabClearCursor` | |

---

## Open points

*Evidence: [ASM] (what was and was not found)*

- `ArrangeCancelTarget` falls through into `ArrangeCancelTab` (see the Arrange section) while two asm comments describe a target-only cancel.
- `ArrangePerformSwap` never handles "the target slot was equipped" (confirmed by the asm comment).
- `PositionGridCursor`'s second entry (`loc_02EA46`) has no caller.
- The text of the BG3 strings (`consolestring_01E8xx`–`01EAxx`) is not decoded here; only their order is recorded.

---

## See Also

| Document | Relationship |
|----------|-------------|
| [inventory-overlay.md](inventory-overlay.md) | `OpenInventoryScreen`, the loop that runs this menu and polls flag byte `#00` |
| [hardware-and-init.md](hardware-and-init.md) | VBlank and joypad layer behind `joypadCurrent` / `joypadHeld` |
| [game-systems.md](game-systems.md) | event-block and flag helpers |
| [scene-script.md](scene-script.md) | scene `$FF` build that spawns the menu actor |
