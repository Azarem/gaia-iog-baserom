# Bank $00 — Actors: Player Transitions, Rewards & Inventory

**Bank:** `$00` (mirrored at `$80`)  
**Address range:** `$00C2BB`–`$00CF29` (this document)  
**Scope:** Red jewel rewards, player transition animation library, statue/inventory system, location-specific interactables, and field reveal collectibles

These actors handle player-facing progression: stat rewards from red jewels, cutscene/warp player animations, statue collectible grants, town doors, pressure plates, overworld map transitions, and animated field pickups.

**Related:** [`actors-combat-interaction.md`](actors-combat-interaction.md) (stat reward VFX, push handlers) · [`bank00-upper-analysis.md`](../bank00-upper-analysis.md)

---

## Overview

| Actor / Block | Old Name | Address | Movable | Scene / Spawn |
|---------------|----------|---------|---------|---------------|
| `red_jewel_reward_handler` | `actor_00C2BB` | `$C2BB` | ✓ | 5 scenes |
| `player_transition_handlers` | `entry_points_00C418` | `$C418`–`$C5E3` | **No** | Library (`$&` refs) |
| `freejia_street_prop` | `actor_00C62D` | `$C62D` | ✓ | Freejia ($32) |
| `hidden_red_jewel` | `hidden_red_jewel` | `$C672` | ✓ | 16 scenes |
| `town_door` | `town_door` | `$C5A3` | ✓ | 16 scenes |
| `floor_button` | `floor_button` | `$C9FE` | ✓ | 7 scenes |
| `overworld_exit` | `overworld_exit` | `$CA45` | ✓ | 15 overworld scenes |
| `statue_inventory_reward` | `actor_00CD59` | `$CD59` | ✓ | Scene $FD |
| `inventory_statue_slot` | `actor_00CF29` | `$CF29` | ✓ | Scene $FF |
| `field_reveal_object` | `actor_00DA78` | `$DA78` | ✓ | Runtime spawn |

---

## Red Jewel Rewards

### red_jewel_reward_handler

| Property | Value |
|----------|-------|
| **Old Name** | `actor_00C2BB` |
| **New Name** | `red_jewel_reward_handler` |
| **Hex Address** | `$00C2BB` (script `$C2BE`, table `$C312`, helper `$C33E`) |
| **Decimal Address** | 49851 |
| **Size** | 220 bytes |
| **Type** | `actor_def` (priority `#20`) |
| **ASM File** | `extracted/actors/red_jewel_reward_handler.asm` |
| **Movable** | Yes (move with `reward_table_01AADE`) |
| **Priority** | High — boss reward scenes |

#### Description

Maps `$scene_current` to a reward tier via embedded lookup table `unk5_00C312`, then applies HP/STR/DEF increments from `reward_table_01AADE`. Only activates when `$player_flags` bit `$0020` is set (player in reward-eligible state, typically post-boss). Uses WRAM flag offset `$0100` range to prevent duplicate rewards per scene index.

The helper at `$C33E` walks the reward table byte-by-byte: value `1` → increment `$0ACA` (HP), `2` → increment `$0ADE` (STR), `3` → increment `$0ADC` (DEF). Each tier sets a `$0300` scene flag before applying.

#### Algorithm

```
1. Scan unk5_00C312 for matching $scene_current
2. TestWramFlag_Offset100 — skip if already rewarded
3. Require $player_flags bit $0020
4. Load reward tier from table entry + 1
5. JSR code_00C33E — apply stat increments via reward_table_01AADE
6. Update $0B22 (HP display delta)
7. SetWramFlag_Offset100 — mark scene rewarded
8. SetEntryContinue loop
```

#### Variables

| Symbol | Role |
|--------|------|
| `$scene_current` | Scene index lookup key |
| `$player_flags` | Bit `$0020` = reward eligible |
| `$0ACA` | Current HP |
| `$0ACE` | Base HP (for delta calc) |
| `$0ADE` | STR stat |
| `$0ADC` | DEF stat |
| `$0B22` | HP bar display delta |
| `$20` | Saved table index |
| `unk5_00C312` | Scene → reward tier mapping (5 boss scenes + padding) |
| `reward_table_01AADE` | Tier → stat increment byte stream |

