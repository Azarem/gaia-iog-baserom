# Bank $00 — Actors: Player Transitions, Rewards & Inventory

**Bank:** `$00` (mirrored at `$80`)  
**Address range:** `$00C2BB`–`$00CF29` (this document)  
**Scope:** Boss clear stat rewards, player transition animation library, statue/inventory system, location-specific interactables, and field reveal collectibles  
**Sources:** `extracted/actors/*.asm`, `extracted/system/statue_inventory/*`, `extracted/freejia/*`, `extracted/tables/scene_actors.asm`

These actors handle player-facing progression: boss-triggered catchup stat rewards, cutscene/warp player animations, statue collectible grants, town doors, hit-triggered switches, overworld map transitions, and animated field pickups.

**Related:** [`actors-combat-interaction.md`](actors-combat-interaction.md) (stat reward VFX, push handlers) · [`README.md`](README.md)

---

## Overview

| Actor / Block | Address | Movable | Scene / Spawn |
|---------------|---------|---------|---------------|
| `boss_clear_reward_handler` | `$C2BB` | ✓ | 5 scenes |
| `player_transition_handlers` | `$C418`–`$C5E3` | **No** | Library (`$&` refs) |
| `freejia_street_prop` | `$C62D` | ✓ | Freejia ($32) |
| `hidden_red_jewel` | `$C672` | ✓ | 16 scenes |
| `town_door` | `$C5A3` | ✓ | 3 scenes (+1 runtime) |
| `hit_switch` | `$C9FE` | ✓ | 7 scenes |
| `overworld_exit` | `$CA45` | ✓ | 15 overworld scenes |
| `statue_inventory_reward` | `$CD59` | ✓ | Scene $FD |
| `inventory_statue_slot` | `$CF29` | ✓ | Scene $FF |
| `field_reveal_object` | `$DA78` | ✓ | Runtime spawn |

---

## Boss Clear Reward Handler

### boss_clear_reward_handler

**Address:** `$00C2BB` · **Size:** 220 bytes

#### Description

After a boss is defeated, this handler retroactively awards all **uncollected** per-scene enemy-clear stat rewards within a range. The embedded range table `boss_reward_range_table` maps `$scene_current` to a `<sceneCurrent, sceneMin, sceneMax>` triplet. The helper at `$C33E` then walks `enemy_clear_reward_table` from `sceneMin` to `sceneMax`, granting every reward the player missed.

Only activates when `$player_flags` bit `$0020` is set (boss-defeat latch set by the boss death script). Uses WRAM flag offset `$0100` range to prevent duplicate boss catchup per scene. Individual scene rewards are tracked via `$0300` flags.

The helper at `$C33E` walks the reward table byte-by-byte: value `1` → increment max HP (`$0ACA`), `2` → increment `$0ADE` (STR), `3` → increment `$0ADC` (DEF). Each scene's reward sets a `$0300` flag before applying, so already-collected rewards are skipped.

Movable (move with `enemy_clear_reward_table`). High priority — boss reward scenes.

> ⚠ This actor has **nothing to do with red jewels**. It is a boss-defeat catchup mechanism that ensures the player receives all stat bonuses from scenes they may have cleared (or skipped clearing) between boss milestones.

#### Algorithm

```
1. Scan boss_reward_range_table for matching $scene_current
2. TestWramFlag_Offset100 — skip if boss already rewarded
3. Require $player_flags bit $0020 (boss defeated)
4. Load scene range (sceneMin → sceneMax) from table entry
5. JSR apply_pending_clear_rewards — walk enemy_clear_reward_table[sceneMin..sceneMax]
   For each scene in range: check $0300 flag, skip if collected, else grant stat and set flag
6. Update $0B22 (HP recovery delta = playerMaxHp − playerHp)
7. SetWramFlag_Offset100 — mark boss scene rewarded
8. SetEntryHere loop
```

#### Variables

