# Bank $00 — Event Flag System

**Bank:** `$00` (mirrored at `$80` for FastROM access)  
**Address range:** `$00B05E`–`$00B4F6` (through `TestFlag_0100`; `bitmasks_bit_position` at `$00B11D`)  
**ASM file:** `extracted/system/engine/flag_helpers.asm`

This page documents the **bitfield flag helpers** in bank `$00`: one shared indexing scheme over WRAM, near-call cores (`RTS`), and far-call wrappers (`RTL`) that add constant bases before delegating to the cores.

**Related:** [`direction-collision.md`](direction-collision.md), [`cop_handlers_scene_flags.asm`](../../../extracted/system/engine/cop_handlers_scene_flags.asm) (COP `$CC`–`$D3`), [`../../cop/README.md`](../../cop/README.md), [`../../wram-memory-map.md`](../../wram-memory-map.md)

## Source of truth

Primary: `extracted/system/engine/flag_helpers.asm`

Also checked this session: `extracted/system/engine/cop_handlers_scene_flags.asm`, `extracted/system/engine/cop_handlers_dungeon_switch.asm` (`SetDungeonKillFlag`), `extracted/system/engine/actor_execution.asm` (`CheckEnemyDefeatedFlag`), `db-us/scene-flags.json`, `db-us/names/bank00.json` (label addresses).

**Naming:** All routine and table names in the tables below are **extracted labels** from `flag_helpers.asm`. The **`$0400` / `$0500` style flag IDs** in the flag-array map are **documentation indices** (global bit number = `$0A00` base + byte×8 + bit); they match the block header comments in `flag_helpers.asm`, not separate hardware regions.

**Counts:** JSL wrapper **live/dead** status below was verified with `rg` over `extracted/**/*.asm` this session (static references only). COP opcode usage counts appear in the header of `cop_handlers_scene_flags.asm` (not re-counted here).

---

## Overview

| Category | Functions | Address span (labels) | Notes |
|----------|-----------|------------------------|-------|
| Boss-reward wrappers (`+$0100`, 3-bit index) | 2 | `$00B05E`–`$00B068` | `TestWramFlag_Offset100`, `SetWramFlag_Offset100` |
| Core WRAM-region set/test | 2 | `$00B074`–`$00B0B6` | `SetWramFlag`, `TestWramFlag` |
| Core event-region set/clear/test | 3 | `$00B0B7`–`$00B11C` | `SetEventFlag`, `ClearEventFlag`, `TestEventFlag` |
| Bitmask table (data) | 1 | `$00B11D` | `bitmasks_bit_position` (8 bytes) |
| Far-call wrappers (`RTL`) | 11 | `$00B481`–`$00B4F6` | Offset/raw helpers + `ClearAllWramFlags` |
| **Total** | **19 routines + 1 table** | `$00B05E`–`$00B4F6` | Span from `TestWramFlag_Offset100` through `TestFlag_0100` |

---

## Unified bitfield architecture

All persistence flags are **one logical bit array** rooted at **`eventFlags` (`$000A00`)**. The label **`wramFlags` (`$000A80`)** is the same array at byte offset `$80` from `$0A00`; `SetWramFlag` / `TestWramFlag` read and write through the `wramFlags` label, while `SetEventFlag` / `ClearEventFlag` / `TestEventFlag` use the `eventFlags` label. Both use identical index math.

```
byte_offset = index >> 3
bit_number  = index & 7
bitmask     = bitmasks_bit_position[bit_number]
```

### Flag array map (WRAM bytes vs wrapper bases)

```text
Global flag index     WRAM bytes (inclusive)   Typical role (from asm comments + callers)
-----------------     ----------------------   -------------------------------------------
$0000–$01FF (+Raw)     $0A00–$0A1F              Low event flags (statues, switches, COP byte forms, …)
$0100–$01FF (+_0100)  $0A20–$0A3F              Event/trigger flags (defeat reveal, event blocks, puzzles)
$0200–$02FF (+_0200)  $0A40–$0A5F              Chest-open + Red Jewel persistence (scene_chest_table byte 3)
$0300–$03FF (+_0300)  $0A60–$0A7F              Per-scene “clear reward claimed” (scene ID in A)
$0400–$04FF           $0A80–$0A9F              Dungeon kill bits (enemyNum → SetDungeonKillFlag); cleared by ClearAllWramFlags / game over
$0500–$0507           $0AA0 (bits 0–7)         Boss reward taken (`TestWramFlag_Offset100` / `SetWramFlag_Offset100`, index 0–7)
$0510+ (+_0510)        $0AA2+                   Ability unlock flags (`TestFlag_0510`; index from TestAbilityFlag)
```

