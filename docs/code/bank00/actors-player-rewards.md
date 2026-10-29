# Bank $00 — Actors: Player Transitions, Rewards & Inventory

**Bank:** `$00` (mirrored at `$80`)  
**Address range:** `$00C2BB`–`$00DA78` (reward-related actors in this doc)  
**Scope:** Boss catchup stat rewards, per-scene clear-reward helpers, field-reveal pickups, mystic-statue ceremony / inventory display, player transition scripts, and assorted town interactables  
**Related:** [`functions-combat-defeat.md`](functions-combat-defeat.md) (last-enemy stat pickup pipeline, gem drops) · [`actors-combat-interaction.md`](actors-combat-interaction.md) (defeat dispatch, push handlers) · [`README.md`](README.md)

---

## Source of truth

Primary extracted files for this document:

| Path | Role |
|------|------|
| `extracted/actors/boss_clear_reward_handler.asm` | Post-boss catchup actor + `boss_reward_range_table` |
| `extracted/tables/enemy_clear_reward_table.asm` | 256-byte per-scene tier table (`?BANK 01`) |
| `extracted/actors/reward_actors.asm` | Last-kill HP/STR/DEF pickup actors + `RewardActorVFX` |
| `extracted/functions/StandardEnemyDefeatHandler.asm` | Last-enemy `EnemyStatBonusReward` spawn path |
| `extracted/functions/EnemyDefeatDispatch.asm` | Non-last kills → `field_reveal_object` gem path |
| `extracted/actors/field_reveal_object.asm` | Runtime gem / hidden-stat reveal pickup |
| `extracted/system/statue_inventory/statue_inventory_reward.asm` | Scene `$FD` ceremony + `statue_reward_table` |
| `extracted/system/inventory/inventory_statue_slot.asm` | Scene `$FF` pedestal display |
| `extracted/system/inventory/inventory_menu.asm` | Notes: menu does not spawn statue actors |
| `extracted/actors/player_transition_handlers.asm` | Player script library (not scene-placed) |
| `extracted/actors/hidden_red_jewel.asm` | Red jewel interactable (separate from stat rewards) |
| `extracted/actors/town_door.asm`, `extracted/freejia/freejia/freejia_street_prop.asm` | Door-like props |
| `extracted/actors/hit_switch.asm`, `extracted/actors/overworld_exit.asm` | Great Wall switches, world-map exits |
| `extracted/tables/scene_actors.asm` | Static placements for `$FD`, `$FF`, boss handler, jewels, doors |
| `extracted/pyramid/pyCC_mystic_ball.asm`, `extracted/angkor_wat/awB1_wall_walker.asm` | `field_reveal_object` field spawns |

**Naming:** Labels such as `boss_clear_reward_handler`, `BossClearApplyStatReward`, and `PlayerSkyGardenJumpLanding` are **extracted labels**. Legacy names in older notes (`apply_pending_clear_rewards`, `SpawnSparkleEffect`, `GardenJumpAnim`, `FallIntoHoleAnim`) are **not** in the current ROM — do not use them when patching.

**Counts (this session, `rg` on `extracted/tables/scene_actors.asm` unless noted):**

| Item | Count type | Value |
|------|------------|-------|
| `boss_clear_reward_handler` | static scene placements | **5** (scenes `$29`, `$55`, `$67`, `$8A`, `$DD`) |
| `hidden_red_jewel` | static scene placements | **16** |
| `town_door` | static scene placements | **16** (+ **1** runtime spawn in `fr32_guide.asm`) |
| `freejia_street_prop` | static scene placements | **2** (scene `$32`) |
| `hit_switch` | static scene placements | **7** (Great Wall `$83`, `$85`×5, `$87`) |
| `overworld_exit` | static scene placements | **15** |
| `statue_inventory_reward` | static scene placements | **6** (scene `$FD` only) |
| `inventory_statue_slot` | static scene placements | **6** (scene `$FF` only) |
| `field_reveal_object` | static scene placements | **0** — **3** runtime spawn call sites (`EnemyDefeatDispatch`, `pyCC_mystic_ball`, `awB1_wall_walker`) |
| `boss_reward_range_table` | entries in source table | **11** rows (**5** live boss rows + **6** placeholders) |
| `enemy_clear_reward_table` | entries in source table | **256** bytes (**87** nonzero tiers in shipped table) |
| `statue_reward_table` | entries in source table | **6** rows × 4 bytes |

---

## Overview