| Symbol | Role |
|--------|------|
| `$scene_current` | Scene index — boss scene lookup key |
| `$player_flags` | Bit `$0020` = boss defeated, reward eligible |
| `$0ACA` | Max HP |
| `$0ACE` | Current HP |
| `$0ADE` | STR stat |
| `$0ADC` | DEF stat |
| `$0B22` | HP bar display delta |
| `$20` | Saved range table index |
| `boss_reward_range_table` | Boss scene → `<sceneCurrent, sceneMin, sceneMax>` range mapping (5 active + 6 placeholders) |
| `enemy_clear_reward_table` | Per-scene enemy clear reward table (0=none, 1=HP, 2=STR, 3=DEF) |

#### Range Table (`boss_reward_range_table`)

Each entry defines the range of scenes whose rewards are granted on boss defeat:

| # | Scene | Min | Max | Boss Context |
|---|-------|-----|-----|-------------|
| 00 | `$29` | `$0C` | `$29` | Castoth |
| 01 | `$55` | `$3D` | `$55` | Viper |
| 02 | `$67` | `$5A` | `$67` | Vampire |
| 03 | `$8A` | `$6D` | `$8A` | Sand Fanger |
| 04 | `$DD` | `$A0` | `$DD` | Mummy Queen |
| 05 | `$F8` | `$00` | `$00` | (placeholder) |
| 06–0A | `$29` | `$00` | `$00` | (placeholder) |

#### Scene Usage

**5** placements — post-boss scenes:

| Scene Context | Slot |
|---------------|------|
| Castoth (`ir29`) | `#05` |
| Viper boss (`sg55`) | `#19` |
| Vampire lair (`mu67`) | `#0A` |
| Sand Fanger (`gw8A` event) | `#04` |
| Mummy Queen (`pyDD`) | `#0A` |

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Includes | `enemy_clear_reward_table` | Must move together |
| Includes | `flag_helpers` | Flag/stat COP helpers |
| Related | `field_reveal_object` | Also reads `enemy_clear_reward_table` |
| Related | `StandardEnemyDefeatHandler` | Reads `enemy_clear_reward_table` per scene; the stat reward is paid for the LAST enemy of the scene (gems drop while `$0300 + scene` is set or enemies remain) |

---

## Player Transition Handlers Library

### player_transition_handlers

**Address:** `$00C418`–`$00C5E3` · **Size:** 460 bytes (11 sub-functions)

#### Description

Library of COP scripts for cutscene and warp player animations. Not placed directly in scenes; referenced by `$&func_00C4xx` pointers from warp handlers, boss scripts, and `ComposeDigitSprites_AtCursor`. All player-control-restoration paths converge on `$@PlayerIdleEntry` (bank `$02` normal player AI).

**Not movable** — widely referenced via `$&` short addresses.

Includes: `player_character`, `table_0EE000` (generic metasprite table).

#### Sub-Functions

| Part | Address | Name | Behavior |
|------|---------|------|----------|
| 1 | `$C418` | `SpawnSparkleEffect` | Spawns sparkle anim via `SpawnLastRel`, sound `$09`, frame `$2A` |
| 2 | `$C432` | `HoldPlayerSpriteLoop1` | Loops player sprite frame `#01` (or `#11` if flag byte `#00` set) |
| 3 | `$C43D` | `HoldPlayerSpriteLoop11` | Loops player sprite frame `#11` |
| 4 | `$C446` | `HoldBodySpriteLoop` | Body sprite `#04`, frame `#1F`, infinite anim loop |
| 5 | `$C455` | `HoldBodySpriteRelease` | Clears `$10` bit `$0200` (releases body hold) |
| 6 | `$C45A` | `RestorePlayerControlDirect` | `JML $@PlayerIdleEntry` |
| 7 | `$C45E` | `PlayerWakeAnim` | Body `#04`, frame `#20`, anim once, RTL |
| 8 | `$C46D` | `PlayerWakeReturn` | Wake anim → `JML PlayerIdleEntry` |
| 9 | `$C479` | `WarpClimbAnim` | Masks joypad, vertical climb + sound `$2C`, 8-frame Y move |
| 10 | `$C4D1` | `GardenJumpAnim` | Sky Garden ledge jump: V-flip, multi-stage Y moves, landing sound |
| 11 | `$C557` | `FallIntoHoleAnim` | Fall through hollow tile: body `#08`, solid probe, sink anim |

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Included by | `warps_interaction.asm`, `GlobalInputHandler`, `ComposeDigitSprites_AtCursor` | `$&` pointer tables |
| Called from | `sg4D_jump_handler`, `ir29_castoth`, `gw8A_sand_fanger`, Gold Ship scenes | `JumpScript` / pointer assignment |
| Returns to | `PlayerIdleEntry` | Bank `$02` player control |