**Important:** `TestWramFlag_Offset100` / `SetWramFlag_Offset100` add **`$0100` to (A AND 7)**, which targets **byte `$0AA0`** (global flags **`$0500`–`$0507`**), **not** the `$0A80` kill-flag block. The `_Offset100` suffix is the **index offset**, not “WRAM-only.”

`ClearAllWramFlags` zero-fills **only `$0A80`–`$0A9F`** (32 bytes, global indices **`$0400`–`$04FF`**). It does **not** clear `$0A00`–`$0A7F` or `$0AA0+`.

### Bitmask lookup table

**Label:** `bitmasks_bit_position` · **Address:** `$00B11D` · **Size:** 8 bytes

| Index | Mask |
|-------|------|
| 0–7 | `$01`, `$02`, `$04`, `$08`, `$10`, `$20`, `$40`, `$80` |

### Carry flag convention (test routines)

`TestEventFlag`, `TestWramFlag`, and all **`Test*` JSL wrappers** return:

| Flag bit | **C** (carry) | Typical branch |
|----------|---------------|----------------|
| **Set** | **Set** | `BCS` → “flag is set” (matches caller comments, e.g. `warps_interaction.asm`) |
| **Clear** | **Clear** | `BCC` → “flag is clear” |

Implementation (both cores): `SEC` → `AND` array byte → `BNE` skip **`CLC`** → if AND was zero, **`CLC`** leaves carry clear; if AND was nonzero, carry remains **set** from **`SEC`**.

COP **`BranchOnFlag` / `WaitOnFlag`** handlers in `cop_handlers_scene_flags.asm` branch on this same carry sense.

### Calling convention

From `flag_helpers.asm` header: flag index in **A** (16-bit) for JSL wrappers; cores are **`JSR`-only**, preserve **X**, clobber **Y** and scratch **`$0000`**. **`TestWramFlag` has no `JSR` caller outside `flag_helpers.asm`**; dungeon defeat checks duplicate the logic in `CheckEnemyDefeatedFlag` (`actor_execution.asm`).

---

## Core routines

### SetWramFlag / TestWramFlag

**Addresses:** `$00B074` / `$00B095` · **Termination:** `RTS`

Set or test one bit via **`wramFlags,Y`** (`$000A80` base). Used from **`SetDungeonKillFlag`** (COP `#D8`, passes **`enemyNum`** as index — global flag **`$0400 + enemyNum`** in the unified map) and from **`TestWramFlag_Offset100`** / **`SetWramFlag_Offset100`** (indices **`$0100`–`$0107`** → **`$0AA0`**).

### SetEventFlag / ClearEventFlag / TestEventFlag

**Addresses:** `$00B0B7` / `$00B0D8` / `$00B0FB` · **Termination:** `RTS`

Set, clear (inverted-mask **`EOR #$FF`** then **`AND`**), or test via **`eventFlags,Y`** (`$000A00` base). Called from COP handlers in `cop_handlers_scene_flags.asm` and from all event **`Set*` / `Clear*` / `Test*`** JSL wrappers.

### ClearAllWramFlags

**Address:** `$00B4CC` · **Termination:** `RTL` · **live**

Zeroes **`$0A80`–`$0A9F`** (16 word stores). **`game_over_sequence.asm`** clears the same range inline on a real game over.

**JSL callers (live):** `WorldMapController.asm` (once on world-map entry), `st68_kara.asm`, `sp58_red_eye.asm`. No ordinary scene-change reset was found in extracted code.

---

## Far-call wrappers (RTL)

