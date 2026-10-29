# Bank $00 — Functions: Player State, NPC AI & Escort

**Bank:** `$00` (mirrored at `$80`)  
**Address range:** `$00C397`–`$00C9B8`  
**Source files:** [`ApplyPlayerHitstun.asm`](../../../extracted/functions/ApplyPlayerHitstun.asm), [`SetPlayerIdleFacing.asm`](../../../extracted/functions/SetPlayerIdleFacing.asm), [`npc_wander_ai.asm`](../../../extracted/functions/npc_wander_ai.asm), [`FlickerParentActor.asm`](../../../extracted/functions/FlickerParentActor.asm), [`EscortFollowPathTracker.asm`](../../../extracted/functions/EscortFollowPathTracker.asm), [`f_inventory_full.asm`](../../../extracted/functions/f_inventory_full.asm)

Player damage knockback, cutscene idle facing, town NPC wander AI, escort path replay, parent flicker helper, and inventory-full dialog.

**Related:** [`actors-combat-interaction.md`](actors-combat-interaction.md) (`HitStaggerMain` from hitstun) · [`README.md`](README.md)

## Source of truth

| Topic | `extracted/...` |
|--------|------------------|
| Hitstun | `functions/ApplyPlayerHitstun.asm`, `actors/hit_stagger_controller.asm` |
| Idle facing | `functions/SetPlayerIdleFacing.asm`, `actors/player/player_character.asm` (`IdleStand*`) |
| Wander AI | `functions/npc_wander_ai.asm`, town NPC actor scripts |
| Escort | `functions/EscortFollowPathTracker.asm` |
| Flicker | `functions/FlickerParentActor.asm` |
| Inventory full | `functions/f_inventory_full.asm` |

**Naming:** `orbitAngle` / `orbitDiameter` at `$7F0010`/`$7F0012` in wander and escort code are **WRAM field mnemonics** — for wander they store **home X/Y**, not orbit math. `currentHp` at `$7F0026` holds the NPC **base animation index** in wander AI.

**Counts (this session, `rg` on `extracted/`):** `ApplyPlayerHitstun` JSL **9** sites in **3** files; `SetPlayerIdleFacing` JSL **17** sites in **14** files; `NpcRandomWanderAI` JSL **13** actors; `InventoryFullMessage` JML **8** sites; `EscortFollowPathTracker` `SpawnAfterFlags` **7** scenes; `FlickerParentActor` `SpawnAfterAbsFlags` **5** actors.

---

## Overview

| Function | Address | Size | Movable | Call type | Priority |
|----------|---------|------|---------|-----------|----------|
| `ApplyPlayerHitstun` | `$C397` | 129 B | ✓ | JSL (9 sites) | **High** |
| `SetPlayerIdleFacing` | `$C6E4` | 44 B + table | ✓ (with table) | JSL (17 sites) | **High** |
| `SyncActorPosFromDP` | `$C718` | 13 B | ✓ | JSL (13 inits) | Medium |
| `NpcRandomWanderAI` | `$C725` | 213 B | ✓ | JSL (13 loops) | **High** |
| `FlickerParentActor` | `$C7FA` | 12 B | ✓ | COP `SpawnAfterAbsFlags` | Medium |
| `EscortFollowPathTracker` | `$C806` | 317 B + table | ✓ (with table) | COP `SpawnAfterFlags` | **High** |
| `InventoryFullMessage` | `$C98E` | 42 B | ✓ | JML (8 sites) | Medium |

---

## Player state & damage

### ApplyPlayerHitstun

**Address:** `$C397` · **Live**

**Entry:** **A** = damage (bit 15 = heavy-hit flag); **Y** = knockback direction (0 south, 1 north, 2 west, 3 east, 4+ = none). ASL/LSR only tests bit 15 — damage is **not** halved.

Subtracts damage from `playerHp`, sets player `$10` \|= `$0080`, writes iframe counter `$7F0028` (`$003C` or `$FFC4` for heavy). Unless `playerFlags` bit `$0800` (script lock), spawns `HitStaggerMain` via `SpawnListAppend` with flags `$2400`. On script lock or failed spawn (`Y == $1FC0`), clears joypad mask bits `$0F00`. Always plays `PlaySoundCh2` `#07`.

#### JSL call sites (9)

| File | Sites |
|------|-------|
| `great_wall/gw82_archer.asm` | 2 |
| `great_wall/gw83_asp.asm` | 3 |
| `incan_ruins/ir1F_stone_guard.asm` | 4 |

Player attack and contact damage use inline code in `combat_collision.asm`, not this routine.

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Spawns | `HitStaggerMain` | `hit_stagger_controller` |
| Returns via | Stagger child | `HitStaggerReleasePlayer` → player idle |

---

### SetPlayerIdleFacing

**Address:** `$C6E4` · **Live**

**Entry:** **A** = facing index 0 south, 1 north, 2 west, 3 east (no range check). Sets player actor `$0000`/`$0002` from the **`player_idle_entry_table`** (four **`$&IdleStand*`** words in `player_character.asm` — **not** scene-mode variants).

