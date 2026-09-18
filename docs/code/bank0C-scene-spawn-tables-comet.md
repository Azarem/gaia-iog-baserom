# Bank $0C — Scene Spawn Tables & Comet Finale

> ROM bank `$0C` (`$0C8000`–`$0CFFFF`, 32,768 bytes) is primarily a **data bank**
> containing the game's two master spawn tables: the **Scene Actor Table** and the
> **Scene Thinker Table**. These tables define which actors and thinkers are
> instantiated when any scene loads — they are the central registry for all
> in-game entity placement. The remaining ~10% of the bank holds the
> **Comet / Space Flight** actors and thinkers for the game's final sequence,
> plus a small unused stub.
>
> The bank holds **7 mapped blocks** across 3 groups with **9 distinct pieces**.
> Coverage is **92.3%** mapped, with a 2,525-byte unmapped tail.

---

## 1. Coverage Summary

| Metric | Value |
|--------|-------|
| Bank range | `$0C8000`–`$0CFFFF` (819,200–851,967) |
| Total bank size | 32,768 bytes |
| Mapped | 30,243 bytes (92.3%) |
| Unmapped tail | 2,525 bytes at `$0CF623`–`$0CFFFF` |
| Parent blocks | 7 distinct blocks in `blocks.json` |
| Total pieces | 9 |
| Piece types | 2 × table, 2 × thinker-def, 2 × actor-def, 2 × Code, 1 × actor-def (unused) |
| Groups | `tables`, `babel_tower`, `unused` |
| Overrides | 0 (no entries in `overrides.json`) |
| Named addresses | 2 (`loc_0CF47E`, `loc_0CF4FF` — internal to Comet boss) |

---

## 2. Functional Group Summary

| Group | Bytes | % of Bank | Blocks | Primary Content |
|-------|-------|-----------|--------|-----------------|
| Scene Actor Table | 26,085 | 79.6% | 1 | Master actor spawn list for all 256 scene IDs |
| Scene Thinker Table | 1,398 | 4.3% | 1 | Master thinker spawn list for all 256 scene IDs |
| Comet Finale | 2,525 | 7.7% | 4 | Space Flight + Final Lair actors & thinkers |
| Unused | 4 | <0.1% | 1 | Dead actor stub |
| Unmapped tail | 2,525 | 7.7% | — | Uncharted padding/data |

---

## 3. Memory Map

### 3.1 Full Address Map

| Address | End | Size | Block / Part | Type | Group |
|---------|-----|------|--------------|------|-------|
| `$0C8000` | `$0CE5E5` | 26,085 | `scene_actors` | &scene-event | tables |
| `$0CE5E5` | `$0CEB5B` | 1,398 | `scene_thinkers` | &thinker-spawn | tables |
| `$0CEB5B` | `$0CEB74` | 25 | `sE7_thinker_0CEB5B` | thinker-def | babel_tower |
| `$0CEB74` | `$0CEC65` | 241 | `sE8_thinker_0CEB74` | thinker-def | babel_tower |
| `$0CEC65` | `$0CED4C` | 231 | `sE8_actor_0CEEAA` / `code_0CEC65` | Code | babel_tower |
| `$0CED4C` | `$0CEDC5` | 121 | `sE7_actor_0CEDC5` / `code_0CED4C` | Code | babel_tower |
| `$0CEDC5` | `$0CEEAA` | 229 | `sE7_actor_0CEDC5` / `sE7_actor_0CEDC5` | actor-def | babel_tower |
| `$0CEEAA` | `$0CF61F` | 1,909 | `sE8_actor_0CEEAA` / `sE8_actor_0CEEAA` | actor-def | babel_tower |
| `$0CF61F` | `$0CF623` | 4 | `actor_0CF61F` | actor-def | unused |
| `$0CF623` | `$0D0000` | 2,525 | *(unmapped tail)* | — | — |

### 3.2 Visual Layout

```
$0C8000 ┌──────────────────────────────────────────────────────────────┐
        │                                                              │
        │              SCENE ACTOR TABLE (scene_actors)                │
        │                                                              │
        │   ROM: 256-entry ptr array → scene_event composites          │
        │        (actor-spawn list + DialogString scene name)          │
        │                                                              │
        │   Extracted: Extract(1) splits into two parallel tables:     │
        │     scene_actors [...]              → spawn pointer array    │
        │     scene_actors_extract_table [...] → scene name pointers   │
        │                                                              │
        │   241 unique scenes, 594 actor defs, 1,798 spawns            │
        │   64 named locations, 177 with empty name strings            │
        │                                                              │
        │                    (26,085 bytes — 79.6%)                    │
        │                                                              │
$0CE5E5 ├──────────────────────────────────────────────────────────────┤
        │           SCENE THINKER TABLE (scene_thinkers)               │
        │                                                              │
        │   256-entry pointer array (512 bytes)                        │
        │   → 70 unique thinker_spawn blocks, each listing             │
        │     palette cyclers, parallax scrollers, HDMA effects        │
        │   46 unique thinker definitions, 204 total entries           │
        │                                                              │
        │                    (1,398 bytes — 4.3%)                      │
$0CEB5B ├──────────────────────────────────────────────────────────────┤
        │  sE7_thinker — Space Flight BG scroll (25 bytes)             │
        │  Decrements $0720 by 8/frame + HDMA queue                    │
$0CEB74 ├──────────────────────────────────────────────────────────────┤
        │  sE8_thinker — Comet Lair PPU config (241 bytes)             │
        │  5 phase configs controlling TM/TS, color math,              │
        │  window registers — flag-byte gated transitions              │
$0CEC65 ├──────────────────────────────────────────────────────────────┤
        │  code_0CEC65 — Comet Lair HDMA brightness ramp (231 bytes)   │
        │  Builds per-scanline HDMA table, double-buffered             │
        │  in $7E7C00/$7E7E00 for eye beam visual effect               │
$0CED4C ├──────────────────────────────────────────────────────────────┤
        │  code_0CED4C — Space Flight player falling script (121 bytes)│
        │  900-frame idle → downward descent → map transition to $E8   │
$0CEDC5 ├──────────────────────────────────────────────────────────────┤
        │  sE7_actor — Space Flight star/particle controller (229 b)   │
        │  Spawns 4 star variants, center-gap tunnel effect            │
$0CEEAA ├──────────────────────────────────────────────────────────────┤
        │                                                              │
        │  sE8_actor — DARK GAIA / COMET BOSS (1,909 bytes)            │
        │                                                              │
        │  Two-phase boss with mid-fight transformation:               │
        │  Phase 1: Eye beam (vertical bolt → rising spread)           │
        │  Transition: 128-frame camera scroll, PPU reconfig,          │
        │             BG change, arena decoration spawn                │
        │  Phase 2: Eye beam + tentacle pairs with homing AI,          │
        │           destructible weak point, floating spawners          │
        │  Death: Debris shower, palette cascade, map → Ending         │
        │                                                              │
$0CF61F ├──────────────────────────────────────────────────────────────┤
        │  actor_0CF61F — unused RTL stub (4 bytes)                    │
$0CF623 ├──────────────────────────────────────────────────────────────┤
        │  UNMAPPED TAIL (2,525 bytes)                                 │
$0D0000 └──────────────────────────────────────────────────────────────┘
```

