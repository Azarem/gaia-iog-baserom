# Bank $00 — Smooth Scroll & Camera Pan System

**Bank:** `$00` (mirrored at `$80`)  
**Address range:** `$00E683`–`$00F292`  
**Size:** ~3,376 bytes, 22+ parts across 3 blocks  
**Files:** [`extracted/system/engine/smooth_follow.asm`](../../../extracted/system/engine/smooth_follow.asm), [`camera_scroll.asm`](../../../extracted/system/engine/camera_scroll.asm), [`forced_walk.asm`](../../../extracted/system/engine/forced_walk.asm)

Three **separate engineering layers** share this address region but do not overlap at runtime:

1. **Smooth follow engine** (`smooth_follow.asm`) — NPC/helper **movement** utility (16-direction chase). Not placed in `scene_actors`; spawned via `SpawnAfterMarked` from boss/follower scripts.
2. **Scroll-ratio camera actors + helpers** (`camera_scroll.asm`) — usually scene record `#02`; fill **`cameraDeltaX/Y`** from spawn bytes × `cameraTarget*`.
3. **Forced walk / camera pan** (`forced_walk.asm`) — one-shot player auto-walk during warps; sets **`playerFlags` `$0100`** and COP **`CameraPan*`**.

The **default player camera** for field scenes is **`camera_scroll_controller`** at record `#01` ([`actors-infrastructure.md`](actors-infrastructure.md)), **not** `ScrollCameraTrack`. Track is the most common **slot `#02`** scroll-mode actor (**105** static placements).

**Related:** [`actors-infrastructure.md`](actors-infrastructure.md) · [`functions-camera-motion.md`](functions-camera-motion.md) · [`slider-glide-system.md`](slider-glide-system.md) · [`utility-math-movement.md`](utility-math-movement.md)

## Source of truth

| File | Contents |
|------|----------|
| `extracted/system/engine/smooth_follow.asm` | Follow/chase engine + `FollowSlopeDitherTable` |
| `extracted/system/engine/camera_scroll.asm` | `ScrollCamera*` actors, `TileAlign*`, `ComputeScrollDeltas` |
| `extracted/system/engine/forced_walk.asm` | `ForcedWalk*` + read/sync helpers |
| `extracted/actors/camera_scroll_controller.asm` | Player target + `effectDeltaX/Y` (documented in actors-infrastructure) |
| `extracted/tables/scene_actors.asm` | Static placement counts for `ScrollCamera*` |

**Naming:** All function and actor labels above are **extracted**. Size column entries marked **~** or “estimated span” are **label-to-label** byte differences, not always instruction-counted sizes.

**Counts:** Scene usage figures are **static `actor-spawn` records** in `scene_actors.asm` (rg count, this session).

## Live code vs legacy / dead

| Symbol | Status |
|--------|--------|
| Smooth follow entry points | **Live** — spawned from `aw_spirit_follower`, `dm_follower_behavior`, `sg4D_knight_armor`, `pyDD_queen_spirit_attack`, `mu5F_flasher`, `sE8_dark_gaia`, `sEA_solid_arm`, plus `smooth_follow_child` tail calls |
| `ScrollCamera*` actors | **Live** — scene table placements |
| `ForcedWalk*` | **Live** — `StartForcedWalk` during extended warps |
| `forcedScrollOverride` (`$06C8`) writers | **Live** writers in `ScrollCameraInit` / layer-1 actors; **no reader** found outside layer-1 block (per extracted comments) |
| `CopySiblingFollowState` / `InitFollowAndChase` | **Not scene-placed** — **indirect** only via COP spawn from scripts |

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

### Block Structure

| Block | Parts | Address Range |
|-------|-------|---------------|
| `smooth_follow` | Follow engine + angle/step resolve + tables | `$E683`–`$F192` |
| `camera_scroll` | 4 camera actors + tile/scroll utilities | `$E94D`–`$ED0B` |
| `forced_walk` | 4 forced walks + sprite/sync helpers | `$EB9B`–`$ED84` (overlaps camera_scroll labels — same ROM bank, different subsystems) |