| Actor / block | Address (approx.) | Movable | Scene / spawn |
|---------------|-------------------|---------|----------------|
| `boss_clear_reward_handler` | `$C2BB` | ✓ | 5 boss arenas |
| `player_transition_handlers` | `$C418`–`$C68F` | **No** | Library (`$&` / pointer writes only) |
| `freejia_street_prop` | `$C630` | ✓ | Scene `$32` (2) |
| `hidden_red_jewel` | `$C672` | ✓ | 16 scenes |
| `town_door` | `$C5A3` | ✓ | `$01` / `$32` / `$91` (+1 runtime) |
| `hit_switch` | `$C9FE` | ✓ | Great Wall (7) |
| `overworld_exit` | `$CA45` | ✓ | 15 overworld entrances |
| `statue_inventory_reward` | `$CD59` | ✓ | Scene `$FD` (6 copies) |
| `inventory_statue_slot` | `$CF29` | ✓ | Scene `$FF` (6 copies) |
| `field_reveal_object` | `$DA78` | ✓ | Runtime spawn only |

Statue ceremony actors are **not** part of the enemy-clear stat pipeline; they use **`SetFlagRaw`** on indices `$F8`–`$FD` (bits in byte `$0A1F`) and only affect inventory presentation.

---

## Reward systems (how they relate)

```text
                    enemy_clear_reward_table[scene]  (256 bytes, bank $01)
                                    |
        +---------------------------+---------------------------+
        |                           |                           |
   Last enemy kill              Boss defeated              Hidden field event
   (orbitAngle = 0)            (playerFlags $0020)        (mystic ball, wall walker)
        |                           |                           |
 StandardEnemyDefeatHandler    boss_clear_reward_handler    SpawnAfterFlags
   .EnemyStatBonusReward       .BossClearApplyStatReward          |
        |                           |                           |
 spawns reward_actors           Direct INC stats +          field_reveal_object
 e_hp / e_str / e_def           SetFlag_0300 per scene      (tier OR gem path)
        |                           |                           |
 RewardActorVFX sets            Same SetFlag_0300            collect_handler_gem
 SetFlag_0300 + VFX             (skip if already set)        child (pull pickup)
        |                           |
   Dialog + stat + HP bar refill via hpToHeal ($0B22)

Parallel track (red jewels): hidden_red_jewel / NPC scripts → GiveItem #01 → TestEventFlag_0200 ($0280+$0E)

Parallel track (statues): boss scripts → QueueMapChange scene $FD → statue_inventory_reward
                          → SetFlagRaw ($F8-$FD) → inventory_statue_slot on scene $FF
```

Full last-kill and gem-drop behavior: [`functions-combat-defeat.md`](functions-combat-defeat.md).

---

## Boss clear catchup rewards

### `boss_clear_reward_handler` (**live**)

**Address:** `$00C2BB` · **Size:** ~220 bytes (49854–50070 in extraction)

After a boss dies, this invisible actor grants every **uncollected** per-scene clear reward in the dungeon range tied to that boss. It does **not** grant red jewels, mystic statues, or gem pickups — only the same **Max HP / STR / DEF +1** tiers stored in `enemy_clear_reward_table`, using the same **`SetFlag_0300`** scene flags as normal room clears.

**Activation**

1. `BossRewardCheckInit` scans `boss_reward_range_table` (4 bytes per row: **boss scene id**, **first scene**, **last scene**, pad) until `sceneCurrent` matches. No end-of-table guard — safe only because the actor is placed solely in the five boss arenas.
2. `TestWramFlag_Offset100` on boss index (row offset ÷ 4 → event flags **`$0500`–`$0507`**). If already set, the actor idles.
3. Each frame: require **`playerFlags` bit `$0020`** (boss-defeat latch from boss scripts).
4. `BossClearApplyStatReward` walks scene indices **`[first, last)`** (last scene byte is **exclusive**; boss scene tier is **0** in the shipped table so the walk stops there).

**Per-scene grant (`BossClearApplyStatReward`)**

- Read `enemy_clear_reward_table[Y]`. Tier **0**: advance; when index reaches **last**, done.
- Tier **nonzero** and **`TestFlag_0300(scene)`** clear: **`SetFlag_0300`**, then **1** → `INC playerMaxHp`, **2** → `INC playerStr`, **3** → `INC playerDef` (values **>3** set the flag but grant no stat — none occur in the table).
- **`hpToHeal`** (`$0B22`) := `playerMaxHp − playerHp` (HUD refills 1 HP per 8 frames, same as `reward_actors`).
- **`SetWramFlag_Offset100`** marks this boss’s catchup complete.