Zeros wait `$0008` and movement scratch `$002C`/`$002E` (DP and `$7F002C`/`$7F002E`). Caller **X** saved/restored; **only A** selects facing.

#### Table: `player_idle_entry_table`

| Index (A) | Entry label |
|-----------|-------------|
| 0 | `IdleStandSouth` |
| 1 | `IdleStandNorth` |
| 2 | `IdleStandWest` |
| 3 | `IdleStandEast` |

#### JSL call sites (17, 14 actor files)

| Scene / actor file |
|--------------------|
| `diamond_mine/mine_elevator/dm43_elevator.asm` |
| `incan_ruins/incan_ruins_entrance/ir1C_lily.asm` |
| `babel_tower/babel_lower_floors/btDF_kara.asm` |
| `babel_tower/babel_entrance/btDE_monologue.asm` |
| `babel_tower/babel_entrance/btDE_olman.asm` |
| `angel_village/angel_tunnel_rooms/av74_kara.asm` |
| `angel_village/undersea_tunnel/st68_lily.asm` |
| `nazca/nazca/na4B_lily.asm` |
| `freejia/oakton_interior/dc31_kara.asm` (×2) |
| `itory/itory_village/it15_lola.asm` |
| `itory/itory_village/it15_lily.asm` |
| `south_cape/coastal_cave/sc02_seth.asm` |
| `south_cape/wills_house/sc06_lily.asm` |
| `south_cape/wills_house/sc06_kara.asm` (×3) |

---

## NPC wander AI

### Home position and wander state storage

| WRAM / DP | Mnemonic (extracted) | Role in wander |
|-----------|----------------------|----------------|
| DP `$14`, `$16` | — | Current pixel position (updated by caller `AnimOnce`) |
| `$7F0010,X` | `orbitAngle` | **Home X** (copied once from `$14` in init) |
| `$7F0012,X` | `orbitDiameter` | **Home Y** (copied once from `$16`) |
| `$7F0026,X` | `currentHp` | **Base animation index** (stand = base+0..3, walk = base+4..7) |
| `$0008` | wait | `$78` after a stand (121 tick hold via caller yield pattern) |
| `$28`, `$2A` | sprite frame | Staged animation index |

Init pattern (each NPC): store base anim in `$7F0026`, **`JSL SyncActorPosFromDP` once**, then loop: **`JSL NpcRandomWanderAI`**, `SetEntryHereAndYield`, `SetEntryHere`, `AnimOnce`.

### SyncActorPosFromDP

**Address:** `$C718` · **Live**

Copies DP `$14`/`$16` → `$7F0010,X` / `$7F0012,X`. Does not fall through into wander in ROM (always **`RTL`**); NPC scripts call wander separately.

### NpcRandomWanderAI

**Address:** `$C725` · **Live**

`RngByte` AND `#7` → `SwitchCase` on **`npc_wander_case_table`** (8 entries):

| Case | Action |
|------|--------|
| 0 | Stand north (`base+1`) |
| 1 | Stand south (`base+0`) |
| 2 | Stand west (`base+2`) |
| 3 | Stand east (`base+3`) |
| 4 | Step north — chain `$12` on Y, walk `base+5` |
| 5 | Step south — chain `$11` on Y, walk `base+4` |
| 6 | Step west — chain `$12` on X, walk `base+6` |
| 7 | Step east — chain `$11` on X, walk `base+7` |

**Home distance:** steps abort to a stand facing that direction if movement would exceed **`$30` pixels** (3 tiles) from home on that axis, or if `BranchIfSolid*` for that direction hits a solid tile. Stands call **`MarkSolidHere`**; walks call **`ClearSolidHere`**.

#### NPC × AI matrix (13 actors, static scripts)

| Region | Actor file |
|--------|------------|
| Dao | `daC9_businessman.asm`, `daC3_man1.asm` |
| Watermia | `wa78_water_kid.asm`, `wa78_moving_woman.asm`, `wa78_glass_game.asm`, `wa78_centipede_man.asm` |
| Angel Village | `av6B_villagers2.asm`, `av6B_ocean_ache.asm` |
| Euro | `eu91_women2.asm`, `eu91_men2.asm` |
| Seaside Palace | `sp5A_villagers.asm` |
| South Cape | `sc01_roof_man.asm`, `sc04_poverty.asm` |

---

## Escort path tracking

### EscortFollowPathTracker

**Address:** `$C806` · **Live**

Child actor spawned with **`SpawnAfterFlags`** on escort NPCs; uses **`$04`** (list predecessor) as the **parent NPC** slot.

**Setup:** seed facing from spawner (`orbitAngle` = facing+1, or 0 → `GetPlayerFacingDirection`), fill **`$7EDF00`** ring with **9** eight-byte entries (X, Y, facing word at +4), then track player `$14`/`$16` each frame.

**Ring layout (`$7EDF00`, global WRAM — not per-actor pool):**

| Field | Size | Notes |
|-------|------|-------|
| Entry stride | 8 bytes | X word, Y word, facing word, unused |
| Entries written | 9 | offsets `$00`–`$40` |
| Entries read | 8 | head index masked with **`$3F`**; ninth slot unused |

