# Bank `$03` — Engine Core Reference

> Source-of-truth documentation for the Illusion of Gaia engine code residing in
> ROM bank `$03`. This index groups every major component into focused
> categories, gives a broad functional overview of each part, and links out to
> per-category deep-dive documents.
>
> All addresses are **SNES/ROM addresses in hexadecimal** (bank byte `$03`).
> Address ranges are sourced from [`db-us/blocks.json`](../../../db-us/blocks.json).

---

## 1. Bank overview

Bank `$03` holds the **runtime engine core** of IOG: the per-frame game loop
subsystems (actors, thinkers, collision, sprites), the field-input/item/inventory
UI layer, the world-map and radar navigation screens, the Mode 7 perspective and
HDMA cutscene machinery, the text/menu renderers, and the scene-lifecycle +
hardware-I/O (DMA/HDMA/SPC) + save infrastructure.

| Metric | Value |
|--------|-------|
| **Documented span** | `$038000`–`$03F201` |
| **Total size** | ~28.5 KB (contiguous, no gaps) |
| **Source files** | 27 `.asm` units in `extracted/` |
| **Categories** | 8 |
| **Primary caller** | `system_core` main game loop (external, bank `$02`) |

> The remainder of the bank (`$03F201`–`$03FFFF`) holds scene-specific and
> unrelated data outside the scope of this reference.

---

## 2. Memory map

Blocks are listed in ascending address order. Several logical units are
**non-contiguous** (their code is interleaved with neighbors); those rows are
marked and share a `⇢` continuation marker.

```
$038000 ┌──────────────────────────────────────────────┐
        │ GlobalInputHandler          $038000–$0380BF  │  Field Input & Items
$0380BF ├──────────────────────────────────────────────┤
        │ radar_map_screen            $0380BF–$038410  │  Radar & World Map
$038410 ├──────────────────────────────────────────────┤
        │ item_use_system             $038410–$03A0AA  │  Field Input & Items
        │   (item dispatcher + 41 handlers + strings)  │
$03A0AA ├──────────────────────────────────────────────┤
        │ garden_crash_cutscene       $03A0AA–$03A1FA  │  Mode 7 & Cutscenes
$03A1FA ├──────────────────────────────────────────────┤
        │ future_vision_cutscene      $03A1FA–$03A2F1  │  Mode 7 & Cutscenes
$03A2F1 ├──────────────────────────────────────────────┤
        │ WorldMapController          $03A2F1–$03A6BA  │  Radar & World Map
$03A6BA ├──────────────────────────────────────────────┤
        │ IrisCircleEffect            $03A6BA–$03A83E  │  Mode 7 & Cutscenes
$03A83E ├──────────────────────────────────────────────┤
        │ HdmaWindowEffect            $03A83E–$03A940  │  Radar & World Map
$03A940 ├──────────────────────────────────────────────┤
        │ mode7_perspective           $03A940–$03AB88  │  Mode 7 & Cutscenes
$03AB88 ├──────────────────────────────────────────────┤
        │ mode7_perspective_unused    $03AB88–$03AD77  │  Mode 7 & Cutscenes (dead)
$03AD77 ├──────────────────────────────────────────────┤
        │ world_map_routes  (data)    $03AD77–$03B1D4  │  Radar & World Map
$03B1D4 ├──────────────────────────────────────────────┤
        │ world_map_names   (data)    $03B1D4–$03B401  │  Radar & World Map
$03B401 ├──────────────────────────────────────────────┤
        │ world_map_options (data+code)$03B401–$03BAE1 │  Radar & World Map
$03BAE1 ├──────────────────────────────────────────────┤
        │ oam_digit_compose           $03BAE1–$03BB85  │  Sprite Rendering
$03BB85 ├──────────────────────────────────────────────┤
        │ combat_collision            $03BB85–$03C5FF  │  Movement & Collision
$03C5FF ├──────────────────────────────────────────────┤
        │ sprite_composition ⇢        $03C5FF–$03CAF5  │  Sprite Rendering
$03CAF5 ├──────────────────────────────────────────────┤
        │ actor_execution             $03CAF5–$03D12D  │  Actor & Thinker Runtime
$03D12D ├──────────────────────────────────────────────┤
        │ thinker_execution ⇢         $03D12D–$03D1F5  │  Actor & Thinker Runtime
$03D1F5 ├──────────────────────────────────────────────┤
        │ tile_collision_physics      $03D1F5–$03D7E7  │  Movement & Collision
$03D7E7 ├──────────────────────────────────────────────┤
        │ thinker_execution ⇢         $03D7E7–$03D86A  │  Actor & Thinker Runtime
$03D86A ├──────────────────────────────────────────────┤
        │ sprite_composition ⇢        $03D86A–$03D881  │  Sprite Rendering
$03D881 ├──────────────────────────────────────────────┤
        │ hdma_dma_spc ⇢              $03D881–$03D916  │  Scene & Hardware
$03D916 ├──────────────────────────────────────────────┤
        │ save_system                 $03D916–$03D9E8  │  Scene & Hardware
$03D9E8 ├──────────────────────────────────────────────┤
        │ scene_lifecycle             $03D9E8–$03E0B0  │  Scene & Hardware
$03E0B0 ├──────────────────────────────────────────────┤
        │ hdma_dma_spc ⇢              $03E0B0–$03E255  │  Scene & Hardware
$03E255 ├──────────────────────────────────────────────┤
        │ DialogStringRenderer        $03E255–$03E849  │  Text & Menus
$03E849 ├──────────────────────────────────────────────┤
        │ MenuSelectionHandler        $03E849–$03EA62  │  Text & Menus
$03EA62 ├──────────────────────────────────────────────┤
        │ ConsoleStringRenderer       $03EA62–$03EF97  │  Text & Menus
$03EF97 ├──────────────────────────────────────────────┤
        │ inventory_mgmt              $03EF97–$03F0CA  │  Field Input & Items
$03F0CA ├──────────────────────────────────────────────┤
        │ GetPlayerFacingDirection    $03F0CA–$03F1D0  │  Field Input & Items
$03F1D0 ├──────────────────────────────────────────────┤
        │ hdma_dma_spc ⇢              $03F1D0–$03F201  │  Scene & Hardware
$03F201 └──────────────────────────────────────────────┘
```