#### Scene Usage

**5** placements — post-boss reward scenes:

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
| Includes | `reward_table_01AADE` | Must move together |
| Includes | `cop_handlers_script` | Flag/stat COP helpers |
| Related | `field_reveal_object` | Also reads `reward_table_01AADE` |
| Cataloged in | `us/blocks.json` @ 49851 | |

---

## Player Transition Handlers Library

### player_transition_handlers

| Property | Value |
|----------|-------|
| **Old Name** | `entry_points_00C418` |
| **New Name** | `player_transition_handlers` |
| **Hex Address** | `$00C418`–`$00C5E3` |
| **Decimal Address** | 50200–50659 |
| **Size** | 460 bytes (11 sub-functions) |
| **Type** | Multi-part `Code` block |
| **ASM File** | `extracted/actors/player_transition_handlers.asm` |
| **Movable** | **No** — widely referenced via `$&` short addresses |

#### Description

Library of COP scripts for cutscene and warp player animations. Not placed directly in scenes; referenced by `$&func_00C4xx` pointers from warp handlers, boss scripts, and `chunk_03BAE1`. All player-control-restoration paths converge on `$@code_02C3C8` (bank `$02` normal player AI).

Includes: `player_character`, `table_0EE000` (generic metasprite table).

#### Sub-Functions

| Part | Address | Old Name | New Name | Behavior |
|------|---------|----------|----------|----------|
| 1 | `$C418` | `func_00C418` | `SpawnSparkleEffect` | Spawns sparkle anim via `SpawnLastRel`, sound `$09`, frame `$2A` |
| 2 | `$C432` | `func_00C432` | `HoldPlayerSpriteLoop1` | Loops player sprite frame `#01` (or `#11` if flag byte `#00` set) |
| 3 | `$C43D` | `func_00C43D` | `HoldPlayerSpriteLoop11` | Loops player sprite frame `#11` |
| 4 | `$C446` | `func_00C446` | `HoldBodySpriteLoop` | Body sprite `#04`, frame `#1F`, infinite anim loop |
| 5 | `$C455` | `func_00C455` | `HoldBodySpriteRelease` | Clears `$10` bit `$0200` (releases body hold) |
| 6 | `$C45A` | `func_00C45A` | `RestorePlayerControlDirect` | `JML $@code_02C3C8` |
| 7 | `$C45E` | `func_00C45E` | `PlayerWakeAnim` | Body `#04`, frame `#20`, anim once, RTL |
| 8 | `$C46D` | `func_00C46D` | `PlayerWakeReturn` | Wake anim → `JML code_02C3C8` |
| 9 | `$C479` | `func_00C479` | `WarpClimbAnim` | Masks joypad, vertical climb + sound `$2C`, 8-frame Y move |
| 10 | `$C4D1` | `func_00C4D1` | `GardenJumpAnim` | Sky Garden ledge jump: V-flip, multi-stage Y moves, landing sound |
| 11 | `$C557` | `func_00C557` | `FallIntoHoleAnim` | Fall through hollow tile: body `#08`, solid probe, sink anim |

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Included by | `warps_interaction.asm`, `chunk_038000`, `chunk_03BAE1` | `$&` pointer tables |
| Called from | `sg4D_jump_handler`, `ir29_castoth`, `gw8A_sand_fanger`, Gold Ship scenes | `JumpScript` / pointer assignment |
| Returns to | `code_02C3C8` | Bank `$02` player control |

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

Single-instruction entry: `JML $@code_02C3C8`. Used when no wake animation is needed.

---

### PlayerWakeAnim / PlayerWakeReturn (`$C45E` / `$C46D`)

Sleep/wake sequence: sets body `#04`, plays frame `#20` once. `PlayerWakeReturn` adds the `JML` to normal control after the anim.

---

### WarpClimbAnim (`$C479`)

Vertical warp climb used in ladder/rope transitions:

1. Masks joypad (`$CFF0`), sets `$player_flags` bit `$0800`
2. Waits 3 frames, moves Y + `$80`
3. 8-frame animated Y climb (move IDs `$19`/`$1C`)
4. Sound `$2C`, restores flags, `JML code_02C3C8`

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
4. Restore player control via `code_02C3C8`

