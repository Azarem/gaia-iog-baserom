# Bank 01 — Data Tables Reference

**ROM Range:** `$01:8000`–`$01:FF6C` (offsets `$18000`–`$1FF6C`, 32,108 bytes mapped)  
**CPU Address:** `$C1:8000`–`$C1:FF6C` (HiROM), mirrored at `$01:8000`–`$01:FFFF`  
**Content:** Pure data — no executable code. Contains all major engine lookup tables, game strings, enemy/scene metadata, and math tables.

> Bank 01's lower half (`$01:0000`–`$01:7FFF`) is not ROM in HiROM mapping — it mirrors hardware registers and WRAM. All ROM data in this bank begins at `$18000`.

---

## Table of Contents

| # | Block | Address | Size | Type | Purpose |
|---|-------|---------|------|------|---------|
| 1 | [display_preset_table](#1-display_preset_table) | `$18000`–`$18234` | 564 B | `&display-preset` | Scene display/graphics mode presets |
| 2 | [scene_warps](#2-scene_warps) | `$18234`–`$1A95E` | 10,026 B | `&warp-def` | All scene warp/transition definitions |
| 3 | [forced_walk_sequence_table](#3-forced_walk_sequence_table) | `$1A95E`–`$1AADE` | 384 B | `&Binary` | Forced-walk animation frame sequences |
| 4 | [enemy_clear_reward_table](#4-enemy_clear_reward_table) | `$1AADE`–`$1ABDE` | 256 B | `Byte` | Per-scene enemy clear rewards |
| 5 | [direction_velocity_table](#5-direction_velocity_table) | `$1ABDE`–`$1ABF0` | 18 B | `direction-velocity` | Direction→sprite/velocity mapping |
| 6 | [enemy_stats_table](#6-enemy_stats_table) | `$1ABF0`–`$1ADA8` | 440 B | `enemy-stats` | Enemy HP/ATK/DEF/type stats |
| 7 | [scene_barrier_chest_table](#7-scene_barrier_chest_table) | `$1ADA8`–`$1B086` | 734 B | `&Binary` | Per-scene barrier/chest placement data |
| 8 | [movement_delta_table](#8-movement_delta_table) | `$1B086`–`$1C384` | 4,862 B | `&delta-node` | Pre-computed movement delta curves |
| 9 | [trig_and_level_tables](#9-trig_and_level_tables) | `$1C384`–`$1CA95` | 1,809 B | Mixed | Sine/cosine LUTs and level-up table |
| 10 | [dialog_template_table](#10-dialog_template_table) | `$1CA95`–`$1CBA6` | 273 B | `&DialogString` | Dialog box/screen-effect templates |
| 11 | [music_pointer_array](#11-music_pointer_array) | `$1CBA6`–`$1CC00` | 90 B | `@Binary` | Scene→BGM music data pointers |
| 12 | [parallax_scroll_table](#12-parallax_scroll_table) | `$1CC00`–`$1D3CE` | 1,998 B | `&Binary` | Per-scene parallax/HDMA scroll configs |
| 13 | [event_block_table](#13-event_block_table) | `$1D3CE`–`$1D8BE` | 1,264 B | `event-block-def` | Event block tile copy definitions |
| 14 | [hdma_and_ramp_tables](#14-hdma_and_ramp_tables) | `$1D8BE`–`$1D971` | 179 B | Mixed | HDMA channel config + ramp motion curves |
| 15 | [body_table](#15-body_table) | `$1D971`–`$1D9A7` | 54 B | `body-entry` | Player form spriteset/tileset pointers |
| 16 | [will_ability_anim_table](#16-will_ability_anim_table) | `$1D9A7`–`$1D9BF` | 24 B | `&Binary` | Will's attack ability animation configs |
| 17 | [freedan_ability_anim_table](#17-freedan_ability_anim_table) | `$1D9BF`–`$1D9D8` | 25 B | `&Binary` | Freedan's attack ability animation configs |
| 18 | [system_strings](#18-system_strings) | `$1D9D8`–`$1EB0F` | 4,407 B | `ConsoleString` | All UI/menu/item/ability text strings |
| 19 | [item_component_table](#19-item_component_table) | `$1EB0F`–`$1EBA8` | 153 B | `&ConsoleString` | Item name prefix components for composition |
| 20 | [dictionary_a](#20-dictionary_a) | `$1EBA8`–`$1F54D` | 2,469 B | `&DialogString` | Dialog text dictionary (common words) |
| 21 | [dictionary_b](#21-dictionary_b) | `$1F54D`–`$1FD24` | 2,007 B | `&DialogString` | Dialog text dictionary (extended words) |
| 22 | [item_get_dialog_table](#22-item_get_dialog_table) | `$1FD24`–`$1FF6C` | 584 B | `&DialogString` | Item acquisition dialog messages |

**Unmapped tail:** `$1FF6C`–`$20000` (148 bytes) — likely padding/unused.

---

## Detailed Analysis

### 1. display_preset_table

**Current name:** `table_018000`  
**Proposed name:** `display_preset_table`  
**Address:** `$18000`–`$18234` (564 bytes)  
**Type:** Pointer table → `display-preset` structs  
**Category:** `tables`

**Description:**  
Index table of 47 (`$00`–`$2E`) display preset configurations. Each preset is a 10-byte `display-preset` struct that defines the SNES PPU display parameters for a scene. These presets are selected when loading a new scene and configure:

| Byte | Purpose |
|------|---------|
| 0 | BG mode and tile size flags |
| 1 | Tilemap base addresses (BG12NBA / BG34NBA) |
| 2 | BG screen base addresses |
| 3 | Layer visibility / main screen designation |
| 4–5 | Color math and window mask settings |
| 6 | HDMA/scroll configuration |
| 7 | Special flags (parallax mode, transparency) |
| 8–9 | Reserved / padding |

**Usage:** The scene loader reads the display preset index from scene metadata and configures all PPU registers accordingly. Every game area references one of these presets.

---

### 2. scene_warps

**Current name:** `scene_warps`  
**Proposed name:** `scene_warps` *(already well-named)*  
**Address:** `$18234`–`$1A95E` (10,026 bytes)  
**Type:** Pointer table → `warp-def` arrays  
**Category:** `tables`

**Description:**  
The master warp definition table — one of the largest structures in bank 1. Indexed by scene ID, each entry is a pointer to a variable-length list of `warp-def` entries for that scene. Each `warp-def` contains two sub-structures:

- **`scene-warp`**: Door/entrance warps — rectangle trigger area (X, Y, width, height), destination scene ID, destination coordinates, and facing direction.
- **`stair-warp`**: Staircase warps — similar structure but with stair-specific coordinate offsets for the climb animation.

Both sub-types use `$FF` as a list terminator. The engine's `warps_interaction` system checks player position against these rectangles each frame and triggers transitions when the player enters a warp zone.

**Usage:** Referenced by `warps_interaction.asm` during scene transitions. Scene index `$0646` selects the warp list.

---

### 3. forced_walk_sequence_table

**Current name:** `table_01A95E`  
**Proposed name:** `forced_walk_sequence_table`  
**Address:** `$1A95E`–`$1AADE` (384 bytes)  
**Type:** Pointer table → binary sequences  
**Category:** `tables`

**Description:**  
Table of 16 (`$00`–`$0F`) pointers to forced-walk animation frame sequences. Each sequence is a stream of paired bytes encoding sprite frame indices and movement step sizes, terminated by `$00,$00`. These define the step patterns for cutscene character movement (e.g., NPCs walking on scripted paths, the player being moved during events).

The byte-pair format appears to encode: `<sprite_frame_index>, <step_delta>` where the frame index selects the walking animation frame and the delta controls movement speed per tick.

**Usage:** Referenced by `forced_walk.asm` — the engine's forced movement system that overrides player input during scripted sequences. Indexed by direction to select the appropriate walk cycle.

---

### 4. enemy_clear_reward_table

**Current name:** `enemy_clear_reward_table`  
**Proposed name:** `enemy_clear_reward_table` *(already well-named)*  
**Address:** `$1AADE`–`$1ABDE` (256 bytes)  
**Type:** Byte array (256 entries, one per scene)  
**Category:** `tables`

**Description:**  
Maps each scene ID (`$00`–`$FF`) to its enemy-clear reward tier:
- `$00` = No reward (non-combat scenes, towns, overworld)
- `$01` = Tier 1 reward (minor stat boost)
- `$02` = Tier 2 reward (medium stat boost)
- `$03` = Tier 3 reward (major stat boost / rare item)

When all enemies in a Dark Space dungeon room are defeated, the game checks this table to determine what reward the player receives. The reward system is central to IOG's stat progression — defeating all enemies in a room grants permanent stat increases (HP, STR, DEF) or items.

**Usage:**
- `StandardEnemyDefeatHandler.asm` — checks reward on last enemy kill
- `field_reveal_object.asm` — reveals reward object after clear
- `radar_map_screen.asm` — draws chest icon on radar for scenes with rewards

---

### 5. direction_velocity_table

**Current name:** `dir_sprite_01ABDE`  
**Proposed name:** `direction_velocity_table`  
**Address:** `$1ABDE`–`$1ABF0` (18 bytes)  
**Type:** `direction-velocity` array (9 entries)  
**Category:** `tables`

**Description:**  
Maps cardinal/diagonal directions to sprite frame and velocity parameters. Each `direction-velocity` entry is 2 bytes:

| Index | Direction | Sprite | Velocity |
|-------|-----------|--------|----------|
| 0 | South | `$09` | `$12` |
| 1 | North | `$08` | `$11` |
| 2 | East | `$09` | `$14` |
| 3 | West | `$08` | `$11` |
| 4 | SE | `$09` | `$14` |
| 5 | SW | `$09` | `$12` |
| 6 | Idle A | `$02` | `$00` |
| 7 | Idle B | `$03` | `$00` |
| 8 | NE/NW | `$08` | `$13` |

The sprite value selects the base animation frame for that direction. The velocity byte controls movement speed.

**Usage:**
- `actor_execution.asm` — reads direction sprite for actor facing
- `forced_walk.asm` — gets velocity for forced movement in each direction

---

### 6. enemy_stats_table

**Current name:** `stats_01ABF0`  
**Proposed name:** `enemy_stats_table`  
**Address:** `$1ABF0`–`$1ADA8` (440 bytes)  
**Type:** `enemy-stats` array (110 entries)  
**Category:** `tables`

**Description:**  
Master enemy stat table. Each entry is a 4-byte `enemy-stats` struct indexed by enemy type ID:

| Byte | Field | Description |
|------|-------|-------------|
| 0 | HP | Hit points (0 = invulnerable/non-combat, `$7F`/`$FF` = boss-tier) |
| 1 | ATK | Attack power |
| 2 | DEF | Defense value (`$7F` = immune to normal damage, `$FF` = special) |
| 3 | Type | Enemy type/element (0–3, affects damage calculations) |

Notable entries:
- Index `$00` = null/placeholder (`0,0,0,0`)
- Index `$06` = invincible object (`$7F,0,0,0`)
- Indices `$14`, `$27`, `$2F`, `$30`, `$31`, `$36` = boss stats (high HP, `$7F` DEF = immune phases)
- Indices `$50`–`$5E` = late-game bosses (HP `$28`, DEF `$7F`)

**Usage:** Actors load enemy stats by their type ID. The combat system reads HP, ATK, DEF from this table to calculate damage. Boss actors often reference specific offsets directly (e.g., the Sand Fanger at `$1ABF0+154`).

---

### 7. scene_barrier_chest_table

**Current name:** `table_01ADA8`  
**Proposed name:** `scene_barrier_chest_table`  
**Address:** `$1ADA8`–`$1B086` (734 bytes)  
**Type:** Pointer table → per-scene binary data  
**Category:** `tables`

**Description:**  
Per-scene table of barrier tile and treasure chest placement data, indexed by scene ID. Each scene's entry is a variable-length list of 4-byte records:

| Byte | Field | Description |
|------|-------|-------------|
| 0 | X tile | Tile X coordinate of the barrier/chest |
| 1 | Y tile | Tile Y coordinate |
| 2 | Content | Item ID for chests, or tile index for barriers |
| 3 | Flags | Event flag ID (bit 7 = end-of-list sentinel) |

Most scenes point to `binary_01AFA6` (`$FF` = no barriers/chests). Non-trivial entries define the placement of:
- **Barrier tiles:** 2×2 tile blocks placed on the map when an event flag is set, blocking paths until cleared
- **Treasure chests:** Searchable tiles that yield items when the event flag is not yet set

**Usage:**
- `warps_interaction.asm` — `PlaceBarrierTiles` walks entries to place blocking tiles
- `warps_interaction.asm` — chest interaction searches entries by player position
- `radar_map_screen.asm` — reads scene entries to draw transition markers on the world map radar

---

### 8. movement_delta_table

**Current name:** `table_01B086`  
**Proposed name:** `movement_delta_table`  
**Address:** `$1B086`–`$1C384` (4,862 bytes)  
**Type:** Pointer table → `delta-node` linked lists  
**Category:** `tables`

**Description:**  
The largest table in bank 1. Contains 85 (`$00`–`$54`) pointers to pre-computed movement delta sequences used for smooth character/camera motion. Each `delta-node` is a 4-byte struct:

```
delta-node { Word value, &delta-node next }
```

- `value` = signed 16-bit movement delta for one axis per frame
- `next` = pointer to the next delta-node (self-referencing = hold constant)

These linked lists define velocity curves — acceleration ramps, arc trajectories, deceleration, and linear motion patterns. Simple entries (indices `$00`–`$11`) are single-node constants (zero velocity, fixed speeds). Complex entries (indices `$12`+) are multi-node sequences that trace curves over time.

**Usage:**
- `WorldMapController.asm` — world map movement uses X/Y/Z delta sources from this table to animate travel between nodes
- `forced_walk.asm` and `hit_stagger` systems — character knockback and scripted movement use pre-baked delta curves
- Camera scrolling systems — smooth camera tracking via delta sequences

---

### 9. trig_and_level_tables

**Current name:** `scene_flag_table`  
**Proposed name:** `trig_and_level_tables`  
**Address:** `$1C384`–`$1CA95` (1,809 bytes)  
**Category:** `system`

A composite block containing six related sub-tables for math and progression:

#### 9a. level_experience_table
**Part:** `scene_flag_table`  
**Address:** `$1C384`–`$1C455` (209 bytes, `$D1` entries)  
**Type:** `Byte` array

Experience level thresholds. Indices `$00`–`$41` show a repeating pattern of `$01` every 8th entry (8 experience points per level). Indices `$42`–`$C0` contain a smooth ramp from `$01` to `$10` (level scaling). Indices `$C1`+ contain high values `$E0`–`$EF` (endgame level caps). Used by the leveling system to determine when the player gains a level.

#### 9b. sine_table_8bit
**Part:** `sine_table_8bit`  
**Address:** `$1C455`–`$1C495` (64 entries)  
**Type:** `Byte` array

8-bit sine lookup table. Values range from `$00` to `$7F` covering one quarter-wave (0°–90°). Used by actor code for circular/oscillating motion (whirligigs, skulker enemy, sand fanger spiral attacks) and the scene lifecycle system for screen wipe effects.

#### 9c. signed_sine_table
**Part:** `signed_sine_table`  
**Address:** `$1C495`–`$1C595` (256 entries)  
**Type:** `Byte` array (signed)

Full 360° signed 8-bit sine table. Values go: `$7F` (peak) → `$00` (zero-crossing) → `$81` (trough) → `$00` (zero-crossing). The incan ruins whirligig enemy uses this for X/Y circular motion, and it's used for signed oscillation effects.

#### 9d. sine_table_16bit
**Part:** `sine_table_16bit`  
**Address:** `$1C595`–`$1C695` (128 word entries)  
**Type:** `Word` array

16-bit high-precision sine table, one quarter-wave (0°–90°). Values range from `$0000` to `$7FFF` (0.0 to ~1.0 in fixed-point). Used by the Mode 7 perspective system for rotation calculations.

#### 9e. cosine_table_16bit
**Part:** `cosine_table_16bit`  
**Address:** `$1C695`–`$1C795` (128 word entries)  
**Type:** `Word` array

16-bit high-precision cosine table, one quarter-wave. Values range from `$7FFF` (1.0) down to `$0000` (0.0). Paired with the sine table for Mode 7 matrix computations.

#### 9f. signed_sine_table_16bit
**Part:** `signed_sine_table_16bit`  
**Address:** `$1C795`–`$1C995` (256 word entries)  
**Type:** `Word` array (signed)

Full-cycle 16-bit signed sine table. Values range from `$0000` through `$7FFF` (positive peak) to `$8001` (negative trough). Used by Mode 7 perspective with 4-quadrant dispatch for rotation at arbitrary angles.

#### 9g. sine_table_16bit_copy
**Part:** `sine_table_16bit_quarter`  
**Address:** `$1C995`–`$1CA95` (128 word entries)  
**Type:** `Word` array

Duplicate of `sine_table_16bit`. Likely exists for bank-alignment or separate addressing context.

**Usage:**
- `mode7_perspective.asm` / `mode7_perspective_unused.asm` — Mode 7 rotation matrix (16-bit sin/cos)
- `scene_lifecycle.asm` — screen transition effects (8-bit sine)
- Actor code (whirligig, skulker, sand fanger) — circular movement patterns
- `system_init.asm` — uses `sine_table_8bit` address as a known zero-byte source for WRAM clearing

---

### 10. dialog_template_table

**Current name:** `templates_01CA95`  
**Proposed name:** `dialog_template_table`  
**Address:** `$1CA95`–`$1CBA6` (273 bytes)  
**Type:** Pointer table → `DialogString` entries (22 templates)  
**Category:** `tables`

**Description:**  
Reusable dialog box templates invoked by the `$C2 InsertTemplate` control code in dialog strings. Each template is a pre-formatted dialog string containing setup commands:

- **Templates `$00`–`$07`:** Screen-effect presets — configure `[SEP]` (screen effect parameters) for palette shifts and `[SFX]` (sound effect) triggers. Used for Dark Space transformations and special screen transitions.
- **Templates `$08`–`$11`:** Dialog box size presets — `[DLG:3,x]` sets dialog box position/type, `[SIZ:D,n]` sets the text line count (1–4 lines). These standardize dialog box sizes across the game.
- **Template `$12`:** "Where do you go?" — the world map destination selection prompt.
- **Templates `$13`–`$15`:** Screen-effect presets without sound effects (silent variants of `$00`–`$04`).

**Usage:** `DialogStringRenderer.asm` — the `InsertTemplate` handler (`$C2`) indexes this table to recursively expand template strings inline.

---

### 11. music_pointer_array

**Current name:** `music_array_01CBA6`  
**Proposed name:** `music_pointer_array`  
**Address:** `$1CBA6`–`$1CC00` (90 bytes)  
**Type:** `@Binary` (3-byte long pointers, 30 entries)  
**Category:** `system`

**Description:**  
Maps scene music IDs to SPC music data locations in ROM. Each 3-byte entry is a long pointer (`address_lo, address_hi, bank`) to compressed music data. The entries reference named BGM tracks:

| ID | Track |
|----|-------|
| `$00`–`$01` | `bgm_lively_city` |
| `$02` | `bgm_blessing_of_nature` |
| `$03` | `bgm_ominous_whispers` |
| `$04` | `bgm_royal_anthem` |
| `$05` | `bgm_descent_into_darkness` |
| `$06` | `bgm_awakening_the_wind` |
| `$07` | `bgm_secret_of_nazca` |
| `$08` | `bgm_legendary_sunken_continent` |
| `$09` | `bgm_golden_road` |
| `$0A` | `bgm_unexplored_temple` |
| `$0B` | `bgm_great_pyramid` |
| `$0D` | `bgm_longing_for_the_past` |
| `$0E` | `bgm_guardians` |
| `$0F` | `bgm_threat_of_dark_gaia` |
| `$10` | `bgm_deep_sadness` |
| `$11` | `bgm_beautiful_world` |
| `$12` | `bgm_bittersweet_victory` |
| `$13` | `bgm_rebirth` |
| `$14` | `bgm_drifting_endlessly` |
| `$15` | `bgm_space_beyond_time` |
| `$17` | `bgm_important_item` |
| `$18` | `bgm_lolas_melody` |
| `$19` | `bgm_lost_incan_melody` |
| `$1A` | `bgm_no_music` |
| `$1B` | `bgm_lively_city_by_the_sea` |
| `$1C` | `bgm_waterfall` |
| `$1D` | `bgm_melody_of_memories` |

**Usage:** `hdma_dma_spc.asm` — the SPC transfer system reads 3-byte entries from this array using `musicTransitionState × 3` as the index, loading the music data address and bank into the DMA transfer registers.

---

### 12. parallax_scroll_table

**Current name:** `parallax_table`  
**Proposed name:** `parallax_scroll_table`  
**Address:** `$1CC00`–`$1D3CE` (1,998 bytes)  
**Type:** Pointer table → binary parallax configs (37 entries, `$00`–`$24`)  
**Category:** `tables`

**Description:**  
Per-scene parallax scrolling configurations. Each entry defines HDMA table parameters that create multi-layer scrolling effects. The binary data encodes:

- Header bytes: BG mode, scroll region boundaries, flags
- Per-scanline-region entries: `register, scroll_speed_x, scroll_speed_y, flags`

Many entries (`$0D`–`$1A`) are simple 2-byte terminators (`$FFFF` = no parallax), meaning most indoor scenes don't use parallax. Complex entries define multi-region scroll effects for outdoor areas:
- Entry `$00` — 7-region parallax (Sky Temple-style layered clouds)
- Entry `$01` — 5-region parallax (coastal/ocean scenes)
- Entry `$05` — many-region complex parallax (Great Wall area)
- Entry `$06` — smooth gradient parallax (underwater)

**Usage:** `parallax_thinker.asm` — the parallax thinker actor reads the scene's parallax config and programs HDMA channels accordingly each frame.

---

### 13. event_block_table

**Current name:** `event_block_table`  
**Proposed name:** `event_block_table` *(already well-named)*  
**Address:** `$1D3CE`–`$1D8BE` (1,264 bytes, 158 entries × 8 bytes)  
**Type:** `event-block-def` array  
**Category:** `system`

**Description:**  
Defines event-triggered tile block operations. Each 8-byte entry specifies a rectangular region of tiles to copy or modify when an event flag changes:

| Byte | Field | Description |
|------|-------|-------------|
| 0 | Scene ID | Scene where this event block applies |
| 1 | Source X | Source tile X coordinate |
| 2 | Source Y | Source tile Y coordinate |
| 3 | Width | Width in tiles |
| 4 | Height | Height in tiles |
| 5 | Dest X | Destination tile X coordinate |
| 6 | Dest Y | Destination tile Y coordinate |
| 7 | Layer | 0 = BG1 (map), nonzero = BG2 (overlay), bit 0 = special flag |

These are used for doors opening/closing, barriers appearing/disappearing, puzzle state changes, and other visual map mutations tied to event progression. The `LookupEventBlock` routine validates the scene ID before executing the copy.

**Usage:** `event_blocks.asm` — the event block system uses `event_index × 8` to read entries and performs tile rectangle copies between source and destination coordinates.

---

### 14. hdma_and_ramp_tables

**Current name:** `hdma_channel_config`  
**Proposed name:** `hdma_and_ramp_tables`  
**Address:** `$1D8BE`–`$1D971` (179 bytes)  
**Category:** `system`

A composite block with three sub-tables:

#### 14a. hdma_channel_config
**Part:** `hdma_channel_config`  
**Address:** `$1D8BE`–`$1D8FE` (64 entries)  
**Type:** `Byte` array

DMA transfer mode lookup table for HDMA channel configuration. Each byte specifies the DMAP register value (transfer mode + direction bits) for a particular HDMA effect. Values include:
- `$00` = 1-byte write to single register
- `$01` = 2-byte write to register pair
- `$02` = 2-byte write to same register twice
- `$80`/`$81`/`$82` = same modes with indirect flag set

**Usage:** `hdma_dma_spc.asm` — `SetupHdmaChannel_Indirect/Direct` uses this to configure DMAP for HDMA channels. Also referenced by `parallax_thinker.asm` and `cop_handlers_collision.asm`.

#### 14b. parallax_speed_table
**Part:** `parallax_speed_config`  
**Address:** `$1D8FE`–`$1D90B` (13 bytes)  
**Type:** `Byte` array

Parallax scroll speed parameters. Contains shift/scale values used by the parallax thinker to calculate per-layer scroll rates. Values: `$02, $03, $03, $05, $05, $64, $00, $FF, $7F, $FF, $7F, $FF, $7F`.

**Usage:** `parallax_thinker.asm` — reads speed parameters alongside the HDMA channel config.

#### 14c. ramp_motion_curves
**Part:** `array_01D90B`  
**Address:** `$1D90B`–`$1D971` (102 bytes)  
**Type:** `ramp-motion` array (2 entries, each pointing to a binary curve)

Pre-computed acceleration/deceleration curves for ramp movement (e.g., stair climbing). Each `ramp-motion` entry is `{ &curve_data, frame_count }`:
- Entry 0: 64-frame curve (`binary_01D911`) — slow acceleration ramp, values `$F0`→`$00`→`$10`
- Entry 1: 32-frame curve (`binary_01D951`) — fast acceleration ramp, values `$F8`→`$00`→`$08`

**Usage:** `ramps.asm` — ramp actors read these curves to smoothly accelerate the player when stepping onto slopes/stairs.

---

### 15. body_table

**Current name:** `body_table`  
**Proposed name:** `body_table` *(already well-named)*  
**Address:** `$1D971`–`$1D9A7` (54 bytes, 9 entries × 6 bytes)  
**Type:** `body-entry` array  
**Category:** `tables`

**Description:**  
Maps player form IDs to their spriteset and sprite tile data locations. Each 6-byte `body-entry` contains:

```
body-entry { Address spriteset_ptr, @Binary sprite_tiles_ptr }
```

| Index | Form | Spriteset | Sprite Tiles |
|-------|------|-----------|-------------|
| 0 | Will (normal) | `table_158000` | `will_sprites_1A8000` |
| 1 | Freedan | `table_0E8000` | `free_sprites_1AC000` |
| 2 | Shadow | `table_148000` | `shad_sprites_1BC000` |
| 3 | Shadow (alt) | `table_148000` | `shad_sprites_1BC000` |
| 4 | Will (alternate) | `table_0F8000` | `will_sprites_1A8000` |
| 5 | Ability FX | `table_0FC000` | `abil_sprites_1B8000` |
| 6 | Will FX | `table_17A000` | `free_fx_1C8000` |
| 7 | Shadow FX | `table_17B000` | `shad_fx_1CA000` |
| 8 | Shadow (mode) | `table_17C000` | `shad_sprites_1BC000` |

**Usage:**
- `sprite_composition.asm` — reads spriteset pointer and tile DMA source for the active player form
- `actor_execution.asm` — loads body table entry for the current body index during form transitions

---

### 16. will_ability_anim_table

**Current name:** `table_01D9A7`  
**Proposed name:** `will_ability_anim_table`  
**Address:** `$1D9A7`–`$1D9BF` (24 bytes, 3 entries)  
**Type:** Pointer table → binary configs  
**Category:** `tables`

**Description:**  
Animation configuration table for Will's three attack abilities. Each entry is a 6-byte record containing sprite frame indices, hitbox dimensions, and timing data stored to the ability system's `climbStateData` registers (`$09E0`/`$09E2`).

| Index | Ability | Data |
|-------|---------|------|
| 0 | Psycho Dash | `00,00,16,0B,05,0A` |
| 1 | Psycho Slider | `00,00,18,0B,05,08` |
| 2 | Spin Dash | `00,00,1A,0B,04,07` |

**Usage:** `attack_ability_system.asm` — `LoadAbilityAnimTableA` reads Will's ability configs by index.

---

### 17. freedan_ability_anim_table

**Current name:** `table_01D9BF`  
**Proposed name:** `freedan_ability_anim_table`  
**Address:** `$1D9BF`–`$1D9D8` (25 bytes, 3 entries)  
**Type:** Pointer table → binary configs  
**Category:** `tables`

**Description:**  
Same structure as `will_ability_anim_table` but for Freedan's abilities:

| Index | Ability | Data |
|-------|---------|------|
| 0 | Dark Friar | `00,00,1C,0B,05,08,0C` |
| 1 | Aura Barrier | `00,00,1E,0B,05,09` |
| 2 | Earthquaker | `00,00,20,0B,00,07` |

**Usage:** `attack_ability_system.asm` — `LoadAbilityAnimTableB` reads Freedan's ability configs by index.

---

### 18. system_strings

**Current name:** `system_strings`  
**Proposed name:** `system_strings` *(already well-named)*  
**Address:** `$1D9D8`–`$1EB0F` (4,407 bytes)  
**Category:** `tables`

A large composite block containing all game UI and menu text, organized into 8 sub-tables:

#### 18a. boot_screen_strings (`consolestring_01D9D8`)
3 fixed strings: region lockout warning, "PUSH START BUTTON", and copyright notice.

#### 18b. item_name_table (`itemname_table_01DABF`)
Pointer table of 64 item display names (Red Jewel, Herb, Incan Statue A/B, Crystal Ball, etc.). Used in inventory screens and item acquisition dialogs.

#### 18c. item_menu_table (`itemmenu_table_01DE1E`)
Pointer table of 64 item menu descriptions — longer text shown when selecting items in the inventory menu.

#### 18d. Separator (`item_table_separator`)
8-byte padding between item menu and item description tables.

#### 18e. item_description_table (`itemdesc_table_01E132`)
Pointer table of item description strings — detailed help text for the item selection screen.

#### 18f. ability_menu_table (`abilmenu_table_01E5EC`)
Pointer table of ability menu display names.

#### 18g. ability_name_table (`abilname_table_01E65D`)
Pointer table of ability short names (Psycho Dash, Dark Friar, Aura Barrier, etc.).

#### 18h. ability_description_table (`abildesc_table_01E6DC`)
Pointer table of ability description text.

#### 18i. character_name_table (`charname_table_01E7CE`)
Pointer table of character display names (Will, Kara, Lance, Erik, Seth, etc.).

#### 18j. misc_string_table (`table_01E94C`)
Pointer table of miscellaneous UI strings (status labels, menu headers, save/load text).

**Usage:** The ConsoleStringRenderer and all inventory/menu subsystems reference these tables by sub-table pointer + index.

---

### 19. item_component_table

**Current name:** `itemcomp_table_01EB0F`  
**Proposed name:** `item_component_table`  
**Address:** `$1EB0F`–`$1EBA8` (153 bytes, 15 entries)  
**Type:** Pointer table → `ConsoleString` entries  
**Category:** `tables`

**Description:**  
Item name prefix/component strings used for compositional rendering. When the dialog system encounters the `$10 InsertItemName` control code, it looks up the component name from this table:

| Index | Component |
|-------|-----------|
| 0 | "Crystal " |
| 1 | "Diamond " |
| 2 | "Dark " |
| 3 | "Hieroglyph " |
| 4 | "Inca " |
| 5 | "Mystery " |
| 6 | "Prison " |
| 7 | "Plate " |
| 8 | "Psycho " |
| 9 | "Restores " |
| 10 | (additional) |
| 11 | (additional) |
| 12 | (additional) |
| 13 | (additional) |
| 14 | (additional) |

These components are combined with other text to form full item names, reducing string storage by sharing common prefixes.

**Usage:** `ConsoleStringRenderer.asm` — the `InsertItemName` handler (`$10`) indexes this table to render composite item names.

---

### 20. dictionary_a

**Current name:** `dictionary_01EBA8`  
**Proposed name:** `dialog_dictionary_a`  
**Address:** `$1EBA8`–`$1F54D` (2,469 bytes)  
**Type:** Pointer table → `DialogString` entries  
**Category:** `tables`

**Description:**  
First dialog text dictionary — a table of commonly used words and phrases compressed as indices. When the dialog renderer encounters control code `$D6 DictionaryA`, it reads a 1-byte operand as an index into this table and recursively renders the string at that pointer.

This is IOG's text compression system — instead of repeating "the", "you", "have", etc. throughout thousands of dialog strings, each common word is stored once in the dictionary and referenced by index. This table contains the most frequently used words.

**Usage:** `DialogStringRenderer.asm` — `DictionaryA` handler expands `$D6 XX` into the full word/phrase from this table.

---

### 21. dictionary_b

**Current name:** `dictionary_01F54D`  
**Proposed name:** `dialog_dictionary_b`  
**Address:** `$1F54D`–`$1FD24` (2,007 bytes)  
**Type:** Pointer table → `DialogString` entries  
**Category:** `tables`

**Description:**  
Second dialog text dictionary — extended word list. Functions identically to Dictionary A but is triggered by control code `$D7 DictionaryB`. Contains less frequently used words and longer phrases that still benefit from compression.

The two-dictionary system effectively gives 512 possible compressed words (256 per dictionary) while using only a 1-byte index per reference.

**Usage:** `DialogStringRenderer.asm` — `DictionaryB` handler expands `$D7 XX` from this table.

---

### 22. item_get_dialog_table

**Current name:** `itemget_table_01FD24`  
**Proposed name:** `item_get_dialog_table`  
**Address:** `$1FD24`–`$1FF6C` (584 bytes)  
**Type:** Pointer table → `DialogString` entries  
**Category:** `tables`

**Description:**  
Maps item IDs to the dialog string displayed when the player acquires that item. Each entry points to a dialog string such as "Will got a Red Jewel!" or "HP increased by 1!" The table is indexed by the item type received:

- Combat rewards (stat increases) have formulaic strings
- Key items have unique acquisition messages
- Some indices share the same string pointer (e.g., multiple Mystic Statues)
- Special entries include inventory-full messages and "nothing found" defaults

The strings at `dialogstring_01FF02` (inventory full) and `dialogstring_01FF1F` (item success) are referenced directly by the inventory management system.

**Usage:**
- `inventory_mgmt.asm` — displays item acquisition dialog
- `combat_collision.asm` — displays rewards after defeating enemies

---

## Proposed Name Changes Summary

| Current Name | Proposed Name | Rationale |
|-------------|---------------|-----------|
| `table_018000` | `display_preset_table` | Contains display-preset structs for scene PPU config |
| `table_01A95E` | `forced_walk_sequence_table` | Used exclusively by forced_walk system |
| `dir_sprite_01ABDE` | `direction_velocity_table` | Maps directions to sprite frames + velocities |
| `stats_01ABF0` | `enemy_stats_table` | Master enemy stat table |
| `table_01ADA8` | `scene_barrier_chest_table` | Per-scene barrier/chest placement data |
| `table_01B086` | `movement_delta_table` | Pre-computed movement delta curves |
| `scene_flag_table` | `trig_and_level_tables` | Composite: trig LUTs + level thresholds |
| `sine_table_8bit` | `sine_table_8bit` | 8-bit quarter-wave sine LUT |
| `signed_sine_table` | `signed_sine_table` | Full-cycle signed 8-bit sine |
| `sine_table_16bit` | `sine_table_16bit` | 16-bit quarter-wave sine LUT |
| `cosine_table_16bit` | `cosine_table_16bit` | 16-bit quarter-wave cosine LUT |
| `signed_sine_table_16bit` | `signed_sine_table_16bit` | Full-cycle 16-bit signed sine |
| `sine_table_16bit_quarter` | `sine_table_16bit_copy` | Duplicate of sine_table_16bit |
| `templates_01CA95` | `dialog_template_table` | Dialog box/FX template strings |
| `music_array_01CBA6` | `music_pointer_array` | Scene music → SPC data pointers |
| `parallax_table` | `parallax_scroll_table` | Per-scene parallax HDMA configs |
| `hdma_channel_config` | `hdma_channel_config` | HDMA DMA transfer mode lookup |
| `parallax_speed_config` | `parallax_speed_table` | Parallax scroll speed params |
| `array_01D90B` | `ramp_motion_curves` | Acceleration curves for ramp actors |
| `table_01D9A7` | `will_ability_anim_table` | Will's ability animation configs |
| `table_01D9BF` | `freedan_ability_anim_table` | Freedan's ability animation configs |
| `itemcomp_table_01EB0F` | `item_component_table` | Item name prefix components |
| `dictionary_01EBA8` | `dialog_dictionary_a` | Dialog word compression table A |
| `dictionary_01F54D` | `dialog_dictionary_b` | Dialog word compression table B |
| `itemget_table_01FD24` | `item_get_dialog_table` | Item acquisition dialog messages |

Names already correct: `scene_warps`, `enemy_clear_reward_table`, `event_block_table`, `body_table`, `system_strings`
