# Bank $00 — Actors: Player Transitions, Rewards & Inventory

**Bank:** `$00` (mirrored at `$80`)  
**Address range:** `$00C2BB`–`$00CF29` (this document)  
**Scope:** Boss clear stat rewards, player transition animation library, statue/inventory system, location-specific interactables, and field reveal collectibles  
**Sources:** `extracted/actors/*.asm`, `extracted/system/statue_inventory/*`, `extracted/freejia/*`, `extracted/tables/scene_actors.asm`

These actors handle player-facing progression: boss-triggered catchup stat rewards, cutscene/warp player animations, statue collectible grants, town doors, pressure plates, overworld map transitions, and animated field pickups.

**Related:** [`actors-combat-interaction.md`](actors-combat-interaction.md) (stat reward VFX, push handlers) · [`readme.md`](readme.md)

---

## Overview

| Actor / Block | Address | Movable | Scene / Spawn |
|---------------|---------|---------|---------------|
| `boss_clear_reward_handler` | `$C2BB` | ✓ | 5 scenes |
| `player_transition_handlers` | `$C418`–`$C5E3` | **No** | Library (`$&` refs) |
| `freejia_street_prop` | `$C62D` | ✓ | Freejia ($32) |
| `hidden_red_jewel` | `$C672` | ✓ | 16 scenes |
| `town_door` | `$C5A3` | ✓ | 16 scenes |
| `floor_button` | `$C9FE` | ✓ | 7 scenes |
| `overworld_exit` | `$CA45` | ✓ | 15 overworld scenes |
| `statue_inventory_reward` | `$CD59` | ✓ | Scene $FD |
| `inventory_statue_slot` | `$CF29` | ✓ | Scene $FF |
| `field_reveal_object` | `$DA78` | ✓ | Runtime spawn |

---

## Boss Clear Reward Handler

### boss_clear_reward_handler

**Address:** `$00C2BB` · **Size:** 220 bytes

#### Description

After a boss is defeated, this handler retroactively awards all **uncollected** per-scene enemy-clear stat rewards within a range. The embedded range table `boss_reward_range_00C312` maps `$scene_current` to a `<sceneCurrent, sceneMin, sceneMax>` triplet. The helper at `$C33E` then walks `enemy_clear_reward_table` from `sceneMin` to `sceneMax`, granting every reward the player missed.

Only activates when `$player_flags` bit `$0020` is set (boss defeated, reward-eligible state). Uses WRAM flag offset `$0100` range to prevent duplicate boss catchup per scene. Individual scene rewards are tracked via `$0300` flags.

The helper at `$C33E` walks the reward table byte-by-byte: value `1` → increment `$0ACA` (HP), `2` → increment `$0ADE` (STR), `3` → increment `$0ADC` (DEF). Each scene's reward sets a `$0300` flag before applying, so already-collected rewards are skipped.

Movable (move with `enemy_clear_reward_table`). High priority — boss reward scenes.

> ⚠ This actor has **nothing to do with red jewels**. It is a boss-defeat catchup mechanism that ensures the player receives all stat bonuses from scenes they may have cleared (or skipped clearing) between boss milestones.

#### Algorithm

```
1. Scan boss_reward_range_00C312 for matching $scene_current
2. TestWramFlag_Offset100 — skip if boss already rewarded
3. Require $player_flags bit $0020 (boss defeated)
4. Load scene range (sceneMin → sceneMax) from table entry
5. JSR apply_pending_clear_rewards — walk enemy_clear_reward_table[sceneMin..sceneMax]
   For each scene in range: check $0300 flag, skip if collected, else grant stat and set flag
6. Update $0B22 (HP recovery delta = playerMaxHp − playerHp)
7. SetWramFlag_Offset100 — mark boss scene rewarded
8. SetEntryContinue loop
```

#### Variables