```text
1. Match sceneCurrent in boss_reward_range_table → boss index in $20
2. TestWramFlag_Offset100(boss index) → idle if set
3. Poll playerFlags bit $0020 each frame
4. Load range word from table+1 into actor $04; JSR BossClearApplyStatReward
5. hpToHeal := maxHp − hp; SetWramFlag_Offset100(boss index); idle loop
```

| Symbol | Role |
|--------|------|
| `$scene_current` | Boss arena scene id (table lookup key) |
| `$player_flags` | Bit `$0020` = boss defeated |
| `$0ACA` / `$0ACE` | Max / current HP |
| `$0ADE` / `$0ADC` | STR / DEF |
| `$0B22` | `hpToHeal` |
| `$20` | Matching row byte offset |
| `boss_reward_range_table` | Boss scene → scene index range |
| `enemy_clear_reward_table` | Tier per scene (0–3) |

#### `boss_reward_range_table` (in `boss_clear_reward_handler.asm`)

| # | Boss scene | First | Last (exclusive) | Context |
|---|------------|-------|------------------|---------|
| 00 | `$29` | `$0C` | `$29` | Castoth |
| 01 | `$55` | `$3D` | `$55` | Viper |
| 02 | `$67` | `$5A` | `$67` | Mu vampires |
| 03 | `$8A` | `$6D` | `$8A` | Sand Fanger |
| 04 | `$DD` | `$A0` | `$DD` | Mummy Queen |
| 05 | `$F8` | `$00` | `$00` | Placeholder |
| 06–0A | `$29` | `$00` | `$00` | Placeholders (never match before row 00) |

#### Scene placements (`scene_actors.asm`)

| Scene | Slot | Boss context |
|-------|------|----------------|
| `$29` | `#05` | Castoth |
| `$55` | `#19` | Viper |
| `$67` | `#0A` | Mu |
| `$8A` | `#04` | Sand Fanger |
| `$DD` | `#0A` | Mummy Queen |

**Includes:** `enemy_clear_reward_table`, `flag_helpers` (move with handler).

---

## Per-scene clear reward table

**File:** `extracted/tables/enemy_clear_reward_table.asm` (**bank `$01`**, 256 bytes)

One byte per scene id: **0** none, **1** Max HP +1, **2** STR +1, **3** DEF +1. Claim state: **scene flag `$0300 + scene`** (`TestFlag_0300` / `SetFlag_0300` in `flag_helpers.asm`).

**Readers (live):**

| Consumer | Use |
|----------|-----|
| `StandardEnemyDefeatHandler.EnemyStatBonusReward` | Last enemy → spawn `reward_actors` pickup |
| `boss_clear_reward_handler.BossClearApplyStatReward` | Boss catchup batch grant |
| `field_reveal_object` | Hidden stat item variant when tier path runs |
| `radar_map_screen` | Reward icon while flag clear and tier ≠ 0 |

---

## Field reveal collectibles

### `field_reveal_object` (**live**, runtime spawn only)

**Address:** `$00DA78` · **Size:** ~274 bytes

Gem or stat-item pickup: drops to floor, hops, spawns **`collect_handler_gem`** (`SpawnAfterMarked`, flags `$2300`) for L/R pull collection. **Not listed in `scene_actors.asm`.**

**Spawn call sites**

| Caller | `$26` at entry | Behavior |
|--------|----------------|----------|
| `EnemyDefeatDispatch.asm` | Remaining enemy count (**nonzero**) | **Gem path only** — reads defeated enemy’s `enemy_stats_table+3` & 3 |
| `pyCC_mystic_ball.asm` | 0 | Tier path if flag `$0300` clear |
| `awB1_wall_walker.asm` | 0 | Same |

**Pickup selection (entry)**

```text
if $26 != 0  OR  TestFlag_0300(scene)  →  FieldRevealFromActorStats (gem tiers from stat table +3)
else  tier = enemy_clear_reward_table[scene] & 3
      0 → FieldRevealFromActorStats
      1/2/3 → stat items anim $0C/$0D/$0E, items $80/$81/$82 (does NOT SetFlag_0300 here)
```

**Motion:** `FieldRevealDrop` probes solid tiles (budget overwritten to 7 steps), `MoveToward` to landing row, Y hop chain `$45`, **`WaitByte #0B` (12 ticks)**, then `collect_handler_gem`. Stat items loop anim ≥ `$08` indefinitely; gems blink ~110 frames then `FieldRevealDieEmpty`.

**Note:** Per-enemy gems from `EnemyDefeatDispatch` never use the room tier path; last-kill stat rewards use `reward_actors` instead ([`functions-combat-defeat.md`](functions-combat-defeat.md)).