---

### SpawnSparkleEffect (`$C418`)

Spawns a short-lived sparkle actor at `#00,#00` with flags `$0302`. Child script plays sound `$09`, sets metasprite from `table_0EE000`, animates frame `$2A` once, then dies. Used as a visual flourish at warp/transition entry points.

---

### HoldPlayerSpriteLoop1 / HoldPlayerSpriteLoop11 (`$C432` / `$C43D`)

Freezes the player on a specific sprite frame during cutscenes. `HoldPlayerSpriteLoop1` checks flag byte `#00`: if set, branches to frame `#11` path; otherwise loops frame `#01`. Both use `SetEntryHere` + `AnimOnce` infinite loops.

---

### HoldBodySpriteLoop / HoldBodySpriteRelease (`$C446` / `$C455`)

Forces body overlay sprite `#04` frame `#1F` in a hold loop (sets `$10` bit `$0200`). Release clears that bit without restoring full player control — callers chain to `RestorePlayerControlDirect` or wake anims.

---

### RestorePlayerControlDirect (`$C45A`)

Single-instruction entry: `JML $@PlayerIdleEntry`. Used when no wake animation is needed.

---

### PlayerWakeAnim / PlayerWakeReturn (`$C45E` / `$C46D`)

Sleep/wake sequence: sets body `#04`, plays frame `#20` once. `PlayerWakeReturn` adds the `JML` to normal control after the anim.

---

### WarpClimbAnim (`$C479`)

Vertical warp climb used in ladder/rope transitions:

1. Masks joypad (`$CFF0`), sets `$player_flags` bit `$0800`
2. Waits 3 frames, moves Y + `$80`
3. 8-frame animated Y climb (move IDs `$19`/`$1C`)
4. Sound `$2C`, restores flags, `JML PlayerIdleEntry`

---

### GardenJumpAnim (`$C4D1`)

Sky Garden ledge jump with vertical flip:

1. Initial Y offset + `$C0`, toggle V-flip, fall + `$E0`
2. Multi-stage `$1A`/`$1B` Y animation with decreasing step sizes
3. Toggle V-flip off, landing frames `$1E`/`$1F`
4. Sound `$2C`, restore control

Referenced by `sg4D_jump_handler.asm`.

---

### FallIntoHoleAnim (`$C557`)

Player falls through hollow floor tiles:

1. Sets body sprite `#08`, probes downward with `BranchIfSolid`
2. If solid type `#04` south: short fall + `$1C` landing
3. Otherwise: sink through with `$2000` flag, frame-by-frame Y increment until solid type `#00`
4. Restore player control via `PlayerIdleEntry`

---

## Statue / Inventory System

### statue_inventory_reward

**Address:** `$00CD59` · **Size:** 464 bytes

#### Description

Scene `$FD` (mystic-statue reward ceremony): entered via `QueueMapChange` from six boss/event scripts (Gold Ship, Viper, Mu, Great Wall, Mummy Queen, Babel). Six actor copies share the pedestals; only the copy whose table index matches `globalScriptIndex` (`$0AAC`) runs the ceremony.

Contains shared data `statue_reward_table` — **6 entries of 4 bytes** each (flag, sprite, match index, one unused tail byte). Spawns **8** `StatueRewardOrbitalSparkle` children during the fanfare wait, then up to **60** `StatueRewardConfettiBurst` actors (about **15** visible, gated by `frameCounter AND 3`).