**Non-contiguous units** (`⇢`): `sprite_composition`, `thinker_execution`, and
`hdma_dma_spc` each occupy multiple disjoint address ranges. Their fragments are
documented together within a single category document.

---

## 3. Categories

| # | Category | Address footprint | Parts | Document |
|---|----------|-------------------|-------|----------|
| 1 | Field Input, Items & Inventory | `$038000`–`$0380BF`, `$038410`–`$03A0AA`, `$03EF97`–`$03F1D0` | 4 | [field-input-and-items.md](field-input-and-items.md) |
| 2 | Radar & World Map | `$0380BF`–`$038410`, `$03A2F1`–`$03A6BA`, `$03A83E`–`$03A940`, `$03AD77`–`$03BAE1` | 6 | [radar-and-world-map.md](radar-and-world-map.md) |
| 3 | Mode 7 Perspective & Cutscenes | `$03A0AA`–`$03A2F1`, `$03A6BA`–`$03A83E`, `$03A940`–`$03AD77` | 5 | [mode7-and-cutscenes.md](mode7-and-cutscenes.md) |
| 4 | Actor & Thinker Runtime | `$03CAF5`–`$03D12D`, `$03D12D`–`$03D1F5`, `$03D7E7`–`$03D86A` | 2 | [actor-thinker-runtime.md](actor-thinker-runtime.md) |
| 5 | Movement, Physics & Combat Collision | `$03BB85`–`$03C5FF`, `$03D1F5`–`$03D7E7` | 2 | [movement-and-collision.md](movement-and-collision.md) |
| 6 | Sprite Composition & OAM | `$03BAE1`–`$03BB85`, `$03C5FF`–`$03CAF5`, `$03D86A`–`$03D881` | 2 | [sprite-rendering.md](sprite-rendering.md) |
| 7 | Text Rendering & Menus | `$03E255`–`$03EF97` | 3 | [text-and-menus.md](text-and-menus.md) |
| 8 | Scene Lifecycle, DMA/HDMA/SPC & Save | `$03D881`–`$03D916`, `$03D916`–`$03D9E8`, `$03D9E8`–`$03E0B0`, `$03E0B0`–`$03E255`, `$03F1D0`–`$03F201` | 3 | [scene-and-hardware.md](scene-and-hardware.md) |

---

## 4. Per-part reference

