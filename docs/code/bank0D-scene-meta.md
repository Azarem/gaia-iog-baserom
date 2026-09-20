# Bank $0D — Scene Metadata Table

*Part of the IOG Code Bank Documentation Suite*

> Defines every scene's graphical asset manifest — display mode, tile graphics, tilemaps, palettes, sprite maps, and music — consumed by the scene script interpreter during scene transitions.

**Source:** [`scene_meta.asm`](../../extracted/tables/scene_meta.asm)
**ROM range:** `$0D:8000`–`$0D:AFFF` (file offset `$D8000`–`$DAFFF`, 12,287 bytes)
**Bank range:** `$0D:8000`–`$0D:FFFF` (32 KB total; scene_meta occupies the first 37.5%, remainder is unstructured binary data)

---

## Overview

The `scene_meta` block is the game's master scene resource table. Every scene in Illusion of Gaia — from South Cape to the Comet interior — has an entry here that declares which graphical assets to load during a scene transition. When the player enters a new area, the scene script interpreter in Bank $02 (`SceneScriptMain` in `scene_script.asm`) reads the current scene's metadata entry and executes each command sequentially to configure the PPU, decompress tile graphics, transfer tilemaps and palettes, load sprite sheets, and start music playback.

The block is declared in `blocks.json` with the type `scene-meta` and two postprocessing steps that transform the raw struct data into the extracted ASM output:

```json
"scene_meta": {
  "start": 884736,
  "end": 897023,
  "type": "scene-meta",
  "postProcess": "Lookup(0,1)&&Label(label,meta_label)",
  "movable": true
}
```

The `Lookup(0,1)` step builds a 256-entry lookup table (`scene_meta_list`) that maps scene IDs to their metadata entries. The `Label(label,meta_label)` step extracts inline `label` struct instances from the command streams and builds a secondary lookup table (`meta_label_list`) for cross-scene asset sharing.

**Related:** [Bank $02 Scene Script](bank2-code-analysis.md) · [Bank $0C Scene Spawn Tables](bank0C-scene-spawn-tables-comet.md)

---

## Bank Memory Map

```
$0D:8000 ┌──────────────────────────────────────┐
         │ scene_meta_list (lookup table)        │  512 bytes (256 × 2-byte pointers)
$0D:8200 ├──────────────────────────────────────┤
         │ Scene metadata entries                │  ~11,647 bytes
         │   scene_meta_0000 ... scene_meta_00FF │  (231 valid entries, 25 null slots)
         │   Each entry: variable-length command │
         │   stream terminated by implicit end   │
$0D:AEFE ├──────────────────────────────────────┤
         │ meta_label_list (label lookup table)  │  128 bytes (64 × 2-byte pointers)
$0D:AF7E ├──────────────────────────────────────┤
         │                                      │
$0D:AFFF │ End of scene_meta block              │
$0D:B000 ├──────────────────────────────────────┤
         │ Unstructured binary data              │  20,480 bytes (20 KB)
         │ (compressed graphics / tilemaps)      │
$0D:FFFF └──────────────────────────────────────┘
```

---

## Data Structure Definition

### Root Type: `scene-meta`

Defined in `structs.json`:

```json
"scene-meta": { "types": [ "Word", "meta<>" ] }
```

Each `scene-meta` entry consists of:
1. **Scene ID** (`Word`, 2 bytes) — the numeric scene identifier (matches scene IDs in `groups.json`)
2. **Command stream** (`meta<>`) — a variable-length sequence of discriminated command structs

### Meta Command Base Type: `meta<>`

```json
"meta<>": { "discriminator": 0, "delimiter": 0 }
```

The `meta<>` type is a discriminated union — each command begins with a 1-byte **opcode** (the discriminator field at index 0) that identifies the command type, followed by type-specific operand bytes. The stream is terminated by a delimiter byte of `$00`.

### Command Types (Discriminated Subtypes of `meta<>`)

