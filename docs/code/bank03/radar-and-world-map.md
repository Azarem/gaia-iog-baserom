# Radar & World Map

> The two navigation surfaces of bank `$03`: the in-area radar/minimap overlay,
> and the overworld travel map (`scene $FE`) with its route bytecode, area-name
> table, per-destination option handlers, and travel iris effect.

*Part of the [Bank $03 Documentation Suite](readme.md)*

## Parts in this category

| Part | Range | Source |
|------|-------|--------|
| radar_map_screen | `$0380BF`–`$038410` | [radar_map_screen.asm](../../../extracted/system/engine/radar_map_screen.asm) |
| WorldMapController | `$03A2F1`–`$03A6BA` | [WorldMapController.asm](../../../extracted/system/world_map/WorldMapController.asm) |
| HdmaWindowEffect | `$03A83E`–`$03A940` | [HdmaWindowEffect.asm](../../../extracted/system/world_map/HdmaWindowEffect.asm) |
| world_map_routes | `$03AD77`–`$03B1D4` | [world_map_routes.asm](../../../extracted/system/world_map/world_map_routes.asm) |
| world_map_names | `$03B1D4`–`$03B401` | [world_map_names.asm](../../../extracted/system/world_map/world_map_names.asm) |
| world_map_options | `$03B401`–`$03BAE1` | [world_map_options.asm](../../../extracted/system/world_map/world_map_options.asm) |

## Overview

Two distinct systems live here. The **radar** (`radar_map_screen`) is the
hold-Start minimap overlay drawn on top of any normal area: it renders a tile
minimap centered on the player with scene markers and colored actor dots. The
**world map** is a full scene (`$FE`) governed by `WorldMapController`, which
handles the player's arrival animation, companion dot formation, location-name
display, and table-driven route travel between locations. Travel is described by
`world_map_routes` bytecode, area names come from `world_map_names`, destination
setup is dispatched through `world_map_options`, and the visual iris/spotlight
transition during travel is produced by the `HdmaWindowEffect` thinker.

**Related:** [field-input-and-items.md](field-input-and-items.md) (Start button entry point) · [mode7-and-cutscenes.md](mode7-and-cutscenes.md) (IrisCircleEffect / HDMA iris comparison) · [scene-and-hardware.md](scene-and-hardware.md) (scene transitions during travel)

---

## radar_map_screen — `$0380BF`–`$038410`

Source: [radar_map_screen.asm](../../../extracted/system/engine/radar_map_screen.asm)

### Purpose

Renders the in-game radar/minimap overlay accessible from within combat areas. A
tile-based minimap of the current area centered on the player, with scene
transition markers, friendly actors (blue dots) and enemy actors (red dots).

### Rendering pipeline (`RadarScreenSetup`)

1. DMA radar icon graphics (512 bytes, `radar_icons_001C00`) to VRAM `$7700`.
2. Block-copy the radar tilemap (`radar_layout_001E00`, `$0580` bytes) to the VRAM
   staging buffer at `$7F0380`.
3. Compute a 68×68-tile viewport centered on the player (aligned to a 4-tile
   boundary).
4. Plot scene-transition markers from `table_01ADA8` within the viewport
   (tile `$2EE6`).
5. Convert the viewport to pixel coordinates (×16) for actor plotting.
6. Iterate the actor list — friendly (`extendedFlags` bit 8) as blue dots
   (`$2AE7`), enemies (bit 9) as red dots (`$280D`).
7. Draw BCD marker count and actor count as digit tiles (base `$34F0`).
8. Check enemy-clear reward eligibility (flag `$0300` + `enemy_clear_reward_table`)
   and draw a chest icon if applicable.
9. Run the BG3 script for the radar text overlay.

### Resolution & buffer layout

Each radar cell = a 4×4 map-tile (64×64 px) area; the 68-tile viewport covers
~17 cells per axis. Radar output occupies the BG tilemap staging buffer at
`$7F0200` (interior starts at offset `$0216`; 64 bytes/row).
`RadarBorderAnimate` cycles a 29-entry tile table (`RadarBorderTileTable`) every
other frame at VRAM position `$7F0A24`.

### Key routines

