# Bank $00 — Actors: Scene Infrastructure

**Bank:** `$00` (mirrored at `$80`)  
**Address range:** `$00C1AA`–`$00EAED` (this document)  
**Scope:** Global camera/scene actors, movement speed zones, dream sequence controller, and large ramp boosters  
**Sources:** `extracted/actors/*.asm`, `extracted/mountain_temple/movement_speed_zones.asm`, `extracted/tables/scene_actors.asm`

These actors form the invisible infrastructure present on nearly every field scene. Most run every frame without COP-heavy scripting; they coordinate camera scroll, scene flag initialization, player speed modifiers, and ramp acceleration.

**Related:** [`readme.md`](readme.md) · [`actors-combat-interaction.md`](actors-combat-interaction.md) (visual effect pipeline fed by `camera_scroll_controller`)

---

## Overview

| Actor | Address | Size | Movable | Scene Placements |
|-------|---------|------|---------|------------------|
| `dream_zoom_controller` | `$C1AA` | 54 B | ✓ | 1 (scene $2A) |
| `speed_zone_ew_slow` | `$C1DF` | 57 B | ✓ | 9 (Mountain Temple) |
| `speed_zone_ew_fast` | `$C218` | 57 B | ✓ | 3 (Kress Maze) |
| `speed_zone_ns_fast_unused` | `$C251` | 53 B | ✓ | **0** (dead code) |
| `speed_zone_ns_slow` | `$C286` | 53 B | ✓ | 4 (Mountain Temple) |
| `large_ramp_booster` | `$C963` | 43 B | **No** | 3 (Incan Ruins, Diamond Mine) |
| `scene_flag_init` | `$C667` | 8 B | ✓ | 26 |
| `camera_scroll_controller` | `$EAED` | 174 B | ✓ | 220+ |

---

## Camera & Scene Management

### camera_scroll_controller

**Address:** `$00EAED` · **Size:** 174 bytes

#### Description

The most-used actor in Illusion of Gaia. Placed at actor slot `#01` in 220+ field scenes, it runs every frame to compute camera scroll deltas from the player's pixel position. It reads `$camera_offset_x/y` and `$camera_bounds_x/y` (scene-defined limits), clamps the desired scroll position, and writes pixel deltas to `$06E4` (X) and `$06E6` (Y). Those deltas feed the visual effect pipeline (`effect_velocity_init` → `effect_position_update` → `effect_subpixel_math`).

On first entry, sets actor flag `$1000` via `TSB $12` and calls `SetEntryHere`. If `$06EE` bit `$0200` is set (camera frozen), the actor returns immediately without updating scroll.

The main path uses `PHD`/`TCD` with `$09F4` (player actor DP base) to read player coords at `$14`/`$16`, derives tile coords into `$player_x_pos`, `$player_y_pos`, `$player_x_tile`, `$player_y_tile`, then applies a 128-pixel dead zone centered on the current scroll before clamping to bounds.

#### Algorithm

```
1. SetEntryHere; exit if $06EE bit $0200 (camera lock)
2. Read player X/Y from actor WRAM ($14, $16)
3. Derive sub-tile player positions and tile indices
4. If $player_flags bit $0100 clear:
     a. Compute target scroll X: player X − $80, clamp to [$camera_offset_x, $camera_bounds_x − $100]
     b. Store in $06BE
     c. Same for Y into $06C2 using $camera_offset_y / $camera_bounds_y
5. $06E4 ← $06BE − $068A  (scroll delta X)
6. $06E6 ← $06C2 − $068E  (scroll delta Y)
7. RTL
```

#### Variables