---

## 4. Block Analysis

### 4.1 Scene Actor Table — `scene_actors` (26,085 bytes — 79.6%)

The **scene actor table** is the game's master registry of which actors spawn
when a scene loads. It is a contiguous data structure occupying nearly 80% of
the bank and is referenced every time the engine transitions to a new scene.

**File:** `extracted/tables/scene_actors.asm`

**Type:** `&scene-event` — a table of 2-byte bank-local pointers to scene-event
blocks.

**`blocks.json` definition:**

```json
"scene_actors": {
  "start": 819200,
  "end": 845285,
  "type": "&scene-event",
  "postProcess": "Extract(1)",
  "movable": true,
  "order": -1
}
```

#### Struct Definitions (`structs.json`)

The scene actor table is built from a hierarchy of struct types defined in
`db-us/structs.json`. These structs describe how the engine parses the raw
ROM bytes:

| Struct | Definition | Purpose |
|--------|-----------|---------|
| `scene-event` | `[ "enemy-spawn", "DialogString" ]` | Composite: spawn list + scene name |
| `enemy-spawn` | `[ Byte, Byte, Byte, @actor-def, Byte, Byte, Byte ]` | Full spawn entry (7 fields, discriminator `6`) |
| `actor-spawn` | `[ Byte, Byte, Byte, @actor-def ]` | Reduced spawn entry (4 fields, discriminator `0`, parent: `enemy-spawn`) |

**Key relationships:**

- **`scene-event`** is a two-part composite structure. Field 0 is a
  `$FF`-delimited list of `enemy-spawn` entries; field 1 is a `DialogString`
  containing the scene's display name.
- **`enemy-spawn`** is the base spawn type with a `delimiter` of `$FF`
  (end-of-list marker). It supports a discriminator system for variable-length
  entries.
- **`actor-spawn`** inherits from `enemy-spawn` with `discriminator: 0`,
  using only the first 4 fields (X, Y, variant, actor-def pointer). This is
  the format used by all spawns in IOG.

#### ROM Binary Format (Original)

In the ROM, each `scene-event` block contains **both** the actor spawn list
**and** the scene's display name string packed together as a single contiguous
block:

```
┌─ scene_actors pointer array ─────────────────────────────────┐
│  256 × 2-byte bank-local pointers (512 bytes at $0C8000)     │
│  Each points to a scene_event block within this bank         │
└──────────────────────────────────────────────────────────────┘
          │
          ▼
┌─ scene_event block (ROM layout) ─────────────────────────────┐
│  actor-spawn: X, Y, variant, @actor-def   (6 bytes)          │
│  actor-spawn: X, Y, variant, @actor-def   (6 bytes)          │
│  ...                                                         │
│  $FF                                      (delimiter byte)   │
│  DialogString: scene name text            (variable length)  │
│  $00                                      (string terminator)│
└──────────────────────────────────────────────────────────────┘
```

This means in the original ROM, "South Cape" the location name string is
stored immediately after the last actor-spawn entry and its `$FF` terminator
within the same scene_event block.

#### Post-Processing: `Extract(1)`

The `postProcess: "Extract(1)"` directive in `blocks.json` tells the engine
to **split** each `scene-event` composite during extraction. The parameter `1`
is the field index within the `scene-event` struct to extract — field 1 is the
`DialogString` (scene name).

The `Extract` post-processor (`gaia-core/src/rom/extraction/postprocessor.ts`)
performs these steps:

1. Iterates through each scene_event entry in the pointer table
2. Removes field `[1]` (the `DialogString`) from each struct
3. Leaves field `[0]` (the `enemy-spawn` / `actor-spawn` list) in place
4. Creates a parallel pointer table `scene_actors_extract_table` containing
   references to each extracted `DialogString` value
5. Emits the extracted strings as named labels: `scene_event_XXXXXX_value`

After post-processing, the single ROM-format table becomes **two** parallel
arrays:

```
scene_actors [...]               → actor spawn pointers (256 entries)
scene_actors_extract_table [...]  → scene name pointers (256 entries)
```

Both arrays are indexed by scene ID (`$00`–`$FF`), maintaining a 1:1
correspondence.

#### Extracted File Layout

The extracted `scene_actors.asm` file contains five distinct sections:

| Section | Lines | Content |
|---------|-------|---------|
| `?INCLUDE` directives | 1–599 | 599 actor definition file dependencies |
| `scene_actors [...]` | 603–860 | 256-entry pointer array to scene_event blocks |
| `scene_event_XXXXXX [...]` blocks | 862–4698 | 241 unique actor spawn lists |
| `scene_actors_extract_table [...]` | 4700–4958 | 256-entry pointer array to scene name strings |
| `scene_event_XXXXXX_value` labels | 4959–5439 | 241 unique scene name DialogStrings |

**Actor spawn format** (after extraction, each scene_event contains only spawns):

```
scene_event_0C8221 [               ← South Cape (36 actors)
  actor-spawn < #29, #2F, #02, @player_character.PlayerCharacterDef >
  actor-spawn < #00, #00, #00, @camera_scroll_controller >
  actor-spawn < #11, #11, #00, @camera_scroll.ScrollCameraTrack >
  actor-spawn < #20, #0E, #00, @town_door >
  ... (32 more actors) ...
]
```

**Scene name format** (extracted into parallel table):

```
scene_actors_extract_table [       ← Parallel pointer array
  &scene_event_0C821F_value   ;00  ← Scene $00 name
  &scene_event_0C8221_value   ;01  ← Scene $01 name
  ...
]

scene_event_0C8221_value `South Cape`    ← Scene $01 display name
scene_event_0C8325_value `Seaside Cave`  ← Scene $02 display name
scene_event_0C8200_value `TEST MAP`      ← Shared blank template name
```

Each `actor-spawn` record specifies:

```
actor-spawn < X_tile, Y_tile, variant, @actor_def_address >
```

- **X/Y tile** — spawn position in the scene's tile grid
- **Variant** — parameter byte passed to the actor (e.g., `#02` = player
  facing direction, `#30` = smoke animation variant, `#01` = Red Jewel index)
- **Actor def address** — long pointer (`@`) to the actor definition, which
  can reside in any bank

#### Scene Names

The extracted scene names are `DialogString` values displayed as location
titles when the player enters a scene. Of the 241 unique scene_event blocks:

- **64 have named locations** (e.g., `South Cape`, `Watermia`, `Pyramid`)
- **177 have empty strings** (dungeon rooms, transitions, subscreen areas)