---

## Mystic statue ceremony (scene `$FD`)

### `statue_inventory_reward` (**live**)

**Address:** `$00CD59` · **Size:** ~464 bytes

**Separate progression system:** mystic statues for the inventory screen, **not** `enemy_clear_reward_table` or `$0300` flags.

**Scene `$FD`:** six actor copies (same pedestal layout as inventory scene `$FF`). Only the copy whose `statue_reward_table` **match byte** equals **`globalScriptIndex` (`$0AAC`)** runs the ceremony; others stay hidden or show already-collected statues.

**Triggers:** `QueueMapChange` to scene `$FD` from six scripts (each sets `globalScriptIndex`, `sourceSceneId` `$0B12`, return coords `$0B08`–`$0B10`):

| Index | Match | Trigger (extracted) | Return scene |
|-------|-------|---------------------|--------------|
| 0 | 0 | `gs2E_crew2.asm` | Gold Ship `$2E` |
| 1 | 1 | `sg55_mystic_statue.asm` | `$55` |
| 2 | 2 | `mu66_rama_spirits.asm` | `$66` |
| 3 | 3 | `gw8A_sand_fanger.asm` | `$8A` |
| 4 | 4 | `pyDD_mystic_statue.asm` | `$DD` |
| 5 | 5 | `btDE_olman.asm` | `$DE` |

**`statue_reward_table`** (6 × 4 bytes: flag, sprite anim index, match index, tail byte unused):

| Index | Flag | Sprite (`$28`) | Match |
|-------|------|----------------|-------|
| 0 | `$F8` | `$3A` | 0 |
| 1 | `$F9` | `$3B` | 1 |
| 2 | `$FA` | `$3C` | 2 |
| 3 | `$FB` | `$3D` | 3 |
| 4 | `$FC` | `$3E` | 4 |
| 5 | `$FD` | `$3F` | 5 |

Flags **`$F8`–`$FD`** are **`SetFlagRaw`** → bits 0–5 of byte **`$0A1F`**.

**Ceremony (summary):** hide input (`joypadMaskStd |= $FFFC`), VRAM/register setup, **`SetFlagRaw`** on success path, **8** `StatueRewardOrbitalSparkle` children (angles `$21`, `$41`, … `$E1`, loop until angle word `$0101`), fanfare wait reusing **`globalScriptIndex` as 180-frame countdown**, then up to **60** `StatueRewardConfettiBurst` spawns (~**15** visible due to `frameCounter AND 3` gate). Exit: restore `sourceSceneId`, warp coords, `gfxCacheIdxA` `$0002`, `gfxCacheIdxB` `$0303`.

**Placements:** `scene_actors.asm` scene `$FD` records `#00`–`#05` → `@statue_inventory_reward`.

---

## Inventory statue display (scene `$FF`)

### `inventory_statue_slot` (**live**)

**Address:** `$00CF29` · **Size:** ~84 bytes (+ claimed-state block)

**Display-only** relative to ceremony: reads **`statue_reward_table`** via `?INCLUDE 'statue_inventory_reward'`. **`TestFlagRaw`**: if statue not collected → **`Die`** immediately. If collected → show sprite from table byte +1, animate.

**Tab rule:** `inventoryTabIndex` (`$0AFA`) **= 3** (Status) → hide (`$10` bit `$2000`); tabs 0–2 show pedestals beside the item grid. The inventory menu actor does **not** spawn these — they come from scene `$FF`’s actor list (`inventory_menu.asm` block note).

**Placements:** `scene_actors.asm` scene `$FF` records `#01`–`#06` (after `InventoryMenuDef`).

Spawn parameter encoding (low nibble = table index, bit 4 = top-row Y offset): documented in `inventory_statue_slot.asm` block note.

---

## Player transition handlers library

### `player_transition_handlers` (**live** library, **not movable**)

**Address:** `$00C418`–`$C68F` · **Size:** ~472 bytes

COP routines and one impact effect. Callers write **`$0000`/`$0002`** on the **player** actor; most end with **`JML PlayerIdleEntry`** (bank `$02`), which clears script locks including **`playerFlags` `$0800`**.

**Includes:** `player_character`, `spriteset_pickups_effects` (not `table_0EE000`).