| Wrapper | Address | Index adjustment | Core | Region (global indices) | Live callers (extracted) | Dead |
|---------|---------|------------------|------|-------------------------|---------------------------|------|
| `SetEventFlag_0200` | `$B481` | `+$0200` | `SetEventFlag` | `$0200+` | `warps_interaction.asm`, `hidden_red_jewel.asm` | |
| `TestEventFlag_0200` | `$B489` | `AND #$FF`, `+$0200` | `TestEventFlag` | `$0200+` | `warps_interaction.asm`, `hidden_red_jewel.asm`, `radar_map_screen.asm` | |
| `TestFlag_0300` | `$B496` | `AND #$FF`, `+$0300` | `TestEventFlag` | `$0300+` scene ID | `StandardEnemyDefeatHandler.asm`, `field_reveal_object.asm`, `boss_clear_reward_handler.asm`, `radar_map_screen.asm` | |
| `SetFlag_0300` | `$B4A1` | `AND #$FF`, `+$0300` | `SetEventFlag` | `$0300+` | `reward_actors.asm`, `boss_clear_reward_handler.asm` | |
| `TestFlag_0510` | `$B4AC` | `AND #$FF`, `+$0510` | `TestEventFlag` | ability unlocks | `inventory_menu.asm` (`TestAbilityFlag` → JSL) | |
| `TestFlagRaw` | `$B4B7` | `AND #$FF` | `TestEventFlag` | `$0000–$00FF` | `scene_script.asm`, `dm3F_laborer.asm`, `pyD4_falling_orb.asm`, `gw82_necklace_stone.asm`, `inventory_statue_slot.asm`, `statue_inventory_reward.asm` | |
| `SetFlagRaw` | `$B4BE` | `AND #$FF` | `SetEventFlag` | `$0000–$00FF` | `dm3F_laborer.asm`, `ir1F_gold_tile.asm`, `pyD4_falling_orb.asm`, `gw82_necklace_stone.asm`, `hit_switch.asm`, `statue_inventory_reward.asm` | |
| `ClearFlagRaw` | `$B4C5` | `AND #$FF` | `ClearEventFlag` | `$0000–$00FF` | `ir1F_gold_tile.asm` | |
| `SetFlag_0100` | `$B4E0` | `AND #$FF`, `+$0100` | `SetEventFlag` | `$0100+` triggers | `EnemyDefeatDispatch.asm`, `StandardEnemyDefeatHandler.asm`, `awB1_wall_walker.asm`, `pyCC_mystic_ball.asm` | |
| `ClearFlag_0100` | `$B4EB` | `AND #$FF`, `+$0100` | `ClearEventFlag` | `$0100+` | | **dead** (no reference) |
| `TestFlag_0100` | `$B4F6` | `AND #$FF`, `+$0100` | `TestEventFlag` | `$0100+` | `EnemyDefeatDispatch.asm`, `StandardEnemyDefeatHandler.asm`, `awB1_wall_walker.asm`, `pyCC_mystic_ball.asm`, `pyCC_dark_space_portal.asm` | |
| `TestWramFlag_Offset100` | `$B05E` | `AND #7`, `+$0100` | `TestWramFlag` | `$0500–$0507` | Boss lairs + `boss_clear_reward_handler.asm`, `ir29_castoth.asm` | |
| `SetWramFlag_Offset100` | `$B069` | `AND #7`, `+$0100` | `SetWramFlag` | `$0500–$0507` | `boss_clear_reward_handler.asm` only | |

---

## Usage patterns

### COP handlers (bank `$00`, near `JSR`)

Scene scripts use COP **`$CC`–`$D3`** (`cop_handlers_scene_flags.asm`) → **`JSR`** `SetEventFlag` / `ClearEventFlag` / `TestEventFlag` with indices from bytecode (byte or word forms). See COP family docs for operand layout.

### Cross-bank actors / engine

Other banks use **`JSL $@flag_helpers.<Wrapper>`**; wrappers adjust **A** and **`JSR`** the core, then **`RTL`**.

### Persistence vs reset

- **`$0A00`–`$0A7F` and `$0AA0+`:** story/world/scene/reward state; **not** cleared by `ClearAllWramFlags`.
- **`$0A80`–`$0A9F`:** dungeon kill bits; cleared on world map entry, specific scripts, and game over (see above).

---

## Canonical index notes (source-backed)