### Category 1 — Field Input, Items & Inventory → [field-input-and-items.md](field-input-and-items.md)

The player-facing interaction layer: the top-level field button gate, the
Y-button item dispatcher with all 41 item handlers, inventory slot bookkeeping,
and the player-facing-direction helper.

| Part | Range | Source |
|------|-------|--------|
| **GlobalInputHandler** | `$038000`–`$0380BF` | [GlobalInputHandler.asm](../../../extracted/system/engine/GlobalInputHandler.asm) |

Per-frame UI input dispatcher called from `system_core` between warp/chest checks
and actor execution. Five guard conditions suppress input (pending scene
transition, game-over, music playing, run/ability active, no button). Dispatches
the three UI buttons: **Start** → map/radar screen (delegates to
`radar_map_screen`, with a `PAUSE` overlay variant when the input-lock flag is
set), **Select** → inventory screen, **Y** → item use (`ItemUseDispatch`). Start
is checked before the run/ability guard so the map is reachable while running.

| Part | Range | Source |
|------|-------|--------|
| **item_use_system** | `$038410`–`$03A0AA` | [item_use_system.asm](../../../extracted/system/engine/item_use_system.asm) |

The complete inventory item-usage pipeline. `ItemUseDispatch` reads the equipped
slot, extracts the 6-bit item ID (`$00`–`$3F`), and dispatches through a 64-entry
jump table. Handlers return via `RTS` into a shared `ItemUseEpilogue` using a
stacked-return (`PEA`) trick. Handler families: **display-only** story items,
**scene-gated key/placement items** (check `sceneCurrent` + player tile position,
then remove item / set event flag / edit tilemap), **melody items** (Wind, Lola,
Memory — share `FluteMusicActorController` for the SPC upload → playback → effect
→ restore cycle), and **dialogue-option items** (Herb, Journal, Hieroglyph
Plates). Notable mechanics: Red Jewel BCD counter + orbit VFX, six-slot
Hieroglyph plate swap puzzle, Aura shadow-form transformation, Gorgon Flower
three-petal partial-completion flags.

| Part | Range | Source |
|------|-------|--------|
| **inventory_mgmt** | `$03EF97`–`$03F0CA` | [inventory_mgmt.asm](../../../extracted/system/inventory/inventory_mgmt.asm) |

Inventory slot management. `GiveItemToPlayer` scans the 16-slot inventory
(`$0AB4`) for a free slot (or handles the "inventory full" case) and stores the
item; supports a high-bit ($80) path for special insert semantics. Referenced by
item handlers (e.g., the Hieroglyph plate swap returns the displaced plate here)
and shares item-name lookups with the HUD renderer.

| Part | Range | Source |
|------|-------|--------|
| **GetPlayerFacingDirection** | `$03F0CA`–`$03F1D0` | [GetPlayerFacingDirection.asm](../../../extracted/system/engine/GetPlayerFacingDirection.asm) |

Small helper that resolves the player actor's current facing (via the actor's
animation/direction field indexed into `FacingDirectionLookup`). Returns carry
clear for the four cardinal directions (`< $04`), carry set otherwise. Used by
interaction/item logic that needs the direction the player is looking.

---

### Category 2 — Radar & World Map → [radar-and-world-map.md](radar-and-world-map.md)

The two navigation surfaces: the in-area radar minimap overlay, and the
overworld travel map (`scene $FE`) with its route bytecode, area-name table, and
per-destination option handlers.

| Part | Range | Source |
|------|-------|--------|
| **radar_map_screen** | `$0380BF`–`$038410` | [radar_map_screen.asm](../../../extracted/system/engine/radar_map_screen.asm) |

Renders the hold-Start radar/minimap overlay. `RadarScreenSetup` DMAs radar icon
graphics + tilemap, computes a 68×68-tile viewport centered on the player
(4-tile/cell resolution), plots scene-transition markers, friendly actors (blue
dots) and enemies (red dots), shows BCD marker/actor counts, and draws an
enemy-clear reward chest icon when eligible. `RadarBorderAnimate` cycles a
29-entry border tile table every other frame. Called only from
`GlobalInputHandler`.

| Part | Range | Source |
|------|-------|--------|
| **WorldMapController** | `$03A2F1`–`$03A6BA` | [WorldMapController.asm](../../../extracted/system/world_map/WorldMapController.asm) |