The shared blank template `scene_event_0C8200` (used by 16 unused scene IDs)
has the name `TEST MAP` — a development artifact. Scene `$00`
(`scene_event_0C821F`) has an empty string.

Notable scene name patterns:
- Town/village names appear once per overworld entrance scene
- Dungeon names appear only at the dungeon entry point, not for interior rooms
- `Dark Space` is used by 6 different scenes (`$EB`–`$EF`, `$F7`)
- `Sky Garden` and `Back of Garden` alternate across 8 scenes (`$4C`–`$56`)
- Sub-locations use descriptive names: `Guest Room`, `Passage - Outside`,
  `Main Hall 1F` through `Main Hall 4F`

#### Statistics

| Metric | Value |
|--------|-------|
| Pointer array entries | 256 (one per scene ID, `$00`–`$FF`) |
| Unique scene_event blocks | 241 |
| Total actor-spawn records | 1,798 |
| Unique actor definitions referenced | 594 |
| `?INCLUDE` directives (dependency files) | 599 |
| Average actors per scene | 7.5 |
| Max actors in a single scene | 58 (`scene_event_0CBDC4` — Euro Rolek Market) |
| Scenes with 0 actors | 2 (`scene_event_0C821F` for scene `$00`) |
| Shared blank template | `scene_event_0C8200` — used by 16 scene IDs |
| Scene IDs not in `groups.json` | 28 (unused/transitional/internal scenes) |

#### Most Frequently Spawned Actors

Nearly every scene includes the player and camera system:

| Count | Actor | Purpose |
|-------|-------|---------|
| 224× | `player_character.PlayerCharacterDef` | Player controller |
| 220× | `camera_scroll_controller` | Camera logic |
| 102× | `camera_scroll.ScrollCameraTrack` | Camera tracking (free scroll) |
| 31× | `dark_space.dark_space2` | Dark Space portal |
| 26× | `scene_flag_init` | Scene flag initialization |
| 26× | `ramps.ramp_east` | Eastward ramp collision |
| 22× | `ramps.ramp_west` | Westward ramp collision |
| 20× | `sg55_falling_tile` | Viper Lair floor tiles |
| 16× | `town_door` | Town building doorway |
| 16× | `hidden_red_jewel` | Collectible Red Jewel |
| 16× | `visual_effect_pipeline.effect_position_update` | VFX position sync |
| 15× | `overworld_exit` | Exit to world map |

#### Actors by Region

