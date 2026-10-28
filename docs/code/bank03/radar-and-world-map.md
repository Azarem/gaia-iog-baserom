# Radar & World Map

> The two navigation surfaces of bank `$03`: the in-area radar/minimap overlay,
> and the overworld travel map (`scene $FE`) with its route bytecode, area-name
> table, per-destination option handlers, and the travel-scene screen split effect.

*Part of the [Bank $03 Documentation Suite](README.md)*

## Parts in this category

| Part | Range | Source |
|------|-------|--------|
| radar_map_screen | `$0380BF`–`$038410` | [radar_map_screen.asm](../../../extracted/system/engine/radar_map_screen.asm) |
| WorldMapController | `$03A2F1`–`$03A6BA` | [WorldMapController.asm](../../../extracted/system/world_map/WorldMapController.asm) |
| WorldMapSplitEffect | `$03A83E`–`$03A940` | [WorldMapSplitEffect.asm](../../../extracted/system/world_map/WorldMapSplitEffect.asm) |
| world_map_route_table | `$03AD77`–`$03B1D4` | [world_map_route_table.asm](../../../extracted/system/world_map/world_map_route_table.asm) |
| world_map_scene_names | `$03B1D4`–`$03B401` | [world_map_scene_names.asm](../../../extracted/system/world_map/world_map_scene_names.asm) |
| world_map_options | `$03B401`–`$03BAE1` | [world_map_options.asm](../../../extracted/system/world_map/world_map_options.asm) |

## Overview

Two distinct systems live here. The **radar** (`radar_map_screen`) is the
hold-Start minimap overlay drawn on top of any normal area: it renders a tile
minimap centered on the player with scene markers and colored actor dots. The
**world map** is a full scene (`$FE`) governed by `WorldMapController`, which
handles the player's arrival animation, companion dot formation, location-name
display, and table-driven route travel between locations. Travel is described by
`world_map_route_table` bytecode, area names come from `world_map_scene_names`, destination
setup is dispatched through `world_map_options`, and the Mode 7 / Mode 1 screen split
with a white boundary line during travel is produced by the `WorldMapSplitEffect` thinker
(a BGMODE / COLDATA split; it is not an iris and uses no window registers).

**Related:** [field-input-and-items.md](field-input-and-items.md) (Start button entry point) · [mode7-and-cutscenes.md](mode7-and-cutscenes.md) (`IrisCircleEffect`; `WorldMapSplitEffect` is a different, non-window effect) · [scene-and-hardware.md](scene-and-hardware.md) (scene transitions during travel)

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
6. Iterate the actor list — stat-bearing enemies (`extendedFlags` bit 8,
   `$0100`) as blue dots (`$2AE7`), bit 9 (`$0200`) actors as red dots
   (`$280D`). Note: bit 8 is set by `actor_execution.asm` during enemy
   spawn; the "friendly" label in auto-docs refers to dot color, not semantics.
7. Draw BCD marker count and actor count as digit tiles (base `$34F0`).
8. Check enemy-clear reward eligibility (flag `$0300` + `enemy_clear_reward_table`)
   and draw a chest icon if applicable.
9. Run the BG3 script for the radar text overlay.

### Resolution & buffer layout

Each radar cell = a 4×4 map-tile (64×64 px) area; the 68-tile viewport covers
~17 cells per axis. Radar output occupies the BG tilemap staging buffer at
`$7F0200` (interior starts at offset `$0216`; 64 bytes/row).
`RadarBorderAnimate` cycles a 29-entry tile table (`RadarBorderColorTable`) every
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
| `$0383D6` | `RadarBorderColorTable` | 29 × word entries for border shimmer animation cycle |

### Cross-references