Sole actor for the world-map scene (`$FE`). Implements arrival (gravity-drop
landing animation), companion-dot formation, location-name display, table-driven
route travel (a bytecode interpreter over `world_map_routes` with one level of
subroutine nesting), and scene entry on arrival. Owns the world-map state block
`$0D52`–`$0D6F` (positions, destination/route IDs, companion array, deferred
scene). Spawns `HdmaWindowEffect` during travel and dispatches destinations
through `world_map_options`.

| Part | Range | Source |
|------|-------|--------|
| **HdmaWindowEffect** | `$03A83E`–`$03A940` | [HdmaWindowEffect.asm](../../../extracted/system/world_map/HdmaWindowEffect.asm) |

Thinker spawned by `WorldMapController` during travel. Manages double-buffered
sine-table data (selected by frame parity) driving HDMA window registers to
create an iris/spotlight transition. Supports steady-state, a 40-frame opening
iris animation, and a final hold. Writes 7-byte HDMA parameter blocks from two
templates into `$7E8800`/`$7E8A00`.

| Part | Range | Source |
|------|-------|--------|
| **world_map_routes** | `$03AD77`–`$03B1D4` | [world_map_routes.asm](../../../extracted/system/world_map/world_map_routes.asm) |

Data: a `&route-step` pointer table plus the route-step records it references.
Each `route-step` record encodes X/Y/Z movement delta-table indices + a frame
count; `$FE` = subroutine call, `$FF` = end. Consumed by
`WorldMapController.RouteAnimationEngine`.

| Part | Range | Source |
|------|-------|--------|
| **world_map_names** | `$03B1D4`–`$03B401` | [world_map_names.asm](../../../extracted/system/world_map/world_map_names.asm) |

Data: a `map-label` table pairing a scene/area ID with a sprite-string pointer
for the on-map area name. Linearly searched by `LookupMapName`.

| Part | Range | Source |
|------|-------|--------|
| **world_map_options** | `$03B401`–`$03BAE1` | [world_map_options.asm](../../../extracted/system/world_map/world_map_options.asm) |

Data + code: a `&Code` dispatch table of per-destination option handlers
(`code_03B44F`…) selected by the destination ID in `$0D58`. Each handler sets up
the specific route/scene parameters for that world-map location.

---

### Category 3 — Mode 7 Perspective & Cutscenes → [mode7-and-cutscenes.md](mode7-and-cutscenes.md)

The Mode 7 rotation/scaling engine and the HDMA iris generator, plus the two
scene-specific cutscene actors that drive them.

| Part | Range | Source |
|------|-------|--------|
| **mode7_perspective** | `$03A940`–`$03AD77` (active portion `$03A940`–`$03AB88`) | [mode7_perspective.asm](../../../extracted/thinkers/mode7_perspective.asm) |

Thinker generating per-scanline Mode 7 rotation/scaling matrices, queued as HDMA
tables for M7A–M7D (`$211B`–`$211E`). Uses sine/cosine tables and a 4-quadrant
hardware-divide (`WRDIV`/`RDDIV`) pipeline with adaptive overflow halving and
divisor normalization. Drives the world map, prologue prophecy, Sky Garden crash,
and Angkor Wat future-vision perspective effects.

| Part | Range | Source |
|------|-------|--------|
| **mode7_perspective_unused** | `$03AB88`–`$03AD77` | [mode7_perspective_unused.asm](../../../extracted/unused/mode7_perspective_unused.asm) |

**Dead code.** An earlier/alternate Mode 7 implementation never referenced by any
scene, thinker spawn, or COP handler. Differs from the active version: 3-entry
indirect HDMA headers, high-to-low fill, subtractive perspective, no divisor
normalization, borrow-based accumulation, `QueueHdma` instead of `QueueDma`, and
fewer hardware-divide delay NOPs. Likely superseded during development.

| Part | Range | Source |
|------|-------|--------|
| **IrisCircleEffect** | `$03A6BA`–`$03A83E` | [IrisCircleEffect.asm](../../../extracted/prologue/prologue_prophecy/IrisCircleEffect.asm) |

Thinker generating a circular-window HDMA table each frame via hardware multiply
(`WRMPY`/`RDMPY`). Double-buffered (`$7E8D00`/`$7E8E00`), radius controlled by
actor field `$B6`, producing a per-scanline window gradient that approximates a
circle cross-section (iris closes as `$B6` grows). Used in the prologue prophecy
scene (`$8C`) and the world map (`$FE`).