---

## Statue / Inventory System

### statue_inventory_reward

| Property | Value |
|----------|-------|
| **Old Name** | `actor_00CD59` |
| **New Name** | `statue_inventory_reward` |
| **Hex Address** | `$00CD59` (script `$CD5C`, data `$CE97`) |
| **Decimal Address** | 52569 |
| **Size** | 464 bytes |
| **Type** | `actor_def` (priority `#30`, scene `$FD`) |
| **ASM File** | `extracted/system/statue_inventory/statue_inventory_reward.asm` |
| **Movable** | Yes |

#### Description

Scene `$FD` (statue inventory overlay): grants statue collectibles when the player selects an uncollected slot. Flow: event flag check → item display via `func_03CA55` → fanfare wait → sparkle FX spawn → restore prior scene.

Contains shared data `unk19_00CE97` — a **6×3-byte slot table** mapping flag ID, display frame, and inventory index. Spawns 6 animated pickup children (`code_00CEAF`) during fanfare, then random sparkle particles (`code_00CEFF`).

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
| Includes | `chunk_03BAE1`, `cop_handlers_script`, `inventory_spritemap` | |
| Shared data | `unk19_00CE97` | Read by `inventory_statue_slot` |
| Calls | `func_03CA55` | Advance animation frame |
| Calls | `ApplyOrbitalOffsetFromRef` | Pickup child orbit motion |

---

### inventory_statue_slot

| Property | Value |
|----------|-------|
| **Old Name** | `actor_00CF29` |
| **New Name** | `inventory_statue_slot` |
| **Hex Address** | `$00CF29` (script `$CF2C`, display `$CF63`) |
| **Decimal Address** | 53033 |
| **Size** | 84 bytes |
| **Type** | `actor_def` (priority `#38`, scene `$FF`) |
| **ASM File** | `extracted/system/inventory/inventory_statue_slot.asm` |
| **Movable** | Yes |

#### Description

Scene `$FF` (inventory menu): displays collected statue items. Reads slot index from `$0E`, checks collection flag via shared `unk19_00CE97` from `statue_inventory_reward`. If uncollected, dies immediately. If collected, shows sprite via `func_03CA55` and toggles visibility based on `$0AFA` state (`#$0003` = highlighted/visible).

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
| Includes | `inventory_spritemap`, `chunk_03BAE1` | |

---

## Location-Specific Actors

### freejia_street_prop

| Property | Value |
|----------|-------|
| **Old Name** | `actor_00C62D` |
| **New Name** | `freejia_street_prop` |
| **Hex Address** | `$00C62D` (script `$C630`) |
| **Decimal Address** | 50733 |
| **Size** | 58 bytes |
| **Type** | `actor_def` (priority `#10`, scene `freejia`) |
| **ASM File** | `extracted/freejia/freejia/freejia_street_prop.asm` |
| **Movable** | Yes |

#### Description

Interactive scenery in Freejia (scene `$32`). Displays metasprite frame `#07`, sets solid high tile, waits for player proximity. When player presses button `$0800` within range, plays sound `$01`. When player enters tile, clears low solid and switches to frame `#00` (opened/activated state).

Structurally identical to `town_door` but uses frame `#07` and sound `$01` instead of door frame `#01` / sound `$0E`.

#### Scene Usage

**2** placements in Freejia street scene.

---

### hidden_red_jewel

| Property | Value |
|----------|-------|
| **Old Name** | `hidden_red_jewel` |
| **New Name** | `hidden_red_jewel` |
| **Hex Address** | `$00C672` (script `$C672`, interact `$C681`) |
| **Decimal Address** | 50799 |
| **Size** | 117 bytes |
| **Type** | `actor_def` (priority `#30`) |
| **ASM File** | `extracted/actors/hidden_red_jewel.asm` |
| **Movable** | Yes |

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

| Property | Value |
|----------|-------|
| **Old Name** | `town_door` |
| **New Name** | `town_door` |
| **Hex Address** | `$00C5A3` (script `$C5F6`) |
| **Decimal Address** | 50675 |
| **Size** | 58 bytes |
| **Type** | `actor_def` (priority `#10`) |
| **ASM File** | `extracted/actors/town_door.asm` |
| **Movable** | Yes |