### Include Dependencies

| Include | Purpose |
|---------|---------|
| `MulDivide` | Signed multiply/clamp helper |
| `ComposeDigitSprites_AtCursor` | Shared actor/engine constants (bank `$03`) |
| `dir_sprite_01ABDE` | Direction-indexed sprite table (facing frames) |
| `forced_walk_pan_table` | Forced-walk pan step lists (bank `$00`) |
| `move_chain_table` | Animation frame duration lookup |

### Subsystem Breakdown

| Subsystem | Functions | Purpose |
|-----------|-----------|---------|
| Smooth follow engine | `CopySiblingFollowState`, `InitFollowAndChase`, 8 direction handlers, `ApplyFollowMovement`, `SelectFallbackDirection`, 16 sprite handlers | NPC/platform sliding |
| Camera scroll actors | `ScrollCameraInit`, `ScrollCameraTrack`, `ScrollCameraVertical`, `ScrollCameraAccumulate` | Per-scene camera management |
| Forced walk functions | `ForcedWalkSouth/North/West/East` | Player auto-walk during transitions |
| Utilities | Tile align, scroll delta, sprite read, player sync | Coordinate helpers |
| Data | `FollowDirectionTable`, `FollowSlopeDitherTable` | Dispatch + interpolation |

---

## Smooth Follow Engine

**File:** `extracted/system/engine/smooth_follow.asm` only. This block is a **movement utility** reused by follower helpers and `smooth_follow_child`; it is **not** a camera scroll driver and does not write `cameraTarget*` or BG scroll registers.

### CopySiblingFollowState

**Address:** `$00E683` · **Size:** 35 bytes (instruction span)

#### Description

Copies follow state from the sibling actor referenced by `$0004,Y` (predecessor link): `$7F0014,X` ← sibling sprite index; `$7F000A,X` ← sibling movement param. Falls through to `ChasePlayerLoop` at `FollowChaseMainLoop`.

#### Algorithm

```
1. LDY $0004          ; Sibling actor index
2. LDA $7F0014,Y → $7F0014,X  ; Copy sprite index
3. LDA $7F000A,Y → $7F000A,X  ; Copy movement param
4. BRA ChasePlayerLoop
```

---

### InitFollowAndChase

**Address:** `$00E6A6` · **Estimated span:** through `SelectFallbackDirection` (~561 B label gap — includes embedded chase handlers)

#### Description

Main entry point for the smooth follow/chase engine. Performs the same sibling copy as `CopySiblingFollowState`, but additionally sets `$7F000E,X = $FFFF` (reset direction state), then enters `ChasePlayerLoop`.

#### ChasePlayerLoop (`FollowChaseMainLoop`)

The core tracking loop computes signed delta X/Y from the actor to the player (`$24` = player actor reference), determines the dominant axis via absolute magnitude comparison, and dispatches to one of 8 directional handler blocks:

| Condition | Direction Block | Handler |
|-----------|----------------|---------|
| +X, +Y, Y > X | `FollowChaseHeadSSE` | NE-biased (Y dominant) |
| +X, +Y, X > Y | `FollowChaseHeadESE` | NE-biased (X dominant) |
| +X, -Y, Y > X | `FollowChaseHeadNNE` | SE-biased (Y dominant, neg) |
| +X, -Y, X > Y | `FollowChaseHeadENE` | SE-biased (X dominant, neg) |
| -X, +Y, Y > X | `FollowChaseHeadSSW` | NW-biased (Y dominant) |
| -X, +Y, X > Y | `FollowChaseHeadWSW` | NW-biased (X dominant) |
| -X, -Y, Y > X | `FollowChaseHeadNNW` | SW-biased (Y dominant, neg) |
| -X, -Y, X > Y | `FollowChaseHeadWNW` | SW-biased (X dominant, neg) |

Each handler calls either `ComputeFollowAngle` or `ComputeFollowAngleAlt`, then `SelectFallbackDirection`. All handlers converge at `ApplyFollowMovement`.