| Region | Scenes | Actors | Largest Scene |
|--------|--------|--------|---------------|
| Angel Village | 14 | 158 | `$6C` (26 actors) |
| Sky Garden | 13 | 140 | `$55` (25 actors) |
| Euro | 13 | 128 | `$91` (58 actors — Rolek Market) |
| Edward Castle | 10 | 120 | `$0A` (42 actors) |
| Freejia | 13 | 105 | — |
| Pyramid | 17 | 100 | — |
| Watermia | 8 | 92 | `$78` (47 actors) |
| South Cape | 8 | 83 | `$01` (36 actors) |
| Great Wall | 8 | 83 | — |
| Incan Ruins | 14 | 81 | `$29` (40 actors — Castoth's Lair) |
| Mu | 9 | 79 | — |
| Mountain Temple | 10 | 76 | — |
| Babel Tower | 15 | 76 | — |
| Angkor Wat | 17 | 75 | — |
| Diamond Mine | 11 | 57 | — |
| Gold Ship | 6 | 55 | — |
| Dao | 7 | 52 | — |
| Itory | 7 | 47 | — |
| Seaside Palace | 5 | 43 | — |
| Native Village | 3 | 36 | — |
| Nazca | 2 | 22 | — |
| System (menus) | 7 | 22 | — |
| Ending | 5 | 14 | — |
| Prologue | 4 | 12 | — |
| Mansion | 2 | 10 | — |
| *Unmapped IDs* | 28 | 77 | — |

#### Blank Template Scenes

16 scene IDs share the minimal 3-actor template `scene_event_0C8200`
(player + camera controller + camera scroll). These are scenes not in
`groups.json` — likely unused, transitional, or placeholder scene slots:

`$48`, `$57`, `$76`, `$77`, `$80`, `$81`, `$9E`, `$AA`, `$AB`, `$AF`,
`$C1`, `$C2`, `$CA`, `$CB`, `$F8`, `$F9`

Scene `$00` uses `scene_event_0C821F` which is completely empty (0 actors) —
a true null scene.

**Properties (`blocks.json`):**
- `type: "&scene-event"` — pointer table of `scene-event` composite structs
- `movable: true` — the table can be relocated during rebuild
- `postProcess: "Extract(1)"` — splits scene names from spawn data (see above)
- `order: -1` — extracted before other blocks to satisfy cross-references

---

### 4.2 Scene Thinker Table — `scene_thinkers` (1,398 bytes — 4.3%)

The **scene thinker table** is the companion to the scene actor table. It maps
each scene ID to a list of thinker definitions that activate when the scene
loads. Thinkers handle background visual effects: palette cycling, parallax
scrolling, HDMA wave/distortion effects, screen mode configuration, and
ambient lighting.

**File:** `extracted/tables/scene_thinkers.asm`

**Type:** `&thinker-spawn` — a table of 2-byte bank-local pointers to
thinker-spawn blocks.

#### Structure

Identical layout to the actor table: a 256-entry pointer array followed by
thinker_spawn blocks. Each block lists `thinker-spawn` records:

```
thinker-spawn < param, @thinker_def_address >
```

- **param** — configuration byte (e.g., palette index for cycler, layer ID
  for parallax, wave amplitude for HDMA)
- **thinker def address** — long pointer to the thinker definition code

#### Statistics

| Metric | Value |
|--------|-------|
| Pointer array entries | 256 |
| Unique thinker_spawn blocks | 70 |
| Total thinker-spawn entries | 204 |
| Unique thinker definitions referenced | 46 |
| `?INCLUDE` directives | 45 (thinker definition files + 2 comet thinkers) |

#### Thinker Types — Full Catalog

**Universal (present in nearly all scenes):**

| Thinker | Uses | Purpose |
|---------|------|---------|
| `global_ambient_dispatcher` | 59× | Default ambient lighting system. Present in almost every scene. |
| `ambient_palette_cycler` | 59× | Animated palette rotation with configurable palette index. Handles water shimmer, lava glow, torch flicker, crystal sparkle, etc. Parameter selects which palette rows to cycle. |
| `parallax_thinker` | 30× | Multi-layer background parallax scrolling. Parameter selects which BG layer and scroll mode (e.g., `#1E` = Great Wall, `#03` = world map, `#1D` = Seaside rooms). |

**Area-specific visual effects:**

| Thinker | Uses | Purpose |
|---------|------|---------|
| `sine_hdma_ending_wave` | 5× | Sinusoidal HDMA wave distortion for ending/Babel sequences |
| `incan_ruins_transform_palette` | 3× | Incan Ruins palette transformation effect (Larai Cliff area) |
| `sine_hdma_slow_wave` | 2× | Slow water wave HDMA distortion (Gold Ship, Babel Tower) |
| `sine_hdma_dual_channel` | 2× | Dual-channel wavy distortion (Seaside Palace, Angel Village river) |
| `ending_comet_dma_setup` | 2× | DMA initialization for comet/ending scenes |
| `IrisCircleEffect` | 2× | Circular iris wipe transition (Sand Fanger, World Map) |
| `palette_parent_child` | 2× | Parent-child palette linking (World Map, Inventory) |
| `oneshot_coldata_warm_flash` | 2× | One-shot warm color flash (Itory Cave, Prologue) |
| `thinkers_05FB16.thinker_def_05FB32` | 2× | Shared utility thinker (Dream, Mu Vampire Lair) |
| `mu_tint_and_wave` | 1× | Mu underwater tint + wave effect (all 7 Mu scenes share one block) |
| `watermia_festival_palette` | 1× | Watermia festival palette cycling (Watermia + Great Wall scenes) |
| `itory_village_fog` | 1× | Fog overlay effect (Itory Village, Moon Tribe) |
| `larai_cliff_scroll_wave` | 1× | Larai Cliff background scroll wave |
| `palace_coffin_hdma_table` | 1× | Seaside Palace coffin room perspective HDMA |
| `palace_fountain_palette` | 1× | Seaside Palace fountain animation palette |
| `palace_scroll_brightness` | 1× | Seaside Palace brightness scroll effect |
| `native_village_sine_hdma` | 1× | Native Village heat shimmer |
| `dao_sine_hdma_slow` | 1× | Dao desert heat shimmer |
| `dao_window_mask` | 1× | Dao window masking effect |
| `angel_tunnel_window_dma` | 1× | Angel Village tunnel window DMA |
| `babel_elevator_color_add` | 1× | Babel Tower elevator color addition |
| `dark_castoth_layer_config` | 1× | Dark Castoth boss rush layer config |
| `edward_castle_alarm_palette` | 1× | Edward Castle alarm state palette |
| `dream_palette_loop` | 1× | Will's Dream sequence palette loop |
| `flag_gated_palette_cool` | 1× | Flag-conditional cool palette (South Cape) |
| `flag_gated_palette_warm` | 1× | Flag-conditional warm palette (South Cape) |
| `oneshot_coldata_green_tint` | 1× | One-shot green color tint |
| `ending_comet_sine_hdma` | 1× | Ending comet sequence sine HDMA |

**System/menu thinkers:**

| Thinker | Uses | Purpose |
|---------|------|---------|
| `mode7_perspective.Mode7PerspectiveInit` | 1× | Mode 7 perspective for World Map |
| `inventory_dma_setup` | 1× | Inventory screen DMA initialization |
| `diary_menu_window_dma` | 1× | Diary menu window DMA setup |
| `boot_logo_palette_enix` | 1× | Enix boot logo palette |
| `boot_logo_palette_quintet` | 1× | Quintet boot logo palette |
| `boot_logo_palette_third` | 1× | Third-party boot logo palette |

**Comet finale thinkers (in-bank):**

| Thinker | Uses | Purpose |
|---------|------|---------|
| `sE7_thinker_0CEB5B` | 1× | Space Flight starfield scroll |
| `sE8_thinker_0CEB74` | 1× | Comet Lair PPU phase controller |
| `comet_lair_hdma_a` | 1× | Comet Lair HDMA channel A |
| `comet_lair_hdma_b` | 1× | Comet Lair HDMA channel B |
| `comet_lair_hdma_c_timed` | 1× | Comet Lair HDMA channel C (timed) |

**Credits/ending thinkers:**

| Thinker | Uses | Purpose |
|---------|------|---------|
| `crF7_proc_09F330` | 1× | Credits sequence procedure A |
| `crF7_proc_09F360` | 1× | Credits sequence procedure B |
| `crF7_proc_09F510` | 1× | Credits sequence procedure C |
| `thinkers_05FB16.crF7_thinker_05FB16` | 1× | Credits sequence thinker |

**Properties:**
- `order: -1` — build priority ordering
- Not marked `movable` (implicitly fixed — engine hardcodes the table address)

---

### 4.3 Space Flight Thinker — `sE7_thinker_0CEB5B` (25 bytes)

A thinker for the Space Flight scene (`$E7` — the pre-boss falling sequence).
Creates a continuous upward-scrolling starfield background.

**File:** `extracted/babel_tower/space_flight/sE7_thinker_0CEB5B.asm`

**Thinker params:** `#04, #08` (priority 4, param 8)

**Mechanism:**
- Entry/exit loop runs every frame
- Reads BG scroll register `$0720`, subtracts 8 (`ADC #$FFF8`), writes back
- Queues an HDMA transfer via `QueueHdma(@dma_channel_0CEB70, #0E)` —
  DMA channel definition `dma-channel < #20, #20, #07 >` targeting HDMA
  channel `$0E`
- Net effect: background scrolls upward 8 pixels per frame (480 px/sec),
  creating the rushing-stars-past effect during the falling sequence

**Properties:** `movable: true`, scene: `space_flight`

---

### 4.4 Comet Lair Thinker — `sE8_thinker_0CEB74` (241 bytes)

The Comet Lair's PPU configuration thinker manages screen rendering across
the boss fight's multiple phases. Contains **5 distinct configurations**, each
a self-contained code block that sets SNES PPU registers and loops until the
boss actor modifies flag byte `#FF` to trigger a phase transition.

The boss actor switches between phases by writing bank-local pointers into
the thinker's script pointer at `$0F00`.

**File:** `extracted/babel_tower/comet_lair/sE8_thinker_0CEB74.asm`

**Thinker params:** `#04, #08` (priority 4, param 8)

#### Phase Configurations

| Phase | Label | TM | TS | CGWSEL | CGADSUB | Extras | Visual Effect |
|-------|-------|----|----|--------|---------|--------|---------------|
| 0 (Initial) | `code_0CEB76` | `$16` BG2+BG3+OBJ | `$00` none | `$82` force-black-inside-window + fixed-color-sub | `$02` add BG2 | BG1SC=$10, BG2SC=$18 | Dark arena — no BG1, color math adds BG2 against fixed color |
| 1 (Boss Active) | `code_0CEBA1` | `$17` BG1+BG2+BG3+OBJ | `$02` BG2 | `$82` same | `$11` add BG1+OBJ | same | Full arena visible — BG1 revealed, BG2 on sub-screen, color math on BG1+OBJ |
| 2 (Transition) | `code_0CEBCC` | `$17` all | `$00` none | `$80` force-black-inside-window + sub=subScreen | `$80` subtract-mode only | same | Darkening — subtract mode with no sub-screen layers creates dimming |
| 3 (Window FX) | `code_0CEBF7` | `$17` all | `$00` none | `$22` prevent-math-inside-window + fixed-color-sub | `$03` add BG1+BG2 | WH0=$00, WH1=$00, WOBJSEL=$30, $7F0C02=$57 | Window masking — boss reveal/transformation with region-based color math |
| 4 (Victory) | `code_0CEC35` | `$17` all | `$00` none | `$80` force-black-inside-window | `$3F` add all 6 layers | WOBJSEL=$00 (clear) | Full brightness — all layers participate in color addition |

Each phase loops via `COP [BranchIfFlagByte] ( #FF, #00, &self )` — the
flag byte `#FF` is always `$00` during the loop, so the branch always fires
back to the start. When the boss changes this flag, the thinker falls through
the `RTL` and the boss writes a new phase address into the thinker slot.

**Properties:** `movable: false` (the boss writes `&`-prefixed bank-local
pointers to individual phase labels), scene: `comet_lair`

---

### 4.5 HDMA Brightness Ramp — `code_0CEC65` (231 bytes)

A spawned thinker that builds a per-scanline HDMA brightness gradient during
the Comet boss's eye beam attack. Creates a glowing intensity ramp effect
across the screen.

**File:** Part of `extracted/babel_tower/comet_lair/sE8_actor_0CEEAA.asm`

**Mechanism:**
1. Initializes `animScratch2 = 4` (scanline step), clears all scratch registers
2. Each frame: toggles between two WRAM buffers (`$7E7C00` and `$7E7E00`)
   via `animScratch` LSR parity (double-buffered to avoid tearing)
3. Builds HDMA table in 8-bit mode (`SEP #$20`, bank `$7E`):
   - Header: `$45` control + `$FF` initial value (3-byte entry)
   - Body: `$04` repeat × `animScratch2` entries with linearly
     decreasing/increasing brightness values derived from base `$857A`
   - Footer: `$01` terminator + `$FF` reset value
4. Queues the completed table via `QueueDma` to DMA channel `#26`
5. Increments scanline count (`animScratch2`) each frame; clamps at 36 (`$0024`)
6. After reaching 36 scanlines: increments `spritesetPtr` generation counter,
   clears flag byte `#02` (signals boss the effect is complete), resets
   `WH0 = $FF`, kills the thinker

The double-buffering is critical — one buffer is being displayed by HDMA while
the other is being built for the next frame.

**Properties:** Part of `sE8_actor_0CEEAA` block, `movable: false`

---

### 4.6 Space Flight Actor — `sE7_actor_0CEDC5` (350 bytes total)

The Space Flight actor controls scene `$E7` — the sequence where Shadow (Will in
Shadow form) falls through space before the final boss. Manages the player's
falling animation and spawns star particles streaming past.

**File:** `extracted/babel_tower/space_flight/sE7_actor_0CEDC5.asm`

#### Parts

| Part | Size | Type | Description |
|------|------|------|-------------|
| `code_0CED4C` | 121 | Code | Player falling script — injected into the player actor |
| `sE7_actor_0CEDC5` | 229 | actor-def | Star field controller — spawns star particles in a loop |

#### Star Field Controller (`sE7_actor_0CEDC5`)

**Actor-def params:** sprite `#00`, hitbox `#10`, variant `#29`

**Init sequence:**
1. `SpawnAfter(@code_0CEE9B)` — spawns a one-shot actor that sets `TM = $15`
   (BG1+BG3+OBJ, **disabling BG2**) and `TS = $00`. This strips the BG2
   layer to create the starfield-only background.
2. Forces `characterForm = 2` (Shadow transformation)
3. Hijacks player actor's script pointer to `code_0CED4C` (falling script).
   Uses `$&` (bank-local) + `$*` (bank byte) for the two-part long address.
4. Clears player wait timer (`$0008,Y = 0`)
5. Sets `playerFlags.$0800` (cutscene lock)

**Main loop (`SetEntryContinue`):**
- RNG byte AND 7 → `SwitchCase` with 8 entries mapping to 4 star types
  (each type has 2 slots = 25% weight):
  - `code_0CEE0E` → spawns `code_0CEE3E` (sprite `#00`)
  - `code_0CEE17` → spawns `code_0CEE43` (sprite `#01`)
  - `code_0CEE20` → spawns `code_0CEE48` (sprite `#02`)
  - `code_0CEE29` → spawns `code_0CEE4D` (sprite `#03`)
- After spawning, sets wait timer: `$08 = (RNG & 7) + 16` (16–23 frames
  between star spawns)
- All star spawns use flags `$0902`

**Star particle behavior** (shared via `loc_0CEE50`):
- Sets `$0080` priority, `$0030` on `$12`
- RNG assigns X position (`$14`)
- **Center-gap filter** creates a tunnel effect:
  - X < `$6A` (106): star falls normally
  - `$6A` ≤ X < `$8A` (106–137): star immediately **dies** (32-pixel dead zone)
  - X ≥ `$8A` (138): star falls normally
- Falling stars: Y starts at `$FFC0` (−64, above screen), no horizontal
  velocity (`moveXAlt = 0`). Vertical speed alternates between 11 and 9
  based on frame counter `$0410` parity (creates subtle parallax depth).
- Movement loop: `ReloadForceMove` + `StageSpriteFrame(#FF)` + `AnimOnce`
  until Y ≥ `$0180` (384, well below screen), then `Die`

The center gap means stars only appear on the left and right edges of the
screen, creating the visual impression of falling through a narrow tunnel
or shaft in space.

#### Player Falling Script (`code_0CED4C`)

Injected into the player actor by the star field controller:

1. **Setup:** Clears `$0008` on `$10` (disable player attack), stages player
   sprite `#1B`, sets `$0E |= $8000` (vertical flip). Positions at
   X=`$7A` (122), Y=`$BB` (187). Sets 900-frame countdown (`$26 = $0384`).

2. **Idle phase (900 frames):** Each frame: `AnimOneFrame`, waits for `$2A`
   (sync event) to become nonzero. When triggered, stores `$08` as sub-timer
   in `$24`, clears `$08`. Inner loop: `SetEntryExit` decrements both `$26`
   (master timer) and `$24` (sub-timer). When sub-timer expires, returns to
   AnimOneFrame wait. When master timer expires (900 frames elapsed), enters
   descent.

3. **Descent phase:** `StagePlayerMoveY(#1B, #08)` — moves downward at speed 8.
   Spawns trail sparkle effects (`code_0CEDAB` with flags `$0300`) each frame.
   Trail effect: sets metasprite from `table_0EE000`, applies RNG X offset
   (±8 pixels from player), plays frame `#02`, dies. Loop continues until Y
   wraps negative and |Y| ≥ `$0030` (48), at which point:

4. **Transition:** `QueueMapChange(#E8, ...)` — loads scene `$E8` (Comet —
   Final Lair) with transition params `#80, $2100`.

**Properties:** `movable: true`, scene: `space_flight`

---

### 4.7 Dark Gaia — Final Boss (`sE8_actor_0CEEAA`, 2,140 bytes total)

The **Dark Gaia** boss is the game's final battle, fought in scene `$E8`
(Comet — Final Lair). This is a two-phase boss with a dramatic mid-fight
transformation sequence. It is the largest code block in bank 0C.

**File:** `extracted/babel_tower/comet_lair/sE8_actor_0CEEAA.asm`

**Actor-def params:** sprite `#00`, hitbox `#00`, variant `#21`

**Dependencies:** `enemy_stats_table`, `func_0AA36E`, `oneshot_palette_flash_18`,
`oneshot_palette_flash_19`, `player_character`, `sE8_thinker_0CEB74`,
`smooth_follow`, `table_0EE000`

#### Sub-actor Inventory

| Code Label | Flags | Role |
|------------|-------|------|
| `code_0CED37` | — | Palette start #7D (intro) |
| `code_0CED3E` | — | Palette start #7F (phase transition) |
| `code_0CED45` | `$2000` | Palette start #69 (eye beam glow) |
| `code_0CEC65` | thinker | HDMA brightness ramp (§4.5) |
| `code_0CEE9B` | — | TM config helper (space flight only) |
| `code_0CEF6D` | `$2000` | TM flash — toggles BG1 on/off 16× |
| `code_0CF1CE` | `$0300` | Death decoration at (96, 440) — loop frame #08 |
| `code_0CF1DF` | `$0300` | Death decoration at (177, 440) — loop frame #08 |
| `code_0CF1F0` | `$0300` | Death decoration at (180, 416) — loop frame #09 |
| `code_0CF201` | `$2300` | Debris spawner — 12 cycles of paired explosions |
| `code_0CF22F` | `$0302` | Debris type A — sound #06, RNG position, frame #07 |
| `code_0CF23C` | `$0302` | Debris type B — sound #06, RNG position, frame #01 |
| `code_0CF266` | `$2200` | Destructible weak point during eye beam |
| `code_0CF291` | `$2800` | Falling debris shower — 30 cycles of 3 types |
| `code_0CF2BB` | `$0B00` | Falling debris type A — sprite #1B, speed (0,6) |
| `code_0CF2C8` | `$0B00` | Falling debris type B — sprite #1C, speed (0,6) |
| `code_0CF2D5` | `$0B00` | Falling debris type C — sprite #1D, speed (0,8) |
| `code_0CF2F2` | `$0301` | Left tentacle — enters from (49, 407) |
| `code_0CF31F` | `$0301` | Right tentacle — enters from (207, 407), HFlip |
| `code_0CF3EF` | `$0301` | Tentacle intro splash — frame #08, die |
| `code_0CF3FC` | `$2200` | Left floating spawner at X=24 |
| `code_0CF403` | `$2200` | Right floating spawner at X=232 |
| `code_0CF429` | `$0200` | Spawned homing sub-entity |
| `code_0CF4E3` | `$0301` | Arena decoration (eye/face) with 2 children |
| `code_0CF543` | `$0301` | Arena child: sprite+hitbox #0C, timed |
| `code_0CF549` | `$0301` | Arena child: frame #0C, infinite loop |
| `code_0CF550` | `$0301` | Eye beam telegraph + fire |
| `code_0CF570` | `$0202` | Downward beam projectile |
| `code_0CF5AF` | `$0202` | Rising spread projectile |
| `func_0AA36E` | `$2000` | Boss kill invulnerability flash (cross-bank) |

#### Phase 1 — Initial Form

**Arena Setup (`code_0CEEAD`):**
- Sets `$0010` on `$12` (enemy flag)
- Zeroes all camera target/delta registers for fixed-screen boss arena
- Positions boss at (129, 234)
- Hijacks player actor script to `loc_0CF5EF` (player arena entry — falls from
  above at X=136, Y=−64, descends at speed 7 until Y ≥ 224, landing sound
  `#2C`, re-enables attack, returns to `PlayerIdleEntry`)
- Sets `playerFlags.$0800` (cutscene lock), waits for player to land
- Spawns palette transition (palette `#7D`)
- Switches thinker to Phase 1 (`code_0CEBA1`)
- Starts boss music (`#10`)
- Sets death callback → `code_0CEF88` (phase transition)
- Waits 254 frames (`WaitByte(#FE)`)
- Displays opening frame `#1F`

**Combat Loop (`loc_0CEF11`):**
1. Sets hit callback → `code_0CEF3C`
2. Clears invulnerability (`$2000` off `$10`) — boss is hittable
3. Spawns eye beam attack (`code_0CF550` at relative (0,0), flags `$0301`)
4. Stores beam actor handle in `$24`
5. Sets 100-frame timer (`$26 = $0064`)
6. Per-frame: decrements timer. At expiry: re-enables invulnerability (`$2000`)
7. `WaitWord($01DF)` — waits for attack cooldown condition
8. Loops back to step 1

**Eye Beam Attack (`code_0CF550`):**
- 3-frame telegraph: sprite `#0D` → `#0E` → fires
- Spawns downward beam projectile (`code_0CF570`, flags `$0202`)
- Shows frame `#0F`, then clears parent's `$24` reference, dies

**Downward Beam (`code_0CF570`):**
- Frame `#14`, sound `#1D`
- Descends via `StageSpriteMoveY(#15, #0C)` at speed 12
- Checks flag byte `#03` each frame (boss dead → die immediately)
- Falls until Y wraps negative and |Y| ≥ 48 (off-screen bottom)
- On reaching bottom: sets `$2000` on `$10`, spawns **14 rising spread
  projectiles** (`code_0CF5AF`, flags `$0202`) at 14-frame intervals

**Rising Spread Projectiles (`code_0CF5AF`):**
- Check flag byte `#03` → die if boss defeated
- Sound `#23`, RNG X position
- Two speed variants (50/50 RNG): `StageSpriteMoveY(#16, #09)` (speed 9)
  or `StageSpriteMoveY(#16, #0D)` (speed 13)
- Rise upward until Y wraps and reaches `$0120` (288), then die
- Creates a curtain of projectiles rising from the bottom of the screen

**Hit Response (`code_0CEF3C`):**
- Immediately enables invulnerability (`$2000`)
- Spawns TM flash effect (`code_0CEF6D` — toggles `TM` between `$16` and
  `$17` for 16 frames, rapidly enabling/disabling BG1 for screen flicker)
- If eye beam exists (`$24 ≠ 0`): flags it with `$2000` (disable)
- 16-frame invuln period with alternating beam enable/disable
- Returns to `WaitWord` → next attack cycle

#### Phase Transition (First Death → Second Form)

Triggered when Phase 1 HP depletes (death callback `code_0CEF88`):

1. Sets flag byte `#03` (terminates all active projectiles)
2. Clears hit/death callbacks, sets `$2300` on `$10` (invuln + hidden)
3. Disables eye beam if active
4. Spawns palette transition (palette `#7F`)
5. Waits 59 frames, switches thinker to **Phase 0** (`code_0CEB76` — dark arena)
6. Spawns palette flash (`oneshot_palette_flash_18`)
7. Waits 119 frames
8. Loads second form stats from `enemy_stats_table+154`
9. Restores actor flags `$0301` on `$10`, `$1000` on `$12`
10. Sets `displayModeFlags.$0080`

**Camera reveal (128 frames):**
- Locks player input, disables player attack (`$0010,Y AND $FFF7`)
- 128 iterations: advances `cameraTargetY` by 2, traverses the actor linked
  list — all actors with `$0400` flag get Y position shifted up by 2
- Net effect: smooth 256-pixel upward camera pan revealing the boss's full form

**Post-reveal setup:**
- Palette flash (`oneshot_palette_flash_19`)
- Switches thinker to **Phase 1** (`code_0CEBA1` — full arena visible)
- Sets flag byte `#01`
- Re-enables player attack
- Waits 99 frames
- Switches thinker to **Phase 3** (`code_0CEBF7` — window effects)
- Waits 99 more frames
- Clears `displayModeFlags.$0080`
- Applies BG change `#9D`
- Spawns arena decoration (`code_0CF4E3`) — the boss's eye/face visual element
  at (128, 426) with 2 child actors at relative (-4,-4) and (4,0)
- Spawns two floating spawners (`code_0CF3FC` at X=24, `code_0CF403` at X=232)
  with flags `$2200`
- Repositions boss to (128, 336)
- Enters second form AI

#### Phase 2 — True Form

**AI Loop (`code_0CF08F`):**
- `SetDeathCallback(@code_0CF154)` (final death)
- Per-frame: checks `orbitDiameter`:
  - If ≥ 0: decrements (cooldown timer), performs tentacle spawn attack with A=0
  - If < 0 (no cooldown): RNG picks attack from 8 slots:
    - 25% (slots 0–1): **Tentacle spawn attack** (`code_0CF13B`)
    - 75% (slots 2–7): **Eye beam attack** (`code_0CF0C0`)

**Eye Beam Attack — Phase 2 (`code_0CF0C0`):**
- Sets `orbitDiameter = 3` (3-frame cooldown before next RNG roll)
- Redirects arena decoration to `loc_0CF51E` (eye opens — children get `$2000`)
- Clears `$0200`, windup frame `#17`
- Re-enables `$0200`
- Writes `$57` to `$7F0C02` (HDMA parameter)
- Spawns HDMA brightness ramp thinker (`code_0CEC65`)
- Sets flag byte `#02` (HDMA active signal)
- Spawns eye beam glow palette (`code_0CED45`, palette `#69`)
- Sound `#20`
- Spawns destructible weak point (`code_0CF266`, flags `$2200`): positioned at
  (128, 480) with stats from `enemy_stats_table+160`, becomes hittable after
  9 frames, plays 10-frame animation `#1F`, then dies
- Loops frame `#1A` until flag byte `#02` is cleared (HDMA ramp complete)
- Recovery: `WH0 = $FF`, recovery animation (frame `#06` × 60 loops), frame `#18`
- Redirects arena decoration to `loc_0CF4FF` (eye closes — children clear `$2000`)
- Returns to AI loop

**Tentacle Spawn Attack (`code_0CF13B`):**
- Spawns two tentacles simultaneously:
  - **Left** (`code_0CF2F2`): enters at (49, 407), rises to (16, 336), frame `#09`→`#0A`
  - **Right** (`code_0CF31F`): enters at (207, 407) with HFlip, rises to (240, 336)
- Both pass different `$26` parameters (4 vs 12) affecting homing behavior
- Shared tentacle AI (`code_0CF353`):
  - Sound `#20`, sets enemy+priority flags
  - Loads `enemy_stats_table+158`
  - Spawns `smooth_follow.CopySiblingFollowState` for player-tracking homing
  - Sets `chatPtr = $800B`, `loopCounter = 3`
  - Links child to player actor for target tracking
  - 5-frame attack animation loop
  - After homing: copies movement data, kills follower, enters position
    maintenance loop until `$4000` flag (wall collision) → dies
- Waits 299 frames (`WaitWord($012B)`), then loops back with fresh death callback

**Floating Spawners (`code_0CF3FC` / `code_0CF403`):**
- Positioned at X=24 and X=232, Y=472 (below visible arena)
- Infinite loop: RNG delay (120–183 frames), check flag byte `#04` (boss dead → die)
- Each cycle spawns a homing sub-entity (`code_0CF429`):
  - Sets `$0080` priority, `$00A0` on `$12`
  - Approach animation `#11` × 2 loops → frame `#12`
  - Loads `enemy_stats_table+15C`, sound `#1D`
  - Sets death callback (`code_0CF4D9` — plays sound `#1B`)
  - Clears `$0200` (becomes hittable)
  - Two-stage descent: `StageSpriteMoveY(#13, #0A)` then `StageSpriteMoveY(#13, #2A)`
  - Clears own HP to 0, sets return pointer to `loc_0CF47E`
  - **Tracking phase** (`loc_0CF47E`): 5 iterations (`loopCounter = 5`), each:
    - Check flag byte `#04` → retreat if boss dead
    - Compute target: player X ± RNG 63, clamped to [0, 264]; player Y ± RNG 63
      (using `$0411`), clamped to [256, 488]
    - `MoveToward(#13, #02)` at speed 2 toward computed point
    - If `$4000` flag (wall collision) → die
    - 1-frame attack loop, then next iteration
  - After 5 iterations: clears death callback (becomes unkillable?)

**Arena Decoration (`code_0CF4E3`):**
- Positions at (128, 426) — the boss's central eye/face
- Spawns 2 children: `code_0CF549` at relative (-4,-4) loops frame `#0C`
  forever, `code_0CF543` at relative (4,0) sets sprite+hitbox `#0C` then waits
- Two states controlled by boss:
  - **Eye closed** (`loc_0CF4FF`): clears `$2000` on both children, loops frame `#00`
  - **Eye open** (`loc_0CF51E`): frame `#01`, sets `$2000` on both children (hidden),
    frame `#02`, `SetEntryContinue` loop

#### Final Death Sequence (`code_0CF154`)

1. Sets flag byte `#04` (signals all sub-actors: spawners, tentacles, homing entities)
2. Masks joypad (`$FFF0` → full input lock)
3. Spawns `func_0AA36E` (boss kill invulnerability flash)
4. Spawns explosion debris controller (`code_0CF201`) at relative (0, −32):
   at position (128, 368), uses `table_0EE000` metasprites, 12 cycles each
   spawning paired debris sprites (`code_0CF22F` type A + `code_0CF23C` type B)
   at random offsets (X ±31, Y ±63) from center, sound `#06` each
5. Spawns 3 persistent visual decorations:
   - `code_0CF1CE` at (96, 440) — infinite loop frame `#08`
   - `code_0CF1DF` at (177, 440) — infinite loop frame `#08`
   - `code_0CF1F0` at (180, 416) — infinite loop frame `#09`
6. Spawns falling debris shower (`code_0CF291`): starts at Y=544, 30 cycles
   of 3 debris types (sprites `#1B`, `#1C`, `#1D` at speeds (0,6), (0,6), (0,8)),
   RNG X positions, fall until Y < 224 then die. 14 frames between each spawn.
7. Boss death animation: frame `#19` → `#1E`
8. Switches thinker to **Phase 4** (`code_0CEC35` — full brightness)
9. Palette flash (`oneshot_palette_flash_18`)
10. Waits 299 frames
11. Sets `gfxCacheIdxB = $0404`
12. `QueueMapChange(#E5)` — transitions to Ending — Comet scene
    with params `#00, $1100`
13. Sets `$0800` on `$10`, waits 1 frame
14. Resets `characterForm = 0` (back to Will form)
15. Returns

**Properties:** `movable: false` (writes bank-local pointers to thinker phases),
scene: `comet_lair`

---

### 4.8 Unused Actor Stub — `actor_0CF61F` (4 bytes)

A minimal dead actor definition containing only an `RTL` instruction.

**File:** `extracted/unused/actor_0CF61F.asm`

**Actor-def params:** sprite `#00`, hitbox `#00`, variant `#20`

**Body:** `RTL` — immediately returns, doing nothing.

No references found in the scene actor table or any other code. Likely a
development leftover, early placeholder, or artifact from a removed feature.

**Properties:** `movable: true`, group: `unused`

---

## 5. Observations

### 5.1 Bank Architecture — Data-Dominant

Unlike most other documented banks (which contain code-heavy actor definitions),
bank `$0C` is **~84% pure data tables**. The two spawn tables together consume
27,483 bytes — structured pointer arrays and spawn records rather than
executable code. This makes the bank critical infrastructure: every scene load
in the game reads from these tables.

### 5.2 Scene Actor Table as Central Registry

The `scene_actors` table is the single point of truth for actor placement
across the entire game. It references 594 unique actor definitions across
all banks, making it the most interconnected structure in the codebase. Any
change to actor placement, NPC positioning, enemy spawn locations, or puzzle
element layout must go through this table.

Key structural patterns:
- **Player + Camera are near-universal**: 224 of 241 unique scenes include the
  player character; 220 include the camera controller
- **16 blank-template scenes** share a single 3-actor event block, suggesting
  unused or placeholder scene slots
- **Scene $00 is truly empty** (0 actors) — a null scene used as a default
- **Euro Rolek Market** ($91) is the most densely populated scene at 58 actors
- The table is marked `movable: true` and `postProcess: "Extract(1)"`,
  meaning the engine can relocate it and post-processes its sub-structures

### 5.3 Scene Thinker Table — Visual Identity per Scene

The thinker table gives each area its visual identity. The 70 unique
thinker_spawn blocks map to 46 distinct thinker definitions. Two thinkers
dominate: `global_ambient_dispatcher` (59 scenes) and `ambient_palette_cycler`
(59 scenes with 90+ individual palette entries) provide the baseline lighting
and animation for nearly every scene.

Area-specific thinkers create the game's distinctive visual moods:
- **Mu** scenes all share `mu_tint_and_wave` for the underwater tint
- **Seaside Palace** has dedicated coffin HDMA, fountain palette, and
  brightness scroll thinkers
- **Great Wall/Watermia** share `watermia_festival_palette`
- **Comet Lair** has the most complex setup: 6 thinkers including the
  5-phase PPU controller and 3 HDMA channels

### 5.4 Comet Finale — Self-Contained Boss Arena

The 4 Comet-related blocks (2,525 bytes total) form a tightly coupled,
self-contained boss encounter. The actor and thinker work together through
a flag-byte protocol and direct script pointer manipulation:

| Component | Block | Role | Communication |
|-----------|-------|------|---------------|
| Starfield scroll | `sE7_thinker_0CEB5B` | Background scrolling | Independent |
| PPU phase control | `sE8_thinker_0CEB74` | 5 rendering configs | Flag byte `#FF` gates loops; boss writes `&`-pointers to `$0F00` |
| HDMA ramp | `code_0CEC65` | Eye beam brightness | Flag byte `#02`: boss sets, thinker clears when done |
| Pre-boss sequence | `sE7_actor_0CEDC5` | Falling + stars | Hijacks player script, `QueueMapChange` to `$E8` |
| Boss AI | `sE8_actor_0CEEAA` | Full Dark Gaia fight | Orchestrates all other components |

The boss has **two distinct phases** with 5 thinker-driven PPU transitions:

```
Phase 0 (dark arena) → Phase 1 (boss active) → [combat] →
  Phase 0 (darken) → [camera reveal] → Phase 1 (full arena) →
  Phase 3 (window effects) → [setup] → [Phase 2 combat] →
  Phase 4 (victory brightness)
```

### 5.5 Boss Attack Pattern Summary

| Phase | Attack | Frequency | Mechanism |
|-------|--------|-----------|-----------|
| 1 | Eye beam | Every cycle | Vertical bolt → 14 rising spread projectiles |
| 2 | Eye beam | 75% per roll | HDMA ramp, destructible weak point, palette glow |
| 2 | Tentacle pair | 25% per roll + cooldown | Homing via `smooth_follow`, 299-frame window |
| 2 | Floating spawners | Continuous | RNG-timed homing sub-entities from arena edges |

### 5.6 Immovable Blocks

Two Comet blocks (`sE8_thinker_0CEB74` and `sE8_actor_0CEEAA`) are marked
`movable: false`. The boss actor directly writes bank-local `&`-prefixed
pointers into the thinker actor's script slot (`LDA #$&code_0CEBA1; STA $0000,Y`).
If either block were relocated, these pointers would break. This is a necessary
coupling for the multi-phase PPU control system.

### 5.7 Unmapped Tail

The 2,525-byte tail (`$0CF623`–`$0CFFFF`) is unmapped in `blocks.json` with
no named addresses and no overrides. It likely contains padding/fill bytes.

### 5.8 Cross-Bank References

The Comet boss references shared code from other banks:

| Reference | Bank | Purpose |
|-----------|------|---------|
| `func_0AA36E` | `$0A` | Boss kill invulnerability flash |
| `enemy_stats_table` (+154, +158, +15C, +160) | `$00` | HP/stats for boss forms and sub-entities |
| `smooth_follow.CopySiblingFollowState` | `$01` | Homing tentacle behavior |
| `table_0EE000` | `$0E` | Metasprite frame definitions |
| `player_character.PlayerIdleEntry` | `$01` | Return control to player |
| `oneshot_palette_flash_18` / `_19` | `$00` | One-shot palette flash effects |