| Label | Role | Example callers |
|-------|------|-----------------|
| `SpawnImpactSparkAndDie` | Spark + die | `combat_collision` default victim script |
| `ImpactSparkEffect` | SFX `$09`, frame `$2A` | Via spawn above; `gw82_archer` |
| `PlayerIdleAnimLoop` | Idle anim `$01` / `$11` (flag byte `#00`) | `warps_interaction`, `ir29_castoth` |
| `PlayerStaticBodyPose` / `PlayerWalkingIdlePose` | Flute pose body 4 / `$1F` | `item_use_system` melody |
| `RestorePlayerControlDirect` | `JML PlayerIdleEntry` | `warps_interaction`, `ir29_castoth` |
| `PlayerPoseHold` / `PlayerPoseHoldExit` | Hold body 4 frame `$20` | Gold Ship / Freejia cutscenes |
| `PlayerIdleEntryJump` | `JML PlayerIdleEntry` | **Dead / unreferenced** |
| `PlayerFallFromHeight` | Fall anim + landing | `awBD_fall_trigger` |
| `PlayerSkyGardenJumpLanding` | Garden jump arc | `sg4D_jump_handler` |
| `PlayerAuraTransformEntry` (+ sub-labels) | Shadow Aura sink | `item_use_system.UseItem_Aura` |

There is **no** `WarpClimbAnim`, `GardenJumpAnim`, or `FallIntoHoleAnim` label in the current extraction — use the names above.

---

## Location-specific interactables

### `hidden_red_jewel` (**live**)

Red jewel item **`#01`** via **`GiveItem`**, flag **`TestEventFlag_0200`** with index **`$0E + $80`** ( **`$0280`–`$028F`** ). **Independent** of clear-reward flags `$0300` and boss catchup. Sixteen static placements; seven NPC scripts **`JML HiddenRedJewelInventoryFull`** on full inventory (no shared flag with placements).

### `freejia_street_prop` (**live**)

Scene **`$32`**, **2** placements. Same interaction pattern as `town_door` (near + hold Up **`$0800`** 8 frames): sound **`$01`**, frame **`#07`** → open **`#00`**. Metasprite `spriteset_npc_props`.

### `town_door` (**live**)

**16** static + **1** runtime (`fr32_guide` → `TownDoorInit`). Hold Up 8 frames, sound **`$0E`**, closed frame **`#01`**. Scenes: **`$01`** (5), **`$32`** (4), **`$91`** (7).

### `hit_switch` (**live**)

**7** Great Wall placements. Solid; **`SetHitCallback` → `HitSwitchTriggered`**. **`SetFlagRaw`** with flag number in **`$24`** (from spawn type >> 1). Stats pointer **`enemy_stats_table+118`** (entry `$46`). Frame **`#0F`** / **`#10`**.

### `overworld_exit` (**live**)

**15** placements. Dispatches on **`scene_current`** for zone tests → **`StageWorldMapChoice`** → finalize sets **`gfxCacheIdxB`** (`$064A`) to **`$0400`**. Scene-specific gates documented in `overworld_exit.asm` block note (table in prior doc remains aligned with extracted handlers; verify tile coords against that file when patching a single scene).

---

## Source validation

**Files checked:** `boss_clear_reward_handler.asm`, `enemy_clear_reward_table.asm`, `field_reveal_object.asm`, `reward_actors.asm`, `StandardEnemyDefeatHandler.asm`, `EnemyDefeatDispatch.asm`, `statue_inventory_reward.asm`, `inventory_statue_slot.asm`, `inventory_menu.asm`, `player_transition_handlers.asm`, `hidden_red_jewel.asm`, `town_door.asm`, `freejia_street_prop.asm`, `hit_switch.asm`, `overworld_exit.asm`, `scene_actors.asm`, `pyCC_mystic_ball.asm`, `awB1_wall_walker.asm`, `flag_helpers.asm`.

**Verified:** `boss_reward_range_table` row bytes; `BossClearApplyStatReward` tier dispatch and `$0300` interaction; boss flag **`$0500+`** via `TestWramFlag_Offset100`; `field_reveal_object` branch on `$26` and `$0300`; spawn call sites; scene **`$FD`/`$FF`** actor lists; `statue_reward_table` six entries; red jewel flag base **`$0200+$80+$0E`**; placement counts via `rg` on `scene_actors.asm`; player transition label set vs obsolete doc names.

**Notes:** `freejia_street_prop.asm` header comment still says “no interaction”; the COP flow matches interactive props (trust instructions over that comment). `overworld_exit` per-scene coordinate table was not re-audited line-by-line this pass — spot-check against `overworld_exit.asm` before relying on a single row. **`PlayerIdleEntryJump`** marked dead per block note. Inferred: exact meaning of collision byte **`$0E`** in `FieldRevealDrop`.
