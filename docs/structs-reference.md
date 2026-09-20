# IOG Struct Reference

Comprehensive documentation of all struct types defined in `us/structs.json` for Illusion of Gaia (US). Each struct describes a repeating data layout used by the extraction/rebuild engine to parse and emit ROM data.

## Table of Contents

- [Naming Conventions](#naming-conventions)
- [Complete Rename Map](#complete-rename-map)
- [Actor System Structs](#actor-system-structs)
  - [actor-def](#actor-def)
  - [thinker-def](#thinker-def)
  - [actor-spawn](#actor-spawn)
  - [enemy-spawn](#enemy-spawn)
  - [thinker-spawn](#thinker-spawn)
  - [scene-event](#scene-event)
  - [enemy-stats](#enemy-stats)
- [Scene Definition Structs (meta)](#scene-definition-structs)
  - [meta (discriminated union)](#meta-discriminated-union)
  - [scene-meta](#scene-meta)
  - [display-mode](#display-mode)
  - [bitmap](#bitmap)
  - [palette](#palette)
  - [tileset](#tileset)
  - [tilemap](#tilemap)
  - [spritemap](#spritemap)
  - [music](#music)
  - [branch](#branch)
  - [label](#label)
  - [jump](#jump)
  - [char-tiles](#char-tiles)
  - [meta-skip](#meta-skip)
- [Movement & Animation Structs](#movement--animation-structs)
  - [delta-node](#delta-node)
  - [route-step](#route-step)
  - [direction-velocity](#direction-velocity)
  - [camera-keyframe](#camera-keyframe)
  - [ramp-motion](#ramp-motion)
- [System Initialization Structs](#system-initialization-structs)
  - [register-init](#register-init)
  - [wram-init](#wram-init)
  - [display-preset](#display-preset)
  - [dma-channel](#dma-channel)
- [Game Logic Structs](#game-logic-structs)
  - [gem-drop-threshold](#gem-drop-threshold)
  - [boss-reward-range](#boss-reward-range)
  - [statue-reward](#statue-reward)
  - [spawn-trigger](#spawn-trigger)
  - [zone-trigger](#zone-trigger)
  - [screen-pos](#screen-pos)
  - [event-block-def](#event-block-def)
- [Resource Structs](#resource-structs)
  - [body-entry](#body-entry)
  - [palette-bundle](#palette-bundle)
  - [sprite-set / sprite-group / sprite-part](#sprite-set--sprite-group--sprite-part)
  - [diary-entry](#diary-entry)
  - [map-label](#map-label)
- [Warp Structs](#warp-structs)
  - [warp-def](#warp-def)
  - [scene-warp](#scene-warp)
  - [stair-warp](#stair-warp)
- [Specialized Structs](#specialized-structs)
  - [conveyor-index / conveyor-zone](#conveyor-index--conveyor-zone)
- [Usage Statistics Summary](#usage-statistics-summary)

---



## Naming Conventions

All struct names use **kebab-case** (e.g., `actor-def`, `delta-node`, `enemy-stats`). In extracted `.asm`, struct instances appear as `type_ROMADDR` labels (e.g., `delta-node_01B130`).

## Complete Rename Map

Every struct has been given a descriptive kebab-case name. This table maps old names (from any previous version) to the current canonical names:


| Old Name       | New Name                                 | Rationale                                  |
| -------------- | ---------------------------------------- | ------------------------------------------ |
| `h_actor`      | *(removed, merged into* `actor-def`*)*   | Header bytes are now part of `actor-def`   |
| `h_thinker`    | *(removed, merged into* `thinker-def`*)* | Header bytes are now part of `thinker-def` |
| `actor_def`    | `actor-def`                              | Actor definition (header + code)           |
| `thinker_def`  | `thinker-def`                            | Thinker definition (header + code)         |
| `actor`        | `actor-spawn`                            | Scene actor spawn entry                    |
| `enemy`        | `enemy-spawn`                            | Scene enemy spawn entry                    |
| `thinker`      | `thinker-spawn`                          | Scene thinker spawn entry                  |
| `event_def`    | `scene-event`                            | Scene event definition (spawns + dialog)   |
| `stats`        | `enemy-stats`                            | Enemy combat statistics record             |
| `dma_data`     | `dma-channel`                            | DMA/HDMA channel setup entry               |
| `motion`       | `route-step`                             | Overworld route movement step              |
| `map_name`     | `map-label`                              | Overworld location name entry              |
| `dir_sprite`   | `direction-velocity`                     | Direction → velocity index mapping         |
| `sprite_set`   | `sprite-set`                             | Sprite animation set                       |
| `sprite_group` | `sprite-group`                           | Sprite frame group                         |
| `sprite_part`  | `sprite-part`                            | Sprite OAM tile                            |
| `bundle`       | `palette-bundle`                         | Palette animation bundle entry             |
| `const`        | `wram-init`                              | Boot WRAM initialization constant          |
| `sc_ix`        | `conveyor-index`                         | Conveyor belt scene index                  |
| `sc_data`      | `conveyor-zone`                          | Conveyor belt zone definition              |
| `warp_def`     | `warp-def`                               | Composite warp definition                  |
| `scene_warp`   | `scene-warp`                             | Scene transition warp entry                |
| `stair_warp`   | `stair-warp`                             | Stair transition warp entry                |
| `mapdef`       | `scene-meta`                             | Scene metadata definition                  |
| `ppu`          | `display-mode`                           | PPU display mode preset selector           |
| `unk1`         | `gem-drop-threshold`                     | Dark gem drop weighted RNG lookup          |
| `unk5`         | `boss-reward-range`                      | Boss defeat scene range → stat reward catchup config |
| `unk6`         | `register-init`                          | Hardware register boot initialization      |
| `unk7`         | `display-preset`                         | Scene display PPU configuration preset     |
| `unk8`         | `delta-node`                             | Linked-list movement/animation delta node  |
| `unk9`         | `spawn-trigger`                          | Scene + position transition trigger        |
| `unk10`        | `screen-pos`                             | Screen coordinate pair (X, Y)              |
| `unk11`        | `zone-trigger`                           | Scene bounding-box hazard trigger          |
| `unk14`        | `body-entry`                             | Character form → sprite resource map       |
| `unk15`        | `event-block-def`                        | Field tile reveal block definition (src→dst tile copy) |
| `unk16`        | `diary-entry`                            | Diary menu warp destination                |
| `unk17`        | `ramp-motion`                            | Ramp/slope Y-motion pattern                |
| `unk18`        | `camera-keyframe`                        | Camera drift/shake keyframe                |
| `unk19`        | `statue-reward`                          | Mystic Statue inventory reward slot        |
| `metaE`        | `meta-skip`                              | No-op scene command (skip 3 bytes)         |
| `meta17`       | `char-tiles`                             | Direct VRAM character tile upload          |


---



## Actor System Structs



### actor-def

Variable-length actor definition: 3-byte header + inline code body. This is the primary actor format, combining the former `h_actor` header directly into the definition. The list entry points 3 bytes before the code entry point, to this header (Data Crystal: `dl EntryPtr-3`).


| Field | Type | Offset | Name       | Description                                                                                                   |
| ----- | ---- | ------ | ---------- | ------------------------------------------------------------------------------------------------------------- |
| 0     | Byte | +0     | spriteId   | Starting sprite index → `$7E0028` (`SprIdx`). `$00` = no sprite (utility/system actors)                       |
| 1     | Byte | +1     | flags10Lo  | Low byte of initial `$7E0010` (`Flags10`) — physics/rendering flags. Usually `$00`                            |
| 2     | Byte | +2     | initBudget | Header byte; common values `$10`/`$20`/`$30`/`$38`. Not consumed by spawn routine; likely extraction metadata |
| 3     | Code | +3     | code       | Inline 65C816 code body (variable length) — the actual actor execution entry point                            |


**Layout:** `[Byte, Byte, Byte, Code]`

**Spawn behavior:** `InitActorFromSceneData` reads the header: byte +0 → `$7E0028` (sprite index), byte +1 OR'd with `$4000` → `$7E0010` (Flags10 with bit 14 set). Execution begins at +3. Data Crystal confirms byte +0 as "starting sprite ID" and bytes +1/+2 as "starting actor-page $10/$11."

**Usage:** Every actor in the game — NPCs, enemies, bosses, interactive objects, system actors, camera controllers, menu handlers. This is the most-used struct type in the entire ROM.

**Files:** 400+ `.asm` files across all game areas

**blocks.json:** 652 typed parts

---



### thinker-def

Variable-length thinker definition: 2-byte header + inline code. Combines the former `h_thinker` header directly into the definition. The list entry points 2 bytes before the code entry point (Data Crystal: `dl EntryPtr-2`). The 2-byte header is copied as a little-endian word into `$7F000E,x`.


| Field | Type | Offset | Name         | Description                                                                                                   |
| ----- | ---- | ------ | ------------ | ------------------------------------------------------------------------------------------------------------- |
| 0     | Byte | +0     | thinkerClass | Thinker class flag: `$00`=execute before actors, `$04`=execute after actors (bit `$0004` in `$7F000E` header) |
| 1     | Byte | +1     | slotSize     | WRAM slot size (almost always `$08` = 8 bytes)                                                                |
| 2     | Code | +2     | code         | Inline 65C816 code body — execution entry point                                                              |


**Layout:** `[Byte, Byte, Code]`

**Usage:** Per-frame background processors: HDMA effects, palette cycling, parallax scrolling, ambient effects, boot logo sequences. Data Crystal: "Flag #$0004 in the header means execute-after-actors if set, before-actors if clear."

**Files:** ~40+ thinker definitions

**blocks.json:** 58 typed parts

---



### actor-spawn

Scene spawn-table entry for standard actors (non-enemy). Child of `enemy-spawn` with schema discriminator `0` (based on `statsIndex == 0`, not on a flags nibble).


| Field | Type       | Offset | Name   | Description                                                                                                                     |
| ----- | ---------- | ------ | ------ | ------------------------------------------------------------------------------------------------------------------------------- |
| 0     | Byte       | +0     | spawnX | Tile X coordinate (×16 = pixel X). Some actors override for other purposes                                                      |
| 1     | Byte       | +1     | spawnY | Tile Y coordinate (×16 = pixel Y)                                                                                               |
| 2     | Byte       | +2     | param  | Actor parameter. If odd: right-shifted 1 bit → actor `$7E000E`. If even: bit 3 cleared, becomes OAM high byte at `$7E000E`      |
| 3     | @actor-def | +3     | def    | 3-byte long pointer to actor definition (points to 3-byte header, code entry is +3 from this pointer)                           |


**Layout:** `[Byte, Byte, Byte, @actor-def]`  
**Parent:** `enemy-spawn` (discriminator `0` — determined by `statsIndex` being absent/zero, not by a flags nibble)

**Usage:** Part of `scene-event` in the scene actor table. Every scene's spawn list uses these entries for non-enemy actors. The `param` byte has dual semantics: odd values encode an actor-specific parameter (e.g., "contents of this Dark Space"), while even values provide sprite OAM override bits.

---



### enemy-spawn

Scene spawn-table entry for enemy actors with extra combat parameters. Distinguished from `actor-spawn` by having a non-zero `statsIndex` (Data Crystal: "Actors not involved in combat should have StatsIndex=0, in which case MonsterId and DeathActionIndex are omitted").


| Field | Type       | Offset | Name           | Description                                                                                                                    |
| ----- | ---------- | ------ | -------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| 0     | Byte       | +0     | spawnX         | Tile X coordinate (×16 = pixel X)                                                                                              |
| 1     | Byte       | +1     | spawnY         | Tile Y coordinate (×16 = pixel Y)                                                                                              |
| 2     | Byte       | +2     | param          | Actor parameter (same semantics as `actor-spawn` param)                                                                        |
| 3     | @actor-def | +3     | def            | 3-byte pointer to actor definition                                                                                             |
| 4     | Byte       | +6     | statsIndex     | Index into `enemy-stats` table (×4 = byte offset to HP/STR/DEF/DP at `$81ABF0`). Non-zero distinguishes enemy from actor entry |
| 5     | Byte       | +7     | enemyNum       | Dungeon enemy number for kill tracking. `0` = always respawns. Non-zero = stays dead until flag cleared (world map, death, etc) |
| 6     | Byte       | +8     | deathActionIdx | Map rearrangement script index on death (as if `COP $32 : db Idx : COP $33`)                                                  |


**Layout:** `[Byte, Byte, Byte, @actor-def, Byte, Byte, Byte]`  
**Discriminator:** Non-zero `statsIndex` (schema typetag `6` in `structs.json`; not a runtime flags nibble value)  
**Delimiter:** `255` (`$FF` byte terminates actor list, followed by map name `DialogString` + `$CA`)

---



### thinker-spawn

Scene thinker spawn entry: thinker-specific parameter + pointer to thinker definition.


| Field | Type         | Offset | Name  | Description                                                                                                |
| ----- | ------------ | ------ | ----- | ---------------------------------------------------------------------------------------------------------- |
| 0     | Byte         | +0     | param | Thinker-specific parameter (e.g., palette bundle index for palette thinkers). Stored in thinker actor WRAM |
| 1     | @thinker-def | +1     | def   | 3-byte long pointer to thinker definition (points to 2-byte header, code entry is +2 from pointer)        |


**Layout:** `[Byte, @thinker-def]`  
**Delimiter:** `255`

**Usage:** Scene thinker lists in the thinker table. Each scene can have 0–5 thinkers. Data Crystal: "Param is a thinker-specific parameter, e.g. 'palette bundle index'." For palette cycling thinkers, this value becomes the bundle index passed to COP `$37`/`$38`.

**blocks.json:** `scene_thinkers` (typed `&thinker-spawn`)

---



### scene-event

Composite scene event definition: actor/enemy spawn list + map name text. Data Crystal: "The actor list ends with $FF, followed by the name of the map (if any), followed by $CA."


| Field | Type        | Name    | Description                                                                                         |
| ----- | ----------- | ------- | --------------------------------------------------------------------------------------------------- |
| 0     | enemy-spawn | spawns  | `$FF`-terminated list of `actor-spawn`/`enemy-spawn` entries (6 or 9 bytes each, based on stats)    |
| 1     | DialogString  | mapName | Map/location name text (variable-width encoded, terminated by `$CA`). May be empty for unnamed maps |


**Layout:** `[enemy-spawn, DialogString]`

**Usage:** Top-level scene actor table. Every scene maps to one `scene-event` entry. In extracted ASM, the spawn list and name text are split into sibling labels: `scene_event_XXXXX` (spawns) and `scene_event_XXXXX_value` (map name). Empty events exist for scenes with no actors.

**blocks.json:** `scene_actors` (typed `&scene-event`)

---



### enemy-stats

4-byte enemy combat statistics record.


| Field | Type | Offset | Name       | Description                                                    |
| ----- | ---- | ------ | ---------- | -------------------------------------------------------------- |
| 0     | Byte | +0     | hp         | Max/current HP (loaded into `$currentHp` on spawn)             |
| 1     | Byte | +1     | attack     | Attack power (damage to player = attack − playerDef, min 1)    |
| 2     | Byte | +2     | defense    | Defense stat (damage to enemy = playerStr + bonuses − defense, min 1) |
| 3     | Byte | +3     | gemDropType | Dark gem drop type: 0=none, 1=fixed type A, 2=fixed type B, 3=random weighted |


**Layout:** `[Byte, Byte, Byte, Byte]`

**Usage:** Central enemy stat table indexed by all combat actors. The `hp` field is loaded directly into the actor's `$currentHp`. The `attack` field (byte 1) determines damage to the player: `attack − playerDef` (min 1), applied via `ApplyPlayerHitstun`. The `defense` field (byte 2) reduces incoming damage from the player: `playerStr + bonuses − defense` (min 1). Bosses with defense `$7F` (127) are effectively damage-immune through normal attacks. The `gemDropType` field (byte 3) determines what dark gem spawns on defeat via `StandardEnemyDefeatHandler` → `EnemyGemDropRouter`: 0=no gem (stat bonus path only), 1/2=fixed gem type, 3+=random weighted selection from `gem-drop-threshold` table.

**Files:** `stats_01ABF0.asm` (110 entries), consumed by 40+ actor files

**blocks.json:** `stats_01ABF0` (109552–109992)

**Entry count:** 110 entries × 4 bytes = 440 bytes

---



## Scene Definition Structs



### meta (discriminated union)

The `meta<>` type is a discriminated union used in scene metadata scripts. The first byte (discriminator) selects which child struct follows. The engine reads the discriminator and dispatches to the appropriate scene script command handler via `scene_script_jump_table`.

**Discriminator byte** → child struct (Data Crystal calls these "header cards"):


| Disc | Hex    | Name           | Handler                    | Purpose                              | Data Crystal Card |
| ---- | ------ | -------------- | -------------------------- | ------------------------------------ | ----------------- |
| 0    | `$00`  | *(end)*        | —                          | End-of-script terminator             | —                 |
| 2    | `$02`  | `display-mode` | `SceneCmd_ConfigDisplay`   | PPU display mode setup               | `$02`             |
| 3    | `$03`  | `bitmap`       | `SceneCmd_LoadBgTiles`     | VRAM character data upload           | `$03`             |
| 4    | `$04`  | `palette`      | `SceneCmd_LoadTilemap`     | CGRAM palette buffer upload          | `$04`             |
| 5    | `$05`  | `tileset`      | `SceneCmd_LoadDualTilemap` | BG metatile mapping load             | `$05`             |
| 6    | `$06`  | `tilemap`      | `SceneCmd_FullGraphics`    | Metatile tilemap load                | `$06`             |
| 14   | `$0E`  | `meta-skip`    | `SceneCmd_Skip3`           | No-op (skip 3 bytes)                 | —                 |
| 16   | `$10`  | `spritemap`    | `SceneCmd_LoadSpriteTiles` | Spriteset data load                  | `$10`             |
| 17   | `$11`  | `music`        | `SpcMusicLoadCmd`          | SPC music transfer                   | `$11`             |
| 19   | `$13`  | `branch`       | `SceneCmd_ConditionalLoad` | Flag-conditional jump                | `$13`             |
| 20   | `$14`  | `label`        | `SceneCmd_Nop`             | Named anchor / jump target           | `$14`             |
| 21   | `$15`  | `jump`         | `SkipScriptCommands`       | Unconditional jump to label          | `$15`             |
| 23   | `$17`  | `char-tiles`   | `SceneCmd_LoadCharTiles`   | Direct VRAM char/tile DMA            | —                 |

**Undocumented dispatch slots:**
Discriminators `$01`, `$07`–`$0D`, `$0F`, `$12`, `$16` all dispatch to `code_02845C` (no-op RTS) in the jump table. Discriminator `$12` has special significance in `SkipScriptCommands` as a skip-region terminator (end-of-skip marker).

**Delimiter:** `0` (null discriminator = end of script)

---



### scene-meta

Top-level scene metadata definition: scene ID + command stream. Data Crystal: "The format of a map's entry in the table is `db MapNum : db $00` followed by one or more header cards."


| Field | Type   | Name     | Description                                                  |
| ----- | ------ | -------- | ------------------------------------------------------------ |
| 0     | Word   | sceneId  | Scene index (0–255), stored as `MapNum, $00` word            |
| 1     | meta<> | commands | Stream of discriminated union commands (terminated by `$00`) |


**Layout:** `[Word, meta<>]`

**Usage:** Every scene in the game has one `scene-meta` entry defining its graphical resource loading sequence. 230+ scene definitions in `scene_meta.asm`. The engine seeks through the table at `$0D8000` looking for matching map IDs. In extracted ASM, the Word prefix is embedded in the block name (e.g., `scene-meta_0001`) rather than appearing as an explicit data field.

**blocks.json:** `scene_meta` (884736–897023, typed `scene-meta`)

---



### display-mode

Display mode preset selector (discriminator 2). Selects a `display-preset` entry by index. Data Crystal: "Indexes pointers to PPU register settings at $818000."


| Field | Type | Offset | Name        | Description                                                            |
| ----- | ---- | ------ | ----------- | ---------------------------------------------------------------------- |
| 0     | Byte | +0     | presetIndex | Index into `display-preset` table at `$818000` (`table_018000.asm`, 0–46) |


**Layout:** `[Byte]` (after discriminator)

**Usage in scene_meta.asm:** 231 instances

---



### bitmap

VRAM character data upload command (discriminator 3). Data Crystal: "Load VRAM character data. Writes to VRAM after decompressing (if needed) to $7E7000."


| Field | Type    | Offset | Name       | Description                                                                                                                   |
| ----- | ------- | ------ | ---------- | ----------------------------------------------------------------------------------------------------------------------------- |
| 0     | Byte    | +0     | srcOffset  | Source offset within decompressed data (shifted left before use)                                                              |
| 1     | Byte    | +1     | sizeW      | Transfer size in words (shifted left; ignored if data is LZ-compressed)                                                       |
| 2     | Byte    | +2     | destOffset | Destination VRAM offset (shifted left before use)                                                                             |
| 3     | @Binary | +3     | data       | 3-byte pointer to character tile data (may be LZ-compressed)                                                                  |
| 4     | Byte    | +6     | isSprites  | Target buffer: `$00`=BG (base VRAM word-addr `$2000`), `$01`=sprite (base `$4000`). Handler supports additional modes `$02`/`$03` |


**Layout:** `[Byte, Byte, Byte, @Binary, Byte]` (after discriminator)

**Usage in scene_meta.asm:** 319 instances

**Notes:** Data Crystal: "The base VRAM word-address is $2000 (byte-address $4000) if IsSprites=0, or $4000 (byte-address $8000) if IsSprites=1." All three parameter bytes (srcOffset, sizeW, destOffset) are left-shifted before use. If the data has `$0000` for its compressed size header, it is treated as uncompressed and the sizeW byte is used.

---



### palette

Palette upload to CGRAM buffer (discriminator 4). Data Crystal: "Load CGRAM data. Writes to the CGRAM buffer at $7F0A00."


| Field | Type    | Offset | Name       | Description                                                                  |
| ----- | ------- | ------ | ---------- | ---------------------------------------------------------------------------- |
| 0     | Byte    | +0     | srcOffset  | Source offset within palette data (shifted left before use)                   |
| 1     | Byte    | +1     | sizeW      | Transfer size in words (shifted left before use)                              |
| 2     | Byte    | +2     | destOffset | Destination offset in CGRAM staging buffer `$7F0A00` (shifted left)          |
| 3     | @Binary | +3     | data       | 3-byte pointer to palette data (always uncompressed per Data Crystal)        |


**Layout:** `[Byte, Byte, Byte, @Binary]` (after discriminator)

**Usage in scene_meta.asm:** 278 instances

**Notes:** Palette data (card `$04`) is always uncompressed. All three parameter bytes are left-shifted (×2) before use to convert from word to byte addressing.

---



### tileset

BG metatile mapping load command (discriminator 5). Data Crystal: "Load BG metatile mappings, which join four 8×8 px VRAM characters as a 16×16 px metatile."


| Field | Type    | Offset | Name       | Description                                                                                                                              |
| ----- | ------- | ------ | ---------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| 0     | Byte    | +0     | srcOffset  | Source offset within data (shifted left before use)                                                                                       |
| 1     | Byte    | +1     | sizeW      | Transfer size in words (shifted left; ignored if LZ-compressed)                                                                           |
| 2     | Byte    | +2     | destOffset | Destination offset in metatile buffer (shifted left)                                                                                      |
| 3     | Byte    | +3     | layers     | Layer target: `1`=Map (→ `$7E2000`), `2`=Effect (→ `$7E2800`), `3`=both                                                                  |
| 4     | @Binary | +4     | data       | 3-byte pointer to metatile mapping data (may be LZ-compressed)                                                                           |


**Layout:** `[Byte, Byte, Byte, Byte, @Binary]` (after discriminator)

**Usage in scene_meta.asm:** 300 instances

**Notes:** Data Crystal: "Only 8 bits of the VRAM addresses are used; the four high bits in each tile set its collision type." Card `$05` for each layer must precede card `$06` (tilemap) for that layer. Card `$03` (bitmap) with isSprites=0 must precede this command to set up VRAM and the decompression buffer.

---



### tilemap

Metatile tilemap load for a BG layer (discriminator 6). Data Crystal: "Load metatile tilemap."


| Field | Type    | Offset | Name  | Description                                                                                                     |
| ----- | ------- | ------ | ----- | --------------------------------------------------------------------------------------------------------------- |
| 0     | Byte    | +0     | layer | Target layer: `1`=Map (BG1, → `$7EA000`), `2`=Effect (BG2, → `$7EC000`)                                        |
| 1     | @Binary | +1     | data  | 3-byte pointer to tilemap data (may be LZ-compressed)                                                           |


**Layout:** `[Byte, @Binary]` (after discriminator)

**Usage in scene_meta.asm:** 383 instances

---



### spritemap

Metasprite / spriteset / sprite tile connectivity data load (discriminator 16). Data Crystal: "Load metasprite / spriteset / sprite tile connectivity data. Data is written to $7E4000."


| Field | Type    | Offset | Name  | Description                                                                     |
| ----- | ------- | ------ | ----- | ------------------------------------------------------------------------------- |
| 0     | Word    | +0     | sizeB | Size in bytes of spriteset data (e.g., `$17F4`, `$1238`)                        |
| 1     | Byte    | +2     | dummy | Unused byte (always `$00` in extracted data)                                     |
| 2     | @Binary | +3     | data  | 3-byte pointer to spriteset source data                                          |


**Layout:** `[Word, Byte, @Binary]` (after discriminator)

**Usage in scene_meta.asm:** 56 instances

---



### music

SPC music track load command (discriminator 17). Data Crystal: "Load music."


| Field | Type    | Offset | Name      | Description                                                                                                                                         |
| ----- | ------- | ------ | --------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| 0     | Byte    | +0     | musicId   | Music track ID. Sets which music should be resumed by actors that interrupt normal music (→ `$7E06F2`)                                               |
| 1     | Byte    | +1     | roomGroup | Room group identifier. If `$7E06F6` is nonzero and ≠ `roomGroup`, the card does nothing and pre-existing music continues. `$00`=default, `$01`=stop |
| 2     | @Binary | +2     | data      | 3-byte pointer to SPC music data (always uncompressed)                                                                                              |


**Layout:** `[Byte, Byte, @Binary]` (after discriminator)

**Usage in scene_meta.asm:** 234 instances

**Notes:** Data Crystal: "If $7E06F6 is nonzero and not equal to RoomGroup, this card does nothing, and any pre-existing music continues without interruption; the Gold Ship uses this to preserve music between outside and inside. $7E06F6 is zeroed after this card is read." Music data (card `$11`) is always uncompressed.

---



### branch

Conditional script branching (discriminator 19).


| Field | Type | Offset | Name        | Description                        |
| ----- | ---- | ------ | ----------- | ---------------------------------- |
| 0     | Byte | +0     | flag        | WRAM flag index to test            |
| 1     | Byte | +1     | targetLabel | Label ID to jump to if flag is set |


**Layout:** `[Byte, Byte]` (after discriminator)

**Usage in scene_meta.asm:** 18 instances. Used for conditional resource loading based on story progress flags.

---



### label

Named anchor point in script (discriminator 20).


| Field | Type | Offset | Name    | Description                                  |
| ----- | ---- | ------ | ------- | -------------------------------------------- |
| 0     | Byte | +0     | labelId | Label ID (referenced by `branch` and `jump`) |


**Layout:** `[Byte]` (after discriminator)

**Usage in scene_meta.asm:** 56 instances

---



### jump

Unconditional jump to label (discriminator 21).


| Field | Type | Offset | Name        | Description         |
| ----- | ---- | ------ | ----------- | ------------------- |
| 0     | Byte | +0     | targetLabel | Label ID to jump to |


**Layout:** `[Byte]` (after discriminator)

**Usage in scene_meta.asm:** 176 instances

---



### char-tiles

Direct VRAM character tile upload (discriminator 23). Optionally LZ-decompresses binary data and DMAs to VRAM.


| Field | Type    | Offset | Name  | Description                                                                          |
| ----- | ------- | ------ | ----- | ------------------------------------------------------------------------------------ |
| 0     | Byte    | +0     | param | Bit 7: VRAM addressing mode (`$80`=direct word address); bits 0–6: address parameter |
| 1     | @Binary | +1     | data  | 3-byte pointer to tile data (optionally LZ-compressed)                               |


**Layout:** `[Byte, @Binary]` (after discriminator)

**Usage in scene_meta.asm:** 1 instance (inventory screen `mapdef_00FF` only)

**Runtime handler:** `SceneCmd_LoadCharTiles` — decompresses data if non-null, DMAs to VRAM at address derived from param byte.

---



### meta-skip

No-op scene command that skips 3 parameter bytes (discriminator 14).


| Field | Type | Offset | Name    | Description |
| ----- | ---- | ------ | ------- | ----------- |
| 0     | Byte | +0     | unused0 | Unused      |
| 1     | Byte | +1     | unused1 | Unused      |
| 2     | Byte | +2     | unused2 | Unused      |


**Layout:** `[Byte, Byte, Byte]` (after discriminator)

**Usage in scene_meta.asm:** 0 instances. Engine handler `SceneCmd_Skip3` exists but no mapdef data uses this command. Reserved for development/debugging.

---



## Movement & Animation Structs



### delta-node

Singly-linked list node for per-frame signed movement deltas. The core animation primitive in the engine.


| Field | Type        | Offset | Name  | Description                                                  |
| ----- | ----------- | ------ | ----- | ------------------------------------------------------------ |
| 0     | Word        | +0     | delta | Signed 16-bit per-frame delta (e.g., `$0001`=+1, `$FFFF`=−1) |
| 1     | &delta-node | +2     | next  | Same-bank pointer to next node (`$0000` = null terminator)   |


**Layout:** `[Word, &delta-node]`

**Terminator:** Node with `delta=$0000, next=$0000`. Self-referencing nodes (next → self) create infinite constant-velocity loops.

**Usage contexts:**

1. **Animation frame timing** — `AnimFrameLookup` maps frame index → delta chain head for X/Y velocity (`$2C`/`$2E`)
2. **Forced camera scroll** — `direction-velocity` indices → X/Y velocity chains for scripted player walks
3. **Overworld route playback** — three parallel chains per route step drive camera X, Y, and player position
4. **Hit knockback** — stagger controller selects X or Y chain for knockback direction

**Files:** `movement_delta_table.asm` (85-entry pointer table + 1,173 nodes), `actor_pool.asm`, `forced_walk.asm`, `WorldMapController.asm`, `hit_stagger_controller.asm`

**blocks.json:** `movement_delta_table` (110726–115588, typed `&delta-node`)

**Entry count:** 85 index entries + 1,173 nodes = 4,862 bytes

**Common patterns:**

- `< $0001, &self >` — constant +1/frame (loop forever)
- `< $FFFF, &self >` — constant −1/frame
- `< $0001, &next > → < $0000, &prev >` — alternating +1/0 (half-speed)
- `< $0000, $0000 >` — null terminator (stop)

---



### route-step

4-byte overworld route movement step. Encodes one segment of an overworld travel route.


| Field | Type | Offset | Name      | Description                                                               |
| ----- | ---- | ------ | --------- | ------------------------------------------------------------------------- |
| 0     | Byte | +0     | deltaXIdx | Index into `delta-node` table for camera X chain; `$FF`=end; `$FE`=branch |
| 1     | Byte | +1     | deltaYIdx | Index into `delta-node` table for camera Y chain                          |
| 2     | Byte | +2     | posIdx    | Index into `delta-node` table for player position chain                   |
| 3     | Byte | +3     | duration  | Frame count for this step (`$10`–`$A0` typical)                           |


**Layout:** `[Byte, Byte, Byte, Byte]`  
**Delimiter:** Consumer checks `deltaXIdx == $FF` (end of route) and `deltaXIdx == $FE` (branch: load new route pointer from following word). No explicit `$FF` terminator bytes appear in the extracted `world_map_routes.asm`; routes are a contiguous byte stream with the pointer table defining start offsets.

**Usage:** Overworld map route animations. When the player selects a destination, the engine reads a `route-step` sequence to animate the camera/sprite along the path.

**Files:** `world_map_routes.asm` (251 entries across ~38 routes)

**blocks.json:** `world_map_routes` (241015–242132, typed `&route-step`)

---



### direction-velocity

2-byte direction-to-velocity mapping for player directional movement.


| Field | Type | Offset | Name    | Description                                        |
| ----- | ---- | ------ | ------- | -------------------------------------------------- |
| 0     | Byte | +0     | xVelIdx | Index into `delta-node` table for X velocity chain |
| 1     | Byte | +1     | yVelIdx | Index into `delta-node` table for Y velocity chain |


**Layout:** `[Byte, Byte]`

**Usage:** Translates player facing direction byte (`$0650`) into X/Y velocity chain pointers for forced walk sequences. 9 entries cover all cardinal and diagonal directions.

**Files:** `dir_sprite_01ABDE.asm` (9 entries), `forced_walk.asm`, `chunk_03BAE1.asm`

**blocks.json:** `dir_sprite_01ABDE` (109534–109552)

**Entry count:** 9 entries × 2 bytes = 18 bytes

---



### camera-keyframe

2-byte camera drift/shake keyframe: signed pixel delta + frame duration.


| Field | Type | Offset | Name   | Description                                                            |
| ----- | ---- | ------ | ------ | ---------------------------------------------------------------------- |
| 0     | Byte | +0     | delta  | Signed 8-bit pixel delta/frame (≥`$80` = negative; `$FF`=−1, `$FC`=−4) |
| 1     | Byte | +1     | frames | Duration in frames; `$3C`=60 (hold/pause); `$00`=end of sequence       |


**Layout:** `[Byte, Byte]`

**Usage:** Scripted camera vertical panning and shaking during cutscenes. The engine adds delta to `$cameraTargetY`/`$cameraDeltaY` each frame for the specified duration.

**Contexts:**

- **Watermia intro** — slow camera pan revealing the city (37 keyframes)
- **Gold Ship wreck** — ship rocking with alternating ±deltas (69 keyframes)
- **Erik cutscene** — dramatic camera movement during shipwreck (19 keyframes)

**blocks.json:** 2 typed parts, 1 override address

**Total:** ~125 keyframes across 3 files

---



### ramp-motion

Ramp/slope Y-motion pattern descriptor. Points to a byte stream of signed Y deltas for smooth vertical movement on slopes.


| Field | Type    | Offset | Name    | Description                                        |
| ----- | ------- | ------ | ------- | -------------------------------------------------- |
| 0     | &Binary | +0     | pattern | Same-bank pointer to byte array of signed Y deltas |
| 1     | Byte    | +2     | length  | Number of bytes in the pattern                     |


**Layout:** `[&Binary, Byte]`

**Usage:** Applied when the player walks on ramps/slopes. Each byte is a signed Y offset per animation frame. Two patterns exist:

- Pattern 0: 64 bytes — gradual slope (long ramp)
- Pattern 1: 32 bytes — steep slope (short ramp)

**Files:** `hdma_channel_config.asm` (2 entries), `ramps.asm` (consumer)

**blocks.json:** `array_01D90B` (121099–121201)

---



## System Initialization Structs



### register-init

3-byte SNES hardware register initialization entry for system boot.


| Field | Type | Offset | Name    | Description                                                          |
| ----- | ---- | ------ | ------- | -------------------------------------------------------------------- |
| 0     | Word | +0     | address | Hardware register address (`$2100`–`$2133` PPU, `$4200`–`$420D` CPU) |
| 1     | Byte | +2     | value   | 8-bit value to write to the register                                 |


**Layout:** `[Word, Byte]`  
**Delimiter:** Address word with bit 15 set (`BMI` check; `$FFFF` is the conventional sentinel but any address ≥ `$8000` terminates)

**Usage:** `InitHardwareRegisters` iterates this table at boot, writing each value to its register. Covers all PPU registers (display brightness, OBJ settings, BG mode, tilemap addresses, window masks, color math) and CPU I/O registers (NMI/IRQ enables, H/V timer, DMA channels).

**Files:** `system_init.asm` (`PpuRegisterInitTable`, 76 entries)

**blocks.json:** `struct_029F5A` in `system_init` (171866–172096)

**Entry count:** 76 entries × 3 bytes + 2-byte terminator = 230 bytes

---



### wram-init

Boot WRAM initialization constant: address + value pair.


| Field | Type | Offset | Name    | Description                                                  |
| ----- | ---- | ------ | ------- | ------------------------------------------------------------ |
| 0     | Word | +0     | address | WRAM destination address (bit 15 set = end sentinel)         |
| 1     | Word | +2     | value   | 16-bit initialization value (constants, pointers, addresses) |


**Layout:** `[Word, Word]`  
**Delimiter:** `65535` (address `$FFFF` terminates)

**Usage:** Boot initialization loop writes each value to the specified WRAM address. Initializes engine state: VRAM address variables, graphics cache pointers, scene table base addresses, gameplay flags.

**Notable entries:**

- `< $069E, $A000 >` — VRAM address variable
- `< $003A, &scene_meta >` — scene metadata table pointer
- `< $0AC4, $FFFF >` — gameplay state sentinel

**Files:** `system_init.asm` (`SystemInitConstants`, 34 entries)

**blocks.json:** `constants_029E85` in `system_init` (171653–171791)

**Entry count:** 34 entries × 4 bytes = 136 bytes

---



### display-preset

10-byte scene display configuration preset. Defines PPU layer enables, color math, BG mode, tilemap addresses, and scroll behavior.


| Field | Type | Offset | Name        | Description                                                        |
| ----- | ---- | ------ | ----------- | ------------------------------------------------------------------ |
| 0     | Byte | +0     | tmts        | `$212C`/`$212E` — Main/sub screen layer enable (TM/TS)             |
| 1     | Byte | +1     | tmwtsw      | `$212D`/`$212F` — Window area mask for main/sub screen             |
| 2     | Byte | +2     | cgwsel      | `$2130` — Color math designation                                   |
| 3     | Byte | +3     | cgadsub     | `$2131` — Color math add/subtract select                           |
| 4     | Byte | +4     | layerFlags  | Layer reload flags, scroll mode, priority bits                     |
| 5     | Byte | +5     | tilemapAddr | BG1/BG2 tilemap VRAM addresses → `$2107`/`$2108`                   |
| 6     | Byte | +6     | bgMode      | `$2105` — BG mode and character size (e.g., `$09` = Mode 1, 16×16) |
| 7     | Byte | +7     | scrollFlags | Mosaic size, scroll mode, player sprite flag                       |
| 8     | Byte | +8     | reserved0   | Reserved (always `$00`)                                            |
| 9     | Byte | +9     | reserved1   | Reserved (always `$00`)                                            |


**Layout:** `[Byte × 10]`

**Usage:** `display-mode` scene command (`$02`) reads a preset index, looks up the record via `table_018000`, and applies all PPU settings. This is how each scene configures its visual rendering.

**Common tmts patterns:**

- `$17` = layers 1+2+4 (most scenes)
- `$15` = layers 1+2+3 (some indoor scenes)
- `$11` = layers 1+4 (special effects)

**Files:** `table_018000.asm` (47 presets), `scene_script.asm` (consumer: `SceneCmd_ConfigDisplay`)

**blocks.json:** `table_018000` (98304–98868, typed `&display-preset`)

**Entry count:** 47 pointer entries + 47 × 10-byte records = 564 bytes

---



### dma-channel

3-byte DMA/HDMA channel setup entry for hardware effects.


| Field | Type | Offset | Name     | Description                                                  |
| ----- | ---- | ------ | -------- | ------------------------------------------------------------ |
| 0     | Byte | +0     | channel  | DMA channel config nibble (e.g., `$70`, `$01`, `$60`)        |
| 1     | Byte | +1     | register | Target PPU register offset (e.g., `$1E`=window, `$20`=CGRAM) |
| 2     | Byte | +2     | data     | Transfer count or mode byte                                  |


**Layout:** `[Byte, Byte, Byte]`  
**Delimiter:** `0` (channel byte `$00` terminates)

**Usage:** Consumed by `COP [QueueHdma]` and `COP [QueueDma]` commands. Sets up windowing effects, palette cycling, color gradient HDMA, and general DMA transfers.

**Files:** 9 files with 215+ instances (inventory, diary menu, ending credits, boot logos, angel tunnel, space flight)

---



## Game Logic Structs



### gem-drop-threshold

Weighted RNG lookup entry for dark gem drop type selection. Formerly `reward-threshold`.


| Field | Type  | Offset | Name      | Description                                                   |
| ----- | ----- | ------ | --------- | ------------------------------------------------------------- |
| 0     | Word  | +0     | threshold | RNG threshold (`$0000`–`$0100`); compared against random byte |
| 1     | &Code | +2     | handler   | Same-bank code pointer to dark gem variant handler            |


**Layout:** `[Word, &Code]`

**Usage:** On enemy defeat (gemDropType=3+), `DarkGemDropSystem` generates a random byte and walks this table. The first entry whose threshold exceeds the RNG value wins, routing to its handler which spawns the corresponding dark point gem variant. Three table segments (indexed by player defense tier) select different probability distributions — stronger players see more DEF gems, weaker players see more HP gems.

**Dark gem variants (by chatPtr):**
- `$0083` (HP gem) — sprite frames `#04`/`#09`, increases HP on collection
- `$0084` (STR gem) — sprite frames `#05`/`#0A`, increases STR on collection
- `$0085` (DEF gem) — sprite frames `#06`/`#0B`, increases DEF on collection
- `$0086` (special gem) — sprite frames `#22`/`#35`, rare variant with distinct animation

**Tier selection** (in `SpawnDarkGemWeighted`):
- Tier 0 (weak): `playerMaxHp/4 ≥ playerHp` → more HP gems
- Tier 1 (medium): `playerMaxHp/2 ≥ playerHp` → balanced mix
- Tier 2 (strong): `playerMaxHp/2 < playerHp` → more DEF/special gems

**Files:** `DarkGemDropSystem.asm` (12 entries)

**Entry count:** 12 entries × 4 bytes = 48 bytes (3 groups of 4)

---



### boss-reward-range

Boss defeat scene range configuration. Each entry maps a boss scene to a range of scene indices whose enemy-clear stat rewards are retroactively granted on boss defeat.


| Field | Type | Offset | Name         | Description                                               |
| ----- | ---- | ------ | ------------ | --------------------------------------------------------- |
| 0     | Byte | +0     | sceneCurrent | Boss scene ID that triggers this catchup                  |
| 1     | Byte | +1     | sceneMin     | Start of scene range in `enemy_clear_reward_table`        |
| 2     | Byte | +2     | sceneMax     | End of scene range in `enemy_clear_reward_table`          |
| 3     | Byte | +3     | padding      | Always `$00` (tail byte)                                  |


**Layout:** `[Byte, Byte, Byte, Byte]`

**Usage:** `boss_clear_reward_handler` loops this table matching `$sceneCurrent`. On match, walks `enemy_clear_reward_table[sceneMin..sceneMax]` granting HP/STR/DEF bonuses for any scene whose `$0300` flag is not yet set. WRAM flags at offset `$0100` track boss-level catchup completion.

**Files:** `boss_clear_reward_handler.asm` (11 entries, 5 active + 6 placeholders)

**Entry count:** 11 entries × 4 bytes = 44 bytes

---



### statue-reward

Mystic Statue inventory reward slot configuration.


| Field | Type | Offset | Name       | Description                                      |
| ----- | ---- | ------ | ---------- | ------------------------------------------------ |
| 0     | Byte | +0     | flag       | WRAM flag index (tested/set to track collection) |
| 1     | Byte | +1     | rewardItem | Reward item ID (passed to `UpdateActorAnimation`)         |
| 2     | Byte | +2     | slotIndex  | Inventory slot index (compared against `$0AAC`)  |


**Layout:** `[Byte, Byte, Byte]`  
**Tail:** `1` (1 trailing byte after array)

**Usage:** Each of the 6 Mystic Statue reward slots maps a flag + item + slot. Both `statue_inventory_reward` (NPC) and `inventory_statue_slot` (UI) reference this table.

**Files:** `statue_inventory_reward.asm` (6 entries), `inventory_statue_slot.asm` (consumer)

**Entry count:** 6 entries × 3 bytes + 1 tail = 19 bytes

---



### spawn-trigger

Scene + player position match for transition triggers.


| Field | Type | Offset | Name    | Description                               |
| ----- | ---- | ------ | ------- | ----------------------------------------- |
| 0     | Word | +0     | sceneId | Scene ID to match against `$sceneCurrent` |
| 1     | Word | +2     | playerX | Player X position to match                |
| 2     | Word | +4     | playerY | Player Y position to match                |


**Layout:** `[Word, Word, Word]`  
**Delimiter:** `65535` (`$FFFF` in first word = end)

**Usage:** Hidden actors on scene load walk this table comparing all three fields. On match, they swap the player's handler to a transition routine.

**Instances:**

1. **Sky Garden** (`sg4D_jump_handler.asm`) — 26 entries, scenes `$4D`–`$54` → jump pad transition
2. **Angkor Wat** (`awBD_actor_08985E.asm`) — 5 entries, scenes `$BB`/`$BD` → zone transition

**Total:** 31 entries × 6 bytes = 186 bytes

---



### zone-trigger

Scene bounding-box region trigger for hazard spawning.


| Field | Type | Offset | Name    | Description                             |
| ----- | ---- | ------ | ------- | --------------------------------------- |
| 0     | Byte | +0     | sceneId | Scene ID to match                       |
| 1     | Byte | +1     | xMin    | Minimum X tile coordinate (×16 = pixel) |
| 2     | Byte | +2     | yMin    | Minimum Y tile coordinate               |
| 3     | Byte | +3     | xMax    | Maximum X tile coordinate               |
| 4     | Byte | +4     | yMax    | Maximum Y tile coordinate               |


**Layout:** `[Byte, Byte, Byte, Byte, Byte]`  
**Delimiter:** `255` (sceneId `$FF` = end)

**Usage:** Pyramid danger-slide actor checks player position against bounding boxes; on entry, spawns hazard via `COP [SpawnAfterFlags]`.

**Files:** `pyD9_actor_08C4EA.asm` (9 entries for scenes `$D9`/`$DB`)

**Entry count:** 9 entries × 5 bytes = 45 bytes

---



### screen-pos

Simple screen coordinate pair for UI positioning and sprite spawn offsets.


| Field | Type | Offset | Name | Description                  |
| ----- | ---- | ------ | ---- | ---------------------------- |
| 0     | Word | +0     | x    | Screen X coordinate (pixels) |
| 1     | Word | +2     | y    | Screen Y coordinate (pixels) |


**Layout:** `[Word, Word]`

**Usage contexts:**

1. **Inventory status cursor** — 3 entries at fixed X=`$98`
2. **Inventory grid columns** — 4 entries with row offset added at runtime
3. **Inventory slot positions** — 16 entries (4×4 grid)
4. **Castoth boss** — 18 entries across 3 arrays for attack projectile spawn positions

**Files:** `inventory_menu.asm` (23 entries), `ir29_castoth.asm` (18 entries)

**Total:** 41 entries × 4 bytes = 164 bytes

---



### event-block-def

8-byte event block definition for field tile reveals. Each entry describes a rectangular region of hidden off-screen tiles in the tilemap and a visible destination rectangle. When the corresponding event flag is set (typically after defeating specific enemies), the hidden tiles are copied to the visible destination, revealing paths, platforms, walls, or other terrain changes.


| Field | Type | Offset | Name      | Description                                          |
| ----- | ---- | ------ | --------- | ---------------------------------------------------- |
| 0     | Byte | +0     | sceneId   | Scene ID filter — entry only applies in this scene   |
| 1     | Byte | +1     | srcX      | Source column — hidden off-screen tile X (tile coords) |
| 2     | Byte | +2     | srcY      | Source row — hidden off-screen tile Y (tile coords)  |
| 3     | Byte | +3     | width     | Tile width of region to copy                         |
| 4     | Byte | +4     | height    | Tile height of region to copy                        |
| 5     | Byte | +5     | dstX      | Destination column — visible area X (tile coords)    |
| 6     | Byte | +6     | dstY      | Destination row — visible area Y (tile coords)       |
| 7     | Byte | +7     | layerFlag | Layer mode: `$00` = foreground only, nonzero = dual-layer (foreground + effect layer) |


**Layout:** `[Byte, Byte, Byte, Byte, Byte, Byte, Byte, Byte]`

**Usage:** `LookupEventBlock` indexes by ID × 8, verifies scene ID, then loads geometry into working registers for `SwapEventBlockTiles` or `AnimateEventBlock` to perform the tile copy. `SpawnFieldRevealEffect` also reads width/height/dstX/dstY from this table to compute the visual sparkle effect area and movement target.

**Files:** `event_block_table.asm` (158 entries), `event_blocks.asm`, `SpawnFieldRevealEffect.asm`

**blocks.json:** `event_block_table` (119758–121022)

**Entry count:** 158 entries × 8 bytes = 1,264 bytes

---



## Resource Structs



### body-entry

Character body form → sprite resource mapping.


| Field | Type    | Offset | Name        | Description                                           |
| ----- | ------- | ------ | ----------- | ----------------------------------------------------- |
| 0     | Address | +0     | animTable   | 3-byte long pointer to animation/sprite-set table     |
| 1     | @Binary | +3     | spritesheet | 3-byte long pointer to character spritesheet ROM data |


**Layout:** `[Address, @Binary]`

**Usage:** On form change (Will → Freedan → Shadow), the engine reads `body_table` to get animation and spritesheet pointers.

**Character forms:**


| Index | Character      | Animation Table | Spritesheet           |
| ----- | -------------- | --------------- | --------------------- |
| 0     | Will (default) | `table_158000`  | `will_sprites_1A8000` |
| 1     | Freedan        | `table_0E8000`  | `free_sprites_1AC000` |
| 2     | Shadow         | `table_148000`  | `shad_sprites_1BC000` |
| 3     | Shadow (alt)   | `table_148000`  | `shad_sprites_1BC000` |
| 4     | Will (variant) | `table_0F8000`  | `will_sprites_1A8000` |
| 5     | Ability FX     | `table_0FC000`  | `abil_sprites_1B8000` |
| 6     | Freedan FX     | `table_17A000`  | `free_fx_1C8000`      |
| 7     | Shadow FX      | `table_17B000`  | `shad_fx_1CA000`      |
| 8     | Shadow (3rd)   | `table_17C000`  | `shad_sprites_1BC000` |


**Files:** `body_table.asm` (9 entries), `actor_pool.asm`, `chunk_03BAE1.asm`

**blocks.json:** `body_table` (121201–121255)

---



### palette-bundle

Palette animation sequence header (6 bytes per entry). Data Crystal: "The indexed pointers in bank $16 point to palette bundle headers, which contain 6 bytes for every sequence in the bundle." A **bundle group** contains one or more of these headers, terminated by `numPalettes = $00`. 128 bundle groups are indexed from the pointer table at `$168000`.


| Field | Type  | Offset | Name              | Description                                                                                                                |
| ----- | ----- | ------ | ----------------- | -------------------------------------------------------------------------------------------------------------------------- |
| 0     | Byte  | +0     | numPalettes       | Number of palette writes (via `COP $39`/`PaletteStep`) before advancing to next header; `$00` = end of sequence list       |
| 1     | &Word | +1     | dataSourceAddress | Same-bank pointer to raw palette source bytes (BGR555 color data, not indices)                                              |
| 2     | Byte  | +3     | cgramTargetWord   | CGRAM word address for writes. Engine converts: `byteOffset = word × 2 + $0A00` in `$7F0A00` staging buffer. `$00` with `numBytesMinusOne = $02` triggers COLDATA path instead |
| 3     | Byte  | +4     | numBytesMinusOne  | Number of bytes to copy minus 1. E.g., `$0D` = 14 bytes = 7 SNES colors. Special: `$02` with `cgramTargetWord = $00` → 3-byte COLDATA (`$2132`) writes |
| 4     | Byte  | +5     | delayFrames       | Frames to wait after each palette write before next `PaletteStep` resumes                                                  |


**Layout:** `[Byte, &Word, Byte, Byte, Byte]` (6 bytes)  
**Terminator:** `numPalettes = $00`

**COP interface:**
- `COP $36` (`PaletteRestart`) — restart current sequence from first header
- `COP $37` (`PaletteStart`) — start new bundle by index
- `COP $38` (`PaletteStartLoop`) — start bundle with outer loop count
- `COP $39` (`PaletteStep`) — advance one timed write; halt until `delayFrames` expires
- `COP $3A` (`PaletteStepLoop`) — step with outer iteration counter

**Engine:** `LoadPaletteBundle` (load header into actor scratch), `DecompressGfxToVram` (apply write via WRAM trampoline → `$548B`)

**Common field values:**

| numPalettes | Typical use                                    |
| ----------- | ---------------------------------------------- |
| `$01`       | Single write per header (most entries, ~1,100) |
| `$08`       | 8-step local cycle before next header          |
| `$20`       | 32-write COLDATA fade                          |

| numBytesMinusOne | Bytes | Colors | Typical use          |
| ---------------- | ----- | ------ | -------------------- |
| `$17`            | 24    | 12     | Most common          |
| `$1F`            | 32    | 16     | Full 16-color row    |
| `$0D`            | 14    | 7      | Fire/water shimmer   |
| `$02`            | 3     | —      | COLDATA special case |

| delayFrames | Effect                    |
| ----------- | ------------------------- |
| `$00`       | Every engine tick          |
| `$01`–`$03` | Fast flicker/cycling       |
| `$04`–`$07` | Slower ambient cycles      |
| `$5F`       | Very slow fade (~1.5 sec) |

**COLDATA special case:** When `cgramTargetWord = $00` and `numBytesMinusOne = $02`, the engine writes 3-byte COLDATA (`$2132`) component values instead of CGRAM staging. Data bytes use SNES COLDATA bit layout (bits 7–5 = component select). Used for backdrop/color-math fades.

**Palette overlap:** Data Crystal: "Palette source data within a bundle can overlap. This is a common design for e.g. wave or flame effects, where a small number of colors are rolled cyclically through CGRAM."

**Usage:** Drives per-frame palette cycling for ambient effects (water shimmer, fire flicker, crystal glow, lava, transparency fades). A thinker-type actor usually handles palette bundles. Common handlers: `$80B519` (run first sequence once, then die) and `$80B520` (run first sequence repeatedly forever). Thinkers are efficiently spawned via `COP $3B` with `Param` = palette bundle index.

**Files:** `palette_bundles.asm` (128 groups, 1,400+ entries)

**blocks.json:** `palette_bundles` (1474560–1497132, typed `&palette-bundle`)

---



### sprite-set / sprite-group / sprite-part

Hierarchical sprite definition system:

**sprite-set:** Indexed animation frames for an entity.


| Field | Type          | Name       | Description                               |
| ----- | ------------- | ---------- | ----------------------------------------- |
| 0     | Word          | frameCount | Number of animation frames in this entry  |
| 1     | &sprite-group | groups     | Same-bank pointer to first sprite group   |


**Terminator:** `frameCount = $0000` (null word, not `$FFFF`)

**sprite-group:** 13-byte header + variable-length parts.


| Field | Type        | Description                                 |
| ----- | ----------- | ------------------------------------------- |
| 0–12  | Byte × 13   | Group metadata (bounds, flags, tile counts) |
| 13    | sprite-part | Variable number of OAM tile entries         |


**sprite-part:** 6-byte OAM tile definition.


| Field | Type     | Description                              |
| ----- | -------- | ---------------------------------------- |
| 0–4   | Byte × 5 | Position offsets, tile index, attributes |
| 5     | Word     | VRAM tile reference                      |


**blocks.json:** 17 blocks typed `&sprite-set` (`table_0E8000`, `table_0EDA00`, `table_0EE000`, `table_0F8000`, `table_0FC000`, `inventory_spritemap`, etc.)

---



### diary-entry

Diary menu warp destination: location name + warp coordinates.


| Field | Type       | Name     | Description                                                  |
| ----- | ---------- | -------- | ------------------------------------------------------------ |
| 0     | DialogString | name     | Location name text (variable-width encoded, `$CA`-delimited) |
| 1     | Binary     | warpData | Packed warp word: scene ID + X/Y coordinates                 |


**Layout:** `[DialogString, Binary]`

**Usage:** 256 index entries → ~25 unique diary records. Each contains display name and packed warp coordinates for gameplay resume.

**Locations:** South Cape, Edward's Prison, Itory, Freejia, Diamond Mine, Sky Garden, Seaside Palace, Mu, Angel Village, Watermia, Great Wall, Euro, Mt. Temple, Natives' Village, Angkor Wat, Dao, Pyramid, Babel Tower, etc.

**Files:** `strings_0BF706.asm`, `sFA_diary_menu.asm`

**blocks.json:** `strings_0BF706` (typed `&diary-entry`)

---



### map-label

Overworld location name entry: scene ID key + pointer to sprite-rendered name string.


| Field | Type          | Offset | Name    | Description                                        |
| ----- | ------------- | ------ | ------- | -------------------------------------------------- |
| 0     | Byte          | +0     | mapId   | Map/scene ID key; `$00` = end of table             |
| 1     | &SpriteString | +1     | namePtr | Same-bank pointer to sprite-rendered location name |


**Layout:** `[Byte, &SpriteString]`  
**Delimiter:** `0` (mapId `$00` = end)

**Usage:** On the overworld map, the engine searches this table by current map ID and renders the matching sprite string.

**Files:** `world_map_names.asm` (37 entries)

**blocks.json:** `world_map_names` (242132–242689, typed `map-label`)

---



## Warp Structs



### warp-def

Composite warp definition containing both scene warps and stair warps.


| Field | Type       | Name       | Description                                     |
| ----- | ---------- | ---------- | ----------------------------------------------- |
| 0     | scene-warp | sceneWarps | Delimiter-terminated list of scene warp entries |
| 1     | stair-warp | stairWarps | Delimiter-terminated list of stair warp entries |


**Layout:** `[scene-warp, stair-warp]`

**blocks.json:** `scene_warps` (typed `&warp-def`)

---



### scene-warp

Scene transition warp entry (door/exit).


| Field | Type | Offset | Name      | Description                        |
| ----- | ---- | ------ | --------- | ---------------------------------- |
| 0     | Byte | +0     | srcTileX  | Source trigger tile X              |
| 1     | Byte | +1     | srcTileY  | Source trigger tile Y              |
| 2     | Byte | +2     | width     | Trigger width (tiles)              |
| 3     | Byte | +3     | height    | Trigger height (tiles)             |
| 4     | Byte | +4     | destScene | Destination scene ID               |
| 5     | Word | +5     | destX     | Destination X coordinate (pixels)  |
| 6     | Word | +7     | destY     | Destination Y coordinate (pixels)  |
| 7     | Byte | +9     | facing    | Player facing direction after warp |
| 8     | Word | +10    | flags     | Warp flags                         |


**Layout:** `[Byte, Byte, Byte, Byte, Byte, Word, Word, Byte, Word]` (12 bytes, stride `$0C`)  
**Delimiter:** Byte +0 with sign bit set (`BMI` / ≥ `$80`) terminates the scene-warp list

---



### stair-warp

Stair transition warp entry.


| Field | Type | Offset | Name      | Description                                 |
| ----- | ---- | ------ | --------- | ------------------------------------------- |
| 0     | Byte | +0     | srcTileX  | Source trigger tile X                       |
| 1     | Byte | +1     | srcTileY  | Source trigger tile Y                       |
| 2     | Byte | +2     | width     | Trigger width                               |
| 3     | Byte | +3     | height    | Trigger height                              |
| 4     | Word | +4     | destScene | Destination scene ID (word for stair warps) |
| 5     | Word | +6     | destX     | Destination X coordinate                    |
| 6     | Word | +8     | destY     | Destination Y coordinate                    |
| 7     | Byte | +10    | facing    | Player facing direction                     |
| 8     | Word | +11    | flags     | Warp flags                                  |


**Layout:** `[Byte, Byte, Byte, Byte, Word, Word, Word, Byte, Word]` (13 bytes, stride `$0D`)  
**Delimiter:** Byte +0 with sign bit set (`BMI` / ≥ `$80`) terminates the stair-warp list

---



## Specialized Structs



### conveyor-index / conveyor-zone

Scene-indexed conveyor belt zone system. Only used for the Solid Arm boss lair.

**conveyor-index** — Scene lookup entry:


| Field | Type           | Offset | Name    | Description                        |
| ----- | -------------- | ------ | ------- | ---------------------------------- |
| 0     | Byte           | +0     | sceneId | Scene ID key; `$00` = end of index |
| 1     | &conveyor-zone | +1     | zones   | Same-bank pointer to zone array    |


**Layout:** `[Byte, &conveyor-zone]`  
**Delimiter:** `0`

**conveyor-zone** — Belt zone definition:


| Field | Type | Offset | Name     | Description                                                                            |
| ----- | ---- | ------ | -------- | -------------------------------------------------------------------------------------- |
| 0     | Byte | +0     | minTileX | Minimum tile X bound. Also serves as end-of-list marker if bit 7 set (≥`$80` = end)   |
| 1     | Byte | +1     | minTileY | Minimum tile Y bound                                                                   |
| 2     | Byte | +2     | maxTileX | Maximum tile X bound                                                                   |
| 3     | Byte | +3     | maxTileY | Maximum tile Y bound                                                                   |
| 4     | Byte | +4     | velX     | Signed X velocity on overlap (sign-extended to 16-bit)                                 |
| 5     | Byte | +5     | velY     | Signed Y velocity on overlap (sign-extended to 16-bit)                                 |


**Layout:** `[Byte, Byte, Byte, Byte, Byte, Byte]`  
**Delimiter:** byte +0 ≥ `$80` (`BMI` check in consumer)

**Consumer logic:** Tests `minTileX ≤ playerXTile`, `minTileY ≤ playerYTile`, `maxTileX ≥ playerXTile`, `maxTileY ≥ playerYTile`. On overlap, sign-extends `velX`/`velY` and adds to `$extVelocityX`/`$extVelocityY`. Zone stride is 6 bytes (`INX` × 6).

**Usage:** Conveyor belt actor searches by scene ID, tests each zone's AABB against player position, and applies velocity to `$extVelocityX`/`$extVelocityY`.

**Files:** `btEA_actor_0ADC55.asm` (2 scenes, 4 zones)

**blocks.json:** `sc_ix_0ADCFE` + `sc_data_0ADD05`

---



## Usage Statistics Summary


| Struct               | Entry Count | Bytes    | Defining Files | Consuming Files | blocks.json Parts |
| -------------------- | ----------- | -------- | -------------- | --------------- | ----------------- |
| `actor-def`          | 400+        | Variable | 400+           | —               | 652               |
| `thinker-def`        | ~40         | Variable | ~40            | —               | 58                |
| `enemy-stats`        | 110         | 440      | 1              | 40+             | 1                 |
| `delta-node`         | 1,173 nodes | 4,862    | 1              | 4               | 1                 |
| `palette-bundle`     | 1,400+      | ~22,500  | 1              | 1               | 1                 |
| `event-block-def`    | 158         | 1,264    | 1              | 2               | 1                 |
| `diary-entry`        | ~25 unique  | ~850     | 1              | 1               | 1                 |
| `display-preset`     | 47          | 564      | 1              | 1               | 1                 |
| `route-step`         | 251         | ~1,100   | 1              | 1               | 1                 |
| `dma-channel`        | 215+        | ~650     | 9              | —               | —                 |
| `register-init`      | 76          | 230      | 1              | 1               | 1                 |
| `screen-pos`         | 41          | 164      | 2              | —               | 3                 |
| `map-label`          | 37          | 111+     | 1              | 1               | 1                 |
| `wram-init`          | 34          | 138      | 1              | 1               | 1                 |
| `spawn-trigger`      | 31          | 186      | 2              | —               | —                 |
| `sprite-set`         | —           | —        | —              | —               | 17                |
| `camera-keyframe`    | ~125        | ~250     | 3              | —               | 2                 |
| `gem-drop-threshold`   | 12          | 48       | 1              | —               | —                 |
| `boss-reward-range`  | 11          | 44       | 1              | —               | —                 |
| `zone-trigger`       | 9           | 45       | 1              | —               | —                 |
| `body-entry`         | 9           | 54       | 1              | 2               | 1                 |
| `direction-velocity` | 9           | 18       | 1              | 2               | 1                 |
| `statue-reward`      | 6           | 19       | 1              | 1               | —                 |
| `conveyor-index`     | 2           | 7        | 1              | —               | 1                 |
| `conveyor-zone`      | 4           | 25       | 1              | —               | 1                 |
| `ramp-motion`        | 2           | 102      | 1              | 1               | 1                 |
| `char-tiles`         | 1           | varies   | 1              | 1               | —                 |
| `meta-skip`          | 0           | 0        | 0              | —               | —                 |




### Scene Meta Command Statistics (scene_meta.asm)


| Command        | Discriminator | Count |
| -------------- | ------------- | ----- |
| `tilemap`      | 6             | 383   |
| `bitmap`       | 3             | 319   |
| `tileset`      | 5             | 300   |
| `palette`      | 4             | 278   |
| `music`        | 17            | 234   |
| `display-mode` | 2             | 231   |
| `jump`         | 21            | 176   |
| `spritemap`    | 16            | 56    |
| `label`        | 20            | 56    |
| `branch`       | 19            | 18    |
| `char-tiles`   | 23            | 1     |
| `meta-skip`    | 14            | 0     |


---



## Appendix: Actor WRAM Layout

For the complete actor WRAM memory map (direct page `$7E:00`–`$2F`, extended fields `$7F:0000`–`$002F`, callback tables `$7F:1000`–`$101F`), see **[wram-memory-map.md](wram-memory-map.md)** §2.11, §4.1, and §4.4.

### Spawn Struct → WRAM Mapping (Quick Reference)

| Struct Field                      | → WRAM Address  | Notes                                          |
| --------------------------------- | --------------- | ---------------------------------------------- |
| `actor-def` byte +0 (`spriteId`)  | `$7E:28`        | Starting sprite index                          |
| `actor-def` byte +1 (`flags10Lo`) | `$7E:10` (lo)   | OR'd with `$4000` at spawn                     |
| `actor-spawn` `param` (odd)       | `$7E:0E`        | Right-shifted 1 bit                            |
| `actor-spawn` `param` (even)      | `$7E:0E`        | Bit 3 cleared, used as OAM high byte           |
| `actor-spawn` `spawnX`            | `$7E:14`        | ×16 (tile → pixel conversion)                  |
| `actor-spawn` `spawnY`            | `$7E:16`        | ×16 (tile → pixel conversion)                  |
| `enemy-spawn` `statsIndex`        | `$7F:20`        | ×4 + `$81ABF0` → stats pointer                 |
| `enemy-spawn` `enemyNum`          | `$7F:22`        | Kill tracking flag index                       |
| `enemy-spawn` `deathActionIdx`    | `$7F:24`        | Map rearrangement on death                     |
| `enemy-stats` `hp`                | `$7F:26`        | Initial HP value                               |
| `thinker-spawn` `param`           | Actor WRAM      | Thinker-specific (e.g., palette bundle index)  |

**Source:** [Data Crystal — Illusion of Gaia Notes](https://datacrystal.tcrf.net/wiki/Illusion_of_Gaia/Notes)