---

### ApplyFollowMovement

**Address:** `$00E87E` · **Size:** ~60 bytes

#### Description

Applies computed movement deltas (`$0000`/`$0002`) to both the actor and its linked sibling. Updates position, stores velocity in `$7F002C,X`/`$7F002E,X`. If `$7F0012,X ≥ 8`, resets to zero and re-enters `ChasePlayerLoop` via `COP [SetEntryExitNow]`.

---

### SelectFallbackDirection

**Address:** `$00E8BA` · **Size:** ~13 bytes

#### Description

When the computed direction index indicates the target was already reached, routes through `COP [SwitchCase]` on the low 3 bits to resume from the correct directional handler entry point. Dispatch table: `code_list_00E8C7` — 8 entries mapping back to handler midpoints.

---

## Camera Pan Actors

**File:** `extracted/system/engine/camera_scroll.asm`. These are **scroll-ratio** actors, usually scene record **`#02`** (after `camera_scroll_controller` at `#01`). Spawn X/Y bytes encode **MulDivide** ratio operands (see file header), not world tile positions — common bytes `#11,#11`, `#21,#00`, `#DF,#DF` (Init only).

```text
Chase loop (smooth follow) — each frame while helper lives:
  FollowChaseMainLoop → octant handler → ComputeFollowAngle(Alt)
    → ResolveFacing* → ComputeFollowStep (FollowSlopeDitherTable)
    → ApplyFollowMovement → (SetEntryExitNow when sub-step ≥ 8) → loop

Forced walk pan — single activation on player actor:
  mask joypad → read walk stream → scrollStepTableBase from forced_walk_pan_table
    → CameraPan* (COP, yields until pan done) → ApplyScrollOffset
    → SyncPlayerToCamera → unmask → Die
  (camera_scroll_controller keeps publishing effectDeltaX/Y from held cameraTarget*)

Scroll delta accumulation (ScrollCameraTrack / Accumulate):
  TileAlignPosition → ComputeScrollDeltas
    → cameraDeltaX/Y = MulDivide(cameraTarget*, packed spawn ratio)
  Accumulate adds DP $24/$26 each frame after ComputeScrollDeltas
```

### ScrollCameraInit

**Address:** `$00E94D` · **Size:** 62 bytes

#### Description

Mt. Kress / special overworld scrolling. Tiles self-position to grid via `TileAlignCoord`, then loops 3 times calling `ComputeScrollDeltas` with `LoopInit`/`LoopNext`. Copies `$06C4` → `$0690`, sets forced scroll override `$06C8 = $06C0 | $8000`, then clears `$06C0`.

- **Special behavior:** `$12` bit `$1000` set (invisible actor), loops via `COP [LoopInit] #03`
- **Scene usage:** **12** static placements — spawn **`#DF,#DF`** (Mt. Kress chain and related maps)

---

### ScrollCameraTrack

**Address:** `$00EA96` · **Size:** 17 bytes

#### Description

Simplest scroll-ratio actor — `TileAlignPosition`, then `ComputeScrollDeltas` every frame. **Most common slot `#02` scroll-mode actor**, not the player-follow camera (that is `camera_scroll_controller` at `#01`).

- **Scene usage:** **105** static placements (`scene_actors.asm`; extracted header comment: ~100 lists, 87 with spawn `#11,#11`)

---

### ScrollCameraVertical

**Address:** `$00EAA7` · **Size:** 28 bytes

#### Description

Camera actor variant for vertically-scrolling maps. Same base behavior as `ScrollCameraTrack` but also computes vertical scroll offset: if `$16 ≠ 0`, calls `MulDivide(Y=$06C2)` and stores result to `$06C4`.