| Opcode | Name | Struct Types | Description |
|--------|------|-------------|-------------|
| `$02` | `display-mode` | `[Byte]` | PPU display configuration preset index |
| `$03` | `bitmap` | `[Byte, Byte, Byte, @Binary, Byte]` | Compressed tile graphics (BG/sprite) |
| `$04` | `palette` | `[Byte, Byte, Byte, @Binary]` | Color palette data |
| `$05` | `tileset` | `[Byte, Byte, Byte, Byte, @Binary]` | Tileset definition |
| `$06` | `tilemap` | `[Byte, @Binary]` | Tilemap layout data |
| `$0E` | `meta-skip` | `[Byte, Byte, Byte]` | Skip 3 bytes (padding/reserved) |
| `$10` | `spritemap` | `[Word, Byte, @Binary]` | Sprite composition map |
| `$11` | `music` | `[Byte, Byte, @Binary]` | SPC music track data |
| `$13` | `branch` | `[Byte, Byte]` | Conditional execution (flag test + label jump) |
| `$14` | `label` | `[Byte]` | Named jump target within the command stream |
| `$15` | `jump` | `[Byte]` | Unconditional jump to a label in another scene |
| `$17` | `char-tiles` | `[Byte, @Binary]` | Character/object tile graphics |

### Command Details

#### `display-mode` (opcode `$02`)

```
$02 <preset_index:Byte>
```

Selects a PPU display configuration from `display_preset_table` (Bank $02, `table_018000`). Each preset is a 10-byte entry that configures: TM/TS (main/sub screen layer enable), TMW/TSW (window masks), CGWSEL/CGADSUB (color math), BGMODE, BG tilemap base addresses (BG1SC/BG2SC), layer priority flag, scroll mode flags, and visible screen height ($E0 or $100 scanlines).

**Every scene entry begins with a `display-mode` command.** This is always the first command in the stream — the scene script interpreter depends on PPU configuration being established before any graphics data is loaded.

#### `bitmap` (opcode `$03`)

```
$03 <vram_start:Byte> <vram_end:Byte> <flags:Byte> <source:@Binary(3 bytes)> <mode:Byte>
```

Loads compressed tile graphics from ROM to VRAM. The VRAM start/end bytes are scaled (×$200) to define the destination region. The `flags` byte controls cache slot selection and VRAM page offset. The `mode` byte selects the loading path:
- Mode `$00`: Standard 2bpp tile strip (BG tiles for one page)
- Mode `$01`: Double-size tile strip (two pages)
- Mode `$02`: Triple-size tile strip
- Mode `$03`: Full 4bpp page load (16KB to VRAM $2000)

The source is a 3-byte ROM pointer to QuintetLZ-compressed data. The scene script engine runs a 4-entry graphics cache (`$0084`–`$008F`) — if the same source was recently loaded, it restores from a WRAM ring buffer instead of re-decompressing.

#### `palette` (opcode `$04`)

```
$04 <start_color:Byte> <count:Byte> <cgram_offset:Byte> <source:@Binary(3 bytes)>
```

Loads palette color data. The start color, count, and CGRAM offset define which palette slots receive data. The source pointer references the palette data in ROM.

#### `tileset` (opcode `$05`)

```
$05 <start:Byte> <end:Byte> <offset:Byte> <layer:Byte> <source:@Binary(3 bytes)>
```

Loads a tileset definition. Operates on the dual-layer tilemap system — the `layer` byte selects layer 0 (primary BG) or layer 1 (overlay/effect BG). Combined with `tilemap` commands to define the complete map geometry.

#### `tilemap` (opcode `$06`)

```
$06 <layer:Byte> <source:@Binary(3 bytes)>
```

Loads tilemap layout data for a BG layer. The `layer` byte selects `$01` (layer 0 at `$7E:A000`) or `$02` (layer 1 at `$7E:C000`). Source data is decompressed and written to WRAM, then attributes are rebuilt for SNES-format palette/priority bytes.

#### `spritemap` (opcode `$10`)

```
$10 <tile_data_size:Word> <flags:Byte> <source:@Binary(3 bytes)>
```

