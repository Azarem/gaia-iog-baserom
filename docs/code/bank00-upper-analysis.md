# Bank $00 Upper Half — Comprehensive Block Analysis

**Bank:** `$00` (mirrored at `$80`)
**Address range:** `$00B500`–`$00F4FF` (post-system-core)
**Scope:** All code blocks with auto-generated hex names (type_00####) that have not yet been analyzed
**Related:** [`chunk_008000-analysis.md`](chunk_008000-analysis.md) covers `$008000`–`$00B530`

> This document catalogs every unanalyzed block in the upper half of bank $00,
> provides suggested names, identifies logical groupings, flags errors, and
> recommends split/merge actions. It covers **49 thinkers**, **26 actors**, and
> **29 functions** totaling ~104 discrete code units.
>
> **Status:** All proposed renames have been applied to `us/blocks.json` and
> `us/names.json` as of 2026-09-06. See [§11 Applied Changes](#11-applied-changes).

---

## Table of Contents

1. [Overview & Statistics](#1-overview--statistics)
2. [Thinker Analysis](#2-thinker-analysis)
3. [Actor Analysis](#3-actor-analysis)
4. [Function Analysis](#4-function-analysis)
5. [Logical Groupings](#5-logical-groupings)
6. [Rename Map](#6-rename-map)
7. [Movability Assessment](#7-movability-assessment)
8. [Errors & Issues](#8-errors--issues)
9. [Split / Merge Recommendations](#9-split--merge-recommendations)
10. [Cross-Reference Matrix](#10-cross-reference-matrix)
11. [Applied Changes](#11-applied-changes)
12. [File → Parts Boundary Table](#12-file--parts-boundary-table)

---

## 1. Overview & Statistics

### Address Distribution

| Range | Count | Content |
|-------|-------|---------|
| `$00B500`–`$00BFFF` | 49 | Thinkers (palette, HDMA, DMA, screen config) |
| `$00C100`–`$00CFFF` | 20 | Actors (speed zones, dream, rewards, push) + Functions (NPC AI, camera, menus) |
| `$00D600`–`$00DFFF` | 14 | Functions (game over, combat defeat, item drops, chest spawning) |
| `$00E100`–`$00EAFF` | 12 | Actors (push handlers, smooth follow, visual effects, camera) |
| `$00F300`–`$00F4FF` | 4 | Functions (player stop, orbital math) |

### Block Type Breakdown

| Category | Total | Named | Auto-Named | Unused |
|----------|-------|-------|------------|--------|
| Thinkers | 49 | 1 (`parallax_thinker`) | 48 | 7 |
| Actors | 26 | 11 (named blocks) | 15 | 1 (`speed_zone_ns_fast_unused`) |
| Functions | 29 | 2 (`f_inventory_full`, `death_message`) | 22 active + 5 unused | 5 |
| **Total** | **104** | **14** | **85** | **13** |

---

## 2. Thinker Analysis

Thinkers are background processes (type `thinker_def`) running in parallel with actors. In IOG they handle palette cycling, HDMA wave effects, screen configuration, and DMA setup. All use priority `#08`.

### 2.1 Palette Cycling Family

These thinkers manage ambient color animation using `PaletteRestart`/`PaletteStart`/`PaletteStep` COP commands.

| Current Name | Address | Suggested Name | Purpose | Self-Contained | Scene |
|--------------|---------|----------------|---------|----------------|-------|
| `thinker_00B520` | $B520 | `ambient_palette_cycler` | Generic infinite palette loop; bundle from scene table | ✓ | Dozens (dominant ambient effect) |
| `thinker_00B5C0` | $B5C0 | `flag_gated_palette_warm` | Bundle `#02` gated by flags `#1C`/`#16` | ✓ | Oakton House (scene 48) |
| `thinker_00B5DF` | $B5DF | `flag_gated_palette_cool` | Bundle `#4C`, same flag gate pattern | ✓ | Early overworld maps |
| `thinker_00B5FE` | $B5FE | `palette_parent_child` | Bundle `#03`, spawns child thinker on flag `#01` | ✓ | Inventory-adjacent sets |
| `thinker_00B631` | $B631 | `edward_castle_alarm_palette` | Red-alert palette `#05` + COLDATA red tint | ✓ | Edward Castle (scene 10) |
| `thinker_00B671` | $B671 | `incan_ruins_transform_palette` | Multi-phase: `#1A`→`#34`/`#33`→`#36` via flags `#4D`/`#52` | ✓ | Angkor/Incan scenes |
| `thinker_00B6D2` | $B6D2 | `dream_palette_loop` | Dream palette `#35` with flag `#FF` exit | ✓ | Gold Ship dream (scene 42) |
| `thinker_00B71E` | $B71E | `palace_fountain_palette` | `$CGADSUB=#03` + alternating `#1A`/`#25` | ✓ | Palace Fountain (scene 93) |
| `thinker_00B754` | $B754 | `watermia_festival_palette` | Default `#42`; spawns child `#72` on flag `#96` | ✓ | Watermia (scene 120) |

### 2.2 One-Shot Palette Flashes

Small self-killing thinkers spawned by actor scripts for brief visual effects.

| Current Name | Address | Suggested Name | Bundle | Scene Usage |
|--------------|---------|----------------|--------|-------------|
| `thinker_00B65E` | $B65E | `oneshot_coldata_warm_flash` | COLDATA `#$66`/`#$82` | Incan Ruins / Larai Cliff |
| `thinker_00B6E5` | $B6E5 | `oneshot_coldata_green_tint` | COLDATA `#$2B`/`#$44`/`#$82` | Oakton storm scenes |
| `thinker_00B7CC` | $B7CC | `oneshot_palette_flash_18` | `#18` (white flash) | Comet Lair, Angkor, Mu |
| `thinker_00B7D6` | $B7D6 | `oneshot_palette_flash_19` | `#19` (complement of `#18`) | Same as `#18` |
| `thinker_00B7E0` | $B7E0 | `oneshot_palette_flash_1B` | `#1B` | Mu prayer, Castle prison |
| `thinker_00B7EA` | $B7EA | `oneshot_palette_flash_1C` | `#1C` | Snake Pit, Gold Ship, Mu |
| `thinker_00B7F4` | $B7F4 | `oneshot_palette_flash_40` | `#40` (strong color shift) | Angel Tunnel, Palace |
| `thinker_00B7FE` | $B7FE | `oneshot_palette_flash_1F` | `#1F` | Itory Moon Tribe camp |

### 2.3 Hardware Configuration Thinkers

These set SNES PPU registers once or per-frame without palette cycling.

| Current Name | Address | Suggested Name | Registers Written | Self-Contained | Scene |
|--------------|---------|----------------|-------------------|----------------|-------|
| `thinker_00B78F` | $B78F | `babel_elevator_color_add` | `$CGADSUB=#02` | ✓ | Babel Light Elevator (scene 225) |
| `thinker_00B79D` | $B79D | `palace_scroll_brightness` | `$COLDATA` from `$06C2` scroll | ✓ | Palace Coffins |
| `thinker_00B7BE` | $B7BE | `dao_window_mask` | `$W12SEL=#02` | ✓ | Dao Village (scene 195) |
| `thinker_00B818` | $B818 | `itory_village_fog` | `$CGADSUB=#$50` west of X=$01B0 | **No** (`$player_actor`) | Itory Village |
| `thinker_00BF78` | $BF78 | `dark_castoth_layer_config` | `$TM=#$17`, `$TS=#$00` | ✓ | Dark Castoth Lair (scene 242) |

### 2.4 Sine HDMA Wave Effects

Background oscillation effects using `InitSineHdma`/`TickSineHdma`/`BindSineHdma`.

| Current Name | Address | Suggested Name | Tick Speed | Channel(s) | Scene |
|--------------|---------|----------------|------------|------------|-------|
| `thinker_00BE18` | $BE18 | `sine_hdma_slow_wave` | `#01` | `#0D` | Multiple mid/late scenes |
| `thinker_00BE83` | $BE83 | `sine_hdma_dual_channel` | `#02` | `#0F`, `#10` | Palace Coffins |
| `thinker_00BF19` | $BF19 | `sine_hdma_ending_wave` | — | `#0F` | Comet Lair, Dark Castoth |
| `thinker_00BCB3` | $BCB3 | `ending_comet_sine_hdma` | `#05` | `#0F`, `#10` | Ending Comet (scene 229) |
| `thinker_00BCF5` | $BCF5 | `comet_lair_hdma_a` | — | `#10` | Comet Lair (scene 232) |
| `thinker_00BD21` | $BD21 | `comet_lair_hdma_b` | — | `#0F` | Comet Lair |
| `thinker_00BD42` | $BD42 | `comet_lair_hdma_c_timed` | — | `#0D` | Comet Lair (timed transition) |
| `thinker_00BD96` | $BD96 | `larai_cliff_scroll_wave` | — | — | Larai Cliff (scene 29) |
| `thinker_00BDCD` | $BDCD | `mu_tint_and_wave` | — | `#0D`, `#0E` | Mu rooms (scenes 96–103) |
| `thinker_00BED1` | $BED1 | `dao_sine_hdma_slow` | `#00` | `#0D` | Dao Village |
| `thinker_00BEF2` | $BEF2 | `native_village_sine_hdma` | `#04` | `#0E`, `#10` | Native Village (scene 172) |

### 2.5 Custom HDMA / DMA Setup

| Current Name | Address | Suggested Name | Purpose | Scene |
|--------------|---------|----------------|---------|-------|
| `thinker_00BE39` | $BE39 | `palace_coffin_hdma_table` | Builds HDMA table at `$7E7000` | Palace Coffins |
| `thinker_00BCDF` | $BCDF | `ending_comet_dma_setup` | One-shot DMA for PPU registers | Ending Comet / Comet Lair |
| `thinker_00BB8E` | $BB8E | `inventory_dma_setup` | Inventory screen PPU init | Inventory |
| `thinker_00B87B` | $B87B | `angel_tunnel_window_dma` | Window registers for Angel Tunnel | Angel Tunnel Rooms |

### 2.6 Menu / System Thinkers

| Current Name | Address | Suggested Name | Purpose | Scene |
|--------------|---------|----------------|---------|-------|
| `thinker_00BBAF` | $BBAF | `diary_menu_window_dma` | State-machine DMA for diary menu | Diary Menu |
| `thinker_00B83F` | $B83F | `boot_logo_palette_enix` | Logo fade `#50`→`#52`→`#54` | Boot Logos |
| `thinker_00B853` | $B853 | `boot_logo_palette_quintet` | Logo fade `#51`→`#53`→`#55` | Boot Logos |
| `thinker_00B867` | $B867 | `boot_logo_palette_third` | Logo fade `#56`→`#57`→`#58` | Boot Logos |

### 2.7 Global Scene Dispatcher

| Current Name | Address | Suggested Name | Purpose |
|--------------|---------|----------------|---------|
| `thinker_00BF89` | $BF89 | `global_ambient_dispatcher` | Hub: `SwitchCase` on `$0AD4` selects palette bundles; checks `$0656` bit 15 for player-proximity interaction |

**Dependencies:** `?INCLUDE 'chunk_03BAE1'`, `$player_actor`, `$@func_03F0CA`, `$@func_03CA55`
**Self-contained:** **No** — the only thinker with `?INCLUDE` dependencies
**Scene:** Present in nearly every `thinker_0CE*` scene set as the ambient + interaction slot

### 2.8 Unused / Dead Thinkers

| Current Name | Address | Suggested Name | Reason Unused |
|--------------|---------|----------------|---------------|
| `thinker_00B6FD` | $B6FD | `palette_buffer_clear_unused` | No references in scene_thinkers |
| `thinker_00B781` | $B781 | `babel_palette_65_unused` | No references; cut Babel Tower effect |
| `thinker_00B808` | $B808 | `palette_loop_flash_unused` | No references |
| `thinker_00BC97` | $BC97 | `dma_setup_variant_unused` | No references |
| `thinker_00BDCA` | $BDCA | `empty_stub_unused` | RTL only — placeholder |
| `thinker_00BEAA` | $BEAA | `native_village_dup_unused` | Byte-identical duplicate of `thinker_00BEF2` |
| `thinker_00BF52` | $BF52 | `gen_hdma_sine_oneshot_unused` | Extracted subset of `code_00BF3A` in `thinker_00BF19` |

---

## 3. Actor Analysis

### 3.1 Scene Infrastructure (Global)

| Current Name | Address | Suggested Name | Purpose | Movable |
|--------------|---------|----------------|---------|---------|
| `actor_00EAED` | $EAED | `camera_scroll_controller` | Computes camera scroll deltas from player position; runs on nearly every field scene at actor slot `#01` | ✓ |
| `actor_00C667` | $C667 | `scene_flag_init` | One-shot: clears flag byte `#00`, then dies; bundled as slot `#03`/`#04` | ✓ |

### 3.2 Movement Speed Zones (Mountain Temple)

Invisible tile triggers that modify `$player_speed_ns` or `$player_speed_ew` when the player enters a 16×16 box.

| Current Name | Address | Suggested Name | Axis | Speed | Movable | Scene |
|--------------|---------|----------------|------|-------|---------|-------|
| `actor_00C1DF` | $C1DF | `speed_zone_ew_slow` | E-W | `$FFF9` (−7) | ✓ | Mountain Temple |
| `actor_00C218` | $C218 | `speed_zone_ew_fast` | E-W | `#7` | ✓ | Kress Maze |
| `actor_00C286` | $C286 | `speed_zone_ns_slow` | N-S | `$FFF9` (−7) | ✓ | Mountain Temple |
| `actor_00C251` | $C251 | `speed_zone_ns_fast` *(unused)* | N-S | `#7` | ✓ | **None** — dead duplicate |

**Notes:** Pure 65C816 (no COP commands, no includes). `actor_00C251` has no scene references and should remain in `unused/`.

### 3.3 Dream Sequence

| Current Name | Address | Suggested Name | Purpose | Movable |
|--------------|---------|----------------|---------|---------|
| `actor_00C1AA` | $C1AA | `dream_zoom_controller` | Gold Ship dream: scroll/zoom countdown `$A0`→`$40` | ✓ |

### 3.4 Rewards & Collectibles

| Current Name | Address | Suggested Name | Purpose | Movable |
|--------------|---------|----------------|---------|---------|
| `actor_00C2BB` | $C2BB | `red_jewel_reward_handler` | Maps `$scene_current` to reward tier; increments HP/STR/DEF | ✓ (with `reward_table_01AADE`) |
| `actor_00DA78` | $DA78 | `field_reveal_object` | Animated reveal/collectible; moves toward player; spawns push handler | ✓ (with includes) |

### 3.5 Player Transition Handlers

| Current Name | Address | Suggested Name | Purpose | Movable |
|--------------|---------|----------------|---------|---------|
| `entry_points_00C418` | $C418 | `player_transition_handlers` | Library of COP scripts for cutscene/warp player animations | **No** (widely referenced via `$&`) |

Sub-functions within this block:

| Part | Address | Suggested Name | Behavior |
|------|---------|----------------|----------|
| `func_00C418` | $C418 | `SpawnSparkleEffect` | Spawns sparkle anim |
| `func_00C432` | $C432 | `HoldPlayerSpriteLoop1` | Loops player sprite frame `#01` |
| `func_00C43D` | $C43D | `HoldPlayerSpriteLoop11` | Loops player sprite frame `#11` |
| `func_00C446` | $C446 | `HoldBodySpriteLoop` | Body sprite `#04`, frame `#1F` |
| `func_00C455` | $C455 | `HoldBodySpriteRelease` | Release from body hold |
| `func_00C45A` | $C45A | `RestorePlayerControlDirect` | JML to `$@code_02C3C8` |
| `func_00C45E` | $C45E | `PlayerWakeAnim` | Body `#04`, frame `#20`, anim once |
| `func_00C46D` | $C46D | `PlayerWakeReturn` | Wake anim → normal control |
| `func_00C479` | $C479 | `WarpClimbAnim` | Vertical climb + sound |
| `func_00C4D1` | $C4D1 | `GardenJumpAnim` | Sky Garden ledge jump + flip |
| `func_00C557` | $C557 | `FallIntoHoleAnim` | Fall through hollow tile |

### 3.6 Combat / Knockback

| Current Name | Address | Suggested Name | Purpose | Movable |
|--------------|---------|----------------|---------|---------|
| `actor_00D877` | $D877 | `hit_stagger_controller` | Spawned on hit; applies knockback; restores AI or returns player to normal | ✓ (as parts block) |

### 3.7 Push / Interaction Handlers

Three variants sharing `$@func_03F0CA` (direction probe) and `chunk_03BAE1`:

| Current Name | Address | Suggested Name | Distinct Behavior | Movable |
|--------------|---------|----------------|--------------------|---------|
| `actor_00E155` | $E155 | `push_handler_light` | Nudges linked actor ±2 px; no solid changes | ✓ |
| `actor_00E256` | $E256 | `push_handler_solid` | Requires ≥32 px offset; clears/sets solid tiles | ✓ |
| `actor_00E3BA` | $E3BA | `push_handler_forceball` | Uses `AddPosition`; requires player anim `$003A`–`$003D` | ✓ |

### 3.8 Smooth Follow (Homing)

| Current Name | Address | Suggested Name | Purpose | Movable |
|--------------|---------|----------------|---------|---------|
| `actor_00E4DB` | $E4DB | `smooth_follow_child` | Spawns child that homes toward target via angle/step math | **No** (`$&` refs to `smooth_follow`) |

### 3.9 Visual Effect Pipeline

Three actors forming a camera/scroll effect subsystem:

| Current Name | Address | Suggested Name | Role | Movable |
|--------------|---------|----------------|------|---------|
| `actor_00E8D7` | $E8D7 | `effect_velocity_init` | Converts spawn coords to velocity; seeds `$06C8`/`$06C4` | ✓ |
| `actor_00E98B` | $E98B | `effect_subpixel_math` | Multiply/divide helper for scroll values | ✓ |
| `actor_00E9EC` | $E9EC | `effect_position_update` | Integrates velocity; clamps to bounds | ✓ |

**Pipeline:** `actor_00EAED` (camera deltas) → `actor_00E8D7` (init velocity) → `actor_00E9EC` (integrate) → `actor_00E98B` (subpixel)

### 3.10 Location-Specific

| Current Name | Address | Suggested Name | Purpose | Movable | Scene |
|--------------|---------|----------------|---------|---------|-------|
| `actor_00C62D` | $C62D | `freejia_street_prop` | Interactive scenery; solid tile + sound on button press | ✓ | Freejia (scene $32) |

### 3.11 Statue / Inventory System Actors

| Current Name | Address | Suggested Name | Purpose | Movable | Scene |
|--------------|---------|----------------|---------|---------|-------|
| `actor_00CD59` | $CD59 | `statue_inventory_reward` | Scene $FD: Grants statue collectibles; event flag check → item display → fanfare → sparkle FX → restore prior scene. Contains shared data `unk19_00CE97` (6×3-byte slot table). 6 COP scripts including animated pickup children. | ✓ | statue_inventory ($FD) |
| `actor_00CF29` | $CF29 | `inventory_statue_slot` | Scene $FF: Displays collected statue items in inventory menu. Reads slot index, checks flag via shared `unk19_00CE97`, shows/hides based on `$0AFA` state. Depends on `actor_00CD59` via `?INCLUDE`. | ✓ | inventory ($FF) |

**Dependencies:** Both include `chunk_03BAE1`, `cop_handlers_script`, `inventory_spritemap`. `actor_00CF29` includes `actor_00CD59` for shared table access.

### 3.12 Stat Reward Actors

| Current Name | Address | Suggested Name | Purpose | Movable |
|--------------|---------|----------------|---------|---------|
| `reward_actors` (block) | $E02D–$E155 | `stat_reward_actors` | Three level-up event actors spawned after combat rewards |  ✓ |
| — `e_hp_increase` | $E02D | — | Increments `$0ACA` (HP), clamps at `$0255`, prints "HP increased" | — |
| — `e_str_increase` | $E06B | — | Increments `$0ADE` (STR), prints message | — |
| — `e_def_increase` | $E0A6 | — | Increments `$0ADC` (DEF), prints message | — |
| — `func_00E110` | $E110 | `RewardActorVFX` | Shared reward VFX: sprite bounce toward player, sound $25, set flag `$0300` | — |

**Scene:** Global — spawned from `StandardEnemyDefeatHandler` (`func_00DB8A`) via `COP [SpawnLastRel]`, never placed directly in scene_actors.

### 3.13 Ramps & Collision Actors

| Current Name | Address | Suggested Name | Purpose | Movable | Scene |
|--------------|---------|----------------|---------|---------|-------|
| `large_ramps` | $C963 | `large_ramp_booster` | Accelerates player speed ±1 when within 2-tile proximity on active ramp. Distinct from `ramps.asm` directional ramp system. Pure 65C816, no COP commands, no includes. | **No** | Incan Ruins ($22), Diamond Mine ($41) |

---

## 4. Function Analysis

### 4.1 Game Over / Death Sequence (Group A)

| Current Name | Address | Suggested Name | Purpose | Movable | Call Type |
|--------------|---------|----------------|---------|---------|-----------|
| `func_00F3B3` | $F3B3 | `StopPlayerOnDeathAssign` | Zeros player speed; sets `$0200` flag | ✓ | JSL |
| `func_00D62F` | $D62F | `GameOverSequence` | Full death flow: fade, palette, reload saved scene | **No** (inbound `$&`) | Pointer assignment |
| `func_00B5B3` | $B5B3 | `DeathPaletteFadeThinker` | Death palette fade (spawned by GameOver) | ✓ | COP `SpawnThinker` |
| `func_00D718` | $D718 | `GameOverCutsceneSprites` | Post-death visual: 3 marked sprite actors | ✓ | COP `SpawnAfter` |

**Death sequence flow:** `StopPlayerOnDeathAssign` → `GameOverSequence` → spawns `DeathPaletteFadeThinker` + `GameOverCutsceneSprites`

### 4.2 Enemy Defeat Pipeline (Group B)

| Current Name | Address | Suggested Name | Purpose | Movable | Call Type |
|--------------|---------|----------------|---------|---------|-----------|
| `func_00DB8A` | $DB8A | `StandardEnemyDefeatHandler` | Central enemy death: kill counters, flash, drops, rewards | **No** (inbound `$&`) | Pointer / COP `JumpScript` |
| `func_00DD5B` | $DD5B | `EnemyRewardChestRouter` | Routes reward type 1/2/other to chest variants | **No** (embedded) | Internal JSR |
| `func_00DD87` | $DD87 | `EnemyStatBonusReward` | Scene-indexed HP/STR/DEF reward spawner | **No** (embedded) | Internal JSR |
| `func_00DDF2` | $DDF2 | `SpawnItemDropPickup` | Animated item drop from enemy flag | ✓ | COP `SpawnLastRel` |
| `func_00DF15` | $DF15 | `EnemyDeathFlash` | Brief white-flash metasprite | ✓ | COP `SpawnLastRel` |
| `func_00DF29` | $DF29 | `EnemyRewardChestSystem` | Treasure chest spawner + 6 variant handlers | ✓ | COP `SpawnLastRel` |
| `stub_00DC77` | $DC77 | `NullActorScriptStub` | Immediate `COP Die` — default actor script | **No** (inbound `$&`) | Pointer assignment |

**Defeat pipeline flow:** Enemy `OnDeath` → `StandardEnemyDefeatHandler` → `EnemyDeathFlash` + optionally `SpawnItemDropPickup` → `EnemyRewardChestRouter` or `EnemyStatBonusReward` → chest/stat actors

`func_00DF29` contains multiple sub-functions:

| Part | Address | Suggested Name |
|------|---------|----------------|
| `func_00DF29` | $DF29 | `SpawnRewardChestType1` |
| `func_00DF38` | $DF38 | `SpawnRewardChestType1Alt` |
| `func_00DF52` | $DF52 | `SpawnRewardChestType2` |
| `func_00DF61` | $DF61 | `SpawnRewardChestType2Alt` |
| `func_00DF7B` | $DF7B | `SpawnRewardChestWeighted` |
| `func_00DFC9` | $DFC9 | `SpawnRewardChestHP` |
| `func_00DFE3` | $DFE3 | `SpawnRewardChestDEF` |

### 4.3 Combat Visual Effects (Group C)

| Current Name | Address | Suggested Name | Purpose | Movable | Call Type |
|--------------|---------|----------------|---------|---------|-----------|
| `func_00DCB4` | $DCB4 | `SpawnAttackTrailEffect` | 16-frame hit trail via `$@func_03BAF1` | ✓ | COP `SpawnLastRel` |
| `func_00DD03` | $DD03 | `SpawnHitSparkSprites` | OAM spark entries for critical-hit feedback | ✓ | COP `SpawnLastRel` |

### 4.4 Player / Party State (Group D)

| Current Name | Address | Suggested Name | Purpose | Movable | Call Type |
|--------------|---------|----------------|---------|---------|-----------|
| `func_00C397` | $C397 | `ApplyPlayerHitstun` | Damage knockback: stun timer, spawn hit actor, mask joypad | ✓ | JSL (~12 callers) |
| `func_00C6E4` | $C6E4 | `InitPlayerScriptVariant` | Selects player COP script variant from table | ✓ (with table) | JSL (~15 scenes) |
| `func_00C806` | $C806 | `EscortFollowPathTracker` | Ring buffer of 9 XY waypoints for party escort | ✓ (with array) | COP `SpawnAfterFlags` |

### 4.5 NPC Wander AI (Group E)

| Current Name | Address | Suggested Name | Purpose | Movable | Call Type |
|--------------|---------|----------------|---------|---------|-----------|
| `func_00C718` | $C718 | `SyncActorPosFromDP` | Copies `$14`/`$16` to actor WRAM | ✓ | JSL |
| `func_00C725` | $C725 | `NpcRandomWanderAI` | RNG 8-direction walk with collision | ✓ (with codes) | JSL |
| `func_00C7FA` | $C7FA | `ToggleActorVisibilityFlag` | XOR `$2000` on referenced actor | ✓ | COP `SpawnAfterAbsFlags` |

### 4.6 Ambient Motion (Group F)

| Current Name | Address | Suggested Name | Purpose | Movable | Call Type |
|--------------|---------|----------------|---------|---------|-----------|
| `func_00CF8E` | $CF8E | `CameraDriftLoopSimple` | 120-frame random ±1..2 camera nudge | ✓ | COP `SpawnAfterFlags` |
| `func_00CFAE` | $CFAE | `CameraDriftLoopShip` | Camera drift gated by `$player_flags` | ✓ | COP `SpawnAfterFlags` |
| `func_00CFEF` | $CFEF | `CameraDriftPatterned` | Direction-table camera drift (boss arenas) | ✓ (with `binary_00D068`) | COP `SpawnLastRel` |
| `func_00C9B8` | $C9B8 | `SpawnDebrisBurst` | 8 RNG-scattered sparkle actors | ✓ | COP `SpawnAfterFlags` |

### 4.7 Orbital / Circular Math (Group G)

| Current Name | Address | Suggested Name | Purpose | Movable | Call Type |
|--------------|---------|----------------|---------|---------|-----------|
| `func_00F3C9` | $F3C9 | `ApplyOrbitalOffsetFromRef` | Sin/cos offset from reference actor (**⚠ misplaced in `unused/`**) | ✓ | JSL (~15+ refs) |
| `func_00F432` | $F432 | `ApplyOrbitalOffsetXY` | Sin/cos offset using separate X/Y angle bytes | ✓ | JSL (~3 callers) |
| `func_00F428` | $F428 | `CopyRefActorPos` *(dead)* | Stub between F3B3 and F3C9 | — | — |

### 4.8 Unused / Dead Functions

| Current Name | Address | Suggested Name | Reason Unused |
|--------------|---------|----------------|---------------|
| `func_00B528` | $B528 | `SceneTransPaletteThinker_unused` | No references (noref) |
| `func_00DC79` | $DC79 | `AttackTrailShort_unused` | No references; variant of `func_00DCB4` |
| `func_00E655` | $E655 | `InitSmoothFollowChase_unused` | No references; spawns `@InitFollowAndChase` |
| `func_00F3C9` | $F3C9 | **⚠ MISPLACED — LIVE CODE** | 15+ active references — see §8.1 |
| `func_00F428` | $F428 | `CopyRefActorPos_dead` | Dead entry stub |

### 4.9 Inventory / Message Utilities

| Current Name | Address | Suggested Name | Purpose | Movable | Call Type |
|--------------|---------|----------------|---------|---------|-----------|
| `f_inventory_full` | $C98E | `InventoryFullMessage` | Prints "Your inventory is full. You can't carry more." Pure text utility. No includes, no dependencies. | ✓ | JML (from 10+ scene scripts) |
| `death_message` | $D796 | `DeathWakeupMessage` | Post-death wake-up monologue: branches on `$0AD4` (Will/Freedan/Shadow) for character-specific text. Spawned from `player_character.asm`. | ✓ | COP `SpawnAfterFlags` |

---

## 5. Logical Groupings

### Group 1: Palette System ($B520–$B7FE)

**Theme:** Ambient palette cycling, COLDATA tints, one-shot flashes

Contains 20 thinkers that should be logically grouped:
- **Ambient cyclers:** `ambient_palette_cycler`, `flag_gated_palette_warm/cool`, `palette_parent_child`
- **Scene-specific palettes:** `edward_castle_alarm`, `incan_ruins_transform`, `dream_palette_loop`, `palace_fountain`, `watermia_festival`
- **One-shot flashes:** 8 thinkers (`#18`/`#19`, `#1B`/`#1C`, `#40`, `#1F`, COLDATA warm/green)

**Notes:** All are self-contained (no `?INCLUDE`). The one-shot flashes form natural pairs (`#18`/`#19` = blinding light in/out, `#1B`/`#1C` = dungeon spirit).

### Group 2: HDMA Wave Effects ($BCB3–$BEF2)

**Theme:** Sine-based HDMA oscillation for water/fog/distortion effects

Contains 11 thinkers arranged by scene:
- **Template:** `sine_hdma_slow_wave` ($BE18)
- **Comet set:** `ending_comet_sine_hdma` → `comet_lair_hdma_a/b/c`
- **Regional:** `larai_cliff_scroll_wave`, `mu_tint_and_wave`, `palace_coffin_hdma_table`, `dao_sine_hdma_slow`, `native_village_sine_hdma`

### Group 3: Combat System ($C397, $D62F–$DFFF)

**Theme:** Player damage, enemy defeat, drops, rewards, death sequence

Contains 14 functions forming a complete combat resolution pipeline:
- **Player damage:** `ApplyPlayerHitstun` → `hit_stagger_controller`
- **Enemy defeat:** `StandardEnemyDefeatHandler` → `EnemyDeathFlash` → drops/rewards
- **Game over:** `StopPlayerOnDeathAssign` → `GameOverSequence` → fade/reload
- **Visual FX:** `SpawnAttackTrailEffect`, `SpawnHitSparkSprites`

### Group 4: Interaction Library ($E155–$E3BA)

**Theme:** Button-press push mechanics for objects/statues/forceballs

Three push handler variants that share `$@func_03F0CA` and `chunk_03BAE1`. All movable, all self-contained.

### Group 5: NPC Behavior ($C718–$C806)

**Theme:** Town NPC wander AI and party escort pathfinding

- `SyncActorPosFromDP` + `NpcRandomWanderAI` always called together
- `EscortFollowPathTracker` used for Kara/party following
- `ToggleActorVisibilityFlag` for show/hide in palace rooms

### Group 6: Camera & Scene Effects ($CF8E–$CFEF, $E8D7–$EAED)

**Theme:** Camera drift, visual effect velocity, subpixel math

- Camera drift functions for ambient motion (bosses, ships)
- Effect pipeline actors for Viper Lair / Dark Space scroll effects
- `camera_scroll_controller` feeds all of these

### Group 7: Orbital Math ($F3B3–$F432)

**Theme:** Sin/cos circular motion for actors

Two orbital offset functions (`ApplyOrbitalOffsetFromRef`, `ApplyOrbitalOffsetXY`) plus death-assignment prelude.

---

## 6. Rename Map

Complete suggested rename table for all auto-named blocks:

### Thinkers

| Current | Suggested | Priority |
|---------|-----------|----------|
| `thinker_00B520` | `ambient_palette_cycler` | **High** (most-used thinker) |
| `thinker_00B5C0` | `flag_gated_palette_warm` | Medium |
| `thinker_00B5DF` | `flag_gated_palette_cool` | Medium |
| `thinker_00B5FE` | `palette_parent_child` | Medium |
| `thinker_00B631` | `edward_castle_alarm_palette` | Medium |
| `thinker_00B65E` | `oneshot_coldata_warm_flash` | Low |
| `thinker_00B671` | `incan_ruins_transform_palette` | Medium |
| `thinker_00B6D2` | `dream_palette_loop` | Medium |
| `thinker_00B6E5` | `oneshot_coldata_green_tint` | Low |
| `thinker_00B6FD` | `palette_buffer_clear_unused` | Low (unused) |
| `thinker_00B71E` | `palace_fountain_palette` | Medium |
| `thinker_00B754` | `watermia_festival_palette` | Medium |
| `thinker_00B781` | `babel_palette_65_unused` | Low (unused) |
| `thinker_00B78F` | `babel_elevator_color_add` | Low |
| `thinker_00B79D` | `palace_scroll_brightness` | Low |
| `thinker_00B7BE` | `dao_window_mask` | Low |
| `thinker_00B808` | `palette_loop_flash_unused` | Low (unused) |
| `thinker_00B818` | `itory_village_fog` | Medium |
| `thinker_00B83F` | `boot_logo_palette_enix` | Low |
| `thinker_00B853` | `boot_logo_palette_quintet` | Low |
| `thinker_00B867` | `boot_logo_palette_third` | Low |
| `thinker_00B87B` | `angel_tunnel_window_dma` | Low |
| `thinker_00BB8E` | `inventory_dma_setup` | Low |
| `thinker_00BBAF` | `diary_menu_window_dma` | Medium |
| `thinker_00BC97` | `dma_setup_variant_unused` | Low (unused) |
| `thinker_00BCB3` | `ending_comet_sine_hdma` | Medium |
| `thinker_00BCDF` | `ending_comet_dma_setup` | Low |
| `thinker_00BCF5` | `comet_lair_hdma_a` | Medium |
| `thinker_00BD21` | `comet_lair_hdma_b` | Medium |
| `thinker_00BD42` | `comet_lair_hdma_c_timed` | Medium |
| `thinker_00BD96` | `larai_cliff_scroll_wave` | Medium |
| `thinker_00BDCA` | `empty_stub_unused` | Low (unused) |
| `thinker_00BDCD` | `mu_tint_and_wave` | Medium |
| `thinker_00BE18` | `sine_hdma_slow_wave` | Medium |
| `thinker_00BE39` | `palace_coffin_hdma_table` | Medium |
| `thinker_00BE83` | `sine_hdma_dual_channel` | Medium |
| `thinker_00BEAA` | `native_village_dup_unused` | Low (unused) |
| `thinker_00BED1` | `dao_sine_hdma_slow` | Low |
| `thinker_00BEF2` | `native_village_sine_hdma` | Medium |
| `thinker_00BF19` | `sine_hdma_ending_wave` | Medium |
| `thinker_00BF52` | `gen_hdma_sine_oneshot_unused` | Low (unused) |
| `thinker_00BF78` | `dark_castoth_layer_config` | Low |
| `thinker_00BF89` | `global_ambient_dispatcher` | **High** (present in every scene) |

### Actors

| Current | Suggested | Priority |
|---------|-----------|----------|
| `actor_00C1AA` | `dream_zoom_controller` | Medium |
| `actor_00C1DF` | `speed_zone_ew_slow` | Medium |
| `actor_00C218` | `speed_zone_ew_fast` | Medium |
| `actor_00C251` | `speed_zone_ns_fast_unused` | Low (unused) |
| `actor_00C286` | `speed_zone_ns_slow` | Medium |
| `actor_00C2BB` | `red_jewel_reward_handler` | **High** |
| `actor_00C62D` | `freejia_street_prop` | Low |
| `actor_00C667` | `scene_flag_init` | **High** (global infrastructure) |
| `actor_00D877` | `hit_stagger_controller` | **High** |
| `actor_00DA78` | `field_reveal_object` | Medium |
| `actor_00E155` | `push_handler_light` | **High** |
| `actor_00E256` | `push_handler_solid` | **High** |
| `actor_00E3BA` | `push_handler_forceball` | Medium |
| `actor_00E4DB` | `smooth_follow_child` | **High** |
| `actor_00E8D7` | `effect_velocity_init` | Medium |
| `actor_00E98B` | `effect_subpixel_math` | Medium |
| `actor_00E9EC` | `effect_position_update` | Medium |
| `actor_00EAED` | `camera_scroll_controller` | **High** (100+ scenes) |

### Functions

| Current | Suggested | Priority |
|---------|-----------|----------|
| `func_00B5B3` | `DeathPaletteFadeThinker` | Medium |
| `func_00C397` | `ApplyPlayerHitstun` | **High** |
| `func_00C6E4` | `InitPlayerScriptVariant` | **High** |
| `func_00C718` | `SyncActorPosFromDP` | Medium |
| `func_00C725` | `NpcRandomWanderAI` | **High** |
| `func_00C7FA` | `ToggleActorVisibilityFlag` | Medium |
| `func_00C806` | `EscortFollowPathTracker` | **High** |
| `func_00C9B8` | `SpawnDebrisBurst` | Medium |
| `func_00CF8E` | `CameraDriftLoopSimple` | Medium |
| `func_00CFAE` | `CameraDriftLoopShip` | Medium |
| `func_00CFEF` | `CameraDriftPatterned` | Medium |
| `func_00D62F` | `GameOverSequence` | **High** |
| `func_00D718` | `GameOverCutsceneSprites` | Medium |
| `func_00DB8A` | `StandardEnemyDefeatHandler` | **High** |
| `func_00DD5B` | `EnemyRewardChestRouter` | Medium |
| `func_00DD87` | `EnemyStatBonusReward` | Medium |
| `stub_00DC77` | `NullActorScriptStub` | Medium |
| `func_00DCB4` | `SpawnAttackTrailEffect` | Medium |
| `func_00DD03` | `SpawnHitSparkSprites` | Medium |
| `func_00DDF2` | `SpawnItemDropPickup` | **High** |
| `func_00DF15` | `EnemyDeathFlash` | Medium |
| `func_00DF29` | `EnemyRewardChestSystem` | **High** |
| `func_00F3B3` | `StopPlayerOnDeathAssign` | Medium |
| `func_00F3C9` | `ApplyOrbitalOffsetFromRef` | **High** (misplaced) |
| `func_00F432` | `ApplyOrbitalOffsetXY` | Medium |

---

## 7. Movability Assessment

### Immovable Blocks (external `$&` short references)

These blocks are referenced by other code via `$&` (2-byte same-bank pointer) and **cannot** be relocated without updating all callers:

| Block | Inbound `$&` From | Reason |
|-------|-------------------|--------|
| `func_00D62F` | `chunk_03BAE1` | Player death pointer assignment `$&func_00D62F` |
| `func_00DB8A` | `chunk_03BAE1`, `actor_00D877` | Enemy defeat pointer `$&func_00DB8A` |
| `stub_00DC77` | `chunk_03BAE1` (`func_03C524`) | Default actor script `$&stub_00DC77` |
| `entry_points_00C418` | 15+ consumers | Player anim `#$&func_00C4xx` references |
| `actor_00E4DB` | Pyramid blaster, Angkor, etc. | `#$&actor_00E4DB-1` hard refs |
| `thinker_00BF89` | — | `?INCLUDE 'chunk_03BAE1'` + `$player_actor` |
| `thinker_00B818` | — | References `$player_actor` |

### Fully Self-Contained (True Movability)

These blocks have **no `?INCLUDE`, no `$&` external refs**, and only use `$@` long references:

| Category | Count | Examples |
|----------|-------|---------|
| Thinkers | 42/49 | All palette cyclers, all HDMA waves, all one-shots |
| Actors | 12/20 | Speed zones, dream controller, push handlers, effect actors |
| Functions | 17/27 | Camera drift, debris burst, death flash, orbital math |

### Conditionally Movable (co-located data)

Must move with embedded tables/binaries as a unit:

| Block | Co-located Data |
|-------|-----------------|
| `func_00C6E4` | `table_00C710` (4-entry player script pointer table) |
| `func_00C725` | `code_list_00C733` + direction handler blocks |
| `func_00C806` | `array_00C943` (direction delta table) |
| `func_00CFEF` | `binary_00D068` (8 direction deltas) |
| `func_00DD03` | `code_00DD1D` (spark builder sub) |
| `func_00DF29` | `array_00DFFD` + 6 variant funcs |

---

## 8. Errors & Issues

### 8.1 ⚠ CRITICAL: `func_00F3C9` Misplaced in `unused/`

**`func_00F3C9` (`ApplyOrbitalOffsetFromRef`) is actively referenced by 15+ callers** including:
- `cop_handlers_collision.asm` (camera pan COP)
- `chunk_038000.asm`
- Castoth boss
- Fire sprite actors
- Statue inventory

This function was originally in `extracted/unused/` and `blocks.json` marked it as unused, which was incorrect — it has live `$@func_00F3C9` references throughout the codebase.

**Action:** ✅ **RESOLVED** — Moved to `functions` section in `blocks.json` (2026-09-06). Will appear in `extracted/functions/` on next extraction.

### 8.2 Scene Tag Audit (Verified Against scene_actors.asm)

The following scene tags have been verified against `scene_actors.asm` and `scene_thinkers.asm`:

| Block | `scene` Tag | Verified | Notes |
|-------|-------------|----------|-------|
| `speed_zone_ew_fast` (was `actor_00C218`) | `kress_maze` | ✓ | Only scene #A7 — tag is correct |
| `dream_zoom_controller` (was `actor_00C1AA`) | `dream` | ✓ | Scene #2A only |
| `freejia_street_prop` (was `actor_00C62D`) | `freejia` | ✓ | Scene #32 only |
| `statue_inventory_reward` (was `actor_00CD59`) | `statue_inventory` | ✓ | Scene #FD only |
| `inventory_statue_slot` (was `actor_00CF29`) | `inventory` | ✓ | Scene #FF only |
| `camera_scroll_controller` (was `actor_00EAED`) | *(none — global)* | ✓ | 235 scenes — correctly untagged |
| `scene_flag_init` (was `actor_00C667`) | *(none — global)* | ✓ | 26+ scenes — correctly untagged |
| `red_jewel_reward_handler` (was `actor_00C2BB`) | *(none — global)* | ✓ | 5 distinct scenes — correctly untagged |
| `large_ramp_booster` (`large_ramps`) | *(none)* | ✓ | 2 scenes (#22, #41) — correctly untagged |

**Runtime-only actors** (no scene_actors entries — spawned dynamically): `hit_stagger_controller`, `field_reveal_object`, `push_handler_light/solid/forceball`, `smooth_follow_child`, `effect_subpixel_math`, `reward_actors`. This is expected behavior.

### 8.3 Duplicate Code

| Live Version | Duplicate | Status |
|--------------|-----------|--------|
| `thinker_00BEF2` | `thinker_00BEAA` | Byte-identical; `00BEAA` has no references |
| `func_00DCB4` | `func_00DC79` | `00DC79` is shorter variant with no references |
| `func_00F3C9` | `func_00E655` | `00E655` wraps `00F3C9` with no direct callers |

### 8.4 Potential Boundary Issues

| Block | Issue | Recommendation |
|-------|-------|----------------|
| `actor_00D877` parts | 7 parts (`e_actor`, `func_00D904`, `func_00D9EB`, `sub_00DA13/41/47/66`) span $D877–$DA66 but some are internal-only subs | Keep as single parts block — all `$&`-linked internally |
| `func_00DB8A` parts | Contains `func_00DD5B` and `func_00DD87` as separate parts but they're only called via internal `$&` | Correct — must remain as multi-part block |
| `func_00DF29` | 7 variant functions in one file span $DF29–$DFFF + `array_00DFFD` | Consider grouping as `enemy_reward_chest_system` block with all parts |

### 8.5 Missing Block Entries

The following code exists between mapped blocks but isn't explicitly defined in `blocks.json`:

| Address | Content | Suggestion |
|---------|---------|------------|
| $B528–$B5B3 | `func_00B528` (unused palette thinker) | Already in `unused` section — correct |
| $DC77–$DC79 | `stub_00DC77` | Has entry but lacks descriptive name |

---

## 9. Split / Merge Recommendations

### 9.1 Merge: Speed Zone Actors → `movement_speed_zones`

**Current:** 4 separate single-block entries (`actor_00C1DF`, `actor_00C218`, `actor_00C251`, `actor_00C286`)
**Recommendation:** Merge into one parts block `movement_speed_zones`:

```json
"movement_speed_zones": {
    "movable": true,
    "scene": "mountain_temple",
    "parts": {
        "speed_zone_ew_slow": { "start": 49631, "end": 49688, "type": "actor_def" },
        "speed_zone_ew_fast": { "start": 49688, "end": 49745, "type": "actor_def" },
        "speed_zone_ns_slow": { "start": 49798, "end": 49851, "type": "actor_def" }
    }
}
```
(`actor_00C251` stays in `unused`)

**Rationale:** All four are identical in structure, differ only in axis/sign. They're all placed in Mountain Temple scenes.

### 9.2 Merge: Push Handlers → `push_interaction_handlers`

**Current:** 3 separate blocks (`actor_00E155`, `actor_00E256`, `actor_00E3BA`)
**Recommendation:** Merge into one parts block:

```json
"push_interaction_handlers": {
    "movable": true,
    "parts": {
        "push_handler_light": { "start": 57685, "end": 57942, "type": "Code" },
        "push_handler_solid": { "start": 57942, "end": 58298, "type": "Code" },
        "push_handler_forceball": { "start": 58298, "end": 58587, "type": "Code" }
    }
}
```

**Rationale:** Functionally related variants of the same system. All three include `chunk_03BAE1` and use `$@func_03F0CA`.

### 9.3 Merge: Effect Pipeline → `visual_effect_pipeline`

**Current:** 3 separate blocks (`actor_00E8D7`, `actor_00E98B`, `actor_00E9EC`)
**Recommendation:** Merge into one parts block:

```json
"visual_effect_pipeline": {
    "movable": true,
    "parts": {
        "effect_velocity_init": { "start": 59607, "end": 59725, "type": "actor_def" },
        "effect_subpixel_math": { "start": 59787, "end": 59884, "type": "Code" },
        "effect_position_update": { "start": 59884, "end": 60054, "type": "actor_def" }
    }
}
```

**Rationale:** These three actors form a pipeline and are always used together.

### 9.4 Merge: Camera Drift Functions → `camera_drift`

**Current:** 3 separate blocks (`func_00CF8E`, `func_00CFAE`, `func_00CFEF`)
**Recommendation:** Merge with `binary_00D068`:

```json
"camera_drift": {
    "movable": true,
    "parts": {
        "CameraDriftLoopSimple": { "start": 53134, "end": 53166, "type": "Code" },
        "CameraDriftLoopShip": { "start": 53166, "end": 53231, "type": "Code" },
        "CameraDriftPatterned": { "start": 53231, "end": 53352, "type": "Code" },
        "binary_00D068": { "start": 53352, "end": 53384, "type": "Binary" }
    }
}
```

**Rationale:** Three variants of the same camera-drift behavior; `func_00CFEF` requires `binary_00D068`.

### 9.5 Merge: Game Over Functions → `game_over_sequence`

**Current:** 4 separate blocks (`func_00D62F`, `func_00D718`, `func_00B5B3`, `func_00F3B3`)
**Recommendation:** Group as related (but `func_00D62F` is not movable):

```json
"game_over_sequence": {
    "movable": false,
    "parts": {
        "GameOverSequence": { "start": 54831, "end": 55064, "type": "Code" },
        "GameOverCutsceneSprites": { "start": 55064, "end": 55190, "type": "Code" }
    }
}
```

`func_00B5B3` (`DeathPaletteFadeThinker`) and `func_00F3B3` (`StopPlayerOnDeathAssign`) remain separate as they're self-contained utilities callable independently.

### 9.6 Merge: NPC Wander → `npc_wander_ai`

**Current:** 3 separate blocks (`func_00C718`, `func_00C725`, `func_00C7FA`)
**Recommendation:** Merge `func_00C718` and `func_00C725` (always called together):

```json
"npc_wander_ai": {
    "movable": true,
    "parts": {
        "SyncActorPosFromDP": { "start": 50968, "end": 50981, "type": "Code" },
        "NpcRandomWanderAI": { "start": 50981, "end": 51194, "type": "Code" }
    }
}
```

`func_00C7FA` (`ToggleActorVisibilityFlag`) is conceptually separate and should remain standalone.

### 9.7 Do NOT Split: `func_00DB8A` Block

`func_00DB8A`, `func_00DD5B`, and `func_00DD87` are already correctly grouped as a multi-part block. The internal `$&` references between them make splitting impossible.

### 9.8 Do NOT Merge: One-Shot Palette Thinkers

The 8 one-shot palette thinkers (`$B7CC`–`$B7FE`) are individually spawned by different actor scripts and should remain separate blocks for maximum flexibility.

---

## 10. Cross-Reference Matrix

### Most-Referenced Blocks (within bank $00 upper)

| Block | Ref Count | Primary Callers |
|-------|-----------|-----------------|
| `actor_00EAED` (`camera_scroll_controller`) | 100+ | Every field scene |
| `actor_00C667` (`scene_flag_init`) | 80+ | Most scene templates |
| `func_00C725` (`NpcRandomWanderAI`) | ~12 | Town NPC scripts |
| `func_00DB8A` (`StandardEnemyDefeatHandler`) | ~20 | All enemy actors |
| `func_00C397` (`ApplyPlayerHitstun`) | ~12 | Combat enemies |
| `thinker_00BF89` (`global_ambient_dispatcher`) | ~40 | Nearly every scene set |
| `thinker_00B520` (`ambient_palette_cycler`) | ~30 | Paired with `BF89` |
| `func_00DF15` (`EnemyDeathFlash`) | ~10 | Enemy actors + defeat handler |
| `func_00F3C9` (`ApplyOrbitalOffsetFromRef`) | ~15 | COP handlers, bosses, actors |
| `actor_00E256` (`push_handler_solid`) | ~9 | Statue/archer/knight actors |

### Engine Integration Points

| This Block | Connects To | Via |
|------------|-------------|-----|
| `func_00D62F` | `chunk_03BAE1` | `$&func_00D62F` pointer on player death |
| `func_00DB8A` | `chunk_03BAE1` | `$&func_00DB8A` pointer for enemy defeat |
| `stub_00DC77` | `chunk_03BAE1` | `$&stub_00DC77` default actor script |
| `entry_points_00C418` | `warps_interaction`, `chunk_038000` | `#$&func_00C4xx` references |
| `actor_00D877` | `chunk_03BAE1` | `SpawnLastRel @e_actor_00D877` |
| `actor_00E4DB` | `smooth_follow` | `?INCLUDE 'smooth_follow'`, `$&ComputeFollow*` |
| `thinker_00BF89` | `chunk_03BAE1` | `?INCLUDE 'chunk_03BAE1'` |

### External Bank Dependencies

| From | To | Bank | Purpose |
|------|----|------|---------|
| Most actors | `func_03F0CA` | $03 | Player facing lookup |
| Most actors | `func_03CA55` | $03 | Advance animation frame |
| Most actors | `func_03BAF1` | $03 | Sprite factory |
| `func_00C806` | `func_03F0CA` | $03 | Layer lookup for escort |
| `func_00C397` | `e_actor_00D877` | $00 | Spawn knockback actor |
| `func_00F3C9/F432` | `binary_01C455/495` | $01 | Sin/cos lookup tables |
| `func_00F3C9/F432` | `hardware_math` | $02 | Signed multiply |
| `func_00D62F` | Scene state vars | $00 | `$0AF0`–`$0AF8` save data |

---

*Generated from deep analysis of 96 code blocks in bank $00 upper half ($B500–$F4FF) of Illusion of Gaia US ROM.*
*Cross-referenced with `us/blocks.json`, `us/names.json`, `extracted/` ASM files, and `chunk_008000-analysis.md`.*

---

## 11. Applied Changes

### 11.1 blocks.json Renames (2026-09-06)

All 96 block-level key renames applied across the following sections:

| Section | Count | Examples |
|---------|-------|---------|
| `actors` | 13 | `red_jewel_reward_handler`, `hit_stagger_controller`, `camera_scroll_controller`, `player_transition_handlers` |
| `system` | 2 | `statue_inventory_reward`, `inventory_statue_slot` |
| `thinkers` | 19 | `ambient_palette_cycler`, `global_ambient_dispatcher`, `sine_hdma_slow_wave` |
| Scene-tagged thinkers | 18 | `edward_castle_alarm_palette`, `dream_palette_loop`, `palace_fountain_palette` |
| `functions` | 22 | `ApplyPlayerHitstun`, `StandardEnemyDefeatHandler`, `EnemyRewardChestSystem` |
| `unused` | 12 | `speed_zone_ns_fast_unused`, `ApplyOrbitalOffsetFromRef`, `AttackTrailShort_unused` |
| Scene-tagged actors | 4 | `speed_zone_ew_slow`, `speed_zone_ns_slow`, `dream_zoom_controller` |
| System thinkers | 6 | `boot_logo_palette_enix`, `inventory_dma_setup`, `angel_tunnel_window_dma` |

**Part-level keys** inside multi-part blocks were intentionally left unchanged — they will update automatically on next extraction after names.json is applied.

### 11.2 names.json Additions (2026-09-06)

**104 new entries** added, bringing total from 617 to 721 entries.

| Address Range | Count | Category |
|---------------|-------|----------|
| 46368–49033 | 55 | Thinker addresses (palette cyclers, HDMA waves, DMA setup, dispatchers) |
| 49578–53231 | 22 | Actor addresses (speed zones, rewards, inventory, camera drift) |
| 54831–58587 | 25 | Function addresses (game over, combat, push handlers, follow) |
| 59607–60141 | 4 | Effect pipeline actors |
| 62387–62514 | 3 | Post-smooth-follow (orbital math, death assignment) |

### 11.3 Cross-Reference with chunk_008000-analysis.md

The following connections were identified between the system core (§chunk_008000) and this upper-half analysis:

| System Core Reference | Upper-Half Block | Connection Type |
|-----------------------|------------------|-----------------|
| `func_00F3C9` (included by system core) | `ApplyOrbitalOffsetFromRef` | System core `?INCLUDE` → lives in upper half at $F3C9 |
| `ActorPoolAllocator` ($B501) | `PaletteResetAndKillThinker` ($B519) | Adjacent code — allocator ends at B519 where palette helper begins |
| COP `SpawnLastRel` | `reward_actors`, `hit_stagger_controller` | Runtime spawn via system COP commands |
| `SetDeathCallback` COP | `GameOverSequence` ($D62F) | Player death pointer assignment from `chunk_03BAE1` |
| `SetDeathCallback` COP | `StandardEnemyDefeatHandler` ($DB8A) | Enemy defeat pointer assignment |

**No grouping changes needed:** The system core boundary at $B530 cleanly separates the engine from the upper-half actor/thinker/function code. The `func_00F3C9` inclusion is a cross-boundary reference (system core includes an upper-half function), which is architecturally correct.

---

## 12. File → Parts Boundary Table

This table defines the definitive file boundaries for each extracted file in the upper half, including all scaffolded/embedded parts within each ASM file.

### 12.1 Thinker Files ($B520–$BF89)

| File | Block Name | Start | End | Parts (internal labels) | Shared Conventions |
|------|-----------|-------|-----|------------------------|-------------------|
| `ambient_palette_cycler.asm` | `ambient_palette_cycler` | 46368 | 46376 | `thinker_def` header only | Palette COP family |
| `flag_gated_palette_warm.asm` | `flag_gated_palette_warm` | 46528 | 46559 | `thinker_def` + flag-check + palette ops | Palette COP family |
| `flag_gated_palette_cool.asm` | `flag_gated_palette_cool` | 46559 | 46590 | Same structure as warm variant | Palette COP family |
| `palette_parent_child.asm` | `palette_parent_child` | 46590 | 46641 | `thinker_def` + child spawn | Palette COP family |
| `edward_castle_alarm_palette.asm` | `edward_castle_alarm_palette` | 46641 | 46686 | `thinker_def` + COLDATA write | Scene palette |
| `oneshot_coldata_warm_flash.asm` | `oneshot_coldata_warm_flash` | 46686 | 46705 | `thinker_def` + COLDATA + KillThinker | One-shot flash |
| `incan_ruins_transform_palette.asm` | `incan_ruins_transform_palette` | 46705 | 46802 | `thinker_def` + multi-phase palette switch | Scene palette |
| `dream_palette_loop.asm` | `dream_palette_loop` | 46802 | 46821 | `thinker_def` + flag-exit palette loop | Scene palette |
| `oneshot_coldata_green_tint.asm` | `oneshot_coldata_green_tint` | 46821 | 46845 | `thinker_def` + triple COLDATA + kill | One-shot flash |
| `palace_fountain_palette.asm` | `palace_fountain_palette` | 46878 | 46932 | `thinker_def` + CGADSUB + alternating bundles | Scene palette |
| `watermia_festival_palette.asm` | `watermia_festival_palette` | 46932 | 46977 | `thinker_def` + child spawn on flag | Scene palette |
| `babel_elevator_color_add.asm` | `babel_elevator_color_add` | 46991 | 47005 | `thinker_def` + CGADSUB=#02 | HW config |
| `palace_scroll_brightness.asm` | `palace_scroll_brightness` | 47005 | 47038 | `thinker_def` + COLDATA from scroll | HW config |
| `dao_window_mask.asm` | `dao_window_mask` | 47038 | 47052 | `thinker_def` + W12SEL=#02 | HW config |
| `oneshot_palette_flash_18.asm` | `oneshot_palette_flash_18` | 47052 | 47062 | `thinker_def` + single bundle flash | One-shot flash |
| `oneshot_palette_flash_19.asm` | `oneshot_palette_flash_19` | 47062 | 47072 | Same structure | One-shot flash |
| `oneshot_palette_flash_1B.asm` | `oneshot_palette_flash_1B` | 47072 | 47082 | Same structure | One-shot flash |
| `oneshot_palette_flash_1C.asm` | `oneshot_palette_flash_1C` | 47082 | 47092 | Same structure | One-shot flash |
| `oneshot_palette_flash_40.asm` | `oneshot_palette_flash_40` | 47092 | 47102 | Same structure | One-shot flash |
| `oneshot_palette_flash_1F.asm` | `oneshot_palette_flash_1F` | 47102 | 47112 | Same structure | One-shot flash |
| `itory_village_fog.asm` | `itory_village_fog` | 47128 | 47167 | `thinker_def` + player_actor check + CGADSUB | HW config (not self-contained) |
| `boot_logo_palette_enix.asm` | `boot_logo_palette_enix` | 47167 | 47187 | `thinker_def` + 3-stage fade | Boot system |
| `boot_logo_palette_quintet.asm` | `boot_logo_palette_quintet` | 47187 | 47207 | Same structure | Boot system |
| `boot_logo_palette_third.asm` | `boot_logo_palette_third` | 47207 | 47227 | Same structure | Boot system |
| `angel_tunnel_window_dma.asm` | `angel_tunnel_window_dma` | 47227 | 47243 | `thinker_def` + window DMA | Custom DMA |
| `parallax_thinker.asm` | `parallax_thinker` | 47243 | 48014 | Complex: multi-mode parallax with HDMA tables | Custom DMA (large) |
| `inventory_dma_setup.asm` | `inventory_dma_setup` | 48014 | 48047 | `thinker_def` + PPU init sequence | System DMA |
| `diary_menu_window_dma.asm` | `diary_menu_window_dma` | 48047 | 48279 | `thinker_def` + state-machine DMA | System DMA |
| `ending_comet_sine_hdma.asm` | `ending_comet_sine_hdma` | 48307 | 48351 | `thinker_def` + sine HDMA channels #0F/#10 | Sine HDMA |
| `ending_comet_dma_setup.asm` | `ending_comet_dma_setup` | 48351 | 48373 | `thinker_def` + one-shot PPU DMA | Custom DMA |
| `comet_lair_hdma_a.asm` | `comet_lair_hdma_a` | 48373 | 48417 | `thinker_def` + HDMA channel #10 | Sine HDMA |
| `comet_lair_hdma_b.asm` | `comet_lair_hdma_b` | 48417 | 48450 | `thinker_def` + HDMA channel #0F | Sine HDMA |
| `comet_lair_hdma_c_timed.asm` | `comet_lair_hdma_c_timed` | 48450 | 48534 | `thinker_def` + timed HDMA transition | Sine HDMA |
| `larai_cliff_scroll_wave.asm` | `larai_cliff_scroll_wave` | 48534 | 48586 | `thinker_def` + scroll-based wave | Sine HDMA |
| `mu_tint_and_wave.asm` | `mu_tint_and_wave` | 48589 | 48664 | `thinker_def` + dual-channel HDMA | Sine HDMA |
| `sine_hdma_slow_wave.asm` | `sine_hdma_slow_wave` | 48664 | 48697 | `thinker_def` + slow tick #01 | Sine HDMA |
| `palace_coffin_hdma_table.asm` | `palace_coffin_hdma_table` | 48697 | 48771 | `thinker_def` + manual HDMA table build | Custom HDMA |
| `sine_hdma_dual_channel.asm` | `sine_hdma_dual_channel` | 48771 | 48810 | `thinker_def` + dual sine channels | Sine HDMA |
| `dao_sine_hdma_slow.asm` | `dao_sine_hdma_slow` | 48849 | 48882 | `thinker_def` + very slow tick #00 | Sine HDMA |
| `native_village_sine_hdma.asm` | `native_village_sine_hdma` | 48882 | 48921 | `thinker_def` + channels #0E/#10 | Sine HDMA |
| `sine_hdma_ending_wave.asm` | `sine_hdma_ending_wave` | 48921 | 48978 | `thinker_def` + ending wave channel #0F | Sine HDMA |
| `dark_castoth_layer_config.asm` | `dark_castoth_layer_config` | 49016 | 49033 | `thinker_def` + TM/TS set | HW config |
| `global_ambient_dispatcher.asm` | `global_ambient_dispatcher` | 49033 | 49578 | Complex: SwitchCase hub + player interaction + includes | Dispatcher (not self-contained) |

### 12.2 Actor Files ($C1AA–$EAED)

| File | Block Name | Start | End | Parts | Shared Conventions |
|------|-----------|-------|-----|-------|-------------------|
| `dream_zoom_controller.asm` | `dream_zoom_controller` | 49578 | 49631 | `actor_def` + countdown zoom | Scene actor |
| `speed_zone_ew_slow.asm` | `speed_zone_ew_slow` | 49631 | 49688 | `actor_def` + player speed mod | Speed zone |
| `speed_zone_ew_fast.asm` | `speed_zone_ew_fast` | 49688 | 49745 | Same structure | Speed zone |
| `speed_zone_ns_slow.asm` | `speed_zone_ns_slow` | 49798 | 49851 | Same structure | Speed zone |
| `red_jewel_reward_handler.asm` | `red_jewel_reward_handler` | 49851 | 50071 | `actor_def` + scene→reward lookup + stat increment | Reward system |
| `scene_flag_init.asm` | `scene_flag_init` | 50791 | 50799 | `actor_def` + clear flag + die (8 bytes) | Infrastructure |
| `freejia_street_prop.asm` | `freejia_street_prop` | 50733 | 50791 | `actor_def` + solid tile + sound | Scene actor |
| `player_transition_handlers.asm` | `player_transition_handlers` | 50200 | 50675 | 11 sub-functions (`func_00C418`–`func_00C557`) | Player anim library |
| `floor_button.asm` | `floor_button` | 51707 | 51778 | `actor_def` + pressure plate | Scene actor |
| `hidden_red_jewel.asm` | `hidden_red_jewel` | 50799 | 50916 | `actor_def` + collect/flag | Scene actor |
| `town_door.asm` | `town_door` | 50675 | 50733 | `actor_def` + warp trigger | Scene actor |
| `overworld_exit.asm` | `overworld_exit` | 51778 | 52569 | `actor_def` + complex warp/fade logic | Scene actor (large) |
| `large_ramps.asm` | `large_ramps` | 51555 | 51598 | `actor_def` + speed boost, no COP | Ramp system |
| `statue_inventory_reward.asm` | `statue_inventory_reward` | 52569 | 53033 | `actor_def` + `code_00CE7B/93` + `unk19_00CE97` (table) + 2 child actors | Inventory system |
| `inventory_statue_slot.asm` | `inventory_statue_slot` | 53033 | 53134 | `actor_def` + flag check + display | Inventory system |
| `hit_stagger_controller.asm` | `hit_stagger_controller` | 55415 | 55928 | 7 parts: `e_actor_00D877`, `func_00D904`, `func_00D9EB`, `sub_00DA13/41/47/66` | Combat system |
| `field_reveal_object.asm` | `field_reveal_object` | 55928 | 56202 | Single code block — animated reveal + push spawn | Interaction |
| `reward_actors.asm` | `reward_actors` | 57389 | 57685 | 4 parts: `e_hp/str/def_increase`, `func_00E110` (VFX) | Reward system |
| `push_handler_light.asm` | `push_handler_light` | 57685 | 57942 | Single code block — light nudge handler | Push system |
| `push_handler_solid.asm` | `push_handler_solid` | 57942 | 58298 | Single code block — solid tile push | Push system |
| `push_handler_forceball.asm` | `push_handler_forceball` | 58298 | 58587 | Single code block — forceball push | Push system |
| `smooth_follow_child.asm` | `smooth_follow_child` | 58587 | 58965 | Single code block — child homing actor | Follow system |
| `effect_velocity_init.asm` | `effect_velocity_init` | 59607 | 59725 | `actor_def` + velocity seed | Effect pipeline |
| `effect_subpixel_math.asm` | `effect_subpixel_math` | 59787 | 59884 | Code block — multiply/divide helper | Effect pipeline |
| `effect_position_update.asm` | `effect_position_update` | 59884 | 60054 | `actor_def` + velocity integration | Effect pipeline |
| `camera_scroll_controller.asm` | `camera_scroll_controller` | 60141 | 60315 | `actor_def` + scroll delta computation | Infrastructure |

### 12.3 Function Files ($B5B3–$F432)

| File | Block Name | Start | End | Parts | Shared Conventions |
|------|-----------|-------|-----|-------|-------------------|
| `DeathPaletteFadeThinker.asm` | `DeathPaletteFadeThinker` | 46515 | 46528 | Single code block | Game over |
| `ApplyPlayerHitstun.asm` | `ApplyPlayerHitstun` | 50071 | 50200 | Single code block | Combat |
| `InitPlayerScriptVariant.asm` | `InitPlayerScriptVariant` | 50916 | 50968 | `func_00C6E4` + `table_00C710` (4-entry pointer table) | Player state |
| `SyncActorPosFromDP.asm` | `SyncActorPosFromDP` | 50968 | 50981 | Single code block (13 bytes) | NPC AI |
| `NpcRandomWanderAI.asm` | `NpcRandomWanderAI` | 50981 | 51194 | Code + direction handler blocks | NPC AI |
| `ToggleActorVisibilityFlag.asm` | `ToggleActorVisibilityFlag` | 51194 | 51206 | Single code block (12 bytes) | NPC AI |
| `EscortFollowPathTracker.asm` | `EscortFollowPathTracker` | 51206 | 51555 | `func_00C806` + `array_00C943` (direction table) | NPC AI |
| `InventoryFullMessage.asm` | `f_inventory_full` | 51598 | 51640 | Code + `widestring_00C993` | Inventory utility |
| `SpawnDebrisBurst.asm` | `SpawnDebrisBurst` | 51640 | 51707 | Single code block | Visual FX |
| `CameraDriftLoopSimple.asm` | `CameraDriftLoopSimple` | 53134 | 53166 | Single code block | Camera drift |
| `CameraDriftLoopShip.asm` | `CameraDriftLoopShip` | 53166 | 53231 | Single code block | Camera drift |
| `CameraDriftPatterned.asm` | `CameraDriftPatterned` | 53231 | 53384 | `func_00CFEF` + `binary_00D068` (direction offsets) | Camera drift |
| `GameOverSequence.asm` | `GameOverSequence` | 54831 | 55064 | Single code block | Game over |
| `GameOverCutsceneSprites.asm` | `GameOverCutsceneSprites` | 55064 | 55190 | Single code block | Game over |
| `DeathWakeupMessage.asm` | `death_message` | 55190 | 55415 | Code + 3 `widestring` parts (Will/Freedan/Shadow) | Death system |
| `StandardEnemyDefeatHandler.asm` | `StandardEnemyDefeatHandler` | 56202 | 56818 | 3 parts: `func_00DB8A`, `func_00DD5B`, `func_00DD87` | Combat defeat |
| `NullActorScriptStub.asm` | `NullActorScriptStub` | 56439 | 56441 | RTL (2 bytes) | System |
| `SpawnAttackTrailEffect.asm` | `SpawnAttackTrailEffect` | 56500 | 56579 | Single code block | Combat VFX |
| `SpawnHitSparkSprites.asm` | `SpawnHitSparkSprites` | 56579 | 56667 | Single code block | Combat VFX |
| `SpawnItemDropPickup.asm` | `SpawnItemDropPickup` | 56818 | 57109 | Code block + widestring parts | Item drops |
| `EnemyDeathFlash.asm` | `EnemyDeathFlash` | 57109 | 57129 | Single code block (20 bytes) | Combat VFX |
| `EnemyRewardChestSystem.asm` | `EnemyRewardChestSystem` | 57129 | 57389 | 7 sub-funcs + `array_00DFFD` | Reward chest |
| `StopPlayerOnDeathAssign.asm` | `StopPlayerOnDeathAssign` | 62387 | 62409 | Single code block (22 bytes) | Game over |
| `ApplyOrbitalOffsetXY.asm` | `ApplyOrbitalOffsetXY` | 62514 | 62607 | Single code block | Orbital math |

### 12.4 Unused Files

| File | Block Name | Start | End | Reason Unused |
|------|-----------|-------|-----|---------------|
| `SceneTransPaletteThinker_unused.asm` | `SceneTransPaletteThinker_unused` | 46376 | 46515 | No references (noref) |
| `palette_buffer_clear_unused.asm` | `palette_buffer_clear_unused` | 46845 | 46878 | No scene_thinkers references |
| `babel_palette_65_unused.asm` | `babel_palette_65_unused` | 46977 | 46991 | Cut Babel Tower effect |
| `palette_loop_flash_unused.asm` | `palette_loop_flash_unused` | 47112 | 47128 | No references |
| `dma_setup_variant_unused.asm` | `dma_setup_variant_unused` | 48279 | 48307 | No references |
| `empty_stub_unused.asm` | `empty_stub_unused` | 48586 | 48589 | RTL only — placeholder (3 bytes) |
| `native_village_dup_unused.asm` | `native_village_dup_unused` | 48810 | 48849 | Byte-identical duplicate of `native_village_sine_hdma` |
| `gen_hdma_sine_oneshot_unused.asm` | `gen_hdma_sine_oneshot_unused` | 48978 | 49016 | Extracted subset of `sine_hdma_ending_wave` |
| `speed_zone_ns_fast_unused.asm` | `speed_zone_ns_fast_unused` | 49745 | 49798 | No scene_actors references — dead N-S speed zone |
| `AttackTrailShort_unused.asm` | `AttackTrailShort_unused` | 56441 | 56500 | Variant of SpawnAttackTrailEffect with no refs |
| `InitSmoothFollowChase_unused.asm` | `InitSmoothFollowChase_unused` | 58965 | 59011 | Wrapper with no direct callers |
| ~~`ApplyOrbitalOffsetFromRef.asm`~~ | `ApplyOrbitalOffsetFromRef` | 62409 | 62504 | ✅ **Moved to `functions` section** — see §8.1, §13.2 |
| `CopyRefActorPos_unused.asm` | `CopyRefActorPos_unused` | 62504 | 62514 | Dead entry stub (10 bytes) |

### 12.5 Grouping Recommendations — Status

All recommended groupings have been applied to `blocks.json`. Final status:

| Proposed Group | Members | Convention | Status |
|---------------|---------|------------|--------|
| **Palette COP family** | 9 ambient cyclers + 8 one-shot flashes | All use PaletteRestart/Start/Step COP pattern | ✓ Kept individual — spawned independently |
| **Sine HDMA family** | 11 sine wave thinkers | All use InitSineHdma/TickSineHdma/BindSineHdma | ✓ Kept individual — scene-specific |
| **Speed zones** | 3 active + 1 unused | Identical structure, Mountain Temple only | ✓ **Merged** → `movement_speed_zones` in `mountain_temple` |
| **Push handlers** | 3 variants | All include `chunk_03BAE1`, use `$@func_03F0CA` | ✓ **Merged** → `push_interaction_handlers` in `actors` |
| **Effect pipeline** | 3 actors | Sequential processing, same scenes | ✓ **Merged** → `visual_effect_pipeline` in `actors` |
| **Camera drift** | 3 functions + binary | Ambient camera variants, all use RNG | ✓ **Merged** → `camera_drift` in `functions` |
| **Game over** | 3 contiguous functions | Death sequence: fade → cutscene → wakeup message | ✓ **Merged** → `game_over_sequence` in `functions` (`movable: false`) |
| **Combat defeat** | 6 functions | Enemy death → flash → drops → chest | ✓ Already grouped in `StandardEnemyDefeatHandler` |
| **Inventory system** | 2 actors | Statue/inventory menu shared data | ✓ Kept separate — different scene sections |
| **NPC AI** | 2 functions | Position sync + random wander | ✓ **Merged** → `npc_wander_ai` in `functions` |

---

## 13. Structural Changes (2026-09-06)

### 13.1 Parts Block Merges

Six new multi-part blocks created from individual entries:

| Block Name | Section | Parts | Rationale |
|-----------|---------|-------|-----------|
| `movement_speed_zones` | `mountain_temple` | `speed_zone_ew_slow`, `speed_zone_ew_fast`, `speed_zone_ns_slow` | Identical structure, same scene group; removed `kress_maze` scene tag (shared within MT) |
| `push_interaction_handlers` | `actors` | `push_handler_light`, `push_handler_solid`, `push_handler_forceball` | All share `chunk_03BAE1` + `$@func_03F0CA` convention |
| `visual_effect_pipeline` | `actors` | `effect_velocity_init`, `effect_subpixel_math`, `effect_position_update` | Sequential processing pipeline, always used together |
| `camera_drift` | `functions` | `CameraDriftLoopSimple`, `CameraDriftLoopShip`, `func_00CFEF`, `binary_00D068` | Three camera drift variants + shared direction offset data |
| `game_over_sequence` | `functions` | `GameOverSequence`, `GameOverCutsceneSprites`, `death_message` | Contiguous addresses (54831–55415), thematically linked death flow; `movable: false` due to inbound `$&` refs |
| `npc_wander_ai` | `functions` | `SyncActorPosFromDP`, `NpcRandomWanderAI` | Always called together (position sync + wander loop) |

### 13.2 Section Moves

Five entries moved to their correct category sections:

| Block | From Section | To Section | Reason |
|-------|-------------|-----------|--------|
| `palette_buffer_clear_unused` | `thinkers` | `unused` | No references — unreferenced code |
| `ending_comet_dma_setup` | `thinkers` | `ending` | Exclusive to ending comet scenes; added `scene: "ending_comet"` |
| `sine_hdma_dual_channel` | `thinkers` | `seaside_palace` | Exclusive to Palace Coffins; added `scene: "palace_coffins"` |
| `sine_hdma_ending_wave` | `thinkers` | `babel_tower` | Used in Comet Lair + Dark Castoth (both babel_tower); no `scene` tag (shared within group) |
| `ApplyOrbitalOffsetFromRef` | `unused` | `functions` | **Critical fix:** 15+ live references — was incorrectly marked as unused |

### 13.3 Scene Tag Cleanup

| Block | Change | Reason |
|-------|--------|--------|
| `speed_zone_ew_fast` | Removed `scene: "kress_maze"` | Now part of `movement_speed_zones` in `mountain_temple` section — shared within group, no individual scene tag needed |

### 13.4 Section Placement Rules Applied

The following placement rules were enforced:

1. **Scene-exclusive blocks** → placed in their scene group section with a `scene` property
2. **Blocks shared between scenes in the same group** → placed in the group section with **no** `scene` property
3. **Blocks used across multiple scene groups** → placed in generic `actors`/`thinkers`/`functions` sections
4. **Unused blocks** → placed in `unused` section regardless of original category
5. **Runtime-only utility actors** (spawned dynamically, never in scene_actors tables) → placed in `actors` section

---

*Generated from deep analysis of 104 code blocks in bank $00 upper half ($B500–$F4FF) of Illusion of Gaia US ROM.*
*All renames applied to `us/blocks.json` (97 block keys) and `us/names.json` (104 entries) on 2026-09-06.*
*Structural groupings (6 merges, 5 section moves) applied to `us/blocks.json` on 2026-09-06.*
*Cross-referenced with `us/blocks.json`, `us/names.json`, `extracted/` ASM files, `scene_actors.asm`, `scene_thinkers.asm`, and `chunk_008000-analysis.md`.*