| Symbol | Role |
|--------|------|
| `$scene_current` | Scene index — boss scene lookup key |
| `$player_flags` | Bit `$0020` = boss defeated, reward eligible |
| `$0ACA` | Current HP |
| `$0ACE` | Base HP (for delta calc) |
| `$0ADE` | STR stat |
| `$0ADC` | DEF stat |
| `$0B22` | HP bar display delta |
| `$20` | Saved range table index |
| `boss_reward_range_00C312` | Boss scene → `<sceneCurrent, sceneMin, sceneMax>` range mapping (5 active + 6 placeholders) |
| `enemy_clear_reward_table` | Per-scene enemy clear reward table (0=none, 1=HP, 2=STR, 3=DEF) |

#### Range Table (`boss_reward_range_00C312`)

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
| Includes | `cop_handlers_flags` | Flag/stat COP helpers |
| Related | `field_reveal_object` | Also reads `enemy_clear_reward_table` |
| Related | `StandardEnemyDefeatHandler` | Reads `enemy_clear_reward_table` per scene for individual drops |

---

## Player Transition Handlers Library

### player_transition_handlers

**Address:** `$00C418`–`$00C5E3` · **Size:** 460 bytes (11 sub-functions)

#### Description

Library of COP scripts for cutscene and warp player animations. Not placed directly in scenes; referenced by `$&func_00C4xx` pointers from warp handlers, boss scripts, and `ComposeDigits_Continuation`. All player-control-restoration paths converge on `$@PlayerIdleEntry` (bank `$02` normal player AI).

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
| Included by | `warps_interaction.asm`, `GlobalInputHandler`, `ComposeDigits_Continuation` | `$&` pointer tables |
| Called from | `sg4D_jump_handler`, `ir29_castoth`, `gw8A_sand_fanger`, Gold Ship scenes | `JumpScript` / pointer assignment |
| Returns to | `PlayerIdleEntry` | Bank `$02` player control |

---

### SpawnSparkleEffect (`$C418`)

Spawns a short-lived sparkle actor at `#00,#00` with flags `$0302`. Child script plays sound `$09`, sets metasprite from `table_0EE000`, animates frame `$2A` once, then dies. Used as a visual flourish at warp/transition entry points.

---

### HoldPlayerSpriteLoop1 / HoldPlayerSpriteLoop11 (`$C432` / `$C43D`)

Freezes the player on a specific sprite frame during cutscenes. `HoldPlayerSpriteLoop1` checks flag byte `#00`: if set, branches to frame `#11` path; otherwise loops frame `#01`. Both use `SetEntryContinue` + `AnimOnce` infinite loops.

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

Scene `$FD` (statue inventory overlay): grants statue collectibles when the player selects an uncollected slot. Flow: event flag check → item display via `UpdateActorAnimation` → fanfare wait → sparkle FX spawn → restore prior scene.

Contains shared data `unk19_00CE97` — a **6×3-byte slot table** mapping flag ID, display frame, and inventory index. Spawns 6 animated pickup children (`StatueRewardOrbitalSparkle`) during fanfare, then random sparkle particles (`StatueRewardConfettiBurst`).

On completion, writes saved scene/position from `$0B08`–`$0B12` into warp vars `$0648`–`$0652` and sets fade mode `$0303`.

#### Variables

| Symbol | Role |
|--------|------|
| `$0E` / `$24` | Slot index from scene placement |
| `$0AAC` | Fanfare countdown timer |
| `$0AFA` | Inventory display state |
| `$0B08`–`$0B12` | Saved scene/position restore |
| `$0648`–`$0652` | Warp destination vars |
| `unk19_00CE97` | 6-entry `{flag, frame, index}` table |
| `$0676` | PPU scroll state (zeroed on entry) |

#### Slot Table (`unk19_00CE97`)

| Index | Flag | Frame | Inv Index |
|-------|------|-------|-----------|
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
| Includes | `ComposeDigits_Continuation`, `cop_handlers_flags`, `inventory_spritemap` | |
| Shared data | `unk19_00CE97` | Read by `inventory_statue_slot` |
| Calls | `UpdateActorAnimation` | Advance animation frame |
| Calls | `ApplyOrbitalOffsetFromRef` | Pickup child orbit motion |

---

### inventory_statue_slot

**Address:** `$00CF29` · **Size:** 84 bytes

#### Description