Loads sprite tile graphics and composition data. The 16-bit size field specifies the decompressed sprite tile data size. Source cache slot `$0684` prevents redundant loads.

#### `music` (opcode `$11`)

```
$11 <room_group:Byte> <parent_actor:Byte> <source:@Binary(3 bytes)>
```

Transfers SPC700 music data via the IPL handshake protocol. The `room_group` byte gates loading — if the current `musicRoomGroup` already matches, the transfer is skipped entirely, preventing redundant multi-second SPC transfers when moving between rooms in the same music region. The `parent_actor` byte controls whether playback starts (nonzero = play, zero = stop).

#### `branch` (opcode `$13`)

```
$13 <flag_index:Byte> <label_id:Byte>
```

Conditional execution gate. Tests a game event flag via `TestFlagRaw` — if the flag is **set**, jumps execution to the specified `label_id` (via `SkipScriptCommands`), skipping the remaining commands in the current block. If **clear**, execution continues normally with the next command. Used for scenes that need different asset configurations depending on game state (e.g., Will's house loading different actors before/after a story event).

#### `label` (opcode `$14`)

```
$14 <label_id:Byte>
```

Declares a named jump target within the command stream. Labels serve two purposes:
1. **Branch targets** — `branch` commands jump to labels within the same scene
2. **Cross-scene sharing** — `jump` commands reference labels in other scenes to reuse asset definitions

Labels are extracted by the `Label(label,meta_label)` postprocessor into the `meta_label_list` lookup table.

#### `jump` (opcode `$15`)

```
$15 <label_id:Byte>
```

Unconditional jump to a label. The `SkipScriptCommands` routine uses the `meta_label_list` lookup table to resolve the label ID to an offset within the scene_meta data, then continues execution from that point. This is the primary mechanism for **asset sharing** between scenes — instead of duplicating bitmap/tileset/palette commands, a scene jumps to a shared label defined in another scene's metadata entry.

#### `char-tiles` (opcode `$17`)

```
$17 <vram_page:Byte> <source:@Binary(3 bytes)>
```

Loads character or object tile graphics with flexible VRAM targeting. The VRAM page byte determines the destination: bit 7 set = absolute VRAM address `(page & $7F) × 4`, bit 0 = VRAM `$1000`, bit 1 = VRAM `$1800`.

---

## Postprocessing Pipeline

The raw ROM data is a flat stream of `scene-meta` structs — each entry is `[scene_id:u16, command_bytes..., $00]` packed sequentially. The engine applies two postprocessing steps during extraction:

### Step 1: `Lookup(0,1)` — Scene Lookup Table Generation

The `Lookup` postprocessor reads each `scene-meta` entry, extracts field 0 (the scene ID word) as the key and field 1 (the command stream) as the value. It builds a 256-entry lookup table (`scene_meta_list`) where each slot is a 2-byte offset pointer to the corresponding scene's metadata entry.

```
scene_meta_list [
  &scene_meta_0000   ;00 — Font/system init
  &scene_meta_0001   ;01 — South Cape
  &scene_meta_0002   ;02 — Coastal Cave
  ...
  #$0000             ;09 — null (unused scene ID)
  ...
  &scene_meta_00FF   ;FF — Inventory
]
```

- Valid entries contain `&scene_meta_XXXX` — a 2-byte offset to the entry within the same bank
- Null entries contain `#$0000` — scene ID is unused (25 null slots out of 256)
- The lookup table occupies exactly 512 bytes (256 × 2)

### Step 2: `Label(label,meta_label)` — Label Lookup Table Generation

The `Label` postprocessor scans all command streams for `label` structs (opcode `$14`). For each label found, it records the label ID and its position within the data. It then builds the `meta_label_list` — a 64-entry lookup table (IDs `$00`–`$3F`) mapping label IDs to byte offsets.

```
meta_label_list [
  #$0000             ;00 — unused
  &meta_label_01     ;01 — South Cape interior shared assets
  &meta_label_02     ;02 — Prison/aqueduct shared assets
  &meta_label_03     ;03 — Cave shared assets
  ...
  &meta_label_3F     ;3F — Pyramid shared enemy sprites
]
```

The label table enables `jump` commands to efficiently redirect execution into any labeled position across all scene entries without a linear scan.

---

## Original Layout (Unpatched ROM)

In the original game, the scene script interpreter uses a **linear scan** to find the current scene's metadata entry:

### `FindCurrentScene` — Original Algorithm

```
FindCurrentScene:
  Y = 0                         ; Start at beginning of scene data
loop:
  scene_id = read_word([$3A], Y) ; Read 2-byte scene ID
  Y += 2
  if scene_id == sceneCurrent:
    return                       ; Y now points to first command byte
  ; Skip commands until next $00 delimiter
  scan each opcode, advance Y by operand size
  goto loop
```

The original `FindCurrentScene` starts at the beginning of the packed scene data (pointed to by `$3A`) and reads each entry's 2-byte scene ID. On mismatch, it must parse through every command in the entry — determining each command's operand size via a fall-through `INY` cascade — to find the `$00` delimiter marking the next entry. This repeats until the target scene is found.

**Performance characteristics:**
- **Best case:** Scene ID `$00` — found immediately (zero entries skipped)
- **Worst case:** Scene ID `$FF` — must scan through all 231 valid entries before reaching the end
- **Average case:** Must parse ~115 entries' worth of variable-length command streams
- Each scan step requires opcode comparison and variable-skip logic (up to 8 comparisons per command byte)

### `SkipScriptCommands` — Original Algorithm

The original `SkipScriptCommands` (used by `jump` and `branch` commands) performs the **same linear scan** — it reads a label ID, then walks through entries from the beginning comparing label opcodes until it finds a matching label struct. This means every `jump` command during scene loading triggers a full re-scan of the packed data.

**The combined cost:** A single scene load may call `FindCurrentScene` once (linear scan to find the scene) plus one or more `SkipScriptCommands` calls (linear scan per `jump` command). For scenes with shared assets — which is the majority of the game — this means **multiple linear scans per transition**.

---

## Revised Layout (SceneLoadPatch)

The `SceneLoadPatch.patch.asm` fundamentally changes both `FindCurrentScene` and `SkipScriptCommands` from linear scans to **O(1) direct-indexed lookups** using the two lookup tables generated by the postprocessor.

### Patched `FindCurrentScene` — Direct Index

```asm
FindCurrentScene! {
    REP #$20
    LDA $scene_current      ; Load current scene ID
    ASL                     ; × 2 for word-sized table index
    TAY
    LDA [$3A], Y            ; Read pointer from scene_meta_list[scene_id]
    SEC
    SBC $3A                 ; Convert absolute pointer to relative offset
    TAY                     ; Y = offset to first command byte
    SEP #$20
    RTS
}
```

Instead of scanning, the patched version:
1. Takes `sceneCurrent` (the target scene ID)
2. Doubles it (`ASL`) to index into the 2-byte-per-entry `scene_meta_list`
3. Reads the entry pointer directly from `[$3A] + scene_id × 2`
4. Converts to a relative offset by subtracting the table base (`$3A`)

**This is a constant-time operation** — regardless of which scene is loaded, it takes exactly 9 instructions with no loops or branching.

### Patched `SkipScriptCommands` — Direct Label Lookup

```asm
SkipScriptCommands! {
    JSR $&ReadScriptByte    ; Read the label ID from the jump command
    REP #$20
    ASL                     ; × 2 for word-sized table index
    TAX
    LDA $@meta_label_list, X ; Read pointer from meta_label_list[label_id]
    SEC
    SBC $3A                 ; Convert to relative offset
    TAY                     ; Y = offset to labeled position
    SEP #$20
    RTS
}
```

Instead of scanning for matching label opcodes, the patched version:
1. Reads the label ID from the script stream
2. Doubles it (`ASL`) to index into `meta_label_list`
3. Reads the label's offset pointer directly via long addressing (`$@meta_label_list`)
4. Converts to relative offset

**This is also constant-time** — every `jump` command resolves instantly regardless of where the target label is in the data.

### Performance Comparison

| Operation | Original | Patched | Improvement |
|-----------|----------|---------|-------------|
| FindCurrentScene | O(n) — scan up to 231 entries | O(1) — direct table lookup | Eliminates ~100+ opcode parses per transition |
| SkipScriptCommands | O(n) — scan packed data for label | O(1) — direct table lookup | Eliminates linear scan per jump/branch |
| Memory overhead | 0 bytes | 640 bytes (512 + 128) | Lookup tables occupy <1% of bank |
| Scene load latency | Variable (worst case: ~2000+ byte scan) | Constant (~20 cycles) | Consistent fast loads for all scenes |

### How the Patch Integrates

The patch file uses `!` suffixes to **replace** the original routines:
- `FindCurrentScene!` replaces the original with the table-indexed version
- `SkipScriptCommands!` replaces the original linear scanner
- All intermediate labels (`loc_028CF5!`, `loc_028CFF!`, etc.) are stubbed out since the linear scan code is entirely eliminated

The `?INCLUDE 'scene_meta'` directive links the patch to the scene_meta data, giving it access to `$@meta_label_list` via long addressing for cross-bank label resolution.

---

## Asset Sharing via Labels and Jumps

The label/jump system is a critical memory optimization. Many scenes share the same tile graphics, palettes, and tilesets — loading duplicate data would waste both ROM space (duplicate commands) and CPU time (redundant decompression). Instead, one scene defines the shared assets under a label, and other scenes `jump` to that label.

### Example: South Cape Interior Scenes

Scene `$03` (Lance's house) defines the shared South Cape interior assets under `meta_label_01`:

```
scene_meta_0003 [
  display-mode < #01 >
  music < #1C, #00, @bgm_lively_city_by_the_sea >
  tilemap < #01, @map_sc03 >
  tilemap < #02, @map_southcape_interior_effect >
  palette < #00, #70, #10, @pal_southcape_interior_2 >
  meta_label_01:              ← label definition
  bitmap < #00, #10, #00, @gfx_southcape_interior, #00 >
  bitmap < #00, #10, #10, @gfx_southcape_effect, #00 >
  tileset < #00, #20, #00, #01, @set_southcape_interior >
  tileset < #00, #20, #00, #02, @set_southcape_effect >
  jump < #3E >
]
```

Scenes `$04`, `$05`, `$07` (Eric's house, Seth's house, Chef's house) then jump to this label:

```
scene_meta_0005 [
  display-mode < #01 >
  music < #1C, #00, @bgm_lively_city_by_the_sea >
  palette < #00, #70, #10, @pal_southcape_interior >
  tilemap < #01, @map_sc05 >
  tilemap < #02, @map_southcape_interior_effect >
  jump < #01 >                ← jumps to meta_label_01 in scene $03
]
```

Each interior scene loads only its unique palette and tilemaps, then jumps to the shared label for the common bitmap/tileset data. This pattern reduces both ROM usage and load time.

### Example: Conditional Branching

Scene `$06` (Will's house) uses `branch` for story-dependent asset loading:

```
scene_meta_0006 [
  display-mode < #01 >
  music < #1C, #00, @bgm_lively_city_by_the_sea >
  music < #1B, #01, @bgm_no_music >
  palette < #00, #70, #10, @pal_southcape_interior_3 >
  tilemap < #01, @map_sc06 >
  tilemap < #02, @map_sc06_effect >
  branch < #4C, #01 >        ← if flag $4C set, jump to label $07
  branch < #21, #23 >        ← if flag $21 set, jump to label $23
  meta_label_07:
  bitmap < ... castle_actors ... >
  palette < ... castle_actors ... >
  spritemap < ... castle_actors ... >
  jump < #24 >
  meta_label_23:
  bitmap < ... main_characters ... >
  palette < ... main_characters ... >
  spritemap < ... main_characters ... >
  meta_label_24:
  bitmap < ... southcape_interior ... >
  ...
]
```

The branch commands test game progress flags to select which sprite set to load — early game gets main characters, later game gets castle actors.

---

## Scene Coverage Summary

The 231 valid scene entries span every location in the game:

| Scene Range | Location Group | Count | Notes |
|-------------|---------------|-------|-------|
| `$00` | System (font init) | 1 | Minimal — display-mode + bitmap + palette only |
| `$01`–`$08` | South Cape | 8 | Heavy label sharing via `meta_label_01` |
| `$0A`–`$13` | Edward's Castle / Aqueduct | 10 | Shared via `meta_label_02`, `meta_label_30` |
| `$14` | Unused | 1 | `display-mode < #00 >` only |
| `$15`–`$1C` | Itory / Moon Tribe | 8 | Shared via `meta_label_04`, `meta_label_08` |
| `$1D`–`$29` | Incan Ruins / Larai Cliff | 13 | Shared via `meta_label_05`, `meta_label_06` |
| `$2A`–`$2F` | Gold Ship | 6 | |
| `$30`–`$3C` | Freejia | 13 | |
| `$3D`–`$47` | Diamond Mine | 11 | |
| `$49`–`$55` | Nazca / Sky Garden | 12 | |
| `$58`–`$67` | Seaside Palace / Mu | 16 | |
| `$68`–`$75` | Angel Village / Tunnels | 14 | |
| `$78`–`$7F` | Watermia / Great Wall | 8 | |
| `$82`–`$8B` | Great Wall (cont.) | 10 | |
| `$8C`–`$90` | Prologue / Ending | 5 | |
| `$91`–`$9D` | Euro / Mt. Temple | 13 | |
| `$A0`–`$A9` | Mt. Temple (cont.) | 10 | |
| `$AC`–`$C0` | Native / Angkor Wat | 20 | |
| `$C3`–`$DD` | Dao / Pyramid | 27 | |
| `$DE`–`$EA` | Babel Tower / Comet | 13 | |
| `$F0`–`$FF` | Mansion / Credits / System | 14 | Title, inventory, world map, credits |

---

## Relationship to Other Systems

### Scene Script Interpreter (Bank $02)

`SceneScriptMain` in `scene_script.asm` is the consumer of this data. It:
1. Sets `$3A` to point to the scene_meta data in bank $0D
2. Calls `FindCurrentScene` to locate the entry
3. Loops: `ReadScriptByte` → opcode dispatch via `scene_script_jump_table` → execute handler
4. Terminates on opcode `$00`

### Scene Lifecycle (Bank $03)

`ClearSceneState` in `scene_lifecycle.asm` calls `SceneScriptMain` as the first major step in a scene transition, after clearing game state but before camera init, event blocks, and actor spawning.

### Scene Actors / Thinkers (Bank $0C)

The `scene_actors` and `scene_thinkers` blocks define which game objects to spawn in each scene. These are separate from `scene_meta` — actors are loaded after the graphics pipeline completes.

### Graphics Cache System

The scene script maintains a 4-entry ring buffer cache for tile graphics (`$0084`–`$008F`) and per-command source caches (`$066C`–`$0687`) that track recently loaded assets. When transitioning between scenes that share the same tile source, the cache system bypasses decompression entirely, restoring VRAM from WRAM backup buffers.

---

## See Also

- [`scene_script.asm`](../../extracted/system/engine/scene_script.asm) — Scene command interpreter and graphics pipeline
- [`scene_lifecycle.asm`](../../extracted/system/engine/scene_lifecycle.asm) — Scene transition pipeline
- [`SceneLoadPatch.patch.asm`](../../baserom/patches/SceneLoadPatch.patch.asm) — O(1) lookup optimization patch
- [COP System Overview](../cop/index.md) — Game scripting commands
- [Actor Organization Analysis](../actor-organization-analysis.md) — Scene actor structure