- **Scene usage:** **15** static placements (Edward's Castle, Itory, Incan Ruins, Dao — per `scene_actors.asm`)

---

### ScrollCameraAccumulate

**Address:** `$00EAC3` · **Size:** 42 bytes

#### Description

Camera actor that accumulates scroll offsets from direct-page variables `$24`/`$26` into the global camera deltas `$06C0`/`$06C4` each frame. Used in Pyramid scenes with moving platforms.

- **Scene usage:** **5** static placements (Pyramid interiors)

---

## Forced Walk Functions

**File:** `extracted/system/engine/forced_walk.asm`. Spawned on the **player** by `StartForcedWalk` during extended warp transitions (not scene-table actors). Each variant follows the same pattern:

1. Clear `$12` bits `$6000`, set entry continue
2. Mask joypad (`$FFFF` → `$joypad_mask_std`), zero `$0656`
3. Read direction sprite + animation duration from `dir_sprite_01ABDE` / `move_chain_table`
4. Clear actor flags, stage player sprite, animate once
5. Look up walk pan pointer from `forced_walk_pan_table` → `scrollStepTableBase` (`$06E0`), zero `$2A`, reset X
6. Execute `COP [CameraPan*]` in the appropriate direction (COP names in `copdef.json`)
7. Apply scroll position offset via `ApplyScrollOffset`
8. Re-read direction sprite, re-animate
9. Sync player position via `SyncPlayerToCamera`
10. Unmask joypad, `COP [Die]`

### ForcedWalkSouth

**Address:** `$00EB9B` · **Size:** 84 bytes

- **COP:** `CameraPanDown`
- **Sprite lookup:** `ReadDirSprite_YVelocity` → `$2E`

### ForcedWalkNorth

**Address:** `$00EBEF` · **Size:** 84 bytes

- **COP:** `CameraPanUp`
- **Sprite lookup:** `ReadDirSprite_YVelocity`

### ForcedWalkWest

**Address:** `$00EC43` · **Size:** 84 bytes

- **COP:** `CameraPanLeft`
- **Sprite lookup:** `ReadDirSprite_XVelocity` → `$2C`

### ForcedWalkEast

**Address:** `$00EC97` · **Size:** 84 bytes

- **COP:** `CameraPanRight`
- **Sprite lookup:** `ReadDirSprite_XVelocity`

---

## Utility Subroutines

### TileAlignCoord

**Address:** `$00ECEB` · **Size:** 13 bytes

Aligns a pixel coordinate to the tile grid: `A >> 4` (divide by 16) with 8-bit precision, mask to `$0F0F`. Returns result in Y. Called by `ScrollCameraInit`, `TileAlignPosition`.

### TileAlignPosition

**Address:** `$00ECF8` · **Size:** 19 bytes

Tile-aligns both actor X (`$14 - 8`) and Y (`$16`) via `TileAlignCoord`, storing results back to `$14`/`$16`. Called by `ScrollCameraTrack`, `ScrollCameraVertical`, `ScrollCameraAccumulate`.

### ComputeScrollDeltas

**Address:** `$00ED0B` · **Size:** 29 bytes

Computes camera scroll deltas. If `$14 ≠ 0`, calls `MulDivide(Y=$06BE)` → `$06C0`. If `$16 ≠ 0`, calls `MulDivide(Y=$06C2)` → `$06C4`. Called by `ScrollCameraInit`, `ScrollCameraTrack`, `ScrollCameraAccumulate`.

### ReadDirSprite_YVelocity

**Address:** `$00ED28` · **Size:** 32 bytes

Reads direction byte from forced-walk data stream at `$0650`, looks up sprite index from `dir_sprite_01ABDE` and animation duration from `move_chain_table`. Stores sprite to `$0000`, duration to `$2E`. Called by `ForcedWalkSouth`, `ForcedWalkNorth`.

### ReadDirSprite_XVelocity

**Address:** `$00ED48` · **Size:** 32 bytes

Same as Y variant but stores duration to `$2C` (X velocity). Called by `ForcedWalkWest`, `ForcedWalkEast`.

### ApplyScrollOffset

**Address:** `$00ED68` · **Size:** 28 bytes

Reads 4-byte position delta from data stream at `$0650`, adds to actor position `$14`/`$16`, advances stream pointer by 4. Called by all four forced walk functions.

### SyncPlayerToCamera

**Address:** `$00ED84` · **Size:** 36 bytes

Copies actor position to player actor, sets player flags for normal walking (`OR $0008, AND $FDFF` on `$10`), copies animation state `$28`, zeros wait counter `$0008`. Called by all four forced walk functions.

### ComputeFollowAngle

**Address:** `$00EDA8` · **Size:** ~27 bytes

Computes angular step for smooth follow. Compares primary/secondary axis distances, uses `UnsignedDivide` (step count calculator) to derive 16-step direction index. Primary axis is `$0018` (X distance). Stores result in `$7F0010,X`.

### ComputeFollowAngleAlt

**Address:** `$00EDC3` · **Size:** ~93 bytes

Same as `ComputeFollowAngle` but axes swapped — primary is `$001C` (Y distance). Shares tail code with primary variant.

### ComputeFollowStep

**Address:** `$00EE1C` · **Size:** 96 bytes

Computes pixel movement step from follow angle. Uses `$7F0010,X` (angle) and `$7F0012,X` (sub-step) as table index into `FollowSlopeDitherTable` (`FollowSlopeDitherTable`). Accumulates fractional movement. Called by all 8 direction handlers.

### ResolveFacingFromAxisBase

**Address:** `$00EE7C` · **Size:** ~18 bytes

Entry point A — resolves follow direction for primary-axis-dominant cases. Branches on `$7F0010,X` value ranges (< 5, 5–12, ≥ 13) into speed categories.

### ResolveFacingFromDiagonalBase

**Address:** `$00EE8C` · **Size:** ~228 bytes

Entry point B — resolves follow direction for secondary-axis-dominant cases. Updates `$7F000E,X` (direction index 0–15), dispatches to one of 16 sprite/priority handlers via `FollowDirectionTable`, calls `UpdateActorAnimation` to advance animation.

---

## Direction Sprite Handlers

**Address range:** `$00EF92`–`$00F172`  
**Count:** 16 handlers (one per 22.5° direction)  
**Size:** ~33 bytes each (~545 bytes total including jump table)

Each handler sets the actor's OAM flags (`$000E,Y`) for correct sprite priority/mirror bits and computes the walking sprite index stored in `$0000` and angular step in `$7F0010,X`. Returns with RTS.

| Handler | Index | Address | OAM Priority Bits | Walk Direction | Step |
|---------|-------|---------|-------------------|----------------|------|
| `FollowDirHandler00` | 0 (N) | `$EF92` | `AND $3FFF` (front) | `$0001` | `$10` |
| `FollowDirHandler01` | 1 (NNE) | `$EFB0` | `AND $3FFF` | `$0001` | `$08` |
| `FollowDirHandler02` | 2 (NE) | `$EFCE` | `AND $3FFF` | `$0002` | `$00` |
| `FollowDirHandler03` | 3 (ENE) | `$EFEC` | `AND $3FFF` | `$0002` | `$08` |
| `FollowDirHandler04` | 4 (E) | `$F00A` | `AND $3FFF` | `$0003` | `$10` |
| `FollowDirHandler05` | 5 (ESE) | `$F028` | `OR $8000` (H-flip) | `$0003` | `$08` |
| `FollowDirHandler06` | 6 (SE) | `$F049` | `OR $8000` | `$0004` | `$00` |
| `FollowDirHandler07` | 7 (SSE) | `$F06A` | `OR $8000` | `$0004` | `$08` |
| `FollowDirHandler08` | 8 (S) | `$F08B` | `OR $8000` | `$0005` | `$10` |
| `FollowDirHandler09` | 9 (SSW) | `$F0AC` | `OR $C000` (H+V flip) | `$0005` | `$08` |
| `FollowDirHandler0A` | 10 (SW) | `$F0CD` | `OR $C000` | `$0006` | `$00` |
| `FollowDirHandler0B` | 11 (WSW) | `$F0EE` | `OR $C000` | `$0006` | `$08` |
| `FollowDirHandler0C` | 12 (W) | `$F10F` | `OR $4000` (V-flip) | `$0007` | `$10` |
| `FollowDirHandler0D` | 13 (WNW) | `$F130` | `OR $4000` | `$0007` | `$08` |
| `FollowDirHandler0E` | 14 (NW) | `$F151` | `OR $4000` | `$0008` | `$00` |
| `FollowDirHandler0F` | 15 (NNW) | `$F172` | `OR $4000` | `$0008` | `$08` |

---

## Data Tables

### FollowDirectionTable

**Address:** `$00EF72` · **Size:** 32 bytes (16 × 2-byte pointers)

Jump table for the 16-direction smooth follow sprite handlers. Indexed by `$7F000E,X & $0F`.

### FollowSlopeDitherTable

**Address:** `$00F193` · **Size:** 544 bytes

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
| Chase direction blocks (8) | `ResolveFacingFromAxisBase` / `ResolveFacingFromDiagonalBase` | 8 |
| Forced walks (4) | `ReadDirSprite_YVelocity` / `ReadDirSprite_XVelocity` | 4 |
| Forced walks (4) | `ApplyScrollOffset` | 4 |
| Forced walks (4) | `SyncPlayerToCamera` | 4 |
| Camera actors (3) | `TileAlignPosition` | 3 |
| Camera actors (3) | `ComputeScrollDeltas` | 3 |
| `TileAlignPosition` | `TileAlignCoord` | 2 |
| `ResolveFacingFromDiagonalBase` | 16 direction handlers | 16 |
| Direction handlers (16) | `UpdateActorAnimation` | 16 |

### External Calls

| Target | Bank | Called By | Purpose |
|--------|------|-----------|---------|
| `MulDivide` | `$02` | `ComputeScrollDeltas`, `ScrollCameraVertical` | Signed multiply/clamp |
| `UnsignedDivide` | `$02` | `ComputeFollowAngle`/`Alt` | Step count calculation |
| `UpdateActorAnimation` | `$03` | `ResolveFacingFromDiagonalBase` (×16) | Advance sprite animation |
| `dir_sprite_01ABDE` | `$01` | `ReadDirSprite_*` | Direction sprite lookup |
| `forced_walk_pan_table` | `$00` | Forced walks | Pan step list pointer |
| `walk_step_table`, `move_chain_table` | `$00` / `$01` | `ReadDirSprite_*` | Animation + velocity curve |
| `move_chain_table` | `$01` | `ReadDirSprite_*` | Animation duration |

---

## Scene Usage Summary

| Actor / Function | Static placements | Areas / mechanism |
|------------------|-------------------|-----------------|
| `camera_scroll_controller` | **220** lists @ `#01` | Player camera target + `effectDeltaX/Y` — see [`actors-infrastructure.md`](actors-infrastructure.md) |
| `ScrollCameraTrack` | **105** @ `#02` | Towns / overworlds (ratio `#11,#11` common) |
| `ScrollCameraVertical` | **15** @ `#02` | Edward's Castle, Itory, Incan Ruins, Dao |
| `ScrollCameraAccumulate` | **5** @ `#02` | Pyramid interiors |
| `ScrollCameraInit` | **12** @ `#02` | Mt. Kress chain (`#DF,#DF`) |
| `Layer1DriftUnbounded` / `Wrapped` | **6** / **16** | Layer-1 drift — [`actors-infrastructure.md`](actors-infrastructure.md) |
| Forced walks | **0** in table | Warp script spawn → `CameraPan*` |
| `InitFollowAndChase` / `CopySiblingFollowState` | **0** in table | `SpawnAfterMarked` from follower/boss scripts |

### Camera actor → scene class map

| Scene class | Record `#01` | Typical record `#02` |
|-------------|--------------|----------------------|
| Standard field (220 lists) | `camera_scroll_controller` | `ScrollCameraTrack` (105) or Init (12) / Vertical (15) / Accumulate (5) |
| Sky Garden `$4E` / `$50` (examples) | `camera_scroll_controller` | `Layer1DriftUnbounded` |
| Babel plane `$DC` | player | `Layer1DriftUnbounded` only (no controller in table) |
| Menus / boot / `$89` prologue | varies | no standard pair |

### Relationship to `camera_scroll_controller`

`camera_scroll_controller` updates **`cameraTargetX/Y`** and **`effectDeltaX/Y`**. `ScrollCamera*` actors update **`cameraDeltaX/Y`** (layer-1 scroll position / ratio path). Layer-1 drift actors consume **`effectDeltaX/Y`**. Forced walk sets **`playerFlags` `$0100`** and drives **`CameraPan*`** while the controller keeps differencing targets against live scroll.

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

| # | Name | Address | Size |
|---|------|---------|------|
| 1 | `CopySiblingFollowState` | `$E683` | 35 B |
| 2 | `InitFollowAndChase` | `$E6A6` | 561 B |
| 3 | `ApplyFollowMovement` | `$E87E` | ~60 B |
| 4 | `SelectFallbackDirection` | `$E8BA` | ~13 B |
| 5 | `ScrollCameraInit` | `$E94D` | 62 B |
| 6 | `ScrollCameraTrack` | `$EA96` | 17 B |
| 7 | `ScrollCameraVertical` | `$EAA7` | 28 B |
| 8 | `ScrollCameraAccumulate` | `$EAC3` | 42 B |
| 9 | `ForcedWalkSouth` | `$EB9B` | 84 B |
| 10 | `ForcedWalkNorth` | `$EBEF` | 84 B |
| 11 | `ForcedWalkWest` | `$EC43` | 84 B |
| 12 | `ForcedWalkEast` | `$EC97` | 84 B |
| 13 | `TileAlignCoord` | `$ECEB` | 13 B |
| 14 | `TileAlignPosition` | `$ECF8` | 19 B |
| 15 | `ComputeScrollDeltas` | `$ED0B` | 29 B |
| 16 | `ReadDirSprite_YVelocity` | `$ED28` | 32 B |
| 17 | `ReadDirSprite_XVelocity` | `$ED48` | 32 B |
| 18 | `ApplyScrollOffset` | `$ED68` | 28 B |
| 19 | `SyncPlayerToCamera` | `$ED84` | 36 B |
| 20 | `ComputeFollowAngle` | `$EDA8` | ~27 B |
| 21 | `ComputeFollowAngleAlt` | `$EDC3` | ~93 B |
| 22 | `ComputeFollowStep` | `$EE1C` | 96 B |
| 23 | `ResolveFacingFromAxisBase` | `$EE7C` | ~18 B |
| 24 | `ResolveFacingFromDiagonalBase` | `$EE8C` | ~228 B |
| 25–40 | Direction handlers 0–15 | `$EF92`–`$F172` | ~33 B each |
| 41 | `FollowDirectionTable` | `$EF72` | 32 B |
| 42 | `FollowSlopeDitherTable` | `$F193` | 544 B |

---

## Source validation

**Files checked:** `smooth_follow.asm`, `camera_scroll.asm`, `forced_walk.asm`, `camera_scroll_controller.asm`, `layer1_scroll_actors.asm`, `scene_actors.asm`, `forced_walk` block comments, `db-us/names/bank00.json` (entry addresses).

**Verified:** Subsystem separation; **`ScrollCameraTrack` ≠ default player camera**; scene placement counts (**105** / **15** / **5** / **12**); spawn-byte semantics in `camera_scroll.asm` header; forced walk uses **`forced_walk_pan_table`** and **`CameraPan*`**; external **`MulDivide`** (`$02`), **`UpdateActorAnimation`** (`$03`), direction tables in `$00`/`$01`.

**Notes:** Address ranges **`$E94D`–`$ED84`** interleave camera_scroll utilities with forced_walk — use label names, not span alone, when patching. Statistics table sizes mix counted and **estimated** spans.

*Primary sources: `extracted/system/engine/smooth_follow.asm`, `camera_scroll.asm`, `forced_walk.asm`.*