- **In:** `JSR` from `GlobalInputHandler` only (`RadarScreenSetup` + `RadarBorderAnimate`).
- **Out:**
  - `vblank_joypad.VBlankWaitAndJoypad` / `EnableNmiAndJoypad` / `DisableNmiKeepJoypad` — VBlank sync
  - `vram_buffer_clear.ClearVramBufferPartial` — clear staging buffer before draw
  - `flag_helpers.TestEventFlag_0200` — check visited markers
  - `flag_helpers.TestFlag_0300` — enemy-clear reward eligibility
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
| `$0D52` | staged start X; nonzero = a world-map entry is pending (moved to `$0D54` and cleared on arrival; `CheckSceneTransition`/`ExecuteSceneTransition` test `$0D52`/`$0D53`) |
| `$0D54`/`$0D56` | `worldMapPlayerX`/`Y`: start position on the 1024 x 1024 map |
| `$0D58` | choice id (0 = none); the low 5 bits index `world_map_options` |
| `$0D5A` | route id (0 = none), index into `world_map_route_table`, set by COP `StageWorldMapMove` / the menu handlers |
| `$0D5C` | route subroutine return pointer (0 = none; the `$FE` subroutine code is never used by the data) |
| `$0D5E` | written by the two stage COPs (always 0), never read |
| `$0D60`–`$0D6A` | party array: six words of `spm_overworld_sprites` animation indices; `$0D60` = leader, `$0D62`–`$0D6A` = up to five companions, 0 = empty |
| `$0D6C` | deferred `$0652` (scroll parameters of the queued scene change) |
| `$0D6E` | destination scene (low byte); scripted trip: from `ExecuteSceneTransition`; menu trip: from `DeferSceneTransition` (`sceneNext`) |
| `$0D6F` | scene being left (`ExecuteSceneTransition` copies `sceneCurrent`); the start name is looked up with it |

`ClearWorldMapState` zeroes `$0D52`–`$0D6D` (14 words) on cleanup, so `$0D6E`/`$0D6F` survive the trip.

### Mode 7 parameters the controller drives

`Mode7PerspectiveInit` sets `$B8 := $0400`, `$B6 := 0`, `$BC := 0` and the centre `$CA`/`$CC` := (`$0D54`, `$0D56`). `$B8` is the divisor at the top scanline (smaller = zoomed out), `$B6` is how much it grows per scanline (0 = flat map, larger = stronger perspective) and `$BC` is the rotation index (512 steps per turn). Route steps change `$CA`/`$CC`/`$BC`, so the map slides and turns during a trip. (`$BC` was first called elevation; it is rotation.)

### Trip timeline