Scene `$FF` (inventory menu): displays collected statue items. Reads slot index from `$0E`, checks collection flag via shared `unk19_00CE97` from `statue_inventory_reward`. If uncollected, dies immediately. If collected, shows sprite via `UpdateActorAnimation` and toggles visibility based on `$0AFA` state (`#$0003` = highlighted/visible).

Depends on `statue_inventory_reward` via `?INCLUDE` for shared table access.

#### Algorithm

```
1. Position sprite (+$08,$08 offset; +$F8 Y if $0E bit $10)
2. Index unk19_00CE97 via ($0E & $0F) × 4
3. TestFlagRaw — Die if not collected
4. Set frame from table, animate
5. If $0AFA == 3: show ($10 bit $2000 set); else hide
```

#### Scene Usage

Scene `$FF` only — one slot actor per inventory row (6 slots).

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Includes | `statue_inventory_reward` | Shared `unk19_00CE97` |
| Includes | `inventory_spritemap`, `ComposeDigits_Continuation` | |

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

Door warp trigger for town scenes. Shows closed door (frame `#01`, solid high). When player approaches within 1 tile, opens (frame `#00`, clears low solid). Button `$0800` within 8-frame loop plays sound `$0E` — typically wired to scene warp via separate warp actor/trigger.

Uses `table_0EDA00` metasprite (town object sprites).

#### Scene Usage

**16** placements in town and village exterior scenes.

---

### floor_button

**Address:** `$00C9FE` · **Size:** 71 bytes

#### Description

Pressure plate actor. On init: stores flag ID from `$0E` into `$24`, points `$7F0020` at `stats_01ABF0+118` (stat block), displays frame `#0F` (unpressed), sets solid + hit callback. When struck: sets event flag via `SetFlagRaw`, animates to frame `#10` (pressed), waits 15 frames, returns to unpressed, re-arms callback.

#### Variables

| Symbol | Role |
|--------|------|
| `$0E` / `$24` | Event flag ID to set on press |
| `$7F0026` | Hit callback enable (`$FF`) |
| `stats_01ABF0+118` | Linked stat/flag block pointer |

#### Scene Usage

**7** placements — puzzle rooms (Pyramid, Edward Castle, etc.).

---

### overworld_exit

**Address:** `$00CA45` · **Size:** 791 bytes

#### Description

Complex warp/fade logic for overworld-to-world-map transitions. Entry dispatches on `$scene_current` via a cascade of `CMP`/`JMP` to scene-specific handlers. Each handler checks player position thresholds, flag bytes, and tile regions before calling `StageWorldMapChoice` with world-map coordinates and destination index.

Common pattern: zero `$0D60`, stage world map choice, then jump to `OverworldExitFinalize` which sets `$064A ← #$0400` (fade mode) and continues.

#### Handled Scenes (partial)

| Scene ID | Handler | Condition |
|----------|---------|-----------|
| `$01` | `$CACA` | Y < `$10`; flag bytes `#25`/`#26` select map node |
| `$0A` | `$CB11` | Y == `$2D0` |
| `$15` | `$CB2A` | Tile region + flag `#01`/`#4A` |
| `$1C` | `$CB5F` | Tile box `#06–#08`, `#1C–#1E` |
| `$32` | `$CB78` | Freejia exit tile + flag `#65` |
| `$3E`–`$CC` | Various | Region/flag-gated exits |

#### Variables

| Symbol | Role |
|--------|------|
| `$scene_current` | Dispatch key |
| `$player_y_pos`, `$player_x_pos` | Position gates |
| `$0D60` | World map state (zeroed on transition) |
| `$064A` | Fade/transition mode |
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
5. SpawnMarkedAfter collect_handler_gem (#$2300)
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
| `EnemyDefeatDispatch.asm` | Generic field reveal helper |

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Spawns | `collect_handler_gem` | Gem collection interaction handler |
| Includes | `interaction_handlers`, `enemy_clear_reward_table` | |

---

*Source: `extracted/actors/*.asm`, `extracted/system/statue_inventory/*`, `extracted/freejia/*`, `extracted/tables/scene_actors.asm`.*
