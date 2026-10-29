# Bank $00 — Actors: Scene Infrastructure

**Bank:** `$00` (mirrored at `$80`)  
**Address range:** `$00C1AA`–`$00EAED` (this document)  
**Scope:** Global camera/scene actors, movement speed zones, dream sequence controller, and large ramp boosters  
**Sources:** `extracted/actors/*.asm`, `extracted/mountain_temple/movement_speed_zones.asm`, `extracted/tables/scene_actors.asm`

## Source of truth

| Path | Role |
|------|------|
| `extracted/actors/camera_scroll_controller.asm` | Default per-frame player camera target + `effectDeltaX/Y` |
| `extracted/actors/layer1_scroll_actors.asm` | Layer-1 drift / wrap / parallax actors |
| `extracted/actors/scene_flag_init.asm`, `dream_zoom_controller.asm`, `large_ramp_booster.asm` | Other infrastructure actors in this doc |
| `extracted/mountain_temple/movement_speed_zones.asm` | Speed zone actor bodies |
| `extracted/system/engine/camera_scroll.asm` | Slot `#02` scroll-ratio actors (`ScrollCamera*`) — see [`camera-scroll-system.md`](camera-scroll-system.md) |
| `extracted/tables/scene_actors.asm` | Static scene placement tables |

**Naming:** Labels such as `camera_scroll_controller`, `dream_zoom_controller`, and `scene_flag_init` are **extracted** actor block names (as printed in `.asm`). WRAM symbols in actor files (`effectDeltaX`, `layerPriorityFlag`, `bg1ScrollH`) are **extracted** mnemonics from `!` aliases. Phrases like “visual effect pipeline” are **documentation shorthand** for the layer-1 scroll chain driven by `effectDeltaX/Y`.

**Counts:** Numbers in the overview table are **static `actor-spawn` records** in `extracted/tables/scene_actors.asm` unless noted. They are not runtime `SpawnAfterFlags` spawns, COP script spawns, or total label references across the repo. Unique scene lists use the block comment in `scene_actors.asm` (for example **220** lists include `camera_scroll_controller` as record `#01`).

These actors form the invisible infrastructure present on nearly every field scene. Most run every frame without COP-heavy scripting; they coordinate camera scroll, scene flag initialization, player speed modifiers, and ramp acceleration.

**Related:** [`README.md`](README.md) · [`actors-combat-interaction.md`](actors-combat-interaction.md) (visual effect pipeline fed by `camera_scroll_controller`)

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
| `camera_scroll_controller` | `$EAED` | ~173 B (estimated span) | ✓ | **220** scene lists |

---

## Infrastructure vs gameplay vs layer-1 scroll

| Layer | Extracted home | What it does |
|-------|----------------|--------------|
| **Player camera (layer 0 target)** | `camera_scroll_controller` | Computes `cameraTargetX/Y` from player position (unless forced walk holds the target) and publishes **`effectDeltaX/Y`** = target minus current BG1 scroll. Does not write hardware scroll registers. |
| **Scroll ratio / special camera mode (often slot `#02`)** | `camera_scroll.ScrollCameraTrack` and siblings in [`camera-scroll-system.md`](camera-scroll-system.md) | Each frame fills **`cameraDeltaX/Y`** via `MulDivide` from packed spawn bytes and `cameraTarget*`. Not the same as the player-follow actor at slot `#01`. |
| **Layer-1 position / drift** | `layer1_scroll_actors` (`Layer1DriftUnbounded`, `Layer1DriftWrapped`, `Layer1ParallaxRatio`) | Integrates velocity plus `effectDeltaX/Y` into **`cameraDeltaX/Y`** (layer-1 scroll position when bit `$0400` of `layerPriorityFlag` is set). |
| **Forced camera pan (cutscene warp)** | `forced_walk.asm` + COP `CameraPan*` | One-shot auto-walk: sets **`playerFlags` `$0100`**, drives pan tables, then dies. See [`camera-scroll-system.md`](camera-scroll-system.md). |
| **Ambient camera nudge (script spawn)** | `camera_drift.asm` | Short COP-spawned scripts that add to `cameraTarget*` / `cameraDelta*` — see [`functions-camera-motion.md`](functions-camera-motion.md). |

**Default field setup:** record `#00` = player, `#01` = **`camera_scroll_controller`**, `#02` = usually a `ScrollCamera*` actor or a `layer1_scroll_actors` variant (six scenes use `Layer1DriftUnbounded` instead of `ScrollCameraTrack`).

---

## Camera & Scene Management

### camera_scroll_controller

**Address:** `$00EAED` · **Size:** 174 bytes

#### Description

The primary **player-follow camera** actor. Placed at record `#01` in **220** scene actor lists (`scene_actors.asm` block comment; counted as **220** `actor-spawn` lines this session). Each frame it updates the layer-0 scroll **target** (`cameraTargetX/Y`) from the player's pixel position and writes **`effectDeltaX/Y`** (`$06E4` / `$06E6`) = target minus current BG1 scroll (`bg1ScrollH` / `mapScrollV`). Layer-1 drivers consume those deltas (see call chain below). This actor does not apply scroll to the PPU.