| Part | Range | Source |
|------|-------|--------|
| **garden_crash_cutscene** | `$03A0AA`–`$03A1FA` | [garden_crash_cutscene.asm](../../../extracted/sky_garden/garden_crash/garden_crash_cutscene.asm) |

Scene `$59` actor for the Sky Garden crash. Configures Mode 7 color math, spawns
`Mode7PerspectiveUpdate` (params `$0804`) and a companion `CrashCameraController`
thinker, then choreographs approach → gravity acceleration → impact (sets flag
`$0AA6`, queues map change to scene `$58`) → debris SFX burst.

| Part | Range | Source |
|------|-------|--------|
| **future_vision_cutscene** | `$03A1FA`–`$03A2F1` | [future_vision_cutscene.asm](../../../extracted/angkor_wat/future_vision/future_vision_cutscene.asm) |

Scene `$C0` actor for the Angkor Wat future vision. Shares the garden-crash
Mode 7 setup, adds an initial palette flash, and drives a 5-phase choreography
(zoom-in + rotate → full rotation → pause + zoom-out + scroll → long upward
scroll with a 16-step brightness fade → transition to scene `$BF`) via
`FutureVisionController`.

---

### Category 4 — Actor & Thinker Runtime → [actor-thinker-runtime.md](actor-thinker-runtime.md)

The heart of the per-frame simulation: the actor update loop (five execution
contexts), the actor/thinker memory pools, scene spawning, and the thinker
scheduler.

| Part | Range | Source |
|------|-------|--------|
| **actor_execution** | `$03CAF5`–`$03D12D` | [actor_execution.asm](../../../extracted/system/engine/actor_execution.asm) |

The complete actor update pipeline. Five execution contexts (`RunActors_Normal`,
`_DisplayFiltered`, `_PauseFiltered`, `_CutsceneOnly`, `_OverlayOnly`) selected by
game-state flags, each iterating the actor linked list and dispatching to each
actor's COP script via the `PHK`/`PEA`/`PHA`/`RTL` indirect-call trick, followed
by post-tick movement. Also owns iframe counting (`$7F0028,X`), pool
initialization (`InitActorPool`: 84 actor slots + 16 thinker slots,
`ThinkerPoolAlloc`), scene actor spawning (`SpawnSceneActors` +
`InitActorFromSceneData` record parser), and defeated-enemy handling.

| Part | Range | Source |
|------|-------|--------|
| **thinker_execution** | `$03D12D`–`$03D1F5` + `$03D7E7`–`$03D86A` | [thinker_execution.asm](../../../extracted/system/engine/thinker_execution.asm) |

Thinker lifecycle and per-frame dispatch. Thinkers are lightweight script actors
(16-slot pool at `$0F00`, doubly-linked list rooted at `$5A`) handling ambient
effects, palette cycling, background animation, and HDMA cutscene effects.
`SpawnSceneThinkers` + `InitThinkerFromSceneData` parse the scene thinker list;
four execution filters (`RunThinkers_TypeA`–`TypeD`, selected by filter-flag bits
for general/deferred × normal/cutscene) run at different points in the game loop
using the same COP dispatch pattern as actors.

---

### Category 5 — Movement, Physics & Combat Collision → [movement-and-collision.md](movement-and-collision.md)

Tile-based actor movement (with and without collision) and the actor-vs-actor
combat/interaction collision + damage system.

| Part | Range | Source |
|------|-------|--------|
| **tile_collision_physics** | `$03D1F5`–`$03D7E7` | [tile_collision_physics.asm](../../../extracted/system/engine/tile_collision_physics.asm) |

Axis-separated actor movement. `ApplyMovement` (no collision, airborne/overlay)
and `ApplyMovementWithCollision` (grounded) resolve X first (`MoveLeft`/`Right`)
then Y (`MoveUp`/`Down`), each returning carry set on block / clear on pass.
Reads deltas from an override chain (`$2C`/`$2E`) or per-actor scratch, negated by
direction bits in `$12`. Decodes the packed two-nibble collision tile map via
`[$80]`/`CalcTileMapOffset`, snaps position to tile boundaries on block, and
implements a bounce mechanism (`EOR $6000` on direction).