| Range | Role | Evidence |
|-------|------|----------|
| `$0200+` (byte in A) | Chest opened / Red Jewel collected | `scene_chest_table.asm`, `warps_interaction.asm`, `hidden_red_jewel.asm` |
| `$0300+` scene ID | Scene clear reward already claimed | `StandardEnemyDefeatHandler.asm`, `reward_actors.asm`, `boss_clear_reward_handler.asm` |
| `$0100+` idx | Enemy defeat → field reveal / event-block triggers | `EnemyDefeatDispatch.asm`, `StandardEnemyDefeatHandler.asm` |
| `$0400+` enemyNum | Enemy defeated in dungeon (re-entry) | `SetDungeonKillFlag`, `CheckEnemyDefeatedFlag` |
| `$0500–$0507` | Boss reward flag (3-bit boss index) | `TestWramFlag_Offset100`, `SetWramFlag_Offset100` |
| `$0510+` | Ability unlock slots | `TestFlag_0510`, `TestAbilityFlag` |
| Low `$00FF` raw | Statues, switches, misc | `TestFlagRaw` / `SetFlagRaw` call sites |

**Inferred / sparse:** `db-us/scene-flags.json` currently documents only a few story flags (e.g. flag **63** for Lance’s letter); most index meanings come from table comments and caller asm, not a complete ROM-wide index.

---

## Quick reference (addresses)

| Name | Address | Storage base | Operation |
|------|---------|--------------|-----------|
| `TestWramFlag_Offset100` | `$B05E` | `$0AA0` (`$0500+`) | Test |
| `SetWramFlag_Offset100` | `$B069` | `$0AA0` | Set |
| `SetWramFlag` | `$B074` | `$0A80` | Set |
| `TestWramFlag` | `$B095` | `$0A80` | Test |
| `SetEventFlag` | `$B0B7` | `$0A00` | Set |
| `ClearEventFlag` | `$B0D8` | `$0A00` | Clear |
| `TestEventFlag` | `$B0FB` | `$0A00` | Test |
| `bitmasks_bit_position` | `$B11D` | — | Data |
| `SetEventFlag_0200` | `$B481` | `$0A00` | Set (+`$0200`) |
| `TestEventFlag_0200` | `$B489` | `$0A00` | Test (+`$0200`) |
| `TestFlag_0300` | `$B496` | `$0A00` | Test (+`$0300`) |
| `SetFlag_0300` | `$B4A1` | `$0A00` | Set (+`$0300`) |
| `TestFlag_0510` | `$B4AC` | `$0A00` | Test (+`$0510`) |
| `TestFlagRaw` | `$B4B7` | `$0A00` | Test |
| `SetFlagRaw` | `$B4BE` | `$0A00` | Set |
| `ClearFlagRaw` | `$B4C5` | `$0A00` | Clear |
| `ClearAllWramFlags` | `$B4CC` | `$0A80` block | Clear 32 B |
| `SetFlag_0100` | `$B4E0` | `$0A00` | Set (+`$0100`) |
| `ClearFlag_0100` | `$B4EB` | `$0A00` | Clear (+`$0100`, unused) |
| `TestFlag_0100` | `$B4F6` | `$0A00` | Test (+`$0100`) |

---

## Source validation

**Files checked:** `extracted/system/engine/flag_helpers.asm`, `cop_handlers_scene_flags.asm`, `cop_handlers_dungeon_switch.asm`, `actor_execution.asm` (`CheckEnemyDefeatedFlag`), representative JSL call sites under `extracted/` (boss handlers, `warps_interaction.asm`, `StandardEnemyDefeatHandler.asm`, `inventory_menu.asm`, `game_over_sequence.asm`, `WorldMapController.asm`), `db-us/names/bank00.json`, `db-us/scene-flags.json`.

**Verified:** All wrapper labels and addresses; unified `$0A00` map vs `wramFlags` slice; **`TestWramFlag_Offset100` → `$0AA0`**; carry = set when bit set; **`ClearFlag_0100`** unreferenced; **`TestWramFlag`** core only used from `_Offset100` wrapper; live/dead JSL matrix via `rg`.

**Notes:** Global flag IDs (`$0400`, etc.) are documentation naming from `flag_helpers.asm` block comments; **`SetDungeonKillFlag`** passes **`enemyNum`** directly into **`SetWramFlag`** (equivalent to indices **`$0400+enemyNum`** only when describing the unified map). COP usage counts taken from `cop_handlers_scene_flags.asm` header, not re-counted.