On entry: sets `$12` bit `$1000` (overlay / display-filter qualifier), `SetEntryHere`, then returns immediately if **`layerPriorityFlag`** (`$06EE`) bit **`$0200`** is set (camera frozen — set during attack setup in `player_character`).

The main path uses `PHD`/`TCD` with `playerActorDp` (`$09F4`) to read player `$14`/`$16`, derives `playerXPos` / `playerYPos` (sprite-adjusted) and tile indices. **There is no dead zone** in the extracted code: per axis, `t = playerPixel − $80`, clamp to `[cameraOffset, cameraBounds − $100]`, store in `cameraTargetX/Y`. While **`playerFlags` bit `$0100`** (forced walk) is set, target recomputation is **skipped**, but **deltas are still computed** from whatever target `forced_walk` left in `cameraTarget*`.

#### Algorithm

```
1. SetEntryHere; exit if layerPriorityFlag bit $0200 (camera frozen)
2. D := playerActorDp; refresh playerXPos/YPos and playerXTile/YTile
3. If playerFlags bit $0100 clear:
     a. cameraTargetX ← clamp(player X − $80, cameraOffsetX, cameraBoundsX − $100)
     b. cameraTargetY ← same for Y with cameraOffsetY / cameraBoundsY
4. effectDeltaX ← cameraTargetX − bg1ScrollH ($068A)
5. effectDeltaY ← cameraTargetY − mapScrollV ($068E)
6. RTL
```

#### Variables

| Symbol | Role |
|--------|------|
| `$14`, `$16` | Player pixel X/Y (via actor DP) |
| `$player_x_pos`, `$player_y_pos` | Player position minus sprite anchor offset |
| `$player_x_tile`, `$player_y_tile` | Tile coordinates (÷16) |
| `playerFlags` | Bit `$0100` = forced walk — skip **target** update only |
| `cameraOffsetX/Y`, `cameraBoundsX/Y` | Scene window edges (`$06D6`–`$06DC`) |
| `cameraTargetX/Y` | Layer-0 scroll target (`$06BE` / `$06C2`) |
| `bg1ScrollH`, `mapScrollV` | Current BG1 scroll (`$068A` / `$068E`) |
| `effectDeltaX/Y` | Target − current scroll (`$06E4` / `$06E6`) |
| `layerPriorityFlag` | Bit `$0200` = freeze all updates; bit `$0400` = layer-1 scroll mode |

#### Scene Usage

Record `#01` in **220** scene lists (all player-starting field templates except special menus/cutscenes listed in `scene_actors.asm` §“17 lists do not start with the player”). Not the same as slot `#02` `ScrollCameraTrack` (**105** placements) — that actor computes **`cameraDeltaX/Y`**, not `effectDeltaX/Y`.

#### Call chain (layer-1 scroll)

```text
camera_scroll_controller (slot #01)
  → effectDeltaX/Y each frame
       ↓
Layer1DriftUnbounded | Layer1DriftWrapped  (optional; 6 or 16 scene placements)
  → adds effectDelta* + constant velocity → cameraDeltaX/Y (+ wrap on Wrapped)
       ↓
CameraSmoothScroll / upload path (camera_tilemap.asm) when layerPriorityFlag bit $0400 set
  → BG2 scroll from cameraDelta* / effectScrollH/V

Layer1ParallaxRatio — runtime spawn only (Viper arena / mystic statue); not in scene_actors table
ScrollCameraTrack / Vertical / Init / Accumulate — parallel slot #02 path into cameraDelta* (see camera-scroll-system.md)
```

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Feeds | `Layer1DriftUnbounded`, `Layer1DriftWrapped` | Read `effectDeltaX/Y` |
| Paired with | `ScrollCameraTrack`, `ScrollCameraVertical`, … | Usually record `#02`; scroll **ratio** actors |
| Related | [`camera-scroll-system.md`](camera-scroll-system.md) | Smooth follow, forced walk, `ScrollCamera*` utilities |
| Related | [`functions-camera-motion.md`](functions-camera-motion.md) | Script-spawned `camera_drift` nudges |

---

### scene_flag_init

**Address:** `$00C667` · **Size:** 8 bytes

#### Description

One-shot infrastructure actor in **26** scene actor lists (`actor-spawn` count in `scene_actors.asm`; slots `#02`–`#04`, plus `#14` / `#1A` / `#1C` once each). On its first tick it **sets event flag index `#00`** via `COP [SetFlagByte] (#00)` (a **bit index**, not a byte), then `Die`. Scene setup already clears the first event-flag word, so this actor re-asserts flag `#00` after the scene is live.

#### Algorithm