On exit, restores the saved scene from `$0B12` and position in `$0B08`–`$0B10` via warp vars; sets exit effect 2 / enter effect 0 (`gfxCacheIdxA` `$0002`) and transition speed 3 (`gfxCacheIdxB` `$0303`).

#### Variables

| Symbol | Role |
|--------|------|
| `$0E` / `$24` | Slot index from scene placement |
| `$0AAC` | Fanfare countdown timer |
| `$0AAC` | Ceremony index / fanfare countdown |
| `$0B08`–`$0B10` | Saved tile X/Y and scroll params for return warp |
| `$0648`–`$0652` | Warp destination staging |
| `statue_reward_table` | 6-entry `{flag, sprite, match, tail}` table |
| `$0676` | High byte + bank of graphics cache slot D (`srcCacheBgD+1`; cleared on entry) |

#### Slot Table (`statue_reward_table`)

| Index | Flag | Frame | Match |
|-------|------|-------|-------|
| 0 | `$F8` | `$3A` | 0 |
| 1 | `$F9` | `$3B` | 1 |
| 2 | `$FA` | `$3C` | 2 |
| 3 | `$FB` | `$3D` | 3 |
| 4 | `$FC` | `$3E` | 4 |
| 5 | `$FD` | `$3F` | 5 |

#### Scene Usage

Scene `$FD` only — statue inventory reward screen.

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Includes | `ApplyOrbitalOffsetFromRef`, `flag_helpers`, `inventory_spritemap`, `music_actors`, `sprite_composition`, `spriteset_pickups_effects` | |
| Shared data | `statue_reward_table` | Read by `inventory_statue_slot` |
| Calls | `UpdateActorAnimation` | Advance animation frame |
| Calls | `ApplyOrbitalOffsetFromRef` | Pickup child orbit motion |

---

### inventory_statue_slot

**Address:** `$00CF29` · **Size:** 84 bytes

#### Description

Scene `$FF` (inventory menu): displays collected statue items. Reads slot index from `$0E`, checks collection flag via shared `statue_reward_table` from `statue_inventory_reward`. If uncollected, dies immediately. If collected, shows sprite via `UpdateActorAnimation` and hides the statue only on the Status tab (`inventoryTabIndex` `$0AFA` = 3); tabs 0–2 show it.

Depends on `statue_inventory_reward` via `?INCLUDE` for shared table access.

#### Algorithm

```
1. Position sprite (+$08,$08 offset; +$F8 Y if $0E bit $10)
2. Index statue_reward_table via ($0E & $0F) × 4
3. TestFlagRaw — Die if not collected
4. Set frame from table, animate
5. If $0AFA == 3: hide; else show ($10 bit $2000 set)
```

#### Scene Usage

Scene `$FF` only — one slot actor per inventory row (6 slots).

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Includes | `statue_inventory_reward` | Shared `statue_reward_table` |
| Includes | `inventory_spritemap`, `ComposeDigitSprites_AtCursor` | |

---

## Location-Specific Actors

### freejia_street_prop

**Address:** `$00C62D` · **Size:** 58 bytes

#### Description

Interactive scenery in Freejia (scene `$32`). Displays metasprite frame `#07`, sets solid high tile, waits for player proximity. When player presses button `$0800` within range, plays sound `$01`. When player enters tile, clears low solid and switches to frame `#00` (opened/activated state).

Structurally identical to `town_door` but uses frame `#07` and sound `$01` instead of door frame `#01` / sound `$0E`.

#### Scene Usage

**2** placements in Freejia street scene.

---

### hidden_red_jewel

**Address:** `$00C672` · **Size:** 117 bytes

#### Description

Collectible red jewel placed in hidden locations. Uses standard `actor_def` with `SetOnInteract` callback. On button press: tests event flag `$0E + $80`, gives item `#01` (red jewel) via `GiveItem`, prints discovery string, sets flag. If inventory full, prints alternate string without granting.