| Symbol | Role |
|--------|------|
| `$14`, `$16` | Player pixel X/Y (via actor DP) |
| `$player_x_pos`, `$player_y_pos` | Player position minus sprite anchor offset |
| `$player_x_tile`, `$player_y_tile` | Tile coordinates (÷16) |
| `$player_flags` | Bit `$0100` skips scroll computation |
| `$camera_offset_x/y` | Minimum scroll position |
| `$camera_bounds_x/y` | Maximum scroll position |
| `$06BE`, `$06C2` | Computed target scroll |
| `$068A`, `$068E` | Current scroll position |
| `$06E4`, `$06E6` | Output scroll deltas (effect pipeline input) |
| `$06EE` | Bit `$0200` = freeze camera updates |

#### Scene Usage

Present at slot `#01` in virtually every overworld, dungeon, and town field scene. Documented count: **220** references in `scene_actors.asm`. Not placed in menus, boot screens, or pure cutscene-only scenes.

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Feeds | `effect_velocity_init` | Consumes `$06E4`/`$06E6` |
| Paired with | `ScrollCameraTrack`, `ScrollCameraVertical` | Slot `#02` camera actors in boss/special scenes |

---

### scene_flag_init

**Address:** `$00C667` · **Size:** 8 bytes

#### Description

One-shot infrastructure actor bundled as slot `#03` or `#04` in 26 scene templates. On its first (and only) tick it clears event flag byte `#00` via `COP [SetFlagByte] (#00)`, then immediately dies. This ensures a clean per-scene flag state before other actors read flag bytes on entry.

#### Algorithm

```
1. COP SetFlagByte (#00)   ; clear flag byte 0
2. COP Die
```

#### Variables

None directly — operates through the COP flag system (WRAM flag byte `#00`).

#### Scene Usage

**26** placements in `scene_actors.asm`, typically slot `#03` or `#04` with coords `#00,#01,#00`. Used on scene templates that require a fresh flag-byte baseline (overworld exits, dream sequences, multi-act dungeons).

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Related | Event flag system | See [`event-flags.md`](event-flags.md) |

---

## Movement Speed Zones (Mountain Temple)

Four invisible 16×16 pixel trigger boxes that modify `$player_speed_ew` or `$player_speed_ns` when the player enters the zone. All four are **pure 65C816** — no COP commands, no `?INCLUDE` dependencies. They compare actor position to `$player_actor` WRAM using Manhattan distance checks.

### speed_zone_ew_slow

**Address:** `$00C1DF` · **Size:** 57 bytes

#### Description

When the player is within a 16×16 box centered on this actor's tile, sets east-west movement speed to `$FFF9` (−7). Used in Mountain Temple corridors to slow the player on narrow E-W paths.

#### Algorithm

```
1. |player_x + 8 − actor_x| < $10  AND  |player_y + 8 − actor_y| < $10
2. If both true: $player_speed_ew ← $FFF9 (−7)
3. RTL
```

#### Variables

| Symbol | Role |
|--------|------|
| `$player_actor` | Index of player actor slot |
| `$player_speed_ew` | East-west velocity (16-bit signed) |
| `$14`, `$16` | Actor anchor position |

#### Scene Usage

**9** placements — Mountain Temple (`mtA0`/`mtA1` scenes).

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Block | `movement_speed_zones` | Grouped with other speed zone actors |
| Distinct from | `ramps.asm` | Directional tile ramp system |

---

### speed_zone_ew_fast

**Address:** `$00C218` · **Size:** 57 bytes

#### Description

Same proximity test as `speed_zone_ew_slow`, but sets `$player_speed_ew` to `#7` (+7). Used in Kress Maze to accelerate E-W movement on straightaways.

#### Variables

Same as `speed_zone_ew_slow`; writes `#$0007` instead of `$FFF9`.

#### Scene Usage

**3** placements — Kress Maze.

---

### speed_zone_ns_slow

**Address:** `$00C286` · **Size:** 53 bytes

#### Description

North-south variant. Uses a tighter Y proximity threshold (`$0004` instead of `$0010`) — the player must be nearly aligned on the N-S axis. Sets `$player_speed_ns` to `$FFF9` (−7).

#### Algorithm

```
1. |player_x + 8 − actor_x| < $10
2. |player_y − actor_y| < $04   ; tighter N-S alignment
3. If both: $player_speed_ns ← $FFF9
```

