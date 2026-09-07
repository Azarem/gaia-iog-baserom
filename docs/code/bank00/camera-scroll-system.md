# Bank $00 — Smooth Scroll & Camera Pan System

**Bank:** `$00` (mirrored at `$80`)  
**Address range:** `$00E683`–`$00F292`  
**Size:** ~3,376 bytes, 22+ parts across 3 blocks  
**Files:** `extracted/system/chunk_00E683.asm` (legacy monolith); split across `smooth_follow`, `camera_scroll`, `forced_walk` in `us/blocks.json`

Implements two distinct subsystems: a **smooth actor follow/chase engine** (sliding actors on a 16-direction grid) and a **forced camera pan system** (elevation-transition autoscrolls), plus four scene camera infrastructure actors and interpolation data tables.

**Related:** [`actors-infrastructure.md`](actors-infrastructure.md) (`camera_scroll_controller` at `$EAED`) · [`stair-climb-system.md`](stair-climb-system.md) · [`utility-math-movement.md`](utility-math-movement.md)

---

## Table of Contents

1. [System Overview](#system-overview)
2. [Smooth Follow Engine](#smooth-follow-engine)
3. [Camera Pan Actors](#camera-pan-actors)
4. [Forced Walk Functions](#forced-walk-functions)
5. [Utility Subroutines](#utility-subroutines)
6. [Direction Sprite Handlers](#direction-sprite-handlers)
7. [Data Tables](#data-tables)
8. [Variable Maps](#variable-maps)
9. [Call Reference Matrix](#call-reference-matrix)
10. [Scene Usage Summary](#scene-usage-summary)
11. [Statistics](#statistics)

---

## System Overview

### Block Structure (blocks.json)

| Block | Parts | Address Range |
|-------|-------|---------------|
| `smooth_follow` | Follow engine + angle/step resolve + tables | `$E683`–`$F192` |
| `camera_scroll` | 4 camera actors + tile/scroll utilities | `$E94D`–`$ED0B` |
| `forced_walk` | 4 forced walks + sprite/sync helpers | `$EB9B`–`$ED84` |

### Include Dependencies

| Include | Purpose |
|---------|---------|
| `chunk_028000` | `func_028000` — signed multiply/clamp helper |
| `chunk_03BAE1` | `func_03CA55` — advance sprite animation frame |
| `dir_sprite_01ABDE` | Direction-indexed sprite table (facing frames) |
| `table_01A95E` | Camera scroll speed table |
| `table_01B086` | Animation frame duration lookup |

### Subsystem Breakdown

| Subsystem | Functions | Purpose |
|-----------|-----------|---------|
| Smooth follow engine | `CopySiblingFollowState`, `InitFollowAndChase`, 8 direction handlers, `ApplyFollowMovement`, `SelectFallbackDirection`, 16 sprite handlers | NPC/platform sliding |
| Camera scroll actors | `ScrollCameraInit`, `ScrollCameraTrack`, `ScrollCameraVertical`, `ScrollCameraAccumulate` | Per-scene camera management |
| Forced walk functions | `ForcedWalkSouth/North/West/East` | Player auto-walk during transitions |
| Utilities | Tile align, scroll delta, sprite read, player sync | Coordinate helpers |
| Data | `FollowDirectionTable`, `SmoothFollowLookup` | Dispatch + interpolation |

---

## Smooth Follow Engine

### CopySiblingFollowState

| Property | Value |
|----------|-------|
| **Old Name** | `func_00E683` |
| **New Name** | `CopySiblingFollowState` |
| **Hex Address** | `$00E683` |
| **Decimal Address** | 59011 |
| **End Address** | `$00E6A6` (59046) |
| **Size** | 35 bytes |

#### Description

Copies follow state from the sibling actor referenced by `$0004,Y` (predecessor link): `$7F0014,X` ← sibling sprite index; `$7F000A,X` ← sibling movement param. Falls through to `ChasePlayerLoop` at `code_00E6CE`.

#### Algorithm

```
1. LDY $0004          ; Sibling actor index
2. LDA $7F0014,Y → $7F0014,X  ; Copy sprite index
3. LDA $7F000A,Y → $7F000A,X  ; Copy movement param
4. BRA ChasePlayerLoop
```

---

### InitFollowAndChase

| Property | Value |
|----------|-------|
| **Old Name** | `func_00E6A6` |
| **New Name** | `InitFollowAndChase` |
| **Hex Address** | `$00E6A6` |
| **Decimal Address** | 59046 |
| **End Address** | `$00E87E` (59518) |
| **Size** | 561 bytes (includes chase logic through `SelectFallbackDirection`) |

#### Description

Main entry point for the smooth follow/chase engine. Performs the same sibling copy as `CopySiblingFollowState`, but additionally sets `$7F000E,X = $FFFF` (reset direction state), then enters `ChasePlayerLoop`.

#### ChasePlayerLoop (`code_00E6CE`)

The core tracking loop computes signed delta X/Y from the actor to the player (`$24` = player actor reference), determines the dominant axis via absolute magnitude comparison, and dispatches to one of 8 directional handler blocks:

| Condition | Direction Block | Handler |
|-----------|----------------|---------|
| +X, +Y, Y > X | `code_00E7A5` | NE-biased (Y dominant) |
| +X, +Y, X > Y | `code_00E789` | NE-biased (X dominant) |
| +X, -Y, Y > X | `code_00E736` | SE-biased (Y dominant, neg) |
| +X, -Y, X > Y | `loc_00E763` | SE-biased (X dominant, neg) |
| -X, +Y, Y > X | `code_00E7CE` | NW-biased (Y dominant) |
| -X, +Y, X > Y | `code_00E7FB` | NW-biased (X dominant) |
| -X, -Y, Y > X | `code_00E850` | SW-biased (Y dominant, neg) |
| -X, -Y, X > Y | `code_00E821` | SW-biased (X dominant, neg) |

Each handler calls either `ComputeFollowAngle` or `ComputeFollowAngleAlt`, then `SelectFallbackDirection`. All handlers converge at `ApplyFollowMovement`.

---

### ApplyFollowMovement

| Property | Value |
|----------|-------|
| **Old Name** | (within `func_00E6A6`) |
| **New Name** | `ApplyFollowMovement` |
| **Hex Address** | `$00E87E` |
| **Decimal Address** | 59518 |
| **End Address** | `$00E8BA` (59578) |
| **Size** | ~60 bytes |

#### Description

Applies computed movement deltas (`$0000`/`$0002`) to both the actor and its linked sibling. Updates position, stores velocity in `$7F002C,X`/`$7F002E,X`. If `$7F0012,X ≥ 8`, resets to zero and re-enters `ChasePlayerLoop` via `COP [SetEntryExitNow]`.

---

### SelectFallbackDirection

| Property | Value |
|----------|-------|
| **Old Name** | (within `func_00E6A6`) |
| **New Name** | `SelectFallbackDirection` |
| **Hex Address** | `$00E8BA` |
| **Decimal Address** | 59578 |
| **End Address** | `$00E8C7` (59591) |
| **Size** | ~13 bytes |

#### Description

When the computed direction index indicates the target was already reached, routes through `COP [SwitchCase]` on the low 3 bits to resume from the correct directional handler entry point. Dispatch table: `code_list_00E8C7` — 8 entries mapping back to handler midpoints (`follow_fallback_table` in names.json).

---

## Camera Pan Actors

Scene-infrastructure actors placed at slot #2 in nearly every overworld/town scene (typically at position `$11,$11` or `$21,$21` off-screen).

### ScrollCameraInit

| Property | Value |
|----------|-------|
| **Old Name** | `actor_00E94D` |
| **New Name** | `ScrollCameraInit` |
| **Hex Address** | `$00E94D` |
| **Decimal Address** | 59725 |
| **End Address** | `$00EA96` (59787) |
| **Size** | 62 bytes |
| **Type** | `actor_def` |

#### Description

Mt. Kress / special overworld scrolling. Tiles self-position to grid via `TileAlignCoord`, then loops 3 times calling `ComputeScrollDeltas` with `LoopInit`/`LoopNext`. Copies `$06C4` → `$0690`, sets forced scroll override `$06C8 = $06C0 | $8000`, then clears `$06C0`.

- **Special behavior:** `$12` bit `$1000` set (invisible actor), loops via `COP [LoopInit] #03`
- **Scene usage:** Mt. Kress scenes only — always at position `$DF,$DF`

---

### ScrollCameraTrack

| Property | Value |
|----------|-------|
| **Old Name** | `actor_00EA96` |
| **New Name** | `ScrollCameraTrack` |
| **Hex Address** | `$00EA96` |
| **Decimal Address** | 60054 |
| **End Address** | `$00EAA7` (60071) |
| **Size** | 17 bytes |
| **Type** | `actor_def` |

#### Description

Simplest camera actor — aligns self to tile grid via `TileAlignPosition`, then calls `ComputeScrollDeltas` every frame. **Default camera controller** used in most town/overworld scenes.

- **Scene usage:** **~40+** scenes — the most common camera actor in the game

---

### ScrollCameraVertical

| Property | Value |
|----------|-------|
| **Old Name** | `actor_00EAA7` |
| **New Name** | `ScrollCameraVertical` |
| **Hex Address** | `$00EAA7` |
| **Decimal Address** | 60071 |
| **End Address** | `$00EAC3` (60099) |
| **Size** | 28 bytes |
| **Type** | `actor_def` |

#### Description

Camera actor variant for vertically-scrolling maps. Same base behavior as `ScrollCameraTrack` but also computes vertical scroll offset: if `$16 ≠ 0`, calls `func_028000(Y=$06C2)` and stores result to `$06C4`.

- **Scene usage:** Edward's Castle, Itory Village, Incan Ruins, Dao — **~10** scenes

---

### ScrollCameraAccumulate

| Property | Value |
|----------|-------|
| **Old Name** | `actor_00EAC3` |
| **New Name** | `ScrollCameraAccumulate` |
| **Hex Address** | `$00EAC3` |
| **Decimal Address** | 60099 |
| **End Address** | `$00EAED` (60141) |
| **Size** | 42 bytes |
| **Type** | `actor_def` |

#### Description

Camera actor that accumulates scroll offsets from direct-page variables `$24`/`$26` into the global camera deltas `$06C0`/`$06C4` each frame. Used in Pyramid scenes with moving platforms.

- **Scene usage:** Pyramid D6/D7/D9/DA interiors — **~5** scenes

---

## Forced Walk Functions

Automated player walk in a cardinal direction during scene transitions involving stairs or elevation changes. Each follows the same 10-step pattern:

1. Clear `$12` bits `$6000`, set entry continue
2. Mask joypad (`$FFFF` → `$joypad_mask_std`), zero `$0656`
3. Read direction sprite + animation duration from `dir_sprite_01ABDE` / `table_01B086`
4. Clear actor flags, stage player sprite, animate once
5. Look up camera scroll speed from `table_01A95E` → `$06E0`, zero `$2A`, reset X
6. Execute `COP [PanCamera*]` in the appropriate direction
7. Apply scroll position offset via `ApplyScrollOffset`
8. Re-read direction sprite, re-animate
9. Sync player position via `SyncPlayerToCamera`
10. Unmask joypad, `COP [Die]`

### ForcedWalkSouth

| Property | Value |
|----------|-------|
| **Old Name** | `func_00EB9B` |
| **New Name** | `ForcedWalkSouth` |
| **Hex Address** | `$00EB9B` |
| **Decimal Address** | 60315 |
| **Size** | 84 bytes |
| **COP** | `PanCameraDown` |
| **Sprite lookup** | `ReadDirSprite_YVelocity` → `$2E` |

### ForcedWalkNorth

| Property | Value |
|----------|-------|
| **Old Name** | `func_00EBEF` |
| **New Name** | `ForcedWalkNorth` |
| **Hex Address** | `$00EBEF` |
| **Decimal Address** | 60399 |
| **Size** | 84 bytes |
| **COP** | `PanCameraUp` |
| **Sprite lookup** | `ReadDirSprite_YVelocity` |

### ForcedWalkWest

| Property | Value |
|----------|-------|
| **Old Name** | `func_00EC43` |
| **New Name** | `ForcedWalkWest` |
| **Hex Address** | `$00EC43` |
| **Decimal Address** | 60483 |
| **Size** | 84 bytes |
| **COP** | `PanCameraLeft` |
| **Sprite lookup** | `ReadDirSprite_XVelocity` → `$2C` |

### ForcedWalkEast

| Property | Value |
|----------|-------|
| **Old Name** | `func_00EC97` |
| **New Name** | `ForcedWalkEast` |
| **Hex Address** | `$00EC97` |
| **Decimal Address** | 60567 |
| **Size** | 84 bytes |
| **COP** | `PanCameraRight` |
| **Sprite lookup** | `ReadDirSprite_XVelocity` |

---

## Utility Subroutines

### TileAlignCoord

| Property | Value |
|----------|-------|
| **Old Name** | `sub_00ECEB` |
| **New Name** | `TileAlignCoord` |
| **Hex Address** | `$00ECEB` |
| **Decimal Address** | 60651 |
| **Size** | 13 bytes |

Aligns a pixel coordinate to the tile grid: `A >> 4` (divide by 16) with 8-bit precision, mask to `$0F0F`. Returns result in Y. Called by `ScrollCameraInit`, `TileAlignPosition`.

### TileAlignPosition

| Property | Value |
|----------|-------|
| **Old Name** | `sub_00ECF8` |
| **New Name** | `TileAlignPosition` |
| **Hex Address** | `$00ECF8` |
| **Decimal Address** | 60664 |
| **Size** | 19 bytes |

Tile-aligns both actor X (`$14 - 8`) and Y (`$16`) via `TileAlignCoord`, storing results back to `$14`/`$16`. Called by `ScrollCameraTrack`, `ScrollCameraVertical`, `ScrollCameraAccumulate`.

### ComputeScrollDeltas

| Property | Value |
|----------|-------|
| **Old Name** | `sub_00ED0B` |
| **New Name** | `ComputeScrollDeltas` |
| **Hex Address** | `$00ED0B` |
| **Decimal Address** | 60683 |
| **Size** | 29 bytes |

Computes camera scroll deltas. If `$14 ≠ 0`, calls `func_028000(Y=$06BE)` → `$06C0`. If `$16 ≠ 0`, calls `func_028000(Y=$06C2)` → `$06C4`. Called by `ScrollCameraInit`, `ScrollCameraTrack`, `ScrollCameraAccumulate`.

### ReadDirSprite_YVelocity

| Property | Value |
|----------|-------|
| **Old Name** | `sub_00ED28` |
| **New Name** | `ReadDirSprite_YVelocity` |
| **Hex Address** | `$00ED28` |
| **Decimal Address** | 60712 |
| **Size** | 32 bytes |

Reads direction byte from forced-walk data stream at `$0650`, looks up sprite index from `dir_sprite_01ABDE` and animation duration from `table_01B086`. Stores sprite to `$0000`, duration to `$2E`. Called by `ForcedWalkSouth`, `ForcedWalkNorth`.

### ReadDirSprite_XVelocity

| Property | Value |
|----------|-------|
| **Old Name** | `sub_00ED48` |
| **New Name** | `ReadDirSprite_XVelocity` |
| **Hex Address** | `$00ED48` |
| **Decimal Address** | 60744 |
| **Size** | 32 bytes |

Same as Y variant but stores duration to `$2C` (X velocity). Called by `ForcedWalkWest`, `ForcedWalkEast`.

### ApplyScrollOffset

| Property | Value |
|----------|-------|
| **Old Name** | `sub_00ED68` |
| **New Name** | `ApplyScrollOffset` |
| **Hex Address** | `$00ED68` |
| **Decimal Address** | 60776 |
| **Size** | 28 bytes |

Reads 4-byte position delta from data stream at `$0650`, adds to actor position `$14`/`$16`, advances stream pointer by 4. Called by all four forced walk functions.

### SyncPlayerToCamera

| Property | Value |
|----------|-------|
| **Old Name** | `sub_00ED84` |
| **New Name** | `SyncPlayerToCamera` |
| **Hex Address** | `$00ED84` |
| **Decimal Address** | 60804 |
| **Size** | 36 bytes |

Copies actor position to player actor, sets player flags for normal walking (`OR $0008, AND $FDFF` on `$10`), copies animation state `$28`, zeros wait counter `$0008`. Called by all four forced walk functions.

### ComputeFollowAngle

| Property | Value |
|----------|-------|
| **Old Name** | `sub_00EDA8` |
| **New Name** | `ComputeFollowAngle` |
| **Hex Address** | `$00EDA8` |
| **Decimal Address** | 60840 |
| **Size** | ~27 bytes |

Computes angular step for smooth follow. Compares primary/secondary axis distances, uses `func_0281E8` (step count calculator) to derive 16-step direction index. Primary axis is `$0018` (X distance). Stores result in `$7F0010,X`.

### ComputeFollowAngleAlt

| Property | Value |
|----------|-------|
| **Old Name** | `sub_00EDC3` |
| **New Name** | `ComputeFollowAngleAlt` |
| **Hex Address** | `$00EDC3` |
| **Decimal Address** | 60867 |
| **Size** | ~93 bytes |

Same as `ComputeFollowAngle` but axes swapped — primary is `$001C` (Y distance). Shares tail code with primary variant.

### ComputeFollowStep

| Property | Value |
|----------|-------|
| **Old Name** | `sub_00EE1C` |
| **New Name** | `ComputeFollowStep` |
| **Hex Address** | `$00EE1C` |
| **Decimal Address** | 60956 |
| **Size** | 96 bytes |

Computes pixel movement step from follow angle. Uses `$7F0010,X` (angle) and `$7F0012,X` (sub-step) as table index into `SmoothFollowLookup` (`binary_00F193`). Accumulates fractional movement. Called by all 8 direction handlers.

### ResolveFollowDirection

| Property | Value |
|----------|-------|
| **Old Name** | `sub_00EE7C` |
| **New Name** | `ResolveFollowDirection` |
| **Hex Address** | `$00EE7C` |
| **Decimal Address** | 61052 |
| **Size** | ~18 bytes |

Entry point A — resolves follow direction for primary-axis-dominant cases. Branches on `$7F0010,X` value ranges (< 5, 5–12, ≥ 13) into speed categories.

### ResolveFollowDirectionAlt

| Property | Value |
|----------|-------|
| **Old Name** | (within `sub_00EE7C` block) |
| **New Name** | `ResolveFollowDirectionAlt` |
| **Hex Address** | `$00EE8C` |
| **Decimal Address** | 61068 |
| **Size** | ~228 bytes |

Entry point B — resolves follow direction for secondary-axis-dominant cases. Updates `$7F000E,X` (direction index 0–15), dispatches to one of 16 sprite/priority handlers via `FollowDirectionTable`, calls `func_03CA55` to advance animation.

---

## Direction Sprite Handlers

**Address range:** `$00EF92`–`$00F172`  
**Count:** 16 handlers (one per 22.5° direction)  
**Size:** ~33 bytes each (~545 bytes total including jump table)

Each handler sets the actor's OAM flags (`$000E,Y`) for correct sprite priority/mirror bits and computes the walking sprite index stored in `$0000` and angular step in `$7F0010,X`. Returns with RTS.

| Handler | Index | Address | OAM Priority Bits | Walk Direction | Step |
|---------|-------|---------|-------------------|----------------|------|
| `code_00EF92` | 0 (N) | `$EF92` | `AND $3FFF` (front) | `$0001` | `$10` |
| `code_00EFB0` | 1 (NNE) | `$EFB0` | `AND $3FFF` | `$0001` | `$08` |
| `code_00EFCE` | 2 (NE) | `$EFCE` | `AND $3FFF` | `$0002` | `$00` |
| `code_00EFEC` | 3 (ENE) | `$EFEC` | `AND $3FFF` | `$0002` | `$08` |
| `code_00F00A` | 4 (E) | `$F00A` | `AND $3FFF` | `$0003` | `$10` |
| `code_00F028` | 5 (ESE) | `$F028` | `OR $8000` (H-flip) | `$0003` | `$08` |
| `code_00F049` | 6 (SE) | `$F049` | `OR $8000` | `$0004` | `$00` |
| `code_00F06A` | 7 (SSE) | `$F06A` | `OR $8000` | `$0004` | `$08` |
| `code_00F08B` | 8 (S) | `$F08B` | `OR $8000` | `$0005` | `$10` |
| `code_00F0AC` | 9 (SSW) | `$F0AC` | `OR $C000` (H+V flip) | `$0005` | `$08` |
| `code_00F0CD` | 10 (SW) | `$F0CD` | `OR $C000` | `$0006` | `$00` |
| `code_00F0EE` | 11 (WSW) | `$F0EE` | `OR $C000` | `$0006` | `$08` |
| `code_00F10F` | 12 (W) | `$F10F` | `OR $4000` (V-flip) | `$0007` | `$10` |
| `code_00F130` | 13 (WNW) | `$F130` | `OR $4000` | `$0007` | `$08` |
| `code_00F151` | 14 (NW) | `$F151` | `OR $4000` | `$0008` | `$00` |
| `code_00F172` | 15 (NNW) | `$F172` | `OR $4000` | `$0008` | `$08` |

---

## Data Tables

### FollowDirectionTable

| Property | Value |
|----------|-------|
| **Old Name** | `table_00EF72` |
| **New Name** | `FollowDirectionTable` |
| **Hex Address** | `$00EF72` |
| **Decimal Address** | 61298 |
| **Size** | 32 bytes (16 × 2-byte pointers) |
| **Type** | `&Code` jump table |

Jump table for the 16-direction smooth follow sprite handlers. Indexed by `$7F000E,X & $0F`.

### SmoothFollowLookup

| Property | Value |
|----------|-------|
| **Old Name** | `binary_00F193` |
| **New Name** | `SmoothFollowLookup` |
| **Hex Address** | `$00F193` |
| **Decimal Address** | 61843 |
| **End Address** | `$00F3B3` (62387) |
| **Size** | 544 bytes |
| **Type** | Binary interpolation data |

Interpolation table for smooth movement. Contains pairs of signed 16-bit values indexed by angle × sub-step, used by `ComputeFollowStep` to accumulate fractional pixel movement. Values decrease in magnitude at higher indices, creating smooth deceleration curves. Format: sequence of 16-bit words; `$0100` (1.0) at low indices tapering to `$0000` at high indices.

---

## Variable Maps

### Smooth Follow Engine

| Address | Size | Name | Used By |
|---------|------|------|---------|
| `$7F000A,X` | 2 | Movement parameter / sprite flag | `CopySiblingFollowState`, direction resolve |
| `$7F000E,X` | 2 | Direction index (0–15) | Chase loop, direction resolve |
| `$7F0010,X` | 2 | Angular step / follow angle | `ComputeFollowAngle`, direction handlers |
| `$7F0012,X` | 2 | Sub-step accumulator | `ComputeFollowStep`, `ApplyFollowMovement` |
| `$7F0014,X` | 2 | Sibling sprite index | `CopySiblingFollowState` |
| `$7F002C,X` | 2 | Applied velocity X | `ApplyFollowMovement` |
| `$7F002E,X` | 2 | Applied velocity Y | `ApplyFollowMovement` |
| `$04` | 2 | Predecessor link (sibling ID) | `ApplyFollowMovement`, follow engine |
| `$24` | 2 | Player actor reference | Chase loop player position read |
| `$0018` | 2 | Absolute X distance | Chase loop direction dispatch |
| `$001C` | 2 | Absolute Y distance | Chase loop direction dispatch |

### Camera Actor Subsystem

| Address | Size | Name | Used By |
|---------|------|------|---------|
| `$14` | 2 | Tile-aligned X | All camera actors |
| `$16` | 2 | Tile-aligned Y | All camera actors |
| `$24`/`$26` | 2 each | Scroll accumulator X/Y | `ScrollCameraAccumulate` |
| `$06BE` | 2 | Camera target X | `ComputeScrollDeltas` |
| `$06C0` | 2 | Camera delta X | `ComputeScrollDeltas`, `ScrollCameraAccumulate` |
| `$06C2` | 2 | Camera target Y | `ComputeScrollDeltas` |
| `$06C4` | 2 | Camera delta Y | `ComputeScrollDeltas`, `ScrollCameraVertical`, `ScrollCameraAccumulate` |
| `$06C8` | 2 | Forced scroll override | `ScrollCameraInit` |
| `$0690` | 2 | Saved camera delta | `ScrollCameraInit` |

### Forced Walk Subsystem

| Address | Size | Name | Used By |
|---------|------|------|---------|
| `$0650` | 2 | Walk data stream pointer | `ReadDirSprite_*`, `ApplyScrollOffset` |
| `$0656` | 2 | Filtered joypad state | Zeroed by forced walks |
| `$06E0` | 2 | Scroll speed table entry | All forced walks |
| `$06E2` | 2 | Scroll step index | All forced walks (zeroed) |
| `$2A` | 2 | Animation frame | All forced walks (zeroed) |
| `$2C` | 2 | X velocity (anim speed) | `ReadDirSprite_XVelocity` |
| `$2E` | 2 | Y velocity (anim speed) | `ReadDirSprite_YVelocity` |

---

## Call Reference Matrix

### Internal Calls

| Caller | Callee | Count |
|--------|--------|-------|
| Chase direction blocks (8) | `ComputeFollowAngle` / `ComputeFollowAngleAlt` | 8 |
| Chase direction blocks (8) | `ComputeFollowStep` | 8 |
| Chase direction blocks (8) | `ResolveFollowDirection` / `ResolveFollowDirectionAlt` | 8 |
| Forced walks (4) | `ReadDirSprite_YVelocity` / `ReadDirSprite_XVelocity` | 4 |
| Forced walks (4) | `ApplyScrollOffset` | 4 |
| Forced walks (4) | `SyncPlayerToCamera` | 4 |
| Camera actors (3) | `TileAlignPosition` | 3 |
| Camera actors (3) | `ComputeScrollDeltas` | 3 |
| `TileAlignPosition` | `TileAlignCoord` | 2 |
| `ResolveFollowDirectionAlt` | 16 direction handlers | 16 |
| Direction handlers (16) | `func_03CA55` | 16 |

### External Calls

| Target | Bank | Called By | Purpose |
|--------|------|-----------|---------|
| `func_028000` | `$02` | `ComputeScrollDeltas`, `ScrollCameraVertical` | Signed multiply/clamp |
| `func_0281E8` | `$02` | `ComputeFollowAngle`/`Alt` | Step count calculation |
| `func_03CA55` | `$03` | `ResolveFollowDirectionAlt` (×16) | Advance sprite animation |
| `dir_sprite_01ABDE` | `$01` | `ReadDirSprite_*` | Direction sprite lookup |
| `table_01A95E` | `$01` | Forced walks | Scroll speed |
| `table_01B086` | `$01` | `ReadDirSprite_*` | Animation duration |

---

## Scene Usage Summary

| Actor / Function | Scene Count | Areas |
|------------------|-------------|-------|
| `ScrollCameraTrack` | ~40+ | Nearly all towns and overworlds |
| `ScrollCameraVertical` | ~10 | Edward's Castle, Itory, Incan Ruins, Dao |
| `ScrollCameraAccumulate` | ~5 | Pyramid interiors (D6/D7/D9/DA) |
| `ScrollCameraInit` | ~10 | Mt. Kress exclusively |
| Forced walks (via COP pan) | — | All areas with elevation changes |
| `CopySiblingFollowState` / `InitFollowAndChase` | 0 direct | Called programmatically by `smooth_follow_child` and boss scripts |

### Relationship to `camera_scroll_controller`

The actor at `$EAED` (`camera_scroll_controller`) computes per-frame scroll deltas from player position and is placed at slot #1 in 220+ scenes. The camera pan actors documented here (slot #2) provide scene-specific scroll behavior variants that feed into the same `$06C0`/`$06C4` delta pipeline.

---

## Statistics

### Code Distribution

| Category | Count | Size |
|----------|-------|------|
| Follow engine (entry + chase + apply) | 4 | ~669 bytes |
| 8 direction handler blocks | 8 | (embedded in chase) |
| Apply movement + fallback | 2 | ~73 bytes |
| Camera actors | 4 | ~149 bytes |
| Forced walk functions | 4 | ~336 bytes |
| Utility subroutines | 9 | ~352 bytes |
| Direction sprite handlers | 16 | ~545 bytes |
| Data tables | 2 | ~576 bytes |
| **Total** | **~47 parts** | **~2,889 bytes** |

### Function Index

| # | New Name | Old Name | Address | Size |
|---|----------|----------|---------|------|
| 1 | `CopySiblingFollowState` | `func_00E683` | `$E683` | 35 B |
| 2 | `InitFollowAndChase` | `func_00E6A6` | `$E6A6` | 561 B |
| 3 | `ApplyFollowMovement` | (in E6A6) | `$E87E` | ~60 B |
| 4 | `SelectFallbackDirection` | (in E6A6) | `$E8BA` | ~13 B |
| 5 | `ScrollCameraInit` | `actor_00E94D` | `$E94D` | 62 B |
| 6 | `ScrollCameraTrack` | `actor_00EA96` | `$EA96` | 17 B |
| 7 | `ScrollCameraVertical` | `actor_00EAA7` | `$EAA7` | 28 B |
| 8 | `ScrollCameraAccumulate` | `actor_00EAC3` | `$EAC3` | 42 B |
| 9 | `ForcedWalkSouth` | `func_00EB9B` | `$EB9B` | 84 B |
| 10 | `ForcedWalkNorth` | `func_00EBEF` | `$EBEF` | 84 B |
| 11 | `ForcedWalkWest` | `func_00EC43` | `$EC43` | 84 B |
| 12 | `ForcedWalkEast` | `func_00EC97` | `$EC97` | 84 B |
| 13 | `TileAlignCoord` | `sub_00ECEB` | `$ECEB` | 13 B |
| 14 | `TileAlignPosition` | `sub_00ECF8` | `$ECF8` | 19 B |
| 15 | `ComputeScrollDeltas` | `sub_00ED0B` | `$ED0B` | 29 B |
| 16 | `ReadDirSprite_YVelocity` | `sub_00ED28` | `$ED28` | 32 B |
| 17 | `ReadDirSprite_XVelocity` | `sub_00ED48` | `$ED48` | 32 B |
| 18 | `ApplyScrollOffset` | `sub_00ED68` | `$ED68` | 28 B |
| 19 | `SyncPlayerToCamera` | `sub_00ED84` | `$ED84` | 36 B |
| 20 | `ComputeFollowAngle` | `sub_00EDA8` | `$EDA8` | ~27 B |
| 21 | `ComputeFollowAngleAlt` | `sub_00EDC3` | `$EDC3` | ~93 B |
| 22 | `ComputeFollowStep` | `sub_00EE1C` | `$EE1C` | 96 B |
| 23 | `ResolveFollowDirection` | `sub_00EE7C` | `$EE7C` | ~18 B |
| 24 | `ResolveFollowDirectionAlt` | (in EE7C) | `$EE8C` | ~228 B |
| 25–40 | Direction handlers 0–15 | `code_00EF92`–`$F172` | `$EF92`–`$F172` | ~33 B each |
| 41 | `FollowDirectionTable` | `table_00EF72` | `$EF72` | 32 B |
| 42 | `SmoothFollowLookup` | `binary_00F193` | `$F193` | 544 B |

---

*Source: `us/blocks.json`, `us/names.json`, `docs/code/chunk_008000-analysis.md` §chunk_00E683, `docs/cop-commands-reference.md`.*