1. Init (`WorldMapController`): reset form to Will, two palette-reset thinkers (bundle `$0B`), clear WRAM flags, mask the buttons (`joypadMaskStd |= $FFFC`; the ROM has `$FFF0`, widened by `transforms.json`), spawn `ArrivalAndTravelSetup`. With no choice id (scripted trip) the controller dies here; otherwise it saves `DeferSceneTransition` with `SetSavedPtr` and runs `world_map_options[choice & $1F]` (menu and handler).
2. `ArrivalAndTravelSetup`, 44 ticks: puts itself (the leader's dot) at the start position, centres the camera (X−`$80`, Y−`$70`) and adds the negative `TickGravity` delta to `$B8` each tick (a zoom-out from 8x in to a wide view).
3. Menu trips only: wait 16 ticks, spawn `WorldMapSplitEffect`, then poll `$0D5A` every frame while the menu is open (Quit leaves it 0: the handler already queued the scene you came from and `DeferSceneTransition` just dies).
4. Tilt phase (`TiltPhaseStart`), 93 ticks: shows the name of the scene being left (`LookupMapName` with `$0D6F`), grows `$B6` by the `TickGravity` curve and `$B8` by 1 (the flat map tilts into a strong perspective view), then clears the name (`$00DA := 0`).
5. Companion dots: scan the party array from `$0D62`, pick formation N from `companion_formation_tables`, spawn one `CompanionDotMovement` per companion, spawn `RouteAnimationEngine`; this actor becomes the leader's dot.
6. Route playback: `RouteAnimationEngine` plays the `world_map_route_table` bytes (X, Y and rotation delta chains).
7. `RouteEndHandler`: dots die, the destination name (`$0D6E`) shows for 60 ticks (`WaitByte #3B`), `$B6` falls by `$10` per frame until the map is flat (Start skips), the deferred `sceneNext`/`$0652` are restored and the controller dives (`$B8` grows by an increasing delta) while the scene exit transition runs.

(`WaitByte(n)` resumes n + 1 ticks later.)

### Key routines

| Address | Label | Role |
|---------|-------|------|
| `$03A2F1` | `WorldMapController` | `actor-def` entry: form reset, palette thinkers, child spawn |
| `$03A341` | `DeferSceneTransition` | `SetSavedPtr` callback: capture `sceneNext` → `$0D6E` and `$0652` → `$0D6C` after option dispatch, before route animation |
| `$03A35E` | `ArrivalAndTravelSetup` | position/camera/gravity, companion spawn, route launch |
| `$03A469` | `CompanionDotMovement` | per-companion dot positioning from formation tables |
| `$03A503` | `companion_formation_tables` | 6-entry formation offset data per companion count |
| `$03A52F` | `RouteAnimationEngine` | init: set route flags, enter step loop |
| `$03A541` | `RouteStepLoop` | bytecode interpreter loop: read step, apply movement, next |
| `$03A5DB` | `SkipToSceneTransition` | Start-button skip: jump straight to deferred transition |
| `$03A5F0` | `RouteSubroutineCall` | `$FE` control byte: save return pointer, jump to subroutine route (never used by the data) |
| `$03A5FE` | `RouteEndHandler` | route complete: clear flags, 60-tick destination name, untilt, dive, transition |
| `$03A681` | `ClearWorldMapState` | zero `$0D52`–`$0D6D` (14 words) |
| `$03A692` | `LookupMapName` | linear search of `world_map_scene_names` for area name string pointer |

### Companion formation tables

`companion_formation_tables` (`$03A503`) contains offset data for up to 6 companion
dots. The controller scans the `$0D60` array (6 words) to count active companions
(nonzero entries). The formation layout is selected by companion count, and
`CompanionDotMovement` is spawned per companion with offsets from the table.

### Frame counts

| Phase | Frames | Description |
|-------|--------|-------------|
| Zoom-out | 44 | `$B8` falls (arrival) |
| Tilt phase | 93 | start name shown, `$B6` grows |
| Destination name | 60 | `WaitByte #3B`, then the untilt (`$B6` falls by `$10` per frame) and the dive; Start-skippable via `SkipToSceneTransition` |

### Deferred-scene flow

When a destination is set (`$0D58 ≠ 0`), `WorldMapController` spawns
`WorldMapSplitEffect`, dispatches through `world_map_options`, then registers
`DeferSceneTransition` via `SetSavedPtr`. That callback runs after option dispatch
and before route animation, capturing the destination scene from `sceneNext` into
`$0D6E` and `$0652` into `$0D6C`. When the route bytecode completes,
`RouteEndHandler` (or `SkipToSceneTransition`) restores the deferred transition:
`$0D6E` → `sceneNext` and `$0D6C` → `$0652`; `$0D6F` is not written back to
`sceneNext`. The normal `CheckSceneTransition` pipeline then takes over.

---

## WorldMapSplitEffect — `$03A83E`–`$03A940`

Source: [WorldMapSplitEffect.asm](../../../extracted/system/world_map/WorldMapSplitEffect.asm)

### Purpose

Thinker (type `$04`, priority `$08`) spawned by `WorldMapController.ArrivalAndTravelSetup` (menu trips only, COP `SpawnThinker`). Every frame it builds two per-scanline HDMA tables, one for BGMODE (`$2105`) and one for COLDATA (`$2132`), that split the screen at a boundary row and, when a route starts, push that row down the screen. It is a BGMODE / COLDATA split, not an iris or window effect: no window register and no sine table is involved. (Its labels were first named `HdmaWindowEffect`, `QueueHdmaSineBuffers`, `UpdateHdmaWindowParams` and `InitSineTableBuffers`; the `sineTableA`/`sineTableB` mnemonics only survive because the scroll-wave code shares them.)

### Double-buffered tables

Two table pairs selected by frame parity (`$0036` bit 0). The second operand of `COP QueueDma` is the PPU B-bus register (`$2100` + `#05` = BGMODE, `#32` = COLDATA), not an HDMA channel number:
- Even frames: `$7E8800` (BGMODE) + `$7E8A00` (COLDATA)
- Odd frames: `$7E8900` (`sineTableA`) + `$7E8B00` (`sineTableB`)

`InitSplitFill` fills the buffers with `$01FF`; the template copy overwrites only the first 6 bytes, so below the boundary the leftover fill makes every other scanline write a white fixed colour (the COLDATA table reads it as a repeat count `$FF` followed by `01, FF, 01, FF, ...`).

### Table contents

- BGMODE (`split_bgmode_template = 7F 07 | 18 07 | 01 09 | 00`): 127 lines of `$07` (Mode 7), then `$18` + offset lines of `$07`, then one line of `$09` (Mode 1, BG3 priority) and the terminator, which `BuildSplitTables` writes itself. The last value stays in force below the table: Mode 7 down to row 150 + offset, Mode 1 from row 151 + offset.
- COLDATA (`split_coldata_template = 7F 00 | 18 00 | 01 FF | 00`): the same line counts with data `$00` (no colour plane = no change), then one line of `$FF` (all planes, full intensity = white) on the boundary row.
- The per-actor offset `$7F2104,X` (0 at spawn) is added to the second line count of both tables, so the boundary row moves one line per offset step.

### Animation phases

- Spawn: offset := 0, `InitSplitFill`, `SetEntryHere`.
- **Holding** (`$0D58` ≠ 0 and `$0D5A` = 0: destination chosen, no route yet): `BuildSplitTables` + `QueueSplitTables` each frame at the current offset.
- **Opening** (otherwise): 2 frames of rebuild + queue, then 40 frames in which the offset grows by 2 per frame (second line count `$18` → `$68`, boundary row 151 → 231, off the bottom of the screen), then it parks rebuilding with offset 80. What the strip below the boundary looks like on screen is decoded from the tables, not observed (OQ-I058-1).

### Key routines

| Address | Label | Role |
|---------|-------|------|
| `$03A83E` | `WorldMapSplitEffect` | thinker entry: init offset, fill buffers, dispatch by state |
| `$03A886` | `QueueSplitTables` | frame-parity DMA: even `$8800`/`$8A00`, odd `$8900`/`$8B00` |
| `$03A8A6` | `BuildSplitTables` | copy the 6 template bytes, add the actor offset to the second line count, write the terminator |
| `$03A90B` | `InitSplitFill` | fill both buffers with the `$01FF` pattern |

### HDMA templates

Two 7-byte templates (`split_bgmode_template`, `split_coldata_template`); the seventh byte is never used (see Table contents above).

### Relationship to IrisCircleEffect

`IrisCircleEffect` computes a **circular** window per frame via hardware multiply and writes scanline count + edge pairs to the window registers. `WorldMapSplitEffect` writes no window registers: it is a BGMODE / COLDATA split. They are different effects; both are thinker type `$04`, priority `$08`, and are never active at the same time.

---

## world_map_route_table — `$03AD77`–`$03B1D4`

Source: [world_map_route_table.asm](../../../extracted/system/world_map/world_map_route_table.asm)

**Type:** `&route-step` pointer table + `route-step` records (blocks.json
`world_map_route_table`, `movable: true`).

### Purpose

Movement data for world-map travel. A pointer table of 38 entries (`$00`–`$25`; `$00` aliases `$01`) points at 37 route arrays named `route_<id>_<origin>_to_<destination>` (`route_unused_<id>` for `$0E`, `$0F`, `$10`, `$23`, `$24`, `$25`, which nothing stages). Interpreted by `WorldMapController.RouteAnimationEngine`. The trip for each id is listed in the `world_map_options` block note.

### Record format

Each `route-step` is a 4-byte record: `route-step < xDeltaIndex, yDeltaIndex, rotationDeltaIndex, ticks >`.

| Field | Meaning |
|-------|---------|
| `xDeltaIndex` | index into `movement_delta_table` for the X chain (`$00CA`); 0 = still |
| `yDeltaIndex` | index for the Y chain (`$00CC`); 0 = still |
| `rotationDeltaIndex` | index for the rotation chain (`$00BC`); 0 = still |
| `ticks` | n; the step runs n + 1 ticks |

Indices used: X and Y take 1 (+1 per tick), 2 (−1), `$11` (alternating +1, 0) or `$12` (alternating −1, 0); rotation takes 1 (+1) or 2 (−1). A step never mixes rotation with movement: a route turns the map and runs straight in one of eight directions. They are delta-table indices, not directions or distances.

Every array is 4n + 1 bytes: a hidden `$FF` ends it. `$FE` (subroutine call, return pointer in `$0D5C`) is implemented but never used by the data.

---

## world_map_scene_names — `$03B1D4`–`$03B401`

Source: [world_map_scene_names.asm](../../../extracted/system/world_map/world_map_scene_names.asm)

**Type:** `map-label` table (blocks.json `world_map_scene_names`).

### Purpose

Scene id → name string table that `WorldMapController` uses for the two area names of a trip (start name from `$0D6F`, end name from the low byte of `$0D6E`), followed by the name strings. `LookupMapName` (`$03A692`) searches 37 three-byte entries (scene id, name pointer) in ascending scene-id order. The name is drawn by `pr_text_placement_calc` as one 8-pixel sprite record per character in the `$7F0600` buffer (tile = code × 2 + `$2300`), centred at Y = `$38`, with the byte count in `$00DA`; `WorldMapController` zeroes `$00DA` to remove the name.

Several ids share a name: South Cape (`$01` `$06`), Itory Village (`$15` `$17`), Diamond Coast (`$30` `$31`), Freejia (`$32` `$39`), Angel Village (`$69` `$6A`), Watermia (`$78` `$79`), City of Euro (`$91` `$95` `$96`), Mt.Temple (`$9F` `$A0`), Natives' Village (`$AC` `$AD` `$AE`), Desert Village Dao (`$C3` `$C4` `$C5` `$C8`). Unmatched ids get no name.

---

## world_map_options — `$03B401`–`$03BAE1`

Source: [world_map_options.asm](../../../extracted/system/world_map/world_map_options.asm)

**Type:** `&Code` dispatch table + handler code (blocks.json `world_map_options`).

### Purpose

A 39-entry `&Code` table indexed by the choice id (`$0D58` & `$1F`): `$01`–`$1B` are real menus (`WorldMapMenu_<id>`), `$00` only returns, `$1C`–`$25` are `WorldMapMenu_Empty<id>` (print an empty template and return) and `$26` is `WorldMapMenu_Nothing26` (prints "Nothing!!"). Each menu prints a Quit / destination text and runs `COP DialogueOptions`; the chosen handler (`WorldMapGo_<origin>_<destination>`, `WorldMapQuit_<place>`) stages the route and queues the scene change.

### Handler behavior

Each handler is a small `&Code` block that sets up the route and deferred scene
parameters for its destination:

1. Stages the route with `StageWorldMapMoveIds ( 0, route id )`, which writes `$0D5A` (selects a route from `world_map_route_table`)
2. Queues the destination scene with `QueueMapChange` (captured into `$0D6E` by
   `DeferSceneTransition` after dispatch; flag bit 7 marks a new revive / save point)
3. The Watermia ↔ Euro handlers also write `$0D60 := 7` (leader animation 7)

The option index is extracted from `$0D58` by `WorldMapController` (5-bit mask),
then used as a word index into the `&Code` table at the start of
`world_map_options`. After the handler completes, `DeferSceneTransition` captures
the pending `sceneNext` into `$0D6E` and `$0652` into `$0D6C`, then
`RouteAnimationEngine` begins route playback.

### Notes

The relationship between options, routes, and scenes is:
- `$0D58` (destination ID) → selects an option handler from `world_map_options`
- The option handler writes a route ID → `$0D5A` → selects from `world_map_route_table`
- The option handler sets the destination scene via `sceneNext`; `DeferSceneTransition`
  captures it → `$0D6E`. `$0D6F` (the scene being left) is set by `ExecuteSceneTransition` on
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

**Split effect vs. iris:** `IrisCircleEffect` (Category 3) is used in both the prologue prophecy scene (`$8C`) and the world map (`$FE`), while `WorldMapSplitEffect` (this category) is world-map-only. The two are different effects (circular window vs. BGMODE / COLDATA split) and are never active simultaneously.

**Radar vs. world map independence:** The radar overlay (`radar_map_screen`) and the
world map scene (`WorldMapController`) are completely independent systems. The
radar is a hold-Start overlay drawn on top of any normal field scene; it reads the
current area's tilemap data, actor list, and scene markers. The world map is a
full scene (`$FE`) with its own actor, thinkers, and route system. The radar never
activates on the world-map scene (Start on the world map is consumed by the
controller's joypad mask `$FFFC`).

**Minimap V2 replacement (IOG Retranslated):** The `minimap-v2` module replaces the
original radar with a compact 4×4-per-metatile collision-based minimap. Key
architectural differences from the original radar:

- Reads collision data from `$7FC000` directly (not the tilemap) via
  `BuildViewportCollision`, classifying tiles as floor (color 1) or wall (color 2).
- Uses a viewport-relative packed color array (stride 32) supporting rooms of any
  size, with D-pad scrolling for large rooms.
- Stamps colored markers for warps, chests, dark spaces, enemies, and player via
  `StampQuadrant` (ORA-based quadrant assembly into the packed array).
- Uploads custom CHR tiles to VRAM `$6800` via adhoc DMA, writes to the engine
  staging buffer at `$7F0200`, and triggers NMI flush via `displayModeFlags` bit 0.
- **Must save/restore engine low DP ($00-$94) across rendering** because
  `StampWarpMarkers` uses DP `$80`–`$82` as a long pointer to the warp table,
  which overwrites the engine's collision tile map pointer. Without the
  save/restore, all collision checks read garbage after the minimap closes,
  causing actors to freeze.
- The original `RadarScreenSetup` uses only DPs `$02`, `$18`–`$1E` as scratch,
  avoiding this conflict entirely — the minimap's wider DP usage is the reason
  the save/restore pattern was necessary.

---

## See Also

- [field-input-and-items.md](field-input-and-items.md) — `GlobalInputHandler` Start button opens radar; item handlers reference inventory
- [mode7-and-cutscenes.md](mode7-and-cutscenes.md) — `IrisCircleEffect` vs `WorldMapSplitEffect` comparison; shared HDMA windowing concepts
- [scene-and-hardware.md](scene-and-hardware.md) — `ClearSceneState` initializes scene $FE; transition effects used by world map
- [actor-thinker-runtime.md](actor-thinker-runtime.md) — `WorldMapController` is an actor; `WorldMapSplitEffect` is a thinker
- [Bank $03 index](README.md) — bank-wide memory map, WRAM reference, design patterns