| Part | Range | Source |
|------|-------|--------|
| **combat_collision** | `$03BB85`–`$03C5FF` | [combat_collision.asm](../../../extracted/system/engine/combat_collision.asm) |

All actor-vs-actor collision and damage. Iterates the actor render list (`$0C00`)
so off-screen actors are never tested. Two pipelines: `RunCombatCollision`
(player-attacks-enemy hit test + enemy-hits-player AABB test with normal/friendly
masks) and `RunInteractionCollision` (NPC/object interaction against the player
bounding box). Decodes signed hitbox offsets from the metasprite header
(`$0004`–`$0007`, H-mirror aware), applies damage formulas
(`chainDamage/2 + 1` for player hits; `max(1, enemyAtk − totalStr)` for enemy
hits), and handles knockback, damage-number formatting, and death.

---

### Category 6 — Sprite Composition & OAM → [sprite-rendering.md](sprite-rendering.md)

The actor-to-OAM rendering pipeline (render-list build, depth sort, metasprite
decomposition, OAM packing) plus the floating damage-digit sprite composer.

| Part | Range | Source |
|------|-------|--------|
| **sprite_composition** | `$03C5FF`–`$03CAF5` + `$03D86A`–`$03D881` | [sprite_composition.asm](../../../extracted/system/engine/sprite_composition.asm) |

Converts actor metasprites into the 128-entry hardware OAM table each frame in
four stages: `ClearActorRenderList` (zeros the `$0200`–`$03FE` bucket array +
`$FFFF` sentinel), `SortActorsByDepth` (bucket sort keyed by inverted screen-Y,
with fixed keys for always-front/always-behind flags; `BuildFinalList` emits the
sorted list at `$0C00`), and `ComposeAllSprites` (pre-fills OAM with off-screen
`$E080`, then decomposes the compose buffer at `$7F3100` and each sorted actor's
7-byte-per-subsprite metasprite, packing the 2-bpp OAM high table).

| Part | Range | Source |
|------|-------|--------|
| **oam_digit_compose** | `$03BAE1`–`$03BB85` | [oam_digit_compose.asm](../../../extracted/system/engine/oam_digit_compose.asm) |

Converts packed-BCD damage numbers into individual digit sprites in the compose
buffer at `$7F3100` (6-byte entries: X, Y, tile). Renders hundreds→tens→ones
left-to-right, skipping leading zeros (half-width advance) vs. full glyphs. Called
by combat hit effects to render floating damage numbers above actors; includes a
re-entry point for appending adjacent number groups.

---

### Category 7 — Text Rendering & Menus → [text-and-menus.md](text-and-menus.md)

The two independent text engines (wide-string dialogue and ASCII HUD/console) and
the dialogue-choice menu cursor.

| Part | Range | Source |
|------|-------|--------|
| **DialogStringRenderer** | `$03E255`–`$03E849` | [DialogStringRenderer.asm](../../../extracted/system/engine/DialogStringRenderer.asm) |

The dialogue text engine. Bytecode-driven wide-string format: bytes `< $C0` are
tile indices rendered as 16×16 characters (top+bottom tile rows into the
`$7F0200` VRAM staging buffer), bytes `$C0`–`$FF` are opcodes dispatched via a
25-entry command table (box open/clear, position/palette, templates, indirect &
remote strings, number formatting, newline/scroll, wait-for-input, frame delay,
etc.) using an `RTS`-trick dispatch. Maintains cursor/box state in work RAM
(`$0998`, `$097A`–`$0980`, `$099A`–`$099C`, …). Entered via `JSL` from COP
handlers.

| Part | Range | Source |
|------|-------|--------|
| **MenuSelectionHandler** | `$03E849`–`$03EA62` | [MenuSelectionHandler.asm](../../../extracted/system/engine/MenuSelectionHandler.asm) |