| Address | Label | Role |
|---------|-------|------|
| `$0380BF` | `RadarScreenSetup` | full radar draw: DMA icons, tilemap copy, viewport calc, plot, legend |
| `$038259` | `RadarBorderAnimate` | cycle 29-entry tile table at `$7F0A24` on odd frames |
| `$03827C` | `RadarPlotSceneMarkers` | iterate `table_01ADA8`, plot unvisited markers, BCD count |
| `$03830E` | `RadarPlotActors` | walk actor list, dispatch to friendly/enemy plotters |
| `$03832F` | `RadarPlotFriendlyActor` | blue dot (`$2AE7`) — viewport bounds only |
| `$038379` | `RadarPlotEnemyActor` | red dot (`$280D`) — camera + viewport double bounds check |
| `$0383D6` | `RadarBorderTileTable` | 29 × word entries for border shimmer animation cycle |

### Cross-references

- **In:** `JSR` from `GlobalInputHandler` only (`RadarScreenSetup` + `RadarBorderAnimate`).
- **Out:**
  - `vblank_joypad.VBlankWaitAndJoypad` / `EnableNmiAndJoypad` / `EnableNmiOnly` — VBlank sync
  - `vram_buffer_clear.ClearVramBufferPartial` — clear staging buffer before draw
  - `cop_handlers_flags.TestEventFlag_0200` — check visited markers
  - `cop_handlers_flags.TestFlag_0300` — enemy-clear reward eligibility
  - `enemy_clear_reward_table` — per-scene reward lookup
  - `COP RunBg3Script (consolestring_01EAD1)` — radar text label overlay

### Notes

**VRAM buffer layout:** The radar tilemap occupies `$7F0200`–`$7F0A24+`. The
interior starts at offset `$0216` from `$7F0200`; each VRAM tilemap row is 64
bytes (32 words). The base layout is block-copied from `radar_layout_001E00`
(`$0580` bytes) into `$7F0380` before any markers or actors are plotted.

**Tile constants:**