**Per frame:** if player moved, NPC jumps to **head** position (≈8 recorded frames behind), overwrites head with current player XY, updates walk anim `orbitDiameter + facing + 4` when facing changed, advances head by 8. If player idle, NPC shows stand anim `orbitDiameter + facing` (no +4).

**`EscortFollowPathDeltaTable`:** 4 rows × 4 words (dx, dy, facing word, pad) — initial trail steps **opposite** player facing (2 px per setup entry).

#### Spawn sites (7)

| Actor file | Flags param |
|------------|-------------|
| `edward_castle/edward_castle/ec0A_kara.asm` | `$2000` |
| `itory/moon_tribe_camp/it1A_lily.asm` | `$2000` |
| `incan_ruins/incan_ruins_entrance/ir1C_lily.asm` | `$2000` |
| `euro/flea_market/eu97_clerk2.asm` | `$2000` |
| `babel_tower/babel_lower_floors/btDF_kara.asm` | `$2000` |
| `babel_tower/babel_entrance/btDE_kara_missing.asm` | `$2800` |
| `babel_tower/babel_upper_floors/btE3_kara.asm` | `$2000` |

Spawner sets **`orbitDiameter`** = NPC base animation index; **`orbitAngle`** = facing seed per block note.

---

## Inventory utility

### InventoryFullMessage

**Address:** `$C98E` · **Live**

`PrintDialogString` `dialogstring_00C993`, then **`RTL`** back to the calling actor script (entered via **`JML`**, not a subroutine call).

Reached when a script's item-grant path fails (inventory full) — **`GiveItemToPlayer`** failure branches **`JML`** here. **`InteractionDamage_NPCChat`** uses its own overflow path and does **not** jump to this label.

#### JML call sites (8)

| File |
|------|
| `pyramid/heiroglyph_room/pyDA_lithograph1.asm` |
| `angkor_wat/angkor_inner_courtyard/awBA_glasses.asm` |
| `euro/euro/eu91_merchant_counter.asm` |
| `great_wall/gw82_necklace_stone.asm` |
| `diamond_mine/mine_inner/dm47_sam.asm` |
| `edward_castle/castle_prison/ec0B_cell.asm` |
| `edward_castle/edward_castle/ec0A_barrel_roast.asm` |
| `south_cape/wills_house/sc06_lola.asm` |

---

## Parent flicker (cutscene)

### FlickerParentActor

**Address:** `$C7FA` · **Live**

Each tick: **`LDY $24`** (parent slot from spawner via `CopyActorState`), **`EOR #$2000`** on parent **`$0010,Y`** (not `$12`). **`RTL`** without `Die` — toggles every frame (~50% depth skip in `SortActorsByDepth`).

#### Spawn sites (5)

| File | Context |
|------|---------|
| `seaside_palace/palace_main/sp5A_phantom_ribber.asm` | Phantom Ribber |
| `seaside_palace/palace_rooms/sp5B_neil.asm` | Party room reveal (flag `#70`) |
| `sp5B_lance.asm`, `sp5B_erik.asm`, `sp5B_kara.asm` | Same pattern |

---

## Call reference matrix

| Caller context | Function | Mechanism |
|----------------|----------|-----------|
| `gw82_archer`, `gw83_asp`, `ir1F_stone_guard` | `ApplyPlayerHitstun` | JSL |
| 14 cutscene actors (see table) | `SetPlayerIdleFacing` | JSL |
| 13 town NPC inits / loops | `SyncActorPosFromDP`, `NpcRandomWanderAI` | JSL |
| Escort Kara / Lily / clerk scenes | `EscortFollowPathTracker` | COP `SpawnAfterFlags` |
| Palace rooms / Phantom Ribber | `FlickerParentActor` | COP `SpawnAfterAbsFlags` |
| 8 item-grant scripts | `InventoryFullMessage` | JML |

---

## Statistics

| Metric | Value |
|--------|-------|
| Functions documented | 7 |
| Address span | `$C397`–`$C9B8` |
| High-priority (combat / escort / wander) | 4 |
| External bank | `$03` (`GetPlayerFacingDirection` in escort setup/tail) |

---

## Source validation

**Files checked:** all listed `extracted/functions/*.asm` above; JSL/JML/COP call sites verified with `rg` across `extracted/`; wander block note actor list matched to 13 NPC files; escort block note spawn list matched to 7 scenes.

**Verified:** `player_idle_entry_table` contents and facing-only indexing; wander case order and `$30` home bounds; escort `$7EDF00` entry size and 8/9 entry behavior; `FlickerParentActor` parent field `$24` and `$0010` toggle; inventory-full 8 JML paths.

**Notes:** `SetPlayerIdleFacing` table is **not** a scene/mode table (doc-only “restricted movement” rows removed). Escort “delay” is frame-based path replay, not a simple 9×4-byte actor ring. Failed `HitStaggerMain` spawn still runs child-setup stores at `Y=$1FC0` per source comment (behavior at that address not traced).