#### Description

Door warp trigger for town scenes. Shows closed door (frame `#01`, solid high). When player approaches within 1 tile, opens (frame `#00`, clears low solid). Button `$0800` within 8-frame loop plays sound `$0E` — typically wired to scene warp via separate warp actor/trigger.

Uses `table_0EDA00` metasprite (town object sprites).

#### Scene Usage

**16** placements in town and village exterior scenes.

---

### floor_button

| Property | Value |
|----------|-------|
| **Old Name** | `floor_button` |
| **New Name** | `floor_button` |
| **Hex Address** | `$00C9FE` (script `$C9FE`, callback `$CA2D`) |
| **Decimal Address** | 51707 |
| **Size** | 71 bytes |
| **Type** | `actor_def` (priority `#01`) |
| **ASM File** | `extracted/actors/floor_button.asm` |
| **Movable** | Yes |

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

| Property | Value |
|----------|-------|
| **Old Name** | `overworld_exit` |
| **New Name** | `overworld_exit` |
| **Hex Address** | `$00CA45` (dispatch `$CA45`, handlers `$CACA`–`$CD38`) |
| **Decimal Address** | 51778 |
| **Size** | 791 bytes |
| **Type** | `actor_def` (priority `#30`) |
| **ASM File** | `extracted/actors/overworld_exit.asm` |
| **Movable** | Yes |

#### Description

Complex warp/fade logic for overworld-to-world-map transitions. Entry dispatches on `$scene_current` via a cascade of `CMP`/`JMP` to scene-specific handlers. Each handler checks player position thresholds, flag bytes, and tile regions before calling `StageWorldMapChoice` with world-map coordinates and destination index.

Common pattern: zero `$0D60`, stage world map choice, then jump to `code_00CAC1` which sets `$064A ← #$0400` (fade mode) and continues.

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

| Property | Value |
|----------|-------|
| **Old Name** | `actor_00DA78` |
| **New Name** | `field_reveal_object` |
| **Hex Address** | `$00DA78` (script `$DA78`–`$DB88`) |
| **Decimal Address** | 55928 |
| **Size** | 274 bytes |
| **Type** | `Code` (spawned, not scene-placed) |
| **ASM File** | `extracted/actors/field_reveal_object.asm` |
| **Movable** | Yes (with includes) |

#### Description

Animated reveal/collectible spawned at runtime when a hidden field object is discovered. **Not placed in `scene_actors.asm`** — spawned via `SpawnAfterFlags` from boss scripts and field actors.

On spawn: checks `$scene_current` against `reward_table_01AADE` to select HP/STR/DEF/gem sprite variant via `SwitchCase`. If already collected (`TestFlag_0300`), uses alternate frame path. Animates upward reveal (7-frame Y rise with solid check), moves toward player (`MoveToward`), then spawns `push_handler_light` for collection interaction.

#### Algorithm

```
1. Select sprite variant from reward_table_01AADE[$scene_current] & 3
2. Animate Y rise (7 frames, solid-aware)
3. MoveToward player + StageForceMoveXY
4. Wait 11 frames
5. SpawnMarkedAfter push_handler_light (#$2300)
6. Loop anim until $28 < 8, then fade
```

#### Variables

| Symbol | Role |
|--------|------|
| `$26` | Rise frame counter |
| `$24` | Saved Y position |
| `$28` | Fade/anim phase |
| `$7F0020` | Parent actor link |
| `reward_table_01AADE` | Scene → reward type index |

#### Scene Usage

Runtime spawn only — called from:

| Caller | Context |
|--------|---------|
| `pyCC_mystic_ball.asm` | Pyramid mystic ball reveal |
| `awB1_wall_walker.asm` | Angkor wall walker drop |
| `func_0AA43F.asm` | Generic field reveal helper |

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Spawns | `push_handler_light` | Collection nudge handler |
| Includes | `push_interaction_handlers`, `reward_table_01AADE` | |
| Cataloged in | `us/blocks.json` @ 55928 | |

---

*Source: `extracted/actors/*.asm`, `extracted/system/statue_inventory/*`, `extracted/freejia/*`, `us/blocks.json`, `extracted/tables/scene_actors.asm`.*