| Tile | Palette | Use |
|------|---------|-----|
| `$2EE6` | 2 | scene transition marker |
| `$2AE7` | 2 | friendly actor dot (blue) |
| `$280D` | 0 | enemy actor dot (red) |
| `$34F0`+ | 3 | BCD digit base (digit value OR'd in) |
| `$2EE1`–`$2EE3` | varies | chest icon (4×4 flipped tiles) |
| `$32E8`–`$32EB` | 3 | reward counter digits |

**Viewport math:** Player tile position (`playerXTile`/`playerYTile`) is aligned
to a 4-tile boundary (`AND $00FC`). The viewport extends ±32 tiles from that center
(left = X−32, right = X+68, top = Y−32, bottom = Y+68). For actor plotting, tile
coords are converted to pixels (×16 via ASL×4). Actor pixel positions are
converted to VRAM offsets: X via `>>5 AND $FFFE` (word-align), Y via `AND $FFC0`
(64 bytes per row).

**Enemy double-bounds check:** `RadarPlotEnemyActor` checks both the game camera
bounds (`cameraOffsetX`/`Y` to `cameraBoundsX`/`Y`) and the radar viewport bounds.
Only enemies visible on both the camera and the radar are plotted — off-screen
enemies are hidden. Friendly actors skip the camera check (always plotted if within
the radar viewport).

---

## WorldMapController — `$03A2F1`–`$03A6BA`

Source: [WorldMapController.asm](../../../extracted/system/world_map/WorldMapController.asm)

### Purpose

The sole actor for the world-map scene (`$FE`). Implements arrival animation,
companion dot formation, location-name display, table-driven route travel, and
scene entry on arrival.

### World-map state block (`$0D52`–`$0D6F`)

| Address | Purpose |
|---------|---------|
| `$0D52`/`$0D53` | special-transition trigger bytes, checked by `CheckSceneTransition`/`ExecuteSceneTransition` |
| `$0D54`/`$0D56` | initial player X/Y on the map |
| `$0D58` | destination/route selection ID (0 = none) |
| `$0D5A` | route active flag / route ID for playback |
| `$0D5C` | route subroutine return pointer |
| `$0D60`–`$0D6A` | companion array (6 words) |
| `$0D6C` | deferred `$0652` auxiliary data |
| `$0D6E` | deferred destination scene ID (captured from `sceneNext` by `DeferSceneTransition`) |
| `$0D6F` | source scene ID (set by `scene_lifecycle` to `sceneCurrent` on special transition entry) |

`ClearWorldMapState` zeroes `$0D52`–`$0D6D` (14 words) on cleanup.

### Player lifecycle on the map

1. Init: reset form to Will, spawn palette thinkers, clear WRAM flags, mask D-pad
   (`$FFF0` → `joypadMaskStd`), spawn `ArrivalAndTravelSetup`.
2. `ArrivalAndTravelSetup`: position player at (`$0D54`,`$0D56`), center camera
   (X−`$80`, Y−`$70`), play a 44-frame gravity drop.
3. If destination set (`$0D58` ≠ 0): spawn `HdmaWindowEffect`, dispatch through
   `world_map_options`; register `DeferSceneTransition` via `SetSavedPtr` (runs
   after option dispatch, before route animation) to capture pending `sceneNext`.
4. If no destination: land, spawn location-name actor (`pr_actor_0BCF52`),
   look up name via `LookupMapName`, play a 93-frame ascent.
5. Companion dots: scan `$0D60` array, pick formation from
   `companion_position_tables`, spawn `CompanionDotMovement` per companion.
6. Route playback: `RouteAnimationEngine` interprets `world_map_routes` bytecode.
7. On completion: `RouteEndHandler` clears route flags, shows destination name,
   plays a 59-frame descent (Start-skippable), triggers the deferred transition.

### Key routines

| Address | Label | Role |
|---------|-------|------|
| `$03A2F1` | `WorldMapController` | `actor-def` entry: form reset, palette thinkers, child spawn |
| `$03A341` | `DeferSceneTransition` | `SetSavedPtr` callback: capture `sceneNext` → `$0D6E` and `$0652` → `$0D6C` after option dispatch, before route animation |
| `$03A35E` | `ArrivalAndTravelSetup` | position/camera/gravity, companion spawn, route launch |
| `$03A469` | `CompanionDotMovement` | per-companion dot positioning from formation tables |
| `$03A503` | `companion_position_tables` | 6-entry formation offset data per companion count |
| `$03A52F` | `RouteAnimationEngine` | init: set route flags, enter step loop |
| `$03A541` | `RouteStepLoop` | bytecode interpreter loop: read step, apply movement, next |
| `$03A5DB` | `SkipToSceneTransition` | Start-button skip: jump straight to deferred transition |
| `$03A5F0` | `RouteSubroutineCall` | `$FE` control byte: save return pointer, jump to subroutine route |
| `$03A5FE` | `RouteEndHandler` | route complete: clear flags, name display, 59-frame descent, transition |
| `$03A681` | `ClearWorldMapState` | zero `$0D52`–`$0D6D` (14 words) |
| `$03A692` | `LookupMapName` | linear search of `world_map_names` for area name string pointer |

### Companion formation tables

`companion_position_tables` (`$03A503`) contains offset data for up to 6 companion
dots. The controller scans the `$0D60` array (6 words) to count active companions
(nonzero entries). The formation layout is selected by companion count, and
`CompanionDotMovement` is spawned per companion with offsets from the table.

### Frame counts

| Phase | Frames | Description |
|-------|--------|-------------|
| Gravity drop | 44 | player falls onto map from above |
| Ascent animation | 93 | name display + landing settle (no travel) |
| Descent at destination | 59 | Start-skippable via `SkipToSceneTransition` |

### Deferred-scene flow

When a destination is set (`$0D58 ≠ 0`), `WorldMapController` spawns
`HdmaWindowEffect`, dispatches through `world_map_options`, then registers
`DeferSceneTransition` via `SetSavedPtr`. That callback runs after option dispatch
and before route animation, capturing the destination scene from `sceneNext` into
`$0D6E` and `$0652` into `$0D6C`. When the route bytecode completes,
`RouteEndHandler` (or `SkipToSceneTransition`) restores the deferred transition:
`$0D6E` → `sceneNext` and `$0D6C` → `$0652`; `$0D6F` is not written back to
`sceneNext`. The normal `CheckSceneTransition` pipeline then takes over.

---

## HdmaWindowEffect — `$03A83E`–`$03A940`

Source: [HdmaWindowEffect.asm](../../../extracted/system/world_map/HdmaWindowEffect.asm)

### Purpose

Thinker (type `$04`, priority `$08`) spawned by
`WorldMapController.ArrivalAndTravelSetup` during travel. Manages double-buffered
sine-table data for HDMA window registers to create an iris/spotlight transition
on the world map.

### Double-buffered sine tables

Two buffer pairs selected by frame parity (`$0036` bit 0):
- Even frames: `$7E8800` (channel 5) + `$7E8A00` (channel `$32`)
- Odd frames: `$7E8900` (channel 5) + `$7E8B00` (channel `$32`)

`InitSineTableBuffers` fills both with `$01FF` (76 entries + `$0000` terminator) =
fully-open window.

### Animation phases

- **Steady-state** (route active, `$0D58` ≠ 0 and `$0D5A` = 0):
  `UpdateHdmaWindowParams` + `QueueHdmaSineBuffers` each frame.
- **Opening** (`$0D58` = 0 or `$0D5A` ≠ 0): 2-frame hold → 40-frame iris
  (`$7F2104,X` advances by 2/frame, scrolling the read position) → hold final.

`UpdateHdmaWindowParams` sets DBR `$7E`, selects the buffer by parity, and writes
7-byte HDMA parameter blocks from `hdma_window1/2_template` into `$8800,Y`/`$8A00,Y`,
adding the per-actor HDMA offset (`$7F2104,X`) to byte 2 of each template.

### Key routines

| Address | Label | Role |
|---------|-------|------|
| `$03A83E` | `HdmaWindowEffect` | thinker entry: init offset, fill buffers, dispatch by state |
| `$03A886` | `QueueHdmaSineBuffers` | frame-parity DMA: even `$8800`/`$8A00`, odd `$8900`/`$8B00` |
| `$03A8A6` | `UpdateHdmaWindowParams` | write 7-byte HDMA blocks from templates + actor offset |
| `$03A90B` | `InitSineTableBuffers` | fill both buffers with `$01FF` (76 entries + `$0000` terminator) |

### HDMA parameter templates

Two 7-byte templates at `$03A932` and `$03A939` provide the base HDMA indirect
table data:

| Template | Raw bytes | Purpose |
|----------|-----------|---------|
| `binary_03A932` | `7F 07 18 07 01 09 00` | window 1 parameters |
| `binary_03A939` | `7F 00 18 00 01 FF 00` | window 2 parameters |

`UpdateHdmaWindowParams` copies these into the selected buffer (`$8800,Y` /
`$8A00,Y`), adding the per-actor HDMA offset (`$7F2104,X`) to byte 2 (the
scanline source row) of each template to animate the window position.

### Relationship to IrisCircleEffect

Both thinkers produce HDMA-driven window effects, but with different approaches:
- **IrisCircleEffect** computes a **circular** window per-frame via hardware
  multiply, writing scanline count + edge pairs. Used for spotlight/iris closings.
- **HdmaWindowEffect** scrolls through **pre-filled sine-table buffers** by
  advancing a read offset, producing a smoother parameterized transition. Used for
  the world-map travel iris.

Both are thinker type `$04`, priority `$08`. They target different HDMA channels
and are never spawned simultaneously.

---

## world_map_routes — `$03AD77`–`$03B1D4`

Source: [world_map_routes.asm](../../../extracted/system/world_map/world_map_routes.asm)

**Type:** `&route-step` pointer table + `route-step` records (blocks.json
`world_map_routes`, `movable: true`).

### Purpose

Movement bytecode for world-map travel. A pointer table (`route_step_03ADC3`, …)
indexes route lists; each `route-step` record encodes X/Y/Z movement delta-table
indices and a frame count. Control bytes: `$FE` = subroutine call (one nesting
level), `$FF` = end. Interpreted by `WorldMapController.RouteAnimationEngine`.

### Record format

Each `route-step` is a 4-byte record: `route-step < a, b, c, d >`.

| Field | Meaning |
|-------|---------|
| `a` | X movement delta table index (0 = none, 1 = left, 2 = right) |
| `b` | Y movement delta table index (0 = none, 1 = up, 2 = down) |
| `c` | Z movement delta table index (0 = none, 1/2 = altitude change) |
| `d` | frame count — duration of this movement step |

`RouteStepLoop` reads each step and applies the delta indices to the player's
position for the specified number of frames. The delta tables are internal to
`RouteAnimationEngine` (`movement_delta_table`).

**Control bytes** (in place of a normal step):
- `$FE` — subroutine call: the next word is a pointer to a sub-route. Return
  pointer saved to `$0D5C`. One nesting level only.
- `$FF` — end of route. Returns to `RouteEndHandler`.

### Route pointer table

The table at `$03AD77` contains 38 entries (indices `$00`–`$25`), each a word
pointer to a `route-step` list. Entry `$00` and `$01` share the same route
(`route_step_03ADC3`). The route index is determined by the destination option
handlers in `world_map_options`.

---

## world_map_names — `$03B1D4`–`$03B401`

Source: [world_map_names.asm](../../../extracted/system/world_map/world_map_names.asm)

**Type:** `map-label` table (blocks.json `world_map_names`).

### Purpose

Pairs a scene/area ID with a sprite-string pointer for the on-map area name, e.g.
`map-label < #01, &spritestring_03B244 >`. Linearly searched by
`WorldMapController.LookupMapName`. Note some IDs share the same string
(`#C4`/`#C5`/`#C8` → `&spritestring_03B3CC`).

### Notes

`LookupMapName` (`$03A692`) performs a linear search of the `map-label` table.
Each entry pairs a scene/area ID byte with a word pointer to a sprite-string (used
by the `pr_actor_0BCF52` name display actor). Some IDs share strings
(`#C4`/`#C5`/`#C8` point to the same Dao area name). The table terminates with a
sentinel — unmatched IDs receive no name display.

---

## world_map_options — `$03B401`–`$03BAE1`

Source: [world_map_options.asm](../../../extracted/system/world_map/world_map_options.asm)

**Type:** `&Code` dispatch table + handler code (blocks.json `world_map_options`).

### Purpose

A `&Code` table (`code_03B44F`, `code_03B451`, …) of per-destination option
handlers selected by the destination ID in `$0D58`. Each handler configures the
route/scene parameters for that world-map location before travel begins.

### Handler behavior

Each handler is a small `&Code` block that sets up the route and deferred scene
parameters for its destination:

1. Writes the route ID to `$0D5A` (selects a route from `world_map_routes`)
2. Sets the destination scene via `sceneNext` (captured into `$0D6E` by
   `DeferSceneTransition` after dispatch)
3. Sets graphics cache indices (`gfxCacheIdxA`/`B`) for the destination's
   enter/exit transition
4. Some handlers set additional game state (music, event flags, palette)

The option index is extracted from `$0D58` by `WorldMapController` (5-bit mask),
then used as a word index into the `&Code` table at the start of
`world_map_options`. After the handler completes, `DeferSceneTransition` captures
the pending `sceneNext` into `$0D6E` and `$0652` into `$0D6C`, then
`RouteAnimationEngine` begins route playback.

### Notes

The relationship between options, routes, and scenes is:
- `$0D58` (destination ID) → selects an option handler from `world_map_options`
- The option handler writes a route ID → `$0D5A` → selects from `world_map_routes`
- The option handler sets the destination scene via `sceneNext`; `DeferSceneTransition`
  captures it → `$0D6E`. `$0D6F` (source scene ID) is set by `scene_lifecycle` on
  special-scene entry, not by option handlers
- Route playback animates the player along the path
- On completion, `RouteEndHandler` triggers the deferred transition to the target scene

---

## Category-wide notes

**World-map WRAM `$0D52`–`$0D6F`:** This 30-byte state block is primarily owned
by the world-map system. It is zeroed by `ClearWorldMapState` on cleanup and
persists across the map scene's lifetime. The block stores arrival position,
destination ID, route playback state, companion formation, and the deferred scene
transition target. However, `scene_lifecycle.asm` also writes `$0D54`, `$0D6C`,
`$0D6E`, and `$0D6F` during the special-scene (`$FE`) transition entry path.

**Iris effect sharing:** `IrisCircleEffect` (Category 3) is used in both the
prologue prophecy scene (`$8C`) and the world map (`$FE`), while
`HdmaWindowEffect` (this category) is world-map-only. Both produce HDMA window
effects but use different algorithms and HDMA channels — they are never active
simultaneously.

**Radar vs. world map independence:** The radar overlay (`radar_map_screen`) and the
world map scene (`WorldMapController`) are completely independent systems. The
radar is a hold-Start overlay drawn on top of any normal field scene; it reads the
current area's tilemap data, actor list, and scene markers. The world map is a
full scene (`$FE`) with its own actor, thinkers, and route system. The radar never
activates on the world-map scene (Start on the world map is consumed by the
controller's joypad mask `$FFF0`).

---

## See Also

- [field-input-and-items.md](field-input-and-items.md) — `GlobalInputHandler` Start button opens radar; item handlers reference inventory
- [mode7-and-cutscenes.md](mode7-and-cutscenes.md) — `IrisCircleEffect` vs `HdmaWindowEffect` comparison; shared HDMA windowing concepts
- [scene-and-hardware.md](scene-and-hardware.md) — `ClearSceneState` initializes scene $FE; transition effects used by world map
- [actor-thinker-runtime.md](actor-thinker-runtime.md) — `WorldMapController` is an actor; `HdmaWindowEffect` is a thinker
- [Bank $03 index](readme.md) — bank-wide memory map, WRAM reference, design patterns