```
1. COP SetFlagByte (#00)   ; set flag index 0
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

**9** static placements — **6** in Mountain Temple scenes (`$A0`–`$A3` region), **3** in Kress Maze scene **`$A7`** (same file block as `ScrollCameraInit` at `#DF,#DF`).

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

Adds ±1 to `$player_speed_ew` **once per approach** when the player is already moving (`$player_speed_ew` or `$player_speed_ns` non-zero) and enters a 32 px box (`BranchIfPlayerNear` `#02`). After the boost, the actor idles (`LargeRampIdleHold`, bare `RTL`) while the player stays within 48 px (`BranchIfPlayerNear` `#03`); only when the player leaves that range does the speed gate run again. **`$player_speed_ns` is never modified.**

Pure 65C816 for the speed path; minimal COP (`SetEntryHere`, `BranchIfPlayerNear`). **Distinct from** the `ramps.asm` jump-launcher actors (`ramp_east` at `$D310`), which take over the player script for scripted jumps — not tile slope physics (`slope_ramp_physics` in bank `$02`).

**Not movable.**

#### Algorithm

```
1. If `$player_speed_ew` OR `$player_speed_ns` == 0: RTL (wait for movement)
2. SetEntryHere; BranchIfPlayerNear `#02` → boost path, else RTL
3. Adjust `$player_speed_ew` ±1 from sign (once)
4. SetEntryHere; BranchIfPlayerNear `#03` → `LargeRampIdleHold` (idle RTL while near)
5. Player beyond 48 px → branch to step 1
```

#### Variables

| Symbol | Role |
|--------|------|
| `$player_speed_ew` | Modified ±1 once per approach |
| `$player_speed_ns` | Gate only — must be non-zero to arm; never written |

#### Scene Usage

| Scene | ID | Placements |
|-------|-----|------------|
| Incan Ruins | `$22` | 1 (slot `#17`) |
| Diamond Mine | `$41` | 2 (slots `#12`, `#13`) |

**3** total placements in `scene_actors.asm`.

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Distinct from | `ramps` block (`ramp_east`) | Jump-launcher actors at `$D310` |

---

## Scene matrix (static placements)

Counts are **`actor-spawn` rows** in `extracted/tables/scene_actors.asm` (October 2026 audit).

| Actor / group | Placements | Typical record # | Notes |
|---------------|------------|------------------|-------|
| `camera_scroll_controller` | **220** lists | `#01` | Default player camera; exception scene `$89` uses it as `#00` without player |
| `ScrollCameraTrack` | **105** | `#02` | Scroll ratio actor — [`camera-scroll-system.md`](camera-scroll-system.md) |
| `ScrollCameraInit` | **12** | `#02` | Spawn bytes `#DF,#DF` (Mt. Kress chain) |
| `ScrollCameraVertical` | **15** | `#02` | Edward / Itory / Incan / Dao vertical maps |
| `ScrollCameraAccumulate` | **5** | `#02` | Pyramid interiors |
| `Layer1DriftUnbounded` | **6** | `#01` or `#02` | Scenes `$4E`, `$50`, …, `$DC` (see asm block note) |
| `Layer1DriftWrapped` | **16** | `#02` | Wrapped layer-1 drift |
| `Layer1ParallaxRatio` | **0** in table | — | Runtime `SpawnBeforeFlags` only (Viper / mystic statue) |
| `scene_flag_init` | **26** | `#02`–`#04`, … | One-shot flag `#00` |
| `dream_zoom_controller` | **1** | `#04` | Scene **`$2A`** (Gold Ship dream) |
| Speed zones (all) | **16** | varies | See overview; `speed_zone_ns_fast_unused` = **0** |
| `large_ramp_booster` | **3** | `#12`–`#17` | Incan `$22`, Diamond Mine `$41` |

---

## Source validation

**Files checked:** `extracted/actors/camera_scroll_controller.asm`, `layer1_scroll_actors.asm`, `scene_flag_init.asm`, `dream_zoom_controller.asm`, `large_ramp_booster.asm`, `extracted/mountain_temple/movement_speed_zones.asm`, `extracted/system/engine/camera_scroll.asm`, `extracted/tables/scene_actors.asm` (header block comment + `rg` counts).

**Verified:** `CameraScrollUpdate` algorithm and WRAM symbols; **no dead zone**; forced-walk gating on target only; `effectDeltaX/Y` naming; **220** `camera_scroll_controller` spawns; **26** `scene_flag_init`; **6** `Layer1DriftUnbounded`; speed-zone placement split MT vs `$A7`; distinction between slot `#01` controller vs `#02` `ScrollCamera*`.

**Notes:** Function **sizes** in the overview use **estimated span** from adjacent labels unless instruction-counted elsewhere. `CameraDeadBoundsX/Y` in `camera_scroll_controller.asm` are **dead code** (never branched to). Layer-1 actor block comment still says two scenes for `Layer1DriftUnbounded` while the table has **six** spawns — doc follows the table count.