General-purpose menu cursor for dialogue choices. A packed stack parameter encodes
grid geometry (rows / columns); handles Up/Down (wraparound), L/R (paging),
A/Start (confirm → sound #11, carry set) and B (cancel → result 0). `DrawMenuCursor`
runs a 16-frame blink between highlight/dim tiles (saving/restoring the tile under
the cursor); `ReadMenuSelection` converts the cursor position to OAM sprite data.

| Part | Range | Source |
|------|-------|--------|
| **ConsoleStringRenderer** | `$03EA62`–`$03EF97` | [ConsoleStringRenderer.asm](../../../extracted/system/engine/ConsoleStringRenderer.asm) |

The HUD/UI text engine (inventory, status, HP bars, equipment icons, bordered
boxes). Simpler 8-bit charset: bytes `>= $12` are literal tiles, bytes `$00`–`$11`
are opcodes in an 18-entry table (set VRAM addr/palette, remote/indirect strings,
BCD/decimal numbers, draw box, clear column/rect, fill tile, equip icons, player &
enemy HP bars, raw bytes, item-name insert, row advances). Dispatches via indirect
`JSR ($addr,X)` and supports recursive renders. Entered via `JSL`.

---

### Category 8 — Scene Lifecycle, DMA/HDMA/SPC & Save → [scene-and-hardware.md](scene-and-hardware.md)

Scene transition orchestration, the shared hardware-transfer + audio utility
block, and SRAM save/load.

| Part | Range | Source |
|------|-------|--------|
| **scene_lifecycle** | `$03D9E8`–`$03E0B0` | [scene_lifecycle.asm](../../../extracted/system/engine/scene_lifecycle.asm) |

The scene transition pipeline. `CheckSceneTransition` → `ExecuteSceneTransition`
orchestrates exit effect → NMI off → target resolution → `ClearSceneState` (the
"big setup": scene-script parse, camera bounds, event blocks, barrier tiles,
actor/thinker spawn, palette/graphics load, initial tilemap render) → enter
effect → optional press-start wait. Provides 4–5 exit/enter visual transition
types (brightness fade, instant, mosaic dissolve, sine-wave HDMA scroll
distortion) built with hardware multiply.

| Part | Range | Source |
|------|-------|--------|
| **hdma_dma_spc** | `$03D881`–`$03D916` + `$03E0B0`–`$03E255` + `$03F1D0`–`$03F201` | [hdma_dma_spc.asm](../../../extracted/system/engine/hdma_dma_spc.asm) |

A mixed hardware-utility block across three ranges: **player tile DMA**
(`DmaPlayerTilesToVram`, up to 8 queued 16×16 tiles during V-Blank),
**palette/graphics loading** (`LoadPaletteBundle`, `DecompressGfxToVram`),
**HDMA channel management** (`ResetHdmaState`, `SetupHdmaChannel_Indirect/Direct`
from a register lookup table), **SPC audio transfer** (ready handshake, music data
send with confirmation, transition-state music resolution), and **ad-hoc VRAM
DMA** (`DmaAdhocVramBlock` for deferred one-shot writes queued at `$7F0C03`).

| Part | Range | Source |
|------|-------|--------|
| **save_system** | `$03D916`–`$03D9E8` | [save_system.asm](../../../extracted/system/engine/save_system.asm) |

SRAM save/load with dual-checksum validation. Four 512-byte slots at
`$306200 + slot×512`. `SaveGameState_Scene`/`LoadGameState_Scene` copy 508 bytes
of event flags (`$0A00`–`$0BFC`, plus current scene at `$0B06`).
`ComputeSaveChecksum` produces an additive and an XOR checksum (both seeded with
`$3652` so blank SRAM fails validation). Load returns carry clear on success, set
on corrupt/empty; `ClearSaveSlot` zeroes a slot.

---

## 5. Cross-references & call flow

```
        system_core main loop (bank $02, external)
                    │
    ┌───────────────┼──────────────────────────────────────────┐
    ▼               ▼                     ▼                      ▼
GlobalInputHandler  ClearActorRenderList  RunActors_*      ComposeAllSprites
    │               (sprite_composition)  (actor_execution)  (sprite_composition)
    │                                         │                  ▲
    ├─ Start ─► radar_map_screen              │ COP dispatch     │
    ├─ Select ► inventory screen (external)   ▼                  │
    └─ Y ─────► ItemUseDispatch          per-actor script  SortActorsByDepth
               (item_use_system)              │
                    │                         ▼
                    │                    tile_collision_physics (post-tick move)
                    │                         │
                    ▼                         ▼
          FluteMusicActorController     RunCombatCollision / RunInteractionCollision
          RemoveEquippedItem            (combat_collision) ─► oam_digit_compose
          GiveItemToPlayer (inventory_mgmt)

  RunThinkers_TypeA–D (thinker_execution) ─► mode7_perspective / IrisCircleEffect / HdmaWindowEffect

  CheckSceneTransition (scene_lifecycle) ─► ClearSceneState ─► hdma_dma_spc (DMA/HDMA/SPC),
                                            actor_execution (spawn), save via save_system

  Text: DialogStringRenderer / ConsoleStringRenderer / MenuSelectionHandler  (JSL from COP + engine)

  World map (scene $FE): WorldMapController ─► world_map_options / world_map_routes / world_map_names,
                         spawns HdmaWindowEffect + mode7_perspective
```

---

## 6. Source file map

| Source `.asm` | blocks.json block | Category |
|---------------|-------------------|----------|
| [GlobalInputHandler.asm](../../../extracted/system/engine/GlobalInputHandler.asm) | `GlobalInputHandler` | 1 |
| [item_use_system.asm](../../../extracted/system/engine/item_use_system.asm) | `item_use_system` | 1 |
| [inventory_mgmt.asm](../../../extracted/system/inventory/inventory_mgmt.asm) | `inventory_mgmt` | 1 |
| [GetPlayerFacingDirection.asm](../../../extracted/system/engine/GetPlayerFacingDirection.asm) | `GetPlayerFacingDirection` | 1 |
| [radar_map_screen.asm](../../../extracted/system/engine/radar_map_screen.asm) | `radar_map_screen` | 2 |
| [WorldMapController.asm](../../../extracted/system/world_map/WorldMapController.asm) | `WorldMapController` | 2 |
| [HdmaWindowEffect.asm](../../../extracted/system/world_map/HdmaWindowEffect.asm) | `HdmaWindowEffect` | 2 |
| [world_map_routes.asm](../../../extracted/system/world_map/world_map_routes.asm) | `world_map_routes` | 2 |
| [world_map_names.asm](../../../extracted/system/world_map/world_map_names.asm) | `world_map_names` | 2 |
| [world_map_options.asm](../../../extracted/system/world_map/world_map_options.asm) | `world_map_options` | 2 |
| [mode7_perspective.asm](../../../extracted/thinkers/mode7_perspective.asm) | `mode7_perspective` | 3 |
| [mode7_perspective_unused.asm](../../../extracted/unused/mode7_perspective_unused.asm) | `mode7_perspective_unused` | 3 |
| [IrisCircleEffect.asm](../../../extracted/prologue/prologue_prophecy/IrisCircleEffect.asm) | `IrisCircleEffect` | 3 |
| [garden_crash_cutscene.asm](../../../extracted/sky_garden/garden_crash/garden_crash_cutscene.asm) | `garden_crash_cutscene` | 3 |
| [future_vision_cutscene.asm](../../../extracted/angkor_wat/future_vision/future_vision_cutscene.asm) | `future_vision_cutscene` | 3 |
| [actor_execution.asm](../../../extracted/system/engine/actor_execution.asm) | `actor_execution` | 4 |
| [thinker_execution.asm](../../../extracted/system/engine/thinker_execution.asm) | `thinker_execution` | 4 |
| [tile_collision_physics.asm](../../../extracted/system/engine/tile_collision_physics.asm) | `tile_collision_physics` | 5 |
| [combat_collision.asm](../../../extracted/system/engine/combat_collision.asm) | `combat_collision` | 5 |
| [sprite_composition.asm](../../../extracted/system/engine/sprite_composition.asm) | `sprite_composition` | 6 |
| [oam_digit_compose.asm](../../../extracted/system/engine/oam_digit_compose.asm) | `oam_digit_compose` | 6 |
| [DialogStringRenderer.asm](../../../extracted/system/engine/DialogStringRenderer.asm) | `DialogStringRenderer` | 7 |
| [MenuSelectionHandler.asm](../../../extracted/system/engine/MenuSelectionHandler.asm) | `MenuSelectionHandler` | 7 |
| [ConsoleStringRenderer.asm](../../../extracted/system/engine/ConsoleStringRenderer.asm) | `ConsoleStringRenderer` | 7 |
| [scene_lifecycle.asm](../../../extracted/system/engine/scene_lifecycle.asm) | `scene_lifecycle` | 8 |
| [hdma_dma_spc.asm](../../../extracted/system/engine/hdma_dma_spc.asm) | `hdma_dma_spc` | 8 |
| [save_system.asm](../../../extracted/system/engine/save_system.asm) | `save_system` | 8 |