Each placement's `$0E` field encodes the unique event flag offset.

#### Variables

| Symbol | Role |
|--------|------|
| `$0E` | Per-instance flag offset (actor placement field) |
| Event flags `$0200` range | `$0E + $80` per jewel |

#### Scene Usage

**16** placements across overworld and dungeon hidden locations.

---

### town_door

**Address:** `$00C5A3` · **Size:** 58 bytes

#### Description

Decorative town door (not a warp; building entrances use separate triggers). Shows closed door (frame `#01`, solid high). When the player is within 1 tile (`BranchIfPlayerNear` radius 1) and holds Up (`$0800`) for **8 consecutive frames**, plays sound `$0E`, clears solid, and switches to open frame `#00` for the rest of the visit. Releasing Up or leaving proximity restarts the hold counter.

Uses `table_0EDA00` metasprite (town object sprites).

#### Scene Usage

**16** placements in three scenes — `$01` South Cape (5), `$32` Freejia (4), `$91` Euro (7) — plus one runtime spawn from `fr32_guide`.

---

### hit_switch

**Address:** `$00C9FE` · **Size:** 71 bytes

#### Description

Solid **hit-triggered switch** (not a pressure plate — the player cannot stand on it). On init: stores flag number from spawn type byte in `$24`, uses enemy stat entry `$118` for hit handling, shows frame `#0F`, marks solid, and registers `HitSwitchTriggered` as the hit callback. Each strike sets the numbered event flag, shows frame `#10`, waits 15 frames, returns to `#0F`, and re-arms the callback.

#### Variables

| Symbol | Role |
|--------|------|
| `$0E` / `$24` | Event flag number to set on hit |
| `$7F1000` | Hit callback pointer (cleared after dispatch) |
| `enemy_stats_table+118` | Stat block for hit reception |

#### Scene Usage

**7** placements — **Great Wall** scenes only (`$83`, `$85`×5, `$87`).

---

### overworld_exit

**Address:** `$00CA45` · **Size:** 791 bytes

#### Description

Complex warp/fade logic for overworld-to-world-map transitions. Entry dispatches on `$scene_current` via a cascade of `CMP`/`JMP` to scene-specific handlers. Each handler checks player position thresholds, flag bytes, and tile regions before calling `StageWorldMapChoice` with world-map coordinates and destination index.

Common pattern: clear `$0D60` (first word of the six-word world-map companion array `$0D60`–`$0D6A`), `StageWorldMapChoice` with start X/Y and destination-menu id, then `JMP OverworldExitFinalize`, which sets `gfxCacheIdxB` (`$064A`) ← `$0400` and idles until the scene changes.

#### Handled Scenes