#### Scene Usage

**4** placements — Mountain Temple.

---

### speed_zone_ns_fast_unused

**Address:** `$00C251` · **Size:** 53 bytes

#### Description

Byte-identical logic pattern to `speed_zone_ns_slow` but writes `$player_speed_ns ← #7`. **No scene references** in `scene_actors.asm` — a dead duplicate left in ROM. Should not be placed without verifying no runtime spawn paths reference it.

#### Scene Usage

**None** — zero placements.

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Duplicate of | `speed_zone_ns_slow` | Same N-S proximity test, opposite speed sign |

---

## Dream Sequence

### dream_zoom_controller

**Address:** `$00C1AA` · **Size:** 54 bytes

#### Description

Gold Ship dream sequence (scene `$2A` / 42): drives a scroll/zoom countdown from `$A0` → `$40`. On entry, exits immediately if flag byte `#0E` bit `#01` is set (`ExitIfFlagByte`). Otherwise computes offset values `$F6`/`$FA` from current scroll `$068A`/`$068E`, seeds countdown register `$FE` with `$A0`, then decrements `$FE` by 2 each frame until it falls below `$40`, at which point the actor dies.

#### Algorithm

```
1. ExitIfFlagByte (#0E, #01) — skip if dream already completed
2. $F6 ← $88 − $068A;  $FA ← $180 − $068E;  $FE ← $A0
3. SetEntryHere loop:
     $FE ← $FE − 2
     If $FE ≥ $40: RTL (continue next frame)
     Die
```

#### Variables

| Symbol | Role |
|--------|------|
| `$068A`, `$068E` | Current scroll X/Y |
| `$00F6`, `$00FA` | Dream scroll offset targets |
| `$00FE` | Zoom countdown ($A0 → $40) |
| Flag byte `#0E` | Dream completion gate |

#### Scene Usage

**1** placement — Gold Ship dream scene only (slot `#04`, coords `#00,#01,#01`).

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Paired with | `dream_palette_loop` thinker | Same dream scene palette cycling |

---

## Large Ramps

### large_ramp_booster

**Address:** `$00C963` · **Size:** 43 bytes (actor) + 33 bytes (embedded code)

#### Description

Accelerates player speed by ±1 when the player is within 2-tile proximity on an active ramp tile. Requires non-zero `$player_speed_ew` or `$player_speed_ns` (player must already be moving). Uses `BranchIfPlayerNear` with radius `#02` then `#03` in a loop: if E-W speed is negative, decrements; if positive, increments. Repeats while player remains near.

Pure 65C816 for the speed adjustment path; minimal COP (`SetEntryHere`, `BranchIfPlayerNear`). **Distinct from** the `ramps.asm` directional ramp system (`ramp_east` at `$D310`) which handles tile-based slope physics.

**Not movable.**

#### Algorithm

```
1. If $player_speed_ew OR $player_speed_ns == 0: RTL
2. SetEntryHere
3. BranchIfPlayerNear (#02) → speed adjust code
4. RTL if player left range
5. Adjust $player_speed_ew ±1 based on sign
6. Loop via BranchIfPlayerNear (#03)
```

#### Variables

| Symbol | Role |
|--------|------|
| `$player_speed_ew` | Modified ±1 when on ramp |
| `$player_speed_ns` | Gate — must be non-zero to activate |

#### Scene Usage

| Scene | ID | Placements |
|-------|-----|------------|
| Incan Ruins | `$22` | 1 (slot `#17`) |
| Diamond Mine | `$41` | 2 (slots `#12`, `#13`) |

**3** total placements in `scene_actors.asm`.

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Distinct from | `ramps` block (`ramp_east`) | Tile-slope system at `$D310` |

---

*Source: `extracted/actors/*.asm`, `extracted/mountain_temple/movement_speed_zones.asm`, `extracted/tables/scene_actors.asm`.*