| Scene | Area | Exit zone | Gate (first match wins) | Start X,Y | Choice id / menu |
|-------|------|-----------|-------------------------|-----------|------------------|
| `$01` | South Cape | Y < `$10` | flag `$26`, then flag `$25` | `$D4`,`$3A4` | `$02` Itory; `$1B` Quit only; default `$01` Edward's Castle |
| `$0A` | Edward Castle | Y == `$2D0` | none | `$104`,`$334` | `$03` South Cape |
| `$15` | Itory Village | tiles (2D,2E)–(2F,30) | flag `$01` disables; flag `$4A` | `$C4`,`$2B4` | `$06` Inca Ruins; default `$04` South Cape |
| `$1C` | Inca Ruins entrance | tiles (06,1C)–(08,1E) | none | `$134`,`$284` | `$05` Itory Village |
| `$32` | Freejia | tiles (12,3C)–(16,3E) | flag `$65` | `$254`,`$2D4` | `$07` Diamond Mine; default `$09` Quit only |
| `$3E` | Diamond Mine entrance | tiles (0A,3F)–(0C,40) | none | `$334`,`$334` | `$08` Freejia |
| `$69` | Angel Village entrance | tiles (29,0D)–(2C,0F) | flag `$8D` | `$384`,`$164` | `$0A` Watermia; default `$15` Quit only |
| `$78` | Watermia | tiles (27,3D)–(29,40) | flag `$94`, then flag `$8E` | `$2D4`,`$1A4` | `$0E` / `$0C` multi-dest; default `$0B` Angel Village |
| `$82` | Great Wall entrance | tiles (00,08)–(01,0B) | none | `$2A4`,`$124` | `$0D` Watermia |
| `$91` | Euro | tiles (3F,42)–(40,48) | flag `$AC`, then flag `$9F` | `$1D4`,`$134` | `$1A` / `$10` multi-dest; default `$0F` Watermia |
| `$A0` | Mountain Temple entrance | tiles (2F,1B)–(30,1C) | none | `$214`,`$B4` | `$11` Euro city |
| `$AC` | Native Village | tiles (1F,1B)–(20,20) | flag `$B6`, then flag `$B1` | `$124`,`$1A4` | `$19` / `$13` multi-dest; default `$12` Euro city |
| `$B0` | Angkor Wat entrance | tiles (1D,4F)–(24,50) | none | `$134`,`$154` | `$14` Natives' Village |
| `$C3` | Dao | tiles (00,0D)–(01,11) | flag `$B4` | `$94`,`$114` | `$17` / default `$16` Natives' Village |
| `$CC` | Pyramid | tiles west or east edge | none | `$74`,`$B4` | `$18` Dao Village |

#### Variables

| Symbol | Role |
|--------|------|
| `$scene_current` | Dispatch key |
| `$player_y_pos`, `$player_x_pos` | Position gates |
| `$0D60` | First word of world-map companion array (cleared on every exit path) |
| `$064A` | `gfxCacheIdxB` (transition staging; set to `$0400` in finalize) |
| `$0648`–`$0652` | Warp destination parameters |

#### Scene Usage

**15** placements on overworld field scenes at map boundaries.

---

## Field Reveal Object

### field_reveal_object

**Address:** `$00DA78` · **Size:** 274 bytes

#### Description

Animated reveal/collectible spawned at runtime when a hidden field object is discovered. **Not placed in `scene_actors.asm`** — spawned via `SpawnAfterFlags` from boss scripts and field actors.

On spawn: checks `$scene_current` against `enemy_clear_reward_table` to select HP/STR/DEF/gem sprite variant via `SwitchCase`. If already collected (`TestFlag_0300`), uses alternate frame path. Animates upward reveal (7-frame Y rise with solid check), moves toward player (`MoveToward`), then spawns `collect_handler_gem` for collection interaction.

#### Algorithm

```
1. Select sprite variant from enemy_clear_reward_table[$scene_current] & 3
2. Animate Y rise (7 frames, solid-aware)
3. MoveToward player + StageForceMoveXY
4. Wait 11 frames
5. SpawnAfterMarked collect_handler_gem (#$2300)
6. Loop anim until $28 < 8, then fade
```

#### Variables

| Symbol | Role |
|--------|------|
| `$26` | Rise frame counter |
| `$24` | Saved Y position |
| `$28` | Fade/anim phase |
| `$7F0020` | Parent actor link |
| `enemy_clear_reward_table` | Per-scene enemy clear reward type (0=none, 1=HP, 2=STR, 3=DEF) |

#### Scene Usage

Runtime spawn only — called from:

| Caller | Context |
|--------|---------|
| `pyCC_mystic_ball.asm` | Pyramid mystic ball reveal |
| `awB1_wall_walker.asm` | Angkor wall walker drop |
| `EnemyDefeatDispatch.asm` | Non-last-enemy kills: spawns with remaining count in `$26` for per-enemy stat gem variant |

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Spawns | `collect_handler_gem` | Gem collection interaction handler |
| Includes | `interaction_handlers`, `enemy_clear_reward_table` | |

---

*Source: `extracted/actors/*.asm`, `extracted/system/statue_inventory/*`, `extracted/freejia/*`, `extracted/tables/scene_actors.asm`.*
